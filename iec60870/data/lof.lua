local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_NOF')

function data:initialize(val)
	val = val or 0
	self._val = val & 0xFFFFFF
end

function data:VAL()
	return self._val & 0xFFFFFF
end

function data:to_hex()
	return string.pack('<I3', self._val)
end

function data:from_hex(raw, index)
	 self._val, index = string.unpack('<I3', raw, index)
	 return index
end

function data:__totable()
	return {
		name = 'NOF',
		val = self:VAL(),
	}
end

return data
