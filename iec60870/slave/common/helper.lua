local class = require 'middleclass'
local types = require 'iec60870.types'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_object = require 'iec60870.asdu.object'

local helper = class('LUA_IEC60870_SLAVE_COMMON_HELPER')

function helper:initialize()
end

function helper:make_object(ti, addr, ...)
	return asdu_object:new(ti, asdu_addr:new(addr), { ... })
end

function helper:make_cp24time2a(timestamp)
	local ms = timestamp % 1000
	local sec = (timestamp // 1000) % 60
	local min = (timestamp // 60000) % 60
	return ti_map.create_data('CP24Time2a', 0, min, sec, ms)
end

--[[
-- addr: integer
-- val: number(0 or 1)
-- timestamp: number
--]]
function helper:make_sp_na(addr, val)
	return self:make_object(types.M_SP_NA_1, addr, ti_map.create_data('SIQ', val))
end

--[[
-- addr: integer
-- val: number(0 or 1)
-- timestamp: number
--]]
function helper:make_sp_ta(addr, val, timestamp)
	local t = self:make_cp24time2a(timestamp)
	return self:make_object(types.M_SP_TA_1, addr, ti_map.create_data('SIQ', val), t)
end

function helper:make_dp_na(addr, val)
	return self:make_object(types.M_DP_NA_1, addr, ti_map.create_data('DIQ', val))
end

function helper:make_dp_ta(addr, val, timestamp)
	local t = self:make_cp24time2a(timestamp)
	return self:make_object(types.M_DP_TA_1, addr, ti_map.create_data('DIQ', val))
end

function helper:make_me_na(addr, val)
	return self:make_object(types.M_ME_NA_1, addr, ti_map.create_data('NVA', val), ti_map.create_data('QDS'))
end

function helper:make_me_ta(addr, val, timestamp)
	local t = self:make_cp24time2a(timestamp)
	return self:make_object(types.M_ME_TA_1, addr, ti_map.create_data('NVA', val), ti_map.create_data('QDS'), t)
end

function helper:make_me_nb(addr, val)
	return self:make_object(types.M_ME_NA_1, addr, ti_map.create_data('SVA', val), ti_map.create_data('QDS'))
end

function helper:make_me_tb(addr, val, timestamp)
	local t = self:make_cp24time2a(timestamp)
	return self:make_object(types.M_ME_TA_1, addr, ti_map.create_data('SVA', val), ti_map.create_data('QDS'), t)
end

function helper:make_it_na(addr, val)
	-- TODO: addr to sq????
	local sq = addr
	return self:make_object(types.M_IT_NA_1, addr, ti_map.create_data('BCR', val, sq))
end

function helper:make_it_ta(addr, val, timestamp)
	local t = self:make_cp24time2a(timestamp)
	local sq = addr
	return self:make_object(types.M_IT_TA_1, addr, ti_map.create_data('BCR', val, sq), t)
end

return helper
