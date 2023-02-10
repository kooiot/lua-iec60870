-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_IEC60870_DATA_SRQ')

function data:initialize(val, bs)
	self._val = val & 0x7F + ((bs & 0x1) << 7) 
end

function data:VAL()
	return self._val & 0x7F
end

function data:BS()
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
		'VAL:', self:VAL(),
		'BS:', self:BS(),
	})
end

return data
