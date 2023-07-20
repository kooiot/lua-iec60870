--[[ 
-- Base class for 60870 master object (for slave)
--]]
local class = require 'middleclass'

local master = class('LUA_IEC60870_SLAVE_COMMON_MASTER')

function master:initialize()
end

function master:make_data_frame(asdu)
	assert(false, 'Not implemented!')
end

function master:request(frame, need_confirm, need_terminate, desc)
	assert(false, 'Not implemented!')
end

return master
