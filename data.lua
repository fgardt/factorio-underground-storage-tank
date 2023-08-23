require("circuit-connector-sprites")

local pictures = table.deepcopy(data.raw["storage-tank"]["storage-tank"].pictures)

local graphics_dir = "__underground-storage-tank__/graphics/"

pictures.picture.sheets = {
    {
        filename = graphics_dir .. "tank/base.png",
        priority = "extra-high",
        frames = 1,
        width = 176,
        height = 176,
        shift = { 0, 0 },
        hr_version = {
            filename = graphics_dir .. "tank/hr-base.png",
            priority = "extra-high",
            frames = 1,
            width = 352,
            height = 352,
            shift = { 0, 0 },
            scale = 0.5
        }
    },
    {
        filename = graphics_dir .. "tank/shadow.png",
        draw_as_shadow = true,
        priority = "extra-high",
        frames = 1,
        width = 176,
        height = 176,
        shift = { 0, 0 },
        hr_version = {
            filename = graphics_dir .. "tank/hr-shadow.png",
            draw_as_shadow = true,
            priority = "extra-high",
            frames = 1,
            width = 352,
            height = 352,
            shift = { 0, 0 },
            scale = 0.5
        }
    },
    {
        filename = graphics_dir .. "corner_pipes/south-west.png",
        priority = "extra-high",
        frames = 1,
        width = 64,
        height = 64,
        shift = { -2, 2 },
        hr_version = {
            filename = graphics_dir .. "corner_pipes/hr-south-west.png",
            priority = "extra-high",
            frames = 1,
            width = 128,
            height = 128,
            shift = { -2, 2 },
            scale = 0.5
        }
    },
    {
        filename = graphics_dir .. "corner_pipes/south-east.png",
        priority = "extra-high",
        frames = 1,
        width = 64,
        height = 64,
        shift = { 2, 2 },
        hr_version = {
            filename = graphics_dir .. "corner_pipes/hr-south-east.png",
            priority = "extra-high",
            frames = 1,
            width = 128,
            height = 128,
            shift = { 2, 2 },
            scale = 0.5
        }
    },
    {
        filename = graphics_dir .. "corner_pipes/north-west.png",
        priority = "extra-high",
        frames = 1,
        width = 64,
        height = 64,
        shift = { -2, -2 },
        hr_version = {
            filename = graphics_dir .. "corner_pipes/hr-north-west.png",
            priority = "extra-high",
            frames = 1,
            width = 128,
            height = 128,
            shift = { -2, -2 },
            scale = 0.5
        }
    },
    {
        filename = graphics_dir .. "corner_pipes/north-east.png",
        priority = "extra-high",
        frames = 1,
        width = 64,
        height = 64,
        shift = { 2, -2 },
        hr_version = {
            filename = graphics_dir .. "corner_pipes/hr-north-east.png",
            priority = "extra-high",
            frames = 1,
            width = 128,
            height = 128,
            shift = { 2, -2 },
            scale = 0.5
        }
    }
}

pictures.window_background = {
    filename = graphics_dir .. "tank/window-background.png",
    priority = "extra-high",
    width = 24,
    height = 42,
    hr_version = {
        filename = graphics_dir .. "tank/hr-window-background.png",
        priority = "extra-high",
        width = 48,
        height = 84,
        scale = 0.5
    }
}

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

data:extend({
    {
        type = "storage-tank",
        name = "underground-storage-tank",

        minable = { mining_time = 1, result = "underground-storage-tank" },

        scale_info_icons = false,
        collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } },
        selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },

        flow_length_in_ticks = 360,

        fluid_box = {
            base_area = 500,
            base_level = -5,
            height = 5,

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
                filename = graphics_dir .. "tank/reflection.png",
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
    },
    {
        type = "item",
        name = "underground-storage-tank",
        icon = graphics_dir .. "tank/item.png",
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "storage",
        order = "b[fluid]-b[storage-tank]",
        place_result = "underground-storage-tank",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "underground-storage-tank",
        energy_required = 15,
        enabled = false,
        ingredients = {
            { "storage-tank", 10 },
            { "explosives",   10 },
            { "pipe",         20 }
        },
        result = "underground-storage-tank"
    },
    {
        type = "technology",
        name = "underground-storage-tank",
        icon = graphics_dir .. "tank/tech.png",
        icon_size = 256,
        icon_mipmaps = 4,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "underground-storage-tank"
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
    },
})
