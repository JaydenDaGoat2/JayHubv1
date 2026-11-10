--!nonstrict
-- Camera Settings tab.

local CAMERA_KEYS = {
	"CameraMode",
	"FieldOfView",
	"CameraSmoothing",
	"ShoulderOffset",
	"BroadcastDistance",
	"MaxZoom",
	"ShotShake",
	"ShakeIntensity",
}

return function(page: ScrollingFrame, ctx: any)
	local C, Store, Notify, Camera = ctx.Components, ctx.Store, ctx.Notify, ctx.CameraSystem

	C.Header(page, "Camera Settings", "Frame the court your way")

	local mode = C.Section(page, "Mode")
	C.Dropdown(mode, {
		Label = "Camera mode",
		Desc = "Default, over the shoulder, TV sideline or top-down",
		Key = "CameraMode",
	})
	C.Slider(mode, { Label = "Field of view", Key = "FieldOfView", Suffix = "°" })
	C.Slider(mode, { Label = "Smoothing", Key = "CameraSmoothing" })

	local framing = C.Section(page, "Framing")
	C.Slider(framing, { Label = "Shoulder offset", Key = "ShoulderOffset" })
	C.Slider(framing, { Label = "Broadcast / overhead distance", Key = "BroadcastDistance" })
	C.Slider(framing, { Label = "Max zoom distance", Key = "MaxZoom" })

	local effects = C.Section(page, "Effects")
	C.Toggle(effects, { Label = "Shot shake", Desc = "Small camera kick when you release", Key = "ShotShake" })
	C.Slider(effects, { Label = "Shake intensity", Key = "ShakeIntensity" })
	C.ButtonRow(effects, {
		{
			Text = "Test shake",
			Callback = function()
				if not Store.get("ShotShake") then
					Notify.warn("Turn on Shot shake first")
					return
				end
				Camera.shake(1)
			end,
		},
		{
			Text = "Next camera mode",
			Style = "Primary",
			Callback = function()
				Notify.info("Camera: " .. Camera.cycleMode())
			end,
		},
	})

	C.Button(page, {
		Text = "Reset camera settings",
		Style = "Danger",
		Callback = function()
			Store.resetKeys(CAMERA_KEYS)
			Notify.success("Camera settings reset")
		end,
	})
end
