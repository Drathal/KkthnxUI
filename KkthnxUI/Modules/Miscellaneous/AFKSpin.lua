local K, C, L = unpack(select(2, ...))
if C.Misc.AFKCamera ~= true then return end

-- WoW Lua
local _G = _G
local math_floor = math.floor
local math_pi = math.pi
local math_random = math.random
local select = select
local string_format = string.format
local tonumber = tonumber

-- Wow API
local CalendarGetDate = _G.CalendarGetDate
local CinematicFrame = _G.CinematicFrame
local CloseAllWindows = _G.CloseAllWindows
local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local DND = _G.DND
local GetAchievementInfo = _G.GetAchievementInfo
local GetActiveSpecGroup = _G.GetActiveSpecGroup
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetColoredName = _G.GetColoredName
local GetGameTime = _G.GetGameTime
local GetGuildInfo = _G.GetGuildInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local GetStatistic = _G.GetStatistic
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local LEVEL = _G.LEVEL
local MoveViewLeftStart = _G.MoveViewLeftStart
local MoveViewLeftStop = _G.MoveViewLeftStop
local MovieFrame = _G.MovieFrame
local PAPERDOLL_SIDEBAR_STATS = _G.PAPERDOLL_SIDEBAR_STATS
local PVEFrame_ToggleFrame = _G.PVEFrame_ToggleFrame
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local RemoveExtraSpaces = _G.RemoveExtraSpaces
local Screenshot = _G.Screenshot
local SetCVar = _G.SetCVar
local UnitCastingInfo = _G.UnitCastingInfo
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local UnitIsAFK = _G.UnitIsAFK
local UnitLevel = _G.UnitLevel
local UnitRace = _G.UnitRace

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, PVEFrame, ChatTypeInfo, NONE, KkthnxUIAFKPlayerModel, date
-- GLOBALS: TIMEMANAGER_TOOLTIP_LOCALTIME, TIMEMANAGER_TOOLTIP_REALMTIME

local AFK = LibStub("AceAddon-3.0"):NewAddon("AFK", "AceEvent-3.0", "AceTimer-3.0")

local stats = {
	60,		-- Total deaths
	94,		-- Quests abandoned
	97,		-- Daily quests completed
	98,		-- Quests completed
	107,	-- Creatures killed
	112,	-- Deaths from drowning
	114,	-- Deaths from falling
	319,	-- Duels won
	320,	-- Duels lost
	321,	-- Total raid and dungeon deaths
	326,	-- Gold from quest rewards
	328,	-- Total gold acquired
	333,	-- Gold looted
	334,	-- Most gold ever owned
	338,	-- Vanity pets owned
	339,	-- Mounts owned
	342,	-- Epic items acquired
	349,	-- Flight paths taken
	353,	-- Number of times hearthed
	377,	-- Most factions at Exalted
	588,	-- Total Honorable Kills
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	919,	-- Gold earned from auctions
	931,	-- Total factions encountered
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	1042,	-- Number of hugs
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1065,	-- Total waves
	1066,	-- Total times LOL'd
	1149,	-- Talent tree respecs
	1197,	-- Total kills
	1198,	-- Total kills that grant experience or honor
	1339,	-- Mage portal taken most
	1487,	-- Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1716,	-- Battleground with the most Killing Blows
	2277,	-- Summons accepted
	5692,	-- Rated battlegrounds played
	5694,	-- Rated battlegrounds won
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
	10060,	-- Garrison Followers recruited
	10181,	-- Garrision Missions completed
	10184,	-- Garrision Rare Missions completed
	11234,	-- Class Hall Champions recruited
	11235,	-- Class Hall Troops recruited
	11236,	-- Class Hall Missions completed
	11237,	-- Class Hall Rare Missions completed
}

-- Create Time
local function createTime()
	local hour, hour24, minute, ampm = tonumber(date("%I")), tonumber(date("%H")), tonumber(date("%M")), date("%p"):lower()
	local sHour, sMinute = GetGameTime()

	local localTime = string_format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_LOCALTIME, hour, minute, ampm)
	local localTime24 = string_format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_LOCALTIME, hour24, minute)
	local realmTime = string_format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute, ampm)
	local realmTime24 = string_format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute)

	if C.DataText.LocalTime then
		if C.DataText.Time24Hr then
			return localTime24
		else
			return localTime
		end
	else
		if C.DataText.Time24Hr then
			return realmTime24
		else
			return realmTime
		end
	end
end

local monthAbr = {
	[1] = L.AFKScreen.Jan,
	[2] = L.AFKScreen.Feb,
	[3] = L.AFKScreen.Mar,
	[4] = L.AFKScreen.Apr,
	[5] = L.AFKScreen.May,
	[6] = L.AFKScreen.Jun,
	[7] = L.AFKScreen.Jul,
	[8] = L.AFKScreen.Aug,
	[9] = L.AFKScreen.Sep,
	[10] = L.AFKScreen.Oct,
	[11] = L.AFKScreen.Nov,
	[12] = L.AFKScreen.Dec,
}

local daysAbr = {
	[1] = L.AFKScreen.Sun,
	[2] = L.AFKScreen.Mon,
	[3] = L.AFKScreen.Tue,
	[4] = L.AFKScreen.Wed,
	[5] = L.AFKScreen.Thu,
	[6] = L.AFKScreen.Fri,
	[7] = L.AFKScreen.Sat,
}

-- Create Date
local function createDate()
	local curDayName, curMonth, curDay, curYear = CalendarGetDate()
	AFK.AFKMode.top.date:SetFormattedText("%s, %s %d, %d", daysAbr[curDayName], monthAbr[curMonth], curDay, curYear)
end

-- Create Random Stats
local function createStats()
	local id = stats[math_random( #stats )]
	local _, name = GetAchievementInfo(id)
	local result = GetStatistic(id)
	if result == "--" then result = NONE end
	return string_format("%s: |cfff0ff00%s|r", name, result)
end

local active
local function getSpec()
	local specIndex = GetSpecialization()
	if not specIndex then return end
	active = GetActiveSpecGroup()
	local talent = ""
	local i = GetSpecialization(false, false, active)
	if i then
		i = select(2, GetSpecializationInfo(i))
		if(i) then
			talent = string_format("%s", i)
		end
	end
	return string_format("%s", talent)
end

function AFK:UpdateStatMessage()
	K.UIFrameFadeIn(self.AFKMode.statMsg.info, 1, 1, 0)
	local createdStat = createStats()
	self.AFKMode.statMsg.info:SetText(createdStat)
	K.UIFrameFadeIn(self.AFKMode.statMsg.info, 1, 0, 1)
end

-- Simple-Timer for Stats
local showTime = 5
local total = 0
local function onUpdate(self, elapsed)
	total = total + elapsed
	if total >= showTime then
		local createdStat = createStats()
		self:SetText(createdStat)
		self:FadeIn()
		total = 0
	end
end

local CAMERA_SPEED = 0.035
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}

local printKeys = {
	["PRINTSCREEN"] = true,
}

if IsMacClient() then
	printKeys[_G["KEY_PRINTSCREEN_MAC"]] = true
end

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime

	local createdTime = createTime()

	-- Set Time
	self.AFKMode.top.time:SetFormattedText(createdTime)

	-- Set Date
	createDate()

	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", math_floor(time/60), time % 60)
end

function AFK:SetAFK(status)
	if (InCombatLockdown()) then return end

	if (status) then
		local level = UnitLevel("player")
		local race = UnitRace("player")
		local localizedClass = UnitClass("player")
		local spec = getSpec()

		MoveViewLeftStart(CAMERA_SPEED)
		self.AFKMode:Show()
		CloseAllWindows()
		UIParent:Hide()

		if (IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L.AFKScreen.NoGuild)
		end

		self.AFKMode.bottom.model.curAnimation = "wave"
		self.AFKMode.bottom.model.startTime = GetTime()
		self.AFKMode.bottom.model.duration = 2.3
		self.AFKMode.bottom.model:SetUnit("player")
		self.AFKMode.bottom.model.isIdle = nil
		self.AFKMode.bottom.model:SetAnimation(67)
		self.AFKMode.bottom.model.idleDuration = 40
		self.statsTimer = self:ScheduleRepeatingTimer("UpdateStatMessage", 5)
		self.startTime = GetTime()
		self.timer = self:ScheduleRepeatingTimer("UpdateTimer", 1)

		self.AFKMode.statMsg.info:Show()

		self.isAFK = true
	elseif (self.isAFK) then
		UIParent:Show()
		self.AFKMode:Hide()
		self.AFKMode.statMsg.info:Hide()
		MoveViewLeftStop()
		self:CancelTimer(self.statsTimer)
		self:CancelTimer(self.timer)
		self:CancelTimer(self.animTimer)
		self.AFKMode.bottom.time:SetText("00:00")

		if (PVEFrame:IsShown()) then -- odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		self.isAFK = false
	end
end

function AFK:OnEvent(event, ...)
	if (event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if (event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...)
			if (status == "confirm") then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end

		if (event == "PLAYER_REGEN_DISABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end
		return
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return end
	if (UnitCastingInfo("player") ~= nil) then
		-- Don't activate afk if player is crafting stuff, check back in 30 seconds
		self:ScheduleTimer("OnEvent", 30)
		return
	end

	if (UnitIsAFK("player")) then
		self:SetAFK(true)
	else
		self:SetAFK(false)
	end
end

function AFK:Toggle()
	if (C.Misc.AFKCamera) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
		self:RegisterEvent("LFG_PROPOSAL_SHOW", "OnEvent")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")
		SetCVar("autoClearAFK", "1")
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("LFG_PROPOSAL_SHOW")
		self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
	end
end

local function OnKeyDown(self, key)
	if (ignoreKeys[key]) then return end
	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false)
		AFK:ScheduleTimer("OnEvent", 60)
	end
end

function AFK:LoopAnimations()
	if (KkthnxUIAFKPlayerModel.curAnimation == "wave") then
		KkthnxUIAFKPlayerModel:SetAnimation(69)
		KkthnxUIAFKPlayerModel.curAnimation = "dance"
		KkthnxUIAFKPlayerModel.startTime = GetTime()
		KkthnxUIAFKPlayerModel.duration = 300
		KkthnxUIAFKPlayerModel.isIdle = false
		KkthnxUIAFKPlayerModel.idleDuration = 120
	end
end

function AFK:Initialize()
	local level = UnitLevel("player")
	local race = UnitRace("player")
	local localizedClass = UnitClass("player")
	local className = K.Class
	local spec = getSpec()

	self.AFKMode = CreateFrame("Frame", "KkthnxUIAFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	-- Create Top frame
	self.AFKMode.top = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.top:SetFrameLevel(0)
	self.AFKMode.top:SetTemplate("Transparent")
	self.AFKMode.top:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
	self.AFKMode.top:ClearAllPoints()
	self.AFKMode.top:SetPoint("TOP", self.AFKMode, "TOP", 0, 2)
	self.AFKMode.top:SetWidth(GetScreenWidth() + (2 * 2))
	self.AFKMode.top:SetHeight(GetScreenHeight() * (1 / 10))

	-- Wow Logo
	self.AFKMode.top.wowlogo = CreateFrame("Frame", nil, self.AFKMode) -- </ need this to upper the logo layer > --
	self.AFKMode.top.wowlogo:SetPoint("TOP", self.AFKMode.top, "TOP", 0, -5)
	self.AFKMode.top.wowlogo:SetFrameStrata("MEDIUM")
	self.AFKMode.top.wowlogo:SetSize(300, 150)
	self.AFKMode.top.wowlogo.tex = self.AFKMode.top.wowlogo:CreateTexture(nil, "OVERLAY")
	self.AFKMode.top.wowlogo.tex:SetAtlas("Glues-WoW-LegionLogo")
	self.AFKMode.top.wowlogo.tex:SetInside()

	-- Server/Local Time text
	self.AFKMode.top.time = self.AFKMode.top:CreateFontString(nil, "OVERLAY")
	self.AFKMode.top.time:SetFont(C.Media.Font, 20, C.Media.Font_Style)
	self.AFKMode.top.time:SetText("")
	self.AFKMode.top.time:SetPoint("RIGHT", self.AFKMode.top, "RIGHT", -20, 0)
	self.AFKMode.top.time:SetJustifyH("LEFT")
	self.AFKMode.top.time:SetTextColor(K.Color.r, K.Color.g, K.Color.b)

	-- Date text
	self.AFKMode.top.date = self.AFKMode.top:CreateFontString(nil, "OVERLAY")
	self.AFKMode.top.date:SetFont(C.Media.Font, 20, C.Media.Font_Style)
	self.AFKMode.top.date:SetText("")
	self.AFKMode.top.date:SetPoint("LEFT", self.AFKMode.top, "LEFT", 20, 0)
	self.AFKMode.top.date:SetJustifyH("RIGHT")
	self.AFKMode.top.date:SetTextColor(K.Color.r, K.Color.g, K.Color.b)

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:SetTemplate("Transparent")
	self.AFKMode.bottom:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
	self.AFKMode.bottom:SetPoint("BOTTOM", self.AFKMode, "BOTTOM", 0, -2)
	self.AFKMode.bottom:SetWidth(GetScreenWidth() + (2 * 2))
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10))

	local factionGroup = UnitFactionGroup("player")

	-- factionGroup = "Alliance"
	local size, offsetX, offsetY = 130, -20, -12
	local nameOffsetX, nameOffsetY = -10, -28
	if factionGroup == "Neutral" then
		factionGroup = "Panda"
		size, offsetX, offsetY = 90, 15, 10
		nameOffsetX, nameOffsetY = 20, -5
	end

	-- Display our UI Name
	self.AFKMode.bottom.kkthnxui = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.kkthnxui:SetFont(C.Media.Font, 30)
	self.AFKMode.bottom.kkthnxui:SetText(K.Title)
	self.AFKMode.bottom.kkthnxui:SetPoint("RIGHT", self.AFKMode.bottom, "RIGHT", -25, 8)
	self.AFKMode.bottom.kkthnxui:SetTextColor(60/255, 155/255, 237/255)

	-- Display our UI Version
	self.AFKMode.bottom.ktext = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.ktext:SetFont(C.Media.Font, 17)
	self.AFKMode.bottom.ktext:SetFormattedText("v%s", K.Version)
	self.AFKMode.bottom.ktext:SetPoint("TOP", self.AFKMode.bottom.kkthnxui, "BOTTOM")
	self.AFKMode.bottom.ktext:SetTextColor(0.7, 0.7, 0.7)

	-- Random stats frame
	self.AFKMode.statMsg = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.statMsg:SetSize(418, 72)
	self.AFKMode.statMsg:SetPoint("CENTER", 0, 200)

	self.AFKMode.statMsg.bg = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.bg:SetPoint("BOTTOM")
	self.AFKMode.statMsg.bg:SetSize(326, 103)
	self.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	self.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	self.AFKMode.statMsg.lineTop = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.lineTop:SetDrawLayer("BACKGROUND", 2)
	self.AFKMode.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.lineTop:SetPoint("TOP")
	self.AFKMode.statMsg.lineTop:SetSize(418, 7)
	self.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	self.AFKMode.statMsg.lineBottom = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
	self.AFKMode.statMsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.lineBottom:SetPoint("BOTTOM")
	self.AFKMode.statMsg.lineBottom:SetSize(418, 7)
	self.AFKMode.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	-- Random stats frame
	self.AFKMode.statMsg.info = self.AFKMode.statMsg:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.statMsg.info:SetFont(C.Media.Font, 18, "OUTLINE")
	self.AFKMode.statMsg.info:SetPoint("CENTER", self.AFKMode.statMsg, "CENTER", 0, -2)
	self.AFKMode.statMsg.info:SetText(string_format("|cffb3b3b3%s|r", PAPERDOLL_SIDEBAR_STATS))
	self.AFKMode.statMsg.info:SetJustifyH("CENTER")
	self.AFKMode.statMsg.info:SetTextColor(0.7, 0.7, 0.7)

	-- Move the factiongroup sign to the center
	self.AFKMode.bottom.factionb = CreateFrame("Frame", nil, self.AFKMode) -- need this to upper the faction logo layer
	self.AFKMode.bottom.factionb:SetPoint("BOTTOM", self.AFKMode.bottom, "TOP", 0, -40)
	self.AFKMode.bottom.factionb:SetFrameStrata("MEDIUM")
	self.AFKMode.bottom.factionb:SetFrameLevel(10)
	self.AFKMode.bottom.factionb:SetSize(220, 220)
	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.faction:ClearAllPoints()
	self.AFKMode.bottom.faction:SetParent(self.AFKMode.bottom.factionb)
	self.AFKMode.bottom.faction:SetInside()

	-- Apply class texture rather than the faction
	self.AFKMode.bottom.faction:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\ClassIcons\\CLASS-"..className)
	self.AFKMode.bottom.faction:SetSize(size, size)

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.name:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.name:SetFormattedText("%s - %s".. "\n" .."%s %s %s %s %s", K.Name, K.Realm, LEVEL, level, race, spec, localizedClass)
	self.AFKMode.bottom.name:SetPoint("TOP", self.AFKMode.bottom.factionb, "BOTTOM", 0, 5)
	self.AFKMode.bottom.name:SetTextColor(K.Color.r, K.Color.g, K.Color.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:SetFont(C.Media.Font, 18)
	self.AFKMode.bottom.guild:SetText(L.AFKScreen.NoGuild)
	self.AFKMode.bottom.guild:SetPoint("TOP", self.AFKMode.bottom.name, "BOTTOM", 0, -6)
	self.AFKMode.bottom.guild:SetJustifyH("CENTER")
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:SetFont(C.Media.Font, 30)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:SetPoint("LEFT", self.AFKMode.bottom, "LEFT", 25, 0)
	self.AFKMode.bottom.time:SetTextColor(60/255, 155/255, 237/255)

	-- NPC Model
	self.AFKMode.bottom.npcHolder = CreateFrame("Frame", nil, self.AFKMode.bottom)
	self.AFKMode.bottom.npcHolder:SetSize(150, 150)
	self.AFKMode.bottom.npcHolder:SetPoint("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", 200, 130)
	self.AFKMode.bottom.npc = CreateFrame("PlayerModel", "KkthnxUIAFKNPCModel", self.AFKMode.bottom.npcHolder)
	self.AFKMode.bottom.npc:SetCreature(85009)
	self.AFKMode.bottom.npc:SetPoint("CENTER", self.AFKMode.bottom.npcHolder, "CENTER")
	self.AFKMode.bottom.npc:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	self.AFKMode.bottom.npc:SetCamDistanceScale(6)
	self.AFKMode.bottom.npc:SetFacing(15 * (math_pi/180))

	-- Use this frame to control position of the model
	self.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, self.AFKMode.bottom)
	self.AFKMode.bottom.modelHolder:SetSize(150, 150)
	self.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)
	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "KkthnxUIAFKPlayerModel", self.AFKMode.bottom.modelHolder)
	self.AFKMode.bottom.model:SetPoint("CENTER", self.AFKMode.bottom.modelHolder, "CENTER")
	self.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) -- YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame
	self.AFKMode.bottom.model:SetCamDistanceScale(4.5) -- Since the model frame is huge, we need to zoom out quite a bit
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetScript("OnUpdate", function(self)
		local timePassed = GetTime() - self.startTime
		if(timePassed > self.duration) and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			AFK.animTimer = AFK:ScheduleTimer("LoopAnimations", self.idleDuration)
		end
	end)
	self:Toggle()
	self.isActive = false
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	AFK:Initialize()
end)