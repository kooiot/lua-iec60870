local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_AFQ')

function data:initialize(l, h)
	l = l or 0
	h = h or 0
	self._val = l & 0xF + ((h & 0xF) << 4) 
end

function data:H()
	return self._val & 0xF
end

function data:L()
	return (self._val >> 4) & 0xF
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
		name = 'AFQ',
		l = self:L(),
		h = self:H(),
	}
end

return data
