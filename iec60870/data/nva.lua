-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_NVA')

function data:initialize(val)
	self._val = val
end

function data:VAL()
	return self._val
end

function data:to_hex()
	if self._val < 0 then
		string.pack('<I2', 0x7FFFF - self._val)
	else
		return string.pack('<I2', self._val)
	end
end

function data:from_hex(raw, index)
	local val = string.unpack('<I2', raw, index)
	if val > 0x7FFF then
		self._val = 0xFFFF - val
	else
		self._val = val
	end
	return index + 2
end

function data:__to_string()
	return 'NVA:'..self._val
end

return data
