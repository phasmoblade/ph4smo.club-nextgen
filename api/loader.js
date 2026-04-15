export default function handler(req, res) {

  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  
  const loaderScript = `
-- ph4smo.club loader
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/loader.lua")
end)

if success then
    loadstring(result)()
else
    warn("Failed to load: " .. tostring(result))
end
`;

  res.status(200).send(loaderScript);
}
