require('__base__/script/freeplay/control.lua')

-- ============================================================
-- 词汇卡片场景脚本
-- 每隔 3 分钟弹出单词卡片，支持 7 本词书切换，多词性分行显示
-- 词书来源：KyleBing/english-vocabulary
-- ============================================================

local INTERVAL = 3 * 60 * 60  -- 3 分钟（单位：tick，60 tick/秒）

-- 词书列表，顺序决定选择面板中的显示顺序
local BOOKS = {
    {id = "junior", name = "初中",  words = require("word_list_junior")},
    {id = "senior", name = "高中",  words = require("word_list_senior")},
    {id = "cet4",   name = "四级",  words = require("word_list_cet4")},
    {id = "cet6",   name = "六级",  words = require("word_list_cet6")},
    {id = "kaoyan", name = "考研",  words = require("word_list_kaoyan")},
    {id = "toefl",  name = "托福",  words = require("word_list_toefl")},
    {id = "sat",    name = "SAT",   words = require("word_list_sat")},
}
local BOOK_MAP = {}
for _, b in ipairs(BOOKS) do BOOK_MAP[b.id] = b end

-- ============================================================
-- 链接 freeplay 的原有事件处理器
-- 必须在注册自己的处理器之前 get，否则会覆盖 freeplay 逻辑
-- ============================================================
local _fp_gui_click = script.get_event_handler(defines.events.on_gui_click)
local _fp_tick      = script.get_event_handler(defines.events.on_tick)
local _fp_joined    = script.get_event_handler(defines.events.on_player_joined_game)

-- ============================================================
-- 存档数据结构（storage 在 Factorio 2.0 中替代 global）
--
-- storage.vocab[player_index] = {
--   active   = "cet4",          -- 当前词书 id
--   card_loc = {x, y},          -- 卡片上次位置（拖拽后保存）
--   [bid]    = {                 -- 每本词书独立保存进度
--     order      = {1,3,2,...},  -- 打乱后的单词索引序列
--     pos        = 1,            -- 当前在 order 中的位置
--     next_tick  = 0,            -- 下次自动翻页的 tick
--   },
-- }
-- ============================================================

-- Fisher-Yates 洗牌，用于初始化词序
local function shuffle(arr)
    for i = #arr, 2, -1 do
        local j = math.random(1, i)
        arr[i], arr[j] = arr[j], arr[i]
    end
end

-- 获取玩家数据，首次访问时初始化
local function get_pdata(pidx)
    if not storage.vocab then storage.vocab = {} end
    if not storage.vocab[pidx] then
        storage.vocab[pidx] = {active = "cet4"}
    end
    return storage.vocab[pidx]
end

-- 获取指定词书的进度，首次访问时生成随机词序
local function get_book_prog(pidx, bid)
    local pd    = get_pdata(pidx)
    local words = BOOK_MAP[bid].words
    if not pd[bid] then
        local order = {}
        for i = 1, #words do order[i] = i end
        shuffle(order)
        pd[bid] = {order = order, pos = 1, next_tick = game.tick + INTERVAL}
    end
    return pd[bid]
end

-- 返回当前激活的 bid、book、prog
local function get_active(pidx)
    local pd   = get_pdata(pidx)
    local bid  = pd.active or "cet4"
    local book = BOOK_MAP[bid]
    local prog = get_book_prog(pidx, bid)
    return bid, book, prog
end

-- ============================================================
-- GUI 工具函数
-- ============================================================

-- 用富文本将释义字符串里的词性标签（adj. n. vt. 等）着色为浅蓝色
local function fmt_meaning(m)
    local out = {}
    for line in (m .. "\n"):gmatch("([^\n]*)\n") do
        if line ~= "" then
            local pos, rest = line:match("^([%a][%a&]*%.) (.+)")
            if pos then
                line = "[color=0.5,0.8,1]" .. pos .. "[/color] " .. rest
            end
            out[#out + 1] = line
        end
    end
    return table.concat(out, "\n")
end

-- 卡片关闭或翻词前保存位置，下次打开时恢复
local function persist_card_loc(player)
    local card = player.gui.screen.vocab_card
    if card and card.valid then
        get_pdata(player.index).card_loc = card.location
    end
end

-- 创建紧凑小按钮（Factorio 2.0 无 small_button 样式，手动覆盖尺寸）
local function small_btn(parent, name, caption)
    local b = parent.add{type = "button", name = name, caption = caption}
    b.style.minimal_width  = 10
    b.style.height         = 26
    b.style.top_padding    = 1
    b.style.bottom_padding = 1
    b.style.left_padding   = 6
    b.style.right_padding  = 6
    b.style.font           = "default-small"
    return b
end

-- 在 flow 中插入可拖拽区域并绑定到 target frame
-- flow 元素本身不响应鼠标拖拽，必须用 empty-widget + draggable_space
local function add_drag(flow, target)
    local d = flow.add{type = "empty-widget", style = "draggable_space"}
    d.style.horizontally_stretchable = true
    d.style.height = 24
    d.drag_target = target
    return d
end

-- ============================================================
-- 书目选择面板
-- ============================================================
local function show_book_select(player)
    -- 再次点击"书"按钮时关闭面板（toggle 行为）
    local existing = player.gui.screen.vocab_book_select
    if existing and existing.valid then existing.destroy() ; return end

    local pidx      = player.index
    local pd        = get_pdata(pidx)
    local active_id = pd.active or "cet4"
    local card      = player.gui.screen.vocab_card
    local cx = card and card.valid and card.location.x or 10
    local cy = card and card.valid and card.location.y or 80

    local frame = player.gui.screen.add{
        type = "frame", name = "vocab_book_select", direction = "vertical",
    }
    frame.style.width = 280
    frame.location    = {x = cx, y = cy + 165}  -- 紧贴卡片下方

    local th = frame.add{type = "flow", direction = "horizontal"}
    th.style.vertical_align = "center"
    th.add{type = "label", caption = "选择词书"}.style.font = "default-bold"
    add_drag(th, frame)
    small_btn(th, "vocab_book_select_close", "×")

    frame.add{type = "line"}

    -- 每本书一个按钮，显示名称、总词数、当前进度
    for _, book in ipairs(BOOKS) do
        local prog  = get_book_prog(pidx, book.id)
        local is_on = (book.id == active_id)
        local btn = frame.add{
            type    = "button",
            name    = "vocab_book_" .. book.id,
            caption = string.format("%s%s  (%d词)  %d/%d",
                is_on and "▶ " or "   ", book.name,
                #book.words, prog.pos, #book.words),
        }
        btn.style.horizontally_stretchable = true
        btn.style.height = 36
        if is_on then btn.style.font = "default-bold" end
    end
end

-- ============================================================
-- 总览面板（滚动列表，当前词高亮）
-- ============================================================
local function show_overview(player, force_loc)
    local existing = player.gui.screen.vocab_overview
    if existing and existing.valid then
        -- force_loc 不为 nil 时在原位刷新（翻词后同步高亮），否则 toggle
        if not force_loc then existing.destroy() ; return end
        existing.destroy()
    end

    local pidx = player.index
    local _, book, prog = get_active(pidx)
    local current_idx = prog.order[prog.pos]  -- 当前单词在 words 表中的原始索引
    local card = player.gui.screen.vocab_card
    local cx   = card and card.valid and card.location.x or 10
    local cy   = card and card.valid and card.location.y or 80
    local loc  = force_loc or {x = cx + 310, y = cy}

    local ov = player.gui.screen.add{
        type = "frame", name = "vocab_overview", direction = "vertical",
    }
    ov.style.width  = 480
    ov.style.height = 480
    ov.location     = loc

    local th = ov.add{type = "flow", direction = "horizontal"}
    th.style.vertical_align = "center"
    th.add{type = "label", caption = book.name .. "  总览"}.style.font = "default-bold"
    add_drag(th, ov)
    th.add{type = "label",
        caption = string.format("(%d词)", #book.words)}.style.font = "default-small"
    small_btn(th, "vocab_overview_close", "×")

    ov.add{type = "line"}

    local scroll = ov.add{type = "scroll-pane", direction = "vertical",
        horizontal_scroll_policy = "never"}
    scroll.style.horizontally_stretchable = true
    scroll.style.vertically_stretchable   = true

    -- 两列：单词 | 释义（按词书原始顺序，不按随机翻页顺序）
    local tbl = scroll.add{type = "table", column_count = 2}
    tbl.style.horizontal_spacing = 12
    tbl.style.vertical_spacing   = 1

    local hi = {r = 0.95, g = 0.75, b = 0.1}  -- 高亮色：金黄
    for i, word in ipairs(book.words) do
        local lw = tbl.add{type = "label", caption = word.w}
        lw.style.minimal_width = 130
        local lm = tbl.add{type = "label", caption = fmt_meaning(word.m)}
        lm.style.minimal_width = 300
        lm.style.single_line   = false
        if i == current_idx then
            lw.style.font_color = hi
            lm.style.font_color = hi
        end
    end
end

-- ============================================================
-- 单词卡片主体
-- ============================================================
local function show_vocab_gui(player)
    persist_card_loc(player)
    local pidx = player.index
    local pd   = get_pdata(pidx)
    local bid, book, prog = get_active(pidx)

    -- 清除旧卡片和折叠按钮
    local tb = player.gui.screen.vocab_btn
    if tb and tb.valid then tb.destroy() end
    local old = player.gui.screen.vocab_card
    if old and old.valid then old.destroy() end

    local word = book.words[prog.order[prog.pos]]
    local loc  = pd.card_loc or {x = 10, y = 80}

    local frame = player.gui.screen.add{
        type = "frame", name = "vocab_card", direction = "vertical",
    }
    frame.style.width = 340
    frame.location    = loc

    -- 标题行：[书名] [书] ===拖拽=== [当前/总数]
    local tf = frame.add{type = "flow", direction = "horizontal"}
    tf.style.vertical_align = "center"
    tf.add{type = "label", caption = book.name}.style.font = "default-bold"
    small_btn(tf, "vocab_book_select", "书")
    add_drag(tf, frame)
    tf.add{
        type    = "label",
        caption = string.format("%d / %d", prog.pos, #book.words),
    }.style.font = "default-small"

    frame.add{type = "line"}

    -- 单词（加大上下边距，让它更突出）
    local lw = frame.add{type = "label", caption = word.w}
    lw.style.font          = "default-large-bold"
    lw.style.top_margin    = 10
    lw.style.bottom_margin = 6
    lw.style.left_margin   = 2

    -- 释义：词性标签着色，多行显示
    local lm = frame.add{type = "label", caption = fmt_meaning(word.m)}
    lm.style.single_line   = false
    lm.style.bottom_margin = 10
    lm.style.left_margin   = 2

    -- 按钮行：[< 上一个] [总览] <弹性空白> [下一个 >] [关]
    local bf = frame.add{type = "flow", direction = "horizontal"}
    bf.style.horizontal_spacing = 4
    small_btn(bf, "vocab_prev",     "< 上一个")
    small_btn(bf, "vocab_overview", "总览")
    local sp = bf.add{type = "empty-widget"}
    sp.style.horizontally_stretchable = true
    small_btn(bf, "vocab_next",  "下一个 >")
    small_btn(bf, "vocab_close", "关")

    -- 如果总览面板已开，在原位刷新高亮
    local ov = player.gui.screen.vocab_overview
    if ov and ov.valid then show_overview(player, ov.location) end
    -- 翻词时关闭书目面板
    local bs = player.gui.screen.vocab_book_select
    if bs and bs.valid then bs.destroy() end
end

-- 折叠：关闭卡片和所有子面板，改为一个小"词汇"按钮
local function collapse_to_btn(player)
    persist_card_loc(player)
    for _, name in ipairs{"vocab_card","vocab_overview","vocab_book_select"} do
        local g = player.gui.screen[name]
        if g and g.valid then g.destroy() end
    end
    if player.gui.screen.vocab_btn then return end
    local btn = player.gui.screen.add{type = "button", name = "vocab_btn", caption = "词汇"}
    btn.style.minimal_width  = 10
    btn.style.height         = 26
    btn.style.top_padding    = 1
    btn.style.bottom_padding = 1
    btn.style.left_padding   = 8
    btn.style.right_padding  = 8
    btn.style.font           = "default-small"
    btn.location             = {x = 10, y = 80}
end

-- 翻页（delta = 1 下一个，-1 上一个），同时重置计时器
local function move_word(player, delta)
    persist_card_loc(player)
    local pidx = player.index
    local _, book, prog = get_active(pidx)
    prog.pos       = ((prog.pos - 1 + delta) % #book.words) + 1
    prog.next_tick = game.tick + INTERVAL
    show_vocab_gui(player)
end

-- 切换词书并立即刷新卡片
local function switch_book(player, new_bid)
    if not BOOK_MAP[new_bid] then return end
    get_pdata(player.index).active = new_bid
    show_vocab_gui(player)
end

-- ============================================================
-- 事件注册
-- ============================================================

-- 所有属于本脚本的按钮名称，用于与 freeplay 按钮区分
local MY_BTNS = {
    vocab_next              = true,
    vocab_prev              = true,
    vocab_close             = true,
    vocab_btn               = true,
    vocab_overview          = true,
    vocab_overview_close    = true,
    vocab_book_select       = true,
    vocab_book_select_close = true,
    vocab_book_junior       = true,
    vocab_book_senior       = true,
    vocab_book_cet4         = true,
    vocab_book_cet6         = true,
    vocab_book_kaoyan       = true,
    vocab_book_toefl        = true,
    vocab_book_sat          = true,
}

script.on_event(defines.events.on_gui_click, function(e)
    local elem = e.element
    if not (elem and elem.valid) then
        if _fp_gui_click then _fp_gui_click(e) end
        return
    end
    local name   = elem.name
    local player = game.players[e.player_index]
    if MY_BTNS[name] then
        if not (player and player.valid) then return end
        if     name == "vocab_next"              then move_word(player,  1)
        elseif name == "vocab_prev"              then move_word(player, -1)
        elseif name == "vocab_close"             then collapse_to_btn(player)
        elseif name == "vocab_btn"               then show_vocab_gui(player)
        elseif name == "vocab_overview"          then show_overview(player)
        elseif name == "vocab_overview_close"    then
            local g = player.gui.screen.vocab_overview
            if g and g.valid then g.destroy() end
        elseif name == "vocab_book_select"       then show_book_select(player)
        elseif name == "vocab_book_select_close" then
            local g = player.gui.screen.vocab_book_select
            if g and g.valid then g.destroy() end
        else
            -- vocab_book_<id>：从按钮名提取词书 id 后切换
            local bid = name:match("^vocab_book_(.+)$")
            if bid then switch_book(player, bid) end
        end
    else
        if _fp_gui_click then _fp_gui_click(e) end
    end
end)

script.on_event(defines.events.on_player_joined_game, function(e)
    if _fp_joined then _fp_joined(e) end
    local player = game.players[e.player_index]
    if player and player.valid then show_vocab_gui(player) end
end)

script.on_event(defines.events.on_tick, function(e)
    if _fp_tick then _fp_tick(e) end
    if not storage.vocab then return end
    for _, player in pairs(game.connected_players) do
        local pidx = player.index
        local pd   = storage.vocab[pidx]
        if pd then
            local bid  = pd.active or "cet4"
            local prog = pd[bid]
            local book = BOOK_MAP[bid]
            if prog and book and e.tick >= prog.next_tick then
                prog.pos       = (prog.pos % #book.words) + 1
                prog.next_tick = e.tick + INTERVAL
                show_vocab_gui(player)
            end
        end
    end
end)
