local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = game:GetService("Workspace").CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Root = script
local Creator = require(Root.Creator)
local ElementsTable = require(Root.Elements)
local Acrylic = require(Root.Acrylic)
local Components = Root.Components
local NotificationModule = require(Components.Notification)

local New = Creator.New

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUI = New("ScreenGui", {
	Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
})
ProtectGui(GUI)
NotificationModule:Init(GUI)

local Library = {
	Version = "1.2.0",

	OpenFrames = {},
	Options = {},
	Themes = require(Root.Themes).Names,

	Window = nil,
	WindowFrame = nil,
	Unloaded = false,

	Theme = "Night",
	DialogOpen = false,
	UseAcrylic = false,
	Acrylic = false,
	Transparency = true,
	MinimizeKeybind = nil,
	MinimizeKey = Enum.KeyCode.LeftControl,

	GUI = GUI,
	
	-- Search feature
	AllElements = {},
	AllTabs = {},
	SearchBarWidth = 180, -- Default search bar width (can be changed)
}

function Library:SafeCallback(Function, ...)
	if not Function then
		return
	end

	local Success, Event = pcall(Function, ...)
	if not Success then
		local _, i = Event:find(":%d+: ")

		if not i then
			return Library:Notify({
				Title = "Interface",
				Content = "Callback error",
				SubContent = Event,
				Duration = 5,
			})
		end

		return Library:Notify({
			Title = "Interface",
			Content = "Callback error",
			SubContent = Event:sub(i + 1),
			Duration = 5,
		})
	end
end

function Library:Round(Number, Factor)
	if Factor == 0 then
		return math.floor(Number)
	end
	Number = tostring(Number)
	return Number:find("%.") and tonumber(Number:sub(1, Number:find("%.") + Factor)) or Number
end

local Icons = require(Root.Icons).assets
function Library:GetIcon(Name)
	if Name ~= nil and Icons["lucide-" .. Name] then
		return Icons["lucide-" .. Name]
	end
	return nil
end

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
	return Elements[Key](...)
end

    for _, ElementComponent in pairs(ElementsTable) do
    	local typeName = ElementComponent.__type
    	if typeName then
    		Elements["Add" .. typeName] = function(self, Idx, Config)
    			ElementComponent.Container = self.Container
    			ElementComponent.Type = self.Type
    			ElementComponent.ScrollFrame = self.ScrollFrame
    			ElementComponent.Library = Library
    			ElementComponent.TabIndex = self.TabIndex
    			return ElementComponent:New(Idx, Config)
    		end
    	end
    end

function Elements:AddSection(TitleOrConfig)
	local Section = require(Components.Section)(TitleOrConfig, self.Container)
	setmetatable(Section, Elements)
	return Section
end

-- Convenience aliases (WindUI-compatible API)
-- Allows: Section:Toggle({Flag="x", Title="...", ...}) instead of Section:AddToggle("x", {...})
-- Allows: Tab:Section({Title="x", Opened=true}) instead of Tab:AddSection({Title="x", Opened=true})
Elements.Section = Elements.AddSection

-- Elements that don't use Idx (they only take Config)
local NoIdxElements = { Button = true, Paragraph = true, Banner = true, ButtonGroup = true }

local function MakeShorthand(MethodName)
	if NoIdxElements[MethodName] then
		-- These elements don't take Idx, just Config
		Elements[MethodName] = function(self, Config)
			return Elements["Add" .. MethodName](self, Config)
		end
	else
		-- These elements take (Idx, Config) - use Flag or Title as Idx
		Elements[MethodName] = function(self, Config)
			local Idx = Config.Flag or Config.Title or ""
			return Elements["Add" .. MethodName](self, Idx, Config)
		end
	end
end

for _, name in pairs({"Toggle", "Slider", "Dropdown", "Input", "Keybind", "Colorpicker", "Button", "Paragraph", "Banner", "ButtonGroup", "SelectionList", "Stepper", "Tabs"}) do
	if not Elements[name] then
		MakeShorthand(name)
	end
end

Library.Elements = Elements

function Library:CreateWindow(Config)
	assert(Config.Title, "Window - Missing Title")

	if Library.Window then
		print("You cannot create more than one window.")
		return
	end

	Library.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.LeftControl
	Library.UseAcrylic = Config.Acrylic or false
	Library.Acrylic = Config.Acrylic or false
	Library.Theme = Config.Theme or "Night"
	Creator.CurrentTheme = Library.Theme
	
	if Config.Acrylic then
		Acrylic.init()
	end

	local Window = require(Components.Window)({
		Title = Config.Title or "Fluent",
		SubTitle = Config.SubTitle or "by dawid",
		Icon = Config.Icon or nil,
		Author = Config.Author or nil,
		TabWidth = Config.TabWidth or 160,
		Size = Config.Size or UDim2.fromOffset(580, 460),
		Parent = GUI,
	})
    
    -- Link Library and Elements to Window
    Window.Library = Library
    Window.Elements = Elements
    
	Library.Window = Window
	Library:SetTheme(Config.Theme)

	return Window
end

function Library:SetTheme(Value)
	if Library.Window and table.find(Library.Themes, Value) then
		Library.Theme = Value
		Creator.CurrentTheme = Value
		Creator.UpdateTheme()
	end
end

function Library:AddTheme(ThemeData)
	assert(ThemeData.Name, "AddTheme - Missing Name")
	-- Use Dark theme as base, merge provided colors on top
	local Base = require(Root.Themes)["Dark"]
	local NewTheme = {}
	for k, v in pairs(Base) do
		NewTheme[k] = v
	end
	for k, v in pairs(ThemeData) do
		NewTheme[k] = v
	end
	-- Register into the themes table used by Creator
	local ThemesTable = require(Root.Themes)
	ThemesTable[ThemeData.Name] = NewTheme
	if not table.find(ThemesTable.Names, ThemeData.Name) then
		table.insert(ThemesTable.Names, ThemeData.Name)
	end
	-- Update Library.Themes reference
	Library.Themes = ThemesTable.Names
end

function Library:Destroy()
	if Library.Window then
		Library.Unloaded = true
		if Library.UseAcrylic then
			Library.Window.AcrylicPaint.Model:Destroy()
		end
		Creator.Disconnect()
		Library.GUI:Destroy()
	end
end

function Library:ToggleAcrylic(Value)
	if Library.Window then
		if Library.UseAcrylic then
			Library.Acrylic = Value
			Library.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
			if Value then
				Acrylic.Enable()
			else
				Acrylic.Disable()
			end
		end
	end
end

function Library:ToggleTransparency(Value)
	if Library.Window then
		Library.Window:ToggleTransparency(Value)
	end
end

function Library:Notify(Config)
	return NotificationModule:New(Config)
end

if getgenv then
	getgenv().Fluent = Library
end

return Library
