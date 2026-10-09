local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "SelectionList"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "SelectionList - Missing Title")
	assert(Config.Values, "SelectionList - Missing Values")

	local initialSelected = {}
	if type(Config.Default) == "table" then
		for _, v in ipairs(Config.Default) do
			table.insert(initialSelected, v)
		end
	end

	local SelectionList = {
		Values = Config.Values,
		Selected = initialSelected,
		Callback = Config.Callback or function(Value) end,
		Type = "SelectionList",
		Items = {},
	}

	local SelectionFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false)
	
	local ListHolder = New("Frame", {
		Size = UDim2.new(1, -20, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(10, 42),
		BackgroundTransparency = 1,
		Parent = SelectionFrame.Frame
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})

	local function CreateItem(Name)
		local isSelected = table.find(SelectionList.Selected, Name) ~= nil
		
		local Dot = New("Frame", {
			Size = UDim2.fromOffset(6, 6),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = isSelected,
			BackgroundTransparency = 0.2
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		local Circle = New("Frame", {
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = isSelected and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(35, 38, 45),
			BackgroundTransparency = isSelected and 0 or 0.5,
			ThemeTag = {
				BackgroundColor3 = isSelected and "Accent" or "Element"
			}
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			New("UIStroke", {
				Thickness = 1,
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = isSelected and 0.4 or 0.8,
			}),
			Dot,
		})

		local ItemBtn = New("TextButton", {
			Name = "Item_" .. Name,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Text = "",
			Parent = ListHolder
		}, {
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 12),
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Circle,
			New("TextLabel", {
				Text = Name,
				TextColor3 = Color3.fromRGB(220, 220, 220),
				TextSize = 14,
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				ThemeTag = { TextColor3 = "Text" }
			})
		})

		local function UpdateItemVisual()
			local nowSelected = table.find(SelectionList.Selected, Name) ~= nil
			Creator.OverrideTag(Circle, { BackgroundColor3 = nowSelected and "Accent" or "Element" })
			Circle.BackgroundTransparency = nowSelected and 0 or 0.5
			Dot.Visible = nowSelected
		end

		Creator.AddSignal(ItemBtn.MouseButton1Click, function()
			local foundIdx = table.find(SelectionList.Selected, Name)
			if foundIdx then
				table.remove(SelectionList.Selected, foundIdx)
			else
				table.insert(SelectionList.Selected, Name)
			end
			
			UpdateItemVisual()
			
			Library:SafeCallback(SelectionList.Callback, SelectionList.Selected)
			Library:SafeCallback(SelectionList.Changed, SelectionList.Selected)
		end)

		SelectionList.Items[Name] = {
			Button = ItemBtn,
			Update = UpdateItemVisual,
		}

		return ItemBtn
	end

	local function BuildItems()
		for _, child in ipairs(ListHolder:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
		SelectionList.Items = {}
		for _, Value in ipairs(SelectionList.Values) do
			CreateItem(Value)
		end
	end

	BuildItems()

	function SelectionList:SetValue(Values)
		local newSelected = {}
		if type(Values) == "table" then
			for _, v in ipairs(Values) do
				if table.find(SelectionList.Values, v) then
					table.insert(newSelected, v)
				end
			end
		end
		SelectionList.Selected = newSelected

		for _, item in pairs(SelectionList.Items) do
			item.Update()
		end

		Library:SafeCallback(SelectionList.Callback, SelectionList.Selected)
		Library:SafeCallback(SelectionList.Changed, SelectionList.Selected)
	end

	function SelectionList:SetValues(NewValues)
		SelectionList.Values = NewValues or {}
		local filtered = {}
		for _, v in ipairs(SelectionList.Selected) do
			if table.find(SelectionList.Values, v) then
				table.insert(filtered, v)
			end
		end
		SelectionList.Selected = filtered
		BuildItems()
	end

	function SelectionList:OnChanged(Func)
		SelectionList.Changed = Func
		Func(SelectionList.Selected)
	end

	function SelectionList:Destroy()
		SelectionFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Library.Options[Idx] = SelectionList
	
	SelectionList.Frame = SelectionFrame.Frame
	table.insert(Library.AllElements, {
		Type = "Element",
		ElementType = "SelectionList",
		Name = Config.Title,
		Title = Config.Title,
		Description = Config.Description or "",
		TabIndex = self.TabIndex,
		Frame = SelectionFrame.Frame,
	})
	
	return SelectionList
end

return Element
