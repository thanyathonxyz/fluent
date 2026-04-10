local Root = script.Parent.Parent
local Assets = require(script.Parent.Assets)
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)
local SearchModule = require(script.Parent.Search)

local New = Creator.New
local AddSignal = Creator.AddSignal

return function(Config)
	local TitleBar = {}
	local Library = require(Root)

	local function BarButton(Icon, Pos, Parent, Callback)
		local Button = {
			Callback = Callback or function() end,
		}

		Button.Frame = New("TextButton", {
			Size = UDim2.new(0, 34, 1, -8),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Parent = Parent,
			Position = Pos,
			Text = "",
			ThemeTag = { BackgroundColor3 = "Text" },
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 7) }),
			New("ImageLabel", {
				Image = Icon,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Name = "Icon",
				ThemeTag = { ImageColor3 = "Text" },
			}),
		})

		local Motor, SetTransparency = Creator.SpringMotor(1, Button.Frame, "BackgroundTransparency")
		AddSignal(Button.Frame.MouseEnter, function() SetTransparency(0.94) end)
		AddSignal(Button.Frame.MouseLeave, function() SetTransparency(1, true) end)
		AddSignal(Button.Frame.MouseButton1Down, function() SetTransparency(0.96) end)
		AddSignal(Button.Frame.MouseButton1Up, function() SetTransparency(0.94) end)
		AddSignal(Button.Frame.MouseButton1Click, Button.Callback)

		return Button
	end

	-- App Icon
	local AppIcon = Config.Icon and New("ImageLabel", {
		Name = "AppIcon",
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		Image = Config.Icon,
	}) or nil

	-- Title and Subtitle holder
	local TitleHolder = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
	}, {
		New("UISizeConstraint", { MaxSize = Vector2.new(400, math.huge) }),
		New("UIListLayout", {
			Padding = UDim.new(0, 6),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		New("TextLabel", {
			Name = "Title",
			LayoutOrder = 1,
			RichText = true,
			Text = Config.Title,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
			TextSize = 13,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			ThemeTag = { TextColor3 = "Text" },
		}),
		(Config.Author and Config.Author ~= "") and New("TextLabel", {
			Name = "AuthorLabel",
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text = "by " .. Config.Author,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextSize = 11,
			TextXAlignment = "Left",
			ThemeTag = { TextColor3 = "SubText" },
		}) or nil,
		(Config.SubTitle and Config.SubTitle ~= "") and New("Frame", {
			Name = "SubTitleBadge",
			LayoutOrder = 3,
			Size = UDim2.fromOffset(0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 0.85,
			ThemeTag = { BackgroundColor3 = "Accent" }
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
			New("UIStroke", {
				Transparency = 0.7,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				ThemeTag = { Color = "Accent" }
			}),
			New("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = Config.SubTitle,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
				TextSize = 10,
				ThemeTag = { TextColor3 = "Text" }
			})
		}) or nil,
	})

	-- Unified Branding (The real one)
	local BrandingLabel = New("Frame", {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, Config.TitleOffset or 12, 0, 0), -- Alignment King: 12px standard 
		BackgroundTransparency = 1,
	}, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 14), -- Extra spatial luxury
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        AppIcon,
        TitleHolder
    })

	TitleBar.Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		Parent = Config.Parent,
	}, {
		BrandingLabel,
        -- Glass Divider Line
        New("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, -20, 0, 1),
            Position = UDim2.new(0, 10, 1, -1),
            BackgroundTransparency = 0.8,
            ThemeTag = { BackgroundColor3 = "TitleBarLine" },
        })
	})

	TitleBar.CloseButton = BarButton(Assets.Close, UDim2.new(1, -4, 0, 4), TitleBar.Frame, function()
		Library.Window:Dialog({
			Title = "Close",
			Content = "Are you sure you want to unload the interface?",
			Buttons = {
				{ Title = "Yes", Callback = function() Library:Destroy() end },
				{ Title = "No" },
			},
		})
	end)
	TitleBar.MaxButton = BarButton(Assets.Max, UDim2.new(1, -40, 0, 4), TitleBar.Frame, function()
		Config.Window.Maximize(not Config.Window.Maximized)
	end)
	TitleBar.MinButton = BarButton(Assets.Min, UDim2.new(1, -80, 0, 4), TitleBar.Frame, function()
		Library.Window:Minimize()
	end)

	return TitleBar
end
