-- FT1.2 可变帧格式

local base = require 'iec60870.frame.base'

local frame = base:subclass('LUA_IEC60870_FRAME_FT12')

frame.static.FT_FIXED	= 0x10
frame.static.FT_FLEX	= 0x68
frame.static.FT_S_E5	= 0xE5
frame.static.FT_S_A2	= 0xA2

function frame:initialize(ft, asdu)
	self._ft = ft or frame.static.FT_FIXED
	self._asdu = asdu
end

function frame:from_hex(raw, index)
	local head = string.byte(raw, index)
	assert(head == 0x68, 'Invalid frame raw string')
	local l = string.byte(

	return
end
