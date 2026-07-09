-- AI decision making and timeout actions.

-- ── AI logic ─────────────────────────────────────────────────────────────────

local function longest_run(ranks)
    local best=0; local cur=0; local prev=nil
    for _,r in ipairs(ranks) do
        if prev and r==prev+1 then
            cur=cur+1
        else
            cur=1
        end
        if cur>best then best=cur end
        prev=r
    end
    return best
end

function ai_bid_score(hand)
    local cnt=rank_counts(hand or {})
    local ranks=sorted_keys(cnt)
    local score=0

    if cnt[16] and cnt[17] then score=score+10 end
    score=score+(cnt[17] or 0)*6
    score=score+(cnt[16] or 0)*5
    score=score+(cnt[15] or 0)*3
    score=score+(cnt[14] or 0)*2
    score=score+(cnt[13] or 0)

    local singles=0
    local seq_ranks={}
    local pair_ranks={}
    local triple_ranks={}
    for _,r in ipairs(ranks) do
        local n=cnt[r]
        if n==4 then score=score+8
        elseif n==3 then score=score+4
        elseif n==2 then score=score+2
        elseif n==1 and r<15 then singles=singles+1 end
        if r<15 then
            if n>=1 then seq_ranks[#seq_ranks+1]=r end
            if n>=2 then pair_ranks[#pair_ranks+1]=r end
            if n>=3 then triple_ranks[#triple_ranks+1]=r end
        end
    end

    local seq_len=longest_run(seq_ranks)
    if seq_len>=5 then score=score+(seq_len-4)*2 end
    local pair_len=longest_run(pair_ranks)
    if pair_len>=3 then score=score+(pair_len-2)*2 end
    local plane_len=longest_run(triple_ranks)
    if plane_len>=2 then score=score+plane_len*3 end

    if singles>5 then score=score-(singles-5) end
    return score
end

function ai_choose_bid(hand,current_bid)
    local score=ai_bid_score(hand)
    local desired=0
    if score>=22 then desired=3
    elseif score>=15 then desired=2
    elseif score>=9 then desired=1 end

    current_bid=current_bid or 0
    if desired>current_bid then return desired end
    return 0
end

local function rank_cards(byr,r,count,start)
    local out={}
    start=start or 1
    for i=start,math.min(#(byr[r] or {}),start+count-1) do out[#out+1]=byr[r][i] end
    return out
end

local function append_cards(out,cards)
    for _,c in ipairs(cards or {}) do out[#out+1]=c end
end

local function collect_kickers(byr,ranks,need,used_count,need_pair)
    local out={}
    for _,r in ipairs(ranks) do
        if #(byr[r] or {})~=4 then
            local start=(used_count and used_count[r] or 0)+1
            if need_pair then
                if #byr[r]-start+1>=2 then
                    out[#out+1]=byr[r][start]
                    out[#out+1]=byr[r][start+1]
                    if #out>=need then return out end
                end
            else
                for i=start,#byr[r] do
                    out[#out+1]=byr[r][i]
                    if #out>=need then return out end
                end
            end
        end
    end
    return #out>=need and out or nil
end

local function add_candidate(candidates,cards,last)
    local pt=get_type(cards or {})
    if not pt then return end
    if last and not can_beat(last,pt) then return end
    candidates[#candidates+1]={cards=order_play_cards(cards,pt),pt=pt}
end

local function add_run_candidates(candidates,byr,ranks,min_len,count,last)
    local usable={}
    for _,r in ipairs(ranks) do
        if r<15 and #byr[r]>=count and #byr[r]~=4 then usable[#usable+1]=r end
    end
    for i=1,#usable do
        local run={usable[i]}
        local j=i+1
        while j<=#usable and usable[j]==run[#run]+1 do
            run[#run+1]=usable[j]
            j=j+1
        end
        if #run>=min_len then
            for len=min_len,#run do
                for s=1,#run-len+1 do
                    local cards={}
                    for k=s,s+len-1 do append_cards(cards,rank_cards(byr,run[k],count)) end
                    add_candidate(candidates,cards,last)
                end
            end
        end
    end
end

local function collect_ai_candidates(hand,last)
    sort_hand(hand)
    local byr={}
    for _,c in ipairs(hand) do
        if not byr[c.rank] then byr[c.rank]={} end
        byr[c.rank][#byr[c.rank]+1]=c
    end
    local ranks=sorted_keys(byr)
    local candidates={}

    for _,r in ipairs(ranks) do if #byr[r]~=4 then add_candidate(candidates,rank_cards(byr,r,1),last) end end
    for _,r in ipairs(ranks) do if #byr[r]>=2 and #byr[r]~=4 then add_candidate(candidates,rank_cards(byr,r,2),last) end end
    for _,r in ipairs(ranks) do if #byr[r]==3 then add_candidate(candidates,rank_cards(byr,r,3),last) end end

    for _,r in ipairs(ranks) do
        if #byr[r]==3 then
            local body=rank_cards(byr,r,3)
            local one=collect_kickers(byr,ranks,1,{[r]=3},false)
            if one then local cards={}; append_cards(cards,body); append_cards(cards,one); add_candidate(candidates,cards,last) end
            local pair=collect_kickers(byr,ranks,2,{[r]=3},true)
            if pair then local cards={}; append_cards(cards,body); append_cards(cards,pair); add_candidate(candidates,cards,last) end
        end
    end

    add_run_candidates(candidates,byr,ranks,5,1,last)
    add_run_candidates(candidates,byr,ranks,3,2,last)

    local triple_ranks={}
    for _,r in ipairs(ranks) do if r<15 and #byr[r]==3 then triple_ranks[#triple_ranks+1]=r end end
    for i=1,#triple_ranks do
        local run={triple_ranks[i]}
        local j=i+1
        while j<=#triple_ranks and triple_ranks[j]==run[#run]+1 do run[#run+1]=triple_ranks[j]; j=j+1 end
        for len=2,#run do
            for s=1,#run-len+1 do
                local used_count={}; local body={}
                for k=s,s+len-1 do
                    local r=run[k]; used_count[r]=3; append_cards(body,rank_cards(byr,r,3))
                end
                add_candidate(candidates,body,last)
                local singles=collect_kickers(byr,ranks,len,used_count,false)
                if singles then local cards={}; append_cards(cards,body); append_cards(cards,singles); add_candidate(candidates,cards,last) end
                local pairs=collect_kickers(byr,ranks,len*2,used_count,true)
                if pairs then local cards={}; append_cards(cards,body); append_cards(cards,pairs); add_candidate(candidates,cards,last) end
            end
        end
    end

    for _,r in ipairs(ranks) do
        if #byr[r]>=4 then
            local body=rank_cards(byr,r,4)
            local singles=collect_kickers(byr,ranks,2,{[r]=4},false)
            if singles then local cards={}; append_cards(cards,body); append_cards(cards,singles); add_candidate(candidates,cards,last) end
            local pairs=collect_kickers(byr,ranks,4,{[r]=4},true)
            if pairs then local cards={}; append_cards(cards,body); append_cards(cards,pairs); add_candidate(candidates,cards,last) end
            add_candidate(candidates,body,last)
        end
    end
    if byr[16] and byr[17] then add_candidate(candidates,{byr[16][1],byr[17][1]},last) end

    return candidates
end

local function same_team(g,a,b)
    if not g or not a or not b or a==b then return false end
    return a~=g.landlord and b~=g.landlord
end

local function landlord_cards_left(g)
    if not g or not g.landlord or not g.hands then return 99 end
    return #(g.hands[g.landlord] or {})
end

local function ai_score_candidate(g,pid,c,last,hand_count)
    local pt=c.pt
    local n=pt.n or #(c.cards or {})
    local score=n*30-(pt.key or 0)
    if n==hand_count then score=score+10000 end
    if last then
        score=score+1000
        local critical=landlord_cards_left(g)<=2
        if same_team(g,pid,last.by) and n~=hand_count then score=score-10000 end
        if g and last.by==g.landlord then score=score+200 end
        if critical and g and last.by==g.landlord then score=score+500 end
        if pt.tp=="bomb" or pt.tp=="rocket" then
            score=score+(critical and 300 or -350)
        end
    else
        if pt.tp=="single" then score=score+80
        elseif pt.tp=="pair" then score=score+70
        elseif pt.tp=="triple" then score=score+60
        elseif pt.tp=="seq" or pt.tp=="pseq" or pt.tp=="plane" or pt.tp=="plane1" or pt.tp=="plane2" then score=score+120
        elseif pt.tp=="bomb" or pt.tp=="rocket" then score=score-500 end
    end
    return score
end

function ai_choose_cards_for(g,pid,hand,last)
    local candidates=collect_ai_candidates(hand or {},last)
    local best=nil; local best_score=nil
    for _,c in ipairs(candidates) do
        local score=ai_score_candidate(g,pid,c,last,#(hand or {}))
        if not best_score or score>best_score then
            best=c; best_score=score
        end
    end
    if last and best_score and best_score<-5000 then return nil end
    return best and best.cards or nil
end

function ai_choose_cards(hand,last)
    return ai_choose_cards_for(nil,nil,hand,last)
end

local function is_trusted_player(pid)
    local d=storage.ddz
    return pid and (not is_ai(pid)) and d and d.trustees and d.trustees[pid]
end

local function is_auto_actor(pid)
    return pid and (is_ai(pid) or is_trusted_player(pid))
end

function do_ai_turn_for(g)
    g.ai_pending=false
    if g.phase=="bidding" then
        if g.bid_pending or g.redeal_pending then return end
        local pid=g.order[g.bid_turn]
        if not is_auto_actor(pid) then return end
        do_bid(g,pid,ai_choose_bid(g.hands and g.hands[pid] or {},g.bid_val or 0))
    elseif g.phase=="playing" then
        local pid=g.order[g.play_turn]
        if not is_auto_actor(pid) then return end
        local hand=g.hands[pid]
        if not hand or #hand==0 then return end
        local last=(g.last and g.last.by~=pid) and g.last or nil
        local cards=ai_choose_cards_for(g,pid,hand,last)
        if not cards then do_pass(g,pid); return end
        if not g.sel[pid] then g.sel[pid]={} end
        g.sel[pid]={}
        local used={}
        for _,ac in ipairs(cards) do
            for i,hc in ipairs(hand) do
                if not used[i] and hc.rank==ac.rank and hc.suit==ac.suit then
                    g.sel[pid][i]=true; used[i]=true; break
                end
            end
        end
        do_play(g,pid)
    end
end

function do_auto_timeout(g)
    if g.phase=="bidding" then
        if g.bid_pending then return end
        local pid=g.order[g.bid_turn]
        if pid and not is_ai(pid) then
            if not storage.ddz.trustees then storage.ddz.trustees={} end
            storage.ddz.trustees[pid]=true
            local p=game.players[pid]; if p then ddz_play_sound(p,"alert_destroyed",0.7) end
            do_ai_turn_for(g)
        end
    elseif g.phase=="playing" then
        local pid=g.order[g.play_turn]
        if pid and not is_ai(pid) then
            if not storage.ddz.trustees then storage.ddz.trustees={} end
            storage.ddz.trustees[pid]=true
            local p=game.players[pid]; if p then ddz_play_sound(p,"alert_destroyed",0.7) end
            do_ai_turn_for(g)
        end
    end
end
