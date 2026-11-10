--!nonstrict
-- Colour palette for the whole interface. UI elements bind properties to a
-- named token; when the player changes theme every bound property animates to
-- its new colour.
--
--   Theme.bind(frame, "BackgroundColor3", "Surface")
--   Theme.bindGradient(gradient)   -- Accent -> Accent2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JayHubShared = ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))
local Signal = require(JayHubShared:WaitForChild("Signal"))
local Store = require(script.Parent.Store)
local Tween = require(script.Parent.Parent.UI.Tween)

local Theme = {}

Theme.Changed = Signal.new()

-- Fixed dark base shared by every theme.
Theme.Base = {
	Background = "#08090D",
	Sidebar = "#0C0D13",
	Surface = "#111219",
	Surface2 = "#161821",
	Elevated = "#1D202B",
	Hover = "#252937",
	Stroke = "#2A2E3D",
	Text = "#F1F3FA",
	SubText = "#9BA1B6",
	Muted = "#5E6479",
	Success = "#34D399",
	Warning = "#FBBF24",
	Danger = "#F43F5E",
}

-- Accent pairs (primary, secondary) for each preset.
Theme.Presets = {
	JayHub = { "#2F8CFF", "#8B5CFF" },
	["Neon Violet"] = { "#A855F7", "#EC4899" },
	Arctic = { "#38BDF8", "#818CF8" },
	Crimson = { "#F43F5E", "#A855F7" },
	Emerald = { "#10B981", "#3B82F6" },
	Solar = { "#F59E0B", "#EF4444" },
} :: { [string]: { string } }

local palette: { [string]: Color3 } = {}
local bindings = setmetatable({}, { __mode = "k" }) :: { [Instance]: { [string]: string } }
local gradients = setmetatable({}, { __mode = "k" }) :: { [UIGradient]: boolean }

-- `Theme.T.Surface` returns a marker the Create helper turns into a binding.
Theme.T = setmetatable({}, {
	__index = function(_, token)
		return { __themeToken = token }
	end,
}) :: { [string]: any }

local function computePalette()
	for token, hex in Theme.Base do
		palette[token] = Schema.toColor(hex)
	end
	local themeName = Store.get("Theme")
	local pair = Theme.Presets[themeName]
	local accent, accent2
	if pair then
		accent, accent2 = Schema.toColor(pair[1]), Schema.toColor(pair[2])
	else
		accent, accent2 = Schema.toColor(Store.get("AccentColor")), Schema.toColor(Store.get("AccentColor2"))
	end
	palette.Accent = accent
	palette.Accent2 = accent2
	-- Subtle tinted surfaces derived from the accent.
	palette.AccentDim = palette.Surface2:Lerp(accent, 0.18)
	palette.AccentSoft = palette.Elevated:Lerp(accent, 0.35)
end

computePalette()

function Theme.get(token: string): Color3
	return palette[token] or Color3.new(1, 0, 1)
end

function Theme.accentSequence(): ColorSequence
	return ColorSequence.new(palette.Accent, palette.Accent2)
end

-- Binds a property to a token and sets it now. Pass `animate` to tween to
-- the new colour instead of snapping.
function Theme.bind(instance: Instance, prop: string, token: string, animate: boolean?)
	local entry = bindings[instance]
	if not entry then
		entry = {}
		bindings[instance] = entry
	end
	entry[prop] = token
	if animate then
		Tween.play(instance, { [prop] = Theme.get(token) }, 0.15)
		return
	end
	local ok, err = pcall(function()
		(instance :: any)[prop] = Theme.get(token)
	end)
	if not ok then
		warn("[JayHub] Theme.bind failed:", err)
	end
end

function Theme.unbind(instance: Instance, prop: string?)
	local entry = bindings[instance]
	if not entry then
		return
	end
	if prop then
		entry[prop] = nil
	else
		bindings[instance] = nil
	end
end

function Theme.bindGradient(gradient: UIGradient)
	gradients[gradient] = true
	gradient.Color = Theme.accentSequence()
end

local function applyAll()
	computePalette()
	for instance, props in bindings do
		if instance.Parent then
			-- Only accent-derived tokens change between themes.
			local goal = {}
			local any = false
			for prop, token in props do
				if string.sub(token, 1, 6) == "Accent" then
					goal[prop] = palette[token]
					any = true
				end
			end
			if any then
				Tween.play(instance, goal, 0.3)
			end
		end
	end
	local sequence = Theme.accentSequence()
	for gradient in gradients do
		gradient.Color = sequence
	end
	Theme.Changed:Fire()
end

Store.observeMany({ "Theme", "AccentColor", "AccentColor2" }, applyAll)

return Theme
