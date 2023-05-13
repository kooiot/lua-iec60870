local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_QOS')

function data:initialize(ql, se)
	ql = ql or 0
	se = se or 0
	self._val = ql & 0x7F + ((se & 0x1) << 7)
end

function data:QL()
	return self._val & 0x7F
end

function data:SE()
	return (self._val >> 7) & 0x1
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
		name = 'QOS',
		ql = self:QL(),
		se = self:SE(),
	}
end

return data
