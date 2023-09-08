local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_NVA')

function data:initialize(val)
	self._val = val or 0
end

function data:VAL()
	return self._val
end

function data:to_hex()
	if self._val < 0 then
		string.pack('<I2', (0x7FFF - self._val) & 0xFFFF)
	else
		return string.pack('<I2', self._val & 0xFFFF)
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

function data:__totable()
	return {
		name = 'NVA:',
		val = self._val,
	}
end

return data
