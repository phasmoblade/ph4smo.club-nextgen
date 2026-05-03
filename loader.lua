-- ph4smo.club Loader (Official Recode)
-- Styled EXACTLY after https://ph4smo.vercel.app/

print("[ph4smo.club] Initializing...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local API_URL = "https://ph4smoapi.vercel.app/api/checkkey"
local KEY_STORAGE = "ph4smo_key_v2"
local VERIFIED_SIGNAL = "ph4smo_verified" -- Signal for game scripts

-- Cleanup old UIs
for _, obj in ipairs(CoreGui:GetChildren()) do
    if obj.Name:find("ph4smoLoader") then obj:Destroy() end
end

-- ============ CONFIGURATION ============

local SupportedGames = {
    [70845479499574] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/bbn.lua",
    [21532277] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/notoriety.lua",
}

-- ============ UTILS ============

local function getLoadstring()
    return (typeof(loadstring) == "function" and loadstring) or 
           (typeof(getfenv().loadstring) == "function" and getfenv().loadstring)
end

local function getHWID()
    local hwid = ""
    pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
    if hwid == "" then hwid = tostring(LocalPlayer.UserId) end
    return hwid
end

local function saveKey(key)
    if writefile then pcall(function() writefile(KEY_STORAGE, key) end) end
end

local function loadKey()
    if isfile and isfile(KEY_STORAGE) then
        local s, r = pcall(function() return readfile(KEY_STORAGE) end)
        return s and r or nil
    end
    return nil
end

-- ============ UI CREATION ============

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ph4smoLoader_Final"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(500, 400)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Анимация появления
local function fadeIn()
    MainFrame.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(500, 400)
    }):Play()
end

-- Анимация убирания
local function fadeOut(callback)
    local t = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0)
    })
    t:Play()
    t.Completed:Connect(function()
        if callback then callback() end
        ScreenGui:Destroy()
    end)
end

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(40, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
CloseBtn.TextSize = 30
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() fadeOut() end)

-- Main Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 100)
Title.Position = UDim2.new(0, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "ph4smo.club"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 65
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 110)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "key system"
Subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
Subtitle.TextSize = 14
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = MainFrame

-- Center Input Box
local InputBox = Instance.new("Frame")
InputBox.Size = UDim2.new(0, 380, 0, 60)
InputBox.Position = UDim2.new(0.5, 0, 0, 160)
InputBox.AnchorPoint = Vector2.new(0.5, 0)
InputBox.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
InputBox.Parent = MainFrame

local IBCorner = Instance.new("UICorner")
IBCorner.CornerRadius = UDim.new(0, 10)
IBCorner.Parent = InputBox

local IBStroke = Instance.new("UIStroke")
IBStroke.Color = Color3.fromRGB(20, 20, 20)
IBStroke.Thickness = 1
IBStroke.Parent = InputBox

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter Access Key Here"
KeyInput.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyInput.PlaceholderColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Code
KeyInput.Parent = InputBox

-- Verify Button
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0, 380, 0, 45)
VerifyBtn.Position = UDim2.new(0.5, 0, 0, 230)
VerifyBtn.AnchorPoint = Vector2.new(0.5, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "verify"
VerifyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
VerifyBtn.TextSize = 16
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.AutoButtonColor = true
VerifyBtn.Parent = MainFrame

local VCorner = Instance.new("UICorner")
VCorner.CornerRadius = UDim.new(0, 8)
VCorner.Parent = VerifyBtn

-- Get Key Button (Simple)
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 380, 0, 45)
GetKeyBtn.Position = UDim2.new(0.5, 0, 0, 285)
GetKeyBtn.AnchorPoint = Vector2.new(0.5, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
GetKeyBtn.Text = "get key"
GetKeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
GetKeyBtn.TextSize = 16
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.AutoButtonColor = true
GetKeyBtn.Parent = MainFrame

local GKCorner = Instance.new("UICorner")
GKCorner.CornerRadius = UDim.new(0, 8)
GKCorner.Parent = GetKeyBtn

local GKStroke = Instance.new("UIStroke")
GKStroke.Color = Color3.fromRGB(30, 30, 30)
GKStroke.Thickness = 1
GKStroke.Parent = GetKeyBtn

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard("https://ph4smoapi.vercel.app/get-key") end
    StatusLabel.Text = "link copied to clipboard!"
    task.delay(2, function() if StatusLabel.Text == "link copied to clipboard!" then StatusLabel.Text = "" end end)
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 345)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- ============ LOGIC ============

local function getHttpGet()
    if game and typeof(game.HttpGet) == "function" then
        return function(url) return game:HttpGet(url) end
    elseif typeof(HttpGet) == "function" then
        return HttpGet
    end
    return nil
end

local function verify(key)
    if not key or key == "" then return end
    StatusLabel.Text = "checking..."
    
    local httpGet = getHttpGet()
    if not httpGet then
        StatusLabel.Text = "http error"
        warn("[ph4smo.club] Error: HttpGet not found.")
        return
    end

    local hwid = getHWID()
    local url = string.format("%s?key=%s&hwid=%s&timestamp=%d", API_URL, HttpService:UrlEncode(key), HttpService:UrlEncode(hwid), os.time())
    
    local success, response = pcall(function() return httpGet(url) end)
    
    if success and response then
        local keyData
        local decodeSuccess = pcall(function() keyData = HttpService:JSONDecode(response) end)
        
        if decodeSuccess and keyData and keyData.valid == true then
            StatusLabel.Text = "success! loading..."
            saveKey(key)
            _G.ph4smo_verified = true
            if keyData.premium then _G.ph4smo_premium = true end
            task.wait(0.5)
            
            local gUrl = SupportedGames[game.GameId] or SupportedGames[game.PlaceId]
            if gUrl then
                StatusLabel.Text = "executing..."
                local success2, content = pcall(function() return httpGet(gUrl) end)
                if success2 and content then
                    local scriptName = gUrl:match("([^/]+)%.lua$") or "Script"
                    local ls = getLoadstring()
                    
                    if ls then
                        local func, err = ls(content, scriptName)
                        if func then
                            fadeOut(function()
                                task.spawn(function()
                                    local s, e = pcall(func)
                                    if not s then 
                                        local errorMsg = tostring(e)
                                        warn("[ph4smo.club] " .. scriptName .. " Error: " .. errorMsg)
                                    end
                                end)
                            end)
                        else
                            StatusLabel.Text = "compile error"
                            warn("[ph4smo.club] Compile Error: " .. tostring(err))
                        end
                    else
                        StatusLabel.Text = "no loadstring found"
                        warn("[ph4smo.club] Error: Your executor does not support loadstring.")
                    end
                else
                    StatusLabel.Text = "download error"
                end
            else
                StatusLabel.Text = "game not supported"
            end
        else
            StatusLabel.Text = "invalid key"
        end
    else
        StatusLabel.Text = "server error"
    end
end

VerifyBtn.MouseButton1Click:Connect(function()
    verify(KeyInput.Text:gsub("%s+", ""))
end)

-- Saved Key
local sk = loadKey()
fadeIn() 

if sk then
    KeyInput.Text = sk
    task.spawn(function() verify(sk) end)
end

-- Dragging
local d, di, ds, sp
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        d = true ds = i.Position sp = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - ds
        MainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
end)
