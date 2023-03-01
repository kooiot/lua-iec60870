local base = require 'iec60870.master.base'
local ft12 = require 'iec60870.frame.ft12'
local f_ctrl = require 'iec60870.frame.ctrl'

local master = base:subclass('LUA_IEC60870_MASTER_CS101')

function master:initialize(conf, balance)
	local conf = conf or {}
	conf.ASDU_COT_SIZE = conf.ASDU_COT_SIZE or 1
	conf.ASDU_CAOA_SIZE = conf.ASDU_CAOA_SIZE or 2
	conf.ASDU_OBJ_ADDR_SIZE = conf.ASDU_OBJ_ADDR_SIZE or 2
	conf.MAX_RESEND = conf.MAX_RESEND or 3
	conf.MAX_RESEND_TIME = conf.MAX_RESEND_TIME or 10
	base.initialize(self, conf)
	self._balance = balance
	self._fcb = 0
end

function master:make_frame(ctrl, addr, asdu, ft_type)
	local ftt = ft_type or ft12.static.FT_FLEX
	return ft12:new(ftt, ctrl, addr, asdu)
end

function master:FCB()
	return self._fcb
end

function master:FCB_NEXT()
	self._fcb = (self._fcb + 1) % 2 
end

function master:make_ctrl(fc)
	local dir = self._balance and f_ctrl.static.DIR_R or f_ctrl.static.DIR_M
	local fcv_en =  f_ctrl:need_fcv(fc) -- FCV required by function code
	if fcb_en then
		return f_ctrl:new(dir, f_ctrl.static.PRM_REQ, self:FCB(), 1, fc)
	else
		return f_ctrl:new(dir, f_ctrl.static.PRM_REQ, 0, 0, fc)
	end
end

-- lock to specified addr slave for a while until unlock
--   Any other slave request/response will skipped
function master:lock_slave(addr)
	self._lock_slave = addr
end

function master:unlock_slave(addr)
	self._lock_slave = nil
end

function master:fire_poll_station(addr)
	local slave = self._slaves[addr]
	if not slave then
		return nil, 'Slave ['..addr..'] not found'
	end
	return slave:fire_poll_station()
end

function master:send(req)
	assert(false, 'Not implemented!')
end

function master:start()
	assert(false, 'Not implemented!')
end

function master:stop()
	assert(false, 'Not implemented!')
end

return master
