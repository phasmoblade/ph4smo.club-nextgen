export default function handler(req, res) {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');

  const loaderScript = `local ok, src = pcall(function()
  return game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/loader.lua", true)
end)
if not ok or not src or src == "" then
  warn("[ph4smo] Failed to fetch: " .. tostring(src))
  return
end
local fn, err = loadstring(src)
if not fn then
  warn("[ph4smo] Compile error: " .. tostring(err))
  return
end
local ok2, err2 = pcall(fn)
if not ok2 then
  warn("[ph4smo] Runtime error: " .. tostring(err2))
end`;

  res.status(200).send(loaderScript);
}
