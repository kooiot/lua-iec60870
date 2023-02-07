-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_SVA')

function data:initialize(val)
	self._val = val
end

function data:VAL()
	return self._val
end

function data:to_hex()
	return string.pack('f', self._val)
end

function data:from_hex(raw, index)
	self._val, index = string.unpack('f', raw, index)
	return index
end

function data:__to_string()
	return 'FLOAT:'..self._val
end

return data
