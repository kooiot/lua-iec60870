local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local helper = require 'iec60870.common.helper'

local data = base:subclass('LUA_IEC60870_DATA_NVA')

function data:initialize(val)
	self._val = val or 0
end

function data:VAL()
	return self._val
end

function data:to_hex()
	if self._val < 0 then
		local val = (0x10000 + self._val) & 0x7FFF
		-- print('-', val)
		-- print(self._val, string.pack('<I2', ((0x10000 + self._val) & 0x7FFF) + 0x8000))
		return string.pack('<I2', ((0x10000 + self._val) & 0x7FFF) + 0x8000)
	else
		-- print('+', self._val & 0x7FFF)
		-- print(self._val, helper.to_hex(string.pack('<I2', self._val & 0x7FFF)))
		return string.pack('<I2', self._val & 0x7FFF)
	end
end

function data:from_hex(raw, index)
	local val = string.unpack('<I2', raw, index)
	if val > 0x7FFF then
		self._val = (val & 0x7FFF) - 0x10000
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
