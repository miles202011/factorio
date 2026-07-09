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
  market.destructible = false
  market.minable = false

  --添加模块装甲
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="modular-armor",count=1}}
  --添加能量装甲
  market.add_market_item{price={{name="coin",count=3}},  offer={type="give-item",item="power-armor",count=1}}
  --添加K2装甲
  market.add_market_item{price={{name="coin",count=20}}, offer={type="give-item",item="power-armor-mk2",count=1}}
  --添加太阳能模块
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="solar-panel-equipment",count=10}}
  --添加裂变电
  market.add_market_item{price={{name="coin",count=10}}, offer={type="give-item",item="fission-reactor-equipment",count=1}}
  --添加K1电池
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="battery-equipment",count=1}}
  --添加K2电池
  market.add_market_item{price={{name="coin",count=8}},  offer={type="give-item",item="battery-mk2-equipment",count=1}}
  --添加建设机器人
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="construction-robot",count=2}}
  --添加mk1机器人背包
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="personal-roboport-equipment",count=1}}
  --添加mk2机器人背包
  market.add_market_item{price={{name="coin",count=20}}, offer={type="give-item",item="personal-roboport-mk2-equipment",count=1}}
  --添加腿
  market.add_market_item{price={{name="coin",count=3}},  offer={type="give-item",item="exoskeleton-equipment",count=1}}
  --添加锚定模块
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="belt-immunity-equipment",count=1}}
  --添加夜视模块
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="night-vision-equipment",count=1}}
  --添加mk1护盾模块
  market.add_market_item{price={{name="coin",count=1}},  offer={type="give-item",item="energy-shield-equipment",count=1}}
  --添加mk2护盾模块
  market.add_market_item{price={{name="coin",count=5}},  offer={type="give-item",item="energy-shield-mk2-equipment",count=1}}
  --添加激光模块
  market.add_market_item{price={{name="coin",count=10}}, offer={type="give-item",item="personal-laser-defense-equipment",count=1}}
  for i = 1, 4 do
    market.add_market_item{price={{name="no-item",count=1}},offer={type="give-item",item="no-item",count=1}}
  end

  if not script.active_mods["space-age"] and script.active_mods["quality"] then
    market.add_market_item{price={{name="coin",count=200}},offer={type="give-item",item="power-armor-mk2",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=10}}, offer={type="give-item",item="solar-panel-equipment",quality="legendary",count=10}}
    market.add_market_item{price={{name="coin",count=100}},offer={type="give-item",item="fission-reactor-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=80}}, offer={type="give-item",item="battery-mk2-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=60}}, offer={type="give-item",item="personal-roboport-mk2-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=15}}, offer={type="give-item",item="exoskeleton-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=5}},  offer={type="give-item",item="energy-shield-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=15}}, offer={type="give-item",item="energy-shield-mk2-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=25}}, offer={type="give-item",item="personal-laser-defense-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=20}}, offer={type="give-item",item="artillery-turret",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=20}}, offer={type="give-item",item="artillery-wagon",quality="legendary",count=1}}
    for i = 1, 9 do
      market.add_market_item{price={{name="no-item",count=1}},offer={type="give-item",item="no-item",count=1}}
    end
  end

  if script.active_mods["space-age"] then
    market.add_market_item{price={{name="coin",count=5}},   offer={type="give-item",item="toolbelt-equipment",count=1}}
    market.add_market_item{price={{name="coin",count=100}}, offer={type="give-item",item="mech-armor",count=1}}
    market.add_market_item{price={{name="coin",count=50}},  offer={type="give-item",item="fusion-reactor-equipment",count=1}}
    market.add_market_item{price={{name="coin",count=30}},  offer={type="give-item",item="battery-mk3-equipment",count=1}}
    market.add_market_item{price={{name="coin",count=500}}, offer={type="give-item",item="mech-armor",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=250}}, offer={type="give-item",item="fusion-reactor-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=150}}, offer={type="give-item",item="battery-mk3-equipment",quality="legendary",count=1}}
    market.add_market_item{price={{name="coin",count=100}}, offer={type="give-item",item="captive-biter-spawner",count=1}}
    market.add_market_item{price={{name="coin",count=5}},   offer={type="give-item",item="pentapod-egg",count=1}}
    market.add_market_item{price={{name="no-item",count=1}},offer={type="give-item",item="no-item",count=1}}
  end

  rendering.draw_sprite{sprite="item/coin",target=market,surface=surface,x_scale=1.5,y_scale=1.5}
end

local surface_configs = {
  nauvis   = {x=5,   y=5,  always_day=true,  msg="母星开启永昼"},
  vulcanus = {x=5,   y=5,  always_day=true,  msg="火星开启永昼"},
  gleba    = {x=5,   y=5,  always_day=true,  msg="草星开启永昼"},
  fulgora  = {x=5,   y=5,  always_day=false, msg="雷星未开启永昼"},
  aquilo   = {x=120, y=80, always_day=true,  msg="冰星开启永昼"},
}

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

script.on_nth_tick(3600, function()
  for _, player in pairs(game.connected_players) do
    player.insert{name = "coin", count = 1}
  end
end)

-- 问题：on_player_joined_game 直接注册，但实际未被触发
-- （event_handler 加载后可能覆盖了直接注册的事件）
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

freeplay.on_init = function()
  storage.created_items = created_items()
  setup_all_surfaces()
end

freeplay.on_configuration_changed = function()
  storage.created_items = storage.created_items or created_items()
  setup_all_surfaces()
end

return freeplay
