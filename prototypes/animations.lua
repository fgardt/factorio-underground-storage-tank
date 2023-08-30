local const = require("constants")

if not settings.startup[const.enable_transparent_setting].value then return end

function animation_layer(filename, is_anim)
    local graphics_dir = const.graphics_dir .. "transparent_top/"

    if is_anim then
        graphics_dir = graphics_dir .. "frames/"
    end

    return {
        filename = graphics_dir .. filename .. ".png",
        priority = "low",
        size = 144,

        repeat_count = is_anim and 1 or 60,
        frame_count = is_anim and 60 or 1,
        line_length = is_anim and 8 or 1,

        apply_runtime_tint = is_anim or false,

        hr_version = {
            filename = graphics_dir .. "hr-" .. filename .. ".png",
            priority = "low",
            size = 288,
            scale = 0.5,

            repeat_count = is_anim and 1 or 60,
            frame_count = is_anim and 60 or 1,
            line_length = is_anim and 8 or 1,

            apply_runtime_tint = is_anim or false,
        },
    }
end

function build_animation(level)
    local layers = {}

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
        name = "ust-transparent_top-" .. level,
        layers = layers,
    }
end

for level = 0, 20 do
    data:extend({ build_animation(level * 5) })
end
