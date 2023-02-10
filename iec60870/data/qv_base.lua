-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.frame.types'

local qv_base = class('LUA_IEC60870_DATA_QV_BASE')

function qv_base:initialize(bl, sb, nt, iv)
	self._qv_val = ((bl & 0x1) << 4) + ((sb & 0x1) << 5) + ((nt & 0x1) << 6) + ((iv & 0x1) << 7)
end

function qv_base:BL()
	return (self._qv_val >> 4) & 0x1
end

function qv_base:SB()
	return (self._qv_val >> 5) & 0x1
end

function qv_base:NT()
	return (self._qv_val >> 6) & 0x1
end

function qv_base:IV()
	return (self._qv_val >> 7) & 0x1
end

function qv_base:value()
	return self._qv_val
end

function qv_base:set_qv_value(val)
	self._qv_val = val
end

function qv_base:__to_string()
	return table.concat({
		'BL:', self:BL(),
		'SB:', self:SB(),
		'NT:', self.NT(),
		'IV:', types.valid_table[self:IV()],
	})
end

return qv_base
