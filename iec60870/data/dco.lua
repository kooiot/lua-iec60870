-- M_SP_NA_1
local qoc = require 'iec60870.frame.qoc'
local types = require 'iec60870.types'

local data = qoc:subclass('LUA_IEC60870_DATA_DCO')

function data:initialize(dcs, bs, qu, se)
	qoc.initialize(self, qu, se)
	self._val = dcs & 0x3
end

function data:DCS()
	return self._val & 0x3
end

function data:to_hex()
	local val = self._val + (qoc.value(self) & 0xF8)
	return string.char(self._val)
end

function data:from_hex(raw, index)
	 local val = string.byte(raw, index)
	 self._val = val & 0x3
	 qoc.set_value(val & 0xF8)
	 return index + 1
end

function data:__to_string()
	return  'DCS:'..self:DCS()..qoc.__to_string(self)
end

return data
