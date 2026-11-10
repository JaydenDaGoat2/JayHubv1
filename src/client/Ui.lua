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
