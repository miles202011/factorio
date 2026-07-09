local Global = require 'utils.global'
local surface_name = 'amap'
local Reset = require 'maps.amap.soft_reset'
local diff=require 'maps.amap.diff'
local Event = require 'utils.event'
local WorldTable = require 'maps.amap.world.world_table'
local Public = {}

local this = {
    active_surface_index = nil,
    surface_name = surface_name,
}

Global.register(
    this,
    function(tbl)
        this = tbl
    end
)

local starting_items = {
  ['submachine-gun'] = 1,
  ['firearm-magazine'] = 30,
  ['wood'] = 16,
  ['car']=1,
}


function Public.create_yiciyuan_surface()
   local map_gen_settings
  if script.active_mods["space-age"] then
    map_gen_settings = game.planets["nauvis"].prototype.map_gen_settings    
  end
        map_gen_settings['seed'] = math.random(10000, 99999)
        map_gen_settings['starting_area'] = 1
        map_gen_settings['default_enable_all'] = true
        map_gen_settings['water'] = 1


  local no_biter={
    ["coal"] = {frequency = "1", size = "1", richness = "1"},
    ["stone"] = {frequency = "1", size = "1", richness = "1"},
    ["copper-ore"] = {frequency = "1", size = "1",richness = "1"},
    ["iron-ore"] = {frequency ="1", size = "1", richness = "1"},
    ["uranium-ore"] = {frequency ="1", size = "1", richness = "1"},
    ["crude-oil"] = {frequency = "1", size = "1", richness = "1"},
    ["trees"] = {frequency = "1", size = "1", richness = "1"},
    ["enemy-base"] = {frequency = "0", size = "0", richness = "0"},
}

 
map_gen_settings.autoplace_controls =no_biter

if not this.yiciyuan_count then
  this.yiciyuan_count = 0
end
if not this.old_name then
  this.old_name = 'yiciyuan'
end
this.yiciyuan_count = this.yiciyuan_count + 1

local new_surface = game.create_surface(this.old_name .. '_' .. tostring(this.yiciyuan_count), map_gen_settings)

 return new_surface
end
 
 
function Public.create_surface()
  local map=diff.get()
  local surface_configs = WorldTable.get('surface_configs')
  local world_mapping = WorldTable.get('world_surface_mapping')
  local world_map_settings = WorldTable.get('world_map_settings')
  local map_gen_settings={}
  --检测是否加载了太空时代mod 

   if script.active_mods["space-age"] then
   map_gen_settings = game.planets["nauvis"].prototype.map_gen_settings
  end
        map_gen_settings['seed'] = math.random(1, 4294967295)
        map_gen_settings['starting_area'] = 1.4
        map_gen_settings['default_enable_all'] = true
        map_gen_settings['water'] = 0.4
        

    -- 应用世界特定的地图生成设置
    if world_map_settings[map.world] then
      local settings = world_map_settings[map.world]
      for key, value in pairs(settings) do
        map_gen_settings[key] = value
      end
    end
     
 
	-- 从world_table获取对应世界的地表配置
	local world_config_name = world_mapping[map.world]
	if world_config_name and surface_configs[world_config_name] then
		map_gen_settings.autoplace_controls = surface_configs[world_config_name]
	else
		-- 如果找不到配置，使用默认配置
		map_gen_settings.autoplace_controls = surface_configs.cave
	end

    
  this.active_surface_index = Reset.soft_reset_map(game.surfaces['nauvis'], map_gen_settings, starting_items).index

    return this.active_surface_index
end

function Public.get_active_surface()
    return this.active_surface
end

function Public.get_surface_name()
    return this.surface_name
end

function Public.get(key)
    if key then
        return this[key]
    else
        return this
    end
end

return Public
