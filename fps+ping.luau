local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

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

local OuterBorder = Instance.new("Frame", ScreenGui)
OuterBorder.Size = UDim2.fromOffset(1, 1)
OuterBorder.Position = UDim2.new(1, -155, 0, 10)
OuterBorder.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
OuterBorder.BorderSizePixel = 0
Instance.new("UICorner", OuterBorder).CornerRadius = UDim.new(0, 9)

local MainFrame = Instance.new("Frame", OuterBorder)
MainFrame.Size = UDim2.new(1, -4, 1, -4)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 7)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(30, 30, 35)

TweenService:Create(OuterBorder, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(145, 54)
}):Play()

local Glow = Instance.new("Frame", MainFrame)
Glow.ZIndex = 2
Glow.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Glow.BackgroundTransparency = 0.82
Glow.BorderSizePixel = 0
Glow.Size = UDim2.new(1, 0, 0, 2)

local function CreateLabel(text, pos)
    local lbl = Instance.new("TextLabel", MainFrame)
    lbl.ZIndex = 5
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -14, 0, 15)
    lbl.Position = pos
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = 12
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    return lbl
end

local Title = CreateLabel("HUTAO PERFORMANCE", UDim2.new(0, 7, 0, 3))
Title.Size = UDim2.new(1, 0, 0, 14)
local FPSLabel = CreateLabel("FPS  : LOADING...", UDim2.new(0, 7, 0, 19))
local PingLabel = CreateLabel("PING : LOADING...", UDim2.new(0, 7, 0, 34))

task.spawn(function()
    while true do
        local Particle = Instance.new("Frame", MainFrame)
        Particle.ZIndex = 1
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
            Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)

        FPSLabel.Text = "FPS  : " .. FPS
        FPSLabel.TextColor3 = (FPS >= 50 and Color3.fromRGB(0, 255, 120)) or (FPS >= 30 and Color3.fromRGB(255, 220, 0)) or Color3.fromRGB(255, 70, 70)

        PingLabel.Text = "PING : " .. Ping .. " MS"
        PingLabel.TextColor3 = (Ping <= 80 and Color3.fromRGB(0, 255, 120)) or (Ping <= 150 and Color3.fromRGB(255, 220, 0)) or Color3.fromRGB(255, 70, 70)
    end
end)
