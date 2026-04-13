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

	-- Favorites / Pins
	Favorites = {},
	_favoritesContainer = nil,

	-- Tab transition style: "slide", "fade", "scale"
	TransitionStyle = "slide",

	-- Accent gradient
	AccentGradient = nil,
	AccentGradientRotation = nil,
	_gradientObjects = {},
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
    			local result = ElementComponent:New(Idx, Config)

    			-- Attach favorite pin button
    			if result and result.Frame and type(Idx) == "string" and Idx ~= "" then
    				Library:_attachPinButton(result, Idx)
    			end

    			return result
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
		ToggleButton = Config.ToggleButton,
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

-- =============================================
-- CHANGELOG POPUP
-- =============================================
function Library:Changelog(Config)
	Config = Config or {}
	Config.Title = Config.Title or "What's New"
	Config.Version = Config.Version or "1.0.0"
	Config.Items = Config.Items or {}

	-- OnlyOnce: only show once per version
	if Config.OnlyOnce ~= false then
		local folder = "FluentSettings"
		local key = Config.Key or "changelog"
		local path = folder .. "/" .. key .. "_version.txt"
		local ok, exists = pcall(isfile, path)
		if ok and exists then
			local readOk, ver = pcall(readfile, path)
			if readOk and ver == Config.Version then return end
		end
		pcall(function()
			local ok2, e2 = pcall(isfolder, folder)
			if ok2 and not e2 then pcall(makefolder, folder) end
		end)
		pcall(writefile, path, Config.Version)
	end

	if not Library.Window then return end
	local Window = Library.Window

	Library.DialogOpen = true

	-- Tint overlay
	local TintFrame = New("TextButton", {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Parent = Window.Root,
	})

	local _, TintSet = Creator.SpringMotor(1, TintFrame, "BackgroundTransparency", true)

	local DialogWidth = math.min(420, Window.Size.X.Offset - 80)
	local DialogHeight = math.min(360, Window.Size.Y.Offset - 60)

	local Scale = New("UIScale", { Scale = 1.1 })
	local _, ScaleSet = Creator.SpringMotor(1.1, Scale, "Scale")

	-- Type colors & labels
	local typeColors = {
		added = Color3.fromRGB(76, 191, 118),
		fixed = Color3.fromRGB(96, 165, 250),
		removed = Color3.fromRGB(248, 113, 113),
		changed = Color3.fromRGB(251, 191, 36),
		improved = Color3.fromRGB(192, 132, 252),
	}
	local typeLabels = {
		added = "NEW", fixed = "FIX", removed = "DEL",
		changed = "CHG", improved = "IMP",
	}

	-- Scrollable items container
	local ItemsLayout = New("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local ItemsHolder = New("ScrollingFrame", {
		Size = UDim2.new(1, -30, 1, -115),
		Position = UDim2.fromOffset(15, 68),
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 0.5,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
	}, {
		ItemsLayout,
		New("UIPadding", { PaddingRight = UDim.new(0, 8) }),
	})

	-- Populate items
	for i, item in ipairs(Config.Items) do
		local itemType = "added"
		local itemText = ""

		if type(item) == "table" then
			itemType = item.Type or "added"
			itemText = item.Text or ""
		else
			itemText = tostring(item)
		end

		local badgeColor = typeColors[itemType] or typeColors.added
		local badgeText = typeLabels[itemType] or "NEW"

		New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 0.92,
			Parent = ItemsHolder,
			LayoutOrder = i,
			ThemeTag = { BackgroundColor3 = "Element" },
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 5) }),
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 7),
				PaddingBottom = UDim.new(0, 7),
			}),
			New("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, {
				New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 8),
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				New("Frame", {
					Size = UDim2.fromOffset(36, 16),
					BackgroundColor3 = badgeColor,
					LayoutOrder = 1,
				}, {
					New("UICorner", { CornerRadius = UDim.new(0, 3) }),
					New("TextLabel", {
						Size = UDim2.fromScale(1, 1),
						Text = badgeText,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 9,
						FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
						BackgroundTransparency = 1,
					}),
				}),
				New("TextLabel", {
					Size = UDim2.new(1, -44, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Text = itemText,
					TextSize = 12,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					ThemeTag = { TextColor3 = "Text" },
				}),
			}),
		})
	end

	-- Auto-size canvas
	Creator.AddSignal(ItemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		ItemsHolder.CanvasSize = UDim2.new(0, 0, 0, ItemsLayout.AbsoluteContentSize.Y + 4)
	end)
	ItemsHolder.CanvasSize = UDim2.new(0, 0, 0, ItemsLayout.AbsoluteContentSize.Y + 4)

	-- Version badge
	local VersionBadge = New("Frame", {
		Size = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.fromOffset(15, 42),
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 4) }),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}),
		New("TextLabel", {
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "v" .. Config.Version,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
			BackgroundTransparency = 1,
		}),
	})

	-- Close button area
	local CloseBtn = New("TextButton", {
		Size = UDim2.new(1, -30, 0, 32),
		Position = UDim2.new(0.5, 0, 0.5, 2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "Got it!",
		TextSize = 13,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		ThemeTag = {
			BackgroundColor3 = "DialogButton",
			TextColor3 = "Text",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", {
			Transparency = 0.5,
			ThemeTag = { Color = "DialogButtonBorder" },
		}),
	})

	local CloseHolder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.new(0, 0, 1, -50),
		BackgroundTransparency = 1,
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			ThemeTag = { BackgroundColor3 = "DialogHolderLine" },
		}),
		CloseBtn,
	})

	-- Dialog root
	local DialogRoot = New("CanvasGroup", {
		Size = UDim2.fromOffset(DialogWidth, DialogHeight),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		GroupTransparency = 1,
		Parent = TintFrame,
		ThemeTag = { BackgroundColor3 = "Dialog" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", {
			Transparency = 0.5,
			ThemeTag = { Color = "DialogBorder" },
		}),
		Scale,
		New("TextLabel", {
			Position = UDim2.fromOffset(15, 14),
			Size = UDim2.new(1, -30, 0, 22),
			Text = Config.Title,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			BackgroundTransparency = 1,
			ThemeTag = { TextColor3 = "Text" },
		}),
		VersionBadge,
		ItemsHolder,
		CloseHolder,
	})

	local _, RootSet = Creator.SpringMotor(1, DialogRoot, "GroupTransparency", true)

	-- Open animation
	TintSet(0.75)
	RootSet(0)
	ScaleSet(1)

	-- Close handler
	local closing = false
	local function CloseChangelog()
		if closing then return end
		closing = true
		Library.DialogOpen = false
		TintSet(1)
		RootSet(1)
		ScaleSet(1.1)
		task.delay(0.25, function()
			pcall(function() TintFrame:Destroy() end)
		end)
	end

	Creator.AddSignal(CloseBtn.MouseButton1Click, CloseChangelog)
end

-- =============================================
-- FAVORITES / PINS SYSTEM
-- =============================================
-- Hash set for O(1) lookup
local _favoritesSet = {}
local function _rebuildFavoritesSet()
	_favoritesSet = {}
	for _, v in ipairs(Library.Favorites) do
		_favoritesSet[v] = true
	end
end

function Library:IsFavorite(idx)
	return _favoritesSet[idx] == true
end

function Library:ToggleFavorite(idx)
	if Library:IsFavorite(idx) then
		_favoritesSet[idx] = nil
		for i, v in ipairs(Library.Favorites) do
			if v == idx then
				table.remove(Library.Favorites, i)
				break
			end
		end
	else
		table.insert(Library.Favorites, idx)
		_favoritesSet[idx] = true
	end
	Library:SaveFavorites()
	Library:_rebuildFavoritesUI()
end

function Library:SaveFavorites()
	pcall(function()
		local folder = "FluentSettings"
		local ok, exists = pcall(isfolder, folder)
		if ok and not exists then pcall(makefolder, folder) end
		local httpService = game:GetService("HttpService")
		writefile(folder .. "/favorites.json", httpService:JSONEncode(Library.Favorites))
	end)
end

function Library:LoadFavorites()
	pcall(function()
		local folder = "FluentSettings"
		local path = folder .. "/favorites.json"
		local ok, exists = pcall(isfile, path)
		if ok and exists then
			local httpService = game:GetService("HttpService")
			local readOk, content = pcall(readfile, path)
			if readOk then
				local decodeOk, data = pcall(httpService.JSONDecode, httpService, content)
				if decodeOk and type(data) == "table" then
					Library.Favorites = data
					_rebuildFavoritesSet()
				end
			end
		end
	end)
end

function Library:_attachPinButton(element, idx)
	if not element.Frame then return end

	local isPinned = Library:IsFavorite(idx)
	local _pinTween -- Track active tween to cancel overlap

	local PinBtn = New("TextButton", {
		Text = isPinned and "\226\152\133" or "\226\152\134",
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -6, 0, 6),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		TextSize = 14,
		TextColor3 = isPinned and Creator.GetThemeProperty("Accent") or Color3.fromRGB(120, 120, 120),
		TextTransparency = isPinned and 0 or 0.6,
		ZIndex = 5,
		Parent = element.Frame,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
	})

	element.PinButton = PinBtn

	Creator.AddSignal(PinBtn.MouseButton1Click, function()
		Library:ToggleFavorite(idx)
		local pinned = Library:IsFavorite(idx)
		PinBtn.Text = pinned and "\226\152\133" or "\226\152\134"
		if _pinTween then _pinTween:Cancel() end
		_pinTween = TweenService:Create(PinBtn, TweenInfo.new(0.2), {
			TextColor3 = pinned and Creator.GetThemeProperty("Accent") or Color3.fromRGB(120, 120, 120),
			TextTransparency = pinned and 0 or 0.6,
		})
		_pinTween:Play()
	end)

	Creator.AddSignal(element.Frame.MouseEnter, function()
		if not Library:IsFavorite(idx) then
			if _pinTween then _pinTween:Cancel() end
			_pinTween = TweenService:Create(PinBtn, TweenInfo.new(0.15), { TextTransparency = 0.3 })
			_pinTween:Play()
		end
	end)
	Creator.AddSignal(element.Frame.MouseLeave, function()
		if not Library:IsFavorite(idx) then
			if _pinTween then _pinTween:Cancel() end
			_pinTween = TweenService:Create(PinBtn, TweenInfo.new(0.15), { TextTransparency = 0.6 })
			_pinTween:Play()
		end
	end)
end

function Library:BuildFavoritesSection(tab)
	local section = tab:AddSection({ Title = "Favorites", Opened = true })
	Library._favoritesContainer = section.Container
	Library:LoadFavorites()
	Library:_rebuildFavoritesUI()
	return section
end

function Library:_rebuildFavoritesUI()
	if not Library._favoritesContainer then return end
	local container = Library._favoritesContainer

	-- Remove old favorite cards
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject") and child:GetAttribute("IsFavoriteCard") then
			child:Destroy()
		end
	end

	if #Library.Favorites == 0 then
		local emptyLabel = New("TextLabel", {
			Size = UDim2.new(1, 0, 0, 40),
			Text = "No pinned elements yet.\nClick the star on any element to pin it.",
			TextSize = 12,
			TextWrapped = true,
			BackgroundTransparency = 1,
			Parent = container,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			ThemeTag = { TextColor3 = "SubText" },
		})
		emptyLabel:SetAttribute("IsFavoriteCard", true)
		return
	end

	for _, idx in ipairs(Library.Favorites) do
		local info = nil
		for _, el in ipairs(Library.AllElements) do
			if el.Title == idx or el.Name == idx then
				info = el
				break
			end
		end

		if info then
			local tabName = "Unknown"
			for _, t in ipairs(Library.AllTabs) do
				if t.TabIndex == info.TabIndex then
					tabName = t.Name
					break
				end
			end

			local card = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 38),
				AutoButtonColor = false,
				Parent = container,
				ThemeTag = { BackgroundColor3 = "Element", BackgroundTransparency = "ElementTransparency" },
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 6) }),
				New("UIStroke", {
					Transparency = 0.55,
					ThemeTag = { Color = "ElementBorder" },
				}),
				New("TextLabel", {
					Size = UDim2.fromOffset(20, 38),
					Position = UDim2.fromOffset(10, 0),
					Text = "\226\152\133",
					TextSize = 13,
					BackgroundTransparency = 1,
					ThemeTag = { TextColor3 = "Accent" },
				}),
				New("TextLabel", {
					Size = UDim2.new(1, -70, 0, 14),
					Position = UDim2.new(0, 32, 0, 5),
					Text = info.Title or idx,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					ThemeTag = { TextColor3 = "Text" },
				}),
				New("TextLabel", {
					Size = UDim2.new(1, -70, 0, 12),
					Position = UDim2.new(0, 32, 0, 21),
					Text = tabName .. " \194\183 " .. (info.ElementType or ""),
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					ThemeTag = { TextColor3 = "SubText" },
				}),
				New("TextLabel", {
					Size = UDim2.fromOffset(16, 38),
					Position = UDim2.new(1, -24, 0, 0),
					Text = "\226\134\146",
					TextSize = 14,
					BackgroundTransparency = 1,
					ThemeTag = { TextColor3 = "SubText" },
				}),
			})
			card:SetAttribute("IsFavoriteCard", true)

			Creator.AddSignal(card.MouseButton1Click, function()
				if Library.Window then
					Library.Window:SelectTab(info.TabIndex)
				end
				task.wait(0.3)
				if info.Frame and info.Frame.Parent and info.Frame.Parent:IsA("ScrollingFrame") then
					local sf = info.Frame.Parent
					sf.CanvasPosition = Vector2.new(0,
						math.max(0, info.Frame.AbsolutePosition.Y - sf.AbsolutePosition.Y + sf.CanvasPosition.Y - 5)
					)
				end
			end)

			-- Hover effect
			Creator.AddSignal(card.MouseEnter, function()
				TweenService:Create(card, TweenInfo.new(0.15), {
					BackgroundTransparency = (Creator.GetThemeProperty("ElementTransparency") or 0.82) - 0.08,
				}):Play()
			end)
			Creator.AddSignal(card.MouseLeave, function()
				TweenService:Create(card, TweenInfo.new(0.15), {
					BackgroundTransparency = Creator.GetThemeProperty("ElementTransparency") or 0.82,
				}):Play()
			end)
		end
	end
end

-- =============================================
-- GRADIENT ACCENT
-- =============================================
function Library:SetAccentGradient(GradientColors, Rotation)
	Library.AccentGradient = GradientColors
	Library.AccentGradientRotation = Rotation or 45

	-- Apply to all registered accent elements
	for Instance, Data in next, Creator.Registry do
		if typeof(Instance) == "Instance" and Data.Properties then
			if Data.Properties.BackgroundColor3 == "Accent" or Data.Properties.ImageColor3 == "Accent" then
				local existing = Instance:FindFirstChildOfClass("UIGradient")
				if existing then existing:Destroy() end

				if GradientColors then
					local grad = New("UIGradient", {
						Color = GradientColors,
						Rotation = Rotation or 45,
						Parent = Instance,
					})
					table.insert(Library._gradientObjects, grad)
				end
			end
		end
	end
end

function Library:ClearAccentGradient()
	Library.AccentGradient = nil
	Library.AccentGradientRotation = nil
	for _, grad in ipairs(Library._gradientObjects) do
		pcall(function() grad:Destroy() end)
	end
	Library._gradientObjects = {}
end

if getgenv then
	getgenv().Fluent = Library
end

return Library
