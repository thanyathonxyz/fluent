local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Stepper"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Stepper - Missing Title.")
	assert(Config.Default, "Stepper - Missing default value.")
	assert(Config.Min, "Stepper - Missing minimum value.")
	assert(Config.Max, "Stepper - Missing maximum value.")
	Config.Step = Config.Step or 1

	local Stepper = {
		Value = nil,
		Min = Config.Min,
		Max = Config.Max,
		Step = Config.Step or 1,
		Callback = Config.Callback or function(Value) end,
		Type = "Stepper",
	}

	local StepperFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)
	StepperFrame.DescLabel.Size = UDim2.new(1, -120, 0, 14)

	Stepper.SetTitle = StepperFrame.SetTitle
	Stepper.SetDesc = StepperFrame.SetDesc

	local ValueLabel = New("TextLabel", {
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = tostring(Config.Default),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextSize = 13,
		ThemeTag = { TextColor3 = "Text" }
	})

	local function CreateButton(Icon, Callback)
		local Btn = New("TextButton", {
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = Color3.fromRGB(35, 38, 45),
			BackgroundTransparency = 0.5,
			Text = Icon,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
			TextSize = 16,
			ThemeTag = { 
				BackgroundColor3 = "Element",
				TextColor3 = "Text"
			}
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", {
				Thickness = 1,
				Transparency = 0.8,
				ThemeTag = { Color = "ElementBorder" }
			})
		})

		Creator.AddSignal(Btn.MouseButton1Click, Callback)
		return Btn
	end

	local Controls = New("Frame", {
		Size = UDim2.new(0, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = StepperFrame.Frame
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 15),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		CreateButton("-", function()
			Stepper:SetValue(Stepper.Value - Stepper.Step)
		end),
		ValueLabel,
		CreateButton("+", function()
			Stepper:SetValue(Stepper.Value + Stepper.Step)
		end)
	})

	function Stepper:OnChanged(Func)
		Stepper.Changed = Func
		Func(Stepper.Value)
	end

	function Stepper:SetValue(Value)
		local Rounded = Library:Round(math.clamp(Value, Stepper.Min, Stepper.Max), 2)
		self.Value = Rounded
		ValueLabel.Text = tostring(Rounded)

		Library:SafeCallback(Stepper.Callback, self.Value)
		Library:SafeCallback(Stepper.Changed, self.Value)
	end

	function Stepper:Destroy()
		StepperFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Stepper:SetValue(Config.Default)
	Library.Options[Idx] = Stepper
	
	Stepper.Frame = StepperFrame.Frame
	table.insert(Library.AllElements, {
		Type = "Element",
		ElementType = "Stepper",
		Name = Config.Title,
		Title = Config.Title,
		Description = Config.Description or "",
		TabIndex = self.TabIndex,
		Frame = StepperFrame.Frame,
	})
	
	return Stepper
end

return Element
