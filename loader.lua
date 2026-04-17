local PlaceId = game.PlaceId

local SupportedGames = {
    [4746041618] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/steel-titans.lua",
    [6516141723] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/doors.lua",
    [79305036070450] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/spin-a-baddie.lua",
    [70845479499574] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/bite-by-night.lua",
    [6961824067] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/ftap.lua",
    [3956818381] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/ninja-legends.lua"
}

local function loadScript(url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if success and result then
        local func, compileError = loadstring(result)
        
        if func then
            local loadSuccess, loadError = pcall(func)
            
            if not loadSuccess then
                warn("Script execution error: " .. tostring(loadError))
            end
        else
            warn("Script compile error: " .. tostring(compileError))
        end
    else
        warn("Failed to download script: " .. tostring(result))
    end
end

task.spawn(function()
    if SupportedGames[PlaceId] then
        loadScript(SupportedGames[PlaceId])
    else
        loadScript("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/scripts/main-script.lua")
    end
end)
