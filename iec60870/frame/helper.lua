local _M = {}

-- SUM(8bits)
local sum = require 'hashings.sum'

function _M.sum(data)
	return sum:new(data):digest()
end

return _M
