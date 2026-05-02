-- ============================================
--   Admin Tool Script - by DevSpace
--   Password: niqa123
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PASSWORD = "niqa123"

local flyEnabled = false
local espEnabled = false
local flySpeed = 60
local bodyVelocity, bodyGyro
local espObjects = {}
local flyConn

-- ============================================
-- MAIN GUI
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "AdminTool"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player.PlayerGui

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function makeShadow(parent)
	local s = Instance.new("ImageLabel")
	s.Name = "Shadow"
	s.AnchorPoint = Vector2.new(0.5, 0.5)
	s.BackgroundTransparency = 1
	s.Position = UDim2.new(0.5, 0, 0.5, 6)
	s.Size = UDim2.new(1, 24, 1, 24)
	s.ZIndex = parent.ZIndex - 1
	s.Image = "rbxassetid://6014261993"
	s.ImageColor3 = Color3.fromRGB(0, 0, 0)
	s.ImageTransparency = 0.5
	s.ScaleType = Enum.ScaleType.Slice
	s.SliceCenter = Rect.new(49, 49, 450, 450)
	s.Parent = parent
end

-- ============================================
-- LOADING SCREEN
-- ============================================
local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.new(1, 0, 1, 0)
loadFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
loadFrame.BorderSizePixel = 0
loadFrame.ZIndex = 100
loadFrame.Parent = gui

local loadLogo = Instance.new("TextLabel")
loadLogo.Size = UDim2.new(0, 200, 0, 40)
loadLogo.Position = UDim2.new(0.5, -100, 0.38, 0)
loadLogo.BackgroundTransparency = 1
loadLogo.Text = "ADMIN TOOL"
loadLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
loadLogo.TextSize = 26
loadLogo.Font = Enum.Font.GothamBlack
loadLogo.ZIndex = 101
loadLogo.Parent = loadFrame

local loadSub = Instance.new("TextLabel")
loadSub.Size = UDim2.new(0, 260, 0, 24)
loadSub.Position = UDim2.new(0.5, -130, 0.48, 0)
loadSub.BackgroundTransparency = 1
loadSub.Text = "Memuat sistem..."
loadSub.TextColor3 = Color3.fromRGB(120, 130, 160)
loadSub.TextSize = 13
loadSub.Font = Enum.Font.Gotham
loadSub.ZIndex = 101
loadSub.Parent = loadFrame

-- Progress bar bg
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 260, 0, 4)
barBg.Position = UDim2.new(0.5, -130, 0.56, 0)
barBg.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
barBg.BorderSizePixel = 0
barBg.ZIndex = 101
barBg.Parent = loadFrame
makeCorner(barBg, 4)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
barFill.BorderSizePixel = 0
barFill.ZIndex = 102
barFill.Parent = barBg
makeCorner(barFill, 4)

local loadPct = Instance.new("TextLabel")
loadPct.Size = UDim2.new(0, 260, 0, 20)
loadPct.Position = UDim2.new(0.5, -130, 0.59, 0)
loadPct.BackgroundTransparency = 1
loadPct.Text = "0%"
loadPct.TextColor3 = Color3.fromRGB(80, 120, 255)
loadPct.TextSize = 11
loadPct.Font = Enum.Font.GothamBold
loadPct.ZIndex = 101
loadPct.Parent = loadFrame

-- Animate loading bar
local steps = {"Menginisialisasi...", "Memuat modul...", "Menyiapkan ESP...", "Memeriksa izin...", "Selesai!"}
local function runLoading(onDone)
	local progress = 0
	for i, msg in ipairs(steps) do
		loadSub.Text = msg
		local target = i / #steps
		local tween = TweenService:Create(barFill, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {Size = UDim2.new(target, 0, 1, 0)})
		tween:Play()
		for p = math.floor(progress*100), math.floor(target*100) do
			loadPct.Text = p .. "%"
			task.wait(0.004)
		end
		progress = target
		task.wait(0.15)
	end
	task.wait(0.3)
	-- Fade out loading
	TweenService:Create(loadFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	for _, v in ipairs(loadFrame:GetDescendants()) do
		if v:IsA("TextLabel") or v:IsA("Frame") or v:IsA("ImageLabel") then
			pcall(function()
				TweenService:Create(v, TweenInfo.new(0.35), {
					BackgroundTransparency = 1,
					TextTransparency = 1,
					ImageTransparency = 1
				}):Play()
			end)
		end
	end
	task.wait(0.45)
	loadFrame.Visible = false
	onDone()
end

-- ============================================
-- PASSWORD SCREEN
-- ============================================
local pwFrame = Instance.new("Frame")
pwFrame.Size = UDim2.new(0, 300, 0, 160)
pwFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
pwFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 28)
pwFrame.BorderSizePixel = 0
pwFrame.Visible = false
pwFrame.ZIndex = 50
pwFrame.Parent = gui
makeCorner(pwFrame, 12)
makeShadow(pwFrame)

local pwAccent = Instance.new("Frame")
pwAccent.Size = UDim2.new(1, 0, 0, 3)
pwAccent.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
pwAccent.BorderSizePixel = 0
pwAccent.ZIndex = 51
pwAccent.Parent = pwFrame
makeCorner(pwAccent, 3)

local pwTitle = Instance.new("TextLabel")
pwTitle.Size = UDim2.new(1, 0, 0, 44)
pwTitle.BackgroundTransparency = 1
pwTitle.Text = "ðŸ”  Verifikasi Admin"
pwTitle.TextColor3 = Color3.fromRGB(220, 225, 255)
pwTitle.TextSize = 14
pwTitle.Font = Enum.Font.GothamBold
pwTitle.ZIndex = 51
pwTitle.Parent = pwFrame

local pwSub = Instance.new("TextLabel")
pwSub.Size = UDim2.new(1, -30, 0, 18)
pwSub.Position = UDim2.new(0, 15, 0, 42)
pwSub.BackgroundTransparency = 1
pwSub.Text = "Masukkan password untuk melanjutkan"
pwSub.TextColor3 = Color3.fromRGB(90, 100, 140)
pwSub.TextSize = 11
pwSub.Font = Enum.Font.Gotham
pwSub.TextXAlignment = Enum.TextXAlignment.Left
pwSub.ZIndex = 51
pwSub.Parent = pwFrame

local pwBox = Instance.new("TextBox")
pwBox.Size = UDim2.new(1, -30, 0, 36)
pwBox.Position = UDim2.new(0, 15, 0, 68)
pwBox.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
pwBox.TextColor3 = Color3.fromRGB(220, 225, 255)
pwBox.PlaceholderText = "Password..."
pwBox.PlaceholderColor3 = Color3.fromRGB(60, 70, 100)
pwBox.Text = ""
pwBox.TextSize = 13
pwBox.Font = Enum.Font.Gotham
pwBox.BorderSizePixel = 0
pwBox.ClearTextOnFocus = false
pwBox.ZIndex = 51
pwBox.Parent = pwFrame
makeCorner(pwBox, 8)

local pwBtn = Instance.new("TextButton")
pwBtn.Size = UDim2.new(1, -30, 0, 34)
pwBtn.Position = UDim2.new(0, 15, 0, 114)
pwBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 230)
pwBtn.Text = "Masuk"
pwBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pwBtn.TextSize = 13
pwBtn.Font = Enum.Font.GothamBold
pwBtn.BorderSizePixel = 0
pwBtn.ZIndex = 51
pwBtn.Parent = pwFrame
makeCorner(pwBtn, 8)

-- ============================================
-- MAIN PANEL
-- ============================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 230)
mainFrame.Position = UDim2.new(0, 16, 0.5, -115)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ZIndex = 50
mainFrame.Parent = gui
makeCorner(mainFrame, 12)
makeShadow(mainFrame)

local mainAccent = Instance.new("Frame")
mainAccent.Size = UDim2.new(1, 0, 0, 3)
mainAccent.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
mainAccent.BorderSizePixel = 0
mainAccent.ZIndex = 51
mainAccent.Parent = mainFrame
makeCorner(mainAccent, 3)

local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(1, -16, 0, 40)
mainTitle.Position = UDim2.new(0, 12, 0, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "âš™ï¸  Admin Tool"
mainTitle.TextColor3 = Color3.fromRGB(220, 225, 255)
mainTitle.TextSize = 13
mainTitle.Font = Enum.Font.GothamBold
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
mainTitle.ZIndex = 51
mainTitle.Parent = mainFrame

-- Divider
local div = Instance.new("Frame")
div.Size = UDim2.new(1, -24, 0, 1)
div.Position = UDim2.new(0, 12, 0, 40)
div.BackgroundColor3 = Color3.fromRGB(28, 32, 52)
div.BorderSizePixel = 0
div.ZIndex = 51
div.Parent = mainFrame

-- Toggle button factory
local function makeToggle(parent, yPos, label, icon)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -24, 0, 42)
	row.Position = UDim2.new(0, 12, 0, yPos)
	row.BackgroundTransparency = 1
	row.ZIndex = 51
	row.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -58, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = icon .. "  " .. label
	lbl.TextColor3 = Color3.fromRGB(180, 190, 220)
	lbl.TextSize = 12
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 52
	lbl.Parent = row

	local togBg = Instance.new("Frame")
	togBg.Size = UDim2.new(0, 44, 0, 22)
	togBg.Position = UDim2.new(1, -44, 0.5, -11)
	togBg.BackgroundColor3 = Color3.fromRGB(35, 40, 62)
	togBg.BorderSizePixel = 0
	togBg.ZIndex = 52
	togBg.Parent = row
	makeCorner(togBg, 11)

	local togCircle = Instance.new("Frame")
	togCircle.Size = UDim2.new(0, 16, 0, 16)
	togCircle.Position = UDim2.new(0, 3, 0.5, -8)
	togCircle.BackgroundColor3 = Color3.fromRGB(100, 110, 150)
	togCircle.BorderSizePixel = 0
	togCircle.ZIndex = 53
	togCircle.Parent = togBg
	makeCorner(togCircle, 8)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.ZIndex = 54
	btn.Parent = row

	local isOn = false
	local function setToggle(state)
		isOn = state
		TweenService:Create(togBg, TweenInfo.new(0.2), {
			BackgroundColor3 = state and Color3.fromRGB(70, 100, 230) or Color3.fromRGB(35, 40, 62)
		}):Play()
		TweenService:Create(togCircle, TweenInfo.new(0.2), {
			Position = state and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
			BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 110, 150)
		}):Play()
	end

	return btn, setToggle, function() return isOn end
end

-- FLY TOGGLE
local flyBtn, setFlyToggle, getFlyState = makeToggle(mainFrame, 50, "Terbang", "ðŸš€")
-- ESP TOGGLE
local espBtn, setEspToggle, getEspState = makeToggle(mainFrame, 100, "ESP Player", "ðŸ‘ï¸")

-- Speed slider label
local speedLbl = Instance.new("TextLabel")
speedLbl.Size = UDim2.new(1, -24, 0, 18)
speedLbl.Position = UDim2.new(0, 12, 0, 152)
speedLbl.BackgroundTransparency = 1
speedLbl.Text = "Speed: " .. flySpeed
speedLbl.TextColor3 = Color3.fromRGB(120, 130, 165)
speedLbl.TextSize = 11
speedLbl.Font = Enum.Font.Gotham
speedLbl.TextXAlignment = Enum.TextXAlignment.Left
speedLbl.ZIndex = 51
speedLbl.Parent = mainFrame

-- Speed slider
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -24, 0, 6)
sliderBg.Position = UDim2.new(0, 12, 0, 174)
sliderBg.BackgroundColor3 = Color3.fromRGB(28, 32, 52)
sliderBg.BorderSizePixel = 0
sliderBg.ZIndex = 51
sliderBg.Parent = mainFrame
makeCorner(sliderBg, 4)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(70, 100, 230)
sliderFill.BorderSizePixel = 0
sliderFill.ZIndex = 52
sliderFill.Parent = sliderBg
makeCorner(sliderFill, 4)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 14, 0, 14)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 53
sliderKnob.Parent = sliderBg
makeCorner(sliderKnob, 7)

-- Slider logic
local dragging = false
sliderKnob.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if not dragging then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local bg = sliderBg
		local absPos = bg.AbsolutePosition.X
		local absSize = bg.AbsoluteSize.X
		local rel = math.clamp((i.Position.X - absPos) / absSize, 0, 1)
		flySpeed = math.floor(20 + rel * 180)
		speedLbl.Text = "Speed: " .. flySpeed
		sliderFill.Size = UDim2.new(rel, 0, 1, 0)
		sliderKnob.Position = UDim2.new(rel, 0, 0.5, 0)
	end
end)

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -38, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
minBtn.Text = "â€”"
minBtn.TextColor3 = Color3.fromRGB(120, 130, 165)
minBtn.TextSize = 12
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 52
minBtn.Parent = mainFrame
makeCorner(minBtn, 6)

local minimized = false
local contentFrames = {div, mainTitle, flyBtn.Parent, espBtn.Parent, speedLbl, sliderBg}

minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	minBtn.Text = minimized and "+" or "â€”"
	TweenService:Create(mainFrame, TweenInfo.new(0.2), {
		Size = minimized and UDim2.new(0, 240, 0, 46) or UDim2.new(0, 240, 0, 230)
	}):Play()
end)

-- Warning label (bottom of panel)
local warnLbl = Instance.new("TextLabel")
warnLbl.Size = UDim2.new(1, -24, 0, 20)
warnLbl.Position = UDim2.new(0, 12, 0, 202)
warnLbl.BackgroundTransparency = 1
warnLbl.Text = ""
warnLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
warnLbl.TextSize = 10
warnLbl.Font = Enum.Font.Gotham
warnLbl.ZIndex = 51
warnLbl.Parent = mainFrame

-- ============================================
-- FLY SYSTEM
-- ============================================
local function enableFly()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	hum.PlatformStand = true

	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bodyVelocity.P = 1e5
	bodyVelocity.Parent = hrp

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bodyGyro.P = 5e4
	bodyGyro.D = 500
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	flyConn = RunService.Heartbeat:Connect(function()
		if not flyEnabled then return end
		local c = player.Character
		if not c then return end
		local h = c:FindFirstChild("HumanoidRootPart")
		if not h or not bodyVelocity or not bodyGyro then return end

		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

		local flat = Vector3.new(dir.X, 0, dir.Z)
		bodyVelocity.Velocity = dir.Magnitude > 0 and (
			Vector3.new(flat.X, 0, flat.Z).Magnitude > 0
			and Vector3.new(flat.Unit.X * flySpeed, dir.Y * flySpeed, flat.Unit.Z * flySpeed)
			or Vector3.new(0, dir.Y * flySpeed, 0)
		) or Vector3.zero

		bodyGyro.CFrame = CFrame.new(Vector3.zero, cam.CFrame.LookVector)
	end)
end

local function disableFly()
	if flyConn then flyConn:Disconnect(); flyConn = nil end
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
	if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
end

flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	setFlyToggle(flyEnabled)
	if flyEnabled then enableFly() else disableFly() end
end)

-- F key toggle
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F and mainFrame.Visible then
		flyEnabled = not flyEnabled
		setFlyToggle(flyEnabled)
		if flyEnabled then enableFly() else disableFly() end
	end
end)

-- ============================================
-- ESP SYSTEM
-- ============================================
local function clearESP()
	for _, obj in pairs(espObjects) do
		if obj and obj.Parent then obj:Destroy() end
	end
	espObjects = {}
end

local function addESP(target)
	if target == player then return end
	local char = target.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Billboard name tag
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_" .. target.Name
	bb.Size = UDim2.new(0, 120, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Parent = hrp

	local nameBox = Instance.new("Frame")
	nameBox.Size = UDim2.new(1, 0, 0.6, 0)
	nameBox.Position = UDim2.new(0, 0, 0, 0)
	nameBox.BackgroundColor3 = Color3.fromRGB(14, 16, 28)
	nameBox.BackgroundTransparency = 0.25
	nameBox.BorderSizePixel = 0
	nameBox.Parent = bb
	makeCorner(nameBox, 5)

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -8, 1, 0)
	nameLbl.Position = UDim2.new(0, 4, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = target.Name
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.TextSize = 11
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = nameBox

	-- Health bar bg
	local hpBg = Instance.new("Frame")
	hpBg.Size = UDim2.new(1, 0, 0.3, 0)
	hpBg.Position = UDim2.new(0, 0, 0.7, 0)
	hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	hpBg.BackgroundTransparency = 0.3
	hpBg.BorderSizePixel = 0
	hpBg.Parent = bb
	makeCorner(hpBg, 4)

	local hpFill = Instance.new("Frame")
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
	hpFill.BorderSizePixel = 0
	hpFill.Parent = hpBg
	makeCorner(hpFill, 4)

	-- Highlight
	local hl = Instance.new("SelectionBox")
	hl.Adornee = char
	hl.Color3 = Color3.fromRGB(80, 120, 255)
	hl.LineThickness = 0.06
	hl.SurfaceTransparency = 0.85
	hl.SurfaceColor3 = Color3.fromRGB(80, 120, 255)
	hl.Parent = char

	-- Update HP
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		local function updateHP()
			local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			hpFill.Size = UDim2.new(pct, 0, 1, 0)
			hpFill.BackgroundColor3 = Color3.fromHSV(pct * 0.33, 0.8, 0.9)
			nameLbl.Text = target.Name .. " [" .. math.floor(pct * 100) .. "%]"
		end
		updateHP()
		hum.HealthChanged:Connect(updateHP)
	end

	table.insert(espObjects, bb)
	table.insert(espObjects, hl)
end

local function refreshESP()
	clearESP()
	if not espEnabled then return end
	for _, p in ipairs(Players:GetPlayers()) do
		addESP(p)
	end
end

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	setEspToggle(espEnabled)
	refreshESP()
end)

Players.PlayerAdded:Connect(function(p)
	if espEnabled then
		p.CharacterAdded:Connect(function() task.wait(0.5); addESP(p) end)
	end
end)

-- ============================================
-- FLY DETECTION (Anti-cheat buat player lain)
-- ============================================
local warnedPlayers = {}

RunService.Heartbeat:Connect(function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p == player then continue end
		local char = p.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then continue end

		-- Cek apakah player melayang (Y velocity tinggi + ga di ground)
		local vel = hrp.AssemblyLinearVelocity
		local isFloating = math.abs(vel.Y) < 2 and hrp.Position.Y > 5
		local rayResult = workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0))

		if isFloating and not rayResult and hum.PlatformStand then
			if not warnedPlayers[p.Name] then
				warnedPlayers[p.Name] = true

				-- Tampilkan warning
				warnLbl.Text = "âš  " .. p.Name .. " terdeteksi terbang!"

				local notif = Instance.new("ScreenGui")
				notif.ResetOnSpawn = false
				notif.Parent = player.PlayerGui

				local nb = Instance.new("Frame")
				nb.Size = UDim2.new(0, 280, 0, 50)
				nb.Position = UDim2.new(0.5, -140, 0, 16)
				nb.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
				nb.BorderSizePixel = 0
				nb.ZIndex = 90
				nb.Parent = notif
				makeCorner(nb, 10)

				local nl = Instance.new("TextLabel")
				nl.Size = UDim2.new(1, -16, 1, 0)
				nl.Position = UDim2.new(0, 8, 0, 0)
				nl.BackgroundTransparency = 1
				nl.Text = "âš ï¸  " .. p.Name .. " terdeteksi terbang!"
				nl.TextColor3 = Color3.fromRGB(255, 255, 255)
				nl.TextSize = 12
				nl.Font = Enum.Font.GothamBold
				nl.ZIndex = 91
				nl.Parent = nb

				game:GetService("Debris"):AddItem(notif, 4)

				-- Reset warning setelah 10 detik
				task.delay(10, function() warnedPlayers[p.Name] = nil; warnLbl.Text = "" end)
			end
		end
	end
end)

-- ============================================
-- PASSWORD CHECK
-- ============================================
local function checkPW()
	if pwBox.Text == PASSWORD then
		pwFrame.Visible = false
		mainFrame.Visible = true
	else
		pwBox.Text = ""
		pwBox.PlaceholderText = "âŒ Salah, coba lagi"
		TweenService:Create(pwFrame, TweenInfo.new(0.05, Enum.EasingStyle.Bounce), {}):Play()
		-- Shake effect
		local origPos = pwFrame.Position
		for i = 1, 4 do
			TweenService:Create(pwFrame, TweenInfo.new(0.04), {Position = UDim2.new(0.5, -150 + (i%2==0 and 8 or -8), 0.5, -80)}):Play()
			task.wait(0.05)
		end
		TweenService:Create(pwFrame, TweenInfo.new(0.08), {Position = origPos}):Play()
	end
end

pwBtn.MouseButton1Click:Connect(checkPW)
pwBox.FocusLost:Connect(function(enter) if enter then checkPW() end end)

-- ============================================
-- START
-- ============================================
task.spawn(function()
	runLoading(function()
		pwFrame.Visible = true
	end)
end)
