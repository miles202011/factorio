require('__base__/script/freeplay/control.lua')

local handler = require("event_handler")

local G = {
    top = "ttt_top_btn",
    lobby = "ttt_lobby_frame",
    table = "ttt_table_frame",
    open = "ttt_open_table",
    close = "ttt_close",
    back = "ttt_back_lobby",
    leave = "ttt_leave",
    ready = "ttt_ready",
    unready = "ttt_unready",
    add_ai = "ttt_add_ai",
    kick_ai = "ttt_kick_ai",
    again = "ttt_again",
    stats = "ttt_stats_open",
    stats_close = "ttt_stats_close",
    rules = "ttt_rules_open",
    rules_close = "ttt_rules_close",
    notice = "ttt_notice_open",
    notice_close = "ttt_notice_close",
    join_pfx = "ttt_join_",
    view_pfx = "ttt_view_",
    cell_pfx = "ttt_cell_",
}

local WIN_LINES = {
    {1, 2, 3}, {4, 5, 6}, {7, 8, 9},
    {1, 4, 7}, {2, 5, 8}, {3, 6, 9},
    {1, 5, 9}, {3, 5, 7},
}

local AI_DELAY_TICKS = 60
local PLAYER_TURN_TICKS = 20 * 60

local function store()
    storage.ttt = storage.ttt or {}
    storage.ttt.tables = storage.ttt.tables or {}
    storage.ttt.seat = storage.ttt.seat or {}
    storage.ttt.next_tid = storage.ttt.next_tid or 1
    storage.ttt.stats = storage.ttt.stats or {}
    storage.ttt.ai_due = storage.ttt.ai_due or {}
    storage.ttt.turn_due = storage.ttt.turn_due or {}
    return storage.ttt
end

local function player(pid)
    if pid and pid > 0 then return game.get_player(pid) end
end

local function is_human(pid)
    return pid and pid > 0
end

local function player_name(pid)
    if not pid then return "空位" end
    if pid < 0 then return "AI 工程师" end
    local p = game.get_player(pid)
    return p and p.name or "离线玩家"
end

local function mark_of_seat(seat)
    return seat == 1 and "X" or "O"
end

local function display_mark(mark)
    if mark == "X" then return "Ｘ" end
    if mark == "O" then return "Ｏ" end
    return " "
end

local function seat_of_pid(g, pid)
    for i = 1, 2 do
        if g.players[i] == pid then return i end
    end
end

local function pid_for_mark(g, mark)
    return g.players[mark == "X" and 1 or 2]
end

local function phase_text(phase)
    if phase == "waiting" then return "等待中" end
    if phase == "playing" then return "对局中" end
    return "已结束"
end

local function add_top_button(p)
    if p and p.valid and not p.gui.top[G.top] then
        p.gui.top.add{type = "button", name = G.top, caption = "井字棋"}
    end
end

local function destroy_if_valid(e)
    if e and e.valid then e.destroy() end
end

local function close_windows(p)
    destroy_if_valid(p.gui.screen[G.lobby])
    destroy_if_valid(p.gui.screen[G.table])
end

local function add_titlebar(frame, title, close_name)
    local bar = frame.add{type = "flow", direction = "horizontal"}
    bar.drag_target = frame
    local title_label = bar.add{type = "label", style = "frame_title", caption = title}
    title_label.drag_target = frame
    local drag = bar.add{type = "empty-widget", style = "draggable_space_header"}
    drag.style.horizontally_stretchable = true
    drag.style.height = 24
    drag.drag_target = frame
    bar.add{
        type = "sprite-button",
        name = close_name,
        style = "frame_action_button",
        sprite = "utility/close",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = "关闭",
    }
end

local function get_game_by_player(pid)
    local s = store()
    local tid = s.seat[pid]
    return tid and s.tables[tid], tid
end

local function first_empty_seat(g)
    if not g.players[1] then return 1 end
    if not g.players[2] then return 2 end
end

local function ai_seat(g)
    for i = 1, 2 do
        if g.players[i] and g.players[i] < 0 then return i end
    end
end

local function count_humans(g)
    local n = 0
    for i = 1, 2 do
        if is_human(g.players[i]) then n = n + 1 end
    end
    return n
end

local function board_full(board)
    for i = 1, 9 do
        if board[i] == "" then return false end
    end
    return true
end

local function winner_mark(board)
    for _, line in ipairs(WIN_LINES) do
        local a, b, c = line[1], line[2], line[3]
        if board[a] ~= "" and board[a] == board[b] and board[a] == board[c] then
            return board[a]
        end
    end
    if board_full(board) then return "draw" end
end

local function update_stats(winner, loser, draw)
    local s = store()
    local function row(pid)
        if not is_human(pid) then return end
        local name = player_name(pid)
        s.stats[name] = s.stats[name] or {w = 0, l = 0, d = 0}
        return s.stats[name]
    end
    if draw then
        local a = row(winner)
        local b = row(loser)
        if a then a.d = a.d + 1 end
        if b then b.d = b.d + 1 end
        return
    end
    local wr = row(winner)
    local lr = row(loser)
    if wr then wr.w = wr.w + 1 end
    if lr then lr.l = lr.l + 1 end
end

local function finish_game(g, mark)
    local s = store()
    s.ai_due[g.tid] = nil
    s.turn_due[g.tid] = nil
    g.phase = "over"
    if mark == "draw" then
        g.msg = "平局，棋盘被填满了。"
        update_stats(g.players[1], g.players[2], true)
        return
    end

    local winner = pid_for_mark(g, mark)
    local loser = pid_for_mark(g, mark == "X" and "O" or "X")
    g.winner = winner
    g.msg = player_name(winner) .. " 获胜。"
    update_stats(winner, loser, false)
end

local function finish_timeout(g)
    if not g or g.phase ~= "playing" or not g.turn or g.turn < 0 then return false end
    local seat = seat_of_pid(g, g.turn)
    if not seat then return false end

    local timed_out = g.turn
    local winner = g.players[seat == 1 and 2 or 1]
    if not winner then return false end

    local s = store()
    s.ai_due[g.tid] = nil
    s.turn_due[g.tid] = nil
    g.phase = "over"
    g.winner = winner
    g.msg = player_name(timed_out) .. " 超时未落子，" .. player_name(winner) .. " 获胜。"
    update_stats(winner, timed_out, false)
    return true
end

local function check_finish(g)
    local mark = winner_mark(g.board)
    if mark then
        finish_game(g, mark)
        return true
    end
    return false
end

local function reset_game(g)
    local s = store()
    s.ai_due[g.tid] = nil
    s.turn_due[g.tid] = nil
    g.phase = "waiting"
    g.ready = {}
    g.board = {"", "", "", "", "", "", "", "", ""}
    g.turn = nil
    g.winner = nil
    g.msg = "等待两名玩家准备。"
    for i = 1, 2 do
        if g.players[i] and g.players[i] < 0 then
            g.ready[g.players[i]] = true
        end
    end
end

local function start_game(g)
    g.phase = "playing"
    g.board = {"", "", "", "", "", "", "", "", ""}
    g.turn = g.players[1]
    g.winner = nil
    g.msg = player_name(g.turn) .. " 先手。"
end

local function can_start(g)
    return g.phase == "waiting"
        and g.players[1] and g.players[2]
        and g.ready[g.players[1]] and g.ready[g.players[2]]
end

local function try_start(g)
    if can_start(g) then start_game(g) end
end

local function would_win(board, mark, pos)
    if board[pos] ~= "" then return false end
    board[pos] = mark
    local ok = winner_mark(board) == mark
    board[pos] = ""
    return ok
end

local function ai_pick(board, ai_mark, human_mark)
    for i = 1, 9 do
        if would_win(board, ai_mark, i) then return i end
    end
    for i = 1, 9 do
        if would_win(board, human_mark, i) then return i end
    end
    if board[5] == "" then return 5 end
    for _, i in ipairs{1, 3, 7, 9} do
        if board[i] == "" then return i end
    end
    for i = 1, 9 do
        if board[i] == "" then return i end
    end
end

local refresh_all

local function do_ai_turn(g)
    if g.phase ~= "playing" or not g.turn or g.turn > 0 then return end
    local ai_seat = seat_of_pid(g, g.turn)
    if not ai_seat then return end

    local ai_mark = mark_of_seat(ai_seat)
    local human_mark = ai_mark == "X" and "O" or "X"
    local pos = ai_pick(g.board, ai_mark, human_mark)
    if not pos then return end

    g.board[pos] = ai_mark
    if check_finish(g) then return end

    local next_seat = ai_seat == 1 and 2 or 1
    g.turn = g.players[next_seat]
    g.msg = "轮到 " .. player_name(g.turn) .. "。"
end

local function schedule_ai_turn(g)
    local s = store()
    if g and g.phase == "playing" and g.turn and g.turn < 0 then
        s.ai_due[g.tid] = game.tick + AI_DELAY_TICKS
    elseif g then
        s.ai_due[g.tid] = nil
    end
end

local function schedule_turn_timer(g)
    local s = store()
    if g and g.phase == "playing" and g.turn and g.turn > 0 then
        s.turn_due[g.tid] = game.tick + PLAYER_TURN_TICKS
    elseif g then
        s.turn_due[g.tid] = nil
    end
end

local function turn_seconds_left(g)
    if not g or g.phase ~= "playing" or not g.turn or g.turn < 0 then return nil end
    local due = store().turn_due[g.tid]
    if not due then return nil end
    local ticks = math.max(0, due - game.tick)
    return math.ceil(ticks / 60)
end

local function refresh_players(g)
    for i = 1, 2 do
        local p = player(g.players[i])
        if p then refresh_all(p) end
    end
end

local function show_rules(p)
    if p.gui.screen.ttt_rules then p.gui.screen.ttt_rules.destroy(); return end
    local f = p.gui.screen.add{type = "frame", name = "ttt_rules", direction = "vertical"}
    f.auto_center = true
    f.style.minimal_width = 430
    add_titlebar(f, "井字棋 · 游戏规则", G.rules_close)

    local function row(title, body)
        local rf = f.add{type = "flow", direction = "horizontal"}
        local lbl = rf.add{type = "label", caption = title}
        lbl.style.font = "default-bold"
        lbl.style.minimal_width = 90
        local bl = rf.add{type = "label", caption = body}
        bl.style.single_line = false
        bl.style.maximal_width = 300
    end

    row("【目标】", "在 3x3 棋盘上率先连成横、竖或斜向三子。")
    row("【座位】", "1号位执 X 先手，2号位执 O 后手。")
    row("【流程】", "双方入座并准备后开始；轮到自己时点击空格落子。")
    row("【限时】", "真人玩家每回合 20 秒内落子，超时判对方获胜。")
    row("【平局】", "棋盘填满且无人三连，则本局平局。")
end

local function show_notice(p)
    if p.gui.screen.ttt_notice then p.gui.screen.ttt_notice.destroy(); return end
    local f = p.gui.screen.add{type = "frame", name = "ttt_notice", direction = "vertical"}
    f.auto_center = true
    f.style.minimal_width = 430
    add_titlebar(f, "井字棋 · 注意事项", G.notice_close)

    local function row(title, body)
        local rf = f.add{type = "flow", direction = "horizontal"}
        local lbl = rf.add{type = "label", caption = title}
        lbl.style.font = "default-bold"
        lbl.style.minimal_width = 90
        local bl = rf.add{type = "label", caption = body}
        bl.style.single_line = false
        bl.style.maximal_width = 300
    end

    row("【离桌】", "对局中离桌会让另一方直接获胜。")
    row("【战绩】", "只记录真人玩家的胜、负、平；AI 不记战绩。")
    row("【AI补位】", "等待阶段可加入 AI，也可在开局前踢出 AI。")
    row("【再来】", "结束后点击「再来一局」会回到等待阶段，需要真人重新准备。")
end

local function show_stats(p)
    if p.gui.screen.ttt_stats then p.gui.screen.ttt_stats.destroy(); return end
    local s = store()
    local f = p.gui.screen.add{type = "frame", name = "ttt_stats", direction = "vertical"}
    f.auto_center = true
    f.style.minimal_width = 380
    add_titlebar(f, "井字棋 · 战绩统计", G.stats_close)

    if not next(s.stats) then
        f.add{type = "label", caption = "暂无战绩。"}
        return
    end

    local hf = f.add{type = "flow", direction = "horizontal"}
    local function hcol(text, width)
        local label = hf.add{type = "label", caption = text}
        label.style.font = "default-bold"
        label.style.minimal_width = width
    end
    hcol("玩家", 130)
    hcol("胜", 60)
    hcol("负", 60)
    hcol("平", 60)
    f.add{type = "line"}

    local rows = {}
    for name, stats in pairs(s.stats) do
        rows[#rows + 1] = {name = name, stats = stats, total = (stats.w or 0) + (stats.l or 0) + (stats.d or 0)}
    end
    table.sort(rows, function(a, b)
        if a.total == b.total then return a.name < b.name end
        return a.total > b.total
    end)

    local sc = f.add{type = "scroll-pane", direction = "vertical"}
    sc.style.maximal_height = 300
    for _, row in ipairs(rows) do
        local rf = sc.add{type = "flow", direction = "horizontal"}
        local function col(text, width)
            local label = rf.add{type = "label", caption = text}
            label.style.minimal_width = width
        end
        col(row.name, 130)
        col(tostring(row.stats.w or 0), 60)
        col(tostring(row.stats.l or 0), 60)
        col(tostring(row.stats.d or 0), 60)
    end
end

local function show_lobby(p)
    close_windows(p)
    local s = store()

    local frame = p.gui.screen.add{type = "frame", name = G.lobby, direction = "vertical"}
    frame.auto_center = true
    frame.style.minimal_width = 520
    add_titlebar(frame, "井字棋 · 大厅", G.close)

    local current = get_game_by_player(p.index)
    if current then
        local row = frame.add{type = "flow", direction = "horizontal"}
        row.style.vertical_align = "center"
        row.add{type = "label", caption = "你已经在一张桌上。"}
        row.add{type = "button", name = G.view_pfx .. tostring(current.tid), caption = "回到棋桌"}
        frame.add{type = "line"}
    end

    local any = false
    local tids = {}
    for tid in pairs(s.tables) do tids[#tids + 1] = tid end
    table.sort(tids)

    if #tids == 0 then
        local label = frame.add{type = "label", caption = "暂无棋桌，点击下方「开新桌」开始游戏。"}
        label.style.font_color = {r = 0.55, g = 0.55, b = 0.55}
    else
        local sc = frame.add{type = "scroll-pane", direction = "vertical"}
        sc.style.maximal_height = 280
        for _, tid in ipairs(tids) do
            local g = s.tables[tid]
            any = true
            local tf = sc.add{type = "frame", direction = "horizontal"}
            tf.style.minimal_width = 500
            tf.style.padding = 6

            local phase
            if g.phase == "waiting" then
                phase = "[color=0.4,1,0.4]等待中[/color]"
            elseif g.phase == "over" then
                phase = "[color=0.5,0.5,0.5]结束[/color]"
            else
                phase = "[color=1,0.85,0.2]对局中[/color]"
            end
            local title = tf.add{type = "label", caption = "桌 " .. tid .. "  " .. phase}
            title.style.minimal_width = 120

            local seats = tf.add{type = "flow", direction = "horizontal"}
            seats.style.horizontal_spacing = 8
            seats.style.minimal_width = 280
            for seat = 1, 2 do
                local pid = g.players[seat]
                local mark = ""
                if g.phase == "waiting" and pid then
                    mark = g.ready[pid] and "[color=0.4,1,0.4]✓[/color]" or "[color=1,0.6,0.2]○[/color]"
                end
                local text = mark_of_seat(seat) .. ":" .. player_name(pid) .. mark
                seats.add{type = "label", caption = text}
            end

            local can_join = not current and g.phase == "waiting" and first_empty_seat(g)
            tf.add{type = "button", name = (can_join and G.join_pfx or G.view_pfx) .. tostring(tid), caption = can_join and "加入" or "查看"}
        end
    end

    frame.add{type = "line"}
    local buttons = frame.add{type = "flow", direction = "horizontal"}
    buttons.add{type = "button", name = G.open, caption = "开新桌"}
    buttons.add{type = "button", name = G.stats, caption = "查看战绩"}
    buttons.add{type = "button", name = G.rules, caption = "游戏规则"}
    buttons.add{type = "button", name = G.notice, caption = "注意事项"}
end

local function add_player_line(parent, g, seat)
    local pid = g.players[seat]
    local mark = mark_of_seat(seat)
    local ready = pid and g.ready[pid]
    local text = mark .. "  " .. player_name(pid)
    if g.phase == "waiting" and pid then
        text = text .. (ready and "  已准备" or "  未准备")
    elseif g.phase == "playing" and pid == g.turn then
        text = text .. "  当前回合"
    end
    parent.add{type = "label", caption = text}
end

local function show_table(p, g)
    close_windows(p)

    local frame = p.gui.screen.add{type = "frame", name = G.table, direction = "vertical"}
    frame.auto_center = true
    local my_seat = seat_of_pid(g, p.index)

    if g.phase == "waiting" then
        frame.style.minimal_width = 400
        add_titlebar(frame, "井字棋 · 桌 " .. g.tid .. " · 等待就绪", G.close)
        local humans = count_humans(g)
        local seated = (g.players[1] and 1 or 0) + (g.players[2] and 1 or 0)
        frame.add{type = "label", caption = "玩家就绪 (" .. seated .. "/2)"}
        for seat = 1, 2 do
            local pid = g.players[seat]
            if pid then
                local row = frame.add{type = "flow", direction = "horizontal"}
                local ready = g.ready[pid]
                    and "[color=0.4,1,0.4]已准备[/color]"
                    or "[color=1,0.6,0.2]未准备[/color]"
                row.add{type = "label", caption = "  " .. seat .. "号：　" .. player_name(pid) .. "  " .. ready}
                if my_seat and pid < 0 then
                    row.add{type = "button", name = G.kick_ai, caption = "踢出"}
                end
            else
                frame.add{type = "label", caption = "  " .. seat .. "号：　（空）"}
            end
        end
        if g.msg and g.msg ~= "" then
            local msg = frame.add{type = "label", caption = g.msg}
            msg.style.font_color = {r = 0.55, g = 0.55, b = 0.55}
        end
        frame.add{type = "line"}
        local buttons = frame.add{type = "flow", direction = "horizontal"}
        if my_seat then
            local ready = g.ready[p.index]
            if ready then
                buttons.add{type = "label", caption = "[color=0.4,1,0.4]已准备，等待其他玩家…[/color]"}
            else
                buttons.add{type = "button", name = G.ready, caption = "准备"}
            end
        end
        if my_seat and first_empty_seat(g) then
            buttons.add{type = "button", name = G.add_ai, caption = "加入AI"}
        end
        if my_seat then
            buttons.add{type = "button", name = G.leave, caption = "离桌"}
        end
        buttons.add{type = "button", name = G.rules, caption = "游戏规则"}
        buttons.add{type = "button", name = G.notice, caption = "注意事项"}
        return
    end

    if g.phase == "over" then
        frame.style.minimal_width = 300
        add_titlebar(frame, "游戏结束 · 桌 " .. g.tid, G.close)
        local label = frame.add{type = "label", caption = g.msg or "游戏结束。"}
        label.style.font = "default-bold"
        local buttons = frame.add{type = "flow", direction = "horizontal"}
        if my_seat then
            buttons.add{type = "button", name = G.again, caption = "再来一局"}
            buttons.add{type = "button", name = G.leave, caption = "离桌"}
        end
        buttons.add{type = "button", name = G.back, caption = "大厅"}
        return
    end

    frame.style.minimal_width = 480
    add_titlebar(frame, "井字棋 · 桌 " .. g.tid, G.close)

    local hdr = frame.add{type = "flow", direction = "horizontal"}
    hdr.style.horizontal_spacing = 8
    for seat = 1, 2 do
        local pid = g.players[seat]
        local card = hdr.add{type = "frame", direction = "vertical"}
        if pid == g.turn then card.style = "positive_message_frame" end
        card.style.minimal_width = 220
        card.style.padding = 6
        local arrow = pid == g.turn and "[color=1,0.9,0.1]▶ [/color]" or "   "
        local title = card.add{type = "label", caption = arrow .. player_name(pid) .. " [" .. mark_of_seat(seat) .. "]"}
        if pid == g.turn then title.style.font = "default-bold" end
        card.add{type = "label", caption = pid == g.turn and "[color=0.4,1,0.4]当前回合[/color]" or "[color=0.5,0.5,0.5]等待…[/color]"}
        if pid == g.turn and pid > 0 then
            card.add{type = "label", caption = "[color=1,0.85,0.2]剩余 " .. tostring(turn_seconds_left(g) or 20) .. " 秒[/color]"}
        end
    end

    if g.msg and g.msg ~= "" then
        frame.add{type = "label", caption = g.msg}
    end
    frame.add{type = "line"}

    local board = frame.add{type = "table", column_count = 3}
    board.style.horizontal_spacing = 4
    board.style.vertical_spacing = 4

    local can_move = g.phase == "playing" and g.turn == p.index
    for i = 1, 9 do
        local cap = display_mark(g.board[i])
        local btn = board.add{type = "button", name = G.cell_pfx .. g.tid .. "_" .. i, caption = cap}
        btn.style.width = 64
        btn.style.height = 64
        btn.style.font = "heading-1"
        btn.enabled = (can_move and g.board[i] == "") or g.board[i] ~= ""
    end

    frame.add{type = "line"}
    local buttons = frame.add{type = "flow", direction = "horizontal"}
    buttons.add{type = "button", name = G.rules, caption = "游戏规则"}
    if my_seat then
        buttons.add{type = "button", name = G.leave, caption = "退出（结束本局）"}
    end
end

refresh_all = function(p)
    if not p or not p.valid then return end
    local g = get_game_by_player(p.index)
    if g then
        show_table(p, g)
    elseif p.gui.screen[G.lobby] then
        show_lobby(p)
    end
end

local function alloc_tid()
    local s = store()
    local tid = 1
    while s.tables[tid] do tid = tid + 1 end
    s.next_tid = math.max(s.next_tid, tid + 1)
    return tid
end

local function create_table(pid)
    local s = store()
    local tid = alloc_tid()
    local g = {
        tid = tid,
        phase = "waiting",
        players = {[1] = pid},
        ready = {},
        board = {"", "", "", "", "", "", "", "", ""},
        msg = "等待第二名玩家加入，或点击补 AI。",
    }
    s.tables[tid] = g
    s.seat[pid] = tid
    return g
end

local function join_table(pid, tid)
    local s = store()
    if s.seat[pid] then return s.tables[s.seat[pid]] end
    local g = s.tables[tid]
    if not g or g.phase ~= "waiting" then return end
    local seat = first_empty_seat(g)
    if not seat then return end
    g.players[seat] = pid
    g.msg = "两名玩家入座后，双方准备即可开始。"
    s.seat[pid] = tid
    return g
end

local function add_ai(g)
    local seat = first_empty_seat(g)
    if not seat then return end
    local ai_pid = -g.tid
    g.players[seat] = ai_pid
    g.ready[ai_pid] = true
    g.msg = "AI 已入座，真人玩家准备后开始。"
end

local function kick_ai(g)
    if g.phase ~= "waiting" then return end
    local s = store()
    s.ai_due[g.tid] = nil
    s.turn_due[g.tid] = nil
    local seat = ai_seat(g)
    if not seat then return end
    local ai_pid = g.players[seat]
    g.players[seat] = nil
    g.ready[ai_pid] = nil
    g.msg = "AI 已离桌。"
end

local function destroy_table_if_empty(g)
    if count_humans(g) > 0 then return end
    store().tables[g.tid] = nil
end

local function leave_table(pid)
    local s = store()
    local g, tid = get_game_by_player(pid)
    if not g then return end

    local seat = seat_of_pid(g, pid)
    if not seat then return end
    local other = g.players[seat == 1 and 2 or 1]

    if g.phase == "playing" and other then
        update_stats(other, pid, false)
        g.msg = player_name(pid) .. " 离桌，" .. player_name(other) .. " 获胜。"
    elseif g.phase == "over" then
        g.msg = player_name(pid) .. " 离桌。"
    else
        g.msg = "有玩家离桌。"
    end

    g.players[seat] = nil
    g.ready[pid] = nil
    s.seat[pid] = nil

    if other and other < 0 then
        g.players[seat == 1 and 2 or 1] = nil
    end

    if count_humans(g) == 0 then
        s.tables[tid] = nil
        s.ai_due[tid] = nil
        s.turn_due[tid] = nil
        return nil
    end

    s.ai_due[tid] = nil
    s.turn_due[tid] = nil
    g.phase = "waiting"
    g.ready = {}
    g.board = {"", "", "", "", "", "", "", "", ""}
    g.turn = nil
    g.winner = nil
    for i = 1, 2 do
        if g.players[i] and g.players[i] < 0 then
            g.ready[g.players[i]] = true
        end
    end

    return s.tables[tid]
end

local function on_click(event)
    local p = player(event.player_index)
    if not p or not event.element or not event.element.valid then return end
    local name = event.element.name

    if name == G.top then
        if p.gui.screen[G.lobby] or p.gui.screen[G.table] then
            close_windows(p)
        else
            local g = get_game_by_player(p.index)
            if g then show_table(p, g) else show_lobby(p) end
        end
        return
    end

    if name == G.close then
        close_windows(p)
        return
    end

    if name == G.rules then
        show_rules(p)
        return
    end

    if name == G.rules_close then
        destroy_if_valid(p.gui.screen.ttt_rules)
        return
    end

    if name == G.notice then
        show_notice(p)
        return
    end

    if name == G.notice_close then
        destroy_if_valid(p.gui.screen.ttt_notice)
        return
    end

    if name == G.stats then
        show_stats(p)
        return
    end

    if name == G.stats_close then
        destroy_if_valid(p.gui.screen.ttt_stats)
        return
    end

    if name == G.back then
        show_lobby(p)
        return
    end

    if name == G.open then
        local g = get_game_by_player(p.index) or create_table(p.index)
        show_table(p, g)
        return
    end

    local join_tid = name:match("^" .. G.join_pfx .. "(%d+)$")
    if join_tid then
        local g = join_table(p.index, tonumber(join_tid))
        if g then
            show_table(p, g)
            refresh_players(g)
        else
            p.print("这张桌已经不能加入了。")
            show_lobby(p)
        end
        return
    end

    local view_tid = name:match("^" .. G.view_pfx .. "(%d+)$")
    if view_tid then
        local g = store().tables[tonumber(view_tid)]
        if g then show_table(p, g) else show_lobby(p) end
        return
    end

    local g = get_game_by_player(p.index)
    if not g then return end

    if name == G.ready then
        g.ready[p.index] = true
        g.msg = player_name(p.index) .. " 已准备。"
        try_start(g)
        schedule_turn_timer(g)
        schedule_ai_turn(g)
        refresh_players(g)
        return
    end

    if name == G.unready then
        g.ready[p.index] = nil
        g.msg = player_name(p.index) .. " 取消准备。"
        refresh_players(g)
        return
    end

    if name == G.add_ai then
        add_ai(g)
        try_start(g)
        schedule_turn_timer(g)
        schedule_ai_turn(g)
        refresh_players(g)
        return
    end

    if name == G.kick_ai then
        kick_ai(g)
        refresh_players(g)
        return
    end

    if name == G.again then
        reset_game(g)
        try_start(g)
        schedule_turn_timer(g)
        schedule_ai_turn(g)
        refresh_players(g)
        return
    end

    if name == G.leave then
        local changed = leave_table(p.index)
        close_windows(p)
        show_lobby(p)
        if changed then refresh_players(changed) end
        return
    end

    local tid, pos = name:match("^" .. G.cell_pfx .. "(%d+)_(%d+)$")
    if tid and pos and tonumber(tid) == g.tid and g.phase == "playing" and g.turn == p.index then
        pos = tonumber(pos)
        if g.board[pos] == "" then
            local seat = seat_of_pid(g, p.index)
            g.board[pos] = mark_of_seat(seat)
            if not check_finish(g) then
                local next_seat = seat == 1 and 2 or 1
                g.turn = g.players[next_seat]
                g.msg = "轮到 " .. player_name(g.turn) .. "。"
                schedule_turn_timer(g)
                schedule_ai_turn(g)
            end
            refresh_players(g)
        end
    end
end

local function on_player_removed(event)
    local pidx = event.player_index
    local g = leave_table(pidx)
    if g then refresh_players(g) end
end

local function on_tick(event)
    if event.tick % 15 ~= 0 then return end
    local s = store()
    for tid, due_tick in pairs(s.ai_due) do
        if due_tick <= event.tick then
            s.ai_due[tid] = nil
            local g = s.tables[tid]
            if g and g.phase == "playing" and g.turn and g.turn < 0 then
                do_ai_turn(g)
                schedule_turn_timer(g)
                schedule_ai_turn(g)
                refresh_players(g)
            end
        end
    end
    for tid, due_tick in pairs(s.turn_due) do
        local g = s.tables[tid]
        if not g or g.phase ~= "playing" or not g.turn or g.turn < 0 then
            s.turn_due[tid] = nil
        elseif due_tick <= event.tick then
            finish_timeout(g)
            refresh_players(g)
        elseif event.tick % 60 == 0 then
            refresh_players(g)
        end
    end
end

handler.add_lib({
    events = {
        [defines.events.on_player_created] = function(event)
            add_top_button(player(event.player_index))
        end,
        [defines.events.on_player_joined_game] = function(event)
            add_top_button(player(event.player_index))
        end,
        [defines.events.on_player_left_game] = function(event)
            local g = get_game_by_player(event.player_index)
            if g and g.phase == "playing" then
                leave_table(event.player_index)
                refresh_players(g)
            end
        end,
        [defines.events.on_pre_player_removed] = on_player_removed,
        [defines.events.on_gui_click] = on_click,
        [defines.events.on_tick] = on_tick,
    },
    on_init = function()
        store()
        for _, p in pairs(game.players) do add_top_button(p) end
    end,
    on_configuration_changed = function()
        store()
        for _, p in pairs(game.players) do add_top_button(p) end
    end,
})
