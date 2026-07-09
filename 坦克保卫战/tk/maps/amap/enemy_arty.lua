local Event = require 'utils.event'

local Global = require 'utils.global'
local Task = require 'utils.task'
local arty_count = {construction_queue = {}}
local Public = {}
local get_baolei_pos = require'stronghold_generation_algorithm_v2'.find_available_stronghold_position
local RPG = require 'modules.rpg.table'
local Token = require 'utils.token'
local WPT = require 'maps.amap.table'
local Loot = require 'maps.amap.loot'
local WD = require 'modules.wave_defense.table'
-- 敌人炮台配置表
local enemy_turret = {
    --  [1]={name='stone-wall',worth=1,wave_number=0},
    [2] = {
        name = 'biter-spawner',
        worth = 20,
        wave_number = 200,
        ban = true
    },
    [3] = {
        name = 'laser-turret',
        worth = 8,
        wave_number = 100
    },
    [4] = {
        name = 'gun-turret',
        worth = 5,
        wave_number = 100
    },
    [5] = {
        name = 'medium-worm-turret',
        worth = 10,
        wave_number = 100,
        ban = true
    },
    [6] = {
        name = 'flamethrower-turret',
        worth = 10,
        wave_number = 150
    },
    [7] = {
        name = 'big-worm-turret',
        worth = 20,
        wave_number = 150,
        ban = true
    },
    [8] = {
        name = 'behemoth-worm-turret',
        worth = 50,
        wave_number = 700,
        ban = true
    },
    [9] = {
        name = 'artillery-turret',
        worth = 100,
        wave_number = 1000
    }
}

-- 堡垒分批创建任务队列管理器
local construction_queue = arty_count.construction_queue

-- 初始化任务队列
function Public.init_construction_queue()
    construction_queue.tasks = {}
    construction_queue.current_index = 1
    construction_queue.active_constructions = {}
end

-- 添加分批任务到队列
function Public.add_batch_task(task_data)
    if not construction_queue.tasks then
        construction_queue.tasks = {}
        construction_queue.current_index = 1
        construction_queue.active_constructions = {}
    end
    construction_queue.tasks[#construction_queue.tasks + 1] = task_data
end

-- 获取下一个待执行的任务
function Public.get_next_task()
    if construction_queue.current_index <= #construction_queue.tasks then
        local task = construction_queue.tasks[construction_queue.current_index]
        construction_queue.current_index = construction_queue.current_index + 1
        
        -- 更新对应建设任务的当前索引
        if task.baolei_id and construction_queue.active_constructions[task.baolei_id] then
            construction_queue.active_constructions[task.baolei_id].current_index = construction_queue.current_index
        end
        
        return task
    end
    return nil
end

-- 检查是否还有待执行的任务
function Public.has_pending_tasks()
    return construction_queue.tasks and construction_queue.current_index <= #construction_queue.tasks
end

-- 获取当前队列长度
function Public.get_queue_length()
    return construction_queue.tasks and #construction_queue.tasks or 0
end

-- 执行单个分批任务
function Public.execute_batch_task(task)
    local success, result = pcall(task.func, unpack(task.params))
    if not success then
        game.print("堡垒分批任务执行失败: " .. tostring(result))
        game.print("任务类型: " .. task.type)
    end
    return success
end

-- 启动新的堡垒分批创建
function Public.start_baolei_construction(position, wave_number, surface, robot_number, fix_number, out_wall, something, baolei_id, cleanup_terrain)
    if cleanup_terrain == nil then
        cleanup_terrain = true
    end
    if not construction_queue.tasks then
        construction_queue.tasks = {}
        construction_queue.current_index = 1
        construction_queue.active_constructions = {}
    end
    
    local construction_id = baolei_id
    local start_index = #construction_queue.tasks + 1
    
    construction_queue.active_constructions[construction_id] = {
        position = position,
        wave_number = wave_number,
        surface = surface,
        robot_number = robot_number,
        fix_number = fix_number,
        out_wall = out_wall,
        something = something,
        baolei_id = baolei_id,
        current_stage = 1,
        all_thing = {},
        roboport = nil,
        task_start_index = start_index,
        task_end_index = start_index - 1,  -- 还没有添加任务
        current_index = start_index  -- 初始化当前索引
    }
    
    -- 清理附近旧奖励箱
    Public.cleanup_nearby_reward_chests(position, surface)
    
    -- 创建清理任务
    if cleanup_terrain then
        Public.create_cleanup_tasks(position, surface, baolei_id)
    end
    
    -- 创建地形设置任务
    if cleanup_terrain then
        Public.create_terrain_tasks(position, surface, baolei_id)
    end
    
    -- 创建核心建筑任务
    Public.create_core_building_tasks(position, surface, robot_number, fix_number, something, baolei_id)
    
    -- 创建炮台任务
    Public.create_turret_tasks(position, surface, wave_number, baolei_id)
    
    -- 创建内层墙壁任务
    Public.create_inner_wall_tasks(position, surface, baolei_id)
    
    -- 创建外层墙壁任务（如果需要）
    if out_wall then
        Public.create_outer_wall_tasks(position, surface, baolei_id)
    end
    
    -- 更新任务结束索引
    construction_queue.active_constructions[construction_id].task_end_index = #construction_queue.tasks
    
    return construction_id
end

local ammo = {}
ammo = {
    [1] = {
        name = 'firearm-magazine'
    },
    [2] = {
        name = 'piercing-rounds-magazine'
    },
    [3] = {
        name = 'uranium-rounds-magazine'
    }
}

-- 品质配置
local quality_upgrades = { 
    { name = "legendary", chance = 0.01 }, -- 1% 传说品质
    { name = "epic",      chance = 0.03 }, -- 3% 史诗品质
    { name = "rare",      chance = 0.05 }, -- 5% 稀有品质
    { name = "uncommon",  chance = 0.10 }  -- 10% 普通品质
}

-- 根据概率随机选择品质
local function select_quality_by_chance()
    -- 检查是否启用了品质mod
    local has_quality_mod = script.active_mods['quality'] ~= nil
    if not has_quality_mod then
        return nil
    end
    
    local roll = math.random()
    local cumulative_chance = 0
    
    for _, quality in ipairs(quality_upgrades) do
        cumulative_chance = cumulative_chance + quality.chance
        if roll <= cumulative_chance then
            return quality.name
        end
    end
    
    return nil
end

local player_build = {'rocket-silo', 'steam-turbine', 'assembling-machine-1', 'assembling-machine-2',
                      'assembling-machine-3', 'oil-refinery', 'chemical-plant', 'car', 'spidertron', 'tank',
                      'character', 'gun-turret', 'electric-mining-drill', 'laser-turret', 'steam-engine', 'roboport', 'big-mining-drill'    ,'foundry','rail-support'
                        
  ,'recycler'
  ,'electromagnetic-plant'
  ,'heating-tower'}
local artillery_target_entities = {
    'character',
    'radar',
    'roboport',
    'artillery-wagon',
    'artillery-turret',
    'flamethrower-turret',
    'spidertron',
    'tesla-turret',
    'railgun-turret',
    'small-worm-turret',
    'medium-worm-turret',
    'big-worm-turret',
    'behemoth-worm-turret',
    'biter-spawner',
    'spitter-spawner'
}

Global.register(arty_count, function(tbl)
    arty_count = tbl
end)

function Public.reset_table()
    arty_count.unit = {}
    arty_count.neet_to_kill = {}
    arty_count.pace = 1.5
    arty_count.radius = 105
    arty_count.surface = {}
    arty_count.index = 1
    arty_count.fire = {}
    arty_count.arty = {}
    arty_count.roboport_wave = {}
    arty_count.all = {}
    arty_count.gun = {}
    arty_count.laser = {}
    arty_count.flame = {}
    arty_count.last = {}
    arty_count.attack_table={}
    arty_count.can_attack_table={}
    arty_count.ammo_index = 1
    arty_count.count = 0
    arty_count.arty_check_count = 0
    arty_count.construction_queue = {
        tasks = {},
        current_index = 1,
        active_constructions = {}
    }
    arty_count.baolei_creation_times = {}
    arty_count.next_baolei_speed_bonus = 0
end

local on_init = function()
    Public.reset_table()
    Public.init_construction_queue()
end

local shot_hd = Token.register(function(entity)

    if not entity or not entity.valid then
        return
    end
    local wave_defense_table = WD.get_table()
    if not wave_defense_table.target then
        return
    end
    if not wave_defense_table.target.valid then
        return
    end
    local target = wave_defense_table.target
    local e = entity.surface.create_entity({
        name = 'atomic-rocket',
        position = {
            x = target.position.x,
            y = target.position.y - 100
        },

        force = game.forces.enemy,
        source = {
            x = target.position.x,
            y = target.position.y - 100
        },
        target = target,
        speed = 1
    })
    game.print('虫子已经发射核弹，并在重新装弹，下一发核弹将在3分钟后发射', {255, 0, 0})
end)
function Public.add_laser(k)
    arty_count.laser[#arty_count.laser + 1] = k
end
function Public.add_gun(k)
    arty_count.gun[#arty_count.gun + 1] = k
end
function Public.add_flame(k)
    arty_count.flame[#arty_count.flame + 1] = k
end

function Public.add_arty(k)
    arty_count.arty[#arty_count.arty + 1] = k
end


function Public.get_ammo()
    local index = arty_count.ammo_index
    local ammo_name = ammo[index].name
    return ammo_name
end


function Public.get(key)
  if key then
    return arty_count[key]
  else
    return arty_count
  end
end

function Public.check_and_add_to_attack_table(entity)
  if not entity or not entity.valid then return end
  if #arty_count.all == 0 then return end
  
  local entity_pos = entity.position
  for _, artillery in pairs(arty_count.all) do
    if artillery and artillery.valid then
      local artillery_pos = artillery.position
      local distance_squared = 
        (artillery_pos.x - entity_pos.x)^2 + 
        (artillery_pos.y - entity_pos.y)^2
      if distance_squared <= arty_count.radius * arty_count.radius then
        local already_exists = false
        for _, existing in pairs(arty_count.can_attack_table) do
          if existing == entity then
            already_exists = true
            break
          end
        end
        if not already_exists then
          arty_count.can_attack_table[#arty_count.can_attack_table + 1] = entity
        end
        return
      end
    end
  end
end


local function fast_remove(tbl, index)
    local count = #tbl
    if index > count then
        return
    elseif index < count then
        tbl[index] = tbl[count]
    end

    tbl[count] = nil
end

local function gun_bullet()
    for index = 1, #arty_count.gun do
        local turret = arty_count.gun[index]
        if not (turret and turret.valid) then
            fast_remove(arty_count.gun, index)
            return
        end
        local index = arty_count.ammo_index
        local ammo_name = ammo[index].name
        turret.insert {
            name = ammo_name,
            count = 200
        }
    end
end

local function flame_bullet()
    for index = 1, #arty_count.flame do
        local turret = arty_count.flame[index]
        if not (turret and turret.valid) then
            fast_remove(arty_count.flame, index)
            return
        end

        turret.fluidbox[1] = {
            name = 'light-oil',
            amount = 100
        }

    end
end

local function energy_bullet()

    for index = 1, #arty_count.laser do
        local turret = arty_count.laser[index]
        if not (turret and turret.valid) then
            fast_remove(arty_count.laser, index)
            return
        end
        turret.energy = 99999999
    end
end

-- 清理附近旧奖励箱
function Public.cleanup_nearby_reward_chests(position, surface)
    local search_radius = 30
    local area = {
        left_top = {position.x - search_radius, position.y - search_radius},
        right_bottom = {position.x + search_radius, position.y + search_radius}
    }
    
    local chests_to_remove = surface.find_entities_filtered({
        name = {"steel-chest", "crash-site-chest-1", "crash-site-chest-2"},
        area = area
    })
    
    for _, chest in pairs(chests_to_remove) do
        if chest and chest.valid then
            if not (chest.destructible == false and chest.minable == false) then
                chest.destroy()
            end
        end
    end
end

-- 创建清理任务（分批处理）
function Public.create_cleanup_tasks(position, surface, baolei_id)
    local k = 30
    local area = {
        left_top = {position.x - k, position.y - k},
        right_bottom = {position.x + k, position.y + k}
    }
    
    -- 分批查找实体以避免一次性加载过多数据
    local entity_types = {"unit", "tree", "simple-entity", "cliff", "land-mine", "cargo-wagon", "fluid-wagon", "chest"}
    for _, entity_type in pairs(entity_types) do
        local entities_to_remove = surface.find_entities_filtered({
            type = entity_type,
            area = area
        })
        
        -- 将清理工作分批处理
        local batch_size = 20  -- 每批处理20个实体
        for i = 1, #entities_to_remove, batch_size do
            local batch = {}
            for j = i, math.min(i + batch_size - 1, #entities_to_remove) do
                batch[#batch + 1] = entities_to_remove[j]
            end
            
            Public.add_batch_task({
                type = "cleanup_entities",
                baolei_id = baolei_id,
                func = function(batch_entities)
                    for _, e in pairs(batch_entities) do
                        if e and e.valid then
                            if e.name == "land-mine" then
                                if e.force and e.force.name == "player" then
                                    e.destroy()
                                end
                            else
                                e.destroy()
                            end
                        end
                    end
                end,
                params = {batch}
            })
        end
    end
end

-- 创建地形设置任务（分批处理）
function Public.create_terrain_tasks(position, surface, baolei_id)
    local dis = 44
    local positions_to_set = {}
    
    -- 收集所有需要设置的地形位置
    for a = 1, dis do
        for b = 1, dis do
            positions_to_set[#positions_to_set + 1] = {
                name = "sand-1",
                position = {position.x - dis * 0.5 + a, position.y - dis * 0.5 + b}
            }
        end
    end
    
    -- 分批设置地形
    local batch_size = 50  -- 每批设置50个地块
    for i = 1, #positions_to_set, batch_size do
        local batch = {}
        for j = i, math.min(i + batch_size - 1, #positions_to_set) do
            batch[#batch + 1] = positions_to_set[j]
        end
        
        Public.add_batch_task({
            type = "set_terrain",
            baolei_id = baolei_id,
            func = function(terrain_batch)
                surface.set_tiles(terrain_batch)
            end,
            params = {batch}
        })
    end
end

-- 创建核心建筑任务
function Public.create_core_building_tasks(position, surface, robot_number, fix_number, something, baolei_id)
    Public.add_batch_task({
        type = "create_roboport",
        baolei_id = baolei_id,
        func = function()
            local roboport = surface.create_entity({
                name = "roboport",
                position = position,
                force = "enemy"
            })
            
            if roboport and roboport.valid then
                if construction_queue.active_constructions and construction_queue.active_constructions[baolei_id] then
                    construction_queue.active_constructions[baolei_id].roboport = roboport
                    construction_queue.active_constructions[baolei_id].all_thing[#construction_queue.active_constructions[baolei_id].all_thing + 1] = roboport
                    arty_count.roboport_wave[roboport.unit_number] = construction_queue.active_constructions[baolei_id].wave_number
                end
                if arty_count.arty and arty_count.arty[baolei_id] then
                    arty_count.arty[baolei_id].roboport = roboport
                    arty_count.arty[baolei_id].baolei_id = baolei_id
                end
            
                
                if robot_number >= 350 then robot_number = 350 end
                if fix_number >= 700 then fix_number = 700 end
                
                roboport.insert { name = "repair-pack", count = fix_number }
                roboport.insert { name = "construction-robot", count = robot_number }
                roboport.destructible = false
                
                arty_count.laser[#arty_count.laser + 1] = roboport
            end
        end,
        params = {}
    })
    
    Public.add_batch_task({
        type = "create_chest_and_inserter",
        baolei_id = baolei_id,
        func = function()
            if not construction_queue.active_constructions or not construction_queue.active_constructions[baolei_id] then
                return
            end
            local construction = construction_queue.active_constructions[baolei_id]
            local position = construction.position
            local surface = construction.surface
            local something = construction.something
            
            local chest = surface.create_entity({
                name = "storage-chest",
                position = { x = position.x, y = position.y - 3 },
                force = "enemy"
            })
            
            local inserter = surface.create_entity({
                name = "bulk-inserter",
                position = { x = position.x, y = position.y - 2 },
                force = "enemy"
            })
            
            if chest and chest.valid then
                chest.destructible = false
                construction.all_thing[#construction.all_thing + 1] = chest
                
                
                if something ~= nil then
                    for _, v in pairs(something) do
                        if v.number ~= 0 then
                            chest.insert({ name = v.name, count = v.number })
                        end
                    end
                end
            end
            
            if inserter and inserter.valid then
                inserter.destructible = false
                construction.all_thing[#construction.all_thing + 1] = inserter
                arty_count.all[#arty_count.all + 1] = inserter
                arty_count.laser[#arty_count.laser + 1] = inserter
            end
        end,
        params = {}
    })
end

-- 创建内层墙壁任务（分批处理）
function Public.create_inner_wall_tasks(position, surface, baolei_id)
    local wall_batches = {}
    
    -- 收集所有内层墙壁位置
    local wall_positions = {}
    
    -- 上侧墙壁 (14个)
    for i = 1, 14 do
        wall_positions[#wall_positions + 1] = { position.x - 19 + i, position.y - 18 }
    end
    
    -- 右上侧墙壁 (18个)
    for i = 1, 18 do
        wall_positions[#wall_positions + 1] = { position.x + i, position.y - 18 }
    end
    
    -- 下侧墙壁 (36个)
    for i = 1, 36 do
        wall_positions[#wall_positions + 1] = { position.x - 18 + i, position.y + 18 }
    end
    
    -- 左侧墙壁 (36个)
    for i = 1, 36 do
        wall_positions[#wall_positions + 1] = { position.x - 18, position.y - 18 + i }
    end
    
    -- 右侧墙壁 (36个)
    for i = 1, 36 do
        wall_positions[#wall_positions + 1] = { position.x + 18, position.y - 18 + i }
    end
    
    -- 分批创建墙壁
    local batch_size = 10  -- 每批创建10个墙壁
    for i = 1, #wall_positions, batch_size do
        local batch = {}
        for j = i, math.min(i + batch_size - 1, #wall_positions) do
            batch[#batch + 1] = wall_positions[j]
        end
        
        Public.add_batch_task({
            type = "create_inner_walls",
            baolei_id = baolei_id,
            func = function(wall_batch)
                if not construction_queue.active_constructions or not construction_queue.active_constructions[baolei_id] then
                    return
                end
                local construction = construction_queue.active_constructions[baolei_id]
                local surface = construction.surface
                
                for _, wall_pos in pairs(wall_batch) do
                    if surface.can_place_entity({
                        name = "stone-wall",
                        position = wall_pos,
                        force = game.forces.neutral
                    }) then
                        local e = surface.create_entity({
                            name = "stone-wall",
                            position = wall_pos,
                            force = game.forces.neutral
                        })
                        if e and e.valid then
                            construction.all_thing[#construction.all_thing + 1] = e
                            -- 只有需要击败的单位才注册到arty_count.unit表
                            if e.name ~= "stone-wall" then
                                arty_count.unit[e.unit_number] = baolei_id
                            end
                        end
                    end
                end
            end,
            params = {batch}
        })
    end
end

-- 创建炮台任务（根据价值点系统）
function Public.create_turret_tasks(position, surface, wave_number, baolei_id)
    local this = WPT.get()

    local all_worth = wave_number  * 1.05
    local fix_function = wave_number - 500
    if fix_function < 0 then fix_function = 0 end
    if fix_function > 1000 then fix_function = 1000 end
    
    local fix_worth = 0
    if all_worth <= 20 then all_worth = 20 end
    if all_worth >= 1200 then
        fix_worth = all_worth - 1200
        all_worth = 1000
    end
    
    local can_build_turret = {}
    for i, building in pairs(enemy_turret) do
        if wave_number >= building.wave_number then
            if this.world_number ~= 8 then
                can_build_turret[#can_build_turret + 1] = building
            else
                if not building.ban then
                    can_build_turret[#can_build_turret + 1] = building
                end
            end
        end
    end

    local something = {
        [1] = { name = 'laser-turret', worth = 10, wave_number = 100, index = 4, number = 0 },
        [2] = { name = 'gun-turret', worth = 5, wave_number = 100, index = 5, number = 0 },
        [3] = { name = 'flamethrower-turret', worth = 10, wave_number = 150, index = 6, number = 0 },
        [4] = { name = 'land-mine', worth = 1, wave_number = 100, index = 1, number = 0 }
    }

    if wave_number >= 1300 then
        something[5] = {
            name = 'artillery-turret',
            worth = 100,
            wave_number = 1300,
            index = 7,
            number = 0
        }
    end

    -- 根据价值点分配炮台数量
    while all_worth > 0 do
        local index = math.random(1, #can_build_turret)
        local turret_data = can_build_turret[index]
        local turret_name = turret_data.name
        local worth = turret_data.worth
        
        Public.add_batch_task({
            type = "create_single_turret",
            baolei_id = baolei_id,
            func = function()
                if not construction_queue.active_constructions or not construction_queue.active_constructions[baolei_id] then
                    return
                end
                local construction = construction_queue.active_constructions[baolei_id]
                local position = construction.position
                local surface = construction.surface
                
                -- 获取随机品质
                local quality = select_quality_by_chance()
                
                local turret_pos = {
                    x = position.x + math.random(-18, 18),
                    y = position.y + math.random(-18, 18)
                }
                
            
                    local e = surface.create_entity({
                        name = turret_name,
                        position = turret_pos,
                        force = game.forces.enemy,
                        quality = quality,
                        direction = math.random(0, 3)*4
                    })

                    -- if turret_name == 'flamethrower-turret' then
                    --     e.direction = math.random(1, 7)
                    -- end
                    
                    if e and e.valid then
                        construction.all_thing[#construction.all_thing + 1] = e
                        
                        if e.name == 'gun-turret' then
                            arty_count.gun[#arty_count.gun + 1] = e
                        end
                        if e.name == 'laser-turret' then
                            arty_count.laser[#arty_count.laser + 1] = e
                        end
                        if e.name == 'flamethrower-turret' then
                            arty_count.flame[#arty_count.flame + 1] = e
                        end
                        if e.name == 'artillery-turret' then
                            arty_count.all[#arty_count.all + 1] = e
                            arty_count.fire[#arty_count.fire + 1] = 0
                            arty_count.count = arty_count.count + 1
                        end
                        
                        -- 只有需要击败的单位才注册到arty_count.unit表并增加计数
                        if e.name ~= "stone-wall" then
                            arty_count.unit[e.unit_number] = baolei_id
                            arty_count.arty[baolei_id].number = arty_count.arty[baolei_id].number + 1
                        end
                    end
                
            end,
            params = {}
        })
        
        all_worth = all_worth - worth
    end
    
    -- 处理修复包价值点
    while fix_worth > 0 do
        local index = math.random(1, #something)
        local worth = something[index].worth
        fix_worth = fix_worth - worth
        something[index].number = something[index].number + 1
    end
end

-- 创建外层墙壁任务（分批处理）
function Public.create_outer_wall_tasks(position, surface, baolei_id)
    local wall_positions = {}
    
    -- 上侧外层墙壁 (18个)
    for i = 1, 18 do
        wall_positions[#wall_positions + 1] = { position.x - 24 + i, position.y - 23 }
    end
    
    -- 右上侧外层墙壁 (23个)
    for i = 1, 23 do
        wall_positions[#wall_positions + 1] = { position.x + i, position.y - 23 }
    end
    
    -- 下侧外层墙壁 (46个)
    for i = 1, 46 do
        wall_positions[#wall_positions + 1] = { position.x - 23 + i, position.y + 23 }
    end
    
    -- 左侧外层墙壁 (46个)
    for i = 1, 46 do
        wall_positions[#wall_positions + 1] = { position.x - 23, position.y - 23 + i }
    end
    
    -- 右侧外层墙壁 (46个)
    for i = 1, 46 do
        wall_positions[#wall_positions + 1] = { position.x + 23, position.y - 23 + i }
    end
    
    -- 分批创建外层墙壁
    local batch_size = 8  -- 每批创建8个外层墙壁（因为外层墙壁更多）
    for i = 1, #wall_positions, batch_size do
        local batch = {}
        for j = i, math.min(i + batch_size - 1, #wall_positions) do
            batch[#batch + 1] = wall_positions[j]
        end
        
        Public.add_batch_task({
            type = "create_outer_walls",
            baolei_id = baolei_id,
            func = function(wall_batch)
                if not construction_queue.active_constructions or not construction_queue.active_constructions[baolei_id] then
                    return
                end
                local construction = construction_queue.active_constructions[baolei_id]
                local surface = construction.surface
                
                for _, wall_pos in pairs(wall_batch) do
                    if surface.can_place_entity({
                        name = "stone-wall",
                        position = wall_pos,
                        force = game.forces.neutral
                    }) then
                        local e = surface.create_entity({
                            name = "stone-wall",
                            position = wall_pos,
                            force = game.forces.neutral
                        })
                        if e and e.valid then
                            construction.all_thing[#construction.all_thing + 1] = e
                           
                            
                            -- 只有需要击败的单位才注册到arty_count.unit表
                            if e.name ~= "stone-wall" then
                                arty_count.unit[e.unit_number] = baolei_id
                            end
                        end
                    end
                end
            end,
            params = {batch}
        })
    end
end

-- 销毁堡垒的所有墙
local function kill_wall(baolei_id)
    if arty_count.neet_to_kill[baolei_id] then
        for i, v in pairs(arty_count.neet_to_kill[baolei_id]) do
            if v and v.valid and v.name ~= '' and v.name ~= 'roboport' then
                v.destructible = true
                v.die()
            end
        end
    end
end

local function check_roboport_destructible()
    if not arty_count.arty then
        return
    end
    
    local turret_types = {
        "gun-turret",
        "laser-turret", 
        "flamethrower-turret",
        "artillery-turret",
        "small-worm-turret",
        "medium-worm-turret",
        "big-worm-turret",
        "behemoth-worm-turret"
    }
    
    for baolei_id, baolei_data in pairs(arty_count.arty) do
        if baolei_data and baolei_data.roboport and baolei_data.roboport.valid then
            if not baolei_data.roboport.destructible then
                local actual_turret_count = 0
                
                if arty_count.neet_to_kill[baolei_id] then
                    for _, entity in pairs(arty_count.neet_to_kill[baolei_id]) do
                        if entity and entity.valid then
                            for _, turret_name in ipairs(turret_types) do
                                if entity.name == turret_name then
                                    actual_turret_count = actual_turret_count + 1
                                    break
                                end
                            end
                        end
                    end
                end
                
                if actual_turret_count == 0 then
                    baolei_data.roboport.destructible = true
                    baolei_data.number = 0
                    kill_wall(baolei_id)
                end
            end
        end
    end
end
-- 检测堡垒有效性并重新统计堡垒数量
function Public.recount_baolei()
    local this = WPT.get()
    local valid_count = 0
    
    -- 遍历所有堡垒，只检查机器人平台是否有效
    if arty_count.arty then
        for baolei_id, baolei_data in pairs(arty_count.arty) do
            local baolei_valid = false
            
            -- 只检查堡垒对应的机器人平台是否有效
            if baolei_data and baolei_data.roboport and baolei_data.roboport.valid then
                baolei_valid = true
            end
            
            -- 如果机器人平台有效，则计数
            if baolei_valid then
                valid_count = valid_count + 1
            else
                -- 清理无效的堡垒记录
                arty_count.arty[baolei_id] = nil
                if arty_count.neet_to_kill then
                    arty_count.neet_to_kill[baolei_id] = nil
                end
                if arty_count.baolei_creation_times then
                    arty_count.baolei_creation_times[baolei_id] = nil
                end
                if construction_queue.active_constructions then
                    construction_queue.active_constructions[baolei_id] = nil
                end
            end
        end
    end
    
    -- 更新堡垒数量
    this.baolei_count = valid_count
    
    return valid_count
end
-- 完成堡垒创建的收尾工作
function Public.finish_baolei_construction(baolei_id)
    if not construction_queue.active_constructions then
        return
    end
    local construction = construction_queue.active_constructions[baolei_id]
    if construction and construction.all_thing then
        arty_count.neet_to_kill[baolei_id] = construction.all_thing
        
        -- 增加堡垒计数
        local this = WPT.get()
        this.baolei_count = this.baolei_count + 1
        
        -- 先清理arty_count.attack_table中无效的物体
        for i = #arty_count.attack_table, 1, -1 do
            local e = arty_count.attack_table[i]
            if not e or not e.valid then
                table.remove(arty_count.attack_table, i)
            end
        end

        -- 检测重炮目标
        local function check_artillery_targets()
            for _, artillery in pairs(arty_count.all) do
                if artillery and artillery.valid then
                    local artillery_pos = artillery.position
                    for _, entity_name in pairs(artillery_target_entities) do
                        for _, target_entity in pairs(construction.surface.find_entities_filtered({
                            name = entity_name,
                            position = artillery_pos,
                            radius = arty_count.radius,
                            force = game.forces.player
                        })) do
                            if target_entity and target_entity.valid then
                                -- 如果不在攻击表中，则添加
                                local already_exists = false
                                    for _, existing in pairs(arty_count.can_attack_table) do
                                        if existing == target_entity then
                                            already_exists = true
                                            break
                                        end
                                    end
                                    if not already_exists then
                                        arty_count.can_attack_table[#arty_count.can_attack_table + 1] = target_entity
                                    end
                            end
                        end
                    end
                end
            end
        end
        
        -- 如果有重炮，则检测目标
        if #arty_count.all > 0 then
            check_artillery_targets()
        end

        -- 添加地雷
        local mind_number = construction.wave_number * 0.01
        for i = 1, 14 + mind_number do
            construction.surface.create_entity({
                name = "land-mine",
                position = {
                    x = construction.position.x + math.random(-18, 18) * 1.5,
                    y = construction.position.y + math.random(-18, 18) * 1.5
                },
                force = game.forces.enemy
            })
        end

        -- 生成宝箱
        local many_baozhang = math.floor(construction.wave_number * 0.008)
        if many_baozhang > 10 then many_baozhang = 10 end
        
        local max_luck = construction.wave_number * 0.2 + 100
        local min_luck = construction.wave_number * 0.1 + 50
        if max_luck >= 800 then max_luck = 800 end
        if min_luck >= 500 then min_luck = 500 end

        for i = 1, many_baozhang do
            local magic = math.random(min_luck, max_luck)
            local chest_position = construction.surface.find_non_colliding_position("steel-chest", construction.position, 20, 1, true)
             
            -- 只有找到有效位置才创建宝箱
            if chest_position then
                local container
                -- 15%的概率生成品质宝箱
                if math.random(1, 100) <= 15 then
                    container = Loot.cool_with_quality(construction.surface, chest_position, 'steel-chest', magic)
                else
                    container = Loot.cool(construction.surface, chest_position, 'steel-chest', magic)
                end
                -- 设置宝箱不可摧毁
                if container and container.valid then
                    container.destructible = false
                end
            end
        end

        -- 在世界10和世界11时添加"曹营"文字标签
        if this.world_number == 10  and construction.roboport and construction.roboport.valid then
            rendering.draw_text({ 
                text = "曹营", 
                surface = construction.surface, 
                target = { 
                    entity = construction.roboport, 
                    offset = {0, -2.5} 
                }, 
                color = { 
                    r = 1, 
                    g = 1, 
                    b = 0, 
                    a = 1 
                }, 
                scale = 1.5, 
                font = 'default-large-semibold', 
                alignment = 'center', 
                scale_with_zoom = false 
            })
        end
    end
    
    -- 清理已完成的建设任务
    construction_queue.active_constructions[baolei_id] = nil
end

local function urgrade_ammo(wave_number)
    if wave_number > 500 and arty_count.ammo_index == 1 then
        arty_count.ammo_index = 2
    end

    if wave_number > 800 and arty_count.ammo_index == 2 then
        arty_count.ammo_index = 3
    end
end

function Public.baolei(position, wave_number, surface, cleanup_terrain)
    if cleanup_terrain == nil then
        cleanup_terrain = true
    end
    local this = WPT.get()
    game.print({'amap.biter_build' .. (this.world_number == 10 and '_world10' or ''), position.x, position.y, surface.name})
    urgrade_ammo(wave_number)

    local all_worth = wave_number  * 1.05
    local fix_function = wave_number - 500
    if fix_function < 0 then
        fix_function = 0
    end
    if fix_function > 1000 then
        fix_function = 1000
    end
    local robot_number = 1 + math.floor(fix_function * 0.35)
    local fix_number = 1 + math.floor(fix_function * 0.7)
    local out_wall = false
    if wave_number >= 500 then
        out_wall = true
    end

    local fix_worth = 0
    if all_worth <= 20 then
        all_worth = 20
    end
    if all_worth >= 1200 then
        fix_worth = all_worth - 1200
        all_worth = 1000
    end

    local baolei_id = #arty_count.arty + 1
    arty_count.arty[baolei_id] = {}
    arty_count.arty[baolei_id].number = 0
    arty_count.arty[baolei_id].roboport = {}

    local something = {
        [1] = {
            name = 'laser-turret',
            worth = 10,
            wave_number = 100,
            index = 4,
            number = 0
        },
        [2] = {
            name = 'gun-turret',
            worth = 5,
            wave_number = 100,
            index = 5,
            number = 0
        },
        [3] = {
            name = 'flamethrower-turret',
            worth = 10,
            wave_number = 150,
            index = 6,
            number = 0
        },
        [4] = {
            name = 'land-mine',
            worth = 1,
            wave_number = 100,
            index = 1,
            number = 0
        }
    }

    if wave_number >= 1300 then
        something[5] = {
            name = 'artillery-turret',
            worth = 100,
            wave_number = 1300,
            index = 7,
            number = 0
        }
    end

    while fix_worth > 0 do
        local index = math.random(1, #something)
        local worth = something[index].worth
        fix_worth = fix_worth - worth
        something[index].number = something[index].number + 1
    end

    Public.start_baolei_construction(position, wave_number, surface, robot_number, fix_number, out_wall, something, baolei_id, cleanup_terrain)
    
    -- 记录堡垒创建时间
    if not arty_count.baolei_creation_times then
        arty_count.baolei_creation_times = {}
    end
    arty_count.baolei_creation_times[baolei_id] = game.tick

    if wave_number >= 2000  then
        -- 获取随机品质
        local quality = select_quality_by_chance()
        
        local e = surface.create_entity({
            name = 'artillery-turret',
            position = {
                x = position.x,
                y = position.y
            },
            force = game.forces.enemy,
            direction = math.random(0, 3)*4,
            quality = quality
        })
        arty_count.all[#arty_count.all + 1] = e
        arty_count.fire[#arty_count.fire + 1] = 0
        arty_count.count = arty_count.count + 1
        
        -- 将重炮添加到 all_thing 表中，以便秒杀时能正确销毁
        if construction_queue.active_constructions and construction_queue.active_constructions[baolei_id] then
            construction_queue.active_constructions[baolei_id].all_thing[#construction_queue.active_constructions[baolei_id].all_thing + 1] = e
        end
    end
end

local function calc_players()
    local players = game.connected_players
    local total = 0
    for i = 1, #players do
        local player = players[i]
        if player.afk_time < 36000 then
            total = total + 1
        end
    end
    if total <= 0 then
        total = 1
    end
    return total
end

local function get_new_arty()
    -- 增加检查次数计数器
    arty_count.arty_check_count = arty_count.arty_check_count + 1
    
    local this = WPT.get()
    
    -- 根据世界类型决定基础生成间隔
    local base_interval = 20
    if this.world_number == 7 or this.world_number == 9 or this.world_number == 11 or this.world_number == 12 then
        base_interval = 35
    end
    
    -- 根据玩家数量和堡垒数量调整生成间隔
    local player_count = calc_players()
    local generate_interval = base_interval
    
    -- 应用加速奖励（如果上一个堡垒在3分钟内被摧毁）
    if arty_count.next_baolei_speed_bonus > 0 then
        generate_interval = generate_interval - arty_count.next_baolei_speed_bonus
        arty_count.next_baolei_speed_bonus = 0  -- 重置奖励
    end
    
    if this.baolei_count <= 0 then
        generate_interval = generate_interval - 5
    else
        if player_count == 1 then
            generate_interval = generate_interval + 5
        elseif player_count >= 3 then
            local extra_players = player_count - 1
            local speed_up = math.floor(extra_players / 2)
            generate_interval = generate_interval + 5 - speed_up
        end
    end
    
    if generate_interval < 5 then
        generate_interval = 5
    end
    
    if arty_count.arty_check_count < generate_interval then
        return
    end
    
    arty_count.arty_check_count = 0

    local wave_number = WD.get('wave_number')
    local start_nuamber = 250
    --如果没有火箭发射井，但是标签存在，则移除标签
    if not this.baolei_silo or not this.baolei_silo.valid then
         if this.silo_tag  then
        this.silo_tag.destroy()
        this.silo_tag = nil
    end
       
    end
   
    if this.world_number == 7 or this.world_number == 9 or this.world_number == 11 or this.world_number == 12 then
        start_nuamber = 250
        if not this.baolei_silo or not this.baolei_silo.valid then
            this.baolei_silo = nil
        end
    end
    if this.world_number == 7 then
        start_nuamber = 150
    end
    if wave_number < start_nuamber then
        return
    end
    if (this.world_number == 7 or this.world_number == 9 or this.world_number == 11 or this.world_number == 12) and this.baolei_count > 1 then
        if this.baolei_silo and this.baolei_silo.valid then
            game.print('警告：敌方火箭发射架将在3分钟后发射核弹！', {255, 0, 0})
            game.print('警告：敌方火箭发射架将在3分钟后发射核弹！！', {255, 0, 0})
            game.print('警告：敌方火箭发射架将在3分钟后发射核弹！！！', {255, 0, 0})

            for abcd = 1, 10 do
                Task.set_timeout_in_ticks(60 * 60 * 3 * abcd, shot_hd, this.baolei_silo)
            end
            return
        end
    end

    local wave_defense_table = WD.get_table()
    if not wave_defense_table.target then
        return
    end
    if not wave_defense_table.target.valid then
        return
    end
    local target = wave_defense_table.target
    local surface = target.surface

    local temp_pos
    local position
    if this.world_number == 7 or this.world_number == 9 or this.world_number == 11 or this.world_number == 12 then
        temp_pos = target.position
        if (this.baolei_y ~= 0 and this.world_number == 7) or (this.baolei_y ~= 0 and this.world_number == 9) or (this.baolei_y ~= 0 and this.world_number == 11) or (this.baolei_y ~= 0 and this.world_number == 12) then
            temp_pos.y = this.baolei_y
        end
        local juli = 65
        local entities = surface.count_entities_filtered {
            position = temp_pos,
            radius = juli,
            name = player_build,
            force = game.forces.player,
            limit = 1
        }
        while entities ~= 0 do
            temp_pos = {
                x = 0,
                y = temp_pos.y - 115
            }
            entities = surface.count_entities_filtered {
                position = temp_pos,
                radius = juli,
                name = player_build,
                force = game.forces.player,
                limit = 1
            }
        end

        this.baolei_y = temp_pos.y
        position = wave_defense_table.spawn_position
    else
        local only_below = false
        if this.world_number == 10 then 
            only_below = true
        end
        position = get_baolei_pos(target.position, 120, surface, target,only_below)
    
    end
    if this.world_number == 8 then
        if math.abs(position.x) >= 300 or math.abs(position.y) >= 300 then
            position = wave_defense_table.spawn_position
        end
    end
    if position == nil then
        return
    end
    if this.world_number ~= 7 and this.world_number ~= 9 and this.world_number ~= 11 and this.world_number ~= 12 then
        Public.baolei(position, wave_number, surface)
    end

    if this.world_number == 7 or this.world_number == 9 or this.world_number == 11 or this.world_number == 12 then
           Public.recount_baolei()
        if this.baolei_count > 1 then
            this.baolei_silo = surface.create_entity({
                name = "rocket-silo",
                position = {
                    x = 0,
                    y = this.baolei_y - 50
                },
                force = "enemy"
            })

                        this.silo_tag=game.forces.player.add_chart_tag(surface, {
        position =  this.baolei_silo.position,
        icon = { type = "entity", name = "rocket-silo" },
        text = '敌方核弹发射井',
    })
            this.baolei_silo.destructible = false
            game.print({'amap.biter_build_hd', 0, this.baolei_y - 50, surface.name}, {255, 0, 0})
            game.print('注意：你必须摧毁所有堡垒，才能对核弹发射井造成伤害！', {255, 0, 0})
            game.print('注意：你必须摧毁所有堡垒，才能对核弹发射井造成伤害！！', {255, 0, 0})
            return
        else
            Public.baolei({
                x = -65,
                y = this.baolei_y
            }, wave_number, surface)
            Public.baolei({
                x = 65,
                y = this.baolei_y
            }, wave_number, surface)
            Public.baolei({
                x = 0,
                y = this.baolei_y
            }, wave_number, surface)
        end

    end

end

local artillery_target_callback = Token.register(function(data)
    local position = data.position
    local entity = data.entity

    if not entity.valid then
        return
    end

    local tx, ty = position.x, position.y
    local pos = entity.position
    local x, y = pos.x, pos.y
    local dx, dy = tx - x, ty - y
    local d = dx * dx + dy * dy
    if d <= arty_count.radius*arty_count.radius then
        local use_rocket = false
        
        if entity.name == 'spidertron' then
            use_rocket = true
        elseif entity.type == 'character' then
            local player = entity.player
            if player and player.valid then
                local armor_inv = player.get_inventory(defines.inventory.character_armor)
                if armor_inv and armor_inv[1] and armor_inv[1].valid_for_read then
                    local armor_name = armor_inv[1].name
                    if armor_name == 'mech-armor' then
                        use_rocket = true
                    end
                end
            end
        end
        
        if use_rocket then
            entity.surface.create_entity({
                name = 'rocket',
                position = position,
                target = entity,
                force = 'enemy',
                speed = arty_count.pace
            })
        else
            entity.surface.create_entity({
                name = 'artillery-projectile',
                position = position,
                target = entity,
                force = 'enemy',
                speed = arty_count.pace
            })
        end
    end
end)

local remove_steel_chests_callback = Token.register(function(data)
    local position = data.position
    local surface = data.surface
    local k = 8
    local area_1 = {
        left_top = {position.x - k, position.y - k},
        right_bottom = {position.x + k, position.y + k}
    }
    for _, e in pairs(surface.find_entities_filtered({
        name = {"steel-chest", "crash-site-chest-1", "crash-site-chest-2"},
        area = area_1
    })) do
        e.destroy()
    end
    for unit_number, _ in pairs(arty_count.roboport_wave) do
        arty_count.roboport_wave[unit_number] = 1
    end
end)

local function add_bullet()
    flame_bullet()
end
local function energy()
    energy_bullet()
end

local function do_artillery_turrets_targets()


    if arty_count.count <= 0 then
        return
    end
    
    -- 清理can_attack_table中的无效实体
    for i = #arty_count.can_attack_table, 1, -1 do
        local e = arty_count.can_attack_table[i]
        if not e or not e.valid then
            table.remove(arty_count.can_attack_table, i)
        end
    end
    
    if not arty_count.can_attack_table then
        arty_count.can_attack_table = {}
    end
    if not arty_count.attack_table then
        arty_count.attack_table = {}
    end


    arty_count.index = arty_count.index + 1
    if arty_count.index > arty_count.count then
        arty_count.index = 1
    end

    local index = arty_count.index
    local turret = arty_count.all[index]

    if not (turret and turret.valid) then
        fast_remove(arty_count.all, index)
        fast_remove(arty_count.fire, index)
        arty_count.count = arty_count.count - 1
        return
    end

    local now = game.tick
    if not arty_count.fire[index] then
        arty_count.fire[index] = 0
    end
    if (now - arty_count.fire[index]) < 360 then
        return
    end
    arty_count.fire[index] = now

    local position = arty_count.all[index].position

    local this = WPT.get()
    if not this.active_surface_index or not game.surfaces[this.active_surface_index] then return end

    -- Create a combined list of targets: online players + can_attack_table entities
    local entities = {}
    
    -- Add all online players
    local arty_surface = arty_count.all[index].surface
    for _, player in pairs(game.connected_players) do
        if player and player.valid and player.character and player.character.valid then
            if player.physical_surface ~= arty_surface then
                goto continue
            end
            local player_pos = player.character.position
            -- Check if player is within radius of the artillery (compare squares instead of sqrt)
            local distance_squared =
                (position.x - player_pos.x)^2 +
                (position.y - player_pos.y)^2
            if distance_squared <= arty_count.radius * arty_count.radius then
                entities[#entities + 1] = player.character
            end
            ::continue::
        end
    end
    
    -- Add entities from can_attack_table that are valid and within radius
    for _, target_entity in pairs(arty_count.can_attack_table) do
        if target_entity and target_entity.valid then
            local target_pos = target_entity.position
            local distance_squared = 
                (position.x - target_pos.x)^2 + 
                (position.y - target_pos.y)^2
            if distance_squared <= arty_count.radius * arty_count.radius then
                entities[#entities + 1] = target_entity
            end
        end
    end

    if #entities == 0 then
        return
    end


    local count = 1
    if arty_count.count > 4 then
        count = math.floor(arty_count.count * 0.5)
    else
        count = arty_count.count
    end
    

    -- 开火
    for i = 1, count do
        local entity = entities[math.random(#entities)]
        if entity and entity.valid then
            local data = {
                position = position,
                entity = entity
            }
            Task.set_timeout_in_ticks(i * 60, artillery_target_callback, data)
        end
    end
end



local function on_entity_died(event)
    local entity = event.entity

    if not entity.valid or not entity then
        return
    end

    local surface = entity.surface

    if entity.name== 'nuclear-reactor' then

   

    local position = entity.position
    
    -- Factorio 一个区块是 32x32 格
    -- 计算中心点所在的区块坐标
    local chunk_x = math.floor(position.x / 32)
    local chunk_y = math.floor(position.y / 32)
    
    -- 为了防止反应堆正好压在区块边缘，建议覆盖反应堆可能接触到的周围区块
    -- 反应堆大小是 5x5。这里为了保险，我们处理中心区块以及相邻的区块
    -- 如果你想“狠一点”，可以扩大半径，比如 radius = 1 (3x3个区块)
    local radius = 1
    
    game.print({'amap.reactor_meltdown_warning'})

    -- 遍历需要重置的区块
    for x = chunk_x - radius, chunk_x + radius do
        for y = chunk_y - radius, chunk_y + radius do
            local current_chunk_pos = {x = x, y = y}
            
            -- 1. 删除区块：这将移除该区域内所有玩家建筑、地形修改、掉落物
            surface.delete_chunk(current_chunk_pos)
        end
    end

    -- 2. 请求重新生成：游戏会根据原始地图种子重新生成地形
    -- 这会将地形恢复为“出厂设置”（例如：原本是草地的地方变回草地，人工岩浆消失）
    surface.request_to_generate_chunks(position, radius)
    
    -- 强制立即执行生成请求（可选，防止出现黑色虚空等待加载）
    surface.force_generate_chunk_requests()

    local wave_number = WD.get('wave_number')
    if wave_number <= 500 then
        wave_number = 500
    end
    Public.baolei(position, wave_number, surface, false)

    local remove_data = {
        position = position,
        surface = surface
    }
    Task.set_timeout_in_ticks(600, remove_steel_chests_callback, remove_data)

    
    end

    local force = event.entity.force
    if force ~= game.forces.enemy then
        return
    end
    local name = event.entity.name
    if arty_count.unit[entity.unit_number] then
        local unit_number = entity.unit_number
        local baolei_id = arty_count.unit[unit_number]
        arty_count.arty[baolei_id].number = arty_count.arty[baolei_id].number - 1
        if arty_count.arty[baolei_id].number <= 0 then
            arty_count.arty[baolei_id].roboport.destructible = true
            kill_wall(baolei_id)
        end
        arty_count.unit[unit_number] = nil

    end

    if name ~= "roboport" then

        return
    end

    local position = entity.position
    local surface = entity.surface

    local k = 8
    local area_1 = {
        left_top = {position.x - k, position.y - k},
        right_bottom = {position.x + k, position.y + k}
    }

    for _, e in pairs(surface.find_entities_filtered({
        name = {"steel-chest", "crash-site-chest-1", "crash-site-chest-2"},
        area = area_1
    })) do
        e.operable = true
        e.minable = true
        e.force = game.forces.player
    end

    local unit_number = entity.unit_number
    local wave_number = arty_count.roboport_wave[unit_number]
    arty_count.roboport_wave[unit_number] = nil

    local baolei_id
    for i, v in pairs(arty_count.arty) do
        local id = i  -- 直接使用循环索引
        if v.roboport == entity then
            baolei_id = id
            break
        end
    end
    
    -- 检查堡垒是否在4分钟内被销毁
    if baolei_id and arty_count.baolei_creation_times and arty_count.baolei_creation_times[baolei_id] then
        local creation_tick = arty_count.baolei_creation_times[baolei_id]
        local current_tick = game.tick
        local ticks_alive = current_tick - creation_tick
        local three_minutes_ticks = 60 * 60 * 4  -- 3分钟 = 180秒 = 10800 ticks
        
        if ticks_alive < three_minutes_ticks then
            -- 堡垒在4分钟内被销毁，下一个堡垒建设时间加快5分钟
            arty_count.next_baolei_speed_bonus = 5
        end
        
        -- 清理创建时间记录
        arty_count.baolei_creation_times[baolei_id] = nil
    end
    
    if baolei_id then
        arty_count.arty[baolei_id] = nil
    end
    
 
    
    -- 批量清理arty_count.unit表中属于该堡垒的所有单位索引，避免内存泄漏
    if baolei_id then
        for unit_number, associated_baolei_id in pairs(arty_count.unit) do
            if associated_baolei_id == baolei_id then
                arty_count.unit[unit_number] = nil
            end
        end
    end
    local this = WPT.get()
    this.baolei_count = this.baolei_count - 1
    
    if this.world_number == 9 or this.world_number == 11 or this.world_number == 12 then
        if this.baolei_silo and not this.baolei_silo.valid then
            this.baolei_silo = nil
        end
        if this.baolei_count <= 0 then
            if this.baolei_silo and this.baolei_silo.valid then
                this.baolei_silo.destructible = true
            end

            this.baolei_count = 0
        end
    end

    game.print({'amap.baolei_die' .. (this.world_number == 10 and '_world10' or '')})

    if not event.cause then
        return
    end
    if not event.cause.valid then
        return
    end


    if event.cause.name ~= 'character' then
        return
    end

    if not event.cause.player then
        return
    end

    local player = event.cause.player
    local rpg_t = RPG.get('rpg_t')

    player.insert {
        name = "coin",
        count = wave_number * 5 * 2.5
    }
    rpg_t[player.index].xp = rpg_t[player.index].xp + wave_number
    game.print({'amap.kill_baolei' .. (this.world_number == 10 and '_world10' or ''), player.name, wave_number, wave_number * 5 * 2.5})

end

local function on_robot_built_entity(event)
 
    local e = event.entity
    if not e or not e.valid then
        return
    end
    if e.surface.name ~= 'nauvis' then
        return
    end
    if e.force == game.forces.player then
        --如果e的名字在，artillery_target_entities表，则添加到arty_count.targets表中
        if table.contains(artillery_target_entities, e.name) then
            table.insert(arty_count.attack_table, e)
             --如果重炮数量不为0，则判断是否可以加入can_attack_table表中
        if #arty_count.all > 0 then
            -- 立即检查这个新建实体是否在重炮攻击范围内
            if e and e.valid then
                local entity_pos = e.position
                for _, artillery in pairs(arty_count.all) do
                    if artillery and artillery.valid then
                        local artillery_pos = artillery.position
                        local distance_squared = 
                            (artillery_pos.x - entity_pos.x)^2 + 
                            (artillery_pos.y - entity_pos.y)^2
                        if distance_squared <= arty_count.radius * arty_count.radius then
                            -- 检查是否已经在can_attack_table中
                
                                arty_count.can_attack_table[#arty_count.can_attack_table + 1] = e
                            
                            break
                        end
                    end
                end
            end
        end
        end
       
    end

    if e.force ~= game.forces.enemy then
        return
    end

    if e then
        if e.name == 'gun-turret' then
            arty_count.gun[#arty_count.gun + 1] = e
        end
        if e.name == 'laser-turret' then
            arty_count.laser[#arty_count.laser + 1] = e
        end
        if e.name == 'flamethrower-turret' then
            arty_count.flame[#arty_count.flame + 1] = e
        end
        if e.name == 'artillery-turret' then
            arty_count.all[#arty_count.all + 1] = e
            arty_count.fire[#arty_count.fire + 1] = 0
            arty_count.count = arty_count.count + 1
            -- 立即搜索攻击范围内的目标
            local artillery_pos = e.position
            for _, entity_name in pairs(artillery_target_entities) do
                for _, target_entity in pairs(e.surface.find_entities_filtered({
                    name = entity_name,
                    position = artillery_pos,
                    radius = arty_count.radius,
                    force = game.forces.player
                })) do
                    if target_entity and target_entity.valid then
                        local already_exists = false
                        for _, existing in pairs(arty_count.can_attack_table) do
                            if existing == target_entity then
                                already_exists = true
                                break
                            end
                        end
                        if not already_exists then
                            arty_count.can_attack_table[#arty_count.can_attack_table + 1] = target_entity
                        end
                    end
                end
            end
        end

        if e.name ~= "land-mine" then
            for i, v in pairs(arty_count.arty) do
                if v.roboport and v.roboport.valid then
                    local pos = v.roboport.position
                    local x = pos.x
                    local y = pos.y
                    local dist_squared = x * x + y * y
                    if dist_squared <= 24 * 24 then
                        local baolei_id = v.baolei_id
                        arty_count.arty[baolei_id].number = arty_count.arty[baolei_id].number + 1
                        arty_count.unit[e.unit_number] = baolei_id

                        return
                    end
                end
            end
        end
    end
end

--Event.on_nth_tick(60*3, get_new_arty)
Event.on_nth_tick(60 * 60, get_new_arty)
--Event.on_nth_tick(60 * 3, get_new_arty)
Event.on_nth_tick(2000, gun_bullet)
Event.on_nth_tick(120, add_bullet)
Event.on_nth_tick(5, energy)
Event.on_nth_tick(10, do_artillery_turrets_targets)

-- 分批任务队列处理器
local function process_construction_queue()
    if not construction_queue.tasks then
        return
    end
    if not Public.has_pending_tasks() then
        return
    end
    
    -- 每tick执行最多5个任务，避免性能问题
    local max_tasks_per_tick = 5
    local executed_count = 0
    
    while Public.has_pending_tasks() and executed_count < max_tasks_per_tick do
        local task = Public.get_next_task()
        if task then
            local success = Public.execute_batch_task(task)
            if success then
                executed_count = executed_count + 1
            else
                -- 任务失败时记录错误，但继续处理其他任务
                game.print("分批任务执行失败: " .. task.type)
            end
        else
            break
        end
    end
end

-- 检查是否需要完成堡垒建设
local function check_finish_construction()
    -- 检查所有活跃的建设任务
    if construction_queue.active_constructions then
        for baolei_id, construction in pairs(construction_queue.active_constructions) do
            -- 检查该堡垒的所有任务是否都已执行完成
            if construction.current_index > construction.task_end_index then
                -- 所有任务都已完成，进行收尾工作
                Public.finish_baolei_construction(baolei_id)
                
            end
        end
    end
end

-- 添加事件处理器
Event.on_nth_tick(2, process_construction_queue)  -- 每tick检查并执行任务
Event.on_nth_tick(60, check_finish_construction)   -- 每秒检查建设完成情况
Event.on_nth_tick(1800, check_roboport_destructible)  -- 每30秒检查机器人平台是否应该可被摧毁

Event.add(defines.events.on_robot_built_entity, on_robot_built_entity, {

    {filter = "type", type = 'land-mine'},
    {filter = "type", type = 'character'},
    {filter = "type", type = 'car'},
     {filter = "type", type = 'wall'},
    {filter = "type", type = 'spider-vehicle'},
    {filter = "type", type = 'ammo-turret'},
    {filter = "type", type = 'electric-turret'},
    {filter = "type", type = 'fluid-turret'},
    {filter = "type", type = 'radar'},
    {filter = "type", type = 'roboport'}
})
Event.add(defines.events.on_built_entity, on_robot_built_entity, {
    {filter = "type", type = 'land-mine'},
    {filter = "type", type = 'character'},
    {filter = "type", type = 'car'},
     {filter = "type", type = 'wall'},
    {filter = "type", type = 'spider-vehicle'},
    {filter = "type", type = 'ammo-turret'},
    {filter = "type", type = 'electric-turret'},
    {filter = "type", type = 'fluid-turret'},
    {filter = "type", type = 'radar'},
    {filter = "type", type = 'roboport'}
})
Event.add(defines.events.on_entity_died, on_entity_died)
Event.on_init(on_init)

return Public
