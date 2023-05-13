local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_CP16TIME2A')

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
	self._ms, index  = string.unpack('<I2', raw, index)
	return index
end

function data:__totable()
	return {
		name = 'CP16Time2a',
		ms = self._ms,
	}
end

return data
