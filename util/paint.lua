local Paint = {}

local Memory = require "util.memory"
local Player = require "util.player"
local Utils = require "util.utils"

local Pokemon = require "storage.pokemon"

local encounters = 0
local elapsedTime = Utils.elapsedTime
local drawText = Utils.drawText

function Paint.draw(currentMap)
	local px, py = Player.position()
	drawText(0, 14, currentMap..": "..px.." "..py)
	drawText(0, 0, elapsedTime())

	if Memory.value("battle", "our_id") > 0 then
		local curr_hp = Pokemon.index(0, "hp")
		local hpStatus
		if curr_hp == 0 then
			hpStatus = "DEAD"
		elseif curr_hp <= math.ceil(Pokemon.index(0, "max_hp") * 0.2) then
			hpStatus = "RED"
		end
		if hpStatus then
			drawText(120, 7, hpStatus)
		end
	end

	local xPokemon = 125
	local yPokemon = 15
	drawText(xPokemon,yPokemon,"Pokemons: ")
	local squirtx = Pokemon.indexOf("squirtle")
	if squirtx ~= -1 then
		drawText(xPokemon,yPokemon +5,"Squirtle")
	end
	
	
	local pidgeyx = Pokemon.indexOf("pidgey")
	if pidgeyx ~= -1 then
		drawText(xPokemon,yPokemon+15,"Pidgey")
	end
	
	local spearowx = Pokemon.indexOf("spearow")
	if spearowx ~= -1 then
		drawText(xPokemon,yPokemon+15,"Spearow")
	end
	
	local parasx = Pokemon.indexOf("paras")
	if parasx ~= -1 then
		drawText(xPokemon,yPokemon+20,"Paras")
	end
	
	local oddishx = Pokemon.indexOf("oddish")
	if oddishx ~= -1 then
		drawText(xPokemon,yPokemon+20,"Oddish")
	end
	
	local nidx = Pokemon.indexOf("nidoran", "nidorino", "nidoking")
	if nidx ~= -1 then
		local att = Pokemon.index(nidx, "attack")
		local def = Pokemon.index(nidx, "defense")
		local spd = Pokemon.index(nidx, "speed")
		local scl = Pokemon.index(nidx, "special")
		drawText(60, 0,"Nido stats: "..att.." "..def.." "..spd.." "..scl)
	end
	nidx = Pokemon.indexOf("nidoran")
	if nidx == -1 then
		nidx = Pokemon.indexOf("nidorino")
		if nidx == -1 then
			nidx = Pokemon.indexOf("nidoking")
			if nidx ~= -1 then
				drawText(xPokemon,yPokemon+10,"Nidoking")
			end
		else
			drawText(xPokemon,yPokemon+10,"Nidorino")
		end
	else
		drawText(xPokemon,yPokemon+10,"Nidoran")
	end
	local enc = " encounter"
	if encounters ~= 1 then
		enc = enc.."s"
	end
	drawText(0, 116, Memory.value("battle", "critical"))
	drawText(0, 125, Memory.value("player", "repel"))
	drawText(0, 134, encounters..enc)
	return true
end

function Paint.wildEncounters(count)
	encounters = count
end

function Paint.reset()
	encounters = 0
end

return Paint
