#! /usr/bin/env lua5.4

local basexx = require 'basexx'
local apdu = require 'iec60870.frame.apdu'
local conf = require 'iec60870.conf'
local lconf = require 'apdu_dec_conf'

for k, v in pairs(conf) do
	if lconf[k] then
		conf[k] = lconf[k]
	end
end

local args = {...}
local str = table.concat(args)

str = string.gsub(str, ' ', '')

print('SRC:', str)
print('SRC len:', string.len(str))

local raw = basexx.from_hex(str)

local frame = apdu:new()

local r, next_index, err = frame:valid_hex(raw, 1)
if not r then
	print(next_index, err)
else
	frame:from_hex(raw, 1)
	print(frame)
end
