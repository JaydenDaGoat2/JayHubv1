-- Animates every held ball locally (dribble bounce, overhead while loading a
-- shot) by changing the server-created "Hold" weld's C0 on this client only.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("Config"))

local BallRenderer = {}

local player = Players.LocalPlayer
local localLoading = false
local blends: { [Instance]: number } = setmetatable({}, { __mode = "k" }) :: any

function BallRenderer.setLocalLoading(on: boolean)
	localLoading = on
end

local function floorOffset(root: BasePart): number
	local humanoid = root.Parent and root.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
		return -(humanoid.HipHeight + root.Size.Y / 2)
	end
	return -3 -- R6
end

function BallRenderer.start()
	local folder = workspace:WaitForChild("Basketballs")

	RunService.RenderStepped:Connect(function(dt)
		local clock = os.clock()
		for _, ball in folder:GetChildren() do
			local weld = ball:FindFirstChild("Hold")
			if not (weld and weld:IsA("Weld") and weld.Part0 and ball:IsA("BasePart")) then
				blends[ball] = nil
				continue
			end

			local mine = ball:GetAttribute("HolderId") == player.UserId
			local overhead = ball:GetAttribute("Loading") == true or (mine and localLoading)
			local blend = blends[ball] or 0
			blend += ((if overhead then 1 else 0) - blend) * math.min(dt * 14, 1)
			blends[ball] = blend

			local radius = ball.Size.Y / 2
			local low = floorOffset(weld.Part0) + radius
			local high = -0.4
			-- |sin| gives the sharp snap off the floor and a soft turn at the hand.
			local bounce = math.abs(math.sin(clock * Config.DribbleRate))
			local dribble = CFrame.new(Config.DribbleSide, low + (high - low) * bounce, -Config.DribbleForward)

			weld.C0 = dribble:Lerp(Config.HoldOverheadOffset, blend)
		end
	end)
end

return BallRenderer
