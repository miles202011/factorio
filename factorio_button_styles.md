# Factorio 按钮样式完整索引

- 来源文件：`D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio\data\core\prototypes\style.lua`
- 生成范围：所有直接定义 `type = "button_style"` 的样式
- 数量：150
- 说明：每个样式条目里的“直接属性”只列当前样式表自己写出的属性；通过 `parent` 继承得到的属性不在该条目重复展开。

## 属性解释

| 属性 | 含义 |
|---|---|
| `type` | 样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。 |
| `font` | 按钮文字字体。 |
| `horizontal_align` | 文字或内容水平方向对齐。 |
| `vertical_align` | 文字或内容垂直方向对齐。 |
| `icon_horizontal_align` | 图标水平方向对齐。 |
| `ignored_by_search` | 是否被样式搜索或调试搜索忽略。 |
| `top_padding` | 上内边距。 |
| `bottom_padding` | 下内边距。 |
| `left_padding` | 左内边距。 |
| `right_padding` | 右内边距。 |
| `minimal_width` | 最小宽度。 |
| `minimal_height` | 最小高度。 |
| `default_font_color` | 默认状态文字颜色。 |
| `default_graphical_set` | 默认状态外观图形集。 |
| `hovered_font_color` | 鼠标悬停时文字颜色。 |
| `hovered_graphical_set` | 鼠标悬停状态外观图形集。 |
| `clicked_font_color` | 按下时文字颜色。 |
| `clicked_vertical_offset` | 按下按钮时文字或图标向下偏移量。 |
| `clicked_graphical_set` | 按下状态外观图形集。 |
| `disabled_font_color` | 禁用状态文字颜色。 |
| `disabled_graphical_set` | 禁用状态外观图形集。 |
| `selected_font_color` | 选中状态文字颜色。 |
| `selected_graphical_set` | 选中状态外观图形集。 |
| `selected_hovered_font_color` | 选中且悬停时文字颜色。 |
| `selected_hovered_graphical_set` | 选中且悬停状态外观图形集。 |
| `selected_clicked_font_color` | 选中且按下时文字颜色。 |
| `selected_clicked_graphical_set` | 选中且按下状态外观图形集。 |
| `strikethrough_color` | 文字删除线颜色。 |
| `pie_progress_color` | 按钮上饼形进度覆盖层颜色。 |
| `left_click_sound` | 左键点击音效。 |
| `parent` | 继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。 |
| `tooltip` | 悬停提示文本或本地化键。 |
| `width` | 固定宽度。 |
| `natural_width` | 自然宽度。 |
| `horizontally_squashable` | 水平方向可压缩设置。 |
| `padding` | 四边统一内边距。 |
| `size` | 固定宽高相等的尺寸。 |
| `invert_colors_of_picture_when_disabled` | 禁用状态时是否反转图片颜色。 |
| `height` | 固定高度。 |
| `top_margin` | 上外边距。 |
| `active_label` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `inactive_label` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `left_button_position` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `middle_button_position` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `right_button_position` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `default_background` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `hover_background` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `disabled_background` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `button` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `maximal_width` | 最大宽度。 |
| `invert_colors_of_picture_when_hovered_or_toggled` | 悬停或切换状态时是否反转图片颜色。 |
| `draw_shadow_under_picture` | 是否在图片下方绘制阴影。 |
| `selector_and_title_spacing` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `opened_sound` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `button_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `icon` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `list_box_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `scroll_pane_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `item_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `horizontally_stretchable` | 水平方向可拉伸。 |
| `horizontal_spacing` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `vertical_spacing` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `border` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `column_ordering_ascending_button_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `column_ordering_descending_button_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `inactive_column_ordering_ascending_button_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `inactive_column_ordering_descending_button_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `left_margin` | 左外边距。 |
| `margin` | 四边外边距。 |
| `background_graphical_set` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `thumb_button_style` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `full_bar` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `full_bar_disabled` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `empty_bar` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `empty_bar_disabled` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `draw_notches` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `notch` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `high_button` | 此属性出现在按钮样式定义中；具体含义由 Factorio 样式系统解释，通常用于外观、尺寸、对齐、交互状态或控件行为。 |
| `right_margin` | 右外边距。 |
| `bottom_margin` | 下外边距。 |

## 全部按钮样式总表

| # | 样式名 | 行号 | 父样式 | 直接属性 |
|---:|---|---|---|---|
| 1 | `button` | 1033-1094 |  | `type`, `font`, `horizontal_align`, `vertical_align`, `icon_horizontal_align`, `ignored_by_search`, `top_padding`, `bottom_padding`, `left_padding`, `right_padding`, `minimal_width`, `minimal_height`, `default_font_color`, `default_graphical_set`, `hovered_font_color`, `hovered_graphical_set`, `clicked_font_color`, `clicked_vertical_offset`, `clicked_graphical_set`, `disabled_font_color`, `disabled_graphical_set`, `selected_font_color`, `selected_graphical_set`, `selected_hovered_font_color`, `selected_hovered_graphical_set`, `selected_clicked_font_color`, `selected_clicked_graphical_set`, `strikethrough_color`, `pie_progress_color`, `left_click_sound` |
| 2 | `green_button` | 1096-1123 | `button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound`, `tooltip` |
| 3 | `rounded_button` | 1125-1164 |  | `type`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set` |
| 4 | `back_button` | 1166-1175 | `dialog_button` | `type`, `parent`, `horizontal_align`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set` |
| 5 | `red_back_button` | 1177-1187 | `dialog_button` | `type`, `parent`, `horizontal_align`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_font_color`, `disabled_graphical_set` |
| 6 | `confirm_button` | 1201-1212 | `dialog_button` | `type`, `parent`, `horizontal_align`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound`, `tooltip` |
| 7 | `confirm_button_without_tooltip` | 1214-1219 | `confirm_button` | `type`, `parent`, `tooltip` |
| 8 | `confirm_double_arrow_button` | 1221-1231 | `dialog_button` | `type`, `parent`, `horizontal_align`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `tooltip` |
| 9 | `map_generator_preview_button` | 1245-1250 | `forward_button` | `type`, `parent`, `icon_horizontal_align` |
| 10 | `map_generator_close_preview_button` | 1252-1258 | `back_button` | `type`, `parent`, `icon_horizontal_align`, `left_padding` |
| 11 | `map_generator_confirm_button` | 1260-1265 | `confirm_double_arrow_button` | `type`, `parent`, `width` |
| 12 | `confirm_in_load_game_button` | 1267-1273 | `confirm_button` | `type`, `parent`, `natural_width`, `horizontally_squashable` |
| 13 | `red_confirm_button` | 1275-1286 | `dialog_button` | `type`, `parent`, `horizontal_align`, `left_click_sound`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_font_color`, `disabled_graphical_set` |
| 14 | `red_button` | 1288-1314 | `button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound` |
| 15 | `tool_button_red` | 1316-1324 | `red_button` | `type`, `parent`, `padding`, `size`, `left_click_sound`, `invert_colors_of_picture_when_disabled` |
| 16 | `tool_button_flush_fluid` | 1326-1331 | `tool_button_red` | `type`, `parent`, `left_click_sound` |
| 17 | `tool_button` | 1333-1341 |  | `type`, `padding`, `height`, `minimal_width`, `left_click_sound`, `invert_colors_of_picture_when_disabled` |
| 18 | `tool_button_without_padding` | 1343-1348 | `tool_button` | `type`, `parent`, `padding` |
| 19 | `tool_button_green` | 1350-1375 | `tool_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set` |
| 20 | `tool_button_blue` | 1396-1416 | `tool_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 21 | `mini_tool_button_red` | 1418-1425 | `red_button` | `type`, `parent`, `padding`, `size`, `left_click_sound` |
| 22 | `mini_button` | 1427-1433 |  | `type`, `padding`, `size`, `left_click_sound` |
| 23 | `mini_button_aligned_to_text_vertically` | 1435-1442 |  | `type`, `padding`, `size`, `top_margin`, `left_click_sound` |
| 24 | `mini_button_aligned_to_text_vertically_when_centered` | 1444-1451 |  | `type`, `padding`, `size`, `top_margin`, `left_click_sound` |
| 25 | `highlighted_tool_button` | 1453-1463 | `tool_button` | `type`, `parent`, `default_graphical_set` |
| 26 | `switch` | 1599-1635 |  | `type`, `active_label`, `inactive_label`, `width`, `height`, `padding`, `left_button_position`, `middle_button_position`, `right_button_position`, `default_background`, `hover_background`, `disabled_background`, `button` |
| 27 | `dialog_button` | 1637-1649 | `button` | `type`, `font`, `parent`, `default_font_color`, `hovered_font_color`, `clicked_font_color`, `disabled_font_color`, `bottom_padding`, `height`, `minimal_width` |
| 28 | `menu_button` | 1651-1664 | `button` | `type`, `parent`, `font`, `default_font_color`, `hovered_font_color`, `clicked_font_color`, `minimal_width`, `maximal_width`, `minimal_height`, `top_padding`, `bottom_padding` |
| 29 | `menu_button_continue` | 1666-1693 | `menu_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound`, `tooltip` |
| 30 | `side_menu_button` | 1695-1709 | `button` | `type`, `parent`, `default_font_color`, `size`, `padding`, `left_click_sound`, `invert_colors_of_picture_when_hovered_or_toggled`, `default_graphical_set` |
| 31 | `map_view_add_button` | 1711-1717 | `slot_sized_button` | `type`, `parent`, `height`, `width` |
| 32 | `image_tab_slot` | 1728-1733 | `slot_sized_button` | `type`, `parent`, `size` |
| 33 | `image_tab_selected_slot` | 1735-1740 | `slot_sized_button_pressed` | `type`, `parent`, `size` |
| 34 | `red_circuit_network_content_slot` | 1742-1754 | `compact_slot` | `type`, `parent`, `default_graphical_set` |
| 35 | `green_circuit_network_content_slot` | 1756-1768 | `compact_slot` | `type`, `parent`, `default_graphical_set` |
| 36 | `compact_slot` | 1770-1801 | `button` | `type`, `parent`, `size`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `pie_progress_color` |
| 37 | `slot` | 1803-1817 | `button` | `type`, `parent`, `size`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `pie_progress_color`, `left_click_sound` |
| 38 | `red_slot` | 1819-1827 | `slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set` |
| 39 | `yellow_slot` | 1829-1837 | `slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set` |
| 40 | `green_slot` | 1839-1846 | `slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 41 | `blue_slot` | 1848-1855 | `slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 42 | `tool_equip_ammo_slot` | 1857-1916 | `slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set`, `left_click_sound` |
| 43 | `inventory_slot` | 1918-1927 | `slot` | `type`, `parent`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set`, `left_click_sound` |
| 44 | `filter_inventory_slot` | 1929-1934 | `blue_slot` | `type`, `parent`, `left_click_sound` |
| 45 | `closed_inventory_slot` | 1936-1945 | `slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set`, `left_click_sound` |
| 46 | `red_inventory_slot` | 1947-1955 | `inventory_slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set` |
| 47 | `yellow_inventory_slot` | 1957-1965 | `inventory_slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set` |
| 48 | `research_queue_cancel_button` | 2058-2064 | `red_button` | `type`, `parent`, `size`, `padding` |
| 49 | `transparent_button` | 2691-2702 | `button` | `type`, `parent`, `padding`, `default_graphical_set`, `clicked_graphical_set`, `hovered_graphical_set`, `clicked_vertical_offset`, `pie_progress_color`, `left_click_sound` |
| 50 | `transparent_slot` | 2704-2710 | `transparent_button` | `type`, `parent`, `size`, `draw_shadow_under_picture` |
| 51 | `universe_planet_button` | 2728-2733 | `transparent_slot` | `type`, `parent`, `size` |
| 52 | `universe_connection_button` | 2735-2745 |  | `type`, `minimal_width`, `minimal_height`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set` |
| 53 | `universe_platform_button` | 2747-2752 | `transparent_slot` | `type`, `parent`, `size` |
| 54 | `frame_button` | 2754-2790 | `button` | `type`, `parent`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set` |
| 55 | `frame_action_button` | 2793-2800 | `frame_button` | `type`, `parent`, `invert_colors_of_picture_when_hovered_or_toggled`, `size`, `left_click_sound` |
| 56 | `blueprint_record_slot_button` | 2802-2808 | `inventory_slot` | `type`, `parent`, `size`, `padding` |
| 57 | `blueprint_record_selection_button` | 2810-2815 | `big_slot_button` | `type`, `parent`, `padding` |
| 58 | `drop_target_button` | 2842-2917 |  | `type`, `font`, `default_font_color`, `padding`, `default_graphical_set`, `hovered_font_color`, `hovered_graphical_set`, `clicked_font_color`, `clicked_graphical_set`, `disabled_font_color`, `disabled_graphical_set`, `pie_progress_color`, `left_click_sound` |
| 59 | `compact_red_slot` | 2934-2963 | `compact_slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `left_click_sound` |
| 60 | `inventory_limit_slot_button` | 2965-3001 | `slot_sized_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set` |
| 61 | `working_weapon_button` | 3003-3036 | `green_slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `left_click_sound`, `draw_shadow_under_picture` |
| 62 | `not_working_weapon_button` | 3038-3081 | `red_slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set`, `left_click_sound`, `draw_shadow_under_picture` |
| 63 | `omitted_technology_slot` | 3083-3090 |  | `type`, `size`, `padding`, `default_graphical_set`, `hovered_graphical_set` |
| 64 | `crafting_queue_slot` | 3102-3123 |  | `type`, `size`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `pie_progress_color` |
| 65 | `promised_crafting_queue_slot` | 3125-3144 | `crafting_queue_slot` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 66 | `control_settings_button` | 3146-3152 | `rounded_button` | `type`, `parent`, `horizontal_align`, `width` |
| 67 | `control_settings_section_button` | 3175-3181 | `tool_button` | `type`, `parent`, `invert_colors_of_picture_when_hovered_or_toggled`, `default_graphical_set` |
| 68 | `dropdown_button` | 3183-3190 |  | `type`, `padding`, `horizontal_align`, `font`, `left_click_sound` |
| 69 | `dropdown` | 3202-3234 |  | `type`, `ignored_by_search`, `minimal_width`, `minimal_height`, `top_padding`, `bottom_padding`, `left_padding`, `right_padding`, `selector_and_title_spacing`, `opened_sound`, `button_style`, `icon`, `list_box_style` |
| 70 | `game_controller_icons_dropdown` | 3236-3253 | `dropdown` | `type`, `parent`, `list_box_style` |
| 71 | `circuit_condition_comparator_dropdown` | 3255-3316 |  | `type`, `minimal_width`, `left_padding`, `right_padding`, `height`, `button_style`, `list_box_style` |
| 72 | `not_accessible_station_in_station_selection` | 3325-3334 | `list_box_item` | `type`, `parent`, `default_font_color`, `hovered_font_color`, `selected_font_color`, `selected_hovered_font_color`, `selected_clicked_font_color` |
| 73 | `partially_accessible_station_in_station_selection` | 3336-3345 | `list_box_item` | `type`, `parent`, `default_font_color`, `hovered_font_color`, `selected_font_color`, `selected_hovered_font_color`, `selected_clicked_font_color` |
| 74 | `new_game_header_list_box_item` | 3347-3361 | `list_box_item` | `type`, `parent`, `font`, `default_font_color`, `hovered_font_color`, `selected_font_color`, `selected_hovered_font_color`, `selected_clicked_font_color`, `disabled_font_color`, `default_graphical_set`, `hovered_graphical_set`, `disabled_graphical_set` |
| 75 | `list_box_item` | 3363-3380 |  | `type`, `font`, `ignored_by_search`, `minimal_width`, `horizontal_align`, `default_font_color`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_font_color`, `disabled_graphical_set` |
| 76 | `train_status_button` | 3382-3388 | `list_box_item` | `type`, `parent`, `width`, `horizontal_align` |
| 77 | `station_train_status_button` | 3390-3395 | `list_box_item` | `type`, `parent`, `width` |
| 78 | `title_tip_item` | 3397-3402 | `list_box_item` | `type`, `parent`, `font` |
| 79 | `list_box` | 3525-3538 |  | `type`, `scroll_pane_style`, `item_style` |
| 80 | `item_and_count_select_confirm` | 3776-3783 | `green_button` | `type`, `parent`, `size`, `padding`, `invert_colors_of_picture_when_disabled` |
| 81 | `filter_group_button_tab_slightly_larger` | 3959-3992 |  | `type`, `size`, `left_padding`, `right_padding`, `top_padding`, `bottom_padding`, `clicked_vertical_offset`, `selected_graphical_set`, `disabled_graphical_set`, `selected_font_color`, `selected_hovered_font_color`, `selected_hovered_graphical_set`, `selected_clicked_font_color`, `selected_clicked_graphical_set` |
| 82 | `button_with_shadow` | 4106-4127 |  | `type`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `left_click_sound` |
| 83 | `train_schedule_add_wait_condition_button` | 4129-4136 | `button_with_shadow` | `type`, `parent`, `horizontal_align`, `height`, `width` |
| 84 | `train_schedule_add_interrupt_station_button` | 4138-4146 | `button_with_shadow` | `type`, `parent`, `horizontal_align`, `height`, `horizontally_stretchable` |
| 85 | `train_schedule_add_station_button` | 4148-4155 | `button_with_shadow` | `type`, `parent`, `horizontal_align`, `horizontally_stretchable`, `height` |
| 86 | `train_schedule_action_button` | 4163-4174 |  | `type`, `padding`, `size`, `left_click_sound`, `disabled_graphical_set` |
| 87 | `train_schedule_comparison_type_button` | 4316-4324 |  | `type`, `left_padding`, `right_padding`, `width`, `height`, `left_click_sound` |
| 88 | `minimap_slot` | 4342-4418 | `button` | `type`, `parent`, `padding`, `size`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set` |
| 89 | `locomotive_minimap_button` | 4420-4496 | `button` | `type`, `parent`, `padding`, `size`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set` |
| 90 | `target_station_in_schedule_in_train_view_list_box_item` | 4516-4526 | `list_box_item` | `type`, `parent`, `default_font_color`, `hovered_font_color`, `clicked_font_color`, `selected_font_color`, `selected_hovered_font_color`, `selected_clicked_font_color` |
| 91 | `no_path_station_in_schedule_in_train_view_list_box_item` | 4528-4538 | `list_box_item` | `type`, `parent`, `default_font_color`, `hovered_font_color`, `clicked_font_color`, `selected_font_color`, `selected_hovered_font_color`, `selected_clicked_font_color` |
| 92 | `default_permission_group_list_box_item` | 4540-4549 | `list_box_item` | `type`, `parent`, `default_font_color`, `hovered_font_color`, `selected_font_color`, `selected_hovered_font_color`, `selected_clicked_font_color` |
| 93 | `table` | 4590-4713 |  | `type`, `horizontal_spacing`, `vertical_spacing`, `border`, `column_ordering_ascending_button_style`, `column_ordering_descending_button_style`, `inactive_column_ordering_ascending_button_style`, `inactive_column_ordering_descending_button_style` |
| 94 | `browse_games_gui_toggle_favorite_on_button` | 4974-5002 |  | `type`, `size`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set` |
| 95 | `browse_games_gui_toggle_favorite_off_button` | 5004-5032 |  | `type`, `size`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set` |
| 96 | `mods_filter_exclude_button` | 5034-5070 | `transparent_slot` | `type`, `parent`, `size`, `left_margin`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set` |
| 97 | `cancel_close_button` | 5513-5518 | `frame_action_button` | `type`, `parent`, `tooltip` |
| 98 | `close_button` | 5520-5525 | `frame_action_button` | `type`, `parent`, `tooltip` |
| 99 | `lab_research_info_button` | 5659-5679 |  | `type`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `width`, `padding` |
| 100 | `current_research_info_button` | 5681-5691 |  | `type`, `padding`, `width`, `default_graphical_set` |
| 101 | `open_armor_button` | 6243-6250 | `forward_button` | `type`, `parent`, `padding`, `height`, `width` |
| 102 | `quick_bar_page_button` | 6599-6630 | `button` | `type`, `parent`, `font`, `default_font_color`, `size`, `padding`, `margin`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound` |
| 103 | `tool_bar_open_button` | 6632-6637 | `quick_bar_page_button` | `type`, `parent`, `width` |
| 104 | `dark_rounded_button` | 6651-6697 |  | `type`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 105 | `train_schedule_item_select_button` | 6699-6705 | `dark_rounded_button` | `type`, `parent`, `size`, `padding` |
| 106 | `train_schedule_fulfilled_item_select_button` | 6707-6754 | `train_schedule_item_select_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 107 | `train_schedule_partially_fulfilled_item_select_button` | 6755-6802 | `train_schedule_fulfilled_item_select_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 108 | `slot_button` | 6803-6844 | `button` | `type`, `parent`, `draw_shadow_under_picture`, `size`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set`, `pie_progress_color`, `left_click_sound` |
| 109 | `big_slot_button` | 6846-6869 | `button` | `type`, `parent`, `draw_shadow_under_picture`, `size`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 110 | `slot_button_in_shallow_frame` | 6871-6911 | `slot_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `selected_clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound` |
| 111 | `yellow_slot_button` | 6913-6939 | `slot_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set` |
| 112 | `red_slot_button` | 6941-6967 | `slot_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set` |
| 113 | `slot_sized_button` | 6969-7008 | `button` | `type`, `parent`, `default_graphical_set`, `disabled_graphical_set`, `hovered_graphical_set`, `left_click_sound`, `clicked_graphical_set`, `selected_graphical_set`, `selected_hovered_graphical_set`, `size`, `padding` |
| 114 | `compact_slot_sized_button` | 7010-7015 | `slot_sized_button` | `type`, `parent`, `size` |
| 115 | `slot_sized_button_pressed` | 7017-7043 | `button` | `type`, `parent`, `default_graphical_set`, `disabled_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `size`, `padding` |
| 116 | `slot_sized_button_blue` | 7045-7070 | `slot_sized_button` | `type`, `parent`, `default_graphical_set`, `disabled_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 117 | `slot_sized_button_red` | 7072-7097 | `slot_sized_button` | `type`, `parent`, `default_graphical_set`, `disabled_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 118 | `slot_sized_button_green` | 7099-7124 | `slot_sized_button` | `type`, `parent`, `default_graphical_set`, `disabled_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 119 | `shortcut_bar_button` | 7126-7132 | `slot_sized_button` | `type`, `parent`, `padding`, `invert_colors_of_picture_when_disabled` |
| 120 | `shortcut_bar_button_blue` | 7134-7139 | `slot_sized_button_blue` | `type`, `parent`, `padding` |
| 121 | `shortcut_bar_button_red` | 7141-7146 | `slot_sized_button_red` | `type`, `parent`, `padding` |
| 122 | `shortcut_bar_button_green` | 7148-7153 | `slot_sized_button_green` | `type`, `parent`, `padding` |
| 123 | `shortcut_bar_button_small` | 7155-7163 | `slot_sized_button` | `type`, `parent`, `size`, `padding`, `invert_colors_of_picture_when_disabled`, `left_click_sound` |
| 124 | `shortcut_bar_button_small_green` | 7165-7172 | `slot_sized_button_green` | `type`, `parent`, `size`, `padding`, `left_click_sound` |
| 125 | `shortcut_bar_button_small_red` | 7174-7181 | `slot_sized_button_red` | `type`, `parent`, `size`, `padding`, `left_click_sound` |
| 126 | `shortcut_bar_button_small_blue` | 7183-7190 | `slot_sized_button_blue` | `type`, `parent`, `size`, `padding`, `left_click_sound` |
| 127 | `horizontal_scrollbar` | 7639-7683 |  | `type`, `height`, `background_graphical_set`, `thumb_button_style` |
| 128 | `vertical_scrollbar` | 7684-7728 |  | `type`, `width`, `background_graphical_set`, `thumb_button_style` |
| 129 | `slider_button` | 7884-7911 |  | `type`, `width`, `height`, `padding`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound` |
| 130 | `left_slider_button` | 7914-7939 | `slider_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound` |
| 131 | `right_slider_button` | 7941-7966 | `slider_button` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set`, `disabled_graphical_set`, `left_click_sound` |
| 132 | `slider` | 7968-8049 |  | `type`, `minimal_width`, `height`, `ignored_by_search`, `full_bar`, `full_bar_disabled`, `empty_bar`, `empty_bar_disabled`, `draw_notches`, `notch`, `button` |
| 133 | `notched_slider` | 8051-8085 | `slider` | `type`, `parent`, `height`, `draw_notches`, `button` |
| 134 | `double_slider` | 8087-8148 |  | `type`, `button`, `high_button`, `minimal_width`, `height`, `full_bar`, `full_bar_disabled`, `empty_bar`, `empty_bar_disabled`, `draw_notches`, `notch` |
| 135 | `entity_variation_button` | 8829-8837 |  | `type`, `size`, `left_padding`, `right_padding`, `top_padding`, `bottom_padding` |
| 136 | `tile_variation_button` | 8839-8844 |  | `type`, `size`, `padding` |
| 137 | `train_schedule_fulfilled_delete_button` | 9010-9020 | `train_schedule_delete_button` | `type`, `parent`, `invert_colors_of_picture_when_hovered_or_toggled`, `default_graphical_set` |
| 138 | `train_schedule_partially_fulfilled_delete_button` | 9021-9031 | `train_schedule_delete_button` | `type`, `parent`, `invert_colors_of_picture_when_hovered_or_toggled`, `default_graphical_set` |
| 139 | `train_schedule_temporary_station_delete_button` | 9033-9043 | `train_schedule_delete_button` | `type`, `parent`, `invert_colors_of_picture_when_hovered_or_toggled`, `default_graphical_set` |
| 140 | `other_settings_gui_button` | 9085-9090 | `button` | `type`, `parent`, `width` |
| 141 | `dark_button` | 9145-9153 |  | `type`, `default_graphical_set` |
| 142 | `train_schedule_delete_button` | 9207-9216 | `dark_button` | `type`, `parent`, `padding`, `width`, `invert_colors_of_picture_when_hovered_or_toggled`, `left_click_sound` |
| 143 | `train_schedule_collapse_button` | 9218-9223 | `train_schedule_delete_button` | `type`, `parent`, `size` |
| 144 | `train_schedule_condition_time_selection_button` | 9283-9288 |  | `type`, `width`, `left_click_sound` |
| 145 | `shortcut_bar_expand_button` | 9290-9310 | `frame_button` | `type`, `parent`, `width`, `height`, `left_click_sound`, `left_padding`, `right_padding`, `invert_colors_of_picture_when_hovered_or_toggled`, `selected_graphical_set`, `selected_hovered_graphical_set` |
| 146 | `choose_chat_icon_button` | 9452-9487 |  | `type`, `size`, `padding`, `right_margin`, `top_margin`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 147 | `choose_chat_icon_in_textbox_button` | 9489-9525 |  | `type`, `size`, `padding`, `right_margin`, `bottom_margin`, `invert_colors_of_picture_when_hovered_or_toggled`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 148 | `decider_combinator_signal_select_button` | 9641-9688 | `slot_button_in_shallow_frame` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 149 | `decider_combinator_fulfilled_signal_select_button` | 9690-9737 | `slot_button_in_shallow_frame` | `type`, `parent`, `default_graphical_set`, `hovered_graphical_set`, `clicked_graphical_set` |
| 150 | `add_logistic_section_button` | 9739-9743 |  | `type`, `height` |

## 全部按钮样式明细

### 1. `button`

- 行号：`1033-1094`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `font` = `"default-semibold"`：按钮文字字体。
  - `horizontal_align` = `"center"`：文字或内容水平方向对齐。
  - `vertical_align` = `"center"`：文字或内容垂直方向对齐。
  - `icon_horizontal_align` = `"center"`：图标水平方向对齐。
  - `ignored_by_search` = `true`：是否被样式搜索或调试搜索忽略。
  - `top_padding` = `0`：上内边距。
  - `bottom_padding` = `0`：下内边距。
  - `left_padding` = `8`：左内边距。
  - `right_padding` = `8`：右内边距。
  - `minimal_width` = `108`：最小宽度。
  - `minimal_height` = `28`：最小高度。
  - `default_font_color` = `button_default_font_color`：默认状态文字颜色。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_font_color` = `button_hovered_font_color`：鼠标悬停时文字颜色。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_font_color` = `button_hovered_font_color`：按下时文字颜色。
  - `clicked_vertical_offset` = `1`：按下按钮时文字或图标向下偏移量。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_font_color` = `{179, 179, 179}`：禁用状态文字颜色。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `selected_font_color` = `button_hovered_font_color`：选中状态文字颜色。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_font_color` = `button_hovered_font_color`：选中且悬停时文字颜色。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_font_color` = `button_hovered_font_color`：选中且按下时文字颜色。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。
  - `strikethrough_color` = `gui_color.grey`：文字删除线颜色。
  - `pie_progress_color` = `{1, 1, 1}`：按钮上饼形进度覆盖层颜色。
  - `left_click_sound` = `"__core__/sound/gui-click.ogg"`：左键点击音效。

### 2. `green_button`

- 行号：`1096-1123`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-green-confirm.ogg"`：左键点击音效。
  - `tooltip` = `"gui.confirm-instruction"`：悬停提示文本或本地化键。

### 3. `rounded_button`

- 行号：`1125-1164`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。

### 4. `back_button`

- 行号：`1166-1175`
- 父样式：`dialog_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dialog_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `default_graphical_set` = `arrow_back(grey_arrow_tileset, arrow_idle_index, "shadow", default_dirt_color)`：默认状态外观图形集。
  - `hovered_graphical_set` = `arrow_back(grey_arrow_tileset, arrow_hovered_index, "glow", default_glow_color)`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `arrow_back(grey_arrow_tileset, arrow_clicked_index)`：按下状态外观图形集。
  - `disabled_graphical_set` = `arrow_back(grey_arrow_tileset, arrow_disabled_index, "glow", default_dirt_color)`：禁用状态外观图形集。

### 5. `red_back_button`

- 行号：`1177-1187`
- 父样式：`dialog_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dialog_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `default_graphical_set` = `arrow_back(red_arrow_tileset, arrow_idle_index, "shadow", default_dirt_color)`：默认状态外观图形集。
  - `hovered_graphical_set` = `arrow_back(red_arrow_tileset, arrow_hovered_index, "glow", red_button_glow_color)`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `arrow_back(red_arrow_tileset, arrow_clicked_index)`：按下状态外观图形集。
  - `disabled_font_color` = `gui_color.grey`：禁用状态文字颜色。
  - `disabled_graphical_set` = `arrow_back(red_arrow_tileset, arrow_disabled_index, "glow", default_dirt_color)`：禁用状态外观图形集。

### 6. `confirm_button`

- 行号：`1201-1212`
- 父样式：`dialog_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dialog_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"right"`：文字或内容水平方向对齐。
  - `default_graphical_set` = `arrow_forward(green_arrow_tileset, arrow_idle_index, "shadow", default_dirt_color)`：默认状态外观图形集。
  - `hovered_graphical_set` = `arrow_forward(green_arrow_tileset, arrow_hovered_index, "glow", green_button_glow_color)`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `arrow_forward(green_arrow_tileset, arrow_clicked_index)`：按下状态外观图形集。
  - `disabled_graphical_set` = `arrow_forward(green_arrow_tileset, arrow_disabled_index, "glow", default_dirt_color)`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-green-confirm.ogg"`：左键点击音效。
  - `tooltip` = `"gui.confirm-instruction"`：悬停提示文本或本地化键。

### 7. `confirm_button_without_tooltip`

- 行号：`1214-1219`
- 父样式：`confirm_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"confirm_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `tooltip` = `""`：悬停提示文本或本地化键。

### 8. `confirm_double_arrow_button`

- 行号：`1221-1231`
- 父样式：`dialog_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dialog_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"right"`：文字或内容水平方向对齐。
  - `default_graphical_set` = `double_arrow_forward(green_arrow_tileset, arrow_idle_index, "shadow", default_dirt_color)`：默认状态外观图形集。
  - `hovered_graphical_set` = `double_arrow_forward(green_arrow_tileset, arrow_hovered_index, "glow", green_button_glow_color)`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `double_arrow_forward(green_arrow_tileset, arrow_clicked_index)`：按下状态外观图形集。
  - `disabled_graphical_set` = `double_arrow_forward(green_arrow_tileset, arrow_disabled_index, "glow", default_dirt_color)`：禁用状态外观图形集。
  - `tooltip` = `"gui.confirm-instruction"`：悬停提示文本或本地化键。

### 9. `map_generator_preview_button`

- 行号：`1245-1250`
- 父样式：`forward_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"forward_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `icon_horizontal_align` = `"left"`：图标水平方向对齐。

### 10. `map_generator_close_preview_button`

- 行号：`1252-1258`
- 父样式：`back_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"back_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `icon_horizontal_align` = `"left"`：图标水平方向对齐。
  - `left_padding` = `-4`：左内边距。

### 11. `map_generator_confirm_button`

- 行号：`1260-1265`
- 父样式：`confirm_double_arrow_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"confirm_double_arrow_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `width` = `208`：固定宽度。

### 12. `confirm_in_load_game_button`

- 行号：`1267-1273`
- 父样式：`confirm_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"confirm_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `natural_width` = `300`：自然宽度。
  - `horizontally_squashable` = `"on"`：水平方向可压缩设置。

### 13. `red_confirm_button`

- 行号：`1275-1286`
- 父样式：`dialog_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dialog_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"right"`：文字或内容水平方向对齐。
  - `left_click_sound` = `{ filename = "__core__/sound/gui-red-confirm.ogg", volume = 0.7 }`：左键点击音效。
  - `default_graphical_set` = `arrow_forward(red_arrow_tileset, arrow_idle_index, "shadow", default_dirt_color)`：默认状态外观图形集。
  - `hovered_graphical_set` = `arrow_forward(red_arrow_tileset, arrow_hovered_index, "glow", red_button_glow_color)`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `arrow_forward(red_arrow_tileset, arrow_clicked_index)`：按下状态外观图形集。
  - `disabled_font_color` = `gui_color.grey`：禁用状态文字颜色。
  - `disabled_graphical_set` = `arrow_forward(red_arrow_tileset, arrow_disabled_index, "glow", default_dirt_color)`：禁用状态外观图形集。

### 14. `red_button`

- 行号：`1288-1314`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `{ filename = "__core__/sound/gui-red-button.ogg", volume = 0.5 }`：左键点击音效。

### 15. `tool_button_red`

- 行号：`1316-1324`
- 父样式：`red_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"red_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `2`：四边统一内边距。
  - `size` = `28`：固定宽高相等的尺寸。
  - `left_click_sound` = `"__core__/sound/gui-tool-button.ogg"`：左键点击音效。
  - `invert_colors_of_picture_when_disabled` = `true`：禁用状态时是否反转图片颜色。

### 16. `tool_button_flush_fluid`

- 行号：`1326-1331`
- 父样式：`tool_button_red`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"tool_button_red"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `left_click_sound` = `{ filename = "__core__/sound/gui-flush-fluid.ogg", volume = 0.7 }`：左键点击音效。

### 17. `tool_button`

- 行号：`1333-1341`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `padding` = `2`：四边统一内边距。
  - `height` = `28`：固定高度。
  - `minimal_width` = `28`：最小宽度。
  - `left_click_sound` = `"__core__/sound/gui-tool-button.ogg"`：左键点击音效。
  - `invert_colors_of_picture_when_disabled` = `true`：禁用状态时是否反转图片颜色。

### 18. `tool_button_without_padding`

- 行号：`1343-1348`
- 父样式：`tool_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"tool_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `0`：四边统一内边距。

### 19. `tool_button_green`

- 行号：`1350-1375`
- 父样式：`tool_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"tool_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。

### 20. `tool_button_blue`

- 行号：`1396-1416`
- 父样式：`tool_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"tool_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 21. `mini_tool_button_red`

- 行号：`1418-1425`
- 父样式：`red_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"red_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `0`：四边统一内边距。
  - `size` = `16`：固定宽高相等的尺寸。
  - `left_click_sound` = `{{ filename = "__core__/sound/gui-tool-button.ogg", volume = 1 }}`：左键点击音效。

### 22. `mini_button`

- 行号：`1427-1433`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `padding` = `0`：四边统一内边距。
  - `size` = `16`：固定宽高相等的尺寸。
  - `left_click_sound` = `"__core__/sound/gui-button-mini.ogg"`：左键点击音效。

### 23. `mini_button_aligned_to_text_vertically`

- 行号：`1435-1442`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `padding` = `0`：四边统一内边距。
  - `size` = `16`：固定宽高相等的尺寸。
  - `top_margin` = `3`：上外边距。
  - `left_click_sound` = `"__core__/sound/gui-button-mini.ogg"`：左键点击音效。

### 24. `mini_button_aligned_to_text_vertically_when_centered`

- 行号：`1444-1451`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `padding` = `0`：四边统一内边距。
  - `size` = `16`：固定宽高相等的尺寸。
  - `top_margin` = `1`：上外边距。
  - `left_click_sound` = `"__core__/sound/gui-button-mini.ogg"`：左键点击音效。

### 25. `highlighted_tool_button`

- 行号：`1453-1463`
- 父样式：`tool_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"tool_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 26. `switch`

- 行号：`1599-1635`
- 父样式：无
- 直接属性：
  - `type` = `"switch_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `active_label` = `〈table〉`：Factorio 按钮样式属性。
  - `inactive_label` = `〈table〉`：Factorio 按钮样式属性。
  - `width` = `32`：固定宽度。
  - `height` = `16`：固定高度。
  - `padding` = `0`：四边统一内边距。
  - `left_button_position` = `2`：Factorio 按钮样式属性。
  - `middle_button_position` = `9`：Factorio 按钮样式属性。
  - `right_button_position` = `16`：Factorio 按钮样式属性。
  - `default_background` = `{position = {0, 96}, size = {64, 32}}`：Factorio 按钮样式属性。
  - `hover_background` = `{position = {64, 96}, size = {64, 32}}`：Factorio 按钮样式属性。
  - `disabled_background` = `{position = {0, 96}, size = {64, 32}}`：Factorio 按钮样式属性。
  - `button` = `〈table〉`：Factorio 按钮样式属性。

### 27. `dialog_button`

- 行号：`1637-1649`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `font` = `"default-dialog-button"`：按钮文字字体。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_font_color` = `button_default_bold_font_color`：默认状态文字颜色。
  - `hovered_font_color` = `button_default_bold_font_color`：鼠标悬停时文字颜色。
  - `clicked_font_color` = `button_default_bold_font_color`：按下时文字颜色。
  - `disabled_font_color` = `gui_color.grey`：禁用状态文字颜色。
  - `bottom_padding` = `2`：下内边距。
  - `height` = `32`：固定高度。
  - `minimal_width` = `112`：最小宽度。

### 28. `menu_button`

- 行号：`1651-1664`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `font` = `"default-dialog-button"`：按钮文字字体。
  - `default_font_color` = `button_default_bold_font_color`：默认状态文字颜色。
  - `hovered_font_color` = `button_default_bold_font_color`：鼠标悬停时文字颜色。
  - `clicked_font_color` = `button_default_bold_font_color`：按下时文字颜色。
  - `minimal_width` = `320`：最小宽度。
  - `maximal_width` = `320`：最大宽度。
  - `minimal_height` = `50`：最小高度。
  - `top_padding` = `4`：上内边距。
  - `bottom_padding` = `4`：下内边距。

### 29. `menu_button_continue`

- 行号：`1666-1693`
- 父样式：`menu_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"menu_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-green-confirm.ogg"`：左键点击音效。
  - `tooltip` = `"gui.confirm-instruction"`：悬停提示文本或本地化键。

### 30. `side_menu_button`

- 行号：`1695-1709`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_font_color` = `{}`：默认状态文字颜色。
  - `size` = `40`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `left_click_sound` = `"__core__/sound/gui-square-button.ogg"`：左键点击音效。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `true`：悬停或切换状态时是否反转图片颜色。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 31. `map_view_add_button`

- 行号：`1711-1717`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `height` = `28`：固定高度。
  - `width` = `120`：固定宽度。

### 32. `image_tab_slot`

- 行号：`1728-1733`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `68`：固定宽高相等的尺寸。

### 33. `image_tab_selected_slot`

- 行号：`1735-1740`
- 父样式：`slot_sized_button_pressed`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button_pressed"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `68`：固定宽高相等的尺寸。

### 34. `red_circuit_network_content_slot`

- 行号：`1742-1754`
- 父样式：`compact_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"compact_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 35. `green_circuit_network_content_slot`

- 行号：`1756-1768`
- 父样式：`compact_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"compact_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 36. `compact_slot`

- 行号：`1770-1801`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `36`：固定宽高相等的尺寸。
  - `padding` = `1`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `pie_progress_color` = `{0.98, 0.66, 0.22, 0.5}`：按钮上饼形进度覆盖层颜色。

### 37. `slot`

- 行号：`1803-1817`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `slot_size`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {80, 424}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {160, 424}, size = 80}}`：按下状态外观图形集。
  - `pie_progress_color` = `{0.98, 0.66, 0.22, 0.5}`：按钮上饼形进度覆盖层颜色。
  - `left_click_sound` = `{ filename = "__core__/sound/gui-inventory-slot-button.ogg", volume = 0.6 }`：左键点击音效。

### 38. `red_slot`

- 行号：`1819-1827`
- 父样式：`slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `{ base = {border = 4, position = {240, 816}, size = 80}}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {320, 816}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {400, 816}, size = 80}}`：按下状态外观图形集。
  - `selected_graphical_set` = `{ base = {border = 4, position = {320, 816}, size = 80}}`：选中状态外观图形集。

### 39. `yellow_slot`

- 行号：`1829-1837`
- 父样式：`slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `{ base = {border = 4, position = {0, 816}, size = 80}}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {80, 816}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {160, 816}, size = 80}}`：按下状态外观图形集。
  - `selected_graphical_set` = `{ base = {border = 4, position = {80, 816}, size = 80}}`：选中状态外观图形集。

### 40. `green_slot`

- 行号：`1839-1846`
- 父样式：`slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `{ base = {border = 4, position = {504, 136}, size = 80}}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {504, 216}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {504, 296}, size = 80}}`：按下状态外观图形集。

### 41. `blue_slot`

- 行号：`1848-1855`
- 父样式：`slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `{ base = {border = 4, position = {0, 504}, size = 80}}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {80, 504}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {160, 504}, size = 80}}`：按下状态外观图形集。

### 42. `tool_equip_ammo_slot`

- 行号：`1857-1916`
- 父样式：`slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。
  - `left_click_sound` = `{}`：左键点击音效。

### 43. `inventory_slot`

- 行号：`1918-1927`
- 父样式：`slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `selected_graphical_set` = `{ base = {border = 4, position = {160, 504}, size = 80}}`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `{ base = {border = 4, position = {160, 504}, size = 80}}`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `{ base = {border = 4, position = {160, 504}, size = 80}}`：选中且按下状态外观图形集。
  - `left_click_sound` = `{}`：左键点击音效。

### 44. `filter_inventory_slot`

- 行号：`1929-1934`
- 父样式：`blue_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"blue_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `left_click_sound` = `{}`：左键点击音效。

### 45. `closed_inventory_slot`

- 行号：`1936-1945`
- 父样式：`slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `{ base = {border = 4, position = {504, 376}, size = 80}}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {504, 456}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {504, 536}, size = 80}}`：按下状态外观图形集。
  - `selected_graphical_set` = `{ base = {border = 4, position = {504, 456}, size = 80}}`：选中状态外观图形集。
  - `left_click_sound` = `{}`：左键点击音效。

### 46. `red_inventory_slot`

- 行号：`1947-1955`
- 父样式：`inventory_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"inventory_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `{ base = {border = 4, position = {240, 816}, size = 80}}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {320, 816}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {400, 816}, size = 80}}`：按下状态外观图形集。
  - `selected_graphical_set` = `{ base = {border = 4, position = {320, 816}, size = 80}}`：选中状态外观图形集。

### 47. `yellow_inventory_slot`

- 行号：`1957-1965`
- 父样式：`inventory_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"inventory_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `{ base = {border = 4, position = {0, 816}, size = 80}}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{ base = {border = 4, position = {80, 816}, size = 80}}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{ base = {border = 4, position = {160, 816}, size = 80}}`：按下状态外观图形集。
  - `selected_graphical_set` = `{ base = {border = 4, position = {80, 816}, size = 80}}`：选中状态外观图形集。

### 48. `research_queue_cancel_button`

- 行号：`2058-2064`
- 父样式：`red_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"red_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `{32, 20}`：固定宽高相等的尺寸。
  - `padding` = `-4`：四边统一内边距。

### 49. `transparent_button`

- 行号：`2691-2702`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `{}`：默认状态外观图形集。
  - `clicked_graphical_set` = `{}`：按下状态外观图形集。
  - `hovered_graphical_set` = `{}`：鼠标悬停状态外观图形集。
  - `clicked_vertical_offset` = `0`：按下按钮时文字或图标向下偏移量。
  - `pie_progress_color` = `{0.98, 0.66, 0.22, 0.5}`：按钮上饼形进度覆盖层颜色。
  - `left_click_sound` = `{}`：左键点击音效。

### 50. `transparent_slot`

- 行号：`2704-2710`
- 父样式：`transparent_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"transparent_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `32`：固定宽高相等的尺寸。
  - `draw_shadow_under_picture` = `true`：是否在图片下方绘制阴影。

### 51. `universe_planet_button`

- 行号：`2728-2733`
- 父样式：`transparent_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"transparent_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `40`：固定宽高相等的尺寸。

### 52. `universe_connection_button`

- 行号：`2735-2745`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `minimal_width` = `0`：最小宽度。
  - `minimal_height` = `0`：最小高度。
  - `padding` = `8`：四边统一内边距。
  - `default_graphical_set` = `{}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{}`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{}`：按下状态外观图形集。
  - `disabled_graphical_set` = `{}`：禁用状态外观图形集。

### 53. `universe_platform_button`

- 行号：`2747-2752`
- 父样式：`transparent_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"transparent_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `16`：固定宽高相等的尺寸。

### 54. `frame_button`

- 行号：`2754-2790`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。

### 55. `frame_action_button`

- 行号：`2793-2800`
- 父样式：`frame_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"frame_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `true`：悬停或切换状态时是否反转图片颜色。
  - `size` = `24`：固定宽高相等的尺寸。
  - `left_click_sound` = `"__core__/sound/gui-tool-button.ogg"`：左键点击音效。

### 56. `blueprint_record_slot_button`

- 行号：`2802-2808`
- 父样式：`inventory_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"inventory_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `80`：固定宽高相等的尺寸。
  - `padding` = `4`：四边统一内边距。

### 57. `blueprint_record_selection_button`

- 行号：`2810-2815`
- 父样式：`big_slot_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"big_slot_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `4`：四边统一内边距。

### 58. `drop_target_button`

- 行号：`2842-2917`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `font` = `"default"`：按钮文字字体。
  - `default_font_color` = `{1, 1, 1}`：默认状态文字颜色。
  - `padding` = `5`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_font_color` = `{1, 1, 1}`：鼠标悬停时文字颜色。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_font_color` = `{1, 1, 1}`：按下时文字颜色。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_font_color` = `{0.5, 0.5, 0.5}`：禁用状态文字颜色。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `pie_progress_color` = `{1, 1, 1}`：按钮上饼形进度覆盖层颜色。
  - `left_click_sound` = `"__core__/sound/gui-drop-target.ogg"`：左键点击音效。

### 59. `compact_red_slot`

- 行号：`2934-2963`
- 父样式：`compact_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"compact_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-slot-unavailable.ogg"`：左键点击音效。

### 60. `inventory_limit_slot_button`

- 行号：`2965-3001`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。

### 61. `working_weapon_button`

- 行号：`3003-3036`
- 父样式：`green_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"green_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `left_click_sound` = `{}`：左键点击音效。
  - `draw_shadow_under_picture` = `true`：是否在图片下方绘制阴影。

### 62. `not_working_weapon_button`

- 行号：`3038-3081`
- 父样式：`red_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"red_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `left_click_sound` = `{}`：左键点击音效。
  - `draw_shadow_under_picture` = `true`：是否在图片下方绘制阴影。

### 63. `omitted_technology_slot`

- 行号：`3083-3090`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `{10, 8}`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `{}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{}`：鼠标悬停状态外观图形集。

### 64. `crafting_queue_slot`

- 行号：`3102-3123`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `40`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `pie_progress_color` = `{0.98, 0.66, 0.22, 0.5}`：按钮上饼形进度覆盖层颜色。

### 65. `promised_crafting_queue_slot`

- 行号：`3125-3144`
- 父样式：`crafting_queue_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"crafting_queue_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 66. `control_settings_button`

- 行号：`3146-3152`
- 父样式：`rounded_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"rounded_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `width` = `225`：固定宽度。

### 67. `control_settings_section_button`

- 行号：`3175-3181`
- 父样式：`tool_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"tool_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `true`：悬停或切换状态时是否反转图片颜色。
  - `default_graphical_set` = `{position = {68, 0}, corner_size = 8}`：默认状态外观图形集。

### 68. `dropdown_button`

- 行号：`3183-3190`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `padding` = `0`：四边统一内边距。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `font` = `"default-dropdown"`：按钮文字字体。
  - `left_click_sound` = `"__core__/sound/gui-click.ogg"`：左键点击音效。

### 69. `dropdown`

- 行号：`3202-3234`
- 父样式：无
- 直接属性：
  - `type` = `"dropdown_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `ignored_by_search` = `true`：是否被样式搜索或调试搜索忽略。
  - `minimal_width` = `116`：最小宽度。
  - `minimal_height` = `28`：最小高度。
  - `top_padding` = `-1`：上内边距。
  - `bottom_padding` = `1`：下内边距。
  - `left_padding` = `8`：左内边距。
  - `right_padding` = `4`：右内边距。
  - `selector_and_title_spacing` = `8`：Factorio 按钮样式属性。
  - `opened_sound` = `{ filename = "__core__/sound/gui-dropdown-open.ogg" }`：Factorio 按钮样式属性。
  - `button_style` = `〈table〉`：Factorio 按钮样式属性。
  - `icon` = `〈table〉`：Factorio 按钮样式属性。
  - `list_box_style` = `〈table〉`：Factorio 按钮样式属性。

### 70. `game_controller_icons_dropdown`

- 行号：`3236-3253`
- 父样式：`dropdown`
- 直接属性：
  - `type` = `"dropdown_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dropdown"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `list_box_style` = `〈table〉`：Factorio 按钮样式属性。

### 71. `circuit_condition_comparator_dropdown`

- 行号：`3255-3316`
- 父样式：无
- 直接属性：
  - `type` = `"dropdown_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `minimal_width` = `0`：最小宽度。
  - `left_padding` = `4`：左内边距。
  - `right_padding` = `0`：右内边距。
  - `height` = `40`：固定高度。
  - `button_style` = `〈table〉`：Factorio 按钮样式属性。
  - `list_box_style` = `〈table〉`：Factorio 按钮样式属性。

### 72. `not_accessible_station_in_station_selection`

- 行号：`3325-3334`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_font_color` = `gui_color.red`：默认状态文字颜色。
  - `hovered_font_color` = `{61, 3, 0}`：鼠标悬停时文字颜色。
  - `selected_font_color` = `{61, 3, 0}`：选中状态文字颜色。
  - `selected_hovered_font_color` = `{61, 3, 0}`：选中且悬停时文字颜色。
  - `selected_clicked_font_color` = `{61, 3, 0}`：选中且按下时文字颜色。

### 73. `partially_accessible_station_in_station_selection`

- 行号：`3336-3345`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_font_color` = `{110, 179, 255}`：默认状态文字颜色。
  - `hovered_font_color` = `{0, 23, 84}`：鼠标悬停时文字颜色。
  - `selected_font_color` = `{0, 23, 84}`：选中状态文字颜色。
  - `selected_hovered_font_color` = `{0, 23, 84}`：选中且悬停时文字颜色。
  - `selected_clicked_font_color` = `{0, 23, 84}`：选中且按下时文字颜色。

### 74. `new_game_header_list_box_item`

- 行号：`3347-3361`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `font` = `"heading-2"`：按钮文字字体。
  - `default_font_color` = `gui_color.caption`：默认状态文字颜色。
  - `hovered_font_color` = `gui_color.caption`：鼠标悬停时文字颜色。
  - `selected_font_color` = `gui_color.caption`：选中状态文字颜色。
  - `selected_hovered_font_color` = `gui_color.caption`：选中且悬停时文字颜色。
  - `selected_clicked_font_color` = `gui_color.caption`：选中且按下时文字颜色。
  - `disabled_font_color` = `gui_color.caption`：禁用状态文字颜色。
  - `default_graphical_set` = `{position = {17, 17},  corner_size = 8}`：默认状态外观图形集。
  - `hovered_graphical_set` = `{position = {17, 17},  corner_size = 8}`：鼠标悬停状态外观图形集。
  - `disabled_graphical_set` = `{position = {17, 17},  corner_size = 8}`：禁用状态外观图形集。

### 75. `list_box_item`

- 行号：`3363-3380`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `font` = `"default-listbox"`：按钮文字字体。
  - `ignored_by_search` = `false`：是否被样式搜索或调试搜索忽略。
  - `minimal_width` = `0`：最小宽度。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `default_font_color` = `gui_color.white`：默认状态文字颜色。
  - `default_graphical_set` = `{position = {208, 17},  corner_size = 8}`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `{position = {51, 17}, corner_size = 8}`：按下状态外观图形集。
  - `disabled_font_color` = `{179, 179, 179}`：禁用状态文字颜色。
  - `disabled_graphical_set` = `{position = {17, 17}, corner_size = 8}`：禁用状态外观图形集。

### 76. `train_status_button`

- 行号：`3382-3388`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `width` = `train_gui_minimap_size`：固定宽度。
  - `horizontal_align` = `"center"`：文字或内容水平方向对齐。

### 77. `station_train_status_button`

- 行号：`3390-3395`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `width` = `train_gui_minimap_size + 12`：固定宽度。

### 78. `title_tip_item`

- 行号：`3397-3402`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `font` = `"default-semibold"`：按钮文字字体。

### 79. `list_box`

- 行号：`3525-3538`
- 父样式：无
- 直接属性：
  - `type` = `"list_box_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `scroll_pane_style` = `〈table〉`：Factorio 按钮样式属性。
  - `item_style` = `〈table〉`：Factorio 按钮样式属性。

### 80. `item_and_count_select_confirm`

- 行号：`3776-3783`
- 父样式：`green_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"green_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `28`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `invert_colors_of_picture_when_disabled` = `true`：禁用状态时是否反转图片颜色。

### 81. `filter_group_button_tab_slightly_larger`

- 行号：`3959-3992`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `{71 + 4, 72 + 4}`：固定宽高相等的尺寸。
  - `left_padding` = `3 + 2`：左内边距。
  - `right_padding` = `4 + 2`：右内边距。
  - `top_padding` = `4 + 2`：上内边距。
  - `bottom_padding` = `4 + 2`：下内边距。
  - `clicked_vertical_offset` = `0`：按下按钮时文字或图标向下偏移量。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `selected_font_color` = `button_hovered_font_color`：选中状态文字颜色。
  - `selected_hovered_font_color` = `button_hovered_font_color`：选中且悬停时文字颜色。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_font_color` = `button_hovered_font_color`：选中且按下时文字颜色。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。

### 82. `button_with_shadow`

- 行号：`4106-4127`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-menu-small.ogg"`：左键点击音效。

### 83. `train_schedule_add_wait_condition_button`

- 行号：`4129-4136`
- 父样式：`button_with_shadow`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button_with_shadow"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `height` = `36`：固定高度。
  - `width` = `288`：固定宽度。

### 84. `train_schedule_add_interrupt_station_button`

- 行号：`4138-4146`
- 父样式：`button_with_shadow`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button_with_shadow"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `height` = `36`：固定高度。
  - `horizontally_stretchable` = `"on"`：水平方向可拉伸。

### 85. `train_schedule_add_station_button`

- 行号：`4148-4155`
- 父样式：`button_with_shadow`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button_with_shadow"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `horizontal_align` = `"left"`：文字或内容水平方向对齐。
  - `horizontally_stretchable` = `"on"`：水平方向可拉伸。
  - `height` = `36`：固定高度。

### 86. `train_schedule_action_button`

- 行号：`4163-4174`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `padding` = `0`：四边统一内边距。
  - `size` = `28`：固定宽高相等的尺寸。
  - `left_click_sound` = `"__core__/sound/gui-tool-button.ogg"`：左键点击音效。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。

### 87. `train_schedule_comparison_type_button`

- 行号：`4316-4324`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `left_padding` = `4`：左内边距。
  - `right_padding` = `4`：右内边距。
  - `width` = `56`：固定宽度。
  - `height` = `28`：固定高度。
  - `left_click_sound` = `"__core__/sound/gui-menu-small.ogg"`：左键点击音效。

### 88. `minimap_slot`

- 行号：`4342-4418`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `0`：四边统一内边距。
  - `size` = `right_menu_width`：固定宽高相等的尺寸。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。

### 89. `locomotive_minimap_button`

- 行号：`4420-4496`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `0`：四边统一内边距。
  - `size` = `train_gui_minimap_size`：固定宽高相等的尺寸。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。

### 90. `target_station_in_schedule_in_train_view_list_box_item`

- 行号：`4516-4526`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_font_color` = `gui_color.orange`：默认状态文字颜色。
  - `hovered_font_color` = `{82, 47, 0}`：鼠标悬停时文字颜色。
  - `clicked_font_color` = `{82, 47, 0}`：按下时文字颜色。
  - `selected_font_color` = `{82, 47, 0}`：选中状态文字颜色。
  - `selected_hovered_font_color` = `{82, 47, 0}`：选中且悬停时文字颜色。
  - `selected_clicked_font_color` = `{82, 47, 0}`：选中且按下时文字颜色。

### 91. `no_path_station_in_schedule_in_train_view_list_box_item`

- 行号：`4528-4538`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_font_color` = `{1, 0.2, 0.3}`：默认状态文字颜色。
  - `hovered_font_color` = `{135, 0, 17}`：鼠标悬停时文字颜色。
  - `clicked_font_color` = `{135, 0, 17}`：按下时文字颜色。
  - `selected_font_color` = `{135, 0, 17}`：选中状态文字颜色。
  - `selected_hovered_font_color` = `{135, 0, 17}`：选中且悬停时文字颜色。
  - `selected_clicked_font_color` = `{135, 0, 17}`：选中且按下时文字颜色。

### 92. `default_permission_group_list_box_item`

- 行号：`4540-4549`
- 父样式：`list_box_item`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"list_box_item"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_font_color` = `{0.55, 0.55, 1}`：默认状态文字颜色。
  - `hovered_font_color` = `{0.8, 0.8, 1.0}`：鼠标悬停时文字颜色。
  - `selected_font_color` = `{0.2, 0.2, 0.8}`：选中状态文字颜色。
  - `selected_hovered_font_color` = `{0.2, 0.2, 0.8}`：选中且悬停时文字颜色。
  - `selected_clicked_font_color` = `{0.2, 0.2, 0.8}`：选中且按下时文字颜色。

### 93. `table`

- 行号：`4590-4713`
- 父样式：无
- 直接属性：
  - `type` = `"table_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `horizontal_spacing` = `4`：Factorio 按钮样式属性。
  - `vertical_spacing` = `4`：Factorio 按钮样式属性。
  - `border` = `{}`：Factorio 按钮样式属性。
  - `column_ordering_ascending_button_style` = `〈table〉`：Factorio 按钮样式属性。
  - `column_ordering_descending_button_style` = `〈table〉`：Factorio 按钮样式属性。
  - `inactive_column_ordering_ascending_button_style` = `〈table〉`：Factorio 按钮样式属性。
  - `inactive_column_ordering_descending_button_style` = `〈table〉`：Factorio 按钮样式属性。

### 94. `browse_games_gui_toggle_favorite_on_button`

- 行号：`4974-5002`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `16`：固定宽高相等的尺寸。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。

### 95. `browse_games_gui_toggle_favorite_off_button`

- 行号：`5004-5032`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `16`：固定宽高相等的尺寸。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。

### 96. `mods_filter_exclude_button`

- 行号：`5034-5070`
- 父样式：`transparent_slot`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"transparent_slot"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `16`：固定宽高相等的尺寸。
  - `left_margin` = `8`：左外边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。

### 97. `cancel_close_button`

- 行号：`5513-5518`
- 父样式：`frame_action_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"frame_action_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `tooltip` = `"gui.cancel-instruction"`：悬停提示文本或本地化键。

### 98. `close_button`

- 行号：`5520-5525`
- 父样式：`frame_action_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"frame_action_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `tooltip` = `"gui.close-instruction"`：悬停提示文本或本地化键。

### 99. `lab_research_info_button`

- 行号：`5659-5679`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `width` = `slot_table_width`：固定宽度。
  - `padding` = `-8`：四边统一内边距。

### 100. `current_research_info_button`

- 行号：`5681-5691`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `padding` = `0`：四边统一内边距。
  - `width` = `right_menu_width`：固定宽度。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 101. `open_armor_button`

- 行号：`6243-6250`
- 父样式：`forward_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"forward_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `7`：四边统一内边距。
  - `height` = `38`：固定高度。
  - `width` = `76`：固定宽度。

### 102. `quick_bar_page_button`

- 行号：`6599-6630`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `font` = `"default-bold"`：按钮文字字体。
  - `default_font_color` = `button_hovered_font_color`：默认状态文字颜色。
  - `size` = `40`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `margin` = `0`：四边外边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-square-button.ogg"`：左键点击音效。

### 103. `tool_bar_open_button`

- 行号：`6632-6637`
- 父样式：`quick_bar_page_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"quick_bar_page_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `width` = `52`：固定宽度。

### 104. `dark_rounded_button`

- 行号：`6651-6697`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 105. `train_schedule_item_select_button`

- 行号：`6699-6705`
- 父样式：`dark_rounded_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dark_rounded_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `28`：固定宽高相等的尺寸。
  - `padding` = `-3`：四边统一内边距。

### 106. `train_schedule_fulfilled_item_select_button`

- 行号：`6707-6754`
- 父样式：`train_schedule_item_select_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"train_schedule_item_select_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 107. `train_schedule_partially_fulfilled_item_select_button`

- 行号：`6755-6802`
- 父样式：`train_schedule_fulfilled_item_select_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"train_schedule_fulfilled_item_select_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 108. `slot_button`

- 行号：`6803-6844`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `draw_shadow_under_picture` = `true`：是否在图片下方绘制阴影。
  - `size` = `40`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。
  - `pie_progress_color` = `{0.98, 0.66, 0.22, 0.5}`：按钮上饼形进度覆盖层颜色。
  - `left_click_sound` = `{ filename = "__core__/sound/gui-inventory-slot-button.ogg", volume = 0.6 }`：左键点击音效。

### 109. `big_slot_button`

- 行号：`6846-6869`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `draw_shadow_under_picture` = `true`：是否在图片下方绘制阴影。
  - `size` = `80`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 110. `slot_button_in_shallow_frame`

- 行号：`6871-6911`
- 父样式：`slot_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `selected_clicked_graphical_set` = `〈table〉`：选中且按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-square-button.ogg"`：左键点击音效。

### 111. `yellow_slot_button`

- 行号：`6913-6939`
- 父样式：`slot_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。

### 112. `red_slot_button`

- 行号：`6941-6967`
- 父样式：`slot_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。

### 113. `slot_sized_button`

- 行号：`6969-7008`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-square-button.ogg"`：左键点击音效。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。
  - `size` = `40`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。

### 114. `compact_slot_sized_button`

- 行号：`7010-7015`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `36`：固定宽高相等的尺寸。

### 115. `slot_sized_button_pressed`

- 行号：`7017-7043`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `size` = `40`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。

### 116. `slot_sized_button_blue`

- 行号：`7045-7070`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 117. `slot_sized_button_red`

- 行号：`7072-7097`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 118. `slot_sized_button_green`

- 行号：`7099-7124`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 119. `shortcut_bar_button`

- 行号：`7126-7132`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `2`：四边统一内边距。
  - `invert_colors_of_picture_when_disabled` = `true`：禁用状态时是否反转图片颜色。

### 120. `shortcut_bar_button_blue`

- 行号：`7134-7139`
- 父样式：`slot_sized_button_blue`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button_blue"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `2`：四边统一内边距。

### 121. `shortcut_bar_button_red`

- 行号：`7141-7146`
- 父样式：`slot_sized_button_red`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button_red"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `2`：四边统一内边距。

### 122. `shortcut_bar_button_green`

- 行号：`7148-7153`
- 父样式：`slot_sized_button_green`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button_green"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `2`：四边统一内边距。

### 123. `shortcut_bar_button_small`

- 行号：`7155-7163`
- 父样式：`slot_sized_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `20`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `invert_colors_of_picture_when_disabled` = `true`：禁用状态时是否反转图片颜色。
  - `left_click_sound` = `"__core__/sound/gui-button-mini.ogg"`：左键点击音效。

### 124. `shortcut_bar_button_small_green`

- 行号：`7165-7172`
- 父样式：`slot_sized_button_green`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button_green"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `20`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `left_click_sound` = `"__core__/sound/gui-button-mini.ogg"`：左键点击音效。

### 125. `shortcut_bar_button_small_red`

- 行号：`7174-7181`
- 父样式：`slot_sized_button_red`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button_red"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `20`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `left_click_sound` = `"__core__/sound/gui-button-mini.ogg"`：左键点击音效。

### 126. `shortcut_bar_button_small_blue`

- 行号：`7183-7190`
- 父样式：`slot_sized_button_blue`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_sized_button_blue"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `20`：固定宽高相等的尺寸。
  - `padding` = `0`：四边统一内边距。
  - `left_click_sound` = `"__core__/sound/gui-button-mini.ogg"`：左键点击音效。

### 127. `horizontal_scrollbar`

- 行号：`7639-7683`
- 父样式：无
- 直接属性：
  - `type` = `"horizontal_scrollbar_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `height` = `12`：固定高度。
  - `background_graphical_set` = `{ position = {0, 72}, corner_size = 8}`：Factorio 按钮样式属性。
  - `thumb_button_style` = `〈table〉`：Factorio 按钮样式属性。

### 128. `vertical_scrollbar`

- 行号：`7684-7728`
- 父样式：无
- 直接属性：
  - `type` = `"vertical_scrollbar_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `width` = `12`：固定宽度。
  - `background_graphical_set` = `{ position = {0, 72}, corner_size = 8}`：Factorio 按钮样式属性。
  - `thumb_button_style` = `〈table〉`：Factorio 按钮样式属性。

### 129. `slider_button`

- 行号：`7884-7911`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `width` = `20`：固定宽度。
  - `height` = `12`：固定高度。
  - `padding` = `0`：四边统一内边距。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-click.ogg"`：左键点击音效。

### 130. `left_slider_button`

- 行号：`7914-7939`
- 父样式：`slider_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slider_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-slider.ogg"`：左键点击音效。

### 131. `right_slider_button`

- 行号：`7941-7966`
- 父样式：`slider_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slider_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。
  - `disabled_graphical_set` = `〈table〉`：禁用状态外观图形集。
  - `left_click_sound` = `"__core__/sound/gui-slider.ogg"`：左键点击音效。

### 132. `slider`

- 行号：`7968-8049`
- 父样式：无
- 直接属性：
  - `type` = `"slider_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `minimal_width` = `160`：最小宽度。
  - `height` = `12`：固定高度。
  - `ignored_by_search` = `true`：是否被样式搜索或调试搜索忽略。
  - `full_bar` = `〈table〉`：Factorio 按钮样式属性。
  - `full_bar_disabled` = `〈table〉`：Factorio 按钮样式属性。
  - `empty_bar` = `〈table〉`：Factorio 按钮样式属性。
  - `empty_bar_disabled` = `〈table〉`：Factorio 按钮样式属性。
  - `draw_notches` = `false`：Factorio 按钮样式属性。
  - `notch` = `〈table〉`：Factorio 按钮样式属性。
  - `button` = `〈table〉`：Factorio 按钮样式属性。

### 133. `notched_slider`

- 行号：`8051-8085`
- 父样式：`slider`
- 直接属性：
  - `type` = `"slider_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slider"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `height` = `20`：固定高度。
  - `draw_notches` = `true`：Factorio 按钮样式属性。
  - `button` = `〈table〉`：Factorio 按钮样式属性。

### 134. `double_slider`

- 行号：`8087-8148`
- 父样式：无
- 直接属性：
  - `type` = `"double_slider_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `button` = `〈table〉`：Factorio 按钮样式属性。
  - `high_button` = `〈table〉`：Factorio 按钮样式属性。
  - `minimal_width` = `160`：最小宽度。
  - `height` = `12`：固定高度。
  - `full_bar` = `〈table〉`：Factorio 按钮样式属性。
  - `full_bar_disabled` = `〈table〉`：Factorio 按钮样式属性。
  - `empty_bar` = `〈table〉`：Factorio 按钮样式属性。
  - `empty_bar_disabled` = `〈table〉`：Factorio 按钮样式属性。
  - `draw_notches` = `false`：Factorio 按钮样式属性。
  - `notch` = `〈table〉`：Factorio 按钮样式属性。

### 135. `entity_variation_button`

- 行号：`8829-8837`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `100`：固定宽高相等的尺寸。
  - `left_padding` = `2`：左内边距。
  - `right_padding` = `5`：右内边距。
  - `top_padding` = `2`：上内边距。
  - `bottom_padding` = `5`：下内边距。

### 136. `tile_variation_button`

- 行号：`8839-8844`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `100`：固定宽高相等的尺寸。
  - `padding` = `2`：四边统一内边距。

### 137. `train_schedule_fulfilled_delete_button`

- 行号：`9010-9020`
- 父样式：`train_schedule_delete_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"train_schedule_delete_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `false`：悬停或切换状态时是否反转图片颜色。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 138. `train_schedule_partially_fulfilled_delete_button`

- 行号：`9021-9031`
- 父样式：`train_schedule_delete_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"train_schedule_delete_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `false`：悬停或切换状态时是否反转图片颜色。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 139. `train_schedule_temporary_station_delete_button`

- 行号：`9033-9043`
- 父样式：`train_schedule_delete_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"train_schedule_delete_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `false`：悬停或切换状态时是否反转图片颜色。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 140. `other_settings_gui_button`

- 行号：`9085-9090`
- 父样式：`button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `width` = `120`：固定宽度。

### 141. `dark_button`

- 行号：`9145-9153`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。

### 142. `train_schedule_delete_button`

- 行号：`9207-9216`
- 父样式：`dark_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"dark_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `padding` = `0`：四边统一内边距。
  - `width` = `16`：固定宽度。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `true`：悬停或切换状态时是否反转图片颜色。
  - `left_click_sound` = `"__core__/sound/gui-tool-button.ogg"`：左键点击音效。

### 143. `train_schedule_collapse_button`

- 行号：`9218-9223`
- 父样式：`train_schedule_delete_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"train_schedule_delete_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `size` = `28`：固定宽高相等的尺寸。

### 144. `train_schedule_condition_time_selection_button`

- 行号：`9283-9288`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `width` = `84`：固定宽度。
  - `left_click_sound` = `"__core__/sound/gui-menu-small.ogg"`：左键点击音效。

### 145. `shortcut_bar_expand_button`

- 行号：`9290-9310`
- 父样式：`frame_button`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"frame_button"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `width` = `8`：固定宽度。
  - `height` = `16`：固定高度。
  - `left_click_sound` = `"__core__/sound/gui-shortcut-expand.ogg"`：左键点击音效。
  - `left_padding` = `-2`：左内边距。
  - `right_padding` = `-2`：右内边距。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `true`：悬停或切换状态时是否反转图片颜色。
  - `selected_graphical_set` = `〈table〉`：选中状态外观图形集。
  - `selected_hovered_graphical_set` = `〈table〉`：选中且悬停状态外观图形集。

### 146. `choose_chat_icon_button`

- 行号：`9452-9487`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `28`：固定宽高相等的尺寸。
  - `padding` = `4`：四边统一内边距。
  - `right_margin` = `-6`：右外边距。
  - `top_margin` = `-3`：上外边距。
  - `default_graphical_set` = `{}`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 147. `choose_chat_icon_in_textbox_button`

- 行号：`9489-9525`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `size` = `28`：固定宽高相等的尺寸。
  - `padding` = `4`：四边统一内边距。
  - `right_margin` = `-6`：右外边距。
  - `bottom_margin` = `-4`：下外边距。
  - `invert_colors_of_picture_when_hovered_or_toggled` = `true`：悬停或切换状态时是否反转图片颜色。
  - `default_graphical_set` = `{}`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 148. `decider_combinator_signal_select_button`

- 行号：`9641-9688`
- 父样式：`slot_button_in_shallow_frame`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_button_in_shallow_frame"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 149. `decider_combinator_fulfilled_signal_select_button`

- 行号：`9690-9737`
- 父样式：`slot_button_in_shallow_frame`
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `parent` = `"slot_button_in_shallow_frame"`：继承的父样式名。未在当前样式中直接定义的属性，会从父样式链继承。
  - `default_graphical_set` = `〈table〉`：默认状态外观图形集。
  - `hovered_graphical_set` = `〈table〉`：鼠标悬停状态外观图形集。
  - `clicked_graphical_set` = `〈table〉`：按下状态外观图形集。

### 150. `add_logistic_section_button`

- 行号：`9739-9743`
- 父样式：无
- 直接属性：
  - `type` = `"button_style"`：样式类型。这里筛选的是 `button_style`，表示该样式可用于按钮类 GUI 元素。
  - `height` = `40`：固定高度。
