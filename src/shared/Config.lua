--!strict
-- Basketball configuration. Every gameplay number lives here so you can tune
-- the feel of the game without touching the scripts.
-- Distances are in studs (roughly 1 stud = 0.3 m for a default character).

local Config = {}

---------------------------------------------------------------------------
-- Court & hoops
---------------------------------------------------------------------------
-- If no parts/models tagged with HoopTag exist when the server starts, a
-- full court with two hoops is generated at CourtOrigin.
Config.AutoBuildCourt = true
Config.CourtOrigin = Vector3.new(0, 0, 0) -- top surface of the floor
Config.CourtLength = 94 -- along X
Config.CourtWidth = 50 -- along Z
Config.RimHeight = 10
Config.RimRadius = 1.6 -- inner radius of the ring
Config.HoopTag = "BasketballHoop" -- CollectionService tag for custom hoops

---------------------------------------------------------------------------
-- Ball
---------------------------------------------------------------------------
Config.BallName = "Basketball"
Config.BallTag = "BasketballBall" -- CollectionService tag the client uses to find the ball
Config.BallDiameter = 1.5
Config.BallColor = Color3.fromRGB(226, 104, 32)
Config.BallDensity = 0.6
Config.BallFriction = 0.5
Config.BallElasticity = 0.72
Config.KillY = -50 -- ball respawns at center court below this height
Config.IdleResetTime = 60 -- seconds a loose, motionless ball waits before respawning (0 = never)

---------------------------------------------------------------------------
-- Possession & dribbling
---------------------------------------------------------------------------
Config.PickupRadius = 3.5 -- how close a loose ball must be to grab it
Config.ShooterRegrabDelay = 0.75 -- shooter/passer can't instantly re-grab the ball
Config.DribbleRate = 9 -- higher = faster dribble
Config.DribbleSide = 1.1 -- how far to the right of the player the ball bounces
Config.DribbleForward = 1.3
Config.HoldOverheadOffset = CFrame.new(0, 2.6, -0.9) -- ball position while loading a shot

---------------------------------------------------------------------------
-- Shooting
---------------------------------------------------------------------------
Config.MeterFillTime = 0.9 -- seconds for the meter to go from empty to full
Config.MeterAutoRelease = 1.1 -- held this long = forced (late) release
Config.PerfectCenter = 0.85 -- where the "green" release sits on the meter (0-1)
Config.PerfectWindow = 0.05 -- +/- around PerfectCenter that counts as perfect
Config.GoodWindow = 0.13 -- +/- around PerfectCenter that counts as good
Config.MaxMissOffset = 3.6 -- how far (studs) the worst shot lands from the rim center
Config.ThreePointDistance = 22 -- shots taken from farther than this are worth 3
Config.DeepRange = 32 -- accuracy starts falling off past this distance
Config.DeepRangeFalloff = 25 -- studs past DeepRange until a shot is fully random
Config.ContestRadius = 6 -- defenders this close in front of the shooter contest the shot
Config.ContestPenalty = 0.3 -- added "badness" when contested (0-1 scale)
Config.ShotCooldown = 0.5
Config.JumpOnShot = true
Config.ReleaseOffset = Vector3.new(0, 3, -1.2) -- relative to HumanoidRootPart
Config.MinArc = 4 -- apex height above the higher of release/rim, short shots
Config.MaxArc = 12
Config.ArcPerStud = 0.16 -- extra arc per stud of shot distance
Config.Backspin = 10

---------------------------------------------------------------------------
-- Passing & stealing
---------------------------------------------------------------------------
Config.PassRange = 60
Config.PassMaxAngle = 65 -- degrees from where you face; receivers outside this are ignored
Config.PassSpeed = 60 -- studs/second
Config.TeamsMatter = true -- if players are on Teams: pass only to teammates, steal only from opponents
Config.StealRange = 6
Config.StealChance = 0.35
Config.StealCooldown = 1.5

---------------------------------------------------------------------------
-- Controls (keyboard, gamepad; mobile gets on-screen buttons automatically)
---------------------------------------------------------------------------
Config.Keys = {
	Shoot = { Enum.KeyCode.E, Enum.KeyCode.ButtonX },
	Pass = { Enum.KeyCode.Q, Enum.KeyCode.ButtonY },
	Steal = { Enum.KeyCode.F, Enum.KeyCode.ButtonB },
}

return Config
