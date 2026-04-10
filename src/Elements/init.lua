local Elements = {}

-- Standard Elements
table.insert(Elements, require(script:WaitForChild("Toggle")))
table.insert(Elements, require(script:WaitForChild("Slider")))
table.insert(Elements, require(script:WaitForChild("Dropdown")))
table.insert(Elements, require(script:WaitForChild("Colorpicker")))
table.insert(Elements, require(script:WaitForChild("Keybind")))
table.insert(Elements, require(script:WaitForChild("Input")))
table.insert(Elements, require(script:WaitForChild("Button")))
table.insert(Elements, require(script:WaitForChild("Paragraph")))
table.insert(Elements, require(script:WaitForChild("Banner")))
table.insert(Elements, require(script:WaitForChild("ButtonGroup")))

-- SpectreWare Premium Elements (Explicitly Loaded)
local Tabs = require(script:WaitForChild("Tabs"))
local Stepper = require(script:WaitForChild("Stepper"))
local SelectionList = require(script:WaitForChild("SelectionList"))

table.insert(Elements, Tabs)
table.insert(Elements, Stepper)
table.insert(Elements, SelectionList)

return Elements
