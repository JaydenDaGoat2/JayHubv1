-- AutoGreen  -  Practical Basketball  |  standalone meter reader (Ultra) + clean draggable UI
-- Menu: drag the logo anywhere, tap it to open/close. Drag the menu by its bar. X closes it.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

local AG_URL = "https://raw.githubusercontent.com/jaydendagoat2/jayhubv1/claude/j/O.lua"
local SELF_URL = "https://raw.githubusercontent.com/jaydendagoat2/jayhubv1/claude/autogreen/AutoGreen.lua"

if getgenv and getgenv().__AutoGreenRunning then return end
if getgenv then getgenv().__AutoGreenRunning = true end

-- ===== the meter reader engine (Ultra), loaded from O.lua =====
local function httpGet(url)
	local get = (syn and syn.request) or (http and http.request) or request or http_request
	if get then
		local ok, res = pcall(get, { Url = url, Method = "GET" })
		if ok and res and res.Body then return res.Body end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok then return body end
end
local KS
do
	local src = httpGet(AG_URL)
	if src and #src > 1000 then
		local f = (loadstring or load)(src)
		if f then local ok, res = pcall(f) if ok then KS = res end end
	end
end
local S = KS and KS.Settings or {}
if KS then pcall(KS.start, function() end) end

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "AutoGreenUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 9999
local parent = (gethui and gethui()) or game:GetService("CoreGui")
local okp = pcall(function() gui.Parent = parent end)
if not okp then gui.Parent = LP:WaitForChild("PlayerGui") end

local ACCENT = Color3.fromRGB(80, 230, 140)
local BG = Color3.fromRGB(22, 25, 33)
local CARD = Color3.fromRGB(32, 36, 48)
local STROKE = Color3.fromRGB(70, 90, 120)
local TXT = Color3.fromRGB(235, 242, 255)
local SUB = Color3.fromRGB(150, 170, 200)

local function corner(o, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 10) c.Parent = o return c end
local function stroke(o, col, t) local s = Instance.new("UIStroke") s.Color = col or STROKE s.Transparency = t or 0.3 s.Thickness = 1.3 s.Parent = o return s end

-- makes a frame draggable across the whole screen by a given handle
local function draggable(handle, moves)
	local dragging, startPos, startInput
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = moves.Position
			startInput = i.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			moves.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- ----- the menu window -----
local win = Instance.new("Frame")
win.Name = "Menu"
win.Size = UDim2.fromOffset(300, 240)
win.Position = UDim2.fromScale(0.5, 0.42)
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = BG
win.Visible = false
win.Parent = gui
corner(win, 16)
stroke(win, ACCENT, 0.25)

local bar = Instance.new("Frame")
bar.Name = "Bar"
bar.Size = UDim2.new(1, 0, 0, 44)
bar.BackgroundColor3 = CARD
bar.Parent = win
corner(bar, 16)
local barFix = Instance.new("Frame") barFix.Size = UDim2.new(1,0,0,20) barFix.Position = UDim2.new(0,0,1,-20) barFix.BackgroundColor3 = CARD barFix.BorderSizePixel = 0 barFix.Parent = bar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 0)
title.Size = UDim2.new(1, -60, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Auto Green"
title.TextSize = 18
title.TextColor3 = TXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = bar

-- X close button
local xbtn = Instance.new("TextButton")
xbtn.AnchorPoint = Vector2.new(1, 0.5)
xbtn.Position = UDim2.new(1, -10, 0.5, 0)
xbtn.Size = UDim2.fromOffset(28, 28)
xbtn.BackgroundColor3 = Color3.fromRGB(70, 40, 44)
xbtn.Text = "X"
xbtn.Font = Enum.Font.GothamBold
xbtn.TextSize = 15
xbtn.TextColor3 = Color3.fromRGB(255, 120, 120)
xbtn.AutoButtonColor = true
xbtn.Parent = bar
corner(xbtn, 8)

draggable(bar, win)

-- a toggle row
local toggles = {}
local function addToggle(text, order, default, cb)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -24, 0, 46)
	row.Position = UDim2.fromOffset(12, 44 + 8 + (order - 1) * 54)
	row.BackgroundColor3 = CARD
	row.Parent = win
	corner(row, 10)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.Size = UDim2.new(1, -80, 1, 0)
	lbl.Font = Enum.Font.GothamMedium
	lbl.Text = text
	lbl.TextSize = 15
	lbl.TextColor3 = TXT
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	local sw = Instance.new("TextButton")
	sw.AnchorPoint = Vector2.new(1, 0.5)
	sw.Position = UDim2.new(1, -12, 0.5, 0)
	sw.Size = UDim2.fromOffset(52, 28)
	sw.AutoButtonColor = false
	sw.Text = ""
	sw.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
	sw.Parent = row
	corner(sw, 14)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(22, 22)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
	knob.Parent = sw
	corner(knob, 11)
	local state = default and true or false
	local function paint()
		sw.BackgroundColor3 = state and ACCENT or Color3.fromRGB(55, 60, 75)
		knob.Position = state and UDim2.fromOffset(27, 3) or UDim2.fromOffset(3, 3)
	end
	paint()
	sw.MouseButton1Click:Connect(function() state = not state paint() cb(state) end)
	toggles[text] = { set = function(v) state = v paint() end, get = function() return state end }
	return toggles[text]
end

-- Auto Green toggle -> drives the engine
addToggle("Auto Green", 1, S.AutoGreen == true, function(v) if KS then S.AutoGreen = v end end)
if KS then S.AutoGreen = toggles["Auto Green"].get() end

-- Auto Execute toggle -> write a loader to the executor's autoexec folder
local function setAutoExec(on)
	local loader = 'loadstring(game:HttpGet("' .. SELF_URL .. '"))()'
	local names = { "autoexec", "Autoexec", "autoexecute", "Autoexecute", "auto_execute" }
	local wroteAny = false
	if on then
		for _, folder in ipairs(names) do
			pcall(function()
				if type(isfolder) == "function" and isfolder(folder) and type(writefile) == "function" then
					writefile(folder .. "/AutoGreen.lua", loader)
					wroteAny = true
				end
			end)
		end
		-- fallback for executors that keep autoexec out of reach (e.g. Real): drop a copy next to workspace
		pcall(function() if type(writefile) == "function" then writefile("AutoGreen_autoexec.lua", loader) end end)
	else
		for _, folder in ipairs(names) do
			pcall(function()
				local p = folder .. "/AutoGreen.lua"
				if type(isfile) == "function" and isfile(p) and type(delfile) == "function" then delfile(p) end
			end)
		end
	end
	return wroteAny
end
addToggle("Auto Execute", 2, false, function(v) setAutoExec(v) end)

local note = Instance.new("TextLabel")
note.BackgroundTransparency = 1
note.Position = UDim2.fromOffset(14, 44 + 8 + 2 * 54 + 4)
note.Size = UDim2.new(1, -28, 0, 36)
note.Font = Enum.Font.Gotham
note.Text = "Auto Green reads the meter and lets go on the green. Drag this window by the top bar."
note.TextSize = 11
note.TextColor3 = SUB
note.TextWrapped = true
note.TextXAlignment = Enum.TextXAlignment.Left
note.TextYAlignment = Enum.TextYAlignment.Top
note.Parent = win

-- ----- the floating logo (drag anywhere, tap to toggle menu) -----
local logo = Instance.new("TextButton")
logo.Name = "Logo"
logo.Size = UDim2.fromOffset(56, 56)
logo.Position = UDim2.fromScale(0.04, 0.4)
logo.BackgroundColor3 = BG
logo.AutoButtonColor = false
logo.Text = "AG"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 20
logo.TextColor3 = ACCENT
logo.Parent = gui
corner(logo, 28)
stroke(logo, ACCENT, 0.1)

-- distinguish a tap (toggle menu) from a drag (move logo)
do
	local dragging, moved, startPos, startInput
	logo.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true moved = false
			startPos = logo.Position startInput = i.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then
				dragging = false
				if not moved then win.Visible = not win.Visible end
			end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			if d.Magnitude > 6 then moved = true end
			logo.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

xbtn.MouseButton1Click:Connect(function() win.Visible = false end)

-- a tiny toast
pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Auto Green", Text = KS and "Loaded. Tap the AG logo." or "Engine failed to load.", Duration = 4 })
end)
