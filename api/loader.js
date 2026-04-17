import fs from 'fs';
import path from 'path';

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
            font-family: 'Space Grotesk', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #000;
            color: #fff;
            min-height: 100vh;
            cursor: none;
        }
        
        .cursor {
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255,255,255,.4);
            border-radius: 50%;
            position: fixed;
            pointer-events: none;
            z-index: 9999;
            transition: transform 0.15s ease;
        }
        
        .cursor-dot {
            width: 4px;
            height: 4px;
            background: #fff;
            border-radius: 50%;
            position: fixed;
            pointer-events: none;
            z-index: 9999;
        }
        
        .hero {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
            position: relative;
        }
        
        .hero::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(255,255,255,0.03) 0%, transparent 70%);
            pointer-events: none;
        }
        
        .title-wrapper {
            text-align: center;
            margin-bottom: 60px;
        }
        
        .title {
            font-size: clamp(4rem, 12vw, 8rem);
            font-weight: 700;
            letter-spacing: -0.05em;
            line-height: 1;
            margin-bottom: 20px;
            color: #fff;
        }
        
        .subtitle {
            font-size: 1rem;
            color: #666;
            letter-spacing: 0.3em;
            text-transform: uppercase;
            font-weight: 400;
        }
        
        .message-card {
            max-width: 600px;
            width: 100%;
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(20px);
            text-align: center;
        }
        
        .message-text {
            font-size: 1.1rem;
            color: #999;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        
        .back-btn {
            display: inline-block;
            background: #fff;
            border: none;
            border-radius: 12px;
            color: #000;
            padding: 16px 40px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            letter-spacing: 0.05em;
            text-decoration: none;
        }
        
        .back-btn:hover {
            background: #e5e5e5;
            transform: translateY(-2px);
        }
        
        @media (max-width: 768px) {
            .message-card {
                padding: 30px 20px;
            }
            
            .message-text {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
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
            <a href="/" class="back-btn">← back to home</a>
        </div>
    </div>
    
    <script>
        const cursor = document.querySelector('.cursor');
        const cursorDot = document.querySelector('.cursor-dot');
        
        document.addEventListener('mousemove', (e) => {
            cursor.style.left = e.clientX + 'px';
            cursor.style.top = e.clientY + 'px';
            cursorDot.style.left = (e.clientX + 8) + 'px';
            cursorDot.style.top = (e.clientY + 8) + 'px';
        });
        
        document.querySelector('.back-btn').addEventListener('mouseenter', () => {
            cursor.style.transform = 'scale(1.5)';
        });
        document.querySelector('.back-btn').addEventListener('mouseleave', () => {
            cursor.style.transform = 'scale(1)';
        });
    </script>
</body>
</html>`);
    return;
  }
  
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');

  const script = `local ok, src = pcall(function()
  return game:HttpGet("https://ph4smoclub.vercel.app/scripts/loader.lua", true)
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
