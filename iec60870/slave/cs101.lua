local base = require 'iec60870.slave.base'
local util = require 'iec60870.common.util'

local slave = base:subclass('LUA_IEC60870_SLAVE_CS101')

function slave:initialize(conf)
	local conf = conf or {}
	conf.COT_SIZE = conf.COT_SIZE or 1
	conf.FRAME_ADDR_SIZE = conf.FRAME_ADDR_SIZE or 2
	conf.ADDR_SIZE = conf.ADDR_SIZE or 2
	conf.OBJ_ADDR_SIZE = conf.OBJ_ADDR_SIZE or 2
	conf.MAX_RESEND = conf.MAX_RESEND or 3
	conf.MAX_RESEND_TIME = conf.MAX_RESEND_TIME or 10
	base.initialize(self, conf)
	self._started = false
	self._closing = false

	self._tasks = {}
	self._next_slaves = {}
end

-- lock to specified addr slave for a while until unlock
--   Any other slave request/response will skipped
function slave:lock_slave(addr)
	self._lock_slave = addr
end

function slave:unlock_slave(addr)
	self._lock_slave = nil
end

function slave:poll_data(addr)
	-- return slave:send_poll_station()
end

function slave:start()
	if self._started then
		return false, 'Already started'
	end
	self._closing = false

	util.fork(function()
		while not self._closing do
			self:on_run()
		end
	end)
	util.fork(function()
		self:do_task_work()
	end)

	self._started = true
	return true
end

function slave:stop()
	if not self._started then
		return false, 'Already stoped'
	end
	if self._closing then
		return true, 'Already closing...'
	end

	self._closing = true

	self._started = false
	return true
end

function slave:on_run()
end

function slave:do_task_work()
	while not self._closing do
		if #self._tasks > 0 then
			--- Pop one task
			local task = table.remove(self._tasks, 1)
			task:do_work()
		else
			util.sleep(100) -- 100 ms
		end
	end
end

function slave:add_task(task)
	-- Fifo
	table.insert(self._tasks, task)
end

return slave
