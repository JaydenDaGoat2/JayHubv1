--!nonstrict
-- JayHub client bootstrap. Loads saved data, starts every system and builds
-- the interface. Each step is protected so one failure can't take the whole
-- hub down.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local JayHubShared = Shared:WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))
local Signal = require(JayHubShared:WaitForChild("Signal"))

local Core = script:WaitForChild("Core")
local UI = script:WaitForChild("UI")
local Systems = script:WaitForChild("Systems")

local Store = require(Core.Store)
local Theme = require(Core.Theme)
local Notify = require(Core.Notify)
local Keybinds = require(Core.Keybinds)
local Components = require(UI.Components)
local Window = require(UI.Window)
local Create = require(UI.Create)

local Stats = require(Systems.Stats)
local CameraSystem = require(Systems.CameraSystem)
local CourtSystem = require(Systems.CourtSystem)
local DribbleSystem = require(Systems.DribbleSystem)
local ShotTrainer = require(Systems.ShotTrainer)

local function step(name: string, fn: () -> ())
	local ok, err = pcall(fn)
	if not ok then
		warn(("[JayHub] %s failed: %s"):format(name, tostring(err)))
	end
	return ok
end

---------------------------------------------------------------------------
-- HUD layer (shot meter, toasts) lives in its own ScreenGui so it stays
-- visible while the window is closed.
---------------------------------------------------------------------------
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
for _, name in { "JayHubHUD", "JayHubToasts" } do
	local old = playerGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end
local hud = Create("ScreenGui", {
	Name = "JayHubHUD",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 40,
	Parent = playerGui,
})
local toastGui = Create("ScreenGui", {
	Name = "JayHubToasts",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 60,
	Parent = playerGui,
})
Notify.init(toastGui)

---------------------------------------------------------------------------
-- Systems
---------------------------------------------------------------------------
step("Camera", CameraSystem.start)
step("Court", CourtSystem.start)
step("Dribble", DribbleSystem.start)
step("Shot trainer", function()
	ShotTrainer.start(hud)
end)

Keybinds.on("ToggleTrainer", function(phase)
	if phase == "Began" then
		local enabled = not Store.get("TrainerEnabled")
		Store.set("TrainerEnabled", enabled)
		Notify.info(if enabled then "Shot trainer on" else "Shot trainer off", "Shot Trainer")
	end
end)
Keybinds.on("ToggleDribble", function(phase)
	if phase == "Began" then
		Store.set("DribbleEnabled", not Store.get("DribbleEnabled"))
	end
end)
Keybinds.on("Crossover", function(phase)
	if phase == "Began" then
		DribbleSystem.crossover()
	end
end)
Keybinds.on("CycleCamera", function(phase)
	if phase == "Began" then
		Notify.info("Camera: " .. CameraSystem.cycleMode(), "Camera")
	end
end)

---------------------------------------------------------------------------
-- Interface
---------------------------------------------------------------------------
local OnReady = Signal.new()
local ctx = {
	Components = Components,
	Store = Store,
	Theme = Theme,
	Notify = Notify,
	Keybinds = Keybinds,
	Schema = Schema,
	Stats = Stats,
	CameraSystem = CameraSystem,
	CourtSystem = CourtSystem,
	DribbleSystem = DribbleSystem,
	ShotTrainer = ShotTrainer,
	OnReady = OnReady,
}

local window = Window.new()
local Tabs = UI:WaitForChild("Tabs")
local TAB_ORDER = {
	{ "Home", "Home" },
	{ "Shot Trainer", "ShotTrainer" },
	{ "Player Settings", "PlayerSettings" },
	{ "Dribble Settings", "DribbleSettings" },
	{ "Camera Settings", "CameraSettings" },
	{ "Court Customization", "CourtCustomization" },
	{ "Keybinds", "Keybinds" },
	{ "Statistics", "Statistics" },
	{ "Configuration", "Configuration" },
}
for _, entry in TAB_ORDER do
	local title, moduleName = entry[1], entry[2]
	window:AddTab(title, function(page)
		local module = Tabs:FindFirstChild(moduleName)
		if not module then
			error("missing tab module " .. moduleName)
		end
		local build = require(module :: ModuleScript)
		build(page, ctx)
	end)
end
window:SelectTab("Home")

-- Intro animation.
window.IsOpen = false
window.Root.Visible = false
window:Open()

---------------------------------------------------------------------------
-- Load saved data (may take a moment while the server reads the DataStore).
---------------------------------------------------------------------------
window:SetStatus("Connecting…", "Warning")
task.spawn(function()
	local online = false
	step("Load data", function()
		online = Store.init()
	end)
	if online then
		Stats.load(Store.InitialStats)
	end

	if Store.Persistent then
		window:SetStatus("Cloud save", "Success")
		Notify.success("Your settings and stats are loaded.", "JayHub ready")
	elseif online then
		window:SetStatus("Session only", "Warning")
		Notify.warn("Saving is unavailable right now. Changes last until you leave.", "JayHub ready")
	else
		window:SetStatus("Offline", "Danger")
		Notify.warn("The JayHub server script isn't running. Changes won't be saved.", "Offline")
	end
	OnReady:Fire()

	local key = Keybinds.display(Keybinds.keyName("ToggleMenu"))
	Notify.info(("Press %s to show or hide JayHub."):format(key), "Tip")
end)

Store.StatusChanged:Connect(function(text)
	if string.find(text, "failed") then
		window:SetStatus("Sync failed", "Danger")
	elseif Store.Persistent then
		window:SetStatus(text == "Saved" and "Saved" or "Cloud save", "Success")
	end
end)
