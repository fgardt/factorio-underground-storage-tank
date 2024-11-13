local const = require("constants")

---@return 1|30|60|300
local function parse_rate_setting()
    local rate = const.setting.get_rate()

    if rate == "slow" then
        return 300
    end

    if rate == "normal" then
        return 60
    end

    if rate == "fast" then
        return 30
    end

    if rate == "insane" then
        return 1
    end

    -- fallback to slow if something went wrong (whatever that may be??)
    return 300
end

local function init_storage()
    ---@class TankInfo
    ---@field age uint
    ---@field entity LuaEntity
    ---@field animation LuaRenderObject?
    ---@field prev_unit uint
    ---@field next_unit uint

    ---@class Storage
    ---@field rate uint
    ---@field tanks table<uint, TankInfo>
    ---@field count uint
    ---@field next_check uint
    ---@field ticks_per_check uint
    ---@field entities_per_check uint
    ---@field recalculate_timings boolean
    storage = storage or {}

    storage.rate = storage.rate or parse_rate_setting()
    storage.tanks = storage.tanks or {}
    storage.count = storage.count or 0 ---@type uint
    storage.next_check = storage.next_check or nil

    storage.ticks_per_check = storage.ticks_per_check or 1 ---@type uint
    storage.entities_per_check = storage.entities_per_check or 1 ---@type uint
    storage.recalculate_timings = false
end

---@param tank TankInfo
local function update_tank(tank)
    local entity = tank.entity
    if not entity.valid then
        -- remove tnak from ring buffer
        storage.count = storage.count - 1
        --storage.recalculate_timings = true

        if storage.count == 0 then
            storage.next_check = nil
        else
            storage.tanks[tank.prev_unit].next_unit = tank.next_unit
            storage.tanks[tank.next_unit].prev_unit = tank.prev_unit
        end

        tank = nil ---@type TankInfo

        return
    end

    if tank.animation == nil or not tank.animation.valid then
        if not const.setting.is_transparent() then return end

        tank.animation = rendering.draw_animation({
            animation = "ust-transparent_top-0",
            target = entity,
            surface = entity.surface,
            animation_offset = tank.age % 600,
            animation_speed = 0.1,
            render_layer = "floor",
        })
    end

    local fluid = tank.entity.fluidbox[1]

    if not fluid then
        tank.animation.animation = "ust-transparent_top-0"
        tank.animation.color = { a = 0 }
        return
    end

    local prototype = prototypes.fluid[fluid.name]
    local level = math.floor((fluid.amount / tank.entity.prototype.fluid_capacity) * 20 + 0.5) * 5
    local color = prototype.base_color
    --local is_gas = (fluid.temperature or 15) > prototype.gas_temperature

    if level == 0 then
        color = { 0, 0, 0, 0 }
    else
        color.a = color.a * 0.75
    end

    tank.animation.animation = "ust-transparent_top-" .. level
    tank.animation.color = color

    -- TODO: different animation for gases
end

---@param _ NthTickEventData
local function run_checks(_)
    for _ = 1, storage.entities_per_check do
        if not storage.next_check then
            return
        end

        local info = storage.tanks[ storage.next_check --[[@as uint]] ]
        storage.next_check = info.next_unit

        update_tank(info)
    end
end

local function update_timings()
    local count = storage.count
    local rate = storage.rate

    -- check if we can disable tank scanning
    if not const.setting.is_transparent() or count == 0 or rate == 0 then
        script.on_nth_tick(storage.ticks_per_check, nil)
        return
    end

    local ticks_per_check = math.ceil(rate / count) --[[@as uint]]
    local entities_per_check = math.ceil(count / rate) --[[@as uint]]

    -- check if this clashes with the recalculation interval
    if ticks_per_check == 1800 then
        ticks_per_check = 1799
    end

    script.on_nth_tick(storage.ticks_per_check, nil)
    script.on_nth_tick(ticks_per_check, run_checks)

    storage.ticks_per_check = ticks_per_check
    storage.entities_per_check = entities_per_check
    storage.recalculate_timings = false
end

script.on_nth_tick(1800, function(_)
    --if storage.recalculate_timings then
    update_timings()
    --end
end)

---@param entity LuaEntity?
local function register_tank(entity)
    if not entity or not entity.valid or not entity.unit_number or not entity.name == const.entity_name then
        return
    end

    ---@type uint, uint
    local next_unit, prev_unit
    if not storage.next_check then
        storage.next_check = entity.unit_number
        next_unit = entity.unit_number ---@type uint
        prev_unit = entity.unit_number ---@type uint
    else
        prev_unit = storage.next_check ---@type uint
        next_unit = storage.tanks[prev_unit].next_unit

        storage.tanks[prev_unit].next_unit = entity.unit_number
        storage.tanks[next_unit].prev_unit = entity.unit_number
    end

    local age = game.tick
    local anim_id = nil
    if const.setting.is_transparent() then
        anim_id = rendering.draw_animation({
            animation = "ust-transparent_top-0",
            target = entity,
            surface = entity.surface,
            animation_offset = age % 600,
            animation_speed = 0.1,
            render_layer = "floor",
        })
    end

    ---@type TankInfo
    local tank = {
        age = age,
        entity = entity,
        animation = anim_id,
        next_unit = next_unit,
        prev_unit = prev_unit,
    }

    storage.count = storage.count + 1
    storage.tanks[entity.unit_number] = tank

    update_timings()
end

---@param clear boolean?
local function init(clear)
    if clear then
        storage = {}
        rendering.clear("underground-storage-tank")
    end

    init_storage()
    storage.rate = parse_rate_setting()
    update_timings()

    if clear or storage.count == 0 then
        for _, surface in pairs(game.surfaces) do
            for _, entity in pairs(surface.find_entities_filtered({ type = "storage-tank", name = const.entity_name })) do
                register_tank(entity)
            end
        end
    end
end

script.on_init(function() init(true) end)
script.on_configuration_changed(function() init(true) end)

script.on_load(function()
    if not const.setting.is_transparent() then return end

    if not storage then return end
    if storage.count == 0 or storage.rate == 0 then return end
    if not storage.ticks_per_check then return end

    script.on_nth_tick(storage.ticks_per_check, run_checks)
end)

---@param event
---| EventData.on_robot_built_entity
---| EventData.script_raised_revive
---| EventData.script_raised_built
---| EventData.on_built_entity
local function placed_tank(event)
    register_tank(event.entity)
end

local ev = defines.events
script.on_event(ev.on_runtime_mod_setting_changed, function()
    storage.rate = parse_rate_setting()
    update_timings()
end)

---@type LuaScriptRaisedBuiltEventFilter[]
local filter = { { filter = "type", type = "storage-tank" }, { filter = "name", name = const.entity_name, mode = "and" } }

script.on_event(ev.on_robot_built_entity, placed_tank, filter)
script.on_event(ev.script_raised_revive, placed_tank, filter)
script.on_event(ev.script_raised_built, placed_tank, filter)
script.on_event(ev.on_built_entity, placed_tank, filter)
