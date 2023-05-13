local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_R32')

function data:initialize(val)
	self._val = val or 0
end

function data:VAL()
	return self._val
end

function data:to_hex()
	return string.pack('f', self._val)
end

function data:from_hex(raw, index)
	self._val, index = string.unpack('f', raw, index)
	return index
end

function data:__totable()
	return {
		name = 'IEEE STD 754 Float',
		val = self._val
	}
end

return data
