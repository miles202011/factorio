# 合并版综合服务器脚本 — 设计备忘

## 来源
合并自 5 个独立 cl：
- 防捣乱孤岛流放（水上孤岛地形 + 流放系统 + 管理员命令）
- 开局礼包（新玩家装备礼包）
- 判断玩家本地化语言（91-tick 延迟检测 locale）
- 星球传送（聊天触发星球间传送）
- 自动拆除空矿机（资源耗尽自动标记拆除）

## storage 键（所有模块共享）

| 键 | 类型 | 用途 |
|----|------|------|
| stomper_placed | bool | 孤岛五足虫是否已生成 |
| jailed | table[player_index → tick] | 临时小黑屋释放时刻 |
| offense_count | table[player.name → int] | 拆除违规次数 |
| permanent_ban | table[player.name → bool] | 永久小黑屋 |
| exile_origin | table[player.name → {x,y,surface}] | 流放前原始位置 |
| pending_unexile | table[player.name → bool] | 离线时被释放，重连后执行 |
| gifted_players | table[player.name → bool] | 已发放礼包，防重复 |
| teleport_cooldowns | table[player.index → tick] | 传送上次时刻 |

## on_player_joined_game 处理顺序（重要）

1. 记录语言检测变量（join_player_name1）
2. pending_unexile → 释放 + 欢迎 + 礼包，return
3. permanent_ban → 锁权限 + 流放，return（不发礼包不欢迎）
4. 正常：欢迎 + 礼包 + 管理员提示 + 临时小黑屋续期检查

## 各模块关键参数

- 防捣乱：新玩家保护期 30 分钟，框选阈值 > 50，临时小黑屋 30 秒
- 开局礼包：power-armor（6×8=48格，当前占 47 格）+ 建设机器人×20；按 player.name 去重
- 语言检测：两变量中继（join_player_name1 → join_player_name2），91-tick 后全服广播
- 星球传送：聊天含"传送/去/teleport"+ 别名触发；冷却 10 分钟；需背包、弹药栏、物流回收栏全空且不在载具
  - 别名：地星=nauvis, 雷星=fulgora, 草星=gleba, 火星=vulcanus, 冰星=aquilo
  - 星球不存在时优先 planet.create_surface()，否则 game.create_surface()
- 空矿机：on_resource_depleted + on_nth_tick(18000) 兜底；API 为 mining_drill_radius（2.0）

## 事件注册总览

| 事件 / tick | 功能 |
|---|---|
| on_chunk_generated | 孤岛地形覆盖 |
| on_player_joined_game | 语言/流放/欢迎/礼包/小黑屋续期（合并） |
| on_player_created | 首次创建给礼包 |
| on_player_deconstructed_area | 防捣乱检测 |
| on_resource_depleted | 空矿机实时检测 |
| on_console_chat | 聊天传送 |
| on_nth_tick(60) | 临时小黑屋释放 |
| on_nth_tick(91) | 语言检测中继 |
| on_nth_tick(18000) | 空矿机全图扫描 |

## 合并注意事项
- 去掉了 event_handler 依赖（原开局礼包使用），改为 script.on_event 直接注册
- on_init：init_storage + setup_island
- on_configuration_changed：init_storage + mark_empty_drills 全图扫描

## 修改记录
[2026-05-22] 初始创建：合并防捣乱孤岛流放 + 开局礼包 + 判断玩家语言 + 星球传送 + 自动拆除空矿机
[2026-05-22] 加入时私聊告知传送功能：用法说明 + 五星球彩色列表
[2026-05-22] 新增 character_trash 检查：物流回收栏有物品时拦截传送
[2026-05-22] 修复传送误判：player.surface 是视角表面，改用 player.character.surface 判断角色实际位置
