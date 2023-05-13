local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_SRQ')

function data:initialize(val, bs)
	val = val or 0
	bs = bs or 0
	self._val = val & 0x7F + ((bs & 0x1) << 7) 
end

function data:VAL()
	return self._val & 0x7F
end

function data:BS()
	return (self._val >> 7) & 0x1
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
		name = 'SRQ',
		val = self:VAL(),
		bs = self:BS(),
	}
end

return data
