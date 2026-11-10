--!strict
-- JayHub server: builds the court when the place has none, stores each
-- player's settings, configuration slots and lifetime stats in a DataStore,
-- and applies the public parts of their profile (nameplate, attributes,
-- walk speed). Everything the client sends is validated against the Schema.

local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local Schema = require(Shared:WaitForChild("JayHub"):WaitForChild("Schema"))
local CourtBuilder = require(script.Parent:WaitForChild("CourtBuilder"))

local HubConfig = Config.JayHub

type Slot = { Name: string, SavedAt: number, Settings: { [string]: any } }
type Session = {
	Loaded: boolean, -- false = loading failed, never write over their data
	Ready: boolean, -- true once loading has finished (successfully or not)
	Dirty: boolean,
	Settings: { [string]: any }, -- live settings (profile is applied from these)
	SavedSettings: { [string]: any }, -- what gets written to the DataStore
	Slots: { [number]: Slot },
	Stats: { [string]: number },
	LastManualSave: number,
	Requests: { number },
	NicknameCache: { [string]: string },
}

local sessions: { [Player]: Session } = {}

---------------------------------------------------------------------------
-- Court
---------------------------------------------------------------------------
if Config.AutoBuildCourt and #CollectionService:GetTagged(Config.HoopTag) == 0 then
	local ok, err = pcall(CourtBuilder.build)
	if not ok then
		warn("[JayHub] Court build failed:", err)
	end
end

---------------------------------------------------------------------------
-- Remotes
---------------------------------------------------------------------------
local remotes = Instance.new("Folder")
remotes.Name = "JayHubRemotes"
local request = Instance.new("RemoteFunction")
request.Name = "Request"
request.Parent = remotes
remotes.Parent = ReplicatedStorage

---------------------------------------------------------------------------
-- DataStore helpers
---------------------------------------------------------------------------
local store: DataStore? = nil
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(HubConfig.DataStoreName)
	end)
	if ok then
		store = result
	else
		warn("[JayHub] DataStores unavailable, progress won't be saved:", result)
	end
end

local function keyFor(player: Player): string
	return "player_" .. player.UserId
end

local function withRetries<T>(label: string, fn: () -> T): (boolean, T?)
	local lastErr: any = nil
	for attempt = 1, 3 do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		task.wait(attempt * 1.5)
	end
	warn(("[JayHub] %s failed after 3 attempts: %s"):format(label, tostring(lastErr)))
	return false, nil
end

local function sanitizeSlots(input: any): { [number]: Slot }
	local out = {}
	if type(input) ~= "table" then
		return out
	end
	for index = 1, Schema.SlotCount do
		local slot = input[index] or input[tostring(index)]
		if type(slot) == "table" and type(slot.Settings) == "table" then
			local name = if type(slot.Name) == "string" then string.sub(slot.Name, 1, 24) else ("Slot " .. index)
			out[index] = {
				Name = name,
				SavedAt = if type(slot.SavedAt) == "number" then slot.SavedAt else 0,
				Settings = Schema.sanitize(slot.Settings),
			}
		end
	end
	return out
end

-- DataStores need string keys for sparse tables, so slots are stored keyed "1".."3".
local function serializeSlots(slots: { [number]: Slot }): { [string]: Slot }
	local out = {}
	for index, slot in slots do
		out[tostring(index)] = slot
	end
	return out
end

local function savePlayer(player: Player): boolean
	local session = sessions[player]
	if not session or not session.Loaded or not store then
		return false
	end
	local payload = {
		Version = Schema.Version,
		Settings = session.SavedSettings,
		Slots = serializeSlots(session.Slots),
		Stats = session.Stats,
	}
	local dataStore = store :: DataStore
	local ok = withRetries("Save " .. player.Name, function()
		dataStore:UpdateAsync(keyFor(player), function()
			return payload
		end)
		return true
	end)
	if ok then
		session.Dirty = false
	end
	return ok
end

---------------------------------------------------------------------------
-- Profile (nameplate, attributes, walk speed)
---------------------------------------------------------------------------
local function filterNickname(player: Player, session: Session, raw: string): string
	if raw == "" then
		return ""
	end
	local cached = session.NicknameCache[raw]
	if cached then
		return cached
	end
	local ok, filtered = pcall(function()
		local result = TextService:FilterStringAsync(raw, player.UserId, Enum.TextFilterContext.PublicChat)
		return result:GetNonChatStringForBroadcastAsync()
	end)
	-- If filtering fails we never show unfiltered text to others.
	local clean = if ok and type(filtered) == "string" then filtered else ""
	session.NicknameCache[raw] = clean
	return clean
end

local function applyNameplate(player: Player, character: Model, settings: { [string]: any }, nickname: string)
	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local existing = if head then head:FindFirstChild("JayHubNameplate") else nil

	if not settings.ShowNameplate or not head then
		if existing then
			existing:Destroy()
		end
		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		end
		return
	end

	local accent = Schema.toColor(settings.NameplateColor)
	local gui = existing :: BillboardGui?
	if not gui then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "JayHubNameplate"
		billboard.Size = UDim2.fromOffset(200, 54)
		billboard.StudsOffset = Vector3.new(0, 2.7, 0)
		billboard.MaxDistance = HubConfig.NameplateDistance
		billboard.LightInfluence = 0
		billboard.ResetOnSpawn = false

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "PlayerName"
		nameLabel.BackgroundTransparency = 1
		nameLabel.Size = UDim2.new(1, 0, 0.58, 0)
		nameLabel.Font = Enum.Font.GothamBlack
		nameLabel.TextScaled = true
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.TextStrokeTransparency = 0.6
		nameLabel.Parent = billboard

		local info = Instance.new("TextLabel")
		info.Name = "Info"
		info.BackgroundTransparency = 1
		info.Position = UDim2.fromScale(0, 0.6)
		info.Size = UDim2.new(1, 0, 0.4, 0)
		info.Font = Enum.Font.GothamBold
		info.TextScaled = true
		info.TextStrokeTransparency = 0.7
		info.Parent = billboard

		billboard.Parent = head
		gui = billboard
	end

	local billboard = gui :: BillboardGui
	local nameLabel = billboard:FindFirstChild("PlayerName") :: TextLabel?
	local info = billboard:FindFirstChild("Info") :: TextLabel?
	if nameLabel then
		nameLabel.Text = if nickname ~= "" then nickname else player.DisplayName
	end
	if info then
		info.Text = ("#%d  ·  %s"):format(settings.JerseyNumber, settings.Position)
		info.TextColor3 = accent
	end
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

local function applyProfile(player: Player)
	local session = sessions[player]
	if not session then
		return
	end
	local settings = session.Settings
	local nickname = filterNickname(player, session, settings.Nickname)

	player:SetAttribute("JayHubNickname", nickname)
	player:SetAttribute("JerseyNumber", settings.JerseyNumber)
	player:SetAttribute("PreferredPosition", settings.Position)
	player:SetAttribute("ShootingHand", settings.ShootingHand)

	local character = player.Character
	if not character then
		return
	end
	applyNameplate(player, character, settings, nickname)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and HubConfig.AllowWalkSpeed then
		humanoid.WalkSpeed = settings.WalkSpeed
	end
end

---------------------------------------------------------------------------
-- Player lifecycle
---------------------------------------------------------------------------
local function loadPlayer(player: Player)
	local session: Session = {
		Loaded = false,
		Ready = false,
		Dirty = false,
		Settings = Schema.defaults(),
		SavedSettings = Schema.defaults(),
		Slots = {},
		Stats = Schema.emptyStats(),
		LastManualSave = 0,
		Requests = {},
		NicknameCache = {},
	}
	sessions[player] = session

	if store then
		local dataStore = store :: DataStore
		local ok, data = withRetries("Load " .. player.Name, function()
			return dataStore:GetAsync(keyFor(player))
		end)
		if ok then
			session.Loaded = true
			if type(data) == "table" then
				session.Settings = Schema.sanitize(data.Settings)
				session.SavedSettings = table.clone(session.Settings)
				session.Slots = sanitizeSlots(data.Slots)
				session.Stats = Schema.sanitizeStats(data.Stats)
			end
		end
	end
	session.Ready = true

	if player.Parent then
		applyProfile(player)
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Head", 10)
		character:WaitForChild("Humanoid", 10)
		applyProfile(player)
	end)
	task.spawn(loadPlayer, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	local session = sessions[player]
	if session and session.Dirty then
		savePlayer(player)
	end
	sessions[player] = nil
end)

game:BindToClose(function()
	local pending = 0
	for player, session in sessions do
		if session.Dirty then
			pending += 1
			task.spawn(function()
				savePlayer(player)
				pending -= 1
			end)
		end
	end
	local deadline = os.clock() + 25
	while pending > 0 and os.clock() < deadline do
		task.wait(0.25)
	end
end)

task.spawn(function()
	while true do
		task.wait(HubConfig.AutosaveInterval)
		for player, session in sessions do
			if session.Dirty then
				task.spawn(savePlayer, player)
			end
		end
	end
end)

---------------------------------------------------------------------------
-- Request handling
---------------------------------------------------------------------------
local function rateLimited(session: Session): boolean
	local now = os.clock()
	local recent = session.Requests
	while recent[1] and now - recent[1] > HubConfig.RequestWindow do
		table.remove(recent, 1)
	end
	if #recent >= HubConfig.RequestsPerWindow then
		return true
	end
	table.insert(recent, now)
	return false
end

local function slotSummary(session: Session)
	local out = {}
	for index = 1, Schema.SlotCount do
		local slot = session.Slots[index]
		if slot then
			out[tostring(index)] = { Name = slot.Name, SavedAt = slot.SavedAt, Settings = slot.Settings }
		end
	end
	return out
end

local handlers: { [string]: (...any) -> any } = {}

function handlers.Init(_player, session)
	return {
		Settings = session.Settings,
		Slots = slotSummary(session),
		Stats = session.Stats,
		Persistent = session.Loaded,
	}
end

-- Keeps the server copy of the settings up to date and re-applies the profile.
function handlers.SyncSettings(player, session, settings, persist)
	if type(settings) ~= "table" then
		return { Ok = false, Message = "Invalid settings" }
	end
	session.Settings = Schema.sanitize(settings)
	-- With auto save off, changes stay live but aren't written until "Save now".
	if persist == true then
		session.SavedSettings = table.clone(session.Settings)
		session.Dirty = true
	end
	applyProfile(player)
	return { Ok = true }
end

function handlers.SaveSlot(_player, session, index, payload)
	if type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > Schema.SlotCount then
		return { Ok = false, Message = "Invalid slot" }
	end
	if type(payload) ~= "table" or type(payload.Settings) ~= "table" then
		return { Ok = false, Message = "Invalid configuration" }
	end
	local name = if type(payload.Name) == "string" and payload.Name ~= "" then payload.Name else ("Slot " .. index)
	name = (string.gsub(name, "%c", ""))
	session.Slots[index] = {
		Name = string.sub(name, 1, 24),
		SavedAt = os.time(),
		Settings = Schema.sanitize(payload.Settings),
	}
	session.Dirty = true
	return { Ok = true, Slots = slotSummary(session) }
end

function handlers.DeleteSlot(_player, session, index)
	if type(index) ~= "number" or session.Slots[index] == nil then
		return { Ok = false, Message = "That slot is already empty" }
	end
	session.Slots[index] = nil
	session.Dirty = true
	return { Ok = true, Slots = slotSummary(session) }
end

function handlers.SaveStats(_player, session, stats)
	session.Stats = Schema.sanitizeStats(stats)
	session.Dirty = true
	return { Ok = true }
end

function handlers.Flush(player, session)
	if not session.Loaded then
		return { Ok = false, Message = "Saving is unavailable on this server" }
	end
	local now = os.clock()
	local wait = HubConfig.ManualSaveCooldown - (now - session.LastManualSave)
	if wait > 0 then
		return { Ok = false, Message = ("Please wait %ds before saving again"):format(math.ceil(wait)) }
	end
	session.LastManualSave = now
	session.Dirty = true
	local ok = savePlayer(player)
	return { Ok = ok, Message = if ok then "Saved to the cloud" else "Save failed, we'll retry automatically" }
end

request.OnServerInvoke = function(player: Player, action: any, a: any, b: any)
	local session = sessions[player]
	if not session then
		return { Ok = false, Message = "Session not ready" }
	end

	-- Wait for the initial load so a fast client doesn't get defaults.
	local deadline = os.clock() + 15
	while not session.Ready and os.clock() < deadline do
		task.wait(0.1)
	end

	if type(action) ~= "string" or not handlers[action] then
		return { Ok = false, Message = "Unknown request" }
	end
	if action ~= "Init" and rateLimited(session) then
		return { Ok = false, Message = "Slow down a little" }
	end

	local ok, result = pcall(handlers[action], player, session, a, b)
	if not ok then
		warn(("[JayHub] %s request from %s failed: %s"):format(action, player.Name, tostring(result)))
		return { Ok = false, Message = "Server error" }
	end
	return result
end
