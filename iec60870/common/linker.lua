local class = require 'middleclass'
local logger = require 'iec60870.common.logger'

local linker = class('LUA_COMMON_LINKER')

function linker:initialize()
	self._recv = nil
	self._connected = false
	self._listen_map = {}
end

function linker:connected()
	return self._connected
end

function linker:open()
	assert(false, 'Not implemented!')
end

function linker:close()
	assert(false, 'Not implemented!')
end

function linker:reset()
	assert(false, 'Not implemented!')
end

function linker:send(raw)
	assert(false, 'Not implemented!')
end

function linker:dump_key()
	assert(false, 'Not implemented!')
end

function linker:bind_recv(recv)
	self._recv = recv
end

function linker:on_recv(raw)
	if not self._recv then
		logger.error('Linker has no recv function')
		return
	end
	return self._recv(raw)
end

function linker:bind_listen(key, listen)
	self._listen_map[key] = listen
	if self._connected then
		listen.on_connected(key, self)
	end
end

function linker:on_connected()
	logger.info('Linker connected...')
	self._connected = true
	for key, listen in pairs(self._listen_map) do
		listen.on_connected(key, self)
	end
end

function linker:on_disconnected()
	logger.warning('Linker disconnected!!!')
	self._connected = false
	for key, listen in pairs(self._listen_map) do
		listen.on_disconnected(key, self)
	end
end

return linker
