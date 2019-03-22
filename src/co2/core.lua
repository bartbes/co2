-- Copyright (c) 2019 Bart van Strien
-- See LICENSE file for more information

local co2 = {}
local co1 = require "coroutine"

co2.create = co1.create
co2.running = co1.running
co2.status = co1.status
co2.yield = co1.yield

-- Note: rename resume to presume
co2.presume = co1.resume

local function strip_traceback_header(traceback)
	return traceback:gsub("^.-\n", "")
end

function co2.traceback(coro, level)
	level = level or 0

	local parts = {}

	if coro then
		table.insert(parts, debug.traceback(coro))
	end

	-- Note: for some reason debug.traceback needs a string to pass a level
	-- But if you pass a string it adds a newline
	table.insert(parts, debug.traceback("", 2 + level):sub(2))

	for i = 2, #parts do
		parts[i] = strip_traceback_header(parts[i])
	end

	return table.concat(parts, "\n\t-- coroutine boundary --\n")
end

-- xpresume is to presume what xpcall is to pcall
-- Except xpresume can also pass arguments
function co2.xpresume(coro, handler, ...)
	local function dispatch(status, maybe_err, ...)
		if status then
			return true, maybe_err, ...
		else
			return false, handler(maybe_err, coro)
		end
	end

	return dispatch(co2.presume(coro, ...))
end

local function generic_error_handler(msg, coro)
	error(string.format("Coroutine failure: %s\n\nCoroutine %s", msg, debug.traceback(coro)))
end

-- resume then propagates the error, using a default generic error handler
-- which adds a coroutine stack trace
function co2.resume(coro, ...)
	return select(2, co2.xpresume(coro, generic_error_handler, ...))
end

-- And co2.wrap is like coroutine.wrap, except it uses co2.resume, and thus
-- the same generic error handler
function co2.wrap(f)
	local co = co2.create(f)

	return function(...)
		return co2.resume(co, ...)
	end
end

return co2
