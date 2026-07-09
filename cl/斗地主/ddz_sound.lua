-- Sound presets and playback helpers.

DDZ_SOUND_TEST_GROUPS = {
    ddz={label_key="sound-group-recommended"},
    gui={label_key="sound-group-gui"},
    result={label_key="sound-group-result"},
    item={label_key="sound-group-item"},
    build={label_key="sound-group-build"},
    deconstruct={label_key="sound-group-deconstruct"},
    rotate={label_key="sound-group-rotate"},
    equipment={label_key="sound-group-equipment"},
    world={label_key="sound-group-world"},
    wire={label_key="sound-group-wire"},
    tile={label_key="sound-group-tile"},
}

DDZ_RECOMMENDED_SOUND_TESTS = {
    -- 斗地主当前映射的常用音效。
    {id="gui_click", key="gui_click", group="ddz", label_key="sound-test-click", volume=0.8},
    {id="inventory_click", key="inventory_click", group="ddz", label_key="sound-test-select", volume=0.8},
    {id="smart_pipette", key="smart_pipette", group="ddz", label_key="sound-test-hint", volume=0.75},
    {id="cannot_build", key="cannot_build", group="ddz", label_key="sound-test-no-hint", volume=0.7},
    {id="new_objective", key="new_objective", group="ddz", label_key="sound-test-turn", volume=0.7},
    {id="drop_item", key="drop_item", group="ddz", label_key="sound-test-play", volume=0.75},
    {id="list_box_click", key="list_box_click", group="ddz", label_key="sound-test-pass", volume=0.7},
    {id="confirm", key="confirm", group="ddz", label_key="sound-test-bid", volume=0.75},
    {id="item_spawned", key="item_spawned", group="ddz", label_key="sound-test-deal", volume=0.65},
    {id="research_completed", key="research_completed", group="ddz", label_key="sound-test-landlord", volume=0.75},
    {id="build_large", key="build_large", group="ddz", label_key="sound-test-bomb", volume=0.8},
    {id="build_huge", key="build_huge", group="ddz", label_key="sound-test-rocket", volume=0.8},
    {id="gui_switch", key="gui_switch", group="ddz", label_key="sound-test-trustee", volume=0.75},
    {id="alert_destroyed", key="alert_destroyed", group="ddz", label_key="sound-test-warning", volume=0.7},
    {id="game_won", key="game_won", group="ddz", label_key="sound-test-win", volume=0.8},
    {id="game_lost", key="game_lost", group="ddz", label_key="sound-test-loss", volume=0.8},
    {id="entity_settings_pasted", key="entity_settings_pasted", group="ddz", label_key="sound-test-export", volume=0.75},
}

DDZ_SOUND_TESTS = {
    -- utility-sounds 完整清单，按用途分类。
    {id="alert_destroyed", key="alert_destroyed", group="gui", label_key="sound-test-alert-destroyed", volume=0.7},
    {id="cannot_build", key="cannot_build", group="gui", label_key="sound-test-cannot-build", volume=0.7},
    {id="clear_cursor", key="clear_cursor", group="gui", label_key="sound-test-clear-cursor", volume=0.75},
    {id="confirm", key="confirm", group="gui", label_key="sound-test-confirm", volume=0.75},
    {id="console_message", key="console_message", group="gui", label_key="sound-test-console-message", volume=0.75},
    {id="gui_click", key="gui_click", group="gui", label_key="sound-test-gui-click", volume=0.8},
    {id="gui_switch", key="gui_switch", group="gui", label_key="sound-test-gui-switch", volume=0.75},
    {id="list_box_click", key="list_box_click", group="gui", label_key="sound-test-list-box-click", volume=0.7},
    {id="new_objective", key="new_objective", group="gui", label_key="sound-test-new-objective", volume=0.7},
    {id="scenario_message", key="scenario_message", group="gui", label_key="sound-test-scenario-message", volume=0.75},
    {id="smart_pipette", key="smart_pipette", group="gui", label_key="sound-test-smart-pipette", volume=0.75},
    {id="tutorial_notice", key="tutorial_notice", group="gui", label_key="sound-test-tutorial-notice", volume=0.75},
    {id="undo", key="undo", group="gui", label_key="sound-test-undo", volume=0.75},

    {id="drop_item", key="drop_item", group="item", label_key="sound-test-drop-item", volume=0.75},
    {id="entity_settings_copied", key="entity_settings_copied", group="item", label_key="sound-test-entity-settings-copied", volume=0.75},
    {id="entity_settings_pasted", key="entity_settings_pasted", group="item", label_key="sound-test-entity-settings-pasted", volume=0.75},
    {id="inventory_click", key="inventory_click", group="item", label_key="sound-test-inventory-click", volume=0.8},
    {id="inventory_move", key="inventory_move", group="item", label_key="sound-test-inventory-move", volume=0.75},
    {id="item_deleted", key="item_deleted", group="item", label_key="sound-test-item-deleted", volume=0.75},
    {id="item_spawned", key="item_spawned", group="item", label_key="sound-test-item-spawned", volume=0.65},
    {id="paste_activated", key="paste_activated", group="item", label_key="sound-test-paste-activated", volume=0.75},
    {id="picked_up_item", key="picked_up_item", group="item", label_key="sound-test-picked-up-item", volume=0.75},

    {id="achievement_unlocked", key="achievement_unlocked", group="result", label_key="sound-test-achievement-unlocked", volume=0.75},
    {id="crafting_finished", key="crafting_finished", group="result", label_key="sound-test-crafting-finished", volume=0.75},
    {id="game_lost", key="game_lost", group="result", label_key="sound-test-game-lost", volume=0.8},
    {id="game_won", key="game_won", group="result", label_key="sound-test-game-won", volume=0.8},
    {id="research_completed", key="research_completed", group="result", label_key="sound-test-research-completed", volume=0.75},

    {id="armor_insert", key="armor_insert", group="equipment", label_key="sound-test-armor-insert", volume=0.75},
    {id="armor_remove", key="armor_remove", group="equipment", label_key="sound-test-armor-remove", volume=0.75},
    {id="switch_gun", key="switch_gun", group="equipment", label_key="sound-test-switch-gun", volume=0.75},

    {id="axe_fighting", key="axe_fighting", group="world", label_key="sound-test-axe-fighting", volume=0.75},
    {id="axe_mining_ore", key="axe_mining_ore", group="world", label_key="sound-test-axe-mining-ore", volume=0.75},
    {id="axe_mining_stone", key="axe_mining_stone", group="world", label_key="sound-test-axe-mining-stone", volume=0.75},
    {id="default_driving_sound", key="default_driving_sound", group="world", label_key="sound-test-default-driving-sound", volume=0.55},
    {id="default_landing_steps", key="default_landing_steps", group="world", label_key="sound-test-default-landing-steps", volume=0.65},
    {id="default_manual_repair", key="default_manual_repair", group="world", label_key="sound-test-default-manual-repair", volume=0.65},
    {id="metal_walking_sound", key="metal_walking_sound", group="world", label_key="sound-test-metal-walking-sound", volume=0.6},
    {id="mining_wood", key="mining_wood", group="world", label_key="sound-test-mining-wood", volume=0.75},
    {id="rail_plan_start", key="rail_plan_start", group="world", label_key="sound-test-rail-plan-start", volume=0.75},
    {id="segment_dying_sound", key="segment_dying_sound", group="world", label_key="sound-test-segment-dying-sound", volume=0.7},

    {id="build_animated_huge", key="build_animated_huge", group="build", label_key="sound-test-build-animated-huge", volume=0.75},
    {id="build_animated_large", key="build_animated_large", group="build", label_key="sound-test-build-animated-large", volume=0.75},
    {id="build_animated_medium", key="build_animated_medium", group="build", label_key="sound-test-build-animated-medium", volume=0.75},
    {id="build_animated_small", key="build_animated_small", group="build", label_key="sound-test-build-animated-small", volume=0.75},
    {id="build_blueprint_huge", key="build_blueprint_huge", group="build", label_key="sound-test-build-blueprint-huge", volume=0.75},
    {id="build_blueprint_large", key="build_blueprint_large", group="build", label_key="sound-test-build-blueprint-large", volume=0.75},
    {id="build_blueprint_medium", key="build_blueprint_medium", group="build", label_key="sound-test-build-blueprint-medium", volume=0.75},
    {id="build_blueprint_small", key="build_blueprint_small", group="build", label_key="sound-test-build-blueprint-small", volume=0.75},
    {id="build_ghost_upgrade", key="build_ghost_upgrade", group="build", label_key="sound-test-build-ghost-upgrade", volume=0.75},
    {id="build_ghost_upgrade_cancel", key="build_ghost_upgrade_cancel", group="build", label_key="sound-test-build-ghost-upgrade-cancel", volume=0.75},
    {id="build_huge", key="build_huge", group="build", label_key="sound-test-build-huge", volume=0.8},
    {id="build_large", key="build_large", group="build", label_key="sound-test-build-large", volume=0.8},
    {id="build_medium", key="build_medium", group="build", label_key="sound-test-build-medium", volume=0.75},
    {id="build_small", key="build_small", group="build", label_key="sound-test-build-small", volume=0.75},

    {id="deconstruct_huge", key="deconstruct_huge", group="deconstruct", label_key="sound-test-deconstruct-huge", volume=0.75},
    {id="deconstruct_large", key="deconstruct_large", group="deconstruct", label_key="sound-test-deconstruct-large", volume=0.75},
    {id="deconstruct_medium", key="deconstruct_medium", group="deconstruct", label_key="sound-test-deconstruct-medium", volume=0.75},
    {id="deconstruct_robot", key="deconstruct_robot", group="deconstruct", label_key="sound-test-deconstruct-robot", volume=0.75},
    {id="deconstruct_small", key="deconstruct_small", group="deconstruct", label_key="sound-test-deconstruct-small", volume=0.75},

    {id="rotated_huge", key="rotated_huge", group="rotate", label_key="sound-test-rotated-huge", volume=0.75},
    {id="rotated_large", key="rotated_large", group="rotate", label_key="sound-test-rotated-large", volume=0.75},
    {id="rotated_medium", key="rotated_medium", group="rotate", label_key="sound-test-rotated-medium", volume=0.75},
    {id="rotated_small", key="rotated_small", group="rotate", label_key="sound-test-rotated-small", volume=0.75},

    {id="wire_connect_pole", key="wire_connect_pole", group="wire", label_key="sound-test-wire-connect-pole", volume=0.75},
    {id="wire_disconnect", key="wire_disconnect", group="wire", label_key="sound-test-wire-disconnect", volume=0.75},
    {id="wire_pickup", key="wire_pickup", group="wire", label_key="sound-test-wire-pickup", volume=0.75},

    -- 已确认的非 utility SoundPath。
    {id="tile_build_small_concrete", path="tile-build-small/concrete", group="tile", label_key="sound-test-tile-build-small-concrete", volume=0.75, surface=true},
}

local SOUND_BY_ID = {}
for _,item in ipairs(DDZ_SOUND_TESTS) do
    SOUND_BY_ID[item.id]=item
end

function ddz_sound_test_caption(item)
    if not item then return "" end
    if item.label_key then return DDZ_L(item.label_key) end
    return item.label or item.key or item.path or item.id
end

function ddz_sound_test_path(item)
    if not item then return "" end
    return item.path or ("utility/"..item.key)
end

function ddz_sound_test_group_caption(group)
    local cfg=DDZ_SOUND_TEST_GROUPS[group]
    if cfg and cfg.label_key then return DDZ_L(cfg.label_key) end
    return group or ""
end

function ddz_sound_enabled(player)
    if not (player and player.valid) then return false end
    local d=storage.ddz
    if not d then return true end
    if not d.sound_enabled then d.sound_enabled={} end
    local enabled=d.sound_enabled[player.index]
    return enabled ~= false
end

function ddz_set_sound_enabled(player, enabled)
    if not (player and player.valid) then return end
    local d=storage.ddz
    if not d then return end
    if not d.sound_enabled then d.sound_enabled={} end
    d.sound_enabled[player.index]=enabled ~= false
end

function ddz_toggle_sound(player)
    if not (player and player.valid) then return end
    ddz_set_sound_enabled(player, not ddz_sound_enabled(player))
end

function ddz_play_sound(player, key, volume)
    if not (player and player.valid) then return end
    if not ddz_sound_enabled(player) then return end
    if not key or key=="" then return end
    pcall(function()
        player.play_sound{
            path="utility/"..key,
            volume_modifier=volume or 0.8
        }
    end)
end

local function ddz_play_sound_path(player, path, volume, use_surface)
    if not (player and player.valid) then return end
    if not ddz_sound_enabled(player) then return end
    if not path or path=="" then return end
    pcall(function()
        if use_surface and player.surface then
            player.surface.play_sound{
                path=path,
                position=player.position,
                volume_modifier=volume or 0.8
            }
        else
            player.play_sound{
                path=path,
                volume_modifier=volume or 0.8
            }
        end
    end)
end

function ddz_play_test_sound(player, id)
    local item=SOUND_BY_ID[id]
    if not item then return false end
    if item.key then
        ddz_play_sound(player, item.key, item.volume)
    else
        ddz_play_sound_path(player, item.path, item.volume, item.surface)
    end
    return true
end

function ddz_play_table_sound(g, key, volume)
    if not g then return end
    for _,pid in ipairs(g.order or {}) do
        if not is_ai(pid) then
            local p=game.players[pid]
            if p and p.connected then ddz_play_sound(p,key,volume) end
        end
    end
    local d=storage.ddz
    if d and d.spectating then
        for pid,tid in pairs(d.spectating) do
            if tid==g.tid then
                local p=game.players[pid]
                if p and p.connected then ddz_play_sound(p,key,volume) end
            end
        end
    end
end

function ddz_play_turn_prompt(g)
    if not g then return end
    local pid=nil
    if g.phase=="bidding" and not g.bid_pending and not g.redeal_pending then
        pid=g.order[g.bid_turn]
    elseif g.phase=="playing" then
        pid=g.order[g.play_turn]
    end
    if pid and not is_ai(pid) then
        local p=game.players[pid]
        if p and p.connected then ddz_play_sound(p,"new_objective",0.7) end
    end
end

function ddz_play_card_action(g, pt)
    if pt and pt.tp=="rocket" then
        ddz_play_table_sound(g,"build_huge",0.8)
    elseif pt and pt.tp=="bomb" then
        ddz_play_table_sound(g,"build_large",0.8)
    else
        ddz_play_table_sound(g,"drop_item",0.65)
    end
end

function ddz_play_game_over(g, winner)
    if not (g and winner) then return end
    local winner_landlord=(winner==g.landlord)
    for _,pid in ipairs(g.order or {}) do
        if not is_ai(pid) then
            local p=game.players[pid]
            if p and p.connected then
                local same_side=(winner_landlord and pid==g.landlord) or ((not winner_landlord) and pid~=g.landlord)
                ddz_play_sound(p,same_side and "game_won" or "game_lost",0.8)
            end
        end
    end
    local d=storage.ddz
    if d and d.spectating then
        for pid,tid in pairs(d.spectating) do
            if tid==g.tid then
                local p=game.players[pid]
                if p and p.connected then ddz_play_sound(p,"research_completed",0.65) end
            end
        end
    end
end
