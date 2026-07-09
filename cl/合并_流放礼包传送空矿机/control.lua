require('__base__/script/freeplay/control.lua')

-- ============================================================
--  工具
-- ============================================================

local function broadcast(msg, color)
    for _, p in pairs(game.players) do
        if p.valid and p.connected then
            p.print(msg, color)
        end
    end
end

-- ============================================================
--  水上孤岛 — 地形生成
-- ============================================================

local SURFACE_NAME = "水上孤岛"
local FLOOR_TILE   = "stone-path"
local WATER_TILE   = "deepwater"
local STOMPER_NAME = "big-stomper-pentapod"
local FLOOR_RADIUS = 5  -- 11×11 地砖

local function on_chunk_generated(event)
    if event.surface.name ~= SURFACE_NAME then return end
    local area    = event.area
    local surface = event.surface
    local tiles   = {}
    for x = area.left_top.x, area.right_bottom.x - 1 do
        for y = area.left_top.y, area.right_bottom.y - 1 do
            local is_center = (x >= -FLOOR_RADIUS and x <= FLOOR_RADIUS
                           and y >= -FLOOR_RADIUS and y <= FLOOR_RADIUS)
            table.insert(tiles, {
                name     = is_center and FLOOR_TILE or WATER_TILE,
                position = {x, y},
            })
        end
    end
    surface.set_tiles(tiles)
    surface.destroy_decoratives({area = area})
    for _, entity in pairs(surface.find_entities(area)) do
        if entity.valid and not entity.name:find(STOMPER_NAME, 1, true) then
            entity.destroy()
        end
    end
    if not storage.stomper_placed
       and area.left_top.x <= 0 and area.right_bottom.x > 0
       and area.left_top.y <= 0 and area.right_bottom.y > 0 then
        local e = surface.create_entity({
            name     = STOMPER_NAME,
            position = {0, 0},
            force    = "enemy",
        })
        if e then storage.stomper_placed = true end
    end
end

script.on_event(defines.events.on_chunk_generated, on_chunk_generated)

local function setup_island()
    storage.stomper_placed = false
    local surface = game.get_surface(SURFACE_NAME) or game.create_surface(SURFACE_NAME, {
        default_enable_all_autoplace_controls = false,
        autoplace_settings = {
            tile       = {treat_missing_as_default = false},
            entity     = {treat_missing_as_default = false},
            decorative = {treat_missing_as_default = false},
        },
        cliff_settings = {cliff_elevation_0 = 1024},
    })
    surface.request_to_generate_chunks({0, 0}, 1)
    surface.force_generate_chunk_requests()
    return surface
end

local function get_island_surface()
    return game.get_surface(SURFACE_NAME) or setup_island()
end

-- ============================================================
--  防捣乱拆除保护 & 孤岛流放
-- ============================================================

local CFG = {
    new_player_ticks = 30 * 60 * 60,  -- 30 分钟
    max_deconstruct  = 50,
    jail_ticks       = 30 * 60,        -- 30 秒
    jail_group_name  = "小黑屋",
}

-- 统一初始化所有模块的 storage 键
local function init_storage()
    -- 防捣乱孤岛流放
    if storage.stomper_placed == nil then storage.stomper_placed = false end
    storage.jailed             = storage.jailed             or {}
    storage.offense_count      = storage.offense_count      or {}
    storage.permanent_ban      = storage.permanent_ban      or {}
    storage.exile_origin       = storage.exile_origin       or {}
    storage.pending_unexile    = storage.pending_unexile    or {}
    -- 开局礼包
    storage.gifted_players     = storage.gifted_players     or {}
    -- 星球传送
    storage.teleport_cooldowns = storage.teleport_cooldowns or {}
end

local function ensure_jail_group()
    local group = game.permissions.get_group(CFG.jail_group_name)
    if group then return group end
    group = game.permissions.create_group(CFG.jail_group_name)
    for _, action in pairs(defines.input_action) do
        pcall(function() group.set_allows_action(action, false) end)
    end
    return group
end

local function strip_player(player)
    if not (player.character and player.character.valid) then return end
    local pos     = player.position
    local surface = player.surface
    local chest = surface.create_entity{
        name     = "steel-chest",
        position = pos,
        force    = player.force,
    }
    local chest_inv = chest and chest.get_inventory(defines.inventory.chest)
    local function collect(name, count)
        local inserted = chest_inv and chest_inv.insert({name = name, count = count}) or 0
        if inserted < count then
            surface.spill_item_stack{
                position      = pos,
                stack         = {name = name, count = count - inserted},
                enable_looted = false,
                force         = player.force,
                allow_belts   = false,
            }
        end
    end
    -- 手持物品（Factorio 2.0 无 clean_cursor，用 cursor_stack 手动处理）
    if player.cursor_stack and player.cursor_stack.valid_for_read then
        collect(player.cursor_stack.name, player.cursor_stack.count)
        player.cursor_stack.clear()
    end
    local inv_ids = {
        defines.inventory.character_main,
        defines.inventory.character_guns,
        defines.inventory.character_ammo,
        defines.inventory.character_armor,
        defines.inventory.character_trash,
    }
    for _, inv_id in pairs(inv_ids) do
        local inv = player.character.get_inventory(inv_id)
        if inv then
            for i = 1, #inv do
                local stack = inv[i]
                if stack.valid_for_read then
                    collect(stack.name, stack.count)
                    stack.clear()
                end
            end
        end
    end
end

local function exile_to_island(player)
    -- 仅在不在孤岛时记录原始位置，防止重复流放覆盖正确的返回点
    if player.surface.name ~= SURFACE_NAME then
        storage.exile_origin[player.name] = {
            x       = player.position.x,
            y       = player.position.y,
            surface = player.surface.name,
        }
    end
    strip_player(player)
    player.teleport({4, 0}, get_island_surface())
end

local function unexile_player(player)
    storage.permanent_ban[player.name]   = nil
    storage.pending_unexile[player.name] = nil
    player.permission_group = game.permissions.get_group("Default")
    local origin = storage.exile_origin[player.name]
    if origin then
        local surface = game.get_surface(origin.surface)
        player.teleport({origin.x, origin.y}, surface or game.get_surface("nauvis"))
        storage.exile_origin[player.name] = nil
    else
        player.teleport({0, 0}, game.get_surface("nauvis"))
    end
end

-- ============================================================
--  开局礼包
-- ============================================================

local function give_starter_gift(player)
    if not player or not player.valid then return end
    if not player.character then return end
    storage.gifted_players = storage.gifted_players or {}
    if storage.gifted_players[player.name] then return end
    storage.gifted_players[player.name] = true

    local armor_inv = player.get_inventory(defines.inventory.character_armor)
    if not armor_inv then return end
    armor_inv[1].set_stack({ name = "power-armor", count = 1 })

    local grid = armor_inv[1].grid
    if grid then
        grid.put({ name = "fission-reactor-equipment" })
        grid.put({ name = "exoskeleton-equipment" })
        grid.put({ name = "exoskeleton-equipment" })
        grid.put({ name = "personal-roboport-equipment" })
        grid.put({ name = "personal-roboport-equipment" })
        grid.put({ name = "belt-immunity-equipment" })
        grid.put({ name = "battery-mk2-equipment" })
        grid.put({ name = "night-vision-equipment" })
    end

    player.insert({ name = "construction-robot", count = 20 })
    player.print(
        "欢迎！你已收到新玩家礼包：\n" ..
        "✔ 能量装甲（已装备）内含：裂变反应堆×1、外骨骼×2、机器人指令×2、锚定×1、电池组MK2×1、夜视×1\n" ..
        "✔ 建设机器人 ×20",
        { r = 0.4, g = 1.0, b = 0.4 }
    )
end

-- ============================================================
--  判断玩家本地化语言（91 tick 两级延迟中继）
-- ============================================================

local join_player_name1 = ""
local join_player_name2 = ""

-- ============================================================
--  星球传送
-- ============================================================

local SURFACE_ALIASES = {
    ["地星"] = "nauvis",
    ["雷星"] = "fulgora",
    ["草星"] = "gleba",
    ["火星"] = "vulcanus",
    ["冰星"] = "aquilo",
}

local SURFACE_DISPLAY = {}
for alias, name in pairs(SURFACE_ALIASES) do
    SURFACE_DISPLAY[name] = alias
end

local COOLDOWN_TICKS = 10 * 60 * 60  -- 10 分钟

local function display(surface_name)
    return SURFACE_DISPLAY[surface_name] or surface_name
end

local function check_inventory(player)
    if player.vehicle then
        return false, "请先离开载具再传送"
    end
    local main = player.get_inventory(defines.inventory.character_main)
    if main and not main.is_empty() then
        return false, "背包中还有物品，请先清空背包"
    end
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

local function get_or_create_surface(name)
    local surface = game.get_surface(name)
    if surface then return surface end
    local planet = game.planets[name]
    if planet then return planet.create_surface() end
    return game.create_surface(name)
end

local function find_safe_pos(surface)
    return surface.find_non_colliding_position("character", {0, 0}, 500, 1)
        or {x = 0, y = 0}
end

local function do_teleport(player, target_name)
    storage.teleport_cooldowns = storage.teleport_cooldowns or {}
    local char_surface = player.character and player.character.surface.name or player.surface.name
    if char_surface == target_name then
        player.print("[传送] 你已经在 " .. display(target_name) .. " 了！")
        return
    end
    local now       = game.tick
    local last      = storage.teleport_cooldowns[player.index] or 0
    local remaining = COOLDOWN_TICKS - (now - last)
    if last > 0 and remaining > 0 then
        local s   = math.ceil(remaining / 60)
        local min = math.floor(s / 60)
        local sec = s % 60
        player.print(string.format("[传送] 冷却中，还需等待 %d 分 %02d 秒", min, sec))
        return
    end
    local ok, reason = check_inventory(player)
    if not ok then
        player.print("[传送] 无法传送：" .. reason)
        return
    end
    local surface = get_or_create_surface(target_name)
    local pos     = find_safe_pos(surface)
    if player.teleport(pos, surface) then
        storage.teleport_cooldowns[player.index] = now
        player.print("[传送] 已抵达 " .. display(target_name) .. "，一路平安！")
    else
        player.print("[传送] 传送失败，请稍后再试")
    end
end

local function on_chat(event)
    if not event.player_index then return end
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    local msg = event.message
    if not (msg:find("传送") or msg:find("去") or msg:find("teleport")) then return end
    for alias, surface_name in pairs(SURFACE_ALIASES) do
        if msg:find(alias, 1, true) then
            do_teleport(player, surface_name)
            return
        end
    end
end

-- ============================================================
--  自动拆除空矿机
-- ============================================================

local function drill_has_resources(drill)
    local prototype  = drill.prototype
    local radius     = prototype.mining_drill_radius
    local pos        = drill.position
    local categories = prototype.resource_categories
    local resources  = drill.surface.find_entities_filtered({
        area = {
            { pos.x - radius, pos.y - radius },
            { pos.x + radius, pos.y + radius },
        },
        type = "resource",
    })
    for _, res in pairs(resources) do
        if res.valid and categories[res.prototype.resource_category] then
            return true
        end
    end
    return false
end

local function mark_empty_drills(surface)
    local drills    = surface.find_entities_filtered({ type = "mining-drill" })
    local count     = 0
    local first_pos = nil
    for _, drill in pairs(drills) do
        if drill.valid and not drill.to_be_deconstructed() then
            if not drill_has_resources(drill) then
                drill.order_deconstruction(drill.force)
                count     = count + 1
                first_pos = first_pos or drill.position
            end
        end
    end
    if count > 0 then
        local loc    = "(" .. math.floor(first_pos.x) .. ", " .. math.floor(first_pos.y) .. ")"
        local suffix = count == 1 and "1 台矿机" or count .. " 台矿机"
        broadcast(
            "[color=255,200,100]自动拆除：[/color]矿区资源耗尽，已标记 " .. suffix ..
            " 拆除，附近 [color=200,200,200]" .. loc .. "[/color]",
            { r = 1.0, g = 0.8, b = 0.4 }
        )
    end
end

-- ============================================================
--  事件注册
-- ============================================================

-- 玩家加入（合并：语言检测 + 流放恢复 + 欢迎 + 礼包 + 临时小黑屋续期）
script.on_event(defines.events.on_player_joined_game, function(event)
    init_storage()
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end

    -- 语言检测中继（只记名字，91-tick 后输出）
    join_player_name1 = player.name

    -- 离线期间被管理员释放
    if storage.pending_unexile[player.name] then
        unexile_player(player)
        player.print("【系统】管理员已将你从孤岛释放，权限已恢复。")
        player.print("欢迎 [color=100,255,100]" .. player.name .. "[/color] 回来！")
        give_starter_gift(player)
        return
    end

    -- 永久小黑屋：锁权限 + 流放，不欢迎不发礼包
    if storage.permanent_ban[player.name] then
        player.permission_group = ensure_jail_group()
        exile_to_island(player)
        game.print(
            "【小黑屋】永久小黑屋玩家 " .. player.name .. " 尝试加入，已流放至孤岛，权限锁定！",
            { r = 1, g = 0, b = 0 }
        )
        return
    end

    -- 正常玩家
    player.print("欢迎 [color=100,255,100]" .. player.name .. "[/color] 加入服务器！")
    player.print("📋 QQ 群：[color=255,215,0]1101554578[/color]，欢迎加群交流！")
    player.print("🚀 星球传送：在聊天中说「去火星」「传送到草星」等即可跨星球传送（背包需清空，10 分钟冷却）")
    player.print("   支持：[color=180,220,255]地星[/color] / [color=255,200,100]火星[/color] / [color=150,255,150]草星[/color] / [color=180,180,255]雷星[/color] / [color=200,240,255]冰星[/color]")
    give_starter_gift(player)

    if player.admin then
        player.print("【管理员提示】孤岛流放命令：")
        player.print("  /exile <玩家名>   — 流放至孤岛并永久锁定权限")
        player.print("  /unexile <玩家名> — 释放并传送回原位置，恢复权限")
    end

    -- 临时小黑屋重连：检查剩余时间
    local release_tick = storage.jailed[event.player_index]
    if release_tick then
        local remaining = math.ceil((release_tick - game.tick) / 60)
        if remaining > 0 then
            player.permission_group = ensure_jail_group()
            player.print("【小黑屋】你重新连线，惩罚仍在进行，剩余约 " .. remaining .. " 秒。")
        else
            storage.jailed[event.player_index] = nil
        end
    end
end)

-- 玩家首次创建（首次进入游戏）
script.on_event(defines.events.on_player_created, function(event)
    init_storage()
    give_starter_gift(game.get_player(event.player_index))
end)

-- 检测框选拆除
script.on_event(defines.events.on_player_deconstructed_area, function(event)
    init_storage()
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    if player.online_time >= CFG.new_player_ticks then return end

    local entities = event.surface.find_entities_filtered{
        area                = event.area,
        force               = player.force,
        to_be_deconstructed = true,
    }
    local count = #entities
    if count <= CFG.max_deconstruct then return end

    event.surface.cancel_deconstruct_area{
        area   = event.area,
        force  = player.force,
        player = player,
    }

    local offenses = storage.offense_count[player.name] or 0

    if offenses >= 1 then
        storage.permanent_ban[player.name] = true
        storage.offense_count[player.name] = offenses + 1
        player.permission_group = ensure_jail_group()
        exile_to_island(player)
        game.print(
            "【全服通报】玩家 " .. player.name ..
            " 再次一次性标记拆除了 " .. count .. " 个建筑！已永久加入「小黑屋」并流放至水上孤岛！",
            { r = 1, g = 0, b = 0 }
        )
    else
        storage.offense_count[player.name] = 1
        storage.jailed[event.player_index] = game.tick + CFG.jail_ticks
        player.permission_group = ensure_jail_group()
        game.print(
            "【全服通报】新玩家 " .. player.name ..
            " 一次性标记拆除了 " .. count .. " 个建筑！已被关入「小黑屋」30 秒，所有权限暂停！",
            { r = 1, g = 0.7, b = 0 }
        )
        player.print("【警告】你一次性标记了 " .. count .. " 个建筑拆除，操作已被撤销！")
        player.print("【警告】已关入「小黑屋」30 秒，期间所有操作被禁止。")
        player.print("【警告】解除后请遵守规则，再次违规将被永久加入小黑屋并流放孤岛！")
    end
end)

-- 资源耗尽时检查附近矿机
script.on_event(defines.events.on_resource_depleted, function(event)
    local resource = event.entity
    if not resource or not resource.valid then return end
    local pos    = resource.position
    local drills = resource.surface.find_entities_filtered({
        area = { { pos.x - 15, pos.y - 15 }, { pos.x + 15, pos.y + 15 } },
        type = "mining-drill",
    })
    local count     = 0
    local first_pos = nil
    for _, drill in pairs(drills) do
        if drill.valid and not drill.to_be_deconstructed() then
            if not drill_has_resources(drill) then
                drill.order_deconstruction(drill.force)
                count     = count + 1
                first_pos = first_pos or drill.position
            end
        end
    end
    if count > 0 then
        local loc    = "(" .. math.floor(first_pos.x) .. ", " .. math.floor(first_pos.y) .. ")"
        local suffix = count == 1 and "1 台矿机" or count .. " 台矿机"
        broadcast(
            "[color=255,200,100]自动拆除：[/color]矿区资源耗尽，已标记 " .. suffix ..
            " 拆除，附近 [color=200,200,200]" .. loc .. "[/color]",
            { r = 1.0, g = 0.8, b = 0.4 }
        )
    end
end)

-- 聊天传送
script.on_event(defines.events.on_console_chat, on_chat)

-- 每 60 tick：临时小黑屋释放检查
script.on_nth_tick(60, function(event)
    if not storage.jailed then return end
    for idx, release_tick in pairs(storage.jailed) do
        if event.tick >= release_tick then
            storage.jailed[idx] = nil
            local player = game.players[idx]
            if player and player.valid and player.connected
               and not storage.permanent_ban[player.name] then
                player.permission_group = game.permissions.get_group("Default")
                player.print("【系统】30 秒惩罚结束，权限已恢复。")
                player.print("【系统】再次大规模拆除将被永久加入小黑屋并流放孤岛，请遵守服务器规则！")
                game.print(
                    "【系统】玩家 " .. player.name .. " 已从小黑屋释放。",
                    { r = 0.4, g = 1, b = 0.4 }
                )
            end
        end
    end
end)

-- 每 91 tick：语言检测两级中继
script.on_nth_tick(91, function()
    if join_player_name2 ~= "" then
        local player = game.players[join_player_name2]
        if player then
            game.print("[color=red]<服务器>" .. player.name .. "的语言为" .. player.locale .. "[/color]")
        end
    end
    join_player_name2 = join_player_name1
    join_player_name1 = ""
end)

-- 每 18000 tick（5 分钟）：全图空矿机兜底扫描
script.on_nth_tick(18000, function()
    for _, surface in pairs(game.surfaces) do
        mark_empty_drills(surface)
    end
end)

-- ============================================================
--  管理员命令
-- ============================================================

commands.add_command("exile", "【管理员】将玩家流放至孤岛并永久锁定权限", function(cmd)
    local caller      = cmd.player_index and game.players[cmd.player_index]
    local caller_name = caller and caller.name or "服务器控制台"
    if caller and not caller.admin then
        caller.print("【错误】仅管理员可使用此命令。")
        return
    end
    if not cmd.parameter then
        if caller then caller.print("【错误】用法：/exile <玩家名>") end
        return
    end
    if cmd.parameter == "miles202011" then
        game.print(
            "【全服通报】错误：流放 miles202011 所需科技尚未研究，请先解锁「基本常识」科技包。" ..
            "本次操作已记录至 " .. caller_name .. " 的黑历史。",
            { r = 1, g = 0.8, b = 0 }
        )
        return
    end
    local target = game.players[cmd.parameter]
    if not (target and target.valid) then
        if caller then caller.print("【错误】找不到玩家：" .. cmd.parameter) end
        return
    end
    init_storage()
    storage.permanent_ban[target.name] = true
    storage.offense_count[target.name] = (storage.offense_count[target.name] or 0) + 1
    target.permission_group = ensure_jail_group()
    exile_to_island(target)
    game.print(
        "【管理员】" .. caller_name .. " 将玩家 " .. target.name .. " 流放至孤岛。",
        { r = 1, g = 0.5, b = 0 }
    )
end)

commands.add_command("unexile", "【管理员】将玩家从孤岛释放并恢复权限", function(cmd)
    local caller      = cmd.player_index and game.players[cmd.player_index]
    local caller_name = caller and caller.name or "服务器控制台"
    if caller and not caller.admin then
        caller.print("【错误】仅管理员可使用此命令。")
        return
    end
    if not cmd.parameter then
        if caller then caller.print("【错误】用法：/unexile <玩家名>") end
        return
    end
    local target = game.players[cmd.parameter]
    if not (target and target.valid) then
        if caller then caller.print("【错误】找不到玩家：" .. cmd.parameter) end
        return
    end
    init_storage()
    if target.connected then
        unexile_player(target)
        target.print("【系统】管理员已将你从孤岛释放，权限已恢复。")
        game.print(
            "【管理员】" .. caller_name .. " 将玩家 " .. target.name .. " 从孤岛释放。",
            { r = 0.4, g = 1, b = 0.4 }
        )
    else
        storage.permanent_ban[target.name]   = nil
        storage.pending_unexile[target.name] = true
        if caller then
            caller.print("【系统】玩家 " .. target.name .. " 当前离线，将在其下次上线时自动释放。")
        end
    end
end)

-- ============================================================
--  初始化
-- ============================================================

script.on_init(function()
    init_storage()
    setup_island()
end)

script.on_configuration_changed(function()
    init_storage()
    for _, surface in pairs(game.surfaces) do
        mark_empty_drills(surface)
    end
end)
