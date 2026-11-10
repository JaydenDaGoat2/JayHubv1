--!strict
-- Shared math used by both server (authoritative) and client (meter display).

local Config = require(script.Parent.Config)

local BallMath = {}

export type Grade = "Perfect" | "Good" | "Early" | "Late"

-- Meter value (0-1) for how long the shot button has been held.
function BallMath.meterValue(elapsed: number): number
	return math.clamp(elapsed / Config.MeterFillTime, 0, 1)
end

-- Turns a meter value into a grade and a "badness" from 0 (pure) to 1 (brick).
function BallMath.gradeRelease(value: number): (Grade, number)
	local err = value - Config.PerfectCenter
	local absErr = math.abs(err)

	if absErr <= Config.PerfectWindow then
		return "Perfect", 0
	end

	if absErr <= Config.GoodWindow then
		-- Small offsets: usually drops, sometimes rattles out.
		local t = (absErr - Config.PerfectWindow) / (Config.GoodWindow - Config.PerfectWindow)
		return "Good", t * 0.35
	end

	local grade: Grade = if err < 0 then "Early" else "Late"
	return grade, math.clamp(0.35 + (absErr - Config.GoodWindow) / 0.25, 0.35, 1)
end

-- Extra badness for shooting from very deep.
function BallMath.distancePenalty(distance: number): number
	if distance <= Config.DeepRange then
		return 0
	end
	return math.clamp((distance - Config.DeepRange) / Config.DeepRangeFalloff, 0, 1)
end

-- Initial velocity that sends a projectile from `from` to `to` in `flightTime` seconds.
function BallMath.velocityForTime(from: Vector3, to: Vector3, flightTime: number, gravity: number): Vector3
	local g = Vector3.new(0, -gravity, 0)
	return (to - from - 0.5 * g * flightTime * flightTime) / flightTime
end

-- Initial velocity for a shot that peaks `arc` studs above the higher of the
-- two points, then comes down onto `to`. Returns velocity and flight time.
function BallMath.velocityForArc(from: Vector3, to: Vector3, arc: number, gravity: number): (Vector3, number)
	local apex = math.max(from.Y, to.Y) + arc
	local up = math.sqrt(2 * gravity * (apex - from.Y))
	local timeUp = up / gravity
	local timeDown = math.sqrt(2 * (apex - to.Y) / gravity)
	local flightTime = timeUp + timeDown

	local flat = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
	return flat / flightTime + Vector3.new(0, up, 0), flightTime
end

function BallMath.arcForDistance(distance: number): number
	return math.clamp(Config.MinArc + distance * Config.ArcPerStud, Config.MinArc, Config.MaxArc)
end

function BallMath.flatDistance(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

return BallMath
