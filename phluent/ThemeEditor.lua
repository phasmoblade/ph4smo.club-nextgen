--[[
    phluent ThemeEditor Addon
    Adds Theme Editor to Settings tab automatically
    
    Usage: 
    local ThemeEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/phasmoblade/ph4smo.club-nextgen/main/phluent/ThemeEditor.lua"))()
    ThemeEditor:Init(Fluent, Window, SettingsTab)
--]]

local ThemeEditor = {}

local DEFAULT_THEME = {
    Name = "Custom",
    Accent = Color3.fromRGB(96, 205, 255),
    AcrylicMain = Color3.fromRGB(60, 60, 60),
    AcrylicBorder = Color3.fromRGB(90, 90, 90),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(40, 40, 40)),
    AcrylicNoise = 0.9,
    TitleBarLine = Color3.fromRGB(75, 75, 75),
    Tab = Color3.fromRGB(120, 120, 120),
    Element = Color3.fromRGB(120, 120, 120),
    ElementBorder = Color3.fromRGB(35, 35, 35),
    InElementBorder = Color3.fromRGB(90, 90, 90),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(120, 120, 120),
    ToggleToggled = Color3.fromRGB(42, 42, 42),
    SliderRail = Color3.fromRGB(120, 120, 120),
    DropdownFrame = Color3.fromRGB(160, 160, 160),
    DropdownHolder = Color3.fromRGB(45, 45, 45),
    DropdownBorder = Color3.fromRGB(35, 35, 35),
    DropdownOption = Color3.fromRGB(120, 120, 120),
    Keybind = Color3.fromRGB(120, 120, 120),
    Input = Color3.fromRGB(160, 160, 160),
    InputFocused = Color3.fromRGB(10, 10, 10),
    InputIndicator = Color3.fromRGB(150, 150, 150),
    Dialog = Color3.fromRGB(45, 45, 45),
    DialogHolder = Color3.fromRGB(35, 35, 35),
    DialogHolderLine = Color3.fromRGB(30, 30, 30),
    DialogButton = Color3.fromRGB(45, 45, 45),
    DialogButtonBorder = Color3.fromRGB(80, 80, 80),
    DialogBorder = Color3.fromRGB(70, 70, 70),
    DialogInput = Color3.fromRGB(55, 55, 55),
    DialogInputLine = Color3.fromRGB(160, 160, 160),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(170, 170, 170),
    Hover = Color3.fromRGB(120, 120, 120),
    HoverChange = 0.07,
}

local function deepCopy(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

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
    local HttpService = game:GetService("HttpService")
    local customTheme = deepCopy(DEFAULT_THEME)
    local themeName = "Custom"
    
    -- Load saved custom theme
    if isfile and isfile("ph4smo_custom_theme.json") then
        pcall(function()
            local data = HttpService:JSONDecode(readfile("ph4smo_custom_theme.json"))
            if data then
                if data._name then themeName = data._name end
                for key, value in pairs(data) do
                    if typeof(value) == "table" and value.R then
                        customTheme[key] = Color3.fromRGB(value.R, value.G, value.B)
                    end
                end
                customTheme.Name = themeName
            end
        end)
    end
    
    -- Register custom theme so it appears in the Interface theme dropdown
    Library:SetTheme(customTheme)
    -- Switch back to current theme
    pcall(function() Library:SetTheme(Library.Theme or "Dark") end)
    
    -- Apply custom theme function
    local function applyCustom()
        customTheme.Name = themeName
        Library:SetTheme(customTheme)
    end
    
    local function isCustomActive()
        return Library.Theme == themeName or Library.Theme == "Custom"
    end
    
    -- ============ UI ============
    local ThemeSection = SettingsTab:AddSection("Theme Editor")
    
    ThemeSection:AddParagraph({
        Title = "Custom Theme",
        Content = "Create your own theme colors. Select 'Custom' from the Theme dropdown above to apply."
    })
    
    -- Main colors
    ThemeSection:AddColorpicker("te_accent", {
        Title = "Accent",
        Default = customTheme.Accent,
        Callback = function(c) customTheme.Accent = c; if isCustomActive() then applyCustom() end end
    })
    
    ThemeSection:AddColorpicker("te_acrylic_main", {
        Title = "Background",
        Default = customTheme.AcrylicMain,
        Callback = function(c) customTheme.AcrylicMain = c; if isCustomActive() then applyCustom() end end
    })
    
    ThemeSection:AddColorpicker("te_acrylic_border", {
        Title = "Background Border",
        Default = customTheme.AcrylicBorder,
        Callback = function(c) customTheme.AcrylicBorder = c; if isCustomActive() then applyCustom() end end
    })
    
    ThemeSection:AddColorpicker("te_text", {
        Title = "Text",
        Default = customTheme.Text,
        Callback = function(c) customTheme.Text = c; if isCustomActive() then applyCustom() end end
    })
    
    ThemeSection:AddColorpicker("te_subtext", {
        Title = "SubText",
        Default = customTheme.SubText,
        Callback = function(c) customTheme.SubText = c; if isCustomActive() then applyCustom() end end
    })
    
    ThemeSection:AddColorpicker("te_element", {
        Title = "Element",
        Default = customTheme.Element,
        Callback = function(c) customTheme.Element = c; if isCustomActive() then applyCustom() end end
    })
    
    ThemeSection:AddColorpicker("te_element_border", {
        Title = "Element Border",
        Default = customTheme.ElementBorder,
        Callback = function(c) customTheme.ElementBorder = c; if isCustomActive() then applyCustom() end end
    })
    
    -- Dialog colors
    ThemeSection:AddColorpicker("te_dialog", {
        Title = "Dialog Background",
        Default = customTheme.Dialog,
        Callback = function(c) customTheme.Dialog = c; if isCustomActive() then applyCustom() end end
    })
    
    ThemeSection:AddColorpicker("te_dialog_btn", {
        Title = "Dialog Button",
        Default = customTheme.DialogButton,
        Callback = function(c) customTheme.DialogButton = c; if isCustomActive() then applyCustom() end end
    })
    
    -- Theme name input
    ThemeSection:AddInput("te_theme_name", {
        Title = "Theme Name",
        Default = themeName,
        Placeholder = "Enter theme name...",
        Numeric = false,
        Callback = function(value)
            if value and #value > 0 then
                themeName = value
            end
        end
    })
    
    -- Save button
    ThemeSection:AddButton({Title = "Save Theme", Callback = function()
        customTheme.Name = themeName
        local themeToSave = { _name = themeName }
        for key, value in pairs(customTheme) do
            if typeof(value) == "Color3" then
                themeToSave[key] = {
                    R = math.floor(value.R * 255),
                    G = math.floor(value.G * 255),
                    B = math.floor(value.B * 255)
                }
            end
        end
        
        local success = pcall(function()
            writefile("ph4smo_custom_theme.json", HttpService:JSONEncode(themeToSave))
        end)
        
        -- Register and apply
        applyCustom()
        
        Library:Notify({
            Title = success and "Theme Saved" or "Error",
            Content = success and ("'" .. themeName .. "' saved and applied!") or "Failed to save theme",
            Duration = 3
        })
    end})
    
    -- Reset button
    ThemeSection:AddButton({Title = "Reset to Default", Callback = function()
        customTheme = deepCopy(DEFAULT_THEME)
        themeName = "Custom"
        customTheme.Name = themeName
        
        if isCustomActive() then
            applyCustom()
        end
        
        pcall(function()
            if isfile and isfile("ph4smo_custom_theme.json") then
                delfile("ph4smo_custom_theme.json")
            end
        end)
        
        Library:Notify({
            Title = "Theme Reset",
            Content = "Custom theme reset to default",
            Duration = 3
        })
    end})
    
    return ThemeSection
end

return ThemeEditor
