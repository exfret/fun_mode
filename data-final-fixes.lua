-- Stand-in until the hash function is working
dosh_mode = false
if settings.startup["fun_mode_dosh"].value then
    dosh_mode = true
end

--------------------------------------------------
--------------------------------------------------
-------------- Changes ---------------------------
--------------------------------------------------
--------------------------------------------------

--------------------------------------------------
-- Libraries
--------------------------------------------------

--------------------------------------------------
-- Notes
--------------------------------------------------

-- (V) means "visual change", which is disabled by visual change setting
-- Actually, I don't think this is getting maintained, so let's just get rid of that setting
settings.startup["fun_mode_normal_visuals"].value = false

--------------------------------------------------
-- Startup
--------------------------------------------------

-- 1. Supporter fishies
-- 2. Dying creates a character item
-- 3. Mining the crashed ship gives you a heart attack
-- 4. Character corpses move
-- 5. (V) Inventory widths of 9
-- 6. You can't touch water and you can fall off cliffs
-- 7. Ring of fire
-- 8. Biter rocks
-- 9. No fish normally
-- 10. No grass tiles or regular trees
-- 11. Fake alerts
-- 12. Burner mining drills faster for faster start
-- 13. Some starting items to make the game faster
-- 14. Wooden equipment
-- 15. 20.01 foot pole
-- 16. Giving entities Greenosity values

--------------------------------------------------
-- Electricity
--------------------------------------------------

-- 1. Switch boiler fluid boxes
-- 2. Electring mining drills have larger mining area
-- 3. All backer names are now "Fun"
-- 4. Mercy research
-- 5. Burnt result of coal is fish
-- 6. Inserters are only certain directions
-- 7. You start with big electric poles rather than small ones
-- 8. (V) Transport belt animations are weird
-- 9. Offshore pumps lower pumping speed

--------------------------------------------------
-- Red science
--------------------------------------------------

-- 1. Various things smelt into upgraded versions of themselves
-- 2. Peperos
-- 3. Heavy armor slows you down
-- 4. Unique challenges that happen every now and then
-- 5. Wall has 2x2 grid
-- 6. Need to unlock storage
-- 7. Repair packs need to be used by bots
-- 8. (V) Squished assembling machines
-- 9. Lamps don't turn on
-- 10. Steel smelts in bulk
-- 11. You only get one underground belt when crafting
-- 12. Research for longness
-- 13. Min distance between undergrounds

--------------------------------------------------
-- Green science
--------------------------------------------------

-- 1. REMOVED Chain signals are far into the tech tree
-- 2. Lunar panels
-- 3. Logistic science takes 6.1 seconds
-- 4. (V) Switch red and green wire colors
-- 5. Sacrifices to exfret
-- 6. Offshore assemblers
-- 7. REMOVED Trains are invisible
-- 8. No straight driving
-- 9. REMOVED Curved rails cost 99 rails but the rail recipe is overall cheaper
-- 10. Gates close when player is near
-- 11. Hazard concrete makes you vroom but damages you
-- 12. Need a driver's license to drive
-- 13. Research for the color green
-- 14. Custom messages for certain people
-- 15. Locomotives actively try to kill you
-- 16. Iron plate prod bonus research
-- 17. Toolbelt 2 after dark green science (only normal green science in base)

--------------------------------------------------
-- Oil
--------------------------------------------------

-- 1. Inserter 2 capacity bonus behind blue science
-- 2. Accumulators take a lot of energy, but don't give much in return
-- 3. Landmines explode you too
-- 4. They're physical plants, not chemical plants
-- 5. Crude oil patch changes
-- 6. Small biter sprites are now behemoths
-- 7. Flamethrowers have a weird arc
-- 8. Make cliff explosives more explosive
-- 9. Rename efficiency modules to ef-fish-iency modules
-- 10. Explosives on belts explode
-- 11. Tanks look like storage tanks
-- 12. Sit down and think really hard tech

--------------------------------------------------
-- Bots
--------------------------------------------------

-- 1. The heavy oil solid fuel recipe is actually the best one
-- 2. On the 8th hour, insert spoons into each player's inventory
-- 3. Nuclear fish
-- 4. Oil fish
-- 5. Cheeseman
-- 6. Lubricant is now an item
-- 7. Uranium probabilities flipped
-- 8. Water 2
-- 9. Switch colors of red and yellow chests
-- 10. Nuclear reactors have 1 health
-- 11. Processing units are fluids
-- 12. Prod mod 2's are actually very good
-- 13. Bot breeding
-- 14. Roller skates
-- 15. Transport belt rotation tech

--------------------------------------------------
-- Purple/Yellow
--------------------------------------------------

-- 1. Coal liquefaction is now oil solidification
-- 2. Low density structure needs a lot of heavy things
-- 3. Bob the inserter
-- 4. A research just to regenerate biter bases
-- 5. Cliffside assemblers
-- 6. Lab 2.0
-- 7. Beacon limits

--------------------------------------------------
-- Rocket
--------------------------------------------------

-- 1. Absolutely useless and useful research
-- 2. Iterations of rocket fuel refining
-- 3. The rocket is a fish
-- 4. Rocket silo has tons of module slots but doesn't accept prods
-- 5. Bring back RCU's
-- 6. FUN letters
-- 7. Messages for getting far into the game
-- 8. Special description for rocket silo

--------------------------------------------------
-- Beta features
--------------------------------------------------

-- Changes listed in file

--------------------------------------------------
-- Execute last
--------------------------------------------------

-- 1. Item stack sizes are one lower to make them look annoying
-- 2. All fluid boxes are underground
-- 3. Swim (research to walk on water)
-- 4. Seahorses go with advanced circuits
-- 5. Mining something gives back its ingredients

--------------------------------------------------
-- Beta fixes
--------------------------------------------------

-- Changes listed in file

--------------------------------------------------
-- No spoilers
--------------------------------------------------

--------------------------------------------------
-- Normal visuals setting
--------------------------------------------------

--------------------------------------------------
--------------------------------------------------
-------------- Libraries -------------------------
--------------------------------------------------
--------------------------------------------------

local collision_mask_util = require("collision-mask-util")

local supporters = require("supporters")

require("beta-features")

function change_scale(tbl, factor)
    if type(tbl) == "table" then
        for _, val in pairs(tbl) do
            change_scale(val, factor)
        end

        if tbl["filename"] ~= nil then
            local scale = 1
            if tbl["scale"] ~= nil then
                scale = tbl["scale"]
            end
            tbl["scale"] = factor * scale
        end
    end
end

function shift_visuals(tbl, shift)
    if type(tbl) == "table" then
        for _, val in pairs(tbl) do
            shift_visuals(val, shift)
        end

        if tbl["filename"] ~= nil then
            local base_shift = {0, 0}
            if tbl["shift"] ~= nil then
                base_shift = tbl["shift"]
            end
            tbl["shift"] = {base_shift[1] + shift[1], base_shift[2] + shift[2]}
        end
    end

    return tbl
end

function reverse_animation(tbl)
    if type(tbl) == "table" then
        for key, val in pairs(tbl) do
            reverse_animation(val)
        end

        if tbl.frame_count ~= nil then
            tbl.run_mode = "backward"
        end
    end
end

function remove_tech_recipe_unlock(tech, recipe_name)
    effect_index = 0
    
    for ind, effect in pairs(tech.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
            effect_index = ind
        end
    end

    if effect_index ~= 0 then
        table.remove(tech.effects, effect_index)
    end
end

--------------------------------------------------
--------------------------------------------------
-------------- Implementation! -------------------
--------------------------------------------------
--------------------------------------------------

--------------------------------------------------
-- Startup
--------------------------------------------------

-- 1. Supporter fishies

for _, supporter in pairs(supporters) do
    local name = "supporter-fish-" .. string.gsub(supporter, " ", "-")
    data.raw.fish[name] = table.deepcopy(data.raw.fish.fish)
    data.raw.fish[name].name = name
    data.raw.fish[name].localised_name = supporter
    data.raw.fish[name].pictures[1] = {
        filename = "__fun_mode__/graphics/supporter-fish.png",
        height = 32,
        width = 32,
        priority = "extra-high"
    }
    data.raw.fish[name].pictures[2] = nil
    change_scale(data.raw.fish[name].pictures, 10)
    for x = 1, 2 do
        for y = 1, 2 do
            data.raw.fish[name].collision_box[x][y] = data.raw.fish[name].collision_box[x][y] * 5
            data.raw.fish[name].selection_box[x][y] = data.raw.fish[name].selection_box[x][y] * 10
        end
    end
    data.raw.fish[name].collision_mask = {layers = {player = true}}
    data.raw.fish[name].minable = nil
    data.raw.fish[name].max_health = 100000
    data.raw.fish[name].autoplace = nil
end

-- 2. Dying creates a character item

data:extend({
    {
        type = "item",
        name = "character-corpse",
        localised_name = "Dead body",
        subgroup = "raw-resource",
        icon = data.raw["utility-sprites"].default.character_reach_distance_modifier_icon.filename,
        icon_size = 64,
        stack_size = 10
    }
})
data.raw["character-corpse"]["character-corpse"].minable.results = {{type = "item", name = "character-corpse", amount = 1}}

-- 3. Mining the crashed ship gives you a heart attack

-- In control

-- 4. Character corpses move

data.raw["character-corpse"]["character-corpse"].minable.mining_time = 0.2
data.raw["character-corpse"]["character-corpse"].time_to_live = 0

-- 5. Inventory widths of 9

data.raw["utility-constants"].default.inventory_width = 9
data.raw.character.character.inventory_size = 72

-- 6. You can't touch water and you can fall off cliffs

data:extend({
    {
        type = "sound",
        name = "wilhelm",
        filename = "__fun_mode__/sounds/wilhelm.wav",
        volume = 3
    },
    {
        type = "technology",
        name = "finesse",
        localised_name = "Finesse",
        localised_description = "You learn enough finesse not to trip over certain vertical objects.",
        icon = data.raw.cliff.cliff.icon,
        icon_size = data.raw.cliff.cliff.icon_size,
        prerequisites = {
            "lab-2"
        },
        unit = {
            count = 250,
            time = 30,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"burner-inserter", 1}
            }
        },
        effects = {}
    }
})

-- 7. Ring of fire

data.raw.fire["fire-flame"].burnt_patch_lifetime = 10 * data.raw.fire["fire-flame"].burnt_patch_lifetime
data.raw.fire["fire-flame"].initial_lifetime = 4 * data.raw.fire["fire-flame"].initial_lifetime
data.raw.fire["fire-flame"].maximum_lifetime = 4 * data.raw.fire["fire-flame"].maximum_lifetime

-- 8. Biter rocks

local biter_type = "small-biter"
local biter_type_localised = "Small biter"
if dosh_mode then
    biter_type = "big-biter"
    biter_type_localised = "Big biter"
end

-- Item to alert players that rocks create biters
data:extend({
    {
        type = "item",
        name = "biter-item",
        localised_name = biter_type_localised,
        icon = data.raw["unit"][biter_type].icon,
        icon_size = data.raw["unit"][biter_type].icon_size,
        stack_size = 50,
        hidden = true
    }
})
rock_list = {
    small = {
        ["big-sand-rock"] = true,
        ["big-rock"] = true
    },
    huge = {
        ["huge-rock"] = true
    }
}
for rock_type, rocks in pairs(rock_list) do
    local amount = 6
    if rock_type == "huge" then
        amount = 10
    end
    for rock_name, _ in pairs(rocks) do
        data.raw["simple-entity"][rock_name].minable.results = {
            {type = "item", name = "biter-item", amount = amount}
        }
    end
end

-- 9. No fish normally

data.raw.fish.fish.autoplace = nil
data.raw.planet.nauvis.map_gen_settings.autoplace_settings.entity.settings.fish = nil

-- 10. No grass tiles or regular trees

local sandy_tiles = {}
for _, tile in pairs(data.raw.tile) do
    if string.find(tile.name, "sand") or string.find(tile.name, "desert") then
        table.insert(sandy_tiles, tile.name)
    end
end
local tile_to_new_tile = {}
for _, tile in pairs(data.raw.tile) do
    if string.find(tile.name, "dirt") or string.find(tile.name, "grass") then
        tile_to_new_tile[tile.name] = sandy_tiles[math.random(1, #sandy_tiles)]
    end
end
for old_tile, new_tile in pairs(tile_to_new_tile) do
    data.raw.tile[old_tile] = table.deepcopy(data.raw.tile[new_tile])
    data.raw.tile[old_tile].name = old_tile
end
local tree_list = {}
for _, tree in pairs(data.raw.tree) do
    if tree.name ~= "dead-grey-trunk" then
        tree_list[tree.name] = true
    end
end
for old_tree, _ in pairs(tree_list) do
    data.raw.tree[old_tree] = table.deepcopy(data.raw.tree["dead-grey-trunk"])
    data.raw.tree[old_tree].name = old_tree
end

-- 11. Fake alerts

data:extend({
    {
        type = "sound",
        name = "alert-destroyed",
        filename = "__fun_mode__/sounds/alert-destroyed.ogg",
        category = "alert"
    }
})

-- 12. Burner mining drills faster for faster start

data.raw["mining-drill"]["burner-mining-drill"].mining_speed = 0.5
data.raw["mining-drill"]["electric-mining-drill"].mining_speed = 0.49

-- 13. Some starting items to make the game faster

-- In control

-- 14. Wooden equipment

data.raw["roboport-equipment"]["wooden-roboport"] = table.deepcopy(data.raw["roboport-equipment"]["personal-roboport-equipment"])
data.raw["roboport-equipment"]["wooden-roboport"].name = "wooden-roboport"
data.raw["roboport-equipment"]["wooden-roboport"].localised_name = "Wooden roboport"
data.raw["roboport-equipment"]["wooden-roboport"].burner = {
    type = "burner",
    fuel_inventory_size = 1,
    burnt_inventory_size = 1,
    fuel_categories = {"wood"}
}
data.raw["roboport-equipment"]["wooden-roboport"].robot_limit = 20
data.raw["roboport-equipment"]["wooden-roboport"].power = "500kW"
data.raw["roboport-equipment"]["wooden-roboport"].charging_energy = "5MW"
data.raw["roboport-equipment"]["wooden-roboport"].sprite.filename = "__fun_mode__/graphics/wooden-roboport.png"
data:extend({
    {
        type = "fuel-category",
        name = "wood",
        localised_name = "Wood"
    },
    {
        type = "equipment-grid",
        name = "wooden-armor-grid",
        width = 2,
        height = 2,
        equipment_categories = {"armor"},
        locked = true
    },
    {
        type = "armor",
        name = "wooden-armor",
        localised_name = "Wooden armor",
        equipment_grid = "wooden-armor-grid",
        resistances = {
            {
                type = "physical",
                percent = 15
            },
            {
                type = "fire",
                percent = -300
            },
            {
                type = "acid",
                percent = -100
            }
        },
        infinite = true,
        stack_size = 1,
        icon = "__fun_mode__/graphics/wooden-armor.png",
        icon_size = 64,
        flags = {
            "not-stackable"
        }
    }
})
-- Add wood as fuel category
local function add_wood_to_fuel_categories(tbl)
    for key, val in pairs(tbl) do
        if type(val) == "table" then
            add_wood_to_fuel_categories(val)
        end
    end

    -- Check if this is a burner energy source
    if tbl["type"] == "burner" and tbl["fuel_inventory_size"] ~= nil then
        if tbl["fuel_categories"] == nil then
            tbl["fuel_categories"] = {"chemical"}
        end

        local has_chemical = false
        for _, category in pairs(tbl["fuel_categories"]) do
            if category == "chemical" then
                has_chemical = true
            end
        end
        if has_chemical then
            table.insert(tbl["fuel_categories"], "wood")
        end
    end
end
add_wood_to_fuel_categories(data.raw)
data.raw.item.wood.fuel_category = "wood"
-- Make wood a little better of a fuel
data.raw.item.wood.fuel_value = "4MJ"

-- 15. 20.01 meter pole

data:extend({
    {
        type = "item",
        name = "pole",
        localised_name = "20.01m pole",
        subgroup = "gun",
        icon = "__fun_mode__/graphics/icons/pole.png",
        icon_size = 64,
        stack_size = 1
    }
})

-- 16. Giving entities Greenosity
data.raw["fish"]["fish"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.74%"}
    },
}
data.raw["assembling-machine"]["assembling-machine-3"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.49%"}
    },
}
data.raw["power-switch"]["power-switch"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.0%"}
    },
}
data.raw["rail-signal"]["rail-signal"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.???%"}
    },
}
data.raw["power-switch"]["power-switch"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.0%"}
    },
}
data.raw["item"]["uranium-ore"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.74%"}
    },
}
data.raw["power-switch"]["power-switch"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.0%"}
    },
}
data.raw["tool"]["logistic-science-pack"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.99%"}
    },
}
data.raw["container"]["crash-site-spaceship"].custom_tooltip_fields =
{
    { 
        name = {"fun-mode-funtoids.greenosity"},
        value = {"fun-mode-funtoids.this-is-yellow%"}
    },
}

--------------------------------------------------
-- Electricity
--------------------------------------------------

-- 1. Switch boiler fluid boxes

-- Switch fluid boxes
local temp_fluid_box = table.deepcopy(data.raw.boiler.boiler.fluid_box)
data.raw.boiler.boiler.fluid_box = table.deepcopy(data.raw.boiler.boiler.output_fluid_box)
data.raw.boiler.boiler.output_fluid_box = temp_fluid_box
-- Fix input/outputs and filters
data.raw.boiler.boiler.fluid_box.production_type = "input-output"
data.raw.boiler.boiler.fluid_box.filter = "water"
for _, pipe_connection in pairs(data.raw.boiler.boiler.fluid_box.pipe_connections) do
    pipe_connection.flow_direction = "input-output"
end
data.raw.boiler.boiler.output_fluid_box.production_type = "output"
data.raw.boiler.boiler.output_fluid_box.filter = "steam"
for _, pipe_connection in pairs(data.raw.boiler.boiler.output_fluid_box.pipe_connections) do
    pipe_connection.flow_direction = "output"
end

-- 2. Electring mining drills have larger mining area

data.raw["mining-drill"]["electric-mining-drill"].resource_searching_radius = 4.49

-- 3. All backer names are now "Fun"

-- In control

-- 4. Mercy research

data:extend({
    {
        type = "technology",
        name = "mercy",
        localised_name = "Mercy",
        localised_description = "exfret give'th, and exfret take'th away.",
        icon = "__fun_mode__/graphics/savior.png",
        icon_size = 600,
        unit = {
            count = 5,
            time = 10,
            ingredients = {
                {"automation-science-pack", 1}
            }
        },
        prerequisites = {
            "automation-science-pack"
        },
        effects = {
            {type = "laboratory-productivity", modifier = 0.01}
        }
    }
})

-- 5. Burnt result of coal is fish

data.raw.item.coal.burnt_result = "raw-fish"
data:extend({
    {
        type = "recipe",
        name = "get-rid-of-fish",
        localised_name = "Get rid of fish",
        icon = "__fun_mode__/graphics/get-rid-of-fish.png",
        icon_size = 64,
        subgroup = "raw-resource",
        ingredients = {{type = "item", name = "raw-fish", amount = 1}},
        results = {},
        energy_required = 1
    }
})
-- Add burnt_inventory_size's to burner entities
data.raw.boiler.boiler.energy_source.burnt_inventory_size = 3
data.raw["mining-drill"]["burner-mining-drill"].energy_source.burnt_inventory_size = 1
data.raw.inserter["burner-inserter"].energy_source.burnt_inventory_size = 1
data.raw.furnace["stone-furnace"].energy_source.burnt_inventory_size = 1
data.raw.furnace["steel-furnace"].energy_source.burnt_inventory_size = 1
data.raw.locomotive.locomotive.energy_source.burnt_inventory_size = 1
data.raw.car.car.energy_source.burnt_inventory_size = 1
data.raw.car.tank.energy_source.burnt_inventory_size = 1
-- Add fish to selection lists
data.raw.capsule["raw-fish"].flags = {"always-show"}

-- 6. Inserters are only certain directions

-- In control

-- 7. You start with big electric poles rather than small ones

data.raw.recipe["big-electric-pole"].ingredients = {
    {type = "item", name = "iron-stick", amount = 1},
    {type = "item", name = "copper-cable", amount = 2}
}
table.insert(data.raw.technology.electronics.effects, {type = "unlock-recipe", recipe = "big-electric-pole"})
remove_tech_recipe_unlock(data.raw.technology.electronics, "small-electric-pole")
data.raw.technology["electric-energy-distribution-1"].effects = {
    {type = "unlock-recipe", recipe = "medium-electric-pole"}
}
data.raw.technology["electric-energy-distribution-1"].icon = "__fun_mode__/graphics/electric-energy-distribution-1.png"
data.raw.technology["electric-energy-distribution-1"].icon_size = 256
data.raw.technology["electric-energy-distribution-1"].icon_mipmaps = 1
data.raw["electric-pole"]["medium-electric-pole"].supply_area_distance = 2.5
data.raw["electric-pole"]["medium-electric-pole"].maximum_wire_distance = 7.5
data.raw.recipe["iron-stick"].enabled = true
remove_tech_recipe_unlock(data.raw.technology["railway"], "iron-stick")
remove_tech_recipe_unlock(data.raw.technology["circuit-network"], "iron-stick")

-- 8. Transport belt animations are weird

-- Transport belt animations are weird
local belt_classes = {
    "transport-belt",
    "underground-belt",
    "splitter",
    "loader",
    "loader-1x1"
}
for _, class in pairs(belt_classes) do
    for _, belt in pairs(data.raw[class]) do
        -- Keep fast belts normal for extra confusion
        if belt.speed ~= 0.0625 then
            belt.animation_speed_coefficient = belt.animation_speed_coefficient * -1
        end
    end
end

-- 10. Offshore pumps lower pumping speed

data.raw["offshore-pump"]["offshore-pump"].pumping_speed = 0.1

--------------------------------------------------
-- Red science
--------------------------------------------------

-- 1. Various things smelt into upgraded versions of themselves

-- Make flamethrower turret cheap since it's bad now
data.raw.recipe["flamethrower-turret"].category = "smelting"
data.raw.recipe["flamethrower-turret"].ingredients = {{type = "item", name = "gun-turret", amount = 1}}
data.raw.recipe["explosive-cannon-shell"].category = "smelting"
data.raw.recipe["explosive-cannon-shell"].ingredients = {{type = "item", name = "cannon-shell", amount = 2}}
data.raw.recipe["explosive-rocket"].category = "smelting"
data.raw.recipe["explosive-rocket"].ingredients = {{type = "item", name = "rocket", amount = 2}}
data.raw.recipe["cluster-grenade"].category = "smelting"
data.raw.recipe["cluster-grenade"].ingredients = {{type = "item", name = "grenade", amount = 5}}
data.raw.recipe["steam-turbine"].category = "smelting"
data.raw.recipe["steam-turbine"].ingredients = {{type = "item", name = "steam-engine", amount = 5}}
data.raw.recipe["heat-exchanger"].category = "smelting"
data.raw.recipe["heat-exchanger"].ingredients = {{type = "item", name = "boiler", amount = 5}}

-- 2. Peperos

data.raw.character.peperos = table.deepcopy(data.raw.character.character)
data.raw.character.peperos.name = "peperos"
data.raw.character.peperos.localised_name = "Peperos"
data.raw.character.exfret = table.deepcopy(data.raw.character.character)
data.raw.character.exfret.name = "exfret"
data.raw.character.exfret.localised_name = "exfret"

-- 3. Heavy armor slows you down

-- In control

-- 4. Unique challenges that happen every now and then

-- Allow making permanent things back to non-permanent
data:extend({
    {
        type = "technology",
        name = "instability",
        localised_name = "Instability",
        localised_description = "Change any permanent buildings back to normal.",
        icon = data.raw["utility-sprites"].default.refresh.filename,
        icon_size = data.raw["utility-sprites"].default.refresh.size,
        max_level = "infinite",
        unit = {
            count_formula = "200",
            time = 10,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            }
        },
        prerequisites = {
            "chemical-science-pack"
        },
        effects = {
        }
    }
})

-- 5. Wall has 2x2 grid

data.raw.wall["stone-wall"].build_grid_size = 2
data.raw.wall["stone-wall-2"] = table.deepcopy(data.raw.wall["stone-wall"])
data.raw.wall["stone-wall-2"].name = "stone-wall-2"
data.raw.wall["stone-wall-2"].localised_name = "Better wall"
table.insert(data.raw.wall["stone-wall-2"].flags, "placeable-off-grid")
data.raw.wall["stone-wall-2"].minable.results = {{type = "item", name = "stone-wall-2", amount = 1}}
data:extend({
    {
        type = "technology",
        name = "stone-wall-2",
        localised_name = "Better walls",
        localised_description = "Walls without a grid requirement.",
        icon = "__fun_mode__/graphics/wall-2.png",
        icon_size = 64,
        unit = {
            count = 25,
            time = 45,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            }
        },
        prerequisites = {
            "military-2",
            "stone-wall"
        },
        effects = {
            {type = "unlock-recipe", recipe = "stone-wall-2"}
        }
    },
    {
        type = "recipe",
        name = "stone-wall-2",
        ingredients = {
            {type = "item", name = "stone-wall", amount = 1}
        },
        results = {
            {type = "item", name = "stone-wall-2", amount = 1}
        },
        energy_required = 2,
        enabled = false
    },
    {
        type = "item",
        name = "stone-wall-2",
        localised_name = "Better wall",
        subgroup = "defensive-structure",
        order = "a[stone-wall]-a[stone-wall]-2",
        icon = "__fun_mode__/graphics/wall-2.png",
        icon_size = 64,
        stack_size = 100,
        place_result = "stone-wall-2"
    }
})

-- 6. Need to unlock storage

data.raw.recipe["wooden-chest"].enabled = false
data.raw.recipe["iron-chest"].enabled = false
data:extend({
    {
        type = "technology",
        name = "storage",
        localised_name = "Storage",
        localised_description = "Coming up with the idea of storage requires thinking outside the box.",
        icon = data.raw.item["iron-chest"].icon,
        icon_size = data.raw.item["iron-chest"].icon_size,
        icon_mipmaps = data.raw.item["iron-chest"].icon_mipmaps,
        unit = {
            count = 30,
            time = 15,
            ingredients = {
                {"automation-science-pack", 1}
            }
        },
        prerequisites = {
            "automation-science-pack"
        },
        effects = {
            {type = "unlock-recipe", recipe = "wooden-chest"},
            {type = "unlock-recipe", recipe = "iron-chest"},
            {type = "unlock-recipe", recipe = "steel-chest"}
        }
    }
})
remove_tech_recipe_unlock(data.raw.technology["steel-processing"], "steel-chest")

-- 7. Repair packs need to be used by bots

data.raw["repair-tool"]["repair-pack"].localised_name = "Complex doohickey"
data.raw.technology["repair-pack"].localised_name = "Complex doohickey"

-- 8. Squished assembling machines

local assm_anim = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"].graphics_set.animation)
local width_layers = table.deepcopy(assm_anim)
width_layers.layers[1].width = 72
width_layers.layers[2].width = 72
width_layers.layers[1].height = 104
width_layers.layers[2].height = 104
width_layers.layers[1].filename = "__fun_mode__/graphics/assembling-machine-1-width.png"
width_layers.layers[2].filename = "__fun_mode__/graphics/assembling-machine-1-width.png"
local height_layers = table.deepcopy(assm_anim)
height_layers.layers[1].width = 107
height_layers.layers[2].width = 107
height_layers.layers[1].height = 76
height_layers.layers[2].height = 76
height_layers.layers[1].filename = "__fun_mode__/graphics/assembling-machine-1-height.png"
height_layers.layers[2].filename = "__fun_mode__/graphics/assembling-machine-1-height.png"
data.raw["assembling-machine"]["assembling-machine-1"].graphics_set.animation = {
    north = table.deepcopy(width_layers),
    east = table.deepcopy(height_layers),
    south = table.deepcopy(width_layers),
    west = table.deepcopy(height_layers)
}
-- For some reason it's off by a factor of 2, so upsize it
change_scale(data.raw["assembling-machine"]["assembling-machine-1"].graphics_set.animation, 2)
data.raw["assembling-machine"]["assembling-machine-1"].collision_box = {{-0.7, -1.2}, {0.9, 1.2}}
data.raw["assembling-machine"]["assembling-machine-1"].selection_box = {{-0.7, -1.2}, {0.9, 1.2}}
data.raw["assembling-machine"]["assembling-machine-1"].next_upgrade = nil

-- 9. Lamps don't turn on

local lamp = data.raw.lamp["small-lamp"]
lamp.picture_on = lamp.picture_off
lamp.light = nil
lamp.light_when_colored = nil
lamp.glow_size = 0
lamp.glow_color_intensity = 0

-- 10. Steel smelts in bulk

-- Note: this is actually a better recipe since time is x10 less, and you need half the iron plates
data.raw.recipe["steel-plate"].energy_required = 100 * data.raw.recipe["steel-plate"].energy_required
data.raw.recipe["steel-plate"].ingredients = {
    {type = "item", name = "iron-plate", amount = 2500}
}
data.raw.recipe["steel-plate"].results = {
    {type = "item", name = "steel-plate", amount = 1000}
}

-- 11. You only get one underground belt when crafting

data.raw.recipe["underground-belt"].results = {{type = "item", name = "underground-belt", amount = 1}}
data.raw.recipe["fast-underground-belt"].ingredients = {
    {type = "item", name = "iron-gear-wheel", amount = 20},
    {type = "item", name = "underground-belt", amount = 1}
}
data.raw.recipe["fast-underground-belt"].results = {{type = "item", name = "fast-underground-belt", amount = 1}}
-- Changing ingredients for express belts is done elsewhere anyways and more complicated so skip it
-- EDIT: Changed back to not using water 2 v2 so set ingredients here
data.raw.recipe["express-underground-belt"].ingredients = {
    {type = "item", name = "iron-gear-wheel", amount = 40},
    {type = "item", name = "fast-underground-belt", amount = 1},
    {type = "fluid", name = "lubricant", amount = 20}
}
data.raw.recipe["express-underground-belt"].results = {{type = "item", name = "express-underground-belt", amount = 1}}

-- 12. Research for longness

data:extend({
    {
        type = "technology",
        name = "longness",
        localised_name = "Longness",
        localised_description = "Figure out how to make things long.",
        icon = data.raw.item["long-handed-inserter"].icon,
        icon_size = data.raw.item["long-handed-inserter"].icon_size,
        icon_mipmaps = data.raw.item["long-handed-inserter"].icon_mipmaps,
        prerequisites = {
            "automation"
        },
        unit = {
            count = 75,
            time = 15,
            ingredients = {
                {"automation-science-pack", 1}
            }
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "long-handed-inserter"
            }
        }
    },
    {
        type = "technology",
        name = "longer-arms",
        localised_name = "Longer arms",
        localised_description = "You take a pill to have them double in size!",
        icon = "__fun_mode__/graphics/technology/arm.png",
        icon_size = 64,
        unit = {
            count = 100,
            time = 15,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            }
        },
        prerequisites = {
            "longness",
            "logistic-science-pack"
        },
        effects = {
            {
                type = "character-reach-distance",
                modifier = 10
            },
            {
                type = "character-build-distance",
                modifier = 10
            },
            {
                type = "character-item-drop-distance",
                modifier = 10
            }
        }
    }
})
remove_tech_recipe_unlock(data.raw.technology.automation, "long-handed-inserter")
table.insert(data.raw.technology.railway.prerequisites, "longness")

-- 13. Min distance between undergrounds

-- TABLED
--[[data:extend({
    {
        type = "simple-entity-with-owner",
        name = "underground-preventer",
        localised_name = "Too close to another underground",
        collision_mask = {
            layers = {
                underground_belt = true
            }
        },
        collision_box = {
            {-2, -0.5},
            {2, 0.5}
        }
    },
    {
        type = "collision-layer",
        name = "underground_belt"
    }
})
for _, underground_belt in pairs(data.raw["underground-belt"]) do
    if underground_belt.collision_mask == nil then
        underground_belt.collision_mask = collision_mask_util.get_default_mask("underground-belt")
    end

    underground_belt.collision_mask.layers["underground_belt"] = true
end]]

--------------------------------------------------
-- Green science
--------------------------------------------------

-- 1. Chain signals are far into the tech tree

-- Need to bring back the nice signals tech that was in 1.0
--[[data:extend({
    {
        type = "technology",
        name = "rail-signals",
        localised_name = "Rail chain signals",
        localised_description = "They call it a \"chain\" signal because of all the techs it's locked behind.",
        order = "c-g-c",
        icon = "__fun_mode__/graphics/legacy/rail-signals.png",
        icon_size = 256,
        icon_mipmaps = 4,
        prerequisites = {
            "automated-rail-transportation",
            "robotics"
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
            {type = "unlock-recipe", recipe = "rail-chain-signal"}
        }
    }
})
remove_tech_recipe_unlock(data.raw.technology["automated-rail-transportation"], "rail-chain-signal")]]

-- 2. Lunar panels

-- First, make them more powerful
data.raw["solar-panel"]["solar-panel"].production = "150kW"
-- Now change localisations
data.raw["dont-use-entity-in-energy-production-achievement"]["solaris"].localised_name = "Lunaris"
data.raw["dont-use-entity-in-energy-production-achievement"]["solaris"].localised_description = "Produce more than 10 GJ per hour using only lunar panels."
data.raw["use-entity-in-energy-production-achievement"]["solar-power"].localised_name = "Lunar power"
data.raw["use-entity-in-energy-production-achievement"]["solar-power"].localised_description = "Start producing power by lunar panels."
data.raw["dont-use-entity-in-energy-production-achievement"]["steam-all-the-way"].localised_description = "Launch a rocket to space without using any lunar panels."
data.raw["solar-panel"]["solar-panel"].localised_name = "Lunar panel"
data.raw["solar-panel"]["solar-panel"].localised_description = "During daytime it produces 0% of the power output which increases to 100% at night."
data.raw["solar-panel-equipment"]["solar-panel-equipment"].localised_name = "Portable lunar panel"
data.raw.technology["solar-energy"].localised_name = "Lunar energy"
data.raw.technology["solar-energy"].localised_description = "Source of free electric energy, but useless at day."
data.raw.technology["solar-panel-equipment"].localised_name = "Portable lunar panel"
data.raw.technology["solar-panel-equipment"].localised_description = "Inserted into armor to power other equipment, but useless at day."

-- 3. Logistic science takes 6.1 seconds

data.raw.recipe["logistic-science-pack"].energy_required = 6.1

-- 4. Switch red and green wire colors

local temp_red_wire_sprite = table.deepcopy(data.raw["utility-sprites"].default.red_wire)
data.raw["utility-sprites"].default.red_wire = table.deepcopy(data.raw["utility-sprites"].default.green_wire)
data.raw["utility-sprites"].default.green_wire = temp_red_wire_sprite

-- 5. Sacrifices to exfret

-- Note: we have to give coins to player or else the manual crafting event doesn't trigger
-- Only allow the player to carry out sacrifices
table.insert(data.raw.character.character.crafting_categories, "crafting-by-hand")
data:extend({
    {
        type = "recipe-category",
        name = "crafting-by-hand"
    },
    -- Add a whole new tab just for sacrifices
    {
        type = "item-group",
        name = "sacrifices",
        icon = "__fun_mode__/graphics/sacrifices/main-icon.png",
        icon_size = 64,
        localised_name = "Sacrifices",
        order = "z[sacrifices]"
    },
    {
        type = "item-subgroup",
        name = "sacrifices",
        group = "sacrifices"
    },
    -- The sacrifice recipes
    {
        type = "recipe",
        name = "sacrifice-steel-plate",
        localised_name = "Sacrifice steel plates",
        subgroup = "sacrifices",
        order = "c",
        icon = "__fun_mode__/graphics/sacrifices/steel-plate.png",
        icon_size = 64,
        category = "crafting-by-hand",
        ingredients = {
            {type = "item", name = "steel-plate", amount = 1000}
        },
        results = {{type = "item", name = "coin", amount = 1}},
        energy_required = 2,
        enabled = false
    },
    {
        type = "recipe",
        name = "sacrifice-oil-patch",
        localised_name = "Sacrifice grape juice",
        subgroup = "sacrifices",
        order = "e",
        icon = "__fun_mode__/graphics/sacrifices/crude-oil.png",
        icon_size = 64,
        category = "crafting-by-hand",
        ingredients = {
            {type = "item", name = "oil-patch", amount = 5}
        },
        results = {{type = "item", name = "coin", amount = 1}},
        energy_required = 2,
        enabled = false
    },
    {
        type = "recipe",
        name = "sacrifice-explosives",
        localised_name = "Sacrifice explosives (quickly!)",
        subgroup = "sacrifices",
        order = "f",
        icon = "__fun_mode__/graphics/sacrifices/explosives.png",
        icon_size = 64,
        category = "crafting-by-hand",
        ingredients = {
            {type = "item", name = "explosives", amount = 100}
        },
        results = {{type = "item", name = "coin", amount = 1}},
        energy_required = 0.1,
        enabled = false
    },
    {
        type = "recipe",
        name = "sacrifice-logistic-robot",
        localised_name = "Sacrifice logistic robots",
        subgroup = "sacrifices",
        order = "g",
        icon = "__fun_mode__/graphics/sacrifices/logistic-robot.png",
        icon_size = 64,
        category = "crafting-by-hand",
        ingredients = {
            {type = "item", name = "logistic-robot", amount = 1000}
        },
        results = {{type = "item", name = "coin", amount = 1}},
        energy_required = 2,
        enabled = false
    },
    {
        type = "recipe",
        name = "sacrifice-peperos",
        localised_name = "Sacrifice your friend, Peperos",
        subgroup = "sacrifices",
        order = "z",
        icon = "__fun_mode__/graphics/sacrifices/peperos.png",
        icon_size = 64,
        category = "crafting-by-hand",
        ingredients = {},
        results = {{type = "item", name = "coin", amount = 1}},
        energy_required = 5,
        enabled = false
    },
    {
        type = "recipe",
        name = "sacrifice-exfret",
        localised_name = "Sacrifice your friend, exfret",
        subgroup = "sacrifices",
        order = "z",
        icon = "__fun_mode__/graphics/sacrifices/exfret.png",
        icon_size = 64,
        category = "crafting-by-hand",
        ingredients = {},
        results = {{type = "item", name = "coin", amount = 1}},
        energy_required = 5,
        enabled = false
    },
    -- Sacrifices technology
    {
        type = "technology",
        name = "sacrifices",
        localised_name = "Sacrifices",
        localised_description = "Make one-time sacrifices to exfret for +10% lab productivity each for non-fish sacrifices. Fish sacrifices are +5% lab productivity per fish tier.",
        icon = "__fun_mode__/graphics/sacrifices/main-icon.png",
        icon_size = 64,
        prerequisites = {
            "steel-processing",
            "logistic-science-pack"
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
            {type = "unlock-recipe", recipe = "sacrifice-steel-plate"},
            {type = "unlock-recipe", recipe = "sacrifice-oil-patch"},
            {type = "unlock-recipe", recipe = "sacrifice-explosives"},
            {type = "unlock-recipe", recipe = "sacrifice-logistic-robot"},
            --{type = "unlock-recipe", recipe = "sacrifice-peperos"}
        }
    }
})
-- Fish sacrifices
data:extend({
    {
        type = "item-subgroup",
        name = "fish-combine",
        group = "sacrifices",
        order = "zz"
    },
    {
        type = "item-subgroup",
        name = "fish-sacrifice",
        group = "sacrifices",
        order = "zzz"
    },
    -- Fish 1 sacrifice
    {
        type = "recipe",
        name = "sacrifice-fish-1",
        localised_name = "Sacrifice fish",
        subgroup = "fish-sacrifice",
        order = "zz01",
        icon = "__fun_mode__/graphics/sacrifices/lizzy-fish-bowl.png",
        icon_size = 400,
        category = "crafting-by-hand",
        ingredients = {
            {type = "item", name = "raw-fish", amount = 100}
        },
        results = {{type = "item", name = "coin", amount = 1}},
        energy_required = 2,
        enabled = false
    }
})
table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = "sacrifice-fish-1"})
-- Fish tiers 2 through 12 with sacrifices
for i = 2, 12 do
    local ing = {{type = "item", name = "fish-" .. tostring(i - 1), amount = 2}}
    if i == 2 then
        ing = {{type = "item", name = "raw-fish", amount = 2}}
    end
    local name = "fish-" .. tostring(i)
    data.raw.capsule[name] = table.deepcopy(data.raw.capsule["raw-fish"])
    data.raw.capsule[name].name = name
    data.raw.capsule[name].localised_name = "Fish " .. tostring(i)
    data.raw.capsule[name].subgroup = "fish-combine"
    local first_digit = "0"
    if i >= 10 then
        first_digit = ""
    end
    data:extend({
        -- Fish combining recipe
        {
            type = "recipe",
            name = name,
            subgroup = "fish-combine",
            order = "zy" .. first_digit .. tostring(i),
            ingredients = ing,
            results = {{type = "item", name = name, amount = 1}},
            energy_required = 1,
            enabled = false
        },
        -- Fish sacrifice recipe
        {
            type = "recipe",
            name = "sacrifice-" .. name,
            localised_name = "Sacrifice fish " .. tostring(i),
            subgroup = "fish-sacrifice",
            order = "zz" .. first_digit .. tostring(i),
            icon = "__fun_mode__/graphics/sacrifices/lizzy-fish-bowl.png",
            icon_size = 400,
            category = "crafting-by-hand",
            ingredients = {
                {type = "item", name = name, amount = 100}
            },
            results = {{type = "item", name = "coin", amount = 1}},
            energy_required = 2,
            enabled = false
        }
    })
    table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = name})
    table.insert(data.raw.technology.sacrifices.effects, {type = "unlock-recipe", recipe = "sacrifice-" .. name})
end
-- Extra recipe ingredients for spice
-- Define seahorses/fish glue
data:extend({
    {
        type = "item",
        name = "seahorse",
        localised_name = "Seahorse",
        localised_description = "Horses of the sea; used for glue.",
        subgroup = "raw-resource",
        icon = "__fun_mode__/graphics/sacrifices/seahorse.png",
        icon_size = 64,
        stack_size = 100,
        drop_sound = {
            filename = "__fun_mode__/sounds/horse-neigh.wav"
        },
        pick_sound = {
            filename = "__fun_mode__/sounds/horse-neigh.wav"
        },
    },
    {
        type = "recipe",
        name = "get-rid-of-seahorse",
        localised_name = "Fishify seahorse",
        subgroup = "raw-resource",
        icon = "__fun_mode__/graphics/sacrifices/fishify-seahorse.png",
        icon_size = 64,
        ingredients = {
            {type = "item", name = "seahorse", amount = 1}
        },
        results = {{type = "item", name = "raw-fish", amount = 2}},
        energy_required = 1,
        enabled = false,
        allow_decomposition = false
    },
    {
        type = "item",
        name = "fish-glue",
        localised_name = "Fish glue",
        localised_description = "To glue masses of writhing fish flesh together.",
        subgroup = "intermediate-product",
        icon = "__fun_mode__/graphics/sacrifices/glue.png",
        icon_size = 64,
        stack_size = 50
    },
    {
        type = "recipe",
        name = "fish-glue",
        subgroup = "fish-combine",
        category = "crafting",
        order = "zzzz",
        ingredients = {
            {type = "item", name = "seahorse", amount = 1}
        },
        results = {{type = "item", name = "fish-glue", amount = 2}},
        energy_required = 1,
        enabled = false,
        allow_decomposition = false,
        allow_productivity = true
    }
})
-- Give seahorses as a byproduct of advanced circuits
data.raw.recipe["advanced-circuit"].results = {{type = "item", name = "advanced-circuit", amount = 1}, {type = "item", name = "seahorse", amount = 2}}
data.raw.recipe["advanced-circuit"].main_product = "advanced-circuit"
table.insert(data.raw.technology["advanced-circuit"].effects, {type = "unlock-recipe", recipe = "get-rid-of-seahorse"})
table.insert(data.raw.technology["advanced-circuit"].effects, {type = "unlock-recipe", recipe = "fish-glue"})
-- Ability to turn excess advanced circuits into seahorses
data:extend({
    {
        type = "recipe",
        name = "seahorse-from-advanced-circuit",
        localised_name = "Seahorse from advanced circuit",
        subgroup = "intermediate-product",
        order = "zzzzz",
        icon = "__fun_mode__/graphics/sacrifices/circuit-seahorse.png",
        icon_size = 64,
        category = "crafting",
        ingredients = {
            {type = "item", name = "advanced-circuit", amount = 1}
        },
        results = {{type = "item", name = "seahorse", amount = 4}},
        energy_required = 4,
        enabled = false,
        allow_decomposition = false
    }
})
table.insert(data.raw.technology["advanced-circuit"].effects, {type = "unlock-recipe", recipe = "seahorse-from-advanced-circuit"})
-- Spice up the fish recipes
table.insert(data.raw.recipe["fish-3"].ingredients, {type = "item", name = "copper-cable", amount = 1})
table.insert(data.raw.recipe["fish-4"].ingredients, {type = "item", name = "stone", amount = 1})
table.insert(data.raw.recipe["fish-5"].ingredients, {type = "item", name = "copper-plate", amount = 1})
table.insert(data.raw.recipe["fish-6"].ingredients, {type = "item", name = "fish-glue", amount = 1})
table.insert(data.raw.recipe["fish-7"].ingredients, {type = "item", name = "rail", amount = 1})
table.insert(data.raw.recipe["fish-8"].ingredients, {type = "fluid", name = "water-2", amount = 10})
data.raw.recipe["fish-8"].category = "crafting-with-fluid"
table.insert(data.raw.recipe["fish-9"].ingredients, {type = "item", name = "oil-fish", amount = 1})
table.insert(data.raw.recipe["fish-10"].ingredients, {type = "item", name = "explosives", amount = 1})
table.insert(data.raw.recipe["fish-11"].ingredients, {type = "item", name = "nuclear-fish", amount = 1})
table.insert(data.raw.recipe["fish-12"].ingredients, {type = "item", name = "space-science-pack", amount = 1})

-- 6. Offshore assemblers

data.raw["assembling-machine"]["assembling-machine-2"].crafting_speed = 3
data.raw["assembling-machine"]["assembling-machine-2"].module_slots = 2
data.raw["assembling-machine"]["assembling-machine-2"].energy_usage = "500kW"
if data.raw["assembling-machine"]["assembling-machine-2"].collision_mask == nil then
    data.raw["assembling-machine"]["assembling-machine-2"].collision_mask = collision_mask_util.get_default_mask("assembling-machine")
end
data.raw["assembling-machine"]["assembling-machine-2"].collision_mask.layers = {
    ["ground_tile"] = true,
    ["object"] = true,
    ["new_player"] = true
}
if data.raw.character.character.collision_mask == nil then
    data.raw.character.character.collision_mask = collision_mask_util.get_default_mask("character")
end
data.raw.character.character.collision_mask.layers["new_player"] = true
-- Character desn't collide with itself to allow teleportation
data.raw.character.character.collision_mask["not_colliding_with_itself"] = true
data.raw["assembling-machine"]["assembling-machine-2"].localised_name = "Offshore assembler"
data.raw["assembling-machine"]["assembling-machine-2"].next_upgrade = nil
data.raw.technology["automation-2"].localised_name = "Offshore assembler"
data.raw.technology["automation-2"].localised_description = "Assembling machines capable of both processing fluid ingredients and sitting on fluid surfaces."
data:extend({
    {
        type = "collision-layer",
        name = "water"
    },
    {
        type = "collision-layer",
        name = "new_player"
    }
})

-- 7. Trains are invisible

-- TODO

-- 8. No straight driving

-- In control

-- 9. Curved rails cost 99 rails but the rail recipe is overall cheaper

--[[ REMOVED (too weird)
data.raw["curved-rail-a"]["curved-rail-a"].placeable_by = {item = "rail", count = 99}
data.raw["curved-rail-b"]["curved-rail-b"].minable.count = 99
data.raw["rail-planner"]["rail"].stack_size = 500
data.raw.recipe["rail"].results = {
    {type = "item", name = "rail", amount = 5}
}]]

-- 10. Gates close when player is near

local gate = data.raw.gate.gate
reverse_animation(gate)
if gate.opened_collision_mask == nil then
    gate.opened_collision_mask = data.raw["utility-constants"]["default"]["default_collision_masks"]["gate/opened"]
end
gate.opened_collision_mask.layers = {item = true, object = true, player = true, water_tile = true, train = true}
if gate.collision_mask == nil then
    gate.collision_mask = collision_mask_util.get_default_mask("gate")
end
gate.collision_mask.layers = {object = true, item = true, floor = true, water_tile = true}

-- 11. Hazard concrete makes you vroom but damages you

local hazard_concretes = {"hazard-concrete-left", "hazard-concrete-right", "refined-hazard-concrete-left", "refined-hazard-concrete-right"}
for _, hazard_concrete in pairs(hazard_concretes) do
    -- This formula hurts my brain
    data.raw.tile[hazard_concrete].walking_speed_modifier = ((1.3 - data.raw.tile[hazard_concrete].walking_speed_modifier) / 0.2 * 2 + (data.raw.tile[hazard_concrete].walking_speed_modifier - 1.1) / 0.2 * 3 - 2) * 2 + 0.01 - 1
end

-- 12. Need a driver's license to drive

data:extend({
    {
        type = "technology",
        name = "driver-license",
        localised_name = "Driver's License",
        localised_description = "Get your license from the DMV.",
        icon = "__fun_mode__/graphics/driver_license_clipart.png",
        icon_size = 64,
        prerequisites = {
            "automobilism"
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
            {type = "unlock-recipe", recipe = "driver-license"}
        }
    },
    {
        type = "technology",
        name = "driving-lessons",
        localised_name = "Driving lessons",
        localised_description = "Learn how to drive better, you dumbo.",
        icon = "__fun_mode__/graphics/technology/driving-lessons.png",
        icon_size = 256,
        prerequisites = {
            "driver-license"
        },
        unit = {
            count = 100,
            time = 30,
            ingredients = {
                {"automation-science-pack", 1},
                {"dark-green-science", 1},
                {"chemical-science-pack", 1},
            }
        },
        effects = {}
    },
    {
        type = "recipe",
        name = "driver-license",
        ingredients = {
            {type = "item", name = "iron-plate", amount = 1}
        },
        results = {
            {type = "item", name = "driver-license", amount = 1}
        },
        enabled = false
    },
    {
        type = "item",
        name = "driver-license",
        localised_name = "Driver's License",
        subgroup = "transport",
        order = "b[personal-transport]-a[driver-license]",
        icon = "__fun_mode__/graphics/driver_license_clipart.png",
        icon_size = 64,
        stack_size = 1,
        flags = {"not-stackable"},
        pick_sound = data.raw.item["iron-plate"].pick_sound,
        drop_sound = data.raw.item["iron-plate"].drop_sound,
    }
})

-- 13. Research for the color green

data:extend({
    {
        type = "technology",
        name = "green",
        localised_name = "Green",
        localised_description = "You figure out how to make green stuff.",
        icon = "__fun_mode__/graphics/green.png",
        icon_size = 64,
        unit = {
            count = 200,
            time = 30,
            ingredients = {
                {"logistic-science-pack", 1}
            }
        },
        prerequisites = {
            "logistic-science-pack"
        },
        effects = {}
    }
})
table.insert(data.raw.technology["bulk-inserter"].prerequisites, "green")
table.insert(data.raw.technology["lubricant"].prerequisites, "green")
table.insert(data.raw.technology["uranium-processing"].prerequisites, "green")
table.insert(data.raw.technology["efficiency-module"].prerequisites, "green")

-- 14. Custom messages for certain people

-- In control

-- 15. Locomotives actively try to kill you

data:extend({
    {
        type = "sound",
        name = "thwoop",
        category = "game-effect",
        filename = "__fun_mode__/sounds/thwoop.wav",
        volume = 10
    }
})

-- 16. Iron plate prod bonus research

data:extend({
    {
        type = "technology",
        name = "iron-plate-productivity",
        localised_name = "Iron plate productivity",
        localised_description = "Okay, I lied, maybe I'll be a little merciful.",
        icon = "__fun_mode__/graphics/technology/iron-plate-prod.png",
        icon_size = 64,
        prerequisites = {
            "logistic-science-pack",
            "mercy"
        },
        unit = {
            count = 250,
            time = 30,
            ingredients = {
                {"logistic-science-pack", 1},
                {"automation-science-pack", 1}
            }
        },
        effects = {
            {type = "change-recipe-productivity", recipe = "iron-plate", change = 1}
        }
    }
})

-- 17. Toolbelt 2 after dark green science

data:extend({
    {
        type = "technology",
        name = "toolbelt-2",
        localised_name = "Toolbelt 2",
        localised_description = "A second toolbelt is helpful when your inventory is 9 slots wide.",
        icon = "__fun_mode__/graphics/technology/toolbelt-2.png",
        icon_size = 256,
        unit = {
            count = 200,
            time = 15,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            }
        },
        prerequisites = {
            "toolbelt",
            "logistic-science-pack"
        },
        effects = {
            {type = "character-inventory-slots-bonus", modifier = 10}
        }
    }
})

--------------------------------------------------
-- Oil
--------------------------------------------------

-- 1. Inserter 2 capacity bonus behind blue science

table.insert(data.raw.technology["inserter-capacity-bonus-2"].unit.ingredients, {"chemical-science-pack", 1})
table.insert(data.raw.technology["inserter-capacity-bonus-2"].prerequisites, "chemical-science-pack")

-- 2. Accumulators take a lot of energy, but don't give much in return

data.raw.accumulator.accumulator.energy_source.buffer_capacity = "500MJ"
data.raw.accumulator.accumulator.energy_source.input_flow_limit = "2MW"
data.raw.accumulator.accumulator.energy_source.output_flow_limit = "300kW"

-- 3. Landmines explode you too

-- In control

-- 4. They're physical plants, not chemical plants

data.raw.recipe.sulfur.ingredients = {
    {type = "fluid", name = "petroleum-gas", amount = 30}
}
table.insert(data.raw["assembling-machine"]["assembling-machine-2"].crafting_categories, "chemistry")
table.insert(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories, "chemistry")
data.raw["recipe-category"]["dummy"] = {type = "recipe-category", name = "dummy"}
data.raw["assembling-machine"]["chemical-plant"].crafting_categories = {"dummy"}
data.raw.item["chemical-plant"].place_result = "tree-01"
data.raw.item["chemical-plant"].localised_name = "Physical plant"
data.raw.recipe["chemical-plant"].ingredients = {{type = "item", name = "wood", amount = 1}}
data.raw.tree["tree-01"].localised_name = "Physical plant"
data.raw.technology["oil-processing"].localised_description = "Assemblers do all the chemical stuff nowadays."
-- Hotfix for oil cracking
data.raw.recipe["heavy-oil-cracking"].ingredients = {{type = "fluid", name = "heavy-oil", amount = 40}}
data.raw.recipe["light-oil-cracking"].ingredients = {{type = "fluid", name = "light-oil", amount = 30}}

-- 5. Crude oil patch changes

data:extend({
    {
        type = "item",
        name = "oil-patch",
        localised_name = "Grape juice spring",
        localised_description = "Don't let it slip through your fingers!",
        subgroup = "raw-resource",
        icon = "__base__/graphics/icons/crude-oil-resource.png",
        icon_mipmaps = 4,
        icon_size = 64,
        stack_size = 1,
        place_result = "crude-oil",
        flags = {
            "not-stackable"
        },
        fuel_category = "chemical",
        fuel_value = "250MJ",
        fuel_acceleration_multiplier = 0.5,
        fuel_top_speed_multiplier = 2
    },
    {
        type = "item",
        name = "nuclear-oil-patch",
        localised_name = "Yummy grape juice spring",
        localised_description = "Even yummier!",
        subgroup = "uranium-processing",
        icon = "__fun_mode__/graphics/nuclear-oil-patch-icon.png",
        icon_size = 64,
        icon_mipmaps = 4,
        stack_size = 1,
        place_result = "nuclear-crude-oil",
        flags = {
            "not-stackable"
        },
        fuel_category = "chemical",
        fuel_value = "250GJ",
        fuel_acceleration_multiplier = 10,
        fuel_top_speed_multiplier = 4
    },
    {
        type = "recipe",
        name = "nuclear-crude-oil",
        localised_name = "Yummy grape juice spring",
        localised_description = "Even yummier!",
        subgroup = "uranium-processing",
        category = "centrifuging",
        ingredients = {
            {type = "item", name = "oil-patch", amount = 1},
            {type = "item", name = "uranium-235", amount = 10}
        },
        results = {
            {type = "item", name = "nuclear-oil-patch", amount = 1}
        },
        energy_required = 180,
        enabled = false
    },
    {
        type = "recipe",
        name = "crude-oil-from-patch",
        localised_name = "Grape juice generation",
        subgroup = "fluid-recipes",
        category = "oil-processing",
        ingredients = {},
        results = {
            {type = "fluid", name = "crude-oil", amount = 100}
        },
        energy_required = 10,
        enabled = false
    }
})
data.raw.resource["crude-oil"].minable = {
    mining_time = 10,
    results = {{type = "item", name = "oil-patch", amount = 1}}
}
data.raw["mining-drill"].pumpjack.vector_to_place_result = {-1,1.75}
data.raw["mining-drill"].pumpjack.output_fluid_box = nil
data.raw.resource["crude-oil"].infinite = false
data.raw.resource["nuclear-crude-oil"] = table.deepcopy(data.raw.resource["crude-oil"])
data.raw.resource["nuclear-crude-oil"].name = "nuclear-crude-oil"
data.raw.resource["nuclear-crude-oil"].localised_name = "Nuclear oil patch"
data.raw.resource["nuclear-crude-oil"].minable = {
    mining_time = 20,
    results = {{type = "item", name = "nuclear-oil-patch", amount = 1}}
}
data.raw.resource["nuclear-crude-oil"].stages.sheet.filename = "__fun_mode__/graphics/nuclear-oil-patch-picture.png"
data.raw.resource["nuclear-crude-oil"].icon = "__fun_mode__/graphics/nuclear-oil-patch-icon.png"
data.raw.resource["nuclear-crude-oil"].icon_size = 64
data.raw.resource["nuclear-crude-oil"].icon_mipmaps = 4
data.raw.resource["nuclear-crude-oil"].infinite = false -- Not necessary because already set in crude oil... but just in case
table.insert(data.raw.technology["kovarex-enrichment-process"].effects, {type = "unlock-recipe", recipe = "nuclear-crude-oil"})
table.insert(data.raw.recipe["oil-refinery"].ingredients, {type = "item", name = "oil-patch", amount = 1})
table.insert(data.raw.technology["oil-processing"].effects, {type = "unlock-recipe", recipe = "crude-oil-from-patch"})
-- TODO: TEST
-- Change oil refinery recipe to give four at a time so we don't need too many oil patches
for _, ingredient in pairs(data.raw.recipe["oil-refinery"].ingredients) do
    if ingredient.name ~= "oil-patch" then
        ingredient.amount = ingredient.amount * 2
    end
end
data.raw.recipe["oil-refinery"].results[1].amount = data.raw.recipe["oil-refinery"].results[1].amount * 2
-- Remove prod on pumpjacks
data.raw["mining-drill"].pumpjack.allowed_effects = {"speed", "pollution", "consumption", "quality"}

-- 6. Small biter sprites are now behemoths

local unit_image_properties = {
    "run_animation",
    "alternative_attacking_frame_sequence",
    "dying_sound",
    "light",
    "render_layer",
    "running_sound_animation_positions",
    "walking_sound"
}
for _, property in pairs(unit_image_properties) do
    data.raw.unit["medium-biter"][property] = data.raw.unit["behemoth-biter"][property]
end
data.raw.unit["medium-biter"].attack_parameters.animation = data.raw.unit["behemoth-biter"].attack_parameters.animation

-- 7. Flamethrowers have a weird arc

data.raw.stream["flamethrower-fire-stream"].particle_horizontal_speed = 0.06
data.raw.stream["flamethrower-fire-stream"].vertical_acceleration = 0.0000001

-- 8. Make cliff explosives more explosive

table.insert(data.raw.recipe["cliff-explosives"].ingredients, {type = "item", name = "uranium-ore", amount = 1})
data.raw.technology["cliff-explosives"].localised_name = "Atomic cliff explosives"
data.raw.capsule["cliff-explosives"].localised_name = "Atomic cliff explosives"
local prev_action = table.deepcopy(data.raw.projectile["cliff-explosives"].action)
data.raw.projectile["cliff-explosives"].action = data.raw.projectile["atomic-rocket"].action
table.insert(data.raw.technology["cliff-explosives"].prerequisites, "uranium-mining")
table.insert(data.raw.technology["cliff-explosives"].unit.ingredients, {"chemical-science-pack", 1})
data.raw.ammo["atomic-bomb"].localised_name = "Cliff Explosive Rocket"
-- Remove processing units from recipe
data.raw.recipe["atomic-bomb"].ingredients = {{type = "item", name = "explosives", amount = 10}, {type = "item", name = "uranium-235", amount = 30}}
data.raw.technology["atomic-bomb"].localised_name = "Cliff Explosive Rocket"
data.raw.technology["atomic-bomb"].localised_description = "Not as good as the blue explosives."
data.raw.technology["atomic-bomb"].unit.count = 50
data.raw.projectile["atomic-rocket"].action = prev_action
data.raw.technology["atomic-bomb"].icons = {
    {
        icon = data.raw.technology["atomic-bomb"].icon,
        icon_size = data.raw.technology["atomic-bomb"].icon_size
    },
    {
        icon = data.raw.capsule["cliff-explosives"].icon,
        icon_size = data.raw.capsule["cliff-explosives"].icon_size,
        scale = 1,
        shift = {0, -0.4}
    }
}
data.raw.technology["atomic-bomb"].unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"military-science-pack", 1},
    {"chemical-science-pack", 1}
}
data.raw.technology["atomic-bomb"].prerequisites = {
    "cliff-explosives",
    "uranium-processing",
    "rocketry"
}

-- 9. Rename efficiency modules to ef-fish-iency modules

table.insert(data.raw.recipe["efficiency-module"].ingredients, {type = "item", name = "raw-fish", amount = 1})
data.raw.module["efficiency-module"].localised_name = "Ef-fish-iency Module"
data.raw.technology["efficiency-module"].localised_name = "Ef-fish-iency Module"
table.insert(data.raw.recipe["efficiency-module-2"].ingredients, {type = "item", name = "fish-2", amount = 1})
data.raw.module["efficiency-module-2"].localised_name = "Ef-fish-iency Module 2"
data.raw.technology["efficiency-module-2"].localised_name = "Ef-fish-iency Module 2"
table.insert(data.raw.recipe["efficiency-module-3"].ingredients, {type = "item", name = "fish-3", amount = 1})
data.raw.module["efficiency-module-3"].localised_name = "Ef-fish-iency Module 3"
data.raw.technology["efficiency-module-3"].localised_name = "Ef-fish-iency Module 3"

-- 10. Explosives on belts explode

-- Disable explosives from selection lists, like for requester chests
-- EDIT: Undoing this cuz it just feels weird
--data.raw.item.explosives.hidden = true

--------------------------------------------------
-- Bots
--------------------------------------------------

-- 1. The heavy oil solid fuel recipe is actually the best one

data.raw.recipe["solid-fuel-from-heavy-oil"].ingredients = {
    {type = "fluid", name = "heavy-oil", amount = 10}
}
data.raw.recipe["solid-fuel-from-light-oil"].ingredients = {
    {type = "fluid", name = "light-oil", amount = 100}
}
data.raw.recipe["solid-fuel-from-petroleum-gas"].ingredients = {
    {type = "fluid", name = "petroleum-gas", amount = 30}
}

-- 2. On the 8th hour, insert spoons into each player's inventory

data:extend({
    {
        type = "item",
        name = "spoon", 
        localised_name = "Spoon",
        icon = "__fun_mode__/graphics/spoon.png",
        icon_size = 64,
        stack_size = 1,
        flags = {
            "not-stackable"
        },
        hidden = true
    }
})

-- 11. Tanks look like storage tanks

data.raw.car.tank.animation = {
    filename = "__base__/graphics/entity/storage-tank/storage-tank.png",
    direction_count = 1,
    size = 215,
    scale = 108 / 215
}
data.raw.car.tank.light_animation = nil

-- 12. Sit down and think really hard tech

data:extend({
    {
        name = "sit",
        type = "technology",
        localised_name = "Sit down and think really hard",
        localised_description = "You have to stay very still to form your thoughts about something blue.",
        icon = "__fun_mode__/graphics/sit_tech.png",
        icon_size = 64,
        prerequisites = {
            "advanced-circuit",
            "sulfur-processing"
        },
        unit = {
            count = 100,
            time = 5,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            }
        },
        effects = {}
    }
})
data.raw.technology["chemical-science-pack"].prerequisites = {"sit"}

-- 3. Nuclear fish

data.raw.capsule["nuclear-fish"] = table.deepcopy(data.raw.capsule["raw-fish"])
data.raw.capsule["nuclear-fish"].name = "nuclear-fish"
data.raw.capsule["nuclear-fish"].localised_name = "Nuclear fish"
data.raw.capsule["nuclear-fish"].subgroup = "uranium-processing"
data.raw.capsule["nuclear-fish"].order = "h[raw-fish]"
data.raw.capsule["nuclear-fish"].icon = "__fun_mode__/graphics/nuclear-fish.png"
data.raw.capsule["nuclear-fish"].icon_size = 64
data.raw.capsule["nuclear-fish"].stack_size = 10
data.raw.capsule["nuclear-fish"].fuel_category = "nuclear"
data.raw.capsule["nuclear-fish"].fuel_value = "100GJ"
data.raw.capsule["nuclear-fish"].burnt_result = "raw-fish"
-- Nuclear fish is very yummy
data.raw.capsule["nuclear-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage.amount = 1000
data:extend({
    {
        type = "recipe",
        name = "nuclear-fish",
        category = "centrifuging",
        ingredients = {
            {type = "item", name = "raw-fish", amount = 500},
            {type = "item", name = "uranium-ore", amount = 100}
        },
        results = {{type = "item", name = "nuclear-fish", amount = 1}},
        energy_required = 30,
        enabled = false
    }
})
table.insert(data.raw.technology["nuclear-power"].effects, {type = "unlock-recipe", recipe = "nuclear-fish"})
-- Call it nuclear fish-ion
data.raw.technology["nuclear-power"].localised_name = "Nuclear fish-ion"
data.raw.technology["nuclear-power"].localised_description = "Power and sophisticated method of power generation using fish."
remove_tech_recipe_unlock(data.raw.technology["nuclear-power"], "uranium-fuel-cell")
data.raw.item["fission-reactor-equipment"].localised_name = "Portable fish-ion reactor"
data.raw.technology["fission-reactor-equipment"].localised_name = "Portable fish-ion reactor"
data.raw["generator-equipment"]["fission-reactor-equipment"].localised_name = "Portable fish-ion reactor"
data.raw.recipe["fission-reactor-equipment"].localised_name = "Portable fish-ion reactor"

-- 4. Oil fish

data.raw.capsule["oil-fish"] = table.deepcopy(data.raw.capsule["raw-fish"])
data.raw.capsule["oil-fish"].name = "oil-fish"
data.raw.capsule["oil-fish"].localised_name = "Grape-flavored fish"
data.raw.capsule["oil-fish"].subgroup = "raw-resource"
data.raw.capsule["oil-fish"].order = "h[raw-fish]"
data.raw.capsule["oil-fish"].icon = "__fun_mode__/graphics/oil-fish.png"
data.raw.capsule["oil-fish"].icon_size = 64
data.raw.capsule["oil-fish"].stack_size = 5
-- Oil fish is less yummy, but still delicious
data.raw.capsule["oil-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage.amount = 50
table.insert(data.raw.recipe["advanced-oil-processing"].results, {type = "item", name = "oil-fish", amount = 1})
data:extend({
    {
        type = "recipe",
        name = "get-rid-of-oil-fish",
        localised_name = "Get rid of grape-flavored fish",
        ingredients = {
            {type = "item", name = "oil-fish", amount = 2},
            {type = "item", name = "raw-fish", amount = 1}
        },
        icon = "__fun_mode__/graphics/get-rid-of-oil-fish.png",
        icon_size = 64,
        results = {},
        energy_required = 2,
        enabled = false,
        subgroup = "raw-resource",
        order = "h[raw-fish]"
    }
})
table.insert(data.raw.technology["advanced-oil-processing"].effects, {type = "unlock-recipe", recipe = "get-rid-of-oil-fish"})

-- 5. Cheeseman

-- Graphics
data.raw["electric-turret"].cheeseman = table.deepcopy(data.raw["electric-turret"]["laser-turret"])
data.raw["electric-turret"].cheeseman.name = "cheeseman"
data.raw["electric-turret"].cheeseman.localised_name = "Cheeseman"
data.raw["electric-turret"].cheeseman.energy_source = {type = "void"}
data.raw["electric-turret"].cheeseman.icon = "__fun_mode__/graphics/cheeseman.png"
data.raw["electric-turret"].cheeseman.icon_size = 156
local cheeseman_animation = {
    filename = "__fun_mode__/graphics/cheeseman.png",
    size = 156,
    direction_count = 1
}
data.raw["electric-turret"].cheeseman.folded_animation = table.deepcopy(cheeseman_animation)
data.raw["electric-turret"].cheeseman.folding_sound = nil
data.raw["electric-turret"].cheeseman.folding_animation = table.deepcopy(cheeseman_animation)
data.raw["electric-turret"].cheeseman.prepared_animation = table.deepcopy(cheeseman_animation)
data.raw["electric-turret"].cheeseman.preparing_animation = table.deepcopy(cheeseman_animation)
data.raw["electric-turret"].cheeseman.preparing_sound = nil
data.raw["electric-turret"].cheeseman.water_reflection = nil
data.raw["electric-turret"].cheeseman.base_picture = nil
data.raw["electric-turret"].cheeseman.resource_indicator_animation = nil
data.raw["electric-turret"].cheeseman.graphics_set = {
    base_visualization = {
        animation = {
            table.deepcopy(cheeseman_animation)
        }
    }
}
-- Attacks
data.raw["electric-turret"].cheeseman.attack_parameters.damage_modifier = 0.2
data.raw["electric-turret"].cheeseman.attack_parameters.range = 19
-- Category of ammo (so it doesn't get laser turret bonuses)
data.raw["electric-turret"].cheeseman.attack_parameters.ammo_category = "cheeseman"
data:extend({
    {
        type = "ammo-category",
        name = "cheeseman",
        localised_name = "Cheese"
    }
})
-- Beam
data.raw["electric-turret"].cheeseman.attack_parameters.ammo_type.action.action_delivery.beam = "cheese"
data.raw["electric-turret"].cheeseman.attack_parameters.ammo_type.action.action_delivery.max_length = 19
data.raw["beam"].cheese = table.deepcopy(data.raw.beam["laser-beam"])
data.raw["beam"].cheese.name = "cheese"
data.raw["beam"].cheese.damage_interval = 1
data.raw["beam"].cheese.action_triggered_automatically = true
-- Box and misc
data.raw["electric-turret"].cheeseman.selection_box = {{-3, -3}, {3, 3}}
data.raw["electric-turret"].cheeseman.minable = nil
data.raw["electric-turret"].cheeseman.corpse = "construction-robot-remnants"
data.raw["electric-turret"].cheeseman.collision_mask = {layers = {}}
data.raw["electric-turret"].cheeseman.max_health = 2000
table.insert(data.raw["electric-turret"].cheeseman.flags, "placeable-off-grid")
-- Make gun turrets more susceptible to cheeseman
data.raw["ammo-turret"]["gun-turret"].resistances = {
    {
        type = "laser",
        percent = -2000
    }
}
-- Make guns better to deal with cheeseman better when he attacks
data.raw.gun["pistol"].attack_parameters.range = 24
data.raw.gun["pistol"].attack_parameters.damage_modifier = 1.5
data.raw.gun["submachine-gun"].attack_parameters.range = 24
data.raw.gun["submachine-gun"].attack_parameters.damage_modifier = 1.2

-- 6. Lubricant is now an item

data:extend({
    {
        type = "item",
        name = "lubricant",
        localised_name = "Lubricant",
        subgroup = "fluid-recipes",
        icon = data.raw.fluid.lubricant.icon,
        icon_size = data.raw.fluid.lubricant.icon_size,
        stack_size = 200
    }
})
data.raw.recipe.lubricant.results = {
    {type = "item", name = "lubricant", amount = 10}
}
data.raw.recipe["empty-lubricant-barrel"].results = {
    {type = "item", name = "lubricant", amount = 50},
    {type = "item", name = "barrel", amount = 1}
}
for _, recipe in pairs(data.raw.recipe) do
    if recipe.ingredients ~= nil then
        local inds = {}
        for ind, ing in pairs(recipe.ingredients) do
            if ing.type == "fluid" and ing.name == "lubricant" then
                table.insert(recipe.ingredients, {type = "item", name = "lubricant", amount = ing.amount})
                table.insert(inds, ind)
            end
        end
        for i = #inds, 1, -1 do
            table.remove(recipe.ingredients, inds[i])
        end
    end
end
-- Make electric engine units normal crafting category since now they're all solids
data.raw.recipe["electric-engine-unit"].category = "crafting"

-- 7. Uranium probabilities flipped

data.raw.recipe["uranium-processing"].results = {
    {type = "item", name = "uranium-238", amount = 1, probability = 0.003},
    {type = "item", name = "uranium-235", amount = 1, probability = 0.997}
}

-- 8. Water 2

data.raw.fluid["water-2"] = table.deepcopy(data.raw.fluid["water"])
data.raw.fluid["water-2"].name = "water-2"
data.raw.fluid["water"].localised_name = "Water 1"
data.raw.fluid["water-2"].localised_name = "Water 2"
data.raw["offshore-pump"]["offshore-pump-2"] = table.deepcopy(data.raw["offshore-pump"]["offshore-pump"])
data.raw["offshore-pump"]["offshore-pump-2"].name = "offshore-pump-2"
data.raw["offshore-pump"]["offshore-pump"].localised_name = "Offshore Pump 1"
data.raw["offshore-pump"]["offshore-pump-2"].localised_name = "Offshore Pump 2"
data.raw["offshore-pump"]["offshore-pump-2"].localised_description = "It does the same thing, but twice."
data.raw["offshore-pump"]["offshore-pump-2"].fluid = "water-2"
data.raw["offshore-pump"]["offshore-pump-2"].fluid_box.filter = "water-2"
data.raw["offshore-pump"]["offshore-pump-2"].minable.result = "offshore-pump-2"
data.raw.item["offshore-pump-2"] = table.deepcopy(data.raw.item["offshore-pump"])
data.raw.item["offshore-pump-2"].name = "offshore-pump-2"
data.raw.item["offshore-pump"].localised_name = "Offshore Pump 1"
data.raw.item["offshore-pump-2"].localised_name = "Offshore Pump 2"
data.raw.item["offshore-pump-2"].localised_description = "It does the same thing, but twice."
data.raw.item["offshore-pump-2"].place_result = "offshore-pump-2"
data:extend({
    {
        type = "recipe",
        name = "offshore-pump-2",
        ingredients = {
            {type = "item", name = "offshore-pump", amount = 50}
        },
        results = {
            {type = "item", name = "offshore-pump-2", amount = 1}
        },
        enabled = false
    },
    {
        type = "technology",
        name = "water-2",
        localised_name = "Water 2",
        localised_description = "Water was so good they made a second one. Now, harness the power of H2O2 to process your grape juice.",
        icon = data.raw.fluid.water.icon,
        icon_size = data.raw.fluid.water.icon_size,
        icon_mipmaps = data.raw.fluid.water.icon_mipmaps,
        unit = {
            count = 50,
            time = 30,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            }
        },
        prerequisites = {
            "chemical-science-pack"
        },
        effects = {
            {type = "unlock-recipe", recipe = "offshore-pump-2"}
        }
    }
})
data.raw.technology["advanced-oil-processing"].prerequisites = {
    "water-2"
}
data.raw.recipe["basic-oil-processing"].ingredients = {
    {type = "fluid", name = "crude-oil", amount = 100},
    {type = "fluid", name = "water", amount = 5}
}
data.raw.recipe["advanced-oil-processing"].ingredients = {
    {type = "fluid", name = "crude-oil", amount = 100},
    {type = "fluid", name = "water-2", amount = 5}
}
data.raw.fluid["water-2-2"] = table.deepcopy(data.raw.fluid.water)
data.raw.fluid["water-2-2"].name = "water-2-2"
data.raw.fluid["water-2-2"].localised_name = "Water 2, version 2"
data.raw["offshore-pump"]["offshore-pump-2-2"] = table.deepcopy(data.raw["offshore-pump"]["offshore-pump"])
data.raw["offshore-pump"]["offshore-pump-2-2"].name = "offshore-pump-2-2"
data.raw["offshore-pump"]["offshore-pump-2-2"].localised_name = "Offshore Pump 2, version 2"
data.raw["offshore-pump"]["offshore-pump-2-2"].localised_description = "We wish we could say this was an improvement."
data.raw["offshore-pump"]["offshore-pump-2-2"].fluid = "water-2-2"
data.raw["offshore-pump"]["offshore-pump-2-2"].fluid_box.filter = "water-2-2"
data.raw["offshore-pump"]["offshore-pump-2-2"].minable.result = "offshore-pump-2-2"
data.raw.item["offshore-pump-2-2"] = table.deepcopy(data.raw.item["offshore-pump"])
data.raw.item["offshore-pump-2-2"].name = "offshore-pump-2-2"
data.raw.item["offshore-pump-2-2"].localised_name = "Offshore Pump 2, version 2"
data.raw.item["offshore-pump-2-2"].localised_description = "We wish we could say this was an improvement."
data.raw.item["offshore-pump-2-2"].place_result = "offshore-pump-2-2"
data:extend({
    {
        type = "recipe",
        name = "offshore-pump-2-2",
        category = "crafting",
        ingredients = {
            --{type = "item", name = "lubricant", amount = 10000},
            {type = "item", name = "offshore-pump-2", amount = 50},
            {type = "item", name = "uranium-238", amount = 1}
        },
        results = {
            {type = "item", name = "offshore-pump-2-2", amount = 1}
        },
        enabled = false
    },
    {
        type = "technology",
        name = "water-2-2",
        localised_name = "Water 2, version 2",
        localised_description = "They're just gonna run this water joke dry aren't they?",
        icons = {
            {
                icon = data.raw.fluid.water.icon,
                icon_size = data.raw.fluid.water.icon_size,
                icon_mipmaps = data.raw.fluid.water.icon_mipmaps,
                shift = {-10, -15}
            },
            {
                icon = data.raw.fluid.water.icon,
                icon_size = data.raw.fluid.water.icon_size,
                icon_mipmaps = data.raw.fluid.water.icon_mipmaps,
                shift = {10, 15}
            }
        },
        unit = {
            count = 200,
            time = 30,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                -- Added later automatically I think
                --{"py-science", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"explosives", 1},
                {"burner-inserter", 1},
                {"boiler", 1},
                {"lab", 1},
                {"repair-pack", 1},
            }
        },
        prerequisites = {
            "utility-science-pack",
            "production-science-pack",
            "uranium-processing"
        },
        effects = {
            {type = "unlock-recipe", recipe = "offshore-pump-2-2"}
        }
    }
})
data.raw.recipe["rocket-silo"].ingredients = {
    {type = "item", name = "steel-plate", amount = 1000},
    {type = "item", name = "electric-engine-unit", amount = 200},
    {type = "item", name = "pipe", amount = 100},
    {type = "item", name = "refined-concrete", amount = 1000}
}
table.insert(data.raw.technology["rocket-silo"].prerequisites, "water-2-2")
--[[data.raw.recipe["express-transport-belt"].ingredients = {
    {type = "item", name = "iron-gear-wheel", amount = 10},
    {type = "item", name = "fast-transport-belt", amount = 1},
    {type = "fluid", name = "water-2-2", amount = 0.2}
}
data.raw.recipe["express-underground-belt"].ingredients = {
    {type = "item", name = "iron-gear-wheel", amount = 40},
    {type = "item", name = "fast-underground-belt", amount = 1},
    {type = "fluid", name = "water-2-2", amount = 0.5}
}
data.raw.recipe["express-splitter"].ingredients = {
    {type = "item", name = "iron-gear-wheel", amount = 10},
    {type = "item", name = "fast-splitter", amount = 1},
    {type = "item", name = "advanced-circuit", amount = 10},
    {type = "fluid", name = "water-2-2", amount = 1}
}
data.raw.technology["logistics-3"].prerequisites = {
    "water-2-2"
}]]
data.raw.recipe["sulfuric-acid"].ingredients = {
    {type = "fluid", name = "water-2", amount = 20},
    {type = "item", name = "iron-plate", amount = 1},
    {type = "item", name = "sulfur", amount = 5}
}
data.raw.recipe["concrete"].ingredients = {
    {type = "item", name = "iron-ore", amount = 1},
    {type = "fluid", name = "water-2", amount = 10},
    {type = "item", name = "stone-brick", amount = 5}
}
data.raw.recipe["refined-concrete"].ingredients = {
    {type = "item", name = "steel-plate", amount = 1},
    {type = "item", name = "iron-stick", amount = 8},
    {type = "item", name = "concrete", amount = 10},
    {type = "fluid", name = "water-2-2", amount = 10}
}
remove_tech_recipe_unlock(data.raw.technology.concrete, "iron-stick")
data.raw.recipe["explosives"].ingredients = {
    {type = "item", name = "coal", amount = 1},
    {type = "item", name = "sulfur", amount = 1},
    {type = "fluid", name = "water-2", amount = 5}
}
-- Concrete water 2 prerequisite
data.raw.technology.concrete.prerequisites = {"water-2"}

-- 9. Switch colors of red and yellow chests

data.raw["logistic-container"]["storage-chest"].logistic_mode = "passive-provider"
data.raw["logistic-container"]["storage-chest"].max_logistic_slots = 0
data.raw["logistic-container"]["storage-chest"].localised_name = "Passive Provider Chest"
data.raw["logistic-container"]["storage-chest"].localised_description = "Makes it content available to the logistic network."
data.raw["logistic-container"]["passive-provider-chest"].logistic_mode = "storage"
data.raw["logistic-container"]["passive-provider-chest"].max_logistic_slots = 1
data.raw["logistic-container"]["passive-provider-chest"].localised_name = "Storage Chest"
data.raw["logistic-container"]["passive-provider-chest"].localised_description = "Long-term storage for the logistic network."

-- 10. Nuclear reactors have 1 health

data.raw.reactor["nuclear-reactor"].max_health = 1

-- 11. Processing units are fluids

data:extend({
    {
        type = "fluid",
        name = "processing-unit",
        localised_name = "Processing fluid unit",
        subgroup = "intermediate-product",
        order = "g[processing-unit]",
        icon = data.raw.item["processing-unit"].icon,
        icon_size = data.raw.item["processing-unit"].icon_size,
        default_temperature = -273,
        base_color = {r = 51, g = 1, b = 63},
        flow_color = {r = 51, g = 1, b = 63}
    }
})
for _, recipe in pairs(data.raw.recipe) do
    if recipe.ingredients ~= nil then
        for _, ingredient in pairs(recipe.ingredients) do
            if ingredient.name == "processing-unit" then
                ingredient.type = "fluid"
                if recipe.category == "crafting" or recipe.category == nil then
                    -- Don't do this with beta mode since we change it back to solid anyways
                    --if not settings.startup["fun_mode_beta"].value then
                        --recipe.category = "crafting-with-fluid"
                    --end
                end
            end
        end
    end
end
data.raw.recipe["processing-unit"].results = {
    {type = "fluid", amount = 1, name = "processing-unit"}
}
data.raw.recipe["processing-unit"].subgroup = "intermediate-product"
data.raw.recipe["processing-unit"].localised_name = "Processing fluid unit"
data.raw.technology["processing-unit"].localised_name = "Processing fluid unit"

-- 12. Prod mod 2's are actually very good

data.raw.module["productivity-module-2"].effect = {
    consumption = -0.10,
    productivity = 0.12,
    speed = 0.60,
    pollution = 0.06
}

-- 13. Bot breeding

data:extend({
    {
        type = "technology",
        name = "bot-breeding",
        localised_name = "Bot breeding",
        localised_description = "Learn to make bots more efficiently.",
        icons = {
            {
                icon = data.raw.item["construction-robot"].icon,
                icon_size = data.raw.item["construction-robot"].icon_size,
                scale = 0.5
            },
            {
                icon = data.raw.item["logistic-robot"].icon,
                icon_size = data.raw.item["logistic-robot"].icon_size,
                scale = 0.25,
                shift = {10, 10}
            }
        },
        unit = {
            count = 50,
            time = 15,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            }
        },
        prerequisites = {
            "robotics"
        },
        effects = {
            {type = "unlock-recipe", recipe = "bot-breeding"}
        }
    },
    {
        type = "recipe",
        name = "bot-breeding",
        localised_name = "Breed bots",
        subgroup = "logistic-network",
        order = "a[robot]-z[bot-breeding]",
        icons = {
            {
                icon = data.raw.item["construction-robot"].icon,
                icon_size = data.raw.item["construction-robot"].icon_size,
                scale = 0.5,
                shift = {-10, 0}
            },
            {
                icon = data.raw.item["logistic-robot"].icon,
                icon_size = data.raw.item["logistic-robot"].icon_size,
                scale = 0.5,
                shift = {10, 0}
            }
        },
        ingredients = {
            {type = "item", name = "construction-robot", amount = 1},
            {type = "item", name = "logistic-robot", amount = 1}
        },
        results = {
            {type = "item", name = "construction-robot", amount_min = 1, amount_max = 2},
            {type = "item", name = "logistic-robot", amount_min = 1, amount_max = 2},
        },
        energy_required = 2,
        enabled = false
    }
})
data.raw.recipe["construction-robot"].ingredients = {
    {type = "item", name = "flying-robot-frame", amount = 10},
    {type = "item", name = "electronic-circuit", amount = 2}
}
data.raw.recipe["logistic-robot"].ingredients = {
    {type = "item", name = "flying-robot-frame", amount = 10},
    {type = "item", name = "advanced-circuit", amount = 2}
}

-- 14. Roller skates

-- Decided not to do

-- 15. Transport belt rotation tech

data:extend({
    {
        type = "technology",
        name = "belt-ping",
        localised_name = "Belt surveillance",
        localised_description = "Get pinged when a transport belt rotates itself.",
        icon = "__fun_mode__/graphics/technology/belt-ping.png",
        icon_size = 256,
        unit = {
            count = 100,
            time = 15,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"burner-inserter", 1}
            }
        },
        prerequisites = {
            "lab-2"
        },
        effects = {}
    }
})

--------------------------------------------------
-- Purple/Yellow
--------------------------------------------------

-- 1. Coal liquefaction is now oil solidification

data.raw.recipe["coal-liquefaction"].localised_name = "Coca cola solidification"
data.raw.technology["coal-liquefaction"].localised_name = "Coca cola solidification"
data.raw.technology["coal-liquefaction"].localised_description = "A processing technique to turn soda products into coal with the use of steam and water 2."
data.raw.recipe["coal-liquefaction"].ingredients = {
    {type = "fluid", name = "heavy-oil", amount = 90},
    {type = "fluid", name = "water-2", amount = 1}
}
data.raw.recipe["coal-liquefaction"].results = {
    {type = "fluid", name = "heavy-oil", amount = 25},
    {type = "item", name = "coal", amount = 10}
}

-- 2. Low density structure needs a lot of heavy things

-- Don't directly make tanks a prerequisite technology since otherwise they won't be able to find the LDS research with discovery tree
data.raw.technology["low-density-structure"].localised_name = "\"Low\" density structure"
data.raw.technology["low-density-structure"].localised_description = "Put three heavy things together to make a light thing."
data.raw.item["low-density-structure"].localised_name = "\"Low\" density structure"
data.raw.recipe["low-density-structure"].ingredients = {
    {type = "item", name = "tank", amount = 1},
    {type = "item", name = "flamethrower-turret", amount = 1},
    {type = "item", name = "nuclear-reactor", amount = 1}
}
data.raw.recipe["low-density-structure"].main_product = "low-density-structure"
data.raw.recipe["low-density-structure"].energy_required = 200
data.raw.recipe["low-density-structure"].results = {
    {type = "item", name = "low-density-structure", amount = 1},
    {type = "item", probability = 0.99, name = "nuclear-reactor", amount = 1, ignored_by_productivity = 1}
}
data.raw.recipe["fission-reactor-equipment"].ingredients = {
    {type = "item", name = "low-density-structure", amount = 2},
    {type = "fluid", name = "processing-unit", amount = 200},
    {type = "item", name = "nuclear-fish", amount = 1}
}
data.raw.recipe["energy-shield-mk2-equipment"].ingredients = {
    {type = "item", name = "low-density-structure", amount = 1},
    {type = "item", name = "energy-shield-equipment", amount = 10},
    {type = "item", type = "fluid", name = "processing-unit", amount = 5}
}
data.raw.recipe["personal-laser-defense-equipment"].ingredients = {
    {type = "item", name = "low-density-structure", amount = 1},
    {type = "item", name = "laser-turret", amount = 10},
    {type = "fluid", name = "processing-unit", amount = 20}
}
data.raw.recipe["spidertron"].ingredients = {
    {type = "item", name = "low-density-structure", amount = 5},
    {type = "fluid", name = "processing-unit", amount = 16},
    {type = "item", name = "raw-fish", amount = 1},
    {type = "item", name = "efficiency-module-3", amount = 2},
    {type = "item", name = "rocket-launcher", amount = 4},
    {type = "item", name = "fission-reactor-equipment", amount = 2},
    {type = "item", name = "exoskeleton-equipment", amount = 4},
    {type = "item", name = "radar", amount = 2}
}
data.raw.recipe["power-armor-mk2"].ingredients = {
    {type = "item", name = "electric-engine-unit", amount = 40},
    {type = "item", name = "low-density-structure", amount = 2},
    {type = "item", name = "speed-module-2", amount = 25},
    {type = "item", name = "efficiency-module-2", amount = 25},
    {type = "fluid", name = "processing-unit", amount = 60}
}
data.raw.recipe["personal-roboport-mk2-equipment"].ingredients = {
    {type = "item", name = "low-density-structure", amount = 1},
    {type = "item", name = "personal-roboport-equipment", amount = 10},
    {type = "fluid", name = "processing-unit", amount = 100}
}
data.raw.recipe["utility-science-pack"].ingredients = {
    {type = "item", name = "low-density-structure", amount = 1},
    {type = "item", name = "flying-robot-frame", amount = 25},
    {type = "fluid", name = "processing-unit", amount = 50}
}
data.raw.recipe["utility-science-pack"].results = {
    {type = "item", name = "utility-science-pack", amount = 75}
}
data.raw.recipe["utility-science-pack"].energy_required = 25 * data.raw.recipe["utility-science-pack"].energy_required
data.raw.recipe["satellite"].ingredients = {
    {type = "item", name = "low-density-structure", amount = 3},
    {type = "item", name = "rocket-fuel", amount = 50},
    {type = "item", name = "solar-panel", amount = 100},
    {type = "item", name = "accumulator", amount = 100},
    {type = "item", name = "radar", amount = 5},
    {type = "fluid", name = "processing-unit", amount = 100}
}

-- 3. Bob the inserter

data:extend({
    {
        type = "technology",
        name = "bob",
        localised_name = "Bob",
        localised_description = "Bob is an inserter that was adjusted a little too much...",
        icon = "__fun_mode__/graphics/bob_inserter_icon.png",
        icon_size = 64,
        prerequisites = {
            "production-science-pack"
        },
        unit = {
            count = 200,
            time = 30,
            ingredients = {
                {"burner-inserter", 1}
            }
        },
        effects = {
            {type = "unlock-recipe", recipe = "bob"}
        }
    },
    {
        type = "recipe",
        name = "bob",
        localised_name = "Bob",
        subgroup = "inserter",
        order = "g[bob]",
        ingredients = {
            {type = "item", name = "iron-stick", amount = 25},
            {type = "item", name = "long-handed-inserter", amount = 1}
        },
        results = {
            {type = "item", name = "bob", amount = 1}
        },
        enabled = false
    },
    {
        type = "item",
        name = "bob",
        subgroup = "inserter",
        order = "g[bob]",
        icon = "__fun_mode__/graphics/bob_inserter_icon.png",
        icon_size = 64,
        stack_size = 49,
        place_result = "bob"
    }
})
data.raw.inserter["bob"] = table.deepcopy(data.raw.inserter["bulk-inserter"])
data.raw.inserter["bob"].icon = "__fun_mode__/graphics/bob_inserter_icon.png"
data.raw.inserter["bob"].icon_size = 64
data.raw.inserter["bob"].name = "bob"
data.raw.inserter["bob"].localised_name = "Bob"
data.raw.inserter["bob"].pickup_position = {0, -15.4}
data.raw.inserter["bob"].insert_position = {0, 15.4}
data.raw.inserter["bob"].extension_speed = data.raw.inserter["bob"].extension_speed / 3
-- Keep bob as a stack inserter
data.raw.inserter["bob"].filter_count = 5
data.raw.inserter["bob"].hand_size = 3
data.raw.inserter["bob"].energy_source = {
    type = "void"
}
data.raw.inserter["bob"].minable = {
    mining_time = 0.1,
    result = "bob"
}
data.raw.inserter["bob"].hand_base_picture.tint = {
    r = 50,
    g = 50,
    b = 50
}
data.raw.inserter["bob"].hand_open_picture.tint = {
    r = 50,
    g = 50,
    b = 50
}
data.raw.inserter["bob"].hand_closed_picture.tint = {
    r = 50,
    g = 50,
    b = 50
}
data.raw.inserter["bob"].platform_picture.sheet.tint = {
    r = 50,
    g = 50,
    b = 50
}

-- 4. A research just to regenerate biter bases

data:extend({
    {
        type = "technology",
        name = "regeneration",
        localised_name = "Regeneration",
        localised_description = "Regenerates enemy bases.",
        icon = data.raw["unit"]["small-biter"].icon,
        icon_size = data.raw["unit"]["small-biter"].icon_size,
        prerequisites = {
            "utility-science-pack"
        },
        unit = {
            count_formula = "50",
            time = 15,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1}
            }
        },
        effects = {},
        max_level = "infinite"
    }
})

-- 5. Cliffside assemblers

data:extend({
    {
        type = "item",
        name = "cliff",
        subgroup = "terrain",
        icon = data.raw.cliff.cliff.icon,
        icon_size = data.raw.cliff.cliff.icon_size,
        icon_mipmaps = data.raw.cliff.cliff.icon_mipmaps,
        stack_size = 10,
        place_result = "cliff"
    },
    {
        type = "recipe",
        name = "cliff",
        category = "crafting",
        ingredients = {
            {type = "item", name = "stone", amount = 1000}
        },
        results = {
            {type = "item", name = "cliff", amount = 1}
        },
        energy_required = 60,
        enabled = false
    },
    {
        type = "recipe-category",
        name = "silo"
    }
})
table.insert(data.raw.technology["automation-3"].effects, {type = "unlock-recipe", recipe = "cliff"})
data.raw["assembling-machine"]["assembling-machine-3"].localised_name = "Cliffside assembler"
data.raw["assembling-machine"]["assembling-machine-3"].localised_description = "Assembles the silo and other stuff."
data.raw["assembling-machine"]["assembling-machine-3"].module_slots = 6
data.raw["item"]["assembling-machine-3"].localised_name = "Cliffside assembler"
data.raw["item"]["assembling-machine-3"].localised_description = "Assembles the silo and other stuff."
data.raw["technology"]["automation-3"].localised_name = "Cliffside silo assembly"
data.raw["technology"]["automation-3"].localised_description = "Required for making the silo. Comes with free cliff recipe!"
data.raw.recipe["rocket-silo"].category = "silo"
table.insert(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories, "silo")
table.insert(data.raw.technology["rocket-silo"].prerequisites, "automation-3")

-- 6. Lab 2.0

data.raw.lab["lab-2"] = table.deepcopy(data.raw.lab.lab)
data.raw.lab["lab-2"].localised_name = "Lab 2.0"
data.raw.lab["lab-2"].name = "lab-2"
data.raw.lab["lab-2"].researching_speed = 2
-- Buffed research speed
data.raw.lab["lab-2"].energy_source = {
    type = "burner",
    usage_priority = "secondary-input",
    fuel_inventory_size = 1,
    burnt_inventory_size = 1
}
data.raw.lab["lab-2"].energy_usage = "200kW"
data.raw.lab.lab.inputs = {
    "automation-science-pack",
    "logistic-science-pack",
    "military-science-pack",
    "chemical-science-pack"
}
data.raw.lab["lab-2"].inputs = {
    "automation-science-pack",
    "logistic-science-pack",
    "military-science-pack",
    "chemical-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "space-science-pack",
    "repair-pack",
    "lab",
    "burner-inserter",
    "boiler",
    "explosives"
}
data.raw.tool["burner-inserter"] = table.deepcopy(data.raw.item["burner-inserter"])
data.raw.item["burner-inserter"] = nil
data.raw.tool["burner-inserter"].type = "tool"
data.raw.tool["burner-inserter"].durability = 1
data.raw.recipe["burner-inserter"].energy_required = 30
data.raw.inserter["burner-inserter"].stack = true
-- Make burner inserters more viable :)
data.raw.inserter["burner-inserter"].stack_size_bonus = 30
data.raw.inserter["burner-inserter"].energy_per_movement = "15kJ"
data.raw.inserter["burner-inserter"].energy_per_rotation = "15kJ"
data.raw.tool["boiler"] = table.deepcopy(data.raw.item["boiler"])
data.raw.item["boiler"] = nil
data.raw.tool["boiler"].type = "tool"
data.raw.tool["boiler"].durability = 1
--[[data.raw.tool["copper-cable"] = table.deepcopy(data.raw.item["copper-cable"])
data.raw.item["copper-cable"] = nil
data.raw.tool["copper-cable"].type = "tool"
data.raw.tool["copper-cable"].durability = 1]]
data.raw.tool["explosives"] = table.deepcopy(data.raw.item["explosives"])
data.raw.item["explosives"] = nil
data.raw.tool["explosives"].type = "tool"
data.raw.tool["explosives"].durability = 1
data.raw.item["lab-2"] = table.deepcopy(data.raw.item.lab)
data.raw.item["lab-2"].localised_name = "Lab 2.0"
data.raw.item["lab-2"].name = "lab-2"
data.raw.item["lab-2"].place_result = "lab-2"
data.raw.tool["lab"] = table.deepcopy(data.raw.item["lab"])
data.raw.item["lab"] = nil
data.raw.tool["lab"].type = "tool"
data.raw.tool["lab"].durability = 1
data.raw.lab["lab-2"].minable.results = {{type = "item", name = "lab-2", amount = 1}}
data.raw.recipe["lab-2"] = table.deepcopy(data.raw.recipe.lab)
data.raw.recipe["lab-2"].ingredients = {{type = "item", name = "advanced-circuit", amount = 10}, {type = "item", name = "steel-plate", amount = 10}, {type = "item", name = "fast-transport-belt", amount = 4}}
data.raw.recipe["lab-2"].results = {{type = "item", name = "lab-2", amount = 1}}
data.raw.recipe["lab-2"].name = "lab-2"
data.raw.recipe["lab-2"].enabled = false
data:extend({
    {
        type = "technology",
        name = "lab-2",
        localised_name = "Lab 2.0",
        localised_description = "You've figured out how to jam a lot more stuff in there.",
        icon = data.raw.tool.lab.icon,
        icon_size = data.raw.tool.lab.icon_size,
        unit = {
            count = 100,
            time = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            }
        },
        prerequisites = {
            "chemical-science-pack"
        },
        effects = {
            {type = "unlock-recipe", recipe = "lab-2"}
        },
        essential = true
    }
})
table.insert(data.raw.technology["utility-science-pack"].prerequisites, "lab-2")
-- Don't add prereq to lab-2 for production science pack, just to advanced furnaces
table.insert(data.raw.technology["advanced-material-processing-2"].prerequisites, "lab-2")
data.raw.technology["advanced-material-processing-2"].unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"boiler", 1}
}
data.raw.lab.lab.fast_replaceable_group = "lab"
data.raw.lab["lab-2"].fast_replaceable_group = "lab"
data.raw.lab["lab-2"].module_slots = 4
data.raw.lab["lab-2"].collision_box = {
    {-2.2, -2.2},
    {2.2, 2.2}
}
data.raw.lab["lab-2"].selection_box = {
    {-2.5, -2.5},
    {2.5, 2.5}
}
change_scale(data.raw.lab["lab-2"].on_animation, 5 / 3)
change_scale(data.raw.lab["lab-2"].off_animation, 5 / 3)
local prod_extra = {
    --{"repair-pack", 1},
    --{"lab", 1},
    --{"copper-cable", 30},
    --{"burner-inserter", 1}
}
local util_extra = {
    --{"power-armor", 1},
    --{"boiler", 1},
    --{"explosives", 1}
}
table.insert(data.raw.technology["electric-energy-distribution-2"].prerequisites, "lab-2")
for _, technology in pairs(data.raw.technology) do
    -- Need to check for trigger technologies
    if technology.unit ~= nil then
        local has_util = false
        local has_prod = false
        for _, ingredient in pairs(technology.unit.ingredients) do
            if ingredient[1] == "production-science-pack" then
                has_prod = true
            end
            if ingredient[1] == "utility-science-pack" then
                has_util = true
            end
        end
        if has_util then
            for _, extra in pairs(util_extra) do
                table.insert(technology.unit.ingredients, extra)
            end
        end
        if has_prod then
            for _, extra in pairs(prod_extra) do
                table.insert(technology.unit.ingredients, extra)
            end
        end
    end
end
-- Make electric energy distribution just tons of copper cable
data.raw.technology["electric-energy-distribution-2"].unit.ingredients = {
    {"copper-cable", 135}
}
data.raw.technology["production-science-pack"].unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"burner-inserter", 1}
}
data.raw.technology["utility-science-pack"].unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"power-armor", 1},
    {"boiler", 1}
}
table.insert(data.raw.technology["rocket-fuel"].prerequisites, "lab-2")
data.raw.technology["rocket-fuel"].unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"boiler", 1}
}
table.insert(data.raw.technology["battery-mk2-equipment"].prerequisites, "lab-2")
data.raw.technology["battery-mk2-equipment"].unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"repair-pack", 1}
}
table.insert(data.raw.technology["personal-laser-defense-equipment"].prerequisites, "lab-2")
data.raw.technology["personal-laser-defense-equipment"].unit.ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"repair-pack", 1}
}

-- 7. Beacon limits

data.raw.beacon.beacon.distribution_effectivity = 5
data.raw.beacon.beacon.supply_area_distance = 4
data:extend({
    {
        type = "technology",
        name = "beacon-count",
        localised_name = "Beacon count",
        localised_description = "Double the number of beacons you can place via harnessing the electrodynamic quasi-energy of Nauvis' geoferrous mantle. (Base value of 2 max beacons).",
        icon = "__fun_mode__/graphics/entity/compilatron-walk/compilatron-walk-2.png",
        icon_size = 78,
        prerequisites = {
            "effect-transmission"
        },
        unit = {
            count_formula = "10*4^(L-1)",
            time = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"lab", 1},
                {"burner-inserter", 1},
                {"power-armor", 1}
            }
        },
        effects = {},
        max_level = "infinite"
    }
})
data.raw.technology["effect-transmission"].localised_name = "Super beacons"
data.raw.technology["effect-transmission"].localised_description = "You can only craft a limited number of beacons (base of 2, upgradeable with research), but they transmit their effects like crazy."

--------------------------------------------------
-- Rocket
--------------------------------------------------

-- 1. Absolutely useless and useful research

data:extend({
    {
        type = "technology",
        name = "useless",
        localised_name = "Useless research",
        localised_description = "Does as much as a piece of grass.",
        icon = "__fun_mode__/graphics/useless.png",
        icon_size = 64,
        prerequisites = {
            "rocket-silo"
        },
        unit = {
            count = 200,
            time = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
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
                {"explosives", 1}
            }
        },
        effects = {}
    },
    {
        type = "technology",
        name = "useful",
        localised_name = "Useful research",
         -- In control
        localised_description = "Unlocks every technology - turns out grass is pretty useful.",
        icon = "__fun_mode__/graphics/useful.png",
        icon_size = 64,
        prerequisites = {
            "useless"
        },
        unit = {
            count = 1,
            time = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
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
                {"explosives", 1}
            }
        },
        effects = {}
    }
})

-- 2. Iterations of rocket fuel refining

local refined_string = ""
for i = 1, 5 do
    local ingredient_name = "solid-fuel"
    if i > 1 then
        ingredient_name = "solid-fuel-refined-" .. (i-1)
    end
    if i == 5 then
        ingredient_name = "solid-fuel-refined-" .. (i-2)
    end

    data:extend({
        {
            type = "recipe-category",
            name = "fuel-refining-" .. tostring(i)
        },
        {
            type = "recipe",
            name = "rocket-fuel-refining-" .. tostring(i),
            localised_name = "Refined " .. refined_string .. "solid fuel",
            category = "fuel-refining-" .. tostring(i),
            ingredients = {
                {type = "item", name = ingredient_name, amount = 10},
                {type = "fluid", name = "light-oil", amount = 10}
            },
            results = {
                {type = "item", name = "solid-fuel-refined-" .. tostring(i), amount = 10}
            },
            energy_required = i * 2,
            enabled = false,
            allow_productivity = true
        },
        {
            type = "item",
            name = "solid-fuel-refined-" .. tostring(i),
            localised_name = "Refined " .. refined_string .. "solid fuel",
            localised_description = "The refined version.",
            subgroup = data.raw.item["solid-fuel"].subgroup,
            icon = data.raw.item["solid-fuel"].icon,
            icon_size = data.raw.item["solid-fuel"].icon_size,
            stack_size = 10,
            fuel_value = tostring(20 * i) .. "MJ",
            fuel_acceleration_multiplier = (100 + 40 * i) / 100,
            fuel_top_speed_multiplier = (100 + 10 * i) / 100,
            fuel_category = "chemical"
        }
    })
    data.raw["assembling-machine"]["refinery-" .. tostring(i)] = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
    data.raw["assembling-machine"]["refinery-" .. tostring(i)].name = "refinery-" .. tostring(i)
    data.raw["assembling-machine"]["refinery-" .. tostring(i)].localised_name = "Refined " .. refined_string .. "solid fuel refinery"
    local place = ""
    if i == 1 then
        place = "worst."
    elseif i == 2 then
        place = "second worst."
    elseif i == 3 then
        place = "third best."
    elseif i == 4 then
        place = "second best."
    elseif i == 5 then
        place = "best."
    end
    data.raw["assembling-machine"]["refinery-" .. tostring(i)].localised_description = "Refining at its " .. place
    data.raw["assembling-machine"]["refinery-" .. tostring(i)].crafting_categories = {"fuel-refining-" .. tostring(i)}
    data.raw["assembling-machine"]["refinery-" .. tostring(i)].minable = {
        mining_time = data.raw["assembling-machine"]["chemical-plant"].minable.mining_time,
        results = {{type = "item", name = "refinery-" .. tostring(i), amount = 1}}
    }
    data.raw["assembling-machine"]["refinery-" .. tostring(i)].crafting_speed = 1 + i
    if i == 5 then
        data.raw["assembling-machine"]["refinery-" .. tostring(i)].crafting_speed = 0.314159
    end
    local scale = math.pow(1.5, i)
    if i == 5 then
        scale = 1 / 3
    end
    change_scale(data.raw["assembling-machine"]["refinery-" .. tostring(i)].graphics_set, scale)
    change_scale(data.raw["assembling-machine"]["refinery-" .. tostring(i)].graphics_set_flipped, scale)
    for k = 1, 2 do
        for l = 1, 2 do
            data.raw["assembling-machine"]["refinery-" .. tostring(i)].collision_box[k][l] = data.raw["assembling-machine"]["refinery-" .. tostring(i)].collision_box[k][l] * scale
            data.raw["assembling-machine"]["refinery-" .. tostring(i)].selection_box[k][l] = data.raw["assembling-machine"]["refinery-" .. tostring(i)].selection_box[k][l] * scale
        end
    end
    for _, fluid_box in pairs(data.raw["assembling-machine"]["refinery-" .. tostring(i)].fluid_boxes) do
        for _, pipe_connection in pairs(fluid_box.pipe_connections) do
            for key, _ in pairs(pipe_connection.position) do
                local sign = 1
                if pipe_connection.position[key] < 0 then
                    sign = -1
                end
                if scale < 1 then
                    pipe_connection.position[key] = pipe_connection.position[key] / 3
                else
                    pipe_connection.position[key] = pipe_connection.position[key] + sign * (scale - 1) * 1.2
                end
            end
        end
    end
    data.raw["item"]["refinery-" .. tostring(i)] = {
        type = "item",
        name = "refinery-" .. tostring(i),
        localised_name = "Refined " .. refined_string .. "solid fuel refinery",
        localised_description = "Refined refining at its most refined.",
        subgroup = data.raw.item["chemical-plant"].subgroup,
        icon = data.raw.item["chemical-plant"].icon,
        icon_size = data.raw.item["chemical-plant"].icon_size,
        stack_size = 20,
        place_result = "refinery-" .. tostring(i)
    }
    local prev_refinery = "refinery-" .. tostring(i-1)
    if i == 1 then
        prev_refinery = "assembling-machine-2"
    end
    data:extend({
        {
            type = "recipe",
            name = "refinery-" .. tostring(i),
            category = "crafting",
            ingredients = {
                {type = "item", name = "electronic-circuit", amount = 5},
                {type = "item", name = "iron-gear-wheel", amount = 5},
                {type = "item", name = "pipe", amount = 5},
                {type = "item", name = "steel-plate", amount = 5},
                {type = "item", name = prev_refinery, amount = 1}
            },
            results = {
                {type = "item", name = "refinery-" .. tostring(i), amount = 1}
            },
            energy_required = 5 * i,
            enabled = false
        }
    })
    local prerequisite_tech = "technology-refining-" .. tostring(i-1)
    if i == 1 then
        prerequisite_tech = "lab-2"
    end
    data:extend({
        {
            type = "technology",
            name = "technology-refining-" .. tostring(i),
            localised_name = "Refined " .. refined_string .. "solid fuel",
            localised_description = "Refining at its " .. place,
            icon = data.raw.item["solid-fuel"].icon,
            icon_size = data.raw.item["solid-fuel"].icon_size,
            unit = {
                time = 10,
                count = 200 * i,
                ingredients = {
                    {"boiler", 1}
                }
            },
            prerequisites = {
                prerequisite_tech
            },
            effects = {
                {type = "unlock-recipe", recipe = "refinery-" .. tostring(i)},
                {type = "unlock-recipe", recipe = "rocket-fuel-refining-" .. tostring(i)}
            }
        }
    })
    
    refined_string = "refined " .. refined_string
end
data.raw.recipe["rocket-fuel"].ingredients = {
    {type = "item", name = "solid-fuel-refined-5", amount = 10},
    {type = "fluid", name = "light-oil", amount = 10}
}
data.raw.technology["rocket-fuel"].prerequisites = {"technology-refining-5"}
-- Make rocket fuel OP
data.raw.item["rocket-fuel"].fuel_value = "200MJ"
data.raw.item["rocket-fuel"].fuel_acceleration_multiplier = 5
data.raw.item["rocket-fuel"].fuel_top_speed_multiplier = 1.75

-- 3. The rocket is a fish

data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_sprite = {
    layers = {
        {
            filename = "__fun_mode__/graphics/rocket-fish-transformed.png",
            height = 600,
            width = 340,
            scale = 0.875,
            shift = {0, 6}
        }
    }
}
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_rise_offset = {0, -5}
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_bottom1_animation.scale = 0.01
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_bottom1_animation.hr_version = nil
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_bottom2_animation.scale = 0.01
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_bottom2_animation.hr_version = nil
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_top1_animation.scale = 0.01
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_top1_animation.hr_version = nil
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_top2_animation.scale = 0.01
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_top2_animation.hr_version = nil
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_top3_animation.scale = 0.01
data.raw["rocket-silo-rocket"]["rocket-silo-rocket"].rocket_smoke_top3_animation.hr_version = nil

-- 4. Rocket silo has tons of module slots but doesn't accept prods

data.raw["rocket-silo"]["rocket-silo"].allowed_effects = {
    "consumption",
    "productivity",
    "speed"
}
data.raw["rocket-silo"]["rocket-silo"].module_slots = 10

-- 5. Bring back RCU's

data:extend({
    {
        type = "item",
        name = "rocket-control-unit",
        localised_name = "Rocket control unit 2.0",
        subgroup = "intermediate-product",
        order = "n[rocket-control-unit]",
        icon = "__fun_mode__/graphics/legacy/rocket-control-unit.png",
        icon_size = 64,
        icon_mipmaps = 4,
        stack_size = 10
    },
    {
        type = "recipe",
        name = "rocket-control-unit",
        localised_name = "Rocket control unit 2.0",
        category = "crafting",
        ingredients = {
            {type = "fluid", name = "processing-unit", amount = 1},
            {type = "item", name = "speed-module", amount = 1}
        },
        results = {
            {type = "item", name = "rocket-control-unit", amount = 1}
        },
        energy_required = 30,
        enabled = false,
        allow_productivity = true
    },
    {
        type = "technology",
        name = "rocket-control-unit",
        localised_name = "Rocket control unit 2.0",
        localised_description = "Advanced computing unit capable of controlling rocket systems.",
        order = "k-a",
        icon = "__fun_mode__/graphics/legacy/rocket-control-unit-tech.png",
        icon_mipmaps = 4,
        icon_size = 256,
        prerequisites = {
            "utility-science-pack",
            "speed-module"
        },
        unit = {
            count = 300,
            time = 45,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1}
            }
        },
        effects = {
            {type = "unlock-recipe", recipe = "rocket-control-unit"}
        }
    }
})
table.insert(data.raw.technology["rocket-silo"].prerequisites, "rocket-control-unit")

-- 6. FUN letters

--- 1000 fish each
data:extend({
    {
        type = "item",
        name = "f",
        localised_name = "F",
        localised_description = "F is for FISH",
        subgroup = "intermediate-product",
        order = "s",
        icon = "__fun_mode__/graphics/letter_f.png",
        icon_size = 64,
        stack_size = 10
    },
    {
        type = "item",
        name = "u",
        localised_name = "U",
        localised_description = "U is for U",
        subgroup = "intermediate-product",
        order = "sa",
        icon = "__fun_mode__/graphics/letter_u.png",
        icon_size = 64,
        stack_size = 10
    },
    {
        type = "item",
        name = "n",
        localised_name = "N",
        localised_description = "N is for NORMAL STUFF",
        subgroup = "intermediate-product",
        order = "sab",
        icon = "__fun_mode__/graphics/letter_n.png",
        icon_size = 64,
        stack_size = 10
    },
    {
        type = "recipe",
        name = "f",
        category = "crafting",
        ingredients = {{type = "item", name = "raw-fish", amount = 100}},
        results = {{type = "item", name = "f", amount = 1}},
        energy_required = 30,
        enabled = false,
        allow_productivity = true
    },
    {
        type = "recipe",
        name = "u",
        category = "crafting",
        ingredients = {
            {type = "item", name = "character-corpse", amount = 1}
        },
        results = {{type = "item", name = "u", amount = 20}},
        energy_required = 30,
        enabled = false,
        allow_productivity = true
    },
    {
        type = "recipe",
        name = "n",
        category = "crafting",
        ingredients = {
            {type = "item", name = "low-density-structure", amount = 1},
            {type = "item", name = "rocket-fuel", amount = 10},
            {type = "item", name = "rocket-control-unit", amount = 10}
        },
        results = {{type = "item", name = "n", amount = 1}},
        energy_required = 30,
        enabled = false,
        allow_productivity = true
    }
})
table.insert(data.raw.technology["rocket-silo"].effects, {type = "unlock-recipe", recipe = "f"})
table.insert(data.raw.technology["rocket-silo"].effects, {type = "unlock-recipe", recipe = "u"})
table.insert(data.raw.technology["rocket-silo"].effects, {type = "unlock-recipe", recipe = "n"})
data.raw.recipe["rocket-part"].ingredients = {
    {type = "item", name = "f", amount = 1},
    {type = "item", name = "u", amount = 1},
    {type = "item", name = "n", amount = 1}
}
data.raw.recipe["rocket-part"].allow_productivity = false
-- Ability to automate U's
data:extend({
    {
        type = "recipe",
        name = "character-corpse",
        localised_name = "Grow character corpse",
        category = "crafting-with-fluid",
        ingredients = {
            {type = "fluid", name = "water-2-2", amount = 100},
            {type = "item", name = "assembling-machine-1", amount = 2},
            {type = "item", name = "exoskeleton-equipment", amount = 1},
            {type = "item", name = "modular-armor", amount = 1},
            {type = "item", name = "construction-robot", amount = 100}
        },
        results = {
            {type = "item", name =  "character-corpse", amount = 1}
        },
        energy_required = 120,
        enabled = false
    },
    {
        type = "technology",
        name = "grow-character-corpse",
        localised_name = "Character corpse growth",
        localised_description = "Purely for automation purposes. Just mine or collect your corpses for an easier way.",
        icon = data.raw["character-corpse"]["character-corpse"].icon,
        icon_size = data.raw["character-corpse"]["character-corpse"].icon_size,
        prerequisites = {
            "rocket-silo"
        },
        unit = {
            count = 200,
            time = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1},
                {"production-science-pack", 1},
                {"lab", 1}
            }
        },
        effects = {
            {type = "unlock-recipe", recipe = "character-corpse"}
        }
    }
})

-- 7. Messages for getting far into the game

-- In control

-- 8. Special description for rocket silo

data.raw.technology["rocket-silo"].localised_description = "The fun is almost over."

--------------------------------------------------
-- Beta features
--------------------------------------------------

--if settings.startup["fun_mode_beta"].value then
    do_fun_mode_beta_features()
--end

--------------------------------------------------
-- Dosh additions
--------------------------------------------------

if dosh_mode then
    data:extend({
        {
            type = "technology",
            name = "dont-be-dosh",
            localised_name = "Don't be Doshdoshington",
            localised_description = "A jinx that blocks key technologies from those with the power to abuse them.",
            icon = "__fun_mode__/graphics/dosh.png",
            icon_size = 256,
            research_trigger = {
                type = "scripted",
                trigger_description = "Triggered by entering the realm of mortal Factorio players.",
            },
            prerequisites = {},
        },
        {
            type = "technology",
            name = "dont-be-dosh-dummy",
            icon = "__fun_mode__/graphics/dosh.png",
            icon_size = 256,
            research_trigger = {
                type = "scripted",
            },
            prerequisites = {},
            hidden = true,
        }
    })
    local dosh_locked = {
        "mercy",
        "multidirectional",
        "finesse",
        "iron-plate-productivity",
        "steel-plate-prod",
        "electric-energy-distribution-2",
    }
    for _, tech in pairs(dosh_locked) do
        table.insert(data.raw.technology[tech].prerequisites, "dont-be-dosh")
        table.insert(data.raw.technology[tech].prerequisites, "dont-be-dosh-dummy")
    end
    -- Make electric mining drills have as their only prerequisite the dosh research to make it clear that it locks stuff
    data.raw.technology["electric-mining-drill"].prerequisites = {"dont-be-dosh-dummy", "dont-be-dosh"}
end

--------------------------------------------------
-- Execute last
--------------------------------------------------

-- 1. Item stack sizes are one lower to make them look annoying

for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            if item.stack_size >= 5 then
                item.stack_size = item.stack_size - 1
            end
        end
    end
end

-- 2. All fluid boxes are underground

local function replace_pipe_connections(tbl)
    if type(tbl) == "table" then
        for key, val in pairs(tbl) do
            if key == "pipe_connections" then
                for _, conn in pairs(val) do
                    conn.connection_type = "underground"
                    conn.max_underground_distance = 4
                end
            else
                replace_pipe_connections(val)
            end
        end
    end
end
replace_pipe_connections(data.raw)
-- Make pipe-to-grounds easier to craft since they're less useful
data.raw.recipe["pipe-to-ground"].ingredients = {
    {type = "item", name = "iron-plate", amount = 1},
    {type = "item", name = "pipe", amount = 2}
}

-- 3. Swim (research to walk on water)

for class_name, _ in pairs(defines.prototypes.entity) do
    if class_name ~= "character" then
        -- Need to check in case of depecrated entities
        if data.raw[class_name] ~= nil then
            for _, prototype in pairs(data.raw[class_name]) do
                if prototype.collision_mask == nil then
                    prototype.collision_mask = collision_mask_util.get_default_mask(prototype.type)
                end

                local collision_mask = prototype.collision_mask.layers

                -- Check for player layer and add separate water-layer (water collision) and player-layer (player collision) instead so player layer can be removed from water
                if collision_mask["player"] then
                    collision_mask["player"] = nil
                    collision_mask["water"] = true
                    collision_mask["new_player"] = true
                end

                prototype.collision_mask.layers = collision_mask
            end
        end
    end
end
local water_tiles = {}
for _, tile in pairs(data.raw.tile) do
    if string.find(tile.name, "water") then
        table.insert(water_tiles, tile.name)
    end
end
for _, tile_name in pairs(water_tiles) do
    data.raw.tile[tile_name].collision_mask.layers = {
        water_tile = true,
        item = true,
        resource = true,
        doodad = true,
        water = true
    }
    data.raw.tile[tile_name].walking_speed_modifier = 0.6
end
data:extend({
    {
        type = "technology",
        name = "swim",
        localised_name = "Swim",
        localised_description = "Drinking enough of the blue slurpy juice gives you the power to swim.",
        icon = "__fun_mode__/graphics/legacy/water-o.png",
        icon_size = 32,
        prerequisites = {
            "chemical-science-pack"
        },
        unit = {
            count = 100,
            time = 15,
            ingredients = {
                {"chemical-science-pack", 1}
            }
        },
        effects = {}
    }
})

-- 4. Seahorses go with advanced circuits

-- Anything that requires advanced circuits also requires an equivalent amount of seahorses
for _, recipe in pairs(data.raw.recipe) do
    if recipe.name ~= "seahorse-from-advanced-circuit" then
        if recipe.ingredients ~= nil then
            for _, ing in pairs(recipe.ingredients) do
                if ing.type == "item" and ing.name == "advanced-circuit" then
                    table.insert(recipe.ingredients, {type = "item", name = "seahorse", amount = ing.amount})
                end
            end
        end
    end
end

-- 5. Mining something gives back its ingredients

--[[local minable_entity_type_blacklist = {
    ["transport-belt"] = true,
    ["character-corpse"] = true, -- TEST
    ["construction-robot"] = true, -- TEST
    ["logistic-robot"] = true -- TEST
}
-- Mining a building gives back what it takes to make it
for entity_class, _ in pairs(defines.prototypes.entity) do
    if not minable_entity_type_blacklist[entity_class] then
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                -- If there's a named recipe for it, use that
                if data.raw.recipe[entity.name] ~= nil and entity.minable ~= nil then
                    entity.minable = {
                        mining_time = entity.minable.mining_time,
                        results = data.raw.recipe[entity.name].ingredients
                    }
                end
            end
        end
    end
end]]

--------------------------------------------------
-- Beta fixes
--------------------------------------------------

--if settings.startup["fun_mode_beta"].value then
    do_fun_mode_beta_fixes()
--end

--------------------------------------------------
-- Dosh hotfixes
--------------------------------------------------

if dosh_mode then
    data.raw.technology.useful.hidden = true
    -- Now change trigger on slurp more juice
    data.raw.technology["automation-science-two"].research_trigger.item = "burner-mining-drill"
    data.raw.technology["automation-science-two"].research_trigger.count = 100
    data.raw.technology.pistol.prerequisites = {}
    data.raw.technology.pistol.localised_description = "You feel like you're going to need a lot of these."
    data.raw.technology.pistol.research_trigger = {
        type = "mine-entity",
        entity = "huge-rock",
    }
    table.insert(data.raw.technology["automation-science-pack"].prerequisites, "pistol")
    -- Pistols everywhere!
    data.raw.recipe["automation-science-pack"].ingredients = {{type = "item", name = "pistol", amount = 1}}
    data.raw.recipe["firearm-magazine"].ingredients = {{type = "item", name = "pistol", amount = 1}}
    data.raw.recipe["firearm-magazine"].results = {{type = "item", name = "firearm-magazine", amount = 2}}
    data.raw.recipe["inserter"].ingredients = {{type = "item", name = "pistol", amount = 1}}
    data.raw.recipe["underground-belt"].ingredients = {{type = "item", name = "pistol", amount = 2}, {type = "item", name = "transport-belt", amount = 5}}
    data.raw.recipe["submachine-gun"].ingredients = {{type = "item", name = "pistol", amount = 2}}
    data.raw.recipe["submachine-gun"].category = "smelting"

    data.raw["mining-drill"]["burner-mining-drill"].resource_searching_radius = 4.99
    data.raw["mining-drill"]["burner-mining-drill"].mining_speed = 0.25
    data.raw["mining-drill"]["burner-mining-drill"].radius_visualisation_picture = {
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
        width = 10,
        height = 10,
    }
    local my_module = table.deepcopy(data.raw.module["productivity-module-2"])
    data.raw.module["productivity-module-2"] = nil
    my_module.type = "item"
    data.raw.item["productivity-module-2"] = my_module
end

--------------------------------------------------
-- No spoilers
--------------------------------------------------

-- Hide simulations

--[[local simulation_names = {}
for simulation_name, _ in pairs(data.raw["utility-constants"]["default"].main_menu_simulations) do
    table.insert(simulation_names, simulation_name)
end
for _, simulation_name in pairs(simulation_names) do
    data.raw["utility-constants"]["default"].main_menu_simulations[simulation_name] = nil
end]]

if not settings.startup["fun_mode_enable_factoriopedia"].value then
    local class_types_to_remove_factoriopedia = {
        defines.prototypes.entity,
        defines.prototypes.tile,
        defines.prototypes.item,
        defines.prototypes.technology,
        defines.prototypes.recipe,
        defines.prototypes.fluid,
        defines.prototypes.fluid,
        {
            ["ammo-category"] = true,
            ["virtual-signal"] = true,
            ["planet"] = true
        }
    }
    for _, class_type in pairs(class_types_to_remove_factoriopedia) do
        for class_name, _ in pairs(class_type) do
            if data.raw[class_name] ~= nil then
                for _, prototype in pairs(data.raw[class_name]) do
                    prototype.hidden_in_factoriopedia = true
                end
            end
        end
    end
    data:extend({
        {
            type = "simple-entity",
            name = "factoriopedia-explanation",
            localised_name = "Why is factoriopedia not here?",
            localised_description = " ",
            factoriopedia_description = "Factoriopedia is disabled to prevent spoilers. You can undo this in the mod settings."
        }
    })
end

--------------------------------------------------
-- Normal visuals setting
--------------------------------------------------

if settings.startup["fun_mode_normal_visuals"].value then
    -- Change belts back to normal
    for _, class in pairs(belt_classes) do
        for _, belt in pairs(data.raw[class]) do
            -- Keep fast belts normal for extra confusion
            if belt.speed ~= 0.0625 then
                belt.animation_speed_coefficient = belt.animation_speed_coefficient * -1
            end
        end
    end

    -- Assembling machines don't undulate (or have any animation)
    log(serpent.block(data.raw["assembling-machine"]["assembling-machine-1"].graphics_set))
    for _, animation in pairs(data.raw["assembling-machine"]["assembling-machine-1"].graphics_set.animation) do
        for _, layer in pairs(animation.layers) do
            layer.frame_count = 1
            layer.repeat_count = 1
        end
    end

    -- Stack sizes are normal
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.stack_size >= 4 then
                    item.stack_size = item.stack_size + 1
                end
            end
        end
    end

    -- Swap red and green wires again
    local temp_red_wire_sprite = table.deepcopy(data.raw["utility-sprites"].default.red_wire)
    data.raw["utility-sprites"].default.red_wire = table.deepcopy(data.raw["utility-sprites"].default.green_wire)
    data.raw["utility-sprites"].default.green_wire = temp_red_wire_sprite
end

