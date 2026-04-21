-- ph4smo.club game script loader
-- This loader only loads game scripts (key verification is done by key-system.lua)

local PlaceId = game.PlaceId

local SupportedGames = {
    [2440500124] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/flick.lua",
    [3956818381] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/ninja-legends.lua",
    [4746041618] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/steel-titans.lua",
    [6516141723] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/doors.lua",
    [6961824067] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/ftap.lua",
    [7336302630] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/project-delta.lua",
    [70845479499574] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/bite-by-night.lua",
    [79305036070450] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/spin-a-baddie.lua"
}

local function loadScript(url)
    print("[ph4smo.club] Loading script from: " .. url)
    
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        warn("[ph4smo.club] Failed to download script: " .. tostring(result))
        return false
    end
    
    local func, compileError = loadstring(result)
    
    if not func then
        warn("[ph4smo.club] Script compile error: " .. tostring(compileError))
        return false
    end
    
    local loadSuccess, loadError = pcall(func)
    
    if not loadSuccess then
        warn("[ph4smo.club] Script execution error: " .. tostring(loadError))
        return false
    end
    
    print("[ph4smo.club] Script loaded successfully!")
    return true
end

-- Main execution
print("[ph4smo.club] Game loader started")

if SupportedGames[PlaceId] then
    print("[ph4smo.club] Supported game detected (ID: " .. PlaceId .. ")")
    loadScript(SupportedGames[PlaceId])
else
    print("[ph4smo.club] Universal script loading...")
    loadScript("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/main-script.lua")
end
