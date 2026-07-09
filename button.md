# Factorio 按钮类型和功能索引

生成时间：2026-07-08  
范围：Factorio 2.1.9 运行时 GUI API，以及本机 `D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\core\prototypes\style.lua` 中的按钮类样式。  
用途：给场景脚本、mod、教学 GUI 写按钮时查阅。

## 先区分：控件类型和样式

Factorio 里“按钮”有两层含义：

1. GUI 控件类型：写在 `LuaGuiElement.add{ type = "..." }` 里的类型，决定它能做什么、触发什么事件。
2. 样式：写在 `style = "..."` 里的外观名，决定颜色、大小、边框、图标对齐、按下效果等。样式本身不执行业务逻辑。

按钮点击后的功能由脚本事件决定，最常用的是：

```lua
script.on_event(defines.events.on_gui_click, function(event)
  if event.element and event.element.valid and event.element.name == "my_button" then
    -- 在这里写按钮功能
  end
end)
```

## GUI 按钮/按钮类控件

| 控件类型 | 主要功能 | 常用事件 | 典型用途 |
|---|---|---|---|
| `button` | 普通文字按钮，可带 `caption`、`tooltip`、`style`。 | `on_gui_click` | 确认、取消、打开窗口、执行命令。 |
| `sprite-button` | 图片按钮，显示 `sprite`，可带数字、提示、不同按钮样式。 | `on_gui_click` | 工具栏图标、物品/实体图标按钮、快捷入口。 |
| `choose-elem-button` | 原型选择按钮，点开游戏内置选择器，让玩家选择物品、流体、信号、实体等。 | `on_gui_elem_changed` | 配置物品过滤器、选择传送目标、选择科技/配方/信号。 |
| `checkbox` | 方形勾选框，保存 true/false 状态。 | `on_gui_checked_state_changed` | 开关配置项、启用/禁用功能。 |
| `radiobutton` | 圆形单选按钮。Factorio 不会自动把同组其它按钮取消，需要脚本维护互斥。 | `on_gui_checked_state_changed` | 多个模式中选一个。 |
| `switch` | 三态切换器，可有左、中、右状态和两侧标签。 | `on_gui_switch_state_changed` | 左/右模式切换、自动/手动/关闭。 |
| `drop-down` | 下拉列表，从多个文本项中选一个。 | `on_gui_selection_state_changed` | 选择难度、分组、排序模式、星球等。 |
| `list-box` | 列表选择器，一次选择一个文本项。 | `on_gui_selection_state_changed` | 玩家列表、车站列表、存档列表、可滚动选项。 |
| `tab` | 标签按钮，配合 `tabbed-pane` 使用。 | `on_gui_selected_tab_changed` | 多页面面板：设置、统计、商店、日志。 |
| `slider` | 滑块，选择数值。不是按钮，但包含可拖动按钮样式。 | `on_gui_value_changed` | 数量、比例、音量、阈值。 |
| `textfield` / `text-box` | 文本输入。不是按钮，但常和确认按钮一起使用。 | `on_gui_text_changed`、`on_gui_confirmed` | 搜索、输入数值、输入名称。 |

## `choose-elem-button` 可选择的元素类型

`choose-elem-button` 的 `elem_type` 决定玩家能选择什么：

| `elem_type` | 功能 |
|---|---|
| `achievement` | 选择成就原型。 |
| `decorative` | 选择装饰物原型。 |
| `entity` | 选择实体原型。 |
| `equipment` | 选择装备原型。 |
| `fluid` | 选择流体原型。 |
| `item` | 选择物品原型。 |
| `item-group` | 选择物品分组。 |
| `recipe` | 选择配方原型。 |
| `signal` | 选择信号，包含物品、流体、虚拟信号等。 |
| `technology` | 选择科技原型。 |
| `tile` | 选择地砖原型。 |
| `asteroid-chunk` | 选择太空时代的小行星块原型。 |
| `space-location` | 选择太空位置/星球原型。 |
| `item-with-quality` | 选择带品质的物品。 |
| `entity-with-quality` | 选择带品质的实体。 |
| `recipe-with-quality` | 选择带品质的配方。 |
| `equipment-with-quality` | 选择带品质的装备。 |

## 常用功能写法

| 目标 | 推荐控件 | 说明 |
|---|---|---|
| 点一下执行动作 | `button` | 文字清楚时用普通按钮。 |
| 点图标执行动作 | `sprite-button` | 用 `sprite = "item/iron-plate"`、`sprite = "utility/..."` 等。 |
| 选择游戏原型 | `choose-elem-button` | 比手写搜索框更接近原版体验。 |
| 开关功能 | `checkbox` 或 `switch` | 简单 true/false 用 `checkbox`；两个/三个模式用 `switch`。 |
| 多选一 | `radiobutton`、`drop-down` 或 `list-box` | 选项少且要显眼用 `radiobutton`；选项多用下拉或列表。 |
| 选择数字 | `slider` | 精确数值通常再配一个 `textfield`。 |
| 顶部入口按钮 | `sprite-button` | 通常放在 `mod-gui` 的 button flow。 |
| 物品格/库存格外观 | `sprite-button` + `slot` 类样式 | 自定义库存、商店、奖励列表常用。 |

## 运行时事件对照

| 事件 | 由哪些控件常触发 | 用途 |
|---|---|---|
| `on_gui_click` | `button`、`sprite-button`、很多可点击控件 | 处理普通点击。 |
| `on_gui_elem_changed` | `choose-elem-button` | 玩家选中的原型变更。 |
| `on_gui_checked_state_changed` | `checkbox`、`radiobutton` | 勾选状态变化。 |
| `on_gui_switch_state_changed` | `switch` | 开关状态变化。 |
| `on_gui_selection_state_changed` | `drop-down`、`list-box` | 列表选择变化。 |
| `on_gui_selected_tab_changed` | `tabbed-pane` / `tab` | 标签页变化。 |
| `on_gui_value_changed` | `slider` | 数值变化。 |
| `on_gui_confirmed` | `textfield`、`text-box` | 玩家在输入框按确认键。 |
| `on_gui_hover` / `on_gui_leave` | 多数 GUI 元素 | 悬停提示、动态预览。 |
| `on_gui_opened` / `on_gui_closed` | 游戏打开/关闭某些 GUI | 初始化或清理界面。 |

## 本机 `style.lua` 中的按钮类样式和功能

下面是本机核心样式文件中筛出的 150 个按钮/按钮相关样式。它们大多可以直接用于 `button` 或 `sprite-button`，部分是下拉框、列表、表格、滚动条、滑块等控件内部使用的按钮样式。

| # | 样式名 | 父样式 | 推荐功能/含义 |
|---:|---|---|---|
| 1 | `button` | 无 | 标准普通按钮根样式，绝大多数按钮样式的基础。 |
| 2 | `green_button` | `button` | 绿色确认/正向操作按钮。 |
| 3 | `rounded_button` | 无 | 圆角按钮，常用于控制设置或图标按钮。 |
| 4 | `back_button` | `dialog_button` | 返回、上一步、关闭预览。 |
| 5 | `red_back_button` | `dialog_button` | 红色返回/危险返回按钮。 |
| 6 | `confirm_button` | `dialog_button` | 确认、继续、应用。 |
| 7 | `confirm_button_without_tooltip` | `confirm_button` | 没有内置提示的确认按钮。 |
| 8 | `confirm_double_arrow_button` | `dialog_button` | 双箭头确认/前进按钮。 |
| 9 | `map_generator_preview_button` | `forward_button` | 地图生成器预览按钮。 |
| 10 | `map_generator_close_preview_button` | `back_button` | 关闭地图生成器预览。 |
| 11 | `map_generator_confirm_button` | `confirm_double_arrow_button` | 地图生成器确认。 |
| 12 | `confirm_in_load_game_button` | `confirm_button` | 载入游戏界面的确认按钮，可压缩宽度。 |
| 13 | `red_confirm_button` | `dialog_button` | 红色确认，通常表示删除、覆盖、危险确认。 |
| 14 | `red_button` | `button` | 通用红色按钮。 |
| 15 | `tool_button_red` | `red_button` | 红色工具图标按钮。 |
| 16 | `tool_button_flush_fluid` | `tool_button_red` | 排空流体类危险工具按钮。 |
| 17 | `tool_button` | 无 | 标准工具栏按钮。 |
| 18 | `tool_button_without_padding` | `tool_button` | 无内边距工具按钮，适合纯图标。 |
| 19 | `tool_button_green` | `tool_button` | 绿色工具按钮，表示启用或正向工具。 |
| 20 | `tool_button_blue` | `tool_button` | 蓝色工具按钮，表示信息、选择或特殊工具。 |
| 21 | `mini_tool_button_red` | `red_button` | 小号红色工具按钮。 |
| 22 | `mini_button` | 无 | 小号按钮。 |
| 23 | `mini_button_aligned_to_text_vertically` | 无 | 与文本垂直对齐的小按钮。 |
| 24 | `mini_button_aligned_to_text_vertically_when_centered` | 无 | 文本居中布局中垂直对齐的小按钮。 |
| 25 | `highlighted_tool_button` | `tool_button` | 高亮工具按钮。 |
| 26 | `switch` | 无 | 三态/切换开关控件样式。 |
| 27 | `dialog_button` | `button` | 对话框底部按钮基础样式。 |
| 28 | `menu_button` | `button` | 主菜单按钮。 |
| 29 | `menu_button_continue` | `menu_button` | 主菜单继续游戏按钮。 |
| 30 | `side_menu_button` | `button` | 侧边菜单图标按钮。 |
| 31 | `map_view_add_button` | `slot_sized_button` | 地图视图添加按钮。 |
| 32 | `image_tab_slot` | `slot_sized_button` | 图片标签页未选中槽位。 |
| 33 | `image_tab_selected_slot` | `slot_sized_button_pressed` | 图片标签页选中槽位。 |
| 34 | `red_circuit_network_content_slot` | `compact_slot` | 红线电路网络内容槽。 |
| 35 | `green_circuit_network_content_slot` | `compact_slot` | 绿线电路网络内容槽。 |
| 36 | `compact_slot` | `button` | 紧凑物品/信号槽。 |
| 37 | `slot` | `button` | 标准物品槽按钮。 |
| 38 | `red_slot` | `slot` | 红色物品槽，常表示错误、不可用、危险。 |
| 39 | `yellow_slot` | `slot` | 黄色物品槽，常表示警告或部分满足。 |
| 40 | `green_slot` | `slot` | 绿色物品槽，常表示可用或已满足。 |
| 41 | `blue_slot` | `slot` | 蓝色物品槽，常表示过滤器或特殊选择。 |
| 42 | `tool_equip_ammo_slot` | `slot` | 工具/装备/弹药槽。 |
| 43 | `inventory_slot` | `slot` | 背包库存槽。 |
| 44 | `filter_inventory_slot` | `blue_slot` | 库存过滤器槽。 |
| 45 | `closed_inventory_slot` | `slot` | 关闭/锁定库存槽。 |
| 46 | `red_inventory_slot` | `inventory_slot` | 红色库存槽。 |
| 47 | `yellow_inventory_slot` | `inventory_slot` | 黄色库存槽。 |
| 48 | `research_queue_cancel_button` | `red_button` | 取消研究队列按钮。 |
| 49 | `transparent_button` | `button` | 透明背景按钮。 |
| 50 | `transparent_slot` | `transparent_button` | 透明物品槽/图标槽。 |
| 51 | `universe_planet_button` | `transparent_slot` | 宇宙视图星球按钮。 |
| 52 | `universe_connection_button` | 无 | 宇宙视图连接线按钮。 |
| 53 | `universe_platform_button` | `transparent_slot` | 宇宙视图平台按钮。 |
| 54 | `frame_button` | `button` | 窗口标题栏/框架上的图标按钮。 |
| 55 | `frame_action_button` | `frame_button` | 标题栏动作按钮，如关闭、取消。 |
| 56 | `blueprint_record_slot_button` | `inventory_slot` | 蓝图记录槽按钮。 |
| 57 | `blueprint_record_selection_button` | `big_slot_button` | 蓝图记录选择按钮。 |
| 58 | `drop_target_button` | 无 | 拖放目标按钮。 |
| 59 | `compact_red_slot` | `compact_slot` | 紧凑红色槽。 |
| 60 | `inventory_limit_slot_button` | `slot_sized_button` | 背包限制槽按钮。 |
| 61 | `working_weapon_button` | `green_slot` | 当前可用武器槽。 |
| 62 | `not_working_weapon_button` | `red_slot` | 当前不可用武器槽。 |
| 63 | `omitted_technology_slot` | 无 | 被省略/隐藏的科技槽。 |
| 64 | `crafting_queue_slot` | 无 | 制造队列槽。 |
| 65 | `promised_crafting_queue_slot` | `crafting_queue_slot` | 已承诺/等待材料的制造队列槽。 |
| 66 | `control_settings_button` | `rounded_button` | 控制设置按钮。 |
| 67 | `control_settings_section_button` | `tool_button` | 控制设置分区按钮。 |
| 68 | `dropdown_button` | 无 | 下拉框内部按钮。 |
| 69 | `dropdown` | 无 | 下拉框整体样式。 |
| 70 | `game_controller_icons_dropdown` | `dropdown` | 手柄图标选择下拉框。 |
| 71 | `circuit_condition_comparator_dropdown` | 无 | 电路条件比较符下拉框。 |
| 72 | `not_accessible_station_in_station_selection` | `list_box_item` | 车站选择中不可达车站项。 |
| 73 | `partially_accessible_station_in_station_selection` | `list_box_item` | 车站选择中部分可达车站项。 |
| 74 | `new_game_header_list_box_item` | `list_box_item` | 新游戏界面列表标题项。 |
| 75 | `list_box_item` | 无 | 列表框条目按钮样式。 |
| 76 | `train_status_button` | `list_box_item` | 火车状态列表按钮。 |
| 77 | `station_train_status_button` | `list_box_item` | 车站火车状态按钮。 |
| 78 | `title_tip_item` | `list_box_item` | 标题提示条目。 |
| 79 | `list_box` | 无 | 列表框整体样式。 |
| 80 | `item_and_count_select_confirm` | `green_button` | 物品和数量选择确认按钮。 |
| 81 | `filter_group_button_tab_slightly_larger` | 无 | 稍大的过滤器分组标签按钮。 |
| 82 | `button_with_shadow` | 无 | 带阴影按钮。 |
| 83 | `train_schedule_add_wait_condition_button` | `button_with_shadow` | 火车时刻表添加等待条件。 |
| 84 | `train_schedule_add_interrupt_station_button` | `button_with_shadow` | 火车时刻表添加中断车站。 |
| 85 | `train_schedule_add_station_button` | `button_with_shadow` | 火车时刻表添加车站。 |
| 86 | `train_schedule_action_button` | 无 | 火车时刻表动作按钮。 |
| 87 | `train_schedule_comparison_type_button` | 无 | 火车时刻表比较类型按钮。 |
| 88 | `minimap_slot` | `button` | 小地图槽按钮。 |
| 89 | `locomotive_minimap_button` | `button` | 机车小地图按钮。 |
| 90 | `target_station_in_schedule_in_train_view_list_box_item` | `list_box_item` | 火车视图时刻表目标车站项。 |
| 91 | `no_path_station_in_schedule_in_train_view_list_box_item` | `list_box_item` | 火车视图无路径车站项。 |
| 92 | `default_permission_group_list_box_item` | `list_box_item` | 默认权限组列表项。 |
| 93 | `table` | 无 | 表格样式，包含列排序按钮样式。 |
| 94 | `browse_games_gui_toggle_favorite_on_button` | 无 | 浏览游戏界面：收藏开启按钮。 |
| 95 | `browse_games_gui_toggle_favorite_off_button` | 无 | 浏览游戏界面：收藏关闭按钮。 |
| 96 | `mods_filter_exclude_button` | `transparent_slot` | Mod 过滤排除按钮。 |
| 97 | `cancel_close_button` | `frame_action_button` | 取消/关闭按钮。 |
| 98 | `close_button` | `frame_action_button` | 关闭窗口按钮。 |
| 99 | `lab_research_info_button` | 无 | 实验室研究信息按钮。 |
| 100 | `current_research_info_button` | 无 | 当前研究信息按钮。 |
| 101 | `open_armor_button` | `forward_button` | 打开护甲界面按钮。 |
| 102 | `quick_bar_page_button` | `button` | 快捷栏页按钮。 |
| 103 | `tool_bar_open_button` | `quick_bar_page_button` | 打开工具栏按钮。 |
| 104 | `dark_rounded_button` | 无 | 深色圆角按钮。 |
| 105 | `train_schedule_item_select_button` | `dark_rounded_button` | 火车时刻表项目选择按钮。 |
| 106 | `train_schedule_fulfilled_item_select_button` | `train_schedule_item_select_button` | 条件满足的时刻表项目选择按钮。 |
| 107 | `train_schedule_partially_fulfilled_item_select_button` | `train_schedule_fulfilled_item_select_button` | 条件部分满足的时刻表项目选择按钮。 |
| 108 | `slot_button` | `button` | 槽位按钮基础样式。 |
| 109 | `big_slot_button` | `button` | 大槽位按钮。 |
| 110 | `slot_button_in_shallow_frame` | `slot_button` | 浅框架里的槽位按钮。 |
| 111 | `yellow_slot_button` | `slot_button` | 黄色槽位按钮。 |
| 112 | `red_slot_button` | `slot_button` | 红色槽位按钮。 |
| 113 | `slot_sized_button` | `button` | 标准槽尺寸按钮。 |
| 114 | `compact_slot_sized_button` | `slot_sized_button` | 紧凑槽尺寸按钮。 |
| 115 | `slot_sized_button_pressed` | `button` | 按下状态的槽尺寸按钮。 |
| 116 | `slot_sized_button_blue` | `slot_sized_button` | 蓝色槽尺寸按钮。 |
| 117 | `slot_sized_button_red` | `slot_sized_button` | 红色槽尺寸按钮。 |
| 118 | `slot_sized_button_green` | `slot_sized_button` | 绿色槽尺寸按钮。 |
| 119 | `shortcut_bar_button` | `slot_sized_button` | 快捷栏按钮。 |
| 120 | `shortcut_bar_button_blue` | `slot_sized_button_blue` | 蓝色快捷栏按钮。 |
| 121 | `shortcut_bar_button_red` | `slot_sized_button_red` | 红色快捷栏按钮。 |
| 122 | `shortcut_bar_button_green` | `slot_sized_button_green` | 绿色快捷栏按钮。 |
| 123 | `shortcut_bar_button_small` | `slot_sized_button` | 小号快捷栏按钮。 |
| 124 | `shortcut_bar_button_small_green` | `slot_sized_button_green` | 小号绿色快捷栏按钮。 |
| 125 | `shortcut_bar_button_small_red` | `slot_sized_button_red` | 小号红色快捷栏按钮。 |
| 126 | `shortcut_bar_button_small_blue` | `slot_sized_button_blue` | 小号蓝色快捷栏按钮。 |
| 127 | `horizontal_scrollbar` | 无 | 横向滚动条样式，内部包含按钮。 |
| 128 | `vertical_scrollbar` | 无 | 纵向滚动条样式，内部包含按钮。 |
| 129 | `slider_button` | 无 | 滑块按钮基础样式。 |
| 130 | `left_slider_button` | `slider_button` | 双滑块左侧按钮。 |
| 131 | `right_slider_button` | `slider_button` | 双滑块右侧按钮。 |
| 132 | `slider` | 无 | 滑块整体样式。 |
| 133 | `notched_slider` | `slider` | 带刻度滑块。 |
| 134 | `double_slider` | 无 | 双端滑块。 |
| 135 | `entity_variation_button` | 无 | 实体变体按钮。 |
| 136 | `tile_variation_button` | 无 | 地砖变体按钮。 |
| 137 | `train_schedule_fulfilled_delete_button` | `train_schedule_delete_button` | 删除已满足时刻表条件。 |
| 138 | `train_schedule_partially_fulfilled_delete_button` | `train_schedule_delete_button` | 删除部分满足时刻表条件。 |
| 139 | `train_schedule_temporary_station_delete_button` | `train_schedule_delete_button` | 删除临时车站。 |
| 140 | `other_settings_gui_button` | `button` | 其它设置界面按钮。 |
| 141 | `dark_button` | 无 | 深色按钮。 |
| 142 | `train_schedule_delete_button` | `dark_button` | 火车时刻表删除按钮。 |
| 143 | `train_schedule_collapse_button` | `train_schedule_delete_button` | 火车时刻表折叠按钮。 |
| 144 | `train_schedule_condition_time_selection_button` | 无 | 火车时刻表时间条件选择按钮。 |
| 145 | `shortcut_bar_expand_button` | `frame_button` | 快捷栏展开按钮。 |
| 146 | `choose_chat_icon_button` | 无 | 聊天图标选择按钮。 |
| 147 | `choose_chat_icon_in_textbox_button` | 无 | 输入框内聊天图标选择按钮。 |
| 148 | `decider_combinator_signal_select_button` | `slot_button_in_shallow_frame` | 判断运算器信号选择按钮。 |
| 149 | `decider_combinator_fulfilled_signal_select_button` | `slot_button_in_shallow_frame` | 判断运算器已满足信号选择按钮。 |
| 150 | `add_logistic_section_button` | 无 | 添加物流分区按钮。 |

## 样式选择建议

| 场景 | 推荐样式 |
|---|---|
| 普通动作 | `button`、`dialog_button` |
| 确认/正向动作 | `green_button`、`confirm_button` |
| 删除/危险动作 | `red_button`、`red_confirm_button`、`tool_button_red` |
| 工具栏图标 | `tool_button`、`tool_button_green`、`tool_button_blue`、`tool_button_red` |
| 小图标按钮 | `mini_button`、`mini_tool_button_red` |
| 窗口标题栏 | `frame_button`、`frame_action_button`、`close_button` |
| 物品/信号槽 | `slot`、`inventory_slot`、`slot_button`、`slot_sized_button` |
| 紧凑物品槽 | `compact_slot`、`compact_slot_sized_button` |
| 快捷栏 | `shortcut_bar_button`、`shortcut_bar_button_small` 及颜色变体 |
| 透明图标 | `transparent_button`、`transparent_slot` |
| 下拉/列表 | `dropdown`、`dropdown_button`、`list_box`、`list_box_item` |
| 火车时刻表 | `train_schedule_*` 系列 |
| 滑块/滚动条 | `slider`、`slider_button`、`horizontal_scrollbar`、`vertical_scrollbar` |

## 资料来源

- Factorio Runtime Docs：`GuiElementType`、`ElemType`、`LuaGuiElement`、GUI 事件。
- Factorio Prototype Docs：`ButtonStyleSpecification`。
- 本机文件：`D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\core\prototypes\style.lua`。
- 本目录已有索引：`D:\桌面\factorio\factorio_button_styles.md`。
