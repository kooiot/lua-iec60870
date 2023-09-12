--- This is class for device data pool helper
--	e.g. make data snapshot, make spontenous data and so on
local class = require 'middleclass'
local t = require 'iec60870.types'
local util = require 'iec60870.common.util'
local helper = require 'iec60870.common.helper'
local object_gen = require 'iec60870.asdu.object_gen'

local data_pool = class('LUA_IEC60870_SLAVE_COMMON_DATA_POOL')

local MAX_SP_COUNT = 70
local MAX_ME_COUNT = 30
local MAX_IT_COUNT = 30
local SP_DEF_VAL = false
local ME_DEF_VAL = 0
local IT_DEF_VAL = 0

local type_maps = {
	--- SP
	SP = { t.M_SP_NA_1, t.M_SP_TA_1, MAX_SP_COUNT, SP_DEF_VAL },
	DP = { t.M_DP_NA_1, t.M_DP_TA_1, MAX_SP_COUNT, SP_DEF_VAL },
	--- ME
	ME_NA = { t.M_ME_NA_1, t.M_ME_TA_1, MAX_ME_COUNT, ME_DEF_VAL },
	ME_NB = { t.M_ME_NB_1, t.M_ME_TB_1, MAX_ME_COUNT, ME_DEF_VAL },
	ME_NC = { t.M_ME_NC_1, t.M_ME_TC_1, MAX_ME_COUNT, ME_DEF_VAL },
	ME = { t.M_ME_NC_1, t.M_ME_TC_1, MAX_ME_COUNT, ME_DEF_VAL },
	--- IT
	IT_NA = { t.M_IT_NA_1, t.M_IT_TA_1, MAX_IT_COUNT, IT_DEF_VAL },
	IT = { t.M_IT_NA_1, t.M_IT_TA_1, MAX_IT_COUNT, IT_DEF_VAL },
}

function data_pool:initialize(device, type_name, inputs, default_val, max_count)
	self._device = assert(device)
	self._type_name = type_name
	self._types = assert(type_maps[type_name])
	assert(inputs)
	self._inputs = {}
	self._max_count = max_count or self._types[3]
	self._spont_data = {}
	self._default_val = default_val ~= nil and default_val or self._types[4]

	for _, v in ipairs(inputs) do
		table.insert(self._inputs, {
			name = v.name,
			input = v,
			value = { 
				value = default_val, 
				timestamp = util.now(), 
				quality = 255
			}
		})
	end
end

function data_pool:IS_SP()
	return string.sub(self._type_name, 1, 2) == 'SP'
end

function data_pool:set_vals(vals)
	for _, v in ipairs(self._inputs) do
		v.value = vals[v.name] or v.value
	end
end

function data_pool:_convert_data(data_list, ti)
	assert(data_list)
	assert(ti)
	local ret = {}
	for _, v in ipairs(data_list) do
		local data, err = object_gen.generate(ti, v.input.addr, v.value.value, v.value.timestamp, v.value.quality)
		if data then
			-- print(helper.tostring(data))
			table.insert(ret, data)
		else
			-- TODO: log
		end
	end
	-- print(#ret)
	return ret
end

function data_pool:set_value(name, value, timestamp, quality)
	for _, v in ipairs(self._inputs) do
		if v.name == name then
			v.value = {
				value = value ~= nil and value or false,
				timestamp = timestamp or util.now(),
				quality = quality or 0
			}
			table.insert(self._spont_data, {
				input = v.input,
				value = v.value
			})
		end
	end
end

function data_pool:make_snapshot()
	self._spont_data = {} -- clear original spont data

	local snapshot = {}
	local list = {}
	for _, v in ipairs(self._inputs) do
		if #list >= self._max_count then
			table.insert(snapshot, self:_convert_data(list, self._types[1]))
			list = {}
		end
		table.insert(list, {
			input = v.input,
			value =  v.value
		})
	end
	if #list > 0 then
		table.insert(snapshot, self:_convert_data(list, self._types[1]))
	end
	return snapshot
end

function data_pool:has_spont_data()
	return #self._spont_data > 0
end

function data_pool:get_spont_data()
	if #self._spont_data == 0 then
		return {}
	end
	local ti = self._device:DATA_WITH_TM() and self._types[2] or self._types[1]
	if #self._spont_data <= self._max_count then
		local data = self._spont_data
		self._spont_data = {}
		return self:_convert_data(data, ti), ti
	end

	local data = table.move(self._spont_data, 1, self._max_count, 1, {})
	self._spont_data = table.move(self._spont_data, self._max_count + 1, #self._spont_data, 1, {})
	return self:_convert_data(data, ti), ti
end

return data_pool
