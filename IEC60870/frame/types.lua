local _M = {}

--define constants
_M.M_SP_NA_1 = 1  
_M.M_SP_TA_1 = 2  
_M.M_DP_NA_1 = 3  
_M.M_DP_TA_1 = 4  
_M.M_ST_NA_1 = 5  
_M.M_ST_TA_1 = 6  
_M.M_BO_NA_1 = 7  
_M.M_BO_TA_1 = 8  
_M.M_ME_NA_1 = 9  
_M.M_ME_TA_1 = 10  
_M.M_ME_NB_1 = 11 
_M.M_ME_TB_1 = 12 
_M.M_ME_NC_1 = 13 
_M.M_ME_TC_1 = 14 
_M.M_IT_NA_1 = 15 
_M.M_IT_TA_1 = 16 
_M.M_EP_TA_1 = 17
_M.M_EP_TB_1 = 18
_M.M_EP_TC_1 = 19
_M.M_PS_NA_1 = 20 
_M.M_ME_ND_1 = 21 
_M.M_SP_TB_1 = 30 
_M.M_DP_TB_1 = 31 
_M.M_ST_TB_1 = 32 
_M.M_BO_TB_1 = 33 
_M.M_ME_TD_1 = 34 
_M.M_ME_TE_1 = 35 
_M.M_ME_TF_1 = 36 
_M.M_IT_TB_1 = 37 
_M.M_EP_TD_1 = 38 
_M.M_EP_TE_1 = 39 
_M.M_EP_TF_1 = 40 
_M.C_SC_NA_1 = 45 
_M.C_DC_NA_1 = 46 
_M.C_RC_NA_1 = 47 
_M.C_SE_NA_1 = 48 
_M.C_SE_NB_1 = 49 
_M.C_SE_NC_1 = 50 
_M.C_BO_NA_1 = 51 
_M.C_SC_TA_1 = 58 
_M.C_DC_TA_1 = 59 
_M.C_RC_TA_1 = 60 
_M.C_SE_TA_1 = 61 
_M.C_SE_TB_1 = 62 
_M.C_SE_TC_1 = 63 
_M.C_BO_TA_1 = 64 
_M.M_EI_NA_1 = 70 
_M.C_IC_NA_1 = 100
_M.C_CI_NA_1 = 101
_M.C_RD_NA_1 = 102
_M.C_CS_NA_1 = 103
_M.C_RP_NA_1 = 105
_M.C_TS_TA_1 = 107
_M.P_ME_NA_1 = 110
_M.P_ME_NB_1 = 111
_M.P_ME_NC_1 = 112
_M.P_AC_NA_1 = 113
_M.F_FR_NA_1 = 120
_M.F_SR_NA_1 = 121
_M.F_SC_NA_1 = 122
_M.F_LS_NA_1 = 123
_M.F_AF_NA_1 = 124
_M.F_SG_NA_1 = 125
_M.F_DR_TA_1 = 126
_M.F_SC_NB_1 = 127

--Type id description
_M.typeid_table = {
	[1  ] = "M_SP_NA_1  single-point information",
	[2  ] = "M_SP_TA_1  single-point information with time tag",
	[3  ] = "M_DP_NA_1  double-point information",
	[4  ] = "M_DP_TA_1  double-point information with time tag",
	[5  ] = "M_ST_NA_1  step position information",
	[6  ] = "M_ST_TA_1  step position information with time tag",
	[7  ] = "M_BO_NA_1  bitstring of 32 bits",
	[8  ] = "M_BO_TA_1  bitstring of 32 bits with time tag",
	[9  ] = "M_ME_NA_1  measured value, normalized value",
	[10 ] = "M_ME_TA_1  measured value, normalized value with time tag",
	[11 ] = "M_ME_NB_1  measured value, scaled value",
	[12 ] = "M_ME_TB_1  measured value, scaled value with time tag",
	[13 ] = "M_ME_NC_1  measured value, short floating point",
	[14 ] = "M_ME_TC_1  measured value, short floating point with time tag",
	[15 ] = "M_IT_NA_1  integrated totals",
	[16 ] = "M_IT_TA_1  integrated totals with time tag",
	[17 ] = "M_EP_TA_1  event of protection equipment with time tag",
	[18 ] = "M_EP_TB_1  packed start events of protection equipment with time tag",
	[19 ] = "M_EP_TC_1  packed output circuit information of protection equipment with time tag",
	[20 ] = "M_PS_NA_1  packed single-point information with status change detection",
	[21 ] = "M_ME_ND_1  measured value, normalized value without quality descriptor",
	[30 ] = "M_SP_TB_1  single-point information with time tag CP56Time2a",
	[31 ] = "M_DP_TB_1  double-point information with time tag CP56Time2a",
	[32 ] = "M_ST_TB_1  step position information with time tag CP56Time2a",
	[33 ] = "M_BO_TB_1  bitstring of 32 bit with time tag CP56Time2a",
	[34 ] = "M_ME_TD_1  measured value, normalized value with time tag CP56Time2a",
	[35 ] = "M_ME_TE_1  measured value, scaled value with time tag CP56Time2a",
	[36 ] = "M_ME_TF_1  measured value, short floating point with time tag CP56Time2a",
	[37 ] = "M_IT_TB_1  integrated totals with time tag CP56Time2a",
	[38 ] = "M_EP_TD_1  event of protection equipment with time tag CP56Time2a",
	[39 ] = "M_EP_TE_1  packed start events of protection equipment with time tag CP56Time2a",
	[40 ] = "M_EP_TF_1  packed output circuit information of protection equipment with time tag CP56Time2a",
	[45 ] = "C_SC_NA_1  single command",
	[46 ] = "C_DC_NA_1  double command",
	[47 ] = "C_RC_NA_1  regulating step command",
	[48 ] = "C_SE_NA_1  set point command, normalized value",
	[49 ] = "C_SE_NB_1  set point command, scaled value",
	[50 ] = "C_SE_NC_1  set point command, short floating point number",
	[51 ] = "C_BO_NA_1  bitstring of 32 bits",
	[58 ] = "C_SC_TA_1  single command with time tag CP56Time2a",
	[59 ] = "C_DC_TA_1  double command with time tag CP56Time2a",
	[60 ] = "C_RC_TA_1  regulating step command with time tag CP56Time2a",
	[61 ] = "C_SE_TA_1  set point command, normalized value with time tag CP56Time2a",
	[62 ] = "C_SE_TB_1  set point command, scaled value with time tag CP56Time2a",
	[63 ] = "C_SE_TC_1  set point command, short floating-point with time tag CP56Time2a",
	[64 ] = "C_BO_TA_1  bitstring of 32 bits with time tag CP56Time2a",
	[70 ] = "M_EI_NA_1  end of initialization",
	[100] = "C_IC_NA_1  interrogation command",
	[101] = "C_CI_NA_1  counter interrogation command",
	[102] = "C_RD_NA_1  read command",
	[103] = "C_CS_NA_1  clock synchronization command",
	[105] = "C_RP_NA_1  reset process command",
	[107] = "C_TS_TA_1  test command with time tag CP56Time2a",
	[110] = "P_ME_NA_1  parameter of measured value, normalized value",
	[111] = "P_ME_NB_1  parameter of measured value, scaled value",
	[112] = "P_ME_NC_1  parameter of measured value, short floating-point number",
	[113] = "P_AC_NA_1  parameter activation",
	[120] = "F_FR_NA_1  file ready",
	[121] = "F_SR_NA_1  section ready",
	[122] = "F_SC_NA_1  call directory, select file, call file, call section",
	[123] = "F_LS_NA_1  last section, last segment",
	[124] = "F_AF_NA_1  ack file, ack section",
	[125] = "F_SG_NA_1  segment",
	[126] = "F_DR_TA_1  directory",
	[127] = "F_SC_NB_1  Query Log - Request archive file",

}

_M.typeid2_table = {
	[1  ] = "M_SP_NA_1",
	[2  ] = "M_SP_TA_1",
	[3  ] = "M_DP_NA_1",
	[4  ] = "M_DP_TA_1",
	[5  ] = "M_ST_NA_1",
	[6  ] = "M_ST_TA_1",
	[7  ] = "M_BO_NA_1",
	[8  ] = "M_BO_TA_1",
	[9  ] = "M_ME_NA_1",
	[10 ] = "M_ME_TA_1",
	[11 ] = "M_ME_NB_1",
	[12 ] = "M_ME_TB_1",
	[13 ] = "M_ME_NC_1",
	[14 ] = "M_ME_TC_1",
	[15 ] = "M_IT_NA_1",
	[16 ] = "M_IT_TA_1",
	[17 ] = "M_EP_TA_1",
	[18 ] = "M_EP_TB_1",
	[19 ] = "M_EP_TC_1",
	[20 ] = "M_PS_NA_1",
	[21 ] = "M_ME_ND_1",
	[30 ] = "M_SP_TB_1",
	[31 ] = "M_DP_TB_1",
	[32 ] = "M_ST_TB_1",
	[33 ] = "M_BO_TB_1",
	[34 ] = "M_ME_TD_1",
	[35 ] = "M_ME_TE_1",
	[36 ] = "M_ME_TF_1",
	[37 ] = "M_IT_TB_1",
	[38 ] = "M_EP_TD_1",
	[39 ] = "M_EP_TE_1",
	[40 ] = "M_EP_TF_1",
	[45 ] = "C_SC_NA_1",
	[46 ] = "C_DC_NA_1",
	[47 ] = "C_RC_NA_1",
	[48 ] = "C_SE_NA_1",
	[49 ] = "C_SE_NB_1",
	[50 ] = "C_SE_NC_1",
	[51 ] = "C_BO_NA_1",
	[58 ] = "C_SC_TA_1",
	[59 ] = "C_DC_TA_1",
	[60 ] = "C_RC_TA_1",
	[61 ] = "C_SE_TA_1",
	[62 ] = "C_SE_TB_1",
	[63 ] = "C_SE_TC_1",
	[64 ] = "C_BO_TA_1",
	[70 ] = "M_EI_NA_1",
	[100] = "C_IC_NA_1",
	[101] = "C_CI_NA_1",
	[102] = "C_RD_NA_1",
	[103] = "C_CS_NA_1",
	[105] = "C_RP_NA_1",
	[107] = "C_TS_TA_1",
	[110] = "P_ME_NA_1",
	[111] = "P_ME_NB_1",
	[112] = "P_ME_NC_1",
	[113] = "P_AC_NA_1",
	[120] = "F_FR_NA_1",
	[121] = "F_SR_NA_1",
	[122] = "F_SC_NA_1",
	[123] = "F_LS_NA_1",
	[124] = "F_AF_NA_1",
	[125] = "F_SG_NA_1",
	[126] = "F_DR_TA_1",
	[127] = "F_SC_NB_1",

}
--Type id object length
_M.asdu_obj_len_table = {
	[1  ] = 1  ,    --M_SP_NA_1
	[2  ] = 4  ,    --M_SP_TA_1
	[3  ] = 1  ,    --M_DP_NA_1
	[4  ] = 4  ,    --M_DP_TA_1
	[5  ] = 2  ,    --M_ST_NA_1
	[6  ] = 5  ,    --M_ST_TA_1
	[7  ] = 5  ,    --M_BO_NA_1
	[8  ] = 8  ,    --M_BO_TA_1
	[9  ] = 3  ,    --M_ME_NA_1
	[10 ] = 6  ,    --M_ME_TA_1
	[11 ] = 3  ,    --M_ME_NB_1
	[12 ] = 6  ,    --M_ME_TB_1
	[13 ] = 5  ,    --M_ME_NC_1
	[14 ] = 8  ,    --M_ME_TC_1
	[15 ] = 5  ,    --M_IT_NA_1
	[16 ] = 8  ,    --M_IT_TA_1
	[17 ] = 6  ,    --M_EP_TA_1
	[18 ] = 7  ,    --M_EP_TB_1
	[19 ] = 7  ,    --M_EP_TC_1
	[20 ] = 5  ,    --M_PS_NA_1
	[21 ] = 2  ,    --M_ME_ND_1
	[30 ] = 8  ,    --M_SP_TB_1
	[31 ] = 8  ,    --M_DP_TB_1
	[32 ] = 9  ,    --M_ST_TB_1
	[33 ] = 12 ,   	--M_BO_TB_1
	[34 ] = 10 ,   	--M_ME_TD_1
	[35 ] = 10 ,   	--M_ME_TE_1
	[36 ] = 12 ,   	--M_ME_TF_1
	[37 ] = 12 ,   	--M_IT_TB_1
	[38 ] = 10 ,  	--M_EP_TD_1
	[39 ] = 11 ,  	--M_EP_TE_1
	[40 ] = 11 ,  	--M_EP_TF_1
	[45 ] = 1  ,   	--C_SC_NA_1
	[46 ] = 1  ,   	--C_DC_NA_1
	[47 ] = 1  ,   	--C_RC_NA_1
	[48 ] = 3  ,   	--C_SE_NA_1
	[49 ] = 3  ,   	--C_SE_NB_1
	[50 ] = 5  ,   	--C_SE_NC_1
	[51 ] = 4  ,  	--C_BO_NA_1
	[58 ] = 8  ,  	--C_SC_TA_1
	[59 ] = 8  , 	--C_DC_TA_1
	[60 ] = 8  ,  	--C_RC_TA_1
	[61 ] = 10 ,  	--C_SE_TA_1
	[62 ] = 10 ,  	--C_SE_TB_1
	[63 ] = 12 ,  	--C_SE_TC_1
	[64 ] = 11 ,  	--C_BO_TA_1
	[70 ] = 1  , 	--M_EI_NA_1
	[100] = 1  ,  	--C_IC_NA_1
	[101] = 1  , 	--C_CI_NA_1
	[102] = 0  ,  	--C_RD_NA_1
	[103] = 7  , 	--C_CS_NA_1
	[105] = 1  ,  	--C_RP_NA_1
	[107] = 9  , 	--C_TS_TA_1
	[110] = 3  ,  	--P_ME_NA_1
	[111] = 3  , 	--P_ME_NB_1
	[112] = 5  ,  	--P_ME_NC_1
	[113] = 1  , 	--P_AC_NA_1
	[120] = 6  ,  	--F_FR_NA_1
	[121] = 7  , 	--F_SR_NA_1
	[122] = 4  ,  	--F_SC_NA_1
	[123] = 5  , 	--F_LS_NA_1
	[124] = 4  ,  	--F_AF_NA_1
	[125] = 0  , 	--F_SG_NA_1
	[126] = 13 ,  	--F_DR_TA_1
	[127] = 16 ,  	--F_SC_NB_1
}

--Cause of transfer
_M.cot_table = {
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

_M.prm1_func_table = {
	[0]   = "Rst Remote link. SEND/CFM expt",
	[1]   = "Rst user process. SEND/CFM expt",
	[2]   = "Reserved. SEND/CFM expt",
	[3]   = "Class 2 available. SEND/CFM expt",
	[4]   = "Class 2 available. SEND/NO REPLY expt",
	[5]   = "Reserved",
	[6]   = "Reserved",
	[7]   = "Reserved",
	[8]   = "expt response specifies access demand. REQUEST for access demand",
	[9]   = "Request status of link. REQUEST/RESPOND expt",
	[10]  = "Request class 1. REQUEST/RESPOND expt",
	[11]  = "Request class 2. REQUEST/RESPOND expt",
	[12]  = "Reserved",
	[13]  = "Reserved",
	[14]  = "Reserved",
	[15]  = "Reserved",
}

_M.prm0_func_table = {
	[0]   = "ACK:positive ack. CFM",
	[1]   = "NACK:message not accepted, link busy. CFM",
	[2]   = "Reserved",
	[3]   = "Reserved",
	[4]   = "Reserved",
	[5]   = "Reserved",
	[6]   = "Reserved",
	[7]   = "Reserved",
	[8]   = "Class 2 available. RESPOND",
	[9]   = "NACK:requested data not available. RESPOND",
	[10]  = "Reserved",
	[11]  = "Status of link or access demand. RESPOND",
	[12]  = "Reserved",
	[13]  = "Reserved",
	[14]  = "Link service not functioning",
	[15]  = "Link service not implemented",

}
_M.valid_table = {
	[0 ] = "Valid",
	[1 ] = "Invalid"
}

_M.spi_str_table = {
	[0] = "OFF",
	[1] = "ON"
}

_M.dpi_str_table = {
	[0] = "Indeterminate/intermediate",
	[1] = "OFF",
	[2] = "ON",
	[3] = "Indeterminate"
}

_M.se_table = {
	[0 ] = "Execute",
	[1 ] = "Select"
}

_M.qu_table = {
	[0] = "No additional definition",
	[1] = "Short pulse duration",
	[2] = "Long pulse duration",
	[3] = "Persistent"
}

_M.dco_table = {
	[0] = "Not permitted",
	[1] = "OFF",
	[2] = "ON",
	[3] = "Not permitted"
}

_M.month_table = {
	[1] = "Jan",
	[2] = "Feb",
	[3] = "Mar",
	[4] = "Apr",
	[5] = "May",
	[6] = "Jun",
	[7] = "Jul",
	[8] = "Aug",
	[9] = "Sep",
	[10] = "Oct",
	[11] = "Nov",
	[12] = "Dec",
}

_M.dayofweek_table = {
	[0]  = "Day of Week-ERR",
	[1]  = "Mon",
	[2]  = "Tue",
	[3]  = "Wed",
	[4]  = "Thu",
	[5]  = "Fri",
	[6]  = "Sat",
	[7]  = "Sun",

}

_M.qds_ov_table = {
	[0 ] = ".... ...0 Not oeverflow",
	[1 ] = ".... ...1 Overflow"
}

_M.qds_bl_table = {
	[0 ] = "...0 .... Not blocked",
	[1 ] = "...1 .... Blocked"
}

_M.qds_sb_table = {
	[0 ] = "..0. .... Not substituted",
	[1 ] = "..1. .... Substituted"
}

_M.qds_nt_table = {
	[0 ] = ".0.. .... Topical",
	[1 ] = ".1.. .... Not topical"
}

_M.qds_iv_table = {
	[0 ] = "0... .... Valid",
	[1 ] = "1... .... Invalid"
}

_M.cot_pos_neg_table = {
	[0 ] = "Positive",
	[1 ] = "Negative"
}

_M.cot_test_table = {
	[0 ] = "No test",
	[1 ] = "Test"
}

_M.qoi_table = {
	[0 ] = "Not used",
	[1 ] = "Reserved",
	[2 ] = "Reserved",
	[3 ] = "Reserved",
	[4 ] = "Reserved",
	[5 ] = "Reserved",
	[6 ] = "Reserved",
	[7 ] = "Reserved",
	[8 ] = "Reserved",
	[9 ] = "Reserved",
	[10] = "Reserved",
	[11] = "Reserved",
	[12] = "Reserved",
	[13] = "Reserved",
	[14] = "Reserved",
	[15] = "Reserved",
	[16] = "Reserved",
	[17] = "Reserved",
	[18] = "Reserved",
	[19] = "Reserved",
	[20] = "Station interrogation(global)",
	[21] = "interrogation of group 1 ",
	[22] = "interrogation of group 2 ",
	[23] = "interrogation of group 3 ",
	[24] = "interrogation of group 4 ",
	[25] = "interrogation of group 5 ",
	[26] = "interrogation of group 6 ",
	[27] = "interrogation of group 7 ",
	[28] = "interrogation of group 8 ",
	[29] = "interrogation of group 9 ",
	[30] = "interrogation of group 10",
	[31] = "interrogation of group 11",
	[32] = "interrogation of group 12",
	[33] = "interrogation of group 13",
	[34] = "interrogation of group 14",
	[35] = "interrogation of group 15",
	[36] = "interrogation of group 16",
	[37] = "Reserved",
	[38] = "Reserved",
	[39] = "Reserved",
	[40] = "Reserved",
	[41] = "Reserved",
}

_M.qcc_request_table = {
	[0] = "No counter request(not used)",
	[1] = "request couter group 1",
	[2] = "request couter group 2",
	[3] = "request couter group 3",
	[4] = "request couter group 4",
	[5] = "general reqeust counter",
	[6] = "reserved"
}

--counter
_M.qcc_freeze_table = {
	[0] = "read(no freeze or reset)",
	[1] = "counter freeze without reset(value frozen represents integrated total)",
	[2] = "counter freeze with reset(value frozen represents incremental information)",
	[3] = "counter reset"
}

--Binary counter reading
_M.bcr_carry_table = {
	[0] = "no counter overflow occurred in the corresponding integration period",
	[1] = "counter overflow occurred in the corresponding integration period"
}

_M.bcr_ca_table = {
	[0] = "counter was not adjusted since last reading",
	[1] = "counter was adjusted since last reading"
}

_M.bcr_iv_table = {
	[0] = "counter reading is valid",
	[1] = "counter reading is invalid"
}

return _M
