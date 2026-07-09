require('__base__/script/freeplay/control.lua')

--[[
    判断刚加入玩家的本地化语言
    提取自 majoros2/control.lua

    原理：利用两个变量做 91 tick 延迟中继，
    等待玩家 locale 数据加载完毕后再输出，
    避免刚加入时 locale 尚未同步的问题。
]]--

local join_player_name1 = ""
local join_player_name2 = ""

-- 玩家加入时记录其名字
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    join_player_name1 = player.name
end)

-- 每 91 tick 推进一次变量，延迟后输出 locale
-- 会有极小概率发生同步错误，重连可解决
script.on_nth_tick(91, function()
    if join_player_name2 ~= "" then
        local player = game.players[join_player_name2]
        if player then
            local msg = "[color=red]<服务器>" .. player.name .. "的语言为" .. player.locale .. "[/color]"
            game.print(msg)
        end
    end
    join_player_name2 = join_player_name1
    join_player_name1 = ""
end)
