wait(3)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowSize = isMobile and UDim2.fromOffset(400, 350) or UDim2.fromOffset(580, 460)

local Window = Fluent:CreateWindow({
    Title = "🚪 > ph4smo.club (nextgen) - Doors",
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
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Protection = Window:AddTab({ Title = "Protection", Icon = "shield" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "palette" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

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

local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local Remotes = ReplicatedStorage:FindFirstChild("EntityInfo") or ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
local espSettings = {
    distance = true,
    targetFov = 70,
    fovEnabled = false,
    colors = {
        item = Color3.fromRGB(0, 255, 150),
        monster = Color3.fromRGB(255, 50, 50),
        key = Color3.fromRGB(255, 255, 0),
        gold = Color3.fromRGB(255, 215, 0),
        player = Color3.fromRGB(150, 0, 255),
        door = Color3.fromRGB(0, 255, 255),
        objective = Color3.fromRGB(0, 100, 255),
        hiding = Color3.fromRGB(100, 100, 100),
        shed = Color3.fromRGB(139, 69, 19)
    }
}
local ActiveESPs = {}
local charMods = {canJump = false, canSlide = false}
local goldAmount = 50
local instantInteractActive = false
local monsterWarnActive = false
local lightLoop = nil
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if charMods.canJump then char:SetAttribute("CanJump", true) end
    if charMods.canSlide then char:SetAttribute("CanSlide", true) end
end)
local function ToggleRemote(name, state)
    local remote = Remotes:FindFirstChild(name) or _G[name .. "_Storage"]
    if state then
        if remote then
            _G[name .. "_Storage"] = remote
            remote.Parent = nil
        end
    else
        local storage = _G[name .. "_Storage"]
        if storage then
            storage.Parent = Remotes
        end
    end
end
local WarningGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
WarningGui.Name = "ph4smo_WarningGui"
local WarningLabel = Instance.new("TextLabel", WarningGui)
WarningLabel.Size = UDim2.new(1, 0, 0, 100)
WarningLabel.Position = UDim2.new(0, 0, 0.2, 0)
WarningLabel.BackgroundTransparency = 1
WarningLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
WarningLabel.TextStrokeTransparency = 0
WarningLabel.Font = Enum.Font.GothamBlack
WarningLabel.TextSize = 50
WarningLabel.Visible = false
WarningLabel.Text = "🚨 MONSTER INCOMING! HIDE! 🚨"
local function ClearESPType(typeKey)
    for i = #ActiveESPs, 1, -1 do
        local esp = ActiveESPs[i]
        if esp.Type == typeKey or typeKey == "all" then
            if esp.Billboard then esp.Billboard:Destroy() end
            if esp.Highlight then esp.Highlight:Destroy() end
            table.remove(ActiveESPs, i)
        end
    end
end
local function ManageESP(model, part, text, colorType)
    if not part or not model then return end
    if part:FindFirstChild("ph4smo_ESP_" .. colorType) then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ph4smo_Highlight_" .. colorType
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.new(1,1,1)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = part
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ph4smo_ESP_" .. colorType
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.MaxDistance = 500
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Text = text
    billboard.Parent = part
    table.insert(ActiveESPs, {
        Model = model, Part = part, Billboard = billboard, Highlight = hl,
        Text = text, Type = colorType, Label = label
    })
end
RunService.RenderStepped:Connect(function()
    for i = #ActiveESPs, 1, -1 do
        local esp = ActiveESPs[i]
        if not esp.Model or not esp.Model.Parent then
            if esp.Billboard then esp.Billboard:Destroy() end
            if esp.Highlight then esp.Highlight:Destroy() end
            table.remove(ActiveESPs, i)
            continue
        end
        local c = espSettings.colors[esp.Type] or Color3.new(1,1,1)
        esp.Label.TextColor3 = c
        esp.Highlight.FillColor = c
        esp.Highlight.OutlineColor = c
        if espSettings.distance and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local dist = math.floor((esp.Part.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude)
            esp.Label.Text = esp.Text .. " [" .. dist .. "m]"
        else
            esp.Label.Text = esp.Text
        end
    end
end)
Tabs.Main:AddParagraph({
    Title = "💰 Gold",
    Content = "Add gold to your account"
})
Tabs.Main:AddSlider("GoldAmount", {
    Title = "Gold Amount",
    Description = "Amount of gold to add",
    Default = 50,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        goldAmount = Value
    end
})
Tabs.Main:AddButton({
    Title = "Add Gold",
    Description = "Add gold to your account",
    Callback = function()
        local goldObj = LocalPlayer:FindFirstChild("Gold")
        if goldObj then 
            goldObj.Value = goldObj.Value + goldAmount 
            Fluent:Notify({
                Title = "Success",
                Content = goldAmount .. " gold added!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "❌ Error",
                Content = "Gold data not found",
                Duration = 3
            })
        end
    end
})
Tabs.Main:AddParagraph({
    Title = "🏃 Movement",
    Content = "Movement modifications"
})
Tabs.Main:AddToggle("Jump", {
    Title = "Enable Jump",
    Description = "Allow jumping",
    Default = false,
    Callback = function(Value)
        charMods.canJump = Value
        if LocalPlayer.Character then 
            LocalPlayer.Character:SetAttribute("CanJump", Value) 
        end
    end
})
Tabs.Main:AddToggle("Slide", {
    Title = "Enable Slide",
    Description = "Allow sliding",
    Default = false,
    Callback = function(Value)
        charMods.canSlide = Value
        if LocalPlayer.Character then 
            LocalPlayer.Character:SetAttribute("CanSlide", Value) 
        end
    end
})
Tabs.Main:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Adjust walk speed",
    Default = 16,
    Min = 16,
    Max = 45,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})
Tabs.Main:AddParagraph({
    Title = "📷 Camera",
    Content = "Camera settings"
})
Tabs.Main:AddToggle("CustomFOV", {
    Title = "Custom FOV",
    Description = "Enable custom field of view",
    Default = false,
    Callback = function(Value)
        espSettings.fovEnabled = Value
        if not Value then
            Camera.FieldOfView = 70
        end
    end
})
Tabs.Main:AddSlider("FOV", {
    Title = "Field of View",
    Description = "Adjust camera FOV",
    Default = 70,
    Min = 70,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        espSettings.targetFov = Value
    end
})
RunService:BindToRenderStep("ph4smo_FOV", Enum.RenderPriority.Camera.Value + 1, function()
    if espSettings.fovEnabled then
        Camera.FieldOfView = espSettings.targetFov
    end
end)
Tabs.Main:AddParagraph({
    Title = "🤝 Interaction",
    Content = "Interaction modifications"
})
Tabs.Main:AddToggle("InstantInteract", {
    Title = "Instant Interact",
    Description = "Remove hold duration from prompts",
    Default = false,
    Callback = function(Value)
        instantInteractActive = Value
    end
})
Tabs.Main:AddToggle("MonsterWarning", {
    Title = "Monster Warning",
    Description = "Show warning when monster spawns",
    Default = false,
    Callback = function(Value)
        monsterWarnActive = Value
    end
})
workspace.ChildAdded:Connect(function(child)
    if monsterWarnActive then
        local name = child.Name:lower()
        if name:find("rush") or name:find("ambush") or name:find("eyes") or name:find("halt") then
            WarningLabel.Visible = true
            task.delay(4, function() WarningLabel.Visible = false end)
        end
    end
end)
Tabs.Main:AddToggle("Fullbright", {
    Title = "Fullbright",
    Description = "Night vision mode",
    Default = false,
    Callback = function(Value)
        if Value then
            lightLoop = RunService.RenderStepped:Connect(function()
                game.Lighting.Ambient = Color3.new(1, 1, 1)
                game.Lighting.Brightness = 2
                game.Lighting.FogEnd = 100000
                game.Lighting.GlobalShadows = false
            end)
        else
            if lightLoop then lightLoop:Disconnect() end
            game.Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            game.Lighting.GlobalShadows = true
        end
    end
})
Tabs.Protection:AddParagraph({
    Title = "👻 Anti-Entity",
    Content = "Protection from entities"
})
Tabs.Protection:AddToggle("AntiA90", {
    Title = "Anti A-90",
    Description = "Disable A-90 entity",
    Default = false,
    Callback = function(Value)
        ToggleRemote("A90", Value)
    end
})
Tabs.Protection:AddToggle("AntiDread", {
    Title = "Anti Dread",
    Description = "Disable Dread entity",
    Default = false,
    Callback = function(Value)
        ToggleRemote("Dread", Value)
    end
})
Tabs.Protection:AddToggle("AntiScreech", {
    Title = "Anti Screech",
    Description = "Disable Screech entity",
    Default = false,
    Callback = function(Value)
        ToggleRemote("Screech", Value)
    end
})
Tabs.Protection:AddToggle("AntiGiggle", {
    Title = "Anti Giggle",
    Description = "Disable Giggle entity",
    Default = false,
    Callback = function(Value)
        ToggleRemote("Giggle", Value)
    end
})
Tabs.Protection:AddToggle("AntiHaste", {
    Title = "Anti Haste",
    Description = "Disable Haste entity",
    Default = false,
    Callback = function(Value)
        ToggleRemote("Haste", Value)
    end
})
Tabs.Protection:AddToggle("AntiCamShake", {
    Title = "Anti Camera Shake",
    Description = "Disable camera shake effects",
    Default = false,
    Callback = function(Value)
        local list = {"CamShake", "CamShakeClient", "CamShakeRelative", "CamShakeRelativeClient"}
        for _, name in pairs(list) do 
            ToggleRemote(name, Value) 
        end
    end
})
local tracker = {
    items = false,
    monsters = false,
    keys = false,
    gold = false,
    players = false,
    doors = false,
    objectives = false,
    hiding = false,
    shed = false
}
Tabs.ESP:AddParagraph({
    Title = "📍 ESP Settings",
    Content = "Toggle ESP for different objects"
})
Tabs.ESP:AddToggle("ItemESP", {
    Title = "Item ESP",
    Description = "Show items (lighter, flashlight, etc)",
    Default = false,
    Callback = function(Value)
        tracker.items = Value
        if not Value then ClearESPType("item") end
    end
})
Tabs.ESP:AddToggle("KeyESP", {
    Title = "Key ESP",
    Description = "Show keys",
    Default = false,
    Callback = function(Value)
        tracker.keys = Value
        if not Value then ClearESPType("key") end
    end
})
Tabs.ESP:AddToggle("GoldESP", {
    Title = "Gold ESP",
    Description = "Show gold piles",
    Default = false,
    Callback = function(Value)
        tracker.gold = Value
        if not Value then ClearESPType("gold") end
    end
})
Tabs.ESP:AddToggle("ObjectiveESP", {
    Title = "Objective ESP",
    Description = "Show objectives (books, levers, etc)",
    Default = false,
    Callback = function(Value)
        tracker.objectives = Value
        if not Value then ClearESPType("objective") end
    end
})
Tabs.ESP:AddToggle("HidingESP", {
    Title = "Hiding Spot ESP",
    Description = "Show hiding spots (lockers, wardrobes)",
    Default = false,
    Callback = function(Value)
        tracker.hiding = Value
        if not Value then ClearESPType("hiding") end
    end
})
Tabs.ESP:AddToggle("ShedESP", {
    Title = "Toolshed ESP",
    Description = "Show toolsheds",
    Default = false,
    Callback = function(Value)
        tracker.shed = Value
        if not Value then ClearESPType("shed") end
    end
})
Tabs.ESP:AddToggle("MonsterESP", {
    Title = "Monster ESP",
    Description = "Show monsters",
    Default = false,
    Callback = function(Value)
        tracker.monsters = Value
        if not Value then ClearESPType("monster") end
    end
})
Tabs.ESP:AddToggle("DoorESP", {
    Title = "Door ESP",
    Description = "Show doors",
    Default = false,
    Callback = function(Value)
        tracker.doors = Value
        if not Value then ClearESPType("door") end
    end
})
Tabs.ESP:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Description = "Show other players",
    Default = false,
    Callback = function(Value)
        tracker.players = Value
        if not Value then ClearESPType("player") end
    end
})
Tabs.Visual:AddParagraph({
    Title = "🎨 ESP Visual Settings",
    Content = "Customize ESP appearance"
})
Tabs.Visual:AddToggle("ShowDistance", {
    Title = "Show Distance",
    Description = "Display distance to objects",
    Default = true,
    Callback = function(Value)
        espSettings.distance = Value
    end
})
Tabs.Visual:AddColorpicker("ItemColor", {
    Title = "Item Color",
    Default = espSettings.colors.item,
    Callback = function(Value)
        espSettings.colors.item = Value
    end
})
Tabs.Visual:AddColorpicker("MonsterColor", {
    Title = "Monster Color",
    Default = espSettings.colors.monster,
    Callback = function(Value)
        espSettings.colors.monster = Value
    end
})
Tabs.Visual:AddColorpicker("ObjectiveColor", {
    Title = "Objective Color",
    Default = espSettings.colors.objective,
    Callback = function(Value)
        espSettings.colors.objective = Value
    end
})
Tabs.Visual:AddColorpicker("HidingColor", {
    Title = "Hiding Spot Color",
    Default = espSettings.colors.hiding,
    Callback = function(Value)
        espSettings.colors.hiding = Value
    end
})
task.spawn(function()
    local ObjList = {"LibraryHintPaper", "LiveHintBook", "LeverForGate", "LiveBreakerPolePickup", "ElectricalKeyObtain"}
    local HSList = {"Locker_Large", "Wardrobe", "Bed", "Backdoor_Wardrobe", "Rooms_Locker", "CircularVent"}
    while task.wait(1) do
        pcall(function()
            if instantInteractActive then
                for _, prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                    end
                end
            end
            if tracker.items or tracker.keys or tracker.gold or tracker.objectives or tracker.hiding or tracker.shed then
                for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if v:IsA("Model") then
                        local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                        if p then
                            local n = v.Name
                            if tracker.items and (n == "Lighter" or n == "Flashlight" or n == "Crucifix" or n == "Lockpick" or n == "Vitamins" or n == "Bandage" or n == "SkeletonKey") then
                                ManageESP(v, p, "Item", "item")
                            end
                            if tracker.keys and n == "KeyObtain" then
                                ManageESP(v, p, "Key", "key")
                            end
                            if tracker.gold and n == "GoldPile" then
                                ManageESP(v, p, "Gold", "gold")
                            end
                            if tracker.objectives and table.find(ObjList, n) then
                                local d = (n == "LiveHintBook" and "Book") or (n == "LeverForGate" and "Lever") or (n == "LiveBreakerPolePickup" and "Breaker") or (n == "ElectricalKeyObtain" and "Electrical Key") or "Objective"
                                ManageESP(v, p, d, "objective")
                            end
                            if tracker.hiding and table.find(HSList, n) then
                                ManageESP(v, p, "Hiding", "hiding")
                            end
                            if tracker.shed and n == "Toolshed_Small" then
                                ManageESP(v, p, "Toolshed", "shed")
                            end
                        end
                    end
                end
            end
            if tracker.doors then
                for _, r in pairs(workspace.CurrentRooms:GetChildren()) do
                    local d = r:FindFirstChild("Door")
                    if d then
                        local doorPart = d:FindFirstChild("Door") or d:FindFirstChild("Hinge") or d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                        if doorPart and not doorPart:FindFirstChild("ph4smo_ESP_door") then
                            ManageESP(d, doorPart, "Door #" .. r.Name, "door")
                        end
                    end
                end
            end
            if tracker.monsters then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and (v.Name == "RushMoving" or v.Name == "AmbushMoving" or v.Name == "Eyes" or v.Name == "FigureRig" or v.Name == "Seek") then
                        local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                        if p then ManageESP(v, p, "MONSTER", "monster") end
                    end
                end
            end
            if tracker.players then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        ManageESP(p.Character, p.Character.PrimaryPart, p.Name, "player")
                    end
                end
            end
        end)
    end
end)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ph4smo_Doors")
SaveManager:SetFolder("ph4smo_Doors/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Tabs.Settings:AddButton({
    Title = "Rejoin",
    Description = "Rejoin current server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})
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
                        ClearESPType("all")
                        RunService:UnbindFromRenderStep("ph4smo_FOV")
                        if WarningGui then WarningGui:Destroy() end
                        if lightLoop then lightLoop:Disconnect() end
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

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    task.wait(0.5)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ph4smo_MobileButton"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    local Button = Instance.new("TextButton")
    Button.Name = "ToggleButton"
    Button.Size = UDim2.new(0, 60, 0, 60)
    Button.Position = UDim2.new(0, 10, 0.5, -30)
    Button.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    Button.Text = "🚪"
    Button.TextSize = 32
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Active = true
    Button.Parent = ScreenGui
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Button
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(150, 100, 200)
    Stroke.Thickness = 2
    Stroke.Parent = Button
    local dragging = false
    local dragInput, dragStart, startPos
    local dragThreshold = 10
    local hasMoved = false
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position
            hasMoved = false
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not hasMoved then
                        local success, err = pcall(function()
                            Window:Minimize()
                        end)
                        if not success then
                            print("[ph4smo.club] Toggle error:", err)
                        end
                    end
                end
            end)
        end
    end)
    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > dragThreshold then
                hasMoved = true
            end
            if hasMoved then
                Button.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    print("[ph4smo.club] Mobile button created! Tap to toggle menu")
end
