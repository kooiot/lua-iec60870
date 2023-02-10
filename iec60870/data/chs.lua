-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.types'

local data = class('LUA_IEC60870_DATA_CHS')

function data:initialize(val)
	self._val = val & 0xFF
end

function data:VAL()
	return self._val & 0xFF
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
	})
end

return data
