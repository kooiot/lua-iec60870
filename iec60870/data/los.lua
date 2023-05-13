local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_LOS')

function data:initialize(val)
	val = val or 0
	self._val = val & 0xFF
end

function data:VAL()
	return self._val & 0xFF
end

function data:to_hex()
	return string.char(self._val)
end

function data:from_hex(raw, index)
	 self._val = assert(string.byte(raw, index))
	 return index + 1
end

function data:__totable()
	return {
		name = 'LOS',
		val = self:VAL(),
	}
end

return data
