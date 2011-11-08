﻿-- --------------------
-- TellMeWhen
-- Originally by Nephthys of Hyjal <lieandswell@yahoo.com>

-- Other contributions by
-- Sweetmms of Blackrock
-- Oozebull of Twisting Nether
-- Oodyboo of Mug'thol
-- Banjankri of Blackrock
-- Predeter of Proudmoore
-- Xenyr of Aszune

-- Currently maintained by
-- Cybeloras of Mal'Ganis
-- --------------------

local TMW = TMW
if not TMW then return end
local L = TMW.L

local db, UPD_INTV, ClockGCD, rc, mc, pr, ab
local GetSpellCooldown, IsSpellInRange, IsUsableSpell =
	  GetSpellCooldown, IsSpellInRange, IsUsableSpell
local GetActionCooldown, IsActionInRange, IsUsableAction, GetActionTexture, GetActionInfo =
	  GetActionCooldown, IsActionInRange, IsUsableAction, GetActionTexture, GetActionInfo
local UnitRangedDamage  =
	  UnitRangedDamage
local pairs =
	  pairs
local OnGCD = TMW.OnGCD
local print = TMW.print
local _, pclass = UnitClass("Player")
local SpellTextures = TMW.SpellTextures

local Type = {}
LibStub("AceEvent-3.0"):Embed(Type)
Type.type = "multistate"
Type.name = L["ICONMENU_MULTISTATECD"]
Type.desc = L["ICONMENU_MULTISTATECD_DESC"]
Type.SUGType = "multistate"
Type.chooseNameTitle = L["ICONMENU_CHOOSENAME_MULTISTATE"]
Type.chooseNameText = L["CHOOSENAME_DIALOG_MSCD"]
Type.WhenChecks = {
	text = L["ICONMENU_SHOWWHEN"],
	{ value = "alpha", 			text = L["ICONMENU_USABLE"], 			colorCode = "|cFF00FF00" },
	{ value = "unalpha",  		text = L["ICONMENU_UNUSABLE"], 			colorCode = "|cFFFF0000" },
	{ value = "always", 		text = L["ICONMENU_ALWAYS"] },
}
Type.RelevantSettings = {
	RangeCheck = true,
	ManaCheck = true,
	ShowPBar = true,
	PBarOffs = true,
	ShowCBar = true,
	CBarOffs = true,
	InvertBars = true,
	DurationMin = true,
	DurationMax = true,
	DurationMinEnabled = true,
	DurationMaxEnabled = true,
}
Type.DisabledEvents = {
	OnUnit = true,
}


function Type:Update()
	db = TMW.db
	UPD_INTV = db.profile.Interval
	ClockGCD = db.profile.ClockGCD
	rc = db.profile.OORColor
	mc = db.profile.OOMColor
	pr = db.profile.PRESENTColor
	ab = db.profile.ABSENTColor
end


local function MultiStateCD_OnEvent(icon)
	local actionType, spellID = GetActionInfo(icon.Slot) -- check the current slot first, because it probably didnt change
	if actionType == "spell" and spellID == icon.NameFirst then
		return
	end
	for i=1, 120 do
		local actionType, spellID = GetActionInfo(i)
		if actionType == "spell" and spellID == icon.NameFirst then
			icon.Slot = i
			return
		end
	end
end

local function MultiStateCD_OnUpdate(icon, time)
	if icon.LastUpdate <= time - UPD_INTV then
		icon.LastUpdate = time
		local CndtCheck = icon.CndtCheck if CndtCheck and CndtCheck() then return end

		local Slot = icon.Slot
		local start, duration = GetActionCooldown(Slot)
		if duration then

			local inrange, nomana = 1

			if icon.RangeCheck then
				inrange = IsActionInRange(Slot, "target") or 1
			end
			if icon.ManaCheck then
				_, nomana = IsUsableAction(Slot)
			end


			local alpha, color
			if (duration == 0 or OnGCD(duration)) and inrange == 1 and not nomana then
				alpha, color = icon.Alpha, 1
			elseif icon.Alpha ~= 0 then
				if inrange ~= 1 then
					alpha, color = icon.UnAlpha*rc.a, rc
				elseif nomana then
					alpha, color = icon.UnAlpha*mc.a, mc
				elseif not icon.ShowTimer then
					alpha, color = icon.UnAlpha, 0.5
				else
					alpha, color = icon.UnAlpha, 1
				end
			else
				alpha, color = icon.UnAlpha, 1
			end
			
			local actionType, spellID = GetActionInfo(Slot)
			spellID = actionType == "spell" and spellID or icon.NameFirst
			
			
			--icon:SetInfo(alpha, color, texture, start, duration, spellChecked, reverse, count, countText, forceupdate, unit)
			icon:SetInfo(alpha, color, GetActionTexture(Slot) or "Interface\\Icons\\INV_Misc_QuestionMark", start, duration, spellID, nil, nil, nil, nil, nil)
		end
	end
end


function Type:Setup(icon, groupID, iconID)
	icon.NameFirst = TMW:GetSpellNames(icon, icon.Name, 1)

	if icon.NameFirst and icon.NameFirst ~= "" and GetSpellLink(icon.NameFirst) and not tonumber(icon.NameFirst) then
		icon.NameFirst = tonumber(strmatch(GetSpellLink(icon.NameFirst), ":(%d+)")) -- extract the spellID from the link
	end
	
	icon.Slot = 0
	MultiStateCD_OnEvent(icon)
	
	if icon:IsBeingEdited() == 1 then
		if doWarn then
			TMW.HELP:Show("ICON_DR_MISMATCH", icon, TMW.IE.Main.Name, 0, 0, L["WARN_DRMISMATCH"]..append)
		else
			TMW.HELP:Hide("ICON_DR_MISMATCH")
		end
	end

	icon:SetTexture(GetActionTexture(icon.Slot) or "Interface\\Icons\\INV_Misc_QuestionMark")

	icon:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	icon:SetScript("OnEvent", MultiStateCD_OnEvent)

	icon:SetScript("OnUpdate", MultiStateCD_OnUpdate)
	icon:OnUpdate(TMW.time)
end


TMW:RegisterIconType(Type)




