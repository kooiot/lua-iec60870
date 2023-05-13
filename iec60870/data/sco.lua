-- M_SP_NA_1
local qoc = require 'iec60870.data.qoc'
local types = require 'iec60870.types'

local data = qoc:subclass('LUA_IEC60870_DATA_SCO')

-- [[ <0> := OFF 	<1> := ON ]] --
function data:initialize(scs, qu, se)
	qoc.initialize(self, qu, se)
	local bs =  0
	self._val = ((scs and 1 or 0) & 0x1) + ((bs & 0x1) << 1)
end

function data:VAL()
	return (self._val & 0x1) ~= 0
end

function data:SCS()
	return self._val & 0x1
end

function data:BS()
	return (self._val >> 1) & 0x1
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
	t.name = 'SCO'
	t.scs = self:SCS()
	t.bs = self:BS()
	return t
end

return data
