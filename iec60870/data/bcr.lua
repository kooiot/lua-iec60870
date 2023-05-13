local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_BCR')

function data:initialize(val, sq, cy, cv, iv)
	val = val or 0
	sq = sq or 0
	cy = cy or 0
	cv = cv or 0
	iv = iv or 0
	self._val = val
	self._bcr = (sq & 0x1F) + ((cy & 0x1) << 5) + ((cv & 0x1) << 6) + ((iv & 0x1) << 7)
end

function data:VAL()
	return self._val & 0xFFFFFFFF
end

function data:BCR()
	return self._bcr
end

function data:SQ()
	return self._bcr & 0x1F
end

function data:CY()
	return (self._bcr >> 5) & 0x1
end

function data:CV()
	return (self._bcr >> 6) & 0x1
end

function data:IV()
	return (self._bcr >> 7) & 0x1
end

function data:to_hex()
	return string.pack('<i4', self._val)..string.pack('<I1', self._bcr)
end

function data:from_hex(raw, index)
	 self._val, index = string.unpack('<i4', raw, index)
	 self._bcr, index = string.unpack('<I1', raw, index)
	 return index
end

function data:__totable()
	return {
		name = 'BCR',
		val = self:VAL(),
		bcr = self:BCR(),
	}
end

return data
