wait(3)

-- ╔══════════════════════════════════════════════════════════════╗
-- ║           🪓 ph4smo.club (nextgen) - Bite By Night          ║
-- ║                      by phasmoblade                          ║
-- ╚══════════════════════════════════════════════════════════════╝

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ═══════════════════════════════════════════════════════════════
-- 🎨 UI SETUP
-- ═══════════════════════════════════════════════════════════════

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowSize = isMobile and UDim2.fromOffset(400, 350) or UDim2.fromOffset(580, 460)

local Window = Fluent:CreateWindow({
    Title = "🪓 ph4smo.club (nextgen) - Bite By Night",
    SubTitle = "by phasmoblade",
    TabWidth = 160,
    Size = windowSize,
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.Home
})

if isMobile then
    Window:AddButton({
        Title = "Toggle GUI",
        Callback = function()
            Window:Minimize()
        end
    })
end

-- ═══════════════════════════════════════════════════════════════
-- 📑 TABS
-- ═══════════════════════════════════════════════════════════════

local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Survivor = Window:AddTab({ Title = "Survivor", Icon = "user" }),
    Killer = Window:AddTab({ Title = "Killer", Icon = "skull" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ═══════════════════════════════════════════════════════════════
-- 🔧 SERVICES & VARIABLES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CurrentCamera = workspace.CurrentCamera
local PlayerGui = LocalPlayer.PlayerGui

-- ═══════════════════════════════════════════════════════════════
-- 📊 PLAYER INFO
-- ═══════════════════════════════════════════════════════════════

local executor = "Unknown"
if identifyexecutor then
    executor = identifyexecutor()
elseif KRNL_LOADED then
    executor = "KRNL"
elseif syn then
    executor = "Synapse X"
elseif SENTINEL_LOADED then
    executor = "Sentinel"
elseif getexecutorname then
    executor = getexecutorname()
end

local platform = "Unknown"
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    platform = "Android/Mobile"
elseif UserInputService.KeyboardEnabled then
    platform = "Windows/PC"
end

local placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local placeId = tostring(game.PlaceId)
local jobId = game.JobId

Tabs.Info:AddParagraph({
    Title = "👤 Player Information",
    Content = "Username: " .. LocalPlayer.Name .. "\nDisplay Name: " .. LocalPlayer.DisplayName .. "\nUser ID: " .. tostring(LocalPlayer.UserId) .. "\nAccount Age: " .. tostring(LocalPlayer.AccountAge) .. " days"
})

Tabs.Info:AddParagraph({
    Title = "💻 System Information",
    Content = "Executor: " .. executor .. "\nPlatform: " .. platform .. "\nFPS: " .. tostring(math.floor(workspace:GetRealPhysicsFPS()))
})

Tabs.Info:AddParagraph({
    Title = "🎮 Place Information",
    Content = "Place Name: " .. placeName .. "\nPlace ID: " .. placeId .. "\nJob ID: " .. jobId
})

-- ═══════════════════════════════════════════════════════════════
-- ⚙️ SETTINGS & STORAGE
-- ═══════════════════════════════════════════════════════════════

local Settings = {
    SafeTeleport = true,
    RunBoost = 0,
    AutoGen = false,
    AutoEscape = false,
    AutoFarm = false,
    BypassSlowness = false,
    AlwaysRun = false,
    EnableJumping = false
}

local Connections = {}
local SafeTeleporting = false
local PrevTeam = nil

-- ESP Settings
local ESPSettings = {
    Survivor = {NameTags = false, Health = false, Chams = false},
    Killer = {NameTags = false, Health = false, Chams = false},
    Generator = {NameTags = false, Chams = false},
    Battery = {NameTags = false, Chams = false},
    Trap = {NameTags = false, Chams = false},
    Fusebox = {NameTags = false, Chams = false},
    Minion = {NameTags = false, Chams = false}
}

-- ESP Storage
local SurvivorNameTags, SurvivorChams, SurvivorHealthLabels = {}, {}, {}
local KillerNameTags, KillerChams, KillerHealthLabels = {}, {}, {}
local GeneratorNameTags, GeneratorChams = {}, {}
local BatteryNameTags, BatteryChams = {}, {}
local TrapNameTags, TrapChams = {}, {}
local FuseboxNameTags, FuseboxChams = {}, {}
local MinionNameTags, MinionChams = {}, {}

-- Anti Death Settings
local AntiDeath = {
    Enabled = false,
    Threshold = 30,
    LastPos = nil,
    Teleported = false,
    Debounce = false,
    Plate = nil
}

-- Auto Parry Settings
local AutoParrySettings = {
    Enabled = false,
    BasicRange = 15
}

local AttackAnimIds = {
    "rbxassetid://70869035406359",  -- Обычный удар 1
    "rbxassetid://106673226682917", -- Обычный удар 2
    "rbxassetid://112503015929213", -- Обычный удар 3
    "rbxassetid://120428956410756", -- Обычный удар 4
    "rbxassetid://102810363618918"  -- Обычный удар 5
}

-- Скиллы (игнорируются Auto Parry)
local SkillAnimIds = {
    "rbxassetid://133752270724243", -- Pull атака (скилл)
    "rbxassetid://71147082224885"   -- Другой скилл
}

-- Killer Settings
local KillerSettings = {
    HitboxExpander = false,
    HitboxSize = 15,
    NoStun = false,
    AutoKill = false,
    InfiniteStamina = false
}

-- Auto Kill Settings
local AutoKillSettings = {
    Enabled = false,
    LastAttack = 0,
    AttackCooldown = 0.5,
    MaxDistance = 300,
    SafeDistance = 4,
    InCutscene = false,
    CutsceneCheckDelay = 3
}

-- Safety Area
local SafetyAreaEnabled = false
local SafetyPart = nil
local SafetyOriginalPos = nil

-- ═══════════════════════════════════════════════════════════════
-- 🛠️ UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetTeam()
    local char = GetCharacter()
    return char and char:GetAttribute("Team")
end

local function TeleportCharacter(target, bypass)
    if SafeTeleporting then return end
    pcall(function()
        local char = GetCharacter()
        local root = char.PrimaryPart
        if not root then return end
        
        if Settings.SafeTeleport and not bypass then
            root.Anchored = true
            SafeTeleporting = true
            local startCF = root.CFrame
            local dist = (startCF.Position - target.Position).Magnitude
            local runSpeed = char:GetAttribute("RunSpeed") or 24
            local duration = dist / runSpeed
            local step = 0
            while step < duration do
                step = step + RunService.Heartbeat:Wait()
                root.CFrame = startCF:Lerp(target, math.clamp(step / duration, 0, 1))
            end
            root.CFrame = target
            root.Anchored = false
            SafeTeleporting = false
        else
            root.CFrame = target
        end
    end)
end

local function ToggleKiller(enabled)
    pcall(function()
        PlayerGui:WaitForChild("UI"):WaitForChild("Main"):WaitForChild("RemoteEvent"):FireServer("SettingChange", "DisableKiller", not enabled)
    end)
end

local function CreateESP(part, color, text)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = part
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Text = text
    textLabel.Parent = billboardGui
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            connection:Disconnect()
            if billboardGui and billboardGui.Parent then
                billboardGui:Destroy()
            end
            return
        end
        
        pcall(function()
            local char = GetCharacter()
            if char and char.PrimaryPart then
                local dist = (part.Position - char.PrimaryPart.Position).Magnitude
                textLabel.Text = text .. "\n" .. string.format("%.0f studs", dist)
            end
        end)
    end)
    
    return billboardGui, connection
end

local function CreatePlayerESP(part, color, name, showHealth)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = part
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Text = name
    textLabel.Parent = billboardGui
    
    local char = part.Parent
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            connection:Disconnect()
            if billboardGui and billboardGui.Parent then
                billboardGui:Destroy()
            end
            return
        end
        
        pcall(function()
            local myChar = GetCharacter()
            if not myChar or not myChar.PrimaryPart then return end
            
            -- Проверяем, что part все еще существует и имеет позицию
            if not part or not part.Position then return end
            
            -- Вычисляем расстояние с проверкой на NaN
            local dist = (part.Position - myChar.PrimaryPart.Position).Magnitude
            if dist ~= dist then dist = 0 end -- Проверка на NaN
            
            local displayText = name
            
            -- Проверяем здоровье с дополнительными проверками
            if showHealth then
                -- Обновляем ссылку на humanoid, если она устарела
                if not humanoid or not humanoid.Parent then
                    humanoid = char and char:FindFirstChildOfClass("Humanoid")
                end
                
                if humanoid and humanoid.Health and humanoid.Health > 0 then
                    local hp = math.floor(humanoid.Health)
                    local maxHp = math.floor(humanoid.MaxHealth or 100)
                    displayText = name .. " [" .. hp .. "/" .. maxHp .. "]"
                end
            end
            
            -- Обновляем текст с расстоянием
            textLabel.Text = displayText .. "\n" .. string.format("%.0f studs", math.floor(dist))
        end)
    end)
    
    return billboardGui, connection
end

local function CreateHealthLabel(char)
    if not char then return nil end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return nil end
    
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return nil end
    
    local labelGui = Instance.new("BillboardGui")
    labelGui.Adornee = head
    labelGui.Size = UDim2.new(3, 0, 1, 0)
    labelGui.StudsOffset = Vector3.new(0, 3, 0)
    labelGui.AlwaysOnTop = true
    labelGui.LightInfluence = 0
    labelGui.Parent = char
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 16
    textLabel.Text = "100 / 100"
    textLabel.Parent = labelGui
    
    local connection = humanoid.HealthChanged:Connect(function()
        local hp = math.floor(humanoid.Health)
        local maxHp = math.floor(humanoid.MaxHealth)
        textLabel.Text = hp .. " / " .. maxHp
    end)
    
    local hp = math.floor(humanoid.Health)
    local maxHp = math.floor(humanoid.MaxHealth)
    textLabel.Text = hp .. " / " .. maxHp
    
    return {gui = labelGui, connection = connection}
end

local function CreateChams(object, color)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = object
    return highlight
end

-- ═══════════════════════════════════════════════════════════════
-- 🏃 SURVIVOR TAB
-- ═══════════════════════════════════════════════════════════════

Tabs.Survivor:AddParagraph({
    Title = "⚡ Generator Features",
    Content = "Automatically complete generators and manage power"
})

Tabs.Survivor:AddToggle("AutoGen", {
    Title = "Auto Generator",
    Default = false,
    Callback = function(v)
        Settings.AutoGen = v
        if v then
            Connections.AutoGen = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local genUi = PlayerGui:FindFirstChild("Gen")
                    if genUi and genUi.Enabled then
                        local event = genUi.GeneratorMain.Event
                        event:FireServer({ Wires = true, Switches = true, Lever = true })
                    end
                end)
            end)
        else
            if Connections.AutoGen then
                Connections.AutoGen:Disconnect()
            end
        end
    end
})

local function CompleteAllGenerators()
    if not Connections.AutoGen then
        Connections.AutoGen = RunService.Heartbeat:Connect(function()
            pcall(function()
                local genUi = PlayerGui:FindFirstChild("Gen")
                if genUi and genUi.Enabled then
                    local event = genUi.GeneratorMain.Event
                    event:FireServer({ Wires = true, Switches = true, Lever = true })
                end
            end)
        end)
    end
    
    pcall(function()
        local gameMap = workspace.MAPS:FindFirstChild("GAME MAP")
        if not gameMap then return end
        
        if gameMap:FindFirstChild("FuseBoxes") then
            local fuseboxes = gameMap.FuseBoxes:GetChildren()
            for _, fusebox in pairs(fuseboxes) do
                if not fusebox:GetAttribute("Inserted") and fusebox.PrimaryPart then
                    local nearestBattery = nil
                    local shortestDist = math.huge
                    
                    for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                        if obj.Name == "Battery" then
                            local batteryPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if batteryPart then
                                local dist = (fusebox.PrimaryPart.Position - batteryPart.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    nearestBattery = obj
                                end
                            end
                        end
                    end
                    
                    if nearestBattery then
                        local batteryPart = nearestBattery:IsA("BasePart") and nearestBattery or nearestBattery:FindFirstChildWhichIsA("BasePart", true)
                        if batteryPart then
                            local char = GetCharacter()
                            local root = char and char.PrimaryPart
                            if root then
                                root.CFrame = batteryPart.CFrame
                                task.wait(1)
                                root.CFrame = fusebox.PrimaryPart.CFrame * CFrame.new(0, 0, 3)
                                task.wait(0.5)
                                for _, part in pairs(fusebox:GetDescendants()) do
                                    if part:IsA("ProximityPrompt") and part.Enabled then
                                        fireproximityprompt(part)
                                        task.wait(1)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if not gameMap:FindFirstChild("Generators") then return end
        
        for _, gen in pairs(gameMap.Generators:GetChildren()) do
            if gen:GetAttribute("Progress") < 100 and gen.PrimaryPart then
                TeleportCharacter(CFrame.new(gen.PrimaryPart.Position + Vector3.new(0, 2, 0)))
                task.wait(0.2)
                local prompt = gen.RootPart.Point1.ProximityPrompt
                if not prompt.Enabled then prompt = gen.RootPart.Point2.ProximityPrompt end
                if not prompt.Enabled then prompt = gen.RootPart.Point3.ProximityPrompt end
                if not prompt.Enabled then continue end
                fireproximityprompt(prompt)
                task.wait(3)
            end
        end
    end)
end

Tabs.Survivor:AddButton({
    Title = "Complete All Generators",
    Callback = function()
        task.spawn(function()
            pcall(CompleteAllGenerators)
        end)
    end
})

Tabs.Survivor:AddToggle("AutoBarricade", {
    Title = "Auto Barricade (Perfect)",
    Default = false,
    Callback = function(v)
        if v then
            Connections.AutoBarricade = RunService.RenderStepped:Connect(function()
                pcall(function()
                    -- Метод 1: Поиск по имени "Dot" (самый точный)
                    local dot = PlayerGui:FindFirstChild("Dot")
                    if dot and dot:IsA("ScreenGui") and dot.Enabled then
                        local container = dot:FindFirstChild("Container")
                        if container then
                            local frame = container:FindFirstChild("Frame")
                            if frame and frame:IsA("GuiObject") then
                                frame.AnchorPoint = Vector2.new(0.5, 0.5)
                                frame.Position = UDim2.new(0.5, 0, 0.5, 0)
                                return
                            end
                        end
                    end
                    
                    -- Метод 2: Поиск только по точному имени GUI "Dot" или содержащему "barricade"
                    for _, gui in pairs(PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Enabled then
                            local lowerName = gui.Name:lower()
                            -- Только для GUI с точным названием, связанным с баррикадой
                            if lowerName == "dot" or string.find(lowerName, "barricade") then
                                local container = gui:FindFirstChild("Container")
                                if container then
                                    for _, child in pairs(container:GetChildren()) do
                                        if child:IsA("Frame") and (child.Name == "Frame" or child.Name == "Dot" or child.Name == "Point") then
                                            child.AnchorPoint = Vector2.new(0.5, 0.5)
                                            child.Position = UDim2.new(0.5, 0, 0.5, 0)
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end)
        else
            if Connections.AutoBarricade then
                Connections.AutoBarricade:Disconnect()
            end
        end
    end
})

Tabs.Survivor:AddToggle("AutoEscape", {
    Title = "Auto Escape",
    Default = false,
    Callback = function(v)
        Settings.AutoEscape = v
        if v then
            local lastEscapeAttempt = 0
            Connections.AutoEscape = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local currentTime = tick()
                    if currentTime - lastEscapeAttempt < 1 then return end
                    
                    local team = GetTeam()
                    if not SafeTeleporting and team == "Survivor" and workspace.GAME.CAN_ESCAPE.Value then
                        local gameMap = workspace.MAPS:FindFirstChild("GAME MAP")
                        if not gameMap then return end
                        
                        local escapes = gameMap.Escapes and gameMap.Escapes:GetChildren() or {}
                        if #escapes == 0 then
                            for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                                if obj.Name == "EscapePoint" then
                                    table.insert(escapes, obj)
                                end
                            end
                        end
                        for _, esc in pairs(escapes) do
                            if esc:GetAttribute("Enabled") then
                                TeleportCharacter(esc.CFrame, true)
                                lastEscapeAttempt = currentTime
                                break
                            end
                        end
                    end
                end)
            end)
        else
            if Connections.AutoEscape then
                Connections.AutoEscape:Disconnect()
            end
        end
    end
})

Tabs.Survivor:AddParagraph({
    Title = "🛡️ Safety Features",
    Content = "Protect yourself from danger"
})

Tabs.Survivor:AddToggle("SafetyArea", {
    Title = "Safety Area",
    Default = false,
    Callback = function(v)
        if ScriptJustLoaded and v then
            task.wait(0.5)
        end
        
        SafetyAreaEnabled = v
        local char = GetCharacter()
        if not char or not char.PrimaryPart then return end
        local root = char.PrimaryPart
        
        if v then
            SafetyOriginalPos = root.CFrame
            local pos = root.Position
            SafetyPart = Instance.new("Part")
            SafetyPart.Size = Vector3.new(50, 1, 50)
            SafetyPart.Anchored = true
            SafetyPart.Position = pos - Vector3.new(0, 100, 0)
            SafetyPart.Name = "SafetyPlate"
            SafetyPart.Material = Enum.Material.ForceField
            SafetyPart.Color = Color3.fromRGB(0, 170, 255)
            SafetyPart.Transparency = 0.3
            SafetyPart.Parent = workspace
            
            task.spawn(function()
                TeleportCharacter(CFrame.new(pos - Vector3.new(0, 95, 0)), true)
            end)
        else
            if SafetyPart then
                SafetyPart:Destroy()
                SafetyPart = nil
            end
            if SafetyOriginalPos then
                task.spawn(function()
                    TeleportCharacter(SafetyOriginalPos, true)
                end)
            end
        end
    end
})

Tabs.Survivor:AddSlider("AntiDeathThreshold", {
    Title = "Anti Death Threshold",
    Default = 30,
    Min = 25,
    Max = 80,
    Rounding = 0.5,
    Callback = function(v)
        AntiDeath.Threshold = v
    end
})

Tabs.Survivor:AddToggle("AntiDeath", {
    Title = "Anti Death",
    Default = false,
    Callback = function(v)
        AntiDeath.Enabled = v
        
        if v then
            Connections.AntiDeath = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = GetCharacter()
                    if not char then return end
                    
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    
                    local root = char.PrimaryPart
                    if not root then return end
                    
                    if hum.Health < AntiDeath.Threshold and hum.Health > 0 and not AntiDeath.Teleported and not AntiDeath.Debounce then
                        AntiDeath.Debounce = true
                        AntiDeath.Teleported = true
                        AntiDeath.LastPos = root.CFrame
                        
                        local pos = root.Position
                        AntiDeath.Plate = Instance.new("Part")
                        AntiDeath.Plate.Size = Vector3.new(50, 1, 50)
                        AntiDeath.Plate.Anchored = true
                        AntiDeath.Plate.Position = pos - Vector3.new(0, 100, 0)
                        AntiDeath.Plate.Name = "AntiDeathPlate"
                        AntiDeath.Plate.Material = Enum.Material.ForceField
                        AntiDeath.Plate.Color = Color3.fromRGB(255, 0, 0)
                        AntiDeath.Plate.Transparency = 0.3
                        AntiDeath.Plate.Parent = workspace
                        
                        task.spawn(function()
                            TeleportCharacter(CFrame.new(pos - Vector3.new(0, 95, 0)), true)
                        end)
                        
                        task.delay(1, function()
                            AntiDeath.Debounce = false
                        end)
                    
                    elseif hum.Health >= AntiDeath.Threshold and AntiDeath.Teleported and AntiDeath.LastPos and not AntiDeath.Debounce then
                        AntiDeath.Debounce = true
                        
                        if AntiDeath.Plate then
                            AntiDeath.Plate:Destroy()
                            AntiDeath.Plate = nil
                        end
                        
                        if AntiDeath.LastPos then
                            task.spawn(function()
                                TeleportCharacter(AntiDeath.LastPos, true)
                            end)
                        end
                        
                        AntiDeath.LastPos = nil
                        AntiDeath.Teleported = false
                        
                        task.delay(1, function()
                            AntiDeath.Debounce = false
                        end)
                    end
                end)
            end)
        else
            if Connections.AntiDeath then
                Connections.AntiDeath:Disconnect()
            end
            
            if AntiDeath.Teleported and AntiDeath.LastPos then
                if AntiDeath.Plate then
                    AntiDeath.Plate:Destroy()
                    AntiDeath.Plate = nil
                end
                task.spawn(function()
                    TeleportCharacter(AntiDeath.LastPos, true)
                end)
            end
            
            AntiDeath.Teleported = false
            AntiDeath.LastPos = nil
            AntiDeath.Debounce = false
        end
    end
})

Tabs.Survivor:AddParagraph({
    Title = "⚔️ Combat Features",
    Content = "Defend yourself against killers"
})

Tabs.Survivor:AddSlider("AutoParryBasic", {
    Title = "Auto Parry Range",
    Default = 15,
    Min = 8,
    Max = 25,
    Rounding = 1,
    Callback = function(v)
        AutoParrySettings.BasicRange = v
    end
})

Tabs.Survivor:AddToggle("AutoParry", {
    Title = "Auto Parry (Basic Attacks)",
    Default = false,
    Callback = function(v)
        AutoParrySettings.Enabled = v
        
        if v then
            local lastParryTime = 0
            local parryCooldown = 0.1
            
            local function performParry()
                local currentTime = tick()
                if currentTime - lastParryTime < parryCooldown then return false end
                
                local parrySuccess = false
                
                -- Пробуем оба метода одновременно
                pcall(function()
                    local Module = require(game:GetService("ReplicatedStorage").Modules.Warp).Client("Input")
                    if Module then
                        Module:Fire(true, {"Ability", 2})
                        parrySuccess = true
                    end
                end)
                
                pcall(function()
                    local args = {
                        buffer.fromstring("\a"),
                        buffer.fromstring("\254\001\000\254\002\000\006\aAbility\001\002")
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Warp"):WaitForChild("Index"):WaitForChild("Event"):WaitForChild("Reliable"):FireServer(unpack(args))
                    parrySuccess = true
                end)
                
                if parrySuccess then
                    lastParryTime = currentTime
                    return true
                end
                return false
            end
            
            local function isBasicAttack(animId)
                -- Проверяем ТОЛЬКО базовые удары
                for _, aid in ipairs(AttackAnimIds) do
                    if animId == aid then return true end
                end
                return false
            end
            
            local function isSkill(animId)
                -- Проверяем скиллы (чтобы игнорировать)
                for _, sid in ipairs(SkillAnimIds) do
                    if animId == sid then return true end
                end
                return false
            end
            
            local function isAttackingMe(attackerRoot, myRoot)
                -- Проверяем, направлена ли атака на меня
                local attackerLookVector = attackerRoot.CFrame.LookVector
                local directionToMe = (myRoot.Position - attackerRoot.Position).Unit
                
                -- Вычисляем угол между направлением взгляда киллера и направлением ко мне
                local dotProduct = attackerLookVector:Dot(directionToMe)
                
                -- Если угол меньше ~45 градусов (dotProduct > 0.7), значит киллер смотрит на меня
                return dotProduct > 0.7
            end
            
            -- Метод 1: BoxHandleAdornment (индикатор атаки)
            Connections.AutoParryBox = workspace.DescendantAdded:Connect(function(child)
                if not AutoParrySettings.Enabled then return end
                
                task.spawn(function()
                    pcall(function()
                        if child:IsA("BoxHandleAdornment") then
                            local char = GetCharacter()
                            if not char or not char.PrimaryPart then return end
                            
                            local myRoot = char.PrimaryPart
                            local distance = (child.CFrame.Position - myRoot.Position).Magnitude
                            
                            if distance <= AutoParrySettings.BasicRange then
                                -- Проверяем, что рядом киллер с базовой атакой, направленной на меня
                                local shouldParry = false
                                for _, plr in ipairs(Players:GetPlayers()) do
                                    if plr == LocalPlayer then continue end
                                    
                                    local pchar = plr.Character
                                    if not pchar then continue end
                                    if pchar:GetAttribute("Team") ~= "Killer" then continue end
                                    
                                    local attackerRoot = pchar:FindFirstChild("HumanoidRootPart")
                                    if not attackerRoot then continue end
                                    
                                    local dist = (attackerRoot.Position - myRoot.Position).Magnitude
                                    if dist > AutoParrySettings.BasicRange + 5 then continue end
                                    
                                    -- ВАЖНО: Проверяем, что киллер атакует именно меня
                                    if not isAttackingMe(attackerRoot, myRoot) then continue end
                                    
                                    local hum = pchar:FindFirstChildOfClass("Humanoid")
                                    if not hum then continue end
                                    
                                    local animator = hum:FindFirstChildOfClass("Animator")
                                    if not animator then continue end
                                    
                                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                        if track.IsPlaying and track.Animation then
                                            local animId = track.Animation.AnimationId
                                            if isBasicAttack(animId) then
                                                shouldParry = true
                                                break
                                            end
                                        end
                                    end
                                    
                                    if shouldParry then break end
                                end
                                
                                if shouldParry then
                                    performParry()
                                end
                            end
                        end
                    end)
                end)
            end)
            
            -- Метод 2: Отслеживание ТОЛЬКО базовых атак у киллеров, направленных на меня
            Connections.AutoParry = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if not AutoParrySettings.Enabled then return end
                    
                    local char = GetCharacter()
                    if not char or not char.PrimaryPart then return end
                    
                    local myRoot = char.PrimaryPart
                    
                    -- Проверяем только киллеров
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr == LocalPlayer then continue end
                        
                        local pchar = plr.Character
                        if not pchar then continue end
                        
                        -- ВАЖНО: Только киллеры
                        if pchar:GetAttribute("Team") ~= "Killer" then continue end
                        
                        local attackerRoot = pchar:FindFirstChild("HumanoidRootPart")
                        if not attackerRoot then continue end
                        
                        local distance = (attackerRoot.Position - myRoot.Position).Magnitude
                        if distance > AutoParrySettings.BasicRange + 10 then continue end
                        
                        -- ВАЖНО: Проверяем, что киллер атакует именно меня
                        if not isAttackingMe(attackerRoot, myRoot) then continue end
                        
                        local hum = pchar:FindFirstChildOfClass("Humanoid")
                        if not hum then continue end
                        
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if not animator then continue end
                        
                        -- Проверяем анимации
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            if not track.IsPlaying then continue end
                            if not track.Animation then continue end
                            
                            local animId = track.Animation.AnimationId
                            
                            -- ИГНОРИРУЕМ СКИЛЛЫ!
                            if isSkill(animId) then continue end
                            
                            -- ПАРИРУЕМ ТОЛЬКО БАЗОВЫЕ УДАРЫ!
                            if isBasicAttack(animId) then
                                local animTime = track.TimePosition
                                -- Парируем в начале анимации
                                if animTime >= 0 and animTime <= 0.3 then
                                    if distance <= AutoParrySettings.BasicRange then
                                        if performParry() then
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end)
        else
            if Connections.AutoParry then
                Connections.AutoParry:Disconnect()
                Connections.AutoParry = nil
            end
            if Connections.AutoParryBox then
                Connections.AutoParryBox:Disconnect()
                Connections.AutoParryBox = nil
            end
        end
    end
})

Tabs.Survivor:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(v)
        Settings.AutoFarm = v
        if v then
            ToggleKiller(false)
            PrevTeam = GetTeam()
            
            Connections.AutoFarm = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if not Settings.AutoFarm then return end -- Проверка на выключение
                    
                    local role = GetTeam()
                    if role and role ~= PrevTeam then
                        PrevTeam = role
                        if role == "Survivor" and Settings.AutoFarm then
                            task.spawn(function()
                                task.wait(2)
                                if Settings.AutoFarm then -- Еще одна проверка перед выполнением
                                    CompleteAllGenerators()
                                end
                            end)
                        end
                    end
                end)
            end)
        else
            ToggleKiller(true)
            if Connections.AutoFarm then
                Connections.AutoFarm:Disconnect()
                Connections.AutoFarm = nil
            end
            if Connections.AutoGen then
                Connections.AutoGen:Disconnect()
                Connections.AutoGen = nil
            end
            PrevTeam = nil
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- 🔪 KILLER TAB
-- ═══════════════════════════════════════════════════════════════

Tabs.Killer:AddParagraph({
    Title = "⚔️ Combat Features",
    Content = "Enhance your killing abilities"
})

Tabs.Killer:AddToggle("AutoAim", {
    Title = "Auto Aim (Aimbot)",
    Description = "Automatically aims at nearest survivor",
    Default = false,
    Callback = function(Value)
        KillerSettings.AutoAim = Value
        if Value then
            Connections.AutoAim = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local team = GetTeam()
                    if team ~= "Killer" then return end
                    
                    local myChar = GetCharacter()
                    if not myChar or not myChar.PrimaryPart then return end
                    
                    local myRoot = myChar.PrimaryPart
                    local nearestTarget = nil
                    local shortestDist = math.huge
                    
                    -- Ищем ближайшего выжившего
                    for _, player in pairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                        if player ~= myChar then
                            local hrp = player:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (myRoot.Position - hrp.Position).Magnitude
                                if dist < shortestDist and dist <= 50 then -- В пределах 50 студов
                                    shortestDist = dist
                                    nearestTarget = hrp
                                end
                            end
                        end
                    end
                    
                    -- Наводимся на цель
                    if nearestTarget then
                        local targetPos = nearestTarget.Position
                        local lookVector = (targetPos - myRoot.Position).Unit
                        myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + lookVector)
                    end
                end)
            end)
        else
            if Connections.AutoAim then
                Connections.AutoAim:Disconnect()
                Connections.AutoAim = nil
            end
        end
    end
})

Tabs.Killer:AddToggle("NoStun", {
    Title = "No Stun",
    Default = false,
    Callback = function(Value)
        KillerSettings.NoStun = Value
        if Value then
            Connections.NoStunLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = GetCharacter()
                    if not char then return end
                    
                    local team = GetTeam()
                    if team ~= "Killer" then return end
                    
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    -- Расширенный список атрибутов для удаления всех видов оглушения
                    local stunAttributes = {
                        "Stun", "Stunned", "InAbility", "StunDuration",
                        "Confused", "Confusion", "ConfusionEffect", "Disoriented",
                        "Slowed", "Slow", "SlowEffect", "Frozen", "Freeze",
                        "Ragdoll", "Disabled", "Immobilized", "Paralyzed",
                        "Dazed", "Knocked", "KnockedDown", "Incapacitated",
                        "AxeStun", "TaserStun", "FighterStun", "SecurityStun",
                        "HitStun", "ImpactStun", "WeaponStun"
                    }
                    
                    -- Удаляем все атрибуты оглушения
                    for _, attr in ipairs(stunAttributes) do
                        if char:GetAttribute(attr) then
                            char:SetAttribute(attr, false)
                        end
                    end
                    
                    -- Сбрасываем WalkSpeed если он замедлен
                    if hum then
                        local baseSpeed = char:GetAttribute("RunSpeed") or 24
                        if hum.WalkSpeed < baseSpeed - 5 then
                            hum.WalkSpeed = baseSpeed
                        end
                    end
                    
                    -- Удаляем эффекты из Humanoid
                    if hum then
                        for _, effect in pairs(hum:GetChildren()) do
                            if effect:IsA("NumberValue") or effect:IsA("BoolValue") then
                                if string.find(effect.Name:lower(), "stun") or 
                                   string.find(effect.Name:lower(), "confus") or
                                   string.find(effect.Name:lower(), "slow") then
                                    effect:Destroy()
                                end
                            end
                        end
                    end
                    
                    -- Удаляем визуальные эффекты confusion/stun
                    for _, effect in pairs(char:GetDescendants()) do
                        if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
                            if string.find(effect.Name:lower(), "stun") or 
                               string.find(effect.Name:lower(), "confus") or
                               string.find(effect.Name:lower(), "daze") then
                                effect.Enabled = false
                            end
                        end
                    end
                end)
            end)
        else
            if Connections.NoStunLoop then
                Connections.NoStunLoop:Disconnect()
                Connections.NoStunLoop = nil
            end
        end
    end
})

Tabs.Killer:AddToggle("InfiniteStamina", {
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        KillerSettings.InfiniteStamina = Value
    end
})

-- Проверка на катсцену
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local cutsceneUI = PlayerGui:FindFirstChild("Cutscene") or PlayerGui:FindFirstChild("CutScene")
            if cutsceneUI and cutsceneUI.Enabled then
                AutoKillSettings.InCutscene = true
            else
                AutoKillSettings.InCutscene = false
            end
            
            -- Альтернативная проверка через атрибуты
            local char = GetCharacter()
            if char and char:GetAttribute("InCutscene") then
                AutoKillSettings.InCutscene = true
            end
        end)
    end
end)

Tabs.Killer:AddToggle("AutoKill", {
    Title = "Auto Kill All",
    Default = false,
    Callback = function(Value)
        AutoKillSettings.Enabled = Value
        if Value then
            Connections.AutoKill = RunService.Heartbeat:Connect(function()
                pcall(function()
                    -- Проверка на катсцену
                    if AutoKillSettings.InCutscene then return end
                    
                    local team = GetTeam()
                    if team ~= "Killer" then return end
                    
                    local myChar = GetCharacter()
                    if not myChar or not myChar.PrimaryPart then return end
                    
                    -- Проверка кулдауна атаки
                    local currentTime = tick()
                    if currentTime - AutoKillSettings.LastAttack < AutoKillSettings.AttackCooldown then
                        return
                    end
                    
                    local myRoot = myChar.PrimaryPart
                    local myPos = myRoot.Position
                    local nearestSurvivor = nil
                    local shortestDist = math.huge
                    
                    -- Получаем карту для проверки границ
                    local gameMap = workspace.MAPS:FindFirstChild("GAME MAP")
                    local mapBounds = nil
                    
                    if gameMap and gameMap.PrimaryPart then
                        local mapSize = gameMap:GetExtentsSize()
                        local mapCenter = gameMap.PrimaryPart.Position
                        mapBounds = {
                            MinX = mapCenter.X - mapSize.X / 2 - 50,
                            MaxX = mapCenter.X + mapSize.X / 2 + 50,
                            MinY = mapCenter.Y - 50,
                            MaxY = mapCenter.Y + mapSize.Y / 2 + 100,
                            MinZ = mapCenter.Z - mapSize.Z / 2 - 50,
                            MaxZ = mapCenter.Z + mapSize.Z / 2 + 50
                        }
                    end
                    
                    -- Ищем выживших в workspace.PLAYERS.ALIVE
                    if workspace.PLAYERS:FindFirstChild("ALIVE") then
                        for _, survivor in pairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                            if survivor:IsA("Model") and survivor ~= myChar then
                                local survivorRoot = survivor:FindFirstChild("HumanoidRootPart")
                                local survivorHum = survivor:FindFirstChild("Humanoid")
                                
                                if survivorRoot and survivorHum and survivorHum.Health > 0 then
                                    local dist = (myPos - survivorRoot.Position).Magnitude
                                    if dist < shortestDist and dist <= AutoKillSettings.MaxDistance then
                                        shortestDist = dist
                                        nearestSurvivor = survivorRoot
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Если не нашли, ищем по всем игрокам
                    if not nearestSurvivor then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local char = player.Character
                                local survivorRoot = char:FindFirstChild("HumanoidRootPart")
                                local survivorHum = char:FindFirstChild("Humanoid")
                                
                                if survivorRoot and survivorHum and survivorHum.Health > 0 and char:GetAttribute("Team") == "Survivor" then
                                    local dist = (myPos - survivorRoot.Position).Magnitude
                                    if dist < shortestDist and dist <= AutoKillSettings.MaxDistance then
                                        shortestDist = dist
                                        nearestSurvivor = survivorRoot
                                    end
                                end
                            end
                        end
                    end
                    
                    if nearestSurvivor then
                        local targetPos = nearestSurvivor.Position
                        
                        -- Проверка границ карты (динамическая или статическая)
                        local inBounds = true
                        if mapBounds then
                            inBounds = targetPos.X >= mapBounds.MinX and targetPos.X <= mapBounds.MaxX and
                                      targetPos.Y >= mapBounds.MinY and targetPos.Y <= mapBounds.MaxY and
                                      targetPos.Z >= mapBounds.MinZ and targetPos.Z <= mapBounds.MaxZ
                        else
                            -- Статические границы как запасной вариант
                            inBounds = math.abs(targetPos.X) <= 800 and 
                                      math.abs(targetPos.Z) <= 800 and 
                                      targetPos.Y >= -50 and targetPos.Y <= 400
                        end
                        
                        if not inBounds then return end
                        
                        -- Безопасная телепортация
                        local direction = (targetPos - myPos).Unit
                        local safePosition = targetPos - direction * AutoKillSettings.SafeDistance
                        
                        -- Проверяем безопасную позицию
                        local safePosInBounds = true
                        if mapBounds then
                            safePosInBounds = safePosition.X >= mapBounds.MinX and safePosition.X <= mapBounds.MaxX and
                                             safePosition.Y >= mapBounds.MinY and safePosition.Y <= mapBounds.MaxY and
                                             safePosition.Z >= mapBounds.MinZ and safePosition.Z <= mapBounds.MaxZ
                        else
                            safePosInBounds = math.abs(safePosition.X) <= 800 and 
                                             math.abs(safePosition.Z) <= 800 and 
                                             safePosition.Y >= -50 and safePosition.Y <= 400
                        end
                        
                        if not safePosInBounds then return end
                        
                        -- Телепортируемся
                        myRoot.CFrame = CFrame.new(safePosition, targetPos)
                        
                        -- Проверяем, что цель все еще жива
                        local targetChar = nearestSurvivor.Parent
                        if targetChar and targetChar:FindFirstChild("Humanoid") then
                            local humanoid = targetChar.Humanoid
                            if humanoid and humanoid.Health > 0 then
                                -- Небольшая задержка перед атакой
                                task.wait(0.15)
                                
                                -- Пробуем несколько методов атаки
                                local attackSuccess = false
                                
                                -- Метод 1: Стандартная атака через RemoteEvent
                                pcall(function()
                                    local args = {
                                        buffer.fromstring("\a"),
                                        buffer.fromstring("\254\001\000\254\002\000\006\aAbility\001\002")
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Warp"):WaitForChild("Index"):WaitForChild("Event"):WaitForChild("Reliable"):FireServer(unpack(args))
                                    attackSuccess = true
                                end)
                                
                                -- Метод 2: Альтернативная атака через Input модуль
                                if not attackSuccess then
                                    pcall(function()
                                        local Module = require(game:GetService("ReplicatedStorage").Modules.Warp).Client("Input")
                                        if Module then
                                            Module:Fire(true, {"Ability", 1})
                                        end
                                    end)
                                end
                                
                                AutoKillSettings.LastAttack = currentTime
                            end
                        end
                    end
                end)
            end)
        else
            if Connections.AutoKill then
                Connections.AutoKill:Disconnect()
                Connections.AutoKill = nil
            end
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ⚡ MOVEMENT TAB (ПЕРЕПИСАН)
-- ═══════════════════════════════════════════════════════════════

Tabs.Movement:AddParagraph({
    Title = "🏃 Speed Features",
    Content = "Control your movement speed"
})

Tabs.Movement:AddToggle("BypassSlowness", {
    Title = "Bypass Slowness",
    Default = false,
    Callback = function(v)
        Settings.BypassSlowness = v
    end
})

Tabs.Movement:AddToggle("AlwaysRun", {
    Title = "Always Run",
    Default = false,
    Callback = function(v)
        Settings.AlwaysRun = v
        
        -- Сбрасываем скорость при выключении
        if not v then
            pcall(function()
                local char = GetCharacter()
                if char then
                    local baseWalkSpeed = 16
                    local baseRunSpeed = 24
                    
                    char:SetAttribute("WalkSpeed", baseWalkSpeed)
                    char:SetAttribute("RunSpeed", baseRunSpeed)
                    
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = baseWalkSpeed
                    end
                end
            end)
        end
    end
})

Tabs.Movement:AddToggle("EnableJumping", {
    Title = "Enable Jumping",
    Default = false,
    Callback = function(v)
        Settings.EnableJumping = v
    end
})

Tabs.Movement:AddSlider("RunBoost", {
    Title = "Run Boost",
    Default = 0,
    Min = 0,
    Max = 16,
    Rounding = 1,
    Callback = function(v)
        Settings.RunBoost = v
    end
})

-- ПЕРЕПИСАННАЯ ЛОГИКА MOVEMENT
Connections.Movement = RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = GetCharacter()
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        local team = GetTeam()
        
        -- Базовые значения
        local baseWalkSpeed = 16
        local baseRunSpeed = 24
        local boost = Settings.RunBoost or 0
        
        -- Ограничение буста для киллера
        if team == "Killer" then
            boost = math.clamp(boost, 0, 10)
        end
        
        -- Bypass Slowness - игнорирует все замедления
        if Settings.BypassSlowness then
            local targetSpeed = baseWalkSpeed + boost
            hum.WalkSpeed = targetSpeed
            
            -- Устанавливаем кастомную скорость через атрибуты
            if team == "Survivor" then
                char:SetAttribute("CustomSpeed", targetSpeed)
            elseif team == "Killer" then
                char:SetAttribute("ModifiedMovementSpeed", targetSpeed)
            end
        end
        
        -- Always Run - постоянный бег
        if Settings.AlwaysRun then
            local runSpeed = baseRunSpeed + boost
            char:SetAttribute("WalkSpeed", runSpeed)
            char:SetAttribute("RunSpeed", runSpeed)
        elseif boost > 0 then
            -- Просто буст к скорости бега
            char:SetAttribute("RunSpeed", baseRunSpeed + boost)
        end
        
        -- Enable Jumping
        if Settings.EnableJumping then
            hum.JumpHeight = 7.2
            hum.JumpPower = 50
        else
            hum.JumpHeight = 0
            hum.JumpPower = 0
        end
        
        -- No Stun (Killer)
        if KillerSettings.NoStun and team == "Killer" then
            -- Удаляем все эффекты оглушения и контроля
            if char:GetAttribute("Stun") then
                char:SetAttribute("Stun", false)
            end
            if char:GetAttribute("InAbility") then
                char:SetAttribute("InAbility", false)
            end
            if char:GetAttribute("Confused") then
                char:SetAttribute("Confused", false)
            end
            if char:GetAttribute("Confusion") then
                char:SetAttribute("Confusion", false)
            end
            if char:GetAttribute("Stunned") then
                char:SetAttribute("Stunned", false)
            end
            if char:GetAttribute("StunDuration") then
                char:SetAttribute("StunDuration", 0)
            end
            if char:GetAttribute("Slowed") then
                char:SetAttribute("Slowed", false)
            end
            if char:GetAttribute("Frozen") then
                char:SetAttribute("Frozen", false)
            end
            if char:GetAttribute("Ragdoll") then
                char:SetAttribute("Ragdoll", false)
            end
            if char:GetAttribute("Disabled") then
                char:SetAttribute("Disabled", false)
            end
        end
        
        -- Infinite Stamina (Killer)
        if KillerSettings.InfiniteStamina and team == "Killer" then
            char:SetAttribute("Stamina", 100)
            char:SetAttribute("MaxStamina", 100)
        end
    end)
end)

Tabs.Movement:AddParagraph({
    Title = "🚧 Collision Features",
    Content = "Control collision and barriers"
})

Tabs.Movement:AddToggle("NoBarriers", {
    Title = "No Barriers",
    Default = false,
    Callback = function(v)
        if v then
            local function disableBarriers()
                for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                    if obj.Name == "BARRIER" or obj.Name == "BOUNDARY" then
                        obj.CanCollide = false
                    end
                end
            end
            
            disableBarriers()
            
            Connections.NoBarriers = workspace.IGNORE.ChildAdded:Connect(function(obj)
                if obj.Name == "BARRIER" or obj.Name == "BOUNDARY" then
                    obj.CanCollide = false
                end
            end)
        else
            if Connections.NoBarriers then
                Connections.NoBarriers:Disconnect()
            end
        end
    end
})

Tabs.Movement:AddToggle("InstantPrompts", {
    Title = "Instant Prompts",
    Default = false,
    Callback = function(v)
        if v then
            local function updatePrompts()
                for _, obj in workspace:GetDescendants() do
                    if obj:IsA("ProximityPrompt") then
                        obj.HoldDuration = 0.1
                    end
                end
            end
            
            updatePrompts()
            
            Connections.InstantPrompts = workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0.1
                end
            end)
        else
            if Connections.InstantPrompts then
                Connections.InstantPrompts:Disconnect()
            end
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- 👁️ VISUAL TAB
-- ═══════════════════════════════════════════════════════════════

Tabs.Visual:AddParagraph({
    Title = "👥 Player ESP",
    Content = "See players through walls"
})

local SurvivorESPDropdown = Tabs.Visual:AddDropdown("SurvivorESP", {
    Title = "Survivor ESP",
    Description = "Choose what to show for survivors",
    Values = {"NameTags", "Health", "Chams"},
    Multi = true,
    Default = {}
})

local lastSurvivorHealthState = false

SurvivorESPDropdown:OnChanged(function(Value)
    ESPSettings.Survivor.NameTags = Value["NameTags"] or false
    ESPSettings.Survivor.Health = Value["Health"] or false
    ESPSettings.Survivor.Chams = Value["Chams"] or false
    
    local showHealth = ESPSettings.Survivor.Health
    local healthStateChanged = (showHealth ~= lastSurvivorHealthState)
    lastSurvivorHealthState = showHealth
    
    if ESPSettings.Survivor.NameTags then
        if healthStateChanged then
            for _, data in pairs(SurvivorNameTags) do
                if data.connection then data.connection:Disconnect() end
                if data.gui then data.gui:Destroy() end
            end
            SurvivorNameTags = {}
        end
        
        if not Connections.SurvivorNameTags then
            Connections.SurvivorNameTags = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, char in pairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                        if not SurvivorNameTags[char] and char ~= GetCharacter() then
                            local part = char:FindFirstChild("HumanoidRootPart")
                            if part then
                                local esp, conn = CreatePlayerESP(part, Color3.new(0, 1, 0), char.Name, showHealth)
                                SurvivorNameTags[char] = {gui = esp, connection = conn}
                            end
                        end
                    end
                    for char, data in pairs(SurvivorNameTags) do
                        if not char.Parent then
                            if data.connection then data.connection:Disconnect() end
                            if data.gui then data.gui:Destroy() end
                            SurvivorNameTags[char] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.SurvivorNameTags then
            Connections.SurvivorNameTags:Disconnect()
            Connections.SurvivorNameTags = nil
        end
        for _, data in pairs(SurvivorNameTags) do
            if data.connection then data.connection:Disconnect() end
            if data.gui then data.gui:Destroy() end
        end
        SurvivorNameTags = {}
    end
    
    if ESPSettings.Survivor.Chams then
        if not Connections.SurvivorChams then
            Connections.SurvivorChams = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, char in pairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                        if not SurvivorChams[char] and char ~= GetCharacter() then
                            SurvivorChams[char] = CreateChams(char, Color3.new(0, 1, 0))
                        end
                    end
                    for char, cham in pairs(SurvivorChams) do
                        if not char.Parent then
                            cham:Destroy()
                            SurvivorChams[char] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.SurvivorChams then
            Connections.SurvivorChams:Disconnect()
            Connections.SurvivorChams = nil
        end
        for _, cham in pairs(SurvivorChams) do
            cham:Destroy()
        end
        SurvivorChams = {}
    end
end)

local KillerESPDropdown = Tabs.Visual:AddDropdown("KillerESP", {
    Title = "Killer ESP",
    Description = "Choose what to show for killers",
    Values = {"NameTags", "Health", "Chams"},
    Multi = true,
    Default = {}
})

local lastKillerHealthState = false

KillerESPDropdown:OnChanged(function(Value)
    ESPSettings.Killer.NameTags = Value["NameTags"] or false
    ESPSettings.Killer.Health = Value["Health"] or false
    ESPSettings.Killer.Chams = Value["Chams"] or false
    
    local showHealth = ESPSettings.Killer.Health
    local healthStateChanged = (showHealth ~= lastKillerHealthState)
    lastKillerHealthState = showHealth
    
    if ESPSettings.Killer.NameTags then
        if healthStateChanged then
            for _, data in pairs(KillerNameTags) do
                if data.connection then data.connection:Disconnect() end
                if data.gui then data.gui:Destroy() end
            end
            KillerNameTags = {}
        end
        
        if not Connections.KillerNameTags then
            Connections.KillerNameTags = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, char in pairs(workspace.PLAYERS.KILLER:GetChildren()) do
                        if not KillerNameTags[char] and char ~= GetCharacter() then
                            local part = char:FindFirstChild("HumanoidRootPart")
                            if part then
                                local esp, conn = CreatePlayerESP(part, Color3.new(1, 0, 0), "KILLER", showHealth)
                                KillerNameTags[char] = {gui = esp, connection = conn}
                            end
                        end
                    end
                    for char, data in pairs(KillerNameTags) do
                        if not char.Parent then
                            if data.connection then data.connection:Disconnect() end
                            if data.gui then data.gui:Destroy() end
                            KillerNameTags[char] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.KillerNameTags then
            Connections.KillerNameTags:Disconnect()
            Connections.KillerNameTags = nil
        end
        for _, data in pairs(KillerNameTags) do
            if data.connection then data.connection:Disconnect() end
            if data.gui then data.gui:Destroy() end
        end
        KillerNameTags = {}
    end
    
    if ESPSettings.Killer.Chams then
        if not Connections.KillerChams then
            Connections.KillerChams = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, char in pairs(workspace.PLAYERS.KILLER:GetChildren()) do
                        if not KillerChams[char] and char ~= GetCharacter() then
                            KillerChams[char] = CreateChams(char, Color3.new(1, 0, 0))
                        end
                    end
                    for char, cham in pairs(KillerChams) do
                        if not char.Parent then
                            cham:Destroy()
                            KillerChams[char] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.KillerChams then
            Connections.KillerChams:Disconnect()
            Connections.KillerChams = nil
        end
        for _, cham in pairs(KillerChams) do
            cham:Destroy()
        end
        KillerChams = {}
    end
end)

Tabs.Visual:AddParagraph({
    Title = "🎯 Object ESP",
    Content = "See important objects through walls"
})

local GeneratorESPDropdown = Tabs.Visual:AddDropdown("GeneratorESP", {
    Title = "Generator ESP",
    Description = "Choose what to show for generators",
    Values = {"NameTags", "Chams"},
    Multi = true,
    Default = {}
})

GeneratorESPDropdown:OnChanged(function(Value)
    ESPSettings.Generator.NameTags = Value["NameTags"] or false
    ESPSettings.Generator.Chams = Value["Chams"] or false
    
    if ESPSettings.Generator.NameTags then
        if not Connections.GeneratorNameTags then
            Connections.GeneratorNameTags = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if workspace.MAPS:FindFirstChild("GAME MAP") and workspace.MAPS["GAME MAP"]:FindFirstChild("Generators") then
                        for _, gen in pairs(workspace.MAPS["GAME MAP"].Generators:GetChildren()) do
                            local progress = gen:GetAttribute("Progress") or 0
                            if progress < 100 and not GeneratorNameTags[gen] and gen.PrimaryPart then
                                local esp, conn = CreateESP(gen.PrimaryPart, Color3.new(0, 0, 1), "Generator")
                                GeneratorNameTags[gen] = {gui = esp, connection = conn}
                            end
                        end
                        for gen, data in pairs(GeneratorNameTags) do
                            local progress = gen:GetAttribute("Progress") or 100
                            if not gen.Parent or progress >= 100 then
                                if data.connection then data.connection:Disconnect() end
                                if data.gui then data.gui:Destroy() end
                                GeneratorNameTags[gen] = nil
                            end
                        end
                    end
                end)
            end)
        end
    else
        if Connections.GeneratorNameTags then
            Connections.GeneratorNameTags:Disconnect()
            Connections.GeneratorNameTags = nil
        end
        for _, data in pairs(GeneratorNameTags) do
            if data.connection then data.connection:Disconnect() end
            if data.gui then data.gui:Destroy() end
        end
        GeneratorNameTags = {}
    end
    
    if ESPSettings.Generator.Chams then
        if not Connections.GeneratorChams then
            Connections.GeneratorChams = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if workspace.MAPS:FindFirstChild("GAME MAP") and workspace.MAPS["GAME MAP"]:FindFirstChild("Generators") then
                        for _, gen in pairs(workspace.MAPS["GAME MAP"].Generators:GetChildren()) do
                            local progress = gen:GetAttribute("Progress") or 0
                            if progress < 100 and not GeneratorChams[gen] then
                                GeneratorChams[gen] = CreateChams(gen, Color3.new(0, 0, 1))
                            end
                        end
                        for gen, cham in pairs(GeneratorChams) do
                            local progress = gen:GetAttribute("Progress") or 100
                            if not gen.Parent or progress >= 100 then
                                cham:Destroy()
                                GeneratorChams[gen] = nil
                            end
                        end
                    end
                end)
            end)
        end
    else
        if Connections.GeneratorChams then
            Connections.GeneratorChams:Disconnect()
            Connections.GeneratorChams = nil
        end
        for _, cham in pairs(GeneratorChams) do
            cham:Destroy()
        end
        GeneratorChams = {}
    end
end)

local BatteryESPDropdown = Tabs.Visual:AddDropdown("BatteryESP", {
    Title = "Battery ESP",
    Description = "Choose what to show for batteries",
    Values = {"NameTags", "Chams"},
    Multi = true,
    Default = {}
})

BatteryESPDropdown:OnChanged(function(Value)
    ESPSettings.Battery.NameTags = Value["NameTags"] or false
    ESPSettings.Battery.Chams = Value["Chams"] or false
    
    if ESPSettings.Battery.NameTags then
        if not Connections.BatteryNameTags then
            Connections.BatteryNameTags = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                        if obj.Name == "Battery" and not BatteryNameTags[obj] then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local esp, conn = CreateESP(part, Color3.fromRGB(255, 165, 0), "Battery")
                                BatteryNameTags[obj] = {gui = esp, connection = conn}
                            end
                        end
                    end
                    for battery, data in pairs(BatteryNameTags) do
                        if not battery.Parent then
                            if data.connection then data.connection:Disconnect() end
                            if data.gui then data.gui:Destroy() end
                            BatteryNameTags[battery] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.BatteryNameTags then
            Connections.BatteryNameTags:Disconnect()
            Connections.BatteryNameTags = nil
        end
        for _, data in pairs(BatteryNameTags) do
            if data.connection then data.connection:Disconnect() end
            if data.gui then data.gui:Destroy() end
        end
        BatteryNameTags = {}
    end
    
    if ESPSettings.Battery.Chams then
        if not Connections.BatteryChams then
            Connections.BatteryChams = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                        if obj.Name == "Battery" and not BatteryChams[obj] then
                            BatteryChams[obj] = CreateChams(obj, Color3.fromRGB(255, 165, 0))
                        end
                    end
                    for battery, cham in pairs(BatteryChams) do
                        if not battery.Parent then
                            cham:Destroy()
                            BatteryChams[battery] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.BatteryChams then
            Connections.BatteryChams:Disconnect()
            Connections.BatteryChams = nil
        end
        for _, cham in pairs(BatteryChams) do
            cham:Destroy()
        end
        BatteryChams = {}
    end
end)

local TrapESPDropdown = Tabs.Visual:AddDropdown("TrapESP", {
    Title = "Trap ESP",
    Description = "Choose what to show for traps",
    Values = {"NameTags", "Chams"},
    Multi = true,
    Default = {}
})

TrapESPDropdown:OnChanged(function(Value)
    ESPSettings.Trap.NameTags = Value["NameTags"] or false
    ESPSettings.Trap.Chams = Value["Chams"] or false
    
    if ESPSettings.Trap.NameTags then
        if not Connections.TrapNameTags then
            Connections.TrapNameTags = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                        if obj.Name == "Trap" and not TrapNameTags[obj] then
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local esp, conn = CreateESP(part, Color3.new(1, 0, 0), "Trap")
                                TrapNameTags[obj] = {gui = esp, connection = conn}
                            end
                        end
                    end
                    for trap, data in pairs(TrapNameTags) do
                        if not trap.Parent then
                            if data.connection then data.connection:Disconnect() end
                            if data.gui then data.gui:Destroy() end
                            TrapNameTags[trap] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.TrapNameTags then
            Connections.TrapNameTags:Disconnect()
            Connections.TrapNameTags = nil
        end
        for _, data in pairs(TrapNameTags) do
            if data.connection then data.connection:Disconnect() end
            if data.gui then data.gui:Destroy() end
        end
        TrapNameTags = {}
    end
    
    if ESPSettings.Trap.Chams then
        if not Connections.TrapChams then
            Connections.TrapChams = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                        if obj.Name == "Trap" and not TrapChams[obj] then
                            TrapChams[obj] = CreateChams(obj, Color3.new(1, 0, 0))
                        end
                    end
                    for trap, cham in pairs(TrapChams) do
                        if not trap.Parent then
                            cham:Destroy()
                            TrapChams[trap] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.TrapChams then
            Connections.TrapChams:Disconnect()
            Connections.TrapChams = nil
        end
        for _, cham in pairs(TrapChams) do
            cham:Destroy()
        end
        TrapChams = {}
    end
end)

local FuseboxESPDropdown = Tabs.Visual:AddDropdown("FuseboxESP", {
    Title = "Fusebox ESP",
    Description = "Choose what to show for fuseboxes",
    Values = {"NameTags", "Chams"},
    Multi = true,
    Default = {}
})

FuseboxESPDropdown:OnChanged(function(Value)
    ESPSettings.Fusebox.NameTags = Value["NameTags"] or false
    ESPSettings.Fusebox.Chams = Value["Chams"] or false
    
    if ESPSettings.Fusebox.NameTags then
        if not Connections.FuseboxNameTags then
            Connections.FuseboxNameTags = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if workspace.MAPS:FindFirstChild("GAME MAP") and workspace.MAPS["GAME MAP"]:FindFirstChild("FuseBoxes") then
                        for _, fusebox in pairs(workspace.MAPS["GAME MAP"].FuseBoxes:GetChildren()) do
                            if not fusebox:GetAttribute("Inserted") and not FuseboxNameTags[fusebox] then
                                local part = fusebox.PrimaryPart
                                if part then
                                    local esp, conn = CreateESP(part, Color3.new(1, 1, 0), "Fusebox")
                                    FuseboxNameTags[fusebox] = {gui = esp, connection = conn}
                                end
                            end
                        end
                        for fusebox, data in pairs(FuseboxNameTags) do
                            if not fusebox.Parent or fusebox:GetAttribute("Inserted") then
                                if data.connection then data.connection:Disconnect() end
                                if data.gui then data.gui:Destroy() end
                                FuseboxNameTags[fusebox] = nil
                            end
                        end
                    end
                end)
            end)
        end
    else
        if Connections.FuseboxNameTags then
            Connections.FuseboxNameTags:Disconnect()
            Connections.FuseboxNameTags = nil
        end
        for _, data in pairs(FuseboxNameTags) do
            if data.connection then data.connection:Disconnect() end
            if data.gui then data.gui:Destroy() end
        end
        FuseboxNameTags = {}
    end
    
    if ESPSettings.Fusebox.Chams then
        if not Connections.FuseboxChams then
            Connections.FuseboxChams = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if workspace.MAPS:FindFirstChild("GAME MAP") and workspace.MAPS["GAME MAP"]:FindFirstChild("FuseBoxes") then
                        for _, fusebox in pairs(workspace.MAPS["GAME MAP"].FuseBoxes:GetChildren()) do
                            if not fusebox:GetAttribute("Inserted") and not FuseboxChams[fusebox] then
                                FuseboxChams[fusebox] = CreateChams(fusebox, Color3.new(1, 1, 0))
                            end
                        end
                        for fusebox, cham in pairs(FuseboxChams) do
                            if not fusebox.Parent or fusebox:GetAttribute("Inserted") then
                                cham:Destroy()
                                FuseboxChams[fusebox] = nil
                            end
                        end
                    end
                end)
            end)
        end
    else
        if Connections.FuseboxChams then
            Connections.FuseboxChams:Disconnect()
            Connections.FuseboxChams = nil
        end
        for _, cham in pairs(FuseboxChams) do
            cham:Destroy()
        end
        FuseboxChams = {}
    end
end)

local MinionESPDropdown = Tabs.Visual:AddDropdown("MinionESP", {
    Title = "Minion ESP",
    Description = "Choose what to show for minions",
    Values = {"NameTags", "Chams"},
    Multi = true,
    Default = {}
})

MinionESPDropdown:OnChanged(function(Value)
    ESPSettings.Minion.NameTags = Value["NameTags"] or false
    ESPSettings.Minion.Chams = Value["Chams"] or false
    
    if ESPSettings.Minion.NameTags then
        if not Connections.MinionNameTags then
            Connections.MinionNameTags = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                        if obj:IsA("Model") and obj.Name == "Minion" and not MinionNameTags[obj] then
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local esp, conn = CreateESP(part, Color3.fromRGB(255, 165, 0), "Minion")
                                MinionNameTags[obj] = {gui = esp, connection = conn}
                            end
                        end
                    end
                    for minion, data in pairs(MinionNameTags) do
                        if not minion.Parent then
                            if data.connection then data.connection:Disconnect() end
                            if data.gui then data.gui:Destroy() end
                            MinionNameTags[minion] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.MinionNameTags then
            Connections.MinionNameTags:Disconnect()
            Connections.MinionNameTags = nil
        end
        for _, data in pairs(MinionNameTags) do
            if data.connection then data.connection:Disconnect() end
            if data.gui then data.gui:Destroy() end
        end
        MinionNameTags = {}
    end
    
    if ESPSettings.Minion.Chams then
        if not Connections.MinionChams then
            Connections.MinionChams = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                        if obj:IsA("Model") and obj.Name == "Minion" and not MinionChams[obj] then
                            MinionChams[obj] = CreateChams(obj, Color3.fromRGB(255, 165, 0))
                        end
                    end
                    for minion, cham in pairs(MinionChams) do
                        if not minion.Parent then
                            cham:Destroy()
                            MinionChams[minion] = nil
                        end
                    end
                end)
            end)
        end
    else
        if Connections.MinionChams then
            Connections.MinionChams:Disconnect()
            Connections.MinionChams = nil
        end
        for _, cham in pairs(MinionChams) do
            cham:Destroy()
        end
        MinionChams = {}
    end
end)

Tabs.Visual:AddParagraph({
    Title = "💡 Lighting",
    Content = "Adjust game lighting"
})

local OldLighting = {}
local FullbrightEnabled = false

Tabs.Visual:AddToggle("Fullbright", {
    Title = "Fullbright + Antiblind",
    Default = false,
    Callback = function(v)
        FullbrightEnabled = v
        if v then
            if not Connections.Fullbright then
                Connections.Fullbright = RunService.RenderStepped:Connect(function()
                    pcall(function()
                        if not FullbrightEnabled then return end
                        
                        Lighting.Brightness = 5
                        Lighting.ClockTime = 14
                        Lighting.FogEnd = 100000
                        Lighting.GlobalShadows = false
                        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                        
                        local LightingFolder = Lighting:FindFirstChild("Lighting")
                        if LightingFolder then
                            LightingFolder:Destroy()
                        end
                        
                        for _, obj in pairs(Lighting:GetChildren()) do
                            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
                                obj.Enabled = false
                            end
                        end
                    end)
                end)
            end
        else
            FullbrightEnabled = false
            if Connections.Fullbright then
                Connections.Fullbright:Disconnect()
                Connections.Fullbright = nil
            end
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- 📍 TELEPORT TAB
-- ═══════════════════════════════════════════════════════════════

Tabs.Teleport:AddParagraph({
    Title = "⚙️ Teleport Settings",
    Content = "Configure teleportation behavior"
})

Tabs.Teleport:AddToggle("SafeTeleport", {
    Title = "Safe Teleport",
    Default = true,
    Callback = function(v)
        Settings.SafeTeleport = v
    end
})

Tabs.Teleport:AddParagraph({
    Title = "📍 Quick Teleports",
    Content = "Teleport to important locations"
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Lobby",
    Callback = function()
        pcall(function()
            TeleportCharacter(workspace.Lobby["Player Position"].CFrame, true)
        end)
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Map",
    Callback = function()
        pcall(function()
            local gameMap = workspace.MAPS:FindFirstChild("GAME MAP")
            if not gameMap then
                Fluent:Notify({
                    Title = "Teleport to Map",
                    Content = "Game map not found! Start a game first.",
                    Duration = 3
                })
                return
            end
            
            local generators = gameMap:FindFirstChild("Generators")
            if not generators then
                Fluent:Notify({
                    Title = "Teleport to Map",
                    Content = "Generators not found!",
                    Duration = 3
                })
                return
            end
            
            local gens = generators:GetChildren()
            if #gens == 0 then
                Fluent:Notify({
                    Title = "Teleport to Map",
                    Content = "No generators available!",
                    Duration = 3
                })
                return
            end
            
            local randomGen = gens[math.random(1, #gens)]
            if randomGen and randomGen.PrimaryPart then
                TeleportCharacter(randomGen.PrimaryPart.CFrame * CFrame.new(0, 3, 0), true)
                Fluent:Notify({
                    Title = "Teleport to Map",
                    Content = "Teleported successfully!",
                    Duration = 2
                })
            end
        end)
    end
})

Tabs.Teleport:AddButton({
    Title = "Escape",
    Callback = function()
        pcall(function()
            if not workspace.GAME.CAN_ESCAPE.Value then
                Fluent:Notify({
                    Title = "Escape",
                    Content = "Cannot escape yet! Complete generators first.",
                    Duration = 3
                })
                return
            end
            
            local gameMap = workspace.MAPS:FindFirstChild("GAME MAP")
            if not gameMap then
                Fluent:Notify({
                    Title = "Escape",
                    Content = "Game map not found!",
                    Duration = 3
                })
                return
            end
            
            local escapes = {}
            
            if gameMap:FindFirstChild("Escapes") then
                escapes = gameMap.Escapes:GetChildren()
            end
            
            if #escapes == 0 then
                for _, obj in pairs(workspace.IGNORE:GetChildren()) do
                    if obj.Name == "EscapePoint" then
                        table.insert(escapes, obj)
                    end
                end
            end
            
            if #escapes == 0 then
                Fluent:Notify({
                    Title = "Escape",
                    Content = "No escape points found!",
                    Duration = 3
                })
                return
            end
            
            local escaped = false
            for _, esc in pairs(escapes) do
                if esc:GetAttribute("Enabled") then
                    TeleportCharacter(esc.CFrame, true)
                    escaped = true
                    Fluent:Notify({
                        Title = "Escape",
                        Content = "Teleported to escape!",
                        Duration = 2
                    })
                    break
                end
            end
            
            if not escaped then
                Fluent:Notify({
                    Title = "Escape",
                    Content = "No enabled escape points found!",
                    Duration = 3
                })
            end
        end)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ⚙️ SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ph4smo_BiteByNight")
SaveManager:SetFolder("ph4smo_BiteByNight/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Settings:AddButton({
    Title = "UnHook",
    Callback = function()
        Window:Dialog({
            Title = "UnHook Confirmation",
            Content = "Are you sure you want to unload the script?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        for _, connection in pairs(Connections) do
                            if typeof(connection) == "RBXScriptConnection" then
                                connection:Disconnect()
                            end
                        end
                        Fluent:Destroy()
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled")
                    end
                }
            }
        })
    end
})

-- ═══════════════════════════════════════════════════════════════
-- 🎉 FINALIZATION
-- ═══════════════════════════════════════════════════════════════

local ScriptJustLoaded = true
task.delay(3, function()
    ScriptJustLoaded = false
end)

Fluent:Notify({
    Title = "👋 Welcome!",
    Content = "Welcome, " .. LocalPlayer.Name .. "!",
    Duration = 5
})

task.wait(0.1)
Window:SelectTab(1)