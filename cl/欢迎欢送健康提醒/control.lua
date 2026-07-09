require('__base__/script/freeplay/control.lua')

local SERVER_INFO = "📋 服务器信息 | QQ群：[color=255,215,0]1101554578[/color] | 主直连：[color=100,200,255]dx.moe.xin:37009[/color] | 备用直连：[color=100,200,255]lt.moe.xin:37009[/color]"

-- 每隔多少 tick 发一次健康提醒（60 UPS × 3600 秒 = 1 现实小时）
local REMINDER_INTERVAL = 60 * 3600

local HEALTH_REMINDERS = {
    "💪 [color=150,255,150]健康提醒：[/color]已游戏约1小时，建议起身活动5分钟，做个拉伸！",
    "👀 [color=150,255,150]健康提醒：[/color]注意保护眼睛！闭眼休息20秒，眺望远处放松一下。",
    "💧 [color=150,255,150]健康提醒：[/color]长时间游戏别忘了多喝水，保持身体水分充足！",
    "🧘 [color=150,255,150]健康提醒：[/color]注意坐姿！保护颈椎和腰椎，站起来走动走动。",
}

local function get_store()
    if storage ~= nil then return storage end
    return global
end

local function broadcast(msg, color)
    for _, p in pairs(game.players) do
        if p.valid and p.connected then
            p.print(msg, color)
        end
    end
end

-- ============================================================
-- 事件：玩家加入
-- ============================================================
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end

    broadcast(">>> [color=100,255,100]" .. player.name .. "[/color] 加入了游戏，欢迎！", { r = 0.4, g = 1.0, b = 0.4 })
    broadcast(SERVER_INFO, { r = 0.8, g = 0.9, b = 1.0 })
end)

-- ============================================================
-- 事件：玩家离开
-- ============================================================
script.on_event(defines.events.on_player_left_game, function(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end

    broadcast("<<< [color=255,180,80]" .. player.name .. "[/color] 离开了游戏，再见！", { r = 1.0, g = 0.7, b = 0.3 })
end)

-- ============================================================
-- on_tick：每小时循环播放健康提醒
-- ============================================================
script.on_event(defines.events.on_tick, function(event)
    local tick = game.tick
    if tick == 0 or tick % REMINDER_INTERVAL ~= 0 then return end
    local idx = (math.floor(tick / REMINDER_INTERVAL) - 1) % #HEALTH_REMINDERS + 1
    broadcast(HEALTH_REMINDERS[idx], { r = 0.6, g = 1.0, b = 0.6 })
end)

-- ============================================================
-- 初始化
-- ============================================================
script.on_init(function()
    local store = get_store()
    store.reminder_count = store.reminder_count or 0
end)

script.on_load(function()
    -- 无需重置，数据在 storage 里持久化
end)
