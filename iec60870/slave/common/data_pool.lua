--- This is class for device data pool helper
--	e.g. make data snapshot, make spontenous data and so on
local class = require 'middleclass'
local util = require 'iec60870.common.util'

local data_pool = class('LUA_IEC60870_SLAVE_COMMON_DATA_POOL')

function data_pool:initialize(inputs, max_count, converter)
	self._inputs = inputs or {}
	self._max_count = assert(max_count)
	self._spont_data = {}
	self._converter = converter
end

function data_pool:set_vals(vals, default_val)
	for _, v in ipairs(self._inputs) do
		v.value = vals[v.name] or (v.value or { value = default_val, timestamp = util.now(), quality = 255 })
	end
end

function data_pool:_convert_data(data_list)
	local ret = {}
	for _, v in ipairs(data_list) do
		local val = v._value
		table.insert(ret, self._converter(v.addr, val.value, val.timestamp, v))
	end
	return ret
end

function data_pool:_push_spont_data(name, value)
	table.insert(self._spont_data, {
		name = name,
		value = v.value
	})
end

function data_pool:set_value(name, value, timestamp, quality)
	for _, v in ipairs(self._sp_inputs) do
		if v.name == name then
			v.value = {
				value = value ~= nil and value or false,
				timestamp = timestamp or util.now(),
				quality = quality or 0
			}
			self:_push_spont_data(name, v.value)
		end
	end
end

function data_pool:make_snapshot()
	self._spont_data = {} -- clear original spont data

	local snapshot = {}
	local list = {}
	for _, v in ipairs(self._sp_inputs) do
		if #list >= MAX_YX_COUNT then
			table.insert(snapshot, self:_convert_data(list))
			list = {}
		end
		table.insert(list, {
			name = v.name,
			value =  {
				value = v.value ~= nil and value or false,
				timestamp = v.timestamp or util.now(),
				quality = v.quality or 255
			}
		})
	end
	if #list > 0 then
		table.insert(snapshot, self:_convert_data(list))
	end
	return snapshot
end

function data_pool:has_pont_data()
	return #self._spont_data > 0
end

function data_pool:get_spont_data()
	if #self._spont_data == 0 then
		return {}
	end
	if #self._spont_data <= self._max_count then
		local data = self._spont_data
		self._spont_data = {}
		return self:_convert_data(data)
	end

	local data = table.move(self._spont_data, 1, self._max_count, 1, {})
	self._spont_data = table.move(self._spont_data, self._max_count + 1, #self._spont_data, 1, {})
	return self:_convert_data(data)
end

return data
