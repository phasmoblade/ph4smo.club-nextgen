local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local windowSize = isMobile and UDim2.fromOffset(480, 360) or UDim2.fromOffset(580, 460)

local Window = Fluent:CreateWindow({
    Title = "🌟 > ph4smo.club (nextgen)",
    SubTitle = "by phasmoblade",
    TabWidth = 160,
    Size = windowSize,
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

if isMobile then
    local MinimizeButton = Window:AddButton({
        Title = "Toggle GUI",
        Callback = function()
            Window:Minimize()
        end
    })
end

-- Create mobile toggle button
if isMobile then
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create ScreenGui for the button
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Ph4smoToggleButton"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    -- Create the button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.fromOffset(60, 60)
    ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "🌌"
    ToggleButton.TextSize = 30
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ScreenGui
    
    -- Add corner radius
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = ToggleButton
    
    -- Add stroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(100, 100, 100)
    UIStroke.Thickness = 2
    UIStroke.Parent = ToggleButton
    
    -- Toggle functionality
    local isVisible = true
    ToggleButton.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        Window:SetOpen(isVisible)
    end)
    
    -- Make button draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Universal = Window:AddTab({ Title = "Universal Scripts", Icon = "globe" }),
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Invisible FE Script
do
    -- Add key binding option for Invisible FE
    local invisKey = Tabs.Player:AddDropdown("InvisKey", {
        Title = "Invisibility Key",
        Values = {"Q", "E", "R", "F", "G", "V", "B", "C", "X", "Z"},
        Default = "X",
        Multi = false,
        Callback = function(Value)
            Options.InvisKey.Value = Value
        end
    })
    
    Options.InvisKey = invisKey
    
    -- Invisible FE Script
    Tabs.Player:AddButton({
        Title = "Invisible FE (Toggle)",
        Description = "Toggle Invisibility with selected key",
        Callback = function()
            local key = Options.InvisKey.Value or "X"
            local keyCode
            if key == "Q" then keyCode = Enum.KeyCode.Q
            elseif key == "E" then keyCode = Enum.KeyCode.E
            elseif key == "R" then keyCode = Enum.KeyCode.R
            elseif key == "F" then keyCode = Enum.KeyCode.F
            elseif key == "G" then keyCode = Enum.KeyCode.G
            elseif key == "V" then keyCode = Enum.KeyCode.V
            elseif key == "B" then keyCode = Enum.KeyCode.B
            elseif key == "C" then keyCode = Enum.KeyCode.C
            elseif key == "X" then keyCode = Enum.KeyCode.X
            elseif key == "Z" then keyCode = Enum.KeyCode.Z
            else keyCode = Enum.KeyCode.X
            end
            
            local key = keyCode
            local invis_on = false
            
            local function onKeyPress(inputObject, gameProcessed)
                if gameProcessed then return end
                if inputObject.KeyCode == key then
                    invis_on = not invis_on
                    if invis_on then
                        local savedpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        wait()
                        game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
                        wait(0.15)
                        local Seat = Instance.new('Seat', game.Workspace)
                        Seat.Anchored = false
                        Seat.CanCollide = false
                        Seat.Name = 'invischair'
                        Seat.Transparency = 1
                        Seat.Position = Vector3.new(-25.95, 84, 3537.55)
                        local Weld = Instance.new("Weld", Seat)
                        Weld.Part0 = Seat
                        Weld.Part1 = game.Players.LocalPlayer.Character:FindFirstChild("Torso") or game.Players.LocalPlayer.Character:FindFirstChild("UpperTorso")
                        wait()
                        Seat.CFrame = savedpos
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Invis On",
                            Duration = 1,
                            Text = ""
                        })
                    else
                        local chair = workspace:FindFirstChild('invischair')
                        if chair then
                            chair:Destroy()
                        end
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Invis Off",
                            Duration = 1,
                            Text = ""
                        })
                    end
                end
            end
            
            game:GetService("UserInputService").InputBegan:Connect(onKeyPress)
            
            Fluent:Notify({
                Title = "Invisible FE",
                Content = "Invisible FE script loaded! Press " .. tostring(key) .. " to toggle",
                Duration = 3
            })
        end
    })
end

-- Universal Scripts Tab
do
    Tabs.Universal:AddParagraph({
        Title = "Universal Scripts",
        Content = "Load various universal scripts that work in most games"
    })
    
    -- Infinite Yield
    Tabs.Universal:AddButton({
        Title = "Infinite Yield",
        Description = "Load Infinite Yield admin script",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            Fluent:Notify({
                Title = "Infinite Yield",
                Content = "Loading Infinite Yield...",
                Duration = 3
            })
        end
    })
    
    -- Dex Explorer
    Tabs.Universal:AddButton({
        Title = "Dex Explorer",
        Description = "Load Dex Explorer",
        Callback = function()
            loadstring(game:HttpGet("https://gist.githubusercontent.com/someunknowndude/38cecea5be9d75cb743eac8b1eaf6758/raw"))()
            Fluent:Notify({
                Title = "Dex Explorer",
                Content = "Loading Dex Explorer...",
                Duration = 3
            })
        end
    })
    
    -- Fly GUI V3
    Tabs.Universal:AddButton({
        Title = "Fly GUI V3",
        Description = "Load Fly GUI V3",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
            Fluent:Notify({
                Title = "Fly GUI V3",
                Content = "Loading Fly GUI V3...",
                Duration = 3
            })
        end
    })
end

do
    Fluent:Notify({
        Title = "ph4smo.club",
        Content = "Game Not Supported",
        SubContent = "This game is not supported yet, but you can use Universal Scripts",
        Duration = 8
    })

    -- Get player and system information
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    
    -- Detect executor
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
    
    -- Detect platform
    local platform = "Unknown"
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        platform = "Android/Mobile"
    elseif UserInputService.KeyboardEnabled then
        platform = "Windows/PC"
    end
    
    -- Get place info
    local placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local placeId = tostring(game.PlaceId)
    local jobId = game.JobId
    
    Tabs.Info:AddParagraph({
        Title = "Game Not Supported",
        Content = "This game is not currently supported by ph4smo.club scripts.\n\nSupported games:\n🪓 Bite By Night\n🎲 Spin a Baddie\n⚔️ Steel Titans\n🚪 Doors\n🥷 Ninja Legends\n🎯 FTAP (Fling Things and People)\n\nMore games coming soon!"
    })
    
    Tabs.Info:AddParagraph({
        Title = "Player Information",
        Content = "Username: " .. LocalPlayer.Name .. "\nDisplay Name: " .. LocalPlayer.DisplayName .. "\nUser ID: " .. tostring(LocalPlayer.UserId) .. "\nAccount Age: " .. tostring(LocalPlayer.AccountAge) .. " days"
    })
    
    -- System Info Section
    Tabs.Info:AddParagraph({
        Title = "System Information",
        Content = "Executor: " .. executor .. "\nPlatform: " .. platform .. "\nFPS: " .. tostring(math.floor(workspace:GetRealPhysicsFPS()))
    })
    
    -- Place Info Section
    Tabs.Info:AddParagraph({
        Title = "Place Information",
        Content = "Place Name: " .. placeName .. "\nPlace ID: " .. placeId .. "\nJob ID: " .. jobId
    })
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)

-- UnHook button in Interface section
Tabs.Settings:AddButton({
    Title = "UnHook",
    Description = "Unload the GUI and all related elements",
    Callback = function()
        Window:Dialog({
            Title = "UnHook Confirmation",
            Content = "Are you sure you want to unload the script?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        Fluent:Notify({
                            Title = "UnHook",
                            Content = "Unloading script...",
                            Duration = 2
                        })
                        
                        wait(0.5)
                        
                        -- Unload Fluent library
                        Fluent:Destroy()
                        
                        -- Clean up any remaining connections or loops
                        for _, connection in pairs(getconnections(game:GetService("RunService").RenderStepped)) do
                            connection:Disconnect()
                        end
                        
                        print("Script unloaded successfully")
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


Window:SelectTab(1)

Fluent:Notify({
    Title = "ph4smo.club",
    Content = "Loading...",
    Duration = 3
})

task.wait(3)

Fluent:Notify({
    Title = "👋 Welcome!",
    Content = "Welcome, " .. LocalPlayer.Name .. "!",
    SubContent = "Game not supported - showing info only. Check Universal Scripts tab for scripts that work in any game!",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()