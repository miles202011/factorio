local Server = require 'utils.server'
local Session = require 'utils.datastore.session_data'
local Modifers = require 'player_modifiers'
local WPT = require 'maps.amap.table'

local mapkeeper = '[color=blue]Mapkeeper:[/color]'

local Public = {}
local function delete_all_platforms()
    local nauvis = game.surfaces["nauvis"]
    
    -- 遍历所有势力 (通常只需处理 player 势力，但为了保险遍历所有)
    for _, force in pairs(game.forces) do
        -- 检查该势力是否有平台
        if force.platforms then
            
            -- 【重要】先收集要删除的平台，不要一边遍历一边删除
            -- 直接在 pairs 循环里 destroy() 可能会导致迭代器失效或漏删
            local platforms_to_kill = {}
            for _, platform in pairs(force.platforms) do
                table.insert(platforms_to_kill, platform)
            end
            
            -- 开始执行删除
            for _, platform in pairs(platforms_to_kill) do
                if platform.valid then
                    local p_surface = platform.surface
                    
                    -- 1. 安全措施：把平台上的玩家传送走
                    if p_surface and p_surface.valid then
                        for _, player in pairs(game.connected_players) do
                            if player.surface == p_surface then
                                -- 传送到 Nauvis 或者其他安全的地方
                                player.teleport({0,0}, nauvis) 
                                player.print({'amap.forced_teleport_due_to_platform_reset'})
                            end
                        end
                    end
                    
                    -- 2. 彻底摧毁平台
                    -- 这会自动删除关联的 surface，不需要手动 delete_surface
                    platform.destroy()
                end
            end
        end
    end
end

local function cleanup_other_surfaces()
    local nauvis = game.surfaces["nauvis"]
    
    -- 1. 安全措施：先把所有在线玩家传送到 Nauvis
    -- 防止删除地表时玩家跌入虚空导致崩溃
    for _, player in pairs(game.connected_players) do
        if player.surface.name ~= "nauvis" then
            player.teleport({0,0}, nauvis)
        end
    end

    -- 2. 摧毁太空平台 (Space Age 特有)
    -- 遍历所有势力，查找并摧毁其拥有的平台
    for _, force in pairs(game.forces) do
        if force.platforms then -- 确保 API 存在
            -- 注意：在遍历过程中删除元素通常需要倒序或小心处理，
            -- 但 destroy() 通常是安全的，不过为了稳妥，我们收集后再删
            local platforms_to_kill = {}
            for _, platform in pairs(force.platforms) do
                table.insert(platforms_to_kill, platform)
            end
            
            for _, platform in pairs(platforms_to_kill) do
                if platform.valid then
                    platform.destroy() -- 这会连带删除平台对应的 surface
                end
            end
        end
    end

    -- 3. 删除其他所有地表 (Vulcanus, Fulgora, 自定义地表等)
    for name, surface in pairs(game.surfaces) do
        if name ~= "nauvis" and surface.valid then
            -- 注意：有些 Mod 创建的特殊地表可能受保护，但一般都可删除
            game.delete_surface(surface)
        end
    end
    
    -- 4. (可选) 重置星球发现状态
    -- 如果你想让玩家重新在星图中“发现”这些星球，可能需要重置相关数据
    -- 这通常由科技重置(reset_forces)自动处理，因为星球发现通常绑定在科技上
end
local function reset_forces(new_surface)
    local spawn = {
        x = game.forces.player.get_spawn_position(new_surface).x,
        y = game.forces.player.get_spawn_position(new_surface).y
    }
    for _, f in pairs(game.forces) do
        f.reset()
        f.reset_evolution()
        f.set_spawn_position(spawn, new_surface)
    end
end

local function teleport_players(surface)
    if not surface or not surface.valid then
        return
    end
    game.forces.player.set_spawn_position({0, 0}, surface)
    local spawn_position = game.forces.player.get_spawn_position(surface) or {0, 0}

    for _, player in pairs(game.connected_players) do
        local teleport_position = surface.find_non_colliding_position('character', spawn_position, 3, 0) or spawn_position
        player.teleport(teleport_position, surface)
    end
end
 
local function equip_players(player_starting_items, data)
    local offline_players = {}

    for _, player in pairs(game.players) do
        if player.connected then
            local saved_quickbar = {}
            for i = 1, 100 do
                local filter = player.get_quick_bar_slot(i)
                if filter then
                    saved_quickbar[i] = filter
                end
            end

            if player.character and player.character.valid then
                player.character.destroy()
            end

            if not player.character then
                player.set_controller({type = defines.controllers.god})
                player.create_character()
            end

            player.clear_items_inside()
            Modifers.update_player_modifiers(player)

            for item, amount in pairs(player_starting_items) do
                player.insert({name = item, count = amount})
            end

            for i, filter in pairs(saved_quickbar) do
                if filter and filter.valid then
                    player.set_quick_bar_slot(i, filter)
                end
            end
        else
            table.insert(offline_players, player.index)
        end
    end

    if #offline_players > 0 then
        for _, player_index in pairs(offline_players) do
            local player = game.players[player_index]
            if player then
                data.players[player.index] = nil
                Session.clear_player(player)
            end
        end
        game.remove_offline_players(offline_players)
    end
end
local function remove_all_chart_tags(surface)
    -- 地图标记是归属于"势力"的，所以我们需要遍历势力
    -- 通常只需要清理 player 势力，但为了保险遍历所有
    for _, force in pairs(game.forces) do
        -- 查找该势力在这个地表上的所有标记
        -- find_chart_tags 第二个参数不传则默认搜索整个地表
        local tags = force.find_chart_tags(surface)
        
        for _, tag in pairs(tags) do
            if tag.valid then
                tag.destroy()
            end
        end
    end
end
function Public.soft_reset_map(old_surface, map_gen_settings, player_starting_items)

    local this = WPT.get()

    if not this.soft_reset_counter then
        this.soft_reset_counter = 0
    end
    if not this.original_surface_name then
        this.original_surface_name = old_surface.name
    end
    this.soft_reset_counter = this.soft_reset_counter + 1

    --local new_surface = game.create_surface(this.original_surface_name .. '_' .. tostring(this.soft_reset_counter), map_gen_settings)
   -- new_surface.request_to_generate_chunks({0, 0}, 0.5)
   -- new_surface.force_generate_chunk_requests()
   
    local new_surface=game.surfaces["nauvis"]

        if map_gen_settings then
        -- 确保我们有一个新的随机种子，除非传入参数指定了旧种子
        if not map_gen_settings.seed then
            map_gen_settings.seed = math.random(1, 4294967295)
        end
        new_surface.map_gen_settings = map_gen_settings
    end


--    if true then 
--     return new_surface
--    end
    new_surface.clear(true)
    remove_all_chart_tags(new_surface)
    --清空玩家的所有物品，背包，武器栏，手持物品等等（在equip_players函数中通过player.clear_items_inside()实现）
    new_surface.request_to_generate_chunks({0, 0}, 1)
    --new_surface.force_generate_chunk_requests()
    reset_forces(new_surface)
    teleport_players(new_surface)
    equip_players(player_starting_items, this)
    delete_all_platforms()
    cleanup_other_surfaces()
    --game.delete_surface(old_surface)

    --创建世界资源
   
    local radius = 512
 --   local area = {{x = -radius, y = -radius}, {x = radius, y = radius}}
    -- for _, entity in pairs(new_surface.find_entities_filtered {area = area, type = 'logistic-robot'}) do
    --     entity.destroy()
    -- end

    -- for _, entity in pairs(new_surface.find_entities_filtered {area = area, type = 'construction-robot'}) do
    --     entity.destroy()
    -- end

    local message = table.concat({mapkeeper .. ' Welcome to ', this.original_surface_name, '!'})

    if this.soft_reset_counter > 1 then
        message =
            table.concat(
            {
                mapkeeper,
                ' The world has been reshaped, welcome to ',
                this.original_surface_name,
                ' number ',
                tostring(this.soft_reset_counter),
                '!'
            }
        )
    end
    game.print(message, {r = 0.98, g = 0.66, b = 0.22})

    return new_surface
end

return Public
