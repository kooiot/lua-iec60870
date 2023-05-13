-- 643.5104 帧格式

local helper = require 'iec60870.common.helper'
local base = require 'iec60870.frame.base'
local conf = require 'iec60870.conf'
local frame_apci = require 'iec60870.frame.apci'
local frame_asdu = require 'iec60870.asdu.init'
local frame_ctrl = require 'iec60870.frame.ctrl'
local frame_addr = require 'iec60870.frame.addr'
local asdu_parser = require 'iec60870.asdu.parser'

local frame = base:subclass('LUA_IEC60870_FRAME_APDU')

frame.static.HEAD = 0x68
frame.static.MAX_LEN = 253

function frame:initialize(controlled, apci, asdu)
	self._controlled = controlled
	self._apci = apci or frame_apci:new()
	self._asdu = asdu
end

function frame:APCI()
	return self._apci
end

function frame:ASDU()
	return self._asdu
end

function frame:DUMP_KEY(linker)
	return linker:dump_key()
end

function frame:valid_hex(raw, index)
	index = index or 1
	local head = string.byte(raw, index)
	if head ~= frame.static.HEAD then
		return false, index + 1, 'Invalid frame'
	end

	local apdu_len = string.byte(raw, index + 1)
	if string.len(raw) < apdu_len + 2 then
		return false, index, 'Stream data not enough, need len:'..(apdu_len + 2)
	end

	return true, index + apdu_len + 2
end

function frame:from_hex(raw, index)
	self._asdu = nil
	index = index or 1
	assert(frame.static.HEAD == string.byte(raw, index))
	local len = string.byte(raw, index + 1)

	local s_start = index + 2
	index = self._apci:from_hex(raw, index + 2)

	local asdu_raw = string.sub(raw, index, s_start + len - 1)
	if string.len(asdu_raw) > 0 then
		-- helper.dump_raw(asdu_raw, 1, 'ASDU')
		self._asdu = assert(asdu_parser(not self._controlled, asdu_raw))
	end

	return s_start + len
end

function frame:to_hex()
	local apci_raw = self._apci:to_hex()
	local asdu_raw = self._asdu and self._asdu:to_hex() or ''
	-- helper.dump_raw(asdu_raw, 1, 'ASDU to_hex')
	local len = string.len(apci_raw) + string.len(asdu_raw)
	return string.pack('<I1I1', frame.static.HEAD, len)..apci_raw..asdu_raw
end

function frame:__totable()
	return {
		name = 'APDU Frame',
		apci = helper.totable(self._apci),
		asdu = helper.totable(self._asdu)
	}
end

return frame
