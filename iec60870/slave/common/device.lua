--- This is class for device data helper
--	e.g. make data snapshot, make spontenous data and so on
local class = require 'middleclass'
local util = require 'iec60870.common.util'
local common_helper = require 'iec60870.slave.common.helper'
local data_pool = require 'iec60870.slave.common.device.data_pool'

local device = class('LUA_IEC60870_SLAVE_COMMON_DEVICE')

local MAX_SP_COUNT = 70
local MAX_ME_COUNT = 30
local MAX_IT_COUNT = 30

-- Addr: number device addr
-- Mode:'balance' or 'unbalance'
function device:initialize(addr, mode, max_sp_count, max_me_count, max_it_count)
	base.initialize(self, addr)

	local device_m = require 'iec60870.slave.common.device.'..mode
	self._impl = device_m:new(self, addr)

	self._sp_data = nil
	self._max_sp_count = max_sp_count or MAX_SP_COUNT
	self._me_data = nil
	self._max_me_count = max_me_count or MAX_ME_COUNT
	self._it_data = nil
	self._max_it_count = max_it_count or MAX_IT_COUNT
end

function device:add_sp_data(inputs)
	assert(not self._sp_data)
	self._sp_data = data_pool:new(inputs, MAX_SP_COUNT, false, function(input, value)
		return common_helper.make_sp_na(input.addr, value.value, value.timestamp)
	end)
	return self._sp_data
end

function device:add_me_data(inputs)
	assert(not self._me_data)
	self._me_data = data_pool:new(inputs, MAX_ME_COUNT, 0, function(input, value)
		if input.ti == 'ME_NA' then
			return common_helper.make_me_na(input.addr, value.value, value.timestamp)
		elseif input.ti == 'ME_NB' then
			return common_helper.make_me_nb(input.addr, value.value, value.timestamp)
		elseif v.ti == 'ME_NC' or v.ti == 'ME' then
			return common_helper.make_me_nc(input.addr, value.value, value.timestamp)
		else
			return nil, 'Unknown ME found '
		end
	end)
	return self._me_data
end

function device:add_it_data(inputs)
	assert(not self._it_data)
	self._it_data = data_pool:new(inputs, MAX_IT_COUNT, 0, function(input, value)
		return common_helper.make_it_na(input.addr, value.value, value.timestamp)
	end)
	return self._it_data
end

-- Return a list of different kind of data object list
function device:get_snapshot()
	local snapshot = {}
	if self._sp_data then
		local sp_snap = self._sp_data:make_snapshot()
		snapshot = table.move(sp_snap, 1, #sp_snap, #snapshot + 1, snapshot)
	end
	if self._me_data then
		local me_snap = self._me_data:make_snapshot()
		snapshot = table.move(me_snap, 1, #me_snap, #snapshot + 1, snapshot)
	end
	if self._it_data then
		local it_snap = self._it_data:make_snapshot()
		snapshot = table.move(it_snap, 1, #it_snap, #snapshot + 1, snapshot)
	end
	return snapshot
end

function device:has_spontaneous()
	if self._sp_data and self._sp_data:has_spont_data() then
		return true
	end
	return false
end

function device:get_spontaneous()
	if self._sp_data and self._sp_data:has_spont_data() then
		return self._sp_data:get_spont_data()
	end
	-- assert(false, 'Should not be here!!')
	return nil
end

--[[
-- 遥测变位也通过2级数据发送
SRC:	681a1a68080109040301014000000002402003000340a0000008409001007c16
{"ft":"0x68","ctrl":{"dir":0,"acd":0,"fc":8,"name":"CTRL","prm":0,"dfc":0},"name":"FT1.2 Frame","asdu":{"name":"ASDU","unit":{"ti":9,"cot":{"cause":"Spontaneous","name":"Cause of Transfer"},"vsq":{"name":"Variable structure qualifier","count":4,"sq":0},"name":"Unit","caoa":{"addr":1,"name":"Common address of ASDU"}},"objs":[{"name":"ASDU Object","addr":{"addr":16385,"name":"ADDR"},"data":[{"val":0,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]},{"name":"ASDU Object","addr":{"addr":16386,"name":"ADDR"},"data":[{"val":800,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]},{"name":"ASDU Object","addr":{"addr":16387,"name":"ADDR"},"data":[{"val":160,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]},{"name":"ASDU Object","addr":{"addr":16392,"name":"ADDR"},"data":[{"val":400,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]}]},"addr":{"addr":1,"name":"ADDR"}}
--]]
function device:get_class2_data()
	if self._me_data and self._me_data:has_spont_data() then
		return self._me_data:get_spont_data()
	end
	if self._it_data and self._it_data:has_spont_data() then
		return self._it_data:get_spont_data()
	end
	return nil
end


function device:on_disconnected()
	return self._impl:on_disconnected()
end

function device:on_connected()
	return self._impl:on_connected()
end

function device:make_snapshot()
	return self._impl:make_snapshot()
end

function device:poll_class1()
	return self._impl:poll_class1()
end

function device:poll_class2()
	return self._impl:poll_class2()
end

return data
