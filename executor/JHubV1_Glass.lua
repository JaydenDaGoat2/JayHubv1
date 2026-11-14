local a=[==[
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
local VERSION = "v1.86"
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
local function notify(title, msg, dur) if string.find(tostring(title), "^Glide") or string.find(tostring(title), "^Speed boost") then return end if UI.notify then UI.notify(title, msg, dur) end end
local S = {
WinTrans = 0.5, CardTrans = 0.78, Hue = 212, Sat = 0.85, Val = 0.85, WinGradient = true,
OutlineColor = "White", OutlineThick = 2, OutlineShine = true,
TextColor = "White", TextStroke = true, Font = "Gotham", Corner = 10, UIScale = 1,
LogoSize = 58, LogoOpacity = 1, LogoAnim = true, LogoX = -1, LogoY = -1,
Blur = false, BlurSize = 10, Watermark = true, Notifications = true, Sounds = true, MenuKey = "RightShift",
Codes = "100M 100KLIKES 500KMEMBERS 100KCCUPLS RELEASE SORRYFORBUGS", CodeRemotes = true,
AutoGreen = true, AutoCalibrate = true, AutoTiming = true, ShotRelease = "Auto",
HoldTime = 0.55, MaxHold = 1.6, CalSpeed = 1.0, CalStep = 0.035,
ShotTimes = "", ShotRatio = 0, BarPath = "", BarProp = "", BarAt = 0, BarNudge = 0,
ShotStyle = "Hold", AutoExec = false, BallMagnet = false, MagnetMode = "Pull to me", MagnetRange = 25, Learn = false, PeakLead = 0.027, PerfectGreen = false, PerfectGreenPct = 100, AutoCal = true, AutoTimes = "", Sweep = false, MagnetFrames = 1, LogoOn = false, Logo = "Owner", MascotOn = false, Mascot = "SpongeBob", MaxOverall = false, MaxCoins = false, MaxBadges = false, MeterAim = false, MeterTarget = 1.0, MeterBin = 0.05, Lightning = true, BoltCount = 6, BoltSpeed = 1, BoltThick = 2, BoltBright = 0.9, BoltColor = "White + Yellow", BgMove = true, BgGlow = 0.5, BgOrbs = true, AccentMode = "Gold", OutlineSpeed = 1, LogoStyle = "J bolt H", LogoBg = true, Preset = "Lightning Gold", PacketOn = true, PacketMul = 1,
MovingOffset = 0, SprintOffset = 0, PingComp = 0, Humanize = 0, Nudge = 0, GreenSound = true,
HookShootButton = true, ShootButtonPath = "", ReleaseMethod = "Both", FireClick = true,
ManualAssist = true, ShootKey = "E", SprintKey = "LeftShift",
BackupButton = false, BackupMethod = "touch", BackupInset = false,
DribbleGlide = false, DribbleGlidePower = 30, DribbleGlideTime = 0.45, GlideSpeed = 1,
ShotGlide = false, ShotGlidePower = 22, ShotGlideTime = 0.45,
GatherGlide = false, GatherGlidePower = 26, GatherGlideTime = 0.45,
DribbleGlideSpeed = 1, ShotGlideSpeed = 1, GatherGlideSpeed = 1,
GfxLow = false, GfxEffects = false, GfxTextures = false, GfxShadows = false, GfxPost = false, GfxHideOthers = false, GfxCull = false,
GfxCullDist = 250, GfxBoost = false, GfxFpsCap = 0, PingStab = false, PingWindow = 3, FinalAdj = "",
ShotGlideMethod = "GameVel", ShotGlideWhen = "After release", NoStun = false, StunIds = "", HoopMarks = "",
LagSync = true, LagK = 2, PrecFit = true, PeakBin = 0.014, AdaptPlus = true, GreenMax = true,
AGHuman = true, AGHumanAmt = 50, LogoIds = "", LookUser = "",
AllJumpers = true, GLead = 0, GLeadN = 0, ImportTimes = "", FirstShot = false, PFLead = 0, PFLeadN = 0, AccentTone = "Rainbow",
FadeNudge = 8, MagnetDelay = 120, AutoAdaptAll = true, InstantGreen = true, GlideShotSafe = true, LabOn = true, FamLead = "", SmartSteps = true, ContestShow = false, GuardSpeed = 0, UltraOn = false, GreenSoundId = "", GreenSoundVol = 0.6, CtrlSpyOn = false, GuardSpyOn = false, HardLock = "", GuardKey = "", RGuardOn = false, AGUnlocked = false, LockedUnlocked = false, OwnerUnlocked = false, ShotIntelDB = "",
AGMistakes = false, AGMistakeAmt = 15, ABRecheck = true, ASteal = false, ASRange = 5, ASChance = 60, ASReact = 0.15, ASKey = "", BindLib = "",
AGOnlyBall = true,
BindMove1 = "None", BindMove2 = "None", BindMove3 = "None", BindMove4 = "None", BindMove5 = "None", BindMove6 = "None",
BindKey1 = "", BindArgs1 = "", BindKey2 = "", BindArgs2 = "", BindKey3 = "", BindArgs3 = "", BindKey4 = "", BindArgs4 = "", BindKey5 = "", BindArgs5 = "", BindKey6 = "", BindArgs6 = "",
LowFix = true, LowBoostPct = 25, LowGlidePct = 60, LowLevel = 3,
AG = false, AGTarget = "Ball handler", AGDist = 4, AGReact = 0.08, AGPredict = 0.18, AGRange = 45, AGLock = false, AGFace = true, AGSprint = true, AGHoldToUse = false, WalkAnimId = "", GuardAnimId = "",
AB = false, ABRange = 12, ABDelay = 0.1, ABKey = "Space", ABChance = 100, ABChase = true,
AR = false, ARSpeed = 1, ARReact = 0.18, ARRange = 45, ARJump = true, ARMagnet = true, ARMagRange = 4, ARMarker = false,
AP = false, APBuild = "Small", APPostScore = true, APAllAround = true, APOpenDist = 6, APRange = 24, APThree = true, APDrive = true, APLayups = true, APSprint = true, APMoves = true,
APShotDelay = 0.8, APDefend = true, APRebound = true, APAntiAfk = true, APPause = true, APStaminaMin = 20, APHoop = "Nearest", APPostRange = 8, APSpot = 22, APSpeed = 1, APTeam = "By team",
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
S.AutoCal = S.AutoGreen ~= false
S.Learn = S.AutoCal
if S.PerfectGreen == nil then S.PerfectGreen = false end
if S.PeakLead == nil then S.PeakLead = 0.027 end
if S.LowFix == nil then S.LowFix = true end
if S.LowBoostPct == nil then S.LowBoostPct = 25 end
if S.LowGlidePct == nil then S.LowGlidePct = 60 end
if S.LowLevel == nil then S.LowLevel = 3 end
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
if S.SettingsVer < 29 then S.Codes = DEFAULTS.Codes end
if S.SettingsVer < 31 then S.LagSync, S.PrecFit, S.AdaptPlus = false, false, false end
if S.SettingsVer < 32 then S.LagSync, S.PrecFit, S.AdaptPlus, S.GreenMax, S.Sweep = true, true, true, true, false end
S.Sweep = false -- sweep stays off at all times; it deliberately misses to map timing, never wanted in real play
if S.SettingsVer < 33 then S.FirstShot = false end
if S.SettingsVer < 34 then S.CardTrans = 0.4 end
if S.SettingsVer < 35 then
S.AutoTimes = string.gsub(S.AutoTimes or "", "(%a):(%S-)=([%d%.]+)", function(kind, key, val)
if kind == "l" or kind == "p" then return string.format("%s:%s=%.4f", kind, key, math.max(0, (tonumber(val) or 0) - 0.008)) end
return kind .. ":" .. key .. "=" .. val
end)
end
if S.SettingsVer < 36 then
S.AccentTone, S.ARSpeed, S.ARReact, S.ARRange, S.ARMagRange = "Rainbow", 1, 0.18, 45, 4
if S.MagnetRange > 25 then S.MagnetRange = 25 end
end
S.SettingsVer = 36
DEFAULTS.SettingsVer = 36
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
local ACTION_WORDS = { Shoot = { "shoot", "shot" }, Sprint = { "sprint", "run" }, Guard = { "guard" } }
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
["111074210919383"] = 0.367,
["71484695722621"] = 0.321,
["77401448272074"] = 0.339,
["128777513307709+77401448272074"] = 0.339,
}
Shot.VERDICT = { "Very early", "Early", "Slightly early", "Good", "Perfect", "Slightly late", "Late", "Very late" }
Shot.NAMES = {
["15851912457+15851919155"] = "Jumpshot1RBase",
["15851912457+15851919155+17285155256"] = "Jumpshot1RBase",
["111074210919383"] = "StepPostFade1R",
["71484695722621"] = "PostFadeLeft1R",
["77401448272074"] = "PostFadeRight1R",
["128777513307709+77401448272074"] = "PostFadeRight1R",
}
Shot.keyName = {}
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
local n = Shot.keyName[key] or Shot.NAMES[key]
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
return Shot.nameFor(cur.key, cur.anim), (cur.mode == "peak") and string.format("%.0f ms before the peak", cur.hold * 1000) or string.format("%.3fs", cur.hold), cur.state or "-", last,
(#lines > 0) and table.concat(lines, "\n") or "No change yet", ptxt
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
return clamp(comp, 0, 0.2), p
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
Shot.auto[key] = { hold = tonumber(val), greens = {}, locked = (kind == "L" or kind == "l"), dir = 1, mode = (kind == "l" or kind == "p") and "peak" or nil }
end
end
function Shot.autoSave()
local parts = {}
for key, a in pairs(Shot.auto) do parts[#parts + 1] = string.format("%s:%s=%.4f", a.mode == "peak" and (a.locked and "l" or "p") or (a.locked and "L" or "P"), key, a.hold) end
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
Shot.PEAK_Q = 0.978
function Shot.peakFit(samples)
local pts, lastq = {}, -1
for _, sm in ipairs(samples) do
if sm.q < lastq - 0.001 then break end
lastq = sm.q
if sm.q > 0.12 and sm.q < 0.93 then pts[#pts + 1] = sm end
end
local n = #pts
if n < 6 or pts[n].q < 0.3 then return nil end
local t0 = pts[1].t
local st, sq, stt, stq = 0, 0, 0, 0
for _, p in ipairs(pts) do
local x = p.t - t0
st, sq, stt, stq = st + x, sq + p.q, stt + x * x, stq + x * p.q
end
local den = n * stt - st * st
if den <= 1e-9 then return nil end
local a = (n * stq - st * sq) / den
local b = (sq - a * st) / n
if a < 1.2 or a > 5 then return nil end
return t0 + (Shot.PEAK_Q - b) / a
end
function Shot.peakLearn(info, res, strength, a, key)
if a.locked then return true end
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if not idx then return true end
if info.manual and idx ~= 5 then return true end
local lead = info.lead or a.hold
if not info.manual and math.abs(lead - a.hold) > 0.05 then return true end
local before = a.hold
a.n = (a.n or 0) + 1
local why
if idx == 5 then
a.hold, a.locked = lead, true
S.PeakLead = clamp(S.PeakLead * 0.5 + lead * 0.5, 0, 0.08)
pcall(notify, "Auto Green", string.format("Learned this shot: %.0f ms before the peak", lead * 1000), 3)
why = "Perfect, locked"
else
local d, mag
if idx == 4 then
d, mag = a.dir or 1, 0.4
elseif idx <= 3 then
d, mag = -1, (idx == 3 and 0.7) or (idx == 2 and 1.0) or 1.5
else
d, mag = 1, (idx == 6 and 0.7) or (idx == 7 and 1.0) or 1.5
end
a.step = a.step or 0.012
if idx == 4 then
a.goodRun = (a.goodRun or 0) + 1
a.step = clamp(a.step * ((a.goodRun >= 2) and 1.15 or 0.85), 0.002, 0.008)
else
a.goodRun = 0
if a.lastD and a.lastD ~= d then
a.step = math.max(0.002, a.step * 0.5)
elseif a.lastD == d then
a.step = math.min(0.02, a.step * 1.3)
end
a.lastD, a.dir = d, d
end
a.hold = clamp(lead + d * a.step * mag, 0, 0.1)
S.PeakLead = clamp(S.PeakLead + d * a.step * mag * 0.25, 0, 0.08)
why = (Shot.VERDICT[idx] or "?") .. (d > 0 and ", letting go earlier" or ", letting go later")
end
if math.abs(a.hold - before) > 0.0003 or a.locked then Shot.noteAdjust(key, before, a.hold, why) end
Shot.autoSave()
if Rec.shotOn then
Rec.shotAdd(string.format("AUTOCAL(meter) key=%s idx=%s lead=%.4f next=%.4f locked=%s", key, tostring(idx), lead, a.hold, tostring(a.locked)))
end
return true
end
function Shot.autoLearn(info, res, strength)
local key = info.key
if not Shot.autoActive(key) then return false end
Shot.autoLoad()
local a = Shot.auto[key]
if not a then return false end
if a.locked then return true end
if a.mode == "peak" then return Shot.peakLearn(info, res, strength, a, key) end
local held = (info.held or 0) + (info.comp or 0)
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if not idx or not held then return true end
if info.manual and idx ~= 5 then return true end
if not info.manual and math.abs(held - a.hold) > 0.06 then return true end
a.n = (a.n or 0) + 1
local before, wasLocked = a.hold, a.locked
if idx == 5 then
a.greens[#a.greens + 1] = held
a.hold = held
a.locked = true
pcall(notify, "Auto Green", string.format("Learned this shot: %.3fs", a.hold), 3)
else
local d, mag
if idx == 4 then
d, mag = a.dir or 1, 0.4
elseif idx <= 3 then
d, mag = 1, (idx == 3 and 0.7) or (idx == 2 and 1.0) or 1.5
else
d, mag = -1, (idx == 6 and 0.7) or (idx == 7 and 1.0) or 1.5
end
a.step = a.step or 0.020
if idx == 4 then
a.goodRun = (a.goodRun or 0) + 1
a.step = a.step * ((a.goodRun >= 2) and 1.15 or 0.85)
a.step = clamp(a.step, 0.004, 0.015)
else
a.goodRun = 0
if a.lastD and a.lastD ~= d then
a.step = math.max(0.004, a.step * 0.5)
elseif a.lastD == d then
a.step = math.min(0.04, a.step * 1.3)
end
a.lastD, a.dir = d, d
end
a.hold = held + d * a.step * mag
end
a.hold = clamp(a.hold, Shot.FLOOR, S.MaxHold)
if a.locked and not wasLocked then
Shot.noteAdjust(key, before, a.hold, "Perfect, locked")
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
if fin and S.AdaptPlus then Shot.finalLoad() fin = fin + (Shot.finalAdj[key] or 0) end
if fin then
Shot.lastSweep = nil
Shot.cur = { key = key, hold = fin, state = "Locked (built in)" }
return clamp(fin, Shot.FLOOR, S.MaxHold), fin
end
if Shot.autoActive(key) then
Shot.autoLoad()
local a = Shot.auto[key]
if not a then
a = { hold = Shot.seedLead(key), greens = {}, locked = false, dir = 1, mode = "peak", bin = S.PeakBin }
Shot.auto[key] = a
end
Shot.lastSweep = nil
if a.mode == "peak" then
Shot.cur = { key = key, hold = a.hold, mode = "peak", state = a.locked and "Locked (learned)" or "Learning (by the meter)" }
return a.hold, a.hold, "peak"
end
local state = a.locked and "Locked (learned)" or ((a.n or 0) > 0 and ((a.dir or 1) > 0 and "Learning, trying later" or "Learning, trying earlier")) or "Learning"
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
if info and Shot.FINAL[info.key] then
if S.AdaptPlus then pcall(Shot.finalLearn, info, res, strength) end
return
end
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
local hold, base, mode = Shot.remoteHold(key, pk)
local comp, peakLead = 0, nil
if mode == "peak" then
peakLead = hold
hold = Shot.AUTO_START
else
comp = Shot.pingComp()
if comp ~= 0 then hold = math.max(Shot.FLOOR, hold - comp) end
end
if Shot.cur then Shot.cur.comp = comp end
local manual = false
local usedMeter, qpred = false, nil
local peakAimed = false
local ok0, ping0 = pcall(function() return LP:GetNetworkPing() end)
local lead = (ok0 and ping0 or 0.04) + 0.016 + S.Nudge / 1000
local look = Shot.lookAhead()
while tick() - m0 < S.MaxHold do
if ctx.ended then
manual = true
break
end
local now = tick()
local n = #samples
if peakLead then
local tp = Shot.peakFitSmart(samples, key)
if tp and (not S.LagSync or tp - m0 > 0.22) then
hold = math.max(Shot.FLOOR, tp - (Shot.effPing() + peakLead) - m0 - Shot.fpsComp())
peakAimed = true
end
if now - m0 >= hold - look and (peakAimed or now - m0 >= Shot.AUTO_START - look) then break end
elseif S.MeterAim and n >= 3 and now - samples[n].t < 0.15 then
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
elseif now - m0 >= hold - look then
break
end
RunService.Heartbeat:Wait()
end
if mconn then pcall(function() mconn:Disconnect() end) end
pcall(Shot.slopeCommit, samples, key)
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
Shot.markShot()
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
Rec.shotAdd(string.format("RELEASE meter=%s target=%.3f predicted=%s samples=%d key=%s packet=%s hold=%.4f held=%.4f by=%s style=%s ping=%s comp=%.4f lead=%s", tostring(usedMeter), S.MeterTarget, tostring(qpred), #samples, key, tostring(pk), hold, held,
Shot.lastRelease, tostring(S.ShotStyle), tostring(pcall(function() return LP:GetNetworkPing() end) and LP:GetNetworkPing() or "?"), comp, tostring(peakLead)))
end
task.spawn(Shot.evaluate, { snap = snap, since = since, sit = sit, key = key, base = base, held = held, manual = manual,
pk = pk, remote = true, usedBar = false, usedMeter = usedMeter, qpred = qpred, comp = manual and 0 or comp, lead = peakLead })
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
notify("Auto Green error", tostring(err), 6)
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
power = power * (S.GlideSpeed or 1) * Glide.lowScale()
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
if kind == "shot" and S.ShotGlideMethod and S.ShotGlideMethod ~= "Auto" then method = S.ShotGlideMethod end
if method == "Auto" then method = Glide.chain[Glide.cur] end
if method == "GameVel" then
local gpm = Mover.playerModule()
if not (gpm and gpm.Character and gpm.Character.Movement and typeof(gpm.Character.Movement.CFVelocity) == "Vector3") then method = "CFrame" end
end
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
Glide.attrOn = true
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
-- LOW SETTINGS: a device on low graphics (or a low frame rate) is pulled back by the server more often and loses most of its boost,
-- so on low settings the boost is raised by a percentage and the glide is kept but weaker
function Speed.graphicsLevel()
local lvl
pcall(function()
local saved = UserSettings():GetService("UserGameSettings").SavedQualityLevel
if saved and saved.Value and saved.Value >= 1 then lvl = saved.Value end
end)
if not lvl then
pcall(function()
local q = settings().Rendering.QualityLevel
if q and q.Value and q.Value >= 1 then lvl = q.Value end
end)
end
return lvl
end
-- 0 = normal settings, 1 = lowest, in between for a little low
function Speed.lowFactor()
if S.LowFix == false then return 0 end
local f = 0
local lvl = Speed.graphicsLevel()
local top = S.LowLevel or 3
if lvl then
if lvl <= top then f = 1 elseif lvl <= top + 2 then f = 0.5 end
end
local fps = JH.FPS or 60
if fps < 28 then f = math.max(f, 1) elseif fps < 40 then f = math.max(f, 0.5) end
return f
end
function Glide.lowScale()
local f = Speed.lowFactor()
if f <= 0 then return 1 end
local pct = clamp((S.LowGlidePct or 60) / 100, 0.1, 1)
return 1 - (1 - pct) * f
end
function Speed.lowStatusText()
local lvl = Speed.graphicsLevel()
local f = Speed.lowFactor()
local gtxt = lvl and ("graphics level " .. lvl) or "graphics level unknown"
local state = (S.LowFix == false) and "fix off" or (f >= 1 and "LOW, fix on") or (f > 0 and "a little low, fix half on" or "normal, fix not needed")
return string.format("%s, %d FPS - %s", gtxt, math.floor((JH.FPS or 0) + 0.5), state)
end
function Speed.extraNow()
local kind, level = Speed.pick()
Speed.kind = kind
local extra = (kind and level > 0) and Speed.gameWS * (1.1 ^ level - 1) or 0
local f = Speed.lowFactor()
local more = 1 + ((S.LowBoostPct or 25) / 100) * f
extra = clamp(extra * more, 0, S.SpeedCap * more)
local lv = Speed.level * (1 - f)
if S.AntiRubber and lv > 0 then extra = extra / (1 + lv) end
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
local img = V.customLogo(key) or V.logoImg[key]
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
if Mover.override and tick() - (Mover.overrideT or 0) < 0.4 and v.Magnitude < 0.3 then return old(self, Mover.override, select(2, ...)) end
local okc, s = pcall(Mover.outScale)
if okc and s > 1.001 and v.Magnitude > 0.05 then
if Rec.on then task.defer(Rec.remote, self, method, table.pack(v * s), string.format("boosted x%.2f", s)) end
return old(self, v * s, select(2, ...))
end
end
elseif okn and name == "Dribble" then
Mover.lastDribbleRemote = self task.defer(Mover.onDribble, table.pack(...))
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
if S.Sweep then notify("Shot recorder", "Sweep is ON: shots are released early and late on purpose. Turn it off for real results.", 7) end
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
local DiscordBtn = new("TextButton", { Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -92, 0.5, 0),
	Size = UDim2.fromOffset(32, 28), AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(88, 101, 242), Parent = Header })
UI.corner(DiscordBtn, 0.7)
UI.label({ Text = "D", TextSize = 14, Font = Enum.Font.GothamBlack, TextColor3 = WHITE, Size = UDim2.fromScale(1, 1), Parent = DiscordBtn }, true, false)
DiscordBtn.Activated:Connect(function()
	local INVITE = "https://discord.gg/fk5TsZMrRM"
	local ok = type(setclipboard) == "function" and pcall(setclipboard, INVITE)
	notify("JHub", ok and "Discord invite copied - paste it in your browser to join." or ("Join my Discord: " .. INVITE), 5)
end)
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
l.Text = "press key or button..."
UI.listening = function(name)
setk(name or "")
show()
saveSoon()
end
task.delay(6, function()
if l.Text == "press key or button..." then
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
local sr = UI.Card(P, "Shot recorder")
UI.Toggle(sr, "Record shots (turn off to copy everything)", "RecShots", function(v) if v then Rec.shotStart() else Rec.shotStop() end end)
UI.Toggle(sr, "Sweep timings while recording (locked off)", "Sweep", function()
S.Sweep = false
local list = UI.flagRefresh["Sweep"]
if list then for _, f in ipairs(list) do pcall(f) end end
saveSoon()
notify("Shot recorder", "Sweep stays off. It deliberately misses shots on purpose and is not something you want running.", 5)
end)
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
local showLocked = false
function UI.syncAuto()
local on = S.AutoGreen ~= false
S.AutoCal, S.Learn = on, on
end
UI.Toggle(g, "Auto Green", "AutoGreen", function() UI.syncAuto() end)
UI.Dropdown(g, "Shot style (Hold or Tap)", "ShotStyle", { "Hold", "Tap" })
UI.Slider(g, "Starting hold time", "HoldTime", 0.08, 1.6, 0.005, 3, "s")
UI.Slider(g, "Release earlier / later", "Nudge", -150, 150, 5, 0, "ms")
UI.Toggle(g, "Perfect green", "PerfectGreen")
UI.Note(g, "Makes up for high ping/ms. Does nothing if you have low ping.")
UI.Slider(g, "Perfect green strength", "PerfectGreenPct", 0, 150, 5, 0, "%")
if showLocked then
local ln = UI.Card(P, "Learning")
UI.Toggle(ln, "Learn timing from results", "Learn")
UI.Toggle(ln, "Auto-learn new shot animations", "AutoCal")
end
local cal = UI.Card(P, "Auto Calibrate")
UI.Toggle(cal, "Auto Calibrate", "AutoCalibrate")
UI.Slider(cal, "Learn speed", "CalSpeed", 0.1, 1, 0.05, 2)
UI.Button(cal, "Forget learned animations", function()
Shot.autoReset()
notify("Auto Green", "Learned animations cleared", 2)
end)
local at = UI.Card(P, "Auto Timing")
UI.Toggle(at, "Auto Timing", "AutoTiming")
UI.Slider(at, "Ping compensation", "PingComp", 0, 100, 5, 0, "%")
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "AutoGreen", "ShotStyle", "HoldTime", "Nudge", "Learn", "PerfectGreen", "PerfectGreenPct", "AutoCalibrate", "CalSpeed", "AutoTiming", "PingComp", "ShotTimes",
"ShotRatio", "PacketMul", "PacketOn" }, function()
Shot.parseTimes()
Shot.brackets = {}
UI.syncAuto()
end)
end)
end
P = UI.Page("Dribbling", "D")
do
local d = UI.Card(P, "Dribble Glide")
UI.Toggle(d, "Dribble Glide", "DribbleGlide")
UI.Slider(d, "Glide power", "DribbleGlidePower", 1, 80, 1, 0)
UI.Slider(d, "Glide speed", "DribbleGlideSpeed", 0.5, 3, 0.1, 1, "x")
UI.Slider(d, "Time", "DribbleGlideTime", 0.05, 1, 0.01, 2, "s")
local sg = UI.Card(P, "Shot Glide")
UI.Toggle(sg, "Shot Glide", "ShotGlide")
UI.Slider(sg, "Glide power", "ShotGlidePower", 1, 80, 1, 0)
UI.Slider(sg, "Glide speed", "ShotGlideSpeed", 0.5, 3, 0.1, 1, "x")
UI.Dropdown(sg, "Shot glide method", "ShotGlideMethod", { "GameVel", "CFrame", "Velocity", "Auto" })
UI.Dropdown(sg, "Shot glide starts", "ShotGlideWhen", { "After release", "During shot" })
UI.Slider(sg, "Time", "ShotGlideTime", 0.05, 1, 0.01, 2, "s")
local gt = UI.Card(P, "Gather Step Glide")
UI.Toggle(gt, "Gather Step Glide", "GatherGlide")
UI.Slider(gt, "Glide power", "GatherGlidePower", 1, 80, 1, 0)
UI.Slider(gt, "Glide speed", "GatherGlideSpeed", 0.5, 3, 0.1, 1, "x")
UI.Slider(gt, "Time", "GatherGlideTime", 0.05, 1, 0.01, 2, "s")
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "DribbleGlideSpeed", "ShotGlideSpeed", "GatherGlideSpeed", "DribbleGlide", "DribbleGlidePower", "DribbleGlideTime", "ShotGlide", "ShotGlidePower", "ShotGlideTime", "GatherGlide",
"GatherGlidePower", "GatherGlideTime" })
end)
end
P = UI.Page("Players", "P")
do
local b = UI.Card(P, "Walk speed boost (walking, no ball)")
UI.Toggle(b, "Walk speed boost", "SpeedOn", function(v) if v then Speed.resetAuto() end end)
UI.Slider(b, "Level (0 = normal, each level x1.1)", "SpeedAdd", 0, 15, 1, 0)
local rb = UI.Card(P, "Run speed boost (running, no ball)")
UI.Toggle(rb, "Run speed boost", "RunOn", function(v) if v then Speed.resetAuto() end end)
UI.Slider(rb, "Level (0 = normal, each level x1.1)", "RunAdd", 0, 15, 1, 0)
local bb = UI.Card(P, "Ball speed boost (with the ball)")
UI.Toggle(bb, "Ball speed boost", "BallSpeedOn", function(v) if v then Speed.resetAuto() end end)
UI.Slider(bb, "Level (0 = normal, each level x1.1)", "BallAdd", 0, 15, 1, 0)
local lw = UI.Card(P, "Low settings fix")
UI.lowStat = UI.Stat(lw, "Your device")
UI.Note(lw, "On low graphics or a low frame rate the speed boost and the dribble glide lose strength. This gives the boost a percentage more and keeps the glide, just weaker.")
UI.Toggle(lw, "Low settings fix", "LowFix")
UI.Slider(lw, "Extra speed boost on low settings", "LowBoostPct", 0, 100, 5, 0, "%")
UI.Slider(lw, "Glide strength on low settings", "LowGlidePct", 10, 100, 5, 0, "%")
UI.Slider(lw, "Count graphics up to this level as low", "LowLevel", 1, 8, 1, 0)
local rs = UI.Card(P, "Restore")
UI.Button(rs, "Restore to default", function()
UI.restore({ "SpeedOn", "SpeedAdd", "RunOn", "RunAdd", "BallSpeedOn", "BallAdd", "LowFix", "LowBoostPct", "LowGlidePct", "LowLevel" }, function() Speed.resetAuto() end)
end)
end
P = UI.Page("Ball Mags", "B")
do
local m = UI.Card(P, "Ball magnet")
UI.Toggle(m, "Ball magnet", "BallMagnet")
UI.Dropdown(m, "How it gets the ball", "MagnetMode", { "Pull to me", "Go to the ball" })
UI.Slider(m, "Range", "MagnetRange", 10, 150, 5, 0, " studs")
UI.Slider(m, "Minimum time on the ball (frames)", "MagnetFrames", 1, 6, 1, 0)
UI.Slider(m, "Grab delay (so it is not instant)", "MagnetDelay", 0, 400, 10, 0, " ms")
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
UI.Input(al, "Green sound ID (Roblox audio number)", "GreenSoundId", nil, "paste a Roblox audio ID")
UI.Slider(al, "Green sound volume", "GreenSoundVol", 0.1, 1, 0.05, 2)
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
local gpType = i.UserInputType
if UI.listening and (gpType == Enum.UserInputType.Gamepad1 or gpType == Enum.UserInputType.Gamepad2 or gpType == Enum.UserInputType.Gamepad3 or gpType == Enum.UserInputType.Gamepad4) then
	local f = UI.listening
	UI.listening = nil
	f(i.KeyCode.Name)
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
InfoText.Text = string.format("JHub V" .. VERSION:sub(2) .. "  |  %d FPS  |  %d ms  |  %s", fps, ping, timeStr)
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
-- GLIDE FIX
Glide.chain = { "CFrame", "Velocity", "Input", "AttrBoost", "Impulse" }
Glide.fails = 0
function Glide.judge(kind, method, startPos, dir, expected, why)
local r = Mover.body()
if not r then return end
local moved = (r.Position - startPos):Dot(dir)
Glide.last = string.format("%s (%s) via %s: moved %.1f of %.1f studs", kind, why or "?", method, moved, expected)
log("Glide " .. Glide.last)
if expected < 4 then return end
if moved >= expected * 0.4 then
Glide.fails = 0
if tick() - Glide.lastNote > 10 then
Glide.lastNote = tick()
notify("Glide", "WORKS", 2)
end
return
end
Glide.fails = Glide.fails + 1
if Glide.fails < 3 then return end
Glide.fails = 0
if S.GlideMethod == "Auto" and not (kind == "shot" and S.ShotGlideMethod ~= "Auto") then
Glide.cur = Glide.cur % #Glide.chain + 1
notify("Glide", "not yet, trying " .. Glide.chain[Glide.cur], 2)
else
notify("Glide", "DOESN'T WORK", 3)
end
end
function Glide.start(kind, power, duration, dirOverride)
local r, h = Mover.body(), hum()
power = power * (S.GlideSpeed or 1) * Glide.lowScale()
if not r or not h or power <= 0 or duration <= 0 then return end
local now = tick()
if now - (Glide.lastStart[kind] or 0) < duration * 0.5 then return end
Glide.lastStart[kind] = now
local intent = Mover.intent(h, r)
local dir = flat(intent)
if dirOverride and flat(dirOverride).Magnitude > 0.1 then dir = flat(dirOverride) end
if dir.Magnitude < 0.1 then dir = flat(r.CFrame.LookVector) end
if dir.Magnitude < 0.01 then return end
dir = dir.Unit
local method = S.GlideMethod
if kind == "shot" and S.ShotGlideMethod and S.ShotGlideMethod ~= "Auto" then method = S.ShotGlideMethod end
if method == "Auto" then method = Glide.chain[Glide.cur] end
if method == "GameVel" then
local gpm = Mover.playerModule()
if not (gpm and gpm.Character and gpm.Character.Movement and typeof(gpm.Character.Movement.CFVelocity) == "Vector3") then method = "CFrame" end
end
Glide.token = Glide.token + 1
local token = Glide.token
local startPos = r.Position
local why = Glide.why
local walk = flat(intent) * Speed.gameWS
local total = power * duration * 0.8
local gbase = Mover.gameVel() or Vector3.new(0, 0, 0)
local applied, finished, startedAt = 0, false, now
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
local function frame()
if finished then return "stop" end
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
local p = clamp((tick() - now) / duration, 0, 1)
local over = token ~= Glide.token or not r.Parent or not JH.Running
if method == "CFrame" and not over then
local want = power * duration * 0.8 * (2 * p - p * p)
local step = want - applied
if step > 0 and not Glide.blocked(r, dir, step) then
r.CFrame = r.CFrame + dir * step
applied = want
Mover.sync(r)
end
end
if over or p >= 1 then
finished = true
restoreAttr()
if token == Glide.token then
task.delay(0.15, function()
if token == Glide.token then pcall(Glide.judge, kind, method, startPos, dir, total, why) end
end)
end
return "stop"
end
local factor = 1.6 * (1 - p)
if method == "GameVel" then
local gpm = Mover.playerModule()
local gmv = gpm and gpm.Character and gpm.Character.Movement
if gmv and typeof(gmv.CFVelocity) == "Vector3" then
local gv = gmv.CFVelocity
gmv.CFVelocity = Vector3.new(gbase.X + dir.X * power * factor, gv.Y, gbase.Z + dir.Z * power * factor)
end
return nil
end
if method == "Impulse" or method == "CFrame" then return nil end
if method == "AttrBoost" then
local c = char()
if c then
Glide.attrOn = true
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
local gameDir = Mover.gameIntent()
if (not gameDir or gameDir.Magnitude < 0.05) and tick() >= gi.nextSend then
gi.nextSend = tick() + 0.05
Mover.send(dir * gi.scale)
end
return nil
end
if method == "Velocity" then
local v = r.AssemblyLinearVelocity
local t = walk + dir * (power * factor)
r.AssemblyLinearVelocity = Vector3.new(t.X, v.Y, t.Z)
end
return nil
end
local conns = {}
local function run()
local ok, res = pcall(frame)
if not ok then
Glide.lastErr = tostring(res)
log("Glide error: " .. Glide.lastErr)
notify("Glide problem", Glide.lastErr, 5)
end
if not ok or res == "stop" then
for _, c in ipairs(conns) do c:Disconnect() end
end
end
conns[1] = RunService.Stepped:Connect(run)
conns[2] = RunService.Heartbeat:Connect(run)
end
function Mover.onDribble(args)
Anim.lastDribble = tick()
local c0 = char()
local pk0 = c0 and c0:GetAttribute("LastDribblePackage")
local dir = Mover.moveWhere(1.5)
if not dir and typeof(args[3]) == "Vector3" and flat(args[3]).Magnitude > 0.1 then dir = flat(args[3]) end
task.spawn(function()
local t0 = tick()
while JH.Running and tick() - t0 < 0.1 do
local cc = char()
if cc and cc:GetAttribute("LastDribblePackage") ~= pk0 then break end
RunService.Heartbeat:Wait()
end
if not JH.Running then return end
local c = char()
local pkg = c and c:GetAttribute("LastDribblePackage")
local name = type(pkg) == "string" and string.lower(pkg) or ""
dir = Mover.moveWhere(1.5) or dir
if matchAny(name, Mover.GATHER_MOVES) then
if not dir and (string.find(name, "step back", 1, true) or string.find(name, "stepback", 1, true)) then
local body = Mover.body()
if body then dir = -flat(body.CFrame.LookVector) end
end
Glide.fire("gather", "step back move " .. name, dir)
else
Glide.fire("dribble", "dribble move " .. (name ~= "" and name or tostring(args[1])), dir)
end
end)
end

Glide.kinds = {
dribble = { "DribbleGlide", "DribbleGlidePower", "DribbleGlideTime", "DribbleGlideSpeed" },
gather = { "GatherGlide", "GatherGlidePower", "GatherGlideTime", "GatherGlideSpeed" },
shot = { "ShotGlide", "ShotGlidePower", "ShotGlideTime", "ShotGlideSpeed" },
}
function Glide.fire(kind, why, dir)
local k = Glide.kinds[kind]
if not k or not S[k[1]] then return end
if S.GlideNeedBall and kind ~= "shot" and not Ball.holding then
log("Glide " .. kind .. " skipped: you do not hold the ball")
return
end
local m = math.max(S[k[4]] or 1, 0.1)
Glide.why = why or "?"
Glide.start(kind, S[k[2]] * m, S[k[3]] / m, dir)
end
function Glide.test(kind)
local k = Glide.kinds[kind]
if not k then return end
Glide.lastStart[kind] = 0
Glide.why = "test button"
local m = math.max(S[k[4]] or 1, 0.1)
Glide.start(kind, S[k[2]] * m, S[k[3]] / m)
end
function Mover.watchShot(pressT)
local h, r = hum(), Mover.body()
local stick
if h and r then
local intent = Mover.intent(h, r)
if intent.Magnitude > 0.1 then stick = flat(intent) end
end
task.spawn(function()
local t0 = tick()
while JH.Running and tick() - t0 < 0.35 and Shot.meterT < pressT - 0.05 do RunService.Heartbeat:Wait() end
if not JH.Running or Shot.meterT < pressT - 0.05 then return end
local c = char()
local anim = string.lower(tostring(c and c:GetAttribute("BaseAnimation") or ""))
local body = Mover.body()
local dir = stick
if not dir and body and matchAny(anim, { "fade", "stepback", "step back" }) then dir = -flat(body.CFrame.LookVector) end
if not dir then dir = Mover.moveWhere(1.5) end
if not dir and body then dir = flat(body.CFrame.LookVector) end
Glide.fire("shot", "shot", dir)
end)
end
-- AUTO GREEN, GRAPHICS AND PING UPGRADE
do
-- AUTO GREEN: the original learner, plus a bias watch for shots that are already locked
local origAutoLearn = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
local a = Shot.auto and Shot.auto[info.key]
if S.AdaptPlus and a and a.locked and a.mode == "peak" and not info.manual and Shot.autoActive(info.key) then
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx then
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
a.bin = a.bin or S.PeakBin or 0.014
local before = a.hold
a.b = (a.b or 0) * 0.7 + off * 0.3
if math.abs(off) >= 2 then
a.hold = clamp(a.hold + off * a.bin * 0.7, 0, 0.1)
a.b = 0
elseif math.abs(a.b) >= 0.45 then
a.hold = clamp(a.hold + a.b * a.bin * 0.8, 0, 0.1)
a.b = 0
end
if a.hold ~= before then
Shot.noteAdjust(info.key, before, a.hold, (Shot.VERDICT[idx] or "?") .. ", re-centered")
Shot.autoSave()
end
end
end
return origAutoLearn(info, res, strength)
end

---------------------------------------------------------------------
-- PING STABILIZER
---------------------------------------------------------------------
local Ping = { buf = {}, stable = nil, jitter = 0, raw = 0 }
JH.api.Ping = Ping
function Ping.step()
local ok, p = pcall(function() return LP:GetNetworkPing() end)
if not ok or type(p) ~= "number" then return end
Ping.raw = p
local n = math.max(5, math.floor((S.PingWindow or 3) * 10))
Ping.buf[#Ping.buf + 1] = p
while #Ping.buf > n do table.remove(Ping.buf, 1) end
local t = {}
for i, v in ipairs(Ping.buf) do t[i] = v end
table.sort(t)
local med = t[math.floor((#t + 1) / 2)]
local dev = 0
for _, v in ipairs(Ping.buf) do dev = dev + math.abs(v - med) end
Ping.stable = med
Ping.jitter = dev / #Ping.buf
end
function Ping.trim(on)
pcall(function()
local net = settings().Network
if on then
if Ping.oldLag == nil then Ping.oldLag = net.IncomingReplicationLag end
net.IncomingReplicationLag = 0
elseif Ping.oldLag ~= nil then
net.IncomingReplicationLag = Ping.oldLag
Ping.oldLag = nil
end
end)
end
local basePing = Shot.pingNow
function Shot.pingNow()
if S.PingStab and Ping.stable then return Ping.stable end
return basePing()
end
task.spawn(function()
while JH.Running do
Ping.step()
task.wait(0.1)
end
end)

---------------------------------------------------------------------
-- GRAPHICS AND FPS BOOSTER
---------------------------------------------------------------------
local Gfx = { saved = setmetatable({}, { __mode = "k" }), culled = setmetatable({}, { __mode = "k" }), removed = {},
low = {}, queue = {}, qh = 1, qt = 0, tok = 0, any = false }
JH.api.Gfx = Gfx
local EFFECTS = { ParticleEmitter = true, Trail = true, Beam = true, Fire = true, Smoke = true, Sparkles = true,
PointLight = true, SpotLight = true, SurfaceLight = true }
local POST = { BloomEffect = true, BlurEffect = true, ColorCorrectionEffect = true, DepthOfFieldEffect = true, SunRaysEffect = true }
local FLAGS = { "GfxLow", "GfxEffects", "GfxTextures", "GfxShadows", "GfxPost", "GfxHideOthers", "GfxCull" }

function Gfx.set(inst, prop, value)
local ok, cur = pcall(function() return inst[prop] end)
if not ok or cur == value then return end
local rec = Gfx.saved[inst]
if not rec then
rec = {}
Gfx.saved[inst] = rec
end
if rec[prop] == nil then rec[prop] = cur end
pcall(function() inst[prop] = value end)
end
function Gfx.isChar(d)
local m = d.Parent
while m and m ~= workspace do
if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then return true end
m = m.Parent
end
return false
end
function Gfx.remove(d)
Gfx.removed[#Gfx.removed + 1] = { inst = d, parent = d.Parent }
d.Parent = nil
end
function Gfx.apply(d)
local cls = d.ClassName
if S.GfxEffects then
if EFFECTS[cls] then
Gfx.set(d, "Enabled", false)
return
elseif cls == "Explosion" then
Gfx.set(d, "Visible", false)
return
end
end
if S.GfxPost then
if POST[cls] and d.Name ~= "JHubBlur" then
Gfx.set(d, "Enabled", false)
return
elseif cls == "Atmosphere" then
Gfx.set(d, "Density", 0)
Gfx.set(d, "Haze", 0)
Gfx.set(d, "Glare", 0)
return
end
end
if d:IsA("BasePart") then
if d.Name == "ProxyCharacter" or Ball.parts[d] then return end
if S.GfxShadows then Gfx.set(d, "CastShadow", false) end
if S.GfxTextures and not Gfx.isChar(d) then
Gfx.set(d, "Material", Enum.Material.SmoothPlastic)
Gfx.set(d, "Reflectance", 0)
if cls == "MeshPart" then Gfx.set(d, "TextureID", "") end
end
elseif S.GfxTextures then
if cls == "Decal" or cls == "Texture" then
if not Gfx.isChar(d) and not (d.Parent and Ball.parts[d.Parent]) then Gfx.set(d, "Transparency", 1) end
elseif cls == "SurfaceAppearance" and not Gfx.isChar(d) then
Gfx.remove(d)
end
end
end
function Gfx.sweep()
local tok = Gfx.tok
task.spawn(function()
local n = 0
for _, root in ipairs({ Lighting, workspace }) do
for _, d in ipairs(root:GetDescendants()) do
if tok ~= Gfx.tok or not JH.Running then return end
pcall(Gfx.apply, d)
n = n + 1
if n % 400 == 0 then task.wait() end
end
end
end)
end
local function push(d)
if Gfx.any then
Gfx.qt = Gfx.qt + 1
Gfx.queue[Gfx.qt] = d
end
end
bind(workspace.DescendantAdded, push)
bind(Lighting.DescendantAdded, push)
bind(RunService.Heartbeat, function()
local q = Gfx.queue
local n = 0
while Gfx.qh <= Gfx.qt and n < 120 do
local d = q[Gfx.qh]
q[Gfx.qh] = nil
Gfx.qh = Gfx.qh + 1
if d and d.Parent then pcall(Gfx.apply, d) end
n = n + 1
end
end)
function Gfx.restoreProps()
for inst, rec in pairs(Gfx.saved) do
for prop, val in pairs(rec) do pcall(function() inst[prop] = val end) end
end
Gfx.saved = setmetatable({}, { __mode = "k" })
for _, r in ipairs(Gfx.removed) do
pcall(function() r.inst.Parent = r.parent end)
end
Gfx.removed = {}
end
function Gfx.lowOn()
local low = Gfx.low
pcall(function()
local r = settings().Rendering
if low.quality == nil then low.quality = r.QualityLevel end
r.QualityLevel = Enum.QualityLevel.Level01
end)
pcall(function()
local r = settings().Rendering
if low.mesh == nil then low.mesh = r.MeshPartDetailLevel end
r.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
end)
pcall(function()
local ugs = UserSettings():GetService("UserGameSettings")
if low.saved == nil then low.saved = ugs.SavedQualityLevel end
ugs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
end)
pcall(function()
if sethiddenproperty and gethiddenproperty then
if low.tech == nil then low.tech = gethiddenproperty(Lighting, "Technology") end
sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
end
end)
Gfx.set(Lighting, "GlobalShadows", false)
local t = workspace:FindFirstChildOfClass("Terrain")
if t then
Gfx.set(t, "Decoration", false)
Gfx.set(t, "WaterWaveSize", 0)
Gfx.set(t, "WaterWaveSpeed", 0)
Gfx.set(t, "WaterReflectance", 0)
end
end
function Gfx.lowOff()
local low = Gfx.low
pcall(function()
if low.quality ~= nil then settings().Rendering.QualityLevel = low.quality end
if low.mesh ~= nil then settings().Rendering.MeshPartDetailLevel = low.mesh end
end)
pcall(function()
if low.saved ~= nil then UserSettings():GetService("UserGameSettings").SavedQualityLevel = low.saved end
end)
pcall(function()
if low.tech ~= nil and sethiddenproperty then sethiddenproperty(Lighting, "Technology", low.tech) end
end)
Gfx.low = {}
end
function Gfx.restoreCull()
for d in pairs(Gfx.culled) do pcall(function() d.LocalTransparencyModifier = 0 end) end
Gfx.culled = setmetatable({}, { __mode = "k" })
Gfx.parts = nil
end
function Gfx.cullStep()
if not S.GfxCull then return end
local cam = workspace.CurrentCamera
if not cam then return end
if not Gfx.parts or tick() - (Gfx.partsT or 0) > 15 then
Gfx.partsT = tick()
local list, n = {}, 0
for _, d in ipairs(workspace:GetDescendants()) do
if d:IsA("BasePart") and d.Name ~= "ProxyCharacter" and not Ball.parts[d] and d.Size.Magnitude < 40 and not Gfx.isChar(d) then
list[#list + 1] = d
end
n = n + 1
if n % 600 == 0 then task.wait() end
end
Gfx.parts = list
Gfx.cursor = 1
end
local list = Gfx.parts
if not list then return end
local pos = cam.CFrame.Position
local lim = S.GfxCullDist
local total = #list
local first = Gfx.cursor or 1
local last = math.min(total, first + 1200)
for i = first, last do
local d = list[i]
if d and d.Parent then
local far = (d.Position - pos).Magnitude > lim
if far and not Gfx.culled[d] then
Gfx.culled[d] = true
d.LocalTransparencyModifier = 1
elseif not far and Gfx.culled[d] then
Gfx.culled[d] = nil
d.LocalTransparencyModifier = 0
end
end
end
Gfx.cursor = (last >= total) and 1 or (last + 1)
end
function Gfx.hideOthersStep()
if not S.GfxHideOthers then return end
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= LP and pl.Character then
for _, a in ipairs(pl.Character:GetChildren()) do
if a:IsA("Accessory") then
local h = a:FindFirstChild("Handle")
if h then Gfx.set(h, "LocalTransparencyModifier", 1) end
end
end
end
end
end
function Gfx.applyCap()
local cap = S.GfxFpsCap
if cap and cap > 0 then
if Gfx.oldCap == nil then
local ok, v = pcall(function() return getfpscap and getfpscap() or 60 end)
Gfx.oldCap = (ok and tonumber(v)) or 60
end
if setfpscap then pcall(setfpscap, cap) end
elseif Gfx.oldCap ~= nil then
if setfpscap then pcall(setfpscap, Gfx.oldCap) end
Gfx.oldCap = nil
end
end
function Gfx.onChange()
Gfx.tok = Gfx.tok + 1
Gfx.restoreProps()
if S.GfxLow then Gfx.lowOn() else Gfx.lowOff() end
if S.GfxShadows then Gfx.set(Lighting, "GlobalShadows", false) end
Gfx.any = (S.GfxEffects or S.GfxTextures or S.GfxShadows or S.GfxPost) and true or false
if Gfx.any then Gfx.sweep() end
if not S.GfxCull then Gfx.restoreCull() end
Gfx.hideOthersStep()
Gfx.applyCap()
end
function Gfx.boost(on)
for _, k in ipairs(FLAGS) do UI.set(k, on, false) end
Gfx.onChange()
if on then pcall(collectgarbage, "collect") end
end
function Gfx.restoreAll()
Gfx.tok = Gfx.tok + 1
Gfx.restoreProps()
Gfx.lowOff()
Gfx.restoreCull()
if Gfx.oldCap ~= nil and setfpscap then pcall(setfpscap, Gfx.oldCap) end
end
local oldUnload = JH.Unload
function JH.Unload()
pcall(Gfx.restoreAll)
pcall(Ping.trim, false)
oldUnload()
end
task.spawn(function()
local gcT = tick()
while JH.Running do
pcall(Gfx.cullStep)
pcall(Gfx.hideOthersStep)
if S.GfxBoost and tick() - gcT > 30 then
gcT = tick()
pcall(collectgarbage, "step", 200)
end
task.wait(0.4)
end
end)

-- the Graphics tab
local PG = UI.Page("Graphics", "G")
local c1 = UI.Card(PG, "FPS booster")
UI.Toggle(c1, "FPS booster", "GfxBoost", function(v) Gfx.boost(v) end)
UI.Note(c1, "Turns on every option below at once and keeps cleaning up anything new that appears. Turn it off to put everything back.")
local fpsStat = UI.Stat(c1, "FPS")
UI.Slider(c1, "FPS cap (0 = leave alone)", "GfxFpsCap", 0, 360, 5, 0, nil, function() Gfx.applyCap() end)

local c2 = UI.Card(PG, "Lower graphics")
local function opt(card, text, flag) UI.Toggle(card, text, flag, function() Gfx.onChange() end) end
opt(c2, "Lowest graphics", "GfxLow")
opt(c2, "Remove textures and fancy materials", "GfxTextures")
opt(c2, "Remove particles, trails and lights", "GfxEffects")
opt(c2, "Turn off shadows", "GfxShadows")
opt(c2, "Turn off blur, bloom, fog and haze", "GfxPost")
opt(c2, "Hide other players' accessories", "GfxHideOthers")

local c3 = UI.Card(PG, "Map cleanup")
opt(c3, "Hide small map parts far away", "GfxCull")
UI.Slider(c3, "Hide parts farther than", "GfxCullDist", 60, 600, 10, 0, " studs")
UI.Note(c3, "The court, big walls, players and the ball are never hidden.")
UI.Button(c3, "Turn everything off", function()
for _, k in ipairs(FLAGS) do UI.set(k, false, false) end
UI.set("GfxBoost", false, false)
UI.set("GfxFpsCap", 0, false)
Gfx.onChange()
end)

local c4 = UI.Card(PG, "Ping stabilizer")
UI.Toggle(c4, "Ping stabilizer", "PingStab", function(v) Ping.trim(v) end)
UI.Note(c4, "Your real ping comes from your connection and cannot be lowered here. This smooths out ping spikes so Auto Green and Perfect green time off a steady number, and it turns off the client's own extra network delay.")
UI.Slider(c4, "Smoothing window", "PingWindow", 1, 6, 1, 0, "s")
local pingStat = UI.Stat(c4, "Ping (now)")
local stableStat = UI.Stat(c4, "Ping (stable)")
local jitterStat = UI.Stat(c4, "Jitter")

task.spawn(function()
while JH.Running do
if Window.Visible and UI.current and UI.current.name == "Graphics" then
pcall(function()
fpsStat.Text = string.format("%d", math.floor(JH.FPS + 0.5))
pingStat.Text = string.format("%d ms", math.floor(Ping.raw * 1000 + 0.5))
stableStat.Text = Ping.stable and string.format("%d ms", math.floor(Ping.stable * 1000 + 0.5)) or "-"
jitterStat.Text = string.format("%.1f ms", Ping.jitter * 1000)
end)
end
task.wait(0.5)
end
end)

Ping.trim(S.PingStab)
Gfx.onChange()
end
-- GLIDE RULES, CODES, AUTO GUARD, AUTO BLOCK, AUTO REBOUND, AUTO GRIND, NO STUN
do
-- gather glide is only for hop steps and euro steps, step backs belong to the dribble glide
Mover.GATHER_MOVES = { "euro", "hop", "gather" }
local STEP_BACK = { "stepback", "step back" }
local SHOT_MOVES = { "shot", "shoot", "jumper", "layup", "dunk", "fade", "floater", "hook" }

function Glide.cancel()
Glide.token = Glide.token + 1
Glide.input = nil
if Glide.attrOn then
Glide.attrOn = false
local c = char()
if c then
c:SetAttribute("SpeedBoost", 0)
c:SetAttribute("SpeedBoostTime", 0)
c:SetAttribute("AccelerationBoost", 0)
end
end
end
function Glide.gatherOk(c)
local gt = string.lower(tostring(c:GetAttribute("GatherType") or ""))
local pk = string.lower(tostring(c:GetAttribute("LastDribblePackage") or ""))
if string.find(gt, "pump", 1, true) then return false end
if matchAny(gt, STEP_BACK) or matchAny(pk, STEP_BACK) then return false end
return true
end

function Mover.onDribble(args)
Anim.lastDribble = tick()
local c0 = char()
local pk0 = c0 and c0:GetAttribute("LastDribblePackage")
local dir = Mover.moveWhere(1.5)
if not dir and typeof(args[3]) == "Vector3" and flat(args[3]).Magnitude > 0.1 then dir = flat(args[3]) end
task.spawn(function()
local t0 = tick()
while JH.Running and tick() - t0 < 0.1 do
local cc = char()
if cc and cc:GetAttribute("LastDribblePackage") ~= pk0 then break end
RunService.Heartbeat:Wait()
end
if not JH.Running then return end
local c = char()
local pkg = c and c:GetAttribute("LastDribblePackage")
local name = type(pkg) == "string" and string.lower(pkg) or ""
if matchAny(name, SHOT_MOVES) then return end
if matchAny(name, STEP_BACK) then
local body = Mover.body()
local back = body and -flat(body.CFrame.LookVector) or dir
Glide.fire("dribble", "step back " .. name, back)
return
end
dir = Mover.moveWhere(1.5) or dir
if matchAny(name, Mover.GATHER_MOVES) then
Glide.fire("gather", "gather move " .. name, dir)
else
Glide.fire("dribble", "dribble move " .. (name ~= "" and name or tostring(args[1])), dir)
end
end)
end

-- a running dribble or gather glide stops the moment a shot starts, and the shot glide does its own thing
local baseShoot = Shot.onShootCall
function Shot.onShootCall(args)
local d = args[1]
if type(d) == "table" then
if d.Shoot == true and (S.DribbleGlide or S.GatherGlide) then pcall(Glide.cancel) end
if d.Shoot == false then Mover.shotUpT = tick() end
end
return baseShoot(args)
end
function Mover.watchShot(pressT)
task.defer(function()
local h, r = hum(), Mover.body()
local stick
if h and r then
local okI, intent = pcall(Mover.intent, h, r)
if okI and intent and intent.Magnitude > 0.1 then stick = flat(intent) end
end
local t0 = tick()
while JH.Running and tick() - t0 < 0.35 and Shot.meterT < pressT - 0.05 do RunService.Heartbeat:Wait() end
if not JH.Running or Shot.meterT < pressT - 0.05 then return end
local c = char()
local anim = string.lower(tostring(c and c:GetAttribute("BaseAnimation") or ""))
local body = Mover.body()
local dir = stick
if not dir and body and matchAny(anim, { "fade", "stepback", "step back" }) then dir = -flat(body.CFrame.LookVector) end
if not dir then dir = Mover.moveWhere(1.5) end
if not dir and body then dir = flat(body.CFrame.LookVector) end
if S.ShotGlideWhen ~= "During shot" then
local w0 = tick()
while JH.Running and tick() - w0 < 1.6 and Shot.releasedT < pressT and (Mover.shotUpT or 0) < pressT do RunService.Heartbeat:Wait() end
end
Glide.lastStart.shot = 0
Glide.fire("shot", "shot", dir)
end)
end

---------------------------------------------------------------------
-- CODES
---------------------------------------------------------------------
Net.KNOWN_CODES = { "100M", "100KLIKES", "500KMEMBERS", "100KCCUPLS", "RELEASE", "SORRYFORBUGS" }
function Net.gameCodes()
local found = {}
if type(getloadedmodules) ~= "function" then return found end
local okl, mods = pcall(getloadedmodules)
if not okl or type(mods) ~= "table" then return found end
local function walk(t, depth)
if depth > 3 then return end
for k, v in pairs(t) do
if type(k) == "string" and #k >= 3 and #k <= 24 and string.find(k, "^[%u%d_]+$") and string.find(k, "%u") then found[k] = true end
if type(v) == "table" then pcall(walk, v, depth + 1) end
end
end
for _, m in ipairs(mods) do
local okp, path = pcall(Bar.pathOf, m)
if okp and string.find(string.lower(path), "code", 1, true) then
local okr, res = pcall(require, m)
if okr and type(res) == "table" then pcall(walk, res, 0) end
end
end
return found
end
function Net.redeemViaRemotes(list)
local remotes = {}
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and matchAny(string.lower(d.Name), { "code", "redeem", "promo", "coupon" }) then
remotes[#remotes + 1] = d
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
pcall(function() rm:FireServer({ Code = code }) end)
log("Code " .. code .. " sent via " .. rm.Name)
end
end
task.wait(1.2)
end
return true
end
function Net.redeemAll()
local seen, list = {}, {}
local function add(c)
c = trim(c)
if c ~= "" and not seen[c] then
seen[c] = true
list[#list + 1] = c
end
end
for _, c in ipairs(tokens(S.Codes)) do add(c) end
for _, c in ipairs(Net.KNOWN_CODES) do add(c) end
local fromGame = Net.gameCodes()
local extra = 0
for c in pairs(fromGame) do
if not seen[c] then extra = extra + 1 end
add(c)
end
notify("Codes", string.format("Trying %d codes (%d found inside the game).", #list, extra), 3)
local done = Net.redeemViaGui(list)
if not done and S.CodeRemotes then done = Net.redeemViaRemotes(list) end
if done then
notify("Codes", "Finished. Check your coins and rewards.", 4)
else
notify("Codes", "Open the Store, then the Codes box, once. Then press Redeem all codes again.", 5)
end
end

---------------------------------------------------------------------
-- NO STUN
---------------------------------------------------------------------
local STUN_WORDS = { "stun", "stagger", "knock", "dizzy", "daze", "ragdoll", "flinch", "faint", "hurt" }
local Bot = { hoops = {}, hoopsT = 0, track = setmetatable({}, { __mode = "k" }), cmd = nil, cmdT = 0, mul = 1, face = nil, faceT = 0,
shotSeen = setmetatable({}, { __mode = "k" }), btnCache = {}, sprinting = false, shotT = 0, moveT = 0, blockT = 0,
chaseUntil = 0, status = "Off", spot = nil, spotT = 0, ballT = 0, jumpT = 0 }
JH.api.Bot = Bot

function Bot.noStunStep()
if not S.NoStun then return end
local c, h = char(), hum()
if c then
if Bot.stunChar ~= c then
Bot.stunChar = c
bind(c.AttributeChanged, function(name)
local low = string.lower(name)
if S.NoStun and string.find(low, "stun", 1, true) and c:GetAttribute(name) then
local a = Anim.animator
local ok, list = pcall(function() return a and a:GetPlayingAnimationTracks() or {} end)
if ok then
for _, tr in ipairs(list) do
local id = Anim.idOf(tr)
if id ~= "" and not tr.Looped and not Anim.has("StunIds", id) then
S.StunIds = trim((S.StunIds or "") .. " " .. id)
saveSoon()
end
end
end
end
end)
end
for k, v in pairs(c:GetAttributes()) do
local low = string.lower(k)
if string.find(low, "stun", 1, true) or string.find(low, "ragdoll", 1, true) or string.find(low, "stagger", 1, true) then
if v == true then c:SetAttribute(k, false) elseif type(v) == "number" and v ~= 0 then c:SetAttribute(k, 0) end
end
end
end
if h then
pcall(function()
if h.PlatformStand then h.PlatformStand = false end
local st = h:GetState()
if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
end)
end
local a = Anim.animator
if a then
local ok, list = pcall(function() return a:GetPlayingAnimationTracks() end)
if ok then
for _, tr in ipairs(list) do
if Anim.has("StunIds", Anim.idOf(tr)) or matchAny(Anim.name(tr), STUN_WORDS) then pcall(function() tr:Stop(0) end) end
end
end
end
end

---------------------------------------------------------------------
-- BOT BASICS: players, hoops, movement
---------------------------------------------------------------------
function Bot.charOf(pl)
return pl.Character or (workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(pl.Name))
end
function Bot.hasBall(c)
local af = c:FindFirstChild("Attributes")
local bv = af and af:FindFirstChild("Basketball")
return (bv and bv.Value ~= nil) and true or false
end
-- reads real root.AssemblyLinearVelocity instead of estimating speed from position deltas - the engine already knows the opponent's true instantaneous velocity and replicates it, no need to re-derive a laggier copy of it
local function sampleRoot(root, now)
local v = root.AssemblyLinearVelocity
local flatV = Vector3.new(v.X, 0, v.Z)
local tr = Bot.track[root]
if not tr then
Bot.track[root] = { p = root.Position, t = now, v = flatV }
else
tr.v = tr.v * 0.6 + flatV * 0.4
tr.p, tr.t = root.Position, now
end
end
function Bot.sample()
local now = tick()
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= LP then
local c = Bot.charOf(pl)
local root = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
if root then sampleRoot(root, now) end
end
end
-- AI opponents have no Player object, so the loop above never samples their velocity - without this, Bot.guardStep's prediction always assumed AI stood still
local myChar = char()
local folder = workspace:FindFirstChild("Characters")
if folder then
for _, c in ipairs(folder:GetChildren()) do
if c:IsA("Model") and c ~= myChar and c.Name ~= "InvisCharacter" then
local root = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
if root then sampleRoot(root, now) end
end
end
end
end
-- this game never sets Player.Team (confirmed nil on real players in a remote spy log), it uses a custom HomeTeam attribute on the character instead
local function sameSide(c1, c2)
if not c1 or not c2 then return false end
local h1, h2 = c1:GetAttribute("HomeTeam"), c2:GetAttribute("HomeTeam")
if h1 == nil or h2 == nil then return false end
return h1 == h2
end
function Bot.others()
local out = {}
local seen = {}
local myChar = char()
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= LP then
local c = Bot.charOf(pl)
local root = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
local hm = c and c:FindFirstChildOfClass("Humanoid")
if root and hm and hm.Health > 0 then
seen[c] = true
local tr = Bot.track[root]
out[#out + 1] = { pl = pl, c = c, root = root, pos = root.Position, vel = tr and tr.v or Vector3.new(0, 0, 0),
mate = S.APTeam == "By team" and sameSide(myChar, c),
ball = Bot.hasBall(c), shooting = c:GetAttribute("Action") == "Shooting" }
end
end
end
-- AI opponents are real characters in the game but have no Player object behind them, so the loop above never finds them
local folder = workspace:FindFirstChild("Characters")
if folder then
for _, c in ipairs(folder:GetChildren()) do
if c:IsA("Model") and c ~= myChar and not seen[c] and c.Name ~= "InvisCharacter" then
local root = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
local hm = c:FindFirstChildOfClass("Humanoid")
if root and hm and hm.Health > 0 then
local tr = Bot.track[root]
out[#out + 1] = { pl = { Name = c.Name }, c = c, root = root, pos = root.Position, vel = tr and tr.v or Vector3.new(0, 0, 0),
mate = S.APTeam == "By team" and sameSide(myChar, c),
ball = Bot.hasBall(c), shooting = c:GetAttribute("Action") == "Shooting" }
end
end
end
end
return out
end
function Bot.scanHoops()
local list = {}
local function add(pos)
for _, h in ipairs(list) do
if (h - pos).Magnitude < 14 then return end
end
list[#list + 1] = pos
end
for x, y, z in string.gmatch(S.HoopMarks or "", "(%-?[%d%.]+),(%-?[%d%.]+),(%-?[%d%.]+)") do
add(Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
end
local n = 0
for _, d in ipairs(workspace:GetDescendants()) do
n = n + 1
if n % 500 == 0 then task.wait() end
if d:IsA("BasePart") or d:IsA("Model") then
local nm = string.lower(d.Name)
if not string.find(nm, "ball", 1, true) and (nm == "rim" or nm == "hoop" or nm == "goal" or nm == "basket" or string.find(nm, "hoop", 1, true) or string.find(nm, "rim", 1, true) == 1) then
local ok, pos = pcall(function() return d:IsA("Model") and d:GetPivot().Position or d.Position end)
if ok then add(pos) end
end
end
end
Bot.hoops, Bot.hoopsT = list, tick()
log("Hoops found: " .. #list)
end
function Bot.nearestHoop(pos, far)
local best, bd
for _, h in ipairs(Bot.hoops) do
local d = flat(h - pos).Magnitude
if not bd or (far and d > bd) or (not far and d < bd) then best, bd = h, d end
end
return best
end
function Bot.attackHoop(pos)
local mode = S.APHoop
if mode == "Farthest" then return Bot.nearestHoop(pos, true) end
return Bot.nearestHoop(pos, false)
end
function Bot.move(dir, mul)
if dir.Magnitude > 1 then dir = dir.Unit end
Bot.cmd, Bot.cmdT, Bot.mul = dir, tick(), mul or 1
Mover.override, Mover.overrideT = dir, tick()
-- this game is server-authoritative and never reads Humanoid.MoveDirection/Humanoid:Move at all (confirmed back in v1.45's "this game does not use MoveDirection" finding, re-confirmed by Humanoid:Move producing zero real displacement) - the only thing that actually moves a character here is the same MoveDirection RemoteEvent the game's own control script fires, which Mover.send already drives for other features like Glide. Fire it directly instead of waiting on the passive Mover.override hook to catch a call that may not come often enough while idle.
local sentVec = dir * (mul or 1)
local ok = pcall(Mover.send, sentVec)
Bot.dbg = Bot.dbg or {}
Bot.dbg.sentVia, Bot.dbg.sentVec, Bot.dbg.sentOk, Bot.dbg.sentAt = "Mover.send", sentVec, ok, tick()
local h3 = hum()
Bot.dbg.humState = h3 and h3:GetState().Name or "no humanoid"
end
function Bot.stopMove()
Bot.cmd = nil
Mover.override = nil
local ok = pcall(Mover.send, Vector3.new())
Bot.dbg = Bot.dbg or {}
Bot.dbg.sentVia, Bot.dbg.sentVec, Bot.dbg.sentOk, Bot.dbg.sentAt = "Mover.send(stop)", Vector3.new(), ok, tick()
end
function Bot.faceAt(pos)
local r = Mover.body()
if not r then return end
local d = flat(pos - r.Position)
if d.Magnitude > 0.5 then Bot.face, Bot.faceT = d.Unit, tick() end
end
function Bot.stamina()
local c = char()
local v = c and c:GetAttribute("Stamina")
if type(v) ~= "number" then return nil end
return v <= 1 and v * 100 or v
end
function Bot.setSprint(on)
if on then
local st = Bot.stamina()
if st and st <= S.APStaminaMin then on = false end
end
if on ~= Bot.sprinting then
Bot.sprinting = on
pcall(Input.action, "Sprint", on)
end
end
function Bot.findBtn(words)
local key = table.concat(words, "|")
local c = Bot.btnCache[key]
if c and tick() - c.t < 2 and (not c.obj or c.obj.Parent) then return c.obj end
local pg = LP:FindFirstChild("PlayerGui")
local found
if pg then
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("GuiButton") and not d:IsDescendantOf(gui) and visibleChain(d) then
local n = string.lower(d.Name .. " " .. (d:IsA("TextButton") and d.Text or ""))
if matchAny(n, words) then
found = d
break
end
end
end
end
Bot.btnCache[key] = { obj = found, t = tick() }
return found
end
function Bot.press(key, hold, words)
task.spawn(function()
Input.sendKey(key, true)
local btn = words and Bot.findBtn(words)
if btn then Input.fireGui(btn, true, true) end
task.wait(hold or 0.1)
Input.sendKey(key, false)
if btn then Input.fireGui(btn, false, true) end
end)
end
function Bot.userActive()
if not S.APPause then return false end
local d = Mover.gameDir
return d ~= nil and tick() - (Mover.gameDirT or 0) < 0.4 and flat(d).Magnitude > 0.35
end
-- confirmed from a real remote guard recorder log (this game's real Jog/defensive slide ids) - bootstrap these so Auto Guard has a walk animation immediately instead of waiting on another learning pass, now that the old bad exclusion is gone
if not S.WalkAnimId or S.WalkAnimId == "" then S.WalkAnimId = "rbxassetid://135438934392621" saveSoon() end
if not S.GuardAnimId or S.GuardAnimId == "" then S.GuardAnimId = "rbxassetid://16597565910" saveSoon() end
-- learn two real animations from how you actually move: a normal walk (facing roughly the way you're moving) and a defensive slide (facing one way, moving sideways/backward - the real signature of guarding someone), instead of guessing an id or treating all movement the same
local walkLastPos, walkLastT
bind(RunService.Heartbeat, function()
	local needWalk = not S.WalkAnimId or S.WalkAnimId == ""
	local needGuard = not S.GuardAnimId or S.GuardAnimId == ""
	if not needWalk and not needGuard then return end
	if Bot.cmd then return end
	local h, r = hum(), Mover.body()
	if not h or not r then return end
	local now = tick()
	local moveDelta, moving = Vector3.new(), false
	if walkLastPos and walkLastT and now - walkLastT > 0 then
		moveDelta = flat(r.Position - walkLastPos)
		moving = moveDelta.Magnitude / (now - walkLastT) > 3
	end
	walkLastPos, walkLastT = r.Position, now
	if not moving then return end
	local facing = flat(r.CFrame.LookVector)
	local isGuardMove = false
	if facing.Magnitude > 0.1 and moveDelta.Magnitude > 0.1 then
		isGuardMove = facing.Unit:Dot(moveDelta.Unit) < 0.3
	end
	for _, tr in ipairs(h:GetPlayingAnimationTracks()) do
		local id = tr.Animation and tr.Animation.AnimationId
		if tr.Priority == Enum.AnimationPriority.Movement and tr.Looped and id and id ~= "" then
			if isGuardMove and needGuard then
				S.GuardAnimId = id
				saveSoon()
				notify("JHub", "Learned your real defensive slide animation.", 3)
			elseif not isGuardMove and needWalk then
				S.WalkAnimId = id
				saveSoon()
				notify("JHub", "Learned your real walk animation.", 3)
			end
			break
		end
	end
end)
local activeId, activeTrack
local moveTracks = {}
local function trackFor(id)
	if not id or id == "" then return nil end
	local h = hum()
	if not h then return nil end
	local cached = moveTracks[id]
	if cached and cached.hum == h then return cached.track end
	local animator = h:FindFirstChildOfClass("Animator")
	if not animator then return nil end
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
	if not ok or not track then return nil end
	track.Priority = Enum.AnimationPriority.Movement
	track.Looped = true
	moveTracks[id] = { track = track, hum = h }
	return track
end
bind(RunService.Stepped, function(_, dt)
	if dt <= 0 or dt > 0.25 then return end
	local r = Mover.body()
	if not r then return end
	local now = tick()
	local moving = Bot.cmd and now - Bot.cmdT < 0.35 and Bot.cmd.Magnitude > 0.05
	-- Humanoid:Move produced zero effect on animation too (confirmed: the real guard/defensive animation only shows up because it's tied directly to the HoldingG attribute by the game's own systems, not because of anything we send through Humanoid.MoveDirection - same "this game doesn't react to MoveDirection" finding as the movement side). CFrame drives position; load and play the confirmed real walk animation ourselves on top of it.
	if moving then
		r.CFrame = r.CFrame + Bot.cmd * Speed.gameWS * Bot.mul * dt
		Mover.sync(r)
		-- GuardAnimId never actually won out over the game's own real defensive animation in any recorder log, stationary or moving - so stop competing with it and just always play the real walk animation whenever actually moving, guarding or not
		local id = S.WalkAnimId
		if id ~= activeId then
			if activeTrack then pcall(function() activeTrack:Stop(0.1) end) end
			activeTrack = trackFor(id)
			activeId = id
		end
		if activeTrack then
			activeTrack.Speed = math.clamp(Bot.mul or 1, 0.6, 1.8)
			if not activeTrack.IsPlaying then activeTrack:Play(0.15) end
		end
	elseif activeTrack and activeTrack.IsPlaying then
		activeTrack:Stop(0.15)
	end
if Bot.face and now - Bot.faceT < 0.35 then
local p = r.Position
r.CFrame = CFrame.new(p, p + Bot.face)
end
end)

---------------------------------------------------------------------
-- AUTO GUARD AND AUTO BLOCK
---------------------------------------------------------------------
function Bot.pickTarget(others, me, forced)
local mode = forced or S.AGTarget
local function scoreOf(o)
local d = flat(o.pos - me).Magnitude
if mode == "Ball handler" then return o.ball and (d - 1000) or d end
if mode == "Closest to hoop" then
local h = Bot.nearestHoop(o.pos)
return h and flat(o.pos - h).Magnitude or d
end
return d
end
local best, bd
for _, o in ipairs(others) do
if not o.mate then
local score = scoreOf(o)
if not bd or score < bd then best, bd = o, score end
end
end
-- stick to whoever is already locked unless they're gone/dead, or a clearly better target has stayed clearly better for a bit - stops the target flickering between two near-equal candidates every tick, which is what caused jittery, indecisive movement
local now = tick()
if Bot.lockedChar then
local still
for _, o in ipairs(others) do
if o.c == Bot.lockedChar and not o.mate then still = o break end
end
if still then
if best and best.c ~= still.c and bd < scoreOf(still) - 2 then
if Bot.lockBetterChar ~= best.c then Bot.lockBetterChar, Bot.lockBetterSince = best.c, now end
if now - Bot.lockBetterSince >= 0.5 then
Bot.lockedChar, Bot.lockBetterChar, Bot.lockBetterSince = best.c, nil, nil
return best
end
else
Bot.lockBetterChar, Bot.lockBetterSince = nil, nil
end
return still
end
end
Bot.lockedChar, Bot.lockBetterChar, Bot.lockBetterSince = best and best.c or nil, nil, nil
return best
end
function Bot.blockStep(others, me)
if not S.AB then return end
local now = tick()
for _, o in ipairs(others) do
if not o.mate then
local was = Bot.shotSeen[o.c]
Bot.shotSeen[o.c] = o.shooting
if o.shooting and not was and now - Bot.blockT > 0.9 then
local dist = flat(o.pos - me).Magnitude
if dist <= S.ABRange and math.random(100) <= S.ABChance then
Bot.blockT = now
task.delay(S.ABDelay, function()
if JH.Running then Bot.doJump() end
end)
end
end
end
end
end

---------------------------------------------------------------------
-- AUTO REBOUND
---------------------------------------------------------------------
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
function Bot.predictBall(b)
local g = workspace.Gravity
local p, v = b.Position, b.AssemblyLinearVelocity
rayParams.FilterDescendantsInstances = { b, char() }
local hit = workspace:Raycast(p, Vector3.new(0, -300, 0), rayParams)
local floorY = hit and hit.Position.Y or (p.Y - 3)
local catchY = floorY + 4.5
local t = 0
if p.Y > catchY then
local disc = v.Y * v.Y + 2 * g * (p.Y - catchY)
t = (v.Y + math.sqrt(disc)) / g
else
t = 0.2
end
t = clamp(t, 0, 4)
return Vector3.new(p.X + v.X * t, floorY, p.Z + v.Z * t), t
end
function Bot.marker(pos)
if not S.ARMarker or not pos then
if Bot.mk then Bot.mk.Parent = nil end
return
end
if not Bot.mk then
local p = Instance.new("Part")
p.Name = "JHReboundMarker"
p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
p.Shape = Enum.PartType.Ball
p.Size = Vector3.new(2, 2, 2)
p.Material = Enum.Material.Neon
p.Color = Color3.fromRGB(255, 221, 64)
p.Transparency = 0.35
Bot.mk = p
end
Bot.mk.Position = pos + Vector3.new(0, 1, 0)
Bot.mk.Parent = workspace
end
function Bot.reboundStep(me, r)
if not Feat.ballLoose() then
Bot.marker(nil)
return false
end
local b = Feat.findBall()
if not b or not b.Parent then return false end
if flat(b.Position - me).Magnitude > S.ARRange then return false end
local land, t = Bot.predictBall(b)
Bot.marker(land)
local to = flat(land - me)
local d = to.Magnitude
if d > 0.8 then
Bot.move(to.Unit, S.ARSpeed)
Bot.setSprint(d > 8)
else
Bot.stopMove()
end
local bd = flat(b.Position - me).Magnitude
local now = tick()
if S.ARJump and bd < 7 and b.Position.Y > me.Y + 1 and now - Bot.jumpT > 0.8 then
Bot.jumpT = now
Bot.press("Space", 0.15, { "jump" })
end
if S.ARMagnet and bd <= S.ARMagRange and now - Bot.ballT > 0.4 then
Bot.ballT = now
pcall(Feat.getBall, true)
end
Bot.status = string.format("Rebound (%.1fs)", t)
return true
end

---------------------------------------------------------------------
-- AUTO PLAY
---------------------------------------------------------------------
function Bot.shoot(hoop)
local now = tick()
if now - Bot.shotT < S.APShotDelay or Shot.busy then return end
Bot.shotT = now
if hoop then Bot.faceAt(hoop) end
Bot.stopMove()
if S.ShotStyle ~= "Tap" then
Bot.oldStyle = Bot.oldStyle or S.ShotStyle
S.ShotStyle = "Tap"
end
Input.action("Shoot", true)
task.delay(0.08, function() Input.action("Shoot", false) end)
Bot.status = "Shooting"
end
function Bot.nearestDefender(me, others)
local dd, dn = math.huge, nil
for _, o in ipairs(others) do
if not o.mate then
local d = flat(o.pos - me).Magnitude
if d < dd then dd, dn = d, o end
end
end
return dd, dn
end
function Bot.steer(me, hoop, others)
local toHoop = flat(hoop - me)
local steer = toHoop.Unit
local side = Vector3.new(-toHoop.Unit.Z, 0, toHoop.Unit.X)
for _, o in ipairs(others) do
if not o.mate then
local off = flat(o.pos - me)
local d = off.Magnitude
if d < 9 and off:Dot(toHoop) > 0 then
local s = off:Dot(side) > 0 and -1 or 1
steer = steer + side * s * (1 - d / 9) * 1.3
end
end
end
return steer.Unit
end
function Bot.offense(me, others)
local hoop = Bot.attackHoop(me)
if not hoop then
Bot.status = "No hoop found"
return false
end
local c = char()
if c and c:GetAttribute("Action") == "Shooting" then
Bot.stopMove()
return true
end
local dist = flat(hoop - me).Magnitude
local dd = Bot.nearestDefender(me, others)
local build = S.APBuild
local now = tick()
if build == "Big" and S.APPostScore then
if dist > S.APPostRange then
local tight = dd < 3.5
Bot.move(flat(hoop - me).Unit * (tight and 0.6 or 1), S.APSpeed * (tight and 0.8 or 1))
Bot.faceAt(hoop)
Bot.setSprint(false)
Bot.status = "Posting up"
else
Bot.shoot(hoop)
end
return true
end
if dist <= 9 and S.APLayups then
Bot.shoot(hoop)
return true
end
local open = dd >= S.APOpenDist
if open and dist <= S.APRange and (S.APThree or dist <= 22) and dist > 9 then
Bot.shoot(hoop)
return true
end
if build == "Shooter" and not open then
Bot.status = "Looking for an open look"
end
if S.APDrive or build == "Small" or build == "Wing" then
local dir = Bot.steer(me, hoop, others)
Bot.move(dir, S.APSpeed)
Bot.setSprint(S.APSprint and dist > 12)
Bot.status = "Driving"
if S.APMoves and dd < 7 and now - Bot.moveT > 1.4 + math.random() * 1.2 then
Bot.moveT = now
local keys = tokens(S.DribbleKeys)
if #keys > 0 then Bot.press(keys[math.random(#keys)], 0.06) end
end
else
Bot.stopMove()
end
return true
end
function Bot.offBall(me, others)
local hoop = Bot.attackHoop(me)
if not hoop then return false end
local now = tick()
if S.APBuild == "Big" and S.APPostScore then
local away = flat(me - hoop)
if away.Magnitude < 0.1 then away = Vector3.new(0, 0, 1) end
local spot = hoop + away.Unit * S.APPostRange
local to = flat(spot - me)
if to.Magnitude > 1.5 then Bot.move(to.Unit, S.APSpeed) else Bot.stopMove() end
Bot.faceAt(hoop)
Bot.status = "Sealing in the post"
return true
end
if not Bot.spotUp or now - Bot.spotUpT > 1.2 then
local best, bs
for i = 0, 11 do
local a = i * math.pi / 6
local p = hoop + Vector3.new(math.cos(a), 0, math.sin(a)) * S.APSpot
local score = 0
local md = math.huge
for _, o in ipairs(others) do
if not o.mate then md = math.min(md, flat(o.pos - p).Magnitude) end
end
score = math.min(md, 14) - flat(p - me).Magnitude * 0.15
if not bs or score > bs then best, bs = p, score end
end
Bot.spotUp, Bot.spotUpT = best, now
end
local to = flat(Bot.spotUp - me)
if to.Magnitude > 1.5 then Bot.move(to.Unit, S.APSpeed) else Bot.stopMove() end
Bot.faceAt(hoop)
Bot.status = "Spacing the floor"
return true
end
function Bot.play(me, others, hasBall)
if hasBall then return Bot.offense(me, others) end
local handler
for _, o in ipairs(others) do
if o.ball then handler = o end
end
if S.APRebound and Feat.ballLoose() and Bot.reboundStep(me) then return true end
if handler then
if handler.mate then return Bot.offBall(me, others) end
if S.APDefend then return Bot.guardStep(me, others, "Ball handler") end
return false
end
return Bot.offBall(me, others)
end
function Bot.setAP(on)
S.AP = on
if on then
if not S.AutoGreen then UI.set("AutoGreen", true) end
if Bot.sampleHoops ~= true then
Bot.sampleHoops = true
task.spawn(Bot.scanHoops)
end
notify("Auto play", "Bot is playing. Touch the stick to take over.", 3)
else
Bot.stopMove()
Bot.setSprint(false)
Bot.marker(nil)
if Bot.oldStyle then
S.ShotStyle, Bot.oldStyle = Bot.oldStyle, nil
end
Bot.status = "Off"
end
if Bot.apLabel then Bot.apLabel.Text = on and "Auto play: ON (tap to stop)" or "Auto play: OFF (tap to start)" end
end
function Bot.think()
Bot.sample()
local r, h = Mover.body(), hum()
if not r or not h or h.Health <= 0 then
Bot.stopMove()
return
end
local active = S.AP or S.AG or S.AR or S.AB
if not active then return end
if #Bot.hoops == 0 and tick() - Bot.hoopsT > 10 and not Bot.scanning then
Bot.scanning = true
task.spawn(function()
Bot.scanHoops()
Bot.scanning = false
end)
end
if Bot.userActive() then
Bot.stopMove()
Bot.setSprint(false)
Bot.status = "You are driving"
return
end
local me = r.Position
local others = Bot.others()
local hasBall = Feat.hasBall()
pcall(Bot.blockStep, others, me)
local now = tick()
local acted = false
if S.AP then
acted = Bot.play(me, others, hasBall)
else
if S.AR and not hasBall then acted = Bot.reboundStep(me) end
local wantGuard = S.AG and not hasBall
if wantGuard and S.AGHoldToUse then
local c3 = char()
wantGuard = c3 and c3:GetAttribute("HoldingG") == true
end
if not acted and wantGuard then acted = Bot.guardStep(me, others) end
end
if not acted then
Bot.stopMove()
Bot.setSprint(false)
if not S.AP then
Bot.status = (S.AG and S.AGHoldToUse and not hasBall) and "Hold Guard to drive" or "Waiting"
end
end
end
task.spawn(function()
while JH.Running do
pcall(Bot.think)
pcall(Bot.noStunStep)
task.wait(0.05)
end
end)
pcall(function()
local vu = game:GetService("VirtualUser")
bind(LP.Idled, function()
if S.AP and S.APAntiAfk then pcall(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end) end
end)
end)
local oldUnload2 = JH.Unload
function JH.Unload()
Mover.override = nil
Bot.cmd = nil
if Bot.oldStyle then S.ShotStyle = Bot.oldStyle end
if Bot.mk then pcall(function() Bot.mk:Destroy() end) end
oldUnload2()
end

---------------------------------------------------------------------
-- TABS
---------------------------------------------------------------------
local playersPage
for _, p in ipairs(UI.pages) do
if p.name == "Players" then playersPage = p end
end
if playersPage then
local ns = UI.Card(playersPage, "No stun")
UI.Toggle(ns, "No stun", "NoStun")
UI.Note(ns, "Stops stun animations, clears stun flags on your character and gets you back up. It also learns new stun animations the game shows you.")
end

local GP = UI.Page("Auto Guard", "A")
do
local AG_CODE = "6022"
local typed = ""
local lock = UI.Card(GP, "Auto Guard (locked)")
UI.Input(lock, "Code", { get = function() return typed end, set = function(v) typed = tostring(v or "") end }, nil, "enter the code")
UI.Note(lock, "Auto Guard is locked. Enter the code to open it.")
local contentFrames = {}
JH.AGContentFrames = contentFrames
if S.AGUnlocked then
task.defer(function()
lock.frame.Visible = false
for _, f in ipairs(contentFrames) do f.Visible = true end
end)
end
UI.Button(lock, "Unlock", function()
if string.gsub(typed, "%s", "") == AG_CODE then
lock.frame.Visible = false
for _, f in ipairs(contentFrames) do f.Visible = true end
S.AGUnlocked = true
saveSoon()
notify("Auto Guard", "Unlocked", 3)
else
notify("Auto Guard", "Wrong code", 3)
end
end, true)
local g1 = UI.Card(GP, "Auto guard")
g1.frame.Visible = false
contentFrames[#contentFrames + 1] = g1.frame
UI.Toggle(g1, "Auto guard", "AG")
UI.Dropdown(g1, "Who to guard", "AGTarget", { "Ball handler", "Closest to me", "Closest to hoop" })
UI.Toggle(g1, "Only guard the player who has the ball", "AGOnlyBall")
UI.Slider(g1, "Guard distance (studs in front)", "AGDist", 1, 12, 0.5, 1)
UI.Note(g1, "Holds the real Guard button while guarding, same as a real player, and uses Guard speed from the Players tab for how fast it closes out.")
UI.Keybind(g1, "Guard key (keyboard, only if there is no on-screen Guard button)", function() return S.GuardKey end, function(v) S.GuardKey = v end)
UI.Slider(g1, "Reaction time", "AGReact", 0, 0.5, 0.01, 2, "s")
UI.Slider(g1, "Prediction (looks ahead)", "AGPredict", 0, 0.6, 0.02, 2, "s")
UI.Slider(g1, "Guard range", "AGRange", 10, 120, 5, 0, " studs")
UI.Toggle(g1, "Stay in front no matter what", "AGLock")
UI.Toggle(g1, "Only drive while I hold the real Guard button myself", "AGHoldToUse")
UI.Toggle(g1, "Face the player I guard", "AGFace")
UI.Toggle(g1, "Sprint to catch up", "AGSprint")
UI.Toggle(g1, "Look human (sway, hesitate, player speed)", "AGHuman")
UI.Slider(g1, "How human", "AGHumanAmt", 0, 100, 5, 0, "%")
UI.Note(g1, "It stands between the player and the hoop, and leads where they are going. Stay in front no matter what ignores range and reaction and chases at double speed.")
local g2 = UI.Card(GP, "Auto block")
g2.frame.Visible = false
contentFrames[#contentFrames + 1] = g2.frame
UI.Toggle(g2, "Auto block", "AB")
UI.Slider(g2, "Block range", "ABRange", 4, 30, 1, 0, " studs")
UI.Slider(g2, "Block timing (delay after the shot starts)", "ABDelay", 0, 0.5, 0.01, 2, "s")
UI.Slider(g2, "Block chance", "ABChance", 0, 100, 5, 0, "%")
UI.Keybind(g2, "Block / jump key", function() return S.ABKey end, function(v) S.ABKey = (v ~= "" and v) or "Space" end)
UI.Note(g2, "Blocks by jumping at the shooter. If your game blocks with another button, set it here.")
local rc = UI.Card(GP, "Remote Guard Recorder")
rc.frame.Visible = false
contentFrames[#contentFrames + 1] = rc.frame
UI.Note(rc, "Turn this on, then either guard someone for real (10-15s, walk toward/away/side to side) or have someone guard YOU. It catches every animation on you AND on whoever is nearest to you - priority, speed, looped or not - plus position, HoldingG, Action and state each tick.")
JH.rguardAnimLog = JH.rguardAnimLog or {}
JH.rguardMoveLog = JH.rguardMoveLog or {}
JH.rguardOppAnimLog = JH.rguardOppAnimLog or {}
local rconn, roppConn, roppHum
local function hookOpp(h)
if roppConn then roppConn:Disconnect() roppConn = nil end
roppHum = h
if h then
roppConn = h.AnimationPlayed:Connect(function(track)
if not S.RGuardOn then return end
table.insert(JH.rguardOppAnimLog, string.format("%s  oppanim  name=%s  id=%s  prio=%s  looped=%s  speed=%.2f",
os.date("%H:%M:%S"), track.Name, (track.Animation and track.Animation.AnimationId) or "?", track.Priority.Name, tostring(track.Looped), track.Speed))
if #JH.rguardOppAnimLog > 400 then table.remove(JH.rguardOppAnimLog, 1) end
end)
end
end
UI.Toggle(rc, "Record everything about guarding", "RGuardOn", function(v)
if v then
JH.rguardAnimLog, JH.rguardMoveLog, JH.rguardOppAnimLog = {}, {}, {}
local h = hum()
if h then
rconn = h.AnimationPlayed:Connect(function(track)
if not S.RGuardOn then return end
table.insert(JH.rguardAnimLog, string.format("%s  anim  name=%s  id=%s  prio=%s  looped=%s  speed=%.2f",
os.date("%H:%M:%S"), track.Name, (track.Animation and track.Animation.AnimationId) or "?", track.Priority.Name, tostring(track.Looped), track.Speed))
if #JH.rguardAnimLog > 400 then table.remove(JH.rguardAnimLog, 1) end
end)
end
notify("Remote Guard Recorder", "Recording. Guard someone, or have someone guard you.", 5)
else
if rconn then rconn:Disconnect() rconn = nil end
if roppConn then roppConn:Disconnect() roppConn = nil end
roppHum = nil
notify("Remote Guard Recorder", "Stopped. Tap Copy to get the report.", 4)
end
end)
local rLastPos, rLastLog = nil, 0
bind(RunService.Heartbeat, function()
if not S.RGuardOn then return end
local now = tick()
if now - rLastLog < 0.2 then return end
rLastLog = now
local h, r = hum(), Mover.body()
if not h or not r then return end
local speed = 0
if rLastPos then speed = flat(r.Position - rLastPos).Magnitude / 0.2 end
rLastPos = r.Position
local c2 = char()
local tracks = {}
for _, tr in ipairs(h:GetPlayingAnimationTracks()) do
local tid = tr.Animation and tr.Animation.AnimationId or "?"
tracks[#tracks + 1] = string.format("%s(%s,%s,spd=%.1f)", tid, tr.Priority.Name, tostring(tr.Looped), tr.Speed)
end
local nearest, nearestDist
local ok, others = pcall(Bot.others)
if ok and others then
for _, o in ipairs(others) do
local d = (o.pos - r.Position).Magnitude
if not nearestDist or d < nearestDist then nearest, nearestDist = o, d end
end
end
local oppName, oppTracks = "none", {}
if nearest and nearestDist and nearestDist < 30 then
oppName = (nearest.pl and nearest.pl.Name) or "?"
local oh = nearest.c and nearest.c:FindFirstChildOfClass("Humanoid")
if oh then
if oh ~= roppHum then hookOpp(oh) end
for _, tr in ipairs(oh:GetPlayingAnimationTracks()) do
local tid = tr.Animation and tr.Animation.AnimationId or "?"
oppTracks[#oppTracks + 1] = string.format("%s(%s,%s,spd=%.1f)", tid, tr.Priority.Name, tostring(tr.Looped), tr.Speed)
end
end
elseif roppHum then
hookOpp(nil)
end
local dbg = Bot.dbg or {}
local dbgLine = string.format("dbgTarget=%s dbgDist=%s dbgDir=%s dbgSent=%s dbgSentOk=%s dbgSentVia=%s dbgHumState=%s dbgBlockedReason=%s",
tostring(dbg.target or "none"),
dbg.dist and string.format("%.1f", dbg.dist) or "?",
dbg.dir and string.format("(%.2f,%.2f,%.2f)", dbg.dir.X, dbg.dir.Y, dbg.dir.Z) or "?",
dbg.sentVec and string.format("(%.2f,%.2f,%.2f)", dbg.sentVec.X, dbg.sentVec.Y, dbg.sentVec.Z) or "?",
tostring(dbg.sentOk), tostring(dbg.sentVia), tostring(dbg.humState), tostring(dbg.reason or "none"))
table.insert(JH.rguardMoveLog, string.format("%s  move  state=%s  speed=%.1f  holdingG=%s  action=%s  guarding=%s  playing=%s  opp=%s  oppDist=%s  oppPlaying=%s  %s",
os.date("%H:%M:%S"), h:GetState().Name, speed, tostring(c2 and c2:GetAttribute("HoldingG")), tostring(c2 and c2:GetAttribute("Action")), tostring(Bot.status or ""),
#tracks > 0 and table.concat(tracks, " | ") or "none", oppName, nearestDist and string.format("%.1f", nearestDist) or "?", #oppTracks > 0 and table.concat(oppTracks, " | ") or "none", dbgLine))
if #JH.rguardMoveLog > 200 then table.remove(JH.rguardMoveLog, 1) end
end)
UI.Button(rc, "Copy remote guard log", function()
local rlines = { "== REMOTE GUARD RECORDER " .. tostring(VERSION) .. " | " .. os.date("%Y-%m-%d %H:%M:%S") }
if #JH.rguardAnimLog == 0 and #JH.rguardMoveLog == 0 and #JH.rguardOppAnimLog == 0 then
rlines[#rlines + 1] = "(nothing recorded yet, turn it on and guard someone for real first)"
else
rlines[#rlines + 1] = "-- your animations (every one played, any priority) --"
for _, l in ipairs(JH.rguardAnimLog) do rlines[#rlines + 1] = l end
rlines[#rlines + 1] = "-- opponent animations (nearest player/bot to you, every one played) --"
for _, l in ipairs(JH.rguardOppAnimLog) do rlines[#rlines + 1] = l end
rlines[#rlines + 1] = "-- movement/state snapshots --"
for _, l in ipairs(JH.rguardMoveLog) do rlines[#rlines + 1] = l end
end
local text = table.concat(rlines, "\n")
pcall(function() if type(writefile) == "function" then writefile("JHub_remote_guard_log.txt", text) end end)
if type(setclipboard) == "function" then pcall(setclipboard, text) end
notify("Remote Guard Recorder", string.format("%.0f KB, saved as JHub_remote_guard_log.txt and copied", #text / 1024), 6)
end)
end

local RP = UI.Page("Rebound", "R")
local r1 = UI.Card(RP, "Auto rebound")
UI.Toggle(r1, "Auto rebound", "AR")
UI.Slider(r1, "Speed", "ARSpeed", 0.5, 3, 0.1, 1, "x")
UI.Slider(r1, "Reaction time", "ARReact", 0, 0.5, 0.01, 2, "s")
UI.Slider(r1, "Range", "ARRange", 15, 150, 5, 0, " studs")
UI.Toggle(r1, "Jump for the ball", "ARJump")
UI.Toggle(r1, "Grab it with the ball magnet when close", "ARMagnet")
UI.Slider(r1, "Grab distance", "ARMagRange", 3, 20, 1, 0, " studs")
UI.Toggle(r1, "Show where the ball will land", "ARMarker")
UI.Note(r1, "Follows the ball's path, runs to where it will come down at hand height, jumps and grabs it.")

local AP = UI.Page("Auto Grind", "G")
local a1 = UI.Card(AP, "Auto play")
local _, apLabel = UI.Button(a1, S.AP and "Auto play: ON (tap to stop)" or "Auto play: OFF (tap to start)", function() Bot.setAP(not S.AP) end, true)
Bot.apLabel = apLabel
local statStat = UI.Stat(a1, "Doing")
UI.Dropdown(a1, "Build", "APBuild", { "Big", "Small", "Wing", "Shooter" })
UI.Note(a1, "Needs Auto Green on, and it turns it on for you. Touch the stick and the bot hands the game back to you.")
local a2 = UI.Card(AP, "Big build")
UI.Toggle(a2, "Post score (post up and score all game)", "APPostScore")
UI.Slider(a2, "Post range from the hoop", "APPostRange", 4, 14, 0.5, 1, " studs")
local a3 = UI.Card(AP, "Small build")
UI.Toggle(a3, "All around score (dribble, shoot open, lay ups)", "APAllAround")
UI.Toggle(a3, "Dribble moves", "APMoves")
local a4 = UI.Card(AP, "Smart shots")
UI.Slider(a4, "Open when defender is farther than", "APOpenDist", 2, 15, 0.5, 1, " studs")
UI.Slider(a4, "Longest jumper", "APRange", 12, 40, 1, 0, " studs")
UI.Toggle(a4, "Take threes", "APThree")
UI.Toggle(a4, "Take lay ups and dunks", "APLayups")
UI.Toggle(a4, "Drive to the hoop", "APDrive")
UI.Slider(a4, "Time between shots", "APShotDelay", 0.3, 4, 0.1, 1, "s")
local a5 = UI.Card(AP, "Movement")
UI.Slider(a5, "Bot speed", "APSpeed", 0.5, 2, 0.1, 1, "x")
UI.Toggle(a5, "Sprint", "APSprint")
UI.Slider(a5, "Stop sprinting under this stamina", "APStaminaMin", 0, 80, 5, 0, "%")
UI.Slider(a5, "Spot up distance", "APSpot", 12, 30, 1, 0, " studs")
local a6 = UI.Card(AP, "Behaviour")
UI.Toggle(a6, "Guard when the other team has the ball", "APDefend")
UI.Toggle(a6, "Chase rebounds", "APRebound")
UI.Toggle(a6, "Hand control back when I touch the stick", "APPause")
UI.Toggle(a6, "Anti AFK", "APAntiAfk")
UI.Dropdown(a6, "Teammates", "APTeam", { "By team", "Everyone is an opponent" })
UI.Dropdown(a6, "Hoop to attack", "APHoop", { "Nearest", "Farthest" })
UI.Button(a6, "Rescan hoops", function() task.spawn(Bot.scanHoops) end)
UI.Button(a6, "Mark a hoop (stand under the rim first)", function()
local r = Mover.body()
if not r then return end
local p = r.Position
S.HoopMarks = (S.HoopMarks or "") .. string.format("%.1f,%.1f,%.1f;", p.X, p.Y + 8, p.Z)
saveSoon()
task.spawn(Bot.scanHoops)
notify("Hoop", "Marked", 2)
end)

task.spawn(function()
while JH.Running do
if Window.Visible and UI.current and UI.current.name == "Auto Grind" then
pcall(function() statStat.Text = Bot.status end)
end
task.wait(0.4)
end
end)

-- Auto Grind is unfinished and stays hidden; Auto Guard no longer force-hidden or force-disabled
for _, p in ipairs(UI.pages) do
if p.name == "Auto Grind" then p.lbl.Parent.Visible = false end
end

-- UI customizations goes to the bottom of the tab list
for _, p in ipairs(UI.pages) do
if p.name == "UI" then p.lbl.Parent.LayoutOrder = 999 end
end
if S.AP then S.AP = false end
task.spawn(Bot.scanHoops)
end
-- LAG SYNC: Auto Green follows ping and FPS changes
do
local Lag = { pings = {}, dts = {}, dtEma = 1 / 60, stable = nil, pingBase = nil, dtBase = nil }
JH.api.Lag = Lag
Shot.slopes = Shot.slopes or {}

local function pct(list, q)
local t = {}
for i, v in ipairs(list) do t[i] = v end
table.sort(t)
return t[math.max(1, math.floor(#t * q))]
end
bind(RunService.Heartbeat, function(dt) Lag.dtEma = Lag.dtEma * 0.9 + dt * 0.1 end)
task.spawn(function()
local n = 0
while JH.Running do
local ok, p = pcall(function() return LP:GetNetworkPing() end)
if ok and type(p) == "number" then
Lag.pings[#Lag.pings + 1] = p
if #Lag.pings > 3000 then table.remove(Lag.pings, 1) end
local tail = {}
for i = math.max(1, #Lag.pings - 14), #Lag.pings do tail[#tail + 1] = Lag.pings[i] end
Lag.stable = pct(tail, 0.5)
end
Lag.dts[#Lag.dts + 1] = Lag.dtEma
if #Lag.dts > 3000 then table.remove(Lag.dts, 1) end
n = n + 1
if n % 50 == 0 and #Lag.pings >= 150 then
Lag.pingBase = pct(Lag.pings, 0.3)
Lag.dtBase = pct(Lag.dts, 0.35)
end
task.wait(0.1)
end
end)

-- how much worse than your normal the ping and the frame time are right now
function Lag.pingEx()
if not Lag.stable or not Lag.pingBase then return 0 end
return math.max(0, Lag.stable - Lag.pingBase)
end
function Lag.fpsComp()
if not S.LagSync or not Lag.dtBase then return 0 end
return clamp((Lag.dtEma - Lag.dtBase) / 2, 0, 0.12)
end
function Lag.total()
return clamp(Lag.pingEx() * (S.LagK or 2) + Lag.fpsComp(), 0, 0.25)
end

local basePingNow = Shot.pingNow
function Shot.pingNow()
if S.LagSync and Lag.stable then return Lag.stable end
return basePingNow()
end
function Shot.effPing()
local p = Shot.pingNow()
if not S.LagSync then return p end
return p + Lag.pingEx() * ((S.LagK or 2) - 1)
end
function Shot.fpsComp() return Lag.fpsComp() end
function Shot.lookAhead()
if S.LagSync then return clamp(1.25 * Lag.dtEma, 0.02, 0.2) end
return 0.02
end
local basePingComp = Shot.pingComp
function Shot.pingComp()
local c, p = basePingComp()
if not S.LagSync then return c, p end
return clamp(math.max(c, Lag.total()), 0, 0.25), p
end
function Shot.markShot()
Shot.lastShotFps = JH.FPS
Shot.lastShotEx = Lag.pingEx()
end

-- the meter climbs at a steady speed per shot, so once that speed is known a laggy frame rate can still find the peak
local function ls(pts)
local n = #pts
local t0 = pts[1].t
local st, sq, stt, stq = 0, 0, 0, 0
for _, p in ipairs(pts) do
local x = p.t - t0
st, sq, stt, stq = st + x, sq + p.q, stt + x * x, stq + x * p.q
end
local den = n * stt - st * st
if den <= 1e-9 then return nil end
return (n * stq - st * sq) / den
end
function Shot.peakFitSmart(samples, key)
local base = Shot.peakFit(samples)
if not S.LagSync then return base end
local pts, lastq = {}, -1
for _, sm in ipairs(samples) do
if sm.q < lastq - 0.001 then break end
lastq = sm.q
if sm.q > 0.12 and sm.q < 0.93 then pts[#pts + 1] = sm end
end
local n = #pts
if n < 2 then return base end
local fps = JH.FPS or 60
local known = Shot.slopes[key]
local a = n >= 6 and ls(pts) or nil
if a and (a < 1.2 or a > 5) then a = nil end
local agrees = (not a) or (not known) or math.abs(a - known) / known < 0.08
if known and agrees and pts[n].q > 0.25 and (S.PrecFit or fps < 45 or n < 7) then
local sum, wsum = 0, 0
for _, p in ipairs(pts) do
local w = p.q * p.q
sum = sum + (p.t + (Shot.PEAK_Q - p.q) / known) * w
wsum = wsum + w
end
return sum / wsum
end
return base
end
Shot.slopeMiss = Shot.slopeMiss or {}
function Shot.slopeCommit(samples, key)
if not S.LagSync or (JH.FPS or 60) < 40 then return end
local pts, lastq = {}, -1
for _, sm in ipairs(samples) do
if sm.q < lastq - 0.001 then break end
lastq = sm.q
if sm.q > 0.12 and sm.q < 0.93 then pts[#pts + 1] = sm end
end
if #pts < 8 then return end
local a = ls(pts)
if not a or a < 1.2 or a > 5 then return end
local known = Shot.slopes[key]
if not known then
Shot.slopes[key] = a
elseif math.abs(a - known) / known < 0.08 then
Shot.slopes[key] = known * 0.85 + a * 0.15
Shot.slopeMiss[key] = 0
else
local miss = (Shot.slopeMiss[key] or 0) + 1
Shot.slopeMiss[key] = miss
if miss >= 3 then Shot.slopes[key], Shot.slopeMiss[key] = a, 0 end
end
end

-- built in and fixed shots have no learner, so the ping factor is learned from their verdicts
function Shot.lagLearn(info, res, strength)
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if not idx or idx == 5 or idx == 4 then return end
local ex = Shot.lastShotEx or 0
if ex < 0.015 or (Shot.lastShotFps or 60) < 30 then return end
local err = (idx - 5) * 0.014
S.LagK = clamp((S.LagK or 2) + err / ex * 0.3, 0.5, 3.5)
saveSoon()
end
local baseLearn = Shot.learnRemote
function Shot.learnRemote(info, res, strength)
if S.LagSync and info and Shot.FINAL[info.key] and not info.manual then pcall(Shot.lagLearn, info, res, strength) end
return baseLearn(info, res, strength)
end

local shootPage
for _, p in ipairs(UI.pages) do
if p.name == "Shooting" then shootPage = p end
end
if shootPage then
local c = UI.Card(shootPage, "Lag sync")
UI.Toggle(c, "Auto Green MAX (best timing, all upgrades)", "GreenMax", function(v)
for _, k in ipairs({ "LagSync", "PrecFit", "AdaptPlus" }) do UI.set(k, v, false) end
end)
UI.Toggle(c, "Green every jumper (shared learning)", "AllJumpers")
UI.Slider(c, "Fade and step back timing (later)", "FadeNudge", -30, 40, 1, 0, " ms")
UI.Toggle(c, "Auto adapt: learn every shot from the first one", "AutoAdaptAll")
UI.Toggle(c, "Instant green (works at low FPS and high ping)", "InstantGreen")
UI.Toggle(c, "Smart steps (faster learning, no bouncing)", "SmartSteps")
UI.Toggle(c, "Show live open/contested feedback while dribbling", "ContestShow")
UI.Toggle(c, "Keep glides away from my shot", "GlideShotSafe")
UI.Buttons(c, { { "Copy my locked timings", function() local t = Shot.exportTimings() if setclipboard then setclipboard(t) end notify("Timings", t == "" and "Nothing locked yet" or "Copied to clipboard", 3) end } })
UI.Input(c, "Import timings", "ImportTimes", nil, "paste copied timings, then rejoin")
UI.Toggle(c, "Lag sync (follow my ping and FPS)", "LagSync")
UI.Toggle(c, "Smoother meter reading", "PrecFit")
UI.Toggle(c, "Faster jumper adapt (experimental)", "AdaptPlus")
UI.Note(c, "Learns your normal ping and FPS. When either gets worse, Auto Green releases earlier by exactly that much, so the shot still lands on the green. Nothing changes while you are at your normal.")
UI.Slider(c, "Ping compensation factor (learns by itself)", "LagK", 0.5, 3.5, 0.05, 2, "x")
local sPing = UI.Stat(c, "Ping now")
local sBase = UI.Stat(c, "Ping normal")
local sFps = UI.Stat(c, "FPS now")
local sShift = UI.Stat(c, "Release shifted by")
local sPerf = UI.Stat(c, "Perfects")
task.spawn(function()
while JH.Running do
if Window.Visible and UI.current == shootPage then
pcall(function()
sPing.Text = Lag.stable and string.format("%d ms", math.floor(Lag.stable * 1000 + 0.5)) or "-"
sBase.Text = Lag.pingBase and string.format("%d ms", math.floor(Lag.pingBase * 1000 + 0.5)) or "learning"
sFps.Text = string.format("%d", math.floor(JH.FPS + 0.5))
sShift.Text = S.LagSync and string.format("%d ms earlier", math.floor(Lag.total() * 1000 + 0.5)) or "off"
sPerf.Text = string.format("%d / %d (%d%%)", Shot.stats.greens, Shot.stats.shots, Shot.stats.shots > 0 and math.floor(Shot.stats.greens * 100 / Shot.stats.shots + 0.5) or 0)
end)
end
task.wait(0.5)
end
end)
end
end
-- AUTO ADAPT: faster and centered learning for new jumpers
do
local function verdictIdx(info, res, strength)
return info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
end
local function idsOf(key)
local set, n = {}, 0
for id in string.gmatch(key, "%d+") do
set[id] = true
n = n + 1
end
return set, n
end

-- a new jumper starts from a shot it is built from, else from the middle of what you have already locked
function Shot.seedLead(key)
if not S.AdaptPlus then return S.PeakLead or 0.027 end
local mine, mn = idsOf(key)
local best, bn
local list = {}
for k2, a2 in pairs(Shot.auto or {}) do
if k2 ~= key and a2.mode == "peak" and a2.locked and a2.hold then
list[#list + 1] = a2.hold
local other, on = idsOf(k2)
local small, big, sn = mine, other, mn
if on < mn then small, big, sn = other, mine, on end
local all = sn > 0
for id in pairs(small) do
if not big[id] then
all = false
break
end
end
if all and (not bn or sn > bn) then best, bn = a2.hold, sn end
end
end
if best then return best end
if #list >= 2 then
table.sort(list)
return list[math.ceil(#list / 2)]
end
return S.PeakLead or 0.027
end

-- every verdict says which way and about how far the release was off, so the first correction already lands close,
-- and the lock is placed in the middle of the Perfect window instead of on its edge
local origPeakLearn = Shot.peakLearn
function Shot.peakLearn(info, res, strength, a, key)
if not S.AdaptPlus then return origPeakLearn(info, res, strength, a, key) end
if a.locked then return true end
local idx = verdictIdx(info, res, strength)
if not idx then return true end
if info.manual and idx ~= 5 then return true end
local lead = info.lead or a.hold
if not info.manual and math.abs(lead - a.hold) > 0.05 then return true end
local before = a.hold
a.n = (a.n or 0) + 1
a.bin = a.bin or S.PeakBin or 0.014
local prev = a.prev
if prev and idx ~= 5 and prev.idx ~= 5 and prev.idx ~= idx and math.abs(lead - prev.lead) > 0.002 then
local est = -(lead - prev.lead) / (idx - prev.idx)
if est > 0 then
a.bin = clamp(a.bin * 0.5 + est * 0.5, 0.006, 0.04)
S.PeakBin = clamp((S.PeakBin or 0.014) * 0.7 + a.bin * 0.3, 0.008, 0.03)
end
end
a.prev = { idx = idx, lead = lead }
local why
if idx == 5 then
local shift = 0
if prev and (prev.idx == 6 or prev.idx == 4) then
local edge = (prev.lead + lead) / 2
local center = (prev.idx == 6) and (edge + a.bin / 2) or (edge - a.bin / 2)
shift = clamp(center - lead, -a.bin / 2, a.bin / 2)
end
a.hold, a.locked = clamp(lead + shift, 0, 0.1), true
S.PeakLead = clamp(S.PeakLead * 0.5 + a.hold * 0.5, 0, 0.08)
pcall(notify, "Auto Green", string.format("Learned this shot: %.0f ms before the peak", a.hold * 1000), 3)
why = "Perfect, locked"
else
local off = idx - 5
if idx == 4 then off = -1 end
a.hold = clamp(lead + off * a.bin * 0.85, 0, 0.1)
S.PeakLead = clamp(S.PeakLead + (a.hold - lead) * 0.25, 0, 0.08)
why = (Shot.VERDICT[idx] or "?") .. (off > 0 and ", letting go earlier" or ", letting go later")
end
if math.abs(a.hold - before) > 0.0003 or a.locked then Shot.noteAdjust(key, before, a.hold, why) end
Shot.autoSave()
if Rec.shotOn then
Rec.shotAdd(string.format("AUTOCAL(meter) key=%s idx=%s lead=%.4f next=%.4f locked=%s bin=%.4f", key, tostring(idx), lead, a.hold, tostring(a.locked), a.bin))
end
return true
end
end
-- AUTO GREEN MAX EXTRAS, HUMAN GUARD, REAL LOOKS AND LOGOS
do
local Bot = JH.api.Bot
local V = Feat.V
local function verdictIdx(info, res, strength)
return info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
end

-- built in shots follow the verdicts too: a steady bias moves them, one big miss moves them at once
Shot.finalAdj = Shot.finalAdj or {}
Shot.finalSt = {}
Shot.finalLoaded = false
function Shot.finalLoad()
if Shot.finalLoaded then return end
Shot.finalLoaded = true
for key, val in string.gmatch(S.FinalAdj or "", "(%S-)=([%-%d%.]+)") do
Shot.finalAdj[key] = tonumber(val)
end
end
function Shot.finalSave()
local parts = {}
for key, val in pairs(Shot.finalAdj) do parts[#parts + 1] = string.format("%s=%.4f", key, val) end
table.sort(parts)
S.FinalAdj = table.concat(parts, " ")
saveSoon()
end
function Shot.finalLearn(info, res, strength)
if info.manual then return end
if S.LagSync and (Shot.lastShotEx or 0) >= 0.015 then return end
local idx = verdictIdx(info, res, strength)
if not idx then return end
Shot.finalLoad()
local key = info.key
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
local st = Shot.finalSt[key]
if not st then
st = { b = 0 }
Shot.finalSt[key] = st
end
local bin = S.PeakBin or 0.014
local old = Shot.finalAdj[key] or 0
local new = old
st.b = st.b * 0.7 + off * 0.3
if math.abs(off) >= 2 then
new = old - off * bin * 0.7
st.b = 0
elseif math.abs(st.b) >= 0.45 then
new = old - st.b * bin * 0.8
st.b = 0
end
new = clamp(new, -0.05, 0.05)
if new ~= old then
Shot.finalAdj[key] = new
Shot.noteAdjust(key, (Shot.FINAL[key] or 0) + old, (Shot.FINAL[key] or 0) + new, Shot.VERDICT[idx] or "?")
Shot.finalSave()
end
end

-- real guarding, rebuilt plain and simple: move the character to the spot with CFrame (same as every other bot movement in this script), hold the real Guard button so HoldingG is genuinely true, and play your own real walk/guard animation on top. No simulated keys, no simulated touches - those were freezing the camera.
local guardHeld = false
function Bot.setGuardHold(on)
if S.AGHoldToUse then return end
if on == guardHeld then return end
Input.action("Guard", on)
guardHeld = on
end
bind(RunService.Heartbeat, function()
if not S.AG and guardHeld then Bot.setGuardHold(false) end
end)
-- the guard looks like a player: it sways, reacts a little differently each time, sometimes hesitates and never runs faster than a player can
function Bot.guardStep(me, others, forced)
local t = Bot.pickTarget(others, me, forced)
if not t then
Bot.dbg = { reason = "no target found" }
return false
end
local dist = flat(t.pos - me).Magnitude
if dist > S.AGRange and not S.AGLock then
Bot.dbg = { target = t.pl.Name, targetPos = t.pos, dist = dist, reason = string.format("out of AGRange (%.0f > %.0f) and AGLock is off", dist, S.AGRange) }
return false
end
local now = tick()
local amt = S.AGHuman and (S.AGHumanAmt or 50) / 100 or 0
local w = Bot.wob
if amt > 0 and (not w or now - w.t > 0.5 + math.random() * 0.9) then
w = { t = now, ox = (math.random() - 0.5) * 2.4 * amt, oz = (math.random() - 0.5) * 2.4 * amt,
sp = 1 - 0.18 * amt + math.random() * 0.3 * amt, rj = math.random() * 0.12 * amt,
pause = (math.random() < 0.12 * amt) and (now + 0.12) or 0 }
Bot.wob = w
end
local react = (S.AGLock and 0 or S.AGReact) + ((w and amt > 0) and w.rj or 0)
if not Bot.spot or Bot.spotTarget ~= t or now - Bot.spotT >= react then
local ppos = t.pos + t.vel * S.AGPredict
local hoop = Bot.nearestHoop(ppos)
local dirf = hoop and flat(hoop - ppos) or flat(t.vel)
if dirf.Magnitude < 0.1 then dirf = flat(me - ppos) end
if dirf.Magnitude < 0.1 then dirf = Vector3.new(0, 0, 1) end
local spot = ppos + dirf.Unit * S.AGDist
if w and amt > 0 then spot = spot + Vector3.new(w.ox, 0, w.oz) end
Bot.spot, Bot.spotTarget, Bot.spotT = spot, t, now
end
Bot.setGuardHold(true)
local mul = 1 + (S.GuardSpeed or 0) / 100
if amt > 0 then mul = math.min(mul * w.sp, (S.AGLock and (1 + 0.8 * amt) or (1 + 0.35 * amt))) end
if w and amt > 0 and w.pause > now then
Bot.stopMove()
Bot.dbg = { target = t.pl.Name, targetPos = t.pos, spot = Bot.spot, dir = Vector3.new(), reason = "human-wobble pause" }
if S.AGFace then Bot.faceAt(t.pos) end
Bot.status = "Guarding " .. t.pl.Name
return true
end
local to = flat(Bot.spot - me)
local d = to.Magnitude
local dir
if d < 0.5 then
Bot.stopMove()
dir = Vector3.new()
else
local gain = S.AGLock and 1 or math.min(1, d / 3)
dir = to.Unit * gain
Bot.move(dir, mul)
end
-- merge, don't replace - Bot.move/Bot.stopMove already wrote sentVia/sentVec/sentOk/humState into Bot.dbg just above, overwriting the whole table here was wiping that out of the log
Bot.dbg = Bot.dbg or {}
Bot.dbg.target, Bot.dbg.targetPos, Bot.dbg.spot, Bot.dbg.dist, Bot.dbg.dir = t.pl.Name, t.pos, Bot.spot, d, dir
Bot.dbg.reason = d < 0.5 and "within 0.5 studs of ideal spot, stopped" or nil
if S.AGFace then Bot.faceAt(t.pos) end
Bot.status = "Guarding " .. t.pl.Name
return true
end


-- your own logo pictures: paste the image number from a Roblox image link
function V.customId(key)
for k, id in string.gmatch(S.LogoIds or "", "(%w+)=(%d+)") do
if k == key then return id end
end
return nil
end
function V.customLogo(key)
local id = V.customId(key)
return id and ("rbxassetid://" .. id) or nil
end
function V.setCustomId(key, text)
local id = string.match(tostring(text or ""), "%d+")
local parts = {}
for k, v in string.gmatch(S.LogoIds or "", "(%w+)=(%d+)") do
if k ~= key then parts[#parts + 1] = k .. "=" .. v end
end
if id then parts[#parts + 1] = key .. "=" .. id end
S.LogoIds = table.concat(parts, " ")
V.logoKey = nil
saveSoon()
end

-- copy the clothes and accessories of any real Roblox account, on your screen only
function Feat.lookAs(name, uid)
task.spawn(function()
local id = uid
if not id then
local ok, r = pcall(function() return Players:GetUserIdFromNameAsync(trim(tostring(name))) end)
if not ok or not r then
notify("Real look", "No Roblox player called " .. tostring(name), 4)
return
end
id = r
end
local ok, model = pcall(function() return Players:GetCharacterAppearanceAsync(id) end)
local c = char()
if not ok or not model or not c then
notify("Real look", "Could not load that look", 4)
return
end
local h = c:FindFirstChildOfClass("Humanoid")
for _, d in ipairs(c:GetChildren()) do
if d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("BodyColors") then d:Destroy() end
end
for _, d in ipairs(model:GetChildren()) do
if d:IsA("Accessory") then
if h then pcall(function() h:AddAccessory(d:Clone()) end) end
elseif d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("BodyColors") then
d:Clone().Parent = c
end
end
notify("Real look", "Now looking like " .. tostring(name), 3)
end)
end

local fp
for _, p in ipairs(UI.pages) do
if p.name == "Features" then fp = p end
end
if fp then
local lc = UI.Card(fp, "Real look")
UI.Input(lc, "Roblox username", "LookUser", nil, "type a username")
UI.Buttons(lc, { { "Look like this player", function() Feat.lookAs(S.LookUser) end }, { "Back to my look", function() Feat.lookAs(LP.Name, LP.UserId) end } })
UI.Note(lc, "Copies the clothes and accessories of any real Roblox account, only on your screen. Use it for any creator or character that has a Roblox account.")
local lg = UI.Card(fp, "Custom logo image")
UI.Input(lg, "Image ID for the logo picked above", { get = function() return V.customId(S.Logo) or "" end, set = function(v) V.setCustomId(S.Logo, v) end }, nil, "number from the image link")
UI.Note(lg, "Paste the number from the creator's real logo image link and it replaces the badge above your head.")
end
end
-- GREEN EVERY JUMPER: one shared lead learned from every verdict, used by every jumper, new or old
do
local origActive = Shot.autoActive
function Shot.autoActive(key)
if S.AllJumpers and S.AutoCal and not Shot.FINAL[key] and not (S.Sweep and Rec.shotOn) then return true end
return origActive(key)
end
local prevSeed = Shot.seedLead
function Shot.seedLead(key)
if S.AllJumpers and (S.GLeadN or 0) >= 3 and (S.GLead or 0) > 0 then
local v = prevSeed(key)
-- a related locked jumper is trusted first, else the shared lead
local mine = Shot.auto and Shot.auto[key]
if v == (S.PeakLead or 0.027) or not S.AdaptPlus then return clamp(S.GLead, 0, 0.1) end
return v
end
return prevSeed(key)
end
local prevLearn = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if S.AllJumpers and info and info.lead and not info.manual and info.remote ~= false then
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx and (S.LagSync and (Shot.lastShotEx or 0) >= 0.015) == false then
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
if math.abs(off) <= 3 then
local est = clamp(info.lead + off * (S.PeakBin or 0.014) * 0.8, 0, 0.1)
local n = S.GLeadN or 0
if n < 3 or (S.GLead or 0) <= 0 then S.GLead = est else S.GLead = S.GLead * 0.85 + est * 0.15 end
S.GLeadN = math.min(n + 1, 999)
saveSoon()
end
end
end
return prevLearn(info, res, strength)
end
end
-- SHARED TIMINGS: timings baked into the script are what every user starts from; "Copy my timings" exports yours
do
Shot.SHARED = ""
local origLoad = Shot.autoLoad
function Shot.autoLoad()
local first = not Shot.autoLoaded
origLoad()
if first then
for kind, key, val in string.gmatch(Shot.SHARED .. " " .. (S.ImportTimes or ""), "(%a):(%S-)=([%d%.]+)") do
if not Shot.auto[key] then
Shot.auto[key] = { hold = tonumber(val), greens = {}, locked = (kind == "L" or kind == "l"), dir = 1, mode = (kind == "l" or kind == "p") and "peak" or nil }
end
end
end
end
function Shot.exportTimings()
Shot.autoLoad()
local parts = {}
for key, a in pairs(Shot.auto) do
if a.locked then parts[#parts + 1] = string.format("%s:%s=%.4f", a.mode == "peak" and "l" or "L", key, a.hold) end
end
table.sort(parts)
return table.concat(parts, " ")
end
end
-- FIRST SHOT ACCURACY: the meter speed is shared by every shot, so a new jumper reads its peak from the shared speed at once
do
Shot.GSLOPE = 2.68
function Shot.gslope()
local list = {}
for _, v in pairs(Shot.slopes) do list[#list + 1] = v end
if #list >= 3 then
table.sort(list)
return list[math.ceil(#list / 2)]
end
return Shot.GSLOPE
end
local prevSmart = Shot.peakFitSmart
function Shot.peakFitSmart(samples, key)
local tp = prevSmart(samples, key)
if not S.FirstShot or not S.LagSync or Shot.slopes[key] then return tp end
local pts, lastq = {}, -1
for _, sm in ipairs(samples) do
if sm.q < lastq - 0.001 then break end
lastq = sm.q
if sm.q > 0.12 and sm.q < 0.93 then pts[#pts + 1] = sm end
end
local n = #pts
if n < 3 or pts[n].q < 0.25 then return tp end
local g = Shot.gslope()
if n >= 6 then
local t0, st, sq, stt, stq = pts[1].t, 0, 0, 0, 0
for _, p in ipairs(pts) do
local x = p.t - t0
st, sq, stt, stq = st + x, sq + p.q, stt + x * x, stq + x * p.q
end
local den = n * stt - st * st
if den > 1e-9 then
local a = (n * stq - st * sq) / den
if math.abs(a - g) / g > 0.2 then return tp end
end
end
local sum, wsum = 0, 0
for _, p in ipairs(pts) do
local w = p.q * p.q
sum = sum + (p.t + (Shot.PEAK_Q - p.q) / g) * w
wsum = wsum + w
end
return sum / wsum
end
-- a brand new jumper aims a little early: Good is on the early side of Perfect, while late shots show a full bar
local prevSeed2 = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeed2(key)
return v
end
-- a very early or very late result moves a jumper that is still learning further and at once
local prevLearn2 = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
local r = prevLearn2(info, res, strength)
if S.FirstShot and info and not info.manual then
local a = Shot.auto and Shot.auto[info.key]
local idx = info.idx or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if a and a.mode == "peak" and not a.locked and idx and (idx >= 7 or idx <= 2) then
a.hold = clamp(a.hold + (idx - 5) * (a.bin or S.PeakBin or 0.014) * 0.4, 0, 0.1)
Shot.autoSave()
end
end
return r
end
end
-- FADES AND BUILT IN SHOTS: exactly as they were before the upgrades, none of the new timing changes touch them
do
local prevHold = Shot.remoteHold
function Shot.remoteHold(key, pk)
Shot.isFinalShot = Shot.FINAL[key] ~= nil
return prevHold(key, pk)
end
Shot.finalAdj = {}
function Shot.finalLoad() Shot.finalLoaded = true end
function Shot.finalLearn() end
function Shot.lagLearn() end
local prevPC = Shot.pingComp
function Shot.pingComp()
if Shot.isFinalShot then
local p = Shot.pingNow()
if not S.PerfectGreen then return 0, p end
return clamp((p - Shot.PING_REF) * ((S.PerfectGreenPct or 100) / 100), 0, 0.2), p
end
return prevPC()
end
local prevLook = Shot.lookAhead
function Shot.lookAhead()
if Shot.isFinalShot then return 0.02 end
return prevLook()
end
end
-- POST FADES: these built-in timings keep learning from the game's verdicts and settle on Perfect; every other built-in shot is left alone
do
local POST = {
["111074210919383"] = true, ["71484695722621"] = true,
["77401448272074"] = true, ["128777513307709+77401448272074"] = true,
}
local loaded, st = false, {}
local function load()
if loaded then return end
loaded = true
for key, val in string.gmatch(S.FinalAdj or "", "(%S-)=([%-%d%.]+)") do
if Shot.FINAL[key] then Shot.finalAdj[key] = tonumber(val) end
end
end
local function save()
local parts = {}
for key in pairs(Shot.finalAdj) do
if Shot.finalAdj[key] then parts[#parts + 1] = string.format("%s=%.4f", key, Shot.finalAdj[key]) end
end
table.sort(parts)
S.FinalAdj = table.concat(parts, " ")
saveSoon()
end
function Shot.finalLoad() load() end
function Shot.finalLearn(info, res, strength)
if info.manual or not Shot.FINAL[info.key] or not (POST[info.key] or S.AutoAdaptAll) then return end
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if not idx then return end
load()
local key = info.key
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
local s = st[key] or { b = 0 }
st[key] = s
local first = (s.n or 0) == 0
s.n = (s.n or 0) + 1
local bin, old = 0.014 * (first and 1.5 or 1) * (Shot.adaptGain and Shot.adaptGain(key, off) or 1), Shot.finalAdj[key] or 0
local new = old
s.b = s.b * 0.7 + off * 0.3
if math.abs(off) >= 2 then
new, s.b = old - off * bin * 0.9, 0
elseif math.abs(s.b) >= 0.45 then
new, s.b = old - s.b * bin * 0.8, 0
end
new = clamp(new, -0.06, 0.06)
if new ~= old then
Shot.finalAdj[key] = new
Shot.noteAdjust(key, (Shot.FINAL[key] or 0) + old, (Shot.FINAL[key] or 0) + new, Shot.VERDICT[idx] or "?")
save()
end
end
end
-- POST SPIN FADE ON EVERY CHOSEN JUMPSHOT: any jumpshot that ends in a post fade starts from the post fade's own learned timing
do
local FADE = { "111074210919383", "71484695722621", "77401448272074" }
local function isFade(key)
key = tostring(key)
for _, id in ipairs(FADE) do
if string.find(key, id, 1, true) then return true end
end
return false
end
local prevSeed3 = Shot.seedLead
function Shot.seedLead(key)
if isFade(key) and (S.PFLeadN or 0) >= 2 and (S.PFLead or 0) > 0 then return clamp(S.PFLead, 0, 0.1) end
return prevSeed3(key)
end
local prevLearn3 = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if info and info.lead and not info.manual and not Shot.FINAL[info.key] and isFade(info.key) then
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx then
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
if math.abs(off) <= 3 then
local est = clamp(info.lead + off * (S.PeakBin or 0.014) * 0.8, 0, 0.1)
local n = S.PFLeadN or 0
if n < 2 or (S.PFLead or 0) <= 0 then S.PFLead = est else S.PFLead = S.PFLead * 0.8 + est * 0.2 end
S.PFLeadN = math.min(n + 1, 999)
saveSoon()
end
end
end
return prevLearn3(info, res, strength)
end
end
-- JHUB LOGO: the menu button shows the J-Hub picture (downloaded once, falls back to the old J bolt H if the executor cannot)
do
local URL = "https://raw.githubusercontent.com/jaydendagoat2/jayhubv1/claude/claudechud-8cord-executor-wclom3/executor/jhub_logo2.png"
local FILE = "JHub_logo_v2.png"
task.spawn(function()
if type(getcustomasset) ~= "function" or type(writefile) ~= "function" then return end
local have = false
if type(isfile) == "function" then
local ok, r = pcall(isfile, FILE)
have = ok and r
end
if not have then
local ok, data = pcall(function() return game:HttpGet(URL) end)
if not ok or type(data) ~= "string" or #data < 1000 then return end
if not pcall(writefile, FILE, data) then return end
end
local ok, asset = pcall(getcustomasset, FILE)
if not ok or not asset or asset == "" then return end
local body = UI.LogoBody
if not body or not body.Parent then return end
local img = Instance.new("ImageLabel")
img.Name = "JHubLogo"
img.BackgroundTransparency = 1
img.Size = UDim2.fromScale(1, 1)
img.Image = asset
img.ScaleType = Enum.ScaleType.Fit
img.ZIndex = 3
img.Parent = body
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0.2, 0)
c.Parent = img
for _, d in ipairs(body:GetChildren()) do
if d:IsA("GuiObject") and d ~= img then d.Visible = false end
end
for _, l in ipairs(UI.FloatLetters or {}) do pcall(function() l.Visible = false end) end
end)
end
-- J-HUB SKIN: the artwork is the menu background, tabs sit in its rail, cards sit side by side and wrap underneath
do
local W, H = 720, 405
Window.Size = UDim2.fromOffset(W, H)
local artOn = false
local collapsedNow = false
local function layout()
Main.BackgroundTransparency = 1
pcall(function() Main:FindFirstChild("Storm").Visible = false end)
Sheen.Visible = false
MainStroke.Transparency = 1
Body.Position, Body.Size = UDim2.fromScale(0, 0), UDim2.fromScale(1, 1)
Header.Position, Header.Size = UDim2.fromScale(0.28, 0.105), UDim2.fromScale(0.70, 0.095)
Rail.Position, Rail.Size = UDim2.fromScale(0.045, 0.40), UDim2.fromScale(0.2, 0.52)
Content.Position, Content.Size = UDim2.fromScale(0.285, 0.25), UDim2.fromScale(0.685, 0.66)
RailLine.Visible = false
local badge = Header:FindFirstChild("LogoBadge")
if badge then badge.Visible = false end
for _, d in ipairs(Header:GetChildren()) do
if d:IsA("TextLabel") then d.Position = UDim2.new(0, 12, 0.5, -7) end
end
end
local function twoColumns()
for _, p in ipairs(UI.pages) do
local lay = p.frame:FindFirstChildOfClass("UIListLayout")
if lay then
lay.FillDirection = Enum.FillDirection.Horizontal
lay.Wraps = true
lay.Padding = UDim.new(0, 8)
end
for _, c in ipairs(p.frame:GetChildren()) do
if c:IsA("Frame") then c.Size = UDim2.new(0.5, -4, 0, 0) end
end
end
end
layout()
twoColumns()
local origApply = UI.applyWindow
function UI.applyWindow(...)
local r = origApply(...)
if not collapsedNow then layout() end
return r
end
function UI.fitScale()
local vp = cam().ViewportSize
local s = math.min(vp.X * 0.94 / W, vp.Y * 0.86 / H)
if s > 1.15 then s = 1.15 end
WinScale.Scale = s * S.UIScale
end
UI.fitScale()

local art
CollapseBtn.Activated:Connect(function()
task.wait()
collapsedNow = collapsed
if collapsed then
if art then art.Visible = false end
Main.BackgroundTransparency = 0
Header.Position, Header.Size = UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 46)
Window.Size = UDim2.fromOffset(W, 46)
else
if art then art.Visible = true end
Window.Size = UDim2.fromOffset(W, H)
layout()
end
end)

local URL = "https://raw.githubusercontent.com/jaydendagoat2/jayhubv1/claude/claudechud-8cord-executor-wclom3/executor/jhub_ui_bg2.png"
local FILE = "JHub_ui_bg_v2.png"
task.spawn(function()
if type(getcustomasset) ~= "function" or type(writefile) ~= "function" then return end
local have = false
if type(isfile) == "function" then
local ok, r = pcall(isfile, FILE)
have = ok and r
end
if not have then
local ok, data = pcall(function() return game:HttpGet(URL) end)
if not ok or type(data) ~= "string" or #data < 1000 then return end
if not pcall(writefile, FILE, data) then return end
end
local ok, asset = pcall(getcustomasset, FILE)
if not ok or not asset or asset == "" then return end
art = Instance.new("ImageLabel")
art.Name = "JHubArt"
art.BackgroundColor3 = Color3.new(0, 0, 0)
art.BorderSizePixel = 0
art.Size = UDim2.fromScale(1, 1)
art.Image = asset
art.ScaleType = Enum.ScaleType.Stretch
art.ZIndex = 0
art.Visible = not collapsedNow
art.Parent = Main
artOn = true
end)
end
-- J-HUB RED: one red theme everywhere, the old blue glass, lightning and logo backing are gone
do
local TONES = {
Rainbow = { Color3.fromRGB(70, 140, 255), Color3.fromRGB(255, 214, 60), Color3.fromRGB(165, 95, 255) },
Blue = { Color3.fromRGB(70, 140, 255), Color3.fromRGB(130, 185, 255), Color3.fromRGB(40, 100, 230) },
Yellow = { Color3.fromRGB(255, 214, 60), Color3.fromRGB(255, 236, 140), Color3.fromRGB(230, 180, 20) },
Purple = { Color3.fromRGB(165, 95, 255), Color3.fromRGB(200, 150, 255), Color3.fromRGB(130, 60, 230) },
}
computeTheme = function()
local t = TONES[S.AccentTone] or TONES.Rainbow
Theme.Glass = Color3.fromRGB(6, 6, 10)
Theme.Sheen = Color3.fromRGB(20, 20, 40)
Theme.Card = Color3.fromRGB(10, 10, 16)
Theme.Elem = Color3.fromRGB(20, 20, 30)
Theme.Stroke = Color3.fromRGB(0, 0, 30)
Theme.Text = Color3.fromRGB(255, 255, 255)
Theme.Sub = Color3.fromRGB(190, 195, 225)
Theme.Outline = t[1]
Theme.AccentA = t[2]
Theme.AccentB = t[3]
end
computeTheme()

-- the old moving background, lightning and glass sheen are removed
pcall(function() Main:FindFirstChild("Storm"):Destroy() end)
pcall(function() Sheen:Destroy() end)
UI.paintStorm = function() end
UI.applyFx = function() end
MainStroke.Transparency = 1

-- the logo button: only the picture, no gold ring, glow, sparks or backing behind it
do
local body = UI.LogoBody
for _, d in ipairs(body:GetChildren()) do
if d:IsA("UIStroke") or d:IsA("UIGradient") then d:Destroy() end
end
body.BackgroundTransparency = 1
body:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
if body.BackgroundTransparency < 1 then body.BackgroundTransparency = 1 end
end)
pcall(function() LogoGlow:Destroy() end)
pcall(function() Spark1:Destroy() end)
pcall(function() Spark2:Destroy() end)
pcall(function() UI.LogoRoot.Size = UDim2.fromOffset(math.max(S.LogoSize, 56), math.max(S.LogoSize, 56)) end)
end

-- the artwork already draws the minimise and close buttons, the real ones sit invisibly on top of them
for _, b in ipairs({ CollapseBtn, CloseBtn }) do
for _, d in ipairs(b:GetChildren()) do
if d:IsA("UIStroke") or d:IsA("TextLabel") or d:IsA("UICorner") then d:Destroy() end
end
b.BackgroundTransparency = 1
b:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
if b.BackgroundTransparency < 1 then b.BackgroundTransparency = 1 end
end)
end
CollapseBtn.Position = UDim2.new(1, -40, 0.5, 0)
CloseBtn.Position = UDim2.new(1, -6, 0.5, 0)
pcall(function() HeadLine.Visible = false end)

local function restyle()
Rail.Position, Rail.Size = UDim2.fromScale(0.042, 0.385), UDim2.fromScale(0.205, 0.565)
for _, d in ipairs(Rail:GetChildren()) do
if d:IsA("TextButton") then d.Size = UDim2.new(1, 0, 0, 34) end
if d:IsA("UIPadding") then
d.PaddingLeft, d.PaddingRight, d.PaddingTop = UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 1)
end
if d:IsA("UIListLayout") then d.Padding = UDim.new(0, 4) end
end
for _, d in ipairs(Header:GetChildren()) do
if d:IsA("TextLabel") then
d.Text = "JHub V" .. VERSION:sub(2)
d.TextSize = 20
d.Position = UDim2.new(0, 14, 0.5, -11)
d.Size = UDim2.new(0, 200, 0, 22)
end
end
end
restyle()
local prevApply = UI.applyWindow
function UI.applyWindow(...)
local r = prevApply(...)
restyle()
return r
end

-- UI customizations that fit the new menu
for _, p in ipairs(UI.pages) do
if p.name == "UI" then
local old = { ["Glass look"] = true, ["Outline"] = true, ["Presets"] = true, ["Lightning"] = true, ["Moving background"] = true, ["Header logo"] = true }
for _, f in ipairs(p.frame:GetChildren()) do
if f:IsA("Frame") then
for _, d in ipairs(f:GetDescendants()) do
if d:IsA("TextLabel") and old[d.Text] then f:Destroy() break end
end
end
end
local c = UI.Card(p, "Colors")
UI.Dropdown(c, "Menu color", "AccentTone", { "Rainbow", "Blue", "Yellow", "Purple" }, function() UI.applyTheme() end)
UI.Slider(c, "Card darkness", "CardTrans", 0.1, 0.9, 0.01, 2, nil, function() UI.applyTheme() end)
c.frame.LayoutOrder = -1
c.frame.Size = UDim2.new(0.5, -4, 0, 0)
end
end
UI.applyTheme()
end
-- NATURAL REBOUND AND BALL MAGNET: runs like a player (normal speed, reaction time, jumps on time), no locking onto the ball
do
local Bot = JH.api.Bot
function Bot.reboundStep(me, r)
if not Feat.ballLoose() then
Bot.marker(nil)
Bot.rbT = nil
return false
end
local b = Feat.findBall()
if not b or not b.Parent then return false end
local now = tick()
local bd = flat(b.Position - me).Magnitude
if bd > S.ARRange then return false end
if not Bot.rbT then
Bot.rbT = now
Bot.rbDelay = (S.ARReact or 0.18) * (0.8 + math.random() * 0.5)
Bot.rbSway = { math.random() - 0.5, math.random() - 0.5 }
end
if now - Bot.rbT < Bot.rbDelay then return false end
local land, t = Bot.predictBall(b)
Bot.marker(land)
-- stand just inside the landing spot, between it and the hoop, so the ball comes down in front of you
local spot = land
local hoop = Bot.nearestHoop(land)
if hoop then
local toHoop = flat(hoop - land)
if toHoop.Magnitude > 3 then spot = land + toHoop.Unit * math.min(1.6, toHoop.Magnitude * 0.1) end
end
spot = spot + Vector3.new(Bot.rbSway[1] * 0.8, 0, Bot.rbSway[2] * 0.8)
local to = flat(spot - me)
local d = to.Magnitude
local speed = clamp(S.ARSpeed or 1, 0.5, 1.3)
if d > 1.3 then
Bot.move(to.Unit * math.min(1, d / 3), speed)
Bot.setSprint(d > 12 and t > 0.8)
else
Bot.stopMove()
Bot.faceAt(b.Position)
end
-- jump so the top of the jump meets the ball
if S.ARJump and t < 0.42 and bd < 6 and b.Position.Y > me.Y + 2 and now - Bot.jumpT > 0.9 then
Bot.jumpT = now
Bot.press("Space", 0.15, { "jump" })
end
-- a short reach only, like a long arm: it does nothing from far away or when the ball is high above you
if S.ARMagnet and bd <= math.min(S.ARMagRange or 4, 5) and b.Position.Y < me.Y + 7 and now - Bot.ballT > 0.5 then
Bot.ballT = now
pcall(Feat.getBall, true)
end
Bot.status = string.format("Rebound (%.1fs)", t)
return true
end

-- ball magnet: runs over in short quick steps instead of jumping straight onto the ball, and never reaches for a ball that is high above you
function Feat.getBall(force)
local r = Mover.body()
local b, dist = Feat.findBall()
if not r or not b then return false end
if b.Position.Y > r.Position.Y + 12 then return false end
if S.MagnetMode ~= "Go to the ball" then
if not Feat.hop(b) then return false end
else
task.spawn(function()
local t0 = tick()
while JH.Running and tick() - t0 < 0.45 do
local rr, bb = Mover.body(), Feat.findBall()
if not rr or not bb then return end
local d = Vector3.new(bb.Position.X - rr.Position.X, 0, bb.Position.Z - rr.Position.Z)
if d.Magnitude < 3 then return end
rr.CFrame = rr.CFrame + d.Unit * math.min(d.Magnitude - 2.5, 5)
Mover.sync(rr)
RunService.Heartbeat:Wait()
end
end)
end
log(string.format("Ball magnet: %s (%.0f studs away)", S.MagnetMode, dist or 0))
return true
end
local origMag = Feat.magnetStep
function Feat.magnetStep()
local now = tick()
if S.BallMagnet and now < (Feat.magnetNext or 0) then return end
local before = Feat.magnetT
origMag()
if Feat.magnetT ~= before then Feat.magnetNext = now + 0.3 + math.random() * 0.5 end
end
end
-- RAINBOW MENU: blue, yellow and purple on black, slowly cycling
do
local BLUE, YEL, PUR = Color3.fromRGB(70, 140, 255), Color3.fromRGB(255, 214, 60), Color3.fromRGB(165, 95, 255)
local cyc = { BLUE, YEL, PUR }
local function cycColor(t)
local i = math.floor(t / 2.6) % #cyc + 1
local j = i % #cyc + 1
local k = ((t % 2.6) - 2.1) / 0.5
if k <= 0 then return cyc[i] end
k = k * k * (3 - 2 * k)
return cyc[i]:Lerp(cyc[j], k)
end
local origPaint = UI.paintGrad
function UI.paintGrad(g)
if S.AccentTone == "Rainbow" then
g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, BLUE), ColorSequenceKeypoint.new(0.5, PUR), ColorSequenceKeypoint.new(1, YEL) })
else
origPaint(g)
end
end
task.spawn(function()
while JH.Running do
task.wait(0.12)
if S.AccentTone == "Rainbow" and Window.Visible then
local t = tick()
local c = cycColor(t)
Theme.AccentA, Theme.AccentB, Theme.Outline = c:Lerp(Color3.new(1, 1, 1), 0.3), c, c
for _, it in ipairs(UI.themed) do
local key = it[3]
if (key == "AccentA" or key == "AccentB" or key == "Outline") and it[1].Parent then
pcall(function() it[1][it[2]] = Theme[key] end)
end
end
for _, g in ipairs(UI.grads) do
if g.Parent then g.Rotation = (t * 40) % 360 end
end
end
end
end)
UI.applyTheme()
end
-- TIMING SLIDERS IN THE MENU: fade and step back release later, ball magnet waits a moment before it grabs
do
local POSTFADE = { ["111074210919383"] = true, ["71484695722621"] = true, ["77401448272074"] = true, ["128777513307709+77401448272074"] = true }
local prevHold = Shot.remoteHold
function Shot.remoteHold(key, pk)
local hold, base, mode = prevHold(key, pk)
Shot.lastNudge = nil
local n = (S.FadeNudge or 0) / 1000
if n ~= 0 and hold then
local fade = POSTFADE[key] == true
local moving = Shot.situation() ~= "stand"
if mode == "peak" and (fade or moving) then
Shot.lastNudge = n
hold = clamp(hold - n, 0, 0.1)
elseif mode ~= "peak" and fade then
hold = hold + n
end
end
return hold, base, mode
end
-- the learner is told the timing it chose itself, so the slider is not learned twice
local prevLearn = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if info and info.lead and Shot.lastNudge then info.lead = info.lead + Shot.lastNudge end
return prevLearn(info, res, strength)
end
local innerGet = Feat.getBall
function Feat.getBall(force)
local d = (S.MagnetDelay or 0) / 1000
if d <= 0 then return innerGet(force) end
task.delay(d * (0.8 + math.random() * 0.4), function()
if JH.Running then pcall(innerGet, force) end
end)
return true
end
end
-- INSTANT GREEN: the release is timed with a wait that does not depend on frames, from the meter start and the shared meter speed
do
local prevLook = Shot.lookAhead
function Shot.lookAhead()
if S.InstantGreen then
local dt = 1 / math.max(JH.FPS or 60, 1)
return clamp(1.3 * dt, 0.03, 0.6)
end
return prevLook()
end
local prevFps = Shot.fpsComp
function Shot.fpsComp()
if S.InstantGreen then return 0 end
return prevFps()
end
local prevSmart = Shot.peakFitSmart
function Shot.peakFitSmart(samples, key)
local tp = prevSmart(samples, key)
if tp or not S.InstantGreen then return tp end
-- too few meter readings (a very low frame rate): start from when the meter started
local g = (Shot.gslope and Shot.gslope()) or 2.68
return Shot.meterT + Shot.PEAK_Q / g
end
-- built in shots were tuned at a normal ping: a higher ping lets go that much earlier
local prevHold = Shot.remoteHold
function Shot.remoteHold(key, pk)
local hold, base, mode = prevHold(key, pk)
if S.InstantGreen and mode ~= "peak" and Shot.FINAL[key] and hold then
local extra = clamp((Shot.effPing and Shot.effPing() or 0) - 0.035, 0, 0.5)
if extra > 0 then hold = math.max(Shot.FLOOR, hold - extra) end
end
return hold, base, mode
end
end
-- GLIDES STAY OUT OF THE SHOT: nothing pushes you while the shoot button is held, and the shot glide waits until the release has gone out
do
local baseShoot = Shot.onShootCall
function Shot.onShootCall(args)
local d = args[1]
if S.GlideShotSafe and type(d) == "table" then
if d.Shoot == true then
Mover.shotDownT = tick()
pcall(Glide.cancel)
elseif d.Shoot == false then
Mover.shotUpT = tick()
end
end
return baseShoot(args)
end
local function holding()
return (Mover.shotDownT or 0) > (Mover.shotUpT or 0)
end
local baseFire = Glide.fire
function Glide.fire(kind, why, dir)
if S.GlideShotSafe then
local now = tick()
local c = char()
local act = c and c:GetAttribute("Action")
if kind ~= "shot" and (holding() or now - (Mover.shotUpT or 0) < 0.35 or act == "Shooting") then return end
if kind == "shot" and now - (Mover.shotUpT or 0) < 0.12 then
task.delay(0.12, function() if JH.Running then pcall(baseFire, kind, why, dir) end end)
return
end
end
return baseFire(kind, why, dir)
end
-- the speed boost also waits while the shoot button is held
local baseStep = Speed.step
function Speed.step(dt)
if S.GlideShotSafe and holding() then return end
return baseStep(dt)
end
end
-- SHOT LAB: records every shot you take with everything around it, gives live feedback, lists the game's shot animations, and copies a report
do
local Lab = { rows = {}, stats = {} }
Shot.lab = Lab
local WORDS = { "shot", "shoot", "jump", "fade", "step", "layup", "dunk", "hook", "post", "spin", "float", "finger", "gather", "euro", "hop" }
local function idxOf(info, res, strength)
return info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
end
function Lab.add(info, res, strength)
local idx = idxOf(info, res, strength)
local key = tostring(info.key or "?")
local ch = char()
local anim = ch and ch:GetAttribute("BaseAnimation") or nil
local mode = Shot.FINAL[key] and "built-in" or (info.lead and "learned" or "fixed")
local row = {
t = os.date("%H:%M:%S"), key = key, name = Shot.nameFor(key, anim), mode = mode,
held = info.held or 0, lead = info.lead, verdict = (idx and Shot.VERDICT[idx]) or tostring(res or "?"), idx = idx,
ping = math.floor((Shot.pingNow and Shot.pingNow() or 0) * 1000 + 0.5), fps = math.floor((JH.FPS or 0) + 0.5),
sit = Shot.situation(), manual = info.manual == true, nudge = Shot.lastNudge,
}
Lab.rows[#Lab.rows + 1] = row
if #Lab.rows > 400 then table.remove(Lab.rows, 1) end
local s = Lab.stats[key]
if not s then
s = { name = row.name, mode = mode, n = 0, perfect = 0, good = 0, early = 0, late = 0, offSum = 0, heldSum = 0 }
Lab.stats[key] = s
end
s.n = s.n + 1
s.heldSum = s.heldSum + row.held
if idx then
if idx == 5 then s.perfect = s.perfect + 1
elseif idx == 4 then s.good = s.good + 1
elseif idx < 4 then s.early = s.early + 1
else s.late = s.late + 1 end
s.offSum = s.offSum + ((idx == 4) and -1 or (idx - 5))
end
if Lab.stat then
local tip = ""
local mean = s.n > 0 and s.offSum / s.n or 0
if s.n >= 3 and mean < -0.5 then tip = "  (keeps releasing early)" elseif s.n >= 3 and mean > 0.5 then tip = "  (keeps releasing late)" end
Lab.stat.Text = string.format("%s: %s  |  %d ms  %d FPS%s", row.name, row.verdict, row.ping, row.fps, tip)
end
if Lab.count then Lab.count.Text = tostring(#Lab.rows) .. " shots" end
end
function Lab.animations()
local out, n = {}, 0
for _, d in ipairs(game:GetDescendants()) do
if d:IsA("Animation") and tostring(d.AnimationId) ~= "" then
local nm = string.lower(d.Name)
for _, w in ipairs(WORDS) do
if string.find(nm, w, 1, true) then
out[#out + 1] = d.Name .. " = " .. string.gsub(tostring(d.AnimationId), "rbxassetid://", "") .. "  (" .. d.Parent.Name .. ")"
n = n + 1
break
end
end
end
if n >= 500 then break end
end
table.sort(out)
return out
end
function Lab.report()
local lines = { "== JHub Shot Lab report ==", "version " .. tostring(VERSION) .. " | place " .. tostring(game.PlaceId) .. " | " .. tostring(JH.execName) .. " | " .. os.date("%Y-%m-%d %H:%M:%S") }
local keep = { "LagSync", "InstantGreen", "AutoAdaptAll", "FadeNudge", "AdaptPlus", "PrecFit", "GreenMax", "AutoCal", "AutoCalibrate", "CalSpeed", "PeakBin", "GlideShotSafe", "ShotGlideWhen", "ShotGlideMethod", "Sweep" }
local st = {}
for _, k in ipairs(keep) do st[#st + 1] = k .. "=" .. tostring(S[k]) end
lines[#lines + 1] = "settings: " .. table.concat(st, " ")
lines[#lines + 1] = ""
lines[#lines + 1] = "-- per shot type: name | key | mode | shots | perfect good early late | average miss (-early +late) | advice --"
local keys = {}
for k in pairs(Lab.stats) do keys[#keys + 1] = k end
table.sort(keys)
for _, k in ipairs(keys) do
local s = Lab.stats[k]
local mean = s.n > 0 and s.offSum / s.n or 0
local advice = "fine"
if s.n >= 3 and mean < -0.4 then advice = string.format("release about %.0f ms later", math.abs(mean) * 14)
elseif s.n >= 3 and mean > 0.4 then advice = string.format("release about %.0f ms earlier", math.abs(mean) * 14)
elseif s.n < 3 then advice = "need more shots" end
lines[#lines + 1] = string.format("%s | %s | %s | %d | %d %d %d %d | %+.2f | %s", s.name, k, s.mode, s.n, s.perfect, s.good, s.early, s.late, mean, advice)
end
lines[#lines + 1] = ""
lines[#lines + 1] = "-- last shots: time | name | key | mode | held | lead | result | ping ms | FPS | move | manual --"
local from = math.max(1, #Lab.rows - 120)
for i = from, #Lab.rows do
local r = Lab.rows[i]
lines[#lines + 1] = string.format("%s | %s | %s | %s | %.3f | %s | %s | %d | %d | %s | %s", r.t, r.name, r.key, r.mode, r.held, r.lead and string.format("%.3f", r.lead) or "-", r.verdict, r.ping, r.fps, r.sit, tostring(r.manual))
end
return table.concat(lines, "\n")
end
local function copy(text, what)
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Shot Lab", what .. " copied", 3)
else
notify("Shot Lab", "This executor cannot copy to the clipboard", 4)
end
end
local mainPage
for _, p in ipairs(UI.pages) do
if p.name == "Main" then mainPage = p end
end
if mainPage then
local c = UI.Card(mainPage, "Shot Lab")
UI.Toggle(c, "Record every shot", "LabOn")
Lab.stat = UI.Stat(c, "Last shot")
Lab.count = UI.Stat(c, "Recorded")
UI.Buttons(c, {
{ "Copy shot report", function() copy(Lab.report(), "Shot report") end },
{ "Copy game shot animations", function() copy("== game shot animations ==\n" .. table.concat(Lab.animations(), "\n"), "Animation list") end },
})
UI.Button(c, "Clear recorded shots", function()
Lab.rows, Lab.stats = {}, {}
if Lab.count then Lab.count.Text = "0 shots" end
end)
UI.Note(c, "Shoot normally. After a few shots of each move, copy the report and send it. The animation list names the game's own shot animations.")
end
local prevLR = Shot.learnRemote
function Shot.learnRemote(info, res, strength)
if S.LabOn and info then pcall(Lab.add, info, res, strength) end
return prevLR(info, res, strength)
end
end
-- SHOT INTELLIGENCE: a live readout of the per-animation timing profile system (Shot.auto/Shot.FINAL), keyed automatically
-- by whichever jumpshot animation is actually equipped - switching jumpshots switches profiles with no setup needed
do
local mainPage
for _, p in ipairs(UI.pages) do if p.name == "Main" then mainPage = p end end
if mainPage then
local c = UI.Card(mainPage, "Shot Intelligence")
local sName = UI.Stat(c, "Detected jumpshot")
local sId = UI.Stat(c, "Animation ID")
local sStatus = UI.Stat(c, "Calibration status")
local sConf = UI.Stat(c, "Confidence")
local sHold = UI.Stat(c, "Active timing")
local sSeen = UI.Stat(c, "Recognized before")
local sTimes = UI.Stat(c, "Times seen")
local sSit = UI.Stat(c, "Situations seen")
local sRetest = UI.Stat(c, "Needs retest")
local sKnown = UI.Stat(c, "Known profiles")
UI.Button(c, "Copy every known shot profile", function()
local lines = { "== JHub shot intelligence profiles ==" }
local seen = {}
local db = (JH.ShotIntel and JH.ShotIntel.DB) or {}
for key in pairs(Shot.FINAL) do
seen[key] = true
local rec = db[key]
lines[#lines + 1] = string.format("%s | %s | built-in, confirmed | hold %.3fs | seen %dx%s", Shot.nameFor(key), key, Shot.FINAL[key],
rec and rec.timesSeen or 0, (rec and rec.needsRetest) and " | NEEDS RETEST" or "")
end
for key, a in pairs(Shot.auto or {}) do
if not seen[key] then
local rec = db[key]
lines[#lines + 1] = string.format("%s | %s | %s | %d samples | hold %.3fs | seen %dx%s", Shot.nameFor(key), key,
a.locked and "locked" or "learning", a.n or 0, a.hold or 0, rec and rec.timesSeen or 0,
(rec and rec.needsRetest) and " | NEEDS RETEST" or (rec and not rec.identified) and " | unidentified animation" or "")
end
end
copy(table.concat(lines, "\n"), "Shot profiles")
end)
UI.Note(c, "Each jumpshot animation gets its own timing profile automatically - switching jumpshots switches profiles, no setup needed. A profile needs enough consistent real shots before it is trusted (locked); until then it is still learning. If a locked profile starts missing consistently, it is automatically unlocked and flagged to retest instead of staying trusted forever.")
task.spawn(function()
while true do
local cur = Shot.cur
local db = (JH.ShotIntel and JH.ShotIntel.DB) or {}
if cur and cur.key then
local key = cur.key
local a = Shot.auto and Shot.auto[key]
local rec = db[key]
sName.Text = Shot.nameFor(key, cur.anim)
sId.Text = string.sub(tostring(key), 1, 22)
sStatus.Text = cur.state or "-"
if Shot.FINAL[key] then
sConf.Text = "Built-in (confirmed)"
elseif a then
sConf.Text = string.format("%d samples%s", a.n or 0, a.locked and ", locked" or ", learning")
else
sConf.Text = "No data yet"
end
sHold.Text = string.format("%.3fs", cur.hold or 0)
sSeen.Text = rec and "Yes" or "No"
sTimes.Text = rec and tostring(rec.timesSeen or 0) or "0"
if rec and rec.sits and next(rec.sits) then
local parts = {}
for sitName, cnt in pairs(rec.sits) do parts[#parts + 1] = sitName .. " x" .. cnt end
table.sort(parts)
sSit.Text = table.concat(parts, ", ")
else
sSit.Text = "-"
end
sRetest.Text = (rec and rec.needsRetest) and "Yes - flagged" or "No"
if rec and not rec.identified then sStatus.Text = "Unidentified animation" end
else
sName.Text, sId.Text, sStatus.Text, sConf.Text, sHold.Text = "-", "-", "Shoot to see it", "-", "-"
sSeen.Text, sTimes.Text, sSit.Text, sRetest.Text = "-", "-", "-", "-"
end
local known = 0
for _ in pairs(Shot.FINAL) do known = known + 1 end
for _ in pairs(Shot.auto or {}) do known = known + 1 end
sKnown.Text = tostring(known)
task.wait(1)
end
end)
end
end
-- LOGO LETTERS: the menu title and the top bar use a brush marker font with a black outline and the blue, yellow and purple colors
do
local FONT = Enum.Font.PermanentMarker
local function style()
for _, d in ipairs(Header:GetChildren()) do
if d:IsA("TextLabel") then
d.Font = FONT
d.TextSize = 28
d.TextColor3 = Color3.new(1, 1, 1)
d.TextStrokeColor3 = Color3.new(0, 0, 0)
d.TextStrokeTransparency = 0.05
d.Size = UDim2.new(0, 280, 0, 30)
d.Position = UDim2.new(0, 14, 0.5, -15)
if not d:FindFirstChildOfClass("UIGradient") then UI.grad(d) end
end
end
end
pcall(style)
local prevApply = UI.applyWindow
function UI.applyWindow(...)
local r = prevApply(...)
pcall(style)
return r
end
end
-- SHOT NAMES FROM THE GAME'S OWN ANIMATION LIST, AND TIMING SHARED INSIDE EACH SHOT FAMILY
do
local IDNAME = {
["123897568594090"] = "Backstep1L",
["127422207069035"] = "Backstep1R",
["16145346328"] = "CloseFade1L",
["16145343052"] = "CloseFade1R",
["16143619816"] = "CloseShot1L",
["16143612725"] = "CloseShot1R",
["122465444344495"] = "ClutchShot1R",
["105859087082844"] = "ClutchShot2R",
["104766830277346"] = "Escape Retreat StepBack 1 L",
["101763948381427"] = "Escape Retreat StepBack 1 R",
["18490241160"] = "Eurostep1L",
["18490760705"] = "Eurostep1R",
["111704738351151"] = "Eurostep2L",
["94525958298824"] = "Eurostep2R",
["16247513358"] = "FadeAway1L",
["16104888271"] = "FadeAway1R",
["72457151419535"] = "FadeOffSpin",
["73312396340408"] = "Floater1L",
["18479327091"] = "Floater1R",
["83560375675042"] = "Floater2L",
["110801085144110"] = "Floater2R",
["72125557808800"] = "Floater3L",
["101591116880216"] = "Floater3R",
["121266237142174"] = "Floater4L",
["76935911753836"] = "Floater4R",
["129529685206875"] = "HalfSpin 1 L",
["116377271778907"] = "HalfSpin 1 R",
["18562916903"] = "Hopstep1L",
["18564813109"] = "Hopstep1R",
["74708121013638"] = "Jumpshot10LBase",
["89043189007783"] = "Jumpshot10LRelease",
["93718423729481"] = "Jumpshot10RBase",
["106368953335940"] = "Jumpshot10RRelease",
["98057390970111"] = "Jumpshot11LBase",
["139180517555346"] = "Jumpshot11LRelease",
["108219916586130"] = "Jumpshot11RBase",
["122616867439575"] = "Jumpshot11RRelease",
["133292215102254"] = "Jumpshot12LBase",
["109188880516100"] = "Jumpshot12LRelease",
["85618824455884"] = "Jumpshot12RBase",
["108356101205697"] = "Jumpshot12RRelease",
["126439912802076"] = "Jumpshot13LBase",
["122548714712371"] = "Jumpshot13LRelease",
["92872377351550"] = "Jumpshot13RBase",
["140052980856457"] = "Jumpshot13RRelease",
["114941990966676"] = "Jumpshot14LBase",
["108579262151957"] = "Jumpshot14LRelease",
["81957659045162"] = "Jumpshot14RBase",
["90495832697285"] = "Jumpshot14RRelease",
["74979847696031"] = "Jumpshot15LBase",
["110632271666784"] = "Jumpshot15LRelease",
["84540244428238"] = "Jumpshot15RBase",
["71664326786621"] = "Jumpshot15RRelease",
["109811332443306"] = "Jumpshot16LBase",
["132558433850380"] = "Jumpshot16LRelease",
["71026149999012"] = "Jumpshot16RBase",
["118631494115522"] = "Jumpshot16RRelease",
["15852002207"] = "Jumpshot1LBase",
["15852004111"] = "Jumpshot1LRelease",
["15851912457"] = "Jumpshot1RBase",
["15851919155"] = "Jumpshot1RRelease",
["105701400634134"] = "Jumpshot2LBase",
["109450934633536"] = "Jumpshot2LRelease",
["72456843565147"] = "Jumpshot2RBase",
["84289633045544"] = "Jumpshot2RRelease",
["127398785869633"] = "Jumpshot3LBase",
["112156144070038"] = "Jumpshot3LRelease",
["103840440800065"] = "Jumpshot3RBase",
["121374781838539"] = "Jumpshot3RRelease",
["93579833800410"] = "Jumpshot4LBase",
["118445199489350"] = "Jumpshot4LRelease",
["107267506258170"] = "Jumpshot4RBase",
["88476923576638"] = "Jumpshot4RRelease",
["98433629221242"] = "Jumpshot5LBase",
["136333410000989"] = "Jumpshot5LRelease",
["78687270972169"] = "Jumpshot5RBase",
["105872738506827"] = "Jumpshot5RRelease",
["87425338536981"] = "Jumpshot6LBase",
["119409927614003"] = "Jumpshot6LRelease",
["94901854704297"] = "Jumpshot6RBase",
["134827491525733"] = "Jumpshot6RRelease",
["129361186598012"] = "Jumpshot7LBase",
["136230260055859"] = "Jumpshot7LRelease",
["106983388593429"] = "Jumpshot7RBase",
["84934876114141"] = "Jumpshot7RRelease",
["140548746406756"] = "Jumpshot8LBase",
["101150492242995"] = "Jumpshot8LRelease",
["130802304867577"] = "Jumpshot8RBase",
["95617155918948"] = "Jumpshot8RRelease",
["135680344718842"] = "Jumpshot9LBase",
["121465657586926"] = "Jumpshot9LRelease",
["94696336118150"] = "Jumpshot9RBase",
["79176486779613"] = "Jumpshot9RRelease",
["96144129758396"] = "JumpshotSmothered1L",
["86178912276158"] = "JumpshotSmothered1R",
["16247060979"] = "MovingShotLeft1L",
["16205020756"] = "MovingShotLeft1R",
["16247080711"] = "MovingShotRight1L",
["16246923753"] = "MovingShotRight1R",
["118903578746477"] = "PostFadeLeft1L",
["89959998001439"] = "PostFadeLeft1R",
["90675102495015"] = "PostFadeRight1L",
["128777513307709"] = "PostFadeRight1R",
["94918503601868"] = "PostHookLeft1L",
["139165512882286"] = "PostHookRight1R",
["71484695722621"] = "PostSpinGather1L",
["77401448272074"] = "PostSpinGather1R",
["18507584241"] = "SpinGather1L",
["18507570562"] = "SpinGather1R",
["95688876134046"] = "SpinHookLeft1L",
["104966197366795"] = "SpinHookRight1R",
["91053585299044"] = "StepBack 1 L",
["100829976540057"] = "StepBack 1 R",
["76796993769486"] = "StepBack 2 L",
["94150114804496"] = "StepBack 2 R",
["119260785892440"] = "StepPostFade1L",
["111074210919383"] = "StepPostFade1R",
["95782467897683"] = "UnderRimCloseShot1L",
["107778200710432"] = "UnderRimCloseShot1R",
}
Shot.idName = IDNAME
local function nameOfId(id) return IDNAME[tostring(id)] end
local prevName = Shot.nameFor
function Shot.nameFor(key, anim)
local n = Shot.keyName[key] or Shot.NAMES[key]
if n then return n end
local parts, any = {}, false
for id in string.gmatch(tostring(key), "%d+") do
local nm = nameOfId(id)
if nm then any = true end
parts[#parts + 1] = nm or id
end
if any then return table.concat(parts, " + ") end
return prevName(key, anim)
end
-- a shot family: every jumpshot, every fade, every step back and so on
local FAMILIES = {
{ "postfade", { "PostFade", "StepPostFade", "PostSpinGather" } },
{ "stepback", { "StepBack", "Backstep", "Retreat" } },
{ "fade", { "FadeAway", "CloseFade", "FadeOffSpin" } },
{ "moving", { "MovingShot" } },
{ "close", { "CloseShot", "UnderRim" } },
{ "floater", { "Floater" } },
{ "hook", { "Hook" } },
{ "jumpshot", { "Jumpshot" } },
}
function Shot.familyOf(key)
for id in string.gmatch(tostring(key), "%d+") do
local nm = nameOfId(id)
if nm then
for _, fam in ipairs(FAMILIES) do
for _, pat in ipairs(fam[2]) do
if string.find(nm, pat, 1, true) then return fam[1] end
end
end
end
end
return nil
end
local function readFam()
local t = {}
for fam, v, n in string.gmatch(S.FamLead or "", "(%a+)=([%d%.]+):(%d+)") do t[fam] = { tonumber(v), tonumber(n) } end
return t
end
local function writeFam(t)
local parts = {}
for fam, d in pairs(t) do parts[#parts + 1] = string.format("%s=%.4f:%d", fam, d[1], d[2]) end
table.sort(parts)
S.FamLead = table.concat(parts, " ")
saveSoon()
end
local prevSeed = Shot.seedLead
function Shot.seedLead(key)
local fam = Shot.familyOf(key)
if fam and S.AutoAdaptAll then
local d = readFam()[fam]
if d and d[2] >= 2 then return clamp(d[1], 0, 0.1) end
end
return prevSeed(key)
end
local prevLearn = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if S.AutoAdaptAll and info and info.lead and not info.manual and not Shot.FINAL[info.key] then
local fam = Shot.familyOf(info.key)
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if fam and idx then
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
if math.abs(off) <= 3 then
local t = readFam()
local d = t[fam] or { 0, 0 }
local est = clamp(info.lead + off * (S.PeakBin or 0.014) * 0.8, 0, 0.1)
if d[2] < 2 then d[1] = est else d[1] = d[1] * 0.8 + est * 0.2 end
d[2] = math.min(d[2] + 1, 999)
t[fam] = d
writeFam(t)
end
end
end
return prevLearn(info, res, strength)
end
end
-- LOCKED TAB: its own tab, locked with a code; the recorders, the scanner and the Shot Lab (and later auto play) live inside it
do
local CODE = "6022"
local mainPage
for _, p in ipairs(UI.pages) do
if p.name == "Main" then mainPage = p end
end
if mainPage then
local TITLES = { ["Game recorder"] = true, ["Shot recorder"] = true, ["Game scanner"] = true, ["Shot Lab"] = true }
local tools = {}
for _, f in ipairs(mainPage.frame:GetChildren()) do
if f:IsA("Frame") then
for _, d in ipairs(f:GetDescendants()) do
if d:IsA("TextLabel") and TITLES[d.Text] then
f.Visible = false
tools[#tools + 1] = f
break
end
end
end
end
local LP = UI.Page("Locked", "L")
UI.lockedPage = LP
UI.lockedTools = tools
local lay = LP.frame:FindFirstChildOfClass("UIListLayout")
if lay then
lay.FillDirection = Enum.FillDirection.Horizontal
lay.Wraps = true
lay.Padding = UDim.new(0, 8)
end
local typed = ""
local lock = UI.Card(LP, "Locked")
lock.frame.Size = UDim2.new(0.5, -4, 0, 0)
UI.Input(lock, "Code", { get = function() return typed end, set = function(v) typed = tostring(v or "") end }, nil, "enter the code")
local function unlockLocked()
for i, f in ipairs(tools) do
f.Parent = LP.frame
f.LayoutOrder = i + 1
f.Size = UDim2.new(0.5, -4, 0, 0)
f.Visible = true
end
lock.frame.Visible = false
end
if S.LockedUnlocked then task.defer(unlockLocked) end
UI.Button(lock, "Unlock", function()
if string.gsub(typed, "%s", "") == CODE then
unlockLocked()
S.LockedUnlocked = true
saveSoon()
notify("Locked tab", "Unlocked", 3)
else
notify("Locked tab", "Wrong code", 3)
end
end, true)
UI.Note(lock, "Everything in this tab is locked. Enter the code to open it.")
end
end
-- OWNER TAB: locked with its own code, sets who gets a crown/dev/mod badge in JHub Chat for everyone
do
local CODE2 = "2011"
local mainPage
for _, p in ipairs(UI.pages) do if p.name == "Main" then mainPage = p end end
if mainPage then
local OP = UI.Page("Owner", "O")
local typed2 = ""
local lock2 = UI.Card(OP, "Owner")
UI.Input(lock2, "Code", { get = function() return typed2 end, set = function(v) typed2 = tostring(v or "") end }, nil, "enter the code")
local rolesCard = UI.Card(OP, "Chat roles")
rolesCard.frame.Visible = false
local existing = JH.roles or {}
local ownerName, devNames, mod1Name, mod2Name, ownerCode = tostring(existing.owner or ""), tostring(existing.devs or ""), tostring(existing.mod1 or ""), tostring(existing.mod2 or ""), ""
UI.Input(rolesCard, "Owner name (gold text, crown, #owner)", { get = function() return ownerName end, set = function(v) ownerName = tostring(v or "") end }, nil, "owner's player name")
UI.Input(rolesCard, "Owner code (only needed to set/change the Owner)", { get = function() return ownerCode end, set = function(v) ownerCode = tostring(v or "") end }, nil, "required to change the Owner")
UI.Input(rolesCard, "Devs (comma separated player names)", { get = function() return devNames end, set = function(v) devNames = tostring(v or "") end }, nil, "name1, name2")
UI.Input(rolesCard, "Mod 1 name", { get = function() return mod1Name end, set = function(v) mod1Name = tostring(v or "") end }, nil, "player name")
UI.Input(rolesCard, "Mod 2 name", { get = function() return mod2Name end, set = function(v) mod2Name = tostring(v or "") end }, nil, "player name")
UI.Button(rolesCard, "Save and push to everyone", function()
local cur = JH.roles or {}
local newOwner = cur.owner or ""
if ownerName ~= (cur.owner or "") then
if string.lower(string.gsub(ownerCode, "%s", "")) == "jay" then
newOwner = ownerName
else
notify("Owner tab", "Wrong owner code - the Owner was not changed. Devs/mods still saved.", 4)
end
else
newOwner = ownerName
end
ownerName, ownerCode = newOwner, ""
local roles = { owner = newOwner, devs = devNames, mod1 = mod1Name, mod2 = mod2Name, t = os.time() }
JH.roles = roles
if JH.netPut then task.spawn(JH.netPut, "roles", roles) end
notify("Owner tab", "Roles saved and pushed - everyone's JHub Chat will show the badges.", 4)
end, true)
UI.Note(rolesCard, "Whoever is named here gets a badge next to their name in JHub Chat for everyone: the owner gets a gold crown and #owner, devs/mods get their own tag. Once set, a role stays until changed - changing the Owner needs the Owner code, not just the tab code.")
if S.OwnerUnlocked then
task.defer(function()
lock2.frame.Visible = false
rolesCard.frame.Visible = true
end)
end
UI.Button(lock2, "Unlock", function()
if string.gsub(typed2, "%s", "") == CODE2 then
lock2.frame.Visible = false
rolesCard.frame.Visible = true
S.OwnerUnlocked = true
saveSoon()
notify("Owner tab", "Unlocked", 3)
else
notify("Owner tab", "Wrong code", 3)
end
end, true)
UI.Note(lock2, "Owner-only tab. Enter the code to manage chat crown/dev/mod badges.")
end
end
-- MINIMISED BAR: the artwork draws the minimise and close buttons, so when the artwork is hidden the buttons are drawn on the bar itself
do
local YEL = Color3.fromRGB(255, 214, 60)
local function setup(b, text)
local l = b:FindFirstChild("JHMark")
if l then return l, b:FindFirstChild("JHMarkStroke") end
l = Instance.new("TextLabel")
l.Name = "JHMark"
l.BackgroundTransparency = 1
l.Size = UDim2.fromScale(1, 1)
l.Font = Enum.Font.GothamBold
l.TextSize = 20
l.Text = text
l.TextColor3 = YEL
l.Visible = false
l.Parent = b
local st = Instance.new("UIStroke")
st.Name = "JHMarkStroke"
st.Color = YEL
st.Thickness = 1.5
st.Enabled = false
st.Parent = b
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 8)
c.Parent = b
return l, st
end
local la, sa = setup(CollapseBtn, "-")
local lb, sb = setup(CloseBtn, "X")
local function show(on)
la.Visible, lb.Visible = on, on
sa.Enabled, sb.Enabled = on, on
end
CollapseBtn.Activated:Connect(function()
task.wait(0.06)
show(collapsed == true)
end)
show(false)
end
-- SMART STEPS FOR AUTO CALIBRATE: bigger steps on the first result and when the misses keep going the same way, small steps when it bounces, and almost none for a lag spike
do
local hist = {}
function Shot.adaptGain(key, off)
if not S.SmartSteps then return 1 end
local h = hist[key]
if not h then
h = {}
hist[key] = h
end
local n = #h
local last, prev = h[n], h[n - 1]
local gain = 1
if n == 0 then
gain = 1.5
elseif n >= 2 and math.abs(off) >= 3 and math.abs(last) <= 1 and math.abs(prev) <= 1 then
gain = 0.3
elseif last * off < 0 and math.abs(last) >= 0.5 and math.abs(off) >= 0.5 then
gain = 0.6
elseif last * off > 0 and math.abs(last) >= 0.5 and math.abs(off) >= 0.5 then
gain = 1.4
end
if (Shot.lastShotEx or 0) >= 0.03 then gain = math.min(gain, 0.3) end
h[#h + 1] = off
if #h > 6 then table.remove(h, 1) end
return gain
end
local prevLearn = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
local a = Shot.auto and info and Shot.auto[info.key]
local before = a and a.hold
local r = prevLearn(info, res, strength)
if S.SmartSteps and a and before and a.mode == "peak" and not info.manual and not Shot.FINAL[info.key] then
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx then
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
local gain = Shot.adaptGain(info.key, off)
local after = a.hold
if after ~= before and gain ~= 1 then
a.hold = clamp(before + (after - before) * gain, 0, 0.1)
Shot.autoSave()
end
end
end
return r
end
end
-- ULTRA GAME RECORDER: one switch that records everything (game recorder, shot recorder, shot lab) plus every player, animation, input, control and setting
do
local Ultra = { on = false, conns = {}, seenAnim = setmetatable({}, { __mode = "k" }), last = {} }
Shot.ultra = Ultra
local CAS = game:GetService("ContextActionService")
local ATTRS = { "Action", "BaseAnimation", "GatherType", "LastDribblePackage", "Stamina", "ServerVelocity", "CanMove", "meterOffset" }
local function charOfPlayer(pl)
return pl.Character or (workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(pl.Name))
end
local function hasBall(c)
local af = c and c:FindFirstChild("Attributes")
local bv = af and af:FindFirstChild("Basketball")
return (bv and bv.Value ~= nil) and true or false
end
local function watchAnimator(pl, c)
local h = c and c:FindFirstChildOfClass("Humanoid")
local a = h and (h:FindFirstChildOfClass("Animator") or c:FindFirstChildWhichIsA("Animator", true))
if not a or Ultra.seenAnim[a] then return end
Ultra.seenAnim[a] = true
Ultra.conns[#Ultra.conns + 1] = a.AnimationPlayed:Connect(function(tr)
local id = ""
pcall(function() id = string.gsub(tostring(tr.Animation.AnimationId), "rbxassetid://", "") end)
Rec.add("anim", string.format("%s%s %s id=%s len=%.2f prio=%s looped=%s", pl.Name, pl == LP and " (me)" or "", tostring(tr.Name), id, tr.Length or 0,
tostring(tr.Priority), tostring(tr.Looped)))
end)
end
local function dumpOnce()
-- controls the game has bound
pcall(function()
for name, info in pairs(CAS:GetAllBoundActionInfo()) do
local kinds = {}
for _, t in ipairs(info.inputTypes or {}) do kinds[#kinds + 1] = tostring(t) end
Rec.add("control", string.format("bound action %s priority=%s stack=%s inputs=%s", tostring(name), tostring(info.priority), tostring(info.stackOrder), table.concat(kinds, ",")))
end
end)
-- emotes and every shot or move animation the game ships
pcall(function()
local n = 0
for _, d in ipairs(game:GetDescendants()) do
if d:IsA("Animation") and tostring(d.AnimationId) ~= "" then
n = n + 1
Rec.add("anim-list", d:GetFullName() .. " = " .. string.gsub(tostring(d.AnimationId), "rbxassetid://", ""))
if n >= 700 then break end
end
end
end)
-- settings: values and attributes that look like game rules
pcall(function()
local n = 0
for _, d in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
if d:IsA("ValueBase") then
n = n + 1
Rec.add("setting", d:GetFullName() .. " = " .. tostring(d.Value))
if n >= 400 then break end
end
end
for k, v in pairs(LP:GetAttributes()) do Rec.add("setting", "player attribute " .. k .. " = " .. tostring(v)) end
for k, v in pairs(workspace:GetAttributes()) do Rec.add("setting", "workspace attribute " .. k .. " = " .. tostring(v)) end
for k, v in pairs(game:GetService("ReplicatedStorage"):GetAttributes()) do Rec.add("setting", "storage attribute " .. k .. " = " .. tostring(v)) end
end)
-- hoops and court
pcall(function()
local n = 0
for _, d in ipairs(workspace:GetDescendants()) do
if d:IsA("BasePart") then
local nm = string.lower(d.Name)
if string.find(nm, "hoop", 1, true) or string.find(nm, "rim", 1, true) or string.find(nm, "backboard", 1, true) or string.find(nm, "goal", 1, true) then
n = n + 1
Rec.add("court", string.format("%s at %.1f,%.1f,%.1f size %.1f,%.1f,%.1f", d:GetFullName(), d.Position.X, d.Position.Y, d.Position.Z, d.Size.X, d.Size.Y, d.Size.Z))
if n >= 40 then break end
end
end
end
end)
Rec.add("build", "walkspeed=" .. tostring(hum() and hum().WalkSpeed) .. " jump=" .. tostring(hum() and hum().JumpPower) .. " hipheight=" .. tostring(hum() and hum().HipHeight))
end
local function sample()
local me = hrp()
for _, pl in ipairs(Players:GetPlayers()) do
local c = charOfPlayer(pl)
local root = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
if root then
watchAnimator(pl, c)
local v = root.AssemblyLinearVelocity
local parts = {}
for _, k in ipairs(ATTRS) do
local val = c:GetAttribute(k)
if val ~= nil then parts[#parts + 1] = k .. "=" .. (type(val) == "number" and string.format("%.2f", val) or tostring(val)) end
end
local h = c:FindFirstChildOfClass("Humanoid")
local st = "?"
if h then pcall(function() st = tostring(h:GetState()) end) end
local line = string.format("%s%s team=%s pos=%.1f,%.1f,%.1f vel=%.1f,%.1f,%.1f ball=%s state=%s %s%s", pl.Name, pl == LP and " (me)" or "",
tostring(pl.Team and pl.Team.Name), root.Position.X, root.Position.Y, root.Position.Z, v.X, v.Y, v.Z, tostring(hasBall(c)), st,
table.concat(parts, " "), (me and pl ~= LP) and string.format(" dist=%.1f", (root.Position - me.Position).Magnitude) or "")
if Ultra.last[pl] ~= line or tick() - (Ultra.lastT and Ultra.lastT[pl] or 0) > 2 then
Ultra.last[pl] = line
Ultra.lastT = Ultra.lastT or {}
Ultra.lastT[pl] = tick()
Rec.add("player", line)
end
end
end
local b = Feat.findBall()
if b and b.Parent then
local v = b.AssemblyLinearVelocity
Rec.add("ballpos", string.format("pos=%.1f,%.1f,%.1f vel=%.1f,%.1f,%.1f loose=%s", b.Position.X, b.Position.Y, b.Position.Z, v.X, v.Y, v.Z, tostring(Feat.ballLoose())))
end
end
function Ultra.start()
if Ultra.on then return end
Ultra.on = true
if not Rec.on then Rec.start() end
pcall(Rec.shotStart)
S.LabOn = true
pcall(dumpOnce)
Ultra.conns[#Ultra.conns + 1] = UIS.InputBegan:Connect(function(i, gp)
Rec.add("input", string.format("began %s %s gui=%s", tostring(i.UserInputType), i.KeyCode ~= Enum.KeyCode.Unknown and tostring(i.KeyCode) or "", tostring(gp)))
end)
Ultra.conns[#Ultra.conns + 1] = UIS.InputEnded:Connect(function(i, gp)
Rec.add("input", string.format("ended %s %s", tostring(i.UserInputType), i.KeyCode ~= Enum.KeyCode.Unknown and tostring(i.KeyCode) or ""))
end)
task.spawn(function()
local n = 0
while Ultra.on and JH.Running do
pcall(sample)
n = n + 1
if n % 8 == 0 then Rec.add("perf", string.format("fps=%d ping=%d ms", math.floor((JH.FPS or 0) + 0.5), math.floor((Shot.pingNow and Shot.pingNow() or 0) * 1000 + 0.5))) end
task.wait(0.25)
end
end)
notify("Ultra recorder", "Recording everything", 3)
end
function Ultra.stop()
if not Ultra.on then return end
Ultra.on = false
for _, c in ipairs(Ultra.conns) do pcall(function() c:Disconnect() end) end
Ultra.conns = {}
pcall(Rec.shotStop)
pcall(Rec.stop)
end
function Ultra.report()
local parts = { Rec.text() }
if Shot.lab and Shot.lab.report then parts[#parts + 1] = "\n\n" .. Shot.lab.report() end
return table.concat(parts, "\n")
end
local mainPage
for _, p in ipairs(UI.pages) do
if p.name == "Main" then mainPage = p end
end
if mainPage and UI.lockedTools then
local c = UI.Card(mainPage, "Ultra Game Recorder")
UI.Toggle(c, "Record everything", "UltraOn", function(v) if v then Ultra.start() else Ultra.stop() end end)
UI.Note(c, "Play normally with it on: dribble, shoot, guard, steal, block, rebound, dunk, use every button once. It records every player, animation, button, setting, ball movement and shot.")
UI.Buttons(c, {
{ "Copy everything", function()
local text = Ultra.report()
pcall(function() if type(writefile) == "function" then writefile("JHub_ultra_report.txt", text) end end)
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Ultra recorder", "Copied and saved as JHub_ultra_report.txt", 4)
else
notify("Ultra recorder", "Saved as JHub_ultra_report.txt in your executor folder", 4)
end
end },
{ "Clear", function() pcall(Rec.clear) if Shot.lab then Shot.lab.rows, Shot.lab.stats = {}, {} end end },
})
c.frame.Visible = false
table.insert(UI.lockedTools, 1, c.frame)
end
S.UltraOn = false
end
-- REBOUND AND BALL MAGNET LEAVE YOU ALONE WHILE YOU MOVE, GUARD SPEED, SHOT CONTEST ABOVE YOUR HEAD, NO STUN ONLY IN FIGHT ANIMATIONS
do
local Bot = JH.api.Bot
local function stickActive()
local h, r = hum(), Mover.body()
if not h or not r then return false end
local ok, intent = pcall(Mover.intent, h, r)
return ok and intent ~= nil and intent.Magnitude > 0.15
end
Feat.heldT = 0
task.spawn(function()
while JH.Running do
task.wait(0.1)
if not Feat.ballLoose() then Feat.heldT = tick() end
end
end)
-- a real rebound or loose ball only: not a pass, a check up, or while you are the one moving the character
function Feat.grabOk(b)
local r = Mover.body()
if not r or not b then return false end
if tick() - Feat.heldT < 0.9 then return false end
local rebound = b.Position.Y > r.Position.Y + 5 or b.AssemblyLinearVelocity.Y < -8
if stickActive() and not rebound then return false end
return true
end
local prevGet = Feat.getBall
function Feat.getBall(force)
local b = Feat.findBall()
if not b or not Feat.grabOk(b) then return false end
return prevGet(force)
end
local prevReb = Bot.reboundStep
function Bot.reboundStep(me, r)
local b = Feat.findBall()
if b and not Feat.grabOk(b) then
Bot.marker(nil)
Bot.rbT = nil
return false
end
return prevReb(me, r)
end

-- guard speed: extra speed only while an opponent with the ball is close and you do not have it
function Feat.isGuarding()
if Ball.holding then return false end
local me = hrp()
if not me then return false end
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= LP and not (LP.Team and pl.Team == LP.Team) then
local c = pl.Character or (workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(pl.Name))
local af = c and c:FindFirstChild("Attributes")
local bv = af and af:FindFirstChild("Basketball")
local root = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
if bv and bv.Value ~= nil and root and (root.Position - me.Position).Magnitude < 16 then return true end
end
end
return false
end
local baseExtra = Speed.extraNow
function Speed.extraNow()
local e = baseExtra()
if (S.GuardSpeed or 0) > 0 and Feat.isGuarding() then e = e + (Speed.gameWS or 16) * S.GuardSpeed / 100 end
return e
end
local pp
for _, p in ipairs(UI.pages) do
if p.name == "Players" then pp = p end
end
if pp then
local g = UI.Card(pp, "Guard speed")
UI.Slider(g, "Extra speed while guarding", "GuardSpeed", 0, 60, 1, 0, "%")
UI.Button(g, "Reset guard speed", function() UI.set("GuardSpeed", 0) end)
UI.Note(g, "Only faster while you guard the player with the ball. Normal speed the rest of the time.")
end

-- no stun only inside bump, cross, steal, shot, layup and dunk animations (or while the game flags a stun)
local NS_WORDS = { "bump", "cross", "steal", "dunk", "layup", "shot", "shoot", "push", "stun", "stagger", "knock", "ragdoll", "fall" }
local baseNS = Bot.noStunStep
function Bot.noStunStep()
if not S.NoStun then return end
local c = char()
local active = false
if c then
for k, v in pairs(c:GetAttributes()) do
local low = string.lower(k)
if (string.find(low, "stun", 1, true) or string.find(low, "ragdoll", 1, true) or string.find(low, "stagger", 1, true)) and v then active = true break end
end
end
if not active then
local a = Anim.animator
local ok, list = pcall(function() return a and a:GetPlayingAnimationTracks() or {} end)
if ok then
for _, tr in ipairs(list) do
if Anim.has("StunIds", Anim.idOf(tr)) or matchAny(string.lower(Anim.name(tr) or ""), NS_WORDS) then active = true break end
end
end
end
if not active then return end
return baseNS()
end

-- live open/contested feedback while you have the ball, from the real distance to the nearest real defender - updates continuously as you move, instead of only scraping the game's own post-shot "Contested" label once you've already released
local bb, label, hl
task.spawn(function()
while JH.Running do
task.wait(0.1)
local show = S.ContestShow
local c = char()
local r = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
local okHB, hb = pcall(Feat.hasBall)
local hasBall = show and r and okHB and hb
if show and r and hasBall then
local nearest
local okO, others = pcall(Bot.others)
if okO and others then
for _, o in ipairs(others) do
if not o.mate then
local d = flat(o.pos - r.Position).Magnitude
if not nearest or d < nearest then nearest = d end
end
end
end
if nearest then
if not bb then
bb = Instance.new("BillboardGui")
bb.Name = "JHContest"
bb.Size = UDim2.fromOffset(170, 30)
bb.StudsOffset = Vector3.new(0, 4.2, 0)
bb.AlwaysOnTop = true
label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Size = UDim2.fromScale(1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 20
label.TextStrokeTransparency = 0.3
label.Parent = bb
pcall(function() bb.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
end
if not hl or not hl.Parent then
hl = Instance.new("Highlight")
hl.Name = "JHOpenness"
hl.FillTransparency = 0.65
hl.OutlineTransparency = 0
pcall(function() hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
end
bb.Adornee = c:FindFirstChild("Head") or r
bb.Enabled = true
hl.Parent = c
local word, col
if nearest >= 6 then
word, col = "OPEN", Color3.fromRGB(70, 235, 110)
elseif nearest >= 3.5 then
word, col = "SLIGHTLY OPEN", Color3.fromRGB(255, 225, 60)
else
word, col = "CONTESTED", Color3.fromRGB(255, 60, 60)
end
local pct = math.clamp(math.floor(100 - nearest * 12), 0, 100)
label.Text = string.format("%s (%d%%)", word, pct)
label.TextColor3 = col
hl.FillColor, hl.OutlineColor = col, col
else
if bb then bb.Enabled = false end
if hl then hl.Parent = nil end
end
else
if bb then bb.Enabled = false end
if hl then hl.Parent = nil end
end
end
end)
end
-- everything in the locked tab lives inside the Ultra Game Recorder card: the game recorder, shot recorder, game scanner and Shot Lab controls are moved into it
do
local tools = UI.lockedTools
if tools and #tools >= 2 then
local ultra = tools[1]
local order = 0
for _, ch in ipairs(ultra:GetChildren()) do
if ch:IsA("GuiObject") then order = math.max(order, ch.LayoutOrder) end
end
local card = { frame = ultra, order = order }
for i = 2, #tools do
local f = tools[i]
local title
for _, d in ipairs(f:GetDescendants()) do
if d:IsA("TextLabel") and d.Text ~= "" then title = d.Text break end
end
UI.Note(card, "---- " .. tostring(title or "Tool") .. " ----", "Text")
for _, ch in ipairs(f:GetChildren()) do
if ch:IsA("GuiObject") and ch.LayoutOrder >= 2 then
card.order = card.order + 1
ch.LayoutOrder = card.order
ch.Parent = ultra
end
end
f:Destroy()
end
for i = #tools, 2, -1 do table.remove(tools, i) end
end
end
-- AUTO GUARD, BLOCK, STEAL AND AUTO PLAY LIVE IN THE LOCKED TAB: guard mistakes, a pump fake check for blocks, and auto steal that only reaches when the ball handler is not dribbling
do
local Bot = JH.api.Bot
local prevGuard = Bot.guardStep
local slipUntil, slipNext = 0, 0
function Bot.guardStep(me, others, forced)
if S.AGMistakes then
local now = tick()
if now < slipUntil then
Bot.status = "Guarding (a slip)"
return true
end
if now > slipNext then
slipNext = now + 1.2 + math.random() * 1.6
if math.random(100) <= (S.AGMistakeAmt or 15) then slipUntil = now + 0.25 + math.random() * 0.45 end
end
end
return prevGuard(me, others, forced)
end
function Bot.blockStep(others, me)
if not S.AB then return end
local now = tick()
for _, o in ipairs(others) do
if not o.mate then
local was = Bot.shotSeen[o.c]
Bot.shotSeen[o.c] = o.shooting
if o.shooting and not was and now - Bot.blockT > 0.9 then
local dist = flat(o.pos - me).Magnitude
if dist <= S.ABRange and math.random(100) <= S.ABChance then
Bot.blockT = now
local c = o.c
task.delay(S.ABDelay * (0.85 + math.random() * 0.3), function()
if not JH.Running then return end
-- a pump fake turns the shot into a gather: only jump if he is really still shooting
if S.ABRecheck ~= false and c:GetAttribute("Action") ~= "Shooting" then return end
Bot.doJump()
end)
end
end
end
end
end
local function tap(words, key)
if key and key ~= "" then
Bot.press(key, 0.1, words)
else
local btn = Bot.findBtn(words)
if btn then
task.spawn(function()
Input.fireGui(btn, true, true)
task.wait(0.1)
Input.fireGui(btn, false, true)
end)
end
end
end
function Bot.stealStep(others, me)
if not S.ASteal or Feat.hasBall() then return end
local now = tick()
if now - (Bot.stealT or 0) < 1.6 then return end
for _, o in ipairs(others) do
if o.ball and not o.mate then
local act = o.c:GetAttribute("Action")
local d = flat(o.pos - me).Magnitude
if d <= (S.ASRange or 5) and act ~= "Dribbling" and act ~= "Shooting" and act ~= "Stealing" and math.random(100) <= (S.ASChance or 60) then
Bot.stealT = now
task.delay((S.ASReact or 0.15) * (0.8 + math.random() * 0.4), function()
if JH.Running then tap({ "steal", "reach" }, S.ASKey) end
end)
return
end
end
end
end
local prevThink = Bot.think
function Bot.think()
prevThink()
if S.ASteal then
pcall(function()
local r = Mover.body()
if r and not Bot.userActive() then Bot.stealStep(Bot.others(), r.Position) end
end)
end
end

-- the hidden auto guard and auto play pages: their cards, plus the new ones, move into the locked tab
local gp, ap
for _, p in ipairs(UI.pages) do
if p.name == "Auto Guard" then gp = p end
if p.name == "Auto Grind" then ap = p end
end
if gp then
local c1 = UI.Card(gp, "Guard mistakes")
UI.Toggle(c1, "Make mistakes sometimes", "AGMistakes")
UI.Slider(c1, "How often", "AGMistakeAmt", 0, 60, 1, 0, "%")
local c2 = UI.Card(gp, "Block pump fake check")
UI.Toggle(c2, "Only jump if he is still shooting", "ABRecheck")
UI.Note(c2, "Block reaction time and block distance are the sliders in the Auto block card.")
local c3 = UI.Card(gp, "Auto steal")
UI.Toggle(c3, "Auto steal (only when he is not dribbling)", "ASteal")
UI.Slider(c3, "Steal distance", "ASRange", 3, 9, 0.5, 1, " studs")
UI.Slider(c3, "Steal chance", "ASChance", 10, 100, 5, 0, "%")
UI.Slider(c3, "Steal reaction time", "ASReact", 0, 0.5, 0.01, 2, "s")
UI.Keybind(c3, "Steal key (empty uses the on-screen button)", function() return S.ASKey end, function(v) S.ASKey = v end)
if JH.AGContentFrames then
c1.frame.Visible = false
c2.frame.Visible = false
c3.frame.Visible = false
table.insert(JH.AGContentFrames, c1.frame)
table.insert(JH.AGContentFrames, c2.frame)
table.insert(JH.AGContentFrames, c3.frame)
end
end
if ap and UI.lockedTools then
for _, f in ipairs(ap.frame:GetChildren()) do
if f:IsA("Frame") then
f.Visible = false
table.insert(UI.lockedTools, f)
end
end
end
end
-- KEYBOARD BINDS: pick any dribble move by name and bind a key to it. The script learns each move's signal the first time you do that move with the game's own button, then the key repeats it
do
local N = 6
local MOVES = { "None", "Crossover 1", "Crossover 2", "BehindBack 1", "BehindBack 3", "DoubleBehindBack 1", "Spin 1", "Spin 2", "Spin 3", "HalfSpin 1",
"StepBack 1", "StepBack 2", "Retreat StepBack 1", "Hesitation 1", "Drive Hesitation 1", "Retreat Hesitation 1", "Misdirection Cross", "SwitchHand 1",
"Sidestep 1", "Eurostep 1", "Hopstep 1", "PowerHopstep 1" }
local lib = {}
local function ser(args)
local out = {}
for i = 1, args.n do
local v = args[i]
local t = typeof(v)
if t == "string" then out[i] = "s:" .. v
elseif t == "number" then out[i] = "n:" .. tostring(v)
elseif t == "boolean" then out[i] = "b:" .. tostring(v)
elseif t == "Vector3" then out[i] = "v:"
else out[i] = "x:" end
end
return table.concat(out, "|")
end
local function deser(text)
if not text or text == "" then return nil end
local args, n = {}, 0
for part in string.gmatch(text .. "|", "(.-)|") do
n = n + 1
local k, v = string.sub(part, 1, 1), string.sub(part, 3)
if k == "s" then args[n] = v
elseif k == "n" then args[n] = tonumber(v)
elseif k == "b" then args[n] = (v == "true")
elseif k == "v" then args[n] = "DIR"
else args[n] = nil end
end
args.n = n
return args
end
for entry in string.gmatch(S.BindLib or "", "([^;]+);") do
local name, text = string.match(entry, "^(.-)@@(.*)$")
if name then lib[name] = deser(text) end
end
local function saveLib()
local parts = {}
for name, args in pairs(lib) do parts[#parts + 1] = name .. "@@" .. ser(args) .. ";" end
S.BindLib = table.concat(parts)
saveSoon()
end
-- let the network layer (loaded later) read/write this move library and share it
JH.bindLib, JH.bindSer, JH.bindDeser, JH.bindSaveLib = lib, ser, deser, saveLib
local function remote()
local d = game:GetService("ReplicatedStorage"):FindFirstChild("Dribble", true)
return (d and d:IsA("RemoteEvent")) and d or Mover.lastDribbleRemote
end
local function replay(slot)
local name = S["BindMove" .. slot]
if not name or name == "None" then return end
local t, rem = lib[name], remote()
if not t then
notify("Binds", "Do " .. name .. " once with the game's own button first, so the script learns it", 4)
return
end
if not rem then return end
local h, r = hum(), Mover.body()
local dir = Vector3.new(0, 0, 1)
if h and r then
local ok, intent = pcall(Mover.intent, h, r)
if ok and intent and intent.Magnitude > 0.1 then dir = flat(intent) else dir = flat(r.CFrame.LookVector) end
end
local args = {}
for i = 1, t.n do args[i] = (t[i] == "DIR") and dir or t[i] end
Mover.selfFire = true
pcall(function() rem:FireServer(table.unpack(args, 1, t.n)) end)
Mover.selfFire = false
end
-- every dribble you do with the game's own button is remembered by the move's name
local prevOD = Mover.onDribble
function Mover.onDribble(args)
local copy = table.pack(table.unpack(args, 1, args.n))
task.spawn(function()
task.wait(0.12)
local c = char()
local raw = c and c:GetAttribute("LastDribblePackage")
-- the dropdown names have no hand suffix, but the game's own attribute does ("Spin 1 L"), so strip it before saving
local name = type(raw) == "string" and (string.match(raw, "^(.-)%s+[LR]$") or raw) or raw
if type(name) == "string" and name ~= "" and ser(lib[name] or { n = 0 }) ~= ser(copy) then
lib[name] = copy
saveLib()
if JH.onBindLearned then task.spawn(JH.onBindLearned, name, copy) end
end
end)
return prevOD(args)
end
UIS.InputBegan:Connect(function(i, gp)
local it = i.UserInputType
local isBindInput = it == Enum.UserInputType.Keyboard or it == Enum.UserInputType.Gamepad1 or it == Enum.UserInputType.Gamepad2 or it == Enum.UserInputType.Gamepad3 or it == Enum.UserInputType.Gamepad4
if not isBindInput then return end
if gp and it == Enum.UserInputType.Keyboard then return end
for slot = 1, N do
local k = S["BindKey" .. slot]
if k and k ~= "" and k == i.KeyCode.Name then
task.spawn(replay, slot)
return
end
end
end)
local pg = UI.Page("Binds", "K")
local lay = pg.frame:FindFirstChildOfClass("UIListLayout")
if lay then
lay.FillDirection = Enum.FillDirection.Horizontal
lay.Wraps = true
lay.Padding = UDim.new(0, 8)
end
local info = UI.Card(pg, "How binds work")
info.frame.Size = UDim2.new(1, -4, 0, 0)
UI.Note(info, "Pick a dribble move for each bind and a key or controller button. The first time you do a move with the game's own button, the script learns it. After that your key or controller button does that move, and the game picks left or right from the hand the ball is in.")
UI.Button(info, "Reset all binds", function()
	for slot = 1, N do
		S["BindMove" .. slot], S["BindKey" .. slot], S["BindArgs" .. slot] = "None", "", ""
	end
	saveSoon()
	UI.refreshAll()
	notify("Binds", "All 6 binds reset.", 3)
end)
for slot = 1, N do
local c = UI.Card(pg, "Bind " .. slot)
c.frame.Size = UDim2.new(0.5, -4, 0, 0)
UI.Dropdown(c, "Move", "BindMove" .. slot, MOVES)
UI.Keybind(c, "Key", function() return S["BindKey" .. slot] end, function(v) S["BindKey" .. slot] = v end)
UI.Button(c, "X - clear this bind", function()
S["BindMove" .. slot], S["BindKey" .. slot], S["BindArgs" .. slot] = "None", "", ""
saveSoon()
UI.refreshAll()
notify("Binds", "Bind " .. slot .. " cleared.", 2)
end)
end
end
-- LESS OBVIOUS GUARD, AUTO PLAY CARD, AUTO BLOCK BUTTON WORDS
do
local Bot = JH.api.Bot
-- a real defender lags behind a change of direction: the direction he runs in is smoothed over a third of a second
local dirS
local lastT = tick()
local prevMove = Bot.move
function Bot.move(dir, mul)
local now = tick()
if S.AGHuman and now - (Bot.guardingNow or 0) < 0.15 and dir then
local dt = math.min(now - lastT, 0.2)
local tau = 0.18 + 0.35 * ((S.AGHumanAmt or 50) / 100)
dirS = dirS and dirS:Lerp(dir, math.clamp(dt / tau, 0, 1)) or dir
lastT = now
return prevMove(dirS, math.min(mul or 1, 1.02))
end
dirS = nil
lastT = now
return prevMove(dir, mul)
end
local prevGuard = Bot.guardStep
function Bot.guardStep(me, others, forced)
local ok = prevGuard(me, others, forced)
-- only count as "actively guarding" (for animation purposes) once close to the real guard spot - this used to set guardingNow on every single call, which is every tick Auto Guard runs at all including while still chasing from far away, so the guard/defensive animation got picked almost 100% of the time and the walk animation never got a chance to show during approach
if ok and Bot.dbg and Bot.dbg.dist and Bot.dbg.dist < 3 then
Bot.guardingNow = tick()
end
return ok
end
-- the guard gives some room by default instead of hugging him
if (S.AGDist or 0) < 4 then S.AGDist = 4.5 end
if (S.AGReact or 0) < 0.15 then S.AGReact = 0.2 end

-- Auto play card at the top of the locked tab
if UI.lockedTools then
local lp = UI.lockedPage
local ap
for _, p in ipairs(UI.pages) do
if p.name == "Auto Guard" then ap = p end
end
if ap then
local c = UI.Card(ap, "Auto play")
local _, lbl = UI.Button(c, S.AP and "Auto play: ON (tap to stop)" or "Auto play: OFF (tap to start)", function() Bot.setAP(not S.AP) end, true)
Bot.apLabel = lbl
UI.Dropdown(c, "Build", "APBuild", { "Big", "Small", "Wing", "Shooter" })
UI.Note(c, "Turns on Auto Green, dribbles to get open, shoots open shots, takes layups and dunks, follows the shot for the rebound and guards when the other team has the ball. Touch the stick and it hands the game back to you.")
table.insert(UI.lockedTools, 2, c.frame)
c.frame.Visible = false
end
end
end
-- AUTO BLOCK JUMPS WITH THE GAME'S JUMP AND DUNK BUTTON (the trampoline button on mobile)
do
local Bot = JH.api.Bot
function Bot.doJump()
local btn = Bot.findBtn({ "jump", "dunk", "trampoline" })
if btn then
task.spawn(function()
Input.fireGui(btn, true, true)
task.wait(0.15)
Input.fireGui(btn, false, true)
end)
else
Bot.press(S.ABKey or "Space", 0.18)
local h = hum()
if h then pcall(function() h.Jump = true end) end
end
end
end
-- AUTO GUARD ONLY GUARDS THE PLAYER WHO HAS THE BALL
do
local Bot = JH.api.Bot
local prevG = Bot.guardStep
function Bot.guardStep(me, others, forced)
if S.AGOnlyBall ~= false then
local handler
for _, o in ipairs(others) do
if o.ball and not o.mate then handler = o end
end
if not handler then Bot.setGuardHold(false) return false end
forced = "Ball handler"
end
return prevG(me, others, forced)
end
end
-- UPDATE BUTTON: checks GitHub for the newest version and loads it
do
local OWNER, REPO, BRANCH = "jaydendagoat2", "jayhubv1", "claude/claudechud-8cord-executor-x86h7a"
local function http(url) return game:HttpGet(url) end
local function latestSha()
local branch = string.gsub(BRANCH, "/", "%%2F")
local ok, body = pcall(http, "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/commits/" .. branch)
if not ok or type(body) ~= "string" then return nil end
return string.match(body, '"sha"%s*:%s*"(%x+)"')
end
local function fetchNewest()
local sha = latestSha()
local url = sha and ("https://raw.githubusercontent.com/" .. OWNER .. "/" .. REPO .. "/" .. sha .. "/executor/JHubV1_Glass.lua")
or ("https://raw.githubusercontent.com/" .. OWNER .. "/" .. REPO .. "/" .. BRANCH .. "/executor/JHubV1_Glass.lua?v=" .. tostring(os.time()))
local ok, src = pcall(http, url)
if not ok or type(src) ~= "string" or #src < 10000 then return nil end
return src, string.match(src, 'local VERSION = "(v[%d%.]+)')
end
local mine = string.match(tostring(VERSION), "^(v[%d%.]+)") or tostring(VERSION)
local mainPage
for _, p in ipairs(UI.pages) do
if p.name == "Main" then mainPage = p end
end
if mainPage then
local c = UI.Card(mainPage, "Updates")
local cur = UI.Stat(c, "This version")
cur.Text = mine
local newest = UI.Stat(c, "Newest version")
newest.Text = "tap Check"
local busy = false
UI.Buttons(c, {
{ "Check", function()
if busy then return end
busy = true
newest.Text = "checking..."
local src, ver = fetchNewest()
newest.Text = ver or "could not reach GitHub"
busy = false
end },
{ "Update now", function()
if busy then return end
busy = true
newest.Text = "downloading..."
local src, ver = fetchNewest()
if not src then
newest.Text = "could not reach GitHub"
busy = false
return
end
newest.Text = ver or "?"
if ver == mine then
notify("Update", "You already have the newest version (" .. mine .. ")", 4)
busy = false
return
end
local fn = loadstring(src)
if not fn then
notify("Update", "The download could not be read", 4)
busy = false
return
end
notify("Update", "Updating to " .. tostring(ver) .. "...", 3)
pcall(JH.Unload)
task.defer(fn)
end },
})
UI.Note(c, "Loads the newest version from GitHub and restarts JHub. Your settings stay.")
end
end
-- PROBLEM REPORT FOR EVERYONE: copies the last shots (move, result, ping, FPS) so players can paste it to the developer
do
local mainPage
for _, p in ipairs(UI.pages) do
if p.name == "Main" then mainPage = p end
end
if mainPage and Shot.lab and Shot.lab.report then
local c = UI.Card(mainPage, "Problem report")
UI.Button(c, "Copy my shot report", function()
local text = Shot.lab.report()
if type(setclipboard) == "function" then
pcall(setclipboard, text)
notify("Report", "Copied. Paste it in the Discord.", 4)
else
pcall(function() if type(writefile) == "function" then writefile("JHub_shot_report.txt", text) end end)
notify("Report", "Saved as JHub_shot_report.txt in your executor folder", 5)
end
end)
UI.Note(c, "Shoot about 10 times, then tap this and paste the result in the Discord. It lists each shot, the result, your ping and FPS.")
end
end
-- DEX AND REMOTE SPY INSIDE THE ULTRA GAME RECORDER: the whole game tree, every shot package and every config module, plus the remote spy
do
local ultra = UI.lockedTools and UI.lockedTools[1]
if ultra then
local order = 0
for _, ch in ipairs(ultra:GetChildren()) do
if ch:IsA("GuiObject") then order = math.max(order, ch.LayoutOrder) end
end
local card = { frame = ultra, order = order }
local RS = game:GetService("ReplicatedStorage")
local function emit(file, text, what)
pcall(function() if type(writefile) == "function" then writefile(file, text) end end)
local clip = text
if #clip > 900000 then clip = string.sub(clip, 1, 900000) .. "\n-- (cut here, the rest is in the file " .. file .. ")" end
if type(setclipboard) == "function" then pcall(setclipboard, clip) end
notify("Dex", string.format("%s: %.0f KB, saved as %s%s", what, #text / 1024, file, type(setclipboard) == "function" and " and copied" or ""), 6)
end
local function deep(t, depth, out, prefix, seen, cap)
if seen[t] or depth > 7 or #out >= cap then return end
seen[t] = true
local keys = {}
for k in pairs(t) do keys[#keys + 1] = k end
pcall(table.sort, keys, function(a, b) return tostring(a) < tostring(b) end)
for _, k in ipairs(keys) do
if #out >= cap then
out[#out + 1] = prefix .. "... (cut)"
return
end
local v = t[k]
local tv = typeof(v)
if tv == "table" then
out[#out + 1] = prefix .. tostring(k) .. " = {"
deep(v, depth + 1, out, prefix .. "  ", seen, cap)
out[#out + 1] = prefix .. "}"
elseif tv == "function" then
out[#out + 1] = prefix .. tostring(k) .. " = function"
else
out[#out + 1] = prefix .. tostring(k) .. " = " .. Rec.fmt(v, 0)
end
end
end
local function treeText()
local out = { "== DEX TREE " .. tostring(VERSION) .. " | place " .. string.format("%.0f", game.PlaceId) .. " | " .. os.date("%Y-%m-%d %H:%M:%S") }
local lines = 0
local function walk(inst, depth, maxd)
if depth > maxd then return end
for _, c in ipairs(inst:GetChildren()) do
if c ~= gui then
local line = string.rep("  ", depth) .. c.Name .. " [" .. c.ClassName .. "]"
if c:IsA("ValueBase") then line = line .. " = " .. tostring(c.Value) end
if c:IsA("Animation") then line = line .. " id=" .. string.gsub(tostring(c.AnimationId), "rbxassetid://", "") end
if c:IsA("Sound") then line = line .. " id=" .. tostring(c.SoundId) end
if c:IsA("RemoteEvent") or c:IsA("RemoteFunction") then line = line .. " <remote>" end
local n = 0
for k, v in pairs(c:GetAttributes()) do
n = n + 1
if n <= 6 then line = line .. " @" .. k .. "=" .. tostring(v) end
end
out[#out + 1] = line
lines = lines + 1
if lines % 400 == 0 then task.wait() end
walk(c, depth + 1, maxd)
end
end
end
for _, spec in ipairs({ { RS, 16 }, { game:GetService("ReplicatedFirst"), 6 }, { game:GetService("StarterPlayer"), 8 }, { game:GetService("StarterGui"), 8 },
{ LP:FindFirstChild("PlayerGui"), 10 }, { workspace, 3 } }) do
if spec[1] then
out[#out + 1] = ""
out[#out + 1] = "-- " .. spec[1]:GetFullName()
pcall(walk, spec[1], 1, spec[2])
end
end
return table.concat(out, "\n")
end
local function configText(filter, title)
local out = { "== " .. title .. " " .. tostring(VERSION) .. " | place " .. string.format("%.0f", game.PlaceId) .. " | " .. os.date("%Y-%m-%d %H:%M:%S") }
local seenMod, mods = {}, {}
pcall(function()
for _, m in ipairs(getloadedmodules()) do
local ok, path = pcall(Bar.pathOf, m)
if ok and string.find(path, filter, 1, true) and not seenMod[m] then seenMod[m] = true mods[#mods + 1] = { m = m, path = path } end
end
end)
for _, m in ipairs(RS:GetDescendants()) do
if m:IsA("ModuleScript") and not seenMod[m] then
local path = m:GetFullName()
if string.find(string.gsub(path, "%.", "/"), filter, 1, true) then seenMod[m] = true mods[#mods + 1] = { m = m, path = path } end
end
end
table.sort(mods, function(a, b) return a.path < b.path end)
for i, e in ipairs(mods) do
if i % 5 == 0 then task.wait() end
out[#out + 1] = ""
out[#out + 1] = "-- " .. e.path
local ok, res = pcall(require, e.m)
if ok and type(res) == "table" then deep(res, 0, out, "  ", {}, #out + 2500)
elseif ok then out[#out + 1] = "  = " .. tostring(res)
else out[#out + 1] = "  (could not be read)" end
end
return table.concat(out, "\n"), #mods
end
Shot.dexConfigText = configText
UI.Note(card, "---- Dex and remote spy ----", "Text")
UI.Buttons(card, {
{ "Dex: game tree", function()
notify("Dex", "Reading the whole game. This takes up to a minute.", 5)
task.spawn(function() emit("JHub_dex_tree.txt", treeText(), "Game tree") end)
end },
{ "Dex: every jumpshot", function()
notify("Dex", "Reading every shot setting.", 4)
task.spawn(function()
local text, n = configText("Config/Game/Shooting", "SHOT SETTINGS (every jumpshot)")
emit("JHub_dex_shots.txt", text, n .. " shot modules")
end)
end },
})
UI.Buttons(card, {
{ "Dex: all config", function()
notify("Dex", "Reading every config module.", 4)
task.spawn(function()
local text, n = configText("Config", "ALL GAME CONFIG")
emit("JHub_dex_config.txt", text, n .. " config modules")
end)
end },
{ "Remote spy", function()
local text = Rec.spyText()
emit("JHub_remote_spy.txt", text, "Remote spy")
end },
})
JH.ctrlLog = JH.ctrlLog or {}
UI.Toggle(card, "Record controller inputs", "CtrlSpyOn", function(v)
	if v then
		JH.ctrlLog = {}
		notify("Controller spy", "Press every button, stick and trigger on your controller now.", 5)
	else
		notify("Controller spy", "Stopped. Tap Copy controller log to get the report.", 4)
	end
end)
UI.Buttons(card, {
{ "Copy controller log", function()
local log = JH.ctrlLog or {}
local lines = { "== CONTROLLER INPUTS " .. tostring(VERSION) .. " | " .. os.date("%Y-%m-%d %H:%M:%S") }
if #log == 0 then
lines[#lines + 1] = "(nothing recorded yet, turn Record controller inputs on and press every button, stick and trigger)"
else
for _, l in ipairs(log) do lines[#lines + 1] = l end
end
emit("JHub_controller_log.txt", table.concat(lines, "\n"), "Controller log")
end },
})
local lastAxis = {}
local function isGamepad(t)
	return t == Enum.UserInputType.Gamepad1 or t == Enum.UserInputType.Gamepad2 or t == Enum.UserInputType.Gamepad3 or t == Enum.UserInputType.Gamepad4
end
bind(UIS.InputBegan, function(i, gp)
	if not S.CtrlSpyOn or not isGamepad(i.UserInputType) then return end
	table.insert(JH.ctrlLog, string.format("%s  PRESS  %s  (%s)", os.date("%H:%M:%S"), i.KeyCode.Name, i.UserInputType.Name))
	if #JH.ctrlLog > 300 then table.remove(JH.ctrlLog, 1) end
end)
bind(UIS.InputChanged, function(i, gp)
	if not S.CtrlSpyOn or not isGamepad(i.UserInputType) then return end
	local pos = i.Position
	if pos.Magnitude < 0.08 then return end
	local name = i.KeyCode.Name
	local now = tick()
	if lastAxis[name] and now - lastAxis[name] < 0.4 then return end
	lastAxis[name] = now
	table.insert(JH.ctrlLog, string.format("%s  AXIS  %s  (%s)  x=%.2f y=%.2f z=%.2f", os.date("%H:%M:%S"), name, i.UserInputType.Name, pos.X, pos.Y, pos.Z))
	if #JH.ctrlLog > 300 then table.remove(JH.ctrlLog, 1) end
end)
UI.Buttons(card, {
{ "Copy control map (keyboard + controller + mobile)", function()
local CAS = game:GetService("ContextActionService")
local okc, infoAll = pcall(function() return CAS:GetAllBoundActionInfo() end)
local out = { "== CONTROL MAP " .. tostring(VERSION) .. " | place " .. tostring(game.PlaceId) .. " | " .. os.date("%Y-%m-%d %H:%M:%S") }
if okc and infoAll then
local names = {}
for name in pairs(infoAll) do names[#names + 1] = name end
table.sort(names)
local pg = LP:FindFirstChild("PlayerGui")
for _, name in ipairs(names) do
local d = infoAll[name]
local keys, pads, touch = {}, {}, false
for _, t in ipairs(d.inputTypes or {}) do
local ok2, et = pcall(function() return t.EnumType end)
if ok2 and et == Enum.KeyCode then
if string.find(t.Name, "^Button") or string.find(t.Name, "^DPad") or string.find(t.Name, "^Thumbstick") then
pads[#pads + 1] = t.Name
else
keys[#keys + 1] = t.Name
end
elseif ok2 and et == Enum.UserInputType and t == Enum.UserInputType.Touch then
touch = true
end
end
local btn
if pg then
for _, d2 in ipairs(pg:GetDescendants()) do
if d2:IsA("GuiButton") then
local n = string.lower(d2.Name .. " " .. (d2:IsA("TextButton") and d2.Text or ""))
if string.find(n, string.lower(name), 1, true) then
btn = d2:GetFullName()
break
end
end
end
end
out[#out + 1] = string.format("%s | keyboard: %s | controller: %s | touch flag: %s | on-screen button: %s",
name, #keys > 0 and table.concat(keys, ",") or "none", #pads > 0 and table.concat(pads, ",") or "none",
tostring(touch), btn or "not found")
end
else
out[#out + 1] = "(could not read the game's bound actions)"
end
emit("JHub_control_map.txt", table.concat(out, "\n"), "Control map")
end },
})
UI.Buttons(card, {
{ "Find every dribble move (scan the game's own data)", function()
notify("Dribble scan", "Reading the game's own dribble, combo and gather data. This takes a moment.", 5)
task.spawn(function()
local parts = {}
for _, filt in ipairs({ "Dribbl", "Combo", "Gather", "Move" }) do
local ok2, text = pcall(configText, filt, "DRIBBLE DATA (" .. filt .. ")")
if ok2 and text then parts[#parts + 1] = text end
task.wait()
end
local full = table.concat(parts, "\n\n")
emit("JHub_dex_dribble.txt", full, "Dribble move data")
notify("Dribble scan", "Done. Paste JHub_dex_dribble.txt to me so I can build real auto-fill from whatever the game actually stores.", 7)
end)
end },
})
end
end
-- GUARD RECORDER INSIDE THE ULTRA GAME RECORDER: records your own real guarding (state, animation, distance) and reports the learned walk animation id
do
local ultra = UI.lockedTools and UI.lockedTools[1]
if ultra then
local order = 0
for _, ch in ipairs(ultra:GetChildren()) do
if ch:IsA("GuiObject") then order = math.max(order, ch.LayoutOrder) end
end
local card = { frame = ultra, order = order }
local function emit(file, text, what)
pcall(function() if type(writefile) == "function" then writefile(file, text) end end)
local clip = text
if #clip > 900000 then clip = string.sub(clip, 1, 900000) .. "\n-- (cut here, the rest is in the file " .. file .. ")" end
if type(setclipboard) == "function" then pcall(setclipboard, clip) end
notify("Dex", string.format("%s: %.0f KB, saved as %s%s", what, #text / 1024, file, type(setclipboard) == "function" and " and copied" or ""), 6)
end
JH.guardLog = JH.guardLog or {}
local function nearestOther()
local r = Mover.body()
if not r then return nil end
local best, bd
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= LP and pl.Character then
local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
if hrp then
local d = flat(hrp.Position - r.Position).Magnitude
if not bd or d < bd then best, bd = pl, d end
end
end
end
return best, bd
end
local lastLog = 0
bind(RunService.Heartbeat, function()
if not S.GuardSpyOn then return end
local now = tick()
if now - lastLog < 0.5 then return end
lastLog = now
local h = hum()
if not h then return end
local _, dist = nearestOther()
local tracks = {}
for _, tr in ipairs(h:GetPlayingAnimationTracks()) do
local id = tr.Animation and tr.Animation.AnimationId or "?"
tracks[#tracks + 1] = string.format("%s(%s,%s)", id, tr.Priority.Name, tostring(tr.Looped))
end
table.insert(JH.guardLog, string.format("%s  state=%s  holdingG=%s  moveDir=%.2f  dist=%.1f  guarding=%s  tracks=%s",
os.date("%H:%M:%S"), h:GetState().Name, tostring(char() and char():GetAttribute("HoldingG")), h.MoveDirection.Magnitude, dist or -1, tostring(Bot.status or ""), #tracks > 0 and table.concat(tracks, " | ") or "none"))
if #JH.guardLog > 300 then table.remove(JH.guardLog, 1) end
end)
UI.Toggle(card, "Record guarding", "GuardSpyOn", function(v)
if v then
JH.guardLog = {}
notify("Guard recorder", "Recording. Play normally, guard someone for a bit, then tap Copy guard log.", 5)
else
notify("Guard recorder", "Stopped. Tap Copy guard log to get the report.", 4)
end
end)
UI.Buttons(card, {
{ "Copy guard log", function()
local log = JH.guardLog or {}
local lines = { "== GUARD RECORDER " .. tostring(VERSION) .. " | " .. os.date("%Y-%m-%d %H:%M:%S"),
"Learned walk animation id: " .. tostring(S.WalkAnimId ~= "" and S.WalkAnimId or "(not learned yet, walk for real once)"),
				"Learned guard/slide animation id: " .. tostring(S.GuardAnimId ~= "" and S.GuardAnimId or "(not learned yet, guard someone for real once)"),
string.format("Guard settings: dist=%s react=%s predict=%s range=%s guardSpeed=%s", tostring(S.AGDist), tostring(S.AGReact), tostring(S.AGPredict), tostring(S.AGRange), tostring(S.GuardSpeed)),
"" }
if #log == 0 then
lines[#lines + 1] = "(nothing recorded yet, turn Record guarding on and guard someone for a bit)"
else
for _, l in ipairs(log) do lines[#lines + 1] = l end
end
emit("JHub_guard_log.txt", table.concat(lines, "\n"), "Guard log")
end },
})
end
end
-- JUMPSHOT MASTERY INSIDE THE ULTRA GAME RECORDER: which jumpshots in the game have been covered, what was learned for each, and every shot setting the game stores
do
local function pairKey(a, b)
local t = { tostring(a), tostring(b) }
table.sort(t)
return t[1] .. "+" .. t[2]
end
function Shot.masteryText()
local ids = Shot.idName or {}
local byName = {}
for id, name in pairs(ids) do byName[name] = id end
pcall(Shot.autoLoad)
local lines = { "== JUMPSHOT MASTERY " .. tostring(VERSION) .. " | " .. os.date("%Y-%m-%d %H:%M:%S"), "",
"-- every jumpshot in the game: covered? | key | learned lead | shots | perfect good early late --" }
local covered, total = 0, 0
local function statsOf(key)
local a = Shot.auto and Shot.auto[key]
local s = Shot.lab and Shot.lab.stats and Shot.lab.stats[key]
local fin = Shot.FINAL and Shot.FINAL[key]
return a, s, fin
end
for n = 1, 16 do
for _, side in ipairs({ "L", "R" }) do
local base, rel = byName["Jumpshot" .. n .. side .. "Base"], byName["Jumpshot" .. n .. side .. "Release"]
if base and rel then
total = total + 1
local key = pairKey(base, rel)
local a, s, fin = statsOf(key)
local has = (a ~= nil) or (s ~= nil) or (fin ~= nil)
if has then covered = covered + 1 end
lines[#lines + 1] = string.format("Jumpshot %d%s | %s | key=%s | lead=%s | shots=%s | %s", n, side, has and "COVERED" or "not shot yet", key,
a and string.format("%.4f%s", a.hold or 0, a.locked and " (locked)" or "") or (fin and string.format("built-in %.3f", fin) or "-"),
s and tostring(s.n) or "0", s and string.format("%d %d %d %d", s.perfect, s.good, s.early, s.late) or "-")
end
end
end
lines[#lines + 1] = ""
lines[#lines + 1] = string.format("coverage: %d of %d jumpshots have been shot or learned", covered, total)
lines[#lines + 1] = ""
lines[#lines + 1] = "-- every other shot type that was shot or learned --"
for key, a in pairs(Shot.auto or {}) do
lines[#lines + 1] = string.format("%s | key=%s | lead=%.4f%s", tostring(Shot.nameFor and Shot.nameFor(key) or key), key, a.hold or 0, a.locked and " (locked)" or "")
end
lines[#lines + 1] = ""
lines[#lines + 1] = "-- learned timings in the script's own format (paste this to the developer) --"
lines[#lines + 1] = tostring(S.AutoTimes or "")
lines[#lines + 1] = "-- built-in shot adjustments --"
lines[#lines + 1] = tostring(S.FinalAdj or "")
lines[#lines + 1] = "-- shot family timings --"
lines[#lines + 1] = tostring(S.FamLead or "")
return table.concat(lines, "\n")
end
local U = Shot.ultra
if U and U.report then
local prev = U.report
function U.report()
local parts = { prev(), "\n\n" .. Shot.masteryText() }
if Shot.dexConfigText then
local ok, text = pcall(Shot.dexConfigText, "Config/Game/Shooting", "SHOT SETTINGS (every jumpshot)")
parts[#parts + 1] = "\n\n" .. (ok and text or "== shot settings could not be read")
end
return table.concat(parts)
end
end
local ultra = UI.lockedTools and UI.lockedTools[1]
if ultra then
local order = 0
for _, ch in ipairs(ultra:GetChildren()) do
if ch:IsA("GuiObject") then order = math.max(order, ch.LayoutOrder) end
end
local card = { frame = ultra, order = order }
UI.Note(card, "---- Jumpshot mastery ----", "Text")
UI.Buttons(card, {
{ "Copy jumpshot mastery", function()
local text = Shot.masteryText()
pcall(function() if type(writefile) == "function" then writefile("JHub_mastery.txt", text) end end)
if type(setclipboard) == "function" then pcall(setclipboard, text) end
notify("Mastery", "Copied and saved as JHub_mastery.txt", 4)
end },
})
UI.Note(card, "Lists all 16 jumpshots (left and right): which ones you have shot, what was learned for each, and which still need a few shots. Copy everything now also includes this and every shot setting the game stores.")
end
end
-- PER-JUMPSHOT SETTINGS: the game's own numbers for all 16 jumpshots; shots with random timing are learned more steadily
do
Shot.CFG = {
[1] = { 1.8, 0 }, [2] = { 1.045, 0 }, [3] = { 1.065, 0 }, [4] = { 0.875, 0 },
[5] = { 1, 0.05 }, [6] = { 1, 0.05 }, [7] = { 1, 0.05 }, [8] = { 0.95, 0.05 },
[9] = { 0.95, 0 }, [10] = { 0.95, 0.05 }, [11] = { 0.8, 0.05 }, [12] = { 0.8, 0.05 },
[13] = { 1, 0.05 }, [14] = { 0.825, 0.05 }, [15] = { 1.07, 0.05 }, [16] = { 0.9, 0 },
}
local function jumpNum(key)
for id in string.gmatch(tostring(key), "%d+") do
local nm = Shot.idName and Shot.idName[id]
local n = nm and string.match(nm, "^Jumpshot(%d+)[RL]")
if n then return tonumber(n) end
end
end
Shot.jumpNum = jumpNum
local prevGain = Shot.adaptGain
function Shot.adaptGain(key, off)
local g = prevGain(key, off)
local n = jumpNum(key)
local c = n and Shot.CFG[n]
-- random-timing shots: a miss can be the game's own +-0.05 noise, so never push a step harder than normal
if c and c[2] > 0 and g > 1 then g = 1 end
return g
end
local prevText = Shot.masteryText
if prevText then
function Shot.masteryText()
local t = prevText()
local o = { "", "GAME SETTINGS PER JUMPSHOT (speed / random timing)" }
for i = 1, 16 do
local c = Shot.CFG[i]
o[#o + 1] = string.format("  Jumpshot %d: speed %.3f  random %s", i, c[1], c[2] > 0 and "+-0.05" or "none")
end
return t .. "\n" .. table.concat(o, "\n")
end
end
end
-- 10 ALWAYS-ON LIVE HELPS FOR AUTO GREEN: small, clamped nudges on top of the existing learner. No toggle, cannot be turned off.
do
local legacySeed = Shot.seedLead
local function liveChar() return char() end
local pingAvg, pingN = 70, 0
local function livePing()
local ok, p = pcall(function() return Players.LocalPlayer:GetNetworkPing() * 1000 end)
return ok and p or nil
end
local function pingBaseline(p)
pingN = math.min(pingN + 1, 40)
pingAvg = pingAvg + (p - pingAvg) / pingN
return pingAvg
end

-- 1) a ping spike above your normal ping nudges the live hold a touch later
local prevSeed1 = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeed1(key)
if Shot.FINAL[key] then return v end
local p = livePing()
if p then
local base = pingBaseline(p)
v = clamp(v + clamp((p - base) * 0.00004, -0.004, 0.008), 0, 0.1)
end
return v
end

-- 2) low stamina slows the shot animation down a touch, so the lead comes a little later
local prevSeed2 = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeed2(key)
if Shot.FINAL[key] then return v end
local c = liveChar()
local st = c and c:GetAttribute("Stamina")
if type(st) == "number" and st < 35 then
v = clamp(v + (35 - st) * 0.00006, 0, 0.1)
end
return v
end

-- 3) standing and moving jumpshots are learned as two separate pools, so one does not drag the other around
local moveFam, moveFamN = {}, {}
local function movingNow()
local c = liveChar()
local v = c and c:GetAttribute("ServerVelocity")
return (typeof(v) == "Vector3") and v.Magnitude > 3
end
local prevLearn3 = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
local r = prevLearn3(info, res, strength)
if info and info.lead and not info.manual and not Shot.FINAL[info.key] then
local fam = Shot.familyOf(info.key)
if fam then
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx then
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
if math.abs(off) <= 3 then
local key2 = (movingNow() and "m:" or "s:") .. fam
local n = moveFamN[key2] or 0
local est = clamp(info.lead + off * (S.PeakBin or 0.014) * 0.8, 0, 0.1)
moveFam[key2] = (n < 2) and est or (moveFam[key2] * 0.85 + est * 0.15)
moveFamN[key2] = math.min(n + 1, 999)
end
end
end
end
return r
end
local prevSeed3 = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeed3(key)
if Shot.FINAL[key] then return v end
local fam = Shot.familyOf(key)
if fam then
local key2 = (movingNow() and "m:" or "s:") .. fam
if (moveFamN[key2] or 0) >= 2 then v = clamp(moveFam[key2], 0, 0.1) end
end
return v
end

-- 4) your own character's live ShotSpeed scales the seed, instead of one flat number for every player
local prevSeed4 = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeed4(key)
if Shot.FINAL[key] then return v end
local c = liveChar()
local sp = c and tonumber(c:GetAttribute("ShotSpeed"))
if sp and sp > 0.3 and sp < 3 then
local scale = clamp(1 / sp, 0.75, 1.3)
v = clamp(v * (0.7 + 0.3 * scale), 0, 0.1)
end
return v
end

-- 5) a contested miss teaches the learner less than a wide-open miss
local prevLearn5 = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if info and not info.manual and strength and res ~= "green" and res ~= "good" then
local tag = string.match(tostring(Shot.fbText or ""), "Contest %- (%S+)")
if tag and tag ~= "None" and tag ~= "Open" then strength = math.max(1, strength - 1) end
end
return prevLearn5(info, res, strength)
end

-- 6) a lag spike at the moment you learn from a shot also teaches the learner less
local prevLearn6 = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if info and not info.manual and strength then
local p = livePing()
if p and p > pingAvg + 40 then strength = math.max(1, strength - 1) end
end
return prevLearn6(info, res, strength)
end

-- 7) a jumper you have barely seen moves toward the truth faster than one you already know well
local prevLearn7 = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
local a = Shot.auto and info and Shot.auto[info.key]
local before, beforeN = a and a.hold, a and a.n or 0
local r = prevLearn7(info, res, strength)
if a and before and a.mode == "peak" and not (info and info.manual) and a.hold ~= before then
local conf = math.min(1, beforeN / 12)
a.hold = clamp(before + (a.hold - before) * (1.4 - conf * 0.7), 0, 0.1)
end
return r
end

-- 8) catching a pass straight into a shot gets its own small gather adjustment
local prevSeed8 = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeed8(key)
if Shot.FINAL[key] then return v end
local c = liveChar()
local gt = c and tostring(c:GetAttribute("GatherType") or "")
if gt ~= "" and string.find(string.lower(gt), "catch", 1, true) then
v = clamp(v - 0.003, 0, 0.1)
end
return v
end

-- 9) one freak result does not swing the hold; it has to show up twice in a row first
local lastOff = {}
local prevLearn9 = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if info and info.key and not info.manual then
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx then
local off = (idx == 5 and 0) or (idx == 4 and -1) or (idx - 5)
local last = lastOff[info.key]
lastOff[info.key] = off
if math.abs(off) >= 3 and (not last or math.abs(last) < 2) and strength then
strength = math.max(1, strength - 1)
end
end
end
return prevLearn9(info, res, strength)
end

-- 10) whatever the nine above add up to, the live seed can never drift far from what the shot has actually earned
local prevSeed10 = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeed10(key)
local orig = legacySeed(key)
return clamp(clamp(v, orig - 0.015, orig + 0.015), 0, 0.1)
end
end
-- JHUB NETWORK: chat, a shared timing pool, and a live feed for everyone running this script. Uses your own Firebase project.
do
local Net = {}
Net.URL = "https://jayhubv1-default-rtdb.firebaseio.com"
Net.lead = {}
local function netGet(path)
local ok, res = pcall(function() return request({ Url = Net.URL .. "/" .. path .. ".json", Method = "GET" }) end)
if ok and res and res.Body then
local okj, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
if okj then return data end
end
return nil
end
local function netPost(path, tbl)
local okj, body = pcall(function() return HttpService:JSONEncode(tbl) end)
if not okj then return end
pcall(function() request({ Url = Net.URL .. "/" .. path .. ".json", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end)
end
local function netPut(path, tbl)
local okj, body = pcall(function() return HttpService:JSONEncode(tbl) end)
if not okj then return end
pcall(function() request({ Url = Net.URL .. "/" .. path .. ".json", Method = "PUT", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end)
end
local function sanitize(k) return (string.gsub(tostring(k), "[%.%#%$%[%]/]", "_")) end
local myName = Players.LocalPlayer.Name
JH.netGet, JH.netPut = netGet, netPut
JH.roles = JH.roles or {}
task.spawn(function()
while true do
local ok, data = pcall(netGet, "roles")
if ok and type(data) == "table" then JH.roles = data end
task.wait(5)
end
end)
local function badgeFor(name)
local roles = JH.roles or {}
if roles.owner and roles.owner ~= "" and name == roles.owner then
return "\u{1F451} ", Color3.fromRGB(255, 215, 0), " #owner"
end
if type(roles.devs) == "string" then
for dn in string.gmatch(roles.devs, "([^,]+)") do
if string.gsub(dn, "^%s+", "") == name then return "\u{1F6E0} ", Color3.fromRGB(80, 220, 255), " #dev" end
end
end
if roles.mod1 and roles.mod1 ~= "" and name == roles.mod1 then return "\u{1F6E1} ", Color3.fromRGB(190, 120, 255), " #mod" end
if roles.mod2 and roles.mod2 ~= "" and name == roles.mod2 then return "\u{2B50} ", Color3.fromRGB(255, 160, 60), " #mod" end
return "", nil, ""
end

local mainPage
for _, p in ipairs(UI.pages) do if p.name == "Main" then mainPage = p end end
if mainPage then
-- CHAT: everyone running this script can talk here
local chat = UI.Card(mainPage, "JHub Chat (everyone on this script)")
local chatList = new("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 130), BackgroundTransparency = 1, ScrollBarThickness = 3,
CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(chat), Parent = chat.frame })
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = chatList })
local chatRow = row(chat, 30)
local chatBox = new("TextBox", { Size = UDim2.new(1, -66, 1, 0), Text = "", PlaceholderText = "Say something to everyone on JHub...",
ClearTextOnFocus = false, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = chatRow })
UI.text(chatBox, false)
UI.elem(chatBox)
UI.th(chatBox, "TextColor3", "Text")
UI.th(chatBox, "PlaceholderColor3", "Sub")
UI.corner(chatBox, 0.7)
UI.stroke(chatBox, 0.5)
new("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = chatBox })
local chatSendBtn = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
Size = UDim2.fromOffset(58, 26), Text = "", AutoButtonColor = false, BackgroundColor3 = WHITE, Parent = chatRow })
UI.corner(chatSendBtn, 0.8)
UI.grad(chatSendBtn)
UI.label({ Text = "Send", TextSize = 13, Size = UDim2.fromScale(1, 1), TextColor3 = WHITE, Parent = chatSendBtn }, true, false)
UI.Note(chat, "Type !ai followed by a question to ask the chat's AI.")
local function askAI(q, cb)
task.spawn(function()
local ok, res = pcall(function()
return request({ Url = "https://text.pollinations.ai/" .. HttpService:UrlEncode(q) .. "?model=openai", Method = "GET" })
end)
local answer = (ok and res and res.Body and res.Body ~= "") and res.Body or "(the AI did not answer, try again)"
cb(string.sub(answer, 1, 400))
end)
end
local function sendChat()
local msg = chatBox.Text
if msg and msg ~= "" then
chatBox.Text = ""
task.spawn(netPost, "chat", { name = myName, text = string.sub(msg, 1, 200), t = os.time() })
local q = string.match(msg, "^!ai%s+(.+)$")
if q then
askAI(q, function(answer)
netPost("chat", { name = "JHub AI", text = answer, t = os.time() })
end)
end
end
end
chatBox.FocusLost:Connect(function(enter) if enter then sendChat() end end)
chatSendBtn.Activated:Connect(sendChat)
local lastChatKey = nil
task.spawn(function()
while true do
local data = netGet("chat")
if type(data) == "table" then
local keys = {}
for k in pairs(data) do keys[#keys + 1] = k end
table.sort(keys)
for _, c in ipairs(chatList:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
for i = math.max(1, #keys - 29), #keys do
local m = data[keys[i]]
if type(m) == "table" then
local name = tostring(m.name or "?")
local prefix, color, suffix = badgeFor(name)
local lbl = UI.label({ Text = string.format("%s%s: %s%s", prefix, name, tostring(m.text or ""), suffix), TextSize = 11,
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, Parent = chatList }, false, "Text")
if color then lbl.TextColor3 = color end
end
end
local newest = keys[#keys]
if newest and newest ~= lastChatKey then
local wasFirst = lastChatKey == nil
lastChatKey = newest
local m = data[newest]
if not wasFirst and type(m) == "table" and tostring(m.name or "") ~= myName then
notify("JHub Chat", string.format("%s: %s", tostring(m.name or "?"), tostring(m.text or "")), 4)
end
end
end
task.wait(3)
end
end)

-- LIVE FEED: every shot anyone on this script takes shows up here
local feed = UI.Card(mainPage, "Live feed (everyone's shots)")
local feedList = new("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 100), BackgroundTransparency = 1, ScrollBarThickness = 3,
CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(feed), Parent = feed.frame })
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = feedList })
task.spawn(function()
while true do
local data = netGet("feed")
if type(data) == "table" then
local keys = {}
for k in pairs(data) do keys[#keys + 1] = k end
table.sort(keys)
for _, c in ipairs(feedList:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
for i = math.max(1, #keys - 19), #keys do
local m = data[keys[i]]
if type(m) == "table" then
UI.label({ Text = string.format("%s  |  %s  |  %s", tostring(m.name or "?"), tostring(m.shot or "?"), tostring(m.verdict or "?")),
TextSize = 11, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, Parent = feedList }, false, "Sub")
end
end
end
task.wait(4)
end
end)

-- UPDATE LOG
local ulog = UI.Card(mainPage, "Update log")
UI.Note(ulog, table.concat({
"v1.86 - Universal Shot Intelligence: every jumpshot animation now gets a persisted profile (name, length, times seen, situations seen, first/last seen, identified or not), a locked profile that starts missing consistently is automatically unlocked and flagged to retest instead of staying trusted forever, and an animation that cannot be identified is labeled as such instead of silently reusing another profile's data - all shown on the Shot Intelligence card",
"v1.85 - new Shot Intelligence card shows the detected jumpshot, its animation ID, calibration status, confidence (sample count/locked/built-in), active timing, and how many profiles are known, plus a button to copy every profile - this is the existing per-animation timing-profile system (automatic per-jumpshot profiles, auto switching when you change jumpshots) made visible instead of hidden",
"v1.84 - a jumpshot used to only get shared as a found best timing network-wide if someone hit a literal real Perfect on it; now any jumpshot whose adaptive learner converges with enough real samples (12+) gets shared the same way, so every jumpshot anyone actually plays eventually gets a found-and-shared best timing, not just the rare Perfects",
"v1.83 - the Owner tab's 2011 code alone could let anyone rename themselves Owner, overwriting whoever had it; now the roles screen loads the current Owner/devs/mods instead of defaulting to you, roles stay set until someone changes them, and changing who the Owner is now needs a separate code on top of 2011",
"v1.82 - entering the Auto Guard, Locked, or Owner tab code once now sticks - it stays unlocked after the script resets/reloads, no need to retype it",
"v1.81 - new Owner tab (code 2011) sets who gets a crown/gold/#owner or dev/mod badge in JHub Chat for everyone; chat now pops a notification for new messages; shared jumpshot timing now pushes/pulls every 2-4s instead of 10-20s so one person's locked timing reaches everyone almost instantly; calibration step/speed increased; removed the made-shot ding sound",
"v1.80 - GuardAnimId never once beat the game\'s own real defensive animation in testing, so stopped fighting it - Auto Guard now always plays the real walk animation whenever actually moving, guarding or not",
"v1.79 - found why Auto Rebound had a walk animation but Auto Guard did not: a wobble wrapper was marking Auto Guard as actively guarding on every single tick it ran, even mid-chase, so the walk animation never got picked - fixed",
"v1.78 - Humanoid:Move did nothing for the walk animation either (same reason it did nothing for movement) - now manually plays the confirmed real walk/guard animation on top of CFrame movement",
"v1.77 - added an option to only drive Auto Guard while you hold the real Guard button yourself, instead of it pressing the button for you",
"v1.76 - confirmed Mover.send also produced zero real movement (sent ok, speed stayed 0); back to CFrame for actual position, with Humanoid:Move running alongside it at the same time purely so the real walk animation plays",
"v1.75 - diagnostics found AGRange was blocking Auto Guard from even trying to move whenever the opponent was past it (check your Guard range slider); fixed a logging bug that hid confirmed Mover.send calls; open/contested is now live while dribbling with a character highlight, not just a post-shot label",
"v1.74 - added live diagnostics to the Remote Guard Recorder log: target, distance, calculated direction, what actually got sent, whether it was blocked, and humanoid state, no logic changed",
"v1.73 - found the real reason Auto Guard never followed: this game is server-authoritative and ignores Humanoid:Move entirely - movement now fires the same MoveDirection remote the game itself uses",
"v1.72 - Auto Guard target lock now sticks to the same opponent (with hysteresis) instead of re-picking best every tick, and velocity is read from the real AssemblyLinearVelocity (now including AI) instead of estimated",
"v1.71 - back on Humanoid:Move for good: re-read the last log correctly - speed=0 was the guard distance dead-zone working as intended, not a stall; movement is smooth, animations are the game\'s own, target lock/tracking unchanged",
"v1.70 - Humanoid:Move produced zero actual movement in this game (confirmed: speed stuck at 0 the whole time), reverted to CFrame for position while keeping the confirmed real walk/defensive animation ids playing on top",
"v1.69 - Auto Guard no longer moves by CFrame at all - it now uses Humanoid:Move like a real player does, so the game\'s own Animate script picks the correct walk/defensive-slide animation automatically",
"v1.68 - found the real reason the walk animation never showed: moving the root by CFrame alone left the humanoid stuck in Freefall/FallingDown state forever, which hid the walk animation even though it was technically playing - fixed",
"v1.67 - removed the Discord join gate entirely, replaced with a Discord button in the top right of the menu that copies the invite link",
"v1.66 - fixed the Discord join gate freezing the whole script for anyone whose click or isfile/writefile did not register - it no longer blocks the real menu from loading",
"v1.65 - found it: the real walk animation id was being auto-deleted by a leftover bad-id filter, so Auto Guard could never have one; fixed and bootstrapped the confirmed real ids",
"v1.64 - Remote Guard Recorder now also watches whoever is nearest to you, not just yourself, and logs their walk/guard animation ids too",
"v1.63 - Auto Guard now detects AI opponents (no Player object) and uses the real HomeTeam attribute instead of Player.Team",
"v1.62 - recorder now polls currently-playing animations directly instead of waiting on a play event",
"v1.61 - fixed the recorder: move spam was evicting every animation entry from the log",
"v1.60 - found the real cause of the blank Auto Guard tab: a leftover block re-hid every card on it",
"v1.59 - fixed the in-script update checker pointing at the wrong, stale branch",
"v1.58 - removed the lock code from the visible update log",
"v1.57 - found it: a leftover line was hiding the Auto Guard tab and force-disabling it every load",
"v1.56 - rebuilt Auto Guard tab self-contained with its own code lock",
"v1.55 - Auto Guard now locked behind the Locked tab code, same as the other tools",
"v1.54 - Auto Guard rebuilt plain again (CFrame + real animation, no simulated input); recorder moved onto its own tab",
"v1.53 - added Remote Guard Recorder: catches every animation and movement state while guarding",
"v1.52 - fixed sideways drift and stuck movement when auto guard stops being called",
"v1.51 - Auto Guard rebuilt: holds real Guard button, follows with real keys/joystick",
"v1.50 - Auto Guard holds the real Guard button instead of crafting remote calls",
"v1.49 - fixed HoldG toggling itself back off every frame before the server caught up",
"v1.48 - Auto Guard now presses the real Guard button and lets the server drive movement",
"v1.47 - learns your real defensive slide animation separately from your walk",
"v1.46 - fixed the walk animation learner relearning its own old fake id",
"v1.45 - fixed walk animation never being learned (this game does not use MoveDirection)",
"v1.44 - guard recorder: records your real guarding and reports the learned walk animation id",
"v1.43 - fixed a frozen black/blue screen on first run for some users (Discord gate crash)",
"v1.42 - walk animation is learned from your own real walk instead of a guessed id",
"v1.41 - auto guard uses your real walk animation and Players-tab guard speed only",
"v1.40 - X button on every bind, learned binds shared across the network",
"v1.29 - JHub network: chat, live feed, shared jumpshot timing",
"v1.28 - 10 always-on live helps for Auto Green",
"v1.27 - Sweep locked off at all times",
"v1.25 - every jumpshot's game settings built in",
"v1.24 - jumpshot mastery inside the Ultra recorder",
"v1.23 - Dex tree, every shot setting, remote spy inside Ultra recorder",
"v1.22 - Copy my shot report for every player",
}, "\n"))
end

-- SHARED TIMING POOL: once a jumpshot is locked on anyone's copy, it is shared so everyone's copy converges faster.
-- once that convergence is confident (enough real samples, not just a lucky first guess), broadcast it as a best-known
-- timing for that jumpshot the same way a real Perfect does, so every jumpshot anyone actually plays eventually gets
-- a found-and-shared best timing, not just the ones someone happens to hit a literal Perfect on
local lastPush = {}
local prevLearnNet = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
local r = prevLearnNet(info, res, strength)
if info and info.key and Shot.auto and Shot.auto[info.key] and Shot.auto[info.key].locked and not Shot.FINAL[info.key] then
local a = Shot.auto[info.key]
local now = tick()
if (lastPush[info.key] or 0) + 2 < now then
lastPush[info.key] = now
local confident = (a.n or 0) >= 12
task.spawn(netPut, "timing/" .. sanitize(info.key), { lead = a.hold, n = a.n or 0, hard = confident or nil, by = myName, t = os.time() })
end
end
return r
end
task.spawn(function()
while true do
local data = netGet("timing")
if type(data) == "table" then
local merged = {}
for k, v in pairs(data) do
if type(v) == "table" and type(v.lead) == "number" then merged[k] = v end
end
Net.lead = merged
end
task.wait(4)
end
end)
local prevSeedNet = Shot.seedLead
function Shot.seedLead(key)
local v = prevSeedNet(key)
if Shot.FINAL[key] then return v end
local locked = Shot.auto and Shot.auto[key] and Shot.auto[key].locked
if not locked then
local net = Net.lead[sanitize(key)]
if net and net.lead then v = clamp((v + net.lead) / 2, 0, 0.1) end
end
return v
end

-- LIVE FEED POST: fires once per completed shot
local prevLR = Shot.learnRemote
function Shot.learnRemote(info, res, strength)
if info and info.key then
task.spawn(netPost, "feed", { name = myName, shot = Shot.nameFor(info.key, info.anim), verdict = tostring(res), t = os.time() })
end
return prevLR(info, res, strength)
end
-- PERFECT LOCK: a real Perfect freezes that exact jumpshot's timing forever, locally and shared, until you ask for it to be unlocked by name
local function readHard()
local t = {}
for k in string.gmatch(S.HardLock or "", "([^,]+),") do t[k] = true end
return t
end
local function addHard(key)
local t = readHard()
if not t[key] then
S.HardLock = (S.HardLock or "") .. key .. ","
saveSoon()
end
end
JH.hardLocked = readHard()
local prevLearnHL = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if info and info.key and JH.hardLocked[info.key] then return true end
local r = prevLearnHL(info, res, strength)
if info and info.key and info.idx == 5 and not info.manual and not Shot.FINAL[info.key] and not JH.hardLocked[info.key] and info.lead then
local a = Shot.auto and Shot.auto[info.key]
if not a then
a = { hold = info.lead, greens = {}, locked = false, dir = 1, mode = "peak", bin = S.PeakBin }
Shot.auto[info.key] = a
end
a.hold, a.locked, a.mode = info.lead, true, "peak"
JH.hardLocked[info.key] = true
addHard(info.key)
task.spawn(netPut, "timing/" .. sanitize(info.key), { lead = a.hold, n = 9999, hard = true, by = myName, t = os.time() })
notify("Timing locked", "Jumpshot " .. tostring(Shot.nameFor and Shot.nameFor(info.key) or info.key) .. " hit a real Perfect, its timing is locked forever and shared.", 5)
end
return r
end
local prevSeedHL = Shot.seedLead
function Shot.seedLead(key)
if JH.hardLocked[key] and Shot.auto and Shot.auto[key] then return Shot.auto[key].hold end
local net = Net.lead[sanitize(key)]
if net and net.hard and not JH.hardLocked[key] then
JH.hardLocked[key] = true
addHard(key)
Shot.auto[key] = Shot.auto[key] or {}
local a = Shot.auto[key]
a.hold, a.locked, a.mode, a.greens, a.bin = net.lead, true, "peak", a.greens or {}, a.bin or S.PeakBin
return a.hold
end
return prevSeedHL(key)
end
-- UNIVERSAL SHOT INTELLIGENCE: a per-animation profile database (Shot ID Scanner + Animation Recognition Engine + Profile
-- Database) built on top of the real per-key data that already flows through every shot (Shot.keyOf/Shot.holdFor/Shot.remoteKey
-- already derive a key from the actual equipped animation, dedup automatically, and already switch profiles automatically
-- when the equipped jumpshot changes - that part needed no new code). What's added here: a persisted record per discovered
-- animation (name, length, times seen, situations seen, first/last seen - the Profile Database), a Confidence and Validation
-- System that watches a locked profile's recent results and flags it for retesting if it starts missing consistently instead
-- of trusting it forever, and explicit handling for animations that can't be identified instead of silently reusing another
-- profile's data.
do
local ShotIntel = {}
JH.ShotIntel = ShotIntel
local ok0, data0 = pcall(function() return HttpService:JSONDecode(S.ShotIntelDB or "") end)
ShotIntel.DB = (ok0 and type(data0) == "table") and data0 or {}
local dbDirty = false
task.spawn(function()
while true do
if dbDirty then
dbDirty = false
local ok, body = pcall(function() return HttpService:JSONEncode(ShotIntel.DB) end)
if ok then S.ShotIntelDB = body saveSoon() end
end
task.wait(5)
end
end)
-- CONFIDENCE AND VALIDATION SYSTEM: per-key ring buffer of recent verdicts, kept in memory only (not persisted, lightweight)
local recent = {}
ShotIntel.lastKey = nil
-- SHOT CLASSIFICATION ENGINE + RELEASE-POINT ANALYSIS + AUTOMATIC SHOT DETECTION feed into the same record below
local function record(info, res, strength)
if not (info and info.key) then return end
local key = info.key
local identified = string.sub(key, 1, 4) ~= "sit:"
local rec = ShotIntel.DB[key]
if not rec then
rec = { id = key, name = Shot.nameFor(key, info.anim), length = (info.track and info.track.Length) or 0,
firstSeen = os.time(), lastSeen = os.time(), timesSeen = 0, sits = {}, ver = 1, identified = identified, needsRetest = false }
ShotIntel.DB[key] = rec
end
rec.lastSeen = os.time()
rec.timesSeen = (rec.timesSeen or 0) + 1
if info.sit then rec.sits[info.sit] = (rec.sits[info.sit] or 0) + 1 end
if not rec.identified and identified then rec.identified = true end
if ShotIntel.lastKey ~= key then
ShotIntel.switched = { from = ShotIntel.lastKey, to = key, t = tick() }
ShotIntel.lastKey = key
end
local idx = info.idx or (res == "green" and 5) or (res == "good" and 4) or (res == "early" and 4 - (strength or 2)) or (res == "late" and 5 + (strength or 2))
if idx then
local buf = recent[key]
if not buf then buf = {} recent[key] = buf end
table.insert(buf, 1, idx)
while #buf > 10 do table.remove(buf) end
local a = Shot.auto and Shot.auto[key]
if a and a.locked and #buf >= 5 then
local offSide = 0
for i = 1, math.min(5, #buf) do if math.abs(buf[i] - 5) >= 2 then offSide = offSide + 1 end end
if offSide >= 3 then
a.locked = false
rec.needsRetest = true
notify("Shot Intelligence", "Timing for " .. tostring(rec.name) .. " started missing consistently - unlocked for retesting.", 4)
elseif rec.needsRetest and offSide == 0 then
rec.needsRetest = false
end
end
end
dbDirty = true
end
local prevLR2 = Shot.learnRemote
function Shot.learnRemote(info, res, strength)
local r = prevLR2(info, res, strength)
pcall(record, info, res, strength)
return r
end
local prevLT2 = Shot.learnTiming
function Shot.learnTiming(info, res, strength)
local r = prevLT2(info, res, strength)
pcall(record, info, res, strength)
return r
end
end
-- SHARED BINDS: a dribble move learned on anyone's copy is pushed to the network and picked up by everyone else who hasn't learned it yet
function JH.onBindLearned(name, args)
if JH.bindSer then
task.spawn(netPut, "bindlib/" .. sanitize(name), { text = JH.bindSer(args), name = name, by = myName, t = os.time() })
end
end
task.spawn(function()
local res = netGet("bindlib")
if type(res) == "table" and JH.bindLib and JH.bindDeser then
local changed = false
for key, rowv in pairs(res) do
if type(rowv) == "table" and type(rowv.text) == "string" then
local realName = type(rowv.name) == "string" and rowv.name or key
if not JH.bindLib[realName] then
local args = JH.bindDeser(rowv.text)
if args then
JH.bindLib[realName] = args
changed = true
end
end
end
end
if changed and JH.bindSaveLib then JH.bindSaveLib() end
end
end)
end
-- LIVE ADAPT, SHARPER: steps shrink the more a jumpshot has actually been seen (so it locks in fast early, then stops wobbling), and one freak result against a steady trend gets a lighter step, not a full swing
do
local prevGainLA = Shot.adaptGain
local dampenKey, dampenUntil = nil, 0
function Shot.adaptGain(key, off)
local g = prevGainLA(key, off)
local a = Shot.auto and Shot.auto[key]
local n = a and a.n or 0
local decay = 1 / (1 + 0.12 * n)
g = g * clamp(decay, 0.2, 1)
if key == dampenKey and tick() < dampenUntil then g = g * 0.4 end
return g
end
local recent = {}
local prevLearnLA = Shot.autoLearn
function Shot.autoLearn(info, res, strength)
if info and info.key and info.idx and not info.manual then
local off = (info.idx == 5 and 0) or (info.idx == 4 and -1) or (info.idx - 5)
local h = recent[info.key] or {}
h[#h + 1] = off
while #h > 3 do table.remove(h, 1) end
recent[info.key] = h
if #h >= 3 then
local sum = 0
for i = 1, #h - 1 do sum = sum + h[i] end
local avg = sum / (#h - 1)
if math.abs(off) >= 3 and math.abs(avg) <= 1 then
dampenKey, dampenUntil = info.key, tick() + 1
end
end
end
return prevLearnLA(info, res, strength)
end
end
UI.syncAuto()
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
if a == "Gathering" and Glide.gatherOk and Glide.gatherOk(c) then pcall(Glide.fire, "gather", "gather step") end
end
task.wait(0.03)
end
end)
task.spawn(function()
while JH.Running do
pcall(Feat.magnetStep)
if UI.lowStat and tick() - (Speed.lowStatT or 0) > 1 then
Speed.lowStatT = tick()
UI.lowStat.Text = Speed.lowStatusText()
end
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
]==]local function b()local c=getgenv and getgenv()or shared or _G;local d=c.JHUB_AUTOEXEC;c.JHUB_AUTOEXEC=nil;if d then if not game:IsLoaded()then game.Loaded:Wait()end;local e,f=pcall(function()return readfile("JHubGlass/settings.json")end)if e and type(f)=="string"and not string.find(f,'"AutoExec":true',1,true)then return end end;for g,h in ipairs({"JHubGlass","JHubV1","JayHubPB"})do local i=c[h]if type(i)=="table"and type(i.Unload)=="function"then pcall(i.Unload)end;c[h]=nil end;local j=game:GetService("Players")local k=game:GetService("RunService")local l=game:GetService("UserInputService")local m=game:GetService("HttpService")local n=game:GetService("TweenService")local o=game:GetService("Lighting")local p=game:GetService("GuiService")local q=game:GetService("TeleportService")local r=game:GetService("MarketplaceService")local s=game:GetService("ReplicatedStorage")local t;pcall(function()t=game:GetService("VirtualInputManager")end)local u=j.LocalPlayer;while not u do task.wait()u=j.LocalPlayer end;local v=Color3.new(1,1,1)local w=Enum.UserInputType.MouseButton1;local x=Enum.UserInputType.Touch;local y=Enum.UserInputType.MouseMovement;local z=Enum.UserInputType.Keyboard;local A=l.TouchEnabled and not l.KeyboardEnabled;local B="v1.86"local C={Connections={},Running=true,Logs={},Start=tick(),FPS=60}c.JHubGlass=C;local function D()return workspace.CurrentCamera end;local function E(F,G)local H=F:Connect(G)table.insert(C.Connections,H)return H end;local function I(J)J=tostring(J)table.insert(C.Logs,1,os.date("%H:%M:%S").."  "..J)if#C.Logs>60 then table.remove(C.Logs)end;if C.RecLog then C.RecLog(J)end;print("[JHub] "..J)end;local function K(L,M,N)if L<M then return M elseif L>N then return N end;return L end;local function O(P)return string.gsub(P or"","^%s*(.-)%s*$","%1")end;local function Q(P)local R={}for S in string.gmatch(P or"","[^%s,]+")do table.insert(R,S)end;return R end;local function T(P,U)for g,V in ipairs(U)do if string.find(P,V,1,true)then return true end end;return false end;local function W(L)return Vector3.new(L.X,0,L.Z)end;local function X(Y,Z)local _=Instance.new(Y)local a0;if Z then for a1,L in pairs(Z)do if a1=="Parent"then a0=L else _[a1]=L end end end;if a0 then _.Parent=a0 end;return _ end;local function a2(a3)local _=a3;while _ and _~=game do if _:IsA("GuiObject")and not _.Visible then return false end;if _:IsA("LayerCollector")then return _.Enabled end;_=_.Parent end;return true end;local function a4()local H=u.Character;if H then return H end;local a5=workspace:FindFirstChild("Characters")return a5 and a5:FindFirstChild(u.Name)end;local function a6()local H=a4()return H and(H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart)end;local function a7()local H=a4()return H and H:FindFirstChildOfClass("Humanoid")end;local function a8()local a9,L=pcall(function()return p:GetGuiInset()end)return a9 and L and L.Y or 0 end;local aa,ab,ac,ad,ae,af,ag,ah,ai,aj,ak,al,am,an={},{},{},{},{},{},{},{},{},{},{},{},{},{}local function ao(ap,J,aq)if string.find(tostring(ap),"^Glide")or string.find(tostring(ap),"^Speed boost")then return end;if aa.notify then aa.notify(ap,J,aq)end end;local ar={WinTrans=0.5,CardTrans=0.78,Hue=212,Sat=0.85,Val=0.85,WinGradient=true,OutlineColor="White",OutlineThick=2,OutlineShine=true,TextColor="White",TextStroke=true,Font="Gotham",Corner=10,UIScale=1,LogoSize=58,LogoOpacity=1,LogoAnim=true,LogoX=-1,LogoY=-1,Blur=false,BlurSize=10,Watermark=true,Notifications=true,Sounds=true,MenuKey="RightShift",Codes="100M 100KLIKES 500KMEMBERS 100KCCUPLS RELEASE SORRYFORBUGS",CodeRemotes=true,AutoGreen=true,AutoCalibrate=true,AutoTiming=true,ShotRelease="Auto",HoldTime=0.55,MaxHold=1.6,CalSpeed=1.0,CalStep=0.035,ShotTimes="",ShotRatio=0,BarPath="",BarProp="",BarAt=0,BarNudge=0,ShotStyle="Hold",AutoExec=false,BallMagnet=false,MagnetMode="Pull to me",MagnetRange=25,Learn=false,PeakLead=0.027,PerfectGreen=false,PerfectGreenPct=100,AutoCal=true,AutoTimes="",Sweep=false,MagnetFrames=1,LogoOn=false,Logo="Owner",MascotOn=false,Mascot="SpongeBob",MaxOverall=false,MaxCoins=false,MaxBadges=false,MeterAim=false,MeterTarget=1.0,MeterBin=0.05,Lightning=true,BoltCount=6,BoltSpeed=1,BoltThick=2,BoltBright=0.9,BoltColor="White + Yellow",BgMove=true,BgGlow=0.5,BgOrbs=true,AccentMode="Gold",OutlineSpeed=1,LogoStyle="J bolt H",LogoBg=true,Preset="Lightning Gold",PacketOn=true,PacketMul=1,MovingOffset=0,SprintOffset=0,PingComp=0,Humanize=0,Nudge=0,GreenSound=true,HookShootButton=true,ShootButtonPath="",ReleaseMethod="Both",FireClick=true,ManualAssist=true,ShootKey="E",SprintKey="LeftShift",BackupButton=false,BackupMethod="touch",BackupInset=false,DribbleGlide=false,DribbleGlidePower=30,DribbleGlideTime=0.45,GlideSpeed=1,ShotGlide=false,ShotGlidePower=22,ShotGlideTime=0.45,GatherGlide=false,GatherGlidePower=26,GatherGlideTime=0.45,DribbleGlideSpeed=1,ShotGlideSpeed=1,GatherGlideSpeed=1,GfxLow=false,GfxEffects=false,GfxTextures=false,GfxShadows=false,GfxPost=false,GfxHideOthers=false,GfxCull=false,GfxCullDist=250,GfxBoost=false,GfxFpsCap=0,PingStab=false,PingWindow=3,FinalAdj="",ShotGlideMethod="GameVel",ShotGlideWhen="After release",NoStun=false,StunIds="",HoopMarks="",LagSync=true,LagK=2,PrecFit=true,PeakBin=0.014,AdaptPlus=true,GreenMax=true,AGHuman=true,AGHumanAmt=50,LogoIds="",LookUser="",AllJumpers=true,GLead=0,GLeadN=0,ImportTimes="",FirstShot=false,PFLead=0,PFLeadN=0,AccentTone="Rainbow",FadeNudge=8,MagnetDelay=120,AutoAdaptAll=true,InstantGreen=true,GlideShotSafe=true,LabOn=true,FamLead="",SmartSteps=true,ContestShow=false,GuardSpeed=0,UltraOn=false,GreenSoundId="",GreenSoundVol=0.6,CtrlSpyOn=false,GuardSpyOn=false,HardLock="",GuardKey="",RGuardOn=false,AGUnlocked=false,LockedUnlocked=false,OwnerUnlocked=false,ShotIntelDB="",AGMistakes=false,AGMistakeAmt=15,ABRecheck=true,ASteal=false,ASRange=5,ASChance=60,ASReact=0.15,ASKey="",BindLib="",AGOnlyBall=true,BindMove1="None",BindMove2="None",BindMove3="None",BindMove4="None",BindMove5="None",BindMove6="None",BindKey1="",BindArgs1="",BindKey2="",BindArgs2="",BindKey3="",BindArgs3="",BindKey4="",BindArgs4="",BindKey5="",BindArgs5="",BindKey6="",BindArgs6="",LowFix=true,LowBoostPct=25,LowGlidePct=60,LowLevel=3,AG=false,AGTarget="Ball handler",AGDist=4,AGReact=0.08,AGPredict=0.18,AGRange=45,AGLock=false,AGFace=true,AGSprint=true,AGHoldToUse=false,WalkAnimId="",GuardAnimId="",AB=false,ABRange=12,ABDelay=0.1,ABKey="Space",ABChance=100,ABChase=true,AR=false,ARSpeed=1,ARReact=0.18,ARRange=45,ARJump=true,ARMagnet=true,ARMagRange=4,ARMarker=false,AP=false,APBuild="Small",APPostScore=true,APAllAround=true,APOpenDist=6,APRange=24,APThree=true,APDrive=true,APLayups=true,APSprint=true,APMoves=true,APShotDelay=0.8,APDefend=true,APRebound=true,APAntiAfk=true,APPause=true,APStaminaMin=20,APHoop="Nearest",APPostRange=8,APSpot=22,APSpeed=1,APTeam="By team",GlideFade=60,GlideSmart=true,GlideStopAtWalls=false,GlideNeedBall=true,GlideMethod="Auto",DribbleKeys="Z C X V",GatherKeys="",DribbleBtnPaths="",GatherBtnPaths="",AnimDribble="",AnimGather="",AnimShot="",SpeedOn=false,SpeedAdd=4,SpeedMult=1,BallSpeedOn=false,BallAdd=4,BallMult=1,RunOn=false,RunAdd=4,RunMult=1,RecShots=false,RunDetect="Auto",SettingsVer=0,RecOn=false,SpeedChannel="Auto",SpeedCap=40,AntiRubber=false,ForceBall=false,HoldDist=6,BallName="auto",AutoSprint=false,InfStamina=false}local as={}for a1,L in pairs(ar)do as[a1]=L end;local at={root="JHubGlass"}at.file=at.root.."/settings.json"at.ok=type(writefile)=="function"and type(readfile)=="function"function at.ensure()if type(makefolder)~="function"or type(isfolder)~="function"then return end;pcall(function()if not isfolder(at.root)then makefolder(at.root)end end)end;function at.write(au,av)if not at.ok or not av then return end;at.ensure()pcall(writefile,au,av)end;function at.read(au)if not at.ok then return nil end;local a9,aw=pcall(function()if type(isfile)=="function"and not isfile(au)then return nil end;return readfile(au)end)if a9 then return aw end;return nil end;local function ax(ay)if not ay or ay==""then return nil end;local a9,aw=pcall(function()return m:JSONDecode(ay)end)if a9 then return aw end;return nil end;local function az(aA)if type(aA)~="table"then return end;for a1,L in pairs(aA)do if ar[a1]~=nil and type(ar[a1])==type(L)then ar[a1]=L end end end;az(ax(at.read(at.file)))if ar.SettingsVer<3 then for g,a1 in ipairs({"DribbleGlidePower","DribbleGlideTime","ShotGlidePower","ShotGlideTime","GatherGlidePower","GatherGlideTime","SpeedChannel","GlideMethod","GlideStopAtWalls","SpeedAdd","BallAdd"})do ar[a1]=as[a1]end end;if ar.SettingsVer<4 then for g,a1 in ipairs({"ShootButtonPath","BarPath","BarProp","BarAt","ShotTimes","ShotRatio","PacketMul","PacketOn","HoldTime","SpeedChannel","GlideMethod"})do ar[a1]=as[a1]end end;if ar.SettingsVer<5 then ar.InfStamina,ar.AutoSprint=false,false end;if ar.SettingsVer<6 then ar.SpeedAdd,ar.RunAdd,ar.BallAdd,ar.ForceBall=4,4,4,false end;if ar.SettingsVer<7 then ar.DribbleGlidePower,ar.DribbleGlideTime,ar.ShotGlidePower,ar.ShotGlideTime=10,0.35,6,0.4;ar.GatherGlidePower,ar.GatherGlideTime,ar.GlideSpeed,ar.GlideNeedBall=10,0.4,1,true end;if ar.SettingsVer<8 then ar.DribbleGlidePower,ar.ShotGlidePower,ar.GatherGlidePower,ar.GlideSpeed,ar.AntiRubber=18,12,16,1,false end;if ar.SettingsVer<9 then ar.DribbleGlidePower,ar.DribbleGlideTime,ar.ShotGlidePower,ar.ShotGlideTime=30,0.45,22,0.45;ar.GatherGlidePower,ar.GatherGlideTime=26,0.45 end;if ar.SettingsVer<10 then ar.MeterTarget,ar.MeterBin,ar.MeterAim=1.0,0.05,false end;if ar.SettingsVer<13 then ar.MeterAim=false;local i={}for h,aB in string.gmatch(ar.ShotTimes or"","(%S+)=([%d%.]+)")do if h~="15851912457+15851919155"and h~="15851912457+15851919155+17285155256"then i[#i+1]=h.."="..aB end end;ar.ShotTimes=table.concat(i," ")local aC="r:15851912457+15851919155=1.327 r:15851912457+15851919155+17285155256=1.327 16205020756=0.343 16246923753=0.335 118403922040694=0.315 15997667717=0.365 16143612725=0.355 16143619816=0.355 84063020888988=0.335 138932071140330=0.322 111074210919383=0.414 71484695722621=0.414"local aD={}for h,aB in string.gmatch(ar.ShotTimes or"","(%S+)=([%d%.]+)")do aD[h]=aB end;for h,aB in string.gmatch(aC,"(%S+)=([%d%.]+)")do aD[h]=aB end;local aE={}for h,aB in pairs(aD)do aE[#aE+1]=h.."="..aB end;table.sort(aE)ar.ShotTimes=table.concat(aE," ")end;ar.AutoCal=ar.AutoGreen~=false;ar.Learn=ar.AutoCal;if ar.PerfectGreen==nil then ar.PerfectGreen=false end;if ar.PeakLead==nil then ar.PeakLead=0.027 end;if ar.LowFix==nil then ar.LowFix=true end;if ar.LowBoostPct==nil then ar.LowBoostPct=25 end;if ar.LowGlidePct==nil then ar.LowGlidePct=60 end;if ar.LowLevel==nil then ar.LowLevel=3 end;if ar.PerfectGreenPct==nil then ar.PerfectGreenPct=100 end;if ar.AutoTimes==nil then ar.AutoTimes=""end;if ar.SettingsVer<14 then if ar.MagnetMode=="Pull the ball"then ar.MagnetMode="Pull to me"end end;if ar.SettingsVer<15 then ar.Learn=false end;if ar.SettingsVer<28 then ar.Hue,ar.Sat,ar.Val,ar.WinTrans,ar.CardTrans,ar.OutlineColor,ar.OutlineThick,ar.AccentMode=226,0.8,0.14,0.08,0.55,"Gold",2.5,"Gold"local aC="la:15851912457+15851919155=0.357 lb:15851912457+15851919155=0.000 la:15851912457+15851919155+17285155256=0.357 lb:15851912457+15851919155+17285155256=0.000 16246923753=0.328 16205020756=0.328 16104888271=0.328 16104888271+17285155256=0.328 16205020756+17285155256=0.328 118403922040694=0.290 15997667717=0.347 16143619816=0.350 16143612725=0.350 84063020888988=0.322 138932071140330=0.316 111074210919383=0.357 71484695722621=0.311 77401448272074=0.329 128777513307709+77401448272074=0.329"local aD={}for h,aB in string.gmatch(ar.ShotTimes or"","(%S+)=([%d%.]+)")do if string.sub(h,1,2)~="r:"then aD[h]=aB end end;for h,aB in string.gmatch(aC,"(%S+)=([%d%.]+)")do aD[h]=aB end;local aE={}for h,aB in pairs(aD)do aE[#aE+1]=h.."="..aB end;table.sort(aE)ar.ShotTimes=table.concat(aE," ")end;if ar.SettingsVer<29 then ar.Codes=as.Codes end;if ar.SettingsVer<31 then ar.LagSync,ar.PrecFit,ar.AdaptPlus=false,false,false end;if ar.SettingsVer<32 then ar.LagSync,ar.PrecFit,ar.AdaptPlus,ar.GreenMax,ar.Sweep=true,true,true,true,false end;ar.Sweep=false;if ar.SettingsVer<33 then ar.FirstShot=false end;if ar.SettingsVer<34 then ar.CardTrans=0.4 end;if ar.SettingsVer<35 then ar.AutoTimes=string.gsub(ar.AutoTimes or"","(%a):(%S-)=([%d%.]+)",function(aF,h,aB)if aF=="l"or aF=="p"then return string.format("%s:%s=%.4f",aF,h,math.max(0,(tonumber(aB)or 0)-0.008))end;return aF..":"..h.."="..aB end)end;if ar.SettingsVer<36 then ar.AccentTone,ar.ARSpeed,ar.ARReact,ar.ARRange,ar.ARMagRange="Rainbow",1,0.18,45,4;if ar.MagnetRange>25 then ar.MagnetRange=25 end end;ar.SettingsVer=36;as.SettingsVer=36;as.ShotTimes="la:15851912457+15851919155=0.357 lb:15851912457+15851919155=0.000 la:15851912457+15851919155+17285155256=0.357 lb:15851912457+15851919155+17285155256=0.000 16246923753=0.328 16205020756=0.328 16104888271=0.328 16104888271+17285155256=0.328 16205020756+17285155256=0.328 118403922040694=0.290 15997667717=0.347 16143619816=0.350 16143612725=0.350 84063020888988=0.322 138932071140330=0.316 111074210919383=0.357 71484695722621=0.311 77401448272074=0.329 128777513307709+77401448272074=0.329"ar.ShotTimes=ar.ShotTimes;ar.RecOn=false;ar.RecShots=false;local function aG()local a9,av=pcall(function()return m:JSONEncode(ar)end)if a9 then at.write(at.file,av)end end;local aH=false;local function aI()if aH then return end;aH=true;task.delay(1.5,function()aH=false;aG()end)end;local aJ={White=Color3.new(1,1,1),Ice=Color3.fromRGB(215,240,255),Gold=Color3.fromRGB(255,236,170),Mint=Color3.fromRGB(205,255,232)}local aK={White=Color3.new(1,1,1),Cyan=Color3.fromRGB(120,235,255),Pink=Color3.fromRGB(255,150,220),Gold=Color3.fromRGB(255,225,120),Lime=Color3.fromRGB(170,255,140)}local aL={"White","Cyan","Pink","Gold","Lime","Rainbow"}local aM={"White","Ice","Gold","Mint"}local aN={Gotham={"Gotham","GothamBold"},Montserrat={"Montserrat","MontserratBold"},SourceSans={"SourceSans","SourceSansBold"},Ubuntu={"Ubuntu","Ubuntu"},Oswald={"Oswald","Oswald"},Code={"Code","Code"},FredokaOne={"FredokaOne","FredokaOne"}}local aO={"Gotham","Montserrat","SourceSans","Ubuntu","Oswald","Code","FredokaOne"}local aP={}local function aQ()local aR=ar.Hue%360/360;aP.Glass=Color3.fromHSV(aR,ar.Sat,ar.Val)aP.Sheen=Color3.fromHSV(aR,math.max(ar.Sat-0.55,0),1)aP.Card=Color3.fromHSV(aR,math.max(ar.Sat-0.1,0),math.min(ar.Val+0.1,1))aP.Elem=Color3.fromHSV(aR,ar.Sat,math.max(ar.Val-0.3,0.08))aP.Stroke=Color3.fromHSV(aR,0.9,0.18)aP.Text=aJ[ar.TextColor]or v;aP.Sub=aP.Text:Lerp(aP.Glass,0.28)aP.Outline=aK[ar.OutlineColor]or v;aP.AccentA=Color3.fromHSV(aR,0.2,1)aP.AccentB=Color3.fromHSV((ar.Hue-28)%360/360,0.75,1)if ar.AccentMode~="Match hue"then aP.AccentA=Color3.fromRGB(255,246,180)aP.AccentB=Color3.fromRGB(255,192,28)end end;aQ()local aS=X("ScreenGui",{Name="JHubGlass",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999})local aT=pcall(function()aS.Parent=gethui and gethui()or game:GetService("CoreGui")end)if not aT or not aS.Parent then aS.Parent=u:WaitForChild("PlayerGui")end;local function aU(aV,aW)if not ar.Sounds then return end;pcall(function()local P=Instance.new("Sound")P.SoundId=aV;P.Volume=aW or 0.5;P.Parent=game:GetService("SoundService")P:Play()task.delay(3,function()P:Destroy()end)end)end;local aX="rbxasset://sounds/electronicpingshort.wav"function ab.get(aY)local G=request or http_request or syn and syn.request or http and http.request;if type(G)=="function"then local a9,aZ=pcall(G,{Url=aY,Method="GET"})if a9 and type(aZ)=="table"and aZ.Body then return aZ.Body end end;local a9,a_=pcall(function()return game:HttpGet(aY)end)if a9 then return a_ end;return nil end;function ab.servers(b0)local b1,b2={},nil;for g=1,b0 do local aY=string.format("https://games.roblox.com/v1/games/%.0f/servers/Public?sortOrder=Asc&limit=100%s",game.PlaceId,b2 and"&cursor="..b2 or"")local aA=ax(ab.get(aY))if not aA or type(aA.data)~="table"then break end;for g,P in ipairs(aA.data)do table.insert(b1,P)end;b2=aA.nextPageCursor;if type(b2)~="string"then break end end;return b1 end;function ab.rejoin()ao("Rejoin","Rejoining this server...",2)if#j:GetPlayers()<=1 then q:Teleport(game.PlaceId,u)else q:TeleportToPlaceInstance(game.PlaceId,game.JobId,u)end end;function ab.hop(b3)ao("Servers","Looking for a server...",2)local b4=ab.servers(3)if#b4==0 then ao("Servers","Couldn't load the server list. Your executor may be blocking web requests.",4)return end;local b5={}for g,P in ipairs(b4)do if P.id~=game.JobId and(P.playing or 0)<(P.maxPlayers or 0)then table.insert(b5,P)end end;if#b5==0 then ao("Servers","No other server found. Try again in a moment.",3)return end;local b6;if b3=="lower"then table.sort(b5,function(M,N)return(M.playing or 0)<(N.playing or 0)end)for g,P in ipairs(b5)do if(P.playing or 0)>=1 then b6=P;break end end;b6=b6 or b5[1]if(b6.playing or 0)>=#j:GetPlayers()then ao("Servers","No emptier server than this one right now.",3)return end else local b7={}for g,P in ipairs(b5)do if(P.playing or 0)>=2 then table.insert(b7,P)end end;local b8=#b7>0 and b7 or b5;b6=b8[math.random(1,#b8)]end;ao("Servers",string.format("Joining a server with %d players...",math.floor(b6.playing or 0)),3)q:TeleportToPlaceInstance(game.PlaceId,b6.id,u)end;function ab.redeemViaGui(b4)local b9=u:FindFirstChild("PlayerGui")if not b9 then return false end;local ba;for g,bb in ipairs(b9:GetDescendants())do if bb:IsA("TextBox")then local bc=string.lower(bb.Name.." "..bb.PlaceholderText.." "..(bb.Parent and bb.Parent.Name or""))if string.find(bc,"code",1,true)then ba=bb;break end end end;if not ba then return false end;local bd;local be=ba.Parent and ba.Parent.Parent or ba.Parent;for g,bb in ipairs(be:GetDescendants())do if bb:IsA("GuiButton")then local bc=string.lower(bb.Name.." "..(bb:IsA("TextButton")and bb.Text or""))if T(bc,{"redeem","submit","enter","claim","confirm"})then bd=bb;break end end end;for g,bf in ipairs(b4)do ba.Text=bf;if getconnections then local a9,bg=pcall(getconnections,ba.FocusLost)if a9 and bg then for g,H in ipairs(bg)do pcall(function()if H.Function then H.Function(true)else H:Fire(true)end end)end end end;if bd then ac.fireGui(bd,true,true)ac.fireGui(bd,false,true)end;I("Code (menu): "..bf)task.wait(1.3)end;return true end;function ab.redeemViaRemotes(b4)local bh={}for g,bb in ipairs(s:GetDescendants())do if(bb:IsA("RemoteEvent")or bb:IsA("RemoteFunction"))and T(string.lower(bb.Name),{"code","redeem","promo"})then table.insert(bh,bb)end end;if#bh==0 then return false end;for g,bf in ipairs(b4)do for g,bi in ipairs(bh)do if bi:IsA("RemoteFunction")then task.spawn(function()local a9,aZ=pcall(function()return bi:InvokeServer(bf)end)I("Code "..bf.." via "..bi.Name..": "..tostring(a9 and aZ or"error"))end)else pcall(function()bi:FireServer(bf)end)I("Code "..bf.." sent via "..bi.Name)end end;task.wait(1.2)end;return true end;function ab.redeemAll()local b4=Q(ar.Codes)if#b4==0 then ao("Codes","The code list is empty.",2)return end;ao("Codes","Redeeming "..#b4 .." codes...",2)local bj=ab.redeemViaGui(b4)if not bj and ar.CodeRemotes then bj=ab.redeemViaRemotes(b4)end;if bj then ao("Codes","Finished. Check your coins and rewards.",3)else ao("Codes","Open the game's Codes menu once, then press Redeem all codes again.",4)end end;ac.held={}ac.cache={}function ac.keyCode(bk)if type(bk)~="string"or bk==""then return nil end;local a9,a1=pcall(function()return Enum.KeyCode[bk]end)if a9 and a1 then return a1 end;a9,a1=pcall(function()return Enum.KeyCode[string.upper(bk)]end)if a9 and a1 then return a1 end;return nil end;function ac.sendKey(bk,bl)if not t or not bk or bk==""then return false end;local a1=ac.keyCode(bk)if not a1 then return false end;return pcall(function()t:SendKeyEvent(bl,a1,false,game)end)end;function ac.pathOf(a3)local b9=u:FindFirstChild("PlayerGui")local aE={}local _=a3;while _ and _~=b9 and _~=game do table.insert(aE,1,_.Name)_=_.Parent end;return table.concat(aE,"/")end;function ac.resolve(au)local _=u:FindFirstChild("PlayerGui")if not _ or au==""then return nil end;for bk in string.gmatch(au,"[^/]+")do _=_:FindFirstChild(bk)if not _ then return nil end end;return _ end;local bm={Shoot={"shoot","shot"},Sprint={"sprint","run"},Guard={"guard"}}function ac.findButton(bn)if bn=="Shoot"and ar.ShootButtonPath~=""then local N=ac.resolve(ar.ShootButtonPath)if N then return N end end;local bo=ac.cache[bn]if bo and tick()-bo.t<1.5 and(not bo.obj or bo.obj.Parent)then return bo.obj end;local b9=u:FindFirstChild("PlayerGui")local U=bm[bn]local bp;if b9 and U then for g,bb in ipairs(b9:GetDescendants())do if bb:IsA("GuiButton")and not bb:IsDescendantOf(aS)and a2(bb)then local bc=string.lower(bb.Name.." "..(bb:IsA("TextButton")and bb.Text or""))if T(bc,U)then bp=bb;break end end end end;ac.cache[bn]={obj=bp,t=tick()}return bp end;function ac.fireGui(a3,bl,bq)local br=a3.AbsolutePosition+a3.AbsoluteSize/2;local bs={UserInputType=x,KeyCode=Enum.KeyCode.Unknown,UserInputState=bl and Enum.UserInputState.Begin or Enum.UserInputState.End,Position=Vector3.new(br.X,br.Y,0),Delta=Vector3.new()}local bt=false;local bu={}if bl then table.insert(bu,{a3.InputBegan,bs})if a3:IsA("GuiButton")then table.insert(bu,{a3.MouseButton1Down,br.X,br.Y})end else table.insert(bu,{a3.InputEnded,bs})if a3:IsA("GuiButton")then table.insert(bu,{a3.MouseButton1Up,br.X,br.Y})if bq then table.insert(bu,{a3.MouseButton1Click})table.insert(bu,{a3.Activated,bs,1})end end end;if getconnections then for g,P in ipairs(bu)do local a9,bg=pcall(getconnections,P[1])if a9 and bg then for g,H in ipairs(bg)do local bv=pcall(function()if H.Function then H.Function(P[2],P[3])else H:Fire(P[2],P[3])end end)bt=bt or bv end end end end;if not bt and firesignal then for g,P in ipairs(bu)do pcall(firesignal,P[1],P[2],P[3])end;bt=true end;return bt end;function ac.action(bn,bl)local h=ar[bn.."Key"]local bw=false;if h then bw=ac.sendKey(h,bl)or bw end;if l.TouchEnabled then local bd=bl and ac.findButton(bn)or ac.held[bn]if bd then bw=ac.fireGui(bd,bl,bn~="Shoot"or ar.FireClick)or bw;ac.held[bn]=bl and bd or nil end end;return bw end;function ac.hits(a3,bx)local by,bz=a3.AbsolutePosition,a3.AbsoluteSize;local bA=a8()local bB=4;for g,bC in ipairs({bx.Y,bx.Y+bA,bx.Y-bA})do if bx.X>=by.X-bB and bx.X<=by.X+bz.X+bB and bC>=by.Y-bB and bC<=by.Y+bz.Y+bB then return true end end;return false end;function ac.topButtonAt(bx)local b9=u:FindFirstChild("PlayerGui")if not b9 then return nil end;local bA=a8()for g,bC in ipairs({bx.Y,bx.Y-bA})do local a9,b4=pcall(function()return b9:GetGuiObjectsAtPosition(bx.X,bC)end)if a9 and b4 then for g,a3 in ipairs(b4)do if a3:IsA("GuiButton")and not a3:IsDescendantOf(aS)then return a3 end end end end;return nil end;function ac.btnText(N)local S=""if N:IsA("TextButton")then S=N.Text end;if S==""then local bD=N:FindFirstChildWhichIsA("TextLabel",true)if bD then S=bD.Text end end;return string.upper(O(S))end;ac.gcache={}function ac.glideButtons(aF)local H=ac.gcache[aF]if H and tick()-H.t<2 then return H.list end;local b4={}local bE={}local function bF(_)if not bE[_]then bE[_]=true;table.insert(b4,_)end end;local bG={}for g,a1 in ipairs(Q(aF=="dribble"and ar.DribbleKeys or ar.GatherKeys))do bG[string.upper(a1)]=true end;local b9=u:FindFirstChild("PlayerGui")if b9 and next(bG)then for g,bb in ipairs(b9:GetDescendants())do if not bb:IsDescendantOf(aS)then if bb:IsA("GuiButton")then if bG[ac.btnText(bb)]then bF(bb)end elseif bb:IsA("TextLabel")and bG[string.upper(O(bb.Text))]and a2(bb)then local bH=bb;local bI=bb.Parent;if bI and bI:IsA("GuiObject")and bI.AbsoluteSize.X<=220 and bI.AbsoluteSize.Y<=220 and bI.AbsoluteSize.X>=bb.AbsoluteSize.X and bI.AbsoluteSize.Y>=bb.AbsoluteSize.Y then bH=bI end;bF(bH)end end end end;ac.gcache[aF]={t=tick(),list=b4}return b4 end;ad.parts={}ad.holding=false;ad.source="starting"ad.nearest=nil;function ad.score(_,bc)if ar.BallName~=""and string.lower(ar.BallName)~="auto"then return bc==string.lower(ar.BallName)and 4 or 0 end;if bc=="ball"or bc=="basketball"then return 3 end;if string.find(bc,"basketball",1,true)then return 2 end;if string.find(bc,"ball",1,true)and not T(bc,{"rack","zone","region","spawn","hoop","rim","net","stand"})then return 1 end;if _:IsA("Part")and _.Shape==Enum.PartType.Ball then local bJ=math.max(_.Size.X,_.Size.Y,_.Size.Z)if bJ>=0.8 and bJ<=3.2 then return 1 end end;return 0 end;function ad.partOf(_)if _:IsA("BasePart")then return _ end;if _:IsA("Tool")then return _:FindFirstChild("Handle")end;if _:IsA("Model")then return _.PrimaryPart or _:FindFirstChildWhichIsA("BasePart")end;return nil end;function ad.consider(_)if not(_:IsA("BasePart")or _:IsA("Tool")or _:IsA("Model"))then return end;local bc=string.lower(_.Name)if ad.score(_,bc)>0 then local bI=ad.partOf(_)if bI then ad.parts[bI]=true end end end;function ad.rescan()ad.parts={}for g,bb in ipairs(workspace:GetDescendants())do pcall(ad.consider,bb)end end;function ad.count()local bc=0;for g in pairs(ad.parts)do bc=bc+1 end;return bc end;function ad.check()if ar.ForceBall then return true,"forced on"end;local H,aw=a4(),a6()if not H or not aw then return false,"no character"end;local bK=H:FindFirstChild("Attributes")if bK then local bL=bK:FindFirstChild("Basketball")if bL and bL.Value~=nil then return true,"game ball value"end;return false,"no ball value"end;for g,bM in ipairs({H,u})do for a1,L in pairs(bM:GetAttributes())do local bc=string.lower(a1)if T(bc,{"ball","possess","dribbl"})and(L==true or type(L)=="string"and L~=""or type(L)=="number"and L>0)then return true,"attribute "..a1 end end end;for g,bN in ipairs(H:GetChildren())do if bN:IsA("Tool")and string.find(string.lower(bN.Name),"ball",1,true)then return true,"tool "..bN.Name end end;local bO,bP;for bI in pairs(ad.parts)do if bI.Parent and bI:IsDescendantOf(workspace)then if bI:IsDescendantOf(H)then return true,"ball in character"end;local bb=(bI.Position-aw.Position).Magnitude;if not bP or bb<bP then bO,bP=bI,bb end end end;ad.nearest=bO;if bO and bP<=ar.HoldDist then local bQ=true;for g,bR in ipairs(j:GetPlayers())do if bR~=u and bR.Character then local bS=bR.Character:FindFirstChild("HumanoidRootPart")if bS and(bS.Position-bO.Position).Magnitude<bP then bQ=false;break end end end;if bQ then return true,string.format("ball %.1f studs away",bP)end end;if ah.dribbling()then return true,"dribble animation"end;if tick()-(ah.lastDribble or 0)<1.5 then return true,"dribble move"end;if bO then return false,string.format("ball %d studs away",math.floor(bP))end;return false,"no ball found"end;am.vel=Vector3.new(0,0,0)am.gameDir,am.gameDirT=nil,nil;function am.body()local bI=workspace:FindFirstChild("ProxyCharacter")if bI and bI:IsA("BasePart")then return bI end;return a6()end;am.remote=nil;function am.gameIntent()local bb,S=am.gameDir,am.gameDirT;if not bb then return nil end;local bT=Vector3.new(bb.X,0,bb.Z)if bT.Magnitude<0.05 then return Vector3.new(0,0,0)end;if tick()-S>0.8 then return Vector3.new(0,0,0)end;return bT.Magnitude>1 and bT.Unit or bT end;function am.findRemote()local aw=am.remote;if aw and aw.Parent then return aw end;am.remote=nil;for g,bb in ipairs(s:GetDescendants())do if bb:IsA("RemoteEvent")and bb.Name=="MoveDirection"then am.remote=bb;break end end;return am.remote end;function am.send(bU)local aw=am.findRemote()if not aw then return false end;am.selfFire=true;local a9=pcall(function()aw:FireServer(bU)end)am.selfFire=false;return a9 end;function am.outScale()local P=ai.inputScale or 1;local bV=ag.input;if bV and not bV.paused and tick()<bV.untilT and bV.scale>P then P=bV.scale end;return P end;am.GATHER_MOVES={"stepback","step back","euro","hop","gather"}aj.magnetT=0;function aj.findBall()local aw=am.body()local bO,bP;local a5=workspace:FindFirstChild("Basketballs")if a5 and aw then for g,bb in ipairs(a5:GetDescendants())do if bb:IsA("BasePart")then local bW=(bb.Position-aw.Position).Magnitude;if not bP or bW<bP then bO,bP=bb,bW end end end end;if not bO and ad.nearest and ad.nearest.Parent and aw then bO,bP=ad.nearest,(ad.nearest.Position-aw.Position).Magnitude end;return bO,bP end;function aj.ballLoose()local a5=workspace:FindFirstChild("Characters")if not a5 then return true end;for g,H in ipairs(a5:GetChildren())do local bK=H:FindFirstChild("Attributes")local bL=bK and bK:FindFirstChild("Basketball")if bL and bL.Value~=nil then return false end end;return true end;function aj.getBall(bX)local aw=am.body()local N,bW=aj.findBall()if not aw or not N then return false end;local bT=Vector3.new(aw.Position.X-N.Position.X,0,aw.Position.Z-N.Position.Z)if ar.MagnetMode~="Go to the ball"then if not aj.hop(N)then return false end else if bT.Magnitude<0.1 then bT=Vector3.new(0,0,1)end;local bY=Vector3.new(N.Position.X,aw.Position.Y,N.Position.Z)+bT.Unit*2.5;aw.CFrame=aw.CFrame+bY-aw.Position;am.sync(aw)end;I(string.format("Ball magnet: %s (%.0f studs away)",ar.MagnetMode,bW or 0))return true end;function aj.magnetStep()if not ar.BallMagnet then return end;local bZ=tick()if bZ-aj.magnetT<0.4 or ad.holding then return end;if bZ-ae.releasedT<1.2 then return end;local H=a4()if H and H:GetAttribute("Action")=="Shooting"then return end;local aw=am.body()local N,bW=aj.findBall()if not aw or not N or not bW or bW<4 or bW>ar.MagnetRange then return end;if not aj.ballLoose()then return end;aj.magnetT=bZ;aj.getBall()end;function am.playerModule()if am.pm==nil then am.pm=false;pcall(function()local b_=u:FindFirstChild("PlayerScripts")local c0=b_ and b_:FindFirstChild("Aero")local c1=c0 and c0:FindFirstChild("Controllers")local bJ=c1 and c1:FindFirstChild("Player")if bJ then am.pm=require(bJ)end end)end;return am.pm or nil end;function am.gameVel()local c2=am.playerModule()if not c2 then return nil end;local a9,L=pcall(function()return c2.Character.Movement.CFVelocity end)if a9 and typeof(L)=="Vector3"then return Vector3.new(L.X,0,L.Z)end;return nil end;function am.sync(aw)local c2=am.playerModule()if not c2 then return end;pcall(function()local bN=c2.Character;if bN and bN.LastCFrame~=nil then bN.LastCFrame=aw.CFrame end end)end;function am.moveWhere(c3)local L=am.gameVel()if L and L.Magnitude>(c3 or 1.5)then return L end;return am.moveDir()end;function am.onDribble(c4)ah.lastDribble=tick()local h=tostring(c4[1])local c5=a4()local c6=c5 and c5:GetAttribute("ServerVelocity")local c7=c5 and c5:GetAttribute("LastDribblePackage")local c8=am.gameVel()or Vector3.new(0,0,0)local c9=tick()task.spawn(function()while C.Running and tick()-c9<0.4 do k.Heartbeat:Wait()local ca=a4()local cb=am.gameVel()if cb and(cb-c8).Magnitude>2.5 then break end;if ca and(ca:GetAttribute("ServerVelocity")~=c6 or ca:GetAttribute("LastDribblePackage")~=c7)then break end end;if not C.Running then return end;local H=a4()local cc=H and H:GetAttribute("LastDribblePackage")local bk=type(cc)=="string"and string.lower(cc)or""local cd=am.moveWhere(1.5)if not cd and typeof(c4[3])=="Vector3"and Vector3.new(c4[3].X,0,c4[3].Z).Magnitude>0.1 then cd=Vector3.new(c4[3].X,0,c4[3].Z)end;if T(bk,am.GATHER_MOVES)then if not cd and(string.find(bk,"step back",1,true)or string.find(bk,"stepback",1,true))then local a_=am.body()if a_ then cd=-Vector3.new(a_.CFrame.LookVector.X,0,a_.CFrame.LookVector.Z)end end;ag.fire("gather","step back move "..bk,cd)else ag.fire("dribble","dribble move "..(bk~=""and bk or h),cd)end end)end;function am.moveDir()local H=a4()local ce=H and H:GetAttribute("ServerVelocity")if typeof(ce)=="Vector3"then local a5=Vector3.new(ce.X,0,ce.Z)if a5.Magnitude>1.5 then return a5 end end;return nil end;function am.watchShot(cf)task.spawn(function()local c9=tick()while tick()-c9<0.5 and ae.meterT<cf-0.05 do k.Heartbeat:Wait()end;if ae.meterT<cf-0.05 then return end;local c5=a4()local c6=c5 and c5:GetAttribute("ServerVelocity")local c8=am.gameVel()or Vector3.new(0,0,0)local cg=tick()while C.Running and tick()-cg<0.3 do k.Heartbeat:Wait()local cb=am.gameVel()local ca=a4()if cb and(cb-c8).Magnitude>2 then break end;if ca and ca:GetAttribute("ServerVelocity")~=c6 then break end end;local cd=am.moveWhere(1.5)ag.fire("shot","shot",cd)end)end;function am.controls()if am.ctl==nil then am.ctl=false;pcall(function()local b_=u:FindFirstChild("PlayerScripts")local c2=b_ and b_:FindFirstChild("PlayerModule")if c2 then am.ctl=require(c2):GetControls()end end)end;return am.ctl or nil end;function am.intent(aR,aw)local bV=am.gameIntent()if bV then return bV,"game"end;local ch=W(aR.MoveDirection)if ch.Magnitude>0.05 then return ch,"humanoid"end;local c1=am.controls()if c1 then local a9,ci=pcall(function()return c1:GetMoveVector()end)if a9 and ci and(math.abs(ci.X)>0.05 or math.abs(ci.Z)>0.05)then local cj=W(D().CFrame:VectorToWorldSpace(Vector3.new(ci.X,0,ci.Z)))local ck=math.min(1,math.sqrt(ci.X*ci.X+ci.Z*ci.Z))if cj.Magnitude>0.01 then return cj.Unit*ck,"controls"end end;return Vector3.new(0,0,0),"none"end;local cl=W(aw.AssemblyLinearVelocity)if cl.Magnitude>4 then return cl.Unit,"velocity"end;return Vector3.new(0,0,0),"none"end;local cm={"shoot","shot","jumper","fade","three","release","layup","dunk","alley","stepback","step back","floater"}local cn={"dribble","cross","hesi","behind","between","spin","stepback","step back","shammgod","snatch","escape","jab"}local co={"gather","layup","euro","dunk","floater","hop","finish"}local cp={dribble="AnimDribble",gather="AnimGather",shot="AnimShot"}ah.learnKind=nil;ah.learnUntil=0;ah.learned=0;ah.loops={}ah.seen={}ah.animator=nil;function ah.name(cq)local M=cq.Animation;return string.lower((cq.Name or"").." "..(M and M.Name or"").." "..(M and M.AnimationId or""))end;function ah.idOf(cq)local M=cq.Animation;return M and string.lower(tostring(M.AnimationId or""))or""end;function ah.has(cr,aV)return aV~=""and string.find(" "..string.lower(ar[cr]or"").." "," "..aV.." ",1,true)~=nil end;function ah.isAction(cq)local bI=cq.Priority.Value;return bI>=Enum.AnimationPriority.Action.Value and bI<Enum.AnimationPriority.Core.Value end;function ah.dribbling()for cq in pairs(ah.loops)do if cq.IsPlaying then return true end end;return false end;function ah.classify(cq)if cq.Looped then return nil end;local aV=ah.idOf(cq)for aF,cr in pairs(cp)do if ah.has(cr,aV)then return aF,"taught"end end;local bc=ah.name(cq)if T(bc,co)and not T(bc,{"shoot","shot","jumper"})then return"gather","keyword"end;if T(bc,cm)then return"shot","keyword"end;if T(bc,cn)then return"dribble","keyword"end;if ar.GlideSmart and ah.isAction(cq)and(ad.holding or not next(ad.parts))then return"dribble","smart"end;return nil end;function ah.startLearn(aF)ah.learnKind=aF;ah.learnUntil=tick()+8;ah.learned=0;ao("Teaching "..aF,"Do that move in the game now. You have 8 seconds.",4)aa.show(false)task.delay(8.5,function()if C.Running then aa.show(true)end end)end;function ah.learn(cq)if not ah.learnKind then return false end;if tick()>ah.learnUntil then ah.learnKind=nil;return false end;if cq.Looped or not ah.isAction(cq)then return false end;local aV=ah.idOf(cq)if aV==""then return false end;local cr=cp[ah.learnKind]if not ah.has(cr,aV)then ar[cr]=O((ar[cr]or"").." "..aV)ah.learned=ah.learned+1;aI()I("Taught "..ah.learnKind..": "..aV)ao("Learned",ah.learnKind.." animation saved ("..ah.learned..")",2)end;return true end;function ah.clear()ar.AnimDribble,ar.AnimGather,ar.AnimShot="","",""aI()ao("Taught moves","Cleared",2)end;function ah.summary()return string.format("Taught: %d dribble, %d gather, %d shot",#Q(ar.AnimDribble),#Q(ar.AnimGather),#Q(ar.AnimShot))end;function ah.handle(cq)local bc=ah.name(cq)if cq.Looped and T(bc,{"dribble","ball","handle"})then ah.loops[cq]=true end;ae.noteTrack(cq)local aF,cs=ah.classify(cq)if an.on then an.add("anim",string.format("%s id=%s len=%.2f prio=%s looped=%s speed=%s -> %s",(cq.Name or"")~=""and cq.Name or"?",ah.idOf(cq),cq.Length or 0,tostring(cq.Priority.Value),tostring(cq.Looped),tostring(cq.Speed),tostring(aF)))end;if aF=="dribble"and cs~="smart"then ah.lastDribble=tick()end;if ah.learn(cq)then return end;if ae.busy then return end;if aF and not ae.hooked then ag.fire(aF,"animation "..((cq.Name or"")~=""and cq.Name or"?"))end end;function ah.onPlayed(cq)if ah.seen[cq]then return end;ah.seen[cq]=true;ah.handle(cq)end;function ah.poll()local M=ah.animator;if not M then return end;local a9,b4=pcall(function()return M:GetPlayingAnimationTracks()end)if not a9 or type(b4)~="table"then return end;local ct={}for g,cq in ipairs(b4)do ct[cq]=true;if not ah.seen[cq]then ah.seen[cq]=true;pcall(ah.handle,cq)end end;for cq in pairs(ah.seen)do if not ct[cq]then ah.seen[cq]=nil end end end;function ah.hookChar(H)task.spawn(function()local function cu()return H:FindFirstChildOfClass("Humanoid")or H:FindFirstChildOfClass("AnimationController")or H:FindFirstChildWhichIsA("Animator",true)end;local aR=cu()local c9=tick()while not aR and tick()-c9<10 do task.wait(0.5)aR=cu()end;if not aR then return end;local cv=aR;pcall(function()cv=aR:IsA("Animator")and aR or aR:FindFirstChildOfClass("Animator")or aR:WaitForChild("Animator",5)or aR end)ah.animator=cv;pcall(function()E(cv.AnimationPlayed,function(cq)pcall(ah.onPlayed,cq)end)end)end)end;local cw={asx=function(_)return _.AbsoluteSize.X end,asy=function(_)return _.AbsoluteSize.Y end,apx=function(_)return _.AbsolutePosition.X end,apy=function(_)return _.AbsolutePosition.Y end,irx=function(_)return _.ImageRectSize.X end,iry=function(_)return _.ImageRectSize.Y end,iox=function(_)return _.ImageRectOffset.X end,ioy=function(_)return _.ImageRectOffset.Y end,gox=function(_)return _.Offset.X end,goy=function(_)return _.Offset.Y end,grot=function(_)return _.Rotation end,gc2=function(_)local a1=_.Color.Keypoints;return a1[2]and a1[2].Time end,gc3=function(_)local a1=_.Color.Keypoints;return a1[3]and a1[3].Time end,gt2=function(_)local a1=_.Transparency.Keypoints;return a1[2]and a1[2].Time end,gt3=function(_)local a1=_.Transparency.Keypoints;return a1[3]and a1[3].Time end}local cx={"asx","asy","apx","apy"}local cy={"irx","iry","iox","ioy"}local cz={"gox","goy","grot","gc2","gc3","gt2","gt3"}local cA={"meter","bar","fill","shot","power","timing","release","gauge","progress","bat"}al.armedUntil=0;al.misses=0;al.inst=nil;al.report={}function al.isArmed()return tick()<al.armedUntil end;function al.pathOf(cB)local aE,_={},cB;while _ and _~=game do table.insert(aE,1,_.Name)_=_.Parent end;return table.concat(aE,"/")end;function al.resolve(au)local _=game;for cC in string.gmatch(au,"[^/]+")do _=_ and _:FindFirstChild(cC)if not _ then return nil end end;return _ end;function al.hint(cB)local cD,_=0,cB;for g=1,3 do if not _ then break end;if T(string.lower(_.Name),cA)then cD=cD+1 end;_=_.Parent end;return cD end;function al.getter(cB,cE)local G=cw[cE]if not G then return nil end;return function()return G(cB)end end;function al.locate()local cB=al.inst;if cB and cB.Parent then return cB end;cB=ar.BarPath~=""and al.resolve(ar.BarPath)or nil;if not cB and ar.BarPath~=""then local bk=string.match(ar.BarPath,"([^/]+)$")local cF=string.sub(ar.BarProp,1,1)=="g"for bb in pairs(cF and ae.grads or ae.frames)do if bb.Name==bk and bb.Parent and a2(bb.Parent)then cB=bb;break end end end;al.inst=cB;return cB end;function al.selected()return ar.BarProp~=""and ar.BarPath~=""end;function al.threshold()return ar.BarAt*(1+ar.BarNudge/100)end;function al.forget()al.misses=0;ar.BarPath,ar.BarProp,ar.BarAt="","",0;al.inst=nil;aI()end;function al.select(H)ar.BarPath,ar.BarProp,ar.BarAt=al.pathOf(H.inst),H.prop,0;al.inst=H.inst;aI()I("Shot bar found: "..ar.BarPath.." ("..H.prop..")")ao("Shot bar found",H.inst.Name.." ("..H.prop.."). It learns the release point from your first green.",4)end;function al.watch(cG)local V={n=0,series={},known={},cands={},wide=cG,delta=nil,live=false,v0=nil,before={}}if not al.selected()then for bb in pairs(ae.frames)do if bb.Parent and a2(bb)then V.before[bb]=true end end;for a3 in pairs(ae.grads)do local bI=a3.Parent;if bI and a2(bI)then V.before[a3]=true end end end;return V end;function al.collect(V)local R={}local function bF(cB,Z)local cH=al.pathOf(cB)if string.find(cH,"Stamina",1,true)then return end;local cI=al.hint(cB)if string.find(cH,"BatMeter",1,true)then cI=cI+3 end;for g,bk in ipairs(Z)do local aV=cH.."|"..bk;if not V.known[aV]then V.known[aV]=true;local G=cw[bk]R[#R+1]={id=aV,inst=cB,prop=bk,hint=cI,get=function()return G(cB)end}end end end;for bb in pairs(ae.frames)do if bb.Parent and a2(bb)and(V.wide or not V.before[bb])then bF(bb,cx)if bb:IsA("ImageLabel")or bb:IsA("ImageButton")then bF(bb,cy)end end end;for a3 in pairs(ae.grads)do local bI=a3.Parent;if bI and a2(bI)and(V.wide or not V.before[a3])then bF(a3,cz)end end;return R end;function al.step(V)V.n=V.n+1;local cJ=nil;if al.selected()then if not V.get then local cB=al.locate()if cB then local bY=string.sub(ar.BarProp,1,1)=="g"and cB.Parent or cB;if bY and a2(bY)then V.get=al.getter(cB,ar.BarProp)end end end;if V.get then local a9,L=pcall(V.get)if a9 and type(L)=="number"then if V.v0==nil then V.v0=L end;local bb=math.abs(L-V.v0)if V.delta==nil or bb>V.delta+0.0005 then V.lastMove=tick()end;V.delta=bb;if bb>0.0005 then V.live=true end;cJ=bb end end;if not(an.on and V.wide)then return cJ end end;if V.n<=12 and#V.cands<600 then for g,H in ipairs(al.collect(V))do V.cands[#V.cands+1]=H end end;for g,H in ipairs(V.cands)do local a9,L=pcall(H.get)if a9 and type(L)=="number"then local P=V.series[H.id]if not P then P={}V.series[H.id]=P end;P[#P+1]=L end end;return cJ end;function al.minChange(cE)if cE=="grot"then return 4 end;if string.sub(cE,1,1)=="g"then return 0.04 end;return 3 end;function al.analyze(V)local bO,cK;local cL={}for g,H in ipairs(V.cands or{})do local P=V.series[H.id]if P and#P>=5 then local cM,cN,cO=0,0,0;local cP=math.abs(P[#P]-P[1])local cQ=math.max(cP*0.01,0.0001)for cR=2,#P do local bb=P[cR]-P[cR-1]if bb>cQ then cM=cM+1;cO=cO+1 elseif bb<-cQ then cN=cN+1;cO=cO+1 end end;local cS=cO>0 and math.max(cM,cN)/cO or 0;local cD=cO*cS+H.hint*3;if H.prop=="apx"or H.prop=="apy"then cD=cD*0.4 end;table.insert(cL,{id=H.id,span=cP,steps=cO,consistency=cS,score=cD})if cP>=al.minChange(H.prop)and cO>=4 and cS>=0.85 then if not cK or cD>cK then bO,cK=H,cD end end end end;table.sort(cL,function(M,N)return M.span*M.consistency>N.span*N.consistency end)al.report={}for cR=1,math.min(6,#cL)do local bJ=cL[cR]al.report[cR]=string.format("%s span=%.3f steps=%d consistency=%.2f",bJ.id,bJ.span,bJ.steps,bJ.consistency)end;return bO end;function al.finish(V)if not al.selected()then local bO=al.analyze(V)if bO then local P=V.series[bO.id]al.select(bO)V.delta=math.abs(P[#P]-P[1])else al.misses=al.misses+1 end elseif an.on and#V.cands>0 then al.analyze(V)end;if an.on then for g,bD in ipairs(al.report)do an.add("bar","moved: "..bD)end;if V.delta then an.add("bar",string.format("selected %s %s delta=%.3f point=%.3f",ar.BarPath,ar.BarProp,V.delta,ar.BarAt))end end;return V.delta end;function al.teach()al.forget()al.armedUntil=tick()+14;ao("Teaching the shot bar","Press and hold the game's shoot button now. JHub takes this shot so it can watch the bar.",5)aa.show(false)task.delay(14.5,function()if C.Running then aa.show(true)end end)end;ae.busy=false;ae.touchCtx=nil;ae.labels,ae.frames,ae.grads={},{},{}ae.stats={shots=0,greens=0,early=0,late=0,none=0,streak=0,best=0}ae.times={}ae.cap=nil;ae.lastType="-"ae.lastRelease="-"local cT={0.06,0.15,0.35}function ae.track(bb)if bb:IsA("TextLabel")then if not bb:IsDescendantOf(aS)then ae.labels[bb]=true end elseif bb:IsA("UIGradient")then if not bb:IsDescendantOf(aS)then ae.grads[bb]=true end elseif bb:IsA("Frame")or bb:IsA("ImageLabel")or bb:IsA("ImageButton")then if not bb:IsDescendantOf(aS)then ae.frames[bb]=true end end end;function ae.untrack(bb)ae.labels[bb],ae.frames[bb],ae.grads[bb]=nil,nil,nil end;function ae.hookRoot(cU,cV)if cV then task.spawn(function()local bc=0;for g,bb in ipairs(cU:GetDescendants())do ae.track(bb)bc=bc+1;if bc%1500==0 then task.wait()end end end)else for g,bb in ipairs(cU:GetDescendants())do ae.track(bb)end end;E(cU.DescendantAdded,ae.track)E(cU.DescendantRemoving,ae.untrack)end;function ae.parseTimes()ae.times={}for h,aB in string.gmatch(ar.ShotTimes or"","(%S+)=([%d%.]+)")do ae.times[h]=tonumber(aB)end end;function ae.saveTimes()local aE={}for h,aB in pairs(ae.times)do table.insert(aE,string.format("%s=%.3f",h,aB))end;table.sort(aE)ar.ShotTimes=table.concat(aE," ")aI()end;function ae.timesSummary()local cW={}for h,aB in pairs(ae.times)do local cX=string.sub(h,-10)table.insert(cW,string.format("%s  %.2fs",cX,aB))end;table.sort(cW)return#cW>0 and table.concat(cW,"\n")or"No shot types learned yet. Take a few shots."end;function ae.classify(av)local cY=string.lower(av)if not string.find(cY,"release",1,true)and not T(cY,{"perfect","excellent","flawless","splash","good"})then return nil end;local cZ=string.find(cY,"very",1,true)and 3 or(string.find(cY,"slight",1,true)and 1 or 2)if string.find(cY,"early",1,true)then return"early",cZ end;if string.find(cY,"late",1,true)then return"late",cZ end;if string.find(cY,"%f[%a]good%f[%A]")or string.find(cY,"%f[%a]great%f[%A]")or string.find(cY,"%f[%a]nice%f[%A]")then return"good",0 end;return"green",0 end;function ae.textSnapshot()local c_={}for bb in pairs(ae.labels)do if not bb.Parent then ae.labels[bb]=nil elseif a2(bb)then c_[bb]=bb.Text end end;return c_ end;function ae.result(c_,d0,d1)local c9=tick()while tick()-c9<d0 do for bb in pairs(ae.labels)do if not bb.Parent then ae.labels[bb]=nil elseif bb.Text~=""and c_[bb]~=bb.Text and a2(bb)then local aZ,cZ=ae.classify(bb.Text)if aZ then return aZ,cZ,bb.Text end end end;if d1 then if d1.idxT and ae.fbIdxT>d1.idxT then local aw,d2=ae.fromIdx(ae.fbIdx)if aw then return aw,d2,"release "..tostring(ae.fbIdx)end end;if ae.fbT>d1.fb then local aw,P=ae.classifyFB(ae.fbText)if aw then return aw,P,ae.fbText end end;if ae.greenT>d1.green then return"green",0,"green effect"end;if d1.fake and tick()-c9>0.15 then local H=a4()if H and H:GetAttribute("Action")=="Gathering"then return"early",3,"pump fake (released too soon)"end end end;task.wait(0.06)end;return nil,0,nil end;function ae.situation()local aR,aw=a7(),a6()if not aR or not aw then return"stand"end;local L=aw.AssemblyLinearVelocity;local d3=math.sqrt(L.X*L.X+L.Z*L.Z)if aR.MoveDirection.Magnitude<0.1 and d3<3 then return"stand"end;if d3>19 or ac.held.Sprint or l:IsKeyDown(ac.keyCode(ar.SprintKey)or Enum.KeyCode.LeftShift)then return"sprint"end;return"move"end;function ae.paramValue(d4)local S=ar.HoldTime;if ar.AutoTiming then if d4=="move"then S=S+ar.MovingOffset elseif d4=="sprint"then S=S+ar.SprintOffset end end;return S end;function ae.noteTrack(cq)local d5=ae.cap;if not d5 or cq.Looped or not ah.isAction(cq)then return end;if tick()-d5.t0>0.8 then return end;table.insert(d5.tracks,cq)end;function ae.pickTrack(d5)local bO,d6;for g,d7 in ipairs(d5.tracks)do local cD=d7.Length or 0;local bc=ah.name(d7)if T(bc,cm)or T(bc,co)then cD=cD+100 end;if not d6 or cD>d6 then bO,d6=d7,cD end end;return bO end;function ae.keyOf(cq,d4)if cq then local aV=ah.idOf(cq)if aV~=""then return aV end;return"name:"..string.lower(cq.Name or"shot")end;return"sit:"..d4 end;function ae.nameOf(cq,d4)if not cq then return d4 end;local bc=cq.Name;if bc and bc~=""and bc~="Animation"then return bc end;local M=cq.Animation;if M and M.Name and M.Name~=""and M.Name~="Animation"then return M.Name end;return string.sub(ah.idOf(cq),-8)end;function ae.holdFor(d4,cq)local h=ae.keyOf(cq,d4)local cH;if ar.AutoTiming and cq then cH=ae.times[h]if not cH and ar.ShotRatio>0 and(cq.Length or 0)>0.05 then cH=ar.ShotRatio*cq.Length end end;cH=cH or ae.paramValue(d4)local S=cH;if ar.AutoTiming and ar.PingComp>0 then local a9,d8=pcall(function()return u:GetNetworkPing()end)if a9 and d8 then S=S-d8*ar.PingComp/100 end end;S=S+ar.Nudge/1000;if ar.Humanize>0 then S=S+(math.random()*2-1)*ar.Humanize/1000 end;return K(S,0.05,ar.MaxHold),h,cH end;function ae.applyDelta(d4,d9)if ar.AutoTiming and d4=="move"then aa.set("MovingOffset",K(ar.MovingOffset+d9,-0.5,0.5),false)elseif ar.AutoTiming and d4=="sprint"then aa.set("SprintOffset",K(ar.SprintOffset+d9,-0.5,0.5),false)else aa.set("HoldTime",K(ar.HoldTime+d9,0.08,1.6),false)end end;function ae.release(b3,da)if b3=="backup"then af.send(false)elseif b3=="remote"then ae.releasedT=tick()ae.fireRemote(false)elseif b3=="manualKey"then ac.sendKey(ar.ShootKey,false)elseif b3=="touch"and da then if ar.ReleaseMethod~="Key"and da.btn then ac.fireGui(da.btn,false,ar.FireClick)end;if ar.ReleaseMethod~="Button"then ac.sendKey(ar.ShootKey,false)end end end;function ae.learnTiming(db,aZ,cZ)local dc=ar.CalSpeed;local cH,dd=db.base,db.held;local function de(df)return math.max(ar.CalStep*cZ*dc,df*cT[cZ]*dc/0.6)end;if ar.AutoTiming and db.track then local dg;if db.manual or db.usedBar then if aZ=="green"then dg=cH+(dd-cH)*0.5 end elseif aZ=="green"then dg=cH elseif aZ=="early"then dg=cH+de(cH)elseif aZ=="late"then dg=cH-de(cH)end;if dg then ae.times[db.key]=K(dg,0.08,ar.MaxHold)ae.saveTimes()end;local ck=db.track.Length or 0;if aZ=="green"and ck>0.05 then local dh=(ae.times[db.key]or dd)/ck;ar.ShotRatio=ar.ShotRatio>0 and ar.ShotRatio*0.6+dh*0.4 or dh;aI()end;return end;local d9=0;local di=ae.paramValue(db.sit)if db.manual or db.usedBar then if aZ=="green"then d9=(dd-di)*0.5 end elseif aZ=="early"then d9=de(di)elseif aZ=="late"then d9=-de(di)end;if d9~=0 then ae.applyDelta(db.sit,d9)end end;function ae.evaluate(db)local aZ,cZ,av=ae.result(db.snap,2,db.since)local d2=ae.stats;if aZ=="green"then d2.greens=d2.greens+1;d2.streak=d2.streak+1;if d2.streak>d2.best then d2.best=d2.streak end elseif aZ=="good"then d2.streak=0 elseif aZ=="early"then d2.early=d2.early+1;d2.streak=0 elseif aZ=="late"then d2.late=d2.late+1;d2.streak=0 else d2.none=d2.none+1 end;local dj=av and'"'..av..'"'or"no feedback seen"if ar.AutoCalibrate and aZ then local dc=ar.CalSpeed;if db.barDelta and al.selected()then if aZ=="green"then if db.usedBar and ar.BarAt>0 then ar.BarAt=ar.BarAt*0.7+db.barDelta*0.3 elseif ar.BarAt<=0 then ar.BarAt=db.barDelta else ar.BarAt=ar.BarAt*0.5+db.barDelta*0.5 end elseif db.usedBar and ar.BarAt>0 then local a1=cT[cZ]*dc/0.6;ar.BarAt=ar.BarAt*(aZ=="early"and 1+a1 or 1-a1)end;aI()end;if db.remote then db.idx=db.since and ae.fbIdxT>db.since.idxT and ae.fbIdx or nil;db.relQ=ae.meterQ()if db.usedMeter then ae.learnMeter(db)dj=dj..string.format("  |  aim %.3f",ar.MeterTarget)else ae.learnRemote(db,aZ,cZ)dj=dj..string.format("  |  %.3fs",ae.times[db.key]or db.held)end else ae.learnTiming(db,aZ,cZ)dj=dj..string.format("  |  %s  |  %.2fs",ae.lastType,ae.times[db.key]or ae.paramValue(db.sit))end end;if an.shotOn then pcall(an.shotNote,db,aZ,av)an.shotAdd(string.format("RESULT %s | held=%.4f | key=%s | message=%s | game log=%s",tostring(aZ),db.held or 0,tostring(db.key),tostring(av),string.sub(tostring(ae.fbText or""),1,200)))end;I("Shot: "..dj)ao(aZ=="green"and"GREEN!"or"Shot",dj,2.2)end;ae.meterT,ae.packet,ae.packetT,ae.greenT,ae.fbT,ae.fbText=0,nil,0,0,0,""ae.releasedT,ae.pressT,ae.pkMiss=0,0,0;ae.hooked=false;ae.selfFire=false;ae.remote=nil;function ae.findRemote()local aw=ae.remote;if aw and aw.Parent then return aw end;ae.remote=nil;for g,bb in ipairs(s:GetDescendants())do if bb:IsA("RemoteEvent")and bb.Name=="Shoot"then ae.remote=bb;if bb.Parent and bb.Parent.Name=="InputService"then break end end end;return ae.remote end;function ae.fireRemote(bl)local aw=ae.findRemote()if not aw then return false end;ae.selfFire=true;local a9=pcall(function()aw:FireServer({Shoot=bl})end)ae.selfFire=false;return a9 end;function ae.classifyFB(av)local cY=string.lower(av)local cZ=string.find(cY,"very",1,true)and 3 or(string.find(cY,"slight",1,true)and 1 or 2)if string.find(cY,"%f[%a]early%f[%A]")then return"early",cZ end;if string.find(cY,"%f[%a]late%f[%A]")then return"late",cZ end;if string.find(cY,"%f[%a]perfect%f[%A]")or string.find(cY,"%f[%a]green%f[%A]")or string.find(cY,"%f[%a]excellent%f[%A]")then return"green",0 end;if string.find(cY,"%f[%a]good%f[%A]")then return"good",0 end;return nil end;local function dk(M)local dl=false;for cR=1,3 do local L=M[cR]if typeof(L)=="Instance"then dl=true;if L.Name==u.Name then return true end end end;return not dl end;function ae.onRemoteEvent(bk,...)local M={...}if an.shotOn then local aE={}for cR=1,math.min(#M,8)do local L=M[cR]aE[#aE+1]=typeof(L)=="Instance"and"<"..L.Name..">"or(type(L)=="table"and"{table}"or tostring(L))end;an.shotAdd("EVENT "..bk.." "..table.concat(aE," | "))end;if bk=="Meter"then if M[1]==true and typeof(M[2])=="Instance"and M[2].Name==u.Name then ae.meterT,ae.packet=tick(),nil;if an.shotOn then an.shotMeterStart()end end elseif bk=="RegisterPacket"then if typeof(M[1])=="Instance"and M[1].Name==u.Name and type(M[3])=="number"then ae.packet,ae.packetT=M[3],tick()end elseif bk=="ShowFeedback"then if typeof(M[1])=="Instance"and(M[1].Name==u.Name or M[1]==a4())and tonumber(M[3])then ae.fbIdx,ae.fbIdxT=tonumber(M[3]),tick()end elseif bk=="RunGreenEffect"or bk=="GreenCelebration"then if dk(M)then ae.greenT=tick()end elseif bk=="Output"then if type(M[2])=="string"and string.find(M[2],"Shot Feedback",1,true)then ae.fbT,ae.fbText=tick(),M[2]end end end;ae.remoteNames={Meter=true,RegisterPacket=true,RunGreenEffect=true,GreenCelebration=true,Output=true,ShowFeedback=true,UpdateGreenWindow=true,GreenToggle=true}ae.fbIdx,ae.fbIdxT=nil,0;function ae.fromIdx(dm)if dm==5 then return"green",0 end;if dm==4 then return"good",1 end;if dm and dm<4 then return"early",4-dm end;if dm and dm>5 then return"late",dm-5 end;return nil end;function ae.connectRemotes()local function dn(bb)if bb:IsA("RemoteEvent")and ae.remoteNames[bb.Name]then E(bb.OnClientEvent,function(...)pcall(ae.onRemoteEvent,bb.Name,...)end)end end;for g,bb in ipairs(s:GetDescendants())do dn(bb)end;E(s.DescendantAdded,dn)end;function ae.onShootCall(c4)local bb=c4[1]if type(bb)~="table"or ae.selfFire then return false end;local bZ=tick()if an.shotOn then an.shotAdd("SHOOT remote Shoot="..tostring(bb.Shoot).." Input="..tostring(bb.Input).." UseSpace="..tostring(bb.UseSpace))end;if bb.Shoot==true then ae.pressT=bZ;if ar.ShotGlide then am.watchShot(bZ)end;if ar.AutoGreen and not ae.busy then local da={t0=bZ,ended=false,space=bb.UseSpace==true,btn=ac.lastTouch and ac.lastTouch.obj}ae.remoteCtx=da;task.defer(ae.run,"remote",da)end elseif bb.Shoot==false then local da=ae.remoteCtx;if da and ae.busy and not da.released then if ar.ShotStyle=="Tap"and ar.AutoGreen then da.dropped=true;return true end;da.ended=true;return false end;if ar.AutoGreen and bZ-ae.releasedT<2.5 then return true end end;return false end;ae.FLOOR=0.205;ae.brackets={}function ae.remoteKey(d5,d4)local dp={}for g,d7 in ipairs(d5.tracks)do local aV=ah.idOf(d7)if aV~=""then dp[#dp+1]=string.gsub(aV,"rbxassetid://","")end end;table.sort(dp)if#dp==0 then return"sit:"..d4 end;return table.concat(dp,"+")end;ae.SWEEPSCALE={["71484695722621"]=1,["77401448272074"]=1,["128777513307709+77401448272074"]=1}ae.SWEEPLIST={["77401448272074"]={0.006,0.012,0.018,0.024,0.030,0.036,0.042,0.048},["128777513307709+77401448272074"]={0.006,0.012,0.018,0.024,0.030,0.036,0.042,0.048}}ae.FINAL={["15851912457+15851919155"]=0.357,["15851912457+15851919155+17285155256"]=0.357,["111074210919383"]=0.367,["71484695722621"]=0.321,["77401448272074"]=0.339,["128777513307709+77401448272074"]=0.339}ae.VERDICT={"Very early","Early","Slightly early","Good","Perfect","Slightly late","Late","Very late"}ae.NAMES={["15851912457+15851919155"]="Jumpshot1RBase",["15851912457+15851919155+17285155256"]="Jumpshot1RBase",["111074210919383"]="StepPostFade1R",["71484695722621"]="PostFadeLeft1R",["77401448272074"]="PostFadeRight1R",["128777513307709+77401448272074"]="PostFadeRight1R"}ae.keyName={}ae.adjLog={}ae.cur,ae.last=nil,nil;function ae.noteAdjust(h,df,dq,dr)table.insert(ae.adjLog,1,{t=tick(),key=h,from=df,to=dq,why=dr})while#ae.adjLog>6 do table.remove(ae.adjLog)end end;local function ds(S)local bb=math.max(0,tick()-S)if bb<60 then return string.format("%ds ago",math.floor(bb))end;return string.format("%dm ago",math.floor(bb/60))end;function ae.nameFor(h,dt)local bc=ae.keyName[h]or ae.NAMES[h]if bc then return bc end;if dt and dt~=""then return tostring(dt)end;return"Shot "..string.sub(tostring(h),-6)end;function ae.statusLines()local du=ae.cur;if not du then local c5,dv=ae.pingComp()return"-","-","Shoot to see it","-","No change yet",ar.PerfectGreen and string.format("%.0f ms earlier (ping %.0f ms)",c5*1000,dv*1000)or string.format("off (ping %.0f ms)",dv*1000)end;local dw="-"if ae.last then local bD=ae.last;local L=bD.idx and ae.VERDICT[bD.idx]or bD.res=="green"and"Perfect"or bD.res=="good"and"Good"or tostring(bD.res)dw=string.format("%s at %.3fs",L,bD.held or 0)end;local cW={}for cR=1,math.min(4,#ae.adjLog)do local M=ae.adjLog[cR]cW[#cW+1]=string.format("%s: %.3f -> %.3fs (%s)",ds(M.t),M.from,M.to,M.why)end;local dx,bI=ae.pingComp()local dy;if ar.PerfectGreen then dy=string.format("%.0f ms earlier (ping %.0f ms)",dx*1000,bI*1000)else dy=string.format("off (ping %.0f ms)",bI*1000)end;return ae.nameFor(du.key,du.anim),du.mode=="peak"and string.format("%.0f ms before the peak",du.hold*1000)or string.format("%.3fs",du.hold),du.state or"-",dw,#cW>0 and table.concat(cW,"\n")or"No change yet",dy end;ae.PING_REF=0.022;function ae.pingNow()local a9,bI=pcall(function()return u:GetNetworkPing()end)bI=a9 and type(bI)=="number"and bI or ae.PING_REF;ae.pingEma=ae.pingEma and ae.pingEma*0.7+bI*0.3 or bI;return ae.pingEma end;function ae.pingComp()local bI=ae.pingNow()if not ar.PerfectGreen then return 0,bI end;local dx=(bI-ae.PING_REF)*(ar.PerfectGreenPct or 100)/100;return K(dx,0,0.2),bI end;ae.AUTO_START=0.34;ae.AUTO_SCAN={0.30,0.32,0.34,0.36,0.38,0.31,0.33,0.35,0.37,0.29,0.39,0.40,0.28}ae.auto={}ae.autoLoaded=false;function ae.autoLoad()if ae.autoLoaded then return end;ae.autoLoaded=true;ae.auto={}for aF,h,aB in string.gmatch(ar.AutoTimes or"","(%a):(%S-)=([%d%.]+)")do ae.auto[h]={hold=tonumber(aB),greens={},locked=aF=="L"or aF=="l",dir=1,mode=(aF=="l"or aF=="p")and"peak"or nil}end end;function ae.autoSave()local aE={}for h,M in pairs(ae.auto)do aE[#aE+1]=string.format("%s:%s=%.4f",M.mode=="peak"and(M.locked and"l"or"p")or(M.locked and"L"or"P"),h,M.hold)end;table.sort(aE)ar.AutoTimes=table.concat(aE," ")aI()end;function ae.autoReset()ae.autoLoaded=true;ae.auto={}ar.AutoTimes=""aI()end;function ae.autoActive(h)if not ar.AutoCal or ae.FINAL[h]then return false end;if ar.Sweep and an.shotOn then return false end;if ae.times["la:"..h]or ae.times["r:"..h]then return false end;return true end;ae.PEAK_Q=0.978;function ae.peakFit(dz)local dA,dB={},-1;for g,dC in ipairs(dz)do if dC.q<dB-0.001 then break end;dB=dC.q;if dC.q>0.12 and dC.q<0.93 then dA[#dA+1]=dC end end;local bc=#dA;if bc<6 or dA[bc].q<0.3 then return nil end;local c9=dA[1].t;local d2,dD,dE,dF=0,0,0,0;for g,bI in ipairs(dA)do local dG=bI.t-c9;d2,dD,dE,dF=d2+dG,dD+bI.q,dE+dG*dG,dF+dG*bI.q end;local dH=bc*dE-d2*d2;if dH<=1e-9 then return nil end;local M=(bc*dF-d2*dD)/dH;local N=(dD-M*d2)/bc;if M<1.2 or M>5 then return nil end;return c9+(ae.PEAK_Q-N)/M end;function ae.peakLearn(db,aZ,cZ,M,h)if M.locked then return true end;local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if not dm then return true end;if db.manual and dm~=5 then return true end;local dI=db.lead or M.hold;if not db.manual and math.abs(dI-M.hold)>0.05 then return true end;local dJ=M.hold;M.n=(M.n or 0)+1;local dr;if dm==5 then M.hold,M.locked=dI,true;ar.PeakLead=K(ar.PeakLead*0.5+dI*0.5,0,0.08)pcall(ao,"Auto Green",string.format("Learned this shot: %.0f ms before the peak",dI*1000),3)dr="Perfect, locked"else local bb,dK;if dm==4 then bb,dK=M.dir or 1,0.4 elseif dm<=3 then bb,dK=-1,dm==3 and 0.7 or dm==2 and 1.0 or 1.5 else bb,dK=1,dm==6 and 0.7 or dm==7 and 1.0 or 1.5 end;M.step=M.step or 0.012;if dm==4 then M.goodRun=(M.goodRun or 0)+1;M.step=K(M.step*(M.goodRun>=2 and 1.15 or 0.85),0.002,0.008)else M.goodRun=0;if M.lastD and M.lastD~=bb then M.step=math.max(0.002,M.step*0.5)elseif M.lastD==bb then M.step=math.min(0.02,M.step*1.3)end;M.lastD,M.dir=bb,bb end;M.hold=K(dI+bb*M.step*dK,0,0.1)ar.PeakLead=K(ar.PeakLead+bb*M.step*dK*0.25,0,0.08)dr=(ae.VERDICT[dm]or"?")..(bb>0 and", letting go earlier"or", letting go later")end;if math.abs(M.hold-dJ)>0.0003 or M.locked then ae.noteAdjust(h,dJ,M.hold,dr)end;ae.autoSave()if an.shotOn then an.shotAdd(string.format("AUTOCAL(meter) key=%s idx=%s lead=%.4f next=%.4f locked=%s",h,tostring(dm),dI,M.hold,tostring(M.locked)))end;return true end;function ae.autoLearn(db,aZ,cZ)local h=db.key;if not ae.autoActive(h)then return false end;ae.autoLoad()local M=ae.auto[h]if not M then return false end;if M.locked then return true end;if M.mode=="peak"then return ae.peakLearn(db,aZ,cZ,M,h)end;local dd=(db.held or 0)+(db.comp or 0)local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if not dm or not dd then return true end;if db.manual and dm~=5 then return true end;if not db.manual and math.abs(dd-M.hold)>0.06 then return true end;M.n=(M.n or 0)+1;local dJ,dL=M.hold,M.locked;if dm==5 then M.greens[#M.greens+1]=dd;M.hold=dd;M.locked=true;pcall(ao,"Auto Green",string.format("Learned this shot: %.3fs",M.hold),3)else local bb,dK;if dm==4 then bb,dK=M.dir or 1,0.4 elseif dm<=3 then bb,dK=1,dm==3 and 0.7 or dm==2 and 1.0 or 1.5 else bb,dK=-1,dm==6 and 0.7 or dm==7 and 1.0 or 1.5 end;M.step=M.step or 0.020;if dm==4 then M.goodRun=(M.goodRun or 0)+1;M.step=M.step*(M.goodRun>=2 and 1.15 or 0.85)M.step=K(M.step,0.004,0.015)else M.goodRun=0;if M.lastD and M.lastD~=bb then M.step=math.max(0.004,M.step*0.5)elseif M.lastD==bb then M.step=math.min(0.04,M.step*1.3)end;M.lastD,M.dir=bb,bb end;M.hold=dd+bb*M.step*dK end;M.hold=K(M.hold,ae.FLOOR,ar.MaxHold)if M.locked and not dL then ae.noteAdjust(h,dJ,M.hold,"Perfect, locked")elseif math.abs(M.hold-dJ)>0.0005 then ae.noteAdjust(h,dJ,M.hold,(ae.VERDICT[dm]or"?")..((M.dir or 1)>0 and", going later"or", going earlier"))end;ae.autoSave()if an.shotOn then an.shotAdd(string.format("AUTOCAL key=%s idx=%s held=%.3f next=%.3f greens=%d locked=%s",h,tostring(dm),dd,M.hold,#M.greens,tostring(M.locked)))end;return true end;function ae.remoteHold(h,dM)local dN=ae.FINAL[h]if dN and ar.AdaptPlus then ae.finalLoad()dN=dN+(ae.finalAdj[h]or 0)end;if dN then ae.lastSweep=nil;ae.cur={key=h,hold=dN,state="Locked (built in)"}return K(dN,ae.FLOOR,ar.MaxHold),dN end;if ae.autoActive(h)then ae.autoLoad()local M=ae.auto[h]if not M then M={hold=ae.seedLead(h),greens={},locked=false,dir=1,mode="peak",bin=ar.PeakBin}ae.auto[h]=M end;ae.lastSweep=nil;if M.mode=="peak"then ae.cur={key=h,hold=M.hold,mode="peak",state=M.locked and"Locked (learned)"or"Learning (by the meter)"}return M.hold,M.hold,"peak"end;local dO=M.locked and"Locked (learned)"or(M.n or 0)>0 and((M.dir or 1)>0 and"Learning, trying later"or"Learning, trying earlier")or"Learning"ae.cur={key=h,hold=M.hold,state=dO}return K(M.hold,ae.FLOOR,ar.MaxHold),M.hold end;local cH=ae.times[h]local dh=ae.times["r:"..h]if dh and dM and dM>0 then cH=dM*dh end;local dP,dQ=ae.times["la:"..h],ae.times["lb:"..h]if dP and dQ and dM and dM>0 then cH=dP+dQ*dM end;if not cH then cH=dM and dM*ar.PacketMul or ar.HoldTime end;local dR=cH+ar.Nudge/1000;ae.lastSweep=nil;if ar.Sweep and an.shotOn and not ae.times["la:"..h]then ae.sweepN=ae.sweepN or{}local cR=(ae.sweepN[h]or 0)+1;ae.sweepN[h]=cR;local dS=ae.SWEEPLIST[h]or ae.SWEEP;local dT=dS[(cR-1)%#dS+1]if not ae.SWEEPLIST[h]then dT=dT*(ae.SWEEPSCALE[h]or 2.5)end;dR=dR+dT;ae.lastSweep=dT;an.shotAdd(string.format("SWEEP key=%s step=%d offset=%+.3f",h,cR,dT))end;ae.cur={key=h,hold=dR,state=ar.Sweep and an.shotOn and"Sweep recording"or(ar.AutoCal and"Fixed timing"or"Auto-learn off")}return K(dR,ae.FLOOR,ar.MaxHold),cH end;ae.SWEEP={-0.036,-0.030,-0.024,-0.018,-0.012,-0.006,0,0.006,0.012,0.018,0.024,0.030,0.036}ae.greenKeys={}function ae.learnRemote(db,aZ,cZ)if db then local bN=a4()ae.last={t=tick(),held=db.held,idx=db.idx,res=aZ,key=db.key}if ae.cur and ae.cur.key==db.key and bN then ae.cur.anim=bN:GetAttribute("BaseAnimation")end end;if db and ae.FINAL[db.key]then if ar.AdaptPlus then pcall(ae.finalLearn,db,aZ,cZ)end;return end;if db and ae.autoLearn(db,aZ,cZ)then return end;if not ar.Learn or ar.Sweep and an.shotOn then return end;local h,dd=db.key,db.held+(db.comp or 0)local X;if db.manual then if aZ=="green"then X=dd end elseif aZ=="early"and(cZ or 2)>=3 then X=dd+0.07 elseif ae.times["la:"..h]then return elseif db.pk and db.pk>0 and ae.times["r:"..h]and aZ~="early"then local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="late"and 5+(cZ or 2)local dU=(dd-(dm-5)*0.006)/db.pk;local i=ae.times["r:"..h]local dc=aZ=="green"and 0.7 or(ae.greenKeys[h]and 0.1 or 0.35)if aZ=="green"then ae.greenKeys[h]=true end;ae.times["r:"..h]=K(i+dc*(dU-i),0.5,3)ae.saveTimes()return else local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm then local dU=dd-(dm-5)*0.014;local i=ae.times[h]or dd;local dc=aZ=="green"and 0.7 or(ae.greenKeys[h]and 0.12 or 0.45)if aZ=="green"then ae.greenKeys[h]=true end;X=i+dc*(dU-i)end;if aZ=="green"and db.pk and db.pk>0 then ar.PacketMul=K(ar.PacketMul*0.5+dd/db.pk*0.5,0.4,3)end end;if X then ae.times[h]=K(X,ae.FLOOR,ar.MaxHold)ae.saveTimes()end end;ae.lastBin=nil;function ae.meterQ()local H=a4()local L=H and H:GetAttribute("meterOffset")if typeof(L)=="Vector2"or typeof(L)=="Vector3"then return-L.Y end;return nil end;function ae.learnMeter(db)local dV,dm=db.relQ,db.idx;if not dV or not dm then return end;if dm==5 then ar.MeterTarget=ar.MeterTarget*0.5+dV*0.5 else if ae.lastBin and ae.lastBin.idx~=dm then local dW=math.abs(dV-ae.lastBin.q)/math.abs(dm-ae.lastBin.idx)ar.MeterBin=K(ar.MeterBin*0.5+dW*0.5,0.008,0.12)end;ar.MeterTarget=dV+(5-dm)*ar.MeterBin end;ar.MeterTarget=K(ar.MeterTarget,0.3,1.6)ae.lastBin={idx=dm,q=dV}aI()end;function ae.remoteCore(da)local c_=ae.textSnapshot()local d1={green=ae.greenT,fb=ae.fbT,fake=true,idxT=ae.fbIdxT}local dz={}local dX;do local H=a4()if H then local a9,dY=pcall(function()return H:GetAttributeChangedSignal("meterOffset")end)if a9 and dY then dX=dY:Connect(function()local dZ=ae.meterQ()if dZ then dz[#dz+1]={t=tick(),q=dZ}end end)end end end;local c9=da.t0;local d5={t0=c9-0.05,tracks={}}ae.cap=d5;local d_=tick()+0.5;while tick()<d_ and ae.meterT<c9-0.05 do k.Heartbeat:Wait()end;if ae.meterT<c9-0.05 then ae.cap=nil;if da.dropped and not da.ended then ae.fireRemote(false)end;return end;local e0=ae.meterT;for cR=#dz,1,-1 do if dz[cR].t<e0-0.05 then table.remove(dz,cR)end end;do local bN=a4()if bN and bN:GetAttribute("Action")=="Gathering"then local e1=tick()+1.5;while#dz==0 and tick()<e1 do k.Heartbeat:Wait()end;if#dz>0 then e0=dz[1].t end end end;local e2=tick()+0.12;while(ae.packetT<e0-0.01 or#d5.tracks==0)and tick()<e2 do k.Heartbeat:Wait()end;local dM=ae.packetT>=e0-0.01 and ae.packet or nil;local d4=ae.situation()local h=ae.remoteKey(d5,d4)ae.cap=nil;local dR,cH,b3=ae.remoteHold(h,dM)local dx,e3=0,nil;if b3=="peak"then e3=dR;dR=ae.AUTO_START else dx=ae.pingComp()if dx~=0 then dR=math.max(ae.FLOOR,dR-dx)end end;if ae.cur then ae.cur.comp=dx end;local e4=false;local e5,e6=false,nil;local e7=false;local e8,e9=pcall(function()return u:GetNetworkPing()end)local dI=(e8 and e9 or 0.04)+0.016+ar.Nudge/1000;local ea=ae.lookAhead()while tick()-e0<ar.MaxHold do if da.ended then e4=true;break end;local bZ=tick()local bc=#dz;if e3 then local eb=ae.peakFitSmart(dz,h)if eb and(not ar.LagSync or eb-e0>0.22)then dR=math.max(ae.FLOOR,eb-(ae.effPing()+e3)-e0-ae.fpsComp())e7=true end;if bZ-e0>=dR-ea and(e7 or bZ-e0>=ae.AUTO_START-ea)then break end elseif ar.MeterAim and bc>=3 and bZ-dz[bc].t<0.15 then local M,N=dz[math.max(1,bc-3)],dz[bc]local ec=N.t-M.t;if ec>0.01 then local dc=(N.q-M.q)/ec;if dc>0.05 then e5=true;e6=N.q+dc*(bZ-N.t+dI)if e6>=ar.MeterTarget then break end end end elseif bZ-e0>=dR-ea then break end;k.Heartbeat:Wait()end;if dX then pcall(function()dX:Disconnect()end)end;pcall(ae.slopeCommit,dz,h)local dw,ed=tick(),0;while not e5 and not e4 and not da.ended and tick()-e0<dR do local bc=tick()if bc==dw then ed=ed+1;if ed>20000 then break end else dw,ed=bc,0 end end;while not e4 and not da.ended and tick()-e0<dR do k.Heartbeat:Wait()end;local dd=tick()-e0;ae.markShot()if not e4 then ae.release("remote",da)end;da.released=true;ae.stats.shots=ae.stats.shots+1;ae.lastType=h;ae.lastRelease=e4 and"you"or"timing"if an.on then an.add("shot",string.format("remote shot key=%s packet=%s hold=%.3f base=%.3f held=%.3f released by %s style=%s space=%s",h,tostring(dM),dR,cH,dd,ae.lastRelease,tostring(ar.ShotStyle),tostring(da.space)))end;if an.shotOn then an.shotAdd(string.format("RELEASE meter=%s target=%.3f predicted=%s samples=%d key=%s packet=%s hold=%.4f held=%.4f by=%s style=%s ping=%s comp=%.4f lead=%s",tostring(e5),ar.MeterTarget,tostring(e6),#dz,h,tostring(dM),dR,dd,ae.lastRelease,tostring(ar.ShotStyle),tostring(pcall(function()return u:GetNetworkPing()end)and u:GetNetworkPing()or"?"),dx,tostring(e3)))end;task.spawn(ae.evaluate,{snap=c_,since=d1,sit=d4,key=h,base=cH,held=dd,manual=e4,pk=dM,remote=true,usedBar=false,usedMeter=e5,qpred=e6,comp=e4 and 0 or dx,lead=e3})end;function ae.core(b3,da)if b3=="remote"then return ae.remoteCore(da)end;local d4=ae.situation()local c_=ae.textSnapshot()local cG=al.isArmed()or an.on or not al.selected()and al.misses>=2 and al.misses<10;local ee=al.watch(cG)local d5={t0=da and da.t0 or tick(),tracks={}}ae.cap=d5;ag.fire("shot","shot start")if b3=="backup"then local a9,ef=af.send(true)if not a9 then ae.cap=nil;I("Backup press failed: "..tostring(ef))return end end;local c9=d5.t0;local eg=ar.ShotRelease~="Timing"and al.selected()and ar.BarAt>0;local cq;local dR,h,cH=ae.holdFor(d4,nil)local e4=false;while tick()-c9<ar.MaxHold do k.Heartbeat:Wait()if b3=="manualKey"and da.kc and not l:IsKeyDown(da.kc)then e4=true;break end;if b3=="touch"and da.ended then e4=true;break end;cq=ae.pickTrack(d5)dR,h,cH=ae.holdFor(d4,cq)if cG then dR=math.max(dR,0.5)end;local d9=al.step(ee)if eg and ee.live then if d9 and d9>=al.threshold()then break end;if ee.lastMove and tick()-ee.lastMove>0.25 then break end elseif tick()-c9>=dR then break end end;local dd=tick()-c9;if not e4 then ae.release(b3,da)end;ae.cap=nil;ae.stats.shots=ae.stats.shots+1;local eh=eg and ee.live and not e4;local ei=al.finish(ee)ae.lastType=ae.nameOf(cq,d4)ae.lastRelease=e4 and"you"or(eh and"bar"or"timing")if an.on then an.add("shot",string.format("type=%s key=%s situation=%s held=%.3f base=%.3f released by %s barDelta=%s",ae.lastType,tostring(h),d4,dd,cH or 0,ae.lastRelease,ei and string.format("%.3f",ei)or"-"))end;task.spawn(ae.evaluate,{snap=c_,sit=d4,key=h,track=cq,base=cH,held=dd,usedBar=eh,barDelta=ei,manual=e4})end;function ae.run(b3,da)if ae.busy then return end;ae.busy=true;local a9,ef=pcall(ae.core,b3,da)if not a9 then I("Shot error: "..tostring(ef))ao("Auto Green error",tostring(ef),6)pcall(ae.release,b3,da)end;if b3=="remote"then if da then da.released=true end;ae.remoteCtx=nil end;task.wait(0.15)ae.busy=false end;ae.seenText={}function ae.onMessage(aZ,cY)if ae.hooked then return end;local S=ac.lastTouch;if ae.busy or not S or not S.obj or not S.endT or tick()-S.endT>1.2 or S.endT-S.t0<0.15 then return end;local bp=ac.findButton("Shoot")if bp and ac.hits(bp,S.pos)then return end;ar.ShootButtonPath=ac.pathOf(S.obj)ac.cache.Shoot=nil;aI()I("Shoot button learned from your shot: "..ar.ShootButtonPath)ao("Shoot button found",S.obj.Name,3)end;function ae.watch()for bb in pairs(ae.labels)do if not bb.Parent then ae.labels[bb]=nil else local cY=bb.Text;if cY~=ae.seenText[bb]then ae.seenText[bb]=cY;if cY~=""and a2(bb)and ae.classify(cY)then ae.onMessage(ae.classify(cY),cY)end end end end end;function af.send(ej)local bd=ac.findButton("Shoot")if not bd then return false,"shoot button not found: use Pick in the Shooting tab"end;local H=bd.AbsolutePosition+bd.AbsoluteSize/2;local dG=H.X;local bC=H.Y+(ar.BackupInset and a8()or 0)local bJ=ar.BackupMethod;if bJ=="touch"then if not t then return false,"no VirtualInputManager"end;return pcall(function()t:SendTouchEvent(87,ej and 0 or 2,dG,bC)end)elseif bJ=="mouse"then if not t then return false,"no VirtualInputManager"end;return pcall(function()t:SendMouseButtonEvent(dG,bC,0,ej,game,1)end)end;if type(firesignal)~="function"then return false,"no firesignal"end;return pcall(function()firesignal(ej and bd.MouseButton1Down or bd.MouseButton1Up,dG,bC)end)end;local ek=RaycastParams.new()ek.FilterType=Enum.RaycastFilterType.Exclude;ek.RespectCanCollide=true;ag.token=0;ag.lastStart={}ag.methods={"Auto","CFrame","Input","AttrBoost","Velocity","Impulse"}ag.chain={"CFrame","Input","AttrBoost","Velocity","Impulse"}ag.input=nil;ag.cur=1;ag.last="no glide yet"ag.lastNote=0;ag.kinds={dribble={"DribbleGlide","DribbleGlidePower","DribbleGlideTime"},gather={"GatherGlide","GatherGlidePower","GatherGlideTime"},shot={"ShotGlide","ShotGlidePower","ShotGlideTime"}}function ag.blocked(aw,cd,bW)if not ar.GlideStopAtWalls then return false end;local el={a4()}if ad.nearest then table.insert(el,ad.nearest)end;for g,bI in ipairs(j:GetPlayers())do if bI~=u and bI.Character then table.insert(el,bI.Character)end end;ek.FilterDescendantsInstances=el;local em=workspace:Raycast(aw.Position,cd*(bW+1.6),ek)if not em then return false end;local en=em.Instance;if not en.Anchored then return false end;local P=en.Size;if math.max(P.X,P.Y,P.Z)<3 then return false end;ai.blockedBy=en.Name;return true end;function ag.judge(aF,eo,ep,cd,eq,er,es,et,dr)local aw=a6()or am.body()if not aw then return end;local eu=(aw.Position-ep):Dot(cd)local ev=eq*er*2/math.pi;local ew=eu-math.max(et,0)*er;local dh=ev>0 and ew/ev or 0;ag.last=string.format("%s (%s) via %s: moved %.1f of %.1f studs",aF,dr or"?",eo,ew,ev)I("Glide "..ag.last)ag.fails=ag.fails or 0;if dh>=0.3 then ag.fails=0;if tick()-ag.lastNote>10 then ag.lastNote=tick()ao("Glide","WORKS",2)end else ag.fails=ag.fails+1;if ar.GlideMethod=="Auto"then ag.cur=ag.cur%#ag.chain+1 end;if tick()-ag.lastNote>6 then ag.lastNote=tick()if ag.fails>=#ag.chain or ar.GlideMethod~="Auto"then ag.fails=0;ao("Glide","DOESN'T WORK",3)else ao("Glide","not yet, trying another way",2)end end end end;function ag.start(aF,eq,er,ex)local aw,aR=am.body(),a7()eq=eq*(ar.GlideSpeed or 1)*ag.lowScale()if not aw or not aR or eq<=0 or er<=0 then return end;local bZ=tick()if bZ-(ag.lastStart[aF]or 0)<er*0.6 then return end;ag.lastStart[aF]=bZ;local ey=am.intent(aR,aw)local cd=W(ey)if ex and W(ex).Magnitude>0.1 then cd=W(ex)end;if cd.Magnitude<0.1 then cd=W(aw.CFrame.LookVector)end;if cd.Magnitude<0.01 then return end;cd=cd.Unit;local eo=ar.GlideMethod;if aF=="shot"and ar.ShotGlideMethod and ar.ShotGlideMethod~="Auto"then eo=ar.ShotGlideMethod end;if eo=="Auto"then eo=ag.chain[ag.cur]end;if eo=="GameVel"then local ez=am.playerModule()if not(ez and ez.Character and ez.Character.Movement and typeof(ez.Character.Movement.CFVelocity)=="Vector3")then eo="CFrame"end end;ag.token=ag.token+1;local eA=ag.token;local es=1-K(ar.GlideFade,0,100)/100;local bE=a6()local ep=(bE or aw).Position;local et=am.vel:Dot(cd)local dr=ag.why;local eB=W(ey)*ai.gameWS;if eo=="Input"then ag.input={untilT=bZ+er,scale=1+eq/math.max(ai.gameWS,1),dir=cd,t0=bZ,nextSend=0}end;if eo=="Impulse"then pcall(function()aw:ApplyImpulse(cd*aw.AssemblyMass*eq)end)end;local function eC()local H=a4()if H and eo=="AttrBoost"then H:SetAttribute("SpeedBoost",0)H:SetAttribute("SpeedBoostTime",0)H:SetAttribute("AccelerationBoost",0)end end;local eD=bZ;local function eE(ec)if eo=="Input"and eA==ag.token then local H=a4()if H and H:GetAttribute("CanMove")==false and tick()-eD<1.5 then bZ=tick()if ag.input then ag.input.untilT=bZ+er;ag.input.paused=true end;return nil end;if ag.input then ag.input.paused=false end end;local bI=(tick()-bZ)/er;if eA~=ag.token or bI>=1 or not aw.Parent or not C.Running then eC()if eA==ag.token then task.delay(0.15,function()if eA==ag.token then pcall(ag.judge,aF,eo,ep,cd,eq,er,es,et,dr)end end)end;return"stop"end;if eo=="Impulse"then return nil end;local eF=math.sin(math.pi*K(bI,0,1))if eo=="AttrBoost"then local H=a4()if H then ag.attrOn=true;H:SetAttribute("SpeedBoost",eq*eF/math.max(ai.gameWS,1))H:SetAttribute("SpeedBoostTime",0.25)H:SetAttribute("AccelerationBoost",0.5)end;return nil end;if eo=="Input"then local bV=ag.input;if not bV then return"stop"end;bV.scale=1+eq*eF/math.max(ai.gameWS,1)local game=am.gameIntent()if(not game or game.Magnitude<0.05)and tick()>=bV.nextSend then bV.nextSend=tick()+0.05;am.send(cd*bV.scale)end;return nil end;local eG=eq*eF*ec;if ag.blocked(aw,cd,eG)then return"stop"end;if eo=="Velocity"then local L=aw.AssemblyLinearVelocity;local S=eB+cd*eq*eF;aw.AssemblyLinearVelocity=Vector3.new(S.X,L.Y,S.Z)else aw.CFrame=aw.CFrame+cd*eG;am.sync(aw)end;return nil end;local eH;eH=k.Stepped:Connect(function(g,ec)local a9,aZ=pcall(eE,ec)if not a9 then ag.lastErr=tostring(aZ)I("Glide error: "..ag.lastErr)ao("Glide problem",ag.lastErr,5)eH:Disconnect()elseif aZ=="stop"then eH:Disconnect()end end)end;function ag.fire(aF,dr,cd)local a1=ag.kinds[aF]if not a1 or not ar[a1[1]]then return end;if ar.GlideNeedBall and aF~="shot"and not ad.holding then I("Glide "..aF.." skipped: you do not hold the ball")return end;ag.why=dr or"?"ag.start(aF,ar[a1[2]],ar[a1[3]],cd)end;function ag.test(aF)local a1=ag.kinds[aF]if not a1 then return end;ag.lastStart[aF]=0;ag.why="test button"ag.start(aF,ar[a1[2]],ar[a1[3]])end;ai.gameWS=16;ai.lastSet=nil;ai.lastPos=nil;ai.lastMove=nil;ai.actual=0;ai.extra=0;ai.level=0;ai.rubberTimes={}ai.lastRubberNote=0;ai.lastRubber=0;ai.test=nil;ai.testing=false;ai.src="none"ai.blockedBy="-"ai.channels={"Auto","Input","AttrWS","AttrBoost","CFrame","Velocity","WalkSpeed","GameValues"}ai.chain={"CFrame","Velocity","WalkSpeed","GameValues"}ai.inputScale=1;ai.probe=nil;ai.methods=ai.channels;ai.minWS=16;ai.auto={idx=1,t=0,d=0,e=0,w=0,results={},locked=nil,lastDir=nil}ai.gv={items={},found=0,scanning=false,applied=false}function ai.isRunning()local b3=ar.RunDetect;if b3=="Never"then return false end;if b3=="Always"then return true end;local H=a4()if H and H:GetAttribute("Sprinting")==true then return true end;if ac.sprintTouch or ac.held.Sprint then return true end;local a1=ac.keyCode(ar.SprintKey)if a1 and l:IsKeyDown(a1)then return true end;if b3=="Sprint button"then return false end;return ai.gameWS>=ai.minWS*1.4 and ai.gameWS-ai.minWS>=4 end;ai.PER_LEVEL=0.75;function ai.pick()if ad.holding then if ar.BallSpeedOn then return"ball",ar.BallAdd end;return nil,0 end;if ai.isRunning()then if ar.RunOn then return"run",ar.RunAdd end;return nil,0 end;if ar.SpeedOn then return"walk",ar.SpeedAdd end;return nil,0 end;function ai.graphicsLevel()local eI;pcall(function()local eJ=UserSettings():GetService("UserGameSettings").SavedQualityLevel;if eJ and eJ.Value and eJ.Value>=1 then eI=eJ.Value end end)if not eI then pcall(function()local dZ=settings().Rendering.QualityLevel;if dZ and dZ.Value and dZ.Value>=1 then eI=dZ.Value end end)end;return eI end;function ai.lowFactor()if ar.LowFix==false then return 0 end;local a5=0;local eI=ai.graphicsLevel()local eK=ar.LowLevel or 3;if eI then if eI<=eK then a5=1 elseif eI<=eK+2 then a5=0.5 end end;local eL=C.FPS or 60;if eL<28 then a5=math.max(a5,1)elseif eL<40 then a5=math.max(a5,0.5)end;return a5 end;function ag.lowScale()local a5=ai.lowFactor()if a5<=0 then return 1 end;local eM=K((ar.LowGlidePct or 60)/100,0.1,1)return 1-(1-eM)*a5 end;function ai.lowStatusText()local eI=ai.graphicsLevel()local a5=ai.lowFactor()local eN=eI and"graphics level "..eI or"graphics level unknown"local dO=ar.LowFix==false and"fix off"or a5>=1 and"LOW, fix on"or(a5>0 and"a little low, fix half on"or"normal, fix not needed")return string.format("%s, %d FPS - %s",eN,math.floor((C.FPS or 0)+0.5),dO)end;function ai.extraNow()local aF,eO=ai.pick()ai.kind=aF;local ew=aF and eO>0 and ai.gameWS*(1.1^eO-1)or 0;local a5=ai.lowFactor()local eP=1+(ar.LowBoostPct or 25)/100*a5;ew=K(ew*eP,0,ar.SpeedCap*eP)local eQ=ai.level*(1-a5)if ar.AntiRubber and eQ>0 then ew=ew/(1+eQ)end;return ew end;function ai.noteRubber()if workspace:FindFirstChild("ProxyCharacter")then return end;local bZ=tick()ai.lastRubber=bZ;table.insert(ai.rubberTimes,bZ)while#ai.rubberTimes>0 and bZ-ai.rubberTimes[1]>3 do table.remove(ai.rubberTimes,1)end;if#ai.rubberTimes>=3 and ar.AntiRubber then ai.rubberTimes={}ai.level=math.min(ai.level+1,3)if bZ-ai.lastRubberNote>10 then ai.lastRubberNote=bZ;ao("Speed boost","The game keeps pulling you back, so the boost was lowered",3)end end end;function ai.resetAuto()ai.probe=nil;ai.rep=nil;ai.auto={idx=1,t=0,d=0,e=0,w=0,results={},locked=nil,lastDir=nil}ai.gvRestore()end;local eR={"speed","sprint","walkspeed","runspeed"}local eS={"anim","fire","reload","cooldown","rate","turn","jump","swim","climb","shot","pass"}function ai.gvAccept(bk,L)if type(bk)~="string"or type(L)~="number"or L<3 or L>150 then return false end;local bc=string.lower(bk)return T(bc,eR)and not T(bc,eS)end;function ai.gvScan()local cb=ai.gv;if cb.scanning then return end;cb.scanning=true;cb.items={}task.spawn(function()pcall(function()for g,cB in ipairs({a4(),u,a7()})do if cB then for a1,L in pairs(cB:GetAttributes())do if ai.gvAccept(a1,L)then table.insert(cb.items,{kind="attr",inst=cB,key=a1,orig=L,last=L})end end end end end)for g,cU in ipairs({a4(),u})do if cU then pcall(function()for g,bb in ipairs(cU:GetDescendants())do if(bb:IsA("NumberValue")or bb:IsA("IntValue"))and ai.gvAccept(bb.Name,bb.Value)then table.insert(cb.items,{kind="val",inst=bb,orig=bb.Value,last=bb.Value})end end end)end end;if type(getgc)=="function"then pcall(function()local b4=getgc(true)for cR,S in ipairs(b4)do if type(S)=="table"and getmetatable(S)==nil then pcall(function()local eT=0;for a1,L in next,S do eT=eT+1;if eT>60 then break end;if ai.gvAccept(a1,L)then table.insert(cb.items,{kind="tbl",tbl=S,key=a1,orig=L,last=L})end end end)end;if cR%800==0 then task.wait()end end end)end;cb.found=#cb.items;cb.scanning=false;I("Game speed values found: "..cb.found)end)end;function ai.gvSet(dh)local cb=ai.gv;if#cb.items==0 and not cb.scanning then ai.gvScan()end;for g,eU in ipairs(cb.items)do pcall(function()local du;if eU.kind=="attr"then du=eU.inst:GetAttribute(eU.key)elseif eU.kind=="val"then du=eU.inst.Value else du=rawget(eU.tbl,eU.key)end;if du~=eU.last and type(du)=="number"then eU.orig=du end;local L=eU.orig*dh;if eU.kind=="attr"then eU.inst:SetAttribute(eU.key,L)elseif eU.kind=="val"then eU.inst.Value=L else rawset(eU.tbl,eU.key,L)end;eU.last=L end)end;cb.applied=true end;function ai.gvRestore()local cb=ai.gv;if not cb.applied then return end;for g,eU in ipairs(cb.items)do pcall(function()if eU.kind=="attr"then eU.inst:SetAttribute(eU.key,eU.orig)elseif eU.kind=="val"then eU.inst.Value=eU.orig else rawset(eU.tbl,eU.key,eU.orig)end;eU.last=eU.orig end)end;cb.applied=false end;ai.gameChain={"CFrame","Input","AttrWS","AttrBoost"}ai.gameChainNames={Input="a bigger stick signal",AttrWS="the character's WalkSpeed value",AttrBoost="the character's SpeedBoost value",CFrame="moving the character"}function ai.inputStep(ec,ey,ew,eV)local bI=ai.probe;if not bI then bI={t=0,d=0,base=nil,idx=1,locked=nil,results={}}ai.probe=bI end;if ew<=0 or ey.Magnitude<0.5 then bI.t,bI.d=0,0;return bI.locked or ai.gameChain[bI.idx],ew end;local cd=ey.Unit;if bI.lastDir and cd:Dot(bI.lastDir)<0.7 then bI.t,bI.d=0,0 end;bI.lastDir=cd;bI.t=bI.t+ec;bI.d=bI.d+eV;if not bI.base then if bI.t>=0.5 then if bI.d/bI.t>=1.5 then bI.base=bI.d/bI.t end;bI.t,bI.d=0,0 end;return ai.gameChain[bI.idx],0 end;if bI.locked then return bI.locked,ew end;local bJ=ai.gameChain[bI.idx]if bI.t>=1.2 then local L=bI.d/bI.t;bI.results[bJ]=L;I(string.format("Speed through %s: %.1f studs/s, %.1f without",ai.gameChainNames[bJ],L,bI.base))if L>=bI.base*1.2 then bI.locked=bJ;ao("Speed boost","WORKS",3)else bI.idx=bI.idx+1;bI.t,bI.d=0,0;if bI.idx>#ai.gameChain then bI.locked="Input"ao("Speed boost","DOESN'T WORK",4)else ao("Speed boost","not yet, trying another way",2)end;bJ=bI.locked or ai.gameChain[bI.idx]end end;return bJ,ew end;ai.normal=nil;function ai.report(ec,ey,ew,eW)local bI=ai.rep;if not bI then bI={t=0,d=0,noted=false}ai.rep=bI end;if ey.Magnitude<0.5 then bI.t,bI.d=0,0;return end;local cd=ey.Unit;if bI.lastDir and cd:Dot(bI.lastDir)<0.7 then bI.t,bI.d=0,0 end;bI.lastDir=cd;bI.t=bI.t+ec;bI.d=bI.d+eW;if ew<=0 then if bI.t>=0.5 then local L=bI.d/bI.t;ai.normal=ai.normal and ai.normal*0.7+L*0.3 or L;bI.t,bI.d=0,0 end;return end;if bI.t>=1.0 and not bI.noted then bI.noted=true;local L=bI.d/bI.t;local eX=ai.normal or ai.gameWS*0.7;I(string.format("Speed boost: %.1f studs/s (normal %.1f, boost +%.1f)",L,eX,ew))if L>=eX+0.4*ew then ao("Speed boost","WORKS",3)else ao("Speed boost","DOESN'T WORK",4)end end end;function ai.autoStep(ec,ey,ew,eV)local M=ai.auto;if M.locked then return M.locked,ew end;local bJ=ai.chain[M.idx]if ew<=0 or ey.Magnitude<0.5 then return bJ,ew end;local cd=ey.Unit;if M.lastDir and cd:Dot(M.lastDir)<0.7 then M.t,M.d,M.e,M.w=0,0,0,0 end;M.lastDir=cd;M.t=M.t+ec;M.d=M.d+eV;M.e=M.e+ew*ec;M.w=M.w+ai.gameWS*ec;if M.t>=0.7 then local dK=math.min(1,ey.Magnitude)local L=M.d/M.t;local eY=M.w/M.t*dK+0.35*M.e/M.t*dK;M.results[bJ]=L;if L>=eY then M.locked=bJ;I(string.format("Speed channel %s works: %.1f studs/s (needed %.1f)",bJ,L,eY))ao("Speed boost","WORKS",3)else M.idx=M.idx+1;M.t,M.d,M.e,M.w=0,0,0,0;if M.idx>#ai.chain then local bO,bL;for bN,eZ in pairs(M.results)do if not bL or eZ>bL then bO,bL=bN,eZ end end;M.locked=bO or"CFrame"I("No speed channel passed; kept "..M.locked)ao("Speed boost","DOESN'T WORK",4)else bJ=ai.chain[M.idx]end end end;return bJ,ew end;function ai.step(ec)ai.inputScale=1;local aR,aw=a7(),am.body()if not aR or not aw or aR.Health<=0 or ec<=0 or ec>0.25 then return end;local e_=ai.test;local ey,f0;if e_ then ey,f0=e_.dir,"test"else ey,f0=am.intent(aR,aw)end;ai.src=f0;ai.mag=ey.Magnitude;if e_ then aR:Move(e_.dir,false)end;local f1=aR.WalkSpeed;if f1~=ai.lastSet and f1>1 then ai.gameWS=f1;ai.minWS=math.min(f1,ai.minWS)end;local H=a4()local f2=H and H:GetAttribute("WalkSpeed")if type(f2)=="number"and f2>1 and f2~=ai.lastAttrWS then ai.gameWS=f2 end;ai.minWS=math.min(ai.gameWS,ai.minWS*(1+0.01*ec))local eV=0;local f3=nil;local f4=a6()if f4 then if ai.seenLast and ai.lastPos then f3=W(f4.Position-ai.seenLast).Magnitude end;ai.seenLast=f4.Position end;if ai.lastPos then local d9=W(aw.Position-ai.lastPos)eV=d9.Magnitude;am.vel=am.vel*0.8+d9/ec*0.2;ai.actual=ai.actual+(eV/ec-ai.actual)*0.2;if ai.lastMove and(aw.Position-ai.lastPos):Dot(ai.lastMove.Unit)<-2.5 then ai.noteRubber()end end;if ai.level>0 and tick()-ai.lastRubber>8 then ai.level=ai.level-1;ai.lastRubber=tick()end;ai.lastPos=aw.Position;local eo,ew;if e_ then eo,ew=e_.method,e_.extra else eo,ew=ar.SpeedChannel,ai.extraNow()if eo=="Auto"and am.gameDirT and workspace:FindFirstChild("ProxyCharacter")then eo="CFrame"ai.report(ec,ey,ew,f3 or eV)elseif eo=="Auto"and am.gameDirT then eo,ew=ai.inputStep(ec,ey,ew,f3 or eV)elseif eo=="Auto"then eo,ew=ai.autoStep(ec,ey,ew,f3 or eV)end end;local f5=ew>0 and ey.Magnitude>0.05 and eo~="none"local ca=a4()if ca and ai.lastAttrWS and(eo~="AttrWS"or not f5)then ca:SetAttribute("WalkSpeed",ai.gameWS)ai.lastAttrWS=nil end;if ca and ai.attrBoostOn and(eo~="AttrBoost"or not f5)then ca:SetAttribute("SpeedBoost",0)ca:SetAttribute("SpeedBoostTime",0)ai.attrBoostOn=false end;ai.lastMove=f5 and ey or nil;ai.extra=f5 and ew or 0;if not f5 or eo~="GameValues"then ai.gvRestore()end;if not f5 then if ai.lastSet then aR.WalkSpeed=ai.gameWS;ai.lastSet=nil end;return end;if eo=="Input"then ai.inputScale=1+ew/math.max(ai.gameWS,1)return end;if eo=="AttrWS"and ca then local f6=ai.gameWS+ew;ca:SetAttribute("WalkSpeed",f6)ai.lastAttrWS=f6;return end;if eo=="AttrBoost"and ca then ca:SetAttribute("SpeedBoost",ew/math.max(ai.gameWS,1))ca:SetAttribute("SpeedBoostTime",0.25)ai.attrBoostOn=true;return end;if eo=="WalkSpeed"then local f6=ai.gameWS+ew;if aR.WalkSpeed~=f6 then aR.WalkSpeed=f6 end;ai.lastSet=f6;return end;if ai.lastSet then aR.WalkSpeed=ai.gameWS;ai.lastSet=nil end;if eo=="GameValues"then ai.gvSet((ai.gameWS+ew)/math.max(ai.gameWS,1))elseif eo=="Velocity"then local L=aw.AssemblyLinearVelocity;local S=ey*(ai.gameWS+ew)aw.AssemblyLinearVelocity=Vector3.new(S.X,L.Y,S.Z)else local eG=ey*ew*ec;if eG.Magnitude>0 and not ag.blocked(aw,ey.Unit,eG.Magnitude)then aw.CFrame=aw.CFrame+eG;am.sync(aw)end end end;function ai.autoPick()if ai.testing then return end;local aR,aw=a7(),a6()if not aR or not aw then ao("Speed test","No character found.",2)return end;ai.testing=true;ao("Speed test","Stand in open space. Your character will walk a few steps.",4)local ea=W(D().CFrame.LookVector)if ea.Magnitude<0.01 then ea=W(aw.CFrame.LookVector)end;ea=ea.Unit;local function f7(eo,ew,cd)ai.test={method=eo,extra=ew,dir=cd}local f8=aw.Position;local dw=f8;local f9=0;local c9=tick()while tick()-c9<0.7 do k.Heartbeat:Wait()local bx=aw.Position;if(bx-dw):Dot(cd)<-2.5 then f9=f9+1 end;dw=bx end;local eu=(aw.Position-f8):Dot(cd)ai.test=nil;if eo=="WalkSpeed"then aR.WalkSpeed=ai.gameWS end;task.wait(0.4)return math.abs(eu),f9 end;local a9,ef=pcall(function()local cH=f7("none",0,ea)cH=math.max(cH,1)local fa,fb=nil,1.2;local cW={}for cR,bJ in ipairs({"CFrame","Velocity","WalkSpeed"})do local eu,f9=f7(bJ,20,cR%2==1 and-ea or ea)local fc=eu/cH;table.insert(cW,string.format("%s x%.2f%s",bJ,fc,f9>1 and" (pulled back)"or""))if f9<=1 and fc>fb then fa,fb=bJ,fc end end;I("Speed test: "..table.concat(cW,", "))if fa then aa.set("SpeedChannel",fa)ai.resetAuto()ao("Speed test","Best channel: "..fa.."  ("..table.concat(cW,", ")..")",6)else ao("Speed test","No channel made you faster in this walk test. Try Auto while running, it also tries the game's own speed values. "..table.concat(cW,", "),7)end end)ai.test=nil;ai.testing=false;if not a9 then I("Speed test error: "..tostring(ef))end end;function aj.hasBall()local bN=a4()local bK=bN and bN:FindFirstChild("Attributes")local bL=bK and bK:FindFirstChild("Basketball")if bL and bL.Value~=nil then return true end;return ad.holding==true end;function aj.hop(N)local aw=am.body()if not aw or not N or aj.hopping then return false end;aj.hopping=true;local fd=aw.CFrame;local fe=nil;local ff=false;local function fg()if ff or not fe then return end;pcall(function()local eu=aw.Position-fe;if eu.Magnitude<6 then fd=fd+eu end;aw.CFrame=aw.CFrame+fd.Position-aw.Position;fe=nil end)end;local fh=pcall(function()k:BindToRenderStep("JHHopShow",0,fg)end)task.spawn(function()local fi=math.max(1,math.floor(ar.MagnetFrames or 1))local c9=tick()local bc=0;while tick()-c9<1.2 do k.Heartbeat:Wait()bc=bc+1;pcall(function()local bI=N.Position;local W=Vector3.new(aw.Position.X-bI.X,0,aw.Position.Z-bI.Z)if W.Magnitude<0.1 then W=Vector3.new(0,0,1)end;local fj=Vector3.new(bI.X,aw.Position.Y,bI.Z)+W.Unit*1.2;aw.CFrame=aw.CFrame+fj-aw.Position;fe=aw.Position;am.sync(aw)end)if bc>=fi and aj.hasBall()then for g=1,4 do k.Heartbeat:Wait()pcall(function()aw.CFrame=aw.CFrame+Vector3.new(N.Position.X,aw.Position.Y,N.Position.Z)-aw.Position;fe=aw.Position end)end;break end end;local bj=false;local function fk()if bj then return end;bj=true;ff=true;pcall(function()aw.CFrame=aw.CFrame+fd.Position-aw.Position;aw.AssemblyLinearVelocity=Vector3.new(0,aw.AssemblyLinearVelocity.Y,0)am.sync(aw)end)if fh then pcall(function()k:UnbindFromRenderStep("JHHopShow")end)end;aj.hopping=false end;local fl=pcall(function()k:BindToRenderStep("JHHop",0,function()fk()k:UnbindFromRenderStep("JHHop")end)end)if not fl then k.RenderStepped:Wait()fk()else task.delay(0.2,fk)end end)return true end;do local fm={}aj.V=fm;fm.orig,fm.tmpl,fm.extras,fm.logoImg,fm.saved={},{},{},{},{}fm.isExtra={}fm.labels={overall={},coins={},badges={}}fm.LOGOS={Owner={text="OWNER",color=Color3.fromRGB(255,196,40),words={"owner"}},YouTube={text="YOUTUBE",color=Color3.fromRGB(255,0,0),words={"youtube","yt"}},Twitch={text="TWITCH",color=Color3.fromRGB(145,70,255),words={"twitch"}},TikTok={text="TIKTOK",color=Color3.fromRGB(30,30,30),words={"tiktok"}},Dev={text="DEV",color=Color3.fromRGB(60,140,255),words={"dev","developer"}}}fm.LOGO_NAMES={"Owner","YouTube","Twitch","TikTok","Dev"}local function fn(aw,a3,N)return Color3.fromRGB(aw,a3,N)end;fm.MASCOTS={SpongeBob={skin=fn(255,226,60),shirt=fn(255,255,255),pants=fn(130,85,40),eyes=true,label="SpongeBob"},Patrick={skin=fn(255,140,165),shirt=fn(255,140,165),pants=fn(70,170,90),eyes=true,label="Patrick"},Squidward={skin=fn(120,200,200),shirt=fn(120,200,200),pants=fn(110,90,60),nose=fn(120,200,200),label="Squidward"},Jeffy={skin=fn(255,205,150),shirt=fn(255,215,40),pants=fn(70,100,190),label="Jeffy"},IShowSpeed={skin=fn(150,100,70),shirt=fn(220,30,40),pants=fn(25,25,25),label="IShowSpeed"},MrBeast={skin=fn(235,190,150),shirt=fn(50,120,230),pants=fn(40,45,70),label="MrBeast"},Banana={skin=fn(255,225,53),shirt=fn(255,225,53),pants=fn(255,225,53),hat=fn(110,75,30),label="Banana"},Curry={skin=fn(150,100,72),shirt=fn(255,199,44),pants=fn(29,66,138),label="Curry 30"},LeBron={skin=fn(110,70,50),shirt=fn(85,37,130),pants=fn(85,37,130),label="LeBron"},Kyrie={skin=fn(140,95,70),shirt=fn(0,83,188),pants=fn(0,83,188),label="Kyrie 11"},Wemby={skin=fn(170,120,90),shirt=fn(20,20,20),pants=fn(195,202,206),label="Wemby 1"},Mickey={skin=fn(20,20,20),shirt=fn(20,20,20),pants=fn(215,30,30),hands=fn(255,255,255),ears=fn(20,20,20),label="Mickey"}}fm.MASCOT_NAMES={"SpongeBob","Patrick","Squidward","Jeffy","IShowSpeed","MrBeast","Banana","Curry","LeBron","Kyrie","Wemby","Mickey"}local function fo(bk,V)return string.find(string.lower(bk),"%f[%a]"..V.."%f[%A]")~=nil end;function fm.findLogo(h)if fm.logoImg[h]~=nil then return fm.logoImg[h]or nil end;local fp=fm.LOGOS[h]local bp;local fq={s,u:FindFirstChild("PlayerGui"),game:GetService("StarterGui"),workspace}local bc=0;for g,cU in ipairs(fq)do if cU and not bp then for g,bb in ipairs(cU:GetDescendants())do bc=bc+1;if bc%1500==0 then task.wait()end;if bb:IsA("ImageLabel")or bb:IsA("ImageButton")or bb:IsA("Decal")or bb:IsA("Texture")then local fr=bb:IsA("Decal")and bb.Texture or(bb:IsA("Texture")and bb.Texture or bb.Image)if type(fr)=="string"and fr~=""then for g,V in ipairs(fp.words)do if fo(bb.Name,V)or bb.Parent and fo(bb.Parent.Name,V)then bp=fr;break end end end;if bp then break end end end end end;fm.logoImg[h]=bp or false;return bp end;function fm.clearLogo()if fm.logoGui then pcall(function()fm.logoGui:Destroy()end)end;fm.logoGui,fm.logoKey,fm.logoChar=nil,nil,nil end;function fm.applyLogo(h)fm.clearLogo()local H=a4()local fs=H and(H:FindFirstChild("Head")or H:FindFirstChild("HumanoidRootPart"))local fp=fm.LOGOS[h]if not fs or not fp then return end;local a3=Instance.new("BillboardGui")a3.Name="JHLogo"a3.Size=UDim2.new(0,110,0,40)a3.StudsOffset=Vector3.new(0,3.6,0)a3.AlwaysOnTop=true;a3.Adornee=fs;local fr=fm.customLogo(h)or fm.logoImg[h]if fr then local ft=Instance.new("ImageLabel")ft.BackgroundTransparency=1;ft.Size=UDim2.new(1,0,1,0)ft.ScaleType=Enum.ScaleType.Fit;ft.Image=fr;ft.Parent=a3 else local a5=Instance.new("Frame")a5.Size=UDim2.new(1,0,1,0)a5.BackgroundColor3=fp.color;a5.BackgroundTransparency=0.1;a5.Parent=a3;local fu=Instance.new("UICorner")fu.CornerRadius=UDim.new(0,10)fu.Parent=a5;local S=Instance.new("TextLabel")S.BackgroundTransparency=1;S.Size=UDim2.new(1,0,1,0)S.Font=Enum.Font.GothamBlack;S.TextScaled=true;S.TextColor3=Color3.new(1,1,1)S.Text=fp.text;S.Parent=a5 end;a3.Parent=fs;fm.logoGui,fm.logoKey,fm.logoChar=a3,h,H end;local function fv(en,fw)if fm.orig[en]==nil then fm.orig[en]=en.Color end;en.Color=fw end;function fm.clearMascot()for en,fx in pairs(fm.orig)do pcall(function()if en.Parent then en.Color=fx end end)end;fm.orig={}for cB,fy in pairs(fm.tmpl)do pcall(function()cB[fy[1]]=fy[2]end)end;fm.tmpl={}for g,fz in ipairs(fm.extras)do pcall(function()fz:Destroy()end)end;fm.extras={}fm.isExtra={}fm.mascotKey,fm.mascotChar=nil,nil end;local function ew(H,a0,fA,fw,fB,fC)local bI=Instance.new("Part")bI.Size=fA;bI.Color=fw;bI.Material=Enum.Material.SmoothPlastic;bI.CanCollide,bI.CanQuery,bI.CanTouch,bI.Massless=false,false,false,true;if fB then pcall(function()bI.Shape=fB end)end;bI.CFrame=a0.CFrame*fC;bI.Parent=H;local V=Instance.new("WeldConstraint")V.Part0,V.Part1=bI,a0;V.Parent=bI;fm.extras[#fm.extras+1]=bI;return bI end;local fD={head={"Head"},torso={"UpperTorso","Torso"},larm={"LeftUpperArm","Left Arm"},rarm={"RightUpperArm","Right Arm"},lleg={"LeftUpperLeg","Left Leg"},rleg={"RightUpperLeg","Right Leg"}}local function fE(H,h)for g,bc in ipairs(fD[h])do local bI=H:FindFirstChild(bc)if bI then return bI end end end;local fF,fG=Enum.PartType.Ball,Enum.PartType.Cylinder;local v,fH=Color3.new(1,1,1),Color3.new(0,0,0)function fm.hideOriginal(H)for g,bb in ipairs(H:GetDescendants())do if bb:IsA("BasePart")and bb.Name~="HumanoidRootPart"and not fm.isExtra[bb]or bb:IsA("Decal")then if fm.tmpl[bb]==nil then fm.tmpl[bb]={"Transparency",bb.Transparency}end;bb.Transparency=1 end end end;function fm.build(H,h)local fp=fm.BUILDS[h]local fs=fE(H,"head")if not fp or not fs or not fE(H,"torso")then return false end;local fI=H:FindFirstChild("UpperTorso")~=nil;local a1=fs.Size.Y/(fI and 1.2 or 1)local function bF(fJ,fB,fK,fL,fM,fN,fO,fP,fw,fQ,fR)local fS=fE(H,fJ)if not fS then return nil end;local fT=0;if fI and fJ~="head"then fT=fJ=="torso"and-0.2 or-0.4 end;local en=ew(H,fS,Vector3.new(fK,fL,fM)*a1,fw,fB,CFrame.new(fN*a1,(fO+fT)*a1,fP*a1)*(fR or CFrame.new()))if fQ then en.Material=fQ end;fm.isExtra[en]=true;return en end;local function fU(fJ,dG,bC,fV,fA,fW)local fz=bF(fJ,fF,fA,fA,fA*0.6,dG,bC,fV,v)if fz then bF(fJ,fF,fA*0.5,fA*0.5,fA*0.3,dG,bC,fV-fA*0.28,fW or fH)bF(fJ,fF,fA*0.22,fA*0.22,fA*0.2,dG,bC,fV-fA*0.4,fH)end end;local function fX(av,fw,fJ)local fS=fE(H,fJ or"torso")if not fS then return end;for g,fY in ipairs({Enum.NormalId.Front,Enum.NormalId.Back})do local fZ=Instance.new("SurfaceGui")fZ.Face=fY;fZ.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;fZ.PixelsPerStud=40;local S=Instance.new("TextLabel")S.BackgroundTransparency=1;S.Size=UDim2.new(1,0,1,0)S.Font=Enum.Font.GothamBlack;S.TextScaled=true;S.TextColor3=fw;S.Text=av;S.Parent=fZ;fZ.Parent=fm.torsoPart[1]fm.extras[#fm.extras+1]=fZ end end;fm.torsoPart={}local f_={add=bF,eye=fU,num=fX,BALL=fF,CYL=fG,WHITE=v,BLACK=fH}local a9,ef=pcall(fp,f_)if not a9 then pcall(I,"Costume build: "..tostring(ef))end;return a9 end;local function a_(M,_)local g0,g1,g2,g3=_.skin,_.shirt,_.pants,_.hand or _.skin;local d3=_.headSize or 1.3;if _.headBlock then M.add("head",nil,d3*1.7,d3*1.2,d3,0,0.1,0,g0)else M.add("head",M.BALL,d3*1.4,d3*1.4,d3*1.4,0,0.1,0,g0)end;local g4,g5=_.tw or 2.1,_.th or 2.1;fm.torsoPart[1]=M.add("torso",nil,g4,g5,1.1,0,0,0,g1)if _.pantsTop~=false then M.add("torso",nil,g4+0.05,g5*0.32,1.15,0,-g5*0.34,0,g2)end;local f2=_.aw or 1.05;for g,P in ipairs({{"larm",-1},{"rarm",1}})do M.add(P[1],nil,f2,1.2,f2,0,0.45,0,_.sleeve or g1)M.add(P[1],nil,f2*0.95,0.9,f2*0.95,0,-0.55,0,g0)M.add(P[1],M.BALL,f2*1.15,f2*1.15,f2*1.15,0,-1.05,0,g3)end;local g6=_.lw or 1.05;for g,P in ipairs({"lleg","rleg"})do M.add(P,nil,g6,1.3,g6,0,0.35,0,g2)M.add(P,nil,g6*0.95,0.8,g6*0.95,0,-0.55,0,_.leg or g0)M.add(P,nil,g6*1.1,0.45,g6*1.9,0,-0.95,-0.35,_.shoe or Color3.fromRGB(30,30,30))end end;local function fn(aw,a3,N)return Color3.fromRGB(aw,a3,N)end;local function g7(M,bC,fV,V,fx)M.add("head",nil,V,0.1,0.1,0,bC,fV,fx or fH)M.add("head",nil,0.1,0.12,0.1,-V/2,bC+0.06,fV,fx or fH)M.add("head",nil,0.1,0.12,0.1,V/2,bC+0.06,fV,fx or fH)end;fm.BUILDS={SpongeBob=function(M)local g8=fn(255,226,60)a_(M,{skin=g8,shirt=v,pants=fn(130,85,40),sleeve=v,aw=0.55,lw=0.55,leg=v,shoe=fH,headBlock=true,headSize=1.6,tw=2.4,th=1.8,hand=g8})M.add("torso",nil,2.5,0.25,1.2,0,0.6,0,v)M.add("torso",nil,0.3,1.0,0.15,0,0.2,-0.6,fn(215,30,30))M.add("head",nil,2.7,0.35,1.4,0,-0.35,0,g8)M.eye("head",-0.45,0.35,-0.7,0.9,fn(90,170,255))M.eye("head",0.45,0.35,-0.7,0.9,fn(90,170,255))M.add("head",nil,0.35,0.4,0.1,-0.15,-0.55,-0.72,v)M.add("head",nil,0.35,0.4,0.1,0.15,-0.55,-0.72,v)g7(M,-0.35,-0.72,1.1)M.add("head",M.BALL,0.4,0.4,0.1,-0.95,-0.25,-0.7,fn(255,160,140))M.add("head",M.BALL,0.4,0.4,0.1,0.95,-0.25,-0.7,fn(255,160,140))M.add("head",M.BALL,0.25,0.25,0.1,-0.9,0.9,-0.65,fn(215,175,30))M.add("head",M.BALL,0.2,0.2,0.1,0.8,0.6,-0.65,fn(215,175,30))end,Patrick=function(M)local g9=fn(255,140,165)a_(M,{skin=g9,shirt=g9,pants=fn(70,170,90),aw=1.1,lw=1.1,shoe=g9,headSize=1.5,tw=2.4,th=2.2,pantsTop=true})M.add("head",nil,0.9,1.1,0.9,0,0.9,0,g9,nil,CFrame.Angles(0,0,math.rad(45)))M.eye("head",-0.4,0.15,-0.95,0.55)M.eye("head",0.4,0.15,-0.95,0.55)g7(M,-0.45,-0.98,0.7)M.add("torso",M.BALL,0.5,0.5,0.1,0.5,0.7,-0.6,fn(180,40,150))M.add("torso",M.BALL,0.4,0.4,0.1,-0.6,0.3,-0.6,fn(180,40,150))M.add("torso",M.BALL,0.45,0.45,0.1,0.6,-0.8,-0.6,fn(190,60,160))end,Squidward=function(M)local ga=fn(120,200,200)a_(M,{skin=ga,shirt=fn(170,225,225),pants=fn(110,90,60),aw=0.8,lw=0.85,shoe=ga,headBlock=false,headSize=1.5,tw=1.9})M.add("head",M.BALL,1.5,2.2,1.5,0,0.5,0.1,ga)M.add("head",nil,0.7,0.7,1.7,0,-0.1,-1.1,ga)M.add("head",nil,1.9,0.4,0.4,0,0.2,-0.85,fn(80,150,150))for g,fK in ipairs({-0.45,0.45})do M.add("head",M.BALL,0.6,0.6,0.35,fK,0.4,-0.8,fn(250,250,200))M.add("head",M.BALL,0.25,0.25,0.2,fK,0.3,-1.0,fH)M.add("head",nil,0.7,0.28,0.45,fK,0.62,-0.85,ga)end;M.add("head",M.BALL,0.6,0.4,0.4,-0.5,0.95,0.05,fn(80,150,150))g7(M,-0.85,-0.7,0.8,fn(80,110,110))end,Jeffy=function(M)local ar=fn(255,205,150)a_(M,{skin=ar,shirt=fn(255,215,40),pants=fn(70,100,190),sleeve=fn(255,215,40),tw=1.9,th=1.7,headBlock=false,headSize=1.7,shoe=v})M.add("head",M.BALL,0.7,0.35,1.7,0,1.0,0.05,fn(60,40,25))M.eye("head",-0.45,0.25,-1.0,0.8,fn(90,70,40))M.eye("head",0.45,0.25,-1.0,0.8,fn(90,70,40))M.add("head",nil,0.9,0.25,0.15,0,-0.45,-1.1,fn(120,40,40))M.add("head",nil,0.5,0.25,0.1,0.25,-0.65,-1.1,fn(230,100,120))M.add("torso",nil,0.9,0.25,0.15,0,0.5,-0.6,fn(255,255,255))end,IShowSpeed=function(M)local gb=fn(150,100,70)a_(M,{skin=gb,shirt=fn(220,30,40),pants=fn(25,25,25),sleeve=fn(220,30,40),headSize=1.35,shoe=v})M.add("head",nil,1.85,0.7,1.6,0,0.85,0,fn(20,20,20))M.add("head",nil,1.7,0.35,0.2,0,0.15,-0.8,fn(20,20,20))M.eye("head",-0.35,0.05,-0.85,0.5)M.eye("head",0.35,0.05,-0.85,0.5)M.add("head",nil,1.2,0.4,0.2,0,-0.55,-0.75,fn(30,25,20))g7(M,-0.45,-0.88,0.7,v)M.add("torso",nil,1.6,0.35,0.15,0,0.5,-0.6,v)end,MrBeast=function(M)local gc=fn(235,190,150)a_(M,{skin=gc,shirt=fn(50,120,230),pants=fn(40,45,70),sleeve=fn(50,120,230),tw=2.3,aw=1.15,headSize=1.35,shoe=v})M.add("head",nil,1.9,0.55,1.65,0,0.9,0,fn(60,40,30))M.eye("head",-0.35,0.1,-0.85,0.5,fn(80,120,160))M.eye("head",0.35,0.1,-0.85,0.5,fn(80,120,160))M.add("head",nil,1.1,0.5,0.2,0,-0.5,-0.78,fn(110,80,60))g7(M,-0.4,-0.92,0.6,v)M.add("torso",nil,1.0,0.3,0.15,0,0.55,-0.6,fn(255,215,40))end,Banana=function(M)local g8=fn(255,225,53)M.add("head",M.BALL,1.7,1.9,1.5,0,0.1,0,g8)M.add("head",nil,0.5,0.5,0.5,0,1.15,0,fn(110,75,30))M.add("torso",nil,2.4,2.1,1.4,0,0,0,g8)M.add("torso",M.BALL,2.6,2.6,1.5,0,-0.1,0,g8)for g,P in ipairs({"larm","rarm"})do M.add(P,nil,0.7,2.0,0.7,0,0,0,g8)end;for g,P in ipairs({"lleg","rleg"})do M.add(P,nil,0.8,2.0,0.8,0,0,0,g8)M.add(P,nil,0.9,0.4,1.4,0,-1.0,-0.25,fn(140,100,50))end;M.eye("head",-0.4,0.45,-0.7,0.6)M.eye("head",0.4,0.45,-0.7,0.6)g7(M,-0.2,-0.76,0.8)M.add("head",M.BALL,0.25,0.25,0.1,-0.7,0.9,-0.6,fn(200,160,40))end,Curry=function(M)local gd=fn(150,100,72)a_(M,{skin=gd,shirt=fn(255,199,44),pants=fn(29,66,138),sleeve=fn(255,199,44),shoe=fn(255,199,44),headSize=1.3})M.add("head",nil,1.5,0.45,1.3,0,0.75,0,fn(20,15,12))M.eye("head",-0.35,0.05,-0.8,0.42)M.eye("head",0.35,0.05,-0.8,0.42)g7(M,-0.4,-0.88,0.5,fn(90,40,30))M.num("30",fn(29,66,138))M.add("torso",nil,2.15,0.15,1.15,0,0.95,0,fn(29,66,138))end,LeBron=function(M)local gd=fn(110,70,50)a_(M,{skin=gd,shirt=fn(85,37,130),pants=fn(85,37,130),sleeve=fn(85,37,130),shoe=fn(255,199,44),tw=2.3,aw=1.15,headSize=1.3})M.add("head",nil,1.45,0.3,1.3,0,0.75,0,fn(20,15,12))M.add("head",nil,1.7,0.25,1.5,0,0.6,0,fn(255,199,44))M.eye("head",-0.35,0.05,-0.8,0.42)M.eye("head",0.35,0.05,-0.8,0.42)M.add("head",nil,1.2,0.5,0.25,0,-0.5,-0.75,fn(25,20,18))g7(M,-0.35,-0.9,0.5,v)M.num("23",fn(255,199,44))M.add("torso",nil,2.35,0.15,1.15,0,0.95,0,fn(255,199,44))end,Kyrie=function(M)local gd=fn(140,95,70)a_(M,{skin=gd,shirt=fn(0,83,188),pants=fn(0,83,188),sleeve=fn(0,83,188),shoe=fn(255,255,255),headSize=1.3})M.add("head",nil,1.5,0.4,1.3,0,0.75,0,fn(20,15,12))M.eye("head",-0.35,0.05,-0.8,0.42)M.eye("head",0.35,0.05,-0.8,0.42)M.add("head",nil,1.0,0.3,0.2,0,-0.5,-0.78,fn(25,20,18))g7(M,-0.4,-0.9,0.5,v)M.num("11",v)end,Wemby=function(M)local gd=fn(170,120,90)a_(M,{skin=gd,shirt=fn(20,20,20),pants=fn(195,202,206),sleeve=fn(20,20,20),shoe=v,aw=1.0,lw=1.0,headSize=1.3})M.add("head",nil,1.4,0.35,1.25,0,0.75,0,fn(25,20,18))M.eye("head",-0.35,0.05,-0.8,0.42)M.eye("head",0.35,0.05,-0.8,0.42)g7(M,-0.4,-0.9,0.5,fn(90,40,30))M.num("1",fn(195,202,206))end,Mickey=function(M)local ge=fn(20,20,20)M.add("head",M.BALL,1.8,1.8,1.8,0,0.1,0,ge)M.add("head",M.BALL,1.5,1.2,0.35,0,-0.2,-0.78,fn(255,222,190))for g,fK in ipairs({-1.0,1.0})do M.add("head",fG,0.3,1.1,1.1,fK,1.0,0,ge,nil,CFrame.Angles(0,0,math.rad(90)))end;M.eye("head",-0.3,0.3,-0.92,0.5)M.eye("head",0.3,0.3,-0.92,0.5)M.add("head",M.BALL,0.4,0.3,0.3,0,-0.05,-1.0,ge)g7(M,-0.45,-0.95,0.8,fn(150,30,30))a_(M,{skin=ge,shirt=ge,pants=fn(215,30,30),sleeve=ge,hand=v,shoe=fn(255,200,40),headSize=0.1})M.add("torso",M.BALL,0.3,0.3,0.1,-0.4,-0.5,-0.65,v)M.add("torso",M.BALL,0.3,0.3,0.1,0.4,-0.5,-0.65,v)end}function fm.applyMascot(h)fm.clearMascot()local fp=fm.MASCOTS[h]local H=a4()if not fp or not H then return end;for g,bb in ipairs(H:GetDescendants())do if bb:IsA("Shirt")then fm.tmpl[bb]={"ShirtTemplate",bb.ShirtTemplate}bb.ShirtTemplate=""end;if bb:IsA("Pants")then fm.tmpl[bb]={"PantsTemplate",bb.PantsTemplate}bb.PantsTemplate=""end;if bb:IsA("ShirtGraphic")then fm.tmpl[bb]={"Graphic",bb.Graphic}bb.Graphic=""end;if bb:IsA("BasePart")and bb.Name~="HumanoidRootPart"and not bb:FindFirstAncestorOfClass("Accessory")then local bc=bb.Name;if bc=="Head"then fv(bb,fp.skin)elseif bc=="LowerTorso"then fv(bb,fp.pants)elseif string.find(bc,"Torso",1,true)then fv(bb,fp.shirt)elseif string.find(bc,"Hand",1,true)then fv(bb,fp.hands or fp.skin)elseif string.find(bc,"Arm",1,true)then fv(bb,fp.skin)elseif string.find(bc,"Leg",1,true)or string.find(bc,"Foot",1,true)then fv(bb,fp.pants)end end end;local gf=false;if fm.BUILDS[h]then fm.hideOriginal(H)gf=fm.build(H,h)if not gf then for cB,fy in pairs(fm.tmpl)do if fy[1]=="Transparency"then pcall(function()cB.Transparency=fy[2]end)fm.tmpl[cB]=nil end end end end;local fs=H:FindFirstChild("Head")if fs and not gf then if fp.eyes then for g,fK in ipairs({-0.3,0.3})do local fz=ew(H,fs,Vector3.new(0.55,0.55,0.3),Color3.new(1,1,1),Enum.PartType.Ball,CFrame.new(fK,0.2,-0.5))ew(H,fz,Vector3.new(0.2,0.2,0.2),Color3.new(0,0,0),Enum.PartType.Ball,CFrame.new(0,0,-0.1))end end;if fp.nose then ew(H,fs,Vector3.new(0.45,0.45,1.2),fp.nose,Enum.PartType.Cylinder,CFrame.new(0,-0.1,-0.9)*CFrame.Angles(0,math.rad(90),0))end;if fp.ears then for g,fK in ipairs({-0.75,0.75})do ew(H,fs,Vector3.new(0.9,0.9,0.3),fp.ears,Enum.PartType.Ball,CFrame.new(fK,0.85,0))end end;if fp.hat then ew(H,fs,Vector3.new(0.5,0.5,0.5),fp.hat,nil,CFrame.new(0,0.85,0))end end;fm.mascotKey,fm.mascotChar=h,H end;local gg={overall={"overall","ovr"},coins={"coins","coin","cash","money","currency"},badges={"badge","badges"}}function fm.scanLabels()if fm.scanning then return end;fm.scanning=true;task.spawn(function()local aS=u:FindFirstChild("PlayerGui")if aS then local bc=0;local bp={overall={},coins={},badges={}}for g,bb in ipairs(aS:GetDescendants())do bc=bc+1;if bc%1500==0 then task.wait()end;if bb:IsA("TextLabel")or bb:IsA("TextButton")then local gh={bb.Name,bb.Parent and bb.Parent.Name or"",bb.Parent and bb.Parent.Parent and bb.Parent.Parent.Name or""}for aF,U in pairs(gg)do for g,gi in ipairs(gh)do local gj=string.lower(gi)for g,V in ipairs(U)do if string.find(gj,V,1,true)then bp[aF][bb]=true end end end end end end;fm.labels=bp end;fm.scanning=false;fm.scanT=tick()end)end;local function gk(aF,G)for bb in pairs(fm.labels[aF])do if bb.Parent then pcall(function()local gl=G(bb.Text)if gl and gl~=bb.Text then bb.Text=gl end end)end end end;local function gm(cB,bk)local h=cB;fm.saved[h]=fm.saved[h]or{}if fm.saved[h][bk]==nil then fm.saved[h][bk]=cB:GetAttribute(bk)or false end end;function fm.maxStep()local bw=ar.MaxOverall or ar.MaxCoins or ar.MaxBadges;if not bw then return end;if(not fm.scanT or tick()-fm.scanT>8)and not fm.scanning then fm.scanStarted=tick()fm.scanLabels()end;local H=a4()if ar.MaxOverall then for g,_ in ipairs({u,H})do if _ and _:GetAttribute("Overall")~=nil and _:GetAttribute("Overall")~=99 then gm(_,"Overall")_:SetAttribute("Overall",99)end end;gk("overall",function(S)if string.find(S,"%d")then return string.gsub(S,"%d+","99",1)end end)end;if ar.MaxCoins then local gn=999999999;local go=u:FindFirstChild("leaderstats")if go then for g,L in ipairs(go:GetChildren())do local gj=string.lower(L.Name)if(L:IsA("IntValue")or L:IsA("NumberValue"))and(string.find(gj,"coin",1,true)or string.find(gj,"cash",1,true)or string.find(gj,"money",1,true))then fm.saved[L]=fm.saved[L]or{Value=L.Value}L.Value=gn end end end;for a1,aB in pairs(u:GetAttributes())do local gj=string.lower(a1)if type(aB)=="number"and(string.find(gj,"coin",1,true)or string.find(gj,"cash",1,true)or string.find(gj,"money",1,true))and aB~=gn then gm(u,a1)u:SetAttribute(a1,gn)end end;gk("coins",function(S)if string.find(S,"%d")then return string.gsub(S,"[%d,%.]+","999,999,999",1)end end)end;if ar.MaxBadges then local gp=H and H:GetAttribute("MaxBadgePoints")or 109;if H and H:GetAttribute("BadgePoints")~=nil and H:GetAttribute("BadgePoints")~=gp then gm(H,"BadgePoints")H:SetAttribute("BadgePoints",gp)end;gk("badges",function(S)if string.find(S,"%d+%s*/%s*%d+")then return string.gsub(S,"%d+(%s*/%s*)%d+",tostring(gp).."%1"..tostring(gp),1)end;if string.find(S,"^%s*%d+%s*$")then return tostring(gp)end end)end end;function fm.restoreStats()for cB,fy in pairs(fm.saved)do pcall(function()for bk,aB in pairs(fy)do if bk=="Value"then cB.Value=aB else cB:SetAttribute(bk,aB~=false and aB or nil)end end end)end;fm.saved={}end;function fm.step()local bZ=tick()if fm.t and bZ-fm.t<0.5 then return end;fm.t=bZ;local H=a4()pcall(fm.stepVisuals,H)pcall(fm.maxStep)if not(ar.MaxOverall or ar.MaxCoins or ar.MaxBadges)and next(fm.saved)then pcall(fm.restoreStats)end end;function fm.stepVisuals(H)if ar.LogoOn then local h=ar.Logo;if fm.LOGOS[h]and(fm.logoKey~=h or fm.logoChar~=H or not(fm.logoGui and fm.logoGui.Parent))then if fm.logoImg[h]==nil then if not fm.finding then fm.finding=true;task.spawn(function()pcall(fm.findLogo,h)fm.finding=false end)end else fm.applyLogo(h)end end elseif fm.logoGui then fm.clearLogo()end;if ar.MascotOn then local h=ar.Mascot;if fm.MASCOTS[h]and(fm.mascotKey~=h or fm.mascotChar~=H)then fm.applyMascot(h)end elseif fm.mascotKey then fm.clearMascot()end end;function fm.cleanup()pcall(fm.clearLogo)pcall(fm.clearMascot)pcall(fm.restoreStats)end end;an.on=false;an.lines={}an.bytes=0;an.cap=400000;an.t0=0;an.conns={}an.hooked=false;an.labelText={}an.attrCache={}an.header={}an.repl,an.replIn=0,0;an.lastMoveKey,an.lastMoveT="",0;an.lastBallKey,an.lastBallT="",0;an.lastPosKey,an.lastPosT="",0;an.btnSet={}an.noChar=0;function an.add(aF,av)if not an.on then return end;local gq=string.format("%.2f %s %s",tick()-an.t0,aF,av)an.lines[#an.lines+1]=gq;an.bytes=an.bytes+#gq+1;while an.bytes>an.cap and#an.lines>1 do an.bytes=an.bytes-#table.remove(an.lines,1)-1 end end;function an.short(cB)local aE,_={},cB;while _ and _~=game and#aE<3 do table.insert(aE,1,_.Name)_=_.Parent end;return table.concat(aE,"/")end;function an.fmt(L,gr)local S=typeof(L)if S=="string"then return'"'..string.sub(L,1,300)..'"'end;if S=="number"then return string.format("%.4g",L)end;if S=="boolean"or S=="nil"then return tostring(L)end;if S=="Instance"then local a9,P=pcall(an.short,L)return a9 and"<"..P..">"or"<instance>"end;if S=="NumberRange"then return string.format("NR(%.4g,%.4g)",L.Min,L.Max)end;if S=="NumberSequence"then local a1={}for g,gs in ipairs(L.Keypoints)do a1[#a1+1]=string.format("%.3g:%.3g",gs.Time,gs.Value)end;return"NS("..table.concat(a1," ")..")"end;if S=="Vector3"then return string.format("V3(%.1f,%.1f,%.1f)",L.X,L.Y,L.Z)end;if S=="Vector2"then return string.format("V2(%.1f,%.1f)",L.X,L.Y)end;if S=="CFrame"then return string.format("CF(%.1f,%.1f,%.1f)",L.Position.X,L.Position.Y,L.Position.Z)end;if S=="table"then if(gr or 0)>=2 then return"{...}"end;local aE,bc={},0;for a1,aB in pairs(L)do bc=bc+1;if bc>8 then aE[#aE+1]="..."break end;aE[#aE+1]=tostring(a1).."="..an.fmt(aB,(gr or 0)+1)end;return"{"..table.concat(aE,",").."}"end;return S end;function an.fmtArgs(c4)local R={}for cR=1,math.min(c4.n,8)do R[cR]=an.fmt(c4[cR],0)end;if c4.n>8 then R[#R+1]="..."end;return table.concat(R,", ")end;function an.guiAt(bx)local b9=u:FindFirstChild("PlayerGui")if not b9 then return"-"end;local bA=a8()for g,bC in ipairs({bx.Y,bx.Y-bA})do local a9,b4=pcall(function()return b9:GetGuiObjectsAtPosition(bx.X,bC)end)if a9 and b4 and#b4>0 then local b6;for g,a3 in ipairs(b4)do if a3:IsA("GuiButton")and not a3:IsDescendantOf(aS)then b6=a3;break end end;b6=b6 or b4[1]return string.format("%s [%s %q]",ac.pathOf(b6),b6.ClassName,ac.btnText(b6))end end;return"(no gui)"end;function an.input(aF,cR)local S=cR.UserInputType;if S==x or S==w then an.add("touch",string.format("%s at %.0f,%.0f on %s",aF,cR.Position.X,cR.Position.Y,an.guiAt(cR.Position)))elseif S==z then an.add("key",tostring(cR.KeyCode.Name).." "..aF)end end;an.spy={}function an.callerOf()if type(getcallingscript)~="function"then return nil end;local a9,gt=pcall(getcallingscript)if not a9 or not gt then return nil end;local bv,au=pcall(function()return an.short(gt)end)return bv and au or tostring(gt)end;function an.spyNote(bk,aF,gu,dj,gv)local fz=an.spy[bk]if not fz then fz={sent=0,exec=0,held=0,boosted=0,recv=0}an.spy[bk]=fz end;if aF=="recv"then fz.recv=fz.recv+1 else fz.sent=fz.sent+1;if dj and string.find(dj,"executor",1,true)then fz.exec=fz.exec+1 end;if dj and string.find(dj,"held back",1,true)then fz.held=fz.held+1 end;if dj and string.find(dj,"boosted",1,true)then fz.boosted=fz.boosted+1 end;if gv then fz.caller=gv end end;fz.first=fz.first or gu;fz.last=gu end;function an.remote(cB,eo,c4,dj,gv)if not an.on then return end;local a9,bk=pcall(function()return cB.Name end)if a9 then pcall(an.spyNote,bk,"send",an.fmtArgs(c4),dj,gv)end;if a9 and bk=="Replication"then an.repl=an.repl+1;return end;if a9 and bk=="MoveDirection"then local L=c4[1]local h=typeof(L)=="Vector3"and string.format("%.1f,%.1f",L.X,L.Z)or"?"if h==an.lastMoveKey and tick()-an.lastMoveT<1 then return end;an.lastMoveKey,an.lastMoveT=h,tick()end;local au="?"pcall(function()au=an.short(cB)end)an.add("send",string.format("%s %s(%s)%s%s",au,eo,an.fmtArgs(c4),dj and" ["..dj.."]"or"",gv and" from "..gv or""))end;local function gw(_)return _.Name end;an.ownSrc=nil;pcall(function()an.ownSrc=debug.info(an.noteWrite or gw,"s")end)function an.fromUs()if not an.ownSrc then return false end;for eI=2,5 do local a9,f0=pcall(debug.info,eI,"s")if not a9 or f0==nil then break end;if f0==an.ownSrc then return true end end;return false end;an.writes={}an.WATCHED={CFrame=true,Position=true,Velocity=true,AssemblyLinearVelocity=true,AssemblyAngularVelocity=true,WalkSpeed=true,JumpPower=true,Anchored=true,MaxForce=true,VectorVelocity=true}function an.noteWrite(cB,h,gx)if not an.on then return end;local a9,bQ=pcall(function()local H=a4()return H and(cB==H or cB:IsDescendantOf(H))end)if not a9 or not bQ then return end;local aV=an.short(cB).."."..tostring(h)local V=an.writes[aV]if not V then V={n=0}an.writes[aV]=V end;V.n=V.n+1;V.last=gx end;function an.flushWrites()for aV,V in pairs(an.writes)do an.add("write",string.format("an executor script set %s x%d, last value %s",aV,V.n,an.fmt(V.last,0)))end;an.writes={}end;function an.hookWrites()if an.hookedWrites or type(hookmetamethod)~="function"then return end;an.hookedWrites=true;local gy=type(newcclosure)=="function"and newcclosure or function(a5)return a5 end;local gz;local a9=pcall(function()gz=hookmetamethod(game,"__newindex",gy(function(self,h,gx)if an.on and an.WATCHED[h]and C.Running and type(checkcaller)=="function"and checkcaller()and not an.fromUs()then task.defer(an.noteWrite,self,h,gx)end;return gz(self,h,gx)end))end)if not a9 then an.hookedWrites=false end end;an.seenFuncs={}function an.funcInfo(a5)local f0,gq,bk="?",0,""pcall(function()f0=debug.info(a5,"s")or"?"gq=debug.info(a5,"l")or 0;bk=debug.info(a5,"n")or""end)return f0,gq,bk end;function an.constantsOf(a5)local R={}local gA=debug and debug.getconstants or getconstants;if type(gA)~="function"then return R end;local a9,b4=pcall(gA,a5)if not a9 or type(b4)~="table"then return R end;for g,L in pairs(b4)do if type(L)=="string"and#L>=3 and#L<=40 and not string.find(L,"[%c]")and#R<60 then R[#R+1]=L end end;return R end;function an.scanConnections()if type(getconnections)~="function"then return end;local gB={{"Heartbeat",k.Heartbeat},{"Stepped",k.Stepped},{"RenderStepped",k.RenderStepped},{"InputBegan",l.InputBegan},{"InputEnded",l.InputEnded}}for g,fZ in ipairs(gB)do local a9,b4=pcall(getconnections,fZ[2])if a9 and type(b4)=="table"then for g,eH in ipairs(b4)do local a5;pcall(function()a5=eH.Function end)if type(a5)=="function"then local aV=tostring(a5)if not an.seenFuncs[aV]then an.seenFuncs[aV]=true;local f0,gq,bk=an.funcInfo(a5)if f0~=an.ownSrc and not string.find(f0,"JHubGlass",1,true)and not string.find(f0,"Players.",1,true)and not string.find(f0,"ReplicatedStorage",1,true)then local gC=an.constantsOf(a5)an.add("script",string.format("%s listener %s line %d %s | words: %s",fZ[1],string.sub(f0,1,80),gq,bk,string.sub(table.concat(gC,", "),1,400)))end end end end end end end;an.seenGuis={}function an.scanGuis()local fq={}pcall(function()if type(gethui)=="function"then fq[#fq+1]=gethui()end end)pcall(function()fq[#fq+1]=game:GetService("CoreGui")end)for g,cU in ipairs(fq)do local a9,gD=pcall(function()return cU:GetChildren()end)if a9 then for g,a3 in ipairs(gD)do if a3.Name~="JHubGlass"and not an.seenGuis[a3]then an.seenGuis[a3]=true;local gE={}pcall(function()for g,bb in ipairs(a3:GetDescendants())do if(bb:IsA("TextLabel")or bb:IsA("TextButton"))and bb.Text~=""and#gE<80 then gE[#gE+1]=string.sub(bb.Text,1,30)end end end)an.add("script",string.format("interface found: %s (%s) texts: %s",a3.Name,a3.ClassName,string.sub(table.concat(gE," | "),1,700)))end end end end end;function an.scanLoop()while an.on and C.Running do pcall(an.scanConnections)pcall(an.scanGuis)task.wait(12)end end;function an.hook()if an.hooked or type(hookmetamethod)~="function"or type(getnamecallmethod)~="function"then return end;an.hooked=true;ae.hooked=true;local gy=type(newcclosure)=="function"and newcclosure or function(a5)return a5 end;local i;i=hookmetamethod(game,"__namecall",gy(function(self,...)local eo=getnamecallmethod()if an.on and eo=="SetAttribute"and C.Running and type(checkcaller)=="function"and checkcaller()and not an.fromUs()then local c4=table.pack(...)task.defer(an.noteWrite,self,"attribute "..tostring(c4[1]),c4[2])end;if C.Running and(eo=="FireServer"or eo=="InvokeServer")then local gF=type(checkcaller)=="function"and checkcaller()local bQ=am.selfFire or ae.selfFire;if gF and not bQ then if an.on then local gG,gH=pcall(gw,self)if not(gG and gH=="Replication")then task.defer(an.remote,self,eo,table.pack(...),"sent by an executor script",an.callerOf())end end end;if not gF and not bQ then if eo=="FireServer"then local gI,bk=pcall(gw,self)if gI and bk=="Shoot"then local c4=table.pack(...)local gJ,gK=pcall(ae.onShootCall,c4)if gJ and gK then if an.on then task.defer(an.remote,self,eo,c4,"held back",an.callerOf())end;return end elseif gI and bk=="MoveDirection"then local L=...if typeof(L)=="Vector3"then am.gameDir,am.gameDirT=L,tick()if am.override and tick()-(am.overrideT or 0)<0.4 and L.Magnitude<0.3 then return i(self,am.override,select(2,...))end;local gL,P=pcall(am.outScale)if gL and P>1.001 and L.Magnitude>0.05 then if an.on then task.defer(an.remote,self,eo,table.pack(L*P),string.format("boosted x%.2f",P))end;return i(self,L*P,select(2,...))end end elseif gI and bk=="Dribble"then am.lastDribbleRemote=self;task.defer(am.onDribble,table.pack(...))end end;if an.on then task.defer(an.remote,self,eo,table.pack(...),nil,an.callerOf())end end end;return i(self,...)end))end;function an.connectRemotes()local function dn(bb)if bb:IsA("RemoteEvent")then table.insert(an.conns,bb.OnClientEvent:Connect(function(...)if not an.on then return end;if bb.Name=="Replication"then an.replIn=an.replIn+1;return end;local f=an.fmtArgs(table.pack(...))pcall(an.spyNote,bb.Name,"recv",f)an.add("recv",an.short(bb).."("..f..")")end))end end;for g,bb in ipairs(s:GetDescendants())do dn(bb)end;table.insert(an.conns,s.DescendantAdded:Connect(dn))end;function an.pollLabels()local bc=0;for bb in pairs(ae.labels)do if bb.Parent then local cY=bb.Text;if cY~=an.labelText[bb]then an.labelText[bb]=cY;if cY~=""and bc<12 and not string.match(cY,"^[%d%.:,%s%%/]+$")and not string.find(cY," FPS",1,true)and a2(bb)then bc=bc+1;an.add("text",an.short(bb).." = "..string.format("%q",string.sub(cY,1,80)))end end end end end;function an.pollAttrs()local function gM(gN,cB)if not cB then return end;for a1,L in pairs(cB:GetAttributes())do local h=gN..a1;if an.attrCache[h]~=L then an.add("attr",string.format("%s %s -> %s",h,tostring(an.attrCache[h]),tostring(L)))an.attrCache[h]=L end end end;gM("char.",a4())gM("player.",u)local aR=a7()if aR then for g,cE in ipairs({"WalkSpeed","JumpPower","JumpHeight","Health","HipHeight"})do local a9,L=pcall(function()return aR[cE]end)if a9 and type(L)=="number"and an.attrCache["hum."..cE]~=L then an.add("attr",string.format("hum.%s %s -> %s",cE,tostring(an.attrCache["hum."..cE]),tostring(L)))an.attrCache["hum."..cE]=L end end end end;function an.pollMovers()local aw=a6()if not aw then return end;local R={}for g,bN in ipairs(aw:GetChildren())do local a9,f=pcall(function()if bN:IsA("BodyVelocity")then return string.format("%s velocity=%.1f,%.1f,%.1f maxForce=%.0f",bN.Name,bN.Velocity.X,bN.Velocity.Y,bN.Velocity.Z,bN.MaxForce.X)end;if bN:IsA("BodyPosition")then return string.format("%s position=%.1f,%.1f,%.1f maxForce=%.0f",bN.Name,bN.Position.X,bN.Position.Y,bN.Position.Z,bN.MaxForce.X)end;if bN:IsA("BodyGyro")then return string.format("%s maxTorque=%.0f",bN.Name,bN.MaxTorque.X)end;if bN:IsA("LinearVelocity")then return string.format("%s linear=%.1f,%.1f,%.1f",bN.Name,bN.VectorVelocity.X,bN.VectorVelocity.Y,bN.VectorVelocity.Z)end;return nil end)if a9 and f then R[#R+1]=f end end;local h=table.concat(R," | ")if h~=""and(h~=an.lastMovers or tick()-(an.lastMoversT or 0)>2)then an.lastMovers,an.lastMoversT=h,tick()an.add("body",h)end;local H=a4()if H and aw.Anchored~=an.lastAnchored then an.lastAnchored=aw.Anchored;an.add("body","root anchored="..tostring(aw.Anchored))end end;function an.watchCharacter()local H=a4()if not H then return end;table.insert(an.conns,H.DescendantAdded:Connect(function(bb)if an.on then an.add("char","added "..bb.ClassName.." "..an.short(bb))end end))table.insert(an.conns,H.DescendantRemoving:Connect(function(bb)if an.on then an.add("char","removed "..bb.ClassName.." "..an.short(bb))end end))end;function an.sampleBall()local aw,N=a6(),ad.nearest;local h=tostring(ad.holding)..tostring(ad.source)if h==an.lastBallKey and tick()-an.lastBallT<4 then return end;an.lastBallKey,an.lastBallT=h,tick()if N and N.Parent and aw then an.add("ball",string.format("pos=%.1f,%.1f,%.1f dist=%.1f holding=%s via %s parts=%d",N.Position.X,N.Position.Y,N.Position.Z,(N.Position-aw.Position).Magnitude,tostring(ad.holding),tostring(ad.source),ad.count()))else an.add("ball","holding="..tostring(ad.holding).." via "..tostring(ad.source).." parts="..ad.count())end end;function an.pollButtons()local b9=u:FindFirstChild("PlayerGui")if not b9 then return end;local bZ={}for g,bb in ipairs(b9:GetDescendants())do if bb:IsA("GuiButton")and not bb:IsDescendantOf(aS)and a2(bb)then bZ[ac.pathOf(bb)]=true end end;for bI in pairs(bZ)do if not an.btnSet[bI]then an.add("gui","button shown: "..bI)end end;for bI in pairs(an.btnSet)do if not bZ[bI]then an.add("gui","button hidden: "..bI)end end;an.btnSet=bZ end;function an.sampleLoop()local gO,gP,gQ,gR=0,0,0,0;while an.on and C.Running do local H=a4()local aw=a6()or H and H.PrimaryPart;local aR=a7()if aw then local L=aw.AssemblyLinearVelocity;local dO="?"if aR then pcall(function()dO=tostring(aR:GetState())end)end;local h=string.format("%.1f,%.1f,%.1f|%s",aw.Position.X,aw.Position.Y,aw.Position.Z,dO)if h~=an.lastPosKey or tick()-an.lastPosT>1 then an.lastPosKey,an.lastPosT=h,tick()local gS=workspace:FindFirstChild("ProxyCharacter")an.add("move",string.format("pos=%.1f,%.1f,%.1f proxy=%s vel=%.1f ws=%s intent=%.2f(%s) boost=%.1f ball=%s state=%s",aw.Position.X,aw.Position.Y,aw.Position.Z,gS and string.format("%.1f,%.1f",gS.Position.X,gS.Position.Z)or"none",math.sqrt(L.X*L.X+L.Z*L.Z),aR and string.format("%.1f",aR.WalkSpeed)or"none",ai.mag or 0,tostring(ai.src),ai.extra,tostring(ad.holding),dO))end elseif tick()-an.noChar>3 then an.noChar=tick()an.add("move","no character found (LP.Character="..tostring(u.Character)..")")end;if tick()-gQ>=1 then gQ=tick()pcall(an.flushWrites)if an.repl>0 or an.replIn>0 then an.add("net",string.format("Replication sent x%d, received x%d in the last second",an.repl,an.replIn))end;an.repl,an.replIn=0,0 end;if tick()-gR>2.5 then gR=tick()pcall(an.pollButtons)end;pcall(an.pollMovers)pcall(an.pollLabels)if tick()-gO>0.6 then gO=tick()pcall(an.pollAttrs)end;if tick()-gP>0.45 then gP=tick()pcall(an.sampleBall)end;task.wait(0.15)end end;function an.snapshot()local R={}local function fs(P)R[#R+1]=P end;fs("== JHub recording "..B.." | place "..string.format("%.0f",game.PlaceId).." | "..tostring(C.execName)..(A and" | mobile"or" | pc"))local gT=D().ViewportSize;fs("game: "..tostring(C.placeName).." | screen "..string.format("%.0fx%.0f",gT.X,gT.Y).." | "..os.date("%Y-%m-%d %H:%M:%S"))fs(string.format("executor: VIM=%s getconnections=%s firesignal=%s hookmetamethod=%s getgc=%s setclipboard=%s",tostring(t~=nil),tostring(getconnections~=nil),tostring(firesignal~=nil),tostring(type(hookmetamethod)=="function"),tostring(type(getgc)=="function"),tostring(setclipboard~=nil)))fs(string.format("settings: hold=%.3f times=[%s] ratio=%.3f bar=%s|%s point=%.3f shootButton=%s",ar.HoldTime,ar.ShotTimes,ar.ShotRatio,ar.BarPath,ar.BarProp,ar.BarAt,ar.ShootButtonPath))fs(string.format("boosts: walk=%s+%.1f run=%s+%.1f ball=%s+%.1f channel=%s | glides: dribble=%s shot=%s gather=%s",tostring(ar.SpeedOn),ar.SpeedAdd,tostring(ar.RunOn),ar.RunAdd,tostring(ar.BallSpeedOn),ar.BallAdd,ar.SpeedChannel,tostring(ar.DribbleGlide),tostring(ar.ShotGlide),tostring(ar.GatherGlide)))pcall(function()local H=a4()fs("LP.Character = "..tostring(u.Character).." | character found = "..(H and an.short(H)or"none"))local gU=workspace:FindFirstChild("Characters")if gU then local gV={}for g,bN in ipairs(gU:GetChildren())do gV[#gV+1]=bN.Name end;fs("workspace.Characters: "..table.concat(gV," "))end;local eK={}for g,bN in ipairs(workspace:GetChildren())do if#eK<40 then eK[#eK+1]=bN.Name..":"..bN.ClassName end end;fs("workspace: "..table.concat(eK," "))if H then local gh={}for g,bN in ipairs(H:GetChildren())do gh[#gh+1]=bN.Name..":"..bN.ClassName end;fs("character: "..table.concat(gh," "))local gW=a7()fs("humanoid: "..(gW and"yes walkspeed="..tostring(gW.WalkSpeed).." jump="..tostring(gW.JumpPower)or"none"))local aw=H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart;if aw then fs(string.format("root: %s anchored=%s pos=%.1f,%.1f,%.1f",an.short(aw),tostring(aw.Anchored),aw.Position.X,aw.Position.Y,aw.Position.Z))local gD={}for g,bN in ipairs(aw:GetChildren())do gD[#gD+1]=bN.Name..":"..bN.ClassName end;fs("root children: "..table.concat(gD," "))end;for a1,L in pairs(H:GetAttributes())do fs("  char attribute "..a1 .." = "..tostring(L))end end;local gX={}for g,a3 in ipairs((u:FindFirstChild("PlayerGui")or workspace):GetChildren())do if a3:IsA("ScreenGui")then gX[#gX+1]=a3.Name..(a3.Enabled and""or"(off)")end end;fs("screen guis: "..table.concat(gX," "))end)for a1,L in pairs(u:GetAttributes())do fs("  player attribute "..a1 .." = "..tostring(L))end;local b9=u:FindFirstChild("PlayerGui")if b9 then fs("-- visible buttons:")local bc=0;for g,bb in ipairs(b9:GetDescendants())do if bb:IsA("GuiButton")and not bb:IsDescendantOf(aS)and a2(bb)then bc=bc+1;if bc<=80 then fs(string.format("  %s [%s %q] at %.0f,%.0f size %.0fx%.0f",ac.pathOf(bb),bb.ClassName,ac.btnText(bb),bb.AbsolutePosition.X,bb.AbsolutePosition.Y,bb.AbsoluteSize.X,bb.AbsoluteSize.Y))end end end end;fs("-- remotes:")local bc=0;for g,bb in ipairs(s:GetDescendants())do if bb:IsA("RemoteEvent")or bb:IsA("RemoteFunction")then bc=bc+1;if bc<=100 then fs("  "..bb.ClassName.." "..an.short(bb))end end end;fs("-- ball parts: "..ad.count())an.header=R end;function an.spyText()local gY={}for bk,fz in pairs(an.spy)do gY[#gY+1]={name=bk,e=fz,n=fz.sent+fz.recv}end;table.sort(gY,function(M,N)return M.n>N.n end)local R={"-- remote spy: name | sent | from executor scripts | held back | boosted | received | sender | first args | last args --"}for g,aw in ipairs(gY)do local fz=aw.e;R[#R+1]=string.format("%s | sent %d | exec %d | held %d | boosted %d | recv %d | by %s | first (%s) | last (%s)",aw.name,fz.sent,fz.exec,fz.held,fz.boosted,fz.recv,tostring(fz.caller or"?"),string.sub(tostring(fz.first or""),1,200),string.sub(tostring(fz.last or""),1,200))end;if an.repl>0 or an.replTotal then R[#R+1]="Replication (position stream) is only counted per second in the events"end;return table.concat(R,"\n")end;function an.copySpy()local av=an.spyText()local gZ={}for cR=math.max(1,#an.lines-150),#an.lines do gZ[#gZ+1]=an.lines[cR]end;av=av.."\n-- the last events --\n"..table.concat(gZ,"\n")if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Remote spy","Copied the remote list and the last events. Paste it to me.",4)else at.write(at.root.."/remotespy.txt",av)ao("Remote spy","Saved to the JHubGlass folder (this executor cannot copy).",4)end end;function an.text()local aE={}for g,bD in ipairs(an.header)do aE[#aE+1]=bD end;aE[#aE+1]=an.spyText()aE[#aE+1]="-- events (seconds since start) --"for g,bD in ipairs(an.lines)do aE[#aE+1]=bD end;return table.concat(aE,"\n")end;function an.save(av)at.write(at.root.."/recording.txt",av or an.text())end;function an.summary()local g_=an.bytes/1024;return(an.on and"recording: "or"stopped: ")..string.format("%d lines, %.0f KB",#an.lines,g_)end;function an.copy()if#an.lines==0 and#an.header==0 then ao("Recorder","Nothing recorded yet. Turn on Record the game first.",3)return end;local av=an.text()if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Recorder",string.format("Copied %d lines (%.0f KB). Paste it to me.",#an.lines,#av/1024),4)else ao("Recorder","This executor cannot copy, so it was saved to the JHubGlass folder instead.",4)end;an.save(av)end;function an.clear()an.lines,an.bytes,an.header,an.spy={},0,{},{}ao("Recorder","Cleared",2)end;function an.start()if an.on then return end;an.lines,an.bytes={},0;an.spy={}an.t0=tick()an.on=true;an.labelText,an.attrCache={},{}for bb in pairs(ae.labels)do if bb.Parent then an.labelText[bb]=bb.Text end end;pcall(an.snapshot)pcall(an.hook)pcall(an.connectRemotes)pcall(an.watchCharacter)an.seenFuncs,an.seenGuis,an.writes={},{},{}task.spawn(an.scanLoop)task.spawn(an.sampleLoop)ao("Recorder","Recording. Play and take your shots, then tap Copy recording.",4)end;function an.stop()if not an.on then return end;an.add("end","recording stopped")an.on=false;for g,H in ipairs(an.conns)do pcall(function()H:Disconnect()end)end;an.conns={}pcall(an.save)ao("Recorder",string.format("Stopped. %d lines recorded.",#an.lines),3)end;C.RecLog=function(J)an.add("jhub",J)end;ab.AUTOEXEC_FILE="JHubV1_Glass.lua"ab.AUTOEXEC_FOLDERS={"autoexec","Autoexec","autoexecute","Autoexecute"}function ab.scriptSource()if type(a)=="string"and#a>1000 then return a end;return at.read(at.root.."/"..ab.AUTOEXEC_FILE)end;function ab.autoExecCode()local f0=ab.scriptSource()if not f0 then return nil end;return"(getgenv and getgenv() or _G).JHUB_AUTOEXEC = true\n"..f0 end;function ab.queueTeleport()local dZ=queue_on_teleport or syn and syn.queue_on_teleport or fluxus and fluxus.queue_on_teleport;local bf=ab.autoExecCode()if type(dZ)=="function"and bf then pcall(dZ,bf)return true end;return false end;function ab.autoExec(h0)if not h0 then for g,a5 in ipairs(ab.AUTOEXEC_FOLDERS)do local bI=a5 .."/"..ab.AUTOEXEC_FILE;pcall(function()if type(isfile)=="function"and isfile(bI)and type(delfile)=="function"then delfile(bI)end end)end;ao("Auto execute","Off. JHub will not start by itself anymore.",3)return end;local bf=ab.autoExecCode()if not bf then ao("Auto execute","Could not read the script to save it.",4)return end;at.write(at.root.."/"..ab.AUTOEXEC_FILE,ab.scriptSource())local h1={}for g,a5 in ipairs(ab.AUTOEXEC_FOLDERS)do pcall(function()if type(isfolder)=="function"and isfolder(a5)then writefile(a5 .."/"..ab.AUTOEXEC_FILE,bf)table.insert(h1,a5)end end)end;local h2=ab.queueTeleport()local aE={}if#h1>0 then table.insert(aE,"saved in "..table.concat(h1,", "))end;if h2 then table.insert(aE,"runs again when you change servers")end;if#aE==0 then ao("Auto execute","This executor does not let scripts reach its auto-execute folder. A copy is in the JHubGlass folder: put it in your executor's autoexec folder.",8)else ao("Auto execute","On: "..table.concat(aE,", "),5)end end;an.scanText=""an.scanning=false;an.SCAN_WORDS={"move","speed","stat","dribble","glide","sprint","physic","config","setting","build","shoot","meter","input","player","constant","code","reward","badge","stamina","character"}function an.tableDump(S,gr,R,gN,bE,d5)if bE[S]or gr>3 or#R>=d5 then return end;bE[S]=true;local bG={}for a1 in pairs(S)do bG[#bG+1]=a1 end;pcall(table.sort,bG,function(M,N)return tostring(M)<tostring(N)end)for cR,a1 in ipairs(bG)do if cR>60 or#R>=d5 then R[#R+1]=gN.."..."return end;local L=S[a1]local h3=typeof(L)if h3=="table"then R[#R+1]=gN..tostring(a1).." = {"an.tableDump(L,gr+1,R,gN.."  ",bE,d5)R[#R+1]=gN.."}"elseif h3=="function"then R[#R+1]=gN..tostring(a1).." = function"else R[#R+1]=gN..tostring(a1).." = "..an.fmt(L,0)end end end;function an.scanGame()if an.scanning then ao("Game scanner","Still scanning, wait a moment.",2)return end;an.scanning=true;ao("Game scanner","Scanning the game. This takes a few seconds.",3)task.spawn(function()local R={}local function bF(P)R[#R+1]=P end;pcall(function()bF("== game scan "..B.." | "..tostring(C.placeName).." | "..tostring(C.execName).." | "..os.date("%Y-%m-%d %H:%M:%S"))bF("-- character: "..tostring(a4()and al.pathOf(a4())or"none"))local H=a4()if H then for a1,L in pairs(H:GetAttributes())do bF("  char attribute "..a1 .." = "..tostring(L))end end;for a1,L in pairs(u:GetAttributes())do bF("  player attribute "..a1 .." = "..tostring(L))end;bF("-- game settings (workspace.Settings) --")local d2=workspace:FindFirstChild("Settings")if d2 then for a1,L in pairs(d2:GetAttributes())do bF("  "..a1 .." = "..tostring(L))end;for g,bb in ipairs(d2:GetDescendants())do local a9,aB=pcall(function()return bb.Value end)bF("  "..al.pathOf(bb)..(a9 and" = "..tostring(aB)or""))end end;bF("-- ReplicatedStorage --")local bc=0;for g,bb in ipairs(s:GetDescendants())do bc=bc+1;if bc>700 then bF("  ...")break end;bF("  "..bb.ClassName.." "..al.pathOf(bb))if bc%120==0 then task.wait()end end end)task.wait()pcall(function()local b4;if type(getloadedmodules)=="function"then b4=getloadedmodules()end;if not b4 then bF("-- client modules: this executor cannot list them --")return end;bF("-- client modules ("..#b4 ..") --")local h4={}for cR,bJ in ipairs(b4)do if cR<=500 then bF("  "..al.pathOf(bJ))end;local gi=string.lower(bJ.Name)if#h4<30 and T(gi,an.SCAN_WORDS)then h4[#h4+1]=bJ end end;for g,bJ in ipairs(h4)do task.wait()local a9,aZ=pcall(require,bJ)local cW={}if a9 and type(aZ)=="table"then an.tableDump(aZ,0,cW,"    ",{},200)elseif a9 then cW[1]="    ("..typeof(aZ)..")"else cW[1]="    (could not be read)"end;bF("-- module "..al.pathOf(bJ).." --")for g,bD in ipairs(cW)do bF(bD)end end end)task.wait()pcall(function()if type(getgc)~="function"then return end;bF("-- tables in memory with movement / dribble / code names --")local bp,bE=0,0;for g,S in ipairs(getgc(true))do bE=bE+1;if bE%4000==0 then task.wait()end;if bp<60 and type(S)=="table"then local a9=pcall(function()for a1,L in pairs(S)do if type(a1)=="string"and(type(L)=="number"or type(L)=="string"or type(L)=="boolean")then local h5=string.lower(a1)if(string.find(h5,"speed",1,true)or string.find(h5,"glide",1,true)or string.find(h5,"dribble",1,true)or string.find(h5,"sprint",1,true)or h5=="code"or h5=="codes")and bp<60 then bp=bp+1;bF("  "..a1 .." = "..tostring(L))end end end end)end end end)local av=table.concat(R,"\n")if#av>240000 then av=string.sub(av,1,240000).."\n... (cut)"end;an.scanText=av;an.copyScan()an.scanning=false end)end;function an.copyScan()if an.scanText==""then ao("Game scanner","Nothing scanned yet.",2)return end;if type(setclipboard)=="function"then pcall(setclipboard,an.scanText)ao("Game scanner",string.format("Copied (%.0f KB). Paste it to me.",#an.scanText/1024),4)else ao("Game scanner","This executor cannot copy, so it was saved to the JHubGlass folder.",4)end;at.write(at.root.."/gamescan.txt",an.scanText)end;an.shotOn=false;an.shotLines={}an.shotBytes=0;an.shotConns={}an.shotCap=400000;function an.shotAdd(av)if not an.shotOn then return end;local gq=string.format("%.3f %s",tick()-(an.shotT0 or tick()),av)an.shotLines[#an.shotLines+1]=gq;an.shotBytes=an.shotBytes+#gq+1;while an.shotBytes>an.shotCap and#an.shotLines>1 do an.shotBytes=an.shotBytes-#table.remove(an.shotLines,1)-1 end end;function an.modulesNamed(h6)local R={}if type(getloadedmodules)~="function"then return R end;local a9,b4=pcall(getloadedmodules)if not a9 or type(b4)~="table"then return R end;for g,bJ in ipairs(b4)do local h7,au=pcall(al.pathOf,bJ)if h7 and string.sub(au,-#h6)==h6 then R[#R+1]=bJ end end;return R end;function an.dumpModule(h6,h8)local R={}for g,bJ in ipairs(an.modulesNamed(h6))do local a9,aZ=pcall(require,bJ)R[#R+1]="-- module "..al.pathOf(bJ)if a9 and type(aZ)=="table"then an.tableDump(aZ,0,R,"  ",{},h8 or 260)else R[#R+1]="  ("..typeof(aZ)..")"end end;return R end;function an.constantsAll(a5)local R={}local gA=debug and debug.getconstants or getconstants;if type(gA)~="function"then return R end;local a9,b4=pcall(gA,a5)if not a9 or type(b4)~="table"then return R end;for g,L in pairs(b4)do if type(L)=="string"and#L>=2 and#L<=40 and not string.find(L,"[%c]")or type(L)=="number"then if#R<120 then R[#R+1]=type(L)=="number"and string.format("%.5g",L)or L end end end;return R end;function an.codeOf(bJ)local cW={"-- script "..al.pathOf(bJ)}local f0;if type(decompile)=="function"then local a9,aw=pcall(decompile,bJ)if a9 and type(aw)=="string"and#aw>40 then f0=aw end end;if f0 then if#f0>70000 then f0=string.sub(f0,1,70000).."\n-- (cut)"end;cW[#cW+1]=f0;return table.concat(cW,"\n")end;cW[#cW+1]="-- (this executor cannot decompile: the numbers and words inside each function follow)"local a9,aZ=pcall(require,bJ)if a9 and type(aZ)=="table"then local gh={}for a1,L in pairs(aZ)do if type(L)=="function"then gh[#gh+1]=a1 end end;table.sort(gh,function(M,N)return tostring(M)<tostring(N)end)for g,a1 in ipairs(gh)do cW[#cW+1]="function "..tostring(a1)..": "..table.concat(an.constantsAll(aZ[a1]),", ")end;an.tableDump(aZ,0,cW,"  ",{},160)end;return table.concat(cW,"\n")end;an.CODE_SETS={shooting={"Controllers/Meter","Modules/Config/Meters/Bat","Modules/UI/Character/ShotFeedback","Config/Game/Shooting","Config/Settings/Meter","Modules/Config/Meter"},movement={"Components/Character/Movement","Movement/Types/Base","Controllers/Player","Modules/Components/Input/Mobile"}}function an.copyCode(h9)ao("Code reader","Reading the game's code. This takes a few seconds.",3)task.spawn(function()local R={"== game code "..tostring(h9).." | "..B.." | decompile="..tostring(type(decompile)=="function")}for g,h6 in ipairs(an.CODE_SETS[h9]or{})do for g,bJ in ipairs(an.modulesNamed(h6))do task.wait()local a9,av=pcall(an.codeOf,bJ)R[#R+1]=a9 and av or"-- "..h6 .." could not be read"end end;local av=table.concat(R,"\n")if#av>240000 then av=string.sub(av,1,240000).."\n-- (cut)"end;an.codeText=av;if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Code reader",string.format("Copied (%.0f KB). Paste it to me.",#av/1024),4)else ao("Code reader","This executor cannot copy, so it was saved to the JHubGlass folder.",4)end;at.write(at.root.."/code_"..tostring(h9)..".txt",av)end)end;an.shotSummary={}function an.shotCategory(da,ha)local H=a4()local cH=tostring(H and H:GetAttribute("BaseAnimation")or"")local gj=string.lower(cH.." "..tostring(ha or""))if string.find(gj,"dunk",1,true)then return"dunk"end;if string.find(gj,"layup",1,true)then return"layup"end;if string.find(gj,"floater",1,true)then return"floater"end;if string.find(gj,"stepback",1,true)or string.find(gj,"step back",1,true)then return"step back"end;if string.find(gj,"fade",1,true)then return"fadeaway"end;if string.find(gj,"post",1,true)or string.find(gj,"hook",1,true)then return"post shot"end;if string.find(gj,"movingshot",1,true)then return"moving shot"end;if string.find(gj,"close",1,true)then return"close shot"end;if da and da.speed and da.speed>1.5 then return"moving jumpshot"end;return"standing jumpshot"end;function an.shotNote(db,aZ,av)if not an.shotOn then return end;local H=a4()local da=an.shotCtx or{}local hb=string.match(tostring(ae.fbText or""),"Shot Type %- (%S+)")local function hc(bc)return H and tostring(H:GetAttribute(bc))or"?"end;local bc=#an.shotSummary+1;an.shotSummary[bc]=string.format("SHOT %d | %s | game type=%s | anim=%s | ShotSpeed=%s | speed at start=%.1f | hand=%s | gather=%s | last dribble=%s | in air=%s | held=%.4f | verdict=%s idx=%s | message=%s | contest=%s | key=%s | start hold=%s | frozen meter=%s | sweep=%s",bc,an.shotCategory(da,hb),tostring(hb),hc("BaseAnimation"),hc("ShotSpeed"),da.speed or 0,hc("Hand"),hc("GatherType"),hc("LastDribblePackage"),tostring(da.air),db.held or 0,tostring(aZ),tostring(db.idx),tostring(av),tostring(string.match(tostring(ae.fbText or""),"Contest %- (%S+)")),tostring(db.key),tostring(db.base and string.format("%.3f",db.base)),hc("meterOffset"),tostring(ae.lastSweep))end;function an.shotMeterStart(hd)if not an.shotOn then return end;local H=a4()local L=H and H:GetAttribute("ServerVelocity")an.shotCtx={speed=typeof(L)=="Vector3"and L.Magnitude or 0,air=H and H:GetAttribute("InAir")}an.shotAdd(string.format("== shot meter starts | packet=%s | ShotSpeed=%s",tostring(hd),tostring(H and H:GetAttribute("ShotSpeed"))))end;local he={Stamina=true,TakeoverFill=true,AccelerationBoost=true}function an.shotStart()if an.shotOn then return end;an.shotOn=true;if ar.Sweep then ao("Shot recorder","Sweep is ON: shots are released early and late on purpose. Turn it off for real results.",7)end;an.shotLines,an.shotBytes,an.shotT0,an.shotSummary,an.shotCtx={},0,tick(),{},nil;an.shotAdd("== shot recorder "..B.." | "..tostring(C.placeName).." | "..tostring(C.execName))local H=a4()if H then for a1,L in pairs(H:GetAttributes())do an.shotAdd("start attr "..a1 .." = "..tostring(L))end;table.insert(an.shotConns,H.AttributeChanged:Connect(function(bk)if he[bk]then return end;local aB=H:GetAttribute(bk)an.shotAdd("attr "..bk.." = "..tostring(aB))if bk=="Action"and string.find(string.lower(tostring(aB)),"dunk",1,true)then an.shotAdd("== DUNK started | "..tostring(aB))an.shotSummary[#an.shotSummary+1]="DUNK | Action="..tostring(aB).." | anim="..tostring(H:GetAttribute("BaseAnimation")).." | in air="..tostring(H:GetAttribute("InAir"))end end))end;ao("Shot recorder","Recording. Take standing, moving, fadeaway, step back, layup and dunk shots, then turn it off. It copies everything.",6)end;function an.shotStop()if not an.shotOn then return end;an.shotAdd("== stopped")an.shotOn=false;for g,hf in ipairs(an.shotConns)do pcall(function()hf:Disconnect()end)end;an.shotConns={}an.shotFinish()end;function an.shotFinish()if#an.shotLines<=2 then ao("Shot recorder","Nothing recorded. Take some shots first.",3)return end;ao("Shot recorder","Building the report.",2)task.spawn(function()local R={"== SHOT REPORT "..B.." | "..tostring(C.placeName).." | "..tostring(C.execName),"== one line per shot ("..#an.shotSummary..")"}for g,bD in ipairs(an.shotSummary)do R[#R+1]=bD end;R[#R+1]="== saved hold times: "..tostring(ar.ShotTimes)R[#R+1]="== dunk settings"pcall(function()for g,bJ in ipairs(getloadedmodules())do local h7,au=pcall(al.pathOf,bJ)if h7 and string.find(au,"Config/Game/Dunking",1,true)then task.wait()local hg,aZ=pcall(require,bJ)R[#R+1]="-- "..au;if hg and type(aZ)=="table"then an.tableDump(aZ,0,R,"  ",{},#R+90)end end end end)R[#R+1]="== raw log"R[#R+1]=table.concat(an.shotLines,"\n")local av=table.concat(R,"\n")if#av>380000 then av=string.sub(av,1,380000).."\n-- (cut)"end;if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Shot recorder",string.format("Copied %d shots (%.0f KB). Paste it to me.",#an.shotSummary,#av/1024),5)else ao("Shot recorder","This executor cannot copy, so it was saved to the JHubGlass folder.",5)end;at.write(at.root.."/shotdata.txt",av)end)end;function an.shotCopy()an.shotFinish()end;function an.copyShotConfig()ao("Shot settings","Reading the shot settings. This takes a few seconds.",3)task.spawn(function()local R={"== shot settings "..B}local b4={}pcall(function()b4=getloadedmodules()end)for g,bJ in ipairs(b4)do local a9,au=pcall(al.pathOf,bJ)if a9 and string.find(au,"Config/Game/Shooting/Packages",1,true)then task.wait()local hg,aZ=pcall(require,bJ)R[#R+1]="-- "..au;if hg and type(aZ)=="table"then an.tableDump(aZ,0,R,"  ",{},#R+70)end end end;local av=table.concat(R,"\n")if#av>240000 then av=string.sub(av,1,240000).."\n-- (cut)"end;if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Shot settings",string.format("Copied (%.0f KB). Paste it to me.",#av/1024),4)else ao("Shot settings","This executor cannot copy, so it was saved to the JHubGlass folder.",4)end;at.write(at.root.."/shotsettings.txt",av)end)end;an.CAPTURE_WORDS={"shoot","shot","meter","build","badge","contest","rating","release","timing","takeover","stamina","attribute","stat","skill","archetype","hotzone","hot","cold","makerng","percent","defen","block","guard","gameplay","layup","dunk","pass","dribble","input","mobile","player","physics","util","contact","basketball","coin","movement","gamemode"}function an.captureAll()ao("Capture","Reading the game. This takes up to a minute.",5)task.spawn(function()local R={"== GAME CAPTURE "..B.." | "..tostring(C.placeName).." | "..tostring(C.execName).." | decompile="..tostring(type(decompile)=="function")}local hh={}pcall(function()for g,bJ in ipairs(getloadedmodules())do local a9,au=pcall(al.pathOf,bJ)if a9 then hh[#hh+1]={m=bJ,path=au}end end end)local hi={"Controllers/Player","InputService","Components/Input","Controllers/Meter","Shoot","ShotFeedback","Shared/Util/","Config/Game/Basketball","Config/Game/Contact","Controllers/Characters/Character","Config/Meter","Config/Settings","Controllers/Attributes","Controllers/Gui"}local function hj(au)for g,V in ipairs(hi)do if string.find(au,V,1,true)then return 1 end end;return 2 end;table.sort(hh,function(M,N)local hk,hl=hj(M.path),hj(N.path)if hk~=hl then return hk<hl end;return M.path<N.path end)local function hm(au)local gj=string.lower(au)for g,V in ipairs(an.CAPTURE_WORDS)do if string.find(gj,V,1,true)then return true end end;return false end;R[#R+1]="== all modules ("..#hh..")"for g,fz in ipairs(hh)do R[#R+1]=fz.path end;R[#R+1]="== player values"pcall(function()for a1,L in pairs(u:GetAttributes())do R[#R+1]="player attr "..a1 .." = "..tostring(L)end;local H=a4()if H then for a1,L in pairs(H:GetAttributes())do R[#R+1]="character attr "..a1 .." = "..tostring(L)end end;local go=u:FindFirstChild("leaderstats")if go then for g,L in ipairs(go:GetChildren())do R[#R+1]="leaderstat "..L.Name.." = "..tostring(L.Value)end end;for a1,L in pairs(workspace:GetAttributes())do R[#R+1]="workspace attr "..a1 .." = "..tostring(L)end;for a1,L in pairs(s:GetAttributes())do R[#R+1]="replicated attr "..a1 .." = "..tostring(L)end end)R[#R+1]="== remotes"pcall(function()for g,bb in ipairs(s:GetDescendants())do if bb:IsA("RemoteEvent")or bb:IsA("RemoteFunction")or bb:IsA("UnreliableRemoteEvent")then R[#R+1]=bb.ClassName.." "..bb:GetFullName()end end end)local hn,d5=0,250000;R[#R+1]="== code and settings"for g,fz in ipairs(hh)do if hn>d5 then R[#R+1]="-- (size limit reached, more modules were skipped from here: "..fz.path..")"break end;local ho=string.find(fz.path,"Config/Game/Dunking",1,true)or string.find(fz.path,"Shooting/Packages",1,true)or string.find(fz.path,"Dunking/Animations",1,true)or string.find(fz.path,"Dunking/Landings",1,true)if not ho then for g,V in ipairs({"Icon/","ForgeVFX","CameraModule","AnimationViewer","Vehicles","TabMenu/","SeasonPass","Config/Game/Emotes","Dribbling/Packages","Crowd","Hoops/Net","Replication/Performance","Statsheet","BuildOffer","PlayerModule/","NameFinder","Statistics/","Scoreboards","GymCustomize"})do if string.find(fz.path,V,1,true)and not string.find(fz.path,"Coins",1,true)then ho=true end end end;if hm(fz.path)and not ho then task.wait()local a9,av=pcall(an.codeOf,fz.m)if a9 and type(av)=="string"then if#av>30000 then av=string.sub(av,1,30000).."\n-- (cut)"end;R[#R+1]=av;hn=hn+#av end end end;local av=table.concat(R,"\n")if#av>390000 then av=string.sub(av,1,390000).."\n-- (cut)"end;if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Capture",string.format("Copied (%.0f KB). Paste it to me.",#av/1024),6)else ao("Capture","This executor cannot copy, so it was saved to the JHubGlass folder.",6)end;at.write(at.root.."/capture.txt",av)end)end;aj.maxSeen={}aj.sprinting=false;function aj.refillIn(cB)for g,bb in ipairs(cB:GetDescendants())do if bb:IsA("NumberValue")or bb:IsA("IntValue")then local bc=string.lower(bb.Name)if string.find(bc,"stamina",1,true)or string.find(bc,"energy",1,true)then aj.maxSeen[bb]=math.max(aj.maxSeen[bb]or 0,bb.Value)bb.Value=aj.maxSeen[bb]end end end;for a1,L in pairs(cB:GetAttributes())do if type(L)=="number"then local bc=string.lower(a1)if string.find(bc,"stamina",1,true)or string.find(bc,"energy",1,true)then local h=cB:GetFullName().."."..a1;aj.maxSeen[h]=math.max(aj.maxSeen[h]or 0,L)pcall(function()cB:SetAttribute(a1,aj.maxSeen[h])end)end end end end;function aj.refillStamina()local H=a4()if H then aj.refillIn(H)end;pcall(aj.refillIn,u)end;function aj.tick(eT)local aR=a7()if not aR or aR.Health<=0 then return end;if ar.InfStamina and eT%5==0 then pcall(aj.refillStamina)end;local f6=ar.AutoSprint and aR.MoveDirection.Magnitude>0.1;if f6~=aj.sprinting then aj.sprinting=f6;ac.action("Sprint",f6)end end;ak.mode=nil;function ak.start(b3)aa.show(false)ao("Picker","Tap "..(b3=="shoot"and"the game's SHOOT button"or"the BALL").." now",4)task.delay(0.35,function()ak.mode=b3 end)end;function ak.handle(b3,bx)if b3=="shoot"then local b9=u:FindFirstChild("PlayerGui")local bA=a8()local bp;for g,bC in ipairs({bx.Y,bx.Y+bA})do local a9,b4=pcall(function()return b9:GetGuiObjectsAtPosition(bx.X,bC)end)if a9 and b4 then for g,a3 in ipairs(b4)do if not a3:IsDescendantOf(aS)and a3:IsA("GuiButton")then bp=a3;break end end;if not bp then for g,a3 in ipairs(b4)do if not a3:IsDescendantOf(aS)then bp=a3;break end end end end;if bp then break end end;if bp then aa.set("ShootButtonPath",ac.pathOf(bp),false)ac.cache.Shoot=nil;ao("Shoot button set",bp.Name,3)I("Shoot button: "..ar.ShootButtonPath)else ao("Picker","Nothing found there, try again",3)end else local hp=D():ScreenPointToRay(bx.X,bx.Y)local hq=RaycastParams.new()hq.FilterType=Enum.RaycastFilterType.Exclude;hq.FilterDescendantsInstances={a4()or workspace.Terrain}local aZ=workspace:Raycast(hp.Origin,hp.Direction*600,hq)if aZ and aZ.Instance then aa.set("BallName",aZ.Instance.Name,false)ad.rescan()ad.parts[aZ.Instance]=true;ao("Ball set",aZ.Instance.Name,3)else ao("Picker","Nothing hit, try again",3)end end;aa.show(true)end;aa.themed,aa.texts,aa.corners,aa.cards,aa.elems,aa.grads={},{},{},{},{},{}aa.pages,aa.refresh,aa.flagRefresh,aa.flagCB={},{},{},{}aa.listening=nil;function aa.th(_,cE,h)table.insert(aa.themed,{_,cE,h})_[cE]=aP[h]return _ end;function aa.elemTrans()return K(ar.CardTrans-0.35,0.12,0.9)end;function aa.font(hr)local a5=aN[ar.Font]or aN.Gotham;local bk=hr and a5[2]or a5[1]local a9,fz=pcall(function()return Enum.Font[bk]end)if a9 and fz then return fz end;return hr and Enum.Font.GothamBold or Enum.Font.Gotham end;function aa.text(_,hr)table.insert(aa.texts,{_,hr})_.Font=aa.font(hr)_.TextStrokeColor3=aP.Stroke;_.TextStrokeTransparency=ar.TextStroke and 0.72 or 1;return _ end;function aa.label(Z,hr,hs)local bD=X("TextLabel",Z)bD.BackgroundTransparency=1;aa.text(bD,hr)if hs~=false then aa.th(bD,"TextColor3",hs or"Text")end;return bD end;function aa.corner(_,eF)local H=X("UICorner",{Parent=_})if eF=="pill"then H.CornerRadius=UDim.new(1,0)else table.insert(aa.corners,{H,eF or 1})H.CornerRadius=UDim.new(0,math.floor(ar.Corner*(eF or 1)))end;return H end;function aa.card(a5)table.insert(aa.cards,a5)a5.BackgroundColor3=aP.Card;a5.BackgroundTransparency=ar.CardTrans;return a5 end;function aa.elem(a5)table.insert(aa.elems,a5)a5.BackgroundColor3=aP.Elem;a5.BackgroundTransparency=aa.elemTrans()return a5 end;function aa.paintGrad(a3)a3.Color=ColorSequence.new(aP.AccentA,aP.AccentB)a3.Rotation=35 end;function aa.grad(_)local a3=X("UIGradient",{Parent=_})table.insert(aa.grads,a3)aa.paintGrad(a3)return a3 end;function aa.stroke(_,ht)local d2=X("UIStroke",{Thickness=1,Color=v,Transparency=ht or 0.6,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=_})return d2 end;function aa.addRefresh(cr,G)if cr then aa.flagRefresh[cr]=aa.flagRefresh[cr]or{}table.insert(aa.flagRefresh[cr],G)end;table.insert(aa.refresh,G)end;function aa.set(cr,L,hu)ar[cr]=L;local b4=aa.flagRefresh[cr]if b4 then for g,a5 in ipairs(b4)do pcall(a5)end end;if hu~=false and aa.flagCB[cr]then task.spawn(aa.flagCB[cr],L)end;aI()end;function aa.refreshAll()aa.applyTheme()for g,a5 in ipairs(aa.refresh)do pcall(a5)end end;local hv=X("Frame",{Name="Window",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(560,340),BackgroundTransparency=1,Parent=aS})local hw=X("UIScale",{Parent=hv})local hx=X("Frame",{Name="Main",Size=UDim2.fromScale(1,1),ClipsDescendants=true,Parent=hv})aa.corner(hx,1.4)local hy=X("UIStroke",{Thickness=2,Color=v,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=hx})local hz=X("UIGradient",{Parent=hy})local hA=X("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=v,BorderSizePixel=0,Parent=hx})local hB=X("UIGradient",{Rotation=120,Parent=hA})do local hC=math.atan2 or function(bC,dG)return math.atan(bC,dG)end;local hD,hE=Color3.fromRGB(255,221,64),Color3.fromRGB(255,196,40)local hF=X("Frame",{Name="Storm",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true,Parent=hx})local hG=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(2.2,2.2),BackgroundColor3=v,BorderSizePixel=0,Parent=hF})local hH=X("UIGradient",{Rotation=35,Parent=hG})local hI={}for cR=1,3 do local _=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(150+cR*30,150+cR*30),BackgroundColor3=cR%2==0 and v or hD,BackgroundTransparency=0.9,BorderSizePixel=0,Parent=hF})aa.corner(_,"pill")hI[cR]=_ end;local b8={}for cR=1,10 do local _={glow={},core={},t=0,life=1,on=false}for hJ=1,9 do _.glow[hJ]=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,BackgroundTransparency=1,BackgroundColor3=hD,ZIndex=2,Parent=hF})_.core[hJ]=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,BackgroundTransparency=1,BackgroundColor3=v,ZIndex=3,Parent=hF})end;b8[cR]=_ end;local function hK(_)for hJ=1,#_.core do _.core[hJ].BackgroundTransparency=1;_.glow[hJ].BackgroundTransparency=1 end;_.on=false end;local function hL(_)local hM,hN=560,340;local dG=math.random()*hM;local bc=#_.core;local hO=hN*(0.55+math.random()*0.5)local hP=(math.random()-0.5)*hM*0.45;local dA={{dG,-6}}for hJ=1,bc do local a5=hJ/bc;dA[#dA+1]={dG+hP*a5+(math.random()-0.5)*48,hO*a5}end;local b3=ar.BoltColor or"White + Yellow"local hQ,hR;if b3=="Yellow"then hQ,hR=Color3.fromRGB(255,240,150),hD elseif b3=="White"then hQ,hR=v,Color3.fromRGB(215,228,255)elseif math.random()<0.5 then hQ,hR=v,hD else hQ,hR=hD,v end;local g5=ar.BoltThick or 2;for hJ=1,bc do local M,N=dA[hJ],dA[hJ+1]local hS,fT=N[1]-M[1],N[2]-M[2]local ck=math.sqrt(hS*hS+fT*fT)+2;local hT=math.deg(hC(fT,hS))local bx=UDim2.fromOffset((M[1]+N[1])/2,(M[2]+N[2])/2)local a3,H=_.glow[hJ],_.core[hJ]a3.Size,H.Size=UDim2.fromOffset(ck,g5*4),UDim2.fromOffset(ck,g5)a3.Position,H.Position=bx,bx;a3.Rotation,H.Rotation=hT,hT;a3.BackgroundColor3,H.BackgroundColor3=hR,hQ end;_.t,_.life,_.on=0,0.3/math.max(ar.BoltSpeed or 1,0.2)+math.random()*0.18,true end;local function eG(_,ec)_.t=_.t+ec;local a1=_.t/_.life;if a1>=1 then hK(_)return end;local hU=math.floor(_.t*38)%2==0 and 1 or 0.55;local M=(1-a1)*hU*(ar.BoltBright or 0.9)local hV,hW=1-M,1-M*0.45;for hJ=1,#_.core do _.core[hJ].BackgroundTransparency=hV;_.glow[hJ].BackgroundTransparency=hW end end;function aa.makeBolt(a0,bx,fA,hX)local cU=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=bx,Size=fA,BackgroundTransparency=1,ZIndex=hX or 4,Parent=a0})X("UIAspectRatioConstraint",{AspectRatio=1,Parent=cU})local dA={{0.70,0.02},{0.30,0.54},{0.62,0.48},{0.28,0.99}}local hY={}for hZ=1,2 do for cR=1,3 do local M,N=dA[cR],dA[cR+1]local hS,fT=N[1]-M[1],N[2]-M[2]local a5=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale((M[1]+N[1])/2,(M[2]+N[2])/2),Size=UDim2.fromScale(math.sqrt(hS*hS+fT*fT)+0.04,hZ==1 and 0.34 or 0.17),Rotation=math.deg(hC(fT,hS)),BackgroundColor3=hZ==1 and hE or hD,BackgroundTransparency=hZ==1 and 0.55 or 0,BorderSizePixel=0,ZIndex=(hX or 4)+hZ,Parent=cU})aa.corner(a5,"pill")if hZ==1 then hY[#hY+1]=a5 end end end;aa.bolts=aa.bolts or{}aa.bolts[#aa.bolts+1]=hY;return cU end;local h_={["Lightning Gold"]={Hue=226,Sat=0.8,Val=0.14,AccentMode="Gold",OutlineColor="Gold",BoltColor="White + Yellow"},["Ice Blue"]={Hue=205,Sat=0.55,Val=0.5,AccentMode="Match hue",OutlineColor="Cyan",BoltColor="White"},["Neon Pink"]={Hue=320,Sat=0.8,Val=0.2,AccentMode="Match hue",OutlineColor="Pink",BoltColor="White"},["Emerald"]={Hue=150,Sat=0.8,Val=0.18,AccentMode="Match hue",OutlineColor="Lime",BoltColor="Yellow"},["Midnight"]={Hue=250,Sat=0.5,Val=0.07,AccentMode="Gold",OutlineColor="White",BoltColor="White"}}aa.PRESET_NAMES={"Lightning Gold","Ice Blue","Neon Pink","Emerald","Midnight"}function aa.applyPreset(bk)local bI=h_[bk]if not bI then return end;for a1,L in pairs(bI)do ar[a1]=L end;aa.refreshAll()aI()end;local i0;function aa.paintStorm()local aR=ar.Hue%360/360;local i1=Color3.fromHSV(aR,math.min(ar.Sat,0.9),0.12)local i2=ar.AccentMode=="Match hue"and Color3.fromHSV(aR,0.75,0.42)or Color3.fromRGB(78,60,8)hH.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,i1),ColorSequenceKeypoint.new(0.5,i2),ColorSequenceKeypoint.new(1,i1)})local d7=1-K(ar.BgGlow or 0.5,0,1)*0.85;hH.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,d7),NumberSequenceKeypoint.new(1,d7)})i0=ar.BgGlow end;function aa.applyFx()hF.Visible=true;if ar.Lightning==false then for g,_ in ipairs(b8)do hK(_)end end;if aa.logoParts then local i3=ar.LogoStyle~="JHub V1"aa.logoParts.j.Visible,aa.logoParts.h.Visible,aa.logoParts.bolt.Visible=i3,i3,i3;aa.logoParts.word.Visible=not i3 end;aa.paintStorm()end;aa.paintStorm()aa.stormPool=b8;local i4,i5=0,0;E(k.Heartbeat,function(ec)i4=i4+ec;local eZ=ar.OutlineSpeed or 1;if aa.FloatBodyGrad then aa.FloatBodyGrad.Rotation=i4*55*math.max(eZ,0.2)%360 end;if not hv.Visible then return end;if ar.BgMove~=false then hH.Offset=Vector2.new(math.sin(i4*0.3)*0.35,math.cos(i4*0.23)*0.35)hH.Rotation=35+math.sin(i4*0.2)*30 end;for cR,_ in ipairs(hI)do _.Visible=ar.BgOrbs~=false and ar.BgMove~=false;_.Position=UDim2.fromScale(0.5+0.45*math.sin(i4*0.35*cR+cR),0.5+0.4*math.cos(i4*0.27*cR+cR*2))_.BackgroundTransparency=0.88+0.05*math.sin(i4*1.3+cR)end;if ar.BgGlow~=i0 then aa.paintStorm()end;if ar.Lightning~=false then i5=i5-ec;if i5<=0 then local i6=math.floor(ar.BoltCount or 6)i5=(0.1+math.random()*0.55)*8/math.max(i6,1)/math.max(ar.BoltSpeed or 1,0.2)for cR=1,math.min(i6,#b8)do if not b8[cR].on then hL(b8[cR])break end end end;for g,_ in ipairs(b8)do if _.on then eG(_,ec)end end else for g,_ in ipairs(b8)do if _.on then hK(_)end end end;if aa.LogoOutlineGrad then aa.LogoOutlineGrad.Rotation=i4*140*eZ%360 end;if aa.LogoBGGrad and ar.LogoBg~=false then aa.LogoBGGrad.Offset=Vector2.new(math.sin(i4*0.9)*0.6,0)end;if aa.bolts then local i7=0.5+0.2*math.sin(i4*5)for g,b4 in ipairs(aa.bolts)do for g,a5 in ipairs(b4)do a5.BackgroundTransparency=i7 end end end end)end;local i8=X("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1,Active=true,Parent=hx})local i9;do local i1,i2=Color3.fromRGB(12,14,32),Color3.fromRGB(95,74,10)local ia=X("Frame",{Name="LogoBadge",Position=UDim2.fromOffset(12,5),Size=UDim2.fromOffset(108,26),BackgroundColor3=i1,ClipsDescendants=true,Parent=i8})aa.corner(ia,0.8)local ib=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(3,3),BackgroundColor3=v,BorderSizePixel=0,Parent=ia})local ic=X("UIGradient",{Rotation=20,Parent=ib})ic.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,i1),ColorSequenceKeypoint.new(0.5,i2),ColorSequenceKeypoint.new(1,i1)})local id=X("UIStroke",{Thickness=2,Color=v,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=ia})local ie=X("UIGradient",{Parent=id})ie.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,221,64)),ColorSequenceKeypoint.new(0.5,v),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,221,64))})local hJ=aa.label({Text="J",TextSize=22,Position=UDim2.fromOffset(8,0),Size=UDim2.fromOffset(26,26),TextColor3=v,ZIndex=3,Parent=ia},true,false)local aR=aa.label({Text="H",TextSize=22,Position=UDim2.fromOffset(74,0),Size=UDim2.fromOffset(26,26),TextColor3=v,ZIndex=3,Parent=ia},true,false)local ig=aa.label({Text="JHub V1",TextSize=18,Size=UDim2.fromScale(1,1),TextColor3=v,ZIndex=3,Visible=false,Parent=ia},true,false)local ih=aa.makeBolt(ia,UDim2.fromOffset(54,13),UDim2.fromOffset(22,22),3)i9=aa.grad(hJ)aa.grad(aR)aa.grad(ig)aa.LogoBGGrad,aa.LogoOutlineGrad=ic,ie;aa.logoParts={j=hJ,h=aR,bolt=ih,word=ig}end;aa.label({Text="Glass  "..B.."  -  Practical Basketball",TextSize=11,Position=UDim2.fromOffset(17,30),Size=UDim2.new(0,260,0,13),TextXAlignment=Enum.TextXAlignment.Left,Parent=i8},false,"Sub")local function ii(av,ij)local N=X("TextButton",{Text="",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,ij,0.5,0),Size=UDim2.fromOffset(32,28),AutoButtonColor=false,Parent=i8})aa.elem(N)aa.corner(N,0.7)aa.stroke(N,0.55)aa.label({Text=av,TextSize=14,Size=UDim2.fromScale(1,1),Parent=N},true,"Text")return N end;local ik=X("TextButton",{Text="",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-92,0.5,0),Size=UDim2.fromOffset(32,28),AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(88,101,242),Parent=i8})aa.corner(ik,0.7)aa.label({Text="D",TextSize=14,Font=Enum.Font.GothamBlack,TextColor3=v,Size=UDim2.fromScale(1,1),Parent=ik},true,false)ik.Activated:Connect(function()local il="https://discord.gg/fk5TsZMrRM"local a9=type(setclipboard)=="function"and pcall(setclipboard,il)ao("JHub",a9 and"Discord invite copied - paste it in your browser to join."or"Join my Discord: "..il,5)end)local im=ii("-",-52)local io=ii("X",-12)local ip=X("Frame",{Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),BorderSizePixel=0,BackgroundColor3=v,BackgroundTransparency=0.7,Parent=i8})aa.th(ip,"BackgroundColor3","AccentB")local iq=X("Frame",{Position=UDim2.fromOffset(0,47),Size=UDim2.new(1,0,1,-47),BackgroundTransparency=1,Parent=hx})local ir=X("ScrollingFrame",{Size=UDim2.new(0,116,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,Parent=iq})X("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,Parent=ir})X("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,8),Parent=ir})local is=X("Frame",{Position=UDim2.new(0,116,0,6),Size=UDim2.new(0,1,1,-12),BorderSizePixel=0,BackgroundColor3=v,BackgroundTransparency=0.75,Parent=iq})aa.th(is,"BackgroundColor3","AccentB")local it=X("Frame",{Position=UDim2.fromOffset(120,0),Size=UDim2.new(1,-120,1,0),BackgroundTransparency=1,Parent=iq})function aa.fitScale()local gT=D().ViewportSize;local P=math.min(gT.X*0.94/560,gT.Y*0.86/340)if P>1.15 then P=1.15 end;hw.Scale=P*ar.UIScale end;function aa.applyWindow()hx.BackgroundColor3=aP.Glass;hx.BackgroundTransparency=ar.WinTrans;hA.Visible=ar.WinGradient;hA.BackgroundColor3=aP.Sheen;hA.BackgroundTransparency=0;hB.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.84),NumberSequenceKeypoint.new(0.55,0.96),NumberSequenceKeypoint.new(1,1)})hy.Thickness=ar.OutlineThick;hy.Color=aP.Outline;hy.Transparency=0;local iu=ar.OutlineShine and 0.55 or 0;hz.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,iu),NumberSequenceKeypoint.new(1,0)})hz.Color=ColorSequence.new(v,v)if ar.Blur then if not aa.blur then aa.blur=X("BlurEffect",{Name="JHubBlur",Size=0,Parent=o})end;aa.blur.Size=hv.Visible and ar.BlurSize or 0 elseif aa.blur then aa.blur:Destroy()aa.blur=nil end;aa.fitScale()if aa.paintStorm then aa.paintStorm()end end;function aa.applyLogo()if not aa.LogoRoot then return end;aa.LogoRoot.Size=UDim2.fromOffset(ar.LogoSize,ar.LogoSize)aa.LogoBody.BackgroundTransparency=1-ar.LogoOpacity;aa.LogoText.TextTransparency=1-ar.LogoOpacity;aa.LogoText.TextSize=math.floor(ar.LogoSize*0.4)end;function aa.applyTheme()aQ()for g,S in ipairs(aa.themed)do if S[1].Parent then pcall(function()S[1][S[2]]=aP[S[3]]end)end end;for g,S in ipairs(aa.texts)do if S[1].Parent then S[1].Font=aa.font(S[2])S[1].TextStrokeColor3=aP.Stroke;S[1].TextStrokeTransparency=ar.TextStroke and 0.72 or 1 end end;for g,H in ipairs(aa.corners)do if H[1].Parent then H[1].CornerRadius=UDim.new(0,math.floor(ar.Corner*H[2]))end end;for g,a5 in ipairs(aa.cards)do if a5.Parent then a5.BackgroundColor3=aP.Card;a5.BackgroundTransparency=ar.CardTrans end end;local iv=aa.elemTrans()for g,a5 in ipairs(aa.elems)do if a5.Parent then a5.BackgroundColor3=aP.Elem;a5.BackgroundTransparency=iv end end;for g,a3 in ipairs(aa.grads)do if a3.Parent then aa.paintGrad(a3)end end;aa.applyWindow()aa.applyLogo()end;local function iw(ix,bY,iy,iz,iA)local iB,f8,ep,eu;ix.InputBegan:Connect(function(cR)if cR.UserInputType==w or cR.UserInputType==x then iB,f8,ep,eu=cR,cR.Position,bY.Position,false end end)E(l.InputChanged,function(cR)if not iB then return end;if cR==iB or iB.UserInputType==w and cR.UserInputType==y then local bb=cR.Position-f8;if bb.Magnitude>8 then eu=true end;if eu then local gt=iA and iA()or 1;bY.Position=UDim2.new(ep.X.Scale,ep.X.Offset+bb.X/gt,ep.Y.Scale,ep.Y.Offset+bb.Y/gt)end end end)E(l.InputEnded,function(cR)if not iB then return end;if cR==iB or iB.UserInputType==w and cR.UserInputType==w then if not eu and iy then task.spawn(iy)end;if eu and iz then task.spawn(iz)end;iB=nil end end)end;aa.Window=hv;function aa.keepOnScreen()local gT=D().ViewportSize;local bI,fM=hv.AbsolutePosition,hv.AbsoluteSize;local gt=hw.Scale>0 and hw.Scale or 1;local hS,fT=0,0;if bI.X+fM.X<120 then hS=120-(bI.X+fM.X)end;if bI.X>gT.X-120 then hS=gT.X-120-bI.X end;if bI.Y<0 then fT=-bI.Y end;if bI.Y>gT.Y-50 then fT=gT.Y-50-bI.Y end;if hS~=0 or fT~=0 then local bx=hv.Position;hv.Position=UDim2.new(bx.X.Scale,bx.X.Offset+hS/gt,bx.Y.Scale,bx.Y.Offset+fT/gt)end end;function aa.recenter()hv.Position=UDim2.fromScale(0.5,0.5)aa.fitScale()end;local iC=X("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=0,Parent=i8})local iD=X("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(0,116,1,0),ZIndex=0,Parent=iq})aa.DragHandle,aa.RailDrag=iC,iD;iw(iC,hv,nil,aa.keepOnScreen,function()return hw.Scale end)iw(iD,hv,nil,aa.keepOnScreen,function()return hw.Scale end)local iE=X("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,58),Size=UDim2.fromOffset(280,400),BackgroundTransparency=1,Parent=aS})X("UIListLayout",{Padding=UDim.new(0,6),HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder,Parent=iE})local iF=0;function aa.notify(ap,J,aq)if not ar.Notifications then return end;aq=aq or 3;iF=iF+1;local gy=X("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=iF,Parent=iE})local a5=X("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.fromOffset(300,0),BackgroundColor3=aP.Glass,BackgroundTransparency=math.min(ar.WinTrans,0.35),Parent=gy})aa.corner(a5,0.9)X("UIStroke",{Thickness=1.5,Color=v,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=a5})X("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,8),Parent=a5})X("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=a5})aa.label({Text=ap,TextSize=13,Size=UDim2.new(1,0,0,16),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,Parent=a5},true,"Text")aa.label({Text=tostring(J or""),TextSize=12,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=2,Parent=a5},false,"Sub")n:Create(a5,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Position=UDim2.fromOffset(0,0)}):Play()task.delay(aq,function()local S=n:Create(a5,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Position=UDim2.fromOffset(300,0)})S:Play()S.Completed:Wait()gy:Destroy()end)end;function aa.refreshTabs()for g,bI in ipairs(aa.pages)do local h0=aa.current==bI;bI.bg.BackgroundTransparency=h0 and 0.78 or 1;bI.bar.Visible=h0;bI.lbl.Font=aa.font(h0)end end;function aa.select(bI)aa.current=bI;for g,dZ in ipairs(aa.pages)do dZ.frame.Visible=dZ==bI end;aa.refreshTabs()bI.frame.Position=UDim2.fromOffset(0,10)n:Create(bI.frame,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Position=UDim2.fromOffset(0,0)}):Play()end;function aa.Page(bk,iG)local iH=#aa.pages+1;local N=X("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,40),LayoutOrder=iH,Parent=ir})local ib=X("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=v,BackgroundTransparency=1,Parent=N})aa.corner(ib,0.8)local iI=X("Frame",{Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,0,0.5,-10),BackgroundColor3=v,BorderSizePixel=0,Visible=false,Parent=N})aa.corner(iI,"pill")aa.th(iI,"BackgroundColor3","AccentB")local iJ=X("Frame",{Size=UDim2.fromOffset(24,24),Position=UDim2.new(0,8,0.5,-12),BackgroundColor3=v,Parent=N})aa.corner(iJ,0.7)aa.grad(iJ)aa.label({Text=iG,TextSize=13,Size=UDim2.fromScale(1,1),TextColor3=Color3.fromRGB(10,40,100),Parent=iJ},true,false)local iK=aa.label({Text=bk,TextSize=13,Position=UDim2.fromOffset(40,0),Size=UDim2.new(1,-40,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=N},false,"Text")local eE=X("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=it})aa.th(eE,"ScrollBarImageColor3","Outline")X("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,14),Parent=eE})X("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=eE})local bI={name=bk,bg=ib,bar=iI,lbl=iK,frame=eE,order=0}N.Activated:Connect(function()aa.select(bI)end)table.insert(aa.pages,bI)if not aa.current then aa.select(bI)end;return bI end;function aa.Card(iL,ap)iL.order=iL.order+1;local a5=X("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=iL.order,Parent=iL.frame})aa.card(a5)aa.corner(a5,1)aa.stroke(a5,0.6)X("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,10),Parent=a5})X("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=a5})local d7=X("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=0,Parent=a5})local iM=X("Frame",{Size=UDim2.fromOffset(8,8),Position=UDim2.new(0,0,0.5,-4),BackgroundColor3=v,Parent=d7})aa.corner(iM,"pill")aa.grad(iM)aa.label({Text=ap,TextSize=14,Position=UDim2.fromOffset(16,0),Size=UDim2.new(1,-16,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=d7},true,"Text")local gq=X("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=v,BackgroundTransparency=0.75,BorderSizePixel=0,LayoutOrder=1,Parent=a5})return{frame=a5,order=1,page=iL}end;local function iN(iO)iO.order=iO.order+1;return iO.order end;local function iP(iO,aR)return X("Frame",{Size=UDim2.new(1,0,0,aR or 30),BackgroundTransparency=1,LayoutOrder=iN(iO),Parent=iO.frame})end;function aa.Note(iO,av,hs)return aa.label({Text=av,TextSize=11,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,LayoutOrder=iN(iO),Parent=iO.frame},false,hs or"Sub")end;function aa.Stat(iO,bk)local aw=iP(iO,20)aa.label({Text=bk,TextSize=12,Size=UDim2.new(0.45,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=aw},false,"Sub")return aa.label({Text="-",TextSize=12,Position=UDim2.fromScale(0.35,0),Size=UDim2.new(0.65,0,1,0),TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,Parent=aw},true,"Text")end;function aa.Toggle(iO,av,cr,iQ)local aw=iP(iO,30)aa.label({Text=av,TextSize=13,Size=UDim2.new(1,-52,1,0),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=aw},false,"Text")local iR=X("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(42,22),Parent=aw})aa.elem(iR)aa.corner(iR,"pill")aa.stroke(iR,0.45)local iS=X("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=v,BackgroundTransparency=1,Parent=iR})aa.corner(iS,"pill")aa.grad(iS)local iT=X("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(2,2),BackgroundColor3=v,Parent=iR})aa.corner(iT,"pill")local em=X("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Parent=aw})local function fg(dt)local h0=ar[cr]and true or false;local iU=TweenInfo.new(dt and 0.18 or 0,Enum.EasingStyle.Quad)n:Create(iS,iU,{BackgroundTransparency=h0 and 0 or 1}):Play()n:Create(iT,iU,{Position=h0 and UDim2.fromOffset(22,2)or UDim2.fromOffset(2,2)}):Play()end;aa.flagRefresh[cr]=aa.flagRefresh[cr]or{}table.insert(aa.flagRefresh[cr],function()fg(true)end)table.insert(aa.refresh,function()fg(false)end)if iQ and not aa.flagCB[cr]then aa.flagCB[cr]=iQ end;fg(false)em.Activated:Connect(function()aa.set(cr,not ar[cr])end)end;local function iV(bd,G)local eA=0;bd.InputBegan:Connect(function(cR)if cR.UserInputType==w or cR.UserInputType==x then eA=eA+1;local bQ=eA;G()task.spawn(function()task.wait(0.35)while eA==bQ and C.Running do G()task.wait(0.07)end end)cR.Changed:Connect(function()if cR.UserInputState==Enum.UserInputState.End then eA=eA+1 end end)end end)end;function aa.Slider(iO,av,cr,iW,iX,eG,iY,iZ,iQ)local aw=iP(iO,54)iZ=iZ or""aa.label({Text=av,TextSize=13,Size=UDim2.new(1,-78,0,20),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=aw},false,"Text")local ba=X("TextBox",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(74,20),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,TextSize=12,ClearTextOnFocus=false,Parent=aw})aa.text(ba,true)aa.th(ba,"TextColor3","Text")local function i_(cX,dG,j0)local N=X("TextButton",{Text="",AnchorPoint=Vector2.new(j0,0),Position=UDim2.new(dG,0,0,26),Size=UDim2.fromOffset(26,24),AutoButtonColor=false,Parent=aw})aa.elem(N)aa.corner(N,0.7)aa.stroke(N,0.5)aa.label({Text=cX,TextSize=16,Size=UDim2.fromScale(1,1),Parent=N},true,"Text")return N end;local j1=i_("-",0,0)local j2=i_("+",1,1)local iI=X("Frame",{Position=UDim2.new(0,34,0,34),Size=UDim2.new(1,-68,0,8),Parent=aw})aa.elem(iI)aa.corner(iI,"pill")local iS=X("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=v,Parent=iI})aa.corner(iS,"pill")aa.grad(iS)local iT=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(16,16),BackgroundColor3=v,Parent=iI})aa.corner(iT,"pill")X("UIStroke",{Thickness=2,Color=aP.AccentB,Parent=iT})local em=X("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,30,0,24),Size=UDim2.new(1,-60,0,28),Parent=aw})local j3=10^iY;local function fg()local L=tonumber(ar[cr])or iW;local M=K((L-iW)/(iX-iW),0,1)iS.Size=UDim2.fromScale(M,1)iT.Position=UDim2.fromScale(M,0.5)if not ba:IsFocused()then ba.Text=tostring(L)..iZ end end;local function j4(L)L=K(iW+math.floor((L-iW)/eG+0.5)*eG,iW,iX)L=math.floor(L*j3+0.5)/j3;ar[cr]=L;local b4=aa.flagRefresh[cr]if b4 then for g,a5 in ipairs(b4)do pcall(a5)end end;if iQ then iQ(L)end end;aa.addRefresh(cr,fg)fg()ba.FocusLost:Connect(function()local bc=tonumber(string.gsub(ba.Text,"[^%d%.%-]",""))if bc then j4(bc)aI()else fg()end end)iV(j1,function()j4((tonumber(ar[cr])or iW)-eG)aI()end)iV(j2,function()j4((tonumber(ar[cr])or iW)+eG)aI()end)local iB;local function j5(dG)local M,V=iI.AbsolutePosition.X,iI.AbsoluteSize.X;if V<=0 then return end;j4(iW+(iX-iW)*K((dG-M)/V,0,1))end;em.InputBegan:Connect(function(cR)if cR.UserInputType==w or cR.UserInputType==x then iB=cR;iO.page.frame.ScrollingEnabled=false;j5(cR.Position.X)end end)E(l.InputChanged,function(cR)if iB and(cR==iB or iB.UserInputType==w and cR.UserInputType==y)then j5(cR.Position.X)end end)E(l.InputEnded,function(cR)if iB and(cR==iB or iB.UserInputType==w and cR.UserInputType==w)then iB=nil;iO.page.frame.ScrollingEnabled=true;aI()end end)end;function aa.Input(iO,av,cr,iQ,j6)local aw=iP(iO,30)local j7,j8;if type(cr)=="table"then j7,j8=cr.get,cr.set else j7=function()return ar[cr]end;j8=function(L)ar[cr]=L end end;local j9=av and av~=""if j9 then aa.label({Text=av,TextSize=13,Size=UDim2.new(0.4,-4,1,0),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=aw},false,"Text")end;local N=X("TextBox",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=j9 and UDim2.new(0.6,0,0,26)or UDim2.new(1,0,0,26),Text=tostring(j7()or""),PlaceholderText=j6 or"",ClearTextOnFocus=false,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=aw})aa.text(N,false)aa.elem(N)aa.th(N,"TextColor3","Text")aa.th(N,"PlaceholderColor3","Sub")aa.corner(N,0.7)aa.stroke(N,0.5)X("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,6),Parent=N})N.FocusLost:Connect(function()j8(N.Text)if iQ then task.spawn(iQ,N.Text)end;aI()end)aa.addRefresh(type(cr)=="string"and cr or nil,function()if not N:IsFocused()then N.Text=tostring(j7()or"")end end)return N end;function aa.Button(iO,av,iQ,ja)local aw=iP(iO,32)local N=X("TextButton",{Size=UDim2.fromScale(1,1),AutoButtonColor=false,Text="",BackgroundColor3=v,Parent=aw})aa.corner(N,0.8)if ja then aa.grad(N)else aa.elem(N)aa.stroke(N,0.45)end;local bD=aa.label({Text=av,TextSize=13,Size=UDim2.fromScale(1,1),TextColor3=v,Parent=N},true,not ja and"Text"or false)if ja then bD.TextColor3=Color3.fromRGB(8,32,90)end;N.Activated:Connect(function()task.spawn(function()local a9,ef=pcall(iQ)if not a9 then I(av.." error: "..tostring(ef))ao("Error",tostring(ef),4)end end)end)return N,bD end;function aa.Buttons(iO,b4)local aw=iP(iO,32)local bc=#b4;for cR,jb in ipairs(b4)do local N=X("TextButton",{Size=UDim2.new(1/bc,-4,1,0),Position=UDim2.new((cR-1)/bc,cR==1 and 0 or 3,0,0),AutoButtonColor=false,Text="",Parent=aw})aa.elem(N)aa.corner(N,0.8)aa.stroke(N,0.45)aa.label({Text=jb[1],TextSize=12,Size=UDim2.fromScale(1,1),TextTruncate=Enum.TextTruncate.AtEnd,Parent=N},true,"Text")N.Activated:Connect(function()task.spawn(function()local a9,ef=pcall(jb[2])if not a9 then I(jb[1].." error: "..tostring(ef))ao("Error",tostring(ef),4)end end)end)end end;function aa.Dropdown(iO,av,cr,jc,iQ)local aw=X("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=iN(iO),Parent=iO.frame})X("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=aw})local fs=X("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,LayoutOrder=1,Parent=aw})local j9=av and av~=""if j9 then aa.label({Text=av,TextSize=13,Size=UDim2.new(0.4,-4,1,0),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=fs},false,"Text")end;local bd=X("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=j9 and UDim2.new(0.6,0,0,26)or UDim2.new(1,0,0,26),AutoButtonColor=false,Text="",Parent=fs})aa.elem(bd)aa.corner(bd,0.7)aa.stroke(bd,0.45)local aB=aa.label({Text="",TextSize=12,Position=UDim2.fromOffset(8,0),Size=UDim2.new(1,-26,1,0),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=bd},false,"Text")local jd=aa.label({Text="v",TextSize=11,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.fromOffset(12,12),Parent=bd},true,"Text")local b4=X("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false,LayoutOrder=2,Parent=aw})aa.elem(b4)aa.corner(b4,0.7)X("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=b4})X("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),Parent=b4})local function je()if type(jc)=="function"then local a9,_=pcall(jc)if a9 and type(_)=="table"then return _ end;return{}end;return jc end;local function fg()aB.Text=(ar[cr]==nil or ar[cr]=="")and"None"or tostring(ar[cr])end;local function jf()for g,H in ipairs(b4:GetChildren())do if H:IsA("TextButton")then H:Destroy()end end;for cR,_ in ipairs(je())do local jg=_==ar[cr]local jh=X("TextButton",{Size=UDim2.new(1,0,0,24),AutoButtonColor=false,Text="",BackgroundColor3=v,BackgroundTransparency=jg and 0.7 or 1,LayoutOrder=cR,Parent=b4})aa.corner(jh,0.6)aa.label({Text="  "..tostring(_),TextSize=12,Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Left,Parent=jh},jg,"Text")jh.Activated:Connect(function()b4.Visible=false;jd.Text="v"aa.set(cr,_,false)if iQ then task.spawn(iQ,_)end end)end end;bd.Activated:Connect(function()if b4.Visible then b4.Visible=false;jd.Text="v"else jf()b4.Visible=true;jd.Text="^"end end)aa.addRefresh(cr,fg)fg()end;function aa.Keybind(iO,av,j7,ji)local aw=iP(iO,30)aa.label({Text=av,TextSize=13,Size=UDim2.new(1,-104,1,0),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=aw},false,"Text")local N=X("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(96,26),AutoButtonColor=false,Text="",Parent=aw})aa.elem(N)aa.corner(N,0.7)aa.stroke(N,0.45)local bD=aa.label({Text="",TextSize=12,Size=UDim2.fromScale(1,1),Parent=N},true,"Text")local function fg()local a1=j7()bD.Text=a1 and a1~=""and a1 or"None"end;fg()table.insert(aa.refresh,fg)N.Activated:Connect(function()bD.Text="press key or button..."aa.listening=function(bk)ji(bk or"")fg()aI()end;task.delay(6,function()if bD.Text=="press key or button..."then aa.listening=nil;fg()end end)end)end;aa.visible=true;function aa.show(L)aa.visible=L;if L then hv.Visible=true;local bY=hw.Scale;hw.Scale=bY*0.9;n:Create(hw,TweenInfo.new(0.22,Enum.EasingStyle.Back),{Scale=bY}):Play()else hv.Visible=false;aa.fitScale()end;if aa.blur then aa.blur.Size=L and ar.BlurSize or 0 end end;function aa.toggleMenu()aa.show(not hv.Visible)end;io.Activated:Connect(function()C.Unload()end)local jj=false;im.Activated:Connect(function()jj=not jj;iq.Visible=not jj;hv.Size=jj and UDim2.fromOffset(560,46)or UDim2.fromOffset(560,340)end)E(D():GetPropertyChangedSignal("ViewportSize"),function()aa.fitScale()end)local jk=X("Frame",{Name="LogoRoot",Size=UDim2.fromOffset(ar.LogoSize,ar.LogoSize),BackgroundTransparency=1,Parent=aS})if ar.LogoX>=0 and ar.LogoY>=0 then jk.Position=UDim2.fromOffset(ar.LogoX,ar.LogoY)else jk.Position=UDim2.new(0,14,0.4,0)end;local jl=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(1.5,1.5),BackgroundColor3=v,BackgroundTransparency=0.82,ZIndex=0,Parent=jk})aa.corner(jl,2)local jm=X("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromScale(1,1),BackgroundColor3=v,ZIndex=2,Parent=jk})aa.corner(jm,1.6)jm.BackgroundColor3=Color3.fromRGB(12,14,32)aa.FloatBodyGrad=X("UIGradient",{Rotation=30,Parent=jm})aa.FloatBodyGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(12,14,32)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(100,78,10)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,14,32))})local jn=X("UIStroke",{Thickness=2.5,Color=v,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=jm})local jo=X("UIGradient",{Parent=jn})jo.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,0.35),NumberSequenceKeypoint.new(1,0)})jo.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,221,64)),ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,221,64))})local jp=aa.label({Text="",TextSize=22,Size=UDim2.fromScale(1,1),TextColor3=v,ZIndex=3,Parent=jm},true,false)local jq=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(7,7),BackgroundColor3=v,ZIndex=4,Parent=jk})aa.corner(jq,"pill")local jr=X("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(5,5),BackgroundColor3=v,BackgroundTransparency=0.25,ZIndex=4,Parent=jk})aa.corner(jr,"pill")aa.LogoRoot,aa.LogoBody,aa.LogoText=jk,jm,jp;do local js=aa.label({Text="J",TextScaled=true,Position=UDim2.fromScale(0.1,0.27),Size=UDim2.fromScale(0.28,0.46),TextColor3=v,ZIndex=3,Parent=jm},true,false)local jt=aa.label({Text="H",TextScaled=true,Position=UDim2.fromScale(0.62,0.27),Size=UDim2.fromScale(0.28,0.46),TextColor3=v,ZIndex=3,Parent=jm},true,false)aa.makeBolt(jm,UDim2.fromScale(0.5,0.5),UDim2.fromScale(0.36,0.62),3)aa.FloatLetters={js,jt}end;iw(jm,jk,aa.toggleMenu,function()ar.LogoX,ar.LogoY=jk.AbsolutePosition.X,jk.AbsolutePosition.Y;aI()end)local ju=X("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,6),Size=UDim2.fromOffset(0,24),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=aP.Glass,BackgroundTransparency=0.45,Parent=aS})aa.corner(ju,0.8)X("UIStroke",{Thickness=1.5,Color=v,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=ju})X("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),Parent=ju})local jv=aa.label({Text="",TextSize=12,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Parent=ju},true,"Text")local jw=X("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(92,44),Position=UDim2.new(1,-112,0.55,0),BackgroundColor3=v,Visible=false,Parent=aS})aa.corner(jw,0.9)aa.grad(jw)X("UIStroke",{Thickness=2,Color=v,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=jw})aa.label({Text="GREEN SHOT",TextSize=12,Size=UDim2.fromScale(1,1),TextColor3=Color3.fromRGB(8,32,90),Parent=jw},true,false)iw(jw,jw,function()ae.run("backup")end)local jx="Unknown"pcall(function()if identifyexecutor then local M,N=identifyexecutor()jx=tostring(M or"Unknown")..(N and N~=""and" "..tostring(N)or"")elseif getexecutorname then jx=tostring(getexecutorname())end end)C.execName=jx;local jy="Practical Basketball"C.placeName=jy;task.spawn(function()pcall(function()jy=r:GetProductInfo(game.PlaceId).Name;C.placeName=jy end)end)local function jz(a5)return a5~=nil and"yes"or"no"end;local jA={}local jB=aa.Page("Main","M")do local H=aa.Card(jB,"Profile")local jC=iP(H,62)local jD=X("ImageLabel",{Size=UDim2.fromOffset(58,58),Position=UDim2.fromOffset(0,2),BackgroundColor3=v,BackgroundTransparency=0.85,Parent=jC})aa.corner(jD,"pill")X("UIStroke",{Thickness=2,Color=v,Parent=jD})aa.label({Text=u.DisplayName,TextSize=17,Position=UDim2.fromOffset(70,8),Size=UDim2.new(1,-70,0,22),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=jC},true,"Text")aa.label({Text="@"..u.Name,TextSize=12,Position=UDim2.fromOffset(70,32),Size=UDim2.new(1,-70,0,16),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=jC},false,"Sub")task.spawn(function()local a9,aY=pcall(function()return j:GetUserThumbnailAsync(u.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)end)if a9 and aY then jD.Image=aY end end)aa.Stat(H,"Roblox username").Text=u.Name;jA.game=aa.Stat(H,"Game")jA.time=aa.Stat(H,"Time")aa.Stat(H,"Executor").Text=jx;local ce=aa.Card(jB,"Server")aa.Button(ce,"Rejoin",ab.rejoin,true)aa.Buttons(ce,{{"Join new server",function()ab.hop("new")end},{"Join lower server",function()ab.hop("lower")end}})local ca=aa.Card(jB,"Codes")aa.Input(ca,"","Codes",nil,"codes separated by spaces")aa.Button(ca,"Redeem all codes",ab.redeemAll,true)local jE=aa.Card(jB,"Auto execute")aa.Toggle(jE,"Auto execute","AutoExec",function(L)ab.autoExec(L)end)local jF=aa.Card(jB,"Game recorder")aa.Toggle(jF,"Record the game","RecOn",function(L)if L then an.start()else an.stop()end end)jA.rec=aa.Stat(jF,"Recorded")aa.Buttons(jF,{{"Copy recording",an.copy},{"Clear",an.clear}})aa.Button(jF,"Copy remote spy (RSpy)",an.copySpy)local jG=aa.Card(jB,"Shot recorder")aa.Toggle(jG,"Record shots (turn off to copy everything)","RecShots",function(L)if L then an.shotStart()else an.shotStop()end end)aa.Toggle(jG,"Sweep timings while recording (locked off)","Sweep",function()ar.Sweep=false;local b4=aa.flagRefresh["Sweep"]if b4 then for g,a5 in ipairs(b4)do pcall(a5)end end;aI()ao("Shot recorder","Sweep stays off. It deliberately misses shots on purpose and is not something you want running.",5)end)aa.Button(jG,"Capture everything about shooting",an.captureAll)local jH=aa.Card(jB,"Game scanner")aa.Buttons(jH,{{"Scan game and copy",an.scanGame},{"Copy last scan",an.copyScan}})end;function aa.restore(bG,jI)for g,a1 in ipairs(bG)do ar[a1]=as[a1]end;if jI then pcall(jI)end;aa.refreshAll()aI()ao("Restored","Back to default",2)end;jB=aa.Page("Shooting","S")do local a3=aa.Card(jB,"Auto Green")local jJ=false;function aa.syncAuto()local h0=ar.AutoGreen~=false;ar.AutoCal,ar.Learn=h0,h0 end;aa.Toggle(a3,"Auto Green","AutoGreen",function()aa.syncAuto()end)aa.Dropdown(a3,"Shot style (Hold or Tap)","ShotStyle",{"Hold","Tap"})aa.Slider(a3,"Starting hold time","HoldTime",0.08,1.6,0.005,3,"s")aa.Slider(a3,"Release earlier / later","Nudge",-150,150,5,0,"ms")aa.Toggle(a3,"Perfect green","PerfectGreen")aa.Note(a3,"Makes up for high ping/ms. Does nothing if you have low ping.")aa.Slider(a3,"Perfect green strength","PerfectGreenPct",0,150,5,0,"%")if jJ then local jK=aa.Card(jB,"Learning")aa.Toggle(jK,"Learn timing from results","Learn")aa.Toggle(jK,"Auto-learn new shot animations","AutoCal")end;local jL=aa.Card(jB,"Auto Calibrate")aa.Toggle(jL,"Auto Calibrate","AutoCalibrate")aa.Slider(jL,"Learn speed","CalSpeed",0.1,1,0.05,2)aa.Button(jL,"Forget learned animations",function()ae.autoReset()ao("Auto Green","Learned animations cleared",2)end)local hc=aa.Card(jB,"Auto Timing")aa.Toggle(hc,"Auto Timing","AutoTiming")aa.Slider(hc,"Ping compensation","PingComp",0,100,5,0,"%")local jM=aa.Card(jB,"Restore")aa.Button(jM,"Restore to default",function()aa.restore({"AutoGreen","ShotStyle","HoldTime","Nudge","Learn","PerfectGreen","PerfectGreenPct","AutoCalibrate","CalSpeed","AutoTiming","PingComp","ShotTimes","ShotRatio","PacketMul","PacketOn"},function()ae.parseTimes()ae.brackets={}aa.syncAuto()end)end)end;jB=aa.Page("Dribbling","D")do local bb=aa.Card(jB,"Dribble Glide")aa.Toggle(bb,"Dribble Glide","DribbleGlide")aa.Slider(bb,"Glide power","DribbleGlidePower",1,80,1,0)aa.Slider(bb,"Glide speed","DribbleGlideSpeed",0.5,3,0.1,1,"x")aa.Slider(bb,"Time","DribbleGlideTime",0.05,1,0.01,2,"s")local fZ=aa.Card(jB,"Shot Glide")aa.Toggle(fZ,"Shot Glide","ShotGlide")aa.Slider(fZ,"Glide power","ShotGlidePower",1,80,1,0)aa.Slider(fZ,"Glide speed","ShotGlideSpeed",0.5,3,0.1,1,"x")aa.Dropdown(fZ,"Shot glide method","ShotGlideMethod",{"GameVel","CFrame","Velocity","Auto"})aa.Dropdown(fZ,"Shot glide starts","ShotGlideWhen",{"After release","During shot"})aa.Slider(fZ,"Time","ShotGlideTime",0.05,1,0.01,2,"s")local hW=aa.Card(jB,"Gather Step Glide")aa.Toggle(hW,"Gather Step Glide","GatherGlide")aa.Slider(hW,"Glide power","GatherGlidePower",1,80,1,0)aa.Slider(hW,"Glide speed","GatherGlideSpeed",0.5,3,0.1,1,"x")aa.Slider(hW,"Time","GatherGlideTime",0.05,1,0.01,2,"s")local jM=aa.Card(jB,"Restore")aa.Button(jM,"Restore to default",function()aa.restore({"DribbleGlideSpeed","ShotGlideSpeed","GatherGlideSpeed","DribbleGlide","DribbleGlidePower","DribbleGlideTime","ShotGlide","ShotGlidePower","ShotGlideTime","GatherGlide","GatherGlidePower","GatherGlideTime"})end)end;jB=aa.Page("Players","P")do local N=aa.Card(jB,"Walk speed boost (walking, no ball)")aa.Toggle(N,"Walk speed boost","SpeedOn",function(L)if L then ai.resetAuto()end end)aa.Slider(N,"Level (0 = normal, each level x1.1)","SpeedAdd",0,15,1,0)local jN=aa.Card(jB,"Run speed boost (running, no ball)")aa.Toggle(jN,"Run speed boost","RunOn",function(L)if L then ai.resetAuto()end end)aa.Slider(jN,"Level (0 = normal, each level x1.1)","RunAdd",0,15,1,0)local jO=aa.Card(jB,"Ball speed boost (with the ball)")aa.Toggle(jO,"Ball speed boost","BallSpeedOn",function(L)if L then ai.resetAuto()end end)aa.Slider(jO,"Level (0 = normal, each level x1.1)","BallAdd",0,15,1,0)local g6=aa.Card(jB,"Low settings fix")aa.lowStat=aa.Stat(g6,"Your device")aa.Note(g6,"On low graphics or a low frame rate the speed boost and the dribble glide lose strength. This gives the boost a percentage more and keeps the glide, just weaker.")aa.Toggle(g6,"Low settings fix","LowFix")aa.Slider(g6,"Extra speed boost on low settings","LowBoostPct",0,100,5,0,"%")aa.Slider(g6,"Glide strength on low settings","LowGlidePct",10,100,5,0,"%")aa.Slider(g6,"Count graphics up to this level as low","LowLevel",1,8,1,0)local jM=aa.Card(jB,"Restore")aa.Button(jM,"Restore to default",function()aa.restore({"SpeedOn","SpeedAdd","RunOn","RunAdd","BallSpeedOn","BallAdd","LowFix","LowBoostPct","LowGlidePct","LowLevel"},function()ai.resetAuto()end)end)end;jB=aa.Page("Ball Mags","B")do local bJ=aa.Card(jB,"Ball magnet")aa.Toggle(bJ,"Ball magnet","BallMagnet")aa.Dropdown(bJ,"How it gets the ball","MagnetMode",{"Pull to me","Go to the ball"})aa.Slider(bJ,"Range","MagnetRange",10,150,5,0," studs")aa.Slider(bJ,"Minimum time on the ball (frames)","MagnetFrames",1,6,1,0)aa.Slider(bJ,"Grab delay (so it is not instant)","MagnetDelay",0,400,10,0," ms")aa.Button(bJ,"Get the ball now",function()if not aj.getBall(true)then ao("Ball magnet","No ball found.",2)end end)local jM=aa.Card(jB,"Restore")aa.Button(jM,"Restore to default",function()aa.restore({"BallMagnet","MagnetMode","MagnetRange","MagnetFrames"})end)end;jB=aa.Page("Features","F")do local jP=aa.Card(jB,"Practical Basketball logo")aa.Toggle(jP,"Show logo","LogoOn")aa.Dropdown(jP,"Logo","Logo",aj.V.LOGO_NAMES)local jQ=aa.Card(jB,"Mascot")aa.Toggle(jQ,"Mascot","MascotOn")aa.Dropdown(jQ,"Pick a mascot","Mascot",aj.V.MASCOT_NAMES)local jR=aa.Card(jB,"Maxed stats (only you see this)")aa.Toggle(jR,"Max overall","MaxOverall")aa.Toggle(jR,"Max coins","MaxCoins")aa.Toggle(jR,"Max badges","MaxBadges")local jM=aa.Card(jB,"Restore")aa.Button(jM,"Restore to default",function()aa.restore({"LogoOn","Logo","MascotOn","Mascot","MaxOverall","MaxCoins","MaxBadges"})end)end;jB=aa.Page("UI","U")do local jS=aa.Card(jB,"Glass look")aa.Slider(jS,"Menu transparency","WinTrans",0,0.95,0.01,2,nil,function()aa.applyWindow()end)aa.Slider(jS,"Card transparency","CardTrans",0.3,0.98,0.01,2,nil,function()aa.applyTheme()end)aa.Slider(jS,"Color shade (hue)","Hue",0,360,1,0,nil,function()aa.applyTheme()end)aa.Slider(jS,"Color strength","Sat",0.1,1,0.01,2,nil,function()aa.applyTheme()end)aa.Slider(jS,"Brightness","Val",0.2,1,0.01,2,nil,function()aa.applyTheme()end)local id=aa.Card(jB,"Outline")aa.Dropdown(id,"Outline color","OutlineColor",aL,function()aa.applyTheme()end)aa.Slider(id,"Outline thickness","OutlineThick",0,6,0.5,1,nil,function()aa.applyWindow()end)aa.Toggle(id,"Moving outline shine","OutlineShine",function()aa.applyWindow()end)local cY=aa.Card(jB,"Text")aa.Dropdown(cY,"Text color","TextColor",aM,function()aa.applyTheme()end)aa.Toggle(cY,"Dark text outline","TextStroke",function()aa.applyTheme()end)aa.Dropdown(cY,"Font","Font",aO,function()aa.applyTheme()aa.refreshTabs()end)local jT=aa.Card(jB,"Layout")aa.Slider(jT,"Corner roundness","Corner",0,20,1,0,nil,function()aa.applyTheme()end)aa.Slider(jT,"Menu size","UIScale",0.6,1.5,0.05,2,"x",function()aa.fitScale()end)aa.Toggle(jT,"Info bar","Watermark",function()ju.Visible=ar.Watermark end)aa.Button(jT,"Put the menu back in the middle",function()aa.recenter()end)local jP=aa.Card(jB,"Logo")aa.Slider(jP,"Logo size","LogoSize",36,96,2,0,nil,function()aa.applyLogo()end)aa.Slider(jP,"Logo visibility","LogoOpacity",0.3,1,0.05,2,nil,function()aa.applyLogo()end)aa.Toggle(jP,"Moving logo animation","LogoAnim")aa.Button(jP,"Reset logo position",function()ar.LogoX,ar.LogoY=-1,-1;jk.Position=UDim2.new(0,14,0.4,0)aI()end)local bS=aa.Card(jB,"Presets")aa.Note(bS,"One tap look changes. Everything below can still be tuned by hand.")aa.Dropdown(bS,"Theme preset","Preset",aa.PRESET_NAMES,function(L)aa.applyPreset(L)end)aa.Dropdown(bS,"Accent colors","AccentMode",{"Gold","Match hue"},function()aa.applyTheme()end)local jU=aa.Card(jB,"Lightning")aa.Toggle(jU,"Lightning background","Lightning",function()aa.applyFx()end)aa.Dropdown(jU,"Lightning colors","BoltColor",{"White + Yellow","Yellow","White"})aa.Slider(jU,"Lightning amount","BoltCount",1,10,1,0)aa.Slider(jU,"Lightning speed","BoltSpeed",0.3,3,0.1,1,"x")aa.Slider(jU,"Lightning thickness","BoltThick",1,5,0.5,1)aa.Slider(jU,"Lightning brightness","BoltBright",0.2,1,0.05,2)local jV=aa.Card(jB,"Moving background")aa.Toggle(jV,"Moving background","BgMove")aa.Slider(jV,"Background glow","BgGlow",0,1,0.05,2,nil,function()aa.paintStorm()end)aa.Toggle(jV,"Floating light orbs","BgOrbs")local jW=aa.Card(jB,"Header logo")aa.Dropdown(jW,"Logo style","LogoStyle",{"J bolt H","JHub V1"},function()aa.applyFx()end)aa.Toggle(jW,"Moving logo background","LogoBg")aa.Slider(jW,"Moving outline speed","OutlineSpeed",0,4,0.1,1,"x")local jX=aa.Card(jB,"Alerts and keys")aa.Toggle(jX,"Notifications","Notifications")aa.Toggle(jX,"Sounds","Sounds")aa.Input(jX,"Green sound ID (Roblox audio number)","GreenSoundId",nil,"paste a Roblox audio ID")aa.Slider(jX,"Green sound volume","GreenSoundVol",0.1,1,0.05,2)aa.Keybind(jX,"Menu key (PC)",function()return ar.MenuKey end,function(L)ar.MenuKey=L~=""and L or"RightShift"end)local jY=aa.Card(jB,"Tools")aa.Button(jY,"Save settings now",function()aG()ao("Saved","Settings saved",2)end)aa.Button(jY,"Reset all settings",function()for a1,L in pairs(as)do ar[a1]=L end;aa.refreshAll()aI()ao("Reset","All settings back to default",2)end)aa.Button(jY,"Unload JHub",function()C.Unload()end)local jM=aa.Card(jB,"Restore")aa.Button(jM,"Restore to default",function()aa.restore({"WinTrans","CardTrans","Hue","Sat","Val","OutlineColor","OutlineThick","OutlineShine","TextColor","TextStroke","Font","Corner","UIScale","Watermark","LogoSize","LogoOpacity","LogoAnim","Notifications","Sounds","MenuKey"},function()aa.applyTheme()aa.applyWindow()aa.applyLogo()aa.fitScale()ju.Visible=ar.Watermark;aa.refreshTabs()end)end)end;E(l.InputBegan,function(cR,jZ)if an.on then pcall(an.input,"down",cR)end;if ak.mode and(cR.UserInputType==x or cR.UserInputType==w)then local b3=ak.mode;ak.mode=nil;task.defer(ak.handle,b3,cR.Position)return end;if cR.UserInputType==x then if hv.Visible and ac.hits(hv,cR.Position)then return end;if ac.hits(jk,cR.Position)then return end;if jw.Visible and ac.hits(jw,cR.Position)then return end;ac.lastTouch={input=cR,t0=tick(),pos=cR.Position,obj=ac.topButtonAt(cR.Position)}if(ar.DribbleGlide or ar.GatherGlide)and not ae.hooked then for g,aF in ipairs({"dribble","gather"})do for g,N in ipairs(ac.glideButtons(aF))do if N.Parent and a2(N)and ac.hits(N,cR.Position)then ag.fire(aF,"touch on the "..aF.." button")break end end end end;if ar.RunOn then local j_=ac.findButton("Sprint")if j_ and a2(j_)and ac.hits(j_,cR.Position)then ac.sprintTouch=cR end end;if ar.ShotGlide and not(ar.AutoGreen and ar.HookShootButton)and not ae.hooked then local k0=ac.findButton("Shoot")if k0 and a2(k0)and ac.hits(k0,cR.Position)then ag.fire("shot","touch on the shoot button")end end;if(ar.AutoGreen or al.isArmed())and ar.HookShootButton and not ae.busy and not ae.hooked then local bd=ac.findButton("Shoot")if bd and a2(bd)and ac.hits(bd,cR.Position)then local da={btn=bd,input=cR,t0=tick(),ended=false}ae.touchCtx=da;task.spawn(ae.run,"touch",da)end end;return end;local k1=cR.UserInputType;if aa.listening and(k1==Enum.UserInputType.Gamepad1 or k1==Enum.UserInputType.Gamepad2 or k1==Enum.UserInputType.Gamepad3 or k1==Enum.UserInputType.Gamepad4)then local a5=aa.listening;aa.listening=nil;a5(cR.KeyCode.Name)return end;if cR.UserInputType~=z then return end;if aa.listening then local a5=aa.listening;aa.listening=nil;if cR.KeyCode==Enum.KeyCode.Escape or cR.KeyCode==Enum.KeyCode.Backspace then a5("")else a5(cR.KeyCode.Name)end;return end;if l:GetFocusedTextBox()then return end;local k2=cR.KeyCode;if k2==ac.keyCode(ar.MenuKey)then aa.toggleMenu()return end;if ae.busy then return end;if k2==ac.keyCode(ar.ShootKey)then if ar.ManualAssist and(ar.AutoGreen or al.isArmed())and not ae.hooked then task.spawn(ae.run,"manualKey",{kc=k2,t0=tick()})end;return end;local bG=Q(ar.DribbleKeys)for g,bk in ipairs(bG)do if ac.keyCode(bk)==k2 and(ad.holding or not next(ad.parts))and not ae.hooked then ag.fire("dribble","key "..bk)break end end end)E(l.InputEnded,function(cR)local da=ae.touchCtx;if da and cR==da.input then da.ended=true end;if an.on then pcall(an.input,"up",cR)end;if ac.lastTouch and ac.lastTouch.input==cR then ac.lastTouch.endT=tick()end;if ac.sprintTouch==cR then ac.sprintTouch=nil end end)local k3=0;E(k.Heartbeat,function(ec)C.FPS=C.FPS*0.9+1/math.max(ec,0.001)*0.1;pcall(ah.poll)local S=tick()if hv.Visible then hz.Rotation=S*70*(ar.OutlineSpeed or 1)%360;local dT=S*0.4%2-1;i9.Offset=Vector2.new(dT,0)if ar.OutlineColor=="Rainbow"then k3=(k3+ec*0.25)%1;hy.Color=Color3.fromHSV(k3,0.55,1)end end;if ar.LogoAnim then jm.Position=UDim2.fromOffset(0,math.sin(S*2.2)*3)jl.BackgroundTransparency=0.8+math.sin(S*3)*0.08;jo.Rotation=S*120%360;local M=S*2.4;jq.Position=UDim2.new(0.5,math.cos(M)*ar.LogoSize*0.62,0.5,math.sin(M)*ar.LogoSize*0.62)jr.Position=UDim2.new(0.5,math.cos(M+3.14)*ar.LogoSize*0.55,0.5,math.sin(M+3.14)*ar.LogoSize*0.55)jq.Visible,jr.Visible=true,true else jm.Position=UDim2.fromOffset(0,0)jq.Visible,jr.Visible=false,false end end)E(k.Stepped,function(g,ec)local a9,ef=pcall(ai.step,ec)if not a9 and ai.lastErr~=tostring(ef)then ai.lastErr=tostring(ef)I("Speed error: "..ai.lastErr)ao("Speed problem",ai.lastErr,5)end end)task.spawn(function()local eT=0;while C.Running do eT=eT+1;local a9,k4,k5=pcall(ad.check)if a9 then ad.holding,ad.source=k4,k5 end;pcall(aj.tick,eT)task.wait(0.1)end end)task.spawn(function()while C.Running do pcall(function()local bZ=os.date("*t")local k6=bZ.hour%12;if k6==0 then k6=12 end;local k7=string.format("%d:%02d:%02d %s",k6,bZ.min,bZ.sec,bZ.hour>=12 and"PM"or"AM")local d8=0;pcall(function()d8=math.floor(u:GetNetworkPing()*1000)end)local eL=math.floor(C.FPS+0.5)jv.Text=string.format("JHub V"..B:sub(2).."  |  %d FPS  |  %d ms  |  %s",eL,d8,k7)..(ai.extra>0 and string.format("  |  BOOST +%.0f",ai.extra)or"")if not hv.Visible then return end;if aa.current and aa.current.name=="Main"then jA.game.Text=jy;jA.time.Text=k7;jA.rec.Text=an.summary()end end)task.wait(0.25)end end)function C.Unload()C.Running=false;for g,H in ipairs(C.Connections)do pcall(function()H:Disconnect()end)end;pcall(ae.release,"manualKey",nil)if aj.sprinting then pcall(ac.action,"Sprint",false)end;local aR=a7()if aR and ai.lastSet then pcall(function()aR.WalkSpeed=ai.gameWS end)end;if aa.blur then pcall(function()aa.blur:Destroy()end)end;pcall(ai.gvRestore)pcall(aj.V.cleanup)pcall(an.stop)aG()pcall(function()aS:Destroy()end)if c.JHubGlass==C then c.JHubGlass=nil end end;C.api={S=ar,UI=aa,Net=ab,Input=ac,Ball=ad,Shot=ae,Backup=af,Glide=ag,Anim=ah,Speed=ai,Feat=aj,Picker=ak,Bar=al,Mover=am,Rec=an}ag.chain={"CFrame","Velocity","Input","AttrBoost","Impulse"}ag.fails=0;function ag.judge(aF,eo,ep,cd,ev,dr)local aw=am.body()if not aw then return end;local eu=(aw.Position-ep):Dot(cd)ag.last=string.format("%s (%s) via %s: moved %.1f of %.1f studs",aF,dr or"?",eo,eu,ev)I("Glide "..ag.last)if ev<4 then return end;if eu>=ev*0.4 then ag.fails=0;if tick()-ag.lastNote>10 then ag.lastNote=tick()ao("Glide","WORKS",2)end;return end;ag.fails=ag.fails+1;if ag.fails<3 then return end;ag.fails=0;if ar.GlideMethod=="Auto"and not(aF=="shot"and ar.ShotGlideMethod~="Auto")then ag.cur=ag.cur%#ag.chain+1;ao("Glide","not yet, trying "..ag.chain[ag.cur],2)else ao("Glide","DOESN'T WORK",3)end end;function ag.start(aF,eq,er,ex)local aw,aR=am.body(),a7()eq=eq*(ar.GlideSpeed or 1)*ag.lowScale()if not aw or not aR or eq<=0 or er<=0 then return end;local bZ=tick()if bZ-(ag.lastStart[aF]or 0)<er*0.5 then return end;ag.lastStart[aF]=bZ;local ey=am.intent(aR,aw)local cd=W(ey)if ex and W(ex).Magnitude>0.1 then cd=W(ex)end;if cd.Magnitude<0.1 then cd=W(aw.CFrame.LookVector)end;if cd.Magnitude<0.01 then return end;cd=cd.Unit;local eo=ar.GlideMethod;if aF=="shot"and ar.ShotGlideMethod and ar.ShotGlideMethod~="Auto"then eo=ar.ShotGlideMethod end;if eo=="Auto"then eo=ag.chain[ag.cur]end;if eo=="GameVel"then local ez=am.playerModule()if not(ez and ez.Character and ez.Character.Movement and typeof(ez.Character.Movement.CFVelocity)=="Vector3")then eo="CFrame"end end;ag.token=ag.token+1;local eA=ag.token;local ep=aw.Position;local dr=ag.why;local eB=W(ey)*ai.gameWS;local hn=eq*er*0.8;local k8=am.gameVel()or Vector3.new(0,0,0)local k9,ff,eD=0,false,bZ;if eo=="Input"then ag.input={untilT=bZ+er,scale=1+eq/math.max(ai.gameWS,1),dir=cd,t0=bZ,nextSend=0}end;if eo=="Impulse"then pcall(function()aw:ApplyImpulse(cd*aw.AssemblyMass*eq)end)end;local function eC()local H=a4()if H and eo=="AttrBoost"then H:SetAttribute("SpeedBoost",0)H:SetAttribute("SpeedBoostTime",0)H:SetAttribute("AccelerationBoost",0)end end;local function eE()if ff then return"stop"end;if eo=="Input"and eA==ag.token then local H=a4()if H and H:GetAttribute("CanMove")==false and tick()-eD<1.5 then bZ=tick()if ag.input then ag.input.untilT=bZ+er;ag.input.paused=true end;return nil end;if ag.input then ag.input.paused=false end end;local bI=K((tick()-bZ)/er,0,1)local ka=eA~=ag.token or not aw.Parent or not C.Running;if eo=="CFrame"and not ka then local f6=eq*er*0.8*(2*bI-bI*bI)local eG=f6-k9;if eG>0 and not ag.blocked(aw,cd,eG)then aw.CFrame=aw.CFrame+cd*eG;k9=f6;am.sync(aw)end end;if ka or bI>=1 then ff=true;eC()if eA==ag.token then task.delay(0.15,function()if eA==ag.token then pcall(ag.judge,aF,eo,ep,cd,hn,dr)end end)end;return"stop"end;local eF=1.6*(1-bI)if eo=="GameVel"then local ez=am.playerModule()local kb=ez and ez.Character and ez.Character.Movement;if kb and typeof(kb.CFVelocity)=="Vector3"then local cb=kb.CFVelocity;kb.CFVelocity=Vector3.new(k8.X+cd.X*eq*eF,cb.Y,k8.Z+cd.Z*eq*eF)end;return nil end;if eo=="Impulse"or eo=="CFrame"then return nil end;if eo=="AttrBoost"then local H=a4()if H then ag.attrOn=true;H:SetAttribute("SpeedBoost",eq*eF/math.max(ai.gameWS,1))H:SetAttribute("SpeedBoostTime",0.25)H:SetAttribute("AccelerationBoost",0.5)end;return nil end;if eo=="Input"then local bV=ag.input;if not bV then return"stop"end;bV.scale=1+eq*eF/math.max(ai.gameWS,1)local kc=am.gameIntent()if(not kc or kc.Magnitude<0.05)and tick()>=bV.nextSend then bV.nextSend=tick()+0.05;am.send(cd*bV.scale)end;return nil end;if eo=="Velocity"then local L=aw.AssemblyLinearVelocity;local S=eB+cd*eq*eF;aw.AssemblyLinearVelocity=Vector3.new(S.X,L.Y,S.Z)end;return nil end;local bg={}local function kd()local a9,aZ=pcall(eE)if not a9 then ag.lastErr=tostring(aZ)I("Glide error: "..ag.lastErr)ao("Glide problem",ag.lastErr,5)end;if not a9 or aZ=="stop"then for g,H in ipairs(bg)do H:Disconnect()end end end;bg[1]=k.Stepped:Connect(kd)bg[2]=k.Heartbeat:Connect(kd)end;function am.onDribble(c4)ah.lastDribble=tick()local c5=a4()local c7=c5 and c5:GetAttribute("LastDribblePackage")local cd=am.moveWhere(1.5)if not cd and typeof(c4[3])=="Vector3"and W(c4[3]).Magnitude>0.1 then cd=W(c4[3])end;task.spawn(function()local c9=tick()while C.Running and tick()-c9<0.1 do local ca=a4()if ca and ca:GetAttribute("LastDribblePackage")~=c7 then break end;k.Heartbeat:Wait()end;if not C.Running then return end;local H=a4()local cc=H and H:GetAttribute("LastDribblePackage")local bk=type(cc)=="string"and string.lower(cc)or""cd=am.moveWhere(1.5)or cd;if T(bk,am.GATHER_MOVES)then if not cd and(string.find(bk,"step back",1,true)or string.find(bk,"stepback",1,true))then local a_=am.body()if a_ then cd=-W(a_.CFrame.LookVector)end end;ag.fire("gather","step back move "..bk,cd)else ag.fire("dribble","dribble move "..(bk~=""and bk or tostring(c4[1])),cd)end end)end;ag.kinds={dribble={"DribbleGlide","DribbleGlidePower","DribbleGlideTime","DribbleGlideSpeed"},gather={"GatherGlide","GatherGlidePower","GatherGlideTime","GatherGlideSpeed"},shot={"ShotGlide","ShotGlidePower","ShotGlideTime","ShotGlideSpeed"}}function ag.fire(aF,dr,cd)local a1=ag.kinds[aF]if not a1 or not ar[a1[1]]then return end;if ar.GlideNeedBall and aF~="shot"and not ad.holding then I("Glide "..aF.." skipped: you do not hold the ball")return end;local bJ=math.max(ar[a1[4]]or 1,0.1)ag.why=dr or"?"ag.start(aF,ar[a1[2]]*bJ,ar[a1[3]]/bJ,cd)end;function ag.test(aF)local a1=ag.kinds[aF]if not a1 then return end;ag.lastStart[aF]=0;ag.why="test button"local bJ=math.max(ar[a1[4]]or 1,0.1)ag.start(aF,ar[a1[2]]*bJ,ar[a1[3]]/bJ)end;function am.watchShot(cf)local aR,aw=a7(),am.body()local ke;if aR and aw then local ey=am.intent(aR,aw)if ey.Magnitude>0.1 then ke=W(ey)end end;task.spawn(function()local c9=tick()while C.Running and tick()-c9<0.35 and ae.meterT<cf-0.05 do k.Heartbeat:Wait()end;if not C.Running or ae.meterT<cf-0.05 then return end;local H=a4()local dt=string.lower(tostring(H and H:GetAttribute("BaseAnimation")or""))local a_=am.body()local cd=ke;if not cd and a_ and T(dt,{"fade","stepback","step back"})then cd=-W(a_.CFrame.LookVector)end;if not cd then cd=am.moveWhere(1.5)end;if not cd and a_ then cd=W(a_.CFrame.LookVector)end;ag.fire("shot","shot",cd)end)end;do local kf=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)local M=ae.auto and ae.auto[db.key]if ar.AdaptPlus and M and M.locked and M.mode=="peak"and not db.manual and ae.autoActive(db.key)then local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm then local dT=dm==5 and 0 or dm==4 and-1 or dm-5;M.bin=M.bin or ar.PeakBin or 0.014;local dJ=M.hold;M.b=(M.b or 0)*0.7+dT*0.3;if math.abs(dT)>=2 then M.hold=K(M.hold+dT*M.bin*0.7,0,0.1)M.b=0 elseif math.abs(M.b)>=0.45 then M.hold=K(M.hold+M.b*M.bin*0.8,0,0.1)M.b=0 end;if M.hold~=dJ then ae.noteAdjust(db.key,dJ,M.hold,(ae.VERDICT[dm]or"?")..", re-centered")ae.autoSave()end end end;return kf(db,aZ,cZ)end;local kg={buf={},stable=nil,jitter=0,raw=0}C.api.Ping=kg;function kg.step()local a9,bI=pcall(function()return u:GetNetworkPing()end)if not a9 or type(bI)~="number"then return end;kg.raw=bI;local bc=math.max(5,math.floor((ar.PingWindow or 3)*10))kg.buf[#kg.buf+1]=bI;while#kg.buf>bc do table.remove(kg.buf,1)end;local S={}for cR,L in ipairs(kg.buf)do S[cR]=L end;table.sort(S)local kh=S[math.floor((#S+1)/2)]local ki=0;for g,L in ipairs(kg.buf)do ki=ki+math.abs(L-kh)end;kg.stable=kh;kg.jitter=ki/#kg.buf end;function kg.trim(h0)pcall(function()local kj=settings().Network;if h0 then if kg.oldLag==nil then kg.oldLag=kj.IncomingReplicationLag end;kj.IncomingReplicationLag=0 elseif kg.oldLag~=nil then kj.IncomingReplicationLag=kg.oldLag;kg.oldLag=nil end end)end;local kk=ae.pingNow;function ae.pingNow()if ar.PingStab and kg.stable then return kg.stable end;return kk()end;task.spawn(function()while C.Running do kg.step()task.wait(0.1)end end)local kl={saved=setmetatable({},{__mode="k"}),culled=setmetatable({},{__mode="k"}),removed={},low={},queue={},qh=1,qt=0,tok=0,any=false}C.api.Gfx=kl;local km={ParticleEmitter=true,Trail=true,Beam=true,Fire=true,Smoke=true,Sparkles=true,PointLight=true,SpotLight=true,SurfaceLight=true}local kn={BloomEffect=true,BlurEffect=true,ColorCorrectionEffect=true,DepthOfFieldEffect=true,SunRaysEffect=true}local ko={"GfxLow","GfxEffects","GfxTextures","GfxShadows","GfxPost","GfxHideOthers","GfxCull"}function kl.set(cB,cE,gx)local a9,du=pcall(function()return cB[cE]end)if not a9 or du==gx then return end;local kp=kl.saved[cB]if not kp then kp={}kl.saved[cB]=kp end;if kp[cE]==nil then kp[cE]=du end;pcall(function()cB[cE]=gx end)end;function kl.isChar(bb)local bJ=bb.Parent;while bJ and bJ~=workspace do if bJ:IsA("Model")and bJ:FindFirstChildOfClass("Humanoid")then return true end;bJ=bJ.Parent end;return false end;function kl.remove(bb)kl.removed[#kl.removed+1]={inst=bb,parent=bb.Parent}bb.Parent=nil end;function kl.apply(bb)local kq=bb.ClassName;if ar.GfxEffects then if km[kq]then kl.set(bb,"Enabled",false)return elseif kq=="Explosion"then kl.set(bb,"Visible",false)return end end;if ar.GfxPost then if kn[kq]and bb.Name~="JHubBlur"then kl.set(bb,"Enabled",false)return elseif kq=="Atmosphere"then kl.set(bb,"Density",0)kl.set(bb,"Haze",0)kl.set(bb,"Glare",0)return end end;if bb:IsA("BasePart")then if bb.Name=="ProxyCharacter"or ad.parts[bb]then return end;if ar.GfxShadows then kl.set(bb,"CastShadow",false)end;if ar.GfxTextures and not kl.isChar(bb)then kl.set(bb,"Material",Enum.Material.SmoothPlastic)kl.set(bb,"Reflectance",0)if kq=="MeshPart"then kl.set(bb,"TextureID","")end end elseif ar.GfxTextures then if kq=="Decal"or kq=="Texture"then if not kl.isChar(bb)and not(bb.Parent and ad.parts[bb.Parent])then kl.set(bb,"Transparency",1)end elseif kq=="SurfaceAppearance"and not kl.isChar(bb)then kl.remove(bb)end end end;function kl.sweep()local kr=kl.tok;task.spawn(function()local bc=0;for g,cU in ipairs({o,workspace})do for g,bb in ipairs(cU:GetDescendants())do if kr~=kl.tok or not C.Running then return end;pcall(kl.apply,bb)bc=bc+1;if bc%400==0 then task.wait()end end end end)end;local function ks(bb)if kl.any then kl.qt=kl.qt+1;kl.queue[kl.qt]=bb end end;E(workspace.DescendantAdded,ks)E(o.DescendantAdded,ks)E(k.Heartbeat,function()local dZ=kl.queue;local bc=0;while kl.qh<=kl.qt and bc<120 do local bb=dZ[kl.qh]dZ[kl.qh]=nil;kl.qh=kl.qh+1;if bb and bb.Parent then pcall(kl.apply,bb)end;bc=bc+1 end end)function kl.restoreProps()for cB,kp in pairs(kl.saved)do for cE,aB in pairs(kp)do pcall(function()cB[cE]=aB end)end end;kl.saved=setmetatable({},{__mode="k"})for g,aw in ipairs(kl.removed)do pcall(function()aw.inst.Parent=aw.parent end)end;kl.removed={}end;function kl.lowOn()local gj=kl.low;pcall(function()local aw=settings().Rendering;if gj.quality==nil then gj.quality=aw.QualityLevel end;aw.QualityLevel=Enum.QualityLevel.Level01 end)pcall(function()local aw=settings().Rendering;if gj.mesh==nil then gj.mesh=aw.MeshPartDetailLevel end;aw.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level04 end)pcall(function()local kt=UserSettings():GetService("UserGameSettings")if gj.saved==nil then gj.saved=kt.SavedQualityLevel end;kt.SavedQualityLevel=Enum.SavedQualitySetting.QualityLevel1 end)pcall(function()if sethiddenproperty and gethiddenproperty then if gj.tech==nil then gj.tech=gethiddenproperty(o,"Technology")end;sethiddenproperty(o,"Technology",Enum.Technology.Compatibility)end end)kl.set(o,"GlobalShadows",false)local S=workspace:FindFirstChildOfClass("Terrain")if S then kl.set(S,"Decoration",false)kl.set(S,"WaterWaveSize",0)kl.set(S,"WaterWaveSpeed",0)kl.set(S,"WaterReflectance",0)end end;function kl.lowOff()local gj=kl.low;pcall(function()if gj.quality~=nil then settings().Rendering.QualityLevel=gj.quality end;if gj.mesh~=nil then settings().Rendering.MeshPartDetailLevel=gj.mesh end end)pcall(function()if gj.saved~=nil then UserSettings():GetService("UserGameSettings").SavedQualityLevel=gj.saved end end)pcall(function()if gj.tech~=nil and sethiddenproperty then sethiddenproperty(o,"Technology",gj.tech)end end)kl.low={}end;function kl.restoreCull()for bb in pairs(kl.culled)do pcall(function()bb.LocalTransparencyModifier=0 end)end;kl.culled=setmetatable({},{__mode="k"})kl.parts=nil end;function kl.cullStep()if not ar.GfxCull then return end;local D=workspace.CurrentCamera;if not D then return end;if not kl.parts or tick()-(kl.partsT or 0)>15 then kl.partsT=tick()local b4,bc={},0;for g,bb in ipairs(workspace:GetDescendants())do if bb:IsA("BasePart")and bb.Name~="ProxyCharacter"and not ad.parts[bb]and bb.Size.Magnitude<40 and not kl.isChar(bb)then b4[#b4+1]=bb end;bc=bc+1;if bc%600==0 then task.wait()end end;kl.parts=b4;kl.cursor=1 end;local b4=kl.parts;if not b4 then return end;local bx=D.CFrame.Position;local ku=ar.GfxCullDist;local hn=#b4;local kv=kl.cursor or 1;local dw=math.min(hn,kv+1200)for cR=kv,dw do local bb=b4[cR]if bb and bb.Parent then local kw=(bb.Position-bx).Magnitude>ku;if kw and not kl.culled[bb]then kl.culled[bb]=true;bb.LocalTransparencyModifier=1 elseif not kw and kl.culled[bb]then kl.culled[bb]=nil;bb.LocalTransparencyModifier=0 end end end;kl.cursor=dw>=hn and 1 or dw+1 end;function kl.hideOthersStep()if not ar.GfxHideOthers then return end;for g,bR in ipairs(j:GetPlayers())do if bR~=u and bR.Character then for g,M in ipairs(bR.Character:GetChildren())do if M:IsA("Accessory")then local aR=M:FindFirstChild("Handle")if aR then kl.set(aR,"LocalTransparencyModifier",1)end end end end end end;function kl.applyCap()local d5=ar.GfxFpsCap;if d5 and d5>0 then if kl.oldCap==nil then local a9,L=pcall(function()return getfpscap and getfpscap()or 60 end)kl.oldCap=a9 and tonumber(L)or 60 end;if setfpscap then pcall(setfpscap,d5)end elseif kl.oldCap~=nil then if setfpscap then pcall(setfpscap,kl.oldCap)end;kl.oldCap=nil end end;function kl.onChange()kl.tok=kl.tok+1;kl.restoreProps()if ar.GfxLow then kl.lowOn()else kl.lowOff()end;if ar.GfxShadows then kl.set(o,"GlobalShadows",false)end;kl.any=(ar.GfxEffects or ar.GfxTextures or ar.GfxShadows or ar.GfxPost)and true or false;if kl.any then kl.sweep()end;if not ar.GfxCull then kl.restoreCull()end;kl.hideOthersStep()kl.applyCap()end;function kl.boost(h0)for g,a1 in ipairs(ko)do aa.set(a1,h0,false)end;kl.onChange()if h0 then pcall(collectgarbage,"collect")end end;function kl.restoreAll()kl.tok=kl.tok+1;kl.restoreProps()kl.lowOff()kl.restoreCull()if kl.oldCap~=nil and setfpscap then pcall(setfpscap,kl.oldCap)end end;local kx=C.Unload;function C.Unload()pcall(kl.restoreAll)pcall(kg.trim,false)kx()end;task.spawn(function()local ky=tick()while C.Running do pcall(kl.cullStep)pcall(kl.hideOthersStep)if ar.GfxBoost and tick()-ky>30 then ky=tick()pcall(collectgarbage,"step",200)end;task.wait(0.4)end end)local kz=aa.Page("Graphics","G")local kA=aa.Card(kz,"FPS booster")aa.Toggle(kA,"FPS booster","GfxBoost",function(L)kl.boost(L)end)aa.Note(kA,"Turns on every option below at once and keeps cleaning up anything new that appears. Turn it off to put everything back.")local kB=aa.Stat(kA,"FPS")aa.Slider(kA,"FPS cap (0 = leave alone)","GfxFpsCap",0,360,5,0,nil,function()kl.applyCap()end)local kC=aa.Card(kz,"Lower graphics")local function kD(iO,av,cr)aa.Toggle(iO,av,cr,function()kl.onChange()end)end;kD(kC,"Lowest graphics","GfxLow")kD(kC,"Remove textures and fancy materials","GfxTextures")kD(kC,"Remove particles, trails and lights","GfxEffects")kD(kC,"Turn off shadows","GfxShadows")kD(kC,"Turn off blur, bloom, fog and haze","GfxPost")kD(kC,"Hide other players' accessories","GfxHideOthers")local kE=aa.Card(kz,"Map cleanup")kD(kE,"Hide small map parts far away","GfxCull")aa.Slider(kE,"Hide parts farther than","GfxCullDist",60,600,10,0," studs")aa.Note(kE,"The court, big walls, players and the ball are never hidden.")aa.Button(kE,"Turn everything off",function()for g,a1 in ipairs(ko)do aa.set(a1,false,false)end;aa.set("GfxBoost",false,false)aa.set("GfxFpsCap",0,false)kl.onChange()end)local kF=aa.Card(kz,"Ping stabilizer")aa.Toggle(kF,"Ping stabilizer","PingStab",function(L)kg.trim(L)end)aa.Note(kF,"Your real ping comes from your connection and cannot be lowered here. This smooths out ping spikes so Auto Green and Perfect green time off a steady number, and it turns off the client's own extra network delay.")aa.Slider(kF,"Smoothing window","PingWindow",1,6,1,0,"s")local kG=aa.Stat(kF,"Ping (now)")local kH=aa.Stat(kF,"Ping (stable)")local kI=aa.Stat(kF,"Jitter")task.spawn(function()while C.Running do if hv.Visible and aa.current and aa.current.name=="Graphics"then pcall(function()kB.Text=string.format("%d",math.floor(C.FPS+0.5))kG.Text=string.format("%d ms",math.floor(kg.raw*1000+0.5))kH.Text=kg.stable and string.format("%d ms",math.floor(kg.stable*1000+0.5))or"-"kI.Text=string.format("%.1f ms",kg.jitter*1000)end)end;task.wait(0.5)end end)kg.trim(ar.PingStab)kl.onChange()end;do am.GATHER_MOVES={"euro","hop","gather"}local kJ={"stepback","step back"}local kK={"shot","shoot","jumper","layup","dunk","fade","floater","hook"}function ag.cancel()ag.token=ag.token+1;ag.input=nil;if ag.attrOn then ag.attrOn=false;local H=a4()if H then H:SetAttribute("SpeedBoost",0)H:SetAttribute("SpeedBoostTime",0)H:SetAttribute("AccelerationBoost",0)end end end;function ag.gatherOk(H)local hW=string.lower(tostring(H:GetAttribute("GatherType")or""))local dM=string.lower(tostring(H:GetAttribute("LastDribblePackage")or""))if string.find(hW,"pump",1,true)then return false end;if T(hW,kJ)or T(dM,kJ)then return false end;return true end;function am.onDribble(c4)ah.lastDribble=tick()local c5=a4()local c7=c5 and c5:GetAttribute("LastDribblePackage")local cd=am.moveWhere(1.5)if not cd and typeof(c4[3])=="Vector3"and W(c4[3]).Magnitude>0.1 then cd=W(c4[3])end;task.spawn(function()local c9=tick()while C.Running and tick()-c9<0.1 do local ca=a4()if ca and ca:GetAttribute("LastDribblePackage")~=c7 then break end;k.Heartbeat:Wait()end;if not C.Running then return end;local H=a4()local cc=H and H:GetAttribute("LastDribblePackage")local bk=type(cc)=="string"and string.lower(cc)or""if T(bk,kK)then return end;if T(bk,kJ)then local a_=am.body()local fk=a_ and-W(a_.CFrame.LookVector)or cd;ag.fire("dribble","step back "..bk,fk)return end;cd=am.moveWhere(1.5)or cd;if T(bk,am.GATHER_MOVES)then ag.fire("gather","gather move "..bk,cd)else ag.fire("dribble","dribble move "..(bk~=""and bk or tostring(c4[1])),cd)end end)end;local kL=ae.onShootCall;function ae.onShootCall(c4)local bb=c4[1]if type(bb)=="table"then if bb.Shoot==true and(ar.DribbleGlide or ar.GatherGlide)then pcall(ag.cancel)end;if bb.Shoot==false then am.shotUpT=tick()end end;return kL(c4)end;function am.watchShot(cf)task.defer(function()local aR,aw=a7(),am.body()local ke;if aR and aw then local kM,ey=pcall(am.intent,aR,aw)if kM and ey and ey.Magnitude>0.1 then ke=W(ey)end end;local c9=tick()while C.Running and tick()-c9<0.35 and ae.meterT<cf-0.05 do k.Heartbeat:Wait()end;if not C.Running or ae.meterT<cf-0.05 then return end;local H=a4()local dt=string.lower(tostring(H and H:GetAttribute("BaseAnimation")or""))local a_=am.body()local cd=ke;if not cd and a_ and T(dt,{"fade","stepback","step back"})then cd=-W(a_.CFrame.LookVector)end;if not cd then cd=am.moveWhere(1.5)end;if not cd and a_ then cd=W(a_.CFrame.LookVector)end;if ar.ShotGlideWhen~="During shot"then local kN=tick()while C.Running and tick()-kN<1.6 and ae.releasedT<cf and(am.shotUpT or 0)<cf do k.Heartbeat:Wait()end end;ag.lastStart.shot=0;ag.fire("shot","shot",cd)end)end;ab.KNOWN_CODES={"100M","100KLIKES","500KMEMBERS","100KCCUPLS","RELEASE","SORRYFORBUGS"}function ab.gameCodes()local bp={}if type(getloadedmodules)~="function"then return bp end;local kO,hh=pcall(getloadedmodules)if not kO or type(hh)~="table"then return bp end;local function eB(S,gr)if gr>3 then return end;for a1,L in pairs(S)do if type(a1)=="string"and#a1>=3 and#a1<=24 and string.find(a1,"^[%u%d_]+$")and string.find(a1,"%u")then bp[a1]=true end;if type(L)=="table"then pcall(eB,L,gr+1)end end end;for g,bJ in ipairs(hh)do local h7,au=pcall(al.pathOf,bJ)if h7 and string.find(string.lower(au),"code",1,true)then local hg,aZ=pcall(require,bJ)if hg and type(aZ)=="table"then pcall(eB,aZ,0)end end end;return bp end;function ab.redeemViaRemotes(b4)local bh={}for g,bb in ipairs(s:GetDescendants())do if(bb:IsA("RemoteEvent")or bb:IsA("RemoteFunction"))and T(string.lower(bb.Name),{"code","redeem","promo","coupon"})then bh[#bh+1]=bb end end;if#bh==0 then return false end;for g,bf in ipairs(b4)do for g,bi in ipairs(bh)do if bi:IsA("RemoteFunction")then task.spawn(function()local a9,aZ=pcall(function()return bi:InvokeServer(bf)end)I("Code "..bf.." via "..bi.Name..": "..tostring(a9 and aZ or"error"))end)else pcall(function()bi:FireServer(bf)end)pcall(function()bi:FireServer({Code=bf})end)I("Code "..bf.." sent via "..bi.Name)end end;task.wait(1.2)end;return true end;function ab.redeemAll()local bE,b4={},{}local function bF(H)H=O(H)if H~=""and not bE[H]then bE[H]=true;b4[#b4+1]=H end end;for g,H in ipairs(Q(ar.Codes))do bF(H)end;for g,H in ipairs(ab.KNOWN_CODES)do bF(H)end;local kP=ab.gameCodes()local ew=0;for H in pairs(kP)do if not bE[H]then ew=ew+1 end;bF(H)end;ao("Codes",string.format("Trying %d codes (%d found inside the game).",#b4,ew),3)local bj=ab.redeemViaGui(b4)if not bj and ar.CodeRemotes then bj=ab.redeemViaRemotes(b4)end;if bj then ao("Codes","Finished. Check your coins and rewards.",4)else ao("Codes","Open the Store, then the Codes box, once. Then press Redeem all codes again.",5)end end;local kQ={"stun","stagger","knock","dizzy","daze","ragdoll","flinch","faint","hurt"}local Bot={hoops={},hoopsT=0,track=setmetatable({},{__mode="k"}),cmd=nil,cmdT=0,mul=1,face=nil,faceT=0,shotSeen=setmetatable({},{__mode="k"}),btnCache={},sprinting=false,shotT=0,moveT=0,blockT=0,chaseUntil=0,status="Off",spot=nil,spotT=0,ballT=0,jumpT=0}C.api.Bot=Bot;function Bot.noStunStep()if not ar.NoStun then return end;local H,aR=a4(),a7()if H then if Bot.stunChar~=H then Bot.stunChar=H;E(H.AttributeChanged,function(bk)local gj=string.lower(bk)if ar.NoStun and string.find(gj,"stun",1,true)and H:GetAttribute(bk)then local M=ah.animator;local a9,b4=pcall(function()return M and M:GetPlayingAnimationTracks()or{}end)if a9 then for g,d7 in ipairs(b4)do local aV=ah.idOf(d7)if aV~=""and not d7.Looped and not ah.has("StunIds",aV)then ar.StunIds=O((ar.StunIds or"").." "..aV)aI()end end end end end)end;for a1,L in pairs(H:GetAttributes())do local gj=string.lower(a1)if string.find(gj,"stun",1,true)or string.find(gj,"ragdoll",1,true)or string.find(gj,"stagger",1,true)then if L==true then H:SetAttribute(a1,false)elseif type(L)=="number"and L~=0 then H:SetAttribute(a1,0)end end end end;if aR then pcall(function()if aR.PlatformStand then aR.PlatformStand=false end;local d2=aR:GetState()if d2==Enum.HumanoidStateType.Ragdoll or d2==Enum.HumanoidStateType.FallingDown then aR:ChangeState(Enum.HumanoidStateType.GettingUp)end end)end;local M=ah.animator;if M then local a9,b4=pcall(function()return M:GetPlayingAnimationTracks()end)if a9 then for g,d7 in ipairs(b4)do if ah.has("StunIds",ah.idOf(d7))or T(ah.name(d7),kQ)then pcall(function()d7:Stop(0)end)end end end end end;function Bot.charOf(bR)return bR.Character or workspace:FindFirstChild("Characters")and workspace.Characters:FindFirstChild(bR.Name)end;function Bot.hasBall(H)local bK=H:FindFirstChild("Attributes")local bL=bK and bK:FindFirstChild("Basketball")return bL and bL.Value~=nil and true or false end;local function kR(cU,bZ)local L=cU.AssemblyLinearVelocity;local kS=Vector3.new(L.X,0,L.Z)local d7=Bot.track[cU]if not d7 then Bot.track[cU]={p=cU.Position,t=bZ,v=kS}else d7.v=d7.v*0.6+kS*0.4;d7.p,d7.t=cU.Position,bZ end end;function Bot.sample()local bZ=tick()for g,bR in ipairs(j:GetPlayers())do if bR~=u then local H=Bot.charOf(bR)local cU=H and(H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart)if cU then kR(cU,bZ)end end end;local kT=a4()local kU=workspace:FindFirstChild("Characters")if kU then for g,H in ipairs(kU:GetChildren())do if H:IsA("Model")and H~=kT and H.Name~="InvisCharacter"then local cU=H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart;if cU then kR(cU,bZ)end end end end end;local function kV(kA,kC)if not kA or not kC then return false end;local kW,kX=kA:GetAttribute("HomeTeam"),kC:GetAttribute("HomeTeam")if kW==nil or kX==nil then return false end;return kW==kX end;function Bot.others()local R={}local bE={}local kT=a4()for g,bR in ipairs(j:GetPlayers())do if bR~=u then local H=Bot.charOf(bR)local cU=H and(H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart)local kY=H and H:FindFirstChildOfClass("Humanoid")if cU and kY and kY.Health>0 then bE[H]=true;local d7=Bot.track[cU]R[#R+1]={pl=bR,c=H,root=cU,pos=cU.Position,vel=d7 and d7.v or Vector3.new(0,0,0),mate=ar.APTeam=="By team"and kV(kT,H),ball=Bot.hasBall(H),shooting=H:GetAttribute("Action")=="Shooting"}end end end;local kU=workspace:FindFirstChild("Characters")if kU then for g,H in ipairs(kU:GetChildren())do if H:IsA("Model")and H~=kT and not bE[H]and H.Name~="InvisCharacter"then local cU=H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart;local kY=H:FindFirstChildOfClass("Humanoid")if cU and kY and kY.Health>0 then local d7=Bot.track[cU]R[#R+1]={pl={Name=H.Name},c=H,root=cU,pos=cU.Position,vel=d7 and d7.v or Vector3.new(0,0,0),mate=ar.APTeam=="By team"and kV(kT,H),ball=Bot.hasBall(H),shooting=H:GetAttribute("Action")=="Shooting"}end end end end;return R end;function Bot.scanHoops()local b4={}local function bF(bx)for g,aR in ipairs(b4)do if(aR-bx).Magnitude<14 then return end end;b4[#b4+1]=bx end;for dG,bC,fV in string.gmatch(ar.HoopMarks or"","(%-?[%d%.]+),(%-?[%d%.]+),(%-?[%d%.]+)")do bF(Vector3.new(tonumber(dG),tonumber(bC),tonumber(fV)))end;local bc=0;for g,bb in ipairs(workspace:GetDescendants())do bc=bc+1;if bc%500==0 then task.wait()end;if bb:IsA("BasePart")or bb:IsA("Model")then local gi=string.lower(bb.Name)if not string.find(gi,"ball",1,true)and(gi=="rim"or gi=="hoop"or gi=="goal"or gi=="basket"or string.find(gi,"hoop",1,true)or string.find(gi,"rim",1,true)==1)then local a9,bx=pcall(function()return bb:IsA("Model")and bb:GetPivot().Position or bb.Position end)if a9 then bF(bx)end end end end;Bot.hoops,Bot.hoopsT=b4,tick()I("Hoops found: "..#b4)end;function Bot.nearestHoop(bx,kw)local bO,bP;for g,aR in ipairs(Bot.hoops)do local bb=W(aR-bx).Magnitude;if not bP or kw and bb>bP or not kw and bb<bP then bO,bP=aR,bb end end;return bO end;function Bot.attackHoop(bx)local b3=ar.APHoop;if b3=="Farthest"then return Bot.nearestHoop(bx,true)end;return Bot.nearestHoop(bx,false)end;function Bot.move(cd,kZ)if cd.Magnitude>1 then cd=cd.Unit end;Bot.cmd,Bot.cmdT,Bot.mul=cd,tick(),kZ or 1;am.override,am.overrideT=cd,tick()local k_=cd*(kZ or 1)local a9=pcall(am.send,k_)Bot.dbg=Bot.dbg or{}Bot.dbg.sentVia,Bot.dbg.sentVec,Bot.dbg.sentOk,Bot.dbg.sentAt="Mover.send",k_,a9,tick()local l0=a7()Bot.dbg.humState=l0 and l0:GetState().Name or"no humanoid"end;function Bot.stopMove()Bot.cmd=nil;am.override=nil;local a9=pcall(am.send,Vector3.new())Bot.dbg=Bot.dbg or{}Bot.dbg.sentVia,Bot.dbg.sentVec,Bot.dbg.sentOk,Bot.dbg.sentAt="Mover.send(stop)",Vector3.new(),a9,tick()end;function Bot.faceAt(bx)local aw=am.body()if not aw then return end;local bb=W(bx-aw.Position)if bb.Magnitude>0.5 then Bot.face,Bot.faceT=bb.Unit,tick()end end;function Bot.stamina()local H=a4()local L=H and H:GetAttribute("Stamina")if type(L)~="number"then return nil end;return L<=1 and L*100 or L end;function Bot.setSprint(h0)if h0 then local d2=Bot.stamina()if d2 and d2<=ar.APStaminaMin then h0=false end end;if h0~=Bot.sprinting then Bot.sprinting=h0;pcall(ac.action,"Sprint",h0)end end;function Bot.findBtn(U)local h=table.concat(U,"|")local H=Bot.btnCache[h]if H and tick()-H.t<2 and(not H.obj or H.obj.Parent)then return H.obj end;local b9=u:FindFirstChild("PlayerGui")local bp;if b9 then for g,bb in ipairs(b9:GetDescendants())do if bb:IsA("GuiButton")and not bb:IsDescendantOf(aS)and a2(bb)then local bc=string.lower(bb.Name.." "..(bb:IsA("TextButton")and bb.Text or""))if T(bc,U)then bp=bb;break end end end end;Bot.btnCache[h]={obj=bp,t=tick()}return bp end;function Bot.press(h,dR,U)task.spawn(function()ac.sendKey(h,true)local bd=U and Bot.findBtn(U)if bd then ac.fireGui(bd,true,true)end;task.wait(dR or 0.1)ac.sendKey(h,false)if bd then ac.fireGui(bd,false,true)end end)end;function Bot.userActive()if not ar.APPause then return false end;local bb=am.gameDir;return bb~=nil and tick()-(am.gameDirT or 0)<0.4 and W(bb).Magnitude>0.35 end;if not ar.WalkAnimId or ar.WalkAnimId==""then ar.WalkAnimId="rbxassetid://135438934392621"aI()end;if not ar.GuardAnimId or ar.GuardAnimId==""then ar.GuardAnimId="rbxassetid://16597565910"aI()end;local l1,l2;E(k.Heartbeat,function()local l3=not ar.WalkAnimId or ar.WalkAnimId==""local l4=not ar.GuardAnimId or ar.GuardAnimId==""if not l3 and not l4 then return end;if Bot.cmd then return end;local aR,aw=a7(),am.body()if not aR or not aw then return end;local bZ=tick()local l5,l6=Vector3.new(),false;if l1 and l2 and bZ-l2>0 then l5=W(aw.Position-l1)l6=l5.Magnitude/(bZ-l2)>3 end;l1,l2=aw.Position,bZ;if not l6 then return end;local l7=W(aw.CFrame.LookVector)local l8=false;if l7.Magnitude>0.1 and l5.Magnitude>0.1 then l8=l7.Unit:Dot(l5.Unit)<0.3 end;for g,d7 in ipairs(aR:GetPlayingAnimationTracks())do local aV=d7.Animation and d7.Animation.AnimationId;if d7.Priority==Enum.AnimationPriority.Movement and d7.Looped and aV and aV~=""then if l8 and l4 then ar.GuardAnimId=aV;aI()ao("JHub","Learned your real defensive slide animation.",3)elseif not l8 and l3 then ar.WalkAnimId=aV;aI()ao("JHub","Learned your real walk animation.",3)end;break end end end)local l9,la;local lb={}local function lc(aV)if not aV or aV==""then return nil end;local aR=a7()if not aR then return nil end;local bo=lb[aV]if bo and bo.hum==aR then return bo.track end;local cv=aR:FindFirstChildOfClass("Animator")if not cv then return nil end;local dt=Instance.new("Animation")dt.AnimationId=aV;local a9,cq=pcall(function()return cv:LoadAnimation(dt)end)if not a9 or not cq then return nil end;cq.Priority=Enum.AnimationPriority.Movement;cq.Looped=true;lb[aV]={track=cq,hum=aR}return cq end;E(k.Stepped,function(g,ec)if ec<=0 or ec>0.25 then return end;local aw=am.body()if not aw then return end;local bZ=tick()local l6=Bot.cmd and bZ-Bot.cmdT<0.35 and Bot.cmd.Magnitude>0.05;if l6 then aw.CFrame=aw.CFrame+Bot.cmd*ai.gameWS*Bot.mul*ec;am.sync(aw)local aV=ar.WalkAnimId;if aV~=l9 then if la then pcall(function()la:Stop(0.1)end)end;la=lc(aV)l9=aV end;if la then la.Speed=math.clamp(Bot.mul or 1,0.6,1.8)if not la.IsPlaying then la:Play(0.15)end end elseif la and la.IsPlaying then la:Stop(0.15)end;if Bot.face and bZ-Bot.faceT<0.35 then local bI=aw.Position;aw.CFrame=CFrame.new(bI,bI+Bot.face)end end)function Bot.pickTarget(ld,le,lf)local b3=lf or ar.AGTarget;local function lg(_)local bb=W(_.pos-le).Magnitude;if b3=="Ball handler"then return _.ball and bb-1000 or bb end;if b3=="Closest to hoop"then local aR=Bot.nearestHoop(_.pos)return aR and W(_.pos-aR).Magnitude or bb end;return bb end;local bO,bP;for g,_ in ipairs(ld)do if not _.mate then local cD=lg(_)if not bP or cD<bP then bO,bP=_,cD end end end;local bZ=tick()if Bot.lockedChar then local lh;for g,_ in ipairs(ld)do if _.c==Bot.lockedChar and not _.mate then lh=_;break end end;if lh then if bO and bO.c~=lh.c and bP<lg(lh)-2 then if Bot.lockBetterChar~=bO.c then Bot.lockBetterChar,Bot.lockBetterSince=bO.c,bZ end;if bZ-Bot.lockBetterSince>=0.5 then Bot.lockedChar,Bot.lockBetterChar,Bot.lockBetterSince=bO.c,nil,nil;return bO end else Bot.lockBetterChar,Bot.lockBetterSince=nil,nil end;return lh end end;Bot.lockedChar,Bot.lockBetterChar,Bot.lockBetterSince=bO and bO.c or nil,nil,nil;return bO end;function Bot.blockStep(ld,le)if not ar.AB then return end;local bZ=tick()for g,_ in ipairs(ld)do if not _.mate then local li=Bot.shotSeen[_.c]Bot.shotSeen[_.c]=_.shooting;if _.shooting and not li and bZ-Bot.blockT>0.9 then local bW=W(_.pos-le).Magnitude;if bW<=ar.ABRange and math.random(100)<=ar.ABChance then Bot.blockT=bZ;task.delay(ar.ABDelay,function()if C.Running then Bot.doJump()end end)end end end end end;local lj=RaycastParams.new()lj.FilterType=Enum.RaycastFilterType.Exclude;function Bot.predictBall(N)local a3=workspace.Gravity;local bI,L=N.Position,N.AssemblyLinearVelocity;lj.FilterDescendantsInstances={N,a4()}local em=workspace:Raycast(bI,Vector3.new(0,-300,0),lj)local lk=em and em.Position.Y or bI.Y-3;local ll=lk+4.5;local S=0;if bI.Y>ll then local lm=L.Y*L.Y+2*a3*(bI.Y-ll)S=(L.Y+math.sqrt(lm))/a3 else S=0.2 end;S=K(S,0,4)return Vector3.new(bI.X+L.X*S,lk,bI.Z+L.Z*S),S end;function Bot.marker(bx)if not ar.ARMarker or not bx then if Bot.mk then Bot.mk.Parent=nil end;return end;if not Bot.mk then local bI=Instance.new("Part")bI.Name="JHReboundMarker"bI.Anchored,bI.CanCollide,bI.CanQuery,bI.CanTouch=true,false,false,false;bI.Shape=Enum.PartType.Ball;bI.Size=Vector3.new(2,2,2)bI.Material=Enum.Material.Neon;bI.Color=Color3.fromRGB(255,221,64)bI.Transparency=0.35;Bot.mk=bI end;Bot.mk.Position=bx+Vector3.new(0,1,0)Bot.mk.Parent=workspace end;function Bot.reboundStep(le,aw)if not aj.ballLoose()then Bot.marker(nil)return false end;local N=aj.findBall()if not N or not N.Parent then return false end;if W(N.Position-le).Magnitude>ar.ARRange then return false end;local ln,S=Bot.predictBall(N)Bot.marker(ln)local dq=W(ln-le)local bb=dq.Magnitude;if bb>0.8 then Bot.move(dq.Unit,ar.ARSpeed)Bot.setSprint(bb>8)else Bot.stopMove()end;local bP=W(N.Position-le).Magnitude;local bZ=tick()if ar.ARJump and bP<7 and N.Position.Y>le.Y+1 and bZ-Bot.jumpT>0.8 then Bot.jumpT=bZ;Bot.press("Space",0.15,{"jump"})end;if ar.ARMagnet and bP<=ar.ARMagRange and bZ-Bot.ballT>0.4 then Bot.ballT=bZ;pcall(aj.getBall,true)end;Bot.status=string.format("Rebound (%.1fs)",S)return true end;function Bot.shoot(lo)local bZ=tick()if bZ-Bot.shotT<ar.APShotDelay or ae.busy then return end;Bot.shotT=bZ;if lo then Bot.faceAt(lo)end;Bot.stopMove()if ar.ShotStyle~="Tap"then Bot.oldStyle=Bot.oldStyle or ar.ShotStyle;ar.ShotStyle="Tap"end;ac.action("Shoot",true)task.delay(0.08,function()ac.action("Shoot",false)end)Bot.status="Shooting"end;function Bot.nearestDefender(le,ld)local lp,lq=math.huge,nil;for g,_ in ipairs(ld)do if not _.mate then local bb=W(_.pos-le).Magnitude;if bb<lp then lp,lq=bb,_ end end end;return lp,lq end;function Bot.steer(le,lo,ld)local lr=W(lo-le)local ls=lr.Unit;local fY=Vector3.new(-lr.Unit.Z,0,lr.Unit.X)for g,_ in ipairs(ld)do if not _.mate then local dT=W(_.pos-le)local bb=dT.Magnitude;if bb<9 and dT:Dot(lr)>0 then local P=dT:Dot(fY)>0 and-1 or 1;ls=ls+fY*P*(1-bb/9)*1.3 end end end;return ls.Unit end;function Bot.offense(le,ld)local lo=Bot.attackHoop(le)if not lo then Bot.status="No hoop found"return false end;local H=a4()if H and H:GetAttribute("Action")=="Shooting"then Bot.stopMove()return true end;local bW=W(lo-le).Magnitude;local lp=Bot.nearestDefender(le,ld)local jf=ar.APBuild;local bZ=tick()if jf=="Big"and ar.APPostScore then if bW>ar.APPostRange then local lt=lp<3.5;Bot.move(W(lo-le).Unit*(lt and 0.6 or 1),ar.APSpeed*(lt and 0.8 or 1))Bot.faceAt(lo)Bot.setSprint(false)Bot.status="Posting up"else Bot.shoot(lo)end;return true end;if bW<=9 and ar.APLayups then Bot.shoot(lo)return true end;local b5=lp>=ar.APOpenDist;if b5 and bW<=ar.APRange and(ar.APThree or bW<=22)and bW>9 then Bot.shoot(lo)return true end;if jf=="Shooter"and not b5 then Bot.status="Looking for an open look"end;if ar.APDrive or jf=="Small"or jf=="Wing"then local cd=Bot.steer(le,lo,ld)Bot.move(cd,ar.APSpeed)Bot.setSprint(ar.APSprint and bW>12)Bot.status="Driving"if ar.APMoves and lp<7 and bZ-Bot.moveT>1.4+math.random()*1.2 then Bot.moveT=bZ;local bG=Q(ar.DribbleKeys)if#bG>0 then Bot.press(bG[math.random(#bG)],0.06)end end else Bot.stopMove()end;return true end;function Bot.offBall(le,ld)local lo=Bot.attackHoop(le)if not lo then return false end;local bZ=tick()if ar.APBuild=="Big"and ar.APPostScore then local lu=W(le-lo)if lu.Magnitude<0.1 then lu=Vector3.new(0,0,1)end;local fj=lo+lu.Unit*ar.APPostRange;local dq=W(fj-le)if dq.Magnitude>1.5 then Bot.move(dq.Unit,ar.APSpeed)else Bot.stopMove()end;Bot.faceAt(lo)Bot.status="Sealing in the post"return true end;if not Bot.spotUp or bZ-Bot.spotUpT>1.2 then local bO,d6;for cR=0,11 do local M=cR*math.pi/6;local bI=lo+Vector3.new(math.cos(M),0,math.sin(M))*ar.APSpot;local cD=0;local ch=math.huge;for g,_ in ipairs(ld)do if not _.mate then ch=math.min(ch,W(_.pos-bI).Magnitude)end end;cD=math.min(ch,14)-W(bI-le).Magnitude*0.15;if not d6 or cD>d6 then bO,d6=bI,cD end end;Bot.spotUp,Bot.spotUpT=bO,bZ end;local dq=W(Bot.spotUp-le)if dq.Magnitude>1.5 then Bot.move(dq.Unit,ar.APSpeed)else Bot.stopMove()end;Bot.faceAt(lo)Bot.status="Spacing the floor"return true end;function Bot.play(le,ld,lv)if lv then return Bot.offense(le,ld)end;local lw;for g,_ in ipairs(ld)do if _.ball then lw=_ end end;if ar.APRebound and aj.ballLoose()and Bot.reboundStep(le)then return true end;if lw then if lw.mate then return Bot.offBall(le,ld)end;if ar.APDefend then return Bot.guardStep(le,ld,"Ball handler")end;return false end;return Bot.offBall(le,ld)end;function Bot.setAP(h0)ar.AP=h0;if h0 then if not ar.AutoGreen then aa.set("AutoGreen",true)end;if Bot.sampleHoops~=true then Bot.sampleHoops=true;task.spawn(Bot.scanHoops)end;ao("Auto play","Bot is playing. Touch the stick to take over.",3)else Bot.stopMove()Bot.setSprint(false)Bot.marker(nil)if Bot.oldStyle then ar.ShotStyle,Bot.oldStyle=Bot.oldStyle,nil end;Bot.status="Off"end;if Bot.apLabel then Bot.apLabel.Text=h0 and"Auto play: ON (tap to stop)"or"Auto play: OFF (tap to start)"end end;function Bot.think()Bot.sample()local aw,aR=am.body(),a7()if not aw or not aR or aR.Health<=0 then Bot.stopMove()return end;local f5=ar.AP or ar.AG or ar.AR or ar.AB;if not f5 then return end;if#Bot.hoops==0 and tick()-Bot.hoopsT>10 and not Bot.scanning then Bot.scanning=true;task.spawn(function()Bot.scanHoops()Bot.scanning=false end)end;if Bot.userActive()then Bot.stopMove()Bot.setSprint(false)Bot.status="You are driving"return end;local le=aw.Position;local ld=Bot.others()local lv=aj.hasBall()pcall(Bot.blockStep,ld,le)local bZ=tick()local lx=false;if ar.AP then lx=Bot.play(le,ld,lv)else if ar.AR and not lv then lx=Bot.reboundStep(le)end;local ly=ar.AG and not lv;if ly and ar.AGHoldToUse then local kE=a4()ly=kE and kE:GetAttribute("HoldingG")==true end;if not lx and ly then lx=Bot.guardStep(le,ld)end end;if not lx then Bot.stopMove()Bot.setSprint(false)if not ar.AP then Bot.status=ar.AG and ar.AGHoldToUse and not lv and"Hold Guard to drive"or"Waiting"end end end;task.spawn(function()while C.Running do pcall(Bot.think)pcall(Bot.noStunStep)task.wait(0.05)end end)pcall(function()local lz=game:GetService("VirtualUser")E(u.Idled,function()if ar.AP and ar.APAntiAfk then pcall(function()lz:CaptureController()lz:ClickButton2(Vector2.new())end)end end)end)local lA=C.Unload;function C.Unload()am.override=nil;Bot.cmd=nil;if Bot.oldStyle then ar.ShotStyle=Bot.oldStyle end;if Bot.mk then pcall(function()Bot.mk:Destroy()end)end;lA()end;local lB;for g,bI in ipairs(aa.pages)do if bI.name=="Players"then lB=bI end end;if lB then local lC=aa.Card(lB,"No stun")aa.Toggle(lC,"No stun","NoStun")aa.Note(lC,"Stops stun animations, clears stun flags on your character and gets you back up. It also learns new stun animations the game shows you.")end;local lD=aa.Page("Auto Guard","A")do local lE="6022"local lF=""local lG=aa.Card(lD,"Auto Guard (locked)")aa.Input(lG,"Code",{get=function()return lF end,set=function(L)lF=tostring(L or"")end},nil,"enter the code")aa.Note(lG,"Auto Guard is locked. Enter the code to open it.")local lH={}C.AGContentFrames=lH;if ar.AGUnlocked then task.defer(function()lG.frame.Visible=false;for g,a5 in ipairs(lH)do a5.Visible=true end end)end;aa.Button(lG,"Unlock",function()if string.gsub(lF,"%s","")==lE then lG.frame.Visible=false;for g,a5 in ipairs(lH)do a5.Visible=true end;ar.AGUnlocked=true;aI()ao("Auto Guard","Unlocked",3)else ao("Auto Guard","Wrong code",3)end end,true)local lI=aa.Card(lD,"Auto guard")lI.frame.Visible=false;lH[#lH+1]=lI.frame;aa.Toggle(lI,"Auto guard","AG")aa.Dropdown(lI,"Who to guard","AGTarget",{"Ball handler","Closest to me","Closest to hoop"})aa.Toggle(lI,"Only guard the player who has the ball","AGOnlyBall")aa.Slider(lI,"Guard distance (studs in front)","AGDist",1,12,0.5,1)aa.Note(lI,"Holds the real Guard button while guarding, same as a real player, and uses Guard speed from the Players tab for how fast it closes out.")aa.Keybind(lI,"Guard key (keyboard, only if there is no on-screen Guard button)",function()return ar.GuardKey end,function(L)ar.GuardKey=L end)aa.Slider(lI,"Reaction time","AGReact",0,0.5,0.01,2,"s")aa.Slider(lI,"Prediction (looks ahead)","AGPredict",0,0.6,0.02,2,"s")aa.Slider(lI,"Guard range","AGRange",10,120,5,0," studs")aa.Toggle(lI,"Stay in front no matter what","AGLock")aa.Toggle(lI,"Only drive while I hold the real Guard button myself","AGHoldToUse")aa.Toggle(lI,"Face the player I guard","AGFace")aa.Toggle(lI,"Sprint to catch up","AGSprint")aa.Toggle(lI,"Look human (sway, hesitate, player speed)","AGHuman")aa.Slider(lI,"How human","AGHumanAmt",0,100,5,0,"%")aa.Note(lI,"It stands between the player and the hoop, and leads where they are going. Stay in front no matter what ignores range and reaction and chases at double speed.")local lJ=aa.Card(lD,"Auto block")lJ.frame.Visible=false;lH[#lH+1]=lJ.frame;aa.Toggle(lJ,"Auto block","AB")aa.Slider(lJ,"Block range","ABRange",4,30,1,0," studs")aa.Slider(lJ,"Block timing (delay after the shot starts)","ABDelay",0,0.5,0.01,2,"s")aa.Slider(lJ,"Block chance","ABChance",0,100,5,0,"%")aa.Keybind(lJ,"Block / jump key",function()return ar.ABKey end,function(L)ar.ABKey=L~=""and L or"Space"end)aa.Note(lJ,"Blocks by jumping at the shooter. If your game blocks with another button, set it here.")local jF=aa.Card(lD,"Remote Guard Recorder")jF.frame.Visible=false;lH[#lH+1]=jF.frame;aa.Note(jF,"Turn this on, then either guard someone for real (10-15s, walk toward/away/side to side) or have someone guard YOU. It catches every animation on you AND on whoever is nearest to you - priority, speed, looped or not - plus position, HoldingG, Action and state each tick.")C.rguardAnimLog=C.rguardAnimLog or{}C.rguardMoveLog=C.rguardMoveLog or{}C.rguardOppAnimLog=C.rguardOppAnimLog or{}local lK,lL,lM;local function lN(aR)if lL then lL:Disconnect()lL=nil end;lM=aR;if aR then lL=aR.AnimationPlayed:Connect(function(cq)if not ar.RGuardOn then return end;table.insert(C.rguardOppAnimLog,string.format("%s  oppanim  name=%s  id=%s  prio=%s  looped=%s  speed=%.2f",os.date("%H:%M:%S"),cq.Name,cq.Animation and cq.Animation.AnimationId or"?",cq.Priority.Name,tostring(cq.Looped),cq.Speed))if#C.rguardOppAnimLog>400 then table.remove(C.rguardOppAnimLog,1)end end)end end;aa.Toggle(jF,"Record everything about guarding","RGuardOn",function(L)if L then C.rguardAnimLog,C.rguardMoveLog,C.rguardOppAnimLog={},{},{}local aR=a7()if aR then lK=aR.AnimationPlayed:Connect(function(cq)if not ar.RGuardOn then return end;table.insert(C.rguardAnimLog,string.format("%s  anim  name=%s  id=%s  prio=%s  looped=%s  speed=%.2f",os.date("%H:%M:%S"),cq.Name,cq.Animation and cq.Animation.AnimationId or"?",cq.Priority.Name,tostring(cq.Looped),cq.Speed))if#C.rguardAnimLog>400 then table.remove(C.rguardAnimLog,1)end end)end;ao("Remote Guard Recorder","Recording. Guard someone, or have someone guard you.",5)else if lK then lK:Disconnect()lK=nil end;if lL then lL:Disconnect()lL=nil end;lM=nil;ao("Remote Guard Recorder","Stopped. Tap Copy to get the report.",4)end end)local lO,lP=nil,0;E(k.Heartbeat,function()if not ar.RGuardOn then return end;local bZ=tick()if bZ-lP<0.2 then return end;lP=bZ;local aR,aw=a7(),am.body()if not aR or not aw then return end;local lQ=0;if lO then lQ=W(aw.Position-lO).Magnitude/0.2 end;lO=aw.Position;local kC=a4()local lR={}for g,d7 in ipairs(aR:GetPlayingAnimationTracks())do local lS=d7.Animation and d7.Animation.AnimationId or"?"lR[#lR+1]=string.format("%s(%s,%s,spd=%.1f)",lS,d7.Priority.Name,tostring(d7.Looped),d7.Speed)end;local lT,lU;local a9,ld=pcall(Bot.others)if a9 and ld then for g,_ in ipairs(ld)do local bb=(_.pos-aw.Position).Magnitude;if not lU or bb<lU then lT,lU=_,bb end end end;local lV,lW="none",{}if lT and lU and lU<30 then lV=lT.pl and lT.pl.Name or"?"local lX=lT.c and lT.c:FindFirstChildOfClass("Humanoid")if lX then if lX~=lM then lN(lX)end;for g,d7 in ipairs(lX:GetPlayingAnimationTracks())do local lS=d7.Animation and d7.Animation.AnimationId or"?"lW[#lW+1]=string.format("%s(%s,%s,spd=%.1f)",lS,d7.Priority.Name,tostring(d7.Looped),d7.Speed)end end elseif lM then lN(nil)end;local lY=Bot.dbg or{}local lZ=string.format("dbgTarget=%s dbgDist=%s dbgDir=%s dbgSent=%s dbgSentOk=%s dbgSentVia=%s dbgHumState=%s dbgBlockedReason=%s",tostring(lY.target or"none"),lY.dist and string.format("%.1f",lY.dist)or"?",lY.dir and string.format("(%.2f,%.2f,%.2f)",lY.dir.X,lY.dir.Y,lY.dir.Z)or"?",lY.sentVec and string.format("(%.2f,%.2f,%.2f)",lY.sentVec.X,lY.sentVec.Y,lY.sentVec.Z)or"?",tostring(lY.sentOk),tostring(lY.sentVia),tostring(lY.humState),tostring(lY.reason or"none"))table.insert(C.rguardMoveLog,string.format("%s  move  state=%s  speed=%.1f  holdingG=%s  action=%s  guarding=%s  playing=%s  opp=%s  oppDist=%s  oppPlaying=%s  %s",os.date("%H:%M:%S"),aR:GetState().Name,lQ,tostring(kC and kC:GetAttribute("HoldingG")),tostring(kC and kC:GetAttribute("Action")),tostring(Bot.status or""),#lR>0 and table.concat(lR," | ")or"none",lV,lU and string.format("%.1f",lU)or"?",#lW>0 and table.concat(lW," | ")or"none",lZ))if#C.rguardMoveLog>200 then table.remove(C.rguardMoveLog,1)end end)aa.Button(jF,"Copy remote guard log",function()local l_={"== REMOTE GUARD RECORDER "..tostring(B).." | "..os.date("%Y-%m-%d %H:%M:%S")}if#C.rguardAnimLog==0 and#C.rguardMoveLog==0 and#C.rguardOppAnimLog==0 then l_[#l_+1]="(nothing recorded yet, turn it on and guard someone for real first)"else l_[#l_+1]="-- your animations (every one played, any priority) --"for g,bD in ipairs(C.rguardAnimLog)do l_[#l_+1]=bD end;l_[#l_+1]="-- opponent animations (nearest player/bot to you, every one played) --"for g,bD in ipairs(C.rguardOppAnimLog)do l_[#l_+1]=bD end;l_[#l_+1]="-- movement/state snapshots --"for g,bD in ipairs(C.rguardMoveLog)do l_[#l_+1]=bD end end;local av=table.concat(l_,"\n")pcall(function()if type(writefile)=="function"then writefile("JHub_remote_guard_log.txt",av)end end)if type(setclipboard)=="function"then pcall(setclipboard,av)end;ao("Remote Guard Recorder",string.format("%.0f KB, saved as JHub_remote_guard_log.txt and copied",#av/1024),6)end)end;local m0=aa.Page("Rebound","R")local m1=aa.Card(m0,"Auto rebound")aa.Toggle(m1,"Auto rebound","AR")aa.Slider(m1,"Speed","ARSpeed",0.5,3,0.1,1,"x")aa.Slider(m1,"Reaction time","ARReact",0,0.5,0.01,2,"s")aa.Slider(m1,"Range","ARRange",15,150,5,0," studs")aa.Toggle(m1,"Jump for the ball","ARJump")aa.Toggle(m1,"Grab it with the ball magnet when close","ARMagnet")aa.Slider(m1,"Grab distance","ARMagRange",3,20,1,0," studs")aa.Toggle(m1,"Show where the ball will land","ARMarker")aa.Note(m1,"Follows the ball's path, runs to where it will come down at hand height, jumps and grabs it.")local m2=aa.Page("Auto Grind","G")local m3=aa.Card(m2,"Auto play")local g,m4=aa.Button(m3,ar.AP and"Auto play: ON (tap to stop)"or"Auto play: OFF (tap to start)",function()Bot.setAP(not ar.AP)end,true)Bot.apLabel=m4;local m5=aa.Stat(m3,"Doing")aa.Dropdown(m3,"Build","APBuild",{"Big","Small","Wing","Shooter"})aa.Note(m3,"Needs Auto Green on, and it turns it on for you. Touch the stick and the bot hands the game back to you.")local m6=aa.Card(m2,"Big build")aa.Toggle(m6,"Post score (post up and score all game)","APPostScore")aa.Slider(m6,"Post range from the hoop","APPostRange",4,14,0.5,1," studs")local m7=aa.Card(m2,"Small build")aa.Toggle(m7,"All around score (dribble, shoot open, lay ups)","APAllAround")aa.Toggle(m7,"Dribble moves","APMoves")local m8=aa.Card(m2,"Smart shots")aa.Slider(m8,"Open when defender is farther than","APOpenDist",2,15,0.5,1," studs")aa.Slider(m8,"Longest jumper","APRange",12,40,1,0," studs")aa.Toggle(m8,"Take threes","APThree")aa.Toggle(m8,"Take lay ups and dunks","APLayups")aa.Toggle(m8,"Drive to the hoop","APDrive")aa.Slider(m8,"Time between shots","APShotDelay",0.3,4,0.1,1,"s")local m9=aa.Card(m2,"Movement")aa.Slider(m9,"Bot speed","APSpeed",0.5,2,0.1,1,"x")aa.Toggle(m9,"Sprint","APSprint")aa.Slider(m9,"Stop sprinting under this stamina","APStaminaMin",0,80,5,0,"%")aa.Slider(m9,"Spot up distance","APSpot",12,30,1,0," studs")local ma=aa.Card(m2,"Behaviour")aa.Toggle(ma,"Guard when the other team has the ball","APDefend")aa.Toggle(ma,"Chase rebounds","APRebound")aa.Toggle(ma,"Hand control back when I touch the stick","APPause")aa.Toggle(ma,"Anti AFK","APAntiAfk")aa.Dropdown(ma,"Teammates","APTeam",{"By team","Everyone is an opponent"})aa.Dropdown(ma,"Hoop to attack","APHoop",{"Nearest","Farthest"})aa.Button(ma,"Rescan hoops",function()task.spawn(Bot.scanHoops)end)aa.Button(ma,"Mark a hoop (stand under the rim first)",function()local aw=am.body()if not aw then return end;local bI=aw.Position;ar.HoopMarks=(ar.HoopMarks or"")..string.format("%.1f,%.1f,%.1f;",bI.X,bI.Y+8,bI.Z)aI()task.spawn(Bot.scanHoops)ao("Hoop","Marked",2)end)task.spawn(function()while C.Running do if hv.Visible and aa.current and aa.current.name=="Auto Grind"then pcall(function()m5.Text=Bot.status end)end;task.wait(0.4)end end)for g,bI in ipairs(aa.pages)do if bI.name=="Auto Grind"then bI.lbl.Parent.Visible=false end end;for g,bI in ipairs(aa.pages)do if bI.name=="UI"then bI.lbl.Parent.LayoutOrder=999 end end;if ar.AP then ar.AP=false end;task.spawn(Bot.scanHoops)end;do local mb={pings={},dts={},dtEma=1/60,stable=nil,pingBase=nil,dtBase=nil}C.api.Lag=mb;ae.slopes=ae.slopes or{}local function eM(b4,dZ)local S={}for cR,L in ipairs(b4)do S[cR]=L end;table.sort(S)return S[math.max(1,math.floor(#S*dZ))]end;E(k.Heartbeat,function(ec)mb.dtEma=mb.dtEma*0.9+ec*0.1 end)task.spawn(function()local bc=0;while C.Running do local a9,bI=pcall(function()return u:GetNetworkPing()end)if a9 and type(bI)=="number"then mb.pings[#mb.pings+1]=bI;if#mb.pings>3000 then table.remove(mb.pings,1)end;local gZ={}for cR=math.max(1,#mb.pings-14),#mb.pings do gZ[#gZ+1]=mb.pings[cR]end;mb.stable=eM(gZ,0.5)end;mb.dts[#mb.dts+1]=mb.dtEma;if#mb.dts>3000 then table.remove(mb.dts,1)end;bc=bc+1;if bc%50==0 and#mb.pings>=150 then mb.pingBase=eM(mb.pings,0.3)mb.dtBase=eM(mb.dts,0.35)end;task.wait(0.1)end end)function mb.pingEx()if not mb.stable or not mb.pingBase then return 0 end;return math.max(0,mb.stable-mb.pingBase)end;function mb.fpsComp()if not ar.LagSync or not mb.dtBase then return 0 end;return K((mb.dtEma-mb.dtBase)/2,0,0.12)end;function mb.total()return K(mb.pingEx()*(ar.LagK or 2)+mb.fpsComp(),0,0.25)end;local mc=ae.pingNow;function ae.pingNow()if ar.LagSync and mb.stable then return mb.stable end;return mc()end;function ae.effPing()local bI=ae.pingNow()if not ar.LagSync then return bI end;return bI+mb.pingEx()*((ar.LagK or 2)-1)end;function ae.fpsComp()return mb.fpsComp()end;function ae.lookAhead()if ar.LagSync then return K(1.25*mb.dtEma,0.02,0.2)end;return 0.02 end;local md=ae.pingComp;function ae.pingComp()local H,bI=md()if not ar.LagSync then return H,bI end;return K(math.max(H,mb.total()),0,0.25),bI end;function ae.markShot()ae.lastShotFps=C.FPS;ae.lastShotEx=mb.pingEx()end;local function go(dA)local bc=#dA;local c9=dA[1].t;local d2,dD,dE,dF=0,0,0,0;for g,bI in ipairs(dA)do local dG=bI.t-c9;d2,dD,dE,dF=d2+dG,dD+bI.q,dE+dG*dG,dF+dG*bI.q end;local dH=bc*dE-d2*d2;if dH<=1e-9 then return nil end;return(bc*dF-d2*dD)/dH end;function ae.peakFitSmart(dz,h)local cH=ae.peakFit(dz)if not ar.LagSync then return cH end;local dA,dB={},-1;for g,dC in ipairs(dz)do if dC.q<dB-0.001 then break end;dB=dC.q;if dC.q>0.12 and dC.q<0.93 then dA[#dA+1]=dC end end;local bc=#dA;if bc<2 then return cH end;local eL=C.FPS or 60;local me=ae.slopes[h]local M=bc>=6 and go(dA)or nil;if M and(M<1.2 or M>5)then M=nil end;local mf=not M or not me or math.abs(M-me)/me<0.08;if me and mf and dA[bc].q>0.25 and(ar.PrecFit or eL<45 or bc<7)then local mg,mh=0,0;for g,bI in ipairs(dA)do local V=bI.q*bI.q;mg=mg+(bI.t+(ae.PEAK_Q-bI.q)/me)*V;mh=mh+V end;return mg/mh end;return cH end;ae.slopeMiss=ae.slopeMiss or{}function ae.slopeCommit(dz,h)if not ar.LagSync or(C.FPS or 60)<40 then return end;local dA,dB={},-1;for g,dC in ipairs(dz)do if dC.q<dB-0.001 then break end;dB=dC.q;if dC.q>0.12 and dC.q<0.93 then dA[#dA+1]=dC end end;if#dA<8 then return end;local M=go(dA)if not M or M<1.2 or M>5 then return end;local me=ae.slopes[h]if not me then ae.slopes[h]=M elseif math.abs(M-me)/me<0.08 then ae.slopes[h]=me*0.85+M*0.15;ae.slopeMiss[h]=0 else local mi=(ae.slopeMiss[h]or 0)+1;ae.slopeMiss[h]=mi;if mi>=3 then ae.slopes[h],ae.slopeMiss[h]=M,0 end end end;function ae.lagLearn(db,aZ,cZ)local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if not dm or dm==5 or dm==4 then return end;local mj=ae.lastShotEx or 0;if mj<0.015 or(ae.lastShotFps or 60)<30 then return end;local ef=(dm-5)*0.014;ar.LagK=K((ar.LagK or 2)+ef/mj*0.3,0.5,3.5)aI()end;local mk=ae.learnRemote;function ae.learnRemote(db,aZ,cZ)if ar.LagSync and db and ae.FINAL[db.key]and not db.manual then pcall(ae.lagLearn,db,aZ,cZ)end;return mk(db,aZ,cZ)end;local ml;for g,bI in ipairs(aa.pages)do if bI.name=="Shooting"then ml=bI end end;if ml then local H=aa.Card(ml,"Lag sync")aa.Toggle(H,"Auto Green MAX (best timing, all upgrades)","GreenMax",function(L)for g,a1 in ipairs({"LagSync","PrecFit","AdaptPlus"})do aa.set(a1,L,false)end end)aa.Toggle(H,"Green every jumper (shared learning)","AllJumpers")aa.Slider(H,"Fade and step back timing (later)","FadeNudge",-30,40,1,0," ms")aa.Toggle(H,"Auto adapt: learn every shot from the first one","AutoAdaptAll")aa.Toggle(H,"Instant green (works at low FPS and high ping)","InstantGreen")aa.Toggle(H,"Smart steps (faster learning, no bouncing)","SmartSteps")aa.Toggle(H,"Show live open/contested feedback while dribbling","ContestShow")aa.Toggle(H,"Keep glides away from my shot","GlideShotSafe")aa.Buttons(H,{{"Copy my locked timings",function()local S=ae.exportTimings()if setclipboard then setclipboard(S)end;ao("Timings",S==""and"Nothing locked yet"or"Copied to clipboard",3)end}})aa.Input(H,"Import timings","ImportTimes",nil,"paste copied timings, then rejoin")aa.Toggle(H,"Lag sync (follow my ping and FPS)","LagSync")aa.Toggle(H,"Smoother meter reading","PrecFit")aa.Toggle(H,"Faster jumper adapt (experimental)","AdaptPlus")aa.Note(H,"Learns your normal ping and FPS. When either gets worse, Auto Green releases earlier by exactly that much, so the shot still lands on the green. Nothing changes while you are at your normal.")aa.Slider(H,"Ping compensation factor (learns by itself)","LagK",0.5,3.5,0.05,2,"x")local mm=aa.Stat(H,"Ping now")local mn=aa.Stat(H,"Ping normal")local mo=aa.Stat(H,"FPS now")local mp=aa.Stat(H,"Release shifted by")local mq=aa.Stat(H,"Perfects")task.spawn(function()while C.Running do if hv.Visible and aa.current==ml then pcall(function()mm.Text=mb.stable and string.format("%d ms",math.floor(mb.stable*1000+0.5))or"-"mn.Text=mb.pingBase and string.format("%d ms",math.floor(mb.pingBase*1000+0.5))or"learning"mo.Text=string.format("%d",math.floor(C.FPS+0.5))mp.Text=ar.LagSync and string.format("%d ms earlier",math.floor(mb.total()*1000+0.5))or"off"mq.Text=string.format("%d / %d (%d%%)",ae.stats.greens,ae.stats.shots,ae.stats.shots>0 and math.floor(ae.stats.greens*100/ae.stats.shots+0.5)or 0)end)end;task.wait(0.5)end end)end end;do local function mr(db,aZ,cZ)return db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)end;local function ms(h)local h9,bc={},0;for aV in string.gmatch(h,"%d+")do h9[aV]=true;bc=bc+1 end;return h9,bc end;function ae.seedLead(h)if not ar.AdaptPlus then return ar.PeakLead or 0.027 end;local bQ,mt=ms(h)local bO,mu;local b4={}for mv,m6 in pairs(ae.auto or{})do if mv~=h and m6.mode=="peak"and m6.locked and m6.hold then b4[#b4+1]=m6.hold;local mw,h0=ms(mv)local mx,gn,my=bQ,mw,mt;if h0<mt then mx,gn,my=mw,bQ,h0 end;local b1=my>0;for aV in pairs(mx)do if not gn[aV]then b1=false;break end end;if b1 and(not mu or my>mu)then bO,mu=m6.hold,my end end end;if bO then return bO end;if#b4>=2 then table.sort(b4)return b4[math.ceil(#b4/2)]end;return ar.PeakLead or 0.027 end;local mz=ae.peakLearn;function ae.peakLearn(db,aZ,cZ,M,h)if not ar.AdaptPlus then return mz(db,aZ,cZ,M,h)end;if M.locked then return true end;local dm=mr(db,aZ,cZ)if not dm then return true end;if db.manual and dm~=5 then return true end;local dI=db.lead or M.hold;if not db.manual and math.abs(dI-M.hold)>0.05 then return true end;local dJ=M.hold;M.n=(M.n or 0)+1;M.bin=M.bin or ar.PeakBin or 0.014;local mA=M.prev;if mA and dm~=5 and mA.idx~=5 and mA.idx~=dm and math.abs(dI-mA.lead)>0.002 then local dU=-(dI-mA.lead)/(dm-mA.idx)if dU>0 then M.bin=K(M.bin*0.5+dU*0.5,0.006,0.04)ar.PeakBin=K((ar.PeakBin or 0.014)*0.7+M.bin*0.3,0.008,0.03)end end;M.prev={idx=dm,lead=dI}local dr;if dm==5 then local mB=0;if mA and(mA.idx==6 or mA.idx==4)then local mC=(mA.lead+dI)/2;local br=mA.idx==6 and mC+M.bin/2 or mC-M.bin/2;mB=K(br-dI,-M.bin/2,M.bin/2)end;M.hold,M.locked=K(dI+mB,0,0.1),true;ar.PeakLead=K(ar.PeakLead*0.5+M.hold*0.5,0,0.08)pcall(ao,"Auto Green",string.format("Learned this shot: %.0f ms before the peak",M.hold*1000),3)dr="Perfect, locked"else local dT=dm-5;if dm==4 then dT=-1 end;M.hold=K(dI+dT*M.bin*0.85,0,0.1)ar.PeakLead=K(ar.PeakLead+(M.hold-dI)*0.25,0,0.08)dr=(ae.VERDICT[dm]or"?")..(dT>0 and", letting go earlier"or", letting go later")end;if math.abs(M.hold-dJ)>0.0003 or M.locked then ae.noteAdjust(h,dJ,M.hold,dr)end;ae.autoSave()if an.shotOn then an.shotAdd(string.format("AUTOCAL(meter) key=%s idx=%s lead=%.4f next=%.4f locked=%s bin=%.4f",h,tostring(dm),dI,M.hold,tostring(M.locked),M.bin))end;return true end end;do local Bot=C.api.Bot;local fm=aj.V;local function mr(db,aZ,cZ)return db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)end;ae.finalAdj=ae.finalAdj or{}ae.finalSt={}ae.finalLoaded=false;function ae.finalLoad()if ae.finalLoaded then return end;ae.finalLoaded=true;for h,aB in string.gmatch(ar.FinalAdj or"","(%S-)=([%-%d%.]+)")do ae.finalAdj[h]=tonumber(aB)end end;function ae.finalSave()local aE={}for h,aB in pairs(ae.finalAdj)do aE[#aE+1]=string.format("%s=%.4f",h,aB)end;table.sort(aE)ar.FinalAdj=table.concat(aE," ")aI()end;function ae.finalLearn(db,aZ,cZ)if db.manual then return end;if ar.LagSync and(ae.lastShotEx or 0)>=0.015 then return end;local dm=mr(db,aZ,cZ)if not dm then return end;ae.finalLoad()local h=db.key;local dT=dm==5 and 0 or dm==4 and-1 or dm-5;local d2=ae.finalSt[h]if not d2 then d2={b=0}ae.finalSt[h]=d2 end;local mD=ar.PeakBin or 0.014;local i=ae.finalAdj[h]or 0;local X=i;d2.b=d2.b*0.7+dT*0.3;if math.abs(dT)>=2 then X=i-dT*mD*0.7;d2.b=0 elseif math.abs(d2.b)>=0.45 then X=i-d2.b*mD*0.8;d2.b=0 end;X=K(X,-0.05,0.05)if X~=i then ae.finalAdj[h]=X;ae.noteAdjust(h,(ae.FINAL[h]or 0)+i,(ae.FINAL[h]or 0)+X,ae.VERDICT[dm]or"?")ae.finalSave()end end;local mE=false;function Bot.setGuardHold(h0)if ar.AGHoldToUse then return end;if h0==mE then return end;ac.action("Guard",h0)mE=h0 end;E(k.Heartbeat,function()if not ar.AG and mE then Bot.setGuardHold(false)end end)function Bot.guardStep(le,ld,lf)local S=Bot.pickTarget(ld,le,lf)if not S then Bot.dbg={reason="no target found"}return false end;local bW=W(S.pos-le).Magnitude;if bW>ar.AGRange and not ar.AGLock then Bot.dbg={target=S.pl.Name,targetPos=S.pos,dist=bW,reason=string.format("out of AGRange (%.0f > %.0f) and AGLock is off",bW,ar.AGRange)}return false end;local bZ=tick()local mF=ar.AGHuman and(ar.AGHumanAmt or 50)/100 or 0;local V=Bot.wob;if mF>0 and(not V or bZ-V.t>0.5+math.random()*0.9)then V={t=bZ,ox=(math.random()-0.5)*2.4*mF,oz=(math.random()-0.5)*2.4*mF,sp=1-0.18*mF+math.random()*0.3*mF,rj=math.random()*0.12*mF,pause=math.random()<0.12*mF and bZ+0.12 or 0}Bot.wob=V end;local mG=(ar.AGLock and 0 or ar.AGReact)+(V and mF>0 and V.rj or 0)if not Bot.spot or Bot.spotTarget~=S or bZ-Bot.spotT>=mG then local mH=S.pos+S.vel*ar.AGPredict;local lo=Bot.nearestHoop(mH)local mI=lo and W(lo-mH)or W(S.vel)if mI.Magnitude<0.1 then mI=W(le-mH)end;if mI.Magnitude<0.1 then mI=Vector3.new(0,0,1)end;local fj=mH+mI.Unit*ar.AGDist;if V and mF>0 then fj=fj+Vector3.new(V.ox,0,V.oz)end;Bot.spot,Bot.spotTarget,Bot.spotT=fj,S,bZ end;Bot.setGuardHold(true)local kZ=1+(ar.GuardSpeed or 0)/100;if mF>0 then kZ=math.min(kZ*V.sp,ar.AGLock and 1+0.8*mF or 1+0.35*mF)end;if V and mF>0 and V.pause>bZ then Bot.stopMove()Bot.dbg={target=S.pl.Name,targetPos=S.pos,spot=Bot.spot,dir=Vector3.new(),reason="human-wobble pause"}if ar.AGFace then Bot.faceAt(S.pos)end;Bot.status="Guarding "..S.pl.Name;return true end;local dq=W(Bot.spot-le)local bb=dq.Magnitude;local cd;if bb<0.5 then Bot.stopMove()cd=Vector3.new()else local fc=ar.AGLock and 1 or math.min(1,bb/3)cd=dq.Unit*fc;Bot.move(cd,kZ)end;Bot.dbg=Bot.dbg or{}Bot.dbg.target,Bot.dbg.targetPos,Bot.dbg.spot,Bot.dbg.dist,Bot.dbg.dir=S.pl.Name,S.pos,Bot.spot,bb,cd;Bot.dbg.reason=bb<0.5 and"within 0.5 studs of ideal spot, stopped"or nil;if ar.AGFace then Bot.faceAt(S.pos)end;Bot.status="Guarding "..S.pl.Name;return true end;function fm.customId(h)for a1,aV in string.gmatch(ar.LogoIds or"","(%w+)=(%d+)")do if a1==h then return aV end end;return nil end;function fm.customLogo(h)local aV=fm.customId(h)return aV and"rbxassetid://"..aV or nil end;function fm.setCustomId(h,av)local aV=string.match(tostring(av or""),"%d+")local aE={}for a1,L in string.gmatch(ar.LogoIds or"","(%w+)=(%d+)")do if a1~=h then aE[#aE+1]=a1 .."="..L end end;if aV then aE[#aE+1]=h.."="..aV end;ar.LogoIds=table.concat(aE," ")fm.logoKey=nil;aI()end;function aj.lookAs(bk,mJ)task.spawn(function()local aV=mJ;if not aV then local a9,aw=pcall(function()return j:GetUserIdFromNameAsync(O(tostring(bk)))end)if not a9 or not aw then ao("Real look","No Roblox player called "..tostring(bk),4)return end;aV=aw end;local a9,mK=pcall(function()return j:GetCharacterAppearanceAsync(aV)end)local H=a4()if not a9 or not mK or not H then ao("Real look","Could not load that look",4)return end;local aR=H:FindFirstChildOfClass("Humanoid")for g,bb in ipairs(H:GetChildren())do if bb:IsA("Accessory")or bb:IsA("Shirt")or bb:IsA("Pants")or bb:IsA("ShirtGraphic")or bb:IsA("BodyColors")then bb:Destroy()end end;for g,bb in ipairs(mK:GetChildren())do if bb:IsA("Accessory")then if aR then pcall(function()aR:AddAccessory(bb:Clone())end)end elseif bb:IsA("Shirt")or bb:IsA("Pants")or bb:IsA("ShirtGraphic")or bb:IsA("BodyColors")then bb:Clone().Parent=H end end;ao("Real look","Now looking like "..tostring(bk),3)end)end;local mL;for g,bI in ipairs(aa.pages)do if bI.name=="Features"then mL=bI end end;if mL then local mM=aa.Card(mL,"Real look")aa.Input(mM,"Roblox username","LookUser",nil,"type a username")aa.Buttons(mM,{{"Look like this player",function()aj.lookAs(ar.LookUser)end},{"Back to my look",function()aj.lookAs(u.Name,u.UserId)end}})aa.Note(mM,"Copies the clothes and accessories of any real Roblox account, only on your screen. Use it for any creator or character that has a Roblox account.")local jP=aa.Card(mL,"Custom logo image")aa.Input(jP,"Image ID for the logo picked above",{get=function()return fm.customId(ar.Logo)or""end,set=function(L)fm.setCustomId(ar.Logo,L)end},nil,"number from the image link")aa.Note(jP,"Paste the number from the creator's real logo image link and it replaces the badge above your head.")end end;do local mN=ae.autoActive;function ae.autoActive(h)if ar.AllJumpers and ar.AutoCal and not ae.FINAL[h]and not(ar.Sweep and an.shotOn)then return true end;return mN(h)end;local mO=ae.seedLead;function ae.seedLead(h)if ar.AllJumpers and(ar.GLeadN or 0)>=3 and(ar.GLead or 0)>0 then local L=mO(h)local bQ=ae.auto and ae.auto[h]if L==(ar.PeakLead or 0.027)or not ar.AdaptPlus then return K(ar.GLead,0,0.1)end;return L end;return mO(h)end;local mP=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if ar.AllJumpers and db and db.lead and not db.manual and db.remote~=false then local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm and(ar.LagSync and(ae.lastShotEx or 0)>=0.015)==false then local dT=dm==5 and 0 or dm==4 and-1 or dm-5;if math.abs(dT)<=3 then local dU=K(db.lead+dT*(ar.PeakBin or 0.014)*0.8,0,0.1)local bc=ar.GLeadN or 0;if bc<3 or(ar.GLead or 0)<=0 then ar.GLead=dU else ar.GLead=ar.GLead*0.85+dU*0.15 end;ar.GLeadN=math.min(bc+1,999)aI()end end end;return mP(db,aZ,cZ)end end;do ae.SHARED=""local mQ=ae.autoLoad;function ae.autoLoad()local kv=not ae.autoLoaded;mQ()if kv then for aF,h,aB in string.gmatch(ae.SHARED.." "..(ar.ImportTimes or""),"(%a):(%S-)=([%d%.]+)")do if not ae.auto[h]then ae.auto[h]={hold=tonumber(aB),greens={},locked=aF=="L"or aF=="l",dir=1,mode=(aF=="l"or aF=="p")and"peak"or nil}end end end end;function ae.exportTimings()ae.autoLoad()local aE={}for h,M in pairs(ae.auto)do if M.locked then aE[#aE+1]=string.format("%s:%s=%.4f",M.mode=="peak"and"l"or"L",h,M.hold)end end;table.sort(aE)return table.concat(aE," ")end end;do ae.GSLOPE=2.68;function ae.gslope()local b4={}for g,L in pairs(ae.slopes)do b4[#b4+1]=L end;if#b4>=3 then table.sort(b4)return b4[math.ceil(#b4/2)]end;return ae.GSLOPE end;local mR=ae.peakFitSmart;function ae.peakFitSmart(dz,h)local eb=mR(dz,h)if not ar.FirstShot or not ar.LagSync or ae.slopes[h]then return eb end;local dA,dB={},-1;for g,dC in ipairs(dz)do if dC.q<dB-0.001 then break end;dB=dC.q;if dC.q>0.12 and dC.q<0.93 then dA[#dA+1]=dC end end;local bc=#dA;if bc<3 or dA[bc].q<0.25 then return eb end;local a3=ae.gslope()if bc>=6 then local c9,d2,dD,dE,dF=dA[1].t,0,0,0,0;for g,bI in ipairs(dA)do local dG=bI.t-c9;d2,dD,dE,dF=d2+dG,dD+bI.q,dE+dG*dG,dF+dG*bI.q end;local dH=bc*dE-d2*d2;if dH>1e-9 then local M=(bc*dF-d2*dD)/dH;if math.abs(M-a3)/a3>0.2 then return eb end end end;local mg,mh=0,0;for g,bI in ipairs(dA)do local V=bI.q*bI.q;mg=mg+(bI.t+(ae.PEAK_Q-bI.q)/a3)*V;mh=mh+V end;return mg/mh end;local mS=ae.seedLead;function ae.seedLead(h)local L=mS(h)return L end;local mT=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)local aw=mT(db,aZ,cZ)if ar.FirstShot and db and not db.manual then local M=ae.auto and ae.auto[db.key]local dm=db.idx or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if M and M.mode=="peak"and not M.locked and dm and(dm>=7 or dm<=2)then M.hold=K(M.hold+(dm-5)*(M.bin or ar.PeakBin or 0.014)*0.4,0,0.1)ae.autoSave()end end;return aw end end;do local mU=ae.remoteHold;function ae.remoteHold(h,dM)ae.isFinalShot=ae.FINAL[h]~=nil;return mU(h,dM)end;ae.finalAdj={}function ae.finalLoad()ae.finalLoaded=true end;function ae.finalLearn()end;function ae.lagLearn()end;local mV=ae.pingComp;function ae.pingComp()if ae.isFinalShot then local bI=ae.pingNow()if not ar.PerfectGreen then return 0,bI end;return K((bI-ae.PING_REF)*(ar.PerfectGreenPct or 100)/100,0,0.2),bI end;return mV()end;local mW=ae.lookAhead;function ae.lookAhead()if ae.isFinalShot then return 0.02 end;return mW()end end;do local kn={["111074210919383"]=true,["71484695722621"]=true,["77401448272074"]=true,["128777513307709+77401448272074"]=true}local mX,d2=false,{}local function mY()if mX then return end;mX=true;for h,aB in string.gmatch(ar.FinalAdj or"","(%S-)=([%-%d%.]+)")do if ae.FINAL[h]then ae.finalAdj[h]=tonumber(aB)end end end;local function aG()local aE={}for h in pairs(ae.finalAdj)do if ae.finalAdj[h]then aE[#aE+1]=string.format("%s=%.4f",h,ae.finalAdj[h])end end;table.sort(aE)ar.FinalAdj=table.concat(aE," ")aI()end;function ae.finalLoad()mY()end;function ae.finalLearn(db,aZ,cZ)if db.manual or not ae.FINAL[db.key]or not(kn[db.key]or ar.AutoAdaptAll)then return end;local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if not dm then return end;mY()local h=db.key;local dT=dm==5 and 0 or dm==4 and-1 or dm-5;local P=d2[h]or{b=0}d2[h]=P;local kv=(P.n or 0)==0;P.n=(P.n or 0)+1;local mD,i=0.014*(kv and 1.5 or 1)*(ae.adaptGain and ae.adaptGain(h,dT)or 1),ae.finalAdj[h]or 0;local X=i;P.b=P.b*0.7+dT*0.3;if math.abs(dT)>=2 then X,P.b=i-dT*mD*0.9,0 elseif math.abs(P.b)>=0.45 then X,P.b=i-P.b*mD*0.8,0 end;X=K(X,-0.06,0.06)if X~=i then ae.finalAdj[h]=X;ae.noteAdjust(h,(ae.FINAL[h]or 0)+i,(ae.FINAL[h]or 0)+X,ae.VERDICT[dm]or"?")aG()end end end;do local mZ={"111074210919383","71484695722621","77401448272074"}local function m_(h)h=tostring(h)for g,aV in ipairs(mZ)do if string.find(h,aV,1,true)then return true end end;return false end;local n0=ae.seedLead;function ae.seedLead(h)if m_(h)and(ar.PFLeadN or 0)>=2 and(ar.PFLead or 0)>0 then return K(ar.PFLead,0,0.1)end;return n0(h)end;local n1=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if db and db.lead and not db.manual and not ae.FINAL[db.key]and m_(db.key)then local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm then local dT=dm==5 and 0 or dm==4 and-1 or dm-5;if math.abs(dT)<=3 then local dU=K(db.lead+dT*(ar.PeakBin or 0.014)*0.8,0,0.1)local bc=ar.PFLeadN or 0;if bc<2 or(ar.PFLead or 0)<=0 then ar.PFLead=dU else ar.PFLead=ar.PFLead*0.8+dU*0.2 end;ar.PFLeadN=math.min(bc+1,999)aI()end end end;return n1(db,aZ,cZ)end end;do local n2="https://raw.githubusercontent.com/jaydendagoat2/jayhubv1/claude/claudechud-8cord-executor-wclom3/executor/jhub_logo2.png"local n3="JHub_logo_v2.png"task.spawn(function()if type(getcustomasset)~="function"or type(writefile)~="function"then return end;local aD=false;if type(isfile)=="function"then local a9,aw=pcall(isfile,n3)aD=a9 and aw end;if not aD then local a9,aA=pcall(function()return game:HttpGet(n2)end)if not a9 or type(aA)~="string"or#aA<1000 then return end;if not pcall(writefile,n3,aA)then return end end;local a9,n4=pcall(getcustomasset,n3)if not a9 or not n4 or n4==""then return end;local a_=aa.LogoBody;if not a_ or not a_.Parent then return end;local fr=Instance.new("ImageLabel")fr.Name="JHubLogo"fr.BackgroundTransparency=1;fr.Size=UDim2.fromScale(1,1)fr.Image=n4;fr.ScaleType=Enum.ScaleType.Fit;fr.ZIndex=3;fr.Parent=a_;local H=Instance.new("UICorner")H.CornerRadius=UDim.new(0.2,0)H.Parent=fr;for g,bb in ipairs(a_:GetChildren())do if bb:IsA("GuiObject")and bb~=fr then bb.Visible=false end end;for g,bD in ipairs(aa.FloatLetters or{})do pcall(function()bD.Visible=false end)end end)end;do local hM,hN=720,405;hv.Size=UDim2.fromOffset(hM,hN)local n5=false;local n6=false;local function n7()hx.BackgroundTransparency=1;pcall(function()hx:FindFirstChild("Storm").Visible=false end)hA.Visible=false;hy.Transparency=1;iq.Position,iq.Size=UDim2.fromScale(0,0),UDim2.fromScale(1,1)i8.Position,i8.Size=UDim2.fromScale(0.28,0.105),UDim2.fromScale(0.70,0.095)ir.Position,ir.Size=UDim2.fromScale(0.045,0.40),UDim2.fromScale(0.2,0.52)it.Position,it.Size=UDim2.fromScale(0.285,0.25),UDim2.fromScale(0.685,0.66)is.Visible=false;local ia=i8:FindFirstChild("LogoBadge")if ia then ia.Visible=false end;for g,bb in ipairs(i8:GetChildren())do if bb:IsA("TextLabel")then bb.Position=UDim2.new(0,12,0.5,-7)end end end;local function n8()for g,bI in ipairs(aa.pages)do local n9=bI.frame:FindFirstChildOfClass("UIListLayout")if n9 then n9.FillDirection=Enum.FillDirection.Horizontal;n9.Wraps=true;n9.Padding=UDim.new(0,8)end;for g,H in ipairs(bI.frame:GetChildren())do if H:IsA("Frame")then H.Size=UDim2.new(0.5,-4,0,0)end end end end;n7()n8()local na=aa.applyWindow;function aa.applyWindow(...)local aw=na(...)if not n6 then n7()end;return aw end;function aa.fitScale()local gT=D().ViewportSize;local P=math.min(gT.X*0.94/hM,gT.Y*0.86/hN)if P>1.15 then P=1.15 end;hw.Scale=P*ar.UIScale end;aa.fitScale()local nb;im.Activated:Connect(function()task.wait()n6=jj;if jj then if nb then nb.Visible=false end;hx.BackgroundTransparency=0;i8.Position,i8.Size=UDim2.fromOffset(0,0),UDim2.new(1,0,0,46)hv.Size=UDim2.fromOffset(hM,46)else if nb then nb.Visible=true end;hv.Size=UDim2.fromOffset(hM,hN)n7()end end)local n2="https://raw.githubusercontent.com/jaydendagoat2/jayhubv1/claude/claudechud-8cord-executor-wclom3/executor/jhub_ui_bg2.png"local n3="JHub_ui_bg_v2.png"task.spawn(function()if type(getcustomasset)~="function"or type(writefile)~="function"then return end;local aD=false;if type(isfile)=="function"then local a9,aw=pcall(isfile,n3)aD=a9 and aw end;if not aD then local a9,aA=pcall(function()return game:HttpGet(n2)end)if not a9 or type(aA)~="string"or#aA<1000 then return end;if not pcall(writefile,n3,aA)then return end end;local a9,n4=pcall(getcustomasset,n3)if not a9 or not n4 or n4==""then return end;nb=Instance.new("ImageLabel")nb.Name="JHubArt"nb.BackgroundColor3=Color3.new(0,0,0)nb.BorderSizePixel=0;nb.Size=UDim2.fromScale(1,1)nb.Image=n4;nb.ScaleType=Enum.ScaleType.Stretch;nb.ZIndex=0;nb.Visible=not n6;nb.Parent=hx;n5=true end)end;do local nc={Rainbow={Color3.fromRGB(70,140,255),Color3.fromRGB(255,214,60),Color3.fromRGB(165,95,255)},Blue={Color3.fromRGB(70,140,255),Color3.fromRGB(130,185,255),Color3.fromRGB(40,100,230)},Yellow={Color3.fromRGB(255,214,60),Color3.fromRGB(255,236,140),Color3.fromRGB(230,180,20)},Purple={Color3.fromRGB(165,95,255),Color3.fromRGB(200,150,255),Color3.fromRGB(130,60,230)}}aQ=function()local S=nc[ar.AccentTone]or nc.Rainbow;aP.Glass=Color3.fromRGB(6,6,10)aP.Sheen=Color3.fromRGB(20,20,40)aP.Card=Color3.fromRGB(10,10,16)aP.Elem=Color3.fromRGB(20,20,30)aP.Stroke=Color3.fromRGB(0,0,30)aP.Text=Color3.fromRGB(255,255,255)aP.Sub=Color3.fromRGB(190,195,225)aP.Outline=S[1]aP.AccentA=S[2]aP.AccentB=S[3]end;aQ()pcall(function()hx:FindFirstChild("Storm"):Destroy()end)pcall(function()hA:Destroy()end)aa.paintStorm=function()end;aa.applyFx=function()end;hy.Transparency=1;do local a_=aa.LogoBody;for g,bb in ipairs(a_:GetChildren())do if bb:IsA("UIStroke")or bb:IsA("UIGradient")then bb:Destroy()end end;a_.BackgroundTransparency=1;a_:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()if a_.BackgroundTransparency<1 then a_.BackgroundTransparency=1 end end)pcall(function()jl:Destroy()end)pcall(function()jq:Destroy()end)pcall(function()jr:Destroy()end)pcall(function()aa.LogoRoot.Size=UDim2.fromOffset(math.max(ar.LogoSize,56),math.max(ar.LogoSize,56))end)end;for g,N in ipairs({im,io})do for g,bb in ipairs(N:GetChildren())do if bb:IsA("UIStroke")or bb:IsA("TextLabel")or bb:IsA("UICorner")then bb:Destroy()end end;N.BackgroundTransparency=1;N:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()if N.BackgroundTransparency<1 then N.BackgroundTransparency=1 end end)end;im.Position=UDim2.new(1,-40,0.5,0)io.Position=UDim2.new(1,-6,0.5,0)pcall(function()ip.Visible=false end)local function nd()ir.Position,ir.Size=UDim2.fromScale(0.042,0.385),UDim2.fromScale(0.205,0.565)for g,bb in ipairs(ir:GetChildren())do if bb:IsA("TextButton")then bb.Size=UDim2.new(1,0,0,34)end;if bb:IsA("UIPadding")then bb.PaddingLeft,bb.PaddingRight,bb.PaddingTop=UDim.new(0,0),UDim.new(0,0),UDim.new(0,1)end;if bb:IsA("UIListLayout")then bb.Padding=UDim.new(0,4)end end;for g,bb in ipairs(i8:GetChildren())do if bb:IsA("TextLabel")then bb.Text="JHub V"..B:sub(2)bb.TextSize=20;bb.Position=UDim2.new(0,14,0.5,-11)bb.Size=UDim2.new(0,200,0,22)end end end;nd()local ne=aa.applyWindow;function aa.applyWindow(...)local aw=ne(...)nd()return aw end;for g,bI in ipairs(aa.pages)do if bI.name=="UI"then local i={["Glass look"]=true,["Outline"]=true,["Presets"]=true,["Lightning"]=true,["Moving background"]=true,["Header logo"]=true}for g,a5 in ipairs(bI.frame:GetChildren())do if a5:IsA("Frame")then for g,bb in ipairs(a5:GetDescendants())do if bb:IsA("TextLabel")and i[bb.Text]then a5:Destroy()break end end end end;local H=aa.Card(bI,"Colors")aa.Dropdown(H,"Menu color","AccentTone",{"Rainbow","Blue","Yellow","Purple"},function()aa.applyTheme()end)aa.Slider(H,"Card darkness","CardTrans",0.1,0.9,0.01,2,nil,function()aa.applyTheme()end)H.frame.LayoutOrder=-1;H.frame.Size=UDim2.new(0.5,-4,0,0)end end;aa.applyTheme()end;do local Bot=C.api.Bot;function Bot.reboundStep(le,aw)if not aj.ballLoose()then Bot.marker(nil)Bot.rbT=nil;return false end;local N=aj.findBall()if not N or not N.Parent then return false end;local bZ=tick()local bP=W(N.Position-le).Magnitude;if bP>ar.ARRange then return false end;if not Bot.rbT then Bot.rbT=bZ;Bot.rbDelay=(ar.ARReact or 0.18)*(0.8+math.random()*0.5)Bot.rbSway={math.random()-0.5,math.random()-0.5}end;if bZ-Bot.rbT<Bot.rbDelay then return false end;local ln,S=Bot.predictBall(N)Bot.marker(ln)local fj=ln;local lo=Bot.nearestHoop(ln)if lo then local lr=W(lo-ln)if lr.Magnitude>3 then fj=ln+lr.Unit*math.min(1.6,lr.Magnitude*0.1)end end;fj=fj+Vector3.new(Bot.rbSway[1]*0.8,0,Bot.rbSway[2]*0.8)local dq=W(fj-le)local bb=dq.Magnitude;local lQ=K(ar.ARSpeed or 1,0.5,1.3)if bb>1.3 then Bot.move(dq.Unit*math.min(1,bb/3),lQ)Bot.setSprint(bb>12 and S>0.8)else Bot.stopMove()Bot.faceAt(N.Position)end;if ar.ARJump and S<0.42 and bP<6 and N.Position.Y>le.Y+2 and bZ-Bot.jumpT>0.9 then Bot.jumpT=bZ;Bot.press("Space",0.15,{"jump"})end;if ar.ARMagnet and bP<=math.min(ar.ARMagRange or 4,5)and N.Position.Y<le.Y+7 and bZ-Bot.ballT>0.5 then Bot.ballT=bZ;pcall(aj.getBall,true)end;Bot.status=string.format("Rebound (%.1fs)",S)return true end;function aj.getBall(bX)local aw=am.body()local N,bW=aj.findBall()if not aw or not N then return false end;if N.Position.Y>aw.Position.Y+12 then return false end;if ar.MagnetMode~="Go to the ball"then if not aj.hop(N)then return false end else task.spawn(function()local c9=tick()while C.Running and tick()-c9<0.45 do local nf,jO=am.body(),aj.findBall()if not nf or not jO then return end;local bb=Vector3.new(jO.Position.X-nf.Position.X,0,jO.Position.Z-nf.Position.Z)if bb.Magnitude<3 then return end;nf.CFrame=nf.CFrame+bb.Unit*math.min(bb.Magnitude-2.5,5)am.sync(nf)k.Heartbeat:Wait()end end)end;I(string.format("Ball magnet: %s (%.0f studs away)",ar.MagnetMode,bW or 0))return true end;local ng=aj.magnetStep;function aj.magnetStep()local bZ=tick()if ar.BallMagnet and bZ<(aj.magnetNext or 0)then return end;local dJ=aj.magnetT;ng()if aj.magnetT~=dJ then aj.magnetNext=bZ+0.3+math.random()*0.5 end end end;do local nh,hD,ni=Color3.fromRGB(70,140,255),Color3.fromRGB(255,214,60),Color3.fromRGB(165,95,255)local nj={nh,hD,ni}local function nk(S)local cR=math.floor(S/2.6)%#nj+1;local hJ=cR%#nj+1;local a1=(S%2.6-2.1)/0.5;if a1<=0 then return nj[cR]end;a1=a1*a1*(3-2*a1)return nj[cR]:Lerp(nj[hJ],a1)end;local nl=aa.paintGrad;function aa.paintGrad(a3)if ar.AccentTone=="Rainbow"then a3.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,nh),ColorSequenceKeypoint.new(0.5,ni),ColorSequenceKeypoint.new(1,hD)})else nl(a3)end end;task.spawn(function()while C.Running do task.wait(0.12)if ar.AccentTone=="Rainbow"and hv.Visible then local S=tick()local H=nk(S)aP.AccentA,aP.AccentB,aP.Outline=H:Lerp(Color3.new(1,1,1),0.3),H,H;for g,eU in ipairs(aa.themed)do local h=eU[3]if(h=="AccentA"or h=="AccentB"or h=="Outline")and eU[1].Parent then pcall(function()eU[1][eU[2]]=aP[h]end)end end;for g,a3 in ipairs(aa.grads)do if a3.Parent then a3.Rotation=S*40%360 end end end end end)aa.applyTheme()end;do local nm={["111074210919383"]=true,["71484695722621"]=true,["77401448272074"]=true,["128777513307709+77401448272074"]=true}local mU=ae.remoteHold;function ae.remoteHold(h,dM)local dR,cH,b3=mU(h,dM)ae.lastNudge=nil;local bc=(ar.FadeNudge or 0)/1000;if bc~=0 and dR then local nn=nm[h]==true;local l6=ae.situation()~="stand"if b3=="peak"and(nn or l6)then ae.lastNudge=bc;dR=K(dR-bc,0,0.1)elseif b3~="peak"and nn then dR=dR+bc end end;return dR,cH,b3 end;local mP=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if db and db.lead and ae.lastNudge then db.lead=db.lead+ae.lastNudge end;return mP(db,aZ,cZ)end;local no=aj.getBall;function aj.getBall(bX)local bb=(ar.MagnetDelay or 0)/1000;if bb<=0 then return no(bX)end;task.delay(bb*(0.8+math.random()*0.4),function()if C.Running then pcall(no,bX)end end)return true end end;do local mW=ae.lookAhead;function ae.lookAhead()if ar.InstantGreen then local ec=1/math.max(C.FPS or 60,1)return K(1.3*ec,0.03,0.6)end;return mW()end;local np=ae.fpsComp;function ae.fpsComp()if ar.InstantGreen then return 0 end;return np()end;local mR=ae.peakFitSmart;function ae.peakFitSmart(dz,h)local eb=mR(dz,h)if eb or not ar.InstantGreen then return eb end;local a3=ae.gslope and ae.gslope()or 2.68;return ae.meterT+ae.PEAK_Q/a3 end;local mU=ae.remoteHold;function ae.remoteHold(h,dM)local dR,cH,b3=mU(h,dM)if ar.InstantGreen and b3~="peak"and ae.FINAL[h]and dR then local ew=K((ae.effPing and ae.effPing()or 0)-0.035,0,0.5)if ew>0 then dR=math.max(ae.FLOOR,dR-ew)end end;return dR,cH,b3 end end;do local kL=ae.onShootCall;function ae.onShootCall(c4)local bb=c4[1]if ar.GlideShotSafe and type(bb)=="table"then if bb.Shoot==true then am.shotDownT=tick()pcall(ag.cancel)elseif bb.Shoot==false then am.shotUpT=tick()end end;return kL(c4)end;local function k4()return(am.shotDownT or 0)>(am.shotUpT or 0)end;local nq=ag.fire;function ag.fire(aF,dr,cd)if ar.GlideShotSafe then local bZ=tick()local H=a4()local nr=H and H:GetAttribute("Action")if aF~="shot"and(k4()or bZ-(am.shotUpT or 0)<0.35 or nr=="Shooting")then return end;if aF=="shot"and bZ-(am.shotUpT or 0)<0.12 then task.delay(0.12,function()if C.Running then pcall(nq,aF,dr,cd)end end)return end end;return nq(aF,dr,cd)end;local ns=ai.step;function ai.step(ec)if ar.GlideShotSafe and k4()then return end;return ns(ec)end end;do local nt={rows={},stats={}}ae.lab=nt;local nu={"shot","shoot","jump","fade","step","layup","dunk","hook","post","spin","float","finger","gather","euro","hop"}local function nv(db,aZ,cZ)return db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)end;function nt.add(db,aZ,cZ)local dm=nv(db,aZ,cZ)local h=tostring(db.key or"?")local bN=a4()local dt=bN and bN:GetAttribute("BaseAnimation")or nil;local b3=ae.FINAL[h]and"built-in"or(db.lead and"learned"or"fixed")local iP={t=os.date("%H:%M:%S"),key=h,name=ae.nameFor(h,dt),mode=b3,held=db.held or 0,lead=db.lead,verdict=dm and ae.VERDICT[dm]or tostring(aZ or"?"),idx=dm,ping=math.floor((ae.pingNow and ae.pingNow()or 0)*1000+0.5),fps=math.floor((C.FPS or 0)+0.5),sit=ae.situation(),manual=db.manual==true,nudge=ae.lastNudge}nt.rows[#nt.rows+1]=iP;if#nt.rows>400 then table.remove(nt.rows,1)end;local P=nt.stats[h]if not P then P={name=iP.name,mode=b3,n=0,perfect=0,good=0,early=0,late=0,offSum=0,heldSum=0}nt.stats[h]=P end;P.n=P.n+1;P.heldSum=P.heldSum+iP.held;if dm then if dm==5 then P.perfect=P.perfect+1 elseif dm==4 then P.good=P.good+1 elseif dm<4 then P.early=P.early+1 else P.late=P.late+1 end;P.offSum=P.offSum+(dm==4 and-1 or dm-5)end;if nt.stat then local nw=""local nx=P.n>0 and P.offSum/P.n or 0;if P.n>=3 and nx<-0.5 then nw="  (keeps releasing early)"elseif P.n>=3 and nx>0.5 then nw="  (keeps releasing late)"end;nt.stat.Text=string.format("%s: %s  |  %d ms  %d FPS%s",iP.name,iP.verdict,iP.ping,iP.fps,nw)end;if nt.count then nt.count.Text=tostring(#nt.rows).." shots"end end;function nt.animations()local R,bc={},0;for g,bb in ipairs(game:GetDescendants())do if bb:IsA("Animation")and tostring(bb.AnimationId)~=""then local gi=string.lower(bb.Name)for g,V in ipairs(nu)do if string.find(gi,V,1,true)then R[#R+1]=bb.Name.." = "..string.gsub(tostring(bb.AnimationId),"rbxassetid://","").."  ("..bb.Parent.Name..")"bc=bc+1;break end end end;if bc>=500 then break end end;table.sort(R)return R end;function nt.report()local cW={"== JHub Shot Lab report ==","version "..tostring(B).." | place "..tostring(game.PlaceId).." | "..tostring(C.execName).." | "..os.date("%Y-%m-%d %H:%M:%S")}local ny={"LagSync","InstantGreen","AutoAdaptAll","FadeNudge","AdaptPlus","PrecFit","GreenMax","AutoCal","AutoCalibrate","CalSpeed","PeakBin","GlideShotSafe","ShotGlideWhen","ShotGlideMethod","Sweep"}local d2={}for g,a1 in ipairs(ny)do d2[#d2+1]=a1 .."="..tostring(ar[a1])end;cW[#cW+1]="settings: "..table.concat(d2," ")cW[#cW+1]=""cW[#cW+1]="-- per shot type: name | key | mode | shots | perfect good early late | average miss (-early +late) | advice --"local bG={}for a1 in pairs(nt.stats)do bG[#bG+1]=a1 end;table.sort(bG)for g,a1 in ipairs(bG)do local P=nt.stats[a1]local nx=P.n>0 and P.offSum/P.n or 0;local nz="fine"if P.n>=3 and nx<-0.4 then nz=string.format("release about %.0f ms later",math.abs(nx)*14)elseif P.n>=3 and nx>0.4 then nz=string.format("release about %.0f ms earlier",math.abs(nx)*14)elseif P.n<3 then nz="need more shots"end;cW[#cW+1]=string.format("%s | %s | %s | %d | %d %d %d %d | %+.2f | %s",P.name,a1,P.mode,P.n,P.perfect,P.good,P.early,P.late,nx,nz)end;cW[#cW+1]=""cW[#cW+1]="-- last shots: time | name | key | mode | held | lead | result | ping ms | FPS | move | manual --"local df=math.max(1,#nt.rows-120)for cR=df,#nt.rows do local aw=nt.rows[cR]cW[#cW+1]=string.format("%s | %s | %s | %s | %.3f | %s | %s | %d | %d | %s | %s",aw.t,aw.name,aw.key,aw.mode,aw.held,aw.lead and string.format("%.3f",aw.lead)or"-",aw.verdict,aw.ping,aw.fps,aw.sit,tostring(aw.manual))end;return table.concat(cW,"\n")end;local function copy(av,nA)if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Shot Lab",nA.." copied",3)else ao("Shot Lab","This executor cannot copy to the clipboard",4)end end;local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB then local H=aa.Card(nB,"Shot Lab")aa.Toggle(H,"Record every shot","LabOn")nt.stat=aa.Stat(H,"Last shot")nt.count=aa.Stat(H,"Recorded")aa.Buttons(H,{{"Copy shot report",function()copy(nt.report(),"Shot report")end},{"Copy game shot animations",function()copy("== game shot animations ==\n"..table.concat(nt.animations(),"\n"),"Animation list")end}})aa.Button(H,"Clear recorded shots",function()nt.rows,nt.stats={},{}if nt.count then nt.count.Text="0 shots"end end)aa.Note(H,"Shoot normally. After a few shots of each move, copy the report and send it. The animation list names the game's own shot animations.")end;local nC=ae.learnRemote;function ae.learnRemote(db,aZ,cZ)if ar.LabOn and db then pcall(nt.add,db,aZ,cZ)end;return nC(db,aZ,cZ)end end;do local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB then local H=aa.Card(nB,"Shot Intelligence")local nD=aa.Stat(H,"Detected jumpshot")local nE=aa.Stat(H,"Animation ID")local nF=aa.Stat(H,"Calibration status")local nG=aa.Stat(H,"Confidence")local nH=aa.Stat(H,"Active timing")local nI=aa.Stat(H,"Recognized before")local nJ=aa.Stat(H,"Times seen")local nK=aa.Stat(H,"Situations seen")local nL=aa.Stat(H,"Needs retest")local nM=aa.Stat(H,"Known profiles")aa.Button(H,"Copy every known shot profile",function()local cW={"== JHub shot intelligence profiles =="}local bE={}local nN=C.ShotIntel and C.ShotIntel.DB or{}for h in pairs(ae.FINAL)do bE[h]=true;local kp=nN[h]cW[#cW+1]=string.format("%s | %s | built-in, confirmed | hold %.3fs | seen %dx%s",ae.nameFor(h),h,ae.FINAL[h],kp and kp.timesSeen or 0,kp and kp.needsRetest and" | NEEDS RETEST"or"")end;for h,M in pairs(ae.auto or{})do if not bE[h]then local kp=nN[h]cW[#cW+1]=string.format("%s | %s | %s | %d samples | hold %.3fs | seen %dx%s",ae.nameFor(h),h,M.locked and"locked"or"learning",M.n or 0,M.hold or 0,kp and kp.timesSeen or 0,kp and kp.needsRetest and" | NEEDS RETEST"or kp and not kp.identified and" | unidentified animation"or"")end end;copy(table.concat(cW,"\n"),"Shot profiles")end)aa.Note(H,"Each jumpshot animation gets its own timing profile automatically - switching jumpshots switches profiles, no setup needed. A profile needs enough consistent real shots before it is trusted (locked); until then it is still learning. If a locked profile starts missing consistently, it is automatically unlocked and flagged to retest instead of staying trusted forever.")task.spawn(function()while true do local du=ae.cur;local nN=C.ShotIntel and C.ShotIntel.DB or{}if du and du.key then local h=du.key;local M=ae.auto and ae.auto[h]local kp=nN[h]nD.Text=ae.nameFor(h,du.anim)nE.Text=string.sub(tostring(h),1,22)nF.Text=du.state or"-"if ae.FINAL[h]then nG.Text="Built-in (confirmed)"elseif M then nG.Text=string.format("%d samples%s",M.n or 0,M.locked and", locked"or", learning")else nG.Text="No data yet"end;nH.Text=string.format("%.3fs",du.hold or 0)nI.Text=kp and"Yes"or"No"nJ.Text=kp and tostring(kp.timesSeen or 0)or"0"if kp and kp.sits and next(kp.sits)then local aE={}for nO,i6 in pairs(kp.sits)do aE[#aE+1]=nO.." x"..i6 end;table.sort(aE)nK.Text=table.concat(aE,", ")else nK.Text="-"end;nL.Text=kp and kp.needsRetest and"Yes - flagged"or"No"if kp and not kp.identified then nF.Text="Unidentified animation"end else nD.Text,nE.Text,nF.Text,nG.Text,nH.Text="-","-","Shoot to see it","-","-"nI.Text,nJ.Text,nK.Text,nL.Text="-","-","-","-"end;local me=0;for g in pairs(ae.FINAL)do me=me+1 end;for g in pairs(ae.auto or{})do me=me+1 end;nM.Text=tostring(me)task.wait(1)end end)end end;do local nP=Enum.Font.PermanentMarker;local function nQ()for g,bb in ipairs(i8:GetChildren())do if bb:IsA("TextLabel")then bb.Font=nP;bb.TextSize=28;bb.TextColor3=Color3.new(1,1,1)bb.TextStrokeColor3=Color3.new(0,0,0)bb.TextStrokeTransparency=0.05;bb.Size=UDim2.new(0,280,0,30)bb.Position=UDim2.new(0,14,0.5,-15)if not bb:FindFirstChildOfClass("UIGradient")then aa.grad(bb)end end end end;pcall(nQ)local ne=aa.applyWindow;function aa.applyWindow(...)local aw=ne(...)pcall(nQ)return aw end end;do local nR={["123897568594090"]="Backstep1L",["127422207069035"]="Backstep1R",["16145346328"]="CloseFade1L",["16145343052"]="CloseFade1R",["16143619816"]="CloseShot1L",["16143612725"]="CloseShot1R",["122465444344495"]="ClutchShot1R",["105859087082844"]="ClutchShot2R",["104766830277346"]="Escape Retreat StepBack 1 L",["101763948381427"]="Escape Retreat StepBack 1 R",["18490241160"]="Eurostep1L",["18490760705"]="Eurostep1R",["111704738351151"]="Eurostep2L",["94525958298824"]="Eurostep2R",["16247513358"]="FadeAway1L",["16104888271"]="FadeAway1R",["72457151419535"]="FadeOffSpin",["73312396340408"]="Floater1L",["18479327091"]="Floater1R",["83560375675042"]="Floater2L",["110801085144110"]="Floater2R",["72125557808800"]="Floater3L",["101591116880216"]="Floater3R",["121266237142174"]="Floater4L",["76935911753836"]="Floater4R",["129529685206875"]="HalfSpin 1 L",["116377271778907"]="HalfSpin 1 R",["18562916903"]="Hopstep1L",["18564813109"]="Hopstep1R",["74708121013638"]="Jumpshot10LBase",["89043189007783"]="Jumpshot10LRelease",["93718423729481"]="Jumpshot10RBase",["106368953335940"]="Jumpshot10RRelease",["98057390970111"]="Jumpshot11LBase",["139180517555346"]="Jumpshot11LRelease",["108219916586130"]="Jumpshot11RBase",["122616867439575"]="Jumpshot11RRelease",["133292215102254"]="Jumpshot12LBase",["109188880516100"]="Jumpshot12LRelease",["85618824455884"]="Jumpshot12RBase",["108356101205697"]="Jumpshot12RRelease",["126439912802076"]="Jumpshot13LBase",["122548714712371"]="Jumpshot13LRelease",["92872377351550"]="Jumpshot13RBase",["140052980856457"]="Jumpshot13RRelease",["114941990966676"]="Jumpshot14LBase",["108579262151957"]="Jumpshot14LRelease",["81957659045162"]="Jumpshot14RBase",["90495832697285"]="Jumpshot14RRelease",["74979847696031"]="Jumpshot15LBase",["110632271666784"]="Jumpshot15LRelease",["84540244428238"]="Jumpshot15RBase",["71664326786621"]="Jumpshot15RRelease",["109811332443306"]="Jumpshot16LBase",["132558433850380"]="Jumpshot16LRelease",["71026149999012"]="Jumpshot16RBase",["118631494115522"]="Jumpshot16RRelease",["15852002207"]="Jumpshot1LBase",["15852004111"]="Jumpshot1LRelease",["15851912457"]="Jumpshot1RBase",["15851919155"]="Jumpshot1RRelease",["105701400634134"]="Jumpshot2LBase",["109450934633536"]="Jumpshot2LRelease",["72456843565147"]="Jumpshot2RBase",["84289633045544"]="Jumpshot2RRelease",["127398785869633"]="Jumpshot3LBase",["112156144070038"]="Jumpshot3LRelease",["103840440800065"]="Jumpshot3RBase",["121374781838539"]="Jumpshot3RRelease",["93579833800410"]="Jumpshot4LBase",["118445199489350"]="Jumpshot4LRelease",["107267506258170"]="Jumpshot4RBase",["88476923576638"]="Jumpshot4RRelease",["98433629221242"]="Jumpshot5LBase",["136333410000989"]="Jumpshot5LRelease",["78687270972169"]="Jumpshot5RBase",["105872738506827"]="Jumpshot5RRelease",["87425338536981"]="Jumpshot6LBase",["119409927614003"]="Jumpshot6LRelease",["94901854704297"]="Jumpshot6RBase",["134827491525733"]="Jumpshot6RRelease",["129361186598012"]="Jumpshot7LBase",["136230260055859"]="Jumpshot7LRelease",["106983388593429"]="Jumpshot7RBase",["84934876114141"]="Jumpshot7RRelease",["140548746406756"]="Jumpshot8LBase",["101150492242995"]="Jumpshot8LRelease",["130802304867577"]="Jumpshot8RBase",["95617155918948"]="Jumpshot8RRelease",["135680344718842"]="Jumpshot9LBase",["121465657586926"]="Jumpshot9LRelease",["94696336118150"]="Jumpshot9RBase",["79176486779613"]="Jumpshot9RRelease",["96144129758396"]="JumpshotSmothered1L",["86178912276158"]="JumpshotSmothered1R",["16247060979"]="MovingShotLeft1L",["16205020756"]="MovingShotLeft1R",["16247080711"]="MovingShotRight1L",["16246923753"]="MovingShotRight1R",["118903578746477"]="PostFadeLeft1L",["89959998001439"]="PostFadeLeft1R",["90675102495015"]="PostFadeRight1L",["128777513307709"]="PostFadeRight1R",["94918503601868"]="PostHookLeft1L",["139165512882286"]="PostHookRight1R",["71484695722621"]="PostSpinGather1L",["77401448272074"]="PostSpinGather1R",["18507584241"]="SpinGather1L",["18507570562"]="SpinGather1R",["95688876134046"]="SpinHookLeft1L",["104966197366795"]="SpinHookRight1R",["91053585299044"]="StepBack 1 L",["100829976540057"]="StepBack 1 R",["76796993769486"]="StepBack 2 L",["94150114804496"]="StepBack 2 R",["119260785892440"]="StepPostFade1L",["111074210919383"]="StepPostFade1R",["95782467897683"]="UnderRimCloseShot1L",["107778200710432"]="UnderRimCloseShot1R"}ae.idName=nR;local function nS(aV)return nR[tostring(aV)]end;local nT=ae.nameFor;function ae.nameFor(h,dt)local bc=ae.keyName[h]or ae.NAMES[h]if bc then return bc end;local aE,bw={},false;for aV in string.gmatch(tostring(h),"%d+")do local gi=nS(aV)if gi then bw=true end;aE[#aE+1]=gi or aV end;if bw then return table.concat(aE," + ")end;return nT(h,dt)end;local nU={{"postfade",{"PostFade","StepPostFade","PostSpinGather"}},{"stepback",{"StepBack","Backstep","Retreat"}},{"fade",{"FadeAway","CloseFade","FadeOffSpin"}},{"moving",{"MovingShot"}},{"close",{"CloseShot","UnderRim"}},{"floater",{"Floater"}},{"hook",{"Hook"}},{"jumpshot",{"Jumpshot"}}}function ae.familyOf(h)for aV in string.gmatch(tostring(h),"%d+")do local gi=nS(aV)if gi then for g,nV in ipairs(nU)do for g,nW in ipairs(nV[2])do if string.find(gi,nW,1,true)then return nV[1]end end end end end;return nil end;local function nX()local S={}for nV,L,bc in string.gmatch(ar.FamLead or"","(%a+)=([%d%.]+):(%d+)")do S[nV]={tonumber(L),tonumber(bc)}end;return S end;local function nY(S)local aE={}for nV,bb in pairs(S)do aE[#aE+1]=string.format("%s=%.4f:%d",nV,bb[1],bb[2])end;table.sort(aE)ar.FamLead=table.concat(aE," ")aI()end;local mO=ae.seedLead;function ae.seedLead(h)local nV=ae.familyOf(h)if nV and ar.AutoAdaptAll then local bb=nX()[nV]if bb and bb[2]>=2 then return K(bb[1],0,0.1)end end;return mO(h)end;local mP=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if ar.AutoAdaptAll and db and db.lead and not db.manual and not ae.FINAL[db.key]then local nV=ae.familyOf(db.key)local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if nV and dm then local dT=dm==5 and 0 or dm==4 and-1 or dm-5;if math.abs(dT)<=3 then local S=nX()local bb=S[nV]or{0,0}local dU=K(db.lead+dT*(ar.PeakBin or 0.014)*0.8,0,0.1)if bb[2]<2 then bb[1]=dU else bb[1]=bb[1]*0.8+dU*0.2 end;bb[2]=math.min(bb[2]+1,999)S[nV]=bb;nY(S)end end end;return mP(db,aZ,cZ)end end;do local nZ="6022"local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB then local n_={["Game recorder"]=true,["Shot recorder"]=true,["Game scanner"]=true,["Shot Lab"]=true}local o0={}for g,a5 in ipairs(nB.frame:GetChildren())do if a5:IsA("Frame")then for g,bb in ipairs(a5:GetDescendants())do if bb:IsA("TextLabel")and n_[bb.Text]then a5.Visible=false;o0[#o0+1]=a5;break end end end end;local u=aa.Page("Locked","L")aa.lockedPage=u;aa.lockedTools=o0;local n9=u.frame:FindFirstChildOfClass("UIListLayout")if n9 then n9.FillDirection=Enum.FillDirection.Horizontal;n9.Wraps=true;n9.Padding=UDim.new(0,8)end;local lF=""local lG=aa.Card(u,"Locked")lG.frame.Size=UDim2.new(0.5,-4,0,0)aa.Input(lG,"Code",{get=function()return lF end,set=function(L)lF=tostring(L or"")end},nil,"enter the code")local function o1()for cR,a5 in ipairs(o0)do a5.Parent=u.frame;a5.LayoutOrder=cR+1;a5.Size=UDim2.new(0.5,-4,0,0)a5.Visible=true end;lG.frame.Visible=false end;if ar.LockedUnlocked then task.defer(o1)end;aa.Button(lG,"Unlock",function()if string.gsub(lF,"%s","")==nZ then o1()ar.LockedUnlocked=true;aI()ao("Locked tab","Unlocked",3)else ao("Locked tab","Wrong code",3)end end,true)aa.Note(lG,"Everything in this tab is locked. Enter the code to open it.")end end;do local o2="2011"local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB then local o3=aa.Page("Owner","O")local o4=""local o5=aa.Card(o3,"Owner")aa.Input(o5,"Code",{get=function()return o4 end,set=function(L)o4=tostring(L or"")end},nil,"enter the code")local o6=aa.Card(o3,"Chat roles")o6.frame.Visible=false;local o7=C.roles or{}local o8,o9,oa,ob,oc=tostring(o7.owner or""),tostring(o7.devs or""),tostring(o7.mod1 or""),tostring(o7.mod2 or""),""aa.Input(o6,"Owner name (gold text, crown, #owner)",{get=function()return o8 end,set=function(L)o8=tostring(L or"")end},nil,"owner's player name")aa.Input(o6,"Owner code (only needed to set/change the Owner)",{get=function()return oc end,set=function(L)oc=tostring(L or"")end},nil,"required to change the Owner")aa.Input(o6,"Devs (comma separated player names)",{get=function()return o9 end,set=function(L)o9=tostring(L or"")end},nil,"name1, name2")aa.Input(o6,"Mod 1 name",{get=function()return oa end,set=function(L)oa=tostring(L or"")end},nil,"player name")aa.Input(o6,"Mod 2 name",{get=function()return ob end,set=function(L)ob=tostring(L or"")end},nil,"player name")aa.Button(o6,"Save and push to everyone",function()local du=C.roles or{}local od=du.owner or""if o8~=(du.owner or"")then if string.lower(string.gsub(oc,"%s",""))=="jay"then od=o8 else ao("Owner tab","Wrong owner code - the Owner was not changed. Devs/mods still saved.",4)end else od=o8 end;o8,oc=od,""local oe={owner=od,devs=o9,mod1=oa,mod2=ob,t=os.time()}C.roles=oe;if C.netPut then task.spawn(C.netPut,"roles",oe)end;ao("Owner tab","Roles saved and pushed - everyone's JHub Chat will show the badges.",4)end,true)aa.Note(o6,"Whoever is named here gets a badge next to their name in JHub Chat for everyone: the owner gets a gold crown and #owner, devs/mods get their own tag. Once set, a role stays until changed - changing the Owner needs the Owner code, not just the tab code.")if ar.OwnerUnlocked then task.defer(function()o5.frame.Visible=false;o6.frame.Visible=true end)end;aa.Button(o5,"Unlock",function()if string.gsub(o4,"%s","")==o2 then o5.frame.Visible=false;o6.frame.Visible=true;ar.OwnerUnlocked=true;aI()ao("Owner tab","Unlocked",3)else ao("Owner tab","Wrong code",3)end end,true)aa.Note(o5,"Owner-only tab. Enter the code to manage chat crown/dev/mod badges.")end end;do local hD=Color3.fromRGB(255,214,60)local function of(N,av)local bD=N:FindFirstChild("JHMark")if bD then return bD,N:FindFirstChild("JHMarkStroke")end;bD=Instance.new("TextLabel")bD.Name="JHMark"bD.BackgroundTransparency=1;bD.Size=UDim2.fromScale(1,1)bD.Font=Enum.Font.GothamBold;bD.TextSize=20;bD.Text=av;bD.TextColor3=hD;bD.Visible=false;bD.Parent=N;local d2=Instance.new("UIStroke")d2.Name="JHMarkStroke"d2.Color=hD;d2.Thickness=1.5;d2.Enabled=false;d2.Parent=N;local H=Instance.new("UICorner")H.CornerRadius=UDim.new(0,8)H.Parent=N;return bD,d2 end;local dP,og=of(im,"-")local dQ,j_=of(io,"X")local function fg(h0)dP.Visible,dQ.Visible=h0,h0;og.Enabled,j_.Enabled=h0,h0 end;im.Activated:Connect(function()task.wait(0.06)fg(jj==true)end)fg(false)end;do local oh={}function ae.adaptGain(h,dT)if not ar.SmartSteps then return 1 end;local aR=oh[h]if not aR then aR={}oh[h]=aR end;local bc=#aR;local dw,mA=aR[bc],aR[bc-1]local fc=1;if bc==0 then fc=1.5 elseif bc>=2 and math.abs(dT)>=3 and math.abs(dw)<=1 and math.abs(mA)<=1 then fc=0.3 elseif dw*dT<0 and math.abs(dw)>=0.5 and math.abs(dT)>=0.5 then fc=0.6 elseif dw*dT>0 and math.abs(dw)>=0.5 and math.abs(dT)>=0.5 then fc=1.4 end;if(ae.lastShotEx or 0)>=0.03 then fc=math.min(fc,0.3)end;aR[#aR+1]=dT;if#aR>6 then table.remove(aR,1)end;return fc end;local mP=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)local M=ae.auto and db and ae.auto[db.key]local dJ=M and M.hold;local aw=mP(db,aZ,cZ)if ar.SmartSteps and M and dJ and M.mode=="peak"and not db.manual and not ae.FINAL[db.key]then local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm then local dT=dm==5 and 0 or dm==4 and-1 or dm-5;local fc=ae.adaptGain(db.key,dT)local jI=M.hold;if jI~=dJ and fc~=1 then M.hold=K(dJ+(jI-dJ)*fc,0,0.1)ae.autoSave()end end end;return aw end end;do local oi={on=false,conns={},seenAnim=setmetatable({},{__mode="k"}),last={}}ae.ultra=oi;local oj=game:GetService("ContextActionService")local ok={"Action","BaseAnimation","GatherType","LastDribblePackage","Stamina","ServerVelocity","CanMove","meterOffset"}local function ol(bR)return bR.Character or workspace:FindFirstChild("Characters")and workspace.Characters:FindFirstChild(bR.Name)end;local function lv(H)local bK=H and H:FindFirstChild("Attributes")local bL=bK and bK:FindFirstChild("Basketball")return bL and bL.Value~=nil and true or false end;local function om(bR,H)local aR=H and H:FindFirstChildOfClass("Humanoid")local M=aR and(aR:FindFirstChildOfClass("Animator")or H:FindFirstChildWhichIsA("Animator",true))if not M or oi.seenAnim[M]then return end;oi.seenAnim[M]=true;oi.conns[#oi.conns+1]=M.AnimationPlayed:Connect(function(d7)local aV=""pcall(function()aV=string.gsub(tostring(d7.Animation.AnimationId),"rbxassetid://","")end)an.add("anim",string.format("%s%s %s id=%s len=%.2f prio=%s looped=%s",bR.Name,bR==u and" (me)"or"",tostring(d7.Name),aV,d7.Length or 0,tostring(d7.Priority),tostring(d7.Looped)))end)end;local function on()pcall(function()for bk,db in pairs(oj:GetAllBoundActionInfo())do local oo={}for g,S in ipairs(db.inputTypes or{})do oo[#oo+1]=tostring(S)end;an.add("control",string.format("bound action %s priority=%s stack=%s inputs=%s",tostring(bk),tostring(db.priority),tostring(db.stackOrder),table.concat(oo,",")))end end)pcall(function()local bc=0;for g,bb in ipairs(game:GetDescendants())do if bb:IsA("Animation")and tostring(bb.AnimationId)~=""then bc=bc+1;an.add("anim-list",bb:GetFullName().." = "..string.gsub(tostring(bb.AnimationId),"rbxassetid://",""))if bc>=700 then break end end end end)pcall(function()local bc=0;for g,bb in ipairs(game:GetService("ReplicatedStorage"):GetDescendants())do if bb:IsA("ValueBase")then bc=bc+1;an.add("setting",bb:GetFullName().." = "..tostring(bb.Value))if bc>=400 then break end end end;for a1,L in pairs(u:GetAttributes())do an.add("setting","player attribute "..a1 .." = "..tostring(L))end;for a1,L in pairs(workspace:GetAttributes())do an.add("setting","workspace attribute "..a1 .." = "..tostring(L))end;for a1,L in pairs(game:GetService("ReplicatedStorage"):GetAttributes())do an.add("setting","storage attribute "..a1 .." = "..tostring(L))end end)pcall(function()local bc=0;for g,bb in ipairs(workspace:GetDescendants())do if bb:IsA("BasePart")then local gi=string.lower(bb.Name)if string.find(gi,"hoop",1,true)or string.find(gi,"rim",1,true)or string.find(gi,"backboard",1,true)or string.find(gi,"goal",1,true)then bc=bc+1;an.add("court",string.format("%s at %.1f,%.1f,%.1f size %.1f,%.1f,%.1f",bb:GetFullName(),bb.Position.X,bb.Position.Y,bb.Position.Z,bb.Size.X,bb.Size.Y,bb.Size.Z))if bc>=40 then break end end end end end)an.add("build","walkspeed="..tostring(a7()and a7().WalkSpeed).." jump="..tostring(a7()and a7().JumpPower).." hipheight="..tostring(a7()and a7().HipHeight))end;local function op()local le=a6()for g,bR in ipairs(j:GetPlayers())do local H=ol(bR)local cU=H and(H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart)if cU then om(bR,H)local L=cU.AssemblyLinearVelocity;local aE={}for g,a1 in ipairs(ok)do local aB=H:GetAttribute(a1)if aB~=nil then aE[#aE+1]=a1 .."="..(type(aB)=="number"and string.format("%.2f",aB)or tostring(aB))end end;local aR=H:FindFirstChildOfClass("Humanoid")local d2="?"if aR then pcall(function()d2=tostring(aR:GetState())end)end;local gq=string.format("%s%s team=%s pos=%.1f,%.1f,%.1f vel=%.1f,%.1f,%.1f ball=%s state=%s %s%s",bR.Name,bR==u and" (me)"or"",tostring(bR.Team and bR.Team.Name),cU.Position.X,cU.Position.Y,cU.Position.Z,L.X,L.Y,L.Z,tostring(lv(H)),d2,table.concat(aE," "),le and bR~=u and string.format(" dist=%.1f",(cU.Position-le.Position).Magnitude)or"")if oi.last[bR]~=gq or tick()-(oi.lastT and oi.lastT[bR]or 0)>2 then oi.last[bR]=gq;oi.lastT=oi.lastT or{}oi.lastT[bR]=tick()an.add("player",gq)end end end;local N=aj.findBall()if N and N.Parent then local L=N.AssemblyLinearVelocity;an.add("ballpos",string.format("pos=%.1f,%.1f,%.1f vel=%.1f,%.1f,%.1f loose=%s",N.Position.X,N.Position.Y,N.Position.Z,L.X,L.Y,L.Z,tostring(aj.ballLoose())))end end;function oi.start()if oi.on then return end;oi.on=true;if not an.on then an.start()end;pcall(an.shotStart)ar.LabOn=true;pcall(on)oi.conns[#oi.conns+1]=l.InputBegan:Connect(function(cR,jZ)an.add("input",string.format("began %s %s gui=%s",tostring(cR.UserInputType),cR.KeyCode~=Enum.KeyCode.Unknown and tostring(cR.KeyCode)or"",tostring(jZ)))end)oi.conns[#oi.conns+1]=l.InputEnded:Connect(function(cR,jZ)an.add("input",string.format("ended %s %s",tostring(cR.UserInputType),cR.KeyCode~=Enum.KeyCode.Unknown and tostring(cR.KeyCode)or""))end)task.spawn(function()local bc=0;while oi.on and C.Running do pcall(op)bc=bc+1;if bc%8==0 then an.add("perf",string.format("fps=%d ping=%d ms",math.floor((C.FPS or 0)+0.5),math.floor((ae.pingNow and ae.pingNow()or 0)*1000+0.5)))end;task.wait(0.25)end end)ao("Ultra recorder","Recording everything",3)end;function oi.stop()if not oi.on then return end;oi.on=false;for g,H in ipairs(oi.conns)do pcall(function()H:Disconnect()end)end;oi.conns={}pcall(an.shotStop)pcall(an.stop)end;function oi.report()local aE={an.text()}if ae.lab and ae.lab.report then aE[#aE+1]="\n\n"..ae.lab.report()end;return table.concat(aE,"\n")end;local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB and aa.lockedTools then local H=aa.Card(nB,"Ultra Game Recorder")aa.Toggle(H,"Record everything","UltraOn",function(L)if L then oi.start()else oi.stop()end end)aa.Note(H,"Play normally with it on: dribble, shoot, guard, steal, block, rebound, dunk, use every button once. It records every player, animation, button, setting, ball movement and shot.")aa.Buttons(H,{{"Copy everything",function()local av=oi.report()pcall(function()if type(writefile)=="function"then writefile("JHub_ultra_report.txt",av)end end)if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Ultra recorder","Copied and saved as JHub_ultra_report.txt",4)else ao("Ultra recorder","Saved as JHub_ultra_report.txt in your executor folder",4)end end},{"Clear",function()pcall(an.clear)if ae.lab then ae.lab.rows,ae.lab.stats={},{}end end}})H.frame.Visible=false;table.insert(aa.lockedTools,1,H.frame)end;ar.UltraOn=false end;do local Bot=C.api.Bot;local function oq()local aR,aw=a7(),am.body()if not aR or not aw then return false end;local a9,ey=pcall(am.intent,aR,aw)return a9 and ey~=nil and ey.Magnitude>0.15 end;aj.heldT=0;task.spawn(function()while C.Running do task.wait(0.1)if not aj.ballLoose()then aj.heldT=tick()end end end)function aj.grabOk(N)local aw=am.body()if not aw or not N then return false end;if tick()-aj.heldT<0.9 then return false end;local ot=N.Position.Y>aw.Position.Y+5 or N.AssemblyLinearVelocity.Y<-8;if oq()and not ot then return false end;return true end;local ou=aj.getBall;function aj.getBall(bX)local N=aj.findBall()if not N or not aj.grabOk(N)then return false end;return ou(bX)end;local ov=Bot.reboundStep;function Bot.reboundStep(le,aw)local N=aj.findBall()if N and not aj.grabOk(N)then Bot.marker(nil)Bot.rbT=nil;return false end;return ov(le,aw)end;function aj.isGuarding()if ad.holding then return false end;local le=a6()if not le then return false end;for g,bR in ipairs(j:GetPlayers())do if bR~=u and not(u.Team and bR.Team==u.Team)then local H=bR.Character or workspace:FindFirstChild("Characters")and workspace.Characters:FindFirstChild(bR.Name)local bK=H and H:FindFirstChild("Attributes")local bL=bK and bK:FindFirstChild("Basketball")local cU=H and(H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart)if bL and bL.Value~=nil and cU and(cU.Position-le.Position).Magnitude<16 then return true end end end;return false end;local ow=ai.extraNow;function ai.extraNow()local fz=ow()if(ar.GuardSpeed or 0)>0 and aj.isGuarding()then fz=fz+(ai.gameWS or 16)*ar.GuardSpeed/100 end;return fz end;local ox;for g,bI in ipairs(aa.pages)do if bI.name=="Players"then ox=bI end end;if ox then local a3=aa.Card(ox,"Guard speed")aa.Slider(a3,"Extra speed while guarding","GuardSpeed",0,60,1,0,"%")aa.Button(a3,"Reset guard speed",function()aa.set("GuardSpeed",0)end)aa.Note(a3,"Only faster while you guard the player with the ball. Normal speed the rest of the time.")end;local oy={"bump","cross","steal","dunk","layup","shot","shoot","push","stun","stagger","knock","ragdoll","fall"}local oz=Bot.noStunStep;function Bot.noStunStep()if not ar.NoStun then return end;local H=a4()local f5=false;if H then for a1,L in pairs(H:GetAttributes())do local gj=string.lower(a1)if(string.find(gj,"stun",1,true)or string.find(gj,"ragdoll",1,true)or string.find(gj,"stagger",1,true))and L then f5=true;break end end end;if not f5 then local M=ah.animator;local a9,b4=pcall(function()return M and M:GetPlayingAnimationTracks()or{}end)if a9 then for g,d7 in ipairs(b4)do if ah.has("StunIds",ah.idOf(d7))or T(string.lower(ah.name(d7)or""),oy)then f5=true;break end end end end;if not f5 then return end;return oz()end;local jO,cX,jW;task.spawn(function()while C.Running do task.wait(0.1)local fg=ar.ContestShow;local H=a4()local aw=H and(H:FindFirstChild("HumanoidRootPart")or H.PrimaryPart)local oA,oB=pcall(aj.hasBall)local lv=fg and aw and oA and oB;if fg and aw and lv then local lT;local oC,ld=pcall(Bot.others)if oC and ld then for g,_ in ipairs(ld)do if not _.mate then local bb=W(_.pos-aw.Position).Magnitude;if not lT or bb<lT then lT=bb end end end end;if lT then if not jO then jO=Instance.new("BillboardGui")jO.Name="JHContest"jO.Size=UDim2.fromOffset(170,30)jO.StudsOffset=Vector3.new(0,4.2,0)jO.AlwaysOnTop=true;cX=Instance.new("TextLabel")cX.BackgroundTransparency=1;cX.Size=UDim2.fromScale(1,1)cX.Font=Enum.Font.GothamBold;cX.TextSize=20;cX.TextStrokeTransparency=0.3;cX.Parent=jO;pcall(function()jO.Parent=gethui and gethui()or game:GetService("CoreGui")end)end;if not jW or not jW.Parent then jW=Instance.new("Highlight")jW.Name="JHOpenness"jW.FillTransparency=0.65;jW.OutlineTransparency=0;pcall(function()jW.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end)end;jO.Adornee=H:FindFirstChild("Head")or aw;jO.Enabled=true;jW.Parent=H;local ig,fx;if lT>=6 then ig,fx="OPEN",Color3.fromRGB(70,235,110)elseif lT>=3.5 then ig,fx="SLIGHTLY OPEN",Color3.fromRGB(255,225,60)else ig,fx="CONTESTED",Color3.fromRGB(255,60,60)end;local eM=math.clamp(math.floor(100-lT*12),0,100)cX.Text=string.format("%s (%d%%)",ig,eM)cX.TextColor3=fx;jW.FillColor,jW.OutlineColor=fx,fx else if jO then jO.Enabled=false end;if jW then jW.Parent=nil end end else if jO then jO.Enabled=false end;if jW then jW.Parent=nil end end end end)end;do local o0=aa.lockedTools;if o0 and#o0>=2 then local oD=o0[1]local iH=0;for g,bN in ipairs(oD:GetChildren())do if bN:IsA("GuiObject")then iH=math.max(iH,bN.LayoutOrder)end end;local iO={frame=oD,order=iH}for cR=2,#o0 do local a5=o0[cR]local ap;for g,bb in ipairs(a5:GetDescendants())do if bb:IsA("TextLabel")and bb.Text~=""then ap=bb.Text;break end end;aa.Note(iO,"---- "..tostring(ap or"Tool").." ----","Text")for g,bN in ipairs(a5:GetChildren())do if bN:IsA("GuiObject")and bN.LayoutOrder>=2 then iO.order=iO.order+1;bN.LayoutOrder=iO.order;bN.Parent=oD end end;a5:Destroy()end;for cR=#o0,2,-1 do table.remove(o0,cR)end end end;do local Bot=C.api.Bot;local oE=Bot.guardStep;local oF,oG=0,0;function Bot.guardStep(le,ld,lf)if ar.AGMistakes then local bZ=tick()if bZ<oF then Bot.status="Guarding (a slip)"return true end;if bZ>oG then oG=bZ+1.2+math.random()*1.6;if math.random(100)<=(ar.AGMistakeAmt or 15)then oF=bZ+0.25+math.random()*0.45 end end end;return oE(le,ld,lf)end;function Bot.blockStep(ld,le)if not ar.AB then return end;local bZ=tick()for g,_ in ipairs(ld)do if not _.mate then local li=Bot.shotSeen[_.c]Bot.shotSeen[_.c]=_.shooting;if _.shooting and not li and bZ-Bot.blockT>0.9 then local bW=W(_.pos-le).Magnitude;if bW<=ar.ABRange and math.random(100)<=ar.ABChance then Bot.blockT=bZ;local H=_.c;task.delay(ar.ABDelay*(0.85+math.random()*0.3),function()if not C.Running then return end;if ar.ABRecheck~=false and H:GetAttribute("Action")~="Shooting"then return end;Bot.doJump()end)end end end end end;local function oH(U,h)if h and h~=""then Bot.press(h,0.1,U)else local bd=Bot.findBtn(U)if bd then task.spawn(function()ac.fireGui(bd,true,true)task.wait(0.1)ac.fireGui(bd,false,true)end)end end end;function Bot.stealStep(ld,le)if not ar.ASteal or aj.hasBall()then return end;local bZ=tick()if bZ-(Bot.stealT or 0)<1.6 then return end;for g,_ in ipairs(ld)do if _.ball and not _.mate then local nr=_.c:GetAttribute("Action")local bb=W(_.pos-le).Magnitude;if bb<=(ar.ASRange or 5)and nr~="Dribbling"and nr~="Shooting"and nr~="Stealing"and math.random(100)<=(ar.ASChance or 60)then Bot.stealT=bZ;task.delay((ar.ASReact or 0.15)*(0.8+math.random()*0.4),function()if C.Running then oH({"steal","reach"},ar.ASKey)end end)return end end end end;local oI=Bot.think;function Bot.think()oI()if ar.ASteal then pcall(function()local aw=am.body()if aw and not Bot.userActive()then Bot.stealStep(Bot.others(),aw.Position)end end)end end;local jZ,by;for g,bI in ipairs(aa.pages)do if bI.name=="Auto Guard"then jZ=bI end;if bI.name=="Auto Grind"then by=bI end end;if jZ then local kA=aa.Card(jZ,"Guard mistakes")aa.Toggle(kA,"Make mistakes sometimes","AGMistakes")aa.Slider(kA,"How often","AGMistakeAmt",0,60,1,0,"%")local kC=aa.Card(jZ,"Block pump fake check")aa.Toggle(kC,"Only jump if he is still shooting","ABRecheck")aa.Note(kC,"Block reaction time and block distance are the sliders in the Auto block card.")local kE=aa.Card(jZ,"Auto steal")aa.Toggle(kE,"Auto steal (only when he is not dribbling)","ASteal")aa.Slider(kE,"Steal distance","ASRange",3,9,0.5,1," studs")aa.Slider(kE,"Steal chance","ASChance",10,100,5,0,"%")aa.Slider(kE,"Steal reaction time","ASReact",0,0.5,0.01,2,"s")aa.Keybind(kE,"Steal key (empty uses the on-screen button)",function()return ar.ASKey end,function(L)ar.ASKey=L end)if C.AGContentFrames then kA.frame.Visible=false;kC.frame.Visible=false;kE.frame.Visible=false;table.insert(C.AGContentFrames,kA.frame)table.insert(C.AGContentFrames,kC.frame)table.insert(C.AGContentFrames,kE.frame)end end;if by and aa.lockedTools then for g,a5 in ipairs(by.frame:GetChildren())do if a5:IsA("Frame")then a5.Visible=false;table.insert(aa.lockedTools,a5)end end end end;do local oJ=6;local oK={"None","Crossover 1","Crossover 2","BehindBack 1","BehindBack 3","DoubleBehindBack 1","Spin 1","Spin 2","Spin 3","HalfSpin 1","StepBack 1","StepBack 2","Retreat StepBack 1","Hesitation 1","Drive Hesitation 1","Retreat Hesitation 1","Misdirection Cross","SwitchHand 1","Sidestep 1","Eurostep 1","Hopstep 1","PowerHopstep 1"}local oL={}local function oM(c4)local R={}for cR=1,c4.n do local L=c4[cR]local S=typeof(L)if S=="string"then R[cR]="s:"..L elseif S=="number"then R[cR]="n:"..tostring(L)elseif S=="boolean"then R[cR]="b:"..tostring(L)elseif S=="Vector3"then R[cR]="v:"else R[cR]="x:"end end;return table.concat(R,"|")end;local function oN(av)if not av or av==""then return nil end;local c4,bc={},0;for en in string.gmatch(av.."|","(.-)|")do bc=bc+1;local a1,L=string.sub(en,1,1),string.sub(en,3)if a1=="s"then c4[bc]=L elseif a1=="n"then c4[bc]=tonumber(L)elseif a1=="b"then c4[bc]=L=="true"elseif a1=="v"then c4[bc]="DIR"else c4[bc]=nil end end;c4.n=bc;return c4 end;for oO in string.gmatch(ar.BindLib or"","([^;]+);")do local bk,av=string.match(oO,"^(.-)@@(.*)$")if bk then oL[bk]=oN(av)end end;local function oP()local aE={}for bk,c4 in pairs(oL)do aE[#aE+1]=bk.."@@"..oM(c4)..";"end;ar.BindLib=table.concat(aE)aI()end;C.bindLib,C.bindSer,C.bindDeser,C.bindSaveLib=oL,oM,oN,oP;local function oQ()local bb=game:GetService("ReplicatedStorage"):FindFirstChild("Dribble",true)return bb and bb:IsA("RemoteEvent")and bb or am.lastDribbleRemote end;local function oR(oS)local bk=ar["BindMove"..oS]if not bk or bk=="None"then return end;local S,oT=oL[bk],oQ()if not S then ao("Binds","Do "..bk.." once with the game's own button first, so the script learns it",4)return end;if not oT then return end;local aR,aw=a7(),am.body()local cd=Vector3.new(0,0,1)if aR and aw then local a9,ey=pcall(am.intent,aR,aw)if a9 and ey and ey.Magnitude>0.1 then cd=W(ey)else cd=W(aw.CFrame.LookVector)end end;local c4={}for cR=1,S.n do c4[cR]=S[cR]=="DIR"and cd or S[cR]end;am.selfFire=true;pcall(function()oT:FireServer(table.unpack(c4,1,S.n))end)am.selfFire=false end;local oU=am.onDribble;function am.onDribble(c4)local copy=table.pack(table.unpack(c4,1,c4.n))task.spawn(function()task.wait(0.12)local H=a4()local oV=H and H:GetAttribute("LastDribblePackage")local bk=type(oV)=="string"and(string.match(oV,"^(.-)%s+[LR]$")or oV)or oV;if type(bk)=="string"and bk~=""and oM(oL[bk]or{n=0})~=oM(copy)then oL[bk]=copy;oP()if C.onBindLearned then task.spawn(C.onBindLearned,bk,copy)end end end)return oU(c4)end;l.InputBegan:Connect(function(cR,jZ)local eU=cR.UserInputType;local oW=eU==Enum.UserInputType.Keyboard or eU==Enum.UserInputType.Gamepad1 or eU==Enum.UserInputType.Gamepad2 or eU==Enum.UserInputType.Gamepad3 or eU==Enum.UserInputType.Gamepad4;if not oW then return end;if jZ and eU==Enum.UserInputType.Keyboard then return end;for oS=1,oJ do local a1=ar["BindKey"..oS]if a1 and a1~=""and a1==cR.KeyCode.Name then task.spawn(oR,oS)return end end end)local b9=aa.Page("Binds","K")local n9=b9.frame:FindFirstChildOfClass("UIListLayout")if n9 then n9.FillDirection=Enum.FillDirection.Horizontal;n9.Wraps=true;n9.Padding=UDim.new(0,8)end;local db=aa.Card(b9,"How binds work")db.frame.Size=UDim2.new(1,-4,0,0)aa.Note(db,"Pick a dribble move for each bind and a key or controller button. The first time you do a move with the game's own button, the script learns it. After that your key or controller button does that move, and the game picks left or right from the hand the ball is in.")aa.Button(db,"Reset all binds",function()for oS=1,oJ do ar["BindMove"..oS],ar["BindKey"..oS],ar["BindArgs"..oS]="None","",""end;aI()aa.refreshAll()ao("Binds","All 6 binds reset.",3)end)for oS=1,oJ do local H=aa.Card(b9,"Bind "..oS)H.frame.Size=UDim2.new(0.5,-4,0,0)aa.Dropdown(H,"Move","BindMove"..oS,oK)aa.Keybind(H,"Key",function()return ar["BindKey"..oS]end,function(L)ar["BindKey"..oS]=L end)aa.Button(H,"X - clear this bind",function()ar["BindMove"..oS],ar["BindKey"..oS],ar["BindArgs"..oS]="None","",""aI()aa.refreshAll()ao("Binds","Bind "..oS.." cleared.",2)end)end end;do local Bot=C.api.Bot;local oX;local oY=tick()local oZ=Bot.move;function Bot.move(cd,kZ)local bZ=tick()if ar.AGHuman and bZ-(Bot.guardingNow or 0)<0.15 and cd then local ec=math.min(bZ-oY,0.2)local o_=0.18+0.35*(ar.AGHumanAmt or 50)/100;oX=oX and oX:Lerp(cd,math.clamp(ec/o_,0,1))or cd;oY=bZ;return oZ(oX,math.min(kZ or 1,1.02))end;oX=nil;oY=bZ;return oZ(cd,kZ)end;local oE=Bot.guardStep;function Bot.guardStep(le,ld,lf)local a9=oE(le,ld,lf)if a9 and Bot.dbg and Bot.dbg.dist and Bot.dbg.dist<3 then Bot.guardingNow=tick()end;return a9 end;if(ar.AGDist or 0)<4 then ar.AGDist=4.5 end;if(ar.AGReact or 0)<0.15 then ar.AGReact=0.2 end;if aa.lockedTools then local fS=aa.lockedPage;local by;for g,bI in ipairs(aa.pages)do if bI.name=="Auto Guard"then by=bI end end;if by then local H=aa.Card(by,"Auto play")local g,iK=aa.Button(H,ar.AP and"Auto play: ON (tap to stop)"or"Auto play: OFF (tap to start)",function()Bot.setAP(not ar.AP)end,true)Bot.apLabel=iK;aa.Dropdown(H,"Build","APBuild",{"Big","Small","Wing","Shooter"})aa.Note(H,"Turns on Auto Green, dribbles to get open, shoots open shots, takes layups and dunks, follows the shot for the rebound and guards when the other team has the ball. Touch the stick and it hands the game back to you.")table.insert(aa.lockedTools,2,H.frame)H.frame.Visible=false end end end;do local Bot=C.api.Bot;function Bot.doJump()local bd=Bot.findBtn({"jump","dunk","trampoline"})if bd then task.spawn(function()ac.fireGui(bd,true,true)task.wait(0.15)ac.fireGui(bd,false,true)end)else Bot.press(ar.ABKey or"Space",0.18)local aR=a7()if aR then pcall(function()aR.Jump=true end)end end end end;do local Bot=C.api.Bot;local p0=Bot.guardStep;function Bot.guardStep(le,ld,lf)if ar.AGOnlyBall~=false then local lw;for g,_ in ipairs(ld)do if _.ball and not _.mate then lw=_ end end;if not lw then Bot.setGuardHold(false)return false end;lf="Ball handler"end;return p0(le,ld,lf)end end;do local p1,p2,p3="jaydendagoat2","jayhubv1","claude/claudechud-8cord-executor-x86h7a"local function http(aY)return game:HttpGet(aY)end;local function p4()local p5=string.gsub(p3,"/","%%2F")local a9,a_=pcall(http,"https://api.github.com/repos/"..p1 .."/"..p2 .."/commits/"..p5)if not a9 or type(a_)~="string"then return nil end;return string.match(a_,'"sha"%s*:%s*"(%x+)"')end;local function p6()local p7=p4()local aY=p7 and"https://raw.githubusercontent.com/"..p1 .."/"..p2 .."/"..p7 .."/executor/JHubV1_Glass.lua"or"https://raw.githubusercontent.com/"..p1 .."/"..p2 .."/"..p3 .."/executor/JHubV1_Glass.lua?v="..tostring(os.time())local a9,f0=pcall(http,aY)if not a9 or type(f0)~="string"or#f0<10000 then return nil end;return f0,string.match(f0,'local VERSION = "(v[%d%.]+)')end;local bQ=string.match(tostring(B),"^(v[%d%.]+)")or tostring(B)local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB then local H=aa.Card(nB,"Updates")local du=aa.Stat(H,"This version")du.Text=bQ;local p8=aa.Stat(H,"Newest version")p8.Text="tap Check"local b7=false;aa.Buttons(H,{{"Check",function()if b7 then return end;b7=true;p8.Text="checking..."local f0,p9=p6()p8.Text=p9 or"could not reach GitHub"b7=false end},{"Update now",function()if b7 then return end;b7=true;p8.Text="downloading..."local f0,p9=p6()if not f0 then p8.Text="could not reach GitHub"b7=false;return end;p8.Text=p9 or"?"if p9==bQ then ao("Update","You already have the newest version ("..bQ..")",4)b7=false;return end;local G=loadstring(f0)if not G then ao("Update","The download could not be read",4)b7=false;return end;ao("Update","Updating to "..tostring(p9).."...",3)pcall(C.Unload)task.defer(G)end}})aa.Note(H,"Loads the newest version from GitHub and restarts JHub. Your settings stay.")end end;do local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB and ae.lab and ae.lab.report then local H=aa.Card(nB,"Problem report")aa.Button(H,"Copy my shot report",function()local av=ae.lab.report()if type(setclipboard)=="function"then pcall(setclipboard,av)ao("Report","Copied. Paste it in the Discord.",4)else pcall(function()if type(writefile)=="function"then writefile("JHub_shot_report.txt",av)end end)ao("Report","Saved as JHub_shot_report.txt in your executor folder",5)end end)aa.Note(H,"Shoot about 10 times, then tap this and paste the result in the Discord. It lists each shot, the result, your ping and FPS.")end end;do local oD=aa.lockedTools and aa.lockedTools[1]if oD then local iH=0;for g,bN in ipairs(oD:GetChildren())do if bN:IsA("GuiObject")then iH=math.max(iH,bN.LayoutOrder)end end;local iO={frame=oD,order=iH}local pa=game:GetService("ReplicatedStorage")local function pb(pc,av,nA)pcall(function()if type(writefile)=="function"then writefile(pc,av)end end)local pd=av;if#pd>900000 then pd=string.sub(pd,1,900000).."\n-- (cut here, the rest is in the file "..pc..")"end;if type(setclipboard)=="function"then pcall(setclipboard,pd)end;ao("Dex",string.format("%s: %.0f KB, saved as %s%s",nA,#av/1024,pc,type(setclipboard)=="function"and" and copied"or""),6)end;local function pe(S,gr,R,gN,bE,d5)if bE[S]or gr>7 or#R>=d5 then return end;bE[S]=true;local bG={}for a1 in pairs(S)do bG[#bG+1]=a1 end;pcall(table.sort,bG,function(M,N)return tostring(M)<tostring(N)end)for g,a1 in ipairs(bG)do if#R>=d5 then R[#R+1]=gN.."... (cut)"return end;local L=S[a1]local h3=typeof(L)if h3=="table"then R[#R+1]=gN..tostring(a1).." = {"pe(L,gr+1,R,gN.."  ",bE,d5)R[#R+1]=gN.."}"elseif h3=="function"then R[#R+1]=gN..tostring(a1).." = function"else R[#R+1]=gN..tostring(a1).." = "..an.fmt(L,0)end end end;local function pf()local R={"== DEX TREE "..tostring(B).." | place "..string.format("%.0f",game.PlaceId).." | "..os.date("%Y-%m-%d %H:%M:%S")}local cW=0;local function eB(cB,gr,pg)if gr>pg then return end;for g,H in ipairs(cB:GetChildren())do if H~=aS then local gq=string.rep("  ",gr)..H.Name.." ["..H.ClassName.."]"if H:IsA("ValueBase")then gq=gq.." = "..tostring(H.Value)end;if H:IsA("Animation")then gq=gq.." id="..string.gsub(tostring(H.AnimationId),"rbxassetid://","")end;if H:IsA("Sound")then gq=gq.." id="..tostring(H.SoundId)end;if H:IsA("RemoteEvent")or H:IsA("RemoteFunction")then gq=gq.." <remote>"end;local bc=0;for a1,L in pairs(H:GetAttributes())do bc=bc+1;if bc<=6 then gq=gq.." @"..a1 .."="..tostring(L)end end;R[#R+1]=gq;cW=cW+1;if cW%400==0 then task.wait()end;eB(H,gr+1,pg)end end end;for g,ph in ipairs({{pa,16},{game:GetService("ReplicatedFirst"),6},{game:GetService("StarterPlayer"),8},{game:GetService("StarterGui"),8},{u:FindFirstChild("PlayerGui"),10},{workspace,3}})do if ph[1]then R[#R+1]=""R[#R+1]="-- "..ph[1]:GetFullName()pcall(eB,ph[1],1,ph[2])end end;return table.concat(R,"\n")end;local function pi(pj,ap)local R={"== "..ap.." "..tostring(B).." | place "..string.format("%.0f",game.PlaceId).." | "..os.date("%Y-%m-%d %H:%M:%S")}local pk,hh={},{}pcall(function()for g,bJ in ipairs(getloadedmodules())do local a9,au=pcall(al.pathOf,bJ)if a9 and string.find(au,pj,1,true)and not pk[bJ]then pk[bJ]=true;hh[#hh+1]={m=bJ,path=au}end end end)for g,bJ in ipairs(pa:GetDescendants())do if bJ:IsA("ModuleScript")and not pk[bJ]then local au=bJ:GetFullName()if string.find(string.gsub(au,"%.","/"),pj,1,true)then pk[bJ]=true;hh[#hh+1]={m=bJ,path=au}end end end;table.sort(hh,function(M,N)return M.path<N.path end)for cR,fz in ipairs(hh)do if cR%5==0 then task.wait()end;R[#R+1]=""R[#R+1]="-- "..fz.path;local a9,aZ=pcall(require,fz.m)if a9 and type(aZ)=="table"then pe(aZ,0,R,"  ",{},#R+2500)elseif a9 then R[#R+1]="  = "..tostring(aZ)else R[#R+1]="  (could not be read)"end end;return table.concat(R,"\n"),#hh end;ae.dexConfigText=pi;aa.Note(iO,"---- Dex and remote spy ----","Text")aa.Buttons(iO,{{"Dex: game tree",function()ao("Dex","Reading the whole game. This takes up to a minute.",5)task.spawn(function()pb("JHub_dex_tree.txt",pf(),"Game tree")end)end},{"Dex: every jumpshot",function()ao("Dex","Reading every shot setting.",4)task.spawn(function()local av,bc=pi("Config/Game/Shooting","SHOT SETTINGS (every jumpshot)")pb("JHub_dex_shots.txt",av,bc.." shot modules")end)end}})aa.Buttons(iO,{{"Dex: all config",function()ao("Dex","Reading every config module.",4)task.spawn(function()local av,bc=pi("Config","ALL GAME CONFIG")pb("JHub_dex_config.txt",av,bc.." config modules")end)end},{"Remote spy",function()local av=an.spyText()pb("JHub_remote_spy.txt",av,"Remote spy")end}})C.ctrlLog=C.ctrlLog or{}aa.Toggle(iO,"Record controller inputs","CtrlSpyOn",function(L)if L then C.ctrlLog={}ao("Controller spy","Press every button, stick and trigger on your controller now.",5)else ao("Controller spy","Stopped. Tap Copy controller log to get the report.",4)end end)aa.Buttons(iO,{{"Copy controller log",function()local I=C.ctrlLog or{}local cW={"== CONTROLLER INPUTS "..tostring(B).." | "..os.date("%Y-%m-%d %H:%M:%S")}if#I==0 then cW[#cW+1]="(nothing recorded yet, turn Record controller inputs on and press every button, stick and trigger)"else for g,bD in ipairs(I)do cW[#cW+1]=bD end end;pb("JHub_controller_log.txt",table.concat(cW,"\n"),"Controller log")end}})local pl={}local function pm(S)return S==Enum.UserInputType.Gamepad1 or S==Enum.UserInputType.Gamepad2 or S==Enum.UserInputType.Gamepad3 or S==Enum.UserInputType.Gamepad4 end;E(l.InputBegan,function(cR,jZ)if not ar.CtrlSpyOn or not pm(cR.UserInputType)then return end;table.insert(C.ctrlLog,string.format("%s  PRESS  %s  (%s)",os.date("%H:%M:%S"),cR.KeyCode.Name,cR.UserInputType.Name))if#C.ctrlLog>300 then table.remove(C.ctrlLog,1)end end)E(l.InputChanged,function(cR,jZ)if not ar.CtrlSpyOn or not pm(cR.UserInputType)then return end;local bx=cR.Position;if bx.Magnitude<0.08 then return end;local bk=cR.KeyCode.Name;local bZ=tick()if pl[bk]and bZ-pl[bk]<0.4 then return end;pl[bk]=bZ;table.insert(C.ctrlLog,string.format("%s  AXIS  %s  (%s)  x=%.2f y=%.2f z=%.2f",os.date("%H:%M:%S"),bk,cR.UserInputType.Name,bx.X,bx.Y,bx.Z))if#C.ctrlLog>300 then table.remove(C.ctrlLog,1)end end)aa.Buttons(iO,{{"Copy control map (keyboard + controller + mobile)",function()local oj=game:GetService("ContextActionService")local gL,pn=pcall(function()return oj:GetAllBoundActionInfo()end)local R={"== CONTROL MAP "..tostring(B).." | place "..tostring(game.PlaceId).." | "..os.date("%Y-%m-%d %H:%M:%S")}if gL and pn then local gh={}for bk in pairs(pn)do gh[#gh+1]=bk end;table.sort(gh)local b9=u:FindFirstChild("PlayerGui")for g,bk in ipairs(gh)do local bb=pn[bk]local bG,po,pp={},{},false;for g,S in ipairs(bb.inputTypes or{})do local bv,iv=pcall(function()return S.EnumType end)if bv and iv==Enum.KeyCode then if string.find(S.Name,"^Button")or string.find(S.Name,"^DPad")or string.find(S.Name,"^Thumbstick")then po[#po+1]=S.Name else bG[#bG+1]=S.Name end elseif bv and iv==Enum.UserInputType and S==Enum.UserInputType.Touch then pp=true end end;local bd;if b9 then for g,pq in ipairs(b9:GetDescendants())do if pq:IsA("GuiButton")then local bc=string.lower(pq.Name.." "..(pq:IsA("TextButton")and pq.Text or""))if string.find(bc,string.lower(bk),1,true)then bd=pq:GetFullName()break end end end end;R[#R+1]=string.format("%s | keyboard: %s | controller: %s | touch flag: %s | on-screen button: %s",bk,#bG>0 and table.concat(bG,",")or"none",#po>0 and table.concat(po,",")or"none",tostring(pp),bd or"not found")end else R[#R+1]="(could not read the game's bound actions)"end;pb("JHub_control_map.txt",table.concat(R,"\n"),"Control map")end}})aa.Buttons(iO,{{"Find every dribble move (scan the game's own data)",function()ao("Dribble scan","Reading the game's own dribble, combo and gather data. This takes a moment.",5)task.spawn(function()local aE={}for g,pr in ipairs({"Dribbl","Combo","Gather","Move"})do local bv,av=pcall(pi,pr,"DRIBBLE DATA ("..pr..")")if bv and av then aE[#aE+1]=av end;task.wait()end;local ps=table.concat(aE,"\n\n")pb("JHub_dex_dribble.txt",ps,"Dribble move data")ao("Dribble scan","Done. Paste JHub_dex_dribble.txt to me so I can build real auto-fill from whatever the game actually stores.",7)end)end}})end end;do local oD=aa.lockedTools and aa.lockedTools[1]if oD then local iH=0;for g,bN in ipairs(oD:GetChildren())do if bN:IsA("GuiObject")then iH=math.max(iH,bN.LayoutOrder)end end;local iO={frame=oD,order=iH}local function pb(pc,av,nA)pcall(function()if type(writefile)=="function"then writefile(pc,av)end end)local pd=av;if#pd>900000 then pd=string.sub(pd,1,900000).."\n-- (cut here, the rest is in the file "..pc..")"end;if type(setclipboard)=="function"then pcall(setclipboard,pd)end;ao("Dex",string.format("%s: %.0f KB, saved as %s%s",nA,#av/1024,pc,type(setclipboard)=="function"and" and copied"or""),6)end;C.guardLog=C.guardLog or{}local function pt()local aw=am.body()if not aw then return nil end;local bO,bP;for g,bR in ipairs(j:GetPlayers())do if bR~=u and bR.Character then local a6=bR.Character:FindFirstChild("HumanoidRootPart")if a6 then local bb=W(a6.Position-aw.Position).Magnitude;if not bP or bb<bP then bO,bP=bR,bb end end end end;return bO,bP end;local pu=0;E(k.Heartbeat,function()if not ar.GuardSpyOn then return end;local bZ=tick()if bZ-pu<0.5 then return end;pu=bZ;local aR=a7()if not aR then return end;local g,bW=pt()local lR={}for g,d7 in ipairs(aR:GetPlayingAnimationTracks())do local aV=d7.Animation and d7.Animation.AnimationId or"?"lR[#lR+1]=string.format("%s(%s,%s)",aV,d7.Priority.Name,tostring(d7.Looped))end;table.insert(C.guardLog,string.format("%s  state=%s  holdingG=%s  moveDir=%.2f  dist=%.1f  guarding=%s  tracks=%s",os.date("%H:%M:%S"),aR:GetState().Name,tostring(a4()and a4():GetAttribute("HoldingG")),aR.MoveDirection.Magnitude,bW or-1,tostring(Bot.status or""),#lR>0 and table.concat(lR," | ")or"none"))if#C.guardLog>300 then table.remove(C.guardLog,1)end end)aa.Toggle(iO,"Record guarding","GuardSpyOn",function(L)if L then C.guardLog={}ao("Guard recorder","Recording. Play normally, guard someone for a bit, then tap Copy guard log.",5)else ao("Guard recorder","Stopped. Tap Copy guard log to get the report.",4)end end)aa.Buttons(iO,{{"Copy guard log",function()local I=C.guardLog or{}local cW={"== GUARD RECORDER "..tostring(B).." | "..os.date("%Y-%m-%d %H:%M:%S"),"Learned walk animation id: "..tostring(ar.WalkAnimId~=""and ar.WalkAnimId or"(not learned yet, walk for real once)"),"Learned guard/slide animation id: "..tostring(ar.GuardAnimId~=""and ar.GuardAnimId or"(not learned yet, guard someone for real once)"),string.format("Guard settings: dist=%s react=%s predict=%s range=%s guardSpeed=%s",tostring(ar.AGDist),tostring(ar.AGReact),tostring(ar.AGPredict),tostring(ar.AGRange),tostring(ar.GuardSpeed)),""}if#I==0 then cW[#cW+1]="(nothing recorded yet, turn Record guarding on and guard someone for a bit)"else for g,bD in ipairs(I)do cW[#cW+1]=bD end end;pb("JHub_guard_log.txt",table.concat(cW,"\n"),"Guard log")end}})end end;do local function pv(M,N)local S={tostring(M),tostring(N)}table.sort(S)return S[1].."+"..S[2]end;function ae.masteryText()local dp=ae.idName or{}local pw={}for aV,bk in pairs(dp)do pw[bk]=aV end;pcall(ae.autoLoad)local cW={"== JUMPSHOT MASTERY "..tostring(B).." | "..os.date("%Y-%m-%d %H:%M:%S"),"","-- every jumpshot in the game: covered? | key | learned lead | shots | perfect good early late --"}local px,hn=0,0;local function py(h)local M=ae.auto and ae.auto[h]local P=ae.lab and ae.lab.stats and ae.lab.stats[h]local dN=ae.FINAL and ae.FINAL[h]return M,P,dN end;for bc=1,16 do for g,fY in ipairs({"L","R"})do local cH,pz=pw["Jumpshot"..bc..fY.."Base"],pw["Jumpshot"..bc..fY.."Release"]if cH and pz then hn=hn+1;local h=pv(cH,pz)local M,P,dN=py(h)local jz=M~=nil or P~=nil or dN~=nil;if jz then px=px+1 end;cW[#cW+1]=string.format("Jumpshot %d%s | %s | key=%s | lead=%s | shots=%s | %s",bc,fY,jz and"COVERED"or"not shot yet",h,M and string.format("%.4f%s",M.hold or 0,M.locked and" (locked)"or"")or(dN and string.format("built-in %.3f",dN)or"-"),P and tostring(P.n)or"0",P and string.format("%d %d %d %d",P.perfect,P.good,P.early,P.late)or"-")end end end;cW[#cW+1]=""cW[#cW+1]=string.format("coverage: %d of %d jumpshots have been shot or learned",px,hn)cW[#cW+1]=""cW[#cW+1]="-- every other shot type that was shot or learned --"for h,M in pairs(ae.auto or{})do cW[#cW+1]=string.format("%s | key=%s | lead=%.4f%s",tostring(ae.nameFor and ae.nameFor(h)or h),h,M.hold or 0,M.locked and" (locked)"or"")end;cW[#cW+1]=""cW[#cW+1]="-- learned timings in the script's own format (paste this to the developer) --"cW[#cW+1]=tostring(ar.AutoTimes or"")cW[#cW+1]="-- built-in shot adjustments --"cW[#cW+1]=tostring(ar.FinalAdj or"")cW[#cW+1]="-- shot family timings --"cW[#cW+1]=tostring(ar.FamLead or"")return table.concat(cW,"\n")end;local pA=ae.ultra;if pA and pA.report then local mA=pA.report;function pA.report()local aE={mA(),"\n\n"..ae.masteryText()}if ae.dexConfigText then local a9,av=pcall(ae.dexConfigText,"Config/Game/Shooting","SHOT SETTINGS (every jumpshot)")aE[#aE+1]="\n\n"..(a9 and av or"== shot settings could not be read")end;return table.concat(aE)end end;local oD=aa.lockedTools and aa.lockedTools[1]if oD then local iH=0;for g,bN in ipairs(oD:GetChildren())do if bN:IsA("GuiObject")then iH=math.max(iH,bN.LayoutOrder)end end;local iO={frame=oD,order=iH}aa.Note(iO,"---- Jumpshot mastery ----","Text")aa.Buttons(iO,{{"Copy jumpshot mastery",function()local av=ae.masteryText()pcall(function()if type(writefile)=="function"then writefile("JHub_mastery.txt",av)end end)if type(setclipboard)=="function"then pcall(setclipboard,av)end;ao("Mastery","Copied and saved as JHub_mastery.txt",4)end}})aa.Note(iO,"Lists all 16 jumpshots (left and right): which ones you have shot, what was learned for each, and which still need a few shots. Copy everything now also includes this and every shot setting the game stores.")end end;do ae.CFG={[1]={1.8,0},[2]={1.045,0},[3]={1.065,0},[4]={0.875,0},[5]={1,0.05},[6]={1,0.05},[7]={1,0.05},[8]={0.95,0.05},[9]={0.95,0},[10]={0.95,0.05},[11]={0.8,0.05},[12]={0.8,0.05},[13]={1,0.05},[14]={0.825,0.05},[15]={1.07,0.05},[16]={0.9,0}}local function pB(h)for aV in string.gmatch(tostring(h),"%d+")do local gi=ae.idName and ae.idName[aV]local bc=gi and string.match(gi,"^Jumpshot(%d+)[RL]")if bc then return tonumber(bc)end end end;ae.jumpNum=pB;local pC=ae.adaptGain;function ae.adaptGain(h,dT)local a3=pC(h,dT)local bc=pB(h)local H=bc and ae.CFG[bc]if H and H[2]>0 and a3>1 then a3=1 end;return a3 end;local pD=ae.masteryText;if pD then function ae.masteryText()local S=pD()local _={"","GAME SETTINGS PER JUMPSHOT (speed / random timing)"}for cR=1,16 do local H=ae.CFG[cR]_[#_+1]=string.format("  Jumpshot %d: speed %.3f  random %s",cR,H[1],H[2]>0 and"+-0.05"or"none")end;return S.."\n"..table.concat(_,"\n")end end end;do local pE=ae.seedLead;local function pF()return a4()end;local pG,pH=70,0;local function pI()local a9,bI=pcall(function()return j.LocalPlayer:GetNetworkPing()*1000 end)return a9 and bI or nil end;local function pJ(bI)pH=math.min(pH+1,40)pG=pG+(bI-pG)/pH;return pG end;local pK=ae.seedLead;function ae.seedLead(h)local L=pK(h)if ae.FINAL[h]then return L end;local bI=pI()if bI then local cH=pJ(bI)L=K(L+K((bI-cH)*0.00004,-0.004,0.008),0,0.1)end;return L end;local mS=ae.seedLead;function ae.seedLead(h)local L=mS(h)if ae.FINAL[h]then return L end;local H=pF()local d2=H and H:GetAttribute("Stamina")if type(d2)=="number"and d2<35 then L=K(L+(35-d2)*0.00006,0,0.1)end;return L end;local pL,pM={},{}local function pN()local H=pF()local L=H and H:GetAttribute("ServerVelocity")return typeof(L)=="Vector3"and L.Magnitude>3 end;local n1=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)local aw=n1(db,aZ,cZ)if db and db.lead and not db.manual and not ae.FINAL[db.key]then local nV=ae.familyOf(db.key)if nV then local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm then local dT=dm==5 and 0 or dm==4 and-1 or dm-5;if math.abs(dT)<=3 then local pO=(pN()and"m:"or"s:")..nV;local bc=pM[pO]or 0;local dU=K(db.lead+dT*(ar.PeakBin or 0.014)*0.8,0,0.1)pL[pO]=bc<2 and dU or pL[pO]*0.85+dU*0.15;pM[pO]=math.min(bc+1,999)end end end end;return aw end;local n0=ae.seedLead;function ae.seedLead(h)local L=n0(h)if ae.FINAL[h]then return L end;local nV=ae.familyOf(h)if nV then local pO=(pN()and"m:"or"s:")..nV;if(pM[pO]or 0)>=2 then L=K(pL[pO],0,0.1)end end;return L end;local pP=ae.seedLead;function ae.seedLead(h)local L=pP(h)if ae.FINAL[h]then return L end;local H=pF()local eZ=H and tonumber(H:GetAttribute("ShotSpeed"))if eZ and eZ>0.3 and eZ<3 then local pQ=K(1/eZ,0.75,1.3)L=K(L*(0.7+0.3*pQ),0,0.1)end;return L end;local pR=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if db and not db.manual and cZ and aZ~="green"and aZ~="good"then local pS=string.match(tostring(ae.fbText or""),"Contest %- (%S+)")if pS and pS~="None"and pS~="Open"then cZ=math.max(1,cZ-1)end end;return pR(db,aZ,cZ)end;local pT=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if db and not db.manual and cZ then local bI=pI()if bI and bI>pG+40 then cZ=math.max(1,cZ-1)end end;return pT(db,aZ,cZ)end;local pU=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)local M=ae.auto and db and ae.auto[db.key]local dJ,pV=M and M.hold,M and M.n or 0;local aw=pU(db,aZ,cZ)if M and dJ and M.mode=="peak"and not(db and db.manual)and M.hold~=dJ then local pW=math.min(1,pV/12)M.hold=K(dJ+(M.hold-dJ)*(1.4-pW*0.7),0,0.1)end;return aw end;local pX=ae.seedLead;function ae.seedLead(h)local L=pX(h)if ae.FINAL[h]then return L end;local H=pF()local hW=H and tostring(H:GetAttribute("GatherType")or"")if hW~=""and string.find(string.lower(hW),"catch",1,true)then L=K(L-0.003,0,0.1)end;return L end;local pY={}local pZ=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if db and db.key and not db.manual then local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm then local dT=dm==5 and 0 or dm==4 and-1 or dm-5;local dw=pY[db.key]pY[db.key]=dT;if math.abs(dT)>=3 and(not dw or math.abs(dw)<2)and cZ then cZ=math.max(1,cZ-1)end end end;return pZ(db,aZ,cZ)end;local p_=ae.seedLead;function ae.seedLead(h)local L=p_(h)local fd=pE(h)return K(K(L,fd-0.015,fd+0.015),0,0.1)end end;do local ab={}ab.URL="https://jayhubv1-default-rtdb.firebaseio.com"ab.lead={}local function q0(au)local a9,aZ=pcall(function()return request({Url=ab.URL.."/"..au..".json",Method="GET"})end)if a9 and aZ and aZ.Body then local q1,aA=pcall(function()return m:JSONDecode(aZ.Body)end)if q1 then return aA end end;return nil end;local function q2(au,q3)local q1,a_=pcall(function()return m:JSONEncode(q3)end)if not q1 then return end;pcall(function()request({Url=ab.URL.."/"..au..".json",Method="POST",Headers={["Content-Type"]="application/json"},Body=a_})end)end;local function q4(au,q3)local q1,a_=pcall(function()return m:JSONEncode(q3)end)if not q1 then return end;pcall(function()request({Url=ab.URL.."/"..au..".json",Method="PUT",Headers={["Content-Type"]="application/json"},Body=a_})end)end;local function q5(a1)return string.gsub(tostring(a1),"[%.%#%$%[%]/]","_")end;local q6=j.LocalPlayer.Name;C.netGet,C.netPut=q0,q4;C.roles=C.roles or{}task.spawn(function()while true do local a9,aA=pcall(q0,"roles")if a9 and type(aA)=="table"then C.roles=aA end;task.wait(5)end end)local function q7(bk)local oe=C.roles or{}if oe.owner and oe.owner~=""and bk==oe.owner then return"\u{1F451} ",Color3.fromRGB(255,215,0)," #owner"end;if type(oe.devs)=="string"then for lq in string.gmatch(oe.devs,"([^,]+)")do if string.gsub(lq,"^%s+","")==bk then return"\u{1F6E0} ",Color3.fromRGB(80,220,255)," #dev"end end end;if oe.mod1 and oe.mod1~=""and bk==oe.mod1 then return"\u{1F6E1} ",Color3.fromRGB(190,120,255)," #mod"end;if oe.mod2 and oe.mod2~=""and bk==oe.mod2 then return"\u{2B50} ",Color3.fromRGB(255,160,60)," #mod"end;return"",nil,""end;local nB;for g,bI in ipairs(aa.pages)do if bI.name=="Main"then nB=bI end end;if nB then local q8=aa.Card(nB,"JHub Chat (everyone on this script)")local q9=X("ScrollingFrame",{Size=UDim2.new(1,0,0,130),BackgroundTransparency=1,ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,LayoutOrder=iN(q8),Parent=q8.frame})X("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=q9})local qa=iP(q8,30)local qb=X("TextBox",{Size=UDim2.new(1,-66,1,0),Text="",PlaceholderText="Say something to everyone on JHub...",ClearTextOnFocus=false,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=qa})aa.text(qb,false)aa.elem(qb)aa.th(qb,"TextColor3","Text")aa.th(qb,"PlaceholderColor3","Sub")aa.corner(qb,0.7)aa.stroke(qb,0.5)X("UIPadding",{PaddingLeft=UDim.new(0,8),Parent=qb})local qc=X("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(58,26),Text="",AutoButtonColor=false,BackgroundColor3=v,Parent=qa})aa.corner(qc,0.8)aa.grad(qc)aa.label({Text="Send",TextSize=13,Size=UDim2.fromScale(1,1),TextColor3=v,Parent=qc},true,false)aa.Note(q8,"Type !ai followed by a question to ask the chat's AI.")local function qd(dZ,iQ)task.spawn(function()local a9,aZ=pcall(function()return request({Url="https://text.pollinations.ai/"..m:UrlEncode(dZ).."?model=openai",Method="GET"})end)local qe=a9 and aZ and aZ.Body and aZ.Body~=""and aZ.Body or"(the AI did not answer, try again)"iQ(string.sub(qe,1,400))end)end;local function qf()local J=qb.Text;if J and J~=""then qb.Text=""task.spawn(q2,"chat",{name=q6,text=string.sub(J,1,200),t=os.time()})local dZ=string.match(J,"^!ai%s+(.+)$")if dZ then qd(dZ,function(qe)q2("chat",{name="JHub AI",text=qe,t=os.time()})end)end end end;qb.FocusLost:Connect(function(qg)if qg then qf()end end)qc.Activated:Connect(qf)local qh=nil;task.spawn(function()while true do local aA=q0("chat")if type(aA)=="table"then local bG={}for a1 in pairs(aA)do bG[#bG+1]=a1 end;table.sort(bG)for g,H in ipairs(q9:GetChildren())do if H:IsA("TextLabel")then H:Destroy()end end;for cR=math.max(1,#bG-29),#bG do local bJ=aA[bG[cR]]if type(bJ)=="table"then local bk=tostring(bJ.name or"?")local gN,fw,iZ=q7(bk)local iK=aa.label({Text=string.format("%s%s: %s%s",gN,bk,tostring(bJ.text or""),iZ),TextSize=11,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=cR,Parent=q9},false,"Text")if fw then iK.TextColor3=fw end end end;local p8=bG[#bG]if p8 and p8~=qh then local qi=qh==nil;qh=p8;local bJ=aA[p8]if not qi and type(bJ)=="table"and tostring(bJ.name or"")~=q6 then ao("JHub Chat",string.format("%s: %s",tostring(bJ.name or"?"),tostring(bJ.text or"")),4)end end end;task.wait(3)end end)local qj=aa.Card(nB,"Live feed (everyone's shots)")local qk=X("ScrollingFrame",{Size=UDim2.new(1,0,0,100),BackgroundTransparency=1,ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,LayoutOrder=iN(qj),Parent=qj.frame})X("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=qk})task.spawn(function()while true do local aA=q0("feed")if type(aA)=="table"then local bG={}for a1 in pairs(aA)do bG[#bG+1]=a1 end;table.sort(bG)for g,H in ipairs(qk:GetChildren())do if H:IsA("TextLabel")then H:Destroy()end end;for cR=math.max(1,#bG-19),#bG do local bJ=aA[bG[cR]]if type(bJ)=="table"then aa.label({Text=string.format("%s  |  %s  |  %s",tostring(bJ.name or"?"),tostring(bJ.shot or"?"),tostring(bJ.verdict or"?")),TextSize=11,Size=UDim2.new(1,0,0,14),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=cR,Parent=qk},false,"Sub")end end end;task.wait(4)end end)local ql=aa.Card(nB,"Update log")aa.Note(ql,table.concat({"v1.86 - Universal Shot Intelligence: every jumpshot animation now gets a persisted profile (name, length, times seen, situations seen, first/last seen, identified or not), a locked profile that starts missing consistently is automatically unlocked and flagged to retest instead of staying trusted forever, and an animation that cannot be identified is labeled as such instead of silently reusing another profile's data - all shown on the Shot Intelligence card","v1.85 - new Shot Intelligence card shows the detected jumpshot, its animation ID, calibration status, confidence (sample count/locked/built-in), active timing, and how many profiles are known, plus a button to copy every profile - this is the existing per-animation timing-profile system (automatic per-jumpshot profiles, auto switching when you change jumpshots) made visible instead of hidden","v1.84 - a jumpshot used to only get shared as a found best timing network-wide if someone hit a literal real Perfect on it; now any jumpshot whose adaptive learner converges with enough real samples (12+) gets shared the same way, so every jumpshot anyone actually plays eventually gets a found-and-shared best timing, not just the rare Perfects","v1.83 - the Owner tab's 2011 code alone could let anyone rename themselves Owner, overwriting whoever had it; now the roles screen loads the current Owner/devs/mods instead of defaulting to you, roles stay set until someone changes them, and changing who the Owner is now needs a separate code on top of 2011","v1.82 - entering the Auto Guard, Locked, or Owner tab code once now sticks - it stays unlocked after the script resets/reloads, no need to retype it","v1.81 - new Owner tab (code 2011) sets who gets a crown/gold/#owner or dev/mod badge in JHub Chat for everyone; chat now pops a notification for new messages; shared jumpshot timing now pushes/pulls every 2-4s instead of 10-20s so one person's locked timing reaches everyone almost instantly; calibration step/speed increased; removed the made-shot ding sound","v1.80 - GuardAnimId never once beat the game\'s own real defensive animation in testing, so stopped fighting it - Auto Guard now always plays the real walk animation whenever actually moving, guarding or not","v1.79 - found why Auto Rebound had a walk animation but Auto Guard did not: a wobble wrapper was marking Auto Guard as actively guarding on every single tick it ran, even mid-chase, so the walk animation never got picked - fixed","v1.78 - Humanoid:Move did nothing for the walk animation either (same reason it did nothing for movement) - now manually plays the confirmed real walk/guard animation on top of CFrame movement","v1.77 - added an option to only drive Auto Guard while you hold the real Guard button yourself, instead of it pressing the button for you","v1.76 - confirmed Mover.send also produced zero real movement (sent ok, speed stayed 0); back to CFrame for actual position, with Humanoid:Move running alongside it at the same time purely so the real walk animation plays","v1.75 - diagnostics found AGRange was blocking Auto Guard from even trying to move whenever the opponent was past it (check your Guard range slider); fixed a logging bug that hid confirmed Mover.send calls; open/contested is now live while dribbling with a character highlight, not just a post-shot label","v1.74 - added live diagnostics to the Remote Guard Recorder log: target, distance, calculated direction, what actually got sent, whether it was blocked, and humanoid state, no logic changed","v1.73 - found the real reason Auto Guard never followed: this game is server-authoritative and ignores Humanoid:Move entirely - movement now fires the same MoveDirection remote the game itself uses","v1.72 - Auto Guard target lock now sticks to the same opponent (with hysteresis) instead of re-picking best every tick, and velocity is read from the real AssemblyLinearVelocity (now including AI) instead of estimated","v1.71 - back on Humanoid:Move for good: re-read the last log correctly - speed=0 was the guard distance dead-zone working as intended, not a stall; movement is smooth, animations are the game\'s own, target lock/tracking unchanged","v1.70 - Humanoid:Move produced zero actual movement in this game (confirmed: speed stuck at 0 the whole time), reverted to CFrame for position while keeping the confirmed real walk/defensive animation ids playing on top","v1.69 - Auto Guard no longer moves by CFrame at all - it now uses Humanoid:Move like a real player does, so the game\'s own Animate script picks the correct walk/defensive-slide animation automatically","v1.68 - found the real reason the walk animation never showed: moving the root by CFrame alone left the humanoid stuck in Freefall/FallingDown state forever, which hid the walk animation even though it was technically playing - fixed","v1.67 - removed the Discord join gate entirely, replaced with a Discord button in the top right of the menu that copies the invite link","v1.66 - fixed the Discord join gate freezing the whole script for anyone whose click or isfile/writefile did not register - it no longer blocks the real menu from loading","v1.65 - found it: the real walk animation id was being auto-deleted by a leftover bad-id filter, so Auto Guard could never have one; fixed and bootstrapped the confirmed real ids","v1.64 - Remote Guard Recorder now also watches whoever is nearest to you, not just yourself, and logs their walk/guard animation ids too","v1.63 - Auto Guard now detects AI opponents (no Player object) and uses the real HomeTeam attribute instead of Player.Team","v1.62 - recorder now polls currently-playing animations directly instead of waiting on a play event","v1.61 - fixed the recorder: move spam was evicting every animation entry from the log","v1.60 - found the real cause of the blank Auto Guard tab: a leftover block re-hid every card on it","v1.59 - fixed the in-script update checker pointing at the wrong, stale branch","v1.58 - removed the lock code from the visible update log","v1.57 - found it: a leftover line was hiding the Auto Guard tab and force-disabling it every load","v1.56 - rebuilt Auto Guard tab self-contained with its own code lock","v1.55 - Auto Guard now locked behind the Locked tab code, same as the other tools","v1.54 - Auto Guard rebuilt plain again (CFrame + real animation, no simulated input); recorder moved onto its own tab","v1.53 - added Remote Guard Recorder: catches every animation and movement state while guarding","v1.52 - fixed sideways drift and stuck movement when auto guard stops being called","v1.51 - Auto Guard rebuilt: holds real Guard button, follows with real keys/joystick","v1.50 - Auto Guard holds the real Guard button instead of crafting remote calls","v1.49 - fixed HoldG toggling itself back off every frame before the server caught up","v1.48 - Auto Guard now presses the real Guard button and lets the server drive movement","v1.47 - learns your real defensive slide animation separately from your walk","v1.46 - fixed the walk animation learner relearning its own old fake id","v1.45 - fixed walk animation never being learned (this game does not use MoveDirection)","v1.44 - guard recorder: records your real guarding and reports the learned walk animation id","v1.43 - fixed a frozen black/blue screen on first run for some users (Discord gate crash)","v1.42 - walk animation is learned from your own real walk instead of a guessed id","v1.41 - auto guard uses your real walk animation and Players-tab guard speed only","v1.40 - X button on every bind, learned binds shared across the network","v1.29 - JHub network: chat, live feed, shared jumpshot timing","v1.28 - 10 always-on live helps for Auto Green","v1.27 - Sweep locked off at all times","v1.25 - every jumpshot's game settings built in","v1.24 - jumpshot mastery inside the Ultra recorder","v1.23 - Dex tree, every shot setting, remote spy inside Ultra recorder","v1.22 - Copy my shot report for every player"},"\n"))end;local qm={}local qn=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)local aw=qn(db,aZ,cZ)if db and db.key and ae.auto and ae.auto[db.key]and ae.auto[db.key].locked and not ae.FINAL[db.key]then local M=ae.auto[db.key]local bZ=tick()if(qm[db.key]or 0)+2<bZ then qm[db.key]=bZ;local qo=(M.n or 0)>=12;task.spawn(q4,"timing/"..q5(db.key),{lead=M.hold,n=M.n or 0,hard=qo or nil,by=q6,t=os.time()})end end;return aw end;task.spawn(function()while true do local aA=q0("timing")if type(aA)=="table"then local qp={}for a1,L in pairs(aA)do if type(L)=="table"and type(L.lead)=="number"then qp[a1]=L end end;ab.lead=qp end;task.wait(4)end end)local qq=ae.seedLead;function ae.seedLead(h)local L=qq(h)if ae.FINAL[h]then return L end;local qr=ae.auto and ae.auto[h]and ae.auto[h].locked;if not qr then local kj=ab.lead[q5(h)]if kj and kj.lead then L=K((L+kj.lead)/2,0,0.1)end end;return L end;local nC=ae.learnRemote;function ae.learnRemote(db,aZ,cZ)if db and db.key then task.spawn(q2,"feed",{name=q6,shot=ae.nameFor(db.key,db.anim),verdict=tostring(aZ),t=os.time()})end;return nC(db,aZ,cZ)end;local function qs()local S={}for a1 in string.gmatch(ar.HardLock or"","([^,]+),")do S[a1]=true end;return S end;local function qt(h)local S=qs()if not S[h]then ar.HardLock=(ar.HardLock or"")..h..","aI()end end;C.hardLocked=qs()local qu=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if db and db.key and C.hardLocked[db.key]then return true end;local aw=qu(db,aZ,cZ)if db and db.key and db.idx==5 and not db.manual and not ae.FINAL[db.key]and not C.hardLocked[db.key]and db.lead then local M=ae.auto and ae.auto[db.key]if not M then M={hold=db.lead,greens={},locked=false,dir=1,mode="peak",bin=ar.PeakBin}ae.auto[db.key]=M end;M.hold,M.locked,M.mode=db.lead,true,"peak"C.hardLocked[db.key]=true;qt(db.key)task.spawn(q4,"timing/"..q5(db.key),{lead=M.hold,n=9999,hard=true,by=q6,t=os.time()})ao("Timing locked","Jumpshot "..tostring(ae.nameFor and ae.nameFor(db.key)or db.key).." hit a real Perfect, its timing is locked forever and shared.",5)end;return aw end;local qv=ae.seedLead;function ae.seedLead(h)if C.hardLocked[h]and ae.auto and ae.auto[h]then return ae.auto[h].hold end;local kj=ab.lead[q5(h)]if kj and kj.hard and not C.hardLocked[h]then C.hardLocked[h]=true;qt(h)ae.auto[h]=ae.auto[h]or{}local M=ae.auto[h]M.hold,M.locked,M.mode,M.greens,M.bin=kj.lead,true,"peak",M.greens or{},M.bin or ar.PeakBin;return M.hold end;return qv(h)end;do local qw={}C.ShotIntel=qw;local e8,qx=pcall(function()return m:JSONDecode(ar.ShotIntelDB or"")end)qw.DB=e8 and type(qx)=="table"and qx or{}local qy=false;task.spawn(function()while true do if qy then qy=false;local a9,a_=pcall(function()return m:JSONEncode(qw.DB)end)if a9 then ar.ShotIntelDB=a_;aI()end end;task.wait(5)end end)local qz={}qw.lastKey=nil;local function qA(db,aZ,cZ)if not(db and db.key)then return end;local h=db.key;local qB=string.sub(h,1,4)~="sit:"local kp=qw.DB[h]if not kp then kp={id=h,name=ae.nameFor(h,db.anim),length=db.track and db.track.Length or 0,firstSeen=os.time(),lastSeen=os.time(),timesSeen=0,sits={},ver=1,identified=qB,needsRetest=false}qw.DB[h]=kp end;kp.lastSeen=os.time()kp.timesSeen=(kp.timesSeen or 0)+1;if db.sit then kp.sits[db.sit]=(kp.sits[db.sit]or 0)+1 end;if not kp.identified and qB then kp.identified=true end;if qw.lastKey~=h then qw.switched={from=qw.lastKey,to=h,t=tick()}qw.lastKey=h end;local dm=db.idx or aZ=="green"and 5 or aZ=="good"and 4 or aZ=="early"and 4-(cZ or 2)or aZ=="late"and 5+(cZ or 2)if dm then local qC=qz[h]if not qC then qC={}qz[h]=qC end;table.insert(qC,1,dm)while#qC>10 do table.remove(qC)end;local M=ae.auto and ae.auto[h]if M and M.locked and#qC>=5 then local qD=0;for cR=1,math.min(5,#qC)do if math.abs(qC[cR]-5)>=2 then qD=qD+1 end end;if qD>=3 then M.locked=false;kp.needsRetest=true;ao("Shot Intelligence","Timing for "..tostring(kp.name).." started missing consistently - unlocked for retesting.",4)elseif kp.needsRetest and qD==0 then kp.needsRetest=false end end end;qy=true end;local qE=ae.learnRemote;function ae.learnRemote(db,aZ,cZ)local aw=qE(db,aZ,cZ)pcall(qA,db,aZ,cZ)return aw end;local qF=ae.learnTiming;function ae.learnTiming(db,aZ,cZ)local aw=qF(db,aZ,cZ)pcall(qA,db,aZ,cZ)return aw end end;function C.onBindLearned(bk,c4)if C.bindSer then task.spawn(q4,"bindlib/"..q5(bk),{text=C.bindSer(c4),name=bk,by=q6,t=os.time()})end end;task.spawn(function()local aZ=q0("bindlib")if type(aZ)=="table"and C.bindLib and C.bindDeser then local qG=false;for h,qH in pairs(aZ)do if type(qH)=="table"and type(qH.text)=="string"then local qI=type(qH.name)=="string"and qH.name or h;if not C.bindLib[qI]then local c4=C.bindDeser(qH.text)if c4 then C.bindLib[qI]=c4;qG=true end end end end;if qG and C.bindSaveLib then C.bindSaveLib()end end end)end;do local qJ=ae.adaptGain;local qK,qL=nil,0;function ae.adaptGain(h,dT)local a3=qJ(h,dT)local M=ae.auto and ae.auto[h]local bc=M and M.n or 0;local qM=1/(1+0.12*bc)a3=a3*K(qM,0.2,1)if h==qK and tick()<qL then a3=a3*0.4 end;return a3 end;local qz={}local qN=ae.autoLearn;function ae.autoLearn(db,aZ,cZ)if db and db.key and db.idx and not db.manual then local dT=db.idx==5 and 0 or db.idx==4 and-1 or db.idx-5;local aR=qz[db.key]or{}aR[#aR+1]=dT;while#aR>3 do table.remove(aR,1)end;qz[db.key]=aR;if#aR>=3 then local mg=0;for cR=1,#aR-1 do mg=mg+aR[cR]end;local qO=mg/(#aR-1)if math.abs(dT)>=3 and math.abs(qO)<=1 then qK,qL=db.key,tick()+1 end end end;return qN(db,aZ,cZ)end end;aa.syncAuto()aa.applyTheme()aa.applyFx()for g,a5 in ipairs(aa.refresh)do pcall(a5)end;ju.Visible=ar.Watermark;jw.Visible=ar.BackupButton;aa.select(aa.pages[1])aa.show(true)local b9=u:WaitForChild("PlayerGui")ae.parseTimes()ae.hookRoot(b9)ae.hookRoot(workspace,true)task.spawn(function()local bE;while C.Running do local H=a4()if H and H~=bE then bE=H;ah.hookChar(H)end;task.wait(1)end end)task.spawn(function()while C.Running do pcall(ae.watch)task.wait(0.2)end end)pcall(function()local qP=nil;E(l.TouchPinch,function(qQ,pQ,qR,dO)if not hv.Visible then return end;if dO==Enum.UserInputState.Begin then qP=nil;local qS=#qQ>=2;for g,bI in ipairs(qQ)do if not ac.hits(hv,bI)then qS=false end end;if qS then qP=ar.UIScale end elseif dO==Enum.UserInputState.Change and qP then local L=math.floor(K(qP*pQ,0.6,1.5)*100+0.5)/100;if L~=ar.UIScale then aa.set("UIScale",L,false)aa.fitScale()aa.keepOnScreen()end else qP=nil end end)end)task.spawn(function()local dw=""while C.Running do local H=a4()local M=H and H:GetAttribute("Action")if type(M)=="string"and M~=dw then dw=M;if M=="Gathering"and ag.gatherOk and ag.gatherOk(H)then pcall(ag.fire,"gather","gather step")end end;task.wait(0.03)end end)task.spawn(function()while C.Running do pcall(aj.magnetStep)if aa.lowStat and tick()-(ai.lowStatT or 0)>1 then ai.lowStatT=tick()aa.lowStat.Text=ai.lowStatusText()end;pcall(aj.V.step)task.wait(0.05)end end)pcall(an.hook)pcall(ae.connectRemotes)if ar.AutoExec then pcall(ab.queueTeleport)end;task.spawn(function()ad.rescan()I(string.format("Scan: %d ball part(s) found",ad.count()))end)E(workspace.DescendantAdded,function(bb)pcall(ad.consider,bb)end)I("JHub Glass loaded on "..jx)ao("JHub V1",(A and"Tap the moving JH logo to open or close the menu."or"Press "..ar.MenuKey.." or click the JH logo to open or close the menu.").."  Welcome, "..u.DisplayName.."!",5)aU(aX,0.4)end;local a9,ef=xpcall(b,function(fz)return tostring(fz).."\n"..debug.traceback()end)if not a9 then warn("[JHub] failed to load: "..tostring(ef))pcall(function()local fZ=Instance.new("ScreenGui")fZ.Name="JHubError"fZ.ResetOnSpawn=false;local qT=pcall(function()fZ.Parent=gethui and gethui()or game:GetService("CoreGui")end)if not qT or not fZ.Parent then fZ.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")end;local ba=Instance.new("TextButton")ba.Size=UDim2.fromOffset(440,230)ba.Position=UDim2.new(0.5,-220,0.5,-115)ba.BackgroundColor3=Color3.fromRGB(10,30,70)ba.TextColor3=Color3.new(1,1,1)ba.Font=Enum.Font.Code;ba.TextSize=12;ba.TextWrapped=true;ba.TextXAlignment=Enum.TextXAlignment.Left;ba.TextYAlignment=Enum.TextYAlignment.Top;ba.Text="JHub failed to load. Screenshot this and send it (tap to close):\n\n"..tostring(ef)ba.Parent=fZ;ba.Activated:Connect(function()fZ:Destroy()end)if setclipboard then pcall(setclipboard,tostring(ef))end end)end