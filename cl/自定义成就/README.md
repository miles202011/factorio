# 自定义成就

## 文件性质

这是 Factorio 2.x scenario 用的 `control.lua`，不是完整 mod。脚本在运行时模拟“自定义成就弹窗”，不会注册新的原版 achievement prototype。

## 文件

- `control.lua`：场景脚本主体。
- `README.md`：功能说明和维护记录。

## 事件注册方式

脚本先加载：

```lua
require('__base__/script/freeplay/control.lua')
local handler = require('event_handler')
```

然后用 `handler.add_lib` 追加事件，避免直接覆盖 freeplay 场景自带事件。

## 核心逻辑

`ACHIEVEMENTS` 是成就配置表。每个成就包含：

```lua
{
    id = 'welcome',
    title = '初来乍到',
    description = '第一次进入这个场景。',
    icon = 'achievement/you-are-doing-it-right',
    hidden = false
}
```

解锁时调用 `unlock_achievement(player, achievement_id)`：

- 检查成就是否存在。
- 检查玩家是否已经解锁，避免重复弹窗。
- 写入 `storage.custom_achievements.players[player.index]`。
- 在左侧 GUI 弹出成就提示。
- 播放 `utility/achievement_unlocked`。
- 如果成就列表面板已打开，则刷新面板。

## 默认成就

- `welcome`：第一次进入场景。
- `first_build`：第一次建造实体。
- `first_mine`：第一次手动采矿。
- `first_kill`：第一次击杀敌对单位。
- `first_death`：第一次死亡。
- `first_research`：第一次完成科技研究。
- `manual_test`：测试成就。

## GUI

进入场景后，顶部会出现一个成就按钮。点击后打开成就列表：

- 显示已解锁数量。
- 每项显示图标、标题、描述、状态。
- 管理员可以在面板里重置自己的成就记录。
- 可点击“测试弹窗”触发测试成就。

## 命令

- `/ach_test`：给自己解锁测试成就。
- `/ach_list`：在聊天栏列出自己的成就状态。
- `/ach_reset`：管理员重置自己的成就记录。

## 关键数据表

持久化数据保存在：

```lua
storage.custom_achievements = {
    players = {
        [player_index] = {
            unlocked = {
                [achievement_id] = true
            },
            unlocked_order = {
                {id = achievement_id, tick = game.tick}
            }
        }
    },
    alerts = {},
    next_alert_id = 1
}
```

## 自定义图标

`icon` 可以使用原版 sprite，例如：

```lua
icon = 'achievement/golem'
```

也可以使用场景文件里的图片，例如：

```lua
icon = 'file/png/phibee.png'
```

如果使用 `file/png/xxx.png`，需要把对应图片目录一起放进 scenario 目录。

当前默认图标：

```lua
local DEFAULT_ICON = 'file/png/phibee.png'
```

图片来源：

`D:\桌面\factorio\图片\菲比表情包-菲比啾比.webp`

已转换为：

`png/phibee.png`

## 对外接口

其它脚本可以通过 remote interface 解锁成就：

```lua
remote.call('custom_achievements', 'unlock', player.index, 'welcome')
```

接口：

- `unlock(player_index, achievement_id)`：解锁指定成就，返回是否成功解锁。
- `reset_player(player_index)`：重置指定玩家成就。
- `list()`：返回成就配置表。

## 同步位置

运行文件同步到：

`C:\Users\王\AppData\Roaming\Factorio\scenarios\自定义成就\`

当前同步内容：

- `control.lua`
- `png/phibee.png`
- `locale/zh-CN/freeplay.cfg`
- `locale/en/freeplay.cfg`

## 维护记录

- 修复成就列表面板只显示标题和按钮、不显示成就条目的问题：列表滚动区现在有固定最小高度，并在创建面板时直接填充内容。
- 将默认成就图标改为 `file/png/phibee.png`；弹窗图标和列表图标显示尺寸都改为 `64`。
- 补充 freeplay 开场本地化文本，修复过场动画结束后显示 `Unknown key: "msg-intro-space-age"` 的问题。
