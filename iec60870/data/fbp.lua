-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_FBP')

function data:initialize()
	self._val = 0x55AA
end

function data:to_hex()
	return string.pack('<I2', self._val)
end

function data:from_hex(raw, index)
	self._val, index = string.unpack('<I2', raw, index)
	return index
end

function data:__to_string()
	return 'FBP: 0xAA55'
end

return data
