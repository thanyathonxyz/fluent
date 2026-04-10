return {
    Name = "Darker",
    	Main = Color3.fromRGB(13, 13, 13),
	Background = Color3.fromRGB(18, 18, 18),
	
	-- Acrylic
	AcrylicMain = Color3.fromRGB(15, 15, 15),
	AcrylicGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10)),
	}),
	AcrylicNoise = 1,
	AcrylicBorder = Color3.fromRGB(45, 45, 45),
	
	-- Selection & Elements
	Accent = Color3.fromRGB(0, 120, 215), -- The specific Sailor Piece blue
	Element = Color3.fromRGB(70, 70, 70),
	ElementBorder = Color3.fromRGB(25, 25, 25),
	InElementBorder = Color3.fromRGB(255, 255, 255), -- Global In-element stroke
	
	-- Element states
	ElementHover = Color3.fromRGB(28, 32, 42),
	ElementTransparency = 0.82,
	
	-- Toggle states
	ToggleSlider = Color3.fromRGB(100, 100, 120),
	ToggleToggled = Color3.fromRGB(18, 20, 25),
	
	-- Text
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(160, 165, 185),
	
	-- Specific Components
	Tab = Color3.fromRGB(255, 255, 255),
	Dialog = Color3.fromRGB(15, 17, 24),
	DialogHolder = Color3.fromRGB(10, 11, 15),
	DialogBorder = Color3.fromRGB(40, 45, 55),
	DialogInput = Color3.fromRGB(25, 28, 38),
	DialogInputLine = Color3.fromRGB(40, 45, 60),
	
	-- TitleBar
	TitleBarLine = Color3.fromRGB(30, 35, 45),
}
