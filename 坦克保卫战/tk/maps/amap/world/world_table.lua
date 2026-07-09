local Global = require 'utils.global'
local Event = require 'utils.event'

local this = {}
local Public = {}

Global.register(
    this,
    function(tbl)
        this = tbl
    end
)

function Public.reset_table()
  -- 世界时间配置（单位：游戏刻，60刻=1秒）
  this.world_time = {
    [1] = 60 * 60 * 50,  -- 世界1：40小时
    [2] = 60 * 60 * 40,  -- 世界2：30小时
    [3] = 60 * 60 * 40,  -- 世界3：40小时
    [6] = 60 * 60 * 15,   -- 世界6：5小时（特殊快节奏）
    [7] = 60 * 60 * 45,  -- 世界7：35小时
    [8] = 60 * 60 * 45,  -- 世界8：35小时
    [9] = 60 * 60 * 45,  -- 世界9：35小时
    [10] = 60 * 60 * 40,  -- 世界10：25小时
    [11] = 60 * 60 * 50,  -- 世界11：40小时
    [12] = 60 * 60 * 10   -- 世界12：10小时
  }

  -- 地表生成配置
  this.surface_configs = {
    -- 洞穴世界 - 高资源频率，丰富矿产
    cave = {
      ["water"] = {frequency = "0.1", size = "0.1", richness = "0.1"},
      ["coal"] = {frequency = "2", size = "1", richness = "0.7"},
      ["stone"] = {frequency = "2", size = "1", richness = "0.7"},
      ["copper-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["iron-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["uranium-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["crude-oil"] = {frequency = "3", size = "2", richness = "1.2"},
      ["trees"] = {frequency = "1", size = "0.7", richness = "0.7"},
      ["enemy-base"] = {frequency = "3", size = "2", richness = "1"}
    },
    -- 四分之一资源 - 标准资源分布
    quarter = {
       ["water"] = {frequency = "0.1", size = "0.1", richness = "0.1"},
      ["coal"] = {frequency = "1", size = "1", richness = "0.7"},
      ["stone"] = {frequency = "1", size = "1", richness = "0.7"},
      ["copper-ore"] = {frequency = "1", size = "2", richness = "0.7"},
      ["iron-ore"] = {frequency = "1", size = "2", richness = "0.7"},
      ["uranium-ore"] = {frequency = "1.4", size = "2", richness = "1"},
      ["crude-oil"] = {frequency = "2", size = "2", richness = "1.2"},
      ["trees"] = {frequency = "1", size = "0.7", richness = "0.7"},
      ["enemy-base"] = {frequency = "3", size = "2", richness = "1"}
    },
    -- 水世界 - 高水资源，无自然资源
    water = {
       ["water"] = {frequency = "0.1", size = "0.1", richness = "0.1"},
        ["coal"] = {frequency = "1", size = "2", richness = "1.5"},
      ["stone"] =  {frequency = "1", size = "2", richness = "1.5"},
      ["copper-ore"] =  {frequency = "1", size = "2", richness = "1.5"},
      ["iron-ore"] =  {frequency = "1", size = "2", richness = "1.5"},
      ["uranium-ore"] = {frequency = "1", size = "2", richness = "1.5"},
      ["crude-oil"] =  {frequency = "1", size = "2", richness = "1.5"},
      ["trees"] = {frequency = "1", size = "0.7", richness = "0.7"},
      ["enemy-base"] = {frequency = "3", size = "2", richness = "1"}
    },
    -- 自由游戏 - 标准配置
    freeplay = {
      ["coal"] = {frequency = "1", size = "1", richness = "1"},
      ["stone"] = {frequency = "1", size = "1", richness = "1"},
      ["copper-ore"] = {frequency = "1", size = "1", richness = "1"},
      ["iron-ore"] = {frequency = "1", size = "1", richness = "1"},
      ["uranium-ore"] = {frequency = "1", size = "1", richness = "1"},
      ["crude-oil"] = {frequency = "1", size = "1", richness = "1"},
      ["trees"] = {frequency = "1", size = "1", richness = "1"},
      ["enemy-base"] = {frequency = "3", size = "3", richness = "2"}
    },
    -- 全树木 - 高树木密度
    all_tree = {
      ["coal"] = {frequency = "2", size = "1", richness = "1"},
      ["stone"] = {frequency = "2", size = "1", richness = "1"},
      ["copper-ore"] = {frequency = "2", size = "2", richness = "1"},
      ["iron-ore"] = {frequency = "2", size = "2", richness = "1"},
      ["uranium-ore"] = {frequency = "2", size = "2", richness = "1"},
      ["crude-oil"] = {frequency = "3", size = "2", richness = "1.2"},
      ["trees"] = {frequency = "3", size = "4", richness = "0.7"},
      ["enemy-base"] = {frequency = "3", size = "1.5", richness = "1.5"}
    },
    -- 全虫子 - 极高敌人密度
    all_biter = {
      ["coal"] = {frequency = "10", size = "10", richness = "5"},
      ["stone"] = {frequency = "10", size = "10", richness = "5"},
      ["copper-ore"] = {frequency = "10", size = "10", richness = "5"},
      ["iron-ore"] = {frequency = "10", size = "10", richness = "5"},
      ["uranium-ore"] = {frequency = "10", size = "10", richness = "5"},
      ["crude-oil"] = {frequency = "10", size = "10", richness = "5"},
      ["trees"] = {frequency = "1", size = "1", richness = "1"},
      ["enemy-base"] = {frequency = "10", size = "10", richness = "2"}
    },
    -- 竞技场 - 极高资源密度
    jjc = {
      ["coal"] = {frequency = "10", size = "10", richness = "5"},
      ["stone"] = {frequency = "10", size = "10", richness = "5"},
      ["copper-ore"] = {frequency = "10", size = "10", richness = "5"},
      ["iron-ore"] = {frequency = "10", size = "10", richness = "5"},
      ["uranium-ore"] = {frequency = "10", size = "10", richness = "5"},
      ["crude-oil"] = {frequency = "10", size = "10", richness = "5"},
      ["trees"] = {frequency = "1", size = "1", richness = "1"},
      ["enemy-base"] = {frequency = "10", size = "3", richness = "2"}
    },
    -- 混合矿石 - 标准混合配置
    mix_ore = {
      ["coal"] = {frequency = "2", size = "1", richness = "0.7"},
      ["stone"] = {frequency = "2", size = "1", richness = "0.7"},
      ["copper-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["iron-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["uranium-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["crude-oil"] = {frequency = "3", size = "2", richness = "1.2"},
      ["trees"] = {frequency = "1", size = "0.7", richness = "0.7"},
      ["enemy-base"] = {frequency = "3", size = "2", richness = "1"}
    },
    -- 无矿石 - 无资源生成
    no_ore = {
      ["coal"] = {frequency = "0", size = "0", richness = "0"},
      ["stone"] = {frequency = "0", size = "0", richness = "0"},
      ["copper-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["iron-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["uranium-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["crude-oil"] = {frequency = "0", size = "0", richness = "0"},
      ["trees"] = {frequency = "2", size = "1", richness = "1"},
      ["enemy-base"] = {frequency = "5", size = "4", richness = "2"}
    },
    -- 铁路模式 - 高资源密度，无树木
    rail = {
      ["coal"] = {frequency = "2", size = "1", richness = "1"},
      ["stone"] = {frequency = "2", size = "1", richness = "1"},
      ["copper-ore"] = {frequency = "3", size = "2", richness = "1"},
      ["iron-ore"] = {frequency = "3", size = "2", richness = "1"},
      ["uranium-ore"] = {frequency = "2.8", size = "2", richness = "1"},
      ["crude-oil"] = {frequency = "4", size = "2", richness = "1.2"},
      ["trees"] = {frequency = "0", size = "0", richness = "0"},
      ["enemy-base"] = {frequency = "10", size = "4", richness = "1"}
    },
    -- 无矿石无虫子 - 安全但无资源
    no_ore_no_biter = {
       ["water"] = {frequency = "0.1", size = "0.1", richness = "0.1"},
      ["coal"] = {frequency = "0", size = "0", richness = "0"},
      ["stone"] = {frequency = "0", size = "0", richness = "0"},
      ["copper-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["iron-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["uranium-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["crude-oil"] = {frequency = "0", size = "0", richness = "0"},
      ["trees"] = {frequency = "2", size = "1", richness = "1"},
      ["enemy-base"] = {frequency = "2", size = "2", richness = "0"}
    },
    -- 有矿石无虫子 - 安全有资源
    have_ore_no_biter = {
       ["water"] = {frequency = "0.1", size = "0.1", richness = "0.1"},
      ["coal"] = {frequency = "1.5", size = "1.5", richness = "1.5"},
      ["stone"] = {frequency = "1", size = "1", richness = "1.5"},
      ["copper-ore"] = {frequency = "1.5", size = "2", richness = "1.5"},
      ["iron-ore"] = {frequency = "1.5", size = "2", richness = "1.5"},
      ["uranium-ore"] = {frequency = "1", size = "1", richness = "1.8"},
      ["crude-oil"] = {frequency = "1", size = "1", richness = "1.5"},
      ["trees"] = {frequency = "1", size = "1", richness = "1"},
      ["enemy-base"] = {frequency = "0", size = "0", richness = "0"}
    },
    -- 螺旋世界 - 蚊香圈地形
    spiral = {
      ["coal"] = {frequency = "1.2", size = "1.2", richness = "1.2"},
      ["stone"] = {frequency = "1", size = "1", richness = "1.2"},
      ["copper-ore"] = {frequency = "1.2", size = "1.5", richness = "1.2"},
      ["iron-ore"] = {frequency = "1.2", size = "1.5", richness = "1.2"},
      ["uranium-ore"] = {frequency = "1", size = "1", richness = "1.5"},
      ["crude-oil"] = {frequency = "1.5", size = "1.5", richness = "1.5"},
      ["trees"] = {frequency = "0.8", size = "0.8", richness = "0.8"},
      ["enemy-base"] = {frequency = "2", size = "1.5", richness = "1"}
    },
    -- 机械城市 - 高科技防御型世界
    jixianchengshi = {
       ["water"] = {frequency = "0.1", size = "0.1", richness = "0.1"},
      ["coal"] = {frequency = "2", size = "1", richness = "0.7"},
      ["stone"] = {frequency = "2", size = "1", richness = "0.7"},
      ["copper-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["iron-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["uranium-ore"] = {frequency = "2", size = "2", richness = "0.7"},
      ["crude-oil"] = {frequency = "3", size = "2", richness = "1.2"},
      ["trees"] = {frequency = "1", size = "0.7", richness = "0.7"},
      ["enemy-base"] = {frequency = "0", size = "0", richness = "0"}
    },
    -- 背水一战 - 无矿只有树
    beishuiyizhan = {
       ["water"] = {frequency = "0.1", size = "0.1", richness = "0.1"},
      ["coal"] = {frequency = "0", size = "0", richness = "0"},
      ["stone"] = {frequency = "0", size = "0", richness = "0"},
      ["copper-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["iron-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["uranium-ore"] = {frequency = "0", size = "0", richness = "0"},
      ["crude-oil"] = {frequency = "0", size = "0", richness = "0"},
      ["trees"] = {frequency = "1", size = "0.7", richness = "0.7"},
      ["enemy-base"] = {frequency = "0", size = "0", richness = "0"}
    }
  }
  -- 世界与地表配置映射
  this.world_surface_mapping = {
    [1] = "cave",           -- 世界1：洞穴世界
    [2] = "quarter",        -- 世界2：四分之一资源
    [3] = "water",          -- 世界3：水世界
    [6] = "jjc",            -- 世界6：竞技场
    [7] = "have_ore_no_biter", -- 世界7：有矿石无虫子
    [8] = "no_ore",         -- 世界8：无矿石
    [9] = "no_ore_no_biter", -- 世界9：无矿石无虫子
    [10] = "have_ore_no_biter", -- 世界10：有矿石无虫子
    [11] = "jixianchengshi",  -- 世界11：机械城市
    [12] = "beishuiyizhan"    -- 世界12：背水一战
  }

  -- 世界特定地图生成设置
  this.world_map_settings = {
    -- 世界2：无水世界
    [2] = {
      starting_area = 0.8
    },
    -- 世界3：配合世界2的设置
    [3] = {
      starting_area = 0.8
    },

    -- 世界6：竞技场，小地图
    [6] = {
      width = 1250,
      height = 1250,
      starting_area = 0.5
    },
    -- 世界7：无矿石无虫子，超小地图
    [7] = {
      width = 200,
      starting_area = 0.6
    },
    -- 世界8：无矿石世界，小地图
    [8] = {
      width = 700,
      height = 700,
      starting_area = 0.8
    },
    -- 世界9：无矿石无虫子，超小地图
    [9] = {
      width = 214,
      starting_area = 0.6
    },
    -- 世界11：机械城市
    [11] = {
      starting_area = 0.6
    },
    -- 世界12：背水一战
    [12] = {
      starting_area = 0.6
    }
  }

  -- Biter 生成规则配置
  -- k_value: 方向值，1=右下, 2=左下, 3=右上, 4=左上
  --   - 数字: 固定使用该方向
  --   - "silo_3_or_roll": 有silo时用3，否则用循环值
  --   - "silo_random_3_4_or_roll": 有silo时随机3或4，否则用循环值
  -- force_x_align: 是否强制x坐标对齐目标
  --   - true: 始终对齐
  --   - "random_1_3_silo": 1/3概率对齐（需要silo）
  -- transfer_pollution: 是否将污染转移到silo位置
  -- boundary_limit: 边界限制值
  -- boundary_action: 边界处理动作，"reset_to_target"=重置为目标位置
  this.biter_spawn_rules = {
    -- 世界7：无矿石无虫子，超小地图，固定使用k=2（左下方向），强制x对齐，污染转移
    [7] = {
      k_value = 2,
      force_x_align = true,
      transfer_pollution = true
    },
    -- 世界9：无矿石无虫子，超小地图，有silo时k=3，否则循环；强制x对齐
    [9] = {
      k_value = "silo_3_or_roll",
      force_x_align = true
    },
    -- 世界10：有矿石无虫子，有silo时随机k=3或4，否则循环；1/3概率强制x对齐
    [10] = {
      k_value = "silo_random_3_4_or_roll",
      force_x_align = "random_1_3_silo"
    },
    -- 世界11：机械城市，有silo时k=3，否则循环；强制x对齐
    [11] = {
      k_value = "silo_3_or_roll",
      force_x_align = true
    },
    -- 世界12：背水一战，有silo时k=3，否则循环；强制x对齐
    [12] = {
      k_value = "silo_3_or_roll",
      force_x_align = true
    },
    -- 世界8：无矿石世界，小地图，边界处理，超出边界时重置为目标位置
    [8] = {
      boundary_limit = 300,
      boundary_action = "reset_to_target"
    }
  }
end

function Public.get(key)
  if key then
    return this[key]
  else
    return this
  end
end

function Public.set(key, value)
  if key and (value or value == false) then
    this[key] = value
    return this[key]
  elseif key then
    return this[key]
  else
    return this
  end
end

local on_init = function()
  Public.reset_table()
end

Event.on_init(on_init)

return Public