--!strict
-- Client controller: input (keyboard, gamepad, mobile buttons), the shot
-- meter, and the local dribble animation for every ball holder.

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local BallMath = require(Shared:WaitForChild("BallMath"))
local Ui = require(script.Parent:WaitForChild("Ui"))

local remotes = Shared:WaitForChild("Remotes")
local ShotStart = remotes:WaitForChild("ShotStart") :: RemoteEvent
local ShotRelease = remotes:WaitForChild("ShotRelease") :: RemoteEvent
local PassRemote = remotes:WaitForChild("Pass") :: RemoteEvent
local StealRemote = remotes:WaitForChild("Steal") :: RemoteEvent
local Feedback = remotes:WaitForChild("Feedback") :: RemoteEvent

local player = Players.LocalPlayer
Ui.init()

---------------------------------------------------------------------------
-- Ball lookup
---------------------------------------------------------------------------
local cachedBall: BasePart? = nil
local function getBall(): BasePart?
	if cachedBall and cachedBall.Parent then
		return cachedBall
	end
	for _, inst in CollectionService:GetTagged(Config.BallTag) do
		if inst:IsA("BasePart") then
			cachedBall = inst
			return inst
		end
	end
	cachedBall = nil
	return nil
end

local function isHolding(): boolean
	local ball = getBall()
	return ball ~= nil and ball:GetAttribute("Holder") == player.UserId
end

local function keyName(list: { Enum.KeyCode }): string
	return list[1].Name
end

---------------------------------------------------------------------------
-- Shooting
---------------------------------------------------------------------------
local loading = false
local loadStart = 0

local function releaseShot()
	if not loading then
		return
	end
	loading = false
	local elapsed = os.clock() - loadStart
	local value = BallMath.meterValue(elapsed)
	ShotRelease:FireServer(elapsed)
	Ui.releaseMeter(value, (BallMath.gradeRelease(value)))
end

local function onShoot(_: string, state: Enum.UserInputState, _: InputObject): Enum.ContextActionResult
	if state == Enum.UserInputState.Begin then
		if loading or not isHolding() then
			return Enum.ContextActionResult.Pass
		end
		loading = true
		loadStart = os.clock()
		ShotStart:FireServer()
		Ui.showMeter(true)

		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if Config.JumpOnShot and hum and hum.FloorMaterial ~= Enum.Material.Air then
			hum.Jump = true
		end
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		releaseShot()
	end
	return Enum.ContextActionResult.Sink
end

local function onPass(_: string, state: Enum.UserInputState, _: InputObject): Enum.ContextActionResult
	if state == Enum.UserInputState.Begin and not loading then
		PassRemote:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

local function onSteal(_: string, state: Enum.UserInputState, _: InputObject): Enum.ContextActionResult
	if state == Enum.UserInputState.Begin then
		StealRemote:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

---------------------------------------------------------------------------
-- Context-sensitive controls: offense when you have the ball, defense when not
---------------------------------------------------------------------------
local mode: string? = nil

local function setMode(newMode: string)
	if mode == newMode then
		return
	end
	mode = newMode
	ContextActionService:UnbindAction("BB_Shoot")
	ContextActionService:UnbindAction("BB_Pass")
	ContextActionService:UnbindAction("BB_Steal")

	if newMode == "Offense" then
		ContextActionService:BindAction("BB_Shoot", onShoot, true, table.unpack(Config.Keys.Shoot))
		ContextActionService:BindAction("BB_Pass", onPass, true, table.unpack(Config.Keys.Pass))
		ContextActionService:SetTitle("BB_Shoot", "Shoot")
		ContextActionService:SetTitle("BB_Pass", "Pass")
		ContextActionService:SetPosition("BB_Shoot", UDim2.new(1, -170, 1, -150))
		ContextActionService:SetPosition("BB_Pass", UDim2.new(1, -230, 1, -90))
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			Ui.setHint("Hold Shoot, release in the green")
		else
			Ui.setHint(
				string.format("Hold %s to shoot (release in the green)  ·  %s pass", keyName(Config.Keys.Shoot), keyName(Config.Keys.Pass))
			)
		end
	else
		ContextActionService:BindAction("BB_Steal", onSteal, true, table.unpack(Config.Keys.Steal))
		ContextActionService:SetTitle("BB_Steal", "Steal")
		ContextActionService:SetPosition("BB_Steal", UDim2.new(1, -170, 1, -150))
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			Ui.setHint("")
		else
			Ui.setHint(string.format("%s to steal", keyName(Config.Keys.Steal)))
		end
	end
end
setMode("Defense")

---------------------------------------------------------------------------
-- Server feedback
---------------------------------------------------------------------------
Feedback.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "Shot" then
		local detail = if data.contested then "Contested" else nil
		Ui.showGrade(data.grade, detail)
	elseif kind == "Score" then
		local mine = data.userId == player.UserId
		local text = string.format("%s +%d", mine and "You" or tostring(data.name), data.points)
		Ui.toast(text, if mine then Color3.fromRGB(70, 220, 100) else Color3.fromRGB(255, 200, 90))
	elseif kind == "Info" then
		Ui.toast(tostring(data))
	end
end)

---------------------------------------------------------------------------
-- Per-frame: meter, mode switching, dribble animation
---------------------------------------------------------------------------
local function dribbleOffset(root: BasePart, t: number): CFrame
	local char = root.Parent
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local legs = 2
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then
		legs = hum.HipHeight
	end
	local floorY = -(legs + root.Size.Y / 2) + Config.BallDiameter / 2
	local topY = -0.6
	local bounce = math.abs(math.sin(t * Config.DribbleRate))
	return CFrame.new(Config.DribbleSide, floorY + (topY - floorY) * bounce, -Config.DribbleForward)
end

RunService.RenderStepped:Connect(function(dt)
	local holding = isHolding()
	setMode(if holding then "Offense" else "Defense")

	if loading then
		if not holding then
			-- Lost the ball mid-shot (stolen).
			loading = false
			Ui.showMeter(false)
		else
			local elapsed = os.clock() - loadStart
			Ui.setMeter(BallMath.meterValue(elapsed))
			if elapsed >= Config.MeterAutoRelease then
				releaseShot()
			end
		end
	end

	-- Animate whoever has the ball (purely visual, local to this client).
	local ball = getBall()
	local weld = ball and ball:FindFirstChild("BallWeld")
	if ball and weld and weld:IsA("Weld") and weld.Part0 then
		if ball:GetAttribute("State") == "Hold" then
			weld.C0 = weld.C0:Lerp(Config.HoldOverheadOffset, math.min(1, dt * 18))
		else
			weld.C0 = dribbleOffset(weld.Part0, os.clock())
		end
	end
end)
