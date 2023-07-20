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
	self._masters = {}
	self._started = false
	self._closing = false

	self._tasks = {}
	self._next_masters = {}
end

-- lock to specified addr slave for a while until unlock
--   Any other slave request/response will skipped
function slave:lock_slave(addr)
	self._lock_slave = addr
end

function slave:unlock_slave(addr)
	self._lock_slave = nil
end

function slave:add_master(addr, master)
	assert(not self._masters[addr])
	self._masters[addr] = master
	if self._started then
		local r, err = master:start()
		if not r then
			return nil, err
		end
	end
	return true
end

function slave:del_master(addr)
	local master = self._masters[addr]
	if master then
		self._masters[addr] = nil
		master:stop()
	end
end

function slave:find_master(addr)
	return self._masters[addr]
end

function slave:poll_data(addr)
	--[[
	local slave = self._masters[addr]
	if not slave then
		return nil, 'Slave ['..addr..'] not found'
	end
	return slave:send_poll_station()
	]]--
end

function slave:start()
	if self._started then
		return false, 'Already started'
	end
	self._closing = false

	util.fork(function()
		while not self._closing do
			self:do_next_master()
			-- Wait for new task adding
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

	for addr, slave in pairs(self._masters) do
		local r, err = slave:stop()
		if not r then
			--- TODO: print error
		end
	end
	self._started = false
	return true
end

function slave:do_next_master()
	if #self._next_masters == 0 then
		util.sleep(100) -- 100 ms
		for k, v in pairs(self._masters) do
			table.insert(self._next_masters, k)
		end
	end
	local addr = table.remove(self._next_masters, 1)
	local master = self._masters[addr]
	if master then
		master:on_run(util.now())
	end
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
