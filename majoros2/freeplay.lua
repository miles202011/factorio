--[[
majoro服务器场景20251030
]]--
local util = require("util")
local crash_site = require("crash-site")
--市场方法
local function create_market(surface,locx,locy)
  --定义创建位置
  local market_position = {x = locx, y = locy}
  --创建市场实体y
  local market = surface.create_entity{
    name = "market",
    position = market_position,
    force = "player",
    create_build_effect_smoke = false
  }
  if not market then return end
  --调整市场属性，不可拆除，不可摧毁
  market.destructible = false
  market.minable = false
  --添加物品清单....不知道lua怎么做二维数组只能用笨办法了
  --添加模块装甲
  market.add_market_item{
    price = {
      {name = "coin", count = 1}  
    },
        offer = {
            type = "give-item",
            item = "modular-armor",
            count = 1
        }
    }
  	--添加能量装甲
    market.add_market_item{
        price = {
            {name = "coin", count = 3}  
        },
        offer = {
            type = "give-item",
            item = "power-armor",
            count = 1
        }
    }
	  --添加K2装甲
    market.add_market_item{
        price = {
            {name = "coin", count = 20}  
        },
        offer = {
            type = "give-item",
            item = "power-armor-mk2",
            count = 1
        }
    }
	  --添加太阳能模块
    market.add_market_item{
        price = {
            {name = "coin", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "solar-panel-equipment",
            count = 10
        }
    }
	  --添加裂变电
    market.add_market_item{
        price = {
            {name = "coin", count = 10}  
        },
        offer = {
            type = "give-item",
            item = "fission-reactor-equipment",
            count = 1
        }
    }
	  --添加K1电池
    market.add_market_item{
        price = {
            {name = "coin", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "battery-equipment",
            count = 1
        }
    }
	  --添加K2电池
    market.add_market_item{
        price = {
            {name = "coin", count = 8}  
        },
        offer = {
            type = "give-item",
            item = "battery-mk2-equipment",
            count = 1
        }
    }
	  --添加建设机器人
    market.add_market_item{
        price = {
            {name = "coin", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "construction-robot",
            count = 2
        }
    }
	--添加mk1机器人背包
    market.add_market_item{
        price = {
            {name = "coin", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "personal-roboport-equipment",
            count = 1
        }
    }
	  --添加mk2机器人背包
    market.add_market_item{
        price = {
            {name = "coin", count = 20}  
        },
        offer = {
            type = "give-item",
            item = "personal-roboport-mk2-equipment",
            count = 1
        }
    }
	  --添加腿
    market.add_market_item{
        price = {
            {name = "coin", count = 3}  
        },
        offer = {
            type = "give-item",
            item = "exoskeleton-equipment",
            count = 1
        }
    }
	  --添加锚定模块
    market.add_market_item{
        price = {
            {name = "coin", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "belt-immunity-equipment",
            count = 1
        }
    }
	  --添加夜视模块
    market.add_market_item{
        price = {
            {name = "coin", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "night-vision-equipment",
            count = 1
        }
    }
	  --添加mk1护盾模块
    market.add_market_item{
        price = {
            {name = "coin", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "energy-shield-equipment",
            count = 1
        }
    }
	  --添加mk2护盾模块
    market.add_market_item{
        price = {
            {name = "coin", count = 5}  
        },
        offer = {
            type = "give-item",
            item = "energy-shield-mk2-equipment",
            count = 1
        }
    }
   --添加激光模块
    market.add_market_item{
        price = {
            {name = "coin", count = 10}  
        },
        offer = {
            type = "give-item",
            item = "personal-laser-defense-equipment",
            count = 1
        }
    }
    --添加占位
    for i = 1, 4 do
      market.add_market_item{
        price = {
            {name = "no-item", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "no-item",
            count = 1
        }
      }
    end
  -- 太空模组关闭 并且 品质模组开启时执行（原版带品质专用代码）
  if not script.active_mods["space-age"] and script.active_mods["quality"] then
        --添加K2装甲
    market.add_market_item{
      price = {
          {name = "coin", count = 200}  
      },
      offer = {
          type = "give-item",
          item = "power-armor-mk2",
          quality = "legendary",
          count = 1
      }
  }
  --添加太阳能模块
  market.add_market_item{
      price = {
          {name = "coin", count = 10}  
      },
      offer = {
          type = "give-item",
          item = "solar-panel-equipment",
          quality = "legendary",
          count = 10
      }
  }
  --添加裂变电
  market.add_market_item{
      price = {
          {name = "coin", count = 100}  
      },
      offer = {
          type = "give-item",
          item = "fission-reactor-equipment",
          quality = "legendary",
          count = 1
      }
  }
  --添加K2电池
  market.add_market_item{
      price = {
          {name = "coin", count = 80}  
      },
      offer = {
          type = "give-item",
          item = "battery-mk2-equipment",
          quality = "legendary",
          count = 1
      }
  }
  --添加mk2机器人背包
  market.add_market_item{
      price = {
          {name = "coin", count = 60}  
      },
      offer = {
          type = "give-item",
          item = "personal-roboport-mk2-equipment",
          quality = "legendary",
          count = 1
      }
  }
  --添加腿
  market.add_market_item{
      price = {
          {name = "coin", count = 15}  
      },
      offer = {
          type = "give-item",
          item = "exoskeleton-equipment",
          quality = "legendary",
          count = 1
      }
  }
  --添加mk1护盾模块
  market.add_market_item{
      price = {
          {name = "coin", count = 5}  
      },
      offer = {
          type = "give-item",
          item = "energy-shield-equipment",
          quality = "legendary",
          count = 1
      }
  }
  --添加mk2护盾模块
  market.add_market_item{
      price = {
          {name = "coin", count = 15}  
      },
      offer = {
          type = "give-item",
          item = "energy-shield-mk2-equipment",
          quality = "legendary",
          count = 1
      }
  }
 --添加激光模块
  market.add_market_item{
      price = {
          {name = "coin", count = 25}  
      },
      offer = {
          type = "give-item",
          item = "personal-laser-defense-equipment",
          quality = "legendary",
          count = 1
      }
  }
  --添加重炮模块
  market.add_market_item{
    price = {
        {name = "coin", count = 20}  
    },
    offer = {
        type = "give-item",
        item = "artillery-turret",
        quality = "legendary",
        count = 1
    }
  }
  --添加重炮车厢模块
    market.add_market_item{
      price = {
          {name = "coin", count = 20}  
      },
      offer = {
          type = "give-item",
          item = "artillery-wagon",
          quality = "legendary",
          count = 1
      }
  }
  -- 添加占位
  for i = 1, 9 do
    market.add_market_item{
      price = {
          {name = "no-item", count = 1}  
      },
      offer = {
          type = "give-item",
          item = "no-item",
          count = 1
      }
    }
  end
  end


  --太空时代专用代码--包含工具腰带、K3甲、聚变电、K3电池（太空必须包含品质，所以判断一个就可以了）
  if script.active_mods['space-age'] then
    --添加工具腰带
		market.add_market_item{
			price = {
				{name = "coin", count = 5}  
			},
			offer = {
				type = "give-item",
				item = "toolbelt-equipment",
				count = 1
			}
		}
		--添加K3装甲
		market.add_market_item{
			price = {
				{name = "coin", count = 100}  
			},
			offer = {
				type = "give-item",
				item = "mech-armor",
				count = 1
			}
		}
		--添加聚变电
		market.add_market_item{
			price = {
				{name = "coin", count = 50}  
			},
			offer = {
				type = "give-item",
				item = "fusion-reactor-equipment",
				count = 1
			}
		}
		--添加K3电池
		market.add_market_item{
			price = {
				{name = "coin", count = 30}  
			},
			offer = {
				type = "give-item",
				item = "battery-mk3-equipment",
				count = 1
			}
		}
		--添加传说K3装甲
		market.add_market_item{
			price = {
				{name = "coin", count = 500}  
			},
			offer = {
				type = "give-item",
				item = "mech-armor",
				quality = "legendary",
				count = 1
			}
		}
		--添加传说聚变电
		market.add_market_item{
			price = {
				{name = "coin", count = 250}  
			},
			offer = {
				type = "give-item",
				item = "fusion-reactor-equipment",
				quality = "legendary",
				count = 1
			}
		}
		--添加传K3电池
		market.add_market_item{
			price = {
				{name = "coin", count = 150}  
			},
			offer = {
				type = "give-item",
				item = "battery-mk3-equipment",
				quality = "legendary",
				count = 1
			}
		}
    --添加虫巢
		market.add_market_item{
			price = {
				{name = "coin", count = 100}  
			},
			offer = {
				type = "give-item",
				item = "captive-biter-spawner",
				count = 1
			}
		}
    --添加虫卵
		market.add_market_item{
			price = {
				{name = "coin", count = 5}  
			},
			offer = {
				type = "give-item",
				item = "pentapod-egg",
				count = 1
			}
		}
    -- 添加占位
    for i = 1, 1 do
      market.add_market_item{
        price = {
            {name = "no-item", count = 1}  
        },
        offer = {
            type = "give-item",
            item = "no-item",
            count = 1
        }
      }
    end
	end
	--贴一个金币图标方便找
  rendering.draw_sprite{
    sprite = "item/coin",
    target = market,
    surface = surface,
    x_scale = 1.5,
    y_scale = 1.5
  }
end
--监听表面创建事件--
script.on_event(defines.events.on_surface_created, function(event)
    -- 从事件中获取地表索引，再通过索引获取表面对象
    local surface = game.get_surface(event.surface_index)
    --匹配表面是否为星球表面
    if surface.name == "vulcanus" then
      create_market(surface,5,5)
      surface.always_day=true
      game.print('火星开启永昼')
    end
    if surface.name == "gleba" then
      create_market(surface,5,5)
      surface.always_day=true
      game.print('草星开启永昼')
    end
    if surface.name == "fulgora" then
      create_market(surface,5,5)
      game.print('雷星未开启永昼')
    end
    if surface.name == "aquilo" then
      create_market(surface,120,80)
      surface.always_day=true
      game.print('冰星开启永昼')
    end
    if surface.name == "nauvis" then
      create_market(surface,5,5)
      surface.always_day=true
      game.print('母星开启永昼')
    end
end)
-- 金币发放事件用来配合市场消费
script.on_nth_tick(3600, function()
	--1分钟发放一个coin
    for _, player in pairs(game.connected_players) do
            player.insert{name = "coin", count = 1}
    end
end)


local created_items = function()
  return
  {
    ["iron-plate"] = 8,
    ["pistol"] = 1,
    ["firearm-magazine"] = 10,
    ["burner-mining-drill"] = 1,
    ["stone-furnace"] = 1,
    ["coin"] = 100
  }
end

local respawn_items = function()
  return
  {
    ["firearm-magazine"] = 10,
  }
end

local ship_items = function()
  return
  {
    ["firearm-magazine"] = 8
  }
end

local debris_items = function()
  return
  {
    ["iron-plate"] = 8
  }
end

local ship_parts = function()
  return crash_site.default_ship_parts()
end

local chart_starting_area = function()
  local r = storage.chart_distance or 200
  local force = game.forces.player
  local surface = game.surfaces[1]
  local origin = force.get_spawn_position(surface)
  force.chart(surface, {{origin.x - r, origin.y - r}, {origin.x + r, origin.y + r}})
end

local get_starting_message = function()
  if storage.custom_intro_message then
    return storage.custom_intro_message
  end
  if script.active_mods["space-age"] then
    return {"msg-intro-space-age"}
  end
  return {"msg-intro"}
end

local show_intro_message = function(player)
  if storage.skip_intro then return end

  if game.is_multiplayer() then
    player.print(get_starting_message())
  else
    game.show_message_dialog{text = get_starting_message()}
  end
end

local on_player_created = function(event)
  local player = game.get_player(event.player_index)
  util.insert_safe(player, storage.created_items)

  if not storage.init_ran then

    --This is so that other mods and scripts have a chance to do remote calls before we do things like charting the starting area, creating the crash site, etc.
    storage.init_ran = true

    chart_starting_area()

    if not storage.disable_crashsite then
      local surface = player.surface
      surface.daytime = 0.7
      crash_site.create_crash_site(surface, {-5,-6}, util.copy(storage.crashed_ship_items), util.copy(storage.crashed_debris_items), util.copy(storage.crashed_ship_parts))
      util.remove_safe(player, storage.crashed_ship_items)
      util.remove_safe(player, storage.crashed_debris_items)
      player.get_main_inventory().sort_and_merge()
      if player.character then
        player.character.destructible = false
      end
      storage.crash_site_cutscene_active = true
      crash_site.create_cutscene(player, {-5, -4})
      return
    end

  end

  show_intro_message(player)

end

local on_player_respawned = function(event)
  local player = game.get_player(event.player_index)
  util.insert_safe(player, storage.respawn_items)
end

local on_cutscene_waypoint_reached = function(event)
  if not storage.crash_site_cutscene_active then return end
  if not crash_site.is_crash_site_cutscene(event) then return end

  local player = game.get_player(event.player_index)

  player.exit_cutscene()
  show_intro_message(player)
end

local skip_crash_site_cutscene = function(event)
  if not storage.crash_site_cutscene_active then return end
  if event.player_index ~= 1 then return end
  local player = game.get_player(event.player_index)
  if player.controller_type == defines.controllers.cutscene then
    player.exit_cutscene()
  end
end

local on_cutscene_cancelled = function(event)
  if not storage.crash_site_cutscene_active then return end
  if event.player_index ~= 1 then return end
  storage.crash_site_cutscene_active = nil
  local player = game.get_player(event.player_index)
  if player.gui.screen.skip_cutscene_label then
    player.gui.screen.skip_cutscene_label.destroy()
  end
  if player.character then
    player.character.destructible = true
  end
  player.zoom = 1.5
end

local on_player_display_refresh = function(event)
  crash_site.on_player_display_refresh(event)
end

local freeplay_interface =
{
  get_created_items = function()
    return storage.created_items
  end,
  set_created_items = function(map)
    storage.created_items = map or error("Remote call parameter to freeplay set created items can't be nil.")
  end,
  get_respawn_items = function()
    return storage.respawn_items
  end,
  set_respawn_items = function(map)
    storage.respawn_items = map or error("Remote call parameter to freeplay set respawn items can't be nil.")
  end,
  set_skip_intro = function(bool)
    storage.skip_intro = bool
  end,
  get_skip_intro = function()
    return storage.skip_intro
  end,
  set_custom_intro_message = function(message)
    storage.custom_intro_message = message
  end,
  get_custom_intro_message = function()
    return storage.custom_intro_message
  end,
  set_chart_distance = function(value)
    storage.chart_distance = tonumber(value) or error("Remote call parameter to freeplay set chart distance must be a number")
  end,
  get_disable_crashsite = function()
    return storage.disable_crashsite
  end,
  set_disable_crashsite = function(bool)
    storage.disable_crashsite = bool
  end,
  get_init_ran = function()
    return storage.init_ran
  end,
  get_ship_items = function()
    return storage.crashed_ship_items
  end,
  set_ship_items = function(map)
    storage.crashed_ship_items = map or error("Remote call parameter to freeplay set created items can't be nil.")
  end,
  get_debris_items = function()
    return storage.crashed_debris_items
  end,
  set_debris_items = function(map)
    storage.crashed_debris_items = map or error("Remote call parameter to freeplay set respawn items can't be nil.")
  end,
  get_ship_parts = function()
    return storage.crashed_ship_parts
  end,
  set_ship_parts = function(parts)
    storage.crashed_ship_parts = parts or error("Remote call parameter to freeplay set ship parts can't be nil.")
  end
}

if not remote.interfaces["freeplay"] then
  remote.add_interface("freeplay", freeplay_interface)
end

local is_debug = function()
  local surface = game.surfaces.nauvis
  local map_gen_settings = surface.map_gen_settings
  return map_gen_settings.width == 50 and map_gen_settings.height == 50
end

local init_ending_info = function()
  local is_space_age = script.active_mods["space-age"]
  local info =
  {
    image_path = is_space_age and "victory-space-age.png" or "victory.png",
    title = {"gui-game-finished.victory"},
    message = is_space_age and {"victory-message-space-age"} or {"victory-message"},
    bullet_points =
    {
      {"victory-bullet-point-1"},
      {"victory-bullet-point-2"},
      {"victory-bullet-point-3"},
      {"victory-bullet-point-4"}
    },
    final_message = {"victory-final-message"},
  }
  game.set_win_ending_info(info)
end

local freeplay = {}

freeplay.events =
{
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_player_respawned] = on_player_respawned,
  [defines.events.on_cutscene_waypoint_reached] = on_cutscene_waypoint_reached,
  ["crash-site-skip-cutscene"] = skip_crash_site_cutscene,
  [defines.events.on_player_display_resolution_changed] = on_player_display_refresh,
  [defines.events.on_player_display_scale_changed] = on_player_display_refresh,
  [defines.events.on_cutscene_cancelled] = on_cutscene_cancelled
}

freeplay.on_configuration_changed = function()
  storage.created_items = storage.created_items or created_items()
  storage.respawn_items = storage.respawn_items or respawn_items()
  storage.crashed_ship_items = storage.crashed_ship_items or ship_items()
  storage.crashed_debris_items = storage.crashed_debris_items or debris_items()
  storage.crashed_ship_parts = storage.crashed_ship_parts or ship_parts()

  if not storage.init_ran then
    -- migrating old saves.
    storage.init_ran = #game.players > 0
  end
  init_ending_info()
end

--禁用科技
local function tech_disable()
  local disabled_techs = {}
  if script.active_mods['space-age'] then
    disabled_techs={
		"follower-robot-count-1",
		"follower-robot-count-2",
		"follower-robot-count-3",
		"follower-robot-count-4",
		"follower-robot-count-5",
    "artillery",
		"artillery-shell-damage-1",
		"artillery-shell-range-1",
    "artillery-shell-speed-1",
    "mech-armor",
		"fusion-reactor-equipment",
		"battery-mk3-equipment"
    }
  else
    disabled_techs={
		"follower-robot-count-1",
		"follower-robot-count-2",
		"follower-robot-count-3",
		"follower-robot-count-4",
		"follower-robot-count-5",
    }
  end
	local force = game.forces.player
  for _, tech_name in pairs(disabled_techs) do
    force.technologies[tech_name].enabled = false
    --force.technologies[tech_name].visible_when_disabled = true
  end
end

--游戏开始时的触发
freeplay.on_init = function()
  game.allow_tip_activation = true
  storage.created_items = created_items()
  storage.respawn_items = respawn_items()
  storage.crashed_ship_items = ship_items()
  storage.crashed_debris_items = debris_items()
  storage.crashed_ship_parts = ship_parts()
  
  tech_disable()
  local surface = game.surfaces.nauvis
  create_market(surface,5,5)  -- 在主表面生成市场
  surface.always_day=true
  game.print('母星开启永昼')
  game.forces.player.worker_robots_speed_modifier = 1.0--修改机器人移速
  game.forces.player.character_running_speed_modifier = 0.8--修改玩家移速
  game.forces.player.manual_crafting_speed_modifier = 4.0--修改玩家手搓速度
  
  
  if is_debug() then
    storage.skip_intro = true
    storage.disable_crashsite = true
  end

  init_ending_info()
end

return freeplay
