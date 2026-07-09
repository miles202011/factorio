# 斗地主音效参考

这份文档只讲斗地主当前怎么用音效，不重复列完整可播放路径。完整已注册路径见 [registered_sounds.md](./registered_sounds.md)。

## 当前实现

- 音效统一由 `ddz_sound.lua` 封装。
- 场景里实际播放的是已注册的 `utility/...` 路径，以及一条已确认的 `tile-build-small/concrete`。
- 每个玩家都可以单独开关声音。
- 按桌广播的音效和个人按钮反馈是分开的。

## 当前常用映射

| 场景 | 当前音效 | 说明 |
| --- | --- | --- |
| 普通按钮、选牌 | `utility/gui_click` | 轻量点击反馈 |
| 声音开关、托管开关 | `utility/gui_switch` | 开关感明确 |
| 点击手牌 | `utility/inventory_click` | 像点中物品 |
| 提示成功选牌 | `utility/smart_pipette` | 像自动选中 |
| 提示无牌可出 | `utility/cannot_build` | 明确表示不行 |
| 轮到自己 | `utility/new_objective` | 醒目提醒 |
| 出牌 | `utility/drop_item` | 像牌落桌 |
| 跳过 | `utility/list_box_click` | 轻提示 |
| 叫分 | `utility/confirm` | 确认感 |
| 发牌 | `utility/item_spawned` | 新东西出现 |
| 地主确认 | `utility/research_completed` | 阶段完成感 |
| 炸弹 | `utility/build_large` | 厚重冲击 |
| 火箭 | `utility/build_huge` | 更重一级 |
| 超时托管 | `utility/alert_destroyed` | 强警告 |
| 导出 | `utility/entity_settings_pasted` | 写入/导出感 |
| 胜利 | `utility/game_won` | 正反馈 |
| 失败 | `utility/game_lost` | 负反馈 |

## 测试工具

`ddz_sound.lua` 里还有一整套测试按钮分组，用来试听：

- `ddz`
- `gui`
- `result`
- `item`
- `build`
- `deconstruct`
- `rotate`
- `equipment`
- `world`
- `wire`
- `tile`

其中 `tile` 组目前只确认了一条：`tile-build-small/concrete`。

## 备注

- 普通 scenario 不能把未注册 `.ogg` 文件路径直接拿来 `player.play_sound`。
- 如果以后改成完整 mod，才适合在 data 阶段扩展新的声音原型。
