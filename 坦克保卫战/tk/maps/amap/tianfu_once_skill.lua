local Token = require 'utils.token'
local Task = require 'utils.task'
local Loot = require 'maps.amap.loot'
local Alert = require 'utils.alert'
local rpgtable = require 'modules.rpg.table'
local TPT = require 'maps.amap.tianfu_table'
local WPT = require 'maps.amap.table'

local Public = {}

-- 获取已初始化的表引用
local goal = {'unit', 'turret', 'unit-spawner','spider-leg','combat-robot','spider-unit'}

-- 辅助函数
local function new_print(player, text)
    local this = WPT.get()
    local tick = game.tick
    local player_index = player.index

    if not this.print_cooldown then
        this.print_cooldown = {}
    end

    if this.print_cooldown[player_index] and tick - this.print_cooldown[player_index] < 30 then
        return
    end

    this.print_cooldown[player_index] = tick

    for _, target_player in pairs(game.connected_players) do
        if player.surface == target_player.surface then
        target_player.create_local_flying_text{
            text = text,
            color = player.color,
            position = player.physical_position,
            speed = 0.8
        }
    end
    end

    -- player.create_local_flying_text{
    --     text = text,
    --     color = player.color,
    --     position = player.physical_position,
    --     speed = 0.8
    -- }
end



Public.once_skills = once_skills

-- 一次性技能函数定义
-- local function dgzg(player)
--     local k = 'bullet'
--     local e = game.forces.player
--     local e_old = e.get_ammo_damage_modifier(k)
--     e.set_ammo_damage_modifier(k, 0.1 + e_old)
--     new_print(player, {'tianfu.dgzg_over'})
--     return true
-- end


local function hc(player)
    local index = player.index
    local main_table = WPT.get()
    if not main_table.qcdj[index] then
        main_table.qcdj[index] = 1
    end
    main_table.qcdj[index] = main_table.qcdj[index] + 5
    new_print(player, {'tianfu.hc_over'})
    return true
end

local function rich_son(player)
    player.insert({
        name = 'coin',
        count = 7000
    })
    new_print(player, {'tianfu.rich_son_over'})
    return true
end

local function shit_luck(player)
    -- 随机决定抽奖次数（2-4次）
    local draw_count = math.random(2, 4)
    
    for i = 1, draw_count do
        local luck = math.floor(math.random(1, 150))
        new_print(player, {'amap.lucknb', luck})
        local magic = luck * 5 + 100
        local position = player.physical_surface.find_non_colliding_position("steel-chest", player.physical_position, 20, 1, true) or player.physical_position
        
        -- 50%概率升级为品质宝箱
        if math.random() <= 0.5 then
            -- 使用品质开箱函数
            Loot.cool_with_quality(
                player.physical_surface, 
                position, 
                'steel-chest',
                magic
            )
        else
            -- 使用普通开箱函数
            Loot.cool(player.physical_surface, position, 'steel-chest', magic)
        end
    end

    local msg = {'amap.whatopen'}
    Alert.alert_player(player, 5, msg)
    new_print(player, {'tianfu.shit_luck_over'})
    return true
end

local function tsxf(player)
    local rpg_t = rpgtable.get('rpg_t')
    rpg_t[player.index].xp = rpg_t[player.index].xp + 4000
    return true
end

local function bulider(player)
    local rpg_t = rpgtable.get('rpg_t')
    rpg_t[player.index].dexterity = rpg_t[player.index].dexterity + 15
    rpg_t[player.index].crafting_speed = rpg_t[player.index].crafting_speed + 1
    -- 增加背包格子+10
    if player.character and player.character.valid then
        player.character.character_inventory_slots_bonus = (player.character.character_inventory_slots_bonus or 0) + 10
    end
    return true
end

local function chishang(player)
    for l, player1 in pairs(game.connected_players) do
        player1.insert({
            name = 'coin',
            count = 3000
        })
        player1.print({'tianfu.chishang_over', player.name})
    end
    player.remove_item {
        name = 'coin',
        count = 3000
    }

    return true
end

local function quanneng(player)
    local rpg_t = rpgtable.get('rpg_t')
    rpg_t[player.index].vitality = rpg_t[player.index].vitality + 15
    rpg_t[player.index].magicka = rpg_t[player.index].magicka + 15
    rpg_t[player.index].strength = rpg_t[player.index].strength + 15
    rpg_t[player.index].dexterity = rpg_t[player.index].dexterity + 15
    return true
end





local function mokuaizhuangjia(player)
    -- 赠送模块装甲MK0和相关装备
    player.insert({
        name = 'modular-armor',
        count = 1
    })
    player.insert({
        name = 'construction-robot',
        count = 10
    })
    player.insert({
        name = 'personal-roboport-equipment',
        count = 1
    })
    player.insert({
        name = 'battery-equipment',
        count = 2
    })
    player.insert({
        name = 'solar-panel-equipment',
        count = 10
    })
    new_print(player, {'tianfu.mokuaizhuangjia_over'})
    return true
end

local function rs(player)
    local rpg_t = rpgtable.get('rpg_t')
    rpg_t[player.index].vitality = rpg_t[player.index].vitality + 80
    new_print(player, {'tianfu.rs_over'})
    return true
end

local function xuetu(player)
    local main_table = WPT.get()
    -- 设置手搓经验倍数为1.5倍
    main_table.crafting_exp_multiplier[player.index] = main_table.crafting_exp_multiplier[player.index]+1.5
    new_print(player, {'tianfu.xuetu_over'})
    return true
end

local function waixinglaike(player)
    player.insert({
        name = 'biolab',
        count = 1
    })
    new_print(player, {'tianfu.waixinglaike_over'})
    return true
end

-- 一次性技能表
local once_skills = {
    -- ['dgzg'] = {
    --     name = dgzg
    -- },
    ['hc'] = {
        name = hc
    },
    ['rich_son'] = {
        name = rich_son
    },

    ['shit_luck'] = {
        name = shit_luck
    },
    ['rs'] = {
        name = rs
    },
    ['tsxf'] = {
        name = tsxf
    },
    ['bulider'] = {
        name = bulider
    },
    ['chishang'] = {
        name = chishang
    },
    ['quanneng'] = {
        name = quanneng
    },

    ['mokuaizhuangjia'] = {
        name = mokuaizhuangjia
    },
    ['xuetu'] = {
        name = xuetu
    },
    ['waixinglaike'] = {
        name = waixinglaike
    }
}

-- 公共接口
Public.once_skills = once_skills
Public.dgzg = dgzg
Public.hc = hc
Public.rich_son = rich_son
Public.shit_luck = shit_luck
Public.rs = rs
Public.tsxf = tsxf
Public.bulider = bulider
Public.chishang = chishang
Public.quanneng = quanneng
-- Public.high_debt = high_debt
Public.mokuaizhuangjia = mokuaizhuangjia
Public.xuetu = xuetu
Public.waixinglaike = waixinglaike

return Public