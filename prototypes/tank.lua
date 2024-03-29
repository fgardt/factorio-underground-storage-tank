local const = require("constants")

local pictures = table.deepcopy(data.raw["storage-tank"]["storage-tank"].pictures)

pictures.picture = {
    layers = {
        {
            filename = const.graphics_dir .. "tank/window.png",
            priority = "extra-high",
            size = 176,
            hr_version = {
                filename = const.graphics_dir .. "tank/hr-window.png",
                priority = "extra-high",
                size = 352,
                scale = 0.5
            }
        },
        {
            filename = const.graphics_dir .. "tank/shadow.png",
            draw_as_shadow = true,
            priority = "extra-high",
            size = 176,
            hr_version = {
                filename = const.graphics_dir .. "tank/hr-shadow.png",
                draw_as_shadow = true,
                priority = "extra-high",
                size = 352,
                scale = 0.5
            }
        },
        {
            filename = const.graphics_dir .. "corner_pipes/south-west.png",
            priority = "extra-high",
            size = 64,
            shift = { -2, 2 },
            hr_version = {
                filename = const.graphics_dir .. "corner_pipes/hr-south-west.png",
                priority = "extra-high",
                size = 128,
                shift = { -2, 2 },
                scale = 0.5
            }
        },
        {
            filename = const.graphics_dir .. "corner_pipes/south-east.png",
            priority = "extra-high",
            size = 64,
            shift = { 2, 2 },
            hr_version = {
                filename = const.graphics_dir .. "corner_pipes/hr-south-east.png",
                priority = "extra-high",
                size = 128,
                shift = { 2, 2 },
                scale = 0.5
            }
        },
        {
            filename = const.graphics_dir .. "corner_pipes/north-west.png",
            priority = "extra-high",
            size = 64,
            shift = { -2, -2 },
            hr_version = {
                filename = const.graphics_dir .. "corner_pipes/hr-north-west.png",
                priority = "extra-high",
                size = 128,
                shift = { -2, -2 },
                scale = 0.5
            }
        },
        {
            filename = const.graphics_dir .. "corner_pipes/north-east.png",
            priority = "extra-high",
            size = 64,
            shift = { 2, -2 },
            hr_version = {
                filename = const.graphics_dir .. "corner_pipes/hr-north-east.png",
                priority = "extra-high",
                size = 128,
                shift = { 2, -2 },
                scale = 0.5
            }
        }
    }
}

pictures.window_background = {
    filename = const.graphics_dir .. "blank.png",
    priority = "extra-high",
    size = 1,
}

local integration_patch = {
    filename = const.graphics_dir .. "tank/no_window.png",
    priority = "extra-high",
    size = 176,
    shift = { 0, 0 },
    hr_version = {
        filename = const.graphics_dir .. "tank/hr-no_window.png",
        priority = "extra-high",
        size = 352,
        shift = { 0, 0 },
        scale = 0.5
    }
}

-- replace for transparent mode
if const.setting.is_transparent() then
    pictures.fluid_background = pictures.window_background
    pictures.flow_sprite = pictures.window_background
    pictures.gas_flow = pictures.window_background

    pictures.picture.layers[1] = nil
    integration_patch.filename = const.graphics_dir .. "transparent_top/ring_tank.png"
    integration_patch.hr_version.filename = const.graphics_dir .. "transparent_top/hr-ring_tank.png"
end

-- circuit connections
require("circuit-connector-sprites")
local circuit_definition = circuit_connector_definitions.create(
    universal_connector_template,
    {
        {
            variation = 15,
            main_offset = util.add_shift({ -2, -2 }, util.by_pixel(-2, -6)),
            shadow_offset = util.add_shift({ -2, -2 }, util.by_pixel(-10, 3)),
            show_shadow = true
        },
        {
            variation = 17,
            main_offset = util.add_shift({ 2, -2 }, util.by_pixel(-2, -3)),
            shadow_offset = util.add_shift({ 2, -2 }, util.by_pixel(-8, 0)),
            show_shadow = true
        },
        {
            variation = 5,
            main_offset = util.add_shift({ 2, 2 }, util.by_pixel(-2, 1)),
            shadow_offset = util.add_shift({ 2, 2 }, util.by_pixel(-2, 1)),
            show_shadow = true
        },
        {
            variation = 3,
            main_offset = util.add_shift({ -2, 2 }, util.by_pixel(-4, -4)),
            shadow_offset = util.add_shift({ -2, 2 }, util.by_pixel(-4, -4)),
            show_shadow = true
        },
    }
)

local base_area = 500
local height = const.setting.get_volume() / (100 * base_area)
-- prototype defs
---@type data.StorageTankPrototype
local entity = {
    type = "storage-tank",
    name = const.entity_name,

    minable = { mining_time = 1, result = const.entity_name },

    scale_info_icons = false,
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } },
    collision_mask = { "object-layer", "water-tile" },

    flow_length_in_ticks = 360,

    fluid_box = {
        base_area = base_area,
        base_level = -5,
        height = height,

        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            { position = { -3, -2 } },
            { position = { -2, -3 } },
            { position = { -2, 3 } },
            { position = { -3, 2 } },
            { position = { 2, -3 } },
            { position = { 3, -2 } },
            { position = { 3, 2 } },
            { position = { 2, 3 } },
        },
    },

    pictures = pictures,
    window_bounding_box = {
        { -0.375, -0.1875 },
        { 0.375,  1.125 }
    },

    water_reflection = {
        pictures = {
            filename = const.graphics_dir .. "tank/reflection.png",
            priority = "extra-high",
            variation_count = 1,
            width = 176,
            height = 176,
            shift = { 0, 0 },
            scale = 1
        },
        rotate = false,
        orientation_to_variation = false
    },

    integration_patch_render_layer = "remnants",
    integration_patch = integration_patch,

    working_sound = table.deepcopy(data.raw["storage-tank"]["storage-tank"].working_sound),

    max_health = 750,
    dying_explosion = "storage-tank-explosion",
    corpse = "storage-tank-remnants",
    damaged_trigger_effect = table.deepcopy(data.raw["storage-tank"]["storage-tank"].damaged_trigger_effect),
    flags = {
        "placeable-player",
        "player-creation",
    },

    circuit_connector_sprites = circuit_definition.sprites,
    circuit_wire_connection_points = circuit_definition.points,
    circuit_wire_max_distance = default_circuit_wire_max_distance,

    icon = "__base__/graphics/icons/storage-tank.png",
    icon_size = 64,
    icon_mipmaps = 4,
}

---@type data.ItemPrototype
local item = {
    type = "item",
    name = const.entity_name,
    icon = const.graphics_dir .. "tank/item.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "storage",
    order = "b[fluid]-b[storage-tank]",
    place_result = const.entity_name,
    stack_size = 50
}

---@type data.RecipePrototype
local recipe = {
    type = "recipe",
    name = const.entity_name,
    energy_required = 15,
    enabled = false,
    ingredients = {
        { "storage-tank", 10 },
        { "explosives",   10 },
        { "pipe",         20 }
    },
    result = const.entity_name
}

---@type data.TechnologyPrototype
local technology = {
    type = "technology",
    name = const.entity_name,
    icon = const.graphics_dir .. "tank/tech.png",
    icon_size = 256,
    icon_mipmaps = 4,
    effects = {
        {
            type = "unlock-recipe",
            recipe = const.entity_name
        }
    },
    prerequisites = {
        "fluid-handling",
        "explosives",
        "chemical-science-pack"
    },
    unit = {
        count = 125,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack",   1 },
            { "chemical-science-pack",   1 }
        },
        time = 30
    },
}

data:extend({ entity, item, recipe, technology })
