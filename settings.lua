local const = require("constants")

data:extend({
    {
        type = "bool-setting",
        name = const.enable_transparent_setting,
        setting_type = "startup",
        default_value = true,
        order = "a"
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
