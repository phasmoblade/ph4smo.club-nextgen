import fs from 'fs';
import path from 'path';

export default function handler(req, res) {
  // Устанавливаем заголовки для Roblox
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  
  try {
    // Читаем файл скрипта
    const scriptPath = path.join(process.cwd(), 'scripts', 'main-script.lua');
    const script = fs.readFileSync(scriptPath, 'utf8');
    
    res.status(200).send(script);
  } catch (error) {
    res.status(500).send('-- Error loading script');
  }
}
