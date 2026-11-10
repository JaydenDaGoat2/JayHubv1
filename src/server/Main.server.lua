-- Server entry point: builds a court if the place has no hoops, then starts the ball logic.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("Config"))
local CourtBuilder = require(script.Parent:WaitForChild("CourtBuilder"))
local BallService = require(script.Parent:WaitForChild("BallService"))

if Config.AutoBuildCourt and #CollectionService:GetTagged(Config.HoopTag) == 0 then
	CourtBuilder.build()
end

BallService.start()
