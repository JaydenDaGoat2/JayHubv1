--!nonstrict
-- Keybinds tab.

return function(page: ScrollingFrame, ctx: any)
	local C, Notify, Keybinds = ctx.Components, ctx.Notify, ctx.Keybinds

	C.Header(page, "Keybinds", "Click a key, then press the new one")

	local keyboard = C.Section(page, "Keyboard", "Esc cancels · Backspace unbinds")
	for _, entry in Keybinds.Actions do
		C.Keybind(keyboard, { Label = entry.Label, Desc = entry.Desc, Action = entry.Action })
	end

	local gamepad = C.Section(page, "Gamepad", "Fixed buttons for controllers")
	for _, entry in Keybinds.Actions do
		local button = Keybinds.Gamepad[entry.Action]
		C.InfoRow(gamepad, entry.Label, if button then (string.gsub(button.Name, "^Button", "")) else "—")
	end

	local touch = C.Section(page, "Touch")
	C.Paragraph(
		touch,
		"Tap the <b>JH</b> button to open or hide the menu (drag it anywhere). With the shot trainer on, a <b>SHOOT</b> button appears at the bottom right."
	)

	C.Paragraph(page, "Movement, chat and menu keys (W A S D, Space, Tab, /, Esc) can't be bound.", "Muted")

	C.Button(page, {
		Text = "Reset keybinds",
		Style = "Danger",
		Callback = function()
			Keybinds.cancelCapture()
			Keybinds.resetAll()
			Notify.success("Keybinds reset to defaults")
		end,
	})
end
