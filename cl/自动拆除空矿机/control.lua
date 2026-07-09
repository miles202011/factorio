require('__base__/script/freeplay/control.lua')

-- 向所有在线玩家发送消息
local function broadcast(msg, color)
    for _, p in pairs(game.players) do
        if p.valid and p.connected then
            p.print(msg, color)
        end
    end
end

-- 返回矿机覆盖范围内是否还有它能采的资源
-- 用矩形近似圆形采矿区域，resource_categories 过滤掉矿机采不了的资源类型
local function drill_has_resources(drill)
    local prototype = drill.prototype
    local radius = prototype.mining_drill_radius
    local pos = drill.position
    local categories = prototype.resource_categories

    local resources = drill.surface.find_entities_filtered({
        area = {
            { pos.x - radius, pos.y - radius },
            { pos.x + radius, pos.y + radius }
        },
        type = "resource"
    })

    for _, res in pairs(resources) do
        if res.valid and categories[res.prototype.resource_category] then
            return true
        end
    end
    return false
end

local function mark_empty_drills(surface)
    local drills = surface.find_entities_filtered({ type = "mining-drill" })
    local count = 0
    local first_pos = nil

    for _, drill in pairs(drills) do
        if drill.valid and not drill.to_be_deconstructed() then
            if not drill_has_resources(drill) then
                drill.order_deconstruction(drill.force)
                count = count + 1
                first_pos = first_pos or drill.position
            end
        end
    end

    if count > 0 then
        local loc = "(" .. math.floor(first_pos.x) .. ", " .. math.floor(first_pos.y) .. ")"
        local suffix = count == 1 and "1 台矿机" or count .. " 台矿机"
        broadcast(
            "[color=255,200,100]自动拆除：[/color]矿区资源耗尽，已标记 " .. suffix ..
            " 拆除，附近 [color=200,200,200]" .. loc .. "[/color]",
            { r = 1.0, g = 0.8, b = 0.4 }
        )
    end
end

-- 某块资源耗尽时，检查附近矿机是否已无资源可采，有则标记拆除
-- 搜索半径 15 格：on_resource_depleted 只提供资源位置，没有关联矿机，需要反向扫描
script.on_event(defines.events.on_resource_depleted, function(event)
    local resource = event.entity
    if not resource or not resource.valid then return end

    local pos = resource.position
    local drills = resource.surface.find_entities_filtered({
        area = { { pos.x - 15, pos.y - 15 }, { pos.x + 15, pos.y + 15 } },
        type = "mining-drill"
    })

    local count = 0
    local first_pos = nil

    for _, drill in pairs(drills) do
        if drill.valid and not drill.to_be_deconstructed() then
            if not drill_has_resources(drill) then
                drill.order_deconstruction(drill.force)
                count = count + 1
                first_pos = first_pos or drill.position
            end
        end
    end

    if count > 0 then
        local loc = "(" .. math.floor(first_pos.x) .. ", " .. math.floor(first_pos.y) .. ")"
        local suffix = count == 1 and "1 台矿机" or count .. " 台矿机"
        broadcast(
            "[color=255,200,100]自动拆除：[/color]矿区资源耗尽，已标记 " .. suffix ..
            " 拆除，附近 [color=200,200,200]" .. loc .. "[/color]",
            { r = 1.0, g = 0.8, b = 0.4 }
        )
    end
end)

-- 脚本更新时立即扫描一次，处理更新前已采空的矿机
script.on_configuration_changed(function()
    for _, surface in pairs(game.surfaces) do
        mark_empty_drills(surface)
    end
end)

-- 每 5 分钟扫描一次全图，兜底处理脚本加载前已经采空的矿机
script.on_nth_tick(18000, function()
    for _, surface in pairs(game.surfaces) do
        mark_empty_drills(surface)
    end
end)
