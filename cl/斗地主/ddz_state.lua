-- Storage, table state, and refresh helpers.

-- ── State management ─────────────────────────────────────────────────────────

function is_ai(idx) return idx<0 end

function pname(idx)
    if is_ai(idx) then
        local d=storage.ddz
        return (d and d.ai_names and d.ai_names[idx]) or ("AI"..(-idx))
    end
    local p=game.players[idx]; return p and p.name or ("P"..idx)
end

function pname_loc(idx)
    if is_ai(idx) then
        local d=storage.ddz
        local name=(d and d.ai_names and d.ai_names[idx]) or ("AI"..(-idx))
        return ai_name_loc(name)
    end
    return pname(idx)
end

function init_storage()
    storage.ddz={
        tables={},       -- [tid] = 桌状态
        seat={},         -- [pid] = tid，nil 表示在大厅
        next_tid=1,
        next_ai_id=-1,   -- 每次分配递减
        ai_names={},     -- [ai_id] = "AI甲/乙/丙"
        ai_tid={},       -- [ai_id] = tid
        join_tick={},    -- [pid] = 入座时的 tick（用于30秒踢出计时）
        stats={},        -- [player_name] = {lw,ll,fw,fl}（地主胜/负，农民胜/负）
        feedback={},     -- [{player,text,tick}]
        fb_editing={},   -- [player_index] = feedback_index（正在编辑的条目）
        trustees={},     -- [player_index] = true 表示托管中
        sound_enabled={}, -- [player_index] = false 表示该玩家关闭音效
        win_pos={},      -- [player_index] = {x,y} 保存主面板拖动位置
        replay_pos={},   -- [player_index] = {x,y} 保存回放面板位置
        spectating={},   -- [player_index] = tid，nil 表示未观战
        panel_hidden={}, -- [player_index] = true 表示主面板已隐藏，直到点顶部按钮重新打开
        replay_archive={},
        replay_archive_order={},
        replay_view={},  -- [player_index] = replay_archive_id，正在查看的回放临时保护
        next_replay_id=1,
    }
end

function ensure_init()
    if not storage.ddz or not storage.ddz.tables then init_storage(); return end
    local d=storage.ddz
    if not d.seat      then d.seat={} end
    if not d.next_tid  then d.next_tid=1 end
    if not d.next_ai_id then d.next_ai_id=-1 end
    if not d.ai_names  then d.ai_names={} end
    if not d.ai_tid    then d.ai_tid={} end
    if not d.join_tick then d.join_tick={} end
    if not d.stats     then d.stats={} end
    if not d.feedback   then d.feedback={} end
    if not d.fb_editing then d.fb_editing={} end
    if not d.trustees   then d.trustees={} end
    if not d.sound_enabled then d.sound_enabled={} end
    if not d.win_pos    then d.win_pos={} end
    if not d.replay_pos then d.replay_pos={} end
    if not d.spectating then d.spectating={} end
    if not d.panel_hidden then d.panel_hidden={} end
    if not d.replay_archive then d.replay_archive={} end
    if not d.replay_archive_order then d.replay_archive_order={} end
    if not d.replay_view then d.replay_view={} end
    if not d.next_replay_id then d.next_replay_id=1 end
    for _,g in pairs(d.tables or {}) do
        if g.redeal_pending == nil then g.redeal_pending=false end
        if g.redeal_pending_tick == nil then g.redeal_pending_tick=0 end
    end
end

function alloc_tid()
    local d=storage.ddz
    local tid=1
    while d.tables[tid] do tid=tid+1 end
    return tid
end

function new_table_entry()
    local d=storage.ddz
    local tid=alloc_tid()
    local g={
        tid=tid, phase="waiting",
        order={}, ready={}, next_ready={},
        hands={}, bottom={}, played_bottom={},
        landlord=nil,
        bid_turn=1, bid_val=0, bid_who=nil, bids_done=0, bid_status={},
        play_turn=1, last=nil, passes=0, turn_tick=0,
        sel={}, msg={}, over_msg="",
        ai_pending=false, ai_ready_tick=0,
        bid_pending=false, bid_pending_who=nil, bid_pending_tick=0,
        redeal_pending=false, redeal_pending_tick=0,
        last_play_by={}, pass_by={}, played_cards={}, played_suits={},
        final_play=nil,
    }
    d.tables[tid]=g
    return tid, g
end

function alloc_ai(tid)
    local d=storage.ddz; local g=d.tables[tid]
    local used={}
    for _,pid in ipairs(g.order) do
        if is_ai(pid) and d.ai_names[pid] then used[d.ai_names[pid]]=true end
    end
    local slot_name=nil
    for _,n in ipairs(AI_SLOT_NAMES) do if not used[n] then slot_name=n; break end end
    if not slot_name then return nil end
    local ai_id=d.next_ai_id; d.next_ai_id=d.next_ai_id-1
    d.ai_names[ai_id]=slot_name; d.ai_tid[ai_id]=tid
    return ai_id
end

function player_in_table(g,pid)
    for _,q in ipairs(g.order) do if q==pid then return true end end
    return false
end

function clear_table_trustees(g)
    local d=storage.ddz
    if not (d and d.trustees and g) then return end
    for _,q in ipairs(g.order or {}) do
        if not is_ai(q) then d.trustees[q]=nil end
    end
end

function reset_table_to_waiting(g)
    if not g then return end
    clear_table_trustees(g)
    g.phase="waiting"; g.over_msg=""
    g.ready={}; g.next_ready={}; g.hands={}; g.bottom={}; g.played_bottom={}
    g.landlord=nil
    g.bid_turn=1; g.bid_val=0; g.bid_who=nil; g.bids_done=0; g.bid_status={}
    g.play_turn=1; g.last=nil; g.passes=0; g.turn_tick=0
    g.sel={}; g.msg={}
    g.ai_pending=false; g.ai_ready_tick=0
    g.bid_pending=false; g.bid_pending_who=nil; g.bid_pending_tick=0
    g.redeal_pending=false; g.redeal_pending_tick=0
    g.last_play_by={}; g.pass_by={}; g.played_cards={}; g.played_suits={}
    g.final_play=nil
end

function all_next_ready(g)
    if not g or g.phase~="over" or #g.order==0 then return false end
    local real_count=0
    for _,q in ipairs(g.order) do
        if is_ai(q) then
            -- AI 自动同意下一局
        else
            real_count=real_count+1
            if not (g.next_ready and g.next_ready[q]) then return false end
        end
    end
    return real_count>0
end

function start_next_round_if_ready(g)
    if not all_next_ready(g) then return false end
    local d=storage.ddz
    reset_table_to_waiting(g)
    for _,q in ipairs(g.order) do
        if is_ai(q) then g.ready[q]=true
        else d.join_tick[q]=game.tick end
    end
    return true
end

-- 若桌上无真实玩家则清理AI并销毁桌子，返回是否已销毁
function try_destroy_table(tid)
    local d=storage.ddz; local g=d.tables[tid]; if not g then return true end
    for _,q in ipairs(g.order) do if not is_ai(q) then return false end end
    for _,q in ipairs(g.order) do
        if is_ai(q) then d.ai_names[q]=nil; d.ai_tid[q]=nil end
    end
    d.tables[tid]=nil
    return true
end

-- ── GUI forward declarations ──────────────────────────────────────────────────

rebuild_one = nil  -- 下方定义

function refresh_table(g)
    for _,pid in ipairs(g.order) do
        if not is_ai(pid) then
            local p=game.players[pid]; if p and p.connected then rebuild_one(p) end
        end
    end
    local d=storage.ddz
    if d and d.spectating then
        for pid,tid in pairs(d.spectating) do
            if tid==g.tid then
                local p=game.players[pid]
                if p and p.connected then rebuild_one(p) end
            end
        end
    end
    if g.phase=="bidding" or g.phase=="playing" then
        if not g.bid_pending and not g.redeal_pending then
            local seat=g.phase=="bidding" and g.bid_turn or g.play_turn
            local actor=g.order[seat]
            if actor and (is_ai(actor) or (storage.ddz.trustees and storage.ddz.trustees[actor])) then
                g.ai_pending=true
                g.ai_ready_tick=game.tick+math.random(180,300)
            end
        end
    end
end

function refresh_lobby()
    local d=storage.ddz
    for _,p in pairs(game.players) do
        if p.connected and not d.seat[p.index] then rebuild_one(p) end
    end
end
