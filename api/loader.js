export default function handler(req, res) {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.status(200).end();
    return;
  }

  const userAgent = req.headers['user-agent'] || '';
  const isBrowser = userAgent.includes('Mozilla') || userAgent.includes('Chrome') || userAgent.includes('Safari');
  
  if (isBrowser) {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.status(403).send(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - ph4smo.club</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #050505;
            color: #fff;
            min-height: 100vh;
            cursor: none;
            overflow-x: hidden;
        }

        * { cursor: none !important; }

        @media (max-width: 768px) {
            body, * { cursor: auto !important; }
            .cursor, .cursor-dot { display: none !important; }
        }

        .cursor {
            width: 24px;
            height: 24px;
            border: 1.5px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            position: fixed;
            pointer-events: none;
            z-index: 9999;
            transition: transform 0.2s cubic-bezier(0.23, 1, 0.32, 1), border-color 0.3s;
            transform: translate(-50%, -50%);
            backdrop-filter: blur(2px);
        }

        .cursor-dot {
            width: 5px;
            height: 5px;
            background: #fff;
            border-radius: 50%;
            position: fixed;
            pointer-events: none;
            z-index: 9999;
            transform: translate(-50%, -50%);
            box-shadow: 0 0 6px rgba(255,255,255,0.4);
        }

        .bg-orbs {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            pointer-events: none;
            z-index: 0;
            overflow: hidden;
        }
        .bg-orb {
            position: absolute;
            border-radius: 50%;
            filter: blur(100px);
            opacity: 0.06;
            animation: orbFloat 20s ease-in-out infinite;
        }
        .bg-orb:nth-child(1) {
            width: 500px; height: 500px;
            background: #fff;
            top: -15%; left: 20%;
        }
        .bg-orb:nth-child(2) {
            width: 400px; height: 400px;
            background: #ccc;
            bottom: -10%; right: -5%;
            animation-delay: -8s;
        }
        @keyframes orbFloat {
            0%, 100% { transform: translate(0, 0) scale(1); }
            25% { transform: translate(60px, -40px) scale(1.1); }
            50% { transform: translate(-30px, 50px) scale(0.95); }
            75% { transform: translate(40px, 20px) scale(1.05); }
        }

        body::after {
            content: '';
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            pointer-events: none;
            z-index: 1;
            opacity: 0.015;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
            background-repeat: repeat;
            background-size: 128px 128px;
        }

        .hero {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
            position: relative;
            z-index: 2;
        }

        .title-wrapper {
            text-align: center;
            margin-bottom: 48px;
        }

        .title {
            font-size: clamp(3.5rem, 12vw, 7rem);
            font-weight: 800;
            letter-spacing: -0.05em;
            line-height: 1;
            margin-bottom: 16px;
            color: #fff;
            text-shadow: 0 0 80px rgba(255,255,255,0.08);
        }

        .subtitle {
            font-size: 0.8rem;
            color: rgba(255,255,255,0.25);
            letter-spacing: 0.25em;
            text-transform: uppercase;
            font-weight: 500;
        }

        .message-card {
            max-width: 520px;
            width: 100%;
            background: rgba(255, 255, 255, 0.04);
            backdrop-filter: blur(40px);
            -webkit-backdrop-filter: blur(40px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-top-color: rgba(255, 255, 255, 0.15);
            border-radius: 24px;
            padding: 36px;
            text-align: center;
            box-shadow:
                0 8px 32px rgba(0, 0, 0, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.06);
        }

        .message-text {
            font-size: 1rem;
            color: rgba(255,255,255,0.4);
            line-height: 1.7;
            margin-bottom: 28px;
        }

        .back-btn {
            display: inline-block;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-top-color: rgba(255, 255, 255, 0.2);
            border-radius: 14px;
            color: #fff;
            padding: 14px 36px;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.23, 1, 0.32, 1);
            text-decoration: none;
            box-shadow:
                0 4px 12px rgba(0, 0, 0, 0.2),
                inset 0 1px 0 rgba(255, 255, 255, 0.06);
        }

        .back-btn:hover {
            background: rgba(255, 255, 255, 0.14);
            transform: translateY(-1px);
            box-shadow:
                0 8px 24px rgba(0, 0, 0, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
        }

        @media (max-width: 768px) {
            .message-card { padding: 28px 20px; }
            .message-text { font-size: 0.9rem; }
        }
    </style>
</head>
<body>
    <div class="bg-orbs">
        <div class="bg-orb"></div>
        <div class="bg-orb"></div>
    </div>

    <div class="cursor"></div>
    <div class="cursor-dot"></div>

    <div class="hero">
        <div class="title-wrapper">
            <h1 class="title">ph4smo.club</h1>
            <p class="subtitle">access denied</p>
        </div>

        <div class="message-card">
            <p class="message-text">
                fuck off, cracker. you're not welcome here. 🖕
            </p>
            <a href="/" class="back-btn">\u2190 back to home</a>
        </div>
    </div>

    <script>
        const cursor = document.querySelector('.cursor');
        const cursorDot = document.querySelector('.cursor-dot');

        document.addEventListener('mousemove', (e) => {
            cursor.style.left = e.clientX + 'px';
            cursor.style.top = e.clientY + 'px';
            cursorDot.style.left = e.clientX + 'px';
            cursorDot.style.top = e.clientY + 'px';
        });

        document.querySelector('.back-btn').addEventListener('mouseenter', () => {
            cursor.style.transform = 'translate(-50%, -50%) scale(1.6)';
            cursor.style.borderColor = 'rgba(255,255,255,0.6)';
        });
        document.querySelector('.back-btn').addEventListener('mouseleave', () => {
            cursor.style.transform = 'translate(-50%, -50%) scale(1)';
            cursor.style.borderColor = 'rgba(255,255,255,0.3)';
        });
    </script>
</body>
</html>`);
    return;
  }
  
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  res.setHeader('Content-Encoding', 'identity');

  const script = `-- ph4smo.club loader
-- Direct loading: loader.lua

print("[ph4smo.club] Loading...")

local loaderUrl = "https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/loader.lua"

local function loadScript(url)
    -- Remove async flag for better injector compatibility
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("[ph4smo.club] Failed to download: " .. tostring(result))
        return false
    end
    
    if not result or result == "" then
        warn("[ph4smo.club] Empty response from server")
        return false
    end
    
    local func, compileError = loadstring(result)
    
    if not func then
        warn("[ph4smo.club] Compile error: " .. tostring(compileError))
        return false
    end
    
    local loadSuccess, loadError = pcall(func)
    
    if not loadSuccess then
        warn("[ph4smo.club] Execution error: " .. tostring(loadError))
        return false
    end
    
    return true
end

-- Load loader.lua (handles key validation and game scripts)
local loaderSuccess = loadScript(loaderUrl)

if not loaderSuccess then
    warn("[ph4smo.club] Failed to load loader")
end`;

  res.status(200).send(script);
}
