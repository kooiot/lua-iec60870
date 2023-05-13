local base = require 'iec60870.frame.base'
local conf = require 'iec60870.conf'

local caoa = base:subclass('LUA_IEC60870_FRAME_CAOA')

function caoa:initialize(addr)
	self._addr = addr
end

function caoa:ADDR()
	return self._addr
end

function caoa:to_hex()
	if conf.ADDR_SIZE == 1 then
		return string.char(self._addr & 0xFF)
	else
		return string.char(self._addr & 0xFF)..string.char((self._addr >> 8) & 0xFF)
	end
end

function caoa:from_hex(raw, index)
	if conf.ADDR_SIZE == 1 then
		self._addr = string.byte(raw, index)
		return index + 1
	else
		-- local basexx = require 'basexx'
		-- print(index, string.len(raw), basexx.to_hex(raw))
		self._addr = string.byte(raw, index) + (string.byte(raw, index + 1) << 8)
		return index + 2
	end
end

function caoa:__totable()
	return {
		name = 'Common address of ASDU',
		addr = self._addr,
	}
end

return caoa
