--!nonstrict
-- Home: welcome banner, live session stats, quick actions and controls.

local Players = game:GetService("Players")

local UI = script.Parent.Parent
local Create = require(UI.Create)

return function(page: ScrollingFrame, ctx: any)
	local C, Store, Stats, Keybinds = ctx.Components, ctx.Store, ctx.Stats, ctx.Keybinds
	local player = Players.LocalPlayer

	local header = C.Header(page, "Welcome back", "Your basketball training hub")
	local title = header:FindFirstChildWhichIsA("TextLabel") :: TextLabel
	Store.observe("Nickname", function(nickname)
		title.Text = "Welcome back, " .. (if nickname ~= "" then nickname else player.DisplayName)
	end)

	------------------------------------------------------------------ banner
	local banner = Create("Frame", {
		Name = "Banner",
		Size = UDim2.new(1, 0, 0, 118),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = page,
	}, { Create.corner(12), Create.accentGradient(20) })
	-- Dark wash so the text stays readable on any accent.
	Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		Parent = banner,
	}, {
		Create.corner(12),
		Create("UIGradient", {
			Transparency = NumberSequence.new(0, 0.9),
			Rotation = 0,
		}),
	})
	Create.text({
		Text = "JAYHUB  ·  PREMIUM SUITE",
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(220, 225, 255),
		Position = UDim2.fromOffset(20, 16),
		Size = UDim2.new(1, -40, 0, 12),
		Parent = banner,
	})
	Create.text({
		Text = "Train like a pro.",
		Font = Enum.Font.GothamBlack,
		TextSize = 26,
		TextColor3 = Color3.new(1, 1, 1),
		Position = UDim2.fromOffset(20, 32),
		Size = UDim2.new(1, -40, 0, 30),
		Parent = banner,
	})
	local bannerSub = Create.text({
		Text = "",
		TextSize = 12,
		TextColor3 = Color3.fromRGB(225, 228, 245),
		Position = UDim2.fromOffset(20, 66),
		Size = UDim2.new(1, -40, 0, 16),
		Parent = banner,
	})
	local cloud = Create.text({
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Color3.new(1, 1, 1),
		Position = UDim2.fromOffset(20, 88),
		Size = UDim2.new(1, -40, 0, 14),
		Parent = banner,
	})
	local function refreshBanner()
		bannerSub.Text = ("#%d  ·  %s  ·  %s-handed shooter"):format(
			Store.get("JerseyNumber"),
			Store.get("Position"),
			Store.get("ShootingHand")
		)
		cloud.Text = if Store.Persistent
			then "●  Cloud save enabled"
			elseif Store.Online then "●  Session only (DataStores unavailable)"
			else "●  Offline mode"
	end
	Store.observeMany({ "JerseyNumber", "Position", "ShootingHand" }, refreshBanner)

	------------------------------------------------------------------ stats
	local statsSection = C.Section(page, "Session", "Live numbers from the shot trainer")
	local grid = C.Grid(statsSection, 4, 66)
	local fg = C.StatTile(grid, { Title = "FG%" })
	local streak = C.StatTile(grid, { Title = "Streak" })
	local best = C.StatTile(grid, { Title = "Best streak" })
	local shots = C.StatTile(grid, { Title = "Shots" })
	local function refreshStats()
		local summary = Stats.session()
		fg:Set(("%d%%"):format(math.floor(summary.Percent + 0.5)), ("%d / %d made"):format(summary.Makes, summary.Attempts))
		streak:Set(tostring(summary.Streak), "makes in a row")
		best:Set(tostring(summary.BestStreak), "this session")
		shots:Set(tostring(summary.Attempts), ("%d perfect"):format(summary.Perfect))
	end
	Stats.Changed:Connect(refreshStats)
	refreshStats()

	------------------------------------------------------------------ actions
	local actions = C.Section(page, "Quick actions")
	local buttons = C.ButtonRow(actions, {
		{
			Text = "",
			Style = "Primary",
			Callback = function()
				Store.set("TrainerEnabled", not Store.get("TrainerEnabled"))
			end,
		},
		{
			Text = "Start drill",
			Callback = function()
				ctx.Notify.result(ctx.ShotTrainer.startDrill())
			end,
		},
	})
	local buttons2 = C.ButtonRow(actions, {
		{
			Text = "",
			Callback = function()
				Store.set("DribbleEnabled", not Store.get("DribbleEnabled"))
			end,
		},
		{
			Text = "",
			Callback = function()
				ctx.CameraSystem.cycleMode()
			end,
		},
	})
	Store.observe("TrainerEnabled", function(on)
		buttons[1]:SetText(if on then "Stop shot trainer" else "Start shot trainer")
	end)
	Store.observe("DribbleEnabled", function(on)
		buttons2[1]:SetText(if on then "Stop dribbling" else "Start dribbling")
	end)
	Store.observe("CameraMode", function(mode)
		buttons2[2]:SetText("Camera: " .. mode)
	end)

	------------------------------------------------------------------ controls
	local controls = C.Section(page, "Controls", "Change these in the Keybinds tab")
	local controlsText = C.Paragraph(controls, "")
	local function refreshControls()
		local lines = {}
		for _, entry in Keybinds.Actions do
			table.insert(
				lines,
				('<font color="#F1F3FA"><b>%s</b></font>   %s'):format(Keybinds.display(Keybinds.keyName(entry.Action)), entry.Label)
			)
		end
		table.insert(lines, "Touch: tap the JH button to open the menu and use the on-screen SHOOT button.")
		controlsText.Text = table.concat(lines, "\n")
	end
	Store.Changed:Connect(function(key)
		if string.sub(key, 1, 4) == "Key_" then
			refreshControls()
		end
	end)
	refreshControls()

	-- Cloud state is known only after Store.init, which may finish later.
	ctx.OnReady:Connect(refreshBanner)
	refreshBanner()
end
