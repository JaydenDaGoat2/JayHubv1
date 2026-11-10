# JayHub Basketball

Rojo project for a Roblox basketball game: shared config and shot math, a server court builder, and a client menu.

## Menu UI (`src/client`)

| File | What it does |
| --- | --- |
| `UI/Theme.lua` | Colors, accent options, fonts, sizes. Change these to restyle everything at once |
| `UI/Library.lua` | The UI library: draggable window, sidebar tabs, section cards, toggle, slider, dropdown, keybind, text box, button, label, notifications |
| `Settings.lua` | Client settings store (`Get` / `Set` / `Observe`) that other client scripts can read |
| `init.client.lua` | Builds the menu (Gameplay, Controls, Interface, About tabs) and applies settings |

Press **RightShift** to show or hide the menu. Touch devices get a ☰ button. The window shrinks itself to fit small screens.

### Using the library

```lua
local Library = require(script.UI.Library)

local window = Library.new({ Title = "JayHub", Subtitle = "Basketball" })
local section = window:AddTab("Gameplay"):AddSection("Shooting")

local meter = section:AddToggle({ Text = "Show shot meter", Default = true, Callback = function(on) end })
section:AddSlider({ Text = "Meter size", Min = 0.5, Max = 1.5, Step = 0.05, Default = 1, Suffix = "x" })
section:AddDropdown({ Text = "Mode", Options = { "Casual", "Ranked" }, Callback = print })
section:AddKeybind({ Text = "Shoot", Default = Enum.KeyCode.E, Callback = print })
section:AddButton({ Text = "Reset", Callback = function() meter:Set(true) end })

window:Notify({ Title = "Saved", Text = "Settings updated", Type = "Success" })
window:SetAccent(Color3.fromRGB(240, 128, 48))
```

Every control returns an object with `:Get()` and `:Set(value, silent)`.

## Setup

Run `rojo serve`, connect from the Rojo plugin in Studio, and press Play.
