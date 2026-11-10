--!nonstrict
-- Reusable JayHub controls. Every control can either be bound to a setting
-- (`Key = "FieldOfView"`) — it then reads, writes and follows the Store — or
-- driven by a plain `Callback`.
--
-- All callbacks are run through `safeCall`, so an error in one control's
-- handler is reported instead of breaking the interface.

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JayHubShared = ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))

local Core = script.Parent.Parent.Core
local Store = require(Core.Store)
local Theme = require(Core.Theme)
local Notify = require(Core.Notify)
local Keybinds = require(Core.Keybinds)
local Tween = require(script.Parent.Tween)
local Create = require(script.Parent.Create)

local T = Theme.T

local Components = {}

local ROW_HEIGHT = 40
local CONTROL_HEIGHT = 30

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function safeCall(fn: ((...any) -> ...any)?, ...: any)
	if not fn then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[JayHub] control callback failed:", err)
		Notify.error("Something went wrong: " .. tostring(err), "JayHub")
	end
end
Components.safeCall = safeCall

local function isPress(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

-- Disables scrolling on the parent page while dragging so touch drags work.
local function lockScroll(gui: Instance, locked: boolean)
	local scroller = gui:FindFirstAncestorWhichIsA("ScrollingFrame")
	if scroller then
		scroller.ScrollingEnabled = not locked
	end
end

-- Hover / press feedback for any button-like GuiObject.
local function hoverable(button: GuiButton, target: GuiObject?, idle: string, hover: string)
	local surface = target or button
	button.MouseEnter:Connect(function()
		Theme.bind(surface, "BackgroundColor3", hover, true)
	end)
	button.MouseLeave:Connect(function()
		Theme.bind(surface, "BackgroundColor3", idle, true)
	end)
end
Components.hoverable = hoverable

local function formatNumber(value: number, step: number?): string
	if step and step >= 1 then
		return tostring(math.floor(value + 0.5))
	elseif step and step >= 0.1 then
		return string.format("%.1f", value)
	end
	return string.format("%.2f", value)
end
Components.formatNumber = formatNumber

-- Left-hand label (+ optional description) used by most rows.
local function rowLabel(parent: Instance, text: string, desc: string?, rightWidth: number)
	local holder = Create("Frame", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -(rightWidth + 12), 1, 0),
		Parent = parent,
	})
	Create.text({
		Name = "Title",
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 0.5, if desc then -16 else -8),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = holder,
	})
	if desc then
		Create.text({
			Name = "Desc",
			Text = desc,
			TextSize = 11,
			TextColor3 = T.SubText,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.new(0, 0, 0.5, 1),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = holder,
		})
	end
	return holder
end

local function row(parent: Instance, height: number?): Frame
	return Create("Frame", {
		Name = "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or ROW_HEIGHT),
		Parent = parent,
	})
end

---------------------------------------------------------------------------
-- Layout
---------------------------------------------------------------------------

-- Page header (big title + subtitle).
function Components.Header(parent: Instance, title: string, subtitle: string?)
	local frame = Create("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, if subtitle then 48 else 28),
		LayoutOrder = -100,
		Parent = parent,
	})
	local titleLabel = Create.text({
		Text = title,
		Font = Enum.Font.GothamBlack,
		TextSize = 22,
		Size = UDim2.new(1, 0, 0, 26),
		Parent = frame,
	})
	Create("UIGradient", {
		Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 196, 220)),
		Rotation = 90,
		Parent = titleLabel,
	})
	if subtitle then
		Create.text({
			Text = subtitle,
			TextSize = 12,
			TextColor3 = T.SubText,
			Position = UDim2.fromOffset(0, 28),
			Size = UDim2.new(1, 0, 0, 16),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = frame,
		})
	end
	return frame
end

-- Card that groups related controls. Returns the inner container.
function Components.Section(parent: Instance, title: string, desc: string?): Frame
	local card = Create("Frame", {
		Name = "Section_" .. title,
		BackgroundColor3 = T.Surface2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	}, {
		Create.corner(10),
		Create.stroke("Stroke", 1, 0.35),
		Create.padding(14, 16, 14, 16),
		Create.list(6),
	})
	local head = Create("Frame", {
		Name = "SectionHead",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, if desc then 36 else 20),
		LayoutOrder = -100,
		Parent = card,
	})
	local dot = Create("Frame", {
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.fromOffset(0, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = head,
	}, { Create.round() })
	Create.accentGradient(0).Parent = dot
	Create.text({
		Text = string.upper(title),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -14, 0, 18),
		Parent = head,
	})
	if desc then
		Create.text({
			Text = desc,
			TextSize = 11,
			TextColor3 = T.SubText,
			Position = UDim2.fromOffset(14, 19),
			Size = UDim2.new(1, -14, 0, 14),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = head,
		})
	end
	return card
end

-- Wrapped paragraph text.
function Components.Paragraph(parent: Instance, text: string, token: string?): TextLabel
	return Create.text({
		Name = "Paragraph",
		Text = text,
		TextSize = 12,
		TextColor3 = T[token or "SubText"],
		TextWrapped = true,
		RichText = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,
	})
end

-- Read-only "label: value" row whose value can be updated.
function Components.InfoRow(parent: Instance, label: string, value: string)
	local frame = row(parent, 26)
	rowLabel(frame, label, nil, 180)
	local valueLabel = Create.text({
		Text = value,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 180, 1, 0),
		Parent = frame,
	})
	return {
		Frame = frame,
		Set = function(_, text: string)
			valueLabel.Text = text
		end,
		Label = valueLabel,
	}
end

-- Horizontal grid of equal cells; returns the grid frame.
function Components.Grid(parent: Instance, columns: number, cellHeight: number, padding: number?): Frame
	local pad = padding or 8
	return Create("Frame", {
		Name = "Grid",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	}, {
		Create("UIGridLayout", {
			CellPadding = UDim2.fromOffset(pad, pad),
			CellSize = UDim2.new(1 / columns, -pad * (columns - 1) / columns, 0, cellHeight),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
end

---------------------------------------------------------------------------
-- Button
---------------------------------------------------------------------------

export type ButtonStyle = "Primary" | "Secondary" | "Danger" | "Ghost"

function Components.Button(
	parent: Instance,
	options: { Text: string, Style: ButtonStyle?, Callback: (() -> ())?, Size: UDim2?, LayoutOrder: number? }
)
	local style = options.Style or "Secondary"
	local idle = if style == "Danger" then "Surface2" elseif style == "Ghost" then "Surface2" else "Elevated"
	local button = Create("TextButton", {
		Name = "Button",
		Text = options.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = if style == "Danger" then T.Danger else T.Text,
		AutoButtonColor = false,
		BackgroundColor3 = T[idle],
		Size = options.Size or UDim2.new(1, 0, 0, 34),
		LayoutOrder = options.LayoutOrder,
		Parent = parent,
	}, {
		Create.corner(8),
	})
	local stroke = Create.stroke(if style == "Danger" then "Danger" else "Stroke", 1, if style == "Danger" then 0.5 else 0.1)
	stroke.Parent = button

	if style == "Primary" then
		button.BackgroundColor3 = Color3.new(1, 1, 1)
		Theme.unbind(button, "BackgroundColor3")
		local gradient = Create.accentGradient(0)
		gradient.Parent = button
		stroke.Transparency = 1
		button.MouseEnter:Connect(function()
			Tween.play(gradient, { Offset = Vector2.new(0.15, 0) }, 0.25)
		end)
		button.MouseLeave:Connect(function()
			Tween.play(gradient, { Offset = Vector2.new(0, 0) }, 0.25)
		end)
	else
		hoverable(button, nil, idle, "Hover")
	end

	local scale = Create("UIScale", { Parent = button })
	button.MouseButton1Down:Connect(function()
		Tween.play(scale, { Scale = 0.96 }, 0.08)
	end)
	button.MouseButton1Up:Connect(function()
		Tween.play(scale, { Scale = 1 }, 0.15, Enum.EasingStyle.Back)
	end)
	button.MouseLeave:Connect(function()
		Tween.play(scale, { Scale = 1 }, 0.15)
	end)

	local busy = false
	button.Activated:Connect(function()
		if busy then
			return
		end
		busy = true
		-- Run in a thread so handlers may yield (server requests).
		task.spawn(function()
			safeCall(options.Callback)
			busy = false
		end)
	end)

	return {
		Instance = button,
		SetText = function(_, text: string)
			button.Text = text
		end,
	}
end

-- Row of buttons sharing the width equally.
function Components.ButtonRow(parent: Instance, buttons: { { Text: string, Style: ButtonStyle?, Callback: (() -> ())? } })
	local frame = Create("Frame", {
		Name = "ButtonRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = parent,
	}, {
		Create.list(8, Enum.FillDirection.Horizontal),
	})
	local count = #buttons
	local out = {}
	for index, spec in buttons do
		out[index] = Components.Button(frame, {
			Text = spec.Text,
			Style = spec.Style,
			Callback = spec.Callback,
			LayoutOrder = index,
			Size = UDim2.new(1 / count, -8 * (count - 1) / count, 1, 0),
		})
	end
	return out, frame
end

---------------------------------------------------------------------------
-- Toggle
---------------------------------------------------------------------------

function Components.Toggle(
	parent: Instance,
	options: { Label: string, Desc: string?, Key: string?, Default: boolean?, Callback: ((boolean) -> ())? }
)
	local frame = row(parent, if options.Desc then 44 else ROW_HEIGHT)
	rowLabel(frame, options.Label, options.Desc, 46)

	local switch = Create("Frame", {
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = T.Elevated,
		Parent = frame,
	}, { Create.round(), Create.stroke("Stroke", 1, 0) })
	local fill = Create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Parent = switch,
	}, { Create.round(), Create.accentGradient(0) })
	local knob = Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = T.SubText,
		ZIndex = 2,
		Parent = switch,
	}, { Create.round() })

	local hit = Create("TextButton", {
		Name = "Hit",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = frame,
	})

	local value = false
	local function render(animate: boolean)
		local duration = if animate then 0.22 else 0
		Tween.play(knob, { Position = if value then UDim2.new(1, -19, 0.5, 0) else UDim2.new(0, 3, 0.5, 0) }, duration, Enum.EasingStyle.Back)
		Tween.play(fill, { BackgroundTransparency = if value then 0 else 1 }, duration)
		Theme.bind(knob, "BackgroundColor3", if value then "Text" else "SubText")
	end

	local function set(newValue: boolean, fromUser: boolean)
		if newValue == value and not fromUser then
			return
		end
		value = newValue
		render(true)
		if fromUser then
			if options.Key then
				local ok, err = Store.set(options.Key, value)
				if not ok then
					Notify.error(tostring(err))
				end
			end
			safeCall(options.Callback, value)
		end
	end

	if options.Key then
		value = Store.get(options.Key) == true
		Store.Changed:Connect(function(key, newValue)
			if key == options.Key then
				set(newValue == true, false)
			end
		end)
	else
		value = options.Default == true
	end
	render(false)

	hit.Activated:Connect(function()
		set(not value, true)
	end)

	return {
		Frame = frame,
		Get = function()
			return value
		end,
		Set = function(_, newValue: boolean)
			set(newValue, false)
		end,
	}
end

---------------------------------------------------------------------------
-- Slider
---------------------------------------------------------------------------

function Components.Slider(
	parent: Instance,
	options: {
		Label: string,
		Desc: string?,
		Key: string?,
		Min: number?,
		Max: number?,
		Step: number?,
		Default: number?,
		Suffix: string?,
		Callback: ((number) -> ())?,
	}
)
	local def = options.Key and Schema.Settings[options.Key]
	local min = options.Min or (def and def.Min) or 0
	local max = options.Max or (def and def.Max) or 1
	local step = options.Step or (def and def.Step) or 0.01
	local suffix = options.Suffix or ""

	local frame = row(parent, 52)
	local top = Create("Frame", {
		Name = "Top",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = frame,
	})
	rowLabel(top, options.Label, nil, 70)

	local valueBox = Create("TextBox", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(64, 22),
		BackgroundColor3 = T.Elevated,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = T.Text,
		ClearTextOnFocus = false,
		Text = "",
		Parent = top,
	}, { Create.corner(6), Create.stroke("Stroke", 1, 0.2) })

	local track = Create("Frame", {
		Name = "Track",
		Position = UDim2.new(0, 0, 0, 38),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = T.Elevated,
		Parent = frame,
	}, { Create.round() })
	local fill = Create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = track,
	}, { Create.round(), Create.accentGradient(0) })
	local knob = Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = T.Text,
		ZIndex = 2,
		Parent = track,
	}, { Create.round(), Create.stroke("Accent", 2, 0) })
	local knobScale = Create("UIScale", { Parent = knob })

	local hit = Create("TextButton", {
		Name = "Hit",
		Text = "",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -6, 0.5, 0),
		Size = UDim2.new(1, 12, 0, 24),
		ZIndex = 3,
		Parent = track,
	})

	local value = min
	local function snap(raw: number): number
		local clamped = math.clamp(raw, min, max)
		local snapped = min + math.floor((clamped - min) / step + 0.5) * step
		return math.floor(math.clamp(snapped, min, max) * 1000 + 0.5) / 1000
	end

	local function render(animate: boolean)
		local alpha = if max > min then (value - min) / (max - min) else 0
		local duration = if animate then 0.08 else 0
		Tween.play(fill, { Size = UDim2.fromScale(alpha, 1) }, duration, Enum.EasingStyle.Linear)
		Tween.play(knob, { Position = UDim2.fromScale(alpha, 0.5) }, duration, Enum.EasingStyle.Linear)
		valueBox.Text = formatNumber(value, step) .. suffix
	end

	local function commit(newValue: number)
		value = snap(newValue)
		render(true)
		if options.Key then
			local ok, err = Store.set(options.Key, value)
			if not ok then
				Notify.error(tostring(err))
			end
		end
		safeCall(options.Callback, value)
	end

	local function valueFromX(x: number): number
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return value
		end
		local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
		return min + (max - min) * alpha
	end

	local dragging = false
	local moveConn: RBXScriptConnection? = nil
	local endConn: RBXScriptConnection? = nil

	local function stopDrag()
		dragging = false
		lockScroll(frame, false)
		Tween.play(knobScale, { Scale = 1 }, 0.15)
		if moveConn then
			moveConn:Disconnect()
			moveConn = nil
		end
		if endConn then
			endConn:Disconnect()
			endConn = nil
		end
	end

	hit.InputBegan:Connect(function(input)
		if not isPress(input) then
			return
		end
		dragging = true
		lockScroll(frame, true)
		Tween.play(knobScale, { Scale = 1.25 }, 0.15, Enum.EasingStyle.Back)
		local last = value
		local function update(x: number)
			local nextValue = snap(valueFromX(x))
			if nextValue ~= last then
				last = nextValue
				commit(nextValue)
			end
		end
		update(input.Position.X)
		moveConn = UserInputService.InputChanged:Connect(function(changed)
			if dragging and isMove(changed) then
				update(changed.Position.X)
			end
		end)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if isPress(ended) then
				stopDrag()
			end
		end)
	end)

	valueBox.FocusLost:Connect(function()
		local number = tonumber((string.gsub(valueBox.Text, "[^%d%.%-]", "")))
		if number then
			commit(number)
		else
			render(false)
		end
	end)

	if options.Key then
		value = snap(Store.get(options.Key))
		Store.Changed:Connect(function(key, newValue)
			if key == options.Key and newValue ~= value and type(newValue) == "number" then
				value = snap(newValue)
				render(true)
			end
		end)
	else
		value = snap(options.Default or min)
	end
	render(false)

	return {
		Frame = frame,
		Get = function()
			return value
		end,
		Set = function(_, newValue: number)
			value = snap(newValue)
			render(true)
		end,
	}
end

---------------------------------------------------------------------------
-- Dropdown
---------------------------------------------------------------------------

function Components.Dropdown(
	parent: Instance,
	options: {
		Label: string,
		Desc: string?,
		Key: string?,
		Options: { string }?,
		Default: string?,
		Callback: ((string) -> ())?,
	}
)
	local def = options.Key and Schema.Settings[options.Key]
	local choices = options.Options or (def and def.Options) or {}
	local rowHeight = if options.Desc then 44 else ROW_HEIGHT
	local optionHeight = 28

	local container = Create("Frame", {
		Name = "Dropdown",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, rowHeight),
		Parent = parent,
	})
	local head = row(container, rowHeight)
	rowLabel(head, options.Label, options.Desc, 160)

	local button = Create("TextButton", {
		Name = "Current",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(160, CONTROL_HEIGHT),
		BackgroundColor3 = T.Elevated,
		Text = "",
		AutoButtonColor = false,
		Parent = head,
	}, { Create.corner(7), Create.stroke("Stroke", 1, 0.1) })
	local current = Create.text({
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -34, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = button,
	})
	local arrow = Create.text({
		Text = "▼",
		TextSize = 9,
		TextColor3 = T.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Parent = button,
	})
	hoverable(button, nil, "Elevated", "Hover")

	local list = Create("Frame", {
		Name = "Options",
		Position = UDim2.new(0, 0, 0, rowHeight + 4),
		Size = UDim2.new(1, 0, 0, #choices * (optionHeight + 4) + 4),
		BackgroundColor3 = T.Surface,
		Parent = container,
	}, {
		Create.corner(8),
		Create.stroke("Stroke", 1, 0.2),
		Create.padding(4),
		Create.list(4),
	})

	local value = choices[1] or ""
	local open = false
	local optionButtons: { [string]: TextButton } = {}

	local function renderSelection()
		current.Text = value
		for name, optionButton in optionButtons do
			local selected = name == value
			Theme.bind(optionButton, "BackgroundColor3", if selected then "AccentDim" else "Surface")
			Theme.bind(optionButton, "TextColor3", if selected then "Text" else "SubText")
		end
	end

	local function setOpen(state: boolean)
		open = state
		local extra = if open then #choices * (optionHeight + 4) + 12 else 0
		Tween.play(container, { Size = UDim2.new(1, 0, 0, rowHeight + extra) }, 0.25)
		Tween.play(arrow, { Rotation = if open then 180 else 0 }, 0.25)
	end

	local function choose(choice: string, fromUser: boolean)
		value = choice
		renderSelection()
		if fromUser then
			setOpen(false)
			if options.Key then
				local ok, err = Store.set(options.Key, choice)
				if not ok then
					Notify.error(tostring(err))
				end
			end
			safeCall(options.Callback, choice)
		end
	end

	for index, choice in choices do
		local optionButton = Create("TextButton", {
			Name = choice,
			LayoutOrder = index,
			Text = "   " .. choice,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			BackgroundColor3 = T.Surface,
			TextColor3 = T.SubText,
			Size = UDim2.new(1, 0, 0, optionHeight),
			Parent = list,
		}, { Create.corner(6) })
		optionButtons[choice] = optionButton
		optionButton.MouseEnter:Connect(function()
			if choice ~= value then
				Theme.bind(optionButton, "BackgroundColor3", "Elevated")
			end
		end)
		optionButton.MouseLeave:Connect(function()
			if choice ~= value then
				Theme.bind(optionButton, "BackgroundColor3", "Surface")
			end
		end)
		optionButton.Activated:Connect(function()
			choose(choice, true)
		end)
	end

	button.Activated:Connect(function()
		setOpen(not open)
	end)

	if options.Key then
		local stored = Store.get(options.Key)
		if type(stored) == "string" then
			value = stored
		end
		Store.Changed:Connect(function(key, newValue)
			if key == options.Key and type(newValue) == "string" then
				choose(newValue, false)
			end
		end)
	elseif options.Default then
		value = options.Default
	end
	renderSelection()

	return {
		Frame = container,
		Get = function()
			return value
		end,
		Set = function(_, choice: string)
			choose(choice, false)
		end,
	}
end

---------------------------------------------------------------------------
-- Text input
---------------------------------------------------------------------------

function Components.TextInput(
	parent: Instance,
	options: {
		Label: string,
		Desc: string?,
		Key: string?,
		Placeholder: string?,
		Default: string?,
		Width: number?,
		Callback: ((string) -> ())?,
	}
)
	local width = options.Width or 180
	local frame = row(parent, if options.Desc then 44 else ROW_HEIGHT)
	rowLabel(frame, options.Label, options.Desc, width)

	local box = Create("TextBox", {
		Name = "Input",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(width, CONTROL_HEIGHT),
		BackgroundColor3 = T.Elevated,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = T.Text,
		PlaceholderText = options.Placeholder or "",
		PlaceholderColor3 = T.Muted,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
		Parent = frame,
	}, { Create.corner(7), Create.padding(0, 10, 0, 10) })
	local stroke = Create.stroke("Stroke", 1, 0.1)
	stroke.Parent = box

	box.Focused:Connect(function()
		Theme.bind(stroke, "Color", "Accent")
	end)
	box.FocusLost:Connect(function()
		Theme.bind(stroke, "Color", "Stroke")
		if options.Key then
			local ok, result = Store.set(options.Key, box.Text)
			if ok then
				box.Text = result
			else
				Notify.error(tostring(result))
				box.Text = Store.get(options.Key)
				return
			end
		end
		safeCall(options.Callback, box.Text)
	end)

	if options.Key then
		box.Text = tostring(Store.get(options.Key))
		Store.Changed:Connect(function(key, newValue)
			if key == options.Key and not box:IsFocused() then
				box.Text = tostring(newValue)
			end
		end)
	else
		box.Text = options.Default or ""
	end

	return {
		Frame = frame,
		Box = box,
		Get = function()
			return box.Text
		end,
		Set = function(_, text: string)
			box.Text = text
		end,
	}
end

-- Multi-line text area (used for import / export codes).
function Components.TextArea(parent: Instance, options: { Placeholder: string?, Height: number?, ReadOnly: boolean? })
	local box = Create("TextBox", {
		Name = "TextArea",
		Size = UDim2.new(1, 0, 0, options.Height or 64),
		BackgroundColor3 = T.Surface,
		Font = Enum.Font.Code,
		TextSize = 12,
		TextColor3 = T.Text,
		PlaceholderText = options.Placeholder or "",
		PlaceholderColor3 = T.Muted,
		ClearTextOnFocus = false,
		MultiLine = true,
		TextWrapped = true,
		TextEditable = not options.ReadOnly,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		Parent = parent,
	}, { Create.corner(8), Create.stroke("Stroke", 1, 0.1), Create.padding(8) })
	return box
end

---------------------------------------------------------------------------
-- Keybind
---------------------------------------------------------------------------

function Components.Keybind(parent: Instance, options: { Label: string, Desc: string?, Action: string })
	local frame = row(parent, if options.Desc then 44 else ROW_HEIGHT)
	rowLabel(frame, options.Label, options.Desc, 110)

	local button = Create("TextButton", {
		Name = "Key",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(110, CONTROL_HEIGHT),
		BackgroundColor3 = T.Elevated,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = T.Text,
		AutoButtonColor = false,
		Text = "",
		Parent = frame,
	}, { Create.corner(7) })
	local stroke = Create.stroke("Stroke", 1, 0.1)
	stroke.Parent = button
	hoverable(button, nil, "Elevated", "Hover")

	local function render()
		button.Text = Keybinds.display(Keybinds.keyName(options.Action))
	end

	local listening = false
	button.Activated:Connect(function()
		if listening then
			Keybinds.cancelCapture()
			return
		end
		listening = true
		button.Text = "Press a key…"
		Theme.bind(stroke, "Color", "Accent")
		Keybinds.capture(options.Action, function(ok, message)
			listening = false
			Theme.bind(stroke, "Color", "Stroke")
			render()
			if message ~= "Cancelled" then
				Notify.result(ok, message, options.Label)
			end
		end)
	end)

	Store.Changed:Connect(function(key)
		if key == "Key_" .. options.Action and not listening then
			render()
		end
	end)
	render()

	return { Frame = frame }
end

---------------------------------------------------------------------------
-- Colour picker
---------------------------------------------------------------------------

Components.Swatches = {
	"#2F8CFF",
	"#8B5CFF",
	"#38BDF8",
	"#EC4899",
	"#F43F5E",
	"#F97316",
	"#FBBF24",
	"#34D399",
	"#10B981",
	"#F5F5F5",
	"#6B7280",
	"#111827",
}

function Components.ColorPicker(
	parent: Instance,
	options: { Label: string, Desc: string?, Key: string?, Default: string?, Callback: ((string) -> ())? }
)
	local rowHeight = if options.Desc then 44 else ROW_HEIGHT
	local panelHeight = 170

	local container = Create("Frame", {
		Name = "ColorPicker",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, rowHeight),
		Parent = parent,
	})
	local head = row(container, rowHeight)
	rowLabel(head, options.Label, options.Desc, 150)

	local right = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(150, CONTROL_HEIGHT),
		BackgroundTransparency = 1,
		Parent = head,
	})
	local preview = Create("TextButton", {
		Name = "Preview",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(CONTROL_HEIGHT, CONTROL_HEIGHT),
		Parent = right,
	}, { Create.corner(7), Create.stroke("Stroke", 1, 0) })
	local hexBox = Create("TextBox", {
		Name = "Hex",
		Position = UDim2.fromOffset(CONTROL_HEIGHT + 6, 0),
		Size = UDim2.new(1, -(CONTROL_HEIGHT + 6), 1, 0),
		BackgroundColor3 = T.Elevated,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = T.Text,
		ClearTextOnFocus = false,
		Text = "",
		Parent = right,
	}, { Create.corner(7), Create.stroke("Stroke", 1, 0.1) })

	local panel = Create("Frame", {
		Name = "Panel",
		Position = UDim2.new(0, 0, 0, rowHeight + 4),
		Size = UDim2.new(1, 0, 0, panelHeight - 8),
		BackgroundColor3 = T.Surface,
		Parent = container,
	}, { Create.corner(8), Create.stroke("Stroke", 1, 0.2), Create.padding(10), Create.list(4) })

	local swatchRow = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Parent = panel,
	}, {
		Create("UIGridLayout", {
			CellSize = UDim2.new(1 / #Components.Swatches, -4, 1, 0),
			CellPadding = UDim2.fromOffset(4, 0),
		}),
	})

	local hue, sat, val = 0, 0, 1
	local hex = "#FFFFFF"
	local open = false
	local hsvSliders: { [string]: any } = {}
	local suppress = false

	local function render()
		local color = Schema.toColor(hex)
		preview.BackgroundColor3 = color
		hexBox.Text = hex
	end

	local function apply(newHex: string, fromUser: boolean, updateSliders: boolean)
		hex = newHex
		if updateSliders then
			hue, sat, val = Schema.toColor(hex):ToHSV()
			suppress = true
			if hsvSliders.H then
				hsvSliders.H:Set(math.floor(hue * 360 + 0.5))
				hsvSliders.S:Set(math.floor(sat * 100 + 0.5))
				hsvSliders.V:Set(math.floor(val * 100 + 0.5))
			end
			suppress = false
		end
		render()
		if fromUser then
			if options.Key then
				local ok, err = Store.set(options.Key, hex)
				if not ok then
					Notify.error(tostring(err))
				end
			end
			safeCall(options.Callback, hex)
		end
	end

	for _, swatchHex in Components.Swatches do
		local swatch = Create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Schema.toColor(swatchHex),
			Parent = swatchRow,
		}, { Create.corner(5), Create.stroke("Stroke", 1, 0.3) })
		swatch.Activated:Connect(function()
			apply(swatchHex, true, true)
		end)
	end

	local function fromHSV()
		if suppress then
			return
		end
		apply(Schema.toHex(Color3.fromHSV(hue, sat, val)), true, false)
	end
	hsvSliders.H = Components.Slider(panel, {
		Label = "Hue",
		Min = 0,
		Max = 360,
		Step = 1,
		Callback = function(v)
			hue = math.clamp(v / 360, 0, 0.999)
			fromHSV()
		end,
	})
	hsvSliders.S = Components.Slider(panel, {
		Label = "Saturation",
		Min = 0,
		Max = 100,
		Step = 1,
		Suffix = "%",
		Callback = function(v)
			sat = v / 100
			fromHSV()
		end,
	})
	hsvSliders.V = Components.Slider(panel, {
		Label = "Brightness",
		Min = 0,
		Max = 100,
		Step = 1,
		Suffix = "%",
		Callback = function(v)
			val = v / 100
			fromHSV()
		end,
	})
	-- Compact the sliders inside the panel.
	for _, slider in hsvSliders do
		slider.Frame.Size = UDim2.new(1, 0, 0, 40)
		local track = slider.Frame:FindFirstChild("Track")
		if track then
			track.Position = UDim2.fromOffset(0, 30)
		end
		local topRow = slider.Frame:FindFirstChild("Top")
		if topRow then
			topRow.Size = UDim2.new(1, 0, 0, 24)
		end
	end
	local contentHeight = 20 + 22 + 3 * 40 + 3 * 4
	panelHeight = contentHeight + 8
	panel.Size = UDim2.new(1, 0, 0, contentHeight)

	preview.Activated:Connect(function()
		open = not open
		Tween.play(container, { Size = UDim2.new(1, 0, 0, rowHeight + (if open then panelHeight else 0)) }, 0.25)
	end)

	hexBox.FocusLost:Connect(function()
		local normalized = Schema.normalizeHex(hexBox.Text)
		if normalized then
			apply(normalized, true, true)
		else
			Notify.error("Use a hex colour like #2F8CFF", options.Label)
			render()
		end
	end)

	if options.Key then
		apply(Store.get(options.Key), false, true)
		Store.Changed:Connect(function(key, newValue)
			if key == options.Key and newValue ~= hex then
				apply(newValue, false, true)
			end
		end)
	else
		apply(options.Default or "#FFFFFF", false, true)
	end

	return {
		Frame = container,
		Get = function()
			return hex
		end,
		Set = function(_, newHex: string)
			local normalized = Schema.normalizeHex(newHex)
			if normalized then
				apply(normalized, false, true)
			end
		end,
	}
end

---------------------------------------------------------------------------
-- Stat tile
---------------------------------------------------------------------------

function Components.StatTile(parent: Instance, options: { Title: string, Value: string?, Sub: string?, LayoutOrder: number? })
	local tile = Create("Frame", {
		Name = "Stat_" .. options.Title,
		BackgroundColor3 = T.Elevated,
		LayoutOrder = options.LayoutOrder,
		Parent = parent,
	}, { Create.corner(10), Create.stroke("Stroke", 1, 0.3), Create.padding(10, 12, 10, 12) })
	Create.text({
		Text = string.upper(options.Title),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = T.SubText,
		Size = UDim2.new(1, 0, 0, 12),
		Parent = tile,
	})
	local valueLabel = Create.text({
		Name = "Value",
		Text = options.Value or "0",
		Font = Enum.Font.GothamBlack,
		TextSize = 22,
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(1, 0, 0, 26),
		TextColor3 = Color3.new(1, 1, 1),
		Parent = tile,
	})
	Create.accentGradient(0).Parent = valueLabel
	local subLabel = Create.text({
		Name = "Sub",
		Text = options.Sub or "",
		TextSize = 10,
		TextColor3 = T.Muted,
		Position = UDim2.fromOffset(0, 43),
		Size = UDim2.new(1, 0, 0, 12),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = tile,
	})
	return {
		Frame = tile,
		Set = function(_, value: string, sub: string?)
			valueLabel.Text = value
			if sub then
				subLabel.Text = sub
			end
		end,
	}
end

-- Horizontal progress bar with label and percentage.
function Components.Bar(parent: Instance, options: { Label: string, Token: string? })
	local frame = row(parent, 30)
	local label = Create.text({
		Text = options.Label,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		Size = UDim2.new(0, 70, 0, 14),
		Parent = frame,
	})
	local valueLabel = Create.text({
		Text = "0",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 90, 0, 14),
		Parent = frame,
	})
	local track = Create("Frame", {
		Position = UDim2.fromOffset(0, 19),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = T.Elevated,
		Parent = frame,
	}, { Create.round() })
	local fill = Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = T[options.Token or "Accent"],
		Parent = track,
	}, { Create.round() })
	return {
		Frame = frame,
		Label = label,
		Set = function(_, alpha: number, text: string)
			Tween.play(fill, { Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1) }, 0.35)
			valueLabel.Text = text
		end,
	}
end

return Components
