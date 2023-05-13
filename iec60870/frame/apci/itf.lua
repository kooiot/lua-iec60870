local base = require 'iec60870.frame.base'

local itf = base:subclass('LUA_IEC60870_FRAME_APCI_ITF')

function itf:initialize(si, ri)
	self._si = si
	self._ri = ri
end

function itf:TYPE()
	local apci = require 'iec60870.frame.apci'
	return apci.static.FRAME_I
end

function itf:SI()
	return self._si
end

function itf:RI()
	return self._ri
end

function itf:byte_size()
	return 4
end

function itf:to_hex()
	local s = (self._si << 1) & 0xFE
	local r = (self._ri << 1) & 0xFE
	return string.pack('<I2I2', s, r)
end

function itf:from_hex(raw, index)
	local s, r = string.unpack('<I2I2', raw, index)
	self._si = s >> 1
	self._ri = r >> 1
	return index + 4
end

function itf:__totable()
	return {
		name = 'ITF',
		si = self:SI(),
		ri = self:RI(),
	}
end

return itf
