local base = require 'iec60870.frame.base'

local nsf = base:subclass('LUA_IEC60870_FRAME_APCI_ITF')

function nsf:initialize(ri)
	self._ri = ri or 0
end

function nsf:TYPE()
	local apci = require 'iec60870.frame.apci'
	return apci.static.FRAME_N
end

function nsf:RI()
	return self._ri
end

function nsf:byte_size()
	return 4
end

function nsf:to_hex()
	local r = (self._ri << 1) & 0xFE
	return string.pack('<I2I2', 0x1, r)
end

function nsf:from_hex(raw, index)
	local s, r = string.unpack('<I2I2', raw, index)
	assert(s == 0x1, 'S Frame error')
	self._ri = r >> 1
	return index + 4
end

function nsf:__totable()
	return {
		name = 'NSF',
		ri = self:RI(),
	}
end

return nsf
