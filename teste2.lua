--  🇧🇷 LIPE HUB 
-- Proteção contra erros de execução
getgenv().SecureMode = true 

-- Limpeza de efeitos antigos
pcall(function()
    if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Death") then
        game:GetService("ReplicatedStorage").Effect.Container.Death:Destroy()
    end
    if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Respawn") then
        game:GetService("ReplicatedStorage").Effect.Container.Respawn:Destroy()
    end
end)

-- [[ 1. CONFIGURAÇÕES E VARIÁVEIS ]] --
_G.Settings = {
    Main = {
        ["Auto Farm Level"] = false,
        ["Fast Auto Farm Level"] = false,
        ["Distance Mob Aura"] = 1000, 
        ["Mob Aura"] = false,
        ["Auto Saber"] = false,
        ["Auto Pole"] = false,
    },
    Configs = {
        ["Fast Attack"] = true,
        ["Fast Attack Type"] = {"Fast"},
        ["Select Weapon"] = {},
        ["Auto Haki"] = true,
        ["Bring Mob"] = true,
        ["Bypass TP"] = false,
    }
}

-- [[ 2. FUNÇÕES ESSENCIAIS (PRESERVADAS) ]] --
local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]
local RigController = require(game:GetService("Players")["LocalPlayer"].PlayerScripts.CombatFramework.RigController)
local RigControllerR = getupvalues(RigController)[2]
local cooldownfastattack = tick()

function getAllBladeHits(Sizes)
    local Hits = {}
    local Client = game.Players.LocalPlayer
    local Enemies = game:GetService("Workspace").Enemies:GetChildren()
    for i=1,#Enemies do local v = Enemies[i]
        local Human = v:FindFirstChildOfClass("Humanoid")
        if Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 then
            table.insert(Hits,Human.RootPart)
        end
    end
    return Hits
end

function CurrentWeapon()
    local ac = CombatFrameworkR.activeController
    local ret = ac.blades[1]
    if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    pcall(function()
        while ret.Parent~=game.Players.LocalPlayer.Character do ret=ret.Parent end
    end)
    if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    return ret
end

function AttackFunction()
    local ac = CombatFrameworkR.activeController
    if ac and ac.equipped then
        for indexincrement = 1, 1 do
            local bladehit = getAllBladeHits(60)
            if #bladehit > 0 then
                local AcAttack8 = debug.getupvalue(ac.attack, 5)
                local AcAttack9 = debug.getupvalue(ac.attack, 6)
                local AcAttack7 = debug.getupvalue(ac.attack, 4)
                local AcAttack10 = debug.getupvalue(ac.attack, 7)
                local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
                local NumberAc13 = AcAttack7 * 798405
                (function()
                    NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
                    AcAttack8 = math.floor(NumberAc12 / AcAttack9)
                    AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
                end)()
                AcAttack10 = AcAttack10 + 1
                debug.setupvalue(ac.attack, 5, AcAttack8)
                debug.setupvalue(ac.attack, 6, AcAttack9)
                debug.setupvalue(ac.attack, 4, AcAttack7)
                debug.setupvalue(ac.attack, 7, AcAttack10)
                for k, v in pairs(ac.animator.anims.basic) do
                    v:Play(0.01,0.01,0.01)
                end                 
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
                    game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
                end
            end
        end
    end
end

-- Configuração de Spawns (Crucial para o Farm)
local EnemySpawns = Instance.new("Folder",workspace)
EnemySpawns.Name = "EnemySpawns"
for i, v in pairs(workspace._WorldOrigin.EnemySpawns:GetChildren()) do
    if v:IsA("Part") then
        local EnemySpawnsX2 = v:Clone()
        local result = string.gsub(v.Name, "Lv. ", "")
        local result2 = string.gsub(result, "[%[%]]", "")
        local result3 = string.gsub(result2, "%d+", "")
        local result4 = string.gsub(result3, "%s+", "")
        EnemySpawnsX2.Name = result4
        EnemySpawnsX2.Parent = workspace.EnemySpawns
        EnemySpawnsX2.Anchored = true
    end
end

-- Função QuestCheck (Lógica Principal de Nível)
local function QuestCheck()
    local Lvl = game:GetService("Players").LocalPlayer.Data.Level.Value
    local MobName, QuestName, QuestLevel, Mon, NPCPosition, LevelRequire, MobCFrame
    
    -- Lógica Simplificada baseada no seu código para garantir funcionamento
    local GuideModule = require(game:GetService("ReplicatedStorage").GuideModule)
    for i,v in pairs(GuideModule["Data"]["NPCList"]) do
        for i1,v1 in pairs(v["Levels"]) do
            if Lvl >= v1 then
                if not LevelRequire then LevelRequire = 0 end
                if v1 > LevelRequire then
                    NPCPosition = i["CFrame"]
                    QuestLevel = i1
                    LevelRequire = v1
                end
            end
        end
    end

    -- Recupera info da quest atual
    local Quests = require(game:GetService("ReplicatedStorage").Quests)
    for i,v in pairs(Quests) do
        for i1,v1 in pairs(v) do
            if v1["LevelReq"] == LevelRequire and i ~= "CitizenQuest" then
                QuestName = i
                for i2,v2 in pairs(v1["Task"]) do
                    MobName = i2
                    Mon = string.split(i2," [Lv. ".. v1["LevelReq"] .. "]")[1]
                end
            end
        end
    end
    
    -- Ajuste para Mobs específicos (Mantido do seu código)
    if QuestName == "MarineQuest2" then
        MobName = "Chief Petty Officer [Lv. 120]"; Mon = "Chief Petty Officer"
    elseif QuestName == "ImpelQuest" then
        MobName = "Dangerous Prisoner [Lv. 190]"; Mon = "Dangerous Prisoner"
        NPCPosition = CFrame.new(5310.60547, 0.350014925, 474.946594)
    end
    
    -- Busca CFrame do Mob
    local matchingCFrames = {}
    if MobName then
        local result = string.gsub(MobName, "Lv. ", "")
        local result2 = string.gsub(result, "[%[%]]", "")
        local result3 = string.gsub(result2, "%d+", "")
        local result4 = string.gsub(result3, "%s+", "")
        for i,v in pairs(game.workspace.EnemySpawns:GetChildren()) do
            if v.Name == result4 then
                table.insert(matchingCFrames, v.CFrame)
            end
        end
    end
    
    return {QuestLevel, NPCPosition, MobName, QuestName, LevelRequire, Mon, matchingCFrames}
end

-- Função de Movimento e Bypass
function toTarget(Pos)
    if not Pos then return end
    local RealTarget = (typeof(Pos) == "CFrame") and Pos or CFrame.new(Pos)
    local Distance = (RealTarget.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local Speed = Distance < 1000 and 315 or 300
    
    local tween = game:GetService("TweenService"):Create(
        game.Players.LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),
        {CFrame = RealTarget}
    )
    tween:Play()
    return tween
end

function InMyNetWork(object)
    if isnetworkowner then return isnetworkowner(object) end
    return (object.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 350
end

-- [[ 3. INTERFACE RAYFIELD (NOVA GUI) ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silver Hub | Rayfield",
   LoadingTitle = "Carregando Script...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = true, FolderName = "SilverHubConfig", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   KeySystem = false,
})

Rayfield:Notify({
   Title = "Sucesso!",
   Content = "Script carregado. Use com moderação.",
   Duration = 5,
   Image = 4483362458,
})

-- ABAS
local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)

-- ELEMENTOS MAIN
MainTab:CreateSection("Farm Principal")

MainTab:CreateToggle({
   Name = "Auto Farm Level",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
       _G.AutoFarmLevelReal = Value
       _G.Settings.Main["Auto Farm Level"] = Value
       if not Value then
           -- Para o tween se desativar
           if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(0.5), {CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame}):Play()
           end
       end
   end,
})

MainTab:CreateDropdown({
   Name = "Selecionar Arma",
   Options = {"Melee", "Sword", "Fruit"},
   CurrentOption = {"Melee"},
   Callback = function(Option)
       SelectWeapon = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "Bring Mobs (Puxar Monstros)",
   CurrentValue = true,
   Callback = function(Value)
       BringMobFarm = Value
       _G.Settings.Configs["Bring Mob"] = Value
   end,
})

-- ELEMENTOS COMBATE
CombatTab:CreateSection("Ataque")

CombatTab:CreateToggle({
   Name = "Fast Attack",
   CurrentValue = true,
   Callback = function(Value)
       _G.Settings.Configs["Fast Attack"] = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Auto Haki",
   CurrentValue = true,
   Callback = function(Value)
       _G.Settings.Configs["Auto Haki"] = Value
   end,
})

-- [[ 4. LOOPS DE LÓGICA (DO SEU CÓDIGO) ]] --

-- Loop Principal de Farm
spawn(function()
    while wait() do 
        if _G.AutoFarmLevelReal then
            pcall(function()
                local Data = QuestCheck()
                local QuestLevel = Data[1]
                local NPCPos = Data[2]
                local MobName = Data[3]
                local QuestName = Data[4]
                local Mon = Data[6]
                local MobSpawns = Data[7]

                local Player = game.Players.LocalPlayer
                local QuestGUI = Player.PlayerGui.Main.Quest

                if QuestGUI.Visible == true then
                    -- Se já tem quest
                    if (NPCPos.Position - Player.Character.HumanoidRootPart.Position).Magnitude >= 3000 then
                        -- Bypass TP logic se necessário
                    end
                    
                    -- Procura o monstro
                    local found = false
                    for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if v.Name == MobName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            found = true
                            if string.find(QuestGUI.Container.QuestTitle.Title.Text, Mon) then
                                PosMon = v.HumanoidRootPart.CFrame
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(60,60,60)
                                if _G.Settings.Configs["Bring Mob"] then
                                    v.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                                end
                                toTarget(v.HumanoidRootPart.CFrame)
                                -- Equipa arma
                                pcall(function()
                                    local backpack = Player.Backpack:FindFirstChild(_G.Settings.Configs["Select Weapon"])
                                    if backpack then Player.Character.Humanoid:EquipTool(backpack) end
                                end)
                            else
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                            end
                        end
                    end
                    if not found and MobSpawns and #MobSpawns > 0 then
                        toTarget(MobSpawns[1])
                    end
                else
                    -- Pega a quest
                    toTarget(NPCPos)
                    if (NPCPos.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 10 then
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer("StartQuest", QuestName, QuestLevel)
                    end
                end
            end)
        end
    end
end)

-- Loop Fast Attack
coroutine.wrap(function()
    while task.wait(.1) do
        local ac = CombatFrameworkR.activeController
        if ac and ac.equipped then
            if _G.Settings.Configs["Fast Attack"] then
                AttackFunction()
                if tick() - cooldownfastattack > .9 then wait(.1) cooldownfastattack = tick() end
            end
        end
    end
end)()

-- Loop Weapon Update
task.spawn(function()
    while wait(1) do
        pcall(function()
            local toolTipMap = {Melee = "Melee", Sword = "Sword", Fruit = "Blox Fruit"}
            local desiredTip = toolTipMap[SelectWeapon] or "Melee"
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v.ToolTip == desiredTip then
                    _G.Settings.Configs["Select Weapon"] = v.Name
                end
            end
        end)
    end
end)

-- Loop Auto Haki
spawn(function()
    while wait(5) do
        if _G.Settings.Configs["Auto Haki"] then
            if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
            end
        end
    end
end)

Rayfield:LoadConfiguration()
