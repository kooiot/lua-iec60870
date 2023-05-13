local class = require 'middleclass'

local types = require 'iec60870.types'
local unpack = class('LUA_IEC60870_DATA_UNPACK')

--- need global settings??
function unpack:initialize()
end

function unpack:__call(raw, index)
	assert(raw, 'Raw data content missing')
	local index = index or 1
	
	if fmt == 'bit' then
		return self:bit_bin(data, index)
	end

	local bf = self._ascii and '>' or '<'

	if fmt == 'raw' or fmt == 'string' then
		assert(raw_len, 'String/raw length needed')
		return string.unpack(bf..'c'..raw_len, data, index)
	end

	local dfmt = data_fmts[fmt]
	assert(dfmt, string.format('Format: %s is not supported', fmt))

	return string.unpack(bf..dfmt, data, index)
end

function unpack:bit_ascii(data, index)
	assert(false, "not implemented")
	--- TODO:
end

--- 4 bits for one bit value
function unpack:bit_bin(data, index)
	local lf = index % 2
	local new_index = (index // 2) + 1

	local val = string.unpack('I1', new_index)

	if lf then
		return (val >> 4) & 0xF, index + 1
	else
		return val & 0xF, index + 1
	end

	return index + 1
end

return unpack
