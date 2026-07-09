-- Card rendering, deck helpers, and card type detection.

-- ── Card helpers ─────────────────────────────────────────────────────────────

function card_str(c)
    if c.suit=="" then
        if c.val=="大王" then return DDZ_S("[color=0.75,0,0]",card_value_loc(c.val),"[/color]") end
        return card_value_loc(c.val)
    end
    local s=c.suit..c.val
    if c.suit=="♥" or c.suit=="♦" then return "[color=0.75,0,0]"..s.."[/color]" end
    return s
end

-- 扑克牌按钮文字（横向显示，红花色用红，选中用黄）
function card_btn_cap(c, sel)
    local txt=(c.suit~="" and (c.val..c.suit) or card_value_loc(c.val))
    if sel then return DDZ_S("[color=1,1,0]",txt,"[/color]") end
    local is_red=(c.suit=="♥" or c.suit=="♦") or (c.suit=="" and c.val=="大王")
    if is_red then return DDZ_S("[color=0.75,0,0]",txt,"[/color]") end
    return txt
end

function card_copy(c)
    return c and {suit=c.suit,val=c.val,rank=c.rank} or nil
end

function card_same(a,b)
    return a and b and a.rank==b.rank and a.suit==b.suit and a.val==b.val
end

function create_deck()
    local d={}
    for _,s in ipairs(SUITS) do
        for _,v in ipairs(VALS) do d[#d+1]={suit=s,val=v,rank=RANK[v]} end
    end
    d[#d+1]={suit="",val="小王",rank=16}
    d[#d+1]={suit="",val="大王",rank=17}
    return d
end

function shuffle(d)
    for i=#d,2,-1 do local j=math.random(1,i); d[i],d[j]=d[j],d[i] end
end

function sort_hand(h)
    table.sort(h,function(a,b)
        if a.rank~=b.rank then return a.rank>b.rank end
        return (a.suit or "")>(b.suit or "")
    end)
end

-- ── Card type detection ──────────────────────────────────────────────────────

function rank_counts(cards)
    local c={}
    for _,card in ipairs(cards) do c[card.rank]=(c[card.rank] or 0)+1 end
    return c
end

function sorted_keys(t)
    local r={}; for k in pairs(t) do r[#r+1]=k end; table.sort(r); return r
end

function get_type(cards)
    local n=#cards; if n==0 then return nil end
    local cnt=rank_counts(cards); local ranks=sorted_keys(cnt)
    if n==2 and cnt[16] and cnt[17] then return {tp="rocket",key=17,n=2} end
    if n==4 and #ranks==1 then return {tp="bomb",key=ranks[1],n=4} end
    if n==1 then return {tp="single",key=ranks[1],n=1} end
    if n==2 and cnt[ranks[1]]==2 then return {tp="pair",key=ranks[1],n=2} end
    if n==3 and #ranks==1 then return {tp="triple",key=ranks[1],n=3} end
    if n==4 then
        for r,c in pairs(cnt) do if c==3 then return {tp="t1",key=r,n=4} end end
    end
    if n==5 then
        local k3=nil
        for r,c in pairs(cnt) do if c==3 then k3=r end end
        if k3 then
            for r,c in pairs(cnt) do
                if r~=k3 and c==2 then return {tp="t2",key=k3,n=5} end
            end
        end
    end
    if n>=5 then
        local ok=(#ranks==n)
        if ok then for _,r in ipairs(ranks) do if cnt[r]~=1 or r>=15 then ok=false;break end end end
        if ok then
            local seq=true
            for i=2,#ranks do if ranks[i]~=ranks[i-1]+1 then seq=false;break end end
            if seq then return {tp="seq",key=ranks[#ranks],n=n} end
        end
    end
    if n>=6 and n%2==0 then
        local ok=(#ranks==n/2)
        if ok then for _,r in ipairs(ranks) do if cnt[r]~=2 or r>=15 then ok=false;break end end end
        if ok then
            local seq=true
            for i=2,#ranks do if ranks[i]~=ranks[i-1]+1 then seq=false;break end end
            if seq then return {tp="pseq",key=ranks[#ranks],n=n} end
        end
    end
    local triples={}
    for _,r in ipairs(ranks) do if cnt[r]>=3 and r<15 then triples[#triples+1]=r end end
    if #triples>=2 then
        table.sort(triples)
        local seq=true
        for i=2,#triples do if triples[i]~=triples[i-1]+1 then seq=false;break end end
        if seq then
            local wings=n-#triples*3
            if wings==0 then return {tp="plane",key=triples[#triples],n=n} end
            if wings==#triples then
                local ok=true
                for r,c in pairs(cnt) do
                    local in_triple=false
                    for _,tr in ipairs(triples) do if tr==r then in_triple=true; break end end
                    if in_triple then
                        if c<3 then ok=false; break end
                    end
                end
                if ok then return {tp="plane1",key=triples[#triples],n=n} end
            end
            if wings==#triples*2 then
                local ok=true
                for r,c in pairs(cnt) do
                    local in_triple=false
                    for _,tr in ipairs(triples) do if tr==r then in_triple=true; break end end
                    if in_triple then
                        if c~=3 then ok=false; break end
                    elseif c~=2 then
                        ok=false; break
                    end
                end
                if ok then return {tp="plane2",key=triples[#triples],n=n} end
            end
        end
    end
    if n==6 then
        for _,r in ipairs(ranks) do
            if cnt[r]==4 then
                local wings=0
                for _,r2 in ipairs(ranks) do
                    if r2~=r then wings=wings+cnt[r2] end
                end
                if wings==2 then
                    return {tp="s41",key=r,n=6}
                end
            end
        end
    end
    if n==8 then
        for _,r in ipairs(ranks) do
            if cnt[r]==4 then
                local ps={}
                for _,r2 in ipairs(ranks) do
                    if r2~=r and cnt[r2]==2 then ps[#ps+1]=r2 end
                end
                if #ps==2 then return {tp="s42",key=r,n=8} end
            end
        end
    end
    return nil
end

local function copy_sorted_cards(cards)
    local out={}
    for i,c in ipairs(cards or {}) do out[i]=c end
    sort_hand(out)
    return out
end

local function card_groups(cards)
    local groups={}
    for _,c in ipairs(copy_sorted_cards(cards)) do
        if not groups[c.rank] then groups[c.rank]={} end
        groups[c.rank][#groups[c.rank]+1]=c
    end
    return groups
end

local function append_rank_cards(out, used, groups, rank, count)
    local group=groups[rank] or {}
    for i=1,math.min(count,#group) do out[#out+1]=group[i] end
    used[rank]=(used[rank] or 0)+count
end

local function append_unused_cards(out, used, cards)
    for _,c in ipairs(copy_sorted_cards(cards)) do
        local n=used[c.rank] or 0
        if n>0 then
            used[c.rank]=n-1
        else
            out[#out+1]=c
        end
    end
end

function order_play_cards(cards, pt)
    pt=pt or get_type(cards or {})
    if not pt then return copy_sorted_cards(cards) end

    local tp=pt.tp
    if tp~="t1" and tp~="t2" and tp~="s41" and tp~="s42"
        and tp~="plane" and tp~="plane1" and tp~="plane2" then
        return copy_sorted_cards(cards)
    end

    local groups=card_groups(cards)
    local out={}
    local used={}

    if tp=="t1" or tp=="t2" then
        append_rank_cards(out,used,groups,pt.key,3)
        append_unused_cards(out,used,cards)
        return out
    end

    if tp=="s41" or tp=="s42" then
        append_rank_cards(out,used,groups,pt.key,4)
        append_unused_cards(out,used,cards)
        return out
    end

    local triple_count=math.floor(pt.n/3)
    if tp=="plane1" then triple_count=math.floor(pt.n/4)
    elseif tp=="plane2" then triple_count=math.floor(pt.n/5) end

    for r=pt.key,pt.key-triple_count+1,-1 do
        append_rank_cards(out,used,groups,r,3)
    end
    append_unused_cards(out,used,cards)
    return out
end

function can_beat(last,play)
    if play.tp=="rocket" then return true end
    if play.tp=="bomb" and last.tp~="bomb" and last.tp~="rocket" then return true end
    if play.tp==last.tp and play.n==last.n then return play.key>last.key end
    return false
end
