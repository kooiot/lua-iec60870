local base = require 'iec60870.slave.common.master'
local types = require 'iec60870.types'
local util = require 'iec60870.common.util'
local logger = require 'iec60870.common.logger'
local ft12 = require 'iec60870.frame.ft12'
local f_ctrl = require 'iec60870.frame.ctrl'
local f_addr = require 'iec60870.frame.addr'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_cot = require 'iec60870.asdu.cot'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_caoa = require 'iec60870.asdu.caoa'
local asdu_object = require 'iec60870.asdu.object'
local asdu_asdu = require 'iec60870.asdu.init'

local master = base:subclass('LUA_IEC60870_SLAVE_CS101_MASTER')

function master:initialize(device, channel, balanced, controlled)
	base.initialize(self)
	self._device = assert(master, 'Device is required')
	self._channel = assert(channel, 'Channel is required')
	self._balanced = balanced
	self._controlled = controlled
	self._fcb = 1
	self._retry = 0
	self._poll_cycle = 0 --- 0 is disable
	self._last_poll = 0
	self._data_cb = function() end
	self._request = nil
	self._confirm_timeout = 5000
	self._terminate_timeout = 5000
	self._closing = false

	local si = {
		'Master object created balanced:',
		self._balanced and 'TRUE' or 'FALSE',
		' controlled:',
		self._controlled and 'TRUE' or 'FALSE',
	}
	logger.debug(table.concat(si))
end

function master:on_run(now_ms)
	if not self._inited then
		return
	end

	-- TODO:
	self._device:on_run()
	return
end

function master:make_data_frame(asdu)
	return self:make_frame(f_ctrl.static.FC_DATA, asdu)
end

function master:make_frame(fc, acd, asdu, ft_type)
	local ftt = ft_type
	if not ftt then
		if asdu then
			ftt = ft12.static.FT_FLEX
		else
			ftt = ft12.static.FT_FIXED
		end
	end
	local ctrl = self:make_ctrl(fc, acd)
	local addr = f_addr:new(self._device:ADDR())
	return ft12:new(ftt, ctrl, addr, asdu)
end

function master:ADDR()
	return self._device:ADDR()
end

function master:DIR()
	if not self._balanced then
		return f_ctrl.static.DIR_R
	end
	return self._controlled and f_ctrl.static.DIR_S or f_ctrl.static.DIR_M
end

function master:PRM()
	return self._controlled and f_ctrl.static.PRM_S or f_ctrl.static.PRM_P
end

function master:FCB()
	return self._fcb
end

-- When received response then set to next_fcb
function master:FCB_NEXT()
	self._fcb = (self._fcb + 1) % 2 
end

function master:make_ctrl(fc, acd)
	if self._balanced or  acd == nil then
		return f_ctrl:new(self:DIR(), self:PRM(), 0, 1, fc)
	else
		if acd ~= 1 then
			acd = acd and 1 or 0
		end
		return f_ctrl:new(self:DIR(), self:PRM(), acd, 1, fc)
	end
end

function master:check_fcb(req)
	local ctrl = resp:CTRL()
	if ctrl:ACD() == 1 then
		if self._balanced then
			assert(false, 'Balance mode cannot use ACD???')
		end
		if ctrl:FCB() == self._fcb then
			return false, 'FCB not excepted'
		end
	end
	return true
end

function master:req_link_status()
	logger.info('master '..self._device:ADDR()..' request link status...')
	local frame = self:make_frame(f_ctrl.static.FC_LINK)
	local resp, err = self:request_inner(frame)
	if not resp then
		return nil, err
	end

	local ctrl = resp:CTRL()
	if ctrl:FC() ~= f_ctrl.static.FC_LINK_RESP then
		return nil, "Invalid response fc:"..ctrl:FC()
	end
	return true
end

function master:req_link_reset()
	logger.info('master '..self._device:ADDR()..' request link reset...')
	self._fcb = 1
	self._last_poll = 0 -- for poll data 
	self._last_poll =  util.now() - self._poll_cycle
	local frame = self:make_frame(f_ctrl.static.FC_RST_LINK)
	local resp, err = self:request_inner(frame)
	if not resp then
		return nil, err
	end

	local ctrl = resp:CTRL()
	if ctrl:FC() ~= f_ctrl.static.FC_S_OK then
		return nil, "Invalid response fc:"..ctrl:FC()
	end
	return true
end

function master:fire_poll_station()
	self._requestClass2 = true
	self._device:add_task(self);
end

function master:send_poll_station(qoi)
	if not self._inited then
		logger.debug('Not initialized....')
		return nil, 'Not initialized!'
	end
	if self._requestClass1 or self._requestClass2 then
		return nil, 'Class1/2 data is requesting..'
	end

	local asdu = {} -- FC=3 TI=100 COT=6 QOI=20
	local qoi = ti_map.create_data('qoi', qoi or 20)
	local cot = asdu_cot:new(types.COT_ACTIVATION) -- 6
	local caoa = asdu_caoa:new(self._addr)
	local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
	local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
	local asdu = asdu_asdu:new(false, unit, {obj})
	local req = self:make_frame(f_ctrl.static.FC_DATA, asdu)
	return self:request(req, true, true, 'Poll Station')
end

function master:_start_inner()
	if not self._balanced then
		return self:unbalance_start()
	end
	return self:balance_start()
end

function master:_start()
	if self._start_proc_cancel then
		self._start_proc_cancel()
		self._start_proc_cancel = nil
	end
	if self._starting then
		return
	end

	local start_proc
	start_proc = function()
		self._start_proc_cancel = nil
		self._starting = true
		logger.info('master '..self._addr..' start...')
		local r, err = self:_start_inner()
		self._starting = false
		if r then
			logger.info('master '..self._addr..' started')
			self._inited = true
		else
			logger.error('master '..self._addr..' start failed')
			self._start_proc_cancel = util.cancelable_timeout(5000, start_proc)
		end
	end

	self._start_proc_cancel = util.cancelable_timeout(50, start_proc)
end

function master:start()
	self._channel:bind_linker_listen(self, {
		on_connected = function()
			self:_start()
		end,
		on_disconnected = function()
			self._inited = false
		end,
	})

	return true
end

function master:unbalance_start()
	local r, err = self:req_link_status()
	if not r then
		logger.error('master '..self._addr..' request link status failed', err)
		return nil, err
	end
	return self:req_link_reset()
end

function master:balance_start()
	local r, err = self:req_link_status()
	if not r then
		logger.error('master '..self._addr..' request link status failed', err)
		return nil, err
	end
	return self:req_link_reset()
end

function master:stop()
	self._inited = false
	self._closing = true
	self._channel:bind_linker_listen(self, nil)
	if self._request then
		util.wakeup(self._request)
	end
end

function master:request_inner(frame)
	-- anything we need to process here?
	return self._channel:request(frame)
end

function master:request(frame, need_confirm, need_terminate, desc)
	-- logger.debug(desc..' request start....')
	local timeout = 5000 + util.now()
	while not self._inited and not self._closing and self._lock  do
		util.sleep(50)
		if util.now() > timeout then
			if not self._inited then
				return nil, 'Wait master ready timeout'
			else
				return nil, 'Wait for last request done timeout'
			end
		end
	end
	if self._closing then
		return nil, 'Closing....'
	end

	-- Lock for this request
	self._lock = {}

	-- logger.debug(desc..' request send ....')
	local result, err = self:request_inner(frame)
	if not result then
		self._lock = nil
		return nil, err
	end

	--[[
	if result:FT() == ft12.static.FT_S_E5 then
		-- no class1 data
		return nil, result
	end

	local ctrl = result:CTRL()
	if ctrl:FC() == f_ctrl.static.FC_DATA_NONE then
		-- no class1 data
		logger.error('Request meet DATA_NONE response', tostring(result))
		return false, result
	end
	]]--

	if need_confirm and not self._closing then
		if not self._requestClass1 then
			self._lock = nil
			return nil, desc..' master ACD=0 so there will no confirm'
		end

		local asdu = frame:ASDU()
		if not asdu then
			logger.error(desc..' frame asdu required if you have confirm callback')
		else
			self._request = { req = frame, resp = nil }
			logger.info(desc.. ' wait confirm ...')
			util.sleep(self._confirm_timeout, self._request)
			result = self._request.resp
			self._request = nil

			if not result then
				self._lock = nil
				return nil, desc .. (self._closing and 'closing ...' or 'confirm timeout ...')
			else
				logger.info(desc..' got confirm result', result)
			end
		end
	end

	if need_terminate and not self._closing then
		if not self._requestClass1 then
			logger.warning(desc..' master ACD=0 so there will no terminate')
			self._lock = nil
			return result
		end

		local asdu = frame:ASDU()
		if not asdu then
			logger.error(desc..' frame asdu required if you have confirm callback')
		else
			self._request = { req = frame, resp = nil }
			logger.info(desc..' wait terminate ...')
			util.sleep(self._terminate_timeout, self._request)
			result = self._request.resp
			self._request = nil
			if not result then
				self._lock = nil
				return nil, desc .. ' ' .. (self._closing and 'closing ...' or 'terminate timeout ...')
			else
				logger.info(desc..' got terminate result', result)
			end
		end
	end

	self._lock = nil

	if not result then
		if self._closing then
			return nil, 'Slave is closing...'
		else
			return nil, 'Unknown Error!!! '..desc
		end
	end

	return result
end

function master:on_inttergation()
	if self._device:make_snapshot() then
		return self:make_frame(f_ctrl.static.FC_S_OK, true)
	else
		return self:make_frame(f_ctrl.static.FC_S_FAIL, false)
	end
end

function master:on_request_class1()
	local acd, asdu = self._device:poll_class1()
	if asdu then
		return self:make_frame(f_ctrl.static.FC_EM1_DATA, acd, asdu)
	else
		-- TODO: what should we return?
		return self:make_frame(f_ctrl.static.FC_S_FAIL, false)
	end
end

function master:on_request_class2()
	local acd, asdu = self._device:poll_class2()
	if asdu then
		return self:make_frame(f_ctrl.static.FC_EM1_DATA, acd, asdu)
	else
		return self:make_frame(f_ctrl.static.FC_S_FAIL, false)
	end
end

function master:do_work()
	if self._requestClass1 then
		self._requestClass1 = false
		local r, err = self:request_class1()
		if not r then
			logger.error('Request Class 1 failed. error:', tostring(err))
		end
	end
	--[[
	if self._requestClass2 then
		self._requestClass2 = false
		local r, err = self:request_class2()
		if not r then
			logger.error(err)
		end
	end
	]]--
end

function master:do_request_check(frame)
	if not self._request then
		logger.debug("do_request_check no request")
		return false
	end
	local req = assert(self._request.req)

	local asdu = frame:ASDU()
	if not asdu then
		logger.debug("do_request_check no ASDU")
		return false
	end

	local unit = asdu:UNIT()
	if unit:TI() ~= req:ASDU():UNIT():TI() then
		logger.debug("do_request_check TI diff")
		return false
	end
	self._request.resp = frame
	util.wakeup(self._request)
	return true
end

function master:on_request(frame)
	if self:do_request_check(frame) then
		return true
	end

	local ctrl = frame:CTRL()

	if ctrl:FC() == f_ctrl.static.FC_LINK_TEST then
		return self:make_frame(f_ctrl.static.FC_S_OK, true)
	end

	if ctrl:FC() == f_ctrl.static.FC_DATA then
		local asdu = frame:ASDU()
		if asdu then
			local unit = asdu:UNIT()
			-- Spontaneous data
			if unit:TI() == 100 then
				if unit:COT():CUASE() == 6 then
					-- Check TI=100
					return self:on_inttergation()
				end
			elseif unit:TI() == 102 or unit:TI() == 132 then
				if unit:COT():CUASE() == 6 then
					-- add class2 data
					return self:on_param_read()
				end
			elseif unit:TI() == 48 or unit:TI() == 136 then
				if unit:COT():CUASE() == 6 then
					if unit:SE() == 1 then
						-- add class2 data
						return self:on_param_set_select()
					else
						-- add class2 data
						return self:on_param_set_apply()
					end
				end
			elseif unit:TI() == 103 then
				if unit:COT():CUASE() == 6 then
					return self:on_time_sync()
				end
			elseif unit:TI() == 104 then
				if unit:COT():CUASE() == 6 then
					--- Add class2 data for test confirm
					return self:on_test_command()
				end
			elseif unit:TI() == 45 then
				if unit:COT():CUASE() == 6 then
					if unit:SE() == 1 then
						return self:on_ctrl_select()
					else
						-- added to class1 (TI=45/46 COT=10, S/E=0)
						return self:on_ctrl_apply()
					end
				elseif unit:COT():CUASE() == 8 then
					return self:on_ctrl_abort()
				end
			elseif unit:TI() == 46 then
				if unit:COT():CUASE() == 6 then
					if unit:SE() == 1 then
						return self:on_ctrl_select()
					else
						-- added to class1 (TI=45/46 COT=10, S/E=0)
						return self:on_ctrl_apply()
					end
				elseif unit:COT():CUASE() == 8 then
					return self:on_ctrl_abort()
				end
			else
				-- TODO:
				return nil, 'ASDU missing'
			end
		else
			return nil, 'ASDU missing'
		end
	end

	if ctrl:FC() == f_ctrl.static.FC_EM1_DATA then
		return self:on_request_class1()
	end

	if ctrl:FC() == f_ctrl.static.FC_EM2_DATA then
		return self:on_request_class2()
	end

	return nil, "Invalid response fc:"..ctrl:FC()
end

return master
