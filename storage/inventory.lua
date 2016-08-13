local Inventory = {}

local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"

local Pokemon = require "storage.pokemon"

local items = {
	pokeball = 4,
	bicycle = 6,
	moon_stone = 10,
	antidote = 11,
	paralyze_heal = 15,
	full_restore = 16,
	super_potion = 19,
	potion = 20,
	escape_rope = 29,
	carbos = 38,
	ss_ticket = 63,
	repel = 30,

	rare_candy = 40,
	helix_fossil = 42,
	nugget = 49,
	pokedoll = 51,
	super_repel = 56,
	fresh_water = 60,
	soda_pop = 61,
	pokeflute = 73,
	ether = 80,
	max_ether = 81,
	elixer = 82,

	x_accuracy = 46,
	x_attack = 65,
	x_speed = 67,
	x_special = 68,

	cut = 196,
	fly = 197,
	surf = 198,
	strength = 199,

	mega_punch = 201,
	horn_drill = 207,
	bubblebeam = 211,
	water_gun = 212,
	ice_beam = 213,
	thunderbolt = 224,
	earthquake = 226,
	dig = 228,
	tm34 = 234,
	rock_slide = 248,
}

local ITEM_BASE = 0x131E

-- Data

function Inventory.indexOf(name)
	local searchID = items[name]
	for i=0,19 do
		local iidx = ITEM_BASE + i * 2
		if Memory.raw(iidx) == searchID then
			return i
		end
	end
	return -1
end

function Inventory.count(name)
	if not name then
		return Memory.value("player", "inventory_count")
	end
	local index = Inventory.indexOf(name)
	if index ~= -1 then
		return Memory.raw(ITEM_BASE + index * 2 + 1)
	end
	return 0
end

function Inventory.contains(...)
	for __,name in ipairs(arg) do
		if Inventory.count(name) > 0 then
			return name
		end
	end
end

function Inventory.containsAll(...)
	for __,name in ipairs(arg) do
		if not Inventory.contains(name) then
			return false
		end
	end
	return true
end

function Inventory.ppRestoreCount()
	return Inventory.count("ether") + Inventory.count("max_ether") + Inventory.count("elixer")
end

-- Actions

function Inventory.teach(item, poke, replaceIdx)
	local main = Memory.value("menu", "main")
	local column = Menu.getCol()
	if main == 144 then
		if column == 5 then
			Menu.select(replaceIdx, true)
		else
			Input.press("A")
		end
	elseif main == 128 then
		if column == 5 then
			Menu.select(Inventory.indexOf(item), "accelerate", true)
		elseif column == 11 then
			Menu.select(2, true)
		elseif column == 14 then
			Menu.select(0, true)
		end
	elseif main == Menu.pokemon then
		Input.press("B")
	elseif main == 64 or main == 96 or main == 192 then
		if column == 5 then
			Menu.select(replaceIdx, true)
		elseif column == 14 then
			Input.press("A")
		elseif column == 15 then
			Menu.select(0, true)
		elseif Menu.hasTextbox() then
			Input.press("B")
		else
			local teachIndex = 0
			if poke then
				if type(poke) == "table" then
					teachIndex = Pokemon.indexOf(unpack(poke))
				else
					teachIndex = Pokemon.indexOf(poke)
				end
			end
			Pokemon.select(teachIndex)
		end
	else
		return false
	end
	return true
end

function Inventory.isFull()
	return Inventory.count() == 20
end

function Inventory.useItemOption(item, poke, option)
	local main = Memory.value("menu", "main")
	local column = Menu.getCol()
	if main == 144 then
		if Menu.hasTextbox() then
			Input.press("B")
		else
			Pokemon.select(poke or 0)
		end
	elseif main == 128 or main == 60 then
		if column == 5 then
			Menu.select(Inventory.indexOf(item), "accelerate", true)
		elseif column == 11 then
			Menu.select(2, true)
		elseif column == 14 then
			Menu.select(option, true)
		else
			Pokemon.select(poke or 0)
		end
	elseif main == 228 then
		if column == 14 and Memory.value("battle", "menu") == 95 then
			Input.press("B")
		end
	elseif main == Menu.pokemon then
		Input.press("B")
	else
		return false
	end
	return true
end

function Inventory.use(item, poke, midfight)
	if midfight then
		local battleMenu = Memory.value("battle", "menu")
		if Menu.onBattleSelect(battleMenu) then
			local rowSelected = Memory.value("menu", "row")
			if Menu.getCol() == 9 then
				if rowSelected == 0 then
					Input.press("Down")
				else
					Input.press("A")
				end
			else
				Input.press("Left")
			end
		elseif battleMenu == 233 then
			Menu.select(Inventory.indexOf(item), "accelerate", true)
		elseif Menu.onPokemonSelect(battleMenu) then
			Pokemon.select(poke or 0)
		else
			Input.press("B")
		end
		return
	end

	return Inventory.useItemOption(item, poke, 0)
end

return Inventory
