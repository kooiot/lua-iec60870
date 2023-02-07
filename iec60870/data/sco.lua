-- M_SP_NA_1
local qoc = require 'iec60870.frame.qoc'
local types = require 'iec60870.frame.types'

local data = qoc:subclass('LUA_ICE60870_DATA_SCO')

function data:initialize(scs, bs, qu, se)
	qoc.initialize(self, qu, se)
	self._val = (scs & 0x1) + ((bs & 0x1) << 1)
end

function data:SCS()
	return self._val & 0x1
end

function data:BS()
	return (self._val >> 1) & 0x1
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
	return  'SCS:'..self:SCS()..' BS:'..self:BS()..qoc.__to_string(self)
end

return data
