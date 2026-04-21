-- ph4smo.club Key System GUI
-- Shows GUI for key input, validates and saves key

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local API_URL = "https://ph4smoapi.vercel.app/api/checkkey"
local KEY_STORAGE = "ph4smo_key_v1"

local function getHWID()
    local success, hwid = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    return success and hwid or "unknown"
end

local function saveKey(key)
    if writefile then
        writefile(KEY_STORAGE, key)
    end
end

local function loadSavedKey()
    if readfile and isfile and isfile(KEY_STORAGE) then
        return readfile(KEY_STORAGE)
    end
    return nil
end

local function formatTimeRemaining(minutes)
    if not minutes then
        return "Lifetime"
    end
    
    local hours = minutes / 60
    local days = hours / 24
    local months = days / 30
    local years = days / 365
    
    if years >= 1 then
        return string.format("%.1f year%s", years, years >= 2 and "s" or "")
    elseif months >= 1 then
        return string.format("%.1f month%s", months, months >= 2 and "s" or "")
    elseif days >= 1 then
        return string.format("%.1f day%s", days, days >= 2 and "s" or "")
    elseif hours >= 1 then
        return string.format("%.1f hour%s", hours, hours >= 2 and "s" or "")
    else
        return string.format("%d minute%s", minutes, minutes ~= 1 and "s" or "")
    end
end

local function validateKey(key)
    local hwid = getHWID()
    local url = API_URL .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)
    
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        return false, "Connection error"
    end
    
    local data = HttpService:JSONDecode(response)
    
    if data.valid then
        if data.lifetime then
            return true, "Lifetime key activated", data
        else
            local timeStr = formatTimeRemaining(data.expiresIn)
            return true, "Key valid for " .. timeStr, data
        end
    else
        local reasons = {
            invalid_key = "Invalid key",
            key_expired = "Key expired",
            hwid_mismatch = "Key bound to another device",
            key_banned = "Key banned",
            hwid_banned = "Device banned",
            rate_limited = "Too many requests",
            missing_params = "Invalid request"
        }
        return false, reasons[data.reason] or "Unknown error"
    end
end

local function createGUI()
    -- Create ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "ph4smoKeySystem"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 380, 0, 200)
    main.Position = UDim2.new(0.5, -190, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = main
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(45, 45, 45)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = main
    
    -- Top bar for dragging
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundTransparency = 1
    topBar.Parent = main
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0, 11)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = main
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "ph4smo.club"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = main
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 12)
    subtitle.Position = UDim2.new(0, 0, 0, 35)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "KEY SYSTEM"
    subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
    subtitle.TextSize = 9
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = main
    
    -- Key Input Frame
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -40, 0, 42)
    inputFrame.Position = UDim2.new(0, 20, 0, 60)
    inputFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = main
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputFrame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(1, -24, 1, 0)
    keyInput.Position = UDim2.new(0, 12, 0, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.Text = ""
    keyInput.PlaceholderText = "Paste your key here..."
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
    keyInput.TextSize = 13
    keyInput.Font = Enum.Font.Gotham
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.ClearTextOnFocus = false
    keyInput.Parent = inputFrame
    
    -- Status Label
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 110)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(140, 140, 140)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.TextWrapped = true
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = main
    
    -- Check Key Button
    local checkBtn = Instance.new("TextButton")
    checkBtn.Name = "CheckBtn"
    checkBtn.Size = UDim2.new(0, 165, 0, 38)
    checkBtn.Position = UDim2.new(0, 20, 0, 145)
    checkBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    checkBtn.BorderSizePixel = 0
    checkBtn.Text = "Check Key"
    checkBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    checkBtn.TextSize = 13
    checkBtn.Font = Enum.Font.GothamBold
    checkBtn.Parent = main
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 10)
    checkCorner.Parent = checkBtn
    
    -- Get Key Button
    local getBtn = Instance.new("TextButton")
    getBtn.Name = "GetBtn"
    getBtn.Size = UDim2.new(0, 165, 0, 38)
    getBtn.Position = UDim2.new(0, 195, 0, 145)
    getBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    getBtn.BorderSizePixel = 0
    getBtn.Text = "Get Key"
    getBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    getBtn.TextSize = 13
    getBtn.Font = Enum.Font.GothamBold
    getBtn.Parent = main
    
    local getCorner = Instance.new("UICorner")
    getCorner.CornerRadius = UDim.new(0, 10)
    getCorner.Parent = getBtn
    
    -- Dragging functionality
    local dragging = false
    local dragInput, mousePos, framePos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            main.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Button hover effects
    local function buttonHover(btn, hoverColor, normalColor)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
        end)
    end
    
    buttonHover(checkBtn, Color3.fromRGB(235, 235, 235), Color3.fromRGB(255, 255, 255))
    buttonHover(getBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(35, 35, 35))
    buttonHover(closeBtn, Color3.fromRGB(220, 50, 50), Color3.fromRGB(30, 30, 30))
    
    -- Close button click
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Check Key Button Click
    checkBtn.MouseButton1Click:Connect(function()
        local key = keyInput.Text:upper():gsub("%s+", "")
        
        if #key == 0 then
            status.Text = "Please enter a key"
            status.TextColor3 = Color3.fromRGB(239, 68, 68)
            return
        end
        
        status.Text = "Validating..."
        status.TextColor3 = Color3.fromRGB(140, 140, 140)
        checkBtn.Text = "Checking..."
        
        task.wait(0.3)
        
        local valid, message, data = validateKey(key)
        
        if valid then
            status.Text = message
            status.TextColor3 = Color3.fromRGB(34, 197, 94)
            checkBtn.Text = "Success!"
            
            saveKey(key)
            
            task.wait(1)
            gui:Destroy()
            
            -- Return success to continue loading
            return true
        else
            status.Text = message
            status.TextColor3 = Color3.fromRGB(239, 68, 68)
            checkBtn.Text = "Check Key"
            return false
        end
    end)
    
    -- Get Key Button Click
    getBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://ph4smoapi.vercel.app/get-key")
            status.Text = "Link copied!"
            status.TextColor3 = Color3.fromRGB(34, 197, 94)
        else
            status.Text = "Get key at: ph4smoapi.vercel.app"
            status.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end)
    
    -- Try to load saved key
    local savedKey = loadSavedKey()
    if savedKey then
        keyInput.Text = savedKey
    end
    
    gui.Parent = CoreGui
    
    return gui
end

-- Main execution
local savedKey = loadSavedKey()

if savedKey then
    local valid, message = validateKey(savedKey)
    
    if valid then
        print("[ph4smo.club] Key verified: " .. message)
        return true
    end
end

-- Show GUI if no valid key
print("[ph4smo.club] Please enter your key")
createGUI()

-- Wait for GUI to be closed (key entered)
repeat task.wait(0.5) until not CoreGui:FindFirstChild("ph4smoKeySystem")

-- Check if key was saved
savedKey = loadSavedKey()
if savedKey then
    local valid, message = validateKey(savedKey)
    if valid then
        print("[ph4smo.club] Key verified: " .. message)
        return true
    end
end

print("[ph4smo.club] No valid key entered")
return false
