-- Colors, fonts and sizes for the UI. Change values here to restyle every
-- window, control and notification at once.

local Theme = {}

Theme.Colors = {
	Background = Color3.fromRGB(17, 18, 23), -- window body
	Sidebar = Color3.fromRGB(22, 23, 29),
	Surface = Color3.fromRGB(27, 28, 36), -- section cards
	Elevated = Color3.fromRGB(36, 38, 48), -- buttons, inputs
	Hover = Color3.fromRGB(44, 46, 58),
	Track = Color3.fromRGB(52, 54, 66), -- slider/toggle background
	Stroke = Color3.fromRGB(44, 46, 56),
	Text = Color3.fromRGB(236, 237, 242),
	SubText = Color3.fromRGB(150, 153, 168),
	Muted = Color3.fromRGB(100, 103, 118),
	Knob = Color3.fromRGB(245, 245, 250),
	Success = Color3.fromRGB(72, 199, 116),
	Warning = Color3.fromRGB(240, 180, 60),
	Error = Color3.fromRGB(235, 87, 87),
}

-- Pickable accent colors (first one is the default).
Theme.Accents = {
	{ Name = "Blue", Color = Color3.fromRGB(88, 130, 255) },
	{ Name = "Violet", Color = Color3.fromRGB(150, 105, 255) },
	{ Name = "Orange", Color = Color3.fromRGB(240, 128, 48) },
	{ Name = "Green", Color = Color3.fromRGB(64, 196, 120) },
	{ Name = "Pink", Color = Color3.fromRGB(236, 90, 150) },
	{ Name = "Red", Color = Color3.fromRGB(232, 72, 72) },
}

Theme.Fonts = {
	Regular = Enum.Font.Gotham,
	Medium = Enum.Font.GothamMedium,
	Bold = Enum.Font.GothamBold,
}

Theme.TextSize = {
	Title = 15,
	Body = 13,
	Small = 11,
}

Theme.WindowSize = Vector2.new(580, 400)
Theme.SidebarWidth = 150
Theme.TopBarHeight = 44
Theme.Corner = 10
Theme.Tween = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

return Theme
