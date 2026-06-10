local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local function getParent()
    return (gethui and gethui()) or CoreGui
end

pcall(function()
    local old = getParent():FindFirstChild("HuTaoPerformance")
    if old then old:Destroy() end
    local oldPlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("HuTaoPerformance")
    if oldPlayerGui then oldPlayerGui:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HuTaoPerformance"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getParent()

local ConfigFile = "HutaoPerfConfig.json"
local defaultPos = UDim2.new(1, -155, 0, 10)
local defaultScale = 1

local savedPos = defaultPos
local savedScale = defaultScale

local function SaveConfig(pos, scale)
    local data = {
        Pos = {pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset},
        Scale = scale
    }
    pcall(function()
        if writefile then
            writefile(ConfigFile, HttpService:JSONEncode(data))
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile(ConfigFile) then
            local decoded = HttpService:JSONDecode(readfile(ConfigFile))
            if decoded then
                if decoded.Pos then
                    savedPos = UDim2.new(decoded.Pos[1], decoded.Pos[2], decoded.Pos[3], decoded.Pos[4])
                end
                if decoded.Scale then
                    savedScale = decoded.Scale
                end
            end
        end
    end)
end

LoadConfig()

local Container = Instance.new("Frame", ScreenGui)
Container.Size = UDim2.fromOffset(1, 1) 
Container.Position = savedPos -- Áp dụng vị trí đã lưu hoặc mặc định
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ClipsDescendants = false

local UIScale = Instance.new("UIScale", Container)
UIScale.Scale = savedScale

TweenService:Create(Container, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(145, 54)
}):Play()

local SettingsPanel = Instance.new("Frame", Container)
SettingsPanel.Size = UDim2.new(1, 0, 0, 125)
SettingsPanel.Position = UDim2.new(0, 0, 0, 0)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.ZIndex = 1
SettingsPanel.Visible = false
Instance.new("UICorner", SettingsPanel).CornerRadius = UDim.new(0, 7)

local SPStroke = Instance.new("UIStroke", SettingsPanel)
SPStroke.Thickness = 1
SPStroke.Color = Color3.fromRGB(0, 140, 255)
SPStroke.Transparency = 0.5

local UIListLayout = Instance.new("UIListLayout", SettingsPanel)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding", SettingsPanel)
UIPadding.PaddingTop = UDim.new(0, 8)

local function Tween(obj, props, time)
    time = time or 0.2
    local tw = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function CreateButton(text)
    local Btn = Instance.new("TextButton", SettingsPanel)
    Btn.Size = UDim2.new(1, -16, 0, 22)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 11
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(40, 40, 45)
    
    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(255, 255, 255)}) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(20, 20, 25), TextColor3 = Color3.fromRGB(200, 200, 200)}) end)
    return Btn
end

local SizeInput = Instance.new("TextBox", SettingsPanel)
SizeInput.Size = UDim2.new(1, -16, 0, 22)
SizeInput.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeInput.Font = Enum.Font.Code
SizeInput.TextSize = 11
SizeInput.PlaceholderText = "Size (VD: 1.2)"
SizeInput.Text = tostring(UIScale.Scale)
Instance.new("UICorner", SizeInput).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", SizeInput).Color = Color3.fromRGB(40, 40, 45)

local DragToggle = CreateButton("Move GUI: OFF")
local SaveBtn = CreateButton("Save Settings")
local ResetBtn = CreateButton("Reset Default")

local OuterBorder = Instance.new("Frame", Container)
OuterBorder.Size = UDim2.new(1, 0, 1, 0)
OuterBorder.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
OuterBorder.BorderSizePixel = 0
OuterBorder.ZIndex = 5
Instance.new("UICorner", OuterBorder).CornerRadius = UDim.new(0, 9)

local MainFrame = Instance.new("Frame", OuterBorder)
MainFrame.Size = UDim2.new(1, -4, 1, -4)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 6
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 7)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(30, 30, 35)

local Glow = Instance.new("Frame", MainFrame)
Glow.ZIndex = 7
Glow.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Glow.BackgroundTransparency = 0.82
Glow.BorderSizePixel = 0
Glow.Size = UDim2.new(1, 0, 0, 2)

local function CreateLabel(text, pos)
    local lbl = Instance.new("TextLabel", MainFrame)
    lbl.ZIndex = 10
    lbl.BackgroundTransparency = 1
    lbl.Position = pos
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = 12
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    return lbl
end

local Title = CreateLabel("", UDim2.new(0, 7, 0, 3))
Title.Size = UDim2.new(1, -30, 0, 14)
Title.RichText = true 
Title.Text = "<b>HUTAO PERFORMANCE</b>"

local FPSLabel = CreateLabel("FPS  : LOADING...", UDim2.new(0, 7, 0, 19))
FPSLabel.Size = UDim2.new(1, -14, 0, 15)
local PingLabel = CreateLabel("PING : LOADING...", UDim2.new(0, 7, 0, 34))
PingLabel.Size = UDim2.new(1, -14, 0, 15)

local SettingsBtn = Instance.new("ImageButton", MainFrame)
SettingsBtn.Size = UDim2.fromOffset(18, 18)
SettingsBtn.Position = UDim2.new(1, -23, 0, 5)
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Image = "rbxassetid://80758916183665"
SettingsBtn.ImageColor3 = Color3.fromRGB(180, 180, 180)
SettingsBtn.ZIndex = 15

local isSettingsOpen = false
SettingsBtn.MouseButton1Click:Connect(function()
    isSettingsOpen = not isSettingsOpen
    if isSettingsOpen then
        SettingsPanel.Visible = true
        Tween(SettingsBtn, {Rotation = 90, ImageColor3 = Color3.fromRGB(0, 140, 255)}, 0.3)
        Tween(SettingsPanel, {Position = UDim2.new(0, 0, 1, 3)}, 0.45)
    else
        Tween(SettingsBtn, {Rotation = 0, ImageColor3 = Color3.fromRGB(180, 180, 180)}, 0.3)
        local closeTween = Tween(SettingsPanel, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        closeTween.Completed:Connect(function()
            if not isSettingsOpen then
                SettingsPanel.Visible = false
            end
        end)
    end
end)

SizeInput.FocusLost:Connect(function()
    local newScale = tonumber(SizeInput.Text)
    if newScale then
        newScale = math.clamp(newScale, 0.5, 3)
        SizeInput.Text = tostring(newScale)
        Tween(UIScale, {Scale = newScale}, 0.2)
    else
        SizeInput.Text = tostring(UIScale.Scale)
    end
end)

local dragEnabled = false
local dragging, dragStart, startPos

DragToggle.MouseButton1Click:Connect(function()
    dragEnabled = not dragEnabled
    DragToggle.Text = dragEnabled and "Move GUI: ON" or "Move GUI: OFF"
    DragToggle.TextColor3 = dragEnabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
end)

OuterBorder.InputBegan:Connect(function(input)
    if dragEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = Container.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(Container, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

SaveBtn.MouseButton1Click:Connect(function()
    SaveConfig(Container.Position, UIScale.Scale)
    SaveBtn.Text = "Saved to File!"
    SaveBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
    task.wait(1)
    SaveBtn.Text = "Save Settings"
    SaveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

ResetBtn.MouseButton1Click:Connect(function()
    Tween(Container, {Position = defaultPos}, 0.5)
    Tween(UIScale, {Scale = defaultScale}, 0.5)
    SizeInput.Text = tostring(defaultScale)
    SaveConfig(defaultPos, defaultScale) -- Lưu đè vị trí mặc định vào file cấu hình
    
    ResetBtn.Text = "Reset Done!"
    ResetBtn.TextColor3 = Color3.fromRGB(255, 220, 0)
    task.wait(1)
    ResetBtn.Text = "Reset Default"
    ResetBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

task.spawn(function()
    while true do
        local Particle = Instance.new("Frame", MainFrame)
        Particle.ZIndex = 8
        Particle.BorderSizePixel = 0
        local Size = math.random(1, 2)
        Particle.Size = UDim2.fromOffset(Size, Size)
        Particle.Position = UDim2.new(math.random(), 0, 1, 0)
        Particle.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
        Particle.BackgroundTransparency = 0.72

        TweenService:Create(Particle, TweenInfo.new(math.random(4, 6), Enum.EasingStyle.Linear), {
            Position = UDim2.new(Particle.Position.X.Scale, 0, -0.15, 0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(6, function() Particle:Destroy() end)
        task.wait(0.5)
    end
end)

local Frames = 0
local LastTime = tick()

RunService.RenderStepped:Connect(function()
    Frames += 1
    local CurrentTime = tick()
    
    if CurrentTime - LastTime >= 0.5 then
        local FPS = math.floor(Frames / (CurrentTime - LastTime))
        Frames = 0
        LastTime = CurrentTime

        local Ping = 0
        pcall(function()
            local rawPing = Players.LocalPlayer:GetNetworkPing()
            Ping = math.floor(rawPing * 1000)
        end)
        
        if Ping <= 0 then
            pcall(function()
                Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
        end

        FPSLabel.Text = "FPS  : " .. FPS
        FPSLabel.TextColor3 = (FPS >= 50 and Color3.fromRGB(0, 255, 120)) or (FPS >= 30 and Color3.fromRGB(255, 220, 0)) or Color3.fromRGB(255, 70, 70)

        PingLabel.Text = "PING : " .. Ping .. " MS"
        PingLabel.TextColor3 = (Ping <= 80 and Color3.fromRGB(0, 255, 120)) or (Ping <= 150 and Color3.fromRGB(255, 220, 0)) or Color3.fromRGB(255, 70, 70)
    end
end)
