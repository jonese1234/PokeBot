local Data = {}

-- INIT

local function hasNido()
	for idx=0, 5 do
		local pokeID = memory.readbyte(0x116B + idx * 0x2C)
		if pokeID == 3 or pokeID == 167 or pokeID == 7 then
			return true
		end
	end
end

function Data.init()
	local version = 0
	if VERSION then
		local vIndex = 2
		for segment in string.gmatch(VERSION, "([^.]+)") do
			version = version + tonumber(segment) * 100 ^ vIndex
			vIndex = vIndex - 1
		end
	end

	local yellowVersion = memory.getcurrentmemorydomainsize() > 30000
	local gameName = "yellow"
	if not yellowVersion then
		gameName = "red"
		local titleText = memory.readbyte(0x0447)
		if titleText == 96 or titleText == 97 then
			if titleText == 97 then
				gameName = "blue"
			end
		elseif not hasNido() then
			print("ERR: Unable to differentiate Red/Blue version")
			if INTERNAL and not STREAMING_MODE then
				gameName = "blue"
			end
		end
	end

	Data.run = {}
	Data.yellow = yellowVersion
	Data.gameName = gameName
	Data.versionNumber = version
end

-- PRIVATE

local function increment(amount)
	if not amount then
		return 1
	end
	return amount + 1
end

-- HELPERS

function Data.setFrames()
	Data.run.frames = require("util.utils").frames()
end

function Data.increment(key)
	local incremented = increment(Data.run[key])
	Data.run[key] = incremented
	return incremented
end

-- REPORT

function Data.reset(reason, areaName, map, px, py, stats)
	if STREAMING_MODE then
		local report = Data.run
		report.cutter = require("storage.pokemon").inParty("paras", "oddish", "sandshrew", "charmander")

		for key,value in pairs(report) do
			if value == true or value == false then
				report[key] = value == true and 1 or 0
			end
		end

		local ns = stats.nidoran
		if ns then
			report.nido_attack = ns.attackDV
			report.nido_defense = ns.defenseDV
			report.nido_speed = ns.speedDV
			report.nido_special = ns.specialDV
			report.nido_level = ns.level4 and 4 or 3
		end
		local ss = stats.starter
		if ss then
			report.starter_attack = ss.attackDV
			report.starter_defense = ss.defenseDV
			report.starter_speed = ss.speedDV
			report.starter_special = ss.specialDV
		end

		report.version = Data.versionNumber
		report.reset_area = areaName
		report.reset_map = map
		report.reset_x = px
		report.reset_y = py
		report.reset_reason = reason

		if not report.frames then
			Data.setFrames()
		end

		require("util.bridge").report(report)
	end
	Data.run = {}
end

return Data
