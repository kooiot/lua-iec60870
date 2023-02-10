-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local qoc = class('LUA_IEC60870_DATA_QOC')

function qoc:initialize(qu, se)
	self._qoc_val = ((qu & 0xF) << 3) + ((se & 0x1) << 7)
end

function qoc:QU()
	return (self._qoc_val >> 3) & 0xF
end

function qoc:SE()
	return (self._qoc_val >> 7) & 0x1
end

function qoc:value()
	return self._qoc_val
end

function qoc:set_value(val)
	self._qoc_val = val
end

function qoc:__to_string()
	return table.concat({
		'QU:', self:QU(),
		'S/E:', self:SE(),
	})
end

return qoc
