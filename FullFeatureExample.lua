--[[
    SpectreUI - Full Feature Example
    Showcases every element & feature the library supports.
    This is a general-purpose example — adapt it to any project.
]]

-- ============================================
-- 1) LOAD LIBRARY
-- ============================================
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/dist/main.lua"))()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/InterfaceManager.lua"))()

-- ============================================
-- 2) CUSTOM THEME (optional)
-- ============================================
Fluent:AddTheme({
    Name = "Spectre",
    Accent = Color3.fromHex("#8b5cf6"),

    AcrylicMain     = Color3.fromHex("#0f0c16"),
    AcrylicBorder   = Color3.fromHex("#2e2a36"),
    AcrylicGradient = ColorSequence.new(Color3.fromHex("#0f0c16"), Color3.fromHex("#1a1528")),

    TitleBarLine = Color3.fromHex("#2e2a36"),
    Tab          = Color3.fromHex("#94a3b8"),

    Element             = Color3.fromHex("#1e1a29"),
    ElementBorder       = Color3.fromHex("#0f0c16"),
    InElementBorder     = Color3.fromHex("#2e2a36"),
    ElementTransparency = 0.82,

    ToggleSlider  = Color3.fromHex("#2e2a36"),
    ToggleToggled = Color3.fromHex("#0f0c16"),
    SliderRail    = Color3.fromHex("#c4b5fd"),

    DropdownFrame  = Color3.fromHex("#2e2a36"),
    DropdownHolder = Color3.fromHex("#0f0c16"),
    DropdownBorder = Color3.fromHex("#1e1a29"),
    DropdownOption = Color3.fromHex("#1e1a29"),

    Dialog             = Color3.fromHex("#1a1528"),
    DialogHolder       = Color3.fromHex("#0f0c16"),
    DialogHolderLine   = Color3.fromHex("#0f0c16"),
    DialogButton       = Color3.fromHex("#1e1a29"),
    DialogButtonBorder = Color3.fromHex("#2e2a36"),
    DialogBorder       = Color3.fromHex("#2e2a36"),
    DialogInput        = Color3.fromHex("#1e1a29"),
    DialogInputLine    = Color3.fromHex("#c4b5fd"),

    Text       = Color3.fromHex("#f8fafc"),
    SubText    = Color3.fromHex("#94a3b8"),
    Hover      = Color3.fromHex("#c4b5fd"),
    HoverChange = 0.04,
})

-- ============================================
-- 3) CREATE WINDOW
-- ============================================
local Window = Fluent:CreateWindow({
    Title       = "SpectreUI Demo",
    SubTitle    = "v1.0",
    Author      = "Tiger",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = true,
    Theme       = "Spectre",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- ============================================
-- 4) TABS  (Settings = last)
-- ============================================
local Tabs = {
    Home     = Window:AddTab({ Title = "Home",      Icon = "home" }),
    Elements = Window:AddTab({ Title = "Elements",  Icon = "layout-list" }),
    Colors   = Window:AddTab({ Title = "Colors",    Icon = "palette" }),
    Settings = Window:AddTab({ Title = "Settings",  Icon = "settings" }),
}

-- ============================================
-- 5) HOME TAB
-- ============================================
local InfoSection  = Tabs.Home:AddSection({ Title = "Information", Opened = true })
local QuickSection = Tabs.Home:AddSection({ Title = "Quick Actions", Opened = true })

InfoSection:AddParagraph({
    Title   = "Welcome to SpectreUI",
    Content = "A flexible Roblox UI library.\nClick any section header to collapse/expand it.",
})

InfoSection:AddBanner({
    Title   = "What's New",
    Content = "Collapsible sections, custom themes, colorpickers, slider suffix, and shorthand API.",
    Style   = "info", -- default: accent-colored left bar + info icon
})

-- Showcase all Banner styles
InfoSection:AddBanner({
    Title   = "Success Example",
    Content = "This is a success banner — use Style = 'success' for confirmations.",
    Style   = "success",
})

InfoSection:AddBanner({
    Title   = "Warning Example",
    Content = "This is a warning banner — use Style = 'warning' for caution messages.",
    Style   = "warning",
})

InfoSection:AddBanner({
    Title   = "Error Example",
    Content = "This is an error banner — use Style = 'error' for critical alerts.",
    Style   = "error",
})

QuickSection:AddButton({
    Title       = "Say Hello",
    Description = "Prints a greeting to the console",
    Callback    = function()
        print("Hello from SpectreUI!")
    end,
})

QuickSection:AddButton({
    Title       = "Open Dialog",
    Description = "Shows a confirmation dialog",
    Callback    = function()
        Window:Dialog({
            Title   = "Confirm",
            Content = "Are you sure?",
            Buttons = {
                { Title = "Yes", Callback = function() print("Confirmed!") end },
                { Title = "No",  Callback = function() print("Cancelled.") end },
            },
        })
    end,
})

-- ============================================
-- 6) ELEMENTS TAB — every element type
-- ============================================
local ToggleSection   = Tabs.Elements:AddSection({ Title = "Toggle & Keybind", Opened = true })
local SliderSection   = Tabs.Elements:AddSection({ Title = "Sliders", Opened = true })
local DropdownSection = Tabs.Elements:AddSection({ Title = "Dropdowns", Opened = false })
local InputSection    = Tabs.Elements:AddSection({ Title = "Input & Misc", Opened = false })

-- TOGGLE
local DemoToggle = ToggleSection:AddToggle("DemoToggle", {
    Title       = "Enable Feature",
    Description = "A basic on/off toggle",
    Default     = false,
})
DemoToggle:OnChanged(function(v) print("Toggle:", v) end)

-- KEYBIND
ToggleSection:AddKeybind("DemoKeybind", {
    Title       = "Action Key",
    Description = "Bind any key or mouse button",
    Default     = "E",
    Mode        = "Toggle",
    Callback    = function() print("Key activated!") end,
    ChangedCallback = function(new) print("Key changed to:", new) end,
})

-- SLIDERS
SliderSection:AddSlider("Speed", {
    Title    = "Speed",
    Default  = 16,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Callback = function(v) print("Speed:", v) end,
})

SliderSection:AddSlider("Opacity", {
    Title    = "Opacity",
    Default  = 80,
    Min      = 0,
    Max      = 100,
    Rounding = 0,
    Suffix   = "%",
    Callback = function(v) print("Opacity:", v) end,
})

SliderSection:AddSlider("Delay", {
    Title       = "Delay",
    Description = "Time between actions",
    Default     = 0.5,
    Min         = 0,
    Max         = 5,
    Rounding    = 1,
    Suffix      = " sec",
    Callback    = function(v) print("Delay:", v) end,
})

-- SINGLE DROPDOWN
DropdownSection:AddDropdown("Language", {
    Title       = "Language",
    Description = "Select your preferred language",
    Values      = {"English", "Thai", "Japanese", "Chinese", "Korean"},
    Default     = "English",
    Callback    = function(v) print("Language:", v) end,
})

-- MULTI-SELECT DROPDOWN
DropdownSection:AddDropdown("Features", {
    Title    = "Enable Features",
    Values   = {"Logging", "Notifications", "Auto-Save", "Analytics"},
    Default  = {"Logging", "Auto-Save"},
    Multi    = true,
    Callback = function(v)
        for name, enabled in pairs(v) do
            print(name, "=", enabled)
        end
    end,
})

-- INPUT
InputSection:AddInput("Username", {
    Title       = "Display Name",
    Description = "Enter a custom name",
    Default     = "",
    Placeholder = "e.g. Player123",
    Callback    = function(v) print("Name:", v) end,
})

-- PARAGRAPH
InputSection:AddParagraph({
    Title   = "Note",
    Content = "All elements above support saving/loading via SaveManager.",
})

-- BUTTON GROUP
InputSection:AddButtonGroup({
    Title       = "Quick Select",
    Description = "Pick one or more options",
    Buttons     = {"A", "B", "C", "D"},
    Callback    = function(Selected)
        for key, state in pairs(Selected) do
            print("ButtonGroup:", key, state)
        end
    end,
})

-- STEPPER
InputSection:AddStepper("StepperDemo", {
    Title       = "Quantity",
    Description = "Use +/- to adjust",
    Default     = 5,
    Min         = 1,
    Max         = 20,
    Step        = 1,
    Callback    = function(v) print("Stepper:", v) end,
})

-- SELECTION LIST
InputSection:AddSelectionList("SelectionDemo", {
    Title       = "Choose Items",
    Description = "Select from the list below",
    Values      = {"Apple", "Banana", "Cherry", "Date", "Elderberry"},
    Default     = {"Apple"},
    Callback    = function(v)
        print("Selection:", table.concat(v, ", "))
    end,
})

-- SUB-TABS (inline tab groups within a section)
local SubTabsSection = Tabs.Elements:AddSection({ Title = "Sub-Tabs Demo", Opened = false })
local DemoSubTabs = SubTabsSection:AddTabs({
    Titles = {
        { Title = "General", Icon = "settings" },
        { Title = "Visual",  Icon = "eye" },
        { Title = "Alert",   Icon = "bell", Color = Color3.fromRGB(239, 68, 68) },
    },
    Default = 1,
})

DemoSubTabs.Tabs["General"]:AddToggle("SubTabToggle1", {
    Title   = "Enable Feature A",
    Default = true,
})

DemoSubTabs.Tabs["Visual"]:AddSlider("SubTabSlider1", {
    Title   = "Brightness",
    Default = 50,
    Min     = 0,
    Max     = 100,
    Rounding = 0,
    Suffix  = "%",
})

DemoSubTabs.Tabs["Alert"]:AddParagraph({
    Title   = "Alert Tab",
    Content = "This sub-tab uses a custom color (red) for its button.",
})

-- ============================================
-- 7) COLORS TAB — Colorpicker showcase
-- ============================================
local PickerSection = Tabs.Colors:AddSection({ Title = "Color Pickers", Opened = true })
local PreviewSection = Tabs.Colors:AddSection({ Title = "Shorthand API", Opened = false })

PickerSection:AddColorpicker("PrimaryColor", {
    Title    = "Primary Color",
    Default  = Color3.fromRGB(139, 92, 246),
    Callback = function(v) print("Primary:", v) end,
})

PickerSection:AddColorpicker("SecondaryColor", {
    Title        = "Secondary Color",
    Default      = Color3.fromRGB(59, 130, 246),
    Transparency = 0,
})

PickerSection:AddColorpicker("AccentColor", {
    Title    = "Accent Color",
    Default  = Color3.fromRGB(239, 68, 68),
    Callback = function(v) print("Accent:", v) end,
})

-- Shorthand API demo (same result, shorter syntax)
PreviewSection:Toggle({
    Flag     = "PreviewToggle",
    Title    = "Preview Mode",
    Default  = false,
    Callback = function(v) print("Preview:", v) end,
})

PreviewSection:Slider({
    Flag     = "PreviewSize",
    Title    = "Size",
    Default  = 50,
    Min      = 10,
    Max      = 200,
    Rounding = 0,
    Suffix   = " px",
})

PreviewSection:Dropdown({
    Flag    = "PreviewShape",
    Title   = "Shape",
    Values  = {"Circle", "Square", "Triangle"},
    Default = "Circle",
})

PreviewSection:Paragraph({
    Title   = "About Shorthand",
    Content = "These use shorthand syntax: Section:Toggle({...}) instead of Section:AddToggle(flag, {...}).",
})

-- ============================================
-- 8) SETTINGS TAB (always last)
-- ============================================
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("SpectreUIDemo")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("SpectreUIDemo")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tabs.Settings)

-- ============================================
-- 9) SELECT DEFAULT TAB & NOTIFY
-- ============================================
Window:SelectTab(1)

Fluent:Notify({
    Title      = "SpectreUI",
    Content    = "Loaded successfully!",
    SubContent = "Press LeftControl to toggle UI",
    Duration   = 5,
})

-- ============================================
-- 10) LOAD SAVED CONFIG
-- ============================================
SaveManager:LoadAutoloadConfig()
