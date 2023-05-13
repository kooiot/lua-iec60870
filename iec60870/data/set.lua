local helper = require 'iec60870.common.helper'
local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local d_nof = require 'iec60870.data.nof'
local d_nos = require 'iec60870.data.nos'
local d_los = require 'iec60870.data.los'

local data = base:subclass('LUA_IEC60870_DATA_SET')

function data:initialize(tp, data)
	self._tp = tp or 0
	self._data = data or ''
end

function data:TYPE()
	return self._tp
end

function data:DATA()
	return self._data
end

function data:to_hex()
	local len = string.len(data)
	return string.char(self._tp & 0xFF)..string.char(len & 0xFF)..tostring(self._data)
end

function data:from_hex(raw, index)
	self._tp = assert(string.byte(raw, index))
	local len = assert(string.byte(raw, index + 1))
	self._data = string.sub(raw, index + 2, index + len + 1)
	assert(string.len(self._data) == len)
	return index + len + 2
end

function data:__totable()
	return {
		name = 'SET',
		['type'] = self._tp,
		data = tostring(self._data), -- TODO: to hex
	}
end

return data
