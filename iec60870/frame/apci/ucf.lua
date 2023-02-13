local class = require 'middleclass'

local ucf = class('LUA_IEC60870_FRAME_APCI_ITF')

function ucf:initialize(test_fr, stop_dt, start_dt)
	self._test_fr = test_fr
	self._stop_dt = stop_dt
	self._start_dt = start_dt
end

function ucf:TYPE()
	local apci = require 'iec60870.frame.apci'
	return apci.static.FRAME_U
end

function ucf:TEST_FR()
	return self._test_fr
end

function ucf:STOP_DT()
	return self._stop_dt
end

function ucf:START_DT()
	return self._start_dt
end

function ucf:byte_size()
	return 4
end

function ucf:valid_bit()
	local test_fr = self._test_fr & 0x3
	local stop_dt = self._stop_dt & 0x3
	local start_dt = self._start_dt & 0x3
	if test_fr ~= 0 then
		assert(stop_dt == 0 and start_dt == 0, 'N Frame bit validation error')
	elseif stop_dt ~= 0 then
		assert(start_dt == 0, 'N Frame bit validation error')
	else
		assert(start_dt ~= 0, 'N Frame bit validation error')
	end
end

function ucf:to_hex()
	self:valid_bit()
	local val = (self._test_fr & 0x3) << 6 + (self._stop_dt & 0x3) << 4 + (self._start_dt & 0x3) << 2 + 0x3
	return string.pack('<I1I1I2', val, 0, 0)
end

function ucf:from_hex(raw, index)
	local val, _, v1 = string.unpack('<I1I1I2', raw, index)
	assert(v1 & 0x1 == 0, 'U Frame error')
	assert(val & 0x3 == 0x3, 'U Frame error')
	self._test_fr = (val >> 6) & 0x3
	self._stop_dt = (val >> 4) & 0x3
	self._start_dt = (val >> 2) & 0x3
	self:valid_bit()	
	return index + 4
end

function ucf:__tostring()
	if (self._test_fr & 0x3) ~= 0 then
		return 'ITF-> TEST_FR:'..self:TEST_FR()
	elseif (self._stop_dt & 0x3) ~= 0 then
		return 'ITF-> STOP_DT:'..self:STOP_DT()
	elseif (self._start_dt & 0x3) ~= 0 then
		return 'ITF-> START_DT:'..self:START_DT()
	end
end

return ucf
