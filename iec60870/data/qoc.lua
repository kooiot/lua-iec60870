local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local qoc = base:subclass('LUA_IEC60870_DATA_QOC')

--[[
	QU:
	<0> := no additional definition
	<1> := short pulse duration (circuit-breaker),duration determined by a system parameter in the outstation
	<2> := long duration pulse,mduration determined by a system parametert in the outstation
	<3> := persistent output
	<4..8>	:= reserved for standard definitions of this companion standard (compatible range)
	<9..15>	:= reserved for the selection of other predefined functions
	<16..31> := reserved for special use (private range)			*/
	SE:
	<0> := Excute	<1> := Select
]]--
function qoc:initialize(qu, se)
	qu = qu or 0
	se = se or 0
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

function qoc:__totable()
	return {
		name = 'QOC',
		qu = self:QU(),
		se = self:SE(),
	}
end

return qoc
