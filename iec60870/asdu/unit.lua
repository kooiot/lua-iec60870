local class = require 'middleclass'
local VSQ = require 'iec60870.frame.vsq'
local COT = require 'iec60870.frame.cot'
local CAOA = require 'iec60870.frame.caoa'

local unit = class('LUA_IEC60870_FRAME_UNIT')

function unit:initialize(ti, vsq, cot, caoa)
	self._ti = ti or 0
	self._vsq = vsq or VSQ:new()
	self._cot = cot or COT:new()
	self._caoa = caoa or CAOA:new()
end

function unit:TI()
	return self._ti
end

function unit:VSQ()
	return self._vsq
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
	self._val = string.byte(raw, index)
	index = index + 1
	index = self._vsq:from_hex(raw, index)
	index = self._cot:from_hex(raw, index)
	index = self._caoa:from_hex(raw, index)
	return index
end

function unit:__tostring()
	return 'TI:'..self._ti..' VSQ: '..self._vsq..' COT: '..self._cot..' CAOA: '..self._caoa
end

return unit
