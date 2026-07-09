功能：生成一个自定义孤岛表面
表面名：水上孤岛
中心地砖：stone-path，半径 FLOOR_RADIUS=5（11×11），足够容纳重踏虫碰撞箱 ±2.4
其余全部：deepwater（不可通行）
生物：big-stomper-pentapod 大型重踏五足虫，位于 (0,0)，force=enemy
区块控制：on_chunk_generated 事件覆盖所有新生成区块，防止玩家探索时露出默认地形
autoplace：全部关闭，地形/实体/装饰均不自动生成

已知问题与修复记录：
- 装饰物（石块等）需在 on_chunk_generated 中调用 destroy_decoratives 清除
- 五足虫的腿是独立实体（big-stomper-pentapod-leg），清理时用前缀匹配保留：
    not entity.name:find(STOMPER_NAME, 1, true)
  否则腿被删除后虫子立即死亡
- 碰撞箱 ±2.3984375，实测 0×0 地板也可手动放置，水面不阻止 create_entity

修改记录：
[2026-05-21 19:00] 初始创建：水面+中心地砖+大型重踏五足虫
[2026-05-21 19:05] 修复装饰物：新增 destroy_decoratives 清除石块等自动生成装饰
[2026-05-21 19:08] 修复虫子消失：实体清理改用前缀匹配，保留腿部独立实体
[2026-05-21 19:10] 调整地板尺寸：FLOOR_RADIUS 2→5（5×5→11×11）
[2026-05-21 19:15] 修复虫子不生成：on_init 期间瓦片尚未就位，改为 setup() 中显式铺砖后放置
[2026-05-21 19:27:05] 重构虫子放置：移入 on_chunk_generated 中心区块判断内，瓦片设完即放，storage.stomper_placed 防重复
[2026-05-21 19:29:47] 验证通过：新游戏启动后大型重踏五足虫成功生成
