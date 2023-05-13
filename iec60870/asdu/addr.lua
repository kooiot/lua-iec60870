local helper = require 'iec60870.common.helper'
local base = require 'iec60870.frame.base'
local conf = require 'iec60870.conf'

local addr = base:subclass('LUA_IEC60870_ASDU_ADDR')

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
	return conf.OBJ_ADDR_SIZE	
end

function addr:to_hex()
	return string.pack('<I'..conf.OBJ_ADDR_SIZE, self._addr)
end

function addr:from_hex(raw, index)
	-- helper.dump_raw(raw, index, 'Addr.from_hex')
	self._addr, index = string.unpack('<I'..conf.OBJ_ADDR_SIZE, raw, index)
	return index
end

function addr:__totable()
	return {
		name = "ADDR",
		addr = self._addr
	}
end

return addr
