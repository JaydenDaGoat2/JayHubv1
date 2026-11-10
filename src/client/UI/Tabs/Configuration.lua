--!nonstrict
-- Configuration tab: interface theme, saving, configuration slots,
-- import / export and full reset.

local INTERFACE_KEYS = {
	"Theme",
	"AccentColor",
	"AccentColor2",
	"UIScale",
	"UITransparency",
	"Animations",
	"BlurBackground",
	"Notifications",
	"ShowFloatingButton",
}

local function formatTime(timestamp: number): string
	if timestamp <= 0 then
		return "never"
	end
	local ok, text = pcall(function()
		return DateTime.fromUnixTimestamp(timestamp):FormatLocalTime("MMM D, h:mm A", "en-us")
	end)
	return if ok then text else tostring(timestamp)
end

return function(page: ScrollingFrame, ctx: any)
	local C, Store, Notify, Schema = ctx.Components, ctx.Store, ctx.Notify, ctx.Schema

	C.Header(page, "Configuration", "Theme, saving and configuration slots")

	------------------------------------------------------------------ interface
	local interface = C.Section(page, "Interface")
	C.Dropdown(interface, { Label = "Theme", Desc = "Pick a preset or Custom to use your own colours", Key = "Theme" })
	-- Editing an accent switches the theme to Custom so the change is visible.
	local function useCustom()
		if Store.get("Theme") ~= "Custom" then
			Store.set("Theme", "Custom")
		end
	end
	C.ColorPicker(interface, { Label = "Custom accent", Key = "AccentColor", Callback = useCustom })
	C.ColorPicker(interface, { Label = "Custom accent 2", Key = "AccentColor2", Callback = useCustom })
	C.Slider(interface, { Label = "Interface scale", Key = "UIScale", Suffix = "x" })
	C.Slider(interface, { Label = "Background transparency", Key = "UITransparency" })
	C.Toggle(interface, { Label = "Animations", Desc = "Turn off for instant transitions", Key = "Animations" })
	C.Toggle(interface, { Label = "Blur game while open", Key = "BlurBackground" })
	C.Toggle(interface, { Label = "Notifications", Desc = "Errors are always shown", Key = "Notifications" })
	C.Toggle(interface, { Label = "Floating JH button", Desc = "Always on for touch devices", Key = "ShowFloatingButton" })
	C.Button(interface, {
		Text = "Reset interface",
		Callback = function()
			Store.resetKeys(INTERFACE_KEYS)
			Notify.success("Interface reset")
		end,
	})

	------------------------------------------------------------------ saving
	local saving = C.Section(page, "Saving")
	C.Toggle(saving, { Label = "Auto save", Desc = "Save changes to the cloud automatically", Key = "AutoSave" })
	local storageRow = C.InfoRow(saving, "Storage", "")
	local lastRow = C.InfoRow(saving, "Last saved", "")
	local function refreshSaving()
		storageRow:Set(if Store.Persistent then "Cloud (DataStore)" elseif Store.Online then "Session only" else "Offline")
		lastRow:Set(formatTime(Store.LastSaved))
	end
	Store.StatusChanged:Connect(refreshSaving)
	ctx.OnReady:Connect(refreshSaving)
	refreshSaving()
	C.Button(saving, {
		Text = "Save now",
		Style = "Primary",
		Callback = function()
			local ok, message = Store.saveNow()
			Notify.result(ok, message, "Save")
			refreshSaving()
		end,
	})

	------------------------------------------------------------------ slots
	local slots = C.Section(page, "Configuration slots", "Store complete setups and switch between them")
	local slotRows = {}
	for index = 1, Schema.SlotCount do
		local nameInput = C.TextInput(slots, {
			Label = "Slot " .. index,
			Placeholder = "Name this setup",
			Width = 200,
		})
		local info = C.InfoRow(slots, "Saved", "empty")
		C.ButtonRow(slots, {
			{
				Text = "Save",
				Style = "Primary",
				Callback = function()
					local name = nameInput:Get()
					if name == "" then
						name = "Slot " .. index
					end
					Notify.result(Store.saveSlot(index, string.sub(name, 1, 24)))
				end,
			},
			{
				Text = "Load",
				Callback = function()
					Notify.result(Store.loadSlot(index))
				end,
			},
			{
				Text = "Delete",
				Style = "Danger",
				Callback = function()
					Notify.result(Store.deleteSlot(index))
				end,
			},
		})
		slotRows[index] = { Name = nameInput, Info = info }
	end
	local function refreshSlots()
		for index, rowData in slotRows do
			local slot = Store.Slots[index]
			if slot then
				rowData.Info:Set(formatTime(slot.SavedAt))
				if not rowData.Name.Box:IsFocused() then
					rowData.Name:Set(slot.Name)
				end
			else
				rowData.Info:Set("empty")
			end
		end
	end
	Store.SlotsChanged:Connect(refreshSlots)
	refreshSlots()

	------------------------------------------------------------------ share
	local share = C.Section(page, "Share", "Copy a code to share your setup, or paste one to load it")
	local area = C.TextArea(share, { Placeholder = "JAYHUB1:{...}", Height = 70 })
	C.ButtonRow(share, {
		{
			Text = "Export",
			Style = "Primary",
			Callback = function()
				local code = Store.export()
				if code == "" then
					Notify.error("Couldn't create a config code")
					return
				end
				area.Text = code
				area:CaptureFocus()
				area.SelectionStart = 1
				area.CursorPosition = #code + 1
				Notify.info("Code ready. Press Ctrl+C to copy it.", "Export")
			end,
		},
		{
			Text = "Import",
			Callback = function()
				Notify.result(Store.import(area.Text), "Import")
			end,
		},
		{
			Text = "Clear",
			Callback = function()
				area.Text = ""
			end,
		},
	})

	------------------------------------------------------------------ reset
	local danger = C.Section(page, "Danger zone")
	local confirmUntil = 0
	local resetButton: any
	resetButton = C.Button(danger, {
		Text = "Reset all settings",
		Style = "Danger",
		Callback = function()
			if os.clock() < confirmUntil then
				confirmUntil = 0
				Store.replaceAll(Schema.defaults())
				resetButton:SetText("Reset all settings")
				Notify.success("Everything is back to default")
			else
				confirmUntil = os.clock() + 3
				resetButton:SetText("Click again to confirm")
				task.delay(3, function()
					if os.clock() >= confirmUntil then
						resetButton:SetText("Reset all settings")
					end
				end)
			end
		end,
	})
end
