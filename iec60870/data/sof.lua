-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.types'

local data = class('LUA_IEC60870_DATA_SOF')

function data:initialize(status, lfd, FOR, fa)
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
	 self._val = string.byte(raw, index)
	 return index + 1
end

function data:__to_string()
	return table.concat({
		'STS:', self:STATUS(),
		'LFD:', self:LFD(),
		'FOR:', self:FOR(),
		'FA:', self:FA(),
	})
end

return data
