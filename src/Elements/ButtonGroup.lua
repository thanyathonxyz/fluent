local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

local ButtonGroup = {}
ButtonGroup.__index = ButtonGroup
ButtonGroup.__type = "ButtonGroup"

function ButtonGroup:New(Config)
	local Library = self.Library
	local Group = {
		Buttons = {},
		Selected = {}
	}
	
	local Frame = New("Frame", {
		Name = "ButtonGroup_" .. (Config.Title or "Unnamed"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ButtonGroup.Container,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 5) }),
		New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }),
		New("TextLabel", {
			Name = "Title",
			Text = Config.Title or "Select Options",
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
			ThemeTag = { TextColor3 = "Text" }
		}),
		New("TextLabel", {
			Name = "Description",
			Text = Config.Description or "",
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			Visible = (Config.Description ~= nil and Config.Description ~= ""),
			ThemeTag = { TextColor3 = "SubText" }
		}),
		New("Frame", {
			Name = "ButtonHolder",
			Size = UDim2.new(1, 0, 0, 45),
			BackgroundTransparency = 1,
		}, {
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 12),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			})
		})
	})
	
	local holder = Frame:FindFirstChild("ButtonHolder")

	for _, Name in ipairs(Config.Buttons or {}) do
		local btn = New("TextButton", {
			Name = "Circle_" .. Name,
			Size = UDim2.fromOffset(34, 34), -- Slightly smaller for elegance
			BackgroundColor3 = Color3.fromRGB(35, 40, 50),
			BackgroundTransparency = 0.6,
			TextColor3 = Color3.fromRGB(160, 160, 160),
			Text = Name,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
			TextSize = 13,
			Parent = holder,
			ThemeTag = {
				BackgroundColor3 = "Element",
				TextColor3 = "SubText"
			}
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			New("UIStroke", {
				Color = Color3.fromRGB(0, 120, 215),
				Transparency = 0.7,
				Thickness = 1.5,
				ThemeTag = { Color = "Accent" }
			})
		})
		
		btn.MouseButton1Click:Connect(function()
			Group.Selected[Name] = not Group.Selected[Name]
			
			-- Visual state
			local isSelected = Group.Selected[Name]
			local stroke = btn:FindFirstChildOfClass("UIStroke")
			
			if isSelected then
				Creator.OverrideTag(btn, {
					BackgroundColor3 = "Accent",
					TextColor3 = "Text"
				})
				btn.BackgroundTransparency = 0.4
				if stroke then stroke.Transparency = 0.1 end
			else
				Creator.OverrideTag(btn, {
					BackgroundColor3 = "Element",
					TextColor3 = "SubText"
				})
				btn.BackgroundTransparency = 0.6
				if stroke then stroke.Transparency = 0.7 end
			end
			
			if Config.Callback then
				Library:SafeCallback(Config.Callback, Group.Selected)
			end
		end)
		
		Group.Buttons[Name] = btn
	end

	Group.Frame = Frame
	table.insert(Library.AllElements, {
		Type = "Element",
		ElementType = "ButtonGroup",
		Name = Config.Title or "ButtonGroup",
		Title = Config.Title or "ButtonGroup",
		Description = Config.Description or "",
		TabIndex = ButtonGroup.TabIndex,
		Frame = Frame,
	})

	return Group
end

return ButtonGroup
