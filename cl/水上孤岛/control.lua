require('__base__/script/freeplay/control.lua')

local SURFACE_NAME = "水上孤岛"
local FLOOR_TILE   = "stone-path"
local WATER_TILE   = "deepwater"
local STOMPER_NAME = "big-stomper-pentapod"
local FLOOR_RADIUS = 5  -- 11×11 地砖

-- ============================================================
-- 区块填充
-- ============================================================

local function on_chunk_generated(event)
    if event.surface.name ~= SURFACE_NAME then return end

    local area    = event.area
    local surface = event.surface
    local tiles   = {}

    for x = area.left_top.x, area.right_bottom.x - 1 do
        for y = area.left_top.y, area.right_bottom.y - 1 do
            local is_center = (x >= -FLOOR_RADIUS and x <= FLOOR_RADIUS
                           and y >= -FLOOR_RADIUS and y <= FLOOR_RADIUS)
            table.insert(tiles, {
                name     = is_center and FLOOR_TILE or WATER_TILE,
                position = {x, y},
            })
        end
    end
    surface.set_tiles(tiles)
    surface.destroy_decoratives({area = area})

    -- 清除自动实体，保留重踏虫身体和腿（腿名称含 STOMPER_NAME 前缀）
    for _, entity in pairs(surface.find_entities(area)) do
        if entity.valid and not entity.name:find(STOMPER_NAME, 1, true) then
            entity.destroy()
        end
    end

    -- 中心区块生成完毕且瓦片已就位时放置虫子（只放一次）
    -- 此处放置比 on_init 更可靠：瓦片刚设完，表面状态确定有效
    if not storage.stomper_placed
       and area.left_top.x <= 0 and area.right_bottom.x > 0
       and area.left_top.y <= 0 and area.right_bottom.y > 0 then
        local e = surface.create_entity({
            name     = STOMPER_NAME,
            position = {0, 0},
            force    = "enemy",
        })
        if e then storage.stomper_placed = true end
    end
end

script.on_event(defines.events.on_chunk_generated, on_chunk_generated)

-- ============================================================
-- 表面初始化
-- ============================================================

local function setup()
    storage.stomper_placed = false

    local surface = game.get_surface(SURFACE_NAME) or game.create_surface(SURFACE_NAME, {
        default_enable_all_autoplace_controls = false,
        autoplace_settings = {
            tile       = {treat_missing_as_default = false},
            entity     = {treat_missing_as_default = false},
            decorative = {treat_missing_as_default = false},
        },
        cliff_settings = {cliff_elevation_0 = 1024},
    })

    -- 触发中心区块生成，on_chunk_generated 会在其中放置虫子
    surface.request_to_generate_chunks({0, 0}, 1)
    surface.force_generate_chunk_requests()
end

local function ensure_storage()
    if storage.stomper_placed == nil then
        storage.stomper_placed = false
    end
end

script.on_init(setup)
script.on_configuration_changed(ensure_storage)
