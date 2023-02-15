local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = class('LUA_IEC60870_DATA_RSI')

data.static.START = 1
data.static.STOP = 0

function data:initialize(se)
	self._val = ((se & 0x1) << 7)
end

function data:SE()
	return (self._val >> 7) & 0x1
end

function data:to_hex()
	return string.char(self._val)
end

function data:from_hex(raw, index)
	self._val = string.byte(raw, index)
	return index + 1
end

function data:__totable()
	return {
		name = 'RSI',
		se = self:SE(),
	}
end

return data
