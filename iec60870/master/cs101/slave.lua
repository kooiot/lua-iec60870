local class = require 'middleclass'
local ft12 = require 'iec60870.frame.ft12'
local f_ctrl = require 'iec60870.frame.ctrl'

local slave = class('LUA_IEC60870_MASTER_CS101_SLAVE')

function slave:initialize(master, linker, addr)
	self._master = master
	self._linker = linker
	self._addr = addr
end

function slave:make_frame(ctrl, asdu, ft_type)
	return self._master:make_frame(ctrl, self._addr, asdu, ft_type)
end

function slave:make_ctrl(fc, fcv_en)
	return self._master:make_ctrl(fc, fcv_en)
end

function slave:req_link_status()
	local ctrl = f_ctrl:new(f_ctrl.static.FC_LINK, false)
	local frame = self:make_frame(ctrl, nil, ft12.static.FT_FIXED)
	return self:send_req(frame)
end

function slave:req_link_reset()
	self._fcb = 0
	local ctrl = self:make_ctrl(f_ctrl.static.FC_RST_LINK, false)
	local frame = self:make_frame(ctrl, nil, ft12.static.FT_FIXED)
	return self:send_req(frame)
end

function slave:fire_poll_station()
	self._requestClass2 = true
end

function slave:send_poll_station()
	local ctrl = self:make_ctrl(f_ctrl.static.FC_EM2_DATA, true)
end

function slave:send(frame)
	return self._linker:send(frame)
end

return slave
