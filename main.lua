-- ============================================
-- 秋雨脚本 v3.0 - 3D粒子预加载画面
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local char, root, hum

-- ==================== 3D粒子预加载画面 ====================
local SplashScreen = Instance.new("ScreenGui")
SplashScreen.Name = "SplashScreen"
SplashScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")
SplashScreen.ResetOnSpawn = false
SplashScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SplashScreen.DisplayOrder = 999

-- 背景
local SplashBg = Instance.new("Frame")
SplashBg.Size = UDim2.new(1, 0, 1, 0)
SplashBg.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
SplashBg.BorderSizePixel = 0
SplashBg.Parent = SplashScreen

-- 粒子容器 - ViewportFrame实现3D
local ParticleViewport = Instance.new("ViewportFrame")
ParticleViewport.Size = UDim2.new(1, 0, 1, 0)
ParticleViewport.BackgroundTransparency = 1
ParticleViewport.BorderSizePixel = 0
ParticleViewport.CurrentCamera = Camera
ParticleViewport.Parent = SplashScreen

-- 3D粒子世界
local particleWorld = Instance.new("Model")
particleWorld.Name = "ParticleWorld"
particleWorld.Parent = ParticleViewport

-- 光源
local light1 = Instance.new("PointLight")
light1.Brightness = 5
light1.Range = 30
light1.Color = Color3.fromRGB(100, 150, 255)
light1.Parent = particleWorld

local light2 = Instance.new("PointLight")
light2.Brightness = 3
light2.Range = 25
light2.Color = Color3.fromRGB(200, 100, 255)
light2.Position = Vector3.new(10, 5, -5)
light2.Parent = particleWorld

-- 创建3D粒子球体
local particles = {}
local particleCount = 80

for i = 1, particleCount do
    local particle = Instance.new("Part")
    particle.Size = Vector3.new(0.4, 0.4, 0.4)
    particle.Shape = Enum.PartType.Ball
    particle.Material = Enum.Material.Neon
    particle.Anchored = true
    particle.CanCollide = false
    particle.BrickColor = BrickColor.new("Bright blue")
    particle.Parent = particleWorld
    
    -- 随机初始位置（散布在画面中）
    local angle = math.random() * math.pi * 2
    local phi = math.random() * math.pi
    local radius = 15 + math.random() * 10
    particle.Position = Vector3.new(
        radius * math.sin(phi) * math.cos(angle),
        radius * math.sin(phi) * math.sin(angle) - 5,
        radius * math.cos(phi) + 10
    )
    
    -- 粒子发光
    local glow = Instance.new("PointLight")
    glow.Brightness = 0.8
    glow.Range = 3 + math.random() * 3
    glow.Color = Color3.fromRGB(
        80 + math.random() * 100,
        100 + math.random() * 100,
        200 + math.random() * 55
    )
    glow.Parent = particle
    
    -- 粒子拖尾
    local trail = Instance.new("Trail")
    trail.Attachment0 = Instance.new("Attachment", particle)
    trail.Attachment1 = Instance.new("Attachment", particle)
    trail.Lifetime = 0.5
    trail.MinLength = 0.1
    trail.MaxLength = 2
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 255)),
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Parent = particle
    
    table.insert(particles, {
        part = particle,
        baseY = particle.Position.Y,
        speed = 0.3 + math.random() * 1.5,
        amplitude = 3 + math.random() * 5,
        offset = math.random() * math.pi * 2,
        rotationSpeed = math.random() * 3,
        colorShift = math.random(),
    })
end

-- 中心发光球体
local centerSphere = Instance.new("Part")
centerSphere.Size = Vector3.new(3, 3, 3)
centerSphere.Shape = Enum.PartType.Ball
centerSphere.Material = Enum.Material.Neon
centerSphere.Anchored = true
centerSphere.CanCollide = false
centerSphere.Position = Vector3.new(0, 5, 15)
centerSphere.BrickColor = BrickColor.new("White")
centerSphere.Parent = particleWorld

local centerGlow = Instance.new("PointLight")
centerGlow.Brightness = 10
centerGlow.Range = 20
centerGlow.Color = Color3.fromRGB(150, 200, 255)
centerGlow.Parent = centerSphere

-- 中心光环
for i = 1, 3 do
    local ring = Instance.new("Part")
    ring.Size = Vector3.new(0.3, 0.3, 0.3)
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Anchored = true
    ring.CanCollide = false
    ring.Position = centerSphere.Position
    ring.Orientation = Vector3.new(90, 0, 0)
    ring.BrickColor = BrickColor.new("Baby blue")
    ring.Transparency = 0.5
    ring.Parent = particleWorld
    table.insert(particles, {
        part = ring,
        baseY = ring.Position.Y,
        speed = 0,
        amplitude = 0,
        offset = i * math.pi * 2 / 3,
        rotationSpeed = 2,
        isRing = true,
        ringRadius = 4 + i * 2,
    })
end

-- 文字标题
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 60)
titleLabel.Position = UDim2.new(0, 0, 0.35, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "秋雨脚本"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 48
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextStrokeTransparency = 0
titleLabel.TextStrokeColor3 = Color3.fromRGB(50, 100, 255)
titleLabel.Parent = SplashScreen

-- 副标题
local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, 0, 0, 30)
subTitle.Position = UDim2.new(0, 0, 0.45, 0)
subTitle.BackgroundTransparency = 1
subTitle.Text = "v3.0 · 粒子进化"
subTitle.TextColor3 = Color3.fromRGB(150, 180, 255)
subTitle.TextSize = 18
subTitle.Font = Enum.Font.GothamMedium
subTitle.Parent = SplashScreen

-- 加载条背景
local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 250, 0, 6)
loadBarBg.Position = UDim2.new(0.5, -125, 0.55, 0)
loadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = SplashScreen
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)

-- 加载条
local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
loadBar.BorderSizePixel = 0
loadBar.Parent = loadBarBg
Instance.new("UICorner", loadBar).CornerRadius = UDim.new(1, 0)

-- 加载条发光
local loadGlow = Instance.new("UIStroke")
loadGlow.Color = Color3.fromRGB(150, 180, 255)
loadGlow.Thickness = 2
loadGlow.Transparency = 0.3
loadGlow.Parent = loadBar

-- 加载文字
local loadText = Instance.new("TextLabel")
loadText.Size = UDim2.new(1, 0, 0, 20)
loadText.Position = UDim2.new(0, 0, 0.58, 0)
loadText.BackgroundTransparency = 1
loadText.Text = "加载中... 0%"
loadText.TextColor3 = Color3.fromRGB(150, 180, 255)
loadText.TextSize = 13
loadText.Font = Enum.Font.GothamMedium
loadText.Parent = SplashScreen

-- 粒子动画循环
local totalTime = 0
local loadProgress = 0

local particleConnection = RunService.RenderStepped:Connect(function(dt)
    totalTime = totalTime + dt
    
    -- 更新加载进度
    loadProgress = math.min(loadProgress + dt * 0.5, 1)
    loadBar.Size = UDim2.new(loadProgress, 0, 1, 0)
    loadText.Text = "加载中... " .. math.floor(loadProgress * 100) .. "%"
    
    -- 更新所有粒子
    for _, data in pairs(particles) do
        local part = data.part
        if part and part.Parent then
            if data.isRing then
                -- 光环旋转
                local angle = totalTime * data.rotationSpeed + data.offset
                local x = math.cos(angle) * data.ringRadius
                local z = math.sin(angle) * data.ringRadius
                part.Position = Vector3.new(
                    centerSphere.Position.X + x,
                    centerSphere.Position.Y,
                    centerSphere.Position.Z + z
                )
                part.Orientation = Vector3.new(0, 0, math.deg(angle))
                part.Size = Vector3.new(0.3, 0.3, data.ringRadius * 2)
            else
                -- 粒子上下浮动 + 旋转
                local newY = data.baseY + math.sin(totalTime * data.speed + data.offset) * data.amplitude
                part.Position = Vector3.new(
                    part.Position.X + math.cos(totalTime * 0.5 + data.offset) * 0.02,
                    newY,
                    part.Position.Z + math.sin(totalTime * 0.3 + data.offset) * 0.02
                )
                
                -- 颜色变化
                local hue = (math.sin(totalTime * 0.8 + data.colorShift) + 1) / 2
                part.Color = Color3.fromRGB(
                    80 + hue * 100,
                    100 + hue * 100,
                    200 + hue * 55
                )
            end
        end
    end
    
    -- 中心球体脉动
    local pulse = 1 + math.sin(totalTime * 2) * 0.3
    centerSphere.Size = Vector3.new(3 * pulse, 3 * pulse, 3 * pulse)
    centerGlow.Brightness = 8 + math.sin(totalTime * 3) * 3
    
    -- 标题呼吸效果
    local breathe = 1 + math.sin(totalTime * 1.5) * 0.1
    titleLabel.TextTransparency = 1 - breathe
end)

-- 渐变遮罩（顶部和底部）
local topGradient = Instance.new("Frame")
topGradient.Size = UDim2.new(1, 0, 0, 150)
topGradient.Position = UDim2.new(0, 0, 0, 0)
topGradient.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
topGradient.BackgroundTransparency = 1
topGradient.BorderSizePixel = 0
topGradient.Parent = SplashScreen

local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20)),
})
topGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 1),
})
topGrad.Parent = topGradient

local bottomGradient = Instance.new("Frame")
bottomGradient.Size = UDim2.new(1, 0, 0, 150)
bottomGradient.Position = UDim2.new(0, 0, 1, -150)
bottomGradient.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
bottomGradient.BackgroundTransparency = 1
bottomGradient.BorderSizePixel = 0
bottomGradient.Parent = SplashScreen

local bottomGrad = Instance.new("UIGradient")
bottomGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20)),
})
bottomGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(1, 0),
})
bottomGrad.Parent = bottomGradient

-- 完成加载后淡出
task.wait(2) -- 预加载显示2秒
loadProgress = 1
loadBar.Size = UDim2.new(1, 0, 1, 0)
loadText.Text = "加载完成! 100%"

task.wait(0.5)

-- 淡出动画
local fadeOut = 0
local fadeConnection = RunService.RenderStepped:Connect(function(dt)
    fadeOut = fadeOut + dt * 2
    SplashBg.BackgroundTransparency = fadeOut
    titleLabel.TextTransparency = fadeOut
    subTitle.TextTransparency = fadeOut
    loadBarBg.BackgroundTransparency = fadeOut
    loadBar.BackgroundTransparency = fadeOut
    loadText.TextTransparency = fadeOut
    topGradient.BackgroundTransparency = fadeOut
    bottomGradient.BackgroundTransparency = fadeOut
    
    if fadeOut >= 1 then
        fadeConnection:Disconnect()
    end
end)

task.wait(0.5)
particleConnection:Disconnect()
SplashScreen:Destroy()

-- ==================== 主脚本开始 ====================
print("秋雨脚本 v3.0 启动中...")

-- ... (下面是原有的完整脚本代码，从状态管理开始)

-- ==================== 状态管理 ====================
local State = {
    Flying = false,
    Spinning = false,
    Circling = false,
    NoClip = false,
    InfJump = false,
    Speed = 1,
    ESP = false,
    ESPBox = false,
    ESPHealth = false,
    ESPDistance = false,
    ESPTracers = false,
    Aimbot = false,
    AimbotVisible = false,
    Hitbox = false,
    HitboxSize = 5,
    Minimized = false,
}

local Components = {
    FlyBodyVelocity = nil,
    FlyConnection = nil,
    FlyKeyBegan = nil,
    FlyKeyEnded = nil,
    SpinAngularVelocity = nil,
    CircleConnection = nil,
    CircleTarget = nil,
    CircleAngle = 0,
    CircleSpeed = 2,
    JumpConnection = nil,
    JumpHeartbeat = nil,
    NoClipConnection = nil,
    SelectedCircleTarget = nil,
    ESPConnections = {},
    AimbotConnection = nil,
    HitboxConnection = nil,
    HitboxParts = {},
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

-- 主窗口
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 200, 0, 340)
MainWindow.Position = UDim2.new(0.5, -100, 0.5, -170)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainWindow.BackgroundTransparency = 0.25
MainWindow.BorderSizePixel = 0
MainWindow.Visible = true
MainWindow.Parent = ScreenGui

Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 100, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = MainWindow

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BackgroundTransparency = 0.9
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "秋雨脚本"
TitleLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -50, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.7
MinBtn.Text = "━"
MinBtn.TextColor3 = Color3.fromRGB(80, 150, 255)
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- 标签页按钮
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 24)
TabContainer.Position = UDim2.new(0, 0, 0, 28)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainWindow

local ESPTab = Instance.new("TextButton")
ESPTab.Size = UDim2.new(0, 48, 0, 22)
ESPTab.Position = UDim2.new(0, 2, 0, 1)
ESPTab.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
ESPTab.BackgroundTransparency = 0.4
ESPTab.Text = "ESP"
ESPTab.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPTab.TextSize = 10
ESPTab.Font = Enum.Font.GothamBold
ESPTab.BorderSizePixel = 0
ESPTab.Parent = TabContainer
Instance.new("UICorner", ESPTab).CornerRadius = UDim.new(0, 6)

local FuncTab = Instance.new("TextButton")
FuncTab.Size = UDim2.new(0, 48, 0, 22)
FuncTab.Position = UDim2.new(0, 52, 0, 1)
FuncTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
FuncTab.BackgroundTransparency = 0.4
FuncTab.Text = "功能"
FuncTab.TextColor3 = Color3.fromRGB(200, 200, 220)
FuncTab.TextSize = 10
FuncTab.Font = Enum.Font.GothamBold
FuncTab.BorderSizePixel = 0
FuncTab.Parent = TabContainer
Instance.new("UICorner", FuncTab).CornerRadius = UDim.new(0, 6)

local CombatTab = Instance.new("TextButton")
CombatTab.Size = UDim2.new(0, 48, 0, 22)
CombatTab.Position = UDim2.new(0, 102, 0, 1)
CombatTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
CombatTab.BackgroundTransparency = 0.4
CombatTab.Text = "战斗"
CombatTab.TextColor3 = Color3.fromRGB(200, 200, 220)
CombatTab.TextSize = 10
CombatTab.Font = Enum.Font.GothamBold
CombatTab.BorderSizePixel = 0
CombatTab.Parent = TabContainer
Instance.new("UICorner", CombatTab).CornerRadius = UDim.new(0, 6)

local PlayerTab = Instance.new("TextButton")
PlayerTab.Size = UDim2.new(0, 48, 0, 22)
PlayerTab.Position = UDim2.new(0, 152, 0, 1)
PlayerTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
PlayerTab.BackgroundTransparency = 0.4
PlayerTab.Text = "玩家"
PlayerTab.TextColor3 = Color3.fromRGB(200, 200, 220)
PlayerTab.TextSize = 10
PlayerTab.Font = Enum.Font.GothamBold
PlayerTab.BorderSizePixel = 0
PlayerTab.Parent = TabContainer
Instance.new("UICorner", PlayerTab).CornerRadius = UDim.new(0, 6)

-- 内容区域
local ESPContent = Instance.new("Frame")
ESPContent.Size = UDim2.new(1, -12, 1, -58)
ESPContent.Position = UDim2.new(0, 6, 0, 54)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = true
ESPContent.Parent = MainWindow

local FuncContent = Instance.new("Frame")
FuncContent.Size = UDim2.new(1, -12, 1, -58)
FuncContent.Position = UDim2.new(0, 6, 0, 54)
FuncContent.BackgroundTransparency = 1
FuncContent.Visible = false
FuncContent.Parent = MainWindow

local CombatContent = Instance.new("Frame")
CombatContent.Size = UDim2.new(1, -12, 1, -58)
CombatContent.Position = UDim2.new(0, 6, 0, 54)
CombatContent.BackgroundTransparency = 1
CombatContent.Visible = false
CombatContent.Parent = MainWindow

local PlayerContent = Instance.new("Frame")
PlayerContent.Size = UDim2.new(1, -12, 1, -58)
PlayerContent.Position = UDim2.new(0, 6, 0, 54)
PlayerContent.BackgroundTransparency = 1
PlayerContent.Visible = false
PlayerContent.Parent = MainWindow

-- 按钮创建函数
local function CreateButton(parent, x, y, w, h, text, active)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w, 0, h)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = active and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    btn.BackgroundTransparency = 0.4
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 220, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 100, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    return btn
end

-- ==================== ESP标签页 ====================
local ESPToggle = CreateButton(ESPContent, 0, 2, 186, 28, "ESP总开关", false)
local ESPBoxBtn = CreateButton(ESPContent, 0, 34, 90, 28, "方框", false)
local ESPHealthBtn = CreateButton(ESPContent, 96, 34, 90, 28, "血量", false)
local ESPDistBtn = CreateButton(ESPContent, 0, 66, 90, 28, "距离", false)
local ESPTraceBtn = CreateButton(ESPContent, 96, 66, 90, 28, "射线", false)

-- ==================== 功能标签页 ====================
local FlyBtn = CreateButton(FuncContent, 0, 2, 90, 28, "飞行", false)
local SpinBtn = CreateButton(FuncContent, 96, 2, 90, 28, "自转", false)
local CircleBtn = CreateButton(FuncContent, 0, 34, 90, 28, "绕圈", false)
local JumpBtn = CreateButton(FuncContent, 96, 34, 90, 28, "无限跳", false)
local NoClipBtn = CreateButton(FuncContent, 0, 66, 90, 28, "穿墙", false)
local SpeedBtn = CreateButton(FuncContent, 96, 66, 90, 28, "加速1x", false)
local StopBtn = CreateButton(FuncContent, 0, 98, 186, 26, "停止全部", false)
StopBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)

local CircleTargetLabel = Instance.new("TextLabel")
CircleTargetLabel.Size = UDim2.new(1, 0, 0, 16)
CircleTargetLabel.Position = UDim2.new(0, 0, 0, 132)
CircleTargetLabel.BackgroundTransparency = 1
CircleTargetLabel.Text = "绕圈目标: 无"
CircleTargetLabel.TextColor3 = Color3.fromRGB(150, 180, 220)
CircleTargetLabel.TextSize = 10
CircleTargetLabel.Font = Enum.Font.GothamMedium
CircleTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
CircleTargetLabel.Parent = FuncContent

-- ==================== 战斗标签页 ====================
local AimbotToggle = CreateButton(CombatContent, 0, 2, 90, 28, "自瞄", false)
local AimbotVisBtn = CreateButton(CombatContent, 96, 2, 90, 28, "可视检查", false)
local HitboxToggle = CreateButton(CombatContent, 0, 34, 90, 28, "范围伤害", false)
local HitboxUpBtn = CreateButton(CombatContent, 96, 34, 44, 28, "+", false)
local HitboxDownBtn = CreateButton(CombatContent, 142, 34, 44, 28, "-", false)

local HitboxSizeLabel = Instance.new("TextLabel")
HitboxSizeLabel.Size = UDim2.new(1, 0, 0, 18)
HitboxSizeLabel.Position = UDim2.new(0, 0, 0, 68)
HitboxSizeLabel.BackgroundTransparency = 1
HitboxSizeLabel.Text = "范围大小: 5"
HitboxSizeLabel.TextColor3 = Color3.fromRGB(150, 180, 220)
HitboxSizeLabel.TextSize = 11
HitboxSizeLabel.Font = Enum.Font.GothamBold
HitboxSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
HitboxSizeLabel.Parent = CombatContent

-- ==================== 玩家标签页 ====================
local PlayerModeLabel = Instance.new("TextLabel")
PlayerModeLabel.Size = UDim2.new(1, 0, 0, 18)
PlayerModeLabel.Position = UDim2.new(0, 0, 0, 2)
PlayerModeLabel.BackgroundTransparency = 1
PlayerModeLabel.Text = "当前模式: 传送"
PlayerModeLabel.TextColor3 = Color3.fromRGB(150, 180, 220)
PlayerModeLabel.TextSize = 11
PlayerModeLabel.Font = Enum.Font.GothamBold
PlayerModeLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerModeLabel.Parent = PlayerContent

local ModeSwitchBtn = CreateButton(PlayerContent, 0, 24, 186, 24, "切换为绕圈模式", false)

local PlayerListLabel = Instance.new("TextLabel")
PlayerListLabel.Size = UDim2.new(1, 0, 0, 16)
PlayerListLabel.Position = UDim2.new(0, 0, 0, 54)
PlayerListLabel.BackgroundTransparency = 1
PlayerListLabel.Text = "玩家列表"
PlayerListLabel.TextColor3 = Color3.fromRGB(150, 180, 220)
PlayerListLabel.TextSize = 10
PlayerListLabel.Font = Enum.Font.GothamMedium
PlayerListLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerListLabel.Parent = PlayerContent

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, 0, 0, 190)
PlayerList.Position = UDim2.new(0, 0, 0, 72)
PlayerList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerList.BackgroundTransparency = 0.85
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 3
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(50, 100, 255)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 200)
PlayerList.Parent = PlayerContent
Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 8)

-- ==================== 最小化恢复按钮 ====================
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 44, 0, 44)
RestoreBtn.Position = UDim2.new(0.02, 0, 0.5, -22)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
RestoreBtn.BackgroundTransparency = 0.3
RestoreBtn.Text = "秋雨"
RestoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RestoreBtn.TextSize = 11
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.BorderSizePixel = 0
RestoreBtn.Visible = false
RestoreBtn.Parent = ScreenGui

Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)

local RestoreStroke = Instance.new("UIStroke")
RestoreStroke.Color = Color3.fromRGB(100, 150, 255)
RestoreStroke.Thickness = 2
RestoreStroke.Transparency = 0.3
RestoreStroke.Parent = RestoreBtn

-- ==================== 标签页切换 ====================
local function SwitchTab(tab)
    ESPContent.Visible = (tab == "ESP")
    FuncContent.Visible = (tab == "Func")
    CombatContent.Visible = (tab == "Combat")
    PlayerContent.Visible = (tab == "Player")
    
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

-- ==================== 最小化 ====================
MinBtn.MouseButton1Click:Connect(function()
    State.Minimized = true
    MainWindow.Visible = false
    RestoreBtn.Visible = true
end)

RestoreBtn.MouseButton1Click:Connect(function()
    State.Minimized = false
    MainWindow.Visible = true
    RestoreBtn.Visible = false
end)

-- ==================== 飞行系统 ====================
local function StartFlying()
    if State.Flying then return end
    State.Flying = true
    FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1, 1, 1) * 50000
    bv.Velocity = Vector3.zero
    bv.Parent = root
    Components.FlyBodyVelocity = bv
    
    local moveDirection = Vector3.zero
    local upDown = 0
    local speed = 50
    
    Components.FlyConnection = RunService.Heartbeat:Connect(function()
        if not State.Flying or not Components.FlyBodyVelocity then return end
        local cam = Camera
        if not cam then return end
        
        local forward = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
        local right = cam.CFrame.RightVector * Vector3.new(1, 0, 1)
        
        local move = (forward * -moveDirection.Z) + (right * moveDirection.X)
        move = move + Vector3.new(0, upDown, 0)
        
        Components.FlyBodyVelocity.Velocity = move.Magnitude > 0.1 and move.Unit * speed or Vector3.zero
    end)
    
    Components.FlyKeyBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.W then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then upDown = 1 end
        if input.KeyCode == Enum.KeyCode.LeftControl then upDown = -1 end
    end)
    
    Components.FlyKeyEnded = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then moveDirection = moveDirection - Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveDirection = moveDirection - Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveDirection = moveDirection - Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveDirection = moveDirection - Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then upDown = 0 end
        if input.KeyCode == Enum.KeyCode.LeftControl then upDown = 0 end
    end)
end

local function StopFlying()
    State.Flying = false
    FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    
    if Components.FlyBodyVelocity then Components.FlyBodyVelocity:Destroy(); Components.FlyBodyVelocity = nil end
    if Components.FlyConnection then Components.FlyConnection:Disconnect(); Components.FlyConnection = nil end
    if Components.FlyKeyBegan then Components.FlyKeyBegan:Disconnect(); Components.FlyKeyBegan = nil end
    if Components.FlyKeyEnded then Components.FlyKeyEnded:Disconnect(); Components.FlyKeyEnded = nil end
end

-- ==================== 自转系统 ====================
local function StartSpinning()
    if State.Spinning then return end
    State.Spinning = true
    SpinBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    
    hum.AutoRotate = false
    
    if root:FindFirstChild("SpinRotator") then
        root.SpinRotator:Destroy()
    end
    
    local angularVelocity = Instance.new("BodyAngularVelocity")
    angularVelocity.Name = "SpinRotator"
    angularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    angularVelocity.AngularVelocity = Vector3.new(0, 70, 0)
    angularVelocity.Parent = root
    Components.SpinAngularVelocity = angularVelocity
end

local function StopSpinning()
    State.Spinning = false
    SpinBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    
    if Components.SpinAngularVelocity then
        Components.SpinAngularVelocity:Destroy()
        Components.SpinAngularVelocity = nil
    end
    hum.AutoRotate = true
end

-- ==================== 绕圈系统 ====================
local function StartCircling(target)
    if State.Circling then StopCircling() end
    if not target then return end
    
    local targetChar = target.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    if not root then return end
    
    State.Circling = true
    Components.CircleTarget = target
    Components.CircleAngle = math.random() * math.pi * 2
    CircleBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    
    local radius = 8
    local heightOffset = 3
    local smoothness = 0.5
    
    Components.CircleConnection = RunService.Heartbeat:Connect(function()
        if not State.Circling then return end
        if not Components.CircleTarget then StopCircling(); return end
        
        local tChar = Components.CircleTarget.Character
        if not tChar then StopCircling(); return end
        
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if not tRoot then StopCircling(); return end
        
        if not root or not root.Parent then StopCircling(); return end
        
        Components.CircleAngle = Components.CircleAngle + (Components.CircleSpeed * 0.05)
        
        local targetPos = tRoot.Position
        local targetX = targetPos.X + radius * math.cos(Components.CircleAngle)
        local targetZ = targetPos.Z + radius * math.sin(Components.CircleAngle)
        local targetY = targetPos.Y + heightOffset
        
        local currentPos = root.Position
        local desiredPos = Vector3.new(targetX, targetY, targetZ)
        local newPos = currentPos:Lerp(desiredPos, smoothness)
        
        root.CFrame = CFrame.new(newPos)
    end)
end

local function StopCircling()
    State.Circling = false
    Components.CircleTarget = nil
    CircleBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    CircleTargetLabel.Text = "绕圈目标: 无"
    
    if Components.CircleConnection then
        Components.CircleConnection:Disconnect()
        Components.CircleConnection = nil
    end
end

-- ==================== 无限跳跃 ====================
local function ToggleInfJump()
    State.InfJump = not State.InfJump
    JumpBtn.BackgroundColor3 = State.InfJump and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    
    if State.InfJump then
        Components.JumpHeartbeat = RunService.Heartbeat:Connect(function()
            if not State.InfJump then return end
            if not hum or not hum.Parent then return end
            
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                hum.Jump = true
            end
        end)
    else
        if Components.JumpHeartbeat then
            Components.JumpHeartbeat:Disconnect()
            Components.JumpHeartbeat = nil
        end
        if Components.JumpConnection then
            Components.JumpConnection:Disconnect()
            Components.JumpConnection = nil
        end
    end
end

-- ==================== 穿墙 ====================
local function ToggleNoClip()
    State.NoClip = not State.NoClip
    NoClipBtn.BackgroundColor3 = State.NoClip and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    
    if State.NoClip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        Components.NoClipConnection = char.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") and State.NoClip then part.CanCollide = false end
        end)
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        if Components.NoClipConnection then
            Components.NoClipConnection:Disconnect()
            Components.NoClipConnection = nil
        end
    end
end

-- ==================== 加速 ====================
local function CycleSpeed()
    local speeds = {1, 2, 4, 8, 16}
    local currentIndex = 1
    for i, v in ipairs(speeds) do
        if v == State.Speed then currentIndex = i; break end
    end
    currentIndex = currentIndex % #speeds + 1
    State.Speed = speeds[currentIndex]
    hum.WalkSpeed = 16 * State.Speed
    SpeedBtn.Text = "加速" .. State.Speed .. "x"
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
    if State.Speed ~= 1 then
        State.Speed = 1
        hum.WalkSpeed = 16
        SpeedBtn.Text = "加速1x"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    end
end

-- ==================== 传送功能 ====================
local function TeleportToPlayer(targetPlayer)
    if not targetPlayer or not root then return false end
    local targetChar = targetPlayer.Character
    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
        root.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

-- ==================== 自瞄系统 ====================
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local targetChar = player.Character
        if not targetChar then continue end
        
        local head = targetChar:FindFirstChild("Head")
        if not head then continue end
        
        if State.AimbotVisible then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if not onScreen then continue end
            
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {char}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500, rayParams)
            if ray then
                local hitChar = ray.Instance:FindFirstAncestorOfClass("Model")
                if hitChar ~= player.Character then continue end
            end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            
            if dist < shortestDist then
                shortestDist = dist
                closest = player
            end
        end
    end
    
    return closest
end

local function ToggleAimbot()
    State.Aimbot = not State.Aimbot
    AimbotToggle.BackgroundColor3 = State.Aimbot and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    
    if State.Aimbot then
        Components.AimbotConnection = RunService.Heartbeat:Connect(function()
            if not State.Aimbot then return end
            
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
            end
        end)
    else
        if Components.AimbotConnection then
            Components.AimbotConnection:Disconnect()
            Components.AimbotConnection = nil
        end
    end
end

-- ==================== 范围伤害系统 ====================
local function ExpandHitbox(character)
    local parts = {}
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local oldSize = part.Size
            local oldTransparency = part.Transparency
            
            part.Size = oldSize * State.HitboxSize
            part.Transparency = 0.7
            part.CanCollide = true
            
            table.insert(parts, {part = part, oldSize = oldSize, oldTransparency = oldTransparency})
        end
    end
    return parts
end

local function RestoreHitbox(parts)
    for _, data in pairs(parts) do
        if data.part and data.part.Parent then
            data.part.Size = data.oldSize
            data.part.Transparency = data.oldTransparency
        end
    end
end

local function ToggleHitbox()
    State.Hitbox = not State.Hitbox
    HitboxToggle.BackgroundColor3 = State.Hitbox and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    
    if State.Hitbox then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                Components.HitboxParts[player] = ExpandHitbox(player.Character)
            end
        end
        
        Components.HitboxConnection = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                task.wait(0.5)
                if State.Hitbox then
                    Components.HitboxParts[player] = ExpandHitbox(character)
                end
            end)
        end)
        
        local playerRemoving = Players.PlayerRemoving:Connect(function(player)
            if Components.HitboxParts[player] then
                RestoreHitbox(Components.HitboxParts[player])
                Components.HitboxParts[player] = nil
            end
        end)
        table.insert(Components.ESPConnections, playerRemoving)
    else
        for player, parts in pairs(Components.HitboxParts) do
            RestoreHitbox(parts)
        end
        Components.HitboxParts = {}
        
        if Components.HitboxConnection then
            Components.HitboxConnection:Disconnect()
            Components.HitboxConnection = nil
        end
    end
end

-- ==================== ESP系统 ====================
local ESPDrawings = {}

local function CreateESP(player)
    local drawings = {}
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 1.5
    box.Filled = false
    box.Transparency = 0.7
    drawings.Box = box
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Size = 13
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = 3
    drawings.Name = nameTag
    
    local healthBg = Drawing.new("Square")
    healthBg.Visible = false
    healthBg.Color = Color3.fromRGB(30, 30, 30)
    healthBg.Thickness = 1
    healthBg.Filled = true
    drawings.HealthBg = healthBg
    
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Filled = true
    drawings.HealthBar = healthBar
    
    local distance = Drawing.new("Text")
    distance.Visible = false
    distance.Color = Color3.fromRGB(255, 255, 255)
    distance.Size = 12
    distance.Center = true
    distance.Outline = true
    distance.Font = 3
    drawings.Distance = distance
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Thickness = 1
    tracer.Transparency = 0.5
    drawings.Tracer = tracer
    
    ESPDrawings[player] = drawings
    return drawings
end

local function UpdateESP()
    for player, drawings in pairs(ESPDrawings) do
        if not player or not player.Parent then
            for _, d in pairs(drawings) do d:Remove() end
            ESPDrawings[player] = nil
            continue
        end
        
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end
        
        if not root then continue end
        
        local targetRoot = character.HumanoidRootPart
        local targetHum = character.Humanoid
        local position, onScreen = Camera:WorldToViewportPoint(targetRoot.Position)
        
        if not onScreen then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end
        
        local dist = (root.Position - targetRoot.Position).Magnitude
        local scale = math.clamp(1 / (dist * 0.05), 0.5, 2)
        local boxSize = Vector2.new(40 * scale, 60 * scale)
        local boxPos = Vector2.new(position.X - boxSize.X/2, position.Y - boxSize.Y/2)
        
        if State.ESPBox then
            drawings.Box.Visible = true
            drawings.Box.Size = boxSize
            drawings.Box.Position = boxPos
            local teamColor = player.TeamColor and player.TeamColor.Color
            drawings.Box.Color = teamColor or Color3.fromRGB(255, 255, 255)
        else
            drawings.Box.Visible = false
        end
        
        drawings.Name.Visible = true
        drawings.Name.Position = Vector2.new(position.X, boxPos.Y - 18)
        drawings.Name.Text = player.Name
        
        if State.ESPHealth then
            local health = targetHum.Health
            local maxHealth = targetHum.MaxHealth
            local healthPercent = math.clamp(health / maxHealth, 0, 1)
            
            drawings.HealthBg.Visible = true
            drawings.HealthBg.Size = Vector2.new(3, boxSize.Y)
            drawings.HealthBg.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
            
            drawings.HealthBar.Visible = true
            drawings.HealthBar.Size = Vector2.new(3, boxSize.Y * healthPercent)
            drawings.HealthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + boxSize.Y * (1 - healthPercent))
            
            if healthPercent > 0.6 then
                drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.3 then
                drawings.HealthBar.Color = Color3.fromRGB(255, 255, 0)
            else
                drawings.HealthBar.Color = Color3.fromRGB(255, 0, 0)
            end
        else
            drawings.HealthBg.Visible = false
            drawings.HealthBar.Visible = false
        end
        
        if State.ESPDistance then
            drawings.Distance.Visible = true
            drawings.Distance.Position = Vector2.new(position.X, boxPos.Y + boxSize.Y + 4)
            drawings.Distance.Text = math.floor(dist) .. "m"
        else
            drawings.Distance.Visible = false
        end
        
        if State.ESPTracers then
            drawings.Tracer.Visible = true
            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(position.X, boxPos.Y + boxSize.Y)
            drawings.Tracer.Color = Color3.fromRGB(255, 255, 255)
        else
            drawings.Tracer.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    if State.ESP then
        UpdateESP()
    else
        for _, drawings in pairs(ESPDrawings) do
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end)

local function ToggleESP()
    State.ESP = not State.ESP
    ESPToggle.BackgroundColor3 = State.ESP and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    
    if State.ESP then
        State.ESPBox = true
        ESPBoxBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
        
        local playerAdded = Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                task.wait(1)
                CreateESP(player)
            end
        end)
        table.insert(Components.ESPConnections, playerAdded)
        
        local playerRemoving = Players.PlayerRemoving:Connect(function(player)
            if ESPDrawings[player] then
                for _, d in pairs(ESPDrawings[player]) do d:Remove() end
                ESPDrawings[player] = nil
            end
        end)
        table.insert(Components.ESPConnections, playerRemoving)
    else
        State.ESPBox = false
        State.ESPHealth = false
        State.ESPDistance = false
        State.ESPTracers = false
        ESPBoxBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
        ESPHealthBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
        ESPDistBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
        ESPTraceBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
        
        for _, drawings in pairs(ESPDrawings) do
            for _, d in pairs(drawings) do d:Remove() end
        end
        ESPDrawings = {}
        
        for _, conn in pairs(Components.ESPConnections) do
            conn:Disconnect()
        end
        Components.ESPConnections = {}
    end
end

-- ==================== 玩家列表 ====================
local playerListMode = "teleport"
local playerButtons = {}

local function RefreshPlayerList()
    for _, btn in pairs(playerButtons) do
        btn:Destroy()
    end
    playerButtons = {}
    
    local players = Players:GetPlayers()
    local count = 0
    
    for _, player in pairs(players) do
        if player ~= LocalPlayer then
            count = count + 1
            local row = math.floor((count - 1) / 2)
            local col = (count - 1) % 2
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 88, 0, 26)
            btn.Position = UDim2.new(0, col * 92, 0, row * 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.BackgroundTransparency = 0.4
            btn.Text = player.Name
            btn.TextColor3 = Color3.fromRGB(200, 220, 255)
            btn.TextSize = 10
            btn.Font = Enum.Font.GothamMedium
            btn.BorderSizePixel = 0
            btn.Parent = PlayerList
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(50, 100, 255)
            stroke.Thickness = 1
            stroke.Transparency = 0.5
            stroke.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                if playerListMode == "teleport" then
                    if TeleportToPlayer(player) then
                        btn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
                        task.wait(0.3)
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                    end
                else
                    Components.SelectedCircleTarget = player
                    CircleTargetLabel.Text = "绕圈目标: " .. player.Name
                    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 30)
                    task.wait(0.3)
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                end
            end)
            
            table.insert(playerButtons, btn)
        end
    end
    
    local totalHeight = math.ceil(count / 2) * 30
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, 40))
end

ModeSwitchBtn.MouseButton1Click:Connect(function()
    if playerListMode == "teleport" then
        playerListMode = "circle"
        PlayerModeLabel.Text = "当前模式: 绕圈"
        ModeSwitchBtn.Text = "切换为传送模式"
    else
        playerListMode = "teleport"
        PlayerModeLabel.Text = "当前模式: 传送"
        ModeSwitchBtn.Text = "切换为绕圈模式"
    end
end)

-- ==================== 按钮绑定 ====================
FlyBtn.MouseButton1Click:Connect(function()
    if State.Flying then StopFlying() else StartFlying() end
end)

SpinBtn.MouseButton1Click:Connect(function()
    if State.Spinning then StopSpinning() else StartSpinning() end
end)

CircleBtn.MouseButton1Click:Connect(function()
    if State.Circling then
        StopCircling()
    elseif Components.SelectedCircleTarget then
        StartCircling(Components.SelectedCircleTarget)
        CircleTargetLabel.Text = "绕圈目标: " .. Components.SelectedCircleTarget.Name
    end
end)

JumpBtn.MouseButton1Click:Connect(ToggleInfJump)
NoClipBtn.MouseButton1Click:Connect(ToggleNoClip)
SpeedBtn.MouseButton1Click:Connect(CycleSpeed)
StopBtn.MouseButton1Click:Connect(StopAll)

-- ESP按钮
ESPToggle.MouseButton1Click:Connect(ToggleESP)
ESPBoxBtn.MouseButton1Click:Connect(function()
    if not State.ESP then return end
    State.ESPBox = not State.ESPBox
    ESPBoxBtn.BackgroundColor3 = State.ESPBox and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
end)
ESPHealthBtn.MouseButton1Click:Connect(function()
    if not State.ESP then return end
    State.ESPHealth = not State.ESPHealth
    ESPHealthBtn.BackgroundColor3 = State.ESPHealth and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
end)
ESPDistBtn.MouseButton1Click:Connect(function()
    if not State.ESP then return end
    State.ESPDistance = not State.ESPDistance
    ESPDistBtn.BackgroundColor3 = State.ESPDistance and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
end)
ESPTraceBtn.MouseButton1Click:Connect(function()
    if not State.ESP then return end
    State.ESPTracers = not State.ESPTracers
    ESPTraceBtn.BackgroundColor3 = State.ESPTracers and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
end)

-- 战斗按钮
AimbotToggle.MouseButton1Click:Connect(ToggleAimbot)
AimbotVisBtn.MouseButton1Click:Connect(function()
    State.AimbotVisible = not State.AimbotVisible
    AimbotVisBtn.BackgroundColor3 = State.AimbotVisible and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
end)
HitboxToggle.MouseButton1Click:Connect(ToggleHitbox)
HitboxUpBtn.MouseButton1Click:Connect(function()
    State.HitboxSize = math.min(State.HitboxSize + 1, 20)
    HitboxSizeLabel.Text = "范围大小: " .. State.HitboxSize
    if State.Hitbox then
        ToggleHitbox()
        ToggleHitbox()
    end
end)
HitboxDownBtn.MouseButton1Click:Connect(function()
    State.HitboxSize = math.max(State.HitboxSize - 1, 2)
    HitboxSizeLabel.Text = "范围大小: " .. State.HitboxSize
    if State.Hitbox then
        ToggleHitbox()
        ToggleHitbox()
    end
end)

-- ==================== 窗口拖动 ====================
local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(MainWindow, TitleBar)
MakeDraggable(RestoreBtn, RestoreBtn)

-- ==================== 关闭 ====================
CloseBtn.MouseButton1Click:Connect(function()
    StopAll()
    State.ESP = false
    for _, drawings in pairs(ESPDrawings) do
        for _, d in pairs(drawings) do d:Remove() end
    end
    ESPDrawings = {}
    ScreenGui:Destroy()
end)

-- 初始刷新
RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

print("秋雨脚本 v3.0 加载完成 - 3D粒子预加载已展示")
