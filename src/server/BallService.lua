-- Server-authoritative basketball logic: ball spawning, possession, shooting,
-- passing, stealing and scoring. The client only says "I pressed / released";
-- the server times the release itself, so a modified client can't fake greens.

local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local BallMath = require(Shared:WaitForChild("BallMath"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local BallService = {}

local GROUP_BALL = "Basketball"
local GROUP_SWISH = "BasketballSwish" -- clean perfects ignore the rim
local GROUP_RIM = "BasketballRim"
local GROUP_CHARACTER = "BasketballCharacter"

local CARRY_OFFSET = CFrame.new(Config.DribbleSide, -1.2, -Config.DribbleForward)
local PASS_COOLDOWN = 0.3
local SHOT_TIMEOUT = 6
local IDLE_SPEED = 0.5

type ShotState = {
	shooter: Player,
	points: number,
	grade: string,
	timingMs: number,
	hoop: BasePart,
	wasAbove: boolean,
	started: number,
}

type BallState = {
	part: Part,
	index: number,
	holder: Player?,
	shot: ShotState?,
	lastMoveTime: number,
	prevPos: Vector3,
}

local balls: { BallState } = {}
local holding: { [Player]: BallState } = {}
local loadingSince: { [Player]: number } = {}
local regrabUntil: { [Player]: number } = {}
local lastShot: { [Player]: number } = {}
local lastPass: { [Player]: number } = {}
local lastSteal: { [Player]: number } = {}
local hoops: { [Instance]: BasePart } = {} -- tagged hoop -> its rim center part

local ShotFeedback = Remotes.get("ShotFeedback")
local ShotOutcome = Remotes.get("ShotOutcome")
local Scored = Remotes.get("Scored")
local Notice = Remotes.get("Notice")

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function rootOf(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function teamsApply(a: Player, b: Player): boolean
	return Config.TeamsMatter and a.Team ~= nil and b.Team ~= nil and not a.Neutral and not b.Neutral
end

local function isTeammate(a: Player, b: Player): boolean
	if teamsApply(a, b) then
		return a.Team == b.Team
	end
	return true
end

local function isOpponent(a: Player, b: Player): boolean
	if teamsApply(a, b) then
		return a.Team ~= b.Team
	end
	return true
end

local function notice(player: Player, text: string, kind: string)
	Notice:FireClient(player, text, kind)
end

local function spawnPosition(index: number): Vector3
	local spread = (index - (Config.BallCount + 1) / 2) * 3
	return Config.CourtOrigin + Vector3.new(0, 4, spread)
end

local function nearestHoop(position: Vector3): BasePart?
	local best, bestDistance = nil, math.huge
	for _, center in hoops do
		local d = BallMath.flatDistance(position, center.Position)
		if d < bestDistance then
			best, bestDistance = center, d
		end
	end
	return best
end

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------

local function setupCollisionGroups()
	for _, name in { GROUP_BALL, GROUP_SWISH, GROUP_RIM, GROUP_CHARACTER } do
		if not PhysicsService:IsCollisionGroupRegistered(name) then
			PhysicsService:RegisterCollisionGroup(name)
		end
	end
	-- The ball never bumps players around; pickups use a radius instead.
	PhysicsService:CollisionGroupSetCollidable(GROUP_BALL, GROUP_CHARACTER, false)
	PhysicsService:CollisionGroupSetCollidable(GROUP_SWISH, GROUP_CHARACTER, false)
	PhysicsService:CollisionGroupSetCollidable(GROUP_SWISH, GROUP_RIM, false)
end

local function rimCenterOf(instance: Instance): BasePart?
	if instance:IsA("BasePart") then
		return instance
	end
	local center = instance:FindFirstChild("RimCenter", true)
	if center and center:IsA("BasePart") then
		return center
	end
	if instance:IsA("Model") then
		return instance.PrimaryPart
	end
	return nil
end

local function addHoop(instance: Instance)
	local center = rimCenterOf(instance)
	if not center then
		warn(`[Basketball] Hoop "{instance:GetFullName()}" needs a part named RimCenter or a PrimaryPart`)
		return
	end
	for _, d in instance:GetDescendants() do
		if d:IsA("BasePart") and d.Name == "Rim" then
			d.CollisionGroup = GROUP_RIM
		end
	end
	hoops[instance] = center
end

local function setCharacterGroup(character: Model)
	local function apply(d: Instance)
		if d:IsA("BasePart") then
			d.CollisionGroup = GROUP_CHARACTER
		end
	end
	for _, d in character:GetDescendants() do
		apply(d)
	end
	character.DescendantAdded:Connect(apply)
end

local ballsFolder: Folder

local function makeBall(index: number): BallState
	local ball = Instance.new("Part")
	ball.Name = Config.BallName
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.one * Config.BallDiameter
	ball.Color = Config.BallColor
	ball.Material = Enum.Material.Plastic
	ball.TopSurface = Enum.SurfaceType.Smooth
	ball.BottomSurface = Enum.SurfaceType.Smooth
	ball.CustomPhysicalProperties =
		PhysicalProperties.new(Config.BallDensity, Config.BallFriction, Config.BallElasticity, 1, 1)
	ball.CollisionGroup = GROUP_BALL
	ball.Position = spawnPosition(index)
	ball:SetAttribute("HolderId", 0)
	ball:SetAttribute("Loading", false)
	ball.Parent = ballsFolder
	ball:SetNetworkOwner(nil)

	return {
		part = ball,
		index = index,
		holder = nil,
		shot = nil,
		lastMoveTime = os.clock(),
		prevPos = ball.Position,
	}
end

---------------------------------------------------------------------------
-- Shot resolution & scoring
---------------------------------------------------------------------------

local function addPoints(player: Player, points: number)
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Points")
	if value and value:IsA("IntValue") then
		value.Value += points
	end
	local team = player.Team
	if team and Config.TeamsMatter and not player.Neutral then
		team:SetAttribute("Score", (team:GetAttribute("Score") or 0) + points)
	end
end

local function resolveShot(state: BallState, made: boolean)
	local shot = state.shot
	if not shot then
		return
	end
	state.shot = nil
	state.part.CollisionGroup = GROUP_BALL

	if made and shot.shooter.Parent then
		addPoints(shot.shooter, shot.points)
		Scored:FireAllClients(shot.shooter, shot.points)
	end
	if shot.shooter.Parent then
		ShotOutcome:FireClient(shot.shooter, {
			made = made,
			points = shot.points,
			grade = shot.grade,
			timingMs = shot.timingMs,
			windowMs = Config.PerfectWindow * Config.MeterFillTime * 1000,
		})
	end
end

---------------------------------------------------------------------------
-- Possession
---------------------------------------------------------------------------

local function clearHolder(state: BallState)
	local holder = state.holder
	if holder then
		holding[holder] = nil
		loadingSince[holder] = nil
	end
	state.holder = nil
	local weld = state.part:FindFirstChild("Hold")
	if weld then
		weld:Destroy()
	end
	state.part:SetAttribute("HolderId", 0)
	state.part:SetAttribute("Loading", false)
end

local function giveBall(state: BallState, player: Player)
	local root = rootOf(player)
	if not root or holding[player] then
		return
	end
	resolveShot(state, false)
	clearHolder(state)

	local ball = state.part
	ball.CanCollide = false
	ball.Massless = true
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	ball.CFrame = root.CFrame * CARRY_OFFSET

	-- Clients animate the dribble by changing this weld's C0 locally.
	local weld = Instance.new("Weld")
	weld.Name = "Hold"
	weld.Part0 = root
	weld.Part1 = ball
	weld.C0 = CARRY_OFFSET
	weld.Parent = ball

	state.holder = player
	holding[player] = state
	ball:SetAttribute("HolderId", player.UserId)
end

local function releaseBall(state: BallState, cframe: CFrame, velocity: Vector3, spin: Vector3?)
	local holder = state.holder
	clearHolder(state)
	if holder then
		regrabUntil[holder] = os.clock() + Config.ShooterRegrabDelay
	end

	local ball = state.part
	ball.Massless = false
	ball.CanCollide = true
	ball.CFrame = cframe
	pcall(function()
		ball:SetNetworkOwner(nil)
	end)
	ball.AssemblyLinearVelocity = velocity
	ball.AssemblyAngularVelocity = spin or Vector3.zero
	state.lastMoveTime = os.clock()
	state.prevPos = ball.Position
end

local function respawnBall(state: BallState)
	resolveShot(state, false)
	releaseBall(state, CFrame.new(spawnPosition(state.index)), Vector3.zero)
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

local function isContested(shooter: Player, root: BasePart, towardHoop: Vector3): boolean
	for _, other in Players:GetPlayers() do
		if other ~= shooter and isOpponent(shooter, other) then
			local otherRoot = rootOf(other)
			if otherRoot then
				local offset = flat(otherRoot.Position - root.Position)
				local d = offset.Magnitude
				if d > 0.01 and d <= Config.ContestRadius and towardHoop:Dot(offset.Unit) > 0.25 then
					return true
				end
			end
		end
	end
	return false
end

local function shoot(player: Player)
	local startedAt = loadingSince[player]
	loadingSince[player] = nil
	local state = holding[player]
	local root = rootOf(player)
	if not startedAt or not state or not root then
		return
	end
	local hoop = nearestHoop(root.Position)
	if not hoop then
		notice(player, "No hoop found", "Warning")
		state.part:SetAttribute("Loading", false)
		return
	end

	local elapsed = os.clock() - startedAt
	local value = BallMath.meterValue(elapsed)
	local grade, badness = BallMath.gradeRelease(value)

	local rim = hoop.Position
	local distance = BallMath.flatDistance(root.Position, rim)
	local towardHoop = flat(rim - root.Position)
	towardHoop = if towardHoop.Magnitude > 0.01 then towardHoop.Unit else flat(root.CFrame.LookVector).Unit

	local contested = isContested(player, root, towardHoop)
	badness += BallMath.distancePenalty(distance)
	if contested then
		badness += Config.ContestPenalty
	end
	badness = math.clamp(badness, 0, 1)

	local target = rim
	if badness > 0 then
		local angle = math.random() * math.pi * 2
		target += Vector3.new(math.cos(angle), 0, math.sin(angle)) * badness * Config.MaxMissOffset
	end

	local facing = CFrame.lookAt(root.Position, root.Position + towardHoop)
	local from = (facing * CFrame.new(Config.ReleaseOffset)).Position
	local velocity = BallMath.velocityForArc(from, target, BallMath.arcForDistance(distance), workspace.Gravity)
	local spin = towardHoop:Cross(Vector3.yAxis) * Config.Backspin

	local points = if distance > Config.ThreePointDistance then 3 else 2
	local timingMs = (elapsed - Config.PerfectCenter * Config.MeterFillTime) * 1000

	releaseBall(state, CFrame.new(from), velocity, spin)
	if badness == 0 then
		state.part.CollisionGroup = GROUP_SWISH
	end
	state.shot = {
		shooter = player,
		points = points,
		grade = grade,
		timingMs = timingMs,
		hoop = hoop,
		wasAbove = false,
		started = os.clock(),
	}
	lastShot[player] = os.clock()

	ShotFeedback:FireClient(player, {
		grade = grade,
		value = value,
		timingMs = timingMs,
		contested = contested,
		deep = distance > Config.DeepRange,
		points = points,
	})
end

local function pass(player: Player)
	local state = holding[player]
	local root = rootOf(player)
	if not state or not root then
		return
	end
	local now = os.clock()
	if now - (lastPass[player] or 0) < PASS_COOLDOWN then
		return
	end
	lastPass[player] = now

	local look = flat(root.CFrame.LookVector).Unit
	local bestRoot: BasePart? = nil
	local bestScore = math.huge
	for _, other in Players:GetPlayers() do
		if other ~= player and isTeammate(player, other) then
			local otherRoot = rootOf(other)
			if otherRoot then
				local offset = flat(otherRoot.Position - root.Position)
				local d = offset.Magnitude
				if d > 1 and d <= Config.PassRange then
					local angle = math.deg(math.acos(math.clamp(look:Dot(offset.Unit), -1, 1)))
					if angle <= Config.PassMaxAngle then
						local score = angle / Config.PassMaxAngle + (d / Config.PassRange) * 0.5
						if score < bestScore then
							bestRoot, bestScore = otherRoot, score
						end
					end
				end
			end
		end
	end

	local from = (root.CFrame * CFrame.new(0, 0.5, -2)).Position
	local target: Vector3
	local flightTime: number
	if bestRoot then
		flightTime = math.max((bestRoot.Position - from).Magnitude / Config.PassSpeed, 0.15)
		-- Lead the receiver so passes to running teammates arrive on time.
		target = bestRoot.Position + flat(bestRoot.AssemblyLinearVelocity) * flightTime
	else
		flightTime = 25 / Config.PassSpeed
		target = from + look * 25
	end
	releaseBall(state, CFrame.new(from), BallMath.velocityForTime(from, target, flightTime, workspace.Gravity))
end

local function steal(player: Player)
	local root = rootOf(player)
	if not root or holding[player] then
		return
	end
	local now = os.clock()
	if now - (lastSteal[player] or 0) < Config.StealCooldown then
		return
	end

	local victim: Player? = nil
	local victimState: BallState? = nil
	local bestDistance = Config.StealRange
	for other, state in holding do
		if other ~= player and isOpponent(player, other) then
			local otherRoot = rootOf(other)
			if otherRoot then
				local d = (otherRoot.Position - root.Position).Magnitude
				if d <= bestDistance then
					victim, victimState, bestDistance = other, state, d
				end
			end
		end
	end
	if not victim or not victimState then
		return -- nobody in range: don't burn the cooldown
	end

	lastSteal[player] = now
	if math.random() < Config.StealChance then
		giveBall(victimState, player)
		regrabUntil[victim] = now + Config.ShooterRegrabDelay
		notice(player, "Steal!", "Success")
		notice(victim, `{player.DisplayName} stole the ball`, "Error")
	else
		notice(player, "Steal missed", "Warning")
	end
end

---------------------------------------------------------------------------
-- Per-frame update
---------------------------------------------------------------------------

local function updateBall(state: BallState, now: number)
	local ball = state.part
	local pos = ball.Position
	local prev = state.prevPos
	state.prevPos = pos

	local holder = state.holder
	if holder then
		if not rootOf(holder) or not holder.Parent then
			releaseBall(state, ball.CFrame, Vector3.new(0, 6, 0)) -- holder died or left: drop it
		end
		return
	end

	-- Scoring: ball center passes down through the rim plane inside the ring.
	local shot = state.shot
	if shot then
		for _, center in hoops do
			local rim = center.Position
			if prev.Y > rim.Y and pos.Y <= rim.Y then
				local t = (prev.Y - rim.Y) / (prev.Y - pos.Y)
				if BallMath.flatDistance(prev:Lerp(pos, t), rim) <= Config.RimRadius then
					resolveShot(state, true)
					break
				end
			end
		end
	end
	shot = state.shot
	if shot then
		local rimY = shot.hoop.Position.Y
		if pos.Y > rimY then
			shot.wasAbove = true
		end
		if (shot.wasAbove and pos.Y < rimY - 3) or now - shot.started > SHOT_TIMEOUT then
			resolveShot(state, false)
		end
	end

	if pos.Y < Config.KillY then
		respawnBall(state)
		return
	end
	if ball.AssemblyLinearVelocity.Magnitude > IDLE_SPEED then
		state.lastMoveTime = now
	elseif
		Config.IdleResetTime > 0
		and now - state.lastMoveTime > Config.IdleResetTime
		and (pos - spawnPosition(state.index)).Magnitude > 3
	then
		respawnBall(state)
		return
	end

	-- Pickup: closest eligible player within range.
	local best: Player? = nil
	local bestDistance = Config.PickupRadius
	for _, player in Players:GetPlayers() do
		if not holding[player] and (regrabUntil[player] or 0) <= now then
			local root = rootOf(player)
			if root then
				local d = (root.Position - pos).Magnitude
				if d <= bestDistance then
					best, bestDistance = player, d
				end
			end
		end
	end
	if best then
		giveBall(state, best)
	end
end

local function onHeartbeat()
	local now = os.clock()
	for player, startedAt in loadingSince do
		if now - startedAt >= Config.MeterAutoRelease then
			shoot(player) -- held too long: forced late release
		end
	end
	for _, state in balls do
		updateBall(state, now)
	end
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------

local function onPlayerAdded(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local points = Instance.new("IntValue")
	points.Name = "Points"
	points.Parent = stats
	stats.Parent = player

	if player.Character then
		setCharacterGroup(player.Character)
	end
	player.CharacterAdded:Connect(setCharacterGroup)
end

local function onPlayerRemoving(player: Player)
	local state = holding[player]
	if state then
		releaseBall(state, state.part.CFrame, Vector3.zero)
	end
	for _, s in balls do
		if s.shot and s.shot.shooter == player then
			s.shot = nil
			s.part.CollisionGroup = GROUP_BALL
		end
	end
	loadingSince[player] = nil
	regrabUntil[player] = nil
	lastShot[player] = nil
	lastPass[player] = nil
	lastSteal[player] = nil
end

function BallService.start()
	setupCollisionGroups()

	for _, hoop in CollectionService:GetTagged(Config.HoopTag) do
		addHoop(hoop)
	end
	CollectionService:GetInstanceAddedSignal(Config.HoopTag):Connect(addHoop)
	CollectionService:GetInstanceRemovedSignal(Config.HoopTag):Connect(function(hoop)
		hoops[hoop] = nil
	end)

	ballsFolder = Instance.new("Folder")
	ballsFolder.Name = "Basketballs"
	ballsFolder.Parent = workspace
	for i = 1, Config.BallCount do
		table.insert(balls, makeBall(i))
	end

	Remotes.get("ShootStart").OnServerEvent:Connect(function(player)
		local state = holding[player]
		if not state or loadingSince[player] then
			return
		end
		if os.clock() - (lastShot[player] or 0) < Config.ShotCooldown then
			return
		end
		loadingSince[player] = os.clock()
		state.part:SetAttribute("Loading", true)
	end)
	Remotes.get("ShootRelease").OnServerEvent:Connect(function(player)
		if loadingSince[player] then
			shoot(player)
		end
	end)
	Remotes.get("Pass").OnServerEvent:Connect(pass)
	Remotes.get("Steal").OnServerEvent:Connect(steal)

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	RunService.Heartbeat:Connect(onHeartbeat)
end

return BallService
