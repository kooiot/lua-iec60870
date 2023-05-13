local base = require 'iec60870.master.common.slave'
local types = require 'iec60870.types'
local util = require 'iec60870.common.util'
local logger = require 'iec60870.common.logger'
local f_apdu = require 'iec60870.frame.apdu'
local f_apci = require 'iec60870.frame.apci'
local f_apci_u = require 'iec60870.frame.apci.ucf'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_cot = require 'iec60870.asdu.cot'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_caoa = require 'iec60870.asdu.caoa'
local asdu_object = require 'iec60870.asdu.object'
local asdu_asdu = require 'iec60870.asdu.init'

local slave = base:subclass('LUA_IEC60870_MASTER_CS104_SLAVE')

function slave:initialize(master, channel, addr, controlled, opt)
	base.initialize(self)
	self._master = assert(master, 'Master is required')
	self._channel = assert(channel, 'Channel is required')
	self._addr = assert(addr, 'Address is required')
	self._controlled = controlled
	self._opt = {
		k = opt.k or 12,
		w = opt.w or 8,
	}
	self._si = 0
	self._last_si_ack = 0
	self._ri = 0
	self._last_ri_ack = 0

	self._retry = 0
	self._poll_cycle = 0 --- 0 is disable
	self._last_poll = 0
	self._data_cb = function() end
	self._request = nil
	self._confirm_timeout = 1000
	self._terminate_timeout = 3000

	self._inited = false
	self._starting = false
	self._closing = false

	local si = {
		'Slave created controlled:',
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

function slave:timer_proc()
	--- T1, T2, T3
	local t1_begin = nil
	local t1_tm = nil
	local t1_check = function(now)
		---
		if t1_begin and self._last_si_ack >= t1_begin then
			ti_begin = nil
			t1_tm = nil
		end

		if not t1_begin then
			if self._si ~= self._last_si_ack then
				t1_begin = self._last_si_ack + 1
				t1_tm = now
			end
		end
		if now - t1_tm > (conf.T1 * 1000) then
			logger.warning('T1 reached, reset channel')
			-- Reset channel
			self._channel:reset()
		end
	end

	local t2_begin = nil
	local t2_tm = nil
	local t2_check = function(now)
		if t2_begin and self._last_ri_ack >= t2_begin then
			t2_begin = nil
			t2_tm = nil
		end
		if not t2_begin then
			if self._ri ~= self._last_ri_ack then
				t2_begin = self._last_ri_ack + 1
				t2_tm = now
			end
		end
		if now - t2_tm > (conf.T2 * 1000) then
			logger.debug('T2 reached, send RI ACK')
			self:send_ri_ack()
		end
	end

	local t3_last = util.now()
	local t3_check = function(now)
		local last_frame_tm = self._channel:last_frame_tm()
		if t3_last < last_frame_tm then
			t3_last = last_frame_tm
		end

		if now - t3_last > (conf.T3 * 1000) then
			logger.debug('T3 reached, send Test U Frame')
			if self:send_test() then
				t3_last = now
			end
		end
	end

	while not self._closing do
		local now = util.now()
		if self._inited then
			t1_check(now)
			t2_check(now)
			t3_check(now)
		end

		util.sleep(1000) --- Sleep one second
	end
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
		self._last_poll = next_poll_ms
		-- Send poll station
		self:send_poll_station()
	end
end

function slave:make_u_frame(start_dt, stop_dt, test_fr)
	local apci = f_apci:new_u(start_dt, stop_dt, test_fr)
	return f_apdu:new(self._controlled, apci, nil)
end

function slave:make_s_frame(si)
	local apci = f_apci:new_s(si)
	return f_apdu:new(self._controlled, apci, nil)
end

function slave:make_i_frame(asdu)
	assert(asdu)
	local apci = f_apci:new_i(self._si, self._ri)
	self._si = self._si + 1 -- ri??
	return f_apdu:new(self._controlled, apci, asdu)
end

function slave:make_data_frame(asdu)
	return self:make_i_frame(asdu)
end

function slave:ADDR()
	return self._addr
end

function slave:DIR()
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
		return f_ctrl:new(self:DIR(), self:PRM(), self:FCB(), 1, fc)
	else
		return f_ctrl:new(self:DIR(), self:PRM(), 0, 0, fc)
	end
end

function slave:send_test()
	local test_frame = self:make_u_frame(0, 0, f_apci_u.static.REQ)
	local resp, err = self:request_inner(frame, 1000)
	if resp then
		logger.debug('slave '..self._addr..' send test (U Frame) done')
		return true
	else
		logger.error('slave '..self._addr..' send test (U Frame) failed', err)
		return false
	end
end

function slave:send_ri_ack()
	local ri = self._ri
	local ack_frame = self:make_s_frame(ri)
	local r, err = self._channel:send(ack_frame)
	if r then
		logger.debug('slave '..self._addr..' send (S Frame) done')
		self._last_ri_ack = ri
	else
		logger.error('slave '..self._addr..' send (S Frame) failed', err)
	end
end

function slave:on_frame_recv(frame)
	if frame:APCI():TYPE() == f_apci.static.FRAME_I then
		self._ri = (frame:APCI():FRAME():SI() + 1 ) % 0x7FFF
		-- print(self._ri, self._last_ri_ack, self._opt.w)

		if math.abs(self._ri - self._last_ri_ack) >= self._opt.w then
			self:send_ri_ack()
		end
	end
end

function slave:req_u_start()
	logger.info('slave '..self._addr..' request START CMD (U Frame)...')
	local frame = self:make_u_frame(f_apci_u.static.REQ, 0, 0)
	local resp, err = self:request_inner(frame)
	if not resp then
		return nil, err
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
	local req = self:make_i_frame(asdu)
	return self:request(req, true, true)
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
		local r, err = self:req_u_start()
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

function slave:stop()
	self._inited = false
	self._closing = true
	self._channel:bind_linker_listen(self, nil)
end

function slave:request_inner(frame, timeout)
	local result, err = self._channel:request(frame, timeout)
	if result then
		self:on_frame_recv(result)
	end
	return result, err
end

function slave:request(frame, need_confirm, need_terminate, desc)
	local timeout = util.now() + 5000
	while not self._inited and not self._closing do
		util.sleep(50)
		if util.now() > timeout then
			return nil, 'Wait for slave ready timeout'
		end
	end

	if self._closing then
		return nil, 'Closing...'
	end

	if need_confirm or need_terminate then
		while self._lock and not self._closing do
			util.sleep(50)
		end
		if self._closing then
			return nil, 'Closing...'
		end
		self._lock = {}
	end

	local result, err = self:request_inner(frame)
	if not result then
		return nil, err
	end

	if need_confirm and not self._closing then
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
				return nil, desc..' confirm timeout'
			else
				logger.info(desc..' got confirm result', result)
			end
		end
	end

	if need_terminate and not self._closing then
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
				return nil, desc..' terminate timeout'
			else
				logger.info(desc..' got terminate result', result)
			end
		end
	end

	self._lock = nil

	if not result then
		if self._closing then
			return nil, 'Slave is closing ...'
		else
			return nil, 'Unknown Error!!! '..desc
		end
	end

	return result
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
	self:on_frame_recv(frame)

	-- print(frame)
	if self:do_request_check(frame) then
		return true
	end

	local asdu = frame:ASDU()
	if asdu then
		local unit = asdu:UNIT()
		--- Check interrogation command
		if unit:TI() == types.C_IC_NA_1 then
			logger.warning("Interrogation command skipped...")
			return true -- just skip this
		end

		-- Spontaneous data
		if unit:COT():CAUSE() == 3 then
			local objs = asdu:OBJS()
			for k, v in pairs(objs) do
				-- TODO: new callback???
				self._data_cb(v, asdu)
			end
			return true
		end

		local objs = asdu:OBJS()
		for k, v in pairs(objs) do
			-- print(k, v)
			self._data_cb(v, asdu)
		end
		return true
	end

	if frame:APCI():TYPE() == f_apci.static.FRAME_U then
		if frame:APCI():FRAME():TEST_FR() == f_apci_u.static.REQ then
			return self:make_u_frame(0, 0, f_apci_u.static.ACK)
		end
	end
	if frame:APCI():TYPE() == f_apci.static.FRAME_S then
		local ri = frame:APCI():FRAME():RI()
		if self._si - ri > self._opt.k then
		end
	end

	return nil, 'Frame request not handled!'
end

return slave
