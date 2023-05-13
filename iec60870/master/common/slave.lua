local class = require 'middleclass'

local slave = class('LUA_IEC60870_MASTER_COMMON_SLAVE')

function slave:initialize()
end

function slave:ADDR()
	assert(false, 'Not implemented!')
end

function slave:make_data_frame(asdu)
	assert(false, 'Not implemented!')
end

function slave:request(frame, need_confirm, need_terminate, desc)
	assert(false, 'Not implemented!')
end

return slave
