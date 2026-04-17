wait(3)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowSize = isMobile and UDim2.fromOffset(400, 350) or UDim2.fromOffset(580, 460)

local Window = Fluent:CreateWindow({
    Title = "⚔️ > ph4smo.club (nextgen) - Ninja Legends",
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
    Main = Window:AddTab({ Title = "Main", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

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

local Settings = {
    InfiniteMoney = false
}

local Connections = {}

-- Infinite Money (Coins + Gems)
Tabs.Main:AddToggle("InfiniteMoney", {
    Title = "Infinite Money",
    Description = "Auto farm infinite coins and gems",
    Default = false,
    Callback = function(v)
        Settings.InfiniteMoney = v
        if v then
            Connections.InfiniteMoney = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if game.Players.LocalPlayer.PlayerGui.gameGui.sideButtons.excludeFolder.gemsFrame.amountLabel.Text:lower() == "inf" then
                        game.ReplicatedStorage.rEvents.zenMasterEvent:FireServer("convertGems", 1e+124)
                    else
                        game.ReplicatedStorage.rEvents.zenMasterEvent:FireServer("convertGems", -math.huge)
                        for Y, k in pairs({"Shadow Charge", "Electral Chaos", "Blazing Entity", "Shadowfire", "Lightning", "Masterful Wrath", "Inferno", "Eternity Storm", "Frost"}) do
                            pcall(function()
                                game.ReplicatedStorage.rEvents.elementMasteryEvent:FireServer(k)
                            end)
                        end
                    end
                end)
            end)
            Fluent:Notify({
                Title = "Infinite Money",
                Content = "Infinite Money enabled!",
                Duration = 3
            })
        else
            if Connections.InfiniteMoney then
                Connections.InfiniteMoney:Disconnect()
            end
            Fluent:Notify({
                Title = "Infinite Money",
                Content = "Infinite Money disabled!",
                Duration = 3
            })
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ph4smo_NinjaLegends")
SaveManager:SetFolder("ph4smo_NinjaLegends/configs")
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
