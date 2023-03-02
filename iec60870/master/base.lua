local class = require 'middleclass'
local g_conf = require 'ice60870.conf'
local logger = require 'ice60870.logger'

local base = class('LUA_IEC60870_MASTER_BASE')

function base:initialize(log, conf)
	-- Set logger
	logger.set_log(log)
	-- Change configuration
	for k, v in pairs(g_conf) do
		if conf[k] ~= nil then
			logger.info('Global setting overwrite key: '..k..' val: '..v)
			g_conf[k] = v
		end
	end

	self._requests = {}
end

function base:start()
	assert(false, 'Not implemented!')
end

function base:stop()
	assert(false, 'Not implemented!')
end

return base
