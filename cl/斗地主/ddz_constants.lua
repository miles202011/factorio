-- Constants and shared names for the Dou Dizhu table logic.

-- 斗地主 多牌桌版（动态开桌，准备机制）

SUITS = {"♠","♥","♦","♣"}
VALS = {"3","4","5","6","7","8","9","10","J","Q","K","A","2"}
RANK = {["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,
               ["9"]=9,["10"]=10,["J"]=11,["Q"]=12,["K"]=13,
               ["A"]=14,["2"]=15,["小王"]=16,["大王"]=17}
TYPE_NAMES ={
    single="单张",pair="对子",triple="三张",
    t1="三带一",t2="三带二",
    seq="顺子",pseq="连对",
    plane="飞机",plane1="飞机带单翅",plane2="飞机带对翅",
    s41="四带两单",s42="四带两对",
    bomb="炸弹",rocket="火箭"
}
TYPE_KEYS ={
    single="type-single",pair="type-pair",triple="type-triple",
    t1="type-t1",t2="type-t2",
    seq="type-seq",pseq="type-pseq",
    plane="type-plane",plane1="type-plane1",plane2="type-plane2",
    s41="type-s41",s42="type-s42",
    bomb="type-bomb",rocket="type-rocket"
}
VAL_MAX ={["大王"]=1,["小王"]=1,
    ["2"]=4,["A"]=4,["K"]=4,["Q"]=4,["J"]=4,["10"]=4,
    ["9"]=4,["8"]=4,["7"]=4,["6"]=4,["5"]=4,["4"]=4,["3"]=4}
AI_SLOT_NAMES ={"AI甲","AI乙","AI丙"}
AI_SLOT_KEYS={["AI甲"]="ai-a",["AI乙"]="ai-b",["AI丙"]="ai-c"}
READY_TIMEOUT =30*60  -- 30秒未准备则踢出
TURN_TIMEOUT =30*60  -- 30秒未出牌/叫分则自动跳过

DDZ_CARD_W = 120
DDZ_CARD_H = 168
DDZ_CARD_OVERLAP = 100
DDZ_CARD_OVERLAP_MAX = 120
DDZ_CARD_SELECT_OFFSET = 40

function DDZ_L(key,...)
    local t={"ddz."..key}
    for i=1,select("#",...) do t[#t+1]=select(i,...) end
    return t
end

function DDZ_S(...)
    local t={""}
    for i=1,select("#",...) do t[#t+1]=select(i,...) end
    return t
end

function type_name_loc(tp)
    return DDZ_L(TYPE_KEYS[tp] or "type-card")
end

function card_value_loc(v)
    if v=="大王" then return DDZ_L("card-big-joker") end
    if v=="小王" then return DDZ_L("card-small-joker") end
    return v
end

function ai_name_loc(name)
    return DDZ_L(AI_SLOT_KEYS[name] or "ai-generic", name or "AI")
end

function ddz_message(key,...)
    return {key=key,args={...}}
end

function ddz_message_caption(msg)
    if type(msg)=="table" and msg.key then
        return DDZ_L(msg.key, unpack(msg.args or {}))
    end
    return msg
end
