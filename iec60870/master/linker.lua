local class = require 'middleclass'
local logger = require 'ice60870.logger'

local linker = class('LUA_IEC60870_MASTER_LINKER')

function linker:initialize()
	self._requests = {}
end

function linker:open()
	assert(false, 'Not implemented!')
end

function linker:close()
	assert(false, 'Not implemented!')
end

function linker:lock()
	self._locked = true
end

function linker:unlock()
	self._locked = false
end

-- Timeout is ms
function linker:request(asdu, timeout)
	assert(asdu, 'Request and Callback is required!')
	local timeout = timeout or g_conf.TIMEOUT

	local tm = timeout
	while self._locked do
		g_conf.sleep(10)
		tm = tm - 10
		if tm < 0 then
			return nil, 'Timeout wait for lock'
		end
	end

	local req, key = self:make_frame(asdu)
	if not req then
		logger.error('Make frame error: '..key)
		return nil, key
	end

	local r, err = self:send(req)
	if not r then
		logger.error('Send frame error: '..key)
		return nil, err
	end

	local t = {}
	self._requests[key] = t
	g_conf.sleep(timeout, t)
	self._requests[key] = nil

	local result = self._results[key] or  { false, 'Timeout' }
	self._results[key] = nil

	return table.unpack(result)
end

return linker
