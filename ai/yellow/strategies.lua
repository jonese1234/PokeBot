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
Strategies.warpToCerulean = false

-- TIME CONSTRAINTS

local function timeForStats(level8)
	local timeBonus = 0
	if level8 then
		if stats.nidoran.attack == 16 then
			timeBonus = timeBonus + 0.25
		end
		if stats.nidoran.speed == 15 then
			timeBonus = timeBonus + 0.3
		end
	else
		timeBonus = (stats.nidoran.attack - 53) * 0.05
		local maxSpeed = math.min(stats.nidoran.speed, 52)
		timeBonus = timeBonus + (maxSpeed - 49) * 0.125
	end
	return timeBonus
end

local function timeForFlier()
	return Pokemon.inParty("pidgey", "spearow") and 0.5 or 0
end

Strategies.timeRequirements = {

	nidoran = function()
		return 7.5 + timeForFlier()
	end,

	forest = function() --YOLO
		return 13 + timeForFlier() + timeForStats(true)
	end,

	brock = function()
		return 15 + timeForFlier() + timeForStats(true)
	end,

	mt_moon = function()
		local timeLimit = 28.25 + timeForStats(true)
		if Pokemon.inParty("paras", "sandshrew") then
			timeLimit = timeLimit + 0.25
		end
		if Pokemon.getExp() > 4200 then
			timeLimit = timeLimit + 0.15
		end
		return timeLimit
	end,

	misty = function() --TWEET
		return 41 + timeForStats()
	end,

	trash = function() --YOLO
		return 49.75 + timeForStats()
	end,

	mom = function() --YOLO
		return 90
	end,

	victory_road = function() --TWEET
		local timeLimit = 101.5
		if Strategies.requiresE4Center(true, true) then
			timeLimit = timeLimit - 0.1
		end
		return timeLimit
	end,

	blue = function() --YOLO
		return 112.28
	end,

	champion = function() --PB
		return 115.28
	end,

}

-- HELPERS

local function nidoranDSum(enabled)
	local px, py = Player.position()
	if enabled and status.path == nil then
		local opponentName = Battle.opponent()
		local opponentLevel = Memory.value("battle", "opponent_level")
		local runOffset, waitOffset, searchDuration
		if opponentName == "rattata" then
			if opponentLevel == 3 then
				waitOffset = 1.3
				searchDuration = 3.2
			elseif opponentLevel == 4 then
				waitOffset = 9.0
				searchDuration = 2.6
			end
			runOffset = 570
		elseif opponentName == "pidgey" then
			if opponentLevel == 3 then
				waitOffset = -1.1
				searchDuration = 3.2
			elseif opponentLevel == 5 then
				waitOffset = 4.7
				searchDuration = 1.9
			elseif opponentLevel == 7 then
				waitOffset = 2.1
				searchDuration = 1.4
			end
			runOffset = 562
		elseif opponentName == "nidoran" then
			if opponentLevel == 4 then
				waitOffset = 6.3
				searchDuration = 1.9
			end
			runOffset = 615
		elseif opponentName == "nidoranf" then
			if opponentLevel == 4 then
				waitOffset = 5.6
				searchDuration = 1.9
			elseif opponentLevel == 6 then
				waitOffset = 2.5
				searchDuration = 1.3
			end
			runOffset = 581
		end
		if waitOffset then
			local waitDuration = 12.8 - searchDuration
			status.path = {waitOffset, searchDuration, waitDuration, searchDuration, waitDuration}
			status.pathIndex = 1
			status.startTime = status.startTime + runOffset
		else
			status.path = 0
		end
	end

	local dx, dy = px, py
	local cornerBonk = true
	local encounterlessSteps = Memory.value("game", "encounterless")
	local pikachuX = Memory.value("player", "pikachu_x") - 4
	if enabled and status.path ~= 0 then
		local duration = status.path[status.pathIndex] * 60
		if Utils.frames() - status.startTime >= duration then
			status.startTime = status.startTime + duration
			if status.pathIndex >= #status.path then
				status.path = 0
			else
				status.pathIndex = status.pathIndex + 1
			end
			return nidoranDSum(enabled)
		end
		local walkOutside = (status.pathIndex - 1) % 2 == 0
		if walkOutside then
			cornerBonk = false
			if dy ~= 48 then
				if px == 3 then
					dy = 48
				else
					dx = 3
				end
			elseif encounterlessSteps <= 1 then
				if px < 3 then
					dx = 3
				elseif pikachuX > px then
					dx = 2
				end
			elseif encounterlessSteps == 2 then
				if px == 4 then
					dx = 3
				else
					dx = 4
				end
			elseif encounterlessSteps > 2 then
				if px == 3 then
					dx = 2
				else
					dx = 3
				end
			end
		end
	end
	if cornerBonk then
		if px == 4 and py == 48 and pikachuX >= px then
			dx = px + 1
		elseif px >= 4 and py == 48 then
			if encounterlessSteps == 0 then
				if not status.bonkWait then
					local direction, duration
					if Player.isFacing("Up") then
						direction = "Left"
						duration = 2
					else
						direction = "Up"
						duration = 3
					end
					Input.press(direction, duration)
				end
				status.bonkWait = not status.bonkWait
				return
			end
			if encounterlessSteps == 1 and dx <= 6 then
				dx = px + 1
			elseif dx ~= 3 then
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
	Walk.step(dx, dy, true)
end

local function depositPikachu()
	if Menu.isOpened() then
		local pc = Memory.value("menu", "size")
		if Memory.value("battle", "menu") ~= 19 then
			local menuColumn = Menu.getCol()
			if menuColumn == 5 then
				if Menu.select(Pokemon.indexOf("pikachu")) then
					Strategies.chat("pika", Utils.random {
						" PIKA PIIKA",
						" NNOOO PIKAAA",
						" Goodbye, Pikachu BibleThump",
						" RIP in PC, Pikachu.", --
						" I don't know how else to say this, but Nido and I are going steady now. Goodbye, Pikachu.",
						" You're cute, Pikachu. But this is a speedrun, and frankly you're getting in my way.",
						"come with me the time is right, there's no better team.... oh you're my best friend in a world we must defend... *stores Pikachu in pc*", --alloces
						" ... and nothing of value was lost.", --mymla
						" Now Pikachu is in Pikajail because it gets in the Pikaway.", --0xAbad1dea
						" A little bit of Pikachu by my side... Just kidding!", --KatieW25
						" #moofydraws https://twitter.com/moofinseeker/status/597845848253423617", --moofinseeker
					})
				end
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
	local hornAttacks = Pokemon.pp(0, "horn_attack")
	local completedCenter
	if pp then
		completedCenter = hornAttacks > pp
	else
		completedCenter = hornAttacks == 25

		if not completedCenter and Strategies.warpToCerulean then
			completedCenter = Combat.hp() + Inventory.count("potion") * 20 >= 70
		end
	end
	if Strategies.initialize("reported") then
		local centerAction
		if completedCenter then
			centerAction = "skipping"
		else
			centerAction = "taking"
		end
		local centerReason
		if pp then
			centerReason = "with "..Utils.pluralize(Pokemon.pp(0, "horn_attack"), "Horn Attack").." ("..(pp+1).." required)."
		elseif not Strategies.warpToCerulean then
			centerReason = "to set our warp point to Cerulean."
		else
			centerReason = "to heal before Misty."
		end
		Bridge.chat("is "..centerAction.." the Center "..centerReason)

		if completedCenter and Strategies.warpToCerulean then
			return true
		end
	end

	local dx, dy = px, py
	if currentMap == startMap then
		if not completedCenter then
			if px ~= entranceX then
				dx = entranceX
			else
				dy = entranceY
			end
		else
			if not finishX or px == finishX then
				Combat.factorPP(nil, false)
				return true
			end
			dx = finishX
		end
	else
		if Pokemon.inParty("pikachu") then
			if py > 5 then
				dy = 5
			elseif px < 13 then
				local cx, cy = Memory.raw(0x0223) + 2, Memory.raw(0x0222) - 3
				if currentMap == 64 and cx == px + 1 and cy == py then
					if py == 4 then
						dy = 5
					else
						dy = 4
					end
				else
					dx = 13
				end
			elseif py ~= 4 then
				dy = 4
			else
				return depositPikachu()
			end
		else
			if Strategies.initialize("deposited") then
				Bridge.caught("deposited")
			end
			if px ~= 3 then
				if Menu.close() then
					local cx, cy = Memory.raw(0x0223) + 2, Memory.raw(0x0222) - 3
					if currentMap == 64 and cx == px - 1 and cy == py then
						if py == 4 then
							dy = 5
						else
							dy = 4
						end
					else
						dx = 3
					end
				end
			elseif completedCenter then
				if Textbox.handle() then
					dy = 8
				end
			elseif py > 3 then
				dy = 3
			else
				strategyFunctions.dialogue({dir="Up"})
			end
		end
	end
	Walk.step(dx, dy)
end

-- STRATEGIES

strategyFunctions.gotPikachu = function()
	Bridge.caught("pikachu")
	Pokemon.updateParty()
	return true
end

strategyFunctions.fightEevee = function()
	if Strategies.trainerBattle() then
		if Combat.hp() == 0 and Strategies.initialize("died") then
			Strategies.vaporeon = true
		end
		Battle.automate()
	elseif status.foughtTrainer then
		return true
	end
end

-- dodgePalletBoy

strategyFunctions.shopViridianPokeballs = function()
	return Shop.transaction {
		buy = {{name="pokeball", index=0, amount=4}, {name="potion", index=1, amount=6}}
	}
end

strategyFunctions.catchNidoran = function()
	if Battle.isActive() then
		local catchableNidoran = Pokemon.isOpponent("nidoran") and Memory.value("battle", "opponent_level") == 6
		if not status.inBattle then
			status.inBattle = true
			status.startTime = Utils.frames()
			if catchableNidoran and Strategies.initialize("naming") then
				Bridge.pollForName()
			end
			status.path = nil
		end
		if Memory.value("battle", "menu") == 94 then
			if not Control.canCatch() then --TODO move to top
				return true
			end
		end
		if Memory.value("menu", "text_input") == 240 then
			Textbox.name()
		elseif Menu.hasTextbox() then
			Input.press(catchableNidoran and "A" or "B")
		else
			Battle.handle()
		end
	else
		if status.inBattle then
			status.inBattle = false
			Pokemon.updateParty()
		end
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
			local enableDSum = status.startTime and (not RESET_FOR_TIME or not Strategies.overMinute(resetLimit - 0.1))
			nidoranDSum(enableDSum)
		end
	end
end

strategyFunctions.leerCaterpies = function()
	if not status.secondCaterpie and not Battle.opponentAlive() then
		status.secondCaterpie = true
	end
	local leerAmount = status.secondCaterpie and 7 or 10
	return strategyFunctions.leer {{"caterpie", leerAmount}}
end

-- checkNidoranStats

strategyFunctions.leerMetapod = function()
	return strategyFunctions.leer {{"caterpie",9}, {"metapod",11}}
end

strategyFunctions.centerViridian = function()
	if Strategies.initialize() then
		local riskTackling = Pokemon.pp(0, "horn_attack") >= 19
		Combat.factorPP(true, riskTackling)
	end
	local minimumHornAttacks = 15
	if stats.nidoran.attack == 16 then
		minimumHornAttacks = minimumHornAttacks - 1
	end
	return takeCenter(minimumHornAttacks, 2, 13, 25, 18)
end

strategyFunctions.fightSandshrew = function()
	local forced
	if Pokemon.isOpponent("sandshrew") then
		local __, turnsToKill, turnsToDie = Combat.bestMove()
		if turnsToKill then
			if turnsToKill > (Control.yolo and 2 or 1) and turnsToDie <= 2 then
				local enemyMove = Combat.enemyAttack()
				local damage = math.floor(enemyMove.damage * 1.8)
				if Combat.hp() < damage and Inventory.contains("potion") then
					Inventory.use("potion", "nidoran", true)
					return false
				end
			end
			if turnsToKill == 3 then
				forced = "tackle"
			end
		end
	end
	return strategyFunctions.leer {{"sandshrew", 14, forced=forced}}
end

strategyFunctions.fightBrock = function()
	local curr_hp = Pokemon.info("nidoran", "hp")
	if curr_hp == 0 then
		return Strategies.death()
	end
	if Strategies.trainerBattle() then
		local forced
		if Pokemon.isOpponent("onix") then
			local __, turnsToKill, turnsToDie = Combat.bestMove()
			if turnsToKill then
				if turnsToDie < 2 and Inventory.contains("potion") then
					Inventory.use("potion", "nidoran", true)
					return false
				end
				local bideTurns = Memory.value("battle", "opponent_bide")
				if bideTurns > 0 then
					local onixHP = Memory.double("battle", "opponent_hp")
					if not status.bideHP then
						status.bideHP = onixHP
						status.startBide = bideTurns
					end
					local hasDamaged = onixHP ~= status.bideHP
					if turnsToKill > 2 then
						forced = "leer"
					elseif turnsToKill == 1 then
					elseif hasDamaged and status.startBide - bideTurns > 1 then
					elseif turnsToKill == 2 and status.startBide == bideTurns then
					elseif not hasDamaged then
						forced = "leer"
					end
				else
					status.bideHP = nil
				end
				if turnsToKill > 2 then
					forced = "leer"
				end
			end
		end
		Battle.automate(forced)
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.conserveHornAttacks = function()
	local riskDamageRanges = false
	if Pokemon.inParty("pikachu") then
		local hornAttacks = Pokemon.pp(0, "horn_attack")
		local ppRequired = 16
		if stats.nidoran.attack == 16 then
			ppRequired = ppRequired - 1
			if stats.nidoran.speed == 15 then
				ppRequired = ppRequired - 1
			end
		end

		local potionCount = Inventory.count("potion")
		local potionsRequired = 3
		if Control.yolo or stats.nidoran.speed == 15 then
			potionsRequired = potionsRequired - 1
		end
		p(hornAttacks, ppRequired, potionCount, potionsRequired)
		if potionCount >= potionsRequired and hornAttacks >= ppRequired then
			Bridge.chat("is risking some damage ranges to attempt to double Center skip...")
			riskDamageRanges = true
		end
	end
	Combat.factorPP(true, riskDamageRanges)
	return true
end

strategyFunctions.fightNidoran = function()
	if Strategies.trainerBattle() then
		local enemyMove = Combat.enemyAttack()
		if enemyMove then
			Control.battlePotion(Combat.hp() <= enemyMove.damage)
		end
		Battle.automate()
	elseif status.foughtTrainer then
		Control.battlePotion(true)
		return true
	end
end

strategyFunctions.reload = function(data)
	local message = "is reloading the "
	if data.area == "route3" then
		message = message.."route to save time by bypassing a difficult trainer."
	elseif data.area == "giovanni" then
		message = message.."Gym to move the trainer and head straight to Giovanni as fast as possible."
	end
	Bridge.chat(message)
	return true
end

-- fightMetapod TODO

strategyFunctions.centerMoon = function()
	local minimumHornAttacks = 5
	if stats.nidoran.attack == 16 then
		minimumHornAttacks = minimumHornAttacks - 1
	end
	return takeCenter(minimumHornAttacks, 15, 11, 5, 12)
end

strategyFunctions.centerCerulean = function(data)
	local ppRequired, finishX
	local firstTrip = not data.second

	if firstTrip then
		ppRequired = 10
		finishX = 8

		local hornAttacks = Pokemon.pp(0, "horn_attack")
		local hasSufficientPP = hornAttacks > ppRequired

		if Strategies.initialize() then
			Combat.factorPP(hasSufficientPP, false)
			Strategies.warpToCerulean = not hasSufficientPP
		end

		if Memory.value("game", "map") == 3 then
			if hasSufficientPP then
				local px, py = Player.position()
				if px > 8 then
					return strategyFunctions.dodgeCerulean({left=true})
				end
			elseif not strategyFunctions.dodgeCerulean({}) then
				return false
			end
		end
	else
		finishX = 22
	end
	return takeCenter(ppRequired, 3, 19, 17, finishX)
end

strategyFunctions.fightKoffing = function(data)
	if Strategies.trainerBattle() then
		local forced
		local opponent = Battle.opponent()
		if opponent == "voltorb" then
			if Battle.pp("horn_attack") < data.min + 1 then
				forced = "double_kick"
			end
		elseif opponent == "koffing" then
			if Strategies.initialize("check_leer") then
				status.leering = Combat.isDisabled("horn_attack") or Battle.pp("horn_attack") < data.min
			end
			if status.leering then
				if not Battle.opponentDamaged() then
					forced = "tackle"
				end
				return Strategies.buffTo("leer", 25, forced)
			end
		end
		Battle.automate(forced)
	elseif status.foughtTrainer then
		return true
	end
end

-- reportMtMoon

-- 4: Mt. Moon

strategyFunctions.rivalSandAttack = function()
	if Strategies.trainerBattle() then
		if Battle.redeployNidoking() then
			local sacrifice = Battle.deployed()
			if sacrifice then
				Strategies.chat("sacrificed", "got Sand-Attack'd twice... Swapping out "..Utils.capitalize(sacrifice).." to restore accuracy.")
			end
			return false
		end
		local forced
		local accuracy = Memory.value("battle", "accuracy")
		local opponentSandshrew = Pokemon.isOpponent("sandshrew")
		if opponentSandshrew then
			forced = "horn_attack"
		end
		if accuracy < 7 then
			if opponentSandshrew then
				local sacrifice = Pokemon.getSacrifice("pidgey", "spearow")
				if sacrifice then
					local threshold = (Control.yolo or Pokemon.info(sacrifice, "level") > 4) and 5 or 6
					if accuracy < threshold then
						local __, turnsToKill = Combat.bestMove()
						if turnsToKill and turnsToKill == 1 then
							if sacrifice and Battle.sacrifice(sacrifice) then
								return false
							end
						end
					end
				end
			elseif not Pokemon.isOpponent("eevee") then --TODO
				Strategies.chat("sacrificed", "got Sand-Attack'd... Attempting to hit through it.")
			end
		end
		Battle.automate(forced)
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.acquireCharmander = function()
	if Strategies.initialize() then
		if Pokemon.inParty("sandshrew", "paras") then
			Bridge.chat("caught a Paras/Sandshrew in Mt. Moon! This skips having to get Charmander here.")
			return true
		end
	end
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
	if Pokemon.inParty("charmander") then
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

-- potionBeforeMisty

-- fightMisty

-- 6: MISTY

-- jingleSkip

strategyFunctions.shopVermilionMart = function()
	-- if Strategies.initialize() then
	-- 	Strategies.setYolo("vermilion")
	-- end
	local supers = Strategies.vaporeon and 7 or 8
	return Shop.transaction {
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

-- fourTurnThrash

-- announceVenonat

-- announceOddish

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

	local sellArray = {{name="nugget"}}
	if Inventory.containsAll("pokeball", "potion") then --TODO , "ether"
		if INTERNAL and Strategies.initialize("pokeball") then
			print("Selling Pokeballs to make up inventory space")
		end
		table.insert(sellArray, {name="pokeball"})
	end
	return Shop.transaction {
		direction = "Right",
		sell = sellArray,
		buy = {{name="x_accuracy", index=0, amount=xAccs}, {name="x_speed", index=5, amount=xSpeeds}, {name="x_attack", index=3, amount=3}, {name="x_special", index=6, amount=5}},
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
			Battle.automate("horn_drill")
		end
	elseif status.foughtTrainer then
		return true
	end
end

-- digFight

-- pokeDoll

-- drivebyRareCandy

-- silphElevator

-- silphCarbos

strategyFunctions.useSilphCarbos = function(data)
	if Strategies.getsSilphCarbosSpecially() then --TODO inventory count
		data.item = "carbos"
		data.poke = "nidoking"
		return strategyFunctions.item(data)
	end
	if Strategies.closeMenuFor(data) then
		return true
	end
end

strategyFunctions.silphRival = function()
	if Strategies.trainerBattle() then
		if Strategies.prepare("x_accuracy") then
			local forced = "horn_drill"
			local prepare
			local opponentName = Battle.opponent()
			if opponentName == "sandslash" then
				if not Strategies.isPrepared("x_speed") then
					local __, __, turnsToDie = Combat.bestMove()
					if turnsToDie and turnsToDie < 2 then
						Strategies.chat("magneton", "is in range to die to Sandslash after that, we'll need to risk finishing setting up against Magneton.")
					else
						prepare = true
					end
				end
			elseif opponentName == "magneton" then
				if Combat.hp() <= 20 and not Strategies.isPrepared("x_speed") then
					if Inventory.contains("super_potion") then
						if Strategies.initialize("heals") then
							local message
							if Strategies.yolo then
								message = "is risking Sonicboom/Confusion to save time."
							else
								message = "is in range to die to Sonicboom/Confusion, healing up to play it safe."
							end
							Bridge.chat(message)
						end
						if not Strategies.yolo then
							Inventory.use("super_potion", nil, true)
							return false
						end
					end
				end
				prepare = true
			elseif opponentName == "kadabra" then
				forced = "earthquake"
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
			if Combat.isSleeping() then
				Inventory.use("pokeflute", nil, true)
				return false
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
		return true
	end
end

strategyFunctions.momHeal = function()
	if Strategies.initialize() then
		Strategies.setYolo("mom")

		local ppItemsRequired = Strategies.vaporeon and 3 or 2
		status.momHeal = Inventory.ppRestoreCount() < ppItemsRequired or Combat.hp() + 50 < (Control.yolo and Combat.healthFor("BlaineNinetails") or 96)
		local message
		if status.momHeal then
			message = "healing with mom before Blaine."
		else
			message = "elixering to skip healing with mom."
		end
		Bridge.chat("is "..message)
	end
	local needsHeal = status.momHeal and Pokemon.pp(0, "earthquake") < 10

	local currentMap = Memory.value("game", "map")
	local px, py = Player.position()
	local dx, dy = px, py
	if currentMap == 0 then
		if needsHeal then
			dy = 5
		elseif py == 6 then
			return true
		end
		Walk.step(dx, dy)
	else
		if Textbox.isActive() then
			Input.cancel()
		elseif needsHeal and px == 5 and py == 5 then
			Player.interact("Up")
		else
			local momPath = {{2,7}, {2,6}, {5,6}, {5,5}, {5,6}, {3,6}, {3,8}}
			Walk.custom(momPath)
		end
	end
end

-- dodgeGirl

-- cinnabarCarbos

strategyFunctions.fightBlaine = function()
	if Strategies.trainerBattle() then
		if Combat.hasParalyzeStatus() then
			if Inventory.contains("full_restore") then
				Strategies.chat("status_recover", "got Burned by Flamethrower. Attempting to recover with a Full Restore...")
				Inventory.use("full_restore", nil, true)
				return false
			end
			Strategies.chat("status_lost", "got Burned by Flamethrower without a Full Restore :(")
		end
		if Strategies.prepare("x_attack") then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.fightGiovanni = function()
	if Strategies.trainerBattle() then
		Strategies.chat("critical", " Giovanni can end the run here with Dugtrio and Persian's high chance to critical...")
		if Strategies.prepare("x_speed") then
			local forced
			local prepareAccuracy
			local opponent = Battle.opponent()
			if opponent == "persian" then
				prepareAccuracy = true
				if not Strategies.isPrepared("x_accuracy") then
					local __, turnsToDie = Combat.enemyAttack()
					if turnsToDie and turnsToDie == 1 then
						Strategies.chat("persian", "needs to finish setting up against Persian...")
					end
				end
			elseif opponent == "dugtrio" then
				prepareAccuracy = Memory.value("battle", "attack_turns") > 0
				if prepareAccuracy then
					Strategies.chat("dig", "got Dig, which gives an extra turn to set up with X Accuracy. No critical!")
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

-- GIOVANNI

strategyFunctions.potionBeforeViridianRival = function(data)
	if Strategies.vaporeon then
		data.hp = 120
		data.yolo = 64
	else
		data.hp = 64
	end
	return strategyFunctions.potion(data)
end

strategyFunctions.useViridianEther = function(data)
	if Strategies.initialize() then
		if not Strategies.vaporeon then
			return true
		end
	end
	return strategyFunctions.ether(data)
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

-- centerSkip

strategyFunctions.shopFullRestores = function()
	if Strategies.initialize() then
		Control.preferredPotion = "full"
		local fullRestores = Inventory.count("full_restore")
		local restoresRequired
		if Control.yolo then
			restoresRequired = 1
		else
			restoresRequired = 2
		end
		if fullRestores >= restoresRequired then --RISK
			if fullRestores == 1 then
				Bridge.chat("is skipping buying extra Full Restores to attempt to make up more time on the Elite 4.")
			end
			return true
		end
	end
	local px, py = Player.position()
	if px == 2 and py == 5 then
		return Shop.transaction {
			buy = {{name="full_restore", index=2, amount=3}}
		}
	end
	Walk.step(2, 5)
end

strategyFunctions.lorelei = function()
	if Strategies.trainerBattle() then
		local opponentName = Battle.opponent()
		if opponentName == "dewgong" then
			Strategies.elite4Reason = "dewgong"
			if Memory.double("battle", "our_speed") < 121 then
				Strategies.chat("speedfall", "got speed fall from Dewgong D: Attempting to recover with X Speed, we need a Rest...")
				if not Strategies.prepare("x_speed") then
					return false
				end
			end
		else
			Strategies.elite4Reason = nil
		end
		if Strategies.prepare("x_accuracy") then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.potionBeforeBruno = function(data)
	data.hp = 32
	data.topOff = true
	if Control.yolo and Combat.inRedBar() then
		data.yolo = 13
	end

	if Strategies.initialize() then
		if data.yolo and Combat.hp() >= data.yolo then
			Bridge.chat("is attempting to make back more time by carrying red-bar through Bruno...")
		end
	end
	return strategyFunctions.potion(data)
end

strategyFunctions.bruno = function()
	if Strategies.trainerBattle() then
		if Combat.hasParalyzeStatus() then
			if Inventory.contains("full_restore") then
				Strategies.chat("status_recover", "is attempting to recover from Hitmonchan's status change with a Full Restore...")
				Inventory.use("full_restore", nil, true)
				return false
			end
			Strategies.chat("status_lost", "got a status change from Hitmonchan, without a Full Restore to cure :(")
		end

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

strategyFunctions.potionBeforeAgatha = function(data)
	data.hp = 64
	data.yolo = 32
	data.topOff = true

	if Strategies.initialize() and Control.yolo then
		local curr_hp = Combat.hp()
		if curr_hp < data.hp and curr_hp >= data.yolo then
			Bridge.chat("is attempting to make back more time by red-barring off Agatha.")
		end
	end
	return strategyFunctions.potion(data)
end

strategyFunctions.agatha = function()
	if Strategies.trainerBattle() then
		local forced
		local preparing = false
		if Pokemon.isOpponent("gengar") then
			if status.firstGengar == nil then
				status.firstGengar = true
			end
			preparing = Memory.double("battle", "our_speed") < 147
			if preparing and status.firstGengar and status.didParalyze then
				if Inventory.count("x_speed") > 1 then
					status.preparing = nil
				end
			end
		else
			if status.firstGengar then
				status.firstGengar = false
			end
			if Pokemon.isOpponent("golbat") then
				forced = "thunderbolt"
			end
		end
		if preparing and not Strategies.prepare("x_speed") then
			return false
		end

		if Combat.isParalyzed() then
			status.didParalyze = true
			if Inventory.contains("full_restore") then
				Inventory.use("full_restore", nil, true)
				return false
			end
		elseif Combat.isSleeping() then
			Inventory.use("pokeflute", nil, true)
			return false
		end
		Battle.automate(forced)
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.lance = function()
	if Strategies.trainerBattle() then
		local xItem
		local opponentName = Battle.opponent()
		if opponentName == "gyarados" then
			xItem = "x_special"
			Strategies.elite4Reason = "gyarados"
		else
			Strategies.elite4Reason = nil
			if opponentName == "dragonair" then
				xItem = "x_speed"
				if Memory.value("battle", "cooldown") == 0 and not Strategies.isPrepared(xItem) then
					local __, turnsToDie = Combat.enemyAttack()
					if turnsToDie and turnsToDie == 1 then
						local potion = Inventory.contains("full_restore", "super_potion")
						if potion ~= "full_restore" then
							Strategies.chat("dragonair", "ran out of Full Restores, we'll need to get lucky setting up on Dragonair...")
						end
						if potion then
							Inventory.use(potion, nil, true)
							return false
						end
					end
				end
			end
		end
		if Strategies.prepare(xItem) then
			Battle.automate()
		end
	elseif status.foughtTrainer then
		return true
	end
end

strategyFunctions.prepareForBlue = function()
	if Strategies.initialize() then
		local message, healSkip
		if Strategies.setYolo("blue") then
			local healLimit = Strategies.getTimeRequirement("blue") + 0.25
			healSkip = Strategies.overMinute(healLimit)
			if healSkip then
				message = "is attempting to skip healing and yolofreeze Sandslash to make up even more time..."
			else
				message = "is attempting to freeze/crit Sandslash to make up more time..."
			end
		elseif Strategies.hasHealthFor("GarySandslash", 0, true) then
			message = "has enough health to tank Sandslash... Let's go!"
			healSkip = true
		elseif Inventory.contains("full_restore") or Strategies.canHealFor("GarySandslash", true, true) or Strategies.hasSupersFor("GarySandslash") then
			message = "is healing for Sandslash..."
		else
			message = "is unable to heal for Sandslash... Looks like we're going to have to freeze!"
			Control.wantedPotion = true
			healSkip = true
		end
		Bridge.chat(message)
		if healSkip then
			return true
		end
	end

	return strategyFunctions.potion({hp="GarySandslash", full=true})
end

strategyFunctions.blue = function()
	if Strategies.trainerBattle() then
		local forced, xItem
		local opponentName = Battle.opponent()
		if opponentName == "sandslash" then
			if Memory.raw(0x0FE9) == 32 then
				Strategies.chat("froze", "froze Sandslash Kreygasm Finishing setup now...")
				if Strategies.isPrepared("x_speed") or Strategies.isPrepared("x_special") then
					xItem = "x_accuracy"
				else
					if stats.nidoran.speedDV <= 7 then
						xItem = Inventory.contains("x_speed", "x_special")
					else
						xItem = Inventory.contains("x_special", "x_speed")
					end
				end
			elseif not Control.yolo and Strategies.hasHealthFor("GarySandslash", 0, true) then
				xItem = "x_special"
			end
			Strategies.elite4Reason = "sandslash"
		else
			Strategies.elite4Reason = nil
			if opponentName == "alakazam" then
				local __, turnsToKill, turnsToDie = Combat.bestMove()
				if turnsToDie == 1 then
					local ourSpeed, theirSpeed = Memory.double("battle", "our_speed"), Memory.double("battle", "opponent_speed")
					if ourSpeed <= theirSpeed then
						local speedMessage, canPotion
						if Battle.damaged() then
							if ourSpeed == theirSpeed then
								speedMessage = "we'll need to get lucky to win this speed tie vs. Alakazam..."
								canPotion = not Data.yolo and Inventory.contains("full_restore")
							else
								canPotion = Inventory.contains("full_restore")
								speedMessage = "with no Full Restores left, we'll need to get lucky..."
							end
							if canPotion then
								speedMessage = "attempting to wait out a non-damage turn."
							end
						else
							speedMessage = "we'll need to get lucky vs. Alakazam here..."
						end
						Strategies.chat("outsped", " Bad speed, "..speedMessage)
						if canPotion then
							Inventory.use("full_restore", nil, true)
							return false
						end
					end
				end
				if Combat.sandAttacked() and not Strategies.isPrepared("x_accuracy") then
					if Menu.onBattleSelect() and Battle.opponentAlive() then
						Strategies.chat("kinesis", "got Kinesis'd, we'll need to risk setting up X Accuracy vs. Alakazam.")
					end
					xItem = "x_accuracy"
				elseif turnsToKill and turnsToKill > 1 and not Strategies.isPrepared("x_speed") and not Strategies.isPrepared("x_special") then
					local message
					if stats.nidoran.speedDV <= 7 then
						xItem = Inventory.contains("x_speed", "x_special")
					else
						xItem = Inventory.contains("x_special", "x_speed")
					end
					if xItem then
						message = " We'll need to set up vs. Alakazam here to 1-shot it..."
					else
						message = " We'll need to get lucky vs. Alakazam here to 1-shot it..."
					end
					Strategies.chat("outsped", message)
				end
			elseif opponentName == "exeggutor" then
				if Combat.isSleeping() then
					local sleepHeal
					if not Combat.inRedBar() and Battle.damaged() and Inventory.contains("full_restore") then
						sleepHeal = "full_restore"
					else
						sleepHeal = "pokeflute"
					end
					Inventory.use(sleepHeal, nil, true)
					return false
				end
				xItem = "x_accuracy"
			end
		end
		if Strategies.prepare(xItem) then
			if Combat.xAccuracy() and opponentName ~= "sandslash" then
				forced = "horn_drill"
			end
			Battle.automate(forced)
		end
	elseif status.foughtTrainer then
		return true
	end
end

-- PROCESS

function Strategies.initGame(midGame)
	if midGame then
		-- Strategies.setYolo("nidoran", true)
		-- Strategies.vaporeon = true
	end
	Control.preferredPotion = "super"
end

function Strategies.completeGameStrategy()
	status = Strategies.status
end

function Strategies.resetGame()
	status = Strategies.status
	stats = Strategies.stats

	Strategies.vaporeon = false
	Strategies.warpToCerulean = false
end

return Strategies
