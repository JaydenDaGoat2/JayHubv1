--!nonstrict
-- Rebindable actions. Each action reads its key from a "Key_<Action>" setting.
-- Gamepad buttons are fixed and touch players get on-screen buttons that call
-- Keybinds.trigger.

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JayHubShared = ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))
local Store = require(script.Parent.Store)

local Keybinds = {}

export type Phase = "Began" | "Ended"

Keybinds.Actions = {
	{ Action = "ToggleMenu", Label = "Toggle menu", Desc = "Open or hide the JayHub window" },
	{ Action = "Shoot", Label = "Shoot", Desc = "Hold to fill the meter, release to shoot" },
	{ Action = "ToggleTrainer", Label = "Toggle shot trainer", Desc = "Show or hide the shot meter" },
	{ Action = "ToggleDribble", Label = "Toggle dribble", Desc = "Start or stop dribbling" },
	{ Action = "Crossover", Label = "Crossover", Desc = "Switch dribble hands" },
	{ Action = "CycleCamera", Label = "Cycle camera", Desc = "Step through the camera modes" },
}

Keybinds.Gamepad = {
	ToggleMenu = Enum.KeyCode.ButtonSelect,
	Shoot = Enum.KeyCode.ButtonX,
	ToggleTrainer = Enum.KeyCode.DPadUp,
	ToggleDribble = Enum.KeyCode.DPadDown,
	Crossover = Enum.KeyCode.ButtonL1,
	CycleCamera = Enum.KeyCode.DPadRight,
} :: { [string]: Enum.KeyCode }

local handlers: { [string]: { (Phase) -> () } } = {}
local held: { [Enum.KeyCode]: { string } } = {}
local capturing: { Action: string, Callback: (boolean, string) -> () }? = nil

local function settingFor(action: string): string
	return "Key_" .. action
end

function Keybinds.keyName(action: string): string
	local name = Store.get(settingFor(action))
	return if type(name) == "string" and name ~= "" then name else "None"
end

-- Pretty label for UI ("LeftShift" -> "L-Shift").
function Keybinds.display(name: string): string
	local pretty = {
		LeftShift = "L-Shift",
		RightShift = "R-Shift",
		LeftControl = "L-Ctrl",
		RightControl = "R-Ctrl",
		LeftAlt = "L-Alt",
		RightAlt = "R-Alt",
		Return = "Enter",
		None = "None",
	}
	return pretty[name] or name
end

-- Registers a handler; returns a function that removes it.
function Keybinds.on(action: string, handler: (Phase) -> ())
	local list = handlers[action]
	if not list then
		list = {}
		handlers[action] = list
	end
	table.insert(list, handler)
	return function()
		local index = table.find(list, handler)
		if index then
			table.remove(list, index)
		end
	end
end

function Keybinds.trigger(action: string, phase: Phase)
	local list = handlers[action]
	if not list then
		return
	end
	for _, handler in table.clone(list) do
		local ok, err = pcall(handler, phase)
		if not ok then
			warn("[JayHub] keybind", action, "failed:", err)
		end
	end
end

local function actionsFor(keyCode: Enum.KeyCode): { string }
	local out = {}
	for _, entry in Keybinds.Actions do
		local name = Store.get(settingFor(entry.Action))
		if (name ~= "" and name == keyCode.Name) or Keybinds.Gamepad[entry.Action] == keyCode then
			table.insert(out, entry.Action)
		end
	end
	return out
end

function Keybinds.isCapturing(): boolean
	return capturing ~= nil
end

function Keybinds.cancelCapture()
	local current = capturing
	capturing = nil
	if current then
		current.Callback(false, "Cancelled")
	end
end

-- Waits for the next key press and binds it to `action`.
-- Escape cancels, Backspace unbinds. Callback gets (ok, message).
function Keybinds.capture(action: string, callback: (boolean, string) -> ())
	if capturing then
		Keybinds.cancelCapture()
	end
	capturing = { Action = action, Callback = callback }
end

function Keybinds.setKey(action: string, keyName: string): (boolean, string)
	if keyName ~= "" then
		if Schema.ReservedKeys[keyName] then
			return false, Keybinds.display(keyName) .. " is reserved"
		end
		for _, entry in Keybinds.Actions do
			if entry.Action ~= action and Store.get(settingFor(entry.Action)) == keyName then
				return false, ("%s is already used by %s"):format(Keybinds.display(keyName), entry.Label)
			end
		end
	end
	local ok, result = Store.set(settingFor(action), keyName)
	if not ok then
		return false, tostring(result)
	end
	return true, if keyName == "" then "Unbound" else "Bound to " .. Keybinds.display(keyName)
end

function Keybinds.resetAll()
	local keys = {}
	for _, entry in Keybinds.Actions do
		table.insert(keys, settingFor(entry.Action))
	end
	Store.resetKeys(keys)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if capturing then
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local current = capturing
		capturing = nil
		if input.KeyCode == Enum.KeyCode.Escape then
			current.Callback(false, "Cancelled")
		elseif input.KeyCode == Enum.KeyCode.Backspace then
			current.Callback(Keybinds.setKey(current.Action, ""))
		else
			current.Callback(Keybinds.setKey(current.Action, input.KeyCode.Name))
		end
		return
	end

	if gameProcessed or UserInputService:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == Enum.KeyCode.Unknown then
		return
	end
	local actions = actionsFor(input.KeyCode)
	if #actions > 0 then
		held[input.KeyCode] = actions
		for _, action in actions do
			Keybinds.trigger(action, "Began")
		end
	end
end)

-- Ended fires for every key whose Began we handled, even if the UI grabbed the
-- release, so a held shot can never get stuck.
UserInputService.InputEnded:Connect(function(input)
	local actions = held[input.KeyCode]
	if actions then
		held[input.KeyCode] = nil
		for _, action in actions do
			Keybinds.trigger(action, "Ended")
		end
	end
end)

return Keybinds
