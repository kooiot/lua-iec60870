local asdu = require 'iec60870.asdu.init'

return function(dir_m, raw, index)
	index = index or 1
	local o = asdu:new(dir_m)
	index = o:from_hex(raw, index)
	return o, index
end
