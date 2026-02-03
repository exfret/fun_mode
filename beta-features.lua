--------------------------------------------------
--------------------------------------------------
-------------- Changes ---------------------------
--------------------------------------------------
--------------------------------------------------

--------------------------------------------------
-- Startup
--------------------------------------------------

-- 1. Starting patches overlap
-- 2. (Non-beta) Wooden equipment
-- 3. (Non-beta) Corpses randomly teleport back to you
-- 4. Furnaces are replaced by furnace stacks
-- 5. Custom achievements

--------------------------------------------------
-- Electricity
--------------------------------------------------

-- 1. (NOT DOING) Belts slow you down drastically, dragging you along

--------------------------------------------------
-- Red science
--------------------------------------------------

-- 1. More red science technology that just gatekeeps extra red techs

--------------------------------------------------
-- Green science
--------------------------------------------------

-- 1. Light green and dark green science
-- 2. Unboiler
-- 3. Fluid unlock rearrangment
-- 4. (Non-beta) Locomotives actively try to kill you
-- 5. Green-ades
-- 6. The character has to be green while doing green research
-- 7. (Non-beta) Toolbelt 2 after dark green science
-- 8. Extra sacrifices
-- 9. Solid steam engine
-- 10. (Non-beta) Iron plate prod bonus research
-- 11. Different types of engines
-- 12. Widgets
-- 13. Research to remove multidirectionality
-- 14. Tuned down landfill cost because I'm merciful

--------------------------------------------------
-- Oil
--------------------------------------------------

-- 1. Equipment shapes are weird
-- 2. (TODO) Youtube videos
-- 3. (TODO) Squeak through at home
-- 4. Solid fuel recipes made in unboiler

--------------------------------------------------
-- Bots
--------------------------------------------------

-- 1. More mining productivity levels to help with later grind
-- 2. Steel productivity
-- 3. (Non-beta) Transport belt rotation tech
-- 4. Placeable water (Replaced with offshore assemblers on concrete)
-- 5. OP substations

--------------------------------------------------
-- Purple/Yellow
--------------------------------------------------

-- 1. (WIP) Py science pack
-- 2. Spidertrons have many legs
-- 3. Very advanced oil processing
-- 4. A way to craft oil patches
-- 5. Kovarex costs less since it's less useful

--------------------------------------------------
-- Rocket
--------------------------------------------------

-- 1. Cat research for cheeseman 2
-- 2. Pistols as prereq to rocket

--------------------------------------------------
-- Execute last
--------------------------------------------------

-- 1. Actually switch lubricant back to fluid and then you have to unboil it
-- 2. Remove copper cable and power armor required for techs
-- 3. Shallow water collides with nothing

--------------------------------------------------
--------------------------------------------------
-------------- Implementation! -------------------
--------------------------------------------------
--------------------------------------------------

function do_fun_mode_beta_features()

--------------------------------------------------
-- Startup
--------------------------------------------------

    -- 1. Starting patches overlap

    -- In control

    -- 2. Wooden equipment

    -- Non-beta now

    -- 3. Corpses randomly teleport back to you

    -- In control

    -- 4. Furnaces are replaced by furnace stacks

    -- Allow some normal furnaces at first, only starting in your inventory
    data.raw.item["steel-furnace"].icon = "__fun_mode__/graphics/icons/steel-furnace-stack.png"
    data.raw.item["steel-furnace"].icon_size = 64
    data.raw.item["steel-furnace"].icon_mipmaps = 1
    data.raw.item["steel-furnace"].localised_name = "Greel furnace stack"
    data.raw.furnace["stone-furnace-stack"] = table.deepcopy(data.raw.furnace["stone-furnace"])
    data.raw.furnace["stone-furnace-stack"].name = "stone-furnace-stack"
    data.raw.furnace["stone-furnace-stack"].localised_name = "Stone furnace"
    data.raw.furnace["stone-furnace"].next_upgrade = nil
    data.raw.item["stone-furnace-stack"] = table.deepcopy(data.raw.item["stone-furnace"])
    data.raw.item["stone-furnace-stack"].name = "stone-furnace-stack"
    data.raw.item["stone-furnace-stack"].localised_name = "Stone furnace stack"
    data.raw.item["stone-furnace-stack"].stack_size = 5
    data.raw.item["stone-furnace-stack"].icon = "__fun_mode__/graphics/icons/stone-furnace-stack.png"
    data.raw.item["stone-furnace-stack"].icon_size = 64
    data.raw.item["stone-furnace-stack"].icon_mipmaps = 1
    data.raw.item["stone-furnace-stack"].place_result = "stone-furnace-stack"
    data.raw.furnace["stone-furnace-stack"].minable.result = "stone-furnace-stack"
    data.raw.recipe["stone-furnace"].ingredients = {{type = "item", name = "stone", amount = 120}}
    data.raw.recipe["stone-furnace"].results = {{type = "item", name = "stone-furnace-stack", amount = 1}}
    data.raw.recipe["stone-furnace"].energy_required = 12
    data.raw.recipe["stone-furnace"].localised_name = "Stone furnace stack"
    for _, furnace in pairs({"stone-furnace-stack", "steel-furnace"}) do
        local furnace_graphics = data.raw.furnace[furnace].graphics_set
        -- Too much work to deal with frickin water reflections
        furnace_graphics.water_reflection = nil
        local function change_furnace(tbl)
            if tbl.animation.layers == nil then
                tbl.animation = {
                    layers = tbl.animation
                }
            end

            local old_layers = table.deepcopy(tbl.animation.layers)

            local function make_animation_in_dir(anim_tbl, dir)
                for i = 1, 24 do
                    for _, layer in pairs(old_layers) do
                        table.insert(anim_tbl, shift_visuals(table.deepcopy(layer), {dir[1] * (2 * i - 2), dir[2] * (2 * i - 2)}))
                    end
                end
            end

            tbl.animation = {
                north = {layers = {}},
                east = {layers = {}},
                south = {layers = {}},
                west = {layers = {}}
            }
            make_animation_in_dir(tbl.animation.north.layers, {0, -1})
            make_animation_in_dir(tbl.animation.east.layers, {1, 0})
            make_animation_in_dir(tbl.animation.south.layers, {0, 1})
            make_animation_in_dir(tbl.animation.west.layers, {-1, 0})

            for _, vis in pairs(tbl.working_visualisations) do
                vis.north_animation = {layers = {}}
                vis.west_animation = {layers = {}}
                vis.south_animation = {layers = {}}
                vis.east_animation = {layers = {}}
            end
            for i = 1, 24 do
                for _, vis in pairs(tbl.working_visualisations) do
                    table.insert(vis.north_animation.layers, shift_visuals(table.deepcopy(vis.animation), {0, -1 * (2 * i - 2)}))
                    table.insert(vis.west_animation.layers, shift_visuals(table.deepcopy(vis.animation), {-1 * (2 * i - 2), 0}))
                    table.insert(vis.south_animation.layers, shift_visuals(table.deepcopy(vis.animation), {0, 1 * (2 * i - 2)}))
                    table.insert(vis.east_animation.layers, shift_visuals(table.deepcopy(vis.animation), {1 * (2 * i - 2), 0}))
                end
            end
            for _, vis in pairs(tbl.working_visualisations) do
                vis.animation = nil
            end
        end
        change_furnace(data.raw.furnace[furnace].graphics_set)
        data.raw.furnace[furnace].collision_box = {{-0.7, -46.7}, {0.7, 0.7}}
        data.raw.furnace[furnace].selection_box = {{-0.8, -46.8}, {0.8, 0.8}}

        data.raw.furnace[furnace].energy_usage = "2.16MW"
        data.raw.furnace[furnace].crafting_speed = data.raw.furnace[furnace].crafting_speed * 24

        -- Don't show icon on map because it will be too large
        data.raw.furnace[furnace].show_recipe_icon_on_map = false
    end
    -- Change crafting recipe for steel furnaces
    data.raw.recipe["steel-furnace"].energy_required = 24 * data.raw.recipe["steel-furnace"].energy_required
    data.raw.recipe["steel-furnace"].ingredients = {
        {type = "item", name = "stone-brick", amount = 240},
        {type = "item", name = "steel-plate", amount = 144}
    }
    -- Fix steel plates to be harder again
    data.raw.recipe["steel-plate"].energy_required = 16000
    data.raw.recipe["steel-plate"].ingredients = {{type = "item", name = "iron-plate", amount = 5000}}
    -- Fix recipes that involve furnaces
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            for _, ingredient in pairs(recipe.ingredients) do
                if ingredient.name == "stone-furnace" then
                    ingredient.name = "stone"
                    ingredient.amount = ingredient.amount * 5
                end
            end
        end
    end

    -- 5. Custom achievements

    data:extend({
        {
            type = "produce-achievement",
            name = "produce-water-2",
            localised_name = "Quench your thirst",
            localised_description = "Create water 2.",
            icon = data.raw.fluid["water-2"].icon,
            icon_size = data.raw.fluid["water-2"].icon_size,
            fluid_product = "water-2",
            amount = 1,
            limited_to_one_game = false
        },
        {
            type = "achievement",
            name = "sacrifice-fish",
            localised_name = "The final sacrifice",
            localised_description = "Perform the final fish sacrifice.",
            icon = "__fun_mode__/graphics/sacrifices/lizzy-fish-bowl.png",
            icon_size = 400
        },
        {
            type = "achievement",
            name = "cheeseman",
            localised_name = "Who is cheeseman?",
            localised_description = "Cheeseman is coming.",
            icon = "__core__/graphics/icons/unknown.png",
            icon_size = 64
        },
        {
            type = "build-entity-achievement",
            name = "lab-2",
            localised_name = "Research with... well, a lot",
            localised_description = "Build a lab 2.0.",
            icon = data.raw.lab["lab-2"].icon,
            icon_size = data.raw.lab["lab-2"].icon_size,
            to_build = "lab-2"
        },
        {
            type = "research-achievement",
            name = "very-advanced-oil",
            localised_name = "Soda scientist",
            localised_description = "Research very advanced soda processing.",
            icon = "__fun_mode__/graphics/technology/very-advanced-oil-processing.png",
            icon_size = 256,
            technology = "very-advanced-oil-processing"
        },
        {
            type = "build-entity-achievement",
            name = "adjusted",
            localised_name = "Over-adjusted",
            localised_description = "Place bob, the inserter.",
            icon = "__fun_mode__/graphics/bob_inserter_icon.png",
            icon_size = 64,
            to_build = "bob"
        },
        {
            type = "build-entity-achievement",
            name = "unboiler",
            localised_name = "If only there were a better word...",
            localised_description = "Place an unboiler.",
            icon = "__fun_mode__/graphics/icons/unboiler.png",
            icon_size = 64,
            to_build = "unboiler"
        },
        {
            type = "research-achievement",
            name = "sit",
            localised_name = "Philosopher",
            localised_description = "Sit down and think very hard.",
            icon = data.raw.technology.sit.icon,
            icon_size = data.raw.technology.sit.icon_size,
            technology = "sit"
        },
        {
            type = "build-entity-achievement",
            name = "offshore-assembler",
            localised_name = "Offshore outsourcing",
            localised_description = "Place an offshore assembler.",
            icon = data.raw["assembling-machine"]["assembling-machine-2"].icon,
            icon_size = data.raw["assembling-machine"]["assembling-machine-2"].icon_size,
            to_build = "assembling-machine-2"
        },
        {
            type = "research-achievement",
            name = "swim",
            localised_name = "Swimming lessons",
            localised_description = "Learn how to swim.",
            icon = "__fun_mode__/graphics/legacy/water-o.png",
            icon_size = 32,
            technology = "swim"
        },
        {
            type = "research-with-science-pack-achievement",
            name = "light-green-science",
            localised_name = "Research with light green slurpy juice",
            localised_description = "Research a technology using light green slurpy juice.",
            icon = "__fun_mode__/graphics/achievement/research-with-light-green-science.png",
            icon_size = 256,
            science_pack = "light-green-science",
        },
        {
            type = "research-with-science-pack-achievement",
            name = "dark-green-science",
            localised_name = "Research with dark green slurpy juice",
            localised_description = "Research a technology using dark green slurpy juice.",
            icon = "__fun_mode__/graphics/achievement/research-with-dark-green-science.png",
            icon_size = 256,
            science_pack = "dark-green-science",
        },
        {
            type = "research-with-science-pack-achievement",
            name = "py-science",
            localised_name = "Research with py science",
            localised_description = "Research a technology using py science packs.",
            icon = "__fun_mode__/graphics/achievement/research-with-py-science.png",
            icon_size = 256,
            science_pack = "py-science",
        },
        {
            type = "produce-achievement",
            name = "produce-solid-fuel-refined-5",
            localised_name = "Playing this was a fuelish decision",
            localised_description = "Create your first block of refined refined refined refined refined solid fuel.",
            icon = data.raw.item["solid-fuel-refined-5"].icon,
            icon_size = data.raw.item["solid-fuel-refined-5"].icon_size,
            item_product = "solid-fuel-refined-5",
            amount = 1,
            limited_to_one_game = false
        },
        {
            type = "achievement",
            name = "there-is-a-spoon",
            localised_name = "There is a spoon",
            localised_description = "You took too long.",
            icon = "__fun_mode__/graphics/achievement/spoon-achievement.png",
            icon_size = 256
        },
        {
            type = "achievement",
            name = "friendship",
            localised_name = "Friendship",
            localised_description = "The biggest fun is the friends we didn't sacrifice along the way.",
            icon = data.raw.character.character.icon,
            icon_size = data.raw.character.character.icon_size,
        },
    })
    data.raw["complete-objective-achievement"]["smoke-me-a-kipper-i-will-be-back-for-breakfast"].localised_name = "Have fun"
    data.raw["complete-objective-achievement"]["smoke-me-a-kipper-i-will-be-back-for-breakfast"].localised_description = "Launch the funnest rocket you'll ever launch!"

--------------------------------------------------
-- Electricity
--------------------------------------------------

    -- 1. Belts slow you down drastically, dragging you along

    -- In control

--------------------------------------------------
-- Red science
--------------------------------------------------

    -- 1. More red science technology that just gatekeeps extra red techs

    data:extend({
        {
            type = "technology",
            name = "automation-science-two",
            localised_name = "Slurp more juice",
            localised_description = "Learn how to slurp even more red juice for more technologies.",
            icon = "__fun_mode__/graphics/technology/automation-science-2.png",
            icon_size = 256,
            research_trigger = {
                type = "craft-item",
                item = "electric-mining-drill",
                count = 30
            },
            prerequisites = {
                "automation-science-pack"
            },
            effects = {}
        }
    })
    data.raw.technology.lamp.prerequisites = {
        "automation-science-two"
    }
    data.raw.technology.lamp.unit.count = 40
    data.raw.technology["repair-pack"].prerequisites = {
        "automation-science-two"
    }
    data.raw.technology["longness"].prerequisites = {
        "automation",
        "automation-science-two"
    }
    data.raw.technology["radar"].prerequisites = {
        "automation-science-two"
    }
    data.raw.technology.radar.unit.count = 75
    table.insert(data.raw.technology["heavy-armor"].prerequisites, "automation-science-two")
    -- Walls are already overlooked as is
    --[[data.raw.technology["stone-wall"].prerequisites = {
        "automation-science-two"
    }]]
    -- I think it's not super fun for logistics to be too late
    --[[data.raw.technology["logistics"].prerequisites = {
        "automation-science-two"
    }]]
    data.raw.technology["storage"].prerequisites = {
        "automation-science-two"
    }

--------------------------------------------------
-- Green science
--------------------------------------------------

    -- 1. Light green and dark green science

    data:extend({
        {
            type = "technology",
            name = "light-green-science",
            localised_name = "Light green slurpy juice",
            localised_description = "Get greenlighted to continue.",
            icon = "__fun_mode__/graphics/light-green-science.png",
            icon_size = 64,
            unit = {
                count = 75,
                time = 5,
                ingredients = {
                    {"automation-science-pack", 1}
                }
            },
            prerequisites = {
                "automation-science-pack"
            },
            effects = {
                {type = "unlock-recipe", recipe = "light-green-science"}
            },
            essential = true
        },
        {
            type = "technology",
            name = "dark-green-science",
            localised_name = "Dark green slurpy juice",
            localised_description = "The apex of the study of green.",
            icon = "__fun_mode__/graphics/dark-green-science.png",
            icon_size = 64,
            unit = {
                count = 125,
                time = 5,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1}
                }
            },
            prerequisites = {
                "green",
                "logistic-science-pack"
            },
            effects = {
                {type = "unlock-recipe", recipe = "dark-green-science"}
            },
            essential = true
        },
        {
            type = "recipe",
            name = "light-green-science",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 1}
            },
            results = {
                {type = "item", name = "light-green-science", amount = 1}
            },
            energy_required = 6,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "recipe",
            name = "dark-green-science",
            category = "growing",
            ingredients = {
                {type = "item", name = "rail-signal", amount = 1},
                {type = "item", name = "logistic-science-pack", amount = 1},
                {type = "fluid", name = "distilled-green", amount = 10}
            },
            results = {
                {type = "item", name = "dark-green-science", amount = 1}
            },
            energy_required = 6,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "tool",
            name = "light-green-science",
            localised_name = "Light green slurpy juice",
            subgroup = "green",
            order = "b[logistic-science-pack]-a[light]",
            icon = "__fun_mode__/graphics/light-green-science.png",
            custom_tooltip_fields = 
            {
                {
                    name = {"fun-mode-funtoids.greenosity"},
                    value = {"fun-mode-funtoids.98.9%"}
                },
            },
            icon_size = 64,
            stack_size = 200,
            durability = 1,
            pick_sound = data.raw.tool["automation-science-pack"].pick_sound,
            drop_sound = data.raw.tool["automation-science-pack"].drop_sound,
        },
        {
            type = "tool",
            name = "dark-green-science",
            localised_name = "Dark green slurpy juice",
            subgroup = "green",
            order = "b[logistic-science-pack]-c[dark]",
            icon = "__fun_mode__/graphics/dark-green-science.png",
            custom_tooltip_fields = 
            {
                {
                    name = {"fun-mode-funtoids.greenosity"},
                    value = {"fun-mode-funtoids.100.9%"}
                },
            },
            icon_size = 64,
            stack_size = 200,
            durability = 1,
            pick_sound = data.raw.tool["automation-science-pack"].pick_sound,
            drop_sound = data.raw.tool["automation-science-pack"].drop_sound,
        },
        {
            type = "fluid",
            name = "distilled-green",
            localised_name = "Distilled green",
            icon = "__fun_mode__/graphics/distilled-green.png",
            icon_size = 64,
            default_temperature = 15,
            base_color = {r = 0, g = 255, b = 0},
            flow_color = {r = 0, g = 255, b = 0}
        },
        {
            type = "item-subgroup",
            name = "green",
            group = "intermediate-products",
            order = "a"
        },
        {
            -- TODO: Put in own subgroup
            type = "recipe",
            name = "color-separation",
            localised_name = "Color separation",
            subgroup = "green",
            category = "growing",
            ingredients = {
                {type = "item", name = "solid-steam", amount = 1}
            },
            results = {
                -- TODO
                --{type = "fluid", name = "distilled-red", amount = 5},
                --{type = "fluid", name = "distilled-blue", amount = 5},
                {type = "fluid", name = "distilled-green", amount = 20}
            },
            energy_required = 2,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "recipe",
            name = "kr-greenhouse",
            subgroup = "green",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 50},
                {type = "item", name = "stone", amount = 20}
            },
            results = {
                {type = "item", name = "kr-greenhouse", amount = 1}
            },
            enabled = false
        },
        {
            type = "item-group",
            name = "green",
            localised_name = "Green",
            order = "da",
            icon = "__fun_mode__/graphics/green.png",
            icon_size = 64
        }
    })
    data.raw.recipe["logistic-science-pack"].ingredients = {
        {type = "item", name = "light-green-science", amount = 1},
        {type = "item", name = "steel-plate", amount = 1}
    }
    data.raw.technology["logistic-science-pack"].localised_description = "You're on the edge of something green."
    data.raw.technology.green.localised_name = "Greener greens"
    data.raw.technology.green.localised_description = "Figure out how to make things greener."
    -- Prerequisites
    data.raw.technology["automation-2"].prerequisites = {
        "light-green-science",
        "steel-processing"
    }
    data.raw.technology["automation-2"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["solar-energy"].prerequisites = {
        "light-green-science",
        "steel-processing"
    }
    data.raw.technology["solar-energy"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["fluid-handling"].prerequisites = {
        "light-green-science",
        "steel-processing"
    }
    data.raw.technology["fluid-handling"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["sacrifices"].prerequisites = {
        "light-green-science"
    }
    data.raw.technology["sacrifices"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["toolbelt"].prerequisites = {
        "light-green-science"
    }
    data.raw.technology["toolbelt"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["circuit-network"].prerequisites = {
        "light-green-science"
    }
    data.raw.technology["circuit-network"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["research-speed-1"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["green"].prerequisites = {
        "light-green-science",
        "unboiler"
    }
    data.raw.technology["green"].unit.ingredients = {
        {"light-green-science", 1}
    }
    -- Gate prerequisites already okay, just need to change science packs
    data.raw.technology["gate"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"light-green-science", 1}
    }
    data.raw.technology["logistic-science-pack"].prerequisites = {
        "light-green-science",
        "steel-processing"
    }
    data.raw.technology["logistic-science-pack"].unit = {
        count = 150,
        time = 5,
        ingredients = {
            {"automation-science-pack", 1},
            {"light-green-science", 1}
        }
    }
    -- Now for medium green
    data.raw.technology["engine"].prerequisites = {
        "logistic-science-pack",
        "unboiler"
    }
    data.raw.technology["military-2"].prerequisites = {
        "logistic-science-pack"
    }
    data.raw.technology["military-2"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
    }
    data.raw.technology["physical-projectile-damage-2"].prerequisites = {
        "physical-projectile-damage-1"
    }
    data.raw.technology["weapon-shooting-speed-2"].prerequisites = {
        "weapon-shooting-speed-1"
    }
    data.raw.technology["oil-gathering"].prerequisites = {
        "fluid-handling",
        "logistic-science-pack"
    }
    data.raw.technology["railway"].prerequisites = {
        "engine"
    }
    data.raw.technology["automobilism"].prerequisites = {
        "engine"
    }
    data.raw.technology["fluid-wagon"].prerequisites = {
        "fluid-handling",
        "railway"
    }
    data.raw.technology["research-speed-2"].prerequisites = {
        "research-speed-1"
    }
    -- Dark green
    table.insert(data.raw.technology["green"].effects, {type = "unlock-recipe", recipe = "color-separation"})
    table.insert(data.raw.technology["green"].effects, {type = "unlock-recipe", recipe = "kr-greenhouse"})
    data.raw.technology["military-science-pack"].prerequisites = {
        "stone-wall",
        "military-2",
        "dark-green-science"
    }
    table.insert(data.raw.technology["flammables"].prerequisites, "dark-green-science")
    table.insert(data.raw.technology["plastics"].prerequisites, "dark-green-science")
    table.insert(data.raw.technology["sulfur-processing"].prerequisites, "dark-green-science")
    data.raw.technology["military-science-pack"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1}
    }
    -- After oil, it's all dark green
    local techs_open_nodes = {"oil-processing"}
    local techs_to_replace = {["oil-processing"] = true}
    while #techs_open_nodes > 0 do
        local node = techs_open_nodes[#techs_open_nodes]
        table.remove(techs_open_nodes, #techs_open_nodes)
        for _, technology in pairs(data.raw.technology) do
            if technology.prerequisites ~= nil then
                for _, prerequisite in pairs(technology.prerequisites) do
                    if not techs_to_replace[technology.name] and prerequisite == node then
                        table.insert(techs_open_nodes, technology.name)
                        techs_to_replace[technology.name] = true
                    end
                end
            end
        end
    end
    for tech_to_replace, _ in pairs(techs_to_replace) do
        if data.raw.technology[tech_to_replace].unit then
            for _, ing in pairs(data.raw.technology[tech_to_replace].unit.ingredients) do
                if ing[1] == "logistic-science-pack" then
                    ing[1] = "dark-green-science"
                end
            end
        end
    end
    -- Add to lab slots
    table.insert(data.raw.lab.lab.inputs, "light-green-science")
    table.insert(data.raw.lab.lab.inputs, "dark-green-science")
    local ind_of_lab_2_logistic = nil
    for ind, input in pairs(data.raw.lab["lab-2"].inputs) do
        if input == "logistic-science-pack" then
            ind_of_lab_2_logistic = ind
        end
    end
    -- Lab 2 only has slots for the darkest green
    table.remove(data.raw.lab["lab-2"].inputs, ind_of_lab_2_logistic)
    table.insert(data.raw.lab["lab-2"].inputs, 2, "dark-green-science")
    -- Krastorio2 greenhouse
    require("krastorio/greenhouse")
    data.raw.recipe.lubricant.category = "growing"
    data.raw.recipe.lubricant.subgroup = "green"
    data.raw.item.lubricant.subgroup = "green"
    -- No greenhouse requirement before logistic science
    --data.raw.recipe["logistic-science-pack"].category = "growing"
    data.raw.tool["logistic-science-pack"].order = "b[logistic-science-pack]-b[medium]"
    data.raw.item["electronic-circuit"].subgroup = "green"
    data.raw.tool["light-green-science"].subgroup = "green"
    data.raw.tool["logistic-science-pack"].subgroup = "green"
    data.raw.tool["dark-green-science"].subgroup = "green"
    data.raw.item["bulk-inserter"].subgroup = "green"
    data.raw.recipe["bulk-inserter"].category = "growing"
    data.raw.item["buffer-chest"].subgroup = "green"
    data.raw.recipe["buffer-chest"].category = "growing"
    data.raw.item["rail-signal"].subgroup = "green"
    data.raw.item["selector-combinator"].subgroup = "green"
    data.raw.recipe["selector-combinator"].category = "growing"
    data.raw.item["pumpjack"].subgroup = "green"
    data.raw.item["lubricant-barrel"].subgroup = "green"
    data.raw.recipe["lubricant-barrel"].subgroup = "green"
    data.raw.recipe["empty-lubricant-barrel"].subgroup = "green"
    data.raw.item["night-vision-equipment"].subgroup = "green"
    data.raw.recipe["night-vision-equipment"].category = "growing"
    data.raw.module["efficiency-module"].subgroup = "green"
    data.raw.module["efficiency-module-2"].subgroup = "green"
    data.raw.module["efficiency-module-3"].subgroup = "green"
    data.raw.recipe["efficiency-module"].category = "growing"
    data.raw.recipe["efficiency-module-2"].category = "growing"
    data.raw.recipe["efficiency-module-3"].category = "growing"
    data.raw.item["assembling-machine-3"].subgroup = "green"
    data.raw.recipe["assembling-machine-3"].category = "growing"
    data.raw["item-subgroup"]["uranium-processing"].order = "ab"
    data.raw.item["uranium-ore"].subgroup = "uranium-processing"
    data.raw.ammo["uranium-rounds-magazine"].subgroup = "uranium-processing"
    data.raw.ammo["uranium-cannon-shell"].subgroup = "uranium-processing"
    data.raw.ammo["explosive-uranium-cannon-shell"].subgroup = "uranium-processing"
    data.raw.item["fission-reactor-equipment"].subgroup = "uranium-processing"
    data.raw.ammo["atomic-bomb"].subgroup = "uranium-processing"
    data.raw.item["centrifuge"].subgroup = "uranium-processing"
    data.raw["item-subgroup"]["green"].group = "green"
    data.raw["item-subgroup"]["uranium-processing"].group = "green"
    -- Steel is now green to fit with being in green science
    data.raw.item["steel-plate"].icon = "__fun_mode__/graphics/icons/steel-plate.png"
    data.raw.item["steel-plate"].subgroup = "green"
    data.raw.item["steel-plate"].localised_name = "Greel"
    data.raw.recipe["sacrifice-steel-plate"].localised_name = "Sacrifice greel plates"
    data.raw.technology["steel-processing"].icon = "__fun_mode__/graphics/technology/steel.png"
    -- Change uranium magazines to use distilled green
    data.raw.recipe["uranium-rounds-magazine"].ingredients = {
        {type = "item", name = "piercing-rounds-magazine", amount = 1},
        {type = "fluid", name = "distilled-green", amount = 1},
    }
    data.raw.recipe["uranium-rounds-magazine"].category = "growing"
    data.raw.technology["uranium-ammo"].unit.count = 200
    data.raw.recipe["uranium-cannon-shell"].ingredients = {
        {type = "item", name = "cannon-shell", amount = 1},
        {type = "fluid", name = "distilled-green", amount = 5},
    }
    data.raw.recipe["explosive-uranium-cannon-shell"].ingredients = {
        {type = "item", name = "explosive-cannon-shell", amount = 1},
        {type = "fluid", name = "distilled-green", amount = 5},
    }
    data.raw.recipe["uranium-cannon-shell"].category = "growing"
    data.raw.recipe["explosive-uranium-cannon-shell"].category = "growing"

    -- 2. Unboiler

    log(serpent.block(data.raw.boiler.boiler))
    data:extend({
        {
            type = "item",
            name = "solid-steam",
            localised_name = "Solid steam",
            subgroup = "fluid-recipes",
            order = "zz",
            icon = data.raw.fluid.steam.icon,
            icon_size = data.raw.fluid.steam.icon_size,
            stack_size = 200
        },
        {
            type = "recipe",
            name = "solid-steam",
            category = "unboiling",
            ingredients = {
                {type = "fluid", name = "steam", amount = 60}
            },
            results = {
                {type = "item", name = "solid-steam", amount = 1}
            },
            energy_required = 4,
            enabled = false
        },
        {
            -- TODO:
            --   * Corpse
            --   * Dying explosion
            --   * Sounds?
            type = "assembling-machine",
            name = "unboiler",
            localised_name = "Unboiler",
            localised_description = "If only there were a better word for this.",
            circuit_wire_max_distance = 9,
            energy_usage = "450kW",
            crafting_speed = 1,
            crafting_categories = {"unboiling"},
            minable = {
                mining_time = 0.2,
                result = "unboiler"
            },
            placeable_by = {item = "unboiler", count = 1},
            icon = "__fun_mode__/graphics/icons/unboiler.png",
            icon_size = 64,
            max_health = 500,
            module_slots = 4,
            allowed_effects = {"speed", "consumption", "pollution", "quality"},
            energy_source = {
                type = "burner",
                fuel_inventory_size = 1,
                burnt_inventory_size = 3,
                emissions_per_minute = {
                    ["pollution"] = 5
                },
                light_flicker = data.raw.boiler.boiler.energy_source.light_flicker,
                smoke = data.raw.boiler.boiler.energy_source.smoke
            },
            fluid_boxes = {
                data.raw.boiler.boiler.fluid_box
            },
            graphics_set = {
                animation = {
                    north = table.deepcopy(data.raw.boiler.boiler.pictures.north.structure),
                    east = table.deepcopy(data.raw.boiler.boiler.pictures.east.structure),
                    south = table.deepcopy(data.raw.boiler.boiler.pictures.south.structure),
                    west = table.deepcopy(data.raw.boiler.boiler.pictures.west.structure)
                }
            },
            collision_box = data.raw.boiler.boiler.collision_box,
            selection_box = data.raw.boiler.boiler.selection_box,
            corpse = "boiler-remnants",
            dying_explosion = "boiler-explosion",
            damaged_trigger_effect = {
                damage_type_filters = "fire",
                entity_name = "spark-explosion",
                offset_deviation = {
                    {
                        -0.5,
                        -0.5
                    },
                    {
                        0.5,
                        0.5
                    }
                },
                offsets = {
                    {
                        0,
                        1
                    }
                },
                type = "create-entity"
            },
            flags = {
                "placeable-neutral",
                "player-creation"
            },
            open_sound = {
                filename = "__base__/sound/open-close/steam-open.ogg",
                volume = 0.56999999999999993
            },
            resistances = {
                {
                    percent = 90,
                    type = "fire"
                },
                {
                    percent = 30,
                    type = "explosion"
                },
                {
                    percent = 30,
                    type = "impact"
                }
            },
            water_reflection = {
                orientation_to_variation = true,
                pictures = {
                    filename = "__base__/graphics/entity/boiler/boiler-reflection.png",
                    height = 32,
                    priority = "extra-high",
                    scale = 5,
                    shift = {
                        0.15625,
                        0.9375
                    },
                    variation_count = 4,
                    width = 28
                }
            },
        },
        {
            type = "recipe-category",
            name = "unboiling"
        },
        {
            type = "technology",
            name = "unboiler",
            localised_name = "Unboiling",
            localised_description = "Study how to turn gases and fluids back into solids.",
            icon = "__fun_mode__/graphics/icons/unboiler.png",
            icon_size = 64,
            unit = {
                count = 50,
                time = 15,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"light-green-science", 1}
                }
            },
            prerequisites = {
                "light-green-science"
            },
            effects = {
                {type = "unlock-recipe", recipe = "unboiler"},
                {type = "unlock-recipe", recipe = "solid-steam"}
            }
        },
        {
            type = "recipe",
            name = "unboiler",
            ingredients = {
                {type = "item", name = "boiler", amount = 1},
                {type = "item", name = "copper-plate", amount = 20}
            },
            results = {
                {type = "item", name = "unboiler", amount = 1}
            },
            enabled = false
        },
        {
            type = "item",
            name = "unboiler",
            localised_name = "Unboiler",
            subgroup = "energy",
            order = "b[steam-power]-c[solid-steam-engine]",
            icon = "__fun_mode__/graphics/icons/unboiler.png",
            icon_size = 64,
            stack_size = 50,
            place_result = "unboiler",
            pick_sound = data.raw.tool.boiler.pick_sound,
            drop_sound = data.raw.tool.boiler.drop_sound,
        }
    })
    -- Fixes
    data.raw["assembling-machine"].unboiler.fluid_boxes[1].production_type = "input"
    data.raw["assembling-machine"].unboiler.fluid_boxes[1].pipe_connections[1].flow_direction = "input"
    data.raw["assembling-machine"].unboiler.fluid_boxes[1].filter = nil
    data.raw["assembling-machine"].unboiler.graphics_set.animation.north.layers[1].filename = "__fun_mode__/graphics/entity/unboiler/north.png"
    data.raw["assembling-machine"].unboiler.graphics_set.animation.east.layers[1].filename = "__fun_mode__/graphics/entity/unboiler/east.png"
    data.raw["assembling-machine"].unboiler.graphics_set.animation.south.layers[1].filename = "__fun_mode__/graphics/entity/unboiler/south.png"
    data.raw["assembling-machine"].unboiler.graphics_set.animation.west.layers[1].filename = "__fun_mode__/graphics/entity/unboiler/west.png"
    -- Engines take solid steam
    table.insert(data.raw.recipe["engine-unit"].ingredients, {type = "item", name = "solid-steam", amount = 1})

    -- 3. Fluid unlock rearrangment

    data.raw.recipe["pipe-to-ground"].enabled = false
    remove_tech_recipe_unlock(data.raw.technology["steam-power"], "pipe-to-ground")
    data.raw.technology["fluid-handling"].effects = {
        {type = "unlock-recipe", recipe = "pipe-to-ground"},
        {type = "unlock-recipe", recipe = "storage-tank"},
        {type = "unlock-recipe", recipe = "pump"},
        {type = "unlock-recipe", recipe = "barrel"},
    }

    -- 4. Locomotives actively try to kill you

    -- Moved to non-beta

    -- 5. Green-ades

    data.raw.capsule.grenade.localised_name = "Green-ade"
    table.insert(data.raw.technology["military-2"].prerequisites, "green")
    data.raw.capsule.grenade.subgroup = "green"
    data.raw.recipe.grenade.category = "growing"
    data.raw.recipe.grenade.ingredients = {
        {type = "item", name = "coal", amount = 10},
        {type = "fluid", name = "distilled-green", amount = 10}
    }
    for i = 1, 3 do
        data.raw.explosion["grenade-explosion"].animations[i].filename = "__fun_mode__/graphics/entity/greenade/medium-explosion-" .. tostring(i) .. ".png"
    end

    -- 6. The character has to be green while doing green research

    -- In control

    -- 7. Toolbelt 2 after dark green science

    -- Moved to non-beta
    data.raw.technology["toolbelt-2"].prerequisites = {"toolbelt"}
    data.raw.technology["toolbelt-2"].unit.ingredients[2][1] = "dark-green-science"

    -- 8. Extra sacrifices

    data:extend({
        {
            type = "recipe",
            name = "sacrifice-solid-steam",
            localised_name = "Sacrifice solid steam",
            subgroup = "sacrifices",
            order = "b",
            icon = "__fun_mode__/graphics/sacrifices/steam.png",
            icon_size = 64,
            category = "crafting-by-hand",
            ingredients = {
                {type = "item", name = "solid-steam", amount = 1000}
            },
            results = {{type = "item", name = "coin", amount = 1}},
            energy_required = 2,
            enabled = false
        },
        {
            type = "recipe",
            name = "sacrifice-car",
            localised_name = "Sacrifice car",
            subgroup = "sacrifices",
            order = "d",
            icon = "__fun_mode__/graphics/sacrifices/car.png",
            icon_size = 64,
            category = "crafting-by-hand",
            ingredients = {
                {type = "item", name = "car", amount = 20}
            },
            results = {{type = "item", name = "coin", amount = 1}},
            energy_required = 2,
            enabled = false
        },
        {
            type = "recipe",
            name = "sacrifice-light-green-science",
            localised_name = "Sacrifice light green slurpy juice",
            subgroup = "sacrifices",
            order = "a",
            icon = "__fun_mode__/graphics/sacrifices/light-green-science.png",
            icon_size = 64,
            category = "crafting-by-hand",
            ingredients = {
                {type = "item", name = "light-green-science", amount = 500}
            },
            results = {{type = "item", name = "coin", amount = 1}},
            energy_required = 2,
            enabled = false
        },
        {
            type = "recipe",
            name = "sacrifice-widget-2",
            localised_name = "Sacrifice micro grip fastening",
            subgroup = "sacrifices",
            order = "a",
            icon = "__fun_mode__/graphics/sacrifices/widget-2.png",
            icon_size = 64,
            category = "crafting-by-hand",
            ingredients = {
                {type = "item", name = "widget-2", amount = 500}
            },
            results = {{type = "item", name = "coin", amount = 1}},
            energy_required = 2,
            enabled = false
        },
        {
            type = "recipe",
            name = "sacrifice-dead-body",
            localised_name = "Sacrifice dead body",
            subgroup = "sacrifices",
            order = "a",
            icon = "__fun_mode__/graphics/sacrifices/dead-body.png",
            icon_size = 64,
            category = "crafting-by-hand",
            ingredients = {
                {type = "item", name = "character-corpse", amount = 1}
            },
            results = {{type = "item", name = "coin", amount = 1}},
            energy_required = 2,
            enabled = false
        }
    })
    table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = "sacrifice-solid-steam"})
    table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = "sacrifice-car"})
    table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = "sacrifice-light-green-science"})
    table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = "sacrifice-widget-2"})
    table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = "sacrifice-dead-body"})

    -- 9. Solid steam engine

    data.raw.item["solid-steam"].fuel_value = "10MJ"
    --data.raw.item["solid-steam"].fuel_acceleration_multiplier = 3
    --data.raw.item["solid-steam"].fuel_top_speed_multiplier = 0.7
    data.raw.item["solid-steam"].fuel_category = "steam"
    data:extend({
        {
            type = "fuel-category",
            name = "steam",
            localised_name = "Steam"
        },
        {
            type = "burner-generator",
            name = "solid-steam-engine",
            localised_name = "Solid steam power",
            energy_source = {
                type = "electric",
                usage_priority = "secondary-output"
            },
            burner = {
                type = "burner",
                fuel_inventory_size = 1,
                smoke = table.deepcopy(data.raw.generator["steam-engine"].smoke),
                fuel_categories = {"steam"}
            },
            animation = {
                north = {
                    filename = "__fun_mode__/graphics/entity/solid-steam-engine/vertical.png",
                    height = 391,
                    width = 225,
                    line_length = 8,
                    scale = 0.5,
                    frame_count = 32
                },
                south = {
                    filename = "__fun_mode__/graphics/entity/solid-steam-engine/vertical.png",
                    height = 391,
                    width = 225,
                    line_length = 8,
                    scale = 0.5,
                    frame_count = 32
                },
                west = {
                    filename = "__fun_mode__/graphics/entity/solid-steam-engine/horizontal.png",
                    height = 257,
                    width = 352,
                    line_length = 8,
                    scale = 0.5,
                    frame_count = 32
                },
                east = {
                    filename = "__fun_mode__/graphics/entity/solid-steam-engine/horizontal.png",
                    height = 257,
                    width = 352,
                    line_length = 8,
                    scale = 0.5,
                    frame_count = 32
                }
            },
            max_power_output = "3.6MW",
            max_health = 800,
            icon = "__fun_mode__/graphics/icons/solid-steam-engine.png",
            icon_size = 64,
            collision_box = {
                {-1.25, -2.35},
                {1.25, 2.35}
            },
            selection_box = {
                {-1.5, -2.5},
                {1.5, 2.5}
            },
            flags = {
                "placeable-neutral",
                "player-creation"
            },
            minable = {
                mining_time = 0.3,
                result = "solid-steam-engine"
            },
            alert_icon_shift = table.deepcopy(data.raw.generator["steam-engine"].alert_icon_shift),
            corpse = "steam-engine-remnants",
            dying_explosion = "steam-engine-explosion",
            damage_trigger_effect = table.deepcopy(data.raw.generator["steam-engine"].damaged_trigger_effect),
            resistances = table.deepcopy(data.raw.generator["steam-engine"].resistances),
            working_sound = table.deepcopy(data.raw.generator["steam-engine"].working_sound)
        },
        {
            type = "item",
            name = "solid-steam-engine",
            localised_name = "Solid steam engine",
            subgroup = "energy",
            order = "b[steam-power]-d[solid-steam-engine]",
            icon = "__fun_mode__/graphics/icons/solid-steam-engine.png",
            icon_size = 64,
            place_result = "solid-steam-engine",
            stack_size = 10
        },
        {
            type = "recipe",
            name = "solid-steam-engine",
            ingredients = {
                {type = "item", name = "pipe", amount = 5},
                {type = "item", name = "iron-gear-wheel", amount = 10},
                {type = "item", name = "iron-plate", amount = 50}
            },
            results = {
                {type = "item", name = "solid-steam-engine", amount = 1}
            },
            enabled = false
        },
        {
            type = "technology",
            name = "solid-steam-engine",
            localised_name = "Solid steam engine",
            localised_description = "It's well-known that solids are denser than fluids. This applies to energetic potential as well.",
            icon = "__fun_mode__/graphics/icons/solid-steam-engine.png",
            icon_size = 64,
            prerequisites = {
                "unboiler",
                "logistic-science-pack"
            },
            unit = {
                count = 100,
                time = 30,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1}
                }
            },
            effects = {
                {type = "unlock-recipe", recipe = "solid-steam-engine"}
            }
        }
    })

    -- 10. Iron plate prod bonus research

    -- Moved to non-beta
    data.raw.technology["iron-plate-productivity"].prerequisites = {"light-green-science", "mercy"}
    data.raw.technology["iron-plate-productivity"].unit.ingredients[1][1] = "light-green-science"
    
    -- 11. Different types of engines

    for _, engine_type in pairs({{"locomotive", "Locomotive engine"}, {"car", "Car engine"}, {"artillery-wagon", "Artillery wagon engine"}, --[[{"tank", "Tank engine"},]] {"pump", "Pump engine"}, {"chemical-science-pack", "Conductive engine"}, {"electric-engine-unit", "Chemical engine"}}) do
        data.raw.item[engine_type[1] .. "-engine"] = table.deepcopy(data.raw.item["engine-unit"])
        data.raw.item[engine_type[1] .. "-engine"].name = engine_type[1] .. "-engine"
        data.raw.item[engine_type[1] .. "-engine"].localised_name = engine_type[2]
        data.raw.recipe[engine_type[1] .. "-engine"] = table.deepcopy(data.raw.recipe["engine-unit"])
        data.raw.recipe[engine_type[1] .. "-engine"].name = engine_type[1] .. "-engine"
        data.raw.recipe[engine_type[1] .. "-engine"].results[1].name = engine_type[1] .. "-engine"
        table.insert(data.raw.technology.engine.effects, {type = "unlock-recipe", recipe = engine_type[1] .. "-engine"})
        for _, ingredient in pairs(data.raw.recipe[engine_type[1]].ingredients) do
            if ingredient.name == "engine-unit" then
                ingredient.name = engine_type[1] .. "-engine"
            end
        end
    end
    -- Call the regular engine unit the spidertron engine, it actually isn't used for anything
    data.raw.item["engine-unit"].localised_name = "Spidertron engine"
    data.raw.item["engine-unit"].localised_description = "In reality, the spidertron has no engine, so this is useless."

    -- 12. Widgets

    data:extend({
        {
            type = "item-subgroup",
            name = "widget",
            localised_name = "widgets",
            order = "ga",
            group = "intermediate-products"
        },
        {
            type = "item",
            name = "widget-1",
            localised_name = "Clouffard hose restrictor",
            subgroup = "widget",
            order = "a[widget]-a",
            icon = "__fun_mode__/graphics/icons/widget-1.png",
            icon_size = 64,
            stack_size = 50
        },
        {
            type = "item",
            name = "widget-2",
            localised_name = "Micro grip fastening",
            subgroup = "widget",
            order = "a[widget]-b",
            icon = "__fun_mode__/graphics/icons/widget-2.png",
            icon_size = 64,
            stack_size = 50
        },
        {
            type = "item",
            name = "widget-2",
            localised_name = "Micro grip fastening",
            subgroup = "widget",
            order = "a[widget]-b",
            icon = "__fun_mode__/graphics/icons/widget-2.png",
            icon_size = 64,
            stack_size = 50
        },
        {
            type = "item",
            name = "widget-3",
            localised_name = "Flat-headed box gizmo",
            subgroup = "widget",
            order = "a[widget]-c",
            icon = "__fun_mode__/graphics/icons/widget-3.png",
            icon_size = 64,
            stack_size = 50
        },
        {
            type = "item",
            name = "widget-4",
            localised_name = "Systematic heap filter",
            subgroup = "widget",
            order = "a[widget]-d",
            icon = "__fun_mode__/graphics/icons/widget-4.png",
            icon_size = 64,
            stack_size = 50
        },
        {
            type = "item",
            name = "widget-5",
            localised_name = "MRI oxiclip finger sensor",
            subgroup = "widget",
            order = "a[widget]-e",
            icon = "__fun_mode__/graphics/icons/widget-5.png",
            icon_size = 64,
            stack_size = 50
        },
        { -- Light green science
          -- To be used in: steel furnaces (instead of steel), pumpjacks, lunar panels, circuit network stuff, locomotive, cargo wagon, assembler 2, train stop, red splitter
            type = "recipe",
            name = "widget-1",
            category = "advanced-crafting",
            ingredients = {
                {type = "item", name = "iron-stick", amount = 2},
                {type = "item", name = "iron-gear-wheel", amount = 2},
                {type = "item", name = "steel-plate", amount = 1}
            },
            results = {
                {type = "item", name = "widget-1", amount = 1}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        { -- Logistic science
          -- To be used in: accumulators, solid steam engine, oil refineries (instead of bricks), steel furnaces (instead of bricks), fluid wagon
            type = "recipe",
            name = "widget-2",
            category = "advanced-crafting",
            ingredients = {
                {type = "item", name = "iron-stick", amount = 1},
                {type = "item", name = "iron-plate", amount = 1},
                {type = "item", name = "stone-wall", amount = 1}
            },
            results = {
                {type = "item", name = "widget-2", amount = 1}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        { -- Chemical science
          -- To be used in: bots, electric furnaces, power armor, centrifuges, tank, lab-2, roboport, module 2's
            type = "recipe",
            name = "widget-3",
            category = "advanced-crafting",
            ingredients = {
                {type = "item", name = "battery", amount = 1},
                {type = "item", name = "iron-plate", amount = 2}
            },
            results = {
                {type = "item", name = "widget-3", amount = 1}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        { -- Py science
          -- To be used in: power armor mk2, artillery, spidertron, personal roboport mk2
            type = "recipe",
            name = "widget-4",
            category = "advanced-crafting",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 40}
            },
            results = {
                {type = "item", name = "widget-4", amount = 1}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        { -- Utility science
          -- To be used in: logistic chests, satellite, assembler 3, express splitter
            type = "recipe",
            name = "widget-5",
            category = "advanced-crafting",
            ingredients = {
                {type = "item", name = "express-transport-belt", amount = 1},
                {type = "item", name = "cluster-grenade", amount = 1}
            },
            results = {
                {type = "item", name = "widget-5", amount = 1}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "technology",
            name = "widget-1",
            localised_name = "Widgets 1",
            localised_description = "You feel like a few more doohickeys in your life would be great.",
            icon = "__fun_mode__/graphics/icons/widget-1.png",
            icon_size = 64,
            prerequisites = {
                "light-green-science"
            },
            unit = {
                count = 50,
                time = 15,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"light-green-science", 1}
                }
            },
            effects = {
                {type = "unlock-recipe", recipe = "widget-1"}
            }
        },
        {
            type = "technology",
            name = "widget-2",
            localised_name = "Widgets 2",
            localised_description = "More gizmos means more fun.",
            icon = "__fun_mode__/graphics/icons/widget-2.png",
            icon_size = 64,
            prerequisites = {
                "logistic-science-pack",
                "widget-1"
            },
            unit = {
                count = 50,
                time = 30,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1}
                }
            },
            effects = {
                {type = "unlock-recipe", recipe = "widget-2"}
            }
        },
        {
            type = "technology",
            name = "widget-3",
            localised_name = "Widgets 3",
            localised_description = "This thingymabobber will the be last, I promise!",
            icon = "__fun_mode__/graphics/icons/widget-3.png",
            icon_size = 64,
            prerequisites = {
                "chemical-science-pack",
                "widget-2"
            },
            unit = {
                count = 50,
                time = 45,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"chemical-science-pack", 1}
                }
            },
            effects = {
                {type = "unlock-recipe", recipe = "widget-3"}
            }
        },
        {
            type = "technology",
            name = "widget-4",
            localised_name = "Widgets 4",
            localised_description = "Oh, but really, how could you stop making thingymabobbers? Watching cogs and wheels spinning is your favorite pasttime.",
            icon = "__fun_mode__/graphics/icons/widget-4.png",
            icon_size = 64,
            prerequisites = {
                "py-science",
                "widget-3"
            },
            unit = {
                count = 50,
                time = 60,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"chemical-science-pack", 1},
                    {"py-science", 1},
                }
            },
            effects = {
                {type = "unlock-recipe", recipe = "widget-4"}
            }
        },
        {
            type = "technology",
            name = "widget-5",
            localised_name = "Widgets 5",
            localised_description = "The ultimate gizmo.",
            icon = "__fun_mode__/graphics/icons/widget-5.png",
            icon_size = 64,
            prerequisites = {
                "utility-science-pack",
                "widget-4"
            },
            unit = {
                count = 50,
                time = 75,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    -- py-science is added automatically later
                    --{"py-science", 1}
                }
            },
            effects = {
                {type = "unlock-recipe", recipe = "widget-5"}
            }
        }
    })
    data.raw.recipe["steel-furnace"].ingredients = {
        {type = "item", name = "widget-1", amount = 24},
        {type = "item", name = "widget-2", amount = 24}
    }
    table.insert(data.raw.recipe["pumpjack"].ingredients, {type = "item", name = "widget-1", amount = 5})
    table.insert(data.raw.recipe["solar-panel"].ingredients, {type = "item", name = "widget-1", amount = 3})
    -- circuit network stuff (assume it's all items)
    for _, item in pairs(data.raw.item) do
        if item.subgroup == "circuit-network" then
            table.insert(data.raw.recipe[item.name].ingredients, {type = "item", name = "widget-1", amount = 1})
        end
    end
    table.insert(data.raw.recipe["locomotive"].ingredients, {type = "item", name = "widget-1", amount = 5})
    table.insert(data.raw.recipe["cargo-wagon"].ingredients, {type = "item", name = "widget-1", amount = 2})
    for _, ingredient in pairs(data.raw.recipe["assembling-machine-2"].ingredients) do
        if ingredient.name == "steel-plate" then
            ingredient.name = "widget-1"
        end
    end
    table.insert(data.raw.recipe["train-stop"].ingredients, {type = "item", name = "widget-1", amount = 1})
    table.insert(data.raw.recipe["fast-splitter"].ingredients, {type = "item", name = "widget-1", amount = 1})
    table.insert(data.raw.recipe["accumulator"].ingredients, {type = "item", name = "widget-2", amount = 1})
    table.insert(data.raw.recipe["solid-steam-engine"].ingredients, {type = "item", name = "widget-2", amount = 10})
    for _, ingredient in pairs(data.raw.recipe["oil-refinery"].ingredients) do
        if ingredient.name == "stone-brick" then
            ingredient.name = "widget-2"
            ingredient.amount = 4
        end
    end
    table.insert(data.raw.recipe["fluid-wagon"].ingredients, {type = "item", name = "widget-2", amount = 3})
    table.insert(data.raw.recipe["construction-robot"].ingredients, {type = "item", name = "widget-3", amount = 1})
    table.insert(data.raw.recipe["logistic-robot"].ingredients, {type = "item", name = "widget-3", amount = 1})
    data.raw.recipe["electric-furnace"].ingredients = {
        {type = "item", name = "widget-1", amount = 3},
        {type = "item", name = "widget-2", amount = 2},
        {type = "item", name = "widget-3", amount = 1}
    }
    table.insert(data.raw.recipe["power-armor"].ingredients, {type = "item", name = "widget-3", amount = 50})
    table.insert(data.raw.recipe["centrifuge"].ingredients, {type = "item", name = "widget-3", amount = 15})
    -- Tank recipe should be massively simpler so that LDS isn't *too* annoying
    data.raw.recipe["tank"].ingredients = {{type = "item", name = "widget-3", amount = 10}}
    table.insert(data.raw.recipe["lab-2"].ingredients, {type = "item", name = "widget-3", amount = 3})
    table.insert(data.raw.recipe["roboport"].ingredients, {type = "item", name = "widget-3", amount = 2})
    table.insert(data.raw.recipe["discharge-defense-equipment"].ingredients, {type = "item", name = "widget-3", amount = 20})
    table.insert(data.raw.recipe["beacon"].ingredients, {type = "item", name = "widget-3", amount = 3})
    table.insert(data.raw.recipe["artillery-shell"].ingredients, {type = "item", name = "widget-4", amount = 1})
    table.insert(data.raw.recipe["spidertron"].ingredients, {type = "item", name = "widget-4", amount = 50})
    table.insert(data.raw.recipe["personal-roboport-mk2-equipment"].ingredients, {type = "item", name = "widget-4", amount = 10})
    table.insert(data.raw.recipe["power-armor-mk2"].ingredients, {type = "item", name = "widget-4", amount = 25})
    table.insert(data.raw.recipe["assembling-machine-3"].ingredients, {type = "item", name = "widget-5", amount = 1})
    table.insert(data.raw.recipe["active-provider-chest"].ingredients, {type = "item", name = "widget-5", amount = 1})
    table.insert(data.raw.recipe["requester-chest"].ingredients, {type = "item", name = "widget-5", amount = 1})
    table.insert(data.raw.recipe["buffer-chest"].ingredients, {type = "item", name = "widget-5", amount = 1})
    table.insert(data.raw.recipe["satellite"].ingredients, {type = "item", name = "widget-5", amount = 200})
    table.insert(data.raw.recipe["express-splitter"].ingredients, {type = "item", name = "widget-5", amount = 1})
    table.insert(data.raw.technology["rocket-silo"].prerequisites, "widget-5")

    -- 13. Research to remove multidirectionality

    data:extend({
        {
            type = "technology",
            name = "multidirectional",
            localised_name = "Multidirectionality",
            localised_description = "Wow, rotating inserters correctly was that simple?",
            icon = "__fun_mode__/graphics/technology/multidirectional.png",
            icon_size = 256,
            unit = {
                count = 75,
                time = 30,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"light-green-science", 1},
                }
            },
            prerequisites = {
                "light-green-science"
            },
            effects = {}
        }
    })

    -- 14. Tuned down landfill cost because I'm merciful
    data.raw.recipe.landfill.ingredients[1].amount = 20

--------------------------------------------------
-- Oil
--------------------------------------------------

    -- 1. Equipment shapes are weird

    -- TODO: TEST
    -- Personal roboport
    for _, prototype in pairs(data.raw["roboport-equipment"]) do
        if prototype.name ~= "wooden-roboport" then
            prototype.shape = {
                width = 3,
                height = 2,
                type = "manual",
                points = {
                    {0, 0}, {1, 0},
                            {1, 1}, {2, 1}
                }
            }
        end
    end
    -- Exoskeleton equipment
    for _, prototype in pairs(data.raw["movement-bonus-equipment"]) do
        prototype.shape = {
            width = 3,
            height = 3,
            type = "manual",
            points = {
                {0, 0}, {1, 0}, {2, 0},
                {0, 1},         {2, 1},
                {0, 2}, {1, 2}, {2, 2},
            }
        }
    end

    -- 2. Youtube videos

    -- TODO: IMPLEMENT/FINISH
    --[[data:extend({
        {
            type = "technology",
            name = "youtube",
            localised_name = "Youtube",
            localised_description = "Follow your lifelong dream of being a content creator!",
            icon = "__fun_mode__/graphics/technology/youtube.png",
            icon_size = 256,
            unit = {
                count = 75,
                time = 30,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"chemical-science-pack", 1}
                }
            },
            prerequisites = {
                "laser"
            },
            effects = {
                {type = "unlock-recipe", recipe = "computer"}
            }
        },
        {
            type = "item",
            name = "computer",
            localised_name = "Computer",
            -- What should subgroup and order be?
            icon = "__fun_mode__/graphics/icons/laptop.png",
            icon_size = 64,
            stack_size = 10
        },
        {
            type = "recipe",
            name = "computer",
            ingredients = {
                {type = "item", name = "advanced-circuit", amount = 200},
                {type = "item", name = "iron-plate", amount = 1},
                {type = "item", name = "battery", amount = 4}
            },
            results = {{type = "item", name = "computer", amount = 1}},
            energy_required = 10,
            enabled = false
        }
    })]]

    -- 3. Squeak through at home

    --[[data:extend({
        { -- Dummy equipment type
            type = "night-vision-equipment",
            name = "small-equipment",
            localised_name = "Smol",
            energy_input = "0W",
            color_lookup = data.raw["night-vision-equipment"]["night-vision-equipment"].color_lookup,
            darkness_to_turn_on = 0,

        }
    })]]

    -- 4. Solid fuel recipes made in unboiler

    data.raw.recipe["solid-fuel-from-petroleum-gas"].category = "unboiling"
    data.raw.recipe["solid-fuel-from-light-oil"].category = "unboiling"
    data.raw.recipe["solid-fuel-from-heavy-oil"].category = "unboiling"

--------------------------------------------------
-- Bots
--------------------------------------------------

    -- 1. More mining productivity levels to help with later grind

    data.raw.technology["mining-productivity-3"].effects = {
        {type = "mining-drill-productivity-bonus", modifier = 0.2}
    }
    data.raw.technology["mining-productivity-3"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1}
    }
    data.raw.technology["mining-productivity-3"].effects = {
        {type = "mining-drill-productivity-bonus", modifier = 0.5}
    }
    data.raw.technology["mining-productivity-3"].prerequisites = {
        "mining-productivity-2"
    }
    data.raw.technology["mining-productivity-4"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1}
    }
    data.raw.technology["mining-productivity-4"].prerequisites = {"mining-productivity-3"}
    data.raw.technology["mining-productivity-4"].effects = {
        {type = "mining-drill-productivity-bonus", modifier = 1}
    }

    -- 2. Steel productivity

    data:extend({
        {
            type = "technology",
            name = "steel-plate-prod",
            localised_name = "Greel plate productivity",
            localised_description = "What a greel!",
            icon = "__fun_mode__/graphics/icons/steel-plate-prod.png",
            icon_size = 64,
            unit = {
                count = 50,
                time = 15,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"chemical-science-pack", 1},
                    {"boiler", 1}
                }
            },
            prerequisites = {
                "advanced-material-processing-2"
            },
            effects = {
                {type = "change-recipe-productivity", recipe = "steel-plate", change = 1}
            }
        }
    })

    -- 3. Transport belt rotation tech

    -- Moved to base
    data.raw.technology["belt-ping"].unit.ingredients[2][1] = "dark-green-science"

    -- 4. Placeable water (Replaced with offshore assemblers on concrete)

    for _, tile in pairs(data.raw.tile) do
        if string.find(tile.name, "concrete") then
            tile.collision_mask = {layers = {}}
        end
    end
    data.raw.technology["concrete"].localised_name = "Offshore assembler platform"
    data.raw.technology["concrete"].localised_description = "Concrete can be used as platforms for offshore assemblers."
    --[[[data:extend({
        {
            type = "item",
            name = "water",
            localised_name = "Water",
            subgroup = "terrain",
            order = "a[widget]-e",
            icon = "__fun_mode__/graphics/legacy/water-o.png",
            icon_size = 32,
            place_as_tile = {
                result = "water-shallow",
                condition = {layers = {}},
                condition_size = 0,
            },
            stack_size = 100
        },
        {
            type = "recipe",
            name = "water",
            localised_name = "Water (tile)",
            category = "crafting-with-fluid",
            ingredients = {
                {type = "fluid", name = "water-2", amount = 100}
            },
            results = {
                {type = "item", name = "water", amount = 1}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        }
    })
    -- Unlocked with water 2
    table.insert(data.raw.technology["water-2"].effects, {type = "unlock-recipe", recipe = "water"})
    --[[local water_tiles = {}
    for _, tile in pairs(data.raw.tile) do
        if string.find(tile.name, "water") then
            table.insert(water_tiles, tile.name)
        end
    end
    for _, tile_name in pairs(water_tiles) do
        data.raw.tile[tile_name].minable = {
            mining_time = data.raw.tile["stone-path"].minable.mining_time,
            result = "water"
        }
        data.raw.tile[tile_name].is_foundation = false
    end]]
    --data.raw.tile.landfill.is_foundation = false
    --data.raw.item.landfill.place_as_tile = {condition = {layers = {}}, result = "landfill", condition_size = 0}
    --data.raw.tile.landfill.collision_mask = {layers = {}}]]]

    -- 5. OP substations

    data.raw["electric-pole"].substation.supply_area_distance = 30
    data.raw["electric-pole"].substation.maximum_wire_distance = 30
    data.raw.recipe.substation.ingredients = {{type = "item", name = "iron-plate", amount = 1}}

--------------------------------------------------
-- Purple/Yellow
--------------------------------------------------

    -- 1. Py science pack

    -- TODO, WIP
    data:extend({
        {
            type = "fluid",
            name = "coal-gas",
            localised_name = "Coal gas",
            icon = "__fun_mode__/graphics/coal-gas.png",
            icon_size = 64,
            default_temperature = 15,
            base_color = {r = 241, g = 235, b = 57},
            flow_color = {r = 241, g = 235, b = 57}
        },
        {
            type = "fluid",
            name = "tar",
            localised_name = "Tar",
            icon = "__fun_mode__/graphics/tar.png",
            icon_size = 64,
            default_temperature = 15,
            base_color = {r = 25, g = 120, b = 18},
            flow_color = {r = 25, g = 120, b = 18}
        },
        {
            type = "recipe",
            name = "coal-distillation",
            localised_name = "Coal distillation",
            subgroup = "fluid-recipes",
            order = "z",
            icon = "__fun_mode__/graphics/coal-distillation.png",
            icon_size = 64,
            category = "oil-processing",
            ingredients = {
                {type = "item", name = "coal", amount = 15}
            },
            results = {
                {type = "fluid", name = "coal-gas", amount = 150},
                {type = "fluid", name = "tar", amount = 50}
            },
            energy_required = 2,
            enabled = false,
            allow_productivity = true
        },
        -- You have to turn the tar back into heavy oil, then that into coal with oil solidification, then that into coal gas to balance things
        {
            type = "recipe",
            name = "tar-heavification",
            localised_name = "Tar cola",
            subgroup = "fluid-recipes",
            order = "zz",
            icon = "__fun_mode__/graphics/tar-heavification.png",
            icon_size = 64,
            category = "oil-processing",
            ingredients = {
                {type = "fluid", name = "tar", amount = 100}
            },
            results = {
                {type = "fluid", name = "heavy-oil", amount = 50}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "tool",
            name = "py-science",
            localised_name = "Py science pack",
            subgroup = "science-pack",
            order = "fz[py-science-pack]",
            icon = "__fun_mode__/graphics/pyscience.png",
            icon_size = 64,
            stack_size = 200,
            durability = 1,
            pick_sound = data.raw.tool["automation-science-pack"].pick_sound,
            drop_sound = data.raw.tool["automation-science-pack"].drop_sound,
        },
        {
            type = "recipe",
            name = "py-science",
            category = "oil-processing",
            ingredients = {
                {type = "fluid", name = "coal-gas", amount = 250}
            },
            results = {
                {type = "item", name = "py-science", amount = 1}
            },
            energy_required = 13,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "technology",
            name = "py-science",
            localised_name = "Py science pack",
            localised_description = "In a sense, you've been playing pyanodons all along.",
            icon = "__fun_mode__/graphics/pyscience.png",
            icon_size = 64,
            unit = {
                count = 75,
                time = 30,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"chemical-science-pack", 1}
                }
            },
            prerequisites = {
                "advanced-oil-processing"
            },
            effects = {
                {type = "unlock-recipe", recipe = "py-science"},
                {type = "unlock-recipe", recipe = "coal-distillation"},
                {type = "unlock-recipe", recipe = "tar-heavification"},
                {type = "unlock-recipe", recipe = "coal-liquefaction"}
            },
            essential = true
        }
    })
    data.raw.technology["coal-liquefaction"].hidden = true
    data.raw.technology["logistic-system"].prerequisites = {
        "py-science",
        "logistic-robotics",
        "utility-science-pack"
    }
    data.raw.technology["logistic-system"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
        -- Py science added automatically soon
        --{"py-science", 1}
    }
    table.insert(data.raw.lab["lab-2"].inputs, "py-science")
    -- If it requires utility, it should require py science
    for _, technology in pairs(data.raw.technology) do
        if technology.unit ~= nil then
            if technology.unit.ingredients ~= nil then
                for _, ingredient in pairs(technology.unit.ingredients) do
                    if ingredient[1] == "utility-science-pack" then
                        table.insert(technology.unit.ingredients, {"py-science", 1})
                    end
                end
            end
        end
    end
    data.raw.technology["spidertron"].prerequisites = {
        "py-science"
    }
    data.raw.technology["spidertron"].unit = {
        time = 30,
        count = 250,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"py-science", 1},
            {"repair-pack", 1},
            {"explosives", 1},
        }
    }
    data.raw.technology["fission-reactor-equipment"].prerequisites = {
        "py-science"
    }
    data.raw.technology["fission-reactor-equipment"].unit = {
        time = 30,
        count = 200,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"burner-inserter", 1},
            {"repair-pack", 1},
            {"boiler", 1},
            {"power-armor", 1},
            {"py-science", 1}
        }
    }
    data.raw.technology["military-4"].prerequisites = {
        "py-science",
        "lab-2"
    }
    data.raw.technology["military-4"].unit = {
        time = 30,
        count = 150,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"py-science", 1},
            {"repair-pack", 1}
        }
    }
    data.raw.technology["power-armor-mk2"].unit = {
        time = 30,
        count = 200,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"py-science", 1},
            {"repair-pack", 1},
        }
    }
    data.raw.technology["artillery"].unit = {
        time = 30,
        count = 200,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"py-science", 1},
            {"explosives", 1}
        }
    }
    -- Description on artillery to say I didn't change it
    data.raw.technology.artillery.localised_description = "I know you won't believe me, but this isn't changed. Have fun with your cheaper artillery."
    data.raw.technology["personal-roboport-mk2-equipment"].prerequisites = {
        "py-science",
        "personal-roboport-equipment"
    }
    data.raw.technology["personal-roboport-mk2-equipment"].unit = {
        time = 30,
        count = 100,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"py-science", 1},
            {"repair-pack", 1},
        }
    }
    --data.raw.technology["rail-signals"].prerequisites = {"py-science"}
    data.raw.technology["efficiency-module-3"].prerequisites = {
        "py-science",
        "efficiency-module-2"
    }
    data.raw.technology["efficiency-module-3"].unit = {
        time = 30,
        count = 300,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"burner-inserter", 1},
            {"repair-pack", 1},
            {"boiler", 1},
            {"py-science", 1}
        }
    }
    data.raw.technology["productivity-module-3"].prerequisites = {
        "py-science",
        "productivity-module-2"
    }
    data.raw.technology["productivity-module-3"].unit = {
        time = 30,
        count = 300,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"burner-inserter", 1},
            {"repair-pack", 1},
            {"boiler", 1},
            {"py-science", 1}
        }
    }
    data.raw.technology["speed-module-3"].prerequisites = {
        "py-science",
        "speed-module-2"
    }
    data.raw.technology["speed-module-3"].unit = {
        time = 30,
        count = 300,
        ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"military-science-pack", 1},
            {"burner-inserter", 1},
            {"repair-pack", 1},
            {"boiler", 1},
            {"py-science", 1}
        }
    }
    -- Fix express transport belts to use utility science
    table.insert(data.raw.technology["logistics-3"].unit.ingredients, {"utility-science-pack", 1})
    --table.insert(data.raw.technology["utility-science-pack"].prerequisites, "lab-2")
    table.insert(data.raw.technology["utility-science-pack"].unit.ingredients, {"py-science", 1})
    -- Idk why beacons require proc units as a prereq but lets get rid of that silliness
    data.raw.technology["effect-transmission"].prerequisites = {"production-science-pack"}
    data.raw.technology["inserter-capacity-bonus-4"].prerequisites = {"inserter-capacity-bonus-3", "lab-2"}
    data.raw.technology["inserter-capacity-bonus-7"].prerequisites = {"inserter-capacity-bonus-6"}
    for i = 4, 7 do
        data.raw.technology["inserter-capacity-bonus-" .. i].unit.ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
            {"burner-inserter", 1}
        }
    end
    data.raw.technology["research-speed-5"].prerequisites = {"research-speed-4"}
    data.raw.technology["research-speed-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"lab", 1}
    }
    data.raw.technology["research-speed-6"].prerequisites = {"research-speed-5"}
    data.raw.technology["research-speed-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"lab", 1}
    }

    -- 2. Spidertrons have many legs

    require("spidertron-legs")

    -- 3. Very advanced oil processing

    -- Have this researched by py science pack actually, and make a prerequisite on processing units since it makes those
    -- OOOH, or! Have this replace processing units
    -- This complexity warrants a higher oil refinery speed
    data.raw["assembling-machine"]["oil-refinery"].crafting_speed = 2
    data:extend({
        {
            type = "technology",
            name = "very-advanced-oil-processing",
            localised_name = "Very advanced soda processing",
            localised_description = "Very advanced soda processing is a lot to process. Get it? Cuz it's how you make processing units.",
            icon = "__fun_mode__/graphics/technology/very-advanced-oil-processing.png",
            icon_size = 256,
            unit = {
                count = 125,
                time = 60,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"chemical-science-pack", 1},
                    {"py-science", 1}
                }
            },
            prerequisites = {
                "py-science"
            },
            effects = {
                {type = "unlock-recipe", recipe = "very-advanced-oil-processing"},
                {type = "unlock-recipe", recipe = "le-croix-separation"},
                {type = "unlock-recipe", recipe = "void-fizz"},
                {type = "unlock-recipe", recipe = "fizzy-fanta"},
                {type = "unlock-recipe", recipe = "void-green"},
            }
        },
        {
            type = "recipe",
            name = "very-advanced-oil-processing",
            localised_name = "Very advanced soda processing",
            subgroup = "fluid-recipes",
            order = "a[oil-processing]-c[very-advanced-oil-processing]",
            category = "oil-processing",
            icon = "__fun_mode__/graphics/icons/very-advanced-oil-processing.png",
            icon_size = 64,
            ingredients = {
                {type = "fluid", name = "sulfuric-acid", amount = 200},
                {type = "fluid", name = "steam", amount = 500},
                {type = "item", name = "coal", amount = 20},
                {type = "item", name = "electronic-circuit", amount = 20},
                {type = "item", name = "advanced-circuit", amount = 2}
            },
            results = {
                {type = "item", name = "solid-steam", amount = 1},
                --{type = "item", name = "heavy-oil", amount = 10},
                {type = "item", name = "oil-fish", amount = 2},
                {type = "fluid", name = "water", amount = 10},
                {type = "fluid", name = "processing-unit", amount = 2},
                {type = "fluid", name = "crude-oil", amount = 20},
                -- Get rid of heavy oil, we add in lubricant back as a fluid later
                --{type = "fluid", name = "heavy-oil", amount = 20},
                {type = "fluid", name = "tar", amount = 40},
                {type = "fluid", name = "distilled-green", amount = 10},
                {type = "fluid", name = "fanta", amount = 20},
                {type = "fluid", name = "le-croix", amount = 40} -- Le croix --> fizz + water, use fizz and lots of water with fanta for fizzy fanta, use fizzy fanta for some things
                -- Maybe also some solid fuel recipes
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "recipe",
            name = "void-green",
            localised_name = "Void green",
            subgroup = "green",
            order = "aaab",
            category = "growing",
            icon = "__fun_mode__/graphics/icons/void-distilled-green.png",
            icon_size = 64,
            ingredients = {
                {type = "fluid", name = "distilled-green", amount = 10},
            },
            results = {},
            enabled = false,
            energy_required = 2,
        },
        {
            type = "fluid",
            name = "fanta",
            localised_name = "Fanta",
            icon = "__fun_mode__/graphics/icons/fanta.png",
            icon_size = 64,
            default_temperature = 15,
            base_color = {r = 100, g = 50, b = 0},
            flow_color = {r = 100, g = 50, b = 0}
        },
        {
            type = "fluid",
            name = "le-croix",
            localised_name = "Pretentious water",
            icon = "__fun_mode__/graphics/icons/le-croix.png",
            icon_size = 64,
            default_temperature = 15,
            base_color = {r = 69, g = 80, b = 85},
            flow_color = {r = 69, g = 80, b = 85}
        },
        {
            type = "fluid",
            name = "fizz",
            localised_name = "Fizz",
            icon = "__fun_mode__/graphics/icons/fizz.png",
            icon_size = 64,
            default_temperature = 15,
            base_color = {r = 255, g = 255, b = 255},
            flow_color = {r = 255, g = 255, b = 255}
        },
        {
            type = "recipe",
            name = "le-croix-separation",
            localised_name = "Pretentious water separation",
            subgroup = "fluid-recipes",
            order = "b",
            category = "oil-processing",
            icon = "__fun_mode__/graphics/icons/le-croix.png",
            icon_size = 64,
            ingredients = {
                {type = "fluid", name = "le-croix", amount = 10}
            },
            results = {
                {type = "fluid", name = "water", amount = 3},
                {type = "fluid", name = "fizz", amount = 5}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "recipe",
            name = "void-fizz",
            localised_name = "Void fizz",
            subgroup = "fluid-recipes",
            order = "ab",
            category = "crafting-with-fluid",
            icon = "__fun_mode__/graphics/icons/void-fizz.png",
            icon_size = 64,
            ingredients = {
                {type = "fluid", name = "fizz", amount = 10}
            },
            results = {},
            energy_required = 1,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "recipe",
            name = "fizzy-fanta",
            localised_name = "Fizzify fanta",
            localised_description = "Making processing units this way does not compute (or does it?)",
            subgroup = "fluid-recipes",
            order = "ac",
            category = "oil-processing",
            icon = "__fun_mode__/graphics/icons/fizzy-fanta.png",
            icon_size = 64,
            ingredients = {
                {type = "fluid", name = "fizz", amount = 5},
                {type = "fluid", name = "fanta", amount = 5}
            },
            results = {
                {type = "fluid", name = "processing-unit", amount = 0.5},
                {type = "fluid", name = "fizz", amount = 1}
            },
            energy_required = 5,
            enabled = false,
            allow_productivity = true
        }
    })
    -- Give the oil refinery enough outputs
    local oil_refinery = data.raw["assembling-machine"]["oil-refinery"]
    local standard_fluid_box = table.deepcopy(oil_refinery.fluid_boxes[3])
    table.insert(oil_refinery.fluid_boxes, table.deepcopy(standard_fluid_box))
    oil_refinery.fluid_boxes[6].pipe_connections[1].position = {-1, -2}
    table.insert(oil_refinery.fluid_boxes, table.deepcopy(standard_fluid_box))
    oil_refinery.fluid_boxes[7].pipe_connections[1].position = {1, -2}
    standard_fluid_box = table.deepcopy(oil_refinery.fluid_boxes[1])
    table.insert(oil_refinery.fluid_boxes, table.deepcopy(standard_fluid_box))
    oil_refinery.fluid_boxes[8].pipe_connections[1].position = {-2, 2}
    oil_refinery.fluid_boxes[8].pipe_connections[1].flow_direction = "output"
    oil_refinery.fluid_boxes[8].production_type = "output"
    oil_refinery.fluid_boxes[8].pipe_connections[1].direction = defines.direction.south
    table.insert(oil_refinery.fluid_boxes, table.deepcopy(standard_fluid_box))
    oil_refinery.fluid_boxes[9].pipe_connections[1].position = {0, 2}
    oil_refinery.fluid_boxes[9].pipe_connections[1].flow_direction = "output"
    oil_refinery.fluid_boxes[9].production_type = "output"
    oil_refinery.fluid_boxes[9].pipe_connections[1].direction = defines.direction.south
    table.insert(oil_refinery.fluid_boxes, table.deepcopy(standard_fluid_box))
    oil_refinery.fluid_boxes[10].pipe_connections[1].position = {2, 2}
    oil_refinery.fluid_boxes[10].pipe_connections[1].flow_direction = "output"
    oil_refinery.fluid_boxes[10].production_type = "output"
    oil_refinery.fluid_boxes[10].pipe_connections[1].direction = defines.direction.south
    data.raw.technology["processing-unit"].prerequisites = {"very-advanced-oil-processing"}
    table.insert(data.raw.technology["processing-unit"].unit.ingredients, {"py-science", 1})
    table.insert(data.raw.technology["efficiency-module-2"].unit.ingredients, {"py-science", 1})
    table.insert(data.raw.technology["speed-module-2"].unit.ingredients, {"py-science", 1})
    table.insert(data.raw.technology["productivity-module-2"].unit.ingredients, {"py-science", 1})
    data.raw.technology["processing-unit"].localised_name = "Processing unit unboiling"
    -- Change processing units back to solids again?
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            for _, ingredient in pairs(recipe.ingredients) do
                if ingredient.name == "processing-unit" then
                    ingredient.type = "item"
                end
            end
        end
    end
    data.raw.recipe["processing-unit"].localised_name = "Processing unit unboiling"
    data.raw.recipe["processing-unit"].ingredients = {{type = "fluid", name = "processing-unit", amount = 1}}
    data.raw.recipe["processing-unit"].results = {{type = "item", name = "processing-unit", amount = 1}}
    data.raw.recipe["processing-unit"].category = "unboiling"
    -- Make things that barely require processing units not require them to be less painful
    for _, ingredient in pairs(data.raw.recipe["power-armor"].ingredients) do
        if ingredient.name == "processing-unit" then
            ingredient.name = "advanced-circuit"
        end
    end
    data.raw.technology["power-armor"].prerequisites = {"electric-engine", "modular-armor"}
    for _, ingredient in pairs(data.raw.recipe["exoskeleton-equipment"].ingredients) do
        if ingredient.name == "processing-unit" then
            ingredient.name = "advanced-circuit"
        end
    end
    data.raw.technology["exoskeleton-equipment"].prerequisites = {"electric-engine", "solar-panel-equipment"}

    -- 4. A way to craft oil patches

    data:extend({
        {
            type = "recipe",
            name = "oil-patch",
            localised_name = "Grape juice spring",
            subgroup = "raw-resource",
            order = "b",
            category = "oil-processing",
            icon = "__base__/graphics/icons/crude-oil-resource.png",
            icon_size = 64,
            ingredients = {
                {type = "fluid", name = "tar", amount = 10000}
            },
            results = {
                {type = "item", name = "oil-patch", amount = 1}
            },
            energy_required = 50,
            enabled = false
        }
    })
    table.insert(data.raw.technology["py-science"].effects, {type = "unlock-recipe", recipe = "oil-patch"})

    -- 5. Kovarex costs less since it's less useful

    data.raw.technology["kovarex-enrichment-process"].unit.count = 150

--------------------------------------------------
-- Rocket
--------------------------------------------------

    -- 1. Cat research for cheeseman 2

    data:extend({
        {
            type = "technology",
            name = "cat",
            localised_name = "Cat",
            localised_description = "A cat to protect you from cheeseman.",
            icon = "__fun_mode__/graphics/technology/cat.png",
            icon_size = 256,
            unit = {
                count = 200,
                time = 60,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    {"repair-pack", 1},
                    {"power-armor", 1},
                    {"lab", 1},
                    {"burner-inserter", 1},
                    {"boiler", 1},
                    {"copper-cable", 1},
                    {"explosives", 1},
                    -- Need to add py science manually
                    {"py-science", 1}
                }
            },
            prerequisites = {
                "utility-science-pack",
                "production-science-pack"
            },
            effects = {}
        },
    })
    -- Make silo military target so cheeseman 2 shoots it
    data.raw["rocket-silo"]["rocket-silo"].is_military_target = true
    -- Define cheeseman 2, which is just cheeseman resistant to everything
    data.raw["electric-turret"]["cheeseman_2"] = table.deepcopy(data.raw["electric-turret"]["cheeseman"])
    data.raw["electric-turret"]["cheeseman_2"].name = "cheeseman_2"
    data.raw["electric-turret"]["cheeseman_2"].resistances = {}
    for _, damage_type in pairs(data.raw["damage-type"]) do
        table.insert(data.raw["electric-turret"]["cheeseman_2"].resistances, {type = damage_type.name, percent = 100})
    end
    -- Define cat
    -- Graphics
    data.raw["electric-turret"].cat = table.deepcopy(data.raw["electric-turret"]["laser-turret"])
    data.raw["electric-turret"].cat.name = "cat"
    data.raw["electric-turret"].cat.localised_name = "Cat"
    data.raw["electric-turret"].cat.energy_source = {type = "void"}
    data.raw["electric-turret"].cat.icon = "__fun_mode__/graphics/technology/cat.png"
    data.raw["electric-turret"].cat.icon_size = 256
    local cat_animation = {
        filename = "__fun_mode__/graphics/technology/cat.png",
        size = 256,
        direction_count = 1
    }
    data.raw["electric-turret"].cat.folded_animation = table.deepcopy(cat_animation)
    data.raw["electric-turret"].cat.folding_sound = nil
    data.raw["electric-turret"].cat.folding_animation = table.deepcopy(cat_animation)
    data.raw["electric-turret"].cat.prepared_animation = table.deepcopy(cat_animation)
    data.raw["electric-turret"].cat.preparing_animation = table.deepcopy(cat_animation)
    data.raw["electric-turret"].cat.preparing_sound = nil
    data.raw["electric-turret"].cat.water_reflection = nil
    data.raw["electric-turret"].cat.base_picture = nil
    data.raw["electric-turret"].cat.resource_indicator_animation = nil
    data.raw["electric-turret"].cat.graphics_set = {
        base_visualization = {
            animation = {
                table.deepcopy(cat_animation)
            }
        }
    }
    -- Attacks
    data.raw["electric-turret"].cat.attack_parameters.damage_modifier = 10
    data.raw["electric-turret"].cat.attack_parameters.range = 40
    -- Category of ammo (so it doesn't get laser turret bonuses)
    data.raw["electric-turret"].cat.attack_parameters.ammo_category = "cat"
    data:extend({
        {
            type = "ammo-category",
            name = "cat",
            localised_name = "Claws"
        }
    })
    -- Beam
    data.raw["electric-turret"].cat.attack_parameters.ammo_type.action.action_delivery.beam = "cat_beam"
    data.raw["electric-turret"].cat.attack_parameters.ammo_type.action.action_delivery.max_length = 40
    data.raw["beam"].cat_beam = table.deepcopy(data.raw.beam["laser-beam"])
    data.raw["beam"].cat_beam.name = "cat_beam"
    data.raw["beam"].cat_beam.damage_interval = 1
    data.raw["beam"].cat_beam.action_triggered_automatically = true
    -- New damage category that can hit cheeseman
    data.raw.beam.cat_beam.action.action_delivery.target_effects[1].damage.type = "cat"
    data:extend({
        {
            type = "damage-type",
            name = "cat",
            localised_name = "Claws"
        }
    })
    -- Box and misc
    data.raw["electric-turret"].cat.selection_box = {{-3, -3}, {3, 3}}
    data.raw["electric-turret"].cat.minable = nil
    data.raw["electric-turret"].cat.corpse = nil
    data.raw["electric-turret"].cat.collision_mask = {layers = {}}
    data.raw["electric-turret"].cat.max_health = 50
    table.insert(data.raw["electric-turret"].cat.flags, "placeable-off-grid")
    -- Make rocket silo easier for cheeseman to kill
    data.raw["rocket-silo"]["rocket-silo"].resistances = {
        {
            type = "laser",
            percent = -2000
        }
    }
    -- Add to rocket description
    data.raw.technology["rocket-silo"].localised_description = data.raw.technology["rocket-silo"].localised_description .. " Just make sure you have a cat."

    -- 2. Pistols as prereq to rocket
    data:extend({
        {
            type = "technology",
            name = "pistol",
            localised_name = "Pistol",
            localised_description = "Once you unravel the manufacturing process for a pistol, you start to wonder if you were overthinking it all along.",
            icon = data.raw.gun.pistol.icon,
            icon_size = data.raw.gun.pistol.icon_size,
            unit = {
                count = 150,
                time = 60,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"dark-green-science", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    {"repair-pack", 1},
                    {"power-armor", 1},
                    {"lab", 1},
                    {"burner-inserter", 1},
                    {"boiler", 1},
                    {"copper-cable", 1},
                    {"explosives", 1},
                    -- Need to add py science manually
                    {"py-science", 1}
                }
            },
            prerequisites = {
                "utility-science-pack",
                "production-science-pack"
            },
            effects = {{type = "unlock-recipe", recipe = "pistol"}}
        },
        {
            type = "recipe",
            name = "pistol",
            localised_name = "Pistol",
            ingredients = {
                {type = "item", name = "iron-plate", amount = 4},
                {type = "item", name = "copper-plate", amount = 4}
            },
            results = {
                {type = "item", name = "pistol", amount = 1}
            },
            energy_required = 5,
            enabled = false
        },
    })
    table.insert(data.raw.technology["rocket-silo"].prerequisites, "pistol")

end

--------------------------------------------------
-- Beta fixes
--------------------------------------------------

function do_fun_mode_beta_fixes()

    -- 1. Actually switch lubricant back to fluid and then you have to unboil it

    data.raw.item["lubricant"].localised_name = "Solid lubricant"
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.results ~= nil then
            for _, result in pairs(recipe.results) do
                if result.name == "lubricant" then
                    result.type = "fluid"
                end
            end
        end
    end
    data:extend({
        {
            type = "recipe",
            name = "solidify-lubricant",
            localised_name = "Solid lubricant",
            subgroup = "fluid-recipes",
            category = "unboiling",
            icon = "__base__/graphics/icons/fluid/lubricant.png",
            icon_size = 64,
            ingredients = {
                {type = "fluid", name = "lubricant", amount = 1}
            },
            results = {
                {type = "item", name = "lubricant", amount = 1}
            },
            energy_required = 0.5,
            enabled = false
        }
    })
    table.insert(data.raw.technology.lubricant.effects, {type = "unlock-recipe", recipe = "solidify-lubricant"})
    -- Switch blue belts to normal crafting
    data.raw.recipe["express-transport-belt"].category = "crafting"
    data.raw.recipe["express-underground-belt"].category = "crafting"
    data.raw.recipe["express-splitter"].category = "crafting"

    -- 2. Remove copper cable and power armor required for techs, also fix/customize a lot of them

    for _, technology in pairs(data.raw.technology) do
        if technology.unit ~= nil then
            for i = #technology.unit.ingredients, 1, -1 do
                if technology.unit.ingredients[i][1] == "copper-cable" or technology.unit.ingredients[i][1] == "power-armor" then
                    table.remove(technology.unit.ingredients, i)
                end
            end
        end
    end
    data.raw.technology["regeneration"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"explosives", 1},
    }
    data.raw.technology["mining-productivity-2"].prerequisites = {"mining-productivity-1"}
    data.raw.technology["mining-productivity-3"].prerequisites = {"mining-productivity-2"}
    data.raw.technology["regeneration"].prerequisites = {"py-science"}
    data.raw.technology["laser-weapons-damage-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
    }
    data.raw.technology["laser-weapons-damage-5"].prerequisites = {"laser-weapons-damage-4"}
    data.raw.technology["laser-weapons-damage-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
    }
    data.raw.technology["laser-weapons-damage-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
    }
    data.raw.technology["laser-weapons-damage-7"].prerequisites = {"laser-weapons-damage-6"}
    data.raw.technology["laser-weapons-damage-7"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
        {"lab", 1}
    }
    data.raw.technology["laser-shooting-speed-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
    }
    data.raw.technology["laser-shooting-speed-5"].prerequisites = {"laser-shooting-speed-4"}
    data.raw.technology["laser-shooting-speed-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
    }
    data.raw.technology["laser-shooting-speed-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
    }
    data.raw.technology["laser-shooting-speed-7"].prerequisites = {"laser-shooting-speed-6"}
    data.raw.technology["laser-shooting-speed-7"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"burner-inserter", 1},
        {"lab", 1}
    }
    data.raw.technology["physical-projectile-damage-3"].prerequisites = {"physical-projectile-damage-2"}
    data.raw.technology["physical-projectile-damage-3"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
    }
    data.raw.technology["physical-projectile-damage-4"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
    }
    data.raw.technology["physical-projectile-damage-5"].prerequisites = {"physical-projectile-damage-4"}
    data.raw.technology["physical-projectile-damage-6"].prerequisites = {"physical-projectile-damage-5"}
    data.raw.technology["physical-projectile-damage-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["physical-projectile-damage-7"].prerequisites = {"physical-projectile-damage-6"}
    data.raw.technology["physical-projectile-damage-7"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["weapon-shooting-speed-3"].prerequisites = {"weapon-shooting-speed-2"}
    data.raw.technology["weapon-shooting-speed-3"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
    }
    data.raw.technology["weapon-shooting-speed-4"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
    }
    data.raw.technology["weapon-shooting-speed-5"].prerequisites = {"weapon-shooting-speed-4"}
    data.raw.technology["weapon-shooting-speed-6"].prerequisites = {"weapon-shooting-speed-5"}
    data.raw.technology["weapon-shooting-speed-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["refined-flammables-4"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["refined-flammables-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["refined-flammables-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["refined-flammables-7"].prerequisites = {"refined-flammables-6"}
    data.raw.technology["refined-flammables-7"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["stronger-explosives-2"].prerequisites = {"stronger-explosives-1"}
    data.raw.technology["stronger-explosives-2"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
    }
    data.raw.technology["stronger-explosives-4"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["stronger-explosives-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["stronger-explosives-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["stronger-explosives-7"].prerequisites = {"stronger-explosives-6"}
    data.raw.technology["stronger-explosives-7"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["artillery-shell-range-1"].prerequisites = {"artillery"}
    data.raw.technology["artillery-shell-range-1"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["artillery-shell-speed-1"].prerequisites = {"artillery"}
    data.raw.technology["artillery-shell-speed-1"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
    }
    data.raw.technology["beacon-count"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
    }
    data.raw.technology["worker-robots-speed-3"].prerequisites = {"worker-robots-speed-2"}
    data.raw.technology["worker-robots-speed-3"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
    }
    data.raw.technology["worker-robots-speed-4"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"utility-science-pack", 1},
    }
    data.raw.technology["worker-robots-speed-5"].prerequisites = {"worker-robots-speed-4"}
    data.raw.technology["worker-robots-speed-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
    }
    data.raw.technology["worker-robots-speed-6"].prerequisites = {"worker-robots-speed-5"}
    data.raw.technology["worker-robots-speed-6"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
        {"repair-pack", 1},
    }
    data.raw.technology["worker-robots-storage-2"].prerequisites = {"worker-robots-storage-1"}
    data.raw.technology["worker-robots-storage-2"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
    }
    data.raw.technology["worker-robots-storage-3"].prerequisites = {"worker-robots-storage-2"}
    data.raw.technology["worker-robots-storage-3"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"production-science-pack", 1},
    }
    data.raw.technology["follower-robot-count-1"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
    }
    data.raw.technology["follower-robot-count-2"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
    }
    data.raw.technology["follower-robot-count-3"].prerequisites = {"follower-robot-count-2"}
    data.raw.technology["follower-robot-count-4"].prerequisites = {"follower-robot-count-3"}
    data.raw.technology["follower-robot-count-4"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"explosives", 1},
    }
    data.raw.technology["follower-robot-count-5"].prerequisites = {"follower-robot-count-4"}
    data.raw.technology["follower-robot-count-5"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"explosives", 1},
    }
    data.raw.technology["electric-energy-distribution-2"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"lab", 1},
    }
    data.raw.technology["bob"].prerequisites = {"bulk-inserter", "longness"}
    data.raw.technology["solar-energy"].unit.count = 100
    for _, effect in pairs(data.raw.technology["automated-rail-transportation"].effects) do
        table.insert(data.raw.technology["railway"].effects, effect)
    end
    data.raw.technology["automated-rail-transportation"].hidden = true
    for _, effect in pairs(data.raw.technology["fluid-wagon"].effects) do
        table.insert(data.raw.technology["railway"].effects, effect)
    end
    data.raw.technology["fluid-wagon"].hidden = true
    data.raw.technology["logistics-2"].unit.count = 200
    data.raw.technology["concrete"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
    }
    data.raw.technology["inserter-capacity-bonus-2"].prerequisites = {"inserter-capacity-bonus-1"}
    data.raw.technology["inserter-capacity-bonus-3"].prerequisites = {"inserter-capacity-bonus-2"}
    data.raw.technology["inserter-capacity-bonus-4"].prerequisites = {"inserter-capacity-bonus-3"}
    for i = 1, 7 do
        data.raw.technology["inserter-capacity-bonus-" .. i].unit.count = 100
    end
    data.raw.technology["cliff-explosives"].unit.count = 50
    data.raw.technology["low-density-structure"].prerequisites = {
        "advanced-oil-processing"
    }
    data.raw.technology["low-density-structure"].unit.count = 150
    data.raw.technology["nuclear-power"].unit.count = 100
    data.raw.technology["tank"].unit.count = 50
    data.raw.technology["processing-unit"].unit.count = 25
    data.raw.technology["rocket-control-unit"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
    }
    -- We don't need reprocessing anymore now that fuel cells are gone
    --[[for _, effect in pairs(data.raw.technology["nuclear-fuel-reprocessing"].effects) do
        table.insert(data.raw.technology["nuclear-power"].effects, effect)
    end]]
    data.raw.technology["nuclear-fuel-reprocessing"].hidden = true
    data.raw.technology["effect-transmission"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
    }
    data.raw.technology["automation-3"].prerequisites = {"speed-module", "production-science-pack"}
    data.raw.technology["automation-3"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"lab", 1},
    }
    data.raw.technology["kovarex-enrichment-process"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"lab", 1},
        {"burner-inserter", 1},
        {"boiler", 1},
    }
    data.raw.technology["logistics-3"].prerequisites = {
        "lubricant",
        "production-science-pack",
        "logistics-2"
    }
    data.raw.technology["logistics-3"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"lab", 1},
        {"burner-inserter", 1},
        {"boiler", 1},
    }
    data.raw.technology["fission-reactor-equipment"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"repair-pack", 1},
    }
    data.raw.technology["utility-science-pack"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"repair-pack", 1},
    }
    data.raw.technology["defender"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1}
    }
    data.raw.technology["destroyer"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"explosives", 1},
    }
    data.raw.technology["uranium-ammo"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
    }
    for i = 1, 7 do
        if i ~= 1 then
            data.raw.technology["braking-force-" .. tostring(i)].prerequisites = {"braking-force-" .. tostring(i-1)}
        end
        data.raw.technology["braking-force-" .. tostring(i)].unit.ingredients = {
            {"automation-science-pack", 1},
            {"dark-green-science", 1},
            {"chemical-science-pack", 1},
        }
    end
    data.raw.technology["rocket-silo"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
        {"burner-inserter", 1},
        {"boiler", 1},
        {"lab", 1},
        {"repair-pack", 1},
    }
    data.raw.technology["useful"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
        {"burner-inserter", 1},
        {"boiler", 1},
        {"lab", 1},
        {"repair-pack", 1},
    }
    data.raw.technology["useless"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
        {"burner-inserter", 1},
        {"boiler", 1},
        {"lab", 1},
        {"repair-pack", 1},
    }
    data.raw.technology["pistol"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
        {"burner-inserter", 1},
        {"boiler", 1},
        {"lab", 1},
        {"repair-pack", 1},
    }
    data.raw.technology["cat"].unit.ingredients = {
        {"automation-science-pack", 1},
        {"dark-green-science", 1},
        {"chemical-science-pack", 1},
        {"py-science", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"explosives", 1},
        {"burner-inserter", 1},
        {"boiler", 1},
        {"lab", 1},
        {"repair-pack", 1},
    }
    table.insert(data.raw.technology["battery-mk2-equipment"].prerequisites, "processing-unit")

    -- Shallow water collides with nothing

    data.raw.tile["water-shallow"].collision_mask.layers.water = nil

end