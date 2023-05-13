local base = require 'iec60870.master.base'
local util = require 'iec60870.common.util'

local master = base:subclass('LUA_IEC60870_MASTER_CS101')

function master:initialize(conf)
	local conf = conf or {}
	conf.COT_SIZE = conf.COT_SIZE or 1
	conf.FRAME_ADDR_SIZE = conf.FRAME_ADDR_SIZE or 2
	conf.ADDR_SIZE = conf.ADDR_SIZE or 2
	conf.OBJ_ADDR_SIZE = conf.OBJ_ADDR_SIZE or 2
	conf.MAX_RESEND = conf.MAX_RESEND or 3
	conf.MAX_RESEND_TIME = conf.MAX_RESEND_TIME or 10
	base.initialize(self, conf)
	self._slaves = {}
	self._started = false
	self._closing = false

	self._tasks = {}
	self._next_slaves = {}
end

-- lock to specified addr slave for a while until unlock
--   Any other slave request/response will skipped
function master:lock_slave(addr)
	self._lock_slave = addr
end

function master:unlock_slave(addr)
	self._lock_slave = nil
end

function master:add_slave(addr, slave)
	assert(not self._slaves[addr])
	self._slaves[addr] = slave
	if self._started then
		local r, err = slave:start()
		if not r then
			return nil, err
		end
	end
	return true
end

function master:del_slave(addr)
	local slave = self._slaves[addr]
	if slave then
		self._slaves[addr] = nil
		slave:stop()
	end
end

function master:find_slave(addr)
	return self._slaves[addr]
end

function master:poll_data(addr)
	local slave = self._slaves[addr]
	if not slave then
		return nil, 'Slave ['..addr..'] not found'
	end
	return slave:send_poll_station()
end

function master:start()
	if self._started then
		return false, 'Already started'
	end
	self._closing = false

	util.fork(function()
		while not self._closing do
			self:do_next_slave()
			-- Wait for new task adding
		end
	end)
	util.fork(function()
		self:do_task_work()
	end)

	for addr, slave in pairs(self._slaves) do
		local r, err = slave:start()
		if not r then
			--- TODO: print error
		end
	end

	self._started = true
	return true
end

function master:stop()
	if not self._started then
		return false, 'Already stoped'
	end
	if self._closing then
		return true, 'Already closing...'
	end

	self._closing = true

	for addr, slave in pairs(self._slaves) do
		local r, err = slave:stop()
		if not r then
			--- TODO: print error
		end
	end
	self._started = false
	return true
end

function master:do_next_slave()
	if #self._next_slaves == 0 then
		util.sleep(100) -- 100 ms
		for k, v in pairs(self._slaves) do
			table.insert(self._next_slaves, k)
		end
	end
	local addr = table.remove(self._next_slaves, 1)
	local slave = self._slaves[addr]
	if slave then
		slave:on_run(util.now())
	end

end

function master:do_task_work()
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

function master:add_task(task)
	-- Fifo
	table.insert(self._tasks, task)
end

return master
