功能：聊天触发星球传送
触发方式：聊天消息同时包含意图词（传送/去/teleport）和目的地别名
目的地别名：地星=nauvis, 雷星=fulgora, 草星=gleba, 火星=vulcanus
限制：不能传送到当前所在表面
冷却：每玩家独立 10 分钟（600 ticks * 60 = 36000 ticks）
背包要求：主背包全空 + 弹药栏全空 + 不能在载具内
表面不存在时：自动 game.create_surface 创建并传送
落点：find_non_colliding_position 从 (0,0) 半径 500 搜索
存储键：storage.teleport_cooldowns[player.index] = game.tick（上次传送时刻）
修复：player.surface 是视角表面，已改用 player.character.surface 判断角色实际位置
修复：新增 character_trash 检查，物流回收栏有物品时拦截传送
