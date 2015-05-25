local Bridge = {}

local Utils = require "util.utils"

local json = require "external.json"

local socket
if INTERNAL then
	socket = require "socket"
end

local client = nil
local timeStopped = true

local function send(prefix, body)
	if client then
		local message = prefix
		if body then
			message = message..","..body
		end
		client:send(message.."\n")
		return true
	end
end

local function readln()
	if client then
		local s, status, partial = client:receive("*l")
		if status == "closed" then
			client = nil
			return nil
		end
		if s and s ~= "" then
			return s
		end
	end
end

-- Wrapper functions

function Bridge.init(gameName)
	if socket then
		-- io.popen("java -jar Main.jar")
		client = socket.connect("127.0.0.1", 13378)
		if client then
			client:settimeout(0.005)
			client:setoption("keepalive", true)
			print("Connected to Java!");
			send("init,"..gameName)
			return true
		else
			print("Error connecting to Java!");
		end
	end
end

function Bridge.tweet(message)
	if STREAMING_MODE then
		print("tweet::"..message)
		return send("tweet", message)
	end
end

function Bridge.pollForName()
	Bridge.polling = true
	send("poll_name")
end

function Bridge.chatRandom(...)
	return Bridge.chat(Utils.random(arg))
end

function Bridge.chat(message, suppressed, extra, newLine)
	if not suppressed then
		if extra then
			p(message.." || "..extra, newLine)
		else
			p(message, newLine)
		end
	end
	return send("msg", message)
end

function Bridge.time(message)
	if not timeStopped then
		return send("time", message)
	end
end

function Bridge.stats(message)
	return send("stats", message)
end

function Bridge.command(command)
	return send("livesplit_command", command);
end

function Bridge.comparisonTime()
	return send("livesplit_getcomparisontime");
end

function Bridge.process()
	local response = readln()
	if response then
		-- print(">"..response)
		if response:find("name:") then
			return response:gsub("name:", "")
		end
	end
end

function Bridge.input(key)
	send("input", key)
end

function Bridge.caught(name)
	if name then
		send("caught", name)
	end
end

function Bridge.hp(curr_hp, max_hp, curr_xp, max_xp, level)
	send("hpxp", curr_hp..","..max_hp..","..curr_xp..","..max_xp..","..level)
end

function Bridge.liveSplit()
	send("start")
	timeStopped = false
end

function Bridge.split(finished)
	if finished then
		timeStopped = true
	end
	send("split")
end

function Bridge.encounter()
	send("encounter")
end

function Bridge.report(report)
	if INTERNAL and not STREAMING_MODE then
		print(json.encode(report))
	end
	send("report", json.encode(report))
end

-- GUESSING

function Bridge.guessing(guess, enabled)
	send(guess, tostring(enabled))
end

function Bridge.guessResults(guess, result)
	send(guess.."results", result)
end

function Bridge.moonResults(encounters, cutter)
	Bridge.guessResults("moon", encounters..","..(cutter and "cutter" or "none"))
end

-- RESET

function Bridge.reset()
	send("reset")
	timeStopped = false
end

function Bridge.close()
	if client then
		client:close()
		client = nil
	end
	print("Bridge closed")
end

return Bridge
