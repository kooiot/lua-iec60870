-- protocol configuration
--

local conf = {
	FRAME_NO_ADDR	= false,	-- Frame has no addr
	ADDR_LEN		= 2,		-- Address size
	FT12_FIXED_LEN	= 0,		-- FIXED Frame FT1.2 ASDU length
	ASDU_COT_SIZE	= 1,		-- cause of transfer
	ASDU_CAOA_SIZE	= 1,		-- common address of ASDU
}

return conf
