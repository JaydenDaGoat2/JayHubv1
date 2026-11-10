--!nonstrict
-- Toast notifications (bottom right). Respect the "Notifications" setting;
-- errors are always shown.

local Store = require(script.Parent.Store)
local Theme = require(script.Parent.Theme)
local Tween = require(script.Parent.Parent.UI.Tween)
local Create = require(script.Parent.Parent.UI.Create)

local Notify = {}

export type Kind = "Info" | "Success" | "Warning" | "Error"

local KIND_TOKEN = {
	Info = "Accent",
	Success = "Success",
	Warning = "Warning",
	Error = "Danger",
}

local MAX_VISIBLE = 4
local container: Frame? = nil
local active: { Frame } = {}
local order = 0

function Notify.init(screenGui: ScreenGui)
	container = Create("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(300, 400),
		BackgroundTransparency = 1,
		Parent = screenGui,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
end

local function dismiss(toast: Frame)
	local index = table.find(active, toast)
	if not index then
		return
	end
	table.remove(active, index)
	local body = toast:FindFirstChild("Body") :: Frame?
	if body then
		Tween.play(body, { Position = UDim2.fromOffset(320, 0) }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	end
	Tween.playThen(toast, { Size = UDim2.new(1, 0, 0, 0) }, 0.25, function()
		toast:Destroy()
	end)
end

function Notify.push(options: { Title: string?, Text: string, Kind: Kind?, Duration: number? })
	local kind: Kind = options.Kind or "Info"
	if kind ~= "Error" and Store.get("Notifications") == false then
		return
	end
	if not container then
		print("[JayHub]", options.Title or kind, options.Text)
		return
	end

	order += 1
	local token = KIND_TOKEN[kind] or "Accent"
	local height = 62

	local toast = Create("Frame", {
		Name = "Toast",
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = container,
	})
	local body = Create("TextButton", {
		Name = "Body",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, height),
		Position = UDim2.fromOffset(320, 0),
		BackgroundColor3 = Theme.T.Surface2,
		Parent = toast,
	}, {
		Create.corner(10),
		Create.stroke("Stroke", 1, 0.2),
		Create("Frame", {
			Name = "Bar",
			Size = UDim2.new(0, 3, 1, -16),
			Position = UDim2.fromOffset(8, 8),
			BackgroundColor3 = Theme.T[token],
			BorderSizePixel = 0,
		}, { Create.round() }),
		Create.text({
			Name = "Title",
			Text = options.Title or kind,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			Position = UDim2.fromOffset(20, 9),
			Size = UDim2.new(1, -30, 0, 16),
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
		Create.text({
			Name = "Message",
			Text = options.Text,
			TextSize = 12,
			TextColor3 = Theme.T.SubText,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(20, 27),
			Size = UDim2.new(1, -30, 0, 30),
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
	})
	local timer = Create("Frame", {
		Name = "Timer",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -2),
		Size = UDim2.new(1, -20, 0, 2),
		BackgroundColor3 = Theme.T[token],
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = body,
	})

	table.insert(active, toast)
	while #active > MAX_VISIBLE do
		dismiss(active[1])
	end

	Tween.play(toast, { Size = UDim2.new(1, 0, 0, height) }, 0.25)
	Tween.play(body, { Position = UDim2.fromOffset(0, 0) }, 0.35, Enum.EasingStyle.Back)

	local duration = options.Duration or 3.5
	Tween.play(timer, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	body.MouseButton1Click:Connect(function()
		dismiss(toast)
	end)
	task.delay(duration, function()
		dismiss(toast)
	end)
end

-- Shortcuts.
function Notify.info(text: string, title: string?)
	Notify.push({ Title = title, Text = text, Kind = "Info" })
end
function Notify.success(text: string, title: string?)
	Notify.push({ Title = title or "Success", Text = text, Kind = "Success" })
end
function Notify.warn(text: string, title: string?)
	Notify.push({ Title = title or "Heads up", Text = text, Kind = "Warning" })
end
function Notify.error(text: string, title: string?)
	Notify.push({ Title = title or "Error", Text = text, Kind = "Error" })
end

-- Shows the result of an operation that returns (ok, message).
function Notify.result(ok: boolean, message: string, title: string?)
	if ok then
		Notify.success(message, title)
	else
		Notify.error(message, title)
	end
end

return Notify
