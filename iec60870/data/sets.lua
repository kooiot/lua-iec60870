local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local d_set = require 'iec60870.data.set'
local helper = require 'iec60870.frame.helper'

local data = base:subclass('LUA_IEC60870_DATA_SET')

function data:initialize(sn, ti, sets)
	self._sn = sn
	self._ti = ti
	self._sets = sets
end

function data:SN()
	return self._sn & 0xFFFF
end

function data:TI()
	return self._ti & 0xFF
end

function data:SETS()
	return self._sets
end

function data:to_hex()
	local t = { string.pack('<I2I1', self._sn & 0xFFFF, self._ti & 0xFF) }
	for _, v in ipairs(self._sets) do
		t[#t + 1] = v:to_hex()
	end
	return table.concat(t)
end

function data:from_hex(raw, index)
	self._sn, self._ti, index = string.unpack('<I2I1', raw, index)
	while index <= string.len(raw) do
		local set = d_set:new()
		index = set:from_hex(raw, index)
		table.insert(self._sets, set)
	end
	return index
end

function data:__totable()
	local sets = {}
	for _, v in ipairs(self._sets) do
		sets[#sets + 1] = helper.totable(v)
	end
	return {
		name = 'SETS',
		sn = self._sn,
		ti = self._ti,
		sets = sets,
	}
end

return data
