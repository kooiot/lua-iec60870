-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_QPM')

function data:initialize(kpa, lpc, pop)
	self._val = (kpa & 0x3F) + ((lpc & 0x1) << 6) + ((pop & 0x1) << 7)
end

function data:KPA()
	return self._val & 0x3F
end

function data:LPC()
	return (self._val >> 6) & 0x1
end

function data:POP()
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
		'KPA:', self:KPA(),
		'LPC:', self:LPC(),
		'POP:', self:POP(),
	})
end

return data
