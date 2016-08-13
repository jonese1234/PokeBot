local Menu = {}

local Data = require "data.data"

local Input = require "util.input"
local Memory = require "util.memory"
local Utils = require "util.utils"

local yellow = Data.yellow

local sliding = false
local alternateStart = 0

Menu.pokemon = yellow and 51 or 103

-- PRIVATE

local function getRow(menuType, scrolls)
	if menuType and menuType == "settings" then
		menuType = menuType.."_row"
	else
		menuType = "row"
	end
	local row = Memory.value("menu", menuType)
	if scrolls then
		row = row + Memory.value("menu", "scroll_offset")
	end
	return row
end

local function setRow(desired, throttle, scrolls, menuType, loop)
	local currentRow = getRow(menuType, scrolls)
	if throttle == "accelerate" then
		if sliding then
			throttle = false
		else
			local dist = math.abs(desired - currentRow)
			if dist < 15 then
				throttle = true
			else
				throttle = false
				sliding = true
			end
		end
	else
		sliding = false
	end
	return Menu.balance(currentRow, desired, true, loop, throttle)
end

local function isCurrently(desired, menuType)
	if menuType then
		menuType = menuType.."_current"
	else
		menuType = "current"
	end
	return Memory.value("menu", menuType) == desired
end
Menu.isCurrently = isCurrently

-- HELPERS

function Menu.getCol()
	return Memory.value("menu", "column")
end

function Menu.open(desired, atIndex, menuType)
	if isCurrently(desired, menuType) then
		return true
	end
	Menu.select(atIndex, false, false, menuType)
	return false
end

function Menu.select(option, throttle, scrolls, menuType, dontPress, loop)
	if setRow(option, throttle, scrolls, menuType, loop) then
		local delay = 1
		if throttle then
			delay = 2
		end
		if not dontPress then
			Input.press("A", delay)
		end
		return true
	end
end

function Menu.cancel(desired, menuType)
	if not isCurrently(desired, menuType) then
		return true
	end
	Input.press("B")
	return false
end

-- SELECT

function Menu.balance(current, desired, inverted, looping, throttle)
	if current == desired then
		sliding = false
		return true
	end
	if not throttle then
		throttle = 0
	else
		throttle = 1
	end
	local goUp = current > desired == inverted
	if looping and math.abs(current - desired) > math.floor(looping / 2) then
		goUp = not goUp
	end
	if goUp then
		Input.press("Up", throttle)
	else
		Input.press("Down", throttle)
	end
	return false
end

function Menu.sidle(current, desired, looping, throttle)
	if current == desired then
		return true
	end
	if not throttle then
		throttle = 0
	else
		throttle = 1
	end
	local goLeft = current > desired
	if looping and math.abs(current - desired) > math.floor(looping / 2) then
		goLeft = not goLeft
	end
	if goLeft then
		Input.press("Left", throttle)
	else
		Input.press("Right", throttle)
	end
	return false
end

function Menu.setCol(desired)
	return Menu.sidle(Menu.getCol(), desired)
end

-- OPTIONS

function Menu.setOption(name, desired)
	if yellow then
		local rowFor = {
			text_speed = 0,
			battle_animation = 1,
			battle_style = 2
		}
		local currentRow = Memory.raw(0x0D3D, true)
		if Menu.balance(currentRow, rowFor[name], true, false, true) then
			Input.press("Left")
		end
	else
		local rowFor = {
			text_speed = 3,
			battle_animation = 8,
			battle_style = 13
		}
		if Memory.value("setting", name) == desired then
			return true
		end
		if setRow(rowFor[name], true, false, "settings") then
			Menu.setCol(desired)
		end
	end
	return false
end

function Menu.onBattleSelect()
	return Memory.value("battle", "menu") == 94
end

function Menu.onPokemonSelect(battleMenu)
	if not battleMenu then
		battleMenu = Memory.value("battle", "menu")
	end
	if yellow then
		battleMenu = battleMenu - 19
	end
	return battleMenu == 8 or battleMenu == 48 or battleMenu == 184 or battleMenu == 222 or battleMenu == 224
end

-- PAUSED

function Menu.hasTextbox()
	return Memory.value("battle", "menu") == (yellow and 19 or 95)
end

function Menu.isOpened()
	return Memory.value("game", "textbox") == 1
end

function Menu.hasBeenOpened()
	local mainMenu = Memory.value("menu", "main")
	if mainMenu > 7 then
		return true
	end
	if (Menu.isOpened() or Menu.onPokemonSelect()) and Utils.match(mainMenu, {0, 1, 2, 4, 6, 7}) then
		return true
	end
end

function Menu.close()
	if not Menu.hasBeenOpened() then
		return true
	end
	Input.press("B")
end

function Menu.pause()
	if Menu.isOpened() then
		if Menu.hasTextbox() then
			Input.cancel()
		else
			local main = Memory.value("menu", "main")
			if main > 2 and main ~= 64 then
				return true
			end
			Input.press("B")
		end
	else
		if yellow then
			alternateStart = alternateStart + 1
			if alternateStart > 1 then
				if alternateStart > 2 then
					alternateStart = 0
				end
				return false
			end
		end
		Input.press("Start", 2)
	end
end

return Menu
