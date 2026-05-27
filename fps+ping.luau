local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    local old = PlayerGui:FindFirstChild("HuTaoPerformance")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HuTaoPerformance"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local OuterBorder = Instance.new("Frame")
OuterBorder.Parent = ScreenGui
OuterBorder.Size = UDim2.fromOffset(1, 1)
OuterBorder.Position = UDim2.new(1, -155, 0, 10)
OuterBorder.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
OuterBorder.BorderSizePixel = 0

local OuterCorner = Instance.new("UICorner")
OuterCorner.CornerRadius = UDim.new(0, 9)
OuterCorner.Parent = OuterBorder

local MainFrame = Instance.new("Frame")
MainFrame.Parent = OuterBorder
MainFrame.Size = UDim2.new(1, -4, 1, -4)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 7)
MainCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = MainFrame
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(30, 30, 35)

TweenService:Create(OuterBorder, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(145, 54)
}):Play()

local Glow = Instance.new("Frame")
Glow.Parent = MainFrame
Glow.ZIndex = 2
Glow.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Glow.BackgroundTransparency = 0.82
Glow.BorderSizePixel = 0
Glow.Size = UDim2.new(1, 0, 0, 2)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.ZIndex = 5
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 14)
Title.Position = UDim2.new(0, 0, 0, 3)
Title.Font = Enum.Font.Code
Title.Text = "HUTAO PERFORMANCE"
Title.TextSize = 10
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Parent = MainFrame
FPSLabel.ZIndex = 5
FPSLabel.BackgroundTransparency = 1
FPSLabel.Size = UDim2.new(1, -14, 0, 15)
FPSLabel.Position = UDim2.new(0, 7, 0, 19)
FPSLabel.Font = Enum.Font.Code
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.TextSize = 12
FPSLabel.Text = "FPS  : LOADING..."
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = MainFrame
PingLabel.ZIndex = 5
PingLabel.BackgroundTransparency = 1
PingLabel.Size = UDim2.new(1, -14, 0, 15)
PingLabel.Position = UDim2.new(0, 7, 0, 34)
PingLabel.Font = Enum.Font.Code
PingLabel.TextXAlignment = Enum.TextXAlignment.Left
PingLabel.TextSize = 12
PingLabel.Text = "PING : LOADING..."
PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local Active = true
local function CreateParticle()
    if not Active then return end
    local Particle = Instance.new("Frame", MainFrame)
    Particle.ZIndex = 1
    Particle.BorderSizePixel = 0
    local Size = math.random(1, 2)
    Particle.Size = UDim2.fromOffset(Size, Size)
    Particle.Position = UDim2.new(math.random(), 0, 1, 0)
    Particle.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
    Particle.BackgroundTransparency = 0.72

    TweenService:Create(Particle, TweenInfo.new(math.random(45, 60) / 10, Enum.EasingStyle.Linear), {
        Position = UDim2.new(Particle.Position.X.Scale, 0, -0.15, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(6, function() Particle:Destroy() end)
end

task.spawn(function()
    while Active do
        CreateParticle()
        task.wait(0.5)
    end
end)

local function GetFPSColor(fps)
    if fps >= 50 then return Color3.fromRGB(0, 255, 120)
    elseif fps >= 30 then return Color3.fromRGB(255, 220, 0)
    else return Color3.fromRGB(255, 70, 70) end
end

local function GetPingColor(ping)
    if ping <= 80 then return Color3.fromRGB(0, 255, 120)
    elseif ping <= 150 then return Color3.fromRGB(255, 220, 0)
    else return Color3.fromRGB(255, 70, 70) end
end

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
            Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)

        FPSLabel.Text = "FPS  : " .. FPS
        FPSLabel.TextColor3 = GetFPSColor(FPS)

        PingLabel.Text = "PING : " .. Ping .. " MS"
        PingLabel.TextColor3 = GetPingColor(Ping)
    end
end)
