local base = require 'iec60870.slave.channel'
local ft12 = require 'iec60870.frame.ft12'
local f_ctrl = require 'iec60870.frame.ctrl'

local channel = base:subclass('LUA_IEC60870_SLAVE_CS101_CHANNEL')

function channel:initialize(slave, linker)
	self._slave = assert(slave, 'Slave is required')
	assert(linker, 'Linker is required')
	base.initialize(self, linker)
end

function channel:frame_parser(raw, index)
	local frame = ft12:new()

	local r, next_index, err = frame:valid_hex(raw, index)
	if not r then
		return nil, next_index, err
	end
	return frame, next_index
end

function channel:frame_min()
	return 1
end

function channel:match_request(req, resp)
	local addr = resp:ADDR()
	if addr ~= req:ADDR() then
		print('xxxxxxxxxx')
		return false, 'Address not matched'
	end

	-- Find addr
	local master = self._slave:find_master(addr:ADDR())
	if not master then
		print('xxxxxxxxxx 2222')
		return false, 'Address not match any master'
	end
	return true
end

function channel:on_request(req)
	local addr = req:ADDR()
	local master = self._slave:find_master(addr:ADDR())
	if not master then
		return false, 'Address not match any master'
	end
	return master:on_request(req)
end

return channel
