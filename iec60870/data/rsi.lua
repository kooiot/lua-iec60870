local helper = require 'iec60870.common.helper'
local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_RSI')

-- 修改多个参数和定值的固化/撤销报文 (203)
--SN: 定值区号
--TI: 特征标识
function data:initialize(sn, ti)
	self._sn = sn or 0
	self._ti = ti or 0
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
		name = 'RSI',
		sn = self._sn,
		ti = self._ti,
	}
end

return data
