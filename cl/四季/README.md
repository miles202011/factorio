四季
nauvis 分为四个象限，分别克隆三颗星球的地形：
  左下 (x<0, y>0) → 草星 gleba
  右上 (x>0, y<0) → 火星 vulcanus
  右下 (x>0, y>0) → 雷星 fulgora
  左上 (x<0, y<0) → 地星 nauvis 原生地形（不处理）

撼地虫领地方案：
  使用 LuaSurface.create_territory + create_segmented_unit({territory=...}) 在 nauvis 上
  复现 Vulcanus territory 系统。撼地虫只在分配的领地内活动，行为与火星一致。

  领地分组策略：
    - 用 vulcanus.get_territory_for_chunk(chunk_pos) 读取火星实际 Voronoi 领地
    - 键值 = "v" .. vc[1].x .. "," .. vc[1].y（vc = vt.get_chunks()）
    - 无 Voronoi 数据或领地跨象限 → 直接跳过，不创建领地、不生成撼地虫
    - 不能有矩形 fallback：Voronoi key("v...")与矩形key("g...")混用 → 同一领地变两个独立领地

  跨象限过滤（必须）：
    只有 Voronoi 领地的所有区块都满足 c.x >= 0 AND c.y < 0（即 c.y <= -1），才在 nauvis 创建领地
    任意一个区块在象限外 → 整个领地跳过
    区块坐标判断：c.x < 0 or c.y >= 0 → 不在火星象限

  每个 territory 只在首次创建时（is_new=true）生成撼地虫：
    - 先在 Vulcanus 对应区块找现有撼地虫，复制其名称和位置（create_segmented_unit）
    - 找不到则在区块内 5 个候选点依次尝试生成（小:中:大 = 3:2:1 随机池）
    - 后续同 territory 区块通过 set_territory_for_chunks 加入，不重复生成
    - 每次领地变动后必须调用 territory.regenerate_patrol_path()，否则撼地虫只原地转圈

撼地虫 AI 状态机：
  patrolling → investigating → attacking → enraged_at_target/enraged_at_nothing → patrolling
  - patrolling：按 territory.get_patrol_path() 路径点巡逻
  - investigating：检测到领地内扰动（玩家建筑），冲向扰动位置
  - attacking：锁定目标追击
  - enraged：被攻击后暴走 30 秒，之后回到 patrolling
  - 无 territory 时：引擎用 territory_radius=4（区块）内部生成巡逻路径，路径不可 Lua 读取
  速度（tiles/tick × speed_multiplier）：巡逻 2/60、侦查 4/60、攻击 7/60、暴走 10/60

关键 API 行为（已验证）：
  - LuaTerritory 字段：surface、valid、object_name，无 unit_number（用它做键会报错）
  - ChunkPositionAndArea：直接有 .x、.y、.area，没有 .position 子表
  - create_segmented_unit 必须传 position 或 body_nodes，否则报错
  - territory_radius=4（区块）是巡逻半径；攻击范围是整个 Voronoi 领地
  - clone_area 不克隆 segmented-unit，必须手动 create_segmented_unit
  - Lua create_territory 会渲染红色领地 overlay（非 data 阶段专属）
