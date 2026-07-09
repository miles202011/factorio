require('__base__/script/freeplay/control.lua')

local handler = require('event_handler')

local GUI = {
    top_button = 'custom_achievements_top_button',
    frame = 'custom_achievements_frame',
    scroll = 'custom_achievements_scroll',
    close = 'custom_achievements_close',
    reset = 'custom_achievements_reset',
    test = 'custom_achievements_test',
    alert_root = 'custom_achievements_alert_root',
    alert_frame = 'custom_achievements_alert_frame',
    alert_bar = 'custom_achievements_alert_bar',
}

local DEFAULT_ICON = 'file/png/phibee.png'
local ACHIEVEMENT_SOUND = 'utility/achievement_unlocked'

local ACHIEVEMENTS = {
    {
        id = 'welcome',
        title = '初来乍到',
        description = '第一次进入这个场景。',
        icon = DEFAULT_ICON,
        hidden = false
    },
    {
        id = 'first_build',
        title = '第一块基石',
        description = '亲手建造第一个实体。',
        icon = DEFAULT_ICON,
        hidden = false
    },
    {
        id = 'first_mine',
        title = '开山第一镐',
        description = '第一次完成手动采矿。',
        icon = DEFAULT_ICON,
        hidden = false
    },
    {
        id = 'first_kill',
        title = '虫群猎手',
        description = '第一次击杀敌对单位。',
        icon = DEFAULT_ICON,
        hidden = false
    },
    {
        id = 'first_death',
        title = '代价',
        description = '第一次死亡。活着回来就好。',
        icon = DEFAULT_ICON,
        hidden = false
    },
    {
        id = 'first_research',
        title = '科学开始运转',
        description = '完成第一项科技研究。',
        icon = DEFAULT_ICON,
        hidden = false
    },
    {
        id = 'manual_test',
        title = '测试成就',
        description = '通过 /ach_test 或面板按钮触发。',
        icon = DEFAULT_ICON,
        hidden = false
    }
}

local ACHIEVEMENT_BY_ID = {}
for _, achievement in ipairs(ACHIEVEMENTS) do
    ACHIEVEMENT_BY_ID[achievement.id] = achievement
end

local function init_storage()
    storage.custom_achievements = storage.custom_achievements or {}
    storage.custom_achievements.players = storage.custom_achievements.players or {}
    storage.custom_achievements.alerts = storage.custom_achievements.alerts or {}
    storage.custom_achievements.next_alert_id = storage.custom_achievements.next_alert_id or 1
end

local function get_player_data(player)
    init_storage()
    local players = storage.custom_achievements.players
    players[player.index] = players[player.index] or {
        unlocked = {},
        unlocked_order = {}
    }
    players[player.index].unlocked = players[player.index].unlocked or {}
    players[player.index].unlocked_order = players[player.index].unlocked_order or {}
    return players[player.index]
end

local function is_unlocked(player, achievement_id)
    return get_player_data(player).unlocked[achievement_id] == true
end

local function safe_destroy(element)
    if element and element.valid then
        element.destroy()
    end
end

local function add_top_button(player)
    local top = player.gui.top
    if top[GUI.top_button] then
        return
    end

    local button = top.add({
        type = 'sprite-button',
        name = GUI.top_button,
        sprite = DEFAULT_ICON,
        tooltip = '自定义成就',
        style = 'slot_button'
    })
    button.style.size = 36
end

local function format_count(player)
    local data = get_player_data(player)
    local unlocked = 0
    for _, achievement in ipairs(ACHIEVEMENTS) do
        if data.unlocked[achievement.id] then
            unlocked = unlocked + 1
        end
    end
    return unlocked, #ACHIEVEMENTS
end

local function build_achievement_row(parent, player, achievement)
    local unlocked = is_unlocked(player, achievement.id)
    local row = parent.add({type = 'frame', direction = 'horizontal', style = 'inside_shallow_frame'})
    row.style.horizontally_stretchable = true
    row.style.bottom_margin = 4

    local icon = row.add({
        type = 'sprite-button',
        sprite = unlocked and achievement.icon or 'utility/questionmark',
        style = unlocked and 'slot_button' or 'red_slot_button',
        enabled = false
    })
    icon.style.size = 64

    local text_flow = row.add({type = 'flow', direction = 'vertical'})
    text_flow.style.horizontally_stretchable = true
    text_flow.style.left_margin = 8

    local title = text_flow.add({
        type = 'label',
        caption = unlocked and achievement.title or ('未解锁：' .. achievement.title)
    })
    title.style.font = 'default-bold'
    title.style.font_color = unlocked and {r = 1.0, g = 0.84, b = 0.25} or {r = 0.65, g = 0.65, b = 0.65}

    local description = text_flow.add({
        type = 'label',
        caption = unlocked and achievement.description or '达成条件后自动解锁。'
    })
    description.style.single_line = false
    description.style.font_color = {r = 0.86, g = 0.86, b = 0.86}
end

local function fill_achievement_list(scroll, player)
    scroll.clear()

    local unlocked, total = format_count(player)
    local summary = scroll.add({
        type = 'label',
        caption = '已解锁 ' .. unlocked .. ' / ' .. total
    })
    summary.style.font = 'heading-2'
    summary.style.font_color = {r = 1.0, g = 0.84, b = 0.25}
    summary.style.bottom_margin = 8

    for _, achievement in ipairs(ACHIEVEMENTS) do
        if not achievement.hidden or is_unlocked(player, achievement.id) then
            build_achievement_row(scroll, player, achievement)
        end
    end
end

local function find_child_by_name(parent, name)
    if not parent or not parent.valid then
        return nil
    end
    for _, child in pairs(parent.children) do
        if child.name == name then
            return child
        end
        local found = find_child_by_name(child, name)
        if found then
            return found
        end
    end
    return nil
end

local function rebuild_panel(player)
    local frame = player.gui.screen[GUI.frame]
    if not frame then
        return
    end

    local scroll = find_child_by_name(frame, GUI.scroll)
    if not scroll then
        return
    end

    fill_achievement_list(scroll, player)
end

local function toggle_panel(player)
    local screen = player.gui.screen
    if screen[GUI.frame] then
        screen[GUI.frame].destroy()
        return
    end

    local frame = screen.add({
        type = 'frame',
        name = GUI.frame,
        direction = 'vertical',
        caption = '自定义成就'
    })
    frame.auto_center = true
    frame.style.width = 520
    frame.style.minimal_height = 430
    frame.style.maximal_height = 650

    local header = frame.add({type = 'flow', direction = 'horizontal'})
    header.style.horizontally_stretchable = true

    local test = header.add({
        type = 'button',
        name = GUI.test,
        caption = '测试弹窗',
        tooltip = '解锁测试成就'
    })
    test.style.right_margin = 6

    local reset = header.add({
        type = 'button',
        name = GUI.reset,
        caption = '重置自己',
        tooltip = '仅管理员可用'
    })
    reset.style.right_margin = 6

    local spacer = header.add({type = 'empty-widget'})
    spacer.style.horizontally_stretchable = true

    header.add({
        type = 'sprite-button',
        name = GUI.close,
        sprite = 'utility/close',
        style = 'frame_action_button',
        tooltip = '关闭'
    })

    frame.add({
        type = 'line',
        direction = 'horizontal'
    })

    local scroll = frame.add({
        type = 'scroll-pane',
        name = GUI.scroll,
        direction = 'vertical'
    })
    scroll.style.horizontally_stretchable = true
    scroll.style.minimal_height = 340
    scroll.style.maximal_height = 560

    fill_achievement_list(scroll, player)
end

local function create_alert(player, achievement)
    init_storage()

    local root = player.gui.left.add({
        type = 'flow',
        direction = 'vertical'
    })

    local frame = root.add({
        type = 'frame',
        name = GUI.alert_frame,
        direction = 'vertical',
        style = 'frame'
    })
    frame.style.width = 360

    local content = frame.add({type = 'flow', direction = 'horizontal'})
    content.style.horizontally_stretchable = true

    local icon = content.add({
        type = 'sprite-button',
        sprite = achievement.icon or DEFAULT_ICON,
        style = 'slot_button',
        enabled = false
    })
    icon.style.size = 64

    local text_flow = content.add({type = 'flow', direction = 'vertical'})
    text_flow.style.left_margin = 8
    text_flow.style.horizontally_stretchable = true

    local title = text_flow.add({
        type = 'label',
        caption = '成就达成：' .. achievement.title
    })
    title.style.font = 'default-large-bold'
    title.style.font_color = {r = 1.0, g = 0.84, b = 0.25}

    local description = text_flow.add({
        type = 'label',
        caption = achievement.description
    })
    description.style.single_line = false
    description.style.font_color = {r = 0.92, g = 0.92, b = 0.92}

    local bar = frame.add({
        type = 'progressbar',
        name = GUI.alert_bar,
        value = 1
    })
    bar.style.height = 5
    bar.style.horizontally_stretchable = true
    bar.style.color = {r = 1.0, g = 0.6, b = 0.12}

    local id = storage.custom_achievements.next_alert_id
    storage.custom_achievements.next_alert_id = id + 1
    storage.custom_achievements.alerts[id] = {
        player_index = player.index,
        root = root,
        bar = bar,
        start_tick = game.tick,
        end_tick = game.tick + 8 * 60
    }

    player.play_sound({path = ACHIEVEMENT_SOUND, volume_modifier = 0.65})
end

local function unlock_achievement(player, achievement_id)
    if not player or not player.valid then
        return false
    end

    local achievement = ACHIEVEMENT_BY_ID[achievement_id]
    if not achievement then
        player.print('未知自定义成就：' .. tostring(achievement_id), {r = 1, g = 0.2, b = 0.2})
        return false
    end

    local data = get_player_data(player)
    if data.unlocked[achievement_id] then
        return false
    end

    data.unlocked[achievement_id] = true
    data.unlocked_order[#data.unlocked_order + 1] = {
        id = achievement_id,
        tick = game.tick
    }

    create_alert(player, achievement)
    rebuild_panel(player)
    return true
end

local function reset_player(player)
    init_storage()
    storage.custom_achievements.players[player.index] = {
        unlocked = {},
        unlocked_order = {}
    }
    rebuild_panel(player)
end

local function list_achievements(player)
    local unlocked, total = format_count(player)
    player.print('自定义成就：已解锁 ' .. unlocked .. ' / ' .. total, {r = 1, g = 0.84, b = 0.25})
    for _, achievement in ipairs(ACHIEVEMENTS) do
        local mark = is_unlocked(player, achievement.id) and '[√] ' or '[ ] '
        player.print(mark .. achievement.title .. ' - ' .. achievement.description)
    end
end

local function update_alerts()
    init_storage()
    local alerts = storage.custom_achievements.alerts
    for id, data in pairs(alerts) do
        if not data.root or not data.root.valid then
            alerts[id] = nil
        elseif game.tick >= data.end_tick then
            safe_destroy(data.root)
            alerts[id] = nil
        elseif data.bar and data.bar.valid then
            local total = data.end_tick - data.start_tick
            local left = data.end_tick - game.tick
            data.bar.value = math.max(0, math.min(1, left / total))
        end
    end
end

commands.add_command('ach_test', '弹出一个自定义成就测试。', function(command)
    local player = game.get_player(command.player_index)
    if player then
        unlock_achievement(player, 'manual_test')
    end
end)

commands.add_command('ach_list', '查看自己的自定义成就。', function(command)
    local player = game.get_player(command.player_index)
    if player then
        list_achievements(player)
    end
end)

commands.add_command('ach_reset', '管理员：重置自己的自定义成就。', function(command)
    local player = game.get_player(command.player_index)
    if not player then
        return
    end
    if not player.admin then
        player.print('只有管理员可以重置自定义成就。', {r = 1, g = 0.2, b = 0.2})
        return
    end
    reset_player(player)
    player.print('自定义成就记录已重置。', {r = 0.4, g = 1.0, b = 0.4})
end)

handler.add_lib({
    on_init = function()
        init_storage()
    end,
    on_configuration_changed = function()
        init_storage()
    end,
    events = {
        [defines.events.on_player_created] = function(event)
            local player = game.get_player(event.player_index)
            if player then
                add_top_button(player)
            end
        end,
        [defines.events.on_player_joined_game] = function(event)
            local player = game.get_player(event.player_index)
            if player then
                add_top_button(player)
                unlock_achievement(player, 'welcome')
            end
        end,
        [defines.events.on_built_entity] = function(event)
            local player = game.get_player(event.player_index)
            if player then
                unlock_achievement(player, 'first_build')
            end
        end,
        [defines.events.on_player_mined_entity] = function(event)
            local player = game.get_player(event.player_index)
            if player then
                unlock_achievement(player, 'first_mine')
            end
        end,
        [defines.events.on_player_died] = function(event)
            local player = game.get_player(event.player_index)
            if player then
                unlock_achievement(player, 'first_death')
            end
        end,
        [defines.events.on_research_finished] = function(event)
            for _, player in pairs(event.research.force.connected_players) do
                unlock_achievement(player, 'first_research')
            end
        end,
        [defines.events.on_entity_died] = function(event)
            if not event.cause or not event.cause.valid then
                return
            end
            if event.entity.force.name ~= 'enemy' then
                return
            end

            local player
            if event.cause.type == 'character' and event.cause.player then
                player = event.cause.player
            elseif event.cause.last_user then
                player = event.cause.last_user
            end

            if player then
                unlock_achievement(player, 'first_kill')
            end
        end,
        [defines.events.on_gui_click] = function(event)
            local element = event.element
            if not element or not element.valid then
                return
            end

            local player = game.get_player(event.player_index)
            if not player then
                return
            end

            if element.name == GUI.top_button then
                toggle_panel(player)
            elseif element.name == GUI.close then
                safe_destroy(player.gui.screen[GUI.frame])
            elseif element.name == GUI.test then
                unlock_achievement(player, 'manual_test')
            elseif element.name == GUI.reset then
                if player.admin then
                    reset_player(player)
                    player.print('自定义成就记录已重置。', {r = 0.4, g = 1.0, b = 0.4})
                else
                    player.print('只有管理员可以重置自定义成就。', {r = 1, g = 0.2, b = 0.2})
                end
            end
        end,
        [defines.events.on_tick] = function(event)
            if event.tick % 5 == 0 then
                update_alerts()
            end
        end
    }
})

remote.add_interface('custom_achievements', {
    unlock = function(player_index, achievement_id)
        local player = game.get_player(player_index)
        if not player then
            return false
        end
        return unlock_achievement(player, achievement_id)
    end,
    reset_player = function(player_index)
        local player = game.get_player(player_index)
        if not player then
            return false
        end
        reset_player(player)
        return true
    end,
    list = function()
        return ACHIEVEMENTS
    end
})
