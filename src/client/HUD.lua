-- Shot meter and short toast messages.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("Config"))

local HUD = {}

local GRADE_COLORS = {
	Perfect = Color3.fromRGB(70, 220, 110),
	Good = Color3.fromRGB(240, 200, 60),
	Early = Color3.fromRGB(235, 90, 70),
	Late = Color3.fromRGB(235, 90, 70),
}
local KIND_COLORS = {
	Success = Color3.fromRGB(70, 220, 110),
	Warning = Color3.fromRGB(240, 200, 60),
	Error = Color3.fromRGB(235, 90, 70),
	Info = Color3.fromRGB(235, 235, 240),
}

local gui: ScreenGui
local meter: Frame
local fill: Frame
local gradeLabel: TextLabel
local toasts: Frame
local hideToken = 0

local function new(className: string, props: { [string]: any }): any
	local inst = Instance.new(className)
	for k, v in props do
		if k ~= "Parent" then
			(inst :: any)[k] = v
		end
	end
	inst.Parent = props.Parent
	return inst
end

local function corner(parent: Instance, radius: number)
	new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

-- A band on the meter between meter values a and b (0 = bottom, 1 = top).
local function zone(a: number, b: number, color: Color3, z: number)
	a, b = math.clamp(a, 0, 1), math.clamp(b, 0, 1)
	new("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1 - a),
		Size = UDim2.fromScale(1, b - a),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = z,
		Parent = meter,
	})
end

function HUD.start()
	gui = new("ScreenGui", {
		Name = "BasketballHUD",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	meter = new("Frame", {
		Name = "Meter",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 80, 0.5, -30),
		Size = UDim2.fromOffset(16, 160),
		BackgroundColor3 = Color3.fromRGB(20, 20, 26),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		Parent = gui,
	})
	corner(meter, 5)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.6, Thickness = 1.5, Parent = meter })

	local c = Config.PerfectCenter
	zone(c - Config.GoodWindow, c + Config.GoodWindow, GRADE_COLORS.Good, 2)
	zone(c - Config.PerfectWindow, c + Config.PerfectWindow, GRADE_COLORS.Perfect, 3)

	fill = new("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = meter,
	})

	gradeLabel = new("TextLabel", {
		Name = "Grade",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.5, 96, 0.5, -30),
		Size = UDim2.fromOffset(180, 44),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextStrokeTransparency = 0.5,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "",
		Visible = false,
		Parent = gui,
	})

	toasts = new("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 48),
		Size = UDim2.fromOffset(360, 200),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	new("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = toasts,
	})
end

function HUD.beginMeter()
	hideToken += 1
	meter.Visible = true
	gradeLabel.Visible = false
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	fill.Size = UDim2.fromScale(1, 0)
end

function HUD.setMeter(value: number)
	fill.Size = UDim2.fromScale(1, math.clamp(value, 0, 1))
end

-- Called with the server's verdict right after release.
function HUD.showGrade(data: { [string]: any })
	local color = GRADE_COLORS[data.grade] or Color3.new(1, 1, 1)
	HUD.setMeter(data.value)
	fill.BackgroundColor3 = color

	local ms = math.floor(data.timingMs + 0.5)
	local extra = {}
	if data.contested then
		table.insert(extra, "contested")
	end
	if data.deep then
		table.insert(extra, "deep")
	end
	gradeLabel.Text = string.upper(data.grade)
		.. `\n<font size="14">{if ms > 0 then "+" else ""}{ms} ms{if #extra > 0 then " · " .. table.concat(extra, ", ") else ""}</font>`
	gradeLabel.RichText = true
	gradeLabel.TextColor3 = color
	gradeLabel.Visible = true

	hideToken += 1
	local token = hideToken
	task.delay(1.4, function()
		if token == hideToken then
			meter.Visible = false
			gradeLabel.Visible = false
		end
	end)
end

function HUD.hideMeter()
	hideToken += 1
	local token = hideToken
	task.delay(0.6, function()
		if token == hideToken then
			meter.Visible = false
		end
	end)
end

function HUD.toast(text: string, kind: string?)
	local label = new("TextLabel", {
		Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(20, 20, 26),
		BackgroundTransparency = 0.25,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = KIND_COLORS[kind or "Info"] or KIND_COLORS.Info,
		Text = text,
		LayoutOrder = math.floor(os.clock() * 1000),
		Parent = toasts,
	})
	corner(label, 8)
	new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = label })

	local children = toasts:GetChildren()
	local count = 0
	for _, child in children do
		if child:IsA("TextLabel") then
			count += 1
		end
	end
	if count > 4 then
		for _, child in children do
			if child:IsA("TextLabel") and child ~= label then
				child:Destroy()
				break
			end
		end
	end

	task.delay(2.2, function()
		if label.Parent then
			local info = TweenInfo.new(0.35)
			TweenService:Create(label, info, { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
			task.wait(0.35)
			label:Destroy()
		end
	end)
end

return HUD
