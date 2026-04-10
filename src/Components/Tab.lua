local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local New = Creator.New
local Spring = Flipper.Spring.new
local Instant = Flipper.Instant.new
local Components = Root.Components

local TabModule = {
	Window = nil,
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
	_switching = false, -- Debounce flag for tab switching
}

function TabModule:Init(Window)
	TabModule.Window = Window
	return TabModule
end

function TabModule:GetCurrentTabPos()
	local TabHolderPos = TabModule.Window.TabHolder.AbsolutePosition.Y
	local TabPos = TabModule.Tabs[TabModule.SelectedTab].Frame.AbsolutePosition.Y

	return TabPos - TabHolderPos
end

function TabModule:New(Title, Icon, Parent)
	local Window = TabModule.Window
	local Library = Window.Library
	local Elements = Window.Elements
    
    if not Elements then
        warn("SpectreWare: Tab creation failed to find Elements table. Ensure Window.Elements is set.")
    end

	TabModule.TabCount = TabModule.TabCount + 1
	local TabIndex = TabModule.TabCount

	local Tab = {
		Selected = false,
		Name = Title,
		Type = "Tab",
	}

	if Library:GetIcon(Icon) then
		Icon = Library:GetIcon(Icon)
	end

	if Icon == "" or Icon == nil then
		Icon = nil
	end

	Tab.IconLabel = New("ImageLabel", {
		Name = "Icon",
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 10, 0.5, 0),
		BackgroundTransparency = 1,
		Image = Icon and Icon or nil,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	Tab.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "Tab",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		New("Frame", {
			Name = "Glow",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = -1,
			ThemeTag = {
				BackgroundColor3 = "Accent",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
		New("TextLabel", {
			Name = "Label",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = Icon and UDim2.new(0, 32, 0.5, 0) or UDim2.new(0, 14, 0.5, 0),
			Text = Title,
			RichText = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = 0,
			FontFace = Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			),
			TextSize = 13,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Size = UDim2.new(1, -14, 1, 0),
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Text",
			},
		}),
        Tab.IconLabel
	})

	local ContainerLayout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	Tab.ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = Window.ContainerHolder,
		Visible = false,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		ContainerLayout,
		New("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 1),
			PaddingTop = UDim.new(0, 1),
			PaddingBottom = UDim.new(0, 1),
		}),
	})

	Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Tab.ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 2)
	end)

	Tab.Motor, Tab.SetTransparency = Creator.SpringMotor(0.96, Tab.Frame, "BackgroundTransparency")

    local Label = Tab.Frame.Label
    local IconLabel = Tab.IconLabel

	Tab.Update = function()
		local Selected = TabModule.SelectedTab == TabIndex
		Tab.Selected = Selected
		Tab.SetTransparency(Selected and 0.85 or 1) -- Slightly darker for better contrast
        
        -- Soft Glow 
        game:GetService("TweenService"):Create(Tab.Frame.Glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { 
            BackgroundTransparency = Selected and 0.9 or 1 
        }):Play()
        
        -- Magnetic Text Shift & Theme-Adaptive Visibility
        game:GetService("TweenService"):Create(Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { 
            Position = UDim2.new(0, Selected and (Icon and 38 or 20) or (Icon and 32 or 14), 0.5, 0),
            TextColor3 = Creator.GetThemeProperty("Text"), -- Adapt to theme
            TextTransparency = Selected and 0 or 0.45 
        }):Play()

        if IconLabel then
             game:GetService("TweenService"):Create(IconLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { 
                ImageColor3 = Creator.GetThemeProperty("Text"), -- Sync with Text Color (White/Black)
                ImageTransparency = Selected and 0 or 0.45
            }):Play()
        end
	end

	Creator.AddSignal(Tab.Frame.MouseEnter, function()
		Tab.SetTransparency(Tab.Selected and 0.85 or 0.93)
	end)
	Creator.AddSignal(Tab.Frame.MouseLeave, function()
		Tab.SetTransparency(Tab.Selected and 0.85 or 1)
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Down, function()
		Tab.SetTransparency(0.88)
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Up, function()
		Tab.SetTransparency(Tab.Selected and 0.85 or 0.93)
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	TabModule.Containers[TabIndex] = Tab.ContainerFrame
	TabModule.Tabs[TabIndex] = Tab

	Tab.Container = Tab.ContainerFrame
	Tab.ScrollFrame = Tab.Container
	Tab.TabIndex = TabIndex
	Tab.Elements = {} -- Track elements in this tab

	-- Register tab for Search
	table.insert(Library.AllTabs, {
		Type = "Tab",
		Name = Title,
		Title = Title,
		TabIndex = TabIndex,
		Frame = Tab.Frame,
	})

	function Tab:Select()
		TabModule:SelectTab(TabIndex)
	end
    
    -- Add alias to prevent common error
    Tab.SelectTab = Tab.Select

	setmetatable(Tab, Elements)
	return Tab
end

function TabModule:SelectTab(Tab)
	if TabModule._switching then return end -- Prevent race condition during animation
	if TabModule.SelectedTab == Tab then return end -- Skip if already selected
	
	local Window = TabModule.Window
	local TweenService = game:GetService("TweenService")

	TabModule.SelectedTab = Tab
	TabModule._switching = true

	for _, TabObject in next, TabModule.Tabs do
		TabObject.Update()
	end

	Window.TabDisplay.Text = TabModule.Tabs[Tab].Name
	Window.SelectorPosMotor:setGoal(Spring(TabModule:GetCurrentTabPos(), { frequency = 6 }))

	task.spawn(function()
		Window.ContainerHolder.Parent = Window.ContainerAnim
		
		-- Slide out + fade
		Window.ContainerPosMotor:setGoal(Spring(15, { frequency = 8 }))
		Window.ContainerBackMotor:setGoal(Spring(1, { frequency = 8 }))
		
		local SlideOut = TweenService:Create(
			Window.ContainerHolder,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, -20, 0, 0) }
		)
		SlideOut:Play()
		
		task.wait(0.12)
		
		for _, Container in next, TabModule.Containers do
			Container.Visible = false
		end
		TabModule.Containers[Tab].Visible = true
		
		-- Reset position, then slide in
		Window.ContainerHolder.Position = UDim2.new(0, 20, 0, 0)
		
		Window.ContainerPosMotor:setGoal(Spring(0, { frequency = 6 }))
		Window.ContainerBackMotor:setGoal(Spring(0, { frequency = 6 }))
		
		local SlideIn = TweenService:Create(
			Window.ContainerHolder,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, 0, 0, 0) }
		)
		SlideIn:Play()
		
		task.wait(0.15)
		Window.ContainerHolder.Parent = Window.ContainerCanvas
		TabModule._switching = false -- Release lock
	end)
end

return TabModule
