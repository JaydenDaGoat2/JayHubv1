--!nonstrict
-- Shooting statistics for this session and across sessions (lifetime).
-- Lifetime totals are sent to the server a few seconds after they change.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JayHubShared = ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))
local Signal = require(JayHubShared:WaitForChild("Signal"))
local Store = require(script.Parent.Parent.Core.Store)

local Stats = {}

export type ShotResult = { Grade: string, Made: boolean, ErrorMs: number, Value: number }
export type Summary = {
	Attempts: number,
	Makes: number,
	Percent: number,
	Perfect: number,
	Good: number,
	Early: number,
	Late: number,
	Streak: number,
	BestStreak: number,
	AvgErrorMs: number,
	PerfectPercent: number,
}

Stats.Changed = Signal.new() -- (lastResult?)
Stats.HISTORY_SIZE = 24

local session = Schema.emptyStats()
local lifetime = Schema.emptyStats()
local streak = 0
local history: { ShotResult } = {}
local saveScheduled = false

local function scheduleSave()
	if saveScheduled then
		return
	end
	saveScheduled = true
	task.delay(6, function()
		saveScheduled = false
		local reply = Store.request("SaveStats", lifetime)
		if not reply.Ok and Store.Online then
			warn("[JayHub] Saving stats failed:", reply.Message)
		end
	end)
end

-- Merges saved lifetime totals with anything recorded before they arrived.
function Stats.load(saved: { [string]: number }?)
	local loaded = Schema.sanitizeStats(saved)
	for _, field in Schema.StatFields do
		if field == "BestStreak" then
			loaded[field] = math.max(loaded[field], lifetime[field])
		else
			loaded[field] += lifetime[field]
		end
	end
	lifetime = loaded
	Stats.Changed:Fire(nil)
end

local function add(target: { [string]: number }, result: ShotResult, currentStreak: number)
	target.Attempts += 1
	if result.Made then
		target.Makes += 1
	end
	target[result.Grade] = (target[result.Grade] or 0) + 1
	target.TotalErrorMs += math.abs(result.ErrorMs)
	target.BestStreak = math.max(target.BestStreak, currentStreak)
end

function Stats.record(result: ShotResult)
	streak = if result.Made then streak + 1 else 0
	add(session, result, streak)
	add(lifetime, result, streak)

	table.insert(history, result)
	while #history > Stats.HISTORY_SIZE do
		table.remove(history, 1)
	end

	Stats.Changed:Fire(result)
	scheduleSave()
end

local function summarize(source: { [string]: number }, currentStreak: number): Summary
	local attempts = source.Attempts
	return {
		Attempts = attempts,
		Makes = source.Makes,
		Percent = if attempts > 0 then source.Makes / attempts * 100 else 0,
		Perfect = source.Perfect,
		Good = source.Good,
		Early = source.Early,
		Late = source.Late,
		Streak = currentStreak,
		BestStreak = source.BestStreak,
		AvgErrorMs = if attempts > 0 then source.TotalErrorMs / attempts else 0,
		PerfectPercent = if attempts > 0 then source.Perfect / attempts * 100 else 0,
	}
end

function Stats.session(): Summary
	return summarize(session, streak)
end

function Stats.lifetime(): Summary
	return summarize(lifetime, streak)
end

function Stats.history(): { ShotResult }
	return table.clone(history)
end

function Stats.streak(): number
	return streak
end

function Stats.resetSession()
	session = Schema.emptyStats()
	streak = 0
	table.clear(history)
	Stats.Changed:Fire(nil)
end

function Stats.resetLifetime()
	lifetime = Schema.emptyStats()
	Stats.Changed:Fire(nil)
	scheduleSave()
end

return Stats
