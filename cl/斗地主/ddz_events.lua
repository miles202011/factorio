-- Factorio event registrations and event handlers.

-- ── Events ───────────────────────────────────────────────────────────────────

script.on_init(function() init_storage() end)
script.on_configuration_changed(function() ensure_init() end)

local function find_gui_child(root,name)
    if not (root and root.valid) then return nil end
    local direct=root[name]
    if direct and direct.valid then return direct end
    for _,child in pairs(root.children or {}) do
        if child.valid then
            if child.name==name then return child end
            local found=find_gui_child(child,name)
            if found then return found end
        end
    end
    return nil
end

-- AI 行动轮询
script.on_nth_tick(30,function()
    local d=storage.ddz; if not d then return end
    for _,g in pairs(d.tables) do
        if g.ai_pending and game.tick>=(g.ai_ready_tick or 0) then do_ai_turn_for(g) end
    end
end)

-- 30秒未准备踢出计时；出牌/叫分超时自动托管
script.on_nth_tick(60,function()
    local d=storage.ddz; if not d then return end
    -- 叫地主3秒倒计时到期后进入出牌阶段
    for _,g in pairs(d.tables) do
        if g.phase=="bidding" and g.bid_pending and game.tick >= g.bid_pending_tick then
            assign_landlord(g, g.bid_pending_who)
        elseif g.phase=="bidding" and g.redeal_pending and game.tick >= g.redeal_pending_tick then
            finish_redeal_pending(g)
        end
    end
    -- 叫分/出牌超时 + 每秒刷新倒计时
    for _,g in pairs(d.tables) do
        if (g.phase=="bidding" or g.phase=="playing") and g.turn_tick then
            if g.phase=="bidding" and g.redeal_pending then
                local rem=math.max(0, g.redeal_pending_tick - game.tick)
                local secs=math.ceil(rem/60)
                local cap=DDZ_L("redeal-start",secs)
                for _,qid in ipairs(g.order) do
                    if not is_ai(qid) then
                        local qp=game.players[qid]
                        if qp and qp.connected then
                            local df=qp.gui.screen.ddz
                            if df and df.valid then
                                local lbl=find_gui_child(df,"ddz_countdown")
                                if lbl and lbl.valid then lbl.caption=cap end
                            end
                        end
                    end
                end
            elseif g.phase=="bidding" and g.bid_pending then
                -- 显示"X成为地主，N秒后开始"倒计时
                local rem=math.max(0, g.bid_pending_tick - game.tick)
                local secs=math.ceil(rem/60)
                local lname=pname_loc(g.bid_pending_who)
                local cap=DDZ_L("landlord-start",lname,secs)
                for _,qid in ipairs(g.order) do
                    if not is_ai(qid) then
                        local qp=game.players[qid]
                        if qp and qp.connected then
                            local df=qp.gui.screen.ddz
                            if df and df.valid then
                                local lbl=find_gui_child(df,"ddz_countdown")
                                if lbl and lbl.valid then lbl.caption=cap end
                            end
                        end
                    end
                end
            elseif game.tick-g.turn_tick > TURN_TIMEOUT then
                do_auto_timeout(g)
            else
                local rem=math.max(0,TURN_TIMEOUT-(game.tick-g.turn_tick))
                local secs=math.ceil(rem/60)
                local key=secs<=5 and "timeout-trust-danger" or "timeout-trust-normal"
                local cap=DDZ_L(key,secs)
                for _,qid in ipairs(g.order) do
                    if not is_ai(qid) then
                        local qp=game.players[qid]
                        if qp and qp.connected then
                            local df=qp.gui.screen.ddz
                            if df and df.valid then
                                local lbl=find_gui_child(df,"ddz_countdown")
                                if lbl and lbl.valid then lbl.caption=cap end
                            end
                        end
                    end
                end
            end
        end
    end
    local lobby_changed=false
    for tid,g in pairs(d.tables) do
        if g.phase=="waiting" then
            local kicked=false
            for i=#g.order,1,-1 do
                local pid=g.order[i]
                if not is_ai(pid) and not g.ready[pid] then
                    local jt=d.join_tick[pid]
                    if jt and (game.tick-jt)>READY_TIMEOUT then
                        table.remove(g.order,i)
                        d.seat[pid]=nil; d.join_tick[pid]=nil
                        local p=game.players[pid]
                        if p and p.connected then
                            rebuild_one(p)
                            p.print(DDZ_L("timeout-left"))
                        end
                        kicked=true; lobby_changed=true
                    end
                end
            end
            -- 踢人后若桌上无真实玩家则销毁桌子
            if kicked then
                if not try_destroy_table(tid) then refresh_table(g) end
            end
        end
    end
    -- 清理等待中的无人桌（含只剩AI的情况）
    local no_real={}
    for tid,g in pairs(d.tables) do
        if g.phase=="waiting" then
            local has_real=false
            for _,q in ipairs(g.order) do if not is_ai(q) then has_real=true; break end end
            if not has_real then no_real[#no_real+1]=tid end
        end
    end
    for _,tid in ipairs(no_real) do
        local g=d.tables[tid]
        if g then
            for _,q in ipairs(g.order) do
                if is_ai(q) then d.ai_names[q]=nil; d.ai_tid[q]=nil end
            end
            d.tables[tid]=nil
        end
        lobby_changed=true
    end
    if lobby_changed then refresh_lobby() end
end)

function setup_player(p)
    if not p.gui.top.ddz_top_btn then
        p.gui.top.add{type="button",name="ddz_top_btn",
            caption=DDZ_L("game-name"),tooltip=DDZ_L("open-panel")}
    else
        p.gui.top.ddz_top_btn.caption=DDZ_L("game-name")
        p.gui.top.ddz_top_btn.tooltip=DDZ_L("open-panel")
    end
end

local FEEDBACK_EXPORT_TEXT = {
    zh = {
        title = "斗地主反馈导出",
        exporter = "导出玩家：",
        count = "反馈数量：",
        unknown = "未知玩家",
    },
    en = {
        title = "Dou Dizhu Feedback Export",
        exporter = "Exported by: ",
        count = "Feedback count: ",
        unknown = "Unknown player",
    },
}

local function feedback_export_text_for(player)
    local locale = "zh-CN"
    if player then
        local ok, value = pcall(function() return player.locale end)
        if ok and type(value) == "string" then locale = value end
    end
    if locale:sub(1, 2) == "en" then return FEEDBACK_EXPORT_TEXT.en end
    return FEEDBACK_EXPORT_TEXT.zh
end

local function replay_archive_for_player(d,pid)
    local view_id=d.replay_view and d.replay_view[pid]
    return view_id and d.replay_archive and d.replay_archive[view_id] or nil
end

local function set_replay_pos_for_player(pid,pos,play_sound,partial_refresh,skip_slider)
    local d=storage.ddz
    local p=game.players[pid]
    local archive=d and replay_archive_for_player(d,pid)
    if not (archive and archive.replay) then
        if p then
            clear_replay_gui(p)
            p.print(DDZ_L("replay-gone"))
        end
        return
    end
    if not archive.replay.pos then archive.replay.pos={} end
    local max=#(archive.replay.steps or {})
    pos=tonumber(pos) or archive.replay.pos[pid] or 0
    pos=math.floor(pos)
    if pos<0 then pos=0 end
    if pos>max then pos=max end
    archive.replay.pos[pid]=pos
    if p then
        if play_sound then ddz_play_sound(p,"list_box_click",0.65) end
        if not (partial_refresh and refresh_replay_gui_content(p,archive,skip_slider)) then
            gui_replay(p,archive)
        end
    end
end

script.on_event(defines.events.on_player_joined_game,function(ev)
    ensure_init()
    local p=game.players[ev.player_index]; if not p then return end
    setup_player(p); rebuild_one(p)
end)

script.on_event(defines.events.on_player_left_game,function(ev)
    ensure_init()
    local d=storage.ddz; local pid=ev.player_index
    if d.replay_view then d.replay_view[pid]=nil; replay_cleanup_archive() end
    if d.trustees then d.trustees[pid]=nil end
    if d.spectating then d.spectating[pid]=nil end
    local tid=d.seat[pid]; if not tid then return end
    local g=d.tables[tid]; if not g then d.seat[pid]=nil; return end

    if g.phase=="bidding" or g.phase=="playing" then
        record_escape(pid,g)
        clear_table_trustees(g)
        g.phase="over"
        g.over_msg=ddz_message("over-disconnected",pname_loc(pid))
        replay_record_over(g,g.over_msg)
        for i,q in ipairs(g.order) do if q==pid then table.remove(g.order,i); break end end
        d.seat[pid]=nil; d.join_tick[pid]=nil
        if try_destroy_table(tid) then refresh_lobby()
        else refresh_table(g); refresh_lobby() end
    elseif g.phase=="waiting" then
        for i,q in ipairs(g.order) do if q==pid then table.remove(g.order,i); break end end
        d.seat[pid]=nil; d.join_tick[pid]=nil
        if try_destroy_table(tid) then refresh_lobby()
        else refresh_table(g); refresh_lobby() end
    elseif g.phase=="over" then
        for i,q in ipairs(g.order) do if q==pid then table.remove(g.order,i); break end end
        if g.next_ready then g.next_ready[pid]=nil end
        d.seat[pid]=nil; d.join_tick[pid]=nil
        if try_destroy_table(tid) then refresh_lobby() end
    end
end)

script.on_event(defines.events.on_gui_click,function(ev)
    ensure_init()
    local el=ev.element; if not (el and el.valid) then return end
    local name=el.name; local pid=ev.player_index; local d=storage.ddz
    if (not name or name=="") and el.parent and el.parent.valid then name=el.parent.name end

    -- 全局按钮（不需要桌子上下文）
    if name=="ddz_top_btn" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"gui_click",0.7)
        if p.gui.screen.ddz then
            if not d.panel_hidden then d.panel_hidden={} end
            d.panel_hidden[pid]=true
            clear_gui(p)
        else
            if d.panel_hidden then d.panel_hidden[pid]=nil end
            rebuild_one(p)
        end
        return
    end
    if name=="ddz_sound_toggle" then
        local p=game.players[pid]; if not p then return end
        local was_enabled=ddz_sound_enabled(p)
        if was_enabled then ddz_play_sound(p,"gui_switch",0.7) end
        ddz_toggle_sound(p)
        if not was_enabled then ddz_play_sound(p,"gui_switch",0.7) end
        rebuild_one(p)
        return
    end
    if name=="ddz_rules_open" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); gui_rules(p) end; return
    end
    if name=="ddz_rules_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_rules then p.gui.screen.ddz_rules.destroy() end; return
    end
    if name=="ddz_notice_open" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); gui_notice(p) end; return
    end
    if name=="ddz_notice_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_notice then p.gui.screen.ddz_notice.destroy() end; return
    end
    if name=="ddz_stats_open" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); gui_stats(p) end; return
    end
    if name=="ddz_stats_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_stats then p.gui.screen.ddz_stats.destroy() end; return
    end
    if name=="ddz_test_open" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); gui_test_tool(p) end; return
    end
    if name=="ddz_test_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_test then p.gui.screen.ddz_test.destroy() end; return
    end
    if name=="ddz_tracker_open" then
        local p=game.players[pid]; if not p then return end
        local tid=d.seat and d.seat[pid]
        local g=tid and d.tables and d.tables[tid]
        if not g then return end
        ddz_play_sound(p,"gui_click",0.7)
        gui_card_tracker(p,g)
        return
    end
    if name=="ddz_tracker_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_tracker then p.gui.screen.ddz_tracker.destroy() end
        return
    end
    if name=="ddz_all_sound_test_open" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); gui_all_sound_test(p) end; return
    end
    if name=="ddz_all_sound_test_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_all_sound_test then p.gui.screen.ddz_all_sound_test.destroy() end; return
    end
    if name:sub(1,15)=="ddz_test_sound_" then
        local p=game.players[pid]; if not p then return end
        ddz_play_test_sound(p,name:sub(16))
        return
    end
    if name=="ddz_test_overlap_apply" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"confirm",0.7)
        if not d.test_tool then d.test_tool={} end
        if not d.test_tool[pid] then d.test_tool[pid]={sel={},played={},deck=create_deck(),overlap=DDZ_CARD_OVERLAP,red_color="default"} sort_hand(d.test_tool[pid].deck) end
        local tb=el.parent and el.parent.valid and el.parent["ddz_test_overlap_input"]
        local ov=tb and tb.valid and tonumber(tb.text) or nil
        if not ov then ov=d.test_tool[pid].overlap or DDZ_CARD_OVERLAP end
        ov=math.floor(ov)
        if ov<0 then ov=0 elseif ov>DDZ_CARD_OVERLAP_MAX then ov=DDZ_CARD_OVERLAP_MAX end
        d.test_tool[pid].overlap=ov
        gui_test_tool(p); return
    end
    if name:sub(1,17)=="ddz_test_overlap_" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"gui_click",0.7)
        if not d.test_tool then d.test_tool={} end
        if not d.test_tool[pid] then d.test_tool[pid]={sel={},played={},deck=create_deck()} sort_hand(d.test_tool[pid].deck) end
        local ov=tonumber(name:sub(18)); if not ov then return end
        d.test_tool[pid].overlap=ov
        gui_test_tool(p); return
    end
    if name:sub(1,13)=="ddz_test_red_" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"gui_click",0.7)
        if not d.test_tool then d.test_tool={} end
        if not d.test_tool[pid] then d.test_tool[pid]={sel={},played={},deck=create_deck(),overlap=DDZ_CARD_OVERLAP} sort_hand(d.test_tool[pid].deck) end
        d.test_tool[pid].red_color=name:sub(14)
        gui_test_tool(p); return
    end
    if name:sub(1,14)=="ddz_test_card_" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"inventory_click",0.75)
        if not d.test_tool then d.test_tool={} end
        if not d.test_tool[pid] then d.test_tool[pid]={sel={},played={},deck=create_deck()} sort_hand(d.test_tool[pid].deck) end
        local idx=tonumber(name:sub(15)); if not idx then return end
        d.test_tool[pid].sel[idx]=not d.test_tool[pid].sel[idx]
        gui_test_tool(p); return
    end
    if name=="ddz_test_clear" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"clear_cursor",0.7)
        if not d.test_tool then d.test_tool={} end
        local old_overlap=d.test_tool[pid] and d.test_tool[pid].overlap or DDZ_CARD_OVERLAP
        local old_red=d.test_tool[pid] and d.test_tool[pid].red_color or "default"
        d.test_tool[pid]={sel={},played={},deck=create_deck(),overlap=old_overlap,red_color=old_red}
        sort_hand(d.test_tool[pid].deck)
        gui_test_tool(p); return
    end
    if name=="ddz_test_10" or name=="ddz_test_15" or name=="ddz_test_20" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"smart_pipette",0.75)
        if not d.test_tool then d.test_tool={} end
        if not d.test_tool[pid] then d.test_tool[pid]={sel={},played={},deck=create_deck()} sort_hand(d.test_tool[pid].deck) end
        local st=d.test_tool[pid]
        st.sel={}
        local limit=20
        if name=="ddz_test_10" then limit=10
        elseif name=="ddz_test_15" then limit=15
        elseif name=="ddz_test_20" then limit=20 end
        for i=1,math.min(limit,#st.deck) do st.sel[i]=true end
        gui_test_tool(p); return
    end
    if name=="ddz_about_open" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"gui_click",0.7)
        if p.gui.screen.ddz_about then
            local d=storage.ddz
            if d and d.fb_editing then d.fb_editing[pid]=nil end
            p.gui.screen.ddz_about.destroy()
        else
            gui_about(p)
        end
        return
    end
    if name=="ddz_about_close" then
        local p=game.players[pid]; if not p then return end
        local d=storage.ddz
        if d and d.fb_editing then d.fb_editing[pid]=nil end
        if p.gui.screen.ddz_about then p.gui.screen.ddz_about.destroy() end; return
    end
    if name=="ddz_about_qr_show" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); gui_qr(p) end; return
    end
    if name=="ddz_about_discord_qr_show" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); gui_discord_qr(p) end; return
    end
    if name=="ddz_about_qr_save" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"entity_settings_pasted",0.75); save_qr_svg(p) end; return
    end
    if name=="ddz_about_discord_qr_save" then
        local p=game.players[pid]; if p then ddz_play_sound(p,"entity_settings_pasted",0.75); save_discord_qr_svg(p) end; return
    end
    if name=="ddz_qr_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_qr then p.gui.screen.ddz_qr.destroy() end; return
    end
    if name=="ddz_discord_qr_close" then
        local p=game.players[pid]
        if p and p.gui.screen.ddz_discord_qr then p.gui.screen.ddz_discord_qr.destroy() end; return
    end
    if name=="ddz_about_save" then
        local p=game.players[pid]; if not p then return end
        local af=p.gui.screen.ddz_about; if not (af and af.valid) then return end
        local tb=af["ddz_about_feedback"]
        local text=tb and tb.valid and tb.text or ""
        text=text:match("^%s*(.-)%s*$")
        if text~="" then
            local d=storage.ddz
            if not d.feedback   then d.feedback={} end
            if not d.fb_editing then d.fb_editing={} end
            local edit_idx=d.fb_editing[pid]
            if edit_idx and d.feedback[edit_idx] and d.feedback[edit_idx].player==p.name then
                d.feedback[edit_idx].text=text
                d.feedback[edit_idx].tick=game.tick
                d.fb_editing[pid]=nil
                ddz_play_sound(p,"confirm",0.7)
                p.print(DDZ_L("feedback-updated"))
            else
                table.insert(d.feedback,{player=p.name,text=text,tick=game.tick})
                ddz_play_sound(p,"confirm",0.7)
                p.print(DDZ_L("feedback-saved"))
            end
        end
        gui_about(p); return
    end
    if name=="ddz_feedback_export" then
        local p=game.players[pid]; if not p then return end
        local d=storage.ddz
        if not d.feedback or #d.feedback==0 then
            p.print(DDZ_L("feedback-empty"))
            return
        end
        local text=feedback_export_text_for(p)
        ddz_play_sound(p,"entity_settings_pasted",0.75)
        local lines={
            text.title,
            text.exporter..p.name,
            text.count..#d.feedback,
            "",
        }
        for i,fb in ipairs(d.feedback) do
            lines[#lines+1]="["..i.."] "..(fb.player or text.unknown).."  "..(fb.tick and tick_to_str(fb.tick) or "--:--:--")
            lines[#lines+1]=fb.text or ""
            lines[#lines+1]=""
        end
        helpers.write_file("斗地主/ddz_feedback.txt",table.concat(lines,"\n"),false,p.index)
        p.print(DDZ_L("feedback-exported"))
        return
    end
    if name=="ddz_fb_cancel" then
        local p=game.players[pid]; if not p then return end
        local d=storage.ddz
        if d and d.fb_editing then d.fb_editing[pid]=nil end
        gui_about(p); return
    end
    if name:sub(1,12)=="ddz_fb_edit_" then
        local p=game.players[pid]; if not p then return end
        local idx=tonumber(name:sub(13)); if not idx then return end
        local d=storage.ddz
        if not d.feedback or not d.feedback[idx] then return end
        if d.feedback[idx].player~=p.name then return end
        if not d.fb_editing then d.fb_editing={} end
        d.fb_editing[pid]=idx
        gui_about(p); return
    end
    if name:sub(1,11)=="ddz_fb_del_" then
        local p=game.players[pid]; if not p then return end
        local idx=tonumber(name:sub(12)); if not idx then return end
        local d=storage.ddz
        if not d.feedback or not d.feedback[idx] then return end
        local fb=d.feedback[idx]
        if fb.player~=p.name and not p.admin then return end
        table.remove(d.feedback,idx)
        if d.fb_editing then
            for qpid,qidx in pairs(d.fb_editing) do
                if     qidx==idx then d.fb_editing[qpid]=nil
                elseif qidx>idx  then d.fb_editing[qpid]=qidx-1 end
            end
        end
        gui_about(p); return
    end
    if name=="ddz_close" then
        local p=game.players[pid]; if not p then return end
        ddz_play_sound(p,"clear_cursor",0.7)
        if not d.panel_hidden then d.panel_hidden={} end
        d.panel_hidden[pid]=true
        clear_gui(p); return
    end
    if name=="ddz_replay_close" then
        local p=game.players[pid]
        if p then ddz_play_sound(p,"clear_cursor",0.7) end
        if p then clear_replay_gui(p) end
        if d.replay_view then d.replay_view[pid]=nil end
        replay_cleanup_archive()
        return
    end

    -- 大厅：开新桌
    if name=="ddz_new_table" then
        if d.seat[pid] then return end
        local tid,g=new_table_entry()
        d.seat[pid]=tid; d.join_tick[pid]=game.tick
        g.order[1]=pid; g.ready[pid]=false
        local p=game.players[pid]; if p then ddz_play_sound(p,"confirm",0.75); rebuild_one(p) end
        refresh_lobby(); return
    end

    -- 大厅：加入已有桌
    if name:sub(1,9)=="ddz_join_" then
        local tid=tonumber(name:sub(10))
        if not tid or d.seat[pid] then return end
        local g=d.tables[tid]
        if not g or #g.order>=3 then return end
        if g.phase=="over" then
            if d.spectating then d.spectating[pid]=nil end
            d.seat[pid]=tid
            g.order[#g.order+1]=pid
            if not g.next_ready then g.next_ready={} end
            g.next_ready[pid]=true
            local p=game.players[pid]; if p then ddz_play_sound(p,"confirm",0.75); rebuild_one(p) end
            if start_next_round_if_ready(g) then refresh_table(g) else refresh_table(g) end
            refresh_lobby(); return
        elseif g.phase~="waiting" then
            return
        end
        if d.spectating then d.spectating[pid]=nil end
        d.seat[pid]=tid; d.join_tick[pid]=game.tick
        g.order[#g.order+1]=pid; g.ready[pid]=false
        local p=game.players[pid]; if p then ddz_play_sound(p,"confirm",0.75); rebuild_one(p) end
        refresh_table(g); refresh_lobby(); return
    end

    if name:sub(1,10)=="ddz_watch_" then
        local tid=tonumber(name:sub(11))
        if not tid or d.seat[pid] then return end
        local g=d.tables[tid]
        if not g or g.phase=="waiting" then return end
        d.spectating[pid]=tid
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_click",0.7); rebuild_one(p) end
        refresh_lobby(); return
    end

    if name=="ddz_watch_close" then
        if d.spectating then d.spectating[pid]=nil end
        local p=game.players[pid]; if p then ddz_play_sound(p,"clear_cursor",0.7); clear_gui(p); gui_lobby(p) end
        refresh_lobby(); return
    end

    -- 以下操作需要玩家在某个桌子
    local tid=d.seat[pid]; local g=tid and d.tables[tid]

    if name=="ddz_replay_open" then
        local p=game.players[pid]
        if p and g then
            ddz_play_sound(p,"gui_click",0.7)
            local archive=replay_archive_round(g)
            if archive then
                if not d.replay_view then d.replay_view={} end
                d.replay_view[pid]=archive.id
                if not archive.replay.pos then archive.replay.pos={} end
                archive.replay.pos[pid]=0
                gui_replay(p,archive)
            end
        end
        return
    end
    if name=="ddz_replay_export" then
        local p=game.players[pid]; if not p then return end
        local archive=nil
        local view_id=d.replay_view and d.replay_view[pid]
        if view_id then
            archive=d.replay_archive and d.replay_archive[view_id]
            if not archive then
                p.print(DDZ_L("replay-gone"))
                return
            end
        elseif g then
            archive=replay_archive_round(g)
        end
        if not archive then
            p.print(DDZ_L("replay-none"))
            return
        end
        local filename=replay_export_archive(p,archive)
        if filename then ddz_play_sound(p,"entity_settings_pasted",0.75); p.print(DDZ_L("replay-exported",filename))
        else p.print(DDZ_L("replay-none")) end
        return
    end
    if name=="ddz_replay_prev" or name=="ddz_replay_next" then
        local archive=replay_archive_for_player(d,pid)
        local pos=archive and archive.replay and archive.replay.pos and archive.replay.pos[pid] or 0
        set_replay_pos_for_player(pid, name=="ddz_replay_prev" and pos-1 or pos+1, true)
        return
    end
    if name=="ddz_replay_last" then
        local archive=replay_archive_for_player(d,pid)
        local max=archive and archive.replay and #(archive.replay.steps or {}) or 0
        set_replay_pos_for_player(pid,max,true)
        return
    end
    if name=="ddz_replay_jump" then
        local input=el.parent and el.parent.valid and el.parent["ddz_replay_jump_input"]
        set_replay_pos_for_player(pid,input and input.valid and tonumber(input.text) or 0,true)
        return
    end
    if name=="ddz_quit_confirm_return" then
        local p=game.players[pid]
        if p then ddz_play_sound(p,"clear_cursor",0.7) end
        if p and p.gui.screen.ddz_quit_confirm then p.gui.screen.ddz_quit_confirm.destroy() end
        return
    end
    if name=="ddz_quit_confirm_ok" then
        local p=game.players[pid]
        if p then ddz_play_sound(p,"alert_destroyed",0.65) end
        if p and p.gui.screen.ddz_quit_confirm then p.gui.screen.ddz_quit_confirm.destroy() end
        if g and (g.phase=="bidding" or g.phase=="playing") then
            record_escape(pid,g)
            clear_table_trustees(g)
            g.phase="over"
            g.over_msg=ddz_message("over-quit",pname_loc(pid))
            replay_record_over(g,g.over_msg)
            refresh_table(g); refresh_lobby()
        end
        return
    end

    -- 离桌
    if name=="ddz_leave_close" then
        if not tid or not g then
            local p=game.players[pid]; if p then clear_gui(p) end; return
        end
        if g.phase=="bidding" or g.phase=="playing" then
            clear_table_trustees(g)
            g.phase="over"
            g.over_msg=ddz_message("over-left",pname_loc(pid))
            replay_record_over(g,g.over_msg)
        end
        for i,q in ipairs(g.order) do if q==pid then table.remove(g.order,i); break end end
        if g.next_ready then g.next_ready[pid]=nil end
        d.seat[pid]=nil; d.join_tick[pid]=nil; if d.trustees then d.trustees[pid]=nil end
        local p=game.players[pid]; if p then ddz_play_sound(p,"undo",0.7); clear_gui(p) end
        local destroyed=try_destroy_table(tid)
        if not destroyed then refresh_table(g) end
        for _,qp in pairs(game.players) do
            if qp.connected and qp.index~=pid and not d.seat[qp.index] then rebuild_one(qp) end
        end
        return
    end

    if name=="ddz_leave_table" then
        if not tid or not g then
            local p=game.players[pid]; if p then rebuild_one(p) end; return
        end
        if g.phase=="bidding" or g.phase=="playing" then
            clear_table_trustees(g)
            g.phase="over"
            g.over_msg=ddz_message("over-left",pname_loc(pid))
            replay_record_over(g,g.over_msg)
        end
        for i,q in ipairs(g.order) do if q==pid then table.remove(g.order,i); break end end
        if g.next_ready then g.next_ready[pid]=nil end
        d.seat[pid]=nil; d.join_tick[pid]=nil; if d.trustees then d.trustees[pid]=nil end
        local p=game.players[pid]; if p then ddz_play_sound(p,"undo",0.7); rebuild_one(p) end
        if try_destroy_table(tid) then refresh_lobby()
        else refresh_table(g); refresh_lobby() end
        return
    end

    -- 退出（结束本局，留在桌上看结束画面）
    if name=="ddz_quit" then
        local p=game.players[pid]
        if p and g and (g.phase=="bidding" or g.phase=="playing") then ddz_play_sound(p,"gui_click",0.7); gui_quit_confirm(p,g) end
        return
    end

    -- 再来一局
    if name=="ddz_restart" then
        if not g then return end
        if g.phase~="over" then return end
        if not g.next_ready then g.next_ready={} end
        local p=game.players[pid]
        if p then ddz_play_sound(p,(g.next_ready[pid] and "undo" or "confirm"),0.7) end
        if g.next_ready[pid] then g.next_ready[pid]=nil else g.next_ready[pid]=true end
        if start_next_round_if_ready(g) then refresh_table(g)
        else refresh_table(g) end
        refresh_lobby(); return
    end

    if not g then return end

    if name=="ddz_trust_toggle" then
        if not player_in_table(g,pid) or is_ai(pid) then return end
        if not (g.phase=="bidding" or g.phase=="playing") then return end
        if not d.trustees then d.trustees={} end
        if d.trustees[pid] then d.trustees[pid]=nil else d.trustees[pid]=true end
        local p=game.players[pid]; if p then ddz_play_sound(p,"gui_switch",0.75) end
        g.sel[pid]={}; g.msg[pid]=nil
        if d.trustees[pid] then
            local seat=g.phase=="bidding" and g.bid_turn or g.play_turn
            if g.order[seat]==pid then
                g.ai_pending=true
                g.ai_ready_tick=game.tick+30
            end
        end
        refresh_table(g); return
    end

    -- 等待阶段
    if g.phase=="waiting" then
        if name=="ddz_add_ai_full" then
            local p=game.players[pid]; if p then ddz_play_sound(p,"cannot_build",0.7); p.print(DDZ_L("ai-full")) end
            return
        end
        if name=="ddz_ready" then
            if not player_in_table(g,pid) then return end
            local p=game.players[pid]
            if p then ddz_play_sound(p,(g.ready[pid] and "undo" or "confirm"),0.7) end
            g.ready[pid]=not g.ready[pid]
            if g.ready[pid] then d.join_tick[pid]=nil
            else d.join_tick[pid]=game.tick end
            -- 三人全准备则开始
            local all_ready=#g.order==3
            if all_ready then
                for _,q in ipairs(g.order) do if not g.ready[q] then all_ready=false; break end end
            end
            if all_ready then start_bidding(g)
            else refresh_table(g); refresh_lobby() end
            return
        end
        if name=="ddz_add_ai" then
            if #g.order>=3 then return end
            local ai_id=alloc_ai(tid); if not ai_id then return end
            local p=game.players[pid]; if p then ddz_play_sound(p,"confirm",0.7) end
            g.order[#g.order+1]=ai_id; g.hands[ai_id]={}; g.ready[ai_id]=true
            local all_ready=#g.order==3
            if all_ready then
                for _,q in ipairs(g.order) do if not g.ready[q] then all_ready=false; break end end
            end
            if all_ready then start_bidding(g)
            else refresh_table(g); refresh_lobby() end
            return
        end
        if name:sub(1,9)=="ddz_kick_" then
            local seat=tonumber(name:sub(10))
            if seat and g.order[seat] and is_ai(g.order[seat]) then
                local ai_id=g.order[seat]
                table.remove(g.order,seat)
                d.ai_names[ai_id]=nil; d.ai_tid[ai_id]=nil
                local p=game.players[pid]; if p then ddz_play_sound(p,"item_deleted",0.65) end
                refresh_table(g); refresh_lobby()
            end
            return
        end
    end

    -- 叫分阶段
    if g.phase=="bidding" then
        if     name=="ddz_bid_0" then do_bid(g,pid,0)
        elseif name=="ddz_bid_1" then do_bid(g,pid,1)
        elseif name=="ddz_bid_2" then do_bid(g,pid,2)
        elseif name=="ddz_bid_3" then do_bid(g,pid,3) end
        return
    end

    -- 出牌阶段
    if g.phase=="playing" then
        if name:sub(1,6)=="ddz_c_" then
            local i=tonumber(name:sub(7))
            if i then
                if not g.sel[pid] then g.sel[pid]={} end
                g.sel[pid][i]=not g.sel[pid][i]; g.msg[pid]=nil
                local p=game.players[pid]; if p then ddz_play_sound(p,"inventory_click",0.75); rebuild_one(p) end
            end
            return
        end
        if name=="ddz_hint" then
            if g.order[g.play_turn]~=pid then return end
            if storage.ddz.trustees and storage.ddz.trustees[pid] then return end
            local hand=g.hands[pid] or {}
            local last=(g.last and g.last.by~=pid) and g.last or nil
            local cards=ai_choose_cards_for(g,pid,hand,last)
            if not (cards and #cards>0) then return end
            g.sel[pid]={}
            local used={}
            for _,ac in ipairs(cards) do
                for i,hc in ipairs(hand) do
                    if not used[i] and card_same(hc,ac) then
                        g.sel[pid][i]=true
                        used[i]=true
                        break
                    end
                end
            end
            g.msg[pid]=nil
            local p=game.players[pid]; if p then ddz_play_sound(p,"smart_pipette",0.75) end
            local p=game.players[pid]; if p then rebuild_one(p) end
            return
        end
        if name=="ddz_play" then
            if g.order[g.play_turn]~=pid then return end
            if storage.ddz.trustees and storage.ddz.trustees[pid] then return end
            local sel=g.sel[pid] or {}; local idxs={}
            for i,v in pairs(sel) do if v then idxs[#idxs+1]=i end end
            if #idxs==0 then return end
            local hand=g.hands[pid] or {}; local cards={}
            for _,i in ipairs(idxs) do if hand[i] then cards[#cards+1]=hand[i] end end
            local pt=get_type(cards)
            if not pt then return end
            if g.last and g.last.by~=pid and not can_beat(g.last,pt) then return end
            do_play(g,pid); return
        end
        if name=="ddz_pass" then
            if g.order[g.play_turn]~=pid then return end
            if storage.ddz.trustees and storage.ddz.trustees[pid] then return end
            if not g.last or g.last.by==pid then return end
            do_pass(g,pid); return
        end
    end
end)

script.on_event(defines.events.on_gui_confirmed,function(ev)
    ensure_init()
    local el=ev.element
    if not (el and el.valid and el.name=="ddz_replay_jump_input") then return end
    set_replay_pos_for_player(ev.player_index,tonumber(el.text) or 0,true)
end)

script.on_event(defines.events.on_gui_value_changed,function(ev)
    ensure_init()
    local el=ev.element
    if not (el and el.valid and el.name=="ddz_replay_slider") then return end
    set_replay_pos_for_player(ev.player_index,el.slider_value or 0,false,true,true)
end)
