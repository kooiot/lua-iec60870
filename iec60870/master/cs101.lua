local base = require 'iec60870.master.base'
local ft12 = require 'iec60870.frame.ft12'
local f_ctrl = require 'iec60870.frame.ctrl'

local master = base:subclass('LUA_IEC60870_MASTER_CS101')

function master:initialize(conf)
	local conf = conf or {}
	conf.ASDU_COT_SIZE = conf.ASDU_COT_SIZE or 1
	conf.ASDU_CAOA_SIZE = conf.ASDU_CAOA_SIZE or 2
	conf.ASDU_OBJ_ADDR_SIZE = conf.ASDU_OBJ_ADDR_SIZE or 2
	conf.MAX_RESEND = conf.MAX_RESEND or 3
	conf.MAX_RESEND_TIME = conf.MAX_RESEND_TIME or 10
	base.initialize(self, conf)
	self._slaves = {}
	self._started = false
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
	self._slaves[addr] = slave
	if self._started then
		local r, err = slave:start()
		if not r then
			-- TODO: log print error
		end
	end
end

function master:del_slave(addr)
	local slave = self._slaves[addr]
	if slave then
		self._slaves[addr] = nil
		slave:stop()
	end
end

function master:fire_poll_station(addr)
	local slave = self._slaves[addr]
	if not slave then
		return nil, 'Slave ['..addr..'] not found'
	end
	return slave:fire_poll_station()
end

function master:start()
	if self._started then
		return false, 'Already started'
	end

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

	for addr, slave in pairs(self._slaves) do
		local r, err = slave:stop()
		if not r then
			--- TODO: print error
		end
	end
	self._started = false
	return true
end

return master
