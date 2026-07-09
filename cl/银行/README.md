# 银行系统 MEMORY

## 功能
顶栏「银行」按钮打开浮动面板。左栏是可手动合成的建筑实体图标网格，右栏是选中物品、数量输入、贷款按钮、贷款明细。

## 面板布局
frame (bank_frame)
├── 标题栏（可拖拽）+ 关闭按钮
└── content (bank_content, 横向)
    ├── left_p (bank_left, 纵向, 自适应屏幕)
    │   ├── 分类标签行 (bank_grp_tbl, table 6 列)
    │   ├── 过滤文本框 (bank_filter)
    │   └── 物品格 (bank_item_sp > bank_item_tbl, 10 列)
    │       toggled = 物品在购物车中
    │       左键切换加入/移出购物车；Alt+左键打开百科
    └── right_p (bank_right, 纵向, 240px)
        ├── "购物车" 标签 + "全部贷款" 按钮 (bank_borrow_all)
        ├── 购物车列表 (bank_cart_sp > bank_cart_tbl, 1 列)
        │   └── 每行：[icon+名称] [数量输入框 bank_cqty__+item] [× 移除 bank_crem__+item]
        ├── 贷款明细标签 + 全部还款按钮 (bank_repay_all)
        └── 贷款列表 (bank_debt_sp > bank_debt_tbl, 1列)
            ├── 节一：已贷实体（名称 + "已贷 N 件" + 还款按钮 bank_rp__ + item_name）
            ├── 分隔线
            └── 节二：原料欠款汇总（名称 + "N / 1000"，颜色：>80% 橙，满额红）

## 可贷物品范围
只允许贷款能放置实体的物品（proto.place_result ~= nil），且排除农业植物（place_result.type ~= "plant"）。
排除：铁板/齿轮等中间产品、混凝土等地板砖、模块/武器、Space Age 农业种子等。
注：种子技术上有 place_result（可手动放置），但正常流程由农业塔负责，不应出现在银行贷款列表。

## 贷款上限逻辑
双重上限，两者取严：

### 1. 单品火箭载荷上限（总贷量）
每种物品最多累计贷出 floor(rocket_lift_weight / item.weight) 件；不可入轨（send_to_orbit_mode == "not-sendable"）或 weight ≤ 0 时限额为 1。
- 借贷上限 = `math.max(1, math.floor(1000000 / proto.weight))`
  - proto.weight 以 gram 为单位（辅助文档算法直接使用 gram 值，如 iron-plate=1000、iron-chest=20000）
  - **不检查 send_to_orbit_mode**：该属性默认 "not-sendable"（铁箱等基础建筑未显式声明），但工具提示仍显示火箭载荷，计算应以重量为准
  - weight ≤ 0 时限额为 1；weight > 1,000,000 时 floor 为 0 → max(1,0) = 1
  - 注意：stack_size ≠ rocket_payload（离心机 stack=50 但载荷=1，核反应堆 stack=10 但载荷=1）
- 检查在原料上限之前，上限已满直接拒绝并提示件数

### 2. 原料欠款上限（MAX_DEBT = 1000）
get_ingredient_totals() 推算当前所有实体贷款对应的原料量；
遍历配方 solid ingredients，按 floor((MAX_DEBT - cur) / ing.amount) × prod 算最大件数；
取最小值 max_allowed，若 < cnt 截断提示，若 ≤ 0 拒绝。

## 数据
storage.bank_debts[player_index][entity_name] = borrowed_count
storage.bank_cart[player_index][entity_name] = qty（购物车，nil=不在购物车）
storage.bank_category[player_index] = selected_group_name (nil=显示全部)
storage.bank_cols[player_index] = item_cols（按屏幕自适应）
storage.bank_trans[player_index][item_name] = 中文名小写（异步翻译缓存）
storage.bank_trans_map[player_index][lname_key] = item_name（翻译请求映射表）

原料欠量由 get_ingredient_totals() 实时从实体债务推算，不单独存储。

## 还款逻辑
repay_one 两步：
1. 先用成品直接抵扣（减少实体贷款 → 原料欠款自动减少）
2. 用配方直接材料（固态）按配方组数抵扣剩余（同上）

## 尺寸（对齐游戏原生制作菜单）
  item_cols = 10（select_slot_row_count）
  grp_cols  = 6（select_group_row_count）
  grp_btn_w = 75（filter_group_button_tab_slightly_larger 宽度）
  sp_w = max(416, 450) = 450px
  sp_h = min(600, max(300, rh - 200))
  item_sp.horizontal_scroll_policy = "never"

## 手动合成分类
从 prototypes.entity["character"].crafting_categories 动态读取，不硬编码。
_HAND_CRAFT 为模块级缓存。

## 中文搜索
pl.request_translations() + on_string_translated 异步缓存中文名到 bank_trans。
过滤框同时匹配英文 ID 和缓存的中文名小写。

## 物品格悬停提示
每个 sprite-button 同时设置：
- elem_tooltip = {type="recipe", name=d.r_name}：原生配方提示框（原料、制造时间、物品属性）
- tooltip = make_item_tooltip(pl, name)：自定义行，格式"已贷 X 件 / 上限 Y 件"

make_item_tooltip 由 item_rocket_limit(proto) 和当前 bank_debts 推算上限与已贷量。
tooltip 更新时机：
- rebuild_item_grid：全量设置（面板打开、换分类、改过滤、全部还款）
- update_item_tooltip(pl, name)：单按钮更新（贷款单项、单项还款）

## 事件
- on_research_finished: 对同势力的所有已开面板玩家调用 rebuild_left_panel（重建分类标签 + 物品格）
- on_gui_click:
  - top_btn 开关面板；bank_grp__ 切换分类
  - bank_pick__ 左键切换购物车加入/移出 / Alt+左键打开百科
  - bank_borrow_all 全部贷款（遍历购物车后清空购物车并刷新）
  - bank_crem__ 移出购物车单项
  - bank_repay_all 全部还款；bank_rp__ 单项还款
- on_gui_text_changed: bank_filter 过滤重建格子；bank_cqty__ 更新购物车数量
- on_string_translated: 缓存中文名
