local class = require 'middleclass'
local logger = require 'iec60870.logger'

local linker = class('LUA_IEC60870_MASTER_LINKER')

function linker:initialize(channel)
	self._channel = channel
	self._requests = {}
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

function linker:on_recv(raw)
	return self._channel:on_recv(raw)
end

return linker
