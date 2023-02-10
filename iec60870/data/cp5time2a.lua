-- M_SP_NA_1
local class = require 'middleclass'
local types = require 'iec60870.types'

local data = class('LUA_IEC60870_DATA_CP56TIME2A')

function data:initialize(tm, ms, iv, su)
	self._tm = tm or os.time()
	self._ms = ms or 0
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

function data:to_hex()
	local t = os.date('*t', self._tm)
	local ms = self._ms + t.sec * 1000	
	local min = t.min + ((self._iv & 0x1) << 7)
	local hour = t.hour + ((self._su & 0x1) << 7)
	local day = t.day + ((t.wday & 0x7) << 5)
	local year = t.year % 100

	return string.pack('<I2I1I1I1I1I1', ms, min, hour, day, t.month, year)
end

function data:from_hex(raw, index)
	local ms, min, hour, day, year = string.pack('<I2I1I1I1I1I1', raw, index)
	local t = {
		sec = ms // 1000,
		min = min & 0x7F,
		hour = hour & 0x7F,
		day = day & 0x1F,
		mon = mon & 0x0F,
		year = (year & 7F) + 2000, -- for current year
	}
	self._tm = os.time(t)
	self._ms = ms % 1000
	self.iv = (min >> 7) & 0x1
	self.su = (hour >> 7) & 0x1
	return index + 7
end

function data:__to_string()
	return table.concat({
		'TIME:', os.date('%FT%T', self._tm),
		'MS:', self._ms,
		'IV:', self._iv,
		'SU:', self._su,
	})
end

return data
