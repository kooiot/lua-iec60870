local base = require 'iec60870.frame.base'

local ctrl = base:subclass('LUA_IEC60870_FRAME_CTRL')

ctrl.static.DIR_R		= 0 -- 保留 (用于非平衡传输)
ctrl.static.DIR_M		= 0 -- 主站 (平衡传输) Controlling Station
ctrl.static.DIR_S		= 1 -- 终端 (平衡传输) Controlled Station
ctrl.static.PRM_P		= 1 -- 启动站 (Primary Station)
ctrl.static.PRM_S		= 0 -- 从动站 (Secondary Station)

-- FCB Frame count bit (0/1)
-- FCV Frame count valid(0/1)
-- DFC Dataf low control(0/1)
-- ACD Access demand(0/1)

ctrl.static.FC_RST_LINK		= 0		-- 复位远方链路
ctrl.static.FC_RST_PROC		= 1		-- 复位用户进程
ctrl.static.FC_LINK_TEST	= 2		-- 发送/确认链路测试功能 --- 平衡链路
ctrl.static.FC_DATA			= 3		-- 发送/确认用户数据
ctrl.static.FC_DATA_NK		= 4		-- 发送/无回答用户数据
ctrl.static.FC_ACC			= 8		-- 访问请求 (响应链路状态) --- 非平衡链路
ctrl.static.FC_LINK			= 9		-- 请求/响应请求链路状态 (响应链路状态)
ctrl.static.FC_EM1_DATA		= 10	-- 请求/响应请求1级用户数据 --- 非平衡链路
ctrl.static.FC_EM2_DATA		= 11	-- 请求/响应请求2级用户数据 --- 非平衡链路

ctrl.static.FC_S_OK			= 0		-- 从动方向 确认:认可
ctrl.static.FC_S_FAIL		= 1		-- 从动方向 确认:否定认可,链路忙
ctrl.static.FC_LINK_RESP	= 11	-- 从动方向 响应:链路状态
ctrl.static.FC_DATA_RESP	= 8		-- 从动方向 响应:用户数据
ctrl.static.FC_DATA_NONE	= 9		-- 从动方向 响应:否定认可:无请求的数据
ctrl.static.FC_SRV_NONE		= 14	-- 从动方向 响应:链路服务未工作
ctrl.static.FC_SRV_BUSY		= 15	-- 从动方向 响应:链路服务未完成

function ctrl:initialize(dir, prm, fcb_acd, fcv_dfc, fc)
	dir = dir or ctrl.static.DIR_R
	prm = prm or ctrl.static.PRM_S
	fcb_acd = fcb_acd or 1
	fcv_dfc = fcv_dfc or 0
	fc = fc or ctrl.static.FC_S_OK

	self._val = ((dir & 0x1) << 7) + ((prm & 0x1) << 6) + ((fcb_acd & 0x1) << 5) + ((fcv_dfc & 0x1) << 4) + fc
end

function ctrl.static:need_fcv(fc)
	if fc == ctrl.static.FC_LINK_TEST then
		return true
	elseif fc == ctrl.static.FC_DATA then
		return true
	elseif fc == ctrl.static.FC_EM1_DATA then
		return true
	elseif fc == ctrl.static.FC_EM2_DATA then
		return true
	else
		return false
	end
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
	return (self._val >> 4) & 0x1
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

function ctrl:byte_size()
	return 1
end

function ctrl:to_hex()
	return string.char(self._val)
end

function ctrl:from_hex(raw, index)
	self._val = string.byte(raw, index)
	return index + 1
end

function ctrl:__totable()
	if self:PRM() == 1 then
		return {
			name = 'CTRL',
			dir = self:DIR(),
			prm = self:PRM(),
			fcb = self:FCB(),
			fcv = self:FCV(),
			fc = self:FC(),
		}
	else
		return {
			name = 'CTRL',
			dir = self:DIR(),
			prm = self:PRM(),
			acd = self:ACD(),
			dfc = self:DFC(),
			fc = self:FC(),
		}
	end
end

return ctrl
