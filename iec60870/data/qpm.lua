local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_QPM')

function data:initialize(kpa, lpc, pop)
	kpa = kpa or 0
	lpc = lpc or 0
	pop = pop or 0
	self._val = (kpa & 0x3F) + ((lpc & 0x1) << 6) + ((pop & 0x1) << 7)
end

function data:KPA()
	return self._val & 0x3F
end

function data:LPC()
	return (self._val >> 6) & 0x1
end

function data:POP()
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
		name = 'QPM',
		kpa = self:KPA(),
		lpc = self:LPC(),
		pop = self:POP(),
	}
end

return data
