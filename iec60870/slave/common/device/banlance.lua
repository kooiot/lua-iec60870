local class = require 'middleclass'

local device = class('LUA_IEC60870_SLAVE_COMMON_DEVICE')

function device:initialize(addr)
	self._addr = addr
	self._data_snapshot = {}
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

-- TODO: should return asdu??
function device:poll_data()
	if self:has_spontaneous() then
		-- TODO: is this same as data list?
		return true, self:get_spontaneous()
	end

	if not self._data_snapshot then
		self._data_snapshot = self:get_snapshot()
	end
	assert(#self._data_snapshot > 0)

	local data_list = table.remove(self._data_snapshot, 1)
	if #self._data_snapshot > 0 then
		return true, data_list
	else
		self._data_snapshot = nil
		return false, data_list
	end
end

function device:get_class2()
	local data_c2 = self:get_class2_data()
	if self:has_spontaneous() then
		if data_c2 then
			return true, data_c2
		else
			local data_sp = self:get_spontaneous()
			return self:has_spontaneous(), data_sp
		end
	end
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
