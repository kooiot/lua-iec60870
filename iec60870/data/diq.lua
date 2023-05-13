local qv_base = require 'iec60870.data.qv_base'
local types = require 'iec60870.types'

local data = qv_base:subclass('LUA_IEC60870_DATA_DIQ')

function data:initialize(dpi, bl, sb, nt, iv)
	dpi = dpi or 0
	bl = bl or 0
	sb = sb or 0
	nt = nt or 0
	iv = iv or 0
	qv_base.initialize(self, bl, sb, nt, iv)
	self._dpi = dpi & 0x3
end

function data:DPI()
	return self._dpi & 0x3
end

function data:to_hex()
	local val = (self._dpi & 0x3) + (qv_base.value(self) & 0xF0)
	return string.char(val)
end

function data:from_hex(raw, index)
	 local val = assert(string.byte(raw, index))
	 self._dpi = val & 0x3
	 qv_base.set_value(self, val & 0xF0)
	 return index + 1
end

function data:__totable()
	local t = qv_base.__totable(self)
	t.name = 'DIQ'
	t.dpi = types.dpi_str_table[self:DPI()]
	return t
end

return data
