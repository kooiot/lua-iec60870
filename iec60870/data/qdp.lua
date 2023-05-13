local qv_base = require 'iec60870.data.qv_base'
local types = require 'iec60870.types'

local data = qv_base:subclass('LUA_IEC60870_DATA_QDP')

function data:initialize(ei, bl, sb, nt, iv)
	ei = ei or 0
	bl = bl or 0
	sb = sb or 0
	nt = nt or 0
	iv = iv or 0
	qv_base.initialize(self, bl, sb, nt, iv)
	self._ei = ei & 0x1
end

function data:EI()
	return self._ei & 0x1
end

function data:to_hex()
	local val = ((self._ei & 0x1) << 3) + (qv_base.value(self) & 0xF0)
	return string.char(val)
end

function data:from_hex(raw, index)
	 local val = assert(string.byte(raw, index))
	 self._ei = (val >> 3) & 0x1
	 qv_base.set_value(self, val & 0xF0)
	 return index + 1
end

function data:__totable()
	local t = qv_base.__totable(self)
	t.name = 'QDP'
	t.ei = self:EI()
	return t
end

return data
