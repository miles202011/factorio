## 该文件功能

- 在项目开发过程中，把所有 Factorio 2.x API 的变化、常用代码和注意事项都记录在里面，避免每次开发都重新查文档。

## 规则

  - API 差异示例：矿机采矿半径属性名为 `mining_drill_radius`（1.x 为 `resource_searching_radius`）

## Factorio 2.x API 备注

- 原型访问：`prototypes.entity["xxx"]`，不是 `game.entity_prototypes`
- 飞船：`surface.platform`（`LuaSpacePlatform`），不存在 `game.space_platforms`
- 飞船调度：`records[i].station = "星球名"`，不是 `planet` 字段
- 星球表面可能不存在（未踏足），应用 `game.planets[name].create_surface()` 创建
- 五足虫的腿是独立实体（`big-stomper-pentapod-leg`），清理实体时需用前缀匹配而非精确匹配

- Factorio 2.x 原型访问改为 `prototypes.entity`，不再是 `game.entity_prototypes`
- 飞船通过 `surface.platform` 访问，类型为 `LuaSpacePlatform`


