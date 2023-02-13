local base = require 'iec60870.frame.base'
local types = require 'iec60870.types'

local data = base:subclass('LUA_IEC60870_DATA_BSI')

function data:initialize(val)
	self:set_val(val)
end

function data:BIT(index)
	return self._vals[index]
end

function data:SET_BIT(index, bv)
	self._vals[index] = bv
end

function data:VAL()
	local val = 0
	for i = 1, 32 do
		local v = self._vals[i]
		if v then
			val = val + ((v & 0x1) << i)
		end
	end
	return val
end

function data:set_val(val)
	for i = 1, 32 do
		if (val >> i) & 0x1 then
			self._vals[i] = 1
		else
			self._vals[i] = 0
		end
	end
end

function data:to_hex()
	local val = self:VAL()
	return string.pack('I4', val)
end

function data:from_hex(raw, index)
	local val
	val, index = string.unpack('I4', raw, index)
	return index
end

function data:__totable()
	local t = {name = 'BSI'}
	for i = 1, 32 do
		local v = self._vals[i]
		if v then
			t['v_'..i] = v & 0x1
		else
			t['v_'..i] = 0
		end
	end

	return t
end

return data
