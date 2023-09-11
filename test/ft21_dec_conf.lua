-- protocol configuration
--

local conf = {
	TIMEOUT				= 5000,		-- Request default timeout(ms)
	FRAME_NO_ADDR		= false,	-- Frame has no addr
	FRAME_ADDR_SIZE		= 1,		-- Frame addr size
	-- FRAME_ADDR_SIZE		= 2,		-- Frame addr size
	FT12_FIXED_LEN		= 0,		-- FIXED Frame FT1.2 ASDU length
	ADDR_SIZE			= 1,		-- ASDU Command addr size
	COT_SIZE			= 1,		-- ASDU cause of transfer
	OBJ_ADDR_SIZE		= 2,		-- ASDU ojbect address size
	MAX_RESEND			= 3,		-- Resend retry time (3~5)
	MAX_RESEND_TIME		= 10,		-- Resend retry time cycle (5-30) seconds
}

return conf
