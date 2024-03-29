local base = require 'iec60870.master.channel'
local ft12 = require 'iec60870.frame.ft12'
local f_ctrl = require 'iec60870.frame.ctrl'

local channel = base:subclass('LUA_IEC60870_MASTER_CS101_CHANNEL')

function channel:initialize(master, linker)
	self._master = assert(master, 'Master is required')
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
		return false, 'Address not matched'
	end

	-- Find addr
	local slave = self._master:find_slave(addr:ADDR())
	if not slave then
		return false, 'Address not match any slave'
	end

	return true
end

function channel:on_request(req)
	local addr = req:ADDR()

	-- Find addr
	local slave = self._master:find_slave(addr:ADDR())
	if not slave then
		return false, 'Address not match any slave'
	end

	return slave:on_request(req)
end

return channel
