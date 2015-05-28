local Battle = {}

local Textbox = require "action.textbox"

local Combat = require "ai.combat"
local Control = require "ai.control"

local Memory = require "util.memory"
local Menu = require "util.menu"
local Input = require "util.input"
local Utils = require "util.utils"

local Inventory = require "storage.inventory"
local Pokemon = require "storage.pokemon"

-- HELPERS

local function potionsForHit(potion, curr_hp, max_hp)
	if not potion then
		return
	end
	local ours, killAmount = Combat.inKillRange()
	if ours then
		if Control.yolo and killAmount > 6 and killAmount == curr_hp then
			return false
		end
		return Utils.canPotionWith(potion, killAmount, curr_hp, max_hp)
	end
end

local function recover()
	if Control.canRecover() then
		local curr_hp = Combat.hp()
		if curr_hp > 0 then
			local max_hp = Combat.maxHP()
			if curr_hp < max_hp then
				local first, second
				if Control.preferredPotion == "full" then
					first, second = "full_restore", "super_potion"
					if max_hp - curr_hp > 54 then
						first = "full_restore"
						second = "super_potion"
					else
						first = "super_potion"
						second = "full_restore"
					end
				else
					if Control.preferredPotion == "super" or max_hp - curr_hp > 22 then
						first = "super_potion"
						second = "potion"
					else
						first = "potion"
						second = "super_potion"
					end
				end
				local potion = Inventory.contains(first, second)
				if potionsForHit(potion, curr_hp, max_hp) then
					Inventory.use(potion, nil, true)
					return true
				end
			end
		end
	end
	if Combat.isParalyzed() and not Control.canDie() then
		local heals = Inventory.contains("paralyze_heal", "full_restore")
		if heals then
			Inventory.use(heals, nil, true)
			return true
		end
	end
end

local function openBattleMenu()
	if Memory.value("battle", "text") == 1 then
		Input.cancel()
		return false
	end
	local battleMenu = Memory.value("battle", "menu")
	local col = Menu.getCol()
	if battleMenu == 106 or (battleMenu == 94 and col == 5) then
		return true
	elseif Menu.onBattleSelect(battleMenu) then
		local rowSelected = Memory.value("menu", "row")
		if col == 9 then
			if rowSelected == 1 then
				Input.press("Up")
			else
				Input.press("A")
			end
		else
			Input.press("Left")
		end
	else
		Input.press("B")
	end
end

local function attack(attackIndex)
	if not Battle.opponentAlive() then
		Input.cancel()
	elseif openBattleMenu() then
		Menu.select(attackIndex, true, false, false, false, 3)
	end
end

local function movePP(name)
	local midx = Pokemon.battleMove(name)
	if not midx then
		return 0
	end
	return Memory.raw(0x102C + midx)
end
Battle.pp = movePP

-- UTILS

function Battle.swapMove(move, toIndex)
	toIndex = toIndex + 1
	if openBattleMenu() then
		local moveIndex = Pokemon.battleMove(move)
		if not moveIndex or moveIndex == toIndex then
			return true
		end
		local selection = Memory.value("menu", "selection_mode")
		local swapSelect
		if selection == toIndex then
			swapSelect = moveIndex
		else
			swapSelect = toIndex
		end
		local menuSize = Memory.raw(0x101F) == 0 and 3 or 4
		if Menu.select(swapSelect, true, false, nil, true, menuSize) then
			Input.press("Select")
		end
	end
end

function Battle.isActive()
	return Memory.value("game", "battle") > 0
end

function Battle.isTrainer()
	return Memory.value("game", "battle") == 2
end

function Battle.opponent()
	return Pokemon.getName(Memory.value("battle", "opponent_id"))
end

function Battle.deployed()
	return Pokemon.getName(Memory.value("battle", "our_id"))
end

function Battle.opponentAlive()
	return Memory.double("battle", "opponent_hp") > 0
end

function Battle.damaged(factor)
	if not factor then
		factor = 1
	end
	return Combat.hp() * factor < Combat.maxHP()
end

function Battle.opponentDamaged(factor)
	if not factor then
		factor = 1
	end
	return Memory.double("battle", "opponent_hp") * factor < Memory.double("battle", "opponent_max_hp")
end

-- HANDLE

function Battle.run()
	if not Battle.opponentAlive() then
		Input.cancel()
	elseif not Menu.onBattleSelect() then
		if Memory.value("menu", "text_length") == 127 then
			Input.press("B")
		else
			Input.cancel()
		end
	elseif Textbox.handle() then
		local selected = Memory.value("menu", "selection")
		if selected == 239 then
			Input.press("A", 2)
		elseif selected == 233 then
			Input.press("Right")
		else
			Input.escape()
		end
	end
end

function Battle.handle()
	if not Control.shouldCatch() then
		if Control.shouldFight() then
			Battle.fight()
		else
			Battle.run()
		end
	end
end

function Battle.handleWild(battleStatus)
	if not battleStatus then
		battleStatus = Memory.value("game", "battle")
	end
	if battleStatus ~= 1 then
		return true
	end
	Battle.handle()
end

function Battle.fight(move)
	local moveIndex
	if move then
		local disableCheck
		if type(move) == "string" then
			disableCheck = move
			moveIndex = Pokemon.battleMove(move)
		else
			disableCheck = move.id
			Battle.accurateAttack = move.accuracy == 100
			moveIndex = move.midx
		end
		if Combat.isDisabled(disableCheck) then
			move = nil
		end
	end
	if not move then
		move = Combat.bestMove()
		if move then
			Battle.accurateAttack = move.accuracy == 100
			moveIndex = move.midx
		else
			moveIndex = nil
		end
	end

	if moveIndex then
		attack(moveIndex)
	elseif Memory.value("menu", "text_length") == 127 then
		Input.press("B")
	else
		Input.cancel()
	end
end

function Battle.swap(target)
	if Menu.onPokemonSelect() then
		if Menu.getCol() == 0 then
			Pokemon.select(target)
		else
			Input.press("A")
		end
	elseif Menu.onBattleSelect() then
		local selected = Memory.value("menu", "selection")
		if selected == 199 then
			Input.press("A", 2)
		elseif Menu.getCol() == 9 then
			Input.press("Right", 0)
		else
			Input.press("Up", 0)
		end
	else
		Input.cancel()
	end
end

function Battle.automate(moveName, skipBuffs)
	if not recover() then
		local state = Memory.value("game", "battle")
		if state == 0 then
			Input.cancel()
		else
			if moveName and movePP(moveName) == 0 then
				moveName = nil
			end
			if state == 1 then
				if Control.shouldFight() then
					Battle.fight(moveName, skipBuffs)
				else
					Battle.run()
				end
			elseif state == 2 then
				Battle.fight(moveName, skipBuffs)
			end
		end
	end
end

-- SACRIFICE

function Battle.sacrifice(...)
	local sacrifice = Pokemon.getSacrifice(...)
	if sacrifice then
		Battle.swap(sacrifice)
		return true
	end
	return false
end

function Battle.redeployNidoking()
	if Pokemon.isDeployed("nidoking") then
		Control.ignoreMiss = false
		return false
	end
	Control.ignoreMiss = true
	if Menu.onPokemonSelect() then
		Pokemon.select("nidoking")
	elseif Menu.hasTextbox() and Menu.getCol() == 1 then
		Input.press("A")
	else
		local forced
		local __, turns = Combat.bestMove()
		if turns == 1 then
			if Pokemon.isDeployed("spearow") then
				forced = "growl"
			elseif Pokemon.isDeployed("squirtle") then
				forced = "tail_whip"
			else
				forced = "sand_attack"
			end
		end
		Battle.automate(forced)
	end
	return true
end

return Battle
