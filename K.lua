--[[
  Oklo shooting system, combined into one file (for JHub)
  Modules inside: config, env, court, aero, hook, autogreen, autoshoot, drive, autodunk, contest, rimguard
  Use:  local KS = <this file's return value>
        local api = KS.start(function(text) print(text) end)   -- starts Auto Green
        KS.Settings.AutoGreen = true                            -- settings table (see Config.DEFAULTS)
        local AutoShoot = KS.import("autoshoot")                -- other modules via KS.import(name)
--]]
local KuluShoot = nil
-- Kulu shooting system (Auto Green) bundled for JHub
KuluShoot = (function()
local modules = {}
local loaded = {}
local function import(name)
    local cached = loaded[name]
    if cached ~= nil then return cached end
    local build = modules[name]
    if not build then error("module is missing: " .. tostring(name)) end
    local value = build(import)
    loaded[name] = value
    return value
end
modules["config"] = function(...)

local Config = {}

Config.PEAKS = {
    Bat = -0.99,
    Funnel2 = -0.985,
    Rocket = -0.91,
    Vertical = -1.48,
} :: { [string]: number }

Config.GUARD_BALL = "Ball Handler"
Config.GUARD_NEAREST = "Nearest Player"
Config.GUARD_TARGETS = { Config.GUARD_BALL, Config.GUARD_NEAREST }

Config.COMBO_NAMES = { "Cross Tween", "Hesi Cross", "Behind Back Spin", "Double Cross Snatch", "Breakdown Stepback", "Half Spin Cross" }
Config.COMBOS = {
    ["Cross Tween"] = { "Crossover", "Tween", "Crossover" },
    ["Hesi Cross"] = { "Hesitation", "Crossover", "Hesitation" },
    ["Behind Back Spin"] = { "BehindBack", "Spin" },
    ["Double Cross Snatch"] = { "DoubleCrossover", "SnatchBack" },
    ["Breakdown Stepback"] = { "Breakdown", "Crossover", "StepBack" },
    ["Half Spin Cross"] = { "HalfSpin", "Crossover" },
} :: { [string]: { string } }

Config.MOVE_INPUTS = {
    Crossover = { R = "Z", L = "C" },
    Hesitation = { R = "C", L = "Z" },
    Tween = { R = "ZZ", L = "CC" },
    DoubleCrossover = { R = "CC", L = "ZZ" },
    BehindBack = { R = "CX", L = "ZX" },
    Spin = { R = "CXZ", L = "ZXC" },
    StepBack = { R = "X", L = "X" },
    SnatchBack = { R = "XX", L = "XX" },
    HalfSpin = { R = "V", L = "V" },
    Breakdown = { R = "VC", L = "VZ" },
} :: { [string]: { [string]: string } }

Config.MOVE_KEYS = {
    { "Crossover", "Crossover" },
    { "Hesitation", "Hesitation" },
    { "Tween", "Tween" },
    { "Double Cross", "DoubleCrossover" },
    { "Behind Back", "BehindBack" },
    { "Spin", "Spin" },
    { "Step Back", "StepBack" },
    { "Snatch Back", "SnatchBack" },
    { "Half Spin", "HalfSpin" },
    { "Breakdown", "Breakdown" },
} :: { { string } }


Config.DUNK_BOTH = "Both"
Config.DUNK_DRIVING = "Driving Only"
Config.DUNK_STANDING = "Standing Only"
Config.DUNK_TYPES = { Config.DUNK_BOTH, Config.DUNK_DRIVING, Config.DUNK_STANDING }

Config.CONTEST_STYLES = { "Percent", "Bar" }
Config.CONTEST_COLORS = { "Contest Colors", "Custom" }

Config.TIMINGS = { "Very Early", "Early", "Slightly Early", "Good", "Perfect", "Slightly Late", "Late", "Very Late" }

Config.PARENT = {
    OpenShotGlow = "OpenShot", OpenShotNumber = "OpenShot", OpenShotBall = "OpenShot",
    ContestWho = "OpenShot", ContestFoeMark = "OpenShot",
    OpenOnly = "AutoShoot",
    DunkMove = "AutoDunk", DunkOpenOnly = "AutoDunk",
    GuardMove = "AutoGuard", GuardFacing = "AutoGuard",
    StealFacing = "AutoSteal", AvoidFouls = "AutoSteal",
    ReadFakes = "AutoBlock",
    BallMagnet = "AutoRebound",
    BlockDribbleKeys = "MoveKeys",
    ComboOnce = "DribbleCombo", ComboGuarded = "DribbleCombo",
    TapShoot = "AutoGreen", AutoCalibrate = "AutoGreen", RimFront = "AutoGreen", NotifyRelease = "AutoGreen", SafeMode = "AutoGreen",
    DribbleGlideSteer = "DribbleGlide", GatherGlideSteer = "GatherGlide", ShotGlideSteer = "ShotGlide",
    EspTeam = "Esp", EspStamina = "Esp", EspBallOnly = "Esp",
} :: { [string]: string }

Config.DEFAULTS = {
    AutoGreen = false,
    GreenOffset = 0,
    PingComp = 100,
    AutoCalibrate = true,
    SafeMode = false,
    TapShoot = false,
    LayupGreen = true,
    RimFront = true,
    NotifyRelease = false,
    PerfectChance = 100,
    OpenOnly = false,
    OpenRange = 6,
    MaxContest = 35,
    MinShot = 0,
    MaxShot = 120,
    AutoShoot = false,
    AutoDunk = false,
    DunkRange = 30,
    DunkType = "Both",
    DunkMove = false,
    DunkOpenOnly = false,
    ShootRange = 24,
    ShootDelay = 300,
    AutoSteal = false,
    StealRange = 8,
    AutoGuard = false,
    GuardRange = 7,
    GuardTarget = "Ball Handler",
    GuardMove = true,
    GuardGap = 16,
    GuardFacing = false,
    ReadFakes = true,
    StealFacing = true,
    AvoidFouls = true,
    AlwaysSprint = false,
    CustomSpeed = false,
    WalkSpeed = 16,
    NoStun = false,
    NoDebounce = false,
    NoCold = false,
    ThreePointLine = false,
    DunkZones = false,
    RangeViz = false,
    ShotRangeViz = false,
    ShotColor = Color3.fromRGB(255, 255, 255),
    StealColor = Color3.fromRGB(255, 90, 90),
    GuardColor = Color3.fromRGB(90, 160, 255),
    BlockColor = Color3.fromRGB(255, 200, 70),
    FullSpeed = false,
    AutoBlock = false,
    BlockRange = 10,
    BlockDelay = 0,
    AutoRebound = false,
    ReboundRange = 8,
    BallMagnet = false,
    MagnetRange = 12,
    AutoPass = false,
    PassPressure = 6,
    AutoDribble = false,
    DribbleRange = 7,
    DribbleCombo = false,
    ComboMoves = "Cross Tween",
    ComboGuarded = true,
    DribbleGlide = false,
    GatherGlide = false,
    ShotGlide = false,
    DribbleGlideSpeed = 5,
    DribbleGlideTime = 240,
    DribbleGlideStrength = 30,
    DribbleGlideSteer = false,
    GatherGlideSpeed = 14,
    GatherGlideTime = 500,
    GatherGlideStrength = 100,
    GatherGlideSteer = false,
    ShotGlideSpeed = 10,
    ShotGlideTime = 440,
    ShotGlideStrength = 60,
    ShotGlideSteer = false,
    ComboOnce = true,
    MoveKeys = false,
    BlockDribbleKeys = false,
    OpenShot = false,
    OpenShotGlow = true,
    OpenShotNumber = false,
    ContestStyle = "Percent",
    ContestWho = true,
    ContestFoeMark = false,
    ContestTextSize = 13,
    ContestHeight = 4.2,
    ContestColorMode = "Contest Colors",
    ContestLabelColor = Color3.fromRGB(255, 255, 255),
    ContestViewRange = 120,
    ContestOpacity = 0.85,
    GlowStrength = 60,
    OpenShotBall = true,
    ContestRange = 6,
    InfStamina = false,
    Esp = false,
    EspTeam = false,
    EspStamina = true,
    EspBallOnly = false,
    EspDistance = 300,
    EspTextSize = 13,
    EspBackground = 0.2,
    ColorEnemy = Color3.fromRGB(255, 105, 105),
    ColorTeam = Color3.fromRGB(105, 235, 135),
    ColorHolder = Color3.fromRGB(255, 215, 80),
    ColorBackground = Color3.fromRGB(16, 16, 22),
} :: { [string]: any }

return Config
end
modules["env"] = function(...)

local Env = {}

local httpService: any = game:GetService("HttpService")

local function pick(value: any): any
    return if type(value) == "function" then value else nil
end

local globals: any = nil
if type(getgenv) == "function" then
    local ok, env = pcall(getgenv)
    if ok and type(env) == "table" then
        globals = env
    end
end
if type(globals) ~= "table" then
    globals = if type(_G) == "table" then _G else {}
end

Env.G = globals
Env.hookmetamethod = pick(hookmetamethod)
Env.newcclosure = pick(newcclosure)
Env.clonefunction = pick(clonefunction)
Env.restorefunction = pick(restorefunction)
Env.getnamecallmethod = pick(getnamecallmethod)
Env.getrawmetatable = pick(getrawmetatable)
Env.setreadonly = pick(setreadonly)
Env.checkcaller = pick(checkcaller)
Env.keypress = pick(keypress)
Env.keyrelease = pick(keyrelease)
Env.filtergc = pick(filtergc)
Env.gethui = pick(gethui)
Env.getgc = pick(getgc)
Env.setidentity = pick(setthreadidentity) or pick(set_thread_identity) or pick(setidentity)
Env.getidentity = pick(getthreadidentity) or pick(get_thread_identity) or pick(getidentity)

local canRead = type(isfile) == "function" and type(readfile) == "function"
local canWrite = type(writefile) == "function"

function Env.get(name: string): any
    return globals[name]
end

function Env.set(name: string, value: any)
    globals[name] = value
end

local function readJson(path: string): any
    if not isfile(path) then
        return nil
    end
    return httpService:JSONDecode(readfile(path))
end

function Env.readJson(path: string): any
    if not canRead then
        return nil
    end
    local ok, value = pcall(readJson, path)
    return if ok and type(value) == "table" then value else nil
end

local function writeJson(path: string, value: any)
    writefile(path, httpService:JSONEncode(value))
end

function Env.writeJson(path: string, value: any): boolean
    if not canWrite then
        return false
    end
    return (pcall(writeJson, path, value))
end

return Env
end
modules["court"] = function(...)

local import: (string) -> any = ...
local Env: typeof(require("./env")) = import("env")

local Court = {}

type Map = { [string]: any }

local players: any = game:GetService("Players")
local replicatedStorage: any = game:GetService("ReplicatedStorage")
local userInput: any = game:GetService("UserInputService")
local stats: any = game:GetService("Stats")

local MOVE_KEYS = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right }
local FAR_RIM = 30
local HOOK = "__PBShootHook"
local BALL_REACH = 6

Court.Now = 0
Court.Mine = nil :: any
Court.Root = nil :: any
Court.Action = nil :: any
Court.HasBall = false
Court.Count = 0
Court.Chars = {} :: { any }
Court.Roots = {} :: { any }
Court.Foe = {} :: { boolean }
Court.Carry = {} :: { boolean }
Court.TeamBall = false
Court.FoeBall = false
Court.Ping = 0.08
Court.Sending = 0
Court.Held = false
Court.Keys = false
Court.KeysOff = -math.huge
Court.Focused = true
Court.UserMoving = false
Court.Dead = false
Court.Forced = false
Court.HandsOff = false
Court.WalkAt = -math.huge
Court.FreeAt = -math.huge
Court.Foul = false
Court.Ball = {} :: { boolean }
Court.FoeHeld = false
Court.Touched = {} :: { string }

local function flat(vector: Vector3): Vector3
    return Vector3.new(vector.X, 0, vector.Z)
end

Court.flat = flat

local records: { [any]: Map } = setmetatable({}, { __mode = "k" }) :: any

local function record(character: any): Map
    local entry = records[character]
    if not entry then
        entry = {}
        records[character] = entry
    end
    return entry
end

function Court.root(character: any): any?
    local entry = record(character)
    local root = entry.Root
    if root and root.Parent == character then
        return root
    end
    root = character:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        entry.Root = root
        return root
    end
    entry.Root = nil
    return nil
end

function Court.humanoid(character: any): any?
    local entry = record(character)
    local humanoid = entry.Humanoid
    if humanoid and humanoid.Parent == character then
        return humanoid
    end
    humanoid = character:FindFirstChildOfClass("Humanoid")
    entry.Humanoid = humanoid
    return humanoid
end

function Court.holds(character: any): boolean
    local entry = record(character)
    local inner = entry.Inner
    if not inner or not inner:IsDescendantOf(character) then
        local folder = character:FindFirstChild("Attributes")
        inner = if folder then folder:FindFirstChild("Basketball") else nil
        entry.Inner = inner
    end
    if inner and inner:IsA("ObjectValue") and inner.Value ~= nil then
        return true
    end
    local outer = entry.Outer
    if not outer or outer.Parent ~= character then
        outer = character:FindFirstChild("Basketball")
        entry.Outer = outer
    end
    if outer and outer:IsA("ObjectValue") and outer.Value ~= nil then
        return true
    end
    local carried = character:GetAttribute("Basketball")
    if carried ~= nil and carried ~= false and carried ~= "" then
        return true
    end
    return character:GetAttribute("TripleThreat") == true or character:GetAttribute("Action") == "Dribbling"
end

function Court.free(character: any): boolean
    if character:GetAttribute("Stunned") == true then
        return false
    end
    return character:GetAttribute("CanMove") ~= false or character:GetAttribute("Action") == "Dribbling"
end

local OWN_MOVES: { [string]: boolean } = {
    Dribbling = true, Shooting = true, Gathering = true, Dunking = true, ContactLayup = true, Layup = true, Passing = true,
    Stealing = true, Blocking = true, Jumping = true, Rebounding = true, CatchingPass = true, PassTransition = true,
    CatchingLob = true, AwaitingPass = true, Diving = true, Pushing = true, MovingShot = true,
}

function Court.forced(character: any): boolean
    if not character then
        return false
    end
    local action = character:GetAttribute("Action")
    if action == "Moving" or action == "Fouled" or action == "Inbounding" or action == "Stunned" then
        return true
    end
    if character:GetAttribute("CanMove") == false then
        return not (type(action) == "string" and OWN_MOVES[action])
    end
    return false
end

local WALKS: { [string]: boolean } = { Moving = true, Fouled = true, Inbounding = true }

function Court.walking(character: any): boolean
    if not character then
        return false
    end
    local action = character:GetAttribute("Action")
    return type(action) == "string" and WALKS[action] == true
end

local GRACE = 0.5
Court.GRACE = GRACE

function Court.held(character: any): boolean
    if not character then
        return false
    end
    if Court.walking(character) or character:GetAttribute("Stunned") == true or character:GetAttribute("Action") == "Stunned" then
        return true
    end
    return os.clock() - (Court.FreeAt or -math.huge) < GRACE
end

function Court.handsOff(character: any): boolean
    if not character then
        return false
    end
    return Court.forced(character) or Court.held(character)
end

function Court.touch(what: string)
    local list = Court.Touched
    if #list < 24 and not table.find(list, what) then
        table.insert(list, what)
    end
end

function Court.enemy(mine: any, character: any): boolean
    if character:GetAttribute("TeamIndex") ~= mine:GetAttribute("TeamIndex") then
        return true
    end
    local theirs = character:GetAttribute("Team")
    return string.sub(character.Name, 1, 2) == "AI" and theirs ~= nil and theirs ~= mine:GetAttribute("Team")
end

local roster: { any } = {}
local rosterFolder: any = nil
local rosterLinks: { any } = {}
local nextSync = 0
local ROSTER_SYNC = 0.5

local function unbindRoster()
    for _, link in rosterLinks do
        pcall(link.Disconnect, link)
    end
    table.clear(rosterLinks)
    table.clear(roster)
    rosterFolder = nil
end

local function bindRoster(folder: any)
    unbindRoster()
    if not folder then
        return
    end
    rosterFolder = folder
    for _, child in folder:GetChildren() do
        table.insert(roster, child)
    end
    rosterLinks[1] = folder.ChildAdded:Connect(function(child: any)
        if not table.find(roster, child) then
            table.insert(roster, child)
        end
    end)
    rosterLinks[2] = folder.ChildRemoved:Connect(function(child: any)
        local index = table.find(roster, child)
        if index then
            local last = #roster
            roster[index] = roster[last]
            roster[last] = nil
        end
    end)
end

local function characters(now: number): any?
    local folder = rosterFolder
    if not folder or folder.Parent ~= workspace then
        folder = workspace:FindFirstChild("Characters")
        bindRoster(folder)
        nextSync = now + ROSTER_SYNC
        return folder
    end
    if now >= nextSync then
        nextSync = now + ROSTER_SYNC
        table.clear(roster)
        for _, child in folder:GetChildren() do
            table.insert(roster, child)
        end
    end
    return folder
end

function Court.mine(): any?
    local folder = rosterFolder
    if not folder or folder.Parent ~= workspace then
        folder = workspace:FindFirstChild("Characters")
    end
    local player = players.LocalPlayer
    if not folder or not player then
        return nil
    end
    return folder:FindFirstChild(player.Name)
end

local pingItem: any = nil
local nextPing = 0
local pingSeeded = false
local PING_SMOOTH = 0.2

local pingWindow: { number } = {}
local PING_WINDOW = 6

local function samplePing(value: number)
    local clamped = math.min(value, 0.6)
    table.insert(pingWindow, clamped)
    if #pingWindow > PING_WINDOW then
        table.remove(pingWindow, 1)
    end
    local sorted = table.clone(pingWindow)
    table.sort(sorted)
    local half = math.ceil(#sorted / 2)
    local low = 0
    for index = 1, half do
        low += sorted[index]
    end
    low /= half
    if pingSeeded then
        Court.Ping += (low - Court.Ping) * PING_SMOOTH
    else
        pingSeeded = true
        Court.Ping = low
    end
end

local function dataPing(): number
    local item = pingItem
    if not item then
        item = stats.Network.ServerStatsItem["Data Ping"]
        pingItem = item
    end
    return item:GetValue()
end

local function networkPing(): number
    return players.LocalPlayer:GetNetworkPing()
end

local function updatePing(now: number)
    if now < nextPing then
        return
    end
    nextPing = now + 0.25
    local ok, value = pcall(dataPing)
    if ok and type(value) == "number" and value == value and value > 0 then
        samplePing(value / 1000)
        return
    end
    pingItem = nil
    local got, seconds = pcall(networkPing)
    if got and type(seconds) == "number" and seconds == seconds and seconds > 0 then
        samplePing(seconds * 2)
    end
end

local serviceFolder: any = nil
local inputs: { [string]: any } = {}

local function service(name: string): any?
    local aero = replicatedStorage:FindFirstChild("Aero")
    local remotes = if aero then aero:FindFirstChild("AeroRemoteServices") else nil
    return if remotes then remotes:FindFirstChild(name) else nil
end

Court.service = service

function Court.input(name: string): any?
    local remote = inputs[name]
    if remote and remote.Parent ~= nil then
        return remote
    end
    local folder = serviceFolder
    if not folder or folder.Parent == nil then
        folder = service("InputService")
        serviceFolder = folder
    end
    remote = if folder then folder:FindFirstChild(name) else nil
    inputs[name] = remote
    return remote
end

local function shotRelease(remote: any, first: any): boolean
    return remote.Name == "Shoot" and type(first) == "table" and rawget(first, "Shoot") == false
end

Court.Closing = false

function Court.send(remote: any, ...: any): boolean
    if Court.HandsOff and not Court.Closing and not shotRelease(remote, (...)) then
        Court.touch("held back " .. tostring(remote.Name))
        return false
    end
    Court.Sending += 1
    local ok = pcall(remote.FireServer, remote, ...)
    Court.Sending -= 1
    return ok
end

function Court.copied(name: string): any?
    local hook = Env.get(HOOK)
    if type(hook) ~= "table" then
        return nil
    end
    if name == "Sprint" and hook.SprintOn then
        return hook.SprintOn
    end
    local press = hook.Press
    return if type(press) == "table" then press[name] else nil
end

local learnedForm: { [string]: number } = {}
local tryForm: { [string]: number } = {}
local trials: { [string]: Map } = {}

function Court.fire(name: string, forms: { (any) -> ...any }, check: ((any) -> boolean)?, adapt: ((any, any) -> any)?, context: any): boolean
    if Court.HandsOff and not Court.Closing then
        Court.touch("held back " .. name)
        return false
    end
    local remote = Court.input(name)
    if not remote then
        return false
    end
    local copied = Court.copied(name)
    if type(copied) == "table" then
        local args = if adapt then adapt(copied, context) else copied
        return Court.send(remote, table.unpack(args, 1, args.n or #args))
    end
    local index = learnedForm[name] or tryForm[name] or 1
    if index > #forms then
        index = 1
    end
    local sent = Court.send(remote, forms[index](context))
    if check and not learnedForm[name] then
        local trial = trials[name]
        if not trial then
            trial = {}
            trials[name] = trial
        end
        trial.Index = index
        trial.Count = #forms
        trial.Until = os.clock() + 0.6
        trial.Check = check
        trial.Context = context
        trial.Live = true
    end
    return sent
end

local function settleTrials(now: number)
    for name, trial in trials do
        if trial.Live then
            local ok, worked = pcall(trial.Check, trial.Context)
            if ok and worked == true then
                learnedForm[name] = trial.Index
                trial.Live = false
                trial.Context = nil
            elseif not ok or now >= trial.Until then
                tryForm[name] = trial.Index % trial.Count + 1
                trial.Live = false
                trial.Context = nil
            end
        end
    end
end

local virtualInput: any = nil
local virtualTried = false
local keyChannel = 0
local keyDead = false

local KEYS: { [string]: { any } } = {
    W = { Enum.KeyCode.W, 0x57 },
    A = { Enum.KeyCode.A, 0x41 },
    S = { Enum.KeyCode.S, 0x53 },
    D = { Enum.KeyCode.D, 0x44 },
}
local pressed: { [string]: boolean } = {}

local function virtualKey(down: boolean, code: any)
    virtualInput:SendKeyEvent(down, code, false, game)
end

local function channel(): number
    if keyChannel ~= 0 then
        return keyChannel
    end
    if not virtualTried then
        virtualTried = true
        local ok, found = pcall(game.GetService, game, "VirtualInputManager")
        if ok and found then
            virtualInput = found
        end
    end
    if virtualInput then
        keyChannel = 1
    elseif Env.keypress and Env.keyrelease then
        keyChannel = 2
    end
    return keyChannel
end

local function send(name: string, down: boolean): boolean
    local entry = KEYS[name]
    local way = channel()
    if way == 1 then
        if pcall(virtualKey, down, entry[1]) then
            return true
        end
        virtualInput = nil
        keyChannel = 0
        way = channel()
    end
    if way == 2 then
        if not down or Court.Focused then
            return (pcall(if down then Env.keypress else Env.keyrelease, entry[2]))
        end
        return false
    end
    keyDead = true
    return false
end

local holders: { [string]: { [string]: boolean } } = {}

local function applyKeys()
    local wanted: { [string]: boolean } = {}
    for _, set in holders do
        for name, down in set do
            if down then
                wanted[name] = true
            end
        end
    end
    if keyDead or Court.Forced or Court.HandsOff or not Court.Focused or userInput.KeyboardEnabled == false or userInput:GetFocusedTextBox() ~= nil then
        table.clear(wanted)
    end
    for name in KEYS do
        local want = wanted[name] == true
        if (pressed[name] == true) ~= want then
            if want then
                pressed[name] = send(name, true) or nil
            else
                pressed[name] = nil
                send(name, false)
            end
        end
    end
    Court.Held = pressed.W == true
    local any = next(pressed) ~= nil
    if Court.Keys and not any then
        Court.KeysOff = os.clock()
    end
    Court.Keys = any
end

local function applyKey()
    applyKeys()
end

function Court.hold(owner: string, down: boolean)
    if not down and not holders[owner] then
        return
    end
    holders[owner] = if down then { W = true } else nil
    applyKeys()
end

function Court.canPress(): boolean
    return not keyDead and channel() ~= 0 and Court.Focused and userInput.KeyboardEnabled ~= false
end

function Court.keysIgnored()
    keyDead = true
    applyKeys()
end

function Court.holdKeys(owner: string, set: { [string]: boolean }?)
    if not set and not holders[owner] then
        return
    end
    holders[owner] = set
    applyKeys()
end

function Court.steering(mine: any): boolean
    if Court.UserMoving then
        return true
    end
    if not Court.Keys and os.clock() - Court.KeysOff > 0.3 then
        local humanoid = Court.humanoid(mine)
        if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
            return true
        end
    end
    return Court.userKeys()
end

function Court.userKeys(): boolean
    if userInput:GetFocusedTextBox() then
        return false
    end
    for _, key in MOVE_KEYS do
        local own = (pressed.W and (key == Enum.KeyCode.W)) or (pressed.A and key == Enum.KeyCode.A) or (pressed.S and key == Enum.KeyCode.S) or (pressed.D and key == Enum.KeyCode.D)
        if not own and userInput:IsKeyDown(key) then
            return true
        end
    end
    return false
end
local proxyPart: any = nil
local proxyMover: any = nil

function Court.proxy(): (any?, any?)
    local part = proxyPart
    if not part or part.Parent ~= workspace then
        part = workspace:FindFirstChild("ProxyCharacter")
        proxyPart = part
        proxyMover = nil
    end
    if not part or not part:IsA("BasePart") then
        return nil, nil
    end
    local mover = proxyMover
    if not mover or mover.Parent ~= part then
        mover = part:FindFirstChild("MovementVelocity")
        proxyMover = if mover and mover:IsA("BodyVelocity") then mover else nil
        mover = proxyMover
    end
    return part, mover
end

function Court.heading(): Vector3?
    if userInput:GetFocusedTextBox() then
        return nil
    end
    local camera = workspace.CurrentCamera
    if not camera then
        return nil
    end
    local x, z = 0, 0
    if userInput:IsKeyDown(Enum.KeyCode.W) or userInput:IsKeyDown(Enum.KeyCode.Up) then
        z += 1
    end
    if userInput:IsKeyDown(Enum.KeyCode.S) or userInput:IsKeyDown(Enum.KeyCode.Down) then
        z -= 1
    end
    if userInput:IsKeyDown(Enum.KeyCode.D) then
        x += 1
    end
    if userInput:IsKeyDown(Enum.KeyCode.A) then
        x -= 1
    end
    if x == 0 and z == 0 then
        return nil
    end
    local frame = camera.CFrame
    local forward = flat(frame.LookVector)
    if forward.Magnitude < 0.01 then
        forward = flat(frame.UpVector)
    end
    if forward.Magnitude < 0.01 then
        return nil
    end
    forward = forward.Unit
    local right = Vector3.new(-forward.Z, 0, forward.X)
    return (forward * z + right * x).Unit
end

function Court.sprintHeld(): boolean
    local hook = Env.get(HOOK)
    local calls = if type(hook) == "table" then hook.Calls else nil
    local last = if type(calls) == "table" then calls.Sprint else nil
    if type(last) == "table" and last[1] == true then
        return true
    end
    return userInput:GetFocusedTextBox() == nil and userInput:IsKeyDown(Enum.KeyCode.LeftShift)
end

local rimCache: { any } = {}
local fronts: { [any]: any } = {}
local hoopsFolder: any = nil
local nextRimScan = 0
local rimWait = 0.5

local function clearRims()
    table.clear(rimCache)
    table.clear(fronts)
    hoopsFolder = nil
end

function Court.rims(): { any }
    if rimCache[1] then
        return rimCache
    end
    local now = os.clock()
    if now < nextRimScan then
        return rimCache
    end
    local hoops = workspace:FindFirstChild("Hoops", true)
    if hoops then
        hoopsFolder = hoops
        for _, descendant in hoops:GetDescendants() do
            if descendant.Name == "Rim" and descendant:IsA("BasePart") then
                table.insert(rimCache, descendant)
            end
        end
    end
    rimWait = if rimCache[1] then 0.5 else math.min(rimWait * 1.5, 4)
    nextRimScan = now + rimWait
    return rimCache
end

function Court.rimDistance(position: Vector3): (number?, any?)
    local best: number? = nil
    local bestRim: any? = nil
    for _, rim in Court.rims() do
        local offset = rim.Position - position
        local distance = math.sqrt(offset.X * offset.X + offset.Z * offset.Z)
        if not best or distance < best then
            best = distance
            bestRim = rim
        end
    end
    return best, bestRim
end

function Court.facingRim(root: any, facing: number, range: number): (any?, number)
    local look = flat(root.CFrame.LookVector)
    local origin = root.Position
    local best: any? = nil
    local bestDistance = math.huge
    for _, rim in Court.rims() do
        local toRim = flat(rim.Position - origin)
        local away = toRim.Magnitude
        local dot = if away > 0.01 then look:Dot(toRim) / away else 1
        if dot >= facing and away <= range and away < bestDistance then
            best = rim
            bestDistance = away
        end
    end
    return best, bestDistance
end

local function boardFront(rim: any): (Vector3?, Vector3?)
    local hoops = hoopsFolder
    if not hoops then
        return nil, nil
    end
    local model = rim
    while model.Parent and model.Parent ~= hoops do
        model = model.Parent
    end
    if model == rim or model.Parent ~= hoops then
        return nil, nil
    end
    local origin = rim.Position
    local board: any = nil
    local sum = Vector3.zero
    local weight = 0
    for _, descendant in model:GetDescendants() do
        if descendant ~= rim and descendant:IsA("BasePart") then
            local offset = flat(descendant.Position - origin)
            if offset.Magnitude > 14 then
                return nil, nil
            end
            local name = string.lower(descendant.Name)
            if not board and (string.find(name, "board", 1, true) or string.find(name, "glass", 1, true)) then
                board = descendant
            end
            if name ~= "rim" and not string.find(name, "net", 1, true) then
                local size = descendant.Size
                local volume = size.X * size.Y * size.Z
                sum += offset * volume
                weight += volume
            end
        end
    end
    local named: Vector3? = nil
    if board then
        local away = flat(origin - board.Position)
        if away.Magnitude > 0.3 then
            named = away.Unit
        end
    end
    local massed: Vector3? = nil
    if weight > 0 then
        local away = sum / -weight
        if away.Magnitude > 0.3 then
            massed = away.Unit
        end
    end
    return named, massed
end

local function oppositeFront(rim: any): (Vector3?, boolean)
    local origin = rim.Position
    local first: any = nil
    local best: any = nil
    local bestDistance = math.huge
    local single = true
    for _, other in rimCache do
        if other ~= rim then
            local distance = flat(other.Position - origin).Magnitude
            if distance >= FAR_RIM then
                if not first then
                    first = other
                elseif (other.Position - first.Position).Magnitude > 25 then
                    single = false
                end
                if distance < bestDistance then
                    best = other
                    bestDistance = distance
                end
            end
        end
    end
    if not best then
        return nil, false
    end
    return flat(best.Position - origin).Unit, single
end

function Court.front(rim: any): Vector3?
    local known = fronts[rim]
    if known ~= nil then
        return if known then known else nil
    end
    local found: Vector3? = nil
    local ok, named, massed = pcall(boardFront, rim)
    local across, single = oppositeFront(rim)
    if ok and named then
        found = named
    elseif across and single then
        found = across
    elseif ok and massed then
        found = massed
    else
        found = across
    end
    fronts[rim] = found or false
    return found
end

function Court.frontOf(rim: any, position: Vector3): (number?, number)
    local front = Court.front(rim)
    if not front then
        return nil, 0
    end
    local offset = flat(position - rim.Position)
    local ahead = offset:Dot(front)
    return ahead, (offset - front * ahead).Magnitude
end

function Court.goal(character: any): any?
    local entry = record(character)
    local value = entry.Goal
    if not value or not value:IsDescendantOf(character) then
        local folder = character:FindFirstChild("Attributes")
        value = if folder then folder:FindFirstChild("Goal") else nil
        entry.Goal = value
    end
    if not value or not value:IsA("ObjectValue") then
        return nil
    end
    local target = value.Value
    local position: Vector3? = nil
    if target and target:IsA("BasePart") then
        position = target.Position
    elseif target and target:IsA("Model") then
        position = target:GetPivot().Position
    end
    if not position then
        return nil
    end
    local distance, rim = Court.rimDistance(position)
    return if distance and distance < 20 then rim else nil
end

function Court.nearestFoe(position: Vector3): number
    local best = math.huge
    local roots = Court.Roots
    local foe = Court.Foe
    for index = 1, Court.Count do
        if foe[index] then
            local distance = (roots[index].Position - position).Magnitude
            if distance < best then
                best = distance
            end
        end
    end
    return best
end

local ballFolder: any = nil
local ballPart: any = nil
local nextBall = 0

function Court.ball(): any?
    local now = Court.Now
    local ball = ballPart
    if ball and now < nextBall and ballFolder and ball:IsDescendantOf(ballFolder) then
        return ball
    end
    nextBall = now + 0.25
    ballPart = nil
    local folder = ballFolder
    if not folder or folder.Parent ~= workspace then
        folder = workspace:FindFirstChild("Basketballs")
        ballFolder = folder
    end
    if not folder then
        return nil
    end
    local origin = if Court.Root then Court.Root.Position else nil
    local bestDistance = math.huge
    for _, child in folder:GetChildren() do
        local part: any = nil
        if child:IsA("BasePart") then
            part = child
        elseif child:IsA("Model") then
            part = child.PrimaryPart
        end
        if part then
            local distance = if origin then (part.Position - origin).Magnitude else 0
            if distance < bestDistance then
                bestDistance = distance
                ballPart = part
            end
        end
    end
    return ballPart
end

function Court.ballNear(position: Vector3, reach: number): boolean?
    Court.ball()
    local folder = ballFolder
    if not folder then
        return nil
    end
    local any = false
    for _, child in folder:GetChildren() do
        local part: any = nil
        if child:IsA("BasePart") then
            part = child
        elseif child:IsA("Model") then
            part = child.PrimaryPart
        end
        if part then
            any = true
            if (part.Position - position).Magnitude <= reach then
                return true
            end
        end
    end
    return if any then false else nil
end

local lastBall: Vector3? = nil

local function trackDead(inbound: boolean)
    if inbound then
        Court.Dead = true
    elseif Court.TeamBall or Court.FoeBall then
        Court.Dead = false
        lastBall = nil
        return
    end
    local ball = Court.ball()
    if not ball then
        lastBall = nil
        return
    end
    local where: Vector3 = ball.Position
    local before = lastBall
    lastBall = where
    if not before or where.Y >= before.Y then
        return
    end
    for _, rim in Court.rims() do
        local center: Vector3 = rim.Position
        local dx, dz = where.X - center.X, where.Z - center.Z
        if dx * dx + dz * dz < 1.44 and before.Y >= center.Y - 0.3 and where.Y < center.Y - 0.3 then
            Court.Dead = true
        end
    end
end

local function trim(list: { any }, from: number, to: number)
    for index = from, to do
        list[index] = nil
    end
end

function Court.refresh(now: number)
    Court.Now = now
    updatePing(now)
    settleTrials(now)
    local first = rimCache[1]
    if first and not first:IsDescendantOf(workspace) then
        clearRims()
    end
    local folder = characters(now)
    local player = players.LocalPlayer
    local mine = if folder and player then folder:FindFirstChild(player.Name) else nil
    local root = if mine then Court.root(mine) else nil
    Court.Mine = mine
    Court.Root = root
    Court.Action = if mine then mine:GetAttribute("Action") else nil
    Court.HasBall = mine ~= nil and Court.holds(mine)
    local forced = Court.forced(mine)
    if mine and (Court.walking(mine) or mine:GetAttribute("Stunned") == true or Court.Action == "Stunned") then
        Court.FreeAt = now
    end
    if mine and Court.walking(mine) then
        Court.WalkAt = now
    end
    local hands = mine ~= nil and (forced or now - (Court.FreeAt or -math.huge) < GRACE)
    if not hands then
        table.clear(Court.Touched)
    end
    if forced ~= Court.Forced or hands ~= Court.HandsOff then
        Court.Forced = forced
        Court.HandsOff = hands
        applyKeys()
    end
    local chars, roots, foe, carry, held = Court.Chars, Court.Roots, Court.Foe, Court.Carry, Court.Ball
    local count = 0
    local teamBall = Court.HasBall
    local foeBall = false
    local foul = Court.Action == "Fouled"
    local inbound = Court.Action == "Inbounding"
    if folder and mine then
        for _, character in roster do
            if character ~= mine and character.Parent == folder and character:GetAttribute("TeamIndex") ~= nil then
                local other = Court.root(character)
                if other then
                    count += 1
                    local theirAction = character:GetAttribute("Action")
                    if theirAction == "Inbounding" or character:GetAttribute("Inbounding") == true then
                        inbound = true
                    end
                    if theirAction == "Fouled" then
                        foul = true
                    end
                    local enemy = Court.enemy(mine, character)
                    local has = Court.holds(character)
                    chars[count] = character
                    roots[count] = other
                    foe[count] = enemy
                    carry[count] = has
                    held[count] = has and Court.ballNear(other.Position, BALL_REACH) ~= false
                    if has then
                        if enemy then
                            foeBall = true
                        else
                            teamBall = true
                        end
                    end
                end
            end
        end
    end
    local before = Court.Count
    if before > count then
        trim(chars, count + 1, before)
        trim(roots, count + 1, before)
        trim(foe, count + 1, before)
        trim(carry, count + 1, before)
        trim(held, count + 1, before)
    end
    Court.Count = count
    Court.TeamBall = teamBall
    Court.FoeBall = foeBall
    Court.Foul = foul
    local foeHeld = false
    for index = 1, count do
        if foe[index] and held[index] then
            foeHeld = true
            break
        end
    end
    Court.FoeHeld = foeHeld
    trackDead(inbound)
end

local links: { any } = {}

function Court.start()
    local ok = pcall(function()
        table.insert(links, userInput.WindowFocusReleased:Connect(function()
            Court.Focused = false
            applyKey()
        end))
        table.insert(links, userInput.WindowFocused:Connect(function()
            Court.Focused = true
        end))
    end)
    if not ok then
        Court.Focused = true
    end
end

function Court.stop()
    table.clear(holders)
    applyKey()
    for _, link in links do
        pcall(link.Disconnect, link)
    end
    table.clear(links)
    unbindRoster()
    table.clear(trials)
end

return Court
end
modules["aero"] = function(...)

local import: (string) -> any = ...
local Env: typeof(require("./env")) = import("env")

local Aero = {}

type Map = { [string]: any }

local NAME = "__PBInputWrap"
local VERSION = 1
local WRAP = { "Shoot", "Sprint", "Steal", "Pass", "Dribble", "Jump", "Clutch", "HoldG" }
local CANDIDATES = { "Meter", "Gui", "Player", "UserInput", "Replication", "Team" }
local GC_CHUNK = 4000

local players: any = game:GetService("Players")

local function inputOf(services: any): any?
    if type(services) ~= "table" then
        return nil
    end
    local input = rawget(services, "InputService")
    if type(input) ~= "table" then
        return nil
    end
    local shoot = rawget(input, "Shoot")
    if type(shoot) ~= "table" or type(rawget(shoot, "Fire")) ~= "function" then
        return nil
    end
    return input
end

local function servicesOf(value: any): any?
    return value.Services
end

local function load(module: any): (boolean, any)
    local ok, value = pcall(require, module)
    if ok and type(value) == "table" then
        return ok, value
    end
    local set, get = Env.setidentity, Env.getidentity
    if not set then
        return ok, value
    end
    local before: any = nil
    if get then
        local read, level = pcall(get)
        before = if read then level else nil
    end
    pcall(set, 2)
    local again, result = pcall(require, module)
    pcall(set, if type(before) == "number" then before else 8)
    return again, result
end

local function fromModule(module: any): any?
    if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
        return nil
    end
    local ok, value = load(module)
    if not ok or type(value) ~= "table" then
        return nil
    end
    local got, services = pcall(servicesOf, value)
    return if got then inputOf(services) else nil
end

local function controllers(): { any }
    local list = {}
    local player = players.LocalPlayer
    local scripts = if player then player:FindFirstChild("PlayerScripts") else nil
    local root = if scripts then scripts:FindFirstChild("Aero") else nil
    local folder = if root then root:FindFirstChild("Controllers") else nil
    if folder then
        for _, name in CANDIDATES do
            local child = folder:FindFirstChild(name)
            if child then
                table.insert(list, child)
            end
        end
    end
    local modules = if root then root:FindFirstChild("Modules") else nil
    local components = if modules then modules:FindFirstChild("Components") else nil
    local input = if components then components:FindFirstChild("Input") else nil
    if input then
        for _, name in { "Keyboard", "Gamepad", "Mobile" } do
            local child = input:FindFirstChild(name)
            if child then
                table.insert(list, child)
            end
        end
    end
    return list
end

local function fromGc(): any?
    local filter = Env.filtergc
    if filter then
        local ok, found = pcall(filter, "table", { Keys = { "InputService", "GameplayService" } }, true)
        if ok then
            return inputOf(found)
        end
        return nil
    end
    local walk = Env.getgc
    if not walk then
        return nil
    end
    local ok, list = pcall(walk, true)
    if not ok or type(list) ~= "table" then
        return nil
    end
    for index, value in list do
        if type(value) == "table" then
            local found = inputOf(value)
            if found then
                return found
            end
        end
        if index % GC_CHUNK == 0 then
            task.wait()
        end
    end
    return nil
end

function Aero.find(light: boolean?): any?
    local existing = Env.get(NAME)
    if type(existing) == "table" and existing.Version == VERSION and type(existing.Input) == "table" then
        return existing.Input
    end
    for _, module in controllers() do
        local input = fromModule(module)
        if input then
            return input
        end
    end
    if light then
        return nil
    end
    return fromGc()
end

function Aero.install(handler: (string, ...any) -> boolean, light: boolean?): (Map?, string?)
    local input = Aero.find(light)
    if not input then
        return nil, "unsupported"
    end
    local existing = Env.get(NAME)
    local reuse = type(existing) == "table" and existing.Version == VERSION and existing.Input == input
    if reuse then
        for name, wrapper in existing.Wrappers do
            local signal = rawget(input, name)
            if type(signal) ~= "table" or rawget(signal, "Fire") ~= wrapper then
                reuse = false
            end
        end
    end
    if type(existing) == "table" and not reuse then
        existing.Off = true
        existing.Handler = nil
    end
    local state: Map = if reuse then existing else { Version = VERSION, Input = input, Originals = {}, Wrappers = {} }
    state.Handler = handler
    state.Off = nil
    for _, name in WRAP do
        local signal = rawget(input, name)
        local current = if type(signal) == "table" then rawget(signal, "Fire") else nil
        if type(current) == "function" and current ~= state.Wrappers[name] then
            local original = current
            local function wrapper(self: any, ...: any): ...any
                if not state.Off then
                    local handle = state.Handler
                    if handle then
                        local ok, hold = pcall(handle, name, ...)
                        if ok and hold == true then
                            return
                        end
                    end
                end
                return original(self, ...)
            end
            state.Originals[name] = original
            state.Wrappers[name] = wrapper
            rawset(signal, "Fire", wrapper)
        end
    end
    Env.set(NAME, state)
    return state, nil
end

function Aero.intact(): boolean
    local state = Env.get(NAME)
    if type(state) ~= "table" or state.Off or type(state.Input) ~= "table" then
        return false
    end
    local signal = rawget(state.Input, "Shoot")
    return type(signal) == "table" and rawget(signal, "Fire") == state.Wrappers.Shoot
end

function Aero.remove()
    local state = Env.get(NAME)
    if type(state) ~= "table" or state.Version ~= VERSION then
        return
    end
    state.Off = true
    state.Handler = nil
    local input = state.Input
    local clean = true
    for name, wrapper in state.Wrappers do
        local signal = if type(input) == "table" then rawget(input, name) else nil
        if type(signal) == "table" then
            if rawget(signal, "Fire") == wrapper then
                rawset(signal, "Fire", state.Originals[name])
            else
                clean = false
            end
        end
    end
    if clean then
        Env.set(NAME, nil)
    end
end

return Aero
end
modules["hook"] = function(...)

local import: (string) -> any = ...
local Env: typeof(require("./env")) = import("env")
local Court: typeof(require("./court")) = import("court")
local Aero: typeof(require("./aero")) = import("aero")

local Hook = {}

type Map = { [string]: any }

local NAME = "__PBShootHook"
local VERSION = 6

local CAPTURE = { Sprint = true, Steal = true, Pass = true, Dribble = true, Jump = true, Clutch = true, HoldG = true }

local getMethod: any = Env.getnamecallmethod
local ours: any = Env.checkcaller
local stopped = false

local function isPress(args: any): boolean
    for index = 1, args.n do
        local value = args[index]
        if type(value) == "boolean" then
            return value
        end
        if type(value) == "table" then
            for _, inner in value do
                if type(inner) == "boolean" then
                    return inner
                end
            end
        end
    end
    return true
end

local function dribbleKey(args: any): string
    for index = 1, args.n do
        local value = args[index]
        if type(value) == "string" then
            return value
        end
        if type(value) == "table" then
            for _, inner in value do
                if type(inner) == "string" then
                    return inner
                end
            end
        end
    end
    return "any"
end

local function capture(state: Map, name: string, args: any)
    local press = isPress(args)
    state.Calls[name] = args
    if press then
        state.Press[name] = args
    end
    if name == "Dribble" then
        local key = dribbleKey(args)
        if press or not state.Dribbles[key] then
            state.Dribbles[key] = args
        end
    end
    if name == "Sprint" and press then
        task.wait(0.25)
        local mine = Court.mine()
        if mine ~= nil and mine:GetAttribute("Sprinting") == true then
            state.SprintOn = args
        end
    end
end

local function watch(state: Map, remote: any, ...: any): boolean
    if not getMethod or getMethod() ~= "FireServer" or typeof(remote) ~= "Instance" then
        return false
    end
    if Court.Sending > 0 or (ours and ours()) then
        return false
    end
    local parent = remote.Parent
    if not parent or parent.Name ~= "InputService" then
        return false
    end
    local name = remote.Name
    if CAPTURE[name] then
        local args = table.pack(...)
        local queue = state.Queue
        if #queue < 32 then
            queue[#queue + 1] = { name, args }
        end
        local owner = state.Owner
        if name == "Dribble" and type(owner) == "table" and type(owner.BlockDribble) == "function" then
            return owner.BlockDribble(args) == true
        end
        return false
    end
    if name ~= "Shoot" then
        return false
    end
    local owner = state.Owner
    if type(owner) ~= "table" then
        return false
    end
    local data = ...
    if type(data) ~= "table" then
        return false
    end
    local flag = rawget(data, "Shoot")
    if flag == true then
        owner.KeyDown = true
        owner.PressPending = true
        owner.DunkPress = rawget(data, "UseSpace") == true
        return false
    end
    if flag ~= false then
        return false
    end
    owner.KeyDown = false
    if rawget(data, "Input") ~= nil then
        return false
    end
    if owner.holding(owner) then
        if owner.Held == nil then
            owner.Held = os.clock()
        end
        return true
    end
    owner.passed(owner)
    return false
end

local function wrapped(state: Map, name: string, ...: any): boolean
    if CAPTURE[name] then
        local args = table.pack(...)
        task.spawn(capture, state, name, args)
        local owner = state.Owner
        if name == "Dribble" and type(owner) == "table" and type(owner.BlockDribble) == "function" then
            return owner.BlockDribble(args) == true
        end
        return false
    end
    if name ~= "Shoot" then
        return false
    end
    local owner = state.Owner
    if type(owner) ~= "table" or type(owner.shootCall) ~= "function" then
        return false
    end
    return owner:shootCall((...)) == true
end

local function rawNamecall(): any
    local getMeta = Env.getrawmetatable
    if not getMeta then
        return nil
    end
    local ok, meta = pcall(getMeta, game)
    if ok and type(meta) == "table" then
        return rawget(meta, "__namecall")
    end
    return nil
end

local function writeNamecall(target: any): boolean
    local getMeta = Env.getrawmetatable
    if not getMeta or type(target) ~= "function" then
        return false
    end
    return (pcall(function()
        local meta = getMeta(game)
        local lock = Env.setreadonly
        if lock then
            lock(meta, false)
        end
        rawset(meta, "__namecall", target)
        if lock then
            lock(meta, true)
        end
    end))
end

local function probe(): boolean
    local folder = Instance.new("Folder")
    folder.Name = "probe"
    local found = folder:FindFirstChild("none")
    local isFolder = folder:IsA("Folder")
    local isPart = folder:IsA("BasePart")
    local service = game:GetService("Players")
    local children = workspace:GetChildren()
    folder:Destroy()
    return found == nil and isFolder == true and isPart == false and typeof(service) == "Instance" and type(children) == "table"
end

local function live(state: Map): (boolean, boolean)
    local seen = false
    local before, off = state.Watch, state.Off
    state.Watch = function(): boolean
        seen = true
        return false
    end
    state.Off = nil
    local ok, works = pcall(probe)
    state.Watch = before
    state.Off = off
    return seen, ok and works == true
end

local function putBack(state: Map)
    local target: any = state.Clean or state.Original
    if type(target) ~= "function" then
        return
    end
    local hookMeta = Env.hookmetamethod
    if hookMeta then
        pcall(hookMeta, game, "__namecall", target)
    end
    local current = rawNamecall()
    if current ~= nil and current == state.Wrapped then
        writeNamecall(target)
    end
end

function Hook.install(): (any?, string?)
    local existing = Env.get(NAME)
    if type(existing) == "table" and existing.Mode == "wrap" then
        existing.Owner = nil
        Env.set(NAME, nil)
        existing = nil
    end
    if type(existing) == "table" then
        if existing.Version ~= VERSION or existing.Broken then
            existing.Owner = nil
            return nil, if existing.Broken then "broken" else "old"
        end
        local _, answers = live(existing)
        if answers then
            existing.Claim = Hook
            existing.Watch = watch
            existing.Off = nil
            return existing, nil
        end
        existing.Off = true
        existing.Owner = nil
        Env.set(NAME, nil)
    end
    local hookMeta = Env.hookmetamethod
    local original: any = rawNamecall()
    if not getMethod or (not hookMeta and (type(original) ~= "function" or not Env.setreadonly)) then
        return nil, "unsupported"
    end
    local clean: any = original
    if type(original) == "function" and Env.clonefunction then
        local cloned, copy = pcall(Env.clonefunction, original)
        if cloned and type(copy) == "function" then
            clean = copy
        end
    end
    local state: Map = {
        Owner = nil,
        Version = VERSION,
        Watch = watch,
        SprintOn = nil,
        Calls = {},
        Queue = {},
        Press = {},
        Dribbles = {},
        Original = original,
        Clean = clean,
        Claim = Hook,
    }
    local old: any = clean
    local function body(self: any, ...: any): ...any
        if not state.Off and getMethod and getMethod() == "FireServer" then
            local ok, hold = pcall(state.Watch, state, self, ...)
            if ok and hold == true then
                return
            end
        end
        return (old or clean)(self, ...)
    end
    if stopped then
        return nil, "stopped"
    end
    local why = "unsupported"
    local wrappers: { any } = {}
    if Env.newcclosure then
        table.insert(wrappers, Env.newcclosure)
    end
    table.insert(wrappers, false)
    Env.set(NAME, state)
    for _, wrap in wrappers do
        local wrapped: any = body
        if wrap then
            local made, closure = pcall(wrap, body)
            wrapped = if made and type(closure) == "function" then closure else nil
        end
        if wrapped then
            state.Wrapped = wrapped
            state.Off = nil
            old = clean
            local placed = false
            if hookMeta then
                local hookedOk, hooked = pcall(hookMeta, game, "__namecall", wrapped)
                placed = hookedOk
                if hookedOk and type(hooked) == "function" and hooked ~= wrapped then
                    old = hooked
                    if type(state.Clean) ~= "function" then
                        state.Clean = hooked
                        clean = hooked
                    end
                end
            elseif type(clean) == "function" then
                placed = writeNamecall(wrapped)
            end
            local seen, works = live(state)
            local fine = placed and works
            if stopped then
                state.Off = true
                old = clean
                putBack(state)
                if live(state) then
                    state.Broken = true
                else
                    Env.set(NAME, nil)
                end
                return nil, "stopped"
            end
            if fine then
                return state, nil
            end
            why = "broken"
            state.Off = true
            old = clean
            if seen or not works then
                putBack(state)
                if live(state) then
                    state.Broken = true
                    state.Owner = nil
                    return nil, "broken"
                end
            end
        end
    end
    Env.set(NAME, nil)
    return nil, why
end

function Hook.drain()
    local state = Env.get(NAME)
    if type(state) ~= "table" or state.Claim ~= Hook then
        return
    end
    local queue = state.Queue
    if type(queue) ~= "table" or #queue == 0 then
        return
    end
    state.Queue = {}
    for _, item in queue do
        task.spawn(capture, state, item[1], item[2])
    end
end

local function bindWrap(owner: any, light: boolean?): boolean
    local existing = Env.get(NAME)
    local state: Map = if type(existing) == "table" and existing.Mode == "wrap" and existing.Version == VERSION
        then existing
        else { Version = VERSION, Mode = "wrap", SprintOn = nil, Calls = {}, Queue = {}, Press = {}, Dribbles = {} }
    if type(existing) == "table" and existing ~= state then
        existing.Owner = nil
    end
    local installed = Aero.install(function(name: string, ...: any): boolean
        return wrapped(state, name, ...)
    end, light)
    if not installed then
        return false
    end
    state.Claim = Hook
    state.Off = nil
    state.Owner = owner
    Env.set(NAME, state)
    return true
end

function Hook.bind(owner: any, allowHook: boolean?, light: boolean?): (boolean, string?)
    local done, wrappedOk = pcall(bindWrap, owner, light)
    if done and wrappedOk then
        return true, "wrap"
    end
    if allowHook == false then
        return false, "safe"
    end
    local ok, state, why = pcall(Hook.install)
    if ok and type(state) == "table" then
        state.Owner = owner
        return true, "hook"
    end
    return false, if ok then why else "broken"
end

function Hook.owned(owner: any): boolean
    local state = Env.get(NAME)
    if type(state) ~= "table" or state.Claim ~= Hook or state.Owner ~= owner or state.Off then
        return false
    end
    if state.Mode == "wrap" then
        return Aero.intact()
    end
    return true
end

function Hook.mode(): string?
    local state = Env.get(NAME)
    if type(state) ~= "table" or state.Claim ~= Hook or state.Off then
        return nil
    end
    return if state.Mode == "wrap" then "wrap" else "hook"
end

function Hook.remove()
    stopped = true
    local state = Env.get(NAME)
    if type(state) ~= "table" or state.Version ~= VERSION or state.Claim ~= Hook then
        return
    end
    if state.Mode == "wrap" then
        state.Off = true
        state.Owner = nil
        Aero.remove()
        Env.set(NAME, nil)
        return
    end
    state.Off = true
    state.Owner = nil
    if state.Broken then
        return
    end
    local current = rawNamecall()
    if current == nil or current ~= state.Wrapped then
        return
    end
    putBack(state)
    local seen = live(state)
    state.Off = true
    if not seen then
        Env.set(NAME, nil)
    end
end

return Hook
end
modules["autogreen"] = function(...)

local import: (string) -> any = ...
local Config: typeof(require("./config")) = import("config")
local Court: typeof(require("./court")) = import("court")
local Env: typeof(require("./env")) = import("env")
local Hook: typeof(require("./hook")) = import("hook")

local AutoGreen = {}
AutoGreen.__index = AutoGreen

type Map = { [string]: any }

local LEARNED = "__PBPeaks"
local PEAK_FILE = "oklo scripts/practicalbasketball/peaks.json"
local TIMING_PERFECT = 5

local TAP_TIMEOUT = 0.8
local HOLD_TIMEOUT = 4.5
local DUNK_TIMEOUT = 0.9
local LAYUP_RANGE = 13
local LOST_GRACE = 0.3
local SERVER_STEP = 1 / 60
local STALL = 0.075

local METERED: { [string]: boolean } = { Shooting = true, Dunking = true, ContactLayup = true, ClutchLayup = true }
local PRESHOT: { [string]: boolean } = { Gathering = true, CatchingPass = true, PassTransition = true, CatchingLob = true, AwaitingPass = true }
local WAITING: { [string]: boolean } = { Dribbling = true, Gathering = true, CatchingPass = true, PassTransition = true, CatchingLob = true, AwaitingPass = true }

local PRESS = { Shoot = true, Input = "E" }
local PRESS_SPACE = { Shoot = true, Input = "E", UseSpace = true }
local RELEASE = { Shoot = false }

local LOG_FILE = "oklo scripts/practicalbasketball/greenlog.txt"
local LOG_LIMIT = 6000

AutoGreen.METERED = METERED
AutoGreen.PRESHOT = PRESHOT

local function learned(): Map
    local store = Env.get(LEARNED)
    if type(store) ~= "table" then
        store = Env.readJson(PEAK_FILE) or {}
        Env.set(LEARNED, store)
    end
    return store
end

local function shotSpeed(character: any): number
    local value = character:GetAttribute("ShotSpeed")
    return if type(value) == "number" and value > 0.05 then value else 1
end

local function meterKind(character: any, meters: { any }): string?
    for index = #meters, 1, -1 do
        local gui = meters[index]
        if not gui:IsDescendantOf(character) then
            table.remove(meters, index)
        elseif gui.Enabled and string.sub(gui.Name, -5) == "Meter" then
            return string.sub(gui.Name, 1, -6)
        end
    end
    return nil
end

local function liveShot(character: any, action: any, meters: { any }): boolean
    if METERED[action] then
        return true
    end
    if character:GetAttribute("ReleasedShot") ~= false or WAITING[action] then
        return false
    end
    return meterKind(character, meters) ~= nil
end

AutoGreen.liveShot = liveShot

function AutoGreen.trace(self: any, text: string)
    if self.Tracing ~= true then
        return
    end
    local lines = self.TraceLines
    if not lines then
        lines = {}
        self.TraceLines = lines
        self.TraceZero = os.clock()
    end
    if #lines >= LOG_LIMIT then
        return
    end
    local line = string.format("%8.3f  %s", os.clock() - self.TraceZero, text)
    lines[#lines + 1] = line
    self.TraceDirty = true
    print("[PBGreen] " .. line)
end

function AutoGreen.traceState(self: any, now: number, action: any)
    local shot: any = self.Shot
    local rimText = ""
    local root = Court.Root
    if root then
        local distance, rim = Court.rimDistance(root.Position)
        if distance and rim and distance <= 20 then
            local ahead, aside = Court.frontOf(rim, root.Position)
            rimText = string.format(" rim=%d ahead=%d side=%d", distance, ahead or -99, aside or -99)
        end
    end
    local text = string.format(
        "state action=%s ball=%s armed=%s press=%s held=%s own=%s holdOk=%s early=%s pending=%s key=%s hook=%s shot=%s%s",
        tostring(action), tostring(Court.HasBall), tostring(self.Armed), tostring(self.Press ~= nil), tostring(self.Held ~= nil),
        tostring(self.Own), tostring(self.HoldOk), tostring(self.EarlyAt ~= nil), tostring(self.PressPending == true),
        tostring(self.KeyDown), tostring(self.HookMode or self.HookFailed), if shot then (shot.Kind or "?") else "none",
        if shot and shot.Fired then " fired" else ""
    ) .. rimText
    if text ~= self.TraceLast then
        self.TraceLast = text
        self:trace(text)
    end
    if self.TraceDirty and now - (self.TraceFlush or 0) > 0.5 then
        self.TraceFlush = now
        self.TraceDirty = false
        if type(writefile) == "function" then
            pcall(writefile, LOG_FILE, table.concat(self.TraceLines, "\n"))
        end
    end
end

function AutoGreen.new(read: (string) -> any, notify: (string) -> ()): any
    return setmetatable({
        Read = read,
        Notify = notify,
        Links = {} :: { any },
        Meters = {} :: { any },
        Character = nil :: any,
        Shot = nil :: any,
        LastAuto = -math.huge,
        LastPress = -math.huge,
        IdleAt = 0,
        LostAt = nil :: any,
        Warned = {} :: Map,
        Press = nil :: any,
        Held = nil :: any,
        Own = false,
        Armed = false,
        HasBall = false,
        HoldOk = false,
        KeyDown = nil :: any,
        LastKind = nil :: any,
        Hooked = false,
        HookBound = false,
        HookMode = nil :: any,
        TriedHook = false,
        Binding = false,
        HookCheck = 0,
        HookFailed = nil :: any,
        Stopped = false,
        Feedback = nil :: any,
        Stats = { Total = 0, Perfect = 0, Streak = 0, Last = "-" },
        Rates = {} :: { [string]: number },
        StatsText = nil :: any,
    }, AutoGreen)
end

function AutoGreen.allowed(self: any): boolean
    local root = Court.Root
    if not root then
        return true
    end
    local read = self.Read
    if read("AutoShoot") ~= true then
        return true
    end
    if read("OpenOnly") == true and Court.nearestFoe(root.Position) <= (read("OpenRange") or 6) then
        return false
    end
    local minimum = read("MinShot") or 0
    local maximum = read("MaxShot") or 120
    if minimum > 0 or maximum < 120 then
        local best = Court.rimDistance(root.Position)
        if best and (best < minimum or best > maximum) then
            return false
        end
    end
    return true
end

function AutoGreen.peak(self: any, kind: string): number?
    local value = Config.PEAKS[kind] or learned()[kind]
    return if type(value) == "number" then value else nil
end

function AutoGreen.canHold(self: any): boolean
    return self:allowed()
end

function AutoGreen.fire(self: any, args: Map): boolean
    local remote = Court.input("Shoot")
    if not remote then
        if not self.Warned.Remote then
            self.Warned.Remote = true
            self.Notify("The shoot remote was not found, Auto Green cannot release")
        end
        return false
    end
    return Court.send(remote, args)
end

function AutoGreen.send(self: any)
    self:trace("  SEND release")
    self.Planned = self.NextPlan
    self.NextPlan = nil
    self.Press = nil
    self.Held = nil
    self.Own = false
    self.LostAt = nil
    local shot: any = self.Shot
    if shot then
        shot.Fired = true
    end
    if self:fire(RELEASE) then
        self.LastAuto = os.clock()
    end
end

function AutoGreen.settle(self: any)
    self:trace("  settle held=" .. tostring(self.Held ~= nil))
    if self.Held ~= nil then
        self:send()
    else
        self.Press = nil
        self.Own = false
        self.LostAt = nil
    end
end

function AutoGreen.release(self: any)
    local shot: any = self.Shot
    if not shot or shot.Fired then
        return
    end
    shot.Fired = true
    local character = self.Character
    if not character or not liveShot(character, character:GetAttribute("Action"), self.Meters) then
        self:settle()
        return
    end
    local steady = (shot.Gap or 0) < STALL and (shot.LongFrame or 0) < STALL
    self.NextPlan = { Kind = shot.Kind, Clean = shot.ReleaseAt ~= nil and shot.Timed == true and shot.Sloppy == nil and steady }
    self:send()
    if shot.NewRate and shot.Kind then
        local store = learned()
        store["#" .. shot.Kind] = shot.NewRate
        Env.writeJson(PEAK_FILE, store)
    end
end

function AutoGreen.onPress(self: any)
    local read = self.Read
    if self.Stopped or read("AutoGreen") ~= true then
        self:trace("  onPress ignored, Auto Green off")
        return
    end
    local mine = Court.mine()
    if not mine or (not Court.holds(mine) and not PRESHOT[mine:GetAttribute("Action")]) then
        if mine and (self.KeyDown == true or self.Held ~= nil) then
            self.EarlyAt = os.clock()
        end
        self:trace("  onPress no ball yet, early=" .. tostring(self.EarlyAt ~= nil))
        return
    end
    self.EarlyAt = nil
    local shot: any = self.Shot
    if shot and shot.Fired then
        self:trace("  onPress ignored, shot already fired")
        return
    end
    if self.Press ~= nil then
        self:trace("  onPress repeat, already owned")
        return
    end
    local now = os.clock()
    self.Press = now
    self.LastPress = now
    self.IdleAt = now
    self.LostAt = nil
    self.HoldOk = false
    self:trace("  onPress OWNED, hold E")
end

function AutoGreen.begin(self: any, useSpace: boolean?): boolean
    if self.Stopped or self.Read("AutoGreen") ~= true or self.Press ~= nil or not self:canHold() then
        return false
    end
    self:onPress()
    local press = self.Press
    if press == nil then
        return false
    end
    if not self:fire(if useSpace then PRESS_SPACE else PRESS) then
        self.Press = nil
        return false
    end
    self.Held = press
    self.DunkPress = useSpace == true
    self.Own = true
    self.HoldOk = true
    return true
end

function AutoGreen.earlyWindow(self: any): number
    return math.max(0.3, math.min(Court.Ping, 0.6) + 0.15)
end

function AutoGreen.holding(self: any): boolean
    if self.Armed ~= true then
        return false
    end
    local early = self.EarlyAt
    if early ~= nil and self.Press == nil and os.clock() - early < self:earlyWindow() then
        return true
    end
    if self.PressPending == true and self.Press == nil then
        return self.HoldMode ~= true
    end
    return self.Press ~= nil and self.HoldOk == true
end

function AutoGreen.shootCall(self: any, data: any): boolean
    if type(data) ~= "table" then
        return false
    end
    local flag = rawget(data, "Shoot")
    if self.Tracing then
        self:trace(string.format("CALL Shoot=%s Input=%s UseSpace=%s", tostring(flag), tostring(rawget(data, "Input")), tostring(rawget(data, "UseSpace"))))
    end
    if flag == true then
        self.KeyDown = true
        self.DunkPress = rawget(data, "UseSpace") == true
        self:onPress()
        return false
    end
    if flag ~= false then
        return false
    end
    self.KeyDown = false
    if rawget(data, "Input") ~= nil then
        self.TapAt = os.clock()
        self.TapPending = true
        return false
    end
    if self:holding() then
        if self.Held == nil then
            self.Held = os.clock()
        end
        self:trace("  release HELD back")
        return true
    end
    self:trace("  release passed through")
    self:passed()
    return false
end

function AutoGreen.passed(self: any)
    if self.Held == nil then
        self.Press = nil
        self.LostAt = nil
    end
end

function AutoGreen.sample(self: any, character: any)
    if character ~= self.Character then
        return
    end
    local offset: any = character:GetAttribute("meterOffset")
    local kindOf = typeof(offset)
    if kindOf ~= "Vector2" then
        return
    end
    local value: number = offset.Y
    local action = character:GetAttribute("Action")
    if not liveShot(character, action, self.Meters) then
        self.Shot = nil
        return
    end
    local now = os.clock()
    local read = self.Read
    local shot: any = self.Shot
    if not shot then
        local sloppy: number? = nil
        if math.random() > (read("PerfectChance") or 100) / 100 then
            sloppy = (if math.random() < 0.5 then -1 else 1) * (0.04 + math.random() * 0.05)
        end
        local nearRim = false
        if not self.Own and read("LayupGreen") == false then
            local root = Court.root(character)
            local rimAt = if root then Court.rimDistance(root.Position) else nil
            nearRim = rimAt ~= nil and rimAt <= LAYUP_RANGE
        end
        self.Shot = {
            T0 = now,
            V0 = value,
            Low = value,
            Scale = shotSpeed(character),
            Fired = false,
            Kind = nil,
            Sloppy = sloppy,
            Timed = not nearRim and self:allowed(),
            DunkAt = if action == "Dunking" then now + DUNK_TIMEOUT else nil,
        }
        return
    end
    if value < shot.Low then
        shot.Low = value
    end
    if not shot.Fired then
        shot.Gap = math.max(shot.Gap or 0, now - (shot.SeenAt or now))
        shot.SeenAt = now
    end
    if value - shot.Low > 0.012 then
        shot.Turned = true
    elseif not shot.Turned and now > shot.T0 then
        local at = now - shot.T0
        if not shot.Ln then
            shot.Ln, shot.Lt, shot.Lv, shot.Ltt, shot.Ltv = 1, 0, shot.V0, 0, 0
        end
        shot.Ln += 1
        shot.Lt += at
        shot.Lv += value
        shot.Ltt += at * at
        shot.Ltv += at * value
    end
    if shot.Fired then
        if shot.Kind and not shot.NewRate and not shot.Turned and (shot.Ln or 0) >= 8 then
            self:learnRate(shot)
        end
        return
    end
    if read("AutoGreen") ~= true or not shot.Timed then
        if self.Held ~= nil then
            self:release()
        end
        return
    end
    local elapsed = now - shot.T0
    if elapsed < 0.02 then
        if now == shot.T0 then
            shot.V0 = value
        end
        return
    end
    local kind: string = shot.Kind or meterKind(character, self.Meters) or ""
    if kind == "" then
        if elapsed < 0.12 then
            return
        end
        kind = if action == "Dunking" then "Dunk" else "Shot"
    end
    if not shot.Kind then
        shot.Kind = kind
        self.LastKind = kind
    end
    local peak = self:peak(kind)
    if not peak then
        if value - shot.Low > 0.012 then
            local store = learned()
            store[kind] = shot.Low
            Env.writeJson(PEAK_FILE, store)
            self:release()
        end
        return
    end
    if value - shot.Low > 0.012 then
        self:release()
        return
    end
    shot.Peak = peak
    shot.Latest = value
    shot.Fresh = true
end

function AutoGreen.plan(self: any, now: number)
    local shot: any = self.Shot
    shot.Fresh = false
    local value: number = shot.Latest
    local peak: number = shot.Peak
    local kind: string = shot.Kind
    local read = self.Read
    local elapsed = now - shot.T0
    if not shot.N then
        shot.N, shot.St, shot.Sv, shot.Stt, shot.Stv = 1, 0, shot.V0, 0, 0
    end
    shot.N += 1
    shot.St += elapsed
    shot.Sv += value
    shot.Stt += elapsed * elapsed
    shot.Stv += elapsed * value
    local speed = (value - shot.V0) / elapsed
    local level = value
    local spread = shot.N * shot.Stt - shot.St * shot.St
    local saved = learned()["#" .. kind]
    local scale: number = shot.Scale or 1
    local base: number? = self.Rates[kind] or (if type(saved) == "number" then saved else nil)
    local known: number? = if base then base * scale else nil
    if shot.N >= 6 and spread > 1e-9 then
        speed = (shot.N * shot.Stv - shot.St * shot.Sv) / spread
        level = (shot.Sv - speed * shot.St) / shot.N + speed * elapsed
        if shot.N >= 8 then
            local measured = speed / scale
            self.Rates[kind] = if base then base + (measured - base) * 0.5 else measured
            shot.NewRate = self.Rates[kind]
        end
    elseif known then
        speed = known
        level = (shot.Sv - speed * shot.St) / shot.N + speed * elapsed
    elseif shot.N >= 4 and spread > 1e-9 then
        speed = (shot.N * shot.Stv - shot.St * shot.Sv) / spread
        level = (shot.Sv - speed * shot.St) / shot.N + speed * elapsed
    end
    if speed >= -0.05 or shot.Frozen then
        return
    end
    local remaining = (peak - level) / speed
    local delay = remaining - math.min(self.FrameDt or 0, 1 / 60) * 0.5 - SERVER_STEP * 0.5 - Court.Ping * (read("PingComp") or 100) / 100 + (read("GreenOffset") or 0) / 1000 + (shot.Sloppy or 0) + self:bias(kind)
    shot.Value = value
    shot.SampleAt = now
    shot.Speed = speed
    shot.Peak = peak
    local trusted = shot.N >= 6 or known ~= nil
    if not trusted and shot.N < 3 then
        return
    end
    shot.ReleaseAt = now + delay
    if delay <= 0 then
        self:release()
    elseif delay < 0.03 and trusted then
        shot.Frozen = true
    end
end

function AutoGreen.learnRate(self: any, shot: any)
    local n = shot.Ln
    local spread = n * shot.Ltt - shot.Lt * shot.Lt
    if spread <= 1e-9 then
        return
    end
    local speed = (n * shot.Ltv - shot.Lt * shot.Lv) / spread
    if speed >= -0.05 then
        return
    end
    local kind: string = shot.Kind
    local measured = speed / (shot.Scale or 1)
    local saved = learned()["#" .. kind]
    local base: number? = self.Rates[kind] or (if type(saved) == "number" then saved else nil)
    self.Rates[kind] = if base then base + (measured - base) * 0.5 else measured
    shot.NewRate = self.Rates[kind]
    local store = learned()
    store["#" .. kind] = shot.NewRate
    Env.writeJson(PEAK_FILE, store)
end

function AutoGreen.bias(self: any, kind: string): number
    if self.Read("AutoCalibrate") == false then
        return 0
    end
    local value = learned()["~" .. kind]
    return if type(value) == "number" then value else 0
end

local CALIBRATION = { [1] = 0.018, [2] = 0.009, [3] = 0.0035, [6] = -0.0035, [7] = -0.009, [8] = -0.018 }

function AutoGreen.calibrate(self: any, kind: string?, timing: number)
    local step = CALIBRATION[timing]
    if not kind or kind == "" or not step or self.Read("AutoCalibrate") == false then
        return
    end
    local store = learned()
    local key = "~" .. kind
    local current = if type(store[key]) == "number" then store[key] else 0
    store[key] = math.clamp(current * 0.97 + step, -0.08, 0.08)
    Env.writeJson(PEAK_FILE, store)
end

function AutoGreen.resetCalibration(self: any)
    local store = learned()
    local keys: { string } = {}
    for key, value in store do
        if type(key) == "string" and (string.sub(key, 1, 1) == "~" or type(value) == "number") then
            table.insert(keys, key)
        end
    end
    for _, key in keys do
        store[key] = nil
    end
    local saved = Env.writeJson(PEAK_FILE, store)
    pcall(self.Notify, if saved then "Calibration reset" else "Calibration reset, could not save the file")
end

function AutoGreen.rated(self: any, timing: number)
    local shot: any = self.Shot
    local mine = os.clock() - self.LastAuto < 2
    local plan: any = self.Planned
    self.Planned = nil
    if mine and plan and plan.Clean and plan.Kind then
        self:calibrate(plan.Kind, timing)
    end
    if shot and shot.Kind and timing == TIMING_PERFECT and not self:peak(shot.Kind) then
        local store = learned()
        store[shot.Kind] = shot.Low
        Env.writeJson(PEAK_FILE, store)
    end
    local record = self.Stats
    self.StatsText = nil
    record.Total += 1
    record.Last = Config.TIMINGS[timing] or "?"
    if self.Read("NotifyRelease") == true and mine then
        self.Notify(record.Last)
    end
    if timing == TIMING_PERFECT then
        record.Perfect += 1
        record.Streak += 1
    else
        record.Streak = 0
    end
end

function AutoGreen.detach(self: any)
    for _, link in self.Links do
        pcall(link.Disconnect, link)
    end
    table.clear(self.Links)
    table.clear(self.Meters)
    if self.Press ~= nil or self.Held ~= nil then
        self:settle()
    end
    self.Character = nil
    self.Shot = nil
end

function AutoGreen.attach(self: any, character: any)
    self:detach()
    if not character or self.Stopped then
        return
    end
    self.Character = character
    local links: { any } = self.Links
    local meters: { any } = self.Meters
    local function consider(descendant: any)
        if descendant:IsA("BillboardGui") and not table.find(meters, descendant) then
            table.insert(meters, descendant)
        end
    end
    table.insert(links, character:GetAttributeChangedSignal("meterOffset"):Connect(function()
        self:sample(character)
    end))
    table.insert(links, character:GetAttributeChangedSignal("Action"):Connect(function()
        if self.Character == character and self.Shot and not liveShot(character, character:GetAttribute("Action"), meters) then
            self.Shot = nil
        end
    end))
    table.insert(links, character:GetAttributeChangedSignal("ReleasedShot"):Connect(function()
        local shot: any = self.Shot
        if shot and self.Character == character and character:GetAttribute("ReleasedShot") == true then
            shot.ReleasedAt = os.clock()
        end
    end))
    table.insert(links, character.DescendantAdded:Connect(consider))
    for _, descendant in character:GetDescendants() do
        consider(descendant)
    end
end

function AutoGreen.step(self: any, now: number, dt: number)
    local on = self.Read("AutoGreen") == true
    local action0 = Court.Action
    local character = Court.Mine
    if character ~= self.Character then
        self:attach(character)
    end
    self.Armed = on and character ~= nil
    self.HasBall = on and Court.HasBall
    self.Tracing = Env.get("PBGreenLog") == true
    if self.Tracing then
        self:traceState(now, action0)
    end
    self.HoldMode = true
    if self.Hooked then
        Hook.drain()
    end
    self.FrameDt = math.min(dt, 0.1)
    local watch: any = self.WatchHook
    if watch then
        watch.Sum += dt
        watch.Count += 1
        if now >= watch.Until then
            self.WatchHook = nil
            local average = watch.Sum / math.max(watch.Count, 1)
            if average > math.max(watch.Base * 1.8, 1 / 30) and self.HookMode == "hook" then
                pcall(Hook.remove)
                self.HookBound = false
                self.HookMode = nil
                self.HookFailed = "slow"
                self.Warned.Hook = true
                self.Notify("Auto Green turned its hook off, it slowed this executor down. Hold the shoot key until the green")
            end
        end
    else
        self.FrameAvg = (self.FrameAvg or dt) + (math.min(dt, 0.25) - (self.FrameAvg or dt)) * 0.05
    end
    if self.PressPending then
        self.PressPending = false
        self:onPress()
        if self.Held ~= nil and self.Press ~= nil and self.HoldOk ~= true then
            self:send()
        end
    end
    if self.TapPending then
        self.TapPending = false
        if on and self.Read("TapShoot") == true and Court.HasBall and self.Press == nil and self.Held == nil and self.Shot == nil
            and self.KeyDown ~= true and action0 ~= "Dribbling" and action0 ~= "Dunking" and action0 ~= "Shooting" then
            self:trace("  TAP turned into a shot, action=" .. tostring(action0))
            self:begin()
        else
            self:trace("  TAP left as it is, action=" .. tostring(action0))
        end
    end
    local early: number? = self.EarlyAt
    if early then
        if now - early > self:earlyWindow() or (self.KeyDown ~= true and self.Held == nil) or not on then
            self.EarlyAt = nil
        elseif Court.HasBall then
            self.EarlyAt = nil
            self:onPress()
        end
    end
    if self.Hooked and not self.HookFailed and now >= self.HookCheck then
        self.HookCheck = now + 2
        if self.HookBound and not Hook.owned(self) then
            self.HookBound = false
            self.Hooked = false
        end
    end
    if on and self.HookFailed and not self.Binding and now >= (self.WrapRetry or 0) and (self.Retries or 0) < 8 then
        self.Retries = (self.Retries or 0) + 1
        self.WrapRetry = now + 5 * self.Retries
        task.spawn(function()
            if self.Stopped or self.HookBound or self.Binding then
                return
            end
            self.Binding = true
            local ok, mode = Hook.bind(self, false, true)
            self.Binding = false
            if self.Stopped then
                pcall(Hook.remove)
            elseif ok then
                self.HookBound = true
                self.HookMode = mode
                self.HookFailed = nil
            end
        end)
    end
    if on and self.HookFailed and not self.HoldMode and not self.Warned.Hook and now >= (self.WarnAt or 0) then
        if not self.WarnAt then
            self.WarnAt = now + 1.5
        else
            self.Warned.Hook = true
            self.Notify("Hold the shoot key until the green on this executor, Auto Green lets go for you")
        end
    end
    local action = action0
    local live = character ~= nil and liveShot(character, action, self.Meters)
    local shot: any = self.Shot
    if shot then
        if not live or (shot.ReleasedAt and now - shot.ReleasedAt >= 1.5) then
            self.Shot = nil
            shot = nil
        elseif not shot.Fired and on then
            shot.LongFrame = math.max(shot.LongFrame or 0, dt)
            if shot.Fresh then
                self:plan(now)
            end
            local at: number? = if shot.Fired then nil else shot.ReleaseAt
            if at then
                if now + math.min(dt, 0.05) * 0.5 >= at then
                    self:release()
                end
            elseif shot.Timed and shot.DunkAt and now >= shot.DunkAt then
                self:release()
            end
        end
    end
    local press: number? = self.Press
    if press then
        if not on or not character then
            self:settle()
        else
            local waiting = WAITING[action] == true and (action ~= "Dribbling" or now - press < 1.2)
            local busy = self.Shot ~= nil or live or waiting
            if busy then
                self.IdleAt = now
            end
            local lost = self.Held ~= nil and not busy and not Court.HasBall
            if not lost then
                self.LostAt = nil
            elseif not self.LostAt then
                self.LostAt = now
            end
            local limit = TAP_TIMEOUT
            if Court.HasBall and not busy then
                local root = Court.Root
                local rimAt = if root then Court.rimDistance(root.Position) else nil
                if rimAt ~= nil and rimAt <= 45 then
                    limit = 2
                end
            end
            if action == "Dunking" and self.Held ~= nil then
                self.DunkSince = self.DunkSince or now
                if now - self.DunkSince >= 0.9 then
                    self.DunkSince = nil
                    self:send()
                    return
                end
            else
                self.DunkSince = nil
            end
            if now - self.IdleAt >= limit or now - press >= HOLD_TIMEOUT or (lost and now - self.LostAt >= LOST_GRACE) then
                self:settle()
            end
        end
    elseif self.Held ~= nil and self.EarlyAt == nil then
        self:send()
    end
end

function AutoGreen.greenWindow(self: any, now: number): boolean
    local shot: any = self.Shot
    if shot and not shot.Fired and shot.ReleaseAt and math.abs(shot.ReleaseAt - now) <= 0.08 then
        return true
    end
    return now - self.LastAuto < 0.35
end

function AutoGreen.hook(self: any, allowHook: boolean?)
    if self.Stopped or self.Binding or self.HookBound then
        return
    end
    if self.Hooked and (self.TriedHook or allowHook ~= true) then
        return
    end
    self.Binding = true
    local ok, mode = Hook.bind(self, allowHook == true)
    self.Binding = false
    if self.Stopped then
        pcall(Hook.remove)
        return
    end
    self.Hooked = true
    self.TriedHook = allowHook == true
    if ok then
        self.HookBound = true
        self.HookMode = mode
        self.HookFailed = nil
        if mode == "hook" then
            self.WatchHook = { Until = os.clock() + 3, Base = self.FrameAvg or (1 / 60), Sum = 0, Count = 0 }
        end
    else
        self.HookMode = nil
        self.HookFailed = mode or "unsupported"
    end
end

function AutoGreen.bind(self: any)
    task.spawn(function()
        local folder = Court.service("InterfaceService")
        local waited = 0
        while not folder and waited < 30 and not self.Stopped do
            waited += task.wait(1)
            folder = Court.service("InterfaceService")
        end
        if not folder or self.Stopped then
            return
        end
        local ok, remote = pcall(folder.WaitForChild, folder, "ShowFeedback", 30)
        if not ok or not remote or self.Stopped then
            return
        end
        self.Feedback = remote.OnClientEvent:Connect(function(character: any, _: any, timing: any)
            if character ~= nil and character == self.Character then
                local index = tonumber(timing)
                if index then
                    self:rated(index)
                end
            end
        end)
    end)
end

function AutoGreen.shutdown(self: any)
    self.Stopped = true
    self.Armed = false
    self.HasBall = false
    pcall(self.detach, self)
    self.Press = nil
    self.Held = nil
    local feedback = self.Feedback
    if feedback then
        self.Feedback = nil
        pcall(feedback.Disconnect, feedback)
    end
    pcall(Hook.remove)
end

return AutoGreen
end
modules["autoshoot"] = function(...)

local import: (string) -> any = ...
local Court: typeof(require("./court")) = import("court")

local AutoShoot = {}
AutoShoot.__index = AutoShoot

local COOLDOWN = 1.6
local RETRY = 0.25
local LAYUP_RANGE = 13
local JITTER = 0.15
local SETTLE = 0.2

local random = Random.new()

function AutoShoot.new(read: (string) -> any, autoGreen: any): any
    return setmetatable({ Read = read, AutoGreen = autoGreen, AutoDunk = nil :: any, Defense = nil :: any, Contest = nil :: any, Last = -math.huge, Since = nil :: number?, GroundAt = nil :: number?, Jitter = 0 }, AutoShoot)
end

local function target(root: any, range: number, attack: any?): (any?, number)
    local near, closest = Court.rimDistance(root.Position)
    if not near or not closest or (attack and closest ~= attack) then
        return nil, math.huge
    end
    local rim, distance = Court.facingRim(root, 0.2, range)
    if rim == closest then
        return rim, distance
    end
    if near <= LAYUP_RANGE then
        return closest, near
    end
    return nil, math.huge
end

local function grounded(mine: any, root: any): boolean
    local humanoid = Court.humanoid(mine)
    if humanoid and humanoid.FloorMaterial == Enum.Material.Air and math.abs(root.AssemblyLinearVelocity.Y) > 2 then
        return false
    end
    return true
end

function AutoShoot.step(self: any, now: number)
    local read = self.Read
    if read("AutoShoot") ~= true or read("AutoGreen") ~= true then
        self.Since = nil
        return
    end
    local mine, root = Court.Mine, Court.Root
    if not mine or not root or not Court.HasBall then
        self.Since = nil
        self.GroundAt = nil
        return
    end
    if not self.Since then
        self.Since = now
        self.Jitter = random:NextNumber(-JITTER, JITTER)
    end
    if not grounded(mine, root) then
        self.GroundAt = nil
        return
    end
    if not self.GroundAt then
        self.GroundAt = now
    end
    local hold = math.max(0, (read("ShootDelay") or 300) * (1 + self.Jitter))
    if now - self.Last < COOLDOWN or now - self.Since < hold / 1000 or now - self.GroundAt < SETTLE then
        return
    end
    local action = Court.Action
    if (action ~= "" and action ~= "Dribbling" and action ~= nil) or not Court.free(mine) or Court.forced(mine) or Court.HandsOff then
        return
    end
    local defense = self.Defense
    local rim, distance = target(root, read("ShootRange") or 24, if defense then defense:attackRim() else nil)
    if not rim then
        return
    end
    local dunk = self.AutoDunk
    if dunk and read("AutoDunk") == true and dunk:claims(distance) then
        return
    end
    if distance < (read("MinShot") or 0) or distance > (read("ShootRange") or 24) then
        return
    end
    if distance <= LAYUP_RANGE then
        local ahead = Court.frontOf(rim, root.Position)
        if ahead and ahead < -1 then
            return
        end
    end
    if Court.nearestFoe(root.Position) <= (read("OpenRange") or 6) then
        return
    end
    local contest = self.Contest
    if contest and contest:estimate(root) > (tonumber(read("MaxContest")) or 35) / 100 then
        return
    end
    if self.AutoGreen:begin(false) then
        self.Last = now
    else
        self.Last = now - COOLDOWN + RETRY
    end
end

return AutoShoot
end
modules["drive"] = function(...)

local import: (string) -> any = ...
local Court: typeof(require("./court")) = import("court")

local Drive = {}

type Map = { [string]: any }

local LIMIT = 27
local TURN = 140
local FRESH = 0.12

local PROFILES: { [string]: Map } = {
    Dunk = { Priority = 3, Accel = 38, Base = 6, Gain = 1.6, Stop = 2, Resume = 4 },
    Guard = { Priority = 2, Accel = 75, Brake = 200, Base = 1.5, Gain = 5, Stop = 0.8, Resume = 1.6, Direct = true, Turn = math.rad(280) },
    Magnet = { Priority = 1, Accel = 60, Base = 5, Gain = 3, Stop = 1, Resume = 1.5 },
}

local owner: string? = nil
local goal = Vector3.zero
local topSpeed = 0
local useKey = false
local forced = false
local setAt = -math.huge
local pace: number? = nil
local moving = false
local last: Vector3? = nil
local lastAt = -math.huge
local userAt = -math.huge
local feed: Vector3? = nil
local seenNative = 0
local seenAt = -math.huge

function Drive.set(name: string, target: Vector3, speed: number, key: boolean, force: boolean, match: Vector3?)
    local now = os.clock()
    local current = owner
    if current and current ~= name and now - setAt < FRESH and PROFILES[current].Priority > PROFILES[name].Priority then
        return
    end
    if current ~= name then
        moving = false
        pace = nil
    end
    owner = name
    goal = target
    topSpeed = speed
    useKey = key
    forced = force
    feed = match
    setAt = now
end

function Drive.clear(name: string)
    if owner == name then
        owner = nil
    end
end

function Drive.moving(name: string): boolean
    return owner == name and moving
end

function Drive.velocity(name: string): Vector3?
    if owner == name and moving then
        return last
    end
    return nil
end

function Drive.since(now: number): number
    return now - lastAt
end

function Drive.active(): boolean
    return owner ~= nil and moving
end

local function halt(mover: any, hands: boolean?)
    local keyed = Court.Held or os.clock() - Court.KeysOff < FRESH
    moving = false
    pace = nil
    Court.hold("Drive", false)
    local written = last
    if written and hands then
        last = nil
    elseif written then
        last = nil
        local steering = Court.Mine ~= nil and Court.steering(Court.Mine)
        if mover and not steering and (mover.Velocity - written).Magnitude < 0.05 then
            mover.Velocity = Vector3.zero
        elseif mover and keyed and not (Court.Mine and Court.steering(Court.Mine)) then
            if mover.Velocity.Magnitude > written.Magnitude + 1 then
                mover.Velocity = written
            end
        end
    end
end

function Drive.begin(now: number)
    local _, mover = Court.proxy()
    if not mover then
        Court.UserMoving = false
        return
    end
    if not Court.Keys and now - Court.KeysOff > 0.3 then
        local incoming = mover.Velocity
        local x, z = incoming.X, incoming.Z
        local speed = math.sqrt(x * x + z * z)
        if speed > 1 then
            local written = last
            local own = false
            if written and now - lastAt <= FRESH then
                local size = written.Magnitude
                own = size > 0.5 and speed <= size * 1.25 + 0.5 and x * written.X + z * written.Z >= 0.8 * speed * size
            end
            if not own then
                userAt = now
            end
        end
    end
    Court.UserMoving = now - userAt < 0.25
end

function Drive.finish(now: number, dt: number)
    local part, mover = Court.proxy()
    local name = owner
    local live = name ~= nil and now - setAt < FRESH and part ~= nil and mover ~= nil
    if live and not forced then
        local mine = Court.Mine
        live = mine ~= nil and not Court.steering(mine)
    end
    if Court.Forced or Court.HandsOff or (Court.Mine ~= nil and Court.handsOff(Court.Mine)) then
        owner = nil
        halt(mover, true)
        return
    end
    if not live or not name or not part or not mover then
        halt(mover)
        return
    end
    local profile = PROFILES[name]
    if profile.Direct then
        local want = feed or Vector3.zero
        local wx, wz = want.X, want.Z
        local native: Vector3 = mover.Velocity
        local nativeSpeed = math.sqrt(native.X * native.X + native.Z * native.Z)
        if Court.Keys and nativeSpeed > 4 and (not last or (native - last).Magnitude > 0.05) then
            seenNative, seenAt = nativeSpeed, now
        end
        local cap = math.min(topSpeed, LIMIT)
        if Court.Keys and now - seenAt < 0.5 then
            cap = math.min(cap, seenNative + 0.3)
        end
        local wantSize = math.sqrt(wx * wx + wz * wz)
        if wantSize > cap then
            wx, wz = wx / wantSize * cap, wz / wantSize * cap
            wantSize = cap
        end
        local velocity = part.AssemblyLinearVelocity
        local vx, vz = velocity.X, velocity.Z
        local stepX, stepZ = wx - vx, wz - vz
        local span = math.min(dt, 0.05)
        local before = math.sqrt(vx * vx + vz * vz)
        if before > 2 then
            local ux, uz = vx / before, vz / before
            local along = stepX * ux + stepZ * uz
            local px, pz = stepX - ux * along, stepZ - uz * along
            local side = math.sqrt(px * px + pz * pz)
            local sideMost = before * profile.Turn * span
            if side > sideMost then
                px, pz = px / side * sideMost, pz / side * sideMost
            end
            stepX, stepZ = ux * along + px, uz * along + pz
        end
        local step = math.sqrt(stepX * stepX + stepZ * stepZ)
        local most = (if wantSize < 0.05 and profile.Brake then profile.Brake else profile.Accel) * span
        if step > most then
            stepX, stepZ = stepX / step * most, stepZ / step * most
        end
        local nx, nz = vx + stepX, vz + stepZ
        local after = math.sqrt(nx * nx + nz * nz)
        if after > cap then
            nx, nz = nx / after * cap, nz / after * cap
            after = cap
        end
        local write = Vector3.new(nx, 0, nz)
        if wantSize < 0.05 and after < 0.4 then
            if not Court.Keys then
                halt(mover)
                return
            end
            write = Vector3.zero
            after = 0
        end
        moving = true
        pace = after
        mover.Velocity = write
        last = write
        lastAt = now
        Court.hold("Drive", false)
        return
    end
    local position = part.Position
    local dx, dz = goal.X - position.X, goal.Z - position.Z
    local away = math.sqrt(dx * dx + dz * dz)
    local match = feed
    if match and profile.Follow then
        local mx, mz = match.X, match.Z
        local matchSpeed = math.sqrt(mx * mx + mz * mz)
        if matchSpeed < 1 and away <= profile.Stop then
            halt(mover)
            return
        end
        local top = topSpeed
        local native: Vector3 = mover.Velocity
        local nativeSpeed = math.sqrt(native.X * native.X + native.Z * native.Z)
        if useKey and Court.Held and nativeSpeed > 4 and (not last or (native - last).Magnitude > 0.05) then
            seenNative, seenAt = nativeSpeed, now
        end
        local nativeCap = math.huge
        if useKey and now - seenAt < 0.5 then
            nativeCap = seenNative + 0.3
            top = math.min(top, nativeCap)
        end
        local pull = profile.Follow * math.min(away, 6)
        local wantX = mx + (if away > 0.05 then dx / away * pull else 0)
        local wantZ = mz + (if away > 0.05 then dz / away * pull else 0)
        local want = math.sqrt(wantX * wantX + wantZ * wantZ)
        local cap = math.min(top, LIMIT)
        if want > cap then
            wantX, wantZ = wantX / want * cap, wantZ / want * cap
        end
        local velocity = part.AssemblyLinearVelocity
        local stepX, stepZ = wantX - velocity.X, wantZ - velocity.Z
        local step = math.sqrt(stepX * stepX + stepZ * stepZ)
        local most = profile.Accel * math.min(dt, 0.05)
        if step > most then
            stepX, stepZ = stepX / step * most, stepZ / step * most
        end
        local write = Vector3.new(velocity.X + stepX, 0, velocity.Z + stepZ)
        local size = write.Magnitude
        if size > nativeCap then
            write = write * (nativeCap / size)
        end
        moving = true
        pace = write.Magnitude
        mover.Velocity = write
        last = write
        lastAt = now
        Court.hold("Drive", useKey)
        return
    end
    if moving then
        if away <= profile.Stop then
            moving = false
        end
    elseif away > profile.Resume then
        moving = true
    end
    if not moving then
        halt(mover)
        return
    end
    local velocity = part.AssemblyLinearVelocity
    local current = math.sqrt(velocity.X * velocity.X + velocity.Z * velocity.Z)
    local speed = math.max(pace or current, current)
    local top = topSpeed
    local native: Vector3 = mover.Velocity
    local nativeSpeed = math.sqrt(native.X * native.X + native.Z * native.Z)
    if useKey and Court.Held and nativeSpeed > 4 and (not last or (native - last).Magnitude > 0.05) then
        top = math.min(top, nativeSpeed + 0.3)
    end
    speed = math.min(speed + profile.Accel * math.min(dt, 0.05), top)
    pace = speed
    local scale = math.min(speed, profile.Base + away * profile.Gain, LIMIT) / away
    local write = Vector3.new(dx * scale, 0, dz * scale)
    local before = part.AssemblyLinearVelocity
    local change = Vector3.new(write.X - before.X, 0, write.Z - before.Z)
    local most = TURN * math.min(dt, 0.05)
    if change.Magnitude > most then
        write = Vector3.new(before.X, 0, before.Z) + change.Unit * most
    end
    mover.Velocity = write
    last = write
    lastAt = now
    if useKey then
        Court.hold("Drive", true)
    else
        Court.hold("Drive", false)
    end
end

function Drive.stop()
    owner = nil
    local _, mover = Court.proxy()
    halt(mover)
end

return Drive
end
modules["autodunk"] = function(...)

local import: (string) -> any = ...
local Court: typeof(require("./court")) = import("court")
local Config: typeof(require("./config")) = import("config")
local Drive: typeof(require("./drive")) = import("drive")

local AutoDunk = {}
AutoDunk.__index = AutoDunk

local COOLDOWN = 2
local WINDOW_MIN = 4.6
local WINDOW_MAX = 11
local DRIVE_START = 20
local DRIVE_SWITCH = 14
local DRIVE_MIN = 6
local DRIVE_MAX = 13
local DRIVE_PACE = 15.5
local STAND_AT = 8
local RUN_SPEED = 16.8
local FACING = 0.35
local FRONT_CONE = 0.34
local FRONT_AIM = 0.6

local RELEASE_SPACE = { Shoot = false, Input = "E", UseSpace = true }
local PRESS_SPACE = { Shoot = true, Input = "E", UseSpace = true }

local flat = Court.flat

function AutoDunk.new(read: (string) -> any, autoGreen: any, player: any): any
    return setmetatable({
        Read = read,
        AutoGreen = autoGreen,
        Player = player,
        Last = -math.huge,
        Run = false,
        Holding = false,
        Owned = false,
        FiredAt = 0,
        SeenAt = nil :: number?,
        HoldGoal = nil :: Vector3?,
        Defense = nil :: any,
    }, AutoDunk)
end

function AutoDunk.idle(self: any)
    self.Run = false
    Court.hold("Dunk", false)
    Drive.clear("Dunk")
end

function AutoDunk.finish(self: any, now: number, on: boolean)
    local lost = not Court.HasBall and Court.Action ~= "Dunking" and now - self.FiredAt >= 0.2
    if not self.SeenAt and (Court.Action == "Dunking" or now - self.FiredAt >= 1.2 or not on or lost) then
        self.SeenAt = now
    end
    local seen: number? = self.SeenAt
    if seen and now - seen >= 0.15 then
        if not self.Owned then
            local remote = Court.input("Shoot")
            if remote then
                Court.send(remote, RELEASE_SPACE)
            end
        end
        self.Holding = false
        self.Owned = false
        self.HoldGoal = nil
        self.SeenAt = nil
    end
end

function AutoDunk.step(self: any, now: number)
    local read = self.Read
    local on = read("AutoDunk") == true
    if self.Holding then
        self:finish(now, on)
    end
    if not on then
        self.Run = false
    end
    local move = on and read("DunkMove") == true
    local goal: Vector3? = if self.Holding then self.HoldGoal else nil
    local run = false
    if self.Holding and (Court.Action == "Dunking" or Court.Action == "Shooting") then
        goal = nil
    end
    if on and now - self.Last >= COOLDOWN and not self.Holding then
        goal, run = self:plan(now, move)
    elseif self.Holding and goal then
        run = true
    end
    if move and goal then
        Drive.set("Dunk", goal, RUN_SPEED, false, true)
        Court.hold("Dunk", run)
    else
        Court.hold("Dunk", false)
        Drive.clear("Dunk")
    end
end

function AutoDunk.plan(self: any, now: number, move: boolean): (Vector3?, boolean)
    local read = self.Read
    local mine, root = Court.Mine, Court.Root
    if not mine or not root or not Court.HasBall then
        self.Run = false
        return nil, false
    end
    local action = Court.Action
    if (action ~= "" and action ~= "Dribbling" and action ~= "Pushing" and action ~= nil) or mine:GetAttribute("Stunned") == true or Court.Forced or Court.HandsOff then
        return nil, false
    end
    local auto = move and not Court.steering(mine)
    local rim, distance = Court.facingRim(root, FACING, read("DunkRange") or 30)
    local defense = self.Defense
    local attack = if defense then defense:attackRim() else nil
    if attack and rim ~= attack then
        rim = nil
    end
    if not rim and auto then
        local near: number?, closest: any? = nil, attack
        if closest then
            near = flat(closest.Position - root.Position).Magnitude
        else
            near, closest = Court.rimDistance(root.Position)
        end
        if near and closest and near <= (read("DunkRange") or 30) then
            rim, distance = closest, near
        end
    end
    if not rim then
        self.Run = false
        return nil, false
    end
    if read("DunkOpenOnly") == true and Court.nearestFoe(root.Position) <= (read("OpenRange") or 6) then
        return nil, false
    end
    local here: Vector3 = root.Position
    local rimAt = Vector3.new(rim.Position.X, here.Y, rim.Position.Z)
    local out = flat(here - rimAt)
    local side = if distance > 0.1 then out / distance else -flat(root.CFrame.LookVector)
    local front = Court.front(rim)
    local cone = if front then side:Dot(front) else 1
    local aim = side
    if front and cone < FRONT_AIM then
        local across = side - front * cone
        local bent = if across.Magnitude > 0.05 then front * FRONT_AIM + across.Unit * math.sqrt(1 - FRONT_AIM * FRONT_AIM) else front
        aim = bent.Unit
    end
    local inFront = cone >= FRONT_CONE
    self.Player.WantSprint = now + 0.4
    local part = Court.proxy()
    local velocity = if part then part.AssemblyLinearVelocity else Vector3.zero
    local planar = flat(velocity)
    local pace = planar.Magnitude
    local mode = read("DunkType") or Config.DUNK_BOTH
    local driving = mode == Config.DUNK_DRIVING or (mode == Config.DUNK_BOTH and (distance >= DRIVE_SWITCH or self.Run == true or pace >= DRIVE_PACE - 3))
    local goal: Vector3? = nil
    if not driving then
        self.Run = false
        if distance < WINDOW_MIN or distance > WINDOW_MAX or not inFront then
            return if auto then rimAt + aim * STAND_AT else nil, false
        end
        if pace >= 2 then
            return nil, false
        end
    else
        if not self.Run and auto then
            if distance < DRIVE_START or not inFront then
                return rimAt + aim * (DRIVE_START + 4), false
            end
            self.Run = true
        end
        goal = if auto then rimAt + aim * 2.5 else nil
        local toward = if distance > 0.1 then -planar:Dot(side) else 0
        if distance > DRIVE_MAX or distance < DRIVE_MIN or pace < DRIVE_PACE or toward < DRIVE_PACE * 0.8 or not inFront then
            if distance < DRIVE_MIN or (self.Run and not inFront) then
                self.Run = false
            end
            return goal, self.Run == true
        end
    end
    if mine:GetAttribute("Sprinting") ~= true or action == "Dribbling" or mine:GetAttribute("CanMove") == false then
        return goal, self.Run == true
    end
    self.Last = now
    self.Holding = true
    self.FiredAt = now
    self.SeenAt = nil
    self.HoldGoal = goal
    self.Run = false
    self.Owned = self.AutoGreen:begin(true)
    if not self.Owned then
        local shoot = Court.input("Shoot")
        if shoot then
            Court.send(shoot, PRESS_SPACE)
        end
    end
    local jump = Court.input("Jump")
    if jump then
        Court.send(jump)
    end
    return goal, goal ~= nil
end

function AutoDunk.claims(self: any, distance: number): boolean
    if self.Holding or self.Run then
        return true
    end
    local read = self.Read
    if distance > (read("DunkRange") or 30) then
        return false
    end
    if read("DunkMove") == true then
        return true
    end
    local root = Court.Root
    local rim = if root then Court.facingRim(root, FACING, read("DunkRange") or 30) else nil
    if not rim then
        return false
    end
    local ahead, aside = Court.frontOf(rim, root.Position)
    if ahead and ahead < FRONT_CONE * math.sqrt(ahead * ahead + aside * aside) then
        return false
    end
    local mode = read("DunkType") or Config.DUNK_BOTH
    local part = Court.proxy()
    local velocity = if part then flat(part.AssemblyLinearVelocity) else Vector3.zero
    local pace = velocity.Magnitude
    local toRim = flat(rim.Position - root.Position)
    if mode ~= Config.DUNK_STANDING and toRim.Magnitude > 0.1 and velocity:Dot(toRim.Unit) >= 8 then
        return true
    end
    if mode ~= Config.DUNK_DRIVING and distance >= WINDOW_MIN and distance <= WINDOW_MAX and pace < 2 then
        return true
    end
    return mode ~= Config.DUNK_STANDING and distance >= DRIVE_MIN and distance <= DRIVE_START and pace >= DRIVE_PACE - 3
end

function AutoDunk.shutdown(self: any)
    if self.Holding and not self.Owned then
        local remote = Court.input("Shoot")
        if remote then
            Court.send(remote, RELEASE_SPACE)
        end
    end
    self.Holding = false
    self.Owned = false
    self.HoldGoal = nil
    self:idle()
end

return AutoDunk
end
modules["contest"] = function(...)

local import: (string) -> any = ...
local Court: typeof(require("./court")) = import("court")
local Env: typeof(require("./env")) = import("env")

local Contest = {}
Contest.__index = Contest

local OPEN = Color3.fromRGB(70, 230, 110)
local CLOSE = Color3.fromRGB(255, 200, 70)
local TIGHT = Color3.fromRGB(255, 80, 80)
local DARK = Color3.fromRGB(14, 16, 20)
local EASE = 10
local FADE = 6
local FILL = 0.84
local OUTLINE = 0.3
local OPEN_BELOW = 0.35

local function holder(): any?
    local hui = Env.gethui
    if hui then
        local ok, folder = pcall(hui)
        if ok and folder then
            return folder
        end
    end
    local ok, core = pcall(game.GetService, game, "CoreGui")
    return if ok then core else nil
end

local function mix(from: Color3, to: Color3, share: number): Color3
    return Color3.new(from.R + (to.R - from.R) * share, from.G + (to.G - from.G) * share, from.B + (to.B - from.B) * share)
end

function Contest.new(read: (string) -> any, autoGreen: any?): any
    return setmetatable({ Read = read, AutoGreen = autoGreen, Light = nil :: any, Color = OPEN, Glow = 0, Value = 0, Gap = math.huge, Open = true }, Contest)
end

function Contest.measure(self: any, root: any): (number, number)
    local range: number = self.Read("ContestRange") or 6
    local here: Vector3 = root.Position
    local _, rim = Court.rimDistance(here)
    local toRim: Vector3? = nil
    if rim then
        local flat = Court.flat(rim.Position - here)
        toRim = if flat.Magnitude > 0.5 then flat.Unit else nil
    end
    local worst, gap = 0, math.huge
    local who, whoRoot = nil, nil
    local roots, foe, chars = Court.Roots, Court.Foe, Court.Chars
    for index = 1, Court.Count do
        if foe[index] then
            local offset = Court.flat(roots[index].Position - here)
            local distance = offset.Magnitude
            if distance < gap then
                gap = distance
            end
            if distance < range * 1.5 + 2 then
                local away = if distance > 0.1 then offset / distance else Vector3.zero
                local theirRoot = roots[index]
                local motion = Court.flat(theirRoot.AssemblyLinearVelocity)
                local closing = math.clamp(-motion:Dot(away), -6, 12)
                local effective = math.max(distance - closing * 0.15, 0)
                local closeness = math.clamp((range * 1.5 - effective) / range, 0, 1)
                local front = 0.6
                if toRim and distance > 0.1 then
                    front = 0.35 + 0.65 * math.clamp(away:Dot(toRim) * 0.5 + 0.5, 0, 1)
                end
                local look = Court.flat(theirRoot.CFrame.LookVector)
                local facing = if look.Magnitude > 0.1 and distance > 0.1 then math.clamp(-look.Unit:Dot(away) * 0.5 + 0.5, 0, 1) else 0.5
                local share = closeness * front * (0.6 + 0.4 * facing)
                if share > worst then
                    worst = share
                    who, whoRoot = chars[index], theirRoot
                end
            end
        end
    end
    self.Who, self.WhoRoot = who, whoRoot
    return worst, gap
end

function Contest.estimate(self: any, root: any): number
    local value, gap = self:measure(root)
    self.Value, self.Gap = value, gap
    return value
end

function Contest.clear(self: any)
    local light = self.Light
    if light then
        self.Light = nil
        pcall(light.Destroy, light)
    end
end

function Contest.shade(self: any): Color3
    if self.Open then
        return OPEN
    end
    return if self.Value < 0.65 then CLOSE else TIGHT
end

function Contest.step(self: any, now: number, dt: number)
    local read = self.Read
    local mine, root = Court.Mine, Court.Root
    local contestOn = read("OpenShot") == true
    if not mine or not root or not contestOn then
        if root and read("AutoShoot") == true then
            self:estimate(root)
        end
        self.Shown = false
        self.Glow = 0
        self:clear()
        return
    end
    local step = math.min(dt, 0.1)
    local value, gap = self:measure(root)
    self.Value, self.Gap = value, gap
    if self.Open then
        self.Open = value < OPEN_BELOW + 0.05
    else
        self.Open = value < OPEN_BELOW - 0.05
    end
    local ball = Court.HasBall
    local showing = contestOn and (read("OpenShotBall") ~= true or ball)
    self.Shown = showing
    local goal: Color3? = nil
    if showing and read("OpenShotGlow") == true then
        goal = self:shade()
    end
    self.Goal = goal
    if goal then
        self.Color = mix(self.Color, goal, 1 - math.exp(-EASE * step))
    end
    local strength = if goal then 1 else 0
    self.Glow += math.clamp(strength - self.Glow, -FADE * step, FADE * step)
    if self.Glow <= 0.005 then
        self:clear()
        return
    end
    local light = self.Light
    if (not light or light.Parent == nil or light.Adornee ~= mine) and now >= (self.RetryAt or 0) then
        self:clear()
        self.RetryAt = now + 2
        local ok, made = pcall(function(): any
            local item = Instance.new("Highlight")
            item.Name = "OpenShot"
            item.DepthMode = Enum.HighlightDepthMode.Occluded
            item.FillTransparency = 1
            item.OutlineTransparency = 1
            item.Adornee = mine
            item.Parent = holder() or mine
            return item
        end)
        light = if ok then made else nil
        self.Light = light
    end
    if light then
        local strength = math.clamp((tonumber(self.Read("GlowStrength")) or 60) / 100, 0.05, 1)
        local glow = self.Glow * strength
        light.FillColor = self.Color
        light.OutlineColor = self.Color
        light.FillTransparency = 1 - (1 - FILL) * glow
        light.OutlineTransparency = 1 - (1 - OUTLINE) * glow
    end
end

local function percentOf(value: number): string
    return math.floor(value * 100 + 0.5) .. "%"
end

local function wording(open: boolean, value: number): string
    if open then
        return "OPEN"
    end
    return if value < 0.65 then "CONTESTED" else "SMOTHERED"
end

local FOLLOW = 12
local REACH = 4

local function lift(self: any, key: string, want: number, dt: number): number
    local alpha: number = self[key] or 0
    alpha += math.clamp(want - alpha, -REACH * dt, REACH * dt)
    self[key] = alpha
    return alpha
end

function Contest.draw(self: any, canvas: any, chip: any)
    local read = self.Read
    local now = os.clock()
    local dt = math.clamp(now - (self.DrawAt or now), 0, 0.1)
    self.DrawAt = now
    local root = Court.Root
    local height = tonumber(read("ContestHeight")) or 4.2
    local range = tonumber(read("ContestViewRange")) or 120
    local opacity = math.clamp(tonumber(read("ContestOpacity")) or 0.85, 0.1, 1)
    local labelOn = self.Shown and root ~= nil and canvas ~= nil and chip ~= nil and read("OpenShotNumber") == true
    local point: Vector2? = nil
    local want = 0
    if labelOn then
        local found, depth = canvas.project(root.Position + Vector3.new(0, height, 0))
        if found and type(depth) == "number" and depth > 0 and depth <= range then
            point, want = found, opacity
        end
    end
    local alpha = lift(self, "LabelAlpha", want, dt)
    local follow = 1 - math.exp(-FOLLOW * dt)
    self.Eased = (self.Eased or self.Value) + (self.Value - (self.Eased or self.Value)) * follow
    local custom: any = read("ContestLabelColor")
    local goal = if read("ContestColorMode") == "Custom" and typeof(custom) == "Color3" then custom else self:shade()
    self.Tone = if self.Tone then mix(self.Tone, goal, follow) else goal
    local scale = math.clamp(tonumber(read("ContestTextSize")) or 13, 8, 30) / 13
    local number = percentOf(self.Eased)
    local tone: Color3 = self.Tone
    if alpha > 0.01 and point and chip then
        local who = self.Who
        local runs = { { Text = number, Color = "Text" } }
        if read("ContestWho") == true and who and not self.Open then
            runs[2] = { Text = "by " .. tostring(who.Name), Color = "Sub" }
        end
        self.LastPoint = point
        local shown = Vector2.new(point.X, point.Y - (1 - math.clamp(alpha / math.max(want, 0.1), 0, 1)) * 8)
        if read("ContestStyle") == "Bar" then
            chip("contest", shown, {}, alpha, scale, { Value = self.Eased, Color = tone, Only = true })
        else
            chip("contest", shown, { { { Text = wording(self.Open, self.Value), Color = tone } }, runs }, alpha, scale, nil)
        end
    end
    local theirs = self.WhoRoot
    local marking = labelOn and read("ContestFoeMark") == true and theirs ~= nil and not self.Open and theirs.Parent ~= nil
    local markPoint: Vector2? = nil
    local markWant = 0
    if marking then
        local found, depth = canvas.project(theirs.Position + Vector3.new(0, height, 0))
        if found and type(depth) == "number" and depth > 0 and depth <= range then
            markPoint, markWant = found, opacity
        end
    end
    local markAlpha = lift(self, "MarkAlpha", markWant, dt)
    if markAlpha > 0.01 and chip then
        local at = markPoint or self.MarkPoint
        if at then
            self.MarkPoint = at
            if read("ContestStyle") == "Bar" then
                chip("mark", at, {}, markAlpha, scale * 0.8, { Value = self.Eased, Color = tone, Only = true })
            else
                chip("mark", at, { { { Text = number, Color = tone } } }, markAlpha, scale * 0.8, nil)
            end
        end
    end
end

function Contest.shutdown(self: any)
    self.Shown = false
    self.Glow = 0
    self:clear()
end

return Contest
end
modules["rimguard"] = function(...)

local import: (string) -> any = ...
local Court: typeof(require("./court")) = import("court")

local RimGuard = {}
RimGuard.__index = RimGuard

local RANGE = 13
local FRONT_MIN = 2.6
local SLOPE = 0.4
local BUSY: { [string]: boolean } = { Shooting = true, Gathering = true, Dunking = true, ContactLayup = true, ClutchLayup = true, Layup = true, Dribbling = true }

function RimGuard.new(read: (string) -> any, autoGreen: any): any
    return setmetatable({ Read = read, AutoGreen = autoGreen }, RimGuard)
end

function RimGuard.physics(self: any)
    if self.Read("RimFront") ~= true then
        return
    end
    local mine = Court.Mine
    if not mine or not Court.HasBall then
        return
    end
    local green = self.AutoGreen
    if green.Press == nil or green.DunkPress == true or (green.Shot and green.Shot.Fired) then
        return
    end
    local action = mine:GetAttribute("Action")
    if (type(action) == "string" and BUSY[action]) or mine:GetAttribute("CanMove") ~= true or Court.handsOff(mine) then
        return
    end
    local part, mover = Court.proxy()
    if not part or not mover then
        return
    end
    local position: Vector3 = part.Position
    local distance, rim = Court.rimDistance(position)
    if not distance or not rim or distance > RANGE then
        return
    end
    local front = Court.front(rim)
    if not front then
        return
    end
    local offsetX, offsetZ = position.X - rim.Position.X, position.Z - rim.Position.Z
    local ahead = offsetX * front.X + offsetZ * front.Z
    if ahead <= 0 then
        return
    end
    local sideX, sideZ = offsetX - front.X * ahead, offsetZ - front.Z * ahead
    local need = math.max(FRONT_MIN, math.sqrt(sideX * sideX + sideZ * sideZ) * SLOPE)
    local velocity: Vector3 = mover.Velocity
    local closing = -(velocity.X * front.X + velocity.Z * front.Z)
    local limit = math.max((ahead - need) * 6, 0)
    if closing > limit then
        if green.Tracing then green:trace(string.format("  RIMGUARD slows the run, ahead=%.1f closing=%.1f limit=%.1f", ahead, closing, limit)) end
        mover.Velocity = velocity + front * (closing - limit)
    end
end

return RimGuard
end

local Config = import("config")
local Court = import("court")
local Env = import("env")
local AutoGreen = import("autogreen")

local KS = {}
KS.import = import
KS.modules = { "config", "env", "court", "aero", "hook", "autogreen", "autoshoot", "drive", "autodunk", "contest", "rimguard" }
KS.Settings = {}
for k, v in pairs(Config.DEFAULTS) do KS.Settings[k] = v end

function KS.start(notifyFn)
    local running = true
    local hookAt = os.clock() + 0.8
    local function raw(flag)
        local v = KS.Settings[flag]
        if v == nil then return Config.DEFAULTS[flag] end
        return v
    end
    local function read(flag)
        if not running then return false end
        local value = raw(flag)
        local parent = Config.PARENT[flag]
        if parent and value == true and raw(parent) ~= true then return false end
        return value
    end
    local function notify(text)
        if running and notifyFn then pcall(notifyFn, text) end
    end
    Env.set("__PBRead", read)
    local autoGreen = AutoGreen.new(read, notify)
    autoGreen.BlockDribble = function() return false end
    local conns = {}
    local function stop()
        if not running then return end
        running = false
        Court.Closing = true
        for _, c in ipairs(conns) do pcall(c.Disconnect, c) end
        pcall(autoGreen.shutdown, autoGreen)
        pcall(Court.stop)
        if Env.get("__PBRead") == read then Env.set("__PBRead", nil) end
    end
    Court.Closing = false
    pcall(Court.start)
    pcall(autoGreen.bind, autoGreen)
    local rs = game:GetService("RunService")
    table.insert(conns, rs.Heartbeat:Connect(function(delta)
        if not running then return end
        local now = os.clock()
        local dt = type(delta) == "number" and delta or 1 / 60
        pcall(Court.refresh, now)
        if not autoGreen.HookBound and not autoGreen.Binding and now >= hookAt then
            if read("AutoGreen") == true and not autoGreen.Hooked then
                task.spawn(autoGreen.hook, autoGreen, false)
            end
        end
        pcall(autoGreen.step, autoGreen, now, dt)
    end))
    local api = { AutoGreen = autoGreen, Read = read }
    function api.Stop() stop() end
    function api.Reset() pcall(autoGreen.resetCalibration, autoGreen) end
    return api
end

return KS
end)()

return KuluShoot
