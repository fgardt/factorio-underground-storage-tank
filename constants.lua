local prefix = "ust-"
local volume_size = prefix .. "tank_volume"
local update_rate = prefix .. "update_rate"
local graphic_mode = prefix .. "graphic_mode"

---@return number
local function get_volume()
    ---@diagnostic disable-next-line: return-type-mismatch
    return settings.startup[volume_size].value
end

---@return "Slow"|"Normal"|"Fast"|"Insane"
local function get_rate()
    ---@diagnostic disable-next-line: return-type-mismatch
    return settings.global[update_rate].value
end

local function is_transparent()
    return settings.startup[graphic_mode].value == "transparent"
end

---@class Constants
local const = {
    setting = {
        volume_size = volume_size,
        update_rate = update_rate,
        graphic_mode = graphic_mode,

        get_volume = get_volume,
        get_rate = get_rate,
        is_transparent = is_transparent,
    },
    prefix = prefix,
    entity_name = "underground-storage-tank",
    graphics_dir = "__underground-storage-tank__/graphics/",
}

return const
