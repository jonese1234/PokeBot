local Player = {}

local Textbox = require "action.textbox"

local Input = require "util.input"
local Memory = require "util.memory"

local facingDirections = {Up=8, Right=1, Left=2, Down=4}
local alternate = false

function Player.isFacing(direction)
	return Memory.value("player", "facing") == facingDirections[direction]
end

function Player.face(direction)
	if Player.isFacing(direction) then
		return true
	end
	if Textbox.handle() then
		Input.press(direction, 0)
	end
end

function Player.interact(direction, extended)
	if Player.face(direction) then
		local speed = 2
		if extended then
			speed = alternate and 4 or 0
			alternate = not alternate
		end
		Input.press("A", speed)
		return true
	end
	alternate = false
end

function Player.isMoving()
	return Memory.value("player", "moving") ~= 0
end

function Player.position()
	return Memory.value("player", "x"), Memory.value("player", "y")
end

return Player
