local helper = require 'iec60870.common.helper'
local base = require 'iec60870.frame.base'

local VSQ = require 'iec60870.asdu.vsq'
local COT = require 'iec60870.asdu.cot'
local CAOA = require 'iec60870.asdu.caoa'

local unit = base:subclass('LUA_IEC60870_FRAME_UNIT')

function unit:initialize(ti, cot, caoa, vsq)
	self._ti = ti or 0
	self._cot = cot or COT:new()
	self._caoa = caoa or CAOA:new()
	self._vsq = vsq or VSQ:new()
end

function unit:TI()
	return self._ti
end

function unit:VSQ()
	return self._vsq
end

function unit:SET_VSQ(vsq)
	self._vsq = vsq
end

function unit:COT()
	return self._cot
end

function unit:CAOA()
	return self._caoa
end

function unit:OBJ()
	return self._obj
end

function unit:SET_OBJ(obj)
	self._obj = obj
end

function unit:to_hex()
	return string.char(self._ti)..self._vsq:to_hex()..self._cot:to_hex()..self._caoa:to_hex()
end

function unit:from_hex(raw, index)
	self._ti = string.byte(raw, index)
	index = index + 1
	index = self._vsq:from_hex(raw, index)
	index = self._cot:from_hex(raw, index)
	index = self._caoa:from_hex(raw, index)
	return index
end

function unit:__totable()
	return {
		name = 'Unit',
		ti = self._ti,
		vsq = helper.totable(self._vsq),
		cot = helper.totable(self._cot),
		caoa = helper.totable(self._caoa),
	}
end

return unit
