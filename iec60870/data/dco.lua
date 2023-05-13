local qoc = require 'iec60870.frame.qoc'
local types = require 'iec60870.types'

local data = qoc:subclass('LUA_IEC60870_DATA_DCO')

--[[
	/* Double command state 
	<0> := not permitted 
	<1> := OFF 
	<2> := ON 
	<3> := not permitted */
]]--
function data:initialize(dcs, qu, se)
	qoc.initialize(self, qu, se)
	self._val = (dcs and 2 or 1) & 0x3
end

function data:VAL()
	return (self._val & 0x3) == 2
end

function data:DCS()
	return self._val & 0x3
end

function data:to_hex()
	local val = self._val + (qoc.value(self) & 0xF8)
	return string.char(self._val)
end

function data:from_hex(raw, index)
	 local val = assert(string.byte(raw, index))
	 self._val = val & 0x3
	 qoc.set_value(self, val & 0xF8)
	 return index + 1
end

function data:__totable()
	local t = qoc.__totable(self)
	t.name = 'DCO'
	t.dcs = self:DCS()
	return t
end

return data
