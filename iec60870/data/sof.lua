local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_SOF')

function data:initialize(status, lfd, FOR, fa)
	status = status or 0
	lfd = lfd or 0
	FOR = FOR or 0
	fa = fa or 0
	self._val = status & 0x1F + ((lfd & 0x1) << 5) + ((FOR & 0x1) << 6) + ((fa & 0x1) << 7) 
end

function data:STATUS()
	return self._val & 0x1F
end

function data:LFD()
	return (self._val >> 5) & 0x1
end

function data:FOR()
	return (self._val >> 6) & 0x1
end

function data:FA()
	return (self._val >> 7) & 0x1
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
		name = 'SOF',
		status = self:STATUS(),
		lfd = self:LFD(),
		['for'] = self:FOR(),
		fa = self:FA(),
	}
end

return data
