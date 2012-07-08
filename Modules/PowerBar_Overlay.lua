-- --------------------
-- TellMeWhen
-- Originally by Nephthys of Hyjal <lieandswell@yahoo.com>

-- Other contributions by:
--		Sweetmms of Blackrock, Oozebull of Twisting Nether, Oodyboo of Mug'thol,
--		Banjankri of Blackrock, Predeter of Proudmoore, Xenyr of Aszune

-- Currently maintained by
-- Cybeloras of Mal'Ganis
-- --------------------


if not TMW then return end

local TMW = TMW
local L = L
local print = TMW.print

local PowerBar_Overlay = TMW:NewClass("IconModule_PowerBar_Overlay", "IconModule_PowerBar")

function PowerBar_Overlay:SetupForIcon(sourceIcon)
	self.Invert = sourceIcon.InvertPBar
	self.Offset = sourceIcon.PBarOffs or 0
end

PowerBar_Overlay:RegisterIconDefaults{
	ShowPBar				= false,
	PBarOffs				= 0,
	InvertPBar				= false,
}

PowerBar_Overlay:RegisterConfigPanel_XMLTemplate("column", 3, "TellMeWhen_PBarOptions")

PowerBar_Overlay:RegisterUpgrade(51022, {
	icon = function(self, ics)
		ics.InvertPBar = not not ics.InvertBars
	end,
})

PowerBar_Overlay:SetIconEventListner("TMW_ICON_SETUP_POST", function(Module, icon)
	if TMW.Locked then
		Module:UpdateTable_Register()
		
		Module.bar:SetAlpha(.9)
	else
		Module:UpdateTable_Unregister()
		
		Module.bar:SetValue(Module.Max)
		Module.bar:SetAlpha(.6)
	end
end)