local Combat = {}

local Movelist = require "data.movelist"
local Opponents = require "data.opponents"

local Bridge = require "util.bridge"
local Memory = require "util.memory"
local Utils = require "util.utils"

local Pokemon = require "storage.pokemon"

local damageMultiplier = { -- http://bulbapedia.bulbagarden.net/wiki/Type_chart#Generation_I
	normal   = {normal=1.0, fighting=1.0, flying=1.0, poison=1.0, ground=1.0, rock=0.5, bug=1.0, ghost=0.0, fire=1.0, water=1.0, grass=1.0, electric=1.0, psychic=1.0, ice=1.0, dragon=1.0, },
	fighting = {normal=2.0, fighting=1.0, flying=0.5, poison=0.5, ground=1.0, rock=2.0, bug=0.5, ghost=0.0, fire=1.0, water=1.0, grass=1.0, electric=1.0, psychic=0.5, ice=2.0, dragon=1.0, },
	flying   = {normal=1.0, fighting=2.0, flying=1.0, poison=1.0, ground=1.0, rock=0.5, bug=2.0, ghost=1.0, fire=1.0, water=1.0, grass=2.0, electric=0.5, psychic=1.0, ice=1.0, dragon=1.0, },
	poison   = {normal=1.0, fighting=1.0, flying=1.0, poison=0.5, ground=0.5, rock=0.5, bug=2.0, ghost=0.5, fire=1.0, water=1.0, grass=2.0, electric=1.0, psychic=1.0, ice=1.0, dragon=1.0, },
	ground   = {normal=1.0, fighting=1.0, flying=0.0, poison=2.0, ground=1.0, rock=2.0, bug=0.5, ghost=1.0, fire=2.0, water=1.0, grass=0.5, electric=2.0, psychic=1.0, ice=1.0, dragon=1.0, },
	rock     = {normal=1.0, fighting=0.5, flying=2.0, poison=1.0, ground=0.5, rock=1.0, bug=2.0, ghost=1.0, fire=2.0, water=1.0, grass=1.0, electric=1.0, psychic=1.0, ice=2.0, dragon=1.0, },
	bug      = {normal=1.0, fighting=0.5, flying=0.5, poison=2.0, ground=1.0, rock=1.0, bug=1.0, ghost=0.5, fire=0.5, water=1.0, grass=2.0, electric=1.0, psychic=2.0, ice=1.0, dragon=1.0, },
	ghost    = {normal=0.0, fighting=1.0, flying=1.0, poison=1.0, ground=1.0, rock=1.0, bug=1.0, ghost=2.0, fire=1.0, water=1.0, grass=1.0, electric=1.0, psychic=0.0, ice=1.0, dragon=1.0, },
	fire     = {normal=1.0, fighting=1.0, flying=1.0, poison=1.0, ground=1.0, rock=0.5, bug=2.0, ghost=1.0, fire=0.5, water=0.5, grass=2.0, electric=1.0, psychic=1.0, ice=2.0, dragon=0.5, },
	water    = {normal=1.0, fighting=1.0, flying=1.0, poison=1.0, ground=2.0, rock=2.0, bug=1.0, ghost=1.0, fire=2.0, water=0.5, grass=0.5, electric=1.0, psychic=1.0, ice=1.0, dragon=0.5, },
	grass    = {normal=1.0, fighting=1.0, flying=0.5, poison=0.5, ground=2.0, rock=2.0, bug=0.5, ghost=1.0, fire=0.5, water=2.0, grass=0.5, electric=1.0, psychic=1.0, ice=1.0, dragon=0.5, },
	electric = {normal=1.0, fighting=1.0, flying=2.0, poison=1.0, ground=0.0, rock=1.0, bug=1.0, ghost=1.0, fire=1.0, water=2.0, grass=0.5, electric=0.5, psychic=1.0, ice=1.0, dragon=0.5, },
	psychic  = {normal=1.0, fighting=2.0, flying=1.0, poison=2.0, ground=1.0, rock=1.0, bug=1.0, ghost=1.0, fire=1.0, water=1.0, grass=1.0, electric=1.0, psychic=0.5, ice=1.0, dragon=1.0, },
	ice      = {normal=1.0, fighting=1.0, flying=2.0, poison=1.0, ground=2.0, rock=1.0, bug=1.0, ghost=1.0, fire=1.0, water=0.5, grass=2.0, electric=1.0, psychic=1.0, ice=0.5, dragon=2.0, },
	dragon   = {normal=1.0, fighting=1.0, flying=1.0, poison=1.0, ground=1.0, rock=1.0, bug=1.0, ghost=1.0, fire=1.0, water=1.0, grass=1.0, electric=1.0, psychic=1.0, ice=1.0, dragon=2.0, },
}

local types = {}
types[0]  = "normal"
types[1]  = "fighting"
types[2]  = "flying"
types[3]  = "poison"
types[4]  = "ground"
types[5]  = "rock"
types[7]  = "bug"
types[8]  = "ghost"
types[20] = "fire"
types[21] = "water"
types[22] = "grass"
types[23] = "electric"
types[24] = "psychic"
types[25] = "ice"
types[26] = "dragon"

local conservePP = false
local allowDamageRange = false
local disableThrash = false
local lastHP, lastExp

local floor = math.floor

local function checkBit(address, value)
	return bit.band(address, value) == value
end

local function isDisabled(move)
	if type(move) == "string" then
		move = Pokemon.moveID(move)
	end
	return move == Memory.value("battle", "disabled")
end
Combat.isDisabled = isDisabled

local function xAccuracy()
	local skipAccuracyCheck = 0x1
	return bit.band(Memory.value("battle", "x_accuracy"), skipAccuracyCheck) == skipAccuracyCheck
end
Combat.xAccuracy = xAccuracy

local function calcDamage(move, attacker, defender, rng)
	if move.fixed then
		return move.fixed, move.fixed
	end
	if move.power == 0 or isDisabled(move.id) then
		return 0, 0
	end
	if move.power > 9000 then
		if xAccuracy() and defender.speed < attacker.speed then
			return 9001, 9001
		end
		return 0, 0
	end
	if disableThrash and move.name == "Thrash" then
		return 0, 0
	end

	local attFactor, defFactor
	if move.special then
		attFactor, defFactor = attacker.spec, defender.spec
	else
		attFactor, defFactor = attacker.att, defender.def
	end
	local attackerLevel = attacker.level
	if move.critical then
		attackerLevel = attackerLevel * 2
	end
	local damage = floor(floor(floor(2 * attackerLevel / 5 + 2) * math.max(1, attFactor) * move.power / math.max(1, defFactor)) / 50) + 2

	if move.move_type == attacker.type1 or move.move_type == attacker.type2 then
		damage = floor(damage * 1.5) -- STAB
	end

	local dmp = damageMultiplier[move.move_type]
	local typeEffect1, typeEffect2 = dmp[defender.type1], dmp[defender.type2]
	if defender.type1 == defender.type2 then
		typeEffect2 = 1
	end
	damage = floor(damage * typeEffect1 * typeEffect2)
	if move.multiple then
		damage = damage * move.multiple
	end
	if rng then
		return damage, damage
	end
	return floor(damage * 217 / 255), damage
end

local function getOpponentType(ty)
	local t1 = types[Memory.value("battle", "opponent_type1")]
	if ty ~= 0 then
		t1 = types[Memory.value("battle", "opponent_type2")]
		if not t1 then
			return Memory.value("battle", "opponent_type2")
		end
	end
	if t1 then
		return t1
	end
	return Memory.value("battle", "opponent_type1")
end
Combat.getOpponentType = getOpponentType

local function getOurType(ty)
	local t1 = types[Memory.value("battle", "our_type1")]
	if ty ~= 0 then
		t1 = types[Memory.value("battle", "our_type2")]
		if not t1 then
			return Memory.value("battle", "opponent_type2")
		end
	end
	if t1 then
		return t1
	end
	return Memory.value("battle", "opponent_type1")
end
Combat.getOurType = getOurType

local function getMoves(who)--Get the moveset of us [0] or them [1]
	local moves = {}
	local base
	if who == 1 then
		base = 0x0FED
	else
		base = 0x101C
	end
	for idx=0, 3 do
		local val = Memory.raw(base + idx)
		if val > 0 then
			local moveTable = Movelist.get(val)
			if moveTable then
				if who == 0 then
					moveTable.pp = Memory.raw(0x102D + idx)
				end
				moves[idx + 1] = moveTable
			else
				p("ERR: Invalid move index", idx)
			end
		end
	end
	return moves
end
Combat.getMoves = getMoves

local function modPlayerStats(user, enemy, move)
	local effect = move.effects
	if effect then
		local diff = effect.diff
		local hitThem = diff < 0
		local stat = effect.stat
		if hitThem then
			enemy[stat] = math.max(2, enemy[stat] + diff)
		else
			user[stat] = user[stat] + diff
		end
	end
	return user, enemy
end

local function calcBestHit(attacker, defender, ours, rng)
	local bestTurns, bestMinTurns = 9001, 9001
	local bestDmg = -1
	local ourMaxHit
	local targetHP = defender.hp
	local ret = nil
	for __,move in ipairs(attacker.moves) do
		if not move.pp or move.pp > 0 then
			local minDmg, maxDmg = calcDamage(move, attacker, defender, rng)
			if maxDmg then
				local minTurns, maxTurns
				if maxDmg <= 0 then
					minTurns, maxTurns = 9001, 9001
				else
					minTurns = math.ceil(targetHP / maxDmg)
					maxTurns = math.ceil(targetHP / minDmg)
				end
				if ours then
					local replaces
					if not ret or minTurns < bestMinTurns or maxTurns < bestTurns then
						replaces = true
					elseif maxTurns == bestTurns and move.name == "Thrash" then
						replaces = targetHP == Memory.double("battle", "opponent_max_hp") --TODO battle turn 0
					elseif maxTurns == bestTurns and ret.name == "Thrash" then
						replaces = targetHP ~= Memory.double("battle", "opponent_max_hp")
					elseif move.fast and not ret.fast then
						if move.multiple then
							replaces = targetHP <= maxDmg * 0.49
						else
							replaces = maxTurns <= bestTurns
						end
					elseif ret.fast then
						replaces = maxTurns < bestTurns
					elseif move.multiple and ret.accuracy < 100 then
						replaces = targetHP <= maxDmg * 0.5
					elseif conservePP then
						if allowDamageRange then
							local isMetapod = attacker.id == 124
							if not isMetapod or maxTurns <= 2 then
								if ret.name == "Horn-Attack" then
									local weightedDmg = (minDmg + maxDmg * 2) / 3
									local weightedTurns = math.ceil(targetHP / weightedDmg)
									replaces = weightedTurns <= bestTurns
								elseif move.name == "Horn-Attack" then
									replaces = maxTurns < bestMinTurns
								end
							end
						elseif maxTurns < 2 or maxTurns == bestMinTurns then
							if ret.name == "Earthquake" and (move.name == "Ice-Beam" or move.name == "Thunderbolt") then
								replaces = true
							elseif move.pp > ret.pp then
								if ret.name == "Horn-Drill" then
									replaces = true
								elseif move.name ~= "Earthquake" then
									replaces = true
								end
							end
						end
					elseif minDmg > bestDmg then
						replaces = true
					end
					if replaces then
						ret = move
						bestMinTurns = minTurns
						bestTurns = maxTurns
						bestDmg = minDmg
						ourMaxHit = maxDmg
					end
				elseif maxDmg > bestDmg then -- Opponents automatically hit max
					ret = move
					bestTurns = minTurns
					bestDmg = maxDmg
				end
			end
		end
	end
	if ret then
		ret.damage = bestDmg
		ret.maxDamage = ourMaxHit
		ret.minTurns = bestMinTurns
		return ret, bestTurns
	end
end

local function getBestMove(ours, enemy, draw)
	if enemy.hp < 1 then
		return
	end
	local bm, bestUs = calcBestHit(ours, enemy, true)
	local __, bestEnemy = calcBestHit(enemy, ours, false)
	if not bm then
		return
	end
	if draw and bm.midx then
		Utils.drawText(0, 35, ''..bm.midx.." "..bm.name)
	end
	return bm, bestUs, bestEnemy
end

local function activePokemon(preset)
	local ours = {
		id = Memory.value("battle", "our_id"),
		level = Memory.value("battle", "our_level"),
		hp = Memory.double("battle", "our_hp"),
		att = Memory.double("battle", "our_attack"),
		def = Memory.double("battle", "our_defense"),
		spec = Memory.double("battle", "our_special"),
		speed = Memory.double("battle", "our_speed"),
		type1 = getOurType(0),
		type2 = getOurType(1),
		moves = getMoves(0),
	}

	local enemy
	if preset then
		enemy = Opponents[preset]
		local toBoost = enemy.boost
		if toBoost then
			local currentStat = ours[toBoost.stat]
			local booster = toBoost.mp
			if toBoost.stat ~= "spec" or (currentStat < 140) == (booster > 1) then
				ours[toBoost.stat] = math.floor(currentStat * booster)
			end
		end
	else
		enemy = {
			id = Memory.value("battle", "opponent_id"),
			level = Memory.value("battle", "opponent_level"),
			hp = Memory.double("battle", "opponent_hp"),
			att = Memory.double("battle", "opponent_attack"),
			def = Memory.double("battle", "opponent_defense"),
			spec = Memory.double("battle", "opponent_special"),
			speed = Memory.double("battle", "opponent_speed"),
			type1 = getOpponentType(0),
			type2 = getOpponentType(1),
			moves = getMoves(1),
		}
	end
	return ours, enemy
end
Combat.activePokemon = activePokemon

-- STATUS

local function checkStatus(target, value)
	return checkBit(Pokemon.info(target, "status"), value)
end

function Combat.isPoisoned(target)
	return checkStatus(target, 0x8)
end

function Combat.hasParalyzeStatus()
	return Memory.value("battle", "paralyzed") > 0
end

function Combat.isFrozen(target)
	return checkStatus(target, 0x20)
end

function Combat.isParalyzed(target)
	return checkStatus(target, 0x40)
end

function Combat.isSleeping(target)
	return Memory.raw(0x116F) > 0 and not Combat.isParalyzed(target)
end

local function isConfused()
	return Memory.raw(0x106B) > 0
end
Combat.isConfused = isConfused

function Combat.sandAttacked()
	return Memory.value("battle", "accuracy") < 7
end

-- HP

function Combat.hp()
	return Pokemon.index(0, "hp")
end

function Combat.maxHP()
	return Pokemon.index(0, "max_hp")
end

function Combat.redHP()
	return math.ceil(Combat.maxHP() * 0.2)
end

function Combat.inRedBar()
	return Combat.hp() <= Combat.redHP()
end

-- COMBAT

function Combat.setDisableThrash(disable)
	disableThrash = disable
end

function Combat.factorPP(enabled, damageRange)
	if enabled ~= nil then
		conservePP = enabled
	end
	if damageRange ~= nil then
		allowDamageRange = damageRange
	end
end

function Combat.reset()
	conservePP = false
	allowDamageRange = false
end

function Combat.healthFor(opponent)
	local ours, enemy = activePokemon(opponent)
	local enemyAttack = calcBestHit(enemy, ours, false)
	return enemyAttack.damage
end

function Combat.inKillRange(draw)
	local ours, enemy = activePokemon()
	local enemyAttack, turnsToDie = calcBestHit(enemy, ours, false)
	local __, turnsToKill = calcBestHit(ours, enemy, true)
	if not turnsToKill or not enemyAttack then
		return false
	end
	if draw then
		Utils.drawText(0, 21, ours.speed.." "..enemy.speed)
		Utils.drawText(0, 28, turnsToDie.." "..ours.hp.." | "..turnsToKill.." "..enemy.hp)
	end
	local hpReq = enemyAttack.damage
	local isConfused = isConfused()
	if isConfused then
		hpReq = hpReq + math.floor(ours.hp * 0.2)
	end
	if ours.hp <= hpReq then
		local outsped = enemyAttack.outspeed
		if outsped and outsped ~= true then
			if Memory.value("battle", "critical") == 1 then
				hpReq = hpReq * 2
			end
			outsped = Memory.value("battle", "attack_turns") > 0
		end
		if outsped or isConfused or turnsToKill > 1 or ours.speed <= enemy.speed or Pokemon.info(0, "status") > 0 then
			return ours, hpReq
		end
	end
end

local function getBattlePokemon()
	local ours, enemy = activePokemon()
	if enemy.hp == 0 then
		return
	end
	for idx=1,4 do
		local move = ours.moves[idx]
		if move then
			move.midx = idx
		end
	end
	return ours, enemy
end

function Combat.nonKill()
	local ours, enemy = getBattlePokemon()
	if not enemy then
		return
	end
	local bestDmg = -1
	local ret = nil
	for __,move in ipairs(ours.moves) do
		if not move.pp or move.pp > 0 then
			local __, maxDmg = calcDamage(move, ours, enemy, true)
			if maxDmg > 0 then
				local threshold = maxDmg * 0.975
				if threshold and threshold < enemy.hp and threshold > bestDmg then
					ret = move
					bestDmg = threshold
				end
			end
		end
	end
	return ret
end

function Combat.bestMove()
	local ours, enemy = getBattlePokemon()
	if enemy then
		return getBestMove(ours, enemy)
	end
end

function Combat.enemyAttack()
	local ours, enemy = activePokemon()
	if enemy.hp == 0 then
		return
	end
	return calcBestHit(enemy, ours, false)
end

function Combat.updateHP(curr_hp)
	local expChange = Memory.raw(0x117B)
	if curr_hp ~= lastHP or expChange ~= lastExp then
		local max_hp = Combat.maxHP()
		if max_hp < curr_hp then
			max_hp = curr_hp
		end
		lastExp = expChange
		lastHP = curr_hp
		local baseExp = Pokemon.getExpForLevelFromCurrent(0)
		local expForCurrentLevel = Pokemon.getExp() - baseExp
		local nextLevelExp = math.max(Pokemon.getExpForLevelFromCurrent(1) - baseExp, 1)
		Bridge.hp(curr_hp, max_hp, expForCurrentLevel, nextLevelExp, Pokemon.index(0, "level"))
	end
end

return Combat
