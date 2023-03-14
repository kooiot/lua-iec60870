local base = require 'iec60870.frame.base'
local helper = require 'iec60870.frame.helper'
local ti_map = require 'iec60870.asdu.ti_map'
local conf = require 'iec60870.conf'
local asdu_addr = require 'iec60870.asdu.addr'

local object = base:subclass('LUA_IEC60870_ASDU_OBJECT')

function object:initialize(ti, addr, data)
	self._ti = assert(ti, 'TI is required!')
	self._addr = addr or asdu_addr:new()
	self._data = data or nil
end

function object:TI()
	return self._ti
end

function object:ADDR()
	return self._addr
end

function object:DATA()
	return self._data
end

function object:TIME()
	return ti_map.TM(self._ti, self._data)
end

function object:IV()
	return ti_map.IV(self._ti, self._data)
end

function object:to_hex(skip_addr)
	local t = {}
	if self._data and self._data.to_hex then
		t[1] = self._data:to_hex()
	else
		for _, v in ipairs(self._data or {}) do
			t[#t + 1] = v:to_hex()
		end
	end
	if skip_addr then
		return table.concat(t)
	end
	return self._addr:to_hex()..table.concat(t)
end

function object:from_hex(skip_addr, name_list, raw, index)
	if not addr then
		addr = asdu_addr:new()
		index = addr:from_hex(raw, index)
	end

	self._addr = assert(addr)
	self._data = nil

	if obj_name_list == '' then
		return index
	end
	if type(obj_name_list) == 'string' then
		self._data, index = ti_map.parse_obj(obj_name_list, raw, index)
		return index
	end
	if type(obj_name_list) == 'table' then
		self._data = {}
		local obj = nil
		for _, v in ipairs(obj_name_list) do
			obj, index = parse_obj(v, raw, index)
			table.insert(self._data, obj)
		end
		return index
	end
	assert(false, 'Not suppport object name list')
end

function object:__totable()
	local data = {}
	if type(self._data) == 'table' then
		for _, v in ipairs(self._data) do
			table.insert(data, helper.totable(v))
		end
	else
		data = helper.totable(self._data)
	end
	return {
		name = 'ASDU Object',
		addr = self._addr,
		data = data
	}
end

return object
