-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.types'

local data = class('LUA_IEC60870_DATA_OCI')

function data:initialize(gc, cl1, cl2, cl3)
	self._val = (gc & 0x1) + ((cl1 & 0x1) << 1) + ((cl2 & 0x1) << 2) + ((cl3 & 0x1) << 3)
end

function data:GC()
	return self._val & 0x1
end

function data:CL1()
	return (self._val >> 1) & 0x1
end

function data:CL2()
	return (self._val >> 2) & 0x1
end

function data:CL3()
	return (self._val >> 3) & 0x1
end

function data:to_hex()
	return string.char(self._val)
end

function data:from_hex(raw, index)
	 self._val = string.byte(raw, index)
	 return index + 1
end

function data:__to_string()
	return table.concat({
		'GC:', self:GC(),
		'CL1:', self:CL1(),
		'CL2:', self:CL2(),
		'CL3:', self:CL3(),
	})
end

return data
