local class = require 'middleclass'
local conf = require 'iec60870.frame.conf'

local addr = class('LUA_ICE60870_FRAME_ADDR')

function addr:initialize(addr)
	self._addr = assert(addr or 0)
end

function addr:ADDR()
	return self._addr
end

function addr:to_hex()
	if conf.ADDR_SIZE == 1 then
		return string.char(self._addr & 0xFF)
	elseif conf.ADDR_SIZE == 2 then
		return string.char(self._addr & 0xFF)..string.char((self._addr >> 8) & 0xFF)
	elseif conf.ADDR_SIZE == 3 then
		return string.char(self._addr & 0xFF)..string.char((self._addr >> 8) & 0xFF)..string.char((self._addr >> 16) & 0xFF)
	else
		assert(false, 'Address size error!')
	end
end

function addr:from_hex(raw, index)
	if conf.ADDR_SIZE == 1 then
		self._addr = string.byte(raw, index)
	elseif conf.ADDR_SIZE == 2 then
		self._addr = string.byte(raw, index) + (string.byte(raw, index + 1) << 8)
	elseif conf.ADDR_SIZE == 3 then
		self._addr = string.byte(raw, index) + (string.byte(raw, index + 1) << 8) + (string.byte(raw, index + 2) << 16)
	else
		assert(false, 'Address size error!')
	end
	return index + conf.ADDR_SIZE
end

function addr:__tostring()
	return 'Addr:'..self._addr
end

return addr
