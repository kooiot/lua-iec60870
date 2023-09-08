--- This is class for device data helper
--	e.g. make data snapshot, make spontenous data and so on
local class = require 'middleclass'
local util = require 'iec60870.common.util'

local data = class('LUA_IEC60870_SLAVE_COMMON_DATA')

local MAX_YX_COUNT = 70
local MAX_YC_COUNT = 30
local MAX_IT_COUNT = 30

function data:initialize(sp_inputs, me_inputs, it_inputs)
	self._sp_inputs = self._sp_inputs or {}
	self._me_inputs = self._me_inputs or {}
	self._it_inputs = self._it_inputs or {}
	self._spont_data = nil
end

function data:set_data(sp_vals, me_vals, it_vals)
	for _, v in ipairs(self._sp_inputs) do
		v.value = sp_vals[v.name] or { value = false, timestamp = util.now(), quality = 255 }
	end
	for _, v in ipairs(self._me_inputs) do
		v.value = me_vals[v.name] or { value = 0, timestamp = util.now(), quality = 255 }
	end
	for _, v in ipairs(self._it_inputs) do
		v.value = it_vals[v.name] or { value = 0, timestamp = util.now(), quality = 255 }
	end
end

function data:_push_spont_data(name, value)
	if self._spont_data then
		-- TODO: remove same name spont data
		table.insert(self._spont_data, {
			name = name,
			value = v.value
		})
	end
end

function data:set_sp_value(name, value, timestamp, quality)
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

function data:set_me_value(name, value, timestamp, quality)
	for _, v in ipairs(self._me_inputs) do
		if v.name == name then
			v.value = {
				value = value ~= nil and value or 0,
				timestamp = timestamp or util.now(),
				quality = quality or 0
			}
			self:_push_spont_data(name, v.value)
		end
	end
end

function data:set_it_value(name, value, timestamp, quality)
	for _, v in ipairs(self._it_inputs) do
		if v.name == name then
			v.value = {
				value = value ~= nil and value or 0,
				timestamp = timestamp or util.now(),
				quality = quality or 0
			}
			self:_push_spont_data(name, v.value)
		end
	end
end

function data:make_snapshot()
	self._spont_data = {} -- clear original spont data

	local snapshot = {}
	local list = {}
	for _, v in ipairs(self._sp_inputs) do
		if #list >= MAX_YX_COUNT then
			table.insert(snapshot, self:_convert_sp_data(list))
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
		table.insert(snapshot, self:_convert_sp_data(list))
	end
	for _, v in ipairs(self._me_inputs) do
		if #list >= MAX_YC_COUNT then
			table.insert(snapshot, self:_convert_me_data(list))
			list = {}
		end
		table.insert(list, {
			name = v.name,
			value =  {
				value = v.value ~= nil and value or 0,
				timestamp = v.timestamp or util.now(),
				quality = v.quality or 255
			}
		})
	end
	if #list > 0 then
		table.insert(snapshot, self:_convert_me_data(list))
	end
	return snapshot
end

function data:has_pont_data()
	return (self._sp_spont and #self._sp_spont > 0) or (self._me_spont and #self._me_spont > 0)
end

function data:_convert_sp_data(data_list)
	local ret = {}
	for _, v in ipairs(data_list) do
		local val = v._value
		table.insert(ret, common_helper.make_sp_na(v.addr, val.value, val.timestamp))
	end
	return ret
end

function data:_convert_me_data(data_list)
	local me_data_list = {}
	for _, v in ipairs(data_list) do
		local val = v._value
		if v.ti == 'ME_NA' then
			table.insert(me_data_list, common_helper.make_me_na(v.addr, val.value, val.timestamp))
		elseif v.ti == 'ME_NB' then
			table.insert(me_data_list, common_helper.make_me_nb(v.addr, val.value, val.timestamp))
		elseif v.ti == 'ME_NC' or v.ti == 'ME' then
			table.insert(me_data_list, common_helper.make_me_nc(v.addr, val.value, val.timestamp))
		else
			self._log:error('Unknown ME found ', v.ti)
		end
	end
	return me_data_list
end

function data:_convert_it_data(data_list)
	local ret = {}
	for _, v in ipairs(data_list) do
		local val = v._value
		table.insert(ret, common_helper.make_it_na(v.addr, val.value, val.timestamp))
	end
	return ret
end

function data:get_spont_data()
	local data = {}
	if self._sp_spont and #self._sp_spont > 0 then
		local count = #self._sp_spont <= MAX_YX_COUNT and #self._sp_spont or MAX_YX_COUNT
		table.move(self._sp_spont, 1, count, 1, data)
		return self:_convert_sp_data(data)
	end
	if self._me_spont and #self._me_spont > 0 then
		local count = #self._sp_spont <= MAX_YX_COUNT and #self._sp_spont or MAX_YX_COUNT
		table.move(self._sp_spont, 1, count, 1, data)
		return self:_convert_me_data(data)
	end
	return {}
end

return data
