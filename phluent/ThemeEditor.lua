--[[
    phluent ThemeEditor Addon - Multi-Theme Support
    
    Usage:
    local ThemeEditor = loadstring(game:HttpGet("...ThemeEditor.lua?t=" .. os.time()))()
    ThemeEditor:RegisterThemes(Fluent) -- call BEFORE InterfaceManager:BuildInterfaceSection
    -- ... InterfaceManager:BuildInterfaceSection(Tabs.Settings) ...
    ThemeEditor:Init(Fluent, Window, Tabs.Settings)
--]]

local ThemeEditor = {}
local HttpService = game:GetService("HttpService")

local THEMES_FOLDER = "ph4smo_themes"
local savedThemeNames = {} -- list of names
local savedThemeData = {} -- name -> color data table

local DEFAULT_COLORS = {
    Accent = Color3.fromRGB(96, 205, 255),
    AcrylicMain = Color3.fromRGB(60, 60, 60),
    AcrylicBorder = Color3.fromRGB(90, 90, 90),
    ElementBorder = Color3.fromRGB(35, 35, 35),
    Element = Color3.fromRGB(120, 120, 120),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(170, 170, 170),
    Dialog = Color3.fromRGB(45, 45, 45),
    DialogButton = Color3.fromRGB(45, 45, 45),
}

-- Color helpers
local function lerp(a, b, t) return a + (b - a) * t end
local function lerpColor(c1, c2, t)
    return Color3.new(lerp(c1.R, c2.R, t), lerp(c1.G, c2.G, t), lerp(c1.B, c2.B, t))
end
local function darken(c, amount) return lerpColor(c, Color3.new(0, 0, 0), amount) end
local function lighten(c, amount) return lerpColor(c, Color3.new(1, 1, 1), amount) end

local function buildFullTheme(name, colors)
    local bg = colors.AcrylicMain or DEFAULT_COLORS.AcrylicMain
    local border = colors.AcrylicBorder or DEFAULT_COLORS.AcrylicBorder
    local elem = colors.Element or DEFAULT_COLORS.Element
    local dialog = colors.Dialog or DEFAULT_COLORS.Dialog
    local dialogBtn = colors.DialogButton or DEFAULT_COLORS.DialogButton
    
    return {
        Name = name,
        Accent = colors.Accent or DEFAULT_COLORS.Accent,
        AcrylicMain = bg,
        AcrylicBorder = border,
        AcrylicGradient = ColorSequence.new(darken(bg, 0.3), darken(bg, 0.3)),
        AcrylicNoise = 0.9,
        TitleBarLine = lighten(bg, 0.15),
        Tab = elem,
        Element = elem,
        ElementBorder = colors.ElementBorder or DEFAULT_COLORS.ElementBorder,
        InElementBorder = border,
        ElementTransparency = 0.87,
        ToggleSlider = elem,
        ToggleToggled = darken(bg, 0.4),
        SliderRail = elem,
        DropdownFrame = lighten(elem, 0.3),
        DropdownHolder = darken(bg, 0.2),
        DropdownBorder = colors.ElementBorder or DEFAULT_COLORS.ElementBorder,
        DropdownOption = elem,
        Keybind = elem,
        Input = lighten(elem, 0.3),
        InputFocused = darken(bg, 0.7),
        InputIndicator = lighten(elem, 0.2),
        Dialog = dialog,
        DialogHolder = darken(dialog, 0.25),
        DialogHolderLine = darken(dialog, 0.35),
        DialogButton = dialogBtn,
        DialogButtonBorder = lighten(dialogBtn, 0.3),
        DialogBorder = lighten(dialog, 0.2),
        DialogInput = lighten(dialog, 0.1),
        DialogInputLine = lighten(elem, 0.3),
        Text = colors.Text or DEFAULT_COLORS.Text,
        SubText = colors.SubText or DEFAULT_COLORS.SubText,
        Hover = elem,
        HoverChange = 0.07,
    }
end

local function ensureFolder()
    pcall(function()
        if isfolder and not isfolder(THEMES_FOLDER) then
            makefolder(THEMES_FOLDER)
        end
    end)
end

local function loadThemesFromDisk()
    savedThemeNames = {}
    savedThemeData = {}
    pcall(function()
        ensureFolder()
        if not listfiles then return end
        for _, path in ipairs(listfiles(THEMES_FOLDER)) do
            if string.sub(path, -5) == ".json" then
                local raw = readfile(path)
                local data = HttpService:JSONDecode(raw)
                if data and data._name then
                    local colors = {}
                    for key, value in pairs(data) do
                        if typeof(value) == "table" and value.R then
                            colors[key] = Color3.fromRGB(value.R, value.G, value.B)
                        end
                    end
                    savedThemeData[data._name] = colors
                    table.insert(savedThemeNames, data._name)
                end
            end
        end
    end)
end

-- Phase 1: Load all themes and register them in Library BEFORE InterfaceManager builds dropdown
function ThemeEditor:RegisterThemes(Library)
    loadThemesFromDisk()
    for _, name in ipairs(savedThemeNames) do
        local fullTheme = buildFullTheme(name, savedThemeData[name])
        Library:RegisterTheme(fullTheme)
    end
end

-- Phase 2: Build editor UI
function ThemeEditor:Init(Fluent, Window, SettingsTab)
    if not SettingsTab then
        for _, tab in pairs(Window.Tabs or {}) do
            if tab.Title and string.find(string.lower(tab.Title), "settings") then
                SettingsTab = tab
                break
            end
        end
    end
    if not SettingsTab then
        warn("[ThemeEditor] Settings tab not found")
        return nil
    end
    
    local Library = Fluent
    local editColors = {}
    for k, v in pairs(DEFAULT_COLORS) do editColors[k] = v end
    local editName = ""
    
    -- ============ UI ============
    local ThemeSection = SettingsTab:AddSection("Theme Editor")
    
    ThemeSection:AddParagraph({
        Title = "Custom Themes",
        Content = "Create, save and load your own themes. Saved themes appear in the Theme dropdown above."
    })
    
    -- Load existing theme dropdown
    local themeListDropdown = ThemeSection:AddDropdown("te_saved_themes", {
        Title = "My Themes",
        Description = "Select a saved theme to load or edit",
        Values = savedThemeNames,
        Default = nil,
        Callback = function(name)
            if savedThemeData[name] then
                -- Load colors into editor
                for k, v in pairs(DEFAULT_COLORS) do
                    editColors[k] = savedThemeData[name][k] or v
                end
                editName = name
                -- Update colorpickers
                pcall(function()
                    if Options["te_accent"] then Options["te_accent"]:SetValue(editColors.Accent) end
                    if Options["te_acrylic_main"] then Options["te_acrylic_main"]:SetValue(editColors.AcrylicMain) end
                    if Options["te_acrylic_border"] then Options["te_acrylic_border"]:SetValue(editColors.AcrylicBorder) end
                    if Options["te_text"] then Options["te_text"]:SetValue(editColors.Text) end
                    if Options["te_subtext"] then Options["te_subtext"]:SetValue(editColors.SubText) end
                    if Options["te_element"] then Options["te_element"]:SetValue(editColors.Element) end
                    if Options["te_element_border"] then Options["te_element_border"]:SetValue(editColors.ElementBorder) end
                    if Options["te_dialog"] then Options["te_dialog"]:SetValue(editColors.Dialog) end
                    if Options["te_dialog_btn"] then Options["te_dialog_btn"]:SetValue(editColors.DialogButton) end
                    if Options["te_theme_name"] then Options["te_theme_name"]:SetValue(name) end
                end)
                -- Apply theme
                local fullTheme = buildFullTheme(name, editColors)
                Library:SetTheme(fullTheme)
            end
        end
    })
    
    -- Color pickers
    local function onColorChange() end -- forward declare
    
    ThemeSection:AddColorpicker("te_accent", {
        Title = "Accent",
        Default = editColors.Accent,
        Callback = function(c) editColors.Accent = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_acrylic_main", {
        Title = "Background",
        Default = editColors.AcrylicMain,
        Callback = function(c) editColors.AcrylicMain = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_acrylic_border", {
        Title = "Background Border",
        Default = editColors.AcrylicBorder,
        Callback = function(c) editColors.AcrylicBorder = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_text", {
        Title = "Text",
        Default = editColors.Text,
        Callback = function(c) editColors.Text = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_subtext", {
        Title = "SubText",
        Default = editColors.SubText,
        Callback = function(c) editColors.SubText = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_element", {
        Title = "Element",
        Default = editColors.Element,
        Callback = function(c) editColors.Element = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_element_border", {
        Title = "Element Border",
        Default = editColors.ElementBorder,
        Callback = function(c) editColors.ElementBorder = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_dialog", {
        Title = "Dialog Background",
        Default = editColors.Dialog,
        Callback = function(c) editColors.Dialog = c; onColorChange() end
    })
    ThemeSection:AddColorpicker("te_dialog_btn", {
        Title = "Dialog Button",
        Default = editColors.DialogButton,
        Callback = function(c) editColors.DialogButton = c; onColorChange() end
    })
    
    -- Live preview: if the currently active theme matches editName, update live
    onColorChange = function()
        if editName ~= "" and Library.Theme == editName then
            local fullTheme = buildFullTheme(editName, editColors)
            Library:SetTheme(fullTheme)
        end
    end
    
    -- Theme name input
    ThemeSection:AddInput("te_theme_name", {
        Title = "Theme Name",
        Default = "",
        Placeholder = "Enter theme name...",
        Numeric = false,
        Callback = function(value)
            if value and #value > 0 then
                editName = value
            end
        end
    })
    
    -- Save button
    ThemeSection:AddButton({Title = "Save Theme", Callback = function()
        if editName == "" then
            Library:Notify({Title = "Error", Content = "Enter a theme name first!", Duration = 3})
            return
        end
        
        -- Save to disk
        local themeToSave = { _name = editName }
        for key, value in pairs(editColors) do
            if typeof(value) == "Color3" then
                themeToSave[key] = {
                    R = math.floor(value.R * 255),
                    G = math.floor(value.G * 255),
                    B = math.floor(value.B * 255)
                }
            end
        end
        
        ensureFolder()
        local success = pcall(function()
            writefile(THEMES_FOLDER .. "/" .. editName .. ".json", HttpService:JSONEncode(themeToSave))
        end)
        
        -- Register and apply
        local fullTheme = buildFullTheme(editName, editColors)
        Library:SetTheme(fullTheme)
        
        -- Update saved data
        if not savedThemeData[editName] then
            table.insert(savedThemeNames, editName)
        end
        savedThemeData[editName] = {}
        for k, v in pairs(editColors) do savedThemeData[editName][k] = v end
        
        -- Update dropdown
        pcall(function()
            themeListDropdown:SetValues(savedThemeNames)
            themeListDropdown:SetValue(editName)
        end)
        
        Library:Notify({
            Title = success and "Theme Saved" or "Error",
            Content = success and ("'" .. editName .. "' saved and applied!") or "Failed to save theme",
            Duration = 3
        })
    end})
    
    -- Delete button
    ThemeSection:AddButton({Title = "Delete Theme", Callback = function()
        if editName == "" or not savedThemeData[editName] then
            Library:Notify({Title = "Error", Content = "No custom theme selected!", Duration = 3})
            return
        end
        
        local nameToDelete = editName
        pcall(function()
            if isfile and isfile(THEMES_FOLDER .. "/" .. nameToDelete .. ".json") then
                delfile(THEMES_FOLDER .. "/" .. nameToDelete .. ".json")
            end
        end)
        
        savedThemeData[nameToDelete] = nil
        for i, n in ipairs(savedThemeNames) do
            if n == nameToDelete then
                table.remove(savedThemeNames, i)
                break
            end
        end
        
        pcall(function()
            themeListDropdown:SetValues(savedThemeNames)
        end)
        
        -- Switch to Dark if deleted theme was active
        if Library.Theme == nameToDelete then
            Library:SetTheme("Dark")
        end
        
        editName = ""
        Library:Notify({Title = "Deleted", Content = "'" .. nameToDelete .. "' removed", Duration = 3})
    end})
    
    return ThemeSection
end

return ThemeEditor
