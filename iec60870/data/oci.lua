local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_OCI')

function data:initialize(gc, cl1, cl2, cl3)
	gc = gc or 0
	cl1 = cl1 or 0
	cl2 = cl2 or 0
	cl3 = cl3 or 0
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
	 self._val = assert(string.byte(raw, index))
	 return index + 1
end

function data:__totable()
	return {
		name = 'OCI',
		gc = self:GC(),
		cl1 = self:CL1(),
		cl2 = self:CL2(),
		cl3 = self:CL3(),
	}
end

return data
