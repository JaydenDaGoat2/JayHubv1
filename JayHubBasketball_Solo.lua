-- JayHub Basketball (solo, client-side)
-- One self-contained script: builds a private court in the sky above you,
-- teleports you onto it, and gives you a ball with dribbling, a timed shot
-- meter, rebounds and scoring. Everything exists only on your screen.
--
-- Controls: walk over the ball to grab it. Hold E (gamepad X / mobile Shoot
-- button) to load a shot, release in the GREEN zone. Click "Exit court" to
-- remove everything and return to where you were. Running the script again
-- restarts it.

if _G.JayHubBasketball then
	pcall(_G.JayHubBasketball)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

---------------------------------------------------------------------------
-- Config (tune the feel here)
---------------------------------------------------------------------------
local Config = {
	CourtHeight = 400, -- court is built this far above where you start
	CourtLength = 94,
	CourtWidth = 50,
	RimHeight = 10,
	RimRadius = 1.6,

	BallDiameter = 1.5,
	BallColor = Color3.fromRGB(226, 104, 32),
	BallDensity = 0.6,
	BallFriction = 0.5,
	BallElasticity = 0.72,
	IdleResetTime = 30,

	PickupRadius = 3.5,
	ShooterRegrabDelay = 0.75,
	DribbleRate = 9,
	DribbleSide = 1.1,
	DribbleForward = 1.3,
	HoldOverheadOffset = CFrame.new(0, 2.6, -0.9),

	MeterFillTime = 0.9,
	MeterAutoRelease = 1.1,
	PerfectCenter = 0.85,
	PerfectWindow = 0.05,
	GoodWindow = 0.13,
	MaxMissOffset = 3.6,
	ThreePointDistance = 22,
	DeepRange = 32,
	DeepRangeFalloff = 25,
	ShotCooldown = 0.5,
	JumpOnShot = true,
	ReleaseOffset = Vector3.new(0, 3, -1.2),
	MinArc = 4,
	MaxArc = 12,
	ArcPerStud = 0.16,
	Backspin = 10,

	ShootKeys = { Enum.KeyCode.E, Enum.KeyCode.ButtonX },
}

---------------------------------------------------------------------------
-- Bookkeeping / cleanup
---------------------------------------------------------------------------
local connections = {}
local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(connections, c)
	return c
end

local rng = Random.new()

local function flat(v)
	return Vector3.new(v.X, 0, v.Z)
end

local function flatDistance(a, b)
	return flat(a - b).Magnitude
end

local function getRoot()
	local char = player.Character
	if not char then
		return nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart")
end

---------------------------------------------------------------------------
-- Shot math
---------------------------------------------------------------------------
local function meterValue(elapsed)
	return math.clamp(elapsed / Config.MeterFillTime, 0, 1)
end

local function gradeRelease(value)
	local err = value - Config.PerfectCenter
	local absErr = math.abs(err)
	if absErr <= Config.PerfectWindow then
		return "Perfect", 0
	end
	if absErr <= Config.GoodWindow then
		local t = (absErr - Config.PerfectWindow) / (Config.GoodWindow - Config.PerfectWindow)
		return "Good", t * 0.35
	end
	local grade = err < 0 and "Early" or "Late"
	return grade, math.clamp(0.35 + (absErr - Config.GoodWindow) / 0.25, 0.35, 1)
end

local function distancePenalty(distance)
	if distance <= Config.DeepRange then
		return 0
	end
	return math.clamp((distance - Config.DeepRange) / Config.DeepRangeFalloff, 0, 1)
end

local function velocityForArc(from, to, arc, gravity)
	local apex = math.max(from.Y, to.Y) + arc
	local up = math.sqrt(2 * gravity * (apex - from.Y))
	local timeUp = up / gravity
	local timeDown = math.sqrt(2 * (apex - to.Y) / gravity)
	local flightTime = timeUp + timeDown
	return flat(to - from) / flightTime + Vector3.new(0, up, 0)
end

local function arcForDistance(distance)
	return math.clamp(Config.MinArc + distance * Config.ArcPerStud, Config.MinArc, Config.MaxArc)
end

---------------------------------------------------------------------------
-- Court
---------------------------------------------------------------------------
local FLOOR_COLOR = Color3.fromRGB(196, 146, 92)
local LINE_COLOR = Color3.fromRGB(245, 245, 245)
local RIM_COLOR = Color3.fromRGB(235, 80, 30)

local startRoot = getRoot() or player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
local returnCFrame = startRoot.CFrame
local origin = Vector3.new(
	math.floor(startRoot.Position.X),
	math.floor(startRoot.Position.Y + Config.CourtHeight),
	math.floor(startRoot.Position.Z)
)
local KILL_Y = origin.Y - 40
local SPAWN_POS = origin + Vector3.new(0, 6, 0)
local PLAYER_SPAWN = CFrame.lookAt(origin + Vector3.new(8, 4, 0), origin + Vector3.new(60, 4, 0))

local court = Instance.new("Folder")
court.Name = "JayHubBasketballCourt"

local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in pairs(props) do
		p[key] = value
	end
	return p
end

local function line(parent, a, b)
	local length = (b - a).Magnitude
	if length < 0.01 then
		return
	end
	part({
		Name = "Line",
		Size = Vector3.new(0.3, 0.05, length + 0.3),
		CFrame = CFrame.lookAt((a + b) / 2, b),
		Color = LINE_COLOR,
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = parent,
	})
end

local function arc(parent, center, radius, a0, a1, segments, clipZ)
	local prev = nil
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

local hoops = {} -- { center = Vector3, lastScore = number }

local function buildHoop(parent, base, facing)
	local model = Instance.new("Model")
	model.Name = "Hoop"
	local cf = CFrame.lookAt(base, Vector3.new(facing.X, base.Y, facing.Z))
	local rimHeight, radius = Config.RimHeight, Config.RimRadius
	local poleHeight = rimHeight + 3
	local dark = Color3.fromRGB(40, 40, 45)

	part({ Name = "Pole", Size = Vector3.new(0.8, poleHeight, 0.8), CFrame = cf * CFrame.new(0, poleHeight / 2, 2), Color = dark, Material = Enum.Material.Metal, Parent = model })
	part({ Name = "Arm", Size = Vector3.new(0.5, 0.5, 3), CFrame = cf * CFrame.new(0, rimHeight + 2.5, 0.5), Color = dark, Material = Enum.Material.Metal, Parent = model })
	part({ Name = "Backboard", Size = Vector3.new(6, 3.6, 0.2), CFrame = cf * CFrame.new(0, rimHeight + 1.4, -1), Color = Color3.fromRGB(230, 240, 255), Material = Enum.Material.Glass, Transparency = 0.35, Parent = model })
	part({ Name = "BackboardSquare", Size = Vector3.new(2, 1.5, 0.05), CFrame = cf * CFrame.new(0, rimHeight + 0.95, -1.13), Color = LINE_COLOR, Material = Enum.Material.SmoothPlastic, Transparency = 0.2, CanCollide = false, CanQuery = false, Parent = model })

	local rimCF = cf * CFrame.new(0, rimHeight, -(1.1 + radius + 0.1))
	local segments, tube = 16, 0.18
	local segLength = (2 * math.pi * radius / segments) * 1.15
	for i = 1, segments do
		part({
			Name = "Rim",
			Size = Vector3.new(tube, tube, segLength),
			CFrame = rimCF * CFrame.Angles(0, (i / segments) * math.pi * 2, 0) * CFrame.new(radius + tube / 2, 0, 0),
			Color = RIM_COLOR,
			Material = Enum.Material.Metal,
			Parent = model,
		})
	end
	part({ Name = "RimBracket", Size = Vector3.new(0.5, 0.2, 0.3), CFrame = cf * CFrame.new(0, rimHeight, -1.25), Color = RIM_COLOR, Material = Enum.Material.Metal, Parent = model })
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
	table.insert(hoops, { center = rimCF.Position, lastScore = 0 })
	return rimCF.Position
end

do
	local halfL, halfW = Config.CourtLength / 2, Config.CourtWidth / 2
	local floorL, floorW = Config.CourtLength + 24, Config.CourtWidth + 24

	part({
		Name = "Floor",
		Size = Vector3.new(floorL, 1, floorW),
		Position = origin - Vector3.new(0, 0.5, 0),
		Color = FLOOR_COLOR,
		Material = Enum.Material.WoodPlanks,
		Parent = court,
	})
	-- See-through walls so you and the ball can't fall off.
	for _, w in ipairs({
		{ Vector3.new(floorL, 12, 1), Vector3.new(0, 6, floorW / 2) },
		{ Vector3.new(floorL, 12, 1), Vector3.new(0, 6, -floorW / 2) },
		{ Vector3.new(1, 12, floorW), Vector3.new(floorL / 2, 6, 0) },
		{ Vector3.new(1, 12, floorW), Vector3.new(-floorL / 2, 6, 0) },
	}) do
		part({ Name = "Wall", Size = w[1], Position = origin + w[2], Transparency = 0.85, Color = Color3.fromRGB(180, 200, 255), Parent = court })
	end

	local lines = Instance.new("Folder")
	lines.Name = "Lines"
	lines.Parent = court
	local y = origin.Y + 0.03
	local function p(x, z)
		return Vector3.new(origin.X + x, y, origin.Z + z)
	end
	line(lines, p(-halfL, -halfW), p(halfL, -halfW))
	line(lines, p(-halfL, halfW), p(halfL, halfW))
	line(lines, p(-halfL, -halfW), p(-halfL, halfW))
	line(lines, p(halfL, -halfW), p(halfL, halfW))
	line(lines, p(0, -halfW), p(0, halfW))
	arc(lines, p(0, 0), 6, 0, math.pi * 2, 24)

	for _, side in ipairs({ -1, 1 }) do
		local base = p(side * halfL, 0)
		local rim = buildHoop(court, Vector3.new(base.X, origin.Y, base.Z), origin)
		local under = Vector3.new(rim.X, y, rim.Z)
		local facingAngle = side < 0 and 0 or math.pi
		local clip = halfW - 3
		arc(lines, under, Config.ThreePointDistance, facingAngle - math.pi / 2, facingAngle + math.pi / 2, 40, clip)
		local cornerX = math.sqrt(math.max(Config.ThreePointDistance ^ 2 - clip ^ 2, 0))
		for _, zSign in ipairs({ -1, 1 }) do
			local arcEnd = Vector3.new(under.X - side * cornerX, y, origin.Z + zSign * clip)
			line(lines, Vector3.new(base.X, y, arcEnd.Z), arcEnd)
		end
		local keyHalf = 6
		local ftX = base.X - side * 19
		line(lines, Vector3.new(base.X, y, origin.Z - keyHalf), Vector3.new(ftX, y, origin.Z - keyHalf))
		line(lines, Vector3.new(base.X, y, origin.Z + keyHalf), Vector3.new(ftX, y, origin.Z + keyHalf))
		line(lines, Vector3.new(ftX, y, origin.Z - keyHalf), Vector3.new(ftX, y, origin.Z + keyHalf))
		arc(lines, Vector3.new(ftX, y, origin.Z), keyHalf, facingAngle - math.pi / 2, facingAngle + math.pi / 2, 16)
	end
end

court.Parent = workspace

---------------------------------------------------------------------------
-- HUD
---------------------------------------------------------------------------
local GRADE_COLORS = {
	Perfect = Color3.fromRGB(70, 220, 100),
	Good = Color3.fromRGB(240, 210, 70),
	Early = Color3.fromRGB(235, 90, 70),
	Late = Color3.fromRGB(235, 90, 70),
}

local function make(className, props)
	local inst = Instance.new(className)
	for key, value in pairs(props) do
		if key ~= "Parent" then
			inst[key] = value
		end
	end
	inst.Parent = props.Parent
	return inst
end

local gui = make("ScreenGui", {
	Name = "JayHubBasketballHud",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

local meter = make("Frame", {
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
make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = meter })
make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5, Transparency = 0.4, Parent = meter })

local function zone(halfWidth, color, z)
	local lo = math.clamp(Config.PerfectCenter - halfWidth, 0, 1)
	local hi = math.clamp(Config.PerfectCenter + halfWidth, 0, 1)
	make("Frame", {
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
zone(Config.GoodWindow, GRADE_COLORS.Good, 2)
zone(Config.PerfectWindow, GRADE_COLORS.Perfect, 3)

local fill = make("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.fromScale(1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	ZIndex = 4,
	Parent = meter,
})

local function label(props)
	props.BackgroundTransparency = 1
	props.TextColor3 = props.TextColor3 or Color3.new(1, 1, 1)
	props.TextStrokeTransparency = props.TextStrokeTransparency or 0.4
	props.Text = props.Text or ""
	props.Parent = gui
	return make("TextLabel", props)
end

local gradeLabel = label({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.36), Size = UDim2.fromOffset(420, 44), Font = Enum.Font.GothamBlack, TextSize = 34 })
local toastLabel = label({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 64), Size = UDim2.fromOffset(520, 40), Font = Enum.Font.GothamBold, TextSize = 26, TextTransparency = 1 })
local hintLabel = label({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromOffset(520, 24), Font = Enum.Font.GothamMedium, TextSize = 17, TextStrokeTransparency = 0.5 })

local panel = make("Frame", {
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 16, 0, 80),
	Size = UDim2.fromOffset(170, 96),
	BackgroundColor3 = Color3.fromRGB(20, 20, 24),
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	Parent = gui,
})
make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = panel })
local pointsLabel = make("TextLabel", {
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 26),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.new(1, 1, 1),
	Text = "Points: 0",
	Parent = panel,
})
local statsLabel = make("TextLabel", {
	Position = UDim2.fromOffset(12, 34),
	Size = UDim2.new(1, -24, 0, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.fromRGB(200, 200, 200),
	Text = "Makes 0 / 0 shots",
	Parent = panel,
})
local exitButton = make("TextButton", {
	Position = UDim2.new(0, 12, 1, -36),
	Size = UDim2.new(1, -24, 0, 28),
	BackgroundColor3 = Color3.fromRGB(200, 60, 50),
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = Color3.new(1, 1, 1),
	Text = "Exit court",
	Parent = panel,
})
make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = exitButton })

local toastToken, gradeToken, meterToken = 0, 0, 0

local function toast(text, color)
	toastToken = toastToken + 1
	local token = toastToken
	toastLabel.Text = text
	toastLabel.TextColor3 = color or Color3.new(1, 1, 1)
	toastLabel.TextTransparency = 0
	toastLabel.TextStrokeTransparency = 0.4
	task.delay(2, function()
		if token == toastToken and toastLabel.Parent then
			TweenService:Create(toastLabel, TweenInfo.new(0.4), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

local function showGrade(grade, detail)
	gradeToken = gradeToken + 1
	local token = gradeToken
	gradeLabel.Text = detail and (string.upper(grade) .. "  ·  " .. detail) or string.upper(grade)
	gradeLabel.TextColor3 = GRADE_COLORS[grade] or Color3.new(1, 1, 1)
	task.delay(1.2, function()
		if token == gradeToken then
			gradeLabel.Text = ""
		end
	end)
end

local function showMeter()
	meterToken = meterToken + 1
	meter.Visible = true
	fill.Size = UDim2.fromScale(1, 0)
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
end

local function releaseMeter(value, grade)
	fill.Size = UDim2.fromScale(1, value)
	fill.BackgroundColor3 = GRADE_COLORS[grade] or Color3.new(1, 1, 1)
	local token = meterToken
	task.delay(1, function()
		if token == meterToken then
			meter.Visible = false
		end
	end)
end

---------------------------------------------------------------------------
-- Ball
---------------------------------------------------------------------------
local ball = part({
	Name = "Basketball",
	Shape = Enum.PartType.Ball,
	Size = Vector3.one * Config.BallDiameter,
	Color = Config.BallColor,
	Material = Enum.Material.Pebble,
	Anchored = false,
	CFrame = CFrame.new(SPAWN_POS),
	CustomPhysicalProperties = PhysicalProperties.new(Config.BallDensity, Config.BallFriction, Config.BallElasticity, 1, 100),
	Parent = court,
})

local holding = false
local weld = nil
local loading = false
local loadStart = 0
local shotReadyAt = 0
local noGrabUntil = 0
local lastShot = nil -- { points, at }
local prevPos = SPAWN_POS
local lastMoved = os.clock()
local points, makes, attempts = 0, 0, 0

local function updateStats()
	pointsLabel.Text = "Points: " .. points
	statsLabel.Text = string.format("Makes %d / %d shots", makes, attempts)
end

local function setHint()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		hintLabel.Text = holding and "Hold Shoot, release in the green" or "Walk over the ball to grab it"
	else
		hintLabel.Text = holding and "Hold E to shoot, release in the green" or "Walk over the ball to grab it"
	end
end

local function attach(root)
	if weld then
		weld:Destroy()
	end
	holding = true
	loading = false
	lastShot = nil
	ball.CanCollide = false
	ball.Massless = true
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = ball
	weld.C0 = CFrame.new(Config.DribbleSide, -1.5, -Config.DribbleForward)
	weld.Parent = ball
	setHint()
end

local function release()
	if weld then
		weld:Destroy()
		weld = nil
	end
	holding = false
	loading = false
	ball.Massless = false
	ball.CanCollide = true
	lastMoved = os.clock()
	setHint()
end

local function launch(from, velocity, spin)
	release()
	ball.CanCollide = false
	ball.CFrame = CFrame.new(from)
	ball.AssemblyLinearVelocity = velocity
	ball.AssemblyAngularVelocity = spin
	prevPos = from
	task.delay(0.12, function()
		if not holding and ball.Parent then
			ball.CanCollide = true
		end
	end)
end

local function respawnBall()
	if holding then
		release()
	end
	ball.CFrame = CFrame.new(SPAWN_POS)
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
	lastShot = nil
	prevPos = SPAWN_POS
	lastMoved = os.clock()
end

local function nearestHoop(pos)
	local best, bestDist = nil, math.huge
	for _, hoop in ipairs(hoops) do
		local d = flatDistance(pos, hoop.center)
		if d < bestDist then
			best, bestDist = hoop, d
		end
	end
	return best
end

local function shoot(elapsed)
	if not holding then
		return
	end
	local root = getRoot()
	if not root then
		release()
		return
	end
	local now = os.clock()
	local rim = nearestHoop(root.Position).center
	local from = (root.CFrame * CFrame.new(Config.ReleaseOffset)).Position
	local distance = flatDistance(root.Position, rim)
	local value = meterValue(elapsed)
	local grade, badness = gradeRelease(value)
	badness = math.clamp(badness + distancePenalty(distance), 0, 1)

	local target = rim
	if badness > 0 then
		local toRim = flat(rim - from)
		toRim = toRim.Magnitude > 0.01 and toRim.Unit or Vector3.xAxis
		local side = toRim:Cross(Vector3.yAxis)
		local dir
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

	local velocity = velocityForArc(from, target, arcForDistance(distance), workspace.Gravity)
	local travel = flat(velocity)
	local spin = travel.Magnitude > 0.01 and travel.Unit:Cross(Vector3.yAxis) * Config.Backspin or Vector3.zero
	local shotPoints = distance > Config.ThreePointDistance and 3 or 2

	releaseMeter(value, grade)
	launch(from, velocity, spin)
	lastShot = { points = shotPoints, at = now }
	noGrabUntil = now + Config.ShooterRegrabDelay
	shotReadyAt = now + Config.ShotCooldown
	attempts = attempts + 1
	updateStats()
	showGrade(grade, shotPoints == 3 and "3PT" or nil)
end

---------------------------------------------------------------------------
-- Input
---------------------------------------------------------------------------
local function onShoot(_, state)
	if state == Enum.UserInputState.Begin then
		if not holding or loading or os.clock() < shotReadyAt then
			return Enum.ContextActionResult.Pass
		end
		loading = true
		loadStart = os.clock()
		showMeter()
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if Config.JumpOnShot and hum and hum.FloorMaterial ~= Enum.Material.Air then
			hum.Jump = true
		end
		return Enum.ContextActionResult.Sink
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		if loading then
			loading = false
			shoot(os.clock() - loadStart)
			return Enum.ContextActionResult.Sink
		end
	end
	return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority("JayHubBasketball_Shoot", onShoot, true, 3000, table.unpack(Config.ShootKeys))
ContextActionService:SetTitle("JayHubBasketball_Shoot", "Shoot")
ContextActionService:SetPosition("JayHubBasketball_Shoot", UDim2.new(1, -170, 1, -150))

---------------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------------
local function dribbleOffset(root, t)
	local hum = root.Parent and root.Parent:FindFirstChildOfClass("Humanoid")
	local legs = 2
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then
		legs = hum.HipHeight
	end
	local floorY = -(legs + root.Size.Y / 2) + Config.BallDiameter / 2
	local topY = -0.6
	local bounce = math.abs(math.sin(t * Config.DribbleRate))
	return CFrame.new(Config.DribbleSide, floorY + (topY - floorY) * bounce, -Config.DribbleForward)
end

connect(RunService.RenderStepped, function(dt)
	local now = os.clock()
	local root = getRoot()

	if holding then
		if not root or not weld or weld.Parent ~= ball or weld.Part0 ~= root then
			-- Died or respawned while holding: drop it.
			local pos = ball.Position
			release()
			meter.Visible = false
			ball.CFrame = CFrame.new(pos)
			prevPos = pos
			return
		end
		if loading then
			local elapsed = now - loadStart
			fill.Size = UDim2.fromScale(1, meterValue(elapsed))
			weld.C0 = weld.C0:Lerp(Config.HoldOverheadOffset, math.min(1, dt * 18))
			if elapsed >= Config.MeterAutoRelease then
				loading = false
				shoot(Config.MeterAutoRelease)
			end
		else
			weld.C0 = dribbleOffset(root, now)
		end
		prevPos = ball.Position
		return
	end

	local pos = ball.Position

	-- Swish detection: ball center passes down through a ring.
	for _, hoop in ipairs(hoops) do
		local c = hoop.center
		if prevPos.Y > c.Y and pos.Y <= c.Y then
			local t = (prevPos.Y - c.Y) / (prevPos.Y - pos.Y)
			if flatDistance(prevPos:Lerp(pos, t), c) < Config.RimRadius and now - hoop.lastScore > 1 then
				hoop.lastScore = now
				local scored = (lastShot and now - lastShot.at < 8) and lastShot.points or 2
				lastShot = nil
				points = points + scored
				makes = makes + 1
				updateStats()
				toast("BUCKET! +" .. scored, Color3.fromRGB(70, 220, 100))
			end
		end
	end
	prevPos = pos

	if pos.Y < KILL_Y then
		respawnBall()
		return
	end
	if ball.AssemblyLinearVelocity.Magnitude > 0.5 then
		lastMoved = now
	elseif now - lastMoved > Config.IdleResetTime and (pos - SPAWN_POS).Magnitude > 8 then
		respawnBall()
		return
	end

	if root and now >= noGrabUntil and (root.Position - pos).Magnitude <= Config.PickupRadius then
		attach(root)
	end
end)

-- Respawned (died, reset): put you back on the court.
connect(player.CharacterAdded, function(char)
	local root = char:WaitForChild("HumanoidRootPart", 10)
	if root and court.Parent then
		task.wait(0.2)
		root.CFrame = PLAYER_SPAWN
	end
end)

---------------------------------------------------------------------------
-- Start / cleanup
---------------------------------------------------------------------------
local function cleanup()
	_G.JayHubBasketball = nil
	for _, c in ipairs(connections) do
		c:Disconnect()
	end
	ContextActionService:UnbindAction("JayHubBasketball_Shoot")
	if weld then
		weld:Destroy()
	end
	court:Destroy()
	gui:Destroy()
	local root = getRoot()
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.CFrame = returnCFrame
	end
end
_G.JayHubBasketball = cleanup
connect(exitButton.Activated, cleanup)

startRoot.AssemblyLinearVelocity = Vector3.zero
startRoot.CFrame = PLAYER_SPAWN
setHint()
updateStats()
toast("JayHub Basketball loaded")
