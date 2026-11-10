--!nonstrict
-- Practice dribble: a local ball that bounces beside the player with the
-- configured speed, height, hand and style. Crossovers swing the ball across
-- the body. The ball is only visible to this player.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Basketball")
local Config = require(Shared:WaitForChild("Config"))
local JayHubShared = Shared:WaitForChild("JayHub")
local Schema = require(JayHubShared:WaitForChild("Schema"))
local Signal = require(JayHubShared:WaitForChild("Signal"))
local Store = require(script.Parent.Parent.Core.Store)

local DribbleSystem = {}

DribbleSystem.Bounced = Signal.new() -- (bounceCount)
DribbleSystem.Crossed = Signal.new() -- (newHand)

local player = Players.LocalPlayer

local STYLES = {
	Standard = { Rate = 1, Height = 1, Forward = 1.2, Side = 1.15 },
	Low = { Rate = 1.35, Height = 0.6, Forward = 1.1, Side = 1.3 },
	Speed = { Rate = 1.15, Height = 1.05, Forward = 2.1, Side = 0.9 },
}
local CROSSOVER_TIME = 0.28

local ball: Part? = nil
local trail: Trail? = nil
local connection: RBXScriptConnection? = nil
local phase = 0 -- 0..1 per bounce
local bounces = 0
local side = 1 -- current lateral position (-1 left, 1 right), animated
local handSign = 1 -- target side
local crossStart: number? = nil
local hidden = false

local function targetHandSign(): number
	return if Store.get("DribbleHand") == "Left" then -1 else 1
end

local function makeBall(): Part
	local part = Instance.new("Part")
	part.Name = "JayHubPracticeBall"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.one * Config.BallDiameter
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = true
	part.Color = Schema.toColor(Store.get("BallColor"))

	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 0.3, 0)
	a0.Parent = part
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -0.3, 0)
	a1.Parent = part

	local newTrail = Instance.new("Trail")
	newTrail.Attachment0 = a0
	newTrail.Attachment1 = a1
	newTrail.Lifetime = 0.18
	newTrail.LightEmission = 0.6
	newTrail.FaceCamera = true
	newTrail.Transparency = NumberSequence.new(0.35, 1)
	newTrail.Color = ColorSequence.new(part.Color)
	newTrail.Enabled = Store.get("BallTrail") == true
	newTrail.Parent = part
	trail = newTrail

	part.Parent = workspace
	return part
end

local function getRig(): (BasePart?, Humanoid?)
	local character = player.Character
	if not character then
		return nil, nil
	end
	return character:FindFirstChild("HumanoidRootPart") :: BasePart?, character:FindFirstChildOfClass("Humanoid")
end

-- Starts a crossover to the other hand.
function DribbleSystem.crossover(): boolean
	if not ball or crossStart then
		return false
	end
	handSign = -handSign
	crossStart = os.clock()
	DribbleSystem.Crossed:Fire(if handSign > 0 then "Right" else "Left")
	return true
end

-- Temporarily hide the ball (e.g. while a practice shot is in the air).
function DribbleSystem.setHidden(state: boolean)
	hidden = state
	if ball then
		ball.Transparency = if state then 1 else 0
	end
	if trail then
		trail.Enabled = not state and Store.get("BallTrail") == true
	end
end

function DribbleSystem.isActive(): boolean
	return ball ~= nil
end

local function step(dt: number)
	local root, humanoid = getRig()
	local part = ball
	if not part then
		return
	end
	if not root or not humanoid or humanoid.Health <= 0 then
		part.Transparency = 1
		return
	end
	if not hidden then
		part.Transparency = 0
	end

	local style = STYLES[Store.get("DribbleStyle")] or STYLES.Standard
	local rate = (Store.get("DribbleSpeed") :: number) * style.Rate
	local moving = humanoid.MoveDirection.Magnitude > 0.1

	local previous = phase
	phase = (phase + dt * rate) % 1
	if phase < previous then
		bounces += 1
		DribbleSystem.Bounced:Fire(bounces)
		if Store.get("AutoCrossover") and bounces % (Store.get("CrossoverEvery") :: number) == 0 then
			DribbleSystem.crossover()
		end
	end

	-- Lateral position: smooth swing during a crossover.
	local forwardBoost = 0
	if crossStart then
		local t = math.clamp((os.clock() - crossStart) / CROSSOVER_TIME, 0, 1)
		local eased = t * t * (3 - 2 * t)
		side = -handSign + 2 * handSign * eased
		forwardBoost = math.sin(t * math.pi) * 0.7 -- ball passes in front of the body
		if t >= 1 then
			crossStart = nil
		end
	else
		side = handSign
	end

	-- Height: smooth at the hand, sharp bounce at the floor.
	local radius = Config.BallDiameter / 2
	local groundY = root.Position.Y - (root.Size.Y / 2 + humanoid.HipHeight)
	local floorY = groundY + radius
	local handY = groundY + 3 * (Store.get("DribbleHeight") :: number) * style.Height + radius
	local y = floorY + (handY - floorY) * math.abs(math.cos(math.pi * phase))

	local forward = style.Forward + forwardBoost + (if moving then 0.6 else 0)
	local flat = root.CFrame * CFrame.new(side * style.Side, 0, -forward)
	part.CFrame = CFrame.new(flat.Position.X, y, flat.Position.Z) * CFrame.Angles(phase * math.pi * 2, 0, 0)
end

function DribbleSystem.setEnabled(enabled: boolean)
	if enabled and not ball then
		handSign = targetHandSign()
		side = handSign
		phase = 0
		bounces = 0
		ball = makeBall()
		DribbleSystem.setHidden(hidden)
		connection = RunService.RenderStepped:Connect(function(dt)
			local ok, err = pcall(step, dt)
			if not ok then
				warn("[JayHub] dribble step failed:", err)
			end
		end)
	elseif not enabled and ball then
		if connection then
			connection:Disconnect()
			connection = nil
		end
		ball:Destroy()
		ball = nil
		trail = nil
		crossStart = nil
	end
end

function DribbleSystem.start()
	Store.observe("DribbleEnabled", function(enabled)
		DribbleSystem.setEnabled(enabled == true)
	end)
	Store.observe("DribbleHand", function()
		if ball and not crossStart and targetHandSign() ~= handSign then
			DribbleSystem.crossover()
		end
	end)
	Store.observe("BallColor", function(hex)
		if ball then
			ball.Color = Schema.toColor(hex)
		end
		if trail then
			trail.Color = ColorSequence.new(Schema.toColor(hex))
		end
	end)
	Store.observe("BallTrail", function(on)
		if trail then
			trail.Enabled = on == true and not hidden
		end
	end)
end

return DribbleSystem
