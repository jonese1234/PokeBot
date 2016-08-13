local Strategies = {}

local Combat = require "ai.combat"
local Control = require "ai.control"

local Battle = require "action.battle"
local Textbox = require "action.textbox"
local Walk = require "action.walk"

local Data = require "data.data"

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Player = require "util.player"
local Shop = require "action.shop"
local Utils = require "util.utils"
local json = require "external.json"

local Inventory = require "storage.inventory"
local Pokemon = require "storage.pokemon"

local splitNumber, splitTime = 0, 0
local resetting

local status = {tries = 0, canProgress = nil, initialized = false}
local stats = {}
Strategies.status = status
Strategies.stats = stats
Strategies.updates = {}
Strategies.deepRun = false

local strategyFunctions

-- RISK/RESET

function Strategies.getTimeRequirement(name)
	local timeCalculation = Strategies.timeRequirements[name]
	if timeCalculation then
		return timeCalculation()
	end
end

function Strategies.reboot()
	if emu.framecount() >= 120 then
		client.pause()
		joypad.set({["Power"] = true})
		client.unpause()
		return
	else
		return
	end
end

function Strategies.hardReset(reason, message, extra, wait)
	resetting = true
	if Data.run.seed then
		if extra then
			extra = extra.." | "..Data.run.seed
		else
			extra = Data.run.seed
		end
	end

	local seed = Data.run.seed
	local newmessage = message.." | "..seed

	local f,  err = io.open(RUNS_FILE, "a")
	if f==nil then
		print("Couldn't open file: "..err)
	else
		f:write(newmessage.."\n")
		f:close()
	end

	local map, px, py = Memory.value("game", "map"), Player.position()
	Data.reset(reason, Control.areaName, map, px, py, stats)
	Bridge.chat(message, false, extra, true)

	if Strategies.elite4Reason then
		Bridge.guessResults("elite4", Strategies.elite4Reason)
		Strategies.elite4Reason = nil
	end

	if Strategies.deepRun then
		p("", true)
		p("", true)
		p("", true)
	end

	if wait and INTERNAL and not STREAMING_MODE then
		strategyFunctions.wait()
	else
		Strategies.reboot()
	end
	return true
end

function Strategies.reset(reason, explanation, extra, wait)
	local time = Utils.elapsedTime()
	local resetMessage = "Reset"
	resetMessage = resetMessage.." at "..Control.areaName
	if time then
		resetMessage = resetMessage.." | "..time
	end
	local separator
	if Strategies.deepRun and not Control.yolo then
		separator = " BibleThump"
	else
		separator = " | "
	end
	resetMessage = resetMessage..separator.." "..explanation.."."

	if Strategies.updates.victory and not Control.yolo then
		Strategies.tweetProgress(Utils.capitalize(resetMessage))
	end

	return Strategies.hardReset(reason, resetMessage, extra, wait)
end

function Strategies.death(extra)
	local reason, explanation
	if Control.missed then
		explanation = "Missed"
		reason = "miss"
	elseif Control.wantedPotion then
		explanation = "Ran out of potions"
		reason = "potion"
	elseif Control.criticaled then
		explanation = "Critical'd"
		reason = "critical"
	elseif Combat.sandAttacked() then
		explanation = "Sand-Attack'd"
		reason = "accuracy"
	elseif Combat.isConfused() then
		explanation = "Confusion'd"
		reason = "confusion"
	elseif Combat.isSleeping() then
		explanation = "Slumbering"
		reason = "sleep"
	elseif Control.yolo then
		explanation = "Yolo strats"
		reason = "yolo"
	else
		explanation = "Died"
		reason = "death"
	end
	return Strategies.reset(reason, explanation, extra)
end

function Strategies.overMinute(min)
	if type(min) == "string" then
		min = Strategies.getTimeRequirement(min)
	end
	return min and Utils.igt() > (min * 60)
end

function Strategies.resetTime(timeLimit, explanation, custom)
	if Strategies.overMinute(timeLimit) then
		if RESET_FOR_TIME then
			if not custom then
				explanation = "Took too long to "..explanation
			end
			return Strategies.reset("time", explanation)
		end
	end
end

function Strategies.setYolo(name, forced)
	local minimumTime = Strategies.getTimeRequirement(name)
	if minimumTime and (forced or RESET_FOR_TIME) then
		local shouldYolo = BEAST_MODE or Strategies.overMinute(minimumTime)
		if Control.yolo ~= shouldYolo then
			Control.yolo = shouldYolo
			Control.setYolo(shouldYolo)
			local prefix
			if Control.yolo then
				prefix = "en"
			else
				prefix = "dis"
			end
			print("YOLO "..prefix.."abled at "..Control.areaName)
		end
	end
	return Control.yolo
end

function Strategies.paceMessage(time)
	Strategies.pbPace = not Strategies.overMinute(time)
	return Utils.elapsedTime(), Strategies.pbPace and " (PB pace)" or ""
end

-- HELPERS

function Strategies.tweetProgress(message, progress)
	if progress then
		Strategies.updates[progress] = true
		message = message.." Pokemon "..Utils.capitalize(Data.gameName).." http://www.twitch.tv/thepokebot"
	end
	-- Bridge.tweet(message)
	return true
end

function Strategies.initialize(once)
	if not once then
		once = "initialized"
	end
	if not status[once] then
		status[once] = true
		return true
	end
end

function Strategies.chat(once, message)
	if Strategies.initialize(once) then
		Bridge.chat(message)
	end
end

function Strategies.canHealFor(damage, allowAlreadyHealed, allowFullRestore)
	if type(damage) == "string" then
		damage = Combat.healthFor(damage)
	end
	local curr_hp, max_hp = Combat.hp(), Combat.maxHP()
	if allowAlreadyHealed and curr_hp > math.min(damage, max_hp - 1) then
		return true
	end
	if max_hp - curr_hp > 3 then
		local healChecks = {"super_potion", "potion"}
		if allowFullRestore then
			table.insert(healChecks, 1, "full_restore")
		end
		for __,potion in ipairs(healChecks) do
			if Inventory.contains(potion) and Utils.canPotionWith(potion, damage, curr_hp, max_hp) then
				return potion
			end
		end
	end
end

function Strategies.hasSupersFor(damage)
	local healTo = math.min(Combat.healthFor(damage), Combat.maxHP())
	return Inventory.count("super_potion") >= math.ceil((healTo - Combat.hp()) / 50)
end

function Strategies.hasHealthFor(opponent, extra, allowFull)
	if not extra then
		extra = 0
	end
	local max_hp = Combat.maxHP()
	local afterHealth = math.min(Combat.hp() + extra, max_hp)
	if allowFull and afterHealth == max_hp then
		return true
	end
	return afterHealth > Combat.healthFor(opponent)
end

function Strategies.trainerBattle()
	local battleStatus = Memory.value("game", "battle")
	if battleStatus > 0 then
		if battleStatus == 2 then
			Strategies.initialize("foughtTrainer")
			return true
		end
		Battle.handleWild(battleStatus)
	else
		Textbox.handle()
	end
end

local function interact(direction, extended)
	if Battle.handleWild() then
		if Battle.isActive() then
			return true
		end
		if Textbox.isActive() then
			if status.interacted then
				return true
			end
			Input.cancel()
		else
			if status.attempts and status.attempts > 0 then
				status.attempts = status.attempts - 1
			elseif Player.interact(direction, extended) then
				status.interacted = true
				status.attempts = Data.yellow and 2 or 1
			end
		end
	end
end

function Strategies.buffTo(buff, defLevel, forced)
	if Strategies.trainerBattle() then
		if not Battle.opponentDamaged() then
			if defLevel and Memory.double("battle", "opponent_defense") > defLevel then
				forced = buff
			end
		end
		Battle.automate(forced, true)
	elseif status.foughtTrainer then
		return true
	end
end

function Strategies.dodgeUp(npc, sx, sy, dodge, offset)
	if not Battle.handleWild() then
		return false
	end
	local px, py = Player.position()
	if py < sy - 1 then
		return true
	end
	local wx, wy = px, py
	if py < sy then
		wy = py - 1
	elseif px == sx or px == dodge then
		if px - Memory.raw(npc) == offset then
			if px == sx then
				wx = dodge
			else
				wx = sx
			end
		else
			wy = py - 1
		end
	end
	Walk.step(wx, wy)
end

local function dodgeSideways(options)
	local left = 1
	if options.left then
		left = -1
	end
	local px, py = Player.position()
	if px * left > (options.sx + (options.dist or 1)) * left then
		return true
	end
	local wx, wy = px, py
	if px * left > options.sx * left then
		wx = px + 1 * left
	elseif py == options.sy or py == options.dodge then
		if px + left == options.npcX and py - Memory.raw(options.npc) == options.offset then
			if py == options.sy then
				wy = options.dodge
			else
				wy = options.sy
			end
		else
			wx = px + 1 * left
		end
	end
	Walk.step(wx, wy)
end

function Strategies.completedMenuFor(data)
	if status.cancel then
		return true
	end
	local count = Inventory.count(data.item)
	return count == 0 or (not data.all and status.startCount and count < status.startCount)
end

function Strategies.closeMenuFor(data)
	if data.chain or (not status.menuOpened and not data.close) then
		if Menu.onPokemonSelect() or Menu.hasTextbox() then
			Input.press("B")
			return false
		end
		return true
	end
	return Menu.close()
end

function Strategies.useItem(data)
	if not status.startCount then
		status.startCount = Inventory.count(data.item)
	end
	if not data.item or Strategies.completedMenuFor(data) then
		return Strategies.closeMenuFor(data)
	end
	if Menu.pause() then
		status.menuOpened = true
		Inventory.use(data.item, data.poke)
	end
end

function Strategies.tossItem(...)
	if not status.startCount then
		status.startCount = Inventory.count()
	elseif Inventory.count() < status.startCount then
		return true
	end
	local tossItem = Inventory.contains(...)
	if not tossItem then
		p("Nothing available to toss", ...)
		return true
	end
	if tossItem ~= status.toss then
		status.toss = tossItem
		p("Tossing "..tossItem.." to make space", Inventory.count())
	end
	if not Inventory.useItemOption(tossItem, nil, 1) then
		if Menu.pause() then
			Input.press("A")
		end
	end
end

local function completedSkillFor(data)
	if data.map then
		if data.map ~= Memory.value("game", "map") then
			return true
		end
	elseif data.x or data.y then
		local px, py = Player.position()
		if data.x == px or data.y == py then
			return true
		end
	elseif data.done then
		if Memory.raw(data.done) > (data.val or 0) then
			return true
		end
	elseif status.tries > 0 and not Menu.isOpened() then
		return true
	end
	return false
end

function Strategies.isPrepared(...)
	if not status.preparing then
		return false
	end
	for __,name in ipairs(arg) do
		local currentCount = Inventory.count(name)
		if currentCount > 0 then
			local previousCount = status.preparing[name]
			if previousCount == nil or currentCount == previousCount then
				return false
			end
		end
	end
	return true
end

function Strategies.prepare(...)
	if not status.preparing then
		status.preparing = {}
	end
	local item
	for __,name in ipairs(arg) do
		local currentCount = Inventory.count(name)
		local needsItem = currentCount > 0
		local previousCount = status.preparing[name]
		if previousCount == nil then
			status.preparing[name] = currentCount
		elseif needsItem then
			needsItem = currentCount == previousCount
		end
		if needsItem then
			item = name
			break
		end
	end
	if not item then
		return true
	end
	if Battle.isActive() then
		Inventory.use(item, nil, true)
	else
		Input.cancel()
	end
end

function Strategies.getsSilphCarbosSpecially()
	return Data.yellow and Utils.match(stats.nidoran.speedDV, {11, 15})
end

function Strategies.needsCarbosAtLeast(count)
	local speedDV = stats.nidoran.speedDV
	local carbosRequired = 0
	if Data.yellow then
		if speedDV <= 7 then
			carbosRequired = 0
		elseif speedDV <= 8 then
			carbosRequired = 3
		elseif speedDV <= 10 then
			carbosRequired = 2
		elseif Strategies.getsSilphCarbosSpecially() then
			carbosRequired = 1
		end
	else
		if speedDV <= 6 then
			carbosRequired = 3
		elseif speedDV <= 7 then
			carbosRequired = 2
		elseif speedDV <= 9 then
			carbosRequired = 1
		end
	end
	return count <= carbosRequired
end

local function nidokingStats()
	local att = Pokemon.index(0, "attack")
	local def = Pokemon.index(0, "defense")
	local spd = Pokemon.index(0, "speed")
	local scl = Pokemon.index(0, "special")
	local statDesc = att.." "..def.." "..spd.." "..scl
	local attDV, defDV, spdDV, sclDV = Pokemon.getDVs("nidoking")
	stats.nidoran = {
		attack = att,
		defense = def,
		speed = spd,
		special = scl,
		level4 = stats.nidoran.level4,
		rating = stats.nidoran.rating,
		attackDV = attDV,
		defenseDV = defDV,
		speedDV = spdDV,
		specialDV = sclDV,
	}

	Combat.factorPP(false, false)
	Combat.setDisableThrash(false)

	p(attDV, defDV, spdDV, sclDV)
	print(statDesc)
	Bridge.stats(statDesc)
end

function Strategies.completeCans()
	local px, py = Player.position()
	if px == 4 and py == 6 then
		local trashcanTries = status.tries + 1
		local prefix
		local suffix = "!"
		if trashcanTries <= 1 then
			prefix = "PERFECT"
		elseif trashcanTries <= (Data.yellow and 2 or 3) then
			prefix = "Amazing"
		elseif trashcanTries <= (Data.yellow and 4 or 6) then
			prefix = "Great"
		elseif trashcanTries <= (Data.yellow and 6 or 9) then
			prefix = "Good"
		elseif trashcanTries <= (Data.yellow and 10 or 22) then
			prefix = "Ugh"
			suffix = "."
		else -- TODO trashcans WR
			prefix = "Reset me now"
			suffix = " BibleThump"
		end
		Bridge.chat(" "..prefix..", "..trashcanTries.." try Trashcans"..suffix)

		Bridge.guessResults("trash", trashcanTries)

		local timeLimit = Strategies.getTimeRequirement("trash") + 1
		if Combat.inRedBar() then
			timeLimit = timeLimit + 0.5
		end
		if Strategies.resetTime(timeLimit, "complete Trashcans") then
			return true
		end
		Strategies.setYolo("trash")
		return true
	end
	local completePath = {
		Down = {{2,11}, {8,7}},
		Right = {{2,12}, {3,12}, {1,6}, {2,6}, {3,6}},
		Left = {{9,8}, {8,8}, {7,8}, {6,8}, {5,8}, {9,10}, {8,10}, {7,10}, {6,10}, {5,10}, {}, {}, {}, {}, {}, {}},
	}
	local walkIn = "Up"
	for dir,tileset in pairs(completePath) do
		for __,tile in ipairs(tileset) do
			if px == tile[1] and py == tile[2] then
				walkIn = dir
				break
			end
		end
	end
	Input.press(walkIn, 0)
end

local function hasEnoughHornDrills()
	local earthquakeJinx = stats.nidoran.attackDV >= 11 and Battle.pp("earthquake") > 0
	return Battle.pp("horn_drill") >= (earthquakeJinx and 4 or 5)
end

local function hasEnoughPPItemsToSkipCentering(afterRestoring, afterPickup)
	if afterRestoring and not hasEnoughHornDrills() then
		return false
	end
	local restoresRequired
	if afterRestoring then
		restoresRequired = afterPickup and 2 or 1
	else
		restoresRequired = 2
	end
	return Inventory.ppRestoreCount() >= restoresRequired
end

function Strategies.requiresE4Center(afterRestoring, afterPickup)
	if not hasEnoughPPItemsToSkipCentering(afterRestoring, afterPickup) then
		return true
	end

	if Control.areaName == "Elite Four" then
		return not Strategies.hasHealthFor("LoreleiDewgong")
	end
	return not Strategies.hasSupersFor("LoreleiDewgong")
end

local function useEtherInsteadOfCenter()
	return not hasEnoughHornDrills() and not Strategies.requiresE4Center(false, false)
end

local function requiresMaxEther()
	return Inventory.ppRestoreCount() < (Strategies.requiresE4Center(true, false) and 2 or 3)
end

-- GENERALIZED STRATEGIES

Strategies.functions = {

	tweetBrock = function()
		local statRequirement, timeRequirement
		if stats.nidoran.rating == nil then
			statRequirement = 3
			timeRequirement = "shorts"
			p("Something Fucked up! Should not be here!")
		elseif Data.yellow then
			statRequirement = Pokemon.inParty("pidgey") and stats.nidoran.attack == 16 or stats.nidoran.speed == 15 --TODO
			timeRequirement = "brock"
		else
			statRequirement = stats.nidoran.rating < 2
			timeRequirement = "shorts"
		end
		if statRequirement and not Strategies.overMinute(timeRequirement) then
			Strategies.tweetProgress("On pace after Brock with a great Nidoran in", "brock")
		end
		return true
	end,

	tweetMisty = function()
		Strategies.setYolo("misty")

		if not Strategies.updates.brock and not Control.yolo and (not Combat.inRedBar() or Inventory.contains("potion")) then
			local timeLimit = Strategies.getTimeRequirement("misty")
			if not Strategies.overMinute(timeLimit) then
				local elt, pbn = Strategies.paceMessage(timeLimit - 1)
				Strategies.tweetProgress("Got a run going, just beat Misty "..elt.." in"..pbn, "misty")
			end
		end
		return true
	end,

	tweetSurge = function()
		Control.preferredPotion = "super"

		if not Strategies.updates.misty then
			local timeLimit = Strategies.getTimeRequirement("trash")
			if not Strategies.overMinute(timeLimit + (not Data.yellow and 1.0 or 0.5)) then
				local elt, pbn = Strategies.paceMessage(timeLimit + (not Data.yellow and 0.25 or 0))
				Strategies.tweetProgress("Got a run going, just beat Surge "..elt.." in"..pbn, "surge")
			end
		end
		return true
	end,

	tweetVictoryRoad = function()
		local elt, pbn = Strategies.paceMessage("victory_road")
		Strategies.tweetProgress("Entering Victory Road at "..elt..pbn.." on our way to the Elite Four in", "victory")
		return true
	end,

	bicycle = function()
		if Memory.value("player", "bicycle") == 1 then
			if Menu.close() then
				return true
			end
		else
			return Strategies.useItem({item="bicycle"})
		end
	end,

	frames = function(data)
		if data.report then
			p("FR", Strategies.frames, Utils.frames() - Strategies.startFrames)
			local repels = Memory.value("player", "repel")
			if repels > 0 then
				print("S "..repels)
			end
			Strategies.frames = nil
		else
			Strategies.startFrames = Utils.frames()
			Strategies.frames = 0
		end
		return true
	end,

	split = function(data)
		Data.increment("reset_split")

		Bridge.split(data and data.finished)
		if Strategies.replay or not INTERNAL then
			splitNumber = splitNumber + 1

			local timeDiff
			splitTime, timeDiff = Utils.timeSince(splitTime)
			if timeDiff then
				print(splitNumber..". "..Control.areaName..": "..Utils.elapsedTime().." ("..timeDiff..")")
			end
		end
		return true
	end,

	interact = function(data)
		return interact(data.dir, data.long)
	end,

	talk = function(data)
		return interact(data.dir, data.long)
	end,

	take = function(data)
		return interact(data.dir, data.long)
	end,

	dialogue = function(data)
		if Battle.handleWild() then
			if Textbox.isActive() then
				if Input.cancel(data.decline and "B" or "A") then
					status.talked = true
				end
			else
				if status.talked then
					return true
				end
				Player.interact(data.dir, false)
			end
		end
	end,

	item = function(data)
		if Battle.handleWild() then
			if status.cancel or data.full and not Inventory.isFull() then
				return Strategies.closeMenuFor(data)
			end
			if not status.checked and data.item ~= "carbos" and not Inventory.contains(data.item) then
				print("No "..data.item.." available!")
			end
			status.checked = true
			return Strategies.useItem(data)
		end
	end,

	potion = function(data)
		if not Battle.handleWild() then
			return false
		end
		if not status.cancel then
			local curr_hp = Combat.hp()
			if curr_hp == 0 then
				return false
			end
			local toHP
			if Control.yolo and data.yolo ~= nil then
				toHP = data.yolo
			else
				toHP = data.hp
			end
			if type(toHP) == "string" then
				toHP = Combat.healthFor(toHP)
			end

			local max_hp = Combat.maxHP()
			if status.didPotion and data.topOff then
				toHP = math.max(toHP, max_hp - 49)
			end
			toHP = math.min(toHP, max_hp)

			local toHeal = toHP - curr_hp
			if toHeal > 0 then
				local toPotion
				if data.forced then
					toPotion = Inventory.contains(data.forced)
				else
					local p_first, p_second, p_third
					if toHeal > 50 then
						if data.full then
							p_first = "full_restore"
						else
							p_first = "super_potion"
						end
						p_second, p_third = "super_potion", "potion"
					else
						if toHeal > 20 then
							p_first, p_second = "super_potion", "potion"
						else
							p_first, p_second = "potion", "super_potion"
						end
						if data.full then
							p_third = "full_restore"
						end
					end
					toPotion = Inventory.contains(p_first, p_second, p_third)
				end

				Control.wantedPotion = toPotion == nil
				if toPotion then
					if Menu.pause() then
						status.didPotion = true
						Inventory.use(toPotion)
						status.menuOpened = true
					end
					return false
				end
			end
		end
		if Strategies.closeMenuFor(data) then
			return true
		end
	end,

	teach = function(data)
		if Strategies.initialize("teaching") then
			if not status.cancel then
				status.cancel = data.full and not Inventory.isFull()
			end
		end

		local itemName
		if data.item then
			itemName = data.item
		else
			itemName = data.move
		end
		if not status.cancel then
			if Pokemon.hasMove(data.move) then
				if data.chain and Memory.value("menu", "main") == 128 then
					return true
				end
				status.cancel = true
			else
				local teachTo = data.poke
				if Strategies.initialize("triedTeaching") then
					if not Inventory.contains(itemName) then
						local errorMessage = "Unable to teach move "..itemName
						if teachTo and type(teachTo) == "string" then
							errorMessage = errorMessage.." to "..teachTo
						end
						return Strategies.reset("error", errorMessage, nil, true)
					end
				end
				local replacement
				if data.replace then
					replacement = Pokemon.moveIndex(data.replace, teachTo)
					if replacement then
						replacement = replacement - 1
					else
						replacement = 0
					end
				else
					replacement = 0
				end
				if Inventory.teach(itemName, teachTo, replacement) then
					status.menuOpened = true
				else
					Menu.pause()
				end
			end
		end
		if status.cancel then
			return Strategies.closeMenuFor(data)
		end
	end,

	skill = function(data)
		if completedSkillFor(data) then
			if Data.yellow then
				if not Menu.hasTextbox() then
					return true
				end
			else
				if not Menu.isOpened() then
					return true
				end
			end
			Input.press("B")
		elseif not data.dir or Player.face(data.dir) then
			if Pokemon.use(data.move, Data.yellow) then
				status.tries = status.tries + 1
			elseif Data.yellow and Menu.hasTextbox() then
				Textbox.handle()
			else
				Menu.pause()
			end
		end
	end,

	fly = function(data)
		if Memory.value("game", "map") == data.map then
			return true
		end
		local cities = {
			pallet = {62, "Up"},
			viridian = {63, "Up"},
			lavender = {66, "Down"},
			celadon = {68, "Down"},
			fuchsia = {69, "Down"},
			cinnabar = {70, "Down"},
			saffron = {72, "Down"},
		}

		local main = Memory.value("menu", "main")
		if main == (Data.yellow and 144 or 228) then
			local currentCity = Memory.value("game", "fly")
			local destination = cities[data.dest]
			local press
			if destination[1] - currentCity == 0 then
				press = "A"
			else
				press = destination[2]
			end
			Input.press(press)
		elseif not Pokemon.use("fly", Data.yellow) then
			Menu.pause()
		end
	end,

	swap = function(data)
		if not status.firstIndex then
			local itemIndex = data.item
			if type(data.item) == "string" then
				itemIndex = Inventory.indexOf(data.item)
				status.checkItem = data.item
			end
			local destIndex = data.dest
			if type(data.dest) == "string" then
				destIndex = Inventory.indexOf(data.dest)
				status.checkItem = data.dest
			end
			if destIndex < itemIndex then
				status.firstIndex = destIndex
				status.lastIndex = itemIndex
			else
				status.firstIndex = destIndex
				status.lastIndex = itemIndex
			end
			status.startedAt = Inventory.indexOf(status.checkItem)
		end
		local swapComplete
		if status.firstIndex == status.lastIndex then
			swapComplete = true
		elseif status.firstIndex < 0 or status.lastIndex < 0 then
			swapComplete = true
			if Strategies.initialize("swapUnavailable") then
				p("Not available to swap", data.item, data.dest, status.firstIndex, status.lastIndex)
			end
		elseif status.startedAt ~= Inventory.indexOf(status.checkItem) then
			swapComplete = true
		end

		if swapComplete then
			return Strategies.closeMenuFor(data)
		end

		local main = Memory.value("menu", "main")
		if main == 128 then
			if Menu.getCol() ~= 5 then
				Menu.select(2, true)
			else
				local selection = Memory.value("menu", "selection_mode")
				if selection == 0 then
					if Menu.select(status.firstIndex, "accelerate", true, nil, true) then
						Input.press("Select")
					end
				else
					if Menu.select(status.lastIndex, "accelerate", true, nil, true) then
						Input.press("Select")
					end
				end
			end
		else
			Menu.pause()
		end
	end,

	acquire = function(data)
		Bridge.caught(data.poke)
		return true
	end,

	swapMove = function(data)
		return Battle.swapMove(data.move, data.to)
	end,

	wait = function()
		print("Please save state")
		Input.press("Start", 999999999)
	end,

	waitToTalk = function()
		if Battle.isActive() then
			status.canProgress = false
			Battle.automate()
		elseif Textbox.isActive() then
			status.canProgress = true
			Input.cancel()
		elseif status.canProgress then
			return true
		end
	end,

	waitToPause = function()
		if Menu.pause() then
			return true
		end
	end,

	waitToFight = function(data)
		if Battle.isActive() then
			status.canProgress = true
			Battle.automate()
		elseif status.canProgress then
			return true
		elseif Textbox.handle() then
			if data.dir then
				Player.interact(data.dir, false)
			else
				Input.cancel()
			end
		end
	end,

	leer = function(data)
		if Strategies.trainerBattle() then
			local bm = Combat.bestMove()
			if not bm or bm.minTurns < 3 then
				Battle.automate(data.forced)
				return false
			end
			local opp = Battle.opponent()
			local defLimit = 9001
			local forced
			for __,poke in ipairs(data) do
				if opp == poke[1] then
					local minimumAttack = poke.minAttack
					if not minimumAttack or stats.nidoran.attack > minimumAttack then
						defLimit = poke[2]
					end
					forced = poke.forced
					break
				end
			end
			return Strategies.buffTo("leer", defLimit, forced)
		elseif status.foughtTrainer then
			return true
		end
	end,

	fightX = function(data)
		return Strategies.prepare("x_"..data.x)
	end,

	elixer = function(data)
		local currentPP = Pokemon.pp(0, data.move)
		if currentPP >= data.min then
			return Strategies.closeMenuFor(data)
		end
		if Strategies.initialize() then
			print("Elixer: "..data.move.." "..currentPP.." in "..Control.areaName)
		end

		data.item = "elixer"
		return Strategies.useItem(data)
	end,

	speedchange = function(data)
		if data.speed~=CURRENT_SPEED then
 		client.speedmode(data.speed)		 
			p(data.extra..", speed changed to "..data.speed.."%")
 			client.speedmode(data.speed)
 			CURRENT_SPEED = data.speed
 		end
		return true
	end,

	-- ROUTE

	squirtleIChooseYou = function()
		if Pokemon.inParty("squirtle") then
			Bridge.caught("squirtle")
			return true
		end
		if Player.face("Up") then
			Textbox.name("A")
		end
	end,

	fightBulbasaur = function()
		if status.tries < 9000 and Pokemon.index(0, "level") == 6 then
			if status.tries > 200 then
				status.tries = 9001

				local attDV, defDV, spdDV, sclDV = Pokemon.getDVs("squirtle")
				local attack, defense, speed, special = Pokemon.index(0, "attack"), Pokemon.index(0, "defense"), Pokemon.index(0, "speed"), Pokemon.index(0, "special")
				stats.starter = {
					attack = Pokemon.index(0, "attack"),
					defense = Pokemon.index(0, "defense"),
					speed = Pokemon.index(0, "speed"),
					special = Pokemon.index(0, "special"),
					attackDV = attDV,
					defenseDV = defDV,
					speedDV = spdDV,
					specialDV = sclDV,
				}
				return Strategies.checkSquirtleStats(attack, defense, speed, special)
			else
				status.tries = status.tries + 1
			end
		end
		if Battle.isActive() and Battle.opponentAlive() then
			local attack = Memory.double("battle", "our_attack")
			if attack > 0 and RESET_FOR_TIME and not status.growled then
				if attack ~= status.attack then
					-- p(attack, Memory.double("battle", "opponent_hp"))
					status.attack = attack
				end
				local growled
				local attackBaseline = BEAST_MODE and 2 or 0
				if attack <= 2 + attackBaseline then
					growled = not Battle.opponentDamaged(3)
				elseif attack <= 3 + attackBaseline then
					growled = not Battle.opponentDamaged(1.9)
				end
				if growled then
					return Strategies.reset("time", "Growled to death", attack.." "..Memory.double("battle", "opponent_hp"))
				end
			end
			if Strategies.resetTime("bulbasaur", "beat Bulbasaur") then
				return true
			end
		end
		return Strategies.buffTo("tail_whip", 6)
	end,

	swapNidoran = function()
		local main = Memory.value("menu", "main")
		local nidoranIndex = Pokemon.indexOf("nidoran")
		if nidoranIndex == 0 then
			if Menu.close() then
				return true
			end
		elseif Menu.pause() then
			if Data.yellow then
				if Inventory.contains("potion") and Pokemon.info("nidoran", "hp") < 15 then
					Inventory.use("potion", "nidoran")
					return false
				end
			else
				if Combat.isPoisoned("squirtle") then
					Inventory.use("antidote", "squirtle")
					return false
				end
				if Inventory.contains("potion") and Pokemon.info("squirtle", "hp") < 15 then
					Inventory.use("potion", "squirtle")
					return false
				end
			end

			local column = Menu.getCol()
			if main == 128 then
				if column == 11 then
					Menu.select(1, true)
				elseif column == 12 then
					Menu.select(1, true)
				else
					Input.press("B")
				end
			elseif main == Menu.pokemon then
				local selectIndex
				if Memory.value("menu", "selection_mode") == 1 then
					selectIndex = nidoranIndex
				else
					selectIndex = 0
				end
				Pokemon.select(selectIndex)
			else
				Input.press("B")
			end
		end
	end,

	dodgePalletBoy = function()
		return Strategies.dodgeUp(0x0223, 14, 14, 15, 7)
	end,

	fightWeedle = function()
		if Strategies.trainerBattle() then
			if Memory.value("battle", "our_status") > 0 and not Inventory.contains("antidote") then
				return Strategies.reset("antidote", "Poisoned, but we skipped the antidote")
			end
			return Strategies.buffTo("tail_whip", 5)
		elseif status.foughtTrainer then
			return true
		end
	end,

	checkNidoranStats = function()
		local nidx = Pokemon.indexOf("nidoran")
		if Pokemon.index(nidx, "level") < 8 then
			return false
		end
		if not Data.yellow and status.tries < 300 then
			status.tries = status.tries + 1
			return false
		end

		local att = Pokemon.index(nidx, "attack")
		local def = Pokemon.index(nidx, "defense")
		local spd = Pokemon.index(nidx, "speed")
		local scl = Pokemon.index(nidx, "special")
		local attDV, defDV, spdDV, sclDV = Pokemon.getDVs("nidoran")
		local level4 = not Data.yellow and stats.nidoran.level4
		stats.nidoran = {
			attack = att,
			defense = def,
			speed = spd,
			special = scl,
			level4 = level4,
			rating = 0,
			attackDV = attDV,
			defenseDV = defDV,
			speedDV = spdDV,
			specialDV = sclDV,
		}
		Bridge.stats(att.." "..def.." "..spd.." "..scl)
		Bridge.chat("Stats: "..att.." attack, "..def.." defense, "..spd.." speed, "..scl.." special.")

		local resetsForStats = att < 15 or spd < 14 or scl < 12
		local restrictiveStats = not Data.yellow and RESET_FOR_TIME
		if not resetsForStats and restrictiveStats then
			resetsForStats = att == 15 and spd == 14
		end

		if resetsForStats then
			local nidoranStatus = nil
			if att < 15 and spd < 14 and scl < 12 then
				nidoranStatus = Utils.random {
					"let's just forget this ever happened",
					"I hate everything BibleThump ",
					"perfect stats Kappa ",
					"there's always the next one..",
					"worst possible stats hype",
					"unrunnable everything -.- "
				}
			else
				if restrictiveStats and att == 15 and spd == 14 then
					nidoranStatus = Utils.append(nidoranStatus, "unrunnable attack/speed combination", ", ")
				else
					if att < 15 then
						nidoranStatus = Utils.append(nidoranStatus, "unrunnable attack", ", ")
					end
					if spd < 14 then
						nidoranStatus = Utils.append(nidoranStatus, "unrunnable speed", ", ")
					end
				end
				if scl < 12 then
					nidoranStatus = Utils.append(nidoranStatus, "unrunnable special", ", ")
				end
			end
			if not nidoranStatus then
				nidoranStatus = "unrunnable"
			end
			return Strategies.reset("stats", "Bad Nidoran - "..nidoranStatus)
		end
		status.tries = 9001

		local statDiff = (16 - att) + (15 - spd) + (13 - scl)
		if def < 12 then
			statDiff = statDiff + 1
		end
		if not Data.yellow and not stats.nidoran.level4 then
			statDiff = statDiff + 1
		end
		stats.nidoran.rating = statDiff

		local superlative
		local exclaim = "!"
		if statDiff == 0 then
			superlative = " perfect"
			exclaim = "! Kreygasm"
		elseif att == 16 and spd == 15 then
			if statDiff == 1 then
				superlative = " great"
			else
				superlative = " good"
			end
		elseif statDiff <= ((restrictiveStats or Data.yellow) and 3 or 4) then
			superlative = "n okay"
			exclaim = "."
		else
			superlative = " min stat"
			exclaim = "."
		end
		local message
		if Data.yellow then
			message = "caught"
		else
			message = "Beat Brock with"
		end
		message = message.." a"..superlative.." Nidoran"..exclaim

		if Data.yellow then
			message = message.." On "..(Strategies.vaporeon and "Vaporeon" or "Flareon").." strats."
		else
			message = message.." Caught at level "..(stats.nidoran.level4 and "4" or "3").."."
		end

		if BEAST_MODE then
			p("", true)
			p("", true)
		end
		Bridge.chat(message)
		return true
	end,

	evolveNidorino = function()
		if Pokemon.inParty("nidorino") then
			Bridge.caught("nidorino")
			return true
		end
		if Battle.isActive() then
			status.tries = 0
			status.canProgress = true
			if not Battle.opponentAlive() then
				Input.press("A")
			else
				Battle.automate()
			end
		elseif status.tries > 3600 then
			print("Broke from Nidorino on tries")
			return true
		else
			if status.canProgress then
				status.tries = status.tries + 1
			end
			Input.press("A")
		end
	end,

	catchFlierBackup = function()
		if Strategies.initialize() then
			Bridge.guessing("moon", true)
			Control.canDie(true)
		end
		local caught = Pokemon.inParty("pidgey", "spearow")
		if Battle.isActive() then
			if Memory.double("battle", "our_hp") == 0 then
				local sacrifice = Pokemon.getSacrifice("squirtle", "pikachu")
				if not sacrifice then
					Control.canDie(false)
				elseif Menu.onPokemonSelect() then
					Pokemon.select(sacrifice)
				else
					Input.press("A")
				end
			else
				Battle.handle()
			end
		else
			local birdPath
			local px, py = Player.position()
			if caught then
				if px > 33 then
					return true
				end
				local startY = 9
				if px > 28 then
					startY = py
				end
				birdPath = {{32,startY}, {32,11}, {34,11}}
			elseif px == 37 then
				if not Control.canCatch() then
					return true
				end
				if py == 10 then
					py = 11
				else
					py = 10
				end
				Walk.step(px, py)
			else
				birdPath = {{32,10}, {32,11}, {34,11}, {34,10}, {37,10}}
			end
			if birdPath then
				Walk.custom(birdPath)
			end
		end
	end,

	evolveNidoking = function(data)
		if Battle.handleWild() then
			local usedMoonStone = not Inventory.contains("moon_stone")
			if Strategies.initialize() then
				if data.early then
					if not Control.getMoonExp then
						return true
					end
					if data.poke then
						if stats.nidoran.attack > 15 or not Pokemon.inParty(data.poke) then
							return true
						end
					end
					if data.exp and Pokemon.getExp() > data.exp then
						return true
					end
				end
			end
			if usedMoonStone then
				if Strategies.initialize("evolved") then
					Bridge.caught("nidoking")
				end
				if Strategies.closeMenuFor(data) then
					return true
				end
			elseif not Inventory.use("moon_stone") then
				Menu.pause()
				status.menuOpened = true
			end
		end
	end,

	fightGrimer = function()
		if Strategies.trainerBattle() then
			if Combat.isDisabled("horn_attack") and Strategies.initialize("disabled") then
				local message = Utils.random {
					"Last for 0 turns pretty please?",
					"Guess it's time to tackle everything.",
					"How could this... happen to me?",
				}
				Bridge.chat("WutFace Grimer just disabled Horn Attack. "..message)
			end
			Battle.automate()
		elseif status.foughtTrainer then
			return true
		end
	end,

	helix = function()
		if Battle.handleWild() then
			if Inventory.contains("helix_fossil") then
				return true
			end
			Player.interact("Up", false)
		end
	end,

	reportMtMoon = function()
		local moonEncounters = Data.run.encounters_moon
		if moonEncounters then
			local cutterStatus
			local conjunction = "but"
			local goodEncounters = moonEncounters < 10

			local caughtCutter = Pokemon.inParty("paras", "sandshrew")
			local catchDescription
			local exclamation = "."
			if caughtCutter then
				catchDescription = caughtCutter
				if goodEncounters then
					conjunction = "and"
				end
				cutterStatus = "we caught a "..Utils.capitalize(caughtCutter)
				exclamation = "!"
			else
				local catchPokemon = Data.yellow and "sandshrew" or "paras"
				catchDescription = "no_"..catchPokemon
				if not goodEncounters then
					conjunction = "and"
				end
				cutterStatus = "we didn't catch a "
				if Data.yellow then
					cutterStatus = cutterStatus.."cutter"
				else
					cutterStatus = cutterStatus..Utils.capitalize(catchPokemon)
					exclamation = " :("
				end
			end
			Bridge.caught(catchDescription)
			Bridge.chat(moonEncounters.." Moon encounters, "..conjunction.." "..cutterStatus..exclamation)
			Bridge.moonResults(moonEncounters, caughtCutter)
		end

		Strategies.resetTime("mt_moon", "complete Mt. Moon")
		return true
	end,

	dodgeCerulean = function(data)
		local left = data.left
		return dodgeSideways {
			npc = 0x0242,
			npcX = 15,
			sx = (left and 16 or 14), sy = 18,
			dodge = (left and 17 or 19),
			offset = 10,
			dist = (left and -7 or 4),
			left = left
		}
	end,

	rareCandyEarly = function(data)
		if Strategies.initialize() then
			if Pokemon.info("nidoking", "level") ~= 20 then
				status.cancel = true
			else
				if Pokemon.getExp() > 5550 then
					status.cancel = true
				else
					local encounterDescription = Data.yellow and "a Geodude" or "enough encounters"
					Bridge.chat("didn't kill "..encounterDescription.." in Mt. Moon. Using Rare Candies early to sacrifice some exp, but improve some damage ranges here.")
				end
			end
		end
		data.poke = "nidoking"
		data.item = "rare_candy"
		data.all = true
		return strategyFunctions.item(data)
	end,

	teachThrash = function(data)
		if Strategies.initialize() then
			if Pokemon.info("nidoking", "level") ~= 21 or not Inventory.contains("rare_candy") then
				status.cancel = true
			else
				status.updateStats = true
			end
		end

		data.move = "thrash"
		data.poke = "nidoking"
		data.item = "rare_candy"
		data.replace = Data.yellow and "tackle" or "leer"
		data.all = true
		if strategyFunctions.teach(data) then
			if status.updateStats then
				nidokingStats()
			end
			return true
		end
	end,

	learnThrash = function()
		if Strategies.initialize() then
			if Pokemon.info("nidoking", "level") ~= 22 then
				return true
			end
		end
		if Strategies.trainerBattle() then
			if Pokemon.moveIndex("thrash", "nidoking") then
				nidokingStats()
				return true
			end
			local settingsRow = Memory.value("menu", "settings_row")
			if settingsRow == 8 then
				local column = Memory.value("menu", "column")
				if column == 15 then
					Input.press("A")
					return false
				end
				if column == 5 then
					local replacementMove = Data.yellow and "tackle" or "leer"
					local replaceIndex = Pokemon.moveIndex(replacementMove, "nidoking")
					if replaceIndex then
						Menu.select(replaceIndex - 1, true)
					else
						Input.cancel()
					end
					return false
				end
			end
			Battle.automate()
		elseif status.foughtTrainer then
			return true
		end
	end,

	swapThrash = function()
		if not Battle.isActive() then
			if Textbox.handle() and status.canProgress then
				return true
			end
		else
			status.canProgress = true
			return Battle.swapMove("thrash", 0)
		end
	end,

	lassEther = function()
		if Strategies.initialize() then
			if Data.yellow then
				if not Strategies.vaporeon or not Strategies.getsSilphCarbosSpecially() then
					return true
				end
				if Inventory.containsAll("pokeball", "potion") then
					return true
				end
			else
				if Inventory.containsAll("antidote", "elixer") then
					return true
				end
			end
		end
		return interact("Up")
	end,

	talkToBill = function()
		if Textbox.isActive() then
			return true
		end
		return interact("Up")
	end,

	potionBeforeMisty = function(data)
		if Strategies.initialize() then
			if data.goldeen then
				Strategies.setYolo("bills")
				if Control.yolo and Combat.hp() > 7 then
					return true
				end
			end
		end

		local healAmount = 72
		local canTwoHit = stats.nidoran.attackDV >= (Control.yolo and 8 or 9)
		local isSpeedTie = stats.nidoran.speedDV == 12
		local outspeeds = stats.nidoran.speedDV >= (Control.yolo and 12 or 13)
		if not Data.yellow and canTwoHit and outspeeds then
			healAmount = 46
		elseif canTwoHit and isSpeedTie then
			healAmount = 66
		elseif Control.yolo then
			healAmount = healAmount - 4
		end
		healAmount = healAmount - (stats.nidoran.special - 43)
		if Pokemon.index(0, "level") == 24 then
			healAmount = healAmount - 3
		end

		if not data.goldeen and Strategies.initialize("healed") then
			local message
			local potionCount = Inventory.count("potion")
			local needsToHeal = healAmount - Combat.hp()
			if potionCount * 20 < needsToHeal then
				message = "ran too low on potions to adequately heal before Misty D:"
			elseif healAmount < 60 then
				message = "is limiting heals to attempt to get closer to red-bar off Misty..."
			elseif isSpeedTie then
				message = "will need to get lucky with speed ties to beat Misty here..."
			elseif not outspeeds then
				message = "will need to get lucky to beat Misty here. We're outsped..."
			elseif not canTwoHit then
				message = "will need to get lucky with damage ranges to beat Misty here..."
			end
			if message then
				Bridge.chat(message, false, potionCount)
			end
		end
		return strategyFunctions.potion({hp=healAmount, chain=data.chain})
	end,

	fightMisty = function()
		if Strategies.trainerBattle() then
			if Battle.redeployNidoking() then
				return false
			end
			if Pokemon.isOpponent("staryu") then
				local __, turnsToKill = Combat.bestMove()
				if turnsToKill and turnsToKill > 1 then
					Strategies.chat("staryu", "needs a good damage range to 1-shot Staryu with this attack...")
				end
			end

			if Battle.opponentAlive() and Combat.isConfused() then
				if not status.sacrifice and not Control.yolo and stats.nidoran.speedDV >= 11 then
					status.sacrifice = Pokemon.getSacrifice("pidgey", "spearow", "squirtle", "paras", "sandshrew", "charmander")
				end

				if Menu.onBattleSelect() then
					if Strategies.initialize("sacrificed") then
						local swapMessage = " Thrash didn't finish the kill :( "
						if Control.yolo then
							swapMessage = swapMessage.."Attempting to hit through Confusion to save time."
						elseif status.sacrifice then
							swapMessage = swapMessage.."Swapping out to cure Confusion."
						else
							swapMessage = swapMessage.."We'll have to hit through Confusion here."
						end
						Bridge.chat(swapMessage)
					end
				end
				if status.sacrifice and Battle.sacrifice(status.sacrifice) then
					return false
				end
			end
			Battle.automate()
		elseif status.foughtTrainer then
			return true
		end
	end,

	announceMachop = function()
		if Strategies.trainerBattle() then
			local __, turnsToKill, turnsToDie = Combat.bestMove()
			if turnsToKill and turnsToDie == 1 and turnsToKill > 1 then
				Strategies.chat("machop", "needs a good damage range to one-shot this Machop, which can kill us with a Karate Chop critical.")
			end
			Battle.automate()
		elseif status.foughtTrainer then
			return true
		end
	end,

	jingleSkip = function()
		if status.canProgress then
			local px, py = Player.position()
			if px < 4 then
				return true
			end
			Input.press("Left", 0)
		else
			Input.press("A", 2)
			status.canProgress = true
		end
	end,

	guess = function(data)
		Bridge.guessing(data.game, data.enabled)
		return true
	end,

	epicCutscene = function()
		Bridge.chatRandom(
			" CUTSCENE HYPE!",
			" Please, sit back and enjoy the cutscene.",
			"is enjoying the scenery Kappa b",
			" Wait, is it too late to get Mew from under the truck??",
			" Cutscenes DansGame",
			" Your regularly scheduled run will continue in just a moment. Thank you for your patience.",
			" Guys I think the game softlocked Kappa",
			" Perfect, I needed a quick bathroom break.",
			" *yawn*",
			" :z",
			" I think that ship broke the ocean.",
			" Ahh, lovely weather in Vermilion City this time of year, isn't it?",
			" As a devout practicing member of the Church of Going Fast, I find the depiction of this unskippable cutscene offensive, frankly.",
			" Anyone else feel cheated we didn't actually get to ride to some far off land in that boat?",
			" So let me get this straight, the ship hadn't even left port yet, and the captain was already seasick? DansGame" --amanazi
		)
		return true
	end,

	fourTurnThrash = function()
		if Strategies.trainerBattle() then
			Strategies.chat("four_turn", "needs to 4-turn Thrash, or hit through Confusion (each a 1 in 2 chance) to beat this dangerous trainer...")

			local forced
			if Pokemon.isOpponent("bellsprout") then
				if Battle.opponentAlive() then
					if Data.yellow and Combat.isConfused() and Combat.hp() < 25 then
						local potion = Inventory.contains("super_potion", "potion")
						if potion then
							Inventory.use(potion, nil, true)
							return false
						end
					end
					forced = "horn_attack"
				end
			end
			Battle.automate(forced)
		elseif status.foughtTrainer then
			return true
		end
	end,

	announceVenonat = function()
		if Strategies.trainerBattle() then
			if Pokemon.isOpponent("venonat") then
				local __, turnsToKill, turnsToDie = Combat.bestMove()
				if turnsToKill and turnsToKill > 1 and stats.nidoran.attackDV < 10 then
					local effectsDescription = turnsToDie == 1 and "kill/confuse" or "confuse"
					Strategies.chat("range", "needs a good damage range to 1-shot this Venonat, which can "..effectsDescription.."...")
				end
			end
			Battle.automate()
		elseif status.foughtTrainer then
			return true
		end
	end,

	announceOddish = function()
		if Strategies.trainerBattle() then
			if Pokemon.isOpponent("oddish") then
				local __, turnsToKill = Combat.bestMove()
				if turnsToKill and turnsToKill > 1 then
					Strategies.chat("oddish", "needs a good damage range to 1-shot this Oddish, which can sleep/paralyze.")
				end
			end
			Battle.automate()
		elseif status.foughtTrainer then
			return true
		end
	end,

	healParalysis = function(data)
		if not Combat.isParalyzed() then
			return Strategies.closeMenuFor(data)
		end
		local heals = Inventory.contains("paralyze_heal", "full_restore")
		if Strategies.initialize("paralyzed") then
			local message
			if heals then
				message = "Full restoring to cure paralysis from Oddish."
			else
				message = "No Paralysis cure available :("
			end
			Bridge.chat(message)
		end
		data.item = heals
		return Strategies.useItem(data)
	end,

	shopTM07 = function()
		return Shop.transaction {
			direction = "Up",
			buy = {{name="horn_drill", index=3}}
		}
	end,

	shopRepels = function()
		local repelCount = Data.yellow and 10 or 9
		return Shop.transaction {
			direction = "Up",
			buy = {{name="super_repel", index=3, amount=repelCount}}
		}
	end,

	shopPokeDoll = function()
		return Shop.transaction {
			direction = "Down",
			buy = {{name="pokedoll", index=0}}
		}
	end,

	shopVending = function()
		return Shop.vend {
			direction = "Up",
			buy = {{name="fresh_water", index=0}, {name="soda_pop", index=1}}
		}
	end,

	giveWater = function()
		if not Inventory.contains("fresh_water", "soda_pop") then
			return true
		end
		if Memory.value("menu", "shop_current") == 20 then
			Input.press("A")
		elseif Textbox.handle() then
			local cx, cy = Memory.raw(0x0223) - 3, Memory.raw(0x0222) - 3
			local px, py = Player.position()
			if Utils.dist(cx, cy, px, py) == 1 then
				Player.interact(Walk.dir(px, py, cx, cy))
			else
				Walk.step(cx, cy)
			end
		end
	end,

	shopExtraWater = function()
		return Shop.vend {
			direction = "Up",
			buy = {{name="fresh_water", index=0}}
		}
	end,

	digFight = function()
		if Strategies.initialize() then
			if Combat.inRedBar() then
				Bridge.chat("is using Rock Slide to one-hit these Ghastlies in red-bar (each is 1 in 10 to miss).")
			end
		end
		if Strategies.trainerBattle() then
			local currentlyDead = Memory.double("battle", "our_hp") == 0
			if currentlyDead then
				local backupPokemon = Pokemon.getSacrifice("paras", "squirtle", "sandshrew", "charmander")
				if not backupPokemon then
					return Strategies.death()
				end
				Strategies.chat("died", " Rock Slide missed BibleThump Trying to finish them off with Dig...")

				if Menu.onPokemonSelect() then
					Pokemon.select(backupPokemon)
				else
					Input.press("A")
				end
			else
				Battle.automate()
			end
		elseif status.foughtTrainer then
			return true
		end
	end,

	pokeDoll = function()
		if Battle.isActive() then
			status.canProgress = true
			-- {s="swap",item="potion",dest="x_special",chain=true}, --TODO yellow
			Inventory.use("pokedoll", nil, true)
		elseif status.canProgress then
			return true
		else
			Input.cancel()
		end
	end,

	silphElevator = function()
		if Menu.isOpened() then
			status.canProgress = true
			Menu.select(9, false, true)
		else
			if status.canProgress then
				return true
			end
			Player.interact("Up")
		end
	end,

	silphCarbos = function()
		if Strategies.initialize() then
			local getCarbos = Strategies.needsCarbosAtLeast(2)
			if getCarbos then
				if not Data.yellow then
					Bridge.chat(" This Nidoking has bad speed, so we need the extra Carbos here.")
				end
			elseif Strategies.getsSilphCarbosSpecially() then
				getCarbos = true
			end
			if not getCarbos then
				return true
			end
		end
		return strategyFunctions.interact({dir="Left"})
	end,

	playPokeFlute = function()
		if Battle.isActive() then
			return true
		end
		if Menu.hasTextbox() then
			Input.cancel()
		elseif Menu.pause() then
			Inventory.use("pokeflute")
		end
	end,

	push = function(data)
		local pos
		if data.dir == "Up" or data.dir == "Down" then
			pos = data.y
		else
			pos = data.x
		end
		local newP = Memory.raw(pos)
		if not status.startPosition then
			status.startPosition = newP
		elseif status.startPosition ~= newP then
			return true
		end
		Input.press(data.dir, 0)
	end,

	drivebyRareCandy = function()
		if Textbox.isActive() then
			status.canProgress = true
			Input.cancel()
		elseif status.canProgress then
			return true
		else
			local px, py = Player.position()
			if py < 13 then
				status.tries = 0
				return
			end
			if py == 13 and status.tries % 2 == 0 then
				Input.press("A", 2)
			else
				Input.press("Up")
				status.tries = 0
			end
			status.tries = status.tries + 1
		end
	end,

	safariCarbos = function()
		if Strategies.initialize() then
			Strategies.setYolo("safari_carbos")
			status.carbos = Inventory.count("carbos")

			if not Strategies.needsCarbosAtLeast(3) then
				return true
			end
			Bridge.chat(" This Nidoking has terrible speed, so we'll need to go out of our way for the extra Carbos here.")
		end
		if Inventory.count("carbos") ~= status.carbos then
			if Walk.step(20, 20) then
				return true
			end
		else
			local px, py = Player.position()
			if px < 21 then
				Walk.step(21, py)
			elseif px == 21 and py == 13 then
				Player.interact("Left")
			else
				Walk.step(21, 13)
			end
		end
	end,

	tossInSafari = function()
		if Inventory.count() <= (Inventory.contains("full_restore") and 18 or 17) then
			return Strategies.closeMenuFor({close=true})
		end
		if Data.red and Inventory.contains("carbos") then
			strategyFunctions.item({item="carbos",poke="nidoking",all=true})
			return false
		end
		return Strategies.tossItem("antidote", "tm34", "pokeball")
	end,

	extraFullRestore = function()
		if Strategies.initialize() then
			if not Data.yellow then
				if Control.yolo or Inventory.contains("full_restore") then
					return true
				end
				Bridge.chat("needs to grab the backup Full Restore here.")
			end
		end
		local px, py = Player.position()
		if px < 21 then
			px = 21
		elseif py < 9 then
			py = 9
		else
			return strategyFunctions.interact({dir="Down"})
		end
		Walk.step(px, py)
	end,

	dodgeGirl = function()
		local gx, gy = Memory.raw(0x0223) - 5, Memory.raw(0x0222)
		local px, py = Player.position()
		if py > gy then
			if px > 3 then
				px = 3
			else
				return true
			end
		elseif gy - py ~= 1 or px ~= gx then
			py = py + 1
		elseif px == 3 then
			px = 2
		else
			px = 3
		end
		Walk.step(px, py)
	end,

	cinnabarCarbos = function()
		local skipsCarbos = not Strategies.needsCarbosAtLeast(Data.yellow and 2 or 1)
		if Strategies.initialize() then
			status.startCount = Inventory.count("carbos")
			if not skipsCarbos then
				Bridge.chat(" This Nidoking has mediocre speed, so we'll need to pick up the extra Carbos here.")
			end
		end

		local px, py = Player.position()
		if px == 21 then
			return true
		end
		if skipsCarbos then
			px, py = 21, 20
		else
			if py == 20 then
				py = 21
			elseif px == 17 and Inventory.count("carbos") == status.startCount then
				Player.interact("Right")
				return false
			else
				px = 21
			end
		end
		Walk.step(px, py)
	end,

	ether = function(data)
		data.item = status.item
		if status.item and Strategies.completedMenuFor(data) then
			if Strategies.closeMenuFor(data) then
				return true
			end
		else
			if not status.item then
				if data.max then
					if not useEtherInsteadOfCenter() then
						return true
					end
					Bridge.chat("is Elixering and grabbing the Max Ether to skip the Elite 4 Center.")
				end

				status.item = Inventory.contains("ether", "max_ether", "elixer")
				if not status.item then
					if Strategies.closeMenuFor(data) then
						return true
					end
					print("No Ether - "..Control.areaName)
					return false
				end
			end
			if status.item == "elixer" then
				data.item = "elixer"
				data.poke = "nidoking"
				return Strategies.useItem(data)
			end
			if Memory.value("menu", "main") == 144 and Menu.getCol() == 5 then
				if Menu.hasTextbox() then
					Input.cancel()
				else
					Menu.select(Pokemon.battleMove("horn_drill"), true)
				end
			elseif Menu.pause() then
				Inventory.use(status.item, "nidoking")
				status.menuOpened = true
			end
		end
	end,

	tossInVictoryRoad = function()
		if Strategies.initialize() then
			if not requiresMaxEther() or not Inventory.isFull() or Inventory.contains("max_ether") then
				return true
			end
		end
		return Strategies.tossItem("antidote", "tm34", "x_attack", "pokeball")
	end,

	grabMaxEther = function()
		if Strategies.initialize() then
			if Inventory.isFull() or not requiresMaxEther() then
				return true
			end
			status.startCount = Inventory.count("max_ether")
		end

		if Inventory.count("max_ether") > status.startCount then
			return true
		end
		local px, py = Player.position()
		if px > 7 then
			return Strategies.reset("error", "Accidentally walked on the island :(", px, true)
		end
		if Memory.value("player", "moving") == 0 then
			Player.interact("Right")
		end
	end,

	potionBeforeLorelei = function(data)
		if Strategies.initialize() then
			if Strategies.requiresE4Center(true, true) then
				return true
			end
			if not Strategies.canHealFor("LoreleiDewgong") then
				return true
			end
			Bridge.chat("is healing before Lorelei to skip the Elite 4 Center...")
		end

		data.hp = Combat.healthFor("LoreleiDewgong")
		return strategyFunctions.potion(data)
	end,

	centerSkip = function()
		if Strategies.initialize() then
			Strategies.setYolo("e4center")
			if not Strategies.requiresE4Center(true, true) then
				local message
				if not Data.yellow then
					message = "is skipping the Center and attempting to red-bar "
					if Strategies.hasHealthFor("LoreleiDewgong") then
						message = message.."off Lorelei..."
					else
						message = message.."the Elite 4!"
					end
					Bridge.chat(message)
				end
				return true
			end
			Bridge.chat("is taking the Center to heal HP/PP for Lorelei.")
		end
		return strategyFunctions.dialogue({dir="Up"})
	end,

	prepareForLance = function()
		local curr_hp = Combat.hp()
		local min_recovery = Combat.healthFor("LanceGyarados")
		if not Control.yolo then
			min_recovery = min_recovery + 1
		end

		local enableFull = Inventory.count("full_restore") > (Control.yolo and 0 or 1)
		if curr_hp + 50 < min_recovery then
			enableFull = not Inventory.contains("super_potion")
		elseif curr_hp + 100 < min_recovery then
			enableFull = Inventory.count("super_potion") < 2
		end
		return strategyFunctions.potion({hp=min_recovery, full=enableFull, chain=true})
	end,

	champion = function()
		if status.finishTime then
			if not status.frames then
				status.frames = 0
				local victoryMessage = "Beat Pokemon "..Utils.capitalize(Data.gameName).." in "..status.finishTime
				if not Strategies.overMinute("champion") then
					victoryMessage = victoryMessage..", a new PB!"
				end
				Strategies.tweetProgress(victoryMessage)
				if Data.run.seed then
					Data.setFrames()
					print("v"..VERSION..": "..Data.run.frames.." frames, with seed "..Data.run.seed)

					if (Data.yellow or not INTERNAL or RESET_FOR_TIME) and not Strategies.replay then
						print("Please save this seed number to share, if you would like proof of your run!")
						print("A screenshot has been saved to the Gameboy\\Screenshots folder in BizHawk.")
						gui.cleartext()
						gui.text(0, 0, "PokeBot v"..VERSION)
						gui.text(0, 7, "Seed: "..Data.run.seed)
						gui.text(0, 14, "Name: "..Textbox.getNamePlaintext())
						gui.text(0, 21, "Reset for time: "..tostring(RESET_FOR_TIME))
						gui.text(0, 28, "Time: "..Utils.elapsedTime())
						gui.text(0, 35, "Frames: "..Utils.frames())
						client.setscreenshotosd(true)
						client.screenshot()
						client.setscreenshotosd(false)
						gui.cleartext()
					end
				end
				Bridge.guessResults("elite4", "victory")
			elseif status.frames == 500 then
				Bridge.chat("beat the game in "..status.finishTime.."!")
			elseif status.frames > 1800 then
				return Strategies.hardReset("won", "Finished the game in "..Utils.elapsedTime()..", Dont forget to follow the stream!")
			end
			status.frames = status.frames + 1
		elseif Memory.value("menu", "shop_current") == 252 then
			strategyFunctions.split({finished=true})
			status.finishTime = Utils.elapsedTime()
		else
			Input.cancel()
		end
	end,

}

strategyFunctions = Strategies.functions

function Strategies.execute(data)
	local strategyFunction = strategyFunctions[data.s]
	if not strategyFunction then
		p("INVALID STRATEGY", data.s, Data.gameName)
		return true
	end
	if strategyFunction(data) then
		status = {tries=0}
		Strategies.status = status
		Strategies.completeGameStrategy()
		-- if Data.yellow and INTERNAL and not STREAMING_MODE then
		-- 	print(data.s)
		-- end
		if resetting then
			return nil
		end
		return true
	end
	return false
end

function Strategies.init(midGame)
	splitTime = Utils.timeSince(0)
	if midGame then
		Control.preferredPotion = "super"
		Combat.factorPP(true)
	end

	local nido = Pokemon.inParty("nidoran", "nidorino", "nidoking")
	if nido then
		local attDV, defDV, spdDV, sclDV = Pokemon.getDVs(nido)
		p(attDV, defDV, spdDV, sclDV)
		stats.nidoran = {
			rating = 1,
			attackDV = attDV,
			defenseDV = defDV,
			speedDV = spdDV,
			specialDV = sclDV,
			level4 = true,
		}
		if nido == "nidoking" then
			stats.nidoran.attack = 55
			stats.nidoran.defense = 45
			stats.nidoran.speed = 50
			stats.nidoran.special = 45
		else
			stats.nidoran.attack = 16
			stats.nidoran.defense = 12
			stats.nidoran.speed = 15
			stats.nidoran.special = 13
		end
		p(stats.nidoran.attack, "x", stats.nidoran.speed, stats.nidoran.special)
	end

	Strategies.initGame(midGame)
end

function Strategies.softReset()
	status = {tries=0}
	Strategies.status = status
	stats = {}
	Strategies.stats = stats
	Strategies.updates = {}

	splitNumber, splitTime = 0, 0
	resetting = nil
	Strategies.deepRun = false
	Strategies.resetGame()
end

return Strategies