local t = require 'iec60870.types'
local conf = require 'iec60870.conf'

local TIME_NULL = function(data)
	return conf.time()
end

local IV_NULL = function(data)
	return 0
end

local TIME2 = function(data)
	if data[2] and data[2].timestamp then
		return data[2]:timestamp()
	else
		assert(false, 'This data cannot adapt TIME2 getter')
	end
end

local TIME3 = function(data)
	if data[3] and data[3].timestamp then
		return data[3]:timestamp()
	else
		assert(false, 'This data cannot adapt TIME3 getter')
	end
end

local TIME4 = function(data)
	if data[4] and data[4].timestamp then
		return data[4]:timestamp()
	else
		assert(false, 'This data cannot adapt TIME4 getter')
	end
end

local IV = function(data)
	if data.IV then
		return data:IV()
	elseif data[1] and data[1].IV then
		return data[1]:IV()
	else
		assert(false, 'This data cannot adapt IV getter')
	end
end

local IV2 = function(data)
	if data[2] and data[2].IV then
		return data[2]:IV()
	else
		assert(false, 'This data cannot adapt IV2 getter')
	end
end

-- 1: object name or objects name list
-- 2: IV getter
-- 3: Timestamp getter
local _M = {
	[t.M_SP_NA_1] = { 'SIQ', IV, TIME_NULL },
	[t.M_SP_TA_1] = { { 'SIQ', 'CP24Time2a' }, IV, TIME2 },
	[t.M_DP_NA_1] = { 'DIQ', IV, TIME_NULL },
	[t.M_DP_TA_1] = { { 'DIQ', 'CP24Time2a' }, IV, TIME2 },
	[t.M_ST_NA_1] = { { 'VTI', 'QDS' }, IV2, TIME_NULL },
	[t.M_ST_TA_1] = { { 'VTI', 'QDS', 'CP24Time2a' }, IV2, TIME3 },
	[t.M_BO_NA_1] = { { 'BSI', 'QDS' }, IV2, TIME_NULL },
	[t.M_BO_TA_1] = { { 'BSI', 'QDS', 'CP24Time2a' }, IV2, TIME3 },
	[t.M_ME_NA_1] = { { 'NVA', 'QDS' }, IV2, TIME_NULL },
	[t.M_ME_TA_1] = { { 'NVA', 'QDS', 'CP24Time2a' }, IV2, TIME3 },
	[t.M_ME_NB_1] = { { 'SVA', 'QDS' }, IV2, TIME_NULL },
	[t.M_ME_TB_1] = { { 'SVA', 'QDS', 'CP24Time2a' }, IV2, TIME3 },
	[t.M_ME_NC_1] = { { 'R32', 'QDS' }, IV2, TIME_NULL },
	[t.M_ME_TC_1] = { { 'R32', 'QDS', 'CP24Time2a' }, IV2, TIME3 },
	[t.M_IT_NA_1] = { 'BCR', IV, TIME_NULL },
	[t.M_IT_TA_1] = { { 'BCR', 'CP24Time2a' }, IV, TIME2 },
	[t.M_EP_TA_1] = { { 'SEP', 'CP16Time2a', 'CP24Time2a' }, IV, TIME3 },
	[t.M_EP_TB_1] = { { 'SPE', 'QDP', 'CP16Time2a', 'CP24Time2a' }, IV2, TIME4 },
	[t.M_EP_TC_1] = { { 'OCI', 'QDP', 'CP16Time2a', 'CP24Time2a' }, IV2, TIME4 },
	[t.M_PS_NA_1] = { { 'SCD', 'QDS' }, IV2, TIME_NULL },
	[t.M_ME_ND_1] = { 'NVA', IV_NULL, TIME_NULL },
	[t.M_SP_TB_1] = { { 'SIQ', 'CP56Time2a' }, IV, TIME2 },
	[t.M_DP_TB_1] = { { 'DIQ', 'CP56Time2a' }, IV, TIME2 },
	[t.M_ST_TB_1] = { { 'VTI', 'QDS', 'CP56Time2a' }, IV2, TIME3 },
	[t.M_BO_TB_1] = { { 'BSI', 'QDS', 'CP56Time2a' }, IV2, TIME3 },
	[t.M_ME_TD_1] = { { 'NVA', 'QDS', 'CP56Time2a' }, IV2, TIME3 },
	[t.M_ME_TE_1] = { { 'SVA', 'QDS', 'CP56Time2a' }, IV2, TIME3 },
	[t.M_ME_TF_1] = { { 'R32', 'QDS', 'CP56Time2a' }, IV2, TIME3 },
	[t.M_IT_TB_1] = { { 'BCR', 'CP56Time2a' }, IV, TIME2 },
	[t.M_EP_TD_1] = { { 'SEP', 'CP16Time2a', 'CP56Time2a' }, IV, TIME3 },
	[t.M_EP_TE_1] = { { 'SPE', 'QDP', 'CP16Time2a', 'CP56Time2a' }, IV2, TIME4 },
	[t.M_EP_TF_1] = { { 'OCI', 'QDP', 'CP16Time2a', 'CP56Time2a' }, IV2, TIME4 },

	[t.C_SC_NA_1] = { 'SCO', IV_NULL, TIME_NULL },
	[t.C_DC_NA_1] = { 'DCO', IV_NULL, TIME_NULL },
	[t.C_RC_NA_1] = { 'RCO', IV_NULL, TIME_NULL },
	[t.C_SE_NA_1] = { { 'NVA', 'QOS' }, IV_NULL, TIME_NULL },
	[t.C_SE_NB_1] = { { 'SVA', 'QOS' }, IV_NULL, TIME_NULL },
	[t.C_SE_NC_1] = { { 'R32', 'QOS' }, IV_NULL, TIME_NULL },
	[t.C_BO_NA_1] = { 'BSI', IV_NULL, TIME_NULL },
	[t.C_SC_TA_1] = { { 'SCO', 'CP56Time2a' }, IV_NULL, TIME_2 },
	[t.C_DC_TA_1] = { { 'DCO', 'CP56Time2a' }, IV_NULL, TIME_2 },
	[t.C_RC_TA_1] = { { 'RCO', 'CP56Time2a' }, IV_NULL, TIME_2 },
	[t.C_SE_TA_1] = { { 'NVA', 'QOS', 'CP56Time2a' }, IV_NULL, TIME_3 },
	[t.C_SE_TB_1] = { { 'SVA', 'QOS', 'CP56Time2a' }, IV_NULL, TIME_3 },
	[t.C_SE_TC_1] = { { 'R32', 'QOS', 'CP56Time2a' }, IV_NULL, TIME_3 },
	[t.C_BO_TA_1] = { { 'BSI', 'CP56Time2a' }, IV_NULL, TIME_2 },

	[t.M_EI_NA_1] = { 'COI', IV_NULL, TIME_NULL },

	[t.C_IC_NA_1] = { 'QOI', IV_NULL, TIME_NULL },
	[t.C_CI_NA_1] = { 'QCC', IV_NULL, TIME_NULL },
	[t.C_RD_NA_1] = { '', IV_NULL, TIME_NULL },
	[t.C_CS_NA_1] = { 'CP56Time2a', IV_NULL, TIME_NULL },
	[t.C_TS_NA_1] = { 'FBP', IV_NULL, TIME_NULL },
	[t.C_RP_NA_1] = { 'GRP', IV_NULL, TIME_NULL },
	[t.C_CD_NA_1] = { 'CP16Time2a', IV_NULL, TIME_NULL },

	[t.P_ME_NA_1] = { { 'NVA', 'QPM' }, IV_NULL, TIME_NULL },
	[t.P_ME_NB_1] = { { 'SVA', 'QPM' }, IV_NULL, TIME_NULL },
	[t.P_ME_NC_1] = { { 'R32', 'QPM' }, IV_NULL, TIME_NULL },
	[t.P_AC_NA_1] = { 'QPA', IV_NULL, TIME_NULL },

	[t.F_FR_NA_1] = { { 'NOF', 'LOF', 'FRQ' }, IV_NULL, TIME_NULL },
	[t.F_SR_NA_1] = { { 'NOF', 'NOS', 'LOF', 'SRQ' }, IV_NULL, TIME_NULL },
	[t.F_SC_NA_1] = { { 'NOF', 'NOS', 'SCQ' }, IV_NULL, TIME_NULL },
	[t.F_LS_NA_1] = { { 'NOF', 'NOS', 'LSQ', 'CHS' }, IV_NULL, TIME_NULL },
	[t.F_AF_NA_1] = { { 'NOF', 'NOS', 'AFQ' }, IV_NULL, TIME_NULL },
	[t.F_SG_NA_1] = { 'FILE', IV_NULL, TIME_NULL },
	[t.F_DR_TA_1] = { { 'NOF', 'LOF', 'CP56Time2a' }, IV_NULL, TIME3 },
	[t.F_SC_NB_1] = { { 'NOF', 'CP56Time2a', 'CP56Time2a' }, IV_NULL, TIME_NULL },
}
