local util = require("util")

--首次创建角色时的初始物品（含100金币）
local function created_items()
  return {
    ["iron-plate"] = 8,
    ["pistol"] = 1,
    ["firearm-magazine"] = 10,
    ["burner-mining-drill"] = 1,
    ["stone-furnace"] = 1,
    ["coin"] = 100
  }
end

--市场方法
local function create_market(surface, locx, locy)
  local market = surface.create_entity{
    name = "market",
    position = {x = locx, y = locy},
    force = "player",
    create_build_effect_smoke = false
  }
  if not market then return end
  --不可拆除，不可摧毁
  market.destructible = false
  market.minable = false

  --添加模块装甲
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "modular-armor", count = 1}
  }
  --添加能量装甲
  market.add_market_item{
    price = {{name = "coin", count = 3}},
    offer = {type = "give-item", item = "power-armor", count = 1}
  }
  --添加K2装甲
  market.add_market_item{
    price = {{name = "coin", count = 20}},
    offer = {type = "give-item", item = "power-armor-mk2", count = 1}
  }
  --添加太阳能模块
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "solar-panel-equipment", count = 10}
  }
  --添加裂变电
  market.add_market_item{
    price = {{name = "coin", count = 10}},
    offer = {type = "give-item", item = "fission-reactor-equipment", count = 1}
  }
  --添加K1电池
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "battery-equipment", count = 1}
  }
  --添加K2电池
  market.add_market_item{
    price = {{name = "coin", count = 8}},
    offer = {type = "give-item", item = "battery-mk2-equipment", count = 1}
  }
  --添加建设机器人
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "construction-robot", count = 2}
  }
  --添加mk1机器人背包
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "personal-roboport-equipment", count = 1}
  }
  --添加mk2机器人背包
  market.add_market_item{
    price = {{name = "coin", count = 20}},
    offer = {type = "give-item", item = "personal-roboport-mk2-equipment", count = 1}
  }
  --添加腿
  market.add_market_item{
    price = {{name = "coin", count = 3}},
    offer = {type = "give-item", item = "exoskeleton-equipment", count = 1}
  }
  --添加锚定模块
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "belt-immunity-equipment", count = 1}
  }
  --添加夜视模块
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "night-vision-equipment", count = 1}
  }
  --添加mk1护盾模块
  market.add_market_item{
    price = {{name = "coin", count = 1}},
    offer = {type = "give-item", item = "energy-shield-equipment", count = 1}
  }
  --添加mk2护盾模块
  market.add_market_item{
    price = {{name = "coin", count = 5}},
    offer = {type = "give-item", item = "energy-shield-mk2-equipment", count = 1}
  }
  --添加激光模块
  market.add_market_item{
    price = {{name = "coin", count = 10}},
    offer = {type = "give-item", item = "personal-laser-defense-equipment", count = 1}
  }
  --添加占位
  for i = 1, 4 do
    market.add_market_item{
      price = {{name = "no-item", count = 1}},
      offer = {type = "give-item", item = "no-item", count = 1}
    }
  end

  -- 太空模组关闭 并且 品质模组开启时执行（原版带品质专用代码）
  if not script.active_mods["space-age"] and script.active_mods["quality"] then
    market.add_market_item{
      price = {{name = "coin", count = 200}},
      offer = {type = "give-item", item = "power-armor-mk2", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 10}},
      offer = {type = "give-item", item = "solar-panel-equipment", quality = "legendary", count = 10}
    }
    market.add_market_item{
      price = {{name = "coin", count = 100}},
      offer = {type = "give-item", item = "fission-reactor-equipment", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 80}},
      offer = {type = "give-item", item = "battery-mk2-equipment", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 60}},
      offer = {type = "give-item", item = "personal-roboport-mk2-equipment", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 15}},
      offer = {type = "give-item", item = "exoskeleton-equipment", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 5}},
      offer = {type = "give-item", item = "energy-shield-equipment", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 15}},
      offer = {type = "give-item", item = "energy-shield-mk2-equipment", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 25}},
      offer = {type = "give-item", item = "personal-laser-defense-equipment", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 20}},
      offer = {type = "give-item", item = "artillery-turret", quality = "legendary", count = 1}
    }
    market.add_market_item{
      price = {{name = "coin", count = 20}},
      offer = {type = "give-item", item = "artillery-wagon", quality = "legendary", count = 1}
    }
    for i = 1, 9 do
      market.add_market_item{
        price = {{name = "no-item", count = 1}},
        offer = {type = "give-item", item = "no-item", count = 1}
      }
    end
  end

  --太空时代专用代码
  if script.active_mods["space-age"] then
    --添加工具腰带
    market.add_market_item{
      price = {{name = "coin", count = 5}},
      offer = {type = "give-item", item = "toolbelt-equipment", count = 1}
    }
    --添加K3装甲
    market.add_market_item{
      price = {{name = "coin", count = 100}},
      offer = {type = "give-item", item = "mech-armor", count = 1}
    }
    --添加聚变电
    market.add_market_item{
      price = {{name = "coin", count = 50}},
      offer = {type = "give-item", item = "fusion-reactor-equipment", count = 1}
    }
    --添加K3电池
    market.add_market_item{
      price = {{name = "coin", count = 30}},
      offer = {type = "give-item", item = "battery-mk3-equipment", count = 1}
    }
    --添加传说K3装甲
    market.add_market_item{
      price = {{name = "coin", count = 500}},
      offer = {type = "give-item", item = "mech-armor", quality = "legendary", count = 1}
    }
    --添加传说聚变电
    market.add_market_item{
      price = {{name = "coin", count = 250}},
      offer = {type = "give-item", item = "fusion-reactor-equipment", quality = "legendary", count = 1}
    }
    --添加传K3电池
    market.add_market_item{
      price = {{name = "coin", count = 150}},
      offer = {type = "give-item", item = "battery-mk3-equipment", quality = "legendary", count = 1}
    }
    --添加虫巢
    market.add_market_item{
      price = {{name = "coin", count = 100}},
      offer = {type = "give-item", item = "captive-biter-spawner", count = 1}
    }
    --添加虫卵
    market.add_market_item{
      price = {{name = "coin", count = 5}},
      offer = {type = "give-item", item = "pentapod-egg", count = 1}
    }
    --添加占位
    market.add_market_item{
      price = {{name = "no-item", count = 1}},
      offer = {type = "give-item", item = "no-item", count = 1}
    }
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

-- 各星球配置：建市场位置 / 是否永昼 / 提示语
local surface_configs = {
  nauvis   = {x = 5,   y = 5,  always_day = true,  msg = "母星开启永昼"},
  vulcanus = {x = 5,   y = 5,  always_day = true,  msg = "火星开启永昼"},
  gleba    = {x = 5,   y = 5,  always_day = true,  msg = "草星开启永昼"},
  fulgora  = {x = 5,   y = 5,  always_day = false, msg = "雷星未开启永昼"},
  aquilo   = {x = 120, y = 80, always_day = true,  msg = "冰星开启永昼"},
}

-- 遍历所有已存在的星球，补建尚未创建的市场（用 storage 防止重复）
local function setup_all_surfaces()
  storage.market_surfaces = storage.market_surfaces or {}
  for name, cfg in pairs(surface_configs) do
    if not storage.market_surfaces[name] then
      local surface = game.surfaces[name]
      if surface then
        create_market(surface, cfg.x, cfg.y)
        if cfg.always_day then surface.always_day = true end
        game.print(cfg.msg)
        storage.market_surfaces[name] = true
      end
    end
  end
end

--监听表面创建事件（太空时代星球首次生成时）--
script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.get_surface(event.surface_index)
  local cfg = surface_configs[surface.name]
  if not cfg then return end
  storage.market_surfaces = storage.market_surfaces or {}
  if storage.market_surfaces[surface.name] then return end
  create_market(surface, cfg.x, cfg.y)
  if cfg.always_day then surface.always_day = true end
  game.print(cfg.msg)
  storage.market_surfaces[surface.name] = true
end)

-- 金币发放事件用来配合市场消费
script.on_nth_tick(3600, function()
  --1分钟发放一个coin
  for _, player in pairs(game.connected_players) do
    player.insert{name = "coin", count = 1}
  end
end)

-- 首次加入赠送100金币（新玩家）
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  storage.gifted_players = storage.gifted_players or {}
  if storage.gifted_players[player.name] then return end
  storage.gifted_players[player.name] = true
  util.insert_safe(player, storage.created_items)
  player.print("[color=red]<服务器>" .. player.name .. "首次加入本局游戏赠送100金币，之后每分钟赠送1金币[/color]")
end)

local freeplay = {}

freeplay.events = {}

-- 新游戏
freeplay.on_init = function()
  storage.created_items = created_items()
  setup_all_surfaces()
end

-- 老存档加载或脚本更新时：补建市场 + 给所有已在存档里的玩家发一次金币
freeplay.on_configuration_changed = function()
  storage.created_items = created_items()  -- 强制覆盖，确保包含金币
  storage.gifted_players = storage.gifted_players or {}
  storage.coin_gifted = storage.coin_gifted or {}
  setup_all_surfaces()
  for _, player in pairs(game.players) do
    if not storage.gifted_players[player.name] then
      storage.gifted_players[player.name] = true
      util.insert_safe(player, storage.created_items)
      game.print("[color=red]<服务器>" .. player.name .. "首次加入本局游戏赠送100金币，之后每分钟赠送1金币[/color]")
    elseif not storage.coin_gifted[player.name] then
      -- 已送过其他物品但漏了金币（旧版 bug 补救）
      storage.coin_gifted[player.name] = true
      player.insert{name = "coin", count = 100}
      game.print("[color=red]<服务器>补发 " .. player.name .. " 100金币[/color]")
    end
  end
end

return freeplay
