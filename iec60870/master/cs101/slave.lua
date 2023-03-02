local class = require 'middleclass'
local ft12 = require 'iec60870.frame.ft12'
local f_ctrl = require 'iec60870.frame.ctrl'

local slave = class('LUA_IEC60870_MASTER_CS101_SLAVE')

function slave:initialize(master, linker, addr, balance, controlled)
	self._master = master
	self._linker = linker
	self._addr = addr
	self._balance = balance
	self._controlled = controlled
	self._fcb = 1
	self._retry = 0
end

function slave:make_frame(ctrl, asdu, ft_type)
	local ftt = ft_type or ft12.static.FT_FLEX
	return ft12:new(ftt, ctrl, self._addr, asdu)
end

function slave:DIR()
	return self._controlled and f_ctrl.static.DIR_S or f_ctrl.static.DIR_M
end

function slave:PRM()
	return self._controlled and f_ctrl.static.PRM_S or f_ctrl.static.DIR_P
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
	if fcb_en then
		return f_ctrl:new(self:DIR(), self:PRM(), self:FCB(), 1, fc)
	else
		return f_ctrl:new(self:DIR(), self:PRM(), 0, 0, fc)
	end
end

function slave:req_link_status()
	local ctrl = self:make_ctrl(f_ctrl.static.FC_LINK)
	local frame = self:make_frame(ctrl, nil, ft12.static.FT_FIXED)
	return self:send_req(frame)
end

function slave:req_link_reset()
	self._fcb = 1
	local ctrl = self:make_ctrl(f_ctrl.static.FC_RST_LINK)
	local frame = self:make_frame(ctrl, nil, ft12.static.FT_FIXED)
	return self:send_req(frame)
end

function slave:fire_poll_station()
	self._requestClass2 = true
end

function slave:send_poll_station()
	local ctrl = self:make_ctrl(f_ctrl.static.FC_EM2_DATA, true)
end

function slave:start()
	if not self._balance then
		return self:unbalance_start()
	end
	return self:balance_start()
end

function slave:unbalance_start()
	local r, err = self:req_link_status()
	if not r then
		return err
	end
	return self:req_link_reset()
end

function slave:balance_start()
	local r, err = self:req_link_status()
	if not r then
		return err
	end
	return self:req_link_reset()
end

function slave:stop()
end

function slave:send(frame)
	return self._linker:send(frame)
end

return slave
