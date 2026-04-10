local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

local Tabs = {}
Tabs.__index = Tabs
Tabs.__type = "Tabs"

function Tabs:New(Idx, Config)
    if not Config and type(Idx) == "table" then
        Config = Idx
        Idx = nil
    end

	local Library = self.Library
	
	local TabSelector = {
		Current = Config.Default or 1,
		Buttons = {},
		Containers = {},
		Handlers = {}
	}
	
	-- Main Strip with better spacing to avoid "overflowing" look
	local Strip = New("ScrollingFrame", {
		Name = "SubTabsStrip",
		Size = UDim2.new(1, 0, 0, 48), -- Slightly taller for better padding
		BackgroundTransparency = 1,
		Parent = self.Container,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		BorderSizePixel = 0,
        LayoutOrder = -1
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 10), -- More spacing between tabs
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 2), -- Add space from title
			PaddingBottom = UDim.new(0, 8), -- Add space to content below
		})
	})

	local titlesList = Config.Titles or (type(Config[1]) == "table" or type(Config[1]) == "string") and Config or {"Tab 1", "Tab 2"}
	local TweenService = game:GetService("TweenService")

	local function setParentScroll(enabled)
		local p = Strip.Parent
		while p do
			if p:IsA("ScrollingFrame") then
				p.ScrollingEnabled = enabled
				break
			end
			p = p.Parent
		end
	end
	Creator.AddSignal(Strip.MouseEnter, function() setParentScroll(false) end)
	Creator.AddSignal(Strip.MouseLeave, function() setParentScroll(true) end)

    local function performSwitch(newIndex, title)
        if TabSelector.Current == newIndex and TabSelector.Containers[title].Visible then return end
        
        local oldTitle = nil
        for t, idx in pairs(TabSelector.Handlers) do
            if idx == TabSelector.Current then oldTitle = t break end
        end
        
        TabSelector.Current = newIndex
        
        for t, btn in pairs(TabSelector.Buttons) do
            local isSelected = (t == title)
            local btnConfig = nil
            for _, v in ipairs(titlesList) do
                if (type(v) == "table" and v.Title or v) == t then btnConfig = v break end
            end
            local customColor = type(btnConfig) == "table" and btnConfig.Color or nil

            Creator.OverrideTag(btn, {
                BackgroundColor3 = isSelected and "Black" or "Element",
                TextColor3 = (not customColor) and (isSelected and "Text" or "SubText") or nil
            })
            
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundTransparency = isSelected and 0.75 or 0.95 -- Much more solid like the Settings toggles
            }):Play()
            
            local inner = btn:FindFirstChildOfClass("Frame")
            if inner then
                local label = inner:FindFirstChildOfClass("TextLabel")
                local icon = inner:FindFirstChildOfClass("ImageLabel")
                if label then
                    label.TextColor3 = isSelected and (customColor or Creator.GetThemeProperty("Text")) or Creator.GetThemeProperty("SubText")
                    label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", isSelected and Enum.FontWeight.Bold or Enum.FontWeight.SemiBold)
                    Creator.OverrideTag(label, { TextColor3 = (not customColor) and (isSelected and "Text" or "SubText") or nil })
                end
                if icon then
                    icon.ImageColor3 = isSelected and (customColor or Creator.GetThemeProperty("Text")) or Creator.GetThemeProperty("SubText")
                    Creator.OverrideTag(icon, { ImageColor3 = (not customColor) and (isSelected and "Text" or "SubText") or nil })
                end
            end

            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then
                Creator.OverrideTag(stroke, { Color = (not customColor) and (isSelected and "Accent" or "ElementBorder") or nil })
                if customColor then stroke.Color = isSelected and customColor or Creator.GetThemeProperty("ElementBorder") end
                stroke.Transparency = isSelected and 0.45 or 0.85 -- Stronger border to match the premium "Box" look
            end
        end

        task.spawn(function()
            local oldContainer = oldTitle and TabSelector.Containers[oldTitle]
            local newContainer = TabSelector.Containers[title]

            if oldContainer then
                local fadeOut = TweenService:Create(oldContainer, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
                fadeOut:Play()
                fadeOut.Completed:Wait()
                oldContainer.Visible = false
            end
            
            newContainer.GroupTransparency = 1
            newContainer.Position = UDim2.fromOffset(10, 0)
            newContainer.Visible = true
            
            TweenService:Create(newContainer, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
                GroupTransparency = 0, 
                Position = UDim2.fromOffset(0, 0) 
            }):Play()
        end)
    end

	for i, TitleObj in ipairs(titlesList) do
		local Title = type(TitleObj) == "table" and TitleObj.Title or TitleObj
		local Icon = type(TitleObj) == "table" and TitleObj.Icon or nil
		local CustomColor = type(TitleObj) == "table" and TitleObj.Color or nil
		
		if Icon and Library:GetIcon(Icon) then
			Icon = Library:GetIcon(Icon)
		end

		local Button = New("TextButton", {
			Name = "SubTab_" .. Title,
			Size = UDim2.fromOffset(0, 32), -- Slightly more compact like the toggles
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Color3.fromRGB(30, 30, 40),
			BackgroundTransparency = (i == TabSelector.Current) and 0.75 or 1.0,
			TextColor3 = (i == TabSelector.Current) and (CustomColor or Color3.fromRGB(240, 240, 240)) or Color3.fromRGB(160, 160, 170),
			Text = "",
			Parent = Strip,
			ThemeTag = {
				BackgroundColor3 = (i == TabSelector.Current) and "Black" or "Element",
				TextColor3 = (not CustomColor) and ((i == TabSelector.Current) and "Text" or "SubText") or nil
			}
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }), -- Use 6px, same as Settings Elements
			New("UIStroke", {
				Transparency = (i == TabSelector.Current) and 0.45 or 0.85,
				Thickness = 1,
				Color = (i == TabSelector.Current) and (CustomColor or Color3.fromRGB(80, 110, 180)) or Color3.fromRGB(60, 60, 70),
				ThemeTag = { Color = (not CustomColor) and ((i == TabSelector.Current) and "Accent" or "ElementBorder") or nil }
			}),
			New("UIPadding", { PaddingRight = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14) }),
			New("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 6),
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Icon and New("ImageLabel", {
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					Image = Icon,
					ImageColor3 = (i == TabSelector.Current) and (CustomColor or Creator.GetThemeProperty("Text")) or Creator.GetThemeProperty("SubText"),
					ThemeTag = { ImageColor3 = (not CustomColor) and ((i == TabSelector.Current) and "Text" or "SubText") or nil }
				}) or nil,
				New("TextLabel", {
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Text = Title,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", (i == TabSelector.Current) and Enum.FontWeight.Bold or Enum.FontWeight.SemiBold),
					TextSize = 13,
					TextColor3 = (i == TabSelector.Current) and (CustomColor or Creator.GetThemeProperty("Text")) or Creator.GetThemeProperty("SubText"),
					ThemeTag = { TextColor3 = (not CustomColor) and ((i == TabSelector.Current) and "Text" or "SubText") or nil }
				})
			})
		})

		local SubContainer = New("CanvasGroup", {
			Name = "SubContainer_" .. Title,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			GroupTransparency = (i == TabSelector.Current) and 0 or 1,
			Visible = (i == TabSelector.Current),
			Parent = self.Container
		}, {
			New("UIListLayout", { 
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 1),
                PaddingBottom = UDim.new(0, 1),
            })
		})

		TabSelector.Buttons[Title] = Button
		TabSelector.Containers[Title] = SubContainer
        TabSelector.Handlers[Title] = i

		Creator.AddSignal(Button.MouseEnter, function()
			if TabSelector.Current ~= i then
				TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.85 }):Play()
			end
		end)
		Creator.AddSignal(Button.MouseLeave, function()
			if TabSelector.Current ~= i then
				TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 1.0 }):Play()
			else
                TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.75 }):Play()
            end
		end)
		Creator.AddSignal(Button.MouseButton1Click, function()
			performSwitch(i, Title)
		end)
	end

	local Interface = { Tabs = {} }
	local ElementsTable = Library.Elements
	
	for _, TitleObj in ipairs(titlesList) do
		local Title = type(TitleObj) == "table" and TitleObj.Title or TitleObj
		local SubContainer = TabSelector.Containers[Title]
		Interface.Tabs[Title] = {
			Container = SubContainer,
			Type = self.Type,
			ScrollFrame = self.ScrollFrame,
			TabIndex = self.TabIndex,
			Library = Library,
			Select = function()
				performSwitch(TabSelector.Handlers[Title], Title)
			end
		}
		setmetatable(Interface.Tabs[Title], ElementsTable)
	end
	
	return setmetatable(Interface, {
        __index = function(_, key)
            return Interface.Tabs[key]
        end
    })
end

return Tabs
