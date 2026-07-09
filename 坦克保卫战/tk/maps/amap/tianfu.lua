local Event = require 'utils.event'
local Loot = require 'maps.amap.loot'
local rpgtable = require 'modules.rpg.table'
local RPG = require 'modules.rpg.core'
local TPT = require 'maps.amap.tianfu_table'
local tianfu_once_skill = require 'maps.amap.tianfu_once_skill'
local tianfu_time_skill = require 'maps.amap.tianfu_time_skill'
local tianfu_trigger_skill = require 'maps.amap.tianfu_trigger_skill'  -- 新添加
local Public = {}
local WPT = require 'maps.amap.table'
local WD = require 'modules.wave_defense.table'

-- 获取已初始化的表引用

local t = {

    ['small-biter'] = 1,
    ['small-spitter'] = 2,
    ['small-worm-turret'] = 32,
    ['medium-biter'] = 8,
    ['medium-spitter'] = 8,
    ['medium-worm-turret'] = 64,
    ['big-biter'] = 32,
    ['big-spitter'] = 32,
    ['big-worm-turret'] = 128,
    ['behemoth-biter'] = 128,
    ['behemoth-spitter'] = 128,
    ['behemoth-worm-turret'] = 256,
    ['biter-spawner'] = 320,
    ['spitter-spawner'] = 320
}

-- 检查玩家是否学习了特定天赋（用于触发天赋判断）
function Public.is_learned(player, skill_id)
    local main_table = WPT.get()
    if not main_table.tianfu_enabled[player.index] then
        main_table.tianfu_enabled[player.index] = {}
    end
    return main_table.tianfu_enabled[player.index][skill_id] == true
end

-- 检查玩家是否学习过特定天赋（用于天赋选择判断，无论启用还是禁用）
function Public.has_learned(player, skill_id)
    local main_table = WPT.get()
    if not main_table.tianfu_enabled[player.index] then
        main_table.tianfu_enabled[player.index] = {}
    end
    return main_table.tianfu_enabled[player.index][skill_id] ~= nil
end


    local function create_damage_floating_text(target_entity, damage_amount, damage_type, player)
    
    -- 根据伤害类型选择颜色
    local color = {r = 1, g = 0.5, b = 0} -- 橙色

    
    -- 在目标位置上方显示伤害数值
    local text_position = {
        x = target_entity.position.x,
        y = target_entity.position.y - 1.5
    }
    
    -- 创建漂浮文本
    player.create_local_flying_text({
        text = tostring(math.floor(damage_amount)),
        position = text_position,
        color = color,
        time_to_live = 60, -- 1秒
        speed = 1.5
    })
end

local function deal_damage_with_floating_text(target_entity, player, damage_amount, damage_type)
    if type(damage_amount) ~= 'number' or damage_amount <= 0 then
        return false
    end     
    local this=WPT.get()
    local damage_multiplier = this.damage_multiplier or 1
    local final_damage = damage_amount * damage_multiplier
    damage_type = damage_type or 'explosion'
    create_damage_floating_text(target_entity, final_damage, damage_type, player)
    target_entity.damage(final_damage, 'player', damage_type, player.character)
 
    return true
end

local function is_gui_visible(element)
    if not element or not element.valid then
        return false
    end

    local screen = element.parent or element

    if screen.valid then
        local visible = screen.visible
        return visible
    end

    return false
end

local function random_k(player_index, k)
    if type(k) ~= 'number' or k < 1 then
        return 1
    end
    
    local main_table = WPT.get()
    
    -- 1. 获取或生成该玩家的随机种子
    if not main_table.random_seed then
        main_table.random_seed= {}
    end
    if not main_table.random_seed[player_index] then
        main_table.random_seed[player_index] = math.random(1, 999999)
    end
    
    -- 2. 获取连接游戏的人数
    local player_count = #game.connected_players
    
    -- 3. 获取当前地图种子
    local map_seed = game.surfaces['nauvis'].map_gen_settings.seed or 0
    
    -- 4. 获取玩家已学习的天赋数量
    local tianfu_count = main_table.tianfu_count[player_index] or 0
    
    -- 5. 根据参数计算确定性随机数
    -- 使用线性同余生成器 (LCG)
    local seed = main_table.random_seed[player_index] + player_index + player_count + map_seed + tianfu_count
    seed = (seed * 1103515245 + 12345) % 2147483648
    
    -- 生成1-k的随机数
    local result = (seed % k) + 1
    
    -- 更新该玩家的种子，使每次调用产生不同的结果
    main_table.random_seed[player_index] = (main_table.random_seed[player_index] * 1103515245 + 12345) % 2147483648
    
    return result
end


local time_skills = tianfu_time_skill.time_skills
local trigger_skills = tianfu_trigger_skill.trigger_skills

function Public.reset_table()
    -- 使用 tianfu_table.lua 中的重置功能
    TPT.reset_table()

    -- 重新获取表引用（虽然不应该改变，但为了安全起见）
    local this = TPT.get()

    -- 重新初始化技能相关数据
    for _, v in pairs(time_skills) do
        this.all_skill[#this.all_skill + 1] = _
        this[_] = {}
        -- 存储有冷却时间的天赋，格式：天赋名=冷却时间（tick）
        if v.time then
            this.tianfu_cooldown[_] = v.time
        end
    end
    for _, v in pairs(tianfu_once_skill.once_skills) do
        this.all_skill[#this.all_skill + 1] = _
    end
    for _, v in pairs(trigger_skills) do
        this.all_skill[#this.all_skill + 1] = _
        this[_] = {}
        -- 存储有冷却时间的天赋，格式：天赋名=冷却时间（tick）
        if v.time then
            this.tianfu_cooldown[_] = v.time
        end
    end

    for k, player in pairs(game.connected_players) do
        local screen = player.gui.screen
        local frame = screen['选择你的天赋']

        if frame and frame.valid then
            frame.destroy()
        end
    end
end

-- 4类天赋分类表
local tianfu_categories = {
    mage = {                                    -- 法师类天赋（通过虫子，召唤物战斗，魔法相关）
       'yl',                                   -- 鱼灵
        'mlzq',                                 -- 魔力之泉
        'yubaobao',                             -- 鱼宝宝
        'smmf',                                 -- 魔法盾
        'kls',                                  -- 傀儡师
        'mfxt',                                 -- 魔法学徒
        'wlfs',                                 -- 亡灵法师
        'juemuren',                             -- 掘墓人
        --'hmds',                                 -- 黑魔导师
        --'zhs',                                  -- 黑暗召唤
       --  'jgq',                                  -- 微型法术激光枪
        'mzqz',                                 -- 魔杖窃贼
        'mijingzhang',                          -- 魔晶杖
        'juqichengjian',                        -- 聚气成剑
        'fali',                                 -- 法力光环
       -- 'fumo',                                 -- 附魔
        'jifengbu',                             -- 疾风步
        'morefali',                             -- 备用法力瓶
        'xxzb',                                 -- 鲜血之杯
        'yjjn',                                 -- 应急胶囊
        'leitingwanjun',                        -- 雷霆万钧
       -- 'tls',                                  -- 通灵术
        'cjs',                                  -- 传教士
        'fish',                                 -- 钓鱼佬
        'yfz',                                  --鱼贩子
        'yuer',                                 -- 鱼饵
        'bei_dong_zhao_huan',                   -- 被动召唤
        --'wanglingdajun',                        -- 亡灵大军
        'shen_fa',                              -- 神罚
        'dianjiqiang',                          --电击枪
        'xxyd',                                 -- 鲜血涌动
        'mlst',                                 -- 魔力升腾
        'smlw',                                 -- 神秘礼物
        'xybg',                                 -- 小鱼饼干
        'hyll',                                 -- 好运连连
        'jika',                                  --集卡
        'zhuoshao',                             --灼烧
        'tianzhao',                             --天照
        'tieshenhuwei',                         --贴身护卫
          'chuanqibaozang',                    --传说宝藏
        'falibiqu',  -- 法力汲取
        'shandianwulianbian',  -- 闪电五连鞭
        'diyu_rongyan',        -- 地狱熔岩
        'shui_hu_fu',  -- 水护符
        'shui_dun',  -- 水遁
        'htms',  -- 红图抹杀
        'tishenshu',  -- 替身术
        'fengyinjuanzhou',  -- 封印卷轴
        'dijiaojiaotu',  -- 低阶教徒
        'wuxingjue',  -- 五行诀
       -- 'weiyang',  -- 喂养
        --'xunshoushi',  -- 驯兽师
        'shimozhe',  -- 噬魔者
        'yanmo',  -- 炎魔
    },
    builder = {      -- 建造者类天赋（建设基地，敏捷相关，资源经济）
        'rsrl',      -- 肉身熔炉
        'fuzhushou', -- 辅助手
       -- 'wuqidashi', -- 武器大师
        'scmcc',     -- 深层采矿车
       -- 'rlfdz',     -- 人力发电站
        'ylsgd',     -- 幽灵施工队
        'gcd',       -- 工程队
        'keyan',     -- 科研人员
        'bpz',       -- 奔跑者
        'fangshou',  -- 城防建设者
        'dianluban', -- 芯片工人
        'jiguang',   -- 激光炮塔生产线
        'sansan',    -- 三三合成
        'bujiwu',    -- 布吉舞者
        'kytd',      -- 科研团队
        'djrc',      -- 顶尖人才
        'tann',      -- 探囊
        'jndd',      -- 江南大盗
        'bulider',   -- 建筑师
        'ycj',       -- 印钞机
        'jxhx',      -- 机械核心
        'touqian',   -- 机敏的小偷
        'ftlt',      -- 垃圾佬
        'kxj',       -- 科学家
        'xueshu',    -- 学术剽窃
        'junhuo',    -- 子弹工厂,
        'dgjx',      -- 帝国军饷
        'yanfayanjiuzhongxin',--研发中心
        'kejigongsi', -- 科技公司
        'chuanqibaozang',--传说宝藏
        'zishenzhuanjia',--资深专家
        'mokuaizhuangjia',--模块装甲
        'gycs',       -- 工业城市
        'shoucuo_de_shen', -- 手搓的神
        'dcrg',       -- 电磁干扰
        'shouyiren',   -- 手艺人
        'xuetu',       -- 学徒
        'gongchengche', -- 工程车
        'jiansheche',   -- 建设车
        'yelianche',    -- 冶炼车
        'jidiche',      -- 基地车
        'beibaozhengli', -- 虚空物流协议
        'waixinglaike', -- 外星来客
        'tesla_battery', -- 特斯拉蓄电池
        'hd',           -- 皇帝
        'small_buss', -- 小商人
        'qiche_ren', -- 汽车人
        'haiguanfang'
    },
    fighter = {          -- 战斗者类天赋（通过增强自身能力战斗，力量和活力相关）
        'shengguangzhongji', -- 圣光重击
        'gongshengti', -- 共生体
        'hushenfu',      -- 护身符
        'chongfengxianzhen', -- 冲锋陷阵
        'jingzhunzhidao', -- 精准制导
        'lianhejuntuan', -- 联合军团
        'rsrl',          -- 肉身熔炉
        'xly',           -- 新兵训练营
        'mbz',           -- 漫步者
         'yhw',           -- 复制指环
        'zdfs2',         -- 自动导弹发射器2
        'daodaoku',      -- 导弹库
      --  'fkdda',         -- 疯狂导弹A型
        --'fkddb',         -- 疯狂导弹B型
        'zdfs',          -- 自动导弹发射器
        'xxyd',          -- 鲜血涌动
        'jingong',       -- 进攻！战斗!
        'genben',        -- 小跟班
        'sglz',            -- 圣光礼赞
        'xuebao',          -- 血爆
        'shoujiao_wuqi',   -- 收缴武器
        'danmu_gongji',    -- 弹幕攻击
        'boom_player',     -- 炸弹人
        'qns',             -- 全能神
        'wjjt',            -- 无尽军团
        'sgj',             -- 赏金猎人
        'baot',            -- 暴徒
        'xixue',           -- 蠕虫

        'fatiao',          -- 发条
        'wolf',            -- 狼人
       -- 'jiantazhe',       -- 践踏者
       -- 'youxia',          -- 游侠
        'caijuezhe',       -- 裁决者
        'peishentuanyuan', -- 陪审团
        'rs',              -- 热血
        'honzha',          -- 轰炸
        'chifu',           -- 赤服
        'tianshi',         -- 天使
        'relife',          -- 复活
        'sxf',             -- 嗜血
        'whea',            -- 我好饿
        'zrsc',            -- 自然生涨
        'zg',              -- 宰割
        'xj',         -- 献祭
        'yinxuejian',      -- 饮血剑
        'lg',              -- 炼金师
        'sangjin',         -- 赏金猎人,
        'xxg',             -- 食尸鬼
        'dgwd',            -- 帝国卫队
        'yueshayueduo',    -- 越杀越多
        'hkzy',            -- 活力护盾：活力值>1200且为全属性最高时，受伤害有10%概率恢复血量并反弹伤害
       -- 'zhiming',         -- 致命一击：你的火箭弹在造成伤害的时候，有15%的概率翻倍伤害
        'zhaohuan_kongxi', -- 召唤空袭
        'pochen_bawangqiang', -- 破阵霸王枪
        'lidazhuanfei',    -- 力大砖飞
        'xuyiyiquan',      -- 蓄意一拳
        'shuangrenjian',   -- 双刃剑
        'dingjilueshizhe', -- 顶级掠食者
        'emengyingrao',    -- 噩梦萦绕
    },
    other = {         -- 其他类天赋（无法归类到以上三类的天赋）
      --  'wudi',       -- 隐形斗篷
              'wxs',       -- 维修师
                      'tuks',            -- 吐口水
         'hhc',                                  -- 滑滑虫
          'yanshu',                               -- 鼹鼠
                  'tzzj',      -- 投资专家
        'carxiu',     -- 汽修工
       -- 'shiyou',     -- 石油大亨
        'sansan',     -- 三三合成
        'xueqiu',     -- 雪球
        'tdlx',       -- 团队领袖
        'xly',        -- 新兵训练营
        'pulu',      -- 铺路机
        'dl',         -- 独狼
        'pailei',        -- 工兵
        'hc',        -- 豪车党
        'rich_son',  -- 富二代
        'shit_luck', -- 狗屎运
        'tsxf',      -- 天神下凡
        'chishang',  -- 发钱
        'quanneng',  -- 全能
        'tjjz',      -- 机械装置
        'willdie',    -- 必死无疑
        'fcz',        -- 复仇者
        'zsfs',       -- 忠实粉丝
               -- 皇帝
     
        'dutu',       -- 赌徒
        'chengshuangchengdui', -- 成双成对
        'weilai',     -- 未来战士
        'shencizhishou', -- 神赐之手
        'yuedui_gushou', -- 乐队鼓手
        'lengdongyubaoxianshu', -- 冷冻鱼保鲜术
        'chaoshikongshangdian', -- 超时空商店
        'lanhuangjiaonang', -- 蓝黄胶囊
        'ailunisi', -- 艾露尼斯
       -- 'zhidanbing', -- 掷弹兵
    }
}


-- 职业选择GUI函数
local function choise_zhiye(player)
    -- 移除可能存在的天赋选择框
    if player.gui.screen['选择你的天赋'] then
        player.gui.screen['选择你的天赋'].destroy()
    end

    -- 移除可能已存在的职业选择框
    if player.gui.screen['choise_zhiye_frame'] then
        player.gui.screen['choise_zhiye_frame'].destroy()
    end

    -- 显示职业选择界面
    local frame = player.gui.screen.add {
        type = 'frame',
        caption = { 'tianfu.choise_zhiye' },
        name = 'choise_zhiye_frame',
        direction = 'vertical'
    }
    frame.force_auto_center()

    -- 添加说明文本
    local label = frame.add({
        type = 'label',
        caption = { 'tianfu.choise_zhiye' }
    })
    label.style.font = 'heading-2'
    label.style.font_color = { r = 0.0, g = 0.5, b = 1.0 }
    -- 添加职业选择按钮
    -- 为每个职业选项添加一个键，用于创建按钮名称
    local zhiye_with_keys = { {
        key = '随机',
        name = { 'tianfu.random' },
        tooltip = ''
    }, {
        key = '战士',
        name = { 'tianfu.zhiye_zhanshi' },
        tooltip = { 'tianfu.zhiye_zhanshi_tip' }
    }, {
        key = '法师',
        name = { 'tianfu.zhiye_fashi' },
        tooltip = { 'tianfu.zhiye_fashi_tip' }
    }, {
        key = '建造者',
        name = { 'tianfu.zhiye_builder' },
        tooltip = { 'tianfu.zhiye_builder_tip' }
    } }

    for _, zhiye_data in pairs(zhiye_with_keys) do
        local button = frame.add({
            type = 'button',
            name = 'zhiye_' .. zhiye_data.key,
            tooltip = zhiye_data.tooltip,
            caption = zhiye_data.name
        })
        button.style.font = 'heading-2'
        button.style.minimal_width = 160
        --button.style.font_color = {r = 0.0, g = 0.7, b = 0.0}
    end
end

local function choise_skill(player)
    local this = TPT.get()
    -- 获取main_table
    local main_table = WPT.get()
if not main_table.crafting_exp_multiplier[player.index] then
  main_table.crafting_exp_multiplier[player.index] = 1
end
    -- 检查是否启用了品质mod
    local has_quality_mod = script.active_mods['quality'] ~= nil
    -- 检查玩家是否已选择职业
    if not main_table.zhiye[player.name] then
        -- 玩家未选择职业，显示职业选择界面
        choise_zhiye(player)
        return
    end

    local selected = {}
    -- 确保表已初始化后再访问
    if this and this.xuanze then
        if this.xuanze[player.index] == 1 then
            return
        end
        this.xuanze[player.index] = 1
    end

    -- 移除可能已存在的天赋选择框
    if player.gui.screen['选择你的天赋'] then
        player.gui.screen['选择你的天赋'].destroy()
    end

    local frame = player.gui.screen.add {
        type = 'frame',
        caption = { 'tianfu.choise_skill' },
        name = '选择你的天赋',
        direction = 'vertical'
    }
    frame.force_auto_center()

    -- 获取玩家职业
    local zhiye = main_table.zhiye[player.name]

    -- 准备天赋选项列表
    local skill_options = {}

    -- 判断是否为第一次选择天赋
    local is_first_selection = false
    if not main_table.tianfu_count[player.index] or main_table.tianfu_count[player.index] == 0 then
        is_first_selection = true
    end

    -- 定义第一次选择时的固定天赋
    local fixed_skill = nil
    if is_first_selection then
        if zhiye == '建造者' then
            fixed_skill = 'fuzhushou'  -- 辅助手
        elseif zhiye == '战士' then
            fixed_skill = 'genben'  -- 小跟班
        elseif zhiye == '法师' then
            fixed_skill = 'mijingzhang'  -- 魔晶杖
        end
    end

    -- 根据职业确定天赋选择逻辑
    if zhiye == '随机' then
        -- 随机职业：从所有天赋中选择5个未学习的天赋
        local all_unlearned = {}
        for _, skill_name in ipairs(this.all_skill) do
            if not Public.has_learned(player, skill_name) then
                all_unlearned[#all_unlearned + 1] = skill_name
            end
        end

        -- 从所有未学习的天赋中随机选择5个
        local temp_unlearned = {}
        for _, skill_name in ipairs(all_unlearned) do
            temp_unlearned[#temp_unlearned + 1] = skill_name
        end
        for i = 1, math.min(5, #temp_unlearned), 1 do
            local num = random_k(player.index, #temp_unlearned)
            skill_options[#skill_options + 1] = temp_unlearned[num]
            table.remove(temp_unlearned, num)
        end
    else
        -- 特定职业：根据职业获取对应分类
        local zhiye_key = ''
        if zhiye == '法师' then
            zhiye_key = 'mage'
        elseif zhiye == '战士' then
            zhiye_key = 'fighter'
        elseif zhiye == '建造者' then
            zhiye_key = 'builder'
        end

        -- 获取对应职业分类的天赋（3个）
        if zhiye_key ~= '' and tianfu_categories[zhiye_key] then
            -- 筛选该分类中未学习的天赋
            local class_unlearned = {}
            for _, skill_name in ipairs(tianfu_categories[zhiye_key]) do
                if not Public.has_learned(player, skill_name) then
                    -- 如果有固定天赋，则跳过它（因为固定天赋会放在第4个位置）
                    if fixed_skill and skill_name == fixed_skill then
                    else
                        class_unlearned[#class_unlearned + 1] = skill_name
                    end
                end
            end

            -- 随机选择3个职业天赋
            local temp_class = {}
            for _, skill_name in ipairs(class_unlearned) do
                temp_class[#temp_class + 1] = skill_name
            end
            for i = 1, math.min(3, #temp_class), 1 do
                local num = random_k(player.index, #temp_class)
                skill_options[#skill_options + 1] = temp_class[num]
                table.remove(temp_class, num)
            end
        end

        -- 获取其他分类的天赋（2个）
        local other_unlearned = {}
        for category_key, category_skills in pairs(tianfu_categories) do
            -- 跳过当前职业的分类
            if category_key ~= zhiye_key then
                for _, skill_name in ipairs(category_skills) do
                    -- 确保天赋未被学习且不在已选择的列表中
                    if not Public.has_learned(player, skill_name) then
                        local already_selected = false
                        for _, selected_skill in ipairs(skill_options) do
                            if selected_skill == skill_name then
                                already_selected = true
                                break
                            end
                        end
                        if not already_selected then
                            -- 如果有固定天赋，则跳过它
                            if fixed_skill and skill_name == fixed_skill then
                            else
                                other_unlearned[#other_unlearned + 1] = skill_name
                            end
                        end
                    end
                end
            end
        end

        -- 如果有固定天赋，则选择1个其他天赋；否则选择2个其他天赋
        local other_count = fixed_skill and 1 or 2
        local temp_other = {}
        for _, skill_name in ipairs(other_unlearned) do
            temp_other[#temp_other + 1] = skill_name
        end
        for i = 1, math.min(other_count, #temp_other), 1 do
            local num = random_k(player.index, #temp_other)
            skill_options[#skill_options + 1] = temp_other[num]
            table.remove(temp_other, num)
        end

        -- 如果有固定天赋，将其添加到第4个位置
        if fixed_skill then
            skill_options[4] = fixed_skill
        end
    end

    -- 如果通过上述方式没有足够的天赋，从所有未学习的天赋中补充
    if #skill_options < 5 then
        local all_unlearned = {}
        for _, skill_name in ipairs(this.all_skill) do
            if not Public.has_learned(player, skill_name) then
                -- 检查是否已在选项列表中
                local already_in_list = false
                for _, selected_skill in ipairs(skill_options) do
                    if selected_skill == skill_name then
                        already_in_list = true
                        break
                    end
                end
                if not already_in_list then
                    all_unlearned[#all_unlearned + 1] = skill_name
                end
            end
        end

        -- 随机选择补充的天赋
        local temp_unlearned2 = {}
        for _, skill_name in ipairs(all_unlearned) do
            temp_unlearned2[#temp_unlearned2 + 1] = skill_name
        end
        for i = 1, math.min(5 - #skill_options, #temp_unlearned2), 1 do
            local num = random_k(player.index, #temp_unlearned2)
            skill_options[#skill_options + 1] = temp_unlearned2[num]
            table.remove(temp_unlearned2, num)
        end
    end

    -- 创建天赋选择按钮（确保没有重复的技能）
    local unique_skills = {}
    local seen_skills = {}

    -- 过滤出唯一的技能
    for _, skill_name in ipairs(skill_options) do
        if not seen_skills[skill_name] then
            seen_skills[skill_name] = true
            unique_skills[#unique_skills + 1] = skill_name
        end
    end

    -- 使用唯一的技能列表创建按钮
    for _, skill_name in ipairs(unique_skills) do
        local b = frame.add({
            type = 'button',
            name = skill_name,
            caption = { 'tianfu.' .. skill_name }
        })
        b.style.font_color = {
            r = 0.00,
            g = 0.25,
            b = 0.00
        }
        b.style.font = 'heading-2'
        b.style.minimal_width = 160
        b.tooltip = { 'tianfu.' .. skill_name .. '_tip' }
    end
    local b = frame.add({
        type = 'label',
        caption = 'PS.彩名玩家可以选2个'
    })
    b.style.font_color = {
        r = 0.66,
        g = 0.0,
        b = 0.66
    }
    -- 尝试设置字体，如果字体不存在则忽略错误
    pcall(function() b.style.font = 'heading-3' end)
    b.style.minimal_width = 96

    local c = frame.add({
        type = 'label',
        caption = 'PS.重复技能不生效'
    })
    c.style.font_color = {
        r = 0.66,
        g = 0.0,
        b = 0.66
    }
    -- 尝试设置字体，如果字体不存在则忽略错误
    pcall(function() c.style.font = 'heading-3' end)
    c.style.minimal_width = 96

    local d = frame.add({
        type = 'label',
        caption = 'PS.注意天赋的相互配合'
    })
    d.style.font_color = {
        r = 0.66,
        g = 0.0,
        b = 0.66
    }
    -- 尝试设置字体，如果字体不存在则忽略错误
    pcall(function() d.style.font = 'heading-3' end)
    d.style.minimal_width = 96

    -- 向玩家说明天赋选择间隔
    local main_table = WPT.get()
    local jiange = 35
    if main_table.jjc == 2 then
        jiange = 15
    end
    local e = frame.add({
        type = 'label',
        caption = "本地图天赋选择间隔" .. jiange .. "级"
    })
    e.style.font_color = {
        r = 255,
        g = 255,
        b = 0
    }
    -- 尝试设置字体，如果字体不存在则忽略错误
    pcall(function() e.style.font = 'heading-3' end)
    e.style.minimal_width = 96

    if not main_table.tianfu_count[player.index] then
        main_table.tianfu_count[player.index] = 0
    end
    main_table.tianfu_count[player.index] = main_table.tianfu_count[player.index] + 1
end

function Public.get_new_tianfu(player)
    choise_skill(player)
end

local function on_player_joined_game(event)
    local this = TPT.get()
    local player = game.players[event.player_index]
    -- 确保表已初始化后再访问
    if this and this.choise_skill then
        if not this.choise_skill[player.name] then
            choise_skill(player)
        end
        this.choise_skill[player.name] = true
    else
        -- 如果表未初始化，则先初始化再执行操作
        choise_skill(player)
    end
end

function Public.get(key)
    local this = TPT.get()
    if key then
        return this[key]
    else
        return this
    end
end

function Public.set(key, value)
    local this = TPT.get()
    if key and (value or value == false) then
        this[key] = value
        return this[key]
    elseif key then
        return this[key]
    else
        return this
    end
end

function Public.get_tianfu_categories()
    return tianfu_categories
end

local function on_gui_click(event)
    local this = TPT.get()
    if not event then
        return
    end
    if not event.element then
        return
    end
    if not event.element.valid then
        return
    end
    if event.element.type ~= 'button' then
        return
    end
    local main_table = WPT.get()
    local player = game.players[event.element.player_index]
    if main_table.tianfu_enabled[player.index] == nil then
        main_table.tianfu_enabled[player.index] = {}
    end
    -- 处理职业选择按钮点击
    if event.element.parent.name == 'choise_zhiye_frame' then
        local element_name = event.element.name
        -- 提取职业名称（去掉前缀"zhiye_"）
        local zhiye_name = string.sub(element_name, 7) -- 从第7个字符开始，去掉"zhiye_"

        -- 处理随机职业选项
        if zhiye_name == '随机' then
            local zhiye_options = { '战士', '法师', '建造者' }
            zhiye_name = zhiye_options[random_k(player.index, #zhiye_options)]
        end

        -- 获取main_table并保存玩家选择的职业
    
        main_table.zhiye[player.name] = zhiye_name

        -- 向玩家发送职业选择成功的消息（使用本地化消息）
        game.print({ 'tianfu.choise_zhiye_msg', player.name, zhiye_name })

        -- 销毁职业选择界面
        event.element.parent.destroy()

        -- 重置选择状态，然后调用天赋选择函数
        this.xuanze[player.index] = 0
        choise_skill(player)

        return
    end

    -- 处理天赋选择按钮点击
    if event.element.parent.name ~= '选择你的天赋' then
        return
    end

    local player = game.players[event.element.player_index]
    this.xuanze[player.index] = 2

    -- tianyu引入代码
    local main_table = WPT.get()
    -- 保存天赋名字到玩家元表
    if main_table.skill[player.name] == nil then
        main_table.skill[player.name] = {}
    end
    local skill_name = event.element.name
    if not tianfu_once_skill.once_skills[skill_name] then
        main_table.skill[player.name][#main_table.skill[player.name] + 1] = skill_name
    end

    -- 设置天赋默认启用

    main_table.tianfu_enabled[player.index][skill_name] = true

    main_table.skill_canchoise[player.name] = 0

    -- 引入结束

    game.print({ 'tianfu.choise_skill_msg', player.name, { 'tianfu.' .. event.element.name } })
    -- Server.to_discord_embed(table.concat({'tianfu.choise_skill_msg', player.name, {'tianfu.'..event.element.name}}))
    this.choise_skill[player.name] = true
    
    if not tianfu_once_skill.once_skills[event.element.name] then
        -- Initialize the table if it doesn't exist
        if not this[event.element.name] then
            this[event.element.name] = {}
        end
        this[event.element.name][#this[event.element.name] + 1] = player.name
        
        -- 更新玩家技能索引：记录玩家学习的时间技能
        local skill_name = event.element.name
        if time_skills[skill_name] then
            if not this.player_time_skills[player.name] then
                this.player_time_skills[player.name] = {}
            end
            this.player_time_skills[player.name][skill_name] = true
        end
    else
        tianfu_once_skill.once_skills[event.element.name].name(player)
    end
    event.element.parent.destroy()
    local jiange = 35
    local this = WPT.get()
    local rpg_t = rpgtable.get('rpg_t')
    if this.jjc == 2 then
        jiange = 15
    end
    -- 检查必要的变量是否存在
    if rpg_t[player.index] and rpg_t[player.index].level and this.tianfu_count and this.tianfu_count[player.index] and this.skill_canchoise and this.skill_canchoise[player.name] == 0 then
        if math.floor(rpg_t[player.index].level / jiange) > this.tianfu_count[player.index] - 1 and is_gui_visible(frame) == false then
            -- 转移至gui更新天赋颜色显示，再引用天赋选择
            this.skill_canchoise[player.name] = 1
      
        end
    end

    if player.gui.left['tianfu_frame'] then
        player.gui.left['tianfu_frame'].destroy()
    end
    
    -- 清除天赋缓存，确保下拉框能显示新学习到的天赋
    local main_table = WPT.get()
    local cache_key = player.name
    
    if main_table.tianfu_names_cache then
        main_table.tianfu_names_cache[cache_key] = nil
    end
    if main_table.tianfu_keys_cache then
        main_table.tianfu_keys_cache[cache_key] = nil
    end
end

-- 扳机类代码
local function have_learn(player, skill)
    return Public.is_learned(player, skill)
end

local function on_tick()
    local this = TPT.get()

    -- 确保必要的表已初始化（兼容旧存档）
    if not this.player_time_skills then
        this.player_time_skills = {}
    end
    if not this.batch_player_index then
        this.batch_player_index = 1
    end

    -- 获取当前连接的玩家列表
    local connected_players = {}
    for _, player in pairs(game.players) do
        if player.valid and player.connected then
            table.insert(connected_players, player)
        end
    end

    -- 如果没有玩家，重置索引
    if #connected_players == 0 then
        this.batch_player_index = 1
        return
    end

    -- 确保索引在有效范围内
    if this.batch_player_index > #connected_players then
        this.batch_player_index = 1
    end

    -- 处理当前批次的玩家（只处理一个玩家）
    local current_player = connected_players[this.batch_player_index]
    if current_player and current_player.valid and current_player.connected then
        -- 以玩家为主键：处理该玩家的所有时间技能
        local tianfu_skill_funcs = tianfu_time_skill
        local player_skills = this.player_time_skills[current_player.name]
        
        -- 完整执行该玩家的所有启用的技能
        if player_skills then
            local main_table = WPT.get()
            local enabled_data = main_table.tianfu_enabled[current_player.index]
            
            -- 遍历所有技能并执行启用的技能
            for skill_name, _ in pairs(player_skills) do
                local is_enabled = not (enabled_data and enabled_data[skill_name] == false)
                if is_enabled then
                    local skill_func = tianfu_skill_funcs[skill_name]
                    if skill_func then
                        skill_func(current_player)
                      -- tianfu_skill_funcs['haiguanfang'](current_player)
                    end
                end
            end
        end
    end

    -- 移动到下一个玩家
    this.batch_player_index = this.batch_player_index + 1

    -- 处理天赋选择逻辑（每2tick都执行）
 
        if not this.choise_skill[current_player.name] then
            choise_skill(current_player)
        end
        this.choise_skill[current_player.name] = true
    
end

-- 独立的学习新天赋时钟事件（每30秒执行一次）
local function on_tick_learn_skill()
    -- 获取当前连接的玩家列表
    local connected_players = {}
    for _, player in pairs(game.players) do
        if player.valid and player.connected then
            table.insert(connected_players, player)
        end
    end

    -- 如果没有玩家，直接返回
    if #connected_players == 0 then
        return
    end

    -- 学习新天赋逻辑
    for _, player in pairs(connected_players) do
        local rpg_t = rpgtable.get('rpg_t')
        local main_table = WPT.get()

        local frame = player.gui.screen['选择你的天赋']
        local jiange = 35
        if main_table.jjc == 2 then
            jiange = 15
        end
        -- 检查必要的变量是否存在
        if rpg_t[player.index] and rpg_t[player.index].level and main_table.tianfu_count and main_table.tianfu_count[player.index] then
            if math.floor(rpg_t[player.index].level / jiange) > main_table.tianfu_count[player.index] - 1 and
                is_gui_visible(frame) == false then
                -- 转移至gui更新天赋颜色显示，再引用天赋选择
                main_table.skill_canchoise[player.name] = 1
            end
        end
        if have_learn(player, 'yanshu') then
            rpg_t[player.index].vitality = 10
            rpg_t[player.index].strength = 10
        end
    end
end







local function yinxuejian_shield(event)
    local this = TPT.get()
    -- 检查实体是否有效且是玩家角色
    local entity = event.entity
    if not entity or not entity.valid or entity.name ~= 'character' then
        return
    end

    -- 获取玩家对象
    local player = entity.player
    if not player or not player.valid then
        return
    end

    -- 获取伤害值
    local damage = event.final_damage_amount
    if not this.yinxuejian_shield[player.index] then 
        this.yinxuejian_shield[player.index] = 0
    end
    -- 如果玩家受到了伤害且护盾量>0，直接给玩家加血。
    if damage > 0 and this.yinxuejian_shield[player.index] > 0 then
        if this.yinxuejian_shield[player.index] > damage then
            this.yinxuejian_shield[player.index] = this.yinxuejian_shield[player.index] - damage
        else
            player.character.health = player.character.health + this.yinxuejian_shield[player.index]
            this.yinxuejian_shield[player.index] = 0
        end
    end
end

local function hushenfu_shield(event)
    local this = TPT.get()
    -- 检查实体是否有效且是玩家角色
    local entity = event.entity
    if not entity or not entity.valid or entity.name ~= 'character' then
        return
    end

    -- 获取玩家对象
    local player = entity.player
    if not player or not player.valid then
        return
    end

    -- 获取伤害值
    local damage = event.final_damage_amount
    if not this.hushenfu_shield[player.index] then
        this.hushenfu_shield[player.index] = 0
    end

    -- 如果玩家受到了伤害且护盾量>0，直接给玩家加血。
    if damage > 0 and this.hushenfu_shield[player.index] > 0 then
        if this.hushenfu_shield[player.index] > damage then
            this.hushenfu_shield[player.index] = this.hushenfu_shield[player.index] - damage + 1
            --给玩家恢复生命值
            player.character.health = player.character.health + this.hushenfu_shield[player.index]
            player.character.health = player.character.health - 1
        else
            player.character.health = player.character.health + this.hushenfu_shield[player.index]
            this.hushenfu_shield[player.index] = 0
        end
    end
end

local function on_pre_player_died(event)
    local this = TPT.get()
    if #this.tianshi ~= 0 then
    for l, player1 in pairs(game.connected_players) do
            if have_learn(player1, 'tianshi') then
                if (tianfu_trigger_skill.tianshi(player1, game.players[event.player_index])) then
                    goto abc
                end
            end
    end
    end

    local player = game.players[event.player_index]

    if have_learn(player, 'relife') then
        tianfu_trigger_skill.relife(player)
    end

    if have_learn(player, 'willdie') then
        tianfu_trigger_skill.willdie(player)
    end
    if have_learn(player, 'yanshu') then
        tianfu_trigger_skill.yanshu(player)
    end

    if event.cause and event.cause.name == 'character' then
        local attacker = event.cause.player
        if attacker and attacker.valid and attacker.force == player.force then
            if player.character and player.character.valid then
                local surface = player.character.surface
                local enemies = surface.count_entities_filtered({
                    position = player.character.position,
                    radius = 12,
                    force = 'enemy'
                })
                if enemies == 0 then
                    local coin_count = attacker.get_item_count('coin')
                    if coin_count > 0 then
                        attacker.remove_item({name = 'coin', count = coin_count})
                        player.insert({name = 'coin', count = coin_count})
                    end
                    if attacker.character and attacker.character.valid then
                        attacker.character.die()
                    end
                    if player.character and player.character.valid then
                        player.character.health = player.character.max_health
                    end
                end
            end
        end
    end

    ::abc::
end

local function on_player_mined_entity(event)
    local player = game.players[event.player_index]

    local entity = event.entity

    if not entity.valid then
        return
    end

    if entity.type ~= "simple-entity" then
        return
    end

    -- if have_learn(player, 'liliangup') then
    --     tianfu_trigger_skill.liliangup(player)
    -- end
    if have_learn(player, 'hyll') then
        tianfu_trigger_skill.hyll(player)
    end

    -- 检查是否学习了皇帝天赋，如果是，清除武器库存
    if have_learn(player, 'hd') then
        local gun_inventory = player.get_inventory(defines.inventory.character_guns)
        if gun_inventory then
            for _, item_data in pairs(gun_inventory.get_contents()) do
                player.remove_item {
                    name = item_data.name,
                    count = item_data.count,
                    quality = item_data.quality
                }
            end
        end
    end
end

function Public.on_player_used_capsule(event)
    local this = TPT.get()
    local player = game.players[event.player_index]
    local item = event.item

    if have_learn(player, 'yhw') and item.name ~= 'discharge-defense-remote' then
        local position = event.position
        tianfu_trigger_skill.yhw(player, position, item.name)
    end

    if have_learn(player, 'hd') and item.name ~= 'raw-fish' then
        player.remove_item {
            name = item.name,
            count = 999999999
        }
    end
    if have_learn(player, 'xybg') and item.name == 'raw-fish' then
        tianfu_trigger_skill.xybg(player)
    end
   -- if have_learn(player, 'mdt') and item.name == 'raw-fish' then
    --    tianfu_trigger_skill.mdt(player)
   -- end
    if have_learn(player, 'yl') and item.name == 'raw-fish' then
        tianfu_trigger_skill.yl(player, event.position)
    end
    if have_learn(player, 'bei_dong_zhao_huan') and item.name == 'raw-fish' then
        tianfu_trigger_skill.bei_dong_zhao_huan(player)
    end

    for l, player1 in pairs(game.connected_players) do
        if #this.yfz ~= 0 then
            if have_learn(player1, 'yfz') and item.name == 'raw-fish' then
                tianfu_trigger_skill.yfz(player1, player)
            end
        end
    end

    -- 处理集卡天赋的鱼计数
    if item.name == 'raw-fish' and have_learn(player, 'jika') then
        -- 初始化玩家的鱼计数
        if not this.fish_count[player.index] then
            this.fish_count[player.index] = 0
        end
        -- 增加鱼使用计数
        this.fish_count[player.index] = this.fish_count[player.index] + 1

        -- 检查是否达到抽奖条件（每1200条鱼）
        if this.fish_count[player.index] >= 1200 then
                -- 执行抽奖
                tianfu_trigger_skill.jika(player)
                -- 重置计数
                this.fish_count[player.index] = 0
            end
    end

    -- 检查是否学习了鱼宝宝天赋
    if item.name == 'raw-fish' and have_learn(player, 'yubaobao') then
        tianfu_trigger_skill.yubaobao(player)
    end

    -- 检查是否学习了喂养天赋
    if item.name == 'raw-fish' and have_learn(player, 'weiyang') then
        tianfu_trigger_skill.weiyang(event,player)
    end

    -- 检查是否学习了闪电五连鞭天赋
    if item.name == 'raw-fish' and have_learn(player, 'shandianwulianbian') then
        tianfu_trigger_skill.shandianwulianbian(player)
    end

    -- 检查是否学习了成双成对天赋
    if have_learn(player, 'chengshuangchengdui') then
        -- 检查是否是剧毒胶囊或减速胶囊
        if item.name == 'poison-capsule' or item.name == 'slowdown-capsule' then
            tianfu_trigger_skill.chengshuangchengdui(player, event.position, item.name)
        end
    end
end

local function on_player_died(event)
    local player = game.players[event.player_index]
    local cause = event.cause
    if cause then
        if cause.valid then

        end
    end

    for _, player1 in pairs(game.connected_players) do
        if have_learn(player1, 'fcz') then
            tianfu_trigger_skill.fcz(player1)
        end
        if have_learn(player1, 'tjjz') then
            tianfu_trigger_skill.tjjz(player1)
        end
        if have_learn(player1, 'dijiaojiaotu') then
            tianfu_trigger_skill.dijiaojiaotu(player1, { player = player })
        end
    end
end

local function on_player_built_entity(event)
    local entity = event.entity

    if not entity then
        return
    end
    if not entity.valid then
        return
    end

    local player = game.players[event.player_index]

    if not player then
        return
    end
end

local function on_entity_died(event)
    local this = TPT.get()
    if not event.entity then
        return
    end
    if not event.entity.valid then
        return
    end
    if event.entity.name == 'gun-turret' and event.entity.force == game.forces.player then
        for l, player1 in pairs(game.connected_players) do

        end
        return
    end

    if not event.cause then
        return
    end
    if not event.cause.valid then
        return
    end

    if not event.entity.valid then
        return
    end
    if event.entity.force ~= game.forces.enemy then
        return
    end

    -- 1000波以后特殊的DEBUFF处理
    local wave_number = WD.get('wave_number')
    if wave_number >= 1000 and event.cause.name == 'character' then
        local player = event.cause.player
        if player and player.valid then
            -- 检查是否击杀了虫巢或沙虫
            local spawner_names = {
                ['biter-spawner'] = true,
                ['spitter-spawner'] = true,
                ['small-worm-turret'] = true,
                ['medium-worm-turret'] = true,
                ['big-worm-turret'] = true,
                ['behemoth-worm-turret'] = true
            }

            if spawner_names[event.entity.name] then
                -- 在玩家角色身上创建 demolisher-ash-sticker 实体（减速效果）
                local surface = player.surface
                if surface and surface.valid then
                    surface.create_entity({
                        name = 'demolisher-ash-sticker',
                        position = event.entity.position,
                        source = event.entity,
                        target = player.character,
                        force = 'enemy',
                    })
                end
            end
            

        end
    end

    -- 检查是否是战斗无人机杀死的敌人
    if event.cause.type == 'combat-robot' and event.cause.force == game.forces.player then
        local player = event.cause.last_user
        if player then
            if have_learn(player, 'jingzhunzhidao') then
                -- 5%的概率触发天赋
                if math.random(1, 100) <= 5 then
                    tianfu_trigger_skill.jingzhunzhidao(player, event.cause)
                end
            end
          
            if have_learn(player, 'lianhejuntuan') then
                -- 2%的概率触发联合军团天赋
                if math.random(1, 100) <= 2 then
                    tianfu_trigger_skill.lianhejuntuan(player)
                end
            end
            
            if have_learn(player, 'peishentuanyuan') then
                -- 0.5%的概率触发陪审团天赋
                if math.random(1, 200) <= 1 then
                    tianfu_trigger_skill.peishentuanyuan(player, event.entity)
                end
            end
        end
    end

    local turret_types = {
        ['ammo-turret'] = true,
        ['electric-turret'] = true,
        ['fluid-turret'] = true
    }

    if turret_types[event.cause.type] and event.cause.force == game.forces.player then

        for l, player1 in pairs(game.connected_players) do
            
                if have_learn(player1, 'dgjx') then
                    tianfu_trigger_skill.dgjx(player1)
                end
            
        end

        return
    end

    --如果是玩家杀死的敌人
    if event.cause.name == 'character' then
        local player = event.cause.player
        local entity = event.entity

        if player.valid then
            if have_learn(player, 'youxia') then
                tianfu_trigger_skill.youxia(player, entity)
            end

            if event.damage_type then
                if have_learn(player, 'yinxuejian') and event.damage_type.name == 'physical' then
                    tianfu_trigger_skill.yinxuejian(player)
                end
                if have_learn(player, 'baot') and event.damage_type.name == 'physical' then
                    tianfu_trigger_skill.baot(player, entity)
                end
                -- 破阵霸王枪天赋触发：物理伤害击杀
                if have_learn(player, 'pochen_bawangqiang') and event.damage_type.name == 'physical' then
                    tianfu_trigger_skill.pochen_bawangqiang(player, entity)
                end
            end
            if have_learn(player, 'sangjin') then
                tianfu_trigger_skill.sangjin(player, entity)
            end
            if have_learn(player, 'zg') then
                tianfu_trigger_skill.zg(player)
            end
            if have_learn(player, 'xixue') then
                tianfu_trigger_skill.xixue(player)
            end
            if have_learn(player, 'sgj') then
                tianfu_trigger_skill.sgj(player)
            end
            if have_learn(player, 'sxf') then
                tianfu_trigger_skill.sxf(player)
            end

            if have_learn(player, 'tuks') then
                tianfu_trigger_skill.tuks(player, entity)
            end
            
            -- 顶级掠食者天赋触发
            if have_learn(player, 'dingjilueshizhe') then
                tianfu_trigger_skill.dingjilueshizhe(player, entity)
            end
            
            -- 噬魔者天赋触发
            if have_learn(player, 'shimozhe') then
                tianfu_trigger_skill.shimozhe(player)
            end
            
            -- 炎魔天赋触发
            if have_learn(player, 'yanmo') then
                tianfu_trigger_skill.yanmo(player, entity)
            end
            
            -- 裁决者天赋触发
            if have_learn(player, 'caijuezhe') then
                tianfu_trigger_skill.caijuezhe(player, entity)
            end

            -- 越杀越多天赋
            if have_learn(player, 'yueshayueduo') then
                tianfu_trigger_skill.yueshayueduo(player, entity)
            end
            
            -- 亡灵大军天赋触发
            -- if have_learn(player, 'wanglingdajun') then
            --     tianfu_trigger_skill.wanglingdajun(player, entity)
            -- end
            
            -- 五行诀天赋触发
            if have_learn(player, 'wuxingjue') then
                tianfu_trigger_skill.wuxingjue(player, {entity = entity})
            end
            
            -- 封印卷轴天赋触发
            if have_learn(player, 'fengyinjuanzhou') then
                tianfu_trigger_skill.fengyinjuanzhou(player, {entity = entity})
            end

            -- 收缴武器天赋
            if have_learn(player, 'shoujiao_wuqi') then
                -- 1.5%的概率触发收缴武器天赋
                if math.random(1, 200) <= 3 then
                    tianfu_trigger_skill.shoujiao_wuqi(player, event.entity)
                end
            end
           
        end

        return
    end
end


-- 附魔虫子的攻击逻辑
local function fumo_biter_attack_logic(event)    
    local this = TPT.get()
    local attacker = event.cause
    
    -- 检查攻击者是否有效
    if not attacker or not attacker.valid then
        return
    end
    
    -- 检查攻击者是否是附魔虫子
    local owner_player_index = this.fumo_biter_to_player[attacker.unit_number]
    if not owner_player_index then
        return
    end
    
    local owner_player = game.players[owner_player_index]
    
    if not owner_player then
        return
    end
    
    -- 获取玩家当前法力值
    local rpg_t = rpgtable.get('rpg_t')
    local current_mana = rpg_t[owner_player.index].mana or 0
    
    if current_mana <= 0 then
        return
    end
    
    -- 计算要消耗的法力值（10%当前法力）
    local mana_consumption = math.floor(current_mana * 0.1)
    
    if mana_consumption <= 0 then
        return
    end
    
    -- 消耗法力值
    rpg_t[owner_player.index].mana = current_mana - mana_consumption
    
    -- 计算伤害（消耗法力 * 5）
    local area_damage = mana_consumption * 4
    
    -- 造成范围伤害
    local surface = event.entity.surface
    local position = event.entity.position
    local radius = 3  -- 小范围伤害
    
    local goal = {'unit', 'turret', 'unit-spawner','spider-leg','combat-robot','spider-unit'}
    
    for _, target in pairs(surface.find_entities_filtered({
        area = { { position.x - radius, position.y - radius }, { position.x + radius, position.y + radius } },
        force = game.forces.enemy,
        type = goal
    })) do
        if target.valid and target.health then
            local distance = math.sqrt((target.position.x - position.x) ^ 2 + (target.position.y - position.y) ^ 2)
            if distance <= radius then
                local damage_multiplier = 1 - distance / radius
                local final_damage = area_damage * damage_multiplier
               
                if final_damage > 0 then
                    target.damage(final_damage, 'player', 'explosion', owner_player.character)
                end
            end
        end
    end
    
    -- 显示法力消耗的飞行文本
    if owner_player.valid then
        owner_player.create_local_flying_text({
            text = '-' .. mana_consumption .. ' Mana',
            position = { x = owner_player.physical_position.x, y = owner_player.physical_position.y - 2 },
            color = { r = 0.3, g = 0.5, b = 1.0 },
            time_to_live = 120,
            speed = 0.8
        })
    end
end

local function on_tick_shengguangzhongji()
    local rpg_t = rpgtable.get('rpg_t')
    local this = TPT.get()
    
    for _, player in pairs(game.connected_players) do
        if not player.valid or not player.character or not player.character.valid then
            goto continue
        end
        
      local cause = player.character
        local inv_ammo = cause.get_inventory(defines.inventory.character_ammo)
        local inv_gun = cause.get_inventory(defines.inventory.character_guns)
        local idx = cause.selected_gun_index
        local surface = cause.surface
        local position = cause.position
        local goal = {'unit', 'turret', 'unit-spawner', 'spider-leg', 'combat-robot', 'spider-unit'}
        
        local enemies
        local sousuo=false
        
        if have_learn(player, 'gongshengti') then
            enemies = surface.find_entities_filtered({
            area = { { position.x - 2, position.y - 2 }, { position.x + 2, position.y + 2 } },
            force = game.forces.enemy,
            type = goal
        })
        sousuo=true
            if #enemies > 0 then
                local random_index = math.random(1, #enemies)
                local target_entity = enemies[random_index]
                
                if target_entity.valid and target_entity.health then
                    local strength = rpg_t[cause.player.index].strength
                    deal_damage_with_floating_text(target_entity, player, (strength/2) * 0.5, 'physical')
                end
            end
            
            cause.health = cause.health + (rpg_t[cause.player.index].vitality - 10) * 0.3 * 0.5
        end
        
        if inv_ammo[idx].valid_for_read and inv_gun[idx].valid_for_read then
            goto continue
        end
        
        if sousuo==false then 
            enemies = surface.find_entities_filtered({
            area = { { position.x - 2, position.y - 2 }, { position.x + 2, position.y + 2 } },
            force = game.forces.enemy,
            type = goal
        })
        end

        if have_learn(player, 'mijingzhang') then
            tianfu_trigger_skill.mijingzhang(player)
        end

        if  have_learn(player, 'shengguangzhongji') then
            tianfu_trigger_skill.shengguangzhongji(player)
        end
        
        if #enemies == 0 then
            goto continue
        end
        
        if have_learn(player, 'shuangrenjian') and #enemies >= 2 then
            if tianfu_trigger_skill.shuangrenjian(player, enemies) then
                goto continue
            end
        end
           
        cause.health = cause.health + (rpg_t[cause.player.index].vitality - 10) * 0.3
        
        local random_index = math.random(1, #enemies)
        local target_entity = enemies[random_index]
        
        if not target_entity.valid or not target_entity.health then
            goto continue
        end
        
        if target_entity.valid then
            local strength = rpg_t[cause.player.index].strength
            deal_damage_with_floating_text(target_entity, player, strength/2-10, 'physical')
        end
        
        ::continue::
    end
end

local function on_entity_damaged(event)
    -- 1. 极其快速的初步过滤

    local entity = event.entity
    if not entity or not entity.valid then return end
    local cause = event.cause
    local entity_force = entity.force
    local player_force = game.forces.player -- 预置引用提高效率

    
    
    -- 2. 处理阵营保护逻辑 (神赐之手)
    -- 仅当受伤者是玩家阵营时才遍历激活状态，减少 90% 的无效循环
    if entity_force == player_force then
        local this = TPT.get()
        local active_skills = this.shencizhishou_active
        if active_skills then
            local current_tick = game.tick
            for _, data in pairs(active_skills) do
                if data and data.end_tick and current_tick < data.end_tick then
                    entity.health = entity.max_health
                    return -- 如果已经无敌，直接返回，不再计算后续受伤逻辑
                end
            end
        end
    end



    -- 3. 受伤者逻辑 (玩家受击)
    local entity_name = entity.name
    if entity_name ~= 'character' then
return
     end
        local player = entity.player
        if player then
            -- 建议将 have_learn 结果存在一个临时 table 中，避免多次调用
            -- 或者将逻辑合并
            if have_learn(player, 'yinxuejian') then yinxuejian_shield(event) end
            if have_learn(player, 'hushenfu') then hushenfu_shield(event) end
            if have_learn(player, 'smmf') then tianfu_trigger_skill.smmf(player, event) end
            if have_learn(player, 'shui_hu_fu') then tianfu_trigger_skill.shui_hu_fu(player) end
            if have_learn(player, 'hkzy') then tianfu_trigger_skill.hkzy(player, event) end
            if have_learn(player, 'tishenshu') then tianfu_trigger_skill.tishenshu(player, event) end
            if have_learn(player, 'xuebao') then tianfu_trigger_skill.xuebao(player, event) end
        end

end



local function on_player_gun_inventory_changed(event)
    local player = game.players[event.player_index]
    if have_learn(player, 'hd') then
        local something = player.get_inventory(defines.inventory.character_guns)
        -- 检查inventory是否存在且有效
        if not something then
            return
        end
        for _, item_data in pairs(something.get_contents()) do
            player.remove_item {
                name = item_data.name,
                count = item_data.count,
                quality = item_data.quality
            }
        end
    end
end

local function on_research_finished(event)
    if event.research.force.index ~= game.forces.player.index then
        return
    end
    for k, player in pairs(game.connected_players) do
        if have_learn(player, 'xueshu') then
            tianfu_trigger_skill.xueshu(player)
        end

        if have_learn(player, 'kxj') then
            tianfu_trigger_skill.kxj(player)
        end

        if have_learn(player, 'qykj') then
            tianfu_trigger_skill.qykj(player)
        end
    end
end

Event.on_nth_tick(3, on_tick)
Event.on_nth_tick(40, on_tick_shengguangzhongji)
Event.on_nth_tick(60*10, on_tick_learn_skill)  -- 每30秒执行一次学习新天赋逻辑
Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_pre_player_died, on_pre_player_died)
Event.add(defines.events.on_player_mined_entity, on_player_mined_entity,{
    {filter = "type", type = 'simple-entity'},
    {filter = "type", type = 'linked-chest'},
    {filter = "type", type = 'container'},
    {filter = "type", type = 'logistic-container'},
    {filter = "type", type = 'car'},
    
    {filter = "type", type = 'artillery-wagon'},
    {filter = "type", type = 'artillery-turret'},
    {filter = "type", type = 'land-mine'},
    {filter = "type", type = 'spider-vehicle'},
    {filter = "type", type = 'ammo-turret'},
    {filter = "type", type = 'electric-turret'},
    {filter = "type", type = 'fluid-turret'},
	{filter = "type", type = 'tree'}
})
Event.add(defines.events.on_player_used_capsule, Public.on_player_used_capsule)
Event.add(defines.events.on_research_finished, on_research_finished)
Event.add(defines.events.on_player_gun_inventory_changed, on_player_gun_inventory_changed)
Event.add(defines.events.on_player_died, on_player_died)
Event.add(defines.events.on_entity_damaged, on_entity_damaged, {
    {filter = "type", type = 'character'}, 
    {filter = "type", type = 'electric-turret'}
    })
Event.add(defines.events.on_entity_died, on_entity_died, {
    {filter = "type", type = 'unit'},
    {filter = "type", type = 'turret'},
    {filter = "type", type = 'unit-spawner'},
    {filter = "type", type = 'land-mine'},
    {filter = "type", type = 'spider-unit'},
    {filter = "type", type = 'character'},
    {filter = "type", type = 'car'},
    
    {filter = "type", type = 'spider-vehicle'},
    {filter = "type", type = 'ammo-turret'},
    {filter = "type", type = 'electric-turret'},
    {filter = "type", type = 'fluid-turret'},
    {filter = "type", type = 'artillery-turret'},
    {filter = "type", type = 'rocket-silo'},
    {filter = "type", type = "reactor"}
    })

-- 添加testzhiye命令，用于检查天赋分类情况
commands.add_command('testzhiye', '检查未分类的天赋', function(event)
    if not event.player_index then
        return
    end

    local player = game.players[event.player_index]
    local unclassified_skills = {}

    -- 创建已分类天赋的查找表
    local classified_skills = {}
    for category_name, skills in pairs(tianfu_categories) do
        for _, skill_id in pairs(skills) do
            classified_skills[skill_id] = true
        end
    end

    -- 检查time_skills中的天赋
    for skill_id, _ in pairs(tianfu_time_skill.time_skills) do
        if not classified_skills[skill_id] then
            table.insert(unclassified_skills, skill_id)
        end
    end

    -- 检查once_skills中的天赋
    for skill_id, _ in pairs(tianfu_once_skill.once_skills) do
        if not classified_skills[skill_id] then
            table.insert(unclassified_skills, skill_id)
        end
    end

    -- 检查trigger_skills中的天赋
    for skill_id, _ in pairs(trigger_skills) do
        if not classified_skills[skill_id] then
            table.insert(unclassified_skills, skill_id)
        end
    end

    -- 输出结果
    if #unclassified_skills > 0 then
        player.print('未分类的天赋:')
        for _, skill_id in pairs(unclassified_skills) do
            player.print('- ' .. skill_id)
        end
        player.print('总共找到 ' .. #unclassified_skills .. ' 个未分类的天赋')
    else
        player.print('所有天赋都已正确分类！')
    end
end)

-- 添加check_missing_skills命令，用于查找在分类表中存在但实际天赋表中不存在的天赋
commands.add_command('check_missing_skills', '查找在分类表中存在但实际天赋表中不存在的天赋', function(event)
    if not event.player_index then
        return
    end

    local player = game.players[event.player_index]
    local missing_skills = {}

    -- 创建实际天赋表的查找表
    local actual_skills = {}
    -- 添加time_skills中的天赋
    for skill_id, _ in pairs(tianfu_time_skill.time_skills) do
        actual_skills[skill_id] = true
    end
    -- 添加once_skills中的天赋
    for skill_id, _ in pairs(tianfu_once_skill.once_skills) do
        actual_skills[skill_id] = true
    end
    -- 添加trigger_skills中的天赋
    for skill_id, _ in pairs(trigger_skills) do
        actual_skills[skill_id] = true
    end

    -- 检查分类表中的天赋是否存在于实际天赋表中
    for category_name, skills in pairs(tianfu_categories) do
        for _, skill_id in pairs(skills) do
            if not actual_skills[skill_id] then
                table.insert(missing_skills, { id = skill_id, category = category_name })
            end
        end
    end

    -- 输出结果
    if #missing_skills > 0 then
        player.print('在分类表中存在但实际天赋表中不存在的天赋:')
        for _, skill_info in pairs(missing_skills) do
            player.print('- ' .. skill_info.id .. ' (分类: ' .. skill_info.category .. ')')
        end
        player.print('总共找到 ' .. #missing_skills .. ' 个不存在的天赋')
    else
        player.print('所有分类表中的天赋都存在于实际天赋表中！')
    end
end)


local function on_player_crafted_item(event)
    local player = game.players[event.player_index]
    if not player or not player.valid then
        return
    end
    
    -- 检查是否学习了手搓的神天赋
    if have_learn(player, 'shoucuo_de_shen') then
        tianfu_trigger_skill.shoucuo_de_shen(player, event)
    end
    
    -- 检查是否学习了手艺人天赋
    if have_learn(player, 'shouyiren') then
        tianfu_trigger_skill.shouyiren(player, event)
    end

    
end


Event.add(defines.events.on_player_crafted_item, on_player_crafted_item)

local function on_player_deconstructed_area(event)
    local player = game.players[event.player_index]
    if not player or not player.valid then
        return
    end
    
    -- 检查是否学习了红图抹杀天赋
    if have_learn(player, 'htms') then
        tianfu_trigger_skill.htms(player,event)
        
    end
    
    -- 检查是否学习了召唤空袭天赋
    if have_learn(player, 'zhaohuan_kongxi') then
        tianfu_trigger_skill.zhaohuan_kongxi(player,event)
        
    end
    
    -- 检查是否学习了神赐之手天赋
    if have_learn(player, 'shencizhishou') then
        tianfu_trigger_skill.shencizhishou(player, event)
    end

end

Event.add(defines.events.on_player_deconstructed_area, on_player_deconstructed_area)

return Public
