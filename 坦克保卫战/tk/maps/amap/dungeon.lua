local Public = {}

local WPT = require 'maps.amap.table'
local Event = require 'utils.event'
local Gui = require 'utils.gui'
local Token = require 'utils.token'
local Task = require 'utils.task'

local DUNGEON_PRICE = 10000
local DUNGEON_TIME_LIMIT = 30 * 60 * 60
local MAX_COINS = 30000

local difficulty_settings = {
    easy = {
        name = "easy",
        recycling_efficiency = 1,
        max_coins = 40000,
        display_name_key = "dungeon_difficulty_easy"
    },
    normal = {
        name = "normal",
        recycling_efficiency = 0.8,
        max_coins = 50000,
        display_name_key = "dungeon_difficulty_normal"
    },
    hard = {
        name = "hard",
        recycling_efficiency = 0.6,
        max_coins = 60000,
        display_name_key = "dungeon_difficulty_hard"
    }
}

local recycling_prices = {
    ["iron-gear-wheel"] = 10,
    ["electronic-circuit"] = 15,
    ["rocket"] = 150,
    ["solar-panel"] = 600,
    ["chemical-science-pack"] = 1500
}

local market_prices = {
    ["coal"] = 5,
    ["transport-belt"] = 5,
    ["underground-belt"] = 20,
    ["fast-transport-belt"] = 50,
    ["fast-underground-belt"] = 200,
    ["splitter"] = 25,
    ["fast-splitter"] = 50,
    ["burner-inserter"] = 10,
    ["inserter"] = 10,
    ["long-handed-inserter"] = 15,
    ["fast-inserter"] = 20,
    ["wooden-chest"] = 5,
    ["iron-chest"] = 10,
    ["stone-furnace"] = 10,
    ["steel-furnace"] = 50,
    ["electric-furnace"] = 70,
    ["offshore-pump"] = 10,
    ["pipe"] = 5,
    ["pipe-to-ground"] = 20,
    ["boiler"] = 15,
    ["steam-engine"] = 50,
    ["small-electric-pole"] = 10,
    ["medium-electric-pole"] = 50,
    ["big-electric-pole"] = 100,
    ["substation"] = 150,
    ["assembling-machine-1"] = 30,
    ["assembling-machine-2"] = 50,
    ["assembling-machine-3"] = 100,
    ["electric-mining-drill"] = 50,
    ["burner-mining-drill"] = 10,
    ["pump"] = 20,
    ["pumpjack"] = 50,
    ["oil-refinery"] = 100,
    ["chemical-plant"] = 50,
    ["storage-tank"] = 40
}

local function restore_stone_wall(params)
    local player = game.players[params.player_index]
    if not player or not player.valid then return end
    
    player.remove_item({name = "stone-wall", count = 1})
    player.surface.create_entity({
        name = "stone-wall",
        position = params.position,
        force = player.force
    })
end

local restore_stone_wall_token = Token.register(restore_stone_wall)

local function remove_mined_item(params)
    local player = game.players[params.player_index]
    if not player or not player.valid then return end
    
    player.remove_item({name = params.item_name, count = 1})
end

local remove_mined_item_token = Token.register(remove_mined_item)

local function get_stone_wall_price(position)
    return math.abs(position.x) + math.abs(position.y)
end

local function is_position_on_resource(surface, position)
    local resources = surface.find_entities_filtered({
        position = position,
        radius = 0.5,
        type = 'resource'
    })
    
    return #resources > 0
end

local function get_dungeon_data(player_index)
    local this = WPT.get()
    if not this.dungeons then
        this.dungeons = {}
    end
    if not this.dungeons[player_index] then
        this.dungeons[player_index] = {
            active = false,
            surface_name = nil,
            original_surface = nil,
            original_character = nil,
            original_force = nil,
            original_position = nil,
            new_character = nil,
            dungeon_force = nil,
            start_tick = nil,
            time_limit = DUNGEON_TIME_LIMIT,
            player_index = nil,
            original_invincible = nil,
            coins_earned = 0,
            max_coins = MAX_COINS,
            recycling_chest = nil,
            difficulty = "easy", -- 默认难度为简单
            recycling_efficiency = 1 -- 默认回收效率为1
        }
    end
    return this.dungeons[player_index]
end

local function cleanup_force(force_name)
    local force = game.forces[force_name]
    if not force then return end
    
    for tech_name, _ in pairs(force.technologies) do
        local tech = force.technologies[tech_name]
        if tech.researched then
            tech.researched = false
        end
    end
    
    game.merge_forces(force_name, "player")
end

local function add_coins_with_limit(player, amount)
    local dungeon_data = get_dungeon_data(player.index)
    local can_add = dungeon_data.max_coins - dungeon_data.coins_earned
    
    if can_add <= 0 then
        return 0
    end
    
    local actual_add = math.min(amount, can_add)
    player.insert({name = "coin", count = actual_add})
    dungeon_data.coins_earned = dungeon_data.coins_earned + actual_add
    
    return actual_add
end

local function create_dungeon_exit_button(player)
    local top = player.gui.top
    if not top['dungeon_exit_button'] then
        local button = top.add({
            type = 'button',
            name = 'dungeon_exit_button',
            caption = {'amap.exit_dungeon'}
        })
        button.style.minimal_height = 38
        button.style.maximal_height = 38
        button.style.minimal_width = 100
    end
end

local function create_dungeon_timer(player)
    local top = player.gui.top
    if not top['dungeon_timer'] then
        local label = top.add({
            type = 'label',
            name = 'dungeon_timer',
            caption = ''
        })
        label.style.font_color = {1, 1, 0}
        label.style.font = 'default-bold'
    end
end

local function create_dungeon_coins(player)
    local top = player.gui.top
    if not top['dungeon_coins'] then
        local label = top.add({
            type = 'label',
            name = 'dungeon_coins',
            caption = ''
        })
        label.style.font_color = {1, 0.84, 0}
        label.style.font = 'default-bold'
    end
end

local function create_recycling_prices_button(player)
    local top = player.gui.top
    if not top['recycling_prices_button'] then
        local button = top.add({
            type = 'button',
            name = 'recycling_prices_button',
            caption = {'amap.recycling_prices'}
        })
        button.style.minimal_height = 38
        button.style.maximal_height = 38
        button.style.minimal_width = 100
    end
end

local function show_recycling_prices_gui(player)
    local screen = player.gui.screen
    
    if screen['recycling_prices_frame'] then
        screen['recycling_prices_frame'].destroy()
        return
    end
    
    local frame = screen.add({
        type = 'frame',
        name = 'recycling_prices_frame',
        caption = {'amap.recycling_prices'},
        direction = 'vertical'
    })
    frame.auto_center = true
    
    local scroll = frame.add({
        type = 'scroll-pane',
        vertical_scroll_policy = 'auto',
        horizontal_scroll_policy = 'never'
    })
    scroll.style.maximal_height = 400
    scroll.style.minimal_width = 300
    
    local table = scroll.add({
        type = 'table',
        column_count = 2
    })
    table.style.horizontal_spacing = 20
    table.style.vertical_spacing = 8
    
    table.add({
        type = 'label',
        caption = {'amap.item_name'},
        style = 'caption_label'
    })
    table.add({
        type = 'label',
        caption = {'amap.price'},
        style = 'caption_label'
    })
    
    for item_name, price in pairs(recycling_prices) do
        local item_label = table.add({
            type = 'label',
            caption = '[img=item/' .. item_name .. '] ' .. item_name
        })
        item_label.style.minimal_width = 150
        item_label.style.maximal_width = 150
        
        local price_label = table.add({
            type = 'label',
            caption = price .. ' [img=item/coin]'
        })
        price_label.style.font_color = {1, 0.84, 0}
        price_label.style.font = 'default-bold'
    end
end

local function show_difficulty_selection_gui(player)
    local screen = player.gui.screen
    
    if screen['difficulty_selection_frame'] then
        screen['difficulty_selection_frame'].destroy()
        return
    end
    
    local frame = screen.add({
        type = 'frame',
        name = 'difficulty_selection_frame',
        caption = {'amap.dungeon_difficulty_title'},
        direction = 'vertical'
    })
    frame.auto_center = true
    
    local scroll = frame.add({
        type = 'scroll-pane',
        vertical_scroll_policy = 'auto',
        horizontal_scroll_policy = 'never'
    })
    scroll.style.maximal_height = 300
    scroll.style.minimal_width = 280
    
    local table = scroll.add({
        type = 'table',
        column_count = 1
    })
    table.style.horizontal_spacing = 5
    table.style.vertical_spacing = 5
    
    for difficulty_key, difficulty_data in pairs(difficulty_settings) do
        local flow = table.add({
            type = 'flow',
            direction = 'vertical'
        })
        
        local title_label = flow.add({
            type = 'label',
            caption = {'amap.' .. difficulty_data.display_name_key}
        })
        title_label.style.font = 'default-bold'
        title_label.style.font_color = {1, 0.84, 0}
        
        local info_label = flow.add({
            type = 'label',
            caption = {'amap.dungeon_difficulty_info', 
                       difficulty_data.recycling_efficiency, 
                       difficulty_data.max_coins}
        })
        info_label.style.single_line = false
        
        local button = flow.add({
            type = 'button',
            name = 'dungeon_difficulty_' .. difficulty_key,
            caption = {'amap.dungeon_difficulty_select'}
        })
        button.style.minimal_width = 150
    end
end

local function update_dungeon_timer(player, remaining_ticks)
    local timer_label = player.gui.top['dungeon_timer']
    if not timer_label then return end
    
    local minutes = math.floor(remaining_ticks / 3600)
    local seconds = math.floor((remaining_ticks % 3600) / 60)
    timer_label.caption = {'amap.dungeon_time_remaining', minutes, seconds}
end

local function update_dungeon_coins(player)
    local coins_label = player.gui.top['dungeon_coins']
    if not coins_label then return end
    
    local dungeon_data = get_dungeon_data(player.index)
    local coins = dungeon_data.coins_earned or 0
    local max_coins = dungeon_data.max_coins or MAX_COINS
    coins_label.caption = {'amap.dungeon_coins_earned', coins, max_coins}
end

Public.get_difficulty_settings = function()
    return difficulty_settings
end

Public.get_difficulty = function(player_index)
    local dungeon_data = get_dungeon_data(player_index)
    return dungeon_data.difficulty or "easy"
end

Public.show_difficulty_selection_gui = function(player)
    show_difficulty_selection_gui(player)
end

local function cleanup_dungeon_gui(player)
    local top = player.gui.top
    
    if top['dungeon_exit_button'] then
        top['dungeon_exit_button'].destroy()
    end
    if top['dungeon_timer'] then
        top['dungeon_timer'].destroy()
    end
    if top['dungeon_coins'] then
        top['dungeon_coins'].destroy()
    end
    if top['recycling_prices_button'] then
        top['recycling_prices_button'].destroy()
    end
    
    local screen = player.gui.screen
    if screen['recycling_prices_frame'] then
        screen['recycling_prices_frame'].destroy()
    end
end

local function generate_ore_vein(surface, center_pos, ore_type, size)
    local vectors = {{0,-1},{-1,0},{1,0},{0,1}}
    local ore_positions = {}
    local ore_entities = {}
    
    local amount = 500 + math.random(0, 500)
    ore_entities[#ore_entities + 1] = {name = ore_type, position = center_pos, amount = amount}
    ore_positions[center_pos.x .. "_" .. center_pos.y] = true
    
    local count = size
    
    for _ = 1, 128 do
        local c = math.random(math.floor(size * 0.25) + 1, size)
        if count < c then c = count end
        
        local placed_ore_count = #ore_entities
        
        for _ = 1, c do
            if #ore_entities == 0 then break end
            
            local r = math.random(1, #ore_entities)
            local position = {x = ore_entities[r].position.x, y = ore_entities[r].position.y}
            
            table.shuffle_table(vectors)
            for i = 1, 4 do
                local p = {x = position.x + vectors[i][1], y = position.y + vectors[i][2]}
                if p.x >= -50 and p.x <= 50 and p.y >= -50 and p.y <= 50 then
                    if not ore_positions[p.x .. "_" .. p.y] then
                        position.x = p.x
                        position.y = p.y
                        ore_positions[p.x .. "_" .. p.y] = true
                        local new_amount = 500 + math.random(0, 500)
                        ore_entities[#ore_entities + 1] = {name = ore_type, position = p, amount = new_amount}
                        break
                    end
                end
            end
        end
        
        count = count - (#ore_entities - placed_ore_count)
        if count <= 0 then break end
    end
    
    for _, e in pairs(ore_entities) do
        surface.create_entity(e)
    end
end

local function generate_water_vein(surface, center_pos, size)
    local vectors = {{0,-1},{-1,0},{1,0},{0,1}}
    local water_positions = {}
    local water_tiles = {}
    
    water_tiles[#water_tiles + 1] = {name = "water", position = center_pos}
    water_positions[center_pos.x .. "_" .. center_pos.y] = true
    
    local count = size
    
    for _ = 1, 64 do
        local c = math.random(math.floor(size * 0.25) + 1, size)
        if count < c then c = count end
        
        local placed_water_count = #water_tiles
        
        for _ = 1, c do
            if #water_tiles == 0 then break end
            
            local r = math.random(1, #water_tiles)
            local position = {x = water_tiles[r].position.x, y = water_tiles[r].position.y}
            
            table.shuffle_table(vectors)
            for i = 1, 4 do
                local p = {x = position.x + vectors[i][1], y = position.y + vectors[i][2]}
                if p.x >= -50 and p.x <= 50 and p.y >= -50 and p.y <= 50 then
                    if not water_positions[p.x .. "_" .. p.y] then
                        position.x = p.x
                        position.y = p.y
                        water_positions[p.x .. "_" .. p.y] = true
                        water_tiles[#water_tiles + 1] = {name = "water", position = p}
                        break
                    end
                end
            end
        end
        
        count = count - (#water_tiles - placed_water_count)
        if count <= 0 then break end
    end
    
    surface.set_tiles(water_tiles)
end

local function generate_oil_patch(surface, center_pos, size)
    local vectors = {{0,-1},{-1,0},{1,0},{0,1},{-1,-1},{1,-1},{-1,1},{1,1}}
    local oil_positions = {}
    local oil_entities = {}
    
    local amount = 100000 + math.random(0, 66667)
    oil_entities[#oil_entities + 1] = {name = "crude-oil", position = center_pos, amount = amount}
    oil_positions[center_pos.x .. "_" .. center_pos.y] = true
    
    local count = size
    local max_oil_wells = 1
    
    for _ = 1, 16 do
        if #oil_entities >= max_oil_wells then break end
        
        local c = math.random(math.floor(size * 0.25) + 1, size)
        if count < c then c = count end
        
        local placed_oil_count = #oil_entities
        
        for _ = 1, c do
            if #oil_entities >= max_oil_wells then break end
            if #oil_entities == 0 then break end
            
            local r = math.random(1, #oil_entities)
            local position = {x = oil_entities[r].position.x, y = oil_entities[r].position.y}
            
            table.shuffle_table(vectors)
            for i = 1, 8 do
                local p = {x = position.x + vectors[i][1], y = position.y + vectors[i][2]}
                if p.x >= -50 and p.x <= 50 and p.y >= -50 and p.y <= 50 then
                    if not oil_positions[p.x .. "_" .. p.y] then
                        local tile = surface.get_tile(p.x, p.y)
                        if tile.name ~= "water" then
                            position.x = p.x
                            position.y = p.y
                            oil_positions[p.x .. "_" .. p.y] = true
                            local new_amount = 100000 + math.random(0, 66667)
                            oil_entities[#oil_entities + 1] = {name = "crude-oil", position = p, amount = new_amount}
                            break
                        end
                    end
                end
            end
        end
        
        count = count - (#oil_entities - placed_oil_count)
        if count <= 0 then break end
    end
    
    for _, e in pairs(oil_entities) do
        surface.create_entity(e)
    end
end

local function create_dungeon_market(surface, player)
    local market = surface.create_entity({
        name = "market",
        position = {x = 0, y = 5},
        force = player.force
    })
    
    if market then
        market.destructible = false
        market.minable = false
        
        local player_force = game.forces["player"]
        
        for item_name, price in pairs(market_prices) do
            local recipe = player_force.recipes[item_name]
            if (recipe and recipe.enabled ) or item_name =='coal' then
                market.add_market_item({
                    price = {{name = "coin", count = price}},
                    offer = {type = 'give-item', item = item_name, count = 1}
                })
            end
        end
    end
    
    local recycling_chest = surface.create_entity({
        name = "steel-chest",
        position = {x = -3, y = 5},
        force = player.force
    })
    
    if recycling_chest then
        recycling_chest.destructible = false
        recycling_chest.minable = false
        rendering.draw_text({
            text = "回收箱",
            surface = surface,
            target = {
                entity = recycling_chest,
                offset = {0, -2.6}
            },
            color = {
                r = 1,
                g = 0.5,
                b = 0
            },
            scale = 1.05,
            font = "default-large-semibold",
            alignment = "center"
        })
    end
    
    return market, recycling_chest
end

function Public.enter_dungeon(player, difficulty)
    if not player or not player.valid then return end
    
    local player_index = player.index
    local dungeon_data = get_dungeon_data(player_index)
    
    if dungeon_data.active then
        player.print({'amap.dungeon_already_active'}, {r = 1, g = 0, b = 0})
        return
    end
    
    local difficulty_key = difficulty or "easy"
    local difficulty_data = difficulty_settings[difficulty_key]
    
    if not difficulty_data then
        difficulty_key = "easy"
        difficulty_data = difficulty_settings.easy
    end
    
    dungeon_data.difficulty = difficulty_key
    dungeon_data.recycling_efficiency = difficulty_data.recycling_efficiency
    dungeon_data.max_coins = difficulty_data.max_coins
    dungeon_data.coins_earned = 0
    
    player.print({'amap.dungeon_difficulty_selected', {'amap.' .. difficulty_data.display_name_key}}, {r = 0, g = 1, b = 0})
    
    dungeon_data.original_surface = player.surface.name
    dungeon_data.original_character = player.character
    dungeon_data.original_force = player.force.name
    dungeon_data.original_position = {x = player.position.x, y = player.position.y}
    dungeon_data.player_index = player_index
    dungeon_data.active = true
    dungeon_data.start_tick = game.tick
    
    if dungeon_data.original_character then
        dungeon_data.original_character.destructible = false
        dungeon_data.original_invincible = true
    end
    
    local force_name = "dungeon_force_" .. player.name
    local force = game.forces[force_name]
    
    if not force then
        force = game.create_force(force_name)
        force.set_friend("player", true)
        force.set_friend("enemy", false)
        force.set_cease_fire("enemy", true)
        
        for f_name, f in pairs(game.forces) do
            if f_name ~= force_name and f_name ~= "enemy" and f_name ~= "neutral"  then
                force.set_friend(f_name, true)
                f.set_friend(force_name, true)
                force.share_chart=true
                f.share_chart=true
            end
        end
        

    end
    
    dungeon_data.dungeon_force = force_name
    player.force = force

    for tech_name, tech in pairs(force.technologies) do
        local player_tech = game.forces["player"].technologies[tech_name]
        if player_tech and player_tech.researched then
            local robot_techs = {
                "robotics",
                "construction-robotics",
                "logistic-robotics",
                "personal-roboport",
                "personal-roboport-mk2",
                "auto-character-logistic-trash-slots",
                "worker-robots-speed-1",
                "worker-robots-speed-2",
                "worker-robots-speed-3",
                "worker-robots-speed-4",
                "worker-robots-speed-5",
                "worker-robots-speed-6",
                "worker-robots-storage-1",
                "worker-robots-storage-2",
                "worker-robots-storage-3"
            }
            local is_robot_tech = false
            for _, robot_tech in ipairs(robot_techs) do
                if tech_name == robot_tech then
                    is_robot_tech = true
                    break
                end
            end
            if not is_robot_tech then
                tech.researched = true
            end
        end
    end

    local disabled_recipes = {
        "grenade",
        "explosive-rocket",
        "firearm-magazine",
        "shotgun-shell",
        "piercing-rounds-magazine",
        "tank",
        "car"
    }
    
    for _, recipe_name in ipairs(disabled_recipes) do
        local recipe = force.recipes[recipe_name]
        if recipe then
            recipe.enabled = false
        end
    end

    local surface_name = "dungeon_" .. player_index
    local surface = game.surfaces[surface_name]
    
    if not surface then
        local map_gen_settings = {}
        if script.active_mods["space-age"] then
            map_gen_settings = game.planets["nauvis"].prototype.map_gen_settings
        end
        map_gen_settings['seed'] = math.random(1, 4294967295)
        map_gen_settings['starting_area'] = 1
        map_gen_settings['default_enable_all'] = true
        map_gen_settings['water'] = 0.4
        map_gen_settings['width'] = 100
        map_gen_settings['height'] = 100
        map_gen_settings['peaceful_mode'] = false
        
        map_gen_settings.autoplace_controls = {
            ["coal"] = {frequency = "0", size = "0", richness = "0"},
            ["stone"] = {frequency = "0", size = "0", richness = "0"},
            ["copper-ore"] = {frequency = "0", size = "0", richness = "0"},
            ["iron-ore"] = {frequency = "0", size = "0", richness = "0"},
            ["uranium-ore"] = {frequency = "0", size = "0", richness = "0"},
            ["crude-oil"] = {frequency = "0", size = "0", richness = "0"},
            ["trees"] = {frequency = "2", size = "1", richness = "1"},
            ["enemy-base"] = {frequency = "2", size = "2", richness = "0"}
        }
        
        surface = game.create_surface(surface_name, map_gen_settings)
        
        surface.request_to_generate_chunks({0, 0}, 1)
        surface.force_generate_chunk_requests()
        
        force.set_spawn_position({0, 0}, surface)
        
        for x = -50, 50 do
            for y = -50, 50 do
                if not surface.get_tile(x, y).collides_with("resource") then
                    surface.set_tiles{{name = "grass-1", position = {x, y}}}
                end
            end
        end
        
        local ore_veins = {
            {type = "coal", count = 3},
            {type = "iron-ore", count = 3},
            {type = "copper-ore", count = 3}
        }
        
        for _, vein in pairs(ore_veins) do
            for i = 1, vein.count do
                local pos = {x = math.random(-40, 40), y = math.random(-40, 40)}
                local size = math.floor(math.random(10, 30) * 1.5)
                generate_ore_vein(surface, pos, vein.type, size)
            end
        end
        
        for i = 1, 2 do
            local pos = {x = math.random(-40, 40), y = math.random(-40, 40)}
            local size = math.random(15, 25)
            generate_water_vein(surface, pos, size)
        end
        
        for i = 1, 3 do
            local pos = {x = math.random(-40, 40), y = math.random(-40, 40)}
            local size = math.random(8, 15)
            generate_oil_patch(surface, pos, size)
        end
        
        local market, recycling_chest = create_dungeon_market(surface, player)
        
        if recycling_chest then
            dungeon_data.recycling_chest = recycling_chest
        end
        
        for x = -50, 50 do
            for y = -50, 50 do
                local tile = surface.get_tile(x, y)
                if tile.name ~= "water" then
                    local entities = surface.find_entities({{x, y}, {x + 1, y + 1}})
                    local has_resource = false
                    for _, entity in pairs(entities) do
                        if entity.type == "resource" then
                            has_resource = true
                            break
                        end
                    end
                    
                    if not has_resource and (math.abs(x) > 3 or math.abs(y) > 3) then
                        local is_market_pos = (x == 0 and y == 5)
                        local is_recycling_chest_pos = (x == -3 and y == 5)
                        
                        if not is_market_pos and not is_recycling_chest_pos then
                            surface.create_entity({
                                name = "stone-wall",
                                position = {x, y},
                                force = force
                            })
                        end
                    end
                end
            end
        end
    end
    
    dungeon_data.surface_name = surface_name
    
    local player_force = game.forces["player"]
    player_force.chart(surface, {{-50, -50}, {50, 50}})
    
    local new_character = surface.create_entity({
        name = "character",
        position = {0, 0},
        force = force
    })
    
    if new_character then
        dungeon_data.new_character = new_character
        
        player.set_controller({type = defines.controllers.ghost})
        player.teleport({0, 0}, surface)
        player.set_controller({
            type = defines.controllers.character,
            character = new_character
        })
        
        player.insert({name = "coin", count = 5000})
        dungeon_data.coins_earned = 0
        
        force.manual_mining_speed_modifier = 10
        force.mining_drill_productivity_bonus = 0
        force.manual_crafting_speed_modifier = -1
        
        
        create_dungeon_exit_button(player)
        create_dungeon_timer(player)
        create_dungeon_coins(player)
        create_recycling_prices_button(player)
        
        update_dungeon_timer(player, dungeon_data.time_limit)
        update_dungeon_coins(player)
        
        player.print({'amap.dungeon_enter_msg'}, {r = 0, g = 1, b = 0})
        game.print({'amap.player_entered_dungeon', player.name}, {r = 0, g = 1, b = 0})
    else
        player.print({'amap.dungeon_creation_failed'}, {r = 1, g = 0, b = 0})
        Public.exit_dungeon(player, "error")
    end
end

function Public.exit_dungeon(player, reason)
    if not player or not player.valid then return end
    
    local player_index = player.index
    local dungeon_data = get_dungeon_data(player_index)
    
    if not dungeon_data.active then return end
    
    local coins = player.get_item_count("coin")
    
    if dungeon_data.new_character and dungeon_data.new_character.valid then
        local new_character = dungeon_data.new_character
        
        local main_inventory = new_character.get_inventory(defines.inventory.character_main)
        local trash_inventory = new_character.get_inventory(defines.inventory.character_trash)
        local ammo_inventory = new_character.get_inventory(defines.inventory.character_ammo)
        local armor_inventory = new_character.get_inventory(defines.inventory.character_armor)
        local gun_inventory = new_character.get_inventory(defines.inventory.character_guns)
        
        if dungeon_data.original_character and dungeon_data.original_character.valid then
            local old_character = dungeon_data.original_character
            
            if coins > 0 then
                old_character.insert({name = "coin", count = coins})
            end
            
            if main_inventory then
                for i = 1, #main_inventory do
                    local item = main_inventory[i]
                    if item.valid_for_read and item.name ~= "coin" then
                        old_character.insert({name = item.name, count = item.count})
                    end
                end
            end
            
            if trash_inventory then
                for i = 1, #trash_inventory do
                    local item = trash_inventory[i]
                    if item.valid_for_read and item.name ~= "coin" then
                        old_character.insert({name = item.name, count = item.count})
                    end
                end
            end
            
            if ammo_inventory then
                for i = 1, #ammo_inventory do
                    local item = ammo_inventory[i]
                    if item.valid_for_read and item.name ~= "coin" then
                        old_character.insert({name = item.name, count = item.count})
                    end
                end
            end
            
            if armor_inventory then
                for i = 1, #armor_inventory do
                    local item = armor_inventory[i]
                    if item.valid_for_read and item.name ~= "coin" then
                        old_character.insert({name = item.name, count = item.count})
                    end
                end
            end
            
            if gun_inventory then
                for i = 1, #gun_inventory do
                    local item = gun_inventory[i]
                    if item.valid_for_read and item.name ~= "coin" then
                        old_character.insert({name = item.name, count = item.count})
                    end
                end
            end
        end
        
        new_character.destroy()
    end
    
    if dungeon_data.original_character and dungeon_data.original_character.valid then
        dungeon_data.original_character.destructible = true
        
        if dungeon_data.original_surface then
            local original_surface = game.surfaces[dungeon_data.original_surface]
            if original_surface then
                player.set_controller({type = defines.controllers.ghost})
                player.teleport(dungeon_data.original_position, original_surface)
                
                if dungeon_data.original_force then
                    local original_force = game.forces[dungeon_data.original_force]
                    if original_force then
                        player.force = original_force
                    end
                end
                
                player.set_controller({
                    type = defines.controllers.character,
                    character = dungeon_data.original_character
                })
            end
        end
    end
    
    if dungeon_data.dungeon_force then
        cleanup_force(dungeon_data.dungeon_force)
    end
    
    if dungeon_data.surface_name then
        local surface = game.surfaces[dungeon_data.surface_name]
        if surface then
            game.delete_surface(dungeon_data.surface_name)
        end
    end
    
    cleanup_dungeon_gui(player)
    
    local earned_coins = dungeon_data.coins_earned or 0
    
    local this = WPT.get()
    this.dungeons[player_index] = nil
    
    if reason == "timeout" then
        player.print({'amap.dungeon_timeout_msg'}, {r = 1, g = 0.5, b = 0})
    elseif reason == "manual" then
        player.print({'amap.dungeon_exit_msg'}, {r = 1, g = 1, b = 0})
    elseif reason == "error" then
        player.print({'amap.dungeon_error_msg'}, {r = 1, g = 0, b = 0})
    else
        player.print({'amap.dungeon_success_msg', coins}, {r = 0, g = 1, b = 0})
    end
    
    if earned_coins > 0 then
        game.print({'amap.dungeon_earned_coins_msg', player.name, earned_coins}, {r = 0.2, g = 0.8, b = 0.2})
    end
end

local function process_recycling_chest(player, dungeon_data)
    if not dungeon_data.active then return end
    
    local recycling_chest = dungeon_data.recycling_chest
    if not recycling_chest or not recycling_chest.valid then return end
    
    local inventory = recycling_chest.get_inventory(defines.inventory.chest)
    if not inventory or inventory.is_empty() then return end
    
    local total_coins_to_add = 0
    local items_to_remove = {}
    
    for item_name, price in pairs(recycling_prices) do
        local item_count = inventory.get_item_count(item_name)
        if item_count > 0 then
            local value = price * item_count * (dungeon_data.recycling_efficiency or 1)
            total_coins_to_add = total_coins_to_add + value
            items_to_remove[item_name] = item_count
        end
    end
    
    if total_coins_to_add > 0 then
        local can_add = dungeon_data.max_coins - dungeon_data.coins_earned
        
        if can_add > 0 then
            local coins_added = add_coins_with_limit(player, total_coins_to_add)
            
            for name, count in pairs(items_to_remove) do
                inventory.remove({name = name, count = count})
            end
            
            player.create_local_flying_text({
                text = "+" .. coins_added,
                position = recycling_chest.position,
                color = {r = 0, g = 1, b = 0},
                time_to_live = 120
            })
            
            if coins_added < total_coins_to_add then
                player.create_local_flying_text({
                    text = {'amap.dungeon_max_coins_reached_flying'},
                    position = recycling_chest.position,
                    color = {r = 1, g = 0.5, b = 0},
                    time_to_live = 120
                })
            else
                player.create_local_flying_text({
                    text = {'amap.dungeon_recycling_earned_flying', coins_added},
                    position = recycling_chest.position,
                    color = {r = 0, g = 1, b = 0},
                    time_to_live = 120
                })
            end
        else
            player.create_local_flying_text({
                text = {'amap.dungeon_max_coins_reached_flying'},
                position = recycling_chest.position,
                color = {r = 1, g = 0, b = 0},
                time_to_live = 120
            })
        end
    end
end

local function on_nth_tick_timeout()
    local this = WPT.get()
    if not this.dungeons then return end
    
    for player_index, dungeon_data in pairs(this.dungeons) do
        if dungeon_data.active then
            local elapsed = game.tick - dungeon_data.start_tick
            local remaining = dungeon_data.time_limit - elapsed
            
            if remaining <= 0 then
                local player = game.players[player_index]
                if player and player.valid then
                    Public.exit_dungeon(player, "timeout")
                else
                    local this = WPT.get()
                    if dungeon_data.dungeon_force then
                        cleanup_force(dungeon_data.dungeon_force)
                    end
                    if dungeon_data.surface_name then
                        game.delete_surface(dungeon_data.surface_name)
                    end
                    this.dungeons[player_index] = nil
                end
            end
        end
    end
end

local function on_nth_tick()
    local this = WPT.get()
    if not this.dungeons then return end
    
    for player_index, dungeon_data in pairs(this.dungeons) do
        if dungeon_data.active then
            local player = game.players[player_index]
            if player and player.valid and player.connected then
                local elapsed = game.tick - dungeon_data.start_tick
                local remaining = dungeon_data.time_limit - elapsed
                
                if remaining > 0 then
                    update_dungeon_timer(player, remaining)
                    update_dungeon_coins(player)
                    process_recycling_chest(player, dungeon_data)
                end
            end
        end
    end
end



local function on_gui_click(event)
    local element = event.element
    if not element.valid then return end
    
    if element.name == 'dungeon_exit_button' then
        local player = game.players[event.player_index]
        Public.exit_dungeon(player, "manual")
        return
    end
    
    if not element.valid then return end
    if element.name == 'recycling_prices_button' then
        local player = game.players[event.player_index]
        show_recycling_prices_gui(player)
        return
    end
    
    local difficulty_key = element.name:match('^dungeon_difficulty_(.+)$')
    if difficulty_key then
        local player = game.players[event.player_index]
        if player.gui.screen['difficulty_selection_frame'] then
            player.gui.screen['difficulty_selection_frame'].destroy()
        end
        Public.enter_dungeon(player, difficulty_key)
        return
    end
end

local function on_built_entity(event)
    local player = game.players[event.player_index]
    if not player or not player.valid then return end
    
    local dungeon_data = get_dungeon_data(player.index)
    if not dungeon_data.active then return end
    
    if player.surface.name ~= dungeon_data.surface_name then return end
    
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    if entity.name == "stone-wall" then
        if is_position_on_resource(entity.surface, entity.position) then
            return
        end
        
        local price = get_stone_wall_price(entity.position)
        player.insert({name = "coin", count = price})
        player.create_local_flying_text{text = "+" .. price, position = entity.position, color = {g = 1}, time_to_live = 150}
    end
end

local function on_robot_built_entity(event)
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    local surface_name = entity.surface.name
    if not string.find(surface_name, "^dungeon_%d+$") then return end
    
    if entity.name == "stone-wall" then
        if is_position_on_resource(entity.surface, entity.position) then
            return
        end
        
        local player_index = tonumber(string.match(surface_name, "^dungeon_(%d+)$"))
        if player_index then
            local player = game.players[player_index]
            if player and player.valid then
                local price = get_stone_wall_price(entity.position)
                player.insert({name = "coin", count = price})
                player.create_local_flying_text{text = "+" .. price, position = entity.position, color = {g = 1}, time_to_live = 150}
            end
        end
    end
end

local function on_player_mined_entity(event)
    local player = game.players[event.player_index]
    if not player or not player.valid then return end
    
    local dungeon_data = get_dungeon_data(player.index)
    if not dungeon_data.active then return end
    
    if player.surface.name ~= dungeon_data.surface_name then return end
    
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    if entity.name == "stone-wall" then
        local current_coins = player.get_item_count("coin")
        local cost = get_stone_wall_price(entity.position)
        
        if current_coins >= cost then
            player.remove_item({name = "coin", count = cost})
            player.create_local_flying_text{text = "-" .. cost, position = entity.position, color = {r = 1}, time_to_live = 150}
        else
            Task.set_timeout_in_ticks(2, restore_stone_wall_token, {
                player_index = player.index,
                position = entity.position
            })
        end
    end
end

local function on_pre_player_mined_item(event)
    local player = game.players[event.player_index]
    if not player or not player.valid then return end
    
    local dungeon_data = get_dungeon_data(player.index)
    if not dungeon_data.active then return end
    
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    local ore_prices = {
        ["coal"] = 5,
        ["iron-ore"] = 5,
        ["copper-ore"] = 5,
    }
    
    local price = ore_prices[entity.name]
    if price then
        local current_coins = player.get_item_count("coin")
        
        if current_coins >= price then
            player.remove_item({name = "coin", count = price})
        else
            Task.set_timeout_in_ticks(2, remove_mined_item_token, {
                player_index = player.index,
                item_name = entity.name
            })
        end
    end
end

local function on_robot_pre_mined(event)
    local entity = event.entity
    if not entity or not entity.valid then return end
    
    if entity.name == "stone-wall" then
        local surface = entity.surface
        local player_index = nil
        
        for _, player in pairs(game.connected_players) do
            local dungeon_data = get_dungeon_data(player.index)
            if dungeon_data.active and dungeon_data.surface_name == surface.name then
                player_index = player.index
                break
            end
        end
        
        if player_index then
            local player = game.players[player_index]
            local current_coins = player.get_item_count("coin")
            local cost = get_stone_wall_price(entity.position)
            
            if current_coins >= cost then
                player.remove_item({name = "coin", count = cost})
                player.create_local_flying_text{text = "-" .. cost, position = entity.position, color = {r = 1}, time_to_live = 150}
            else
                player.remove_item({name = "stone-wall", count = 1})
                Task.set_timeout_in_ticks(2, restore_stone_wall_token, {
                    player_index = player_index,
                    position = entity.position
                })
            end
        end
    end
end

Event.on_nth_tick(600, on_nth_tick_timeout)
Event.on_nth_tick(60, on_nth_tick)
Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_built_entity, on_built_entity)
Event.add(defines.events.on_robot_built_entity, on_robot_built_entity)
Event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
Event.add(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
Event.add(defines.events.on_robot_pre_mined, on_robot_pre_mined)

return Public
