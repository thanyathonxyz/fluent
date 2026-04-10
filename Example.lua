local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/dist/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent UI",
    SubTitle = "Premium Overhaul",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Night",
    MinimizeKey = Enum.KeyCode.LeftControl,
    ToggleButton = {
        Shape = "Circle",
        Size  = 50,
    },
})

-- Fluent now uses a single Search Bar in the Sidebar by default.
-- Tabs also feature a vertical indicator pill.

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Custom Sub-Tabs for Main Tab
-- Sub-tabs now support full theme reactivity (Night/Dark/Light)
local MainSubTabs = Tabs.Main:AddTabs({
    Titles = {"Auto Farm", "Combat", "Config"},
    Default = 1
})

-- Adding elements to the "Auto Farm" sub-tab
local AutoFarm = MainSubTabs.Tabs["Auto Farm"]

AutoFarm:AddBanner({
    Title = "Guide",
    Content = "Welcome to the new Fluent UI. Use the sidebar to search and sub-tabs to navigate.",
    Style = "info",
})

AutoFarm:AddBanner({
    Title = "Warning",
    Content = "Using excessive Farm Speed may trigger anti-cheat. Stay under 8 for safety.",
    Style = "warning",
})

AutoFarm:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Level",
    Default = false,
    Callback = function(Value)
        print("Auto Farm:", Value)
    end
})

AutoFarm:AddSlider("FarmSpeed", {
    Title = "Farm Speed",
    Description = "Adjust how fast you farm",
    Default = 5,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        print("Speed:", Value)
    end
})

-- Adding elements to the "Combat" sub-tab
local Combat = MainSubTabs.Tabs["Combat"]

Combat:AddButtonGroup({
    Title = "Skill Selection",
    Description = "Select which skills to use during combat",
    Buttons = {"Z", "X", "C", "V"},
    Callback = function(Selected)
        for skill, state in pairs(Selected) do
            print("Skill " .. skill .. ": " .. (state and "Enabled" or "Disabled"))
        end
    end
})

Combat:AddDropdown("WeaponSelect", {
    Title = "Select Weapon",
    Values = {"Sword", "Fruit", "Melee", "Gun"},
    Default = 1,
    Callback = function(Value)
        print("Weapon:", Value)
    end
})

-- Settings Tab
Tabs.Settings:AddButton({
    Title = "Destroy UI",
    Description = "Unload the interface",
    Callback = function()
        Window:Dialog({
            Title = "Unload",
            Content = "Are you sure you want to unload the UI?",
            Buttons = {
                {
                    Title = "Yes",
                    Callback = function()
                        Fluent:Destroy()
                    end
                },
                { Title = "No" }
            }
        })
    end
})

-- Finalize
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentPremium")
SaveManager:SetFolder("FluentPremium/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent UI",
    Content = "Successfully loaded Premium Overhaul",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()