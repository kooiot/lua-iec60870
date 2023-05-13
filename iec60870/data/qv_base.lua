local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local qv_base = base:subclass('LUA_IEC60870_DATA_QV_BASE')

function qv_base:initialize(bl, sb, nt, iv)
	bl = bl or 0
	sb = sb or 0
	nt = nt or 0
	iv = iv or 0
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

function qv_base:set_value(val)
	self._qv_val = val
end

function qv_base:__totable()
	return {
		bl = self:BL(),
		sb = self:SB(),
		nt = self:NT(),
		iv = types.valid_table[self:IV()],
	}
end

return qv_base
