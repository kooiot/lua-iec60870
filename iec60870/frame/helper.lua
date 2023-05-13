local _M = {}

-- SUM(8bits)
local sum = require 'hashings.sum'
local cjson = require 'cjson.safe'
local basexx = require 'basexx'

function _M.sum(data)
	return sum:new(data):digest()
end

function _M.tostring(data)
	if not data then
		return '<EMPTY>'
	end
	if type(data) == 'table' and data.__totable then
		return assert(cjson.encode(data:__totable()))
	end
	return assert(cjson.encode(data))
end

local function check_table(t)
	for k, v in pairs(t) do
		assert(cjson.encode(k), 'key is not serializable: '..t.name..'.'..k)
		assert(cjson.encode(v), 'value is not serializable: '..t.name..'.'..k)
	end
	return t
end

function _M.totable(data)
	if not data then
		return nil
	end
	if type(data) == 'table' and data.__totable then
		return check_table(data:__totable())
	end
	return check_table(data)
end

function _M.totable_r(data)
	if not data then
		return nil
	end
	if type(data) == 'table' and data.__totable then
		return data:__totable()
	end
	return data
end

function _M.to_hex(...)
	return basexx.to_hex(...)
end

function _M.from_hex(...)
	return basexx.from_hex(...)
end

function _M.dump_raw(raw, index, desc)
	return print(desc or 'Unknown DESC', basexx.to_hex(string.sub(raw, index)))
end

return _M
