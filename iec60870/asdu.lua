local base = require 'iec60870.frame.base'
local asdu_unit = require 'iec60870.asdu.unit'
local asdu_object = require 'iec60870.asdu.object'

local helper = require 'iec60870.frame.helper'

local asdu = base:subclass('LUA_IEC60870_FRAME_ASDU')

function asdu:initialize(ctrl, unit, objects)
	self._ctrl = assert(ctrl, 'Ctrl is required!')
	self._unit = unit or asdu_unit:new()
	self._objects = objects or {}
end

function asdu:CTRL()
	return self._ctrl
end

function asdu:OI()
	return self._unit
end

function asdu:OBJS()
	return self._objects
end

function asdu:to_hex()
	local t = {}
	t[1] = self._unit:to_hex()
	for _, v in ipairs(self._objects) do
		t[#t + 1] = v:to_hex()
	end
	return table.concat(t)
end

function asdu:from_hex(raw, index)
	index = self._unit:from_hex(raw, index)
	self._objects = {}
	local vsq = self._unit:VSQ()
	for i = 1, vsq:COUNT() do
		local obj = asdu_object:new()
		index = obj:from_hex(raw, index)
		table.insert(self._objects, obj)
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
		objs = obj_tab,
	}
end

return asdu
