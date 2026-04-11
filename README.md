# ph4smo.club nextgen
- It's rework of ph4smo.club (my old script)
# Loadstring
- local ph4smo={url="https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/refs/heads/main/loader.lua",load=function(self)if not game:IsLoaded()then game.Loaded:Wait()end;local code=nil;repeat local s,r=pcall(game.HttpGet,game,self.url)if s then code=r end;task.wait(0.3)until typeof(code)=="string";return(loadstring or load)(code)()end};ph4smo:load()
# Supported Games (11.04.2026):
- Steel Titans
- Doors
- Spin A Baddie
