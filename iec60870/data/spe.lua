local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_SPE')

function data:initialize(gs, sl1, sl2, sl3, sie, srd)
	gs = gs or 0
	sl1 = sl1 or 0
	sl2 = sl2 or 0
	sl3 = sl3 or 0
	sie = sie or 0
	srd = srd or 0
	self._val = (gs & 0x1) + ((sl1 & 0x1) << 1) + ((sl2 & 0x1) << 2) + ((sl3 & 0x1) << 3) + ((sie & 0x1) << 4) + ((srd & 0x1) << 5)
end

function data:GS()
	return self._val & 0x1
end

function data:SL1()
	return (self._val >> 1) & 0x1
end

function data:SL2()
	return (self._val >> 2) & 0x1
end

function data:SL3()
	return (self._val >> 3) & 0x1
end

function data:SIE()
	return (self._val >> 4) & 0x1
end

function data:SRD()
	return (self._val >> 5) & 0x1
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
		name = 'SPE',
		gs = self:GS(),
		sl1 = self:SL1(),
		sl2 = self:SL2(),
		sl3 =  self:SL3(),
		sie = self:SIE(),
		srd = self:SRD(),
	}
end

return data
