local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_FBP')

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

function data:__totable()
	return {
		name = 'FBP',
		fbp = '0xAA55'
	}
end

return data
