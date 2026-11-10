# JayHub Basketball

A practical, server-authoritative basketball system for Roblox: dribbling,
timed jump shots with a release meter, contests, passing, stealing, scoring,
and an auto-generated court.

## Setup

**With Rojo:** `rojo serve` and connect from Studio (see `default.project.json`).

**Manually in Studio:**

| Source | Put it in | As |
| --- | --- | --- |
| `src/shared/Config.lua`, `BallMath.lua` | `ReplicatedStorage/Basketball` (Folder) | ModuleScripts |
| `src/server/CourtBuilder.lua` | `ServerScriptService/Basketball` (Folder) | ModuleScript |
| `src/server/Main.server.lua` | `ServerScriptService/Basketball` | Script named `Main` |
| `src/client/Ui.lua` | `StarterPlayer/StarterPlayerScripts/Basketball` (Folder) | ModuleScript |
| `src/client/Main.client.lua` | `StarterPlayer/StarterPlayerScripts/Basketball` | LocalScript named `Main` |

Press Play: a full court with two hoops is built at the origin if your place
has no hoops tagged `BasketballHoop`.

## Controls

| Action | Keyboard | Gamepad | Mobile |
| --- | --- | --- | --- |
| Shoot (hold, release in the green) | E | X | Shoot button |
| Pass (to the teammate you face) | Q | Y | Pass button |
| Steal (near the ball handler) | F | B | Steal button |

Walk over a loose ball to pick it up.

## How it works

- **Shot meter:** releasing in the green is a *Perfect* (pure swish), yellow is
  *Good* (usually drops), otherwise *Early* (short) or *Late* (long). Holding
  too long forces a late release.
- Accuracy also drops for very deep shots and when a defender is in front of
  you (*Contested*). Shots beyond the three-point line are worth 3.
- Points go to `leaderstats.Points`; with Teams, each Team also gets a
  `Score` attribute. Passing goes only to teammates and stealing only works on
  opponents when players are on Teams (`Config.TeamsMatter`).
- Every number (meter speed, windows, arc, steal chance...) is in
  `src/shared/Config.lua`.

## Custom hoops

Tag your hoop Model with `BasketballHoop` (CollectionService) and put a small
part named `RimCenter` at the middle of the ring. Optionally set a
`RimRadius` number attribute on the model. The rim needs collidable parts for
the ball to bounce off.
