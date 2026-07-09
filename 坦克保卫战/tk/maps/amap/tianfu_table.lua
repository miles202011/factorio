local Global = require 'utils.global'
local Event = require 'utils.event'
local this = {}

local Public = {}

Global.register(
    this,
    function(tbl)
        this = tbl
    end
)


-- 初始化所有天赋相关的表

-- 重置所有表
function Public.reset_table()
    -- 清空所有表，但保持全局存储引用不变
    for k in pairs(this) do
        this[k] = nil
    end
    
    -- 重新初始化所有字段
    this.all_skill = {}
    this.wanglingdajun_souls = {}
    this.wanglingdajun_stored_biters = {}
    this.dingjilueshizhe_kills = {}
    this.tick_skill = {}
    this.choise_skill = {}
    this.shencizhishou_active={}
    this.bpz_count = {}
    this.qiankuang = {}
    this.mine_count = {}
    this.xixue_count = {}
    this.xybg_count = {}
    this.qns_true = false
    this.sgj_count = {}
    this.whea_count = {}
    this.sxf_count = {}
    this.yl_count = {}
    this.xuanze = {}
    this.yjjn_count = {}
    this.yjjn_cn = {}
    this.leitingwanjun_charges = {}  -- 雷霆万钧充能数
    this.leitingwanjun_magic_bonus = {}  -- 雷霆万钧魔法加成
    this.tesla_battery_charges = {}  -- 特斯拉蓄电池充能数
    this.tesla_battery_charge_counter = {}  -- 特斯拉蓄电池充能计数器
    this.fish_count = {}
    this.boom_player_count = {}
    this.boom_player_charges = {}
    this.yanfa_count = {}
    this.biter_kill = {}
    this.fumo_biters = {}  -- 附魔虫子表，存储玩家ID和对应的附魔虫子列表
    this.fumo_biter_to_player = {}  -- 附魔虫子到玩家的映射表，使用unit_number作为键
    this.hushenfu_shield = {}
    this.yinxuejian_shield = {}
    this.fengyinjuanzhou_extra_mana = {}  -- 存储玩家通过封印卷轴获得的额外最大法力值
    this.fengyinjuanzhou_count = {}       -- 存储玩家封印灵魂的计数
    this.xuebao_damage = {}          -- 存储玩家血爆伤害
    this.tianfu_cooldown = {}        -- 存储有冷却时间的天赋，格式：天赋名=冷却时间（tick）
    this.skill_cooldowns = {}        -- 优化的冷却时间表，按玩家索引组织
    this.batch_player_index = 1      -- 分批处理时的玩家索引跟踪器
    this.player_time_skills = {}     -- 玩家时间技能索引：this.player_time_skills[player_name] = {skill_name = true}
    this.player_skill_batch = {}     -- 玩家技能批次信息：this.player_skill_batch[player_name] = {current_batch = 1, skill_list = {}}
    this.pochen_bawangqiang_damage_bonus = {}  -- 破阵霸王枪伤害加成
    this.chaoshikongshangdian_items = {}  -- 超时空商店物品列表：this.chaoshikongshangdian_items[player_index] = {item_name, price}
    this.chaoshikongshangdian_last_refresh = {}  -- 超时空商店上次刷新时间：this.chaoshikongshangdian_last_refresh[player_index] = tick
    this.chaoshikongshangdian_spent = {}  -- 超时空商店已花费金币：this.chaoshikongshangdian_spent[player_index] = amount
end

-- 在模块加载时注册初始化函数
local on_init = function()
    Public.reset_table()
end

Event.on_init(on_init)
-- 获取表数据
function Public.get()
    return this
end

return Public