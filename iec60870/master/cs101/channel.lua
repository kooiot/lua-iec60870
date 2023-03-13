local base = require 'iec60870.master.channel'
local ft12 = require 'iec60870.frame.ft12'

local channel = base:subclass('LUA_IEC60870_MASTER_CS101_CHANNEL')

function channel:initialize(master, linker)
	self._master = master
	base.initialize(self, linker)
end

function channel:frame_parser(raw, index)
	return ft12:valid_hex(raw, index)
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

	local ctrl = resp:CTRL()
	if ctrl:FCB() ~= slave:FCB() then
		return false, 'FCB is not same'
	end

	--- TODO: NEXT_FCB?
	slave:FCB_NEXT()

	return true
end

return channel
