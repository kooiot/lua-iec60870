local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'
local d_nof = require 'iec60870.data.nof'
local d_nos = require 'iec60870.data.nos'
local d_los = require 'iec60870.data.los'
local helper = require 'iec60870.frame.helper'

local data = base:subclass('LUA_IEC60870_DATA_FILE')

function data:initialize(nof, nos, content)
	self._nof = nof or d_nof:new()
	self._nos = nos or d_nos:new()
	self._content = content or ''
end

function data:NOF()
	return self._nof
end

function data:NOS()
	return self._nos
end

function data:CONTENT()
	return self._content
end

function data:to_hex()
	local l = d_los:new(string.len(self._content))
	return self._nof:to_hex()..self._nos:to_hex()..l:to_hex()..self._content
end

function data:from_hex(raw, index)
	local l = d_los:new()
	index = self._nof:from_hex(raw, index)
	index = self._nos:from_hex(raw, index)
	index = l:from_hex(raw, index)
	self._content = string.sub(raw, index, index + l:VAL() - 1)
	return index + l:VAL()
end

function data:__totable()
	return {
		name = 'FILE Part',
		nof = helper.totable(self._nof),
		nos = helper.totable(self._nos),
		content = self._content
	}
end

return data
