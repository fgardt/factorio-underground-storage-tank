local const = require("constants")

if not const.setting.is_transparent() then return end

local anim = require("graphics.transparent_top.anim")
local top = require("graphics.transparent_top.combined")

---@param name string
---@param is_anim boolean?
local function animation_layer(name, is_anim)
    local function internal(src, name, is_anim)
        local info = src[name]

        if is_anim then
            name = "frames/" .. name
        end

        return {
            filename = const.graphics_dir .. "transparent_top/" .. name .. ".png",
            width = info.width,
            height = info.height,
            scale = info.scale,
            shift = info.shift,
            line_length = info.line_length,
            frame_count = info.sprite_count,
            repeat_count = 60 / info.sprite_count,
            apply_runtime_tint = is_anim or false,
            priority = "low",
        }
    end

    local gdata
    if is_anim then
        gdata = anim
    else
        gdata = top
    end

    return internal(gdata, name, is_anim)
end

function build_animation(level)
    local layers
    if level == 0 then
        layers = {
            animation_layer("support_frame"),
            animation_layer("empty_tank"),
        }
    else
        layers = {
            animation_layer(string.format("%03d", level), true)
        }
    end

    return {
        type = "animation",
        name = const.prefix .. "transparent_top-" .. level,
        layers = layers,
    }
end

for level = 0, 20 do
    data:extend({ build_animation(level * 5) })
end
