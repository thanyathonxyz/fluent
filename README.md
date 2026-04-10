<img src="Assets/logodark.png#gh-dark-mode-only" alt="fluent">
<img src="Assets/logolight.png#gh-light-mode-only" alt="fluent">

## ⚡ Features

- Modern UI design with Acrylic blur effect
- 16 element types: Toggle, Slider, Dropdown, Input, Keybind, Colorpicker, Button, Paragraph, Banner, ButtonGroup, Stepper, SelectionList, Sub-Tabs, Section, Dialog, Notification
- 7 built-in themes (Dark, Darker, Night, Amethyst, Aqua, Rose, Light) + custom theme support
- SaveManager — auto save/load configs
- InterfaceManager — theme & UI settings panel
- Mobile support with draggable toggle button
- Search bar in Dropdowns

## 🔌 Installation

```lua
local Fluent = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/dist/main.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/InterfaceManager.lua"
))()
```

## 🚀 Quick Start

```lua
local Window = Fluent:CreateWindow({
    Title    = "My Script",
    SubTitle = "v1.0",
    TabWidth = 160,
    Size     = UDim2.fromOffset(580, 460),
    Acrylic  = true,
    Theme    = "Dark",
})

local Tab = Window:AddTab({ Title = "Main", Icon = "home" })
local Section = Tab:AddSection({ Title = "Features" })

Section:AddToggle("MyToggle", {
    Title   = "Auto Farm",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

Section:AddSlider("MySlider", {
    Title = "Speed", Default = 16, Min = 1, Max = 100, Rounding = 0,
})

Window:SelectTab(1)
```

## 📖 Documentation

**[Full API Documentation (DOCUMENTATION.md)](DOCUMENTATION.md)** — ครบทุก element, method, theme, addon พร้อมตัวอย่างโค้ด

## 📜 Examples

- [FullFeatureExample.lua](FullFeatureExample.lua) — ตัวอย่าง Element ครบทุกชนิด (16 ประเภท)
- [Example.lua](Example.lua) — ตัวอย่าง Sub-Tabs + Mobile Toggle Button

## Credits

- [richie0866/remote-spy](https://github.com/richie0866/remote-spy) - Assets for the UI, some of the code
- [violin-suzutsuki/LinoriaLib](https://github.com/violin-suzutsuki/LinoriaLib) - Code for most of the elements, save manager
- [7kayoh/Acrylic](https://github.com/7kayoh/Acrylic) - Porting richie0866's acrylic module to lua
- [Latte Softworks & Kotera](https://discord.gg/rMMByr4qas) - Bundler