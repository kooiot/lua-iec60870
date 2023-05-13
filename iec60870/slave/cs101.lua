local base = require 'iec60870.master.base'
local util = require 'iec60870.common.util'

local master = base:subclass('LUA_IEC60870_SLAVE_CS101')

function master:initialize(conf)
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

-- lock to specified addr master for a while until unlock
--   Any other master request/response will skipped
function master:lock_master(addr)
	self._lock_master = addr
end

function master:unlock_master(addr)
	self._lock_master = nil
end

function master:add_master(addr, master)
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

function master:del_master(addr)
	local master = self._masters[addr]
	if master then
		self._masters[addr] = nil
		master:stop()
	end
end

function master:find_master(addr)
	return self._masters[addr]
end

function master:poll_data(addr)
	local master = self._masters[addr]
	if not master then
		return nil, 'Slave ['..addr..'] not found'
	end
	return master:send_poll_station()
end

function master:start()
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

	for addr, master in pairs(self._masters) do
		local r, err = master:start()
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

	for addr, master in pairs(self._masters) do
		local r, err = master:stop()
		if not r then
			--- TODO: print error
		end
	end
	self._started = false
	return true
end

function master:do_next_master()
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
