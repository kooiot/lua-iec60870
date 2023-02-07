-- M_DP_NA_1
local qv_base = require 'iec60870.data.qv_base'
local types = require 'iec60870.frame.types'

local data = qv_base:subclass('LUA_ICE60870_DATA_DIQ')

function data:initialize(dpi, bl, sb, nt, iv)
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
	 local val = string.byte(raw, index)
	 self._dpi = val & 0x3
	 qv_base.set_value(self, val & 0xF0)
	 return index + 1
end

function data:__to_string()
	return  'DPI:'..types.dpi_str_table[self:DPI()]..qv_base.__to_string(self)
end

return data
