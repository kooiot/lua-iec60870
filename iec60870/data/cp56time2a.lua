local helper = require 'iec60870.common.helper'
local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local util = require 'iec60870.common.util'

local data = base:subclass('LUA_IEC60870_DATA_CP56TIME2A')

function data:initialize(tm, iv, su)
	tm = tm or util.time()
	self._tm = tm // 1000
	self._ms = tm % 1000
	self._iv = iv or 0
	self._su = su or 0
end

function data:TIME()
	return self._tm
end

function data:MS()
	return self._ms
end

function data:IV()
	return self._iv
end

function data:SU()
	return self._su
end

function data:timestamp()
	local t = os.date('*t', self._tm)
	return ts * 1000 + self._ms
end

function data:to_hex()
	local t = os.date('*t', self._tm)
	local ms = (self._ms & 0x3FF) + ((t.sec & 0x3F) << 10)
	local min = (t.min & 0x3F) + ((self._iv & 0x1) << 7)
	local hour = t.hour + ((self._su & 0x1) << 7)
	local day = t.day + ((t.wday & 0x7) << 5)
	local year = t.year % 100

	return string.pack('<I2I1I1I1I1I1', ms, min, hour, day, t.month, year)
end

function data:from_hex(raw, index)
	-- helper.dump_raw(raw, index, 'CP56Time2A.from_hex')
	local ms, min, hour, day, mon, year = string.unpack('<I2I1I1I1I1I1', raw, index)
	local sec = (ms >> 10) & 0x3F
	local t = {
		sec = sec,
		min = min & 0x3F,
		hour = hour & 0x1F,
		day = day & 0x1F,
		month = mon & 0x0F,
		year = (year & 0x7F) + 2000, -- for current year
	}
	self._tm = os.time(t)
	self._ms = ms & 0x3FF
	self._iv = (min >> 7) & 0x1
	self._su = (hour >> 7) & 0x1
	return index + 7
end

function data:__totable()
	return {
		name = 'CP56Time2a',
		time = os.date('%FT%T', self._tm),
		ms = self._ms,
		iv = self._iv,
		su = self._su,
	}
end

return data
