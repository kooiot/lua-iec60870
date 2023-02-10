-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.types'

local data = class('LUA_IEC60870_DATA_SPE')

function data:initialize(gs, sl1, sl2, sl3, sie, srd)
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
	 self._val = string.byte(raw, index)
	 return index + 1
end

function data:__to_string()
	return table.concat({
		'GS:', self:GS(),
		'SL1:', self:SL1(),
		'SL2:', self:SL2(),
		'SL3:', self:SL3(),
		'SIE:', self:SIE(),
		'SRD:', self:SRD(),
	})
end

return data
