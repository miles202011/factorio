local Public = require 'modules.rpg.table'
local Task = require 'utils.task'
local Gui = require 'utils.gui'
local Color = require 'utils.color_presets'
local Token = require 'utils.token'
local Alert = require 'utils.alert'
local WPT = require 'maps.amap.table'
local tianfu_table=require 'maps.amap.tianfu_table'
local BiterPets = require 'maps.amap.biter_pets'
local EntityCache = require 'maps.amap.entity_cache'

local level_up_floating_text_color = {0, 205, 0}
local visuals_delay = Public.visuals_delay
local xp_floating_text_color = Public.xp_floating_text_color
local experience_levels = Public.experience_levels
local points_per_level = Public.points_per_level
local settings_level = Public.gui_settings_levels
local floor = math.floor

local round = math.round
local abs = math.abs

--RPG Frames
local main_frame_name = Public.main_frame_name
local spell_gui_frame_name = Public.spell_gui_frame_name


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
    if not target_entity or not target_entity.valid then
        return false
    end
    local this=WPT.get()
    local damage_multiplier = this.damage_multiplier or 1
    local final_damage = math.floor(damage_amount * damage_multiplier)
    damage_type = damage_type or 'explosion'
    create_damage_floating_text(target_entity, final_damage, damage_type, player)
    target_entity.damage(final_damage, 'player', damage_type, player.character)
 
    return true
end
local car_name={
  ["car"]=true,
  ["tank"]=true,
  ["spidertron"]=true,
  ["wood"]=true,
}
 
local goal = {'unit', 'turret', 'unit-spawner','combat-robot','spider-leg','spider-unit'}
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
  ['spitter-spawner'] = 320,
  }

local function unstuck_player(index)
  local player = game.get_player(index)
  local surface = player.physical_surface
  if player.physical_surface.name ~= 'nauvis' then return end
  local position = surface.find_non_colliding_position('character', player.physical_position, 32, 0.5)
  if not position then
    return
  end
  player.teleport(position, surface)
end

local lowdowm_1 =
Token.register(
function(player)
  Public.update_player_stats(player)
end
)

function Public.jx(position, surface,player,times)
  player.character_running_speed_modifier=player.character_running_speed_modifier+0.5
  Task.set_timeout_in_ticks(60*8, lowdowm_1, player)

   return true
  end


  function Public.ssz(position, surface,player,times)
  
    for a=-2,2 do
      for b=-2,2 do
        if surface.can_place_entity{name = "stone-wall", position = {position.x+a,position.y+b}, force=game.forces.player} then 
          if (a + b) % 2 == 0 then
            surface.create_entity({name = 'stone-wall', position = {position.x+a,position.y+b},force = game.forces.player})
          end
        end
      end
    end
  
     return true
    end

function Public.lyly(position, surface,player,times)
  
  for a=-4,4 do
    for b=-4,4 do
    surface.create_entity({name = 'fire-flame', position = {position.x+a,position.y+b},force = game.forces.player})
    end
  end

   return true
end

function Public.huo_dun(position, surface, player, times)
  -- 获取技能等级（使用次数）- 主程序会自动处理升级
  local level = times or 1
  if level > 80 then level = 80 end
      local rpg_t = Public.get_value_from_player(player.index)
 
    local magicka_bonus = rpg_t.magicka or 0 
    local damage_multiplier = magicka_bonus * 1
    --最大为3000
    if damage_multiplier > 3000 then
      damage_multiplier = 3000
    end
  local damage = 75 + (level-1) * 30 +damage_multiplier -- 基础伤害75 + 每级50点伤害
  local flame_radius = 4 + math.floor(level / 13)  -- 基础半径4，每10级增加1
  --最大半径为8
  if flame_radius > 7 then
    flame_radius = 7
  end

  --game.print('玩家'..player.name..'使用了'..level..'级火洞术，伤害'..damage..'，半径'..flame_radius)
  -- 获取玩家位置到目标位置的向量
  local player_pos = player.physical_position
  local distance = math.sqrt((position.x - player_pos.x)^2 + (position.y - player_pos.y)^2)
  
  -- 创建从玩家到目标的火焰路径
  local steps = math.floor(distance / 2) + 1  -- 每2格创建一个火焰点
  for i = 1, steps do
    if i >1 then 
    local ratio = i / steps
    local path_x = player_pos.x + (position.x - player_pos.x) * ratio
    local path_y = player_pos.y + (position.y - player_pos.y) * ratio
    
    -- 在路径点创建火焰
    surface.create_entity({
      name = 'fire-flame', 
      position = {path_x, path_y},
      force = game.forces.enemy
    })
  end
  end
  
  -- 在目标位置创建一圈火焰效果
  for i = 1, 24 do
    local angle = (i / 24) * math.pi * 2
    local effect_pos = {
      x = position.x + math.cos(angle) * flame_radius,
      y = position.y + math.sin(angle) * flame_radius
    }
    surface.create_entity({
      name = 'fire-flame', 
      position = effect_pos,
      force = game.forces.enemy
    })
  end
  
  -- 使用圆形区域搜索敌人
  local entities = EntityCache.find_entities_cached(surface, {
    position = position,
    radius = flame_radius,
    force = 'enemy',
    type = goal
  })

  local flame_radius_squared = flame_radius * flame_radius

  for _, entity in pairs(entities) do
    local dx = entity.position.x - position.x
    local dy = entity.position.y - position.y
    local distance_from_center_squared = dx * dx + dy * dy
    local distance_from_center = math.sqrt(distance_from_center_squared)
    local damage_distance_modifier = math.max(0.3, 1 - distance_from_center / flame_radius)
    local final_damage = damage * damage_distance_modifier

    if final_damage > 0 then
      deal_damage_with_floating_text(entity, player, final_damage, 'fire')
    end
  end
  
  -- 注意：升级逻辑由主程序自动处理，不需要手动添加
  return true
end

function Public.shui_long_dan(position, surface, player, times)
  -- 获取技能等级（使用次数）- 主程序会自动处理升级
  local level = times or 1
  if level > 80 then level = 80 end
  local rpg_t = Public.get_value_from_player(player.index)
  local magicka_bonus = rpg_t.magicka or 0 
  local damage_multiplier = magicka_bonus * 1
  --最大为3000
  if damage_multiplier > 3000 then
    damage_multiplier = 3000
  end
  -- 基础伤害和击退效果，随等级提升
  local base_damage = 60 + (level - 1) * 20 + damage_multiplier
  local knockback_distance = 2 --+ math.floor(level / 3)  -- 每3级增加1格击退距离
  local water_radius = 3 + math.floor(level / 15)  -- 每5级增加水柱半径

  --最大半径为4
  if water_radius > 6 then
    water_radius = 6
  end

  --恢复自身20%的生命值
  local health_regen = player.character.max_health * 0.15
  --最大恢复1000
  if health_regen > 1000 then
    health_regen = 1000
  end
player.character.health = player.character.health + health_regen
  -- 获取玩家位置到目标位置的向量
  local player_pos = player.physical_position
  local distance = math.sqrt((position.x - player_pos.x)^2 + (position.y - player_pos.y)^2)
  
  -- 限制最大射程
  if distance > 32 then
    distance = 32
  end
  
  -- 创建水柱路径效果
  local steps = math.floor(distance * 2) + 1 
  for i = 1, steps do
    local ratio = i / steps
    local path_x = player_pos.x + (position.x - player_pos.x) * ratio
    local path_y = player_pos.y + (position.y - player_pos.y) * ratio
    
    -- 在主路径上创建水柱效果
    surface.create_entity({
      name = 'water-splash', 
      position = {path_x, path_y},
      force = game.forces.player
    })
    
    if i % 3 == 1 then
      local enemies = surface.find_entities_filtered({
        position = {x = path_x, y = path_y},
        radius = 1.5,
        force = 'enemy',
        type = {'unit', 'spider-unit'}
      })
      
      for _, enemy in pairs(enemies) do
        if enemy.valid and enemy.health then
          -- 造成伤害
          deal_damage_with_floating_text(enemy, player, base_damage, 'laser')
          -- 击退效果 - 将水柱方向相反的方向推
        end
      end
    end
  end
  
  return true
end













  function Public.ufo(position, surface,player,times)
if times >=10 then times = 10 end
    for i = 1, times do
      local name='distractor-capsule'
      local target= {x=position.x+math.random(-5,5),y=position.y+math.random(-5,5)}
      local  e =  player.physical_surface.create_entity(
            {
              name =name ,
              position=player.physical_position,
              force = 'player',
              source = player.character,
              target = target,
              speed = 0.8,
              player=player
            }
        )
    end
    return true 
  end

  function Public.jgq(position, surface,player,times)

    for i = 1, times do
        Task.set_timeout_in_ticks(i*15, jgq_work, player)
    end
    return true
  end
  
function Public.lightning_chain(position, surface, player, times)
    times = times or 1
    if times > 80 then times = 80 end
    -- 保留原有参数和伤害计算方式
    -- 查找周围的敌对虫子，增加数量限制
    local enemies = EntityCache.find_entities_cached(surface, {
        position = position,
        radius = 20,
        force = game.forces.enemy,
        type = goal
    })
    
    if #enemies == 0 then
        return false
    end

    local rpg_t = Public.get_value_from_player(player.index)

    local magicka_bonus = rpg_t.magicka or 0 
    local damage_multiplier = magicka_bonus * 1
       if damage_multiplier > 3000 then
      damage_multiplier = 3000
    end
    -- 变量：最大攻击目标数量
    local max_targets = 10  -- 最多攻击的虫子数量
    --基于魔力加成伤害

    --总伤害变量，计算公式：20 + game.forces.player.get_ammo_damage_modifier("laser") * 20
    local total_damage = (200 +50*(times-1))+damage_multiplier
    --最低伤害为40%
    local min_damage = total_damage * 0.2
    -- 按血量排序敌人，优先选择血量最低的
    local targets = {}
    for i = 1, math.min(#enemies, max_targets) do
        table.insert(targets, enemies[i])
    end
    
        table.sort(targets, function(a, b)
                return a.health < b.health
            end)

      -- === 2. 视觉效果处理（闪电链效果） ===
    -- 创建主闪电效果：从玩家到第一个目标
    if #targets > 0 and targets[1] and targets[1].valid then
        -- 玩家到第一个目标的主闪电

          surface.create_entity({
                        name = 'electric-beam',
                       position = player.physical_position,
                target = targets[1].position,
                source = player.physical_position,
                        duration = 25 -- 0.5秒，Factorio中1秒=60帧
                    })
        
        -- 创建连锁闪电效果：从一个目标到下一个目标
        for i = 1, #targets - 1 do
            -- 目标之间的连锁闪电
            if targets[i] and targets[i].valid and targets[i+1] and targets[i+1].valid then
     
                    surface.create_entity({
                        name = 'electric-beam',
                        position = targets[i].position,
                        target = targets[i+1].position,
                        source = targets[i].position,
                        duration =25
                    })
            end
        end
        
    end
    -- === 1. 伤害计算和应用（保留原有伤害机制） ===
    -- 分配伤害直到杀死虫子，多余伤害传递给下一个目标
    local remaining_damage = total_damage
    for _, enemy in pairs(targets) do
      if remaining_damage > 0 and enemy and enemy.valid then
        remaining_damage = remaining_damage * 0.8
        
        deal_damage_with_floating_text(enemy, player, remaining_damage, 'electric')
        if remaining_damage < min_damage then
          remaining_damage = min_damage
        end
      end
    end
  
  return true
end

local kill_forces =
Token.register(
function(data)
  for _,v in pairs(data) do
  if  v and  v.valid then
    v.destroy()
  end
end

end
)

local biter_list={
['1']='small-biter',
['2']='medium-biter',
['3']='big-biter',
['4']='behemoth-biter',
}

local spitter_list={
['1']='small-spitter',
['2']='medium-spitter',
['3']='big-spitter',
['4']='behemoth-spitter',
  }

local shachong_list={

['1']='small-worm-turret',
['2']='medium-worm-turret',
['3']='big-worm-turret',
['4']='behemoth-worm-turret',
}


local function tame_unit_effects(player, entity)
  rendering.draw_text {
      text = '~' .. player.name .. "'s pet~",
      surface = player.physical_surface,
      target = entity,
      target_offset = {0, -2.6},
      color = {
          r = player.color.r * 0.6 + 0.25,
          g = player.color.g * 0.6 + 0.25,
          b = player.color.b * 0.6 + 0.25,
          a = 1
      },
      scale = 1.05,
      font = 'default-large-semibold',
      alignment = 'center',
      scale_with_zoom = false
  }
end

function Public.biter_special_forces(position, surface,index,player)

  local biter_name=biter_list[index]
  local spitter_name=spitter_list[index]
  local shachong_name=shachong_list[index]
  

  if not surface.can_place_entity{name = biter_name, position = {x=position.x,y=position.y}, force=game.forces.player} then return false end
  local shachong = surface.create_entity{
    name = shachong_name,
    position = {x=position.x,y=position.y},
    force=game.forces.player,
  }
  
  if not shachong then
    return false
  end
  

 
  
  tame_unit_effects(player,shachong)
  local forces={}
  forces[#forces+1]=shachong
  local group = player.physical_surface.create_unit_group({position = position, force = player.force})
  for i=1,3 do 
    local biter = surface.create_entity{
      name = biter_name,
      position = {x=position.x+3,y=position.y+3},
      force=game.forces.player,
    }
    biter.ai_settings.allow_try_return_to_spawner = false
    forces[#forces+1]=biter
    tame_unit_effects(player,biter)
    group.add_member(biter)
  end

  for i=1,2 do 
    local spitter = surface.create_entity{
      name = spitter_name,
      position = {x=position.x+3,y=position.y+3},
      force=game.forces.player,
    }
    spitter.ai_settings.allow_try_return_to_spawner = false
    forces[#forces+1]=spitter
    tame_unit_effects(player,spitter)
    group.add_member(spitter)
 
  end
  
  --if attack(position,group,shachong) then 
    Task.set_timeout_in_ticks(60*22, kill_forces, forces)
  --else
   --Task.set_timeout_in_ticks(1, kill_forces, forces)
  --end

  return true

end

local kill_turret =
Token.register(
function(data)
  local entity = data.entity
  if not entity or not entity.valid then
    return
  end
  entity.destroy()

end
)

 

function Public.ch(position, surface,player,times)

  local rpg_t = Public.get('rpg_t')
  local mana_max = math.floor(rpg_t[player.index].mana)*1.2+times
  local forces={}
  local group = player.physical_surface.create_unit_group({position = position, force = player.force})
  if  math.floor(rpg_t[player.index].mana)>40 and mana_max > 20 then 
    while mana_max > 20 do
      mana_max=mana_max-1
    for name, worth in pairs(t) do
        if worth <= mana_max then 
            mana_max=mana_max-worth
            local e = player.physical_surface.create_entity{
                name = name,
                position = {x=position.x+math.random(-18,18),y=position.y+math.random(-18,18)},
                force=game.forces.player,
                }
            forces[#forces+1]=e
            tame_unit_effects(player,e)
            if e and e.valid and (e.type=='unit' or e.type=='spider-unit') then
            group.add_member(e)
            end
        end 
    end
    end

     --if attack(position,group,player) then 
      Task.set_timeout_in_ticks(60*12, kill_forces, forces)
    --else
     --Task.set_timeout_in_ticks(1, kill_forces, forces)
  --end
    unstuck_player(player.index)
    rpg_t[player.index].mana=0
   return true
 end
end

function Public.advanced_fishing(position, surface, player, times)
  -- 获取技能等级（使用次数）- 主程序会自动处理升级
  local level = times or 1
  if level > 80 then level = 80 end
  -- 基础得到2条鱼，每级增加1条鱼
  local fish_count = 2 + level
  
  if fish_count>=30 then
    fish_count=30
  end
player.insert({name = 'raw-fish', count = fish_count})

  -- 显示成功消息
  player.create_local_flying_text({
    text = '钓到了 ' .. fish_count .. ' 条鱼！',
    position = position,
    color = {r = 0.2, g = 0.8, b = 1.0},
    speed = 0.8
  })
  
  return true
end

function Public.wudi_turret(position, surface,ammo_name,player)

 if not surface.can_place_entity{name = "gun-turret", position = {x=position.x,y=position.y}, force=game.forces.player} then return false end
  local turret = surface.create_entity{
    name = 'gun-turret',
    position = {x=position.x,y=position.y},
    force=game.forces.player
  }

  if not turret then
    return false
  else
    
    turret.destructible=false
    turret.minable=false
    turret.operable=false
    turret.last_user=player
  end
  turret.insert{name=ammo_name, count = 10}

  local this=WPT.get()
  this.turret_rpg[#this.turret_rpg+1]=turret

  local data = {
    entity = turret,
  }
  Task.set_timeout_in_ticks(720, kill_turret, data)
  return true
end


local desync =
Token.register(
function(data)
  local entity = data.entity
  if not entity or not entity.valid then
    return
  end
  local surface = data.surface
  local fake_shooter = surface.create_entity({name = 'character', position = entity.position, force = 'enemy'})
  for i = 1, 3 do
    surface.create_entity(
    {
      name = 'explosive-rocket',
      position = entity.position,
      force = 'player',
      speed = 1,
      max_range = 1,
      target = entity,
      source = fake_shooter
    }
  )
end
if fake_shooter and fake_shooter.valid then
  fake_shooter.destroy()
end
end
)

local function create_healthbar(player, size)
  return rendering.draw_sprite(
  {
    sprite = 'virtual-signal/signal-white',
    tint = Color.green,
    x_scale = size * 8,
    y_scale = size - 0.2,
    render_layer = 'light-effect',
    target =
            {
                entity = player.character,
                offset = { 0, -2.5 },
            },
    surface = player.physical_surface
  }
)
end

local function create_manabar(player, size)
  return rendering.draw_sprite(
  {
    sprite = 'virtual-signal/signal-white',
    tint = Color.blue,
    x_scale = size * 8,
    y_scale = size - 0.2,
    render_layer = 'light-effect',
       target =
            {
                entity = player.character,
                offset = { 0, -2 },
            },
    surface = player.physical_surface
  }
)
end

local function set_bar(min, max, id, mana)
  if not id or not id.valid then
    return
  end
  local m = 0
  if max > 0 then
    m = min / max
  end
  if min >= max then min = max end
  local x_scale = id.y_scale * 8
  id.x_scale = x_scale * m
  if not mana then
    id.color = {math.floor(255 - 255 * m), math.floor(200 * m), 0}
  end
end

local function level_up(player)
  local rpg_t = Public.get_value_from_player(player.index)
  local names = Public.auto_allocate_nodes_func

  local distribute_points_gain = 0
  for i = rpg_t.level + 1, #experience_levels, 1 do
    if rpg_t.xp > experience_levels[i] then
      rpg_t.level = i
      distribute_points_gain = distribute_points_gain + points_per_level
    else
      break
    end
  end
  if distribute_points_gain == 0 then
    return
  end


  -- automatically enable one_punch and stone_path,
  -- but do so only once.
  if rpg_t.level >= settings_level['one_punch_label'] then
    if not rpg_t.auto_toggle_features.one_punch then
      rpg_t.auto_toggle_features.one_punch = true
      rpg_t.one_punch = true
    end
  end
  if rpg_t.level >= settings_level['stone_path_label'] then
    if not rpg_t.auto_toggle_features.stone_path then
      rpg_t.auto_toggle_features.stone_path = true
      rpg_t.stone_path = true
    end
  end

  Public.draw_level_text(player)
  rpg_t.points_left = rpg_t.points_left + distribute_points_gain
  if rpg_t.allocate_index ~= 1 then
    local node = rpg_t.allocate_index
    local index = names[node]:lower()
    rpg_t[index] = rpg_t[index] + distribute_points_gain
    rpg_t.points_left = rpg_t.points_left - distribute_points_gain
    if not rpg_t.reset then
      rpg_t.total = rpg_t.total + distribute_points_gain
    end
    Public.update_player_stats(player)
  else
    Public.update_char_button(player)
  end
  if player.gui.screen[main_frame_name] then
    Public.toggle(player, true)
  end

  Public.level_up_effects(player)
end

local function add_to_global_pool(amount, personal_tax)
  local rpg_extra = Public.get('rpg_extra')

  if not rpg_extra.global_pool then
    return
  end
  local fee
  if personal_tax then
    fee = amount * rpg_extra.personal_tax_rate
  else
    fee = amount * 0.3
  end

  rpg_extra.global_pool = round(rpg_extra.global_pool + fee, 8)
  return amount - fee
end

local repair_buildings =
Token.register(
function(data)
  local entity = data.entity
  if entity and entity.valid then
    local rng = 0.1
    if math.random(1, 5) == 1 then
      rng = 0.2
    elseif math.random(1, 8) == 1 then
      rng = 0.4
    end
    local to_heal = entity.max_health * rng
    if entity.health and to_heal then
      entity.health = entity.health + to_heal
    end
  end
end
)

function Public.repair_aoe(player, position)
  local entities = player.physical_surface.find_entities_filtered({force = player.force, area = {{position.x - 8, position.y - 8}, {position.x + 8, position.y + 8}}})
  local count = 0
  for i = 1, #entities do
    local e = entities[i]
    local car= false 
    if car_name[e.name] then
      car = ture
    end
    if e.max_health ~= e.health and car==false  then
      count = count + 1
      Task.set_timeout_in_ticks(10, repair_buildings, {entity = e})
    end
  end
  return count
end
function Public.validate_player(player)
  if not player then
    return false
  end
  if not player.valid then
    return false
  end
  if not player.character then
    return false
  end
  if not player.connected then
    return false
  end
  if not game.players[player.index] then
    return false
  end
  return true
end

function Public.remove_mana(player, mana_to_remove)
  local rpg_extra = Public.get('rpg_extra')
  local rpg_t = Public.get_value_from_player(player.index)
  if not rpg_extra.enable_mana then
    return
  end

  if not mana_to_remove then
    return
  end

  mana_to_remove = floor(mana_to_remove)

  if not rpg_t then
    return
  end

  if rpg_t.debug_mode then
    rpg_t.mana = 9999
    return
  end

  if player.gui.screen[main_frame_name] then
    local f = player.gui.screen[main_frame_name]
    local data = Gui.get_data(f)
    if data.mana and data.mana.valid then
      data.mana.caption = rpg_t.mana
    end
  end

  rpg_t.mana = rpg_t.mana - mana_to_remove

  if rpg_t.mana < 0 then
    rpg_t.mana = 0
    return
  end

  if player.gui.screen[spell_gui_frame_name] then
    local f = player.gui.screen[spell_gui_frame_name]
    if f['spell_table'] then
      if f['spell_table']['mana'] then
        f['spell_table']['mana'].caption = math.floor(rpg_t.mana)
      end
      if f['spell_table']['maxmana'] then
        f['spell_table']['maxmana'].caption = math.floor(rpg_t.mana_max)
      end
    end
  end
end

function Public.update_mana(player)
  local rpg_extra = Public.get('rpg_extra')
  local rpg_t = Public.get_value_from_player(player.index)
  if not rpg_extra.enable_mana then
    return
  end

  if not rpg_t then
    return
  end

  if rpg_t.mana>= rpg_t.mana_max then 
    rpg_t.mana = rpg_t.mana_max
  end

  if player.gui.screen[main_frame_name] then
    local f = player.gui.screen[main_frame_name]
    local data = Gui.get_data(f)
    if data.mana and data.mana.valid then
      data.mana.caption = rpg_t.mana
    end
  end
  if player.gui.screen[spell_gui_frame_name] then
    local f = player.gui.screen[spell_gui_frame_name]
    if f['spell_table'] then
      if f['spell_table']['mana'] then
        f['spell_table']['mana'].caption = math.floor(rpg_t.mana)
      end
      if f['spell_table']['maxmana'] then
        f['spell_table']['maxmana'].caption = math.floor(rpg_t.mana_max)
      end
    end
  end

  if rpg_t.mana < 1 then
    return
  end
  if rpg_extra.enable_health_and_mana_bars then
    if rpg_t.show_bars then
      if player.character and player.character.valid then
        if not rpg_t.mana_bar or not rpg_t.mana_bar.valid then
          rpg_t.mana_bar = create_manabar(player, 0.5)
        end
        set_bar(rpg_t.mana, rpg_t.mana_max, rpg_t.mana_bar, true)
      end
    else
      if rpg_t.mana_bar and rpg_t.mana_bar.valid then
          rpg_t.mana_bar.destroy()
        end
    end
  end
end

function Public.reward_mana(player, mana_to_add)
  local rpg_extra = Public.get('rpg_extra')
  local rpg_t = Public.get_value_from_player(player.index)
  if not rpg_extra.enable_mana then
    return
  end

  if not mana_to_add then
    return
  end

  mana_to_add = floor(mana_to_add)

  if not rpg_t then
    return
  end

  if player.gui.screen[main_frame_name] then
    local f = player.gui.screen[main_frame_name]
    local data = Gui.get_data(f)
    if data.mana and data.mana.valid then
      data.mana.caption = rpg_t.mana
    end
  end
  if player.gui.screen[spell_gui_frame_name] then
    local f = player.gui.screen[spell_gui_frame_name]
    if f['spell_table'] then
      if f['spell_table']['mana'] then
        f['spell_table']['mana'].caption = math.floor(rpg_t.mana)
      end
      if f['spell_table']['maxmana'] then
        f['spell_table']['maxmana'].caption = math.floor(rpg_t.mana_max)
      end
    end
  end

  if rpg_t.mana_max < 1 then
    return
  end

  if rpg_t.mana >= rpg_t.mana_max then
    rpg_t.mana = rpg_t.mana_max
    return
  end

  rpg_t.mana = rpg_t.mana + mana_to_add
end

function Public.update_health(player)
  local rpg_extra = Public.get('rpg_extra')
  local rpg_t = Public.get_value_from_player(player.index)

  if not player or not player.valid then
    return
  end

  if not player.character or not player.character.valid then
    return
  end

  if not rpg_t then
    return
  end

  if player.gui.screen[main_frame_name] then
    local f = player.gui.screen[main_frame_name]
    local data = Gui.get_data(f)
    if data and data.health and data.health.valid then
      data.health.caption = (round(player.character.health * 10) / 10)
    end
    local shield_gui = player.character.get_inventory(defines.inventory.character_armor)
    if not shield_gui.is_empty() then
      if shield_gui[1].grid then
        local shield = math.floor(shield_gui[1].grid.shield)
        local shield_max = math.floor(shield_gui[1].grid.max_shield)
        if data and data.shield and data.shield.valid then
          data.shield.caption = shield
        end
        if data and data.shield_max and data.shield_max.valid then
          data.shield_max.caption = shield_max
        end
      end
    end
  end

  if rpg_extra.enable_health_and_mana_bars then
    if rpg_t.show_bars and player.character then
      -- Factorio 2.0中max_health已从prototype移至entity
      local max_life = math.floor( player.character.max_health)
      if not rpg_t.health_bar or not rpg_t.health_bar.valid then
        rpg_t.health_bar = create_healthbar(player, 0.5)
      end
      set_bar(player.character.health, max_life, rpg_t.health_bar)
    else
      if rpg_t.health_bar and rpg_t.health_bar.valid then
        rpg_t.health_bar.destroy()
      end
    end
  end
end

function Public.level_limit_exceeded(player, value)
  local rpg_extra = Public.get('rpg_extra')
  local rpg_t = Public.get_value_from_player(player.index)
  if not rpg_extra.level_limit_enabled then
    return false
  end

  local limits = {
    [1] = 30,
    [2] = 50,
    [3] = 70,
    [4] = 90,
    [5] = 110,
    [6] = 130,
    [7] = 150,
    [8] = 170,
    [9] = 190,
    [10] = 210
  }

  local level = rpg_t.level
  local zone = rpg_extra.breached_walls
  if zone >= 11 then
    zone = 10
  end
  if value then
    return limits[zone]
  end

  if level >= limits[zone] then
    return true
  end
  return false
end

function Public.level_up_effects(player)
  local position = {x = player.physical_position.x - 0.75, y = player.physical_position.y - 1}
  player.create_local_flying_text({position = position, text = '+LVL ', color = level_up_floating_text_color})
  local b = 0.75
  for _ = 1, 5, 1 do
    local p = {
      (position.x + 0.4) + (b * -1 + math.random(0, b * 20) * 0.1),
      position.y + (b * -1 + math.random(0, b * 20) * 0.1)
    }
    player.create_local_flying_text({position = p, text = '✚', color = {1, math.random(0, 100)/255, 0}})
  end
  player.play_sound {path = 'utility/achievement_unlocked', volume_modifier = 0.40}
end

function Public.xp_effects(player)
  local position = {x = player.physical_position.x - 0.75, y = player.physical_position.y - 1}
  player.create_local_flying_text({position = position, text = '+XP', color = level_up_floating_text_color})
  local b = 0.75
  for _ = 1, 5, 1 do
    local p = {
      (position.x + 0.4) + (b * -1 + math.random(0, b * 20) * 0.1),
      position.y + (b * -1 + math.random(0, b * 20) * 0.1)
    }
    player.create_local_flying_text({position = p, text = '✚', color = {1, math.random(0, 100)/255, 0}})
  end
  player.play_sound {path = 'utility/achievement_unlocked', volume_modifier = 0.40}
end

function Public.get_melee_modifier(player)
  local rpg_t = Public.get_value_from_player(player.index)
  return (rpg_t.strength - 10) * 0.10
end

function Public.get_final_damage_modifier(player)
  local rpg_t = Public.get_value_from_player(player.index)
  local rng = math.random(10, 35) * 0.01
  return (rpg_t.strength - 10) * rng
end

function Public.get_final_damage(player, entity, original_damage_amount)
  local modifier = Public.get_final_damage_modifier(player)
  local damage = original_damage_amount + original_damage_amount * modifier
  if entity.prototype.resistances then
    if entity.prototype.resistances.physical then
      damage = damage - entity.prototype.resistances.physical.decrease
      damage = damage - damage * entity.prototype.resistances.physical.percent
    end
  end
  damage = round(damage, 3)
  if damage < 1 then
    damage = 1
  end
  return damage
end

function Public.get_heal_modifier(player)
  local rpg_t = Public.get_value_from_player(player.index)
  return (rpg_t.vitality - 10) * 0.06
end

function Public.get_heal_modifier_from_using_fish(player)
  local rpg_extra = Public.get('rpg_extra')
  if rpg_extra.disable_get_heal_modifier_from_using_fish then
    return
  end

  local base_amount = 80
  local rng = math.random(base_amount, base_amount * rpg_extra.heal_modifier)
  local char = player.character
  local position = player.physical_position
  if char and char.valid then
    local health = player.character_health_bonus + 250
    local color
    if char.health > (health * 0.50) then
      color = {b = 0.2, r = 0.1, g = 1, a = 0.8}
    elseif char.health > (health * 0.25) then
      color = {r = 1, g = 1, b = 0}
    else
      color = {b = 0.1, r = 1, g = 0, a = 0.8}
    end
    player.create_local_flying_text(
    {
      position = {position.x, position.y + 0.6},
      text = '+' .. rng,
      color = color
    }
  )
  char.health = char.health + rng
end
end

function Public.get_mana_modifier(player)
  local rpg_t = Public.get_value_from_player(player.index)
  local modifier
  if rpg_t.level <= 40 then
    modifier = (rpg_t.magicka - 10) * 0.02000
  elseif rpg_t.level <= 80 then
    modifier = (rpg_t.magicka - 10) * 0.01800
  elseif rpg_t.level <= 120 then
    modifier = (rpg_t.magicka - 10) * 0.01400
  elseif rpg_t.level <= 160 then
    modifier = (rpg_t.magicka - 10) * 0.01200
  else
    modifier = (rpg_t.magicka - 10) * 0.01000
  end
  return math.min(modifier, 30)
end

function Public.get_life_on_hit(player)
  local rpg_t = Public.get_value_from_player(player.index)
  return (rpg_t.vitality - 10) * 0.4
end

function Public.get_one_punch_chance(player)
  local rpg_t = Public.get_value_from_player(player.index)
  if rpg_t.strength < 100 then
    return 0
  end
  local chance = round(rpg_t.strength * 0.012, 1)
  if chance > 100 then
    chance = 100
  end
  return chance
end

function Public.get_extra_following_robots(player)
  local rpg_t = Public.get_value_from_player(player.index)
  local strength = rpg_t.strength
  local count = round(strength /35, 3)
  return count
end

function Public.get_magicka(player)
  local rpg_t = Public.get_value_from_player(player.index)
  return (rpg_t.magicka - 10) * 0.10
end

--- Gives connected player some bonus xp if the map was preemptively shut down.
-- amount (integer) -- 10 levels
-- local Public = require 'modules.rpg.table' Public.give_xp(512)
function Public.give_xp(amount)
  for _, player in pairs(game.connected_players) do
    if not Public.validate_player(player) then
      return
    end
    Public.gain_xp(player, amount)
  end
end

function Public.rpg_reset_player(player, one_time_reset)
  if not player.character then
    player.set_controller({type = defines.controllers.god})
    player.create_character()
  end
  local rpg_t = Public.get_value_from_player(player.index)
  local rpg_extra = Public.get('rpg_extra')
  if one_time_reset then
    local total = rpg_t.total
    if not total then
      total = 0
    end
    if rpg_t.text and rpg_t.text.valid then
      rpg_t.text.destroy()
      rpg_t.text = nil
    end
    local old_level = rpg_t.level
    local old_points_left = rpg_t.points_left
    local old_xp = rpg_t.xp
    rpg_t =
    Public.set_new_player_tbl(
    player.index,
    {
      level = 1,
      xp = 0,
      strength = 10,
      magicka = 10,
      dexterity = 10,
      vitality = 10,
      mana = 0,
      mana_max = 0,
      last_spawned = 0,
      last_cast_position = {x = 0, y = -5},  -- 使用特殊值表示未设置状态
      auto_cast_enabled = false,
      crafting_speed = 0,
      dropdown_select_index = 1,
      dropdown_select_index1 = 1,
      dropdown_select_index2 = 1,
      dropdown_select_index3 = 1,
      allocate_index = 1,
      flame_boots = false,
      explosive_bullets = false,
      enable_entity_spawn = false,
      health_bar = rpg_t.health_bar,
      mana_bar = rpg_t.mana_bar,
      points_left = 0,
      last_floaty_text = visuals_delay,
      xp_since_last_floaty_text = 0,
      reset = true,
      capped = false,
      bonus = rpg_extra.breached_walls or 1,
      rotated_entity_delay = 0,
      last_mined_entity_position = {x = 0, y = 0},
      show_bars = true,
      stone_path = false,
      one_punch = false,
      transfered_once = false,
      auto_toggle_features = {
        stone_path = false,
        one_punch = false
      }
    }
  )
  rpg_t.points_left = old_points_left + total
  rpg_t.xp = round(old_xp)
  rpg_t.level = old_level
else
  Public.set_new_player_tbl(
  player.index,
  {
    level = 1,
    xp = 0,
    strength = 10,
    magicka = 10,
    dexterity = 10,
    vitality = 10,
    mana = 0,
    mana_max = 0,
      last_spawned = 0,
      last_cast_position = {x = 0, y = -5},  -- 使用特殊值表示未设置状态
      auto_cast_enabled = false,
      crafting_speed = 0,
      dropdown_select_index = 1,
    dropdown_select_index1 = 1,
    dropdown_select_index2 = 1,
    dropdown_select_index3 = 1,
    allocate_index = 1,
    flame_boots = false,
    explosive_bullets = false,
    enable_entity_spawn = false,
    points_left = 0,
    last_floaty_text = visuals_delay,
    xp_since_last_floaty_text = 0,
    reset = false,
    capped = false,
    total = 0,
    bonus = 1,
    rotated_entity_delay = 0,
    last_mined_entity_position = {x = 0, y = 0},
    show_bars = true,
    stone_path = false,
    one_punch = false,
    transfered_once = false,
    auto_toggle_features = {
      stone_path = false,
      one_punch = false
    }
  }
)
end
Public.draw_gui_char_button(player)
Public.draw_level_text(player)
Public.update_char_button(player)
Public.update_player_stats(player)
end

function Public.rpg_reset_all_players()
  local rpg_t = Public.get('rpg_t')
  local rpg_extra = Public.get('rpg_extra')
  for k, _ in pairs(rpg_t) do
    rpg_t[k] = nil
  end
  for _, p in pairs(game.connected_players) do
    Public.rpg_reset_player(p)
  end
  rpg_extra.breached_walls = 1
  rpg_extra.reward_new_players = 0
  rpg_extra.global_pool = 0
end

function Public.gain_xp(player, amount, added_to_pool, text)
  if not Public.validate_player(player) then
    return
  end
  local rpg_extra = Public.get('rpg_extra')
  local rpg_t = Public.get_value_from_player(player.index)

  if Public.level_limit_exceeded(player) then
    add_to_global_pool(amount, false)
    if not rpg_t.capped then
      rpg_t.capped = true
      local message = ({'rpg_functions.max_level'})
      Alert.alert_player_warning(player, 10, message)
    end
    return
  end

  local text_to_draw

  if rpg_t.capped then
    rpg_t.capped = false
  end

  if not added_to_pool then
    Public.debug_log('RPG - ' .. player.name .. ' got org xp: ' .. amount)
    local fee = amount - add_to_global_pool(amount, true)
    Public.debug_log('RPG - ' .. player.name .. ' got fee: ' .. fee)
    amount = round(amount, 3) - fee
    if rpg_extra.difficulty then
      amount = amount + rpg_extra.difficulty
    end
    local this = WPT.get()
    if this.experience_bonus then
      amount = amount * (1 + this.experience_bonus)
    end
    Public.debug_log('RPG - ' .. player.name .. ' got after fee: ' .. amount)
  else
    Public.debug_log('RPG - ' .. player.name .. ' got org xp: ' .. amount)
  end

  rpg_t.xp = round(rpg_t.xp + amount, 3)
  rpg_t.xp_since_last_floaty_text = round(rpg_t.xp_since_last_floaty_text + amount)

  if not experience_levels[rpg_t.level + 1] then
    return
  end

  local f = player.gui.screen[main_frame_name]
  if f and f.valid then
    local d = Gui.get_data(f)
    if d.exp_gui and d.exp_gui.valid then
      d.exp_gui.caption = math.floor(rpg_t.xp)
    end
  end

  if rpg_t.xp >= experience_levels[rpg_t.level + 1] then
    level_up(player)
  end

  if rpg_t.last_floaty_text > game.tick then
    if not text then
      return
    end
  end

  if text then
    text_to_draw = '+' .. math.floor(amount) .. ' xp'
  else
    text_to_draw = '+' .. math.floor(rpg_t.xp_since_last_floaty_text) .. ' xp'
  end

  player.create_local_flying_text {
    text = text_to_draw,
    position = player.physical_position,
    color = xp_floating_text_color,
    time_to_live = 340,
    speed = 2
  }

  rpg_t.xp_since_last_floaty_text = 0
  rpg_t.last_floaty_text = game.tick + visuals_delay
end

function Public.global_pool(players, count)
  local rpg_extra = Public.get('rpg_extra')

  if not rpg_extra.global_pool then
    return
  end

  local pool = math.floor(rpg_extra.global_pool)

  local random_amount = math.random(5000, 10000)

  if pool <= random_amount then
    return
  end

  if pool >= 20000 then
    pool = 20000
  end

  local share = pool / count

  Public.debug_log('RPG - Share per player:' .. share)

  for i = 1, #players do
    local p = players[i]
    if p.afk_time < 5000 then
      if not Public.level_limit_exceeded(p) then
        Public.gain_xp(p, share, false, true)
        Public.xp_effects(p)
      else
        share = share / 10
        rpg_extra.leftover_pool = rpg_extra.leftover_pool + share
        Public.debug_log('RPG - player capped: ' .. p.name .. '. Amount to pool:' .. share)
      end
    else
      local message = ({'rpg_functions.pool_reward', p.name})
      Alert.alert_player_warning(p, 10, message)
      share = share / 10
      rpg_extra.leftover_pool = rpg_extra.leftover_pool + share
      Public.debug_log('RPG - player AFK: ' .. p.name .. '. Amount to pool:' .. share)
    end
  end

  rpg_extra.global_pool = rpg_extra.leftover_pool or 0

  return
end

local damage_player_over_time_token =
Token.register(
function(data)
  local player = data.player
  if not player.character or not player.character.valid then
    return
  end
  player.character.health = player.character.health - (player.character.health * 0.05)
  player.character.surface.create_entity({name = 'water-splash', position = player.physical_position})
end
)

--- Damages a player over time.
function Public.damage_player_over_time(player, amount)
  if not player or not player.valid then
    return
  end

  amount = amount or 10
  local tick = 20
  for _ = 1, amount, 1 do
    Task.set_timeout_in_ticks(tick, damage_player_over_time_token, {player = player})
    tick = tick + 15
  end
end

--- Distributes the global xp pool to every connected player.
function Public.distribute_pool()
  local count = #game.connected_players
  local players = game.connected_players
  Public.global_pool(players, count)
  print('Distributed the global XP pool')
end

Public.add_to_global_pool = add_to_global_pool

-- 创建属性点和天赋转移界面
function Public.create_transfer_gui(player)
  local rpg_t = Public.get_value_from_player(player.index)
  
  -- 检查玩家是否已经转移过属性
  if rpg_t.transfered_once then
    player.print("您已经转移过属性和天赋，每人仅可转移一次！", {r = 1, g = 0.5, b = 0.5})
    return
  end
  
  --检查玩家等级是否达到105级
  if rpg_t.level < 105 then
    player.print("您的等级还未达到105级，无法转移属性！", {r = 1, g = 0.5, b = 0.5})
    return
  end

  -- 检查玩家是否还有属性点或天赋点
  if rpg_t.points_left <= 0 and rpg_t.strength <= 10 and rpg_t.magicka <= 10 and rpg_t.dexterity <= 10 and rpg_t.vitality <= 10 then
    player.print("您没有任何属性点或天赋可以转移！", {r = 1, g = 0.5, b = 0.5})
    return
  end
  
  local frame = player.gui.screen.add({type = "frame", name = Public.transfer_frame_name, caption = "选择转移目标玩家", direction = "vertical"})
  frame.auto_center = true
  
  local scroll_pane = frame.add({type = "scroll-pane", direction = "vertical"})
  scroll_pane.style.maximal_height = 300
  
  -- 获取在线玩家列表（排除自己）
  local online_players = {}
  for _, p in pairs(game.connected_players) do
    if p.index ~= player.index then
      table.insert(online_players, p)
    end
  end
  
  -- 如果没有其他在线玩家
  if #online_players == 0 then
    frame.add({type = "label", caption = "当前没有其他在线玩家可以转移给"})
    local close_button = frame.add({type = "button", caption = "关闭"})
    close_button.style.font = "default-bold"
    close_button.name = "transfer_cancel_button"
    Gui.on_click("transfer_cancel_button", function(event)
      if frame and frame.valid then
        frame.destroy()
      end
    end)
    return
  end
  
  -- 为每个在线玩家创建按钮
  for _, target_player in pairs(online_players) do
    local button = scroll_pane.add({
      type = "button", 
      caption = target_player.name,
      name = "transfer_to_" .. target_player.index
    })
    button.style.font = "default-bold"
    button.style.minimal_width = 200
    
    -- 添加点击事件
    Gui.on_click("transfer_to_" .. target_player.index, function(event)
      -- 执行转移操作
      Public.execute_transfer(player, target_player)
      
      -- 关闭界面
      if frame and frame.valid then
        frame.destroy()
      end
    end)
  end
  
  -- 添加关闭按钮
  local close_button = frame.add({type = "button", caption = "取消"})
  close_button.style.font = "default-bold"
  close_button.name = "transfer_cancel_button"
  Gui.on_click("transfer_cancel_button", function(event)
    if frame and frame.valid then
      frame.destroy()
    end
  end)
end

-- 执行属性点和天赋转移
function Public.execute_transfer(source_player, target_player)
  local source_rpg = Public.get_value_from_player(source_player.index)
  local target_rpg = Public.get_value_from_player(target_player.index)
  
  -- 检查玩家是否已经转移过属性
  if source_rpg.transfered_once then
    source_player.print("您已经转移过属性和天赋，每人仅可转移一次！", {r = 1, g = 0.5, b = 0.5})
    return
  end
  
  -- 计算要转移的属性点（一半）
  local strength_to_transfer = math.floor((source_rpg.strength - 10) / 2)
  local magicka_to_transfer = math.floor((source_rpg.magicka - 10) / 2)
  local dexterity_to_transfer = math.floor((source_rpg.dexterity - 10) / 2)
  local vitality_to_transfer = math.floor((source_rpg.vitality - 10) / 2)
  
  -- 转移属性点
  if strength_to_transfer > 0 then
    source_rpg.strength = 10
    target_rpg.strength = target_rpg.strength + strength_to_transfer
  end
  
  if magicka_to_transfer > 0 then
    source_rpg.magicka = 10
    target_rpg.magicka = target_rpg.magicka + magicka_to_transfer
  end
  
  if dexterity_to_transfer > 0 then
    source_rpg.dexterity = 10
    target_rpg.dexterity = target_rpg.dexterity + dexterity_to_transfer
  end
  
  if vitality_to_transfer > 0 then
    source_rpg.vitality = 10
    target_rpg.vitality = target_rpg.vitality + vitality_to_transfer
  end
  
  -- 转移未分配的属性点
  local points_to_transfer = math.floor(source_rpg.points_left / 2)
  if points_to_transfer > 0 then
    source_rpg.points_left = 0
    target_rpg.points_left = target_rpg.points_left + points_to_transfer
  end
  
  -- 转移天赋
   local main_table = WPT.get()
   local tianfu = tianfu_table.get()
   if main_table.skill and main_table.skill[source_player.name] and #main_table.skill[source_player.name] > 0 then
     -- 确保目标玩家的skill表存在
     if not main_table.skill[target_player.name] then
       main_table.skill[target_player.name] = {}
     end
     
     -- 计算要转移的天赋数量（一半）
     local skills_to_transfer = math.floor(#main_table.skill[source_player.name] / 2)
     
     if skills_to_transfer > 0 then
       -- 随机选择要转移的天赋
       local transferred_skills = {}
       local skipped_skills = {}  -- 记录跳过的天赋
       
       -- 随机选择天赋进行转移
       for i = 1, skills_to_transfer do
         if #main_table.skill[source_player.name] > 0 then
           local random_index = math.random(1, #main_table.skill[source_player.name])
           local skill = main_table.skill[source_player.name][random_index]
           
           -- 检查目标玩家是否已经学习了这个天赋
           local already_learned = false
           for _, learned_skill in pairs(main_table.skill[target_player.name]) do
             if learned_skill == skill then
               already_learned = true
               break
             end
           end
           
           -- 如果目标玩家已经学习了这个天赋，则跳过
           if already_learned then
             table.insert(skipped_skills, skill)
             -- 从源玩家中移除
             table.remove(main_table.skill[source_player.name], random_index)
           else
             --天赋执行表是这样存储的： xybg = { "itam" },并且存储在local tianfu=tianfu_table.get()中
             --天赋学习表是这样存储的：  skill = {itam = { "xybg" }}，并存储在local main_table = WPT.get()中

             --转移天赋学习表
             -- 添加到目标玩家
             table.insert(main_table.skill[target_player.name], skill)
             table.insert(transferred_skills, skill)
             
             -- 从源玩家中移除
             table.remove(main_table.skill[source_player.name], random_index)

             --转移天赋启用状态表 tianfu_enabled
             local source_enabled = main_table.tianfu_enabled[source_player.index]
             local target_enabled = main_table.tianfu_enabled[target_player.index]
             
             -- 如果源玩家有这个天赋的启用状态，则转移到目标玩家
             if source_enabled and source_enabled[skill] ~= nil then
               if not target_enabled then
                 main_table.tianfu_enabled[target_player.index] = {}
                 target_enabled = main_table.tianfu_enabled[target_player.index]
               end
               target_enabled[skill] = source_enabled[skill]
             end
             
             -- 从源玩家的启用状态表中移除
             if source_enabled then
               source_enabled[skill] = nil
             end

             --转移天赋执行表
           --  从源玩家的执行表中移除
             if tianfu[skill] then
               for idx, player_name in pairs(tianfu[skill]) do
                 if player_name == source_player.name then
                   table.remove(tianfu[skill], idx)
                   break
                 end
               end
             end
             
            -- 添加到目标玩家的执行表
             if not tianfu[skill] then
               tianfu[skill] = {}
             end
             table.insert(tianfu[skill], target_player.name)
           end
         end
       end

       --删除未转移的天赋。
       
       
       -- 通知玩家天赋转移情况
       if #transferred_skills > 0 or #skipped_skills > 0 then
         if #transferred_skills > 0 then
           source_player.print("成功向玩家 " .. target_player.name .. " 转移了 " .. #transferred_skills .. " 个天赋！", {r = 0.5, g = 1, b = 0.5})
           target_player.print("从玩家 " .. source_player.name .. " 处获得了 " .. #transferred_skills .. " 个天赋！", {r = 0.5, g = 1, b = 0.5})
         end
         
         if #skipped_skills > 0 then
           source_player.print("跳过了 " .. #skipped_skills .. " 个天赋，因为目标玩家已经学习了这些天赋。", {r = 1, g = 0.8, b = 0.2})
         end
       end
     end
   end
  
  -- 标记源玩家已经转移过
  source_rpg.transfered_once = true
  
  -- 更新玩家状态
  Public.update_player_stats(source_player)
  Public.update_player_stats(target_player)
  
  -- 发送通知消息
  source_player.print("成功向玩家 " .. target_player.name .. " 转移了一半的属性点和天赋！您已无法再次转移。", {r = 0.5, g = 1, b = 0.5})
  target_player.print("从玩家 " .. source_player.name .. " 处获得了属性点和天赋！", {r = 0.5, g = 1, b = 0.5})
end


-- 注意：原fairy_lightning_trigger函数已被移除，闪电链现在在主循环中直接触发

-- 小精灵召唤技能
function Public.xiao_jingling(position, surface, player, times)
  -- 获取技能等级（使用次数）- 主程序会自动处理升级
  local level = times or 1
  local rpg_t = Public.get_value_from_player(player.index)
  local this = WPT.get()
  -- 计算要召唤的精灵数量
  local spirit_count = 3 + (level - 1)  -- 基础3只，每级增加1只
  if spirit_count > 12 then
    spirit_count = 12  -- 最多8只精灵
  end
  -- 在目标位置周围召唤精灵
  local summoned_spirits = 0
  for i = 1, spirit_count do
    -- 在目标位置周围随机分布
    local angle = (i - 1) * (360 / spirit_count) + math.random(-30, 30)
    local distance = 2 + math.random(-1, 1)
    local spirit_x = position.x + math.cos(math.rad(angle)) * distance
    local spirit_y = position.y + math.sin(math.rad(angle)) * distance
    
    -- 检查位置是否有效
    local spirit_position = surface.find_non_colliding_position('character', {x = spirit_x, y = spirit_y}, 5, 0.5)
    if spirit_position then
      -- 创建绿喷涂虫子作为精灵
      local spirit_entity = surface.create_entity({
        name = 'behemoth-spitter',  -- 使用巨型喷涂虫子
        position = spirit_position,
        force = 'player'
      })
      
      -- 设置虫子的AI设置
      if spirit_entity and spirit_entity.valid then
        spirit_entity.ai_settings.allow_try_return_to_spawner = false
      
        -- 使用 biter_pets 系统驯服精灵
        BiterPets.biter_pets_tame_unit(player, spirit_entity)
        
        -- 再次检查实体是否仍然有效
        if spirit_entity and spirit_entity.valid then
          -- 为精灵添加"虫子法师"标签
          rendering.draw_text {
              text = '虫子法师',
              surface = player.physical_surface,
              target = {
                  entity = spirit_entity,
                  offset = {0, -2.5},
              },
              color = {
                  r = player.color.r * 0.6 + 0.25,
                  g = player.color.g * 0.6 + 0.25,
                  b = player.color.b * 0.6 + 0.25,
                  a = 1
              },
              scale = 1.05,
              font = 'default-large-semibold',
              alignment = 'center',
              scale_with_zoom = false
          }
        end
        
        -- 再次检查实体是否仍然有效，然后为精灵添加血条
        
        summoned_spirits = summoned_spirits + 1
        
        -- 存储精灵数据到按玩家索引组织的表中
        local spirit_data = {
          entity = spirit_entity,
          spawn_time = game.tick,
          lifetime = 60 * 30,  -- 30秒生命周期
        }
        
        -- 初始化按玩家索引的精灵表结构
        if not this.fairy_spirits then
          this.fairy_spirits = {}
        end
        
        -- 按玩家索引注册该玩家的精灵
        if not this.fairy_spirits[player.index] then
          this.fairy_spirits[player.index] = {}
        end
        
        -- 将精灵数据添加到对应玩家的精灵表中
        this.fairy_spirits[player.index][#this.fairy_spirits[player.index]+1] = spirit_data
        -- 注意：闪电链现在在主循环中直接触发，不再使用定时器
      end
    end
  end
  
  return true
end

-- 清理过期精灵的函数（需要添加到适当的事件中）
function Public.cleanup_fairy_spirits()
  local this = WPT.get()
  
  -- 清理按玩家索引组织的精灵表
  if this.fairy_spirits then
    for player_index, spirits in pairs(this.fairy_spirits) do
      local valid_spirits = {}
      local valid_count = 1
      
      for _, spirit_data in pairs(spirits) do
        -- 检查精灵是否还有效
        if spirit_data.entity and spirit_data.entity.valid and 
           game.tick - spirit_data.spawn_time <= spirit_data.lifetime then
          
          valid_spirits[valid_count] = spirit_data  -- 保留有效的精灵
          valid_count = valid_count + 1
        else
          -- 销毁精灵实体
          if spirit_data.entity and spirit_data.entity.valid then
            spirit_data.entity.destroy()
          end
        end
      end
      
      -- 更新玩家精灵表为有效精灵
      if #valid_spirits > 0 then
        this.fairy_spirits[player_index] = valid_spirits
      else
        -- 如果该玩家没有精灵了，清理空的表
        this.fairy_spirits[player_index] = nil
      end
    end
  end
end

-- 在主循环中直接触发所有精灵的闪电链攻击
function Public.trigger_all_fairy_lightning(players)
  local this = WPT.get()
  
  -- 使用按玩家索引组织的精灵表
  local spirits_by_player = this.fairy_spirits or {}
  
  -- 只计算有效的精灵
  for player_index, spirits in pairs(spirits_by_player) do
    local valid_spirits = {}
    local valid_count = 1
    for _, spirit in pairs(spirits) do
      if spirit.entity and spirit.entity.valid then
        valid_spirits[valid_count] = spirit  -- 使用直接数组分配
        valid_count = valid_count + 1
      end
    end
    spirits_by_player[player_index] = valid_spirits  -- 更新为有效精灵
  end
  
  -- 为每个有精灵的玩家触发闪电链
  for player_index, spirits in pairs(spirits_by_player) do
    local player = game.get_player(player_index)
    if player and player.character and player.character.valid then
      -- 获取第一个精灵的数据（用于获取等级等信息）
      local sample_spirit = spirits[1]
      if sample_spirit then
        
     
        local laser_damage_bonus = game.forces.player.get_ammo_damage_modifier("laser")+1
        local attack_speed_bonus = game.forces.player.get_gun_speed_modifier('laser') + 1
        -- 计算闪电链属性
        local base_damage = 10*laser_damage_bonus*attack_speed_bonus
        local chain_range = 16 + math.floor(#spirits / 6)
        local max_chains = 8 + math.floor(#spirits / 6) 
        --最大数量为24
        if max_chains > 24 then
          max_chains = 24
        end

        --最大范围为36
        if chain_range > 30 then
          chain_range = 30
        end
        
        -- 从玩家位置寻找敌人
        local player_position = player.character.position
        local enemies = EntityCache.find_entities_cached(player.physical_surface, {
          position = player.physical_position,
          radius = chain_range,
          force = 'enemy',
          type = goal,
          limit = max_chains
        })
        
        if #enemies > 0 then
          -- 首先创建从玩家到所有精灵的连接（闪电链供电效果）
          --最多10个精灵
local lianjieshu=0
          for _, spirit in pairs(spirits) do

            if spirit.entity and spirit.entity.valid then
              player.physical_surface.create_entity({
                name = 'electric-beam',
                position = player_position,
                source_position = player_position,
                force = 'player',
                target_position = spirit.entity.position,
                duration = 25
              })
              lianjieshu=lianjieshu+1
            end
            if lianjieshu >= 10 then
              break
            end
          end
          
          -- 对每个目标造成伤害并创建从玩家到敌人的闪电效果
          for _, enemy in pairs(enemies) do
            if enemy.valid and enemy.health then
              player.physical_surface.create_entity({
                name = 'electric-beam',
                position = player_position,
                target = enemy.position,
                source = player_position,
                duration = 20
              })
              
              if enemy.valid and enemy.health then
                deal_damage_with_floating_text(enemy, player, base_damage, 'electric')
              end
            end
          end
        end
      end
    end
  end
end

-- 环形火山喷发魔法
local active_lava_burst_task = Token.register(function(data)
    local surface = data.surface
    local pos = data.pos          -- 这是一个固定的坐标 {x, y}
    local player = data.player
    local damage = data.damage    -- 传递过来的大额伤害
    
    -- 必须校验 surface 是否还在，防止跨星球/删图报错
    if surface and surface.valid then
        -- 1. 视觉效果：在原地产生巨型爆炸
        -- 如果是 2.0 Space Age，推荐 'demolisher-explosion' 或 'big-explosion'
        -- 2. 对爆炸点周围进行范围打击
        -- 无论原来的怪跑哪去了，谁踩在熔岩上谁就挨炸
        local area_enemies = surface.find_entities_filtered {
            position = pos,
            radius = 7,   -- 爆炸半径略大一点
            force = game.forces.enemy
        }

        for _, enemy in pairs(area_enemies) do
            if enemy.valid then
                deal_damage_with_floating_text(enemy, player, damage, 'explosion')
            end
        end
    end
end)

function Public.huanxing_huoshan_penfa(position, surface, player, times)
    -- === 1. 范围搜索 ===
    -- 以鼠标/施法点为中心搜索
    local enemies = EntityCache.find_entities_cached(surface, {
        position = position,
        radius = 18,
        force = 'enemy',
        type = goal,
    })
    
    if #enemies == 0 then
        return false
    end

    -- === 2. 伤害计算 ===
    local rpg_t = Public.get_value_from_player(player.index)
    local magicka_bonus = rpg_t.magicka or 0
    
    local damage_multiplier = magicka_bonus * 1
    if damage_multiplier > 3000 then
        damage_multiplier = 3000
    end

    -- 伤害公式：基础伤害 + 等级成长 + 魔力加成
    -- 这是一个高爆发技能
    times = math.min(times, 80)
    local base_val = 100 + 65 * (times - 1)
    local total_damage = base_val + damage_multiplier

    -- 20% 初始灼烧伤害，80% 延迟爆发伤害
    local minor_damage = total_damage * 0.2
    local major_damage = total_damage * 0.8

    -- === 3. 目标选择（纯随机） ===
    -- 最大目标数：基础5个，每3级加1个
    local max_targets = math.min(10, 4 + math.floor(times / 5))
    
    -- 洗牌算法：打乱敌人列表顺序
    for i = #enemies, 2, -1 do
        local j = math.random(i)
        enemies[i], enemies[j] = enemies[j], enemies[i]
    end

    -- 取前 N 个目标
    local targets = {}
    local count = math.min(#enemies, max_targets)
    for i = 1, count do
        table.insert(targets, enemies[i])
    end

    -- === 4. 施法逻辑 ===
    for _, enemy in pairs(targets) do
        local lava_pos = enemy.position

        surface.create_entity({
          name = 'small-demolisher-fissure',
          position = lava_pos,
          force = player.force,
        })
        
        surface.create_entity({
          name = 'fire-flame',
          position = lava_pos,
          force = game.forces.enemy,
        })

        deal_damage_with_floating_text(enemy, player, minor_damage, 'fire')

            -- C. 延迟：注册2秒后的爆炸任务
            -- 传入 fixed 的 lava_pos，不传 enemy 实体
            Task.set_timeout_in_ticks(100, active_lava_burst_task, {
                surface = surface,
                pos = lava_pos,       -- 这是一个坐标点，不会随怪物移动
                player = player,
                damage = major_damage -- 计算好的大额伤害
            })
    end

    return true
end

local leizhenyu_work =
Token.register(
function(data)
    local surface = data.surface
    local position = data.position
    local player = data.player
    local damage = data.damage
    local radius = data.radius

    if not surface or not surface.valid then
        return
    end

    local enemies = surface.find_entities_filtered({
        position = position,
        radius = radius,
        force = 'enemy',
        type = goal
    })

    local strike_position
    if #enemies > 0 then
        local target = enemies[math.random(1, #enemies)]
        if target and target.valid then
            strike_position = target.position

            surface.create_entity({
                name = 'lightning',
                position = {x = strike_position.x, y = strike_position.y - 24},
                force = 'player',
                source = player.character,
                target = target,
                speed = 1.0
            })

            for _, enemy in pairs(enemies) do
 
                    local distance_from_center = math.sqrt(
                        (enemy.position.x - strike_position.x)^2 + (enemy.position.y - strike_position.y)^2
                    )
                    local damage_distance_modifier = math.max(0.3, 1 - distance_from_center / radius)
                    local final_damage = damage * damage_distance_modifier

                    deal_damage_with_floating_text(enemy, player, final_damage, 'electric')
               
            end
        end
    else
        local angle = math.random() * math.pi * 2
        local distance = math.random() * radius
        strike_position = {
            x = position.x + math.cos(angle) * distance,
            y = position.y + math.sin(angle) * distance
        }

        surface.create_entity({
            name = 'lightning',
            position = {x = strike_position.x, y = strike_position.y - 24},
            force = 'player',
            source = player.character,
            speed = 1.0
        })
    end
end
)

function Public.leizhenyu(position, surface, player, times)
    local level = times or 1
    if level > 80 then level = 80 end

    local rpg_t = Public.get_value_from_player(player.index)
    local magicka_bonus = rpg_t.magicka or 0
    local damage_multiplier = magicka_bonus * 1

    if damage_multiplier > 3000 then
        damage_multiplier = 3000
    end

    local damage = 60 + (level - 1) * 10 + damage_multiplier
    local radius = 6 + math.floor(level / 10)

    if radius > 8 then
        radius = 8
    end

    local total_strikes = 3 + math.floor(level / 8)

    if total_strikes > 8 then
        total_strikes = 8
    end

    for i = 1, total_strikes do
        Task.set_timeout_in_ticks(i * 60, leizhenyu_work, {
            surface = surface,
            position = position,
            player = player,
            damage = damage,
            radius = radius
        })
    end

    return true
end

return Public