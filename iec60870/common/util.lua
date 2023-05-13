-- Utils functions

local _M = {}

--- Return MS
_M.time = function()
	return os.time() * 1000
end

_M.now = function()
	return os.time() * 1000
end

_M.fork = function(...)
	assert(false, 'Not implemented')
end

_M.wakeup = function(ct)
	assert(false, 'Not implemented')
end

_M.wait = function(ct)
	assert(false, 'Not implemented')
end

_M.sleep = function(timeout_ms, ct)
	assert(false, 'Not implemented')
end

_M.timeout = function(timeout_ms, cb)
	assert(false, 'Not implemented')
end

_M.cancelable_timeout = function(timeout_ms, func)
	local function cb()
		if func then
			func()
		end
	end
	local function cancel()
		func = nil
	end
	_M.timeout(timeout_ms, cb)
	return cancel
end

return _M
