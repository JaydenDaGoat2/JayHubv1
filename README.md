# JayHub Basketball

A complete basketball system for **your own** Roblox place, written in Luau and synced with [Rojo](https://rojo.space).

## Features

- **Auto-built court**: two hoops with real rim collision, three-point arcs, keys and a center circle. Skipped if your place already has tagged hoops.
- **Dribbling**: the ball is welded to the holder and animated on every client, so it looks smooth for everyone.
- **Timing-based shooting**: hold the shoot key to fill the meter and release in the green. The **server** times the release, so a modified client can't fake perfect shots.
  - Perfect release with no defender and from normal range: a clean swish.
  - Good, early or late release: the ball lands further from the rim center, and physics decides whether it rattles in.
  - Contested shots (an opponent within `ContestRadius`, between you and the hoop) and deep shots are less accurate.
  - Twos and threes come from `ThreePointDistance`.
- **Passing**: passes to the best teammate in front of you, leading them if they're running.
- **Stealing**: a chance-based steal from a nearby opponent, with a cooldown.
- **Scoring**: `leaderstats.Points` for each player, plus a `Score` attribute on each Team when `TeamsMatter` is on.
- **Controls**: keyboard (E/Q/F), gamepad (X/Y/B), and on-screen buttons on mobile.
- **Ball upkeep**: the ball respawns after falling off the map or sitting idle, and drops when its holder dies or leaves.

## Layout

```
src/shared/   -> ReplicatedStorage.Basketball
  Config.lua        every tuning number
  BallMath.lua      meter grading + projectile math
  Remotes.lua       RemoteEvents
src/server/   -> ServerScriptService.Basketball
  Main.server.lua   entry point
  BallService.lua   possession, shooting, passing, stealing, scoring
  CourtBuilder.lua  generated court
src/client/   -> StarterPlayerScripts.Basketball
  Main.client.lua   input + feedback
  HUD.lua           shot meter and toasts
  BallRenderer.lua  dribble / overhead animation
```

## Setup

1. `rojo serve`, then connect from the Rojo plugin in Studio.
2. Press Play. Walk to the ball at center court to pick it up.

## Custom hoops

Tag a Model with `BasketballHoop` (CollectionService). It needs a part named `RimCenter`, or a PrimaryPart, at the center of the ring. Name the ring's collision parts `Rim` so clean perfects can pass through them.

## With the Practical Basketball shot trainer

If the Practical Basketball UI project (`ReplicatedStorage.Shared.ShotEvents`) is in the same place, every shot is reported to its trainer HUD automatically.
