# Fluent UI Library — เอกสารการใช้งานฉบับเต็ม

> **Fluent UI** — Roblox UI Library ที่รองรับทั้ง PC และ Mobile  
> Repository: `thanyathonxyz/fluent` | Author: **Tiger**

---

## สารบัญ

1. [การติดตั้ง](#1-การติดตั้ง)
2. [สร้าง Window](#2-สร้าง-window)
3. [เพิ่ม Tab](#3-เพิ่ม-tab)
4. [เพิ่ม Section](#4-เพิ่ม-section)
5. [Elements ทั้งหมด](#5-elements-ทั้งหมด)
   - [Toggle](#toggle)
   - [Slider](#slider)
   - [Dropdown](#dropdown)
   - [Input](#input)
   - [Keybind](#keybind)
   - [Colorpicker](#colorpicker)
   - [Button](#button)
   - [Paragraph](#paragraph)
   - [Banner](#banner)
   - [ButtonGroup](#buttongroup)
   - [Stepper](#stepper)
   - [SelectionList](#selectionlist)
   - [Sub-Tabs](#sub-tabs)
6. [Dialog (ป๊อปอัพ)](#6-dialog)
7. [Notification](#7-notification)
8. [Themes (ธีม)](#8-themes)
9. [SaveManager (บันทึก Config)](#9-savemanager)
10. [InterfaceManager (ตั้งค่า UI)](#10-interfacemanager)
11. [Mobile Toggle Button](#11-mobile-toggle-button)
12. [Shorthand API](#12-shorthand-api)
13. [อ่านค่าจาก Flag](#13-อ่านค่าจาก-flag)
14. [ตัวอย่างเต็ม](#14-ตัวอย่างเต็ม)

---

## 1. การติดตั้ง

```lua
-- โหลด Library หลัก
local Fluent = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/dist/main.lua"
))()

-- โหลด Addons (ถ้าต้องการ Save/Load Config)
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/InterfaceManager.lua"
))()
```

---

## 2. สร้าง Window

```lua
local Window = Fluent:CreateWindow({
    Title       = "My Script",       -- ชื่อหัวหลัก (บังคับ)
    SubTitle    = "v1.0",            -- ชื่อรอง
    Author      = "Tiger",           -- ชื่อผู้เขียน
    TabWidth    = 160,               -- ความกว้าง sidebar (px)
    Size        = UDim2.fromOffset(580, 460), -- ขนาดหน้าต่าง
    Acrylic     = true,              -- เปิดเอฟเฟค Acrylic (โปร่งแสง)
    Theme       = "Dark",            -- ธีม (ดูรายชื่อด้านล่าง)
    MinimizeKey = Enum.KeyCode.LeftControl, -- ปุ่มย่อ/ขยาย UI

    -- ปุ่มลอยสำหรับ Mobile (ดูหัวข้อ 11)
    ToggleButton = {
        Image = "rbxassetid://10734896206",
        Shape = "Circle",
        Size  = 50,
    },
})
```

**Window Methods:**

| Method | คำอธิบาย |
|--------|----------|
| `Window:AddTab(Config)` | เพิ่ม Tab ใหม่ |
| `Window:SelectTab(index)` | เลือก Tab (1, 2, 3, ...) |
| `Window:Minimize()` | ย่อ/ขยาย Window |
| `Window:Dialog(Config)` | เปิด Dialog box |

---

## 3. เพิ่ม Tab

```lua
local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "home" }),
    Combat   = Window:AddTab({ Title = "Combat",   Icon = "crosshair" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

-- เลือก Tab เริ่มต้น
Window:SelectTab(1)  -- เลือก tab แรก
```

**Icon** ใช้ชื่อจาก [Lucide Icons](https://lucide.dev/icons/) เช่น:  
`"home"`, `"settings"`, `"eye"`, `"crosshair"`, `"shield-check"`, `"palette"`, `"bell"`, `"layout-list"`

---

## 4. เพิ่ม Section

Section คือกล่องแบ่งกลุ่ม element ภายใน Tab — กดหัว Section เพื่อพับ/กาง

```lua
local MainSection = Tabs.Main:AddSection({
    Title  = "Main Settings",  -- ชื่อ Section
    Opened = true,             -- เปิดกางตั้งแต่แรก (default: true)
})

-- Section ซ้อน Section ก็ได้
local SubSection = MainSection:AddSection({
    Title  = "Advanced",
    Opened = false,
})
```

---

## 5. Elements ทั้งหมด

ทุก Element เพิ่มบน **Section** ได้ 2 แบบ:
- **แบบเต็ม**: `Section:AddToggle("FlagName", { ... })` — ต้องใส่ Flag เป็น argument แรก
- **แบบสั้น (Shorthand)**: `Section:Toggle({ Flag = "FlagName", ... })` — ใส่ Flag ไว้ใน table

Flag คือชื่อที่ใช้อ้างอิงค่า (ต้องไม่ซ้ำกัน) สำหรับ Save/Load Config

---

### Toggle

สวิตช์เปิด/ปิด

```lua
local MyToggle = Section:AddToggle("MyToggle", {
    Title       = "Enable Feature",     -- ข้อความแสดง
    Description = "Turn this on/off",   -- คำอธิบาย (ไม่บังคับ)
    Default     = false,                -- ค่าเริ่มต้น
    Callback    = function(value)
        print("Toggle:", value)         -- value = true/false
    end,
})

-- ฟัง event เปลี่ยนค่า
MyToggle:OnChanged(function(value)
    print("Changed to:", value)
end)

-- เปลี่ยนค่าด้วยโค้ด
MyToggle:SetValue(true)

-- อ่านค่า
print(MyToggle.Value)  -- true / false
```

---

### Slider

แถบเลื่อนค่าตัวเลข

```lua
local MySlider = Section:AddSlider("MySlider", {
    Title       = "Speed",
    Description = "Character walk speed",
    Default     = 16,          -- ค่าเริ่มต้น
    Min         = 1,           -- ค่าต่ำสุด
    Max         = 100,         -- ค่าสูงสุด
    Rounding    = 0,           -- ทศนิยม (0 = จำนวนเต็ม, 1 = ทศนิยม 1 ตำแหน่ง)
    Suffix      = " studs/s",  -- ข้อความต่อท้ายค่า (ไม่บังคับ)
    Callback    = function(value)
        print("Speed:", value)
    end,
})

MySlider:OnChanged(function(value) end)
MySlider:SetValue(50)
print(MySlider.Value)  -- 50
```

---

### Dropdown

เมนูเลือกจากรายการ (รองรับ Search ในตัว)

```lua
-- แบบเลือกอันเดียว
local MyDropdown = Section:AddDropdown("MyDropdown", {
    Title       = "Target Part",
    Description = "Which body part to aim",
    Values      = {"Head", "HumanoidRootPart", "Torso"},
    Default     = "Head",       -- ค่าเริ่มต้น (string)
    Callback    = function(value)
        print("Selected:", value)  -- value = "Head"
    end,
})

-- แบบเลือกหลายอัน
local MultiDrop = Section:AddDropdown("MultiDrop", {
    Title    = "Features",
    Values   = {"ESP", "Aimbot", "Speed", "Noclip"},
    Default  = {"ESP", "Speed"},   -- ค่าเริ่มต้น (table)
    Multi    = true,               -- เปิดโหมดเลือกหลายอัน
    Callback = function(value)
        -- value = { ESP = true, Speed = true }
        for name, enabled in pairs(value) do
            print(name, enabled)
        end
    end,
})

-- เปลี่ยนรายการ (เช่น อัปเดตรายชื่อผู้เล่น)
MyDropdown:SetValues({"Head", "Torso", "LeftArm"})

-- เปลี่ยนค่า
MyDropdown:SetValue("Torso")

MyDropdown:OnChanged(function(value) end)
print(MyDropdown.Value)  -- "Torso"
```

---

### Input

ช่องกรอกข้อความ

```lua
local MyInput = Section:AddInput("MyInput", {
    Title       = "Username",
    Description = "Enter player name",
    Default     = "",                   -- ค่าเริ่มต้น
    Placeholder = "Type here...",       -- ข้อความจางๆ ตอนว่าง
    Numeric     = false,               -- true = รับแค่ตัวเลข
    Finished    = false,               -- true = Callback เรียกตอนกด Enter เท่านั้น
    MaxLength   = 50,                  -- จำกัดตัวอักษร (ไม่บังคับ)
    Callback    = function(value)
        print("Input:", value)
    end,
})

MyInput:SetValue("Hello")
MyInput:OnChanged(function(value) end)
print(MyInput.Value)  -- "Hello"
```

---

### Keybind

ปุ่มกดลัด (รองรับทั้ง Keyboard และ Mouse)

```lua
local MyKeybind = Section:AddKeybind("MyKeybind", {
    Title       = "Toggle Aimbot",
    Description = "Press to set key",
    Default     = "E",             -- ค่าเริ่มต้น (ชื่อ KeyCode)
    Mode        = "Toggle",       -- "Toggle" | "Hold" | "Always"
    Callback    = function(state)
        print("Keybind activated:", state) -- state = true/false (Toggle mode)
    end,
    ChangedCallback = function(newKey)
        print("Key changed to:", newKey)
    end,
})

-- เช็คว่ากดอยู่ไหม (ใช้ใน loop)
if MyKeybind:GetState() then
    -- ทำอะไรบางอย่าง
end

-- เปลี่ยนค่า
MyKeybind:SetValue("F", "Hold")

-- ฟัง event
MyKeybind:OnChanged(function(newKey) end)
MyKeybind:OnClick(function(toggled) end)

print(MyKeybind.Value)  -- "F"
print(MyKeybind.Mode)   -- "Hold"
```

**Mode:**
| Mode | พฤติกรรม |
|------|----------|
| `"Toggle"` | กด 1 ครั้ง = เปิด, กดอีกครั้ง = ปิด |
| `"Hold"` | กดค้าง = เปิด, ปล่อย = ปิด |
| `"Always"` | เปิดตลอด |

**ชื่อปุ่มพิเศษ:** `"MouseLeft"`, `"MouseRight"`

---

### Colorpicker

ตัวเลือกสี

```lua
local MyColor = Section:AddColorpicker("MyColor", {
    Title        = "ESP Color",
    Default      = Color3.fromRGB(255, 0, 0),   -- สีเริ่มต้น
    Transparency = 0,                            -- ค่าโปร่งใส 0-1 (ไม่บังคับ)
    Callback     = function(color)
        print("Color:", color)   -- color = Color3
    end,
})

-- เปลี่ยนค่าด้วย Color3
MyColor:SetValueRGB(Color3.fromRGB(0, 255, 0))

print(MyColor.Value)         -- Color3
print(MyColor.Transparency)  -- number
```

---

### Button

ปุ่มกด

```lua
Section:AddButton({
    Title       = "Execute",
    Description = "Run the script now",    -- ไม่บังคับ
    Callback    = function()
        print("Button clicked!")
    end,
})
```

> Button ไม่มี Flag — ไม่ save/load ค่า

---

### Paragraph

ข้อความอ่านอย่างเดียว

```lua
Section:AddParagraph({
    Title   = "Information",
    Content = "This is a read-only text block.\nSupports multi-line.",
})
```

---

### Banner

แถบข้อความเด่นพร้อมสี

```lua
Section:AddBanner({
    Title   = "Welcome",
    Content = "Script loaded successfully!",
    Style   = "info",    -- "info" | "success" | "warning" | "error"
})
```

| Style | สี | ใช้งาน |
|-------|-----|--------|
| `"info"` | ม่วง (Accent) | ข้อมูลทั่วไป |
| `"success"` | เขียว | สำเร็จ |
| `"warning"` | เหลือง | คำเตือน |
| `"error"` | แดง | ข้อผิดพลาด |

```lua
-- เปลี่ยน style ภายหลัง
MyBanner:SetStyle("success")
MyBanner:SetTitle("Done!")
MyBanner:SetContent("Operation completed.")
```

---

### ButtonGroup

กลุ่มปุ่มเลือก (กดเปิด/ปิดแต่ละอัน)

```lua
Section:AddButtonGroup({
    Title       = "Select Rarity",
    Description = "Choose rarities to auto-sell",
    Buttons     = {"Common", "Uncommon", "Rare", "Epic", "Legendary"},
    Callback    = function(selected)
        -- selected = { Common = true, Rare = true, ... }
        for name, isOn in pairs(selected) do
            print(name, isOn)
        end
    end,
})
```

---

### Stepper

ปุ่ม +/- ปรับค่าตัวเลข

```lua
local MyStepper = Section:AddStepper("MyStepper", {
    Title       = "Thread Count",
    Description = "Number of threads",
    Default     = 2,
    Min         = 1,
    Max         = 10,
    Step        = 1,       -- เพิ่ม/ลดทีละเท่าไร
    Callback    = function(value)
        print("Threads:", value)
    end,
})

MyStepper:SetValue(5)
MyStepper:OnChanged(function(value) end)
print(MyStepper.Value)  -- 5
```

---

### SelectionList

รายการเลือกแบบ checkbox (เลือกได้หลายอัน)

```lua
local MyList = Section:AddSelectionList("MyList", {
    Title       = "Target Zones",
    Description = "Choose which zones to farm",
    Values      = {"Zone 1", "Zone 2", "Zone 3", "Boss Room"},
    Default     = {"Zone 1"},   -- เลือกไว้ตั้งแต่แรก
    Callback    = function(selected)
        -- selected = {"Zone 1", "Zone 3"}
        print("Selected:", table.concat(selected, ", "))
    end,
})

MyList:OnChanged(function(selected) end)
print(MyList.Selected)  -- table
```

---

### Sub-Tabs

แท็บย่อยภายใน Section (จัดกลุ่ม element แยกหน้า)

```lua
local SubTabs = Section:AddTabs({
    Titles = {
        { Title = "General",  Icon = "settings" },
        { Title = "Visual",   Icon = "eye" },
        { Title = "Advanced", Icon = "wrench", Color = Color3.fromRGB(239, 68, 68) },
    },
    Default = 1,   -- เลือก tab แรกเป็นค่าเริ่มต้น
})

-- เพิ่ม element ใน Sub-Tab (ใช้เหมือน Section ปกติ)
SubTabs.Tabs["General"]:AddToggle("SubToggle", {
    Title   = "Feature A",
    Default = true,
})

SubTabs.Tabs["Visual"]:AddSlider("SubSlider", {
    Title   = "Brightness",
    Default = 50, Min = 0, Max = 100, Rounding = 0,
})

SubTabs.Tabs["Advanced"]:AddParagraph({
    Title   = "Warning",
    Content = "Advanced settings can affect performance.",
})
```

---

## 6. Dialog

ป๊อปอัพยืนยัน

```lua
Window:Dialog({
    Title   = "Confirm Action",
    Content = "Are you sure you want to unload?",
    Buttons = {
        {
            Title    = "Yes",
            Callback = function()
                print("Confirmed!")
            end,
        },
        {
            Title    = "No",
            Callback = function()
                print("Cancelled.")
            end,
        },
    },
})
```

---

## 7. Notification

ป้ายแจ้งเตือนมุมขวาล่าง

```lua
Fluent:Notify({
    Title      = "Success",              -- หัวข้อ
    Content    = "Script loaded!",       -- เนื้อหา
    SubContent = "Press F to toggle",    -- เนื้อหารอง (ไม่บังคับ)
    Duration   = 5,                      -- ปิดอัตโนมัติ (วินาที)
})

-- แบบมีปุ่ม (ไม่ปิดอัตโนมัติ ต้องกดเลือก)
Fluent:Notify({
    Title   = "Update Available",
    Content = "New version found. Update now?",
    Buttons = {
        {
            Title    = "Update",
            Callback = function()
                print("Updating...")
            end,
        },
        {
            Title    = "Later",
            Callback = function() end,
        },
    },
})
```

---

## 8. Themes

### ธีมที่มีมาให้

| ชื่อ | ลักษณะ |
|------|--------|
| `"Dark"` | มืดมาตรฐาน |
| `"Darker"` | มืดกว่า Dark |
| `"Night"` | มืดโทนน้ำเงิน |
| `"Amethyst"` | มืดโทนม่วง |
| `"Aqua"` | มืดโทนฟ้า |
| `"Rose"` | มืดโทนชมพู |
| `"Light"` | สว่าง |

### เปลี่ยนธีม

```lua
Fluent:SetTheme("Amethyst")
```

### สร้างธีมเอง

```lua
Fluent:AddTheme({
    Name = "MyTheme",
    Accent = Color3.fromHex("#8b5cf6"),

    AcrylicMain     = Color3.fromHex("#0f0c16"),
    AcrylicBorder   = Color3.fromHex("#2e2a36"),
    AcrylicGradient = ColorSequence.new(
        Color3.fromHex("#0f0c16"),
        Color3.fromHex("#1a1528")
    ),

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

-- ใช้ธีม
Fluent:SetTheme("MyTheme")
-- หรือตั้งตอนสร้าง Window: Theme = "MyTheme"
```

---

## 9. SaveManager

ระบบ Save/Load Config อัตโนมัติ — บันทึกค่า Toggle, Slider, Dropdown, Input, Keybind, Colorpicker

### ตั้งค่า

```lua
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("MyScriptName")    -- ชื่อโฟลเดอร์เก็บ config
SaveManager:IgnoreThemeSettings()        -- ไม่ save ค่าธีม (แนะนำ)
SaveManager:BuildConfigSection(Tabs.Settings)  -- สร้าง UI ใน Settings tab
```

### โหลด Config อัตโนมัติ (ใส่ท้ายสุดของ script)

```lua
SaveManager:LoadAutoloadConfig()
```

### Save/Load ด้วยโค้ด

```lua
SaveManager:Save("MyConfig")  -- บันทึก
SaveManager:Load("MyConfig")  -- โหลด
```

### ไม่ save บาง element

```lua
SaveManager:SetIgnoreIndexes({ "DebugToggle", "TempSlider" })
```

---

## 10. InterfaceManager

สร้าง UI ตั้งค่าธีม/Acrylic/Transparency/ปุ่มย่อ อัตโนมัติ

```lua
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("MyScriptName")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
```

จะสร้าง Section "Interface" ที่มี:
- Dropdown เลือกธีม
- Toggle Acrylic
- Toggle Transparency
- Keybind ปุ่มย่อ UI

---

## 11. Mobile Toggle Button

ปุ่มลอยบนหน้าจอสำหรับเปิด/ปิด UI บน Mobile (ตรวจจับอัตโนมัติ)

```lua
local Window = Fluent:CreateWindow({
    Title = "My Script",
    -- ... options อื่นๆ

    ToggleButton = {
        -- Enabled  = true,                        -- บังคับแสดงบน PC ด้วย
        Image    = "rbxassetid://10734896206",     -- ไอคอน (rbxassetid)
        Shape    = "Circle",                       -- "Circle" | "Square" | "Logo"
        Size     = 50,                             -- ขนาด (px)
        -- Color = Color3.fromRGB(139, 92, 246),   -- สี (nil = ตามธีม Accent)
        -- Position = UDim2.new(0, 15, 0.5, -25),  -- ตำแหน่งเริ่มต้น
    },
})
```

ปุ่มลากได้ — กดสั้นๆ = เปิด/ปิด UI, ลากค้าง = ย้ายตำแหน่ง

---

## 12. Shorthand API

เขียนสั้นลง — ใส่ `Flag` ไว้ใน table แทนเป็น argument แรก

```lua
-- แบบเต็ม
Section:AddToggle("MyFlag", {
    Title   = "Feature",
    Default = false,
})

-- แบบสั้น (ผลลัพธ์เหมือนกัน)
Section:Toggle({
    Flag    = "MyFlag",
    Title   = "Feature",
    Default = false,
})
```

ใช้ได้กับ: `Toggle`, `Slider`, `Dropdown`, `Input`, `Keybind`, `Colorpicker`, `Stepper`, `SelectionList`, `Paragraph`, `Button`, `Banner`, `ButtonGroup`

---

## 13. อ่านค่าจาก Flag

ทุก Element ที่มี Flag จะถูกเก็บไว้ใน `Fluent.Options`

```lua
-- สมมติสร้าง Toggle ไว้
Section:AddToggle("AimbotEnabled", { Title = "Aimbot", Default = false })

-- อ่านค่าตรงๆ ที่ไหนก็ได้
print(Fluent.Options.AimbotEnabled.Value)  -- false

-- เปลี่ยนค่า
Fluent.Options.AimbotEnabled:SetValue(true)
```

---

## 14. ตัวอย่างเต็ม

### โครงสร้างพื้นฐาน (Starter Template)

```lua
-- 1) โหลด
local Fluent = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/dist/main.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/InterfaceManager.lua"
))()

-- 2) สร้าง Window
local Window = Fluent:CreateWindow({
    Title       = "My Script",
    SubTitle    = "v1.0",
    Author      = "Tiger",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = true,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
    ToggleButton = { Shape = "Circle", Size = 50 },
})

-- 3) สร้าง Tabs
local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

-- 4) สร้าง Section + Elements
local Section1 = Tabs.Main:AddSection({ Title = "Features", Opened = true })

Section1:AddToggle("AutoFarm", {
    Title       = "Auto Farm",
    Description = "Farm mobs automatically",
    Default     = false,
    Callback    = function(v)
        -- ใส่โค้ดที่นี่
    end,
})

Section1:AddSlider("FarmSpeed", {
    Title    = "Farm Speed",
    Default  = 50,
    Min      = 1,
    Max      = 200,
    Rounding = 0,
    Suffix   = " studs/s",
    Callback = function(v)
        -- ใส่โค้ดที่นี่
    end,
})

Section1:AddDropdown("TargetZone", {
    Title   = "Target Zone",
    Values  = {"Zone 1", "Zone 2", "Zone 3"},
    Default = "Zone 1",
    Callback = function(v)
        -- ใส่โค้ดที่นี่
    end,
})

Section1:AddButton({
    Title    = "Teleport to Zone",
    Callback = function()
        -- ใส่โค้ดที่นี่
    end,
})

-- 5) Settings Tab (SaveManager + InterfaceManager)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("MyScript")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("MyScript")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tabs.Settings)

-- 6) เลือก Tab + แจ้งเตือน
Window:SelectTab(1)

Fluent:Notify({
    Title      = "My Script",
    Content    = "Loaded!",
    SubContent = "Press LeftCtrl to toggle",
    Duration   = 5,
})

-- 7) โหลด Config ที่บันทึกไว้
SaveManager:LoadAutoloadConfig()
```

---

### ทดสอบ Element ทุกชนิด

ดูไฟล์ตัวอย่างเต็มที่:

- **[FullFeatureExample.lua](https://github.com/thanyathonxyz/fluent/blob/main/FullFeatureExample.lua)** — ตัวอย่าง Element ทุกชนิด (16 ประเภท)
- **[Example.lua](https://github.com/thanyathonxyz/fluent/blob/main/Example.lua)** — ตัวอย่าง Sub-Tabs + Toggle Button

---

## Quick Reference

| Element | Method | มี Flag | Save/Load |
|---------|--------|---------|-----------|
| Toggle | `AddToggle(flag, config)` | Yes | Yes |
| Slider | `AddSlider(flag, config)` | Yes | Yes |
| Dropdown | `AddDropdown(flag, config)` | Yes | Yes |
| Input | `AddInput(flag, config)` | Yes | Yes |
| Keybind | `AddKeybind(flag, config)` | Yes | Yes |
| Colorpicker | `AddColorpicker(flag, config)` | Yes | Yes |
| Stepper | `AddStepper(flag, config)` | Yes | No |
| SelectionList | `AddSelectionList(flag, config)` | Yes | No |
| Button | `AddButton(config)` | No | No |
| Paragraph | `AddParagraph(config)` | No | No |
| Banner | `AddBanner(config)` | No | No |
| ButtonGroup | `AddButtonGroup(config)` | No | No |
| Sub-Tabs | `AddTabs(config)` | No | No |

---

## Fluent Library Methods

| Method | คำอธิบาย |
|--------|----------|
| `Fluent:CreateWindow(config)` | สร้าง Window |
| `Fluent:Notify(config)` | แสดงแจ้งเตือน |
| `Fluent:SetTheme(name)` | เปลี่ยนธีม |
| `Fluent:AddTheme(config)` | เพิ่มธีมใหม่ |
| `Fluent:ToggleAcrylic(bool)` | เปิด/ปิด Acrylic |
| `Fluent:ToggleTransparency(bool)` | เปิด/ปิดโปร่งใส |
| `Fluent:Destroy()` | ทำลาย UI ทั้งหมด |
| `Fluent.Options` | ตาราง element ทั้งหมด (อ้างอิงจาก Flag) |
4. รอฟาร์มเสร็จ auto replay!

### เล่น Raid
1. เข้า Raid
2. เปิด script  
3. เปิด **Raid Mode** ✅ (สำคัญ!)
4. เปิด **Auto Farm** ✅
5. Script จะรอนานขึ้นระหว่าง wave

### ขายของอัตโนมัติ
1. ไปที่ **Auto Sell** tab
2. เลือก rarity ที่ต้องการขาย
3. เปิด **Auto Sell** ✅
4. ของจะถูกขายอัตโนมัติ!

---

## 🔑 Hotkeys

| ปุ่ม | ฟังก์ชัน |
|------|----------|
| `Right Control` | ย่อ/ขยาย UI |

---

## 🌐 URLs

- **SpectreUI / Fluent**: `https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/dist/main.lua`
- **SaveManager**: `https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/SaveManager.lua`
- **InterfaceManager**: `https://raw.githubusercontent.com/thanyathonxyz/fluent/refs/heads/main/Addons/InterfaceManager.lua`
