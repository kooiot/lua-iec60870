-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_NOF')

function data:initialize(val)
	self._val = val & 0xFFFFFF
end

function data:VAL()
	return self._val & 0xFFFFFF
end

function data:to_hex()
	return string.pack('<I3', self._val)
end

function data:from_hex(raw, index)
	 self._val, index = string.unpack('<I3', raw, index)
	 return index
end

function data:__to_string()
	return table.concat({
		'VAL:', self:VAL(),
	})
end

return data
