-- This code is licensed under a different license than the rest of this mod.
-- Refer to the license file in this folder for the license.

local kr_icons_size = false

--[[if krastorio.general.getSafeSettingValue("kr-large-icons") then
  kr_icons_size = true
end]]

local scale = 0.5

local hit_effects = require("__base__/prototypes/entity/hit-effects")

local greenhouse_working_sound = {
    filename = "__Krastorio2Assets__/sounds/buildings/greenhouse.ogg",
    volume = 0.75,
    idle_sound = { filename = "__base__/sound/idle1.ogg" },
    aggregation = {
        max_count = 3,
        remove = false,
        count_already_playing = true,
    },
}

data:extend({
    {
        type = "assembling-machine",
        name = "kr-greenhouse",
        localised_name = "Greenhouse",
        icon_size = 64,
        icon_mipmaps = 4,
        icon = "__Krastorio2Assets__/icons/entities/greenhouse.png",
        flags = { "placeable-neutral", "placeable-player", "player-creation" },
        minable = { mining_time = 1, result = "kr-greenhouse" },
        max_health = 500,
        corpse = "kr-big-random-pipes-remnant",
        dying_explosion = "big-explosion",
        damaged_trigger_effect = hit_effects.entity(),
        {
            { type = "impact", percent = 50 },
        },
        custom_tooltip_fields = 
        {
            { 
                name = {"fun-mode-funtoids.greenosity"},
                value = {"fun-mode-funtoids.99%"}
            },
        },
        fluid_boxes = {
            {
                production_type = "output",
                pipe_picture = kr_pipe_path,
                pipe_covers = pipecoverspictures(),
                volume = 30,
                pipe_connections = {
                    { flow_direction = "output", position = { 0, -3 }, direction = defines.direction.north },
                }
            },
            {
                production_type = "output",
                pipe_picture = kr_pipe_path,
                pipe_covers = pipecoverspictures(),
                volume = 30,
                pipe_connections = {
                    { flow_direction = "output", position = { -3, 0 }, direction = defines.direction.west },
                }
            },
            {
                production_type = "input",
                pipe_picture = kr_pipe_path,
                pipe_covers = pipecoverspictures(),
                volume = 30,
                pipe_connections = {
                    { flow_direction = "input", position = { 3, 0 }, direction = defines.direction.east },
                }
            },
            {
                production_type = "input",
                pipe_picture = kr_pipe_path,
                pipe_covers = pipecoverspictures(),
                volume = 30,
                pipe_connections = {
                    { flow_direction = "input", position = { 0, 3 }, direction = defines.direction.south },
                },
            },
        },
        collision_box = { { -3.25, -3.25 }, { 3.25, 3.25 } },
        selection_box = { { -3.5, -3.5 }, { 3.5, 3.5 } },
        fast_replaceable_group = "kr-greenhouse",
        module_slots = 3,
        allowed_effects = { "consumption", "speed", "productivity", "pollution" },
        graphics_set = {
            animation = {
                layers = {
                    {
                        filename = "__Krastorio2Assets__/buildings/greenhouse/greenhouse.png",
                        priority = "high",
                        scale = scale,
                        width = 512,
                        height = 512,
                        frame_count = 1,
                    },
                    {
                        filename = "__Krastorio2Assets__/buildings/greenhouse/greenhouse-sh.png",
                        priority = "high",
                        scale = scale,
                        width = 512,
                        height = 512,
                        shift = { 0.32, 0 },
                        frame_count = 1,
                        draw_as_shadow = true,
                    },
                },
            },
            working_visualisations = {
                {
                    draw_as_light = true,
                    animation = {
                        filename = "__Krastorio2Assets__/buildings/greenhouse/greenhouse-light.png",
                        scale = scale,
                        width = 512,
                        height = 512,
                        frame_count = 1,
                        repeat_count = 10,
                        animation_speed = 0.35,
                    },
                },
                {
                    animation = {
                        filename = "__Krastorio2Assets__/buildings/greenhouse/greenhouse-working.png",
                        scale = scale,
                        width = 512,
                        height = 512,
                        frame_count = 10,
                        line_length = 5,
                        animation_speed = 0.35,
                    },
                },
            },
        },
        crafting_categories = { "growing" },
        scale_entity_info_icon = kr_icons_size,
        vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        working_sound = greenhouse_working_sound,
        crafting_speed = 1,
        return_ingredients_on_change = true,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = {["pollution"] = -5},
        },
        energy_usage = "144.8kW",
        --ingredient_count = 4,
    },
    {
        type = "item",
        name = "kr-greenhouse",
        localised_name = "Greenhouse",
        icon = "__Krastorio2Assets__/icons/entities/greenhouse.png",
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "green",
        order = "d-g1[greenhouse]",
        place_result = "kr-greenhouse",
        stack_size = 50,
    },
    {
        type = "corpse",
        name = "kr-big-random-pipes-remnant",
        icon = "__Krastorio2Assets__/icons/entities/remnants-icon.png",
        icon_size = 64,
        flags = { "placeable-neutral", "building-direction-8-way", "not-on-map" },
        selection_box = { { -4, -4 }, { 4, 4 } },
        tile_width = 3,
        tile_height = 3,
        selectable_in_game = false,
        subgroup = "remnants",
        order = "z[remnants]-a[generic]-b[big]",
        time_before_removed = 60 * 60 * 20, -- 20 minutes
        final_render_layer = "remnants",
        remove_on_tile_placement = false,
        animation = make_rotated_animation_variations_from_sheet(1, {
            filename = "__Krastorio2Assets__/remnants/big-random-pipes-remnants.png",
            line_length = 1,
            width = 250,
            height = 250,
            frame_count = 1,
            direction_count = 1,
        }),
    },
    {
        type = "recipe-category",
        name = "growing",
    },
})
