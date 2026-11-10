--!nonstrict
-- Court Customization tab. Changes are visible only to you.

return function(page: ScrollingFrame, ctx: any)
	local C, Notify, Court = ctx.Components, ctx.Notify, ctx.CourtSystem

	C.Header(page, "Court Customization", "Restyle the court (only you see these changes)")

	local general = C.Section(page, "Court")
	C.Toggle(general, { Label = "Custom court look", Desc = "Off restores the original court", Key = "CourtCustomization" })
	local found = C.InfoRow(general, "Court detected", "")
	local function refreshFound()
		found:Set(if Court.hasCourt() then "Yes" else "No court in this place")
	end
	refreshFound()
	task.delay(5, refreshFound)

	local floor = C.Section(page, "Floor")
	C.ColorPicker(floor, { Label = "Floor colour", Key = "FloorColor" })
	C.Dropdown(floor, { Label = "Floor material", Key = "FloorMaterial" })

	local lines = C.Section(page, "Lines & hoops")
	C.ColorPicker(lines, { Label = "Line colour", Key = "LineColor" })
	C.Toggle(lines, { Label = "Glowing lines", Desc = "Neon court markings", Key = "GlowLines" })
	C.ColorPicker(lines, { Label = "Rim colour", Key = "RimColor" })
	C.Slider(lines, { Label = "Backboard transparency", Key = "BackboardTransparency" })

	local atmosphere = C.Section(page, "Atmosphere")
	C.Dropdown(atmosphere, { Label = "Lighting", Desc = "Time of day and ambience", Key = "CourtLighting" })

	C.Button(page, {
		Text = "Reset court",
		Style = "Danger",
		Callback = function()
			Court.resetSettings()
			Notify.success("Court restored to its default look")
		end,
	})
end
