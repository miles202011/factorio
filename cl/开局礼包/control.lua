-- 功能：新玩家开局礼包
-- 作者：由QQ群1101554578的伙伴制作
-- 触发：玩家首次创建或加入游戏时检查，每个玩家名只发一次。
-- 礼包：自动穿戴能量装甲，装入裂变反应堆、外骨骼×2、机器人指令×2。
-- 礼包：继续装入锚定、电池MK2、夜视，并发放建设机器人×20。
require('__base__/script/freeplay/control.lua')

-- freeplay 场景本身使用 event_handler 分发事件。
-- 这里继续使用同一个 handler 追加逻辑，避免直接 script.on_event 覆盖原版 freeplay 事件。
local handler = require("event_handler")

-- Factorio 2.x 使用 storage，1.x 使用 global。
-- 保留这个小兼容层，方便同一份脚本在不同版本里读写持久化数据。
local function get_store()
    if storage ~= nil then return storage end
    return global
end

local function give_starter_gift(player)
    -- 玩家对象、角色实体不存在时不能操作角色背包或装甲栏。
    if not player or not player.valid then return end
    if not player.character then return end

    local store = get_store()
    store.gifted_players = store.gifted_players or {}

    -- 使用玩家名做领取记录，避免 on_player_joined_game 重连时重复发放。
    if store.gifted_players[player.name] then return end
    store.gifted_players[player.name] = true

    -- 直接把能量装甲放进角色装甲栏，相当于自动穿上。
    local armor_inv = player.get_inventory(defines.inventory.character_armor)
    if not armor_inv then return end
    armor_inv[1].set_stack({ name = "power-armor", count = 1 })

    local grid = armor_inv[1].grid
    if grid then
        -- 当前装备合计占 47 格，power-armor 网格为 48 格，刚好能放下。
        -- 以后新增装备前需要重新确认网格容量和摆放是否可行。
        grid.put({ name = "fission-reactor-equipment" })
        grid.put({ name = "exoskeleton-equipment" })
        grid.put({ name = "exoskeleton-equipment" })
        grid.put({ name = "personal-roboport-equipment" })
        grid.put({ name = "personal-roboport-equipment" })
        grid.put({ name = "belt-immunity-equipment" })
        grid.put({ name = "battery-mk2-equipment" })
        grid.put({ name = "night-vision-equipment" })
    end

    -- 建设机器人放入玩家背包，配合装甲里的机器人指令模块使用。
    player.insert({ name = "construction-robot", count = 20 })

    player.print(
        "欢迎！你已收到新玩家礼包：\n" ..
        "✔ 能量装甲（已装备）内含：裂变反应堆×1、外骨骼×2、机器人指令×2、锚定×1、电池组MK2×1、夜视×1\n" ..
        "✔ 建设机器人 ×20",
        { r = 0.4, g = 1.0, b = 0.4 }
    )
end

local function give_starter_gift_by_index(event)
    -- 事件里只有 player_index，先转成 LuaPlayer 再进入统一发放逻辑。
    give_starter_gift(game.get_player(event.player_index))
end

handler.add_lib({
    events = {
        -- 新玩家创建时发一次；玩家加入时也检查一次，用于补发和兼容重连场景。
        [defines.events.on_player_created]     = give_starter_gift_by_index,
        [defines.events.on_player_joined_game] = give_starter_gift_by_index,
    },
    on_init = function()
        -- 新存档初始化领取记录；之后会随存档持久化。
        get_store().gifted_players = {}
    end,
})
