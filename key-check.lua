--[[ 

██████╗ ██╗  ██╗██╗  ██╗███████╗███╗   ███╗ ██████╗     ██████╗██╗     ██╗   ██╗██████╗ 
██╔══██╗██║  ██║██║  ██║██╔════╝████╗ ████║██╔═══██╗   ██╔════╝██║     ██║   ██║██╔══██╗
██████╔╝███████║███████║███████╗██╔████╔██║██║   ██║   ██║     ██║     ██║   ██║██████╔╝
██╔═══╝ ██╔══██║╚════██║╚════██║██║╚██╔╝██║██║   ██║   ██║     ██║     ██║   ██║██╔══██╗
██║     ██║  ██║     ██║███████║██║ ╚═╝ ██║╚██████╔╝██╗╚██████╗███████╗╚██████╔╝██████╔╝
╚═╝     ╚═╝  ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝ ╚═════╝╚══════╝ ╚═════╝ ╚═════╝ 

        Obfuscated by ph4smo.club | Advanced Protection System v2.0
        https://github.com/phasmoblade | @phasmoblade

]]
local HttpService = game:GetService("HttpService")
local API_URL = "https://ph4smoapi.vercel.app/api/checkkey"
local KEY_STORAGE = "ph4smo_key_v1"

local function getHWID()
    local success, hwid = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    return success and hwid or "unknown"
end

local function loadSavedKey()
    if readfile and isfile then
        if isfile(KEY_STORAGE) then
            return readfile(KEY_STORAGE)
        end
    end
    return nil
end

local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
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
            return true, "Lifetime key", data
        else
            local timeStr = formatTimeRemaining(data.expiresIn)
            return true, "Valid for " .. timeStr, data
        end
    else
        local reasons = {
            invalid_key = "Invalid key",
            key_expired = "Key expired",
            hwid_mismatch = "Key bound to another device",
            hwid_has_key = "Device already has an active key",
            key_banned = "Key banned",
            hwid_banned = "Device banned",
            rate_limited = "Too many requests",
            missing_params = "Invalid request"
        }
        return false, reasons[data.reason] or "Unknown error"
    end
end


local function verifyKey()
    local savedKey = loadSavedKey()
    
    if not savedKey or #savedKey == 0 then
        notify("ph4smo.club", "No key found!", 5)
        notify("ph4smo.club", "Please run the loader first to enter your key", 10)
        notify("ph4smo.club", "Loader: loadstring(game:HttpGet('https://ph4smo.vercel.app/api/loader'))()", 15)
        return false
    end
    
    local valid, message = validateKey(savedKey)
    
    if not valid then
        notify("ph4smo.club", "Key invalid: " .. message, 10)
        notify("ph4smo.club", "Please run the loader to enter a new key", 10)
        return false
    end
    
    notify("ph4smo.club", message, 5)
    return true
end


return verifyKey
