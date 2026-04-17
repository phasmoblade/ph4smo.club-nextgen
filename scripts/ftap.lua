wait(3)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowSize = isMobile and UDim2.fromOffset(400, 350) or UDim2.fromOffset(580, 460)

local Window = Fluent:CreateWindow({
    Title = "🎮 ph4smo.club (nextgen) - Fling Things and People",
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

local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Anti = Window:AddTab({ Title = "Anti", Icon = "shield" }),
    Grab = Window:AddTab({ Title = "Grab", Icon = "hand" }),
    Blobman = Window:AddTab({ Title = "Blobman", Icon = "users" }),
    Character = Window:AddTab({ Title = "Character", Icon = "user" }),
    Aura = Window:AddTab({ Title = "Aura", Icon = "radio" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Fun", Icon = "smile" }),
    Loop = Window:AddTab({ Title = "Loop", Icon = "repeat" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Add section headers
Tabs.Anti:AddParagraph({
    Title = "🛡️ Protection Features",
    Content = "Enable various anti-grab and protection features"
})

Tabs.Grab:AddParagraph({
    Title = "✋ Grab Enhancements",
    Content = "Modify grab behavior and add special effects"
})

Tabs.Blobman:AddParagraph({
    Title = "👥 Blobman Controls",
    Content = "Spawn and control Blobman creature"
})

Tabs.Character:AddParagraph({
    Title = "🏃 Character Modifications",
    Content = "Modify your character's movement and abilities"
})

Tabs.Aura:AddParagraph({
    Title = "⚡ Auto-Target Auras",
    Content = "Automatically affect nearby players"
})

Tabs.Teleport:AddParagraph({
    Title = "📍 Quick Travel",
    Content = "Teleport to various locations on the map"
})

Tabs.Loop:AddParagraph({
    Title = "🔁 Target Loop Actions",
    Content = "Continuously affect selected players"
})

Tabs.ESP:AddParagraph({
    Title = "👁️ Visual Information",
    Content = "See player information through walls"
})

Tabs.Misc:AddParagraph({
    Title = "😄 Fun Features",
    Content = "Additional utility features"
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

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

-- Global Variables
local Settings = {}
local Connections = {}
local selectedPlayers = {}
local PlayerNameMap = {}

-- Helper Functions
local function getChar()
    return LocalPlayer.Character
end

local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function getInv()
    return workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
end

local function spawnToy(name, cframe)
    local success = pcall(function()
        return ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(name, cframe, Vector3.zero)
    end)
    return success
end

local function destroyToy(model)
    pcall(function()
        ReplicatedStorage.MenuToys.DestroyToy:FireServer(model)
    end)
end

local function ragdoll()
    local root = getRoot()
    if root then
        pcall(function()
            ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(root, 0)
        end)
    end
end

local function getBlobman()
    local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    return folder and folder:FindFirstChild("CreatureBlobman")
end


-- Anti Grab
local autoStruggleCoroutine = nil
local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")

Tabs.Anti:AddToggle("AntiGrab", {
    Title = "Anti Grab",
    Default = false,
    Callback = function(enabled)
        if enabled then
            autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local head = character.Head
                    local partOwner = head:FindFirstChild("PartOwner")
                    
                    if partOwner then
                        if Struggle then
                            Struggle:FireServer(LocalPlayer)
                        end
                        
                        local stopEvent = ReplicatedStorage:FindFirstChild("GameCorrectionEvents") and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("StopAllVelocity")
                        if stopEvent then
                            stopEvent:FireServer()
                        end

                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end

                        local BeingHeld = LocalPlayer:FindFirstChild("IsHeld")
                        while BeingHeld and BeingHeld.Value do
                            task.wait()
                        end

                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                end
            end)
        else
            if autoStruggleCoroutine then
                autoStruggleCoroutine:Disconnect()
                autoStruggleCoroutine = nil
            end
            
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
            end
        end
    end
})

-- Anti Explosion
local AntiExplosionEnabled = false
local antiExplosionConn = nil

local function setupAntiExplosion(character)
    if not AntiExplosionEnabled then return end
    local hum = character:WaitForChild("Humanoid", 5)
    local partOwner = hum and hum:FindFirstChild("Ragdolled")
    
    if partOwner then
        if antiExplosionConn then antiExplosionConn:Disconnect() end
        antiExplosionConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            if not AntiExplosionEnabled then return end
            if partOwner.Value then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
            else
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
            end
        end)
    end
end

Tabs.Anti:AddToggle("AntiExplosion", {
    Title = "Anti Explosion",
    Default = false,
    Callback = function(Value)
        AntiExplosionEnabled = Value
        if Value then
            if LocalPlayer.Character then
                setupAntiExplosion(LocalPlayer.Character)
            end
            local respawnConn = LocalPlayer.CharacterAdded:Connect(setupAntiExplosion)
            
            task.spawn(function()
                repeat task.wait() until not AntiExplosionEnabled
                respawnConn:Disconnect()
                if antiExplosionConn then antiExplosionConn:Disconnect() end
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.Anchored = false end
                    end
                end
            end)
        else
            if antiExplosionConn then antiExplosionConn:Disconnect() end
        end
    end
})

-- Anti Fire
local AntiFireEnabled = false
local ExtinguishPart = Workspace:WaitForChild("Map"):WaitForChild("Hole"):WaitForChild("PoisonBigHole"):WaitForChild("ExtinguishPart")
local OriginalFirePos = ExtinguishPart.CFrame

local function ExecuteAntiFire()
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    local isBurning = RootPart:FindFirstChild("FireLight") or RootPart:FindFirstChild("FireParticleEmitter")

    if isBurning and AntiFireEnabled then
        ExtinguishPart.CFrame = RootPart.CFrame
    else
        if ExtinguishPart.CFrame ~= OriginalFirePos then
            ExtinguishPart.CFrame = OriginalFirePos
        end
    end
end

RunService.Heartbeat:Connect(function()
    if AntiFireEnabled then
        ExecuteAntiFire()
    end
end)

Tabs.Anti:AddToggle("AntiFire", {
    Title = "Anti Fire",
    Default = false,
    Callback = function(Value)
        AntiFireEnabled = Value
        if not Value then
            ExtinguishPart.CFrame = OriginalFirePos
        end
    end
})

-- Anti Ragdoll
local antiRagdollEnabled = false
local protectionConnections = {}

local function clearProtectionConnections()
    for _, conn in ipairs(protectionConnections) do
        conn:Disconnect()
    end
    protectionConnections = {}
end

local function applyHumanoidProtection(humanoid)
    if not humanoid then return end
    
    humanoid.BreakJointsOnDeath = false
    humanoid.AutoRotate = true
    humanoid.PlatformStand = false

    table.insert(protectionConnections, humanoid.HealthChanged:Connect(function(health)
        if antiRagdollEnabled and health <= 0 then
            humanoid.Health = 1
        end
    end))

    table.insert(protectionConnections, humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function()
        if antiRagdollEnabled and humanoid.AutoRotate == false then
            humanoid.AutoRotate = true
        end
    end))

    table.insert(protectionConnections, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if antiRagdollEnabled and humanoid.PlatformStand == true then
            humanoid.PlatformStand = false
        end
    end))

    table.insert(protectionConnections, RunService.RenderStepped:Connect(function()
        if antiRagdollEnabled then
            if humanoid.Sit and humanoid.SeatPart == nil then
                humanoid.Sit = false
            end
        end
    end))
end

local function onCharacterAddedProtection(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid and antiRagdollEnabled then
        applyHumanoidProtection(humanoid)
    end
end

Tabs.Anti:AddToggle("AntiRagdoll", {
    Title = "Anti Ragdoll",
    Default = false,
    Callback = function(Value)
        antiRagdollEnabled = Value
        if antiRagdollEnabled then
            local char = LocalPlayer.Character
            if char then
                applyHumanoidProtection(char:FindFirstChild("Humanoid"))
            end
            _G.AntiRagdollConn = LocalPlayer.CharacterAdded:Connect(onCharacterAddedProtection)
        else
            if _G.AntiRagdollConn then
                _G.AntiRagdollConn:Disconnect()
                _G.AntiRagdollConn = nil
            end
            clearProtectionConnections()
        end
    end
})

-- Perm Ragdoll
local permRagdollT = false
local permRagdollRunningS = false

local function setRagdollF(state)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local remote = ReplicatedStorage:FindFirstChild("RagdollRemote", true) or 
                       ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("RagdollRemote")
        
        if remote then
            remote:FireServer(hrp, state and 1 or 0)
        end
    end
end

local function permRagdollLoopF()
    if permRagdollRunningS then return end
    permRagdollRunningS = true
    
    while permRagdollT do
        setRagdollF(true)
        task.wait(0.1)
    end
    
    permRagdollRunningS = false
    setRagdollF(false)
end

Tabs.Anti:AddToggle("PermRagdoll", {
    Title = "Perm Ragdoll",
    Default = false,
    Callback = function(Value)
        permRagdollT = Value
        if Value then
            task.spawn(permRagdollLoopF)
        end
    end
})

-- Anti Lag
local antiLagT = false

Tabs.Anti:AddToggle("AntiLag", {
    Title = "Anti Lag",
    Default = false,
    Callback = function(Value)
        antiLagT = Value
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        local target = scripts and scripts:FindFirstChild("CharacterAndBeamMove")
        
        if target then
            if Value then
                target.Disabled = true
            else
                target.Disabled = false
            end
        end
    end    
})

-- Anti Void
Tabs.Anti:AddButton({
    Title = "Anti Void",
    Callback = function()
        Workspace.FallenPartsDestroyHeight = -1.0E95
    end,
})


-- Grab Tab Functions
local throwStrength = 850
local throwEnabled = false
local Debris = game:GetService("Debris")

Tabs.Grab:AddToggle("Throw", {
    Title = "Throw",
    Default = false,
    Callback = function(Value)
        throwEnabled = Value
    end
})

Tabs.Grab:AddSlider("ThrowStrength", {
    Title = "Throw Strength",
    Default = 850,
    Min = 0,
    Max = 30000,
    Rounding = 50,
    Callback = function(Value)
        throwStrength = Value
    end,
})

Workspace.ChildAdded:Connect(function(model)
    if not throwEnabled then return end
    
    if model.Name == "GrabParts" then
        local partInfo = model:FindFirstChild("GrabPart")
        if not partInfo then return end

        local weld = partInfo:FindFirstChild("WeldConstraint")
        if not weld or not weld.Part1 then return end

        local part = weld.Part1
        local velocity = Instance.new("BodyVelocity")
        velocity.Parent = part
        velocity.MaxForce = Vector3.zero

        model:GetPropertyChangedSignal("Parent"):Connect(function()
            if not model.Parent then
                if throwEnabled then
                    velocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    velocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * throwStrength
                else
                    velocity.MaxForce = Vector3.zero
                end
                Debris:AddItem(velocity, 1)
            end
        end)
    end
end)

-- Spin Grab
local grabSpinEnabled = false
local grabSpinSpeed = 25

Tabs.Grab:AddToggle("SpinGrab", {
    Title = "Spin Grab",
    Default = false,
    Callback = function(Value)
        grabSpinEnabled = Value
    end
})

Tabs.Grab:AddSlider("SpinSpeed", {
    Title = "Spin Speed",
    Default = 25,
    Min = 0,
    Max = 200,
    Rounding = 5,
    Callback = function(Value)
        grabSpinSpeed = Value
    end,
})

Workspace.ChildAdded:Connect(function(model)
    if model.Name == "GrabParts" then
        local partInfo = model:FindFirstChild("GrabPart")
        if not partInfo then return end

        local weld = partInfo:FindFirstChild("WeldConstraint")
        if not weld or not weld.Part1 then return end

        local part = weld.Part1
        
        task.spawn(function()
            local spinForce = nil
            
            while model.Parent == Workspace do
                if grabSpinEnabled then
                    if not spinForce then
                        spinForce = Instance.new("BodyAngularVelocity")
                        spinForce.Name = "GrabSpinForce"
                        spinForce.MaxTorque = Vector3.new(0, math.huge, 0)
                        spinForce.Parent = part
                    end
                    spinForce.AngularVelocity = Vector3.new(0, grabSpinSpeed, 0)
                else
                    if spinForce then
                        spinForce:Destroy()
                        spinForce = nil
                    end
                end
                task.wait(0.1)
            end
            
            if spinForce then
                spinForce:Destroy()
            end
        end)
    end
end)

-- Ultra Grab & Kill Grab
local GrabConnections = {}
local GrabToggles = {
    KillGrab = false,
    UltraGrab = false
}

local function handleGrabPart(model, mode)
    if model.Name == "GrabParts" then
        local grabPart = model:FindFirstChild("GrabPart")
        local dragPart = model:FindFirstChild("DragPart")

        if mode == "Ultra" and dragPart then
            pcall(function()
                dragPart.Color = Color3.fromRGB(255, 0, 0)
                dragPart.Transparency = 0
                dragPart.Material = Enum.Material.Neon
                local orientation = dragPart:FindFirstChildOfClass("AlignOrientation")
                if orientation then
                    orientation.Responsiveness = 200
                    orientation.MaxTorque = math.huge
                end
                local position = dragPart:FindFirstChildOfClass("AlignPosition")
                if position then
                    position.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
                    position.MaxForce = math.huge
                    position.Responsiveness = 200
                end
            end)
        end

        if mode == "Kill" and grabPart then
            local weld = grabPart:FindFirstChild("WeldConstraint")
            if weld and weld.Part1 and weld.Part1.Parent then
                weld.Part1.Parent:BreakJoints()
            end
        end
    end
end

local function toggleGrab(flag, mode)
    if GrabConnections[flag] then
        GrabConnections[flag]:Disconnect()
        GrabConnections[flag] = nil
    end
    if GrabToggles[flag] then
        GrabConnections[flag] = Workspace.ChildAdded:Connect(function(model)
            handleGrabPart(model, mode)
        end)
    end
end

Tabs.Grab:AddToggle("UltraGrab", {
    Title = "Ultra Grab",
    Default = false,
    Callback = function(Value)
        GrabToggles.UltraGrab = Value
        toggleGrab("UltraGrab", "Ultra")
    end
})

Tabs.Grab:AddToggle("KillGrab", {
    Title = "Kill Grab",
    Default = false,
    Callback = function(Value)
        GrabToggles.KillGrab = Value
        toggleGrab("KillGrab", "Kill")
    end
})

-- Rainbow Line
local RainbowLineEnabled = false
local rainbowColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 165, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 0, 255)
}

local function UpdateRainbowLine()
    local colorIndex = 1
    task.spawn(function()
        while RainbowLineEnabled do
            local color = rainbowColors[colorIndex]
            
            pcall(function()
                game:GetService("ReplicatedStorage").DataEvents.UpdateLineColorsEvent:FireServer(table.unpack({
                    [1] = ColorSequence.new{ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color)},
                    [2] = color,
                    [3] = color,
                    [4] = color,
                    [5] = color,
                    [6] = color,
                    [7] = color,
                    [8] = color,
                    [9] = color,
                    [10] = color,
                }))
            end)
            
            colorIndex = colorIndex % #rainbowColors + 1
            task.wait(0.1)
        end
    end)
end

Tabs.Grab:AddToggle("RainbowLine", {
    Title = "Rainbow Line",
    Default = false,
    Callback = function(Value)
        RainbowLineEnabled = Value
        if Value then
            UpdateRainbowLine()
        end
    end
})


-- Blobman Tab
local function GetFormattedPlayerList()
    local displayList = {}
    PlayerNameMap = {} 
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local displayName = p.DisplayName .. " (@" .. p.Name .. ")"
            table.insert(displayList, displayName)
            PlayerNameMap[displayName] = p.Name
        end
    end
    if #displayList == 0 then table.insert(displayList, "No players found") end
    return displayList
end

local targetBringPlayer = ""

local playerDropdown = Tabs.Blobman:AddDropdown("TargetSelect", {
    Title = "Target Select",
    Values = GetFormattedPlayerList(),
    Default = 1,
    Callback = function(Value)
        local rawName = string.match(Value, "%((.-)%)") or Value
        targetBringPlayer = rawName
    end
})

local function RefreshPlayerList()
    local newList = GetFormattedPlayerList()
    playerDropdown:Refresh(newList, true)
end

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    RefreshPlayerList()
end)
Players.PlayerRemoving:Connect(RefreshPlayerList)

Tabs.Blobman:AddButton({
    Title = "Bring",
    Callback = function()
        local target = Players:FindFirstChild(targetBringPlayer)
        if not target or targetBringPlayer == "" then
            Fluent:Notify({
                Title = "Error",
                Content = "Please select target",
                Duration = 2
            })
            return
        end

        local function getMyBlob()
            local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    if v.Name == "CreatureBlobman" then
                        local seat = v:FindFirstChild("VehicleSeat")
                        if seat and seat:FindFirstChild("SeatWeld") and seat.SeatWeld.Part1 and seat.SeatWeld.Part1.Parent == LocalPlayer.Character then
                            return v
                        end
                    end
                end
            end
            return nil
        end

        local currentBlob = getMyBlob()
        if not currentBlob then
            Fluent:Notify({
                Title = "Error",
                Content = "Not riding Blobman",
                Duration = 2
            })
            return
        end

        local char = LocalPlayer.Character
        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
        local tHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        
        local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
        local setNet = grabEvents and grabEvents:FindFirstChild("SetNetworkOwner")
        local scripts = currentBlob:FindFirstChild("BlobmanSeatAndOwnerScript")
        local creatureGrab = scripts and scripts:FindFirstChild("CreatureGrab")
        local rightDetector = currentBlob:FindFirstChild("RightDetector")
        local rightWeld = rightDetector and rightDetector:FindFirstChild("RightWeld")

        if creatureGrab and rightWeld and myHrp and tHrp then
            local originalPos = myHrp.CFrame
            
            if setNet then 
                setNet:FireServer(tHrp, Workspace.CurrentCamera.CFrame) 
            end
            
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 2)
            task.wait(0.15) 

            creatureGrab:FireServer(rightDetector, tHrp, rightWeld)
            
            for i = 1, 2 do
                task.wait(0.05)
                creatureGrab:FireServer(rightDetector, tHrp, rightWeld)
            end

            task.wait(0.1)
            myHrp.CFrame = originalPos

            Fluent:Notify({
                Title = "Success",
                Content = target.DisplayName .. " secured",
                Duration = 2
            })
        end
    end
})

Tabs.Blobman:AddButton({
    Title = "Blobman Spawn & Sit",
    Callback = function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hum then return end

        local spawnedConnection = nil
        local folder = Workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys")

        spawnedConnection = folder.ChildAdded:Connect(function(child)
            if child.Name == "CreatureBlobman" then
                spawnedConnection:Disconnect()
                
                task.spawn(function()
                    local seat = child:WaitForChild("VehicleSeat", 5)
                    if seat and hum then
                        hrp.CFrame = seat.CFrame
                        task.wait(0.1)
                        seat:Sit(hum)
                    end
                end)
            end
        end)

        pcall(function()
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", hrp.CFrame, Vector3.new(0, 0, 0))
        end)
    end
})

-- Character Tab
local asss = false
local wss = 16

Tabs.Character:AddToggle("Walkspeed", {
    Title = "Walkspeed",
    Default = false,
    Callback = function(Value)
        asss = Value
    end
})

Tabs.Character:AddSlider("Speed", {
    Title = "Speed",
    Default = 16,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        wss = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if asss then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + LocalPlayer.Character.Humanoid.MoveDirection * (wss / 100)
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

local targetJumpPower = 25
local jumpEnabled = false
local jumpConn = nil

Tabs.Character:AddToggle("JumpPower", {
    Title = "JumpPower",
    Default = false,
    Callback = function(Value)
        jumpEnabled = Value
        
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        
        if Value then
            jumpConn = RunService.Heartbeat:Connect(function()
                if not jumpEnabled then return end
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = targetJumpPower
                end
            end)
        else
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 25
            end
        end
    end
})

Tabs.Character:AddSlider("Power", {
    Title = "Power",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 5,
    Callback = function(Value)
        targetJumpPower = Value
        if jumpEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = Value end
        end
    end,
})

local InfiniteJumpEnabled = false
Tabs.Character:AddToggle("InfJump", {
    Title = "Inf Jump",
    Default = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local NoclipEnabled = false
local NoclipConnection = nil

Tabs.Character:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
        if NoclipEnabled then
            NoclipConnection = RunService.Stepped:Connect(function()
                if NoclipEnabled and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
        end
    end
})

Tabs.Character:AddButton({
    Title = "Third Person",
    Callback = function()
        LocalPlayer.CameraMaxZoomDistance = 99999
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        Fluent:Notify({
            Title = "Camera Updated",
            Content = "Camera max distance unlocked",
            Duration = 3
        })
    end
})

Tabs.Character:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        
        if #game:GetService("Players"):GetPlayers() <= 1 then
            ts:Teleport(game.PlaceId, p)
        else
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
        end
    end
})

local BlobmanAnchored = false

Tabs.Character:AddToggle("BlobmanAnchor", {
    Title = "Blobman Anchor",
    Default = false,
    Callback = function(Value)
        BlobmanAnchored = Value
        
        local function SetBlobAnchor(state)
            local blob = getBlobman()
            if blob then
                for _, part in pairs(blob:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = state
                    end
                end
            end
        end

        if BlobmanAnchored then
            SetBlobAnchor(true)
            
            task.spawn(function()
                while BlobmanAnchored do
                    SetBlobAnchor(true)
                    task.wait(1)
                end
            end)
        else
            SetBlobAnchor(false)
        end
    end
})


-- Aura Tab
local DETECT_RANGE = 25
local isRunning = false
local whiteFriend = false 
local currentMode = ""
local loopConnection = nil
local processingPlayers = {}

local NET_INTERVAL = 0.005
local NET_COUNT = 10
local orbitRadius = 10
local orbitSpeed = 5

local function FireNetwork(part)
    if not part then return end
    pcall(function()
        local grabEvents = game:GetService("ReplicatedStorage"):FindFirstChild("GrabEvents")
        if grabEvents and grabEvents:FindFirstChild("SetNetworkOwner") then
            grabEvents.SetNetworkOwner:FireServer(part, CFrame.new(part.Position))
        end
    end)
end

local function GetNearbyPlayer()
    local localChar = game.Players.LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
    local localRoot = localChar.HumanoidRootPart
    
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player == game.Players.LocalPlayer then continue end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then continue end
        
        if whiteFriend and game.Players.LocalPlayer:IsFriendsWith(player.UserId) then continue end
        
        local targetRoot = player.Character.HumanoidRootPart
        local distance = (localRoot.Position - targetRoot.Position).Magnitude
        
        if distance <= DETECT_RANGE then
            return player, targetRoot
        end
    end
    return nil
end

local function StartDetection(mode)
    currentMode = mode
    if loopConnection then loopConnection:Disconnect() end
    
    loopConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isRunning then return end
        
        local player, targetRoot = GetNearbyPlayer()
        
        if player and not processingPlayers[player.Name] then
            processingPlayers[player.Name] = true
            
            task.spawn(function()
                local currentAngle = 0
                local isInfinite = (mode == "GrabUp")
                local iterations = isInfinite and 999999 or 50 

                for i = 1, iterations do
                    if not isRunning or currentMode ~= mode then break end
                    if not targetRoot or not targetRoot.Parent then break end
                    
                    FireNetwork(targetRoot)
                    
                    if mode == "GrabUp" then
                        targetRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 1.2, 0)
                    elseif mode == "Fling" then
                        if i == 10 then 
                            targetRoot.CFrame = CFrame.new(0, 1000000000000, 0) 
                            break 
                        end
                    elseif mode == "Orbit" then
                        currentAngle = currentAngle + math.rad(orbitSpeed)
                        local selfRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
                        local offset = Vector3.new(
                            math.cos(currentAngle) * orbitRadius,
                            2,
                            math.sin(currentAngle) * orbitRadius
                        )
                        targetRoot.CFrame = CFrame.new(selfRoot.Position + offset)
                    elseif mode == "Normal" then
                        targetRoot.CFrame = CFrame.new(targetRoot.Position)
                    end
                    
                    task.wait(NET_INTERVAL)
                end
                
                processingPlayers[player.Name] = nil
            end)
        end
    end)
end

Tabs.Aura:AddToggle("GrabAura", {
    Title = "Grab Aura",
    Default = false,
    Callback = function(Value)
        isRunning = Value
        if Value then StartDetection("Normal") else if loopConnection then loopConnection:Disconnect() end end
    end
})

Tabs.Aura:AddToggle("FlingAura", {
    Title = "Fling Aura",
    Default = false,
    Callback = function(Value)
        isRunning = Value
        if Value then StartDetection("Fling") else if loopConnection then loopConnection:Disconnect() end end
    end
})

Tabs.Aura:AddToggle("WhiteFriend", {
    Title = "White Friend",
    Default = false,
    Callback = function(Value)
        whiteFriend = Value
    end
})

-- Teleport Tab
local locations = {
    {Name = "🟣 Purple House", Pos = Vector3.new(255, -8, 449)},
    {Name = "🟢 Green house", Pos = Vector3.new(-534, -8, 93)},
    {Name = "🔵 Blue House", Pos = Vector3.new(512, 82, -343)},
    {Name = "🟠 Orange House", Pos = Vector3.new(548, 122, -73)},
    {Name = "🔴 Red House", Pos = Vector3.new(-493, -8, -165)},
    {Name = "🐿️ Squirrel land", Pos = Vector3.new(0, -7, 0)},
    {Name = "🏔️ Green Mountain House", Pos = Vector3.new(-278, 147, 310)},
    {Name = "🌾 Red Field House", Pos = Vector3.new(-203, 84, -292)},
    {Name = "🕳️ Cave", Pos = Vector3.new(-261, -7, 533)},
    {Name = "🎰 Slot Cave", Pos = Vector3.new(-34, -7, -299)},
    {Name = "☠️ Poisoned well", Pos = Vector3.new(106, -25, 279)},
    {Name = "❄️ Snowy mountain", Pos = Vector3.new(-414, 231, 480)},
    {Name = "1️⃣ Slot1", Pos = Vector3.new(54, -7, -115)},
    {Name = "2️⃣ Slot2", Pos = Vector3.new(170, -8, 527)},
    {Name = "3️⃣ Slot3", Pos = Vector3.new(-213, 83, 421)},
    {Name = "4️⃣ Slot4", Pos = Vector3.new(-540, -6, -40)},
}

for _, loc in ipairs(locations) do
    Tabs.Teleport:AddButton({
        Title = loc.Name,
        Callback = function()
            local char = game.Players.LocalPlayer.Character
            if char then
                char:MoveTo(loc.Pos)
                Fluent:Notify({
                    Title = "Teleport",
                    Content = "Moved to " .. loc.Name,
                    Duration = 2
                })
            end
        end
    })
end

-- Loop Tab
local function GetLoopPlayerList()
    local displayList = {}
    PlayerNameMap = {} 
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local displayName = p.DisplayName .. " (@" .. p.Name .. ")"
            table.insert(displayList, displayName)
            PlayerNameMap[displayName] = p.Name
        end
    end
    if #displayList == 0 then table.insert(displayList, "No players found") end
    return displayList
end

local PlayerDropdown = Tabs.Loop:AddDropdown("LoopTarget", {
    Title = "Target Select",
    Values = GetLoopPlayerList(),
    Multi = true,
    Default = {},
    Callback = function(Options) 
        selectedPlayers = {}
        for _, display in pairs(Options) do
            local name = PlayerNameMap[display]
            if name then table.insert(selectedPlayers, name) end
        end
    end,
})

Tabs.Loop:AddButton({
    Title = "Reset List",
    Callback = function()
        selectedPlayers = {}
        PlayerDropdown:SetValue({})
        Fluent:Notify({
            Title = "Selection Reset",
            Content = "List has been reset",
            Duration = 3
        })
    end
})

local function UpdateLoopList()
    local newList = GetLoopPlayerList()
    PlayerDropdown:Refresh(newList, true)
end

Players.PlayerAdded:Connect(function() task.wait(0.5) UpdateLoopList() end)
Players.PlayerRemoving:Connect(UpdateLoopList)

local targetWalkSpeed = 16
local targetJumpPower = 50

Tabs.Loop:AddSlider("TargetWalkSpeed", {
   Title = "Target Walkspeed",
   Default = 16,
   Min = 0,
   Max = 500,
   Rounding = 1,
   Callback = function(Value)
       targetWalkSpeed = Value
   end,
})

Tabs.Loop:AddSlider("TargetJumpPower", {
   Title = "Target JumpPower",
   Default = 50,
   Min = 0,
   Max = 500,
   Rounding = 1,
   Callback = function(Value)
       targetJumpPower = Value
   end,
})

Tabs.Loop:AddButton({
    Title = "Target Jump",
    Callback = function()
        for _, name in pairs(selectedPlayers) do
            local target = Players:FindFirstChild(name)
            if target and target.Character then
                local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                if tHum then
                    pcall(function()
                        tHum.JumpPower = targetJumpPower
                        tHum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            end
        end
    end
})

local spinEnabled = false
Tabs.Loop:AddToggle("SpinTarget", {
    Title = "Target Spin",
    Default = false,
    Callback = function(Value)
        spinEnabled = Value
        
        task.spawn(function()
            while spinEnabled do
                for _, name in pairs(selectedPlayers) do
                    local target = Players:FindFirstChild(name)
                    if target and target.Character then
                        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                        
                        if tRoot and tHum then
                            pcall(function()
                                tHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                                tHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                            end)

                            local spin = tRoot:FindFirstChild("SpinForce")
                            if not spin then
                                spin = Instance.new("BodyAngularVelocity")
                                spin.Name = "SpinForce"
                                spin.MaxTorque = Vector3.new(0, math.huge, 0)
                                spin.AngularVelocity = Vector3.new(0, 25, 0)
                                spin.Parent = tRoot
                            else
                                spin.AngularVelocity = Vector3.new(0, 25, 0)
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if tRoot then
                        local spin = tRoot:FindFirstChild("SpinForce")
                        if spin then spin:Destroy() end
                    end
                    if tHum then
                        pcall(function()
                            tHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                            tHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                        end)
                    end
                end
            end
        end)
    end
})

Tabs.Loop:AddButton({
    Title = "Target Kill",
    Callback = function()
        for _, name in pairs(selectedPlayers) do
            local target = Players:FindFirstChild(name)
            if target and target.Character then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = 0
                end
            end
        end
    end
})


-- ESP Tab
local ESP_Enabled = false
local Box_Enabled = false
local Distance_Enabled = false 
local Snaplines_Enabled = false
local ESP_Objects = {}
local Box_Color = Color3.fromRGB(255, 0, 0)

local function CreateBox(char)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ArkadiaBox"
    billboard.Adornee = char:WaitForChild("HumanoidRootPart", 5)
    billboard.Size = UDim2.new(5.5, 0, 7, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    billboard.Enabled = true 

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Parent = billboard
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 1, 0)
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "BoxStroke"
    stroke.Thickness = 2.5 
    stroke.Color = Box_Color
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 1 
    stroke.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistanceLabel"
    distLabel.Parent = frame
    distLabel.BackgroundTransparency = 1
    distLabel.AnchorPoint = Vector2.new(1, 1) 
    distLabel.Position = UDim2.new(1, -4, 1, -4) 
    distLabel.Size = UDim2.new(0, 80, 0, 15)
    distLabel.Font = Enum.Font.Code
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextSize = 12
    distLabel.TextXAlignment = Enum.TextXAlignment.Right
    distLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    distLabel.TextStrokeTransparency = 0
    distLabel.Visible = false
    distLabel.Text = ""

    billboard.Parent = char
    return billboard
end

local function CreateSnapline(player)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Box_Color
    line.Thickness = 1
    line.Transparency = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if Snaplines_Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos = player.Character.HumanoidRootPart.Position
            local vector, onScreen = Camera:WorldToViewportPoint(rootPos)
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            line.From = screenCenter
            if onScreen then
                line.To = Vector2.new(vector.X, vector.Y)
                line.Visible = true
            else
                local targetPos2D = Vector2.new(vector.X, vector.Y)
                local direction = (targetPos2D - screenCenter).Unit
                if vector.Z < 0 then direction = -direction end 
                local edgeX = Camera.ViewportSize.X / 2 - 15
                local edgeY = Camera.ViewportSize.Y / 2 - 15
                local m = math.min(math.abs(edgeX / direction.X), math.abs(edgeY / direction.Y))
                line.To = screenCenter + (direction * m)
                line.Visible = true
            end
        else
            line.Visible = false
            if not player or not player.Parent then line:Remove() connection:Disconnect() end
        end
    end)
    return line
end

local function ApplyESP(player)
    if player == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ArkadiaESP"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = Box_Color
        highlight.Enabled = ESP_Enabled
        highlight.Parent = char
        
        local bill = CreateBox(char)
        local stroke = bill:FindFirstChild("BoxStroke", true)
        if stroke then stroke.Transparency = Box_Enabled and 0 or 1 end
        local lbl = bill:FindFirstChild("DistanceLabel", true)
        if lbl then lbl.Visible = Distance_Enabled end
        
        local line = CreateSnapline(player)
        ESP_Objects[player] = {Highlight = highlight, Billboard = bill, Character = char, Tracer = line}
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)
Players.PlayerRemoving:Connect(function(p) 
    if ESP_Objects[p] and ESP_Objects[p].Tracer then ESP_Objects[p].Tracer:Remove() end
    ESP_Objects[p] = nil 
end)

Tabs.ESP:AddToggle("EspToggle", {
    Title = "Enable Player Highlights",
    Default = false,
    Callback = function(v) 
        ESP_Enabled = v 
        for _, data in pairs(ESP_Objects) do if data.Highlight then data.Highlight.Enabled = v end end 
    end
})

Tabs.ESP:AddToggle("BoxToggle", {
    Title = "Enable Red ESP Box",
    Default = false,
    Callback = function(v) 
        Box_Enabled = v 
        for _, data in pairs(ESP_Objects) do 
            if data.Billboard then 
                local stroke = data.Billboard:FindFirstChild("BoxStroke", true)
                if stroke then stroke.Transparency = v and 0 or 1 end
            end 
        end 
    end
})

Tabs.ESP:AddToggle("SnaplineToggle", {
    Title = "Enable Red Snap Line",
    Default = false,
    Callback = function(v) 
        Snaplines_Enabled = v 
    end
})

Tabs.ESP:AddToggle("DistanceToggle", {
    Title = "Show Distance",
    Default = false,
    Callback = function(v) 
        Distance_Enabled = v 
        for _, data in pairs(ESP_Objects) do 
            if data.Billboard then 
                local lbl = data.Billboard:FindFirstChild("DistanceLabel", true)
                if lbl then lbl.Visible = v end
            end 
        end 
    end
})

RunService.RenderStepped:Connect(function()
    local myRoot = getRoot()
    if not myRoot then return end
    for p, data in pairs(ESP_Objects) do
        if data.Billboard and data.Character and data.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = data.Character.HumanoidRootPart
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            if Distance_Enabled then
                local lbl = data.Billboard:FindFirstChild("DistanceLabel", true)
                if lbl then lbl.Text = string.format("[%dm]", math.floor(dist)) end
            end
            if Box_Enabled then
                data.Billboard.Size = (dist < 40) and UDim2.new(8, 0, 10, 0) or UDim2.new(5.5, 0, 7, 0)
            end
        end
    end
end)

local espEnabled = false
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    local name = Drawing.new("Text")
    name.Visible = false
    name.Text = player.DisplayName
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 16
    name.Center = true
    name.Outline = true
    espObjects[player] = {Name = name}
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player].Name:Remove()
        espObjects[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for player, gui in pairs(espObjects) do
        if espEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                gui.Name.Position = Vector2.new(pos.X, pos.Y - 30)
                gui.Name.Visible = true
            else
                gui.Name.Visible = false
            end
        else
            gui.Name.Visible = false
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

Tabs.ESP:AddToggle("NameESP", {
    Title = "Enable Name ESP",
    Default = false,
    Callback = function(v)
        espEnabled = v
    end
})

-- Misc Tab (Fun)
local savedLocation = nil
local loopTPEnabled = false
local tpInterval = 60
local stayTime = 0.5

Tabs.Misc:AddButton({
    Title = "Save Position",
    Callback = function()
        local hrp = getRoot()
        if hrp then
            savedLocation = hrp.CFrame
            Fluent:Notify({
                Title = "Save Position",
                Content = "Current location saved",
                Duration = 2
            })
        end
    end
})

Tabs.Misc:AddToggle("LoopTP", {
    Title = "Loop Teleport",
    Default = false,
    Callback = function(Value)
        loopTPEnabled = Value
        if Value then
            if not savedLocation then
                local hrp = getRoot()
                if hrp then savedLocation = hrp.CFrame end
            end

            task.spawn(function()
                while loopTPEnabled do
                    task.wait(tpInterval)
                    if not loopTPEnabled then break end

                    local hrp = getRoot()
                    if hrp and savedLocation then
                        local beforeTPLocation = hrp.CFrame
                        hrp.CFrame = savedLocation
                        task.wait(stayTime) 
                        local currentHrp = getRoot()
                        if currentHrp then
                            currentHrp.CFrame = beforeTPLocation
                        end
                    end
                end
            end)
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ph4smo_FTAP")
SaveManager:SetFolder("ph4smo_FTAP/configs")
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

Fluent:Notify({
    Title = "👋 Welcome!",
    Content = "Welcome, " .. LocalPlayer.Name .. "!",
    Duration = 5
})

task.wait(0.1)
Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
