local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local f_addr = require 'iec60870.frame.addr'
local helper = require 'iec60870.frame.helper'

local data = base:subclass('LUA_IEC60870_DATA_RSN')

--- If addrs empty, read all
function data:initialize(sn, addrs)
	self._sn = sn
	self._addrs = addrs
end

function data:SN()
	return self._sn & 0xFFFF
end

function data:ADDRS()
	return self._addrs
end

function data:to_hex()
	local t = { string.pack('<I2', self._sn & 0xFFFF) }
	for _, v in ipairs(self._addrs) do
		t[#t + 1] = v:to_hex()
	end
	return table.concat(t)
end

function data:from_hex(raw, index)
	self._sn, index = string.unpack('<I2', raw, index)
	while index <= string.len(raw) do
		local addr = f_addr:new()
		index = addr:from_hex(raw, index)
		table.insert(self._addrs, addr)
	end
	return index
end

function data:__totable()
	local addrs = {}
	for _, v in ipairs(self._addrs) do
		addrs[#addrs + 1] = helper.totable(v)
	end
	return {
		name = 'RSN',
		sn = self._sn,
		addrs = self._addrs,
	}
end

return data
