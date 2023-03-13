-- protocol configuration
--

local conf = {
	TIMEOUT				= 5000,		-- Request default timeout(ms)
	FRAME_NO_ADDR		= false,	-- Frame has no addr
	FT12_FIXED_LEN		= 0,		-- FIXED Frame FT1.2 ASDU length
	ASDU_COT_SIZE		= 1,		-- cause of transfer
	ASDU_CAOA_SIZE		= 2,		-- common address of ASDU
	ASDU_OBJ_ADDR_SIZE	= 2,		-- ojbect address size
	MAX_RESEND			= 3,		-- Resend retry time (3~5)
	MAX_RESEND_TIME		= 10,		-- Resend retry time cycle (5-30) seconds
}

return conf
