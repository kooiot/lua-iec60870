local base = require 'iec60870.master.channel'
local f_apdu = require 'iec60870.frame.apdu'
local f_apci = require 'iec60870.frame.apci'

local channel = base:subclass('LUA_IEC60870_MASTER_CS101_CHANNEL')

function channel:initialize(master, linker)
	self._master = assert(master, 'Master is required')
	assert(linker, 'Linker is required')
	base.initialize(self, linker)
end

function channel:reset()
	return self._linker:reset()
end

function channel:frame_parser(raw, index)
	local frame = f_apdu:new(false)

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
	if req:APCI():TYPE() == f_apci.static.FRAME_U then
		if resp:APCI():TYPE() == f_apci.static.FRAME_U then
			if req:APCI():FRAME():match_request(resp:APCI():FRAME()) then
				return true
			end
		end
	end

	-- print('ERROR', req, resp)

	return false
end

function channel:on_request(req)
	-- Find addr
	local slave = self._master:find_slave(self._linker)
	if not slave then
		return false, 'Address not match any slave'
	end

	return slave:on_request(req)
end

return channel
