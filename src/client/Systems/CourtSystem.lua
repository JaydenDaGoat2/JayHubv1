--!nonstrict
-- Court customization. Changes are local to this player (other players keep
-- their own look). Works on the generated court (workspace.BasketballCourt)
-- and on any hoop tagged with Config.HoopTag. Original values are remembered
-- so turning customization off restores the court exactly.

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local Schema = require(Shared:WaitForChild("JayHub"):WaitForChild("Schema"))
local Store = require(script.Parent.Parent.Core.Store)

local CourtSystem = {}

local COURT_KEYS = {
	"CourtCustomization",
	"FloorColor",
	"FloorMaterial",
	"LineColor",
	"GlowLines",
	"RimColor",
	"BackboardTransparency",
}

type Original = { Color: Color3, Material: Enum.Material, Transparency: number }
local originals = setmetatable({}, { __mode = "k" }) :: { [BasePart]: Original }
local lightingOriginal: { [string]: any }? = nil
local applyQueued = false

local LIGHTING_PRESETS = {
	Arena = {
		ClockTime = 14,
		Brightness = 2.2,
		Ambient = Color3.fromRGB(120, 125, 140),
		OutdoorAmbient = Color3.fromRGB(140, 145, 160),
		ExposureCompensation = 0.2,
	},
	Night = {
		ClockTime = 0.5,
		Brightness = 1,
		Ambient = Color3.fromRGB(70, 80, 120),
		OutdoorAmbient = Color3.fromRGB(60, 70, 110),
		ExposureCompensation = 0.4,
	},
	Sunset = {
		ClockTime = 17.9,
		Brightness = 2,
		Ambient = Color3.fromRGB(140, 100, 90),
		OutdoorAmbient = Color3.fromRGB(150, 110, 100),
		ExposureCompensation = 0,
	},
} :: { [string]: { [string]: any } }

local function remember(part: BasePart)
	if not originals[part] then
		originals[part] = { Color = part.Color, Material = part.Material, Transparency = part.Transparency }
	end
end

local function restore(part: BasePart)
	local original = originals[part]
	if original then
		part.Color = original.Color
		part.Material = original.Material
		part.Transparency = original.Transparency
	end
end

-- Collects court parts by role.
local function collect(): { Floor: { BasePart }, Lines: { BasePart }, Rims: { BasePart }, Boards: { BasePart } }
	local out = { Floor = {}, Lines = {}, Rims = {}, Boards = {} }
	local court = workspace:FindFirstChild("BasketballCourt")
	if court then
		local floor = court:FindFirstChild("Floor")
		if floor and floor:IsA("BasePart") then
			table.insert(out.Floor, floor)
		end
		local lines = court:FindFirstChild("Lines")
		if lines then
			for _, item in lines:GetDescendants() do
				if item:IsA("BasePart") then
					table.insert(out.Lines, item)
				end
			end
		end
	end
	for _, hoop in CollectionService:GetTagged(Config.HoopTag) do
		for _, item in hoop:GetDescendants() do
			if item:IsA("BasePart") then
				if item.Name == "Rim" or item.Name == "RimBracket" then
					table.insert(out.Rims, item)
				elseif item.Name == "Backboard" then
					table.insert(out.Boards, item)
				end
			end
		end
	end
	return out
end

function CourtSystem.apply()
	local parts = collect()
	local enabled = Store.get("CourtCustomization") == true

	for _, group in parts do
		for _, part in group do
			remember(part)
			if not enabled then
				restore(part)
			end
		end
	end
	if not enabled then
		return
	end

	local floorColor = Schema.toColor(Store.get("FloorColor"))
	local floorMaterial = (Enum.Material :: any)[Store.get("FloorMaterial")] or Enum.Material.WoodPlanks
	for _, part in parts.Floor do
		part.Color = floorColor
		part.Material = floorMaterial
	end

	local lineColor = Schema.toColor(Store.get("LineColor"))
	local glow = Store.get("GlowLines") == true
	for _, part in parts.Lines do
		part.Color = lineColor
		part.Material = if glow then Enum.Material.Neon else (originals[part] :: Original).Material
	end

	local rimColor = Schema.toColor(Store.get("RimColor"))
	for _, part in parts.Rims do
		part.Color = rimColor
	end

	local boardTransparency = Store.get("BackboardTransparency") :: number
	for _, part in parts.Boards do
		part.Transparency = boardTransparency
	end
end

local function queueApply()
	if applyQueued then
		return
	end
	applyQueued = true
	task.delay(0.2, function()
		applyQueued = false
		local ok, err = pcall(CourtSystem.apply)
		if not ok then
			warn("[JayHub] court apply failed:", err)
		end
	end)
end

function CourtSystem.applyLighting(preset: string)
	local props = LIGHTING_PRESETS[preset]
	if not lightingOriginal then
		lightingOriginal = {
			ClockTime = Lighting.ClockTime,
			Brightness = Lighting.Brightness,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			ExposureCompensation = Lighting.ExposureCompensation,
		}
	end
	local source = props or lightingOriginal :: { [string]: any }
	for prop, value in source do
		local ok, err = pcall(function()
			(Lighting :: any)[prop] = value
		end)
		if not ok then
			warn("[JayHub] lighting", prop, err)
		end
	end
end

-- Resets every court setting to its default.
function CourtSystem.resetSettings()
	local keys = table.clone(COURT_KEYS)
	table.insert(keys, "CourtLighting")
	Store.resetKeys(keys)
end

function CourtSystem.hasCourt(): boolean
	return workspace:FindFirstChild("BasketballCourt") ~= nil or #CollectionService:GetTagged(Config.HoopTag) > 0
end

function CourtSystem.start()
	Store.observeMany(COURT_KEYS, queueApply)
	Store.observe("CourtLighting", CourtSystem.applyLighting)

	-- Re-apply when the court is built late or streams in.
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "BasketballCourt" then
			queueApply()
			child.DescendantAdded:Connect(queueApply)
		end
	end)
	local court = workspace:FindFirstChild("BasketballCourt")
	if court then
		court.DescendantAdded:Connect(queueApply)
	end
	CollectionService:GetInstanceAddedSignal(Config.HoopTag):Connect(queueApply)
end

return CourtSystem
