local Public = {}

local WPT = require 'maps.amap.table'
local Event = require 'utils.event'
local Alert = require 'utils.alert'
local WD = require 'modules.wave_defense.table'
local RPG = require 'modules.rpg.table'
local Server = require 'utils.server'
local Factories = require 'maps.amap.production'
local diff = require 'maps.amap.diff'
local functions = require 'maps.amap.functions'
local round = math.round
local List = require 'maps.amap.production_list'
local MT = require "maps.amap.basic_markets"
local rpgtable = require 'modules.rpg.table'


local tianfu = require 'maps.amap.tianfu'
local EnemyArty = require 'maps.amap.enemy_arty'
local Dungeon = require 'maps.amap.dungeon'

local function protect(entity, operable)
    entity.minable = false
    entity.destructible = false
    entity.operable = operable
end

----
local urgrade_item = function(market)
    local this = WPT.get()
    local price_mine = this.urgrad_mine * 4000 + 1000
    local price_wall = this.health * 2000 + 15000
    local price_arty = this.arty * 10000 + 20000
    local price_biter_dam = this.biter_dam * 3000 + 3000
    local price_all_dam = this.urgrad_all_dam * 10000 + 10000

    local biter_nest = (this.max_nest_number - 1) * 3000 + 5000
    local biter_worm = (this.max_worm_number - 1) * 3000 + 5000

    local max_price = 65000

    if biter_worm >= max_price then
        biter_worm = max_price
    end

    if biter_nest >= max_price then
        biter_nest = max_price
    end

    if price_arty >= max_price then
        price_arty = max_price
    end
    if price_all_dam >= max_price then
        price_all_dam = max_price
    end
    if price_mine >= max_price then
        price_mine = max_price
    end

    if price_wall >= max_price then
        price_wall = max_price
    end

    if price_biter_dam >= max_price then
        price_biter_dam = max_price
    end
    local health_wall = {
        price = {{name = "coin", count = price_wall}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.buy_health_wall', this.health * 0.1}
        }
    }

    local arty_dam = {
        price = {{name = "coin", count = price_arty}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.buy_arty_dam', this.arty * 0.1}
        }
    }
    local player_biter_dam = {
        price = {{name = "coin", count = price_biter_dam}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.player_biter_dam', this.biter_dam * 0.1}
        }
    }

    local buy_urgrade_all_dam = {
        price = {{name = "coin", count = price_all_dam}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.buy_all_dam', this.urgrad_all_dam * 0.01}
        }
    }
    local urgrade_mine = {
        price = {{name = "coin", count = price_mine}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.urgrade_mine', this.urgrad_mine * 200 + 400}
        }
    }

    local biter_nest_item = {
        price = {{name = "coin", count = biter_nest}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.biter_nest', this.max_nest_number}
        }
    }
    local biter_worm_item = {
        price = {{name = "coin", count = biter_worm}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.biter_worm', this.max_worm_number}
        }
    }

    local buy_tianfu = {
        price = {{name = "coin", count = 65000}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.buy_talent'}
        }
    }
    
    local buy_protectors = {
        price = {{name = "coin", count = 1000}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.buy_protectors', this.protectors_value * 10}
        }
    }
    
    local buy_dungeon = {
        price = {{name = "coin", count = 10000}},
        offer = {
            type = 'nothing',
            effect_description = {'amap.enter_dungeon'}
        }
    }
    
    
    market.add_market_item(health_wall)
    market.add_market_item(buy_urgrade_all_dam)
    -- market.add_market_item(player_biter_dam)
    -- market.add_market_item(buy_urgrade_rock_dam)
    -- market.add_market_item(buy_urgrade_laser_dam)
    -- market.add_market_item(buy_urgrade_bullet_dam)
    -- market.add_market_item(buy_urgrade_electric_dam)
    market.add_market_item(arty_dam)
    market.add_market_item(urgrade_mine)

    market.add_market_item(biter_nest_item)
    market.add_market_item(biter_worm_item)
    market.add_market_item(buy_tianfu)
    market.add_market_item(buy_protectors)
    market.add_market_item(buy_dungeon)
end

local market_items = {{
    price = {{name = "coin", count = 4}},
    offer = {
        type = 'give-item',
        item = "raw-fish",
        count = 1
    }
}, {
    price = {{name = "raw-fish", count = 1}},
    offer = {
        type = 'give-item',
        item = 'coin',
        count = 4
    }
}, {
    price = {{name = "coin", count = 1000}},
    offer = {
        type = 'give-item',
        item = 'car',
        count = 1
    }
}, {
    price = {{name = "coin", count = 6000}},
    offer = {
        type = 'give-item',
        item = 'tank',
        count = 1
    }
}, {
    price = {{name = "coin", count = 60000}},
    offer = {
        type = 'give-item',
        item = 'spidertron',
        count = 1
    }
}, -- {price = {{name = "coin", count = 500}}, offer = {type = 'give-item', item = 'spidertron-remote', count = 1}},
{
    price = {{name = "coin", count = 35000}},
    offer = {
        type = 'give-item',
        item = 'tank-cannon',
        count = 1
    }
}, {
    price = {{name = "coin", count = 128}},
    offer = {
        type = 'give-item',
        item = 'loader',
        count = 1
    }
}, {
    price = {{name = "coin", count = 512}},
    offer = {
        type = 'give-item',
        item = 'fast-loader',
        count = 1
    }
}, {
    price = {{name = "coin", count = 4096}},
    offer = {
        type = 'give-item',
        item = 'express-loader',
        count = 1
    }
}, {
    price = {{name = "coin", count = 12288}},
    offer = {
        type = 'give-item',
        item = 'turbo-loader',
        count = 1
    }
}, {
    price = {{name = "coin", count = 400}},
    offer = {
        type = 'give-item',
        item = 'artillery-shell',
        count = 1
    }
} -- {price = {{name = "coin", count = 60000}}, offer = {type = 'give-item', item = 'rocket-silo', count = 1}}
}




local function get_rand_item()
    local rand_item = {}
    local wave_number = WD.get('wave_number') or 0
    
    local rarity = math.floor( (wave_number / 100))
    
    if rarity < 2 then
        rarity = 2
    end
    if rarity > 12 then
        rarity = 12
    end
    rand_item = MT.get_random_item(rarity, false, false)
    return rand_item
end

function Public.refresh_shop(market)
    if not market or not market.valid then
        return
    end
    market.clear_market_items()
    urgrade_item(market)
    for _, item in pairs(market_items) do
        market.add_market_item(item)
    end

    
    local this = WPT.get()
    if this.world_number ~= 11 then
            local rand_item = get_rand_item()

    for _, item in pairs(rand_item) do
        item.price[1].count = math.floor(item.price[1].count * 1.1)
        market.add_market_item(item)
    end

    end


    if this.world_number == 8 or this.world_number == 7 then
        market.add_market_item({
            price = {{name = "coin", count = 300}},
            offer = {
                type = 'give-item',
                item = 'car',
                count = 1
            }
        })
    end
    game.print({'amap.refresh_shop'})
end

function Public.ft(surface, y)
    local factory = "assembling-machine-2"
    for key = 1, 20, 1 do
        if List[key].kind == "furnace" then
            factory = "electric-furnace"
        else
            factory = "assembling-machine-2"
        end
        local position = {
            x = -16 + key * 3,
            y = -18 + y
        }
        if (key >= 11) then
            position = {
                x = -46 + key * 3,
                y = -12 + y
            }
        end
        local e = surface.create_entity({
            name = factory,
            force = "player",
            position = position
        })
        e.active = false
        protect(e, false)
        e.rotatable = false
        Factories.register_train_assembler(e, key)
        if List[key].kind == "assembler" or List[key].kind == "fluid-assembler" then
            e.set_recipe(List[key].recipe_override or List[key].name)
            e.recipe_locked = true
            e.direction = defines.direction.south
        end
    end
end

function Public.market(surface)
    local this = WPT.get()

    local silo
    if this.world_number ~= 8 then
        if this.world_number == 7 then
            silo = surface.create_entity {
                name = "spidertron",
                position = {
                    x = 0,
                    y = 10
                },
                force = game.forces.player
            }
            silo.grid.inhibit_movement_bonus = true
            
            -- 在世界7的主世界创建不可被挖掘不可被破坏的蓄电池
            local accumulator = surface.create_entity({
                name = 'electric-energy-interface',
                position = {
                    x = 0,
                    y = 6
                },
                force = 'player',
                create_build_effect_smoke = false
            })
         accumulator.destructible = false
                --设置为不可操作
                accumulator.operable = false
                accumulator.minable = false
                 --设置发电量为130MW

         local silo_position = {x = 0, y =   16}
      local silo = surface.create_entity({
        name = "rocket-silo",
        position = silo_position,
        force = game.forces.player
      })
      
      if silo and silo.valid then
        silo.destructible = false
        silo.minable = false
      end
            -- 在世界7的异世界创建不可被挖掘不可被破坏的蓄电池
        else
            silo = surface.create_entity {
                name = "rocket-silo",
                position = {
                    x = 0,
                    y = 16
                },
                force = game.forces.player
            }
        end
        if this.world_number == 10 then
          rendering.draw_text {
            text = "司令部",
            surface = silo.surface,
            target = {
              entity = silo,
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
          }

          --生成曹军的3个堡垒
          --坐标分别为：{100，-350}，{0，-350}，{-100，-350}
          local baolei_positions = {
            {x = 100, y = -350},
            {x = 0, y = -350},
            {x = -100, y = -350}
          }
          
          for _, pos in pairs(baolei_positions) do
            EnemyArty.baolei(pos, 650, surface)
          end
        end
    else
        silo = surface.create_entity {
            name = "spidertron",
            position = {
                x = 0,
                y = 10
            },
            force = game.forces.player
        }
        silo.grid.inhibit_movement_bonus = true
        -- Task.set_timeout_in_ticks(60*5, zhizhu, silo)
        local e3 = surface.create_entity({
            name = 'linked-chest',
            position = {
                x = 0,
                y = 9
            },
            force = 'player',
            create_build_effect_smoke = false
        })

        e3.destructible = false
        e3.minable = false
        
        -- 在世界8的主世界创建不可被挖掘不可被破坏的蓄电池
        local accumulator = surface.create_entity({
            name = 'electric-energy-interface',
            position = {
                x = 0,
                y = 6
            },
            force = 'player',
            create_build_effect_smoke = false
        })
        accumulator.destructible = false
        accumulator.minable = false
        accumulator.operable = false

                 local silo_position = {x = 0, y =  16}
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


    local market = surface.create_entity {
        name = "market",
        position = {
            x = 0,
            y = -5
        },
        force = game.forces.player
    }
    this.silo = silo
    this.shop = market
    silo.minable = false
    market.destructible = false
    Public.refresh_shop(market)
end

local function on_rocket_launched(event)
    if true then return end
      if event.rocket_silo.surface.name ~= 'nauvis' then return end
    local this = WPT.get()
    local rpg_t = RPG.get('rpg_t')
    local money = 1000
    local point = 0
    local map = diff.get()
    if map.rocket_diff then
        money = money + this.times * 1000
    end

    if money >= 500 then
        money = 500
    end
    if this.goal == 1 and this.times == 2 then
        game.print {'amap.goal_1'}
          game.print({'amap.reward', this.times, point, money}, {
            r = 0.22,
            g = 0.88,
            b = 0.22
        })
    end

    for k, player in pairs(game.connected_players) do
        rpg_t[player.index].points_left = rpg_t[player.index].points_left + point
        player.insert {
            name = 'coin',
            count = money
        }
      

       
        -- if not map.cunkuang[player.name] then
        --     map.cunkuang[player.name] = 0
        -- end
        -- local coin = 100 * (this.times - 1)
        -- coin = 50
        -- if coin >= 1000 then
        --     coin = 1000
        -- end
        -- map.cunkuang[player.name] = map.cunkuang[player.name] + coin
        -- if map.cunkuang[player.name] >= 10000 then
        --     map.cunkuang[player.name] = 10000
        -- end

        -- player.print('你的账户已存入' .. coin ..
        --                  '金币，之后的对局中，你可以输入/tk [金币数]，来取出你的金币,存款上限为10K')
    end
    if not this.pass then
        local wave_number = WD.get('wave_number')
        local msg = {'amap.pass', wave_number}
        for k, player in pairs(game.connected_players) do
            Alert.alert_player(player, 25, msg)
        end
        Server.to_discord_embed(table.concat({'** we win the game ! Record is ', wave_number}))
        this.pass = true
    end
    this.times = this.times + 1
end


local function on_market_item_purchased(event)
    local this = WPT.get()
    local market = event.market
    if market ~= this.shop then
        return
    end
    local player = game.players[event.player_index]

    local offer_index = event.offer_index
    local offers = market.get_market_items()
    local bought_offer = offers[offer_index].offer


    if bought_offer.type ~= "nothing" then
        return
    end
    local wave_number = WD.get('wave_number')

    if offer_index == 1 then
        this.health = this.health + 1
        functions.set_force_damage_modifier(game.forces.enemy, -0.1)
        game.print({'amap.buy_wall_over', player.name, this.health * 0.1})
    end

    
 
    if offer_index == 2 then
        local damage_multiplier = this.damage_multiplier or 1
        if damage_multiplier > 0.98 then
            local price_all_dam = this.urgrad_all_dam * 10000 + 10000
            local max_price = 65000
            if price_all_dam >= max_price then
                price_all_dam = max_price
            end
            player.insert({name = "coin", count = price_all_dam})
            player.print({'amap.damage_multiplier_max', player.name})
            return
        end
        this.urgrad_all_dam = this.urgrad_all_dam + 1
        functions.set_force_damage_modifier(game.forces.player, 0.01,true)
        game.print({'amap.urgrad_all_dam_over', player.name, this.urgrad_all_dam * 0.01})
    end

    if offer_index == 3 then
        this.arty = this.arty + 1
        local e_old = game.forces.player.get_ammo_damage_modifier("artillery-shell")
        game.forces.player.set_ammo_damage_modifier("artillery-shell", e_old + 0.1)
        game.print({'amap.buy_arty_over', player.name, this.arty * 0.1 + 1})
    end

    if offer_index == 4 then
        this.urgrad_mine = this.urgrad_mine + 1
        this.max_mine = 400 + this.urgrad_mine * 200
        game.print({'amap.urgrad_mine_over', player.name, this.max_mine})
    end

    market.force.play_sound({
        path = 'utility/new_objective',
        volume_modifier = 0.75
    })
    market.clear_market_items()
    urgrade_item(market)
    for k, item in pairs(market_items) do
        market.add_market_item(item)
    end

    if offer_index == 5 then
        this.max_nest_number = this.max_nest_number + 1
        game.print({'amap.buy_biter_nest', player.name, this.max_nest_number})
    end

    if offer_index == 6 then
        this.max_worm_number = this.max_worm_number + 1
        game.print({'amap.buy_biter_worm', player.name, this.max_worm_number})
    end

    if offer_index == 7 then
        if not this.tianfu_buy_count or type(this.tianfu_buy_count) ~= 'table' then
            this.tianfu_buy_count = {}
        end
        if not this.tianfu_buy_count[player.index] then
            this.tianfu_buy_count[player.index] = 0
        end
        
        if this.tianfu_buy_count[player.index] >= 25 then
            player.insert({name = 'coin', count = 65000})
            player.print({'amap.tianfu_limit_reached', player.name})
            return
        end
        
        tianfu.get_new_tianfu(player)
        this.tianfu_count[player.index] = this.tianfu_count[player.index] - 1
        this.tianfu_buy_count[player.index] = this.tianfu_buy_count[player.index] + 1
        game.print(player.name .. '购买了1个天赋（已购买' .. this.tianfu_buy_count[player.index] .. '次）')
    end

    if offer_index == 8 then
       this.protectors_value=this.protectors_value+1
        game.print({'amap.protectors_value_over',player.name,1000,this.protectors_value*10})
    end

    if offer_index == 9 then
        Dungeon.show_difficulty_selection_gui(player)
    end

    market.force.play_sound({
        path = 'utility/new_objective',
        volume_modifier = 0.75
    })
    market.clear_market_items()
    urgrade_item(market)
    for k, item in pairs(market_items) do
        market.add_market_item(item)
    end

    market.force.play_sound({
        path = 'utility/new_objective',
        volume_modifier = 0.75
    })

    Public.refresh_shop(market)
end

Event.add(defines.events.on_rocket_launched, on_rocket_launched)
Event.add(defines.events.on_market_item_purchased, on_market_item_purchased)


local function on_research_finished(event)
    local this = WPT.get()
    if this.shop and this.shop.valid then
        Public.refresh_shop(this.shop)
    end
end
Event.add(defines.events.on_research_finished, on_research_finished)
return Public
