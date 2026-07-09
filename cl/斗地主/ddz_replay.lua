-- Replay recording and replay viewer.

local function replay_copy_card(c)
    return c and {suit=c.suit, val=c.val, rank=c.rank} or nil
end

local function replay_copy_cards(cards)
    local out={}
    for i,c in ipairs(cards or {}) do out[i]=replay_copy_card(c) end
    return out
end

local function replay_copy_hands(g)
    local out={}
    for _,pid in ipairs(g.order or {}) do
        out[pid]=replay_copy_cards(g.hands[pid] or {})
    end
    return out
end

local function replay_remove_cards(hand, cards)
    local used={}
    for _,rc in ipairs(cards or {}) do
        for i,hc in ipairs(hand or {}) do
            if not used[i] and hc.rank==rc.rank and hc.suit==rc.suit and hc.val==rc.val then
                used[i]=true
                break
            end
        end
    end
    for i=#hand,1,-1 do
        if used[i] then table.remove(hand,i) end
    end
end

local function replay_deep_copy(v)
    if type(v)~="table" then return v end
    local out={}
    for k,val in pairs(v) do out[k]=replay_deep_copy(val) end
    return out
end

local function replay_names(g)
    local names={}
    for _,pid in ipairs(g.order or {}) do names[pid]=pname(pid) end
    return names
end

function replay_init(g)
    g.replay_archive_id=nil
    g.replay={
        start={
            order={},
            hands=replay_copy_hands(g),
            bottom=replay_copy_cards(g.bottom or {}),
        },
        steps={},
        pos={},
    }
    for i,pid in ipairs(g.order or {}) do g.replay.start.order[i]=pid end
end

local function replay_add_step(g, step)
    if g and g.replay then g.replay.steps[#g.replay.steps+1]=step end
end

function replay_record_bid(g,pid,val)
    replay_add_step(g,{type="bid",player=pid,value=val})
end

function replay_record_landlord(g,pid)
    replay_add_step(g,{type="landlord",player=pid,bottom=replay_copy_cards(g.bottom or {})})
end

function replay_record_play(g,pid,cards)
    local pt=get_type(cards or {})
    replay_add_step(g,{
        type="play",
        player=pid,
        cards=replay_copy_cards(cards or {}),
        tp=pt and pt.tp or nil,
        key=pt and pt.key or nil,
        n=pt and pt.n or nil,
    })
end

function replay_record_pass(g,pid)
    replay_add_step(g,{type="pass",player=pid})
end

function replay_record_over(g,msg)
    replay_add_step(g,{type="over",msg=msg or (g and g.over_msg) or ddz_message("over-finished")})
    replay_archive_round(g)
end

function replay_cleanup_archive()
    local d=storage.ddz
    if not (d and d.replay_archive and d.replay_archive_order) then return end

    local protected={}
    for _,id in pairs(d.replay_view or {}) do
        if id then protected[id]=true end
    end

    local first_recent=math.max(1,#d.replay_archive_order-2)
    local keep={}
    for i,id in ipairs(d.replay_archive_order) do
        if i>=first_recent or protected[id] then keep[id]=true end
    end

    local new_order={}
    for _,id in ipairs(d.replay_archive_order) do
        if keep[id] and d.replay_archive[id] then
            new_order[#new_order+1]=id
        else
            d.replay_archive[id]=nil
        end
    end
    d.replay_archive_order=new_order
end

function replay_archive_round(g)
    if not (g and g.replay and g.replay.start) then return nil end
    local d=storage.ddz
    if not d then return nil end
    if not d.replay_archive then d.replay_archive={} end
    if not d.replay_archive_order then d.replay_archive_order={} end
    if not d.next_replay_id then d.next_replay_id=1 end

    local id=g.replay_archive_id
    if not id then
        id=d.next_replay_id
        d.next_replay_id=id+1
        g.replay_archive_id=id
        d.replay_archive_order[#d.replay_archive_order+1]=id
    else
        local found=false
        for _,old_id in ipairs(d.replay_archive_order) do
            if old_id==id then found=true; break end
        end
        if not found then d.replay_archive_order[#d.replay_archive_order+1]=id end
    end

    local rp=replay_deep_copy(g.replay)
    rp.pos={}
    d.replay_archive[id]={
        id=id,
        tid=g.tid,
        phase="over",
        over_msg=g.over_msg,
        names=replay_names(g),
        replay=rp,
    }

    replay_cleanup_archive()
    return d.replay_archive[id]
end

local function replay_name(src,pid)
    if is_ai(pid) then
        local raw=(src.names and src.names[pid]) or pname(pid)
        return ai_name_loc(raw)
    end
    return (src.names and src.names[pid]) or pname(pid)
end

local function replay_export_text_for(player)
    local locale=player and player.locale or ""
    if locale and locale:sub(1,2)=="en" then
        return {
            title="Dou Dizhu Replay Export",
            exporter="Exported by: ",
            table_id="Table: ",
            replay_id="Replay ID: ",
            players="Players",
            initial_hands="Initial hands",
            bottom="Bottom cards: ",
            steps="Steps",
            deal="[0] Deal complete. Bidding starts.",
            bid_none="%s did not bid",
            bid_score="%s bid %s",
            landlord="%s became landlord and took bottom cards: %s",
            play="%s played [%s]: %s",
            pass="%s passed",
            over="Game over: %s",
            none="(none)",
            unknown="Unknown",
            type_card="Cards",
            ai_a="AI A",
            ai_b="AI B",
            ai_c="AI C",
            ai_generic="AI",
            over_landlord="%s played all cards! Landlord wins!",
            over_farmer="%s played all cards! Farmers win!",
            over_disconnected="%s disconnected. This round is over.",
            over_quit="%s quit the game. This round is over.",
            over_left="%s left the table. This round is over.",
            over_finished="Game over.",
        }
    end
    return {
        title="斗地主回放导出",
        exporter="导出玩家：",
        table_id="桌号：",
        replay_id="回放ID：",
        players="玩家",
        initial_hands="初始手牌",
        bottom="底牌：",
        steps="步骤",
        deal="[0] 发牌完成，进入叫分。",
        bid_none="%s 不叫",
        bid_score="%s 叫%s分",
        landlord="%s 成为地主，获得底牌：%s",
        play="%s 出牌 [%s]：%s",
        pass="%s 跳过",
        over="游戏结束：%s",
        none="（无）",
        unknown="未知玩家",
        type_card="牌",
        ai_a="AI甲",
        ai_b="AI乙",
        ai_c="AI丙",
        ai_generic="AI",
        over_landlord="%s 出完了牌！地主胜！",
        over_farmer="%s 出完了牌！农民胜！",
        over_disconnected="%s 断线了，本局结束。",
        over_quit="%s 退出了游戏，本局结束。",
        over_left="%s 离桌了，本局结束。",
        over_finished="游戏结束。",
    }
end

local function replay_plain_arg(text, arg)
    if type(arg)=="string" or type(arg)=="number" then return tostring(arg) end
    if type(arg)~="table" then return text.unknown end
    local key=arg[1]
    if key=="" then
        local parts={}
        for i=2,#arg do parts[#parts+1]=replay_plain_arg(text,arg[i]) end
        return table.concat(parts,"")
    end
    if key=="ddz.ai-a" then return text.ai_a end
    if key=="ddz.ai-b" then return text.ai_b end
    if key=="ddz.ai-c" then return text.ai_c end
    if key=="ddz.ai-generic" then return tostring(arg[2] or text.ai_generic) end
    return tostring(arg[2] or key or text.unknown)
end

local function replay_plain_message(text, msg)
    if type(msg)=="string" then return msg end
    if type(msg)~="table" or not msg.key then return text.over_finished end
    local a=msg.args or {}
    local p1=replay_plain_arg(text,a[1])
    if msg.key=="over-landlord-win" then return string.format(text.over_landlord,p1) end
    if msg.key=="over-farmer-win" then return string.format(text.over_farmer,p1) end
    if msg.key=="over-disconnected" then return string.format(text.over_disconnected,p1) end
    if msg.key=="over-quit" then return string.format(text.over_quit,p1) end
    if msg.key=="over-left" then return string.format(text.over_left,p1) end
    if msg.key=="over-finished" then return text.over_finished end
    return msg.key
end

local function replay_export_name(src,pid,text)
    local raw=(src.names and src.names[pid]) or (is_ai(pid) and ("AI"..(-pid)) or ("P"..pid))
    if is_ai(pid) then
        if raw=="AI甲" then return text.ai_a end
        if raw=="AI乙" then return text.ai_b end
        if raw=="AI丙" then return text.ai_c end
    end
    return raw
end

local function replay_card_text(c)
    if not c then return "" end
    return tostring(c.val or "")..tostring(c.suit or "")
end

local function replay_cards_text(cards,text)
    local parts={}
    for _,c in ipairs(cards or {}) do parts[#parts+1]=replay_card_text(c) end
    if #parts==0 then return text.none end
    return table.concat(parts," ")
end

local function replay_type_text(tp, text)
    if not tp then return text.type_card end
    if text.title=="Dou Dizhu Replay Export" then
        local en={
            single="Single",pair="Pair",triple="Triple",t1="Triple + Single",t2="Triple + Pair",
            seq="Straight",pseq="Pair Sequence",plane="Plane",plane1="Plane + Singles",
            plane2="Plane + Pairs",s41="Four + Two Singles",s42="Four + Two Pairs",
            bomb="Bomb",rocket="Rocket"
        }
        return en[tp] or text.type_card
    end
    return TYPE_NAMES[tp] or text.type_card
end

function replay_export_archive(player, archive)
    if not (player and archive and archive.replay and archive.replay.start) then return nil end
    local text=replay_export_text_for(player)
    local rp=archive.replay
    local lines={
        text.title,
        text.exporter..player.name,
        text.table_id..tostring(archive.tid or "?"),
        text.replay_id..tostring(archive.id or "?"),
        "",
        text.players,
    }

    for _,pid in ipairs(rp.start.order or {}) do
        lines[#lines+1]="- "..replay_export_name(archive,pid,text)
    end
    lines[#lines+1]=""
    lines[#lines+1]=text.initial_hands
    for _,pid in ipairs(rp.start.order or {}) do
        lines[#lines+1]=replay_export_name(archive,pid,text)..": "..replay_cards_text((rp.start.hands or {})[pid],text)
    end
    lines[#lines+1]=text.bottom..replay_cards_text(rp.start.bottom or {},text)
    lines[#lines+1]=""
    lines[#lines+1]=text.steps
    lines[#lines+1]=text.deal

    for i,step in ipairs(rp.steps or {}) do
        if step.type=="bid" then
            if step.value==0 then
                lines[#lines+1]="["..i.."] "..string.format(text.bid_none,replay_export_name(archive,step.player,text))
            else
                lines[#lines+1]="["..i.."] "..string.format(text.bid_score,replay_export_name(archive,step.player,text),tostring(step.value))
            end
        elseif step.type=="landlord" then
            lines[#lines+1]="["..i.."] "..string.format(text.landlord,
                replay_export_name(archive,step.player,text),
                replay_cards_text(step.bottom or {},text))
        elseif step.type=="play" then
            lines[#lines+1]="["..i.."] "..string.format(text.play,
                replay_export_name(archive,step.player,text),
                replay_type_text(step.tp,text),
                replay_cards_text(step.cards or {},text))
        elseif step.type=="pass" then
            lines[#lines+1]="["..i.."] "..string.format(text.pass,replay_export_name(archive,step.player,text))
        elseif step.type=="over" then
            lines[#lines+1]="["..i.."] "..string.format(text.over,replay_plain_message(text,step.msg))
        end
    end

    local filename="斗地主/ddz_replay_"..tostring(archive.tid or "x").."_"..tostring(archive.id or "x")..".txt"
    helpers.write_file(filename,table.concat(lines,"\n"),false,player.index)
    return filename
end

local function replay_build_state(src,pos)
    local rp=src.replay
    local st={
        order={},
        hands={},
        bottom=replay_copy_cards(rp.start.bottom or {}),
        bottom_played={},
        bottom_visible=false,
        landlord=nil,
        last=nil,
        actor=nil,
        desc=DDZ_L("replay-deal"),
    }
    for i,pid in ipairs(rp.start.order or {}) do
        st.order[i]=pid
        st.hands[pid]=replay_copy_cards(rp.start.hands[pid] or {})
    end
    for i=1,pos do
        local step=rp.steps[i]
        if step then
            if step.type=="bid" then
                st.actor=step.player
                if step.value==0 then
                    st.desc=DDZ_L("replay-bid-none",replay_name(src,step.player))
                else
                    st.desc=DDZ_L("replay-bid-score",replay_name(src,step.player),step.value)
                end
            elseif step.type=="landlord" then
                st.actor=step.player
                st.landlord=step.player
                st.bottom_visible=true
                if not st.hands[step.player] then st.hands[step.player]={} end
                for _,c in ipairs(step.bottom or {}) do
                    table.insert(st.hands[step.player], replay_copy_card(c))
                end
                sort_hand(st.hands[step.player])
                st.desc=DDZ_L("replay-landlord",replay_name(src,step.player))
            elseif step.type=="play" then
                st.actor=step.player
                replay_remove_cards(st.hands[step.player], step.cards)
                for _,c in ipairs(step.cards or {}) do
                    for i,bc in ipairs(st.bottom or {}) do
                        if not st.bottom_played[i] and card_same(c,bc) then
                            st.bottom_played[i]=true
                            break
                        end
                    end
                end
                st.last={by=step.player,tp=step.tp,cards=step.cards}
                st.desc=DDZ_L("replay-play",replay_name(src,step.player),type_name_loc(step.tp))
            elseif step.type=="pass" then
                st.actor=step.player
                st.desc=DDZ_L("replay-pass",replay_name(src,step.player))
            elseif step.type=="over" then
                st.actor=nil
                st.desc=ddz_message_caption(step.msg) or DDZ_L("over-finished")
            end
        end
    end
    return st
end

local function replay_card(parent,c,w,h)
    return add_static_card_face(parent,c,w or DDZ_CARD_W,h or DDZ_CARD_H,false)
end

local function replay_card_overlap(overlap)
    overlap=overlap or 0
    if overlap<0 then overlap=0 end
    if overlap>DDZ_CARD_OVERLAP_MAX then overlap=DDZ_CARD_OVERLAP_MAX end
    return overlap
end

local function replay_cards(parent,cards,overlap_px)
    local flow=parent.add{type="flow",direction="horizontal"}
    flow.style.horizontal_spacing=1
    local overlap=replay_card_overlap(overlap_px)
    for i,c in ipairs(cards or {}) do
        local b=replay_card(flow,c,DDZ_CARD_W,DDZ_CARD_H)
        if i>1 and overlap>0 then b.style.left_margin=-overlap end
    end
end

function clear_replay_gui(p)
    local f=p.gui.screen.ddz_replay
    if f and f.valid then
        local loc=f.location
        if loc then
            local d=storage.ddz
            if d then
                if not d.replay_pos then d.replay_pos={} end
                d.replay_pos[p.index]={x=loc.x,y=loc.y}
            end
        end
        f.destroy()
    end
end

local function apply_replay_pos(p,f)
    local d=storage.ddz
    local pos=d and d.replay_pos and d.replay_pos[p.index]
    if pos then
        f.auto_center=false
        f.location={x=pos.x,y=pos.y}
    end
end

local function replay_pos_for_player(p,g)
    local rp=g.replay
    if not rp.pos then rp.pos={} end
    local pos=rp.pos[p.index] or 0
    local max=#(rp.steps or {})
    if pos<0 then pos=0 end
    if pos>max then pos=max end
    rp.pos[p.index]=pos
    return pos,max
end

local function populate_replay_body(parent,g,st)
    local bot=parent.add{type="flow",direction="horizontal"}
    bot.style.vertical_align="center"
    bot.add{type="label",caption=DDZ_L("bottom-cards")}
    if st.bottom_visible then
        for i,c in ipairs(st.bottom or {}) do add_static_card_face(bot,c,DDZ_CARD_W,DDZ_CARD_H,st.bottom_played and st.bottom_played[i]) end
    else
        for i=1,3 do
            add_back_card(bot,DDZ_CARD_W,DDZ_CARD_H,st.bottom and st.bottom[i])
        end
    end
    if st.last then
        bot.add{type="label",caption=DDZ_L("current-cards",replay_name(g,st.last.by),type_name_loc(st.last.tp))}
        replay_cards(bot,st.last.cards or {},DDZ_CARD_OVERLAP)
    end
    parent.add{type="line"}

    for _,pid in ipairs(st.order or {}) do
        local role=st.landlord and ((pid==st.landlord) and DDZ_L("landlord-role") or DDZ_L("farmer-role")) or DDZ_L("unset-role")
        local hand=st.hands[pid] or {}
        local arrow=pid==st.actor and "[color=1,0.9,0.1]▶ [/color]" or "   "
        local title=parent.add{type="label",caption=DDZ_S(arrow,replay_name(g,pid),"  [",role,"]  ",DDZ_L("cards-blue",#hand))}
        title.style.font="default-bold"
        replay_cards(parent,hand,DDZ_CARD_OVERLAP)
        parent.add{type="line"}
    end
end

function refresh_replay_gui_content(p,g,skip_slider)
    if not (g and g.replay and g.replay.start) then return false end
    local f=p.gui.screen.ddz_replay
    if not (f and f.valid) then return false end
    local pos,max=replay_pos_for_player(p,g)
    local st=replay_build_state(g,pos)
    local head=f["ddz_replay_head"]
    if head and head.valid then head.caption=DDZ_L("replay-head",pos,max,st.desc) end
    local body=f["ddz_replay_body"]
    if body and body.valid then
        for i=#body.children,1,-1 do body.children[i].destroy() end
        populate_replay_body(body,g,st)
    end
    local jf=f["ddz_replay_jump_flow"]
    if jf and jf.valid then
        local input=jf["ddz_replay_jump_input"]
        if input and input.valid then input.text=tostring(pos) end
        local slider=jf["ddz_replay_slider"]
        if slider and slider.valid and not skip_slider then slider.slider_value=pos end
    end
    return true
end

function gui_replay(p,g)
    clear_replay_gui(p)
    if not (g and g.replay and g.replay.start) then
        p.print(DDZ_L("replay-none"))
        return
    end
    local pos,max=replay_pos_for_player(p,g)
    local st=replay_build_state(g,pos)

    local f=p.gui.screen.add{type="frame",name="ddz_replay",direction="vertical"}
    f.auto_center=true
    f.style.minimal_width=940
    apply_replay_pos(p,f)
    add_titlebar(f,DDZ_L("title-replay",g.tid),"ddz_replay_close")

    local head=f.add{type="label",name="ddz_replay_head",caption=DDZ_L("replay-head",pos,max,st.desc)}
    head.style.font="default-bold"
    local body=f.add{type="flow",name="ddz_replay_body",direction="vertical"}
    populate_replay_body(body,g,st)

    local bf=f.add{type="flow",direction="horizontal"}
    bf.add{type="button",name="ddz_replay_prev",caption=DDZ_L("prev-step")}
    bf.add{type="button",name="ddz_replay_next",caption=DDZ_L("next-step")}
    bf.add{type="button",name="ddz_replay_last",caption=DDZ_L("last-step")}
    bf.add{type="button",name="ddz_replay_export",caption=DDZ_L("export-replay")}
    bf.add{type="button",name="ddz_replay_close",caption=DDZ_L("close")}

    local jf=f.add{type="flow",name="ddz_replay_jump_flow",direction="horizontal"}
    jf.style.vertical_align="center"
    jf.add{type="label",caption=DDZ_L("replay-jump-label")}
    local input=jf.add{type="textfield",name="ddz_replay_jump_input",text=tostring(pos),numeric=true,allow_decimal=false,allow_negative=false}
    input.style.width=64
    jf.add{type="button",name="ddz_replay_jump",caption=DDZ_L("replay-jump")}
    local slider=jf.add{type="slider",name="ddz_replay_slider",minimum_value=0,maximum_value=math.max(1,max),value=pos,value_step=1,discrete_values=true}
    slider.style.width=620
end
