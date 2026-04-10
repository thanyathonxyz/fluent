local Themes = {
	Names = {
		"Night",
		"Darker",
		"Dark",
		"Amethyst",
		"Aqua",
		"Light",
		"Rose",
	},
}

for _, Theme in next, script:GetChildren() do
	local Required = require(Theme)
	Themes[Required.Name] = Required
end

return Themes
