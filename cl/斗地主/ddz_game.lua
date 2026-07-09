-- Game flow, bidding, playing, passing, and scoring actions.

-- ── Game actions ─────────────────────────────────────────────────────────────

function deal(g)
    local d=create_deck(); shuffle(d)
    for _,pid in ipairs(g.order) do g.hands[pid]={} end
    for i=1,51 do
        local seat=((i-1)%3)+1
        table.insert(g.hands[g.order[seat]],d[i])
    end
    g.bottom={card_copy(d[52]),card_copy(d[53]),card_copy(d[54])}
    g.played_bottom={}
    g.played_suits={}
    for _,pid in ipairs(g.order) do sort_hand(g.hands[pid]) end
end

function start_bidding(g)
    g.phase="bidding"; g.bid_turn=1; g.bid_val=0
    g.bid_who=nil; g.bids_done=0; g.bid_status={}
    g.bid_pending=false; g.bid_pending_who=nil; g.bid_pending_tick=0
    g.redeal_pending=false; g.redeal_pending_tick=0
    g.final_play=nil
    g.turn_tick=game.tick
    deal(g); replay_init(g); refresh_table(g); refresh_lobby()
    ddz_play_table_sound(g,"item_spawned",0.6)
    ddz_play_turn_prompt(g)
end

assign_landlord = nil
function set_redeal_pending(g)
    g.redeal_pending=true
    g.redeal_pending_tick=game.tick+180
    g.ai_pending=false
    g.turn_tick=game.tick
    refresh_table(g)
    ddz_play_table_sound(g,"scenario_message",0.65)
end

function finish_redeal_pending(g)
    g.bids_done=0; g.bid_turn=1; g.bid_val=0; g.bid_who=nil; g.bid_status={}
    g.bid_pending=false; g.bid_pending_who=nil; g.bid_pending_tick=0
    g.redeal_pending=false; g.redeal_pending_tick=0
    g.ai_pending=false
    g.turn_tick=game.tick
    deal(g); replay_init(g); refresh_table(g)
    ddz_play_table_sound(g,"item_spawned",0.6)
    ddz_play_turn_prompt(g)
end

function set_bid_pending(g, winner)
    g.bid_pending=true; g.bid_pending_who=winner
    g.bid_pending_tick=game.tick+180
    g.redeal_pending=false; g.redeal_pending_tick=0
    g.turn_tick=game.tick
    refresh_table(g)
    ddz_play_table_sound(g,"research_completed",0.65)
end

function do_bid(g,pid,val)
    if g.bid_pending or g.redeal_pending then return end
    if g.order[g.bid_turn]~=pid then return end
    g.bids_done=g.bids_done+1; g.bid_status[pid]=val
    replay_record_bid(g,pid,val)
    ddz_play_table_sound(g,val>0 and "confirm" or "list_box_click",0.6)
    if val>0 and val>g.bid_val then g.bid_val=val; g.bid_who=pid end
    if val==3 then set_bid_pending(g,pid); return end
    g.bid_turn=g.bid_turn%3+1; g.turn_tick=game.tick
    if g.bids_done>=3 then
        if g.bid_who then set_bid_pending(g,g.bid_who)
        else
            set_redeal_pending(g)
        end
        return
    end
    refresh_table(g)
    ddz_play_turn_prompt(g)
end

assign_landlord=function(g,pid)
    g.landlord=pid
    for _,c in ipairs(g.bottom) do table.insert(g.hands[pid],card_copy(c)) end
    sort_hand(g.hands[pid])
    for i,qid in ipairs(g.order) do if qid==pid then g.play_turn=i; break end end
    g.last=nil; g.passes=0; g.sel={}; g.msg={}; g.phase="playing"
    g.last_play_by={}; g.pass_by={}; g.played_cards={}; g.played_suits={}; g.played_bottom={}
    g.bid_status={}; g.bid_pending=false; g.bid_pending_who=nil; g.bid_pending_tick=0
    g.redeal_pending=false; g.redeal_pending_tick=0; g.final_play=nil
    g.turn_tick=game.tick
    replay_record_landlord(g,pid)
    refresh_table(g); refresh_lobby()
    ddz_play_turn_prompt(g)
end

function do_play(g,pid)
    if g.order[g.play_turn]~=pid then return end
    local sel=g.sel[pid] or {}; local idxs={}
    for i,v in pairs(sel) do if v then idxs[#idxs+1]=i end end
    if #idxs==0 then
        if not is_ai(pid) then
            g.msg[pid]=ddz_message("msg-select-card")
            local p=game.players[pid]; if p then ddz_play_sound(p,"cannot_build",0.7); rebuild_one(p) end
        end
        return
    end
    local hand=g.hands[pid]; local cards={}
    for _,i in ipairs(idxs) do if hand[i] then cards[#cards+1]=hand[i] end end
    local pt=get_type(cards)
    if not pt then
        if not is_ai(pid) then
            g.msg[pid]=ddz_message("msg-invalid-type"); g.sel[pid]={}
            local p=game.players[pid]; if p then ddz_play_sound(p,"cannot_build",0.7); rebuild_one(p) end
        end
        return
    end
    if g.last and g.last.by~=pid then
        if not can_beat(g.last,pt) then
            if not is_ai(pid) then
                g.msg[pid]=ddz_message("msg-too-small"); g.sel[pid]={}
                local p=game.players[pid]; if p then ddz_play_sound(p,"cannot_build",0.7); rebuild_one(p) end
            end
            return
        end
    end
    table.sort(idxs,function(a,b) return a>b end)
    for _,i in ipairs(idxs) do table.remove(hand,i) end
    local display_cards=order_play_cards(cards,pt)
    g.last={tp=pt.tp,key=pt.key,n=pt.n,by=pid,cards=display_cards}
    g.passes=0; g.sel[pid]={}; g.msg[pid]=nil
    g.last_play_by[pid]=display_cards; g.pass_by[pid]=false
    g.final_play={by=pid,cards=display_cards}
    replay_record_play(g,pid,display_cards)
    ddz_play_card_action(g,pt)
    if not g.played_suits then g.played_suits={} end
    for _,c in ipairs(display_cards) do
        g.played_cards[c.val]=(g.played_cards[c.val] or 0)+1
        if c.suit and c.suit~="" then
            if not g.played_suits[c.val] then g.played_suits[c.val]={} end
            g.played_suits[c.val][c.suit]=(g.played_suits[c.val][c.suit] or 0)+1
        end
        for i,bc in ipairs(g.bottom or {}) do
            if not g.played_bottom[i] and card_same(c,bc) then
                g.played_bottom[i]=true
                break
            end
        end
    end
    if #hand==0 then
        record_stats(g,pid)
        g.over_msg=ddz_message(pid==g.landlord and "over-landlord-win" or "over-farmer-win",pname_loc(pid))
        replay_record_over(g,g.over_msg)
        ddz_play_game_over(g,pid)
        clear_table_trustees(g)
        g.phase="over"; refresh_table(g); refresh_lobby(); return
    end
    g.play_turn=g.play_turn%3+1; g.turn_tick=game.tick; refresh_table(g)
    ddz_play_turn_prompt(g)
end

function do_pass(g,pid)
    if g.order[g.play_turn]~=pid then return end
    if not g.last or g.last.by==pid then
        if not is_ai(pid) then
            g.msg[pid]=ddz_message("msg-must-play")
            local p=game.players[pid]; if p then ddz_play_sound(p,"cannot_build",0.7); rebuild_one(p) end
        end
        return
    end
    g.passes=g.passes+1; g.sel[pid]={}; g.msg[pid]=nil
    g.last_play_by[pid]=nil; g.pass_by[pid]=true
    replay_record_pass(g,pid)
    ddz_play_table_sound(g,"list_box_click",0.55)
    g.play_turn=g.play_turn%3+1; g.turn_tick=game.tick
    if g.passes>=2 then g.last=nil; g.passes=0; g.pass_by={} end
    refresh_table(g)
    ddz_play_turn_prompt(g)
end
