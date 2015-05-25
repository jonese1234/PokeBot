local Paint = {}

local Combat = require "ai.combat"

local Memory = require "util.memory"
local Player = require "util.player"
local Utils = require "util.utils"

local Pokemon = require "storage.pokemon"

local RIGHT_EDGE, BOTTOM_EDGE = 158, 135

local encounters = 0
local elapsedTime = Utils.elapsedTime
local drawText = Utils.drawText

function Paint.draw(currentMap)
	local px, py = Player.position()
	drawText(0, 0, elapsedTime())
	drawText(0, 7, currentMap..": "..px.." "..py)

	if Memory.value("battle", "our_id") > 0 then
		local curr_hp = Combat.hp()
		local hpStatus
		if curr_hp == 0 then
			hpStatus = "DEAD"
		elseif curr_hp <= math.ceil(Combat.maxHP() * 0.2) then
			hpStatus = "RED"
		end
		if hpStatus then
			drawText(RIGHT_EDGE, 7, hpStatus, true)
		end
	end

	local caughtPokemon = {
		{"squirtle", "pikachu", "lapras"},
		{"nidoran", "nidorino", "nidoking"},
		{"spearow", "pidgey"},
		{"paras", "oddish", "charmander", "sandshrew"},
	}
	local partyY = BOTTOM_EDGE
	for __,pokemonCategory in ipairs(caughtPokemon) do
		local pokemon = Pokemon.inParty(unpack(pokemonCategory))
		if pokemon then
			drawText(RIGHT_EDGE, partyY, Utils.capitalize(pokemon), true)
			partyY = partyY - 7
		end
	end

	local nidx = Pokemon.indexOf("nidoran", "nidorino", "nidoking")
	if nidx ~= -1 then
		local att = Pokemon.index(nidx, "attack")
		local def = Pokemon.index(nidx, "defense")
		local spd = Pokemon.index(nidx, "speed")
		local scl = Pokemon.index(nidx, "special")
		drawText(RIGHT_EDGE, 0, att.." "..def.." "..spd.." "..scl, true)
	end

	drawText(0, BOTTOM_EDGE-7, "Repel: "..Memory.value("player", "repel"))
	drawText(0, BOTTOM_EDGE, Utils.pluralize(encounters, "encounter"))
	return true
end

function Paint.wildEncounters(count)
	encounters = count
end

function Paint.reset()
	encounters = 0
end

return Paint
