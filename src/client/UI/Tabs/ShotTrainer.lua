--!nonstrict
-- Shot Trainer tab: meter settings, drill mode and last-shot readout.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Timing = require(ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("JayHub"):WaitForChild("Timing"))

return function(page: ScrollingFrame, ctx: any)
	local C, Store, Notify, Trainer, Keybinds = ctx.Components, ctx.Store, ctx.Notify, ctx.ShotTrainer, ctx.Keybinds

	C.Header(page, "Shot Trainer", "Practice your release timing")

	------------------------------------------------------------------ meter
	local meter = C.Section(page, "Meter", "Hold Shoot to fill the meter and let go on the white line")
	C.Toggle(meter, { Label = "Enable shot trainer", Desc = "Shows the meter and listens for the Shoot key", Key = "TrainerEnabled" })
	local difficultyInfo = "Rookie has the widest green window, Elite the tightest"
	C.Dropdown(meter, { Label = "Difficulty", Desc = difficultyInfo, Key = "TrainerDifficulty" })
	C.Slider(meter, { Label = "Meter fill time", Key = "MeterSpeed", Suffix = "s" })
	C.Dropdown(meter, { Label = "Meter style", Key = "MeterStyle" })
	C.Toggle(meter, { Label = "Auto release", Desc = "Releases for you (late) if you hold too long", Key = "AutoRelease" })
	C.Toggle(meter, { Label = "Show timing in ms", Key = "ShowTimingMs" })
	C.Toggle(meter, { Label = "Practice ball", Desc = "Shows the shot flying at the nearest hoop", Key = "VisualShot" })

	------------------------------------------------------------------ windows readout
	local windows = C.Section(page, "Timing windows")
	local perfectRow = C.InfoRow(windows, "Perfect window", "")
	local goodRow = C.InfoRow(windows, "Good window", "")
	local function refreshWindows()
		local w = Timing.windows(Store.get("TrainerDifficulty"))
		local fill = Store.get("MeterSpeed")
		perfectRow:Set(("±%d ms"):format(math.floor(w.Perfect * fill * 1000 + 0.5)))
		goodRow:Set(("±%d ms"):format(math.floor(w.Good * fill * 1000 + 0.5)))
	end
	Store.observeMany({ "TrainerDifficulty", "MeterSpeed" }, refreshWindows)

	------------------------------------------------------------------ drill
	local drillSection = C.Section(page, "Timed drill", "Make as many shots as you can before the clock runs out")
	C.Slider(drillSection, { Label = "Drill length", Key = "DrillDuration", Suffix = "s" })
	local drillStatus = C.InfoRow(drillSection, "Status", "Ready")
	local bestRow = C.InfoRow(drillSection, "Best this session", "0 makes")
	C.ButtonRow(drillSection, {
		{
			Text = "Start drill",
			Style = "Primary",
			Callback = function()
				Notify.result(Trainer.startDrill())
			end,
		},
		{
			Text = "Stop drill",
			Style = "Danger",
			Callback = function()
				if Trainer.drill() then
					Trainer.stopDrill(false)
				else
					Notify.warn("No drill is running")
				end
			end,
		},
	})
	local function refreshDrill()
		local drill = Trainer.drill()
		drillStatus:Set(if drill then ("Running · %d / %d"):format(drill.Makes, drill.Attempts) else "Ready")
		bestRow:Set(("%d makes"):format(Trainer.bestDrill()))
	end
	Trainer.DrillChanged:Connect(refreshDrill)
	Trainer.Shot:Connect(refreshDrill)
	refreshDrill()

	------------------------------------------------------------------ last shot
	local last = C.Section(page, "Last shot")
	local gradeRow = C.InfoRow(last, "Grade", "—")
	local timingRow = C.InfoRow(last, "Timing", "—")
	local resultRow = C.InfoRow(last, "Result", "—")
	Trainer.Shot:Connect(function(result)
		gradeRow:Set(result.Grade)
		timingRow:Set(("%+d ms (%s)"):format(result.ErrorMs, if result.ErrorMs < 0 then "early" elseif result.ErrorMs > 0 then "late" else "dead on"))
		resultRow:Set(if result.Made then "Make" else "Miss")
	end)

	local help = C.Section(page, "How it works")
	local helpText = C.Paragraph(help, "")
	local function refreshHelp()
		helpText.Text = ("Hold <b>%s</b> (or the on-screen SHOOT button) and release when the bar reaches the white line. "
			.. "<b>Perfect</b> always drops, <b>Good</b> usually does, <b>Early</b> and <b>Late</b> rarely go in. "
			.. "Every shot is added to your Statistics."):format(Keybinds.display(Keybinds.keyName("Shoot")))
	end
	Store.Changed:Connect(function(key)
		if key == "Key_Shoot" then
			refreshHelp()
		end
	end)
	refreshHelp()
end
