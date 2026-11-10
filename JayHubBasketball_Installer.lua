-- JayHub Basketball installer.
-- Paste this whole file into Roblox Studio's Command Bar (View > Command Bar)
-- and press Enter. It creates every script in the right place. Then press Play.
-- Running it again replaces the previous install.

local parents = {
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	ServerScriptService = game:GetService("ServerScriptService"),
	StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"),
}
local folders = {}
for key, parent in parents do
	local old = parent:FindFirstChild("Basketball")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "Basketball"
	folders[key] = folder
end

local function add(where, className, name, source)
	local s = Instance.new(className)
	s.Name = name
	s.Source = source
	s.Parent = folders[where]
end

-- src/shared/Config.lua
add("ReplicatedStorage", "ModuleScript", "Config", [==[
--!strict
-- Basketball configuration. Every gameplay number lives here so you can tune
-- the feel of the game without touching the scripts.
-- Distances are in studs (roughly 1 stud = 0.3 m for a default character).

local Config = {}

---------------------------------------------------------------------------
-- Court & hoops
---------------------------------------------------------------------------
-- If no parts/models tagged with HoopTag exist when the server starts, a
-- full court with two hoops is generated at CourtOrigin.
Config.AutoBuildCourt = true
Config.CourtOrigin = Vector3.new(0, 0, 0) -- top surface of the floor
Config.CourtLength = 94 -- along X
Config.CourtWidth = 50 -- along Z
Config.RimHeight = 10
Config.RimRadius = 1.6 -- inner radius of the ring
Config.HoopTag = "BasketballHoop" -- CollectionService tag for custom hoops

---------------------------------------------------------------------------
-- Ball
---------------------------------------------------------------------------
Config.BallName = "Basketball"
Config.BallTag = "BasketballBall" -- CollectionService tag the client uses to find the ball
Config.BallDiameter = 1.5
Config.BallColor = Color3.fromRGB(226, 104, 32)
Config.BallDensity = 0.6
Config.BallFriction = 0.5
Config.BallElasticity = 0.72
Config.KillY = -50 -- ball respawns at center court below this height
Config.IdleResetTime = 60 -- seconds a loose, motionless ball waits before respawning (0 = never)

---------------------------------------------------------------------------
-- Possession & dribbling
---------------------------------------------------------------------------
Config.PickupRadius = 3.5 -- how close a loose ball must be to grab it
Config.ShooterRegrabDelay = 0.75 -- shooter/passer can't instantly re-grab the ball
Config.DribbleRate = 9 -- higher = faster dribble
Config.DribbleSide = 1.1 -- how far to the right of the player the ball bounces
Config.DribbleForward = 1.3
Config.HoldOverheadOffset = CFrame.new(0, 2.6, -0.9) -- ball position while loading a shot

---------------------------------------------------------------------------
-- Shooting
---------------------------------------------------------------------------
Config.MeterFillTime = 0.9 -- seconds for the meter to go from empty to full
Config.MeterAutoRelease = 1.1 -- held this long = forced (late) release
Config.PerfectCenter = 0.85 -- where the "green" release sits on the meter (0-1)
Config.PerfectWindow = 0.05 -- +/- around PerfectCenter that counts as perfect
Config.GoodWindow = 0.13 -- +/- around PerfectCenter that counts as good
Config.MaxMissOffset = 3.6 -- how far (studs) the worst shot lands from the rim center
Config.ThreePointDistance = 22 -- shots taken from farther than this are worth 3
Config.DeepRange = 32 -- accuracy starts falling off past this distance
Config.DeepRangeFalloff = 25 -- studs past DeepRange until a shot is fully random
Config.ContestRadius = 6 -- defenders this close in front of the shooter contest the shot
Config.ContestPenalty = 0.3 -- added "badness" when contested (0-1 scale)
Config.ShotCooldown = 0.5
Config.JumpOnShot = true
Config.ReleaseOffset = Vector3.new(0, 3, -1.2) -- relative to HumanoidRootPart
Config.MinArc = 4 -- apex height above the higher of release/rim, short shots
Config.MaxArc = 12
Config.ArcPerStud = 0.16 -- extra arc per stud of shot distance
Config.Backspin = 10

---------------------------------------------------------------------------
-- Passing & stealing
---------------------------------------------------------------------------
Config.PassRange = 60
Config.PassMaxAngle = 65 -- degrees from where you face; receivers outside this are ignored
Config.PassSpeed = 60 -- studs/second
Config.TeamsMatter = true -- if players are on Teams: pass only to teammates, steal only from opponents
Config.StealRange = 6
Config.StealChance = 0.35
Config.StealCooldown = 1.5

---------------------------------------------------------------------------
-- Controls (keyboard, gamepad; mobile gets on-screen buttons automatically)
---------------------------------------------------------------------------
Config.Keys = {
	Shoot = { Enum.KeyCode.E, Enum.KeyCode.ButtonX },
	Pass = { Enum.KeyCode.Q, Enum.KeyCode.ButtonY },
	Steal = { Enum.KeyCode.F, Enum.KeyCode.ButtonB },
}

return Config
]==])

-- src/shared/BallMath.lua
add("ReplicatedStorage", "ModuleScript", "BallMath", [==[
--!strict
-- Shared math used by both server (authoritative) and client (meter display).

local Config = require(script.Parent.Config)

local BallMath = {}

export type Grade = "Perfect" | "Good" | "Early" | "Late"

-- Meter value (0-1) for how long the shot button has been held.
function BallMath.meterValue(elapsed: number): number
	return math.clamp(elapsed / Config.MeterFillTime, 0, 1)
end

-- Turns a meter value into a grade and a "badness" from 0 (pure) to 1 (brick).
function BallMath.gradeRelease(value: number): (Grade, number)
	local err = value - Config.PerfectCenter
	local absErr = math.abs(err)

	if absErr <= Config.PerfectWindow then
		return "Perfect", 0
	end

	if absErr <= Config.GoodWindow then
		-- Small offsets: usually drops, sometimes rattles out.
		local t = (absErr - Config.PerfectWindow) / (Config.GoodWindow - Config.PerfectWindow)
		return "Good", t * 0.35
	end

	local grade: Grade = if err < 0 then "Early" else "Late"
	return grade, math.clamp(0.35 + (absErr - Config.GoodWindow) / 0.25, 0.35, 1)
end

-- Extra badness for shooting from very deep.
function BallMath.distancePenalty(distance: number): number
	if distance <= Config.DeepRange then
		return 0
	end
	return math.clamp((distance - Config.DeepRange) / Config.DeepRangeFalloff, 0, 1)
end

-- Initial velocity that sends a projectile from `from` to `to` in `flightTime` seconds.
function BallMath.velocityForTime(from: Vector3, to: Vector3, flightTime: number, gravity: number): Vector3
	local g = Vector3.new(0, -gravity, 0)
	return (to - from - 0.5 * g * flightTime * flightTime) / flightTime
end

-- Initial velocity for a shot that peaks `arc` studs above the higher of the
-- two points, then comes down onto `to`. Returns velocity and flight time.
function BallMath.velocityForArc(from: Vector3, to: Vector3, arc: number, gravity: number): (Vector3, number)
	local apex = math.max(from.Y, to.Y) + arc
	local up = math.sqrt(2 * gravity * (apex - from.Y))
	local timeUp = up / gravity
	local timeDown = math.sqrt(2 * (apex - to.Y) / gravity)
	local flightTime = timeUp + timeDown

	local flat = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
	return flat / flightTime + Vector3.new(0, up, 0), flightTime
end

function BallMath.arcForDistance(distance: number): number
	return math.clamp(Config.MinArc + distance * Config.ArcPerStud, Config.MinArc, Config.MaxArc)
end

function BallMath.flatDistance(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

return BallMath
]==])

-- src/server/CourtBuilder.lua
add("ServerScriptService", "ModuleScript", "CourtBuilder", [==[
--!strict
-- Generates a playable court with two hoops. Only used when your place has no
-- parts/models tagged with Config.HoopTag.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("Config"))

local CourtBuilder = {}

local FLOOR_COLOR = Color3.fromRGB(196, 146, 92)
local LINE_COLOR = Color3.fromRGB(245, 245, 245)
local RIM_COLOR = Color3.fromRGB(235, 80, 30)

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	return p
end

-- Flat painted line between two points on the floor.
local function line(parent: Instance, a: Vector3, b: Vector3, width: number?)
	local length = (b - a).Magnitude
	if length < 0.01 then
		return
	end
	local mid = (a + b) / 2
	part({
		Name = "Line",
		Size = Vector3.new(width or 0.3, 0.05, length + (width or 0.3)),
		CFrame = CFrame.lookAt(mid, b),
		Color = LINE_COLOR,
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = parent,
	})
end

-- Polyline arc around `center` (on the floor) from angle a0 to a1 (radians, in the XZ plane).
local function arc(parent: Instance, center: Vector3, radius: number, a0: number, a1: number, segments: number, clipZ: number?)
	local prev: Vector3? = nil
	for i = 0, segments do
		local a = a0 + (a1 - a0) * (i / segments)
		local point = center + Vector3.new(math.cos(a) * radius, 0, math.sin(a) * radius)
		if clipZ and math.abs(point.Z - center.Z) > clipZ then
			prev = nil
		else
			if prev then
				line(parent, prev, point)
			end
			prev = point
		end
	end
end

local function buildHoop(parent: Instance, base: Vector3, facing: Vector3, name: string): Model
	local model = Instance.new("Model")
	model.Name = name

	-- Local space: -Z points toward center court, +Z is out of bounds.
	local cf = CFrame.lookAt(base, Vector3.new(facing.X, base.Y, facing.Z))
	local rimHeight = Config.RimHeight
	local radius = Config.RimRadius
	local poleHeight = rimHeight + 3

	part({
		Name = "Pole",
		Size = Vector3.new(0.8, poleHeight, 0.8),
		CFrame = cf * CFrame.new(0, poleHeight / 2, 2),
		Color = Color3.fromRGB(40, 40, 45),
		Material = Enum.Material.Metal,
		Parent = model,
	})
	part({
		Name = "Arm",
		Size = Vector3.new(0.5, 0.5, 3),
		CFrame = cf * CFrame.new(0, rimHeight + 2.5, 0.5),
		Color = Color3.fromRGB(40, 40, 45),
		Material = Enum.Material.Metal,
		Parent = model,
	})
	part({
		Name = "Backboard",
		Size = Vector3.new(6, 3.6, 0.2),
		CFrame = cf * CFrame.new(0, rimHeight + 1.4, -1),
		Color = Color3.fromRGB(230, 240, 255),
		Material = Enum.Material.Glass,
		Transparency = 0.35,
		Parent = model,
	})
	-- Shooter's square on the backboard.
	part({
		Name = "BackboardSquare",
		Size = Vector3.new(2, 1.5, 0.05),
		CFrame = cf * CFrame.new(0, rimHeight + 0.95, -1.13),
		Color = LINE_COLOR,
		Material = Enum.Material.SmoothPlastic,
		Transparency = 0.2,
		CanCollide = false,
		CanQuery = false,
		Parent = model,
	})

	local rimOffsetZ = -(1.1 + radius + 0.1)
	local rimCF = cf * CFrame.new(0, rimHeight, rimOffsetZ)

	-- Invisible marker the server uses for aiming and score detection.
	local center = part({
		Name = "RimCenter",
		Size = Vector3.new(0.2, 0.2, 0.2),
		CFrame = rimCF,
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = model,
	})
	model.PrimaryPart = center

	-- Ring built from short segments so the ball can actually bounce off it.
	local segments = 16
	local tube = 0.18
	local segLength = (2 * math.pi * radius / segments) * 1.15
	for i = 1, segments do
		local angle = (i / segments) * math.pi * 2
		part({
			Name = "Rim",
			Size = Vector3.new(tube, tube, segLength),
			CFrame = rimCF * CFrame.Angles(0, angle, 0) * CFrame.new(radius + tube / 2, 0, 0),
			Color = RIM_COLOR,
			Material = Enum.Material.Metal,
			Parent = model,
		})
	end
	part({
		Name = "RimBracket",
		Size = Vector3.new(0.5, 0.2, 0.3),
		CFrame = cf * CFrame.new(0, rimHeight, -1.25),
		Color = RIM_COLOR,
		Material = Enum.Material.Metal,
		Parent = model,
	})

	-- Decorative net (no collision).
	local net = part({
		Name = "Net",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2, radius * 1.8, radius * 1.8),
		CFrame = rimCF * CFrame.new(0, -1.05, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.new(1, 1, 1),
		Material = Enum.Material.ForceField,
		Transparency = 0.3,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = model,
	})
	net.CastShadow = false

	model.Parent = parent
	CollectionService:AddTag(model, Config.HoopTag)
	return model
end

function CourtBuilder.build(): Folder
	local origin = Config.CourtOrigin
	local halfL = Config.CourtLength / 2
	local halfW = Config.CourtWidth / 2

	local folder = Instance.new("Folder")
	folder.Name = "BasketballCourt"

	part({
		Name = "Floor",
		Size = Vector3.new(Config.CourtLength + 24, 1, Config.CourtWidth + 24),
		Position = origin - Vector3.new(0, 0.5, 0),
		Color = FLOOR_COLOR,
		Material = Enum.Material.WoodPlanks,
		Parent = folder,
	})

	local lines = Instance.new("Folder")
	lines.Name = "Lines"
	lines.Parent = folder
	local y = origin.Y + 0.03
	local function p(x: number, z: number): Vector3
		return Vector3.new(origin.X + x, y, origin.Z + z)
	end

	-- Boundary, half-court line and center circle.
	line(lines, p(-halfL, -halfW), p(halfL, -halfW))
	line(lines, p(-halfL, halfW), p(halfL, halfW))
	line(lines, p(-halfL, -halfW), p(-halfL, halfW))
	line(lines, p(halfL, -halfW), p(halfL, halfW))
	line(lines, p(0, -halfW), p(0, halfW))
	arc(lines, p(0, 0), 6, 0, math.pi * 2, 24)

	local hoops = Instance.new("Folder")
	hoops.Name = "Hoops"
	hoops.Parent = folder

	for _, side in { -1, 1 } do
		local base = p(side * halfL, 0)
		local hoop = buildHoop(hoops, Vector3.new(base.X, origin.Y, base.Z), origin, if side < 0 then "HoopWest" else "HoopEast")
		local rim = (hoop.PrimaryPart :: BasePart).Position
		local under = Vector3.new(rim.X, y, rim.Z)

		-- Three-point arc (clipped at the sidelines) and the corner lines.
		local facingAngle = if side < 0 then 0 else math.pi
		local clip = halfW - 3
		arc(lines, under, Config.ThreePointDistance, facingAngle - math.pi / 2, facingAngle + math.pi / 2, 40, clip)
		local cornerX = math.sqrt(math.max(Config.ThreePointDistance ^ 2 - clip ^ 2, 0))
		for _, zSign in { -1, 1 } do
			local arcEnd = Vector3.new(under.X - side * cornerX, y, origin.Z + zSign * clip)
			line(lines, Vector3.new(base.X, y, arcEnd.Z), arcEnd)
		end

		-- The key (paint) and free-throw circle.
		local keyHalf = 6
		local ftX = base.X - side * 19
		line(lines, Vector3.new(base.X, y, origin.Z - keyHalf), Vector3.new(ftX, y, origin.Z - keyHalf))
		line(lines, Vector3.new(base.X, y, origin.Z + keyHalf), Vector3.new(ftX, y, origin.Z + keyHalf))
		line(lines, Vector3.new(ftX, y, origin.Z - keyHalf), Vector3.new(ftX, y, origin.Z + keyHalf))
		arc(lines, Vector3.new(ftX, y, origin.Z), keyHalf, facingAngle - math.pi / 2, facingAngle + math.pi / 2, 16)
	end

	folder.Parent = workspace
	return folder
end

return CourtBuilder
]==])

-- src/server/Main.server.lua
add("ServerScriptService", "Script", "Main", [==[
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
]==])

-- src/client/Ui.lua
add("StarterPlayerScripts", "ModuleScript", "Ui", [==[
--!strict
-- On-screen HUD: shot meter, release grade, score toasts and control hints.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("Config"))

local Ui = {}

local GRADE_COLORS = {
	Perfect = Color3.fromRGB(70, 220, 100),
	Good = Color3.fromRGB(240, 210, 70),
	Early = Color3.fromRGB(235, 90, 70),
	Late = Color3.fromRGB(235, 90, 70),
}

local gui: ScreenGui
local meter: Frame
local fill: Frame
local gradeLabel: TextLabel
local toastLabel: TextLabel
local hintLabel: TextLabel
local toastToken = 0
local gradeToken = 0
local meterToken = 0

local function make(className: string, props: { [string]: any }): any
	local inst = Instance.new(className)
	for key, value in props do
		if key ~= "Parent" then
			(inst :: any)[key] = value
		end
	end
	inst.Parent = props.Parent
	return inst
end

local function corner(parent: Instance, radius: number)
	make("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function zone(center: number, halfWidth: number, color: Color3, z: number)
	local lo = math.clamp(center - halfWidth, 0, 1)
	local hi = math.clamp(center + halfWidth, 0, 1)
	make("Frame", {
		Name = "Zone",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1 - lo),
		Size = UDim2.fromScale(1, hi - lo),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = z,
		Parent = meter,
	})
end

function Ui.init()
	gui = make("ScreenGui", {
		Name = "BasketballHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	meter = make("Frame", {
		Name = "Meter",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.57, 0.5),
		Size = UDim2.fromOffset(16, 150),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		Parent = gui,
	})
	corner(meter, 6)
	make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5, Transparency = 0.4, Parent = meter })

	zone(Config.PerfectCenter, Config.GoodWindow, GRADE_COLORS.Good, 2)
	zone(Config.PerfectCenter, Config.PerfectWindow, GRADE_COLORS.Perfect, 3)

	fill = make("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = meter,
	})

	gradeLabel = make("TextLabel", {
		Name = "Grade",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.36),
		Size = UDim2.fromOffset(420, 44),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 34,
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 0.4,
		Text = "",
		Parent = gui,
	})

	toastLabel = make("TextLabel", {
		Name = "Toast",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 64),
		Size = UDim2.fromOffset(520, 40),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 26,
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 0.4,
		TextTransparency = 1,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		Text = "",
		Parent = gui,
	})

	hintLabel = make("TextLabel", {
		Name = "Hint",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.fromOffset(520, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(230, 230, 230),
		TextStrokeTransparency = 0.5,
		Text = "",
		Parent = gui,
	})
end

function Ui.showMeter(visible: boolean)
	meterToken += 1
	meter.Visible = visible
	if visible then
		fill.Size = UDim2.fromScale(1, 0)
		fill.BackgroundColor3 = Color3.new(1, 1, 1)
	end
end

function Ui.setMeter(value: number)
	fill.Size = UDim2.fromScale(1, math.clamp(value, 0, 1))
end

-- Freeze the meter where the player let go, tint it, then hide it.
function Ui.releaseMeter(value: number, grade: string)
	Ui.setMeter(value)
	fill.BackgroundColor3 = GRADE_COLORS[grade] or Color3.new(1, 1, 1)
	local token = meterToken
	task.delay(1, function()
		if token == meterToken then
			meter.Visible = false
		end
	end)
end

function Ui.showGrade(grade: string, detail: string?)
	gradeToken += 1
	local token = gradeToken
	gradeLabel.Text = if detail then string.upper(grade) .. "  ·  " .. detail else string.upper(grade)
	gradeLabel.TextColor3 = GRADE_COLORS[grade] or Color3.new(1, 1, 1)
	gradeLabel.TextTransparency = 0
	gradeLabel.TextStrokeTransparency = 0.4
	task.delay(1.2, function()
		if token == gradeToken then
			gradeLabel.Text = ""
		end
	end)
end

function Ui.toast(text: string, color: Color3?)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = text
	toastLabel.TextColor3 = color or Color3.new(1, 1, 1)
	toastLabel.TextTransparency = 0
	toastLabel.TextStrokeTransparency = 0.4
	task.delay(2, function()
		if token == toastToken then
			TweenService:Create(toastLabel, TweenInfo.new(0.4), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

function Ui.setHint(text: string)
	hintLabel.Text = text
end

return Ui
]==])

-- src/client/Main.client.lua
add("StarterPlayerScripts", "LocalScript", "Main", [==[
--!strict
-- Client controller: input (keyboard, gamepad, mobile buttons), the shot
-- meter, and the local dribble animation for every ball holder.

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local BallMath = require(Shared:WaitForChild("BallMath"))
local Ui = require(script.Parent:WaitForChild("Ui"))

local remotes = Shared:WaitForChild("Remotes")
local ShotStart = remotes:WaitForChild("ShotStart") :: RemoteEvent
local ShotRelease = remotes:WaitForChild("ShotRelease") :: RemoteEvent
local PassRemote = remotes:WaitForChild("Pass") :: RemoteEvent
local StealRemote = remotes:WaitForChild("Steal") :: RemoteEvent
local Feedback = remotes:WaitForChild("Feedback") :: RemoteEvent

local player = Players.LocalPlayer
Ui.init()

---------------------------------------------------------------------------
-- Ball lookup
---------------------------------------------------------------------------
local cachedBall: BasePart? = nil
local function getBall(): BasePart?
	if cachedBall and cachedBall.Parent then
		return cachedBall
	end
	for _, inst in CollectionService:GetTagged(Config.BallTag) do
		if inst:IsA("BasePart") then
			cachedBall = inst
			return inst
		end
	end
	cachedBall = nil
	return nil
end

local function isHolding(): boolean
	local ball = getBall()
	return ball ~= nil and ball:GetAttribute("Holder") == player.UserId
end

local function keyName(list: { Enum.KeyCode }): string
	return list[1].Name
end

---------------------------------------------------------------------------
-- Shooting
---------------------------------------------------------------------------
local loading = false
local loadStart = 0

local function releaseShot()
	if not loading then
		return
	end
	loading = false
	local elapsed = os.clock() - loadStart
	local value = BallMath.meterValue(elapsed)
	ShotRelease:FireServer(elapsed)
	Ui.releaseMeter(value, (BallMath.gradeRelease(value)))
end

local function onShoot(_: string, state: Enum.UserInputState, _: InputObject): Enum.ContextActionResult
	if state == Enum.UserInputState.Begin then
		if loading or not isHolding() then
			return Enum.ContextActionResult.Pass
		end
		loading = true
		loadStart = os.clock()
		ShotStart:FireServer()
		Ui.showMeter(true)

		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if Config.JumpOnShot and hum and hum.FloorMaterial ~= Enum.Material.Air then
			hum.Jump = true
		end
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		releaseShot()
	end
	return Enum.ContextActionResult.Sink
end

local function onPass(_: string, state: Enum.UserInputState, _: InputObject): Enum.ContextActionResult
	if state == Enum.UserInputState.Begin and not loading then
		PassRemote:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

local function onSteal(_: string, state: Enum.UserInputState, _: InputObject): Enum.ContextActionResult
	if state == Enum.UserInputState.Begin then
		StealRemote:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

---------------------------------------------------------------------------
-- Context-sensitive controls: offense when you have the ball, defense when not
---------------------------------------------------------------------------
local mode: string? = nil

local function setMode(newMode: string)
	if mode == newMode then
		return
	end
	mode = newMode
	ContextActionService:UnbindAction("BB_Shoot")
	ContextActionService:UnbindAction("BB_Pass")
	ContextActionService:UnbindAction("BB_Steal")

	if newMode == "Offense" then
		ContextActionService:BindAction("BB_Shoot", onShoot, true, table.unpack(Config.Keys.Shoot))
		ContextActionService:BindAction("BB_Pass", onPass, true, table.unpack(Config.Keys.Pass))
		ContextActionService:SetTitle("BB_Shoot", "Shoot")
		ContextActionService:SetTitle("BB_Pass", "Pass")
		ContextActionService:SetPosition("BB_Shoot", UDim2.new(1, -170, 1, -150))
		ContextActionService:SetPosition("BB_Pass", UDim2.new(1, -230, 1, -90))
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			Ui.setHint("Hold Shoot, release in the green")
		else
			Ui.setHint(
				string.format("Hold %s to shoot (release in the green)  ·  %s pass", keyName(Config.Keys.Shoot), keyName(Config.Keys.Pass))
			)
		end
	else
		ContextActionService:BindAction("BB_Steal", onSteal, true, table.unpack(Config.Keys.Steal))
		ContextActionService:SetTitle("BB_Steal", "Steal")
		ContextActionService:SetPosition("BB_Steal", UDim2.new(1, -170, 1, -150))
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			Ui.setHint("")
		else
			Ui.setHint(string.format("%s to steal", keyName(Config.Keys.Steal)))
		end
	end
end
setMode("Defense")

---------------------------------------------------------------------------
-- Server feedback
---------------------------------------------------------------------------
Feedback.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "Shot" then
		local detail = if data.contested then "Contested" else nil
		Ui.showGrade(data.grade, detail)
	elseif kind == "Score" then
		local mine = data.userId == player.UserId
		local text = string.format("%s +%d", mine and "You" or tostring(data.name), data.points)
		Ui.toast(text, if mine then Color3.fromRGB(70, 220, 100) else Color3.fromRGB(255, 200, 90))
	elseif kind == "Info" then
		Ui.toast(tostring(data))
	end
end)

---------------------------------------------------------------------------
-- Per-frame: meter, mode switching, dribble animation
---------------------------------------------------------------------------
local function dribbleOffset(root: BasePart, t: number): CFrame
	local char = root.Parent
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local legs = 2
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then
		legs = hum.HipHeight
	end
	local floorY = -(legs + root.Size.Y / 2) + Config.BallDiameter / 2
	local topY = -0.6
	local bounce = math.abs(math.sin(t * Config.DribbleRate))
	return CFrame.new(Config.DribbleSide, floorY + (topY - floorY) * bounce, -Config.DribbleForward)
end

RunService.RenderStepped:Connect(function(dt)
	local holding = isHolding()
	setMode(if holding then "Offense" else "Defense")

	if loading then
		if not holding then
			-- Lost the ball mid-shot (stolen).
			loading = false
			Ui.showMeter(false)
		else
			local elapsed = os.clock() - loadStart
			Ui.setMeter(BallMath.meterValue(elapsed))
			if elapsed >= Config.MeterAutoRelease then
				releaseShot()
			end
		end
	end

	-- Animate whoever has the ball (purely visual, local to this client).
	local ball = getBall()
	local weld = ball and ball:FindFirstChild("BallWeld")
	if ball and weld and weld:IsA("Weld") and weld.Part0 then
		if ball:GetAttribute("State") == "Hold" then
			weld.C0 = weld.C0:Lerp(Config.HoldOverheadOffset, math.min(1, dt * 18))
		else
			weld.C0 = dribbleOffset(weld.Part0, os.clock())
		end
	end
end)
]==])

for key, folder in folders do
	folder.Parent = parents[key]
end
print("JayHub Basketball installed. Press Play to test.")
