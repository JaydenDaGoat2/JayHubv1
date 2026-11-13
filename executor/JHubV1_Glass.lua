--[[
     _ _   _       _       __     ___
    | | | | |_   _| |__    \ \   / / |
 _  | | |_| | | | | '_ \    \ \ / /| |
| |_| |  _  | |_| | |_) |    \ V / | |
 \___/|_| |_|\__,_|_.__/      \_/  |_|

    JHub V1 - Glass  |  Practical Basketball
    Delta (iPhone / Android) + PC

    Tabs: Main, Shooting, Dribbling, Players, UI
    Tap the moving JH logo to open / close the menu.
]]

local JH_SOURCE = [==[
local function JHubMain()
local genv = (getgenv and getgenv()) or shared or _G
local launchedByAuto = genv.JHUB_AUTOEXEC
genv.JHUB_AUTOEXEC = nil
if launchedByAuto then
if not game:IsLoaded() then game.Loaded:Wait() end
local okf, txt = pcall(function() return readfile("JHubGlass/settings.json") end)
if okf and type(txt) == "string" and not string.find(txt, '"AutoExec":true', 1, true) then return end
end
for _, key in ipairs({ "JHubGlass", "JHubV1", "JayHubPB" }) do
local old = genv[key]
if type(old) == "table" and type(old.Unload) == "function" then
pcall(old.Unload)
end
genv[key] = nil
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)
local LP = Players.LocalPlayer
while not LP do
task.wait()
LP = Players.LocalPlayer
end
local WHITE = Color3.new(1, 1, 1)
local MB1 = Enum.UserInputType.MouseButton1
local TOUCH = Enum.UserInputType.Touch
local MMOVE = Enum.UserInputType.MouseMovement
local KEYBOARD = Enum.UserInputType.Keyboard
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
local VERSION = "v1.27 shot-line"
local JH = { Connections = {}, Running = true, Logs = {}, Start = tick(), FPS = 60 }
genv.JHubGlass = JH
local function cam() return workspace.CurrentCamera end
local function bind(signal, fn)
local c = signal:Connect(fn)
table.insert(JH.Connections, c)
return c
end
local function log(msg)
msg = tostring(msg)
table.insert(JH.Logs, 1, os.date("%H:%M:%S") .. "  " .. msg)
if #JH.Logs > 60 then table.remove(JH.Logs) end
if JH.RecLog then JH.RecLog(msg) end
print("[JHub] " .. msg)
end
local function clamp(v, a, b)
if v < a then return a elseif v > b then return b end
return v
end
local function trim(s) return (string.gsub(s or "", "^%s*(.-)%s*$", "%1")) end
local function tokens(s)
local out = {}
for t in string.gmatch(s or "", "[^%s,]+") do table.insert(out, t) end
return out
end
local function matchAny(s, words)
for _, w in ipairs(words) do
if string.find(s, w, 1, true) then return true end
end
return false
end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function new(class, props)
local o = Instance.new(class)
local parent
if props then
for k, v in pairs(props) do
if k == "Parent" then parent = v else o[k] = v end
end
end
if parent then o.Parent = parent end
return o
end
local function visibleChain(g)
local o = g
while o and o ~= game do
if o:IsA("GuiObject") and not o.Visible then return false end
if o:IsA("LayerCollector") then return o.Enabled end
o = o.Parent
end
return true
end
local function char()
local c = LP.Character
if c then return c end
local f = workspace:FindFirstChild("Characters")
return f and f:FindFirstChild(LP.Name)
end
local function hrp() local c = char() return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end
local function hum() local c = char() return c and c:FindFirstChildOfClass("Humanoid") end
local function insetHeight()
local ok, v = pcall(function() return (GuiService:GetGuiInset()) end)
return (ok and v) and v.Y or 0
end
local UI, Net, Input, Ball, Shot, Backup, Glide, Anim, Speed, Feat, Picker, Bar, Mover, Rec =
{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
local function notify(title, msg, dur) if UI.notify then UI.notify(title, msg, dur) end end
local S = {
WinTrans = 0.5, CardTrans = 0.78, Hue = 212, Sat = 0.85, Val = 0.85, WinGradient = true,
OutlineColor = "White", OutlineThick = 2, OutlineShine = true,
TextColor = "White", TextStroke = true, Font = "Gotham", Corner = 10, UIScale = 1,
LogoSize = 58, LogoOpacity = 1, LogoAnim = true, LogoX = -1, LogoY = -1,
Blur = false, BlurSize = 10, Watermark = true, Notifications = true, Sounds = true, MenuKey = "RightShift",
Codes = "100M RELEASE 100KLIKES 500KMEMBERS SORRYFORBUGS", CodeRemotes = true,
AutoGreen = true, AutoCalibrate = true, AutoTiming = true, ShotRelease = "Auto",
HoldTime = 0.55, MaxHold = 1.6, CalSpeed = 0.6, CalStep = 0.02,
ShotTimes = "", ShotRatio = 0, BarPath = "", BarProp = "", BarAt = 0, BarNudge = 0,
ShotStyle = "Hold", AutoExec = false, BallMagnet = false, MagnetMode = "Pull to me", MagnetRange = 60, Learn = false, DetNotify = false, PerfectGreen = false, PerfectGreenPct = 100, AutoCal = true, AutoTimes = "", Sweep = false, MagnetFrames = 1, LogoOn = false, Logo = "Owner", MascotOn = false, Mascot = "SpongeBob", MaxOverall = false, MaxCoins = false, MaxBadges = false, MeterAim = false, MeterTarget = 1.0, MeterBin = 0.05, Lightning = true, BoltCount = 6, BoltSpeed = 1, BoltThick = 2, BoltBright = 0.9, BoltColor = "White + Yellow", BgMove = true, BgGlow = 0.5, BgOrbs = true, AccentMode = "Gold", OutlineSpeed = 1, LogoStyle = "J bolt H", LogoBg = true, Preset = "Lightning Gold", PacketOn = true, PacketMul = 1,
MovingOffset = 0, SprintOffset = 0, PingComp = 0, Humanize = 0, Nudge = 0, GreenSound = true,
HookShootButton = true, ShootButtonPath = "", ReleaseMethod = "Both", FireClick = true,
ManualAssist = true, ShootKey = "E", SprintKey = "LeftShift",
BackupButton = false, BackupMethod = "touch", BackupInset = false,
DribbleGlide = false, DribbleGlidePower = 30, DribbleGlideTime = 0.45, GlideSpeed = 1,
ShotGlide = false, ShotGlidePower = 22, ShotGlideTime = 0.45,
GatherGlide = false, GatherGlidePower = 26, GatherGlideTime = 0.45,
GlideFade = 60, GlideSmart = true, GlideStopAtWalls = false, GlideNeedBall = true, GlideMethod = "Auto",
DribbleKeys = "Z C X V", GatherKeys = "", DribbleBtnPaths = "", GatherBtnPaths = "",
AnimDribble = "", AnimGather = "", AnimShot = "",
SpeedOn = false, SpeedAdd = 4, SpeedMult = 1, BallSpeedOn = false, BallAdd = 4, BallMult = 1,
RunOn = false, RunAdd = 4, RunMult = 1, RecShots = false, RunDetect = "Auto", SettingsVer = 0, RecOn = false,
SpeedChannel = "Auto", SpeedCap = 40, AntiRubber = false, ForceBall = false, HoldDist = 6, BallName = "auto",
AutoSprint = false, InfStamina = false,
}
local DEFAULTS = {}
for k, v in pairs(S) do DEFAULTS[k] = v end
local FS = { root = "JHubGlass" }
FS.file = FS.root .. "/settings.json"
FS.ok = type(writefile) == "function" and type(readfile) == "function"
function FS.ensure()
if type(makefolder) ~= "function" or type(isfolder) ~= "function" then return end
pcall(function()
if not isfolder(FS.root) then makefolder(FS.root) end
end)
end
function FS.write(path, text)
if not FS.ok or not text then return end
FS.ensure()
pcall(writefile, path, text)
end
function FS.read(path)
if not FS.ok then return nil end
local ok, r = pcall(function()
if type(isfile) == "function" and not isfile(path) then return nil end
return readfile(path)
end)
if ok then return r end
return nil
end
local function decode(str)
if not str or str == "" then return nil end
local ok, r = pcall(function() return HttpService:JSONDecode(str) end)
if ok then return r end
return nil
end
local function applyData(data)
if type(data) ~= "table" then return end
for k, v in pairs(data) do
if S[k] ~= nil and type(S[k]) == type(v) then S[k] = v end
end
end
applyData(decode(FS.read(FS.file)))
if S.SettingsVer < 3 then
for _, k in ipairs({ "DribbleGlidePower", "DribbleGlideTime", "ShotGlidePower", "ShotGlideTime", "GatherGlidePower",
"GatherGlideTime", "SpeedChannel", "GlideMethod", "GlideStopAtWalls", "SpeedAdd", "BallAdd" }) do
S[k] = DEFAULTS[k]
end
end
if S.SettingsVer < 4 then
for _, k in ipairs({ "ShootButtonPath", "BarPath", "BarProp", "BarAt", "ShotTimes", "ShotRatio", "PacketMul", "PacketOn", "HoldTime",
"SpeedChannel", "GlideMethod" }) do
S[k] = DEFAULTS[k]
end
end
if S.SettingsVer < 5 then
S.InfStamina, S.AutoSprint = false, false
end
if S.SettingsVer < 6 then
S.SpeedAdd, S.RunAdd, S.BallAdd, S.ForceBall = 4, 4, 4, false
end
if S.SettingsVer < 7 then
S.DribbleGlidePower, S.DribbleGlideTime, S.ShotGlidePower, S.ShotGlideTime = 10, 0.35, 6, 0.4
S.GatherGlidePower, S.GatherGlideTime, S.GlideSpeed, S.GlideNeedBall = 10, 0.4, 1, true
end
if S.SettingsVer < 8 then
S.DribbleGlidePower, S.ShotGlidePower, S.GatherGlidePower, S.GlideSpeed, S.AntiRubber = 18, 12, 16, 1, false
end
if S.SettingsVer < 9 then
S.DribbleGlidePower, S.DribbleGlideTime, S.ShotGlidePower, S.ShotGlideTime = 30, 0.45, 22, 0.45
S.GatherGlidePower, S.GatherGlideTime = 26, 0.45
end
if S.SettingsVer < 10 then
S.MeterTarget, S.MeterBin, S.MeterAim = 1.0, 0.05, false
end
if S.SettingsVer < 13 then
S.MeterAim = false
local old = {}
for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do if key ~= "15851912457+15851919155" and key ~= "15851912457+15851919155+17285155256" then old[#old + 1] = key .. "=" .. val end end
S.ShotTimes = table.concat(old, " ")
local seeds = "r:15851912457+15851919155=1.327 r:15851912457+15851919155+17285155256=1.327 16205020756=0.343 16246923753=0.335 118403922040694=0.315 15997667717=0.365 16143612725=0.355 16143619816=0.355 84063020888988=0.335 138932071140330=0.322 111074210919383=0.414 71484695722621=0.414"
local have = {}
for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do have[key] = val end
for key, val in string.gmatch(seeds, "(%S+)=([%d%.]+)") do have[key] = val end
local parts = {}
for key, val in pairs(have) do parts[#parts + 1] = key .. "=" .. val end
table.sort(parts)
S.ShotTimes = table.concat(parts, " ")
end
if S.AutoCal == nil then S.AutoCal = true end
if S.PerfectGreen == nil then S.PerfectGreen = false end
if S.DetNotify == nil then S.DetNotify = false end
if S.PerfectGreenPct == nil then S.PerfectGreenPct = 100 end
if S.AutoTimes == nil then S.AutoTimes = "" end
if S.SettingsVer < 14 then
if S.MagnetMode == "Pull the ball" then S.MagnetMode = "Pull to me" end
end
if S.SettingsVer < 15 then
S.Learn = false
end
if S.SettingsVer < 28 then
S.Hue, S.Sat, S.Val, S.WinTrans, S.CardTrans, S.OutlineColor, S.OutlineThick, S.AccentMode = 226, 0.8, 0.14, 0.08, 0.55, "Gold", 2.5, "Gold"
local seeds = "la:15851912457+15851919155=0.357 lb:15851912457+15851919155=0.000 la:15851912457+15851919155+17285155256=0.357 lb:15851912457+15851919155+17285155256=0.000 16246923753=0.328 16205020756=0.328 16104888271=0.328 16104888271+17285155256=0.328 16205020756+17285155256=0.328 118403922040694=0.290 15997667717=0.347 16143619816=0.350 16143612725=0.350 84063020888988=0.322 138932071140330=0.316 111074210919383=0.357 71484695722621=0.311 77401448272074=0.329 128777513307709+77401448272074=0.329"
local have = {}
for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do
if string.sub(key, 1, 2) ~= "r:" then have[key] = val end
end
for key, val in string.gmatch(seeds, "(%S+)=([%d%.]+)") do have[key] = val end
local parts = {}
for key, val in pairs(have) do parts[#parts + 1] = key .. "=" .. val end
table.sort(parts)
S.ShotTimes = table.concat(parts, " ")
end
S.SettingsVer = 28
DEFAULTS.SettingsVer = 28
DEFAULTS.ShotTimes = "la:15851912457+15851919155=0.357 lb:15851912457+15851919155=0.000 la:15851912457+15851919155+17285155256=0.357 lb:15851912457+15851919155+17285155256=0.000 16246923753=0.328 16205020756=0.328 16104888271=0.328 16104888271+17285155256=0.328 16205020756+17285155256=0.328 118403922040694=0.290 15997667717=0.347 16143619816=0.350 16143612725=0.350 84063020888988=0.322 138932071140330=0.316 111074210919383=0.357 71484695722621=0.311 77401448272074=0.329 128777513307709+77401448272074=0.329"
S.ShotTimes = S.ShotTimes
S.RecOn = false
S.RecShots = false
local function save()
local ok, text = pcall(function() return HttpService:JSONEncode(S) end)
if ok then FS.write(FS.file, text) end
end
local saveQueued = false
local function saveSoon()
if saveQueued then return end
saveQueued = true
task.delay(1.5, function()
saveQueued = false
save()
end)
end
local TEXT_COLORS = {
White = Color3.new(1, 1, 1), Ice = Color3.fromRGB(215, 240, 255),
Gold = Color3.fromRGB(255, 236, 170), Mint = Color3.fromRGB(205, 255, 232),
}
local OUTLINE_COLORS = {
White = Color3.new(1, 1, 1), Cyan = Color3.fromRGB(120, 235, 255), Pink = Color3.fromRGB(255, 150, 220),
Gold = Color3.fromRGB(255, 225, 120), Lime = Color3.fromRGB(170, 255, 140),
}
local OUTLINE_NAMES = { "White", "Cyan", "Pink", "Gold", "Lime", "Rainbow" }
local TEXT_NAMES = { "White", "Ice", "Gold", "Mint" }
local FONTS = {
Gotham = { "Gotham", "GothamBold" }, Montserrat = { "Montserrat", "MontserratBold" },
SourceSans = { "SourceSans", "SourceSansBold" }, Ubuntu = { "Ubuntu", "Ubuntu" },
Oswald = { "Oswald", "Oswald" }, Code = { "Code", "Code" }, FredokaOne = { "FredokaOne", "FredokaOne" },
}
local FONT_NAMES = { "Gotham", "Montserrat", "SourceSans", "Ubuntu", "Oswald", "Code", "FredokaOne" }
local Theme = {}
local function computeTheme()
local h = (S.Hue % 360) / 360
Theme.Glass = Color3.fromHSV(h, S.Sat, S.Val)
Theme.Sheen = Color3.fromHSV(h, math.max(S.Sat - 0.55, 0), 1)
Theme.Card = Color3.fromHSV(h, math.max(S.Sat - 0.1, 0), math.min(S.Val + 0.1, 1))
Theme.Elem = Color3.fromHSV(h, S.Sat, math.max(S.Val - 0.3, 0.08))
Theme.Stroke = Color3.fromHSV(h, 0.9, 0.18)
Theme.Text = TEXT_COLORS[S.TextColor] or WHITE
Theme.Sub = Theme.Text:Lerp(Theme.Glass, 0.28)
Theme.Outline = OUTLINE_COLORS[S.OutlineColor] or WHITE
Theme.AccentA = Color3.fromHSV(h, 0.2, 1)
Theme.AccentB = Color3.fromHSV(((S.Hue - 28) % 360) / 360, 0.75, 1)
if S.AccentMode ~= "Match hue" then
Theme.AccentA = Color3.fromRGB(255, 246, 180)
Theme.AccentB = Color3.fromRGB(255, 192, 28)
end
end
computeTheme()
local gui = new("ScreenGui", { Name = "JHubGlass", ResetOnSpawn = false, IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 })
local parentedOk = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not parentedOk or not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
local function playSound(id, vol)
if not S.Sounds then return end
pcall(function()
local s = Instance.new("Sound")
s.SoundId = id
s.Volume = vol or 0.5
s.Parent = game:GetService("SoundService")
s:Play()
task.delay(3, function() s:Destroy() end)
end)
end
local SND_CLICK = "rbxasset://sounds/electronicpingshort.wav"
function Net.get(url)
local fn = request or http_request or (syn and syn.request) or (http and http.request)
if type(fn) == "function" then
local ok, res = pcall(fn, { Url = url, Method = "GET" })
if ok and type(res) == "table" and res.Body then return res.Body end
end
local ok, body = pcall(function() return game:HttpGet(url) end)
if ok then return body end
return nil
end
function Net.servers(pages)
local all, cursor = {}, nil
for _ = 1, pages do
local url = string.format("https://games.roblox.com/v1/games/%.0f/servers/Public?sortOrder=Asc&limit=100%s",
game.PlaceId, cursor and ("&cursor=" .. cursor) or "")
local data = decode(Net.get(url))
if not data or type(data.data) ~= "table" then break end
for _, s in ipairs(data.data) do table.insert(all, s) end
cursor = data.nextPageCursor
if type(cursor) ~= "string" then break end
end
return all
end
function Net.rejoin()
notify("Rejoin", "Rejoining this server...", 2)
if #Players:GetPlayers() <= 1 then
TeleportService:Teleport(game.PlaceId, LP)
else
TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end
end
function Net.hop(mode)
notify("Servers", "Looking for a server...", 2)
local list = Net.servers(3)
if #list == 0 then
notify("Servers", "Couldn't load the server list. Your executor may be blocking web requests.", 4)
return
end
local open = {}
for _, s in ipairs(list) do
if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 0) then table.insert(open, s) end
end
if #open == 0 then
notify("Servers", "No other server found. Try again in a moment.", 3)
return
end
local pick
if mode == "lower" then
table.sort(open, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
for _, s in ipairs(open) do
if (s.playing or 0) >= 1 then pick = s break end
end
pick = pick or open[1]
if (pick.playing or 0) >= #Players:GetPlayers() then
notify("Servers", "No emptier server than this one right now.", 3)
return
end
else
local busy = {}
for _, s in ipairs(open) do
if (s.playing or 0) >= 2 then table.insert(busy, s) end
end
local pool = #busy > 0 and busy or open
pick = pool[math.random(1, #pool)]
end
notify("Servers", string.format("Joining a server with %d players...", math.floor(pick.playing or 0)), 3)
TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LP)
end
function Net.redeemViaGui(list)
local pg = LP:FindFirstChild("PlayerGui")
if not pg then return false end
local box
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("TextBox") then
local n = string.lower(d.Name .. " " .. d.PlaceholderText .. " " .. (d.Parent and d.Parent.Name or ""))
if string.find(n, "code", 1, true) then box = d break end
end
end
if not box then return false end
local btn
local scope = box.Parent and box.Parent.Parent or box.Parent
for _, d in ipairs(scope:GetDescendants()) do
if d:IsA("GuiButton") then
local n = string.lower(d.Name .. " " .. (d:IsA("TextButton") and d.Text or ""))
if matchAny(n, { "redeem", "submit", "enter", "claim", "confirm" }) then btn = d break end
end
end
for _, code in ipairs(list) do
box.Text = code
if getconnections then
local ok, conns = pcall(getconnections, box.FocusLost)
if ok and conns then
for _, c in ipairs(conns) do
pcall(function()
if c.Function then c.Function(true) else c:Fire(true) end
end)
end
end
end
if btn then
Input.fireGui(btn, true, true)
Input.fireGui(btn, false, true)
end
log("Code (menu): " .. code)
task.wait(1.3)
end
return true
end
function Net.redeemViaRemotes(list)
local remotes = {}
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and matchAny(string.lower(d.Name), { "code", "redeem", "promo" }) then
table.insert(remotes, d)
end
end
if #remotes == 0 then return false end
for _, code in ipairs(list) do
for _, rm in ipairs(remotes) do
if rm:IsA("RemoteFunction") then
task.spawn(function()
local ok, res = pcall(function() return rm:InvokeServer(code) end)
log("Code " .. code .. " via " .. rm.Name .. ": " .. tostring(ok and res or "error"))
end)
else
pcall(function() rm:FireServer(code) end)
log("Code " .. code .. " sent via " .. rm.Name)
end
end
task.wait(1.2)
end
return true
end
function Net.redeemAll()
local list = tokens(S.Codes)
if #list == 0 then
notify("Codes", "The code list is empty.", 2)
return
end
notify("Codes", "Redeeming " .. #list .. " codes...", 2)
local done = Net.redeemViaGui(list)
if not done and S.CodeRemotes then done = Net.redeemViaRemotes(list) end
if done then
notify("Codes", "Finished. Check your coins and rewards.", 3)
else
notify("Codes", "Open the game's Codes menu once, then press Redeem all codes again.", 4)
end
end
Input.held = {}
Input.cache = {}
function Input.keyCode(name)
if type(name) ~= "string" or name == "" then return nil end
local ok, k = pcall(function() return Enum.KeyCode[name] end)
if ok and k then return k end
ok, k = pcall(function() return Enum.KeyCode[string.upper(name)] end)
if ok and k then return k end
return nil
end
function Input.sendKey(name, down)
if not VIM or not name or name == "" then return false end
local k = Input.keyCode(name)
if not k then return false end
return (pcall(function() VIM:SendKeyEvent(down, k, false, game) end))
end
function Input.pathOf(g)
local pg = LP:FindFirstChild("PlayerGui")
local parts = {}
local o = g
while o and o ~= pg and o ~= game do
table.insert(parts, 1, o.Name)
o = o.Parent
end
return table.concat(parts, "/")
end
function Input.resolve(path)
local o = LP:FindFirstChild("PlayerGui")
if not o or path == "" then return nil end
for name in string.gmatch(path, "[^/]+") do
o = o:FindFirstChild(name)
if not o then return nil end
end
return o
end
local ACTION_WORDS = { Shoot = { "shoot", "shot" }, Sprint = { "sprint", "run" } }
function Input.findButton(action)
if action == "Shoot" and S.ShootButtonPath ~= "" then
local b = Input.resolve(S.ShootButtonPath)
if b then return b end
end
local cached = Input.cache[action]
if cached and tick() - cached.t < 1.5 and (not cached.obj or cached.obj.Parent) then return cached.obj end
local pg = LP:FindFirstChild("PlayerGui")
local words = ACTION_WORDS[action]
local found
if pg and words then
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("GuiButton") and not d:IsDescendantOf(gui) and visibleChain(d) then
local n = string.lower(d.Name .. " " .. (d:IsA("TextButton") and d.Text or ""))
if matchAny(n, words) then found = d break end
end
end
end
Input.cache[action] = { obj = found, t = tick() }
return found
end
function Input.fireGui(g, down, clicks)
local center = g.AbsolutePosition + g.AbsoluteSize / 2
local fake = { UserInputType = TOUCH, KeyCode = Enum.KeyCode.Unknown,
UserInputState = down and Enum.UserInputState.Begin or Enum.UserInputState.End,
Position = Vector3.new(center.X, center.Y, 0), Delta = Vector3.new() }
local fired = false
local sigs = {}
if down then
table.insert(sigs, { g.InputBegan, fake })
if g:IsA("GuiButton") then table.insert(sigs, { g.MouseButton1Down, center.X, center.Y }) end
else
table.insert(sigs, { g.InputEnded, fake })
if g:IsA("GuiButton") then
table.insert(sigs, { g.MouseButton1Up, center.X, center.Y })
if clicks then
table.insert(sigs, { g.MouseButton1Click })
table.insert(sigs, { g.Activated, fake, 1 })
end
end
end
if getconnections then
for _, s in ipairs(sigs) do
local ok, conns = pcall(getconnections, s[1])
if ok and conns then
for _, c in ipairs(conns) do
local ok2 = pcall(function()
if c.Function then c.Function(s[2], s[3]) else c:Fire(s[2], s[3]) end
end)
fired = fired or ok2
end
end
end
end
if not fired and firesignal then
for _, s in ipairs(sigs) do pcall(firesignal, s[1], s[2], s[3]) end
fired = true
end
return fired
end
function Input.action(action, down)
local key = S[action .. "Key"]
local any = false
if key then any = Input.sendKey(key, down) or any end
if UIS.TouchEnabled then
local btn = down and Input.findButton(action) or Input.held[action]
if btn then
any = Input.fireGui(btn, down, action ~= "Shoot" or S.FireClick) or any
Input.held[action] = down and btn or nil
end
end
return any
end
function Input.hits(g, pos)
local ap, as = g.AbsolutePosition, g.AbsoluteSize
local inset = insetHeight()
local pad = 4
for _, y in ipairs({ pos.Y, pos.Y + inset, pos.Y - inset }) do
if pos.X >= ap.X - pad and pos.X <= ap.X + as.X + pad and y >= ap.Y - pad and y <= ap.Y + as.Y + pad then
return true
end
end
return false
end
function Input.topButtonAt(pos)
local pg = LP:FindFirstChild("PlayerGui")
if not pg then return nil end
local inset = insetHeight()
for _, y in ipairs({ pos.Y, pos.Y - inset }) do
local ok, list = pcall(function() return pg:GetGuiObjectsAtPosition(pos.X, y) end)
if ok and list then
for _, g in ipairs(list) do
if g:IsA("GuiButton") and not g:IsDescendantOf(gui) then return g end
end
end
end
return nil
end
function Input.btnText(b)
local t = ""
if b:IsA("TextButton") then t = b.Text end
if t == "" then
local l = b:FindFirstChildWhichIsA("TextLabel", true)
if l then t = l.Text end
end
return string.upper(trim(t))
end
Input.gcache = {}
function Input.glideButtons(kind)
local c = Input.gcache[kind]
if c and tick() - c.t < 2 then return c.list end
local list = {}
local seen = {}
local function add(o)
if not seen[o] then
seen[o] = true
table.insert(list, o)
end
end
local keys = {}
for _, k in ipairs(tokens(kind == "dribble" and S.DribbleKeys or S.GatherKeys)) do keys[string.upper(k)] = true end
local pg = LP:FindFirstChild("PlayerGui")
if pg and next(keys) then
for _, d in ipairs(pg:GetDescendants()) do
if not d:IsDescendantOf(gui) then
if d:IsA("GuiButton") then
if keys[Input.btnText(d)] then add(d) end
elseif d:IsA("TextLabel") and keys[string.upper(trim(d.Text))] and visibleChain(d) then
local region = d
local p = d.Parent
if p and p:IsA("GuiObject") and p.AbsoluteSize.X <= 220 and p.AbsoluteSize.Y <= 220
and p.AbsoluteSize.X >= d.AbsoluteSize.X and p.AbsoluteSize.Y >= d.AbsoluteSize.Y then
region = p
end
add(region)
end
end
end
end
Input.gcache[kind] = { t = tick(), list = list }
return list
end
Ball.parts = {}
Ball.holding = false
Ball.source = "starting"
Ball.nearest = nil
function Ball.score(o, n)
if S.BallName ~= "" and string.lower(S.BallName) ~= "auto" then
return (n == string.lower(S.BallName)) and 4 or 0
end
if n == "ball" or n == "basketball" then return 3 end
if string.find(n, "basketball", 1, true) then return 2 end
if string.find(n, "ball", 1, true) and not matchAny(n, { "rack", "zone", "region", "spawn", "hoop", "rim", "net", "stand" }) then
return 1
end
if o:IsA("Part") and o.Shape == Enum.PartType.Ball then
local m = math.max(o.Size.X, o.Size.Y, o.Size.Z)
if m >= 0.8 and m <= 3.2 then return 1 end
end
return 0
end
function Ball.partOf(o)
if o:IsA("BasePart") then return o end
if o:IsA("Tool") then return o:FindFirstChild("Handle") end
if o:IsA("Model") then return o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart") end
return nil
end
function Ball.consider(o)
if not (o:IsA("BasePart") or o:IsA("Tool") or o:IsA("Model")) then return end
local n = string.lower(o.Name)
if Ball.score(o, n) > 0 then
local p = Ball.partOf(o)
if p then Ball.parts[p] = true end
end
end
function Ball.rescan()
Ball.parts = {}
for _, d in ipairs(workspace:GetDescendants()) do pcall(Ball.consider, d) end
end
function Ball.count()
local n = 0
for _ in pairs(Ball.parts) do n = n + 1 end
return n
end
function Ball.check()
if S.ForceBall then return true, "forced on" end
local c, r = char(), hrp()
if not c or not r then return false, "no character" end
local af = c:FindFirstChild("Attributes")
if af then
local bv = af:FindFirstChild("Basketball")
if bv and bv.Value ~= nil then return true, "game ball value" end
return false, "no ball value"
end
for _, holder in ipairs({ c, LP }) do
for k, v in pairs(holder:GetAttributes()) do
local n = string.lower(k)
if matchAny(n, { "ball", "possess", "dribbl" })
and (v == true or (type(v) == "string" and v ~= "") or (type(v) == "number" and v > 0)) then
return true, "attribute " .. k
end
end
end
for _, ch in ipairs(c:GetChildren()) do
if ch:IsA("Tool") and string.find(string.lower(ch.Name), "ball", 1, true) then
return true, "tool " .. ch.Name
end
end
local best, bd
for p in pairs(Ball.parts) do
if p.Parent and p:IsDescendantOf(workspace) then
if p:IsDescendantOf(c) then return true, "ball in character" end
local d = (p.Position - r.Position).Magnitude
if not bd or d < bd then best, bd = p, d end
end
end
Ball.nearest = best
if best and bd <= S.HoldDist then
local mine = true
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= LP and pl.Character then
local pr = pl.Character:FindFirstChild("HumanoidRootPart")
if pr and (pr.Position - best.Position).Magnitude < bd then mine = false break end
end
end
if mine then return true, string.format("ball %.1f studs away", bd) end
end
if Anim.dribbling() then return true, "dribble animation" end
if tick() - (Anim.lastDribble or 0) < 1.5 then return true, "dribble move" end
if best then return false, string.format("ball %d studs away", math.floor(bd)) end
return false, "no ball found"
end
Mover.vel = Vector3.new(0, 0, 0)
Mover.gameDir, Mover.gameDirT = nil, nil
function Mover.body()
local p = workspace:FindFirstChild("ProxyCharacter")
if p and p:IsA("BasePart") then return p end
return hrp()
end
Mover.remote = nil
function Mover.gameIntent()
local d, t = Mover.gameDir, Mover.gameDirT
if not d then return nil end
local flatd = Vector3.new(d.X, 0, d.Z)
if flatd.Magnitude < 0.05 then return Vector3.new(0, 0, 0) end
if tick() - t > 0.8 then return Vector3.new(0, 0, 0) end
return flatd.Magnitude > 1 and flatd.Unit or flatd
end
function Mover.findRemote()
local r = Mover.remote
if r and r.Parent then return r end
Mover.remote = nil
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
if d:IsA("RemoteEvent") and d.Name == "MoveDirection" then
Mover.remote = d
break
end
end
return Mover.remote
end
function Mover.send(vec)
local r = Mover.findRemote()
if not r then return false end
Mover.selfFire = true
local ok = pcall(function() r:FireServer(vec) end)
Mover.selfFire = false
return ok
end
function Mover.outScale()
local s = Speed.inputScale or 1
local gi = Glide.input
if gi and not gi.paused and tick() < gi.untilT and gi.scale > s then s = gi.scale end
return s
end
Mover.GATHER_MOVES = { "stepback", "step back", "euro", "hop", "gather" }
Feat.magnetT = 0
function Feat.findBall()
local r = Mover.body()
local best, bd
local f = workspace:FindFirstChild("Basketballs")
if f and r then
for _, d in ipairs(f:GetDescendants()) do
if d:IsA("BasePart") then
local dist = (d.Position - r.Position).Magnitude
if not bd or dist < bd then best, bd = d, dist end
end
end
end
if not best and Ball.nearest and Ball.nearest.Parent and r then best, bd = Ball.nearest, (Ball.nearest.Position - r.Position).Magnitude end
return best, bd
end
function Feat.ballLoose()
local f = workspace:FindFirstChild("Characters")
if not f then return true end
for _, c in ipairs(f:GetChildren()) do
local af = c:FindFirstChild("Attributes")
local bv = af and af:FindFirstChild("Basketball")
if bv and bv.Value ~= nil then return false end
end
return true
end
function Feat.getBall(force)
local r = Mover.body()
local b, dist = Feat.findBall()
if not r or not b then return false end
local flatd = Vector3.new(r.Position.X - b.Position.X, 0, r.Position.Z - b.Position.Z)
if S.MagnetMode ~= "Go to the ball" then
if not Feat.hop(b) then return false end
else
if flatd.Magnitude < 0.1 then flatd = Vector3.new(0, 0, 1) end
local target = Vector3.new(b.Position.X, r.Position.Y, b.Position.Z) + flatd.Unit * 2.5
r.CFrame = r.CFrame + (target - r.Position)
Mover.sync(r)
end
log(string.format("Ball magnet: %s (%.0f studs away)", S.MagnetMode, dist or 0))
return true
end
function Feat.magnetStep()
if not S.BallMagnet then return end
local now = tick()
if now - Feat.magnetT < 0.4 or Ball.holding then return end
if now - Shot.releasedT < 1.2 then return end
local c = char()
if c and c:GetAttribute("Action") == "Shooting" then return end
local r = Mover.body()
local b, dist = Feat.findBall()
if not r or not b or not dist or dist < 4 or dist > S.MagnetRange then return end
if not Feat.ballLoose() then return end
Feat.magnetT = now
Feat.getBall()
end
function Mover.playerModule()
if Mover.pm == nil then
Mover.pm = false
pcall(function()
local ps = LP:FindFirstChild("PlayerScripts")
local aero = ps and ps:FindFirstChild("Aero")
local ctl = aero and aero:FindFirstChild("Controllers")
local m = ctl and ctl:FindFirstChild("Player")
if m then Mover.pm = require(m) end
end)
end
return Mover.pm or nil
end
function Mover.gameVel()
local pm = Mover.playerModule()
if not pm then return nil end
local ok, v = pcall(function() return pm.Character.Movement.CFVelocity end)
if ok and typeof(v) == "Vector3" then return Vector3.new(v.X, 0, v.Z) end
return nil
end
function Mover.sync(r)
local pm = Mover.playerModule()
if not pm then return end
pcall(function()
local ch = pm.Character
if ch and ch.LastCFrame ~= nil then ch.LastCFrame = r.CFrame end
end)
end
function Mover.moveWhere(minMag)
local v = Mover.gameVel()
if v and v.Magnitude > (minMag or 1.5) then return v end
return Mover.moveDir()
end
function Mover.onDribble(args)
Anim.lastDribble = tick()
local key = tostring(args[1])
local c0 = char()
local sv0 = c0 and c0:GetAttribute("ServerVelocity")
local pk0 = c0 and c0:GetAttribute("LastDribblePackage")
local v0 = Mover.gameVel() or Vector3.new(0, 0, 0)
local t0 = tick()
task.spawn(function()
while JH.Running and tick() - t0 < 0.4 do
RunService.Heartbeat:Wait()
local cc = char()
local gv = Mover.gameVel()
if gv and (gv - v0).Magnitude > 2.5 then break end
if cc and (cc:GetAttribute("ServerVelocity") ~= sv0 or cc:GetAttribute("LastDribblePackage") ~= pk0) then break end
end
if not JH.Running then return end
local c = char()
local pkg = c and c:GetAttribute("LastDribblePackage")
local name = type(pkg) == "string" and string.lower(pkg) or ""
local dir = Mover.moveWhere(1.5)
if not dir and typeof(args[3]) == "Vector3" and Vector3.new(args[3].X, 0, args[3].Z).Magnitude > 0.1 then
dir = Vector3.new(args[3].X, 0, args[3].Z)
end
if matchAny(name, Mover.GATHER_MOVES) then
if not dir and (string.find(name, "step back", 1, true) or string.find(name, "stepback", 1, true)) then
local body = Mover.body()
if body then dir = -Vector3.new(body.CFrame.LookVector.X, 0, body.CFrame.LookVector.Z) end
end
Glide.fire("gather", "step back move " .. name, dir)
else
Glide.fire("dribble", "dribble move " .. (name ~= "" and name or key), dir)
end
end)
end
function Mover.moveDir()
local c = char()
local sv = c and c:GetAttribute("ServerVelocity")
if typeof(sv) == "Vector3" then
local f = Vector3.new(sv.X, 0, sv.Z)
if f.Magnitude > 1.5 then return f end
end
return nil
end
function Mover.watchShot(pressT)
task.spawn(function()
local t0 = tick()
while tick() - t0 < 0.5 and Shot.meterT < pressT - 0.05 do RunService.Heartbeat:Wait() end
if Shot.meterT < pressT - 0.05 then return end
local c0 = char()
local sv0 = c0 and c0:GetAttribute("ServerVelocity")
local v0 = Mover.gameVel() or Vector3.new(0, 0, 0)
local t1 = tick()
while JH.Running and tick() - t1 < 0.3 do
RunService.Heartbeat:Wait()
local gv = Mover.gameVel()
local cc = char()
if gv and (gv - v0).Magnitude > 2 then break end
if cc and cc:GetAttribute("ServerVelocity") ~= sv0 then break end
end
local dir = Mover.moveWhere(1.5)
Glide.fire("shot", "shot", dir)
end)
end
function Mover.controls()
if Mover.ctl == nil then
Mover.ctl = false
pcall(function()
local ps = LP:FindFirstChild("PlayerScripts")
local pm = ps and ps:FindFirstChild("PlayerModule")
if pm then Mover.ctl = require(pm):GetControls() end
end)
end
return Mover.ctl or nil
end
function Mover.intent(h, r)
local gi = Mover.gameIntent()
if gi then return gi, "game" end
local md = flat(h.MoveDirection)
if md.Magnitude > 0.05 then return md, "humanoid" end
local ctl = Mover.controls()
if ctl then
local ok, mv = pcall(function() return ctl:GetMoveVector() end)
if ok and mv and (math.abs(mv.X) > 0.05 or math.abs(mv.Z) > 0.05) then
local world = flat(cam().CFrame:VectorToWorldSpace(Vector3.new(mv.X, 0, mv.Z)))
local len = math.min(1, math.sqrt(mv.X * mv.X + mv.Z * mv.Z))
if world.Magnitude > 0.01 then return world.Unit * len, "controls" end
end
return Vector3.new(0, 0, 0), "none"
end
local hv = flat(r.AssemblyLinearVelocity)
if hv.Magnitude > 4 then return hv.Unit, "velocity" end
return Vector3.new(0, 0, 0), "none"
end
local SHOT_WORDS = { "shoot", "shot", "jumper", "fade", "three", "release", "layup", "dunk", "alley", "stepback", "step back", "floater" }
local DRIBBLE_WORDS = { "dribble", "cross", "hesi", "behind", "between", "spin", "stepback", "step back", "shammgod", "snatch", "escape", "jab" }
local GATHER_WORDS = { "gather", "layup", "euro", "dunk", "floater", "hop", "finish" }
local ANIM_FLAGS = { dribble = "AnimDribble", gather = "AnimGather", shot = "AnimShot" }
Anim.learnKind = nil
Anim.learnUntil = 0
Anim.learned = 0
Anim.loops = {}
Anim.seen = {}
Anim.animator = nil
function Anim.name(track)
local a = track.Animation
return string.lower((track.Name or "") .. " " .. (a and a.Name or "") .. " " .. (a and a.AnimationId or ""))
end
function Anim.idOf(track)
local a = track.Animation
return a and string.lower(tostring(a.AnimationId or "")) or ""
end
function Anim.has(flag, id)
return id ~= "" and string.find(" " .. string.lower(S[flag] or "") .. " ", " " .. id .. " ", 1, true) ~= nil
end
function Anim.isAction(track)
local p = track.Priority.Value
return p >= Enum.AnimationPriority.Action.Value and p < Enum.AnimationPriority.Core.Value
end
function Anim.dribbling()
for track in pairs(Anim.loops) do
if track.IsPlaying then return true end
end
return false
end
function Anim.classify(track)
if track.Looped then return nil end
local id = Anim.idOf(track)
for kind, flag in pairs(ANIM_FLAGS) do
if Anim.has(flag, id) then return kind, "taught" end
end
local n = Anim.name(track)
if matchAny(n, GATHER_WORDS) and not matchAny(n, { "shoot", "shot", "jumper" }) then return "gather", "keyword" end
if matchAny(n, SHOT_WORDS) then return "shot", "keyword" end
if matchAny(n, DRIBBLE_WORDS) then return "dribble", "keyword" end
if S.GlideSmart and Anim.isAction(track) and (Ball.holding or not next(Ball.parts)) then return "dribble", "smart" end
return nil
end
function Anim.startLearn(kind)
Anim.learnKind = kind
Anim.learnUntil = tick() + 8
Anim.learned = 0
notify("Teaching " .. kind, "Do that move in the game now. You have 8 seconds.", 4)
UI.show(false)
task.delay(8.5, function()
if JH.Running then UI.show(true) end
end)
end
function Anim.learn(track)
if not Anim.learnKind then return false end
if tick() > Anim.learnUntil then
Anim.learnKind = nil
return false
end
if track.Looped or not Anim.isAction(track) then return false end
local id = Anim.idOf(track)
if id == "" then return false end
local flag = ANIM_FLAGS[Anim.learnKind]
if not Anim.has(flag, id) then
S[flag] = trim((S[flag] or "") .. " " .. id)
Anim.learned = Anim.learned + 1
saveSoon()
log("Taught " .. Anim.learnKind .. ": " .. id)
notify("Learned", Anim.learnKind .. " animation saved (" .. Anim.learned .. ")", 2)
end
return true
end
function Anim.clear()
S.AnimDribble, S.AnimGather, S.AnimShot = "", "", ""
saveSoon()
notify("Taught moves", "Cleared", 2)
end
function Anim.summary()
return string.format("Taught: %d dribble, %d gather, %d shot", #tokens(S.AnimDribble), #tokens(S.AnimGather), #tokens(S.AnimShot))
end
function Anim.handle(track)
local n = Anim.name(track)
if track.Looped and matchAny(n, { "dribble", "ball", "handle" }) then Anim.loops[track] = true end
Shot.noteTrack(track)
pcall(Anim.detTrack, track)
local kind, how = Anim.classify(track)
if Rec.on then
Rec.add("anim", string.format("%s id=%s len=%.2f prio=%s looped=%s speed=%s -> %s", (track.Name or "") ~= "" and track.Name or "?",
Anim.idOf(track), track.Length or 0, tostring(track.Priority.Value), tostring(track.Looped), tostring(track.Speed), tostring(kind)))
end
if kind == "dribble" and how ~= "smart" then Anim.lastDribble = tick() end
if Anim.learn(track) then return end
if Shot.busy then return end
if kind and not Shot.hooked then Glide.fire(kind, "animation " .. ((track.Name or "") ~= "" and track.Name or "?")) end
end
function Anim.onPlayed(track)
if Anim.seen[track] then return end
Anim.seen[track] = true
Anim.handle(track)
end
function Anim.poll()
local a = Anim.animator
if not a then return end
local ok, list = pcall(function() return a:GetPlayingAnimationTracks() end)
if not ok or type(list) ~= "table" then return end
local playing = {}
for _, track in ipairs(list) do
playing[track] = true
if not Anim.seen[track] then
Anim.seen[track] = true
pcall(Anim.handle, track)
end
end
for track in pairs(Anim.seen) do
if not playing[track] then Anim.seen[track] = nil end
end
end
Anim.det = { list = {}, index = {}, catByName = {}, nameById = {}, scanned = false, scanning = false, lastAttr = nil, lastAction = nil, cur = nil }
Anim.DET_WORDS = {
{ "Dunk", { "dunk", "slam", "tomahawk", "windmill", "rimgrazer", "alleyoop" } },
{ "Layup", { "layup", "lay up", "scoop", "euro", "floater", "finger" } },
{ "Post", { "post", "hook", "dropstep", "drop step" } },
{ "Jump shot", { "jumpshot", "jump shot", "jumper", "pullup", "pull up", "stepback", "step back", "fadeaway", "shoot" } },
}
Anim.DET_PATHS = { { "Dunk", "dunk" }, { "Layup", "layup" }, { "Post", "post" }, { "Jump shot", "jumpshot" }, { "Jump shot", "jumper" } }
function Anim.detScan()
local d = Anim.det
if d.scanned or d.scanning then return end
d.scanning = true
task.spawn(function()
pcall(function()
local n = 0
for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
n = n + 1
if n % 1500 == 0 then task.wait() end
local path, p = "", inst.Parent
local guard = 0
while p and p ~= ReplicatedStorage and guard < 30 do
path = string.lower(p.Name) .. "/" .. path
p = p.Parent
guard = guard + 1
end
if inst:IsA("Animation") then
d.nameById[string.lower(tostring(inst.AnimationId or ""))] = inst.Name
end
for _, e in ipairs(Anim.DET_PATHS) do
if string.find(path, e[2], 1, true) then
local l = string.lower(inst.Name)
if not d.catByName[l] then d.catByName[l] = e[1] end
break
end
end
end
end)
d.scanned, d.scanning = true, false
end)
end
function Anim.detCat(name)
local l = string.lower(name)
for _, e in ipairs(Anim.DET_WORDS) do
for _, w in ipairs(e[2]) do
if string.find(l, w, 1, true) then return e[1] end
end
end
return Anim.det.catByName[l] or Anim.det.catByName[string.sub(l, 1, -2)]
end
function Anim.detAdd(name, id, cat)
local d = Anim.det
local key = string.lower(name)
local e = d.index[key]
if not e then
e = { name = name, id = id or "", cat = cat, count = 0 }
d.index[key] = e
if S.DetNotify then pcall(notify, "Animation detected", tostring(cat) .. ": " .. name, 3) end
end
e.count = e.count + 1
e.t = tick()
e.cat = cat or e.cat
if id and id ~= "" then e.id = id end
d.cur = e
for i, x in ipairs(d.list) do
if x == e then table.remove(d.list, i) break end
end
table.insert(d.list, 1, e)
while #d.list > 40 do
local r = table.remove(d.list)
d.index[string.lower(r.name)] = nil
end
end
function Anim.detTrack(track)
Anim.detScan()
local a = track.Animation
local id = a and tostring(a.AnimationId or "") or ""
local nm = a and a.Name or ""
if nm == "" or nm == "Animation" then nm = Anim.det.nameById[string.lower(id)] or track.Name or "" end
if nm == "" then return end
local cat = Anim.detCat(nm)
if cat then Anim.detAdd(nm, id, cat) end
end
function Anim.detStep()
local d = Anim.det
local c = char()
if not c then return end
local v = c:GetAttribute("BaseAnimation")
local act = c:GetAttribute("Action")
if d.lastAttr == nil then
d.lastAttr = (type(v) == "string") and v or ""
d.lastAction = act
return
end
local changed = type(v) == "string" and v ~= "" and v ~= d.lastAttr
local started = act == "Shooting" and d.lastAction ~= "Shooting" and type(v) == "string" and v ~= ""
if changed or started then
if type(v) == "string" then d.lastAttr = v end
Anim.detAdd(v, "", Anim.detCat(v) or "Shot")
end
d.lastAction = act
end
function Anim.detText()
local d = Anim.det
local cur = d.cur
local nowName, nowType = "-", "-"
if cur then
local ago = math.max(0, tick() - (cur.t or tick()))
nowName = cur.name
nowType = string.format("%s  (%ds ago)", tostring(cur.cat), math.floor(ago))
end
local lines = {}
for i = 1, math.min(8, #d.list) do
local e = d.list[i]
lines[#lines + 1] = string.format("%s: %s  x%d", tostring(e.cat), e.name, math.floor(e.count))
end
return nowName, nowType, (#lines > 0) and table.concat(lines, "\n") or "Play a shot, layup, dunk or post move"
end
function Anim.detCopy()
local d = Anim.det
local out = { "== animations detected " .. VERSION }
for _, e in ipairs(d.list) do
out[#out + 1] = string.format("%s | %s | %s | seen %d", tostring(e.cat), e.name, e.id ~= "" and e.id or "(from the character)", math.floor(e.count))
end
local text = table.concat(out, "\n")
if type(setclipboard) == "function" then pcall(setclipboard, text) end
notify("Animations", #d.list .. " animation(s) copied", 3)
return text
end
function Anim.hookChar(c)
task.spawn(function()
local function find() return c:FindFirstChildOfClass("Humanoid") or c:FindFirstChildOfClass("AnimationController") or c:FindFirstChildWhichIsA("Animator", true) end
local h = find()
local t0 = tick()
while not h and tick() - t0 < 10 do
task.wait(0.5)
h = find()
end
if not h then return end
local animator = h
pcall(function()
animator = h:IsA("Animator") and h or h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 5) or h
end)
Anim.animator = animator
pcall(function()
bind(animator.AnimationPlayed, function(track)
pcall(Anim.onPlayed, track)
end)
end)
end)
end
local BAR_PROPS = {
asx = function(o) return o.AbsoluteSize.X end,
asy = function(o) return o.AbsoluteSize.Y end,
apx = function(o) return o.AbsolutePosition.X end,
apy = function(o) return o.AbsolutePosition.Y end,
irx = function(o) return o.ImageRectSize.X end,
iry = function(o) return o.ImageRectSize.Y end,
iox = function(o) return o.ImageRectOffset.X end,
ioy = function(o) return o.ImageRectOffset.Y end,
gox = function(o) return o.Offset.X end,
goy = function(o) return o.Offset.Y end,
grot = function(o) return o.Rotation end,
gc2 = function(o) local k = o.Color.Keypoints return k[2] and k[2].Time end,
gc3 = function(o) local k = o.Color.Keypoints return k[3] and k[3].Time end,
gt2 = function(o) local k = o.Transparency.Keypoints return k[2] and k[2].Time end,
gt3 = function(o) local k = o.Transparency.Keypoints return k[3] and k[3].Time end,
}
local FRAME_PROPS = { "asx", "asy", "apx", "apy" }
local IMAGE_PROPS = { "irx", "iry", "iox", "ioy" }
local GRAD_PROPS = { "gox", "goy", "grot", "gc2", "gc3", "gt2", "gt3" }
local BAR_HINTS = { "meter", "bar", "fill", "shot", "power", "timing", "release", "gauge", "progress", "bat" }
Bar.armedUntil = 0
Bar.misses = 0
Bar.inst = nil
Bar.report = {}
function Bar.isArmed() return tick() < Bar.armedUntil end
function Bar.pathOf(inst)
local parts, o = {}, inst
while o and o ~= game do
table.insert(parts, 1, o.Name)
o = o.Parent
end
return table.concat(parts, "/")
end
function Bar.resolve(path)
local o = game
for seg in string.gmatch(path, "[^/]+") do
o = o and o:FindFirstChild(seg)
if not o then return nil end
end
return o
end
function Bar.hint(inst)
local score, o = 0, inst
for _ = 1, 3 do
if not o then break end
if matchAny(string.lower(o.Name), BAR_HINTS) then score = score + 1 end
o = o.Parent
end
return score
end
function Bar.getter(inst, prop)
local fn = BAR_PROPS[prop]
if not fn then return nil end
return function() return fn(inst) end
end
function Bar.locate()
local inst = Bar.inst
if inst and inst.Parent then return inst end
inst = S.BarPath ~= "" and Bar.resolve(S.BarPath) or nil
if not inst and S.BarPath ~= "" then
local name = string.match(S.BarPath, "([^/]+)$")
local isGrad = string.sub(S.BarProp, 1, 1) == "g"
for d in pairs(isGrad and Shot.grads or Shot.frames) do
if d.Name == name and d.Parent and visibleChain(d.Parent) then
inst = d
break
end
end
end
Bar.inst = inst
return inst
end
function Bar.selected() return S.BarProp ~= "" and S.BarPath ~= "" end
function Bar.threshold() return S.BarAt * (1 + S.BarNudge / 100) end
function Bar.forget()
Bar.misses = 0
S.BarPath, S.BarProp, S.BarAt = "", "", 0
Bar.inst = nil
saveSoon()
end
function Bar.select(c)
S.BarPath, S.BarProp, S.BarAt = Bar.pathOf(c.inst), c.prop, 0
Bar.inst = c.inst
saveSoon()
log("Shot bar found: " .. S.BarPath .. " (" .. c.prop .. ")")
notify("Shot bar found", c.inst.Name .. " (" .. c.prop .. "). It learns the release point from your first green.", 4)
end
function Bar.watch(wide)
local w = { n = 0, series = {}, known = {}, cands = {}, wide = wide, delta = nil, live = false, v0 = nil, before = {} }
if not Bar.selected() then
for d in pairs(Shot.frames) do
if d.Parent and visibleChain(d) then w.before[d] = true end
end
for g in pairs(Shot.grads) do
local p = g.Parent
if p and visibleChain(p) then w.before[g] = true end
end
end
return w
end
function Bar.collect(w)
local out = {}
local function add(inst, props)
local base = Bar.pathOf(inst)
if string.find(base, "Stamina", 1, true) then return end
local hint = Bar.hint(inst)
if string.find(base, "BatMeter", 1, true) then hint = hint + 3 end
for _, name in ipairs(props) do
local id = base .. "|" .. name
if not w.known[id] then
w.known[id] = true
local fn = BAR_PROPS[name]
out[#out + 1] = { id = id, inst = inst, prop = name, hint = hint, get = function() return fn(inst) end }
end
end
end
for d in pairs(Shot.frames) do
if d.Parent and visibleChain(d) and (w.wide or not w.before[d]) then
add(d, FRAME_PROPS)
if d:IsA("ImageLabel") or d:IsA("ImageButton") then add(d, IMAGE_PROPS) end
end
end
for g in pairs(Shot.grads) do
local p = g.Parent
if p and visibleChain(p) and (w.wide or not w.before[g]) then add(g, GRAD_PROPS) end
end
return out
end
function Bar.step(w)
w.n = w.n + 1
local result = nil
if Bar.selected() then
if not w.get then
local inst = Bar.locate()
if inst then
local target = string.sub(S.BarProp, 1, 1) == "g" and inst.Parent or inst
if target and visibleChain(target) then w.get = Bar.getter(inst, S.BarProp) end
end
end
if w.get then
local ok, v = pcall(w.get)
if ok and type(v) == "number" then
if w.v0 == nil then w.v0 = v end
local d = math.abs(v - w.v0)
if w.delta == nil or d > w.delta + 0.0005 then w.lastMove = tick() end
w.delta = d
if d > 0.0005 then w.live = true end
result = d
end
end
if not (Rec.on and w.wide) then return result end
end
if w.n <= 12 and #w.cands < 600 then
for _, c in ipairs(Bar.collect(w)) do w.cands[#w.cands + 1] = c end
end
for _, c in ipairs(w.cands) do
local ok, v = pcall(c.get)
if ok and type(v) == "number" then
local s = w.series[c.id]
if not s then
s = {}
w.series[c.id] = s
end
s[#s + 1] = v
end
end
return result
end
function Bar.minChange(prop)
if prop == "grot" then return 4 end
if string.sub(prop, 1, 1) == "g" then return 0.04 end
return 3
end
function Bar.analyze(w)
local best, bestScore
local movers = {}
for _, c in ipairs(w.cands or {}) do
local s = w.series[c.id]
if s and #s >= 5 then
local ups, downs, steps = 0, 0, 0
local span = math.abs(s[#s] - s[1])
local eps = math.max(span * 0.01, 0.0001)
for i = 2, #s do
local d = s[i] - s[i - 1]
if d > eps then
ups = ups + 1
steps = steps + 1
elseif d < -eps then
downs = downs + 1
steps = steps + 1
end
end
local consistency = steps > 0 and math.max(ups, downs) / steps or 0
local score = steps * consistency + c.hint * 3
if c.prop == "apx" or c.prop == "apy" then score = score * 0.4 end
table.insert(movers, { id = c.id, span = span, steps = steps, consistency = consistency, score = score })
if span >= Bar.minChange(c.prop) and steps >= 4 and consistency >= 0.85 then
if not bestScore or score > bestScore then best, bestScore = c, score end
end
end
end
table.sort(movers, function(a, b) return a.span * a.consistency > b.span * b.consistency end)
Bar.report = {}
for i = 1, math.min(6, #movers) do
local m = movers[i]
Bar.report[i] = string.format("%s span=%.3f steps=%d consistency=%.2f", m.id, m.span, m.steps, m.consistency)
end
return best
end
function Bar.finish(w)
if not Bar.selected() then
local best = Bar.analyze(w)
if best then
local s = w.series[best.id]
Bar.select(best)
w.delta = math.abs(s[#s] - s[1])
else
Bar.misses = Bar.misses + 1
end
elseif Rec.on and #w.cands > 0 then
Bar.analyze(w)
end
if Rec.on then
for _, l in ipairs(Bar.report) do Rec.add("bar", "moved: " .. l) end
if w.delta then Rec.add("bar", string.format("selected %s %s delta=%.3f point=%.3f", S.BarPath, S.BarProp, w.delta, S.BarAt)) end
end
return w.delta
end
function Bar.teach()
Bar.forget()
Bar.armedUntil = tick() + 14
notify("Teaching the shot bar", "Press and hold the game's shoot button now. JHub takes this shot so it can watch the bar.", 5)
UI.show(false)
task.delay(14.5, function()
if JH.Running then UI.show(true) end
end)
end
Shot.busy = false
Shot.touchCtx = nil
Shot.labels, Shot.frames, Shot.grads = {}, {}, {}
Shot.stats = { shots = 0, greens = 0, early = 0, late = 0, none = 0, streak = 0, best = 0 }
Shot.times = {}
Shot.cap = nil
Shot.lastType = "-"
Shot.lastRelease = "-"
local STRENGTH_STEP = { 0.06, 0.15, 0.35 }
function Shot.track(d)
if d:IsA("TextLabel") then
if not d:IsDescendantOf(gui) then Shot.labels[d] = true end
elseif d:IsA("UIGradient") then
if not d:IsDescendantOf(gui) then Shot.grads[d] = true end
elseif d:IsA("Frame") or d:IsA("ImageLabel") or d:IsA("ImageButton") then
if not d:IsDescendantOf(gui) then Shot.frames[d] = true end
end
end
function Shot.untrack(d)
Shot.labels[d], Shot.frames[d], Shot.grads[d] = nil, nil, nil
end
function Shot.hookRoot(root, chunked)
if chunked then
task.spawn(function()
local n = 0
for _, d in ipairs(root:GetDescendants()) do
Shot.track(d)
n = n + 1
if n % 1500 == 0 then task.wait() end
end
end)
else
for _, d in ipairs(root:GetDescendants()) do Shot.track(d) end
end
bind(root.DescendantAdded, Shot.track)
bind(root.DescendantRemoving, Shot.untrack)
end
function Shot.parseTimes()
Shot.times = {}
for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do
Shot.times[key] = tonumber(val)
end
end
function Shot.saveTimes()
local parts = {}
for key, val in pairs(Shot.times) do table.insert(parts, string.format("%s=%.3f", key, val)) end
table.sort(parts)
S.ShotTimes = table.concat(parts, " ")
saveSoon()
end
function Shot.timesSummary()
local lines = {}
for key, val in pairs(Shot.times) do
local label = string.sub(key, -10)
table.insert(lines, string.format("%s  %.2fs", label, val))
end
table.sort(lines)
return #lines > 0 and table.concat(lines, "\n") or "No shot types learned yet. Take a few shots."
end
function Shot.classify(text)
local tx = string.lower(text)
if not string.find(tx, "release", 1, true) and not matchAny(tx, { "perfect", "excellent", "flawless", "splash", "good" }) then return nil end
local strength = string.find(tx, "very", 1, true) and 3 or (string.find(tx, "slight", 1, true) and 1 or 2)
if string.find(tx, "early", 1, true) then return "early", strength end
if string.find(tx, "late", 1, true) then return "late", strength end
if string.find(tx, "%f[%a]good%f[%A]") or string.find(tx, "%f[%a]great%f[%A]") or string.find(tx, "%f[%a]nice%f[%A]") then return "good", 0 end
return "green", 0
end
function Shot.textSnapshot()
local snap = {}
for d in pairs(Shot.labels) do
if not d.Parent then
Shot.labels[d] = nil
elseif visibleChain(d) then
snap[d] = d.Text
end
end
return snap
end
function Shot.result(snap, window, since)
local t0 = tick()
while tick() - t0 < window do
for d in pairs(Shot.labels) do
if not d.Parent then
Shot.labels[d] = nil
elseif d.Text ~= "" and snap[d] ~= d.Text and visibleChain(d) then
local res, strength = Shot.classify(d.Text)
if res then return res, strength, d.Text end
end
end
if since then
if since.idxT and Shot.fbIdxT > since.idxT then
local r, st = Shot.fromIdx(Shot.fbIdx)
if r then return r, st, "release " .. tostring(Shot.fbIdx) end
end
if Shot.fbT > since.fb then
local r, s = Shot.classifyFB(Shot.fbText)
if r then return r, s, Shot.fbText end
end
if Shot.greenT > since.green then return "green", 0, "green effect" end
if since.fake and tick() - t0 > 0.15 then
local c = char()
if c and c:GetAttribute("Action") == "Gathering" then return "early", 3, "pump fake (released too soon)" end
end
end
task.wait(0.06)
end
return nil, 0, nil
end
function Shot.situation()
local h, r = hum(), hrp()
if not h or not r then return "stand" end
local v = r.AssemblyLinearVelocity
local hs = math.sqrt(v.X * v.X + v.Z * v.Z)
if h.MoveDirection.Magnitude < 0.1 and hs < 3 then return "stand" end
if hs > 19 or Input.held.Sprint or (UIS:IsKeyDown(Input.keyCode(S.SprintKey) or Enum.KeyCode.LeftShift)) then return "sprint" end
return "move"
end
function Shot.paramValue(sit)
local t = S.HoldTime
if S.AutoTiming then
if sit == "move" then t = t + S.MovingOffset elseif sit == "sprint" then t = t + S.SprintOffset end
end
return t
end
function Shot.noteTrack(track)
local cap = Shot.cap
if not cap or track.Looped or not Anim.isAction(track) then return end
if tick() - cap.t0 > 0.8 then return end
table.insert(cap.tracks, track)
end
function Shot.pickTrack(cap)
local best, bs
for _, tr in ipairs(cap.tracks) do
local score = tr.Length or 0
local n = Anim.name(tr)
if matchAny(n, SHOT_WORDS) or matchAny(n, GATHER_WORDS) then score = score + 100 end
if not bs or score > bs then best, bs = tr, score end
end
return best
end
function Shot.keyOf(track, sit)
if track then
local id = Anim.idOf(track)
if id ~= "" then return id end
return "name:" .. string.lower(track.Name or "shot")
end
return "sit:" .. sit
end
function Shot.nameOf(track, sit)
if not track then return sit end
local n = track.Name
if n and n ~= "" and n ~= "Animation" then return n end
local a = track.Animation
if a and a.Name and a.Name ~= "" and a.Name ~= "Animation" then return a.Name end
return string.sub(Anim.idOf(track), -8)
end
function Shot.holdFor(sit, track)
local key = Shot.keyOf(track, sit)
local base
if S.AutoTiming and track then
base = Shot.times[key]
if not base and S.ShotRatio > 0 and (track.Length or 0) > 0.05 then base = S.ShotRatio * track.Length end
end
base = base or Shot.paramValue(sit)
local t = base
if S.AutoTiming and S.PingComp > 0 then
local ok, ping = pcall(function() return LP:GetNetworkPing() end)
if ok and ping then t = t - ping * (S.PingComp / 100) end
end
t = t + S.Nudge / 1000
if S.Humanize > 0 then t = t + (math.random() * 2 - 1) * (S.Humanize / 1000) end
return clamp(t, 0.05, S.MaxHold), key, base
end
function Shot.applyDelta(sit, delta)
if S.AutoTiming and sit == "move" then
UI.set("MovingOffset", clamp(S.MovingOffset + delta, -0.5, 0.5), false)
elseif S.AutoTiming and sit == "sprint" then
UI.set("SprintOffset", clamp(S.SprintOffset + delta, -0.5, 0.5), false)
else
UI.set("HoldTime", clamp(S.HoldTime + delta, 0.08, 1.6), false)
end
end
function Shot.release(mode, ctx)
if mode == "backup" then
Backup.send(false)
elseif mode == "remote" then
Shot.releasedT = tick()
Shot.fireRemote(false)
elseif mode == "manualKey" then
Input.sendKey(S.ShootKey, false)
elseif mode == "touch" and ctx then
if S.ReleaseMethod ~= "Key" and ctx.btn then Input.fireGui(ctx.btn, false, S.FireClick) end
if S.ReleaseMethod ~= "Button" then Input.sendKey(S.ShootKey, false) end
end
end
function Shot.learnTiming(info, res, strength)
local rate = S.CalSpeed
local base, held = info.base, info.held
local function stepFor(from)
return math.max(S.CalStep * strength * rate, from * STRENGTH_STEP[strength] * rate / 0.6)
end
if S.AutoTiming and info.track then
local newv
if info.manual or info.usedBar then
if res == "green" then newv = base + (held - base) * 0.5 end
elseif res == "green" then
newv = base
elseif res == "early" then
newv = base + stepFor(base)
elseif res == "late" then
newv = base - stepFor(base)
end
if newv then
Shot.times[info.key] = clamp(newv, 0.08, S.MaxHold)
Shot.saveTimes()
end
local len = info.track.Length or 0
if res == "green" and len > 0.05 then
local ratio = (Shot.times[info.key] or held) / len
S.ShotRatio = (S.ShotRatio > 0) and (S.ShotRatio * 0.6 + ratio * 0.4) or ratio
saveSoon()
end
return
end
local delta = 0
local pv = Shot.paramValue(info.sit)
if info.manual or info.usedBar then
if res == "green" then delta = (held - pv) * 0.5 end
elseif res == "early" then
delta = stepFor(pv)
elseif res == "late" then
delta = -stepFor(pv)
end
if delta ~= 0 then Shot.applyDelta(info.sit, delta) end
end
function Shot.evaluate(info)
local res, strength, text = Shot.result(info.snap, 2, info.since)
local st = Shot.stats
if res == "green" then
st.greens = st.greens + 1
st.streak = st.streak + 1
if st.streak > st.best then st.best = st.streak end
if S.GreenSound then playSound(SND_CLICK, 0.6) end
elseif res == "good" then
st.streak = 0
elseif res == "early" then
st.early = st.early + 1
st.streak = 0
elseif res == "late" then
st.late = st.late + 1
st.streak = 0
else
st.none = st.none + 1
end
local note = text and ('"' .. text .. '"') or "no feedback seen"
if S.AutoCalibrate and res then
local rate = S.CalSpeed
if info.barDelta and Bar.selected() then
if res == "green" then
if info.usedBar and S.BarAt > 0 then
S.BarAt = S.BarAt * 0.7 + info.barDelta * 0.3
elseif S.BarAt <= 0 then
S.BarAt = info.barDelta
else
S.BarAt = S.BarAt * 0.5 + info.barDelta * 0.5
end
elseif info.usedBar and S.BarAt > 0 then
local k = STRENGTH_STEP[strength] * rate / 0.6
S.BarAt = S.BarAt * (res == "early" and (1 + k) or (1 - k))
end
saveSoon()
end
if info.remote then
info.idx = (info.since and Shot.fbIdxT > info.since.idxT) and Shot.fbIdx or nil
info.relQ = Shot.meterQ()
if info.usedMeter then
Shot.learnMeter(info)
note = note .. string.format("  |  aim %.3f", S.MeterTarget)
else
Shot.learnRemote(info, res, strength)
note = note .. string.format("  |  %.3fs", Shot.times[info.key] or info.held)
end
else
Shot.learnTiming(info, res, strength)
note = note .. string.format("  |  %s  |  %.2fs", Shot.lastType, Shot.times[info.key] or Shot.paramValue(info.sit))
end
end
if Rec.shotOn then
pcall(Rec.shotNote, info, res, text)
Rec.shotAdd(string.format("RESULT %s | held=%.4f | key=%s | message=%s | game log=%s", tostring(res), info.held or 0, tostring(info.key), tostring(text),
string.sub(tostring(Shot.fbText or ""), 1, 200)))
end
log("Shot: " .. note)
notify(res == "green" and "GREEN!" or "Shot", note, 2.2)
end
Shot.meterT, Shot.packet, Shot.packetT, Shot.greenT, Shot.fbT, Shot.fbText = 0, nil, 0, 0, 0, ""
Shot.releasedT, Shot.pressT, Shot.pkMiss = 0, 0, 0
Shot.hooked = false
Shot.selfFire = false
Shot.remote = nil
function Shot.findRemote()
local r = Shot.remote
if r and r.Parent then return r end
Shot.remote = nil
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
if d:IsA("RemoteEvent") and d.Name == "Shoot" then
Shot.remote = d
if d.Parent and d.Parent.Name == "InputService" then break end
end
end
return Shot.remote
end
function Shot.fireRemote(down)
local r = Shot.findRemote()
if not r then return false end
Shot.selfFire = true
local ok = pcall(function() r:FireServer({ Shoot = down }) end)
Shot.selfFire = false
return ok
end
function Shot.classifyFB(text)
local tx = string.lower(text)
local strength = string.find(tx, "very", 1, true) and 3 or (string.find(tx, "slight", 1, true) and 1 or 2)
if string.find(tx, "%f[%a]early%f[%A]") then return "early", strength end
if string.find(tx, "%f[%a]late%f[%A]") then return "late", strength end
if string.find(tx, "%f[%a]perfect%f[%A]") or string.find(tx, "%f[%a]green%f[%A]") or string.find(tx, "%f[%a]excellent%f[%A]") then
return "green", 0
end
if string.find(tx, "%f[%a]good%f[%A]") then return "good", 0 end
return nil
end
local function isMine(a)
local sawInst = false
for i = 1, 3 do
local v = a[i]
if typeof(v) == "Instance" then
sawInst = true
if v.Name == LP.Name then return true end
end
end
return not sawInst
end
function Shot.onRemoteEvent(name, ...)
local a = { ... }
if Rec.shotOn then
local parts = {}
for i = 1, math.min(#a, 8) do
local v = a[i]
parts[#parts + 1] = typeof(v) == "Instance" and ("<" .. v.Name .. ">") or (type(v) == "table" and "{table}" or tostring(v))
end
Rec.shotAdd("EVENT " .. name .. " " .. table.concat(parts, " | "))
end
if name == "Meter" then
if a[1] == true and typeof(a[2]) == "Instance" and a[2].Name == LP.Name then
Shot.meterT, Shot.packet = tick(), nil
if Rec.shotOn then Rec.shotMeterStart() end
end
elseif name == "RegisterPacket" then
if typeof(a[1]) == "Instance" and a[1].Name == LP.Name and type(a[3]) == "number" then
Shot.packet, Shot.packetT = a[3], tick()
end
elseif name == "ShowFeedback" then
if typeof(a[1]) == "Instance" and (a[1].Name == LP.Name or a[1] == char()) and tonumber(a[3]) then Shot.fbIdx, Shot.fbIdxT = tonumber(a[3]), tick() end
elseif name == "RunGreenEffect" or name == "GreenCelebration" then
if isMine(a) then Shot.greenT = tick() end
elseif name == "Output" then
if type(a[2]) == "string" and string.find(a[2], "Shot Feedback", 1, true) then Shot.fbT, Shot.fbText = tick(), a[2] end
end
end
Shot.remoteNames = { Meter = true, RegisterPacket = true, RunGreenEffect = true, GreenCelebration = true, Output = true, ShowFeedback = true,
UpdateGreenWindow = true, GreenToggle = true }
Shot.fbIdx, Shot.fbIdxT = nil, 0
function Shot.fromIdx(idx)
if idx == 5 then return "green", 0 end
if idx == 4 then return "good", 1 end
if idx and idx < 4 then return "early", 4 - idx end
if idx and idx > 5 then return "late", idx - 5 end
return nil
end
function Shot.connectRemotes()
local function watch(d)
if d:IsA("RemoteEvent") and Shot.remoteNames[d.Name] then
bind(d.OnClientEvent, function(...) pcall(Shot.onRemoteEvent, d.Name, ...) end)
end
end
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do watch(d) end
bind(ReplicatedStorage.DescendantAdded, watch)
end
function Shot.onShootCall(args)
local d = args[1]
if type(d) ~= "table" or Shot.selfFire then return false end
local now = tick()
if Rec.shotOn then Rec.shotAdd("SHOOT remote Shoot=" .. tostring(d.Shoot) .. " Input=" .. tostring(d.Input) .. " UseSpace=" .. tostring(d.UseSpace)) end
if d.Shoot == true then
Shot.pressT = now
if S.ShotGlide then Mover.watchShot(now) end
if S.AutoGreen and not Shot.busy then
local ctx = { t0 = now, ended = false, space = d.UseSpace == true, btn = Input.lastTouch and Input.lastTouch.obj }
Shot.remoteCtx = ctx
task.defer(Shot.run, "remote", ctx)
end
elseif d.Shoot == false then
local ctx = Shot.remoteCtx
if ctx and Shot.busy and not ctx.released then
if S.ShotStyle == "Tap" and S.AutoGreen then
ctx.dropped = true
return true
end
ctx.ended = true
return false
end
if S.AutoGreen and now - Shot.releasedT < 2.5 then return true end
end
return false
end
Shot.FLOOR = 0.205
Shot.brackets = {}
function Shot.remoteKey(cap, sit)
local ids = {}
for _, tr in ipairs(cap.tracks) do
local id = Anim.idOf(tr)
if id ~= "" then ids[#ids + 1] = string.gsub(id, "rbxassetid://", "") end
end
table.sort(ids)
if #ids == 0 then return "sit:" .. sit end
return table.concat(ids, "+")
end
Shot.SWEEPSCALE = { ["71484695722621"] = 1, ["77401448272074"] = 1, ["128777513307709+77401448272074"] = 1 }
Shot.SWEEPLIST = {
["77401448272074"] = { 0.006, 0.012, 0.018, 0.024, 0.030, 0.036, 0.042, 0.048 },
["128777513307709+77401448272074"] = { 0.006, 0.012, 0.018, 0.024, 0.030, 0.036, 0.042, 0.048 },
}
Shot.FINAL = {
["15851912457+15851919155"] = 0.357,
["15851912457+15851919155+17285155256"] = 0.357,
["111074210919383"] = 0.357,
["71484695722621"] = 0.311,
["77401448272074"] = 0.329,
["128777513307709+77401448272074"] = 0.329,
}
Shot.VERDICT = { "Very early", "Early", "Slightly early", "Good", "Perfect", "Slightly late", "Late", "Very late" }
Shot.NAMES = {
["15851912457+15851919155"] = "Jump Shot 1",
["15851912457+15851919155+17285155256"] = "Jump Shot 1 (fake)",
["111074210919383"] = "Post fade",
["71484695722621"] = "Post spin fade (left)",
["77401448272074"] = "Post spin fade (right)",
["128777513307709+77401448272074"] = "Post spin fade (right)",
}
Shot.adjLog = {}
Shot.cur, Shot.last = nil, nil
function Shot.noteAdjust(key, from, to, why)
table.insert(Shot.adjLog, 1, { t = tick(), key = key, from = from, to = to, why = why })
while #Shot.adjLog > 6 do table.remove(Shot.adjLog) end
end
local function agoText(t)
local d = math.max(0, tick() - t)
if d < 60 then return string.format("%ds ago", math.floor(d)) end
return string.format("%dm ago", math.floor(d / 60))
end
function Shot.nameFor(key, anim)
local n = Shot.NAMES[key]
if n then return n end
if anim and anim ~= "" then return tostring(anim) end
return "Shot " .. string.sub(tostring(key), -6)
end
function Shot.statusLines()
local cur = Shot.cur
if not cur then
local c0, p0 = Shot.pingComp()
return "-", "-", "Shoot to see it", "-", "No change yet", S.PerfectGreen and string.format("%.0f ms earlier (ping %.0f ms)", c0 * 1000, p0 * 1000) or string.format("off (ping %.0f ms)", p0 * 1000)
end
local last = "-"
if Shot.last then
local l = Shot.last
local v = (l.idx and Shot.VERDICT[l.idx]) or (l.res == "green" and "Perfect") or (l.res == "good" and "Good") or tostring(l.res)
last = string.format("%s at %.3fs", v, l.held or 0)
end
local lines = {}
for i = 1, math.min(4, #Shot.adjLog) do
local a = Shot.adjLog[i]
lines[#lines + 1] = string.format("%s: %.3f -> %.3fs (%s)", agoText(a.t), a.from, a.to, a.why)
end
local comp, p = Shot.pingComp()
local ptxt
if S.PerfectGreen then ptxt = string.format("%.0f ms earlier (ping %.0f ms)", comp * 1000, p * 1000) else ptxt = string.format("off (ping %.0f ms)", p * 1000) end
return Shot.nameFor(cur.key, cur.anim), string.format("%.3fs", cur.hold), cur.state or "-", last,
(#lines > 0) and table.concat(lines, "\n") or "No change yet", ptxt
end
function Shot.statusStep()
local st = UI.autoStat
if not st then return end
local now = tick()
if Shot.statusT and now - Shot.statusT < 0.25 then return end
Shot.statusT = now
local a, b, c, d, e, f = Shot.statusLines()
st.shot.Text, st.timing.Text, st.state.Text, st.last.Text, st.adj.Text = a, b, c, d, e
if st.ping then st.ping.Text = f end
local dt = UI.detStat
if dt then
pcall(Anim.detStep)
local n1, n2, n3 = Anim.detText()
dt.now.Text, dt.type.Text, dt.list.Text = n1, n2, n3
end
end
Shot.PING_REF = 0.022
function Shot.pingNow()
local ok, p = pcall(function() return LP:GetNetworkPing() end)
p = (ok and type(p) == "number") and p or Shot.PING_REF
Shot.pingEma = Shot.pingEma and (Shot.pingEma * 0.7 + p * 0.3) or p
return Shot.pingEma
end
function Shot.pingComp()
local p = Shot.pingNow()
if not S.PerfectGreen then return 0, p end
local comp = (p - Shot.PING_REF) * ((S.PerfectGreenPct or 100) / 100)
return clamp(comp, -0.02, 0.2), p
end
Shot.AUTO_START = 0.34
Shot.AUTO_SCAN = { 0.30, 0.32, 0.34, 0.36, 0.38, 0.31, 0.33, 0.35, 0.37, 0.29, 0.39, 0.40, 0.28 }
Shot.auto = {}
Shot.autoLoaded = false
function Shot.autoLoad()
if Shot.autoLoaded then return end
Shot.autoLoaded = true
Shot.auto = {}
for kind, key, val in string.gmatch(S.AutoTimes or "", "(%a):(%S-)=([%d%.]+)") do
Shot.auto[key] = { hold = tonumber(val), greens = {}, locked = kind == "L", dir = 1 }
end
end
function Shot.autoSave()
local parts = {}
for key, a in pairs(Shot.auto) do parts[#parts + 1] = string.format("%s:%s=%.3f", a.locked and "L" or "P", key, a.hold) end
table.sort(parts)
S.AutoTimes = table.concat(parts, " ")
saveSoon()
end
function Shot.autoReset()
Shot.autoLoaded = true
Shot.auto = {}
S.AutoTimes = ""
saveSoon()
end
function Shot.autoActive(key)
if not S.AutoCal or Shot.FINAL[key] then return false end
if S.Sweep and Rec.shotOn then return false end
if Shot.times["la:" .. key] or Shot.times["r:" .. key] then return false end
return true
end
function Shot.autoLearn(info, res, strength)
local key = info.key
if not Shot.autoActive(key) then return false end
Shot.autoLoad()
local a = Shot.auto[key]
if not a then return false end
if a.locked then return true end
local held = (info.held or 0) + (info.comp or 0)
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if not idx or not held then return true end
if info.manual and idx ~= 5 then return true end
if not info.manual and math.abs(held - a.hold) > 0.06 then return true end
a.n = (a.n or 0) + 1
local before, wasLocked = a.hold, a.locked
local step = true
if idx == 5 then
step = false
a.greens[#a.greens + 1] = held
a.miss = 0
local sum = 0
for _, g in ipairs(a.greens) do sum = sum + g end
a.hold = sum / #a.greens
if #a.greens >= 2 then
a.locked = true
pcall(notify, "Auto Green", string.format("Learned a new shot: %.3fs", a.hold), 3)
end
elseif #a.greens >= 1 then
a.miss = (a.miss or 0) + 1
if a.miss >= 3 then
a.greens = {}
a.miss = 0
else
step = false
end
end
if step then
if idx == 4 then
a.hold = held + 0.006 * a.dir
elseif idx <= 3 then
a.dir = 1
a.hold = held + (idx == 3 and 0.010 or (idx == 2 and 0.020 or 0.035))
else
a.dir = -1
a.hold = held - (idx == 6 and 0.010 or (idx == 7 and 0.020 or 0.035))
end
end
a.hold = clamp(a.hold, Shot.FLOOR, S.MaxHold)
if a.locked and not wasLocked then
Shot.noteAdjust(key, before, a.hold, "Perfect x2, locked")
elseif math.abs(a.hold - before) > 0.0005 then
Shot.noteAdjust(key, before, a.hold, (Shot.VERDICT[idx] or "?") .. ((a.dir or 1) > 0 and ", going later" or ", going earlier"))
end
Shot.autoSave()
if Rec.shotOn then
Rec.shotAdd(string.format("AUTOCAL key=%s idx=%s held=%.3f next=%.3f greens=%d locked=%s", key, tostring(idx), held, a.hold, #a.greens, tostring(a.locked)))
end
return true
end
function Shot.remoteHold(key, pk)
local fin = Shot.FINAL[key]
if fin then
Shot.lastSweep = nil
Shot.cur = { key = key, hold = fin, state = "Locked (built in)" }
return clamp(fin, Shot.FLOOR, S.MaxHold), fin
end
if Shot.autoActive(key) then
Shot.autoLoad()
local a = Shot.auto[key]
if not a then
a = { hold = Shot.times[key] or Shot.AUTO_START, greens = {}, locked = false, dir = 1 }
Shot.auto[key] = a
end
Shot.lastSweep = nil
local state = a.locked and "Locked (learned)" or (#a.greens >= 1 and string.format("Learning (%d of 2 Perfects)", #a.greens)) or ((a.n or 0) > 0 and ((a.dir or 1) > 0 and "Learning, trying later" or "Learning, trying earlier")) or "Learning"
Shot.cur = { key = key, hold = a.hold, state = state }
return clamp(a.hold, Shot.FLOOR, S.MaxHold), a.hold
end
local base = Shot.times[key]
local ratio = Shot.times["r:" .. key]
if ratio and pk and pk > 0 then base = pk * ratio end
local la, lb = Shot.times["la:" .. key], Shot.times["lb:" .. key]
if la and lb and pk and pk > 0 then base = la + lb * pk end
if not base then
base = pk and pk * S.PacketMul or S.HoldTime
end
local hold = base + S.Nudge / 1000
Shot.lastSweep = nil
if S.Sweep and Rec.shotOn and not Shot.times["la:" .. key] then
Shot.sweepN = Shot.sweepN or {}
local i = (Shot.sweepN[key] or 0) + 1
Shot.sweepN[key] = i
local lst = Shot.SWEEPLIST[key] or Shot.SWEEP
local off = lst[(i - 1) % #lst + 1]
if not Shot.SWEEPLIST[key] then off = off * (Shot.SWEEPSCALE[key] or 2.5) end
hold = hold + off
Shot.lastSweep = off
Rec.shotAdd(string.format("SWEEP key=%s step=%d offset=%+.3f", key, i, off))
end
Shot.cur = { key = key, hold = hold, state = (S.Sweep and Rec.shotOn) and "Sweep recording" or (S.AutoCal and "Fixed timing" or "Auto-learn off") }
return clamp(hold, Shot.FLOOR, S.MaxHold), base
end
Shot.SWEEP = { -0.036, -0.030, -0.024, -0.018, -0.012, -0.006, 0, 0.006, 0.012, 0.018, 0.024, 0.030, 0.036 }
Shot.greenKeys = {}
function Shot.learnRemote(info, res, strength)
if info then
local ch = char()
Shot.last = { t = tick(), held = info.held, idx = info.idx, res = res, key = info.key }
if Shot.cur and Shot.cur.key == info.key and ch then Shot.cur.anim = ch:GetAttribute("BaseAnimation") end
end
if info and Shot.FINAL[info.key] then return end
if info and Shot.autoLearn(info, res, strength) then return end
if not S.Learn or (S.Sweep and Rec.shotOn) then return end
local key, held = info.key, info.held + (info.comp or 0)
local new
if info.manual then
if res == "green" then new = held end
elseif res == "early" and (strength or 2) >= 3 then
new = held + 0.07
elseif Shot.times["la:" .. key] then
return
elseif info.pk and info.pk > 0 and Shot.times["r:" .. key] and res ~= "early" then
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "late" and 5 + (strength or 2))
local est = (held - (idx - 5) * 0.006) / info.pk
local old = Shot.times["r:" .. key]
local rate = res == "green" and 0.7 or (Shot.greenKeys[key] and 0.1 or 0.35)
if res == "green" then Shot.greenKeys[key] = true end
Shot.times["r:" .. key] = clamp(old + rate * (est - old), 0.5, 3)
Shot.saveTimes()
return
else
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx then
local est = held - (idx - 5) * 0.014
local old = Shot.times[key] or held
local rate = res == "green" and 0.7 or (Shot.greenKeys[key] and 0.12 or 0.45)
if res == "green" then Shot.greenKeys[key] = true end
new = old + rate * (est - old)
end
if res == "green" and info.pk and info.pk > 0 then S.PacketMul = clamp(S.PacketMul * 0.5 + (held / info.pk) * 0.5, 0.4, 3) end
end
if new then
Shot.times[key] = clamp(new, Shot.FLOOR, S.MaxHold)
Shot.saveTimes()
end
end
Shot.lastBin = nil
function Shot.meterQ()
local c = char()
local v = c and c:GetAttribute("meterOffset")
if typeof(v) == "Vector2" or typeof(v) == "Vector3" then return -v.Y end
return nil
end
function Shot.learnMeter(info)
local relQ, idx = info.relQ, info.idx
if not relQ or not idx then return end
if idx == 5 then
S.MeterTarget = S.MeterTarget * 0.5 + relQ * 0.5
else
if Shot.lastBin and Shot.lastBin.idx ~= idx then
local bw = math.abs(relQ - Shot.lastBin.q) / math.abs(idx - Shot.lastBin.idx)
S.MeterBin = clamp(S.MeterBin * 0.5 + bw * 0.5, 0.008, 0.12)
end
S.MeterTarget = relQ + (5 - idx) * S.MeterBin
end
S.MeterTarget = clamp(S.MeterTarget, 0.3, 1.6)
Shot.lastBin = { idx = idx, q = relQ }
saveSoon()
end
function Shot.remoteCore(ctx)
local snap = Shot.textSnapshot()
local since = { green = Shot.greenT, fb = Shot.fbT, fake = true, idxT = Shot.fbIdxT }
local samples = {}
local mconn
do
local c = char()
if c then
local ok, sig = pcall(function() return c:GetAttributeChangedSignal("meterOffset") end)
if ok and sig then
mconn = sig:Connect(function()
local q = Shot.meterQ()
if q then samples[#samples + 1] = { t = tick(), q = q } end
end)
end
end
end
local t0 = ctx.t0
local cap = { t0 = t0 - 0.05, tracks = {} }
Shot.cap = cap
local waitEnd = tick() + 0.5
while tick() < waitEnd and Shot.meterT < t0 - 0.05 do RunService.Heartbeat:Wait() end
if Shot.meterT < t0 - 0.05 then
Shot.cap = nil
if ctx.dropped and not ctx.ended then Shot.fireRemote(false) end
return
end
local m0 = Shot.meterT
for i = #samples, 1, -1 do
if samples[i].t < m0 - 0.05 then table.remove(samples, i) end
end
do
local ch = char()
if ch and ch:GetAttribute("Action") == "Gathering" then
local we = tick() + 1.5
while #samples == 0 and tick() < we do RunService.Heartbeat:Wait() end
if #samples > 0 then m0 = samples[1].t end
end
end
local pw = tick() + 0.12
while (Shot.packetT < m0 - 0.01 or #cap.tracks == 0) and tick() < pw do RunService.Heartbeat:Wait() end
local pk = Shot.packetT >= m0 - 0.01 and Shot.packet or nil
local sit = Shot.situation()
local key = Shot.remoteKey(cap, sit)
Shot.cap = nil
local hold, base = Shot.remoteHold(key, pk)
local comp = Shot.pingComp()
if comp ~= 0 then hold = math.max(Shot.FLOOR, hold - comp) end
if Shot.cur then Shot.cur.comp = comp end
local manual = false
local usedMeter, qpred = false, nil
local ok0, ping0 = pcall(function() return LP:GetNetworkPing() end)
local lead = (ok0 and ping0 or 0.04) + 0.016 + S.Nudge / 1000
while tick() - m0 < S.MaxHold do
if ctx.ended then
manual = true
break
end
local now = tick()
local n = #samples
if S.MeterAim and n >= 3 and now - samples[n].t < 0.15 then
local a, b = samples[math.max(1, n - 3)], samples[n]
local dt = b.t - a.t
if dt > 0.01 then
local rate = (b.q - a.q) / dt
if rate > 0.05 then
usedMeter = true
qpred = b.q + rate * ((now - b.t) + lead)
if qpred >= S.MeterTarget then break end
end
end
elseif now - m0 >= hold - 0.02 then
break
end
RunService.Heartbeat:Wait()
end
if mconn then pcall(function() mconn:Disconnect() end) end
local last, stuck = tick(), 0
while not usedMeter and not manual and not ctx.ended and tick() - m0 < hold do
local n = tick()
if n == last then
stuck = stuck + 1
if stuck > 20000 then break end
else
last, stuck = n, 0
end
end
while not manual and not ctx.ended and tick() - m0 < hold do RunService.Heartbeat:Wait() end
local held = tick() - m0
if not manual then Shot.release("remote", ctx) end
ctx.released = true
Shot.stats.shots = Shot.stats.shots + 1
Shot.lastType = key
Shot.lastRelease = manual and "you" or "timing"
if Rec.on then
Rec.add("shot", string.format("remote shot key=%s packet=%s hold=%.3f base=%.3f held=%.3f released by %s style=%s space=%s", key, tostring(pk), hold,
base, held, Shot.lastRelease, tostring(S.ShotStyle), tostring(ctx.space)))
end
if Rec.shotOn then
Rec.shotAdd(string.format("RELEASE meter=%s target=%.3f predicted=%s samples=%d key=%s packet=%s hold=%.4f held=%.4f by=%s style=%s ping=%s comp=%.4f", tostring(usedMeter), S.MeterTarget, tostring(qpred), #samples, key, tostring(pk), hold, held,
Shot.lastRelease, tostring(S.ShotStyle), tostring(pcall(function() return LP:GetNetworkPing() end) and LP:GetNetworkPing() or "?"), comp))
end
task.spawn(Shot.evaluate, { snap = snap, since = since, sit = sit, key = key, base = base, held = held, manual = manual,
pk = pk, remote = true, usedBar = false, usedMeter = usedMeter, qpred = qpred, comp = manual and 0 or comp })
end
function Shot.core(mode, ctx)
if mode == "remote" then return Shot.remoteCore(ctx) end
local sit = Shot.situation()
local snap = Shot.textSnapshot()
local wide = Bar.isArmed() or Rec.on or (not Bar.selected() and Bar.misses >= 2 and Bar.misses < 10)
local watcher = Bar.watch(wide)
local cap = { t0 = (ctx and ctx.t0) or tick(), tracks = {} }
Shot.cap = cap
Glide.fire("shot", "shot start")
if mode == "backup" then
local ok, err = Backup.send(true)
if not ok then
Shot.cap = nil
log("Backup press failed: " .. tostring(err))
return
end
end
local t0 = cap.t0
local useBar = S.ShotRelease ~= "Timing" and Bar.selected() and S.BarAt > 0
local track
local hold, key, base = Shot.holdFor(sit, nil)
local manual = false
while tick() - t0 < S.MaxHold do
RunService.Heartbeat:Wait()
if mode == "manualKey" and ctx.kc and not UIS:IsKeyDown(ctx.kc) then
manual = true
break
end
if mode == "touch" and ctx.ended then
manual = true
break
end
track = Shot.pickTrack(cap)
hold, key, base = Shot.holdFor(sit, track)
if wide then hold = math.max(hold, 0.5) end
local delta = Bar.step(watcher)
if useBar and watcher.live then
if delta and delta >= Bar.threshold() then break end
if watcher.lastMove and tick() - watcher.lastMove > 0.25 then break end
elseif tick() - t0 >= hold then
break
end
end
local held = tick() - t0
if not manual then Shot.release(mode, ctx) end
Shot.cap = nil
Shot.stats.shots = Shot.stats.shots + 1
local usedBar = useBar and watcher.live and not manual
local barDelta = Bar.finish(watcher)
Shot.lastType = Shot.nameOf(track, sit)
Shot.lastRelease = manual and "you" or (usedBar and "bar" or "timing")
if Rec.on then
Rec.add("shot", string.format("type=%s key=%s situation=%s held=%.3f base=%.3f released by %s barDelta=%s", Shot.lastType,
tostring(key), sit, held, base or 0, Shot.lastRelease, barDelta and string.format("%.3f", barDelta) or "-"))
end
task.spawn(Shot.evaluate, { snap = snap, sit = sit, key = key, track = track, base = base, held = held,
usedBar = usedBar, barDelta = barDelta, manual = manual })
end
function Shot.run(mode, ctx)
if Shot.busy then return end
Shot.busy = true
local ok, err = pcall(Shot.core, mode, ctx)
if not ok then
log("Shot error: " .. tostring(err))
pcall(Shot.release, mode, ctx)
end
if mode == "remote" then
if ctx then ctx.released = true end
Shot.remoteCtx = nil
end
task.wait(0.15)
Shot.busy = false
end
Shot.seenText = {}
function Shot.onMessage(res, tx)
if Shot.hooked then return end
local t = Input.lastTouch
if Shot.busy or not t or not t.obj or not t.endT or tick() - t.endT > 1.2 or t.endT - t.t0 < 0.15 then return end
local found = Input.findButton("Shoot")
if found and Input.hits(found, t.pos) then return end
S.ShootButtonPath = Input.pathOf(t.obj)
Input.cache.Shoot = nil
saveSoon()
log("Shoot button learned from your shot: " .. S.ShootButtonPath)
notify("Shoot button found", t.obj.Name, 3)
end
function Shot.watch()
for d in pairs(Shot.labels) do
if not d.Parent then
Shot.labels[d] = nil
else
local tx = d.Text
if tx ~= Shot.seenText[d] then
Shot.seenText[d] = tx
if tx ~= "" and visibleChain(d) and Shot.classify(tx) then Shot.onMessage(Shot.classify(tx), tx) end
end
end
end
end
function Backup.send(isDown)
local btn = Input.findButton("Shoot")
if not btn then return false, "shoot button not found: use Pick in the Shooting tab" end
local c = btn.AbsolutePosition + btn.AbsoluteSize / 2
local x = c.X
local y = c.Y + (S.BackupInset and insetHeight() or 0)
local m = S.BackupMethod
if m == "touch" then
if not VIM then return false, "no VirtualInputManager" end
return pcall(function() VIM:SendTouchEvent(87, isDown and 0 or 2, x, y) end)
elseif m == "mouse" then
if not VIM then return false, "no VirtualInputManager" end
return pcall(function() VIM:SendMouseButtonEvent(x, y, 0, isDown, game, 1) end)
end
if type(firesignal) ~= "function" then return false, "no firesignal" end
return pcall(function() firesignal(isDown and btn.MouseButton1Down or btn.MouseButton1Up, x, y) end)
end
local moveParams = RaycastParams.new()
moveParams.FilterType = Enum.RaycastFilterType.Exclude
moveParams.RespectCanCollide = true
Glide.token = 0
Glide.lastStart = {}
Glide.methods = { "Auto", "CFrame", "Input", "AttrBoost", "Velocity", "Impulse" }
Glide.chain = { "CFrame", "Input", "AttrBoost", "Velocity", "Impulse" }
Glide.input = nil
Glide.cur = 1
Glide.last = "no glide yet"
Glide.lastNote = 0
Glide.kinds = {
dribble = { "DribbleGlide", "DribbleGlidePower", "DribbleGlideTime" },
gather = { "GatherGlide", "GatherGlidePower", "GatherGlideTime" },
shot = { "ShotGlide", "ShotGlidePower", "ShotGlideTime" },
}
function Glide.blocked(r, dir, dist)
if not S.GlideStopAtWalls then return false end
local ignore = { char() }
if Ball.nearest then table.insert(ignore, Ball.nearest) end
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LP and p.Character then table.insert(ignore, p.Character) end
end
moveParams.FilterDescendantsInstances = ignore
local hit = workspace:Raycast(r.Position, dir * (dist + 1.6), moveParams)
if not hit then return false end
local part = hit.Instance
if not part.Anchored then return false end
local s = part.Size
if math.max(s.X, s.Y, s.Z) < 3 then return false end
Speed.blockedBy = part.Name
return true
end
function Glide.judge(kind, method, startPos, dir, power, duration, fadeStart, baseVel, why)
local r = hrp() or Mover.body()
if not r then return end
local moved = (r.Position - startPos):Dot(dir)
local expected = power * duration * (2 / math.pi)
local extra = moved - math.max(baseVel, 0) * duration
local ratio = expected > 0 and extra / expected or 0
Glide.last = string.format("%s (%s) via %s: moved %.1f of %.1f studs", kind, why or "?", method, extra, expected)
log("Glide " .. Glide.last)
Glide.fails = Glide.fails or 0
if ratio >= 0.3 then
Glide.fails = 0
if tick() - Glide.lastNote > 10 then
Glide.lastNote = tick()
notify("Glide", "WORKS", 2)
end
else
Glide.fails = Glide.fails + 1
if S.GlideMethod == "Auto" then Glide.cur = Glide.cur % #Glide.chain + 1 end
if tick() - Glide.lastNote > 6 then
Glide.lastNote = tick()
if Glide.fails >= #Glide.chain or S.GlideMethod ~= "Auto" then
Glide.fails = 0
notify("Glide", "DOESN'T WORK", 3)
else
notify("Glide", "not yet, trying another way", 2)
end
end
end
end
function Glide.start(kind, power, duration, dirOverride)
local r, h = Mover.body(), hum()
power = power * (S.GlideSpeed or 1)
if not r or not h or power <= 0 or duration <= 0 then return end
local now = tick()
if now - (Glide.lastStart[kind] or 0) < duration * 0.6 then return end
Glide.lastStart[kind] = now
local intent = Mover.intent(h, r)
local dir = flat(intent)
if dirOverride and flat(dirOverride).Magnitude > 0.1 then dir = flat(dirOverride) end
if dir.Magnitude < 0.1 then dir = flat(r.CFrame.LookVector) end
if dir.Magnitude < 0.01 then return end
dir = dir.Unit
local method = S.GlideMethod
if method == "Auto" then method = Glide.chain[Glide.cur] end
Glide.token = Glide.token + 1
local token = Glide.token
local fadeStart = 1 - clamp(S.GlideFade, 0, 100) / 100
local seen = hrp()
local startPos = (seen or r).Position
local baseVel = Mover.vel:Dot(dir)
local why = Glide.why
local walk = flat(intent) * Speed.gameWS
if method == "Input" then
Glide.input = { untilT = now + duration, scale = 1 + power / math.max(Speed.gameWS, 1), dir = dir, t0 = now, nextSend = 0 }
end
if method == "Impulse" then
pcall(function() r:ApplyImpulse(dir * r.AssemblyMass * power) end)
end
local function restoreAttr()
local c = char()
if c and method == "AttrBoost" then
c:SetAttribute("SpeedBoost", 0)
c:SetAttribute("SpeedBoostTime", 0)
c:SetAttribute("AccelerationBoost", 0)
end
end
local startedAt = now
local function frame(dt)
if method == "Input" and token == Glide.token then
local c = char()
if c and c:GetAttribute("CanMove") == false and tick() - startedAt < 1.5 then
now = tick()
if Glide.input then
Glide.input.untilT = now + duration
Glide.input.paused = true
end
return nil
end
if Glide.input then Glide.input.paused = false end
end
local p = (tick() - now) / duration
if token ~= Glide.token or p >= 1 or not r.Parent or not JH.Running then
restoreAttr()
if token == Glide.token then
task.delay(0.15, function()
if token == Glide.token then pcall(Glide.judge, kind, method, startPos, dir, power, duration, fadeStart, baseVel, why) end
end)
end
return "stop"
end
if method == "Impulse" then return nil end
local factor = math.sin(math.pi * clamp(p, 0, 1))
if method == "AttrBoost" then
local c = char()
if c then
c:SetAttribute("SpeedBoost", power * factor / math.max(Speed.gameWS, 1))
c:SetAttribute("SpeedBoostTime", 0.25)
c:SetAttribute("AccelerationBoost", 0.5)
end
return nil
end
if method == "Input" then
local gi = Glide.input
if not gi then return "stop" end
gi.scale = 1 + power * factor / math.max(Speed.gameWS, 1)
local game = Mover.gameIntent()
if (not game or game.Magnitude < 0.05) and tick() >= gi.nextSend then
gi.nextSend = tick() + 0.05
Mover.send(dir * gi.scale)
end
return nil
end
local step = power * factor * dt
if Glide.blocked(r, dir, step) then return "stop" end
if method == "Velocity" then
local v = r.AssemblyLinearVelocity
local t = walk + dir * (power * factor)
r.AssemblyLinearVelocity = Vector3.new(t.X, v.Y, t.Z)
else
r.CFrame = r.CFrame + dir * step
Mover.sync(r)
end
return nil
end
local conn
conn = RunService.Stepped:Connect(function(_, dt)
local ok, res = pcall(frame, dt)
if not ok then
Glide.lastErr = tostring(res)
log("Glide error: " .. Glide.lastErr)
notify("Glide problem", Glide.lastErr, 5)
conn:Disconnect()
elseif res == "stop" then
conn:Disconnect()
end
end)
end
function Glide.fire(kind, why, dir)
local k = Glide.kinds[kind]
if not k or not S[k[1]] then return end
if S.GlideNeedBall and kind ~= "shot" and not Ball.holding then
log("Glide " .. kind .. " skipped: you do not hold the ball")
return
end
Glide.why = why or "?"
Glide.start(kind, S[k[2]], S[k[3]], dir)
end
function Glide.test(kind)
local k = Glide.kinds[kind]
if not k then return end
Glide.lastStart[kind] = 0
Glide.why = "test button"
Glide.start(kind, S[k[2]], S[k[3]])
end
Speed.gameWS = 16
Speed.lastSet = nil
Speed.lastPos = nil
Speed.lastMove = nil
Speed.actual = 0
Speed.extra = 0
Speed.level = 0
Speed.rubberTimes = {}
Speed.lastRubberNote = 0
Speed.lastRubber = 0
Speed.test = nil
Speed.testing = false
Speed.src = "none"
Speed.blockedBy = "-"
Speed.channels = { "Auto", "Input", "AttrWS", "AttrBoost", "CFrame", "Velocity", "WalkSpeed", "GameValues" }
Speed.chain = { "CFrame", "Velocity", "WalkSpeed", "GameValues" }
Speed.inputScale = 1
Speed.probe = nil
Speed.methods = Speed.channels
Speed.minWS = 16
Speed.auto = { idx = 1, t = 0, d = 0, e = 0, w = 0, results = {}, locked = nil, lastDir = nil }
Speed.gv = { items = {}, found = 0, scanning = false, applied = false }
function Speed.isRunning()
local mode = S.RunDetect
if mode == "Never" then return false end
if mode == "Always" then return true end
local c = char()
if c and c:GetAttribute("Sprinting") == true then return true end
if Input.sprintTouch or Input.held.Sprint then return true end
local k = Input.keyCode(S.SprintKey)
if k and UIS:IsKeyDown(k) then return true end
if mode == "Sprint button" then return false end
return Speed.gameWS >= Speed.minWS * 1.4 and Speed.gameWS - Speed.minWS >= 4
end
Speed.PER_LEVEL = 0.75
function Speed.pick()
if Ball.holding then
if S.BallSpeedOn then return "ball", S.BallAdd end
return nil, 0
end
if Speed.isRunning() then
if S.RunOn then return "run", S.RunAdd end
return nil, 0
end
if S.SpeedOn then return "walk", S.SpeedAdd end
return nil, 0
end
function Speed.extraNow()
local kind, level = Speed.pick()
Speed.kind = kind
local extra = kind and level * Speed.PER_LEVEL or 0
extra = clamp(extra, 0, S.SpeedCap)
if S.AntiRubber and Speed.level > 0 then extra = extra / (1 + Speed.level) end
return extra
end
function Speed.noteRubber()
if workspace:FindFirstChild("ProxyCharacter") then return end
local now = tick()
Speed.lastRubber = now
table.insert(Speed.rubberTimes, now)
while #Speed.rubberTimes > 0 and now - Speed.rubberTimes[1] > 3 do table.remove(Speed.rubberTimes, 1) end
if #Speed.rubberTimes >= 3 and S.AntiRubber then
Speed.rubberTimes = {}
Speed.level = math.min(Speed.level + 1, 3)
if now - Speed.lastRubberNote > 10 then
Speed.lastRubberNote = now
notify("Speed boost", "The game keeps pulling you back, so the boost was lowered", 3)
end
end
end
function Speed.resetAuto()
Speed.probe = nil
Speed.rep = nil
Speed.auto = { idx = 1, t = 0, d = 0, e = 0, w = 0, results = {}, locked = nil, lastDir = nil }
Speed.gvRestore()
end
local SPEED_WORDS = { "speed", "sprint", "walkspeed", "runspeed" }
local SPEED_SKIP = { "anim", "fire", "reload", "cooldown", "rate", "turn", "jump", "swim", "climb", "shot", "pass" }
function Speed.gvAccept(name, v)
if type(name) ~= "string" or type(v) ~= "number" or v < 3 or v > 150 then return false end
local n = string.lower(name)
return matchAny(n, SPEED_WORDS) and not matchAny(n, SPEED_SKIP)
end
function Speed.gvScan()
local gv = Speed.gv
if gv.scanning then return end
gv.scanning = true
gv.items = {}
task.spawn(function()
pcall(function()
for _, inst in ipairs({ char(), LP, hum() }) do
if inst then
for k, v in pairs(inst:GetAttributes()) do
if Speed.gvAccept(k, v) then table.insert(gv.items, { kind = "attr", inst = inst, key = k, orig = v, last = v }) end
end
end
end
end)
for _, root in ipairs({ char(), LP }) do
if root then
pcall(function()
for _, d in ipairs(root:GetDescendants()) do
if (d:IsA("NumberValue") or d:IsA("IntValue")) and Speed.gvAccept(d.Name, d.Value) then
table.insert(gv.items, { kind = "val", inst = d, orig = d.Value, last = d.Value })
end
end
end)
end
end
if type(getgc) == "function" then
pcall(function()
local list = getgc(true)
for i, t in ipairs(list) do
if type(t) == "table" and getmetatable(t) == nil then
pcall(function()
local count = 0
for k, v in next, t do
count = count + 1
if count > 60 then break end
if Speed.gvAccept(k, v) then
table.insert(gv.items, { kind = "tbl", tbl = t, key = k, orig = v, last = v })
end
end
end)
end
if i % 800 == 0 then task.wait() end
end
end)
end
gv.found = #gv.items
gv.scanning = false
log("Game speed values found: " .. gv.found)
end)
end
function Speed.gvSet(ratio)
local gv = Speed.gv
if #gv.items == 0 and not gv.scanning then Speed.gvScan() end
for _, it in ipairs(gv.items) do
pcall(function()
local cur
if it.kind == "attr" then cur = it.inst:GetAttribute(it.key)
elseif it.kind == "val" then cur = it.inst.Value
else cur = rawget(it.tbl, it.key) end
if cur ~= it.last and type(cur) == "number" then it.orig = cur end
local v = it.orig * ratio
if it.kind == "attr" then it.inst:SetAttribute(it.key, v)
elseif it.kind == "val" then it.inst.Value = v
else rawset(it.tbl, it.key, v) end
it.last = v
end)
end
gv.applied = true
end
function Speed.gvRestore()
local gv = Speed.gv
if not gv.applied then return end
for _, it in ipairs(gv.items) do
pcall(function()
if it.kind == "attr" then it.inst:SetAttribute(it.key, it.orig)
elseif it.kind == "val" then it.inst.Value = it.orig
else rawset(it.tbl, it.key, it.orig) end
it.last = it.orig
end)
end
gv.applied = false
end
Speed.gameChain = { "CFrame", "Input", "AttrWS", "AttrBoost" }
Speed.gameChainNames = {
Input = "a bigger stick signal", AttrWS = "the character's WalkSpeed value", AttrBoost = "the character's SpeedBoost value", CFrame = "moving the character",
}
function Speed.inputStep(dt, intent, extra, frameMove)
local p = Speed.probe
if not p then
p = { t = 0, d = 0, base = nil, idx = 1, locked = nil, results = {} }
Speed.probe = p
end
if extra <= 0 or intent.Magnitude < 0.5 then
p.t, p.d = 0, 0
return p.locked or Speed.gameChain[p.idx], extra
end
local dir = intent.Unit
if p.lastDir and dir:Dot(p.lastDir) < 0.7 then p.t, p.d = 0, 0 end
p.lastDir = dir
p.t = p.t + dt
p.d = p.d + frameMove
if not p.base then
if p.t >= 0.5 then
if p.d / p.t >= 1.5 then p.base = p.d / p.t end
p.t, p.d = 0, 0
end
return Speed.gameChain[p.idx], 0
end
if p.locked then return p.locked, extra end
local m = Speed.gameChain[p.idx]
if p.t >= 1.2 then
local v = p.d / p.t
p.results[m] = v
log(string.format("Speed through %s: %.1f studs/s, %.1f without", Speed.gameChainNames[m], v, p.base))
if v >= p.base * 1.2 then
p.locked = m
notify("Speed boost", "WORKS", 3)
else
p.idx = p.idx + 1
p.t, p.d = 0, 0
if p.idx > #Speed.gameChain then
p.locked = "Input"
notify("Speed boost", "DOESN'T WORK", 4)
else
notify("Speed boost", "not yet, trying another way", 2)
end
m = p.locked or Speed.gameChain[p.idx]
end
end
return m, extra
end
Speed.normal = nil
function Speed.report(dt, intent, extra, move)
local p = Speed.rep
if not p then
p = { t = 0, d = 0, noted = false }
Speed.rep = p
end
if intent.Magnitude < 0.5 then
p.t, p.d = 0, 0
return
end
local dir = intent.Unit
if p.lastDir and dir:Dot(p.lastDir) < 0.7 then p.t, p.d = 0, 0 end
p.lastDir = dir
p.t = p.t + dt
p.d = p.d + move
if extra <= 0 then
if p.t >= 0.5 then
local v = p.d / p.t
Speed.normal = Speed.normal and (Speed.normal * 0.7 + v * 0.3) or v
p.t, p.d = 0, 0
end
return
end
if p.t >= 1.0 and not p.noted then
p.noted = true
local v = p.d / p.t
local normal = Speed.normal or Speed.gameWS * 0.7
log(string.format("Speed boost: %.1f studs/s (normal %.1f, boost +%.1f)", v, normal, extra))
if v >= normal + 0.4 * extra then
notify("Speed boost", "WORKS", 3)
else
notify("Speed boost", "DOESN'T WORK", 4)
end
end
end
function Speed.autoStep(dt, intent, extra, frameMove)
local a = Speed.auto
if a.locked then return a.locked, extra end
local m = Speed.chain[a.idx]
if extra <= 0 or intent.Magnitude < 0.5 then return m, extra end
local dir = intent.Unit
if a.lastDir and dir:Dot(a.lastDir) < 0.7 then a.t, a.d, a.e, a.w = 0, 0, 0, 0 end
a.lastDir = dir
a.t = a.t + dt
a.d = a.d + frameMove
a.e = a.e + extra * dt
a.w = a.w + Speed.gameWS * dt
if a.t >= 0.7 then
local mag = math.min(1, intent.Magnitude)
local v = a.d / a.t
local need = (a.w / a.t) * mag + 0.35 * (a.e / a.t) * mag
a.results[m] = v
if v >= need then
a.locked = m
log(string.format("Speed channel %s works: %.1f studs/s (needed %.1f)", m, v, need))
notify("Speed boost", "WORKS", 3)
else
a.idx = a.idx + 1
a.t, a.d, a.e, a.w = 0, 0, 0, 0
if a.idx > #Speed.chain then
local best, bv
for ch, sp in pairs(a.results) do
if not bv or sp > bv then best, bv = ch, sp end
end
a.locked = best or "CFrame"
log("No speed channel passed; kept " .. a.locked)
notify("Speed boost", "DOESN'T WORK", 4)
else
m = Speed.chain[a.idx]
end
end
end
return m, extra
end
function Speed.step(dt)
Speed.inputScale = 1
local h, r = hum(), Mover.body()
if not h or not r or h.Health <= 0 or dt <= 0 or dt > 0.25 then return end
local test = Speed.test
local intent, src
if test then intent, src = test.dir, "test" else intent, src = Mover.intent(h, r) end
Speed.src = src
Speed.mag = intent.Magnitude
if test then h:Move(test.dir, false) end
local ws = h.WalkSpeed
if ws ~= Speed.lastSet and ws > 1 then
Speed.gameWS = ws
Speed.minWS = math.min(ws, Speed.minWS)
end
local c = char()
local aw = c and c:GetAttribute("WalkSpeed")
if type(aw) == "number" and aw > 1 and aw ~= Speed.lastAttrWS then Speed.gameWS = aw end
Speed.minWS = math.min(Speed.gameWS, Speed.minWS * (1 + 0.01 * dt))
local frameMove = 0
local seenMove = nil
local seenNow = hrp()
if seenNow then
if Speed.seenLast and Speed.lastPos then seenMove = flat(seenNow.Position - Speed.seenLast).Magnitude end
Speed.seenLast = seenNow.Position
end
if Speed.lastPos then
local delta = flat(r.Position - Speed.lastPos)
frameMove = delta.Magnitude
Mover.vel = Mover.vel * 0.8 + (delta / dt) * 0.2
Speed.actual = Speed.actual + (frameMove / dt - Speed.actual) * 0.2
if Speed.lastMove and (r.Position - Speed.lastPos):Dot(Speed.lastMove.Unit) < -2.5 then Speed.noteRubber() end
end
if Speed.level > 0 and tick() - Speed.lastRubber > 8 then
Speed.level = Speed.level - 1
Speed.lastRubber = tick()
end
Speed.lastPos = r.Position
local method, extra
if test then
method, extra = test.method, test.extra
else
method, extra = S.SpeedChannel, Speed.extraNow()
if method == "Auto" and Mover.gameDirT and workspace:FindFirstChild("ProxyCharacter") then
method = "CFrame"
Speed.report(dt, intent, extra, seenMove or frameMove)
elseif method == "Auto" and Mover.gameDirT then
method, extra = Speed.inputStep(dt, intent, extra, seenMove or frameMove)
elseif method == "Auto" then
method, extra = Speed.autoStep(dt, intent, extra, seenMove or frameMove)
end
end
local active = extra > 0 and intent.Magnitude > 0.05 and method ~= "none"
local cc = char()
if cc and Speed.lastAttrWS and (method ~= "AttrWS" or not active) then
cc:SetAttribute("WalkSpeed", Speed.gameWS)
Speed.lastAttrWS = nil
end
if cc and Speed.attrBoostOn and (method ~= "AttrBoost" or not active) then
cc:SetAttribute("SpeedBoost", 0)
cc:SetAttribute("SpeedBoostTime", 0)
Speed.attrBoostOn = false
end
Speed.lastMove = active and intent or nil
Speed.extra = active and extra or 0
if not active or method ~= "GameValues" then Speed.gvRestore() end
if not active then
if Speed.lastSet then
h.WalkSpeed = Speed.gameWS
Speed.lastSet = nil
end
return
end
if method == "Input" then
Speed.inputScale = 1 + extra / math.max(Speed.gameWS, 1)
return
end
if method == "AttrWS" and cc then
local want = Speed.gameWS + extra
cc:SetAttribute("WalkSpeed", want)
Speed.lastAttrWS = want
return
end
if method == "AttrBoost" and cc then
cc:SetAttribute("SpeedBoost", extra / math.max(Speed.gameWS, 1))
cc:SetAttribute("SpeedBoostTime", 0.25)
Speed.attrBoostOn = true
return
end
if method == "WalkSpeed" then
local want = Speed.gameWS + extra
if h.WalkSpeed ~= want then h.WalkSpeed = want end
Speed.lastSet = want
return
end
if Speed.lastSet then
h.WalkSpeed = Speed.gameWS
Speed.lastSet = nil
end
if method == "GameValues" then
Speed.gvSet((Speed.gameWS + extra) / math.max(Speed.gameWS, 1))
elseif method == "Velocity" then
local v = r.AssemblyLinearVelocity
local t = intent * (Speed.gameWS + extra)
r.AssemblyLinearVelocity = Vector3.new(t.X, v.Y, t.Z)
else
local step = intent * extra * dt
if step.Magnitude > 0 and not Glide.blocked(r, intent.Unit, step.Magnitude) then
r.CFrame = r.CFrame + step
Mover.sync(r)
end
end
end
function Speed.autoPick()
if Speed.testing then return end
local h, r = hum(), hrp()
if not h or not r then
notify("Speed test", "No character found.", 2)
return
end
Speed.testing = true
notify("Speed test", "Stand in open space. Your character will walk a few steps.", 4)
local look = flat(cam().CFrame.LookVector)
if look.Magnitude < 0.01 then look = flat(r.CFrame.LookVector) end
look = look.Unit
local function trial(method, extra, dir)
Speed.test = { method = method, extra = extra, dir = dir }
local start = r.Position
local last = start
local rubber = 0
local t0 = tick()
while tick() - t0 < 0.7 do
RunService.Heartbeat:Wait()
local pos = r.Position
if (pos - last):Dot(dir) < -2.5 then rubber = rubber + 1 end
last = pos
end
local moved = (r.Position - start):Dot(dir)
Speed.test = nil
if method == "WalkSpeed" then h.WalkSpeed = Speed.gameWS end
task.wait(0.4)
return math.abs(moved), rubber
end
local ok, err = pcall(function()
local base = trial("none", 0, look)
base = math.max(base, 1)
local bestMethod, bestGain = nil, 1.2
local lines = {}
for i, m in ipairs({ "CFrame", "Velocity", "WalkSpeed" }) do
local moved, rubber = trial(m, 20, (i % 2 == 1) and -look or look)
local gain = moved / base
table.insert(lines, string.format("%s x%.2f%s", m, gain, rubber > 1 and " (pulled back)" or ""))
if rubber <= 1 and gain > bestGain then bestMethod, bestGain = m, gain end
end
log("Speed test: " .. table.concat(lines, ", "))
if bestMethod then
UI.set("SpeedChannel", bestMethod)
Speed.resetAuto()
notify("Speed test", "Best channel: " .. bestMethod .. "  (" .. table.concat(lines, ", ") .. ")", 6)
else
notify("Speed test", "No channel made you faster in this walk test. Try Auto while running, it also tries the game's own speed values. " .. table.concat(lines, ", "), 7)
end
end)
Speed.test = nil
Speed.testing = false
if not ok then log("Speed test error: " .. tostring(err)) end
end
function Feat.hasBall()
local ch = char()
local af = ch and ch:FindFirstChild("Attributes")
local bv = af and af:FindFirstChild("Basketball")
if bv and bv.Value ~= nil then return true end
return Ball.holding == true
end
function Feat.hop(b)
local r = Mover.body()
if not r or not b or Feat.hopping then return false end
Feat.hopping = true
local orig = r.CFrame
local lastSet = nil
local finished = false
local function show()
if finished or not lastSet then return end
pcall(function()
local moved = r.Position - lastSet
if moved.Magnitude < 6 then orig = orig + moved end
r.CFrame = r.CFrame + (orig.Position - r.Position)
lastSet = nil
end)
end
local bound = pcall(function() RunService:BindToRenderStep("JHHopShow", 0, show) end)
task.spawn(function()
local minFrames = math.max(1, math.floor(S.MagnetFrames or 1))
local t0 = tick()
local n = 0
while tick() - t0 < 1.2 do
RunService.Heartbeat:Wait()
n = n + 1
pcall(function()
local p = b.Position
local flat = Vector3.new(r.Position.X - p.X, 0, r.Position.Z - p.Z)
if flat.Magnitude < 0.1 then flat = Vector3.new(0, 0, 1) end
local spot = Vector3.new(p.X, r.Position.Y, p.Z) + flat.Unit * 1.2
r.CFrame = r.CFrame + (spot - r.Position)
lastSet = r.Position
Mover.sync(r)
end)
if n >= minFrames and Feat.hasBall() then
for _ = 1, 4 do
RunService.Heartbeat:Wait()
pcall(function()
r.CFrame = r.CFrame + (Vector3.new(b.Position.X, r.Position.Y, b.Position.Z) - r.Position)
lastSet = r.Position
end)
end
break
end
end
local done = false
local function back()
if done then return end
done = true
finished = true
pcall(function()
r.CFrame = r.CFrame + (orig.Position - r.Position)
r.AssemblyLinearVelocity = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
Mover.sync(r)
end)
if bound then pcall(function() RunService:UnbindFromRenderStep("JHHopShow") end) end
Feat.hopping = false
end
local okb = pcall(function() RunService:BindToRenderStep("JHHop", 0, function() back() RunService:UnbindFromRenderStep("JHHop") end) end)
if not okb then
RunService.RenderStepped:Wait()
back()
else
task.delay(0.2, back)
end
end)
return true
end
do
local V = {}
Feat.V = V
V.orig, V.tmpl, V.extras, V.logoImg, V.saved = {}, {}, {}, {}, {}
V.isExtra = {}
V.labels = { overall = {}, coins = {}, badges = {} }
V.LOGOS = {
Owner = { text = "OWNER", color = Color3.fromRGB(255, 196, 40), words = { "owner" } },
YouTube = { text = "YOUTUBE", color = Color3.fromRGB(255, 0, 0), words = { "youtube", "yt" } },
Twitch = { text = "TWITCH", color = Color3.fromRGB(145, 70, 255), words = { "twitch" } },
TikTok = { text = "TIKTOK", color = Color3.fromRGB(30, 30, 30), words = { "tiktok" } },
Dev = { text = "DEV", color = Color3.fromRGB(60, 140, 255), words = { "dev", "developer" } },
}
V.LOGO_NAMES = { "Owner", "YouTube", "Twitch", "TikTok", "Dev" }
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
V.MASCOTS = {
SpongeBob = { skin = C(255, 226, 60), shirt = C(255, 255, 255), pants = C(130, 85, 40), eyes = true, label = "SpongeBob" },
Patrick = { skin = C(255, 140, 165), shirt = C(255, 140, 165), pants = C(70, 170, 90), eyes = true, label = "Patrick" },
Squidward = { skin = C(120, 200, 200), shirt = C(120, 200, 200), pants = C(110, 90, 60), nose = C(120, 200, 200), label = "Squidward" },
Jeffy = { skin = C(255, 205, 150), shirt = C(255, 215, 40), pants = C(70, 100, 190), label = "Jeffy" },
IShowSpeed = { skin = C(150, 100, 70), shirt = C(220, 30, 40), pants = C(25, 25, 25), label = "IShowSpeed" },
MrBeast = { skin = C(235, 190, 150), shirt = C(50, 120, 230), pants = C(40, 45, 70), label = "MrBeast" },
Banana = { skin = C(255, 225, 53), shirt = C(255, 225, 53), pants = C(255, 225, 53), hat = C(110, 75, 30), label = "Banana" },
Curry = { skin = C(150, 100, 72), shirt = C(255, 199, 44), pants = C(29, 66, 138), label = "Curry 30" },
LeBron = { skin = C(110, 70, 50), shirt = C(85, 37, 130), pants = C(85, 37, 130), label = "LeBron" },
Kyrie = { skin = C(140, 95, 70), shirt = C(0, 83, 188), pants = C(0, 83, 188), label = "Kyrie 11" },
Wemby = { skin = C(170, 120, 90), shirt = C(20, 20, 20), pants = C(195, 202, 206), label = "Wemby 1" },
Mickey = { skin = C(20, 20, 20), shirt = C(20, 20, 20), pants = C(215, 30, 30), hands = C(255, 255, 255), ears = C(20, 20, 20), label = "Mickey" },
}
V.MASCOT_NAMES = { "SpongeBob", "Patrick", "Squidward", "Jeffy", "IShowSpeed", "MrBeast", "Banana", "Curry", "LeBron", "Kyrie", "Wemby", "Mickey" }
local function hasWord(name, w)
return string.find(string.lower(name), "%f[%a]" .. w .. "%f[%A]") ~= nil
end
function V.findLogo(key)
if V.logoImg[key] ~= nil then return V.logoImg[key] or nil end
local def = V.LOGOS[key]
local found
local roots = { ReplicatedStorage, LP:FindFirstChild("PlayerGui"), game:GetService("StarterGui"), workspace }
local n = 0
for _, root in ipairs(roots) do
if root and not found then
for _, d in ipairs(root:GetDescendants()) do
n = n + 1
if n % 1500 == 0 then task.wait() end
if d:IsA("ImageLabel") or d:IsA("ImageButton") or d:IsA("Decal") or d:IsA("Texture") then
local img = d:IsA("Decal") and d.Texture or (d:IsA("Texture") and d.Texture or d.Image)
if type(img) == "string" and img ~= "" then
for _, w in ipairs(def.words) do
if hasWord(d.Name, w) or (d.Parent and hasWord(d.Parent.Name, w)) then
found = img
break
end
end
end
if found then break end
end
end
end
end
V.logoImg[key] = found or false
return found
end
function V.clearLogo()
if V.logoGui then pcall(function() V.logoGui:Destroy() end) end
V.logoGui, V.logoKey, V.logoChar = nil, nil, nil
end
function V.applyLogo(key)
V.clearLogo()
local c = char()
local head = c and (c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart"))
local def = V.LOGOS[key]
if not head or not def then return end
local g = Instance.new("BillboardGui")
g.Name = "JHLogo"
g.Size = UDim2.new(0, 110, 0, 40)
g.StudsOffset = Vector3.new(0, 3.6, 0)
g.AlwaysOnTop = true
g.Adornee = head
local img = V.logoImg[key]
if img then
local il = Instance.new("ImageLabel")
il.BackgroundTransparency = 1
il.Size = UDim2.new(1, 0, 1, 0)
il.ScaleType = Enum.ScaleType.Fit
il.Image = img
il.Parent = g
else
local f = Instance.new("Frame")
f.Size = UDim2.new(1, 0, 1, 0)
f.BackgroundColor3 = def.color
f.BackgroundTransparency = 0.1
f.Parent = g
local cr = Instance.new("UICorner")
cr.CornerRadius = UDim.new(0, 10)
cr.Parent = f
local t = Instance.new("TextLabel")
t.BackgroundTransparency = 1
t.Size = UDim2.new(1, 0, 1, 0)
t.Font = Enum.Font.GothamBlack
t.TextScaled = true
t.TextColor3 = Color3.new(1, 1, 1)
t.Text = def.text
t.Parent = f
end
g.Parent = head
V.logoGui, V.logoKey, V.logoChar = g, key, c
end
local function recolor(part, color)
if V.orig[part] == nil then V.orig[part] = part.Color end
part.Color = color
end
function V.clearMascot()
for part, col in pairs(V.orig) do pcall(function() if part.Parent then part.Color = col end end) end
V.orig = {}
for inst, kv in pairs(V.tmpl) do pcall(function() inst[kv[1]] = kv[2] end) end
V.tmpl = {}
for _, e in ipairs(V.extras) do pcall(function() e:Destroy() end) end
V.extras = {}
V.isExtra = {}
V.mascotKey, V.mascotChar = nil, nil
end
local function extra(c, parent, size, color, shape, offset)
local p = Instance.new("Part")
p.Size = size
p.Color = color
p.Material = Enum.Material.SmoothPlastic
p.CanCollide, p.CanQuery, p.CanTouch, p.Massless = false, false, false, true
if shape then pcall(function() p.Shape = shape end) end
p.CFrame = parent.CFrame * offset
p.Parent = c
local w = Instance.new("WeldConstraint")
w.Part0, w.Part1 = p, parent
w.Parent = p
V.extras[#V.extras + 1] = p
return p
end
local LIMBS = { head = { "Head" }, torso = { "UpperTorso", "Torso" }, larm = { "LeftUpperArm", "Left Arm" }, rarm = { "RightUpperArm", "Right Arm" },
lleg = { "LeftUpperLeg", "Left Leg" }, rleg = { "RightUpperLeg", "Right Leg" } }
local function limbOf(c, key)
for _, n in ipairs(LIMBS[key]) do
local p = c:FindFirstChild(n)
if p then return p end
end
end
local BALL, CYL = Enum.PartType.Ball, Enum.PartType.Cylinder
local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
function V.hideOriginal(c)
for _, d in ipairs(c:GetDescendants()) do
if (d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and not V.isExtra[d]) or d:IsA("Decal") then
if V.tmpl[d] == nil then V.tmpl[d] = { "Transparency", d.Transparency } end
d.Transparency = 1
end
end
end
function V.build(c, key)
local def = V.BUILDS[key]
local head = limbOf(c, "head")
if not def or not head or not limbOf(c, "torso") then return false end
local r15 = c:FindFirstChild("UpperTorso") ~= nil
local k = head.Size.Y / (r15 and 1.2 or 1)
local function add(limb, shape, sx, sy, sz, ox, oy, oz, color, mat, rot)
local lp = limbOf(c, limb)
if not lp then return nil end
local dy = 0
if r15 and limb ~= "head" then dy = (limb == "torso") and -0.2 or -0.4 end
local part = extra(c, lp, Vector3.new(sx, sy, sz) * k, color, shape, CFrame.new(ox * k, (oy + dy) * k, oz * k) * (rot or CFrame.new()))
if mat then part.Material = mat end
V.isExtra[part] = true
return part
end
local function eye(limb, x, y, z, size, iris)
local e = add(limb, BALL, size, size, size * 0.6, x, y, z, WHITE)
if e then
add(limb, BALL, size * 0.5, size * 0.5, size * 0.3, x, y, z - size * 0.28, iris or BLACK)
add(limb, BALL, size * 0.22, size * 0.22, size * 0.2, x, y, z - size * 0.4, BLACK)
end
end
local function num(text, color, limb)
local lp = limbOf(c, limb or "torso")
if not lp then return end
for _, side in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
local sg = Instance.new("SurfaceGui")
sg.Face = side
sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
sg.PixelsPerStud = 40
local t = Instance.new("TextLabel")
t.BackgroundTransparency = 1
t.Size = UDim2.new(1, 0, 1, 0)
t.Font = Enum.Font.GothamBlack
t.TextScaled = true
t.TextColor3 = color
t.Text = text
t.Parent = sg
sg.Parent = V.torsoPart[1]
V.extras[#V.extras + 1] = sg
end
end
V.torsoPart = {}
local env = { add = add, eye = eye, num = num, BALL = BALL, CYL = CYL, WHITE = WHITE, BLACK = BLACK }
local ok, err = pcall(def, env)
if not ok then pcall(log, "Costume build: " .. tostring(err)) end
return ok
end
local function body(a, o)
local skin, shirt, pants, hand = o.skin, o.shirt, o.pants, o.hand or o.skin
local hs = o.headSize or 1.3
if o.headBlock then a.add("head", nil, hs * 1.7, hs * 1.2, hs, 0, 0.1, 0, skin) else a.add("head", a.BALL, hs * 1.4, hs * 1.4, hs * 1.4, 0, 0.1, 0, skin) end
local tw, th = o.tw or 2.1, o.th or 2.1
V.torsoPart[1] = a.add("torso", nil, tw, th, 1.1, 0, 0, 0, shirt)
if o.pantsTop ~= false then a.add("torso", nil, tw + 0.05, th * 0.32, 1.15, 0, -th * 0.34, 0, pants) end
local aw = o.aw or 1.05
for _, s in ipairs({ { "larm", -1 }, { "rarm", 1 } }) do
a.add(s[1], nil, aw, 1.2, aw, 0, 0.45, 0, o.sleeve or shirt)
a.add(s[1], nil, aw * 0.95, 0.9, aw * 0.95, 0, -0.55, 0, skin)
a.add(s[1], a.BALL, aw * 1.15, aw * 1.15, aw * 1.15, 0, -1.05, 0, hand)
end
local lw = o.lw or 1.05
for _, s in ipairs({ "lleg", "rleg" }) do
a.add(s, nil, lw, 1.3, lw, 0, 0.35, 0, pants)
a.add(s, nil, lw * 0.95, 0.8, lw * 0.95, 0, -0.55, 0, o.leg or skin)
a.add(s, nil, lw * 1.1, 0.45, lw * 1.9, 0, -0.95, -0.35, o.shoe or Color3.fromRGB(30, 30, 30))
end
end
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local function mouth(a, y, z, w, col)
a.add("head", nil, w, 0.1, 0.1, 0, y, z, col or BLACK)
a.add("head", nil, 0.1, 0.12, 0.1, -w / 2, y + 0.06, z, col or BLACK)
a.add("head", nil, 0.1, 0.12, 0.1, w / 2, y + 0.06, z, col or BLACK)
end
V.BUILDS = {
SpongeBob = function(a)
local Y = C(255, 226, 60)
body(a, { skin = Y, shirt = WHITE, pants = C(130, 85, 40), sleeve = WHITE, aw = 0.55, lw = 0.55, leg = WHITE, shoe = BLACK, headBlock = true, headSize = 1.6, tw = 2.4, th = 1.8, hand = Y })
a.add("torso", nil, 2.5, 0.25, 1.2, 0, 0.6, 0, WHITE)
a.add("torso", nil, 0.3, 1.0, 0.15, 0, 0.2, -0.6, C(215, 30, 30))
a.add("head", nil, 2.7, 0.35, 1.4, 0, -0.35, 0, Y)
a.eye("head", -0.45, 0.35, -0.7, 0.9, C(90, 170, 255))
a.eye("head", 0.45, 0.35, -0.7, 0.9, C(90, 170, 255))
a.add("head", nil, 0.35, 0.4, 0.1, -0.15, -0.55, -0.72, WHITE)
a.add("head", nil, 0.35, 0.4, 0.1, 0.15, -0.55, -0.72, WHITE)
mouth(a, -0.35, -0.72, 1.1)
a.add("head", a.BALL, 0.4, 0.4, 0.1, -0.95, -0.25, -0.7, C(255, 160, 140))
a.add("head", a.BALL, 0.4, 0.4, 0.1, 0.95, -0.25, -0.7, C(255, 160, 140))
a.add("head", a.BALL, 0.25, 0.25, 0.1, -0.9, 0.9, -0.65, C(215, 175, 30))
a.add("head", a.BALL, 0.2, 0.2, 0.1, 0.8, 0.6, -0.65, C(215, 175, 30))
end,
Patrick = function(a)
local Pk = C(255, 140, 165)
body(a, { skin = Pk, shirt = Pk, pants = C(70, 170, 90), aw = 1.1, lw = 1.1, shoe = Pk, headSize = 1.5, tw = 2.4, th = 2.2, pantsTop = true })
a.add("head", nil, 0.9, 1.1, 0.9, 0, 0.9, 0, Pk, nil, CFrame.Angles(0, 0, math.rad(45)))
a.eye("head", -0.4, 0.15, -0.95, 0.55)
a.eye("head", 0.4, 0.15, -0.95, 0.55)
mouth(a, -0.45, -0.98, 0.7)
a.add("torso", a.BALL, 0.5, 0.5, 0.1, 0.5, 0.7, -0.6, C(180, 40, 150))
a.add("torso", a.BALL, 0.4, 0.4, 0.1, -0.6, 0.3, -0.6, C(180, 40, 150))
a.add("torso", a.BALL, 0.45, 0.45, 0.1, 0.6, -0.8, -0.6, C(190, 60, 160))
end,
Squidward = function(a)
local T = C(120, 200, 200)
body(a, { skin = T, shirt = C(170, 225, 225), pants = C(110, 90, 60), aw = 0.8, lw = 0.85, shoe = T, headBlock = false, headSize = 1.5, tw = 1.9 })
a.add("head", a.BALL, 1.5, 2.2, 1.5, 0, 0.5, 0.1, T)
a.add("head", nil, 0.7, 0.7, 1.7, 0, -0.1, -1.1, T)
a.add("head", nil, 1.9, 0.4, 0.4, 0, 0.2, -0.85, C(80, 150, 150))
for _, sx in ipairs({ -0.45, 0.45 }) do
a.add("head", a.BALL, 0.6, 0.6, 0.35, sx, 0.4, -0.8, C(250, 250, 200))
a.add("head", a.BALL, 0.25, 0.25, 0.2, sx, 0.3, -1.0, BLACK)
a.add("head", nil, 0.7, 0.28, 0.45, sx, 0.62, -0.85, T)
end
a.add("head", a.BALL, 0.6, 0.4, 0.4, -0.5, 0.95, 0.05, C(80, 150, 150))
mouth(a, -0.85, -0.7, 0.8, C(80, 110, 110))
end,
Jeffy = function(a)
local S = C(255, 205, 150)
body(a, { skin = S, shirt = C(255, 215, 40), pants = C(70, 100, 190), sleeve = C(255, 215, 40), tw = 1.9, th = 1.7, headBlock = false, headSize = 1.7, shoe = WHITE })
a.add("head", a.BALL, 0.7, 0.35, 1.7, 0, 1.0, 0.05, C(60, 40, 25))
a.eye("head", -0.45, 0.25, -1.0, 0.8, C(90, 70, 40))
a.eye("head", 0.45, 0.25, -1.0, 0.8, C(90, 70, 40))
a.add("head", nil, 0.9, 0.25, 0.15, 0, -0.45, -1.1, C(120, 40, 40))
a.add("head", nil, 0.5, 0.25, 0.1, 0.25, -0.65, -1.1, C(230, 100, 120))
a.add("torso", nil, 0.9, 0.25, 0.15, 0, 0.5, -0.6, C(255, 255, 255))
end,
IShowSpeed = function(a)
local D = C(150, 100, 70)
body(a, { skin = D, shirt = C(220, 30, 40), pants = C(25, 25, 25), sleeve = C(220, 30, 40), headSize = 1.35, shoe = WHITE })
a.add("head", nil, 1.85, 0.7, 1.6, 0, 0.85, 0, C(20, 20, 20))
a.add("head", nil, 1.7, 0.35, 0.2, 0, 0.15, -0.8, C(20, 20, 20))
a.eye("head", -0.35, 0.05, -0.85, 0.5)
a.eye("head", 0.35, 0.05, -0.85, 0.5)
a.add("head", nil, 1.2, 0.4, 0.2, 0, -0.55, -0.75, C(30, 25, 20))
mouth(a, -0.45, -0.88, 0.7, WHITE)
a.add("torso", nil, 1.6, 0.35, 0.15, 0, 0.5, -0.6, WHITE)
end,
MrBeast = function(a)
local L = C(235, 190, 150)
body(a, { skin = L, shirt = C(50, 120, 230), pants = C(40, 45, 70), sleeve = C(50, 120, 230), tw = 2.3, aw = 1.15, headSize = 1.35, shoe = WHITE })
a.add("head", nil, 1.9, 0.55, 1.65, 0, 0.9, 0, C(60, 40, 30))
a.eye("head", -0.35, 0.1, -0.85, 0.5, C(80, 120, 160))
a.eye("head", 0.35, 0.1, -0.85, 0.5, C(80, 120, 160))
a.add("head", nil, 1.1, 0.5, 0.2, 0, -0.5, -0.78, C(110, 80, 60))
mouth(a, -0.4, -0.92, 0.6, WHITE)
a.add("torso", nil, 1.0, 0.3, 0.15, 0, 0.55, -0.6, C(255, 215, 40))
end,
Banana = function(a)
local Y = C(255, 225, 53)
a.add("head", a.BALL, 1.7, 1.9, 1.5, 0, 0.1, 0, Y)
a.add("head", nil, 0.5, 0.5, 0.5, 0, 1.15, 0, C(110, 75, 30))
a.add("torso", nil, 2.4, 2.1, 1.4, 0, 0, 0, Y)
a.add("torso", a.BALL, 2.6, 2.6, 1.5, 0, -0.1, 0, Y)
for _, s in ipairs({ "larm", "rarm" }) do
a.add(s, nil, 0.7, 2.0, 0.7, 0, 0, 0, Y)
end
for _, s in ipairs({ "lleg", "rleg" }) do
a.add(s, nil, 0.8, 2.0, 0.8, 0, 0, 0, Y)
a.add(s, nil, 0.9, 0.4, 1.4, 0, -1.0, -0.25, C(140, 100, 50))
end
a.eye("head", -0.4, 0.45, -0.7, 0.6)
a.eye("head", 0.4, 0.45, -0.7, 0.6)
mouth(a, -0.2, -0.76, 0.8)
a.add("head", a.BALL, 0.25, 0.25, 0.1, -0.7, 0.9, -0.6, C(200, 160, 40))
end,
Curry = function(a)
local Sk = C(150, 100, 72)
body(a, { skin = Sk, shirt = C(255, 199, 44), pants = C(29, 66, 138), sleeve = C(255, 199, 44), shoe = C(255, 199, 44), headSize = 1.3 })
a.add("head", nil, 1.5, 0.45, 1.3, 0, 0.75, 0, C(20, 15, 12))
a.eye("head", -0.35, 0.05, -0.8, 0.42)
a.eye("head", 0.35, 0.05, -0.8, 0.42)
mouth(a, -0.4, -0.88, 0.5, C(90, 40, 30))
a.num("30", C(29, 66, 138))
a.add("torso", nil, 2.15, 0.15, 1.15, 0, 0.95, 0, C(29, 66, 138))
end,
LeBron = function(a)
local Sk = C(110, 70, 50)
body(a, { skin = Sk, shirt = C(85, 37, 130), pants = C(85, 37, 130), sleeve = C(85, 37, 130), shoe = C(255, 199, 44), tw = 2.3, aw = 1.15, headSize = 1.3 })
a.add("head", nil, 1.45, 0.3, 1.3, 0, 0.75, 0, C(20, 15, 12))
a.add("head", nil, 1.7, 0.25, 1.5, 0, 0.6, 0, C(255, 199, 44))
a.eye("head", -0.35, 0.05, -0.8, 0.42)
a.eye("head", 0.35, 0.05, -0.8, 0.42)
a.add("head", nil, 1.2, 0.5, 0.25, 0, -0.5, -0.75, C(25, 20, 18))
mouth(a, -0.35, -0.9, 0.5, WHITE)
a.num("23", C(255, 199, 44))
a.add("torso", nil, 2.35, 0.15, 1.15, 0, 0.95, 0, C(255, 199, 44))
end,
Kyrie = function(a)
local Sk = C(140, 95, 70)
body(a, { skin = Sk, shirt = C(0, 83, 188), pants = C(0, 83, 188), sleeve = C(0, 83, 188), shoe = C(255, 255, 255), headSize = 1.3 })
a.add("head", nil, 1.5, 0.4, 1.3, 0, 0.75, 0, C(20, 15, 12))
a.eye("head", -0.35, 0.05, -0.8, 0.42)
a.eye("head", 0.35, 0.05, -0.8, 0.42)
a.add("head", nil, 1.0, 0.3, 0.2, 0, -0.5, -0.78, C(25, 20, 18))
mouth(a, -0.4, -0.9, 0.5, WHITE)
a.num("11", WHITE)
end,
Wemby = function(a)
local Sk = C(170, 120, 90)
body(a, { skin = Sk, shirt = C(20, 20, 20), pants = C(195, 202, 206), sleeve = C(20, 20, 20), shoe = WHITE, aw = 1.0, lw = 1.0, headSize = 1.3 })
a.add("head", nil, 1.4, 0.35, 1.25, 0, 0.75, 0, C(25, 20, 18))
a.eye("head", -0.35, 0.05, -0.8, 0.42)
a.eye("head", 0.35, 0.05, -0.8, 0.42)
mouth(a, -0.4, -0.9, 0.5, C(90, 40, 30))
a.num("1", C(195, 202, 206))
end,
Mickey = function(a)
local K = C(20, 20, 20)
a.add("head", a.BALL, 1.8, 1.8, 1.8, 0, 0.1, 0, K)
a.add("head", a.BALL, 1.5, 1.2, 0.35, 0, -0.2, -0.78, C(255, 222, 190))
for _, sx in ipairs({ -1.0, 1.0 }) do a.add("head", CYL, 0.3, 1.1, 1.1, sx, 1.0, 0, K, nil, CFrame.Angles(0, 0, math.rad(90))) end
a.eye("head", -0.3, 0.3, -0.92, 0.5)
a.eye("head", 0.3, 0.3, -0.92, 0.5)
a.add("head", a.BALL, 0.4, 0.3, 0.3, 0, -0.05, -1.0, K)
mouth(a, -0.45, -0.95, 0.8, C(150, 30, 30))
body(a, { skin = K, shirt = K, pants = C(215, 30, 30), sleeve = K, hand = WHITE, shoe = C(255, 200, 40), headSize = 0.1 })
a.add("torso", a.BALL, 0.3, 0.3, 0.1, -0.4, -0.5, -0.65, WHITE)
a.add("torso", a.BALL, 0.3, 0.3, 0.1, 0.4, -0.5, -0.65, WHITE)
end,
}
function V.applyMascot(key)
V.clearMascot()
local def = V.MASCOTS[key]
local c = char()
if not def or not c then return end
for _, d in ipairs(c:GetDescendants()) do
if d:IsA("Shirt") then V.tmpl[d] = { "ShirtTemplate", d.ShirtTemplate }; d.ShirtTemplate = "" end
if d:IsA("Pants") then V.tmpl[d] = { "PantsTemplate", d.PantsTemplate }; d.PantsTemplate = "" end
if d:IsA("ShirtGraphic") then V.tmpl[d] = { "Graphic", d.Graphic }; d.Graphic = "" end
if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and not d:FindFirstAncestorOfClass("Accessory") then
local n = d.Name
if n == "Head" then recolor(d, def.skin)
elseif n == "LowerTorso" then recolor(d, def.pants)
elseif string.find(n, "Torso", 1, true) then recolor(d, def.shirt)
elseif string.find(n, "Hand", 1, true) then recolor(d, def.hands or def.skin)
elseif string.find(n, "Arm", 1, true) then recolor(d, def.skin)
elseif string.find(n, "Leg", 1, true) or string.find(n, "Foot", 1, true) then recolor(d, def.pants) end
end
end
local built = false
if V.BUILDS[key] then
V.hideOriginal(c)
built = V.build(c, key)
if not built then
for inst, kv in pairs(V.tmpl) do
if kv[1] == "Transparency" then pcall(function() inst.Transparency = kv[2] end) V.tmpl[inst] = nil end
end
end
end
local head = c:FindFirstChild("Head")
if head and not built then
if def.eyes then
for _, sx in ipairs({ -0.3, 0.3 }) do
local e = extra(c, head, Vector3.new(0.55, 0.55, 0.3), Color3.new(1, 1, 1), Enum.PartType.Ball, CFrame.new(sx, 0.2, -0.5))
extra(c, e, Vector3.new(0.2, 0.2, 0.2), Color3.new(0, 0, 0), Enum.PartType.Ball, CFrame.new(0, 0, -0.1))
end
end
if def.nose then extra(c, head, Vector3.new(0.45, 0.45, 1.2), def.nose, Enum.PartType.Cylinder, CFrame.new(0, -0.1, -0.9) * CFrame.Angles(0, math.rad(90), 0)) end
if def.ears then
for _, sx in ipairs({ -0.75, 0.75 }) do extra(c, head, Vector3.new(0.9, 0.9, 0.3), def.ears, Enum.PartType.Ball, CFrame.new(sx, 0.85, 0)) end
end
if def.hat then extra(c, head, Vector3.new(0.5, 0.5, 0.5), def.hat, nil, CFrame.new(0, 0.85, 0)) end
end
V.mascotKey, V.mascotChar = key, c
end
local KEYS = {
overall = { "overall", "ovr" },
coins = { "coins", "coin", "cash", "money", "currency" },
badges = { "badge", "badges" },
}
function V.scanLabels()
if V.scanning then return end
V.scanning = true
task.spawn(function()
local gui = LP:FindFirstChild("PlayerGui")
if gui then
local n = 0
local found = { overall = {}, coins = {}, badges = {} }
for _, d in ipairs(gui:GetDescendants()) do
n = n + 1
if n % 1500 == 0 then task.wait() end
if d:IsA("TextLabel") or d:IsA("TextButton") then
local names = { d.Name, d.Parent and d.Parent.Name or "", d.Parent and d.Parent.Parent and d.Parent.Parent.Name or "" }
for kind, words in pairs(KEYS) do
for _, nm in ipairs(names) do
local low = string.lower(nm)
for _, w in ipairs(words) do
if string.find(low, w, 1, true) then found[kind][d] = true end
end
end
end
end
end
V.labels = found
end
V.scanning = false
V.scanT = tick()
end)
end
local function setLabels(kind, fn)
for d in pairs(V.labels[kind]) do
if d.Parent then
pcall(function()
local nt = fn(d.Text)
if nt and nt ~= d.Text then d.Text = nt end
end)
end
end
end
local function remember(inst, name)
local key = inst
V.saved[key] = V.saved[key] or {}
if V.saved[key][name] == nil then V.saved[key][name] = inst:GetAttribute(name) or false end
end
function V.maxStep()
local any = S.MaxOverall or S.MaxCoins or S.MaxBadges
if not any then return end
if (not V.scanT or tick() - V.scanT > 8) and not V.scanning then V.scanStarted = tick(); V.scanLabels() end
local c = char()
if S.MaxOverall then
for _, o in ipairs({ LP, c }) do
if o and o:GetAttribute("Overall") ~= nil and o:GetAttribute("Overall") ~= 99 then remember(o, "Overall"); o:SetAttribute("Overall", 99) end
end
setLabels("overall", function(t) if string.find(t, "%d") then return (string.gsub(t, "%d+", "99", 1)) end end)
end
if S.MaxCoins then
local big = 999999999
local ls = LP:FindFirstChild("leaderstats")
if ls then
for _, v in ipairs(ls:GetChildren()) do
local low = string.lower(v.Name)
if (v:IsA("IntValue") or v:IsA("NumberValue")) and (string.find(low, "coin", 1, true) or string.find(low, "cash", 1, true) or string.find(low, "money", 1, true)) then
V.saved[v] = V.saved[v] or { Value = v.Value }
v.Value = big
end
end
end
for k, val in pairs(LP:GetAttributes()) do
local low = string.lower(k)
if type(val) == "number" and (string.find(low, "coin", 1, true) or string.find(low, "cash", 1, true) or string.find(low, "money", 1, true)) and val ~= big then
remember(LP, k)
LP:SetAttribute(k, big)
end
end
setLabels("coins", function(t) if string.find(t, "%d") then return (string.gsub(t, "[%d,%.]+", "999,999,999", 1)) end end)
end
if S.MaxBadges then
local maxp = (c and c:GetAttribute("MaxBadgePoints")) or 109
if c and c:GetAttribute("BadgePoints") ~= nil and c:GetAttribute("BadgePoints") ~= maxp then
remember(c, "BadgePoints")
c:SetAttribute("BadgePoints", maxp)
end
setLabels("badges", function(t)
if string.find(t, "%d+%s*/%s*%d+") then return (string.gsub(t, "%d+(%s*/%s*)%d+", tostring(maxp) .. "%1" .. tostring(maxp), 1)) end
if string.find(t, "^%s*%d+%s*$") then return tostring(maxp) end
end)
end
end
function V.restoreStats()
for inst, kv in pairs(V.saved) do
pcall(function()
for name, val in pairs(kv) do
if name == "Value" then inst.Value = val else inst:SetAttribute(name, val ~= false and val or nil) end
end
end)
end
V.saved = {}
end
function V.step()
local now = tick()
if V.t and now - V.t < 0.5 then return end
V.t = now
local c = char()
pcall(V.stepVisuals, c)
pcall(V.maxStep)
if not (S.MaxOverall or S.MaxCoins or S.MaxBadges) and next(V.saved) then pcall(V.restoreStats) end
end
function V.stepVisuals(c)
if S.LogoOn then
local key = S.Logo
if V.LOGOS[key] and (V.logoKey ~= key or V.logoChar ~= c or not (V.logoGui and V.logoGui.Parent)) then
if V.logoImg[key] == nil then
if not V.finding then
V.finding = true
task.spawn(function() pcall(V.findLogo, key) V.finding = false end)
end
else
V.applyLogo(key)
end
end
elseif V.logoGui then
V.clearLogo()
end
if S.MascotOn then
local key = S.Mascot
if V.MASCOTS[key] and (V.mascotKey ~= key or V.mascotChar ~= c) then V.applyMascot(key) end
elseif V.mascotKey then
V.clearMascot()
end
end
function V.cleanup()
pcall(V.clearLogo)
pcall(V.clearMascot)
pcall(V.restoreStats)
end
end
Rec.on = false
Rec.lines = {}
Rec.bytes = 0
Rec.cap = 400000
Rec.t0 = 0
Rec.conns = {}
Rec.hooked = false
Rec.labelText = {}
Rec.attrCache = {}
Rec.header = {}
Rec.repl, Rec.replIn = 0, 0
Rec.lastMoveKey, Rec.lastMoveT = "", 0
Rec.lastBallKey, Rec.lastBallT = "", 0
Rec.lastPosKey, Rec.lastPosT = "", 0
Rec.btnSet = {}
Rec.noChar = 0
function Rec.add(kind, text)
if not Rec.on then return end
local line = string.format("%.2f %s %s", tick() - Rec.t0, kind, text)
Rec.lines[#Rec.lines + 1] = line
Rec.bytes = Rec.bytes + #line + 1
while Rec.bytes > Rec.cap and #Rec.lines > 1 do
Rec.bytes = Rec.bytes - #table.remove(Rec.lines, 1) - 1
end
end
function Rec.short(inst)
local parts, o = {}, inst
while o and o ~= game and #parts < 3 do
table.insert(parts, 1, o.Name)
o = o.Parent
end
return table.concat(parts, "/")
end
function Rec.fmt(v, depth)
local t = typeof(v)
if t == "string" then return '"' .. string.sub(v, 1, 300) .. '"' end
if t == "number" then return string.format("%.4g", v) end
if t == "boolean" or t == "nil" then return tostring(v) end
if t == "Instance" then
local ok, s = pcall(Rec.short, v)
return ok and ("<" .. s .. ">") or "<instance>"
end
if t == "NumberRange" then return string.format("NR(%.4g,%.4g)", v.Min, v.Max) end
if t == "NumberSequence" then
local k = {}
for _, kp in ipairs(v.Keypoints) do k[#k + 1] = string.format("%.3g:%.3g", kp.Time, kp.Value) end
return "NS(" .. table.concat(k, " ") .. ")"
end
if t == "Vector3" then return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z) end
if t == "Vector2" then return string.format("V2(%.1f,%.1f)", v.X, v.Y) end
if t == "CFrame" then return string.format("CF(%.1f,%.1f,%.1f)", v.Position.X, v.Position.Y, v.Position.Z) end
if t == "table" then
if (depth or 0) >= 2 then return "{...}" end
local parts, n = {}, 0
for k, val in pairs(v) do
n = n + 1
if n > 8 then
parts[#parts + 1] = "..."
break
end
parts[#parts + 1] = tostring(k) .. "=" .. Rec.fmt(val, (depth or 0) + 1)
end
return "{" .. table.concat(parts, ",") .. "}"
end
return t
end
function Rec.fmtArgs(args)
local out = {}
for i = 1, math.min(args.n, 8) do out[i] = Rec.fmt(args[i], 0) end
if args.n > 8 then out[#out + 1] = "..." end
return table.concat(out, ", ")
end
function Rec.guiAt(pos)
local pg = LP:FindFirstChild("PlayerGui")
if not pg then return "-" end
local inset = insetHeight()
for _, y in ipairs({ pos.Y, pos.Y - inset }) do
local ok, list = pcall(function() return pg:GetGuiObjectsAtPosition(pos.X, y) end)
if ok and list and #list > 0 then
local pick
for _, g in ipairs(list) do
if g:IsA("GuiButton") and not g:IsDescendantOf(gui) then
pick = g
break
end
end
pick = pick or list[1]
return string.format("%s [%s %q]", Input.pathOf(pick), pick.ClassName, Input.btnText(pick))
end
end
return "(no gui)"
end
function Rec.input(kind, i)
local t = i.UserInputType
if t == TOUCH or t == MB1 then
Rec.add("touch", string.format("%s at %.0f,%.0f on %s", kind, i.Position.X, i.Position.Y, Rec.guiAt(i.Position)))
elseif t == KEYBOARD then
Rec.add("key", tostring(i.KeyCode.Name) .. " " .. kind)
end
end
Rec.spy = {}
function Rec.callerOf()
if type(getcallingscript) ~= "function" then return nil end
local ok, sc = pcall(getcallingscript)
if not ok or not sc then return nil end
local ok2, path = pcall(function() return Rec.short(sc) end)
return ok2 and path or tostring(sc)
end
function Rec.spyNote(name, kind, argsText, note, caller)
local e = Rec.spy[name]
if not e then
e = { sent = 0, exec = 0, held = 0, boosted = 0, recv = 0 }
Rec.spy[name] = e
end
if kind == "recv" then
e.recv = e.recv + 1
else
e.sent = e.sent + 1
if note and string.find(note, "executor", 1, true) then e.exec = e.exec + 1 end
if note and string.find(note, "held back", 1, true) then e.held = e.held + 1 end
if note and string.find(note, "boosted", 1, true) then e.boosted = e.boosted + 1 end
if caller then e.caller = caller end
end
e.first = e.first or argsText
e.last = argsText
end
function Rec.remote(inst, method, args, note, caller)
if not Rec.on then return end
local ok, name = pcall(function() return inst.Name end)
if ok then pcall(Rec.spyNote, name, "send", Rec.fmtArgs(args), note, caller) end
if ok and name == "Replication" then
Rec.repl = Rec.repl + 1
return
end
if ok and name == "MoveDirection" then
local v = args[1]
local key = typeof(v) == "Vector3" and string.format("%.1f,%.1f", v.X, v.Z) or "?"
if key == Rec.lastMoveKey and tick() - Rec.lastMoveT < 1 then return end
Rec.lastMoveKey, Rec.lastMoveT = key, tick()
end
local path = "?"
pcall(function() path = Rec.short(inst) end)
Rec.add("send", string.format("%s %s(%s)%s%s", path, method, Rec.fmtArgs(args), note and (" [" .. note .. "]") or "",
caller and (" from " .. caller) or ""))
end
local function nameOf(o) return o.Name end
Rec.ownSrc = nil
pcall(function() Rec.ownSrc = debug.info(Rec.noteWrite or nameOf, "s") end)
function Rec.fromUs()
if not Rec.ownSrc then return false end
for lvl = 2, 5 do
local ok, src = pcall(debug.info, lvl, "s")
if not ok or src == nil then break end
if src == Rec.ownSrc then return true end
end
return false
end
Rec.writes = {}
Rec.WATCHED = { CFrame = true, Position = true, Velocity = true, AssemblyLinearVelocity = true, AssemblyAngularVelocity = true, WalkSpeed = true,
JumpPower = true, Anchored = true, MaxForce = true, VectorVelocity = true }
function Rec.noteWrite(inst, key, value)
if not Rec.on then return end
local ok, mine = pcall(function()
local c = char()
return c and (inst == c or inst:IsDescendantOf(c))
end)
if not ok or not mine then return end
local id = Rec.short(inst) .. "." .. tostring(key)
local w = Rec.writes[id]
if not w then
w = { n = 0 }
Rec.writes[id] = w
end
w.n = w.n + 1
w.last = value
end
function Rec.flushWrites()
for id, w in pairs(Rec.writes) do
Rec.add("write", string.format("an executor script set %s x%d, last value %s", id, w.n, Rec.fmt(w.last, 0)))
end
Rec.writes = {}
end
function Rec.hookWrites()
if Rec.hookedWrites or type(hookmetamethod) ~= "function" then return end
Rec.hookedWrites = true
local wrap = type(newcclosure) == "function" and newcclosure or function(f) return f end
local oldNI
local ok = pcall(function()
oldNI = hookmetamethod(game, "__newindex", wrap(function(self, key, value)
if Rec.on and Rec.WATCHED[key] and JH.Running and type(checkcaller) == "function" and checkcaller() and not Rec.fromUs() then
task.defer(Rec.noteWrite, self, key, value)
end
return oldNI(self, key, value)
end))
end)
if not ok then Rec.hookedWrites = false end
end
Rec.seenFuncs = {}
function Rec.funcInfo(f)
local src, line, name = "?", 0, ""
pcall(function()
src = debug.info(f, "s") or "?"
line = debug.info(f, "l") or 0
name = debug.info(f, "n") or ""
end)
return src, line, name
end
function Rec.constantsOf(f)
local out = {}
local getc = (debug and debug.getconstants) or getconstants
if type(getc) ~= "function" then return out end
local ok, list = pcall(getc, f)
if not ok or type(list) ~= "table" then return out end
for _, v in pairs(list) do
if type(v) == "string" and #v >= 3 and #v <= 40 and not string.find(v, "[%c]") and #out < 60 then out[#out + 1] = v end
end
return out
end
function Rec.scanConnections()
if type(getconnections) ~= "function" then return end
local signals = {
{ "Heartbeat", RunService.Heartbeat }, { "Stepped", RunService.Stepped }, { "RenderStepped", RunService.RenderStepped },
{ "InputBegan", UIS.InputBegan }, { "InputEnded", UIS.InputEnded },
}
for _, sg in ipairs(signals) do
local ok, list = pcall(getconnections, sg[2])
if ok and type(list) == "table" then
for _, conn in ipairs(list) do
local f
pcall(function() f = conn.Function end)
if type(f) == "function" then
local id = tostring(f)
if not Rec.seenFuncs[id] then
Rec.seenFuncs[id] = true
local src, line, name = Rec.funcInfo(f)
if src ~= Rec.ownSrc and not string.find(src, "JHubGlass", 1, true) and not string.find(src, "Players.", 1, true) and not string.find(src, "ReplicatedStorage", 1, true) then
local consts = Rec.constantsOf(f)
Rec.add("script", string.format("%s listener %s line %d %s | words: %s", sg[1], string.sub(src, 1, 80), line, name,
string.sub(table.concat(consts, ", "), 1, 400)))
end
end
end
end
end
end
end
Rec.seenGuis = {}
function Rec.scanGuis()
local roots = {}
pcall(function() if type(gethui) == "function" then roots[#roots + 1] = gethui() end end)
pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
for _, root in ipairs(roots) do
local ok, kids = pcall(function() return root:GetChildren() end)
if ok then
for _, g in ipairs(kids) do
if g.Name ~= "JHubGlass" and not Rec.seenGuis[g] then
Rec.seenGuis[g] = true
local texts = {}
pcall(function()
for _, d in ipairs(g:GetDescendants()) do
if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" and #texts < 80 then texts[#texts + 1] = string.sub(d.Text, 1, 30) end
end
end)
Rec.add("script", string.format("interface found: %s (%s) texts: %s", g.Name, g.ClassName, string.sub(table.concat(texts, " | "), 1, 700)))
end
end
end
end
end
function Rec.scanLoop()
while Rec.on and JH.Running do
pcall(Rec.scanConnections)
pcall(Rec.scanGuis)
task.wait(12)
end
end
function Rec.hook()
if Rec.hooked or type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then return end
Rec.hooked = true
Shot.hooked = true
local wrap = type(newcclosure) == "function" and newcclosure or function(f) return f end
local old
old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
local method = getnamecallmethod()
if Rec.on and method == "SetAttribute" and JH.Running and type(checkcaller) == "function" and checkcaller() and not Rec.fromUs() then
local args = table.pack(...)
task.defer(Rec.noteWrite, self, "attribute " .. tostring(args[1]), args[2])
end
if JH.Running and (method == "FireServer" or method == "InvokeServer") then
local fromExec = type(checkcaller) == "function" and checkcaller()
local mine = Mover.selfFire or Shot.selfFire
if fromExec and not mine then
if Rec.on then
local okn2, name2 = pcall(nameOf, self)
if not (okn2 and name2 == "Replication") then task.defer(Rec.remote, self, method, table.pack(...), "sent by an executor script", Rec.callerOf()) end
end
end
if not fromExec and not mine then
if method == "FireServer" then
local okn, name = pcall(nameOf, self)
if okn and name == "Shoot" then
local args = table.pack(...)
local okd, drop = pcall(Shot.onShootCall, args)
if okd and drop then
if Rec.on then task.defer(Rec.remote, self, method, args, "held back", Rec.callerOf()) end
return
end
elseif okn and name == "MoveDirection" then
local v = ...
if typeof(v) == "Vector3" then
Mover.gameDir, Mover.gameDirT = v, tick()
local okc, s = pcall(Mover.outScale)
if okc and s > 1.001 and v.Magnitude > 0.05 then
if Rec.on then task.defer(Rec.remote, self, method, table.pack(v * s), string.format("boosted x%.2f", s)) end
return old(self, v * s, select(2, ...))
end
end
elseif okn and name == "Dribble" then
task.defer(Mover.onDribble, table.pack(...))
end
end
if Rec.on then task.defer(Rec.remote, self, method, table.pack(...), nil, Rec.callerOf()) end
end
end
return old(self, ...)
end))
end
function Rec.connectRemotes()
local function watch(d)
if d:IsA("RemoteEvent") then
table.insert(Rec.conns, d.OnClientEvent:Connect(function(...)
if not Rec.on then return end
if d.Name == "Replication" then
Rec.replIn = Rec.replIn + 1
return
end
local txt = Rec.fmtArgs(table.pack(...))
pcall(Rec.spyNote, d.Name, "recv", txt)
Rec.add("recv", Rec.short(d) .. "(" .. txt .. ")")
end))
end
end
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do watch(d) end
table.insert(Rec.conns, ReplicatedStorage.DescendantAdded:Connect(watch))
end
function Rec.pollLabels()
local n = 0
for d in pairs(Shot.labels) do
if d.Parent then
local tx = d.Text
if tx ~= Rec.labelText[d] then
Rec.labelText[d] = tx
if tx ~= "" and n < 12 and not string.match(tx, "^[%d%.:,%s%%/]+$") and not string.find(tx, " FPS", 1, true) and visibleChain(d) then
n = n + 1
Rec.add("text", Rec.short(d) .. " = " .. string.format("%q", string.sub(tx, 1, 80)))
end
end
end
end
end
function Rec.pollAttrs()
local function check(prefix, inst)
if not inst then return end
for k, v in pairs(inst:GetAttributes()) do
local key = prefix .. k
if Rec.attrCache[key] ~= v then
Rec.add("attr", string.format("%s %s -> %s", key, tostring(Rec.attrCache[key]), tostring(v)))
Rec.attrCache[key] = v
end
end
end
check("char.", char())
check("player.", LP)
local h = hum()
if h then
for _, prop in ipairs({ "WalkSpeed", "JumpPower", "JumpHeight", "Health", "HipHeight" }) do
local ok, v = pcall(function() return h[prop] end)
if ok and type(v) == "number" and Rec.attrCache["hum." .. prop] ~= v then
Rec.add("attr", string.format("hum.%s %s -> %s", prop, tostring(Rec.attrCache["hum." .. prop]), tostring(v)))
Rec.attrCache["hum." .. prop] = v
end
end
end
end
function Rec.pollMovers()
local r = hrp()
if not r then return end
local out = {}
for _, ch in ipairs(r:GetChildren()) do
local ok, txt = pcall(function()
if ch:IsA("BodyVelocity") then return string.format("%s velocity=%.1f,%.1f,%.1f maxForce=%.0f", ch.Name, ch.Velocity.X, ch.Velocity.Y, ch.Velocity.Z, ch.MaxForce.X) end
if ch:IsA("BodyPosition") then return string.format("%s position=%.1f,%.1f,%.1f maxForce=%.0f", ch.Name, ch.Position.X, ch.Position.Y, ch.Position.Z, ch.MaxForce.X) end
if ch:IsA("BodyGyro") then return string.format("%s maxTorque=%.0f", ch.Name, ch.MaxTorque.X) end
if ch:IsA("LinearVelocity") then return string.format("%s linear=%.1f,%.1f,%.1f", ch.Name, ch.VectorVelocity.X, ch.VectorVelocity.Y, ch.VectorVelocity.Z) end
return nil
end)
if ok and txt then out[#out + 1] = txt end
end
local key = table.concat(out, " | ")
if key ~= "" and (key ~= Rec.lastMovers or tick() - (Rec.lastMoversT or 0) > 2) then
Rec.lastMovers, Rec.lastMoversT = key, tick()
Rec.add("body", key)
end
local c = char()
if c and (r.Anchored ~= Rec.lastAnchored) then
Rec.lastAnchored = r.Anchored
Rec.add("body", "root anchored=" .. tostring(r.Anchored))
end
end
function Rec.watchCharacter()
local c = char()
if not c then return end
table.insert(Rec.conns, c.DescendantAdded:Connect(function(d)
if Rec.on then Rec.add("char", "added " .. d.ClassName .. " " .. Rec.short(d)) end
end))
table.insert(Rec.conns, c.DescendantRemoving:Connect(function(d)
if Rec.on then Rec.add("char", "removed " .. d.ClassName .. " " .. Rec.short(d)) end
end))
end
function Rec.sampleBall()
local r, b = hrp(), Ball.nearest
local key = tostring(Ball.holding) .. tostring(Ball.source)
if key == Rec.lastBallKey and tick() - Rec.lastBallT < 4 then return end
Rec.lastBallKey, Rec.lastBallT = key, tick()
if b and b.Parent and r then
Rec.add("ball", string.format("pos=%.1f,%.1f,%.1f dist=%.1f holding=%s via %s parts=%d", b.Position.X, b.Position.Y,
b.Position.Z, (b.Position - r.Position).Magnitude, tostring(Ball.holding), tostring(Ball.source), Ball.count()))
else
Rec.add("ball", "holding=" .. tostring(Ball.holding) .. " via " .. tostring(Ball.source) .. " parts=" .. Ball.count())
end
end
function Rec.pollButtons()
local pg = LP:FindFirstChild("PlayerGui")
if not pg then return end
local now = {}
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("GuiButton") and not d:IsDescendantOf(gui) and visibleChain(d) then now[Input.pathOf(d)] = true end
end
for p in pairs(now) do
if not Rec.btnSet[p] then Rec.add("gui", "button shown: " .. p) end
end
for p in pairs(Rec.btnSet) do
if not now[p] then Rec.add("gui", "button hidden: " .. p) end
end
Rec.btnSet = now
end
function Rec.sampleLoop()
local lastAttr, lastBall, lastFlush, lastBtn = 0, 0, 0, 0
while Rec.on and JH.Running do
local c = char()
local r = hrp() or (c and c.PrimaryPart)
local h = hum()
if r then
local v = r.AssemblyLinearVelocity
local state = "?"
if h then pcall(function() state = tostring(h:GetState()) end) end
local key = string.format("%.1f,%.1f,%.1f|%s", r.Position.X, r.Position.Y, r.Position.Z, state)
if key ~= Rec.lastPosKey or tick() - Rec.lastPosT > 1 then
Rec.lastPosKey, Rec.lastPosT = key, tick()
local px = workspace:FindFirstChild("ProxyCharacter")
Rec.add("move", string.format("pos=%.1f,%.1f,%.1f proxy=%s vel=%.1f ws=%s intent=%.2f(%s) boost=%.1f ball=%s state=%s",
r.Position.X, r.Position.Y, r.Position.Z, px and string.format("%.1f,%.1f", px.Position.X, px.Position.Z) or "none",
math.sqrt(v.X * v.X + v.Z * v.Z), h and string.format("%.1f", h.WalkSpeed) or "none",
Speed.mag or 0, tostring(Speed.src), Speed.extra, tostring(Ball.holding), state))
end
elseif tick() - Rec.noChar > 3 then
Rec.noChar = tick()
Rec.add("move", "no character found (LP.Character=" .. tostring(LP.Character) .. ")")
end
if tick() - lastFlush >= 1 then
lastFlush = tick()
pcall(Rec.flushWrites)
if Rec.repl > 0 or Rec.replIn > 0 then
Rec.add("net", string.format("Replication sent x%d, received x%d in the last second", Rec.repl, Rec.replIn))
end
Rec.repl, Rec.replIn = 0, 0
end
if tick() - lastBtn > 2.5 then
lastBtn = tick()
pcall(Rec.pollButtons)
end
pcall(Rec.pollMovers)
pcall(Rec.pollLabels)
if tick() - lastAttr > 0.6 then
lastAttr = tick()
pcall(Rec.pollAttrs)
end
if tick() - lastBall > 0.45 then
lastBall = tick()
pcall(Rec.sampleBall)
end
task.wait(0.15)
end
end
function Rec.snapshot()
local out = {}
local function head(s) out[#out + 1] = s end
head("== JHub recording " .. VERSION .. " | place " .. string.format("%.0f", game.PlaceId) .. " | " .. tostring(JH.execName)
.. (IS_MOBILE and " | mobile" or " | pc"))
local vp = cam().ViewportSize
head("game: " .. tostring(JH.placeName) .. " | screen " .. string.format("%.0fx%.0f", vp.X, vp.Y) .. " | " .. os.date("%Y-%m-%d %H:%M:%S"))
head(string.format("executor: VIM=%s getconnections=%s firesignal=%s hookmetamethod=%s getgc=%s setclipboard=%s",
tostring(VIM ~= nil), tostring(getconnections ~= nil), tostring(firesignal ~= nil), tostring(type(hookmetamethod) == "function"),
tostring(type(getgc) == "function"), tostring(setclipboard ~= nil)))
head(string.format("settings: hold=%.3f times=[%s] ratio=%.3f bar=%s|%s point=%.3f shootButton=%s", S.HoldTime, S.ShotTimes,
S.ShotRatio, S.BarPath, S.BarProp, S.BarAt, S.ShootButtonPath))
head(string.format("boosts: walk=%s+%.1f run=%s+%.1f ball=%s+%.1f channel=%s | glides: dribble=%s shot=%s gather=%s",
tostring(S.SpeedOn), S.SpeedAdd, tostring(S.RunOn), S.RunAdd, tostring(S.BallSpeedOn), S.BallAdd, S.SpeedChannel,
tostring(S.DribbleGlide), tostring(S.ShotGlide), tostring(S.GatherGlide)))
pcall(function()
local c = char()
head("LP.Character = " .. tostring(LP.Character) .. " | character found = " .. (c and Rec.short(c) or "none"))
local cf = workspace:FindFirstChild("Characters")
if cf then
local who = {}
for _, ch in ipairs(cf:GetChildren()) do who[#who + 1] = ch.Name end
head("workspace.Characters: " .. table.concat(who, " "))
end
local top = {}
for _, ch in ipairs(workspace:GetChildren()) do
if #top < 40 then top[#top + 1] = ch.Name .. ":" .. ch.ClassName end
end
head("workspace: " .. table.concat(top, " "))
if c then
local names = {}
for _, ch in ipairs(c:GetChildren()) do names[#names + 1] = ch.Name .. ":" .. ch.ClassName end
head("character: " .. table.concat(names, " "))
local hh = hum()
head("humanoid: " .. (hh and ("yes walkspeed=" .. tostring(hh.WalkSpeed) .. " jump=" .. tostring(hh.JumpPower)) or "none"))
local r = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
if r then
head(string.format("root: %s anchored=%s pos=%.1f,%.1f,%.1f", Rec.short(r), tostring(r.Anchored), r.Position.X, r.Position.Y, r.Position.Z))
local kids = {}
for _, ch in ipairs(r:GetChildren()) do kids[#kids + 1] = ch.Name .. ":" .. ch.ClassName end
head("root children: " .. table.concat(kids, " "))
end
for k, v in pairs(c:GetAttributes()) do head("  char attribute " .. k .. " = " .. tostring(v)) end
end
local guis = {}
for _, g in ipairs((LP:FindFirstChild("PlayerGui") or workspace):GetChildren()) do
if g:IsA("ScreenGui") then guis[#guis + 1] = g.Name .. (g.Enabled and "" or "(off)") end
end
head("screen guis: " .. table.concat(guis, " "))
end)
for k, v in pairs(LP:GetAttributes()) do head("  player attribute " .. k .. " = " .. tostring(v)) end
local pg = LP:FindFirstChild("PlayerGui")
if pg then
head("-- visible buttons:")
local n = 0
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("GuiButton") and not d:IsDescendantOf(gui) and visibleChain(d) then
n = n + 1
if n <= 80 then
head(string.format("  %s [%s %q] at %.0f,%.0f size %.0fx%.0f", Input.pathOf(d), d.ClassName, Input.btnText(d),
d.AbsolutePosition.X, d.AbsolutePosition.Y, d.AbsoluteSize.X, d.AbsoluteSize.Y))
end
end
end
end
head("-- remotes:")
local n = 0
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
n = n + 1
if n <= 100 then head("  " .. d.ClassName .. " " .. Rec.short(d)) end
end
end
head("-- ball parts: " .. Ball.count())
Rec.header = out
end
function Rec.spyText()
local rows = {}
for name, e in pairs(Rec.spy) do rows[#rows + 1] = { name = name, e = e, n = e.sent + e.recv } end
table.sort(rows, function(a, b) return a.n > b.n end)
local out = { "-- remote spy: name | sent | from executor scripts | held back | boosted | received | sender | first args | last args --" }
for _, r in ipairs(rows) do
local e = r.e
out[#out + 1] = string.format("%s | sent %d | exec %d | held %d | boosted %d | recv %d | by %s | first (%s) | last (%s)", r.name, e.sent, e.exec, e.held,
e.boosted, e.recv, tostring(e.caller or "?"), string.sub(tostring(e.first or ""), 1, 200), string.sub(tostring(e.last or ""), 1, 200))
end
if Rec.repl > 0 or Rec.replTotal then out[#out + 1] = "Replication (position stream) is only counted per second in the events" end
return table.concat(out, "\n")
end
function Rec.copySpy()
local text = Rec.spyText()
local tail = {}
for i = math.max(1, #Rec.lines - 150), #Rec.lines do tail[#tail + 1] = Rec.lines[i] end
text = text .. "\n-- the last events --\n" .. table.concat(tail, "\n")
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Remote spy", "Copied the remote list and the last events. Paste it to me.", 4)
else
FS.write(FS.root .. "/remotespy.txt", text)
notify("Remote spy", "Saved to the JHubGlass folder (this executor cannot copy).", 4)
end
end
function Rec.text()
local parts = {}
for _, l in ipairs(Rec.header) do parts[#parts + 1] = l end
parts[#parts + 1] = Rec.spyText()
parts[#parts + 1] = "-- events (seconds since start) --"
for _, l in ipairs(Rec.lines) do parts[#parts + 1] = l end
return table.concat(parts, "\n")
end
function Rec.save(text)
FS.write(FS.root .. "/recording.txt", text or Rec.text())
end
function Rec.summary()
local kb = Rec.bytes / 1024
return (Rec.on and "recording: " or "stopped: ") .. string.format("%d lines, %.0f KB", #Rec.lines, kb)
end
function Rec.copy()
if #Rec.lines == 0 and #Rec.header == 0 then
notify("Recorder", "Nothing recorded yet. Turn on Record the game first.", 3)
return
end
local text = Rec.text()
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Recorder", string.format("Copied %d lines (%.0f KB). Paste it to me.", #Rec.lines, #text / 1024), 4)
else
notify("Recorder", "This executor cannot copy, so it was saved to the JHubGlass folder instead.", 4)
end
Rec.save(text)
end
function Rec.clear()
Rec.lines, Rec.bytes, Rec.header, Rec.spy = {}, 0, {}, {}
notify("Recorder", "Cleared", 2)
end
function Rec.start()
if Rec.on then return end
Rec.lines, Rec.bytes = {}, 0
Rec.spy = {}
Rec.t0 = tick()
Rec.on = true
Rec.labelText, Rec.attrCache = {}, {}
for d in pairs(Shot.labels) do
if d.Parent then Rec.labelText[d] = d.Text end
end
pcall(Rec.snapshot)
pcall(Rec.hook)
pcall(Rec.connectRemotes)
pcall(Rec.watchCharacter)
Rec.seenFuncs, Rec.seenGuis, Rec.writes = {}, {}, {}
task.spawn(Rec.scanLoop)
task.spawn(Rec.sampleLoop)
notify("Recorder", "Recording. Play and take your shots, then tap Copy recording.", 4)
end
function Rec.stop()
if not Rec.on then return end
Rec.add("end", "recording stopped")
Rec.on = false
for _, c in ipairs(Rec.conns) do pcall(function() c:Disconnect() end) end
Rec.conns = {}
pcall(Rec.save)
notify("Recorder", string.format("Stopped. %d lines recorded.", #Rec.lines), 3)
end
JH.RecLog = function(msg) Rec.add("jhub", msg) end
Net.AUTOEXEC_FILE = "JHubV1_Glass.lua"
Net.AUTOEXEC_FOLDERS = { "autoexec", "Autoexec", "autoexecute", "Autoexecute" }
function Net.scriptSource()
if type(JH_SOURCE) == "string" and #JH_SOURCE > 1000 then return JH_SOURCE end
return FS.read(FS.root .. "/" .. Net.AUTOEXEC_FILE)
end
function Net.autoExecCode()
local src = Net.scriptSource()
if not src then return nil end
return "(getgenv and getgenv() or _G).JHUB_AUTOEXEC = true\n" .. src
end
function Net.queueTeleport()
local q = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
local code = Net.autoExecCode()
if type(q) == "function" and code then
pcall(q, code)
return true
end
return false
end
function Net.autoExec(on)
if not on then
for _, f in ipairs(Net.AUTOEXEC_FOLDERS) do
local p = f .. "/" .. Net.AUTOEXEC_FILE
pcall(function()
if type(isfile) == "function" and isfile(p) and type(delfile) == "function" then delfile(p) end
end)
end
notify("Auto execute", "Off. JHub will not start by itself anymore.", 3)
return
end
local code = Net.autoExecCode()
if not code then
notify("Auto execute", "Could not read the script to save it.", 4)
return
end
FS.write(FS.root .. "/" .. Net.AUTOEXEC_FILE, Net.scriptSource())
local wrote = {}
for _, f in ipairs(Net.AUTOEXEC_FOLDERS) do
pcall(function()
if type(isfolder) == "function" and isfolder(f) then
writefile(f .. "/" .. Net.AUTOEXEC_FILE, code)
table.insert(wrote, f)
end
end)
end
local queued = Net.queueTeleport()
local parts = {}
if #wrote > 0 then table.insert(parts, "saved in " .. table.concat(wrote, ", ")) end
if queued then table.insert(parts, "runs again when you change servers") end
if #parts == 0 then
notify("Auto execute", "This executor does not let scripts reach its auto-execute folder. A copy is in the JHubGlass folder: put it in your executor's autoexec folder.", 8)
else
notify("Auto execute", "On: " .. table.concat(parts, ", "), 5)
end
end
Rec.scanText = ""
Rec.scanning = false
Rec.SCAN_WORDS = { "move", "speed", "stat", "dribble", "glide", "sprint", "physic", "config", "setting", "build", "shoot", "meter", "input",
"player", "constant", "code", "reward", "badge", "stamina", "character" }
function Rec.tableDump(t, depth, out, prefix, seen, cap)
if seen[t] or depth > 3 or #out >= cap then return end
seen[t] = true
local keys = {}
for k in pairs(t) do keys[#keys + 1] = k end
pcall(table.sort, keys, function(a, b) return tostring(a) < tostring(b) end)
for i, k in ipairs(keys) do
if i > 60 or #out >= cap then
out[#out + 1] = prefix .. "..."
return
end
local v = t[k]
local tv = typeof(v)
if tv == "table" then
out[#out + 1] = prefix .. tostring(k) .. " = {"
Rec.tableDump(v, depth + 1, out, prefix .. "  ", seen, cap)
out[#out + 1] = prefix .. "}"
elseif tv == "function" then
out[#out + 1] = prefix .. tostring(k) .. " = function"
else
out[#out + 1] = prefix .. tostring(k) .. " = " .. Rec.fmt(v, 0)
end
end
end
function Rec.scanGame()
if Rec.scanning then
notify("Game scanner", "Still scanning, wait a moment.", 2)
return
end
Rec.scanning = true
notify("Game scanner", "Scanning the game. This takes a few seconds.", 3)
task.spawn(function()
local out = {}
local function add(s) out[#out + 1] = s end
pcall(function()
add("== game scan " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName) .. " | " .. os.date("%Y-%m-%d %H:%M:%S"))
add("-- character: " .. tostring(char() and Bar.pathOf(char()) or "none"))
local c = char()
if c then
for k, v in pairs(c:GetAttributes()) do add("  char attribute " .. k .. " = " .. tostring(v)) end
end
for k, v in pairs(LP:GetAttributes()) do add("  player attribute " .. k .. " = " .. tostring(v)) end
add("-- game settings (workspace.Settings) --")
local st = workspace:FindFirstChild("Settings")
if st then
for k, v in pairs(st:GetAttributes()) do add("  " .. k .. " = " .. tostring(v)) end
for _, d in ipairs(st:GetDescendants()) do
local ok, val = pcall(function() return d.Value end)
add("  " .. Bar.pathOf(d) .. (ok and (" = " .. tostring(val)) or ""))
end
end
add("-- ReplicatedStorage --")
local n = 0
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
n = n + 1
if n > 700 then
add("  ...")
break
end
add("  " .. d.ClassName .. " " .. Bar.pathOf(d))
if n % 120 == 0 then task.wait() end
end
end)
task.wait()
pcall(function()
local list
if type(getloadedmodules) == "function" then list = getloadedmodules() end
if not list then
add("-- client modules: this executor cannot list them --")
return
end
add("-- client modules (" .. #list .. ") --")
local picked = {}
for i, m in ipairs(list) do
if i <= 500 then add("  " .. Bar.pathOf(m)) end
local nm = string.lower(m.Name)
if #picked < 30 and matchAny(nm, Rec.SCAN_WORDS) then picked[#picked + 1] = m end
end
for _, m in ipairs(picked) do
task.wait()
local ok, res = pcall(require, m)
local lines = {}
if ok and type(res) == "table" then
Rec.tableDump(res, 0, lines, "    ", {}, 200)
elseif ok then
lines[1] = "    (" .. typeof(res) .. ")"
else
lines[1] = "    (could not be read)"
end
add("-- module " .. Bar.pathOf(m) .. " --")
for _, l in ipairs(lines) do add(l) end
end
end)
task.wait()
pcall(function()
if type(getgc) ~= "function" then return end
add("-- tables in memory with movement / dribble / code names --")
local found, seen = 0, 0
for _, t in ipairs(getgc(true)) do
seen = seen + 1
if seen % 4000 == 0 then task.wait() end
if found < 60 and type(t) == "table" then
local ok = pcall(function()
for k, v in pairs(t) do
if type(k) == "string" and (type(v) == "number" or type(v) == "string" or type(v) == "boolean") then
local kl = string.lower(k)
if (string.find(kl, "speed", 1, true) or string.find(kl, "glide", 1, true) or string.find(kl, "dribble", 1, true)
or string.find(kl, "sprint", 1, true) or kl == "code" or kl == "codes") and found < 60 then
found = found + 1
add("  " .. k .. " = " .. tostring(v))
end
end
end
end)
end
end
end)
local text = table.concat(out, "\n")
if #text > 240000 then text = string.sub(text, 1, 240000) .. "\n... (cut)" end
Rec.scanText = text
Rec.copyScan()
Rec.scanning = false
end)
end
function Rec.copyScan()
if Rec.scanText == "" then
notify("Game scanner", "Nothing scanned yet.", 2)
return
end
if type(setclipboard) == "function" then
pcall(setclipboard, Rec.scanText)
notify("Game scanner", string.format("Copied (%.0f KB). Paste it to me.", #Rec.scanText / 1024), 4)
else
notify("Game scanner", "This executor cannot copy, so it was saved to the JHubGlass folder.", 4)
end
FS.write(FS.root .. "/gamescan.txt", Rec.scanText)
end
Rec.shotOn = false
Rec.shotLines = {}
Rec.shotBytes = 0
Rec.shotConns = {}
Rec.shotCap = 400000
function Rec.shotAdd(text)
if not Rec.shotOn then return end
local line = string.format("%.3f %s", tick() - (Rec.shotT0 or tick()), text)
Rec.shotLines[#Rec.shotLines + 1] = line
Rec.shotBytes = Rec.shotBytes + #line + 1
while Rec.shotBytes > Rec.shotCap and #Rec.shotLines > 1 do
Rec.shotBytes = Rec.shotBytes - #table.remove(Rec.shotLines, 1) - 1
end
end
function Rec.modulesNamed(sub)
local out = {}
if type(getloadedmodules) ~= "function" then return out end
local ok, list = pcall(getloadedmodules)
if not ok or type(list) ~= "table" then return out end
for _, m in ipairs(list) do
local okp, path = pcall(Bar.pathOf, m)
if okp and string.sub(path, -#sub) == sub then out[#out + 1] = m end
end
return out
end
function Rec.dumpModule(sub, maxLines)
local out = {}
for _, m in ipairs(Rec.modulesNamed(sub)) do
local ok, res = pcall(require, m)
out[#out + 1] = "-- module " .. Bar.pathOf(m)
if ok and type(res) == "table" then
Rec.tableDump(res, 0, out, "  ", {}, maxLines or 260)
else
out[#out + 1] = "  (" .. typeof(res) .. ")"
end
end
return out
end
function Rec.constantsAll(f)
local out = {}
local getc = (debug and debug.getconstants) or getconstants
if type(getc) ~= "function" then return out end
local ok, list = pcall(getc, f)
if not ok or type(list) ~= "table" then return out end
for _, v in pairs(list) do
if (type(v) == "string" and #v >= 2 and #v <= 40 and not string.find(v, "[%c]")) or type(v) == "number" then
if #out < 120 then out[#out + 1] = type(v) == "number" and string.format("%.5g", v) or v end
end
end
return out
end
function Rec.codeOf(m)
local lines = { "-- script " .. Bar.pathOf(m) }
local src
if type(decompile) == "function" then
local ok, r = pcall(decompile, m)
if ok and type(r) == "string" and #r > 40 then src = r end
end
if src then
if #src > 70000 then src = string.sub(src, 1, 70000) .. "\n-- (cut)" end
lines[#lines + 1] = src
return table.concat(lines, "\n")
end
lines[#lines + 1] = "-- (this executor cannot decompile: the numbers and words inside each function follow)"
local ok, res = pcall(require, m)
if ok and type(res) == "table" then
local names = {}
for k, v in pairs(res) do
if type(v) == "function" then names[#names + 1] = k end
end
table.sort(names, function(a, b) return tostring(a) < tostring(b) end)
for _, k in ipairs(names) do
lines[#lines + 1] = "function " .. tostring(k) .. ": " .. table.concat(Rec.constantsAll(res[k]), ", ")
end
Rec.tableDump(res, 0, lines, "  ", {}, 160)
end
return table.concat(lines, "\n")
end
Rec.CODE_SETS = {
shooting = { "Controllers/Meter", "Modules/Config/Meters/Bat", "Modules/UI/Character/ShotFeedback", "Config/Game/Shooting",
"Config/Settings/Meter", "Modules/Config/Meter" },
movement = { "Components/Character/Movement", "Movement/Types/Base", "Controllers/Player", "Modules/Components/Input/Mobile" },
}
function Rec.copyCode(set)
notify("Code reader", "Reading the game's code. This takes a few seconds.", 3)
task.spawn(function()
local out = { "== game code " .. tostring(set) .. " | " .. VERSION .. " | decompile=" .. tostring(type(decompile) == "function") }
for _, sub in ipairs(Rec.CODE_SETS[set] or {}) do
for _, m in ipairs(Rec.modulesNamed(sub)) do
task.wait()
local ok, text = pcall(Rec.codeOf, m)
out[#out + 1] = ok and text or ("-- " .. sub .. " could not be read")
end
end
local text = table.concat(out, "\n")
if #text > 240000 then text = string.sub(text, 1, 240000) .. "\n-- (cut)" end
Rec.codeText = text
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Code reader", string.format("Copied (%.0f KB). Paste it to me.", #text / 1024), 4)
else
notify("Code reader", "This executor cannot copy, so it was saved to the JHubGlass folder.", 4)
end
FS.write(FS.root .. "/code_" .. tostring(set) .. ".txt", text)
end)
end
Rec.shotSummary = {}
function Rec.shotCategory(ctx, gameType)
local c = char()
local base = tostring(c and c:GetAttribute("BaseAnimation") or "")
local low = string.lower(base .. " " .. tostring(gameType or ""))
if string.find(low, "dunk", 1, true) then return "dunk" end
if string.find(low, "layup", 1, true) then return "layup" end
if string.find(low, "floater", 1, true) then return "floater" end
if string.find(low, "stepback", 1, true) or string.find(low, "step back", 1, true) then return "step back" end
if string.find(low, "fade", 1, true) then return "fadeaway" end
if string.find(low, "post", 1, true) or string.find(low, "hook", 1, true) then return "post shot" end
if string.find(low, "movingshot", 1, true) then return "moving shot" end
if string.find(low, "close", 1, true) then return "close shot" end
if ctx and ctx.speed and ctx.speed > 1.5 then return "moving jumpshot" end
return "standing jumpshot"
end
function Rec.shotNote(info, res, text)
if not Rec.shotOn then return end
local c = char()
local ctx = Rec.shotCtx or {}
local gtype = string.match(tostring(Shot.fbText or ""), "Shot Type %- (%S+)")
local function at(n) return c and tostring(c:GetAttribute(n)) or "?" end
local n = #Rec.shotSummary + 1
Rec.shotSummary[n] = string.format("SHOT %d | %s | game type=%s | anim=%s | ShotSpeed=%s | speed at start=%.1f | hand=%s | gather=%s | last dribble=%s | in air=%s | held=%.4f | verdict=%s idx=%s | message=%s | contest=%s | key=%s | start hold=%s | frozen meter=%s | sweep=%s",
n, Rec.shotCategory(ctx, gtype), tostring(gtype), at("BaseAnimation"), at("ShotSpeed"), ctx.speed or 0, at("Hand"), at("GatherType"), at("LastDribblePackage"),
tostring(ctx.air), info.held or 0, tostring(res), tostring(info.idx), tostring(text), tostring(string.match(tostring(Shot.fbText or ""), "Contest %- (%S+)")),
tostring(info.key), tostring(info.base and string.format("%.3f", info.base)), at("meterOffset"), tostring(Shot.lastSweep))
end
function Rec.shotMeterStart(packet)
if not Rec.shotOn then return end
local c = char()
local v = c and c:GetAttribute("ServerVelocity")
Rec.shotCtx = { speed = (typeof(v) == "Vector3") and v.Magnitude or 0, air = c and c:GetAttribute("InAir") }
Rec.shotAdd(string.format("== shot meter starts | packet=%s | ShotSpeed=%s", tostring(packet), tostring(c and c:GetAttribute("ShotSpeed"))))
end
local SHOT_SKIP = { Stamina = true, TakeoverFill = true, AccelerationBoost = true }
function Rec.shotStart()
if Rec.shotOn then return end
Rec.shotOn = true
Rec.shotLines, Rec.shotBytes, Rec.shotT0, Rec.shotSummary, Rec.shotCtx = {}, 0, tick(), {}, nil
Rec.shotAdd("== shot recorder " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName))
local c = char()
if c then
for k, v in pairs(c:GetAttributes()) do Rec.shotAdd("start attr " .. k .. " = " .. tostring(v)) end
table.insert(Rec.shotConns, c.AttributeChanged:Connect(function(name)
if SHOT_SKIP[name] then return end
local val = c:GetAttribute(name)
Rec.shotAdd("attr " .. name .. " = " .. tostring(val))
if name == "Action" and string.find(string.lower(tostring(val)), "dunk", 1, true) then
Rec.shotAdd("== DUNK started | " .. tostring(val))
Rec.shotSummary[#Rec.shotSummary + 1] = "DUNK | Action=" .. tostring(val) .. " | anim=" .. tostring(c:GetAttribute("BaseAnimation")) .. " | in air=" .. tostring(c:GetAttribute("InAir"))
end
end))
end
notify("Shot recorder", "Recording. Take standing, moving, fadeaway, step back, layup and dunk shots, then turn it off. It copies everything.", 6)
end
function Rec.shotStop()
if not Rec.shotOn then return end
Rec.shotAdd("== stopped")
Rec.shotOn = false
for _, cn in ipairs(Rec.shotConns) do pcall(function() cn:Disconnect() end) end
Rec.shotConns = {}
Rec.shotFinish()
end
function Rec.shotFinish()
if #Rec.shotLines <= 2 then
notify("Shot recorder", "Nothing recorded. Take some shots first.", 3)
return
end
notify("Shot recorder", "Building the report.", 2)
task.spawn(function()
local out = { "== SHOT REPORT " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName), "== one line per shot (" .. #Rec.shotSummary .. ")" }
for _, l in ipairs(Rec.shotSummary) do out[#out + 1] = l end
out[#out + 1] = "== saved hold times: " .. tostring(S.ShotTimes)
out[#out + 1] = "== dunk settings"
pcall(function()
for _, m in ipairs(getloadedmodules()) do
local okp, path = pcall(Bar.pathOf, m)
if okp and string.find(path, "Config/Game/Dunking", 1, true) then
task.wait()
local okr, res = pcall(require, m)
out[#out + 1] = "-- " .. path
if okr and type(res) == "table" then Rec.tableDump(res, 0, out, "  ", {}, #out + 90) end
end
end
end)
out[#out + 1] = "== raw log"
out[#out + 1] = table.concat(Rec.shotLines, "\n")
local text = table.concat(out, "\n")
if #text > 380000 then text = string.sub(text, 1, 380000) .. "\n-- (cut)" end
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Shot recorder", string.format("Copied %d shots (%.0f KB). Paste it to me.", #Rec.shotSummary, #text / 1024), 5)
else
notify("Shot recorder", "This executor cannot copy, so it was saved to the JHubGlass folder.", 5)
end
FS.write(FS.root .. "/shotdata.txt", text)
end)
end
function Rec.shotCopy() Rec.shotFinish() end
function Rec.copyShotConfig()
notify("Shot settings", "Reading the shot settings. This takes a few seconds.", 3)
task.spawn(function()
local out = { "== shot settings " .. VERSION }
local list = {}
pcall(function() list = getloadedmodules() end)
for _, m in ipairs(list) do
local ok, path = pcall(Bar.pathOf, m)
if ok and string.find(path, "Config/Game/Shooting/Packages", 1, true) then
task.wait()
local okr, res = pcall(require, m)
out[#out + 1] = "-- " .. path
if okr and type(res) == "table" then Rec.tableDump(res, 0, out, "  ", {}, #out + 70) end
end
end
local text = table.concat(out, "\n")
if #text > 240000 then text = string.sub(text, 1, 240000) .. "\n-- (cut)" end
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Shot settings", string.format("Copied (%.0f KB). Paste it to me.", #text / 1024), 4)
else
notify("Shot settings", "This executor cannot copy, so it was saved to the JHubGlass folder.", 4)
end
FS.write(FS.root .. "/shotsettings.txt", text)
end)
end
Rec.CAPTURE_WORDS = { "shoot", "shot", "meter", "build", "badge", "contest", "rating", "release", "timing", "takeover", "stamina", "attribute",
"stat", "skill", "archetype", "hotzone", "hot", "cold", "makerng", "percent", "defen", "block", "guard", "gameplay", "layup", "dunk", "pass", "dribble", "input", "mobile",
"player", "physics", "util", "contact", "basketball", "coin", "movement", "gamemode" }
function Rec.captureAll()
notify("Capture", "Reading the game. This takes up to a minute.", 5)
task.spawn(function()
local out = { "== GAME CAPTURE " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName) .. " | decompile=" .. tostring(type(decompile) == "function") }
local mods = {}
pcall(function()
for _, m in ipairs(getloadedmodules()) do
local ok, path = pcall(Bar.pathOf, m)
if ok then mods[#mods + 1] = { m = m, path = path } end
end
end)
local FIRST = { "Controllers/Player", "InputService", "Components/Input", "Controllers/Meter", "Shoot", "ShotFeedback", "Shared/Util/", "Config/Game/Basketball",
"Config/Game/Contact", "Controllers/Characters/Character", "Config/Meter", "Config/Settings", "Controllers/Attributes", "Controllers/Gui" }
local function prio(path)
for _, w in ipairs(FIRST) do
if string.find(path, w, 1, true) then return 1 end
end
return 2
end
table.sort(mods, function(a, b)
local pa, pb = prio(a.path), prio(b.path)
if pa ~= pb then return pa < pb end
return a.path < b.path
end)
local function wanted(path)
local low = string.lower(path)
for _, w in ipairs(Rec.CAPTURE_WORDS) do
if string.find(low, w, 1, true) then return true end
end
return false
end
out[#out + 1] = "== all modules (" .. #mods .. ")"
for _, e in ipairs(mods) do out[#out + 1] = e.path end
out[#out + 1] = "== player values"
pcall(function()
for k, v in pairs(LP:GetAttributes()) do out[#out + 1] = "player attr " .. k .. " = " .. tostring(v) end
local c = char()
if c then for k, v in pairs(c:GetAttributes()) do out[#out + 1] = "character attr " .. k .. " = " .. tostring(v) end end
local ls = LP:FindFirstChild("leaderstats")
if ls then for _, v in ipairs(ls:GetChildren()) do out[#out + 1] = "leaderstat " .. v.Name .. " = " .. tostring(v.Value) end end
for k, v in pairs(workspace:GetAttributes()) do out[#out + 1] = "workspace attr " .. k .. " = " .. tostring(v) end
for k, v in pairs(ReplicatedStorage:GetAttributes()) do out[#out + 1] = "replicated attr " .. k .. " = " .. tostring(v) end
end)
out[#out + 1] = "== remotes"
pcall(function()
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("UnreliableRemoteEvent") then out[#out + 1] = d.ClassName .. " " .. d:GetFullName() end
end
end)
local total, cap = 0, 250000
out[#out + 1] = "== code and settings"
for _, e in ipairs(mods) do
if total > cap then
out[#out + 1] = "-- (size limit reached, more modules were skipped from here: " .. e.path .. ")"
break
end
local skip = string.find(e.path, "Config/Game/Dunking", 1, true) or string.find(e.path, "Shooting/Packages", 1, true)
or string.find(e.path, "Dunking/Animations", 1, true) or string.find(e.path, "Dunking/Landings", 1, true)
if not skip then
for _, w in ipairs({ "Icon/", "ForgeVFX", "CameraModule", "AnimationViewer", "Vehicles", "TabMenu/", "SeasonPass", "Config/Game/Emotes", "Dribbling/Packages",
"Crowd", "Hoops/Net", "Replication/Performance", "Statsheet", "BuildOffer", "PlayerModule/", "NameFinder", "Statistics/", "Scoreboards", "GymCustomize" }) do
if string.find(e.path, w, 1, true) and not string.find(e.path, "Coins", 1, true) then skip = true end
end
end
if wanted(e.path) and not skip then
task.wait()
local ok, text = pcall(Rec.codeOf, e.m)
if ok and type(text) == "string" then
if #text > 30000 then text = string.sub(text, 1, 30000) .. "\n-- (cut)" end
out[#out + 1] = text
total = total + #text
end
end
end
local text = table.concat(out, "\n")
if #text > 390000 then text = string.sub(text, 1, 390000) .. "\n-- (cut)" end
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Capture", string.format("Copied (%.0f KB). Paste it to me.", #text / 1024), 6)
else
notify("Capture", "This executor cannot copy, so it was saved to the JHubGlass folder.", 6)
end
FS.write(FS.root .. "/capture.txt", text)
end)
end
Feat.maxSeen = {}
Feat.sprinting = false
function Feat.refillIn(inst)
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("NumberValue") or d:IsA("IntValue") then
local n = string.lower(d.Name)
if string.find(n, "stamina", 1, true) or string.find(n, "energy", 1, true) then
Feat.maxSeen[d] = math.max(Feat.maxSeen[d] or 0, d.Value)
d.Value = Feat.maxSeen[d]
end
end
end
for k, v in pairs(inst:GetAttributes()) do
if type(v) == "number" then
local n = string.lower(k)
if string.find(n, "stamina", 1, true) or string.find(n, "energy", 1, true) then
local key = inst:GetFullName() .. "." .. k
Feat.maxSeen[key] = math.max(Feat.maxSeen[key] or 0, v)
pcall(function() inst:SetAttribute(k, Feat.maxSeen[key]) end)
end
end
end
end
function Feat.refillStamina()
local c = char()
if c then Feat.refillIn(c) end
pcall(Feat.refillIn, LP)
end
function Feat.tick(count)
local h = hum()
if not h or h.Health <= 0 then return end
if S.InfStamina and count % 5 == 0 then pcall(Feat.refillStamina) end
local want = S.AutoSprint and h.MoveDirection.Magnitude > 0.1
if want ~= Feat.sprinting then
Feat.sprinting = want
Input.action("Sprint", want)
end
end
Picker.mode = nil
function Picker.start(mode)
UI.show(false)
notify("Picker", "Tap " .. (mode == "shoot" and "the game's SHOOT button" or "the BALL") .. " now", 4)
task.delay(0.35, function() Picker.mode = mode end)
end
function Picker.handle(mode, pos)
if mode == "shoot" then
local pg = LP:FindFirstChild("PlayerGui")
local inset = insetHeight()
local found
for _, y in ipairs({ pos.Y, pos.Y + inset }) do
local ok, list = pcall(function() return pg:GetGuiObjectsAtPosition(pos.X, y) end)
if ok and list then
for _, g in ipairs(list) do
if not g:IsDescendantOf(gui) and g:IsA("GuiButton") then found = g break end
end
if not found then
for _, g in ipairs(list) do
if not g:IsDescendantOf(gui) then found = g break end
end
end
end
if found then break end
end
if found then
UI.set("ShootButtonPath", Input.pathOf(found), false)
Input.cache.Shoot = nil
notify("Shoot button set", found.Name, 3)
log("Shoot button: " .. S.ShootButtonPath)
else
notify("Picker", "Nothing found there, try again", 3)
end
else
local ray = cam():ScreenPointToRay(pos.X, pos.Y)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = { char() or workspace.Terrain }
local res = workspace:Raycast(ray.Origin, ray.Direction * 600, params)
if res and res.Instance then
UI.set("BallName", res.Instance.Name, false)
Ball.rescan()
Ball.parts[res.Instance] = true
notify("Ball set", res.Instance.Name, 3)
else
notify("Picker", "Nothing hit, try again", 3)
end
end
UI.show(true)
end
UI.themed, UI.texts, UI.corners, UI.cards, UI.elems, UI.grads = {}, {}, {}, {}, {}, {}
UI.pages, UI.refresh, UI.flagRefresh, UI.flagCB = {}, {}, {}, {}
UI.listening = nil
function UI.th(o, prop, key)
table.insert(UI.themed, { o, prop, key })
o[prop] = Theme[key]
return o
end
function UI.elemTrans() return clamp(S.CardTrans - 0.35, 0.12, 0.9) end
function UI.font(bold)
local f = FONTS[S.Font] or FONTS.Gotham
local name = bold and f[2] or f[1]
local ok, e = pcall(function() return Enum.Font[name] end)
if ok and e then return e end
return bold and Enum.Font.GothamBold or Enum.Font.Gotham
end
function UI.text(o, bold)
table.insert(UI.texts, { o, bold })
o.Font = UI.font(bold)
o.TextStrokeColor3 = Theme.Stroke
o.TextStrokeTransparency = S.TextStroke and 0.72 or 1
return o
end
function UI.label(props, bold, colorKey)
local l = new("TextLabel", props)
l.BackgroundTransparency = 1
UI.text(l, bold)
if colorKey ~= false then UI.th(l, "TextColor3", colorKey or "Text") end
return l
end
function UI.corner(o, factor)
local c = new("UICorner", { Parent = o })
if factor == "pill" then
c.CornerRadius = UDim.new(1, 0)
else
table.insert(UI.corners, { c, factor or 1 })
c.CornerRadius = UDim.new(0, math.floor(S.Corner * (factor or 1)))
end
return c
end
function UI.card(f)
table.insert(UI.cards, f)
f.BackgroundColor3 = Theme.Card
f.BackgroundTransparency = S.CardTrans
return f
end
function UI.elem(f)
table.insert(UI.elems, f)
f.BackgroundColor3 = Theme.Elem
f.BackgroundTransparency = UI.elemTrans()
return f
end
function UI.paintGrad(g)
g.Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)
g.Rotation = 35
end
function UI.grad(o)
local g = new("UIGradient", { Parent = o })
table.insert(UI.grads, g)
UI.paintGrad(g)
return g
end
function UI.stroke(o, transparency)
local st = new("UIStroke", { Thickness = 1, Color = WHITE, Transparency = transparency or 0.6,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
return st
end
function UI.addRefresh(flag, fn)
if flag then
UI.flagRefresh[flag] = UI.flagRefresh[flag] or {}
table.insert(UI.flagRefresh[flag], fn)
end
table.insert(UI.refresh, fn)
end
function UI.set(flag, v, fire)
S[flag] = v
local list = UI.flagRefresh[flag]
if list then
for _, f in ipairs(list) do pcall(f) end
end
if fire ~= false and UI.flagCB[flag] then task.spawn(UI.flagCB[flag], v) end
saveSoon()
end
function UI.refreshAll()
UI.applyTheme()
for _, f in ipairs(UI.refresh) do pcall(f) end
end
local Window = new("Frame", { Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
Size = UDim2.fromOffset(560, 340), BackgroundTransparency = 1, Parent = gui })
local WinScale = new("UIScale", { Parent = Window })
local Main = new("Frame", { Name = "Main", Size = UDim2.fromScale(1, 1), ClipsDescendants = true, Parent = Window })
UI.corner(Main, 1.4)
local MainStroke = new("UIStroke", { Thickness = 2, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Main })
local StrokeGrad = new("UIGradient", { Parent = MainStroke })
local Sheen = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = Main })
local SheenGrad = new("UIGradient", { Rotation = 120, Parent = Sheen })
do
local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
local YEL, GLD = Color3.fromRGB(255, 221, 64), Color3.fromRGB(255, 196, 40)
local Storm = new("Frame", { Name = "Storm", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Main })
local BG = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(2.2, 2.2),
BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = Storm })
local BGGrad = new("UIGradient", { Rotation = 35, Parent = BG })
local orbs = {}
for i = 1, 3 do
local o = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(150 + i * 30, 150 + i * 30),
BackgroundColor3 = (i % 2 == 0) and WHITE or YEL, BackgroundTransparency = 0.9, BorderSizePixel = 0, Parent = Storm })
UI.corner(o, "pill")
orbs[i] = o
end
local pool = {}
for i = 1, 10 do
local o = { glow = {}, core = {}, t = 0, life = 1, on = false }
for j = 1, 9 do
o.glow[j] = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, BackgroundTransparency = 1, BackgroundColor3 = YEL, ZIndex = 2, Parent = Storm })
o.core[j] = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, BackgroundTransparency = 1, BackgroundColor3 = WHITE, ZIndex = 3, Parent = Storm })
end
pool[i] = o
end
local function hide(o)
for j = 1, #o.core do
o.core[j].BackgroundTransparency = 1
o.glow[j].BackgroundTransparency = 1
end
o.on = false
end
local function strike(o)
local W, H = 560, 340
local x = math.random() * W
local n = #o.core
local endY = H * (0.55 + math.random() * 0.5)
local drift = (math.random() - 0.5) * W * 0.45
local pts = { { x, -6 } }
for j = 1, n do
local f = j / n
pts[#pts + 1] = { x + drift * f + (math.random() - 0.5) * 48, endY * f }
end
local mode = S.BoltColor or "White + Yellow"
local coreC, glowC
if mode == "Yellow" then coreC, glowC = Color3.fromRGB(255, 240, 150), YEL
elseif mode == "White" then coreC, glowC = WHITE, Color3.fromRGB(215, 228, 255)
elseif math.random() < 0.5 then coreC, glowC = WHITE, YEL
else coreC, glowC = YEL, WHITE end
local th = S.BoltThick or 2
for j = 1, n do
local a, b = pts[j], pts[j + 1]
local dx, dy = b[1] - a[1], b[2] - a[2]
local len = math.sqrt(dx * dx + dy * dy) + 2
local ang = math.deg(atan2(dy, dx))
local pos = UDim2.fromOffset((a[1] + b[1]) / 2, (a[2] + b[2]) / 2)
local g, c = o.glow[j], o.core[j]
g.Size, c.Size = UDim2.fromOffset(len, th * 4), UDim2.fromOffset(len, th)
g.Position, c.Position = pos, pos
g.Rotation, c.Rotation = ang, ang
g.BackgroundColor3, c.BackgroundColor3 = glowC, coreC
end
o.t, o.life, o.on = 0, 0.3 / math.max(S.BoltSpeed or 1, 0.2) + math.random() * 0.18, true
end
local function step(o, dt)
o.t = o.t + dt
local k = o.t / o.life
if k >= 1 then hide(o) return end
local fl = (math.floor(o.t * 38) % 2 == 0) and 1 or 0.55
local a = (1 - k) * fl * (S.BoltBright or 0.9)
local ct, gt = 1 - a, 1 - a * 0.45
for j = 1, #o.core do
o.core[j].BackgroundTransparency = ct
o.glow[j].BackgroundTransparency = gt
end
end
function UI.makeBolt(parent, pos, size, zi)
local root = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = size, BackgroundTransparency = 1, ZIndex = zi or 4, Parent = parent })
new("UIAspectRatioConstraint", { AspectRatio = 1, Parent = root })
local pts = { { 0.70, 0.02 }, { 0.30, 0.54 }, { 0.62, 0.48 }, { 0.28, 0.99 } }
local glows = {}
for pass = 1, 2 do
for i = 1, 3 do
local a, b = pts[i], pts[i + 1]
local dx, dy = b[1] - a[1], b[2] - a[2]
local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((a[1] + b[1]) / 2, (a[2] + b[2]) / 2),
Size = UDim2.fromScale(math.sqrt(dx * dx + dy * dy) + 0.04, pass == 1 and 0.34 or 0.17), Rotation = math.deg(atan2(dy, dx)),
BackgroundColor3 = pass == 1 and GLD or YEL, BackgroundTransparency = pass == 1 and 0.55 or 0, BorderSizePixel = 0,
ZIndex = (zi or 4) + pass, Parent = root })
UI.corner(f, "pill")
if pass == 1 then glows[#glows + 1] = f end
end
end
UI.bolts = UI.bolts or {}
UI.bolts[#UI.bolts + 1] = glows
return root
end
local PRESETS = {
["Lightning Gold"] = { Hue = 226, Sat = 0.8, Val = 0.14, AccentMode = "Gold", OutlineColor = "Gold", BoltColor = "White + Yellow" },
["Ice Blue"] = { Hue = 205, Sat = 0.55, Val = 0.5, AccentMode = "Match hue", OutlineColor = "Cyan", BoltColor = "White" },
["Neon Pink"] = { Hue = 320, Sat = 0.8, Val = 0.2, AccentMode = "Match hue", OutlineColor = "Pink", BoltColor = "White" },
["Emerald"] = { Hue = 150, Sat = 0.8, Val = 0.18, AccentMode = "Match hue", OutlineColor = "Lime", BoltColor = "Yellow" },
["Midnight"] = { Hue = 250, Sat = 0.5, Val = 0.07, AccentMode = "Gold", OutlineColor = "White", BoltColor = "White" },
}
UI.PRESET_NAMES = { "Lightning Gold", "Ice Blue", "Neon Pink", "Emerald", "Midnight" }
function UI.applyPreset(name)
local p = PRESETS[name]
if not p then return end
for k, v in pairs(p) do S[k] = v end
UI.refreshAll()
saveSoon()
end
local lastGlow
function UI.paintStorm()
local h = (S.Hue % 360) / 360
local dark = Color3.fromHSV(h, math.min(S.Sat, 0.9), 0.12)
local mid = (S.AccentMode == "Match hue") and Color3.fromHSV(h, 0.75, 0.42) or Color3.fromRGB(78, 60, 8)
BGGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, dark), ColorSequenceKeypoint.new(0.5, mid), ColorSequenceKeypoint.new(1, dark) })
local tr = 1 - clamp(S.BgGlow or 0.5, 0, 1) * 0.85
BGGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, tr), NumberSequenceKeypoint.new(1, tr) })
lastGlow = S.BgGlow
end
function UI.applyFx()
Storm.Visible = true
if S.Lightning == false then
for _, o in ipairs(pool) do hide(o) end
end
if UI.logoParts then
local jbh = S.LogoStyle ~= "JHub V1"
UI.logoParts.j.Visible, UI.logoParts.h.Visible, UI.logoParts.bolt.Visible = jbh, jbh, jbh
UI.logoParts.word.Visible = not jbh
end
UI.paintStorm()
end
UI.paintStorm()
UI.stormPool = pool
local fxT, nextAt = 0, 0
bind(RunService.Heartbeat, function(dt)
fxT = fxT + dt
local sp = S.OutlineSpeed or 1
if UI.FloatBodyGrad then UI.FloatBodyGrad.Rotation = (fxT * 55 * math.max(sp, 0.2)) % 360 end
if not Window.Visible then return end
if S.BgMove ~= false then
BGGrad.Offset = Vector2.new(math.sin(fxT * 0.3) * 0.35, math.cos(fxT * 0.23) * 0.35)
BGGrad.Rotation = 35 + math.sin(fxT * 0.2) * 30
end
for i, o in ipairs(orbs) do
o.Visible = S.BgOrbs ~= false and S.BgMove ~= false
o.Position = UDim2.fromScale(0.5 + 0.45 * math.sin(fxT * 0.35 * i + i), 0.5 + 0.4 * math.cos(fxT * 0.27 * i + i * 2))
o.BackgroundTransparency = 0.88 + 0.05 * math.sin(fxT * 1.3 + i)
end
if S.BgGlow ~= lastGlow then UI.paintStorm() end
if S.Lightning ~= false then
nextAt = nextAt - dt
if nextAt <= 0 then
local cnt = math.floor(S.BoltCount or 6)
nextAt = (0.1 + math.random() * 0.55) * (8 / math.max(cnt, 1)) / math.max(S.BoltSpeed or 1, 0.2)
for i = 1, math.min(cnt, #pool) do
if not pool[i].on then strike(pool[i]) break end
end
end
for _, o in ipairs(pool) do if o.on then step(o, dt) end end
else
for _, o in ipairs(pool) do if o.on then hide(o) end end
end
if UI.LogoOutlineGrad then UI.LogoOutlineGrad.Rotation = (fxT * 140 * sp) % 360 end
if UI.LogoBGGrad and S.LogoBg ~= false then UI.LogoBGGrad.Offset = Vector2.new(math.sin(fxT * 0.9) * 0.6, 0) end
if UI.bolts then
local pulse = 0.5 + 0.2 * math.sin(fxT * 5)
for _, list in ipairs(UI.bolts) do
for _, f in ipairs(list) do f.BackgroundTransparency = pulse end
end
end
end)
end
local Header = new("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Active = true, Parent = Main })
local LogoTextGrad
do
local dark, mid = Color3.fromRGB(12, 14, 32), Color3.fromRGB(95, 74, 10)
local badge = new("Frame", { Name = "LogoBadge", Position = UDim2.fromOffset(12, 5), Size = UDim2.fromOffset(108, 26),
BackgroundColor3 = dark, ClipsDescendants = true, Parent = Header })
UI.corner(badge, 0.8)
local bg = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(3, 3),
BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = badge })
local bgGrad = new("UIGradient", { Rotation = 20, Parent = bg })
bgGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, dark), ColorSequenceKeypoint.new(0.5, mid), ColorSequenceKeypoint.new(1, dark) })
local ol = new("UIStroke", { Thickness = 2, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = badge })
local olGrad = new("UIGradient", { Parent = ol })
olGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 221, 64)), ColorSequenceKeypoint.new(0.5, WHITE),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 221, 64)) })
local j = UI.label({ Text = "J", TextSize = 22, Position = UDim2.fromOffset(8, 0), Size = UDim2.fromOffset(26, 26), TextColor3 = WHITE, ZIndex = 3, Parent = badge }, true, false)
local h = UI.label({ Text = "H", TextSize = 22, Position = UDim2.fromOffset(74, 0), Size = UDim2.fromOffset(26, 26), TextColor3 = WHITE, ZIndex = 3, Parent = badge }, true, false)
local word = UI.label({ Text = "JHub V1", TextSize = 18, Size = UDim2.fromScale(1, 1), TextColor3 = WHITE, ZIndex = 3, Visible = false, Parent = badge }, true, false)
local bolt = UI.makeBolt(badge, UDim2.fromOffset(54, 13), UDim2.fromOffset(22, 22), 3)
LogoTextGrad = UI.grad(j)
UI.grad(h)
UI.grad(word)
UI.LogoBGGrad, UI.LogoOutlineGrad = bgGrad, olGrad
UI.logoParts = { j = j, h = h, bolt = bolt, word = word }
end
UI.label({ Text = "Glass  " .. VERSION .. "  -  Practical Basketball", TextSize = 11, Position = UDim2.fromOffset(17, 30),
Size = UDim2.new(0, 260, 0, 13), TextXAlignment = Enum.TextXAlignment.Left, Parent = Header }, false, "Sub")
local function headerButton(text, xoff)
local b = new("TextButton", { Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xoff, 0.5, 0),
Size = UDim2.fromOffset(32, 28), AutoButtonColor = false, Parent = Header })
UI.elem(b)
UI.corner(b, 0.7)
UI.stroke(b, 0.55)
UI.label({ Text = text, TextSize = 14, Size = UDim2.fromScale(1, 1), Parent = b }, true, "Text")
return b
end
local CollapseBtn = headerButton("-", -52)
local CloseBtn = headerButton("X", -12)
local HeadLine = new("Frame", { Position = UDim2.new(0, 10, 1, -1), Size = UDim2.new(1, -20, 0, 1), BorderSizePixel = 0,
BackgroundColor3 = WHITE, BackgroundTransparency = 0.7, Parent = Header })
UI.th(HeadLine, "BackgroundColor3", "AccentB")
local Body = new("Frame", { Position = UDim2.fromOffset(0, 47), Size = UDim2.new(1, 0, 1, -47), BackgroundTransparency = 1, Parent = Main })
local Rail = new("ScrollingFrame", { Size = UDim2.new(0, 116, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Body })
new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Rail })
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 8), Parent = Rail })
local RailLine = new("Frame", { Position = UDim2.new(0, 116, 0, 6), Size = UDim2.new(0, 1, 1, -12), BorderSizePixel = 0,
BackgroundColor3 = WHITE, BackgroundTransparency = 0.75, Parent = Body })
UI.th(RailLine, "BackgroundColor3", "AccentB")
local Content = new("Frame", { Position = UDim2.fromOffset(120, 0), Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1, Parent = Body })
function UI.fitScale()
local vp = cam().ViewportSize
local s = math.min(vp.X * 0.94 / 560, vp.Y * 0.86 / 340)
if s > 1.15 then s = 1.15 end
WinScale.Scale = s * S.UIScale
end
function UI.applyWindow()
Main.BackgroundColor3 = Theme.Glass
Main.BackgroundTransparency = S.WinTrans
Sheen.Visible = S.WinGradient
Sheen.BackgroundColor3 = Theme.Sheen
Sheen.BackgroundTransparency = 0
SheenGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.84), NumberSequenceKeypoint.new(0.55, 0.96),
NumberSequenceKeypoint.new(1, 1) })
MainStroke.Thickness = S.OutlineThick
MainStroke.Color = Theme.Outline
MainStroke.Transparency = 0
local clear = S.OutlineShine and 0.55 or 0
StrokeGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, clear),
NumberSequenceKeypoint.new(1, 0) })
StrokeGrad.Color = ColorSequence.new(WHITE, WHITE)
if S.Blur then
if not UI.blur then UI.blur = new("BlurEffect", { Name = "JHubBlur", Size = 0, Parent = Lighting }) end
UI.blur.Size = Window.Visible and S.BlurSize or 0
elseif UI.blur then
UI.blur:Destroy()
UI.blur = nil
end
UI.fitScale()
if UI.paintStorm then UI.paintStorm() end
end
function UI.applyLogo()
if not UI.LogoRoot then return end
UI.LogoRoot.Size = UDim2.fromOffset(S.LogoSize, S.LogoSize)
UI.LogoBody.BackgroundTransparency = 1 - S.LogoOpacity
UI.LogoText.TextTransparency = 1 - S.LogoOpacity
UI.LogoText.TextSize = math.floor(S.LogoSize * 0.4)
end
function UI.applyTheme()
computeTheme()
for _, t in ipairs(UI.themed) do
if t[1].Parent then pcall(function() t[1][t[2]] = Theme[t[3]] end) end
end
for _, t in ipairs(UI.texts) do
if t[1].Parent then
t[1].Font = UI.font(t[2])
t[1].TextStrokeColor3 = Theme.Stroke
t[1].TextStrokeTransparency = S.TextStroke and 0.72 or 1
end
end
for _, c in ipairs(UI.corners) do
if c[1].Parent then c[1].CornerRadius = UDim.new(0, math.floor(S.Corner * c[2])) end
end
for _, f in ipairs(UI.cards) do
if f.Parent then
f.BackgroundColor3 = Theme.Card
f.BackgroundTransparency = S.CardTrans
end
end
local et = UI.elemTrans()
for _, f in ipairs(UI.elems) do
if f.Parent then
f.BackgroundColor3 = Theme.Elem
f.BackgroundTransparency = et
end
end
for _, g in ipairs(UI.grads) do
if g.Parent then UI.paintGrad(g) end
end
UI.applyWindow()
UI.applyLogo()
end
local function dragify(handle, target, onTap, onEnd, scaleOf)
local dragInput, start, startPos, moved
handle.InputBegan:Connect(function(i)
if i.UserInputType == MB1 or i.UserInputType == TOUCH then
dragInput, start, startPos, moved = i, i.Position, target.Position, false
end
end)
bind(UIS.InputChanged, function(i)
if not dragInput then return end
if i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MMOVE) then
local d = i.Position - start
if d.Magnitude > 8 then moved = true end
if moved then
local sc = scaleOf and scaleOf() or 1
target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X / sc, startPos.Y.Scale, startPos.Y.Offset + d.Y / sc)
end
end
end)
bind(UIS.InputEnded, function(i)
if not dragInput then return end
if i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MB1) then
if not moved and onTap then task.spawn(onTap) end
if moved and onEnd then task.spawn(onEnd) end
dragInput = nil
end
end)
end
UI.Window = Window
function UI.keepOnScreen()
local vp = cam().ViewportSize
local p, sz = Window.AbsolutePosition, Window.AbsoluteSize
local sc = WinScale.Scale > 0 and WinScale.Scale or 1
local dx, dy = 0, 0
if p.X + sz.X < 120 then dx = 120 - (p.X + sz.X) end
if p.X > vp.X - 120 then dx = (vp.X - 120) - p.X end
if p.Y < 0 then dy = -p.Y end
if p.Y > vp.Y - 50 then dy = (vp.Y - 50) - p.Y end
if dx ~= 0 or dy ~= 0 then
local pos = Window.Position
Window.Position = UDim2.new(pos.X.Scale, pos.X.Offset + dx / sc, pos.Y.Scale, pos.Y.Offset + dy / sc)
end
end
function UI.recenter()
Window.Position = UDim2.fromScale(0.5, 0.5)
UI.fitScale()
end
local DragHandle = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
ZIndex = 0, Parent = Header })
local RailDrag = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(0, 116, 1, 0),
ZIndex = 0, Parent = Body })
UI.DragHandle, UI.RailDrag = DragHandle, RailDrag
dragify(DragHandle, Window, nil, UI.keepOnScreen, function() return WinScale.Scale end)
dragify(RailDrag, Window, nil, UI.keepOnScreen, function() return WinScale.Scale end)
local Toasts = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 58), Size = UDim2.fromOffset(280, 400),
BackgroundTransparency = 1, Parent = gui })
new("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right,
SortOrder = Enum.SortOrder.LayoutOrder, Parent = Toasts })
local toastOrder = 0
function UI.notify(title, msg, dur)
if not S.Notifications then return end
dur = dur or 3
toastOrder = toastOrder + 1
local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
LayoutOrder = toastOrder, Parent = Toasts })
local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(300, 0),
BackgroundColor3 = Theme.Glass, BackgroundTransparency = math.min(S.WinTrans, 0.35), Parent = wrap })
UI.corner(f, 0.9)
new("UIStroke", { Thickness = 1.5, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f })
new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 8), Parent = f })
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
UI.label({ Text = title, TextSize = 13, Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left,
LayoutOrder = 1, Parent = f }, true, "Text")
UI.label({ Text = tostring(msg or ""), TextSize = 12, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = f }, false, "Sub")
TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(0, 0) }):Play()
task.delay(dur, function()
local t = TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(300, 0) })
t:Play()
t.Completed:Wait()
wrap:Destroy()
end)
end
function UI.refreshTabs()
for _, p in ipairs(UI.pages) do
local on = UI.current == p
p.bg.BackgroundTransparency = on and 0.78 or 1
p.bar.Visible = on
p.lbl.Font = UI.font(on)
end
end
function UI.select(p)
UI.current = p
for _, q in ipairs(UI.pages) do q.frame.Visible = (q == p) end
UI.refreshTabs()
p.frame.Position = UDim2.fromOffset(0, 10)
TweenService:Create(p.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(0, 0) }):Play()
end
function UI.Page(name, glyph)
local order = #UI.pages + 1
local b = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40),
LayoutOrder = order, Parent = Rail })
local bg = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Parent = b })
UI.corner(bg, 0.8)
local bar = new("Frame", { Size = UDim2.new(0, 3, 0, 20), Position = UDim2.new(0, 0, 0.5, -10), BackgroundColor3 = WHITE,
BorderSizePixel = 0, Visible = false, Parent = b })
UI.corner(bar, "pill")
UI.th(bar, "BackgroundColor3", "AccentB")
local icon = new("Frame", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 8, 0.5, -12), BackgroundColor3 = WHITE, Parent = b })
UI.corner(icon, 0.7)
UI.grad(icon)
UI.label({ Text = glyph, TextSize = 13, Size = UDim2.fromScale(1, 1), TextColor3 = Color3.fromRGB(10, 40, 100), Parent = icon }, true, false)
local lbl = UI.label({ Text = name, TextSize = 13, Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -40, 1, 0),
TextXAlignment = Enum.TextXAlignment.Left, Parent = b }, false, "Text")
local frame = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = Content })
UI.th(frame, "ScrollBarImageColor3", "Outline")
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8),
PaddingBottom = UDim.new(0, 14), Parent = frame })
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
local p = { name = name, bg = bg, bar = bar, lbl = lbl, frame = frame, order = 0 }
b.Activated:Connect(function() UI.select(p) end)
table.insert(UI.pages, p)
if not UI.current then UI.select(p) end
return p
end
function UI.Card(page, title)
page.order = page.order + 1
local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = page.order, Parent = page.frame })
UI.card(f)
UI.corner(f, 1)
UI.stroke(f, 0.6)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8),
PaddingBottom = UDim.new(0, 10), Parent = f })
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
local tr = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 0, Parent = f })
local dot = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0, 0, 0.5, -4), BackgroundColor3 = WHITE, Parent = tr })
UI.corner(dot, "pill")
UI.grad(dot)
UI.label({ Text = title, TextSize = 14, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -16, 1, 0),
TextXAlignment = Enum.TextXAlignment.Left, Parent = tr }, true, "Text")
local line = new("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.75,
BorderSizePixel = 0, LayoutOrder = 1, Parent = f })
return { frame = f, order = 1, page = page }
end
local function nextOrder(card)
card.order = card.order + 1
return card.order
end
local function row(card, h)
return new("Frame", { Size = UDim2.new(1, 0, 0, h or 30), BackgroundTransparency = 1, LayoutOrder = nextOrder(card), Parent = card.frame })
end
function UI.Note(card, text, colorKey)
return UI.label({ Text = text, TextSize = 11, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
LayoutOrder = nextOrder(card), Parent = card.frame }, false, colorKey or "Sub")
end
function UI.Stat(card, name)
local r = row(card, 20)
UI.label({ Text = name, TextSize = 12, Size = UDim2.new(0.45, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = r }, false, "Sub")
return UI.label({ Text = "-", TextSize = 12, Position = UDim2.fromScale(0.35, 0), Size = UDim2.new(0.65, 0, 1, 0),
TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, true, "Text")
end
function UI.Toggle(card, text, flag, cb)
local r = row(card, 30)
UI.label({ Text = text, TextSize = 13, Size = UDim2.new(1, -52, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
local sw = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(42, 22), Parent = r })
UI.elem(sw)
UI.corner(sw, "pill")
UI.stroke(sw, 0.45)
local fill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Parent = sw })
UI.corner(fill, "pill")
UI.grad(fill)
local knob = new("Frame", { Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = WHITE, Parent = sw })
UI.corner(knob, "pill")
local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = r })
local function show(anim)
local on = S[flag] and true or false
local ti = TweenInfo.new(anim and 0.18 or 0, Enum.EasingStyle.Quad)
TweenService:Create(fill, ti, { BackgroundTransparency = on and 0 or 1 }):Play()
TweenService:Create(knob, ti, { Position = on and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2) }):Play()
end
UI.flagRefresh[flag] = UI.flagRefresh[flag] or {}
table.insert(UI.flagRefresh[flag], function() show(true) end)
table.insert(UI.refresh, function() show(false) end)
if cb and not UI.flagCB[flag] then UI.flagCB[flag] = cb end
show(false)
hit.Activated:Connect(function() UI.set(flag, not S[flag]) end)
end
local function holdRepeat(btn, fn)
local token = 0
btn.InputBegan:Connect(function(i)
if i.UserInputType == MB1 or i.UserInputType == TOUCH then
token = token + 1
local mine = token
fn()
task.spawn(function()
task.wait(0.35)
while token == mine and JH.Running do
fn()
task.wait(0.07)
end
end)
i.Changed:Connect(function()
if i.UserInputState == Enum.UserInputState.End then token = token + 1 end
end)
end
end)
end
function UI.Slider(card, text, flag, min, max, step, dec, suffix, cb)
local r = row(card, 54)
suffix = suffix or ""
UI.label({ Text = text, TextSize = 13, Size = UDim2.new(1, -78, 0, 20), TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
local box = new("TextBox", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(74, 20),
BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, TextSize = 12, ClearTextOnFocus = false, Parent = r })
UI.text(box, true)
UI.th(box, "TextColor3", "Text")
local function stepButton(label, x, anchor)
local b = new("TextButton", { Text = "", AnchorPoint = Vector2.new(anchor, 0), Position = UDim2.new(x, 0, 0, 26),
Size = UDim2.fromOffset(26, 24), AutoButtonColor = false, Parent = r })
UI.elem(b)
UI.corner(b, 0.7)
UI.stroke(b, 0.5)
UI.label({ Text = label, TextSize = 16, Size = UDim2.fromScale(1, 1), Parent = b }, true, "Text")
return b
end
local minus = stepButton("-", 0, 0)
local plus = stepButton("+", 1, 1)
local bar = new("Frame", { Position = UDim2.new(0, 34, 0, 34), Size = UDim2.new(1, -68, 0, 8), Parent = r })
UI.elem(bar)
UI.corner(bar, "pill")
local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, Parent = bar })
UI.corner(fill, "pill")
UI.grad(fill)
local knob = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(16, 16),
BackgroundColor3 = WHITE, Parent = bar })
UI.corner(knob, "pill")
new("UIStroke", { Thickness = 2, Color = Theme.AccentB, Parent = knob })
local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Position = UDim2.new(0, 30, 0, 24), Size = UDim2.new(1, -60, 0, 28), Parent = r })
local mult = 10 ^ dec
local function show()
local v = tonumber(S[flag]) or min
local a = clamp((v - min) / (max - min), 0, 1)
fill.Size = UDim2.fromScale(a, 1)
knob.Position = UDim2.fromScale(a, 0.5)
if not box:IsFocused() then box.Text = tostring(v) .. suffix end
end
local function setv(v)
v = clamp(min + math.floor((v - min) / step + 0.5) * step, min, max)
v = math.floor(v * mult + 0.5) / mult
S[flag] = v
local list = UI.flagRefresh[flag]
if list then
for _, f in ipairs(list) do pcall(f) end
end
if cb then cb(v) end
end
UI.addRefresh(flag, show)
show()
box.FocusLost:Connect(function()
local n = tonumber((string.gsub(box.Text, "[^%d%.%-]", "")))
if n then
setv(n)
saveSoon()
else
show()
end
end)
holdRepeat(minus, function() setv((tonumber(S[flag]) or min) - step) saveSoon() end)
holdRepeat(plus, function() setv((tonumber(S[flag]) or min) + step) saveSoon() end)
local dragInput
local function upd(x)
local a, w = bar.AbsolutePosition.X, bar.AbsoluteSize.X
if w <= 0 then return end
setv(min + (max - min) * clamp((x - a) / w, 0, 1))
end
hit.InputBegan:Connect(function(i)
if i.UserInputType == MB1 or i.UserInputType == TOUCH then
dragInput = i
card.page.frame.ScrollingEnabled = false
upd(i.Position.X)
end
end)
bind(UIS.InputChanged, function(i)
if dragInput and (i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MMOVE)) then upd(i.Position.X) end
end)
bind(UIS.InputEnded, function(i)
if dragInput and (i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MB1)) then
dragInput = nil
card.page.frame.ScrollingEnabled = true
saveSoon()
end
end)
end
function UI.Input(card, text, flag, cb, placeholder)
local r = row(card, 30)
local get, setf
if type(flag) == "table" then
get, setf = flag.get, flag.set
else
get = function() return S[flag] end
setf = function(v) S[flag] = v end
end
local hasText = text and text ~= ""
if hasText then
UI.label({ Text = text, TextSize = 13, Size = UDim2.new(0.4, -4, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
end
local b = new("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
Size = hasText and UDim2.new(0.6, 0, 0, 26) or UDim2.new(1, 0, 0, 26), Text = tostring(get() or ""),
PlaceholderText = placeholder or "", ClearTextOnFocus = false, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, Parent = r })
UI.text(b, false)
UI.elem(b)
UI.th(b, "TextColor3", "Text")
UI.th(b, "PlaceholderColor3", "Sub")
UI.corner(b, 0.7)
UI.stroke(b, 0.5)
new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 6), Parent = b })
b.FocusLost:Connect(function()
setf(b.Text)
if cb then task.spawn(cb, b.Text) end
saveSoon()
end)
UI.addRefresh(type(flag) == "string" and flag or nil, function()
if not b:IsFocused() then b.Text = tostring(get() or "") end
end)
return b
end
function UI.Button(card, text, cb, primary)
local r = row(card, 32)
local b = new("TextButton", { Size = UDim2.fromScale(1, 1), AutoButtonColor = false, Text = "", BackgroundColor3 = WHITE, Parent = r })
UI.corner(b, 0.8)
if primary then
UI.grad(b)
else
UI.elem(b)
UI.stroke(b, 0.45)
end
local l = UI.label({ Text = text, TextSize = 13, Size = UDim2.fromScale(1, 1), TextColor3 = WHITE, Parent = b }, true,
(not primary) and "Text" or false)
if primary then l.TextColor3 = Color3.fromRGB(8, 32, 90) end
b.Activated:Connect(function()
task.spawn(function()
local ok, err = pcall(cb)
if not ok then
log(text .. " error: " .. tostring(err))
notify("Error", tostring(err), 4)
end
end)
end)
return b, l
end
function UI.Buttons(card, list)
local r = row(card, 32)
local n = #list
for i, item in ipairs(list) do
local b = new("TextButton", { Size = UDim2.new(1 / n, -4, 1, 0), Position = UDim2.new((i - 1) / n, (i == 1) and 0 or 3, 0, 0),
AutoButtonColor = false, Text = "", Parent = r })
UI.elem(b)
UI.corner(b, 0.8)
UI.stroke(b, 0.45)
UI.label({ Text = item[1], TextSize = 12, Size = UDim2.fromScale(1, 1), TextTruncate = Enum.TextTruncate.AtEnd, Parent = b }, true, "Text")
b.Activated:Connect(function()
task.spawn(function()
local ok, err = pcall(item[2])
if not ok then
log(item[1] .. " error: " .. tostring(err))
notify("Error", tostring(err), 4)
end
end)
end)
end
end
function UI.Dropdown(card, text, flag, options, cb)
local r = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
LayoutOrder = nextOrder(card), Parent = card.frame })
new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = r })
local head = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 1, Parent = r })
local hasText = text and text ~= ""
if hasText then
UI.label({ Text = text, TextSize = 13, Size = UDim2.new(0.4, -4, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, Parent = head }, false, "Text")
end
local btn = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
Size = hasText and UDim2.new(0.6, 0, 0, 26) or UDim2.new(1, 0, 0, 26), AutoButtonColor = false, Text = "", Parent = head })
UI.elem(btn)
UI.corner(btn, 0.7)
UI.stroke(btn, 0.45)
local val = UI.label({ Text = "", TextSize = 12, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -26, 1, 0),
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn }, false, "Text")
local arrow = UI.label({ Text = "v", TextSize = 11, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
Size = UDim2.fromOffset(12, 12), Parent = btn }, true, "Text")
local list = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, LayoutOrder = 2, Parent = r })
UI.elem(list)
UI.corner(list, 0.7)
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = list })
local function getOpts()
if type(options) == "function" then
local ok, o = pcall(options)
if ok and type(o) == "table" then return o end
return {}
end
return options
end
local function show() val.Text = (S[flag] == nil or S[flag] == "") and "None" or tostring(S[flag]) end
local function build()
for _, c in ipairs(list:GetChildren()) do
if c:IsA("TextButton") then c:Destroy() end
end
for i, o in ipairs(getOpts()) do
local sel = (o == S[flag])
local ob = new("TextButton", { Size = UDim2.new(1, 0, 0, 24), AutoButtonColor = false, Text = "", BackgroundColor3 = WHITE,
BackgroundTransparency = sel and 0.7 or 1, LayoutOrder = i, Parent = list })
UI.corner(ob, 0.6)
UI.label({ Text = "  " .. tostring(o), TextSize = 12, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Left,
Parent = ob }, sel, "Text")
ob.Activated:Connect(function()
list.Visible = false
arrow.Text = "v"
UI.set(flag, o, false)
if cb then task.spawn(cb, o) end
end)
end
end
btn.Activated:Connect(function()
if list.Visible then
list.Visible = false
arrow.Text = "v"
else
build()
list.Visible = true
arrow.Text = "^"
end
end)
UI.addRefresh(flag, show)
show()
end
function UI.Keybind(card, text, get, setk)
local r = row(card, 30)
UI.label({ Text = text, TextSize = 13, Size = UDim2.new(1, -104, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(96, 26),
AutoButtonColor = false, Text = "", Parent = r })
UI.elem(b)
UI.corner(b, 0.7)
UI.stroke(b, 0.45)
local l = UI.label({ Text = "", TextSize = 12, Size = UDim2.fromScale(1, 1), Parent = b }, true, "Text")
local function show()
local k = get()
l.Text = (k and k ~= "") and k or "None"
end
show()
table.insert(UI.refresh, show)
b.Activated:Connect(function()
l.Text = "press key..."
UI.listening = function(name)
setk(name or "")
show()
saveSoon()
end
task.delay(6, function()
if l.Text == "press key..." then
UI.listening = nil
show()
end
end)
end)
end
UI.visible = true
function UI.show(v)
UI.visible = v
if v then
Window.Visible = true
local target = WinScale.Scale
WinScale.Scale = target * 0.9
TweenService:Create(WinScale, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = target }):Play()
else
Window.Visible = false
UI.fitScale()
end
if UI.blur then UI.blur.Size = (v and S.BlurSize) or 0 end
end
function UI.toggleMenu() UI.show(not Window.Visible) end
CloseBtn.Activated:Connect(function() JH.Unload() end)
local collapsed = false
CollapseBtn.Activated:Connect(function()
collapsed = not collapsed
Body.Visible = not collapsed
Window.Size = collapsed and UDim2.fromOffset(560, 46) or UDim2.fromOffset(560, 340)
end)
bind(cam():GetPropertyChangedSignal("ViewportSize"), function() UI.fitScale() end)
local LogoRoot = new("Frame", { Name = "LogoRoot", Size = UDim2.fromOffset(S.LogoSize, S.LogoSize), BackgroundTransparency = 1, Parent = gui })
if S.LogoX >= 0 and S.LogoY >= 0 then
LogoRoot.Position = UDim2.fromOffset(S.LogoX, S.LogoY)
else
LogoRoot.Position = UDim2.new(0, 14, 0.4, 0)
end
local LogoGlow = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1.5, 1.5),
BackgroundColor3 = WHITE, BackgroundTransparency = 0.82, ZIndex = 0, Parent = LogoRoot })
UI.corner(LogoGlow, 2)
local LogoBody = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, ZIndex = 2, Parent = LogoRoot })
UI.corner(LogoBody, 1.6)
LogoBody.BackgroundColor3 = Color3.fromRGB(12, 14, 32)
UI.FloatBodyGrad = new("UIGradient", { Rotation = 30, Parent = LogoBody })
UI.FloatBodyGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 14, 32)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 78, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 32)) })
local LogoRing = new("UIStroke", { Thickness = 2.5, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = LogoBody })
local LogoRingGrad = new("UIGradient", { Parent = LogoRing })
LogoRingGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 0) })
LogoRingGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 221, 64)), ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 221, 64)) })
local LogoText = UI.label({ Text = "", TextSize = 22, Size = UDim2.fromScale(1, 1), TextColor3 = WHITE, ZIndex = 3, Parent = LogoBody }, true, false)
local Spark1 = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), BackgroundColor3 = WHITE, ZIndex = 4, Parent = LogoRoot })
UI.corner(Spark1, "pill")
local Spark2 = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5), BackgroundColor3 = WHITE, BackgroundTransparency = 0.25, ZIndex = 4, Parent = LogoRoot })
UI.corner(Spark2, "pill")
UI.LogoRoot, UI.LogoBody, UI.LogoText = LogoRoot, LogoBody, LogoText
do
local lj = UI.label({ Text = "J", TextScaled = true, Position = UDim2.fromScale(0.1, 0.27), Size = UDim2.fromScale(0.28, 0.46), TextColor3 = WHITE, ZIndex = 3, Parent = LogoBody }, true, false)
local lh = UI.label({ Text = "H", TextScaled = true, Position = UDim2.fromScale(0.62, 0.27), Size = UDim2.fromScale(0.28, 0.46), TextColor3 = WHITE, ZIndex = 3, Parent = LogoBody }, true, false)
UI.makeBolt(LogoBody, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.36, 0.62), 3)
UI.FloatLetters = { lj, lh }
end
dragify(LogoBody, LogoRoot, UI.toggleMenu, function()
S.LogoX, S.LogoY = LogoRoot.AbsolutePosition.X, LogoRoot.AbsolutePosition.Y
saveSoon()
end)
local InfoBar = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6), Size = UDim2.fromOffset(0, 24),
AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.Glass, BackgroundTransparency = 0.45, Parent = gui })
UI.corner(InfoBar, 0.8)
new("UIStroke", { Thickness = 1.5, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = InfoBar })
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = InfoBar })
local InfoText = UI.label({ Text = "", TextSize = 12, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = InfoBar }, true, "Text")
local BackupBtn = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(92, 44), Position = UDim2.new(1, -112, 0.55, 0),
BackgroundColor3 = WHITE, Visible = false, Parent = gui })
UI.corner(BackupBtn, 0.9)
UI.grad(BackupBtn)
new("UIStroke", { Thickness = 2, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = BackupBtn })
UI.label({ Text = "GREEN SHOT", TextSize = 12, Size = UDim2.fromScale(1, 1), TextColor3 = Color3.fromRGB(8, 32, 90), Parent = BackupBtn }, true, false)
dragify(BackupBtn, BackupBtn, function() Shot.run("backup") end)
local execName = "Unknown"
pcall(function()
if identifyexecutor then
local a, b = identifyexecutor()
execName = tostring(a or "Unknown") .. ((b and b ~= "") and (" " .. tostring(b)) or "")
elseif getexecutorname then
execName = tostring(getexecutorname())
end
end)
JH.execName = execName
local placeName = "Practical Basketball"
JH.placeName = placeName
task.spawn(function()
pcall(function()
placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name
JH.placeName = placeName
end)
end)
local function has(f) return f ~= nil and "yes" or "no" end
local R = {}
local P = UI.Page("Main", "M")
do
local c = UI.Card(P, "Profile")
local prof = row(c, 62)
local av = new("ImageLabel", { Size = UDim2.fromOffset(58, 58), Position = UDim2.fromOffset(0, 2), BackgroundColor3 = WHITE,
BackgroundTransparency = 0.85, Parent = prof })
UI.corner(av, "pill")
new("UIStroke", { Thickness = 2, Color = WHITE, Parent = av })
UI.label({ Text = LP.DisplayName, TextSize = 17, Position = UDim2.fromOffset(70, 8), Size = UDim2.new(1, -70, 0, 22),
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof }, true, "Text")
UI.label({ Text = "@" .. LP.Name, TextSize = 12, Position = UDim2.fromOffset(70, 32), Size = UDim2.new(1, -70, 0, 16),
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof }, false, "Sub")
task.spawn(function()
local ok, url = pcall(function()
return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)
if ok and url then av.Image = url end
end)
UI.Stat(c, "Roblox username").Text = LP.Name
R.game = UI.Stat(c, "Game")
R.time = UI.Stat(c, "Time")
UI.Stat(c, "Executor").Text = execName
local sv = UI.Card(P, "Server")
UI.Button(sv, "Rejoin", Net.rejoin, true)
UI.Buttons(sv, { { "Join new server", function() Net.hop("new") end }, { "Join lower server", function() Net.hop("lower") end } })
local cc = UI.Card(P, "Codes")
UI.Input(cc, "", "Codes", nil, "codes separated by spaces")
UI.Button(cc, "Redeem all codes", Net.redeemAll, true)
local ae = UI.Card(P, "Auto execute")
UI.Toggle(ae, "Auto execute", "AutoExec", function(v) Net.autoExec(v) end)
local rc = UI.Card(P, "Game recorder")
UI.Toggle(rc, "Record the game", "RecOn", function(v) if v then Rec.start() else Rec.stop() end end)
R.rec = UI.Stat(rc, "Recorded")
UI.Buttons(rc, { { "Copy recording", Rec.copy }, { "Clear", Rec.clear } })
UI.Button(rc, "Copy remote spy (RSpy)", Rec.copySpy)
local ag = UI.Card(P, "Auto Green status")
UI.autoStat = { shot = UI.Stat(ag, "Jump shot"), timing = UI.Stat(ag, "Timing"), state = UI.Stat(ag, "State"), last = UI.Stat(ag, "Last shot"), ping = UI.Stat(ag, "Ping fix"),
adj = UI.Note(ag, "No change yet") }
local dc = UI.Card(P, "Animation detector")
UI.detStat = { now = UI.Stat(dc, "Animation now"), type = UI.Stat(dc, "Type"), list = UI.Note(dc, "Play a shot, layup, dunk or post move") }
UI.Toggle(dc, "Pop up each new animation", "DetNotify")
UI.Button(dc, "Copy animation list", Anim.detCopy)
local sr = UI.Card(P, "Shot recorder")
UI.Toggle(sr, "Record shots (turn off to copy everything)", "RecShots", function(v) if v then Rec.shotStart() else Rec.shotStop() end end)
UI.Toggle(sr, "Sweep timings while recording", "Sweep")
UI.Button(sr, "Capture everything about shooting", Rec.captureAll)
local gs = UI.Card(P, "Game scanner")
UI.Buttons(gs, { { "Scan game and copy", Rec.scanGame }, { "Copy last scan", Rec.copyScan } })
end
function UI.restore(keys, after)
for _, k in ipairs(keys) do S[k] = DEFAULTS[k] end
if after then pcall(after) end
UI.refreshAll()
saveSoon()
notify("Restored", "Back to default", 2)
end
P = UI.Page("Shooting", "S")
do
local g = UI.Card(P, "Auto Green")
UI.Toggle(g, "Auto Green", "AutoGreen")
UI.Dropdown(g, "Shot style (Hold or Tap)", "ShotStyle", { "Hold", "Tap" })
UI.Slider(g, "Starting hold time", "HoldTime", 0.08, 1.6, 0.005, 3, "s")
UI.Slider(g, "Release earlier / later", "Nudge", -150, 150, 5, 0, "ms")
UI.Toggle(g, "Perfect green", "PerfectGreen")
UI.Note(g, "Makes up for high ping")
UI.Slider(g, "Perfect green strength", "PerfectGreenPct", 0, 150, 5, 0, "%")
local ln = UI.Card(P, "Learning")
UI.Toggle(ln, "Learn timing from results", "Learn")
UI.Toggle(ln, "Auto-learn new shot animations", "AutoCal")
UI.Button(ln, "Forget learned animations", function()
Shot.autoReset()
notify("Auto Green", "Learned animations cleared", 2)
end)
local cal = UI.Card(P, "Auto Calibrate")
UI.Toggle(cal, "Auto Calibrate", "AutoCalibrate")
UI.Slider(cal, "Learn speed", "CalSpeed", 0.1, 1, 0.05, 2)
local at = UI.Card(P, "Auto Timing")
UI.Toggle(at, "Auto Timing", "AutoTiming")
UI.Slider(at, "Ping compensation", "PingComp", 0, 100, 5, 0, "%")
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "AutoGreen", "ShotStyle", "HoldTime", "Nudge", "Learn", "PerfectGreen", "PerfectGreenPct", "AutoCalibrate", "CalSpeed", "AutoTiming", "PingComp", "ShotTimes",
"ShotRatio", "PacketMul", "PacketOn" }, function()
Shot.parseTimes()
Shot.brackets = {}
end)
end)
end
P = UI.Page("Dribbling", "D")
do
local d = UI.Card(P, "Dribble Glide")
UI.Toggle(d, "Dribble Glide", "DribbleGlide")
UI.Slider(d, "Glide speed", "DribbleGlidePower", 1, 80, 1, 0)
UI.Slider(d, "Time", "DribbleGlideTime", 0.05, 1, 0.01, 2, "s")
local sg = UI.Card(P, "Shot Glide")
UI.Toggle(sg, "Shot Glide", "ShotGlide")
UI.Slider(sg, "Glide speed", "ShotGlidePower", 1, 80, 1, 0)
UI.Slider(sg, "Time", "ShotGlideTime", 0.05, 1, 0.01, 2, "s")
local gt = UI.Card(P, "Gather Step Glide")
UI.Toggle(gt, "Gather Step Glide", "GatherGlide")
UI.Slider(gt, "Glide speed", "GatherGlidePower", 1, 80, 1, 0)
UI.Slider(gt, "Time", "GatherGlideTime", 0.05, 1, 0.01, 2, "s")
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "DribbleGlide", "DribbleGlidePower", "DribbleGlideTime", "ShotGlide", "ShotGlidePower", "ShotGlideTime", "GatherGlide",
"GatherGlidePower", "GatherGlideTime" })
end)
end
P = UI.Page("Players", "P")
do
local b = UI.Card(P, "Walk speed boost (walking, no ball)")
UI.Toggle(b, "Walk speed boost", "SpeedOn", function(v) if v then Speed.resetAuto() end end)
UI.Slider(b, "Level (0 = normal speed)", "SpeedAdd", 0, 15, 1, 0)
local rb = UI.Card(P, "Run speed boost (running, no ball)")
UI.Toggle(rb, "Run speed boost", "RunOn", function(v) if v then Speed.resetAuto() end end)
UI.Slider(rb, "Level (0 = normal speed)", "RunAdd", 0, 15, 1, 0)
local bb = UI.Card(P, "Ball speed boost (with the ball)")
UI.Toggle(bb, "Ball speed boost", "BallSpeedOn", function(v) if v then Speed.resetAuto() end end)
UI.Slider(bb, "Level (0 = normal speed)", "BallAdd", 0, 15, 1, 0)
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "SpeedOn", "SpeedAdd", "RunOn", "RunAdd", "BallSpeedOn", "BallAdd" }, function() Speed.resetAuto() end)
end)
end
P = UI.Page("Ball Mags", "B")
do
local m = UI.Card(P, "Ball magnet")
UI.Toggle(m, "Ball magnet", "BallMagnet")
UI.Dropdown(m, "How it gets the ball", "MagnetMode", { "Pull to me", "Go to the ball" })
UI.Slider(m, "Range", "MagnetRange", 10, 150, 5, 0, " studs")
UI.Slider(m, "Minimum time on the ball (frames)", "MagnetFrames", 1, 6, 1, 0)
UI.Button(m, "Get the ball now", function()
if not Feat.getBall(true) then notify("Ball magnet", "No ball found.", 2) end
end)
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "BallMagnet", "MagnetMode", "MagnetRange", "MagnetFrames" })
end)
end
P = UI.Page("Features", "F")
do
local lg = UI.Card(P, "Practical Basketball logo")
UI.Toggle(lg, "Show logo", "LogoOn")
UI.Dropdown(lg, "Logo", "Logo", Feat.V.LOGO_NAMES)
local mc = UI.Card(P, "Mascot")
UI.Toggle(mc, "Mascot", "MascotOn")
UI.Dropdown(mc, "Pick a mascot", "Mascot", Feat.V.MASCOT_NAMES)
local mx = UI.Card(P, "Maxed stats (only you see this)")
UI.Toggle(mx, "Max overall", "MaxOverall")
UI.Toggle(mx, "Max coins", "MaxCoins")
UI.Toggle(mx, "Max badges", "MaxBadges")
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "LogoOn", "Logo", "MascotOn", "Mascot", "MaxOverall", "MaxCoins", "MaxBadges" })
end)
end
P = UI.Page("UI", "U")
do
local gl = UI.Card(P, "Glass look")
UI.Slider(gl, "Menu transparency", "WinTrans", 0, 0.95, 0.01, 2, nil, function() UI.applyWindow() end)
UI.Slider(gl, "Card transparency", "CardTrans", 0.3, 0.98, 0.01, 2, nil, function() UI.applyTheme() end)
UI.Slider(gl, "Color shade (hue)", "Hue", 0, 360, 1, 0, nil, function() UI.applyTheme() end)
UI.Slider(gl, "Color strength", "Sat", 0.1, 1, 0.01, 2, nil, function() UI.applyTheme() end)
UI.Slider(gl, "Brightness", "Val", 0.2, 1, 0.01, 2, nil, function() UI.applyTheme() end)
local ol = UI.Card(P, "Outline")
UI.Dropdown(ol, "Outline color", "OutlineColor", OUTLINE_NAMES, function() UI.applyTheme() end)
UI.Slider(ol, "Outline thickness", "OutlineThick", 0, 6, 0.5, 1, nil, function() UI.applyWindow() end)
UI.Toggle(ol, "Moving outline shine", "OutlineShine", function() UI.applyWindow() end)
local tx = UI.Card(P, "Text")
UI.Dropdown(tx, "Text color", "TextColor", TEXT_NAMES, function() UI.applyTheme() end)
UI.Toggle(tx, "Dark text outline", "TextStroke", function() UI.applyTheme() end)
UI.Dropdown(tx, "Font", "Font", FONT_NAMES, function() UI.applyTheme() UI.refreshTabs() end)
local ly = UI.Card(P, "Layout")
UI.Slider(ly, "Corner roundness", "Corner", 0, 20, 1, 0, nil, function() UI.applyTheme() end)
UI.Slider(ly, "Menu size", "UIScale", 0.6, 1.5, 0.05, 2, "x", function() UI.fitScale() end)
UI.Toggle(ly, "Info bar", "Watermark", function() InfoBar.Visible = S.Watermark end)
UI.Button(ly, "Put the menu back in the middle", function() UI.recenter() end)
local lg = UI.Card(P, "Logo")
UI.Slider(lg, "Logo size", "LogoSize", 36, 96, 2, 0, nil, function() UI.applyLogo() end)
UI.Slider(lg, "Logo visibility", "LogoOpacity", 0.3, 1, 0.05, 2, nil, function() UI.applyLogo() end)
UI.Toggle(lg, "Moving logo animation", "LogoAnim")
UI.Button(lg, "Reset logo position", function()
S.LogoX, S.LogoY = -1, -1
LogoRoot.Position = UDim2.new(0, 14, 0.4, 0)
saveSoon()
end)
local pr = UI.Card(P, "Presets")
UI.Note(pr, "One tap look changes. Everything below can still be tuned by hand.")
UI.Dropdown(pr, "Theme preset", "Preset", UI.PRESET_NAMES, function(v) UI.applyPreset(v) end)
UI.Dropdown(pr, "Accent colors", "AccentMode", { "Gold", "Match hue" }, function() UI.applyTheme() end)
local lt = UI.Card(P, "Lightning")
UI.Toggle(lt, "Lightning background", "Lightning", function() UI.applyFx() end)
UI.Dropdown(lt, "Lightning colors", "BoltColor", { "White + Yellow", "Yellow", "White" })
UI.Slider(lt, "Lightning amount", "BoltCount", 1, 10, 1, 0)
UI.Slider(lt, "Lightning speed", "BoltSpeed", 0.3, 3, 0.1, 1, "x")
UI.Slider(lt, "Lightning thickness", "BoltThick", 1, 5, 0.5, 1)
UI.Slider(lt, "Lightning brightness", "BoltBright", 0.2, 1, 0.05, 2)
local bgc = UI.Card(P, "Moving background")
UI.Toggle(bgc, "Moving background", "BgMove")
UI.Slider(bgc, "Background glow", "BgGlow", 0, 1, 0.05, 2, nil, function() UI.paintStorm() end)
UI.Toggle(bgc, "Floating light orbs", "BgOrbs")
local hl = UI.Card(P, "Header logo")
UI.Dropdown(hl, "Logo style", "LogoStyle", { "J bolt H", "JHub V1" }, function() UI.applyFx() end)
UI.Toggle(hl, "Moving logo background", "LogoBg")
UI.Slider(hl, "Moving outline speed", "OutlineSpeed", 0, 4, 0.1, 1, "x")
local al = UI.Card(P, "Alerts and keys")
UI.Toggle(al, "Notifications", "Notifications")
UI.Toggle(al, "Sounds", "Sounds")
UI.Keybind(al, "Menu key (PC)", function() return S.MenuKey end, function(v) S.MenuKey = (v ~= "" and v) or "RightShift" end)
local tl = UI.Card(P, "Tools")
UI.Button(tl, "Save settings now", function()
save()
notify("Saved", "Settings saved", 2)
end)
UI.Button(tl, "Reset all settings", function()
for k, v in pairs(DEFAULTS) do S[k] = v end
UI.refreshAll()
saveSoon()
notify("Reset", "All settings back to default", 2)
end)
UI.Button(tl, "Unload JHub", function() JH.Unload() end)
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "WinTrans", "CardTrans", "Hue", "Sat", "Val", "OutlineColor", "OutlineThick", "OutlineShine", "TextColor", "TextStroke",
"Font", "Corner", "UIScale", "Watermark", "LogoSize", "LogoOpacity", "LogoAnim", "Notifications", "Sounds", "MenuKey" }, function()
UI.applyTheme()
UI.applyWindow()
UI.applyLogo()
UI.fitScale()
InfoBar.Visible = S.Watermark
UI.refreshTabs()
end)
end)
end
bind(UIS.InputBegan, function(i, gp)
if Rec.on then pcall(Rec.input, "down", i) end
if Picker.mode and (i.UserInputType == TOUCH or i.UserInputType == MB1) then
local mode = Picker.mode
Picker.mode = nil
task.defer(Picker.handle, mode, i.Position)
return
end
if i.UserInputType == TOUCH then
if Window.Visible and Input.hits(Window, i.Position) then return end
if Input.hits(LogoRoot, i.Position) then return end
if BackupBtn.Visible and Input.hits(BackupBtn, i.Position) then return end
Input.lastTouch = { input = i, t0 = tick(), pos = i.Position, obj = Input.topButtonAt(i.Position) }
if (S.DribbleGlide or S.GatherGlide) and not Shot.hooked then
for _, kind in ipairs({ "dribble", "gather" }) do
for _, b in ipairs(Input.glideButtons(kind)) do
if b.Parent and visibleChain(b) and Input.hits(b, i.Position) then
Glide.fire(kind, "touch on the " .. kind .. " button")
break
end
end
end
end
if S.RunOn then
local sb = Input.findButton("Sprint")
if sb and visibleChain(sb) and Input.hits(sb, i.Position) then Input.sprintTouch = i end
end
if S.ShotGlide and not (S.AutoGreen and S.HookShootButton) and not Shot.hooked then
local gb = Input.findButton("Shoot")
if gb and visibleChain(gb) and Input.hits(gb, i.Position) then Glide.fire("shot", "touch on the shoot button") end
end
if (S.AutoGreen or Bar.isArmed()) and S.HookShootButton and not Shot.busy and not Shot.hooked then
local btn = Input.findButton("Shoot")
if btn and visibleChain(btn) and Input.hits(btn, i.Position) then
local ctx = { btn = btn, input = i, t0 = tick(), ended = false }
Shot.touchCtx = ctx
task.spawn(Shot.run, "touch", ctx)
end
end
return
end
if i.UserInputType ~= KEYBOARD then return end
if UI.listening then
local f = UI.listening
UI.listening = nil
if i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Backspace then f("") else f(i.KeyCode.Name) end
return
end
if UIS:GetFocusedTextBox() then return end
local kc = i.KeyCode
if kc == Input.keyCode(S.MenuKey) then
UI.toggleMenu()
return
end
if Shot.busy then return end
if kc == Input.keyCode(S.ShootKey) then
if S.ManualAssist and (S.AutoGreen or Bar.isArmed()) and not Shot.hooked then task.spawn(Shot.run, "manualKey", { kc = kc, t0 = tick() }) end
return
end
local keys = tokens(S.DribbleKeys)
for _, name in ipairs(keys) do
if Input.keyCode(name) == kc and (Ball.holding or not next(Ball.parts)) and not Shot.hooked then
Glide.fire("dribble", "key " .. name)
break
end
end
end)
bind(UIS.InputEnded, function(i)
local ctx = Shot.touchCtx
if ctx and i == ctx.input then ctx.ended = true end
if Rec.on then pcall(Rec.input, "up", i) end
if Input.lastTouch and Input.lastTouch.input == i then Input.lastTouch.endT = tick() end
if Input.sprintTouch == i then Input.sprintTouch = nil end
end)
local rainbowHue = 0
bind(RunService.Heartbeat, function(dt)
JH.FPS = JH.FPS * 0.9 + (1 / math.max(dt, 0.001)) * 0.1
pcall(Anim.poll)
local t = tick()
if Window.Visible then
StrokeGrad.Rotation = (t * 70 * (S.OutlineSpeed or 1)) % 360
local off = (((t * 0.4) % 2) - 1)
LogoTextGrad.Offset = Vector2.new(off, 0)
if S.OutlineColor == "Rainbow" then
rainbowHue = (rainbowHue + dt * 0.25) % 1
MainStroke.Color = Color3.fromHSV(rainbowHue, 0.55, 1)
end
end
if S.LogoAnim then
LogoBody.Position = UDim2.fromOffset(0, math.sin(t * 2.2) * 3)
LogoGlow.BackgroundTransparency = 0.8 + math.sin(t * 3) * 0.08
LogoRingGrad.Rotation = (t * 120) % 360
local a = t * 2.4
Spark1.Position = UDim2.new(0.5, math.cos(a) * S.LogoSize * 0.62, 0.5, math.sin(a) * S.LogoSize * 0.62)
Spark2.Position = UDim2.new(0.5, math.cos(a + 3.14) * S.LogoSize * 0.55, 0.5, math.sin(a + 3.14) * S.LogoSize * 0.55)
Spark1.Visible, Spark2.Visible = true, true
else
LogoBody.Position = UDim2.fromOffset(0, 0)
Spark1.Visible, Spark2.Visible = false, false
end
end)
bind(RunService.Stepped, function(_, dt)
local ok, err = pcall(Speed.step, dt)
if not ok and Speed.lastErr ~= tostring(err) then
Speed.lastErr = tostring(err)
log("Speed error: " .. Speed.lastErr)
notify("Speed problem", Speed.lastErr, 5)
end
end)
task.spawn(function()
local count = 0
while JH.Running do
count = count + 1
local ok, holding, source = pcall(Ball.check)
if ok then
Ball.holding, Ball.source = holding, source
end
pcall(Feat.tick, count)
task.wait(0.1)
end
end)
task.spawn(function()
while JH.Running do
pcall(function()
local now = os.date("*t")
local hr = now.hour % 12
if hr == 0 then hr = 12 end
local timeStr = string.format("%d:%02d:%02d %s", hr, now.min, now.sec, now.hour >= 12 and "PM" or "AM")
local ping = 0
pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000) end)
local fps = math.floor(JH.FPS + 0.5)
InfoText.Text = string.format("JHub V1  |  %d FPS  |  %d ms  |  %s", fps, ping, timeStr)
.. (Speed.extra > 0 and string.format("  |  BOOST +%.0f", Speed.extra) or "")
if not Window.Visible then return end
if UI.current and UI.current.name == "Main" then
R.game.Text = placeName
R.time.Text = timeStr
R.rec.Text = Rec.summary()
end
end)
task.wait(0.25)
end
end)
function JH.Unload()
JH.Running = false
for _, c in ipairs(JH.Connections) do pcall(function() c:Disconnect() end) end
pcall(Shot.release, "manualKey", nil)
if Feat.sprinting then pcall(Input.action, "Sprint", false) end
local h = hum()
if h and Speed.lastSet then pcall(function() h.WalkSpeed = Speed.gameWS end) end
if UI.blur then pcall(function() UI.blur:Destroy() end) end
pcall(Speed.gvRestore)
pcall(Feat.V.cleanup)
pcall(Rec.stop)
save()
pcall(function() gui:Destroy() end)
if genv.JHubGlass == JH then genv.JHubGlass = nil end
end
JH.api = { S = S, UI = UI, Net = Net, Input = Input, Ball = Ball, Shot = Shot, Backup = Backup, Glide = Glide, Anim = Anim,
Speed = Speed, Feat = Feat, Picker = Picker, Bar = Bar, Mover = Mover, Rec = Rec }
UI.applyTheme()
UI.applyFx()
for _, f in ipairs(UI.refresh) do pcall(f) end
InfoBar.Visible = S.Watermark
BackupBtn.Visible = S.BackupButton
UI.select(UI.pages[1])
UI.show(true)
local pg = LP:WaitForChild("PlayerGui")
Shot.parseTimes()
Shot.hookRoot(pg)
Shot.hookRoot(workspace, true)
task.spawn(function()
local seen
while JH.Running do
local c = char()
if c and c ~= seen then
seen = c
Anim.hookChar(c)
end
task.wait(1)
end
end)
task.spawn(function()
while JH.Running do
pcall(Shot.watch)
task.wait(0.2)
end
end)
pcall(function()
local pinchStart = nil
bind(UIS.TouchPinch, function(positions, scale, velocity, state)
if not Window.Visible then return end
if state == Enum.UserInputState.Begin then
pinchStart = nil
local inside = #positions >= 2
for _, p in ipairs(positions) do
if not Input.hits(Window, p) then inside = false end
end
if inside then pinchStart = S.UIScale end
elseif state == Enum.UserInputState.Change and pinchStart then
local v = math.floor(clamp(pinchStart * scale, 0.6, 1.5) * 100 + 0.5) / 100
if v ~= S.UIScale then
UI.set("UIScale", v, false)
UI.fitScale()
UI.keepOnScreen()
end
else
pinchStart = nil
end
end)
end)
task.spawn(function()
local last = ""
while JH.Running do
local c = char()
local a = c and c:GetAttribute("Action")
if type(a) == "string" and a ~= last then
last = a
if a == "Gathering" and c:GetAttribute("GatherType") ~= "Pumpfake" then pcall(Glide.fire, "gather", "gather step") end
end
task.wait(0.03)
end
end)
task.spawn(function()
while JH.Running do
pcall(Feat.magnetStep)
pcall(Shot.statusStep)
pcall(Feat.V.step)
task.wait(0.05)
end
end)
pcall(Rec.hook)
pcall(Shot.connectRemotes)
if S.AutoExec then pcall(Net.queueTeleport) end
task.spawn(function()
Ball.rescan()
log(string.format("Scan: %d ball part(s) found", Ball.count()))
end)
bind(workspace.DescendantAdded, function(d) pcall(Ball.consider, d) end)
log("JHub Glass loaded on " .. execName)
notify("JHub V1", (IS_MOBILE and "Tap the moving JH logo to open or close the menu." or "Press " .. S.MenuKey .. " or click the JH logo to open or close the menu.") .. "  Welcome, " .. LP.DisplayName .. "!", 5)
playSound(SND_CLICK, 0.4)
end -- JHubMain
local ok, err = xpcall(JHubMain, function(e) return tostring(e) .. "\n" .. debug.traceback() end)
if not ok then
warn("[JHub] failed to load: " .. tostring(err))
pcall(function()
local sg = Instance.new("ScreenGui")
sg.Name = "JHubError"
sg.ResetOnSpawn = false
local okP = pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okP or not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
local box = Instance.new("TextButton")
box.Size = UDim2.fromOffset(440, 230)
box.Position = UDim2.new(0.5, -220, 0.5, -115)
box.BackgroundColor3 = Color3.fromRGB(10, 30, 70)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.Code
box.TextSize = 12
box.TextWrapped = true
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.Text = "JHub failed to load. Screenshot this and send it (tap to close):\n\n" .. tostring(err)
box.Parent = sg
box.Activated:Connect(function() sg:Destroy() end)
if setclipboard then pcall(setclipboard, tostring(err)) end
end)
end
]==]

local function JHubMain()

-- A re-run removes the previous copy of this menu and the older JHub menu first.
local genv = (getgenv and getgenv()) or shared or _G
local launchedByAuto = genv.JHUB_AUTOEXEC
genv.JHUB_AUTOEXEC = nil
if launchedByAuto then
	if not game:IsLoaded() then game.Loaded:Wait() end
	local okf, txt = pcall(function() return readfile("JHubGlass/settings.json") end)
	if okf and type(txt) == "string" and not string.find(txt, '"AutoExec":true', 1, true) then return end
end
for _, key in ipairs({ "JHubGlass", "JHubV1", "JayHubPB" }) do
	local old = genv[key]
	if type(old) == "table" and type(old.Unload) == "function" then
		pcall(old.Unload)
	end
	genv[key] = nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local LP = Players.LocalPlayer
while not LP do
	task.wait()
	LP = Players.LocalPlayer
end

local WHITE = Color3.new(1, 1, 1)
local MB1 = Enum.UserInputType.MouseButton1
local TOUCH = Enum.UserInputType.Touch
local MMOVE = Enum.UserInputType.MouseMovement
local KEYBOARD = Enum.UserInputType.Keyboard
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
local VERSION = "v1.27 shot-line"

local JH = { Connections = {}, Running = true, Logs = {}, Start = tick(), FPS = 60 }
genv.JHubGlass = JH

local function cam() return workspace.CurrentCamera end

local function bind(signal, fn)
	local c = signal:Connect(fn)
	table.insert(JH.Connections, c)
	return c
end
local function log(msg)
	msg = tostring(msg)
	table.insert(JH.Logs, 1, os.date("%H:%M:%S") .. "  " .. msg)
	if #JH.Logs > 60 then table.remove(JH.Logs) end
	if JH.RecLog then JH.RecLog(msg) end
	print("[JHub] " .. msg)
end
local function clamp(v, a, b)
	if v < a then return a elseif v > b then return b end
	return v
end
local function trim(s) return (string.gsub(s or "", "^%s*(.-)%s*$", "%1")) end
local function tokens(s)
	local out = {}
	for t in string.gmatch(s or "", "[^%s,]+") do table.insert(out, t) end
	return out
end
local function matchAny(s, words)
	for _, w in ipairs(words) do
		if string.find(s, w, 1, true) then return true end
	end
	return false
end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function new(class, props)
	local o = Instance.new(class)
	local parent
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then parent = v else o[k] = v end
		end
	end
	if parent then o.Parent = parent end
	return o
end
local function visibleChain(g)
	local o = g
	while o and o ~= game do
		if o:IsA("GuiObject") and not o.Visible then return false end
		if o:IsA("LayerCollector") then return o.Enabled end
		o = o.Parent
	end
	return true
end
local function char()
	local c = LP.Character
	if c then return c end
	local f = workspace:FindFirstChild("Characters")
	return f and f:FindFirstChild(LP.Name)
end
local function hrp() local c = char() return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end
local function hum() local c = char() return c and c:FindFirstChildOfClass("Humanoid") end
local function insetHeight()
	local ok, v = pcall(function() return (GuiService:GetGuiInset()) end)
	return (ok and v) and v.Y or 0
end

-- Modules are plain tables so they can call each other regardless of definition order.
local UI, Net, Input, Ball, Shot, Backup, Glide, Anim, Speed, Feat, Picker, Bar, Mover, Rec =
	{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
local function notify(title, msg, dur) if UI.notify then UI.notify(title, msg, dur) end end

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
local S = {
	-- look
	WinTrans = 0.5, CardTrans = 0.78, Hue = 212, Sat = 0.85, Val = 0.85, WinGradient = true,
	OutlineColor = "White", OutlineThick = 2, OutlineShine = true,
	TextColor = "White", TextStroke = true, Font = "Gotham", Corner = 10, UIScale = 1,
	LogoSize = 58, LogoOpacity = 1, LogoAnim = true, LogoX = -1, LogoY = -1,
	Blur = false, BlurSize = 10, Watermark = true, Notifications = true, Sounds = true, MenuKey = "RightShift",
	-- main
	Codes = "100M RELEASE 100KLIKES 500KMEMBERS SORRYFORBUGS", CodeRemotes = true,
	-- shooting
	AutoGreen = true, AutoCalibrate = true, AutoTiming = true, ShotRelease = "Auto",
	HoldTime = 0.55, MaxHold = 1.6, CalSpeed = 0.6, CalStep = 0.02,
	ShotTimes = "", ShotRatio = 0, BarPath = "", BarProp = "", BarAt = 0, BarNudge = 0,
	ShotStyle = "Hold", AutoExec = false, BallMagnet = false, MagnetMode = "Pull to me", MagnetRange = 60, Learn = false, DetNotify = false, PerfectGreen = false, PerfectGreenPct = 100, AutoCal = true, AutoTimes = "", Sweep = false, MagnetFrames = 1, LogoOn = false, Logo = "Owner", MascotOn = false, Mascot = "SpongeBob", MaxOverall = false, MaxCoins = false, MaxBadges = false, MeterAim = false, MeterTarget = 1.0, MeterBin = 0.05, Lightning = true, BoltCount = 6, BoltSpeed = 1, BoltThick = 2, BoltBright = 0.9, BoltColor = "White + Yellow", BgMove = true, BgGlow = 0.5, BgOrbs = true, AccentMode = "Gold", OutlineSpeed = 1, LogoStyle = "J bolt H", LogoBg = true, Preset = "Lightning Gold", PacketOn = true, PacketMul = 1,
	MovingOffset = 0, SprintOffset = 0, PingComp = 0, Humanize = 0, Nudge = 0, GreenSound = true,
	HookShootButton = true, ShootButtonPath = "", ReleaseMethod = "Both", FireClick = true,
	ManualAssist = true, ShootKey = "E", SprintKey = "LeftShift",
	BackupButton = false, BackupMethod = "touch", BackupInset = false,
	-- dribbling
	DribbleGlide = false, DribbleGlidePower = 30, DribbleGlideTime = 0.45, GlideSpeed = 1,
	ShotGlide = false, ShotGlidePower = 22, ShotGlideTime = 0.45,
	GatherGlide = false, GatherGlidePower = 26, GatherGlideTime = 0.45,
	GlideFade = 60, GlideSmart = true, GlideStopAtWalls = false, GlideNeedBall = true, GlideMethod = "Auto",
	DribbleKeys = "Z C X V", GatherKeys = "", DribbleBtnPaths = "", GatherBtnPaths = "",
	AnimDribble = "", AnimGather = "", AnimShot = "",
	-- players
	SpeedOn = false, SpeedAdd = 4, SpeedMult = 1, BallSpeedOn = false, BallAdd = 4, BallMult = 1,
	RunOn = false, RunAdd = 4, RunMult = 1, RecShots = false, RunDetect = "Auto", SettingsVer = 0, RecOn = false,
	SpeedChannel = "Auto", SpeedCap = 40, AntiRubber = false, ForceBall = false, HoldDist = 6, BallName = "auto",
	AutoSprint = false, InfStamina = false,
}
local DEFAULTS = {}
for k, v in pairs(S) do DEFAULTS[k] = v end

local FS = { root = "JHubGlass" }
FS.file = FS.root .. "/settings.json"
FS.ok = type(writefile) == "function" and type(readfile) == "function"
function FS.ensure()
	if type(makefolder) ~= "function" or type(isfolder) ~= "function" then return end
	pcall(function()
		if not isfolder(FS.root) then makefolder(FS.root) end
	end)
end
function FS.write(path, text)
	if not FS.ok or not text then return end
	FS.ensure()
	pcall(writefile, path, text)
end
function FS.read(path)
	if not FS.ok then return nil end
	local ok, r = pcall(function()
		if type(isfile) == "function" and not isfile(path) then return nil end
		return readfile(path)
	end)
	if ok then return r end
	return nil
end
local function decode(str)
	if not str or str == "" then return nil end
	local ok, r = pcall(function() return HttpService:JSONDecode(str) end)
	if ok then return r end
	return nil
end
local function applyData(data)
	if type(data) ~= "table" then return end
	for k, v in pairs(data) do
		if S[k] ~= nil and type(S[k]) == type(v) then S[k] = v end
	end
end
applyData(decode(FS.read(FS.file)))
-- older saved settings carried values that kept glides and boosts from working; those are reset once
if S.SettingsVer < 3 then
	for _, k in ipairs({ "DribbleGlidePower", "DribbleGlideTime", "ShotGlidePower", "ShotGlideTime", "GatherGlidePower",
		"GatherGlideTime", "SpeedChannel", "GlideMethod", "GlideStopAtWalls", "SpeedAdd", "BallAdd" }) do
		S[k] = DEFAULTS[k]
	end
end
if S.SettingsVer < 4 then
	for _, k in ipairs({ "ShootButtonPath", "BarPath", "BarProp", "BarAt", "ShotTimes", "ShotRatio", "PacketMul", "PacketOn", "HoldTime",
		"SpeedChannel", "GlideMethod" }) do
		S[k] = DEFAULTS[k]
	end
end
if S.SettingsVer < 5 then
	-- these two have no switch any more, so a value saved by an older menu could not be turned off
	S.InfStamina, S.AutoSprint = false, false
end
if S.SettingsVer < 6 then
	-- the speed sliders became levels, and "ball always on" was left over from an older menu
	S.SpeedAdd, S.RunAdd, S.BallAdd, S.ForceBall = 4, 4, 4, false
end
if S.SettingsVer < 7 then
	-- the glides became smoother and slower, with one overall speed
	S.DribbleGlidePower, S.DribbleGlideTime, S.ShotGlidePower, S.ShotGlideTime = 10, 0.35, 6, 0.4
	S.GatherGlidePower, S.GatherGlideTime, S.GlideSpeed, S.GlideNeedBall = 10, 0.4, 1, true
end
if S.SettingsVer < 8 then
	S.DribbleGlidePower, S.ShotGlidePower, S.GatherGlidePower, S.GlideSpeed, S.AntiRubber = 18, 12, 16, 1, false
end
if S.SettingsVer < 9 then
	S.DribbleGlidePower, S.DribbleGlideTime, S.ShotGlidePower, S.ShotGlideTime = 30, 0.45, 22, 0.45
	S.GatherGlidePower, S.GatherGlideTime = 26, 0.45
end
if S.SettingsVer < 10 then
	S.MeterTarget, S.MeterBin, S.MeterAim = 1.0, 0.05, false
end
if S.SettingsVer < 13 then
	S.MeterAim = false
	local old = {}
	for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do if key ~= "15851912457+15851919155" and key ~= "15851912457+15851919155+17285155256" then old[#old + 1] = key .. "=" .. val end end
	S.ShotTimes = table.concat(old, " ")
	local seeds = "r:15851912457+15851919155=1.327 r:15851912457+15851919155+17285155256=1.327 16205020756=0.343 16246923753=0.335 118403922040694=0.315 15997667717=0.365 16143612725=0.355 16143619816=0.355 84063020888988=0.335 138932071140330=0.322 111074210919383=0.414 71484695722621=0.414"
	local have = {}
	for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do have[key] = val end
	for key, val in string.gmatch(seeds, "(%S+)=([%d%.]+)") do have[key] = val end
	local parts = {}
	for key, val in pairs(have) do parts[#parts + 1] = key .. "=" .. val end
	table.sort(parts)
	S.ShotTimes = table.concat(parts, " ")
end
if S.AutoCal == nil then S.AutoCal = true end
if S.PerfectGreen == nil then S.PerfectGreen = false end
if S.DetNotify == nil then S.DetNotify = false end
if S.PerfectGreenPct == nil then S.PerfectGreenPct = 100 end
if S.AutoTimes == nil then S.AutoTimes = "" end
if S.SettingsVer < 14 then
	if S.MagnetMode == "Pull the ball" then S.MagnetMode = "Pull to me" end
end
if S.SettingsVer < 15 then
	S.Learn = false
end
if S.SettingsVer < 28 then
	S.Hue, S.Sat, S.Val, S.WinTrans, S.CardTrans, S.OutlineColor, S.OutlineThick, S.AccentMode = 226, 0.8, 0.14, 0.08, 0.55, "Gold", 2.5, "Gold"
	local seeds = "la:15851912457+15851919155=0.357 lb:15851912457+15851919155=0.000 la:15851912457+15851919155+17285155256=0.357 lb:15851912457+15851919155+17285155256=0.000 16246923753=0.328 16205020756=0.328 16104888271=0.328 16104888271+17285155256=0.328 16205020756+17285155256=0.328 118403922040694=0.290 15997667717=0.347 16143619816=0.350 16143612725=0.350 84063020888988=0.322 138932071140330=0.316 111074210919383=0.357 71484695722621=0.311 77401448272074=0.329 128777513307709+77401448272074=0.329"
	local have = {}
	for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do
		if string.sub(key, 1, 2) ~= "r:" then have[key] = val end
	end
	for key, val in string.gmatch(seeds, "(%S+)=([%d%.]+)") do have[key] = val end
	local parts = {}
	for key, val in pairs(have) do parts[#parts + 1] = key .. "=" .. val end
	table.sort(parts)
	S.ShotTimes = table.concat(parts, " ")
end
S.SettingsVer = 28
DEFAULTS.SettingsVer = 28
DEFAULTS.ShotTimes = "la:15851912457+15851919155=0.357 lb:15851912457+15851919155=0.000 la:15851912457+15851919155+17285155256=0.357 lb:15851912457+15851919155+17285155256=0.000 16246923753=0.328 16205020756=0.328 16104888271=0.328 16104888271+17285155256=0.328 16205020756+17285155256=0.328 118403922040694=0.290 15997667717=0.347 16143619816=0.350 16143612725=0.350 84063020888988=0.322 138932071140330=0.316 111074210919383=0.357 71484695722621=0.311 77401448272074=0.329 128777513307709+77401448272074=0.329"
S.ShotTimes = S.ShotTimes
S.RecOn = false
S.RecShots = false
local function save()
	local ok, text = pcall(function() return HttpService:JSONEncode(S) end)
	if ok then FS.write(FS.file, text) end
end
local saveQueued = false
local function saveSoon()
	if saveQueued then return end
	saveQueued = true
	task.delay(1.5, function()
		saveQueued = false
		save()
	end)
end

---------------------------------------------------------------------
-- THEME (clear blue glass, white outline, white text)
---------------------------------------------------------------------
local TEXT_COLORS = {
	White = Color3.new(1, 1, 1), Ice = Color3.fromRGB(215, 240, 255),
	Gold = Color3.fromRGB(255, 236, 170), Mint = Color3.fromRGB(205, 255, 232),
}
local OUTLINE_COLORS = {
	White = Color3.new(1, 1, 1), Cyan = Color3.fromRGB(120, 235, 255), Pink = Color3.fromRGB(255, 150, 220),
	Gold = Color3.fromRGB(255, 225, 120), Lime = Color3.fromRGB(170, 255, 140),
}
local OUTLINE_NAMES = { "White", "Cyan", "Pink", "Gold", "Lime", "Rainbow" }
local TEXT_NAMES = { "White", "Ice", "Gold", "Mint" }
local FONTS = {
	Gotham = { "Gotham", "GothamBold" }, Montserrat = { "Montserrat", "MontserratBold" },
	SourceSans = { "SourceSans", "SourceSansBold" }, Ubuntu = { "Ubuntu", "Ubuntu" },
	Oswald = { "Oswald", "Oswald" }, Code = { "Code", "Code" }, FredokaOne = { "FredokaOne", "FredokaOne" },
}
local FONT_NAMES = { "Gotham", "Montserrat", "SourceSans", "Ubuntu", "Oswald", "Code", "FredokaOne" }
local Theme = {}
local function computeTheme()
	local h = (S.Hue % 360) / 360
	Theme.Glass = Color3.fromHSV(h, S.Sat, S.Val)
	Theme.Sheen = Color3.fromHSV(h, math.max(S.Sat - 0.55, 0), 1)
	Theme.Card = Color3.fromHSV(h, math.max(S.Sat - 0.1, 0), math.min(S.Val + 0.1, 1))
	Theme.Elem = Color3.fromHSV(h, S.Sat, math.max(S.Val - 0.3, 0.08))
	Theme.Stroke = Color3.fromHSV(h, 0.9, 0.18)
	Theme.Text = TEXT_COLORS[S.TextColor] or WHITE
	Theme.Sub = Theme.Text:Lerp(Theme.Glass, 0.28)
	Theme.Outline = OUTLINE_COLORS[S.OutlineColor] or WHITE
	Theme.AccentA = Color3.fromHSV(h, 0.2, 1)
	Theme.AccentB = Color3.fromHSV(((S.Hue - 28) % 360) / 360, 0.75, 1)
	if S.AccentMode ~= "Match hue" then
		Theme.AccentA = Color3.fromRGB(255, 246, 180)
		Theme.AccentB = Color3.fromRGB(255, 192, 28)
	end
end
computeTheme()

---------------------------------------------------------------------
-- ROOT GUI
---------------------------------------------------------------------
local gui = new("ScreenGui", { Name = "JHubGlass", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 })
local parentedOk = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not parentedOk or not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local function playSound(id, vol)
	if not S.Sounds then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = vol or 0.5
		s.Parent = game:GetService("SoundService")
		s:Play()
		task.delay(3, function() s:Destroy() end)
	end)
end
local SND_CLICK = "rbxasset://sounds/electronicpingshort.wav"

---------------------------------------------------------------------
-- NETWORK: servers, rejoin, codes
---------------------------------------------------------------------
function Net.get(url)
	local fn = request or http_request or (syn and syn.request) or (http and http.request)
	if type(fn) == "function" then
		local ok, res = pcall(fn, { Url = url, Method = "GET" })
		if ok and type(res) == "table" and res.Body then return res.Body end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok then return body end
	return nil
end
function Net.servers(pages)
	local all, cursor = {}, nil
	for _ = 1, pages do
		local url = string.format("https://games.roblox.com/v1/games/%.0f/servers/Public?sortOrder=Asc&limit=100%s",
			game.PlaceId, cursor and ("&cursor=" .. cursor) or "")
		local data = decode(Net.get(url))
		if not data or type(data.data) ~= "table" then break end
		for _, s in ipairs(data.data) do table.insert(all, s) end
		cursor = data.nextPageCursor
		if type(cursor) ~= "string" then break end
	end
	return all
end
function Net.rejoin()
	notify("Rejoin", "Rejoining this server...", 2)
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(game.PlaceId, LP)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
	end
end
-- mode "new" = random other server, "lower" = the emptiest other server
function Net.hop(mode)
	notify("Servers", "Looking for a server...", 2)
	local list = Net.servers(3)
	if #list == 0 then
		notify("Servers", "Couldn't load the server list. Your executor may be blocking web requests.", 4)
		return
	end
	local open = {}
	for _, s in ipairs(list) do
		if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 0) then table.insert(open, s) end
	end
	if #open == 0 then
		notify("Servers", "No other server found. Try again in a moment.", 3)
		return
	end
	local pick
	if mode == "lower" then
		table.sort(open, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
		-- an empty listing is usually a dead instance, so prefer the smallest one that has someone in it
		for _, s in ipairs(open) do
			if (s.playing or 0) >= 1 then pick = s break end
		end
		pick = pick or open[1]
		if (pick.playing or 0) >= #Players:GetPlayers() then
			notify("Servers", "No emptier server than this one right now.", 3)
			return
		end
	else
		local busy = {}
		for _, s in ipairs(open) do
			if (s.playing or 0) >= 2 then table.insert(busy, s) end
		end
		local pool = #busy > 0 and busy or open
		pick = pool[math.random(1, #pool)]
	end
	notify("Servers", string.format("Joining a server with %d players...", math.floor(pick.playing or 0)), 3)
	TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LP)
end

function Net.redeemViaGui(list)
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return false end
	local box
	for _, d in ipairs(pg:GetDescendants()) do
		if d:IsA("TextBox") then
			local n = string.lower(d.Name .. " " .. d.PlaceholderText .. " " .. (d.Parent and d.Parent.Name or ""))
			if string.find(n, "code", 1, true) then box = d break end
		end
	end
	if not box then return false end
	local btn
	local scope = box.Parent and box.Parent.Parent or box.Parent
	for _, d in ipairs(scope:GetDescendants()) do
		if d:IsA("GuiButton") then
			local n = string.lower(d.Name .. " " .. (d:IsA("TextButton") and d.Text or ""))
			if matchAny(n, { "redeem", "submit", "enter", "claim", "confirm" }) then btn = d break end
		end
	end
	for _, code in ipairs(list) do
		box.Text = code
		if getconnections then
			local ok, conns = pcall(getconnections, box.FocusLost)
			if ok and conns then
				for _, c in ipairs(conns) do
					pcall(function()
						if c.Function then c.Function(true) else c:Fire(true) end
					end)
				end
			end
		end
		if btn then
			Input.fireGui(btn, true, true)
			Input.fireGui(btn, false, true)
		end
		log("Code (menu): " .. code)
		task.wait(1.3)
	end
	return true
end
function Net.redeemViaRemotes(list)
	local remotes = {}
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and matchAny(string.lower(d.Name), { "code", "redeem", "promo" }) then
			table.insert(remotes, d)
		end
	end
	if #remotes == 0 then return false end
	for _, code in ipairs(list) do
		for _, rm in ipairs(remotes) do
			if rm:IsA("RemoteFunction") then
				task.spawn(function()
					local ok, res = pcall(function() return rm:InvokeServer(code) end)
					log("Code " .. code .. " via " .. rm.Name .. ": " .. tostring(ok and res or "error"))
				end)
			else
				pcall(function() rm:FireServer(code) end)
				log("Code " .. code .. " sent via " .. rm.Name)
			end
		end
		task.wait(1.2)
	end
	return true
end
function Net.redeemAll()
	local list = tokens(S.Codes)
	if #list == 0 then
		notify("Codes", "The code list is empty.", 2)
		return
	end
	notify("Codes", "Redeeming " .. #list .. " codes...", 2)
	local done = Net.redeemViaGui(list)
	if not done and S.CodeRemotes then done = Net.redeemViaRemotes(list) end
	if done then
		notify("Codes", "Finished. Check your coins and rewards.", 3)
	else
		notify("Codes", "Open the game's Codes menu once, then press Redeem all codes again.", 4)
	end
end

---------------------------------------------------------------------
-- INPUT: keys, the game's touch buttons, chords
---------------------------------------------------------------------
Input.held = {}
Input.cache = {}
function Input.keyCode(name)
	if type(name) ~= "string" or name == "" then return nil end
	local ok, k = pcall(function() return Enum.KeyCode[name] end)
	if ok and k then return k end
	ok, k = pcall(function() return Enum.KeyCode[string.upper(name)] end)
	if ok and k then return k end
	return nil
end
function Input.sendKey(name, down)
	if not VIM or not name or name == "" then return false end
	local k = Input.keyCode(name)
	if not k then return false end
	return (pcall(function() VIM:SendKeyEvent(down, k, false, game) end))
end
function Input.pathOf(g)
	local pg = LP:FindFirstChild("PlayerGui")
	local parts = {}
	local o = g
	while o and o ~= pg and o ~= game do
		table.insert(parts, 1, o.Name)
		o = o.Parent
	end
	return table.concat(parts, "/")
end
function Input.resolve(path)
	local o = LP:FindFirstChild("PlayerGui")
	if not o or path == "" then return nil end
	for name in string.gmatch(path, "[^/]+") do
		o = o:FindFirstChild(name)
		if not o then return nil end
	end
	return o
end
local ACTION_WORDS = { Shoot = { "shoot", "shot" }, Sprint = { "sprint", "run" } }
-- scanning every PlayerGui descendant is expensive, so results are cached briefly
function Input.findButton(action)
	if action == "Shoot" and S.ShootButtonPath ~= "" then
		local b = Input.resolve(S.ShootButtonPath)
		if b then return b end
	end
	local cached = Input.cache[action]
	if cached and tick() - cached.t < 1.5 and (not cached.obj or cached.obj.Parent) then return cached.obj end
	local pg = LP:FindFirstChild("PlayerGui")
	local words = ACTION_WORDS[action]
	local found
	if pg and words then
		for _, d in ipairs(pg:GetDescendants()) do
			if d:IsA("GuiButton") and not d:IsDescendantOf(gui) and visibleChain(d) then
				local n = string.lower(d.Name .. " " .. (d:IsA("TextButton") and d.Text or ""))
				if matchAny(n, words) then found = d break end
			end
		end
	end
	Input.cache[action] = { obj = found, t = tick() }
	return found
end
-- clicks = also fire MouseButton1Click / Activated (wanted for taps, optional at the end of a hold)
function Input.fireGui(g, down, clicks)
	local center = g.AbsolutePosition + g.AbsoluteSize / 2
	local fake = { UserInputType = TOUCH, KeyCode = Enum.KeyCode.Unknown,
		UserInputState = down and Enum.UserInputState.Begin or Enum.UserInputState.End,
		Position = Vector3.new(center.X, center.Y, 0), Delta = Vector3.new() }
	local fired = false
	local sigs = {}
	if down then
		table.insert(sigs, { g.InputBegan, fake })
		if g:IsA("GuiButton") then table.insert(sigs, { g.MouseButton1Down, center.X, center.Y }) end
	else
		table.insert(sigs, { g.InputEnded, fake })
		if g:IsA("GuiButton") then
			table.insert(sigs, { g.MouseButton1Up, center.X, center.Y })
			if clicks then
				table.insert(sigs, { g.MouseButton1Click })
				table.insert(sigs, { g.Activated, fake, 1 })
			end
		end
	end
	if getconnections then
		for _, s in ipairs(sigs) do
			local ok, conns = pcall(getconnections, s[1])
			if ok and conns then
				for _, c in ipairs(conns) do
					local ok2 = pcall(function()
						if c.Function then c.Function(s[2], s[3]) else c:Fire(s[2], s[3]) end
					end)
					fired = fired or ok2
				end
			end
		end
	end
	if not fired and firesignal then
		for _, s in ipairs(sigs) do pcall(firesignal, s[1], s[2], s[3]) end
		fired = true
	end
	return fired
end
-- press / release a game action with keys and/or the game's on-screen button
function Input.action(action, down)
	local key = S[action .. "Key"]
	local any = false
	if key then any = Input.sendKey(key, down) or any end
	if UIS.TouchEnabled then
		local btn = down and Input.findButton(action) or Input.held[action]
		if btn then
			any = Input.fireGui(btn, down, action ~= "Shoot" or S.FireClick) or any
			Input.held[action] = down and btn or nil
		end
	end
	return any
end
function Input.hits(g, pos)
	local ap, as = g.AbsolutePosition, g.AbsoluteSize
	local inset = insetHeight()
	local pad = 4
	for _, y in ipairs({ pos.Y, pos.Y + inset, pos.Y - inset }) do
		if pos.X >= ap.X - pad and pos.X <= ap.X + as.X + pad and y >= ap.Y - pad and y <= ap.Y + as.Y + pad then
			return true
		end
	end
	return false
end
-- the button a finger landed on
function Input.topButtonAt(pos)
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return nil end
	local inset = insetHeight()
	for _, y in ipairs({ pos.Y, pos.Y - inset }) do
		local ok, list = pcall(function() return pg:GetGuiObjectsAtPosition(pos.X, y) end)
		if ok and list then
			for _, g in ipairs(list) do
				if g:IsA("GuiButton") and not g:IsDescendantOf(gui) then return g end
			end
		end
	end
	return nil
end
-- the visible label of a button (its own text, or the first text label inside it), upper-cased
function Input.btnText(b)
	local t = ""
	if b:IsA("TextButton") then t = b.Text end
	if t == "" then
		local l = b:FindFirstChildWhichIsA("TextLabel", true)
		if l then t = l.Text end
	end
	return string.upper(trim(t))
end
Input.gcache = {}
-- on-screen move buttons: anything labelled with one of your dribble (or gather) keys
function Input.glideButtons(kind)
	local c = Input.gcache[kind]
	if c and tick() - c.t < 2 then return c.list end
	local list = {}
	local seen = {}
	local function add(o)
		if not seen[o] then
			seen[o] = true
			table.insert(list, o)
		end
	end
	local keys = {}
	for _, k in ipairs(tokens(kind == "dribble" and S.DribbleKeys or S.GatherKeys)) do keys[string.upper(k)] = true end
	local pg = LP:FindFirstChild("PlayerGui")
	if pg and next(keys) then
		for _, d in ipairs(pg:GetDescendants()) do
			if not d:IsDescendantOf(gui) then
				if d:IsA("GuiButton") then
					if keys[Input.btnText(d)] then add(d) end
				elseif d:IsA("TextLabel") and keys[string.upper(trim(d.Text))] and visibleChain(d) then
					-- many games draw touch buttons as plain frames with a label on top: use the button-sized frame around the label
					local region = d
					local p = d.Parent
					if p and p:IsA("GuiObject") and p.AbsoluteSize.X <= 220 and p.AbsoluteSize.Y <= 220
						and p.AbsoluteSize.X >= d.AbsoluteSize.X and p.AbsoluteSize.Y >= d.AbsoluteSize.Y then
						region = p
					end
					add(region)
				end
			end
		end
	end
	Input.gcache[kind] = { t = tick(), list = list }
	return list
end

---------------------------------------------------------------------
-- BALL (is it in your hands?)
---------------------------------------------------------------------
Ball.parts = {}
Ball.holding = false
Ball.source = "starting"
Ball.nearest = nil
function Ball.score(o, n)
	if S.BallName ~= "" and string.lower(S.BallName) ~= "auto" then
		return (n == string.lower(S.BallName)) and 4 or 0
	end
	if n == "ball" or n == "basketball" then return 3 end
	if string.find(n, "basketball", 1, true) then return 2 end
	if string.find(n, "ball", 1, true) and not matchAny(n, { "rack", "zone", "region", "spawn", "hoop", "rim", "net", "stand" }) then
		return 1
	end
	if o:IsA("Part") and o.Shape == Enum.PartType.Ball then
		local m = math.max(o.Size.X, o.Size.Y, o.Size.Z)
		if m >= 0.8 and m <= 3.2 then return 1 end
	end
	return 0
end
function Ball.partOf(o)
	if o:IsA("BasePart") then return o end
	if o:IsA("Tool") then return o:FindFirstChild("Handle") end
	if o:IsA("Model") then return o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart") end
	return nil
end
function Ball.consider(o)
	if not (o:IsA("BasePart") or o:IsA("Tool") or o:IsA("Model")) then return end
	local n = string.lower(o.Name)
	if Ball.score(o, n) > 0 then
		local p = Ball.partOf(o)
		if p then Ball.parts[p] = true end
	end
end
function Ball.rescan()
	Ball.parts = {}
	for _, d in ipairs(workspace:GetDescendants()) do pcall(Ball.consider, d) end
end
function Ball.count()
	local n = 0
	for _ in pairs(Ball.parts) do n = n + 1 end
	return n
end
-- returns holding, source. Several independent signals are checked because every game tracks the ball differently.
function Ball.check()
	if S.ForceBall then return true, "forced on" end
	local c, r = char(), hrp()
	if not c or not r then return false, "no character" end
	local af = c:FindFirstChild("Attributes")
	if af then
		local bv = af:FindFirstChild("Basketball")
		if bv and bv.Value ~= nil then return true, "game ball value" end
		return false, "no ball value"
	end
	for _, holder in ipairs({ c, LP }) do
		for k, v in pairs(holder:GetAttributes()) do
			local n = string.lower(k)
			if matchAny(n, { "ball", "possess", "dribbl" })
				and (v == true or (type(v) == "string" and v ~= "") or (type(v) == "number" and v > 0)) then
				return true, "attribute " .. k
			end
		end
	end
	for _, ch in ipairs(c:GetChildren()) do
		if ch:IsA("Tool") and string.find(string.lower(ch.Name), "ball", 1, true) then
			return true, "tool " .. ch.Name
		end
	end
	local best, bd
	for p in pairs(Ball.parts) do
		if p.Parent and p:IsDescendantOf(workspace) then
			if p:IsDescendantOf(c) then return true, "ball in character" end
			local d = (p.Position - r.Position).Magnitude
			if not bd or d < bd then best, bd = p, d end
		end
	end
	Ball.nearest = best
	if best and bd <= S.HoldDist then
		-- a ball closer to someone else belongs to them
		local mine = true
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= LP and pl.Character then
				local pr = pl.Character:FindFirstChild("HumanoidRootPart")
				if pr and (pr.Position - best.Position).Magnitude < bd then mine = false break end
			end
		end
		if mine then return true, string.format("ball %.1f studs away", bd) end
	end
	if Anim.dribbling() then return true, "dribble animation" end
	if tick() - (Anim.lastDribble or 0) < 1.5 then return true, "dribble move" end
	if best then return false, string.format("ball %d studs away", math.floor(bd)) end
	return false, "no ball found"
end

---------------------------------------------------------------------
-- MOVEMENT HELPERS: where you are heading, and a measured speed
---------------------------------------------------------------------
Mover.vel = Vector3.new(0, 0, 0)
Mover.gameDir, Mover.gameDirT = nil, nil
-- this game moves a proxy part (workspace.ProxyCharacter) and the visible character only follows it
function Mover.body()
	local p = workspace:FindFirstChild("ProxyCharacter")
	if p and p:IsA("BasePart") then return p end
	return hrp()
end
Mover.remote = nil
-- the game's stick signal (read through the namecall hook): where the server thinks you are heading
function Mover.gameIntent()
	local d, t = Mover.gameDir, Mover.gameDirT
	if not d then return nil end
	local flatd = Vector3.new(d.X, 0, d.Z)
	if flatd.Magnitude < 0.05 then return Vector3.new(0, 0, 0) end
	if tick() - t > 0.8 then return Vector3.new(0, 0, 0) end
	return flatd.Magnitude > 1 and flatd.Unit or flatd
end
function Mover.findRemote()
	local r = Mover.remote
	if r and r.Parent then return r end
	Mover.remote = nil
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if d:IsA("RemoteEvent") and d.Name == "MoveDirection" then
			Mover.remote = d
			break
		end
	end
	return Mover.remote
end
-- sends a stick signal of our own (used by glides when the stick is idle)
function Mover.send(vec)
	local r = Mover.findRemote()
	if not r then return false end
	Mover.selfFire = true
	local ok = pcall(function() r:FireServer(vec) end)
	Mover.selfFire = false
	return ok
end
-- how much bigger the stick signal is made right now (speed boost and glides)
function Mover.outScale()
	local s = Speed.inputScale or 1
	local gi = Glide.input
	if gi and not gi.paused and tick() < gi.untilT and gi.scale > s then s = gi.scale end
	return s
end
-- dribble moves that end in a step back count as a gather step, everything else is a dribble move
Mover.GATHER_MOVES = { "stepback", "step back", "euro", "hop", "gather" }
-- BALL MAGNET: a loose ball is brought to you, or you are taken to it
Feat.magnetT = 0
function Feat.findBall()
	local r = Mover.body()
	local best, bd
	local f = workspace:FindFirstChild("Basketballs")
	if f and r then
		for _, d in ipairs(f:GetDescendants()) do
			if d:IsA("BasePart") then
				local dist = (d.Position - r.Position).Magnitude
				if not bd or dist < bd then best, bd = d, dist end
			end
		end
	end
	if not best and Ball.nearest and Ball.nearest.Parent and r then best, bd = Ball.nearest, (Ball.nearest.Position - r.Position).Magnitude end
	return best, bd
end
-- someone has it when a character carries the game's Basketball value
function Feat.ballLoose()
	local f = workspace:FindFirstChild("Characters")
	if not f then return true end
	for _, c in ipairs(f:GetChildren()) do
		local af = c:FindFirstChild("Attributes")
		local bv = af and af:FindFirstChild("Basketball")
		if bv and bv.Value ~= nil then return false end
	end
	return true
end
function Feat.getBall(force)
	local r = Mover.body()
	local b, dist = Feat.findBall()
	if not r or not b then return false end
	local flatd = Vector3.new(r.Position.X - b.Position.X, 0, r.Position.Z - b.Position.Z)
	if S.MagnetMode ~= "Go to the ball" then
		if not Feat.hop(b) then return false end
	else
		if flatd.Magnitude < 0.1 then flatd = Vector3.new(0, 0, 1) end
		local target = Vector3.new(b.Position.X, r.Position.Y, b.Position.Z) + flatd.Unit * 2.5
		r.CFrame = r.CFrame + (target - r.Position)
		Mover.sync(r)
	end
	log(string.format("Ball magnet: %s (%.0f studs away)", S.MagnetMode, dist or 0))
	return true
end
function Feat.magnetStep()
	if not S.BallMagnet then return end
	local now = tick()
	if now - Feat.magnetT < 0.4 or Ball.holding then return end
	if now - Shot.releasedT < 1.2 then return end
	local c = char()
	if c and c:GetAttribute("Action") == "Shooting" then return end
	local r = Mover.body()
	local b, dist = Feat.findBall()
	if not r or not b or not dist or dist < 4 or dist > S.MagnetRange then return end
	if not Feat.ballLoose() then return end
	Feat.magnetT = now
	Feat.getBall()
end

-- the game keeps your movement in its player module (Controllers/Player): CFVelocity is where it is moving you right now
function Mover.playerModule()
	if Mover.pm == nil then
		Mover.pm = false
		pcall(function()
			local ps = LP:FindFirstChild("PlayerScripts")
			local aero = ps and ps:FindFirstChild("Aero")
			local ctl = aero and aero:FindFirstChild("Controllers")
			local m = ctl and ctl:FindFirstChild("Player")
			if m then Mover.pm = require(m) end
		end)
	end
	return Mover.pm or nil
end
function Mover.gameVel()
	local pm = Mover.playerModule()
	if not pm then return nil end
	local ok, v = pcall(function() return pm.Character.Movement.CFVelocity end)
	if ok and typeof(v) == "Vector3" then return Vector3.new(v.X, 0, v.Z) end
	return nil
end
-- tells the game's player module where the pushed part is now, so it does not pull you back to where it last put you
function Mover.sync(r)
	local pm = Mover.playerModule()
	if not pm then return end
	pcall(function()
		local ch = pm.Character
		if ch and ch.LastCFrame ~= nil then ch.LastCFrame = r.CFrame end
	end)
end
-- where a move is taking you: the game's own velocity first, then the velocity it reports to the server
function Mover.moveWhere(minMag)
	local v = Mover.gameVel()
	if v and v.Magnitude > (minMag or 1.5) then return v end
	return Mover.moveDir()
end
function Mover.onDribble(args)
	Anim.lastDribble = tick()
	local key = tostring(args[1])
	local c0 = char()
	local sv0 = c0 and c0:GetAttribute("ServerVelocity")
	local pk0 = c0 and c0:GetAttribute("LastDribblePackage")
	local v0 = Mover.gameVel() or Vector3.new(0, 0, 0)
	local t0 = tick()
	task.spawn(function()
		-- the move shows up as a change in the game's velocity (at once) or in what it reports to the server (a little later)
		while JH.Running and tick() - t0 < 0.4 do
			RunService.Heartbeat:Wait()
			local cc = char()
			local gv = Mover.gameVel()
			if gv and (gv - v0).Magnitude > 2.5 then break end
			if cc and (cc:GetAttribute("ServerVelocity") ~= sv0 or cc:GetAttribute("LastDribblePackage") ~= pk0) then break end
		end
		if not JH.Running then return end
		local c = char()
		local pkg = c and c:GetAttribute("LastDribblePackage")
		local name = type(pkg) == "string" and string.lower(pkg) or ""
		local dir = Mover.moveWhere(1.5)
		if not dir and typeof(args[3]) == "Vector3" and Vector3.new(args[3].X, 0, args[3].Z).Magnitude > 0.1 then
			dir = Vector3.new(args[3].X, 0, args[3].Z)
		end
		if matchAny(name, Mover.GATHER_MOVES) then
			-- a step back goes backwards even when the game did not say where
			if not dir and (string.find(name, "step back", 1, true) or string.find(name, "stepback", 1, true)) then
				local body = Mover.body()
				if body then dir = -Vector3.new(body.CFrame.LookVector.X, 0, body.CFrame.LookVector.Z) end
			end
			Glide.fire("gather", "step back move " .. name, dir)
		else
			Glide.fire("dribble", "dribble move " .. (name ~= "" and name or key), dir)
		end
	end)
end
-- the way the game is moving you right now (flat), if it says
function Mover.moveDir()
	local c = char()
	local sv = c and c:GetAttribute("ServerVelocity")
	if typeof(sv) == "Vector3" then
		local f = Vector3.new(sv.X, 0, sv.Z)
		if f.Magnitude > 1.5 then return f end
	end
	return nil
end
-- the shot glide starts when the game starts a shot (its meter appears), whoever takes the shot
function Mover.watchShot(pressT)
	task.spawn(function()
		local t0 = tick()
		while tick() - t0 < 0.5 and Shot.meterT < pressT - 0.05 do RunService.Heartbeat:Wait() end
		if Shot.meterT < pressT - 0.05 then return end
		-- the shot moves you its own way (a fade goes back, a step back goes back): the glide goes that way
		local c0 = char()
		local sv0 = c0 and c0:GetAttribute("ServerVelocity")
		local v0 = Mover.gameVel() or Vector3.new(0, 0, 0)
		local t1 = tick()
		while JH.Running and tick() - t1 < 0.3 do
			RunService.Heartbeat:Wait()
			local gv = Mover.gameVel()
			local cc = char()
			if gv and (gv - v0).Magnitude > 2 then break end
			if cc and cc:GetAttribute("ServerVelocity") ~= sv0 then break end
		end
		local dir = Mover.moveWhere(1.5)
		Glide.fire("shot", "shot", dir)
	end)
end
function Mover.controls()
	if Mover.ctl == nil then
		Mover.ctl = false
		pcall(function()
			local ps = LP:FindFirstChild("PlayerScripts")
			local pm = ps and ps:FindFirstChild("PlayerModule")
			if pm then Mover.ctl = require(pm):GetControls() end
		end)
	end
	return Mover.ctl or nil
end
-- Reads the stick and keys the way Roblox's own controls do, so it still works when a game drives the character itself.
function Mover.intent(h, r)
	local gi = Mover.gameIntent()
	if gi then return gi, "game" end
	local md = flat(h.MoveDirection)
	if md.Magnitude > 0.05 then return md, "humanoid" end
	local ctl = Mover.controls()
	if ctl then
		local ok, mv = pcall(function() return ctl:GetMoveVector() end)
		if ok and mv and (math.abs(mv.X) > 0.05 or math.abs(mv.Z) > 0.05) then
			local world = flat(cam().CFrame:VectorToWorldSpace(Vector3.new(mv.X, 0, mv.Z)))
			local len = math.min(1, math.sqrt(mv.X * mv.X + mv.Z * mv.Z))
			if world.Magnitude > 0.01 then return world.Unit * len, "controls" end
		end
		return Vector3.new(0, 0, 0), "none"
	end
	local hv = flat(r.AssemblyLinearVelocity)
	if hv.Magnitude > 4 then return hv.Unit, "velocity" end
	return Vector3.new(0, 0, 0), "none"
end

---------------------------------------------------------------------
-- ANIMATIONS: events plus polling (server-played animations do not always fire events)
---------------------------------------------------------------------
local SHOT_WORDS = { "shoot", "shot", "jumper", "fade", "three", "release", "layup", "dunk", "alley", "stepback", "step back", "floater" }
local DRIBBLE_WORDS = { "dribble", "cross", "hesi", "behind", "between", "spin", "stepback", "step back", "shammgod", "snatch", "escape", "jab" }
local GATHER_WORDS = { "gather", "layup", "euro", "dunk", "floater", "hop", "finish" }
local ANIM_FLAGS = { dribble = "AnimDribble", gather = "AnimGather", shot = "AnimShot" }
Anim.learnKind = nil
Anim.learnUntil = 0
Anim.learned = 0
Anim.loops = {}
Anim.seen = {}
Anim.animator = nil
function Anim.name(track)
	local a = track.Animation
	return string.lower((track.Name or "") .. " " .. (a and a.Name or "") .. " " .. (a and a.AnimationId or ""))
end
function Anim.idOf(track)
	local a = track.Animation
	return a and string.lower(tostring(a.AnimationId or "")) or ""
end
function Anim.has(flag, id)
	return id ~= "" and string.find(" " .. string.lower(S[flag] or "") .. " ", " " .. id .. " ", 1, true) ~= nil
end
function Anim.isAction(track)
	local p = track.Priority.Value
	return p >= Enum.AnimationPriority.Action.Value and p < Enum.AnimationPriority.Core.Value
end
function Anim.dribbling()
	for track in pairs(Anim.loops) do
		if track.IsPlaying then return true end
	end
	return false
end
-- taught animations win, then name keywords, then any one-shot action animation while you have the ball
function Anim.classify(track)
	if track.Looped then return nil end
	local id = Anim.idOf(track)
	for kind, flag in pairs(ANIM_FLAGS) do
		if Anim.has(flag, id) then return kind, "taught" end
	end
	local n = Anim.name(track)
	if matchAny(n, GATHER_WORDS) and not matchAny(n, { "shoot", "shot", "jumper" }) then return "gather", "keyword" end
	if matchAny(n, SHOT_WORDS) then return "shot", "keyword" end
	if matchAny(n, DRIBBLE_WORDS) then return "dribble", "keyword" end
	if S.GlideSmart and Anim.isAction(track) and (Ball.holding or not next(Ball.parts)) then return "dribble", "smart" end
	return nil
end
function Anim.startLearn(kind)
	Anim.learnKind = kind
	Anim.learnUntil = tick() + 8
	Anim.learned = 0
	notify("Teaching " .. kind, "Do that move in the game now. You have 8 seconds.", 4)
	UI.show(false)
	task.delay(8.5, function()
		if JH.Running then UI.show(true) end
	end)
end
-- true while a Teach window is open and this animation was swallowed by it
function Anim.learn(track)
	if not Anim.learnKind then return false end
	if tick() > Anim.learnUntil then
		Anim.learnKind = nil
		return false
	end
	if track.Looped or not Anim.isAction(track) then return false end
	local id = Anim.idOf(track)
	if id == "" then return false end
	local flag = ANIM_FLAGS[Anim.learnKind]
	if not Anim.has(flag, id) then
		S[flag] = trim((S[flag] or "") .. " " .. id)
		Anim.learned = Anim.learned + 1
		saveSoon()
		log("Taught " .. Anim.learnKind .. ": " .. id)
		notify("Learned", Anim.learnKind .. " animation saved (" .. Anim.learned .. ")", 2)
	end
	return true
end
function Anim.clear()
	S.AnimDribble, S.AnimGather, S.AnimShot = "", "", ""
	saveSoon()
	notify("Taught moves", "Cleared", 2)
end
function Anim.summary()
	return string.format("Taught: %d dribble, %d gather, %d shot", #tokens(S.AnimDribble), #tokens(S.AnimGather), #tokens(S.AnimShot))
end
function Anim.handle(track)
	local n = Anim.name(track)
	if track.Looped and matchAny(n, { "dribble", "ball", "handle" }) then Anim.loops[track] = true end
	Shot.noteTrack(track)
	pcall(Anim.detTrack, track)
	local kind, how = Anim.classify(track)
	if Rec.on then
		Rec.add("anim", string.format("%s id=%s len=%.2f prio=%s looped=%s speed=%s -> %s", (track.Name or "") ~= "" and track.Name or "?",
			Anim.idOf(track), track.Length or 0, tostring(track.Priority.Value), tostring(track.Looped), tostring(track.Speed), tostring(kind)))
	end
	-- a dribble move spotted by name counts as proof you have the ball (used when the ball itself cannot be found)
	if kind == "dribble" and how ~= "smart" then Anim.lastDribble = tick() end
	if Anim.learn(track) then return end
	if Shot.busy then return end
	if kind and not Shot.hooked then Glide.fire(kind, "animation " .. ((track.Name or "") ~= "" and track.Name or "?")) end
end
function Anim.onPlayed(track)
	if Anim.seen[track] then return end
	Anim.seen[track] = true
	Anim.handle(track)
end
function Anim.poll()
	local a = Anim.animator
	if not a then return end
	local ok, list = pcall(function() return a:GetPlayingAnimationTracks() end)
	if not ok or type(list) ~= "table" then return end
	local playing = {}
	for _, track in ipairs(list) do
		playing[track] = true
		if not Anim.seen[track] then
			Anim.seen[track] = true
			pcall(Anim.handle, track)
		end
	end
	for track in pairs(Anim.seen) do
		if not playing[track] then Anim.seen[track] = nil end
	end
end
-- ANIMATION DETECTOR: names the shot, layup, dunk and post animations the game plays (real names, not numbers)
Anim.det = { list = {}, index = {}, catByName = {}, nameById = {}, scanned = false, scanning = false, lastAttr = nil, lastAction = nil, cur = nil }
Anim.DET_WORDS = {
	{ "Dunk", { "dunk", "slam", "tomahawk", "windmill", "rimgrazer", "alleyoop" } },
	{ "Layup", { "layup", "lay up", "scoop", "euro", "floater", "finger" } },
	{ "Post", { "post", "hook", "dropstep", "drop step" } },
	{ "Jump shot", { "jumpshot", "jump shot", "jumper", "pullup", "pull up", "stepback", "step back", "fadeaway", "shoot" } },
}
Anim.DET_PATHS = { { "Dunk", "dunk" }, { "Layup", "layup" }, { "Post", "post" }, { "Jump shot", "jumpshot" }, { "Jump shot", "jumper" } }
-- the game's own folders say which animation is which kind (its dunk list, layup list, post list)
function Anim.detScan()
	local d = Anim.det
	if d.scanned or d.scanning then return end
	d.scanning = true
	task.spawn(function()
		pcall(function()
			local n = 0
			for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
				n = n + 1
				if n % 1500 == 0 then task.wait() end
				local path, p = "", inst.Parent
				local guard = 0
				while p and p ~= ReplicatedStorage and guard < 30 do
					path = string.lower(p.Name) .. "/" .. path
					p = p.Parent
					guard = guard + 1
				end
				if inst:IsA("Animation") then
					d.nameById[string.lower(tostring(inst.AnimationId or ""))] = inst.Name
				end
				for _, e in ipairs(Anim.DET_PATHS) do
					if string.find(path, e[2], 1, true) then
						local l = string.lower(inst.Name)
						if not d.catByName[l] then d.catByName[l] = e[1] end
						break
					end
				end
			end
		end)
		d.scanned, d.scanning = true, false
	end)
end
function Anim.detCat(name)
	local l = string.lower(name)
	for _, e in ipairs(Anim.DET_WORDS) do
		for _, w in ipairs(e[2]) do
			if string.find(l, w, 1, true) then return e[1] end
		end
	end
	return Anim.det.catByName[l] or Anim.det.catByName[string.sub(l, 1, -2)]
end
function Anim.detAdd(name, id, cat)
	local d = Anim.det
	local key = string.lower(name)
	local e = d.index[key]
	if not e then
		e = { name = name, id = id or "", cat = cat, count = 0 }
		d.index[key] = e
		if S.DetNotify then pcall(notify, "Animation detected", tostring(cat) .. ": " .. name, 3) end
	end
	e.count = e.count + 1
	e.t = tick()
	e.cat = cat or e.cat
	if id and id ~= "" then e.id = id end
	d.cur = e
	for i, x in ipairs(d.list) do
		if x == e then table.remove(d.list, i) break end
	end
	table.insert(d.list, 1, e)
	while #d.list > 40 do
		local r = table.remove(d.list)
		d.index[string.lower(r.name)] = nil
	end
end
function Anim.detTrack(track)
	Anim.detScan()
	local a = track.Animation
	local id = a and tostring(a.AnimationId or "") or ""
	local nm = a and a.Name or ""
	if nm == "" or nm == "Animation" then nm = Anim.det.nameById[string.lower(id)] or track.Name or "" end
	if nm == "" then return end
	local cat = Anim.detCat(nm)
	if cat then Anim.detAdd(nm, id, cat) end
end
-- the game also writes the move it is playing onto your character (BaseAnimation)
function Anim.detStep()
	local d = Anim.det
	local c = char()
	if not c then return end
	local v = c:GetAttribute("BaseAnimation")
	local act = c:GetAttribute("Action")
	if d.lastAttr == nil then
		d.lastAttr = (type(v) == "string") and v or ""
		d.lastAction = act
		return
	end
	local changed = type(v) == "string" and v ~= "" and v ~= d.lastAttr
	local started = act == "Shooting" and d.lastAction ~= "Shooting" and type(v) == "string" and v ~= ""
	if changed or started then
		if type(v) == "string" then d.lastAttr = v end
		Anim.detAdd(v, "", Anim.detCat(v) or "Shot")
	end
	d.lastAction = act
end
function Anim.detText()
	local d = Anim.det
	local cur = d.cur
	local nowName, nowType = "-", "-"
	if cur then
		local ago = math.max(0, tick() - (cur.t or tick()))
		nowName = cur.name
		nowType = string.format("%s  (%ds ago)", tostring(cur.cat), math.floor(ago))
	end
	local lines = {}
	for i = 1, math.min(8, #d.list) do
		local e = d.list[i]
		lines[#lines + 1] = string.format("%s: %s  x%d", tostring(e.cat), e.name, math.floor(e.count))
	end
	return nowName, nowType, (#lines > 0) and table.concat(lines, "\n") or "Play a shot, layup, dunk or post move"
end
function Anim.detCopy()
	local d = Anim.det
	local out = { "== animations detected " .. VERSION }
	for _, e in ipairs(d.list) do
		out[#out + 1] = string.format("%s | %s | %s | seen %d", tostring(e.cat), e.name, e.id ~= "" and e.id or "(from the character)", math.floor(e.count))
	end
	local text = table.concat(out, "\n")
	if type(setclipboard) == "function" then pcall(setclipboard, text) end
	notify("Animations", #d.list .. " animation(s) copied", 3)
	return text
end
function Anim.hookChar(c)
	task.spawn(function()
		local function find() return c:FindFirstChildOfClass("Humanoid") or c:FindFirstChildOfClass("AnimationController") or c:FindFirstChildWhichIsA("Animator", true) end
		local h = find()
		local t0 = tick()
		while not h and tick() - t0 < 10 do
			task.wait(0.5)
			h = find()
		end
		if not h then return end
		local animator = h
		pcall(function()
			animator = h:IsA("Animator") and h or h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 5) or h
		end)
		Anim.animator = animator
		pcall(function()
			bind(animator.AnimationPlayed, function(track)
				pcall(Anim.onPlayed, track)
			end)
		end)
	end)
end

---------------------------------------------------------------------
-- SHOT BAR: finds the game's shot meter by what moves while you shoot, then reads it
---------------------------------------------------------------------
local BAR_PROPS = {
	asx = function(o) return o.AbsoluteSize.X end,
	asy = function(o) return o.AbsoluteSize.Y end,
	apx = function(o) return o.AbsolutePosition.X end,
	apy = function(o) return o.AbsolutePosition.Y end,
	irx = function(o) return o.ImageRectSize.X end,
	iry = function(o) return o.ImageRectSize.Y end,
	iox = function(o) return o.ImageRectOffset.X end,
	ioy = function(o) return o.ImageRectOffset.Y end,
	gox = function(o) return o.Offset.X end,
	goy = function(o) return o.Offset.Y end,
	grot = function(o) return o.Rotation end,
	gc2 = function(o) local k = o.Color.Keypoints return k[2] and k[2].Time end,
	gc3 = function(o) local k = o.Color.Keypoints return k[3] and k[3].Time end,
	gt2 = function(o) local k = o.Transparency.Keypoints return k[2] and k[2].Time end,
	gt3 = function(o) local k = o.Transparency.Keypoints return k[3] and k[3].Time end,
}
local FRAME_PROPS = { "asx", "asy", "apx", "apy" }
local IMAGE_PROPS = { "irx", "iry", "iox", "ioy" }
local GRAD_PROPS = { "gox", "goy", "grot", "gc2", "gc3", "gt2", "gt3" }
local BAR_HINTS = { "meter", "bar", "fill", "shot", "power", "timing", "release", "gauge", "progress", "bat" }
Bar.armedUntil = 0
Bar.misses = 0
Bar.inst = nil
Bar.report = {}
function Bar.isArmed() return tick() < Bar.armedUntil end
function Bar.pathOf(inst)
	local parts, o = {}, inst
	while o and o ~= game do
		table.insert(parts, 1, o.Name)
		o = o.Parent
	end
	return table.concat(parts, "/")
end
function Bar.resolve(path)
	local o = game
	for seg in string.gmatch(path, "[^/]+") do
		o = o and o:FindFirstChild(seg)
		if not o then return nil end
	end
	return o
end
function Bar.hint(inst)
	local score, o = 0, inst
	for _ = 1, 3 do
		if not o then break end
		if matchAny(string.lower(o.Name), BAR_HINTS) then score = score + 1 end
		o = o.Parent
	end
	return score
end
function Bar.getter(inst, prop)
	local fn = BAR_PROPS[prop]
	if not fn then return nil end
	return function() return fn(inst) end
end
-- the learned bar object, found again even if the game rebuilds it for every shot
function Bar.locate()
	local inst = Bar.inst
	if inst and inst.Parent then return inst end
	inst = S.BarPath ~= "" and Bar.resolve(S.BarPath) or nil
	if not inst and S.BarPath ~= "" then
		local name = string.match(S.BarPath, "([^/]+)$")
		local isGrad = string.sub(S.BarProp, 1, 1) == "g"
		for d in pairs(isGrad and Shot.grads or Shot.frames) do
			if d.Name == name and d.Parent and visibleChain(d.Parent) then
				inst = d
				break
			end
		end
	end
	Bar.inst = inst
	return inst
end
function Bar.selected() return S.BarProp ~= "" and S.BarPath ~= "" end
function Bar.threshold() return S.BarAt * (1 + S.BarNudge / 100) end
function Bar.forget()
	Bar.misses = 0
	S.BarPath, S.BarProp, S.BarAt = "", "", 0
	Bar.inst = nil
	saveSoon()
end
function Bar.select(c)
	S.BarPath, S.BarProp, S.BarAt = Bar.pathOf(c.inst), c.prop, 0
	Bar.inst = c.inst
	saveSoon()
	log("Shot bar found: " .. S.BarPath .. " (" .. c.prop .. ")")
	notify("Shot bar found", c.inst.Name .. " (" .. c.prop .. "). It learns the release point from your first green.", 4)
end
-- a watcher records what is on screen at the press and follows the bar during the hold
function Bar.watch(wide)
	local w = { n = 0, series = {}, known = {}, cands = {}, wide = wide, delta = nil, live = false, v0 = nil, before = {} }
	if not Bar.selected() then
		for d in pairs(Shot.frames) do
			if d.Parent and visibleChain(d) then w.before[d] = true end
		end
		for g in pairs(Shot.grads) do
			local p = g.Parent
			if p and visibleChain(p) then w.before[g] = true end
		end
	end
	return w
end
-- new candidates only: things that became visible after the press (or, when teaching, everything visible)
function Bar.collect(w)
	local out = {}
	local function add(inst, props)
		local base = Bar.pathOf(inst)
		if string.find(base, "Stamina", 1, true) then return end
		local hint = Bar.hint(inst)
		if string.find(base, "BatMeter", 1, true) then hint = hint + 3 end
		for _, name in ipairs(props) do
			local id = base .. "|" .. name
			if not w.known[id] then
				w.known[id] = true
				local fn = BAR_PROPS[name]
				out[#out + 1] = { id = id, inst = inst, prop = name, hint = hint, get = function() return fn(inst) end }
			end
		end
	end
	for d in pairs(Shot.frames) do
		if d.Parent and visibleChain(d) and (w.wide or not w.before[d]) then
			add(d, FRAME_PROPS)
			if d:IsA("ImageLabel") or d:IsA("ImageButton") then add(d, IMAGE_PROPS) end
		end
	end
	for g in pairs(Shot.grads) do
		local p = g.Parent
		if p and visibleChain(p) and (w.wide or not w.before[g]) then add(g, GRAD_PROPS) end
	end
	return out
end
function Bar.step(w)
	w.n = w.n + 1
	local result = nil
	if Bar.selected() then
		if not w.get then
			local inst = Bar.locate()
			if inst then
				local target = string.sub(S.BarProp, 1, 1) == "g" and inst.Parent or inst
				-- the start value is read the first time the bar is on screen, so every shot speed is measured from the same point
				if target and visibleChain(target) then w.get = Bar.getter(inst, S.BarProp) end
			end
		end
		if w.get then
			local ok, v = pcall(w.get)
			if ok and type(v) == "number" then
				if w.v0 == nil then w.v0 = v end
				local d = math.abs(v - w.v0)
				if w.delta == nil or d > w.delta + 0.0005 then w.lastMove = tick() end
				w.delta = d
				if d > 0.0005 then w.live = true end
				result = d
			end
		end
		-- while recording, everything that moves is still watched so it can be reported
		if not (Rec.on and w.wide) then return result end
	end
	if w.n <= 12 and #w.cands < 600 then
		for _, c in ipairs(Bar.collect(w)) do w.cands[#w.cands + 1] = c end
	end
	for _, c in ipairs(w.cands) do
		local ok, v = pcall(c.get)
		if ok and type(v) == "number" then
			local s = w.series[c.id]
			if not s then
				s = {}
				w.series[c.id] = s
			end
			s[#s + 1] = v
		end
	end
	return result
end
function Bar.minChange(prop)
	if prop == "grot" then return 4 end
	if string.sub(prop, 1, 1) == "g" then return 0.04 end
	return 3
end
-- the bar is whatever changed steadily in one direction during the hold, and was not just drifting around
function Bar.analyze(w)
	local best, bestScore
	local movers = {}
	for _, c in ipairs(w.cands or {}) do
		local s = w.series[c.id]
		if s and #s >= 5 then
			local ups, downs, steps = 0, 0, 0
			local span = math.abs(s[#s] - s[1])
			local eps = math.max(span * 0.01, 0.0001)
			for i = 2, #s do
				local d = s[i] - s[i - 1]
				if d > eps then
					ups = ups + 1
					steps = steps + 1
				elseif d < -eps then
					downs = downs + 1
					steps = steps + 1
				end
			end
			local consistency = steps > 0 and math.max(ups, downs) / steps or 0
			local score = steps * consistency + c.hint * 3
			if c.prop == "apx" or c.prop == "apy" then score = score * 0.4 end
			table.insert(movers, { id = c.id, span = span, steps = steps, consistency = consistency, score = score })
			if span >= Bar.minChange(c.prop) and steps >= 4 and consistency >= 0.85 then
				if not bestScore or score > bestScore then best, bestScore = c, score end
			end
		end
	end
	table.sort(movers, function(a, b) return a.span * a.consistency > b.span * b.consistency end)
	Bar.report = {}
	for i = 1, math.min(6, #movers) do
		local m = movers[i]
		Bar.report[i] = string.format("%s span=%.3f steps=%d consistency=%.2f", m.id, m.span, m.steps, m.consistency)
	end
	return best
end
-- after the shot: if no bar is known yet, try to pick it out of what moved
function Bar.finish(w)
	if not Bar.selected() then
		local best = Bar.analyze(w)
		if best then
			local s = w.series[best.id]
			Bar.select(best)
			w.delta = math.abs(s[#s] - s[1])
		else
			-- nothing moved like a bar this time; after two misses the next shots look at everything on screen
			Bar.misses = Bar.misses + 1
		end
	elseif Rec.on and #w.cands > 0 then
		Bar.analyze(w)
	end
	if Rec.on then
		for _, l in ipairs(Bar.report) do Rec.add("bar", "moved: " .. l) end
		if w.delta then Rec.add("bar", string.format("selected %s %s delta=%.3f point=%.3f", S.BarPath, S.BarProp, w.delta, S.BarAt)) end
	end
	return w.delta
end
function Bar.teach()
	Bar.forget()
	Bar.armedUntil = tick() + 14
	notify("Teaching the shot bar", "Press and hold the game's shoot button now. JHub takes this shot so it can watch the bar.", 5)
	UI.show(false)
	task.delay(14.5, function()
		if JH.Running then UI.show(true) end
	end)
end

---------------------------------------------------------------------
-- SHOOTING: Auto Green, Auto Calibrate, Auto Timing for every shot type
---------------------------------------------------------------------
Shot.busy = false
Shot.touchCtx = nil
Shot.labels, Shot.frames, Shot.grads = {}, {}, {}
Shot.stats = { shots = 0, greens = 0, early = 0, late = 0, none = 0, streak = 0, best = 0 }
Shot.times = {}
Shot.cap = nil
Shot.lastType = "-"
Shot.lastRelease = "-"
local STRENGTH_STEP = { 0.06, 0.15, 0.35 }
-- tracks text labels (feedback), frames and gradients (the shot bar) anywhere in the game, including the 3D world
function Shot.track(d)
	if d:IsA("TextLabel") then
		if not d:IsDescendantOf(gui) then Shot.labels[d] = true end
	elseif d:IsA("UIGradient") then
		if not d:IsDescendantOf(gui) then Shot.grads[d] = true end
	elseif d:IsA("Frame") or d:IsA("ImageLabel") or d:IsA("ImageButton") then
		if not d:IsDescendantOf(gui) then Shot.frames[d] = true end
	end
end
function Shot.untrack(d)
	Shot.labels[d], Shot.frames[d], Shot.grads[d] = nil, nil, nil
end
function Shot.hookRoot(root, chunked)
	if chunked then
		task.spawn(function()
			local n = 0
			for _, d in ipairs(root:GetDescendants()) do
				Shot.track(d)
				n = n + 1
				if n % 1500 == 0 then task.wait() end
			end
		end)
	else
		for _, d in ipairs(root:GetDescendants()) do Shot.track(d) end
	end
	bind(root.DescendantAdded, Shot.track)
	bind(root.DescendantRemoving, Shot.untrack)
end
function Shot.parseTimes()
	Shot.times = {}
	for key, val in string.gmatch(S.ShotTimes or "", "(%S+)=([%d%.]+)") do
		Shot.times[key] = tonumber(val)
	end
end
function Shot.saveTimes()
	local parts = {}
	for key, val in pairs(Shot.times) do table.insert(parts, string.format("%s=%.3f", key, val)) end
	table.sort(parts)
	S.ShotTimes = table.concat(parts, " ")
	saveSoon()
end
function Shot.timesSummary()
	local lines = {}
	for key, val in pairs(Shot.times) do
		local label = string.sub(key, -10)
		table.insert(lines, string.format("%s  %.2fs", label, val))
	end
	table.sort(lines)
	return #lines > 0 and table.concat(lines, "\n") or "No shot types learned yet. Take a few shots."
end
function Shot.classify(text)
	local tx = string.lower(text)
	if not string.find(tx, "release", 1, true) and not matchAny(tx, { "perfect", "excellent", "flawless", "splash", "good" }) then return nil end
	local strength = string.find(tx, "very", 1, true) and 3 or (string.find(tx, "slight", 1, true) and 1 or 2)
	if string.find(tx, "early", 1, true) then return "early", strength end
	if string.find(tx, "late", 1, true) then return "late", strength end
	if string.find(tx, "%f[%a]good%f[%A]") or string.find(tx, "%f[%a]great%f[%A]") or string.find(tx, "%f[%a]nice%f[%A]") then return "good", 0 end
	return "green", 0
end
function Shot.textSnapshot()
	local snap = {}
	for d in pairs(Shot.labels) do
		if not d.Parent then
			Shot.labels[d] = nil
		elseif visibleChain(d) then
			snap[d] = d.Text
		end
	end
	return snap
end
-- reads the game's release message: "green", "early" or "late" plus how strong it was
function Shot.result(snap, window, since)
	local t0 = tick()
	while tick() - t0 < window do
		for d in pairs(Shot.labels) do
			if not d.Parent then
				Shot.labels[d] = nil
			elseif d.Text ~= "" and snap[d] ~= d.Text and visibleChain(d) then
				local res, strength = Shot.classify(d.Text)
				if res then return res, strength, d.Text end
			end
		end
		if since then
			if since.idxT and Shot.fbIdxT > since.idxT then
				local r, st = Shot.fromIdx(Shot.fbIdx)
				if r then return r, st, "release " .. tostring(Shot.fbIdx) end
			end
			if Shot.fbT > since.fb then
				local r, s = Shot.classifyFB(Shot.fbText)
				if r then return r, s, Shot.fbText end
			end
			if Shot.greenT > since.green then return "green", 0, "green effect" end
			-- let go too soon, the game turns it into a pump fake and shows no message
			if since.fake and tick() - t0 > 0.15 then
				local c = char()
				if c and c:GetAttribute("Action") == "Gathering" then return "early", 3, "pump fake (released too soon)" end
			end
		end
		task.wait(0.06)
	end
	return nil, 0, nil
end
-- stand, move or sprint: the fallback when no shot animation could be recognised
function Shot.situation()
	local h, r = hum(), hrp()
	if not h or not r then return "stand" end
	local v = r.AssemblyLinearVelocity
	local hs = math.sqrt(v.X * v.X + v.Z * v.Z)
	if h.MoveDirection.Magnitude < 0.1 and hs < 3 then return "stand" end
	if hs > 19 or Input.held.Sprint or (UIS:IsKeyDown(Input.keyCode(S.SprintKey) or Enum.KeyCode.LeftShift)) then return "sprint" end
	return "move"
end
function Shot.paramValue(sit)
	local t = S.HoldTime
	if S.AutoTiming then
		if sit == "move" then t = t + S.MovingOffset elseif sit == "sprint" then t = t + S.SprintOffset end
	end
	return t
end
-- remembers the animations that start right after the press: one of them is the shot
function Shot.noteTrack(track)
	local cap = Shot.cap
	if not cap or track.Looped or not Anim.isAction(track) then return end
	if tick() - cap.t0 > 0.8 then return end
	table.insert(cap.tracks, track)
end
function Shot.pickTrack(cap)
	local best, bs
	for _, tr in ipairs(cap.tracks) do
		local score = tr.Length or 0
		local n = Anim.name(tr)
		if matchAny(n, SHOT_WORDS) or matchAny(n, GATHER_WORDS) then score = score + 100 end
		if not bs or score > bs then best, bs = tr, score end
	end
	return best
end
function Shot.keyOf(track, sit)
	if track then
		local id = Anim.idOf(track)
		if id ~= "" then return id end
		return "name:" .. string.lower(track.Name or "shot")
	end
	return "sit:" .. sit
end
function Shot.nameOf(track, sit)
	if not track then return sit end
	local n = track.Name
	if n and n ~= "" and n ~= "Animation" then return n end
	local a = track.Animation
	if a and a.Name and a.Name ~= "" and a.Name ~= "Animation" then return a.Name end
	return string.sub(Anim.idOf(track), -8)
end
-- the hold time for this shot: learned for this shot type, else guessed from the animation length, else the base timing
function Shot.holdFor(sit, track)
	local key = Shot.keyOf(track, sit)
	local base
	if S.AutoTiming and track then
		base = Shot.times[key]
		if not base and S.ShotRatio > 0 and (track.Length or 0) > 0.05 then base = S.ShotRatio * track.Length end
	end
	base = base or Shot.paramValue(sit)
	local t = base
	if S.AutoTiming and S.PingComp > 0 then
		local ok, ping = pcall(function() return LP:GetNetworkPing() end)
		if ok and ping then t = t - ping * (S.PingComp / 100) end
	end
	t = t + S.Nudge / 1000
	if S.Humanize > 0 then t = t + (math.random() * 2 - 1) * (S.Humanize / 1000) end
	return clamp(t, 0.05, S.MaxHold), key, base
end
function Shot.applyDelta(sit, delta)
	if S.AutoTiming and sit == "move" then
		UI.set("MovingOffset", clamp(S.MovingOffset + delta, -0.5, 0.5), false)
	elseif S.AutoTiming and sit == "sprint" then
		UI.set("SprintOffset", clamp(S.SprintOffset + delta, -0.5, 0.5), false)
	else
		UI.set("HoldTime", clamp(S.HoldTime + delta, 0.08, 1.6), false)
	end
end
function Shot.release(mode, ctx)
	if mode == "backup" then
		Backup.send(false)
	elseif mode == "remote" then
		Shot.releasedT = tick()
		Shot.fireRemote(false)
	elseif mode == "manualKey" then
		Input.sendKey(S.ShootKey, false)
	elseif mode == "touch" and ctx then
		if S.ReleaseMethod ~= "Key" and ctx.btn then Input.fireGui(ctx.btn, false, S.FireClick) end
		if S.ReleaseMethod ~= "Button" then Input.sendKey(S.ShootKey, false) end
	end
end
function Shot.learnTiming(info, res, strength)
	local rate = S.CalSpeed
	local base, held = info.base, info.held
	local function stepFor(from)
		return math.max(S.CalStep * strength * rate, from * STRENGTH_STEP[strength] * rate / 0.6)
	end
	if S.AutoTiming and info.track then
		local newv
		if info.manual or info.usedBar then
			if res == "green" then newv = base + (held - base) * 0.5 end
		elseif res == "green" then
			newv = base
		elseif res == "early" then
			newv = base + stepFor(base)
		elseif res == "late" then
			newv = base - stepFor(base)
		end
		if newv then
			Shot.times[info.key] = clamp(newv, 0.08, S.MaxHold)
			Shot.saveTimes()
		end
		local len = info.track.Length or 0
		if res == "green" and len > 0.05 then
			local ratio = (Shot.times[info.key] or held) / len
			S.ShotRatio = (S.ShotRatio > 0) and (S.ShotRatio * 0.6 + ratio * 0.4) or ratio
			saveSoon()
		end
		return
	end
	local delta = 0
	local pv = Shot.paramValue(info.sit)
	if info.manual or info.usedBar then
		if res == "green" then delta = (held - pv) * 0.5 end
	elseif res == "early" then
		delta = stepFor(pv)
	elseif res == "late" then
		delta = -stepFor(pv)
	end
	if delta ~= 0 then Shot.applyDelta(info.sit, delta) end
end
-- manual = you let go yourself (JHub only learns from it); otherwise JHub released the shot
function Shot.evaluate(info)
	local res, strength, text = Shot.result(info.snap, 2, info.since)
	local st = Shot.stats
	if res == "green" then
		st.greens = st.greens + 1
		st.streak = st.streak + 1
		if st.streak > st.best then st.best = st.streak end
		if S.GreenSound then playSound(SND_CLICK, 0.6) end
	elseif res == "good" then
		st.streak = 0
	elseif res == "early" then
		st.early = st.early + 1
		st.streak = 0
	elseif res == "late" then
		st.late = st.late + 1
		st.streak = 0
	else
		st.none = st.none + 1
	end
	local note = text and ('"' .. text .. '"') or "no feedback seen"
	if S.AutoCalibrate and res then
		local rate = S.CalSpeed
		if info.barDelta and Bar.selected() then
			if res == "green" then
				if info.usedBar and S.BarAt > 0 then
					S.BarAt = S.BarAt * 0.7 + info.barDelta * 0.3
				elseif S.BarAt <= 0 then
					S.BarAt = info.barDelta
				else
					S.BarAt = S.BarAt * 0.5 + info.barDelta * 0.5
				end
			elseif info.usedBar and S.BarAt > 0 then
				local k = STRENGTH_STEP[strength] * rate / 0.6
				S.BarAt = S.BarAt * (res == "early" and (1 + k) or (1 - k))
			end
			saveSoon()
		end
		if info.remote then
			info.idx = (info.since and Shot.fbIdxT > info.since.idxT) and Shot.fbIdx or nil
			info.relQ = Shot.meterQ()
			if info.usedMeter then
				Shot.learnMeter(info)
				note = note .. string.format("  |  aim %.3f", S.MeterTarget)
			else
				Shot.learnRemote(info, res, strength)
				note = note .. string.format("  |  %.3fs", Shot.times[info.key] or info.held)
			end
		else
			Shot.learnTiming(info, res, strength)
			note = note .. string.format("  |  %s  |  %.2fs", Shot.lastType, Shot.times[info.key] or Shot.paramValue(info.sit))
		end
	end
	if Rec.shotOn then
		pcall(Rec.shotNote, info, res, text)
		Rec.shotAdd(string.format("RESULT %s | held=%.4f | key=%s | message=%s | game log=%s", tostring(res), info.held or 0, tostring(info.key), tostring(text),
			string.sub(tostring(Shot.fbText or ""), 1, 200)))
	end
	log("Shot: " .. note)
	notify(res == "green" and "GREEN!" or "Shot", note, 2.2)
end
-- the game's own shot signals, read from its remotes: the meter starting, its timing number and the result
Shot.meterT, Shot.packet, Shot.packetT, Shot.greenT, Shot.fbT, Shot.fbText = 0, nil, 0, 0, 0, ""
Shot.releasedT, Shot.pressT, Shot.pkMiss = 0, 0, 0
Shot.hooked = false
Shot.selfFire = false
Shot.remote = nil
function Shot.findRemote()
	local r = Shot.remote
	if r and r.Parent then return r end
	Shot.remote = nil
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if d:IsA("RemoteEvent") and d.Name == "Shoot" then
			Shot.remote = d
			if d.Parent and d.Parent.Name == "InputService" then break end
		end
	end
	return Shot.remote
end
-- lets go of the shot the same way the game does when a finger lifts
function Shot.fireRemote(down)
	local r = Shot.findRemote()
	if not r then return false end
	Shot.selfFire = true
	local ok = pcall(function() r:FireServer({ Shoot = down }) end)
	Shot.selfFire = false
	return ok
end
function Shot.classifyFB(text)
	local tx = string.lower(text)
	local strength = string.find(tx, "very", 1, true) and 3 or (string.find(tx, "slight", 1, true) and 1 or 2)
	if string.find(tx, "%f[%a]early%f[%A]") then return "early", strength end
	if string.find(tx, "%f[%a]late%f[%A]") then return "late", strength end
	if string.find(tx, "%f[%a]perfect%f[%A]") or string.find(tx, "%f[%a]green%f[%A]") or string.find(tx, "%f[%a]excellent%f[%A]") then
		return "green", 0
	end
	if string.find(tx, "%f[%a]good%f[%A]") then return "good", 0 end
	return nil
end
local function isMine(a)
	local sawInst = false
	for i = 1, 3 do
		local v = a[i]
		if typeof(v) == "Instance" then
			sawInst = true
			if v.Name == LP.Name then return true end
		end
	end
	return not sawInst
end
function Shot.onRemoteEvent(name, ...)
	local a = { ... }
	if Rec.shotOn then
		local parts = {}
		for i = 1, math.min(#a, 8) do
			local v = a[i]
			parts[#parts + 1] = typeof(v) == "Instance" and ("<" .. v.Name .. ">") or (type(v) == "table" and "{table}" or tostring(v))
		end
		Rec.shotAdd("EVENT " .. name .. " " .. table.concat(parts, " | "))
	end
	if name == "Meter" then
		if a[1] == true and typeof(a[2]) == "Instance" and a[2].Name == LP.Name then
			Shot.meterT, Shot.packet = tick(), nil
			if Rec.shotOn then Rec.shotMeterStart() end
		end
	elseif name == "RegisterPacket" then
		if typeof(a[1]) == "Instance" and a[1].Name == LP.Name and type(a[3]) == "number" then
			Shot.packet, Shot.packetT = a[3], tick()
		end
	elseif name == "ShowFeedback" then
		if typeof(a[1]) == "Instance" and (a[1].Name == LP.Name or a[1] == char()) and tonumber(a[3]) then Shot.fbIdx, Shot.fbIdxT = tonumber(a[3]), tick() end
	elseif name == "RunGreenEffect" or name == "GreenCelebration" then
		if isMine(a) then Shot.greenT = tick() end
	elseif name == "Output" then
		if type(a[2]) == "string" and string.find(a[2], "Shot Feedback", 1, true) then Shot.fbT, Shot.fbText = tick(), a[2] end
	end
end
Shot.remoteNames = { Meter = true, RegisterPacket = true, RunGreenEffect = true, GreenCelebration = true, Output = true, ShowFeedback = true,
	UpdateGreenWindow = true, GreenToggle = true }
Shot.fbIdx, Shot.fbIdxT = nil, 0
-- the game's own scale: 1 Very Early, 2 Early, 3 Slightly Early, 4 Good, 5 Perfect, 6 Slightly Late, 7 Late, 8 Very Late
function Shot.fromIdx(idx)
	if idx == 5 then return "green", 0 end
	if idx == 4 then return "good", 1 end
	if idx and idx < 4 then return "early", 4 - idx end
	if idx and idx > 5 then return "late", idx - 5 end
	return nil
end
function Shot.connectRemotes()
	local function watch(d)
		if d:IsA("RemoteEvent") and Shot.remoteNames[d.Name] then
			bind(d.OnClientEvent, function(...) pcall(Shot.onRemoteEvent, d.Name, ...) end)
		end
	end
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do watch(d) end
	bind(ReplicatedStorage.DescendantAdded, watch)
end
-- runs inside the namecall hook for every Shoot remote the game fires: true means "do not send this one"
function Shot.onShootCall(args)
	local d = args[1]
	if type(d) ~= "table" or Shot.selfFire then return false end
	local now = tick()
	if Rec.shotOn then Rec.shotAdd("SHOOT remote Shoot=" .. tostring(d.Shoot) .. " Input=" .. tostring(d.Input) .. " UseSpace=" .. tostring(d.UseSpace)) end
	if d.Shoot == true then
		Shot.pressT = now
		if S.ShotGlide then Mover.watchShot(now) end
		if S.AutoGreen and not Shot.busy then
			local ctx = { t0 = now, ended = false, space = d.UseSpace == true, btn = Input.lastTouch and Input.lastTouch.obj }
			Shot.remoteCtx = ctx
			task.defer(Shot.run, "remote", ctx)
		end
	elseif d.Shoot == false then
		local ctx = Shot.remoteCtx
		if ctx and Shot.busy and not ctx.released then
			-- Tap: your lift is ignored and JHub lets go at the green point. Hold: your own early lift goes through.
			if S.ShotStyle == "Tap" and S.AutoGreen then
				ctx.dropped = true
				return true
			end
			ctx.ended = true
			return false
		end
		if S.AutoGreen and now - Shot.releasedT < 2.5 then return true end
	end
	return false
end
Shot.FLOOR = 0.205
Shot.brackets = {}
-- a release sooner than this after the meter starts is a pump fake in this game
function Shot.remoteKey(cap, sit)
	local ids = {}
	for _, tr in ipairs(cap.tracks) do
		local id = Anim.idOf(tr)
		if id ~= "" then ids[#ids + 1] = string.gsub(id, "rbxassetid://", "") end
	end
	table.sort(ids)
	if #ids == 0 then return "sit:" .. sit end
	return table.concat(ids, "+")
end
Shot.SWEEPSCALE = { ["71484695722621"] = 1, ["77401448272074"] = 1, ["128777513307709+77401448272074"] = 1 }
Shot.SWEEPLIST = {
	["77401448272074"] = { 0.006, 0.012, 0.018, 0.024, 0.030, 0.036, 0.042, 0.048 },
	["128777513307709+77401448272074"] = { 0.006, 0.012, 0.018, 0.024, 0.030, 0.036, 0.042, 0.048 },
}
Shot.FINAL = {
	["15851912457+15851919155"] = 0.357,
	["15851912457+15851919155+17285155256"] = 0.357,
	["111074210919383"] = 0.357,
	["71484695722621"] = 0.311,
	["77401448272074"] = 0.329,
	["128777513307709+77401448272074"] = 0.329,
}
Shot.VERDICT = { "Very early", "Early", "Slightly early", "Good", "Perfect", "Slightly late", "Late", "Very late" }
Shot.NAMES = {
	["15851912457+15851919155"] = "Jump Shot 1",
	["15851912457+15851919155+17285155256"] = "Jump Shot 1 (fake)",
	["111074210919383"] = "Post fade",
	["71484695722621"] = "Post spin fade (left)",
	["77401448272074"] = "Post spin fade (right)",
	["128777513307709+77401448272074"] = "Post spin fade (right)",
}
Shot.adjLog = {}
Shot.cur, Shot.last = nil, nil
function Shot.noteAdjust(key, from, to, why)
	table.insert(Shot.adjLog, 1, { t = tick(), key = key, from = from, to = to, why = why })
	while #Shot.adjLog > 6 do table.remove(Shot.adjLog) end
end
local function agoText(t)
	local d = math.max(0, tick() - t)
	if d < 60 then return string.format("%ds ago", math.floor(d)) end
	return string.format("%dm ago", math.floor(d / 60))
end
function Shot.nameFor(key, anim)
	local n = Shot.NAMES[key]
	if n then return n end
	if anim and anim ~= "" then return tostring(anim) end
	return "Shot " .. string.sub(tostring(key), -6)
end
function Shot.statusLines()
	local cur = Shot.cur
	if not cur then
		local c0, p0 = Shot.pingComp()
		return "-", "-", "Shoot to see it", "-", "No change yet", S.PerfectGreen and string.format("%.0f ms earlier (ping %.0f ms)", c0 * 1000, p0 * 1000) or string.format("off (ping %.0f ms)", p0 * 1000)
	end
	local last = "-"
	if Shot.last then
		local l = Shot.last
		local v = (l.idx and Shot.VERDICT[l.idx]) or (l.res == "green" and "Perfect") or (l.res == "good" and "Good") or tostring(l.res)
		last = string.format("%s at %.3fs", v, l.held or 0)
	end
	local lines = {}
	for i = 1, math.min(4, #Shot.adjLog) do
		local a = Shot.adjLog[i]
		lines[#lines + 1] = string.format("%s: %.3f -> %.3fs (%s)", agoText(a.t), a.from, a.to, a.why)
	end
	local comp, p = Shot.pingComp()
	local ptxt
	if S.PerfectGreen then ptxt = string.format("%.0f ms earlier (ping %.0f ms)", comp * 1000, p * 1000) else ptxt = string.format("off (ping %.0f ms)", p * 1000) end
	return Shot.nameFor(cur.key, cur.anim), string.format("%.3fs", cur.hold), cur.state or "-", last,
		(#lines > 0) and table.concat(lines, "\n") or "No change yet", ptxt
end
function Shot.statusStep()
	local st = UI.autoStat
	if not st then return end
	local now = tick()
	if Shot.statusT and now - Shot.statusT < 0.25 then return end
	Shot.statusT = now
	local a, b, c, d, e, f = Shot.statusLines()
	st.shot.Text, st.timing.Text, st.state.Text, st.last.Text, st.adj.Text = a, b, c, d, e
	if st.ping then st.ping.Text = f end
	local dt = UI.detStat
	if dt then
		pcall(Anim.detStep)
		local n1, n2, n3 = Anim.detText()
		dt.now.Text, dt.type.Text, dt.list.Text = n1, n2, n3
	end
end
Shot.PING_REF = 0.022
function Shot.pingNow()
	local ok, p = pcall(function() return LP:GetNetworkPing() end)
	p = (ok and type(p) == "number") and p or Shot.PING_REF
	Shot.pingEma = Shot.pingEma and (Shot.pingEma * 0.7 + p * 0.3) or p
	return Shot.pingEma
end
function Shot.pingComp()
	local p = Shot.pingNow()
	if not S.PerfectGreen then return 0, p end
	local comp = (p - Shot.PING_REF) * ((S.PerfectGreenPct or 100) / 100)
	return clamp(comp, -0.02, 0.2), p
end
Shot.AUTO_START = 0.34
Shot.AUTO_SCAN = { 0.30, 0.32, 0.34, 0.36, 0.38, 0.31, 0.33, 0.35, 0.37, 0.29, 0.39, 0.40, 0.28 }
Shot.auto = {}
Shot.autoLoaded = false
function Shot.autoLoad()
	if Shot.autoLoaded then return end
	Shot.autoLoaded = true
	Shot.auto = {}
	for kind, key, val in string.gmatch(S.AutoTimes or "", "(%a):(%S-)=([%d%.]+)") do
		Shot.auto[key] = { hold = tonumber(val), greens = {}, locked = kind == "L", dir = 1 }
	end
end
function Shot.autoSave()
	local parts = {}
	for key, a in pairs(Shot.auto) do parts[#parts + 1] = string.format("%s:%s=%.3f", a.locked and "L" or "P", key, a.hold) end
	table.sort(parts)
	S.AutoTimes = table.concat(parts, " ")
	saveSoon()
end
function Shot.autoReset()
	Shot.autoLoaded = true
	Shot.auto = {}
	S.AutoTimes = ""
	saveSoon()
end
function Shot.autoActive(key)
	if not S.AutoCal or Shot.FINAL[key] then return false end
	if S.Sweep and Rec.shotOn then return false end
	if Shot.times["la:" .. key] or Shot.times["r:" .. key] then return false end
	return true
end
function Shot.autoLearn(info, res, strength)
	local key = info.key
	if not Shot.autoActive(key) then return false end
	Shot.autoLoad()
	local a = Shot.auto[key]
	if not a then return false end
	if a.locked then return true end
	local held = (info.held or 0) + (info.comp or 0)
	local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
	if not idx or not held then return true end
	if info.manual and idx ~= 5 then return true end
	if not info.manual and math.abs(held - a.hold) > 0.06 then return true end
	a.n = (a.n or 0) + 1
	local before, wasLocked = a.hold, a.locked
	local step = true
	if idx == 5 then
		step = false
		a.greens[#a.greens + 1] = held
		a.miss = 0
		local sum = 0
		for _, g in ipairs(a.greens) do sum = sum + g end
		a.hold = sum / #a.greens
		if #a.greens >= 2 then
			a.locked = true
			pcall(notify, "Auto Green", string.format("Learned a new shot: %.3fs", a.hold), 3)
		end
	elseif #a.greens >= 1 then
		a.miss = (a.miss or 0) + 1
		if a.miss >= 3 then
			a.greens = {}
			a.miss = 0
		else
			step = false
		end
	end
	-- late: a little earlier, early: a little later, and the shot after that tells whether it helped
	if step then
		if idx == 4 then
			a.hold = held + 0.006 * a.dir
		elseif idx <= 3 then
			a.dir = 1
			a.hold = held + (idx == 3 and 0.010 or (idx == 2 and 0.020 or 0.035))
		else
			a.dir = -1
			a.hold = held - (idx == 6 and 0.010 or (idx == 7 and 0.020 or 0.035))
		end
	end
	a.hold = clamp(a.hold, Shot.FLOOR, S.MaxHold)
	if a.locked and not wasLocked then
		Shot.noteAdjust(key, before, a.hold, "Perfect x2, locked")
	elseif math.abs(a.hold - before) > 0.0005 then
		Shot.noteAdjust(key, before, a.hold, (Shot.VERDICT[idx] or "?") .. ((a.dir or 1) > 0 and ", going later" or ", going earlier"))
	end
	Shot.autoSave()
	if Rec.shotOn then
		Rec.shotAdd(string.format("AUTOCAL key=%s idx=%s held=%.3f next=%.3f greens=%d locked=%s", key, tostring(idx), held, a.hold, #a.greens, tostring(a.locked)))
	end
	return true
end
function Shot.remoteHold(key, pk)
	local fin = Shot.FINAL[key]
	if fin then
		Shot.lastSweep = nil
		Shot.cur = { key = key, hold = fin, state = "Locked (built in)" }
		return clamp(fin, Shot.FLOOR, S.MaxHold), fin
	end
	if Shot.autoActive(key) then
		Shot.autoLoad()
		local a = Shot.auto[key]
		if not a then
			a = { hold = Shot.times[key] or Shot.AUTO_START, greens = {}, locked = false, dir = 1 }
			Shot.auto[key] = a
		end
		Shot.lastSweep = nil
		local state = a.locked and "Locked (learned)" or (#a.greens >= 1 and string.format("Learning (%d of 2 Perfects)", #a.greens)) or ((a.n or 0) > 0 and ((a.dir or 1) > 0 and "Learning, trying later" or "Learning, trying earlier")) or "Learning"
		Shot.cur = { key = key, hold = a.hold, state = state }
		return clamp(a.hold, Shot.FLOOR, S.MaxHold), a.hold
	end
	local base = Shot.times[key]
	-- some shots (the jumpers) have their green point move with the game's per-shot number: hold = number x ratio
	local ratio = Shot.times["r:" .. key]
	if ratio and pk and pk > 0 then base = pk * ratio end
	-- the jumper's green point moves with the game's per-shot number along a straight line: hold = a + b x number
	local la, lb = Shot.times["la:" .. key], Shot.times["lb:" .. key]
	if la and lb and pk and pk > 0 then base = la + lb * pk end
	if not base then
		base = pk and pk * S.PacketMul or S.HoldTime
	end
	local hold = base + S.Nudge / 1000
	Shot.lastSweep = nil
	if S.Sweep and Rec.shotOn and not Shot.times["la:" .. key] then
		-- sweep: every shot of a type goes out a little earlier or later than the last, so the recording shows exactly where Perfect is
		Shot.sweepN = Shot.sweepN or {}
		local i = (Shot.sweepN[key] or 0) + 1
		Shot.sweepN[key] = i
		local lst = Shot.SWEEPLIST[key] or Shot.SWEEP
		local off = lst[(i - 1) % #lst + 1]
		if not Shot.SWEEPLIST[key] then off = off * (Shot.SWEEPSCALE[key] or 2.5) end
		hold = hold + off
		Shot.lastSweep = off
		Rec.shotAdd(string.format("SWEEP key=%s step=%d offset=%+.3f", key, i, off))
	end
	Shot.cur = { key = key, hold = hold, state = (S.Sweep and Rec.shotOn) and "Sweep recording" or (S.AutoCal and "Fixed timing" or "Auto-learn off") }
	return clamp(hold, Shot.FLOOR, S.MaxHold), base
end
Shot.SWEEP = { -0.036, -0.030, -0.024, -0.018, -0.012, -0.006, 0, 0.006, 0.012, 0.018, 0.024, 0.030, 0.036 }
-- closed loop on the game's own Early / Late messages: every miss narrows where the green point is
Shot.greenKeys = {}
-- only Perfect counts: after a green the saved time is anchored to it and misses only nudge it
function Shot.learnRemote(info, res, strength)
	if info then
		local ch = char()
		Shot.last = { t = tick(), held = info.held, idx = info.idx, res = res, key = info.key }
		if Shot.cur and Shot.cur.key == info.key and ch then Shot.cur.anim = ch:GetAttribute("BaseAnimation") end
	end
	if info and Shot.FINAL[info.key] then return end
	if info and Shot.autoLearn(info, res, strength) then return end
	if not S.Learn or (S.Sweep and Rec.shotOn) then return end
	local key, held = info.key, info.held + (info.comp or 0)
	local new
	if info.manual then
		if res == "green" then new = held end
	elseif res == "early" and (strength or 2) >= 3 then
		-- a pump fake or a very early release: far too soon
		new = held + 0.07
	elseif Shot.times["la:" .. key] then
		return
	elseif info.pk and info.pk > 0 and Shot.times["r:" .. key] and res ~= "early" then
		local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "late" and 5 + (strength or 2))
		local est = (held - (idx - 5) * 0.006) / info.pk
		local old = Shot.times["r:" .. key]
		local rate = res == "green" and 0.7 or (Shot.greenKeys[key] and 0.1 or 0.35)
		if res == "green" then Shot.greenKeys[key] = true end
		Shot.times["r:" .. key] = clamp(old + rate * (est - old), 0.5, 3)
		Shot.saveTimes()
		return
	else
		-- the game's verdict scale (4 Good, 5 Perfect, 6 Slightly Late, 7 Late) tells how far the release was from the green point:
		-- every shot moves the saved time part of the way to where it would have been Perfect, so one odd shot cannot throw it off
		local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
		if idx then
			local est = held - (idx - 5) * 0.014
			local old = Shot.times[key] or held
			local rate = res == "green" and 0.7 or (Shot.greenKeys[key] and 0.12 or 0.45)
			if res == "green" then Shot.greenKeys[key] = true end
			new = old + rate * (est - old)
		end
		if res == "green" and info.pk and info.pk > 0 then S.PacketMul = clamp(S.PacketMul * 0.5 + (held / info.pk) * 0.5, 0.4, 3) end
	end
	if new then
		Shot.times[key] = clamp(new, Shot.FLOOR, S.MaxHold)
		Shot.saveTimes()
	end
end
-- a shot the game started itself (shoot button, dunk trampoline, jump button): JHub lets go at the green point
Shot.lastBin = nil
-- progress along the meter: 0 at the start, 1 at the end of the bar (the game moves meterOffset.Y from 0 towards -1)
function Shot.meterQ()
	local c = char()
	local v = c and c:GetAttribute("meterOffset")
	if typeof(v) == "Vector2" or typeof(v) == "Vector3" then return -v.Y end
	return nil
end
-- learned in meter positions, so it carries over to every shot type, whatever its speed
function Shot.learnMeter(info)
	local relQ, idx = info.relQ, info.idx
	if not relQ or not idx then return end
	if idx == 5 then
		S.MeterTarget = S.MeterTarget * 0.5 + relQ * 0.5
	else
		if Shot.lastBin and Shot.lastBin.idx ~= idx then
			local bw = math.abs(relQ - Shot.lastBin.q) / math.abs(idx - Shot.lastBin.idx)
			S.MeterBin = clamp(S.MeterBin * 0.5 + bw * 0.5, 0.008, 0.12)
		end
		S.MeterTarget = relQ + (5 - idx) * S.MeterBin
	end
	S.MeterTarget = clamp(S.MeterTarget, 0.3, 1.6)
	Shot.lastBin = { idx = idx, q = relQ }
	saveSoon()
end
function Shot.remoteCore(ctx)
	local snap = Shot.textSnapshot()
	local since = { green = Shot.greenT, fb = Shot.fbT, fake = true, idxT = Shot.fbIdxT }
	local samples = {}
	local mconn
	do
		local c = char()
		if c then
			local ok, sig = pcall(function() return c:GetAttributeChangedSignal("meterOffset") end)
			if ok and sig then
				mconn = sig:Connect(function()
					local q = Shot.meterQ()
					if q then samples[#samples + 1] = { t = tick(), q = q } end
				end)
			end
		end
	end
	local t0 = ctx.t0
	local cap = { t0 = t0 - 0.05, tracks = {} }
	Shot.cap = cap
	-- it is only a shot once the game starts its meter
	local waitEnd = tick() + 0.5
	while tick() < waitEnd and Shot.meterT < t0 - 0.05 do RunService.Heartbeat:Wait() end
	if Shot.meterT < t0 - 0.05 then
		Shot.cap = nil
		if ctx.dropped and not ctx.ended then Shot.fireRemote(false) end
		return
	end
	local m0 = Shot.meterT
	for i = #samples, 1, -1 do
		if samples[i].t < m0 - 0.05 then table.remove(samples, i) end
	end
	do
		-- a gather (spin, hop) starts the meter later: time from the first meter movement
		local ch = char()
		if ch and ch:GetAttribute("Action") == "Gathering" then
			local we = tick() + 1.5
			while #samples == 0 and tick() < we do RunService.Heartbeat:Wait() end
			if #samples > 0 then m0 = samples[1].t end
		end
	end
	local pw = tick() + 0.12
	while (Shot.packetT < m0 - 0.01 or #cap.tracks == 0) and tick() < pw do RunService.Heartbeat:Wait() end
	local pk = Shot.packetT >= m0 - 0.01 and Shot.packet or nil
	local sit = Shot.situation()
	local key = Shot.remoteKey(cap, sit)
	Shot.cap = nil
	local hold, base = Shot.remoteHold(key, pk)
	local comp = Shot.pingComp()
	if comp ~= 0 then hold = math.max(Shot.FLOOR, hold - comp) end
	if Shot.cur then Shot.cur.comp = comp end
	local manual = false
	local usedMeter, qpred = false, nil
	local ok0, ping0 = pcall(function() return LP:GetNetworkPing() end)
	local lead = (ok0 and ping0 or 0.04) + 0.016 + S.Nudge / 1000
	while tick() - m0 < S.MaxHold do
		if ctx.ended then
			manual = true
			break
		end
		local now = tick()
		local n = #samples
		-- the meter moves by itself: JHub releases when it is about to reach the aim point (by the meter, not by a clock)
		if S.MeterAim and n >= 3 and now - samples[n].t < 0.15 then
			local a, b = samples[math.max(1, n - 3)], samples[n]
			local dt = b.t - a.t
			if dt > 0.01 then
				local rate = (b.q - a.q) / dt
				if rate > 0.05 then
					usedMeter = true
					qpred = b.q + rate * ((now - b.t) + lead)
					if qpred >= S.MeterTarget then break end
				end
			end
		elseif now - m0 >= hold - 0.02 then
			break
		end
		RunService.Heartbeat:Wait()
	end
	if mconn then pcall(function() mconn:Disconnect() end) end
	-- the last few milliseconds are spent waiting exactly, so the release lands on the point and not on a frame boundary
	local last, stuck = tick(), 0
	while not usedMeter and not manual and not ctx.ended and tick() - m0 < hold do
		local n = tick()
		if n == last then
			stuck = stuck + 1
			if stuck > 20000 then break end
		else
			last, stuck = n, 0
		end
	end
	-- (a clock that does not move falls back to waiting frame by frame)
	while not manual and not ctx.ended and tick() - m0 < hold do RunService.Heartbeat:Wait() end
	local held = tick() - m0
	if not manual then Shot.release("remote", ctx) end
	ctx.released = true
	Shot.stats.shots = Shot.stats.shots + 1
	Shot.lastType = key
	Shot.lastRelease = manual and "you" or "timing"
	if Rec.on then
		Rec.add("shot", string.format("remote shot key=%s packet=%s hold=%.3f base=%.3f held=%.3f released by %s style=%s space=%s", key, tostring(pk), hold,
			base, held, Shot.lastRelease, tostring(S.ShotStyle), tostring(ctx.space)))
	end
	if Rec.shotOn then
		Rec.shotAdd(string.format("RELEASE meter=%s target=%.3f predicted=%s samples=%d key=%s packet=%s hold=%.4f held=%.4f by=%s style=%s ping=%s comp=%.4f", tostring(usedMeter), S.MeterTarget, tostring(qpred), #samples, key, tostring(pk), hold, held,
			Shot.lastRelease, tostring(S.ShotStyle), tostring(pcall(function() return LP:GetNetworkPing() end) and LP:GetNetworkPing() or "?"), comp))
	end
	task.spawn(Shot.evaluate, { snap = snap, since = since, sit = sit, key = key, base = base, held = held, manual = manual,
		pk = pk, remote = true, usedBar = false, usedMeter = usedMeter, qpred = qpred, comp = manual and 0 or comp })
end
function Shot.core(mode, ctx)
	if mode == "remote" then return Shot.remoteCore(ctx) end
	local sit = Shot.situation()
	local snap = Shot.textSnapshot()
	local wide = Bar.isArmed() or Rec.on or (not Bar.selected() and Bar.misses >= 2 and Bar.misses < 10)
	local watcher = Bar.watch(wide)
	local cap = { t0 = (ctx and ctx.t0) or tick(), tracks = {} }
	Shot.cap = cap
	Glide.fire("shot", "shot start")
	if mode == "backup" then
		local ok, err = Backup.send(true)
		if not ok then
			Shot.cap = nil
			log("Backup press failed: " .. tostring(err))
			return
		end
	end
	local t0 = cap.t0
	local useBar = S.ShotRelease ~= "Timing" and Bar.selected() and S.BarAt > 0
	local track
	local hold, key, base = Shot.holdFor(sit, nil)
	local manual = false
	while tick() - t0 < S.MaxHold do
		RunService.Heartbeat:Wait()
		if mode == "manualKey" and ctx.kc and not UIS:IsKeyDown(ctx.kc) then
			manual = true
			break
		end
		if mode == "touch" and ctx.ended then
			manual = true
			break
		end
		track = Shot.pickTrack(cap)
		hold, key, base = Shot.holdFor(sit, track)
		if wide then hold = math.max(hold, 0.5) end
		local delta = Bar.step(watcher)
		if useBar and watcher.live then
			-- the bar is moving: let go when it reaches the learned point, or when it has stopped because it is full
			if delta and delta >= Bar.threshold() then break end
			if watcher.lastMove and tick() - watcher.lastMove > 0.25 then break end
		elseif tick() - t0 >= hold then
			break
		end
	end
	local held = tick() - t0
	if not manual then Shot.release(mode, ctx) end
	Shot.cap = nil
	Shot.stats.shots = Shot.stats.shots + 1
	local usedBar = useBar and watcher.live and not manual
	local barDelta = Bar.finish(watcher)
	Shot.lastType = Shot.nameOf(track, sit)
	Shot.lastRelease = manual and "you" or (usedBar and "bar" or "timing")
	if Rec.on then
		Rec.add("shot", string.format("type=%s key=%s situation=%s held=%.3f base=%.3f released by %s barDelta=%s", Shot.lastType,
			tostring(key), sit, held, base or 0, Shot.lastRelease, barDelta and string.format("%.3f", barDelta) or "-"))
	end
	task.spawn(Shot.evaluate, { snap = snap, sit = sit, key = key, track = track, base = base, held = held,
		usedBar = usedBar, barDelta = barDelta, manual = manual })
end
function Shot.run(mode, ctx)
	if Shot.busy then return end
	Shot.busy = true
	local ok, err = pcall(Shot.core, mode, ctx)
	if not ok then
		log("Shot error: " .. tostring(err))
		pcall(Shot.release, mode, ctx)
	end
	if mode == "remote" then
		if ctx then ctx.released = true end
		Shot.remoteCtx = nil
	end
	task.wait(0.15)
	Shot.busy = false
end

-- learns which on-screen button is the shoot button from your own shots: the button you held, then a release message
Shot.seenText = {}
function Shot.onMessage(res, tx)
	if Shot.hooked then return end
	local t = Input.lastTouch
	if Shot.busy or not t or not t.obj or not t.endT or tick() - t.endT > 1.2 or t.endT - t.t0 < 0.15 then return end
	local found = Input.findButton("Shoot")
	if found and Input.hits(found, t.pos) then return end
	S.ShootButtonPath = Input.pathOf(t.obj)
	Input.cache.Shoot = nil
	saveSoon()
	log("Shoot button learned from your shot: " .. S.ShootButtonPath)
	notify("Shoot button found", t.obj.Name, 3)
end
function Shot.watch()
	for d in pairs(Shot.labels) do
		if not d.Parent then
			Shot.labels[d] = nil
		else
			local tx = d.Text
			if tx ~= Shot.seenText[d] then
				Shot.seenText[d] = tx
				if tx ~= "" and visibleChain(d) and Shot.classify(tx) then Shot.onMessage(Shot.classify(tx), tx) end
			end
		end
	end
end

-- backup: JHub presses the game's shoot button itself (use it if holding the button yourself does not work)
function Backup.send(isDown)
	local btn = Input.findButton("Shoot")
	if not btn then return false, "shoot button not found: use Pick in the Shooting tab" end
	local c = btn.AbsolutePosition + btn.AbsoluteSize / 2
	local x = c.X
	local y = c.Y + (S.BackupInset and insetHeight() or 0)
	local m = S.BackupMethod
	if m == "touch" then
		if not VIM then return false, "no VirtualInputManager" end
		return pcall(function() VIM:SendTouchEvent(87, isDown and 0 or 2, x, y) end)
	elseif m == "mouse" then
		if not VIM then return false, "no VirtualInputManager" end
		return pcall(function() VIM:SendMouseButtonEvent(x, y, 0, isDown, game, 1) end)
	end
	if type(firesignal) ~= "function" then return false, "no firesignal" end
	return pcall(function() firesignal(isDown and btn.MouseButton1Down or btn.MouseButton1Up, x, y) end)
end

---------------------------------------------------------------------
-- GLIDES (dribble, dribble shot, gather step)
-- Three ways to push the character; Auto keeps the one that measurably moves you.
---------------------------------------------------------------------
local moveParams = RaycastParams.new()
moveParams.FilterType = Enum.RaycastFilterType.Exclude
moveParams.RespectCanCollide = true
Glide.token = 0
Glide.lastStart = {}
Glide.methods = { "Auto", "CFrame", "Input", "AttrBoost", "Velocity", "Impulse" }
Glide.chain = { "CFrame", "Input", "AttrBoost", "Velocity", "Impulse" }
Glide.input = nil
Glide.cur = 1
Glide.last = "no glide yet"
Glide.lastNote = 0
Glide.kinds = {
	dribble = { "DribbleGlide", "DribbleGlidePower", "DribbleGlideTime" },
	gather = { "GatherGlide", "GatherGlidePower", "GatherGlideTime" },
	shot = { "ShotGlide", "ShotGlidePower", "ShotGlideTime" },
}
-- a wall check that only counts big anchored parts (courts, walls, poles); the ball, effects and rigs never block you
function Glide.blocked(r, dir, dist)
	if not S.GlideStopAtWalls then return false end
	local ignore = { char() }
	if Ball.nearest then table.insert(ignore, Ball.nearest) end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then table.insert(ignore, p.Character) end
	end
	moveParams.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(r.Position, dir * (dist + 1.6), moveParams)
	if not hit then return false end
	local part = hit.Instance
	if not part.Anchored then return false end
	local s = part.Size
	if math.max(s.X, s.Y, s.Z) < 3 then return false end
	Speed.blockedBy = part.Name
	return true
end
-- after a glide: did it really move you? If not, Auto moves on to the next method
function Glide.judge(kind, method, startPos, dir, power, duration, fadeStart, baseVel, why)
	local r = hrp() or Mover.body()
	if not r then return end
	local moved = (r.Position - startPos):Dot(dir)
	local expected = power * duration * (2 / math.pi)
	local extra = moved - math.max(baseVel, 0) * duration
	local ratio = expected > 0 and extra / expected or 0
	Glide.last = string.format("%s (%s) via %s: moved %.1f of %.1f studs", kind, why or "?", method, extra, expected)
	log("Glide " .. Glide.last)
	Glide.fails = Glide.fails or 0
	if ratio >= 0.3 then
		Glide.fails = 0
		if tick() - Glide.lastNote > 10 then
			Glide.lastNote = tick()
			notify("Glide", "WORKS", 2)
		end
	else
		Glide.fails = Glide.fails + 1
		if S.GlideMethod == "Auto" then Glide.cur = Glide.cur % #Glide.chain + 1 end
		if tick() - Glide.lastNote > 6 then
			Glide.lastNote = tick()
			if Glide.fails >= #Glide.chain or S.GlideMethod ~= "Auto" then
				Glide.fails = 0
				notify("Glide", "DOESN'T WORK", 3)
			else
				notify("Glide", "not yet, trying another way", 2)
			end
		end
	end
end
function Glide.start(kind, power, duration, dirOverride)
	local r, h = Mover.body(), hum()
	power = power * (S.GlideSpeed or 1)
	if not r or not h or power <= 0 or duration <= 0 then return end
	local now = tick()
	-- one move plays several animations at once, so repeat triggers during the slide are ignored
	if now - (Glide.lastStart[kind] or 0) < duration * 0.6 then return end
	Glide.lastStart[kind] = now
	local intent = Mover.intent(h, r)
	local dir = flat(intent)
	-- a dribble move goes the way the move itself goes (to the side, back, across), not where the stick points
	if dirOverride and flat(dirOverride).Magnitude > 0.1 then dir = flat(dirOverride) end
	if dir.Magnitude < 0.1 then dir = flat(r.CFrame.LookVector) end
	if dir.Magnitude < 0.01 then return end
	dir = dir.Unit
	local method = S.GlideMethod
	if method == "Auto" then method = Glide.chain[Glide.cur] end
	-- a new glide replaces the running one instead of stacking speed
	Glide.token = Glide.token + 1
	local token = Glide.token
	local fadeStart = 1 - clamp(S.GlideFade, 0, 100) / 100
	local seen = hrp()
	local startPos = (seen or r).Position
	local baseVel = Mover.vel:Dot(dir)
	local why = Glide.why
	local walk = flat(intent) * Speed.gameWS
	if method == "Input" then
		Glide.input = { untilT = now + duration, scale = 1 + power / math.max(Speed.gameWS, 1), dir = dir, t0 = now, nextSend = 0 }
	end
	if method == "Impulse" then
		pcall(function() r:ApplyImpulse(dir * r.AssemblyMass * power) end)
	end
	local function restoreAttr()
		local c = char()
		if c and method == "AttrBoost" then
			c:SetAttribute("SpeedBoost", 0)
			c:SetAttribute("SpeedBoostTime", 0)
			c:SetAttribute("AccelerationBoost", 0)
		end
	end
	local startedAt = now
	local function frame(dt)
		-- the game ignores the stick while a dribble move is playing (CanMove is off): the glide starts when you can move again
		if method == "Input" and token == Glide.token then
			local c = char()
			if c and c:GetAttribute("CanMove") == false and tick() - startedAt < 1.5 then
				now = tick()
				if Glide.input then
					Glide.input.untilT = now + duration
					Glide.input.paused = true
				end
				return nil
			end
			if Glide.input then Glide.input.paused = false end
		end
		local p = (tick() - now) / duration
		if token ~= Glide.token or p >= 1 or not r.Parent or not JH.Running then
			restoreAttr()
			if token == Glide.token then
				task.delay(0.15, function()
					if token == Glide.token then pcall(Glide.judge, kind, method, startPos, dir, power, duration, fadeStart, baseVel, why) end
				end)
			end
			return "stop"
		end
		if method == "Impulse" then return nil end
		local factor = math.sin(math.pi * clamp(p, 0, 1))
		if method == "AttrBoost" then
			-- the game's own boost values: the same ones the server sets during its dribble moves
			local c = char()
			if c then
				c:SetAttribute("SpeedBoost", power * factor / math.max(Speed.gameWS, 1))
				c:SetAttribute("SpeedBoostTime", 0.25)
				c:SetAttribute("AccelerationBoost", 0.5)
			end
			return nil
		end
		if method == "Input" then
			local gi = Glide.input
			if not gi then return "stop" end
			gi.scale = 1 + power * factor / math.max(Speed.gameWS, 1)
			-- with the stick idle the game sends nothing, so the glide sends the heading itself
			local game = Mover.gameIntent()
			if (not game or game.Magnitude < 0.05) and tick() >= gi.nextSend then
				gi.nextSend = tick() + 0.05
				Mover.send(dir * gi.scale)
			end
			return nil
		end
		local step = power * factor * dt
		if Glide.blocked(r, dir, step) then return "stop" end
		if method == "Velocity" then
			local v = r.AssemblyLinearVelocity
			local t = walk + dir * (power * factor)
			r.AssemblyLinearVelocity = Vector3.new(t.X, v.Y, t.Z)
		else
			r.CFrame = r.CFrame + dir * step
			Mover.sync(r)
		end
		return nil
	end
	-- an error inside a glide is caught and shown instead of silently doing nothing
	local conn
	conn = RunService.Stepped:Connect(function(_, dt)
		local ok, res = pcall(frame, dt)
		if not ok then
			Glide.lastErr = tostring(res)
			log("Glide error: " .. Glide.lastErr)
			notify("Glide problem", Glide.lastErr, 5)
			conn:Disconnect()
		elseif res == "stop" then
			conn:Disconnect()
		end
	end)
end
function Glide.fire(kind, why, dir)
	local k = Glide.kinds[kind]
	if not k or not S[k[1]] then return end
	if S.GlideNeedBall and kind ~= "shot" and not Ball.holding then
		log("Glide " .. kind .. " skipped: you do not hold the ball")
		return
	end
	Glide.why = why or "?"
	Glide.start(kind, S[k[2]], S[k[3]], dir)
end
function Glide.test(kind)
	local k = Glide.kinds[kind]
	if not k then return end
	Glide.lastStart[kind] = 0
	Glide.why = "test button"
	Glide.start(kind, S[k[2]], S[k[3]])
end

---------------------------------------------------------------------
-- SPEED: speed boost and speed boost with ball
-- Runs on Stepped (right before physics, after the game's per-frame scripts). Channel Auto measures
-- your real speed with and without the boost and keeps the first channel that truly makes you faster.
---------------------------------------------------------------------
Speed.gameWS = 16
Speed.lastSet = nil
Speed.lastPos = nil
Speed.lastMove = nil
Speed.actual = 0
Speed.extra = 0
Speed.level = 0
Speed.rubberTimes = {}
Speed.lastRubberNote = 0
Speed.lastRubber = 0
Speed.test = nil
Speed.testing = false
Speed.src = "none"
Speed.blockedBy = "-"
Speed.channels = { "Auto", "Input", "AttrWS", "AttrBoost", "CFrame", "Velocity", "WalkSpeed", "GameValues" }
Speed.chain = { "CFrame", "Velocity", "WalkSpeed", "GameValues" }
Speed.inputScale = 1
Speed.probe = nil
Speed.methods = Speed.channels
Speed.minWS = 16
Speed.auto = { idx = 1, t = 0, d = 0, e = 0, w = 0, results = {}, locked = nil, lastDir = nil }
Speed.gv = { items = {}, found = 0, scanning = false, applied = false }
-- running = sprint pressed (key, or the game's on-screen sprint button), or the game itself raised your WalkSpeed a lot
function Speed.isRunning()
	local mode = S.RunDetect
	if mode == "Never" then return false end
	if mode == "Always" then return true end
	local c = char()
	if c and c:GetAttribute("Sprinting") == true then return true end
	if Input.sprintTouch or Input.held.Sprint then return true end
	local k = Input.keyCode(S.SprintKey)
	if k and UIS:IsKeyDown(k) then return true end
	if mode == "Sprint button" then return false end
	return Speed.gameWS >= Speed.minWS * 1.4 and Speed.gameWS - Speed.minWS >= 4
end
-- a level is a small step: level 0 is your normal speed, every level adds a little
Speed.PER_LEVEL = 0.75
-- only one boost applies at a time: with the ball it is the ball boost, without it running is the run boost, otherwise the walk boost
function Speed.pick()
	if Ball.holding then
		if S.BallSpeedOn then return "ball", S.BallAdd end
		return nil, 0
	end
	if Speed.isRunning() then
		if S.RunOn then return "run", S.RunAdd end
		return nil, 0
	end
	if S.SpeedOn then return "walk", S.SpeedAdd end
	return nil, 0
end
function Speed.extraNow()
	local kind, level = Speed.pick()
	Speed.kind = kind
	local extra = kind and level * Speed.PER_LEVEL or 0
	extra = clamp(extra, 0, S.SpeedCap)
	if S.AntiRubber and Speed.level > 0 then extra = extra / (1 + Speed.level) end
	return extra
end
-- the server keeps pulling you back: boost is cut automatically so you do not get flagged or stuck
function Speed.noteRubber()
	if workspace:FindFirstChild("ProxyCharacter") then return end
	local now = tick()
	Speed.lastRubber = now
	table.insert(Speed.rubberTimes, now)
	while #Speed.rubberTimes > 0 and now - Speed.rubberTimes[1] > 3 do table.remove(Speed.rubberTimes, 1) end
	if #Speed.rubberTimes >= 3 and S.AntiRubber then
		Speed.rubberTimes = {}
		Speed.level = math.min(Speed.level + 1, 3)
		if now - Speed.lastRubberNote > 10 then
			Speed.lastRubberNote = now
			notify("Speed boost", "The game keeps pulling you back, so the boost was lowered", 3)
		end
	end
end
function Speed.resetAuto()
	Speed.probe = nil
	Speed.rep = nil
	Speed.auto = { idx = 1, t = 0, d = 0, e = 0, w = 0, results = {}, locked = nil, lastDir = nil }
	Speed.gvRestore()
end

-- advanced: speed numbers the game itself uses (attributes, number values and config tables)
local SPEED_WORDS = { "speed", "sprint", "walkspeed", "runspeed" }
local SPEED_SKIP = { "anim", "fire", "reload", "cooldown", "rate", "turn", "jump", "swim", "climb", "shot", "pass" }
function Speed.gvAccept(name, v)
	if type(name) ~= "string" or type(v) ~= "number" or v < 3 or v > 150 then return false end
	local n = string.lower(name)
	return matchAny(n, SPEED_WORDS) and not matchAny(n, SPEED_SKIP)
end
function Speed.gvScan()
	local gv = Speed.gv
	if gv.scanning then return end
	gv.scanning = true
	gv.items = {}
	task.spawn(function()
		pcall(function()
			for _, inst in ipairs({ char(), LP, hum() }) do
				if inst then
					for k, v in pairs(inst:GetAttributes()) do
						if Speed.gvAccept(k, v) then table.insert(gv.items, { kind = "attr", inst = inst, key = k, orig = v, last = v }) end
					end
				end
			end
		end)
		for _, root in ipairs({ char(), LP }) do
			if root then
				pcall(function()
					for _, d in ipairs(root:GetDescendants()) do
						if (d:IsA("NumberValue") or d:IsA("IntValue")) and Speed.gvAccept(d.Name, d.Value) then
							table.insert(gv.items, { kind = "val", inst = d, orig = d.Value, last = d.Value })
						end
					end
				end)
			end
		end
		if type(getgc) == "function" then
			pcall(function()
				local list = getgc(true)
				for i, t in ipairs(list) do
					if type(t) == "table" and getmetatable(t) == nil then
						pcall(function()
							local count = 0
							for k, v in next, t do
								count = count + 1
								if count > 60 then break end
								if Speed.gvAccept(k, v) then
									table.insert(gv.items, { kind = "tbl", tbl = t, key = k, orig = v, last = v })
								end
							end
						end)
					end
					if i % 800 == 0 then task.wait() end
				end
			end)
		end
		gv.found = #gv.items
		gv.scanning = false
		log("Game speed values found: " .. gv.found)
	end)
end
function Speed.gvSet(ratio)
	local gv = Speed.gv
	if #gv.items == 0 and not gv.scanning then Speed.gvScan() end
	for _, it in ipairs(gv.items) do
		pcall(function()
			local cur
			if it.kind == "attr" then cur = it.inst:GetAttribute(it.key)
			elseif it.kind == "val" then cur = it.inst.Value
			else cur = rawget(it.tbl, it.key) end
			-- if the game changed it on its own (e.g. walking to sprinting), that is the new original
			if cur ~= it.last and type(cur) == "number" then it.orig = cur end
			local v = it.orig * ratio
			if it.kind == "attr" then it.inst:SetAttribute(it.key, v)
			elseif it.kind == "val" then it.inst.Value = v
			else rawset(it.tbl, it.key, v) end
			it.last = v
		end)
	end
	gv.applied = true
end
function Speed.gvRestore()
	local gv = Speed.gv
	if not gv.applied then return end
	for _, it in ipairs(gv.items) do
		pcall(function()
			if it.kind == "attr" then it.inst:SetAttribute(it.key, it.orig)
			elseif it.kind == "val" then it.inst.Value = it.orig
			else rawset(it.tbl, it.key, it.orig) end
			it.last = it.orig
		end)
	end
	gv.applied = false
end

-- Auto: the boost is applied from the very first frame. While you run steadily the real speed is checked, and a channel
-- that clearly does nothing is swapped for the next one. If none passes, the fastest one measured is kept.
-- when the game sends its own stick signal, the ways of going faster are tried one after another and each is measured
Speed.gameChain = { "CFrame", "Input", "AttrWS", "AttrBoost" }
Speed.gameChainNames = {
	Input = "a bigger stick signal", AttrWS = "the character's WalkSpeed value", AttrBoost = "the character's SpeedBoost value", CFrame = "moving the character",
}
function Speed.inputStep(dt, intent, extra, frameMove)
	local p = Speed.probe
	if not p then
		p = { t = 0, d = 0, base = nil, idx = 1, locked = nil, results = {} }
		Speed.probe = p
	end
	if extra <= 0 or intent.Magnitude < 0.5 then
		p.t, p.d = 0, 0
		return p.locked or Speed.gameChain[p.idx], extra
	end
	local dir = intent.Unit
	if p.lastDir and dir:Dot(p.lastDir) < 0.7 then p.t, p.d = 0, 0 end
	p.lastDir = dir
	p.t = p.t + dt
	p.d = p.d + frameMove
	if not p.base then
		-- the first half second of a run is not boosted, so the gain can be measured
		if p.t >= 0.5 then
			-- a character that is not really moving gives nothing to compare with
			if p.d / p.t >= 1.5 then p.base = p.d / p.t end
			p.t, p.d = 0, 0
		end
		return Speed.gameChain[p.idx], 0
	end
	if p.locked then return p.locked, extra end
	local m = Speed.gameChain[p.idx]
	if p.t >= 1.2 then
		local v = p.d / p.t
		p.results[m] = v
		log(string.format("Speed through %s: %.1f studs/s, %.1f without", Speed.gameChainNames[m], v, p.base))
		if v >= p.base * 1.2 then
			p.locked = m
			notify("Speed boost", "WORKS", 3)
		else
			p.idx = p.idx + 1
			p.t, p.d = 0, 0
			if p.idx > #Speed.gameChain then
				p.locked = "Input"
				notify("Speed boost", "DOESN'T WORK", 4)
			else
				notify("Speed boost", "not yet, trying another way", 2)
			end
			m = p.locked or Speed.gameChain[p.idx]
		end
	end
	return m, extra
end
-- tells you once whether the boost really made you faster; it never switches the boost off
Speed.normal = nil
function Speed.report(dt, intent, extra, move)
	local p = Speed.rep
	if not p then
		p = { t = 0, d = 0, noted = false }
		Speed.rep = p
	end
	if intent.Magnitude < 0.5 then
		p.t, p.d = 0, 0
		return
	end
	local dir = intent.Unit
	if p.lastDir and dir:Dot(p.lastDir) < 0.7 then p.t, p.d = 0, 0 end
	p.lastDir = dir
	p.t = p.t + dt
	p.d = p.d + move
	if extra <= 0 then
		if p.t >= 0.5 then
			local v = p.d / p.t
			Speed.normal = Speed.normal and (Speed.normal * 0.7 + v * 0.3) or v
			p.t, p.d = 0, 0
		end
		return
	end
	if p.t >= 1.0 and not p.noted then
		p.noted = true
		local v = p.d / p.t
		local normal = Speed.normal or Speed.gameWS * 0.7
		log(string.format("Speed boost: %.1f studs/s (normal %.1f, boost +%.1f)", v, normal, extra))
		if v >= normal + 0.4 * extra then
			notify("Speed boost", "WORKS", 3)
		else
			notify("Speed boost", "DOESN'T WORK", 4)
		end
	end
end
function Speed.autoStep(dt, intent, extra, frameMove)
	local a = Speed.auto
	if a.locked then return a.locked, extra end
	local m = Speed.chain[a.idx]
	if extra <= 0 or intent.Magnitude < 0.5 then return m, extra end
	local dir = intent.Unit
	if a.lastDir and dir:Dot(a.lastDir) < 0.7 then a.t, a.d, a.e, a.w = 0, 0, 0, 0 end
	a.lastDir = dir
	a.t = a.t + dt
	a.d = a.d + frameMove
	a.e = a.e + extra * dt
	a.w = a.w + Speed.gameWS * dt
	if a.t >= 0.7 then
		local mag = math.min(1, intent.Magnitude)
		local v = a.d / a.t
		local need = (a.w / a.t) * mag + 0.35 * (a.e / a.t) * mag
		a.results[m] = v
		if v >= need then
			a.locked = m
			log(string.format("Speed channel %s works: %.1f studs/s (needed %.1f)", m, v, need))
			notify("Speed boost", "WORKS", 3)
		else
			a.idx = a.idx + 1
			a.t, a.d, a.e, a.w = 0, 0, 0, 0
			if a.idx > #Speed.chain then
				local best, bv
				for ch, sp in pairs(a.results) do
					if not bv or sp > bv then best, bv = ch, sp end
				end
				a.locked = best or "CFrame"
				log("No speed channel passed; kept " .. a.locked)
				notify("Speed boost", "DOESN'T WORK", 4)
			else
				m = Speed.chain[a.idx]
			end
		end
	end
	return m, extra
end
function Speed.step(dt)
	Speed.inputScale = 1
	local h, r = hum(), Mover.body()
	if not h or not r or h.Health <= 0 or dt <= 0 or dt > 0.25 then return end
	local test = Speed.test
	local intent, src
	if test then intent, src = test.dir, "test" else intent, src = Mover.intent(h, r) end
	Speed.src = src
	Speed.mag = intent.Magnitude
	if test then h:Move(test.dir, false) end
	-- track the game's own WalkSpeed (anything that is not the value we set last frame)
	local ws = h.WalkSpeed
	if ws ~= Speed.lastSet and ws > 1 then
		Speed.gameWS = ws
		Speed.minWS = math.min(ws, Speed.minWS)
	end
	-- some games keep the real speed in a character attribute instead
	local c = char()
	local aw = c and c:GetAttribute("WalkSpeed")
	if type(aw) == "number" and aw > 1 and aw ~= Speed.lastAttrWS then Speed.gameWS = aw end
	Speed.minWS = math.min(Speed.gameWS, Speed.minWS * (1 + 0.01 * dt))
	local frameMove = 0
	local seenMove = nil
	local seenNow = hrp()
	if seenNow then
		if Speed.seenLast and Speed.lastPos then seenMove = flat(seenNow.Position - Speed.seenLast).Magnitude end
		Speed.seenLast = seenNow.Position
	end
	if Speed.lastPos then
		local delta = flat(r.Position - Speed.lastPos)
		frameMove = delta.Magnitude
		Mover.vel = Mover.vel * 0.8 + (delta / dt) * 0.2
		Speed.actual = Speed.actual + (frameMove / dt - Speed.actual) * 0.2
		-- rubber-band detection: a big jump backwards while we were pushing forward
		if Speed.lastMove and (r.Position - Speed.lastPos):Dot(Speed.lastMove.Unit) < -2.5 then Speed.noteRubber() end
	end
	if Speed.level > 0 and tick() - Speed.lastRubber > 8 then
		Speed.level = Speed.level - 1
		Speed.lastRubber = tick()
	end
	Speed.lastPos = r.Position
	local method, extra
	if test then
		method, extra = test.method, test.extra
	else
		method, extra = S.SpeedChannel, Speed.extraNow()
		if method == "Auto" and Mover.gameDirT and workspace:FindFirstChild("ProxyCharacter") then
			method = "CFrame"
			Speed.report(dt, intent, extra, seenMove or frameMove)
		elseif method == "Auto" and Mover.gameDirT then
			method, extra = Speed.inputStep(dt, intent, extra, seenMove or frameMove)
		elseif method == "Auto" then
			method, extra = Speed.autoStep(dt, intent, extra, seenMove or frameMove)
		end
	end
	local active = extra > 0 and intent.Magnitude > 0.05 and method ~= "none"
	-- values written into the character are put back as soon as that way of boosting stops
	local cc = char()
	if cc and Speed.lastAttrWS and (method ~= "AttrWS" or not active) then
		cc:SetAttribute("WalkSpeed", Speed.gameWS)
		Speed.lastAttrWS = nil
	end
	if cc and Speed.attrBoostOn and (method ~= "AttrBoost" or not active) then
		cc:SetAttribute("SpeedBoost", 0)
		cc:SetAttribute("SpeedBoostTime", 0)
		Speed.attrBoostOn = false
	end
	Speed.lastMove = active and intent or nil
	Speed.extra = active and extra or 0
	if not active or method ~= "GameValues" then Speed.gvRestore() end
	if not active then
		if Speed.lastSet then
			h.WalkSpeed = Speed.gameWS
			Speed.lastSet = nil
		end
		return
	end
	if method == "Input" then
		Speed.inputScale = 1 + extra / math.max(Speed.gameWS, 1)
		return
	end
	if method == "AttrWS" and cc then
		local want = Speed.gameWS + extra
		cc:SetAttribute("WalkSpeed", want)
		Speed.lastAttrWS = want
		return
	end
	if method == "AttrBoost" and cc then
		cc:SetAttribute("SpeedBoost", extra / math.max(Speed.gameWS, 1))
		cc:SetAttribute("SpeedBoostTime", 0.25)
		Speed.attrBoostOn = true
		return
	end
	if method == "WalkSpeed" then
		local want = Speed.gameWS + extra
		if h.WalkSpeed ~= want then h.WalkSpeed = want end
		Speed.lastSet = want
		return
	end
	if Speed.lastSet then
		h.WalkSpeed = Speed.gameWS
		Speed.lastSet = nil
	end
	if method == "GameValues" then
		Speed.gvSet((Speed.gameWS + extra) / math.max(Speed.gameWS, 1))
	elseif method == "Velocity" then
		local v = r.AssemblyLinearVelocity
		local t = intent * (Speed.gameWS + extra)
		r.AssemblyLinearVelocity = Vector3.new(t.X, v.Y, t.Z)
	else
		local step = intent * extra * dt
		if step.Magnitude > 0 and not Glide.blocked(r, intent.Unit, step.Magnitude) then
			r.CFrame = r.CFrame + step
			Mover.sync(r)
		end
	end
end
-- walks the character a short way with each channel and keeps the one that really made you faster
function Speed.autoPick()
	if Speed.testing then return end
	local h, r = hum(), hrp()
	if not h or not r then
		notify("Speed test", "No character found.", 2)
		return
	end
	Speed.testing = true
	notify("Speed test", "Stand in open space. Your character will walk a few steps.", 4)
	local look = flat(cam().CFrame.LookVector)
	if look.Magnitude < 0.01 then look = flat(r.CFrame.LookVector) end
	look = look.Unit
	local function trial(method, extra, dir)
		Speed.test = { method = method, extra = extra, dir = dir }
		local start = r.Position
		local last = start
		local rubber = 0
		local t0 = tick()
		while tick() - t0 < 0.7 do
			RunService.Heartbeat:Wait()
			local pos = r.Position
			if (pos - last):Dot(dir) < -2.5 then rubber = rubber + 1 end
			last = pos
		end
		local moved = (r.Position - start):Dot(dir)
		Speed.test = nil
		if method == "WalkSpeed" then h.WalkSpeed = Speed.gameWS end
		task.wait(0.4)
		return math.abs(moved), rubber
	end
	local ok, err = pcall(function()
		local base = trial("none", 0, look)
		base = math.max(base, 1)
		local bestMethod, bestGain = nil, 1.2
		local lines = {}
		for i, m in ipairs({ "CFrame", "Velocity", "WalkSpeed" }) do
			local moved, rubber = trial(m, 20, (i % 2 == 1) and -look or look)
			local gain = moved / base
			table.insert(lines, string.format("%s x%.2f%s", m, gain, rubber > 1 and " (pulled back)" or ""))
			if rubber <= 1 and gain > bestGain then bestMethod, bestGain = m, gain end
		end
		log("Speed test: " .. table.concat(lines, ", "))
		if bestMethod then
			UI.set("SpeedChannel", bestMethod)
			Speed.resetAuto()
			notify("Speed test", "Best channel: " .. bestMethod .. "  (" .. table.concat(lines, ", ") .. ")", 6)
		else
			notify("Speed test", "No channel made you faster in this walk test. Try Auto while running, it also tries the game's own speed values. " .. table.concat(lines, ", "), 7)
		end
	end)
	Speed.test = nil
	Speed.testing = false
	if not ok then log("Speed test error: " .. tostring(err)) end
end


-- BALL MAGNET, PULL TO ME: the game owns the ball, so a client-side move does nothing. Instead the body is put on the ball for one tick
-- (what the server sees) and put back before the next frame is drawn (what you see)
-- someone has the ball when the character carries the game's Basketball value
function Feat.hasBall()
	local ch = char()
	local af = ch and ch:FindFirstChild("Attributes")
	local bv = af and af:FindFirstChild("Basketball")
	if bv and bv.Value ~= nil then return true end
	return Ball.holding == true
end
function Feat.hop(b)
	local r = Mover.body()
	if not r or not b or Feat.hopping then return false end
	Feat.hopping = true
	local orig = r.CFrame
	local lastSet = nil
	local finished = false
	local function show()
		if finished or not lastSet then return end
		pcall(function()
			local moved = r.Position - lastSet
			if moved.Magnitude < 6 then orig = orig + moved end
			r.CFrame = r.CFrame + (orig.Position - r.Position)
			lastSet = nil
		end)
	end
	local bound = pcall(function() RunService:BindToRenderStep("JHHopShow", 0, show) end)
	task.spawn(function()
		local minFrames = math.max(1, math.floor(S.MagnetFrames or 1))
		local t0 = tick()
		local n = 0
		while tick() - t0 < 1.2 do
			RunService.Heartbeat:Wait()
			n = n + 1
			pcall(function()
				local p = b.Position
				local flat = Vector3.new(r.Position.X - p.X, 0, r.Position.Z - p.Z)
				if flat.Magnitude < 0.1 then flat = Vector3.new(0, 0, 1) end
				local spot = Vector3.new(p.X, r.Position.Y, p.Z) + flat.Unit * 1.2
				r.CFrame = r.CFrame + (spot - r.Position)
				lastSet = r.Position
				Mover.sync(r)
			end)
			if n >= minFrames and Feat.hasBall() then
				for _ = 1, 4 do
					RunService.Heartbeat:Wait()
					pcall(function()
						r.CFrame = r.CFrame + (Vector3.new(b.Position.X, r.Position.Y, b.Position.Z) - r.Position)
						lastSet = r.Position
					end)
				end
				break
			end
		end
		local done = false
		local function back()
			if done then return end
			done = true
			finished = true
			pcall(function()
				r.CFrame = r.CFrame + (orig.Position - r.Position)
				r.AssemblyLinearVelocity = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
				Mover.sync(r)
			end)
			if bound then pcall(function() RunService:UnbindFromRenderStep("JHHopShow") end) end
			Feat.hopping = false
		end
		local okb = pcall(function() RunService:BindToRenderStep("JHHop", 0, function() back() RunService:UnbindFromRenderStep("JHHop") end) end)
		if not okb then
			RunService.RenderStepped:Wait()
			back()
		else
			task.delay(0.2, back)
		end
	end)
	return true
end

-- VISUALS (only you see these): logos over your head, a cartoon costume, maxed overall, coins and badges
do
	local V = {}
	Feat.V = V
	V.orig, V.tmpl, V.extras, V.logoImg, V.saved = {}, {}, {}, {}, {}
	V.isExtra = {}
	V.labels = { overall = {}, coins = {}, badges = {} }
	V.LOGOS = {
		Owner = { text = "OWNER", color = Color3.fromRGB(255, 196, 40), words = { "owner" } },
		YouTube = { text = "YOUTUBE", color = Color3.fromRGB(255, 0, 0), words = { "youtube", "yt" } },
		Twitch = { text = "TWITCH", color = Color3.fromRGB(145, 70, 255), words = { "twitch" } },
		TikTok = { text = "TIKTOK", color = Color3.fromRGB(30, 30, 30), words = { "tiktok" } },
		Dev = { text = "DEV", color = Color3.fromRGB(60, 140, 255), words = { "dev", "developer" } },
	}
	V.LOGO_NAMES = { "Owner", "YouTube", "Twitch", "TikTok", "Dev" }
	local function C(r, g, b) return Color3.fromRGB(r, g, b) end
	V.MASCOTS = {
		SpongeBob = { skin = C(255, 226, 60), shirt = C(255, 255, 255), pants = C(130, 85, 40), eyes = true, label = "SpongeBob" },
		Patrick = { skin = C(255, 140, 165), shirt = C(255, 140, 165), pants = C(70, 170, 90), eyes = true, label = "Patrick" },
		Squidward = { skin = C(120, 200, 200), shirt = C(120, 200, 200), pants = C(110, 90, 60), nose = C(120, 200, 200), label = "Squidward" },
		Jeffy = { skin = C(255, 205, 150), shirt = C(255, 215, 40), pants = C(70, 100, 190), label = "Jeffy" },
		IShowSpeed = { skin = C(150, 100, 70), shirt = C(220, 30, 40), pants = C(25, 25, 25), label = "IShowSpeed" },
		MrBeast = { skin = C(235, 190, 150), shirt = C(50, 120, 230), pants = C(40, 45, 70), label = "MrBeast" },
		Banana = { skin = C(255, 225, 53), shirt = C(255, 225, 53), pants = C(255, 225, 53), hat = C(110, 75, 30), label = "Banana" },
		Curry = { skin = C(150, 100, 72), shirt = C(255, 199, 44), pants = C(29, 66, 138), label = "Curry 30" },
		LeBron = { skin = C(110, 70, 50), shirt = C(85, 37, 130), pants = C(85, 37, 130), label = "LeBron" },
		Kyrie = { skin = C(140, 95, 70), shirt = C(0, 83, 188), pants = C(0, 83, 188), label = "Kyrie 11" },
		Wemby = { skin = C(170, 120, 90), shirt = C(20, 20, 20), pants = C(195, 202, 206), label = "Wemby 1" },
		Mickey = { skin = C(20, 20, 20), shirt = C(20, 20, 20), pants = C(215, 30, 30), hands = C(255, 255, 255), ears = C(20, 20, 20), label = "Mickey" },
	}
	V.MASCOT_NAMES = { "SpongeBob", "Patrick", "Squidward", "Jeffy", "IShowSpeed", "MrBeast", "Banana", "Curry", "LeBron", "Kyrie", "Wemby", "Mickey" }

	local function hasWord(name, w)
		return string.find(string.lower(name), "%f[%a]" .. w .. "%f[%A]") ~= nil
	end
	-- the game's own logo pictures, when it has them
	function V.findLogo(key)
		if V.logoImg[key] ~= nil then return V.logoImg[key] or nil end
		local def = V.LOGOS[key]
		local found
		local roots = { ReplicatedStorage, LP:FindFirstChild("PlayerGui"), game:GetService("StarterGui"), workspace }
		local n = 0
		for _, root in ipairs(roots) do
			if root and not found then
				for _, d in ipairs(root:GetDescendants()) do
					n = n + 1
					if n % 1500 == 0 then task.wait() end
					if d:IsA("ImageLabel") or d:IsA("ImageButton") or d:IsA("Decal") or d:IsA("Texture") then
						local img = d:IsA("Decal") and d.Texture or (d:IsA("Texture") and d.Texture or d.Image)
						if type(img) == "string" and img ~= "" then
							for _, w in ipairs(def.words) do
								if hasWord(d.Name, w) or (d.Parent and hasWord(d.Parent.Name, w)) then
									found = img
									break
								end
							end
						end
						if found then break end
					end
				end
			end
		end
		V.logoImg[key] = found or false
		return found
	end
	function V.clearLogo()
		if V.logoGui then pcall(function() V.logoGui:Destroy() end) end
		V.logoGui, V.logoKey, V.logoChar = nil, nil, nil
	end
	function V.applyLogo(key)
		V.clearLogo()
		local c = char()
		local head = c and (c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart"))
		local def = V.LOGOS[key]
		if not head or not def then return end
		local g = Instance.new("BillboardGui")
		g.Name = "JHLogo"
		g.Size = UDim2.new(0, 110, 0, 40)
		g.StudsOffset = Vector3.new(0, 3.6, 0)
		g.AlwaysOnTop = true
		g.Adornee = head
		local img = V.logoImg[key]
		if img then
			local il = Instance.new("ImageLabel")
			il.BackgroundTransparency = 1
			il.Size = UDim2.new(1, 0, 1, 0)
			il.ScaleType = Enum.ScaleType.Fit
			il.Image = img
			il.Parent = g
		else
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 1, 0)
			f.BackgroundColor3 = def.color
			f.BackgroundTransparency = 0.1
			f.Parent = g
			local cr = Instance.new("UICorner")
			cr.CornerRadius = UDim.new(0, 10)
			cr.Parent = f
			local t = Instance.new("TextLabel")
			t.BackgroundTransparency = 1
			t.Size = UDim2.new(1, 0, 1, 0)
			t.Font = Enum.Font.GothamBlack
			t.TextScaled = true
			t.TextColor3 = Color3.new(1, 1, 1)
			t.Text = def.text
			t.Parent = f
		end
		g.Parent = head
		V.logoGui, V.logoKey, V.logoChar = g, key, c
	end

	-- costume
	local function recolor(part, color)
		if V.orig[part] == nil then V.orig[part] = part.Color end
		part.Color = color
	end
	function V.clearMascot()
		for part, col in pairs(V.orig) do pcall(function() if part.Parent then part.Color = col end end) end
		V.orig = {}
		for inst, kv in pairs(V.tmpl) do pcall(function() inst[kv[1]] = kv[2] end) end
		V.tmpl = {}
		for _, e in ipairs(V.extras) do pcall(function() e:Destroy() end) end
		V.extras = {}
		V.isExtra = {}
		V.mascotKey, V.mascotChar = nil, nil
	end
	local function extra(c, parent, size, color, shape, offset)
		local p = Instance.new("Part")
		p.Size = size
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.CanCollide, p.CanQuery, p.CanTouch, p.Massless = false, false, false, true
		if shape then pcall(function() p.Shape = shape end) end
		p.CFrame = parent.CFrame * offset
		p.Parent = c
		local w = Instance.new("WeldConstraint")
		w.Part0, w.Part1 = p, parent
		w.Parent = p
		V.extras[#V.extras + 1] = p
		return p
	end
	local LIMBS = { head = { "Head" }, torso = { "UpperTorso", "Torso" }, larm = { "LeftUpperArm", "Left Arm" }, rarm = { "RightUpperArm", "Right Arm" },
		lleg = { "LeftUpperLeg", "Left Leg" }, rleg = { "RightUpperLeg", "Right Leg" } }
	local function limbOf(c, key)
		for _, n in ipairs(LIMBS[key]) do
			local p = c:FindFirstChild(n)
			if p then return p end
		end
	end
	local BALL, CYL = Enum.PartType.Ball, Enum.PartType.Cylinder
	local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
	function V.hideOriginal(c)
		for _, d in ipairs(c:GetDescendants()) do
			if (d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and not V.isExtra[d]) or d:IsA("Decal") then
				if V.tmpl[d] == nil then V.tmpl[d] = { "Transparency", d.Transparency } end
				d.Transparency = 1
			end
		end
	end
	-- a whole character built from parts that follow your body (your own screen only)
	function V.build(c, key)
		local def = V.BUILDS[key]
		local head = limbOf(c, "head")
		if not def or not head or not limbOf(c, "torso") then return false end
		local r15 = c:FindFirstChild("UpperTorso") ~= nil
		local k = head.Size.Y / (r15 and 1.2 or 1)
		local function add(limb, shape, sx, sy, sz, ox, oy, oz, color, mat, rot)
			local lp = limbOf(c, limb)
			if not lp then return nil end
			local dy = 0
			if r15 and limb ~= "head" then dy = (limb == "torso") and -0.2 or -0.4 end
			local part = extra(c, lp, Vector3.new(sx, sy, sz) * k, color, shape, CFrame.new(ox * k, (oy + dy) * k, oz * k) * (rot or CFrame.new()))
			if mat then part.Material = mat end
			V.isExtra[part] = true
			return part
		end
		local function eye(limb, x, y, z, size, iris)
			local e = add(limb, BALL, size, size, size * 0.6, x, y, z, WHITE)
			if e then
				add(limb, BALL, size * 0.5, size * 0.5, size * 0.3, x, y, z - size * 0.28, iris or BLACK)
				add(limb, BALL, size * 0.22, size * 0.22, size * 0.2, x, y, z - size * 0.4, BLACK)
			end
		end
		local function num(text, color, limb)
			local lp = limbOf(c, limb or "torso")
			if not lp then return end
			for _, side in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
				local sg = Instance.new("SurfaceGui")
				sg.Face = side
				sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
				sg.PixelsPerStud = 40
				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Size = UDim2.new(1, 0, 1, 0)
				t.Font = Enum.Font.GothamBlack
				t.TextScaled = true
				t.TextColor3 = color
				t.Text = text
				t.Parent = sg
				sg.Parent = V.torsoPart[1]
				V.extras[#V.extras + 1] = sg
			end
		end
		V.torsoPart = {}
		local env = { add = add, eye = eye, num = num, BALL = BALL, CYL = CYL, WHITE = WHITE, BLACK = BLACK }
		local ok, err = pcall(def, env)
		if not ok then pcall(log, "Costume build: " .. tostring(err)) end
		return ok
	end
	-- the common body: head, torso with shorts, arms and legs, then each character adds its own details
	local function body(a, o)
		local skin, shirt, pants, hand = o.skin, o.shirt, o.pants, o.hand or o.skin
		local hs = o.headSize or 1.3
		if o.headBlock then a.add("head", nil, hs * 1.7, hs * 1.2, hs, 0, 0.1, 0, skin) else a.add("head", a.BALL, hs * 1.4, hs * 1.4, hs * 1.4, 0, 0.1, 0, skin) end
		local tw, th = o.tw or 2.1, o.th or 2.1
		V.torsoPart[1] = a.add("torso", nil, tw, th, 1.1, 0, 0, 0, shirt)
		if o.pantsTop ~= false then a.add("torso", nil, tw + 0.05, th * 0.32, 1.15, 0, -th * 0.34, 0, pants) end
		local aw = o.aw or 1.05
		for _, s in ipairs({ { "larm", -1 }, { "rarm", 1 } }) do
			a.add(s[1], nil, aw, 1.2, aw, 0, 0.45, 0, o.sleeve or shirt)
			a.add(s[1], nil, aw * 0.95, 0.9, aw * 0.95, 0, -0.55, 0, skin)
			a.add(s[1], a.BALL, aw * 1.15, aw * 1.15, aw * 1.15, 0, -1.05, 0, hand)
		end
		local lw = o.lw or 1.05
		for _, s in ipairs({ "lleg", "rleg" }) do
			a.add(s, nil, lw, 1.3, lw, 0, 0.35, 0, pants)
			a.add(s, nil, lw * 0.95, 0.8, lw * 0.95, 0, -0.55, 0, o.leg or skin)
			a.add(s, nil, lw * 1.1, 0.45, lw * 1.9, 0, -0.95, -0.35, o.shoe or Color3.fromRGB(30, 30, 30))
		end
	end
	local function C(r, g, b) return Color3.fromRGB(r, g, b) end
	local function mouth(a, y, z, w, col)
		a.add("head", nil, w, 0.1, 0.1, 0, y, z, col or BLACK)
		a.add("head", nil, 0.1, 0.12, 0.1, -w / 2, y + 0.06, z, col or BLACK)
		a.add("head", nil, 0.1, 0.12, 0.1, w / 2, y + 0.06, z, col or BLACK)
	end
	V.BUILDS = {
		SpongeBob = function(a)
			local Y = C(255, 226, 60)
			body(a, { skin = Y, shirt = WHITE, pants = C(130, 85, 40), sleeve = WHITE, aw = 0.55, lw = 0.55, leg = WHITE, shoe = BLACK, headBlock = true, headSize = 1.6, tw = 2.4, th = 1.8, hand = Y })
			a.add("torso", nil, 2.5, 0.25, 1.2, 0, 0.6, 0, WHITE)
			a.add("torso", nil, 0.3, 1.0, 0.15, 0, 0.2, -0.6, C(215, 30, 30))
			a.add("head", nil, 2.7, 0.35, 1.4, 0, -0.35, 0, Y)
			a.eye("head", -0.45, 0.35, -0.7, 0.9, C(90, 170, 255))
			a.eye("head", 0.45, 0.35, -0.7, 0.9, C(90, 170, 255))
			a.add("head", nil, 0.35, 0.4, 0.1, -0.15, -0.55, -0.72, WHITE)
			a.add("head", nil, 0.35, 0.4, 0.1, 0.15, -0.55, -0.72, WHITE)
			mouth(a, -0.35, -0.72, 1.1)
			a.add("head", a.BALL, 0.4, 0.4, 0.1, -0.95, -0.25, -0.7, C(255, 160, 140))
			a.add("head", a.BALL, 0.4, 0.4, 0.1, 0.95, -0.25, -0.7, C(255, 160, 140))
			a.add("head", a.BALL, 0.25, 0.25, 0.1, -0.9, 0.9, -0.65, C(215, 175, 30))
			a.add("head", a.BALL, 0.2, 0.2, 0.1, 0.8, 0.6, -0.65, C(215, 175, 30))
		end,
		Patrick = function(a)
			local Pk = C(255, 140, 165)
			body(a, { skin = Pk, shirt = Pk, pants = C(70, 170, 90), aw = 1.1, lw = 1.1, shoe = Pk, headSize = 1.5, tw = 2.4, th = 2.2, pantsTop = true })
			a.add("head", nil, 0.9, 1.1, 0.9, 0, 0.9, 0, Pk, nil, CFrame.Angles(0, 0, math.rad(45)))
			a.eye("head", -0.4, 0.15, -0.95, 0.55)
			a.eye("head", 0.4, 0.15, -0.95, 0.55)
			mouth(a, -0.45, -0.98, 0.7)
			a.add("torso", a.BALL, 0.5, 0.5, 0.1, 0.5, 0.7, -0.6, C(180, 40, 150))
			a.add("torso", a.BALL, 0.4, 0.4, 0.1, -0.6, 0.3, -0.6, C(180, 40, 150))
			a.add("torso", a.BALL, 0.45, 0.45, 0.1, 0.6, -0.8, -0.6, C(190, 60, 160))
		end,
		Squidward = function(a)
			local T = C(120, 200, 200)
			body(a, { skin = T, shirt = C(170, 225, 225), pants = C(110, 90, 60), aw = 0.8, lw = 0.85, shoe = T, headBlock = false, headSize = 1.5, tw = 1.9 })
			a.add("head", a.BALL, 1.5, 2.2, 1.5, 0, 0.5, 0.1, T)
			a.add("head", nil, 0.7, 0.7, 1.7, 0, -0.1, -1.1, T)
			a.add("head", nil, 1.9, 0.4, 0.4, 0, 0.2, -0.85, C(80, 150, 150))
			for _, sx in ipairs({ -0.45, 0.45 }) do
				a.add("head", a.BALL, 0.6, 0.6, 0.35, sx, 0.4, -0.8, C(250, 250, 200))
				a.add("head", a.BALL, 0.25, 0.25, 0.2, sx, 0.3, -1.0, BLACK)
				a.add("head", nil, 0.7, 0.28, 0.45, sx, 0.62, -0.85, T)
			end
			a.add("head", a.BALL, 0.6, 0.4, 0.4, -0.5, 0.95, 0.05, C(80, 150, 150))
			mouth(a, -0.85, -0.7, 0.8, C(80, 110, 110))
		end,
		Jeffy = function(a)
			local S = C(255, 205, 150)
			body(a, { skin = S, shirt = C(255, 215, 40), pants = C(70, 100, 190), sleeve = C(255, 215, 40), tw = 1.9, th = 1.7, headBlock = false, headSize = 1.7, shoe = WHITE })
			a.add("head", a.BALL, 0.7, 0.35, 1.7, 0, 1.0, 0.05, C(60, 40, 25))
			a.eye("head", -0.45, 0.25, -1.0, 0.8, C(90, 70, 40))
			a.eye("head", 0.45, 0.25, -1.0, 0.8, C(90, 70, 40))
			a.add("head", nil, 0.9, 0.25, 0.15, 0, -0.45, -1.1, C(120, 40, 40))
			a.add("head", nil, 0.5, 0.25, 0.1, 0.25, -0.65, -1.1, C(230, 100, 120))
			a.add("torso", nil, 0.9, 0.25, 0.15, 0, 0.5, -0.6, C(255, 255, 255))
		end,
		IShowSpeed = function(a)
			local D = C(150, 100, 70)
			body(a, { skin = D, shirt = C(220, 30, 40), pants = C(25, 25, 25), sleeve = C(220, 30, 40), headSize = 1.35, shoe = WHITE })
			a.add("head", nil, 1.85, 0.7, 1.6, 0, 0.85, 0, C(20, 20, 20))
			a.add("head", nil, 1.7, 0.35, 0.2, 0, 0.15, -0.8, C(20, 20, 20))
			a.eye("head", -0.35, 0.05, -0.85, 0.5)
			a.eye("head", 0.35, 0.05, -0.85, 0.5)
			a.add("head", nil, 1.2, 0.4, 0.2, 0, -0.55, -0.75, C(30, 25, 20))
			mouth(a, -0.45, -0.88, 0.7, WHITE)
			a.add("torso", nil, 1.6, 0.35, 0.15, 0, 0.5, -0.6, WHITE)
		end,
		MrBeast = function(a)
			local L = C(235, 190, 150)
			body(a, { skin = L, shirt = C(50, 120, 230), pants = C(40, 45, 70), sleeve = C(50, 120, 230), tw = 2.3, aw = 1.15, headSize = 1.35, shoe = WHITE })
			a.add("head", nil, 1.9, 0.55, 1.65, 0, 0.9, 0, C(60, 40, 30))
			a.eye("head", -0.35, 0.1, -0.85, 0.5, C(80, 120, 160))
			a.eye("head", 0.35, 0.1, -0.85, 0.5, C(80, 120, 160))
			a.add("head", nil, 1.1, 0.5, 0.2, 0, -0.5, -0.78, C(110, 80, 60))
			mouth(a, -0.4, -0.92, 0.6, WHITE)
			a.add("torso", nil, 1.0, 0.3, 0.15, 0, 0.55, -0.6, C(255, 215, 40))
		end,
		Banana = function(a)
			local Y = C(255, 225, 53)
			a.add("head", a.BALL, 1.7, 1.9, 1.5, 0, 0.1, 0, Y)
			a.add("head", nil, 0.5, 0.5, 0.5, 0, 1.15, 0, C(110, 75, 30))
			a.add("torso", nil, 2.4, 2.1, 1.4, 0, 0, 0, Y)
			a.add("torso", a.BALL, 2.6, 2.6, 1.5, 0, -0.1, 0, Y)
			for _, s in ipairs({ "larm", "rarm" }) do
				a.add(s, nil, 0.7, 2.0, 0.7, 0, 0, 0, Y)
			end
			for _, s in ipairs({ "lleg", "rleg" }) do
				a.add(s, nil, 0.8, 2.0, 0.8, 0, 0, 0, Y)
				a.add(s, nil, 0.9, 0.4, 1.4, 0, -1.0, -0.25, C(140, 100, 50))
			end
			a.eye("head", -0.4, 0.45, -0.7, 0.6)
			a.eye("head", 0.4, 0.45, -0.7, 0.6)
			mouth(a, -0.2, -0.76, 0.8)
			a.add("head", a.BALL, 0.25, 0.25, 0.1, -0.7, 0.9, -0.6, C(200, 160, 40))
		end,
		Curry = function(a)
			local Sk = C(150, 100, 72)
			body(a, { skin = Sk, shirt = C(255, 199, 44), pants = C(29, 66, 138), sleeve = C(255, 199, 44), shoe = C(255, 199, 44), headSize = 1.3 })
			a.add("head", nil, 1.5, 0.45, 1.3, 0, 0.75, 0, C(20, 15, 12))
			a.eye("head", -0.35, 0.05, -0.8, 0.42)
			a.eye("head", 0.35, 0.05, -0.8, 0.42)
			mouth(a, -0.4, -0.88, 0.5, C(90, 40, 30))
			a.num("30", C(29, 66, 138))
			a.add("torso", nil, 2.15, 0.15, 1.15, 0, 0.95, 0, C(29, 66, 138))
		end,
		LeBron = function(a)
			local Sk = C(110, 70, 50)
			body(a, { skin = Sk, shirt = C(85, 37, 130), pants = C(85, 37, 130), sleeve = C(85, 37, 130), shoe = C(255, 199, 44), tw = 2.3, aw = 1.15, headSize = 1.3 })
			a.add("head", nil, 1.45, 0.3, 1.3, 0, 0.75, 0, C(20, 15, 12))
			a.add("head", nil, 1.7, 0.25, 1.5, 0, 0.6, 0, C(255, 199, 44))
			a.eye("head", -0.35, 0.05, -0.8, 0.42)
			a.eye("head", 0.35, 0.05, -0.8, 0.42)
			a.add("head", nil, 1.2, 0.5, 0.25, 0, -0.5, -0.75, C(25, 20, 18))
			mouth(a, -0.35, -0.9, 0.5, WHITE)
			a.num("23", C(255, 199, 44))
			a.add("torso", nil, 2.35, 0.15, 1.15, 0, 0.95, 0, C(255, 199, 44))
		end,
		Kyrie = function(a)
			local Sk = C(140, 95, 70)
			body(a, { skin = Sk, shirt = C(0, 83, 188), pants = C(0, 83, 188), sleeve = C(0, 83, 188), shoe = C(255, 255, 255), headSize = 1.3 })
			a.add("head", nil, 1.5, 0.4, 1.3, 0, 0.75, 0, C(20, 15, 12))
			a.eye("head", -0.35, 0.05, -0.8, 0.42)
			a.eye("head", 0.35, 0.05, -0.8, 0.42)
			a.add("head", nil, 1.0, 0.3, 0.2, 0, -0.5, -0.78, C(25, 20, 18))
			mouth(a, -0.4, -0.9, 0.5, WHITE)
			a.num("11", WHITE)
		end,
		Wemby = function(a)
			local Sk = C(170, 120, 90)
			body(a, { skin = Sk, shirt = C(20, 20, 20), pants = C(195, 202, 206), sleeve = C(20, 20, 20), shoe = WHITE, aw = 1.0, lw = 1.0, headSize = 1.3 })
			a.add("head", nil, 1.4, 0.35, 1.25, 0, 0.75, 0, C(25, 20, 18))
			a.eye("head", -0.35, 0.05, -0.8, 0.42)
			a.eye("head", 0.35, 0.05, -0.8, 0.42)
			mouth(a, -0.4, -0.9, 0.5, C(90, 40, 30))
			a.num("1", C(195, 202, 206))
		end,
		Mickey = function(a)
			local K = C(20, 20, 20)
			a.add("head", a.BALL, 1.8, 1.8, 1.8, 0, 0.1, 0, K)
			a.add("head", a.BALL, 1.5, 1.2, 0.35, 0, -0.2, -0.78, C(255, 222, 190))
			for _, sx in ipairs({ -1.0, 1.0 }) do a.add("head", CYL, 0.3, 1.1, 1.1, sx, 1.0, 0, K, nil, CFrame.Angles(0, 0, math.rad(90))) end
			a.eye("head", -0.3, 0.3, -0.92, 0.5)
			a.eye("head", 0.3, 0.3, -0.92, 0.5)
			a.add("head", a.BALL, 0.4, 0.3, 0.3, 0, -0.05, -1.0, K)
			mouth(a, -0.45, -0.95, 0.8, C(150, 30, 30))
			body(a, { skin = K, shirt = K, pants = C(215, 30, 30), sleeve = K, hand = WHITE, shoe = C(255, 200, 40), headSize = 0.1 })
			a.add("torso", a.BALL, 0.3, 0.3, 0.1, -0.4, -0.5, -0.65, WHITE)
			a.add("torso", a.BALL, 0.3, 0.3, 0.1, 0.4, -0.5, -0.65, WHITE)
		end,
	}
	function V.applyMascot(key)
		V.clearMascot()
		local def = V.MASCOTS[key]
		local c = char()
		if not def or not c then return end
		for _, d in ipairs(c:GetDescendants()) do
			if d:IsA("Shirt") then V.tmpl[d] = { "ShirtTemplate", d.ShirtTemplate }; d.ShirtTemplate = "" end
			if d:IsA("Pants") then V.tmpl[d] = { "PantsTemplate", d.PantsTemplate }; d.PantsTemplate = "" end
			if d:IsA("ShirtGraphic") then V.tmpl[d] = { "Graphic", d.Graphic }; d.Graphic = "" end
			if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and not d:FindFirstAncestorOfClass("Accessory") then
				local n = d.Name
				if n == "Head" then recolor(d, def.skin)
				elseif n == "LowerTorso" then recolor(d, def.pants)
				elseif string.find(n, "Torso", 1, true) then recolor(d, def.shirt)
				elseif string.find(n, "Hand", 1, true) then recolor(d, def.hands or def.skin)
				elseif string.find(n, "Arm", 1, true) then recolor(d, def.skin)
				elseif string.find(n, "Leg", 1, true) or string.find(n, "Foot", 1, true) then recolor(d, def.pants) end
			end
		end
		local built = false
		if V.BUILDS[key] then
			V.hideOriginal(c)
			built = V.build(c, key)
			if not built then
				for inst, kv in pairs(V.tmpl) do
					if kv[1] == "Transparency" then pcall(function() inst.Transparency = kv[2] end) V.tmpl[inst] = nil end
				end
			end
		end
		local head = c:FindFirstChild("Head")
		if head and not built then
			if def.eyes then
				for _, sx in ipairs({ -0.3, 0.3 }) do
					local e = extra(c, head, Vector3.new(0.55, 0.55, 0.3), Color3.new(1, 1, 1), Enum.PartType.Ball, CFrame.new(sx, 0.2, -0.5))
					extra(c, e, Vector3.new(0.2, 0.2, 0.2), Color3.new(0, 0, 0), Enum.PartType.Ball, CFrame.new(0, 0, -0.1))
				end
			end
			if def.nose then extra(c, head, Vector3.new(0.45, 0.45, 1.2), def.nose, Enum.PartType.Cylinder, CFrame.new(0, -0.1, -0.9) * CFrame.Angles(0, math.rad(90), 0)) end
			if def.ears then
				for _, sx in ipairs({ -0.75, 0.75 }) do extra(c, head, Vector3.new(0.9, 0.9, 0.3), def.ears, Enum.PartType.Ball, CFrame.new(sx, 0.85, 0)) end
			end
			if def.hat then extra(c, head, Vector3.new(0.5, 0.5, 0.5), def.hat, nil, CFrame.new(0, 0.85, 0)) end
		end
		V.mascotKey, V.mascotChar = key, c
	end

	-- maxed overall, coins and badges: values and the labels that show them
	local KEYS = {
		overall = { "overall", "ovr" },
		coins = { "coins", "coin", "cash", "money", "currency" },
		badges = { "badge", "badges" },
	}
	function V.scanLabels()
		if V.scanning then return end
		V.scanning = true
		task.spawn(function()
			local gui = LP:FindFirstChild("PlayerGui")
			if gui then
				local n = 0
				local found = { overall = {}, coins = {}, badges = {} }
				for _, d in ipairs(gui:GetDescendants()) do
					n = n + 1
					if n % 1500 == 0 then task.wait() end
					if d:IsA("TextLabel") or d:IsA("TextButton") then
						local names = { d.Name, d.Parent and d.Parent.Name or "", d.Parent and d.Parent.Parent and d.Parent.Parent.Name or "" }
						for kind, words in pairs(KEYS) do
							for _, nm in ipairs(names) do
								local low = string.lower(nm)
								for _, w in ipairs(words) do
									if string.find(low, w, 1, true) then found[kind][d] = true end
								end
							end
						end
					end
				end
				V.labels = found
			end
			V.scanning = false
			V.scanT = tick()
		end)
	end
	local function setLabels(kind, fn)
		for d in pairs(V.labels[kind]) do
			if d.Parent then
				pcall(function()
					local nt = fn(d.Text)
					if nt and nt ~= d.Text then d.Text = nt end
				end)
			end
		end
	end
	local function remember(inst, name)
		local key = inst
		V.saved[key] = V.saved[key] or {}
		if V.saved[key][name] == nil then V.saved[key][name] = inst:GetAttribute(name) or false end
	end
	function V.maxStep()
		local any = S.MaxOverall or S.MaxCoins or S.MaxBadges
		if not any then return end
		if (not V.scanT or tick() - V.scanT > 8) and not V.scanning then V.scanStarted = tick(); V.scanLabels() end
		local c = char()
		if S.MaxOverall then
			for _, o in ipairs({ LP, c }) do
				if o and o:GetAttribute("Overall") ~= nil and o:GetAttribute("Overall") ~= 99 then remember(o, "Overall"); o:SetAttribute("Overall", 99) end
			end
			setLabels("overall", function(t) if string.find(t, "%d") then return (string.gsub(t, "%d+", "99", 1)) end end)
		end
		if S.MaxCoins then
			local big = 999999999
			local ls = LP:FindFirstChild("leaderstats")
			if ls then
				for _, v in ipairs(ls:GetChildren()) do
					local low = string.lower(v.Name)
					if (v:IsA("IntValue") or v:IsA("NumberValue")) and (string.find(low, "coin", 1, true) or string.find(low, "cash", 1, true) or string.find(low, "money", 1, true)) then
						V.saved[v] = V.saved[v] or { Value = v.Value }
						v.Value = big
					end
				end
			end
			for k, val in pairs(LP:GetAttributes()) do
				local low = string.lower(k)
				if type(val) == "number" and (string.find(low, "coin", 1, true) or string.find(low, "cash", 1, true) or string.find(low, "money", 1, true)) and val ~= big then
					remember(LP, k)
					LP:SetAttribute(k, big)
				end
			end
			setLabels("coins", function(t) if string.find(t, "%d") then return (string.gsub(t, "[%d,%.]+", "999,999,999", 1)) end end)
		end
		if S.MaxBadges then
			local maxp = (c and c:GetAttribute("MaxBadgePoints")) or 109
			if c and c:GetAttribute("BadgePoints") ~= nil and c:GetAttribute("BadgePoints") ~= maxp then
				remember(c, "BadgePoints")
				c:SetAttribute("BadgePoints", maxp)
			end
			setLabels("badges", function(t)
				if string.find(t, "%d+%s*/%s*%d+") then return (string.gsub(t, "%d+(%s*/%s*)%d+", tostring(maxp) .. "%1" .. tostring(maxp), 1)) end
				if string.find(t, "^%s*%d+%s*$") then return tostring(maxp) end
			end)
		end
	end
	function V.restoreStats()
		for inst, kv in pairs(V.saved) do
			pcall(function()
				for name, val in pairs(kv) do
					if name == "Value" then inst.Value = val else inst:SetAttribute(name, val ~= false and val or nil) end
				end
			end)
		end
		V.saved = {}
	end

	function V.step()
		local now = tick()
		if V.t and now - V.t < 0.5 then return end
		V.t = now
		local c = char()
		pcall(V.stepVisuals, c)
		pcall(V.maxStep)
		if not (S.MaxOverall or S.MaxCoins or S.MaxBadges) and next(V.saved) then pcall(V.restoreStats) end
	end
	function V.stepVisuals(c)
		-- logo
		if S.LogoOn then
			local key = S.Logo
			if V.LOGOS[key] and (V.logoKey ~= key or V.logoChar ~= c or not (V.logoGui and V.logoGui.Parent)) then
				if V.logoImg[key] == nil then
					if not V.finding then
						V.finding = true
						task.spawn(function() pcall(V.findLogo, key) V.finding = false end)
					end
				else
					V.applyLogo(key)
				end
			end
		elseif V.logoGui then
			V.clearLogo()
		end
		-- costume
		if S.MascotOn then
			local key = S.Mascot
			if V.MASCOTS[key] and (V.mascotKey ~= key or V.mascotChar ~= c) then V.applyMascot(key) end
		elseif V.mascotKey then
			V.clearMascot()
		end
	end
	function V.cleanup()
		pcall(V.clearLogo)
		pcall(V.clearMascot)
		pcall(V.restoreStats)
	end
end

---------------------------------------------------------------------
-- RECORDER: writes down what happens in the game so it can be copied and sent for debugging
---------------------------------------------------------------------
Rec.on = false
Rec.lines = {}
Rec.bytes = 0
Rec.cap = 400000
Rec.t0 = 0
Rec.conns = {}
Rec.hooked = false
Rec.labelText = {}
Rec.attrCache = {}
Rec.header = {}
Rec.repl, Rec.replIn = 0, 0
Rec.lastMoveKey, Rec.lastMoveT = "", 0
Rec.lastBallKey, Rec.lastBallT = "", 0
Rec.lastPosKey, Rec.lastPosT = "", 0
Rec.btnSet = {}
Rec.noChar = 0
function Rec.add(kind, text)
	if not Rec.on then return end
	local line = string.format("%.2f %s %s", tick() - Rec.t0, kind, text)
	Rec.lines[#Rec.lines + 1] = line
	Rec.bytes = Rec.bytes + #line + 1
	-- a ring buffer: the newest events always survive
	while Rec.bytes > Rec.cap and #Rec.lines > 1 do
		Rec.bytes = Rec.bytes - #table.remove(Rec.lines, 1) - 1
	end
end
function Rec.short(inst)
	local parts, o = {}, inst
	while o and o ~= game and #parts < 3 do
		table.insert(parts, 1, o.Name)
		o = o.Parent
	end
	return table.concat(parts, "/")
end
function Rec.fmt(v, depth)
	local t = typeof(v)
	if t == "string" then return '"' .. string.sub(v, 1, 300) .. '"' end
	if t == "number" then return string.format("%.4g", v) end
	if t == "boolean" or t == "nil" then return tostring(v) end
	if t == "Instance" then
		local ok, s = pcall(Rec.short, v)
		return ok and ("<" .. s .. ">") or "<instance>"
	end
	if t == "NumberRange" then return string.format("NR(%.4g,%.4g)", v.Min, v.Max) end
	if t == "NumberSequence" then
		local k = {}
		for _, kp in ipairs(v.Keypoints) do k[#k + 1] = string.format("%.3g:%.3g", kp.Time, kp.Value) end
		return "NS(" .. table.concat(k, " ") .. ")"
	end
	if t == "Vector3" then return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z) end
	if t == "Vector2" then return string.format("V2(%.1f,%.1f)", v.X, v.Y) end
	if t == "CFrame" then return string.format("CF(%.1f,%.1f,%.1f)", v.Position.X, v.Position.Y, v.Position.Z) end
	if t == "table" then
		if (depth or 0) >= 2 then return "{...}" end
		local parts, n = {}, 0
		for k, val in pairs(v) do
			n = n + 1
			if n > 8 then
				parts[#parts + 1] = "..."
				break
			end
			parts[#parts + 1] = tostring(k) .. "=" .. Rec.fmt(val, (depth or 0) + 1)
		end
		return "{" .. table.concat(parts, ",") .. "}"
	end
	return t
end
function Rec.fmtArgs(args)
	local out = {}
	for i = 1, math.min(args.n, 8) do out[i] = Rec.fmt(args[i], 0) end
	if args.n > 8 then out[#out + 1] = "..." end
	return table.concat(out, ", ")
end
-- what a touch landed on: the path, class and label of the button under the finger
function Rec.guiAt(pos)
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return "-" end
	local inset = insetHeight()
	for _, y in ipairs({ pos.Y, pos.Y - inset }) do
		local ok, list = pcall(function() return pg:GetGuiObjectsAtPosition(pos.X, y) end)
		if ok and list and #list > 0 then
			local pick
			for _, g in ipairs(list) do
				if g:IsA("GuiButton") and not g:IsDescendantOf(gui) then
					pick = g
					break
				end
			end
			pick = pick or list[1]
			return string.format("%s [%s %q]", Input.pathOf(pick), pick.ClassName, Input.btnText(pick))
		end
	end
	return "(no gui)"
end
function Rec.input(kind, i)
	local t = i.UserInputType
	if t == TOUCH or t == MB1 then
		Rec.add("touch", string.format("%s at %.0f,%.0f on %s", kind, i.Position.X, i.Position.Y, Rec.guiAt(i.Position)))
	elseif t == KEYBOARD then
		Rec.add("key", tostring(i.KeyCode.Name) .. " " .. kind)
	end
end
Rec.spy = {}
-- which script made the call: a game script, or something running in the executor
function Rec.callerOf()
	if type(getcallingscript) ~= "function" then return nil end
	local ok, sc = pcall(getcallingscript)
	if not ok or not sc then return nil end
	local ok2, path = pcall(function() return Rec.short(sc) end)
	return ok2 and path or tostring(sc)
end
function Rec.spyNote(name, kind, argsText, note, caller)
	local e = Rec.spy[name]
	if not e then
		e = { sent = 0, exec = 0, held = 0, boosted = 0, recv = 0 }
		Rec.spy[name] = e
	end
	if kind == "recv" then
		e.recv = e.recv + 1
	else
		e.sent = e.sent + 1
		if note and string.find(note, "executor", 1, true) then e.exec = e.exec + 1 end
		if note and string.find(note, "held back", 1, true) then e.held = e.held + 1 end
		if note and string.find(note, "boosted", 1, true) then e.boosted = e.boosted + 1 end
		if caller then e.caller = caller end
	end
	e.first = e.first or argsText
	e.last = argsText
end
function Rec.remote(inst, method, args, note, caller)
	if not Rec.on then return end
	local ok, name = pcall(function() return inst.Name end)
	if ok then pcall(Rec.spyNote, name, "send", Rec.fmtArgs(args), note, caller) end
	-- the position stream and the movement stick would drown everything else, so they are summarised
	if ok and name == "Replication" then
		Rec.repl = Rec.repl + 1
		return
	end
	if ok and name == "MoveDirection" then
		local v = args[1]
		local key = typeof(v) == "Vector3" and string.format("%.1f,%.1f", v.X, v.Z) or "?"
		if key == Rec.lastMoveKey and tick() - Rec.lastMoveT < 1 then return end
		Rec.lastMoveKey, Rec.lastMoveT = key, tick()
	end
	local path = "?"
	pcall(function() path = Rec.short(inst) end)
	Rec.add("send", string.format("%s %s(%s)%s%s", path, method, Rec.fmtArgs(args), note and (" [" .. note .. "]") or "",
		caller and (" from " .. caller) or ""))
end
-- what the game sends to the server (shots, moves, purchases) is only visible through a namecall hook
local function nameOf(o) return o.Name end
-- JHub's own chunk name, so its own functions and writes are not mistaken for another script's
Rec.ownSrc = nil
pcall(function() Rec.ownSrc = debug.info(Rec.noteWrite or nameOf, "s") end)
function Rec.fromUs()
	if not Rec.ownSrc then return false end
	for lvl = 2, 5 do
		local ok, src = pcall(debug.info, lvl, "s")
		if not ok or src == nil then break end
		if src == Rec.ownSrc then return true end
	end
	return false
end
Rec.writes = {}
Rec.WATCHED = { CFrame = true, Position = true, Velocity = true, AssemblyLinearVelocity = true, AssemblyAngularVelocity = true, WalkSpeed = true,
	JumpPower = true, Anchored = true, MaxForce = true, VectorVelocity = true }
-- property writes from scripts in the executor, summed up once a second
function Rec.noteWrite(inst, key, value)
	if not Rec.on then return end
	local ok, mine = pcall(function()
		local c = char()
		return c and (inst == c or inst:IsDescendantOf(c))
	end)
	if not ok or not mine then return end
	local id = Rec.short(inst) .. "." .. tostring(key)
	local w = Rec.writes[id]
	if not w then
		w = { n = 0 }
		Rec.writes[id] = w
	end
	w.n = w.n + 1
	w.last = value
end
function Rec.flushWrites()
	for id, w in pairs(Rec.writes) do
		Rec.add("write", string.format("an executor script set %s x%d, last value %s", id, w.n, Rec.fmt(w.last, 0)))
	end
	Rec.writes = {}
end
function Rec.hookWrites()
	if Rec.hookedWrites or type(hookmetamethod) ~= "function" then return end
	Rec.hookedWrites = true
	local wrap = type(newcclosure) == "function" and newcclosure or function(f) return f end
	local oldNI
	local ok = pcall(function()
		oldNI = hookmetamethod(game, "__newindex", wrap(function(self, key, value)
			if Rec.on and Rec.WATCHED[key] and JH.Running and type(checkcaller) == "function" and checkcaller() and not Rec.fromUs() then
				task.defer(Rec.noteWrite, self, key, value)
			end
			return oldNI(self, key, value)
		end))
	end)
	if not ok then Rec.hookedWrites = false end
end
-- other scripts: what runs every frame and which of the game's functions they listen to, with the words inside those functions
Rec.seenFuncs = {}
function Rec.funcInfo(f)
	local src, line, name = "?", 0, ""
	pcall(function()
		src = debug.info(f, "s") or "?"
		line = debug.info(f, "l") or 0
		name = debug.info(f, "n") or ""
	end)
	return src, line, name
end
function Rec.constantsOf(f)
	local out = {}
	local getc = (debug and debug.getconstants) or getconstants
	if type(getc) ~= "function" then return out end
	local ok, list = pcall(getc, f)
	if not ok or type(list) ~= "table" then return out end
	for _, v in pairs(list) do
		if type(v) == "string" and #v >= 3 and #v <= 40 and not string.find(v, "[%c]") and #out < 60 then out[#out + 1] = v end
	end
	return out
end
function Rec.scanConnections()
	if type(getconnections) ~= "function" then return end
	local signals = {
		{ "Heartbeat", RunService.Heartbeat }, { "Stepped", RunService.Stepped }, { "RenderStepped", RunService.RenderStepped },
		{ "InputBegan", UIS.InputBegan }, { "InputEnded", UIS.InputEnded },
	}
	for _, sg in ipairs(signals) do
		local ok, list = pcall(getconnections, sg[2])
		if ok and type(list) == "table" then
			for _, conn in ipairs(list) do
				local f
				pcall(function() f = conn.Function end)
				if type(f) == "function" then
					local id = tostring(f)
					if not Rec.seenFuncs[id] then
						Rec.seenFuncs[id] = true
						local src, line, name = Rec.funcInfo(f)
						-- JHub's own functions and the game's own scripts are not interesting here
						if src ~= Rec.ownSrc and not string.find(src, "JHubGlass", 1, true) and not string.find(src, "Players.", 1, true) and not string.find(src, "ReplicatedStorage", 1, true) then
							local consts = Rec.constantsOf(f)
							Rec.add("script", string.format("%s listener %s line %d %s | words: %s", sg[1], string.sub(src, 1, 80), line, name,
								string.sub(table.concat(consts, ", "), 1, 400)))
						end
					end
				end
			end
		end
	end
end
-- menus other scripts draw (they live outside the game's own interface)
Rec.seenGuis = {}
function Rec.scanGuis()
	local roots = {}
	pcall(function() if type(gethui) == "function" then roots[#roots + 1] = gethui() end end)
	pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
	for _, root in ipairs(roots) do
		local ok, kids = pcall(function() return root:GetChildren() end)
		if ok then
			for _, g in ipairs(kids) do
				if g.Name ~= "JHubGlass" and not Rec.seenGuis[g] then
					Rec.seenGuis[g] = true
					local texts = {}
					pcall(function()
						for _, d in ipairs(g:GetDescendants()) do
							if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" and #texts < 80 then texts[#texts + 1] = string.sub(d.Text, 1, 30) end
						end
					end)
					Rec.add("script", string.format("interface found: %s (%s) texts: %s", g.Name, g.ClassName, string.sub(table.concat(texts, " | "), 1, 700)))
				end
			end
		end
	end
end
function Rec.scanLoop()
	while Rec.on and JH.Running do
		pcall(Rec.scanConnections)
		pcall(Rec.scanGuis)
		task.wait(12)
	end
end
function Rec.hook()
	if Rec.hooked or type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then return end
	Rec.hooked = true
	Shot.hooked = true
	local wrap = type(newcclosure) == "function" and newcclosure or function(f) return f end
	local old
	old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
		local method = getnamecallmethod()
		if Rec.on and method == "SetAttribute" and JH.Running and type(checkcaller) == "function" and checkcaller() and not Rec.fromUs() then
			local args = table.pack(...)
			task.defer(Rec.noteWrite, self, "attribute " .. tostring(args[1]), args[2])
		end
		if JH.Running and (method == "FireServer" or method == "InvokeServer") then
			local fromExec = type(checkcaller) == "function" and checkcaller()
			local mine = Mover.selfFire or Shot.selfFire
			if fromExec and not mine then
				-- another script running in the executor: only written down, never changed
				if Rec.on then
					local okn2, name2 = pcall(nameOf, self)
					if not (okn2 and name2 == "Replication") then task.defer(Rec.remote, self, method, table.pack(...), "sent by an executor script", Rec.callerOf()) end
				end
			end
			if not fromExec and not mine then
				-- the game's own shoot signal is where Auto Green starts and where a Tap is turned into a hold
				if method == "FireServer" then
					local okn, name = pcall(nameOf, self)
					if okn and name == "Shoot" then
						local args = table.pack(...)
						local okd, drop = pcall(Shot.onShootCall, args)
						if okd and drop then
							if Rec.on then task.defer(Rec.remote, self, method, args, "held back", Rec.callerOf()) end
							return
						end
					elseif okn and name == "MoveDirection" then
						local v = ...
						if typeof(v) == "Vector3" then
							Mover.gameDir, Mover.gameDirT = v, tick()
							local okc, s = pcall(Mover.outScale)
							if okc and s > 1.001 and v.Magnitude > 0.05 then
								if Rec.on then task.defer(Rec.remote, self, method, table.pack(v * s), string.format("boosted x%.2f", s)) end
								return old(self, v * s, select(2, ...))
							end
						end
					elseif okn and name == "Dribble" then
						task.defer(Mover.onDribble, table.pack(...))
					end
				end
				if Rec.on then task.defer(Rec.remote, self, method, table.pack(...), nil, Rec.callerOf()) end
			end
		end
		return old(self, ...)
	end))
end
-- and what the server sends back
function Rec.connectRemotes()
	local function watch(d)
		if d:IsA("RemoteEvent") then
			table.insert(Rec.conns, d.OnClientEvent:Connect(function(...)
				if not Rec.on then return end
				if d.Name == "Replication" then
					Rec.replIn = Rec.replIn + 1
					return
				end
				local txt = Rec.fmtArgs(table.pack(...))
				pcall(Rec.spyNote, d.Name, "recv", txt)
				Rec.add("recv", Rec.short(d) .. "(" .. txt .. ")")
			end))
		end
	end
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do watch(d) end
	table.insert(Rec.conns, ReplicatedStorage.DescendantAdded:Connect(watch))
end
function Rec.pollLabels()
	local n = 0
	for d in pairs(Shot.labels) do
		if d.Parent then
			local tx = d.Text
			if tx ~= Rec.labelText[d] then
				Rec.labelText[d] = tx
				-- timers and scores change constantly and are not interesting
				if tx ~= "" and n < 12 and not string.match(tx, "^[%d%.:,%s%%/]+$") and not string.find(tx, " FPS", 1, true) and visibleChain(d) then
					n = n + 1
					Rec.add("text", Rec.short(d) .. " = " .. string.format("%q", string.sub(tx, 1, 80)))
				end
			end
		end
	end
end
function Rec.pollAttrs()
	local function check(prefix, inst)
		if not inst then return end
		for k, v in pairs(inst:GetAttributes()) do
			local key = prefix .. k
			if Rec.attrCache[key] ~= v then
				Rec.add("attr", string.format("%s %s -> %s", key, tostring(Rec.attrCache[key]), tostring(v)))
				Rec.attrCache[key] = v
			end
		end
	end
	check("char.", char())
	check("player.", LP)
	local h = hum()
	if h then
		for _, prop in ipairs({ "WalkSpeed", "JumpPower", "JumpHeight", "Health", "HipHeight" }) do
			local ok, v = pcall(function() return h[prop] end)
			if ok and type(v) == "number" and Rec.attrCache["hum." .. prop] ~= v then
				Rec.add("attr", string.format("hum.%s %s -> %s", prop, tostring(Rec.attrCache["hum." .. prop]), tostring(v)))
				Rec.attrCache["hum." .. prop] = v
			end
		end
	end
end
-- the movers inside the character: whatever a script changes to push you around shows up here
function Rec.pollMovers()
	local r = hrp()
	if not r then return end
	local out = {}
	for _, ch in ipairs(r:GetChildren()) do
		local ok, txt = pcall(function()
			if ch:IsA("BodyVelocity") then return string.format("%s velocity=%.1f,%.1f,%.1f maxForce=%.0f", ch.Name, ch.Velocity.X, ch.Velocity.Y, ch.Velocity.Z, ch.MaxForce.X) end
			if ch:IsA("BodyPosition") then return string.format("%s position=%.1f,%.1f,%.1f maxForce=%.0f", ch.Name, ch.Position.X, ch.Position.Y, ch.Position.Z, ch.MaxForce.X) end
			if ch:IsA("BodyGyro") then return string.format("%s maxTorque=%.0f", ch.Name, ch.MaxTorque.X) end
			if ch:IsA("LinearVelocity") then return string.format("%s linear=%.1f,%.1f,%.1f", ch.Name, ch.VectorVelocity.X, ch.VectorVelocity.Y, ch.VectorVelocity.Z) end
			return nil
		end)
		if ok and txt then out[#out + 1] = txt end
	end
	local key = table.concat(out, " | ")
	if key ~= "" and (key ~= Rec.lastMovers or tick() - (Rec.lastMoversT or 0) > 2) then
		Rec.lastMovers, Rec.lastMoversT = key, tick()
		Rec.add("body", key)
	end
	local c = char()
	if c and (r.Anchored ~= Rec.lastAnchored) then
		Rec.lastAnchored = r.Anchored
		Rec.add("body", "root anchored=" .. tostring(r.Anchored))
	end
end
function Rec.watchCharacter()
	local c = char()
	if not c then return end
	table.insert(Rec.conns, c.DescendantAdded:Connect(function(d)
		if Rec.on then Rec.add("char", "added " .. d.ClassName .. " " .. Rec.short(d)) end
	end))
	table.insert(Rec.conns, c.DescendantRemoving:Connect(function(d)
		if Rec.on then Rec.add("char", "removed " .. d.ClassName .. " " .. Rec.short(d)) end
	end))
end
function Rec.sampleBall()
	local r, b = hrp(), Ball.nearest
	-- only changes are written, plus a reminder every few seconds
	local key = tostring(Ball.holding) .. tostring(Ball.source)
	if key == Rec.lastBallKey and tick() - Rec.lastBallT < 4 then return end
	Rec.lastBallKey, Rec.lastBallT = key, tick()
	if b and b.Parent and r then
		Rec.add("ball", string.format("pos=%.1f,%.1f,%.1f dist=%.1f holding=%s via %s parts=%d", b.Position.X, b.Position.Y,
			b.Position.Z, (b.Position - r.Position).Magnitude, tostring(Ball.holding), tostring(Ball.source), Ball.count()))
	else
		Rec.add("ball", "holding=" .. tostring(Ball.holding) .. " via " .. tostring(Ball.source) .. " parts=" .. Ball.count())
	end
end
-- buttons that appear or disappear (the offence and defence button sets swap when the ball changes hands)
function Rec.pollButtons()
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return end
	local now = {}
	for _, d in ipairs(pg:GetDescendants()) do
		if d:IsA("GuiButton") and not d:IsDescendantOf(gui) and visibleChain(d) then now[Input.pathOf(d)] = true end
	end
	for p in pairs(now) do
		if not Rec.btnSet[p] then Rec.add("gui", "button shown: " .. p) end
	end
	for p in pairs(Rec.btnSet) do
		if not now[p] then Rec.add("gui", "button hidden: " .. p) end
	end
	Rec.btnSet = now
end
function Rec.sampleLoop()
	local lastAttr, lastBall, lastFlush, lastBtn = 0, 0, 0, 0
	while Rec.on and JH.Running do
		local c = char()
		local r = hrp() or (c and c.PrimaryPart)
		local h = hum()
		if r then
			local v = r.AssemblyLinearVelocity
			local state = "?"
			if h then pcall(function() state = tostring(h:GetState()) end) end
			local key = string.format("%.1f,%.1f,%.1f|%s", r.Position.X, r.Position.Y, r.Position.Z, state)
			-- a standing character is written once a second, a moving one every sample
			if key ~= Rec.lastPosKey or tick() - Rec.lastPosT > 1 then
				Rec.lastPosKey, Rec.lastPosT = key, tick()
				local px = workspace:FindFirstChild("ProxyCharacter")
				Rec.add("move", string.format("pos=%.1f,%.1f,%.1f proxy=%s vel=%.1f ws=%s intent=%.2f(%s) boost=%.1f ball=%s state=%s",
					r.Position.X, r.Position.Y, r.Position.Z, px and string.format("%.1f,%.1f", px.Position.X, px.Position.Z) or "none",
					math.sqrt(v.X * v.X + v.Z * v.Z), h and string.format("%.1f", h.WalkSpeed) or "none",
					Speed.mag or 0, tostring(Speed.src), Speed.extra, tostring(Ball.holding), state))
			end
		elseif tick() - Rec.noChar > 3 then
			Rec.noChar = tick()
			Rec.add("move", "no character found (LP.Character=" .. tostring(LP.Character) .. ")")
		end
		if tick() - lastFlush >= 1 then
			lastFlush = tick()
			pcall(Rec.flushWrites)
			if Rec.repl > 0 or Rec.replIn > 0 then
				Rec.add("net", string.format("Replication sent x%d, received x%d in the last second", Rec.repl, Rec.replIn))
			end
			Rec.repl, Rec.replIn = 0, 0
		end
		if tick() - lastBtn > 2.5 then
			lastBtn = tick()
			pcall(Rec.pollButtons)
		end
		pcall(Rec.pollMovers)
		pcall(Rec.pollLabels)
		if tick() - lastAttr > 0.6 then
			lastAttr = tick()
			pcall(Rec.pollAttrs)
		end
		if tick() - lastBall > 0.45 then
			lastBall = tick()
			pcall(Rec.sampleBall)
		end
		task.wait(0.15)
	end
end
-- a one-off picture of the game when recording starts: buttons, remotes, character, settings
function Rec.snapshot()
	local out = {}
	local function head(s) out[#out + 1] = s end
	head("== JHub recording " .. VERSION .. " | place " .. string.format("%.0f", game.PlaceId) .. " | " .. tostring(JH.execName)
		.. (IS_MOBILE and " | mobile" or " | pc"))
	local vp = cam().ViewportSize
	head("game: " .. tostring(JH.placeName) .. " | screen " .. string.format("%.0fx%.0f", vp.X, vp.Y) .. " | " .. os.date("%Y-%m-%d %H:%M:%S"))
	head(string.format("executor: VIM=%s getconnections=%s firesignal=%s hookmetamethod=%s getgc=%s setclipboard=%s",
		tostring(VIM ~= nil), tostring(getconnections ~= nil), tostring(firesignal ~= nil), tostring(type(hookmetamethod) == "function"),
		tostring(type(getgc) == "function"), tostring(setclipboard ~= nil)))
	head(string.format("settings: hold=%.3f times=[%s] ratio=%.3f bar=%s|%s point=%.3f shootButton=%s", S.HoldTime, S.ShotTimes,
		S.ShotRatio, S.BarPath, S.BarProp, S.BarAt, S.ShootButtonPath))
	head(string.format("boosts: walk=%s+%.1f run=%s+%.1f ball=%s+%.1f channel=%s | glides: dribble=%s shot=%s gather=%s",
		tostring(S.SpeedOn), S.SpeedAdd, tostring(S.RunOn), S.RunAdd, tostring(S.BallSpeedOn), S.BallAdd, S.SpeedChannel,
		tostring(S.DribbleGlide), tostring(S.ShotGlide), tostring(S.GatherGlide)))
	pcall(function()
		local c = char()
		head("LP.Character = " .. tostring(LP.Character) .. " | character found = " .. (c and Rec.short(c) or "none"))
		local cf = workspace:FindFirstChild("Characters")
		if cf then
			local who = {}
			for _, ch in ipairs(cf:GetChildren()) do who[#who + 1] = ch.Name end
			head("workspace.Characters: " .. table.concat(who, " "))
		end
		local top = {}
		for _, ch in ipairs(workspace:GetChildren()) do
			if #top < 40 then top[#top + 1] = ch.Name .. ":" .. ch.ClassName end
		end
		head("workspace: " .. table.concat(top, " "))
		if c then
			local names = {}
			for _, ch in ipairs(c:GetChildren()) do names[#names + 1] = ch.Name .. ":" .. ch.ClassName end
			head("character: " .. table.concat(names, " "))
			local hh = hum()
			head("humanoid: " .. (hh and ("yes walkspeed=" .. tostring(hh.WalkSpeed) .. " jump=" .. tostring(hh.JumpPower)) or "none"))
			local r = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
			if r then
				head(string.format("root: %s anchored=%s pos=%.1f,%.1f,%.1f", Rec.short(r), tostring(r.Anchored), r.Position.X, r.Position.Y, r.Position.Z))
				local kids = {}
				for _, ch in ipairs(r:GetChildren()) do kids[#kids + 1] = ch.Name .. ":" .. ch.ClassName end
				head("root children: " .. table.concat(kids, " "))
			end
			for k, v in pairs(c:GetAttributes()) do head("  char attribute " .. k .. " = " .. tostring(v)) end
		end
		local guis = {}
		for _, g in ipairs((LP:FindFirstChild("PlayerGui") or workspace):GetChildren()) do
			if g:IsA("ScreenGui") then guis[#guis + 1] = g.Name .. (g.Enabled and "" or "(off)") end
		end
		head("screen guis: " .. table.concat(guis, " "))
	end)
	for k, v in pairs(LP:GetAttributes()) do head("  player attribute " .. k .. " = " .. tostring(v)) end
	local pg = LP:FindFirstChild("PlayerGui")
	if pg then
		head("-- visible buttons:")
		local n = 0
		for _, d in ipairs(pg:GetDescendants()) do
			if d:IsA("GuiButton") and not d:IsDescendantOf(gui) and visibleChain(d) then
				n = n + 1
				if n <= 80 then
					head(string.format("  %s [%s %q] at %.0f,%.0f size %.0fx%.0f", Input.pathOf(d), d.ClassName, Input.btnText(d),
						d.AbsolutePosition.X, d.AbsolutePosition.Y, d.AbsoluteSize.X, d.AbsoluteSize.Y))
				end
			end
		end
	end
	head("-- remotes:")
	local n = 0
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
			n = n + 1
			if n <= 100 then head("  " .. d.ClassName .. " " .. Rec.short(d)) end
		end
	end
	head("-- ball parts: " .. Ball.count())
	Rec.header = out
end
-- every remote the game or a script used: counts, who sent it, the first and last arguments
function Rec.spyText()
	local rows = {}
	for name, e in pairs(Rec.spy) do rows[#rows + 1] = { name = name, e = e, n = e.sent + e.recv } end
	table.sort(rows, function(a, b) return a.n > b.n end)
	local out = { "-- remote spy: name | sent | from executor scripts | held back | boosted | received | sender | first args | last args --" }
	for _, r in ipairs(rows) do
		local e = r.e
		out[#out + 1] = string.format("%s | sent %d | exec %d | held %d | boosted %d | recv %d | by %s | first (%s) | last (%s)", r.name, e.sent, e.exec, e.held,
			e.boosted, e.recv, tostring(e.caller or "?"), string.sub(tostring(e.first or ""), 1, 200), string.sub(tostring(e.last or ""), 1, 200))
	end
	if Rec.repl > 0 or Rec.replTotal then out[#out + 1] = "Replication (position stream) is only counted per second in the events" end
	return table.concat(out, "\n")
end
function Rec.copySpy()
	local text = Rec.spyText()
	local tail = {}
	for i = math.max(1, #Rec.lines - 150), #Rec.lines do tail[#tail + 1] = Rec.lines[i] end
	text = text .. "\n-- the last events --\n" .. table.concat(tail, "\n")
	if type(setclipboard) == "function" then
		pcall(setclipboard, text)
		notify("Remote spy", "Copied the remote list and the last events. Paste it to me.", 4)
	else
		FS.write(FS.root .. "/remotespy.txt", text)
		notify("Remote spy", "Saved to the JHubGlass folder (this executor cannot copy).", 4)
	end
end
function Rec.text()
	local parts = {}
	for _, l in ipairs(Rec.header) do parts[#parts + 1] = l end
	parts[#parts + 1] = Rec.spyText()
	parts[#parts + 1] = "-- events (seconds since start) --"
	for _, l in ipairs(Rec.lines) do parts[#parts + 1] = l end
	return table.concat(parts, "\n")
end
function Rec.save(text)
	FS.write(FS.root .. "/recording.txt", text or Rec.text())
end
function Rec.summary()
	local kb = Rec.bytes / 1024
	return (Rec.on and "recording: " or "stopped: ") .. string.format("%d lines, %.0f KB", #Rec.lines, kb)
end
function Rec.copy()
	if #Rec.lines == 0 and #Rec.header == 0 then
		notify("Recorder", "Nothing recorded yet. Turn on Record the game first.", 3)
		return
	end
	local text = Rec.text()
	if type(setclipboard) == "function" then
		pcall(setclipboard, text)
		notify("Recorder", string.format("Copied %d lines (%.0f KB). Paste it to me.", #Rec.lines, #text / 1024), 4)
	else
		notify("Recorder", "This executor cannot copy, so it was saved to the JHubGlass folder instead.", 4)
	end
	Rec.save(text)
end
function Rec.clear()
	Rec.lines, Rec.bytes, Rec.header, Rec.spy = {}, 0, {}, {}
	notify("Recorder", "Cleared", 2)
end
function Rec.start()
	if Rec.on then return end
	Rec.lines, Rec.bytes = {}, 0
	Rec.spy = {}
	Rec.t0 = tick()
	Rec.on = true
	Rec.labelText, Rec.attrCache = {}, {}
	for d in pairs(Shot.labels) do
		if d.Parent then Rec.labelText[d] = d.Text end
	end
	pcall(Rec.snapshot)
	pcall(Rec.hook)
	pcall(Rec.connectRemotes)
	pcall(Rec.watchCharacter)
	Rec.seenFuncs, Rec.seenGuis, Rec.writes = {}, {}, {}
	task.spawn(Rec.scanLoop)
	task.spawn(Rec.sampleLoop)
	notify("Recorder", "Recording. Play and take your shots, then tap Copy recording.", 4)
end
function Rec.stop()
	if not Rec.on then return end
	Rec.add("end", "recording stopped")
	Rec.on = false
	for _, c in ipairs(Rec.conns) do pcall(function() c:Disconnect() end) end
	Rec.conns = {}
	pcall(Rec.save)
	notify("Recorder", string.format("Stopped. %d lines recorded.", #Rec.lines), 3)
end
JH.RecLog = function(msg) Rec.add("jhub", msg) end


---------------------------------------------------------------------
-- AUTO EXECUTE: starts JHub by itself after every join and server change
---------------------------------------------------------------------
Net.AUTOEXEC_FILE = "JHubV1_Glass.lua"
Net.AUTOEXEC_FOLDERS = { "autoexec", "Autoexec", "autoexecute", "Autoexecute" }
function Net.scriptSource()
	if type(JH_SOURCE) == "string" and #JH_SOURCE > 1000 then return JH_SOURCE end
	return FS.read(FS.root .. "/" .. Net.AUTOEXEC_FILE)
end
function Net.autoExecCode()
	local src = Net.scriptSource()
	if not src then return nil end
	return "(getgenv and getgenv() or _G).JHUB_AUTOEXEC = true\n" .. src
end
function Net.queueTeleport()
	local q = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
	local code = Net.autoExecCode()
	if type(q) == "function" and code then
		pcall(q, code)
		return true
	end
	return false
end
function Net.autoExec(on)
	if not on then
		for _, f in ipairs(Net.AUTOEXEC_FOLDERS) do
			local p = f .. "/" .. Net.AUTOEXEC_FILE
			pcall(function()
				if type(isfile) == "function" and isfile(p) and type(delfile) == "function" then delfile(p) end
			end)
		end
		notify("Auto execute", "Off. JHub will not start by itself anymore.", 3)
		return
	end
	local code = Net.autoExecCode()
	if not code then
		notify("Auto execute", "Could not read the script to save it.", 4)
		return
	end
	FS.write(FS.root .. "/" .. Net.AUTOEXEC_FILE, Net.scriptSource())
	local wrote = {}
	for _, f in ipairs(Net.AUTOEXEC_FOLDERS) do
		pcall(function()
			if type(isfolder) == "function" and isfolder(f) then
				writefile(f .. "/" .. Net.AUTOEXEC_FILE, code)
				table.insert(wrote, f)
			end
		end)
	end
	local queued = Net.queueTeleport()
	local parts = {}
	if #wrote > 0 then table.insert(parts, "saved in " .. table.concat(wrote, ", ")) end
	if queued then table.insert(parts, "runs again when you change servers") end
	if #parts == 0 then
		notify("Auto execute", "This executor does not let scripts reach its auto-execute folder. A copy is in the JHubGlass folder: put it in your executor's autoexec folder.", 8)
	else
		notify("Auto execute", "On: " .. table.concat(parts, ", "), 5)
	end
end

---------------------------------------------------------------------
-- GAME SCANNER: a report of the game's own client code and data, for working out how movement, dribbling and codes work
---------------------------------------------------------------------
Rec.scanText = ""
Rec.scanning = false
Rec.SCAN_WORDS = { "move", "speed", "stat", "dribble", "glide", "sprint", "physic", "config", "setting", "build", "shoot", "meter", "input",
	"player", "constant", "code", "reward", "badge", "stamina", "character" }
function Rec.tableDump(t, depth, out, prefix, seen, cap)
	if seen[t] or depth > 3 or #out >= cap then return end
	seen[t] = true
	local keys = {}
	for k in pairs(t) do keys[#keys + 1] = k end
	pcall(table.sort, keys, function(a, b) return tostring(a) < tostring(b) end)
	for i, k in ipairs(keys) do
		if i > 60 or #out >= cap then
			out[#out + 1] = prefix .. "..."
			return
		end
		local v = t[k]
		local tv = typeof(v)
		if tv == "table" then
			out[#out + 1] = prefix .. tostring(k) .. " = {"
			Rec.tableDump(v, depth + 1, out, prefix .. "  ", seen, cap)
			out[#out + 1] = prefix .. "}"
		elseif tv == "function" then
			out[#out + 1] = prefix .. tostring(k) .. " = function"
		else
			out[#out + 1] = prefix .. tostring(k) .. " = " .. Rec.fmt(v, 0)
		end
	end
end
function Rec.scanGame()
	if Rec.scanning then
		notify("Game scanner", "Still scanning, wait a moment.", 2)
		return
	end
	Rec.scanning = true
	notify("Game scanner", "Scanning the game. This takes a few seconds.", 3)
	task.spawn(function()
		local out = {}
		local function add(s) out[#out + 1] = s end
		pcall(function()
			add("== game scan " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName) .. " | " .. os.date("%Y-%m-%d %H:%M:%S"))
			add("-- character: " .. tostring(char() and Bar.pathOf(char()) or "none"))
			local c = char()
			if c then
				for k, v in pairs(c:GetAttributes()) do add("  char attribute " .. k .. " = " .. tostring(v)) end
			end
			for k, v in pairs(LP:GetAttributes()) do add("  player attribute " .. k .. " = " .. tostring(v)) end
			add("-- game settings (workspace.Settings) --")
			local st = workspace:FindFirstChild("Settings")
			if st then
				for k, v in pairs(st:GetAttributes()) do add("  " .. k .. " = " .. tostring(v)) end
				for _, d in ipairs(st:GetDescendants()) do
					local ok, val = pcall(function() return d.Value end)
					add("  " .. Bar.pathOf(d) .. (ok and (" = " .. tostring(val)) or ""))
				end
			end
			add("-- ReplicatedStorage --")
			local n = 0
			for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
				n = n + 1
				if n > 700 then
					add("  ...")
					break
				end
				add("  " .. d.ClassName .. " " .. Bar.pathOf(d))
				if n % 120 == 0 then task.wait() end
			end
		end)
		task.wait()
		-- the game's own client modules, the ones whose names suggest movement, stats, dribbling or codes
		pcall(function()
			local list
			if type(getloadedmodules) == "function" then list = getloadedmodules() end
			if not list then
				add("-- client modules: this executor cannot list them --")
				return
			end
			add("-- client modules (" .. #list .. ") --")
			local picked = {}
			for i, m in ipairs(list) do
				if i <= 500 then add("  " .. Bar.pathOf(m)) end
				local nm = string.lower(m.Name)
				if #picked < 30 and matchAny(nm, Rec.SCAN_WORDS) then picked[#picked + 1] = m end
			end
			for _, m in ipairs(picked) do
				task.wait()
				local ok, res = pcall(require, m)
				local lines = {}
				if ok and type(res) == "table" then
					Rec.tableDump(res, 0, lines, "    ", {}, 200)
				elseif ok then
					lines[1] = "    (" .. typeof(res) .. ")"
				else
					lines[1] = "    (could not be read)"
				end
				add("-- module " .. Bar.pathOf(m) .. " --")
				for _, l in ipairs(lines) do add(l) end
			end
		end)
		task.wait()
		-- loose tables in memory whose names mention speed, glide, dribble, codes
		pcall(function()
			if type(getgc) ~= "function" then return end
			add("-- tables in memory with movement / dribble / code names --")
			local found, seen = 0, 0
			for _, t in ipairs(getgc(true)) do
				seen = seen + 1
				if seen % 4000 == 0 then task.wait() end
				if found < 60 and type(t) == "table" then
					local ok = pcall(function()
						for k, v in pairs(t) do
							if type(k) == "string" and (type(v) == "number" or type(v) == "string" or type(v) == "boolean") then
								local kl = string.lower(k)
								if (string.find(kl, "speed", 1, true) or string.find(kl, "glide", 1, true) or string.find(kl, "dribble", 1, true)
									or string.find(kl, "sprint", 1, true) or kl == "code" or kl == "codes") and found < 60 then
									found = found + 1
									add("  " .. k .. " = " .. tostring(v))
								end
							end
						end
					end)
				end
			end
		end)
		local text = table.concat(out, "\n")
		if #text > 240000 then text = string.sub(text, 1, 240000) .. "\n... (cut)" end
		Rec.scanText = text
		Rec.copyScan()
		Rec.scanning = false
	end)
end
function Rec.copyScan()
	if Rec.scanText == "" then
		notify("Game scanner", "Nothing scanned yet.", 2)
		return
	end
	if type(setclipboard) == "function" then
		pcall(setclipboard, Rec.scanText)
		notify("Game scanner", string.format("Copied (%.0f KB). Paste it to me.", #Rec.scanText / 1024), 4)
	else
		notify("Game scanner", "This executor cannot copy, so it was saved to the JHubGlass folder.", 4)
	end
	FS.write(FS.root .. "/gamescan.txt", Rec.scanText)
end

---------------------------------------------------------------------
-- SHOT RECORDER AND CODE READER: everything about how the game times a shot, to build the best Auto Green from
---------------------------------------------------------------------
Rec.shotOn = false
Rec.shotLines = {}
Rec.shotBytes = 0
Rec.shotConns = {}
Rec.shotCap = 400000
function Rec.shotAdd(text)
	if not Rec.shotOn then return end
	local line = string.format("%.3f %s", tick() - (Rec.shotT0 or tick()), text)
	Rec.shotLines[#Rec.shotLines + 1] = line
	Rec.shotBytes = Rec.shotBytes + #line + 1
	while Rec.shotBytes > Rec.shotCap and #Rec.shotLines > 1 do
		Rec.shotBytes = Rec.shotBytes - #table.remove(Rec.shotLines, 1) - 1
	end
end
function Rec.modulesNamed(sub)
	local out = {}
	if type(getloadedmodules) ~= "function" then return out end
	local ok, list = pcall(getloadedmodules)
	if not ok or type(list) ~= "table" then return out end
	for _, m in ipairs(list) do
		local okp, path = pcall(Bar.pathOf, m)
		if okp and string.sub(path, -#sub) == sub then out[#out + 1] = m end
	end
	return out
end
-- a module's table: the shot timing numbers (green window, meter speed) live in the game's own Meter controller and config
function Rec.dumpModule(sub, maxLines)
	local out = {}
	for _, m in ipairs(Rec.modulesNamed(sub)) do
		local ok, res = pcall(require, m)
		out[#out + 1] = "-- module " .. Bar.pathOf(m)
		if ok and type(res) == "table" then
			Rec.tableDump(res, 0, out, "  ", {}, maxLines or 260)
		else
			out[#out + 1] = "  (" .. typeof(res) .. ")"
		end
	end
	return out
end
function Rec.constantsAll(f)
	local out = {}
	local getc = (debug and debug.getconstants) or getconstants
	if type(getc) ~= "function" then return out end
	local ok, list = pcall(getc, f)
	if not ok or type(list) ~= "table" then return out end
	for _, v in pairs(list) do
		if (type(v) == "string" and #v >= 2 and #v <= 40 and not string.find(v, "[%c]")) or type(v) == "number" then
			if #out < 120 then out[#out + 1] = type(v) == "number" and string.format("%.5g", v) or v end
		end
	end
	return out
end
-- the game's own code for a script: decompiled when the executor can, else the numbers and words inside each function
function Rec.codeOf(m)
	local lines = { "-- script " .. Bar.pathOf(m) }
	local src
	if type(decompile) == "function" then
		local ok, r = pcall(decompile, m)
		if ok and type(r) == "string" and #r > 40 then src = r end
	end
	if src then
		if #src > 70000 then src = string.sub(src, 1, 70000) .. "\n-- (cut)" end
		lines[#lines + 1] = src
		return table.concat(lines, "\n")
	end
	lines[#lines + 1] = "-- (this executor cannot decompile: the numbers and words inside each function follow)"
	local ok, res = pcall(require, m)
	if ok and type(res) == "table" then
		local names = {}
		for k, v in pairs(res) do
			if type(v) == "function" then names[#names + 1] = k end
		end
		table.sort(names, function(a, b) return tostring(a) < tostring(b) end)
		for _, k in ipairs(names) do
			lines[#lines + 1] = "function " .. tostring(k) .. ": " .. table.concat(Rec.constantsAll(res[k]), ", ")
		end
		Rec.tableDump(res, 0, lines, "  ", {}, 160)
	end
	return table.concat(lines, "\n")
end
Rec.CODE_SETS = {
	shooting = { "Controllers/Meter", "Modules/Config/Meters/Bat", "Modules/UI/Character/ShotFeedback", "Config/Game/Shooting",
		"Config/Settings/Meter", "Modules/Config/Meter" },
	movement = { "Components/Character/Movement", "Movement/Types/Base", "Controllers/Player", "Modules/Components/Input/Mobile" },
}
function Rec.copyCode(set)
	notify("Code reader", "Reading the game's code. This takes a few seconds.", 3)
	task.spawn(function()
		local out = { "== game code " .. tostring(set) .. " | " .. VERSION .. " | decompile=" .. tostring(type(decompile) == "function") }
		for _, sub in ipairs(Rec.CODE_SETS[set] or {}) do
			for _, m in ipairs(Rec.modulesNamed(sub)) do
				task.wait()
				local ok, text = pcall(Rec.codeOf, m)
				out[#out + 1] = ok and text or ("-- " .. sub .. " could not be read")
			end
		end
		local text = table.concat(out, "\n")
		if #text > 240000 then text = string.sub(text, 1, 240000) .. "\n-- (cut)" end
		Rec.codeText = text
		if type(setclipboard) == "function" then
			pcall(setclipboard, text)
			notify("Code reader", string.format("Copied (%.0f KB). Paste it to me.", #text / 1024), 4)
		else
			notify("Code reader", "This executor cannot copy, so it was saved to the JHubGlass folder.", 4)
		end
		FS.write(FS.root .. "/code_" .. tostring(set) .. ".txt", text)
	end)
end
-- one line per shot: what kind of shot it was, how it was released and what the game said
Rec.shotSummary = {}
function Rec.shotCategory(ctx, gameType)
	local c = char()
	local base = tostring(c and c:GetAttribute("BaseAnimation") or "")
	local low = string.lower(base .. " " .. tostring(gameType or ""))
	if string.find(low, "dunk", 1, true) then return "dunk" end
	if string.find(low, "layup", 1, true) then return "layup" end
	if string.find(low, "floater", 1, true) then return "floater" end
	if string.find(low, "stepback", 1, true) or string.find(low, "step back", 1, true) then return "step back" end
	if string.find(low, "fade", 1, true) then return "fadeaway" end
	if string.find(low, "post", 1, true) or string.find(low, "hook", 1, true) then return "post shot" end
	if string.find(low, "movingshot", 1, true) then return "moving shot" end
	if string.find(low, "close", 1, true) then return "close shot" end
	if ctx and ctx.speed and ctx.speed > 1.5 then return "moving jumpshot" end
	return "standing jumpshot"
end
function Rec.shotNote(info, res, text)
	if not Rec.shotOn then return end
	local c = char()
	local ctx = Rec.shotCtx or {}
	local gtype = string.match(tostring(Shot.fbText or ""), "Shot Type %- (%S+)")
	local function at(n) return c and tostring(c:GetAttribute(n)) or "?" end
	local n = #Rec.shotSummary + 1
	Rec.shotSummary[n] = string.format("SHOT %d | %s | game type=%s | anim=%s | ShotSpeed=%s | speed at start=%.1f | hand=%s | gather=%s | last dribble=%s | in air=%s | held=%.4f | verdict=%s idx=%s | message=%s | contest=%s | key=%s | start hold=%s | frozen meter=%s | sweep=%s",
		n, Rec.shotCategory(ctx, gtype), tostring(gtype), at("BaseAnimation"), at("ShotSpeed"), ctx.speed or 0, at("Hand"), at("GatherType"), at("LastDribblePackage"),
		tostring(ctx.air), info.held or 0, tostring(res), tostring(info.idx), tostring(text), tostring(string.match(tostring(Shot.fbText or ""), "Contest %- (%S+)")),
		tostring(info.key), tostring(info.base and string.format("%.3f", info.base)), at("meterOffset"), tostring(Shot.lastSweep))
end
function Rec.shotMeterStart(packet)
	if not Rec.shotOn then return end
	local c = char()
	local v = c and c:GetAttribute("ServerVelocity")
	Rec.shotCtx = { speed = (typeof(v) == "Vector3") and v.Magnitude or 0, air = c and c:GetAttribute("InAir") }
	Rec.shotAdd(string.format("== shot meter starts | packet=%s | ShotSpeed=%s", tostring(packet), tostring(c and c:GetAttribute("ShotSpeed"))))
end
local SHOT_SKIP = { Stamina = true, TakeoverFill = true, AccelerationBoost = true }
function Rec.shotStart()
	if Rec.shotOn then return end
	Rec.shotOn = true
	Rec.shotLines, Rec.shotBytes, Rec.shotT0, Rec.shotSummary, Rec.shotCtx = {}, 0, tick(), {}, nil
	Rec.shotAdd("== shot recorder " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName))
	local c = char()
	if c then
		for k, v in pairs(c:GetAttributes()) do Rec.shotAdd("start attr " .. k .. " = " .. tostring(v)) end
		table.insert(Rec.shotConns, c.AttributeChanged:Connect(function(name)
			if SHOT_SKIP[name] then return end
			local val = c:GetAttribute(name)
			Rec.shotAdd("attr " .. name .. " = " .. tostring(val))
			if name == "Action" and string.find(string.lower(tostring(val)), "dunk", 1, true) then
				Rec.shotAdd("== DUNK started | " .. tostring(val))
				Rec.shotSummary[#Rec.shotSummary + 1] = "DUNK | Action=" .. tostring(val) .. " | anim=" .. tostring(c:GetAttribute("BaseAnimation")) .. " | in air=" .. tostring(c:GetAttribute("InAir"))
			end
		end))
	end
	notify("Shot recorder", "Recording. Take standing, moving, fadeaway, step back, layup and dunk shots, then turn it off. It copies everything.", 6)
end
function Rec.shotStop()
	if not Rec.shotOn then return end
	Rec.shotAdd("== stopped")
	Rec.shotOn = false
	for _, cn in ipairs(Rec.shotConns) do pcall(function() cn:Disconnect() end) end
	Rec.shotConns = {}
	Rec.shotFinish()
end
-- one report with everything: the shot-by-shot table, the raw log and the dunk settings
function Rec.shotFinish()
	if #Rec.shotLines <= 2 then
		notify("Shot recorder", "Nothing recorded. Take some shots first.", 3)
		return
	end
	notify("Shot recorder", "Building the report.", 2)
	task.spawn(function()
		local out = { "== SHOT REPORT " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName), "== one line per shot (" .. #Rec.shotSummary .. ")" }
		for _, l in ipairs(Rec.shotSummary) do out[#out + 1] = l end
		out[#out + 1] = "== saved hold times: " .. tostring(S.ShotTimes)
		out[#out + 1] = "== dunk settings"
		pcall(function()
			for _, m in ipairs(getloadedmodules()) do
				local okp, path = pcall(Bar.pathOf, m)
				if okp and string.find(path, "Config/Game/Dunking", 1, true) then
					task.wait()
					local okr, res = pcall(require, m)
					out[#out + 1] = "-- " .. path
					if okr and type(res) == "table" then Rec.tableDump(res, 0, out, "  ", {}, #out + 90) end
				end
			end
		end)
		out[#out + 1] = "== raw log"
		out[#out + 1] = table.concat(Rec.shotLines, "\n")
		local text = table.concat(out, "\n")
		if #text > 380000 then text = string.sub(text, 1, 380000) .. "\n-- (cut)" end
		if type(setclipboard) == "function" then
			pcall(setclipboard, text)
			notify("Shot recorder", string.format("Copied %d shots (%.0f KB). Paste it to me.", #Rec.shotSummary, #text / 1024), 5)
		else
			notify("Shot recorder", "This executor cannot copy, so it was saved to the JHubGlass folder.", 5)
		end
		FS.write(FS.root .. "/shotdata.txt", text)
	end)
end
function Rec.shotCopy() Rec.shotFinish() end

-- every shot package's numbers (meter speed, timing range, contest values)
function Rec.copyShotConfig()
	notify("Shot settings", "Reading the shot settings. This takes a few seconds.", 3)
	task.spawn(function()
		local out = { "== shot settings " .. VERSION }
		local list = {}
		pcall(function() list = getloadedmodules() end)
		for _, m in ipairs(list) do
			local ok, path = pcall(Bar.pathOf, m)
			if ok and string.find(path, "Config/Game/Shooting/Packages", 1, true) then
				task.wait()
				local okr, res = pcall(require, m)
				out[#out + 1] = "-- " .. path
				if okr and type(res) == "table" then Rec.tableDump(res, 0, out, "  ", {}, #out + 70) end
			end
		end
		local text = table.concat(out, "\n")
		if #text > 240000 then text = string.sub(text, 1, 240000) .. "\n-- (cut)" end
		if type(setclipboard) == "function" then
			pcall(setclipboard, text)
			notify("Shot settings", string.format("Copied (%.0f KB). Paste it to me.", #text / 1024), 4)
		else
			notify("Shot settings", "This executor cannot copy, so it was saved to the JHubGlass folder.", 4)
		end
		FS.write(FS.root .. "/shotsettings.txt", text)
	end)
end

-- everything about how shooting works, in one report: module map, the game's code, builds, meters, remotes and player values
Rec.CAPTURE_WORDS = { "shoot", "shot", "meter", "build", "badge", "contest", "rating", "release", "timing", "takeover", "stamina", "attribute",
	"stat", "skill", "archetype", "hotzone", "hot", "cold", "makerng", "percent", "defen", "block", "guard", "gameplay", "layup", "dunk", "pass", "dribble", "input", "mobile",
	"player", "physics", "util", "contact", "basketball", "coin", "movement", "gamemode" }
function Rec.captureAll()
	notify("Capture", "Reading the game. This takes up to a minute.", 5)
	task.spawn(function()
		local out = { "== GAME CAPTURE " .. VERSION .. " | " .. tostring(JH.placeName) .. " | " .. tostring(JH.execName) .. " | decompile=" .. tostring(type(decompile) == "function") }
		local mods = {}
		pcall(function()
			for _, m in ipairs(getloadedmodules()) do
				local ok, path = pcall(Bar.pathOf, m)
				if ok then mods[#mods + 1] = { m = m, path = path } end
			end
		end)
		local FIRST = { "Controllers/Player", "InputService", "Components/Input", "Controllers/Meter", "Shoot", "ShotFeedback", "Shared/Util/", "Config/Game/Basketball",
			"Config/Game/Contact", "Controllers/Characters/Character", "Config/Meter", "Config/Settings", "Controllers/Attributes", "Controllers/Gui" }
		local function prio(path)
			for _, w in ipairs(FIRST) do
				if string.find(path, w, 1, true) then return 1 end
			end
			return 2
		end
		table.sort(mods, function(a, b)
			local pa, pb = prio(a.path), prio(b.path)
			if pa ~= pb then return pa < pb end
			return a.path < b.path
		end)
		local function wanted(path)
			local low = string.lower(path)
			for _, w in ipairs(Rec.CAPTURE_WORDS) do
				if string.find(low, w, 1, true) then return true end
			end
			return false
		end
		-- 1: the map of every module (names only), so nothing is missed
		out[#out + 1] = "== all modules (" .. #mods .. ")"
		for _, e in ipairs(mods) do out[#out + 1] = e.path end
		-- 2: values that describe this player and the place
		out[#out + 1] = "== player values"
		pcall(function()
			for k, v in pairs(LP:GetAttributes()) do out[#out + 1] = "player attr " .. k .. " = " .. tostring(v) end
			local c = char()
			if c then for k, v in pairs(c:GetAttributes()) do out[#out + 1] = "character attr " .. k .. " = " .. tostring(v) end end
			local ls = LP:FindFirstChild("leaderstats")
			if ls then for _, v in ipairs(ls:GetChildren()) do out[#out + 1] = "leaderstat " .. v.Name .. " = " .. tostring(v.Value) end end
			for k, v in pairs(workspace:GetAttributes()) do out[#out + 1] = "workspace attr " .. k .. " = " .. tostring(v) end
			for k, v in pairs(ReplicatedStorage:GetAttributes()) do out[#out + 1] = "replicated attr " .. k .. " = " .. tostring(v) end
		end)
		-- 3: every remote
		out[#out + 1] = "== remotes"
		pcall(function()
			for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
				if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("UnreliableRemoteEvent") then out[#out + 1] = d.ClassName .. " " .. d:GetFullName() end
			end
		end)
		-- 4: the code and settings of everything that has to do with shooting, builds, meters and ratings
		local total, cap = 0, 250000
		out[#out + 1] = "== code and settings"
		for _, e in ipairs(mods) do
			if total > cap then
				out[#out + 1] = "-- (size limit reached, more modules were skipped from here: " .. e.path .. ")"
				break
			end
			local skip = string.find(e.path, "Config/Game/Dunking", 1, true) or string.find(e.path, "Shooting/Packages", 1, true)
				or string.find(e.path, "Dunking/Animations", 1, true) or string.find(e.path, "Dunking/Landings", 1, true)
			if not skip then
				for _, w in ipairs({ "Icon/", "ForgeVFX", "CameraModule", "AnimationViewer", "Vehicles", "TabMenu/", "SeasonPass", "Config/Game/Emotes", "Dribbling/Packages",
					"Crowd", "Hoops/Net", "Replication/Performance", "Statsheet", "BuildOffer", "PlayerModule/", "NameFinder", "Statistics/", "Scoreboards", "GymCustomize" }) do
					if string.find(e.path, w, 1, true) and not string.find(e.path, "Coins", 1, true) then skip = true end
				end
			end
			if wanted(e.path) and not skip then
				task.wait()
				local ok, text = pcall(Rec.codeOf, e.m)
				if ok and type(text) == "string" then
					if #text > 30000 then text = string.sub(text, 1, 30000) .. "\n-- (cut)" end
					out[#out + 1] = text
					total = total + #text
				end
			end
		end
		local text = table.concat(out, "\n")
		if #text > 390000 then text = string.sub(text, 1, 390000) .. "\n-- (cut)" end
		if type(setclipboard) == "function" then
			pcall(setclipboard, text)
			notify("Capture", string.format("Copied (%.0f KB). Paste it to me.", #text / 1024), 6)
		else
			notify("Capture", "This executor cannot copy, so it was saved to the JHubGlass folder.", 6)
		end
		FS.write(FS.root .. "/capture.txt", text)
	end)
end

---------------------------------------------------------------------
-- EXTRAS: sprint and stamina
---------------------------------------------------------------------
Feat.maxSeen = {}
Feat.sprinting = false
function Feat.refillIn(inst)
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("NumberValue") or d:IsA("IntValue") then
			local n = string.lower(d.Name)
			if string.find(n, "stamina", 1, true) or string.find(n, "energy", 1, true) then
				Feat.maxSeen[d] = math.max(Feat.maxSeen[d] or 0, d.Value)
				d.Value = Feat.maxSeen[d]
			end
		end
	end
	for k, v in pairs(inst:GetAttributes()) do
		if type(v) == "number" then
			local n = string.lower(k)
			if string.find(n, "stamina", 1, true) or string.find(n, "energy", 1, true) then
				local key = inst:GetFullName() .. "." .. k
				Feat.maxSeen[key] = math.max(Feat.maxSeen[key] or 0, v)
				pcall(function() inst:SetAttribute(k, Feat.maxSeen[key]) end)
			end
		end
	end
end
function Feat.refillStamina()
	local c = char()
	if c then Feat.refillIn(c) end
	pcall(Feat.refillIn, LP)
end
function Feat.tick(count)
	local h = hum()
	if not h or h.Health <= 0 then return end
	if S.InfStamina and count % 5 == 0 then pcall(Feat.refillStamina) end
	local want = S.AutoSprint and h.MoveDirection.Magnitude > 0.1
	if want ~= Feat.sprinting then
		Feat.sprinting = want
		Input.action("Sprint", want)
	end
end

---------------------------------------------------------------------
-- PICKER: tap the game's shoot button, or the ball
---------------------------------------------------------------------
Picker.mode = nil
function Picker.start(mode)
	UI.show(false)
	notify("Picker", "Tap " .. (mode == "shoot" and "the game's SHOOT button" or "the BALL") .. " now", 4)
	task.delay(0.35, function() Picker.mode = mode end)
end
function Picker.handle(mode, pos)
	if mode == "shoot" then
		local pg = LP:FindFirstChild("PlayerGui")
		local inset = insetHeight()
		local found
		for _, y in ipairs({ pos.Y, pos.Y + inset }) do
			local ok, list = pcall(function() return pg:GetGuiObjectsAtPosition(pos.X, y) end)
			if ok and list then
				for _, g in ipairs(list) do
					if not g:IsDescendantOf(gui) and g:IsA("GuiButton") then found = g break end
				end
				if not found then
					for _, g in ipairs(list) do
						if not g:IsDescendantOf(gui) then found = g break end
					end
				end
			end
			if found then break end
		end
		if found then
			UI.set("ShootButtonPath", Input.pathOf(found), false)
			Input.cache.Shoot = nil
			notify("Shoot button set", found.Name, 3)
			log("Shoot button: " .. S.ShootButtonPath)
		else
			notify("Picker", "Nothing found there, try again", 3)
		end
	else
		local ray = cam():ScreenPointToRay(pos.X, pos.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char() or workspace.Terrain }
		local res = workspace:Raycast(ray.Origin, ray.Direction * 600, params)
		if res and res.Instance then
			UI.set("BallName", res.Instance.Name, false)
			Ball.rescan()
			Ball.parts[res.Instance] = true
			notify("Ball set", res.Instance.Name, 3)
		else
			notify("Picker", "Nothing hit, try again", 3)
		end
	end
	UI.show(true)
end

---------------------------------------------------------------------
-- UI LIBRARY (clear blue glass)
---------------------------------------------------------------------
UI.themed, UI.texts, UI.corners, UI.cards, UI.elems, UI.grads = {}, {}, {}, {}, {}, {}
UI.pages, UI.refresh, UI.flagRefresh, UI.flagCB = {}, {}, {}, {}
UI.listening = nil
function UI.th(o, prop, key)
	table.insert(UI.themed, { o, prop, key })
	o[prop] = Theme[key]
	return o
end
function UI.elemTrans() return clamp(S.CardTrans - 0.35, 0.12, 0.9) end
function UI.font(bold)
	local f = FONTS[S.Font] or FONTS.Gotham
	local name = bold and f[2] or f[1]
	local ok, e = pcall(function() return Enum.Font[name] end)
	if ok and e then return e end
	return bold and Enum.Font.GothamBold or Enum.Font.Gotham
end
function UI.text(o, bold)
	table.insert(UI.texts, { o, bold })
	o.Font = UI.font(bold)
	o.TextStrokeColor3 = Theme.Stroke
	o.TextStrokeTransparency = S.TextStroke and 0.72 or 1
	return o
end
function UI.label(props, bold, colorKey)
	local l = new("TextLabel", props)
	l.BackgroundTransparency = 1
	UI.text(l, bold)
	if colorKey ~= false then UI.th(l, "TextColor3", colorKey or "Text") end
	return l
end
function UI.corner(o, factor)
	local c = new("UICorner", { Parent = o })
	if factor == "pill" then
		c.CornerRadius = UDim.new(1, 0)
	else
		table.insert(UI.corners, { c, factor or 1 })
		c.CornerRadius = UDim.new(0, math.floor(S.Corner * (factor or 1)))
	end
	return c
end
function UI.card(f)
	table.insert(UI.cards, f)
	f.BackgroundColor3 = Theme.Card
	f.BackgroundTransparency = S.CardTrans
	return f
end
function UI.elem(f)
	table.insert(UI.elems, f)
	f.BackgroundColor3 = Theme.Elem
	f.BackgroundTransparency = UI.elemTrans()
	return f
end
function UI.paintGrad(g)
	g.Color = ColorSequence.new(Theme.AccentA, Theme.AccentB)
	g.Rotation = 35
end
function UI.grad(o)
	local g = new("UIGradient", { Parent = o })
	table.insert(UI.grads, g)
	UI.paintGrad(g)
	return g
end
function UI.stroke(o, transparency)
	local st = new("UIStroke", { Thickness = 1, Color = WHITE, Transparency = transparency or 0.6,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
	return st
end
function UI.addRefresh(flag, fn)
	if flag then
		UI.flagRefresh[flag] = UI.flagRefresh[flag] or {}
		table.insert(UI.flagRefresh[flag], fn)
	end
	table.insert(UI.refresh, fn)
end
-- set a setting from code or UI; fire = false skips the feature callback
function UI.set(flag, v, fire)
	S[flag] = v
	local list = UI.flagRefresh[flag]
	if list then
		for _, f in ipairs(list) do pcall(f) end
	end
	if fire ~= false and UI.flagCB[flag] then task.spawn(UI.flagCB[flag], v) end
	saveSoon()
end
function UI.refreshAll()
	UI.applyTheme()
	for _, f in ipairs(UI.refresh) do pcall(f) end
end

-- window ---------------------------------------------------------------
local Window = new("Frame", { Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(560, 340), BackgroundTransparency = 1, Parent = gui })
local WinScale = new("UIScale", { Parent = Window })
local Main = new("Frame", { Name = "Main", Size = UDim2.fromScale(1, 1), ClipsDescendants = true, Parent = Window })
UI.corner(Main, 1.4)
local MainStroke = new("UIStroke", { Thickness = 2, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Main })
local StrokeGrad = new("UIGradient", { Parent = MainStroke })
local Sheen = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = Main })
local SheenGrad = new("UIGradient", { Rotation = 120, Parent = Sheen })
do
	local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
	local YEL, GLD = Color3.fromRGB(255, 221, 64), Color3.fromRGB(255, 196, 40)
	local Storm = new("Frame", { Name = "Storm", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Main })
	local BG = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(2.2, 2.2),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = Storm })
	local BGGrad = new("UIGradient", { Rotation = 35, Parent = BG })
	local orbs = {}
	for i = 1, 3 do
		local o = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(150 + i * 30, 150 + i * 30),
			BackgroundColor3 = (i % 2 == 0) and WHITE or YEL, BackgroundTransparency = 0.9, BorderSizePixel = 0, Parent = Storm })
		UI.corner(o, "pill")
		orbs[i] = o
	end
	local pool = {}
	for i = 1, 10 do
		local o = { glow = {}, core = {}, t = 0, life = 1, on = false }
		for j = 1, 9 do
			o.glow[j] = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, BackgroundTransparency = 1, BackgroundColor3 = YEL, ZIndex = 2, Parent = Storm })
			o.core[j] = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, BackgroundTransparency = 1, BackgroundColor3 = WHITE, ZIndex = 3, Parent = Storm })
		end
		pool[i] = o
	end
	local function hide(o)
		for j = 1, #o.core do
			o.core[j].BackgroundTransparency = 1
			o.glow[j].BackgroundTransparency = 1
		end
		o.on = false
	end
	local function strike(o)
		local W, H = 560, 340
		local x = math.random() * W
		local n = #o.core
		local endY = H * (0.55 + math.random() * 0.5)
		local drift = (math.random() - 0.5) * W * 0.45
		local pts = { { x, -6 } }
		for j = 1, n do
			local f = j / n
			pts[#pts + 1] = { x + drift * f + (math.random() - 0.5) * 48, endY * f }
		end
		local mode = S.BoltColor or "White + Yellow"
		local coreC, glowC
		if mode == "Yellow" then coreC, glowC = Color3.fromRGB(255, 240, 150), YEL
		elseif mode == "White" then coreC, glowC = WHITE, Color3.fromRGB(215, 228, 255)
		elseif math.random() < 0.5 then coreC, glowC = WHITE, YEL
		else coreC, glowC = YEL, WHITE end
		local th = S.BoltThick or 2
		for j = 1, n do
			local a, b = pts[j], pts[j + 1]
			local dx, dy = b[1] - a[1], b[2] - a[2]
			local len = math.sqrt(dx * dx + dy * dy) + 2
			local ang = math.deg(atan2(dy, dx))
			local pos = UDim2.fromOffset((a[1] + b[1]) / 2, (a[2] + b[2]) / 2)
			local g, c = o.glow[j], o.core[j]
			g.Size, c.Size = UDim2.fromOffset(len, th * 4), UDim2.fromOffset(len, th)
			g.Position, c.Position = pos, pos
			g.Rotation, c.Rotation = ang, ang
			g.BackgroundColor3, c.BackgroundColor3 = glowC, coreC
		end
		o.t, o.life, o.on = 0, 0.3 / math.max(S.BoltSpeed or 1, 0.2) + math.random() * 0.18, true
	end
	local function step(o, dt)
		o.t = o.t + dt
		local k = o.t / o.life
		if k >= 1 then hide(o) return end
		local fl = (math.floor(o.t * 38) % 2 == 0) and 1 or 0.55
		local a = (1 - k) * fl * (S.BoltBright or 0.9)
		local ct, gt = 1 - a, 1 - a * 0.45
		for j = 1, #o.core do
			o.core[j].BackgroundTransparency = ct
			o.glow[j].BackgroundTransparency = gt
		end
	end
	-- lightning shape for the logo: three bars in a zig-zag, yellow with a soft glow behind
	function UI.makeBolt(parent, pos, size, zi)
		local root = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = size, BackgroundTransparency = 1, ZIndex = zi or 4, Parent = parent })
		new("UIAspectRatioConstraint", { AspectRatio = 1, Parent = root })
		local pts = { { 0.70, 0.02 }, { 0.30, 0.54 }, { 0.62, 0.48 }, { 0.28, 0.99 } }
		local glows = {}
		for pass = 1, 2 do
			for i = 1, 3 do
				local a, b = pts[i], pts[i + 1]
				local dx, dy = b[1] - a[1], b[2] - a[2]
				local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((a[1] + b[1]) / 2, (a[2] + b[2]) / 2),
					Size = UDim2.fromScale(math.sqrt(dx * dx + dy * dy) + 0.04, pass == 1 and 0.34 or 0.17), Rotation = math.deg(atan2(dy, dx)),
					BackgroundColor3 = pass == 1 and GLD or YEL, BackgroundTransparency = pass == 1 and 0.55 or 0, BorderSizePixel = 0,
					ZIndex = (zi or 4) + pass, Parent = root })
				UI.corner(f, "pill")
				if pass == 1 then glows[#glows + 1] = f end
			end
		end
		UI.bolts = UI.bolts or {}
		UI.bolts[#UI.bolts + 1] = glows
		return root
	end
	local PRESETS = {
		["Lightning Gold"] = { Hue = 226, Sat = 0.8, Val = 0.14, AccentMode = "Gold", OutlineColor = "Gold", BoltColor = "White + Yellow" },
		["Ice Blue"] = { Hue = 205, Sat = 0.55, Val = 0.5, AccentMode = "Match hue", OutlineColor = "Cyan", BoltColor = "White" },
		["Neon Pink"] = { Hue = 320, Sat = 0.8, Val = 0.2, AccentMode = "Match hue", OutlineColor = "Pink", BoltColor = "White" },
		["Emerald"] = { Hue = 150, Sat = 0.8, Val = 0.18, AccentMode = "Match hue", OutlineColor = "Lime", BoltColor = "Yellow" },
		["Midnight"] = { Hue = 250, Sat = 0.5, Val = 0.07, AccentMode = "Gold", OutlineColor = "White", BoltColor = "White" },
	}
	UI.PRESET_NAMES = { "Lightning Gold", "Ice Blue", "Neon Pink", "Emerald", "Midnight" }
	function UI.applyPreset(name)
		local p = PRESETS[name]
		if not p then return end
		for k, v in pairs(p) do S[k] = v end
		UI.refreshAll()
		saveSoon()
	end
	local lastGlow
	function UI.paintStorm()
		local h = (S.Hue % 360) / 360
		local dark = Color3.fromHSV(h, math.min(S.Sat, 0.9), 0.12)
		local mid = (S.AccentMode == "Match hue") and Color3.fromHSV(h, 0.75, 0.42) or Color3.fromRGB(78, 60, 8)
		BGGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, dark), ColorSequenceKeypoint.new(0.5, mid), ColorSequenceKeypoint.new(1, dark) })
		local tr = 1 - clamp(S.BgGlow or 0.5, 0, 1) * 0.85
		BGGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, tr), NumberSequenceKeypoint.new(1, tr) })
		lastGlow = S.BgGlow
	end
	function UI.applyFx()
		Storm.Visible = true
		if S.Lightning == false then
			for _, o in ipairs(pool) do hide(o) end
		end
		if UI.logoParts then
			local jbh = S.LogoStyle ~= "JHub V1"
			UI.logoParts.j.Visible, UI.logoParts.h.Visible, UI.logoParts.bolt.Visible = jbh, jbh, jbh
			UI.logoParts.word.Visible = not jbh
		end
		UI.paintStorm()
	end
	UI.paintStorm()
	UI.stormPool = pool
	local fxT, nextAt = 0, 0
	bind(RunService.Heartbeat, function(dt)
		fxT = fxT + dt
		local sp = S.OutlineSpeed or 1
		-- the floating logo
		if UI.FloatBodyGrad then UI.FloatBodyGrad.Rotation = (fxT * 55 * math.max(sp, 0.2)) % 360 end
		if not Window.Visible then return end
		-- moving background
		if S.BgMove ~= false then
			BGGrad.Offset = Vector2.new(math.sin(fxT * 0.3) * 0.35, math.cos(fxT * 0.23) * 0.35)
			BGGrad.Rotation = 35 + math.sin(fxT * 0.2) * 30
		end
		for i, o in ipairs(orbs) do
			o.Visible = S.BgOrbs ~= false and S.BgMove ~= false
			o.Position = UDim2.fromScale(0.5 + 0.45 * math.sin(fxT * 0.35 * i + i), 0.5 + 0.4 * math.cos(fxT * 0.27 * i + i * 2))
			o.BackgroundTransparency = 0.88 + 0.05 * math.sin(fxT * 1.3 + i)
		end
		if S.BgGlow ~= lastGlow then UI.paintStorm() end
		-- lightning
		if S.Lightning ~= false then
			nextAt = nextAt - dt
			if nextAt <= 0 then
				local cnt = math.floor(S.BoltCount or 6)
				nextAt = (0.1 + math.random() * 0.55) * (8 / math.max(cnt, 1)) / math.max(S.BoltSpeed or 1, 0.2)
				for i = 1, math.min(cnt, #pool) do
					if not pool[i].on then strike(pool[i]) break end
				end
			end
			for _, o in ipairs(pool) do if o.on then step(o, dt) end end
		else
			for _, o in ipairs(pool) do if o.on then hide(o) end end
		end
		-- header logo
		if UI.LogoOutlineGrad then UI.LogoOutlineGrad.Rotation = (fxT * 140 * sp) % 360 end
		if UI.LogoBGGrad and S.LogoBg ~= false then UI.LogoBGGrad.Offset = Vector2.new(math.sin(fxT * 0.9) * 0.6, 0) end
		if UI.bolts then
			local pulse = 0.5 + 0.2 * math.sin(fxT * 5)
			for _, list in ipairs(UI.bolts) do
				for _, f in ipairs(list) do f.BackgroundTransparency = pulse end
			end
		end
	end)
end

local Header = new("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Active = true, Parent = Main })
local LogoTextGrad
do
	local dark, mid = Color3.fromRGB(12, 14, 32), Color3.fromRGB(95, 74, 10)
	local badge = new("Frame", { Name = "LogoBadge", Position = UDim2.fromOffset(12, 5), Size = UDim2.fromOffset(108, 26),
		BackgroundColor3 = dark, ClipsDescendants = true, Parent = Header })
	UI.corner(badge, 0.8)
	local bg = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(3, 3),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, Parent = badge })
	local bgGrad = new("UIGradient", { Rotation = 20, Parent = bg })
	bgGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, dark), ColorSequenceKeypoint.new(0.5, mid), ColorSequenceKeypoint.new(1, dark) })
	local ol = new("UIStroke", { Thickness = 2, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = badge })
	local olGrad = new("UIGradient", { Parent = ol })
	olGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 221, 64)), ColorSequenceKeypoint.new(0.5, WHITE),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 221, 64)) })
	local j = UI.label({ Text = "J", TextSize = 22, Position = UDim2.fromOffset(8, 0), Size = UDim2.fromOffset(26, 26), TextColor3 = WHITE, ZIndex = 3, Parent = badge }, true, false)
	local h = UI.label({ Text = "H", TextSize = 22, Position = UDim2.fromOffset(74, 0), Size = UDim2.fromOffset(26, 26), TextColor3 = WHITE, ZIndex = 3, Parent = badge }, true, false)
	local word = UI.label({ Text = "JHub V1", TextSize = 18, Size = UDim2.fromScale(1, 1), TextColor3 = WHITE, ZIndex = 3, Visible = false, Parent = badge }, true, false)
	local bolt = UI.makeBolt(badge, UDim2.fromOffset(54, 13), UDim2.fromOffset(22, 22), 3)
	LogoTextGrad = UI.grad(j)
	UI.grad(h)
	UI.grad(word)
	UI.LogoBGGrad, UI.LogoOutlineGrad = bgGrad, olGrad
	UI.logoParts = { j = j, h = h, bolt = bolt, word = word }
end
UI.label({ Text = "Glass  " .. VERSION .. "  -  Practical Basketball", TextSize = 11, Position = UDim2.fromOffset(17, 30),
	Size = UDim2.new(0, 260, 0, 13), TextXAlignment = Enum.TextXAlignment.Left, Parent = Header }, false, "Sub")
local function headerButton(text, xoff)
	local b = new("TextButton", { Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xoff, 0.5, 0),
		Size = UDim2.fromOffset(32, 28), AutoButtonColor = false, Parent = Header })
	UI.elem(b)
	UI.corner(b, 0.7)
	UI.stroke(b, 0.55)
	UI.label({ Text = text, TextSize = 14, Size = UDim2.fromScale(1, 1), Parent = b }, true, "Text")
	return b
end
local CollapseBtn = headerButton("-", -52)
local CloseBtn = headerButton("X", -12)
local HeadLine = new("Frame", { Position = UDim2.new(0, 10, 1, -1), Size = UDim2.new(1, -20, 0, 1), BorderSizePixel = 0,
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.7, Parent = Header })
UI.th(HeadLine, "BackgroundColor3", "AccentB")

local Body = new("Frame", { Position = UDim2.fromOffset(0, 47), Size = UDim2.new(1, 0, 1, -47), BackgroundTransparency = 1, Parent = Main })
local Rail = new("ScrollingFrame", { Size = UDim2.new(0, 116, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Body })
new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Rail })
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 8), Parent = Rail })
local RailLine = new("Frame", { Position = UDim2.new(0, 116, 0, 6), Size = UDim2.new(0, 1, 1, -12), BorderSizePixel = 0,
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.75, Parent = Body })
UI.th(RailLine, "BackgroundColor3", "AccentB")
local Content = new("Frame", { Position = UDim2.fromOffset(120, 0), Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1, Parent = Body })

function UI.fitScale()
	local vp = cam().ViewportSize
	local s = math.min(vp.X * 0.94 / 560, vp.Y * 0.86 / 340)
	if s > 1.15 then s = 1.15 end
	WinScale.Scale = s * S.UIScale
end

function UI.applyWindow()
	Main.BackgroundColor3 = Theme.Glass
	Main.BackgroundTransparency = S.WinTrans
	Sheen.Visible = S.WinGradient
	Sheen.BackgroundColor3 = Theme.Sheen
	Sheen.BackgroundTransparency = 0
	SheenGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.84), NumberSequenceKeypoint.new(0.55, 0.96),
		NumberSequenceKeypoint.new(1, 1) })
	MainStroke.Thickness = S.OutlineThick
	MainStroke.Color = Theme.Outline
	MainStroke.Transparency = 0
	local clear = S.OutlineShine and 0.55 or 0
	StrokeGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, clear),
		NumberSequenceKeypoint.new(1, 0) })
	StrokeGrad.Color = ColorSequence.new(WHITE, WHITE)
	if S.Blur then
		if not UI.blur then UI.blur = new("BlurEffect", { Name = "JHubBlur", Size = 0, Parent = Lighting }) end
		UI.blur.Size = Window.Visible and S.BlurSize or 0
	elseif UI.blur then
		UI.blur:Destroy()
		UI.blur = nil
	end
	UI.fitScale()
	if UI.paintStorm then UI.paintStorm() end
end
function UI.applyLogo()
	if not UI.LogoRoot then return end
	UI.LogoRoot.Size = UDim2.fromOffset(S.LogoSize, S.LogoSize)
	UI.LogoBody.BackgroundTransparency = 1 - S.LogoOpacity
	UI.LogoText.TextTransparency = 1 - S.LogoOpacity
	UI.LogoText.TextSize = math.floor(S.LogoSize * 0.4)
end
function UI.applyTheme()
	computeTheme()
	for _, t in ipairs(UI.themed) do
		if t[1].Parent then pcall(function() t[1][t[2]] = Theme[t[3]] end) end
	end
	for _, t in ipairs(UI.texts) do
		if t[1].Parent then
			t[1].Font = UI.font(t[2])
			t[1].TextStrokeColor3 = Theme.Stroke
			t[1].TextStrokeTransparency = S.TextStroke and 0.72 or 1
		end
	end
	for _, c in ipairs(UI.corners) do
		if c[1].Parent then c[1].CornerRadius = UDim.new(0, math.floor(S.Corner * c[2])) end
	end
	for _, f in ipairs(UI.cards) do
		if f.Parent then
			f.BackgroundColor3 = Theme.Card
			f.BackgroundTransparency = S.CardTrans
		end
	end
	local et = UI.elemTrans()
	for _, f in ipairs(UI.elems) do
		if f.Parent then
			f.BackgroundColor3 = Theme.Elem
			f.BackgroundTransparency = et
		end
	end
	for _, g in ipairs(UI.grads) do
		if g.Parent then UI.paintGrad(g) end
	end
	UI.applyWindow()
	UI.applyLogo()
end

-- dragging ---------------------------------------------------------------
local function dragify(handle, target, onTap, onEnd, scaleOf)
	local dragInput, start, startPos, moved
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == MB1 or i.UserInputType == TOUCH then
			dragInput, start, startPos, moved = i, i.Position, target.Position, false
		end
	end)
	bind(UIS.InputChanged, function(i)
		if not dragInput then return end
		if i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MMOVE) then
			local d = i.Position - start
			if d.Magnitude > 8 then moved = true end
			if moved then
				local sc = scaleOf and scaleOf() or 1
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X / sc, startPos.Y.Scale, startPos.Y.Offset + d.Y / sc)
			end
		end
	end)
	bind(UIS.InputEnded, function(i)
		if not dragInput then return end
		if i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MB1) then
			if not moved and onTap then task.spawn(onTap) end
			if moved and onEnd then task.spawn(onEnd) end
			dragInput = nil
		end
	end)
end
UI.Window = Window
function UI.keepOnScreen()
	local vp = cam().ViewportSize
	local p, sz = Window.AbsolutePosition, Window.AbsoluteSize
	local sc = WinScale.Scale > 0 and WinScale.Scale or 1
	local dx, dy = 0, 0
	if p.X + sz.X < 120 then dx = 120 - (p.X + sz.X) end
	if p.X > vp.X - 120 then dx = (vp.X - 120) - p.X end
	if p.Y < 0 then dy = -p.Y end
	if p.Y > vp.Y - 50 then dy = (vp.Y - 50) - p.Y end
	if dx ~= 0 or dy ~= 0 then
		local pos = Window.Position
		Window.Position = UDim2.new(pos.X.Scale, pos.X.Offset + dx / sc, pos.Y.Scale, pos.Y.Offset + dy / sc)
	end
end
function UI.recenter()
	Window.Position = UDim2.fromScale(0.5, 0.5)
	UI.fitScale()
end
-- buttons catch touches reliably, so they sit behind the title and the tab column as grab areas
local DragHandle = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
	ZIndex = 0, Parent = Header })
local RailDrag = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(0, 116, 1, 0),
	ZIndex = 0, Parent = Body })
UI.DragHandle, UI.RailDrag = DragHandle, RailDrag
dragify(DragHandle, Window, nil, UI.keepOnScreen, function() return WinScale.Scale end)
dragify(RailDrag, Window, nil, UI.keepOnScreen, function() return WinScale.Scale end)

-- toasts ---------------------------------------------------------------
local Toasts = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 58), Size = UDim2.fromOffset(280, 400),
	BackgroundTransparency = 1, Parent = gui })
new("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right,
	SortOrder = Enum.SortOrder.LayoutOrder, Parent = Toasts })
local toastOrder = 0
function UI.notify(title, msg, dur)
	if not S.Notifications then return end
	dur = dur or 3
	toastOrder = toastOrder + 1
	local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		LayoutOrder = toastOrder, Parent = Toasts })
	local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(300, 0),
		BackgroundColor3 = Theme.Glass, BackgroundTransparency = math.min(S.WinTrans, 0.35), Parent = wrap })
	UI.corner(f, 0.9)
	new("UIStroke", { Thickness = 1.5, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f })
	new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 8), Parent = f })
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
	UI.label({ Text = title, TextSize = 13, Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1, Parent = f }, true, "Text")
	UI.label({ Text = tostring(msg or ""), TextSize = 12, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = f }, false, "Sub")
	TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(0, 0) }):Play()
	task.delay(dur, function()
		local t = TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(300, 0) })
		t:Play()
		t.Completed:Wait()
		wrap:Destroy()
	end)
end

-- pages ------------------------------------------------------------------
function UI.refreshTabs()
	for _, p in ipairs(UI.pages) do
		local on = UI.current == p
		p.bg.BackgroundTransparency = on and 0.78 or 1
		p.bar.Visible = on
		p.lbl.Font = UI.font(on)
	end
end
function UI.select(p)
	UI.current = p
	for _, q in ipairs(UI.pages) do q.frame.Visible = (q == p) end
	UI.refreshTabs()
	p.frame.Position = UDim2.fromOffset(0, 10)
	TweenService:Create(p.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(0, 0) }):Play()
end
function UI.Page(name, glyph)
	local order = #UI.pages + 1
	local b = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = order, Parent = Rail })
	local bg = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Parent = b })
	UI.corner(bg, 0.8)
	local bar = new("Frame", { Size = UDim2.new(0, 3, 0, 20), Position = UDim2.new(0, 0, 0.5, -10), BackgroundColor3 = WHITE,
		BorderSizePixel = 0, Visible = false, Parent = b })
	UI.corner(bar, "pill")
	UI.th(bar, "BackgroundColor3", "AccentB")
	local icon = new("Frame", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 8, 0.5, -12), BackgroundColor3 = WHITE, Parent = b })
	UI.corner(icon, 0.7)
	UI.grad(icon)
	UI.label({ Text = glyph, TextSize = 13, Size = UDim2.fromScale(1, 1), TextColor3 = Color3.fromRGB(10, 40, 100), Parent = icon }, true, false)
	local lbl = UI.label({ Text = name, TextSize = 13, Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -40, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = b }, false, "Text")
	local frame = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = Content })
	UI.th(frame, "ScrollBarImageColor3", "Outline")
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 14), Parent = frame })
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
	local p = { name = name, bg = bg, bar = bar, lbl = lbl, frame = frame, order = 0 }
	b.Activated:Connect(function() UI.select(p) end)
	table.insert(UI.pages, p)
	if not UI.current then UI.select(p) end
	return p
end

-- cards and controls -------------------------------------------------------
function UI.Card(page, title)
	page.order = page.order + 1
	local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = page.order, Parent = page.frame })
	UI.card(f)
	UI.corner(f, 1)
	UI.stroke(f, 0.6)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 10), Parent = f })
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
	local tr = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 0, Parent = f })
	local dot = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0, 0, 0.5, -4), BackgroundColor3 = WHITE, Parent = tr })
	UI.corner(dot, "pill")
	UI.grad(dot)
	UI.label({ Text = title, TextSize = 14, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -16, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = tr }, true, "Text")
	local line = new("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.75,
		BorderSizePixel = 0, LayoutOrder = 1, Parent = f })
	return { frame = f, order = 1, page = page }
end
local function nextOrder(card)
	card.order = card.order + 1
	return card.order
end
local function row(card, h)
	return new("Frame", { Size = UDim2.new(1, 0, 0, h or 30), BackgroundTransparency = 1, LayoutOrder = nextOrder(card), Parent = card.frame })
end
function UI.Note(card, text, colorKey)
	return UI.label({ Text = text, TextSize = 11, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
		LayoutOrder = nextOrder(card), Parent = card.frame }, false, colorKey or "Sub")
end
function UI.Stat(card, name)
	local r = row(card, 20)
	UI.label({ Text = name, TextSize = 12, Size = UDim2.new(0.45, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = r }, false, "Sub")
	return UI.label({ Text = "-", TextSize = 12, Position = UDim2.fromScale(0.35, 0), Size = UDim2.new(0.65, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, true, "Text")
end
function UI.Toggle(card, text, flag, cb)
	local r = row(card, 30)
	UI.label({ Text = text, TextSize = 13, Size = UDim2.new(1, -52, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
	local sw = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(42, 22), Parent = r })
	UI.elem(sw)
	UI.corner(sw, "pill")
	UI.stroke(sw, 0.45)
	local fill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Parent = sw })
	UI.corner(fill, "pill")
	UI.grad(fill)
	local knob = new("Frame", { Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = WHITE, Parent = sw })
	UI.corner(knob, "pill")
	local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = r })
	local function show(anim)
		local on = S[flag] and true or false
		local ti = TweenInfo.new(anim and 0.18 or 0, Enum.EasingStyle.Quad)
		TweenService:Create(fill, ti, { BackgroundTransparency = on and 0 or 1 }):Play()
		TweenService:Create(knob, ti, { Position = on and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2) }):Play()
	end
	UI.flagRefresh[flag] = UI.flagRefresh[flag] or {}
	table.insert(UI.flagRefresh[flag], function() show(true) end)
	table.insert(UI.refresh, function() show(false) end)
	if cb and not UI.flagCB[flag] then UI.flagCB[flag] = cb end
	show(false)
	hit.Activated:Connect(function() UI.set(flag, not S[flag]) end)
end
-- press and hold repeats, so +/- can sweep a whole range
local function holdRepeat(btn, fn)
	local token = 0
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == MB1 or i.UserInputType == TOUCH then
			token = token + 1
			local mine = token
			fn()
			task.spawn(function()
				task.wait(0.35)
				while token == mine and JH.Running do
					fn()
					task.wait(0.07)
				end
			end)
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then token = token + 1 end
			end)
		end
	end)
end
-- slider with - and + buttons and a number box, so everything can be turned down or up precisely
function UI.Slider(card, text, flag, min, max, step, dec, suffix, cb)
	local r = row(card, 54)
	suffix = suffix or ""
	UI.label({ Text = text, TextSize = 13, Size = UDim2.new(1, -78, 0, 20), TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
	local box = new("TextBox", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(74, 20),
		BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, TextSize = 12, ClearTextOnFocus = false, Parent = r })
	UI.text(box, true)
	UI.th(box, "TextColor3", "Text")
	local function stepButton(label, x, anchor)
		local b = new("TextButton", { Text = "", AnchorPoint = Vector2.new(anchor, 0), Position = UDim2.new(x, 0, 0, 26),
			Size = UDim2.fromOffset(26, 24), AutoButtonColor = false, Parent = r })
		UI.elem(b)
		UI.corner(b, 0.7)
		UI.stroke(b, 0.5)
		UI.label({ Text = label, TextSize = 16, Size = UDim2.fromScale(1, 1), Parent = b }, true, "Text")
		return b
	end
	local minus = stepButton("-", 0, 0)
	local plus = stepButton("+", 1, 1)
	local bar = new("Frame", { Position = UDim2.new(0, 34, 0, 34), Size = UDim2.new(1, -68, 0, 8), Parent = r })
	UI.elem(bar)
	UI.corner(bar, "pill")
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, Parent = bar })
	UI.corner(fill, "pill")
	UI.grad(fill)
	local knob = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = WHITE, Parent = bar })
	UI.corner(knob, "pill")
	new("UIStroke", { Thickness = 2, Color = Theme.AccentB, Parent = knob })
	local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Position = UDim2.new(0, 30, 0, 24), Size = UDim2.new(1, -60, 0, 28), Parent = r })
	local mult = 10 ^ dec
	local function show()
		local v = tonumber(S[flag]) or min
		local a = clamp((v - min) / (max - min), 0, 1)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		if not box:IsFocused() then box.Text = tostring(v) .. suffix end
	end
	local function setv(v)
		v = clamp(min + math.floor((v - min) / step + 0.5) * step, min, max)
		v = math.floor(v * mult + 0.5) / mult
		S[flag] = v
		local list = UI.flagRefresh[flag]
		if list then
			for _, f in ipairs(list) do pcall(f) end
		end
		if cb then cb(v) end
	end
	UI.addRefresh(flag, show)
	show()
	box.FocusLost:Connect(function()
		local n = tonumber((string.gsub(box.Text, "[^%d%.%-]", "")))
		if n then
			setv(n)
			saveSoon()
		else
			show()
		end
	end)
	holdRepeat(minus, function() setv((tonumber(S[flag]) or min) - step) saveSoon() end)
	holdRepeat(plus, function() setv((tonumber(S[flag]) or min) + step) saveSoon() end)
	local dragInput
	local function upd(x)
		local a, w = bar.AbsolutePosition.X, bar.AbsoluteSize.X
		if w <= 0 then return end
		setv(min + (max - min) * clamp((x - a) / w, 0, 1))
	end
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == MB1 or i.UserInputType == TOUCH then
			dragInput = i
			card.page.frame.ScrollingEnabled = false
			upd(i.Position.X)
		end
	end)
	bind(UIS.InputChanged, function(i)
		if dragInput and (i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MMOVE)) then upd(i.Position.X) end
	end)
	bind(UIS.InputEnded, function(i)
		if dragInput and (i == dragInput or (dragInput.UserInputType == MB1 and i.UserInputType == MB1)) then
			dragInput = nil
			card.page.frame.ScrollingEnabled = true
			saveSoon()
		end
	end)
end
function UI.Input(card, text, flag, cb, placeholder)
	local r = row(card, 30)
	local get, setf
	if type(flag) == "table" then
		get, setf = flag.get, flag.set
	else
		get = function() return S[flag] end
		setf = function(v) S[flag] = v end
	end
	local hasText = text and text ~= ""
	if hasText then
		UI.label({ Text = text, TextSize = 13, Size = UDim2.new(0.4, -4, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
	end
	local b = new("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = hasText and UDim2.new(0.6, 0, 0, 26) or UDim2.new(1, 0, 0, 26), Text = tostring(get() or ""),
		PlaceholderText = placeholder or "", ClearTextOnFocus = false, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = r })
	UI.text(b, false)
	UI.elem(b)
	UI.th(b, "TextColor3", "Text")
	UI.th(b, "PlaceholderColor3", "Sub")
	UI.corner(b, 0.7)
	UI.stroke(b, 0.5)
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 6), Parent = b })
	b.FocusLost:Connect(function()
		setf(b.Text)
		if cb then task.spawn(cb, b.Text) end
		saveSoon()
	end)
	UI.addRefresh(type(flag) == "string" and flag or nil, function()
		if not b:IsFocused() then b.Text = tostring(get() or "") end
	end)
	return b
end
function UI.Button(card, text, cb, primary)
	local r = row(card, 32)
	local b = new("TextButton", { Size = UDim2.fromScale(1, 1), AutoButtonColor = false, Text = "", BackgroundColor3 = WHITE, Parent = r })
	UI.corner(b, 0.8)
	if primary then
		UI.grad(b)
	else
		UI.elem(b)
		UI.stroke(b, 0.45)
	end
	local l = UI.label({ Text = text, TextSize = 13, Size = UDim2.fromScale(1, 1), TextColor3 = WHITE, Parent = b }, true,
		(not primary) and "Text" or false)
	if primary then l.TextColor3 = Color3.fromRGB(8, 32, 90) end
	b.Activated:Connect(function()
		task.spawn(function()
			local ok, err = pcall(cb)
			if not ok then
				log(text .. " error: " .. tostring(err))
				notify("Error", tostring(err), 4)
			end
		end)
	end)
	return b, l
end
function UI.Buttons(card, list)
	local r = row(card, 32)
	local n = #list
	for i, item in ipairs(list) do
		local b = new("TextButton", { Size = UDim2.new(1 / n, -4, 1, 0), Position = UDim2.new((i - 1) / n, (i == 1) and 0 or 3, 0, 0),
			AutoButtonColor = false, Text = "", Parent = r })
		UI.elem(b)
		UI.corner(b, 0.8)
		UI.stroke(b, 0.45)
		UI.label({ Text = item[1], TextSize = 12, Size = UDim2.fromScale(1, 1), TextTruncate = Enum.TextTruncate.AtEnd, Parent = b }, true, "Text")
		b.Activated:Connect(function()
			task.spawn(function()
				local ok, err = pcall(item[2])
				if not ok then
					log(item[1] .. " error: " .. tostring(err))
					notify("Error", tostring(err), 4)
				end
			end)
		end)
	end
end
function UI.Dropdown(card, text, flag, options, cb)
	local r = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		LayoutOrder = nextOrder(card), Parent = card.frame })
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = r })
	local head = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 1, Parent = r })
	local hasText = text and text ~= ""
	if hasText then
		UI.label({ Text = text, TextSize = 13, Size = UDim2.new(0.4, -4, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = head }, false, "Text")
	end
	local btn = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		Size = hasText and UDim2.new(0.6, 0, 0, 26) or UDim2.new(1, 0, 0, 26), AutoButtonColor = false, Text = "", Parent = head })
	UI.elem(btn)
	UI.corner(btn, 0.7)
	UI.stroke(btn, 0.45)
	local val = UI.label({ Text = "", TextSize = 12, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -26, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn }, false, "Text")
	local arrow = UI.label({ Text = "v", TextSize = 11, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(12, 12), Parent = btn }, true, "Text")
	local list = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, LayoutOrder = 2, Parent = r })
	UI.elem(list)
	UI.corner(list, 0.7)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
	new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = list })
	local function getOpts()
		if type(options) == "function" then
			local ok, o = pcall(options)
			if ok and type(o) == "table" then return o end
			return {}
		end
		return options
	end
	local function show() val.Text = (S[flag] == nil or S[flag] == "") and "None" or tostring(S[flag]) end
	local function build()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for i, o in ipairs(getOpts()) do
			local sel = (o == S[flag])
			local ob = new("TextButton", { Size = UDim2.new(1, 0, 0, 24), AutoButtonColor = false, Text = "", BackgroundColor3 = WHITE,
				BackgroundTransparency = sel and 0.7 or 1, LayoutOrder = i, Parent = list })
			UI.corner(ob, 0.6)
			UI.label({ Text = "  " .. tostring(o), TextSize = 12, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ob }, sel, "Text")
			ob.Activated:Connect(function()
				list.Visible = false
				arrow.Text = "v"
				UI.set(flag, o, false)
				if cb then task.spawn(cb, o) end
			end)
		end
	end
	btn.Activated:Connect(function()
		if list.Visible then
			list.Visible = false
			arrow.Text = "v"
		else
			build()
			list.Visible = true
			arrow.Text = "^"
		end
	end)
	UI.addRefresh(flag, show)
	show()
end
function UI.Keybind(card, text, get, setk)
	local r = row(card, 30)
	UI.label({ Text = text, TextSize = 13, Size = UDim2.new(1, -104, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = r }, false, "Text")
	local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(96, 26),
		AutoButtonColor = false, Text = "", Parent = r })
	UI.elem(b)
	UI.corner(b, 0.7)
	UI.stroke(b, 0.45)
	local l = UI.label({ Text = "", TextSize = 12, Size = UDim2.fromScale(1, 1), Parent = b }, true, "Text")
	local function show()
		local k = get()
		l.Text = (k and k ~= "") and k or "None"
	end
	show()
	table.insert(UI.refresh, show)
	b.Activated:Connect(function()
		l.Text = "press key..."
		UI.listening = function(name)
			setk(name or "")
			show()
			saveSoon()
		end
		task.delay(6, function()
			if l.Text == "press key..." then
				UI.listening = nil
				show()
			end
		end)
	end)
end

-- show / hide --------------------------------------------------------------
UI.visible = true
function UI.show(v)
	UI.visible = v
	if v then
		Window.Visible = true
		local target = WinScale.Scale
		WinScale.Scale = target * 0.9
		TweenService:Create(WinScale, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = target }):Play()
	else
		Window.Visible = false
		UI.fitScale()
	end
	if UI.blur then UI.blur.Size = (v and S.BlurSize) or 0 end
end
function UI.toggleMenu() UI.show(not Window.Visible) end
CloseBtn.Activated:Connect(function() JH.Unload() end)
local collapsed = false
CollapseBtn.Activated:Connect(function()
	collapsed = not collapsed
	Body.Visible = not collapsed
	Window.Size = collapsed and UDim2.fromOffset(560, 46) or UDim2.fromOffset(560, 340)
end)
bind(cam():GetPropertyChangedSignal("ViewportSize"), function() UI.fitScale() end)

-- moving JH logo (tap to open / close, drag to move) ---------------------------
local LogoRoot = new("Frame", { Name = "LogoRoot", Size = UDim2.fromOffset(S.LogoSize, S.LogoSize), BackgroundTransparency = 1, Parent = gui })
if S.LogoX >= 0 and S.LogoY >= 0 then
	LogoRoot.Position = UDim2.fromOffset(S.LogoX, S.LogoY)
else
	LogoRoot.Position = UDim2.new(0, 14, 0.4, 0)
end
local LogoGlow = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1.5, 1.5),
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.82, ZIndex = 0, Parent = LogoRoot })
UI.corner(LogoGlow, 2)
local LogoBody = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, ZIndex = 2, Parent = LogoRoot })
UI.corner(LogoBody, 1.6)
LogoBody.BackgroundColor3 = Color3.fromRGB(12, 14, 32)
UI.FloatBodyGrad = new("UIGradient", { Rotation = 30, Parent = LogoBody })
UI.FloatBodyGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 14, 32)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 78, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 32)) })
local LogoRing = new("UIStroke", { Thickness = 2.5, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = LogoBody })
local LogoRingGrad = new("UIGradient", { Parent = LogoRing })
LogoRingGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 0) })
LogoRingGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 221, 64)), ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 221, 64)) })
local LogoText = UI.label({ Text = "", TextSize = 22, Size = UDim2.fromScale(1, 1), TextColor3 = WHITE, ZIndex = 3, Parent = LogoBody }, true, false)
local Spark1 = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), BackgroundColor3 = WHITE, ZIndex = 4, Parent = LogoRoot })
UI.corner(Spark1, "pill")
local Spark2 = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5), BackgroundColor3 = WHITE, BackgroundTransparency = 0.25, ZIndex = 4, Parent = LogoRoot })
UI.corner(Spark2, "pill")
UI.LogoRoot, UI.LogoBody, UI.LogoText = LogoRoot, LogoBody, LogoText
do
	local lj = UI.label({ Text = "J", TextScaled = true, Position = UDim2.fromScale(0.1, 0.27), Size = UDim2.fromScale(0.28, 0.46), TextColor3 = WHITE, ZIndex = 3, Parent = LogoBody }, true, false)
	local lh = UI.label({ Text = "H", TextScaled = true, Position = UDim2.fromScale(0.62, 0.27), Size = UDim2.fromScale(0.28, 0.46), TextColor3 = WHITE, ZIndex = 3, Parent = LogoBody }, true, false)
	UI.makeBolt(LogoBody, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.36, 0.62), 3)
	UI.FloatLetters = { lj, lh }
end
dragify(LogoBody, LogoRoot, UI.toggleMenu, function()
	S.LogoX, S.LogoY = LogoRoot.AbsolutePosition.X, LogoRoot.AbsolutePosition.Y
	saveSoon()
end)

-- info bar ----------------------------------------------------------------
local InfoBar = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6), Size = UDim2.fromOffset(0, 24),
	AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.Glass, BackgroundTransparency = 0.45, Parent = gui })
UI.corner(InfoBar, 0.8)
new("UIStroke", { Thickness = 1.5, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = InfoBar })
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = InfoBar })
local InfoText = UI.label({ Text = "", TextSize = 12, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = InfoBar }, true, "Text")

-- backup shoot button (optional) --------------------------------------------
local BackupBtn = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(92, 44), Position = UDim2.new(1, -112, 0.55, 0),
	BackgroundColor3 = WHITE, Visible = false, Parent = gui })
UI.corner(BackupBtn, 0.9)
UI.grad(BackupBtn)
new("UIStroke", { Thickness = 2, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = BackupBtn })
UI.label({ Text = "GREEN SHOT", TextSize = 12, Size = UDim2.fromScale(1, 1), TextColor3 = Color3.fromRGB(8, 32, 90), Parent = BackupBtn }, true, false)
dragify(BackupBtn, BackupBtn, function() Shot.run("backup") end)

---------------------------------------------------------------------
-- PAGES
---------------------------------------------------------------------
local execName = "Unknown"
pcall(function()
	if identifyexecutor then
		local a, b = identifyexecutor()
		execName = tostring(a or "Unknown") .. ((b and b ~= "") and (" " .. tostring(b)) or "")
	elseif getexecutorname then
		execName = tostring(getexecutorname())
	end
end)
JH.execName = execName
local placeName = "Practical Basketball"
JH.placeName = placeName
task.spawn(function()
	pcall(function()
		placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name
		JH.placeName = placeName
	end)
end)
local function has(f) return f ~= nil and "yes" or "no" end
local R = {}

-- MAIN ---------------------------------------------------------------------
local P = UI.Page("Main", "M")
do
	local c = UI.Card(P, "Profile")
	local prof = row(c, 62)
	local av = new("ImageLabel", { Size = UDim2.fromOffset(58, 58), Position = UDim2.fromOffset(0, 2), BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.85, Parent = prof })
	UI.corner(av, "pill")
	new("UIStroke", { Thickness = 2, Color = WHITE, Parent = av })
	UI.label({ Text = LP.DisplayName, TextSize = 17, Position = UDim2.fromOffset(70, 8), Size = UDim2.new(1, -70, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof }, true, "Text")
	UI.label({ Text = "@" .. LP.Name, TextSize = 12, Position = UDim2.fromOffset(70, 32), Size = UDim2.new(1, -70, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = prof }, false, "Sub")
	task.spawn(function()
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if ok and url then av.Image = url end
	end)
	UI.Stat(c, "Roblox username").Text = LP.Name
	R.game = UI.Stat(c, "Game")
	R.time = UI.Stat(c, "Time")
	UI.Stat(c, "Executor").Text = execName

	local sv = UI.Card(P, "Server")
	UI.Button(sv, "Rejoin", Net.rejoin, true)
	UI.Buttons(sv, { { "Join new server", function() Net.hop("new") end }, { "Join lower server", function() Net.hop("lower") end } })

	local cc = UI.Card(P, "Codes")
	UI.Input(cc, "", "Codes", nil, "codes separated by spaces")
	UI.Button(cc, "Redeem all codes", Net.redeemAll, true)

	local ae = UI.Card(P, "Auto execute")
	UI.Toggle(ae, "Auto execute", "AutoExec", function(v) Net.autoExec(v) end)

	local rc = UI.Card(P, "Game recorder")
	UI.Toggle(rc, "Record the game", "RecOn", function(v) if v then Rec.start() else Rec.stop() end end)
	R.rec = UI.Stat(rc, "Recorded")
	UI.Buttons(rc, { { "Copy recording", Rec.copy }, { "Clear", Rec.clear } })
	UI.Button(rc, "Copy remote spy (RSpy)", Rec.copySpy)

	local ag = UI.Card(P, "Auto Green status")
	UI.autoStat = { shot = UI.Stat(ag, "Jump shot"), timing = UI.Stat(ag, "Timing"), state = UI.Stat(ag, "State"), last = UI.Stat(ag, "Last shot"), ping = UI.Stat(ag, "Ping fix"),
		adj = UI.Note(ag, "No change yet") }

	local dc = UI.Card(P, "Animation detector")
	UI.detStat = { now = UI.Stat(dc, "Animation now"), type = UI.Stat(dc, "Type"), list = UI.Note(dc, "Play a shot, layup, dunk or post move") }
	UI.Toggle(dc, "Pop up each new animation", "DetNotify")
	UI.Button(dc, "Copy animation list", Anim.detCopy)

	local sr = UI.Card(P, "Shot recorder")
	UI.Toggle(sr, "Record shots (turn off to copy everything)", "RecShots", function(v) if v then Rec.shotStart() else Rec.shotStop() end end)
	UI.Toggle(sr, "Sweep timings while recording", "Sweep")
	UI.Button(sr, "Capture everything about shooting", Rec.captureAll)

	local gs = UI.Card(P, "Game scanner")
	UI.Buttons(gs, { { "Scan game and copy", Rec.scanGame }, { "Copy last scan", Rec.copyScan } })
end

-- SHOOTING -----------------------------------------------------------------
function UI.restore(keys, after)
	for _, k in ipairs(keys) do S[k] = DEFAULTS[k] end
	if after then pcall(after) end
	UI.refreshAll()
	saveSoon()
	notify("Restored", "Back to default", 2)
end
P = UI.Page("Shooting", "S")
do
	local g = UI.Card(P, "Auto Green")
	UI.Toggle(g, "Auto Green", "AutoGreen")
	UI.Dropdown(g, "Shot style (Hold or Tap)", "ShotStyle", { "Hold", "Tap" })
	UI.Slider(g, "Starting hold time", "HoldTime", 0.08, 1.6, 0.005, 3, "s")
	UI.Slider(g, "Release earlier / later", "Nudge", -150, 150, 5, 0, "ms")
	UI.Toggle(g, "Perfect green", "PerfectGreen")
	UI.Note(g, "Makes up for high ping")
	UI.Slider(g, "Perfect green strength", "PerfectGreenPct", 0, 150, 5, 0, "%")

	local ln = UI.Card(P, "Learning")
	UI.Toggle(ln, "Learn timing from results", "Learn")
	UI.Toggle(ln, "Auto-learn new shot animations", "AutoCal")
	UI.Button(ln, "Forget learned animations", function()
		Shot.autoReset()
		notify("Auto Green", "Learned animations cleared", 2)
	end)

	local cal = UI.Card(P, "Auto Calibrate")
	UI.Toggle(cal, "Auto Calibrate", "AutoCalibrate")
	UI.Slider(cal, "Learn speed", "CalSpeed", 0.1, 1, 0.05, 2)

	local at = UI.Card(P, "Auto Timing")
	UI.Toggle(at, "Auto Timing", "AutoTiming")
	UI.Slider(at, "Ping compensation", "PingComp", 0, 100, 5, 0, "%")

	local rs = UI.Card(P, "Restore")
	UI.Button(rs, "Restore to default", function()
		UI.restore({ "AutoGreen", "ShotStyle", "HoldTime", "Nudge", "Learn", "PerfectGreen", "PerfectGreenPct", "AutoCalibrate", "CalSpeed", "AutoTiming", "PingComp", "ShotTimes",
			"ShotRatio", "PacketMul", "PacketOn" }, function()
			Shot.parseTimes()
			Shot.brackets = {}
		end)
	end)
end

-- DRIBBLING ----------------------------------------------------------------
P = UI.Page("Dribbling", "D")
do
	local d = UI.Card(P, "Dribble Glide")
	UI.Toggle(d, "Dribble Glide", "DribbleGlide")
	UI.Slider(d, "Glide speed", "DribbleGlidePower", 1, 80, 1, 0)
	UI.Slider(d, "Time", "DribbleGlideTime", 0.05, 1, 0.01, 2, "s")

	local sg = UI.Card(P, "Shot Glide")
	UI.Toggle(sg, "Shot Glide", "ShotGlide")
	UI.Slider(sg, "Glide speed", "ShotGlidePower", 1, 80, 1, 0)
	UI.Slider(sg, "Time", "ShotGlideTime", 0.05, 1, 0.01, 2, "s")

	local gt = UI.Card(P, "Gather Step Glide")
	UI.Toggle(gt, "Gather Step Glide", "GatherGlide")
	UI.Slider(gt, "Glide speed", "GatherGlidePower", 1, 80, 1, 0)
	UI.Slider(gt, "Time", "GatherGlideTime", 0.05, 1, 0.01, 2, "s")

	local rs = UI.Card(P, "Restore")
	UI.Button(rs, "Restore to default", function()
		UI.restore({ "DribbleGlide", "DribbleGlidePower", "DribbleGlideTime", "ShotGlide", "ShotGlidePower", "ShotGlideTime", "GatherGlide",
			"GatherGlidePower", "GatherGlideTime" })
	end)
end

-- PLAYERS ------------------------------------------------------------------
P = UI.Page("Players", "P")
do
	local b = UI.Card(P, "Walk speed boost (walking, no ball)")
	UI.Toggle(b, "Walk speed boost", "SpeedOn", function(v) if v then Speed.resetAuto() end end)
	UI.Slider(b, "Level (0 = normal speed)", "SpeedAdd", 0, 15, 1, 0)

	local rb = UI.Card(P, "Run speed boost (running, no ball)")
	UI.Toggle(rb, "Run speed boost", "RunOn", function(v) if v then Speed.resetAuto() end end)
	UI.Slider(rb, "Level (0 = normal speed)", "RunAdd", 0, 15, 1, 0)

	local bb = UI.Card(P, "Ball speed boost (with the ball)")
	UI.Toggle(bb, "Ball speed boost", "BallSpeedOn", function(v) if v then Speed.resetAuto() end end)
	UI.Slider(bb, "Level (0 = normal speed)", "BallAdd", 0, 15, 1, 0)

	local rs = UI.Card(P, "Restore")
	UI.Button(rs, "Restore to default", function()
		UI.restore({ "SpeedOn", "SpeedAdd", "RunOn", "RunAdd", "BallSpeedOn", "BallAdd" }, function() Speed.resetAuto() end)
	end)
end

-- BALL ---------------------------------------------------------------------
P = UI.Page("Ball Mags", "B")
do
	local m = UI.Card(P, "Ball magnet")
	UI.Toggle(m, "Ball magnet", "BallMagnet")
	UI.Dropdown(m, "How it gets the ball", "MagnetMode", { "Pull to me", "Go to the ball" })
	UI.Slider(m, "Range", "MagnetRange", 10, 150, 5, 0, " studs")
	UI.Slider(m, "Minimum time on the ball (frames)", "MagnetFrames", 1, 6, 1, 0)
	UI.Button(m, "Get the ball now", function()
		if not Feat.getBall(true) then notify("Ball magnet", "No ball found.", 2) end
	end)

	local rs = UI.Card(P, "Restore")
	UI.Button(rs, "Restore to default", function()
		UI.restore({ "BallMagnet", "MagnetMode", "MagnetRange", "MagnetFrames" })
	end)
end

-- FEATURES -----------------------------------------------------------------
P = UI.Page("Features", "F")
do
	local lg = UI.Card(P, "Practical Basketball logo")
	UI.Toggle(lg, "Show logo", "LogoOn")
	UI.Dropdown(lg, "Logo", "Logo", Feat.V.LOGO_NAMES)

	local mc = UI.Card(P, "Mascot")
	UI.Toggle(mc, "Mascot", "MascotOn")
	UI.Dropdown(mc, "Pick a mascot", "Mascot", Feat.V.MASCOT_NAMES)

	local mx = UI.Card(P, "Maxed stats (only you see this)")
	UI.Toggle(mx, "Max overall", "MaxOverall")
	UI.Toggle(mx, "Max coins", "MaxCoins")
	UI.Toggle(mx, "Max badges", "MaxBadges")

	local rs = UI.Card(P, "Restore")
	UI.Button(rs, "Restore to default", function()
		UI.restore({ "LogoOn", "Logo", "MascotOn", "Mascot", "MaxOverall", "MaxCoins", "MaxBadges" })
	end)
end

-- UI -----------------------------------------------------------------------
P = UI.Page("UI", "U")
do
	local gl = UI.Card(P, "Glass look")
	UI.Slider(gl, "Menu transparency", "WinTrans", 0, 0.95, 0.01, 2, nil, function() UI.applyWindow() end)
	UI.Slider(gl, "Card transparency", "CardTrans", 0.3, 0.98, 0.01, 2, nil, function() UI.applyTheme() end)
	UI.Slider(gl, "Color shade (hue)", "Hue", 0, 360, 1, 0, nil, function() UI.applyTheme() end)
	UI.Slider(gl, "Color strength", "Sat", 0.1, 1, 0.01, 2, nil, function() UI.applyTheme() end)
	UI.Slider(gl, "Brightness", "Val", 0.2, 1, 0.01, 2, nil, function() UI.applyTheme() end)

	local ol = UI.Card(P, "Outline")
	UI.Dropdown(ol, "Outline color", "OutlineColor", OUTLINE_NAMES, function() UI.applyTheme() end)
	UI.Slider(ol, "Outline thickness", "OutlineThick", 0, 6, 0.5, 1, nil, function() UI.applyWindow() end)
	UI.Toggle(ol, "Moving outline shine", "OutlineShine", function() UI.applyWindow() end)

	local tx = UI.Card(P, "Text")
	UI.Dropdown(tx, "Text color", "TextColor", TEXT_NAMES, function() UI.applyTheme() end)
	UI.Toggle(tx, "Dark text outline", "TextStroke", function() UI.applyTheme() end)
	UI.Dropdown(tx, "Font", "Font", FONT_NAMES, function() UI.applyTheme() UI.refreshTabs() end)

	local ly = UI.Card(P, "Layout")
	UI.Slider(ly, "Corner roundness", "Corner", 0, 20, 1, 0, nil, function() UI.applyTheme() end)
	UI.Slider(ly, "Menu size", "UIScale", 0.6, 1.5, 0.05, 2, "x", function() UI.fitScale() end)
	UI.Toggle(ly, "Info bar", "Watermark", function() InfoBar.Visible = S.Watermark end)
	UI.Button(ly, "Put the menu back in the middle", function() UI.recenter() end)

	local lg = UI.Card(P, "Logo")
	UI.Slider(lg, "Logo size", "LogoSize", 36, 96, 2, 0, nil, function() UI.applyLogo() end)
	UI.Slider(lg, "Logo visibility", "LogoOpacity", 0.3, 1, 0.05, 2, nil, function() UI.applyLogo() end)
	UI.Toggle(lg, "Moving logo animation", "LogoAnim")
	UI.Button(lg, "Reset logo position", function()
		S.LogoX, S.LogoY = -1, -1
		LogoRoot.Position = UDim2.new(0, 14, 0.4, 0)
		saveSoon()
	end)

	local pr = UI.Card(P, "Presets")
	UI.Note(pr, "One tap look changes. Everything below can still be tuned by hand.")
	UI.Dropdown(pr, "Theme preset", "Preset", UI.PRESET_NAMES, function(v) UI.applyPreset(v) end)
	UI.Dropdown(pr, "Accent colors", "AccentMode", { "Gold", "Match hue" }, function() UI.applyTheme() end)

	local lt = UI.Card(P, "Lightning")
	UI.Toggle(lt, "Lightning background", "Lightning", function() UI.applyFx() end)
	UI.Dropdown(lt, "Lightning colors", "BoltColor", { "White + Yellow", "Yellow", "White" })
	UI.Slider(lt, "Lightning amount", "BoltCount", 1, 10, 1, 0)
	UI.Slider(lt, "Lightning speed", "BoltSpeed", 0.3, 3, 0.1, 1, "x")
	UI.Slider(lt, "Lightning thickness", "BoltThick", 1, 5, 0.5, 1)
	UI.Slider(lt, "Lightning brightness", "BoltBright", 0.2, 1, 0.05, 2)

	local bgc = UI.Card(P, "Moving background")
	UI.Toggle(bgc, "Moving background", "BgMove")
	UI.Slider(bgc, "Background glow", "BgGlow", 0, 1, 0.05, 2, nil, function() UI.paintStorm() end)
	UI.Toggle(bgc, "Floating light orbs", "BgOrbs")

	local hl = UI.Card(P, "Header logo")
	UI.Dropdown(hl, "Logo style", "LogoStyle", { "J bolt H", "JHub V1" }, function() UI.applyFx() end)
	UI.Toggle(hl, "Moving logo background", "LogoBg")
	UI.Slider(hl, "Moving outline speed", "OutlineSpeed", 0, 4, 0.1, 1, "x")

	local al = UI.Card(P, "Alerts and keys")
	UI.Toggle(al, "Notifications", "Notifications")
	UI.Toggle(al, "Sounds", "Sounds")
	UI.Keybind(al, "Menu key (PC)", function() return S.MenuKey end, function(v) S.MenuKey = (v ~= "" and v) or "RightShift" end)

	local tl = UI.Card(P, "Tools")
	UI.Button(tl, "Save settings now", function()
		save()
		notify("Saved", "Settings saved", 2)
	end)
	UI.Button(tl, "Reset all settings", function()
		for k, v in pairs(DEFAULTS) do S[k] = v end
		UI.refreshAll()
		saveSoon()
		notify("Reset", "All settings back to default", 2)
	end)
	UI.Button(tl, "Unload JHub", function() JH.Unload() end)

	local rs = UI.Card(P, "Restore")
	UI.Button(rs, "Restore to default", function()
		UI.restore({ "WinTrans", "CardTrans", "Hue", "Sat", "Val", "OutlineColor", "OutlineThick", "OutlineShine", "TextColor", "TextStroke",
			"Font", "Corner", "UIScale", "Watermark", "LogoSize", "LogoOpacity", "LogoAnim", "Notifications", "Sounds", "MenuKey" }, function()
			UI.applyTheme()
			UI.applyWindow()
			UI.applyLogo()
			UI.fitScale()
			InfoBar.Visible = S.Watermark
			UI.refreshTabs()
		end)
	end)
end

---------------------------------------------------------------------
-- INPUT HOOKS
---------------------------------------------------------------------
bind(UIS.InputBegan, function(i, gp)
	if Rec.on then pcall(Rec.input, "down", i) end
	if Picker.mode and (i.UserInputType == TOUCH or i.UserInputType == MB1) then
		local mode = Picker.mode
		Picker.mode = nil
		task.defer(Picker.handle, mode, i.Position)
		return
	end
	if i.UserInputType == TOUCH then
		-- taps on JHub's own window, logo or buttons must never count as a move or a shot
		if Window.Visible and Input.hits(Window, i.Position) then return end
		if Input.hits(LogoRoot, i.Position) then return end
		if BackupBtn.Visible and Input.hits(BackupBtn, i.Position) then return end
		Input.lastTouch = { input = i, t0 = tick(), pos = i.Position, obj = Input.topButtonAt(i.Position) }
		-- the game's on-screen move buttons start a glide
		if (S.DribbleGlide or S.GatherGlide) and not Shot.hooked then
			for _, kind in ipairs({ "dribble", "gather" }) do
				for _, b in ipairs(Input.glideButtons(kind)) do
					if b.Parent and visibleChain(b) and Input.hits(b, i.Position) then
						Glide.fire(kind, "touch on the " .. kind .. " button")
						break
					end
				end
			end
		end
		-- the game's on-screen sprint button: held means running
		if S.RunOn then
			local sb = Input.findButton("Sprint")
			if sb and visibleChain(sb) and Input.hits(sb, i.Position) then Input.sprintTouch = i end
		end
		-- shot glide when JHub is not the one taking the shot
		if S.ShotGlide and not (S.AutoGreen and S.HookShootButton) and not Shot.hooked then
			local gb = Input.findButton("Shoot")
			if gb and visibleChain(gb) and Input.hits(gb, i.Position) then Glide.fire("shot", "touch on the shoot button") end
		end
		if (S.AutoGreen or Bar.isArmed()) and S.HookShootButton and not Shot.busy and not Shot.hooked then
			local btn = Input.findButton("Shoot")
			if btn and visibleChain(btn) and Input.hits(btn, i.Position) then
				local ctx = { btn = btn, input = i, t0 = tick(), ended = false }
				Shot.touchCtx = ctx
				task.spawn(Shot.run, "touch", ctx)
			end
		end
		return
	end
	if i.UserInputType ~= KEYBOARD then return end
	if UI.listening then
		local f = UI.listening
		UI.listening = nil
		if i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Backspace then f("") else f(i.KeyCode.Name) end
		return
	end
	if UIS:GetFocusedTextBox() then return end
	local kc = i.KeyCode
	if kc == Input.keyCode(S.MenuKey) then
		UI.toggleMenu()
		return
	end
	if Shot.busy then return end
	if kc == Input.keyCode(S.ShootKey) then
		if S.ManualAssist and (S.AutoGreen or Bar.isArmed()) and not Shot.hooked then task.spawn(Shot.run, "manualKey", { kc = kc, t0 = tick() }) end
		return
	end
	local keys = tokens(S.DribbleKeys)
	for _, name in ipairs(keys) do
		if Input.keyCode(name) == kc and (Ball.holding or not next(Ball.parts)) and not Shot.hooked then
			Glide.fire("dribble", "key " .. name)
			break
		end
	end
end)
bind(UIS.InputEnded, function(i)
	local ctx = Shot.touchCtx
	if ctx and i == ctx.input then ctx.ended = true end
	if Rec.on then pcall(Rec.input, "up", i) end
	if Input.lastTouch and Input.lastTouch.input == i then Input.lastTouch.endT = tick() end
	if Input.sprintTouch == i then Input.sprintTouch = nil end
end)

---------------------------------------------------------------------
-- LOOPS
---------------------------------------------------------------------
local rainbowHue = 0
bind(RunService.Heartbeat, function(dt)
	JH.FPS = JH.FPS * 0.9 + (1 / math.max(dt, 0.001)) * 0.1
	pcall(Anim.poll)
	local t = tick()
	if Window.Visible then
		StrokeGrad.Rotation = (t * 70 * (S.OutlineSpeed or 1)) % 360
		local off = (((t * 0.4) % 2) - 1)
		LogoTextGrad.Offset = Vector2.new(off, 0)
		if S.OutlineColor == "Rainbow" then
			rainbowHue = (rainbowHue + dt * 0.25) % 1
			MainStroke.Color = Color3.fromHSV(rainbowHue, 0.55, 1)
		end
	end
	-- the moving logo: bobbing, pulsing glow, spinning ring and two orbiting sparks
	if S.LogoAnim then
		LogoBody.Position = UDim2.fromOffset(0, math.sin(t * 2.2) * 3)
		LogoGlow.BackgroundTransparency = 0.8 + math.sin(t * 3) * 0.08
		LogoRingGrad.Rotation = (t * 120) % 360
		local a = t * 2.4
		Spark1.Position = UDim2.new(0.5, math.cos(a) * S.LogoSize * 0.62, 0.5, math.sin(a) * S.LogoSize * 0.62)
		Spark2.Position = UDim2.new(0.5, math.cos(a + 3.14) * S.LogoSize * 0.55, 0.5, math.sin(a + 3.14) * S.LogoSize * 0.55)
		Spark1.Visible, Spark2.Visible = true, true
	else
		LogoBody.Position = UDim2.fromOffset(0, 0)
		Spark1.Visible, Spark2.Visible = false, false
	end
end)

bind(RunService.Stepped, function(_, dt)
	local ok, err = pcall(Speed.step, dt)
	if not ok and Speed.lastErr ~= tostring(err) then
		Speed.lastErr = tostring(err)
		log("Speed error: " .. Speed.lastErr)
		notify("Speed problem", Speed.lastErr, 5)
	end
end)

task.spawn(function()
	local count = 0
	while JH.Running do
		count = count + 1
		local ok, holding, source = pcall(Ball.check)
		if ok then
			Ball.holding, Ball.source = holding, source
		end
		pcall(Feat.tick, count)
		task.wait(0.1)
	end
end)

task.spawn(function()
	while JH.Running do
		pcall(function()
			local now = os.date("*t")
			local hr = now.hour % 12
			if hr == 0 then hr = 12 end
			local timeStr = string.format("%d:%02d:%02d %s", hr, now.min, now.sec, now.hour >= 12 and "PM" or "AM")
			local ping = 0
			pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000) end)
			local fps = math.floor(JH.FPS + 0.5)
			InfoText.Text = string.format("JHub V1  |  %d FPS  |  %d ms  |  %s", fps, ping, timeStr)
				.. (Speed.extra > 0 and string.format("  |  BOOST +%.0f", Speed.extra) or "")
			if not Window.Visible then return end
			if UI.current and UI.current.name == "Main" then
				R.game.Text = placeName
				R.time.Text = timeStr
				R.rec.Text = Rec.summary()
			end
		end)
		task.wait(0.25)
	end
end)

---------------------------------------------------------------------
-- UNLOAD
---------------------------------------------------------------------
function JH.Unload()
	JH.Running = false
	for _, c in ipairs(JH.Connections) do pcall(function() c:Disconnect() end) end
	pcall(Shot.release, "manualKey", nil)
	if Feat.sprinting then pcall(Input.action, "Sprint", false) end
	local h = hum()
	if h and Speed.lastSet then pcall(function() h.WalkSpeed = Speed.gameWS end) end
	if UI.blur then pcall(function() UI.blur:Destroy() end) end
	pcall(Speed.gvRestore)
	pcall(Feat.V.cleanup)
	pcall(Rec.stop)
	save()
	pcall(function() gui:Destroy() end)
	if genv.JHubGlass == JH then genv.JHubGlass = nil end
end
JH.api = { S = S, UI = UI, Net = Net, Input = Input, Ball = Ball, Shot = Shot, Backup = Backup, Glide = Glide, Anim = Anim,
	Speed = Speed, Feat = Feat, Picker = Picker, Bar = Bar, Mover = Mover, Rec = Rec }

---------------------------------------------------------------------
-- START
---------------------------------------------------------------------
UI.applyTheme()
UI.applyFx()
for _, f in ipairs(UI.refresh) do pcall(f) end
InfoBar.Visible = S.Watermark
BackupBtn.Visible = S.BackupButton
UI.select(UI.pages[1])
UI.show(true)

local pg = LP:WaitForChild("PlayerGui")
Shot.parseTimes()
Shot.hookRoot(pg)
-- the feedback text and the shot bar are drawn in the 3D world, so the whole workspace is watched too
Shot.hookRoot(workspace, true)
-- the player's rig can sit in workspace.Characters instead of LP.Character
task.spawn(function()
	local seen
	while JH.Running do
		local c = char()
		if c and c ~= seen then
			seen = c
			Anim.hookChar(c)
		end
		task.wait(1)
	end
end)
-- learns the shoot button from your own shots
task.spawn(function()
	while JH.Running do
		pcall(Shot.watch)
		task.wait(0.2)
	end
end)
-- two fingers on the menu: pinch to resize it
pcall(function()
	local pinchStart = nil
	bind(UIS.TouchPinch, function(positions, scale, velocity, state)
		if not Window.Visible then return end
		if state == Enum.UserInputState.Begin then
			pinchStart = nil
			local inside = #positions >= 2
			for _, p in ipairs(positions) do
				if not Input.hits(Window, p) then inside = false end
			end
			if inside then pinchStart = S.UIScale end
		elseif state == Enum.UserInputState.Change and pinchStart then
			local v = math.floor(clamp(pinchStart * scale, 0.6, 1.5) * 100 + 0.5) / 100
			if v ~= S.UIScale then
				UI.set("UIScale", v, false)
				UI.fitScale()
				UI.keepOnScreen()
			end
		else
			pinchStart = nil
		end
	end)
end)
-- gather steps show up as the character's Action
task.spawn(function()
	local last = ""
	while JH.Running do
		local c = char()
		local a = c and c:GetAttribute("Action")
		if type(a) == "string" and a ~= last then
			last = a
			if a == "Gathering" and c:GetAttribute("GatherType") ~= "Pumpfake" then pcall(Glide.fire, "gather", "gather step") end
		end
		task.wait(0.03)
	end
end)
-- the ball magnet
task.spawn(function()
	while JH.Running do
		pcall(Feat.magnetStep)
		pcall(Shot.statusStep)
		pcall(Feat.V.step)
		task.wait(0.05)
	end
end)
-- the game's own shoot signal, meter and result messages
pcall(Rec.hook)
pcall(Shot.connectRemotes)
if S.AutoExec then pcall(Net.queueTeleport) end
task.spawn(function()
	Ball.rescan()
	log(string.format("Scan: %d ball part(s) found", Ball.count()))
end)
bind(workspace.DescendantAdded, function(d) pcall(Ball.consider, d) end)
log("JHub Glass loaded on " .. execName)
notify("JHub V1", (IS_MOBILE and "Tap the moving JH logo to open or close the menu." or "Press " .. S.MenuKey .. " or click the JH logo to open or close the menu.") .. "  Welcome, " .. LP.DisplayName .. "!", 5)
playSound(SND_CLICK, 0.4)

end -- JHubMain

local ok, err = xpcall(JHubMain, function(e) return tostring(e) .. "\n" .. debug.traceback() end)
if not ok then
	warn("[JHub] failed to load: " .. tostring(err))
	pcall(function()
		local sg = Instance.new("ScreenGui")
		sg.Name = "JHubError"
		sg.ResetOnSpawn = false
		local okP = pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
		if not okP or not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
		local box = Instance.new("TextButton")
		box.Size = UDim2.fromOffset(440, 230)
		box.Position = UDim2.new(0.5, -220, 0.5, -115)
		box.BackgroundColor3 = Color3.fromRGB(10, 30, 70)
		box.TextColor3 = Color3.new(1, 1, 1)
		box.Font = Enum.Font.Code
		box.TextSize = 12
		box.TextWrapped = true
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.TextYAlignment = Enum.TextYAlignment.Top
		box.Text = "JHub failed to load. Screenshot this and send it (tap to close):\n\n" .. tostring(err)
		box.Parent = sg
		box.Activated:Connect(function() sg:Destroy() end)
		if setclipboard then pcall(setclipboard, tostring(err)) end
	end)
end
