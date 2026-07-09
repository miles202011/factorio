local WD = require 'modules.wave_defense.table'
local threat_values = require 'modules.wave_defense.threat_values'
local Event = require 'utils.event'
local BiterRolls = require 'modules.wave_defense.biter_rolls'
local math_random = math.random
local WPT = require 'maps.amap.table'
local Token = require 'utils.token'
local Task = require 'utils.task'
local BiterClass = require 'maps.amap.biter_class'

local Public = {}
local function more_biter()
  local this=WPT.get()
  local wave_number = WD.get('wave_number')
  local k =game.forces.enemy.get_evolution_factor()*1000
  if k >wave_number then
    wave_number=k
  end
  local count = 32 + math.floor(wave_number * 0.1)
  if count > 64 then
    count = 64
  end
  this.more_biter=this.more_biter+count
end

local group_out_time =
Token.register(
function(group)
  if  group and  group.valid then
--删除组内所有的虫子，并记录删除的个数
local k =0
    for _, entity in pairs(group.members) do
      if entity and entity.valid then
        entity.destroy()
        k=k+1
      end
    end
    local this=WPT.get()
    this.more_biter=this.more_biter+k
    group.destroy()
  end
end
)

local spawn_batch_units_token

local function attack_nearby_enemies(group, position)
  if not group or not group.valid then
    return
  end
  local nearby_entities = group.surface.find_entities_filtered{position = position, radius = 20, force = game.forces.player, limit=10}
  if #nearby_entities == 0 then
    return
  end
  
  local valid_targets = {}
  for _, entity_obj in pairs(nearby_entities) do
    if entity_obj.valid and entity_obj.health and entity_obj.type ~= "projectile" then
      table.insert(valid_targets, entity_obj)
    end
  end
  
  if #valid_targets == 0 then
    return
  end
  
  local commands = {}
  

  commands[#commands + 1] = {
    type = defines.command.attack_area,
    destination = valid_targets[1].position,
    radius = 16,
    distraction = defines.distraction.by_anything
  }
  
  for i = 1, #valid_targets, 1 do
    commands[#commands + 1] = {
      type = defines.command.attack,
      target = valid_targets[i],
      distraction = defines.distraction.by_anything
    }
  end

  if #commands > 0 and group.valid then
    group.set_command({
      type = defines.command.compound,
      structure_type = defines.compound_command.return_last,
      commands = commands
    })
  end
end

spawn_batch_units_token =
Token.register(
function(data)
  local surface = data.surface
  local valid_position = data.valid_position
  local force = data.force
  local unit_table = data.unit_table
  local group = data.group
  local batch_index = data.batch_index
  local total_batches = data.total_batches
  local wave_number = data.wave_number
  local total_count = data.total_count
  local created_count = data.created_count
  
  if not group or not group.valid then
    return
  end
  
  local batch_size = 12
  local start_index = (batch_index - 1) * batch_size + 1
  local end_index = math.min(batch_index * batch_size, #unit_table)
  
  local created_units = {}
  for i = start_index, end_index do
    if unit_table[i] then
      local biter = surface.create_entity({
        name = unit_table[i].name,
        position = valid_position,
        force = force,
        quality = unit_table[i].quality
      })
      if biter then
       
        table.insert(created_units, biter)
      end
    end
  end
  
  for _, biter in ipairs(created_units) do
    local nest_kills = WD.get('nest_kills_per_minute')
    if nest_kills >= 25 then
      biter.surface.create_entity({
        name = 'bioflux-speed-regen-sticker',
        position = biter.position,
        target = biter,
        force = force,
        quality="legendary"})
        if math_random(1, 500) <= nest_kills and wave_number < 1250 then
          -- BiterClass.assign_random_class(biter)
        end
    end
    
    if group and group.valid then
      group.add_member(biter)
    end
    

  end
  
  local new_created_count = created_count + #created_units
  
  if batch_index == 1 then
  end
  
  if batch_index < total_batches then
    data.batch_index = batch_index + 1
    data.created_count = new_created_count
    Task.set_timeout_in_ticks(2, spawn_batch_units_token, data)
  else
    if group and group.valid then
      attack_nearby_enemies(group, valid_position)
      Task.set_timeout_in_ticks(60 * 75, group_out_time, group)
    end
  end
end
)
local function remove_unit(entity)
  local active_biters = WD.get('active_biters')
  local unit_number = entity.unit_number
  if not active_biters[unit_number] then
    return
  end
  
  local active_threat_loss = threat_values[entity.name]
  local active_biter_threat = WD.get('active_biter_threat')
  local active_biter_count = WD.get('active_biter_count')
  
  local new_active_biter_count = active_biter_count - 1
  local new_active_biter_threat = active_biter_threat - active_threat_loss
  
  if new_active_biter_count <= 0 then
    new_active_biter_count = 0
    new_active_biter_threat = 0
  elseif new_active_biter_threat <= 0 then
    new_active_biter_threat = 0
  end
  
  WD.set('active_biter_threat', new_active_biter_threat)
  WD.set('active_biter_count', new_active_biter_count)
  active_biters[unit_number] = nil
  if active_threat_loss>= 64 then 
    if math_random(1, 20) == 1 then
    local position=entity.position
    local entities = entity.surface.find_entities_filtered{position = position, radius = 5,type = 'corpse'}
    if #entities == 0 then return false end
    for _, entity in pairs(entities) do
      
            entity.destroy()
   
    end
  end
end
end

local function place_nest_near_unit_group()
  local unit_groups = WD.get('unit_groups')
  local random_group = WD.get('random_group')
  local group = unit_groups[random_group]
  if not group then
    return
  end
  if not group.valid then
    return
  end
  if not group.members then
    return
  end
  if not group.members[1] then
    return
  end
  local unit = group.members[math_random(1, #group.members)]
  if not unit.valid then
    return
  end
  local name = 'biter-spawner'
  if math_random(1, 3) == 1 then
    name = 'spitter-spawner'
  end
  local position = unit.surface.find_non_colliding_position(name, unit.position, 12, 1)
  if not position then
    return
  end
  local r = WD.get('nest_building_density')
  if
  unit.surface.count_entities_filtered(
  {
    type = 'unit-spawner',
    force = unit.force,
    area = {{position.x - r, position.y - r}, {position.x + r, position.y + r}}
  }
) > 0
then
  return
end
local spawner = unit.surface.create_entity({name = name, position = position, force = unit.force})
local nests = WD.get('nests')
nests[#nests + 1] = spawner
unit.surface.create_entity({name = 'blood-explosion-huge', position = position})
unit.surface.create_entity({name = 'blood-explosion-huge', position = unit.position})
remove_unit(unit)
unit.destroy()
local threat = WD.get('threat')
WD.set('threat', threat - threat_values[name])
return true
end

function Public.build_nest()
  local threat = WD.get('threat')
  if threat < 1024 then
    return
  end
  local index = WD.get('index')
  if index == 0 then
    return
  end
  for _ = 1, 2, 1 do
    if place_nest_near_unit_group() then
      return
    end
  end
end

function Public.build_worm()
  local threat = WD.get('threat')
  if threat < 512 then
    return
  end
  local worm_building_chance = WD.get('worm_building_chance')
  if math_random(1, worm_building_chance) ~= 1 then
    return
  end

  local index = WD.get('index')
  if index == 0 then
    return
  end

  local random_group = WD.get('random_group')
  local unit_groups = WD.get('unit_groups')
  local group = unit_groups[random_group]
  if not group then
    return
  end
  if not group.valid then
    return
  end
  if not group.members then
    return
  end
  if not group.members[1] then
    return
  end
  local unit = group.members[math_random(1, #group.members)]
  if not unit.valid then
    return
  end

  local wave_number = WD.get('wave_number')

  local k =game.forces.enemy.get_evolution_factor()*1000
  if k >wave_number then
    wave_number=k
  end
  local position = unit.surface.find_non_colliding_position('assembling-machine-1', unit.position, 8, 1)
  BiterRolls.wave_defense_set_worm_raffle(wave_number)
  local worm = BiterRolls.wave_defense_roll_worm_name()
  if not position then
    return
  end

  local worm_building_density = WD.get('worm_building_density')
  local r = worm_building_density
  if
  unit.surface.count_entities_filtered(
  {
    type = 'turret',
    force = unit.force,
    area = {{position.x - r, position.y - r}, {position.x + r, position.y + r}}
  }
) > 0
then
  return
end
unit.surface.create_entity({name = worm, position = position, force = unit.force})
unit.surface.create_entity({name = 'blood-explosion-huge', position = position})
unit.surface.create_entity({name = 'blood-explosion-huge', position = unit.position})
remove_unit(unit)
unit.destroy()
WD.set('threat', threat - threat_values[worm])
end

local function shred_simple_entities(entity)
  local threat = WD.get('threat')
  if threat < 25000 then
    return
  end
  local simple_entities =
  entity.surface.find_entities_filtered(
  {
    type = 'simple-entity',
    position = entity.position,
    radius = 3
  }
)
if #simple_entities == 0 then
  return
end
if #simple_entities > 1 then
  table.shuffle_table(simple_entities)
end
local r = math.floor(threat * 0.00004)
if r < 1 then
  r = 1
end
local count = math.random(1, r)
--local count = 1
local damage_dealt = 0
for i = 1, count, 1 do
  if not simple_entities[i] then
    break
  end
  if simple_entities[i].valid then
    if simple_entities[i].health then
      damage_dealt = damage_dealt + simple_entities[i].health
      simple_entities[i].die()
    end
  end
end
if damage_dealt == 0 then
  return
end
local simple_entity_shredding_cost_modifier = WD.get('simple_entity_shredding_cost_modifier')
local threat_cost = math.floor(damage_dealt * simple_entity_shredding_cost_modifier)
if threat_cost < 1 then
  threat_cost = 1
end
WD.set('threat', threat - threat_cost)
end



local function check_and_update_spawn_throttle()
  local current_time = game.tick
  local spawn_count = WD.get('spawn_unit_spawner_count')
  local spawn_time = WD.get('spawn_unit_spawner_time')
  
  if current_time - spawn_time >= 120 then
    spawn_count = 0
    spawn_time = current_time
  end
  
  if spawn_count >= 10 then
    more_biter()
    return false
  end
  
  spawn_count = spawn_count + 1
  WD.set('spawn_unit_spawner_count', spawn_count)
  WD.set('spawn_unit_spawner_time', spawn_time)
  return true
end

local function get_or_generate_unit_table(count, current_time)
  local cached_unit_table = WD.get('unit_table')
  local cached_time = WD.get('unit_table_time')
  
  if cached_unit_table and next(cached_unit_table) and cached_time and (current_time - cached_time) < 600 then
    return cached_unit_table
  end
  
  local unit_table = BiterRolls.wave_defense_generate_unit_table(count, 0.75, 0.25, 6500)
  WD.set('unit_table', unit_table)
  WD.set('unit_table_time', current_time)
  return unit_table
end


local function spawn_unit_spawner_inhabitants(entity)
  if entity.type ~= 'unit-spawner' then
    return
  end

  if not check_and_update_spawn_throttle() then
    return
  end
  
  local current_time = game.tick
  local wave_number = WD.get('wave_number')
  local k = game.forces.enemy.get_evolution_factor() * 1000
  if k > wave_number then
    wave_number = k
  end
  
  local count = 32 + math.floor(wave_number * 0.1)
  if count > 64 then
    count = 64
  end
  
  BiterRolls.wave_defense_set_unit_raffle(wave_number)
  
  local valid_position = entity.surface.find_non_colliding_position('behemoth-biter', entity.position, 15, 1)
  if not valid_position then
    valid_position = entity.position
  end
  
  local group = entity.surface.create_unit_group({position = entity.position, force = entity.force})
  local unit_table = get_or_generate_unit_table(count, current_time)
  
  local batch_size = 12
  local total_batches = math.ceil(count / batch_size)
  
  local flat_unit_table = {}
  local has_quality_mod = script.active_mods['quality'] ~= nil
  
  for _, unit_info in ipairs(unit_table) do
    table.insert(flat_unit_table, {name = unit_info.unit_name, quality = unit_info.quality_name})
  end
  
  local data = {
    surface = entity.surface,
    valid_position = valid_position,
    force = 'enemy',
    unit_table = flat_unit_table,
    group = group,
    batch_index = 1,
    total_batches = total_batches,
    wave_number = wave_number,
    total_count = #flat_unit_table,
    created_count = 0
  }
  
  Task.set_timeout_in_ticks(0, spawn_batch_units_token, data)
end



local function on_entity_died(event)
    local entity = event.entity

    if not entity.valid then
        return
    end

    if entity.force ~= game.forces.enemy then
        return
    end

    if entity.surface ~= game.surfaces['nauvis'] then
        return
    end
    
    local disable_threat_below_zero = WD.get('disable_threat_below_zero')

    if entity.type == 'unit' or entity.type == 'spider-unit' then
        -- 处理普通虫子死亡
        if not threat_values[entity.name] then
            return
        end
        if disable_threat_below_zero then
            local threat = WD.get('threat')
            if threat <= 0 then
                WD.set('threat', 0)
                remove_unit(entity)
                return
            end
            WD.set('threat', threat - threat_values[entity.name])
            remove_unit(entity)
        else
            local threat = WD.get('threat')
            WD.set('threat', threat - threat_values[entity.name])
            remove_unit(entity)
        end
    else
        -- 处理非 unit 实体（如巢穴 Spawner）
        if entity.health and entity.type == 'unit-spawner' then
             local nest_kills = WD.get('nest_kills_per_minute')
              WD.set('nest_kills_per_minute', nest_kills + 1)
            if threat_values[entity.name] then
                local threat = WD.get('threat')
                WD.set('threat', threat - threat_values[entity.name])
            end
            
            local cause = event.cause
            if not cause then
                more_biter()
            else
                local dx = entity.position.x - cause.position.x
                local dy = entity.position.y - cause.position.y
                local dist = dx * dx + dy * dy
                if dist <= 62500 then 
                    spawn_unit_spawner_inhabitants(entity)
                 
                else 
                    more_biter()
                end
            end
        end

        -- 处理特殊 force 的逻辑
        if entity.force.index == 3 then
            if event.cause then
                if event.cause.valid then
                    if event.cause.force.index == 2 then
                        shred_simple_entities(entity)
                    end
                end
            end
        end
    end -- 这里闭合了 if entity.type == 'unit' 的 else
end -- 这里闭合了 function on_entity_died



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

local function reset_nest_kills_timer()
    local nest_kills = WD.get('nest_kills_per_minute')
    local new_value = nest_kills - 4
    if new_value < 0 then new_value = 0 end
    WD.set('nest_kills_per_minute', new_value)
end

Event.on_nth_tick(600, reset_nest_kills_timer)

return Public
