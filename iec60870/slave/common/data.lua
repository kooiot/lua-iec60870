--- This is class for device data helper
--	e.g. make data snapshot, make spontenous data and so on
local class = require 'middleclass'
local util = require 'iec60870.common.util'

local data = class('LUA_IEC60870_SLAVE_COMMON_DATA')

local MAX_YX_COUNT = 70
local MAX_YC_COUNT = 30

function data:initialize(yx_inputs, yc_inputs)
	self._yx_inputs = self._yx_inputs or {}
	self._yc_inputs = self._yc_inputs or {}
	self._spont_data = nil
end

function data:set_data(yx_vals, yc_vals)
	for _, v in ipairs(self._yx_inputs) do
		v.value = yx_vals[v.name] or { value = false, timestamp = util.now(), quality = 255 }
	end
	for _, v in ipairs(self._yc_inputs) do
		v.value = yc_vals[v.name] or { value = 0, timestamp = util.now(), quality = 255 }
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

function data:set_yx_value(name, value, timestamp, quality)
	for _, v in ipairs(self._yx_inputs) do
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

function data:set_yc_value(name, value, timestamp, quality)
	for _, v in ipairs(self._yc_inputs) do
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
	for _, v in ipairs(self._yx_inputs) do
		if #list >= MAX_YX_COUNT then
			table.insert(snapshot, self:_convert_yx_data(list))
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
		table.insert(snapshot, self:_convert_yx_data(list))
	end
	for _, v in ipairs(self._yc_inputs) do
		if #list >= MAX_YC_COUNT then
			table.insert(snapshot, self:_convert_yc_data(list))
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
		table.insert(snapshot, self:_convert_yc_data(list))
	end
	return snapshot
end

function data:has_pont_data()
	return (self._yx_spont and #self._yx_spont > 0) or (self._yc_spont and #self._yc_spont > 0)
end

function data:_convert_yx_data(data_list)
	return {}
end

function data:_convert_yc_data(data_list)
	return {}
end

function data:get_spont_data()
	local data = {}
	if self._yx_spont and #self._yx_spont > 0 then
		local count = #self._yx_spont <= MAX_YX_COUNT and #self._yx_spont or MAX_YX_COUNT
		table.move(self._yx_spont, 1, count, 1, data)
		return self:_convert_yx_data(data)
	end
	if self._yc_spont and #self._yc_spont > 0 then
		local count = #self._yx_spont <= MAX_YX_COUNT and #self._yx_spont or MAX_YX_COUNT
		table.move(self._yx_spont, 1, count, 1, data)
		return self:_convert_yc_data(data)
	end
	return {}
end

return data
