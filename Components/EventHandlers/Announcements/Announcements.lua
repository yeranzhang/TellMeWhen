﻿-- --------------------
-- TellMeWhen
-- Originally by Nephthys of Hyjal <lieandswell@yahoo.com>

-- Other contributions by:
--		Sweetmms of Blackrock, Oozebull of Twisting Nether, Oodyboo of Mug'thol,
--		Banjankri of Blackrock, Predeter of Proudmoore, Xenyr of Aszune

-- Currently maintained by
-- Cybeloras of Detheroc/Mal'Ganis
-- --------------------


if not TMW then return end

local TMW = TMW
local L = TMW.L
local print = TMW.print
local strlowerCache = TMW.strlowerCache

local huge = math.huge

local _G = _G
local assert, pairs, ipairs, sort, tinsert, wipe, select =
	  assert, pairs, ipairs, sort, tinsert, wipe, select
	  
local SendChatMessage, GetChannelList =
      SendChatMessage, GetChannelList
local UnitInBattleground, IsInRaid, IsInGroup =
      UnitInBattleground, IsInRaid, IsInGroup
local UnitInRaid, GetNumPartyMembers =
      UnitInRaid, GetNumPartyMembers
	  
-- GLOBALS: UIDROPDOWNMENU_MENU_LEVEL, UIDropDownMenu_AddButton, UIDropDownMenu_CreateInfo

local DogTag = LibStub("LibDogTag-3.0", true)


local ANN = TMW.Classes.EventHandler:New("Announcements")
TMW.ANN = ANN

ANN.kwargs = {}
ANN.AllChannelsByChannel = {}
ANN.AllChannelsOrdered = {}

ANN:RegisterEventDefaults{
	Text 	  		= "",
	Channel			= "",
	Location  		= "",
	Sticky 	  		= false,
	ShowIconTex		= true,
	r 		  		= 1,
	g 		  		= 1,
	b 		  		= 1,
	Size 	  		= 0,
}

TMW:RegisterUpgrade(60312, {
	iconEventHandler = function(self, eventSettings)
		if eventSettings.Channel == "FRAME" and eventSettings.Location == "RaidWarningFrame" then
			eventSettings.Channel = "RAID_WARNING_FAKE"
			eventSettings.Location = ""
		end
	end,
})

TMW:RegisterUpgrade(60014, {
	-- I just discovered that announcements use a boolean "Icon" event setting for the "Show icon texture" setting
	-- that conflicts with another event setting. Try to salvage what we can.
	iconEventHandler = function(self, eventSettings)
		if type(eventSettings.Icon) == "boolean" then
			eventSettings.ShowIconTex = eventSettings.Icon
		end
	end,
})

TMW:RegisterUpgrade(51002, {
	-- This is the upgrade that handles the transition from TMW's ghetto text substitutions to DogTag.
	
	-- self.translateString is a function defined in the v51002 upgrade in TellMeWhen.lua.
	-- It is the method that actually converts between the old and new text subs.
	
	-- This upgrade extends this upgrade to announcements and whisper locations
	
	iconEventHandler = function(self, eventSettings)
		eventSettings.Text = self:translateString(eventSettings.Text)
		if eventSettings.Channel == "WHISPER" then
			eventSettings.Location = self:translateString(eventSettings.Location)
		end
	end,
})

TMW:RegisterUpgrade(43009, {
	iconEventHandler = function(self, eventSettings)
		if eventSettings.Location == "FRAME1" then
			eventSettings.Location = 1
		elseif eventSettings.Location == "FRAME2" then
			eventSettings.Location = 2
		elseif eventSettings.Location == "MSG" then
			eventSettings.Location = 10
		end
	end,
})

TMW:RegisterUpgrade(43005, {
	icon = function(self, ics)
		-- whoops, forgot to to this a while back when ANN was replaced with the new event data structure
		-- (really really old sctructure as of 8-8-12, just putting this here with the rest of the announcement stuff.)
		ics.ANN = nil
	end,
})

TMW:RegisterUpgrade(42103, {
	iconEventHandler = function(self, eventSettings)
		if eventSettings.Announce then
			eventSettings.Text, eventSettings.Channel = strsplit("\001", eventSettings.Announce)
			eventSettings.Announce = nil
		end
	end,
})

TMW:RegisterUpgrade(42102, {
	icon = function(self, ics)
		local Events = ics.Events
		Events.OnShow.Announce = ics.ANNOnShow or "\001"

		Events.OnHide.Announce = ics.ANNOnHide or "\001"

		Events.OnStart.Announce = ics.ANNOnStart or "\001"

		Events.OnFinish.Announce = ics.ANNOnFinish or "\001"
		
		ics.ANNOnShow		= nil
		ics.ANNOnHide		= nil
		ics.ANNOnStart		= nil
		ics.ANNOnFinish		= nil
	end,
})


function ANN:ProcessIconEventSettings(event, eventSettings)
	if eventSettings.Channel ~= "" then
		return true
	end
end

function ANN:HandleEvent(icon, eventSettings)
	local Channel = eventSettings.Channel
	if Channel ~= "" then
		local Text = eventSettings.Text
		local chandata = self.AllChannelsByChannel[Channel]

		if not chandata then
			return
		end

		wipe(ANN.kwargs)
		ANN.kwargs.icon = icon.ID
		ANN.kwargs.group = icon.group.ID
		ANN.kwargs.unit = icon.attributes.dogTagUnit
		ANN.kwargs.link = true
		--ANN.kwargs.shouldcolor = not chandata.isBlizz and TMW.db.profile.ColorNames

		if chandata.handler then
			Text = DogTag:Evaluate(Text, "TMW;Unit", ANN.kwargs)
			if Text then
				-- DogTag returns nil if the result is an empty string.
				chandata.handler(icon, eventSettings, Text)
			end
		elseif Text and chandata.isBlizz then
			local Location = eventSettings.Location
			Text = Text:gsub("Name([^F])", "NameForceUncolored%1")
			Text = DogTag:Evaluate(Text, "TMW;Unit", ANN.kwargs)
			if Channel == "WHISPER" then
				wipe(ANN.kwargs)
				ANN.kwargs.icon = icon.ID
				ANN.kwargs.group = icon.group.ID
				ANN.kwargs.unit = icon.attributes.dogTagUnit
				ANN.kwargs.link = false
				--ANN.kwargs.shouldcolor = false
				Location = DogTag:Evaluate(Location, "TMW;Unit", ANN.kwargs)
				Location = Location:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") -- strip color codes
			end
			SendChatMessage(Text, Channel, nil, Location)
		end

		return true
	end
end


function ANN:OnRegisterEventHandlerDataTable(eventHandlerData, order, channel, channelData)
	TMW:ValidateType("2 (order)", '[RegisterEventHandlerData - Announcements](order, channel, channelData)', order, "number")
	TMW:ValidateType("3 (channel)", '[RegisterEventHandlerData - Announcements](order, channel, channelData)', channel, "string")
	TMW:ValidateType("4 (channelData)", '[RegisterEventHandlerData - Announcements](order, channel, channelData)', channelData, "table")
	
	assert(not ANN.AllChannelsByChannel[channel], ("A channel %q is already registered!"):format(channel))
	
	channelData.order = order
	channelData.channel = channel
	
	eventHandlerData.channel = channel
	eventHandlerData.channelData = channelData
	
	ANN.AllChannelsByChannel[channel] = channelData
	
	tinsert(ANN.AllChannelsOrdered,channelData)
	TMW:SortOrderedTables(ANN.AllChannelsOrdered)
end

ANN:RegisterEventHandlerDataNonSpecific(0, "", {
	text = NONE,
})
ANN:RegisterEventHandlerDataNonSpecific(10, "SAY", {
	text = CHAT_MSG_SAY,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(12, "YELL", {
	text = CHAT_MSG_YELL,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(14, "WHISPER", {
	text = WHISPER,
	isBlizz = 1,
	editbox = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(16, "PARTY", {
	text = CHAT_MSG_PARTY,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(20, "RAID", {
	text = CHAT_MSG_RAID,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(22, "RAID_WARNING", {
	text = CHAT_MSG_RAID_WARNING,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(24, "BATTLEGROUND", {
	text = CHAT_MSG_BATTLEGROUND,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(30, "SMART", {
	text = L["CHAT_MSG_SMART"],
	desc = L["CHAT_MSG_SMART_DESC"],
	isBlizz = 1, -- flagged to not use override %t and %f substitutions, and also not to try and color any names
	handler =
	TMW.ISMOP and
		function(icon, data, Text)
			local channel = "SAY"
			if UnitInBattleground("player") then
				channel = "BATTLEGROUND"
			elseif IsInRaid() then
				channel = "RAID"
			elseif IsInGroup() then
				channel = "PARTY"
			end
			SendChatMessage(Text, channel)
		end
	or
		function(icon, data, Text)
			local channel = "SAY"
			if UnitInBattleground("player") then
				channel = "BATTLEGROUND"
			elseif UnitInRaid("player") then
				channel = "RAID"
			elseif GetNumPartyMembers() > 1 then
				channel = "PARTY"
			end
			SendChatMessage(Text, channel)
		end
	,
})
ANN:RegisterEventHandlerDataNonSpecific(40, "CHANNEL", {
	text = L["CHAT_MSG_CHANNEL"],
	desc = L["CHAT_MSG_CHANNEL_DESC"],
	isBlizz = 1, -- flagged to not use override %t and %f substitutions, and also not to try and color any names
	defaultlocation = function() return select(2, GetChannelList()) end,
	dropdown = function()
		for i = 1, huge, 2 do
			local num, name = select(i, GetChannelList())
			if not num then break end

			local info = UIDropDownMenu_CreateInfo()
			info.func = TMW.ANN.Location_DropDown_OnClick
			info.text = name
			info.arg1 = name
			info.value = name
			info.checked = name == TMW.ANN:GetEventSettings().Location
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
		end
	end,
	ddtext = function(value)
		-- also a verification function
		for i = 1, huge, 2 do
			local num, name = select(i, GetChannelList())
			if not num then return end

			if name == value then
				return value
			end
		end
	end,
	handler = function(icon, data, Text)
		for i = 1, huge, 2 do
			local num, name = select(i, GetChannelList())
			if not num then break end
			if strlowerCache[name] == strlowerCache[data.Location] then
				SendChatMessage(Text, data.Channel, nil, num)
				break
			end
		end
	end,
})
ANN:RegisterEventHandlerDataNonSpecific(50, "GUILD", {
	text = CHAT_MSG_GUILD,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(52, "OFFICER", {
	text = CHAT_MSG_OFFICER,
	isBlizz = 1,
})
ANN:RegisterEventHandlerDataNonSpecific(60, "EMOTE", {
	text = CHAT_MSG_EMOTE,
	isBlizz = 1,
})

ANN:RegisterEventHandlerDataNonSpecific(70, "FRAME", {
	-- GLOBALS: DEFAULT_CHAT_FRAME, FCF_GetChatWindowInfo
	text = L["CHAT_FRAME"],
	icon = 1,
	color = 1,
	defaultlocation = function() return DEFAULT_CHAT_FRAME.name end,
	dropdown = function()
		local i = 1
		while _G["ChatFrame"..i] do
			local _, _, _, _, _, _, shown, _, docked = FCF_GetChatWindowInfo(i);
			if shown or docked then
				local name = _G["ChatFrame"..i].name
				local info = UIDropDownMenu_CreateInfo()
				info.func = TMW.ANN.Location_DropDown_OnClick
				info.text = name
				info.arg1 = name
				info.value = name
				info.checked = name == TMW.ANN:GetEventSettings().Location
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
			end
			i = i + 1
		end
	end,
	ddtext = function(value)
		local i = 1
		while _G["ChatFrame"..i] do
			if _G["ChatFrame"..i].name == value then
				return value
			end
			i = i + 1
		end
	end,
	handler = function(icon, data, Text)
		local Location = data.Location

		if data.ShowIconTex then
			Text = "|T" .. (icon.attributes.texture or "") .. ":0|t " .. Text
		end

		local i = 1
		while _G["ChatFrame"..i] do
			local frame = _G["ChatFrame"..i]
			if Location == frame.name then
				frame:AddMessage(Text, data.r, data.g, data.b, 1)
				break
			end
			i = i+1
		end
	end,
})

local bullshitTable = {}
ANN:RegisterEventHandlerDataNonSpecific(71, "RAID_WARNING_FAKE", {
	text = L["RAID_WARNING_FAKE"],
	desc = L["RAID_WARNING_FAKE_DESC"],
	icon = 1,
	color = 1,
	handler = function(icon, data, Text)
		local Location = data.Location

		if data.ShowIconTex then
			Text = "|T" .. (icon.attributes.texture or "") .. ":0|t " .. Text
		end

		-- GLOBALS: RaidWarningFrame, RaidNotice_AddMessage
		
		-- workaround: blizzard's code doesnt manage colors correctly when there are 2 messages being displayed with different colors.
		Text = ("|cff%02x%02x%02x"):format(data.r * 0xFF, data.g * 0xFF, data.b * 0xFF) .. Text .. "|r"

		RaidNotice_AddMessage(RaidWarningFrame, Text, bullshitTable) -- arg3 still demands a valid table for the color info, even if it is empty
		
	end,
})

local bullshitTable = {}
ANN:RegisterEventHandlerDataNonSpecific(72, "ERRORS_FRAME", {
	text = L["ERRORS_FRAME"],
	desc = L["ERRORS_FRAME_DESC"],
	icon = 1,
	color = 1,
	handler = function(icon, data, Text)
		if data.ShowIconTex then
			Text = "|T" .. (icon.attributes.texture or "") .. ":0|t " .. Text
		end

		-- GLOBALS: UIErrorsFrame
		UIErrorsFrame:AddMessage(Text, data.r, data.g, data.b, 1)
	end,
})

local sctcolor = {r=1, b=1, g=1}
ANN:RegisterEventHandlerDataNonSpecific(81, "SCT", {
	-- GLOBALS: SCT
	text = "Scrolling Combat Text",
	hidden = not (SCT and SCT:IsEnabled()),
	sticky = 1,
	icon = 1,
	color = 1,
	defaultlocation = SCT and SCT.FRAME1,
	frames = SCT and {
		[SCT.FRAME1] = "Frame 1",
		[SCT.FRAME2] = "Frame 2",
		[SCT.FRAME3 or SCT.MSG] = "SCTD", -- cheesy, i know
		[SCT.MSG] = "Messages",
	},
	dropdown = function()
		if not SCT then return end
		for id, name in pairs(ANN.AllChannelsByChannel.SCT.frames) do
			local info = UIDropDownMenu_CreateInfo()
			info.func = TMW.ANN.Location_DropDown_OnClick
			info.text = name
			info.arg1 = info.text
			info.value = id
			info.checked = id == TMW.ANN:GetEventSettings().Location
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
		end
	end,
	ddtext = function(value)
		if not SCT then return end
		return ANN.AllChannelsByChannel.SCT.frames[value]
	end,
	handler = function(icon, data, Text)
		if SCT then
			sctcolor.r, sctcolor.g, sctcolor.b = data.r, data.g, data.b
			SCT:DisplayCustomEvent(Text, sctcolor, data.Sticky, data.Location, nil, data.ShowIconTex and icon.attributes.texture)
		end
	end,
})

ANN:RegisterEventHandlerDataNonSpecific(83, "MSBT", {
	-- GLOBALS: MikSBT
	text = "MikSBT",
	hidden = not MikSBT,
	sticky = 1,
	icon = 1,
	color = 1,
	size = 1,
	defaultlocation = "Notification",
	dropdown = function()
		for scrollAreaKey, scrollAreaName in MikSBT:IterateScrollAreas() do
			local info = UIDropDownMenu_CreateInfo()
			info.text = scrollAreaName
			info.value = scrollAreaKey
			info.checked = scrollAreaKey == TMW.ANN:GetEventSettings().Location
			info.func = TMW.ANN.Location_DropDown_OnClick
			info.arg1 = scrollAreaName
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
		end
	end,
	ddtext = function(value)
		if value then
			return MikSBT and select(2, MikSBT:IterateScrollAreas())[value]
		end
	end,
	handler = function(icon, data, Text)
		if MikSBT then
			local Size = data.Size
			if Size == 0 then Size = nil end
			MikSBT.DisplayMessage(Text, data.Location, data.Sticky, data.r*0xFF, data.g*0xFF, data.b*0xFF, Size, nil, nil, data.ShowIconTex and icon.attributes.texture)
		end
	end,
})
ANN:RegisterEventHandlerDataNonSpecific(85, "PARROT", {
	-- GLOBALS: Parrot
	text = "Parrot",
	hidden = not (Parrot and ((Parrot.IsEnabled and Parrot:IsEnabled()) or Parrot:IsActive())),
	sticky = 1,
	icon = 1,
	color = 1,
	size = 1,
	defaultlocation = "Notification",
	dropdown = function()
		local areas = Parrot.GetScrollAreasChoices and Parrot:GetScrollAreasChoices() or Parrot:GetScrollAreasValidate()
		for k, n in pairs(areas) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = n
			info.value = k
			info.func = TMW.ANN.Location_DropDown_OnClick
			info.arg1 = n
			info.checked = k == TMW.ANN:GetEventSettings().Location
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
		end
	end,
	ddtext = function(value)
		if value then
			return (Parrot.GetScrollAreasChoices and Parrot:GetScrollAreasChoices() or Parrot:GetScrollAreasValidate())[value]
		end
	end,
	handler = function(icon, data, Text)
		if Parrot then
			local Size = data.Size
			if Size == 0 then Size = nil end
			Parrot:ShowMessage(Text, data.Location, data.Sticky, data.r, data.g, data.b, nil, Size, nil, data.ShowIconTex and icon.attributes.texture)
		end
	end,
})
ANN:RegisterEventHandlerDataNonSpecific(88, "FCT", {
	-- GLOBALS: CombatText_AddMessage, CombatText_StandardScroll, SHOW_COMBAT_TEXT
	text = COMBAT_TEXT_LABEL,
	desc = L["ANN_FCT_DESC"],
	sticky = 1,
	icon = 1,
	color = 1,
	handler = function(icon, data, Text)
		if data.ShowIconTex then
			Text = "|T" .. (icon.attributes.texture or "") .. ":20:20:-5|t " .. Text
		end
		if SHOW_COMBAT_TEXT ~= "0" then
			if not CombatText_AddMessage then
				-- GLOBALS: UIParentLoadAddOn
				UIParentLoadAddOn("Blizzard_CombatText")
			end
			CombatText_AddMessage(Text, CombatText_StandardScroll, data.r, data.g, data.b, data.Sticky and "crit" or nil, false)
		end
	end,
})
