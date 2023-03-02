local class = require 'middleclass'
local util = require 'iec60870.util'
local g_conf = require 'iec60870.conf'
local logger = require 'iec60870.logger'
local buffer = require 'iec60870.buffer'

local base = class('LUA_IEC60870_MASTER_BASE')

function base:initialize(log, conf)
	-- Set logger
	logger.set_log(log)
	-- Change configuration
	for k, v in pairs(g_conf) do
		if conf[k] ~= nil then
			logger.info('Global setting overwrite key: '..k..' val: '..v)
			g_conf[k] = v
		end
	end

	self._request = nil
	self._result = nil
	self._buf = buffer:new(1024)
end

function base:start()
	assert(false, 'Not implemented!')
end

function base:stop()
	self._closing = true

	--- Abort apdu_wait
	if self._apdu_wait then
		util.wakeup(self._apdu_wait) -- wakeup the process co
	end

	-- Stop stream
	self._linker:stop()
end

function base:on_recv(raw)
	self._buf:append(raw)
	if self._apdu_wait then
		util.wakeup(self._apdu_wait)
	end
end

function base:frame_parser(raw, index)
	return nil, 'Not implemented'
end

function base:frame_min()
	return 1
end

function base:match_request(req, resp)
	return true
end

function base:frame_process()
	while not self._closing do
		::next_frame::
		--- Smaller size
		local frame, r, index
		if self._buf:len() < self:frame_min() then
			goto next_apdu
		end

		frame = self:frame_parser(tostring(self._buf), 1)
		if not frame then
			self._buf:pop(1)
			goto next_frame
		end

		r, index, err = frame:valid_hex(tostring(self._buf), 1)
		if not r then
			if index ~= 1 then
				self._buf:pop(index - 1)
				self._log:error('Frame error:'..err)
				goto next_frame
			end
		else
			local raw = self._buf:sub(1, index - 1)
			self._buf:pop(index - 1)
			local r = frame:from_hex(raw, 1)
			assert(r == index)

			if not self._request or not self._request_wait then
				self._log:error('Request missing or timeout!')
				goto next_frame
			end

			if self:match_request(self._request, frame) then
				self._log:error('Response not match request!')
				goto next_frame
			end

			self._result = frame
			self._log:debug('Got response for request')

			util.wakeup(self._request_wait)

			goto next_frame
		end

		::next_apdu::
		self._apdu_wait = {}
		util.sleep(1000, self._apdu_wait)
		self._apdu_wait = nil
	end
end

-- Timeout is ms
function base:request(asdu, timeout)
	assert(asdu, 'Request and Callback is required!')
	local timeout = timeout or g_conf.TIMEOUT

	local req, key = self:make_frame(asdu)
	if not req then
		logger.error('Make frame error: '..key)
		return nil, key
	end

	local tm = timeout
	while self._locked do
		util.sleep(10)
		tm = tm - 10
		if tm < 0 then
			return nil, 'Timeout wait for lock'
		end
	end

	local t = {}
	self._locked = t

	local r, err = self:send(req:to_hex())
	if not r then
		self._locked = nil
		logger.error('Send frame error: '..key)
		return nil, err
	end

	self._request = req
	util.sleep(timeout, t)
	self._request = nil

	local result = self._result or  { false, 'Timeout' }
	self._result = nil
	self._locked = nil

	return table.unpack(result)
end

return base
