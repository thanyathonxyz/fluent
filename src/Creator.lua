local Root = script.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)

local Creator = {
	Registry = {},
	Signals = {},
	TransparencyMotors = {},
	CurrentTheme = "Night", -- Default theme

	-- Pre-cached TweenInfos to avoid repeated allocation
	TweenInfos = {
		Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 14,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
	},
}

local function ApplyCustomProps(Object, Props)
	if Props.ThemeTag then
		Creator.AddThemeObject(Object, Props.ThemeTag)
	end
end

function Creator.AddSignal(Signal, Function)
	table.insert(Creator.Signals, Signal:Connect(Function))
end

function Creator.Disconnect()
	for Idx = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Idx)
		Connection:Disconnect()
	end
	-- Clean up transparency motors
	for Idx = #Creator.TransparencyMotors, 1, -1 do
		table.remove(Creator.TransparencyMotors, Idx)
	end
	-- Clean up theme registry
	table.clear(Creator.Registry)
end

function Creator.GetThemeProperty(Property)
	if type(Property) ~= "string" then return Property end
	if Themes[Creator.CurrentTheme] and Themes[Creator.CurrentTheme][Property] then
		return Themes[Creator.CurrentTheme][Property]
	end
	return Themes["Dark"][Property]
end

function Creator.UpdateTheme()
	-- Collect dead keys first to avoid mutating table during iteration
	local deadKeys = {}
	for Instance, Object in next, Creator.Registry do
		if not Instance or typeof(Instance) ~= "Instance" or not Instance.Parent then
			table.insert(deadKeys, Instance)
			continue
		end

		local alive = true
		for Property, ColorIdx in next, Object.Properties do
			local ThemeValue = Creator.GetThemeProperty(ColorIdx)
			if ThemeValue ~= nil then
				local ok = pcall(function()
					Instance[Property] = ThemeValue
				end)
				if not ok then
					alive = false
					break
				end
			end
		end
		if not alive then
			table.insert(deadKeys, Instance)
		end
	end
	for _, key in ipairs(deadKeys) do
		Creator.Registry[key] = nil
	end

	for _, Motor in next, Creator.TransparencyMotors do
		local Transparency = Creator.GetThemeProperty("ElementTransparency")
		if Transparency then
			Motor:setGoal(Flipper.Instant.new(Transparency))
		end
	end
end

function Creator.AddThemeObject(Object, Properties)
	local Data = {
		Object = Object,
		Properties = Properties,
	}

	Creator.Registry[Object] = Data
	-- Apply theme to this object only (avoid full UpdateTheme for each registration)
	for Property, ColorIdx in next, Properties do
		local ThemeValue = Creator.GetThemeProperty(ColorIdx)
		if ThemeValue ~= nil then
			pcall(function() Object[Property] = ThemeValue end)
		end
	end
	return Object
end

function Creator.OverrideTag(Object, Properties)
	if Creator.Registry[Object] then
		Creator.Registry[Object].Properties = Properties
		Creator.UpdateTheme()
	else
		Creator.AddThemeObject(Object, Properties)
	end
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	-- Default properties
	for PropName, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[PropName] = Value
	end

	-- Properties
	for PropName, Value in next, Properties or {} do
		if PropName ~= "ThemeTag" then
			Object[PropName] = Value
		end
	end

	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	ApplyCustomProps(Object, Properties)
	return Object
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
	IgnoreDialogCheck = IgnoreDialogCheck or false
	ResetOnThemeChange = ResetOnThemeChange or false
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		if typeof(Instance) == "Instance" and Instance.Parent then
			Instance[Prop] = value
		end
	end)

	if ResetOnThemeChange then
		table.insert(Creator.TransparencyMotors, Motor)
	end

	local function SetValue(Value, Ignore)
		Ignore = Ignore or false
		if not IgnoreDialogCheck then
			if not Ignore then
				if Prop == "BackgroundTransparency" and require(Root).DialogOpen then
					return
				end
			end
		end
		Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
	end

	return Motor, SetValue
end

return Creator
