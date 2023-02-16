local base = require 'iec60870.master.base'
local ft12 = require 'iec60870.frame.ft12'

local master = base:subclass('LUA_IEC60870_MASTER_CS101')

function master:initialize(conf)
	local conf = conf or {}
	conf.ADDR_LEN = conf.ADDR_LEN or 2
	conf.ASDU_COT_SIZE = conf.ASDU_COT_SIZE or 1
	conf.ASDU_CAOA_SIZE = conf.ASDU_CAOA_SIZE or 2
	base.initialize(self, conf)
end

function master:make_frame(ctrl, addr, asdu, ft_type)
	local ftt = ft_type or ft12.static.FT_FLEX
	return ft12:new(ftt, ctrl, addr, asdu)
end

function base:send(req)
	assert(false, 'Not implemented!')
end

function base:start()
	assert(false, 'Not implemented!')
end

function base:stop()
	assert(false, 'Not implemented!')
end

return master
