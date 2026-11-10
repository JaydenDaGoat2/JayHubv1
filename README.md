# JayHub – Basketball Suite

A training hub for **your own** Roblox basketball experience, written in Luau and synced into Studio with [Rojo](https://rojo.space). It includes a shot timing trainer, a practice dribble, camera modes, court styling, rebindable keys, stats tracking and cloud-saved configurations, all inside a dark, animated UI that works on PC, console and mobile.

## Features

| Tab | What it does |
| --- | --- |
| **Home** | Welcome banner with your profile, live session stats, quick actions (trainer, drill, dribble, camera) and a list of your current controls |
| **Shot Trainer** | Hold-and-release meter graded **Perfect / Good / Early / Late** with the offset in ms. Three difficulties, adjustable fill time, vertical or horizontal meter, auto release, a practice ball that flies at the nearest hoop, and a timed drill mode with a session best |
| **Player Settings** | Nickname (filtered by `TextService`), jersey number, position, shooting hand, a nameplate everyone can see (with your colour), and walk speed (the server enforces the limits) |
| **Dribble Settings** | Practice ball with speed, height, starting hand, style (Standard / Low / Speed), manual and automatic crossovers, ball colour and trail |
| **Camera Settings** | Default, Shoulder, Broadcast (sideline) and Overhead modes, FOV, smoothing, shoulder offset, distance, max zoom, and shot shake with adjustable intensity |
| **Court Customization** | Floor colour and material, line colour, neon lines, rim colour, backboard transparency and lighting presets. Only you see these changes, and turning the option off restores the original court |
| **Keybinds** | Rebind every action. Esc cancels, Backspace unbinds, and conflicts and reserved keys are blocked. The tab also lists the fixed gamepad buttons and touch controls |
| **Statistics** | Session or lifetime FG%, makes, streak, best streak, perfect %, average timing error, a grade breakdown and a chart of your last 24 releases. Reset session, or reset lifetime (asks you to confirm) |
| **Configuration** | Theme presets (JayHub, Neon Violet, Arctic, Crimson, Emerald, Solar, Custom), custom accent colours, UI scale, transparency, animations, background blur, notifications, auto save, **Save now**, three named configuration slots (save / load / delete), import and export codes, and a full reset |

**Window:** you can drag it by the title bar and resize it from the corner grip. It also has minimize and close buttons and an animated accent border. It scales itself to fit small screens. A draggable **JH** button reopens it (always shown on touch devices). Toasts confirm every action.

## Project layout

```
src/
  shared/                          -> ReplicatedStorage.Basketball
    Config.lua                     gameplay + JayHub server options (Config.JayHub)
    BallMath.lua                   projectile math (used by the practice ball)
    JayHub/
      Schema.lua                   every setting: type, default, limits + validation
      Timing.lua                   shot grading rules and difficulty windows
      Signal.lua
  server/                          -> ServerScriptService.Basketball
    CourtBuilder.lua               generates a court + hoops if the place has none
    JayHubService.server.lua       DataStore saving, slots, stats, nameplate, walk speed
  client/                          -> StarterPlayerScripts.Basketball (LocalScript)
    init.client.lua                bootstrap
    Core/     Store, Theme, Notify, Keybinds
    UI/       Window, Components, Create, Tween
    UI/Tabs/  one module per tab
    Systems/  ShotTrainer, Stats, DribbleSystem, CameraSystem, CourtSystem
```

## Setup

1. Install Rojo, run `rojo serve` in this folder, and connect from the Rojo plugin in Studio.
2. For saving in Studio: **Game Settings → Security → Enable Studio Access to API Services**.
3. Press Play. JayHub opens automatically. Use **RightShift** (or tap **JH**) to toggle it.

If your place has no parts tagged `BasketballHoop`, the server builds a full court at the origin (`Config.AutoBuildCourt`).

### Default controls

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Toggle menu | RightShift | Select |
| Shoot (hold / release) | E | X |
| Toggle shot trainer | T | D-pad up |
| Toggle dribble | G | D-pad down |
| Crossover | Q | L1 |
| Cycle camera | C | D-pad right |

## How it fits together

- **One schema, validated twice.** `Schema.lua` describes every setting. The client checks each change before applying it, and the server sanitizes everything it receives, so a bad value is never applied or saved. Unknown keys are dropped.
- **Controls bind to settings.** `Components.Toggle(section, { Label = "...", Key = "ShotShake" })` reads the value, writes changes through the Store and updates itself when the value changes elsewhere (slot load, import, reset). A new setting needs one schema entry and one line in a tab.
- **Systems observe the Store.** `Store.observe("FieldOfView", fn)` runs right away and again on every change, so the camera, court, dribble and trainer respond to slider changes immediately.
- **Saving.** Changes sync to the server about 1.5 s after the last edit. With **Auto save** on they are written to the DataStore in the background (every 2 minutes, on leave and on shutdown). With it off they stay live but are only written when you press **Save now**. If loading fails, the server never overwrites your data, and the UI shows *Session only*.
- **Error handling.** DataStore calls retry 3 times. Remote requests are rate limited and wrapped in `pcall`. Every control callback, signal handler, tab build and per-frame update is protected, so one failure is reported in the output and doesn't break the rest of the hub.

### Server options (`Config.JayHub`)

```lua
DataStoreName = "JayHub_PlayerData_v1",
AutosaveInterval = 120,
ManualSaveCooldown = 15,
RequestsPerWindow = 30, RequestWindow = 10,
AllowWalkSpeed = true,   -- false hides the slider and keeps the default speed
NameplateDistance = 70,
```

### Reading player choices from your own scripts

```lua
player:GetAttribute("JayHubNickname")    -- filtered text, "" if none
player:GetAttribute("JerseyNumber")
player:GetAttribute("PreferredPosition") -- "PG" | "SG" | "SF" | "PF" | "C"
player:GetAttribute("ShootingHand")      -- "Right" | "Left"
```

## Scope

JayHub runs inside a game you own or are authorized to edit. The trainer's shots, the practice ball and the court styling exist only on the player's own client. Lifetime stats come from that client too, so treat them as practice numbers, not competitive records. JayHub contains no executor support, auto-timing or auto-release, and no code that changes another game's gameplay.
