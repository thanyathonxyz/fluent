--[[
    Fluent Interface Suite - Full Testing & Feature Showcase
    ==========================================================
    Comprehensive example script demonstrating every element,
    mobile optimizations, memory leak fixes, and new features.

    Author: thanyathonxyz (based on Fluent by dawid)
    Repository: https://github.com/thanyathonxyz/fluent
--]]

-- ============================================================
-- 1) LOAD LIBRARY & ADDONS
-- ============================================================
-- Supports getgenv().Fluent if pre-loaded, otherwise fetches from GitHub
local Fluent = getgenv().Fluent or loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/dist/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/InterfaceManager.lua"))()

-- Roblox Services for real in-game interactive tests
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 2) REGISTER CUSTOM THEME (Optional Showcase)
-- ============================================================
Fluent:AddTheme({
    Name = "CyberAmethyst",
    Accent = Color3.fromHex("#a855f7"),

    AcrylicMain     = Color3.fromHex("#0d0b14"),
    AcrylicBorder   = Color3.fromHex("#2b2238"),
    AcrylicGradient = ColorSequence.new(Color3.fromHex("#0d0b14"), Color3.fromHex("#171224")),

    TitleBarLine = Color3.fromHex("#2b2238"),
    Tab          = Color3.fromHex("#94a3b8"),

    Element             = Color3.fromHex("#181424"),
    ElementBorder       = Color3.fromHex("#241c33"),
    InElementBorder     = Color3.fromHex("#35294d"),
    ElementTransparency = 0.85,

    ToggleSlider  = Color3.fromHex("#2b2238"),
    ToggleToggled = Color3.fromHex("#a855f7"),
    SliderRail    = Color3.fromHex("#c084fc"),

    DropdownFrame  = Color3.fromHex("#241c33"),
    DropdownHolder = Color3.fromHex("#120e1c"),
    DropdownBorder = Color3.fromHex("#35294d"),
    DropdownOption = Color3.fromHex("#181424"),

    Dialog             = Color3.fromHex("#181424"),
    DialogHolder       = Color3.fromHex("#120e1c"),
    DialogHolderLine   = Color3.fromHex("#241c33"),
    DialogButton       = Color3.fromHex("#241c33"),
    DialogButtonBorder = Color3.fromHex("#35294d"),
    DialogBorder       = Color3.fromHex("#35294d"),
    DialogInput        = Color3.fromHex("#120e1c"),
    DialogInputLine    = Color3.fromHex("#a855f7"),

    Text        = Color3.fromHex("#f8fafc"),
    SubText     = Color3.fromHex("#94a3b8"),
    Hover       = Color3.fromHex("#c084fc"),
    HoverChange = 0.04,
})

-- ============================================================
-- 3) CREATE WINDOW
-- ============================================================
local Window = Fluent:CreateWindow({
    Title       = "Fluent Suite",
    SubTitle    = "Audit & Feature Test",
    Author      = "thanyathonxyz",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(600, 480),
    Acrylic     = true,
    Theme       = "CyberAmethyst",
    MinimizeKey = Enum.KeyCode.LeftControl,

    -- Mobile Toggle Button: automatically visible on mobile, draggable
    ToggleButton = {
        Enabled  = true, -- Set true to force visible on PC for testing
        Shape    = "Circle", -- "Circle" | "Square" | "Logo"
        Size     = 50,
        Position = "TopCenter", -- "TopLeft", "TopCenter", "TopRight", "CenterLeft", etc.
    },
})

-- ============================================================
-- 4) DEFINE TABS
-- ============================================================
local Tabs = {
    Home     = Window:AddTab({ Title = "Dashboard", Icon = "home" }),
    Player   = Window:AddTab({ Title = "Player",    Icon = "user" }),
    Visuals  = Window:AddTab({ Title = "Visuals",   Icon = "eye" }),
    Elements = Window:AddTab({ Title = "Elements",  Icon = "sliders" }),
    SubTabs  = Window:AddTab({ Title = "Sub-Tabs",  Icon = "layers" }),
    Settings = Window:AddTab({ Title = "Settings",  Icon = "settings" }),
}

-- ============================================================
-- 5) DASHBOARD / HOME TAB
-- ============================================================
do
    local StatusSection = Tabs.Home:AddSection({ Title = "Overview & System", Opened = true })

    StatusSection:AddBanner({
        Title   = "Fluent UI Library - Enhanced Edition",
        Content = "Full memory leak fixes, GC weak-registry, touch/mobile gestures, clipboard config sharing & modern Luau performance.",
        Style   = "info",
    })

    local SysInfo = StatusSection:AddParagraph({
        Title   = "Client Information",
        Content = string.format("Player: %s\nUser ID: %d\nExecutor: %s", 
            LocalPlayer.Name, 
            LocalPlayer.UserId, 
            (identifyexecutor and identifyexecutor()) or "Standard Client"
        ),
    })

    local QuickActions = Tabs.Home:AddSection({ Title = "Interactive Actions", Opened = true })

    -- Test Notification with Action Buttons (Newly implemented feature)
    QuickActions:AddButton({
        Title       = "Test Notification with Buttons",
        Description = "Tests primary & secondary interactive callbacks in notification popup",
        Callback    = function()
            Fluent:Notify({
                Title      = "Security Prompt",
                Content    = "A sensitive action has been requested.",
                SubContent = "Would you like to grant permission?",
                Duration   = 8,
                Buttons    = {
                    {
                        Title    = "Allow",
                        Callback = function()
                            Fluent:Notify({
                                Title    = "Granted",
                                Content  = "Action was approved successfully!",
                                Duration = 3,
                            })
                        end,
                    },
                    {
                        Title    = "Deny",
                        Callback = function()
                            Fluent:Notify({
                                Title    = "Denied",
                                Content  = "Action was cancelled.",
                                Duration = 3,
                            })
                        end,
                    },
                },
            })
        end,
    })

    -- Test Modal Dialog
    QuickActions:AddButton({
        Title       = "Test Confirmation Dialog",
        Description = "Opens an animated modal dialog box",
        Callback    = function()
            Window:Dialog({
                Title   = "Test Dialog",
                Content = "This is a modal dialog test. Are you enjoying Fluent UI?",
                Buttons = {
                    {
                        Title    = "Yes, absolutely!",
                        Callback = function()
                            Fluent:Notify({ Title = "Thank you!", Content = "Glad to hear that!", Duration = 3 })
                        end,
                    },
                    {
                        Title    = "Needs work",
                        Callback = function()
                            Fluent:Notify({ Title = "Feedback", Content = "We appreciate your feedback!", Duration = 3 })
                        end,
                    },
                },
            })
        end,
    })

    -- Banners showcase
    local BannerSection = Tabs.Home:AddSection({ Title = "Banner Styles", Opened = false })

    BannerSection:AddBanner({
        Title   = "Success Status",
        Content = "All library modules initialized with zero memory leaks.",
        Style   = "success",
    })

    BannerSection:AddBanner({
        Title   = "Warning Advisory",
        Content = "High speed values may trigger anti-cheat detections in strict games.",
        Style   = "warning",
    })

    BannerSection:AddBanner({
        Title   = "Error Alert",
        Content = "Sample error banner style for displaying critical failures.",
        Style   = "error",
    })
end

-- ============================================================
-- 6) PLAYER TAB (Real interactive character modifications)
-- ============================================================
do
    local MovementSection = Tabs.Player:AddSection({ Title = "Movement & Physics", Opened = true })

    -- Helper to get humanoid safely
    local function GetHumanoid()
        local char = LocalPlayer.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    -- WalkSpeed Slider with suffix and click-to-jump rail
    local WalkSpeedSlider = MovementSection:AddSlider("WalkSpeed", {
        Title       = "Walk Speed",
        Description = "Adjust your character's movement velocity",
        Default     = 16,
        Min         = 16,
        Max         = 250,
        Rounding    = 0,
        Suffix      = " studs/s",
        Callback    = function(Value)
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = Value
            end
        end,
    })

    -- JumpPower Slider
    local JumpPowerSlider = MovementSection:AddSlider("JumpPower", {
        Title       = "Jump Power",
        Description = "Adjust jump height/power",
        Default     = 50,
        Min         = 50,
        Max         = 300,
        Rounding    = 0,
        Suffix      = " pwr",
        Callback    = function(Value)
            local hum = GetHumanoid()
            if hum then
                if hum.UseJumpPower then
                    hum.JumpPower = Value
                else
                    hum.JumpHeight = Value * (7.2 / 50)
                end
            end
        end,
    })

    -- Stepper: Field of View (FOV) Adjuster
    local FOVStepper = MovementSection:AddStepper("FOVStepper", {
        Title       = "Camera FOV",
        Description = "Use +/- buttons to step Field of View",
        Default     = 70,
        Min         = 40,
        Max         = 120,
        Step        = 5,
        Callback    = function(Value)
            local camera = workspace.CurrentCamera
            if camera then
                camera.FieldOfView = Value
            end
        end,
    })

    -- Infinite Jump Toggle
    local InfJumpConnection
    local InfJumpToggle = MovementSection:AddToggle("InfiniteJump", {
        Title       = "Infinite Jump",
        Description = "Jump continuously even while in mid-air",
        Default     = false,
        Callback    = function(Enabled)
            if InfJumpConnection then
                InfJumpConnection:Disconnect()
                InfJumpConnection = nil
            end

            if Enabled then
                InfJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local hum = GetHumanoid()
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        end,
    })

    -- Noclip Toggle (RunService.Stepped)
    local NoclipConnection
    local NoclipToggle = MovementSection:AddToggle("Noclip", {
        Title       = "Noclip",
        Description = "Pass through walls and solid barriers",
        Default     = false,
        Callback    = function(Enabled)
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end

            if Enabled then
                NoclipConnection = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end,
    })

    -- Sprint Boost Keybind
    MovementSection:AddKeybind("SprintKeybind", {
        Title           = "Sprint Boost Key",
        Description     = "Toggle or hold to gain +35 walk speed",
        Default         = "Q",
        Mode            = "Toggle", -- "Toggle" or "Hold"
        Callback        = function(Active)
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = Active and (WalkSpeedSlider.Value + 35) or WalkSpeedSlider.Value
            end
        end,
        ChangedCallback = function(NewKey)
            print("Sprint key changed to:", NewKey)
        end,
    })

    -- Auto restore values on respawn
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = WalkSpeedSlider.Value
            if hum.UseJumpPower then
                hum.JumpPower = JumpPowerSlider.Value
            else
                hum.JumpHeight = JumpPowerSlider.Value * (7.2 / 50)
            end
        end
    end)
end

-- ============================================================
-- 7) VISUALS & ESP TAB
-- ============================================================
do
    local VisualsSection = Tabs.Visuals:AddSection({ Title = "Character Highlighting", Opened = true })

    local HighlightInstance = nil

    local function UpdateHighlight(fillColor, outlineColor, transparency, enabled)
        local char = LocalPlayer.Character
        if not char then return end

        if enabled then
            if not HighlightInstance or HighlightInstance.Parent ~= char then
                if HighlightInstance then HighlightInstance:Destroy() end
                HighlightInstance = Instance.new("Highlight")
                HighlightInstance.Name = "FluentHighlight"
                HighlightInstance.Adornee = char
                HighlightInstance.Parent = char
            end
            HighlightInstance.FillColor = fillColor
            HighlightInstance.OutlineColor = outlineColor
            HighlightInstance.FillTransparency = transparency
            HighlightInstance.OutlineTransparency = 0
            HighlightInstance.Enabled = true
        else
            if HighlightInstance then
                HighlightInstance.Enabled = false
            end
        end
    end

    local HighlightToggle = VisualsSection:AddToggle("HighlightEnabled", {
        Title       = "Self Highlight (Chams)",
        Description = "Render high-visibility outline over your character",
        Default     = false,
    })

    local FillColorpicker = VisualsSection:AddColorpicker("HighlightFill", {
        Title        = "Fill Color & Opacity",
        Default      = Color3.fromRGB(168, 85, 247),
        Transparency = 0.5, -- Tests transparency slider with mobile touch drag
    })

    local OutlineColorpicker = VisualsSection:AddColorpicker("HighlightOutline", {
        Title   = "Outline Color",
        Default = Color3.fromRGB(255, 255, 255),
    })

    local function ApplyHighlight()
        UpdateHighlight(
            FillColorpicker.Value,
            OutlineColorpicker.Value,
            FillColorpicker.Transparency or 0.5,
            HighlightToggle.Value
        )
    end

    HighlightToggle:OnChanged(ApplyHighlight)
    FillColorpicker:OnChanged(ApplyHighlight)
    OutlineColorpicker:OnChanged(ApplyHighlight)

    -- SelectionList: Filter entities
    local TargetFilterSection = Tabs.Visuals:AddSection({ Title = "Target Filter", Opened = true })

    TargetFilterSection:AddSelectionList("TargetPriorities", {
        Title       = "Entities to Highlight",
        Description = "Select entity categories using toggle chips",
        Values      = {"Enemies", "Bosses", "Teammates", "NPCs", "Dropped Items", "Chests"},
        Default     = {"Enemies", "Bosses", "Chests"},
        Callback    = function(Selected)
            print("Target categories selected:", table.concat(Selected, ", "))
        end,
    })
end

-- ============================================================
-- 8) ELEMENTS PLAYGROUND TAB (All UI Components)
-- ============================================================
do
    local InputsSection = Tabs.Elements:AddSection({ Title = "Dropdowns & Selectors", Opened = true })

    -- Single-Select Dropdown with dynamic update demo
    local WeaponDropdown = InputsSection:AddDropdown("WeaponChoice", {
        Title       = "Equipped Weapon",
        Description = "Select active combat gear",
        Values      = {"Celestial Katana", "Dark Blade", "Dragon Trident", "Soul Cane", "Mythic Scythe"},
        Default     = "Celestial Katana",
        Callback    = function(Value)
            print("Weapon equipped:", Value)
        end,
    })

    -- Button to dynamically modify dropdown list
    InputsSection:AddButton({
        Title       = "Add Rare Weapon to Dropdown",
        Description = "Demonstrates Dropdown:SetValues() dynamic updates",
        Callback    = function()
            local currentValues = {"Celestial Katana", "Dark Blade", "Dragon Trident", "Soul Cane", "Mythic Scythe", "True Triple Katana ⭐"}
            WeaponDropdown:SetValues(currentValues)
            Fluent:Notify({
                Title   = "Dropdown Updated",
                Content = "Added 'True Triple Katana' to the list!",
                Duration = 3,
            })
        end,
    })

    -- Multi-Select Dropdown
    InputsSection:AddDropdown("ActiveBuffs", {
        Title       = "Active Perks & Buffs",
        Description = "Select multiple enabled perks",
        Values      = {"Double Exp", "Auto Quest", "Fast Attack", "Anti Stun", "Auto Collect"},
        Default     = {"Fast Attack", "Auto Collect"},
        Multi       = true,
        Callback    = function(Values)
            for perk, enabled in pairs(Values) do
                print("Perk:", perk, "=", enabled)
            end
        end,
    })

    local FormSection = Tabs.Elements:AddSection({ Title = "Forms & Quick Inputs", Opened = true })

    -- Text Input (tests mobile virtual keyboard dismissal)
    local CustomTextInput = FormSection:AddInput("CustomMessage", {
        Title       = "Broadcast Message",
        Description = "Input will commit on enter or mobile blur",
        Default     = "Hello Fluent!",
        Placeholder = "Type a message...",
        Numeric     = false,
        Finished    = true, -- only fire callback on Enter / focus lost
        Callback    = function(Text)
            print("Message submitted:", Text)
            Fluent:Notify({
                Title   = "Input Received",
                Content = Text,
                Duration = 3,
            })
        end,
    })

    -- ButtonGroup: Mode Selector
    FormSection:AddButtonGroup({
        Title       = "Performance Profile",
        Description = "Select performance optimization preset",
        Buttons     = {"Balanced", "High FPS", "Ultra Quality", "Battery Saver"},
        Callback    = function(Selected)
            for btn, state in pairs(Selected) do
                if state then
                    print("Active Performance Mode:", btn)
                end
            end
        end,
    })

    -- Stepper: Numeric Count
    FormSection:AddStepper("SpawnCount", {
        Title       = "Batch Spawn Amount",
        Description = "Adjust count with stepped precision",
        Default     = 10,
        Min         = 1,
        Max         = 100,
        Step        = 5,
        Callback    = function(val)
            print("Spawn count:", val)
        end,
    })

    -- Shorthand API Demo Section
    local ShorthandSection = Tabs.Elements:AddSection({ Title = "Shorthand API Showcase", Opened = false })

    ShorthandSection:AddParagraph({
        Title   = "About Shorthand Syntax",
        Content = "You can write Section:Toggle({...}) instead of Section:AddToggle(flag, {...}) with Flag inside the table.",
    })

    ShorthandSection:Toggle({
        Flag     = "ShorthandToggle",
        Title    = "Compact Toggle",
        Default  = true,
        Callback = function(v) print("Shorthand Toggle:", v) end,
    })

    ShorthandSection:Slider({
        Flag     = "ShorthandSlider",
        Title    = "Compact Slider",
        Default  = 75,
        Min      = 0,
        Max      = 100,
        Suffix   = "%",
    })

    ShorthandSection:Dropdown({
        Flag    = "ShorthandDropdown",
        Title   = "Compact Dropdown",
        Values  = {"Alpha", "Beta", "Gamma", "Delta"},
        Default = "Alpha",
    })
end

-- ============================================================
-- 9) SUB-TABS TAB (Nested inline tab groups)
-- ============================================================
do
    local SubTabSection = Tabs.SubTabs:AddSection({ Title = "Nested Tabbed Interface", Opened = true })

    local NestedTabs = SubTabSection:AddTabs({
        Titles = {
            { Title = "General",    Icon = "settings" },
            { Title = "Combat",     Icon = "shield" },
            { Title = "Automation", Icon = "cpu" },
        },
        Default = 1,
    })

    -- General SubTab
    local GeneralTab = NestedTabs.Tabs["General"]
    GeneralTab:AddToggle("SubTab_SoundAlerts", {
        Title   = "Play Sound Alerts",
        Default = true,
    })
    GeneralTab:AddSlider("SubTab_Volume", {
        Title   = "Sound Volume",
        Default = 80,
        Min     = 0,
        Max     = 100,
        Suffix  = "%",
    })

    -- Combat SubTab
    local CombatTab = NestedTabs.Tabs["Combat"]
    CombatTab:AddToggle("SubTab_AutoBlock", {
        Title   = "Auto Parry / Block",
        Default = false,
    })
    CombatTab:AddSlider("SubTab_ParryDistance", {
        Title   = "Reaction Range",
        Default = 15,
        Min     = 5,
        Max     = 50,
        Suffix  = " studs",
    })

    -- Automation SubTab
    local AutoTab = NestedTabs.Tabs["Automation"]
    AutoTab:AddToggle("SubTab_AutoFarm", {
        Title   = "Auto Farm Mobs",
        Default = false,
    })
    AutoTab:AddDropdown("SubTab_MobTarget", {
        Title   = "Priority Mob",
        Values  = {"Bandit [Lv. 5]", "Pirate [Lv. 15]", "Boss [Lv. 50]"},
        Default = "Bandit [Lv. 5]",
    })
end

-- ============================================================
-- 10) SETTINGS TAB (Interface & SaveManager with Clipboard)
-- ============================================================
do
    -- Configure SaveManager and InterfaceManager folders
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})

    InterfaceManager:SetFolder("FluentTestSuite")
    SaveManager:SetFolder("FluentTestSuite/configs")

    -- Build Interface settings (Themes, Acrylic, Transparency, Menu Keybind)
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)

    -- Build Config Manager (Save, Load, Autoload + Clipboard Export/Import)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- Safe Unload Section
    local DangerSection = Tabs.Settings:AddSection({ Title = "Interface Management", Opened = true })

    DangerSection:AddButton({
        Title       = "Destroy Interface",
        Description = "Completely unloads UI, disconnects signals and frees memory",
        Callback    = function()
            Window:Dialog({
                Title   = "Confirm Unload",
                Content = "Are you sure you want to unload Fluent UI? All active connections will be terminated.",
                Buttons = {
                    {
                        Title    = "Yes, Unload",
                        Callback = function()
                            Fluent:Destroy()
                        end,
                    },
                    {
                        Title = "Cancel",
                    },
                },
            })
        end,
    })
end

-- ============================================================
-- 11) INITIALIZATION & WELCOME
-- ============================================================
-- Select default Home tab
Window:SelectTab(1)

-- Display loaded notification
Fluent:Notify({
    Title      = "Fluent Interface Suite",
    Content    = "Loaded successfully!",
    SubContent = "Press LeftControl or tap the icon to toggle.",
    Duration   = 6,
})

-- Attempt to autoload any previously saved configuration
SaveManager:LoadAutoloadConfig()
