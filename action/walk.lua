local Walk = {}

local Data = require "data.data"

local Control = require "ai.control"
local Paths = require("data."..Data.gameName..".paths")

local Input = require "util.input"
local Memory = require "util.memory"
local Player = require "util.player"

local Pokemon = require "storage.pokemon"

local path, stepIdx, currentMap
local pathIdx = 0
local customIdx = 1
local customDir = 1

-- Private functions

local function setPath(index, region)
	pathIdx = index
	stepIdx = 2
	currentMap = region
	path = Paths[index]
end

local function completeStep(region)
	stepIdx = stepIdx + 1
	return Walk.traverse(region)
end

-- Helper functions

local function dir(px, py, dx, dy)
	local direction
	if py > dy then
		direction = "Up"
	elseif py < dy then
		direction = "Down"
	elseif px > dx then
		direction = "Left"
	else
		direction = "Right"
	end
	return direction
end
Walk.dir = dir

local function step(dx, dy, through)
	local px, py = Player.position()
	if px == dx and py == dy then
		return true
	end
	Input.press(dir(px, py, dx, dy), 0, through)
end
Walk.step = step

-- Table functions

function Walk.reset()
	path = nil
	pathIdx = 0
	customIdx = 1
	customDir = 1
	currentMap = nil
	Walk.strategy = nil
end

function Walk.init()
	local region = Memory.value("game", "map")
	local px, py = Player.position()
	if region == 0 and px == 0 and py == 0 then
		return false
	end
	for tries=1,2 do
		for i,p in ipairs(Paths) do
			if i > 2 and p[1] == region then
				local origin = p[2]
				if tries == 2 or (origin[1] == px and origin[2] == py) then
					setPath(i, region)
					return tries == 1
				end
			end
		end
	end
end

function Walk.traverse(region)
	local newIndex
	if not path or currentMap ~= region then
		Walk.strategy = nil
		setPath(pathIdx + 1, region)
		newIndex = pathIdx
		customIdx = 1
		customDir = 1
	elseif stepIdx > #path then
		return
	end
	local tile = path[stepIdx]
	if tile.c then
		Control.set(tile)
		return completeStep(region)
	end
	if tile.s then
		if Walk.strategy then
			Walk.strategy = nil
			return completeStep(region)
		end
		Walk.strategy = tile
		return false
	elseif step(tile[1], tile[2]) then
		Pokemon.updateParty()
		return completeStep(region)
	end
	return newIndex
end

function Walk.canMove()
	return Memory.value("player", "moving") == 0 and Memory.value("player", "fighting") == 0
end

-- Custom path

function Walk.invertCustom(silent)
	if not silent then
		customIdx = customIdx + customDir
	end
	customDir = customDir * -1
end

function Walk.custom(cpath, increment)
	if not cpath then
		customIdx = 1
		customDir = 1
		return
	end
	if increment then
		customIdx = customIdx + customDir
	end
	local tile = cpath[customIdx]
	if not tile then
		if customIdx < 1 then
			customIdx = #cpath
		else
			customIdx = 1
		end
		return customIdx
	end
	local t1, t2 = tile[1], tile[2]
	if t2 == nil then
		if Player.face(t1) then
			Input.press("A", 2)
		end
		return t1
	end
	if step(t1, t2) then
		customIdx = customIdx + customDir
	end
end

return Walk
