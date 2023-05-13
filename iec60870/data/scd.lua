local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local bsi = require 'iec60870.data.bsi'

local data = base:subclass('LUA_IEC60870_DATA_SCD')

function data:initialize(st, cd)
	self._st = bsi:new(st or 0)
	self._cd = bsi:new(cd or 0)
end

function data:ST()
	return self._st
end

function data:CD()
	return self._cd
end

function data:to_hex()
	return self._st:to_hex() .. self._cd:to_hex()
end

function data:from_hex(raw, index)
	index = self._st:from_hex(raw, index)
	index = self._cd:from_hex(raw, index)
	return index
end

function data:__totable()
	return {
		name = 'SCD',
		st = self._st:__totable(),
		cd = self._cd:__totable(),
	}
end

return data
