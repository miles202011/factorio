local Event = require 'utils.event'
local WPT = require 'maps.amap.table'
local WD = require 'modules.wave_defense.table'
local BiterRolls = require 'modules.wave_defense.biter_rolls'
local Token = require 'utils.token'
local Task = require 'utils.task'

local BiterClass = require 'maps.amap.biter_class'
local arty = require 'maps.amap.enemy_arty'
local entity_types = {
  ['unit'] = true,
  ['turret'] = true,
  ['unit-spawner'] = true,
  ['land-mine'] = true,
  ['spider-unit'] = true
}

local spawn_bonus = {
  ['rocket'] = {bonus = 500},
  ['explosive-rocket'] = {bonus = 600},
  ['destroyer-capsule'] = {bonus = 900},
  ['gun-turret'] = {bonus = 700},
  ['grenade'] = {bonus = 500},
  ['shachong'] = {bonus = 700},
  ['distractor-capsule'] = {bonus = 700},
  ['laser-turret'] = {bonus = 550},
  ['land-mine'] = {bonus = 1500},
}

local quality_upgrades = {
  { name = "legendary", base_chance = 0.005 },
  { name = "epic",      base_chance = 0.015 },
  { name = "rare",      base_chance = 0.025 },
  { name = "uncommon",  base_chance = 0.05 } 
}

local function select_random_quality(quality_raffle_cache, total_quality_weight, total_quality_chance)
    if script.active_mods['quality'] == nil or #quality_raffle_cache == 0 then
        return nil
    end
    
    if math.random() > total_quality_chance then
        return nil
    end
    
    if total_quality_weight <= 0 then
        return nil
    end
    
    local r = math.random() * total_quality_weight
    local current_weight = 0
    
    for _, item in ipairs(quality_raffle_cache) do
        current_weight = current_weight + item.weight
        if r <= current_weight then
            return item.name
        end
    end
    
    return #quality_raffle_cache > 0 and quality_raffle_cache[#quality_raffle_cache].name or nil
end

local function calculate_quality_raffle(wave_number)
    if wave_number < 300 then
        return {}, 0, 0
    end
    
    local this = WPT.get()
    local current_tick = game.tick
    
    if this.quality_raffle_cache_tick and current_tick - this.quality_raffle_cache_tick < 6000 then
        return this.quality_raffle_cache, this.quality_total_weight, this.quality_total_chance
    end
    
    local quality_upgrades = { 
        { name = "legendary", base_chance = 0.005 },
        { name = "epic",      base_chance = 0.015 },
        { name = "rare",      base_chance = 0.025 },
        { name = "uncommon",  base_chance = 0.05 } 
    }
    
    local progress = math.min((wave_number - 300) / (3000 - 300), 1)
    local total_quality_chance = progress * 1.0
    
    if total_quality_chance <= 0 then
        this.quality_raffle_cache = {}
        this.quality_total_weight = 0
        this.quality_total_chance = 0
        this.quality_raffle_cache_tick = current_tick
        return {}, 0, 0
    end
    
    local decay_progress = 0
    if wave_number >= 3000 then
        decay_progress = math.min((wave_number - 3000) / (6000 - 3000), 1)
    end
    
    local quality_raffle_cache = {}
    local total_quality_weight = 0
    local base_total = 0.005 + 0.015 + 0.025 + 0.05
    
    for _, item in ipairs(quality_upgrades) do
        local scaled_chance = (item.base_chance / base_total) * total_quality_chance
        quality_raffle_cache[item.name] = scaled_chance
    end
    
    if decay_progress > 0 then
        local transferable_qualities = {"epic", "rare", "uncommon"}
        local total_transfer = 0
        
        for _, name in ipairs(transferable_qualities) do
            local transfer_amount = quality_raffle_cache[name] * decay_progress
            quality_raffle_cache[name] = quality_raffle_cache[name] - transfer_amount
            total_transfer = total_transfer + transfer_amount
        end
        
        quality_raffle_cache["legendary"] = quality_raffle_cache["legendary"] + total_transfer
    end
    
    for name, chance in pairs(quality_raffle_cache) do
        table.insert(quality_raffle_cache, {name = name, weight = chance})
        total_quality_weight = total_quality_weight + chance
    end
    
    this.quality_raffle_cache = quality_raffle_cache
    this.quality_total_weight = total_quality_weight
    this.quality_total_chance = total_quality_chance
    this.quality_raffle_cache_tick = current_tick
    
    return quality_raffle_cache, total_quality_weight, total_quality_chance
end

local function select_quality_by_chance()
  if not script.active_mods['quality'] then
    return nil
  end
  
  local wave_number = WD.get('wave_number')
  if wave_number < 300 then
    return nil
  end
  
  local quality_raffle_cache, total_quality_weight, total_quality_chance = calculate_quality_raffle(wave_number)
  
  if total_quality_chance <= 0 then
    return nil
  end
  
  return select_random_quality(quality_raffle_cache, total_quality_weight, total_quality_chance)
end

local function get_worm_name(wave_number)
  if wave_number >= 800 then return 'behemoth-worm-turret' end
  if wave_number >= 400 then return 'big-worm-turret' end
  if wave_number >= 200 then return 'medium-worm-turret' end
  return 'small-worm-turret'
end

local function create_entity_params(name, position, surface, target, quality)
  return {
    name = name,
    position = position,
    force = 'enemy',
    source = position,
    target = target,
    speed = 0.3,
    move_stuck_players = true,
    quality = quality
  }
end

local do_die = Token.register(
  function(data)
    local position = data.position
    local surface = data.surface
    local source = data.source
    local name = data.name
    local should_offset = data.change
    local this = WPT.get()
    
    if should_offset and name ~= 'biter-spawner' then
      source = {
        x = source.x + math.random(-5, 5),
        y = source.y + math.random(-5, 5)
      }
    end
    
    local spawn_multiple_biters = false
    
    if name == 'shachong' then
      local wave_number = WD.get('wave_number')
      name = get_worm_name(wave_number)
    end
    
    local selected_quality = select_quality_by_chance()
    local e
    
    if not spawn_multiple_biters then
      e = surface.create_entity(create_entity_params(name, source, surface, position, selected_quality))
    else
      for i = 1, 32 do
        local quality = (selected_quality and i == 1) and selected_quality or nil
        e = surface.create_entity(create_entity_params('behemoth-biter', source, surface, position, quality))
      end
    end
    
    if e.name == 'gun-turret' then
      local ammo_name = arty.get_ammo()
      e.insert { name = ammo_name, count = 200 }
    end
    
    if e.name == 'laser-turret' then
      arty.add_laser(e)
    end
    
    if e.name == 'biter-spawner' then
      e.destructible = false
      this.biter_wudi[#this.biter_wudi + 1] = e
    end
  end
)

local spawn_categories = {
  buildings = {
    'biter-spawner',
    'shachong',
    'land-mine',
    'gun-turret',
    'laser-turret'
  },
  projectiles = {
    'explosive-rocket',
    'destroyer-capsule',
    'slowdown-capsule',
  }
}

local function get_random_spawn_category()
  local all_items = {}
  local is_building_flags = {}
  
  for _, name in ipairs(spawn_categories.buildings) do
    table.insert(all_items, name)
    table.insert(is_building_flags, true)
  end
  
  for _, name in ipairs(spawn_categories.projectiles) do
    table.insert(all_items, name)
    table.insert(is_building_flags, false)
  end
  
  local this = WPT.get()
  if not this.spawn_order_index then
    this.spawn_order_index = 1
  end
  local name = all_items[this.spawn_order_index]
  local is_building = is_building_flags[this.spawn_order_index]
  
  this.spawn_order_index = this.spawn_order_index % #all_items + 1
  
  return {name}, is_building
end

local function loaded_biters(entity, cause, count)

  if not entity or not entity.valid then
    return
  end


  local position
  
  if cause and cause.valid then
    position = cause.position
  else
    position = {
      x = entity.position.x + math.random(-5, 5),
      y = entity.position.y + math.random(-5, 5)
    }
  end

  local category_list, is_building = get_random_spawn_category()
  local name = category_list[1]
  
  if is_building then
    if cause and cause.valid then
      local dx = cause.position.x - entity.position.x
      local dy = cause.position.y - entity.position.y
      local distance = math.sqrt(dx * dx + dy * dy)
      
      if distance > 18 then
        local offset = math.min(distance, 3)
        position = {
          x = entity.position.x + (dx / distance) * offset,
          y = entity.position.y + (dy / distance) * offset
        }
      else
        position = entity.position
      end
    else
      position = entity.position
    end
  end

  if not count or count ==0  then
    local wave_number = math.min(WD.get('wave_number'), 4000)
    count = 1
    if spawn_bonus[name] then
      count = 1 + math.floor(wave_number / spawn_bonus[name].bonus)
    end
  end

  local this = WPT.get()
  for i = 1, count do
    this.biter_death_queue[#this.biter_death_queue + 1] = {
      position = position,
      surface = entity.surface,
      source = entity.position,
      name = name,
      change = is_building
    }
  end
end

local function process_death_queue()
  local this = WPT.get()
  if #this.biter_death_queue == 0 then
    return
  end

  local data = this.biter_death_queue[1]
  table.remove(this.biter_death_queue, 1)
  
  local position = data.position
  local surface = data.surface
  local source = data.source
  local name = data.name
  local should_offset = data.change
  local this_local = this
  
  if should_offset and name ~= 'biter-spawner' then
    source = {
      x = source.x + math.random(-5, 5),
      y = source.y + math.random(-5, 5)
    }
  end
  
  local spawn_multiple_biters = false
  
  if name == 'shachong' then
    local wave_number = WD.get('wave_number')
    name = get_worm_name(wave_number)
  end
  
  local selected_quality = select_quality_by_chance()
  local e
  
  if not spawn_multiple_biters then
    e = surface.create_entity(create_entity_params(name, source, surface, position, selected_quality))
  else
    for i = 1, 32 do
      local quality = (selected_quality and i == 1) and selected_quality or nil
      e = surface.create_entity(create_entity_params('behemoth-biter', source, surface, position, quality))
    end
  end
  
  if e and e.valid then
    if e.name == 'gun-turret' then
      local ammo_name = arty.get_ammo()
      e.insert { name = ammo_name, count = 200 }
    end
    
    if e.name == 'laser-turret' then
      arty.add_laser(e)
    end
    
    if e.name == 'biter-spawner' then
      e.destructible = false
      this_local.biter_wudi[#this_local.biter_wudi + 1] = e
    end
  end
end

local on_entity_died = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then
    return
  end
  
  local unit_number = entity.unit_number
    local biter_class_data = BiterClass.get()
    if biter_class_data.suicide_biter_units[unit_number] then
      loaded_biters(entity, event.cause, biter_class_data.suicide_biter_units[unit_number])
      biter_class_data.suicide_biter_units[unit_number] = nil
      return
    end
  
  if entity.force.index == game.forces.player.index then
    return
  end

  if not entity_types[entity.type] then
    return
  end

  if entity.name == 'land-mine' then

    loaded_biters(entity, event.cause)
    return
  end

  local wave_number = WD.get('wave_number')
  if wave_number <= 800 then return end
  
  local k = wave_number * 0.002 - 1
  if k >= 3 then k = 3 end
  k = 1
  if wave_number >= 1600 then
    k = 2
  end
  
  if math.random(1, 100) <= k then
    loaded_biters(entity, event.cause)
  end
end

local no_wudi = function()
  local this = WPT.get()
  local i = 1
  while i <= #this.biter_wudi do
    local e = this.biter_wudi[i]
    if e and e.valid then
      e.destructible = true
      table.remove(this.biter_wudi, i)
    else
      i = i + 1
    end
  end
end
    
Event.on_nth_tick(480, no_wudi)
Event.on_nth_tick(1, process_death_queue)
Event.add(defines.events.on_entity_died, on_entity_died)