export default function handler(req, res) {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  
  const loaderScript = `local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/loader.lua", true)
end)

if success and result then
    local loadSuccess, loadError = pcall(function()
        loadstring(result)()
    end)
    if not loadSuccess then
        warn("Loader error: " .. tostring(loadError))
    end
else
    warn("Failed to load: " .. tostring(result))
end`;

  res.status(200).send(loaderScript);
}
