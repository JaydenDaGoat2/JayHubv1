-- Client-side settings store. The menu writes here; your other client scripts
-- read or observe values so they react when the player changes something.
--
--   local Settings = require(game.Players.LocalPlayer.PlayerScripts.Basketball.Settings)
--   Settings:Observe("ShowShotMeter", function(visible) meter.Visible = visible end)
--
-- Values only last for the session. Add a RemoteEvent + DataStore on the
-- server if you want them saved between visits.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Basketball"):WaitForChild("Config"))

local Settings = {}

local values = {
	-- Gameplay
	ShowShotMeter = true,
	ShotFeedback = true,
	MeterSize = 1,
	CameraFov = 70,
	-- Controls
	ShootKey = Config.Keys.Shoot[1],
	PassKey = Config.Keys.Pass[1],
	StealKey = Config.Keys.Steal[1],
	MenuKey = Enum.KeyCode.RightShift,
	-- Interface
	Accent = "Blue",
	UiScale = 1,
	Notifications = true,
}

local listeners = {}

function Settings:Get(key)
	return values[key]
end

function Settings:Set(key, value)
	if values[key] == value then
		return
	end
	values[key] = value
	for _, fn in listeners[key] or {} do
		task.spawn(fn, value)
	end
end

-- Calls `fn` now with the current value, then on every change.
-- Returns a function that stops observing.
function Settings:Observe(key, fn)
	listeners[key] = listeners[key] or {}
	table.insert(listeners[key], fn)
	task.spawn(fn, values[key])
	return function()
		local list = listeners[key]
		local index = table.find(list, fn)
		if index then
			table.remove(list, index)
		end
	end
end

return Settings
