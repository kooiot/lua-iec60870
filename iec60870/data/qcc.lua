-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_QCC')

function data:initialize(rqt, frz)
	self._val = (rqt & 0x3F) + (frz & 0x3) << 6
end

function data:RQT()
	return self._val & 0x3F
end

function data:FRZ()
	return (self._val >> 6) & 0x3
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
		'RQT:', self:RQT(),
		'FRZ:', self:FRZ(),
	})
end

return data
