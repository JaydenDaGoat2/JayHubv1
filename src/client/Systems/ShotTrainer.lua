--!nonstrict
-- Shot timing trainer: hold the Shoot key to fill the meter, release on the
-- line. Every release is graded Perfect / Good / Early / Late, recorded in
-- Stats, shown on the HUD and (optionally) played out with a practice ball
-- flying at the nearest hoop. Includes a timed drill mode.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local BallMath = require(Shared:WaitForChild("BallMath"))
local JayHubShared = Shared:WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))
local Signal = require(JayHubShared:WaitForChild("Signal"))
local Timing = require(JayHubShared:WaitForChild("Timing"))

local Client = script.Parent.Parent
local Store = require(Client.Core.Store)
local Theme = require(Client.Core.Theme)
local Notify = require(Client.Core.Notify)
local Keybinds = require(Client.Core.Keybinds)
local Tween = require(Client.UI.Tween)
local Create = require(Client.UI.Create)
local Stats = require(script.Parent.Stats)
local CameraSystem = require(script.Parent.CameraSystem)
local DribbleSystem = require(script.Parent.DribbleSystem)

local T = Theme.T
local player = Players.LocalPlayer

local ShotTrainer = {}

ShotTrainer.Shot = Signal.new() -- (result)
ShotTrainer.DrillChanged = Signal.new() -- (drillState | nil)

export type Drill = { EndsAt: number, Duration: number, Attempts: number, Makes: number, Perfect: number }

local GRADE_TOKEN = {
	Perfect = "Success",
	Good = "Accent",
	Early = "Warning",
	Late = "Danger",
}
local COOLDOWN = 0.3

local charging = false
local chargeStart = 0
local lastRelease = 0
local drill: Drill? = nil
local bestDrill = 0
local rng = Random.new()

-- HUD instances (filled in by buildHud).
local hud: { [string]: any } = {}

---------------------------------------------------------------------------
-- HUD
---------------------------------------------------------------------------

local function layoutMeter()
	local meter = hud.Meter :: Frame
	if not meter then
		return
	end
	local vertical = Store.get("MeterStyle") ~= "Horizontal"
	local windows = Timing.windows(Store.get("TrainerDifficulty"))
	local center = Timing.Center

	if vertical then
		meter.AnchorPoint = Vector2.new(0.5, 0.5)
		meter.Position = UDim2.new(0.5, 120, 0.5, -20)
		meter.Size = UDim2.fromOffset(16, 170)
		hud.Fill.AnchorPoint = Vector2.new(0, 1)
		hud.Fill.Position = UDim2.fromScale(0, 1)
		hud.Good.AnchorPoint = Vector2.new(0, 0.5)
		hud.Good.Position = UDim2.fromScale(0, 1 - center)
		hud.Good.Size = UDim2.fromScale(1, windows.Good * 2)
		hud.Perfect.AnchorPoint = Vector2.new(0, 0.5)
		hud.Perfect.Position = UDim2.fromScale(0, 1 - center)
		hud.Perfect.Size = UDim2.fromScale(1, windows.Perfect * 2)
		hud.Line.AnchorPoint = Vector2.new(0.5, 0.5)
		hud.Line.Position = UDim2.fromScale(0.5, 1 - center)
		hud.Line.Size = UDim2.new(1, 8, 0, 2)
		hud.Info.Position = UDim2.new(0.5, 0, 1, 10)
		hud.Info.AnchorPoint = Vector2.new(0.5, 0)
	else
		meter.AnchorPoint = Vector2.new(0.5, 0.5)
		meter.Position = UDim2.new(0.5, 0, 0.5, 130)
		meter.Size = UDim2.fromOffset(240, 14)
		hud.Fill.AnchorPoint = Vector2.new(0, 0)
		hud.Fill.Position = UDim2.fromScale(0, 0)
		hud.Good.AnchorPoint = Vector2.new(0.5, 0)
		hud.Good.Position = UDim2.fromScale(center, 0)
		hud.Good.Size = UDim2.fromScale(windows.Good * 2, 1)
		hud.Perfect.AnchorPoint = Vector2.new(0.5, 0)
		hud.Perfect.Position = UDim2.fromScale(center, 0)
		hud.Perfect.Size = UDim2.fromScale(windows.Perfect * 2, 1)
		hud.Line.AnchorPoint = Vector2.new(0.5, 0.5)
		hud.Line.Position = UDim2.fromScale(center, 0.5)
		hud.Line.Size = UDim2.new(0, 2, 1, 8)
		hud.Info.Position = UDim2.new(0.5, 0, 1, 10)
		hud.Info.AnchorPoint = Vector2.new(0.5, 0)
	end
end

local function setFill(value: number)
	local fill = hud.Fill :: Frame
	if not fill then
		return
	end
	if Store.get("MeterStyle") ~= "Horizontal" then
		fill.Size = UDim2.fromScale(1, value)
	else
		fill.Size = UDim2.fromScale(value, 1)
	end
end

local function updateInfo()
	if not hud.Info then
		return
	end
	local summary = Stats.session()
	local keyName = Keybinds.display(Keybinds.keyName("Shoot"))
	local hint = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		then "Hold SHOOT"
		else ("Hold %s"):format(keyName)
	hud.Info.Text = ("%s   ·   FG %d%%   ·   STREAK %d"):format(hint, math.floor(summary.Percent + 0.5), summary.Streak)
end

local function showFeedback(result: Timing.Result)
	local label = hud.Feedback :: TextLabel
	if not label then
		return
	end
	local token = GRADE_TOKEN[result.Grade] or "Accent"
	local detail = if result.Made then "MAKE" else "MISS"
	if Store.get("ShowTimingMs") then
		detail ..= ("  ·  %+d ms"):format(result.ErrorMs)
	end
	label.Text = string.upper(result.Grade)
	Theme.bind(label, "TextColor3", token)
	hud.FeedbackSub.Text = detail
	label.TextTransparency = 0
	hud.FeedbackSub.TextTransparency = 0

	local scale = hud.FeedbackScale :: UIScale
	scale.Scale = 0.6
	Tween.play(scale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)

	-- Flash the meter stroke in the grade colour.
	local stroke = hud.MeterStroke :: UIStroke
	stroke.Color = Theme.get(token)
	stroke.Thickness = 2
	Tween.play(stroke, { Thickness = 1, Color = Theme.get("Stroke") }, 0.6)

	local stamp = os.clock()
	hud.FeedbackStamp = stamp
	task.delay(1.1, function()
		if hud.FeedbackStamp == stamp then
			Tween.play(label, { TextTransparency = 1 }, 0.4)
			Tween.play(hud.FeedbackSub, { TextTransparency = 1 }, 0.4)
		end
	end)
end

local function updateDrillBanner()
	local banner = hud.Drill :: Frame
	if not banner then
		return
	end
	local current = drill
	banner.Visible = current ~= nil
	if current then
		local remaining = math.max(current.EndsAt - os.clock(), 0)
		hud.DrillText.Text = ("DRILL   %d:%02d     MAKES %d / %d     PERFECT %d"):format(
			math.floor(remaining / 60),
			math.floor(remaining % 60),
			current.Makes,
			current.Attempts,
			current.Perfect
		)
	end
end

local function setHudVisible(visible: boolean)
	if hud.Meter then
		hud.Meter.Visible = visible
	end
	if hud.ShootButton then
		hud.ShootButton.Visible = visible and UserInputService.TouchEnabled
	end
	if not visible then
		charging = false
		setFill(0)
	end
end

local function buildHud(screenGui: ScreenGui)
	local meter = Create("Frame", {
		Name = "ShotMeter",
		BackgroundColor3 = T.Surface,
		BackgroundTransparency = 0.15,
		Visible = false,
		Parent = screenGui,
	}, { Create.corner(5) })
	local meterStroke = Create.stroke("Stroke", 1, 0)
	meterStroke.Parent = meter
	hud.Meter = meter
	hud.MeterStroke = meterStroke

	hud.Good = Create("Frame", {
		Name = "GoodZone",
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Parent = meter,
	})
	hud.Perfect = Create("Frame", {
		Name = "PerfectZone",
		BackgroundColor3 = T.Success,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = meter,
	})
	hud.Fill = Create("Frame", {
		Name = "Fill",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0),
		ZIndex = 3,
		Parent = meter,
	}, { Create.corner(4), Create.accentGradient(90) })
	hud.Line = Create("Frame", {
		Name = "Target",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = meter,
	})
	hud.Info = Create.text({
		Name = "Info",
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = T.Text,
		TextStrokeTransparency = 0.6,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(260, 14),
		Parent = meter,
	})

	local feedback = Create.text({
		Name = "Feedback",
		Text = "",
		Font = Enum.Font.GothamBlack,
		TextSize = 34,
		TextStrokeTransparency = 0.5,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.32, 0),
		Size = UDim2.fromOffset(320, 40),
		Parent = screenGui,
	})
	hud.Feedback = feedback
	hud.FeedbackScale = Create("UIScale", { Parent = feedback })
	hud.FeedbackSub = Create.text({
		Name = "Detail",
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = T.Text,
		TextStrokeTransparency = 0.5,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 2),
		Size = UDim2.fromOffset(320, 18),
		Parent = feedback,
	})

	local drillBanner = Create("Frame", {
		Name = "Drill",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 64),
		Size = UDim2.fromOffset(420, 34),
		BackgroundColor3 = T.Surface,
		BackgroundTransparency = 0.1,
		Visible = false,
		Parent = screenGui,
	}, { Create.round(), Create.stroke("Accent", 1, 0.2) })
	hud.Drill = drillBanner
	hud.DrillText = Create.text({
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = drillBanner,
	})

	-- Touch shoot button.
	local shootButton = Create("TextButton", {
		Name = "ShootButton",
		Text = "SHOOT",
		Font = Enum.Font.GothamBlack,
		TextSize = 16,
		TextColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -110, 1, -70),
		Size = UDim2.fromOffset(92, 92),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Visible = false,
		Parent = screenGui,
	}, { Create.round(), Create.accentGradient(45), Create.stroke("Text", 2, 0.6) })
	hud.ShootButton = shootButton
	local shootScale = Create("UIScale", { Parent = shootButton })
	shootButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			Tween.play(shootScale, { Scale = 0.9 }, 0.08)
			ShotTrainer.beginShot()
		end
	end)
	shootButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			Tween.play(shootScale, { Scale = 1 }, 0.15, Enum.EasingStyle.Back)
			ShotTrainer.endShot()
		end
	end)

	layoutMeter()
	updateInfo()
end

---------------------------------------------------------------------------
-- Practice ball flight
---------------------------------------------------------------------------

local function nearestRim(origin: Vector3): Vector3?
	local best: Vector3? = nil
	local bestDistance = 80
	for _, hoop in CollectionService:GetTagged(Config.HoopTag) do
		local rim: BasePart? = nil
		if hoop:IsA("Model") and hoop.PrimaryPart then
			rim = hoop.PrimaryPart
		else
			rim = hoop:FindFirstChild("RimCenter", true) :: BasePart?
			if not rim and hoop:IsA("BasePart") then
				rim = hoop
			end
		end
		if rim then
			local distance = BallMath.flatDistance(origin, rim.Position)
			if distance < bestDistance then
				bestDistance = distance
				best = rim.Position
			end
		end
	end
	return best
end

local function launchVisual(made: boolean)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end

	local start = (root.CFrame * CFrame.new(0, 2.6, -1.1)).Position
	local rim = nearestRim(root.Position)
	local target: Vector3
	if rim then
		if made then
			target = rim + Vector3.new(0, 0.15, 0)
		else
			local angle = rng:NextNumber(0, math.pi * 2)
			local miss = Config.RimRadius + rng:NextNumber(0.3, 1.4)
			target = rim + Vector3.new(math.cos(angle) * miss, 0.2, math.sin(angle) * miss)
		end
	else
		target = start + root.CFrame.LookVector * 22 + Vector3.new(0, Config.RimHeight - 3, 0)
	end

	local gravity = workspace.Gravity
	local distance = BallMath.flatDistance(start, target)
	local velocity, flightTime = BallMath.velocityForArc(start, target, BallMath.arcForDistance(distance), gravity)
	if flightTime ~= flightTime or flightTime <= 0 then
		return
	end

	local ball = Instance.new("Part")
	ball.Name = "JayHubShotBall"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.one * Config.BallDiameter
	ball.Material = Enum.Material.SmoothPlastic
	ball.Color = Schema.toColor(Store.get("BallColor"))
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CanTouch = false
	ball.CFrame = CFrame.new(start)
	ball.Parent = workspace

	local hadDribble = DribbleSystem.isActive()
	if hadDribble then
		DribbleSystem.setHidden(true)
	end

	local g = Vector3.new(0, -gravity, 0)
	local elapsed = 0
	local phase = "flight"
	local afterStart = start
	local afterVelocity = velocity
	local afterTime = 0
	local spinAxis = root.CFrame.RightVector

	local conn: RBXScriptConnection
	local function finish()
		conn:Disconnect()
		Tween.playThen(ball, { Transparency = 1 }, 0.3, function()
			ball:Destroy()
		end)
		if hadDribble then
			DribbleSystem.setHidden(false)
		end
	end

	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if phase == "flight" then
			local t = math.min(elapsed, flightTime)
			local position = start + velocity * t + 0.5 * g * t * t
			ball.CFrame = CFrame.new(position) * CFrame.fromAxisAngle(spinAxis, -t * 12)
			if elapsed >= flightTime then
				phase = "after"
				afterStart = position
				local arrive = velocity + g * flightTime
				if made then
					-- Drop through the net.
					afterVelocity = Vector3.new(arrive.X * 0.1, -8, arrive.Z * 0.1)
				else
					-- Kick off the rim.
					local away = Vector3.new(target.X - (rim or target).X, 0, target.Z - (rim or target).Z)
					away = if away.Magnitude > 0.01 then away.Unit else -root.CFrame.LookVector
					afterVelocity = away * rng:NextNumber(6, 11) + Vector3.new(0, rng:NextNumber(7, 11), 0)
				end
			end
		else
			afterTime += dt
			local position = afterStart + afterVelocity * afterTime + 0.5 * g * afterTime * afterTime
			ball.CFrame = CFrame.new(position)
			if afterTime >= 0.6 then
				finish()
			end
		end
	end)
end

---------------------------------------------------------------------------
-- Drill
---------------------------------------------------------------------------

function ShotTrainer.drill(): Drill?
	return drill
end

function ShotTrainer.bestDrill(): number
	return bestDrill
end

function ShotTrainer.startDrill(): (boolean, string)
	if drill then
		return false, "A drill is already running"
	end
	if not Store.get("TrainerEnabled") then
		Store.set("TrainerEnabled", true)
	end
	local duration = Store.get("DrillDuration") :: number
	drill = { EndsAt = os.clock() + duration, Duration = duration, Attempts = 0, Makes = 0, Perfect = 0 }
	ShotTrainer.DrillChanged:Fire(drill)
	updateDrillBanner()
	return true, ("%d second drill started. Make as many as you can!"):format(duration)
end

function ShotTrainer.stopDrill(completed: boolean)
	local current = drill
	if not current then
		return
	end
	drill = nil
	updateDrillBanner()
	ShotTrainer.DrillChanged:Fire(nil)
	if completed then
		local isBest = current.Makes > bestDrill
		bestDrill = math.max(bestDrill, current.Makes)
		local pct = if current.Attempts > 0 then math.floor(current.Makes / current.Attempts * 100 + 0.5) else 0
		Notify.push({
			Title = if isBest then "New drill best!" else "Drill complete",
			Text = ("%d / %d made (%d%%), %d perfect"):format(current.Makes, current.Attempts, pct, current.Perfect),
			Kind = if isBest then "Success" else "Info",
			Duration = 6,
		})
	else
		Notify.info("Drill cancelled", "Shot Trainer")
	end
end

---------------------------------------------------------------------------
-- Shooting
---------------------------------------------------------------------------

function ShotTrainer.isCharging(): boolean
	return charging
end

function ShotTrainer.beginShot()
	if not Store.get("TrainerEnabled") or charging then
		return
	end
	if os.clock() - lastRelease < COOLDOWN then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	charging = true
	chargeStart = os.clock()
end

function ShotTrainer.endShot()
	if not charging then
		return
	end
	charging = false
	lastRelease = os.clock()

	local fillTime = Store.get("MeterSpeed") :: number
	local value = math.clamp((os.clock() - chargeStart) / fillTime, 0, 1)
	setFill(value)
	local result = Timing.grade(value, fillTime, Store.get("TrainerDifficulty"), rng)

	Stats.record(result)
	showFeedback(result)
	updateInfo()
	CameraSystem.shake(if result.Made then 0.35 else 0.6)

	local current = drill
	if current then
		current.Attempts += 1
		if result.Made then
			current.Makes += 1
		end
		if result.Grade == "Perfect" then
			current.Perfect += 1
		end
		updateDrillBanner()
	end

	if Store.get("VisualShot") then
		local ok, err = pcall(launchVisual, result.Made)
		if not ok then
			warn("[JayHub] practice ball failed:", err)
		end
	end

	ShotTrainer.Shot:Fire(result)

	-- Let the result sit on the meter briefly, then reset it.
	task.delay(0.6, function()
		if not charging then
			setFill(0)
		end
	end)
end

local function step()
	if charging then
		local fillTime = Store.get("MeterSpeed") :: number
		local elapsed = os.clock() - chargeStart
		setFill(math.clamp(elapsed / fillTime, 0, 1))
		if Store.get("AutoRelease") and elapsed >= fillTime * 1.12 then
			ShotTrainer.endShot()
		end
	end
	local current = drill
	if current then
		updateDrillBanner()
		if os.clock() >= current.EndsAt then
			ShotTrainer.stopDrill(true)
		end
	end
end

function ShotTrainer.start(screenGui: ScreenGui)
	buildHud(screenGui)

	Keybinds.on("Shoot", function(phase)
		if phase == "Began" then
			ShotTrainer.beginShot()
		else
			ShotTrainer.endShot()
		end
	end)

	Store.observe("TrainerEnabled", function(enabled)
		setHudVisible(enabled == true)
		if not enabled and drill then
			ShotTrainer.stopDrill(false)
		end
	end)
	Store.observeMany({ "MeterStyle", "TrainerDifficulty" }, layoutMeter)
	Store.Changed:Connect(function(key)
		if key == "Key_Shoot" then
			updateInfo()
		end
	end)
	Stats.Changed:Connect(updateInfo)

	RunService.RenderStepped:Connect(function()
		local ok, err = pcall(step)
		if not ok then
			warn("[JayHub] trainer step failed:", err)
		end
	end)
end

return ShotTrainer
