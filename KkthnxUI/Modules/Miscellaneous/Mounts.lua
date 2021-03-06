local K, C, L = unpack(select(2, ...))

-- Lua API
local pairs = pairs
local select = select

-- Wow API
local C_MountJournal = C_MountJournal
local CanExitVehicle = CanExitVehicle
local IsControlKeyDown = IsControlKeyDown
local IsFlyableArea = IsFlyableArea
local IsMounted = IsMounted
local IsSwimming = IsSwimming
local IsUsableSpell = IsUsableSpell
local UnitBuff = UnitBuff

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: Mountz, Dismount, VehicleExit

-- -- Universal Mount macro(by Monolit)

--[[
/cancelform [noform]
/leavevehicle [canexitvehicle]
/dismount [mounted]
/run Mountz("GROUND MOUNT", "FLYING MOUNT", "WATER MOUNT")
--]]

function Mountz(groundmount, flyingmount, underwatermount)
	if not underwatermount then underwatermount = groundmount end

	local flyablex, swimablex, vjswim, InVj, nofly
	local num = C_MountJournal.GetNumMounts()
	if not num or IsMounted() then
		Dismount()
		return
	end

	if CanExitVehicle() then
		VehicleExit()
		return
	end

	if IsUsableSpell(59569) ~= true and IsSpellKnown(34090) == true then
		nofly = true
	end

	if not nofly and IsFlyableArea() then
		flyablex = true
	end

	for i = 1, 40 do
		local sid = select(11, UnitBuff("player", i))
		if sid == 73701 or sid == 76377 then
			InVj = true
		end
	end

	if InVj and IsSwimming() then
		vjswim = true
	end

	if IsSwimming() and not flyablex and not vjswim then
		swimablex = true
	end

	if IsControlKeyDown() then
		if IsSwimming() and not vjswim then
			swimablex = not swimablex
		elseif not vjswim then
			flyablex = not flyablex
		else
			vjswim = not vjswim
		end
	end

	local mountID = C_MountJournal.GetMountIDs()
	for _, mountID in pairs(mountID) do
		local creatureName, spellID = C_MountJournal.GetMountInfoByID(mountID)
		if flyingmount and creatureName == flyingmount and flyablex and not swimablex then
			C_MountJournal.SummonByID(mountID)
			return
		elseif groundmount and creatureName == groundmount and not flyablex and not swimablex and not vjswim then
			C_MountJournal.SummonByID(mountID)
			return
		elseif underwatermount and creatureName == underwatermount and swimablex then
			C_MountJournal.SummonByID(mountID)
			return
		elseif spellID == 75207 and vjswim then
			C_MountJournal.SummonByID(mountID)
			return
		end
	end
end