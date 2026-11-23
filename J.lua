-- JayHub now requires a key. Ask the owner for your key and loadstring.
warn("[JayHub] This public link has been disabled. JayHub now requires a key - ask JayGotBucketzzz for your key and the new loadstring.")
pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", { Title = "JayHub", Text = "This link is disabled. A key is required - ask the owner.", Duration = 8 })
end)
