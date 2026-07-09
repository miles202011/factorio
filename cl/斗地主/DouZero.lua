-- DouZero-inspired AI decision layer.
--
-- This file is loaded after ddz_ai.lua and replaces the public decision
-- functions while keeping the original timeout/trustee execution pipeline.

local DZ_COMBO_CAP = 600
local DZ_SEARCH_HAND_LIMIT = 9
local DZ_SEARCH_WIDTH = 8
local DZ_SEARCH_DEPTH = 3

local DZ_WEIGHTS = {
    teammate_single_lead = 260,
    teammate_pair_lead = 235,
    teammate_mismatch_single = -170,
    teammate_mismatch_pair = -120,
    teammate_low_rank_bonus = 90,
    teammate_landlord_critical_penalty = -260,
    landlord_critical = 850,
    landlord_single_intercept = 520,
    landlord_pair_intercept = 420,
    critical_safe_control = 360,
    bomb_penalty = -760,
    bomb_critical_penalty = -80,
    ordinary_intercept_bomb_penalty = -520,
    only_bomb_intercept_bonus = 260,
    active_farmer_bomb_penalty = -900
}

local function copy_list(cards)
    local out = {}
    for i, c in ipairs(cards or {}) do out[i] = c end
    return out
end

local function group_by_rank(cards)
    local byr = {}
    for _, c in ipairs(cards or {}) do
        if not byr[c.rank] then byr[c.rank] = {} end
        byr[c.rank][#byr[c.rank] + 1] = c
    end
    return byr
end

local function append_cards(out, cards)
    for _, c in ipairs(cards or {}) do out[#out + 1] = c end
end

local function unit_cards(unit)
    return unit and (unit.cards or unit) or {}
end

local function make_unit(cards, cost)
    return { cards = cards, cost = cost or 0 }
end

local function kicker_base_cost(rank, size)
    local high_penalty = rank >= 15 and 120 or 0
    return rank * (size == 2 and 4 or 3) + high_penalty
end

local function single_kicker_cost(rank, group_size)
    if group_size == 1 then return kicker_base_cost(rank, 1) end
    if group_size == 3 then return 70 + kicker_base_cost(rank, 1) end
    if group_size == 2 then return 110 + kicker_base_cost(rank, 1) end
    return 9999
end

local function pair_kicker_cost(rank, group_size)
    if group_size == 2 then return kicker_base_cost(rank, 2) end
    if group_size == 3 then return 95 + kicker_base_cost(rank, 2) end
    return 9999
end

local function sort_units(units)
    table.sort(units, function(a, b)
        if (a.cost or 0) ~= (b.cost or 0) then return (a.cost or 0) < (b.cost or 0) end
        local ac = unit_cards(a)[1]
        local bc = unit_cards(b)[1]
        return (ac and ac.rank or 0) < (bc and bc.rank or 0)
    end)
end

local function rank_cards(byr, rank, count, start)
    local out = {}
    local group = byr[rank] or {}
    start = start or 1
    for i = start, math.min(#group, start + count - 1) do out[#out + 1] = group[i] end
    return out
end

local function card_sig(c)
    return tostring(c.rank) .. ":" .. tostring(c.suit or "") .. ":" .. tostring(c.val or "")
end

local function candidate_sig(cards)
    local parts = {}
    for _, c in ipairs(cards or {}) do parts[#parts + 1] = card_sig(c) end
    table.sort(parts)
    return table.concat(parts, "|")
end

local function add_candidate(candidates, seen, cards, last)
    local pt = get_type(cards or {})
    if not pt then return end
    if last and not can_beat(last, pt) then return end
    local sig = candidate_sig(cards)
    if seen[sig] then return end
    seen[sig] = true
    candidates[#candidates + 1] = { cards = order_play_cards(cards, pt), pt = pt }
end

local function append_combinations(out, units, need, cap)
    cap = cap or DZ_COMBO_CAP
    sort_units(units)
    if need == 0 then
        out[#out + 1] = {}
        return
    end
    local cur = {}
    local entries = {}
    local function walk(start, left)
        if left == 0 then
            local cards = {}
            local cost = 0
            for _, unit in ipairs(cur) do
                append_cards(cards, unit_cards(unit))
                cost = cost + (unit.cost or 0)
            end
            entries[#entries + 1] = { cards = cards, cost = cost }
            return
        end
        local max_i = #units - left + 1
        for i = start, max_i do
            cur[#cur + 1] = units[i]
            walk(i + 1, left - 1)
            cur[#cur] = nil
        end
    end
    walk(1, need)
    table.sort(entries, function(a, b)
        if a.cost ~= b.cost then return a.cost < b.cost end
        return #a.cards < #b.cards
    end)
    for i = 1, math.min(#entries, cap) do out[#out + 1] = entries[i].cards end
end

local function available_single_units(byr, ranks, used_count)
    local units = {}
    for _, r in ipairs(ranks) do
        local group = byr[r] or {}
        if #group ~= 4 then
            local start = (used_count and used_count[r] or 0) + 1
            for i = start, #group do
                units[#units + 1] = make_unit({ group[i] }, single_kicker_cost(r, #group))
            end
        end
    end
    return units
end

local function available_pair_units(byr, ranks, used_count)
    local units = {}
    for _, r in ipairs(ranks) do
        local group = byr[r] or {}
        if #group ~= 4 then
            local start = (used_count and used_count[r] or 0) + 1
            if #group - start + 1 >= 2 then
                units[#units + 1] = make_unit({ group[start], group[start + 1] }, pair_kicker_cost(r, #group))
            end
        end
    end
    return units
end

local function add_run_candidates(candidates, seen, byr, ranks, min_len, repeat_count, last)
    local usable = {}
    for _, r in ipairs(ranks) do
        if r < 15 and #(byr[r] or {}) >= repeat_count and #(byr[r] or {}) ~= 4 then
            usable[#usable + 1] = r
        end
    end
    for i = 1, #usable do
        local run = { usable[i] }
        local j = i + 1
        while j <= #usable and usable[j] == run[#run] + 1 do
            run[#run + 1] = usable[j]
            j = j + 1
        end
        if #run >= min_len then
            for len = min_len, #run do
                for s = 1, #run - len + 1 do
                    local cards = {}
                    for k = s, s + len - 1 do append_cards(cards, rank_cards(byr, run[k], repeat_count)) end
                    add_candidate(candidates, seen, cards, last)
                end
            end
        end
    end
end

local function add_plane_candidates(candidates, seen, byr, ranks, last)
    local triples = {}
    for _, r in ipairs(ranks) do
        if r < 15 and #(byr[r] or {}) == 3 then triples[#triples + 1] = r end
    end
    for i = 1, #triples do
        local run = { triples[i] }
        local j = i + 1
        while j <= #triples and triples[j] == run[#run] + 1 do
            run[#run + 1] = triples[j]
            j = j + 1
        end
        for len = 2, #run do
            for s = 1, #run - len + 1 do
                local body = {}
                local used = {}
                for k = s, s + len - 1 do
                    local r = run[k]
                    used[r] = 3
                    append_cards(body, rank_cards(byr, r, 3))
                end
                add_candidate(candidates, seen, body, last)

                local single_sets = {}
                append_combinations(single_sets, available_single_units(byr, ranks, used), len)
                for _, wings in ipairs(single_sets) do
                    local cards = copy_list(body)
                    append_cards(cards, wings)
                    add_candidate(candidates, seen, cards, last)
                end

                local pair_sets = {}
                append_combinations(pair_sets, available_pair_units(byr, ranks, used), len)
                for _, wings in ipairs(pair_sets) do
                    local cards = copy_list(body)
                    append_cards(cards, wings)
                    add_candidate(candidates, seen, cards, last)
                end
            end
        end
    end
end

local function collect_douzero_candidates(hand, last)
    local cards = copy_list(hand or {})
    sort_hand(cards)
    local byr = group_by_rank(cards)
    local ranks = sorted_keys(byr)
    local candidates = {}
    local seen = {}

    -- Basic moves. Bomb ranks are not split into smaller moves.
    for _, r in ipairs(ranks) do if #(byr[r] or {}) ~= 4 then add_candidate(candidates, seen, rank_cards(byr, r, 1), last) end end
    for _, r in ipairs(ranks) do if #(byr[r] or {}) >= 2 and #(byr[r] or {}) ~= 4 then add_candidate(candidates, seen, rank_cards(byr, r, 2), last) end end
    for _, r in ipairs(ranks) do if #(byr[r] or {}) == 3 then add_candidate(candidates, seen, rank_cards(byr, r, 3), last) end end

    -- Triples with kickers.
    for _, r in ipairs(ranks) do
        if #(byr[r] or {}) == 3 then
            local body = rank_cards(byr, r, 3)
            local used = { [r] = 3 }
            local single_sets = {}
            append_combinations(single_sets, available_single_units(byr, ranks, used), 1)
            for _, wings in ipairs(single_sets) do
                local move = copy_list(body)
                append_cards(move, wings)
                add_candidate(candidates, seen, move, last)
            end
            local pair_sets = {}
            append_combinations(pair_sets, available_pair_units(byr, ranks, used), 1)
            for _, wings in ipairs(pair_sets) do
                local move = copy_list(body)
                append_cards(move, wings)
                add_candidate(candidates, seen, move, last)
            end
        end
    end

    add_run_candidates(candidates, seen, byr, ranks, 5, 1, last)
    add_run_candidates(candidates, seen, byr, ranks, 3, 2, last)
    add_plane_candidates(candidates, seen, byr, ranks, last)

    -- Four with two singles / two pairs. The four cards are used as a whole body.
    for _, r in ipairs(ranks) do
        if #(byr[r] or {}) >= 4 then
            local body = rank_cards(byr, r, 4)
            local used = { [r] = 4 }
            local single_sets = {}
            append_combinations(single_sets, available_single_units(byr, ranks, used), 2)
            for _, wings in ipairs(single_sets) do
                local move = copy_list(body)
                append_cards(move, wings)
                add_candidate(candidates, seen, move, last)
            end
            local pair_sets = {}
            append_combinations(pair_sets, available_pair_units(byr, ranks, used), 2)
            for _, wings in ipairs(pair_sets) do
                local move = copy_list(body)
                append_cards(move, wings)
                add_candidate(candidates, seen, move, last)
            end
            add_candidate(candidates, seen, body, last)
        end
    end

    if byr[16] and byr[17] then add_candidate(candidates, seen, { byr[16][1], byr[17][1] }, last) end
    return candidates
end

local function same_team(g, a, b)
    if not g or not a or not b or a == b then return false end
    return a ~= g.landlord and b ~= g.landlord
end

local function landlord_cards_left(g)
    if not g or not g.landlord or not g.hands then return 99 end
    return #(g.hands[g.landlord] or {})
end

local function teammate_cards_left(g, pid)
    if not g or not pid or pid == g.landlord or not g.order or not g.hands then return 99 end
    local best = 99
    for _, other in ipairs(g.order) do
        if other ~= pid and other ~= g.landlord then
            local n = #(g.hands[other] or {})
            if n < best then best = n end
        end
    end
    return best
end

local function remove_cards_from_hand(hand, play)
    local out = copy_list(hand or {})
    local used = {}
    for _, pc in ipairs(play or {}) do
        for i, hc in ipairs(out) do
            if not used[i] and hc.rank == pc.rank and hc.suit == pc.suit and hc.val == pc.val then
                used[i] = true
                break
            end
        end
    end
    local remain = {}
    for i, c in ipairs(out) do if not used[i] then remain[#remain + 1] = c end end
    return remain
end

local function longest_count_run(cnt, min_count)
    local best, cur, prev = 0, 0, nil
    for r = 3, 14 do
        if (cnt[r] or 0) >= min_count then
            if prev and r == prev + 1 then cur = cur + 1 else cur = 1 end
            if cur > best then best = cur end
            prev = r
        end
    end
    return best
end

local function estimate_hand_turns(cards)
    if #(cards or {}) == 0 then return 0 end
    if get_type(cards) then return 1 end
    local analysis = analyze_remaining_hand and analyze_remaining_hand(cards)
    if analysis then return analysis.turns end
    local cnt = rank_counts(cards)
    local turns = 0
    for _, r in ipairs(sorted_keys(cnt)) do
        turns = turns + 1
    end
    local seq = longest_count_run(cnt, 1)
    if seq >= 5 then turns = turns - math.min(seq - 4, 3) end
    local pseq = longest_count_run(cnt, 2)
    if pseq >= 3 then turns = turns - math.min(pseq - 2, 3) end
    local plane = longest_count_run(cnt, 3)
    if plane >= 2 then turns = turns - math.min(plane, 3) end
    if turns < 1 then turns = 1 end
    return turns
end

local function clone_counts(cnt)
    local out = {}
    for r, n in pairs(cnt or {}) do out[r] = n end
    return out
end

local function count_left(cnt)
    local n = 0
    for _, c in pairs(cnt or {}) do n = n + c end
    return n
end

local function find_best_run_in_counts(cnt, min_count, min_len)
    local best_start, best_len = nil, 0
    local cur_start, cur_len = nil, 0
    for r = 3, 14 do
        local n = cnt[r] or 0
        local usable = n >= min_count and n ~= 4
        if usable then
            if not cur_start then cur_start = r; cur_len = 1
            else cur_len = cur_len + 1 end
        else
            if cur_len >= min_len and cur_len > best_len then
                best_start = cur_start
                best_len = cur_len
            end
            cur_start, cur_len = nil, 0
        end
    end
    if cur_len >= min_len and cur_len > best_len then
        best_start = cur_start
        best_len = cur_len
    end
    return best_start, best_len
end

local function consume_run(cnt, start, len, count)
    for r = start, start + len - 1 do cnt[r] = (cnt[r] or 0) - count end
end

local function analyze_with_order(base_cnt, order)
    local cnt = clone_counts(base_cnt)
    local turns = 0
    local score = 0
    local singles = 0
    local low_singles = 0
    local high_controls = 0
    local pair_count = 0
    local triples = 0
    local bombs = 0

    if cnt[16] and cnt[16] > 0 and cnt[17] and cnt[17] > 0 then
        cnt[16] = cnt[16] - 1
        cnt[17] = cnt[17] - 1
        turns = turns + 1
        score = score + 520
        high_controls = high_controls + 2
    end

    for r = 3, 15 do
        if (cnt[r] or 0) == 4 then
            cnt[r] = 0
            turns = turns + 1
            bombs = bombs + 1
            score = score + 430 + r * 4
        end
    end

    for _, shape in ipairs(order) do
        local min_count = shape == "plane" and 3 or (shape == "pseq" and 2 or 1)
        local min_len = shape == "plane" and 2 or (shape == "pseq" and 3 or 5)
        while true do
            local start, len = find_best_run_in_counts(cnt, min_count, min_len)
            if not start then break end
            consume_run(cnt, start, len, min_count)
            turns = turns + 1
            if shape == "plane" then
                score = score + 270 + len * 120
            elseif shape == "pseq" then
                score = score + 210 + len * 85
            else
                score = score + 160 + len * 58
            end
        end
    end

    for r = 3, 17 do
        local n = cnt[r] or 0
        while n >= 3 do
            n = n - 3
            turns = turns + 1
            triples = triples + 1
            score = score + 145 + r * 3
        end
        while n >= 2 do
            n = n - 2
            turns = turns + 1
            pair_count = pair_count + 1
            score = score + 70 + r * 2
        end
        if n == 1 then
            turns = turns + 1
            singles = singles + 1
            if r >= 15 then
                high_controls = high_controls + 1
                score = score + 85 + r * 4
            else
                low_singles = low_singles + 1
                score = score - (34 - r) * 4
            end
        end
    end

    score = score - turns * 135
    score = score - math.max(0, low_singles - 2) * 90
    score = score - math.max(0, singles - 4) * 45
    score = score + high_controls * 70 + bombs * 120 + triples * 25 + pair_count * 12

    return {
        turns = math.max(turns, count_left(base_cnt) > 0 and 1 or 0),
        score = score,
        singles = singles,
        low_singles = low_singles,
        high_controls = high_controls,
        pairs = pair_count,
        triples = triples,
        bombs = bombs
    }
end

function analyze_remaining_hand(cards)
    if #(cards or {}) == 0 then
        return { turns = 0, score = 10000, singles = 0, low_singles = 0, high_controls = 0, pairs = 0, triples = 0, bombs = 0 }
    end
    if get_type(cards) then
        return { turns = 1, score = 1800 - #cards, singles = 0, low_singles = 0, high_controls = 0, pairs = 0, triples = 0, bombs = 0 }
    end

    local cnt = rank_counts(cards)
    local orders = {
        { "plane", "pseq", "seq" },
        { "plane", "seq", "pseq" },
        { "pseq", "plane", "seq" },
        { "seq", "plane", "pseq" }
    }
    local best = nil
    for _, order in ipairs(orders) do
        local a = analyze_with_order(cnt, order)
        if not best or a.score > best.score then best = a end
    end
    return best
end

local function hand_structure_score(cards)
    if #(cards or {}) == 0 then return 10000 end
    if get_type(cards) then return 1400 - #cards end

    local analysis = analyze_remaining_hand(cards)
    local cnt = rank_counts(cards)
    local score = 0
    local singles = 0
    for r, n in pairs(cnt) do
        if n == 4 then score = score + 260
        elseif n == 3 then score = score + 120
        elseif n == 2 then score = score + 50
        elseif n == 1 then
            singles = singles + 1
            score = score - (r >= 15 and 12 or 28)
        end
    end
    if cnt[16] and cnt[17] then score = score + 240 end
    local seq = longest_count_run(cnt, 1)
    if seq >= 5 then score = score + seq * 35 end
    local pseq = longest_count_run(cnt, 2)
    if pseq >= 3 then score = score + pseq * 45 end
    local plane = longest_count_run(cnt, 3)
    if plane >= 2 then score = score + plane * 80 end
    if analysis then
        score = score + analysis.score
        score = score - analysis.turns * 80
        score = score - analysis.low_singles * 55
        score = score + analysis.high_controls * 45
    end
    score = score - estimate_hand_turns(cards) * 95 - math.max(0, singles - 3) * 35
    return score
end

local function played_count_by_rank(g)
    local out = {}
    for val, n in pairs((g and g.played_cards) or {}) do
        local r = RANK[val]
        if r then out[r] = (out[r] or 0) + n end
    end
    return out
end

local function total_rank_count(rank)
    if rank == 16 or rank == 17 then return 1 end
    if rank >= 3 and rank <= 15 then return 4 end
    return 0
end

local function own_count_by_rank(cards)
    local out = {}
    for _, c in ipairs(cards or {}) do out[c.rank] = (out[c.rank] or 0) + 1 end
    return out
end

local function opponent_range_profile(g, hand)
    local played = played_count_by_rank(g)
    local own = own_count_by_rank(hand)
    local remain = {}
    local high_singles = 0
    local high_pairs = 0
    local high_triples = 0
    local possible_bombs = 0
    local possible_rocket = false

    for r = 3, 17 do
        local n = math.max(0, total_rank_count(r) - (played[r] or 0) - (own[r] or 0))
        remain[r] = n
        if r >= 14 then
            if n >= 1 then high_singles = high_singles + n end
            if n >= 2 then high_pairs = high_pairs + 1 end
            if n >= 3 then high_triples = high_triples + 1 end
        end
        if n == 4 then possible_bombs = possible_bombs + 1 end
    end

    possible_rocket = (remain[16] or 0) > 0 and (remain[17] or 0) > 0

    return {
        remain = remain,
        high_singles = high_singles,
        high_pairs = high_pairs,
        high_triples = high_triples,
        possible_bombs = possible_bombs,
        possible_rocket = possible_rocket
    }
end

local function unseen_higher_count(g, hand, rank)
    local profile = opponent_range_profile(g, hand)
    local n = 0
    for r = rank + 1, 17 do
        n = n + (profile.remain[r] or 0)
    end
    return n
end

local function unseen_higher_group_count(g, hand, rank, need)
    local profile = opponent_range_profile(g, hand)
    local n = 0
    for r = rank + 1, 17 do
        if (profile.remain[r] or 0) >= need then
            n = n + 1
        end
    end
    return n
end

local function is_safe_control(g, hand, pt, profile)
    if not pt then return false end
    profile = profile or opponent_range_profile(g, hand)
    if pt.tp == "rocket" then return true end
    if pt.tp == "single" then
        for r = (pt.key or 0) + 1, 17 do if (profile.remain[r] or 0) >= 1 then return false end end
        return true
    end
    if pt.tp == "pair" then
        for r = (pt.key or 0) + 1, 17 do if (profile.remain[r] or 0) >= 2 then return false end end
        return true
    end
    if pt.tp == "triple" then
        for r = (pt.key or 0) + 1, 17 do if (profile.remain[r] or 0) >= 3 then return false end end
        return true
    end
    if pt.tp == "bomb" then
        for r = (pt.key or 0) + 1, 15 do if (profile.remain[r] or 0) >= 4 then return false end end
        return not profile.possible_rocket
    end
    return false
end

local function can_finish_within(cards, max_plays)
    if #(cards or {}) == 0 then return true end
    if max_plays <= 0 then return false end
    if get_type(cards) then return true end
    if max_plays == 1 then return false end
    if #cards > 10 then return false end

    local candidates = collect_douzero_candidates(cards, nil)
    for _, c in ipairs(candidates) do
        local remain = remove_cards_from_hand(cards, c.cards)
        if #remain < #cards and can_finish_within(remain, max_plays - 1) then return true end
    end
    return false
end

local function move_shape_bonus(pt, free_lead)
    if pt.tp == "single" then return free_lead and 55 or 0 end
    if pt.tp == "pair" then return free_lead and 65 or 5 end
    if pt.tp == "triple" then return free_lead and 70 or 10 end
    if pt.tp == "t1" or pt.tp == "t2" then return 85 end
    if pt.tp == "seq" or pt.tp == "pseq" then return free_lead and 160 or 45 end
    if pt.tp == "plane" or pt.tp == "plane1" or pt.tp == "plane2" then return free_lead and 220 or 80 end
    if pt.tp == "s41" or pt.tp == "s42" then return 75 end
    return 0
end

local function teammate_lead_bonus(pt, teammate_left, landlord_left)
    if teammate_left == 1 then
        if pt.tp == "single" then
            return DZ_WEIGHTS.teammate_single_lead + math.max(0, 15 - (pt.key or 0)) * DZ_WEIGHTS.teammate_low_rank_bonus / 12
        end
        return DZ_WEIGHTS.teammate_mismatch_single
    end
    if teammate_left == 2 then
        if pt.tp == "pair" then
            return DZ_WEIGHTS.teammate_pair_lead + math.max(0, 15 - (pt.key or 0)) * DZ_WEIGHTS.teammate_low_rank_bonus / 12
        end
        return DZ_WEIGHTS.teammate_mismatch_pair
    end
    if landlord_left <= 2 then return DZ_WEIGHTS.teammate_landlord_critical_penalty end
    return 0
end

local function quick_search_score(g, hand, candidate, profile)
    local pt = candidate.pt
    local remain = remove_cards_from_hand(hand, candidate.cards)
    local score = (pt.n or #(candidate.cards or {})) * 35 - (pt.key or 0) * 3
    score = score + hand_structure_score(remain)
    score = score - estimate_hand_turns(remain) * 120
    if get_type(remain) then score = score + 700 end
    if is_safe_control(g, hand, pt, profile) then score = score + 280 end
    if pt.tp == "bomb" or pt.tp == "rocket" then score = score - 650 end
    return score
end

local function top_search_candidates(g, hand, profile)
    local candidates = collect_douzero_candidates(hand or {}, nil)
    table.sort(candidates, function(a, b)
        return quick_search_score(g, hand, a, profile) > quick_search_score(g, hand, b, profile)
    end)
    local out = {}
    for i = 1, math.min(#candidates, DZ_SEARCH_WIDTH) do out[#out + 1] = candidates[i] end
    return out
end

local function search_finish_score(g, hand, depth, profile)
    if #(hand or {}) == 0 then return 1500 + depth * 120 end
    if get_type(hand or {}) then return 1200 + depth * 100 - #(hand or {}) end
    if depth <= 1 or #(hand or {}) > DZ_SEARCH_HAND_LIMIT then return nil end

    local best = nil
    for _, c in ipairs(top_search_candidates(g, hand, profile)) do
        local remain = remove_cards_from_hand(hand, c.cards)
        if #remain < #(hand or {}) then
            local next_score = search_finish_score(g, remain, depth - 1, profile)
            if next_score then
                local score = next_score + quick_search_score(g, hand, c, profile) * 0.18
                if not best or score > best then best = score end
            end
        end
    end
    return best
end

local function endgame_search_bonus(g, hand, candidate, remain, profile, safe_control)
    if #(hand or {}) > DZ_SEARCH_HAND_LIMIT then return 0 end
    if #(remain or {}) == 0 then return 0 end

    local best = search_finish_score(g, remain, DZ_SEARCH_DEPTH - 1, profile)
    if not best then return 0 end

    local bonus = 360 + best * 0.28
    if safe_control then bonus = bonus + 280 end

    local pt = candidate.pt
    if not safe_control then
        if pt.tp == "single" and profile.high_singles >= 3 then bonus = bonus - 180 end
        if pt.tp == "pair" and profile.high_pairs >= 2 then bonus = bonus - 150 end
        if profile.possible_rocket or profile.possible_bombs > 0 then bonus = bonus - 120 end
    end
    return bonus
end

local function score_candidate(g, pid, candidate, last, hand, context)
    context = context or {}
    local profile = context.profile or opponent_range_profile(g, hand)
    local pt = candidate.pt
    local n = pt.n or #(candidate.cards or {})
    local hand_count = #(hand or {})
    local remain = remove_cards_from_hand(hand, candidate.cards)
    local remain_analysis = analyze_remaining_hand(remain)
    local score = 0

    if n == hand_count then return 100000 + n * 100 - (pt.key or 0) end
    if get_type(remain) then score = score + 1800 end
    if remain_analysis and remain_analysis.turns == 2 then score = score + 520 end
    if hand_count <= 8 and can_finish_within(remain, 2) then score = score + 900 end

    score = score + n * 45 - (pt.key or 0) * 4
    score = score + hand_structure_score(remain)
    score = score - estimate_hand_turns(remain) * 130
    score = score + move_shape_bonus(pt, not last)

    local safe_control = is_safe_control(g, hand, pt, profile)
    if safe_control then score = score + (hand_count <= 8 and 520 or 230) end
    score = score + endgame_search_bonus(g, hand, candidate, remain, profile, safe_control)

    if pt.tp == "single" and not safe_control and profile.high_singles >= 4 then score = score - 130 end
    if pt.tp == "pair" and not safe_control and profile.high_pairs >= 2 then score = score - 110 end
    if pt.tp == "triple" and not safe_control and profile.high_triples >= 1 then score = score - 90 end

    local landlord_left = landlord_cards_left(g)
    local teammate_left = teammate_cards_left(g, pid)
    local critical = landlord_left <= 2

    if last then
        score = score + 700
        if same_team(g, pid, last.by) then score = score - 20000 end
        if g and last.by == g.landlord then
            score = score + 260
            if critical then score = score + DZ_WEIGHTS.landlord_critical end
            if landlord_left == 1 and pt.tp == "single" then score = score + DZ_WEIGHTS.landlord_single_intercept end
            if landlord_left == 2 and pt.tp == "pair" then score = score + DZ_WEIGHTS.landlord_pair_intercept end
            if critical and safe_control then score = score + DZ_WEIGHTS.critical_safe_control end
        end
        if pt.tp == "bomb" or pt.tp == "rocket" then
            score = score + (critical and DZ_WEIGHTS.bomb_critical_penalty or DZ_WEIGHTS.bomb_penalty)
            if context.ordinary_intercept_available then
                score = score + DZ_WEIGHTS.ordinary_intercept_bomb_penalty
            elseif critical and g and last.by == g.landlord then
                score = score + DZ_WEIGHTS.only_bomb_intercept_bonus
            end
            if profile.possible_rocket or profile.possible_bombs > 0 then score = score - 160 end
        end
    else
        if g and pid == g.landlord then
            score = score + 120 - estimate_hand_turns(remain) * 45
        else
            score = score + teammate_lead_bonus(pt, teammate_left, landlord_left)
            if remain_analysis then
                score = score + remain_analysis.high_controls * 60 + remain_analysis.bombs * 120
            end
            if profile.high_singles >= 4 and pt.tp == "single" and not safe_control then score = score - 120 end
            if profile.possible_bombs == 0 and not profile.possible_rocket and remain_analysis and remain_analysis.bombs > 0 then
                score = score + 100
            end
            if pt.tp == "bomb" or pt.tp == "rocket" then score = score + DZ_WEIGHTS.active_farmer_bomb_penalty end
        end
    end

    if (pt.tp == "single" or pt.tp == "pair" or pt.tp == "triple") and is_safe_control(g, hand, pt, profile) then
        score = score + 220
    end

    return score
end

local function control_power_score(cnt)
    local score = 0
    if cnt[16] and cnt[17] then score = score + 18 end
    score = score + (cnt[17] or 0) * 10
    score = score + (cnt[16] or 0) * 9
    score = score + (cnt[15] or 0) * 5
    score = score + (cnt[14] or 0) * 3
    score = score + (cnt[13] or 0) * 1
    return score
end

local function low_single_count(cnt)
    local n = 0
    for r = 3, 12 do
        if (cnt[r] or 0) == 1 then n = n + 1 end
    end
    return n
end

local function landlord_potential_score(hand)
    hand = hand or {}
    local cnt = rank_counts(hand or {})
    local score = 0
    local analysis = analyze_remaining_hand(hand)
    local turns = estimate_hand_turns(hand)
    local control_score = control_power_score(cnt)
    local bombs = 0
    local triples = 0
    local pair_count = 0
    local low_singles = low_single_count(cnt)

    for _, n in pairs(cnt) do
        if n == 4 then bombs = bombs + 1
        elseif n == 3 then triples = triples + 1
        elseif n == 2 then pair_count = pair_count + 1 end
    end

    score = score + control_score
    score = score + bombs * 14
    score = score + triples * 5
    score = score + pair_count * 2

    local seq = longest_count_run(cnt, 1)
    if seq >= 5 then score = score + (seq - 4) * 3 end
    local pseq = longest_count_run(cnt, 2)
    if pseq >= 3 then score = score + (pseq - 2) * 3 end
    local plane = longest_count_run(cnt, 3)
    if plane >= 2 then score = score + plane * 5 end

    if analysis then
        score = score + math.floor(analysis.score / 180)
        score = score + analysis.high_controls * 3
        score = score + analysis.bombs * 8
        score = score - analysis.low_singles * 2
    end

    score = score - turns * 3
    score = score - math.max(0, low_singles - 4) * 4
    if control_score < 12 and low_singles >= 5 then score = score - 8 end
    if control_score < 8 and bombs == 0 then score = score - 6 end
    if bombs > 0 and ((cnt[15] or 0) > 0 or cnt[16] or cnt[17]) then score = score + 5 end

    return score
end

local function douzero_bid_score(hand)
    return landlord_potential_score(hand)
end

function ai_choose_bid(hand, current_bid)
    local score = douzero_bid_score(hand or {})
    local desired = 0
    if score >= 42 then desired = 3
    elseif score >= 30 then desired = 2
    elseif score >= 18 then desired = 1 end
    current_bid = current_bid or 0
    if current_bid >= 2 and score < 45 then return 0 end
    if current_bid >= 1 and score < 32 then return 0 end
    if desired > current_bid then return desired end
    return 0
end

function ai_choose_cards_for(g, pid, hand, last)
    local candidates = collect_douzero_candidates(hand or {}, last)
    local best, best_score = nil, nil
    local context = { profile = opponent_range_profile(g, hand or {}) }
    if last and g and last.by == g.landlord and landlord_cards_left(g) <= 2 then
        for _, c in ipairs(candidates) do
            if c.pt and c.pt.tp ~= "bomb" and c.pt.tp ~= "rocket" then
                context.ordinary_intercept_available = true
                break
            end
        end
    end
    for _, c in ipairs(candidates) do
        if not (last and same_team(g, pid, last.by) and #(c.cards or {}) ~= #(hand or {})) then
            local score = score_candidate(g, pid, c, last, hand or {}, context)
            if not best_score or score > best_score then
                best = c
                best_score = score
            end
        end
    end
    return best and best.cards or nil
end

function ai_choose_cards(hand, last)
    return ai_choose_cards_for(nil, nil, hand, last)
end
