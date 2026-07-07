-- ============================================
-- 秋雨脚本 v3.0 - ESP修复版 + 预加载
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local char, root, hum

-- ==================== 预加载画面 ====================
local SplashScreen = Instance.new("ScreenGui")
SplashScreen.Name = "SplashScreen"
SplashScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")
SplashScreen.ResetOnSpawn = false
SplashScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SplashScreen.DisplayOrder = 999

local SplashBg = Instance.new("Frame")
SplashBg.Size = UDim2.new(1, 0, 1, 0)
SplashBg.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
SplashBg.BorderSizePixel = 0
SplashBg.Parent = SplashScreen

local splashImage = Instance.new("ImageLabel")
splashImage.Size = UDim2.new(0, 180, 0, 180)
splashImage.Position = UDim2.new(0.5, -90, 0.32, -90)
splashImage.BackgroundTransparency = 1
splashImage.Image = "rbxassetid://你的图片ID"
splashImage.ScaleType = Enum.ScaleType.Fit
splashImage.ImageTransparency = 0.35
splashImage.Parent = SplashScreen
Instance.new("UICorner", splashImage).CornerRadius = UDim.new(0, 14)
local imgStroke = Instance.new("UIStroke")
imgStroke.Color = Color3.fromRGB(100, 150, 255)
imgStroke.Thickness = 2
imgStroke.Transparency = 0.3
imgStroke.Parent = splashImage

local particles = {}
for i = 1, 30 do
    local p = Instance.new("Frame")
    local s = 3 + math.random() * 5
    p.Size = UDim2.new(0, s, 0, s)
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(80 + math.random() * 100, 120 + math.random() * 100, 255)
    p.BackgroundTransparency = 0.3
    p.BorderSizePixel = 0
    p.ZIndex = 2
    p.Parent = SplashScreen
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    local g = Instance.new("UIStroke")
    g.Color = p.BackgroundColor3; g.Thickness = 1; g.Transparency = 0.5; g.Parent = p
    table.insert(particles, {frame = p, x = math.random(), y = math.random(), sx = (math.random() - 0.5) * 0.002, sy = -0.001 - math.random() * 0.005, alpha = 0.3 + math.random() * 0.4})
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 36)
titleLabel.Position = UDim2.new(0, 0, 0.6, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "秋雨脚本"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 30
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextStrokeTransparency = 0
titleLabel.TextStrokeColor3 = Color3.fromRGB(50, 100, 255)
titleLabel.ZIndex = 3
titleLabel.Parent = SplashScreen

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 160, 0, 4)
loadBarBg.Position = UDim2.new(0.5, -80, 0.7, 0)
loadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = SplashScreen
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)

local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
loadBar.BorderSizePixel = 0
loadBar.Parent = loadBarBg
Instance.new("UICorner", loadBar).CornerRadius = UDim.new(1, 0)
local lg = Instance.new("UIStroke")
lg.Color = Color3.fromRGB(150, 200, 255); lg.Thickness = 1.5; lg.Transparency = 0.3; lg.Parent = loadBar

local totalTime = 0; local lp = 0
local pc = RunService.RenderStepped:Connect(function(dt)
    totalTime += dt; lp = math.min(lp + dt * 0.4, 1)
    loadBar.Size = UDim2.new(lp, 0, 1, 0)
    local pulse = 1 + math.sin(totalTime * 2.5) * 0.06
    splashImage.Size = UDim2.new(0, 180 * pulse, 0, 180 * pulse)
    splashImage.Position = UDim2.new(0.5, -90 * pulse, 0.32, -90 * pulse)
    for _, p in pairs(particles) do
        p.x += p.sx; p.y += p.sy
        if p.y < -0.1 then p.x = math.random(); p.y = 1.1 end
        p.frame.Position = UDim2.new(p.x, 0, p.y, 0)
        p.frame.BackgroundTransparency = 1 - p.alpha + math.sin(totalTime * 3 + p.x * 10) * 0.2
    end
    titleLabel.TextTransparency = 0.1 + math.sin(totalTime * 1.5) * 0.1
end)

task.wait(2)
local ts = TweenService; local fi = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
for _, p in pairs(particles) do ts:Create(p.frame, fi, {BackgroundTransparency = 1}):Play() end
ts:Create(SplashBg, fi, {BackgroundTransparency = 1}):Play()
ts:Create(splashImage, fi, {ImageTransparency = 1}):Play()
ts:Create(titleLabel, fi, {TextTransparency = 1}):Play()
ts:Create(loadBarBg, fi, {BackgroundTransparency = 1}):Play()
ts:Create(loadBar, fi, {BackgroundTransparency = 1}):Play()
task.wait(0.5)
pc:Disconnect()
SplashScreen:Destroy()

-- ==================== 状态管理 ====================
local State = {
    Flying = false, Spinning = false, Circling = false,
    NoClip = false, InfJump = false, Speed = 1,
    ESP = false, ESPBox = false, ESPHealth = false,
    ESPDistance = false, ESPTracers = false,
    Aimbot = false, AimbotVisible = false,
    Hitbox = false, HitboxSize = 5, Minimized = false,
}

local Components = {
    FlyBodyVelocity = nil, FlyConnection = nil, FlyKeyBegan = nil, FlyKeyEnded = nil,
    SpinAngularVelocity = nil, CircleConnection = nil, CircleTarget = nil,
    CircleAngle = 0, CircleSpeed = 2, JumpHeartbeat = nil, NoClipConnection = nil,
    SelectedCircleTarget = nil, ESPConnections = {}, AimbotConnection = nil,
    HitboxConnection = nil, HitboxParts = {},
}

-- ==================== 角色初始化 ====================
local function SetupCharacter()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end
SetupCharacter()
LocalPlayer.CharacterAdded:Connect(function()
    SetupCharacter()
    if State.NoClip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ==================== UI创建 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QiuYuScript"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 200, 0, 340)
MainWindow.Position = UDim2.new(0.5, -100, 0.5, -170)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainWindow.BackgroundTransparency = 0.25
MainWindow.BorderSizePixel = 0
MainWindow.Parent = ScreenGui
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 100, 255); MainStroke.Thickness = 1.5; MainStroke.Transparency = 0.3; MainStroke.Parent = MainWindow

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255); TitleBar.BackgroundTransparency = 0.9; TitleBar.BorderSizePixel = 0; TitleBar.Parent = MainWindow
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0); TitleLabel.Position = UDim2.new(0, 8, 0, 0); TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "秋雨脚本"; TitleLabel.TextColor3 = Color3.fromRGB(80, 150, 255); TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22); MinBtn.Position = UDim2.new(1, -50, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); MinBtn.BackgroundTransparency = 0.7
MinBtn.Text = "━"; MinBtn.TextColor3 = Color3.fromRGB(80, 150, 255); MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold; MinBtn.BorderSizePixel = 0; MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22); CloseBtn.Position = UDim2.new(1, -26, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60); CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 24); TabContainer.Position = UDim2.new(0, 0, 0, 28)
TabContainer.BackgroundTransparency = 1; TabContainer.Parent = MainWindow

local function CreateTab(name, pos)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 48, 0, 22); tab.Position = UDim2.new(0, pos, 0, 1)
    tab.BackgroundColor3 = Color3.fromRGB(40, 40, 60); tab.BackgroundTransparency = 0.4
    tab.Text = name; tab.TextColor3 = Color3.fromRGB(200, 200, 220); tab.TextSize = 10
    tab.Font = Enum.Font.GothamBold; tab.BorderSizePixel = 0; tab.Parent = TabContainer
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 6)
    return tab
end

local ESPTab = CreateTab("ESP", 2)
local FuncTab = CreateTab("功能", 52)
local CombatTab = CreateTab("战斗", 102)
local PlayerTab = CreateTab("玩家", 152)
ESPTab.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
ESPTab.TextColor3 = Color3.fromRGB(255, 255, 255)

local function CreateContent()
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -12, 1, -58); c.Position = UDim2.new(0, 6, 0, 54)
    c.BackgroundTransparency = 1; c.Visible = false; c.Parent = MainWindow
    return c
end

local ESPContent = CreateContent(); ESPContent.Visible = true
local FuncContent = CreateContent()
local CombatContent = CreateContent()
local PlayerContent = CreateContent()

local function CreateButton(parent, x, y, w, h, text, active)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w, 0, h); btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = active and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    btn.BackgroundTransparency = 0.4; btn.Text = text; btn.TextColor3 = Color3.fromRGB(200, 220, 255)
    btn.TextSize = 10; btn.Font = Enum.Font.GothamMedium; btn.BorderSizePixel = 0; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(50, 100, 255); st.Thickness = 1; st.Transparency = 0.5; st.Parent = btn
    return btn
end

-- ESP标签页 - 5个按钮
local ESPToggle = CreateButton(ESPContent, 0, 2, 186, 28, "ESP: 关闭", false)
local ESPBoxBtn = CreateButton(ESPContent, 0, 34, 90, 28, "方框: 关", false)
local ESPHealthBtn = CreateButton(ESPContent, 96, 34, 90, 28, "血量: 关", false)
local ESPDistBtn = CreateButton(ESPContent, 0, 66, 90, 28, "距离: 关", false)
local ESPTraceBtn = CreateButton(ESPContent, 96, 66, 90, 28, "射线: 关", false)

-- 功能标签页
local FlyBtn = CreateButton(FuncContent, 0, 2, 90, 28, "飞行", false)
local SpinBtn = CreateButton(FuncContent, 96, 2, 90, 28, "自转", false)
local CircleBtn = CreateButton(FuncContent, 0, 34, 90, 28, "绕圈", false)
local JumpBtn = CreateButton(FuncContent, 96, 34, 90, 28, "无限跳", false)
local NoClipBtn = CreateButton(FuncContent, 0, 66, 90, 28, "穿墙", false)
local SpeedBtn = CreateButton(FuncContent, 96, 66, 90, 28, "加速1x", false)
local StopBtn = CreateButton(FuncContent, 0, 98, 186, 26, "停止全部", false)
StopBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)

local CircleTargetLabel = Instance.new("TextLabel")
CircleTargetLabel.Size = UDim2.new(1, 0, 0, 16); CircleTargetLabel.Position = UDim2.new(0, 0, 0, 132)
CircleTargetLabel.BackgroundTransparency = 1; CircleTargetLabel.Text = "绕圈目标: 无"
CircleTargetLabel.TextColor3 = Color3.fromRGB(150, 180, 220); CircleTargetLabel.TextSize = 10
CircleTargetLabel.Font = Enum.Font.GothamMedium; CircleTargetLabel.Parent = FuncContent

-- 战斗标签页
local AimbotToggle = CreateButton(CombatContent, 0, 2, 90, 28, "自瞄", false)
local AimbotVisBtn = CreateButton(CombatContent, 96, 2, 90, 28, "可视检查", false)
local HitboxToggle = CreateButton(CombatContent, 0, 34, 90, 28, "范围伤害", false)
local HitboxUpBtn = CreateButton(CombatContent, 96, 34, 44, 28, "+", false)
local HitboxDownBtn = CreateButton(CombatContent, 142, 34, 44, 28, "-", false)
local HitboxSizeLabel = Instance.new("TextLabel")
HitboxSizeLabel.Size = UDim2.new(1, 0, 0, 18); HitboxSizeLabel.Position = UDim2.new(0, 0, 0, 68)
HitboxSizeLabel.BackgroundTransparency = 1; HitboxSizeLabel.Text = "范围大小: 5"
HitboxSizeLabel.TextColor3 = Color3.fromRGB(150, 180, 220); HitboxSizeLabel.TextSize = 11
HitboxSizeLabel.Font = Enum.Font.GothamBold; HitboxSizeLabel.Parent = CombatContent

-- 玩家标签页
local PlayerModeLabel = Instance.new("TextLabel")
PlayerModeLabel.Size = UDim2.new(1, 0, 0, 18); PlayerModeLabel.Position = UDim2.new(0, 0, 0, 2)
PlayerModeLabel.BackgroundTransparency = 1; PlayerModeLabel.Text = "模式: 传送"
PlayerModeLabel.TextColor3 = Color3.fromRGB(150, 180, 220); PlayerModeLabel.TextSize = 11
PlayerModeLabel.Font = Enum.Font.GothamBold; PlayerModeLabel.Parent = PlayerContent
local ModeSwitchBtn = CreateButton(PlayerContent, 0, 24, 186, 24, "切换为绕圈模式", false)

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, 0, 0, 190); PlayerList.Position = UDim2.new(0, 0, 0, 54)
PlayerList.BackgroundColor3 = Color3.fromRGB(255, 255, 255); PlayerList.BackgroundTransparency = 0.85
PlayerList.BorderSizePixel = 0; PlayerList.ScrollBarThickness = 3
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(50, 100, 255); PlayerList.CanvasSize = UDim2.new(0, 0, 0, 200)
PlayerList.Parent = PlayerContent
Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 8)

local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 44, 0, 44); RestoreBtn.Position = UDim2.new(0.02, 0, 0.5, -22)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 255); RestoreBtn.BackgroundTransparency = 0.3
RestoreBtn.Text = "秋雨"; RestoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255); RestoreBtn.TextSize = 11
RestoreBtn.Font = Enum.Font.GothamBold; RestoreBtn.BorderSizePixel = 0; RestoreBtn.Visible = false; RestoreBtn.Parent = ScreenGui
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", RestoreBtn).Color = Color3.fromRGB(100, 150, 255)
RestoreBtn.UIStroke.Thickness = 2; RestoreBtn.UIStroke.Transparency = 0.3

-- ==================== 标签切换 ====================
local function SwitchTab(tab)
    ESPContent.Visible = (tab == "ESP"); FuncContent.Visible = (tab == "Func")
    CombatContent.Visible = (tab == "Combat"); PlayerContent.Visible = (tab == "Player")
    ESPTab.BackgroundColor3 = (tab == "ESP") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    FuncTab.BackgroundColor3 = (tab == "Func") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    CombatTab.BackgroundColor3 = (tab == "Combat") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    PlayerTab.BackgroundColor3 = (tab == "Player") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    if tab == "Player" then RefreshPlayerList() end
end
ESPTab.MouseButton1Click:Connect(function() SwitchTab("ESP") end)
FuncTab.MouseButton1Click:Connect(function() SwitchTab("Func") end)
CombatTab.MouseButton1Click:Connect(function() SwitchTab("Combat") end)
PlayerTab.MouseButton1Click:Connect(function() SwitchTab("Player") end)

MinBtn.MouseButton1Click:Connect(function() State.Minimized = true; MainWindow.Visible = false; RestoreBtn.Visible = true end)
RestoreBtn.MouseButton1Click:Connect(function() State.Minimized = false; MainWindow.Visible = true; RestoreBtn.Visible = false end)

-- ==================== 飞行 ====================
local function StartFlying()
    if State.Flying then return end
    State.Flying = true; FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1,1,1)*50000; bv.Velocity = Vector3.zero; bv.Parent = root
    Components.FlyBodyVelocity = bv
    local md, ud, sp = Vector3.zero, 0, 50
    Components.FlyConnection = RunService.Heartbeat:Connect(function()
        if not State.Flying or not Components.FlyBodyVelocity then return end
        local cam = Camera; if not cam then return end
        local fw = cam.CFrame.LookVector * Vector3.new(1,0,1); local rt = cam.CFrame.RightVector * Vector3.new(1,0,1)
        local mv = (fw * -md.Z) + (rt * md.X) + Vector3.new(0, ud, 0)
        Components.FlyBodyVelocity.Velocity = mv.Magnitude > 0.1 and mv.Unit * sp or Vector3.zero
    end)
    Components.FlyKeyBegan = UserInputService.InputBegan:Connect(function(i,g) if g then return end
        if i.KeyCode == Enum.KeyCode.W then md += Vector3.new(0,0,-1) elseif i.KeyCode == Enum.KeyCode.S then md += Vector3.new(0,0,1)
        elseif i.KeyCode == Enum.KeyCode.A then md += Vector3.new(-1,0,0) elseif i.KeyCode == Enum.KeyCode.D then md += Vector3.new(1,0,0)
        elseif i.KeyCode == Enum.KeyCode.Space then ud = 1 elseif i.KeyCode == Enum.KeyCode.LeftControl then ud = -1 end
    end)
    Components.FlyKeyEnded = UserInputService.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W then md -= Vector3.new(0,0,-1) elseif i.KeyCode == Enum.KeyCode.S then md -= Vector3.new(0,0,1)
        elseif i.KeyCode == Enum.KeyCode.A then md -= Vector3.new(-1,0,0) elseif i.KeyCode == Enum.KeyCode.D then md -= Vector3.new(1,0,0)
        elseif i.KeyCode == Enum.KeyCode.Space then ud = 0 elseif i.KeyCode == Enum.KeyCode.LeftControl then ud = 0 end
    end)
end
local function StopFlying()
    State.Flying = false; FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    if Components.FlyBodyVelocity then Components.FlyBodyVelocity:Destroy(); Components.FlyBodyVelocity = nil end
    if Components.FlyConnection then Components.FlyConnection:Disconnect(); Components.FlyConnection = nil end
    if Components.FlyKeyBegan then Components.FlyKeyBegan:Disconnect(); Components.FlyKeyBegan = nil end
    if Components.FlyKeyEnded then Components.FlyKeyEnded:Disconnect(); Components.FlyKeyEnded = nil end
end

-- ==================== 自转 ====================
local function StartSpinning()
    if State.Spinning then return end
    State.Spinning = true; SpinBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40); hum.AutoRotate = false
    if root:FindFirstChild("SpinRotator") then root.SpinRotator:Destroy() end
    local av = Instance.new("BodyAngularVelocity"); av.Name = "SpinRotator"; av.MaxTorque = Vector3.new(0,math.huge,0)
    av.AngularVelocity = Vector3.new(0,70,0); av.Parent = root; Components.SpinAngularVelocity = av
end
local function StopSpinning()
    State.Spinning = false; SpinBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    if Components.SpinAngularVelocity then Components.SpinAngularVelocity:Destroy(); Components.SpinAngularVelocity = nil end
    hum.AutoRotate = true
end

-- ==================== 绕圈 ====================
local function StartCircling(target)
    if State.Circling then StopCircling() end
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not root then return end
    State.Circling = true; Components.CircleTarget = target; Components.CircleAngle = math.random()*math.pi*2
    CircleBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    local r, ho, sm = 8, 3, 0.5
    Components.CircleConnection = RunService.Heartbeat:Connect(function()
        if not State.Circling or not Components.CircleTarget then StopCircling(); return end
        local tc = Components.CircleTarget.Character; if not tc then StopCircling(); return end
        local tr = tc:FindFirstChild("HumanoidRootPart"); if not tr or not root or not root.Parent then StopCircling(); return end
        Components.CircleAngle += Components.CircleSpeed * 0.05
        local tp = tr.Position
        root.CFrame = CFrame.new(root.Position:Lerp(Vector3.new(tp.X+r*math.cos(Components.CircleAngle), tp.Y+ho, tp.Z+r*math.sin(Components.CircleAngle)), sm))
    end)
end
local function StopCircling()
    State.Circling = false; Components.CircleTarget = nil; CircleBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    CircleTargetLabel.Text = "绕圈目标: 无"
    if Components.CircleConnection then Components.CircleConnection:Disconnect(); Components.CircleConnection = nil end
end

-- ==================== 无限跳 ====================
local function ToggleInfJump()
    State.InfJump = not State.InfJump; JumpBtn.BackgroundColor3 = State.InfJump and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.InfJump then
        Components.JumpHeartbeat = RunService.Heartbeat:Connect(function()
            if not State.InfJump or not hum or not hum.Parent then return end
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Jumping then hum.Jump = true end
        end)
    else
        if Components.JumpHeartbeat then Components.JumpHeartbeat:Disconnect(); Components.JumpHeartbeat = nil end
    end
end

-- ==================== 穿墙 ====================
local function ToggleNoClip()
    State.NoClip = not State.NoClip; NoClipBtn.BackgroundColor3 = State.NoClip and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.NoClip then
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        Components.NoClipConnection = char.DescendantAdded:Connect(function(p) if p:IsA("BasePart") and State.NoClip then p.CanCollide = false end end)
    else
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
        if Components.NoClipConnection then Components.NoClipConnection:Disconnect(); Components.NoClipConnection = nil end
    end
end

-- ==================== 加速 ====================
local function CycleSpeed()
    local speeds = {1,2,4,8,16}; local idx = 1
    for i,v in ipairs(speeds) do if v == State.Speed then idx = i; break end end
    idx = idx % #speeds + 1; State.Speed = speeds[idx]; hum.WalkSpeed = 16 * State.Speed
    SpeedBtn.Text = "加速"..State.Speed.."x"
    SpeedBtn.BackgroundColor3 = State.Speed > 1 and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
end

-- ==================== 停止全部 ====================
local function StopAll()
    if State.Flying then StopFlying() end
    if State.Spinning then StopSpinning() end
    if State.Circling then StopCircling() end
    if State.InfJump then ToggleInfJump() end
    if State.NoClip then ToggleNoClip() end
    if State.Aimbot then ToggleAimbot() end
    if State.Hitbox then ToggleHitbox() end
    if State.Speed ~= 1 then State.Speed = 1; hum.WalkSpeed = 16; SpeedBtn.Text = "加速1x"; SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60) end
end

-- ==================== 传送 ====================
local function TeleportToPlayer(tp)
    if not tp or not root then return false end
    local tc = tp.Character
    if tc and tc:FindFirstChild("HumanoidRootPart") then root.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0,3,0); return true end
    return false
end

-- ==================== 自瞄 ====================
local function GetClosestPlayer()
    local cl, sd = nil, math.huge
    for _, pl in pairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        local tc = pl.Character; if not tc then continue end
        local hd = tc:FindFirstChild("Head"); if not hd then continue end
        if State.AimbotVisible then
            local _, os = Camera:WorldToViewportPoint(hd.Position); if not os then continue end
            local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {char}; rp.FilterType = Enum.RaycastFilterType.Blacklist
            local ry = workspace:Raycast(Camera.CFrame.Position, (hd.Position - Camera.CFrame.Position).Unit * 500, rp)
            if ry then local hc = ry.Instance:FindFirstAncestorOfClass("Model"); if hc ~= pl.Character then continue end end
        end
        local sp, os = Camera:WorldToViewportPoint(hd.Position)
        if os then
            local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local d = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
            if d < sd then sd = d; cl = pl end
        end
    end
    return cl
end

local function ToggleAimbot()
    State.Aimbot = not State.Aimbot; AimbotToggle.BackgroundColor3 = State.Aimbot and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.Aimbot then
        Components.AimbotConnection = RunService.Heartbeat:Connect(function()
            if not State.Aimbot then return end
            local t = GetClosestPlayer()
            if t and t.Character and t.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
            end
        end)
    else
        if Components.AimbotConnection then Components.AimbotConnection:Disconnect(); Components.AimbotConnection = nil end
    end
end

-- ==================== 范围伤害 ====================
local function ExpandHitbox(ch)
    local pts = {}
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local os = p.Size; p.Size = os * State.HitboxSize; p.Transparency = 0.7; p.CanCollide = true
            table.insert(pts, {part = p, oldSize = os})
        end
    end
    return pts
end
local function RestoreHitbox(pts)
    for _, d in pairs(pts) do if d.part and d.part.Parent then d.part.Size = d.oldSize end end
end
local function ToggleHitbox()
    State.Hitbox = not State.Hitbox; HitboxToggle.BackgroundColor3 = State.Hitbox and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.Hitbox then
        for _, pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer and pl.Character then Components.HitboxParts[pl] = ExpandHitbox(pl.Character) end end
        Components.HitboxConnection = Players.PlayerAdded:Connect(function(pl)
            pl.CharacterAdded:Connect(function(ch) task.wait(0.5); if State.Hitbox then Components.HitboxParts[pl] = ExpandHitbox(ch) end end)
        end)
    else
        for _, pts in pairs(Components.HitboxParts) do RestoreHitbox(pts) end; Components.HitboxParts = {}
        if Components.HitboxConnection then Components.HitboxConnection:Disconnect(); Components.HitboxConnection = nil end
    end
end

-- ==================== ESP系统（Drawing.new - 5个功能独立） ====================
local ESPDrawings = {}

local function CreateESP(player)
    local drawings = {}
    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Color3.fromRGB(255, 255, 255); box.Thickness = 1.5; box.Filled = false; box.Transparency = 0.7
    drawings.Box = box
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false; nameTag.Color = Color3.fromRGB(255, 255, 255); nameTag.Size = 13; nameTag.Center = true; nameTag.Outline = true; nameTag.Font = 3
    drawings.Name = nameTag
    local healthBg = Drawing.new("Square")
    healthBg.Visible = false; healthBg.Color = Color3.fromRGB(30, 30, 30); healthBg.Thickness = 1; healthBg.Filled = true
    drawings.HealthBg = healthBg
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false; healthBar.Color = Color3.fromRGB(0, 255, 0); healthBar.Thickness = 1; healthBar.Filled = true
    drawings.HealthBar = healthBar
    local distance = Drawing.new("Text")
    distance.Visible = false; distance.Color = Color3.fromRGB(255, 255, 255); distance.Size = 12; distance.Center = true; distance.Outline = true; distance.Font = 3
    drawings.Distance = distance
    local tracer = Drawing.new("Line")
    tracer.Visible = false; tracer.Color = Color3.fromRGB(255, 255, 255); tracer.Thickness = 1; tracer.Transparency = 0.5
    drawings.Tracer = tracer
    ESPDrawings[player] = drawings
    return drawings
end

local function UpdateESP()
    for player, drawings in pairs(ESPDrawings) do
        if not player or not player.Parent then
            for _, d in pairs(drawings) do d:Remove() end
            ESPDrawings[player] = nil; continue
        end
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
            for _, d in pairs(drawings) do d.Visible = false end; continue
        end
        if not root then continue end
        local targetRoot = character.HumanoidRootPart; local targetHum = character.Humanoid
        local position, onScreen = Camera:WorldToViewportPoint(targetRoot.Position)
        if not onScreen then
            for _, d in pairs(drawings) do d.Visible = false end; continue
        end
        local dist = (root.Position - targetRoot.Position).Magnitude
        local scale = math.clamp(1 / (dist * 0.05), 0.5, 2)
        local boxSize = Vector2.new(40 * scale, 60 * scale)
        local boxPos = Vector2.new(position.X - boxSize.X/2, position.Y - boxSize.Y/2)
        
        -- 方框
        if State.ESPBox then
            drawings.Box.Visible = true; drawings.Box.Size = boxSize; drawings.Box.Position = boxPos
            local tc = player.TeamColor and player.TeamColor.Color
            drawings.Box.Color = tc or Color3.fromRGB(255, 255, 255)
        else drawings.Box.Visible = false end
        
        -- 名字始终显示（ESP开启时）
        drawings.Name.Visible = State.ESP
        drawings.Name.Position = Vector2.new(position.X, boxPos.Y - 18); drawings.Name.Text = player.Name
        
        -- 血量
        if State.ESPHealth then
            local h = targetHum.Health; local mh = targetHum.MaxHealth; local hp = math.clamp(h / mh, 0, 1)
            drawings.HealthBg.Visible = true; drawings.HealthBg.Size = Vector2.new(3, boxSize.Y); drawings.HealthBg.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
            drawings.HealthBar.Visible = true; drawings.HealthBar.Size = Vector2.new(3, boxSize.Y * hp); drawings.HealthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + boxSize.Y * (1 - hp))
            if hp > 0.6 then drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
            elseif hp > 0.3 then drawings.HealthBar.Color = Color3.fromRGB(255, 255, 0)
            else drawings.HealthBar.Color = Color3.fromRGB(255, 0, 0) end
        else drawings.HealthBg.Visible = false; drawings.HealthBar.Visible = false end
        
        -- 距离
        if State.ESPDistance then
            drawings.Distance.Visible = true; drawings.Distance.Position = Vector2.new(position.X, boxPos.Y + boxSize.Y + 4); drawings.Distance.Text = math.floor(dist) .. "m"
        else drawings.Distance.Visible = false end
        
        -- 射线
        if State.ESPTracers then
            drawings.Tracer.Visible = true; drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(position.X, boxPos.Y + boxSize.Y); drawings.Tracer.Color = Color3.fromRGB(255, 255, 255)
        else drawings.Tracer.Visible = false end
    end
end

RunService.RenderStepped:Connect(function()
    if State.ESP then UpdateESP()
    else for _, drawings in pairs(ESPDrawings) do for _, d in pairs(drawings) do d.Visible = false end end end
end)

local function ToggleESP()
    State.ESP = not State.ESP
    ESPToggle.BackgroundColor3 = State.ESP and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    ESPToggle.Text = State.ESP and "ESP: 开启" or "ESP: 关闭"
    
    if State.ESP then
        for _, pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then CreateESP(pl) end end
        local pa = Players.PlayerAdded:Connect(function(pl) if pl ~= LocalPlayer then task.wait(1); CreateESP(pl) end end)
        table.insert(Components.ESPConnections, pa)
        local pr = Players.PlayerRemoving:Connect(function(pl)
            if ESPDrawings[pl] then for _, d in pairs(ESPDrawings[pl]) do d:Remove() end; ESPDrawings[pl] = nil end
        end)
        table.insert(Components.ESPConnections, pr)
    else
        for _, drawings in pairs(ESPDrawings) do for _, d in pairs(drawings) do d:Remove() end end
        ESPDrawings = {}
        for _, conn in pairs(Components.ESPConnections) do conn:Disconnect() end; Components.ESPConnections = {}
    end
end

-- ESP单独按钮
local function ToggleESPBox()
    if not State.ESP then return end
    State.ESPBox = not State.ESPBox
    ESPBoxBtn.BackgroundColor3 = State.ESPBox and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    ESPBoxBtn.Text = State.ESPBox and "方框: 开" or "方框: 关"
end

local function ToggleESPHealth()
    if not State.ESP then return end
    State.ESPHealth = not State.ESPHealth
    ESPHealthBtn.BackgroundColor3 = State.ESPHealth and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    ESPHealthBtn.Text = State.ESPHealth and "血量: 开" or "血量: 关"
end

local function ToggleESPDist()
    if not State.ESP then return end
    State.ESPDistance = not State.ESPDistance
    ESPDistBtn.BackgroundColor3 = State.ESPDistance and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    ESPDistBtn.Text = State.ESPDistance and "距离: 开" or "距离: 关"
end

local function ToggleESPTrace()
    if not State.ESP then return end
    State.ESPTracers = not State.ESPTracers
    ESPTraceBtn.BackgroundColor3 = State.ESPTracers and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    ESPTraceBtn.Text = State.ESPTracers and "射线: 开" or "射线: 关"
end

-- ==================== 玩家列表 ====================
local playerListMode = "teleport"; local playerButtons = {}
local function RefreshPlayerList()
    for _, b in pairs(playerButtons) do b:Destroy() end; playerButtons = {}
    local pls = Players:GetPlayers(); local cnt = 0
    for _, pl in pairs(pls) do
        if pl ~= LocalPlayer then
            cnt += 1; local rw = math.floor((cnt-1)/2); local cl = (cnt-1)%2
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 88, 0, 26); btn.Position = UDim2.new(0, cl*92, 0, rw*30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); btn.BackgroundTransparency = 0.4
            btn.Text = pl.Name; btn.TextColor3 = Color3.fromRGB(200, 220, 255); btn.TextSize = 10
            btn.Font = Enum.Font.GothamMedium; btn.BorderSizePixel = 0; btn.Parent = PlayerList
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(50, 100, 255); st.Thickness = 1; st.Transparency = 0.5; st.Parent = btn
            btn.MouseButton1Click:Connect(function()
                if playerListMode == "teleport" then
                    if TeleportToPlayer(pl) then btn.BackgroundColor3 = Color3.fromRGB(30, 80, 40); task.wait(0.3); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60) end
                else
                    Components.SelectedCircleTarget = pl; CircleTargetLabel.Text = "绕圈目标: "..pl.Name
                    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 30); task.wait(0.3); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                end
            end)
            table.insert(playerButtons, btn)
        end
    end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, math.max(math.ceil(cnt/2)*30, 40))
end
ModeSwitchBtn.MouseButton1Click:Connect(function()
    if playerListMode == "teleport" then playerListMode = "circle"; PlayerModeLabel.Text = "模式: 绕圈"; ModeSwitchBtn.Text = "切换为传送模式"
    else playerListMode = "teleport"; PlayerModeLabel.Text = "模式: 传送"; ModeSwitchBtn.Text = "切换为绕圈模式" end
end)

-- ==================== 按钮绑定 ====================
FlyBtn.MouseButton1Click:Connect(function() if State.Flying then StopFlying() else StartFlying() end end)
SpinBtn.MouseButton1Click:Connect(function() if State.Spinning then StopSpinning() else StartSpinning() end end)
CircleBtn.MouseButton1Click:Connect(function() if State.Circling then StopCircling() elseif Components.SelectedCircleTarget then StartCircling(Components.SelectedCircleTarget); CircleTargetLabel.Text = "绕圈目标: "..Components.SelectedCircleTarget.Name end end)
JumpBtn.MouseButton1Click:Connect(ToggleInfJump)
NoClipBtn.MouseButton1Click:Connect(ToggleNoClip)
SpeedBtn.MouseButton1Click:Connect(CycleSpeed)
StopBtn.MouseButton1Click:Connect(StopAll)

ESPToggle.MouseButton1Click:Connect(ToggleESP)
ESPBoxBtn.MouseButton1Click:Connect(ToggleESPBox)
ESPHealthBtn.MouseButton1Click:Connect(ToggleESPHealth)
ESPDistBtn.MouseButton1Click:Connect(ToggleESPDist)
ESPTraceBtn.MouseButton1Click:Connect(ToggleESPTrace)

AimbotToggle.MouseButton1Click:Connect(ToggleAimbot)
AimbotVisBtn.MouseButton1Click:Connect(function() State.AimbotVisible = not State.AimbotVisible; AimbotVisBtn.BackgroundColor3 = State.AimbotVisible and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60) end)
HitboxToggle.MouseButton1Click:Connect(ToggleHitbox)
HitboxUpBtn.MouseButton1Click:Connect(function() State.HitboxSize = math.min(State.HitboxSize+1, 20); HitboxSizeLabel.Text = "范围大小: "..State.HitboxSize; if State.Hitbox then ToggleHitbox(); ToggleHitbox() end end)
HitboxDownBtn.MouseButton1Click:Connect(function() State.HitboxSize = math.max(State.HitboxSize-1, 2); HitboxSizeLabel.Text = "范围大小: "..State.HitboxSize; if State.Hitbox then ToggleHitbox(); ToggleHitbox() end end)

-- ==================== 窗口拖动 ====================
local function MakeDraggable(frame, handle)
    local dragging, ds, sp = false
    handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; ds = i.Position; sp = frame.Position end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds; frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
MakeDraggable(MainWindow, TitleBar)
MakeDraggable(RestoreBtn, RestoreBtn)

CloseBtn.MouseButton1Click:Connect(function()
    StopAll(); State.ESP = false
    for _, drawings in pairs(ESPDrawings) do for _, d in pairs(drawings) do d:Remove() end end
    ESPDrawings = {}; ScreenGui:Destroy()
end)

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

print("秋雨脚本 v3.0 ESP修复版 加载完成!")
