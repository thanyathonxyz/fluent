-- i will rewrite this someday
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Acrylic = require(Root.Acrylic)
local Assets = require(script.Parent.Assets)
local Components = script.Parent

local Spring = Flipper.Spring.new
local Instant = Flipper.Instant.new
local New = Creator.New

return function(Config)
	local Library = require(Root)

	local Window = {
		Minimized = false,
		Maximized = false,
		Size = Config.Size,
		CurrentPos = 0,
		TabWidth = 0,
		Position = UDim2.fromOffset(
			Camera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
			Camera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
		),
	}

	local Dragging, DragInput, MousePos, StartPos = false
	local Resizing, ResizePos = false
	local MinimizeNotif = false

	Window.AcrylicPaint = Acrylic.AcrylicPaint()
	-- App Icon
	local AppIcon = Config.Icon and New("ImageLabel", {
		Name = "AppIcon",
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(0, 10, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Image = Config.Icon,
		Parent = nil -- Will be added to TitleBar.Frame later
	}) or nil

	-- Title and Subtitle holder (Aligned to LEFT)
	local TitleHolder = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, AppIcon and 40 or 12, 0, 0),
		AnchorPoint = Vector2.new(0, 0),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
	})

	Window.TabWidth = Config.TabWidth

	local Selector = New("Frame", {
		Size = UDim2.fromOffset(2, 0),
		Position = UDim2.fromOffset(0, 17),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
        New("ImageLabel", {
            Name = "Glow",
            BackgroundTransparency = 1,
            Image = "rbxassetid://5554236805",
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(23, 23, 277, 277),
            Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(20, 20),
            Position = UDim2.fromOffset(-10, -10),
            ThemeTag = {
                ImageColor3 = "Accent",
            },
            ImageTransparency = 0.5
        })
	})

	local ResizeStartFrame = New("Frame", {
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 1, -20),
	})

	Window.TabHolder = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 3),
		}),
	})

	local TabFrame = New("Frame", {
		Size = UDim2.new(0, Window.TabWidth, 1, -66),
		Position = UDim2.new(0, 12, 0, 54),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		Window.TabHolder,
		Selector,
	})

	Window.TabDisplay = New("TextLabel", {
		RichText = true,
		Text = "Tab",
		TextTransparency = 0,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
		TextSize = 30,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 52),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Window.ContainerHolder = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	Window.ContainerAnim = New("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	Window.ContainerCanvas = New("Frame", {
		Size = UDim2.new(1, -Window.TabWidth - 32, 1, -102),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 90),
		BackgroundTransparency = 1,
	}, {
		Window.ContainerAnim,
		Window.ContainerHolder
	})

	Window.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = Window.Size,
		Position = Window.Position,
		Parent = Config.Parent,
	}, {
		Window.AcrylicPaint.Frame,
		Window.TabDisplay,
		Window.ContainerCanvas,
		TabFrame,
		ResizeStartFrame,
	})

	-- Sidebar Content (Search + Tabs)
	local Search = require(Components.Search)(Window.Root, Window)
	Search.Frame.Position = UDim2.new(0, 5, 0, 48)
	Search.Frame.Size = UDim2.new(0, Window.TabWidth, 0, 30)
	Search.Frame.ZIndex = 1
	
	TabFrame.Position = UDim2.new(0, 5, 0, 84)
	TabFrame.Size = UDim2.new(0, Window.TabWidth, 1, -94)
	TabFrame.ZIndex = 1

	local SearchCorner = Search.Frame:FindFirstChildOfClass("UICorner")
	if SearchCorner then SearchCorner.CornerRadius = UDim.new(0, 6) end

	-- Initialize TabModule before TitleBar so SelectTab is available for Search
	local TabModule = require(Components.Tab):Init(Window)
	function Window:AddTab(TabConfig)
		return TabModule:New(TabConfig.Title, TabConfig.Icon, Window.TabHolder)
	end

	function Window:SelectTab(Tab)
		TabModule:SelectTab(Tab or 1)
	end

	Window.TitleBar = require(script.Parent.TitleBar)({
		Title = Config.Title,
		SubTitle = Config.SubTitle,
		Icon = Config.Icon,
		Author = Config.Author,
        TitleOffset = Config.TitleOffset, -- Enabling the Manual System
		Parent = Window.Root,
		Window = Window,
	})

	if require(Root).UseAcrylic then
		Window.AcrylicPaint.AddParent(Window.Root)
	end

	local SizeMotor = Flipper.GroupMotor.new({
		X = Window.Size.X.Offset,
		Y = Window.Size.Y.Offset,
	})

	local PosMotor = Flipper.GroupMotor.new({
		X = Window.Position.X.Offset,
		Y = Window.Position.Y.Offset,
	})

	Window.SelectorPosMotor = Flipper.SingleMotor.new(17)
	Window.SelectorSizeMotor = Flipper.SingleMotor.new(0)
	Window.ContainerBackMotor = Flipper.SingleMotor.new(0)
	Window.ContainerPosMotor = Flipper.SingleMotor.new(94)

	SizeMotor:onStep(function(values)
		Window.Root.Size = UDim2.new(0, values.X, 0, values.Y)
	end)

	PosMotor:onStep(function(values)
		Window.Root.Position = UDim2.new(0, values.X, 0, values.Y)
	end)

	local LastValue = 0
	local LastTime = 0
	Window.SelectorPosMotor:onStep(function(Value)
		Selector.Position = UDim2.new(0, 0, 0, Value + 17)
		local Now = tick()
		local DeltaTime = Now - LastTime

		if LastValue ~= nil then
			Window.SelectorSizeMotor:setGoal(Spring((math.abs(Value - LastValue) / (DeltaTime * 60)) + 16))
			LastValue = Value
		end
		LastTime = Now
	end)

	Window.SelectorSizeMotor:onStep(function(Value)
		Selector.Size = UDim2.new(0, 2, 0, Value)
	end)

	Window.ContainerBackMotor:onStep(function(Value)
		Window.ContainerAnim.GroupTransparency = Value
	end)

	Window.ContainerPosMotor:onStep(function(Value)
		Window.ContainerAnim.Position = UDim2.fromOffset(0, Value)
	end)

	local OldSizeX
	local OldSizeY
	Window.Maximize = function(Value, NoPos, Instant)
		Window.Maximized = Value
		Window.TitleBar.MaxButton.Frame.Icon.Image = Value and Assets.Restore or Assets.Max

		if Value then
			OldSizeX = Window.Size.X.Offset
			OldSizeY = Window.Size.Y.Offset
		end
		local SizeX = Value and Camera.ViewportSize.X or OldSizeX
		local SizeY = Value and Camera.ViewportSize.Y or OldSizeY
		SizeMotor:setGoal({
			X = Flipper[Instant and "Instant" or "Spring"].new(SizeX, { frequency = 6 }),
			Y = Flipper[Instant and "Instant" or "Spring"].new(SizeY, { frequency = 6 }),
		})
		Window.Size = UDim2.fromOffset(SizeX, SizeY)

		if not NoPos then
			PosMotor:setGoal({
				X = Spring(Value and 0 or Window.Position.X.Offset, { frequency = 6 }),
				Y = Spring(Value and 0 or Window.Position.Y.Offset, { frequency = 6 }),
			})
		end
	end

	Creator.AddSignal(Window.TitleBar.Frame.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = true
			MousePos = Input.Position
			StartPos = Window.Root.Position

			if Window.Maximized then
				StartPos = UDim2.fromOffset(
					Mouse.X - (Mouse.X * ((OldSizeX - 100) / Window.Root.AbsoluteSize.X)),
					Mouse.Y - (Mouse.Y * (OldSizeY / Window.Root.AbsoluteSize.Y))
				)
			end

			if Window.AcrylicPaint and Window.AcrylicPaint.SetVisibility then
				Window.AcrylicPaint.SetVisibility(false)
			end

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					if Window.AcrylicPaint and Window.AcrylicPaint.SetVisibility then
						Window.AcrylicPaint.SetVisibility(true)
					end
				end
			end)
		end
	end)

	Creator.AddSignal(Window.TitleBar.Frame.InputChanged, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			DragInput = Input
		end
	end)

	Creator.AddSignal(ResizeStartFrame.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Resizing = true
			ResizePos = Input.Position
		end
	end)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			local NewPosX = StartPos.X.Offset + Delta.X
			local NewPosY = StartPos.Y.Offset + Delta.Y
			
			-- Clamp to viewport bounds so window can't go completely off-screen
			local WinSize = Window.Root.AbsoluteSize
			local ViewSize = Camera.ViewportSize
			NewPosX = math.clamp(NewPosX, -WinSize.X + 80, ViewSize.X - 80)
			NewPosY = math.clamp(NewPosY, 0, ViewSize.Y - 40)
			
			local NewPos = UDim2.fromOffset(NewPosX, NewPosY)
			
			Window.Root.Position = NewPos
			Window.Position = NewPos
			-- Sync motor so it doesn't snap back when drag ends
			PosMotor:setGoal({
				X = Instant(NewPos.X.Offset),
				Y = Instant(NewPos.Y.Offset),
			})

			if Window.Maximized then
				Window.Maximize(false, true, true)
			end
		end

		if
			(Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
			and Resizing
		then
			local Delta = Input.Position - ResizePos
			local StartSize = Window.Size

			local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0) + Vector3.new(1, 1, 0) * Delta
			local TargetSizeClamped =
				Vector2.new(math.clamp(TargetSize.X, 470, 2048), math.clamp(TargetSize.Y, 380, 2048))

			SizeMotor:setGoal({
				X = Flipper.Instant.new(TargetSizeClamped.X),
				Y = Flipper.Instant.new(TargetSizeClamped.Y),
			})
		end
	end)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if Resizing == true or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = false
			Window.Size = UDim2.fromOffset(SizeMotor:getValue().X, SizeMotor:getValue().Y)
		end
	end)

	Creator.AddSignal(Window.TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Window.TabHolder.CanvasSize = UDim2.new(0, 0, 0, Window.TabHolder.UIListLayout.AbsoluteContentSize.Y)
	end)

	Window.MinimizeKey = Config.MinimizeKey

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if
			type(Library.MinimizeKeybind) == "table"
			and Library.MinimizeKeybind.Type == "Keybind"
			and not UserInputService:GetFocusedTextBox()
		then
			if Input.KeyCode.Name == Library.MinimizeKeybind.Value then
				Window:Minimize()
			end
		elseif Input.KeyCode == Window.MinimizeKey and not UserInputService:GetFocusedTextBox() then
			Window:Minimize()
		end
	end)

	function Window:Minimize()
		Window.Minimized = not Window.Minimized
		Window.Root.Visible = not Window.Minimized
		-- Toggle Acrylic DepthOfField effect so blur doesn't linger when hidden
		if require(Root).UseAcrylic then
			if Window.Minimized then
				Acrylic.Disable()
			else
				Acrylic.Enable()
			end
		end
		if not MinimizeNotif then
			MinimizeNotif = true
			if Window.ToggleButton then
				Library:Notify({
					Title = "Interface",
					Content = "Drag the toggle button to move it. Tap to show/hide.",
					Duration = 6
				})
			else
				local Key = Library.MinimizeKeybind and Library.MinimizeKeybind.Value or Library.MinimizeKey.Name
				Library:Notify({
					Title = "Interface",
					Content = "Press " .. Key .. " to toggle the interface.",
					Duration = 6
				})
			end
		end
	end

	-- ========== Mobile Toggle Button ==========
	do
		local TBRaw = Config.ToggleButton
		local TBConfig = {}
		local ShowToggle

		if TBRaw == false then
			ShowToggle = false
		elseif TBRaw == true then
			TBConfig = { Enabled = true }
			ShowToggle = true
		elseif type(TBRaw) == "table" then
			TBConfig = TBRaw
			if TBConfig.Enabled ~= nil then
				ShowToggle = TBConfig.Enabled
			else
				ShowToggle = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
			end
		else
			-- nil/unset: auto-detect mobile
			ShowToggle = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		end

		if ShowToggle then
			local TBShape = TBConfig.Shape or "Circle"
			local TBSize = TBConfig.Size or 50
			local TBImage = TBConfig.Image or Config.Icon or nil
			local UseCustomColor = TBConfig.Color ~= nil
			local TBColor = TBConfig.Color or Color3.fromRGB(76, 115, 255)
			local TBPosition = TBConfig.Position or UDim2.new(0, 15, 0.5, -TBSize / 2)
			local IsLogoOnly = (TBShape == "Logo")

			local CornerRadius
			if TBShape == "Circle" then
				CornerRadius = UDim.new(1, 0)
			elseif TBShape == "Square" then
				CornerRadius = UDim.new(0, 10)
			else
				CornerRadius = UDim.new(0, 0)
			end

			local IconSize = IsLogoOnly and TBSize or math.floor(TBSize * 0.55)

			local ToggleIcon = TBImage and New("ImageLabel", {
				Name = "Icon",
				Size = UDim2.fromOffset(IconSize, IconSize),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = TBImage,
				ScaleType = Enum.ScaleType.Fit,
			}) or nil

			Window.ToggleButton = New("TextButton", {
				Name = "ToggleButton",
				Size = UDim2.fromOffset(TBSize, TBSize),
				Position = TBPosition,
				BackgroundColor3 = IsLogoOnly and Color3.new(0, 0, 0) or TBColor,
				BackgroundTransparency = IsLogoOnly and 1 or 0.15,
				Text = "",
				AutoButtonColor = false,
				Parent = Config.Parent,
				ZIndex = 999,
				ThemeTag = (not IsLogoOnly and not UseCustomColor) and { BackgroundColor3 = "Accent" } or nil,
			}, {
				New("UICorner", { CornerRadius = CornerRadius }),
				(not IsLogoOnly) and New("UIStroke", {
					Thickness = 1.5,
					Transparency = 0.4,
					Color = TBColor,
					ThemeTag = (not UseCustomColor) and { Color = "Accent" } or nil,
				}) or nil,
				ToggleIcon,
				(not IsLogoOnly) and New("ImageLabel", {
					Name = "Shadow",
					BackgroundTransparency = 1,
					Image = "rbxassetid://5554236805",
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(23, 23, 277, 277),
					Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
					Position = UDim2.fromOffset(-15, -12),
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageTransparency = 0.6,
					ZIndex = -1,
				}) or nil,
			})

			-- Draggable toggle button
			local TBDragging = false
			local TBDragInput
			local TBDragStart
			local TBStartPos
			local DidDrag = false

			Creator.AddSignal(Window.ToggleButton.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					TBDragging = true
					DidDrag = false
					TBDragStart = Input.Position
					TBStartPos = Vector2.new(
						Window.ToggleButton.AbsolutePosition.X,
						Window.ToggleButton.AbsolutePosition.Y
					)

					if not IsLogoOnly then
						Window.ToggleButton.BackgroundTransparency = 0.35
					end

					Input.Changed:Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							TBDragging = false
							if not IsLogoOnly then
								Window.ToggleButton.BackgroundTransparency = 0.15
							end
							if not DidDrag then
								Window:Minimize()
							end
						end
					end)
				end
			end)

			Creator.AddSignal(Window.ToggleButton.InputChanged, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
					TBDragInput = Input
				end
			end)

			Creator.AddSignal(UserInputService.InputChanged, function(Input)
				if Input == TBDragInput and TBDragging then
					local Delta = Input.Position - TBDragStart
					if Delta.Magnitude > 5 then
						DidDrag = true
					end
					local NewPos = UDim2.fromOffset(
						math.clamp(TBStartPos.X + Delta.X, 0, Camera.ViewportSize.X - TBSize),
						math.clamp(TBStartPos.Y + Delta.Y, 0, Camera.ViewportSize.Y - TBSize)
					)
					Window.ToggleButton.Position = NewPos
				end
			end)
		end
	end

    function Window:ToggleTransparency(Value)
        if not Window.AcrylicPaint then return end
        local Background = Window.AcrylicPaint.Frame:FindFirstChild("Background")
        if not Background then return end
        
        -- If Value is provided, use it directly; otherwise toggle
        if Value == nil then
            Value = Background.BackgroundTransparency < 0.1
        end
        
        Library.Transparency = Value
        Background.BackgroundTransparency = Value and 0.35 or 0
    end

	function Window:Destroy()
		pcall(function()
			if require(Root).UseAcrylic and Window.AcrylicPaint.Model then
				Window.AcrylicPaint.Model:Destroy()
			end
		end)
		pcall(function()
			Window.Root:Destroy()
		end)
		pcall(function()
			if Window.ToggleButton then
				Window.ToggleButton:Destroy()
			end
		end)
	end

	local DialogModule = require(Components.Dialog):Init(Window)
	function Window:Dialog(Config)
		local Dialog = DialogModule:Create()
		Dialog.Title.Text = Config.Title

		local Content = New("TextLabel", {
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			Text = Config.Content,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(20, 60),
			BackgroundTransparency = 1,
			Parent = Dialog.Root,
			ClipsDescendants = false,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		New("UISizeConstraint", {
			MinSize = Vector2.new(300, 165),
			MaxSize = Vector2.new(620, math.huge),
			Parent = Dialog.Root,
		})

		Dialog.Root.Size = UDim2.fromOffset(Content.TextBounds.X + 40, 165)
		if Content.TextBounds.X + 40 > Window.Size.X.Offset - 120 then
			Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, 165)
			Content.TextWrapped = true
			Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, Content.TextBounds.Y + 150)
		end

		for _, Button in next, Config.Buttons do
			Dialog:Button(Button.Title, Button.Callback)
		end

		Dialog:Open()
	end

	Creator.AddSignal(Window.TabHolder:GetPropertyChangedSignal("CanvasPosition"), function()
		LastValue = TabModule:GetCurrentTabPos() + 16
		LastTime = 0
		Window.SelectorPosMotor:setGoal(Instant(TabModule:GetCurrentTabPos()))
	end)

	return Window
end
