--!strict
-- Server-authoritative basketball: possession, dribbling, shooting, passing,
-- stealing and scoring. Clients only send intents ("start shot", "release",
-- "pass", "steal"); every outcome is decided here.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local BallMath = require(Shared:WaitForChild("BallMath"))
local CourtBuilder = require(script.Parent:WaitForChild("CourtBuilder"))

local rng = Random.new()

---------------------------------------------------------------------------
-- Remotes
---------------------------------------------------------------------------
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"

local function remote(name: string): RemoteEvent
	local r = Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end

local ShotStart = remote("ShotStart") -- client -> server: shot button pressed
local ShotRelease = remote("ShotRelease") -- client -> server: (elapsed: number)
local PassRemote = remote("Pass") -- client -> server
local StealRemote = remote("Steal") -- client -> server
local Feedback = remote("Feedback") -- server -> client: (kind: string, data: any)
remotes.Parent = Shared

---------------------------------------------------------------------------
-- Court & hoops
---------------------------------------------------------------------------
if Config.AutoBuildCourt and #CollectionService:GetTagged(Config.HoopTag) == 0 then
	CourtBuilder.build()
end

type Hoop = { instance: Instance, lastScore: number }
local hoops: { [Instance]: Hoop } = {}

local function addHoop(inst: Instance)
	hoops[inst] = { instance = inst, lastScore = 0 }
end
for _, inst in CollectionService:GetTagged(Config.HoopTag) do
	addHoop(inst)
end
CollectionService:GetInstanceAddedSignal(Config.HoopTag):Connect(addHoop)
CollectionService:GetInstanceRemovedSignal(Config.HoopTag):Connect(function(inst)
	hoops[inst] = nil
end)

-- Custom hoops: tag a Model (with a part named "RimCenter" at the middle of
-- the ring, or its PrimaryPart/pivot there) or tag the rim-center part itself.
-- An optional "RimRadius" attribute overrides Config.RimRadius.
local function rimOf(hoop: Hoop): (Vector3?, number)
	local inst = hoop.instance
	local radius = inst:GetAttribute("RimRadius")
	local r = if typeof(radius) == "number" then radius else Config.RimRadius
	if inst:IsA("BasePart") then
		return inst.Position, r
	elseif inst:IsA("Model") then
		local marker = inst:FindFirstChild("RimCenter", true)
		if marker and marker:IsA("BasePart") then
			return marker.Position, r
		end
		return inst:GetPivot().Position, r
	end
	return nil, r
end

local function nearestHoop(pos: Vector3): (Hoop?, Vector3?)
	local best: Hoop?, bestCenter: Vector3?, bestDist = nil, nil, math.huge
	for _, hoop in hoops do
		local center = rimOf(hoop)
		if center then
			local d = BallMath.flatDistance(pos, center)
			if d < bestDist then
				best, bestCenter, bestDist = hoop, center, d
			end
		end
	end
	return best, bestCenter
end

---------------------------------------------------------------------------
-- Players
---------------------------------------------------------------------------
local function rootOf(player: Player?): BasePart?
	if not player then
		return nil
	end
	local char = player.Character
	if not char then
		return nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return nil
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function teamsApply(a: Player, b: Player): boolean
	return Config.TeamsMatter and not a.Neutral and not b.Neutral and a.Team ~= nil and b.Team ~= nil
end

local function canPassTo(from: Player, to: Player): boolean
	return not teamsApply(from, to) or from.Team == to.Team
end

local function isOpponent(a: Player, b: Player): boolean
	return not teamsApply(a, b) or a.Team ~= b.Team
end

local function flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function addPoints(player: Player, points: number)
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Points")
	if value and value:IsA("IntValue") then
		value.Value += points
	end
	local team = player.Team
	if team and teamsApply(player, player) then
		team:SetAttribute("Score", (team:GetAttribute("Score") or 0) + points)
	end
end

Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local points = Instance.new("IntValue")
	points.Name = "Points"
	points.Parent = stats
	stats.Parent = player
end)

---------------------------------------------------------------------------
-- Ball state
---------------------------------------------------------------------------
local SPAWN_POS = Config.CourtOrigin + Vector3.new(0, 6, 0)
local SHOT_GRAB_GRACE = 0.25 -- nobody can grab a shot/pass in the first instant after release
local SCORE_MEMORY = 8 -- seconds a shot stays "live" for scoring

type ShotLoad = { player: Player, startedAt: number, token: number }
type LastShot = { player: Player, points: number, at: number }

local ball: Part
local holder: Player? = nil
local weld: Weld? = nil
local loading: ShotLoad? = nil
local lastShot: LastShot? = nil
local lastToucher: Player? = nil
local releasedAt = 0
local lastMoved = os.clock()
local prevPos = SPAWN_POS
local shotToken = 0

local noGrabUntil: { [Player]: number } = {}
local stealReadyAt: { [Player]: number } = {}
local shotReadyAt: { [Player]: number } = {}

local function setState(state: string)
	ball:SetAttribute("State", state)
end

local function createBall()
	local b = Instance.new("Part")
	b.Name = Config.BallName
	b.Shape = Enum.PartType.Ball
	b.Size = Vector3.one * Config.BallDiameter
	b.Color = Config.BallColor
	b.Material = Enum.Material.Pebble
	b.TopSurface = Enum.SurfaceType.Smooth
	b.BottomSurface = Enum.SurfaceType.Smooth
	b.CustomPhysicalProperties =
		PhysicalProperties.new(Config.BallDensity, Config.BallFriction, Config.BallElasticity, 1, 100)
	b.CFrame = CFrame.new(SPAWN_POS)
	b:SetAttribute("Holder", 0)
	b:SetAttribute("State", "Loose")
	CollectionService:AddTag(b, Config.BallTag)
	b.Parent = workspace
	b:SetNetworkOwner(nil)

	ball = b
	holder, weld, loading, lastShot = nil, nil, nil, nil
	prevPos = SPAWN_POS
	lastMoved = os.clock()

	-- If the ball is ever destroyed (fell out of the world with its holder,
	-- deleted by another script...) make a fresh one.
	b.Destroying:Connect(function()
		if ball == b then
			task.defer(createBall)
		end
	end)
end
createBall()

local function attach(player: Player, root: BasePart)
	if weld then
		weld:Destroy()
	end
	holder = player
	lastToucher = player
	lastShot = nil
	loading = nil

	ball.CanCollide = false
	ball.Massless = true
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero

	-- Welded into the character so it moves smoothly with the owner's
	-- physics. Clients animate the dribble locally by driving C0.
	local w = Instance.new("Weld")
	w.Name = "BallWeld"
	w.Part0 = root
	w.Part1 = ball
	w.C0 = CFrame.new(Config.DribbleSide, -1.5, -Config.DribbleForward)
	w.Parent = ball
	weld = w

	ball:SetAttribute("Holder", player.UserId)
	setState("Dribble")
end

local function release()
	if weld then
		weld:Destroy()
		weld = nil
	end
	holder = nil
	loading = nil
	ball.Massless = false
	ball.CanCollide = true
	ball:SetAttribute("Holder", 0)
	setState("Loose")
	if ball:CanSetNetworkOwnership() then
		ball:SetNetworkOwner(nil)
	end
	releasedAt = os.clock()
	lastMoved = releasedAt
end

-- Releases the ball from `from` with the given velocity/spin.
local function launch(from: Vector3, velocity: Vector3, spin: Vector3)
	release()
	ball.CanCollide = false -- don't clip the thrower on the way out
	ball.CFrame = CFrame.new(from)
	ball.AssemblyLinearVelocity = velocity
	ball.AssemblyAngularVelocity = spin
	prevPos = from
	local launched = ball
	task.delay(0.12, function()
		if launched == ball and holder == nil then
			ball.CanCollide = true
		end
	end)
end

-- Holder died, left, or lost their character: the ball pops loose.
local function drop()
	local root = rootOf(holder)
	local pos = if root then (root.CFrame * CFrame.new(0, 0, -2)).Position else ball.Position
	release()
	ball.CFrame = CFrame.new(pos)
	ball.AssemblyLinearVelocity = Vector3.new(0, 8, 0)
	prevPos = pos
end

local function respawnBall()
	if holder then
		release()
	end
	ball.CFrame = CFrame.new(SPAWN_POS)
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	lastShot = nil
	prevPos = SPAWN_POS
	lastMoved = os.clock()
end

---------------------------------------------------------------------------
-- Shooting
---------------------------------------------------------------------------
local function isContested(shooter: Player, root: BasePart, rim: Vector3): boolean
	local toRim = flat(rim - root.Position)
	if toRim.Magnitude < 0.01 then
		return false
	end
	toRim = toRim.Unit
	for _, other in Players:GetPlayers() do
		if other ~= shooter and isOpponent(shooter, other) then
			local otherRoot = rootOf(other)
			if otherRoot then
				local offset = flat(otherRoot.Position - root.Position)
				if offset.Magnitude <= Config.ContestRadius and offset.Magnitude > 0.01 and offset.Unit:Dot(toRim) > 0.3 then
					return true
				end
			end
		end
	end
	return false
end

local function shoot(player: Player, elapsed: number)
	if holder ~= player then
		return
	end
	local root = rootOf(player)
	if not root then
		drop()
		return
	end

	local now = os.clock()
	local from = (root.CFrame * CFrame.new(Config.ReleaseOffset)).Position
	local _, rim = nearestHoop(root.Position)
	if not rim then
		-- No hoops at all: just toss it forward.
		launch(from, root.CFrame.LookVector * 20 + Vector3.new(0, 25, 0), Vector3.zero)
		noGrabUntil[player] = now + Config.ShooterRegrabDelay
		return
	end

	local distance = BallMath.flatDistance(root.Position, rim)
	local grade, badness = BallMath.gradeRelease(BallMath.meterValue(elapsed))
	local contested = isContested(player, root, rim)
	badness += BallMath.distancePenalty(distance)
	if contested then
		badness += Config.ContestPenalty
	end
	badness = math.clamp(badness, 0, 1)

	-- Bad shots land away from the rim center: early = short, late = long.
	local target = rim
	if badness > 0 then
		local toRim = flat(rim - from)
		toRim = if toRim.Magnitude > 0.01 then toRim.Unit else Vector3.xAxis
		local side = toRim:Cross(Vector3.yAxis)
		local dir: Vector3
		if grade == "Early" then
			dir = -toRim * 0.8 + side * rng:NextNumber(-0.6, 0.6)
		elseif grade == "Late" then
			dir = toRim * 0.8 + side * rng:NextNumber(-0.6, 0.6)
		else
			local a = rng:NextNumber(0, math.pi * 2)
			dir = Vector3.new(math.cos(a), 0, math.sin(a))
		end
		target = rim + dir.Unit * badness * Config.MaxMissOffset
	end

	local velocity = BallMath.velocityForArc(from, target, BallMath.arcForDistance(distance), workspace.Gravity)
	local travel = flat(velocity)
	local spin = if travel.Magnitude > 0.01 then travel.Unit:Cross(Vector3.yAxis) * Config.Backspin else Vector3.zero

	local points = if distance > Config.ThreePointDistance then 3 else 2
	launch(from, velocity, spin)
	lastShot = { player = player, points = points, at = now }
	lastToucher = player
	noGrabUntil[player] = now + Config.ShooterRegrabDelay
	shotReadyAt[player] = now + Config.ShotCooldown

	Feedback:FireClient(player, "Shot", {
		grade = grade,
		points = points,
		contested = contested,
		distance = math.floor(distance + 0.5),
	})
end

ShotStart.OnServerEvent:Connect(function(player)
	if holder ~= player or loading or (shotReadyAt[player] or 0) > os.clock() then
		return
	end
	shotToken += 1
	local token = shotToken
	loading = { player = player, startedAt = os.clock(), token = token }
	setState("Hold")
	if weld then
		weld.C0 = Config.HoldOverheadOffset
	end
	-- Held too long: forced (late) release.
	task.delay(Config.MeterAutoRelease, function()
		if loading and loading.token == token then
			shoot(player, Config.MeterAutoRelease)
		end
	end)
end)

ShotRelease.OnServerEvent:Connect(function(player, clientElapsed)
	local load = loading
	if not load or load.player ~= player then
		return
	end
	-- Trust the client's own timing (it's what the player saw on the meter),
	-- but only within a small window of what the server measured.
	local serverElapsed = os.clock() - load.startedAt
	local elapsed = serverElapsed
	if typeof(clientElapsed) == "number" and clientElapsed == clientElapsed then
		elapsed = math.clamp(clientElapsed, serverElapsed - 0.15, serverElapsed + 0.15)
	end
	shoot(player, math.clamp(elapsed, 0, Config.MeterAutoRelease))
end)

---------------------------------------------------------------------------
-- Passing & stealing
---------------------------------------------------------------------------
PassRemote.OnServerEvent:Connect(function(player)
	if holder ~= player or loading then
		return
	end
	local root = rootOf(player)
	if not root then
		return
	end

	local look = flat(root.CFrame.LookVector)
	look = if look.Magnitude > 0.01 then look.Unit else Vector3.zAxis
	local best: Player?, bestRoot: BasePart?, bestScore = nil, nil, math.huge
	for _, other in Players:GetPlayers() do
		if other ~= player and canPassTo(player, other) then
			local otherRoot = rootOf(other)
			if otherRoot then
				local offset = flat(otherRoot.Position - root.Position)
				local dist = offset.Magnitude
				if dist > 1 and dist <= Config.PassRange then
					local angle = math.deg(math.acos(math.clamp(look:Dot(offset.Unit), -1, 1)))
					if angle <= Config.PassMaxAngle then
						local score = angle + dist * 0.5
						if score < bestScore then
							best, bestRoot, bestScore = other, otherRoot, score
						end
					end
				end
			end
		end
	end

	if not best or not bestRoot then
		Feedback:FireClient(player, "Info", "No teammate open in front of you")
		return
	end

	local from = (root.CFrame * CFrame.new(0, 1, -1.5)).Position
	-- Lead the receiver so the ball meets them where they're running to.
	local flight = (bestRoot.Position - from).Magnitude / Config.PassSpeed
	local to = bestRoot.Position + flat(bestRoot.AssemblyLinearVelocity) * flight + Vector3.new(0, 0.5, 0)
	flight = math.clamp((to - from).Magnitude / Config.PassSpeed, 0.15, 2)

	launch(from, BallMath.velocityForTime(from, to, flight, workspace.Gravity), Vector3.zero)
	lastToucher = player
	noGrabUntil[player] = os.clock() + Config.ShooterRegrabDelay
end)

StealRemote.OnServerEvent:Connect(function(player)
	local now = os.clock()
	local victim = holder
	if not victim or victim == player or (stealReadyAt[player] or 0) > now then
		return
	end
	if not isOpponent(player, victim) then
		return
	end
	local root, victimRoot = rootOf(player), rootOf(victim)
	if not root or not victimRoot then
		return
	end
	if (root.Position - victimRoot.Position).Magnitude > Config.StealRange then
		Feedback:FireClient(player, "Info", "Too far to steal")
		return
	end

	stealReadyAt[player] = now + Config.StealCooldown
	if rng:NextNumber() < Config.StealChance then
		attach(player, root)
		Feedback:FireClient(player, "Info", "Steal!")
		Feedback:FireClient(victim, "Info", player.DisplayName .. " stole the ball")
	else
		Feedback:FireClient(player, "Info", "Steal missed")
	end
end)

---------------------------------------------------------------------------
-- Scoring
---------------------------------------------------------------------------
local function onScore(hoop: Hoop)
	local now = os.clock()
	if now - hoop.lastScore < 1 then
		return
	end
	hoop.lastScore = now

	local scorer: Player?, points = lastToucher, 2
	local shotInfo = lastShot
	if shotInfo and now - shotInfo.at <= SCORE_MEMORY then
		scorer, points = shotInfo.player, shotInfo.points
	end
	lastShot = nil

	if scorer and scorer.Parent then
		addPoints(scorer, points)
		Feedback:FireAllClients("Score", {
			name = scorer.DisplayName,
			userId = scorer.UserId,
			points = points,
		})
	end
end

---------------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	local pos = ball.Position

	if holder then
		local root = rootOf(holder)
		local w = weld
		if not root or not w or w.Parent ~= ball or w.Part0 ~= root then
			drop()
		end
		prevPos = ball.Position
		return
	end

	-- Ball went through a ring (top to bottom)?
	for _, hoop in hoops do
		local center, radius = rimOf(hoop)
		if center and prevPos.Y > center.Y and pos.Y <= center.Y then
			local t = (prevPos.Y - center.Y) / (prevPos.Y - pos.Y)
			local crossing = prevPos:Lerp(pos, t)
			if BallMath.flatDistance(crossing, center) < radius then
				onScore(hoop)
			end
		end
	end
	prevPos = pos

	if pos.Y < Config.KillY then
		respawnBall()
		return
	end

	if Config.IdleResetTime > 0 then
		if ball.AssemblyLinearVelocity.Magnitude > 0.5 then
			lastMoved = now
		elseif now - lastMoved > Config.IdleResetTime and (pos - SPAWN_POS).Magnitude > 8 then
			respawnBall()
			return
		end
	end

	-- Pick up a loose ball.
	if now - releasedAt < SHOT_GRAB_GRACE then
		return
	end
	local best: Player?, bestRoot: BasePart?, bestDist = nil, nil, Config.PickupRadius
	for _, player in Players:GetPlayers() do
		if (noGrabUntil[player] or 0) <= now then
			local root = rootOf(player)
			if root then
				local d = (root.Position - pos).Magnitude
				if d <= bestDist then
					best, bestRoot, bestDist = player, root, d
				end
			end
		end
	end
	if best and bestRoot then
		attach(best, bestRoot)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if holder == player then
		drop()
	end
	if lastToucher == player then
		lastToucher = nil
	end
	if lastShot and lastShot.player == player then
		lastShot = nil
	end
	noGrabUntil[player] = nil
	stealReadyAt[player] = nil
	shotReadyAt[player] = nil
end)
