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

function device:on_param_read(master, frame)
	return nil, 'Not implemented'
end

function device:on_param_set(master, frame)
	return nil, 'Not implemented'
end

function device:on_time_sync(master, frame)
	return nil, 'Not implemented'
end

-- Push an Class2 Data (TI=104 COT=7)
function device:on_test_command(master, frame)
	return nil, 'Not implemented'
end

-- Push an Class2 Data (TI=105 COT=7)
function device:on_reset_process_command(master, frame)
	return nil, 'Not implemented'
end

function device:on_single_command(master, frame)
	return nil, 'Not implemented'
end

function device:on_single_command_abort(master, frame)
	return nil, 'Not implemented'
end

function device:on_double_command(master, frame)
	return nil, 'Not implemented'
end

function device:on_double_command_abort(master, frame)
	return nil, 'Not implemented'
end

return device
