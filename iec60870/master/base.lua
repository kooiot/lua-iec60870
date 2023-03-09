local class = require 'middleclass'
local util = require 'iec60870.util'
local g_conf = require 'iec60870.conf'
local logger = require 'iec60870.logger'
local buffer = require 'iec60870.buffer'

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
