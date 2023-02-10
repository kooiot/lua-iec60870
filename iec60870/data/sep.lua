-- M_DP_NA_1
local qv_base = require 'iec60870.data.qv_base'
local types = require 'iec60870.types'

local data = qv_base:subclass('LUA_IEC60870_DATA_SEP')

function data:initialize(es, ei, bl, sb, nt, iv)
	qv_base.initialize(self, bl, sb, nt, iv)
	self._es = es & 0x3
	self._ei = ei & 0x1
end

function data:EI()
	return self._ei & 0x1
end

function data:ES()
	return self._es & 0x3
end

function data:to_hex()
	local val = self._es & 0x3 + ((self._ei & 0x1) << 3) + (qv_base.value(self) & 0xF0)
	return string.char(val)
end

function data:from_hex(raw, index)
	 local val = string.byte(raw, index)
	 self._es = val & 0x3
	 self._ei = (val >> 3) & 0x1
	 qv_base.set_value(self, val & 0xF0)
	 return index + 1
end

function data:__to_string()
	return  'EI:'..self:EI()..qv_base.__to_string(self)
end

return data
