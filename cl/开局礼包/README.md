# 开局礼包 开发笔记

## 文件性质

这是**场景替换文件**（scenario control.lua），不是 mod。放在场景目录下覆盖 freeplay 的 control.lua。
这一点决定了所有事件注册的写法。

## event_handler 集成（核心）

freeplay 使用 `data/core/lualib/event_handler.lua` 做链式事件分发。
该系统在 `script.on_init` / `script.on_load` 上设置了总调度函数，遍历调用所有已注册 lib 的处理器。

**错误做法**：直接调用 `script.on_event` 和 `script.on_init`
→ 会覆盖 event_handler 的总调度函数，导致 freeplay 的逻辑全部丢失。

**正确做法**：
```lua
require('__base__/script/freeplay/control.lua')  -- freeplay 注册自己的 lib
local handler = require("event_handler")          -- 拿到同一缓存实例
handler.add_lib({ events = {...}, on_init = ... }) -- 并入链，双方都会被调用
```

Lua 的 `require` 有 `package.loaded` 缓存，同一运行期内多次 require 同一路径返回同一个 table。

## 版本兼容

```lua
local function get_store()
    if storage ~= nil then return storage end  -- Factorio 2.x
    return global                               -- Factorio 1.x
end
```

## 礼包防重复机制

`store.gifted_players[player.name] = true` 持久化进存档。
`on_player_joined_game` 每次进入会话都触发（含重连），内部 gifted 检查保证不重复发放。
`on_player_created` 覆盖首次创建玩家的场景。

## 装甲格容量

- power-armor → medium-equipment-grid：**6×8 = 48 格**
- power-armor-mk2 → large-equipment-grid：10×10 = 100 格

| 装备 | 尺寸 | 格数 |
|------|------|------|
| fission-reactor-equipment ×1 | 4×4 | 16 |
| exoskeleton-equipment ×2 | 2×4 | 16 |
| personal-roboport-equipment ×2 | 2×2 | 8 |
| belt-immunity-equipment ×1 | 1×1 | 1 |
| battery-mk2-equipment ×1 | 1×2 | 2 |
| night-vision-equipment ×1 | 2×2 | 4 |
| **合计** | | **47 / 48**（当前给 power-armor） |

⚠ 47 格挤入 48 格，grid.put() 贪心放置模拟验证可行，剩 1 格。余量极小，新增装备前需重新验算。
