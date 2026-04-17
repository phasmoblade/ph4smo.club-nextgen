# ph4smo.club Scripts Hosting

## 📦 Установка на Vercel

### Шаг 1: Подготовка
1. Скопируй всю папку `vercel-project` в отдельное место
2. Скопируй свои скрипты в папку `scripts/`:
   - `bite-by-night.lua`
   - `main-script.lua`
   - `loader.lua`

### Шаг 2: Загрузка на Vercel

#### Вариант A: Через GitHub (рекомендуется)
1. Создай новый репозиторий на GitHub
2. Загрузи туда содержимое папки `vercel-project`
3. Зайди на https://vercel.com
4. Нажми "Import Project"
5. Выбери свой GitHub репозиторий
6. Нажми "Deploy"

#### Вариант B: Через Vercel CLI
1. Установи Vercel CLI: `npm i -g vercel`
2. Зайди в папку `vercel-project`
3. Выполни команду: `vercel`
4. Следуй инструкциям
5. Для продакшена: `vercel --prod`

#### Вариант C: Через Drag & Drop
1. Зайди на https://vercel.com
2. Нажми "Add New" → "Project"
3. Перетащи папку `vercel-project` в окно браузера
4. Нажми "Deploy"

### Шаг 3: Настройка домена
1. В настройках проекта на Vercel найди "Domains"
2. Твой домен уже настроен: `ph4smoclub.vercel.app`
3. Можешь добавить свой кастомный домен

## 🚀 Использование

После деплоя твои скрипты будут доступны по адресам:

```lua
-- Universal Loader
loadstring(game:HttpGet("https://ph4smoclub.vercel.app/api/loader"))()

-- Main Script
loadstring(game:HttpGet("https://ph4smoclub.vercel.app/api/main-script"))()

-- Bite By Night
loadstring(game:HttpGet("https://ph4smoclub.vercel.app/api/bite-by-night"))()
```

## 📁 Структура проекта

```
vercel-project/
├── api/                    # API endpoints
│   ├── bite-by-night.js   # Endpoint для Bite By Night
│   ├── main-script.js     # Endpoint для Main Script
│   └── loader.js          # Endpoint для Loader
├── scripts/               # Твои Lua скрипты (создай эту папку!)
│   ├── bite-by-night.lua
│   ├── main-script.lua
│   └── loader.lua
├── public/                # Статические файлы
│   └── index.html        # Главная страница
├── vercel.json           # Конфигурация Vercel
├── package.json          # Зависимости
└── README.md            # Эта инструкция
```

## ⚠️ Важно!

1. **Создай папку `scripts/`** и положи туда свои `.lua` файлы
2. Все скрипты должны быть в кодировке UTF-8
3. Vercel автоматически обновит скрипты при пуше в GitHub
4. Кеширование отключено - изменения применяются сразу

## 🔧 Обновление скриптов

1. Замени файлы в папке `scripts/`
2. Закоммить и запушь в GitHub (если используешь GitHub)
3. Vercel автоматически задеплоит изменения
4. Или используй `vercel --prod` для ручного деплоя

## 📝 Добавление новых скриптов

1. Создай новый файл в `scripts/`, например `new-game.lua`
2. Создай новый endpoint в `api/new-game.js`:

```javascript
import fs from 'fs';
import path from 'path';

export default function handler(req, res) {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  
  try {
    const scriptPath = path.join(process.cwd(), 'scripts', 'new-game.lua');
    const script = fs.readFileSync(scriptPath, 'utf8');
    res.status(200).send(script);
  } catch (error) {
    res.status(500).send('-- Error loading script');
  }
}
```

3. Задеплой изменения

## 🎨 Кастомизация

- Измени `public/index.html` для своего дизайна
- Добавь свои цвета, логотип, описания
- Можешь добавить аналитику, счетчики и т.д.

---

**by phasmoblade**
