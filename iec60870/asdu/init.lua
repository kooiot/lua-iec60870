local base = require 'iec60870.frame.base'
local f_addr = require 'iec60870.frame.addr'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_ti_map = require 'iec60870.asdu.ti_map'
local asdu_vsq = require 'iec60870.asdu.vsq'

local helper = require 'iec60870.frame.helper'

local asdu = base:subclass('LUA_IEC60870_FRAME_ASDU')

function asdu:initialize(dir_m, unit, objects)
	self._dir_m = assert(dir_m ~= nil, 'DIR_M is required!')
	self._unit = unit or asdu_unit:new()
	self._objects = objects or {}
end

function asdu:DIRM()
	return self._dir_m
end

function asdu:UNIT()
	return self._unit
end

function asdu:OBJS()
	return self._objects
end

local vsq_from_objects = function(objs)
	local count = #objs
	if count <= 1 then
		return asdu_vsq:new(count, 0)
	end
	local addr = objs[1]:ADDR():ADDR()
	for _, v in ipairs(objs) do
		if addr ~= v:ADDR():ADDR() then
			return asdu_vsq:new(count, 0)
		end
		addr = addr + 1
	end
	return asdu_vsq:new(count, 1)
end

function asdu:to_hex()
	local t = {}
	local vsq = vsq_from_objects(self._objects)
	self._unit:SET_VSQ(vsq)
	t[1] = self._unit:to_hex()
	local skip_addr = vsq:SQ() == 1
	for i, v in ipairs(self._objects) do
		t[#t + 1] = v:to_hex(skip_addr and i ~= 1)
	end
	return table.concat(t)
end

function asdu:from_hex(raw, index)
	-- helper.dump_raw(raw, index, 'ASDU.from_hex')
	index = self._unit:from_hex(raw, index)
	-- print('ASDU.from_hex', self._unit)
	self._objects = {}
	local vsq = self._unit:VSQ()
	local ti = self._unit:TI()
	local skip_addr = vsq:SQ() == 1
	if skip_addr then
		local addr = 0
		for i = 1, vsq:COUNT() do
			local obj = nil
			-- helper.dump_raw(raw, index, 'ASDU.from_hex.object'..addr)
			if i == 1 then
				obj, index = asdu_ti_map.parse(ti, self._dir_m, nil, raw, index)
			else
				obj, index = asdu_ti_map.parse(ti, self._dir_m, f_addr:new(addr), raw, index)
			end
			addr = obj:ADDR():ADDR() + 1
			table.insert(self._objects, obj)
		end
	else
		for i = 1, vsq:COUNT() do
			local obj = nil
			-- helper.dump_raw(raw, index, 'ASDU.from_hex.object')
			obj, index = asdu_ti_map.parse(ti, self._dir_m, nil, raw, index)
			assert(obj, index)
			table.insert(self._objects, obj)
		end
	end
	return index
end

function asdu:__totable()
	local obj_tb = {}
	for _, v in ipairs(self._objects) do
		obj_tb[#obj_tb + 1] = helper.totable(v)
	end
	return {
		name = 'ASDU',
		unit = helper.totable(self._unit),
		objs = obj_tb,
	}
end

return asdu
