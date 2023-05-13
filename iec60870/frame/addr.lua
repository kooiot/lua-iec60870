local base = require 'iec60870.frame.base'
local conf = require 'iec60870.conf'

local addr = base:subclass('LUA_IEC60870_FRAME_ADDR')

function addr:initialize(addr)
	self._addr = assert(addr or 0)
end

function addr:ADDR()
	return self._addr
end

function addr:__eq(o)
	return self:ADDR() == o:ADDR()
end

function addr:byte_size()
	return conf.FRAME_ADDR_SIZE	
end

function addr:to_hex()
	if conf.FRAME_ADDR_SIZE == 1 then
		return string.char(self._addr & 0xFF)
	elseif conf.FRAME_ADDR_SIZE == 2 then
		return string.char(self._addr & 0xFF)..string.char((self._addr >> 8) & 0xFF)
	elseif conf.FRAME_ADDR_SIZE == 3 then
		return string.char(self._addr & 0xFF)..string.char((self._addr >> 8) & 0xFF)..string.char((self._addr >> 16) & 0xFF)
	else
		assert(false, 'Address size error!')
	end
end

function addr:from_hex(raw, index)
	if conf.FRAME_ADDR_SIZE == 1 then
		self._addr = string.byte(raw, index)
	elseif conf.FRAME_ADDR_SIZE == 2 then
		self._addr = string.byte(raw, index) + (string.byte(raw, index + 1) << 8)
	elseif conf.FRAME_ADDR_SIZE == 3 then
		self._addr = string.byte(raw, index) + (string.byte(raw, index + 1) << 8) + (string.byte(raw, index + 2) << 16)
	else
		assert(false, 'Address size error!')
	end
	return index + conf.FRAME_ADDR_SIZE
end

function addr:__totable()
	return {
		name = "ADDR",
		addr = self._addr
	}
end

return addr
