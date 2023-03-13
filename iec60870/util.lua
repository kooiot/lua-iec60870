-- Utils functions

local _M = {}

_M.time = function()
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

return _M
