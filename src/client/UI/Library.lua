-- A clean, dark UI library: one draggable window with sidebar tabs, section
-- cards and the usual controls, plus toast notifications.
--
--   local Library = require(script.Parent.UI.Library)
--   local window = Library.new({ Title = "JayHub", Subtitle = "Basketball" })
--   local tab = window:AddTab("Gameplay")
--   local section = tab:AddSection("Shooting")
--   section:AddToggle({ Text = "Show shot meter", Default = true, Callback = function(on) end })
--   window:Notify({ Title = "Loaded", Text = "Press RightShift to toggle the menu." })
--
-- Every control returns an object with :Get() and :Set(value). :Set fires the
-- callback unless you pass `true` as the second argument (silent).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)

local C = Theme.Colors
local F = Theme.Fonts
local T = Theme.TextSize

local Library = {}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function create(className, props, children)
	local inst = Instance.new(className)
	for key, value in props or {} do
		if key ~= "Parent" then
			inst[key] = value
		end
	end
	for _, child in children or {} do
		child.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function tween(inst, props, info)
	local t = TweenService:Create(inst, info or Theme.Tween, props)
	t:Play()
	return t
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, thickness)
	return create("UIStroke", {
		Color = color or C.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(all, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or all),
		PaddingRight = UDim.new(0, right or all),
		PaddingTop = UDim.new(0, top or all),
		PaddingBottom = UDim.new(0, bottom or all),
	})
end

local function list(spacing, direction)
	return create("UIListLayout", {
		Padding = UDim.new(0, spacing or 0),
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

local function label(props)
	local base = {
		BackgroundTransparency = 1,
		Font = F.Medium,
		TextSize = T.Body,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}
	for key, value in props do
		base[key] = value
	end
	return create("TextLabel", base)
end

local function isClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function keyName(keyCode)
	if keyCode == nil then
		return "None"
	end
	local name = keyCode.Name
	-- "LeftShift" -> "LShift", "ButtonX" stays as is.
	name = name:gsub("^Left", "L"):gsub("^Right", "R")
	return name
end

-- Row with a label on the left; controls are added on the right.
local function row(parent, text, height, order)
	local frame = create("Frame", {
		Name = text,
		Size = UDim2.new(1, 0, 0, height or 32),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = parent,
	})
	local lbl = label({
		Name = "Label",
		Text = text,
		Size = UDim2.new(1, -150, 0, height or 32),
		Parent = frame,
	})
	return frame, lbl
end

---------------------------------------------------------------------------
-- Section (a card inside a tab that holds controls)
---------------------------------------------------------------------------

local Section = {}
Section.__index = Section

function Section:_next()
	self._order += 1
	return self._order
end

function Section:AddLabel(text)
	local lbl = label({
		Text = text,
		Font = F.Regular,
		TextColor3 = C.SubText,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self:_next(),
		Parent = self.Container,
	})
	return {
		Set = function(_, value)
			lbl.Text = value
		end,
		Get = function()
			return lbl.Text
		end,
	}
end

function Section:AddButton(opts)
	local window = self._window
	local button = create("TextButton", {
		Name = opts.Text,
		Text = opts.Text,
		Font = F.Medium,
		TextSize = T.Body,
		TextColor3 = C.Text,
		AutoButtonColor = false,
		BackgroundColor3 = C.Elevated,
		Size = UDim2.new(1, 0, 0, 32),
		LayoutOrder = self:_next(),
		Parent = self.Container,
	}, { corner(6), stroke() })

	button.MouseEnter:Connect(function()
		tween(button, { BackgroundColor3 = C.Hover })
	end)
	button.MouseLeave:Connect(function()
		tween(button, { BackgroundColor3 = C.Elevated })
	end)
	button.Activated:Connect(function()
		button.BackgroundColor3 = window.Accent
		tween(button, { BackgroundColor3 = C.Hover }, TweenInfo.new(0.35, Enum.EasingStyle.Quint))
		if opts.Callback then
			task.spawn(opts.Callback)
		end
	end)
	return {
		SetText = function(_, text)
			button.Text = text
		end,
	}
end

function Section:AddToggle(opts)
	local window = self._window
	local value = opts.Default == true

	local frame = row(self.Container, opts.Text, 32, self:_next())
	frame.Label.Size = UDim2.new(1, -50, 1, 0)
	local hitbox = create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = frame,
	})
	local switch = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = C.Track,
		Parent = frame,
	}, { corner(10) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = C.Knob,
		Parent = switch,
	}, { corner(8) })

	local function render(instant)
		local goalBg = { BackgroundColor3 = if value then window.Accent else C.Track }
		local goalKnob = { Position = if value then UDim2.new(1, -18, 0.5, 0) else UDim2.new(0, 2, 0.5, 0) }
		if instant then
			switch.BackgroundColor3 = goalBg.BackgroundColor3
			knob.Position = goalKnob.Position
		else
			tween(switch, goalBg)
			tween(knob, goalKnob)
		end
	end

	local control = {}
	function control:Get()
		return value
	end
	function control:Set(newValue, silent)
		value = newValue == true
		render(false)
		if opts.Callback and not silent then
			task.spawn(opts.Callback, value)
		end
	end

	hitbox.Activated:Connect(function()
		control:Set(not value)
	end)
	window:_onAccent(function()
		render(true)
	end)
	render(true)
	return control
end

function Section:AddSlider(opts)
	local window = self._window
	local min, max = opts.Min or 0, opts.Max or 100
	local step = opts.Step or 1
	local suffix = opts.Suffix or ""
	local value = math.clamp(opts.Default or min, min, max)

	local frame = row(self.Container, opts.Text, 44, self:_next())
	frame.Label.Size = UDim2.new(1, -70, 0, 22)

	local valueLabel = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 70, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = C.SubText,
		Parent = frame,
	})
	local track = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = C.Track,
		Parent = frame,
	}, { corner(3) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = window.Accent,
		Parent = track,
	}, { corner(3) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = C.Knob,
		ZIndex = 2,
		Parent = track,
	}, { corner(7) })

	local decimals = 0
	local stepText = tostring(step)
	local dot = stepText:find("%.")
	if dot then
		decimals = #stepText - dot
	end

	local function render()
		local alpha = if max > min then (value - min) / (max - min) else 0
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = string.format("%." .. decimals .. "f", value) .. suffix
	end

	local control = {}
	function control:Get()
		return value
	end
	function control:Set(newValue, silent)
		local snapped = min + math.floor((newValue - min) / step + 0.5) * step
		snapped = math.clamp(snapped, min, max)
		if snapped == value then
			render()
			return
		end
		value = snapped
		render()
		if opts.Callback and not silent then
			task.spawn(opts.Callback, value)
		end
	end

	local dragging = false
	local function fromInput(x)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		control:Set(min + (max - min) * alpha)
	end

	track.InputBegan:Connect(function(input)
		if isClick(input) then
			dragging = true
			fromInput(input.Position.X)
		end
	end)
	window:_connect(UserInputService.InputChanged:Connect(function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			fromInput(input.Position.X)
		end
	end))
	window:_connect(UserInputService.InputEnded:Connect(function(input)
		if isClick(input) then
			dragging = false
		end
	end))
	window:_onAccent(function(accent)
		fill.BackgroundColor3 = accent
	end)

	render()
	return control
end

function Section:AddDropdown(opts)
	local window = self._window
	local options = opts.Options or {}
	local value = opts.Default or options[1]
	local open = false

	local holder = create("Frame", {
		Name = opts.Text,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = self:_next(),
		Parent = self.Container,
	}, { list(4) })

	local header = row(holder, opts.Text, 32, 1)
	local current = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(140, 26),
		BackgroundColor3 = C.Elevated,
		AutoButtonColor = false,
		Font = F.Medium,
		TextSize = T.Body,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	}, { corner(6), stroke(), padding(0, 10, 24, 0, 0) })
	local arrow = label({
		Text = "▾",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 18, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = C.SubText,
		Parent = current,
	})

	local optionList = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Elevated,
		Visible = false,
		LayoutOrder = 2,
		Parent = holder,
	}, { corner(6), stroke(), padding(4), list(2) })

	local control = {}
	local buttons = {}

	local function render()
		current.Text = if value ~= nil then tostring(value) else "Select…"
		for option, button in buttons do
			local selected = option == value
			button.TextColor3 = if selected then window.Accent else C.Text
			button.BackgroundTransparency = if selected then 0 else 1
		end
	end

	local function setOpen(state)
		open = state
		optionList.Visible = open
		arrow.Rotation = if open then 180 else 0
	end

	function control:Get()
		return value
	end
	function control:Set(newValue, silent)
		value = newValue
		render()
		if opts.Callback and not silent then
			task.spawn(opts.Callback, value)
		end
	end
	function control:SetOptions(newOptions)
		for _, button in buttons do
			button:Destroy()
		end
		buttons = {}
		options = newOptions
		for i, option in options do
			local button = create("TextButton", {
				Text = tostring(option),
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = C.Hover,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Font = F.Medium,
				TextSize = T.Body,
				TextColor3 = C.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = i,
				Parent = optionList,
			}, { corner(4), padding(0, 8, 8, 0, 0) })
			button.Activated:Connect(function()
				setOpen(false)
				control:Set(option)
			end)
			buttons[option] = button
		end
		render()
	end

	current.Activated:Connect(function()
		setOpen(not open)
	end)
	window:_onAccent(render)

	control:SetOptions(options)
	return control
end

function Section:AddKeybind(opts)
	local window = self._window
	local value = opts.Default
	local listening = false

	local frame = row(self.Container, opts.Text, 32, self:_next())
	frame.Label.Size = UDim2.new(1, -100, 1, 0)
	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(90, 26),
		BackgroundColor3 = C.Elevated,
		AutoButtonColor = false,
		Font = F.Medium,
		TextSize = T.Body,
		TextColor3 = C.Text,
		Parent = frame,
	}, { corner(6), stroke() })

	local function render()
		button.Text = if listening then "Press a key…" else keyName(value)
		button.TextColor3 = if listening then window.Accent else C.Text
	end

	local control = {}
	function control:Get()
		return value
	end
	function control:Set(keyCode, silent)
		value = keyCode
		render()
		if opts.Callback and not silent then
			task.spawn(opts.Callback, value)
		end
	end

	button.Activated:Connect(function()
		listening = true
		window._capturingKey = true
		render()
	end)
	window:_connect(UserInputService.InputBegan:Connect(function(input)
		if not listening then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.Keyboard and input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end
		listening = false
		-- Let the window's toggle-key handler see that this press was consumed.
		task.defer(function()
			window._capturingKey = false
		end)
		if input.KeyCode == Enum.KeyCode.Escape then
			render() -- cancel, keep the old key
			return
		end
		control:Set(input.KeyCode)
	end))
	window:_onAccent(render)

	render()
	return control
end

function Section:AddTextBox(opts)
	local frame = row(self.Container, opts.Text, 32, self:_next())
	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(140, 26),
		BackgroundColor3 = C.Elevated,
		ClearTextOnFocus = false,
		Text = opts.Default or "",
		PlaceholderText = opts.Placeholder or "",
		PlaceholderColor3 = C.Muted,
		Font = F.Medium,
		TextSize = T.Body,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	}, { corner(6), stroke(), padding(0, 8, 8, 0, 0) })
	local boxStroke = box:FindFirstChildOfClass("UIStroke")

	box.Focused:Connect(function()
		boxStroke.Color = self._window.Accent
	end)
	box.FocusLost:Connect(function(enterPressed)
		boxStroke.Color = C.Stroke
		if opts.Callback then
			task.spawn(opts.Callback, box.Text, enterPressed)
		end
	end)

	return {
		Get = function()
			return box.Text
		end,
		Set = function(_, text, silent)
			box.Text = text
			if opts.Callback and not silent then
				task.spawn(opts.Callback, text, false)
			end
		end,
	}
end

---------------------------------------------------------------------------
-- Tab
---------------------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Tab:AddSection(title)
	self._order += 1
	local card = create("Frame", {
		Name = title or "Section",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Surface,
		LayoutOrder = self._order,
		Parent = self.Page,
	}, { corner(8), stroke(), padding(12, 12, 12, 10, 10), list(4) })

	if title then
		label({
			Text = string.upper(title),
			Font = F.Bold,
			TextSize = T.Small,
			TextColor3 = C.Muted,
			Size = UDim2.new(1, 0, 0, 18),
			LayoutOrder = 0,
			Parent = card,
		})
	end

	return setmetatable({ Container = card, _window = self._window, _order = 0 }, Section)
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------

local Window = {}
Window.__index = Window

function Window:_connect(connection)
	table.insert(self._connections, connection)
	return connection
end

function Window:_onAccent(fn)
	table.insert(self._accentListeners, fn)
end

function Window:SetAccent(color)
	self.Accent = color
	for _, fn in self._accentListeners do
		fn(color)
	end
end

-- Final scale = user scale x a "fit" factor that shrinks the window on small screens.
function Window:_effectiveScale()
	return self._scale * self._fit
end

function Window:SetScale(scale)
	self._scale = scale
	self._uiScale.Scale = self:_effectiveScale()
end

function Window:SetToggleKey(keyCode)
	self.ToggleKey = keyCode
end

function Window:IsOpen()
	return self._open
end

function Window:SetOpen(state)
	if state == self._open then
		return
	end
	self._open = state
	local main, uiScale = self.Main, self._uiScale
	if state then
		main.Visible = true
		uiScale.Scale = self:_effectiveScale() * 0.94
		tween(uiScale, { Scale = self:_effectiveScale() })
	else
		local t = tween(uiScale, { Scale = self:_effectiveScale() * 0.94 }, TweenInfo.new(0.12, Enum.EasingStyle.Quint))
		t.Completed:Connect(function()
			if not self._open then
				main.Visible = false
				uiScale.Scale = self:_effectiveScale()
			end
		end)
	end
end

function Window:Toggle()
	self:SetOpen(not self._open)
end

function Window:SelectTab(tab)
	for _, other in self._tabs do
		local selected = other == tab
		other.Page.Visible = selected
		tween(other.Button, {
			BackgroundTransparency = if selected then 0 else 1,
			TextColor3 = if selected then C.Text else C.SubText,
		})
		tween(other.Indicator, { BackgroundTransparency = if selected then 0 else 1 })
	end
	self._selected = tab
end

function Window:AddTab(name)
	local order = #self._tabs + 1

	local button = create("TextButton", {
		Name = name,
		Text = name,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = C.Elevated,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Font = F.Medium,
		TextSize = T.Body,
		TextColor3 = C.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = order,
		Parent = self._tabList,
	}, { corner(6), padding(0, 14, 8, 0, 0) })
	local indicator = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -14, 0.5, 0),
		Size = UDim2.fromOffset(3, 16),
		BackgroundColor3 = self.Accent,
		BackgroundTransparency = 1,
		Parent = button,
	}, { corner(2) })

	local page = create("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.Track,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = self._content,
	}, { padding(14), list(10) })

	local tab = setmetatable({
		Name = name,
		Button = button,
		Indicator = indicator,
		Page = page,
		_window = self,
		_order = 0,
	}, Tab)
	table.insert(self._tabs, tab)

	button.MouseEnter:Connect(function()
		if self._selected ~= tab then
			tween(button, { TextColor3 = C.Text })
		end
	end)
	button.MouseLeave:Connect(function()
		if self._selected ~= tab then
			tween(button, { TextColor3 = C.SubText })
		end
	end)
	button.Activated:Connect(function()
		self:SelectTab(tab)
	end)
	self:_onAccent(function(accent)
		indicator.BackgroundColor3 = accent
	end)

	if order == 1 then
		self:SelectTab(tab)
	end
	return tab
end

-- opts: { Title, Text, Duration = 4, Type = "Info" | "Success" | "Warning" | "Error" }
function Window:Notify(opts)
	local color = ({
		Success = C.Success,
		Warning = C.Warning,
		Error = C.Error,
	})[opts.Type] or self.Accent

	self._toastCount += 1
	local slot = create("Frame", {
		LayoutOrder = self._toastCount,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self._toasts,
	})
	local toast = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.new(1, 20, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Surface,
		ClipsDescendants = true,
		Parent = slot,
	}, { corner(8), stroke() })
	create("Frame", {
		Name = "Bar",
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = toast,
	})
	local body = create("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = toast,
	}, { padding(12, 16, 12, 10, 10), list(2) })
	label({
		Text = opts.Title or "Notice",
		Font = F.Bold,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 1,
		Parent = body,
	})
	if opts.Text then
		label({
			Text = opts.Text,
			Font = F.Regular,
			TextColor3 = C.SubText,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			Parent = body,
		})
	end

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		local t = tween(toast, { Position = UDim2.new(1, 20, 0, 0) })
		t.Completed:Connect(function()
			slot:Destroy()
		end)
	end

	tween(toast, { Position = UDim2.new(0, 0, 0, 0) })
	toast.Activated:Connect(close)
	task.delay(opts.Duration or 4, close)
end

function Window:Destroy()
	for _, connection in self._connections do
		connection:Disconnect()
	end
	self._connections = {}
	self.Gui:Destroy()
end

---------------------------------------------------------------------------
-- Constructor
---------------------------------------------------------------------------

-- opts: { Title, Subtitle, ToggleKey = Enum.KeyCode.RightShift, Accent,
--         Scale = 1, ShowOpenButton = (touch device), Parent = PlayerGui }
function Library.new(opts)
	opts = opts or {}
	local player = Players.LocalPlayer

	local self = setmetatable({
		Accent = opts.Accent or Theme.Accents[1].Color,
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
		_scale = opts.Scale or 1,
		_fit = 1,
		_toastCount = 0,
		_open = true,
		_tabs = {},
		_connections = {},
		_accentListeners = {},
		_capturingKey = false,
	}, Window)

	local gui = create("ScreenGui", {
		Name = opts.Name or "JayHubUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 10,
		Parent = opts.Parent or player:WaitForChild("PlayerGui"),
	})
	self.Gui = gui

	local size = Theme.WindowSize
	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		BackgroundColor3 = C.Background,
		Parent = gui,
	}, { corner(Theme.Corner), stroke() })
	self.Main = main
	self._uiScale = create("UIScale", { Scale = self._scale, Parent = main })

	-- Shrink the window to fit small screens (phones).
	local function refit()
		local viewport = gui.AbsoluteSize
		if viewport.X <= 0 or viewport.Y <= 0 then
			return
		end
		self._fit = math.min(1, (viewport.X - 24) / size.X, (viewport.Y - 24) / size.Y)
		self._uiScale.Scale = self:_effectiveScale()
	end
	self:_connect(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(refit))
	task.defer(refit)

	-- Top bar -----------------------------------------------------------
	local topBar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, Theme.TopBarHeight),
		BackgroundTransparency = 1,
		Parent = main,
	})
	create("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.Stroke,
		BorderSizePixel = 0,
		Parent = topBar,
	})
	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = self.Accent,
		Parent = topBar,
	}, { corner(4) })
	self:_onAccent(function(accent)
		dot.BackgroundColor3 = accent
	end)

	local titleRow = create("Frame", {
		Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(1, -110, 1, 0),
		BackgroundTransparency = 1,
		Parent = topBar,
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	label({
		Text = opts.Title or "JayHub",
		Font = F.Bold,
		TextSize = T.Title,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 20),
		LayoutOrder = 1,
		Parent = titleRow,
	})
	if opts.Subtitle then
		label({
			Text = opts.Subtitle,
			Font = F.Regular,
			TextColor3 = C.Muted,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 20),
			LayoutOrder = 2,
			Parent = titleRow,
		})
	end

	local function topButton(text, offset)
		local b = create("TextButton", {
			Text = text,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, offset, 0.5, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = C.Hover,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Font = F.Medium,
			TextSize = 18,
			TextColor3 = C.SubText,
			Parent = topBar,
		}, { corner(6) })
		b.MouseEnter:Connect(function()
			tween(b, { BackgroundTransparency = 0, TextColor3 = C.Text })
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundTransparency = 1, TextColor3 = C.SubText })
		end)
		return b
	end
	-- "Close" only hides the window; the toggle key or open button brings it back.
	topButton("×", -10).Activated:Connect(function()
		self:SetOpen(false)
		self:Notify({
			Title = "Menu hidden",
			Text = "Press " .. keyName(self.ToggleKey) .. " to open it again.",
			Duration = 3,
		})
	end)
	topButton("–", -42).Activated:Connect(function()
		self:SetOpen(false)
	end)

	-- Dragging ------------------------------------------------------------
	local dragStart, startPos
	topBar.InputBegan:Connect(function(input)
		if isClick(input) then
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	self:_connect(UserInputService.InputChanged:Connect(function(input)
		if
			dragStart
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end))
	self:_connect(UserInputService.InputEnded:Connect(function(input)
		if isClick(input) then
			dragStart = nil
		end
	end))

	-- Sidebar & content ---------------------------------------------------
	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.new(0, 0, 0, Theme.TopBarHeight),
		Size = UDim2.new(0, Theme.SidebarWidth, 1, -Theme.TopBarHeight),
		BackgroundColor3 = C.Sidebar,
		BorderSizePixel = 0,
		Parent = main,
	}, { corner(Theme.Corner) })
	-- Squares off the sidebar's top-right/bottom-right corners.
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, Theme.Corner, 1, 0),
		BackgroundColor3 = C.Sidebar,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	create("Frame", {
		Size = UDim2.new(1, 0, 0, Theme.Corner),
		BackgroundColor3 = C.Sidebar,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	create("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = C.Stroke,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	self._tabList = create("Frame", {
		Name = "Tabs",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = sidebar,
	}, { padding(8, 8, 9, 10, 10), list(4) })

	self._content = create("Frame", {
		Name = "Content",
		Position = UDim2.new(0, Theme.SidebarWidth, 0, Theme.TopBarHeight),
		Size = UDim2.new(1, -Theme.SidebarWidth, 1, -Theme.TopBarHeight),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = main,
	})

	-- Notifications -------------------------------------------------------
	self._toasts = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 270, 1, -32),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 8),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- Open button (touch devices have no toggle key) ----------------------
	local showOpenButton = opts.ShowOpenButton
	if showOpenButton == nil then
		showOpenButton = UserInputService.TouchEnabled
	end
	if showOpenButton then
		local openButton = create("TextButton", {
			Name = "OpenButton",
			Text = "☰",
			Position = UDim2.fromOffset(16, 60),
			Size = UDim2.fromOffset(40, 40),
			BackgroundColor3 = C.Surface,
			AutoButtonColor = false,
			Font = F.Bold,
			TextSize = 18,
			TextColor3 = C.Text,
			Parent = gui,
		}, { corner(10), stroke() })
		openButton.Activated:Connect(function()
			self:Toggle()
		end)
	end

	-- Toggle key ----------------------------------------------------------
	self:_connect(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or self._capturingKey then
			return
		end
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end))

	return self
end

Library.Theme = Theme

return Library
