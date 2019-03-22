local co2 = require "co2.core"

local function error_function()
	error("EEK")
end

local function success_function()
	return true
end

local function strip_traceback_header(traceback)
	return traceback:gsub("^.-\n", "")
end

local function cut_traceback_after(traceback, name)
	local pos = traceback:find(name, 0, true)
	if not pos then return traceback end

	pos = traceback:find("\n", pos, true)
	if not pos then return traceback end

	return traceback:sub(1, pos)
end

describe("co2.core", function()
	it("can create normal tracebacks without coroutines", function()
		local function testf()
			local real_traceback, co2_traceback = debug.traceback(), co2.traceback()
			return real_traceback, co2_traceback
		end

		local function FUNCTION_BOUNDARY()
			local a, b = testf()
			return a, b
		end

		local real_traceback, co2_traceback = FUNCTION_BOUNDARY()
		real_traceback = cut_traceback_after(real_traceback, "FUNCTION_BOUNDARY")
		co2_traceback = cut_traceback_after(co2_traceback, "FUNCTION_BOUNDARY")

		assert.are.same(real_traceback, co2_traceback)
	end)

	describe("can \"stitch\" tracebacks across coroutine boundaries", function()
		local co = coroutine.create(error_function)
		coroutine.resume(co)

		local function testf()
			local real_traceback, co2_traceback = debug.traceback(), co2.traceback(co)
			return real_traceback, co2_traceback
		end

		local function FUNCTION_BOUNDARY()
			local a, b = testf()
			return a, b
		end

		local real_traceback, co2_traceback = FUNCTION_BOUNDARY()
		local co1_traceback = debug.traceback(co)
		real_traceback = cut_traceback_after(real_traceback, "FUNCTION_BOUNDARY")
		co2_traceback = cut_traceback_after(co2_traceback, "FUNCTION_BOUNDARY")

		it("contains the coroutine's traceback", function()
			assert.is_not_nil(co2_traceback:find(co1_traceback, 0, true))
		end)

		it("contains the calling coroutine's traceback", function()
			local stripped = strip_traceback_header(real_traceback)
			assert.is_not_nil(co2_traceback:find(stripped, 0, true))
		end)
	end)

	it("has co2.presume", function()
		local co = coroutine.create(error_function)
		local success, result = co2.presume(co)

		assert.is_false(success)
		assert.is_not_nil(result:find("EEK", 0, true))

		co = coroutine.create(success_function)
		success, result = co2.presume(co)

		assert.is_true(success)
		assert.is_true(result)
	end)

	it("has co2.xpresume", function()
		local co, msg
		local function handler(_msg, coro)
			assert.are.equal(co, coro)
			msg = _msg
			return handler
		end

		co = coroutine.create(error_function)
		local success, result = co2.xpresume(co, handler)

		assert.is_false(success)
		assert.are.equal(result, handler)
		assert.is_not_nil(msg:find("EEK", 0, true))

		co = coroutine.create(success_function)
		success, result = co2.xpresume(co, handler)

		assert.is_true(success)
		assert.is_true(result)
	end)

	it("has co2.resume", function()
		local co
		local function resumer()
			return co2.resume(co)
		end

		co = coroutine.create(error_function)
		local success, result = pcall(co2.resume, co)

		assert.is_false(success)
		assert.is_not_nil(result:find("EEK", 0, true))
		assert.is_not_nil(result:find("Coroutine failure", 0, true))
		assert.is_not_nil(result:find("Coroutine stack traceback", 0, true))

		co = coroutine.create(success_function)
		result = assert.has_no_errors(resumer)

		assert.is_true(result)
	end)

	it("has an extended co2.wrap", function()
		local co = co2.wrap(error_function)
		local success, result = pcall(co)

		assert.is_false(success)
		assert.is_not_nil(result:find("EEK", 0, true))
		assert.is_not_nil(result:find("Coroutine failure", 0, true))
		assert.is_not_nil(result:find("Coroutine stack traceback", 0, true))

		co = co2.wrap(success_function)
		result = assert.has_no_errors(co)

		assert.is_true(result)
	end)
end)
