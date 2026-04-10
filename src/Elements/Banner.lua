local Root = script.Parent.Parent
local Components = Root.Components
local Creator = require(Root.Creator)
local New = Creator.New

local Banner = {}
Banner.__index = Banner
Banner.__type = "Banner"

local StyleColors = {
	info    = nil,
	warning = Color3.fromRGB(230, 175, 45),
	success = Color3.fromRGB(45, 185, 85),
	error   = Color3.fromRGB(215, 55, 55),
}

local StyleIcons = {
	info    = "info",
	warning = "alert-triangle",
	success = "check-circle",
	error   = "x-circle",
}

function Banner:New(Config)
	Config.Title = Config.Title or "Banner"
	Config.Content = Config.Content or Config.Desc or ""
	Config.Style = Config.Style or "info"

	local Library = require(Root)

	local style = string.lower(Config.Style)
	if not StyleColors[style] then style = "info" end

	local accentColor = StyleColors[style] or Creator.GetThemeProperty("Accent") or Color3.fromRGB(76, 115, 255)
	local iconName = StyleIcons[style] or "info"
	local iconImage = Library:GetIcon(iconName) or "rbxassetid://10723415959"

	-- Identical Element base as Paragraph — same bg, same border, same theme tags
	local Element = require(Components.Element)(Config.Title, Config.Content, Banner.Container, false)
	Element.Frame.BackgroundTransparency = 0.92
	Element.Border.Transparency = 0.6

	-- Make title bold to differentiate from Paragraph
	Element.TitleLabel.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Bold
	)

	-- Shift LabelHolder right to make room for accent bar + icon
	Element.LabelHolder.Position = UDim2.fromOffset(32, 0)
	Element.LabelHolder.Size = UDim2.new(1, -42, 0, 0)

	-- Colored left accent bar (like Section indicator — small, absolutely positioned)
	local AccentBar = New("Frame", {
		Name = "AccentBar",
		Size = UDim2.fromOffset(2, 16),
		Position = UDim2.fromOffset(0, 12),
		BackgroundColor3 = accentColor,
		Parent = Element.Frame,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 2) })
	})
	if style == "info" then
		Creator.AddThemeObject(AccentBar, { BackgroundColor3 = "Accent" })
	end

	-- Colored icon — absolutely positioned, no layout impact
	local InfoIcon = New("ImageLabel", {
		Name = "InfoIcon",
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(0, 10, 0, 13),
		BackgroundTransparency = 1,
		Image = iconImage,
		ImageTransparency = 0.1,
		ImageColor3 = accentColor,
		Parent = Element.Frame,
	})
	if style == "info" then
		Creator.AddThemeObject(InfoIcon, { ImageColor3 = "Accent" })
	end

	local BannerObj = {
		Frame = Element.Frame,
		TitleLabel = Element.TitleLabel,
		DescLabel = Element.DescLabel,
		InfoIcon = InfoIcon,
		AccentBar = AccentBar,
	}

	function BannerObj:SetTitle(Text)
		Element:SetTitle(Text)
	end

	function BannerObj:SetContent(Text)
		Element:SetDesc(Text)
	end
	local Library = require(Root)

	BannerObj.Frame = Element.Frame
	table.insert(Library.AllElements, {
		Type = "Element",
		ElementType = "Banner",
		Name = Config.Title,
		Title = Config.Title,
		Description = Config.Content,
		TabIndex = Banner.TabIndex,
		Frame = Element.Frame,
	})

	function BannerObj:SetStyle(newStyle)
		newStyle = string.lower(newStyle or "info")
		if not StyleColors[newStyle] then newStyle = "info" end

		local newColor = StyleColors[newStyle] or Creator.GetThemeProperty("Accent") or Color3.fromRGB(76, 115, 255)
		local newIcon = Library:GetIcon(StyleIcons[newStyle] or "info") or "rbxassetid://10723415959"

		InfoIcon.ImageColor3 = newColor
		InfoIcon.Image = newIcon
		AccentBar.BackgroundColor3 = newColor

		if newStyle == "info" then
			Creator.AddThemeObject(InfoIcon, { ImageColor3 = "Accent" })
			Creator.AddThemeObject(AccentBar, { BackgroundColor3 = "Accent" })
		else
			Creator.OverrideTag(InfoIcon, {})
			Creator.OverrideTag(AccentBar, {})
		end
	end

	return BannerObj
end

return Banner
