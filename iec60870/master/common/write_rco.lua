local class = require 'middleclass'
local helper = require 'iec60870.common.helper'
local types = require 'iec60870.types'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_cot = require 'iec60870.asdu.cot'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_caoa = require 'iec60870.asdu.caoa'
local asdu_object = require 'iec60870.asdu.object'
local asdu_asdu = require 'iec60870.asdu.init'

local writer = class('LUA_IEC60870_FRAME_DATA_WRITER')

function writer:initialize(slave, addr)
	self._slave = assert(slave)
	self._addr = assert(addr)
end

function writer:do_request(value, se, need_terminate)
	local ti = types.C_RC_NA_1
	local data = ti_map.create_data('rco', value, 0, se)
	local cot = asdu_cot:new(types.COT_ACTIVATION) -- 6
	local caoa = asdu_caoa:new(self._slave:ADDR())
	local unit = asdu_unit:new(ti, cot, caoa)
	local obj = asdu_object:new(ti, asdu_addr:new(self._addr), data)
	local asdu = asdu_asdu:new(false, unit, {obj})

	local req = self._slave:make_data_frame(asdu)
	
	return self._slave:request(req, true, need_terminate, 'Write RCO')
end

function writer:__call(value)
	local r, err = self:do_request(value, 1) -- select
	if r then
		return self:do_request(value, 0, true) -- execute
	end
	return nil, err
end

return writer
