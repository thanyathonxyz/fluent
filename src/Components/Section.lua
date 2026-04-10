local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)
local TweenService = game:GetService("TweenService")
local New = Creator.New

return function(TitleOrConfig, Parent)
	local Section = {}
	local Library = require(Root)

	-- Support both Section("Title", Parent) and Section({Title="...", Opened=true}, Parent)
	local Title = TitleOrConfig
	local Opened = true
	if type(TitleOrConfig) == "table" then
		Title = TitleOrConfig.Title or "Section"
		Opened = TitleOrConfig.Opened ~= false -- default true
	end

	Section.Opened = Opened

	Section.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
	})

	Section.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 24),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Visible = Section.Opened,
	}, {
		Section.Layout,
	})

	-- Collapse arrow icon (rotates 90° when opened)
	local ArrowIcon = New("ImageLabel", {
		Name = "Arrow",
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(1, -16, 0, 7),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://10709790948",
		Rotation = Section.Opened and 0 or -90,
		ThemeTag = { ImageColor3 = "SubText" },
	})

	local TitleButton = New("TextButton", {
		Text = "",
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
	})

	Section.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		-- Vertical Accent Bar
		New("Frame", {
			Name = "Indicator",
			Size = UDim2.fromOffset(2, 16),
			Position = UDim2.fromOffset(0, 4),
			ThemeTag = { BackgroundColor3 = "Accent" }
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 2) })
		}),
		-- Clickable title area
		TitleButton,
		-- Title with spacing for indicator
		New("TextLabel", {
			RichText = true,
			Text = Title,
			TextTransparency = 0,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 14,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Size = UDim2.new(1, -30, 0, 18),
			Position = UDim2.fromOffset(10, 3),
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Text",
			},
		}),
		ArrowIcon,
		Section.Container,
	})

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Find ancestor ScrollingFrame for auto-scroll
	local function GetScrollFrame()
		local sf = Section.Root.Parent
		while sf and not sf:IsA("ScrollingFrame") do
			sf = sf.Parent
		end
		return sf
	end

	local function ScrollToShow()
		local scrollFrame = GetScrollFrame()
		if not scrollFrame then return end

		-- Use predicted final size instead of current (still tweening) size
		local targetH = Section.Layout.AbsoluteContentSize.Y + 28
		local sectionBottom = Section.Root.AbsolutePosition.Y + targetH
		local scrollBottom = scrollFrame.AbsolutePosition.Y + scrollFrame.AbsoluteSize.Y

		if sectionBottom > scrollBottom then
			local scrollAmount = sectionBottom - scrollBottom + 10
			local newY = math.max(0, scrollFrame.CanvasPosition.Y + scrollAmount)
			TweenService:Create(scrollFrame, tweenInfo, {
				CanvasPosition = Vector2.new(0, newY)
			}):Play()
		end
	end

	local function UpdateSize(animate)
		if Section.Opened then
			Section.Container.Visible = true
			local targetY = Section.Layout.AbsoluteContentSize.Y
			if animate then
				TweenService:Create(Section.Container, tweenInfo, {
					Size = UDim2.new(1, 0, 0, targetY)
				}):Play()
				TweenService:Create(Section.Root, tweenInfo, {
					Size = UDim2.new(1, 0, 0, targetY + 28)
				}):Play()
				-- Scroll in parallel after one frame (layout needs to update)
				task.spawn(function()
					task.wait()
					if Section.Opened then
						ScrollToShow()
					end
				end)
			else
				Section.Container.Size = UDim2.new(1, 0, 0, targetY)
				Section.Root.Size = UDim2.new(1, 0, 0, targetY + 28)
			end
		else
			if animate then
				local tween = TweenService:Create(Section.Root, tweenInfo, {
					Size = UDim2.new(1, 0, 0, 24)
				})
				TweenService:Create(Section.Container, tweenInfo, {
					Size = UDim2.new(1, 0, 0, 0)
				}):Play()
				tween:Play()
				tween.Completed:Connect(function()
					if not Section.Opened then
						Section.Container.Visible = false
					end
				end)
			else
				Section.Container.Visible = false
				Section.Root.Size = UDim2.new(1, 0, 0, 24)
			end
		end
	end

	function Section:SetOpen(ForceState)
		if ForceState ~= nil then
			Section.Opened = ForceState
		else
			Section.Opened = not Section.Opened
		end
		TweenService:Create(ArrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Rotation = Section.Opened and 0 or -90
		}):Play()
		UpdateSize(true)
	end

	Creator.AddSignal(TitleButton.MouseButton1Click, function()
		Section:SetOpen()
	end)

	-- Auto-assign incrementing LayoutOrder to children so insertion order is preserved
	local childOrder = 0
	Creator.AddSignal(Section.Container.ChildAdded, function(child)
		if child:IsA("GuiObject") then
			childOrder = childOrder + 1
			child.LayoutOrder = childOrder
		end
	end)

	Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if Section.Opened then
			Section.Container.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y)
			Section.Root.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y + 28)
		end
	end)

	-- Apply initial state (no animation on creation)
	UpdateSize(false)

	return Section
end
