-- 必须是第一行：继承自由游戏的基础逻辑（玩家出生、重生等）
require('__base__/script/freeplay/control.lua')

-- ============================================================
-- 常量定义
-- ============================================================

-- 玩家在聊天中可以说的中文星球别名，映射到 Factorio 表面的内部名称。
-- 内部名称由游戏引擎使用，必须与 game.get_surface() 的参数一致。
-- 如需支持更多星球，在此添加新条目即可。
local SURFACE_ALIASES = {
    ["地星"] = "nauvis",    -- 起始星球，绿色草原
    ["雷星"] = "fulgora",   -- 闪电星球，Space Age DLC
    ["草星"] = "gleba",     -- 生物星球，Space Age DLC
    ["火星"] = "vulcanus",  -- 熔岩星球，Space Age DLC
    ["冰星"] = "aquilo",    -- 冰封星球，Space Age DLC
}

-- 自动将 SURFACE_ALIASES 反转，得到"内部名 → 中文别名"的查找表。
-- 别名即显示名，无需单独维护第二张表，新增星球只改 SURFACE_ALIASES 即可。
local SURFACE_DISPLAY = {}
for alias, name in pairs(SURFACE_ALIASES) do
    SURFACE_DISPLAY[name] = alias
end

-- 传送冷却时间。
-- Factorio 以 tick 计时，1 秒 = 60 tick（默认游戏速度）。
-- 10 分钟 = 10 * 60 秒 * 60 tick/秒 = 36000 tick。
local COOLDOWN_TICKS = 10 * 60 * 60

-- ============================================================
-- 工具函数
-- ============================================================

-- 确保 storage.teleport_cooldowns 表存在。
-- on_configuration_changed 会在 mod 版本变化、存档读取等情况下调用，
-- 此时 storage 可能缺少该键，需要补齐以避免后续 nil 索引报错。
local function ensure_storage()
    if not storage.teleport_cooldowns then
        storage.teleport_cooldowns = {}
    end
end

-- 返回表面的友好中文显示名称；若不在映射表中，直接返回内部名称。
local function display(surface_name)
    return SURFACE_DISPLAY[surface_name] or surface_name
end

-- 检查玩家是否满足传送的背包条件。
-- 规则与乘坐火箭离开星球相同：身无长物、弹药清空。
-- 返回值：ok(bool), reason(string|nil)
local function check_inventory(player)
    -- 坐在载具中时 player.teleport() 行为不可预期，禁止传送。
    if player.vehicle then
        return false, "请先离开载具再传送"
    end

    -- character_main：玩家主背包（工具栏 + 普通格子）
    local main = player.get_inventory(defines.inventory.character_main)
    if main and not main.is_empty() then
        return false, "背包中还有物品，请先清空背包"
    end

    -- character_ammo：武器下方的弹药格
    local ammo = player.get_inventory(defines.inventory.character_ammo)
    if ammo and not ammo.is_empty() then
        return false, "弹药栏中还有弹药，请先清空弹药栏"
    end
    local trash = player.get_inventory(defines.inventory.character_trash)
    if trash and not trash.is_empty() then
        return false, "物流回收栏中还有物品，请先清空"
    end

    return true, nil
end

-- 获取目标表面；若表面尚未生成（玩家从未踏足该星球），则先创建。
-- Space Age 星球的表面在玩家首次到达前不存在，game.get_surface 会返回 nil。
-- 此时必须通过 planet.create_surface() 创建，才能保留星球原型的地形生成配置。
-- 直接调用 game.create_surface(name) 只会产生无地形的空白表面（即之前的 bug）。
local function get_or_create_surface(name)
    local surface = game.get_surface(name)
    if surface then return surface end
    local planet = game.planets[name]
    if planet then return planet.create_surface() end
    -- 不是已知星球（如自定义表面名），退化为空白表面
    return game.create_surface(name)
end

-- 在目标表面 (0, 0) 附近寻找玩家可以安全站立的位置。
-- find_non_colliding_position 参数：
--   "character"  → 以玩家碰撞箱为基准
--   {0, 0}       → 搜索中心（地图原点，通常是星球出生点附近）
--   500          → 搜索半径（格）
--   1            → 步进精度（格），越小越精确但越慢
-- 若 500 格内完全没有可站立位置（极罕见），fallback 到原点强制落地。
local function find_safe_pos(surface)
    return surface.find_non_colliding_position("character", {0, 0}, 500, 1)
        or {x = 0, y = 0}
end

-- ============================================================
-- 核心传送逻辑
-- ============================================================

-- 执行对单个玩家的完整传送流程，按顺序检查所有前置条件。
-- target_name：目标表面的内部名称（如 "vulcanus"）
local function do_teleport(player, target_name)
    ensure_storage()

    -- 条件 1：目标不能是玩家当前所在的表面。
    -- player.surface.name 返回当前所在表面的内部名称。
    local char_surface = player.character and player.character.surface.name or player.surface.name
    if char_surface == target_name then
        player.print("[传送] 你已经在 " .. display(target_name) .. " 了！")
        return
    end

    -- 条件 2：冷却时间检查。
    -- storage.teleport_cooldowns[player.index] 存储该玩家上次传送时的 tick。
    -- player.index 是跨存档稳定的玩家唯一标识符。
    local now  = game.tick
    local last = storage.teleport_cooldowns[player.index] or 0
    local remaining = COOLDOWN_TICKS - (now - last)
    if last > 0 and remaining > 0 then
        -- 将剩余 tick 转换为"X 分 XX 秒"格式显示。
        local s   = math.ceil(remaining / 60)   -- 向上取整到秒
        local min = math.floor(s / 60)
        local sec = s % 60
        player.print(string.format("[传送] 冷却中，还需等待 %d 分 %02d 秒", min, sec))
        return
    end

    -- 条件 3：背包与弹药必须清空。
    local ok, reason = check_inventory(player)
    if not ok then
        player.print("[传送] 无法传送：" .. reason)
        return
    end

    -- 所有条件通过，执行传送。
    local surface = get_or_create_surface(target_name)
    local pos     = find_safe_pos(surface)

    -- player.teleport(position, surface) 返回 bool 表示是否成功。
    -- 失败原因通常是目标位置不可达或引擎内部限制。
    if player.teleport(pos, surface) then
        -- 仅在传送成功后才更新冷却时间，失败不消耗冷却。
        storage.teleport_cooldowns[player.index] = now
        player.print("[传送] 已抵达 " .. display(target_name) .. "，一路平安！")
    else
        player.print("[传送] 传送失败，请稍后再试")
    end
end

-- ============================================================
-- 聊天消息解析
-- ============================================================

-- 监听所有玩家聊天，识别传送意图并提取目标星球。
-- 触发条件（两者同时满足）：
--   1. 消息含意图词：传送 / 去 / teleport
--   2. 消息含星球别名：地星 / 雷星 / 草星 / 火星
-- 示例触发语句："把我传送到火星"、"去草星"、"teleport 地星"
local function on_chat(event)
    -- event.player_index 在服务器广播消息时为 nil，需跳过。
    if not event.player_index then return end
    local player = game.get_player(event.player_index)
    -- 玩家可能已断线，valid 检查防止操作无效实体。
    if not player or not player.valid then return end

    local msg = event.message

    -- 先过滤意图词，避免每条聊天都进入别名遍历。
    if not (msg:find("传送") or msg:find("去") or msg:find("teleport")) then
        return
    end

    -- 遍历别名表，find 第三个参数 true 表示纯文本匹配（不作正则解析）。
    -- 找到第一个匹配的别名后立即传送并返回，防止一条消息重复触发。
    for alias, surface_name in pairs(SURFACE_ALIASES) do
        if msg:find(alias, 1, true) then
            do_teleport(player, surface_name)
            return
        end
    end
end

-- ============================================================
-- 事件注册
-- ============================================================

-- on_init：全新存档首次加载时执行，初始化持久化存储。
script.on_init(function()
    storage.teleport_cooldowns = {}
end)

-- on_configuration_changed：mod 更新或存档迁移后执行。
-- 旧存档的 storage 里可能没有 teleport_cooldowns，ensure_storage 负责补齐。
script.on_configuration_changed(ensure_storage)

-- 监听玩家聊天事件（含 /say 指令产生的消息）。
script.on_event(defines.events.on_console_chat, on_chat)
