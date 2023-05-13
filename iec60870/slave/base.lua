local class = require 'middleclass'
local g_conf = require 'iec60870.conf'
local logger = require 'iec60870.common.logger'

local base = class('LUA_IEC60870_SLAVE_BASE')

function base:initialize(conf)
	conf = conf or {}
	-- Change configuration
	for k, v in pairs(g_conf) do
		if conf[k] ~= nil then
			logger.info('Global setting overwrite key: '..k..' val: '..conf[k])
			g_conf[k] = conf[k]
		end
	end
end

function base:start()
	assert(false, 'Not implemented!')
end

function base:stop()
	assert(false, 'Not implemented!')
end

function base:match_request(req, resp)
	return true
end

return base
