--!nonstrict
-- Client-side settings store. Holds the live settings, lets any module observe
-- a key, validates every change against the shared Schema and keeps the
-- server copy in sync (which handles cloud saving).

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local JayHubShared = Shared:WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))
local Signal = require(JayHubShared:WaitForChild("Signal"))

local Store = {}

Store.Changed = Signal.new() -- (key, value, oldValue)
Store.SlotsChanged = Signal.new() -- (slots)
Store.StatusChanged = Signal.new() -- (statusText)

Store.Online = false -- true when the server remote answered
Store.Persistent = false -- true when the server can write to the DataStore
Store.Slots = {} :: { [number]: { Name: string, SavedAt: number, Settings: { [string]: any } } }
Store.InitialStats = nil :: { [string]: number }?
Store.LastSaved = 0

local settings: { [string]: any } = Schema.defaults()
local remote: RemoteFunction? = nil
local syncScheduled = false
local SYNC_DELAY = 1.5
local EXPORT_PREFIX = "JAYHUB1:"

---------------------------------------------------------------------------
-- Reading & observing
---------------------------------------------------------------------------

function Store.get(key: string): any
	return settings[key]
end

function Store.snapshot(): { [string]: any }
	return table.clone(settings)
end

-- Calls `fn(value)` right away and again whenever the key changes.
function Store.observe(key: string, fn: (any) -> ())
	local ok, err = pcall(fn, settings[key])
	if not ok then
		warn("[JayHub] observer for", key, "failed:", err)
	end
	return Store.Changed:Connect(function(changedKey, value)
		if changedKey == key then
			fn(value)
		end
	end)
end

-- Calls `fn()` whenever any of the given keys change (and once right away).
function Store.observeMany(keys: { string }, fn: () -> ())
	local ok, err = pcall(fn)
	if not ok then
		warn("[JayHub] observer failed:", err)
	end
	return Store.Changed:Connect(function(changedKey)
		if table.find(keys, changedKey) then
			fn()
		end
	end)
end

---------------------------------------------------------------------------
-- Server communication
---------------------------------------------------------------------------

-- Never throws. Returns the server's reply table, or { Ok = false, Message }.
function Store.request(action: string, ...: any): { [string]: any }
	if not remote then
		return { Ok = false, Message = "Offline: changes only last this session" }
	end
	local args = table.pack(...)
	local ok, result = pcall(function()
		return (remote :: RemoteFunction):InvokeServer(action, table.unpack(args, 1, args.n))
	end)
	if not ok then
		warn("[JayHub] request", action, "failed:", result)
		return { Ok = false, Message = "Couldn't reach the server" }
	end
	if type(result) ~= "table" then
		return { Ok = false, Message = "Unexpected server reply" }
	end
	return result
end

local function decodeSlots(raw: any)
	local slots = {}
	if type(raw) == "table" then
		for index = 1, Schema.SlotCount do
			local slot = raw[tostring(index)] or raw[index]
			if type(slot) == "table" then
				slots[index] = {
					Name = if type(slot.Name) == "string" then slot.Name else ("Slot " .. index),
					SavedAt = if type(slot.SavedAt) == "number" then slot.SavedAt else 0,
					Settings = Schema.sanitize(slot.Settings),
				}
			end
		end
	end
	Store.Slots = slots
	Store.SlotsChanged:Fire(slots)
end

local function sync(persist: boolean)
	local reply = Store.request("SyncSettings", settings, persist)
	if not reply.Ok and Store.Online then
		Store.StatusChanged:Fire("Sync failed: " .. tostring(reply.Message))
	end
	return reply
end

local function scheduleSync()
	if syncScheduled then
		return
	end
	syncScheduled = true
	task.delay(SYNC_DELAY, function()
		syncScheduled = false
		sync(settings.AutoSave == true)
		if settings.AutoSave then
			Store.LastSaved = os.time()
			Store.StatusChanged:Fire("Auto-saved")
		end
	end)
end

---------------------------------------------------------------------------
-- Writing
---------------------------------------------------------------------------

-- Returns (true, cleanValue) or (false, reason).
function Store.set(key: string, value: any): (boolean, any)
	local ok, clean = Schema.validate(key, value)
	if not ok then
		return false, clean
	end
	local old = settings[key]
	if old == clean then
		return true, clean
	end
	settings[key] = clean
	Store.Changed:Fire(key, clean, old)
	scheduleSync()
	return true, clean
end

-- Replaces every setting at once (used by loading a slot, import and reset).
function Store.replaceAll(input: { [string]: any })
	local clean = Schema.sanitize(input)
	local changed = {}
	for key, value in clean do
		if settings[key] ~= value then
			table.insert(changed, { key, value, settings[key] })
			settings[key] = value
		end
	end
	for _, change in changed do
		Store.Changed:Fire(change[1], change[2], change[3])
	end
	scheduleSync()
	return #changed
end

-- Resets just the given keys to their defaults.
function Store.resetKeys(keys: { string })
	for _, key in keys do
		local def = Schema.Settings[key]
		if def then
			Store.set(key, def.Default)
		end
	end
end

-- Writes the current settings to the cloud right now.
function Store.saveNow(): (boolean, string)
	if not Store.Online then
		return false, "Offline: the server isn't running JayHub"
	end
	local reply = sync(true)
	if not reply.Ok then
		return false, tostring(reply.Message)
	end
	local flush = Store.request("Flush")
	if flush.Ok then
		Store.LastSaved = os.time()
		Store.StatusChanged:Fire("Saved")
	end
	return flush.Ok == true, tostring(flush.Message or "")
end

---------------------------------------------------------------------------
-- Configuration slots
---------------------------------------------------------------------------

function Store.saveSlot(index: number, name: string): (boolean, string)
	local reply = Store.request("SaveSlot", index, { Name = name, Settings = settings })
	if reply.Ok then
		decodeSlots(reply.Slots)
		return true, "Saved to slot " .. index
	end
	-- Offline fallback so slots still work inside one session.
	if not Store.Online then
		Store.Slots[index] = { Name = name ~= "" and name or ("Slot " .. index), SavedAt = os.time(), Settings = Store.snapshot() }
		Store.SlotsChanged:Fire(Store.Slots)
		return true, "Saved to slot " .. index .. " (this session only)"
	end
	return false, tostring(reply.Message)
end

function Store.loadSlot(index: number): (boolean, string)
	local slot = Store.Slots[index]
	if not slot then
		return false, "Slot " .. index .. " is empty"
	end
	local count = Store.replaceAll(slot.Settings)
	return true, ("Loaded \"%s\" (%d changes)"):format(slot.Name, count)
end

function Store.deleteSlot(index: number): (boolean, string)
	if not Store.Slots[index] then
		return false, "Slot " .. index .. " is already empty"
	end
	if Store.Online then
		local reply = Store.request("DeleteSlot", index)
		if not reply.Ok then
			return false, tostring(reply.Message)
		end
		decodeSlots(reply.Slots)
	else
		Store.Slots[index] = nil
		Store.SlotsChanged:Fire(Store.Slots)
	end
	return true, "Cleared slot " .. index
end

---------------------------------------------------------------------------
-- Import / export
---------------------------------------------------------------------------

function Store.export(): string
	-- Only store values that differ from the defaults to keep the code short.
	local diff = {}
	for key, def in Schema.Settings do
		if settings[key] ~= def.Default then
			diff[key] = settings[key]
		end
	end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, diff)
	return if ok then EXPORT_PREFIX .. json else ""
end

function Store.import(text: string): (boolean, string)
	if type(text) ~= "string" then
		return false, "Paste a JayHub config code first"
	end
	local body = string.match(text, "^%s*" .. EXPORT_PREFIX .. "(.-)%s*$")
	if not body then
		return false, "That isn't a JayHub config code"
	end
	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body)
	if not ok or type(decoded) ~= "table" then
		return false, "The config code is damaged"
	end
	-- Start from defaults so the import reproduces the exported setup exactly.
	local merged = Schema.defaults()
	local accepted, rejected = 0, 0
	for key, value in decoded do
		if type(key) == "string" and Schema.Settings[key] then
			local valid, clean = Schema.validate(key, value)
			if valid then
				merged[key] = clean
				accepted += 1
			else
				rejected += 1
			end
		else
			rejected += 1
		end
	end
	Store.replaceAll(merged)
	local message = ("Imported %d settings"):format(accepted)
	if rejected > 0 then
		message ..= (" (%d skipped)"):format(rejected)
	end
	return true, message
end

---------------------------------------------------------------------------
-- Startup
---------------------------------------------------------------------------

-- Connects to the server and loads saved data. Safe to call once.
function Store.init(): boolean
	local folder = ReplicatedStorage:WaitForChild("JayHubRemotes", 10)
	local found = folder and folder:WaitForChild("Request", 5)
	if not found or not found:IsA("RemoteFunction") then
		warn("[JayHub] Server remote not found; running offline")
		return false
	end
	remote = found

	local reply = Store.request("Init")
	if type(reply.Settings) ~= "table" then
		remote = nil
		warn("[JayHub] Init failed:", reply.Message)
		return false
	end

	Store.Online = true
	Store.Persistent = reply.Persistent == true
	Store.InitialStats = Schema.sanitizeStats(reply.Stats)
	decodeSlots(reply.Slots)

	-- Apply without triggering a sync back to the server.
	local clean = Schema.sanitize(reply.Settings)
	for key, value in clean do
		if settings[key] ~= value then
			local old = settings[key]
			settings[key] = value
			Store.Changed:Fire(key, value, old)
		end
	end
	return true
end

return Store
