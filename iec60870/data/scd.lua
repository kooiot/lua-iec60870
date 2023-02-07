-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'
local bsi = require 'iec60870.data.bsi'

local data = class('LUA_ICE60870_DATA_SCD')

function data:initialize(st, cd)
	self._st = bsi:new(st)
	self._cd = bsi:new(cd)
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

function data:__to_string()
	return table.concat({
		'ST:', tostring(self._st),
		'CD:', tostring(self._cd),
	})
end

return data
