--!nonstrict
-- Dribble Settings tab.

local DRIBBLE_KEYS = {
	"DribbleEnabled",
	"DribbleSpeed",
	"DribbleHeight",
	"DribbleHand",
	"DribbleStyle",
	"AutoCrossover",
	"CrossoverEvery",
	"BallColor",
	"BallTrail",
}

return function(page: ScrollingFrame, ctx: any)
	local C, Store, Notify, Dribble, Keybinds = ctx.Components, ctx.Store, ctx.Notify, ctx.DribbleSystem, ctx.Keybinds

	C.Header(page, "Dribble Settings", "Tune your practice handle")

	local main = C.Section(page, "Dribble")
	C.Toggle(main, { Label = "Dribble", Desc = "Bounce a practice ball beside you", Key = "DribbleEnabled" })
	C.Slider(main, { Label = "Dribble speed", Key = "DribbleSpeed", Suffix = "/s" })
	C.Slider(main, { Label = "Dribble height", Key = "DribbleHeight" })
	C.Dropdown(main, { Label = "Starting hand", Key = "DribbleHand" })
	C.Dropdown(main, { Label = "Style", Desc = "Low is tight and quick, Speed pushes the ball ahead", Key = "DribbleStyle" })

	local moves = C.Section(page, "Crossovers")
	C.Toggle(moves, { Label = "Auto crossover", Desc = "Switch hands automatically", Key = "AutoCrossover" })
	C.Slider(moves, { Label = "Crossover every", Key = "CrossoverEvery", Suffix = " bounces" })
	local counter = C.InfoRow(moves, "Crossovers this session", "0")
	local crossovers = 0
	Dribble.Crossed:Connect(function()
		crossovers += 1
		counter:Set(tostring(crossovers))
	end)
	local bounceRow = C.InfoRow(moves, "Bounces", "0")
	Dribble.Bounced:Connect(function(count)
		bounceRow:Set(tostring(count))
	end)
	C.Button(moves, {
		Text = "Crossover now",
		Style = "Primary",
		Callback = function()
			if not Dribble.crossover() then
				Notify.warn("Start dribbling first (" .. Keybinds.display(Keybinds.keyName("ToggleDribble")) .. ")")
			end
		end,
	})

	local look = C.Section(page, "Ball")
	C.ColorPicker(look, { Label = "Ball colour", Key = "BallColor" })
	C.Toggle(look, { Label = "Motion trail", Key = "BallTrail" })

	C.Button(page, {
		Text = "Reset dribble settings",
		Style = "Danger",
		Callback = function()
			Store.resetKeys(DRIBBLE_KEYS)
			Notify.success("Dribble settings reset")
		end,
	})
end
