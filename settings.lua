local const = require("constants")

data:extend({
    {
        type = "int-setting",
        name = const.setting.volume_size,
        setting_type = "startup",
        default_value = 250000,
        minimum_value = 1000,
        order = "a"
    },
    {
        type = "string-setting",
        name = const.setting.graphic_mode,
        setting_type = "startup",
        default_value = "transparent",
        allowed_values = { "transparent", "small window", "closed" },
        order = "b"
    },
    {
        type = "string-setting",
        name = const.setting.update_rate,
        setting_type = "runtime-global",
        default_value = "Fast",
        allowed_values = { "Slow", "Normal", "Fast", "Insane" },
        order = "a"
    }
})
