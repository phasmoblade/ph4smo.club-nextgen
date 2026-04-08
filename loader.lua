local PlaceId = game.PlaceId

local SupportedGames = {
    [4746041618] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/steel-titans.lua",
    [6516141723] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/doors.lua"
}

if SupportedGames[PlaceId] then
    loadstring(game:HttpGet(SupportedGames[PlaceId]))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/main-script.lua"))()
end
