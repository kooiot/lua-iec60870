local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_BSI')

function data:initialize(val)
	self._val = val or 0
end

function data:BIT(offset)
	assert(offset >= 0 and offset < 32)
	return (self._val >> offset) & 0x1
end

function data:SET_BIT(offset, bv)
	assert(offset >= 0 and offset < 32)
	self._val = self._val | ((bv & 0x1) << offset)
end

function data:VAL()
	return self._val
end

function data:to_hex()
	return string.pack('I4', self._val)
end

function data:from_hex(raw, index)
	self._val, index = string.unpack('I4', raw, index)
	return index
end

function data:__totable()
	local t = {
		name = 'BSI',
		val = string.format('%08X', self._val)
	}

	return t
end

return data
