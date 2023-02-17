-- FT1.2 可变帧格式

local base = require 'iec60870.frame.base'
local conf = require 'iec60870.conf'
local helper = require 'iec60870.frame.helper'
local frame_ctrl = require 'iec60870.frame.ctrl'
local frame_addr = require 'iec60870.frame.addr'
local asdu_parser = require 'ie60870.asdu.parser'

local frame = base:subclass('LUA_IEC60870_FRAME_FT12')

frame.static.FT_FIXED	= 0x10
frame.static.FT_FLEX	= 0x68
frame.static.FT_S_E5	= 0xE5
frame.static.FT_S_A2	= 0xA2
frame.static.FT_END		= 0x16

function frame:initialize(ft, ctrl, addr, asdu)
	self._ft = ft or frame.static.FT_FIXED
	self._ctrl = ctrl or frame_ctrl:new()
	self._addr = addr or frame_addr:new()
	self._asdu = asdu
end

function frame:FT()
	return self._ft
end

function frame:CTRL()
	return self._ctrl
end

function frame:ADDR()
	return self._addr
end

function frame:ASDU()
	return self._asdu
end

function frame:valid_fixed(raw, index)
	local dlen = self._ctrl:byte_size() + 1
	if not conf.FRAME_NO_ADDR then
		dlen = dlen + self._addr:byte_size()
	end
	local len = conf.FT12_FIXED_LEN
	if len > 0 then
		dlen = dlen + len
	end

	if string.len(raw) < index + dlen + 2 then
		return true, index
	end

	local c_data = string.sub(raw, index,  index + dlen)
	local c_cs = helper.sub(c_data)
	dlen = dlen + 1 -- cs

	local cs = string.sub(raw, index + dlen , index + dlen)
	if cs ~= c_cs then
		return false, 'Check sum error'
	end
	dlen = dlen + 1 -- c

	local tail = string.byte(raw, index + dlen)
	assert(tail == 0x16, 'End byte error')

	return true, dlen + 1
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

	if string.byte(raw, index + tlen + 1, index + tlen + 1) ~= frame.static.FT_END then
		return false, 'End char error'
	end

	return true, index + tlen + 1
end


function frame:valid_hex(raw, index)
	index = index or 1
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
		index = self._addr:from_hex(raw, index)
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
	local len = string.byte(raw, index + 1)
	local s_start = index
	index = self._ctrl:from_hex(raw, index + 4)
	if not conf.FRAME_NO_ADDR then
		index = self._addr:from_hex(raw, index)
	end

	local asdu, err = asdu_parser(string.sub(raw, index, s_start + len - 1))
	if asdu then
		self._asdu = asdu
	else
		--- TODO: log error
	end

	return s_start + len + 1
end

function frame:from_hex(raw, index)
	index = index or 1
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

function frame:encode_fixed(raw, index)
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

function frame:encode_flex()
	local asdu_raw = self._asdu:to_hex()
	local body = self._ctrl:to_hex()
	if not conf.FRAME_NO_ADDR then
		body = body..self._addr:to_hex()
	end
	body = body..asdu_raw
	local len = string.len(body)

	local cs = helper.sub(body)

	return string.pack('<I1I1I1I1', self._ft, len, len, self._ft)..body..cs..frame.static.FT_END
end

function frame:to_hex()
	assert(self._frame, 'Frame is nil!')
	if self._ft == frame.static.FT_FIXED then
		return self:encode_fixed()
	elseif self._ft == frame.static.FT_FLEX then
		return self:encode_flex()
	elseif self._ft == frame.static.FT_S_E5 then
		return string.char(self._ft)
	elseif self._ft == frame.static.FT_S_A2 then
		return string.char(self._ft)
	else
		assert(false, 'Invalid frame raw string')
	end
end

function frame:__totable()
	return {
		name = 'FT1.2 Frame',
		ft = self._ft,
		asdu = self._asdu:__totable()
	}
end
