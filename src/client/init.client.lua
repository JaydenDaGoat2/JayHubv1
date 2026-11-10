-- Builds the JayHub menu for the basketball game.
-- Press RightShift (or the ☰ button on touch devices) to show/hide it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))

local Library = require(script:WaitForChild("UI"):WaitForChild("Library"))
local Settings = require(script:WaitForChild("Settings"))

local Theme = Library.Theme
local player = Players.LocalPlayer

local window = Library.new({
	Title = "JayHub",
	Subtitle = "Basketball",
	ToggleKey = Settings:Get("MenuKey"),
})

local function notify(opts)
	if Settings:Get("Notifications") then
		window:Notify(opts)
	end
end

---------------------------------------------------------------------------
-- Gameplay
---------------------------------------------------------------------------
local gameplay = window:AddTab("Gameplay")

local shooting = gameplay:AddSection("Shooting")
shooting:AddToggle({
	Text = "Show shot meter",
	Default = Settings:Get("ShowShotMeter"),
	Callback = function(on)
		Settings:Set("ShowShotMeter", on)
	end,
})
shooting:AddToggle({
	Text = "Release feedback (Perfect / Early / Late)",
	Default = Settings:Get("ShotFeedback"),
	Callback = function(on)
		Settings:Set("ShotFeedback", on)
	end,
})
shooting:AddSlider({
	Text = "Meter size",
	Min = 0.5,
	Max = 1.5,
	Step = 0.05,
	Default = Settings:Get("MeterSize"),
	Suffix = "x",
	Callback = function(size)
		Settings:Set("MeterSize", size)
	end,
})

local camera = gameplay:AddSection("Camera")
camera:AddSlider({
	Text = "Field of view",
	Min = 50,
	Max = 100,
	Default = Settings:Get("CameraFov"),
	Callback = function(fov)
		Settings:Set("CameraFov", fov)
	end,
})

local court = gameplay:AddSection("Court")
court:AddLabel(string.format(
	"Three-pointer from %d studs  ·  Rim height %d  ·  Pass range %d",
	Config.ThreePointDistance,
	Config.RimHeight,
	Config.PassRange
))
court:AddButton({
	Text = "Respawn character",
	Callback = function()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end,
})

---------------------------------------------------------------------------
-- Controls
---------------------------------------------------------------------------
local controls = window:AddTab("Controls")

local actions = controls:AddSection("Actions")
local function bindAction(text, settingKey, action)
	actions:AddKeybind({
		Text = text,
		Default = Settings:Get(settingKey),
		Callback = function(key)
			Settings:Set(settingKey, key)
			-- Your input script reads Config.Keys, so keep it in sync (client copy only).
			Config.Keys[action][1] = key
			notify({ Title = "Keybind updated", Text = text .. " → " .. key.Name, Duration = 2 })
		end,
	})
end
bindAction("Shoot", "ShootKey", "Shoot")
bindAction("Pass", "PassKey", "Pass")
bindAction("Steal", "StealKey", "Steal")
actions:AddLabel("Click a key, then press the new one. Esc cancels.")

local menu = controls:AddSection("Menu")
menu:AddKeybind({
	Text = "Toggle menu",
	Default = Settings:Get("MenuKey"),
	Callback = function(key)
		Settings:Set("MenuKey", key)
	end,
})

---------------------------------------------------------------------------
-- Interface
---------------------------------------------------------------------------
local interface = window:AddTab("Interface")

local look = interface:AddSection("Appearance")
local accentNames = {}
local accentColors = {}
for _, accent in Theme.Accents do
	table.insert(accentNames, accent.Name)
	accentColors[accent.Name] = accent.Color
end
look:AddDropdown({
	Text = "Accent color",
	Options = accentNames,
	Default = Settings:Get("Accent"),
	Callback = function(name)
		Settings:Set("Accent", name)
	end,
})
look:AddSlider({
	Text = "Menu scale",
	Min = 0.75,
	Max = 1.25,
	Step = 0.05,
	Default = Settings:Get("UiScale"),
	Suffix = "x",
	Callback = function(scale)
		Settings:Set("UiScale", scale)
	end,
})

local alerts = interface:AddSection("Notifications")
alerts:AddToggle({
	Text = "Show notifications",
	Default = Settings:Get("Notifications"),
	Callback = function(on)
		Settings:Set("Notifications", on)
	end,
})
alerts:AddButton({
	Text = "Send test notification",
	Callback = function()
		window:Notify({ Title = "Test", Text = "Notifications look like this.", Type = "Success" })
	end,
})

---------------------------------------------------------------------------
-- About
---------------------------------------------------------------------------
local about = window:AddTab("About")
local info = about:AddSection("JayHub")
info:AddLabel("Menu and settings for the JayHub basketball game.")
info:AddLabel("Toggle with RightShift by default, or the ☰ button on mobile.")

---------------------------------------------------------------------------
-- Apply settings
---------------------------------------------------------------------------
Settings:Observe("Accent", function(name)
	window:SetAccent(accentColors[name] or Theme.Accents[1].Color)
end)
Settings:Observe("UiScale", function(scale)
	window:SetScale(scale)
end)
Settings:Observe("MenuKey", function(key)
	window:SetToggleKey(key)
end)
Settings:Observe("CameraFov", function(fov)
	local cam = Workspace.CurrentCamera
	if cam then
		cam.FieldOfView = fov
	end
end)

notify({
	Title = "JayHub loaded",
	Text = "Press " .. Settings:Get("MenuKey").Name .. " to show or hide the menu.",
})
