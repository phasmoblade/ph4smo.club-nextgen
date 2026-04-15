local PlaceId = game.PlaceId

local SupportedGames = {
    [4746041618] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/steel-titans.lua",
    [6516141723] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/doors.lua",
    [79305036070450] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/spin-a-baddie.lua",
    [70845479499574] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/bite-by-night.lua",
    [6961824067] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/ftap.lua",
    [3956818381] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/ninja-legends.lua"
}

local function loadScript(url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if success and result then
        local loadSuccess, loadError = pcall(function()
            loadstring(result)()
        end)
        
        if not loadSuccess then
            warn("Script execution error: " .. tostring(loadError))
        end
    else
        warn("Failed to download script: " .. tostring(result))
    end
end

task.spawn(function()
    if SupportedGames[PlaceId] then
        loadScript(SupportedGames[PlaceId])
    else
        loadScript("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/main-script.lua")
    end
end)
