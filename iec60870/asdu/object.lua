local class = require 'middleclass'

local object = class('LUA_IEC60870_FRAME_OBJECT')

object.static.DIR_R		= 0 -- 保留 (用于非平衡传输)
object.static.DIR_M		= 0 -- 主站 (平衡传输)
object.static.DIR_S		= 1 -- 终端 (平衡传输)
object.static.PRM_REQ		= 1 -- 启动站
object.static.PRM_RESP	= 0 -- 从动站

object.static.FC_RST_LINK		= 0 -- 复位远方链路
object.static.FC_RST_PROC		= 1 -- 复位用户进程
object.static.FC_LINK_TEST	= 2 -- 发送/确认链路测试功能 --- 平衡链路
object.static.FC_DATA			= 3 -- 发送/确认用户数据
object.static.FC_DATA_NK		= 4 -- 发送/无回答用户数据
object.static.FC_ACC			= 8 -- 访问请求 (响应链路状态) --- 非平衡链路
object.static.FC_LINK			= 9 -- 请求/响应请求链路状态 (响应链路状态)
object.static.FC_EM1_DATA		= 10 -- 请求/响应请求1级用户数据 --- 非平衡链路
object.static.FC_EM2_DATA		= 11 -- 请求/响应请求2级用户数据 --- 非平衡链路

function object:initialize(oi, data, tm)
	self._oi = oi
	self._data = data
	self._tm = tm
end

function object:OI()
	return self._oi
end

function object:DATA()
	return self._data
end

function object:TM()
	return self._tm
end

function object:to_hex()
	return string.char(self._ti)..string.char(_vsq)..string.char(self._cot)..string.
end

function object:from_hex(raw, index)
	self._val = string.byte(raw, index)
end

function object:__tostring()
	return 'OI:'..self:OI()..' DATA:'..self:DATA()..' TM:'..self:Tm()
end

return object
