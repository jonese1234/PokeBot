local Strategies = require "ai.strategies"

local Combat = require "ai.combat"
local Control = require "ai.control"

local Data = require "data.data"

local Battle = require "action.battle"
local Shop = require "action.shop"
local Textbox = require "action.textbox"
local Walk = require "action.walk"

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Player = require "util.player"
local Utils = require "util.utils"

local Inventory = require "storage.inventory"
local Pokemon = require "storage.pokemon"

local status = Strategies.status
local stats = Strategies.stats

local strategyFunctions = Strategies.functions

Strategies.vaporeon = false

-- TIME CONSTRAINTS

Strategies.timeRequirements = {

	nidoran = function()
		return 15
	end,

	mt_moon = function()
		local timeLimit = 35
		if stats.nidoran.attack > 15 and stats.nidoran.speed > 14 then
			timeLimit = timeLimit + 0.25
		end
		if Pokemon.inParty("sandshrew") then
			timeLimit = timeLimit + 0.25
		end
		return timeLimit
	end,

	misty = function() --TWEET
		return 43
	end,

	trash = function()
		return 60
	end,

	safari_carbos = function()
		return 90
	end,

	victory_road = function() --PB
		return 110
	end,

	champion = function() --PB
		return 125
	end,

}

-- HELPERS

local function nidoranDSum(enabled)
	local px, py = Player.position()
	if enabled and status.path == nil then
		local opponentName = Battle.opponent()
		local opponentLevel = Memory.value("battle", "opponent_level")
		if opponentName == "rattata" then
			if opponentLevel == 3 then
				status.path = {0, 1, 11, 2, 11}
			elseif opponentLevel == 4 then
				status.path = {9, 2, 11, 2, 11}
			end
		elseif opponentName == "pidgey" then
			if opponentLevel == 3 then
				status.path = {9, 2, 11, 2, 11}
			elseif opponentLevel == 5 then
				status.path = {3, 2, 11, 2, 11}
			elseif opponentLevel == 7 then
				status.path = {0, 3, 11, 2, 11}
			end
		elseif opponentName == "nidoran" then
			if opponentLevel == 4 then
				status.path = {5, 2, 11, 2, 11}
			end
		elseif opponentName == "nidoranf" then
			if opponentLevel == 4 then
				status.path = {1, 2, 11, 2, 11}
			elseif opponentLevel == 6 then
				status.path = {1, 2, 11, 2, 11}
			end
		end
		if status.path then
			status.pathIndex = 1
			status.startTime = Utils.frames() + 118
		else
			status.path = 0
		end
	end

	local dx, dy = px, py
	local cornerBonk = true
	local encounterlessSteps = Memory.value("game", "encounterless")
	if enabled and status.path ~= 0 then
		local duration = status.path[status.pathIndex]
		local currentTime = Utils.frames()
		if (currentTime - status.startTime) / 60 > duration then
			status.startTime = currentTime
			if status.pathIndex >= #status.path then
				status.path = 0
				print("done")
			else
				status.pathIndex = status.pathIndex + 1
				p(status.pathIndex, (status.pathIndex - 1) % 2)
			end
			return nidoranDSum()
		end
		local walkOutside = (status.pathIndex - 1) % 2 == 0
		if walkOutside then
			cornerBonk = false
			if dy ~= 48 then
				dy = 48
			elseif encounterlessSteps <= 1 then
				if px < 3 then
					dx = 3
				end
			elseif encounterlessSteps == 2 then
				if px == 4 then
					dx = 3
				else
					dx = 4
				end
			else
				if px == 3 then
					dx = 2
				else
					dx = 3
				end
			end
		end
	end
	if cornerBonk then
		local pikachuX = Memory.value("player", "pikachu_x") - 4
		if px == 4 and py == 48 and pikachuX >= px then
			dx = px + 1
		elseif px >= 4 and py == 48 then
			if encounterlessSteps == 0 then
				if not status.bonkWait then
					local direction
					if Player.isFacing("Up") then
						direction = "Left"
					else
						direction = "Up"
					end
					Input.press(direction, direction == "Up" and 3 or 2)
				end
				status.bonkWait = not status.bonkWait
				return
			end
			if encounterlessSteps < 2 or dx ~= 3 then
				dx = 3
			else
				dx = 4
			end
		else
			status.bonkWait = nil
			if dx ~= 4 then
				dx = 4
			elseif py ~= 48 then
				dy = 48
			end
		end
	end
	Walk.step(dx, dy)
end

local function depositPikachu()
	if Menu.isOpened() then
		local pc = Memory.value("menu", "size")
		if Memory.value("battle", "menu") ~= 19 then
			local menuColumn = Menu.getCol()
			if menuColumn == 5 then
				Menu.select(Pokemon.indexOf("pikachu"))
			elseif menuColumn == 10 then
				Input.press("A")
			elseif pc == 3 then
				Menu.select(0)
			elseif pc == 5 then
				Menu.select(1)
			else
				Input.cancel()
			end
		else
			Input.cancel()
		end
	else
		Player.interact("Up")
	end
end

local function takeCenter(pp, startMap, entranceX, entranceY, finishX)
	local px, py = Player.position()
	local currentMap = Memory.value("game", "map")
	local sufficientPP = Pokemon.pp(0, "horn_attack") > pp
	if Strategies.initialize("reported") then
		local centerAction
		if sufficientPP then
			centerAction = "Skipping"
		else
			centerAction = "Taking"
		end
		Bridge.chat(centerAction.." the Center with "..Pokemon.pp(0, "horn_attack").." of "..pp.." Horn Attacks")
	end
	if currentMap == startMap then
		if not sufficientPP then
			if px ~= entranceX then
				px = entranceX
			else
				py = entranceY
			end
		else
			if px == finishX then
				return true
			end
			px = finishX
		end
	else
		if Pokemon.inParty("pikachu") then
			if py > 5 then
				py = 5
			elseif px < 13 then
				px = 13
			elseif py ~= 4 then
				py = 4
			else
				return depositPikachu()
			end
		else
			if Strategies.initialize("deposited") then
				Bridge.caught("deposited")
			end
			if px ~= 3 then
				if Menu.close() then
					px = 3
				end
			elseif sufficientPP then
				if Textbox.handle() then
					py = 8
				end
			elseif py > 3 then
				py = 3
			else
				strategyFunctions.confirm({dir="Up"})
			end
		end
	end
	Walk.step(px, py)
end

function Strategies.requiresE4Center()
	return Combat.hp() < 100
end

function Strategies.needs1Carbos()
	return stats.nidoran.speedDV >= 11
end

-- STRATEGIES

strategyFunctions.gotPikachu = function()
	Bridge.caught("pikachu")
	return true
end

-- dodgePalletBoy

strategyFunctions.shopViridianPokeballs = function()
	return Shop.transaction {
		buy = {{name="pokeball", index=0, amount=4}, {name="potion", index=1, amount=6}}
	}
end

strategyFunctions.catchNidoran = function()
	if not Control.canCatch() then
		return true
	end
	if Battle.isActive() then
		status.path = nil
		local isNidoran = Pokemon.isOpponent("nidoran")
		if isNidoran and Memory.value("battle", "opponent_level") == 6 then
			if Strategies.initialize() then
				Bridge.pollForName()
			end
		end
		if Memory.value("battle", "menu") == 94 then
			local pokeballs = Inventory.count("pokeball")
			local caught = Memory.value("player", "party_size") > 1
			if pokeballs < (caught and 1 or 2) then
				return Strategies.reset("pokeballs", "Ran too low on PokeBalls", pokeballs)
			end
		end
		if Memory.value("menu", "text_input") == 240 then
			Textbox.name()
		elseif Menu.hasTextbox() then
			if isNidoran then
				Input.press("A")
			else
				Input.cancel()
			end
		else
			Battle.handle()
		end
	else
		Pokemon.updateParty()
		local hasNidoran = Pokemon.inParty("nidoran")
		if hasNidoran then
			local px, py = Player.position()
			local dx, dy = px, py
			if px ~= 8 then
				dx = 8
			elseif py > 47 then
				dy = 47
			else
				Bridge.caught("nidoran")
				if INTERNAL then
					p(Pokemon.getDVs("nidoran"))
				end
				return true
			end
			Walk.step(dx, dy)
		else
			local resetLimit = Strategies.getTimeRequirement("nidoran")
			local resetMessage = "find a suitable Nidoran"
			if Strategies.resetTime(resetLimit, resetMessage) then
				return true
			end
			local enableDSum = Control.escaped and not Strategies.overMinute(resetLimit - 0.25)
			nidoranDSum(enableDSum)
		end
	end
end

strategyFunctions.leerCaterpies = function()
	if not status.secondCaterpie and not Battle.opponentAlive() then
		status.secondCaterpie = true
	end
	local leerAmount = status.secondCaterpie and 7 or 10
	return strategyFunctions.leer({{"caterpie", leerAmount}})
end

-- checkNidoranStats

strategyFunctions.centerViridian = function()
	return takeCenter(15, 2, 13, 25, 18)
end

strategyFunctions.fightBrock = function()
	local curr_hp = Pokemon.info("nidoran", "hp")
	if curr_hp == 0 then
		return Strategies.death()
	end
	if Strategies.trainerBattle() then
		local __, turnsToKill, turnsToDie = Combat.bestMove()
		if turnsToDie and turnsToDie < 2 and Inventory.contains("potion") then
			Inventory.use("potion", "nidoran", true)
		else
			local bideTurns = Memory.value("battle", "opponent_bide")
			if bideTurns > 0 then
				local onixHP = Memory.double("battle", "opponent_hp")
				if status.tries == 0 then
					status.tries = onixHP
					status.startBide = bideTurns
				end
				if turnsToKill then
					local forced
					if turnsToKill < 2 or status.startBide - bideTurns > 1 then
					-- elseif turnsToKill < 3 and status.startBide == bideTurns then
					elseif onixHP == status.tries then
						forced = "leer"
					end
					Battle.fight(forced)
				else
					Input.cancel()
				end
			else
				status.tries = 0
				strategyFunctions.leer({{"onix", 13}})
			end
		end
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.centerMoon = function()
	return takeCenter(5, 15, 11, 5, 12)
end

strategyFunctions.centerCerulean = function(data)
	local ppRequired = 10
	if data.first then
		local hasSufficientPP = Pokemon.pp(0, "horn_attack") > ppRequired
		if Strategies.initialize() then
			Combat.factorPP(hasSufficientPP)
		end
		local currentMap = Memory.value("game", "map")
		if currentMap == 3 then
			if hasSufficientPP then
				local px, py = Player.position()
				if py > 8 then
					return strategyFunctions.dodgeCerulean({left=true})
				end
			end
			if not strategyFunctions.dodgeCerulean({}) then
				return false
			end
		end
	end
	return takeCenter(ppRequired, 3, 19, 17, 19)
end

-- reportMtMoon

strategyFunctions.acquireCharmander = function()
	if Strategies.initialize() then
		if Pokemon.inParty("sandshrew", "paras") then
			return true
		end
	end
	local acquiredCharmander = Pokemon.inParty("charmander")
	if Textbox.isActive() then
		if Menu.getCol() == 15 then
			local accept = Memory.raw(0x0C3A) == 239
			Input.press(accept and "A" or "B")
		else
			Input.cancel()
		end
		return false
	end
	local px, py = Player.position()
	if acquiredCharmander then
		if Strategies.initialize("aquired") then
			Bridge.caught("charmander")
		end
		if py ~= 8 then
			py = 8
		else
			return true
		end
	else
		if px ~= 6 then
			px = 6
		elseif py > 6 then
			py = 6
		else
			Player.interact("Up")
			return false
		end
	end
	Walk.step(px, py)
end

-- jingleSkip

strategyFunctions.shopVermilionMart = function()
	-- if Strategies.initialize() then
	-- 	Strategies.setYolo("vermilion")
	-- end
	local supers = Strategies.vaporeon and 7 or 8
	return Shop.transaction {
		sell = sellArray,
		buy = {{name="super_potion",index=1,amount=supers}, {name="repel",index=5,amount=3}}
	}
end

strategyFunctions.trashcans = function()
	if not status.canIndex then
		status.canIndex = 1
		status.progress = 1
		status.direction = 1
	end
	local trashPath = {
	-- 	{next,	loc,	check,		mid,	pair,	finish,	end}		{waypoints}
		{nd=2,	{1,12},	"Up",				{3,12},	"Up",	{3,12}},	{{4,12}},
		{nd=4,	{4,11},	"Right",	{4,6},	{1,6},	"Down",	{1,6}},
		{nd=1,	{4,9},	"Left",				{4,7},	"Left",	{4,7}},
		{nd=1,	{4,7},	"Right",	{4,6},	{1,6},	"Down",	{1,6}},		{{4,6}},
		{nd=0,	{1,6},	"Down",				{3,6},	"Down", {3,6}},		{{4,6}}, {{4,8}},
		{nd=0,	{7,8},	"Down",				{7,8},	"Up",	{7,8}},		{{8,8}},
		{nd=0,	{8,7},	"Right",			{8,7},	"Left", {8,7}},
		{nd=0,	{8,11},	"Right",			{8,9},	"Right",{8,9}},		{{8,12}},
	}
	local totalPathCount = #trashPath

	local unlockProgress = Memory.value("progress", "trashcans")
	if Textbox.isActive() then
		if not status.canProgress then
			status.canProgress = true
			local px, py = Player.position()
			if unlockProgress < 2 then
				status.tries = status.tries + 1
				if status.unlocking then
					status.unlocking = false
					local flipIndex = status.canIndex + status.nextDelta
					local flipCan = trashPath[flipIndex][1]
					status.flipIndex = flipIndex
					if px == flipCan[1] and py == flipCan[2] then
						status.nextDirection = status.direction * -1
						status.canIndex = flipIndex
						status.progress = 1
					else
						status.flipIndex = flipIndex
						status.direction = 1
						status.nextDirection = status.direction * -1
						status.progress = status.progress + 1
					end
				else
					status.canIndex = Utils.nextCircularIndex(status.canIndex, status.direction, totalPathCount)
					status.progress = nil
				end
			else
				status.unlocking = true
				status.progress = status.progress + 1
			end
		end
		Input.cancel()
	elseif unlockProgress == 3 then
		return Strategies.completeCans()
	else
		if status.canIndex == status.flipIndex then
			status.flipIndex = nil
			status.direction = status.nextDirection
		end
		local targetCan = trashPath[status.canIndex]
		local targetCount = #targetCan

		local canProgression = status.progress
		if not canProgression then
			canProgression = 1
			status.progress = 1
		else
			local reset
			if canProgression < 1 then
				reset = true
			elseif canProgression > targetCount then
				reset = true
			end
			if reset then
				status.canIndex = Utils.nextCircularIndex(status.canIndex, status.direction, totalPathCount)
				status.progress = nil
				return strategyFunctions.trashcans()
			end
		end

		local action = targetCan[canProgression]
		if type(action) == "string" then
			status.nextDelta = targetCan.nd
			Player.interact(action)
		else
			status.canProgress = false
			local px, py = Player.position()
			local dx, dy = action[1], action[2]
			if px == dx and py == dy then
				status.progress = status.progress + 1
				return strategyFunctions.trashcans()
			end
			Walk.step(dx, dy)
		end
	end
end

-- announceFourTurn

-- redbarCubone

strategyFunctions.deptElevator = function()
	if Menu.isOpened() then
		status.canProgress = true
		Menu.select(4, false, true)
	else
		if status.canProgress then
			return true
		end
		Player.interact("Up")
	end
end

strategyFunctions.shopBuffs = function()
	local xAccs = Strategies.vaporeon and 11 or 10
	local xSpeeds = Strategies.vaporeon and 6 or 7

	return Shop.transaction {
		direction = "Right",
		sell = {{name="nugget"}},
		buy = {{name="x_accuracy", index=0, amount=xAccs}, {name="x_attack", index=3, amount=3}, {name="x_speed", index=5, amount=xSpeeds}, {name="x_special", index=6, amount=5}},
	}
end

-- shopVending

-- giveWater

-- shopExtraWater

-- shopPokeDoll

-- shopTM07

-- shopRepels

strategyFunctions.lavenderRival = function()
	if Strategies.trainerBattle() then
		if Strategies.prepare("x_accuracy") then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

-- digFight

-- pokeDoll

-- drivebyRareCandy

-- silphElevator

strategyFunctions.silphCarbos = function(data)
	if not Strategies.needs1Carbos() then
		if Strategies.closeMenuFor(data) then
			return true
		end
	else
		data.item = "carbos"
		data.poke = "nidoking"
		return strategyFunctions.item(data)
	end
end

strategyFunctions.silphRival = function()
	if Strategies.trainerBattle() then
		if Strategies.prepare("x_accuracy") then
			-- Strategies.prepare("x_speed")
			local forced, prepare
			local opponentName = Battle.opponent()
			if opponentName == "sandslash" then
				local __, __, turnsToDie = Combat.bestMove()
				if turnsToDie and turnsToDie < 2 then
					forced = "horn_drill"
				else
					prepare = true
				end
			elseif opponentName == "magneton" then
				prepare = true
			elseif opponentName ~= "kadabra" then
				forced = "horn_drill" --TODO necessary?
			end
			if not prepare or Strategies.prepare("x_speed") then
				Battle.automate(forced)
			end
		end
	elseif status.foughtTrainer then
		Control.ignoreMiss = false
		return true
	end
end

-- playPokeflute

strategyFunctions.tossTM34 = function()
	if Strategies.initialize() then
		if not Inventory.contains("carbos") or Inventory.count() < 19 then
			return true
		end
	end
	return Strategies.tossItem("tm34")
end

strategyFunctions.fightKoga = function()
	if Strategies.trainerBattle() then
		if Strategies.prepare("x_accuracy") then
			local forced = "horn_drill"
			local opponent = Battle.opponent()
			if opponent == "venonat" then
				if not Battle.opponentAlive() then
					status.secondVenonat = true
				end
				if status.secondVenonat or Combat.isSleeping() then
					if not Strategies.prepare("x_speed") then
						return false
					end
				end
			end
			Battle.automate(forced)
		end
	elseif status.foughtTrainer then
		Strategies.deepRun = true
		Control.ignoreMiss = false
		return true
	end
end

strategyFunctions.fightSabrina = function()
	if Strategies.trainerBattle() then
		if Strategies.prepare("x_accuracy", "x_speed") then
			-- local forced = "horn_drill"
			-- local opponent = Battle.opponent()
			-- if opponent == "venonat" then
			-- end
			Battle.automate(forced)
		end
	elseif status.foughtTrainer then
		Strategies.deepRun = true
		Control.ignoreMiss = false
		return true
	end
end

-- dodgeGirl

-- cinnabarCarbos

strategyFunctions.fightGiovanni = function()
	if Strategies.trainerBattle() then
		if Strategies.initialize() then
			Bridge.chat(" Giovanni can end the run here with Dugtrio's high chance to critical...")
		end
		if Strategies.prepare("x_speed") then
			local forced
			local prepareAccuracy
			local opponent = Battle.opponent()
			if opponent == "persian" then
				prepareAccuracy = true
				if not status.prepared and not Strategies.isPrepared("x_accuracy") then
					status.prepared = true
					Bridge.chat("needs to finish setting up against Persian...")
				end
			elseif opponent == "dugtrio" then
				prepareAccuracy = Memory.value("battle", "dig") > 0
				if prepareAccuracy and not status.dug then
					status.dug = true
					Bridge.chat("got Dig, which gives an extra turn to set up with X Accuracy. No criticals!")
				end
			end
			if not prepareAccuracy or Strategies.prepare("x_accuracy") then
				Battle.automate(forced)
			end
		end
	elseif status.foughtTrainer then
		Strategies.deepRun = true
		Control.ignoreMiss = false
		return true
	end
end

strategyFunctions.useViridianEther = function()
	if Strategies.initialize() then
		if not Strategies.vaporeon or not Inventory.contains("ether", "max_ether") then
			return true
		end
	end
	return strategyFunctions.ether({chain=true})
end

strategyFunctions.fightViridianRival = function()
	if Strategies.trainerBattle() then
		local xItem1, xItem2
		if Strategies.vaporeon then
			xItem1 = "x_accuracy"
			if Battle.pp("horn_drill") < 3 then
				xItem2 = "x_special"
			end
		else
			xItem1 = "x_special"
		end
		if Strategies.prepare(xItem1, xItem2) then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.depositPokemon = function()
	if Memory.value("player", "party_size") == 1 then
		if Menu.close() then
			return true
		end
	elseif Menu.isOpened() then
		local menuSize = Memory.value("menu", "size")
		if not Menu.hasTextbox() then
			if menuSize == 5 then
				Menu.select(1)
				return false
			end
			local menuColumn = Menu.getCol()
			if menuColumn == 10 then
				Input.press("A")
				return false
			end
			if menuColumn == 5 then
				Menu.select(1)
				return false
			end
		end
		Input.press("A")
	else
		Player.interact("Up")
	end
end

strategyFunctions.centerSkip = function()
	if Strategies.initialize() then
		Strategies.setYolo("e4center")
		Control.preferredPotion = "full"

		if false then --TODO
			local message = "is skipping the Elite 4 Center!"
			Bridge.chat(message)
			return true
		end
	end
	return strategyFunctions.confirm({dir="Up"})
end

strategyFunctions.shopE4 = function()
	return Shop.transaction {
		buy = {{name="full_restore", index=2, amount=3}}
	}
end

strategyFunctions.lorelei = function()
	if Strategies.trainerBattle() then
		local opponentName = Battle.opponent()
		if opponentName == "dewgong" then
			if Memory.double("battle", "our_speed") < 121 then
				if Strategies.initialize("speedFall") then
					Bridge.chat("got speed fall from Dewgong D: Attempting to recover with X Speed...")
				end
				if not Strategies.prepare("x_speed") then
					return false
				end
			end
		end
		if Strategies.prepare("x_accuracy") then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.bruno = function()
	if Strategies.trainerBattle() then
		local forced
		local opponentName = Battle.opponent()
		if opponentName == "onix" then
			forced = "ice_beam"
		elseif opponentName == "hitmonchan" then
			if not Strategies.prepare("x_accuracy") then
				return false
			end
		end
		Battle.automate(forced)
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.agatha = function()
	if Strategies.trainerBattle() then
		if Combat.isSleeping() then
			Inventory.use("pokeflute", nil, true)
			return false
		end
		if Pokemon.isOpponent("gengar") then
			if Memory.double("battle", "our_speed") < 147 then
				if Inventory.count("x_speed") > 1 then
					status.preparing = nil
				end
				if not Strategies.prepare("x_speed") then
					return false
				end
			end
		end
		Battle.automate()
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.lance = function()
	if Strategies.trainerBattle() then
		local xItem
		if Pokemon.isOpponent("dragonair") then
			xItem = "x_speed"
			if not Strategies.isPrepared(xItem) then
				local __, turnsToDie = Combat.enemyAttack()
				if turnsToDie and turnsToDie <= 1 then
					local potion = Inventory.contains("full_restore", "super_potion")
					if potion then
						Inventory.use(potion, nil, true)
						return false
					end
				end
			end
		else
			xItem = "x_special"
		end
		if Strategies.prepare(xItem) then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.blue = function()
	if Strategies.trainerBattle() then
		local xItem
		if Pokemon.isOpponent("exeggutor") then
			if Combat.isSleeping() then
				local sleepHeal
				if not Combat.inRedBar() and Inventory.contains("full_restore") then
					sleepHeal = "full_restore"
				else
					sleepHeal = "pokeflute"
				end
				Inventory.use(sleepHeal, nil, true)
				return false
			end
			xItem = "x_accuracy"
		else
			xItem = "x_special"
		end
		if Strategies.prepare(xItem) then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

-- PROCESS

function Strategies.initGame(midGame)
	if midGame then
		-- Strategies.setYolo("", true)
	end
	Control.preferredPotion = "super"
end

function Strategies.completeGameStrategy()
	status = Strategies.status
end

function Strategies.resetGame()
	status = Strategies.status
	stats = Strategies.stats
end

return Strategies
