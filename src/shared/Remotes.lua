--!strict
-- One place for every RemoteEvent the basketball system uses.
-- The server creates them; clients wait for them.

local RunService = game:GetService("RunService")

local Remotes = {}

local NAMES = {
	"ShootStart", -- client -> server: started holding the shot button
	"ShootRelease", -- client -> server: let go of the shot button
	"Pass", -- client -> server
	"Steal", -- client -> server
	"ShotFeedback", -- server -> shooter: grade right after release
	"ShotOutcome", -- server -> shooter: made / missed once the shot resolves
	"Scored", -- server -> everyone: (player, points)
	"Notice", -- server -> one client: (text, kind)
}

local function folder(): Folder
	local existing = script.Parent:FindFirstChild("Remotes")
	if existing then
		return existing :: Folder
	end
	if RunService:IsServer() then
		local f = Instance.new("Folder")
		f.Name = "Remotes"
		for _, name in NAMES do
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = f
		end
		f.Parent = script.Parent
		return f
	end
	return script.Parent:WaitForChild("Remotes") :: Folder
end

function Remotes.get(name: string): RemoteEvent
	local f = folder()
	if RunService:IsServer() then
		return f:FindFirstChild(name) :: RemoteEvent
	end
	return f:WaitForChild(name) :: RemoteEvent
end

return Remotes
