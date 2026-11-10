--!nonstrict
-- The JayHub window: title bar (drag), sidebar tabs with an animated
-- indicator, scrolling pages, minimize / close, a resize grip, background
-- blur and a floating "JH" button to reopen it (also the touch entry point).

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Core = script.Parent.Parent.Core
local Store = require(Core.Store)
local Theme = require(Core.Theme)
local Notify = require(Core.Notify)
local Keybinds = require(Core.Keybinds)
local Tween = require(script.Parent.Tween)
local Create = require(script.Parent.Create)
local Components = require(script.Parent.Components)

local T = Theme.T

local Window = {}
Window.__index = Window

local TITLE_HEIGHT = 48
local SIDEBAR_WIDTH = 172
local TAB_HEIGHT = 36
local DEFAULT_SIZE = Vector2.new(720, 470)
local MIN_SIZE = Vector2.new(560, 360)
local VERSION = "v1.0"

export type Tab = {
	Name: string,
	Button: TextButton,
	Page: ScrollingFrame,
	Index: number,
}

local function isPress(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function viewportSize(): Vector2
	local camera = workspace.CurrentCamera
	return if camera then camera.ViewportSize else Vector2.new(1280, 720)
end

-- Makes `handle` drag `target` around the screen. `onTap` fires for presses
-- that don't move (used by the floating button).
local function makeDraggable(handle: GuiObject, target: GuiObject, onTap: (() -> ())?)
	local dragging = false
	local moved = false
	local startInput = Vector2.zero
	local startPosition = UDim2.new()
	local activeInput: InputObject? = nil

	handle.InputBegan:Connect(function(input)
		if not isPress(input) then
			return
		end
		dragging = true
		moved = false
		activeInput = input
		startInput = Vector2.new(input.Position.X, input.Position.Y)
		startPosition = target.Position
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not isMove(input) then
			return
		end
		-- With touch, only follow the finger that started the drag.
		if input.UserInputType == Enum.UserInputType.Touch and activeInput and input ~= activeInput then
			return
		end
		local delta = Vector2.new(input.Position.X, input.Position.Y) - startInput
		if delta.Magnitude > 6 then
			moved = true
		end
		if not moved then
			return
		end
		local viewport = viewportSize()
		local size = target.AbsoluteSize
		local anchor = target.AnchorPoint
		local x = startPosition.X.Offset + delta.X
		local y = startPosition.Y.Offset + delta.Y
		-- Keep at least part of the window on screen.
		local baseX = startPosition.X.Scale * viewport.X
		local baseY = startPosition.Y.Scale * viewport.Y
		local minX = -baseX + size.X * anchor.X - size.X + 60
		local maxX = viewport.X - baseX + size.X * anchor.X - 60
		local minY = -baseY + size.Y * anchor.Y
		local maxY = viewport.Y - baseY + size.Y * anchor.Y - 40
		target.Position = UDim2.new(startPosition.X.Scale, math.clamp(x, minX, maxX), startPosition.Y.Scale, math.clamp(y, minY, maxY))
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragging and isPress(input) then
			dragging = false
			if not moved and onTap then
				Components.safeCall(onTap)
			end
		end
	end)
end

function Window.new()
	local self = setmetatable({}, Window)
	self.Tabs = {} :: { Tab }
	self.Selected = nil :: Tab?
	self.IsOpen = true
	self.IsMinimized = false
	self.Size = DEFAULT_SIZE
	self._autoScale = 1
	self._hintShown = false

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Remove a stale copy (e.g. after a script reload in Studio).
	local old = playerGui:FindFirstChild("JayHub")
	if old then
		old:Destroy()
	end

	local gui = Create("ScreenGui", {
		Name = "JayHub",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 50,
		Parent = playerGui,
	})
	self.Gui = gui

	------------------------------------------------------------------ root
	local root = Create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(DEFAULT_SIZE.X, DEFAULT_SIZE.Y),
		BackgroundColor3 = T.Background,
		ClipsDescendants = true,
		Parent = gui,
	}, { Create.corner(12) })
	self.Root = root
	self.Scale = Create("UIScale", { Parent = root })
	local rootStroke = Create("UIStroke", {
		Thickness = 1.5,
		Color = Color3.new(1, 1, 1),
		Transparency = 0.25,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = root,
	})
	local strokeGradient = Create.accentGradient(35)
	strokeGradient.Parent = rootStroke
	self._strokeGradient = strokeGradient

	------------------------------------------------------------------ title bar
	local titleBar = Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),
		BackgroundColor3 = T.Sidebar,
		ZIndex = 5,
		Parent = root,
	})
	local accentLine = Create("Frame", {
		Name = "AccentLine",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = titleBar,
	})
	local lineGradient = Create.accentGradient(0)
	lineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	lineGradient.Parent = accentLine
	self._lineGradient = lineGradient

	local logo = Create("Frame", {
		Name = "Logo",
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 6,
		Parent = titleBar,
	}, { Create.corner(8), Create.accentGradient(45) })
	Create.text({
		Text = "JH",
		Font = Enum.Font.GothamBlack,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 7,
		Parent = logo,
	})
	Create.text({
		Text = "JayHub",
		Font = Enum.Font.GothamBlack,
		TextSize = 16,
		Position = UDim2.fromOffset(52, 8),
		Size = UDim2.fromOffset(120, 18),
		ZIndex = 6,
		Parent = titleBar,
	})
	Create.text({
		Text = "BASKETBALL SUITE  ·  " .. VERSION,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = T.SubText,
		Position = UDim2.fromOffset(52, 27),
		Size = UDim2.fromOffset(200, 12),
		ZIndex = 6,
		Parent = titleBar,
	})

	-- Cloud status pill.
	local status = Create("Frame", {
		Name = "Status",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -92, 0.5, 0),
		Size = UDim2.fromOffset(118, 24),
		BackgroundColor3 = T.Surface2,
		ZIndex = 6,
		Parent = titleBar,
	}, { Create.round(), Create.stroke("Stroke", 1, 0.2) })
	local statusDot = Create("Frame", {
		Position = UDim2.new(0, 10, 0.5, -3),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = T.Warning,
		ZIndex = 7,
		Parent = status,
	}, { Create.round() })
	local statusText = Create.text({
		Text = "Connecting…",
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = T.SubText,
		Position = UDim2.fromOffset(22, 0),
		Size = UDim2.new(1, -26, 1, 0),
		ZIndex = 7,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = status,
	})
	self._statusDot = statusDot
	self._statusText = statusText
	self._statusPill = status

	local function titleButton(name: string, text: string, xOffset: number, hoverToken: string)
		local button = Create("TextButton", {
			Name = name,
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = T.SubText,
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOffset, 0.5, 0),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = T.Sidebar,
			ZIndex = 7,
			Parent = titleBar,
		}, { Create.corner(8) })
		button.MouseEnter:Connect(function()
			Theme.bind(button, "BackgroundColor3", hoverToken, true)
			Theme.bind(button, "TextColor3", "Text", true)
		end)
		button.MouseLeave:Connect(function()
			Theme.bind(button, "BackgroundColor3", "Sidebar", true)
			Theme.bind(button, "TextColor3", "SubText", true)
		end)
		return button
	end
	local closeButton = titleButton("Close", "✕", -12, "Danger")
	local minimizeButton = titleButton("Minimize", "—", -48, "Hover")
	self._minimizeButton = minimizeButton

	closeButton.Activated:Connect(function()
		self:Close()
	end)
	minimizeButton.Activated:Connect(function()
		self:SetMinimized(not self.IsMinimized)
	end)

	-- Drag from anywhere on the title bar that isn't a button.
	local dragHandle = Create("Frame", {
		Name = "DragHandle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -230, 1, 0),
		ZIndex = 5,
		Active = true,
		Parent = titleBar,
	})
	makeDraggable(dragHandle, root)

	------------------------------------------------------------------ body
	local body = Create("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, TITLE_HEIGHT),
		Size = UDim2.new(1, 0, 1, -TITLE_HEIGHT),
		BackgroundTransparency = 1,
		Parent = root,
	})
	self.Body = body

	local sidebar = Create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0),
		BackgroundColor3 = T.Sidebar,
		Parent = body,
	})
	Create("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	local tabList = Create("ScrollingFrame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(0, 10),
		Size = UDim2.new(1, -1, 1, -58),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = sidebar,
	}, { Create.list(4), Create.padding(0, 10, 10, 10) })
	self._tabList = tabList

	-- Player card at the bottom of the sidebar.
	local profile = Create("Frame", {
		Name = "Profile",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -8),
		Size = UDim2.new(1, -21, 0, 38),
		BackgroundColor3 = T.Surface2,
		Parent = sidebar,
	}, { Create.corner(8), Create.stroke("Stroke", 1, 0.3) })
	local avatar = Create("ImageLabel", {
		Position = UDim2.fromOffset(6, 5),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = T.Elevated,
		Image = "",
		Parent = profile,
	}, { Create.round() })
	task.spawn(function()
		local ok, image = pcall(function()
			return Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok then
			avatar.Image = image
		end
	end)
	local profileName = Create.text({
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		Position = UDim2.fromOffset(40, 5),
		Size = UDim2.new(1, -44, 0, 14),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = profile,
	})
	local profileInfo = Create.text({
		TextSize = 10,
		TextColor3 = T.SubText,
		Position = UDim2.fromOffset(40, 20),
		Size = UDim2.new(1, -44, 0, 12),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = profile,
	})
	Store.observeMany({ "Nickname", "JerseyNumber", "Position" }, function()
		local nickname = Store.get("Nickname")
		profileName.Text = if nickname ~= "" then nickname else Players.LocalPlayer.DisplayName
		profileInfo.Text = ("#%d  ·  %s"):format(Store.get("JerseyNumber"), Store.get("Position"))
	end)

	local content = Create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(SIDEBAR_WIDTH, 0),
		Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0),
		BackgroundColor3 = T.Surface,
		ClipsDescendants = true,
		Parent = body,
	})
	self.Content = content
	-- Veil used for the fade-in when switching tabs.
	self._veil = Create("Frame", {
		Name = "Veil",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.Surface,
		BackgroundTransparency = 1,
		ZIndex = 20,
		Active = false,
		Parent = content,
	})

	------------------------------------------------------------------ resize grip
	local grip = Create("TextButton", {
		Name = "ResizeGrip",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		ZIndex = 30,
		Parent = root,
	})
	for i = 0, 2 do
		Create("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -4 - i * 5, 1, -4),
			Size = UDim2.fromOffset(2, 4 + i * 4),
			BackgroundColor3 = T.Muted,
			BorderSizePixel = 0,
			ZIndex = 31,
			Parent = grip,
		})
	end
	self._grip = grip
	self:_bindResize(grip)

	------------------------------------------------------------------ floating button
	local floating = Create("TextButton", {
		Name = "FloatingButton",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.42, 0),
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 40,
		Parent = gui,
	}, {
		Create.corner(14),
		Create.accentGradient(45),
		Create("UIStroke", {
			Color = Color3.new(1, 1, 1),
			Transparency = 0.7,
			Thickness = 1.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})
	Create.text({
		Text = "JH",
		Font = Enum.Font.GothamBlack,
		TextSize = 17,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 41,
		Parent = floating,
	})
	self._floating = floating
	makeDraggable(floating, floating, function()
		self:Toggle()
	end)

	------------------------------------------------------------------ blur
	local blur = Lighting:FindFirstChild("JayHubBlur") :: BlurEffect?
	if not blur then
		local newBlur = Instance.new("BlurEffect")
		newBlur.Name = "JayHubBlur"
		newBlur.Size = 0
		newBlur.Parent = Lighting
		blur = newBlur
	end
	self._blur = blur

	------------------------------------------------------------------ settings
	Store.observe("UITransparency", function(value)
		root.BackgroundTransparency = value
		titleBar.BackgroundTransparency = value
		sidebar.BackgroundTransparency = value
		content.BackgroundTransparency = value
	end)
	Store.observe("UIScale", function()
		self:_applyScale()
	end)
	Store.observe("BlurBackground", function()
		self:_applyBlur()
	end)
	Store.observe("ShowFloatingButton", function()
		self:_updateFloating()
	end)

	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self:_applyScale()
		end)
	end

	Keybinds.on("ToggleMenu", function(phase)
		if phase == "Began" then
			self:Toggle()
		end
	end)

	self:_startEffects()
	self:_applyScale()
	return self
end

---------------------------------------------------------------------------
-- Status
---------------------------------------------------------------------------

function Window:SetStatus(text: string, token: string)
	self._statusText.Text = text
	Theme.bind(self._statusDot, "BackgroundColor3", token)
end

---------------------------------------------------------------------------
-- Scale, blur, effects
---------------------------------------------------------------------------

function Window:_applyScale()
	local viewport = viewportSize()
	-- Shrink to fit small (mobile) screens, then apply the player's scale.
	local fit = math.min(1, (viewport.X - 24) / DEFAULT_SIZE.X, (viewport.Y - 24) / DEFAULT_SIZE.Y)
	self._autoScale = math.max(fit, 0.45)
	local target = self._autoScale * (Store.get("UIScale") :: number)
	if self.IsOpen then
		Tween.play(self.Scale, { Scale = target }, 0.2)
	end
end

function Window:_targetScale(): number
	return self._autoScale * (Store.get("UIScale") :: number)
end

function Window:_applyBlur()
	local size = if self.IsOpen and not self.IsMinimized and Store.get("BlurBackground") then 14 else 0
	Tween.play(self._blur, { Size = size }, 0.3)
end

function Window:_updateFloating()
	-- Touch players always get the button since they have no keyboard.
	local show = Store.get("ShowFloatingButton") or (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
	self._floating.Visible = show == true
end

function Window:_startEffects()
	-- Slowly sweep the accent line and border gradient.
	local t = 0
	RunService.Heartbeat:Connect(function(dt)
		if not self.IsOpen or not Tween.enabled() then
			return
		end
		t = (t + dt * 0.25) % 2
		local offset = t - 1
		self._lineGradient.Offset = Vector2.new(offset * 0.6, 0)
		self._strokeGradient.Rotation = 35 + math.sin(t * math.pi) * 40
	end)
end

---------------------------------------------------------------------------
-- Resize
---------------------------------------------------------------------------

function Window:_bindResize(grip: GuiButton)
	local resizing = false
	local startInput = Vector2.zero
	local startSize = Vector2.zero

	grip.InputBegan:Connect(function(input)
		if isPress(input) and not self.IsMinimized then
			resizing = true
			startInput = Vector2.new(input.Position.X, input.Position.Y)
			startSize = self.Size
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not resizing or not isMove(input) then
			return
		end
		local scale = math.max(self.Scale.Scale, 0.1)
		local delta = (Vector2.new(input.Position.X, input.Position.Y) - startInput) / scale
		local viewport = viewportSize() / scale
		-- Anchor is the centre, so the window grows in both directions;
		-- doubling the delta keeps the grip under the cursor.
		local width = math.clamp(startSize.X + delta.X * 2, MIN_SIZE.X, math.max(MIN_SIZE.X, viewport.X - 20))
		local height = math.clamp(startSize.Y + delta.Y * 2, MIN_SIZE.Y, math.max(MIN_SIZE.Y, viewport.Y - 20))
		self.Size = Vector2.new(width, height)
		self.Root.Size = UDim2.fromOffset(width, height)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if resizing and isPress(input) then
			resizing = false
		end
	end)
end

---------------------------------------------------------------------------
-- Open / close / minimize
---------------------------------------------------------------------------

function Window:Open()
	if self.IsOpen then
		return
	end
	self.IsOpen = true
	self.Root.Visible = true
	self.Scale.Scale = self:_targetScale() * 0.88
	Tween.play(self.Scale, { Scale = self:_targetScale() }, 0.35, Enum.EasingStyle.Back)
	self:_applyBlur()
end

function Window:Close()
	if not self.IsOpen then
		return
	end
	self.IsOpen = false
	Keybinds.cancelCapture()
	self:_applyBlur()
	Tween.playThen(self.Scale, { Scale = self:_targetScale() * 0.88 }, 0.18, function()
		if not self.IsOpen then
			self.Root.Visible = false
		end
	end, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	if self._hintShown then
		return
	end
	self._hintShown = true
	local key = Keybinds.display(Keybinds.keyName("ToggleMenu"))
	local how = if self._floating.Visible then ("Press %s or tap JH to reopen"):format(key) else ("Press %s to reopen"):format(key)
	Notify.info(how, "JayHub hidden")
end

function Window:Toggle()
	if self.IsOpen then
		self:Close()
	else
		self:Open()
	end
end

function Window:SetMinimized(state: boolean)
	self.IsMinimized = state
	self._minimizeButton.Text = if state then "+" else "—"
	self._grip.Visible = not state
	local height = if state then TITLE_HEIGHT else self.Size.Y
	Tween.play(self.Root, { Size = UDim2.fromOffset(self.Size.X, height) }, 0.3)
	self:_applyBlur()
end

---------------------------------------------------------------------------
-- Tabs
---------------------------------------------------------------------------

-- Adds a tab. `build(page)` fills it; errors while building are caught and
-- shown on the page instead of breaking the window.
function Window:AddTab(name: string, build: (ScrollingFrame) -> ())
	local index = #self.Tabs + 1

	local button = Create("TextButton", {
		Name = name,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, TAB_HEIGHT),
		BackgroundColor3 = T.Elevated,
		BackgroundTransparency = 1,
		LayoutOrder = index,
		Parent = self._tabList,
	}, { Create.corner(8) })
	local number = Create.text({
		Name = "Number",
		Text = string.format("%02d", index),
		Font = Enum.Font.Code,
		TextSize = 11,
		TextColor3 = T.Muted,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(0, 22, 1, 0),
		Parent = button,
	})
	-- Accent bar that grows on the selected tab.
	Create("Frame", {
		Name = "Bar",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = button,
	}, { Create.round(), Create.accentGradient(90) })
	local label = Create.text({
		Name = "Label",
		Text = name,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = T.SubText,
		Position = UDim2.fromOffset(38, 0),
		Size = UDim2.new(1, -42, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = button,
	})

	local page = Create("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Accent,
		ScrollBarImageTransparency = 0.3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = self.Content,
	}, { Create.list(12), Create.padding(18, 20, 22, 20) })

	local tab: Tab = { Name = name, Button = button, Page = page, Index = index }
	table.insert(self.Tabs, tab)

	button.MouseEnter:Connect(function()
		if self.Selected ~= tab then
			Tween.play(button, { BackgroundTransparency = 0.6 }, 0.15)
			Theme.bind(label, "TextColor3", "Text")
		end
	end)
	button.MouseLeave:Connect(function()
		if self.Selected ~= tab then
			Tween.play(button, { BackgroundTransparency = 1 }, 0.15)
			Theme.bind(label, "TextColor3", "SubText")
		end
	end)
	button.Activated:Connect(function()
		self:SelectTab(name)
	end)

	local ok, err = pcall(build, page)
	if not ok then
		warn(("[JayHub] building tab %s failed: %s"):format(name, tostring(err)))
		Components.Paragraph(page, "This tab failed to load: " .. tostring(err), "Danger")
	end

	return tab
end

function Window:SelectTab(name: string)
	local target: Tab? = nil
	for _, tab in self.Tabs do
		if tab.Name == name then
			target = tab
		end
	end
	if not target or self.Selected == target then
		return
	end
	self.Selected = target

	for _, tab in self.Tabs do
		local selected = tab == target
		tab.Page.Visible = selected
		local label = tab.Button:FindFirstChild("Label") :: TextLabel
		local number = tab.Button:FindFirstChild("Number") :: TextLabel
		Tween.play(tab.Button, { BackgroundTransparency = if selected then 0 else 1 }, 0.2)
		Theme.bind(tab.Button, "BackgroundColor3", if selected then "AccentDim" else "Elevated")
		Theme.bind(label, "TextColor3", if selected then "Text" else "SubText")
		Theme.bind(number, "TextColor3", if selected then "Accent" else "Muted")
		label.Font = if selected then Enum.Font.GothamBold else Enum.Font.GothamMedium
		local bar = tab.Button:FindFirstChild("Bar") :: Frame
		Tween.play(bar, { Size = UDim2.fromOffset(3, if selected then TAB_HEIGHT - 14 else 0) }, 0.3, Enum.EasingStyle.Back)
	end

	-- Page transition: fade from a veil and slide up slightly.
	local page = target.Page
	page.CanvasPosition = Vector2.zero
	page.Position = UDim2.fromOffset(0, 14)
	Tween.play(page, { Position = UDim2.fromOffset(0, 0) }, 0.3)
	self._veil.BackgroundTransparency = 0
	Tween.play(self._veil, { BackgroundTransparency = 1 }, 0.25)
end

return Window
