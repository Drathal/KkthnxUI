local K, C, L = unpack(select(2, ...))
if C.Automation.Resurrection ~= true then return end

-- Wow Lua
local _G = _G

-- Wow API
local CanUseSoulstone = _G.CanUseSoulstone
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCurrentMapAreaID = _G.GetCurrentMapAreaID
local GetMaxBattlefieldID = _G.GetMaxBattlefieldID
local HasSoulstone = _G.HasSoulstone

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SetMapToCurrentZone, RepopMe

-- Auto release the spirit in battlegrounds
local AutoRelease = CreateFrame("Frame")
AutoRelease:RegisterEvent("PLAYER_DEAD")
AutoRelease:SetScript("OnEvent", function(self, event)
	local inBattlefield = false
	for i = 1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i)
		if status == "active" then inBattlefield = true end
	end
	if not (HasSoulstone() and CanUseSoulstone()) then
		SetMapToCurrentZone()
		local areaID = GetCurrentMapAreaID() or 0
		if areaID == 501 or areaID == 708 or areaID == 978 or areaID == 1009 or areaID == 1011 or inBattlefield == true then
			RepopMe()
		end
	end
end)