local qv_base = require 'iec60870.data.qv_base'
local types = require 'iec60870.types'

local data = qv_base:subclass('LUA_IEC60870_DATA_QDS')

function data:initialize(ov, bl, sb, nt, iv)
	qv_base.initialize(self, bl, sb, nt, iv)
	self._ov = ov & 0x1
end

function data:OV()
	return self._ov & 0x3
end

function data:to_hex()
	local val = (self._ov & 0x1) + (qv_base.value(self) & 0xF0)
	return string.char(val)
end

function data:from_hex(raw, index)
	 local val = string.byte(raw, index)
	 self._ov = val & 0x1
	 qv_base.set_value(self, val & 0xF0)
	 return index + 1
end

function data:__totable()
	local t = qv_base.__totable(self)
	t.name = 'QDS'
	t.ov = self:OV()
	return t
end

return data
