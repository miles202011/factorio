# 新玩家防捣乱拆除 — 设计备忘

## 已知行为（非 bug，已确认不改）

- 检测用的是 `to_be_deconstructed = true`，统计的是选区内**所有**已标记建筑，不只是本次新标记的。
  - 后果：玩家第一次选 49 个、第二次选区覆盖第一次时，两次叠加可能触发阈值。
  - 用差值法（取消前后各数一次）可精确只数本次新标记数量，但用户决定不改。

## 惩罚机制

- 首次：临时小黑屋 30 秒（所有权限锁定），全服通报
- 再犯：永久小黑屋（权限永久锁定）+ 踢出，全服通报
- 永久小黑屋不是封禁，玩家仍可重连，但重连后权限依然锁定

## 技术细节

- `game.kick_player` 用 `pcall` 包裹，防止 API 不可用时报错
- 无 `on_player_left_game`：重连时 `on_player_joined_game` 会检查剩余时间，离线清理多余
- `storage.permanent_ban` 存永久小黑屋名单，重连时 `on_player_joined_game` 自动恢复限制
- 没有用 `script.on_init`，改用 `init_storage()` 懒初始化，避免与 freeplay 的 `on_init` 冲突
- 适用 Factorio 2.0+（使用 `storage` 而非 `global`）

## 修改记录
[2026-05-21 20:10:30] 删除 on_player_left_game：重连续期逻辑已覆盖该场景，离线清理多余
