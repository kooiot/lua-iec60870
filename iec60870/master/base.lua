local class = require 'middleclass'
local g_conf = require 'ice60870.conf'
local logger = require 'ice60870.logger'

local base = class('LUA_IEC60870_MASTER_BASE')

function base:initialize(logger, conf)
	for k, v in pairs(g_conf) do
		if conf[k] ~= nil then
			logger.info('Global setting overwrite key: '..k..' val: '..v)
			g_conf[k] = v
		end
	end

	self._requests = {}
end

function base:make_frame(asdu)
	assert(false, 'Not implemented!')
end

function base:send(req)
	assert(false, 'Not implemented!')
end

function base:start()
	assert(false, 'Not implemented!')
end

function base:stop()
	assert(false, 'Not implemented!')
end

function base:lock()
	self._locked = true
end

function base:unlock()
	self._locked = false
end

-- Timeout is ms
function base:request(asdu, timeout)
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

return base
