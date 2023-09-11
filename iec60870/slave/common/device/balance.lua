local class = require 'middleclass'
local types = require 'iec60870.types'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_cot = require 'iec60870.asdu.cot'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_caoa = require 'iec60870.asdu.caoa'
local asdu_object = require 'iec60870.asdu.object'
local asdu_asdu = require 'iec60870.asdu.init'

local device = class('LUA_IEC60870_SLAVE_COMMON_DEVICE_BALANCE')

function device:initialize(device, addr)
	self._device = device
	self._addr = addr
	self:_reset_snapshot_list()
end

function device:_reset_snapshot_list()
	-- reset snapshot list
	self._data_snapshot = nil
	self._data_snapshot_cur = 0
end

function device:link_reset()
	self:_reset_snapshot_list()
end

function device:ADDR()
	return self._addr
end

function device:make_snapshot()
	if self._data_snapshot then
		return false, 'Snapshot already created!'
	end
	self._data_snapshot = self._device:get_snapshot()
	self._data_snapshot_cur = 0
	return true
end

-- TODO: should return asdu??
function device:poll_class1()
	if not self._data_snapshot then
		return false, nil -- what happen here???
	end

	if self._data_snapshot_cur == 0 then
		self._data_snapshot_cur = 1
		local asdu = {} -- FC=8 TI=100 COT=7 QOI=20
		local qoi = ti_map.create_data('qoi', qoi or 20)
		local cot = asdu_cot:new(types.COT_ACTIVATION) -- 6
		local caoa = asdu_caoa:new(self._addr)
		local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
		local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
		return true, asdu_asdu:new(false, unit, {obj})
	end

	if #self._data_snapshot >= self._data_snapshot_cur then
		local data_list = self._data_snapshot[self._data_snapshot_cur]
		self._data_snapshot_cur = self._data_snapshot_cur + 1
		return true, asdu
	end

	-- All snapshot list fired
	self:_reset_snapshot_list()
	-- For termination COT=10
	local asdu = {} -- FC=8 TI=100 COT=10 QOI=20
	local qoi = ti_map.create_data('qoi', qoi or 20)
	local cot = asdu_cot:new(types.COT_ACTIVATION_TERMINATION) -- 10
	local caoa = asdu_caoa:new(self._addr)
	local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
	local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
	return false, asdu_asdu:new(false, unit, {obj})
end

function device:poll_class2()
	local data_c2 = self._device:get_class2_data()
	if data_c2 then
		return has_sp, data_c2
	end

	return false, nil
end

function device:on_run()
	if self._device:has_spontaneous() then
		local data_sp = self._device:get_spontaneous()
		local cos = data_sp:COS()
		-- Fire cos first then SOE
		-- self:send(cos)
		local soe = data_sp:SOE()
		-- self:send(soe)
		-- Wait for confirmation
	end
end

return device
