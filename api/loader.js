export default function handler(req, res) {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  const loaderScript = `
local githubRepo = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/"
loadstring(game:HttpGet(githubRepo .. "loader.lua"))()
`;
  res.status(200).send(loaderScript);
}
