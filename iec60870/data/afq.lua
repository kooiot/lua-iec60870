-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_AFQ')

function data:initialize(l, h)
	self._val = l & 0xF + ((h & 0xF) << 4) 
end

function data:H()
	return self._val & 0xF
end

function data:L()
	return (self._val >> 4) & 0xF
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
		'L:', self:L(),
		'H:', self:H(),
	})
end

return data
