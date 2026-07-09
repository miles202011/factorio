require('__base__/script/freeplay/control.lua')

-- ============================================================
-- 四季
-- nauvis 按坐标轴分成四个象限，各克隆一颗星球的地形：
--   左上 (x<0, y<0) → nauvis 地星原生地形（不处理）
--   左下 (x<0, y>0) → gleba  草星
--   右上 (x>0, y<0) → vulcanus 火星
--   右下 (x>0, y>0) → fulgora  雷星
-- ============================================================

local DEMOLISHER_POOL = {
    "small-demolisher", "small-demolisher", "small-demolisher",
    "medium-demolisher", "medium-demolisher",
    "big-demolisher",
}

local function ensure_planet_surface(planet_name)
    if game.surfaces[planet_name] then return end
    local planet = game.planets[planet_name]
    if not planet then return end
    planet.create_surface()
end

local function clone_from_planet(planet_name, position, area, surface)
    ensure_planet_surface(planet_name)
    local src = game.surfaces[planet_name]
    if not src then return end
    if not src.is_chunk_generated(position) then
        src.request_to_generate_chunks(position, 0)
        src.force_generate_chunk_requests()
    end
    src.clone_area({
        source_area                   = area,
        destination_area              = area,
        destination_surface           = surface,
        clone_tiles                   = true,
        clone_entities                = true,
        clone_decoratives             = true,
        clear_destination_entities    = true,
        clear_destination_decoratives = true,
        expand_map                    = true,
        create_build_effect_smoke     = false,
    })
end

-- 检查 Vulcanus Voronoi 领地的所有区块是否全部在火星象限内（x>=0, y<0）。
local function territory_in_vulcanus_quadrant(vt)
    for _, c in ipairs(vt.get_chunks()) do
        if c.x < 0 or c.y >= 0 then return false end
    end
    return true
end

-- 取得或创建 nauvis 上对应的领地。返回 (territory, is_new)。
-- vt_key 由调用方提供，来自 Vulcanus Voronoi 领地锚点区块坐标。
local function get_or_create_territory(surface, chunk_pos, vt_key)
    local t = storage.nauvis_territories[vt_key]
    if t and t.valid then return t, false end

    t = surface.create_territory({chunks = {chunk_pos}})
    if not t then return nil, false end

    storage.nauvis_territories[vt_key] = t
    return t, true
end

local DEMOLISHER_NAMES = {"small-demolisher", "medium-demolisher", "big-demolisher"}

-- 优先从 Vulcanus 地表复制撼地虫到 nauvis（保留真实位置）；
-- 若该区块无撼地虫，则在候选位置生成一只。
-- 每次领地有变化时调用 regenerate_patrol_path 修复"原地转圈"问题。
local function setup_demolisher(src, dst, area, territory, is_new)
    if is_new then
        local spawned = false
        if src then
            for _, e in ipairs(src.find_entities_filtered({area = area, name = DEMOLISHER_NAMES})) do
                if e.valid then
                    local u = dst.create_segmented_unit({
                        name = e.name, force = e.force,
                        territory = territory, position = e.position,
                    })
                    if u and u.valid then spawned = true; break end
                end
            end
        end
        if not spawned then
            local lx, ly = area.left_top.x, area.left_top.y
            local name = DEMOLISHER_POOL[math.random(#DEMOLISHER_POOL)]
            for _, off in ipairs({{16,16},{8,8},{24,8},{8,24},{24,24}}) do
                local u = dst.create_segmented_unit({
                    name = name, force = "enemy", territory = territory,
                    position = {x = lx + off[1], y = ly + off[2]},
                })
                if u and u.valid then break end
            end
        end
    end
    territory.regenerate_patrol_path()
end

local function on_chunk_generated(event)
    local surface = event.surface
    if surface.name ~= "nauvis" then return end

    local left_top = event.area.left_top
    local cx = left_top.x + 16
    local cy = left_top.y + 16
    local chunk_pos = {x = left_top.x / 32, y = left_top.y / 32}

    if cx < 0 and cy > 0 then
        clone_from_planet("gleba",    {x = cx, y = cy}, event.area, surface)
    elseif cx > 0 and cy < 0 then
        clone_from_planet("vulcanus", {x = cx, y = cy}, event.area, surface)

        local vulcanus = game.surfaces["vulcanus"]
        if vulcanus then
            local vt = vulcanus.get_territory_for_chunk(chunk_pos)
            if vt and vt.valid and territory_in_vulcanus_quadrant(vt) then
                local vc = vt.get_chunks()
                local vt_key = "v" .. vc[1].x .. "," .. vc[1].y
                local territory, is_new = get_or_create_territory(surface, chunk_pos, vt_key)
                if territory then
                    if not is_new then
                        surface.set_territory_for_chunks({chunk_pos}, territory)
                    end
                    setup_demolisher(vulcanus, surface, event.area, territory, is_new)
                end
            end
        end
    elseif cx > 0 and cy > 0 then
        clone_from_planet("fulgora",  {x = cx, y = cy}, event.area, surface)
    end
end

script.on_init(function()
    storage.disable_crashsite = true
    storage.created_items = {
        ["iron-plate"]          = 8,
        ["wood"]                = 1,
        ["pistol"]              = 1,
        ["firearm-magazine"]    = 10,
        ["burner-mining-drill"] = 1,
        ["stone-furnace"]       = 1,
    }
    storage.respawn_items = {
        ["pistol"]          = 1,
        ["firearm-magazine"] = 10,
    }
    storage.nauvis_territories = {}

    local force = game.forces.player
    for _, planet in ipairs({"vulcanus", "fulgora", "gleba"}) do
        local tech = force.technologies["planet-discovery-" .. planet]
        if tech then tech.researched = true end
    end
    ensure_planet_surface("gleba")
    ensure_planet_surface("vulcanus")
    ensure_planet_surface("fulgora")
    game.forces.player.set_spawn_position({x = -4, y = -4}, game.surfaces["nauvis"])
end)

script.on_configuration_changed(function()
    if not storage.nauvis_territories then
        storage.nauvis_territories = {}
    end
    local force = game.forces.player
    for _, planet in ipairs({"vulcanus", "fulgora", "gleba"}) do
        local tech = force.technologies["planet-discovery-" .. planet]
        if tech then tech.researched = true end
    end
end)

script.on_event(defines.events.on_chunk_generated, on_chunk_generated)
