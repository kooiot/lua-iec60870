local base = require 'iec60870.frame.base'
local conf = require 'iec60870.conf'

local cot = base:subclass('LUA_IEC60870_FRAME_COT')

--Cause of transfer
cot.static.TB_DESC = {
	[1 ] = "Period, Cyclic",
	[2 ] = "Backgroud scan",
	[3 ] = "Spontaneous",
	[4 ] = "Initialised",
	[5 ] = "Request or requested",
	[6 ] = "Activation",
	[7 ] = "Activation confirm",
	[8 ] = "Deactivation",
	[9 ] = "Deactivation confirm",
	[10] = "Activation termination",
	[11] = "Return information caused by a remote command",
	[12] = "Return information caused by a local command",
	[13] = "File transfer",
	[20] = "Interrogated by general interrogation",
	[21] = "Interrogated by group 1 interrogation",
	[22] = "Interrogated by group 2 interrogation",
	[23] = "Interrogated by group 3 interrogation",
	[24] = "Interrogated by group 4 interrogation",
	[25] = "Interrogated by group 5 interrogation",
	[26] = "Interrogated by group 6 interrogation",
	[27] = "Interrogated by group 7 interrogation",
	[28] = "Interrogated by group 8 interrogation",
	[29] = "Interrogated by group 9 interrogation",
	[30] = "Interrogated by group 10 interrogation",
	[31] = "Interrogated by group 11 interrogation",
	[32] = "Interrogated by group 12 interrogation",
	[33] = "Interrogated by group 13 interrogation",
	[34] = "Interrogated by group 14 interrogation",
	[35] = "Interrogated by group 15 interrogation",
	[36] = "Interrogated by group 16 interrogation",
	[37] = "Requested by gener counter request",
	[38] = "Requested by group 1 counter request",
	[39] = "Requested by group 2 counter request",
	[40] = "Requested by group 3 counter request",
	[41] = "Requested by group 4 counter request",
	[44] = "Unknown type identification",
	[45] = "Unknown cause of transfer",
	[46] = "Unknown common address of ASDU",
	[47] = "Unknown infomation object address",
}

function cot:initialize(cause, pn, t, addr)
	self._cause = cause or -1
	self._pn = pn or 0
	self._t = t or 0
	self._addr = addr or 0
end

function cot:CAUSE()
	return self._cause
end

function cot:PN()
	return self._pn
end

function cot:T()
	return self._t
end

function cot:ADDR()
	return self._addr
end

function cot:to_hex()
	local cause = ((self._t & 0x1) << 7) + ((self._pn & 0x1) << 6) + (self._cause & 0x3F)
	if conf.COT_SIZE == 1 then
		return string.char(cause & 0xFF)
	else
		return string.char(cause & 0xFF)..string.char(self._addr & 0xFF)
	end
end

function cot:from_hex(raw, index)
	if conf.COT_SIZE == 1 then
		local c = string.byte(raw, index)
		self._cause = c & 0x3F
		self._pn = (c >> 6) & 0x1
		self._t = (c >> 7) & 0x1
		self._addr = nil
		return index + 1
	else
		local c = string.byte(raw, index)
		self._cause = c & 0x3F
		self._pn = (c >> 6) & 0x1
		self._t = (c >> 7) & 0x1
		self._addr = string.byte(raw, index + 1)
		return index + 2
	end
end

function cot:__totable()
	local desc = cot.static.TB_DESC[self._cause] or 'Unknown Cause'
	if conf.COT_SIZE == 1 then
		return {
			name = 'Cause of Transfer',
			cause = desc,
		}
	else
		return {
			name = 'Cause of Transfer',
			cause = desc,
			addr = self._addr
		}
	end
end

return cot
