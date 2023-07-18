local class = require 'middleclass'

local device = class('LUA_IEC60870_SLAVE_COMMON_DEVICE')

function device:initialize(addr)
	self._addr = addr
	self._first_class1 = true
	self._data_snapshot = {}
	self._data_snapshot_cur = nil
end

function device:on_disconnected()
end

function device:on_connected()
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
	-- If not first poll class1
	if not self._first_class1 or not self._data_snapshot then
		if self:has_spontaneous() then
			-- TODO: is this same as data list?
			return true, self:get_spontaneous()
		end
		return false, nil -- what happen here???
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

	if #self._data_snapshot < self._data_snapshot_cur then
		self._data_snaphost = nil
		self._data_snapshot_cur = 0
		-- For termination COT=10
		self._first_class1 = false
		return false, asdu
	else
		local data_list = self._data_snapshot[self._data_snapshot_cur]
		self._data_snapshot_cur = self._data_snapshot_cur + 1
		return true, asdu
	end
end

function device:poll_class2()
	local data_c2 = self:get_class2_data()
	if self:has_spontaneous() then
		if data_c2 then
			-- TODO: make asdu
			return true, data_c2
		else
			local data_sp = self:get_spontaneous()
			-- TODO: make asdu
			return self:has_spontaneous(), data_sp
		end
	end
	-- TODO: make asdu
	return false, data_c2
end

function device:on_run()
	if self:has_spontaneous() then
		local data_sp = self:get_spontaneous()
		local cos = data_sp:COS()
		-- Fire cos first then SOE
		-- self:send(cos)
		local soe = data_sp:SOE()
		-- self:send(soe)
		-- Wait for confirmation
	end
end

return device
