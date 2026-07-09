require('__base__/script/freeplay/control.lua')

local MAX_DEBT = 1000

local G = {
    top_btn   = "bank_top_btn",
    frame     = "bank_frame",
    content   = "bank_content",
    left_p    = "bank_left",
    right_p   = "bank_right",
    grp_tbl   = "bank_grp_tbl",
    grp_pfx   = "bank_grp__",
    filter    = "bank_filter",
    item_sp   = "bank_item_sp",
    item_tbl  = "bank_item_tbl",
    cart_sp   = "bank_cart_sp",
    cart_tbl  = "bank_cart_tbl",
    borrow_all= "bank_borrow_all",
    debt_sp   = "bank_debt_sp",
    debt_tbl  = "bank_debt_tbl",
    repay_a   = "bank_repay_all",
    close     = "bank_close_btn",
    pick_pfx  = "bank_pick__",
    rpfx      = "bank_rp__",
    cqty_pfx  = "bank_cqty__",
    crem_pfx  = "bank_crem__",
}

local function init_storage()
    if not storage.bank_debts      then storage.bank_debts      = {} end
    if not storage.bank_cart       then storage.bank_cart       = {} end  -- [pi][item_name] = qty
    if not storage.bank_category   then storage.bank_category   = {} end
    if not storage.bank_cols       then storage.bank_cols       = {} end
    if not storage.bank_trans      then storage.bank_trans      = {} end
    if not storage.bank_trans_map  then storage.bank_trans_map  = {} end
end

-- LocalisedString 的第一个字符串元素作为 map key（item-name.xxx / entity-name.xxx）
local function lname_key(ls)
    if type(ls) == "string" then return ls end
    if type(ls) == "table"  then return ls[1] or "" end
    return ""
end

script.on_init(init_storage)
script.on_configuration_changed(init_storage)

-- 从角色原型动态读取可手动合成的配方分类，与游戏保持一致
local _HAND_CRAFT

local function get_hand_craft()
    if not _HAND_CRAFT then
        local char = prototypes.entity["character"]
        _HAND_CRAFT = (char and char.crafting_categories)
            or {["crafting"]=true, ["basic-crafting"]=true, ["advanced-crafting"]=true}
    end
    return _HAND_CRAFT
end

local function item_lname(name)
    local p = prototypes.item[name]
    return p and p.localised_name or name
end

local function find_recipe(item_name, force)
    for _, r in pairs(force.recipes) do
        if r.enabled and get_hand_craft()[r.category] then
            for _, p in pairs(r.products) do
                if p.name == item_name then return r end
            end
        end
    end
end

-- 配方每次产出量（处理概率/区间产出）
local function recipe_product_amount(r, item_name)
    for _, p in pairs(r.products) do
        if p.name == item_name then
            return p.amount or (p.amount_min and math.floor((p.amount_min+p.amount_max)/2)) or 1
        end
    end
    return 1
end

-- 将当前贷款债务折算为各原料累计欠量
local function get_ingredient_totals(pi, force)
    local debts = storage.bank_debts[pi]
    if not debts then return {} end
    local totals = {}
    for entity_name, count in pairs(debts) do
        if count > 0 then
            local r = find_recipe(entity_name, force)
            if r then
                local runs = math.ceil(count / recipe_product_amount(r, entity_name))
                for _, ing in pairs(r.ingredients) do
                    if ing.type ~= "fluid" then
                        totals[ing.name] = (totals[ing.name] or 0) + ing.amount * runs
                    end
                end
            end
        end
    end
    return totals
end

local COLS = 10  -- 物品格列数，与制作菜单一致

local function get_craftable_items(force)
    local seen, items = {}, {}
    for _, r in pairs(force.recipes) do
        if r.enabled and get_hand_craft()[r.category] then
            for _, p in pairs(r.products) do
                local proto = prototypes.item[p.name]
                if not seen[p.name] and proto and proto.place_result
                   and proto.place_result.type ~= "plant" then
                    seen[p.name] = true
                    items[#items+1] = {
                        name     = p.name,
                        l_name   = prototypes.item[p.name].localised_name,
                        g_name   = r.group    and r.group.name    or "",
                        g_order  = r.group    and r.group.order    or "",
                        sg_order = r.subgroup and r.subgroup.order or "",
                        sg_name  = r.subgroup and r.subgroup.name  or "",
                        r_order  = r.order,
                        r_name   = r.name,
                    }
                end
            end
        end
    end
    table.sort(items, function(a, b)
        if a.g_order  ~= b.g_order  then return a.g_order  < b.g_order  end
        if a.sg_order ~= b.sg_order then return a.sg_order < b.sg_order end
        return a.r_order < b.r_order
    end)
    return items
end

local function get_craftable_groups(items)
    local seen, groups = {}, {}
    for _, d in ipairs(items) do
        if d.g_name ~= "" and not seen[d.g_name] then
            seen[d.g_name] = true
            groups[#groups+1] = {name=d.g_name, order=d.g_order}
        end
    end
    table.sort(groups, function(a, b) return a.order < b.order end)
    return groups
end

local function get_grp_tbl(pl)
    local f = pl.gui.screen[G.frame]
    if not f then return end
    local c = f[G.content]
    if not c then return end
    local lp = c[G.left_p]
    if not lp then return end
    return lp[G.grp_tbl]
end

local function get_filter_text(pl)
    local f = pl.gui.screen[G.frame]
    if not f then return "" end
    local lp = f[G.content] and f[G.content][G.left_p]
    if not lp then return "" end
    local tf = lp[G.filter]
    return tf and tf.text or ""
end

local function get_debts(pid)
    init_storage()
    if not storage.bank_debts[pid] then storage.bank_debts[pid] = {} end
    return storage.bank_debts[pid]
end

-- ── 还款 ──────────────────────────────────────────────────

-- 尝试用成品或配方直接材料抵还 item 的贷款；返回消息列表
local function repay_one(pl, item, inv, debts, msgs)
    local owed = debts[item]
    if not owed or owed <= 0 then return end

    -- 第一步：用成品直接抵
    local have = inv.get_item_count(item)
    if have > 0 then
        local take = math.min(have, owed)
        inv.remove({name=item, count=take})
        debts[item] = owed - take
        owed = debts[item]
        msgs[#msgs+1] = {"", tostring(take), "×", item_lname(item)}
    end

    -- 第二步：用配方直接材料抵剩余
    if owed > 0 then
        local r = find_recipe(item, pl.force)
        if r then
            local prod = 1
            for _, p in pairs(r.products) do
                if p.name == item then
                    prod = p.amount or (p.amount_min and math.floor((p.amount_min+p.amount_max)/2)) or 1
                    break
                end
            end
            local runs = math.ceil(owed / prod)
            for _, ing in pairs(r.ingredients) do
                if ing.type ~= "fluid" then
                    runs = math.min(runs, math.floor(inv.get_item_count(ing.name) / ing.amount))
                end
            end
            if runs > 0 then
                debts[item] = owed - math.min(runs * prod, owed)
                for _, ing in pairs(r.ingredients) do
                    if ing.type ~= "fluid" then
                        local take = ing.amount * runs
                        inv.remove({name=ing.name, count=take})
                        msgs[#msgs+1] = {"", tostring(take), "×", item_lname(ing.name)}
                    end
                end
            end
        end
    end

    if debts[item] and debts[item] <= 0 then debts[item] = nil end
end

local function do_repay(pl, specific_item)
    local debts = storage.bank_debts[pl.index]
    if not debts then return end
    local inv = pl.get_main_inventory()
    if not inv then return end
    local msgs = {}

    if specific_item then
        repay_one(pl, specific_item, inv, debts, msgs)
    else
        local items = {}
        for item in pairs(debts) do items[#items+1] = item end
        for _, item in ipairs(items) do repay_one(pl, item, inv, debts, msgs) end
    end

    if #msgs > 0 then
        local out = {"", "[银行] 已还款: "}
        for i, m in ipairs(msgs) do
            if i > 1 then out[#out+1] = "，" end
            out[#out+1] = m
        end
        pl.print(out)
    end
end

-- ── 贷款 ──────────────────────────────────────────────────

-- rocket_lift_weight = 1,000,000 grams（来自 utility-constants）
-- proto.weight 以 gram 为单位（辅助文档算法直接使用这一单位）
-- send_to_orbit_mode 不影响工具提示的火箭载荷值，不做检查
local _ROCKET_CAP = 1000000

local function item_rocket_limit(proto)
    local w = proto.weight
    if not w or w <= 0 then return 1 end
    return math.max(1, math.floor(_ROCKET_CAP / w))
end

local function make_item_tooltip(pl, item_name)
    local proto = prototypes.item[item_name]
    if not proto then return nil end
    local rlimit = item_rocket_limit(proto)
    local owed   = ((storage.bank_debts or {})[pl.index] or {})[item_name] or 0
    return string.format("已贷 %d 件 / 上限 %d 件", owed, rlimit)
end

local function do_borrow(pl, name, cnt)
    local r = find_recipe(name, pl.force)
    if not r then
        pl.print({"", "[银行] ", item_lname(name), " 没有可用的手动合成配方"}); return
    end

    -- 单品火箭载荷上限（总贷量不超过该物品的火箭载荷数）
    local proto = prototypes.item[name]
    if proto then
        local rlimit   = item_rocket_limit(proto)
        local cur_owed = ((storage.bank_debts or {})[pl.index] or {})[name] or 0
        if cur_owed >= rlimit then
            pl.print({"", "[银行] ", item_lname(name),
                string.format(" 已达借贷上限（%d 件）", rlimit)})
            return
        end
        cnt = math.min(cnt, rlimit - cur_owed)
    end

    -- 按各原料剩余额度推算最多可贷数量
    local prod        = recipe_product_amount(r, name)
    local cur_totals  = get_ingredient_totals(pl.index, pl.force)
    local max_allowed = cnt

    for _, ing in pairs(r.ingredients) do
        if ing.type ~= "fluid" then
            local cur         = cur_totals[ing.name] or 0
            local avail_runs  = math.floor((MAX_DEBT - cur) / ing.amount)
            local avail_items = avail_runs * prod
            if avail_items < max_allowed then max_allowed = avail_items end
        end
    end

    if max_allowed <= 0 then
        pl.print("[银行] 原料欠款已达上限，无法继续贷款"); return
    end
    if max_allowed < cnt then
        pl.print({"", string.format("[银行] 原料额度不足，仅可贷 %d/%d", max_allowed, cnt)})
        cnt = max_allowed
    end

    local debts = get_debts(pl.index)
    local inv   = pl.get_main_inventory()
    if not inv then pl.print("[银行] 背包不可访问"); return end

    local got = inv.insert({name=name, count=cnt})
    if got > 0 then
        debts[name] = (debts[name] or 0) + got
        pl.print({"", "[银行] 已贷出: ", tostring(got), "×", item_lname(name)})
        if got < cnt then pl.print("[银行] 背包已满: 仅放入 "..got.."/"..cnt) end
    end
end

-- ── GUI 刷新 ──────────────────────────────────────────────

local function get_item_tbl(pl)
    local f = pl.gui.screen[G.frame]
    if not f then return end
    local c = f[G.content]
    if not c then return end
    local lp = c[G.left_p]
    if not lp then return end
    local sp = lp[G.item_sp]
    if not sp then return end
    return sp[G.item_tbl]
end

local function get_right_p(pl)
    local f = pl.gui.screen[G.frame]
    if not f then return end
    local c = f[G.content]
    if not c then return end
    return c[G.right_p]
end

local function rebuild_item_grid(pl, filter, all_items)
    local tbl = get_item_tbl(pl)
    if not tbl then return end
    tbl.clear()
    filter = (filter or ""):lower()
    local cart = (storage.bank_cart or {})[pl.index] or {}
    all_items = all_items or get_craftable_items(pl.force)
    local cols = (storage.bank_cols and storage.bank_cols[pl.index]) or COLS

    -- 筛选（分类 + 文字过滤，同时匹配英文 ID 和缓存的中文名）
    local sel_group = storage.bank_category[pl.index]
    local trans     = storage.bank_trans and storage.bank_trans[pl.index]
    local items = {}
    for _, d in ipairs(all_items) do
        local cn = trans and trans[d.name] or ""
        if (not sel_group or d.g_name == sel_group)
           and (filter == ""
                or d.name:find(filter, 1, true)
                or (cn ~= "" and cn:find(filter, 1, true))) then
            items[#items+1] = d
        end
    end

    local pos    = 0    -- 当前行已填列数（0..cols-1）
    local cur_sg = nil  -- 当前子分组名

    for _, d in ipairs(items) do
        -- 子分组切换时：用空槽填满当前行，使下一组从新行开始
        if cur_sg and d.sg_name ~= cur_sg and pos > 0 then
            for _ = 1, cols - pos do
                tbl.add({type="sprite-button", style="slot_button"})
            end
            pos = 0
        end
        cur_sg = d.sg_name

        local btn = tbl.add({
            type    = "sprite-button",
            name    = G.pick_pfx .. d.name,
            sprite  = "item/" .. d.name,
            style   = "slot_button",
            toggled = cart[d.name] ~= nil,
        })
        if d.r_name then
            btn.elem_tooltip = {type = "recipe", name = d.r_name}
        end
        btn.tooltip = make_item_tooltip(pl, d.name)
        pos = pos + 1
        if pos >= cols then pos = 0 end
    end
end

-- 科技完成后重建分类标签 + 物品格（不重建整个面板，保留右栏和滚动位置）
local function rebuild_left_panel(pl)
    local gt = get_grp_tbl(pl)
    if not gt then return end
    local all_items = get_craftable_items(pl.force)

    -- 请求新物品中文名翻译
    local trans_map = storage.bank_trans_map[pl.index] or {}
    local req = {}
    for _, d in ipairs(all_items) do
        local key = lname_key(d.l_name)
        if key ~= "" and not trans_map[key] then
            trans_map[key] = d.name
            req[#req+1] = d.l_name
        end
    end
    storage.bank_trans_map[pl.index] = trans_map
    if #req > 0 then pl.request_translations(req) end

    -- 重建分类标签（清空再填入最新分组）
    gt.clear()
    local sel_group = storage.bank_category[pl.index]
    for _, g in ipairs(get_craftable_groups(all_items)) do
        gt.add({
            type    = "sprite-button",
            name    = G.grp_pfx .. g.name,
            sprite  = "item-group/" .. g.name,
            style   = "filter_group_button_tab_slightly_larger",
            toggled = g.name == sel_group,
        })
    end

    rebuild_item_grid(pl, get_filter_text(pl), all_items)
end

local function update_item_tooltip(pl, item_name)
    local tbl = get_item_tbl(pl)
    if not tbl then return end
    local btn = tbl[G.pick_pfx .. item_name]
    if btn and btn.valid then btn.tooltip = make_item_tooltip(pl, item_name) end
end

local function refresh_cart(pl)
    local rp = get_right_p(pl)
    if not rp then return end
    local sp = rp[G.cart_sp]
    if not sp then return end
    local tbl = sp[G.cart_tbl]
    if not tbl then return end
    tbl.clear()

    local cart = (storage.bank_cart or {})[pl.index]
    if not cart or not next(cart) then
        local lbl = tbl.add({type="label", caption="← 点击左侧物品加入"})
        lbl.style.font_color = {r=0.6, g=0.6, b=0.6}
        tbl.add({type="empty-widget"})
        return
    end

    for item_name, qty in pairs(cart) do
        local row = tbl.add({type="flow", direction="horizontal"})
        row.style.vertical_align           = "center"
        row.style.horizontally_stretchable = true

        local name_lbl = row.add({
            type    = "label",
            caption = {"", "[item=", item_name, "] ", item_lname(item_name)},
        })
        name_lbl.style.horizontally_stretchable = true
        name_lbl.style.single_line              = true

        local qty_tf = row.add({
            type          = "textfield",
            name          = G.cqty_pfx .. item_name,
            text          = tostring(qty),
            numeric       = true,
            allow_decimal = false,
            allow_negative= false,
        })
        qty_tf.style.width = 48

        local rem = row.add({type="button", name=G.crem_pfx .. item_name, caption="×"})
        rem.style.minimal_width  = 26
        rem.style.height         = 26
        rem.style.top_padding    = 0
        rem.style.bottom_padding = 0
    end
end

local function refresh_debt_list(pl)
    local rp = get_right_p(pl)
    if not rp then return end
    local sp = rp[G.debt_sp]
    if not sp then return end
    local tbl = sp[G.debt_tbl]
    if not tbl then return end
    tbl.clear()
    local debts = storage.bank_debts[pl.index]
    local any = false

    if debts then
        -- 节一：已贷实体列表
        for item, amt in pairs(debts) do
            if amt and amt > 0 then
                any = true
                local row = tbl.add({type="flow", direction="horizontal"})
                row.style.vertical_align           = "center"
                row.style.horizontally_stretchable = true

                local info = row.add({type="flow", direction="vertical"})
                info.style.horizontally_stretchable = true

                local name_lbl = info.add({
                    type    = "label",
                    caption = {"", "[item=", item, "]  ", item_lname(item)},
                })
                name_lbl.style.single_line    = true
                name_lbl.style.maximal_width  = 180
                name_lbl.tooltip              = item_lname(item)

                local amt_lbl = info.add({
                    type    = "label",
                    caption = "已贷 " .. tostring(amt) .. " 件",
                })
                amt_lbl.style.font         = "default-small"
                amt_lbl.style.font_color   = {r=0.6, g=0.6, b=0.6}
                amt_lbl.style.left_padding = 6

                local btn = row.add({
                    type    = "button",
                    name    = G.rpfx .. item,
                    caption = "还款",
                    tooltip = {"", "用背包中的 ", item_lname(item), " 还款"},
                })
                btn.style.minimal_width  = 50
                btn.style.height         = 26
                btn.style.top_padding    = 0
                btn.style.bottom_padding = 0
            end
        end

        -- 节二：原料欠款汇总
        if any then
            local sep = tbl.add({type="line"})
            sep.style.top_margin    = 6
            sep.style.bottom_margin = 2
            local hdr = tbl.add({type="label", caption="原料欠款"})
            hdr.style.font        = "default-small-bold"
            hdr.style.top_padding = 2

            local totals = get_ingredient_totals(pl.index, pl.force)
            local sorted = {}
            for ing_name, amt in pairs(totals) do
                sorted[#sorted+1] = {name=ing_name, amt=amt}
            end
            table.sort(sorted, function(a, b) return a.name < b.name end)

            for _, ing in ipairs(sorted) do
                local row = tbl.add({type="flow", direction="horizontal"})
                row.style.vertical_align           = "center"
                row.style.horizontally_stretchable = true

                local info = row.add({type="flow", direction="vertical"})
                info.style.horizontally_stretchable = true

                local name_lbl = info.add({
                    type    = "label",
                    caption = {"", "[item=", ing.name, "]  ", item_lname(ing.name)},
                })
                name_lbl.style.single_line    = true
                name_lbl.style.maximal_width  = 180
                name_lbl.tooltip              = item_lname(ing.name)

                local pct = ing.amt / MAX_DEBT
                local col = pct >= 1   and {r=0.9, g=0.2, b=0.2}
                         or pct >= 0.8 and {r=0.9, g=0.6, b=0.1}
                         or             {r=0.6, g=0.6, b=0.6}
                local amt_lbl = info.add({
                    type    = "label",
                    caption = tostring(ing.amt) .. " / " .. tostring(MAX_DEBT),
                })
                amt_lbl.style.font         = "default-small"
                amt_lbl.style.font_color   = col
                amt_lbl.style.left_padding = 6
            end
        end
    end

    if not any then
        local lbl = tbl.add({type="label", caption="（暂无贷款）"})
        lbl.style.font_color = {r=0.6, g=0.6, b=0.6}
        tbl.add({type="empty-widget"})
    end
end

-- ── 构建面板 ──────────────────────────────────────────────

local function build_gui(pl)
    if pl.gui.screen[G.frame] then return end
    init_storage()

    -- 尺寸常量（与游戏原生制作菜单对齐）
    local scale     = pl.display_scale
    local rh        = math.floor(pl.display_resolution.height / scale)
    local right_w   = 300
    local slot      = 40
    local item_cols = 10                    -- select_slot_row_count = 10
    local grp_cols  = 6                     -- select_group_row_count = 6
    local grp_btn_w = 75                    -- filter_group_button_tab_slightly_larger 宽度
    local item_sp_w = item_cols * slot + 16 -- 416px（含滚动条）
    local grp_row_w = grp_cols * grp_btn_w  -- 450px
    local sp_w      = math.max(item_sp_w, grp_row_w)
    local sp_h      = math.min(600, math.max(300, rh - 200))
    storage.bank_cols[pl.index] = item_cols

    local frame = pl.gui.screen.add({type="frame", name=G.frame, direction="vertical"})
    frame.auto_center = true

    -- 标题栏（可拖拽）
    local title = frame.add({type="flow", direction="horizontal"})
    title.style.height = 28
    local tlbl = title.add({type="label", caption="银行", style="frame_title"})
    tlbl.style.left_padding = 4
    local spc = title.add({type="empty-widget", style="draggable_space_header"})
    spc.drag_target = frame
    spc.style.horizontally_stretchable = true
    spc.style.height = 24
    title.add({type="sprite-button", name=G.close, sprite="utility/close",
        style="frame_action_button", tooltip="关闭"})

    -- 主体（左右分栏）
    local content = frame.add({type="flow", name=G.content, direction="horizontal"})
    content.style.top_margin = 6

    -- 左栏：物品选择器
    local left_p = content.add({type="flow", name=G.left_p, direction="vertical"})
    left_p.style.right_margin = 8

    left_p.add({type="label", caption="可贷物品"}).style.font = "default-bold"

    -- 分类标签行（与游戏制作菜单一致）
    local all_items = get_craftable_items(pl.force)

    -- 请求中文名翻译（异步，结果由 on_string_translated 缓存到 storage.bank_trans）
    local trans_map = {}
    local req = {}
    for _, d in ipairs(all_items) do
        local key = lname_key(d.l_name)
        if key ~= "" and not trans_map[key] then
            trans_map[key] = d.name
            req[#req+1] = d.l_name
        end
    end
    storage.bank_trans_map[pl.index] = trans_map
    if #req > 0 then pl.request_translations(req) end
    local grp_tbl = left_p.add({type="table", name=G.grp_tbl, column_count=grp_cols})
    grp_tbl.style.top_margin = 4
    local sel_group = storage.bank_category[pl.index]
    for _, g in ipairs(get_craftable_groups(all_items)) do
        grp_tbl.add({
            type    = "sprite-button",
            name    = G.grp_pfx .. g.name,
            sprite  = "item-group/" .. g.name,
            style   = "filter_group_button_tab_slightly_larger",
            toggled = g.name == sel_group,
        })
    end

    local filter_tf = left_p.add({type="textfield", name=G.filter, text="",
        tooltip="按英文 ID 过滤（如 iron-plate）"})
    filter_tf.style.top_margin = 4
    filter_tf.style.width = sp_w - 4

    local item_sp = left_p.add({type="scroll-pane", name=G.item_sp, direction="vertical"})
    item_sp.style.top_margin    = 4
    item_sp.style.width         = sp_w
    item_sp.style.height        = sp_h
    item_sp.horizontal_scroll_policy = "never"
    item_sp.add({type="table", name=G.item_tbl, column_count=item_cols})

    -- 右栏：选中物品 + 贷款 + 还款
    local right_p = content.add({type="flow", name=G.right_p, direction="vertical"})
    right_p.style.width = right_w

    -- 购物车标题 + 全部贷款
    local ch = right_p.add({type="flow", direction="horizontal"})
    ch.style.vertical_align = "center"
    local clbl = ch.add({type="label", caption="购物车"})
    clbl.style.font = "default-bold"
    clbl.style.horizontally_stretchable = true
    right_p.add({type="button", name=G.borrow_all, caption="全部贷款",
        style="green_button", tooltip="按购物车清单贷出全部物品"}).style.top_margin = 2

    -- 购物车列表
    local cart_sp = right_p.add({type="scroll-pane", name=G.cart_sp, direction="vertical"})
    cart_sp.style.top_margin               = 4
    cart_sp.style.maximal_height           = 220
    cart_sp.style.horizontally_stretchable = true
    cart_sp.horizontal_scroll_policy       = "never"
    cart_sp.add({type="table", name=G.cart_tbl, column_count=1}).style.horizontally_stretchable = true

    right_p.add({type="line"}).style.top_margin = 10

    local dh = right_p.add({type="flow", direction="horizontal"})
    dh.style.top_margin = 6
    local dlbl = dh.add({type="label", caption="贷款明细"})
    dlbl.style.font = "default-bold"
    dlbl.style.horizontally_stretchable = true
    right_p.add({type="button", name=G.repay_a, caption="全部还款",
        tooltip="用背包中现有材料偿还所有贷款"}).style.top_margin = 4

    local debt_sp = right_p.add({type="scroll-pane", name=G.debt_sp, direction="vertical"})
    debt_sp.style.top_margin             = 4
    debt_sp.style.maximal_height         = 250
    debt_sp.style.horizontally_stretchable = true
    debt_sp.add({type="table", name=G.debt_tbl, column_count=1}).style.horizontally_stretchable = true

    rebuild_item_grid(pl, "", all_items)
    refresh_cart(pl)
    refresh_debt_list(pl)
end

-- ── 玩家初始化 ────────────────────────────────────────────

local function setup_player(pl)
    if pl.gui.top[G.top_btn] then return end
    pl.gui.top.add({type="button", name=G.top_btn, caption="银行", tooltip="打开银行面板"})
end

script.on_event(defines.events.on_player_created,     function(e) setup_player(game.players[e.player_index]) end)
script.on_event(defines.events.on_player_joined_game, function(e) setup_player(game.players[e.player_index]) end)

-- ── GUI 事件 ──────────────────────────────────────────────

script.on_event(defines.events.on_gui_click, function(e)
    local pl   = game.players[e.player_index]
    local name = e.element.name

    if name == G.top_btn then
        if pl.gui.screen[G.frame] then pl.gui.screen[G.frame].destroy() else build_gui(pl) end

    elseif name == G.close then
        if pl.gui.screen[G.frame] then pl.gui.screen[G.frame].destroy() end

    elseif name:sub(1, #G.grp_pfx) == G.grp_pfx then
        -- 点击分类标签：选中该分类，再次点击取消（显示全部）
        local group = name:sub(#G.grp_pfx + 1)
        local prev  = storage.bank_category[pl.index]
        local gt    = get_grp_tbl(pl)
        if gt then
            if prev and gt[G.grp_pfx .. prev] then gt[G.grp_pfx .. prev].toggled = false end
            if group ~= prev then
                storage.bank_category[pl.index] = group
                if gt[G.grp_pfx .. group] then gt[G.grp_pfx .. group].toggled = true end
            else
                storage.bank_category[pl.index] = nil  -- 取消选中 → 显示全部
            end
        else
            storage.bank_category[pl.index] = (group ~= prev) and group or nil
        end
        rebuild_item_grid(pl, get_filter_text(pl))

    elseif name:sub(1, #G.pick_pfx) == G.pick_pfx then
        local item = name:sub(#G.pick_pfx + 1)
        if e.alt then
            local proto = prototypes.item[item]
            if proto then pl.open_factoriopedia_gui(proto) end
        else
            -- 左键：切换加入/移出购物车
            if not storage.bank_cart[pl.index] then storage.bank_cart[pl.index] = {} end
            local cart = storage.bank_cart[pl.index]
            local btn  = e.element
            if cart[item] then
                cart[item] = nil
                btn.toggled = false
            else
                cart[item] = 1
                btn.toggled = true
            end
            refresh_cart(pl)
        end

    elseif name == G.borrow_all then
        local cart = (storage.bank_cart or {})[pl.index]
        if not cart or not next(cart) then pl.print("[银行] 购物车为空"); return end
        for item_name, qty in pairs(cart) do
            do_borrow(pl, item_name, qty)
        end
        storage.bank_cart[pl.index] = {}
        refresh_cart(pl)
        refresh_debt_list(pl)
        rebuild_item_grid(pl, get_filter_text(pl))

    elseif name:sub(1, #G.crem_pfx) == G.crem_pfx then
        -- 移出购物车
        local item = name:sub(#G.crem_pfx + 1)
        if storage.bank_cart[pl.index] then storage.bank_cart[pl.index][item] = nil end
        local tbl = get_item_tbl(pl)
        if tbl and tbl[G.pick_pfx .. item] then tbl[G.pick_pfx .. item].toggled = false end
        refresh_cart(pl)

    elseif name == G.repay_a then
        do_repay(pl, nil)
        refresh_debt_list(pl)
        rebuild_item_grid(pl, get_filter_text(pl))

    elseif name:sub(1, #G.rpfx) == G.rpfx then
        local item = name:sub(#G.rpfx + 1)
        do_repay(pl, item)
        refresh_debt_list(pl)
        update_item_tooltip(pl, item)
    end
end)

-- 翻译完成 → 缓存中文名，供过滤框搜索使用
script.on_event(defines.events.on_string_translated, function(e)
    if not e.translated then return end
    local tmap = storage.bank_trans_map and storage.bank_trans_map[e.player_index]
    if not tmap then return end
    local key = lname_key(e.localised_string)
    local item_name = tmap[key]
    if not item_name then return end
    if not storage.bank_trans[e.player_index] then
        storage.bank_trans[e.player_index] = {}
    end
    storage.bank_trans[e.player_index][item_name] = e.result:lower()
end)

-- 科技研究完成 → 对同势力的所有已开面板玩家刷新左栏
script.on_event(defines.events.on_research_finished, function(e)
    for _, pl in pairs(game.players) do
        if pl.valid and pl.force == e.research.force and pl.gui.screen[G.frame] then
            rebuild_left_panel(pl)
        end
    end
end)

-- 文字变化：过滤框重建格子；购物车数量框更新 storage
script.on_event(defines.events.on_gui_text_changed, function(e)
    local ename = e.element.name
    if ename == G.filter then
        rebuild_item_grid(game.players[e.player_index], e.element.text)
    elseif ename:sub(1, #G.cqty_pfx) == G.cqty_pfx then
        local item = ename:sub(#G.cqty_pfx + 1)
        local cart = storage.bank_cart and storage.bank_cart[e.player_index]
        if cart and cart[item] then
            cart[item] = math.max(1, math.floor(tonumber(e.element.text) or 1))
        end
    end
end)
