local base = require 'iec60870.master.common.slave'
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

local slave = base:subclass('LUA_IEC60870_MASTER_CS101_SLAVE')

function slave:initialize(master, channel, addr, balance, controlled)
	base.initialize(self)
	self._master = assert(master, 'Master is required')
	self._channel = assert(channel, 'Channel is required')
	self._addr = assert(addr, 'Address is required')
	self._balance = balance
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
		'Slave created balance:',
		self._balance and 'TRUE' or 'FALSE',
		' controlled:',
		self._controlled and 'TRUE' or 'FALSE',
	}
	logger.debug(table.concat(si))
end

function slave:set_poll_cycle(ms)
	self._poll_cycle = ms
end

function slave:set_data_cb(cb)
	self._data_cb = cb or function() end
end

function slave:on_run(now_ms)
	-- print(self._inited, self._poll_cycle, self._last_poll, now_ms)
	if self._poll_cycle == 0 then
		return -- do nothing
	end
	if not self._inited then
		self._last_poll = now_ms - self._poll_cycle
		return
	end

	local next_poll_ms = self._last_poll + self._poll_cycle
	if now_ms > next_poll_ms then
		logger.debug('Send poll station ...')
		-- Send poll station
		local r, err = self:send_poll_station() 
		if r then
			self._last_poll = next_poll_ms
		else
			logger.error('Poll station failed: '..err)
			self._last_poll = self._last_poll + 3000 -- wait for three seconds retry
		end
	end
end

function slave:make_data_frame(asdu)
	return self:make_frame(f_ctrl.static.FC_DATA, asdu)
end

function slave:make_frame(fc, asdu, ft_type)
	local ftt = ft_type
	if not ftt then
		if asdu then
			ftt = ft12.static.FT_FLEX
		else
			ftt = ft12.static.FT_FIXED
		end
	end
	local ctrl = self:make_ctrl(fc)
	return ft12:new(ftt, ctrl, f_addr:new(self._addr), asdu)
end

function slave:ADDR()
	return self._addr
end

function slave:DIR()
	if not self._balance then
		return f_ctrl.static.DIR_R
	end
	return self._controlled and f_ctrl.static.DIR_S or f_ctrl.static.DIR_M
end

function slave:PRM()
	return self._controlled and f_ctrl.static.PRM_S or f_ctrl.static.PRM_P
end

function slave:FCB()
	return self._fcb
end

-- When received response then set to next_fcb
function slave:FCB_NEXT()
	self._fcb = (self._fcb + 1) % 2 
end

function slave:make_ctrl(fc)
	local fcv_en =  f_ctrl:need_fcv(fc) -- FCV required by function code
	if fcv_en then
		-- FCV: 1
		return f_ctrl:new(self:DIR(), self:PRM(), self:FCB(), 1, fc)
	else
		-- FCV: 0
		return f_ctrl:new(self:DIR(), self:PRM(), 0, 0, fc)
	end
end

function slave:post_result(req, resp)
	if req then
		local ctrl = req:CTRL()
		local fc = ctrl:FC()
		if f_ctrl:need_fcv(fc) then
			self:FCB_NEXT()
		end
	end

	local ctrl = resp:CTRL()
	if ctrl:ACD() == 1 then
		if self._balance then
			assert(false, 'Balance mode cannot use ACD???')
		end
		self._requestClass1 = true -- 一级数据请求
		util.fork(function()
			self:do_work()
		end)
	end
	return req, resp
end

function slave:req_link_status()
	logger.info('slave '..self._addr..' request link status...')
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

function slave:req_link_reset()
	logger.info('slave '..self._addr..' request link reset...')
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

function slave:fire_poll_station()
	self._requestClass2 = true
	self._master:add_task(self);
end

function slave:send_poll_station(qoi)
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

function slave:_start_inner()
	if not self._balance then
		return self:unbalance_start()
	end
	return self:balance_start()
end

function slave:_start()
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
		logger.info('slave '..self._addr..' start...')
		local r, err = self:_start_inner()
		self._starting = false
		if r then
			logger.info('slave '..self._addr..' started')
			self._inited = true
		else
			logger.error('slave '..self._addr..' start failed')
			self._start_proc_cancel = util.cancelable_timeout(5000, start_proc)
		end
	end

	self._start_proc_cancel = util.cancelable_timeout(50, start_proc)
end

function slave:start()
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

function slave:unbalance_start()
	local r, err = self:req_link_status()
	if not r then
		logger.error('slave '..self._addr..' request link status failed', err)
		return nil, err
	end
	return self:req_link_reset()
end

function slave:balance_start()
	local r, err = self:req_link_status()
	if not r then
		logger.error('slave '..self._addr..' request link status failed', err)
		return nil, err
	end
	return self:req_link_reset()
end

function slave:stop()
	self._inited = false
	self._closing = true
	self._channel:bind_linker_listen(self, nil)
	if self._request then
		util.wakeup(self._request)
	end
end

function slave:request_inner(frame)
	local result, err = self._channel:request(frame)
	if result then
		-- For anythings need to be done when received response
		self:post_result(frame, result)
	end
	return result, err
end

function slave:request(frame, need_confirm, need_terminate, desc)
	-- logger.debug(desc..' request start....')
	local timeout = 5000 + util.now()
	while not self._inited and not self._closing and self._lock  do
		util.sleep(50)
		if util.now() > timeout then
			if not self._inited then
				return nil, 'Wait slave ready timeout'
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
			return nil, desc..' slave ACD=0 so there will no confirm'
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
			logger.warning(desc..' slave ACD=0 so there will no terminate')
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

function slave:request_class1()
	local req = self:make_frame(f_ctrl.static.FC_EM1_DATA, nil)
	logger.debug('Send request class #1')
	local resp, err = self:request_inner(req)
	if not resp then
		logger.info('Retry request class #1 data')
		self._requestClass1 = true -- retry to get class 1 data
		return nil, err
	end

	if resp:FT() == ft12.static.FT_S_E5 then
		-- no class1 data
		return true
	end

	local ctrl = resp:CTRL()
	if ctrl:FC() == f_ctrl.static.FC_DATA_NONE then
		-- no class1 data
		return true
	end
	return self:on_request(resp)
end

function slave:request_class2()
	local req = self:make_frame(f_ctrl.static.FC_EM2_DATA, nil)
	local resp, err = self:request_inner(req)
	if not resp then
		return nil, err
	end

	if resp:FT() == ft12.static.FT_S_E5 then
		-- no class2 data
		return true
	end

	local ctrl = resp:CTRL()
	if ctrl:FC() == f_ctrl.static.FC_DATA_NONE then
		-- no class2 data
		return true
	end

	return self:on_request(resp)
end

function slave:do_work()
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

function slave:do_request_check(frame)
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

function slave:on_request(frame)
	-- print(frame)
	if self:do_request_check(frame) then
		return true
	end

	local ctrl = frame:CTRL()
	--[[
	if ctrl:FC() == f_ctrl.static.FC_DATA then
		return true
	end
	]]--

	if ctrl:FC() == f_ctrl.static.FC_DATA_RESP then
		local asdu = frame:ASDU()
		if asdu then
			local unit = asdu:UNIT()
			-- Spontaneous data
			if unit:COT():CAUSE() == 3 then
				local objs = asdu:OBJS()
				for k, v in pairs(objs) do
					-- TODO: new callback???
					self._data_cb(v, asdu)
				end
				return true
			end

			-- 总招数据
			if unit:COT():CAUSE() == 20 then
				local objs = asdu:OBJS()
				for k, v in pairs(objs) do
					-- print(k, v)
					self._data_cb(v, asdu)
				end
				return true
			end
		end

		-- TODO: 
	end

	return nil, "Invalid response fc:"..ctrl:FC()
end

return slave
