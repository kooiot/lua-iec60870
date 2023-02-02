local class = require 'middleclass'
local bcd = require 'GDW1178.frame.addr.bcd'

local addr = class('LUA_GDW11778_FRAME_BASE_ADDR')

addr.static.ADDR_S = 0 -- 单地址
addr.static.ADDR_P = 1 -- 通配地址
addr.static.ADDR_G = 2 -- 组地址
addr.static.ADDR_B = 3 -- 广播地址

function addr:initialize(addr_type, logic_addr, sa, ca)
	self._addr_type = addr_type
	self._logic_addr = logic_addr
	self._sa = sa
	self._ca = ca or 0
end

function addr:addr_type()
	return self._addr_type
end

function addr:logic_addr()
	return self._logic_addr
end

function addr:sa()
	return self._sa
end

function addr:ca()
	return self._ca
end

function addr:to_hex()
	local val = ((self._addr_type & 0x3) << 6)
	val = val + ((self._logic_addr & 0x3) << 4)
	val = val + addr_len & 0xF
	local addr_len = string.len(tostring(self._sa))
	local addr_s = bcd.encode(self._sa)
	return string.char(val)..addr_s..string.char(self._ca)
end

function addr:from_hex(raw, index)
	local val = string.byte(raw, index)
	self._addr_type = ((val >> 6) & 0x3)
	self._logic_addr = ((val >> 4) & 0x3)
	local addr_len = val & 0xF
	local addr_s = string.sub(raw, 2, math.ceil(addr_len / 2) + 1)
	local ca_s = string.sub(raw, math.ceil(addr_len / 2) + 2, math.ceil(addr_len / 2) + 2)
	self._sa = bcd.decode(addr_s)
	self._ca = string.byte(ca_s)
end

function addr:__tostring()
	return 'T:'..self._addr_type..' L:'..self._logic_addr..' ADDR:'..self._addr
end

return addr
