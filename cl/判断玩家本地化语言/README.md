提取自：majoros2/control.lua
功能：玩家加入后延迟 91~182 tick 输出其本地化语言（locale）
原理：两变量中继延迟，等待 locale 数据同步完毕
输出格式：全服红色消息 "<服务器>玩家名的语言为zh-CN" 等

## 失败情况

1. 同一 91-tick 窗口内两个玩家先后加入
   - name1 只有一个槽位，后者覆盖前者，前者 locale 丢失
   - 静默跳过，不报错，重连可解决
   - 彻底解决需把 name1 改为队列（见下方改进方案）

2. 玩家加入后在读取前离线（加入后约 91~182 tick 内断线）
   - game.players["名字"] 返回 nil
   - if player then 防御判断挡住，静默跳过，不报错

## 两种失败均为静默跳过，不影响其他玩家，不抛出错误

## 改进方案：用队列替代双变量，支持同窗口多玩家

local queue = {}

script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    table.insert(queue, {name = player.name, join_tick = game.tick})
end)

script.on_nth_tick(91, function()
    local now = game.tick
    for i = #queue, 1, -1 do
        local entry = queue[i]
        if now - entry.join_tick >= 91 then
            local player = game.players[entry.name]
            if player then
                game.print(player.name .. " 的语言为 " .. player.locale)
            end
            table.remove(queue, i)
        end
    end
end)
