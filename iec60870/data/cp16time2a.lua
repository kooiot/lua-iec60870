-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local data = class('LUA_ICE60870_DATA_CP56TIME2A')

function data:initialize(ms)
	self._ms = ms or 0
end

function data:MS()
	return self._ms
end

function data:to_hex()
	return string.pack('<I2', self._ms)
end

function data:from_hex(raw, index)
	self._ms, index  = string.pack('<I2', raw, index)
	return index + 7
end

function data:__to_string()
	return table.concat({
		'SEC:', self._ms // 1000 
		'MS:', self._ms % 1000,
	})
end

return data
