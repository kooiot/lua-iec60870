--[[
-- The object map master information and handles master request logicals
--]]
local base = require 'iec60870.slave.common.master'
local types = require 'iec60870.types'
local util = require 'iec60870.common.util'
local helper = require 'iec60870.common.helper'
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
	self._device = assert(device, 'Device is required')
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
	self._link_reset = false

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
	local dfc = 0 -- ready for next message
	if self._balanced or acd == nil then
		return f_ctrl:new(self:DIR(), self:PRM(), 0, dfc, fc)
	else
		if acd ~= 1 then
			acd = acd and 1 or 0
		end
		return f_ctrl:new(self:DIR(), self:PRM(), acd, dfc, fc)
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

function master:make_init_done_resp(coi)
	local asdu = {} -- FC=8 TI=70 COT=4 COI=2
	local coi = ti_map.create_data('coi', coi or 20)
	local cot = asdu_cot:new(types.COT_INITIALIZED) -- 4
	local caoa = asdu_caoa:new(self._device:ADDR())
	local unit = asdu_unit:new(types.M_EI_NA_1, cot, caoa)
	local obj = asdu_object:new(types.M_EI_NA_1, asdu_addr:new(0), coi)
	local asdu = asdu_asdu:new(false, unit, {obj})
	return self:make_frame(f_ctrl.static.FC_DATA_RESP, false, asdu)
end

function master:start()
	self._channel:bind_linker_listen(self, {
		on_connected = function()
			print('master.on_connected')
			self._inited = false
			self._device:on_connected()
		end,
		on_disconnected = function()
			print('master.on_disconnected')
			self._inited = false
			self._device:on_disconnected()
		end,
	})

	return true
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
	logger.debug('master '..self._device:ADDR()..' on request class 1 data')
	local acd, asdu = self._device:poll_class1()
	if asdu then
		return self:make_frame(f_ctrl.static.FC_DATA_RESP, acd, asdu)
	else
		return self:make_frame(f_ctrl.static.FC_DATA_NONE, false)
	end
end

function master:on_request_class2()
	local acd, asdu = self._device:poll_class2()
	if asdu then
		return self:make_frame(f_ctrl.static.FC_DATA_RESP, acd, asdu)
	else
		return self:make_frame(f_ctrl.static.FC_DATA_NONE, false)
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

	if ctrl:FC() == f_ctrl.static.FC_LINK then
		logger.debug('master '..self._device:ADDR()..' received request link ...')
		return self:make_frame(f_ctrl.static.FC_LINK_RESP, true)
	end

	if ctrl:FC() == f_ctrl.static.FC_RST_LINK then
		self._link_reset = true
		self._device:link_reset()
		logger.debug('master '..self._device:ADDR()..' received request link reset ...')
		return self:make_frame(f_ctrl.static.FC_RST_LINK, true)
	end

	if not self._inited then
		if self._link_reset and ctrl:FC() == f_ctrl.static.FC_EM1_DATA then
			self._link_reset = false
			self._inited = true
			logger.debug('master '..self._device:ADDR()..' response initialization done ...')
			return self:make_init_done_resp()
		end
		--- For the one what does not request the initialization done messge
		if self._link_reset then
			self._link_reset = false
			self._inited = true
		end
		-- Check inited again
		if not self._inited then
			--- skip any more
			return nil, 'Not inited!'
		end
	end

	--- 只有平衡模式才有FC_LINK_TEST
	if ctrl:FC() == f_ctrl.static.FC_LINK_TEST then
		logger.debug('master '..self._device:ADDR()..' received request link reset ...')
		return self:make_frame(f_ctrl.static.FC_S_OK, false)
	end

	if ctrl:FC() == f_ctrl.static.FC_DATA then
		local asdu = frame:ASDU()
		if asdu then
			local unit = asdu:UNIT()
			-- Spontaneous data
			if unit:TI() == 100 then
				if unit:COT():CAUSE() == 6 then
					-- Confirm Inttergation Command
					return self:on_inttergation()
				end
			elseif unit:TI() == 102 or unit:TI() == 132 then
				if unit:COT():CAUSE() == 6 then
					-- TODO: add class2 data
					return self:on_param_read()
				end
			elseif unit:TI() == 48 or unit:TI() == 136 then
				if unit:COT():CAUSE() == 6 then
					if unit:SE() == 1 then
						-- TODO: add class2 data
						return self:on_param_set_select()
					else
						-- TODO: add class2 data
						return self:on_param_set_apply()
					end
				end
			elseif unit:TI() == 103 then
				if unit:COT():CAUSE() == 6 then
					return self:on_time_sync()
				end
			elseif unit:TI() == 104 then
				if unit:COT():CAUSE() == 6 then
					-- TODO: Push an Class2 Data (TI=104 COT=7)
					return self:on_test_command()
				end
			elseif unit:TI() == 105 then
				if unit:COT():CAUSE() == 6 then
					-- TODO: Push an Class2 Data (TI=105 COT=7)
					return self:on_reset_process_command()
				end
			elseif unit:TI() == 45 then
				if unit:COT():CAUSE() == 6 then
					if unit:SE() == 1 then
						return self:on_ctrl_select()
					else
						-- TODO: added to class1 (TI=45/46 COT=10, S/E=0)
						return self:on_ctrl_apply()
					end
				elseif unit:COT():CAUSE() == 8 then
					return self:on_ctrl_abort()
				end
			elseif unit:TI() == 46 then
				if unit:COT():CAUSE() == 6 then
					if unit:SE() == 1 then
						return self:on_ctrl_select()
					else
						-- TODO: added to class1 (TI=45/46 COT=10, S/E=0)
						return self:on_ctrl_apply()
					end
				elseif unit:COT():CAUSE() == 8 then
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
		logger.debug('master '..self._device:ADDR()..' received read class 1 data request...')
		return self:on_request_class1()
	end

	if ctrl:FC() == f_ctrl.static.FC_EM2_DATA then
		logger.debug('master '..self._device:ADDR()..' received read class 2 data request...')
		return self:on_request_class2()
	end

	return nil, "Invalid response fc:"..ctrl:FC()
end

return master
