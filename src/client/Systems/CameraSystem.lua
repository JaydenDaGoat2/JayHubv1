--!nonstrict
-- Camera modes and effects.
--   Default   - Roblox follow camera with JayHub FOV / zoom limits
--   Shoulder  - follow camera shifted over the shoulder
--   Broadcast - TV-style sideline camera that tracks the player
--   Overhead  - high top-down view
-- Shot shake is applied through Humanoid.CameraOffset in the follow modes and
-- directly to the camera CFrame in the scripted ones.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Store = require(script.Parent.Parent.Core.Store)

local CameraSystem = {}

local player = Players.LocalPlayer
local trauma = 0 -- 0..1, decays over time
local offset = Vector3.zero
local scriptedCFrame: CFrame? = nil
local wasScripted = false
local started = false

local function smoothingAlpha(dt: number): number
	local smoothing = Store.get("CameraSmoothing") :: number
	if smoothing <= 0 then
		return 1
	end
	return 1 - smoothing ^ (dt * 30)
end

local function getCharacterParts(): (Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil
	end
	return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- Adds camera shake. `amount` 0..1 (scaled by the Shake intensity setting).
function CameraSystem.shake(amount: number)
	if not Store.get("ShotShake") then
		return
	end
	trauma = math.clamp(trauma + amount * (Store.get("ShakeIntensity") :: number), 0, 1)
end

function CameraSystem.cycleMode(): string
	local modes = { "Default", "Shoulder", "Broadcast", "Overhead" }
	local index = table.find(modes, Store.get("CameraMode")) or 1
	local nextMode = modes[index % #modes + 1]
	Store.set("CameraMode", nextMode)
	return nextMode
end

local function shakeOffset(dt: number): Vector3
	if trauma <= 0 then
		return Vector3.zero
	end
	trauma = math.max(trauma - dt * 1.6, 0)
	local power = trauma * trauma
	local t = os.clock() * 25
	return Vector3.new(
		math.noise(t, 0.3) * power * 0.9,
		math.noise(0.7, t) * power * 0.9,
		math.noise(t, t * 0.5) * power * 0.4
	)
end

local function restoreDefault(camera: Camera, humanoid: Humanoid?)
	camera.CameraType = Enum.CameraType.Custom
	if humanoid then
		camera.CameraSubject = humanoid
	end
	scriptedCFrame = nil
end

local function step(dt: number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local humanoid, root = getCharacterParts()
	local mode = Store.get("CameraMode")
	local alpha = smoothingAlpha(dt)
	local shake = shakeOffset(dt)

	-- Field of view (smoothed in every mode).
	local targetFov = Store.get("FieldOfView") :: number
	camera.FieldOfView += (targetFov - camera.FieldOfView) * math.min(alpha * 2, 1)

	local scripted = (mode == "Broadcast" or mode == "Overhead") and root ~= nil
	if scripted and root then
		camera.CameraType = Enum.CameraType.Scriptable
		local distance = Store.get("BroadcastDistance") :: number
		local focus = root.Position + Vector3.new(0, 1.5, 0)
		local eye
		if mode == "Broadcast" then
			eye = focus + Vector3.new(0, distance * 0.35, distance)
		else
			eye = focus + Vector3.new(0, distance * 1.2, distance * 0.2)
		end
		local goal = CFrame.lookAt(eye, focus)
		scriptedCFrame = if scriptedCFrame then (scriptedCFrame :: CFrame):Lerp(goal, alpha) else goal
		camera.CFrame = (scriptedCFrame :: CFrame) * CFrame.new(shake)
		if humanoid then
			humanoid.CameraOffset = Vector3.zero
		end
		wasScripted = true
		return
	end

	if wasScripted then
		wasScripted = false
		restoreDefault(camera, humanoid)
	end

	-- Follow modes: shoulder offset + shake through CameraOffset.
	local targetOffset = if mode == "Shoulder"
		then Vector3.new(Store.get("ShoulderOffset") :: number, 0.6, 0)
		else Vector3.zero
	offset = offset:Lerp(targetOffset, alpha)
	if humanoid then
		humanoid.CameraOffset = offset + shake
	end
end

function CameraSystem.start()
	if started then
		return
	end
	started = true

	Store.observe("MaxZoom", function(value)
		player.CameraMaxZoomDistance = value
		if player.CameraMinZoomDistance > value then
			player.CameraMinZoomDistance = 0.5
		end
	end)

	Store.observe("CameraMode", function(mode)
		if mode ~= "Broadcast" and mode ~= "Overhead" then
			scriptedCFrame = nil
		end
	end)

	RunService:BindToRenderStep("JayHubCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
		local ok, err = pcall(step, dt)
		if not ok then
			warn("[JayHub] camera step failed:", err)
		end
	end)
end

return CameraSystem
