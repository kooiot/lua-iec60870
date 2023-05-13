local class = require 'middleclass'
local helper = require 'iec60870.frame.helper'

local base = class('LUA_IEC60870_FRAME_BASE')

function base:initialize()
end

-- return next raw index
function base:from_hex(raw, index)
	assert(false, 'Not implemented')
	return index
end

-- return raw string
function base:to_hex()
	assert(false, "not implemented")
	return ''
end

function base:__totable()
	return "Not implemented"
end

function base:__tostring()
	return helper.tostring(self:__totable())
end

return base
