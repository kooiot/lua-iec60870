local class = require 'middleclass'
local t = require 'iec60870.types'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_object = require 'iec60870.asdu.object'

local _M = {}

function _M.initialize()
end

function _M.make_object(ti, addr, ...)
	return asdu_object:new(ti, asdu_addr:new(addr), { ... })
end

function _M.make_cp24time2a(timestamp)
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
function _M.make_sp_na(addr, val, timestamp, quality)
	return _M.make_object(t.M_SP_NA_1, addr, ti_map.create_data('SIQ', val))
end

--[[
-- addr: integer
-- val: number(0 or 1)
-- timestamp: number
--]]
function _M.make_sp_ta(addr, val, timestamp, quality)
	local t = _M.make_cp24time2a(timestamp)
	return _M.make_object(t.M_SP_TA_1, addr, ti_map.create_data('SIQ', val), t)
end

function _M.make_dp_na(addr, val, timestamp, quality)
	return _M.make_object(t.M_DP_NA_1, addr, ti_map.create_data('DIQ', val))
end

function _M.make_dp_ta(addr, val, timestamp, quality)
	local t = _M.make_cp24time2a(timestamp)
	return _M.make_object(t.M_DP_TA_1, addr, ti_map.create_data('DIQ', val), t)
end

function _M.make_me_na(addr, val, timestamp, quality)
	return _M.make_object(t.M_ME_NA_1, addr, ti_map.create_data('NVA', val), ti_map.create_data('QDS'))
end

function _M.make_me_ta(addr, val, timestamp, quality)
	local t = _M.make_cp24time2a(timestamp)
	return _M.make_object(t.M_ME_TA_1, addr, ti_map.create_data('NVA', val), ti_map.create_data('QDS'), t)
end

function _M.make_me_nb(addr, val, timestamp, quality)
	return _M.make_object(t.M_ME_NB_1, addr, ti_map.create_data('SVA', val), ti_map.create_data('QDS'))
end

function _M.make_me_tb(addr, val, timestamp, quality)
	local t = _M.make_cp24time2a(timestamp)
	return _M.make_object(t.M_ME_TB_1, addr, ti_map.create_data('SVA', val), ti_map.create_data('QDS'), t)
end

function _M.make_me_nc(addr, val, timestamp, quality)
	return _M.make_object(t.M_ME_NC_1, addr, ti_map.create_data('R32', val), ti_map.create_data('QDS'))
end

function _M.make_me_tc(addr, val, timestamp, quality)
	local t = _M.make_cp24time2a(timestamp)
	return _M.make_object(t.M_ME_TC_1, addr, ti_map.create_data('R32', val), ti_map.create_data('QDS'), t)
end

-- SQ is the addr index
function _M.make_it_na(addr, val, timestamp, quality, sq)
	return _M.make_object(t.M_IT_NA_1, addr, ti_map.create_data('BCR', val, sq))
end

function _M.make_it_ta(addr, val, timestamp, quality, sq)
	local t = _M.make_cp24time2a(timestamp)
	return _M.make_object(t.M_IT_TA_1, addr, ti_map.create_data('BCR', val, sq), t)
end

local ti_map = {
	[t.M_SP_NA_1] = _M.make_sp_na,
	[t.M_SP_TA_1] = _M.make_sp_ta,
	[t.M_DP_NA_1] = _M.make_dp_na,
	[t.M_DP_TA_1] = _M.make_dp_ta,
	[t.M_ME_NA_1] = _M.make_me_na,
	[t.M_ME_TA_1] = _M.make_me_ta,
	[t.M_ME_NB_1] = _M.make_me_nb,
	[t.M_ME_TB_1] = _M.make_me_tb,
	[t.M_ME_NC_1] = _M.make_me_nc,
	[t.M_ME_TC_1] = _M.make_me_tc,
	[t.M_IT_NA_1] = _M.make_it_na,
	[t.M_IT_TA_1] = _M.make_it_ta,
}

function _M.generate(ti, addr, val, timestamp, quality, ...)
	local func = ti_map[ti]
	if not func then
		return nil, 'TI '..ti..' not supported!'
	end
	return func(addr, val, timestamp, quality, ...)
end

return _M
