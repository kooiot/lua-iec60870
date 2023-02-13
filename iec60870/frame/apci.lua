
local base = require 'iec60870.frame.base'
local helper = require 'iec60870.frame.helper'
local itf = require 'iec60870.frame.acpi.itf'
local nsf = require 'iec60870.frame.acpi.nsf'
local ucf = require 'iec60870.frame.acpi.ucf'

local apci = base:subclass('LUA_IEC60870_FRAME_CTRL')

apci.static.HEAD = 0x68
apci.static.FRAME_I = 0
apci.static.FRAME_S = 1
apci.static.FRAME_U = 2

function apci:initialize(frame, apdu_len)
	self._frame = frame
	self._apdu_len = apdu_len or 0
end

function apci:TYPE()
	return self._frame:TYPE()
end

function apci:APDU_LEN()
	return self._apdu_len
end

function apci:FRAME()
	return self._frame
end

function apci:to_hex()
	return string.char(apci.static.HEAD)..string.char(self._apdu_len)..self._frame:to_hex()
end

function apci:from_hex(raw, index)
	assert(string.byte(raw, index) == apci.static.HEAD)
	self._apdu_len = string.byte(raw, index + 1)

	local v1 = string.byte(raw, index + 2)
	local v3 = string.byte(raw, index + 4)
	if (v1 & 0x1) == 0 and (v3 & 0x1) == 0 then
		self._frame = itf:new()
		self._frame:from_hex(raw, index + 2)
	elseif (v1 & 0x3) == 0x1 and (v3 & 0x1) == 0 then
		self._frame = nsf:new()
		self._frame:from_hex(raw, index + 2)
	elseif (v1 & 0x3) == 0x3 and (v3 & 0x1) == 0 then
		self._frame = nsf:new()
		self._frame:from_hex(raw, index + 2)
	else
		self._frame = nil
	end
	return index + 6
end

function apci:__totable()
	return {
		name = 'APCI',
		apdu_len = self._apdu_len,
		frame = helper.totable(self._frame)
	}
end

return apci
