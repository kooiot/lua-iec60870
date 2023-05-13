local class = require 'middleclass'
local g_conf = require 'iec60870.conf'
local util = require 'iec60870.common.util'
local logger = require 'iec60870.common.logger'
local buffer = require 'iec60870.common.buffer'

local channel = class('LUA_IEC60870_MASTER_CHANNEL')

function channel:initialize(linker)
	self._linker = assert(linker, 'Linker is required')
	self._request = nil
	self._result = nil
	self._buf = buffer:new(1024)
	self._io_cb = function(...) end
	self._last_frame_tm = util.now()
end

function channel:set_io_cb(cb)
	self._io_cb = cb
end

function channel:bind_linker_listen(key, listen)
	self._linker:bind_listen(key, listen)
end

function channel:last_frame_tm()
	return self._last_frame_tm
end

function channel:start()
	self._linker:bind_recv(function(raw)
		self:on_recv(raw)
	end)

	local r, err = self._linker:open()	
	if not r then
		return nil, err
	end

	util.fork(function()
		self:frame_process()
	end)

	return true
end

function channel:stop()
	self._closing = true

	--- Abort apdu_wait
	if self._apdu_wait then
		util.wakeup(self._apdu_wait) -- wakeup the process co
	end

	-- Stop stream
	return self._linker:close()
end

function channel:reset()
	logger.error('Not implemented reset method')
	return true
end

function channel:on_recv(raw)
	self._io_cb('IN', 'N/A', raw)
	self._buf:append(raw)
	if self._apdu_wait then
		util.wakeup(self._apdu_wait)
	end
end

function channel:frame_parser(raw, index)
	return nil, 'Not implemented'
end

function channel:frame_min()
	return 1
end

function channel:match_request(req, resp)
	return true
end

function channel:on_request(req)
	return true
end

function channel:frame_process()
	while not self._closing do
		::next_frame::
		--- Smaller size
		local frame, r, index, raw
		if self._buf:len() < self:frame_min() then
			goto next_apdu
		end

		logger.debug('Try parse frame', self._buf:len())
		frame, index, err = self:frame_parser(tostring(self._buf), 1)
		if not frame then
			logger.debug('Frame error: '..err, index)
			if index > 1 then
				self._buf:pop(index - 1)
				goto next_frame
			else
				goto next_apdu
			end
		end

		raw = self._buf:sub(1, index - 1)
		self._buf:pop(index - 1)
		logger.debug('Got frame size:'..string.len(raw))

		r = frame:from_hex(raw, 1)
		assert(r == index, 'Invalid frame parsed')

		-- Update last frame time
		self._last_frame_tm = util.now()

		logger.debug('Got frame:', tostring(frame))
		-- logger.error('Request missing or timeout!', self._request, self._locked)

		if self._request and self._locked then
			if self:match_request(self._request, frame) then
				self._result = { frame }
				logger.debug('Got response for request')

				util.wakeup(self._locked)
				-- Next frame
				goto next_frame
			end
		end

		resp, err = self:on_request(frame)
		if not resp then
			logger.error(err)
		end

		if resp and type(resp) ~= 'boolean' then
			local key = assert(resp:DUMP_KEY(self._linker))
			self._io_cb('OUT', key, resp:to_hex())
			-- Send Frame
			local r, err = self._linker:send(resp:to_hex())
			-- Update last frame time
			self._last_frame_tm = util.now()

			if not r then
				logger.error('Send response error: '..key)
			end
		end

		-- try to process more frame
		goto next_frame

		::next_apdu::
		if self._buf:len() > 0 then
			logger.debug('Wait one frame', self._buf:len())
		end
		self._apdu_wait = {}
		util.sleep(1000, self._apdu_wait)
		self._apdu_wait = nil
	end
end

function channel:send(req)
	assert(req, 'Request is required!')
	assert(self._linker, 'Linker cannot be nil')
	local timeout = timeout or g_conf.TIMEOUT

	logger.debug('Send frame', tostring(req))

	local key = assert(req:DUMP_KEY(self._linker))
	self._io_cb('OUT', key, req:to_hex())

	self._locked = req
	-- Send request frame
	local r, err = self._linker:send(req:to_hex())
	-- Update last frame time
	self._last_frame_tm = util.now()
	self._locked = nil

	if not r then
		logger.error('Send frame error: '..key)
		return nil, err
	end

	return true
end

-- Timeout is ms
function channel:request(req, timeout)
	assert(req, 'Request is required!')
	assert(self._linker, 'Linker cannot be nil')
	local timeout = timeout or g_conf.TIMEOUT

	logger.debug('Send frame', tostring(req))

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

	local key = assert(req:DUMP_KEY(self._linker))
	self._io_cb('OUT', key, req:to_hex())
	-- Send request frame
	local r, err = self._linker:send(req:to_hex())
	-- Update last frame time
	self._last_frame_tm = util.now()
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

	if result[1] then
		-- print(result[1])
		logger.debug('Got response', tostring(result[1]))
	end

	return table.unpack(result)
end

return channel
