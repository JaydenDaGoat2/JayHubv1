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
