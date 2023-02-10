-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.types'

local data = class('LUA_IEC60870_DATA_QOS')

function data:initialize(ql, se)
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
	self._val = string.byte(raw, index)
	return index + 1
end

function data:__to_string()
	return table.concat({
		'QL:', self:QL(),
		'S/E:', self:SE(),
	})
end

return data
