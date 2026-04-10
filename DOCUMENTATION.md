# Oxygenz Hub - Documentation

## 📦 Enhanced Fluent UI Features

### Smart Search (ช่องค้นหา)
พิมพ์ในช่อง **Search** เพื่อหาฟีเจอร์ได้ 3 แบบ:

| วิธีค้นหา | ตัวอย่าง | ผลลัพธ์ |
|-----------|----------|---------|
| **ตัวอักษรแรก** | `af` | **A**uto **F**arm |
| **ตรงเป๊ะ** | `raid` | Raid Mode |
| **เริ่มต้นคำ** | `sel` | Auto **Sel**l |

---

## ⚙️ Config Options

### Kill Aura Settings

| Config | ค่า Default | คำอธิบาย |
|--------|-------------|----------|
| `AttackDelay` | `0.25` | ดีเลย์ระหว่างการโจมตี (วินาที) |
| `AttackThreads` | `2` | จำนวน thread โจมตีพร้อมกัน |
| `FloatHeight` | `60` | ความสูงที่ลอยเหนือมอนสเตอร์ |
| `TweenSpeed` | `65` | ความเร็วในการบินไปหามอนสเตอร์ |
| `NoMobWaitTime` | `6` | รอกี่วินาทีก่อนกด Replay (Dungeon) |
| `RaidWaitTime` | `10` | รอกี่วินาทีก่อนกด Replay (Raid) |

### Boss Priority
บอสที่จะโจมตีก่อน (เรียงตามลำดับ):
```lua
BossPriority = {
    "Charybdis",
    "Scylla", 
    "Kraken",
    "Leviathan",
    "Hydra",
}
```

### Auto Sell Settings

| Config | ค่า Default | คำอธิบาย |
|--------|-------------|----------|
| `AutoSellInterval` | `5` | เช็คขายของทุกกี่วินาที |
| `SelectedRarities` | `{}` | Rarity ที่เลือกขาย |

---

## 🎮 Tabs

### 1. Main Tab
- **Auto Farm** - เปิดระบบฟาร์มอัตโนมัติ
- **Raid Mode** - เปิดเมื่อเล่น Raid (รอนานกว่าปกติระหว่าง wave)

### 2. Auto Sell Tab  
- **Select Rarities** - เลือก rarity ที่ต้องการขาย
- **Auto Sell** - เปิดขายของอัตโนมัติ

### 3. Settings Tab
- **Theme** - เปลี่ยนธีมสี
- **Minimize Key** - ปุ่มย่อ UI
- **Config** - Save/Load การตั้งค่า

---

## 🔧 การปรับแต่ง Config

แก้ไขค่าใน script ได้ที่ส่วน `Config`:

```lua
local Config = {
    -- ปรับความเร็วโจมตี (ยิ่งน้อย ยิ่งเร็ว)
    AttackDelay = 0.25,
    
    -- เพิ่ม/ลด thread โจมตี
    AttackThreads = 2,
    
    -- ความสูงที่ลอย
    FloatHeight = 60,
    
    -- ความเร็วบิน
    TweenSpeed = 65,
    
    -- รอกี่วินาทีก่อน replay (Dungeon ปกติ)
    NoMobWaitTime = 6,
    
    -- รอกี่วินาทีก่อน replay (Raid)
    RaidWaitTime = 10,
}
```

---

## 📝 ตัวอย่างการใช้งาน

### เล่น Dungeon ปกติ
1. เข้า Dungeon
2. เปิด script
3. เปิด **Auto Farm** ✅
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

- **Enhanced Fluent UI**: `https://raw.githubusercontent.com/tigerprettyboi/enchanted-gui/main/main.lua`
- **SaveManager**: `https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua`
- **InterfaceManager**: `https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua`
