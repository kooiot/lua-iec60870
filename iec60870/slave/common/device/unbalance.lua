local class = require 'middleclass'
local types = require 'iec60870.types'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_cot = require 'iec60870.asdu.cot'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_caoa = require 'iec60870.asdu.caoa'
local asdu_object = require 'iec60870.asdu.object'
local asdu_asdu = require 'iec60870.asdu.init'

local device = class('LUA_IEC60870_SLAVE_COMMON_DEVICE_UNBALANCE')

function device:initialize(device, caoa_addr)
	self._device = device
	self._addr = caoa_addr
	self._first_class1 = true -- first class1 poll cannot be break by class2 data
	self._snapshot_done = false
	self:_reset_snapshot_list()
end

function device:_reset_snapshot_list()
	-- reset snapshot list
	self._data_snapshot = nil
	self._data_snapshot_cur = 0
end

function device:link_reset()
	self._snapshot_done = false
	self:_reset_snapshot_list()
end

function device:ADDR()
	return self._addr
end

function device:make_snapshot()
	if self._data_snapshot then
		return false, 'Snapshot already created!'
	end
	self._data_snapshot = self._device:_make_snapshot()
	-- local cjson = require 'cjson.safe'
	-- print(cjson.encode(self._data_snapshot))
	self._data_snapshot_cur = 0
	return true
end

-- TODO: should return asdu??
function device:poll_class1()
	-- print('poll_class1')
	if not self._data_snapshot then
		-- print('not data snapshot')
		if not self._first_class1 then
			return false, nil -- what happen here???
		end
		local data_sp = assert(self._device:has_spontaneous())
		return self._device:has_spontaneous(), data_sp
	end

	if not self._first_class1 and self._device:has_spontaneous() then
		-- print('has_spontaneous')
		return true, self._device:get_spontaneous()
	end

	-- print('slave.common.device.unbalance', self._data_snapshot_cur, #self._data_snapshot)

	if self._data_snapshot_cur == 0 then
		self._data_snapshot_cur = 1
		-- FC=8 TI=100 COT=7 QOI=20
		local cot = asdu_cot:new(types.COT_ACTIVATION_CON) -- 7
		local caoa = asdu_caoa:new(self._addr)
		local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
		local qoi = ti_map.create_data('qoi', qoi or 20)
		local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
		return true, asdu_asdu:new(false, unit, {obj})
	end

	if #self._data_snapshot >= self._data_snapshot_cur then
		local data_list = self._data_snapshot[self._data_snapshot_cur]
		-- print('slave.common.device.unbalance', self._data_snapshot_cur, #self._data_snapshot)
		self._data_snapshot_cur = self._data_snapshot_cur + 1

		--[[ moved to device.lua
		-- FC=8 COT=20 SQ=1
		local cot = asdu_cot:new(types.COT_INTERROGATED_BY_STATION) -- 20
		local caoa = asdu_caoa:new(self._addr)
		local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
		local resp = asdu_asdu:new(false, unit, data_list)
		return true, resp
		]]--
		-- print('slave.common.device.unbalance', data_list)
		return true, data_list
	end

	if self._first_class1 and self._device:has_spontaneous() then
		return true, self._device:get_spontaneous()
	end

	-- All snapshot list fired
	self:_reset_snapshot_list()
	-- For termination COT=10
	-- RESP: FC=8 TI=100 COT=10 QOI=20
	local qoi = ti_map.create_data('qoi', qoi or 20)
	local cot = asdu_cot:new(types.COT_ACTIVATION_TERMINATION) -- 10
	local caoa = asdu_caoa:new(self._addr)
	local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
	local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
	local resp = asdu_asdu:new(false, unit, {obj})

	--- If first_class1 is true then check whether has spontaneous data to keep class1 poll working ??? 
	if self._first_class1 and self._device:has_spontaneous() then
		return true, resp
	end

	--- Set first_class1 false
	self._first_class1 = false
	self._snapshot_done = true

	-- This is last class1 response
	return false, resp
end

function device:poll_class2()
	if not self._snapshot_done then
		return false, nil
	end

	local data_c2 = self._device:get_class2_data()
	local has_sp = self._device:has_spontaneous() 
	if data_c2 then
		-- print('unbalance.poll_class2 return class2 data')
		-- RESP: FC=8 TI=100 COT=10 QOI=20
		local qoi = ti_map.create_data('qoi', qoi or 20)
		local cot = asdu_cot:new(types.COT_ACTIVATION_TERMINATION) -- 10
		local caoa = asdu_caoa:new(self._addr)
		local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
		local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
		local resp = asdu_asdu:new(false, unit, {obj})

		return has_sp, data_c2
	end

	if has_sp then
		-- return wether has more sp data and current sp data
		-- print('unbalance.poll_class2 return spontaneous data')
		local sp_data = self._device:get_spontaneous()

		-- RESP: FC=8 TI=100 COT=10 QOI=20
		local cot = asdu_cot:new(types.COT_SPONTANEOUS) -- 3
		local caoa = asdu_caoa:new(self._addr)
		local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
		local resp = asdu_asdu:new(false, unit, {obj})

		return self._device:has_spontaneous(), sp_data
	end

	return false, nil
end

function device:on_run()
end

return device
