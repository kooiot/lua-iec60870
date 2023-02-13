local t = require 'ice60870.types'

local _M = {
	[t.M_SP_NA_1] = { 'SIQ' },
	[t.M_SP_TA_1] = { 'SIQ', 'CP24Time2a' },
	[t.M_DP_NA_1] = { 'DIQ' },
	[t.M_DP_TA_1] = { 'DIQ', 'CP24Time2a' },
	[t.M_ST_NA_1] = { 'VTI', '', 'QDS' },
	[t.M_ST_TA_1] = { 'DIQ', 'CP24Time2a', 'QDS' },
}
