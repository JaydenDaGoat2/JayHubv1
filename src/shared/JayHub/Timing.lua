--!strict
-- Shot timing rules for the JayHub shot trainer.
-- The meter fills from 0 to 1 over `fillTime` seconds; the ideal release sits
-- at `Center`. A release is graded by how far it lands from that point.

local Timing = {}

export type Grade = "Perfect" | "Good" | "Early" | "Late"

export type Result = {
	Grade: Grade,
	Made: boolean,
	ErrorMs: number, -- signed: negative = early, positive = late
	Value: number, -- meter value at release (0-1)
}

Timing.Center = 0.85

-- Half-widths of each window, as a fraction of the meter.
Timing.Difficulties = {
	Rookie = { Perfect = 0.07, Good = 0.16 },
	Pro = { Perfect = 0.045, Good = 0.12 },
	Elite = { Perfect = 0.025, Good = 0.08 },
} :: { [string]: { Perfect: number, Good: number } }

-- How often each grade drops. Perfect always goes in.
Timing.GoodMakeChance = { Max = 0.85, Min = 0.45 }
Timing.MissMakeChance = 0.1

function Timing.windows(difficulty: string): { Perfect: number, Good: number }
	return Timing.Difficulties[difficulty] or Timing.Difficulties.Pro
end

-- `rng` is optional so the result can be made deterministic in tests.
function Timing.grade(value: number, fillTime: number, difficulty: string, rng: Random?): Result
	local windows = Timing.windows(difficulty)
	local err = value - Timing.Center
	local absErr = math.abs(err)
	local errorMs = math.floor(err * fillTime * 1000 + 0.5)
	local roll = (rng or Random.new()):NextNumber()

	local grade: Grade
	local made: boolean
	if absErr <= windows.Perfect then
		grade = "Perfect"
		made = true
	elseif absErr <= windows.Good then
		grade = "Good"
		-- Closer to the perfect window = more likely to drop.
		local t = (absErr - windows.Perfect) / (windows.Good - windows.Perfect)
		local chance = Timing.GoodMakeChance.Max - (Timing.GoodMakeChance.Max - Timing.GoodMakeChance.Min) * t
		made = roll < chance
	else
		grade = if err < 0 then "Early" else "Late"
		made = roll < Timing.MissMakeChance
	end

	return { Grade = grade, Made = made, ErrorMs = errorMs, Value = value }
end

return Timing
