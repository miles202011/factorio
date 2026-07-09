# Factorio 原生 GUI 样式参考

## 关键文件位置

| 文件 | 说明 |
|------|------|
| `data/core/prototypes/style.lua` | 所有 GUI 元素的样式定义 |
| `data/core/prototypes/utility-constants.lua` | 游戏内置常量（列数、尺寸等） |
| `data/base/prototypes/item-groups.lua` | 物品分组（group / subgroup）定义 |

路径前缀：`D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\`

---

## 制作菜单核心参数（utility-constants.lua）

```lua
slot_size               = 40   -- 单个物品槽宽高（px）
slot_table_column_count = 10   -- 物品槽每行列数
select_slot_row_count   = 10   -- 配方/物品选择器每行列数
select_group_row_count  = 6    -- 物品分类标签每行列数
crafting_queue_slots_per_row = 10
```

---

## 制作菜单相关样式名（style.lua）

| 样式名 | 类型 | 尺寸 | 用途 |
|--------|------|------|------|
| `slot_button` | button_style | 40×40 | 标准物品槽按钮 |
| `slot_table` | table_style | — | 物品槽表格（间距均为 0） |
| `filter_slot_table` | table_style | — | parent=slot_table，wide_as_column_count=true |
| `filter_group_button_tab_slightly_larger` | button_style | 75×76 | 制作菜单分类图标按钮（**可用于 sprite-button**） |
| `filter_group_tab` | tab_style | h=72, min_w=71 | 制作菜单分类标签（用于 tab 元素） |

> **注意**：
> - `filter_group_button_tab`（不带 _slightly_larger）在 Factorio 2.x 中**不存在**
> - `small_button` 在 Factorio 2.x 中**不存在**；需要紧凑文字按钮时用 `button` 样式并手动覆盖 `minimal_width`、`height`、`padding`

---

## 制作菜单整体宽度推算

- 分类标签行：6 × 75 = **450 px**
- 物品格行：10 × 40 + 16（滚动条）= **416 px**
- 左栏宽度取两者较大值：**450 px**

---

## 手动合成分类（重要）

制作菜单是 **C++ 实现**，无 Lua 源码可查。
可手搓的配方分类应从角色原型动态获取，不要硬编码：

```lua
local char = prototypes.entity["character"]
local HAND_CRAFT = char and char.crafting_categories
    or {["crafting"]=true, ["basic-crafting"]=true, ["advanced-crafting"]=true}
```

Space Age 新增了额外的可手搓分类（如 `organic-or-hand-crafting`），硬编码三个分类会导致这些物品在面板中缺失。
