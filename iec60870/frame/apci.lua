
local base = require 'iec60870.frame.base'
local helper = require 'iec60870.frame.helper'
local itf = require 'iec60870.frame.apci.itf'
local nsf = require 'iec60870.frame.apci.nsf'
local ucf = require 'iec60870.frame.apci.ucf'

local apci = base:subclass('LUA_IEC60870_FRAME_APCI')

apci.static.FRAME_I = 0
apci.static.FRAME_S = 1
apci.static.FRAME_U = 2

function apci.static:new_i(...)
	local self = self:allocate()
	self._frame = itf:new(...)
	return self
end

function apci.static:new_s(...)
	local self = self:allocate()
	self._frame = nsf:new(...)
	return self
end

function apci.static:new_u(...)
	local self = self:allocate()
	self._frame = ucf:new(...)
	return self
end

function apci:initialize(frame)
	self._frame = frame
end

function apci:TYPE()
	return self._frame:TYPE()
end

function apci:FRAME()
	return self._frame
end

function apci:to_hex()
	return self._frame:to_hex()
end

function apci:from_hex(raw, index)
	local v1 = string.byte(raw, index)
	local v3 = string.byte(raw, index + 2)
	if (v1 & 0x1) == 0 and (v3 & 0x1) == 0 then
		self._frame = itf:new()
		self._frame:from_hex(raw, index)
	elseif (v1 & 0x3) == 0x1 and (v3 & 0x1) == 0 then
		self._frame = nsf:new()
		self._frame:from_hex(raw, index)
	elseif (v1 & 0x3) == 0x3 and (v3 & 0x1) == 0 then
		self._frame = ucf:new()
		self._frame:from_hex(raw, index)
	else
		self._frame = nil
	end
	return index + 4
end

function apci:__totable()
	return {
		name = 'APCI',
		frame = helper.totable(self._frame)
	}
end

return apci
