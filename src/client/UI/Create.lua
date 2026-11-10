--!nonstrict
-- Small helpers for building instances.
--
--   Create("Frame", { Size = ..., BackgroundColor3 = Theme.T.Surface }, { children })
--
-- Property values made with `Theme.T.<token>` are bound to the theme so they
-- update when the player switches colours.

local Theme = require(script.Parent.Parent.Core.Theme)

local Create = {}

-- Every GuiObject gets an increasing LayoutOrder so list layouts always show
-- elements in the order they were created.
local layoutCounter = 0

local function new(className: string, props: { [string]: any }?, children: { Instance }?): any
	local instance = Instance.new(className)
	local parent: Instance? = nil
	if instance:IsA("GuiObject") and not (props and props.LayoutOrder) then
		layoutCounter += 1
		instance.LayoutOrder = layoutCounter
	end
	if props then
		for prop, value in props do
			if prop == "Parent" then
				parent = value
			elseif type(value) == "table" and value.__themeToken then
				Theme.bind(instance, prop, value.__themeToken)
			else
				(instance :: any)[prop] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

setmetatable(Create, {
	__call = function(_, className: string, props: { [string]: any }?, children: { Instance }?)
		return new(className, props, children)
	end,
})

Create.new = new

function Create.corner(radius: number?): UICorner
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

function Create.round(): UICorner
	return new("UICorner", { CornerRadius = UDim.new(1, 0) })
end

function Create.stroke(token: string?, thickness: number?, transparency: number?): UIStroke
	return new("UIStroke", {
		Color = Theme.T[token or "Stroke"],
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Create.padding(top: number, right: number?, bottom: number?, left: number?): UIPadding
	return new("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right or top),
		PaddingBottom = UDim.new(0, bottom or top),
		PaddingLeft = UDim.new(0, left or right or top),
	})
end

function Create.list(padding: number?, direction: Enum.FillDirection?, align: Enum.HorizontalAlignment?): UIListLayout
	return new("UIListLayout", {
		Padding = UDim.new(0, padding or 8),
		FillDirection = direction or Enum.FillDirection.Vertical,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

-- Accent gradient (Accent -> Accent2) that follows the theme.
function Create.accentGradient(rotation: number?): UIGradient
	local gradient = new("UIGradient", { Rotation = rotation or 0 })
	Theme.bindGradient(gradient)
	return gradient
end

-- Plain text label with sensible defaults.
function Create.text(props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.T.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.new(1, 0, 0, 18),
	}
	for key, value in props do
		defaults[key] = value
	end
	return new("TextLabel", defaults)
end

return Create
