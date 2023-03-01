local base = require 'iec60870.master.base'
local apdu = require 'iec60870.frame.ft12'
local apci_i = require 'iec60870.apci.itf'
local f_apci = require 'iec60870.apci'

local master = base:subclass('LUA_IEC60870_MASTER_CS101')

function master:initialize(conf)
	local conf = conf or {}
	conf.ASDU_COT_SIZE = conf.ASDU_COT_SIZE or 2
	conf.ASDU_CAOA_SIZE = conf.ASDU_CAOA_SIZE or 2
	conf.ASDU_OBJ_ADDR_SIZE = conf.ASDU_OBJ_ADDR_SIZE or 3
	base.initialize(self, conf)
end

function master:make_frame(ctrl, addr, asdu, apci_frame)
	apci_frame = apci_frame or itf:new(self._si, self._ri)
	return f_apci:new(apci_frame, 
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
