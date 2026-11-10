--!nonstrict
-- Statistics tab: shooting numbers, grade breakdown and a timing chart.

local UI = script.Parent.Parent
local Create = require(UI.Create)
local Theme = require(UI.Parent.Core.Theme)

local T = Theme.T

local GRADE_TOKEN = { Perfect = "Success", Good = "Accent", Early = "Warning", Late = "Danger" }
local CHART_RANGE_MS = 150 -- bars are scaled to this timing error

return function(page: ScrollingFrame, ctx: any)
	local C, Stats, Notify = ctx.Components, ctx.Stats, ctx.Notify

	C.Header(page, "Statistics", "Every shot from the trainer, tracked")

	local view = "Session"
	local refresh: () -> ()
	local viewSection = C.Section(page, "View")
	C.Dropdown(viewSection, {
		Label = "Showing",
		Desc = "Lifetime totals are saved to your account",
		Options = { "Session", "Lifetime" },
		Default = "Session",
		Callback = function(choice: string)
			view = choice
			refresh()
		end,
	})

	------------------------------------------------------------------ tiles
	local overview = C.Section(page, "Overview")
	local grid = C.Grid(overview, 4, 66)
	local tiles = {
		Percent = C.StatTile(grid, { Title = "FG%" }),
		Makes = C.StatTile(grid, { Title = "Makes" }),
		Streak = C.StatTile(grid, { Title = "Streak" }),
		Best = C.StatTile(grid, { Title = "Best streak" }),
		PerfectPct = C.StatTile(grid, { Title = "Perfect %" }),
		AvgError = C.StatTile(grid, { Title = "Avg timing" }),
		Early = C.StatTile(grid, { Title = "Early" }),
		Late = C.StatTile(grid, { Title = "Late" }),
	}

	------------------------------------------------------------------ breakdown
	local breakdown = C.Section(page, "Release breakdown")
	local bars = {}
	for _, grade in { "Perfect", "Good", "Early", "Late" } do
		bars[grade] = C.Bar(breakdown, { Label = grade, Token = GRADE_TOKEN[grade] })
	end

	------------------------------------------------------------------ chart
	local chartSection = C.Section(page, "Recent releases", "Above the line = late, below = early. Faded bars missed.")
	local chart = Create("Frame", {
		Name = "Chart",
		Size = UDim2.new(1, 0, 0, 110),
		BackgroundColor3 = T.Surface,
		Parent = chartSection,
	}, { Create.corner(8), Create.stroke("Stroke", 1, 0.3) })
	Create("Frame", {
		Name = "Baseline",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Muted,
		BorderSizePixel = 0,
		Parent = chart,
	})
	local empty = Create.text({
		Text = "Take a few shots to see your timing here",
		TextSize = 12,
		TextColor3 = T.Muted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = chart,
	})
	local barHolder = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, -12),
		Position = UDim2.fromOffset(8, 6),
		Parent = chart,
	})

	local function renderChart()
		barHolder:ClearAllChildren()
		local history = Stats.history()
		empty.Visible = #history == 0
		local slots = Stats.HISTORY_SIZE
		for index, shot in history do
			local magnitude = math.clamp(math.abs(shot.ErrorMs) / CHART_RANGE_MS, 0.04, 1)
			local late = shot.ErrorMs > 0
			Create("Frame", {
				AnchorPoint = Vector2.new(0.5, if late then 1 else 0),
				Position = UDim2.new((index - 0.5) / slots, 0, 0.5, 0),
				Size = UDim2.new(1 / slots, -4, magnitude * 0.5, 0),
				BackgroundColor3 = T[GRADE_TOKEN[shot.Grade] or "Accent"],
				BackgroundTransparency = if shot.Made then 0 else 0.6,
				BorderSizePixel = 0,
				Parent = barHolder,
			}, { Create.corner(2) })
		end
	end

	------------------------------------------------------------------ refresh
	function refresh()
		local s = if view == "Lifetime" then Stats.lifetime() else Stats.session()
		tiles.Percent:Set(("%d%%"):format(math.floor(s.Percent + 0.5)), ("%d attempts"):format(s.Attempts))
		tiles.Makes:Set(tostring(s.Makes), ("of %d"):format(s.Attempts))
		tiles.Streak:Set(tostring(s.Streak), "current")
		tiles.Best:Set(tostring(s.BestStreak), string.lower(view))
		tiles.PerfectPct:Set(("%d%%"):format(math.floor(s.PerfectPercent + 0.5)), ("%d perfect"):format(s.Perfect))
		tiles.AvgError:Set(("%dms"):format(math.floor(s.AvgErrorMs + 0.5)), "average miss")
		tiles.Early:Set(tostring(s.Early), "releases")
		tiles.Late:Set(tostring(s.Late), "releases")

		local total = math.max(s.Attempts, 1)
		for grade, bar in bars do
			local count = s[grade] :: number
			bar:Set(count / total, ("%d  ·  %d%%"):format(count, math.floor(count / total * 100 + 0.5)))
		end
		renderChart()
	end

	Stats.Changed:Connect(refresh)
	refresh()

	------------------------------------------------------------------ reset
	-- Lifetime reset needs a second click within 3 seconds.
	local confirmUntil = 0
	local lifetimeButton: any
	local resetButtons = C.ButtonRow(page, {
		{
			Text = "Reset session",
			Callback = function()
				Stats.resetSession()
				Notify.success("Session stats cleared")
			end,
		},
		{
			Text = "Reset lifetime",
			Style = "Danger",
			Callback = function()
				if os.clock() < confirmUntil then
					confirmUntil = 0
					Stats.resetLifetime()
					lifetimeButton:SetText("Reset lifetime")
					Notify.success("Lifetime stats cleared")
				else
					confirmUntil = os.clock() + 3
					lifetimeButton:SetText("Click again to confirm")
					task.delay(3, function()
						if os.clock() >= confirmUntil then
							lifetimeButton:SetText("Reset lifetime")
						end
					end)
				end
			end,
		},
	})
	lifetimeButton = resetButtons[2]
end
