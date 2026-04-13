local PlaceId = game.PlaceId

local SupportedGames = {
    [4746041618] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/steel-titans.lua",
    [6516141723] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/doors.lua",
    [79305036070450] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/spin-a-baddie.lua",
    [70845479499574] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/bite-by-night.lua",
    [6961824067] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/ftap.lua",
    [3956818381] = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/ninja-legends.lua"
}

if SupportedGames[PlaceId] then
    loadstring(game:HttpGet(SupportedGames[PlaceId]))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/main-script.lua"))()
end
