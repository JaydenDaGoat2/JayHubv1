--!nonstrict
-- Player Settings tab: profile, nameplate and movement.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Basketball"):WaitForChild("Config"))

local PROFILE_KEYS = { "Nickname", "JerseyNumber", "Position", "ShootingHand", "ShowNameplate", "NameplateColor", "WalkSpeed" }

return function(page: ScrollingFrame, ctx: any)
	local C, Store, Notify = ctx.Components, ctx.Store, ctx.Notify

	C.Header(page, "Player Settings", "Your profile as other players see it")

	local profile = C.Section(page, "Profile")
	C.TextInput(profile, {
		Label = "Nickname",
		Desc = "Shown on your nameplate (filtered by Roblox)",
		Key = "Nickname",
		Placeholder = "Your display name",
	})
	C.Slider(profile, { Label = "Jersey number", Key = "JerseyNumber" })
	C.Dropdown(profile, { Label = "Position", Key = "Position" })
	C.Dropdown(profile, { Label = "Shooting hand", Key = "ShootingHand" })

	local nameplate = C.Section(page, "Nameplate", "A tag above your head with your name, number and position")
	C.Toggle(nameplate, { Label = "Show nameplate", Key = "ShowNameplate" })
	C.ColorPicker(nameplate, { Label = "Nameplate colour", Key = "NameplateColor" })

	local movement = C.Section(page, "Movement")
	if Config.JayHub.AllowWalkSpeed then
		C.Slider(movement, { Label = "Walk speed", Desc = "Applied by the server", Key = "WalkSpeed" })
	else
		C.Paragraph(movement, "Walk speed is locked by this game's settings.")
	end

	local preview = C.Section(page, "Preview")
	local nameRow = C.InfoRow(preview, "Name", "")
	local tagRow = C.InfoRow(preview, "Tag", "")
	Store.observeMany(PROFILE_KEYS, function()
		local nickname = Store.get("Nickname")
		nameRow:Set(if nickname ~= "" then nickname else game:GetService("Players").LocalPlayer.DisplayName)
		tagRow:Set(("#%d · %s · %s hand"):format(Store.get("JerseyNumber"), Store.get("Position"), Store.get("ShootingHand")))
		tagRow.Label.TextColor3 = ctx.Schema.toColor(Store.get("NameplateColor"))
	end)

	C.Button(page, {
		Text = "Reset profile",
		Style = "Danger",
		Callback = function()
			Store.resetKeys(PROFILE_KEYS)
			Notify.success("Profile reset to defaults")
		end,
	})
end
