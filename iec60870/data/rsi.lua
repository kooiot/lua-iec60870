local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local f_addr = require 'iec60870.frame.addr'
local helper = require 'iec60870.frame.helper'

local data = base:subclass('LUA_IEC60870_DATA_RSI')

function data:initialize(sn, ti)
	self._sn = sn
	self._ti = ti
end

function data:SN()
	return self._sn & 0xFFFF
end

function data:TI()
	return self._ti
end

function data:to_hex()
	return string.pack('<I2I1', self._sn & 0xFFFF, self._ti & 0xFF)
end

function data:from_hex(raw, index)
	self._sn, self._ti, index = string.unpack('<I2I1', raw, index)
	return index
end

function data:__totable()
	return {
		name = 'RSN',
		sn = self._sn,
		ti = self._ti,
	}
end

return data
