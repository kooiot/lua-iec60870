local class = require 'middleclass'

local device = class('LUA_IEC60870_SLAVE_COMMON_DEVICE_BASE')

function device:initialize(addr)
	self._addr = addr
end

function device:ADDR()
	return self._addr
end

function device:link_reset()
	assert(nil, 'Not implemented')
end

function device:make_snapshot()
	assert(nil, 'Not implemented')
end

function device:poll_class1()
	assert(nil, 'Not implemented')
end

function device:poll_class2()
	assert(nil, 'Not implemented')
end

function device:on_run()
	assert(nil, 'Not implemented')
end

return device
