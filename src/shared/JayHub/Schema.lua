--!strict
-- Every JayHub setting in one place: type, default and limits.
-- The server and the client both validate against this table, so a value that
-- isn't described here can never be saved.
--
-- Types:
--   bool     true / false
--   number   clamped to Min..Max and snapped to Step
--   enum     one of Options
--   string   trimmed, at most MaxLength characters
--   color    "#RRGGBB"
--   key      an Enum.KeyCode name (or "" for unbound)

local Schema = {}

export type Definition = {
	Type: string, -- "bool" | "number" | "enum" | "string" | "color" | "key"
	Default: any,
	Min: number?,
	Max: number?,
	Step: number?,
	Options: { string }?,
	MaxLength: number?,
}

Schema.Version = 1
Schema.SlotCount = 3

Schema.ThemeNames = { "JayHub", "Neon Violet", "Arctic", "Crimson", "Emerald", "Solar", "Custom" }

Schema.Settings = {
	------------------------------------------------------------------ Interface
	Theme = { Type = "enum", Default = "JayHub", Options = Schema.ThemeNames },
	AccentColor = { Type = "color", Default = "#2F8CFF" },
	AccentColor2 = { Type = "color", Default = "#8B5CFF" },
	UIScale = { Type = "number", Default = 1, Min = 0.7, Max = 1.4, Step = 0.05 },
	UITransparency = { Type = "number", Default = 0, Min = 0, Max = 0.5, Step = 0.05 },
	Animations = { Type = "bool", Default = true },
	BlurBackground = { Type = "bool", Default = false },
	Notifications = { Type = "bool", Default = true },
	AutoSave = { Type = "bool", Default = true },
	ShowFloatingButton = { Type = "bool", Default = true },

	------------------------------------------------------------------ Profile
	Nickname = { Type = "string", Default = "", MaxLength = 20 },
	JerseyNumber = { Type = "number", Default = 23, Min = 0, Max = 99, Step = 1 },
	Position = { Type = "enum", Default = "SG", Options = { "PG", "SG", "SF", "PF", "C" } },
	ShootingHand = { Type = "enum", Default = "Right", Options = { "Right", "Left" } },
	ShowNameplate = { Type = "bool", Default = true },
	NameplateColor = { Type = "color", Default = "#2F8CFF" },
	WalkSpeed = { Type = "number", Default = 16, Min = 12, Max = 24, Step = 1 },

	------------------------------------------------------------------ Shot trainer
	TrainerEnabled = { Type = "bool", Default = false },
	TrainerDifficulty = { Type = "enum", Default = "Pro", Options = { "Rookie", "Pro", "Elite" } },
	MeterSpeed = { Type = "number", Default = 0.9, Min = 0.5, Max = 1.6, Step = 0.05 },
	MeterStyle = { Type = "enum", Default = "Vertical", Options = { "Vertical", "Horizontal" } },
	ShowTimingMs = { Type = "bool", Default = true },
	VisualShot = { Type = "bool", Default = true },
	AutoRelease = { Type = "bool", Default = true },
	DrillDuration = { Type = "number", Default = 60, Min = 30, Max = 180, Step = 15 },

	------------------------------------------------------------------ Dribble
	DribbleEnabled = { Type = "bool", Default = false },
	DribbleSpeed = { Type = "number", Default = 2.2, Min = 1, Max = 4, Step = 0.1 },
	DribbleHeight = { Type = "number", Default = 0.75, Min = 0.3, Max = 1, Step = 0.05 },
	DribbleHand = { Type = "enum", Default = "Right", Options = { "Right", "Left" } },
	DribbleStyle = { Type = "enum", Default = "Standard", Options = { "Standard", "Low", "Speed" } },
	AutoCrossover = { Type = "bool", Default = false },
	CrossoverEvery = { Type = "number", Default = 4, Min = 2, Max = 10, Step = 1 },
	BallColor = { Type = "color", Default = "#E26820" },
	BallTrail = { Type = "bool", Default = true },

	------------------------------------------------------------------ Camera
	CameraMode = { Type = "enum", Default = "Default", Options = { "Default", "Shoulder", "Broadcast", "Overhead" } },
	FieldOfView = { Type = "number", Default = 70, Min = 50, Max = 110, Step = 1 },
	CameraSmoothing = { Type = "number", Default = 0.5, Min = 0, Max = 0.95, Step = 0.05 },
	ShoulderOffset = { Type = "number", Default = 2, Min = -4, Max = 4, Step = 0.25 },
	BroadcastDistance = { Type = "number", Default = 30, Min = 12, Max = 60, Step = 1 },
	MaxZoom = { Type = "number", Default = 40, Min = 8, Max = 100, Step = 1 },
	ShotShake = { Type = "bool", Default = true },
	ShakeIntensity = { Type = "number", Default = 0.4, Min = 0, Max = 1, Step = 0.05 },

	------------------------------------------------------------------ Court
	CourtCustomization = { Type = "bool", Default = true },
	FloorColor = { Type = "color", Default = "#C4925C" },
	FloorMaterial = {
		Type = "enum",
		Default = "WoodPlanks",
		Options = { "WoodPlanks", "Wood", "SmoothPlastic", "Concrete", "Marble", "Slate" },
	},
	LineColor = { Type = "color", Default = "#F5F5F5" },
	GlowLines = { Type = "bool", Default = false },
	RimColor = { Type = "color", Default = "#EB501E" },
	BackboardTransparency = { Type = "number", Default = 0.35, Min = 0, Max = 0.9, Step = 0.05 },
	CourtLighting = { Type = "enum", Default = "Default", Options = { "Default", "Arena", "Night", "Sunset" } },

	------------------------------------------------------------------ Keybinds
	Key_ToggleMenu = { Type = "key", Default = "RightShift" },
	Key_Shoot = { Type = "key", Default = "E" },
	Key_ToggleTrainer = { Type = "key", Default = "T" },
	Key_ToggleDribble = { Type = "key", Default = "G" },
	Key_Crossover = { Type = "key", Default = "Q" },
	Key_CycleCamera = { Type = "key", Default = "C" },
} :: { [string]: Definition }

-- Keys the player may not bind (movement, chat, menu).
Schema.ReservedKeys = {
	W = true,
	A = true,
	S = true,
	D = true,
	Space = true,
	Escape = true,
	Slash = true,
	Tab = true,
	Unknown = true,
}

-- Stat fields that persist between sessions.
Schema.StatFields = { "Attempts", "Makes", "Perfect", "Good", "Early", "Late", "BestStreak", "TotalErrorMs" }

---------------------------------------------------------------------------
-- Colour helpers
---------------------------------------------------------------------------

function Schema.isHex(value: any): boolean
	return type(value) == "string" and string.match(value, "^#%x%x%x%x%x%x$") ~= nil
end

function Schema.toColor(hex: string): Color3
	if not Schema.isHex(hex) then
		return Color3.new(1, 1, 1)
	end
	local ok, color = pcall(Color3.fromHex, hex)
	return if ok then color else Color3.new(1, 1, 1)
end

function Schema.toHex(color: Color3): string
	return "#" .. string.upper(color:ToHex())
end

-- Accepts "#abc", "abc", "#aabbcc" or "aabbcc"; returns "#AABBCC" or nil.
function Schema.normalizeHex(text: string): string?
	local clean = string.upper(string.gsub(text, "[%s#]", ""))
	if string.match(clean, "^%x%x%x$") then
		local r, g, b = string.sub(clean, 1, 1), string.sub(clean, 2, 2), string.sub(clean, 3, 3)
		clean = r .. r .. g .. g .. b .. b
	end
	if string.match(clean, "^%x%x%x%x%x%x$") then
		return "#" .. clean
	end
	return nil
end

---------------------------------------------------------------------------
-- Validation
---------------------------------------------------------------------------

local function isValidKeyName(name: string): boolean
	if name == "" then
		return true
	end
	local ok, keyCode = pcall(function()
		return (Enum.KeyCode :: any)[name]
	end)
	return ok and keyCode ~= nil and not Schema.ReservedKeys[name]
end

-- Returns (true, cleanValue) or (false, reason).
function Schema.validate(key: string, value: any): (boolean, any)
	local def = Schema.Settings[key]
	if not def then
		return false, "Unknown setting " .. tostring(key)
	end

	if def.Type == "bool" then
		if type(value) ~= "boolean" then
			return false, "Expected true/false"
		end
		return true, value
	elseif def.Type == "number" then
		if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
			return false, "Expected a number"
		end
		local min, max, step = def.Min or -math.huge, def.Max or math.huge, def.Step
		local clean = math.clamp(value, min, max)
		if step and step > 0 then
			clean = min + math.floor((clean - min) / step + 0.5) * step
			clean = math.clamp(clean, min, max)
			-- Strip floating point noise (0.30000000004 -> 0.3).
			clean = math.floor(clean * 1000 + 0.5) / 1000
		end
		return true, clean
	elseif def.Type == "enum" then
		if type(value) ~= "string" or not table.find(def.Options :: { string }, value) then
			return false, "Not an allowed option"
		end
		return true, value
	elseif def.Type == "string" then
		if type(value) ~= "string" then
			return false, "Expected text"
		end
		local clean = string.gsub(value, "[%c]", "")
		clean = string.match(clean, "^%s*(.-)%s*$") or ""
		local maxLength = def.MaxLength or 32
		if utf8.len(clean) == nil then
			return false, "Invalid characters"
		end
		if (utf8.len(clean) :: number) > maxLength then
			clean = string.sub(clean, 1, (utf8.offset(clean, maxLength + 1) :: number) - 1)
		end
		return true, clean
	elseif def.Type == "color" then
		if type(value) ~= "string" then
			return false, "Expected a colour"
		end
		local hex = Schema.normalizeHex(value)
		if not hex then
			return false, "Expected #RRGGBB"
		end
		return true, hex
	elseif def.Type == "key" then
		if type(value) ~= "string" or not isValidKeyName(value) then
			return false, "That key can't be bound"
		end
		return true, value
	end

	return false, "Unsupported type"
end

function Schema.defaults(): { [string]: any }
	local out = {}
	for key, def in Schema.Settings do
		out[key] = def.Default
	end
	return out
end

-- Builds a complete, valid settings table from untrusted input. Missing or
-- invalid entries fall back to their defaults; unknown keys are dropped.
function Schema.sanitize(input: any): { [string]: any }
	local out = Schema.defaults()
	if type(input) ~= "table" then
		return out
	end
	for key in Schema.Settings do
		local value = input[key]
		if value ~= nil then
			local ok, clean = Schema.validate(key, value)
			if ok then
				out[key] = clean
			end
		end
	end
	return out
end

function Schema.emptyStats(): { [string]: number }
	local out = {}
	for _, field in Schema.StatFields do
		out[field] = 0
	end
	return out
end

function Schema.sanitizeStats(input: any): { [string]: number }
	local out = Schema.emptyStats()
	if type(input) ~= "table" then
		return out
	end
	for _, field in Schema.StatFields do
		local value = input[field]
		if type(value) == "number" and value == value and value >= 0 and value < 1e9 then
			out[field] = math.floor(value)
		end
	end
	-- Keep the counts consistent with each other.
	local graded = out.Perfect + out.Good + out.Early + out.Late
	if graded > out.Attempts then
		out.Attempts = graded
	end
	out.Makes = math.min(out.Makes, out.Attempts)
	out.BestStreak = math.min(out.BestStreak, out.Makes)
	return out
end

return Schema
