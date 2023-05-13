local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_CP24TIME2A')

function data:initialize(iv, min, sec, ms)
	self._iv = iv or 0
	self._min = min or 0
	self._sec = sec or 0
	self._ms = ms or 0
end

function data:IV()
	return self._iv
end

function data:MIN()
	return self._min
end

function data:SEC()
	return self._sec
end

function data:MS()
	return self._ms
end

function data:timestamp()
	local now = os.time()
	local t = os.date('*t', now)
	if t.min < self._min then
		-- an hour ago
		t = os.date('*t', now - 3600 + 1)
	end

	t.min = self._min
	t.sec = self._sec
	local ts = os.time(t)
	return ts * 1000 + self._ms
end

function data:to_hex()
	local ms = (self._ms & 0x3FF) + ((self._sec & 0x3F) << 10)
	local min = ((self._iv & 0x1) << 7) + (self._min & 0x3F)
	return string.pack('<I2I1', ms, min)
end

function data:from_hex(raw, index)
	local ms, min = string.unpack('<I2I1', raw, index)
	self._ms = ms & 0x3FF
	self._min = (ms >> 10) & 0x3F
	self._sec = min & 0x3F
	self._iv = (min >> 7) & 0x1
	return index + 7
end

function data:__totable()
	return {
		name = 'CP24Time2a',
		iv = self._iv,
		min = self._min,
		sec = self._sec,
		ms = self._ms,
	}
end

return data
