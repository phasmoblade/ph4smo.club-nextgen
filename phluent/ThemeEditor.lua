--[[
    phluent ThemeEditor Addon
    Adds Theme Editor to Settings tab automatically
    
    Usage: 
    local ThemeEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/phluent/ThemeEditor.lua"))()
    ThemeEditor:Init(Fluent, Window)
--]]

local ThemeEditor = {}

function ThemeEditor:Init(Fluent, Window)
    -- Find existing Settings tab (MUST exist, don't create)
    local SettingsTab = nil
    
    -- Try to find existing Settings tab
    for _, tab in pairs(Window.Tabs or {}) do
        if tab.Title and (string.find(string.lower(tab.Title), "settings") or string.find(string.lower(tab.Title), "конфиг")) then
            SettingsTab = tab
            break
        end
    end
    
    -- If no Settings tab, can't add Theme Editor
    if not SettingsTab then
        warn("[ThemeEditor] Settings tab not found - add ThemeEditor:Init() AFTER creating Settings tab")
        return nil
    end
    
    -- Add Theme section to EXISTING Settings tab
    local ThemeSection = SettingsTab:AddSection("Theme Editor")
    
    -- Description paragraph
    ThemeSection:AddParagraph({
        Title = "Custom Theme",
        Content = "Select a preset theme or create your own custom colors. Changes apply immediately."
    })
    
    -- Get Library from Fluent
    local Library = Fluent
    
    -- Initialize custom theme with ALL properties including Dialog
    local customTheme = {
        Name = "Custom",
        Accent = Color3.fromRGB(96, 205, 255),
        AcrylicMain = Color3.fromRGB(60, 60, 60),
        AcrylicBorder = Color3.fromRGB(90, 90, 90),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(170, 170, 170),
        Element = Color3.fromRGB(120, 120, 120),
        ElementBorder = Color3.fromRGB(35, 35, 35),
        -- Dialog colors (for exit confirmation popup)
        Dialog = Color3.fromRGB(45, 45, 45),
        DialogHolder = Color3.fromRGB(35, 35, 35),
        DialogButton = Color3.fromRGB(45, 45, 45),
        DialogButtonBorder = Color3.fromRGB(80, 80, 80),
        DialogBorder = Color3.fromRGB(70, 70, 70),
    }
    
    -- Load saved theme
    local HttpService = game:GetService("HttpService")
    if isfile and isfile("ph4smo_custom_theme.json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("ph4smo_custom_theme.json"))
        end)
        if success and result then
            for key, value in pairs(result) do
                if typeof(value) == "table" and value.R then
                    customTheme[key] = Color3.fromRGB(value.R, value.G, value.B)
                end
            end
        end
    end
    
    -- Theme selector dropdown (preset themes + Custom)
    local themeNames = {}
    for _, name in pairs(Library.Themes or {}) do
        table.insert(themeNames, name)
    end
    table.insert(themeNames, "Custom")
    
    ThemeSection:AddDropdown("Theme Selector", {
        Title = "Select Theme",
        Values = themeNames,
        Multi = false,
        Default = Library.Theme or "Dark",
        Callback = function(Value)
            if Value == "Custom" then
                Library:SetTheme(customTheme)
            else
                Library:SetTheme(Value)
            end
        end
    })
    
    -- Color pickers for custom theme
    ThemeSection:AddColorpicker("Accent Color", {
        Title = "Accent Color",
        Default = customTheme.Accent,
        Callback = function(Color)
            customTheme.Accent = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddColorpicker("Background Main", {
        Title = "Background Main",
        Default = customTheme.AcrylicMain,
        Callback = function(Color)
            customTheme.AcrylicMain = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddColorpicker("Background Border", {
        Title = "Background Border",
        Default = customTheme.AcrylicBorder,
        Callback = function(Color)
            customTheme.AcrylicBorder = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddColorpicker("Text Color", {
        Title = "Text Color",
        Default = customTheme.Text,
        Callback = function(Color)
            customTheme.Text = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddColorpicker("SubText Color", {
        Title = "SubText Color",
        Default = customTheme.SubText,
        Callback = function(Color)
            customTheme.SubText = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddColorpicker("Element Color", {
        Title = "Element Color",
        Default = customTheme.Element,
        Callback = function(Color)
            customTheme.Element = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddColorpicker("Element Border", {
        Title = "Element Border",
        Default = customTheme.ElementBorder,
        Callback = function(Color)
            customTheme.ElementBorder = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    -- Action buttons
    ThemeSection:AddButton("Save Custom Theme", function()
        local themeToSave = {}
        for key, value in pairs(customTheme) do
            if typeof(value) == "Color3" then
                themeToSave[key] = {
                    R = math.floor(value.R * 255),
                    G = math.floor(value.G * 255),
                    B = math.floor(value.B * 255)
                }
            else
                themeToSave[key] = value
            end
        end
        
        local success = pcall(function()
            writefile("ph4smo_custom_theme.json", HttpService:JSONEncode(themeToSave))
        end)
        
        if success then
            Library:Notify({
                Title = "Theme Saved",
                Content = "Custom theme has been saved!",
                Duration = 3
            })
        else
            Library:Notify({
                Title = "Error",
                Content = "Failed to save theme",
                Duration = 3
            })
        end
    end)
    
    -- Dialog colors
    ThemeSection:AddColorpicker("Dialog Background", {
        Title = "Dialog Background",
        Default = customTheme.Dialog,
        Callback = function(Color)
            customTheme.Dialog = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddColorpicker("Dialog Button", {
        Title = "Dialog Button",
        Default = customTheme.DialogButton,
        Callback = function(Color)
            customTheme.DialogButton = Color
            if Library.Theme == "Custom" then
                Library:SetTheme(customTheme)
            end
        end
    })
    
    ThemeSection:AddButton("Reset to Default", function()
        customTheme = {
            Name = "Custom",
            Accent = Color3.fromRGB(96, 205, 255),
            AcrylicMain = Color3.fromRGB(60, 60, 60),
            AcrylicBorder = Color3.fromRGB(90, 90, 90),
            Text = Color3.fromRGB(240, 240, 240),
            SubText = Color3.fromRGB(170, 170, 170),
            Element = Color3.fromRGB(120, 120, 120),
            ElementBorder = Color3.fromRGB(35, 35, 35),
            Dialog = Color3.fromRGB(45, 45, 45),
            DialogHolder = Color3.fromRGB(35, 35, 35),
            DialogButton = Color3.fromRGB(45, 45, 45),
            DialogButtonBorder = Color3.fromRGB(80, 80, 80),
            DialogBorder = Color3.fromRGB(70, 70, 70),
        }
        
        if Library.Theme == "Custom" then
            Library:SetTheme(customTheme)
        end
        
        Library:Notify({
            Title = "Theme Reset",
            Content = "Custom theme reset to default",
            Duration = 3
        })
    end)
    
    return ThemeSection
end

return ThemeEditor
