local base = require 'iec60870.frame.base'
local cp5time2a = require 'iec60870.data.cp5time2a'
local helper = require 'iec60870.frame.helper'
local conf = require 'iec60870.conf'

local object = base:subclass('LUA_IEC60870_ASDU_OBJECT')

function object:initialize(addr, data, time)
	self._addr = addr or 0
	self._data = data or nil
	self._time = time or cp5time2a:new()
end

function object:ADDR()
	return self._addr
end

function object:DATA()
	return self._data
end

function object:TIME()
	return self._time
end

function object:to_hex()
	return string.pack('<I'..conf.ADDR_LEN, self._addr)..self._data:to_hex()..self._time:to_hex()
end

function object:from_hex(raw, index)
	self._addr, index = string.unpack('<I'..conf.ADDR_LEN, raw, index)

	index = self._data:from_hex(raw, index)

	index = self._time:from_hex(raw, index)
	return index
end

function object:__totable()
	return {
		name = 'ASDU Object',
		addr = self._addr,
		data = helper.totable(self._data),
		time = helper.totable(self._time),
	}
end

return object
