local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_QCC')

function data:initialize(rqt, frz)
	rqt = rqt or 0
	frz = frz or 0
	self._val = (rqt & 0x3F) + (frz & 0x3) << 6
end

function data:RQT()
	return self._val & 0x3F
end

function data:FRZ()
	return (self._val >> 6) & 0x3
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
		name = 'QCC',
		rqt = self:RQT(),
		frz = self:FRZ(),
	}
end

return data
