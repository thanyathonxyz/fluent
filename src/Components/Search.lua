local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local Spring = Flipper.Spring.new

return function(Parent, Window, OnSearchCallback)
	local Search = {
		Query = "",
		IsFiltering = false,
		Window = Window,
	}

	local Library = require(Root)

	-- Search Icon (Lucide)
	local SearchIcon = Library:GetIcon("search") or "rbxassetid://10734896206"
	local ClearIcon = Library:GetIcon("x") or "rbxassetid://10747384394"

	-- Clear button
	Search.ClearButton = New("ImageButton", {
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(1, -8, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = ClearIcon,
		ImageTransparency = 0.5,
		Visible = false,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	-- Search Input
	Search.Input = New("TextBox", {
		Size = UDim2.new(1, -45, 1, 0),
		Position = UDim2.fromOffset(24, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		Text = "",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		ClipsDescendants = true,
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "SubText",
		},
	})

	-- Search Container (use configurable width)
	local searchWidth = Library.SearchBarWidth or 180
	Search.Frame = New("Frame", {
		Size = UDim2.new(0, searchWidth, 0, 28),
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 0.92,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "Element",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 14),
		}),
		New("UIStroke", {
			Transparency = 0.7,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		New("ImageLabel", {
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.new(0, 8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = SearchIcon,
			ImageTransparency = 0.4,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		}),
		Search.Input,
		Search.ClearButton,
	})

	-- Hover effects
	local Motor, SetTransparency = Creator.SpringMotor(0.92, Search.Frame, "BackgroundTransparency")

	Creator.AddSignal(Search.Frame.MouseEnter, function()
		SetTransparency(0.88)
	end)
	Creator.AddSignal(Search.Frame.MouseLeave, function()
		if not Search.Input:IsFocused() then
			SetTransparency(0.92)
		end
	end)

	-- Focus effects
	Creator.AddSignal(Search.Input.Focused, function()
		SetTransparency(0.85)
	end)
	Creator.AddSignal(Search.Input.FocusLost, function()
		SetTransparency(0.92)
	end)

	-- Clear button click
	Creator.AddSignal(Search.ClearButton.MouseButton1Click, function()
		Search.Input.Text = ""
		Search:ClearFilter()
	end)

	-- Smart matching function
	local function matchesQuery(text, query)
		if not text or text == "" then return false end
		text = text:lower()
		query = query:lower()
		
		-- Direct contains match
		if text:find(query, 1, true) then
			return true
		end
		
		-- First letter of each word match (e.g., "ka" matches "Kill Aura")
		local initials = ""
		for word in text:gmatch("%S+") do
			initials = initials .. word:sub(1, 1)
		end
		if initials:find(query, 1, true) then
			return true
		end
		
		-- Start of any word match (e.g., "aur" matches "Kill Aura")
		for word in text:gmatch("%S+") do
			if word:sub(1, #query) == query then
				return true
			end
		end
		
		return false
	end

	-- Clear filter and restore all elements AND tabs
	function Search:ClearFilter()
		Search.IsFiltering = false
		Search.ClearButton.Visible = false
		
		-- Restore all elements visibility
		if Library.AllElements then
			for _, elementData in ipairs(Library.AllElements) do
				if elementData.Frame then
					pcall(function()
						elementData.Frame.Visible = true
					end)
				end
			end
		end
		
		-- Restore all tabs visibility
		if Library.AllTabs then
			for _, tabData in ipairs(Library.AllTabs) do
				if tabData.Frame then
					pcall(function()
						tabData.Frame.Visible = true
					end)
				end
			end
		end
	end

	-- Perform filter - filter both Tabs and Elements
	function Search:DoFilter(query)
		Search.Query = query
		
		if query == "" or #query < 1 then
			Search:ClearFilter()
			return
		end

		Search.IsFiltering = true
		Search.ClearButton.Visible = true

		-- Track which tabs have matching elements
		local tabsWithMatches = {}
		local foundTabIndex = nil

		-- First pass: find all matching elements and mark their tabs
		if Library.AllElements then
			for _, elementData in ipairs(Library.AllElements) do
				local title = elementData.Title or elementData.Name or ""
				local desc = elementData.Description or ""
				
				local matches = matchesQuery(title, query) or matchesQuery(desc, query)
				
				if elementData.Frame then
					pcall(function()
						elementData.Frame.Visible = matches
					end)
				end
				
				if matches and elementData.TabIndex then
					tabsWithMatches[elementData.TabIndex] = true
					if not foundTabIndex then
						foundTabIndex = elementData.TabIndex
					end
				end
			end
		end
		
		-- Also check if query matches Tab name directly
		if Library.AllTabs then
			for _, tabData in ipairs(Library.AllTabs) do
				local tabTitle = tabData.Title or tabData.Name or ""
				
				if matchesQuery(tabTitle, query) then
					tabsWithMatches[tabData.TabIndex] = true
					if not foundTabIndex then
						foundTabIndex = tabData.TabIndex
					end
					
					-- Show all elements in this tab if tab name matches
					if Library.AllElements then
						for _, elementData in ipairs(Library.AllElements) do
							if elementData.TabIndex == tabData.TabIndex and elementData.Frame then
								pcall(function()
									elementData.Frame.Visible = true
								end)
							end
						end
					end
				end
			end
		end

		-- Filter tabs - hide tabs without matches
		if Library.AllTabs then
			for _, tabData in ipairs(Library.AllTabs) do
				if tabData.Frame then
					pcall(function()
						tabData.Frame.Visible = (tabsWithMatches[tabData.TabIndex] == true)
					end)
				end
			end
		end

		-- Navigate to the tab containing the first match
		if foundTabIndex and Window and Window.SelectTab then
			Window:SelectTab(foundTabIndex)
		end
	end

	-- Listen to input changes (debounced)
	local _searchDebounce = nil
	Creator.AddSignal(Search.Input:GetPropertyChangedSignal("Text"), function()
		if _searchDebounce then
			task.cancel(_searchDebounce)
		end
		_searchDebounce = task.delay(0.15, function()
			_searchDebounce = nil
			Search:DoFilter(Search.Input.Text)
		end)
	end)

	return Search
end
