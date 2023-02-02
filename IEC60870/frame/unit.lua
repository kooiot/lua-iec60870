local class = require 'middleclass'

local unit = class('LUA_IEC60870_FRAME_UNIT')

unit.static.UND			= 0 -- 未定义
unit.static.M_SP_NA_1	= 1 -- 单点信息
unit.static.M_SP_TA_1	= 2 -- 带时标的单点信息
unit.static.M_DP_NA_1	= 3 -- 双点信息
unit.static.M_DP_TA_1	= 4 -- 带时标的双点信息
unit.static.M_


function unit:initialize(ti, vsq, cot, addr)
	self._ti = ti
	self._vsq = vsq
	self._cot = cot
	self._addr = addr
end

function unit:TI()
	return self._ti
end

function unit:VSQ()
	return self._vsq
end

function unit:COT()
	return self._cot
end

function unit:ADDR()
	return self._addr
end

function unit:to_hex()
	return string.char(self._ti)..string.char(_vsq)..string.char(self._cot)..string.
end

function unit:from_hex(raw, index)
	self._val = string.byte(raw, index)
end

function unit:__tostring()
	if self:PRM() == 1 then
		return 'DIR:'..self:DIR()..' PRM:'..self:PRM()..' FCB:'..self:FCB()..' FCV:'..self:FCV()..' FC:'..self:FC()
	else
		return 'DIR:'..self:DIR()..' PRM:'..self:PRM()..' ACD:'..self:ACD()..' DFC:'..self:DFC()..' FC:'..self:FC()
	end
end

return unit
