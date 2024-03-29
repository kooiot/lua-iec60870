-- protocol configuration
--

local conf = {
	TIMEOUT				= 5000,		-- Request default timeout(ms)
	FRAME_NO_ADDR		= false,	-- Frame has no addr
	FRAME_ADDR_SIZE		= 2,		-- Frame addr size (Link layer adress)
	FT12_FIXED_LEN		= 0,		-- FIXED Frame FT1.2 ASDU length
	ADDR_SIZE			= 2,		-- ASDU Command addr size (CA - Common address size)
	COT_SIZE			= 1,		-- ASDU cause of transfer (COT - )
	OBJ_ADDR_SIZE		= 2,		-- ASDU ojbect address size (IOA - information object address size)
	MAX_RESEND			= 3,		-- Resend retry time (3~5)
	MAX_RESEND_TIME		= 10,		-- Resend retry time cycle (5-30) seconds
	T0					= 30,		-- In second (Connection timeout)
	T1					= 15,		-- In second (Send or test APDU timeout)
	T2					= 10,		-- In second (No data frame ack timeout, T2 < T1)
	T3					= 20,		-- In second (No data frame test timeout)
}

return conf
