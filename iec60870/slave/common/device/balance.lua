local class = require 'middleclass'
local types = require 'iec60870.types'
local util = require 'iec60870.common.util'
local logger = require 'iec60870.common.logger'
local f_ctrl = require 'iec60870.frame.ctrl'
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
	util.timeout(200, function()
		--- self:_balance_start()
	end)
end

function device:ADDR()
	return self._addr
end

function device:_balance_start()
	local r, err = self:req_link_status()
	if not r then
		logger.error('device '..self._addr..' request link status failed', err)
		return nil, err
	end
	return self:req_link_reset()
end

function device:make_frame(...)
	return self._device:master():make_frame(...)
end

function device:request(...)
	return self._device:master():channel():request(...)
end

function device:req_link_status()
	logger.info('device '..self._addr..' request link status...')
	local frame = self:make_frame(f_ctrl.static.FC_LINK, nil, nil, nil, true)
	local resp, err = self:request(frame)
	if not resp then
		return nil, err
	end

	local ctrl = resp:CTRL()
	if ctrl:FC() ~= f_ctrl.static.FC_LINK_RESP then
		return nil, "Invalid response fc:"..ctrl:FC()
	end
	return true
end

function device:req_link_reset()
	logger.info('device '..self._addr..' request link reset...')
	self._fcb = 1
	self._last_poll = 0 -- for poll data
	self._last_poll =  util.now() - self._poll_cycle
	local frame = self:make_frame(f_ctrl.static.FC_RST_LINK, nil, nil, nil, true)
	local resp, err = self:request(frame)
	if not resp then
		return nil, err
	end

	local ctrl = resp:CTRL()
	if ctrl:FC() ~= f_ctrl.static.FC_S_OK then
		return nil, "Invalid response fc:"..ctrl:FC()
	end
	return true
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
		return false
	end

	if self._data_snapshot_cur == 0 then
		self._data_snapshot_cur = 1
		-- TI=100 COT=7 QOI=20
		local cot = asdu_cot:new(types.COT_ACTIVATION_CON) -- 7
		local caoa = asdu_caoa:new(self._addr)
		local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
		local qoi = ti_map.create_data('qoi', qoi or 20)
		local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
		return true, asdu_asdu:new(false, unit, {obj})
	end

	if #self._data_snapshot >= self._data_snapshot_cur then
		local data_list = self._data_snapshot[self._data_snapshot_cur]
		-- print('device.common.device.unbalance', self._data_snapshot_cur, #self._data_snapshot)
		self._data_snapshot_cur = self._data_snapshot_cur + 1
		return true, asdu
	end

	-- All snapshot list fired
	self:_reset_snapshot_list()
	-- For termination COT=10
	local asdu = {} -- TI=100 COT=10 QOI=20
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
		-- print('poll_class2', data_c2)
		return true, data_c2
	end

	return false, nil
end

function device:on_run()
	local has_c1, data_c1 = self:poll_class1()
	if data_c1 then
		print('send class1 data')
		local req = self:make_frame(f_ctrl.static.FC_DATA, nil, data_c1, nil, true)
		local resp = self:request(req)
		print('class1.resp', resp)
	end

	if self._device:has_spontaneous() then
		local data_sp = self._device:get_spontaneous()
		print('on_run11', data_sp)
		local cos = data_sp:COS()
		-- Fire cos first then SOE
		-- self:send(cos)
		local soe = data_sp:SOE()
		-- self:send(soe)
		-- Wait for confirmation
	end
	local has_c2, data_c2 = self:poll_class2()
	if has_c2 then
		print('send class2 data')
		local req = self:make_frame(f_ctrl.static.FC_DATA, nil, data_c2, nil, true)
		local resp = self:request(req)
		print('class2.resp', resp)
	end
end

return device
