wait(3)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowSize = isMobile and UDim2.fromOffset(400, 350) or UDim2.fromOffset(580, 460)

local Window = Fluent:CreateWindow({
    Title = "⚔️ > ph4smo.club (nextgen) - Steel Titans",
    SubTitle = "by phasmoblade",
    TabWidth = 160,
    Size = windowSize,
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.Home
})

if isMobile then
    local MinimizeButton = Window:AddButton({
        Title = "Toggle GUI",
        Callback = function()
            Window:Minimize()
        end
    })
end
local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Movement = Window:AddTab({ Title = "Loading", Icon = "move" }),
    Visuals = Window:AddTab({ Title = "Loading", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Loading", Icon = "settings" })
}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
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
local ESPEnabled = false
local ESPHighlights = {}
local ESPLabels = {}
local ShowPlayerName = true
local ShowTankName = true
local ShowHP = true
local ShowReloadTime = true
local ModulesESPEnabled = false
local ModuleHighlights = {
    AmmoRack = nil,
    FuelTank = nil,
    Barrel = nil,
    HullCrew = nil,
    TurretCrew = nil,
    Engine = nil
}
local ReloadTimers = {}
local OriginalSettings = {
    Lighting = {}
}
local BlackSkyEnabled = false
local FlyEnabled = false
local TeleportDistance = 3
local FlyConnection = nil
local AntiFlipEnabled = false
local NoRecoilEnabled = false
local function GetPlayerTank(player)
    if not player then return nil end
    local char = player:FindFirstChild("Char")
    if not char then return nil end
    if not char.Value then return nil end
    local tank = char.Value.Parent.Parent.Parent
    return tank
end
local function GetTeamColor(player)
    if player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 0, 0)
end
local function SetupAntiCheatBypass()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local oldKick = nil
    oldKick = hookmetamethod(LocalPlayer, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return wait(9e9)
        end
        return oldKick(self, ...)
    end)
    pcall(function()
        hookfunction(LocalPlayer.Kick, function()
            return wait(9e9)
        end)
    end)
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "Kick" then
            return wait(9e9)
        end
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self):lower()
            if remoteName:find("kick") or remoteName:find("ban") then
                return wait(9e9)
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end
pcall(SetupAntiCheatBypass)
local function StartFly()
    if FlyConnection then
        FlyConnection:Disconnect()
    end
    local lastTeleport = 0
    local teleportCooldown = 0.15
    local tracksDisabled = false
    local idleTime = 0
    local lastIdleMove = 0
    local maxHeight = 200
    local currentSpeed = 0
    local targetSpeed = 0
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then 
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            return 
        end
        pcall(function()
            local tank = GetPlayerTank(LocalPlayer)
            if not tank then return end
            if not tracksDisabled then
                for _, obj in pairs(tank:GetDescendants()) do
                    if obj:IsA("Animator") or obj:IsA("AnimationController") then
                        obj:Destroy()
                    end
                    if obj:IsA("Motor6D") or obj:IsA("Motor") then
                        local name = obj.Name:lower()
                        if name:find("track") or name:find("wheel") or name:find("road") then
                            obj:Destroy()
                        end
                    end
                end
                tracksDisabled = true
            end
            for _, part in pairs(tank:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
            local currentTime = tick()
            if currentTime - lastTeleport < teleportCooldown then return end
            local camera = workspace.CurrentCamera
            local moveHorizontal = Vector3.new(0, 0, 0)
            local moveVertical = 0
            local isMoving = false
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                local forward = camera.CFrame.LookVector
                moveHorizontal = moveHorizontal + Vector3.new(forward.X, 0, forward.Z).Unit
                isMoving = true
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                local forward = camera.CFrame.LookVector
                moveHorizontal = moveHorizontal - Vector3.new(forward.X, 0, forward.Z).Unit
                isMoving = true
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                local right = camera.CFrame.RightVector
                moveHorizontal = moveHorizontal - Vector3.new(right.X, 0, right.Z).Unit
                isMoving = true
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                local right = camera.CFrame.RightVector
                moveHorizontal = moveHorizontal + Vector3.new(right.X, 0, right.Z).Unit
                isMoving = true
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVertical = 1
                isMoving = true
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVertical = -1
                isMoving = true
            end
            if isMoving then
                idleTime = 0
                targetSpeed = TeleportDistance
            else
                idleTime = idleTime + (currentTime - lastTeleport)
                targetSpeed = 0
            end
            currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * 0.3
            local finalMove = Vector3.new(0, 0, 0)
            if moveHorizontal.Magnitude > 0 then
                finalMove = finalMove + (moveHorizontal.Unit * currentSpeed)
            end
            if moveVertical ~= 0 then
                local primaryPart = tank.PrimaryPart or tank:FindFirstChild("Hull") or tank:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local currentHeight = primaryPart.Position.Y
                    local terrain = workspace.Terrain
                    local rayOrigin = primaryPart.Position
                    local rayDirection = Vector3.new(0, -1000, 0)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {tank}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    local groundHeight = rayResult and rayResult.Position.Y or 0
                    if moveVertical > 0 and (currentHeight - groundHeight) < maxHeight then
                        finalMove = finalMove + Vector3.new(0, moveVertical * (currentSpeed * 0.35), 0)
                    elseif moveVertical < 0 then
                        finalMove = finalMove + Vector3.new(0, moveVertical * (currentSpeed * 0.35), 0)
                    end
                end
            end
            if not isMoving and idleTime > 3 and (currentTime - lastIdleMove) > 2 then
                local microMove = Vector3.new(
                    (math.random() - 0.5) * 0.03,
                    (math.random() - 0.5) * 0.03,
                    (math.random() - 0.5) * 0.03
                )
                finalMove = finalMove + microMove
                lastIdleMove = currentTime
            end
            if finalMove.Magnitude > 0 then
                lastTeleport = currentTime
                for _, part in pairs(tank:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CFrame = part.CFrame + finalMove
                    end
                end
            end
        end)
    end)
    Fluent:Notify({
        Title = " Fly",
        Content = "Flying! Use WASD + Space/Shift",
        Duration = 3
    })
end
local function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    Fluent:Notify({
        Title = " Fly",
        Content = "Fly stopped!",
        Duration = 2
    })
end
Tabs.Movement:AddParagraph({
    Title = "✈️ Fly",
    Content = "Fly your tank with WASD controls"
})
Tabs.Movement:AddKeybind("FlyKeybind", {
    Title = "Fly Keybind",
    Description = "Press to toggle fly on/off",
    Default = "F",
    Callback = function()
        FlyEnabled = not FlyEnabled
        if FlyEnabled then
            StartFly()
        else
            StopFly()
        end
    end
})
Tabs.Movement:AddSlider("TeleportDistance", {
    Title = "Fly Speed",
    Description = "Adjust flying speed",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        TeleportDistance = Value
    end
})
Tabs.Movement:AddParagraph({
    Title = "🎮 Controls",
    Content = "W/A/S/D - Move\nSpace - Up\nShift - Down"
})
Tabs.Movement:AddParagraph({
    Title = "🛠️ Tank Utilities",
    Content = "Additional tank features"
})
Tabs.Movement:AddToggle("AntiFlip", {
    Title = "Anti-Flip",
    Description = "Prevent tank from flipping over",
    Default = false,
    Callback = function(Value)
        AntiFlipEnabled = Value
    end
})
Tabs.Movement:AddToggle("NoRecoil", {
    Title = "No Recoil",
    Description = "Remove camera shake when shooting",
    Default = false,
    Callback = function(Value)
        NoRecoilEnabled = Value
    end
})
local function CreateHighlight(tank, color)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = tank
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = tank
    return highlight
end
local function SetupModulesESP()
    if ModuleHighlights.AmmoRack then return end
    local AmmoRack = Instance.new("Model", Workspace)
    AmmoRack.Name = "ph4smo_AmmoRack"
    local ammoHL = Instance.new("Highlight", AmmoRack)
    ammoHL.FillColor = Color3.fromRGB(255, 0, 0)
    ammoHL.FillTransparency = 0.7
    ammoHL.OutlineColor = Color3.fromRGB(255, 0, 0)
    ammoHL.OutlineTransparency = 0.98
    ammoHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ModuleHighlights.AmmoRack = AmmoRack
    local FuelTank = Instance.new("Model", Workspace)
    FuelTank.Name = "ph4smo_FuelTank"
    local fuelHL = Instance.new("Highlight", FuelTank)
    fuelHL.FillColor = Color3.fromRGB(255, 255, 0)
    fuelHL.FillTransparency = 0.9
    fuelHL.OutlineColor = Color3.fromRGB(255, 255, 0)
    fuelHL.OutlineTransparency = 0.98
    fuelHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ModuleHighlights.FuelTank = FuelTank
    local Barrel = Instance.new("Model", Workspace)
    Barrel.Name = "ph4smo_Barrel"
    local barrelHL = Instance.new("Highlight", Barrel)
    barrelHL.FillColor = Color3.fromRGB(0, 0, 255)
    barrelHL.FillTransparency = 0.7
    barrelHL.OutlineColor = Color3.fromRGB(0, 0, 255)
    barrelHL.OutlineTransparency = 0.98
    barrelHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ModuleHighlights.Barrel = Barrel
    local HullCrew = Instance.new("Model", Workspace)
    HullCrew.Name = "ph4smo_HullCrew"
    local hullHL = Instance.new("Highlight", HullCrew)
    hullHL.FillColor = Color3.fromRGB(0, 255, 255)
    hullHL.FillTransparency = 0.8
    hullHL.OutlineColor = Color3.fromRGB(0, 255, 255)
    hullHL.OutlineTransparency = 0.98
    hullHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ModuleHighlights.HullCrew = HullCrew
    local TurretCrew = Instance.new("Model", Workspace)
    TurretCrew.Name = "ph4smo_TurretCrew"
    local turretHL = Instance.new("Highlight", TurretCrew)
    turretHL.FillColor = Color3.fromRGB(0, 255, 255)
    turretHL.FillTransparency = 0.8
    turretHL.OutlineColor = Color3.fromRGB(0, 255, 255)
    turretHL.OutlineTransparency = 0.98
    turretHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ModuleHighlights.TurretCrew = TurretCrew
    local Engine = Instance.new("Model", Workspace)
    Engine.Name = "ph4smo_Engine"
    local engineHL = Instance.new("Highlight", Engine)
    engineHL.FillColor = Color3.fromRGB(255, 255, 255)
    engineHL.FillTransparency = 0.2
    engineHL.OutlineColor = Color3.fromRGB(255, 255, 255)
    engineHL.OutlineTransparency = 0.98
    engineHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ModuleHighlights.Engine = Engine
end
local function ClearModulesESP()
    for _, model in pairs(ModuleHighlights) do
        if model and model.Parent then
            for _, child in pairs(model:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Parent = nil
                end
            end
            model:Destroy()
        end
    end
    ModuleHighlights = {
        AmmoRack = nil,
        FuelTank = nil,
        Barrel = nil,
        HullCrew = nil,
        TurretCrew = nil,
        Engine = nil
    }
end
local function UpdateModulesESP()
    if not ModulesESPEnabled then return end
end
local function ProcessModulePart(v)
    if not ModulesESPEnabled then return end
    pcall(function()
        local moduleParts = {
            ["Ammo rack"] = ModuleHighlights.AmmoRack,
            ["Fuel tank"] = ModuleHighlights.FuelTank,
            ["Barrel"] = ModuleHighlights.Barrel,
            ["Hull crew"] = ModuleHighlights.HullCrew,
            ["Turret crew"] = ModuleHighlights.TurretCrew,
            ["Drivetrain"] = ModuleHighlights.Engine
        }
        if moduleParts[v.Name] and v:IsA("BasePart") then
            local myTank = GetPlayerTank(LocalPlayer)
            local myTeam = LocalPlayer.Team
            local isEnemyModule = false
            if myTank and v:IsDescendantOf(myTank) then
                isEnemyModule = false
            else
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local playerTank = GetPlayerTank(player)
                        if playerTank and v:IsDescendantOf(playerTank) then
                            if player.Team ~= myTeam then
                                isEnemyModule = true
                            end
                            break
                        end
                    end
                end
            end
            if isEnemyModule then
                if v.Parent ~= moduleParts[v.Name] then
                    v.Transparency = 0
                    v.Parent = moduleParts[v.Name]
                end
            else
                if v.Parent == moduleParts[v.Name] then
                    local ancestor = v
                    while ancestor.Parent and ancestor.Parent ~= Workspace do
                        ancestor = ancestor.Parent
                    end
                    v.Parent = ancestor
                end
            end
        end
    end)
end
Workspace.DescendantAdded:Connect(function(v)
    if not ModulesESPEnabled then return end
    task.wait(0.5)
    ProcessModulePart(v)
end)
task.spawn(function()
    while task.wait(2) do
        if ModulesESPEnabled then
            pcall(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    ProcessModulePart(v)
                end
            end)
        end
    end
end)
local function CreateESPLabel(tank, player)
    local centerPart = tank.PrimaryPart or tank:FindFirstChild("Hull") or tank:FindFirstChild("Body") or tank:FindFirstChildWhichIsA("BasePart")
    if not centerPart then return nil end
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = centerPart
    billboardGui.Size = UDim2.new(0, 200, 0, 20)
    billboardGui.StudsOffset = Vector3.new(0, 10, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = math.huge
    billboardGui.Parent = centerPart
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextScaled = false
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = ""
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.Parent = billboardGui
    return billboardGui
end
local function UpdateESPLabel(label, tank, player)
    if not label or not label.Parent then return end
    local parts = {}
    if ShowPlayerName then
        table.insert(parts, player.Name)
    end
    if ShowTankName then
        table.insert(parts, tank.Name or "Unknown")
    end
    if ShowHP then
        local hp = "?"
        pcall(function()
            local healthValue = tank:FindFirstChild("Health")
            if not healthValue then
                healthValue = tank:FindFirstChild("HP")
            end
            if not healthValue then
                for _, child in pairs(tank:GetDescendants()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local name = child.Name:lower()
                        if name:find("health") or name:find("hp") then
                            healthValue = child
                            break
                        end
                    end
                end
            end
            if healthValue and (healthValue:IsA("IntValue") or healthValue:IsA("NumberValue")) then
                hp = tostring(math.floor(healthValue.Value))
            end
        end)
        table.insert(parts, hp)
    end
    if ShowReloadTime then
        local reload = "Ready"
        pcall(function()
            if not ReloadTimers[player] then
                ReloadTimers[player] = {lastShot = 0, reloadTime = 5}
            end
            local currentTime = tick()
            local timeSinceShot = currentTime - ReloadTimers[player].lastShot
            local shotDetected = false
            for _, obj in pairs(tank:GetDescendants()) do
                if obj:IsA("Sound") and obj.IsPlaying then
                    local soundName = obj.Name:lower()
                    if soundName:find("fire") or soundName:find("shoot") or soundName:find("shot") or soundName:find("cannon") then
                        ReloadTimers[player].lastShot = currentTime
                        shotDetected = true
                        break
                    end
                end
                if obj:IsA("ParticleEmitter") and obj.Enabled then
                    local emitterName = obj.Name:lower()
                    if emitterName:find("fire") or emitterName:find("muzzle") or emitterName:find("flash") then
                        ReloadTimers[player].lastShot = currentTime
                        shotDetected = true
                        break
                    end
                end
            end
            if timeSinceShot < ReloadTimers[player].reloadTime then
                local timeLeft = ReloadTimers[player].reloadTime - timeSinceShot
                reload = string.format("%.1fs", timeLeft)
            else
                reload = "Ready"
            end
        end)
        table.insert(parts, reload)
    end
    local text = table.concat(parts, ", ")
    if label:FindFirstChildOfClass("TextLabel") then
        label:FindFirstChildOfClass("TextLabel").Text = text
    end
end
local function UpdateESP()
    if not ESPEnabled then 
        for player, data in pairs(ESPHighlights) do
            if data.highlight and data.highlight.Parent then
                data.highlight:Destroy()
            end
            if data.label and data.label.Parent then
                data.label:Destroy()
            end
        end
        ESPHighlights = {}
        return 
    end
    local myTank = GetPlayerTank(LocalPlayer)
    local myTeam = LocalPlayer.Team
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= myTeam then
            pcall(function()
                local tank = GetPlayerTank(player)
                if tank and tank ~= myTank and tank.Parent then
                    local needsUpdate = false
                    if not ESPHighlights[player] then
                        needsUpdate = true
                    elseif not ESPHighlights[player].highlight or not ESPHighlights[player].highlight.Parent then
                        needsUpdate = true
                    elseif ESPHighlights[player].tank ~= tank then
                        if ESPHighlights[player].highlight then
                            ESPHighlights[player].highlight:Destroy()
                        end
                        if ESPHighlights[player].label then
                            ESPHighlights[player].label:Destroy()
                        end
                        needsUpdate = true
                    end
                    if needsUpdate then
                        local teamColor = GetTeamColor(player)
                        local highlight = CreateHighlight(tank, teamColor)
                        local label = CreateESPLabel(tank, player)
                        ESPHighlights[player] = {highlight = highlight, label = label, tank = tank}
                    end
                    UpdateESPLabel(ESPHighlights[player].label, tank, player)
                end
            end)
        end
    end
    for player, data in pairs(ESPHighlights) do
        if not Players:FindFirstChild(player.Name) or player.Team == myTeam then
            if data.highlight and data.highlight.Parent then
                data.highlight:Destroy()
            end
            if data.label and data.label.Parent then
                data.label:Destroy()
            end
            ESPHighlights[player] = nil
        else
            local currentTank = GetPlayerTank(player)
            if not currentTank or currentTank ~= data.tank then
                if data.highlight and data.highlight.Parent then
                    data.highlight:Destroy()
                end
                if data.label and data.label.Parent then
                    data.label:Destroy()
                end
                ESPHighlights[player] = nil
            end
        end
    end
end
Tabs.Visuals:AddParagraph({
    Title = "🎯 Tank ESP",
    Content = "Highlight enemy tanks with info"
})
Tabs.Visuals:AddToggle("TankESP", {
    Title = " Tank ESP",
    Description = "Show highlights on enemy tanks",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            for _, data in pairs(ESPHighlights) do
                if data.highlight and data.highlight.Parent then
                    data.highlight:Destroy()
                end
                if data.label and data.label.Parent then
                    data.label:Destroy()
                end
            end
            ESPHighlights = {}
        end
    end
})
Tabs.Visuals:AddToggle("ShowPlayerName", {
    Title = "Show Player Name",
    Description = "Display player nickname",
    Default = true,
    Callback = function(Value)
        ShowPlayerName = Value
    end
})
Tabs.Visuals:AddToggle("ShowTankName", {
    Title = "Show Tank Name",
    Description = "Display tank model name",
    Default = true,
    Callback = function(Value)
        ShowTankName = Value
    end
})
Tabs.Visuals:AddToggle("ShowHP", {
    Title = "Show HP",
    Description = "Display tank health",
    Default = true,
    Callback = function(Value)
        ShowHP = Value
    end
})
Tabs.Visuals:AddToggle("ShowReloadTime", {
    Title = "Show Reload Time",
    Description = "Display reload cooldown",
    Default = true,
    Callback = function(Value)
        ShowReloadTime = Value
    end
})
Tabs.Visuals:AddToggle("ModulesESP", {
    Title = "Modules ESP",
    Description = "Highlight enemy tank modules (Ammo, Fuel, Barrel, Crew, Engine)",
    Default = false,
    Callback = function(Value)
        ModulesESPEnabled = Value
        if Value then
            SetupModulesESP()
            task.spawn(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    ProcessModulePart(v)
                end
            end)
        else
            ClearModulesESP()
        end
    end
})
Tabs.Visuals:AddParagraph({
    Title = "🌍 Environment",
    Content = "Modify game environment"
})
Tabs.Visuals:AddToggle("FPSBooster", {
    Title = "FPS Booster",
    Description = "Boost FPS by optimizing graphics",
    Default = false,
    Callback = function(Value)
        if Value then
            _G.Settings = {
                Players = {
                    ["Ignore Me"] = true,
                    ["Ignore Others"] = true,
                    ["Ignore Tools"] = true
                },
                Meshes = {
                    NoMesh = false,
                    NoTexture = false,
                    Destroy = false
                },
                Images = {
                    Invisible = true,
                    Destroy = false
                },
                Particles = {
                    Invisible = true,
                    Destroy = false
                },
                Other = {
                    ["FPS Cap"] = true,
                    ["No Camera Effects"] = true,
                    ["No Clothes"] = true,
                    ["Low Water Graphics"] = true,
                    ["No Shadows"] = true,
                    ["Low Rendering"] = true,
                    ["Low Quality Parts"] = true,
                    ["Low Quality Models"] = true,
                    ["Reset Materials"] = true
                }
            }
            _G.SendNotifications = false
            _G.ConsoleLogs = false
            local code = game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua")
            code = code:gsub("discord%.gg/rips", "ph4smo.club")
            code = code:gsub("RIP#6666", "phasmoblade")
            code = code:gsub('game%.StarterGui:SetCore%("SendNotification",%s*{.-}%)', "")
            code = code:gsub('StarterGui:SetCore%("SendNotification",%s*{.-}%)', "")
            loadstring(code)()
        else
            Fluent:Notify({
                Title = "FPS Booster",
                Content = "Rejoin to disable FPS Booster",
                Duration = 5
            })
        end
    end
})
Tabs.Visuals:AddToggle("BlackSky", {
    Title = "Black Sky",
    Description = "Make the sky completely black",
    Default = false,
    Callback = function(Value)
        BlackSkyEnabled = Value
        local Lighting = game:GetService("Lighting")
        if Value then
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("Sky") then
                    if not OriginalSettings.Lighting.Sky then
                        OriginalSettings.Lighting.Sky = {
                            SkyboxBk = obj.SkyboxBk,
                            SkyboxDn = obj.SkyboxDn,
                            SkyboxFt = obj.SkyboxFt,
                            SkyboxLf = obj.SkyboxLf,
                            SkyboxRt = obj.SkyboxRt,
                            SkyboxUp = obj.SkyboxUp,
                            StarCount = obj.StarCount,
                            SunAngularSize = obj.SunAngularSize,
                            MoonAngularSize = obj.MoonAngularSize,
                            CelestialBodiesShown = obj.CelestialBodiesShown
                        }
                    end
                    obj.SkyboxBk = ""
                    obj.SkyboxDn = ""
                    obj.SkyboxFt = ""
                    obj.SkyboxLf = ""
                    obj.SkyboxRt = ""
                    obj.SkyboxUp = ""
                    obj.StarCount = 0
                    obj.SunAngularSize = 0
                    obj.MoonAngularSize = 0
                    obj.CelestialBodiesShown = false
                end
            end
            if not OriginalSettings.Lighting.Ambient then
                OriginalSettings.Lighting.Ambient = Lighting.Ambient
                OriginalSettings.Lighting.OutdoorAmbient = Lighting.OutdoorAmbient
                OriginalSettings.Lighting.ColorShift_Top = Lighting.ColorShift_Top
                OriginalSettings.Lighting.ColorShift_Bottom = Lighting.ColorShift_Bottom
                OriginalSettings.Lighting.ClockTime = Lighting.ClockTime
            end
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
            Lighting.ClockTime = 0
        else
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("Sky") and OriginalSettings.Lighting.Sky then
                    obj.SkyboxBk = OriginalSettings.Lighting.Sky.SkyboxBk
                    obj.SkyboxDn = OriginalSettings.Lighting.Sky.SkyboxDn
                    obj.SkyboxFt = OriginalSettings.Lighting.Sky.SkyboxFt
                    obj.SkyboxLf = OriginalSettings.Lighting.Sky.SkyboxLf
                    obj.SkyboxRt = OriginalSettings.Lighting.Sky.SkyboxRt
                    obj.SkyboxUp = OriginalSettings.Lighting.Sky.SkyboxUp
                    obj.StarCount = OriginalSettings.Lighting.Sky.StarCount
                    obj.SunAngularSize = OriginalSettings.Lighting.Sky.SunAngularSize
                    obj.MoonAngularSize = OriginalSettings.Lighting.Sky.MoonAngularSize
                    obj.CelestialBodiesShown = OriginalSettings.Lighting.Sky.CelestialBodiesShown
                end
            end
            if OriginalSettings.Lighting.Ambient then
                Lighting.Ambient = OriginalSettings.Lighting.Ambient
                Lighting.OutdoorAmbient = OriginalSettings.Lighting.OutdoorAmbient
                Lighting.ColorShift_Top = OriginalSettings.Lighting.ColorShift_Top
                Lighting.ColorShift_Bottom = OriginalSettings.Lighting.ColorShift_Bottom
                Lighting.ClockTime = OriginalSettings.Lighting.ClockTime
            end
        end
    end
})
Tabs.Visuals:AddParagraph({
    Title = "🎨 Atmosphere Color",
    Content = "Change the color of lighting and atmosphere"
})
Tabs.Visuals:AddColorpicker("AtmosphereColor", {
    Title = " Atmosphere Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        if not OriginalSettings.Lighting.AtmosphereOriginal then
            OriginalSettings.Lighting.AtmosphereOriginal = {
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                ColorShift_Top = Lighting.ColorShift_Top,
                ColorShift_Bottom = Lighting.ColorShift_Bottom
            }
        end
        Lighting.Ambient = Value
        Lighting.OutdoorAmbient = Value
        Lighting.ColorShift_Top = Value
        Lighting.ColorShift_Bottom = Value
    end
})
Tabs.Visuals:AddButton({
    Title = "Reset Atmosphere",
    Description = "Reset atmosphere to original colors",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        if OriginalSettings.Lighting.AtmosphereOriginal then
            Lighting.Ambient = OriginalSettings.Lighting.AtmosphereOriginal.Ambient
            Lighting.OutdoorAmbient = OriginalSettings.Lighting.AtmosphereOriginal.OutdoorAmbient
            Lighting.ColorShift_Top = OriginalSettings.Lighting.AtmosphereOriginal.ColorShift_Top
            Lighting.ColorShift_Bottom = OriginalSettings.Lighting.AtmosphereOriginal.ColorShift_Bottom
            OriginalSettings.Lighting.AtmosphereOriginal = nil
        end
    end
})
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    end
    if AntiFlipEnabled then
        pcall(function()
            local tank = GetPlayerTank(LocalPlayer)
            if tank then
                local primaryPart = tank.PrimaryPart or tank:FindFirstChild("Hull") or tank:FindFirstChildWhichIsA("BasePart")
                if primaryPart and primaryPart:IsA("BasePart") then
                    local rotation = primaryPart.CFrame - primaryPart.Position
                    local upVector = rotation.UpVector
                    local angle = math.acos(math.clamp(upVector.Y, -1, 1))
                    if angle > math.rad(30) then
                        local pos = primaryPart.Position
                        local lookVector = primaryPart.CFrame.LookVector
                        lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
                        primaryPart.CFrame = CFrame.new(pos, pos + lookVector)
                        primaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
    end
    if NoRecoilEnabled then
        pcall(function()
            local camera = workspace.CurrentCamera
            if camera and camera.CFrame then
                local cf = camera.CFrame
                local lookVector = cf.LookVector
                local rightVector = cf.RightVector
                local upVector = Vector3.new(0, 1, 0)
                camera.CFrame = CFrame.new(cf.Position, cf.Position + lookVector)
            end
        end)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if ESPHighlights[player] then
        if ESPHighlights[player].highlight and ESPHighlights[player].highlight.Parent then
            ESPHighlights[player].highlight:Destroy()
        end
        if ESPHighlights[player].label and ESPHighlights[player].label.Parent then
            ESPHighlights[player].label:Destroy()
        end
        ESPHighlights[player] = nil
    end
end)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ph4smo_SteelTitans")
SaveManager:SetFolder("ph4smo_SteelTitans/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Tabs.Settings:AddButton({
    Title = "UnHook",
    Description = "Unload the script",
    Callback = function()
        Window:Dialog({
            Title = "UnHook Confirmation",
            Content = "Are you sure you want to unload the script?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        ESPEnabled = false
                        for _, data in pairs(ESPHighlights) do
                            if data.highlight and data.highlight.Parent then
                                data.highlight:Destroy()
                            end
                            if data.label and data.label.Parent then
                                data.label:Destroy()
                            end
                        end
                        local Lighting = game:GetService("Lighting")
                        if BlackSkyEnabled then
                            for _, obj in pairs(Lighting:GetChildren()) do
                                if obj:IsA("Sky") and OriginalSettings.Lighting.Sky then
                                    obj.SkyboxBk = OriginalSettings.Lighting.Sky.SkyboxBk
                                    obj.SkyboxDn = OriginalSettings.Lighting.Sky.SkyboxDn
                                    obj.SkyboxFt = OriginalSettings.Lighting.Sky.SkyboxFt
                                    obj.SkyboxLf = OriginalSettings.Lighting.Sky.SkyboxLf
                                    obj.SkyboxRt = OriginalSettings.Lighting.Sky.SkyboxRt
                                    obj.SkyboxUp = OriginalSettings.Lighting.Sky.SkyboxUp
                                    obj.StarCount = OriginalSettings.Lighting.Sky.StarCount
                                    obj.SunAngularSize = OriginalSettings.Lighting.Sky.SunAngularSize
                                    obj.MoonAngularSize = OriginalSettings.Lighting.Sky.MoonAngularSize
                                    obj.CelestialBodiesShown = OriginalSettings.Lighting.Sky.CelestialBodiesShown
                                end
                            end
                            if OriginalSettings.Lighting.Ambient then
                                Lighting.Ambient = OriginalSettings.Lighting.Ambient
                                Lighting.OutdoorAmbient = OriginalSettings.Lighting.OutdoorAmbient
                                Lighting.ColorShift_Top = OriginalSettings.Lighting.ColorShift_Top
                                Lighting.ColorShift_Bottom = OriginalSettings.Lighting.ColorShift_Bottom
                                Lighting.ClockTime = OriginalSettings.Lighting.ClockTime
                            end
                        end
                        if FlyEnabled then
                            StopFly()
                        end
                        if ModulesESPEnabled then
                            ClearModulesESP()
                        end
                        if OriginalSettings.Lighting.AtmosphereOriginal then
                            Lighting.Ambient = OriginalSettings.Lighting.AtmosphereOriginal.Ambient
                            Lighting.OutdoorAmbient = OriginalSettings.Lighting.AtmosphereOriginal.OutdoorAmbient
                            Lighting.ColorShift_Top = OriginalSettings.Lighting.AtmosphereOriginal.ColorShift_Top
                            Lighting.ColorShift_Bottom = OriginalSettings.Lighting.AtmosphereOriginal.ColorShift_Bottom
                        end
                        Fluent:Destroy()
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("UnHook cancelled")
                    end
                }
            }
        })
    end
})
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "👋 Welcome!",
    Content = "Welcome, " .. LocalPlayer.Name .. "!",
    Duration = 5
})

task.wait(0.1)
Window:SelectTab(1)
