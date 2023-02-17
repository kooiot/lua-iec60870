-- protocol configuration
--

local conf = {
	TIMEOUT				= 5000,		-- Request default timeout
	FRAME_NO_ADDR		= false,	-- Frame has no addr
	FT12_FIXED_LEN		= 0,		-- FIXED Frame FT1.2 ASDU length
	ASDU_COT_SIZE		= 1,		-- cause of transfer
	ASDU_CAOA_SIZE		= 2,		-- common address of ASDU
	ASDU_ADDR_LEN		= 2,		-- ojbect address size
}

conf.time = function()
	return os.time() * 1000
end

return conf
