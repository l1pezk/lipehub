-- =====================================================
-- 🍌 BANANA CAT HUB - AUTO BOUNTY PROFISSIONAL
-- =====================================================
-- Versão: 3.0 | Estável | Otimizado | Silent Aim Integrado
-- =====================================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2)

-- =====================================================
-- 📦 SERVICES
-- =====================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- =====================================================
-- 🔧 CONFIGURAÇÕES GLOBAIS
-- =====================================================
getgenv().BananaCatHub = {
    -- Controles principais
    AUTO_BOUNTY = true,
    MIN_LEVEL = 2100,
    
    -- Sistema de combate
    USE_MELEE = true,
    USE_SWORD = true,
    USE_GUN = true,
    USE_FRUIT = false,
    
    -- Distâncias
    COMBAT_RANGE = 150,  -- Metros para começar a atacar
    CHASE_DISTANCE = 12,  -- Distância para manter durante perseguição
    SCAN_RANGE = 1000,    -- Alcance máximo para detectar players
    
    -- Timing
    TWEEEN_SPEED = 90,
    SKILL_DELAY = 0.25,
    DAMAGE_TIMEOUT = 8,   -- Segundos sem dano para trocar alvo
    
    -- Features
    SILENT_AIM = true,
    CAMERA_LOCK = true,
    AUTO_HOP = true,
    ANTI_SAFE_ZONE = true
}

-- =====================================================
-- 🔒 VARIÁVEIS DE ESTADO
-- =====================================================
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local TARGET = nil
local TARGET_DATA = nil
local IS_CHASING = false
local IS_ATTACKING = false
local ACTIVE_TWEEN = nil
local LAST_DAMAGE_TIME = 0
local TARGET_START_HP = nil
local LAST_SCAN_TIME = 0
local SCAN_COOLDOWN = 2

-- Silent Aim Variables
local SILENT_TARGET = nil
local SILENT_POSITION = nil

-- =====================================================
-- 🎨 SISTEMA DE UI PROFISSIONAL
-- =====================================================
local function CreateProfessionalUI()
    -- Remove UI antiga se existir
    if CoreGui:FindFirstChild("BananaCatHubUI") then
        CoreGui:FindFirstChild("BananaCatHubUI"):Destroy()
    end
    
    -- ScreenGui principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BananaCatHubUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 240)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -120)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Gradiente superior
    local TopGradient = Instance.new("UIGradient")
    TopGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0))
    })
    TopGradient.Rotation = 90
    
    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 0))
    })
    TitleGradient.Parent = TitleBar
    
    -- Título com ícone
    local Title = Instance.new("TextLabel")
    Title.Text = "🍌 BANANA CAT HUB | AUTO BOUNTY"
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Botão de fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -35, 0, 2)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar
    
    -- Conteúdo principal
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    ContentFrame.Position = UDim2.new(0, 10, 0, 50)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- Painel de status
    local StatusPanel = Instance.new("Frame")
    StatusPanel.Name = "StatusPanel"
    StatusPanel.Size = UDim2.new(1, 0, 0, 80)
    StatusPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StatusPanel.BorderSizePixel = 0
    StatusPanel.Parent = ContentFrame
    
    -- Status labels
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Text = "🟢 STATUS: READY"
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 10)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 14
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = StatusPanel
    
    local TargetLabel = Instance.new("TextLabel")
    TargetLabel.Name = "TargetLabel"
    TargetLabel.Text = "🎯 TARGET: NONE"
    TargetLabel.Size = UDim2.new(1, -20, 0, 25)
    TargetLabel.Position = UDim2.new(0, 10, 0, 35)
    TargetLabel.BackgroundTransparency = 1
    TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetLabel.Font = Enum.Font.Gotham
    TargetLabel.TextSize = 13
    TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
    TargetLabel.Parent = StatusPanel
    
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Name = "DistanceLabel"
    DistanceLabel.Text = "📏 DISTANCE: --m"
    DistanceLabel.Size = UDim2.new(1, -20, 0, 25)
    DistanceLabel.Position = UDim2.new(0, 10, 0, 60)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    DistanceLabel.Font = Enum.Font.Gotham
    DistanceLabel.TextSize = 13
    DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    DistanceLabel.Parent = StatusPanel
    
    -- Botões de controle
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "ControlsFrame"
    ControlsFrame.Size = UDim2.new(1, 0, 0, 50)
    ControlsFrame.Position = UDim2.new(0, 0, 0, 90)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Parent = ContentFrame
    
    -- Botão principal de toggle
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Text = "▶ START AUTO BOUNTY"
    ToggleButton.Size = UDim2.new(1, 0, 0, 40)
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 15
    ToggleButton.Parent = ControlsFrame
    
    -- Configurações rápidas
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Size = UDim2.new(1, 0, 0, 60)
    SettingsFrame.Position = UDim2.new(0, 0, 0, 150)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Parent = ContentFrame
    
    -- Toggles de arma
    local MeleeToggle = Instance.new("TextButton")
    MeleeToggle.Text = "🥊 MELEE: ON"
    MeleeToggle.Size = UDim2.new(0.48, 0, 0, 25)
    MeleeToggle.Position = UDim2.new(0, 0, 0, 0)
    MeleeToggle.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
    MeleeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MeleeToggle.Font = Enum.Font.Gotham
    MeleeToggle.TextSize = 12
    MeleeToggle.Parent = SettingsFrame
    
    local SwordToggle = Instance.new("TextButton")
    SwordToggle.Text = "🗡️ SWORD: ON"
    SwordToggle.Size = UDim2.new(0.48, 0, 0, 25)
    SwordToggle.Position = UDim2.new(0.52, 0, 0, 0)
    SwordToggle.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
    SwordToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SwordToggle.Font = Enum.Font.Gotham
    SwordToggle.TextSize = 12
    SwordToggle.Parent = SettingsFrame
    
    local GunToggle = Instance.new("TextButton")
    GunToggle.Text = "🔫 GUN: ON"
    GunToggle.Size = UDim2.new(0.48, 0, 0, 25)
    GunToggle.Position = UDim2.new(0, 0, 0, 30)
    GunToggle.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
    GunToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    GunToggle.Font = Enum.Font.Gotham
    GunToggle.TextSize = 12
    GunToggle.Parent = SettingsFrame
    
    local FruitToggle = Instance.new("TextButton")
    FruitToggle.Text = "🍎 FRUIT: OFF"
    FruitToggle.Size = UDim2.new(0.48, 0, 0, 25)
    FruitToggle.Position = UDim2.new(0.52, 0, 0, 30)
    FruitToggle.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
    FruitToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FruitToggle.Font = Enum.Font.Gotham
    FruitToggle.TextSize = 12
    FruitToggle.Parent = SettingsFrame
    
    -- Sistema de drag
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Handlers de botões
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        getgenv().BananaCatHub.AUTO_BOUNTY = false
    end)
    
    ToggleButton.MouseButton1Click:Connect(function()
        getgenv().BananaCatHub.AUTO_BOUNTY = not getgenv().BananaCatHub.AUTO_BOUNTY
        
        if getgenv().BananaCatHub.AUTO_BOUNTY then
            ToggleButton.Text = "⏹ STOP AUTO BOUNTY"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            StatusLabel.Text = "🟡 STATUS: STARTING..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        else
            ToggleButton.Text = "▶ START AUTO BOUNTY"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            StatusLabel.Text = "🔴 STATUS: STOPPED"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            TARGET = nil
            SILENT_TARGET = nil
        end
    end)
    
    MeleeToggle.MouseButton1Click:Connect(function()
        getgenv().BananaCatHub.USE_MELEE = not getgenv().BananaCatHub.USE_MELEE
        MeleeToggle.Text = "🥊 MELEE: " .. (getgenv().BananaCatHub.USE_MELEE and "ON" or "OFF")
        MeleeToggle.BackgroundColor3 = getgenv().BananaCatHub.USE_MELEE and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
    end)
    
    SwordToggle.MouseButton1Click:Connect(function()
        getgenv().BananaCatHub.USE_SWORD = not getgenv().BananaCatHub.USE_SWORD
        SwordToggle.Text = "🗡️ SWORD: " .. (getgenv().BananaCatHub.USE_SWORD and "ON" or "OFF")
        SwordToggle.BackgroundColor3 = getgenv().BananaCatHub.USE_SWORD and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
    end)
    
    GunToggle.MouseButton1Click:Connect(function()
        getgenv().BananaCatHub.USE_GUN = not getgenv().BananaCatHub.USE_GUN
        GunToggle.Text = "🔫 GUN: " .. (getgenv().BananaCatHub.USE_GUN and "ON" or "OFF")
        GunToggle.BackgroundColor3 = getgenv().BananaCatHub.USE_GUN and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
    end)
    
    FruitToggle.MouseButton1Click:Connect(function()
        getgenv().BananaCatHub.USE_FRUIT = not getgenv().BananaCatHub.USE_FRUIT
        FruitToggle.Text = "🍎 FRUIT: " .. (getgenv().BananaCatHub.USE_FRUIT and "ON" or "OFF")
        FruitToggle.BackgroundColor3 = getgenv().BananaCatHub.USE_FRUIT and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 60, 60)
    end)
    
    return {
        Gui = ScreenGui,
        StatusLabel = StatusLabel,
        TargetLabel = TargetLabel,
        DistanceLabel = DistanceLabel,
        ToggleButton = ToggleButton
    }
end

-- =====================================================
-- 🎯 SISTEMA DE SILENT AIM (INTEGRADO)
-- =====================================================
local function SetupSilentAim()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    -- Variáveis do silent aim
    getgenv().setting = {
        LockPlayers = false,
        LockPlayersBind = Enum.KeyCode.L,
        resetPlayersBind = Enum.KeyCode.P,
    }
    
    Playersaimbot = nil
    PlayersPosition = nil
    
    -- Função para pegar player mais próximo
    local function getClosestPlayer(maxDistance)
        local closestPlayer = nil
        local shortestDistance = maxDistance or 400
        
        if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        
        local myPos = localPlayer.Character.HumanoidRootPart.Position
        
        for _, v in pairs(players:GetPlayers()) do
            if v ~= localPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (v.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist <= shortestDistance then
                    shortestDistance = dist
                    closestPlayer = v
                end
            end
        end
        
        return closestPlayer
    end
    
    -- Loop de seleção do silent aim
    task.spawn(function()
        while task.wait(0.1) do
            if getgenv().BananaCatHub.SILENT_AIM and getgenv().BananaCatHub.AUTO_BOUNTY then
                local target = getClosestPlayer(400)
                if target then
                    Playersaimbot = target.Name
                    PlayersPosition = target.Character.HumanoidRootPart.Position
                else
                    Playersaimbot = nil
                    PlayersPosition = nil
                end
            else
                Playersaimbot = nil
                PlayersPosition = nil
            end
        end
    end)
    
    -- Hook do silent aim
    task.spawn(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(...)
            local method = getnamecallmethod()
            local args = {...}
            
            if tostring(method) == "FireServer" then
                if tostring(args[1]) == "RemoteEvent" then
                    if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                        if Playersaimbot and PlayersPosition then
                            args[2] = PlayersPosition
                            return old(unpack(args))
                        end
                    end
                end
            end
            
            return old(...)
        end)
        
        setreadonly(mt, true)
    end)
end

-- =====================================================
-- 🔧 FUNÇÕES UTILITÁRIAS AVANÇADAS
-- =====================================================
local function GetPlayerLevel(player)
    if player and player:FindFirstChild("Data") then
        local data = player.Data
        if data:FindFirstChild("Level") then
            return data.Level.Value
        end
    end
    return 0
end

local function IsPlayerAlive(player)
    if not player or not player.Character then
        return false
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    
    return humanoid and humanoid.Health > 0 and hrp ~= nil
end

local function IsInSafeZone(player)
    if not player.Character then return true end
    
    -- Verifica ForceField (safe zone comum)
    if player.Character:FindFirstChild("ForceField") then
        return true
    end
    
    -- Verifica posições de safe zones conhecidas
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    
    local safeZones = {
        Vector3.new(-1086.68, 4.89, 1507.58),  -- Starter Island
        Vector3.new(1019.18, 14.49, 1492.11),   -- Marine Starter
        Vector3.new(-1252.83, 12.88, 336.94),   -- Pirate Starter
        Vector3.new(0, 0, 0)                    -- Add more as needed
    }
    
    for _, safePos in ipairs(safeZones) do
        if (hrp.Position - safePos).Magnitude < 50 then
            return true
        end
    end
    
    return false
end

local function GetDistanceToTarget(target)
    if not IsPlayerAlive(LP) or not IsPlayerAlive(target) then
        return math.huge
    end
    
    local myPos = LP.Character.HumanoidRootPart.Position
    local targetPos = target.Character.HumanoidRootPart.Position
    
    return (myPos - targetPos).Magnitude
end

-- =====================================================
-- 🔍 SISTEMA DE DETECÇÃO DE ALVOS (INTELIGENTE)
-- =====================================================
local function ScanForValidTargets()
    local validTargets = {}
    local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
    
    if not myPos then return validTargets end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LP then continue end
        
        if not IsPlayerAlive(player) then continue end
        
        if getgenv().BananaCatHub.ANTI_SAFE_ZONE and IsInSafeZone(player) then
            continue
        end
        
        local level = GetPlayerLevel(player)
        if level < getgenv().BananaCatHub.MIN_LEVEL then
            continue
        end
        
        local distance = GetDistanceToTarget(player)
        if distance > getgenv().BananaCatHub.SCAN_RANGE then
            continue
        end
        
        table.insert(validTargets, {
            Player = player,
            Level = level,
            Distance = distance,
            HRP = player.Character.HumanoidRootPart
        })
    end
    
    -- Ordena por proximidade
    table.sort(validTargets, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return validTargets
end

-- =====================================================
## 🌀 SISTEMA DE MOVIMENTAÇÃO AVANÇADO (TWEEN)
## =====================================================
local function AdvancedChaseTarget(target)
    if not target or not IsPlayerAlive(target) then
        IS_CHASING = false
        if ACTIVE_TWEEN then
            ACTIVE_TWEEN:Cancel()
            ACTIVE_TWEEN = nil
        end
        return false
    end
    
    local targetHRP = target.Character.HumanoidRootPart
    if not targetHRP then return false end
    
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end
    
    -- Calcula posição ideal (atrás/acima do alvo)
    local targetPos = targetHRP.Position
    local myPos = myHRP.Position
    local direction = (targetPos - myPos).Unit
    
    -- Posição final mantendo distância de segurança
    local chasePos = targetPos - (direction * getgenv().BananaCatHub.CHASE_DISTANCE)
    chasePos = Vector3.new(chasePos.X, chasePos.Y + 5, chasePos.Z)
    
    -- Cancela tween anterior se existir
    if ACTIVE_TWEEN then
        ACTIVE_TWEEN:Cancel()
        ACTIVE_TWEEN = nil
    end
    
    -- Cálculo dinâmico de tempo baseado na distância
    local distance = (myPos - chasePos).Magnitude
    local tweenTime = math.max(0.2, math.min(1.2, distance / getgenv().BananaCatHub.TWEEEN_SPEED))
    
    -- Tween info suave
    local tweenInfo = TweenInfo.new(
        tweenTime,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0, false, 0
    )
    
    -- Cria e executa o tween
    ACTIVE_TWEEN = TweenService:Create(myHRP, tweenInfo, {CFrame = CFrame.new(chasePos)})
    IS_CHASING = true
    
    ACTIVE_TWEEN.Completed:Connect(function()
        IS_CHASING = false
        ACTIVE_TWEEN = nil
    end)
    
    ACTIVE_TWEEN:Play()
    
    return true
end

-- =====================================================
-- ⚔️ SISTEMA DE COMBATE MULTI-STYLE
-- =====================================================
local function EquipWeapon(weaponType)
    local character = LP.Character
    if not character then return nil end
    
    -- Procura no character
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local tip = tool.ToolTip or ""
            if weaponType == "Melee" and tip:find("Melee") then return tool
            elseif weaponType == "Sword" and tip:find("Sword") then return tool
            elseif weaponType == "Gun" and tip:find("Gun") then return tool
            elseif weaponType == "Fruit" and tip:find("Blox Fruit") then return tool
            end
        end
    end
    
    -- Procura na mochila
    local backpack = LP.Backpack
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local tip = tool.ToolTip or ""
                if weaponType == "Melee" and tip:find("Melee") then
                    tool.Parent = character
                    task.wait(0.1)
                    return tool
                elseif weaponType == "Sword" and tip:find("Sword") then
                    tool.Parent = character
                    task.wait(0.1)
                    return tool
                elseif weaponType == "Gun" and tip:find("Gun") then
                    tool.Parent = character
                    task.wait(0.1)
                    return tool
                elseif weaponType == "Fruit" and tip:find("Blox Fruit") then
                    tool.Parent = character
                    task.wait(0.1)
                    return tool
                end
            end
        end
    end
    
    return nil
end

local function ExecuteAttackSequence()
    IS_ATTACKING = true
    
    -- Sequência de ataques baseada nas configurações
    local attackOrder = {}
    if getgenv().BananaCatHub.USE_MELEE then table.insert(attackOrder, "Melee") end
    if getgenv().BananaCatHub.USE_SWORD then table.insert(attackOrder, "Sword") end
    if getgenv().BananaCatHub.USE_GUN then table.insert(attackOrder, "Gun") end
    if getgenv().BananaCatHub.USE_FRUIT then table.insert(attackOrder, "Fruit") end
    
    -- Skills para usar
    local skills = {"Z", "X", "C", "V", "F"}
    
    for _, weaponType in ipairs(attackOrder) do
        if not getgenv().BananaCatHub.AUTO_BOUNTY then break end
        
        local tool = EquipWeapon(weaponType)
        if tool then
            -- Executa todas as skills
            for _, skillKey in ipairs(skills) do
                if not getgenv().BananaCatHub.AUTO_BOUNTY then break end
                
                -- Pressiona a tecla da skill
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[skillKey], false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[skillKey], false, game)
                
                -- Delay configurável entre skills
                task.wait(getgenv().BananaCatHub.SKILL_DELAY)
            end
        end
    end
    
    IS_ATTACKING = false
end

-- =====================================================
## 🧪 SISTEMA DE VERIFICAÇÃO DE DANO (ANTI-FAKE)
## =====================================================
local function IsTargetTakingDamage()
    if not TARGET or not IsPlayerAlive(TARGET) then
        return false
    end
    
    local currentHP = TARGET.Character.Humanoid.Health
    
    if not TARGET_START_HP then
        TARGET_START_HP = currentHP
        LAST_DAMAGE_TIME = tick()
        return true
    end
    
    if currentHP < TARGET_START_HP then
        TARGET_START_HP = currentHP
        LAST_DAMAGE_TIME = tick()
        return true
    end
    
    -- Verifica timeout de dano
    if tick() - LAST_DAMAGE_TIME > getgenv().BananaCatHub.DAMAGE_TIMEOUT then
        return false
    end
    
    return true
end

-- =====================================================
-- 📷 SISTEMA CAMERA LOCK
-- =====================================================
local function UpdateCameraLock()
    if not getgenv().BananaCatHub.CAMERA_LOCK or not TARGET or not IsPlayerAlive(TARGET) then
        return
    end
    
    local targetHRP = TARGET.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    Camera.CFrame = CFrame.new(
        Camera.CFrame.Position,
        targetHRP.Position
    )
end

-- =====================================================
-- 🌍 SISTEMA DE SERVER HOP INTELIGENTE
-- =====================================================
local function IntelligentServerHop()
    local validTargets = ScanForValidTargets()
    
    if #validTargets == 0 and getgenv().BananaCatHub.AUTO_HOP then
        print("[BANANA CAT HUB] Server vazio de alvos válidos, executando hop...")
        
        task.spawn(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
        
        return true
    end
    
    return false
end

-- =====================================================
-- 🔄 LOOP PRINCIPAL DO AUTO BOUNTY
-- =====================================================
local function MainBountyLoop(UI)
    while true do
        task.wait(0.1)
        
        -- Verifica se o Auto Bounty está ativado
        if not getgenv().BananaCatHub.AUTO_BOUNTY then
            UI.StatusLabel.Text = "🔴 STATUS: PAUSED"
            UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            TARGET = nil
            goto continue
        end
        
        -- Verifica se o player local está vivo
        if not IsPlayerAlive(LP) then
            UI.StatusLabel.Text = "💀 STATUS: DEAD - WAITING RESPAWN"
            UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
            UI.TargetLabel.Text = "🎯 TARGET: NONE"
            goto continue
        end
        
        -- Sistema de seleção de alvo
        if not TARGET then
            local validTargets = ScanForValidTargets()
            
            if #validTargets == 0 then
                UI.StatusLabel.Text = "🟡 STATUS: NO VALID TARGETS"
                UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                UI.TargetLabel.Text = "🎯 TARGET: NONE"
                
                -- Executa server hop se necessário
                if IntelligentServerHop() then
                    task.wait(5)
                end
                
                goto continue
            end
            
            -- Seleciona o target mais próximo
            local targetData = validTargets[1]
            TARGET = targetData.Player
            TARGET_DATA = targetData
            TARGET_START_HP = TARGET.Character.Humanoid.Health
            LAST_DAMAGE_TIME = tick()
            
            UI.StatusLabel.Text = "🟡 STATUS: TARGET LOCKED"
            UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
            UI.TargetLabel.Text = "🎯 TARGET: " .. TARGET.Name .. " (Lv." .. targetData.Level .. ")"
        end
        
        -- Verifica se o target atual ainda é válido
        if not IsPlayerAlive(TARGET) or IsInSafeZone(TARGET) then
            UI.StatusLabel.Text = "🟡 STATUS: TARGET INVALID - SWITCHING"
            UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            TARGET = nil
            TARGET_DATA = nil
            goto continue
        end
        
        -- Atualiza distância na UI
        local currentDistance = GetDistanceToTarget(TARGET)
        UI.DistanceLabel.Text = "📏 DISTANCE: " .. math.floor(currentDistance) .. "m"
        
        -- Sistema de perseguição
        if AdvancedChaseTarget(TARGET) then
            -- Verifica distância para combate
            if currentDistance <= getgenv().BananaCatHub.COMBAT_RANGE then
                UI.StatusLabel.Text = "🔴 STATUS: ATTACKING"
                UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                
                -- Executa sequência de ataques
                if not IS_ATTACKING then
                    ExecuteAttackSequence()
                end
                
                -- Verifica se está causando dano
                if not IsTargetTakingDamage() then
                    UI.StatusLabel.Text = "🟡 STATUS: NO DAMAGE - SWITCHING TARGET"
                    UI.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                    TARGET = nil
                    TARGET_DATA = nil
                end
            else
                UI.StatusLabel.Text = "🟢 STATUS: CHASING TARGET"
                UI.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
        
        ::continue::
    end
end

-- =====================================================
-- 🚀 INICIALIZAÇÃO DO SISTEMA
-- =====================================================
print("==============================================")
print("🍌 BANANA CAT HUB - AUTO BOUNTY PROFISSIONAL")
print("==============================================")
print("👤 Player: " .. LP.Name)
print("🎯 Target Level: ≥ " .. getgenv().BananaCatHub.MIN_LEVEL)
print("📏 Combat Range: " .. getgenv().BananaCatHub.COMBAT_RANGE .. "m")
print("⚡ Silent Aim: " .. tostring(getgenv().BananaCatHub.SILENT_AIM))
print("📷 Camera Lock: " .. tostring(getgenv().BananaCatHub.CAMERA_LOCK))
print("🌍 Auto Hop: " .. tostring(getgenv().BananaCatHub.AUTO_HOP))
print("==============================================")

-- Setup do Silent Aim
SetupSilentAim()

-- Cria a UI
local UI = CreateProfessionalUI()

-- Inicia o Camera Lock
RunService.RenderStepped:Connect(UpdateCameraLock)

-- Inicia o loop principal
task.spawn(function()
    MainBountyLoop(UI)
end)

-- Sistema de respawn automático
LP.CharacterAdded:Connect(function()
    task.wait(3)
    if getgenv().BananaCatHub.AUTO_BOUNTY then
        UI.StatusLabel.Text = "🟢 STATUS: RESPAWNED - RESUMING"
        UI.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

print("✅ Sistema carregado com sucesso!")
print("🎮 Pressione o botão START para iniciar")