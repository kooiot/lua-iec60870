local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_I8')

function data:initialize(val)
	self._val = val or 0
end

function data:VAL()
	return self._val
end

function data:to_hex()
	return string.pack('<I1', self._val)
end

function data:from_hex(raw, index)
	self._val, index = string.unpack('<I1', raw, index)
	return index
end

function data:__totable()
	return {
		name = 'Integer 8 bits (unsigned)',
		val = self._val
	}
end

return data
