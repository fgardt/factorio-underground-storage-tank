local const = require("constants")

data:extend({
    {
        type = "int-setting",
        name = const.volume_size_setting,
        setting_type = "startup",
        default_value = 250000,
        minimum_value = 1000,
        order = "a"
    },
    {
        type = "bool-setting",
        name = const.enable_transparent_setting,
        setting_type = "startup",
        default_value = true,
        order = "b"
    },
    {
        type = "string-setting",
        name = const.update_rate_setting,
        setting_type = "runtime-global",
        default_value = "Fast",
        allowed_values = { "Slow", "Normal", "Fast", "Insane" },
        order = "a"
    }
})
