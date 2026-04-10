local Root = script.Parent.Parent
local Components = Root.Components
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local Paragraph = {}
Paragraph.__index = Paragraph
Paragraph.__type = "Paragraph"

function Paragraph:New(Config)
	assert(Config.Title, "Paragraph - Missing Title")
	Config.Content = Config.Content or Config.Desc or ""

	local ParagraphEl = require(Components.Element)(Config.Title, Config.Content, self.Container, false)
	ParagraphEl.Frame.BackgroundTransparency = 0.92
	ParagraphEl.Border.Transparency = 0.6

	local Library = require(Root)
	table.insert(Library.AllElements, {
		Type = "Element",
		ElementType = "Paragraph",
		Name = Config.Title,
		Title = Config.Title,
		Description = Config.Content,
		TabIndex = self.TabIndex,
		Frame = ParagraphEl.Frame,
	})

	return ParagraphEl
end

return Paragraph
