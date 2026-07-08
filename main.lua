-- ============================================
-- 秋雨脚本 iOS风格完整版
-- ============================================

-- ==================== Orion iOS UI库 ====================
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

local OrionLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        iOS = {
            Main = Color3.fromRGB(28, 28, 30),
            Second = Color3.fromRGB(44, 44, 46),
            Third = Color3.fromRGB(58, 58, 60),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(242, 242, 247),
            TextDark = Color3.fromRGB(174, 174, 178),
            ButtonText = Color3.fromRGB(10, 132, 255),
            ToggleOn = Color3.fromRGB(10, 132, 255),
            ToggleOff = Color3.fromRGB(116, 116, 128)
        }
    },
    SelectedTheme = "iOS",
    Folder = nil,
    SaveCfg = false
}

local Icons = {}
local Success, Response = pcall(function()
    Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)
if not Success then warn("iOS UI - Icon load failed") end

local function GetIcon(IconName)
    if Icons[IconName] ~= nil then return Icons[IconName] else return nil end
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "iOSUI"
if syn then syn.protect_gui(Orion); Orion.Parent = game.CoreGui
else Orion.Parent = gethui() or game.CoreGui end

if gethui then for _, v in ipairs(gethui():GetChildren()) do if v.Name == Orion.Name and v ~= Orion then v:Destroy() end end
else for _, v in ipairs(game.CoreGui:GetChildren()) do if v.Name == Orion.Name and v ~= Orion then v:Destroy() end end end

function OrionLib:IsRunning() return Orion.Parent == (gethui and gethui() or game.CoreGui) end

local function AddConnection(Signal, Function)
    if not OrionLib:IsRunning() then return end
    local c = Signal:Connect(Function); table.insert(OrionLib.Connections, c); return c
end

task.spawn(function() while OrionLib:IsRunning() do task.wait() end; for _, c in pairs(OrionLib.Connections) do c:Disconnect() end end)

local function MakeDraggable(DragPoint, Main)
    pcall(function()
        local dragging, dragInput, mousePos, framePos = false
        AddConnection(DragPoint.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; mousePos = Input.Position; framePos = Main.Position
                Input.Changed:Connect(function() if Input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        AddConnection(DragPoint.InputChanged, function(Input) if Input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = Input end end)
        AddConnection(UserInputService.InputChanged, function(Input)
            if Input == dragInput and dragging then
                local delta = Input.Position - mousePos
                Main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)
    end)
end

local function Create(Name, Properties, Children)
    local obj = Instance.new(Name)
    for i, v in pairs(Properties or {}) do obj[i] = v end
    for i, v in pairs(Children or {}) do v.Parent = obj end
    return obj
end

local function SetProps(Element, Props) for k, v in pairs(Props) do Element[k] = v end; return Element end
local function SetChildren(Element, Children) for _, c in pairs(Children) do c.Parent = Element end; return Element end
local function Round(Number, Factor) local r = math.floor(Number/Factor + 0.5) * Factor; return r < 0 and r + Factor or r end
local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3"
    elseif Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3"
    elseif Object:IsA("UIStroke") then return "Color"
    elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3"
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(Object, Type)
    if not OrionLib.ThemeObjects[Type] then OrionLib.ThemeObjects[Type] = {} end
    table.insert(OrionLib.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
    return Object
end

local function PackColor(c) return {R = c.R * 255, G = c.G * 255, B = c.B * 255} end
local function UnpackColor(c) return Color3.fromRGB(c.R, c.G, c.B) end

local NotificationHolder = SetProps(SetChildren(Create("Frame", {BackgroundTransparency = 1}, {Create("UIListLayout", {HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})}), {Position = UDim2.new(1, -25, 1, -25), Size = UDim2.new(0, 300, 1, -25), AnchorPoint = Vector2.new(1, 1), Parent = Orion})

function OrionLib:MakeNotification(Config)
    spawn(function()
        Config.Name = Config.Name or "通知"; Config.Content = Config.Content or ""; Config.Time = Config.Time or 5
        local parent = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = NotificationHolder})
        local frame = SetChildren(Create("Frame", {BackgroundColor3 = Color3.fromRGB(28,28,30), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(1, -55, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent}, {Create("UICorner", {CornerRadius = UDim.new(0, 10)}), Create("UIPadding", {PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 12)})}), {})
        local title = Create("TextLabel", {Text = Config.Name, TextColor3 = Color3.fromRGB(242,242,247), TextSize = 15, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = frame})
        local content = Create("TextLabel", {Text = Config.Content, TextColor3 = Color3.fromRGB(174,174,178), TextSize = 14, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, Parent = frame})
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(Config.Time - 0.88)
        TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        task.wait(0.3)
        TweenService:Create(title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        task.wait(0.05)
        TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 20, 0, 0)}):Play()
        task.wait(1.35)
        frame:Destroy()
    end)
end

function OrionLib:Init() end

function OrionLib:MakeWindow(Config)
    Config = Config or {}; Config.Name = Config.Name or "iOS UI"; Config.SaveConfig = Config.SaveConfig or false
    if Config.IntroEnabled == nil then Config.IntroEnabled = true end
    Config.IntroText = Config.IntroText or "iOS UI"; Config.CloseCallback = Config.CloseCallback or function() end
    OrionLib.Folder = Config.ConfigFolder or Config.Name; OrionLib.SaveCfg = Config.SaveConfig

    local FirstTab = true; local Minimized = false; local UIHidden = false

    local TabHolder = AddThemeObject(SetChildren(Create("ScrollingFrame", {BackgroundTransparency = 1, MidImage = "rbxassetid://7445543667", BottomImage = "rbxassetid://7445543667", TopImage = "rbxassetid://7445543667", ScrollBarImageColor3 = OrionLib.Themes.iOS.Text, BorderSizePixel = 0, ScrollBarThickness = 4, Size = UDim2.new(1, 0, 1, -50)}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}), Create("UIPadding", {PaddingBottom = UDim.new(0, 8), PaddingTop = UDim.new(0, 8)})}), "Divider")

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16) end)

    local CloseBtn = SetChildren(Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0, 15)}, {Create("ImageLabel", {Image = "rbxassetid://7072725342", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ImageColor3 = OrionLib.Themes.iOS.Text})}), {})

    local MinimizeBtn = SetChildren(Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -60, 0, 15)}, {Create("ImageLabel", {Image = "rbxassetid://7072719338", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ImageColor3 = OrionLib.Themes.iOS.Text, Name = "Ico"})}), {})

    local DragPoint = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})

    local WindowName = AddThemeObject(Create("TextLabel", {Text = Config.Name, TextColor3 = OrionLib.Themes.iOS.Text, TextSize = 16, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Center}), "Text")

    local WindowStuff = AddThemeObject(SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Second, BorderSizePixel = 0, Size = UDim2.new(0, 150, 1, -50), Position = UDim2.new(0, 0, 0, 50)}, {Create("UICorner", {CornerRadius = UDim.new(0, 10)}), TabHolder}), "Second")

    local MainWindow = AddThemeObject(SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Main, BorderSizePixel = 0, Position = UDim2.new(0.5, -307, 0.5, -172), Size = UDim2.new(0, 615, 0, 344), ClipsDescendants = true, Active = true, Parent = Orion}, {Create("UICorner", {CornerRadius = UDim.new(0, 10)}), SetChildren(Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), Name = "TopBar"}, {WindowName, CloseBtn, MinimizeBtn})), DragPoint, WindowStuff}), "Main")

    MakeDraggable(DragPoint, MainWindow)

    AddConnection(CloseBtn.MouseButton1Up, function()
        MainWindow.Visible = false; UIHidden = true
        OrionLib:MakeNotification({Name = "界面隐藏", Content = "点击右Shift重新打开", Time = 5}); Config.CloseCallback()
    end)
    AddConnection(UserInputService.InputBegan, function(Input) if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then MainWindow.Visible = true end end)
    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 615, 0, 344)}):Play(); MinimizeBtn.Ico.Image = "rbxassetid://7072719338"; task.wait(.02); MainWindow.ClipsDescendants = false; WindowStuff.Visible = true
        else MainWindow.ClipsDescendants = true; MinimizeBtn.Ico.Image = "rbxassetid://7072720870"; TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play(); task.wait(0.1); WindowStuff.Visible = false end
        Minimized = not Minimized
    end)

    if Config.IntroEnabled then
        MainWindow.Visible = false
        local logo = Create("ImageLabel", {Image = Config.IntroIcon or "rbxassetid://8834748103", Parent = Orion, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.4, 0), Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 1, ImageColor3 = OrionLib.Themes.iOS.Text, ImageTransparency = 1})
        local txt = Create("TextLabel", {Text = Config.IntroText, TextColor3 = OrionLib.Themes.iOS.Text, TextSize = 14, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Parent = Orion, Size = UDim2.new(1, 0, 1, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 19, 0.5, 0), TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1})
        TweenService:Create(logo, TweenInfo.new(.3, Enum.EasingStyle.Quad), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        task.wait(0.8)
        TweenService:Create(logo, TweenInfo.new(.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -(txt.TextBounds.X/2), 0.5, 0)}):Play()
        task.wait(0.3)
        TweenService:Create(txt, TweenInfo.new(.3, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        task.wait(2)
        TweenService:Create(txt, TweenInfo.new(.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        MainWindow.Visible = true; logo:Destroy(); txt:Destroy()
    end

    local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}; TabConfig.Name = TabConfig.Name or "Tab"; TabConfig.Icon = TabConfig.Icon or ""
        local TabFrame = SetChildren(Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = TabHolder}, {AddThemeObject(Create("ImageLabel", {Image = TabConfig.Icon, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 15, 0.5, 0), BackgroundTransparency = 1, ImageTransparency = 0.4, Name = "Ico"}), "Text"), AddThemeObject(Create("TextLabel", {Text = TabConfig.Name, TextColor3 = OrionLib.Themes.iOS.Text, TextSize = 14, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Size = UDim2.new(1, -45, 1, 0), Position = UDim2.new(0, 45, 0, 0), TextTransparency = 0.4, Name = "Title"}), "Text")}), {})

        local Container = AddThemeObject(SetChildren(Create("ScrollingFrame", {BackgroundTransparency = 1, MidImage = "rbxassetid://7445543667", BottomImage = "rbxassetid://7445543667", TopImage = "rbxassetid://7445543667", ScrollBarImageColor3 = OrionLib.Themes.iOS.Text, BorderSizePixel = 0, ScrollBarThickness = 5, Size = UDim2.new(1, -150, 1, -50), Position = UDim2.new(0, 150, 0, 50), Parent = MainWindow, Visible = false, Name = "ItemContainer"}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)}), Create("UIPadding", {PaddingBottom = UDim.new(0, 15), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 15)})}), "Divider")

        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30) end)

        if FirstTab then FirstTab = false; TabFrame.Ico.ImageTransparency = 0; TabFrame.Title.TextTransparency = 0; TabFrame.Title.Font = Enum.Font.GothamBold; TabFrame.BackgroundColor3 = OrionLib.Themes.iOS.Third; TabFrame.BackgroundTransparency = 0; Container.Visible = true end

        AddConnection(TabFrame.MouseButton1Click, function()
            for _, t in pairs(TabHolder:GetChildren()) do if t:IsA("TextButton") then t.Title.Font = Enum.Font.GothamSemibold; TweenService:Create(t.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}):Play(); TweenService:Create(t.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play(); TweenService:Create(t, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play() end end
            for _, c in pairs(MainWindow:GetChildren()) do if c.Name == "ItemContainer" then c.Visible = false end end
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play(); TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play(); TweenService:Create(TabFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.GothamBold; TabFrame.BackgroundColor3 = OrionLib.Themes.iOS.Third; Container.Visible = true
        end)

        local function GetElements(ItemParent)
            local ElementFunction = {}
            function ElementFunction:AddLabel(Text)
                local frame = AddThemeObject(SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Second, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 35), Parent = ItemParent}, {Create("UICorner", {CornerRadius = UDim.new(0, 8)}), AddThemeObject(Create("TextLabel", {Text = Text, TextColor3 = OrionLib.Themes.iOS.Text, TextSize = 15, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0), Name = "Content"}), "Text")}), "Second")
                local func = {}; function func:Set(t) frame.Content.Text = t end; return func
            end
            function ElementFunction:AddButton(Config)
                Config = Config or {}; Config.Name = Config.Name or "Button"; Config.Callback = Config.Callback or function() end
                local Button = {}
                local Click = Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0)})
                local frame = AddThemeObject(SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Second, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 38), Parent = ItemParent}, {Create("UICorner", {CornerRadius = UDim.new(0, 8)}), Create("TextLabel", {Text = Config.Name, TextColor3 = OrionLib.Themes.iOS.ButtonText, TextSize = 15, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0), Name = "Content"}), Click}), "Second")
                AddConnection(Click.MouseButton1Up, function() spawn(function() Config.Callback(Button) end) end)
                function Button:Set(t) frame.Content.Text = t end; return Button
            end
            function ElementFunction:AddToggle(Config)
                Config = Config or {}; Config.Name = Config.Name or "Toggle"; Config.Default = Config.Default or false; Config.Callback = Config.Callback or function() end
                local Toggle = {Value = Config.Default}
                local Click = Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0)})
                local ToggleBox = SetChildren(Create("Frame", {BackgroundColor3 = Config.Default and OrionLib.Themes.iOS.ToggleOn or OrionLib.Themes.iOS.ToggleOff, BorderSizePixel = 0, Size = UDim2.new(0, 50, 0, 30), Position = UDim2.new(1, -55, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)}), Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Text, BorderSizePixel = 0, Size = UDim2.new(0, 26, 0, 26), Position = Config.Default and UDim2.new(1, -28, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Name = "Circle"}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})}), {})
                local frame = AddThemeObject(SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Second, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 43), Parent = ItemParent}, {Create("UICorner", {CornerRadius = UDim.new(0, 8)}), AddThemeObject(Create("TextLabel", {Text = Config.Name, TextColor3 = OrionLib.Themes.iOS.Text, TextSize = 15, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 12, 0, 0)}), "Text"), ToggleBox, Click}), "Second")
                function Toggle:Set(v)
                    self.Value = v; Config.Callback(v)
                    if v then TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = OrionLib.Themes.iOS.ToggleOn}):Play(); TweenService:Create(ToggleBox.Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -28, 0.5, 0)}):Play()
                    else TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = OrionLib.Themes.iOS.ToggleOff}):Play(); TweenService:Create(ToggleBox.Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 2, 0.5, 0)}):Play() end
                end
                AddConnection(Click.MouseButton1Up, function() Toggle:Set(not Toggle.Value) end)
                return Toggle
            end
            function ElementFunction:AddSlider(Config)
                Config = Config or {}; Config.Name = Config.Name or "Slider"; Config.Min = Config.Min or 0; Config.Max = Config.Max or 100; Config.Increment = Config.Increment or 1; Config.Default = Config.Default or 50; Config.Callback = Config.Callback or function() end; Config.ValueName = Config.ValueName or ""
                local Slider = {Value = Config.Default}; local Dragging = false
                local SliderDrag = SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.ButtonText, BorderSizePixel = 0, Size = UDim2.new((Config.Default - Config.Min) / (Config.Max - Config.Min), 0, 1, 0), BackgroundTransparency = 0.3, ClipsDescendants = true}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})}), {})
                local SliderBar = SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Second, BorderSizePixel = 0, Size = UDim2.new(1, -24, 0, 26), Position = UDim2.new(0, 12, 0, 30), BackgroundTransparency = 0.9}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)}), SliderDrag, Create("TextLabel", {Text = tostring(Config.Default) .. " " .. Config.ValueName, TextColor3 = OrionLib.Themes.iOS.Text, TextSize = 13, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 14), Position = UDim2.new(0, 12, 0, 6), TextTransparency = 0.8, Name = "Val"})}), {})
                local frame = AddThemeObject(SetChildren(Create("Frame", {BackgroundColor3 = OrionLib.Themes.iOS.Second, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 70), Parent = ItemParent}, {Create("UICorner", {CornerRadius = UDim.new(0, 8)}), AddThemeObject(Create("TextLabel", {Text = Config.Name, TextColor3 = OrionLib.Themes.iOS.Text, TextSize = 15, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 14), Position = UDim2.new(0, 12, 0, 10)}), "Text"), SliderBar}), "Second")
                SliderBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true end end)
                SliderBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local scale = math.clamp((i.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Slider:Set(Config.Min + ((Config.Max - Config.Min) * scale))
                    end
                end)
                function Slider:Set(v)
                    self.Value = math.clamp(Round(v, Config.Increment), Config.Min, Config.Max)
                    TweenService:Create(SliderDrag, TweenInfo.new(.15, Enum.EasingStyle.Quad), {Size = UDim2.fromScale((self.Value - Config.Min) / (Config.Max - Config.Min), 1)}):Play()
                    SliderBar.Val.Text = tostring(self.Value) .. " " .. Config.ValueName; Config.Callback(self.Value)
                end
                return Slider
            end
            function ElementFunction:AddSection(Config)
                Config.Name = Config.Name or "Section"
                local holder = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Name = "Holder"}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})})
                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Parent = Container}, {AddThemeObject(Create("TextLabel", {Text = Config.Name, TextColor3 = OrionLib.Themes.iOS.TextDark, TextSize = 14, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 16), Position = UDim2.new(0, 0, 0, 3)}), "TextDark"), holder})
                AddConnection(holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() frame.Size = UDim2.new(1, 0, 0, holder.UIListLayout.AbsoluteContentSize.Y + 31); holder.Size = UDim2.new(1, 0, 0, holder.UIListLayout.AbsoluteContentSize.Y) end)
                local secFunc = {}
                for i, v in pairs(GetElements(holder)) do secFunc[i] = v end
                return secFunc
            end
            return ElementFunction
        end
        local ElementFunction = {}
        for i, v in pairs(GetElements(Container)) do ElementFunction[i] = v end
        return ElementFunction
    end
    return TabFunction
end

-- ==================== 秋雨脚本功能 ====================
local char, root, hum
local function SetupChar()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end
SetupChar()
LocalPlayer.CharacterAdded:Connect(SetupChar)

local State = {
    Flying = false, Spinning = false, Circling = false,
    NoClip = false, InfJump = false, Speed = 1,
    ESP = false, ESPBox = false, ESPName = false, ESPHealth = false, ESPDistance = false, ESPTracers = false,
    Aimbot = false, AimbotVisible = false, Hitbox = false, HitboxSize = 5,
}
local Comp = {
    FlyBV = nil, FlyConn = nil, FlyK1 = nil, FlyK2 = nil,
    SpinAV = nil, CircleConn = nil, CircleTarget = nil, CircleAngle = 0,
    JumpConn = nil, NoClipConn = nil, SelTarget = nil, ESPConns = {}, AimbotConn = nil,
    HitboxConn = nil, HitboxParts = {}, TrollObjs = {},
}

-- 功能函数
local function StartFly()
    if State.Flying then return end; State.Flying = true
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1,1,1)*50000; bv.Velocity = Vector3.zero; bv.Parent = root; Comp.FlyBV = bv
    local md, ud, sp = Vector3.zero, 0, 50
    Comp.FlyConn = RunService.Heartbeat:Connect(function()
        if not State.Flying or not Comp.FlyBV then return end; local cam = Camera; if not cam then return end
        local fw = cam.CFrame.LookVector * Vector3.new(1,0,1); local rt = cam.CFrame.RightVector * Vector3.new(1,0,1)
        local mv = (fw * -md.Z) + (rt * md.X) + Vector3.new(0, ud, 0)
        Comp.FlyBV.Velocity = mv.Magnitude > 0.1 and mv.Unit * sp or Vector3.zero
    end)
    Comp.FlyK1 = UserInputService.InputBegan:Connect(function(i,g) if g then return end
        if i.KeyCode == Enum.KeyCode.W then md += Vector3.new(0,0,-1) elseif i.KeyCode == Enum.KeyCode.S then md += Vector3.new(0,0,1)
        elseif i.KeyCode == Enum.KeyCode.A then md += Vector3.new(-1,0,0) elseif i.KeyCode == Enum.KeyCode.D then md += Vector3.new(1,0,0)
        elseif i.KeyCode == Enum.KeyCode.Space then ud = 1 elseif i.KeyCode == Enum.KeyCode.LeftControl then ud = -1 end end)
    Comp.FlyK2 = UserInputService.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W then md -= Vector3.new(0,0,-1) elseif i.KeyCode == Enum.KeyCode.S then md -= Vector3.new(0,0,1)
        elseif i.KeyCode == Enum.KeyCode.A then md -= Vector3.new(-1,0,0) elseif i.KeyCode == Enum.KeyCode.D then md -= Vector3.new(1,0,0)
        elseif i.KeyCode == Enum.KeyCode.Space then ud = 0 elseif i.KeyCode == Enum.KeyCode.LeftControl then ud = 0 end end)
end
local function StopFly() State.Flying = false; if Comp.FlyBV then Comp.FlyBV:Destroy(); Comp.FlyBV = nil end; if Comp.FlyConn then Comp.FlyConn:Disconnect(); Comp.FlyConn = nil end; if Comp.FlyK1 then Comp.FlyK1:Disconnect(); Comp.FlyK1 = nil end; if Comp.FlyK2 then Comp.FlyK2:Disconnect(); Comp.FlyK2 = nil end end
local function StartSpin() if State.Spinning then return end; State.Spinning = true; hum.AutoRotate = false; if root:FindFirstChild("SpinRotator") then root.SpinRotator:Destroy() end; local av = Instance.new("BodyAngularVelocity"); av.Name = "SpinRotator"; av.MaxTorque = Vector3.new(0,math.huge,0); av.AngularVelocity = Vector3.new(0,70,0); av.Parent = root; Comp.SpinAV = av end
local function StopSpin() State.Spinning = false; if Comp.SpinAV then Comp.SpinAV:Destroy(); Comp.SpinAV = nil end; hum.AutoRotate = true end
local function StartCircle(target) if State.Circling then StopCircle() end; if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not root then return end; State.Circling = true; Comp.CircleTarget = target; Comp.CircleAngle = math.random()*math.pi*2; local r, ho, sm = 8, 3, 0.5; Comp.CircleConn = RunService.Heartbeat:Connect(function() if not State.Circling or not Comp.CircleTarget then StopCircle(); return end; local tc = Comp.CircleTarget.Character; if not tc then StopCircle(); return end; local tr = tc:FindFirstChild("HumanoidRootPart"); if not tr or not root or not root.Parent then StopCircle(); return end; Comp.CircleAngle += 0.1; local tp = tr.Position; root.CFrame = CFrame.new(root.Position:Lerp(Vector3.new(tp.X+r*math.cos(Comp.CircleAngle), tp.Y+ho, tp.Z+r*math.sin(Comp.CircleAngle)), sm)) end) end
local function StopCircle() State.Circling = false; Comp.CircleTarget = nil; if Comp.CircleConn then Comp.CircleConn:Disconnect(); Comp.CircleConn = nil end end
local function ToggleInfJump() State.InfJump = not State.InfJump; if State.InfJump then Comp.JumpConn = RunService.Heartbeat:Connect(function() if not State.InfJump or not hum or not hum.Parent then return end; local s = hum:GetState(); if s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Jumping then hum.Jump = true end end) else if Comp.JumpConn then Comp.JumpConn:Disconnect(); Comp.JumpConn = nil end end end
local function ToggleNoClip() State.NoClip = not State.NoClip; if State.NoClip then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end; Comp.NoClipConn = char.DescendantAdded:Connect(function(p) if p:IsA("BasePart") and State.NoClip then p.CanCollide = false end end) else for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end; if Comp.NoClipConn then Comp.NoClipConn:Disconnect(); Comp.NoClipConn = nil end end end
local function StopAll() if State.Flying then StopFly() end; if State.Spinning then StopSpin() end; if State.Circling then StopCircle() end; if State.InfJump then ToggleInfJump() end; if State.NoClip then ToggleNoClip() end; if State.Speed ~= 1 then State.Speed = 1; hum.WalkSpeed = 16 end end
local function TeleportToPlayer(tp) if not tp or not root then return false end; local tc = tp.Character; if tc and tc:FindFirstChild("HumanoidRootPart") then root.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0,3,0); return true end; return false end
local function GetTarget() return Comp.SelTarget end
local function TrollHandsUp(target) if not target then return end; local ch = target.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end; hum.PlatformStand = true; task.wait(0.1); local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso"); if torso then local rs = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightUpperArm"); local ls = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftUpperArm"); if rs then rs.CurrentAngle = math.rad(180) end; if ls then ls.CurrentAngle = math.rad(180) end end end
local function TrollSit(target) if not target then return end; local ch = target.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end; hum.Sit = true end
local function TrollFreeze(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; for _, o in pairs(Comp.TrollObjs) do if o and o.Parent then o:Destroy() end end; Comp.TrollObjs = {}; local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1,1,1)*999999; bv.Velocity = Vector3.zero; bv.Parent = hrp; local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1,1,1)*999999; bg.CFrame = hrp.CFrame; bg.Parent = hrp; table.insert(Comp.TrollObjs, bv); table.insert(Comp.TrollObjs, bg) end
local function TrollFling(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1,1,1)*999999; bv.Velocity = Vector3.new(math.random(-300,300), 800, math.random(-300,300)); bv.Parent = hrp; table.insert(Comp.TrollObjs, bv); task.wait(1); if bv and bv.Parent then bv:Destroy() end end
local function TrollSpin(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1,1,1)*999999; bg.CFrame = hrp.CFrame; bg.Parent = hrp; table.insert(Comp.TrollObjs, bg); task.spawn(function() while bg and bg.Parent do bg.CFrame = bg.CFrame * CFrame.Angles(0, math.rad(20), 0); task.wait() end end) end
local function TrollFlip(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1,1,1)*999999; bg.CFrame = hrp.CFrame * CFrame.Angles(math.rad(180), 0, 0); bg.Parent = hrp; table.insert(Comp.TrollObjs, bg) end
local function ClearTroll() for _, o in pairs(Comp.TrollObjs) do if o and o.Parent then o:Destroy() end end; Comp.TrollObjs = {}; local t = GetTarget(); if not t then return end; local ch = t.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if hum then hum.PlatformStand = false; hum.Sit = false end end
local function GetClosestPlayer() local cl, sd = nil, math.huge; for _, pl in pairs(Players:GetPlayers()) do if pl == LocalPlayer then continue end; local tc = pl.Character; if not tc then continue end; local hd = tc:FindFirstChild("Head"); if not hd then continue end; if State.AimbotVisible then local _, os = Camera:WorldToViewportPoint(hd.Position); if not os then continue end; local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {char}; rp.FilterType = Enum.RaycastFilterType.Blacklist; local ry = workspace:Raycast(Camera.CFrame.Position, (hd.Position - Camera.CFrame.Position).Unit * 500, rp); if ry then local hc = ry.Instance:FindFirstAncestorOfClass("Model"); if hc ~= pl.Character then continue end end end; local sp, os = Camera:WorldToViewportPoint(hd.Position); if os then local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); local d = (Vector2.new(sp.X, sp.Y) - sc).Magnitude; if d < sd then sd = d; cl = pl end end end; return cl end
local function ToggleAimbot() State.Aimbot = not State.Aimbot; if State.Aimbot then Comp.AimbotConn = RunService.Heartbeat:Connect(function() if not State.Aimbot then return end; local t = GetClosestPlayer(); if t and t.Character and t.Character:FindFirstChild("Head") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end end) else if Comp.AimbotConn then Comp.AimbotConn:Disconnect(); Comp.AimbotConn = nil end end end
local function ExpandHitbox(ch) local pts = {}; for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then local os = p.Size; p.Size = os * State.HitboxSize; p.Transparency = 0.7; p.CanCollide = true; table.insert(pts, {part = p, oldSize = os}) end end; return pts end
local function RestoreHitbox(pts) for _, d in pairs(pts) do if d.part and d.part.Parent then d.part.Size = d.oldSize end end end
local function ToggleHitbox() State.Hitbox = not State.Hitbox; if State.Hitbox then for _, pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer and pl.Character then Comp.HitboxParts[pl] = ExpandHitbox(pl.Character) end end; Comp.HitboxConn = Players.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(function(ch) task.wait(0.5); if State.Hitbox then Comp.HitboxParts[pl] = ExpandHitbox(ch) end end) end) else for _, pts in pairs(Comp.HitboxParts) do RestoreHitbox(pts) end; Comp.HitboxParts = {}; if Comp.HitboxConn then Comp.HitboxConn:Disconnect(); Comp.HitboxConn = nil end end end

-- ESP
local ESPDrawings = {}
local function CreateESP(player) local d = {}; d.Box = Drawing.new("Square"); d.Box.Visible = false; d.Box.Color = Color3.fromRGB(255,255,255); d.Box.Thickness = 1.5; d.Box.Filled = false; d.Box.Transparency = 0.7; d.Name = Drawing.new("Text"); d.Name.Visible = false; d.Name.Color = Color3.fromRGB(255,255,255); d.Name.Size = 13; d.Name.Center = true; d.Name.Outline = true; d.Name.Font = 3; d.HBg = Drawing.new("Square"); d.HBg.Visible = false; d.HBg.Color = Color3.fromRGB(30,30,30); d.HBg.Thickness = 1; d.HBg.Filled = true; d.HBar = Drawing.new("Square"); d.HBar.Visible = false; d.HBar.Color = Color3.fromRGB(0,255,0); d.HBar.Thickness = 1; d.HBar.Filled = true; d.Dist = Drawing.new("Text"); d.Dist.Visible = false; d.Dist.Color = Color3.fromRGB(255,255,255); d.Dist.Size = 12; d.Dist.Center = true; d.Dist.Outline = true; d.Dist.Font = 3; d.Tracer = Drawing.new("Line"); d.Tracer.Visible = false; d.Tracer.Color = Color3.fromRGB(255,255,255); d.Tracer.Thickness = 1; d.Tracer.Transparency = 0.5; ESPDrawings[player] = d end
local function UpdateESP()
    for player, d in pairs(ESPDrawings) do
        if not player or not player.Parent then for _, v in pairs(d) do v:Remove() end; ESPDrawings[player] = nil; continue end
        local ch = player.Character; if not ch or not ch:FindFirstChild("HumanoidRootPart") or not ch:FindFirstChild("Humanoid") then for _, v in pairs(d) do v.Visible = false end; continue end
        if not root then continue end; local tr = ch.HumanoidRootPart; local th = ch.Humanoid; local pos, os = Camera:WorldToViewportPoint(tr.Position)
        if not os then for _, v in pairs(d) do v.Visible = false end; continue end
        local dist = (root.Position - tr.Position).Magnitude; local scale = math.clamp(1/(dist*0.05),0.5,2); local bs = Vector2.new(40*scale, 60*scale); local bp = Vector2.new(pos.X-bs.X/2, pos.Y-bs.Y/2)
        if State.ESP and State.ESPBox then d.Box.Visible = true; d.Box.Size = bs; d.Box.Position = bp; d.Box.Color = (player.TeamColor and player.TeamColor.Color) or Color3.fromRGB(255,255,255) else d.Box.Visible = false end
        if State.ESP and State.ESPName then d.Name.Visible = true; d.Name.Position = Vector2.new(pos.X, bp.Y-18); d.Name.Text = player.Name else d.Name.Visible = false end
        if State.ESP and State.ESPHealth then local h = th.Health; local mh = th.MaxHealth; local hp = math.clamp(h/mh,0,1); d.HBg.Visible = true; d.HBg.Size = Vector2.new(3, bs.Y); d.HBg.Position = Vector2.new(bp.X-6, bp.Y); d.HBar.Visible = true; d.HBar.Size = Vector2.new(3, bs.Y*hp); d.HBar.Position = Vector2.new(bp.X-6, bp.Y+bs.Y*(1-hp)); d.HBar.Color = hp>0.6 and Color3.fromRGB(0,255,0) or (hp>0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)) else d.HBg.Visible = false; d.HBar.Visible = false end
        if State.ESP and State.ESPDistance then d.Dist.Visible = true; d.Dist.Position = Vector2.new(pos.X, bp.Y+bs.Y+4); d.Dist.Text = math.floor(dist).."m" else d.Dist.Visible = false end
        if State.ESP and State.ESPTracers then d.Tracer.Visible = true; d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(pos.X, bp.Y+bs.Y); d.Tracer.Color = Color3.fromRGB(255,255,255) else d.Tracer.Visible = false end
    end end
RunService.RenderStepped:Connect(function() if State.ESP then UpdateESP() end end)
local function ToggleESP() State.ESP = not State.ESP; if State.ESP then for _, pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then CreateESP(pl) end end; local pa = Players.PlayerAdded:Connect(function(pl) if pl ~= LocalPlayer then task.wait(1); CreateESP(pl) end end); table.insert(Comp.ESPConns, pa); local pr = Players.PlayerRemoving:Connect(function(pl) if ESPDrawings[pl] then for _, v in pairs(ESPDrawings[pl]) do v:Remove() end; ESPDrawings[pl] = nil end end); table.insert(Comp.ESPConns, pr) else for _, d in pairs(ESPDrawings) do for _, v in pairs(d) do v:Remove() end end; ESPDrawings = {}; for _, c in pairs(Comp.ESPConns) do c:Disconnect() end; Comp.ESPConns = {} end end

-- ==================== iOS UI窗口 ====================
local Window = OrionLib:MakeWindow({
    Name = "秋雨脚本",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "QiuYu",
    IntroEnabled = true,
    IntroText = "秋雨脚本",
    IntroIcon = "rbxassetid://73337518954608",
    Icon = "rbxassetid://73337518954608",
    CloseCallback = function() StopAll(); State.ESP = false end
})

-- ESP
local ESPTab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://7733965236"})
local espToggle = ESPTab:AddToggle({Name = "ESP总开关", Default = false, Callback = function(v) ToggleESP() end})
ESPTab:AddToggle({Name = "方框", Default = false, Callback = function(v) State.ESPBox = v end})
ESPTab:AddToggle({Name = "名字", Default = false, Callback = function(v) State.ESPName = v end})
ESPTab:AddToggle({Name = "血量", Default = false, Callback = function(v) State.ESPHealth = v end})
ESPTab:AddToggle({Name = "距离", Default = false, Callback = function(v) State.ESPDistance = v end})
ESPTab:AddToggle({Name = "射线", Default = false, Callback = function(v) State.ESPTracers = v end})
ESPTab:AddButton({Name = "QQ群: 1051933529", Callback = function() if setclipboard then setclipboard("1051933529") end; OrionLib:MakeNotification({Name = "QQ群", Content = "已复制: 1051933529", Time = 3}) end})

-- 功能
local FuncTab = Window:MakeTab({Name = "功能", Icon = "rbxassetid://7733965236"})
FuncTab:AddToggle({Name = "飞行 (WASD/空格/Ctrl)", Default = false, Callback = function(v) if v then StartFly() else StopFly() end end})
FuncTab:AddToggle({Name = "自转", Default = false, Callback = function(v) if v then StartSpin() else StopSpin() end end})
FuncTab:AddToggle({Name = "无限跳跃", Default = false, Callback = function(v) ToggleInfJump() end})
FuncTab:AddToggle({Name = "穿墙", Default = false, Callback = function(v) ToggleNoClip() end})
FuncTab:AddSlider({Name = "速度", Min = 1, Max = 16, Default = 1, Increment = 1, ValueName = "x", Callback = function(v) State.Speed = v; hum.WalkSpeed = 16 * v end})
FuncTab:AddButton({Name = "停止全部", Callback = StopAll})

-- 娱乐
local FunTab = Window:MakeTab({Name = "娱乐", Icon = "rbxassetid://7733965236"})
FunTab:AddButton({Name = "绕圈", Callback = function() if State.Circling then StopCircle() elseif GetTarget() then StartCircle(GetTarget()) end end})
FunTab:AddButton({Name = "举手", Callback = function() TrollHandsUp(GetTarget()) end})
FunTab:AddButton({Name = "摔倒", Callback = function() TrollSit(GetTarget()) end})
FunTab:AddButton({Name = "冻结", Callback = function() TrollFreeze(GetTarget()) end})
FunTab:AddButton({Name = "弹飞", Callback = function() TrollFling(GetTarget()) end})
FunTab:AddButton({Name = "转圈", Callback = function() TrollSpin(GetTarget()) end})
FunTab:AddButton({Name = "倒立", Callback = function() TrollFlip(GetTarget()) end})
FunTab:AddButton({Name = "恢复", Callback = ClearTroll})
local targetLabel = FunTab:AddLabel("目标: 无 (点玩家标签选目标)")
local function refreshLabel() targetLabel:Set("目标: " .. (GetTarget() and GetTarget().Name or "无 (点玩家标签选目标)")) end

-- 战斗
local CombatTab = Window:MakeTab({Name = "战斗", Icon = "rbxassetid://7733965236"})
CombatTab:AddToggle({Name = "自瞄", Default = false, Callback = function(v) ToggleAimbot() end})
CombatTab:AddToggle({Name = "可视检查", Default = false, Callback = function(v) State.AimbotVisible = v end})
CombatTab:AddToggle({Name = "范围伤害", Default = false, Callback = function(v) ToggleHitbox() end})
CombatTab:AddSlider({Name = "范围大小", Min = 2, Max = 20, Default = 5, Increment = 1, Callback = function(v) State.HitboxSize = v end})

-- 玩家
local PlayerTab = Window:MakeTab({Name = "玩家", Icon = "rbxassetid://7733965236"})
local playerMode = "teleport"
local modeBtn = PlayerTab:AddButton({Name = "模式: 传送", Callback = function(b)
    playerMode = (playerMode == "teleport") and "circle" or "teleport"
    b:Set("模式: " .. (playerMode == "teleport" and "传送" or "绕圈"))
end})

local function refreshPlayers()
    local sec = PlayerTab:AddSection({Name = "玩家列表"})
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            sec:AddButton({Name = pl.Name, Callback = function()
                if playerMode == "teleport" then TeleportToPlayer(pl)
                else Comp.SelTarget = pl; refreshLabel(); OrionLib:MakeNotification({Name = "目标", Content = "选中: " .. pl.Name, Time = 3}) end
            end})
        end
    end
end
refreshPlayers()

OrionLib:Init()
print("秋雨脚本 iOS完整版 加载完成!")
