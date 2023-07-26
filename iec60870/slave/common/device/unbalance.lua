local class = require 'middleclass'
local types = require 'iec60870.types'
local ti_map = require 'iec60870.asdu.ti_map'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_cot = require 'iec60870.asdu.cot'
local asdu_addr = require 'iec60870.asdu.addr'
local asdu_caoa = require 'iec60870.asdu.caoa'
local asdu_object = require 'iec60870.asdu.object'
local asdu_asdu = require 'iec60870.asdu.init'

local device = class('LUA_IEC60870_SLAVE_COMMON_DEVICE')

function device:initialize(addr)
	self._addr = addr
	self._first_class1 = true -- first class1 poll cannot be break by class2 data
	self:_reset_snapshot_list()
end

function device:_reset_snapshot_list()
	-- reset snapshot list
	self._data_snapshot = nil
	self._data_snapshot_cur = 0
end

function device:on_disconnected()
	self:_reset_snapshot_list()
end

function device:on_connected()
	self:_reset_snapshot_list()
end

-- Return a list of different kind of data object list
function device:get_snapshot()
	assert(false, 'Not implemented!')
end

function device:has_spontaneous()
	assert(false, 'Not implemented!')
end

function device:get_spontaneous()
	assert(false, 'Not implemented!')
end

--[[
-- 遥测变位也通过2级数据发送
SRC:	681a1a68080109040301014000000002402003000340a0000008409001007c16
{"ft":"0x68","ctrl":{"dir":0,"acd":0,"fc":8,"name":"CTRL","prm":0,"dfc":0},"name":"FT1.2 Frame","asdu":{"name":"ASDU","unit":{"ti":9,"cot":{"cause":"Spontaneous","name":"Cause of Transfer"},"vsq":{"name":"Variable structure qualifier","count":4,"sq":0},"name":"Unit","caoa":{"addr":1,"name":"Common address of ASDU"}},"objs":[{"name":"ASDU Object","addr":{"addr":16385,"name":"ADDR"},"data":[{"val":0,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]},{"name":"ASDU Object","addr":{"addr":16386,"name":"ADDR"},"data":[{"val":800,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]},{"name":"ASDU Object","addr":{"addr":16387,"name":"ADDR"},"data":[{"val":160,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]},{"name":"ASDU Object","addr":{"addr":16392,"name":"ADDR"},"data":[{"val":400,"name":"NVA:"},{"bl":0,"iv":"Valid","ov":0,"name":"QDS","nt":0,"sb":0}]}]},"addr":{"addr":1,"name":"ADDR"}}
--]]
function device:get_class2_data()
	return nil
end

function device:ADDR()
	return self._addr
end

function device:make_snapshot()
	if self._data_snapshot then
		return false, 'Snapshot already created!'
	end
	self._data_snapshot = self:get_snapshot()
	self._data_snapshot_cur = 0
	return true
end

-- TODO: should return asdu??
function device:poll_class1()
	if not self._data_snapshot then
		if not self._first_class1 then
			return false, nil -- what happen here???
		end
		local data_sp = assert(self:has_spontaneous())
		return self:has_spontaneous(), data_sp
	end

	if not self._first_class1 and self:has_spontaneous() then
		return true, self:get_spontaneous()
	end

	if self._data_snapshot_cur == 0 then
		self._data_snapshot_cur = 1
		local asdu = {} -- FC=8 TI=100 COT=7 QOI=20
		local qoi = ti_map.create_data('qoi', qoi or 20)
		local cot = asdu_cot:new(types.COT_ACTIVATION) -- 6
		local caoa = asdu_caoa:new(self._addr)
		local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
		local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
		return true, asdu_asdu:new(false, unit, {obj})
	end

	if #self._data_snapshot >= self._data_snapshot_cur then
		local data_list = self._data_snapshot[self._data_snapshot_cur]
		self._data_snapshot_cur = self._data_snapshot_cur + 1
		return true, asdu
	end

	if self._first_class1 and self:has_spontaneous() then
		return true, self:get_spontaneous()
	end

	-- All snapshot list fired
	self:_reset_snapshot_list()
	-- For termination COT=10
	local asdu = {} -- FC=8 TI=100 COT=10 QOI=20
	local qoi = ti_map.create_data('qoi', qoi or 20)
	local cot = asdu_cot:new(types.COT_ACTIVATION_TERMINATION) -- 10
	local caoa = asdu_caoa:new(self._addr)
	local unit = asdu_unit:new(types.C_IC_NA_1, cot, caoa)
	local obj = asdu_object:new(types.C_IC_NA_1, asdu_addr:new(0), qoi)
	local resp = asdu_asdu:new(false, unit, {obj})

	--- If first_class1 is true then check whether has spontaneous data to keep class1 poll working ??? 
	if self._first_class1 and self:has_spontaneous() then
		return true, resp
	end

	-- This is last class1 response
	return false, resp
end

function device:poll_class2()
	local data_c2 = self:get_class2_data()
	local has_sp = self:has_spontaneous() 
	if data_c2 then
		return has_sp, data_c2
	end

	if has_sp then
		-- return wether has more sp data and current sp data
		local sp_data = self:get_spontaneous()
		return self:has_spontaneous(), sp_data
	end

	return false, nil
end

return device
