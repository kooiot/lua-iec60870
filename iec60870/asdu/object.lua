local helper = require 'iec60870.common.helper'
local base = require 'iec60870.frame.base'
local ti_map = require 'iec60870.asdu.ti_map'
local conf = require 'iec60870.conf'
local asdu_addr = require 'iec60870.asdu.addr'

local object = base:subclass('LUA_IEC60870_ASDU_OBJECT')

function object:initialize(ti, addr, data)
	self._ti = assert(ti, 'TI is required!')
	self._addr = addr or asdu_addr:new()

	if data and data.to_hex then
		self._data = { data }
	else
		self._data = data or {}
	end
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

function object:GET(index, func)
	local d = assert(self._data[index])
	return d[func](d)
end

function object:TIME()
	return ti_map.TM(self._ti, self._data)
end

function object:IV()
	return ti_map.IV(self._ti, self._data)
end

function object:to_hex(skip_addr)
	local t = {}
	for _, v in ipairs(self._data or {}) do
		t[#t + 1] = v:to_hex()
	end
	if skip_addr then
		return table.concat(t)
	end
	return self._addr:to_hex()..table.concat(t)
end

function object:from_hex(addr, name_list, raw, index)
	-- helper.dump_raw(raw, index, 'parse object')
	-- print(index)
	if not addr then
		addr = asdu_addr:new()
		index = addr:from_hex(raw, index)
	end
	-- print('ASDU.object.from_hex', addr)
	-- helper.dump_raw(raw, index, 'parse object 2')

	self._addr = assert(addr)
	self._data = nil

	if name_list == '' then
		self._data = {}
		return index
	end
	-- print(index)
	-- helper.dump_raw(raw, 1, 'parse object')
	if type(name_list) == 'string' then
		-- helper.dump_raw(raw, index, 'parse '..name_list)
		local data, index = ti_map.parse_obj(name_list, raw, index)
		self._data = { data }
		return index
	end
	if type(name_list) == 'table' then
		self._data = {}
		local obj = nil
		for _, v in ipairs(name_list) do
			-- helper.dump_raw(raw, index, 'parse '..v)
			obj, index = ti_map.parse_obj(v, raw, index)
			table.insert(self._data, obj)
		end
		return index
	end
	assert(false, 'Not suppport object name list:'..name_list)
end

function object:__totable()
	local data_t = {}
	for _, v in ipairs(self._data) do
		table.insert(data_t, helper.totable(v))
	end

	return {
		name = 'ASDU Object',
		addr = helper.totable(self._addr),
		data = data_t,
	}
end

return object
