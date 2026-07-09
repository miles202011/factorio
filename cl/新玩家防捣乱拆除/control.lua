require('__base__/script/freeplay/control.lua')

-- ============================================================
--  防捣乱拆除保护
--  新玩家（上线 < 30 分钟）框选标记拆除 > 50 个建筑：
--    首次 → 撤销 + 小黑屋 30 秒 + 全服通报
--    再犯 → 撤销 + 永久小黑屋 + 踢出 + 全服通报
-- ============================================================

local CFG = {
    new_player_ticks = 30 * 60 * 60,  -- 30 分钟
    max_deconstruct  = 50,
    jail_ticks       = 30 * 60,        -- 30 秒
    jail_group_name  = "小黑屋",
}

local function init_storage()
    storage.jailed        = storage.jailed        or {}
    storage.offense_count = storage.offense_count or {}
    storage.permanent_ban = storage.permanent_ban or {}
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

-- 玩家加入：恢复永久小黑屋状态 / 临时小黑屋续期
script.on_event(defines.events.on_player_joined_game, function(event)
    init_storage()
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end

    if storage.permanent_ban[player.name] then
        player.permission_group = ensure_jail_group()
        game.print(
            "【小黑屋】永久小黑屋玩家 " .. player.name .. " 尝试加入，权限已锁定！",
            { r = 1, g = 0, b = 0 }
        )
        return
    end

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

    -- 立即撤销
    event.surface.cancel_deconstruct_area{
        area   = event.area,
        force  = player.force,
        player = player,
    }

    local offenses = storage.offense_count[player.name] or 0

    if offenses >= 1 then
        -- 再犯：永久小黑屋
        storage.permanent_ban[player.name] = true
        storage.offense_count[player.name] = offenses + 1
        player.permission_group = ensure_jail_group()
        game.print(
            "【全服通报】玩家 " .. player.name ..
            " 再次一次性标记拆除了 " .. count .. " 个建筑！已永久加入「小黑屋」并踢出服务器！",
            { r = 1, g = 0, b = 0 }
        )
        pcall(function() game.kick_player(player, "你因多次大规模拆除行为被踢出，已永久加入小黑屋。") end)
    else
        -- 首犯：临时小黑屋 30 秒
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
        player.print("【警告】解除后请遵守规则，再次违规将被永久加入小黑屋并踢出服务器！")
    end
end)

-- 每秒检查释放
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
                player.print("【系统】再次大规模拆除将被永久加入小黑屋，请遵守服务器规则！")
                game.print(
                    "【系统】玩家 " .. player.name .. " 已从小黑屋释放。",
                    { r = 0.4, g = 1, b = 0.4 }
                )
            end
        end
    end
end)
