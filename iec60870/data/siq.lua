-- M_SP_NA_1
local qv_base = require 'iec60870.data.qv_base'
local types = require 'iec60870.types'

local data = qv_base:subclass('LUA_IEC60870_DATA_SIQ')

function data:initialize(spi, bl, sb, nt, iv)
	qv_base.initialize(self, bl, sb, nt, iv)
	self._spi = spi & 0x1
end

function data:SPI()
	return self._spi & 0x1
end

function data:to_hex()
	local val = (self._spi & 0x1) + (qv_base.value(self) & 0xF0)
	return string.char(val)
end

function data:from_hex(raw, index)
	 local val = string.byte(raw, index)
	 self._spi = val & 0x1
	 qv_base.set_value(self, val & 0xF0)
	 return index + 1
end

function data:__to_string()
	return  'SPI:'.types.spi_str_table[self:SPI()]..qv_base.__to_string(self)
end

return data
