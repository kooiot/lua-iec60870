local base = require 'iec60870.frame.base'

local vsq = base:subclass('LUA_IEC60870_FRAME_VSQ')

vsq.static.SQ_OBJ_CONTINUE = 1
vsq.static.SQ_OBJ_SLOT = 0

function vsq:initialize(count, sq)
	self._count = assert(count or 0) & 0x7F
	self._sq = assert((sq or 0) & 0x1)
end

function vsq:COUNT()
	return self._count
end

function vsq:SQ()
	return self._sq & 0x01
end

function vsq:to_hex()
	return string.char(((self._sq & 0x1) << 7) + (self._count & 0x7F))
end

function vsq:from_hex(raw, index)
	local c = string.byte(raw, index)
	self._count = c & 0x7F
	self._sq = (c >> 7) & 0x1
	return index + 1
end

function vsq:__totable()
	return {
		name = 'Variable structure qualifier',
		count = self._count,
		sq = self._sq,
	}
end

return vsq
