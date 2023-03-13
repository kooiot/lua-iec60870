local class = require 'middleclass'
local logger = require 'iec60870.logger'

local linker = class('LUA_IEC60870_MASTER_LINKER')

function linker:initialize()
	self._recv = nil
end

function linker:open()
	assert(false, 'Not implemented!')
end

function linker:close()
	assert(false, 'Not implemented!')
end

function linker:send(raw)
	assert(false, 'Not implemented!')
end

function linker:bind_recv(recv)
	self._recv = recv
end

function linker:on_recv(raw)
	if not self._recv then
		logger.error('Linker has not recv function')
		return
	end
	return self._recv(raw)
end

return linker
