-- FT1.2 可变帧格式

local base = require 'iec60870.frame.base'
local conf = require 'iec60870.conf'
local helper = require 'iec60870.frame.helper'
local frame_ctrl = require 'iec60870.frame.ctrl'
local frame_addr = require 'iec60870.frame.addr'
local asdu_parser = require 'ie60870.asdu.parser'

local frame = base:subclass('LUA_IEC60870_FRAME_APDU')

local APDU_HEAD = 0x68
local APDU_MAX_LEN = 253

function frame:initialize(apci, asdu)
	self._apci = apci
	self._asdu = asdu
end

function frame:APCI()
	return self._apci
end

function frame:ASDU()
	return self._asdu
end

function frame:valid_flex(raw, index)
	local len = string.byte(raw, index + 1, index + 1)
	local r_len = string.byte(raw, index + 2, index + 2)
	if len ~= r_len then
		return false, 'Head Len error'
	end
	local tlen = 4 + len + 1 + 1
	if string.len(raw) < index + tlen then
		return true, index
	end

	if string.byte(raw, index + 4, index + 4) ~= frame.static.FT_FLEX then
		return false, 'Head end error'
	end
	local c_data = string.sub(raw, index + 5, index + 5 + len - 1)
	local c_cs = helper.sub(c_data)
	if cs_cs ~= string.sub(raw, index + 5 + len, index + 5 + len) then
		return false, 'Check sum error'
	end

	return true, index + tlen + 1
end


function frame:valid_hex(raw, index)
	local head = string.byte(raw, index)
	self._ft = head -- just copy to _ft
	if head == frame.static.FT_FIXED then
		return self:valid_fixed(raw, index)
	elseif head == frame.static.FT_FLEX then
		return self:valid_flex(raw, index)
	elseif head == frame.static.FT_S_E5 then
		return true, index + 1
	elseif head == frame.static.FT_S_A2 then
		return true, index + 1
	else
		return false, index + 1
	end
end

function frame:decode_fixed(raw, index)
	self._asdu = nil
	local c_start = index
	index = self._ctrl:from_hex(raw, index + 1)
	if not conf.FRAME_NO_ADDR then
		index = self._addr:from_hext(raw, index)
	end
	local len = conf.FT12_FIXED_LEN
	if len > 0 then
		local asdu, err = asdu_parser(string.sub(raw, index, index + len - 1))
		if asdu then
			self._asdu = asdu
		else
			self._asdu = nil
			--- TODO: log error
		end
	else
		len = 0
	end
	index = index + len

	return index + 2
end

function frame:decode_flex(raw, index)
	self._asdu = nil
	local len = string.byte(raw, index + 1, index + 1)
	local tlen = 4 + len + 1 + 1

	local asdu, err = asdu_parser(string.sub(raw, index + 5, index + 5 + len - 1))
	if asdu then
		self._asdu = asdu
	else
		--- TODO: log error
	end

	return true, index + tlen + 1
end

function frame:from_hex(raw, index)
	local head = string.byte(raw, index)
	self._ft = head -- just copy to _ft
	if head == frame.static.FT_FIXED then
		index = self:decode_fixed(raw, index)
	elseif head == frame.static.FT_FLEX then
		index = self:decode_flex(raw, index)
	elseif head == frame.static.FT_S_E5 then
		index = index + 1
	elseif head == frame.static.FT_S_A2 then
		index = index + 1
	else
		assert(false, 'Invalid frame raw string')
	end
	return index
end

function frame:__totable()
	return {
		name = 'APDU Frame',
		apci = self._apci:__totable(),
	}
end
