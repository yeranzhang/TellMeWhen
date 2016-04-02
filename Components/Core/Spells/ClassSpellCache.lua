﻿-- --------------------
-- TellMeWhen
-- Originally by Nephthys of Hyjal <lieandswell@yahoo.com>

-- Other contributions by:
--		Sweetmms of Blackrock, Oozebull of Twisting Nether, Oodyboo of Mug'thol,
--		Banjankri of Blackrock, Predeter of Proudmoore, Xenyr of Aszune

-- Currently maintained by
-- Cybeloras of Aerie Peak/Detheroc/Mal'Ganis
-- --------------------


if not TMW then return end

local TMW = TMW
local L = TMW.L
local print = TMW.print

local pairs, type, ipairs, bit, select = 
      pairs, type, ipairs, bit, select

local _, pclass = UnitClass("Player")


TMW:RegisterUpgrade(72013, {
	global = function()
		-- The class spell cache is no longer generated dynamically - too many problems with it
		-- (lacking many spells, sharing over comm is vulnerable to bad data, etc.)
		TMW.db.global.ClassSpellCache = nil
		TMW.db.global.XPac_ClassSpellCache = nil

		-- Also nil out some other unused, old SVs.
		TMW.db.global.XPac = nil
		TMW.db.global.XPac_AuraCache = nil
	end,
})

local ClassSpellCache = TMW:NewModule("ClassSpellCache", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")


local RaceMap = {
	[1] = "Human",
	[2] = "Orc",
	[3] = "Dwarf",
	[4] = "NightElf",
	[5] = "Scourge",
	[6] = "Tauren",
	[7] = "Gnome",
	[8] = "Troll",
	[9] = "Goblin",
	[10] = "BloodElf",
	[11] = "Draenei",
	[22] = "Worgen",
	[25] = "Pandaren",
	[26] = "Pandaren",
	[24] = "Pandaren",
}
local Cache = {
	[1] = {71,78,100,355,469,772,871,1160,1464,1680,1715,1719,2457,2565,3127,3411,5246,5308,6343,6544,6552,6572,6673,12292,12294,12323,12328,12712,12950,12975,13046,18499,20243,23588,23881,23920,23922,29144,29725,29838,34428,46915,46917,46924,46953,46968,55694,56636,57755,64382,76838,76856,76857,81099,84608,85288,86101,86110,86535,88163,97462,100130,103826,103827,103828,103840,107570,107574,114028,114029,114030,114192,115767,118000,118038,122509,123829,152276,152277,152278,156321,158298,158836,159362,161608,161798,163201,165365,165383,165393,167105,167188,169679,169680,169683,169685,174926,176289},
	[2] = {498,633,642,853,879,1022,1038,1044,2812,4987,6940,7328,10326,13819,19740,19750,20066,20154,20164,20165,20217,20271,20473,20925,23214,24275,25780,25956,26023,26573,31801,31821,31842,31850,31868,31884,31935,32223,34767,34769,35395,53376,53385,53503,53551,53563,53576,53592,53595,53600,62124,69820,69826,73629,73630,76669,76671,76672,82242,82326,82327,85043,85222,85256,85499,85673,85804,86102,86103,86172,86539,86659,87172,88821,96231,105361,105424,105593,105622,105805,105809,112859,114039,114154,114157,114158,114163,114165,115675,115750,119072,121783,123830,130552,136494,140333,148039,152261,152262,152263,156910,157007,157047,157048,158298,159374,161608,161800,165375,165380,165381,167187,171648},
	[3] = {136,781,883,982,1462,1494,1499,1515,1543,2641,2643,3044,3045,3674,5116,5118,5384,6197,6991,8737,13159,13809,13813,19263,19386,19387,19434,19506,19574,19577,19623,19801,19878,19879,19880,19882,19883,19884,19885,20736,34026,34477,34483,34954,35110,51753,53209,53253,53260,53270,53271,53301,53351,56315,56641,63458,76657,76658,76659,77767,77769,82692,83242,83243,83244,83245,87935,93321,93322,109212,109215,109248,109259,109260,109298,109304,109306,115939,117050,118675,120360,120679,121818,130392,131894,138430,147362,152244,152245,155228,157443,162534,163485,164856,165378,165389,165396,177667},
	[4] = {53,408,703,921,1329,1725,1752,1766,1776,1784,1804,1833,1856,1860,1943,1966,2094,2098,2823,2836,2983,3408,5171,5277,5938,6770,8676,8679,13750,13877,14062,14117,14161,14183,14185,14190,16511,26679,31209,31220,31223,31224,31230,32645,35551,36554,51667,51690,51701,51713,51723,57934,58423,61329,73651,74001,76577,76803,76806,76808,79008,79134,79140,79147,79152,82245,84601,84617,84654,91023,108208,108209,108210,108211,108212,108216,111240,113742,114014,114015,114018,121152,121411,121733,131511,137619,138106,152150,152151,152152,154904,157442,165390},
	[5] = {17,139,527,528,585,586,589,596,605,1706,2006,2060,2061,2096,2944,6346,8092,8122,9484,10060,14914,15286,15407,15473,15487,19236,20711,21562,32375,32379,32546,33076,33206,34433,34861,34914,45243,47515,47517,47536,47540,47585,47788,48045,49868,52798,62618,63733,64044,64129,64843,73325,73510,77484,77485,77486,78203,81206,81208,81209,81662,81700,81749,81782,87336,88625,88684,95649,95740,95860,95861,108920,108942,108945,109142,109175,109186,109964,110744,112833,120517,120644,121135,121536,122121,123040,126135,127632,129250,132157,139139,152116,152117,152118,155245,155246,155271,155361,162448,162452,165362,165370,165376},
	[6] = {674,3714,42650,43265,45462,45477,45524,45529,46584,47476,47528,47541,47568,48263,48265,48266,48707,48743,48792,48982,49020,49028,49039,49143,49184,49206,49222,49509,49530,49572,49576,49998,50029,50034,50041,50371,50385,50392,50842,50887,50977,51052,51128,51160,51271,51462,51986,53331,53342,53343,53344,53428,54447,54637,55078,55090,55095,55233,55610,56222,56835,57330,59057,61999,62158,63560,66192,77513,77514,77515,77575,77606,81127,81136,81164,81229,81333,82246,85948,86113,86524,86536,86537,91107,96268,108194,108196,108199,108200,108201,111673,114556,114866,115989,119975,123693,130735,130736,152279,152280,152281,155522,158298,161497,161608,161797,165394,165395,178819},
	[7] = {324,370,403,421,546,556,974,1064,1535,2008,2062,2484,2645,2825,2894,3599,5394,6196,8004,8042,8050,8056,8143,8177,8190,8737,10400,16166,16188,16196,16213,16282,17364,20608,29000,30814,30823,30884,32182,33757,36936,51485,51490,51505,51514,51522,51530,51533,51564,51886,52127,57994,58875,60103,60188,61295,61882,62099,63374,73680,73899,73920,77130,77223,77226,77472,77756,79206,86099,86100,86108,86529,86629,88766,95862,98008,108269,108270,108271,108273,108280,108281,108282,108283,108284,108285,108287,112858,114050,114051,114052,116956,117012,117013,117014,123099,147074,152255,152256,152257,157153,157154,157444,165368,165391,165399,165462,165477,165479,166221,170374},
	[8] = {10,66,116,118,120,122,130,133,475,1449,1459,1463,1953,2120,2136,2139,2948,3561,3562,3563,3565,3566,3567,5143,6117,7302,10059,11129,11366,11416,11417,11418,11419,11420,11426,11958,12042,12043,12051,12472,12846,12982,28271,28272,30449,30451,30455,30482,31589,31661,31687,32266,32267,32271,32272,33690,33691,35715,35717,42955,43987,44425,44457,44549,44572,44614,45438,49358,49359,49360,49361,53140,53142,55342,61305,61316,61721,61780,76547,76613,80353,84714,86949,88342,88344,88345,88346,102051,108839,108843,108853,108978,110959,111264,112948,112965,113724,114664,114923,116011,117216,117957,120145,120146,126819,132620,132621,132626,132627,140468,152087,153561,153595,153626,155147,155148,155149,157913,157976,157980,157981,157997,161353,161354,161355,161372,165357,165359,165360,176242,176244,176246,176248},
	[9] = {126,172,348,686,688,689,691,697,698,710,712,755,980,1098,1122,1454,1949,5484,5697,5740,5782,5784,6201,6353,6789,17877,17962,18540,20707,23161,27243,29722,29858,29893,30108,30146,30283,48018,48020,48181,74434,77215,77219,77220,80240,86121,93375,101976,103103,103958,104315,104773,105174,108359,108370,108371,108415,108416,108482,108499,108501,108503,108505,108508,108558,108647,108683,108869,109151,109773,109784,110913,111397,111400,111546,111771,113858,113860,113861,114592,114635,116858,117198,117896,119898,120451,122351,124913,137587,152107,152108,152109,157695,157696,165363,165367,165392,166928,171975,174848},
	[10] = {100780,100784,100787,101545,101546,101643,103985,107428,109132,113656,115008,115069,115070,115072,115074,115078,115080,115098,115151,115173,115174,115175,115176,115178,115180,115181,115203,115288,115294,115295,115308,115310,115313,115315,115396,115399,115450,115451,115460,115546,115636,115921,116092,116095,116645,116670,116680,116694,116705,116740,116781,116812,116841,116844,116847,116849,117906,117907,117952,117967,119381,119392,119582,119996,120224,120225,120227,120272,120277,121253,121278,121817,122278,122280,122470,122783,123766,123904,123980,123986,124081,124146,124502,124682,126060,126892,126895,128595,128938,137025,137384,137562,137639,139598,152173,152174,152175,154436,154555,157445,157533,157535,157675,157676,158298,161608,165379,165397,165398,166916,173841},
	[11] = {99,339,740,768,770,774,783,1079,1126,1822,1850,2782,2908,2912,5176,5185,5211,5215,5217,5221,5225,5487,6795,6807,8921,8936,16864,16870,16931,16961,16974,17007,17073,18562,18960,20484,22568,22570,22812,22842,24858,33605,33745,33763,33786,33831,33873,33891,33917,48438,48484,48500,48505,50769,52610,61336,62606,77492,77493,77495,77758,78674,78675,80313,85101,86093,86096,86097,86104,88423,88747,92364,93399,102280,102342,102351,102359,102401,102543,102558,102560,102693,102703,102706,102793,106707,106785,106830,106832,106839,106898,106952,108238,108291,108292,108293,108294,108299,108373,112071,112857,113043,114107,124974,125972,127663,131768,132158,132469,135288,137010,137011,137012,137013,145108,145205,145518,152220,152221,152222,155577,155578,155580,155672,155675,155783,155834,155835,157447,158298,158476,158477,158478,158497,158501,158504,159232,161608,164815,165372,165374,165386,165387,165962,166142,166163,171746,179333},
	["RACIAL"] = {[68992]=22,[7744]=5,[68996]=22,[121093]={11,528},[92680]=7,[143369]=26,[92682]=3,[59542]={11,2},[59543]={11,4},[59544]={11,16},[59545]={11,32},[59547]={11,64},[59548]={11,128},[87840]=22,[33697]={2,576},[6562]=11,[33702]={2,384},[69046]=9,[20592]=7,[20551]=6,[20594]=3,[69041]=9,[69042]=9,[69044]=9,[69045]=9,[822]=10,[155145]={10,2},[26297]=8,[28730]={10,400},[69179]={10,1},[129597]={10,512},[58943]=8,[107072]=24,[107073]=24,[107074]=24,[28875]=11,[107076]=24,[20549]=6,[20550]=6,[107079]={24,8},[20552]=6,[20555]=8,[20557]=8,[69070]=9,[28877]=10,[28880]={11,1},[154744]={7,520},[20579]=5,[59221]=11,[25046]={10,8},[20585]=4,[59224]=3,[143368]=25,[20572]={2,45},[20573]=2,[202719]={10,2048},[20577]=5,[80483]={10,4},[20582]=4,[20583]=4,[59752]=1,[50613]={10,32},[5227]=5,[20589]=7,[20591]={7,978},[68976]=22,[58984]=4,[68978]=22,[68975]=22,[20596]=3,[131701]=24,[154742]=10,[154743]=6,[20593]=7,[154747]={7,32},[154746]={7,1},[20599]=1,[154748]=4,[94293]=22,[20598]=1
	},
	["PET"] = {[50433]=3,[160003]=3,[30213]=9,[118345]=7,[160007]=3,[160044]=3,[160011]=3,[24844]=3,[91778]=6,[160014]=3,[160017]=3,[35346]=3,[118297]=7,[57984]=7,[24604]=3,[115232]=9,[54049]=9,[115746]=9,[115236]=9,[19505]=9,[3110]=9,[160039]=3,[57386]=3,[159788]=3,[160045]=3,[49966]=3,[7870]=9,[160049]=3,[126259]=3,[160052]=3,[160057]=3,[115770]=9,[160060]=3,[160063]=3,[160065]=3,[115778]=9,[94019]=3,[115268]=9,[115781]=9,[94022]=3,[17735]=9,[160073]=3,[160074]=3,[118347]=7,[115276]=9,[160077]=3,[118350]=7,[50256]=3,[117588]=7,[115408]=9,[50518]=3,[50519]=3,[2649]=3,[119899]=9,[126309]=3,[17767]=9,[16827]=3,[17253]=3,[126311]=3,[88680]=3,[24423]=3,[47468]=6,[160018]=3,[191336]=3,[157331]=7,[54644]=3,[36213]=7,[117225]=9,[47481]=6,[47482]=6,[19647]=9,[47484]=6,[157333]=7,[91776]=6,[170176]=9,[24450]=3,[173035]=3,[3716]=9,[7814]=9,[118337]=7,[93435]=3,[54680]=3,[160067]=3,[91797]=6,[89751]=9,[91800]=6,[65220]=3,[91802]=6,[126364]=3,[91809]=6,[157348]=7,[126373]=3,[89766]=9,[115625]=9,[62137]=6,[128432]=3,[128433]=3,[114355]=9,[159926]=3,[34889]=3,[126393]=3,[159931]=3,[91837]=6,[91838]=6,[157375]=7,[89792]=9,[137798]=3,[160452]=3,[90309]=3,[157382]=7,[30151]=9,[30153]=9,[115831]=9,[134477]=9,[26064]=3,[159953]=3,[159956]=3,[6358]=9,[93433]=3,[90328]=3,[115748]=9,[35290]=3,[92380]=3,[115578]=9,[6360]=9,[89808]=9,[90339]=3,[128997]=3,[32233]=9,[90347]=3,[58604]=3,[115284]=9,[90355]=3,[159988]=3,[159733]=3,[159735]=3,[159736]=3,[90361]=3,[90363]=3,[90364]=3,[112042]=9,[135678]=3
	}
}

local CacheIsReady = false

local PlayerSpells = {}
local ClassSpellLookup = {}
local NameCache


-- PUBLIC:

-- Contains a dictionary of spellIDs that are player spells.
function ClassSpellCache:GetSpellLookup()	
	if not CacheIsReady then
		error("The class spell cache hasn't been prepared yet.")
	end

	return ClassSpellLookup
end

-- Returns a dictionary of spellIDs that (should) belong to the current player.
function ClassSpellCache:GetPlayerSpells()
	if not next(PlayerSpells) then
		for k, v in pairs(Cache[pclass]) do
			PlayerSpells[k] = 1
		end
		for k, v in pairs(Cache.PET) do
			if v == pclass then
				PlayerSpells[k] = 1
			end
		end

		local _, race = UnitRace("player")


		for spellID, data in pairs(Cache.RACIAL) do
			if type(data) == "table" then
				-- There are class restrictions on the spell.
				local raceName = data[1]
				local classReq = data[2]
				if raceName == race then
					-- Verify that it is valid for this class.
					for classID = 1, MAX_CLASSES do
						local name, token = GetClassInfoByID(classID)
						if token == pclass and bit.band(bit.lshift(1, classID-1), classReq) > 0 then
							PlayerSpells[spellID] = 1
							break
						end
					end
				end

			elseif data == race then
				-- data is a race name
				-- There are no class restrictions on this spell.
				PlayerSpells[spellID] = 1
			end
		end
	end
	
	return PlayerSpells
end

--[[ Returns the main cache table. Structure:
Cache = {
	[classToken] = {
		[spellID] = 1,
	},
	PET = {
		[spellID] = classToken,
	},
	RACIAL = {
		[spellID] = raceName,
		[spellID2] = {raceName, classReq},
		-- classReq is a bitfield, with enabled bits representing classIDs that the racial is good for.
	},
}
]]
function ClassSpellCache:GetCache()
	if not CacheIsReady then
		error("The class spell cache hasn't been prepared yet.")
	end

	return Cache
end

--[[ Returns a mapping of spell names to spellIDs. Structure:
NameCache = {
	[classToken] = {
		[spellName] = true,
	},
}
]]
function ClassSpellCache:GetNameCache()
	if not CacheIsReady then
		error("The class spell cache hasn't been prepared yet.")
	end
	
	if not NameCache then
		NameCache = {}
		for class, spells in pairs(Cache) do
			if class ~= "RACIAL" and class ~= "PET" then
				local c = {}
				NameCache[class] = c
				for spellID, value in pairs(spells) do
					local name = GetSpellInfo(spellID)
					if name then
						c[name:lower()] = true
					end
				end
			end
		end
	end

	return NameCache
end

local function getRaceIconString(race)
	local coords = TMW:GetRaceIconCoords(race)
	return "|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-RACES:0:0:0:0:512:256:" ..
	coords[1]*512 .. ":" .. 
	coords[2]*512 .. ":" .. 
	coords[3]*256 .. ":" .. 
	coords[4]*256 .. "|t"

end
local function getClassIconString(classToken)
	return "|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:0:0:0:0:256:256:" ..
	(CLASS_ICON_TCOORDS[classToken][1]+.02)*256 .. ":" .. 
	(CLASS_ICON_TCOORDS[classToken][2]-.02)*256 .. ":" .. 
	(CLASS_ICON_TCOORDS[classToken][3]+.02)*256 .. ":" .. 
	(CLASS_ICON_TCOORDS[classToken][4]-.02)*256 .. "|t"
end

function GameTooltip:TMW_SetSpellByIDWithClassIcon(spellID)
	local ret = GameTooltip:SetSpellByID(spellID)

	local classToken = ClassSpellLookup[spellID]
	if classToken then
		local secondIcon = ""
		if classToken == "PET" then
			classToken = Cache.PET[spellID]
			local icon
			if classToken == "WARLOCK" then
				icon = "spell_shadow_metamorphosis"
			elseif classToken == "DEATHKNIGHT" then
				icon = "spell_deathknight_gnaw_ghoul"
			elseif classToken == "SHAMAN" then
				icon = "spell_fire_elemental_totem"
			else
				icon = "ability_hunter_mendpet"
			end
			secondIcon = " |TInterface\\Icons\\" .. icon .. ":0:0:0:0:32:32:2.24:29.76:2.24:29.76|t"
		elseif classToken == "RACIAL" then
			classToken = nil


			local data = Cache.RACIAL[spellID]
			if type(data) == "table" then
				-- There are class restrictions on the spell.
				local raceName = data[1]
				local classReq = data[2]

				secondIcon = getRaceIconString(raceName)

				-- Find the classes that it is valid for.
				for classID = 1, MAX_CLASSES do
					local name, token = GetClassInfoByID(classID)
					if bit.band(bit.lshift(1, classID-1), classReq) > 0 then
						secondIcon = secondIcon .. " " .. getClassIconString(token)
					end
				end

			else
				-- There are no class restriction on the spell.
				-- data is a race name
				secondIcon = getRaceIconString(data)
			end
		end

		local classIcon = classToken and getClassIconString(classToken) or ""

		GameTooltipTextLeft1:SetText( 
		classIcon ..
		secondIcon .. " " ..
		GameTooltipTextLeft1:GetText())
	end

	return ret
end

-- END PUBLIC





-- PRIVATE:

function ClassSpellCache:TMW_DB_INITIALIZED()
	
	for classID, spellList in ipairs(Cache) do
		local name, token, classID = GetClassInfoByID(classID)

		local spellDict = {}
		for k, v in pairs(spellList) do
			spellDict[v] = true
		end

		Cache[token] = spellDict
		Cache[classID] = nil
	end

	for spellID, classID in pairs(Cache.PET) do
		Cache.PET[spellID] = select(2, GetClassInfoByID(classID))
	end

	for spellID, data in pairs(Cache.RACIAL) do
		if type(data) == "table" then
			local raceID = data[1]
			local classReq = data[2]
			data[1] = RaceMap[raceID]
		else
			-- data is a raceID.
			Cache.RACIAL[spellID] = RaceMap[data]
		end
	end
	
	-- Adds a spell's texture to the texture cache by name
	-- so that we can get textures by spell name much more frequently,
	-- reducing the usage of question mark and pocketwatch icons.
	local function AddID(id)
		if id > 0x7FFFFFFF then
			return
		end
		local name, _, tex = GetSpellInfo(id)
		name = TMW.strlowerCache[name]
		if name and not TMW.SpellTexturesMetaIndex[name] then
			TMW.SpellTexturesMetaIndex[name] = tex
		end
	end
	
	-- Spells of the user's class should be prioritized.
	for id in pairs(Cache[pclass]) do
		AddID(id)
	end
	
	-- Next comes spells of all other classes.
	for class, tbl in pairs(Cache) do
		if class ~= pclass and class ~= "PET" then
			for id in pairs(tbl) do
				AddID(id)
			end
		end
	end

	-- Pets are last because there are some overlapping names with class spells
	-- and we don't want to overwrite the textures for class spells with ones for pet spells.
	for id in pairs(Cache.PET) do
		AddID(id)
	end
	
	for class, tbl in pairs(Cache) do
		for id in pairs(tbl) do
			ClassSpellLookup[id] = class
		end
	end

	CacheIsReady = true
end
TMW:RegisterRunonceCallback("TMW_DB_INITIALIZED", ClassSpellCache)


-- END PRIVATE
