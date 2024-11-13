local const = require("constants")
local combined = require("graphics.combined")

---@param name string
---@param options table?
---@return table
local function make_layer(name, options)
    local function internal(src, name, options)
        local info = src[name]
        local layer = {
            filename = const.graphics_dir .. "tank/" .. name .. ".png",
            width = info.width,
            height = info.height,
            scale = info.scale,
            shift = info.shift,
        }

        for k, v in pairs(options or {}) do
            layer[k] = v
        end

        return layer
    end

    return internal(combined, name, options)
end

local pictures = table.deepcopy(data.raw["storage-tank"]["storage-tank"].pictures)

if not pictures then
    error("storage-tank pictures not found")
end

pictures.window_background = {
    filename = const.graphics_dir .. "blank.png",
    priority = "extra-high",
    size = 1,
}

pictures.picture = {
    layers = {
        make_layer("window", { priority = "extra-high" }),
        make_layer("shadow", { draw_as_shadow = true, priority = "extra-high" }),
        {
            filename = const.graphics_dir .. "corner_pipes/south-west.png",
            priority = "extra-high",
            size = 128,
            shift = { -2, 2 },
            scale = 0.5
        },
        {
            filename = const.graphics_dir .. "corner_pipes/south-east.png",
            priority = "extra-high",
            size = 128,
            shift = { 2, 2 },
            scale = 0.5
        },
        {
            filename = const.graphics_dir .. "corner_pipes/north-west.png",
            priority = "extra-high",
            size = 128,
            shift = { -2, -2 },
            scale = 0.5
        },
        {
            filename = const.graphics_dir .. "corner_pipes/north-east.png",
            priority = "extra-high",
            size = 128,
            shift = { 2, -2 },
            scale = 0.5
        }
    }
}

---@type data.Animation
local empty_gas = {
    filename = const.graphics_dir .. "blank.png",
    priority = "extra-high",
    size = 1,
    frame_count = 1,
}

local integration_patch
if const.setting.is_transparent() then
    pictures.picture.layers[1] = table.deepcopy(pictures.picture.layers[2])
    pictures.picture.layers[2] = table.deepcopy(pictures.picture.layers[6])
    pictures.picture.layers[6] = nil

    pictures.fluid_background = pictures.window_background
    pictures.flow_sprite = pictures.window_background
    pictures.gas_flow = empty_gas

    local tt = require("graphics.transparent_top.combined")["ring_tank"]
    integration_patch = {
        filename = const.graphics_dir .. "transparent_top/ring_tank.png",
        width = tt.width,
        height = tt.height,
        scale = tt.scale,
        shift = tt.shift,
        priority = "extra-high",
    }
elseif const.setting.is_closed() then
    pictures.picture.layers[1] = nil
    pictures.fluid_background = pictures.window_background
    pictures.flow_sprite = pictures.window_background
    pictures.gas_flow = empty_gas
    integration_patch = make_layer("closed", { priority = "extra-high" })
else
    integration_patch = make_layer("no_window", { priority = "extra-high" })
end

-- circuit connections
require("circuit-connector-sprites")
local circuit_definition = circuit_connector_definitions.create_vector(
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
    collision_mask = { layers = { ["object"] = true, ["water_tile"] = true } },

    flow_length_in_ticks = 360,

    fluid_box = {
        volume = base_area * height,

        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            { position = { -2, -2 }, direction = defines.direction.north },
            { position = { -2, -2 }, direction = defines.direction.west },
            { position = { 2, -2 },  direction = defines.direction.north },
            { position = { 2, -2 },  direction = defines.direction.east },
            { position = { -2, 2 },  direction = defines.direction.south },
            { position = { -2, 2 },  direction = defines.direction.west },
            { position = { 2, 2 },   direction = defines.direction.south },
            { position = { 2, 2 },   direction = defines.direction.east },
        }
    },

    pictures = pictures,
    window_bounding_box = {
        { -0.375, -0.1875 },
        { 0.375,  1.125 }
    },

    water_reflection = {
        pictures = make_layer("reflection", { priority = "extra-high", variation_count = 1 }),
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

    icon = const.graphics_dir .. "tank/item.png",
    icon_size = 64,
}

---@type data.ItemPrototype
local item = {
    type = "item",
    name = const.entity_name,
    icon = const.graphics_dir .. "tank/item.png",
    icon_size = 64,
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
        { type = "item", name = "storage-tank", amount = 10 },
        { type = "item", name = "explosives",   amount = 10 },
        { type = "item", name = "pipe",         amount = 20 }
    },
    results = {
        { type = "item", name = const.entity_name, amount = 1 }
    },
}

---@type data.TechnologyPrototype
local technology = {
    type = "technology",
    name = const.entity_name,
    icon = const.graphics_dir .. "tank/tech.png",
    icon_size = 256,
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
