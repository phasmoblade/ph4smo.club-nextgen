export default function handler(req, res) {
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
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #0a0a0a;
            color: #fff;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            overflow: hidden;
        }
        
        .container {
            max-width: 600px;
            width: 100%;
            text-align: center;
            z-index: 10;
        }
        
        .icon {
            font-size: 5em;
            margin-bottom: 20px;
            animation: shake 0.5s ease-in-out infinite alternate;
        }
        
        @keyframes shake {
            0% { transform: rotate(-5deg); }
            100% { transform: rotate(5deg); }
        }
        
        h1 {
            font-size: 3em;
            font-weight: 700;
            margin-bottom: 15px;
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: glow 2s ease-in-out infinite;
        }
        
        @keyframes glow {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }
        
        .message {
            font-size: 1.3em;
            color: #888;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .code-box {
            background: #1a1a1a;
            border: 2px solid #ff6b6b;
            border-radius: 12px;
            padding: 20px;
            margin: 30px 0;
            box-shadow: 0 0 30px rgba(255, 107, 107, 0.3);
        }
        
        .code-text {
            font-family: 'Courier New', monospace;
            color: #ff6b6b;
            font-size: 0.9em;
            word-break: break-all;
        }
        
        .back-btn {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 15px 40px;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-top: 20px;
        }
        
        .back-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 25px rgba(102, 126, 234, 0.5);
        }
        
        .particles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 1;
        }
        
        .particle {
            position: absolute;
            background: #ff6b6b;
            border-radius: 50%;
            opacity: 0.3;
            animation: float-particle 10s infinite;
        }
        
        @keyframes float-particle {
            0%, 100% {
                transform: translateY(0) translateX(0);
                opacity: 0;
            }
            10% {
                opacity: 0.3;
            }
            90% {
                opacity: 0.3;
            }
            100% {
                transform: translateY(-100vh) translateX(50px);
                opacity: 0;
            }
        }
        
        @media (max-width: 600px) {
            h1 {
                font-size: 2em;
            }
            
            .icon {
                font-size: 3.5em;
            }
            
            .message {
                font-size: 1.1em;
            }
        }
    </style>
</head>
<body>
    <div class="particles" id="particles"></div>
    
    <div class="container">
        <div class="icon">🚫</div>
        <h1>Access Denied</h1>
        <p class="message">
            You're not supposed to be here.<br>
            This endpoint is for Roblox executors only.
        </p>
        
        <div class="code-box">
            <div class="code-text">HTTP 403 - Forbidden</div>
        </div>
        
        <a href="/" class="back-btn">← Back to Home</a>
    </div>
    
    <script>
        const particlesContainer = document.getElementById('particles');
        for (let i = 0; i < 15; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.width = Math.random() * 10 + 5 + 'px';
            particle.style.height = particle.style.width;
            particle.style.left = Math.random() * 100 + '%';
            particle.style.animationDelay = Math.random() * 10 + 's';
            particle.style.animationDuration = (Math.random() * 10 + 10) + 's';
            particlesContainer.appendChild(particle);
        }
    </script>
</body>
</html>`);
    return;
  }
  
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');

  const script = `local ok, src = pcall(function()
  return game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/loader.lua", true)
end)
if not ok or not src or src == "" then
  warn("[ph4smo] Fetch error: " .. tostring(src))
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

  res.status(200).send(script);
}
