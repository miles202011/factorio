local WPT = require 'maps.amap.table'
local WD = require 'modules.wave_defense.table'
local Loot = require "maps.amap.loot"
local BiterRolls = require 'modules.wave_defense.biter_rolls'
local MT = require "maps.amap.basic_markets"
local Factories = require 'maps.amap.production'
local diff = require 'maps.amap.diff'
local world_function = require 'maps.amap.world.world_function'
local WWT = require 'maps.amap.world.world_table'
local jixianchengshi = require 'maps.amap.world.word__jixianchengshi'
local beishuiyizhan = require 'maps.amap.world.word_beishuiyizhan'
local water_world = require 'maps.amap.world.word_water_world'
local yiciyuankongjian = require 'maps.amap.world.word_yiciyuankongjian'
local IslandManager = require 'maps.amap.island_manager'
local Token = require 'utils.token'
local enemy_arty = require 'maps.amap.enemy_arty'
local Task = require 'utils.task'
local weight_shop = 1
local weight_build = 3
local weight_box= 6
local weight_worm= 0

-- 虫巢价值表系统（参考enemy_arty.lua）
local enemy_base_value = {
  ["biter-spawner"] = {name = "biter-spawner", worth = 20, distance_threshold = 0},
  ["spitter-spawner"] = {name = "spitter-spawner", worth = 20, distance_threshold = 0},
  ["small-worm-turret"] = {name = "small-worm-turret", worth = 8, distance_threshold = 0},
  ["medium-worm-turret"] = {name = "medium-worm-turret", worth = 15, distance_threshold = 1408},
  ["big-worm-turret"] = {name = "big-worm-turret", worth = 25, distance_threshold = 2816},
  ["behemoth-worm-turret"] = {name = "behemoth-worm-turret", worth = 40, distance_threshold = 3220},
  ["gun-turret"] = {name = "gun-turret", worth = 5, distance_threshold = 1408},
  ["laser-turret"] = {name = "laser-turret", worth = 8, distance_threshold = 1408},
  ["flamethrower-turret"] = {name = "flamethrower-turret", worth = 10, distance_threshold = 2112},
  ["artillery-turret"] = {name = "artillery-turret", worth = 100, distance_threshold = 3535}
}

-- 世界7地形生成配置表
local world_7_terrain_config = {
  [0] = {
    generators = {
      function(surface, position, seed, get_tile)
        world_function.tree_cave(surface, position, seed, get_tile)
        world_function.water_dungle(surface, position, seed)
      end
    }
  },
  [1] = {
    clone_area_name = 'vulcanus',
    rock_generator = function(surface, position, seed, get_tile)
      world_function.vulcanus_rock_generator(surface, position, seed, get_tile)
    end
  },
  [2] = {
    clone_area_name = 'fulgora',
    rock_generator = function(surface, position, seed, get_tile)
      world_function.fulgora_rock_generator(surface, position, seed, get_tile)
    end
  },
  [3] = {
    generators = {
      function(surface, position, seed, get_tile)
        world_function.world_cave(surface, position, seed, get_tile)
      end
    }
  },
  [4] = {
    min_wave = 1250,
    clone_area_name = 'gleba',
    rock_generator = function(surface, position, seed, get_tile)
      world_function.gleba_rock_generator(surface, position, seed, get_tile)
    end
  }
}

-- 基于价值系统生成虫巢（参考enemy_arty.lua的baolei函数）
local function generate_enemy_base_by_value(surface, area, total_value, distance_from_base)
  local difficulty_multiplier = 1 + distance_from_base * 0.01
  local adjusted_value = total_value * difficulty_multiplier
  
  local can_build = {}
  for _, building in pairs(enemy_base_value) do
    if distance_from_base >= building.distance_threshold then
      table.insert(can_build, building)
    end
  end
  
  if #can_build == 0 then 
    return {} 
  end
  
  local remaining_value = adjusted_value
  local all_things = {}
  local attempt_count = 0
  local max_attempts = 200
  
  while remaining_value > 0 and attempt_count < max_attempts do
    attempt_count = attempt_count + 1
    
    local available_buildings = {}
    for _, building in ipairs(can_build) do
      if remaining_value >= building.worth then
        table.insert(available_buildings, building)
      end
    end
    
    if #available_buildings == 0 then 
      break 
    end
    
    local selected_building = available_buildings[math.random(1, #available_buildings)]
    
    local width = area.right_bottom.x - area.left_top.x
    local height = area.right_bottom.y - area.left_top.y
    
    if width <= 0 or height <= 0 then
        attempt_count = attempt_count - 1
        break
    end
    
    local random_x = area.left_top.x + math.random(0, width)
    local random_y = area.left_top.y + math.random(0, height)
    local random_position = {x = random_x, y = random_y}
    
    if surface.can_place_entity{name = selected_building.name, position = random_position} then
      local entity_data = {
        name = selected_building.name,
        position = random_position,
        force = "enemy"
      }
      
      if selected_building.name == 'flamethrower-turret' then
        entity_data.direction = 9
      end
      
      local entity = surface.create_entity(entity_data)
      
      if entity then
        table.insert(all_things, entity)
        remaining_value = remaining_value - selected_building.worth
        
        if entity.name == 'gun-turret' then
          enemy_arty.add_gun(entity)
        elseif entity.name == 'laser-turret' then
          enemy_arty.add_laser(entity)
        elseif entity.name == 'flamethrower-turret' then
          enemy_arty.add_flame(entity)
        elseif entity.name == 'artillery-turret' then
          enemy_arty.add_arty(entity)
        end
      end
    end
    
    if #all_things >= 200 then 
      break 
    end
  end
  
  return all_things
end

require "maps.amap.rocks_yield_ore"
require "modules.rocks_broken_paint_tiles"
require "modules.rocks_heal_over_time"
require "modules.rocks_yield_ore_veins"
require "modules.no_deconstruction_of_neutral_entities"


local math_abs = math.abs


local spawner={
'biter-spawner',
'spitter-spawner'
}
local function move_away_things(surface, area)
  for _, e in pairs(surface.find_entities_filtered({type = {"unit-spawner",  "unit", "tree"}, area = area})) do
    local position = surface.find_non_colliding_position(e.name, e.position, 128, 4)
    if position then
      surface.create_entity({name = e.name, position = position, force = "enemy"})
      e.destroy()
    end
  end
end


local function build_base(surface,maxs,event,position)
  if position.x>-4 and position.x<4 then
    if position.y>1 and position.y<5 then
      surface.set_tiles({{name = "water", position = position}})
    end
  end
  if maxs <= 65   then
    if maxs == 56  then
      move_away_things(surface, event.area)
    end
  end
end

local function rand_box(surface, position)
  local get_tile = surface.get_tile(position)
  if get_tile.valid and get_tile.name == 'out-of-map' then
  return
  end
  local chest = 'iron-chest'
  Loot.add(surface, position, chest)
end

local function rand_building(surface,maxs,position)

  local get_tile = surface.get_tile(position)
  if get_tile.valid and get_tile.name == 'out-of-map' then
  return
  end
  
  local wave_number = WD.get('wave_number')
  if wave_number > 1300 then
    return
  end
  
  local factory = Factories.roll_random_assembler(maxs)
  if not factory then return end

  local entity = surface.create_entity({name = factory.entity, force = "neutral", position = position})
  entity.destructible = false
  entity.minable = false
  entity.operable = false
  entity.active = false
  Factories.register_random_assembler(entity, factory.id, factory.tier)
end
local function rand_shop(surface,position,max)

  local get_tile = surface.get_tile(position)
  if get_tile.valid and get_tile.name == 'out-of-map' then
  return
  end
  local q =math_abs(position.x)/70
  local w =math_abs(position.y)/70


local maxs =math.floor(q+w)
if max then maxs=max end
MT.mountain_market(surface,position,maxs)
end

local function rand_worm(surface,position)
  local get_tile = surface.get_tile(position)
  if get_tile.valid and get_tile.name == 'out-of-map' then
  return false
  end
  BiterRolls.wave_defense_set_worm_raffle(math.sqrt(position.x ^ 2 + position.y ^ 2) * 0.19)
  surface.create_entity({name = BiterRolls.wave_defense_roll_worm_name(), position = position, force = 'enemy'})
  return true
end


local function ywjz(surface,position,maxs,shop)
  local this =WPT.get()
  local rand_k=math.random(1,maxs)
  local map=diff.get()
  local current_weight_box = weight_box
  local current_weight_shop = weight_shop
  local current_weight_build = weight_build
  
  if map and map.world == 1 then
    current_weight_box = weight_box * 1.5
  end
  
  if map and map.world == 2 then
    current_weight_build = weight_build * 2
  end
  
  if map and map.world == 6 then
    current_weight_shop = weight_shop * 1.5
  end
  
  if map and map.world == 11 then
    current_weight_shop = 0
  end
  

  
  if rand_k <= current_weight_shop then
    rand_shop(surface,position)
  end
  if current_weight_shop<rand_k and rand_k<= current_weight_shop+current_weight_build then
    if this.enable_wild_factorio then
    rand_building(surface,shop,position)
  end
  end
  if  current_weight_shop+current_weight_build<rand_k and rand_k <= current_weight_shop+current_weight_build+current_weight_box then
    rand_box(surface, position)
  end
  if  current_weight_shop+current_weight_build+current_weight_box <rand_k and rand_k <= current_weight_shop+current_weight_build+current_weight_box+weight_worm then
    rand_worm(surface, position)
  end

end
local function clone_area(surface_name, position, area,clear_destination_entities)
      if not game.surfaces[surface_name].is_chunk_generated(position) then
                    game.surfaces[surface_name].request_to_generate_chunks(position, 0)
                    game.surfaces[surface_name].force_generate_chunk_requests()
     end
     if game.surfaces[surface_name] then
        game.surfaces[surface_name].clone_area({
          source_area = area,
          destination_area = area,
          destination_surface =game.surfaces['nauvis'],
          clone_tiles = true,
          clone_entities = true,
          clone_decoratives = true,
          clear_destination_entities = clear_destination_entities,
          clear_destination_decoratives = true,
          expand_map = true,
          create_build_effect_smoke = false
        })
      end    
  
end


local function create_planet_surface(planet_name, active_surface_index, ziyuan, world_type)
    if game.planets[planet_name] and not game.surfaces[planet_name] then
        local map_gen_settings = table.deepcopy(game.planets[planet_name].prototype.map_gen_settings)
        map_gen_settings.seed = math.random(10000, 99999)
         
        map_gen_settings.autoplace_controls = map_gen_settings.autoplace_controls or {}
        
        if world_type == 7 or world_type == 8 then
            local planet_specials = {
                ["vulcanus"] = {"tungsten_ore", "calcite", "sulfuric_acid_geyser"},
                ["fulgora"] = {"scrap"},
                ["aquilo"] = {"lithium_brine", "fluorine_vent"}
            }

            local specials = planet_specials[planet_name]
            if specials then
                for _, res_name in ipairs(specials) do
                    local base_freq = 1.0
                    if ziyuan[res_name] then
                        base_freq = tonumber(ziyuan[res_name].frequency) or 1.0
                    end

                    map_gen_settings.autoplace_controls[res_name] = {
                        frequency = tostring(base_freq * 3),
                        size = "1.2",
                        richness = "1.2"
                    }
                end
            end

            if planet_name == "gleba" and ziyuan["gleba_enemy_base"] then
                map_gen_settings.autoplace_controls["gleba_enemy_base"] = table.deepcopy(ziyuan["gleba_enemy_base"])
                local freq = tonumber(ziyuan["gleba_enemy_base"].frequency) or 3
                map_gen_settings.autoplace_controls["gleba_enemy_base"].frequency = tostring(freq * 1.5)
            end
        end

        game.create_surface(planet_name, map_gen_settings)
        return true
    end
    return false
end


-- 世界生成函数表
local world_generators = {}

-- 世界1: 洞穴世界
world_generators[1] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y)
  if maxs >= 64 then
    world_function.world_cave(surface, position, seed, get_tile)
  end
end

-- 世界2: 四分之一世界
world_generators[2] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w,x,y,area)

  if maxs >= 64 then
    world_function.quarter(event, x, y)
  end
  
    if math.abs(q) < 1200 and math.abs(w) < 1200 and maxs >= 200 then
        ywjz(surface, position, 20000, maxs)
    end

  if maxs >= 200 and q < 0 and w < 0 then
    world_function.world_cave(surface, position, seed, get_tile)
  end

  if maxs >= 200 and x == 0 and y == 0 then

    if q<0 and w>0 then 
     if not game.surfaces["gleba"].is_chunk_generated(position) then
                    game.surfaces["gleba"].request_to_generate_chunks(position, 0)
                    game.surfaces["gleba"].force_generate_chunk_requests()
     end
     if game.surfaces["gleba"] then
        game.surfaces["gleba"].clone_area({
          source_area = area,
          destination_area = area,
          destination_surface =surface,
          clone_tiles = true,
          clone_entities = true,
          clone_decoratives = true,
          clear_destination_entities = true,
          clear_destination_decoratives = true,
          expand_map = true,
          create_build_effect_smoke = false
        })
      end
    end
    if q>0 and w<0 then 
     if not game.surfaces["vulcanus"].is_chunk_generated(position) then
                    game.surfaces["vulcanus"].request_to_generate_chunks(position, 0)
                    game.surfaces["vulcanus"].force_generate_chunk_requests()
     end
      if game.surfaces["vulcanus"] then
        game.surfaces["vulcanus"].clone_area({
          source_area = area,
          destination_area = area,
          destination_surface =surface,
          clone_tiles = true,
          clone_entities = true,
          clone_decoratives = true,
          clear_destination_entities = true,
          clear_destination_decoratives = true,
          expand_map = true,
          create_build_effect_smoke = false
        })
      
      end
    end
    if q>0 and w>0 then 
     if not game.surfaces["fulgora"].is_chunk_generated(position) then
                    game.surfaces["fulgora"].request_to_generate_chunks(position, 0)
                    game.surfaces["fulgora"].force_generate_chunk_requests()
     end
      if game.surfaces["fulgora"] then
        game.surfaces["fulgora"].clone_area({
          source_area = area,
          destination_area = area,
          destination_surface =surface,
          clone_tiles = true,
          clone_entities = true,
          clone_decoratives = true,
          clear_destination_entities = true,
          clear_destination_decoratives = true,
          expand_map = true,
          create_build_effect_smoke = false
        })
      
      end
    end
        if math.random(1, 8) == 1 then
          local spawner_name = spawner[math.random(1, 2)]
          local spawn_count = math.floor(maxs / math.random(50, 200))
       
          
          for i = 1, spawn_count do
            local worm_position=surface.find_non_colliding_position(spawner_name, position, 32, 4)
             if worm_position then
             rand_worm(surface, worm_position) 
             end
              local biter_position=surface.find_non_colliding_position(spawner_name, position, 32, 4)
              if biter_position then
                local e = surface.create_entity({
                  name = spawner_name,
                  position = biter_position,
                  force = game.forces.enemy,
                })
               
              
            end
          end
        end
  end
end




-- 世界6: 竞技场
world_generators[6] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y)
  if maxs >= 64 then
    world_function.world_cave_buff(surface, position, seed, get_tile, set_tiles)
  end
end

-- 世界7: 无矿石无虫子世界
world_generators[7] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y,area)
  area.left_top = {x = -100, y = area.left_top.y}
  area.right_bottom = {x = 100, y = area.right_bottom.y}
  if maxs >= 64 then
    if w < -50 then
        local mod_w = math.abs(w) % 704
      if mod_w >= 32 and mod_w <= 64 then
        return 
      end
      local nearest_base = math.floor(w / 704) * 704
      local base_y = nearest_base - 150
      local end_y = nearest_base + 150
      
      if not (q >= -100 and q <= 100 and w >= base_y and w <= end_y) then
        local y_range = math.floor((math.abs(w)) / 704) % 5
        local wave_number = WD.get('wave_number')
        local config = world_7_terrain_config[y_range]
        
        if config then
          if config.min_wave and wave_number < config.min_wave then
            config = nil
            local check_range = (y_range + 1) % 5
            while check_range ~= y_range do
              local check_config = world_7_terrain_config[check_range]
              if check_config and (not check_config.min_wave or wave_number >= check_config.min_wave) then
                config = check_config
                break
              end
              check_range = (check_range + 1) % 5
            end
          end
          
          if config and config.generators then
            for _, gen in ipairs(config.generators) do
              gen(surface, position, seed, get_tile)
            end
          end
          
          if config.clone_area_name and x == 0 and y == 0 then
            clone_area(config.clone_area_name, position, area, false)
          end
          
          if config.rock_generator and math.random(1, 3) == 1 then
            config.rock_generator(surface, position, seed, get_tile)
          end
        end
        
        if math.random(1, 220) == 1 then
          local spawner_name = spawner[math.random(1, 2)]
          if rand_worm(surface, position) then
            local e = surface.create_entity({
              name = spawner_name,
              position = position,
              force = game.forces.enemy,
            })
          end
        end
      end
    end
    if w > 100 then
      surface.set_tiles({{name = "out-of-map", position = position}})
    end
     if w % 704 == 0 and q == 0 then
 
      world_function.crate_ore(surface, position, 2, 40)
  
      local accumulator = surface.create_entity({
        name = "electric-energy-interface",
        position = position,
        force = game.forces.player
      })
      
      if accumulator and accumulator.valid then
        accumulator.destructible = false
        accumulator.operable = false
        accumulator.minable = false
        accumulator.energy = 1300000
      end
      
      local silo_position = {x = position.x, y = position.y + 10}
      local silo = surface.create_entity({
        name = "rocket-silo",
        position = silo_position,
        force = game.forces.player
      })
      
      if silo and silo.valid then
        silo.destructible = false
        silo.minable = false
      end
      end
  end
end

-- 世界8: 无矿石世界
world_generators[8] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y)
  if maxs >= 64 then
    world_function.world_cave(surface, position, seed, get_tile, set_tiles)
  end
end

-- 世界9: 特殊资源世界
world_generators[9] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y)
  if maxs >= 64 then
    if w > 0 then
      if q == 0 then
        if w % 200 == 0 and w % 1000 ~= 0 then
          local abc = math.floor(w / 200)
          if abc >= 3 then abc = 3 end
          world_function.crate_ore(surface, position, abc, 40)
          world_function.crate_water(surface, position, abc * 2)
        end
        if w % 1000 == 0 then
          world_function.crate_uore(surface, position, abc, 40)
        end
      end
    else
      if w <= -100 then
        ywjz(surface, position, 5000, maxs * 2)
        if math.random(1, 90) == 1 then
          local spawner_name = spawner[math.random(1, 2)]
          if rand_worm(surface, position) then
            local e = surface.create_entity({
              name = spawner_name,
              position = position,
              force = game.forces.enemy,
            })
          end
        end
      end
    end
  end
end

-- 世界10: 特殊规则世界
world_generators[10] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y)
  if maxs >= 64 then
    if w > 0 then
      if math.abs(q) < 1000 and math.abs(w) < 1000 then
        if math.random(1, 2) == 1 then
          ywjz(surface, position, 20000, maxs)
        end
      end
    end
    
    if w >= -165 and w <= -125 then
      surface.set_tiles({{name = "water-shallow", position = position}})
    end
    
    if w <= -180 then
      if math.random(1, 60) == 1 then
        local spawner_name = spawner[math.random(1, 2)]
        if surface.can_place_entity({name = spawner_name, position = position, force = game.forces.enemy}) then
          if rand_worm(surface, position) then
            local e = surface.create_entity({
              name = spawner_name,
              position = position,
              force = game.forces.enemy,
            })
          end
        end
      end
    end
  end
end

-- 世界11: 机械城市
world_generators[11] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y)
  if maxs <= 64 then
    local this = WPT.get()
    if not this.energy_recycler then
      local spawn_pos = {x = 0, y = 8}
      local recycler_pos = surface.find_non_colliding_position("steel-chest", spawn_pos, 10, 1)
      if recycler_pos then
        local recycler = surface.create_entity({
          name = "steel-chest",
          position = recycler_pos,
          force = "player",
          quality='legendary'
        })
        if recycler and recycler.valid then
          local text_id = rendering.draw_text {
            text = "回收箱",
            surface = surface,
            target = {
              entity = recycler,
              offset = {0, -2.6}
            },
            color = {
              r = 1,
              g = 0,
              b = 0,
              a = 1
            },
            scale = 1.05,
            font = "default-large-semibold",
            alignment = "center",
            scale_with_zoom = false
          }
           recycler.minable = false
          recycler.destructible = false
          this.energy_recycler = {entity = recycler, text_id = text_id}
        end
      end
    end
    
    if not this.laser_turrets_created then
      local turret_count = 0
      local turret_y = -28
      local turret_x_start = -68.25
      local turret_spacing = 3.5
      
      for i = 0, 39 do
        local turret_pos = {x = turret_x_start + i * turret_spacing, y = turret_y}
        local turret = surface.create_entity({
          name = "laser-turret",
          position = turret_pos,
          force = "player",
          minable = false,
          destructible = false
        })
        if turret and turret.valid then
          jixianchengshi.register_laser_turret(turret)
          turret_count = turret_count + 1
          turret.minable = false
        end
      end
      
      for i = 0, 39 do
        local turret_pos = {x = turret_x_start + i * turret_spacing, y = -25}
        local turret = surface.create_entity({
          name = "laser-turret",
          position = turret_pos,
          force = "player",
          minable = false,
          destructible = false
        })
        if turret and turret.valid then
          jixianchengshi.register_laser_turret(turret)
          turret_count = turret_count + 1
          turret.minable = false
          
        end
      end
      
      local wall_x_start = -68.25
      for i = 0, 136 do
        local wall_pos = {x = wall_x_start + i, y = -30}
        surface.create_entity({
          name = "stone-wall",
          position = wall_pos,
          force = game.forces.player
        })
      end
      
      for i = 0, 136 do
        local wall_pos = {x = wall_x_start + i, y = -31}
        surface.create_entity({
          name = "stone-wall",
          position = wall_pos,
          force = game.forces.player
        })
      end
      
      if turret_count > 0 then
        this.laser_turrets_created = true
      end
    end
    
    
  end
  
  if maxs >= 64 then
    if w < 0 then
      if math.abs(q) > 107 then
        surface.set_tiles({{name = "out-of-map", position = position}})
      else
        if w <= -150 then
          ywjz(surface, position, 5000, maxs * 2)
          if math.random(1, 90) == 1 then
            local spawner_name = spawner[math.random(1, 2)]
            if rand_worm(surface, position) then
              local e = surface.create_entity({
                name = spawner_name,
                position = position,
                force = game.forces.enemy,
              })
            end
          end
        end
      end
    end
  end
end

-- 世界12: 背水一战
world_generators[12] = function(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y)
  if maxs <= 64 then
    beishuiyizhan.create_initial_bio_lab(surface)
    
    local this = WPT.get()
    if not this.initial_resources_created then
      local coal_total = 750000
      local stone_total = 750000
      
      local coal_area = {x_min = -60, x_max = -30, y_min = -15, y_max = 15}
      local stone_area = {x_min = 30, x_max = 60, y_min = -15, y_max = 15}
      
      local coal_cells = (coal_area.x_max - coal_area.x_min) * (coal_area.y_max - coal_area.y_min)
      local stone_cells = (stone_area.x_max - stone_area.x_min) * (stone_area.y_max - stone_area.y_min)
      
      local coal_per_cell = math.floor(coal_total / coal_cells)
      local stone_per_cell = math.floor(stone_total / stone_cells)
      
      for cx = coal_area.x_min, coal_area.x_max do
        for cy = coal_area.y_min, coal_area.y_max do
          local pos = {x = cx, y = cy}
          if surface.can_place_entity({name = "coal", position = pos, amount = coal_per_cell}) then
            surface.create_entity({name = "coal", position = pos, amount = coal_per_cell})
          end
        end
      end
      
      for sx = stone_area.x_min, stone_area.x_max do
        for sy = stone_area.y_min, stone_area.y_max do
          local pos = {x = sx, y = sy}
          if surface.can_place_entity({name = "stone", position = pos, amount = stone_per_cell}) then
            surface.create_entity({name = "stone", position = pos, amount = stone_per_cell})
          end
        end
      end
      
      this.initial_resources_created = true
    end
  end
  
   if maxs >= 64 then
  if w <= 96 then
      if math.abs(q) > 107 then
        surface.set_tiles({{name = "out-of-map", position = position}})
      else
        if w <= -150 then
          ywjz(surface, position, 5000, maxs * 2)
          if math.random(1, 90) == 1 then
            local spawner_name = spawner[math.random(1, 2)]
            if rand_worm(surface, position) then
              local e = surface.create_entity({
                name = spawner_name,
                position = position,
                force = game.forces.enemy,
              })
            end
          end
        end
      end
    end
end
end

local function on_chunk_generated(event)

  local surface = event.surface
  local this = WPT.get()
  if not this.active_surface_index or not game.surfaces[this.active_surface_index] then return end
  if surface.name ~= "nauvis" then return end
  if	not(surface.index == game.surfaces[this.active_surface_index].index) then return end

  local left_top_x = event.area.left_top.x
  local left_top_y = event.area.left_top.y

  local seed = surface.map_gen_settings.seed
  local area = event.area
  local set_tiles = surface.set_tiles
  local get_tile = surface.get_tile
  local position

  local map=diff.get()

  if map.world==2 or map.world==7 or map.world==8 then
    local ziyuan = {}
    
    local planets = {"vulcanus", "fulgora", "gleba"}
    if map.world == 8 then
        table.insert(planets, "aquilo")
    end
    
    for _, planet_name in ipairs(planets) do
        create_planet_surface(planet_name, this.active_surface_index, ziyuan, map.world)
    end
end

  if map.world == 12 and left_top_y/32 > 2 then
    local this = WPT.get()
    if not this.port_discovered then
      if math.random(1, 100) <= 7 then
        this.ore_sequence_index = this.ore_sequence_index % 6 + 1
        local ore_name = this.ore_sequence[this.ore_sequence_index]
        local ore_total = 750000
        local ore_per_cell = math.floor(ore_total / 1024)
        if ore_name == "crude-oil" then
          for x = 2, 30, 5 do
            for y = 2, 30, 5 do
              local pos = {x = left_top_x + x, y = left_top_y + y}
              if surface.can_place_entity({name = ore_name, position = pos, amount = ore_total}) then
                surface.create_entity({name = ore_name, position = pos, amount = ore_total})
              end
            end
          end
        else
          for x = 0, 31 do
            for y = 0, 31 do
              local pos = {x = left_top_x + x, y = left_top_y + y}
              if surface.can_place_entity({name = ore_name, position = pos, amount = ore_per_cell}) then
                surface.create_entity({name = ore_name, position = pos, amount = ore_per_cell})
              end
            end
          end
        end
        return
      else
        local tiles = {}
        for x = 0, 31 do
          for y = 0, 31 do
            table.insert(tiles, {name = "deepwater", position = {x = left_top_x + x, y = left_top_y + y}})
          end
        end
        surface.set_tiles(tiles)
        return
      end
    end
  end

  for x = 0, 31, 1 do
    for y = 0, 31, 1 do
      position = {x = left_top_x + x, y = left_top_y + y}
      local q =position.x
      local w =position.y
      local maxs =math.abs(q+w)+math.abs(q-w)
      if maxs < 64 then
        build_base(surface, maxs, event, position)
      end
      
      if maxs >= 170 then
        if map.world == 6 or map.world == 8 then
          ywjz(surface, position, 5000, 9999)
        else
          if map.world ~= 3 and map.world ~= 9 and map.world ~= 10 and map.world ~= 2 and map.world ~= 11 and map.world ~= 12 then
            ywjz(surface, position, 20000, maxs)
          end
        end
      end
    end
  end
  
  if map.world == 3 then
    local chunk_area = {
      left_top = {x = left_top_x, y = left_top_y},
      right_bottom = {x = left_top_x + 32, y = left_top_y + 32}
    }
    local chunk_center_x = left_top_x + 16
    local chunk_center_y = left_top_y + 16
    local chunk_maxs = math.abs(chunk_center_x + chunk_center_y) + math.abs(chunk_center_x - chunk_center_y)
    
    if chunk_maxs >= 64  then
      world_function.water(surface, chunk_area, seed)
    end
  end
  
  if map.world ~= 3 then
    for x = 0, 31, 1 do
      for y = 0, 31, 1 do
        position = {x = left_top_x + x, y = left_top_y + y}
        local q =position.x
        local w =position.y
        local maxs =math.abs(q+w)+math.abs(q-w)
        
        if maxs >= 64 then
          if map.world == 7 and math.abs(q) >= 130 then
            return
          end
          
          local generator = world_generators[map.world]
          if generator then
            generator(surface, position, seed, get_tile, set_tiles, event, maxs, q, w, x, y,area)
          end
        end
      end
    end  end
end

local function on_robot_built_tile (event)

  local map=diff.get() 
  if map.world ~=3 then return end

  local tile=event.tile

  if tile.name ~="landfill" then return end
  local surface=game.surfaces[event.surface_index]

  local this = WPT.get()
  if game.surfaces[this.active_surface_index]~=surface then return end
  local tiles=event.tiles
  for _,v in pairs(tiles) do 
    surface.set_tiles({{name = 'water', position = v.position}}, true)
  end
  game.print({'amap.robot_cannot_landfill'})
  
  end

local function on_player_built_tile (event)
  local map = diff.get()
  if map.world ~= 3 then return end

  local tile = event.tile
  if tile.name ~= "landfill" then return end

  local surface = game.surfaces[event.surface_index]
  local this = WPT.get()
  if game.surfaces[this.active_surface_index] ~= surface then return end

  local tiles = event.tiles

  local min_x, max_x, min_y, max_y
  for _, v in pairs(tiles) do
    if not min_x then
      min_x, max_x = v.position.x, v.position.x
      min_y, max_y = v.position.y, v.position.y
    else
      min_x = math.min(min_x, v.position.x)
      max_x = math.max(max_x, v.position.x)
      min_y = math.min(min_y, v.position.y)
      max_y = math.max(max_y, v.position.y)
    end
  end

  local padding = 1
  min_x, max_x = min_x - padding, max_x + padding
  min_y, max_y = min_y - padding, max_y + padding

  local has_adjacent_land = false
  local test_entity = 'transport-belt'
  
  local sample_points = {
    {x = min_x, y = min_y},
    {x = max_x, y = min_y},
    {x = min_x, y = max_y},
    {x = max_x, y = max_y},
    {x = math.floor((min_x + max_x) / 2), y = min_y},
    {x = math.floor((min_x + max_x) / 2), y = max_y},
    {x = min_x, y = math.floor((min_y + max_y) / 2)},
    {x = max_x, y = math.floor((min_y + max_y) / 2)}
  }

  for _, point in ipairs(sample_points) do
    if surface.can_place_entity{name = test_entity, position = point, force = game.forces.neutral} then
      has_adjacent_land = true
      break
    end
  end

  if not has_adjacent_land then
    local player = game.players[event.player_index]
    player.print({'amap.cant_bulid_landfill'})

    for _, v in pairs(tiles) do
      if player.physical_position.x ~= v.position.x or player.physical_position.y ~= v.position.y then
        surface.set_tiles({{name = 'water', position = v.position}}, true)
        player.insert{name = 'landfill', count = 1}
      end
    end
  end
end

local function on_init()
  storage.rocks_yield_ore_maximum_amount = 999
  storage.rocks_yield_ore_base_amount = 100
  storage.rocks_yield_ore_distance_modifier = 0.020
  storage.watery_world_fishes = {}
  for _, prototype in pairs(prototypes.entity) do
    if prototype.type == "fish" then
      table.insert(storage.watery_world_fishes, prototype.name)
    end
  end
end


local Event = require 'utils.event'
Event.on_init(on_init)

--Event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
Event.add(defines.events.on_chunk_generated, on_chunk_generated)
--Event.add(defines.events.on_player_built_tile , on_player_built_tile)
--Event.add(defines.events.on_robot_built_tile  , on_robot_built_tile )
Event.add(defines.events.on_built_entity, on_built_entity,
    {filter = "type", type = 'land-mine'},
    {filter = "type", type = 'character'},
    {filter = "type", type = 'car'},
     {filter = "type", type = 'wall'},
    {filter = "type", type = 'spider-vehicle'},
    {filter = "type", type = 'ammo-turret'},
    {filter = "type", type = 'electric-turret'},
    {filter = "type", type = 'fluid-turret'},
    {filter = "type", type = 'radar'},
    {filter = "type", type = 'roboport'})
