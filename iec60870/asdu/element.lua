local class = require 'middleclass'

local element = class('LUA_IEC60870_FRAME_ELEMENT')

element.static.ET_UI = 


function element:initialize(etype, esize, bit_offset, data, fct)
	self._ti = ti
	self._vsq = vsq
	self._cot = cot
	self._addr = addr
end

function element:TI()
	return self._ti
end

function element:VSQ()
	return self._vsq
end

function element:COT()
	return self._cot
end

function element:ADDR()
	return self._addr
end

function element:to_hex()
	return string.char(self._ti)..string.char(_vsq)..string.char(self._cot)..string.
end

function element:from_hex(raw, index)
	self._val = string.byte(raw, index)
end

function element:__tostring()
	if self:PRM() == 1 then
		return 'DIR:'..self:DIR()..' PRM:'..self:PRM()..' FCB:'..self:FCB()..' FCV:'..self:FCV()..' FC:'..self:FC()
	else
		return 'DIR:'..self:DIR()..' PRM:'..self:PRM()..' ACD:'..self:ACD()..' DFC:'..self:DFC()..' FC:'..self:FC()
	end
end

return element
