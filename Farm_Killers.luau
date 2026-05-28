local Farm = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local PhysicsService = game:GetService("PhysicsService")
local PathfindingService = game:GetService("PathfindingService")
local LocalizationService = game:GetService("LocalizationService")
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)

getgenv().AutoKillerFarm = getgenv().AutoKillerFarm or false
getgenv().AutoFarmGen = getgenv().AutoFarmGen or false
getgenv().SafeModeGen = getgenv().SafeModeGen or false
getgenv().SafeRangeGen = getgenv().SafeRangeGen or 45

local killerThread
local generatorThread

local killerDelay = 0.12
local generatorDelay = 0.45

local function GetCharacter()
    return localPlayer.Character or localPlayer.CharacterAdded:Wait()
end

local function GetHRP(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(character)
    return character and character:FindFirstChildWhichIsA("Humanoid")
end

local function IsAlive(character)
    local humanoid = GetHumanoid(character)

    return humanoid and humanoid.Health > 0
end

local function IsKillerNear(position)
    if not getgenv().SafeModeGen then
        return false
    end

    local range = getgenv().SafeRangeGen

    for _, killer in ipairs(killersFolder:GetChildren()) do
        local hrp = GetHRP(killer)

        if hrp and (hrp.Position - position).Magnitude <= range then
            return true
        end
    end

    return false
end

local function GetNearestSurvivor(myHRP, character)
    local nearest
    local nearestDistance = math.huge

    local myPos = myHRP.Position

    for _, survivor in ipairs(survivorsFolder:GetChildren()) do
        if survivor ~= character and survivor:IsA("Model") and IsAlive(survivor) then
            local hrp = GetHRP(survivor)

            if hrp then
                local distance = (hrp.Position - myPos).Magnitude

                if distance < nearestDistance then
                    nearestDistance = distance
                    nearest = hrp
                end
            end
        end
    end

    return nearest
end

function Farm.StartKillerFarm()
    if killerThread then
        return
    end

    killerThread = task.spawn(function()
        local lastTeleport = 0

        while getgenv().AutoKillerFarm do
            local now = tick()

            if now - lastTeleport >= killerDelay then
                lastTeleport = now

                local character = GetCharacter()

                if character
                and character:IsDescendantOf(killersFolder)
                and IsAlive(character)
                then
                    local hrp = GetHRP(character)

                    if hrp then
                        local nearest = GetNearestSurvivor(hrp, character)

                        if nearest then
                            hrp.CFrame = nearest.CFrame * CFrame.new(0,0,3)
                        end
                    end
                end
            end

            task.wait(0.03)
        end

        killerThread = nil
    end)
end

function Farm.StopKillerFarm()
    getgenv().AutoKillerFarm = false
    killerThread = nil
end

local CachedMap
local CachedGenerators = {}

local function UpdateGeneratorCache()
    table.clear(CachedGenerators)

    local mapContainer = Workspace:FindFirstChild("Map")
    local ingame = mapContainer and mapContainer:FindFirstChild("Ingame")

    CachedMap = ingame and ingame:FindFirstChild("Map")

    if not CachedMap then
        return
    end

    for _, gen in ipairs(CachedMap:GetChildren()) do
        if gen.Name == "Generator" then
            CachedGenerators[#CachedGenerators + 1] = gen
        end
    end
end

local function GetClosestGenerator(hrp)
    local closest
    local closestDistance = math.huge

    local myPos = hrp.Position

    for i = 1, #CachedGenerators do
        local gen = CachedGenerators[i]

        local progress = gen:FindFirstChild("Progress")

        if progress and progress.Value < 100 then
            local genPart =
                gen.PrimaryPart
                or gen:FindFirstChildWhichIsA("BasePart")

            if genPart and not IsKillerNear(genPart.Position) then
                local distance = (genPart.Position - myPos).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closest = gen
                end
            end
        end
    end

    return closest
end

function Farm.StartGeneratorFarm()
    if generatorThread then
        return
    end

    generatorThread = task.spawn(function()
        local lastPosition
        local currentGen

        UpdateGeneratorCache()

        while getgenv().AutoFarmGen do
            local character = GetCharacter()

            if character
            and character:IsDescendantOf(survivorsFolder)
            and IsAlive(character)
            then
                local hrp = GetHRP(character)

                if hrp then
                    if not CachedMap or not CachedMap.Parent then
                        UpdateGeneratorCache()
                    end

                    local gen = GetClosestGenerator(hrp)

                    if gen then
                        local genPart =
                            gen.PrimaryPart
                            or gen:FindFirstChildWhichIsA("BasePart")

                        if genPart then
                            local shouldTeleport = true

                            if lastPosition and currentGen == gen then
                                if (hrp.Position - lastPosition.Position).Magnitude < 2.5 then
                                    shouldTeleport = false
                                end
                            end

                            if shouldTeleport then
                                local offsets = {
                                    Vector3.new(0,0,-6),
                                    Vector3.new(6,0,0),
                                    Vector3.new(-6,0,0)
                                }

                                for i = 1, #offsets do
                                    local posCF = genPart.CFrame * CFrame.new(offsets[i])
                                    local pos = posCF.Position

                                    local occupied = false

                                    for _, survivor in ipairs(survivorsFolder:GetChildren()) do
                                        if survivor ~= character then
                                            local sHRP = GetHRP(survivor)

                                            if sHRP and (sHRP.Position - pos).Magnitude < 2.5 then
                                                occupied = true
                                                break
                                            end
                                        end
                                    end

                                    if not occupied and not IsKillerNear(pos) then
                                        hrp.CFrame = posCF
                                        lastPosition = posCF
                                        currentGen = gen
                                        break
                                    end
                                end
                            end

                            local main = gen:FindFirstChild("Main")

                            if main then
                                local prompt = main:FindFirstChild("Prompt")

                                if prompt and prompt:IsA("ProximityPrompt") then
                                    pcall(function()
                                        prompt.HoldDuration = 0
                                        fireproximityprompt(prompt)
                                    end)
                                end
                            end
                        end
                    end
                end
            end

            task.wait(generatorDelay)
        end

        generatorThread = nil
    end)
end

function Farm.StopGeneratorFarm()
    getgenv().AutoFarmGen = false
    generatorThread = nil
end

getgenv().AutoUseAllSkills =
    getgenv().AutoUseAllSkills or true

getgenv().AutoAbilityEnabled =
    getgenv().AutoAbilityEnabled or false

getgenv().AutoAbilityRange =
    getgenv().AutoAbilityRange or 25

getgenv().AutoRagingPace =
    getgenv().AutoRagingPace or false

getgenv().AutoPizzaDelivery =
    getgenv().AutoPizzaDelivery or false

getgenv().Auto404Error =
    getgenv().Auto404Error or false

getgenv().AutoUnstableEye =
    getgenv().AutoUnstableEye or false

getgenv().AutoBloodHunt =
    getgenv().AutoBloodHunt or false

local AbilityButtons = {
    "Carving Slash",
    "Slash",
    "Punch",
    "Stab"
}

local LastSkillUse = {}

local GLOBAL_SKILL_DELAY = 0.15
local BUTTON_COOLDOWN = 0.35
local AUTO_ALL_SKILL_RANGE = 5

local AutoSkillThread

local function IsKiller()
    local character = GetCharacter()

    return character
    and character.Parent == killersFolder
end

local function HasSurvivorInRange(range)
    local character = GetCharacter()

    if not character then
        return false
    end

    local myRoot = GetHRP(character)

    if not myRoot then
        return false
    end

    local myPos = myRoot.Position

    for _, survivor in ipairs(
        survivorsFolder:GetChildren()
    ) do
        if survivor ~= character then

            local root = GetHRP(survivor)

            if root then
                if (root.Position - myPos).Magnitude <= range then
                    return true
                end
            end
        end
    end

    return false
end

local function CanUseButton(btn)
    if not btn
    or not btn.Parent
    or not btn.Visible
    or not btn.Active
    then
        return false
    end

    local now = tick()

    local last =
        LastSkillUse[btn] or 0

    if now - last < BUTTON_COOLDOWN then
        return false
    end

    LastSkillUse[btn] = now

    return true
end

local function FireButton(btn)
    if not CanUseButton(btn) then
        return
    end

    pcall(function()
        btn:Activate()
    end)
end

local function HandleAutoAllSkills(container)
    if not getgenv().AutoUseAllSkills then
        return
    end

    if not HasSurvivorInRange(
        AUTO_ALL_SKILL_RANGE
    ) then
        return
    end

    local children =
        container:GetChildren()

    for i = 1, #children do
        local obj = children[i]

        if obj
        and (
            obj:IsA("TextButton")
            or obj:IsA("ImageButton")
        ) then

            FireButton(obj)

            task.wait(0.04)
        end
    end
end

local function HandleAttackSkills(container)
    if not getgenv().AutoAbilityEnabled then
        return
    end

    if not HasSurvivorInRange(
        getgenv().AutoAbilityRange
    ) then
        return
    end

    for i = 1, #AbilityButtons do
        local btn =
            container:FindFirstChild(
                AbilityButtons[i]
            )

        if btn
        and (
            btn:IsA("TextButton")
            or btn:IsA("ImageButton")
        ) then

            FireButton(btn)

            task.wait(0.04)
        end
    end
end

local function HandleExtraSkills(container)
    local ExtraAbilities = {
        RagingPace = getgenv().AutoRagingPace,
        PizzaDelivery = getgenv().AutoPizzaDelivery,
        ["404Error"] = getgenv().Auto404Error,
        UnstableEye = getgenv().AutoUnstableEye,
        BloodHunt = getgenv().AutoBloodHunt
    }

    for name, enabled in pairs(
        ExtraAbilities
    ) do
        if enabled then

            local btn =
                container:FindFirstChild(name)

            if btn
            and (
                btn:IsA("TextButton")
                or btn:IsA("ImageButton")
            ) then

                FireButton(btn)

                task.wait(0.04)
            end
        end
    end
end

local function StartAutoSkillLoop()
    if AutoSkillThread then
        return
    end

    AutoSkillThread = task.spawn(function()

        while true do

            local canRun =
                IsKiller()

            local playerGui =
                localPlayer:FindFirstChild(
                    "PlayerGui"
                )

            local mainUI =
                playerGui
                and playerGui:FindFirstChild(
                    "MainUI"
                )

            local container =
                mainUI
                and mainUI:FindFirstChild(
                    "AbilityContainer"
                )

            if canRun and container then

                HandleAutoAllSkills(container)

                HandleAttackSkills(container)

                HandleExtraSkills(container)
            end

            task.wait(GLOBAL_SKILL_DELAY)
        end
    end)
end

StartAutoSkillLoop()