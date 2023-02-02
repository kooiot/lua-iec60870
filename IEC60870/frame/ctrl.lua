local class = require 'middleclass'

local ctrl = class('LUA_IEC60870_FRAME_CTRL')

ctrl.static.DIR_R		= 0 -- 保留 (用于非平衡传输)
ctrl.static.DIR_M		= 0 -- 主站 (平衡传输)
ctrl.static.DIR_S		= 1 -- 终端 (平衡传输)
ctrl.static.PRM_REQ		= 1 -- 启动站
ctrl.static.PRM_RESP	= 0 -- 从动站

ctrl.static.FC_RST_LINK		= 0 -- 复位远方链路
ctrl.static.FC_RST_PROC		= 1 -- 复位用户进程
ctrl.static.FC_LINK_TEST	= 2 -- 发送/确认链路测试功能 --- 平衡链路
ctrl.static.FC_DATA			= 3 -- 发送/确认用户数据
ctrl.static.FC_DATA_NK		= 4 -- 发送/无回答用户数据
ctrl.static.FC_ACC			= 8 -- 访问请求 (响应链路状态) --- 非平衡链路
ctrl.static.FC_LINK			= 9 -- 请求/响应请求链路状态 (响应链路状态)
ctrl.static.FC_EM1_DATA		= 10 -- 请求/响应请求1级用户数据 --- 非平衡链路
ctrl.static.FC_EM2_DATA		= 11 -- 请求/响应请求2级用户数据 --- 非平衡链路

function ctrl:initialize(dir, prm, fcb_acd, fcv_dfc, fc)
	self._val = ((dir & 0x1) << 7) + ((prm & 0x1) << 6) + ((fcb_acd & 0x1) << 5) + ((fcv_dfc & 0x1) << 4) + fc
end

function ctrl:DIR()
	return (self._val >> 7) & 0x1
end

function ctrl:PRM()
	return (self._val >> 6) & 0x1
end

-- 启动站(下行) 
-- FCB位（0/1交替）
function ctrl:FCB()
	return (self._val >> 5) & 0x1
end

-- 从动站(上行)
-- 1: 有1级数据等待访问
-- 0: 无1级数据等待访问
function ctrl:ACD()
	return (self._val >> 5) & 0x1
end

-- 启动站(下行) 
-- 1: 表示FCB有效
-- 0: 表示FCB无效
function ctrl:FCV()
	return (self._val >> 3) & 0x1
end

-- 从动站(上行)
-- 1: 从动站不能接收后续报文
-- 0: 从动站可以接收后续报文
function ctrl:DFC()
	return (self._val >> 4) & 0x1
end

function ctrl:FC()
	return self._val & 0xF
end

function ctrl:to_hex()
	return string.char(self._val)
end

function ctrl:from_hex(raw, index)
	self._val = string.byte(raw, index)
end

function ctrl:__tostring()
	if self:PRM() == 1 then
		return 'DIR:'..self:DIR()..' PRM:'..self:PRM()..' FCB:'..self:FCB()..' FCV:'..self:FCV()..' FC:'..self:FC()
	else
		return 'DIR:'..self:DIR()..' PRM:'..self:PRM()..' ACD:'..self:ACD()..' DFC:'..self:DFC()..' FC:'..self:FC()
	end
end

return ctrl
