local class = require 'middleclass'
local conf = require 'ICE60870.frame.conf'

local caoa = class('LUA_IEC60870_FRAME_CAOA')

function caoa:initialize(addr)
	self._addr = addr
end

function caoa:ADDR()
	return self._addr
end

function caoa:to_hex()
	if conf.CAOA_SIZE == 1 then
		return string.char(self._addr & 0xFF)
	else
		return string.char(self._addr & 0xFF)..string.char((self._addr >> 8) & 0xFF)
	end
end

function caoa:from_hex(raw, index)
	if conf.CAOA_SIZE == 1 then
		self._addr = string.byte(raw, index)
		return index + 1
	else
		self._addr = string.byte(raw, index) + (string.byte(raw, index + 1) << 8)
		return index + 2
	end
end

function caoa:__tostring()
	return 'Addr:'..self._addr
end

return caoa
