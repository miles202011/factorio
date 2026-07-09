# Factorio 已注册声音路径参考

## 结论

普通 scenario 里，`player.play_sound{path=...}` 需要的是 Factorio 已注册的 `SoundPath`，不是 `.ogg` 文件路径。

可以直接使用已注册的 `SoundPath`，例如：

```lua
player.play_sound{path="utility/gui_click", volume_modifier=0.8}
```

不能直接把 `.ogg` 资源文件路径传给 `player.play_sound`：

```lua
player.play_sound{path="__base__/sound/example.ogg"}
```

原因是 scenario 没有 data 阶段，不能注册新的 sound prototype。`data/core/sound/`、`data/base/sound/`、`data/space-age/sound/` 里的 `.ogg` 是资源文件，不等于运行时都能直接作为 `SoundPath` 播放。

## 来源

本文档根据本地 Factorio 2.0.77 数据文件整理：

- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\core\prototypes\utility-sounds.lua`
- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\space-age\prototypes\utility-sounds.lua`
- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\base\script\*.lua`
- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\space-age\menu-simulations\*.lua`
- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\space-age\prototypes\tile\tile-sounds.lua`

## 完整 utility-sounds 注册路径清单（66 个）

以下 66 个 key 来自本地 Factorio 2.0.77 的 `utility-sounds` prototype。调用路径格式均为 `utility/<key>`。

- `core/prototypes/utility-sounds.lua` 定义 65 个。
- `space-age/prototypes/utility-sounds.lua` 追加 1 个：`segment_dying_sound`。
- 这份表是 `utility-sounds` 的完整清单，不是 Factorio 所有 `.ogg` 文件的完整清单。
- 测试工具可以播放这些 `utility/...` 路径来试听。

| 路径 | 来源 | 说明 |
| --- | --- | --- |
| `utility/achievement_unlocked` | core | 成就/奖励提示 |
| `utility/alert_destroyed` | core | 强警告、危险提示 |
| `utility/armor_insert` | core | 装入装备 |
| `utility/armor_remove` | core | 移除装备 |
| `utility/axe_fighting` | core | 近战/打击 |
| `utility/axe_mining_ore` | core | 挖矿 |
| `utility/axe_mining_stone` | core | 敲石头 |
| `utility/build_animated_huge` | core | 超大型动画实体建造 |
| `utility/build_animated_large` | core | 大型动画实体建造 |
| `utility/build_animated_medium` | core | 中型动画实体建造 |
| `utility/build_animated_small` | core | 小型动画实体建造 |
| `utility/build_blueprint_huge` | core | 超大型蓝图放置 |
| `utility/build_blueprint_large` | core | 大型蓝图放置 |
| `utility/build_blueprint_medium` | core | 中型蓝图放置 |
| `utility/build_blueprint_small` | core | 小型蓝图放置 |
| `utility/build_ghost_upgrade` | core | 幽灵升级 |
| `utility/build_ghost_upgrade_cancel` | core | 取消幽灵升级 |
| `utility/build_huge` | core | 超大型建造；用于火箭 |
| `utility/build_large` | core | 大型建造；用于炸弹 |
| `utility/build_medium` | core | 中型建造 |
| `utility/build_small` | core | 小型建造 |
| `utility/cannot_build` | core | 否定/错误提示 |
| `utility/clear_cursor` | core | 清空/取消 |
| `utility/confirm` | core | 确认操作 |
| `utility/console_message` | core | 控制台消息 |
| `utility/crafting_finished` | core | 制作完成 |
| `utility/deconstruct_huge` | core | 超大型拆除 |
| `utility/deconstruct_large` | core | 大型拆除 |
| `utility/deconstruct_medium` | core | 中型拆除 |
| `utility/deconstruct_robot` | core | 机器人拆除 |
| `utility/deconstruct_small` | core | 小型拆除 |
| `utility/default_driving_sound` | core | 默认驾驶声 |
| `utility/default_landing_steps` | core | 默认落地/脚步 |
| `utility/default_manual_repair` | core | 默认维修 |
| `utility/drop_item` | core | 放下物品 |
| `utility/entity_settings_copied` | core | 复制设置 |
| `utility/entity_settings_pasted` | core | 粘贴/写入设置 |
| `utility/game_lost` | core | 失败 |
| `utility/game_won` | core | 胜利 |
| `utility/gui_click` | core | 普通 UI 点击 |
| `utility/gui_switch` | core | 开关切换 |
| `utility/inventory_click` | core | 物品格点击 |
| `utility/inventory_move` | core | 物品移动 |
| `utility/item_deleted` | core | 物品移除 |
| `utility/item_spawned` | core | 物品生成 |
| `utility/list_box_click` | core | 列表选择 |
| `utility/metal_walking_sound` | core | 金属脚步 |
| `utility/mining_wood` | core | 砍木头 |
| `utility/new_objective` | core | 新目标 |
| `utility/paste_activated` | core | 应用粘贴 |
| `utility/picked_up_item` | core | 拾取物品 |
| `utility/rail_plan_start` | core | 铁路规划开始 |
| `utility/research_completed` | core | 研究完成 |
| `utility/rotated_huge` | core | 超大型旋转 |
| `utility/rotated_large` | core | 大型旋转 |
| `utility/rotated_medium` | core | 中型旋转 |
| `utility/rotated_small` | core | 小型旋转 |
| `utility/scenario_message` | core | 场景消息 |
| `utility/segment_dying_sound` | Space Age | Space Age demolisher 死亡声，属于敌人死亡类声音 |
| `utility/smart_pipette` | core | 吸管选取 |
| `utility/switch_gun` | core | 切换武器/状态 |
| `utility/tutorial_notice` | core | 教程提示 |
| `utility/undo` | core | 撤销 |
| `utility/wire_connect_pole` | core | 电线连接 |
| `utility/wire_disconnect` | core | 电线断开 |
| `utility/wire_pickup` | core | 拿起电线 |

## Factorio 自带脚本中实际出现的播放路径

这些是本地 `data/*/script` 或 menu simulation 中实际搜到的 `play_sound` 用法：

| 路径 | 出现位置 | 备注 |
| --- | --- | --- |
| `utility/achievement_unlocked` | `base/script/rocket-rush/rocket-rush.lua` | 成就/奖励 |
| `utility/research_completed` | `base/script/team-production/team_production.lua`, `base/script/pvp/pvp.lua` | 阶段完成 |
| `utility/game_lost` | `base/script/team-production/team_production.lua`, `base/script/wave-defense/wave_defense.lua` | 失败 |
| `utility/game_won` | `base/script/team-production/team_production.lua`, `base/script/wave-defense/wave_defense.lua` | 胜利 |
| `tile-build-small/concrete` | `space-age/menu-simulations/menu-simulation-aquilo-send-help.lua` | 地砖建造声示例 |

## tile 路径确认范围

这条路径已在自带脚本中出现，可作为已注册路径播放：

```lua
surface.play_sound{path="tile-build-small/concrete", position=point}
```

本文档只确认 `tile-build-small/concrete` 这一条 tile build 路径。其它 `tile-build-*` 路径没有列入已确认清单。

## programmable speaker 音色边界

这些在原版可编程扬声器里存在，但它们不是 `player.play_sound{path=...}` 的 `SoundPath`：

- 警报类：`alarm-1`、`alarm-2`、`buzzer-1`、`buzzer-2`、`buzzer-3`、`ring`、`siren`
- 游戏提示类：`achievement-unlocked`、`alert-destroyed`、`cannot-build`、`console-message`、`crafting-finished`、`game-lost`、`game-won`、`gui-click`、`new-objective`、`research-completed`、`scenario-message`
- 打击乐：`kick-1`、`kick-2`、`snare-1`、`snare-2`、`snare-3`、`hat-1`、`hat-2`、`fx`、`high-q`、`perc-1`、`perc-2`、`crash`、`reverse-cymbal`、`clap`、`shaker`、`cowbell`、`triangle`
- 乐器音阶：piano、bass、celesta、drum 等多组音阶

这些音色要通过可编程扬声器实体的 instrument/note 机制触发。没有放置并控制可编程扬声器实体时，scenario 不能直接用 `player.play_sound` 播放这些 note 名称。

## 原型内部声音是什么

Factorio 目录里的大量 `.ogg` 会被实体、武器、环境、机器等 prototype 引用。这类声音是“挂在某个游戏对象或游戏行为上的资源”，不是 `utility/...` 这种可直接给 `player.play_sound` 使用的通用路径。

常见类型：

| 类型 | 例子 | 触发方式 |
| --- | --- | --- |
| 实体声音 | 箱子、门、机器人、火车、炮塔、敌人 | 建造、拆除、受击、死亡、开关、移动 |
| 武器声音 | 手枪、霰弹枪、激光、火箭、炮弹、爆炸 | 开火、命中、爆炸 |
| 环境声音 | 地面脚步、矿石挖掘、树木、水、地砖 | 行走、挖掘、铺地砖、环境事件 |
| 机器声音 | 组装机、炉子、化工厂、离心机、发电机、传送带 | 机器运行、停止、循环工作 |

原型内部声音通常写在 prototype 字段里，例如 `working_sound`、`open_sound`、`close_sound`、`attack_parameters.sound`、`created_effect.sound`、`dying_sound` 等。游戏会在对应行为发生时播放它们。

这类 `.ogg` 文件不能直接写成 scenario 播放路径：

```lua
player.play_sound{path="__base__/sound/fight/submachine-gunshot.ogg"}
```

要使用这类声音，有三种明确方式：

- 让游戏行为自然触发，例如真的开火、建造、拆除、运行机器。
- 找到它是否同时存在已注册 `SoundPath`，例如 `utility/...` 或本文档已确认的 `tile-build-small/concrete`。
- 做成完整 mod，在 data 阶段把目标 `.ogg` 注册成 sound prototype，然后 runtime 播放注册后的名称。

## `.ogg` 文件为什么不能直接全用

这些目录里有大量音频资源：

- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\core\sound\`
- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\base\sound\`
- `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\space-age\sound\`

它们是数据阶段给原型使用的资源文件。完整 mod 可以在 data 阶段注册：

```lua
data:extend{
  {
    type = "sound",
    name = "my_custom_sound",
    filename = "__my_mod__/sound/my.ogg",
    volume = 0.8
  }
}
```

然后 runtime 才能播放注册后的声音。普通 scenario 只有 runtime 脚本，没有 data 阶段，所以不能新增这类注册。
