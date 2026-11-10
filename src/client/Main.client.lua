-- Client entry point: input (keyboard, gamepad, touch buttons), the shot meter,
-- and feedback. All real decisions happen on the server.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local BallMath = require(Shared:WaitForChild("BallMath"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local HUD = require(script.Parent:WaitForChild("HUD"))
local BallRenderer = require(script.Parent:WaitForChild("BallRenderer"))

local player = Players.LocalPlayer
local ballsFolder = workspace:WaitForChild("Basketballs")

local ShootStart = Remotes.get("ShootStart")
local ShootRelease = Remotes.get("ShootRelease")
local PassRemote = Remotes.get("Pass")
local StealRemote = Remotes.get("Steal")

local loadingStart: number? = nil

local function holdingBall(): boolean
	for _, ball in ballsFolder:GetChildren() do
		if ball:GetAttribute("HolderId") == player.UserId then
			return true
		end
	end
	return false
end

local function release()
	if not loadingStart then
		return
	end
	loadingStart = nil
	BallRenderer.setLocalLoading(false)
	ShootRelease:FireServer()
	HUD.hideMeter() -- the server's grade (ShotFeedback) replaces this shortly
end

local function onShoot(_, state: Enum.UserInputState)
	if state == Enum.UserInputState.Begin then
		if loadingStart or not holdingBall() then
			return Enum.ContextActionResult.Pass
		end
		loadingStart = os.clock()
		BallRenderer.setLocalLoading(true)
		ShootStart:FireServer()
		HUD.beginMeter()

		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if Config.JumpOnShot and humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
			humanoid.Jump = true
		end
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		release()
	end
	return Enum.ContextActionResult.Sink
end

local function onPass(_, state: Enum.UserInputState)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if loadingStart then
		-- Passing out of a shot attempt cancels the shot.
		loadingStart = nil
		BallRenderer.setLocalLoading(false)
		HUD.hideMeter()
	end
	PassRemote:FireServer()
	return Enum.ContextActionResult.Sink
end

local function onSteal(_, state: Enum.UserInputState)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	StealRemote:FireServer()
	return Enum.ContextActionResult.Sink
end

-- Optional: forward results to the Practical Basketball shot trainer if that
-- project (ReplicatedStorage.Shared.ShotEvents) is also in the place.
local function reportToTrainer(outcome: { [string]: any })
	local folder = ReplicatedStorage:FindFirstChild("Shared")
	local module = folder and folder:FindFirstChild("ShotEvents")
	if not (module and module:IsA("ModuleScript")) then
		return
	end
	local ok, ShotEvents = pcall(require, module)
	if ok and type(ShotEvents) == "table" and ShotEvents.Report then
		ShotEvents.Report({
			timingMs = outcome.timingMs,
			windowMs = outcome.windowMs,
			made = outcome.made,
			shotType = if outcome.points == 3 then "Three" else "Jumper",
		})
	end
end

HUD.start()
BallRenderer.start()

ContextActionService:BindAction("BasketballShoot", onShoot, true, table.unpack(Config.Keys.Shoot))
ContextActionService:BindAction("BasketballPass", onPass, true, table.unpack(Config.Keys.Pass))
ContextActionService:BindAction("BasketballSteal", onSteal, true, table.unpack(Config.Keys.Steal))
ContextActionService:SetTitle("BasketballShoot", "Shoot")
ContextActionService:SetTitle("BasketballPass", "Pass")
ContextActionService:SetTitle("BasketballSteal", "Steal")

RunService.RenderStepped:Connect(function()
	if loadingStart then
		local elapsed = os.clock() - loadingStart
		HUD.setMeter(BallMath.meterValue(elapsed))
		if elapsed >= Config.MeterAutoRelease then
			release()
		end
	end
end)

Remotes.get("ShotFeedback").OnClientEvent:Connect(function(data)
	HUD.showGrade(data)
end)

Remotes.get("ShotOutcome").OnClientEvent:Connect(function(outcome)
	if outcome.made then
		HUD.toast(`Bucket! +{outcome.points}`, "Success")
	else
		HUD.toast("Miss", "Error")
	end
	reportToTrainer(outcome)
end)

Remotes.get("Scored").OnClientEvent:Connect(function(scorer: Player, points: number)
	if scorer ~= player and scorer then
		HUD.toast(`{scorer.DisplayName} scored {points}`, "Info")
	end
end)

Remotes.get("Notice").OnClientEvent:Connect(function(text: string, kind: string)
	HUD.toast(text, kind)
end)

-- Dying mid-shot shouldn't leave the meter stuck on screen.
player.CharacterAdded:Connect(function()
	if loadingStart then
		loadingStart = nil
		BallRenderer.setLocalLoading(false)
		HUD.hideMeter()
	end
end)
