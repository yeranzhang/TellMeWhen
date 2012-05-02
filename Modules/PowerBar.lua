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
local LSM = LibStub("LibSharedMedia-3.0")
local _, pclass = UnitClass("Player")
local GetSpellInfo, UnitPower =
	  GetSpellInfo, UnitPower
local pairs, wipe, _G =
	  pairs, wipe, _G
local PowerBarColor = PowerBarColor
local tContains = TMW.tContains

local defaultPowerTypes = {
	ROGUE		= SPELL_POWER_ENERGY,
	PRIEST		= SPELL_POWER_MANA,
	DRUID		= SPELL_POWER_MANA,
	WARRIOR		= SPELL_POWER_RAGE,
	MAGE		= SPELL_POWER_MANA,
	WARLOCK		= SPELL_POWER_MANA,
	PALADIN		= SPELL_POWER_MANA,
	SHAMAN		= SPELL_POWER_MANA,
	HUNTER		= SPELL_POWER_FOCUS,
	DEATHKNIGHT = SPELL_POWER_RUNIC_POWER,
}
local defaultPowerType = defaultPowerTypes[pclass]

local PBarsToUpdate = {}

local PowerBar = TMW:NewClass("IconModule_PowerBar", "IconModule", "UpdateTableManager", "AceEvent-3.0", "AceTimer-3.0")
PowerBar:UpdateTable_Set(PBarsToUpdate)

function PowerBar:OnNewInstance(icon)
	local bar = CreateFrame("StatusBar", nil, icon)
	self.bar = bar
	
	self.texture = bar:CreateTexture(nil, "OVERLAY")
	self.texture:SetAllPoints()
	bar:SetStatusBarTexture(self.texture)
	
	local colorinfo = PowerBarColor[defaultPowerType]
	bar:SetStatusBarColor(colorinfo.r, colorinfo.g, colorinfo.b, 0.9)
	self.powerType = defaultPowerType
	
	self.Max = 1
	bar:SetMinMaxValues(0, self.Max)
	
	self.PBarOffs = 0
end

function PowerBar:OnEnable()
	self.bar:Show()
	self.texture:SetTexture(LSM:Fetch("statusbar", TMW.db.profile.TextureName))
	
	local icon = self.icon
	local attributes = icon.attributes
	self:SPELL(icon, attributes.spell)
end
function PowerBar:OnDisable()
	self.bar:Hide()
	self:UpdateTable_Unregister()
end

function PowerBar:OnUsed()
	PowerBar:RegisterEvent("SPELL_UPDATE_USABLE")
	PowerBar:RegisterEvent("UNIT_POWER_FREQUENT")
end
function PowerBar:OnUnused()
	PowerBar:UnregisterEvent("SPELL_UPDATE_USABLE")
	PowerBar:UnregisterEvent("UNIT_POWER_FREQUENT")
end


function PowerBar:SetupForIcon(sourceIcon)
	self.InvertBars = sourceIcon.InvertBars
	self.Offset = sourceIcon.PBarOffs or 0
end

function PowerBar:SetSpell(spell)
	local bar = self.bar
	self.spell = spell
	
	if spell then
		self:UpdateCost()

		self:UpdateTable_Register()
		
		self:Update()
	elseif tContains(self.UpdateTable_UpdateTable, self) then
		local value = self.InvertBars and self.Max or 0
		bar:SetValue(value)
		self.__value = value
		
		self:UpdateTable_Unregister()
	end
end

function PowerBar:UpdateCost()
	local bar = self.bar
	local spell = self.spell
	
	if spell then
		local _, _, _, cost, _, powerType = GetSpellInfo(spell)
		
		cost = powerType == 9 and 3 or cost or 0 -- holy power hack: always use a max of 3
		self.Max = cost
		bar:SetMinMaxValues(0, cost)
		self.__value = nil -- the displayed value might change when we change the max, so force an update
		
		powerType = powerType or defaultPowerType
		if powerType ~= self.powerType then
			local colorinfo = PowerBarColor[powerType]
			bar:SetStatusBarColor(colorinfo.r, colorinfo.g, colorinfo.b, 0.9)
			self.powerType = powerType
		end
	end
end

function PowerBar:Update(power, powerTypeNum)
	local bar = self.bar
	if not powerTypeNum then
		powerTypeNum = self.powerType
		power = UnitPower("player", powerTypeNum)
	end
	
	if powerTypeNum == self.powerType then
	
		local Max = self.Max
		local value

		if not self.InvertBars then
			value = Max - power + self.PBarOffs
		else
			value = power + self.PBarOffs
		end

		if value > Max then
			value = Max
		elseif value < 0 then
			value = 0
		end

		if self.__value ~= value then
			bar:SetValue(value)
			self.__value = value
		end
	end
end


function PowerBar:SPELL_UPDATE_USABLE()
	if TMW.Locked then
		for i = 1, #PBarsToUpdate do
			local Module = PBarsToUpdate[i]
			Module:UpdateCost()
		end
	end
end

function PowerBar:UNIT_POWER_FREQUENT(event, unit, powerType)
	if unit == "player" then
		local powerTypeNum = powerType and _G["SPELL_POWER_" .. powerType]
		local power = powerTypeNum and UnitPower("player", powerTypeNum)
		
		for i = 1, #PBarsToUpdate do
			local Module = PBarsToUpdate[i]
			Module:Update(power, powerTypeNum)
		end
	end
end


function PowerBar:SPELL(icon, spellChecked)
	self:SetSpell(spellChecked)
end
PowerBar:SetDataListner("SPELL")
	
PowerBar:SetIconEventListner("TMW_ICON_SETUP_POST", function(Module, icon)
	if TMW.Locked then
		Module:UpdateTable_Register()
		
		Module.bar:SetAlpha(.9)
	else
		Module:UpdateTable_Unregister()
		
		Module.bar:SetValue(Module.Max)
		Module.bar:SetAlpha(.6)
	end
end)


TMW:RegisterCallback("TMW_LOCK_TOGGLED", function(event, Locked)
	if not Locked then
		PowerBar:UpdateTable_UnregisterAll()
	end
end)
