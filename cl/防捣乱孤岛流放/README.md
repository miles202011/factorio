# 防捣乱孤岛流放 — 设计备忘

## 来源
合并自：水上孤岛 + 新玩家防捣乱拆除

## 功能概述

### 水上孤岛地形
- 表面名：水上孤岛
- 中心地砖：stone-path，FLOOR_RADIUS=5（11×11），其余全部 deepwater
- 生物：big-stomper-pentapod 大型重踏五足虫，位于 (0,0)，force=enemy
- autoplace 全部关闭，区块覆盖逻辑同原版水上孤岛

### 惩罚机制（新玩家上线 < 30 分钟触发）
- 阈值：框选标记拆除 > 50 个建筑
- 首次：临时小黑屋 30 秒（所有权限锁定），全服通报
- 再犯：永久小黑屋（权限永久锁定）+ 传送至孤岛 (4, 0)，全服通报
- 永久小黑屋不是封禁，玩家仍可重连，但重连后：
    - 自动恢复权限锁定
    - 自动再次传送至孤岛

## 技术细节

- `get_island_surface()` — 懒获取孤岛表面，不存在时调用 setup_island()
- `exile_to_island(player)` — 记录原始位置（仅在不在孤岛时），teleport 到 (4, 0)
- `unexile_player(player)` — 清除封禁、恢复权限、传送回 exile_origin（无记录则去 nauvis 0,0）
- 永久流放无踢出操作，玩家留在游戏中被监视
- storage 键：stomper_placed / jailed / offense_count / permanent_ban / exile_origin / pending_unexile
- init_storage() 懒初始化，同时在 on_init / on_configuration_changed 中调用
- 无 on_player_left_game：重连时 on_player_joined_game 检查剩余时间续期
- 永久小黑屋用玩家名（player.name）索引，跨连线持久

## 管理员命令

- `/exile <玩家名>` — 流放至孤岛并永久锁定权限（记录原始位置）
- `/unexile <玩家名>` — 释放并传送回原位置，恢复权限
  - 玩家在线：立即执行
  - 玩家离线：清除封禁，设 pending_unexile，重连时自动执行
- 管理员上线时私聊收到命令提示

## 已知行为（非 bug，已确认不改）
- 检测用 to_be_deconstructed=true，统计选区内所有已标记建筑，含跨次叠加

## 修改记录
[2026-05-21 00:00:00] 初始创建：合并水上孤岛地形 + 防捣乱流放机制
[2026-05-21 19:43:36] 新增管理员命令 /exile /unexile；exile_to_island 记录原始位置；新增 unexile_player；管理员上线私聊提示；pending_unexile 处理离线释放
[2026-05-21 19:50:47] /exile 新增 miles202011 保护：尝试流放该玩家的管理员将被全服嘲讽
[2026-05-21 19:53:57] 更换嘲讽文案为异星工厂风格：「基本常识科技包」
[2026-05-21 19:58:04] 嘲讽文案调整署名格式：「本次操作已记录至 XXX 的黑历史」
[2026-05-21 20:00:57] 新增玩家加入欢迎语 + QQ 群号 1101554578 私聊提示
[2026-05-21 20:10:30] 删除 on_player_left_game：重连续期逻辑已覆盖该场景，离线清理多余
[2026-05-21 20:13:02] 新增 strip_player()：流放前在原地生成紫箱存放物品，溢出掉落地面
[2026-05-21 20:17:08] 新增 exile_permanent()：将锁权限与传送孤岛绑定，永久小黑屋两处触发点统一调用
[2026-05-21 20:18:04] 修复崩溃：服务器控制台执行命令时 cmd.player_index 为 nil，game.players[nil] 直接崩服；改用 cmd.player_index and game.players[...]，控制台视为管理员权限
[2026-05-21 20:18:43] 修复 strip_player()：clean_cursor 在 Factorio 2.0 不存在，改用 cursor_stack 手动处理手持物品
[2026-05-21 20:21:22] 回滚：删除 exile_permanent()，恢复锁权限与传送分开两行调用
[2026-05-21 20:26:09] 修复 strip_player()：logistic-chest-passive-provider 在 Factorio 2.0 不存在，改用 steel-chest
[2026-05-21 20:27:39] 修复 strip_player()：查官方 wiki 确认紫箱实体名为 passive-provider-chest，替换 steel-chest
[2026-05-22 12:30:11] strip_player() 改回 steel-chest（钢箱）
