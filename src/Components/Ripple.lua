-- Ripple Effect Component
-- Clean flash feedback using parent's own transparency — no child frames needed

local TweenService = game:GetService("TweenService")

local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local Ripple = {}

function Ripple.Create(Parent, Color)
	local function DoRipple()
		if not Parent or not Parent.Parent then return end

		-- Flash the parent's own background briefly
		local originalTransparency = Parent.BackgroundTransparency
		local flashTarget = math.max(originalTransparency - 0.15, 0)

		Parent.BackgroundTransparency = flashTarget
		TweenService:Create(
			Parent,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = originalTransparency }
		):Play()
	end

	-- Connect to mouse click
	if Parent:IsA("GuiButton") then
		Creator.AddSignal(Parent.MouseButton1Down, function()
			DoRipple()
		end)
	end

	return {
		Fire = DoRipple,
	}
end

return Ripple
