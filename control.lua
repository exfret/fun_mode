local supporters = require("supporters")
local challenges = require("challenges")

script.on_init(function()
    -- CRITICAL TODO: TEMPORARY!
    storage.dosh_mode = true
    game.forces.player.technologies["dont-be-dosh-dummy"].researched = true

    -- Create the landmine force
    game.create_force("landmine")

    -- Used for keeping day-night cycle changes consistent with day challenge
    storage.day_offset = 0

    -- Supporter fishies
    storage["supporter-fishies"] = {}
    for _, supporter in pairs(supporters) do
        local name = "supporter-fish-" .. supporter

        while true do
            local random_chunk = {x = math.random(-18, 18), y = math.random(-18, 18)}

            if not (-3 <= random_chunk.x and random_chunk.x <= 3 and -3 <= random_chunk.y and random_chunk.y <= 3) then
                storage["supporter-fishies"][name] = game.surfaces.nauvis.create_entity({name = string.gsub(name, " ", "-"), position = {x = 32 * random_chunk.x + 16, y = 32 * random_chunk.y + 16}})
                rendering.draw_text({
                    text = supporter,
                    surface = "nauvis",
                    target = storage["supporter-fishies"][name],
                    color = {1, 1, 1}, -- White
                    scale = 3,
                    alignment = "center"
                })
                break
            end
        end
    end

    -- For tracking character corpses
    storage.all_corpses = {}

    -- Watch your step
    storage.prev_pos = {}
    storage.prev_vel = {}

    -- Ring of fire
    for i = 1, 628 / 4 do
        game.surfaces.nauvis.create_entity({name = "fire-flame", position = {10 * math.cos(i / 25), 10 * math.sin(i / 25)}})
    end

    -- Challenges
    storage.chance_to_do_challenge = 0
    storage.buildings_currently_permanent = {}
    -- Also used for explosives
    storage.all_belts = {}
    storage.curr_belt_index = 0

    -- Don't do pollution nerfs if dosh
    if not settings.startup["fun_mode_dosh"].value then
        -- Nerfs to evolution/pollution
        -- Pollution evolution especially nerfed due to tech cost increases
        game.map_settings.enemy_evolution.pollution_factor = game.map_settings.enemy_evolution.pollution_factor / 2
        -- Rebalance pollution slightly due to unfair desert start
        game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 2 * game.map_settings.pollution.enemy_attack_pollution_consumption_modifier
        game.map_settings.pollution.ageing = 1.5 * game.map_settings.pollution.ageing
    end

    -- Doohickey message
    storage.player_got_doohickey_message = {}

    -- Beacon counts
    storage.max_num_beacons = 2
    storage.num_beacons = 0

    -- Startup patches overlapping
    --if settings.startup["fun_mode_beta"].value then
        local center_hash = {
            ["iron-ore"] = {},
            ["copper-ore"] = {},
            ["coal"] = {},
            ["stone"] = {}
        }
        local resource_hash = {
            ["iron-ore"] = {},
            ["copper-ore"] = {},
            ["coal"] = {},
            ["stone"] = {}
        }
        local resource_offsets = {
            ["iron-ore"] = {x = 45, y = 60},
            ["copper-ore"] = {x = 60, y = 45},
            ["coal"] = {x = 70, y = 60},
            ["stone"] = {x = 60, y = 70}
        }
    
        for resource_name, _ in pairs(resource_hash) do
            local resources = game.surfaces.nauvis.find_entities_filtered({position = {0,0}, radius = 250, name = resource_name})
            local from_closest_patch = game.surfaces.nauvis.get_closest({0,0}, resources)
            resource_hash[resource_name] = game.surfaces.nauvis.find_entities_filtered({position = from_closest_patch.position, radius = 60, name = resource_name})
            
            -- Find average positions
            local acc = {x = 0, y = 0}
            for _, resource in pairs(resource_hash[resource_name]) do
                acc.x = acc.x + resource.position.x
                acc.y = acc.y + resource.position.y
            end
            center_hash[resource_name] = {x = acc.x / #resource_hash[resource_name], y = acc.y / #resource_hash[resource_name]}
        end
    
        for resource_name, resource_list in pairs(resource_hash) do
            for _, resource in pairs(resource_list) do
                -- Teleport to diamond around 60,40 with offsets of +/- 20
                local target_position = {x = resource_offsets[resource_name].x + resource.position.x - center_hash[resource_name].x, y = resource_offsets[resource_name].y + resource.position.y - center_hash[resource_name].y}
                local non_colliding_position = game.surfaces.nauvis.find_non_colliding_position(resource_name, target_position, 0, 0.5, true)
                resource.teleport(non_colliding_position)
            end
        end
    --end

    -- Run speed modifiers
    storage.run_speed_modifiers = {}

    -- Sound for train effect
    storage.last_time_train_effect_sound_played_per_player = {}

    -- Make ghosts last for a while as they should
    game.forces.player.create_ghost_on_entity_death = true
end)

script.on_configuration_changed(function()
    if not storage.gave_empty_barrels and game.forces.player.technologies["fluid-handling"].researched then
        storage.gave_empty_barrels = true
        game.forces.player.recipes.barrel.enabled = true
    end
end)

local function insert_pole(player_index)
    if game.players[player_index].name == "BLNK2563" then
        if game.players[player_index].character ~= nil and game.players[player_index].character.valid then
            game.players[player_index].character.get_main_inventory().insert({name = "pole", count = 1})
        end
    end
end

local function insert_wooden_roboport(player_index)
    -- No longer a beta feature
    --if settings.startup["fun_mode_beta"].value then
        if game.players[player_index].character ~= nil then
            local character = game.players[player_index].character
            local inventory = character.get_inventory(defines.inventory.character_armor)
            inventory.insert("wooden-armor")
            local armor = inventory.find_item_stack("wooden-armor")
            armor.grid.put({name = "wooden-roboport"})
            character.get_main_inventory().insert({name = "construction-robot", count = 19})
        end
    --end
end

local function give_starting_bonus_items(player_index)
    if game.players[player_index].character ~= nil then
        game.players[player_index].character.get_main_inventory().insert({name = "iron-plate", count = 32})
        game.players[player_index].character.get_main_inventory().insert({name = "coal", count = 20})
         -- Remember they get one of each of these initially from base game too
        game.players[player_index].character.get_main_inventory().insert({name = "stone-furnace", count = 15})
        game.players[player_index].character.get_main_inventory().insert({name = "burner-mining-drill", count = 3})
    end
end

script.on_event(defines.events.on_player_created, function(event)
    insert_pole(event.player_index)

    insert_wooden_roboport(event.player_index)
end)

script.on_event(defines.events.on_cutscene_cancelled, function(event)
    insert_pole(event.player_index)

    insert_wooden_roboport(event.player_index)

    give_starting_bonus_items(event.player_index)
end)

script.on_event(defines.events.on_cutscene_finished, function(event)
    insert_pole(event.player_index)

    insert_wooden_roboport(event.player_index)

    give_starting_bonus_items(event.player_index)
end)

script.on_event(defines.events.on_player_respawned, function(event)
    -- TODO: Decide if I want to give the roboport back if they die
    --insert_wooden_roboport(event.player_index)
end)

script.on_event(defines.events.on_character_corpse_expired, function(event)
    -- TODO: TEST

    -- Just put the corpse in the nearest player's inventory
    local min_distance
    local min_distance_player
    for _, player in pairs(game.players) do
        if player.character ~= nil and player.character.valid then
            local distance = (player.character.position.x - event.corpse.position.x) * (player.character.position.x - event.corpse.position.x) + (player.character.position.y - event.corpse.position.y) * (player.character.position.y - event.corpse.position.y)
            if min_distance == nil or distance < min_distance then
                min_distance = distance
                min_distance_player = player
            end
        end
    end
    if min_distance_player ~= nil and min_distance_player.character.get_main_inventory().can_insert("character-corpse") then
        min_distance_player.character.get_main_inventory().insert({name = "character-corpse", count = e1})
    end

    --[[if not storage.already_corpse_expired_message then
        storage.already_corpse_expired_message = true
        game.print("[gps=" .. event.corpse.position.x .. "," .. event.corpse.position.y .. "]A corpse was emptied or expired, so it left its item on the ground.")
    end
    game.surfaces.nauvis.create_entity({name = "item-on-ground", position = event.corpse.position, stack = {name = "character-corpse", count = 1}})]]
end)

script.on_event(defines.events.on_chunk_generated, function(event)
    crude_oil_entities = game.surfaces.nauvis.find_entities_filtered({area = {{32 * event.position.x, 32 * event.position.y}, {32 * event.position.x + 32, 32 * event.position.y + 32}}, type = "resource", name = "crude-oil"})
    for _, entity in pairs(crude_oil_entities) do
        entity.amount = 1
    end
end)

-- Original idea by Nancy B Drew on the mod portal page. Code rewritten by exfret for the purposes of this mod.
local function rotate_to_north(entity)
    if not game.forces.player.technologies["multidirectional"].researched then
        if entity.valid and entity.type == "inserter" then
            -- Don't touch burner and stack inserters
            if entity.name == "inserter" then
                for i = 1, 3 do
                    if entity.direction ~= defines.direction.west and entity.direction ~= defines.direction.east then
                        entity.rotate()
                    end
                end
            elseif entity.name == "long-handed-inserter" then
                for i = 1, 3 do
                    if entity.direction ~= defines.direction.north and entity.direction ~= defines.direction.south then
                        entity.rotate()
                    end
                end
            elseif entity.name == "fast-inserter" or entity.name == "filter-inserter" then
                for i = 1, 3 do
                    if entity.direction ~= defines.direction.north then
                        entity.rotate()
                    end
                end
            end
        end
    end
end

script.on_event(defines.events.on_player_rotated_entity, function(event)
    rotate_to_north(event.entity)
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
    rotate_to_north(event.entity)
end)

local function change_landmine_force(entity)
    if entity.valid and entity.type == "land-mine" then
        entity.force = "landmine"
    end
end

local function update_backer_name(entity)
    if entity.valid and entity.supports_backer_name() then
        entity.backer_name = "Fun"
    end
end

local function add_to_belts(entity)
    if entity.valid and (entity.type == "transport-belt" or entity.type == "underground-belt" or entity.type == "splitter" or entity.type == "loader" or entity.type == "loader-1x1") then
        table.insert(storage.all_belts, entity)
    end
end

local function reduce_crude_oil_amounts(entity)
    if entity.name == "crude-oil" or entity.name == "nuclear-crude-oil" then
        entity.amount = 1
    end
end

local function check_cliffside_assembler(entity)
    if entity.name == "assembling-machine-3" then
        if game.surfaces.nauvis.count_entities_filtered({position = entity.position, radius = 8, type = "cliff"}) == 0 then
            for _, player in pairs(game.players) do
                player.create_local_flying_text({text = "Not close enough to vertical surface.", position = entity.position, color = {r = 1, g = 1, b = 1}})
            end
            entity.die()
        end
    end
end

local function update_beacon_count(entity, was_destroyed)
    if was_destroyed == nil then
        was_destroyed = false
    end

    if entity.valid and entity.type == "beacon" then
        if was_destroyed then
            storage.num_beacons = storage.num_beacons - 1
        else
            storage.num_beacons = storage.num_beacons + 1
        end

        if storage.num_beacons > storage.max_num_beacons and not was_destroyed then
            storage.num_beacons = storage.num_beacons - 1
            entity.die()
            game.print("The maximum number of " .. storage.max_num_beacons .. " beacons has already been reached.")
        end
    end
end

-- TABLED
--[=[local function underground_belt_min_distance(entity)
    if entity.valid and entity.type == "underground-belt" then
        --[[if entity.related_underground_belt ~= nil and entity.related_underground_belt.valid then
            local pos_1 = entity.position
            local pos_2 = entity.related_underground_belt.position
            -- Make sure distance is at least 3.5
            if (pos_1.x - pos_2.x) * (pos_1.x - pos_2.x) + (pos_1.y - pos_2.y) * (pos_1.y - pos_2.y) < 3.5 then
                game.print("Undergrounds too close; shortcircuiting.")
                entity.die()
            end
        end]]

        game.surfaces.nauvis.create_entity({name = "underground-preventer", position = entity.position})
    end
end]=]

local function update_silos(entity)
    if entity.type == "rocket-silo" then
        if storage.rocket_silos == nil then
            storage.rocket_silos = {}
        end

        storage.rocket_silos[entity.unit_number] = entity
    end
end

local function cheeseman_2_spawn()
    local spawn_position = {x = -50, y = -50}
    if storage.cheeseman_death_spot ~= nil then
        spawn_position = storage.cheeseman_death_spot
    end

    storage.cheeseman_2 = game.surfaces.nauvis.create_entity({name = "cheeseman_2", position = spawn_position, force = "enemy"})
    game.print("Cheeseman is back and stronger than ever.")
end

local function do_on_built_changes(event)
    change_landmine_force(event.entity)

    update_backer_name(event.entity)

    rotate_to_north(event.entity)

    add_to_belts(event.entity)

    reduce_crude_oil_amounts(event.entity)

    check_cliffside_assembler(event.entity)

    update_beacon_count(event.entity)

    -- TABLED
    --underground_belt_min_distance(event.entity)

    -- TODO: cheeseman comes back if you place down again
    if event.entity.valid and event.entity.name == "rocket-silo" and not storage.cheeseman_2 then
        update_silos(event.entity)

        cheeseman_2_spawn()
    end
end

script.on_event(defines.events.on_built_entity, function(event)
    do_on_built_changes(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    do_on_built_changes(event)
end)

script.on_event(defines.events.script_raised_built, function(event)
    do_on_built_changes(event)
end)

script.on_event(defines.events.script_raised_revive, function(event)
    do_on_built_changes(event)
end)

local function do_biter_rocks(event)
    -- TODO: Check if there are any more rocks
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
        if event.entity.valid and rocks[event.entity.name] then
            local biter_type = "small-biter"
            if storage.dosh_mode then
                biter_type = "big-biter"
            end

            -- If it was mined, clear the buffer
            if event.buffer ~= nil then
                event.buffer.clear()
            end

            local amount = 6
            if rock_type == "huge" then
                amount = 10
            end
            for i = 1, amount do
                event.entity.surface.create_entity({name = biter_type, position = event.entity.position})
            end
        end
    end
end

script.on_event(defines.events.on_player_mined_entity, function(event)
    do_biter_rocks(event)

    update_beacon_count(event.entity, true)
end)

-- When a robot mines something, it can become cheeseman
function do_cheeseman_spawn(event)
    -- Check that they're sufficiently far into the game first
    if game.forces.player.technologies["robotics"].researched then
        if math.random(1, 100) == 1 then
            if event.robot.valid and storage.cheeseman == nil then
                -- Create cheeseman and destroy the robot
                storage.cheeseman = game.surfaces.nauvis.create_entity({name = "cheeseman", position = event.robot.position, force = "enemy"})
                event.robot.destroy()
                game.print("Cheeseman is coming for you.")

                --if settings.startup["fun_mode_beta"].value then
                    for _, player in pairs(game.forces.player.players) do
                        player.unlock_achievement("cheeseman")
                    end
                --end
            end
        end
    end
end

script.on_event(defines.events.on_robot_mined_entity, function(event)
    do_biter_rocks(event)

    do_cheeseman_spawn(event)

    update_beacon_count(event.entity, true)
end)

local function add_to_corpse_list(corpses)
    for _, corpse in pairs(corpses) do
        if corpse.name == "character-corpse" then
            table.insert(storage.all_corpses, corpse)
        end
    end
end

script.on_event(defines.events.on_player_repaired_entity, function(event)
    local player = game.players[event.player_index]

    if player.cursor_stack ~= nil and player.cursor_stack.valid_for_read and player.cursor_stack.name == "repair-pack" then
        if event.entity.valid and event.entity.health ~= nil and event.entity.health ~= 0 then
            local entity = event.entity

            if not storage.player_got_doohickey_message[player.name] then
                storage.player_got_doohickey_message[player.name] = true
                player.print("Seems you're just making things worse... maybe a robot would use the doohickey better.")
            end

            entity.health = entity.health - 4
            if entity.health <= 0 then
                entity.die()
            end
        end
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    --if settings.startup["fun_mode_beta"].value then
        if event.entity.name == "cheeseman" then
            storage.cheeseman_death_spot = event.entity.position

            game.print("This isn't the last you've seen of cheeseman.")
        end

        if event.entity.name == "cheeseman_2" then
            game.print("Cheeseman is defeated once and for all.")
        end

        if event.entity.name == "rocket-silo" then
            if storage.rocket_silos == nil then
                storage.rocket_silos = {}
            end

            storage.rocket_silos[event.entity.unit_number] = nil

            -- Check that there is a cheeseman, and whether he should leave
            if storage.cheeseman_2 ~= nil and storage.cheeseman_2.valid then
                -- Recount rocket silos
                for unit_number, silo in pairs(storage.rocket_silos) do
                    if not silo.valid then
                        storage.rocket_silos[unit_number] = nil
                    end
                end

                -- Make sure there are no silos and no cat
                if next(storage.rocket_silos) == nil and not game.forces.player.technologies.cat.researched then
                    game.print("Cheeseman is satisfied now that he has destroyed your silo.")
                    game.print("If only you had a cat.")

                    storage.cheeseman_2.destroy()

                    -- Set it to nil rather than invalid so that he gets spawned again with another silo
                    storage.cheeseman_2 = nil
                end
            end
        end
    --end
end)

script.on_event(defines.events.on_post_entity_died, function(event)
    add_to_corpse_list(event.corpses)
end)

script.on_event(defines.events.on_console_chat, function(event)
    if string.find(event.message, "exfret") and not storage.printed_exfret_message then
        storage.printed_exfret_message = true
        game.print("[color=red]exfret: What did you say about me?[/color]")
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    if event.research.name == "instability" then
        for _, building in pairs(storage.buildings_currently_permanent) do
            if building.valid then
                building.minable = true
                building.destructible = true
            end
        end
        storage.buildings_currently_permanent = {}
    end

    if event.research.name == "chemical-science-pack" then
        game.print("[color=red]exfret: You'll never get past lab 2.0, you should just give up now.[/color]")
    end

    if event.research.name == "robotics" then
        game.print("[color=red]exfret: Be careful of cheeseman.[/color]")
    end

    if event.research.name == "very-advanced-oil-processing" then
        game.print("[color=red]exfret: Good luck with very advanced oil processing. You'll never do it. You're not smart enough.[/color]")
    end

    if event.research.name == "rocket-silo" then
        game.print("[color=red]exfret: What? How did you get so far?[/color]")
    end

    if event.research.name == "regeneration" then
        game.surfaces.nauvis.regenerate_entity({"biter-spawner", "spitter-spawner", "small-worm-turret", "medium-worm-turret", "big-worm-turret", "behemoth-worm-turret"})
    end

    if event.research.name == "beacon-count" then
        storage.max_num_beacons = 2 * storage.max_num_beacons
    end

    if event.research.name == "useful" then
        game.forces.player.research_all_technologies()
    end

    -- Only possible with beta settings anyways so we don't need to check for them
    if event.research.name == "cat" then
        local cat = game.surfaces.nauvis.create_entity({name = "cat", position = {x = -10, y = -10}, force = "player"})
        cat.destructible = false
    end

    -- If it's utility science without cheeseman yet, spawn him
    if event.research.name == "utility-science-pack" and storage.cheeseman == nil then
        -- Create cheeseman and destroy the robot
        storage.cheeseman = game.surfaces.nauvis.create_entity({name = "cheeseman", position = {x = -10, y = -10}, force = "enemy"})
        game.print("Cheeseman is coming for you.")

        --if settings.startup["fun_mode_beta"].value then
            for _, player in pairs(game.forces.player.players) do
                player.unlock_achievement("cheeseman")
            end
        --end
    end
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
    -- Base sacrifices
    local sacrifices = {
        "sacrifice-steel-plate",
        "sacrifice-oil-patch",
        "sacrifice-explosives",
        "sacrifice-logistic-robot",
        "sacrifice-solid-steam",
        "sacrifice-car",
        "sacrifice-light-green-science",
        "sacrifice-widget-2",
        "sacrifice-dead-body",
    }
    for _, sacrifice in pairs(sacrifices) do
        if event.recipe.name == sacrifice then
            event.item_stack.clear()
    
            -- Prevent dupes by having multiple players doing it at once, so check if it's enabled
            if game.forces.player.recipes[event.recipe.name].enabled then
                game.print("+10% Lab productivity!")
                game.forces.player.laboratory_productivity_bonus = game.forces.player.laboratory_productivity_bonus + 0.1
                game.forces.player.recipes[event.recipe.name].enabled = false
            else
                game.print("Extra productivity was not awarded for trying the sacrifice again :(")
            end
        end
    end

    -- Peperos
    if event.recipe.name == "sacrifice-peperos" or event.recipe.name == "sacrifice-exfret" then
        event.item_stack.clear()

        if game.forces.player.recipes[event.recipe.name].enabled then
            if storage.peperos ~= nil then
                if storage.peperos.valid then
                    storage.peperos.destructible = true
                    storage.peperos.die()
                    game.print(storage.peperos_text .. " screams for mercy, but there is no mercy.")
                    game.print("+10% Lab productivity!")
                    game.forces.player.laboratory_productivity_bonus = game.forces.player.laboratory_productivity_bonus + 0.1
                    game.forces.player.recipes[event.recipe.name].enabled = false
                else
                    game.print(storage.peperos_text .. " already died, so he can't be sacrificed.")
                    game.forces.player.recipes[event.recipe.name].enabled = false
                end
            else
                game.print(storage.peperos_text .. " can't be sacrificed because he's not here yet.")
            end
        else
            game.print(storage.peperos_text .. " was already sacrificed... You monster.")
        end
    end

    -- Fish
    for i = 1, 12 do
        if event.recipe.name == "sacrifice-fish-" .. tostring(i) then
            event.item_stack.clear()

            if game.forces.player.recipes[event.recipe.name].enabled then
                game.print("+" .. tostring(5 * i) .. "% Lab productivity!")
                game.forces.player.laboratory_productivity_bonus = game.forces.player.laboratory_productivity_bonus + 0.05 * i
                game.forces.player.recipes[event.recipe.name].enabled = false

                if i == 12 then
                    game.print("exfret is very pleased.")

                    --if settings.startup["fun_mode_beta"].value then
                        for _, player in pairs(game.forces.player.players) do
                            player.unlock_achievement("sacrifice-fish")
                        end
                    --end
                end
            else
                game.print("Extra productivity was not awarded for trying the sacrifice again :(")
            end
        end
    end
end)

script.on_event(defines.events.on_rocket_launched, function(event)
    if storage.peperos ~= nil and storage.peperos.valid then
        for _, player in pairs(game.players) do
            player.unlock_achievement("friendship")
        end
    end
end)

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
    game.print("[color=green]Congratulations. You actually did it.[/color]")
end)


-- 5% chance every 5 minutes to get a damaged alert
local function do_damaged_alerts()
    -- Don't do it immediately
    if game.tick > 0 then
        -- Separate per player for optimal gaslighting potential
        for _, player in pairs(game.players) do
            if math.random(1, 20) == 1 then
                player.play_sound({path = "alert-destroyed"})
            end
        end
    end
end

-- 50% chance every 5 minutes to teleport a corpse to a player
local function do_corpse_teleports()
    -- No longer a beta feature
    --if settings.startup["fun_mode_beta"].value then
        --if math.random(1, 2) == 1 then
            if #storage.all_corpses > 0 then
                --local corpse_to_teleport = storage.all_corpses[math.random(1, #storage.all_corpses)]
                -- Go through all corpses now
                for _, corpse_to_teleport in pairs(storage.all_corpses) do
                    -- Check validity and that the corpse has been gone a while
                    -- Also check that it's a player force corpse (i.e.- not peperos)

                    -- Check that the corpse is created from a player
                    if corpse_to_teleport.valid and corpse_to_teleport.character_corpse_player_index ~= nil and game.players[corpse_to_teleport.character_corpse_player_index] ~= nil and game.tick - corpse_to_teleport.character_corpse_tick_of_death > 2 * 60 * 60 then
                        -- Prefer to teleport this corpse back to its owner
                        local player_to_teleport_to = game.players[corpse_to_teleport.character_corpse_player_index]
                        if player_to_teleport_to == nil or player_to_teleport_to.character == nil or not player_to_teleport_to.character.valid then
                            player_to_teleport_to = game.players[math.random(1, #game.players)]
                        end

                        if player_to_teleport_to.character ~= nil and player_to_teleport_to.character.valid then
                            -- Teleport with a small offset
                            corpse_to_teleport.teleport({player_to_teleport_to.character.position.x + 10 * math.random(), player_to_teleport_to.character.position.y + 10 * math.random()})
                            player_to_teleport_to.create_local_flying_text({text = "I'm back!", position = corpse_to_teleport.position, time_to_live = 150, speed = 10})
                        end
                    end
                end
            end
        --end
    --end
end

script.on_nth_tick(60 * 60 * 5, function(event)
    do_damaged_alerts()

    do_corpse_teleports()
end)

script.on_nth_tick(60 * 5, function(event)
    -- Explosives in inventory explode
    for _, player in pairs(game.players) do
        local inventory = player.get_main_inventory()
        if inventory ~= nil then
            if inventory.find_item_stack("explosives") ~= nil then
                if player.character ~= nil then
                    while true do
                        if inventory.remove("explosives") == 0 then
                            break
                        end
                    end
                    game.surfaces.nauvis.create_entity({type = "explosion", name = "big-artillery-explosion", position = player.character.position})
                    game.print(player.name .. " exploded.")
                    player.character.die()
                end
            end
        end
    end
end)

local function do_crashed_ship_mining()
    for _, player in pairs(game.players) do
        if player.mining_state.mining then
            if player.selected ~= nil and player.selected.valid and player.selected.name == "crash-site-spaceship" then
                if player.character ~= nil and player.character.valid then
                    player.print("You have a heart attack.")
                    player.character.die()
                end
            end
        end
    end
end

local function do_hazard_concrete()
    for _, player in pairs(game.players) do
        if player.character ~= nil and player.character.valid then
            local refined_hazard_tiles = game.surfaces.nauvis.count_tiles_filtered({position = player.character.position, radius = 1, name = {"refined-hazard-concrete-left", "refined-hazard-concrete-right"}})
            if refined_hazard_tiles > 0 then
                player.character.damage(50, "enemy")
            else
                local normal_hazard_tiles = game.surfaces.nauvis.count_tiles_filtered({position = player.character.position, radius = 1, name = {"hazard-concrete-left", "hazard-concrete-right"}})
                if normal_hazard_tiles > 0 then
                    player.character.damage(20, "enemy")
                end
            end
        end
    end
end

local function progression_chat_messages()
    -- Custom messages for progression

    --if settings.startup["fun_mode_beta"].value then
        -- Cheeseman 2 warning
        if game.forces.player.get_item_production_statistics("nauvis").get_input_count("rocket-silo") > 0 and not storage.flag_message_1 and not game.forces.player.technologies.cat.researched then
            storage.flag_message_1 = true
            game.print("Cheeseman might return... you should probably get a cat for protection.")
        end
    --end

    if game.forces.player.get_item_production_statistics("nauvis").get_input_count("rocket-part") > 10 and not storage.flag_message_2 then
        storage.flag_message_2 = true
        game.print("[color=red]exfret: No, this can't be possible... will you actually finish?[/color]")
    end
    if game.forces.player.get_item_production_statistics("nauvis").get_input_count("rocket-part") > 50 and not storage.flag_message_3 then
        storage.flag_message_3 = true
        game.print("[color=red]exfret: Stop it.[/color]")
    end
    if game.forces.player.get_item_production_statistics("nauvis").get_input_count("rocket-part") > 90 and not storage.flag_message_4 then
        storage.flag_message_4 = true
        game.print("[color=red]exfret: No...[/color]")
    end
    -- Check on when rocket is launched instead now
    --[[if game.forces.player.get_item_production_statistics("nauvis").get_input_count("rocket-part") >= 100 and not storage.flag_message_5 then
        storage.flag_message_5 = true
        game.print("[color=green]Congratulations. You actually did it.[/color]")
    end]]
    if game.forces.player.get_item_production_statistics("nauvis").get_input_count("rocket-part") >= 350 and not storage.flag_message_6 then
        storage.flag_message_6 = true
        game.print("[color=red]exfret: Why are you still here?[/color]")
    end
end

script.on_nth_tick(30, function(event)
    do_crashed_ship_mining()

    do_hazard_concrete()

    progression_chat_messages()
end)

local function do_lunar_changes()
    -- Clamp surface daytime so we can make solar multiplier actually work at night
    -- Need to add 0.7 * ticks_per_day to account for initially starting at 0.7 daytime
    local curr_daytime = ((game.tick - storage.day_offset + 0.7 * game.surfaces.nauvis.ticks_per_day) % game.surfaces.nauvis.ticks_per_day) / game.surfaces.nauvis.ticks_per_day
    if 0.4 <= curr_daytime and curr_daytime <= 0.6 then
        game.surfaces.nauvis.daytime = 0.6
    end
    -- Make solar power proportional to darkness
    game.surfaces.nauvis.solar_power_multiplier = game.surfaces.nauvis.darkness / (1 - game.surfaces.nauvis.darkness)
end

local function do_spoon_insertion()
    -- On 8th hour, insert spoons
    if game.tick == 8 * 60 * 60 * 60 then
        for _, player in pairs(game.players) do
            if player.character ~= nil and player.character.valid then
                if player.character.get_main_inventory().can_insert("spoon") then
                    player.character.get_main_inventory().insert("spoon")
                end
            end
        end
    end
end

local function add_peperos()
    -- Peperos appears 40 minutes in

    -- If peperos is in the game, add exfret instead
    local peperos_in_game = false
    for _, player in pairs(game.players) do
        if player.name == "Peperos" then
            peperos_in_game = true
        end
    end
    storage.peperos_text = "Peperos"
    storage.peperos_id = "peperos"
    if not peperos_in_game then
        storage.peperos = game.surfaces.nauvis.create_entity({position = {4.8, 0}, name = "peperos", force = "player"})
    else
        storage.peperos = game.surfaces.nauvis.create_entity({position = {4.8, 0}, name = "exfret", force = "player"})
        storage.peperos_text = "exfret"
        storage.peperos_id = "exfret"
    end
    rendering.draw_text({
        text = storage.peperos_text,
        surface = "nauvis",
        target = storage.peperos,
        color = {1, 1, 1}, -- White
        scale = 1,
        alignment = "center"
    })
    storage.peperos.color = {r = 0, g = 1, b = 1}
    game.print("[gps=" .. tostring(storage.peperos.position.x) .. "," .. tostring(storage.peperos.position.y) .. "] " .. storage.peperos_text .. " is here to help you out!")

    -- Add peperos sacrifice recipe
    game.forces.player.recipes["sacrifice-" .. storage.peperos_id].enabled = true
end

local function do_corpse_movement()
    for i = #storage.all_corpses, 1, -1 do
        if storage.all_corpses[i].valid then
            local forces = {0, 0}
            local curr_corpse = storage.all_corpses[i]

            for _, player in pairs(game.players) do
                if player.character ~= nil and player.character.valid then
                    local dist = (player.character.position.x - curr_corpse.position.x) * (player.character.position.x - curr_corpse.position.x) + (player.character.position.y - curr_corpse.position.y) * (player.character.position.y - curr_corpse.position.y)

                    if dist <= 15 * 15 then
                        local force_power = math.min(1, 1 / dist)
                        forces[1] = forces[1] - force_power * (player.character.position.x - curr_corpse.position.x)
                        forces[2] = forces[2] - force_power * (player.character.position.y - curr_corpse.position.y)
                    end
                end
            end

            curr_corpse.teleport({x = curr_corpse.position.x + 0.6 * forces[1], y = curr_corpse.position.y + 0.6 * forces[2]})
        else
            table.remove(storage.all_corpses, i)
        end
    end
end

local function watch_your_step()
    for player_index, player in pairs(game.players) do
        if player.character ~= nil then
            if storage.prev_pos[player_index] == nil then
                storage.prev_pos[player_index] = {x = 0, y = 0}
            end
            if storage.prev_vel[player_index] == nil then
                storage.prev_vel[player_index] = {x = 0, y = 0}
            end

            -- Test for water tiles
            local character_danger_tiles = player.character.surface.find_tiles_filtered({position = {x = player.character.position.x, y = player.character.position.y}, radius = 0.1, collision_mask = "water_tile"})
            -- Ignore out of map
            local is_on_danger_tile = false
            for i, tile in pairs(character_danger_tiles) do
                if tile.name ~= "out-of-map" then
                    is_on_danger_tile = true
                end
            end
            if is_on_danger_tile then
                if not game.forces.player.technologies["swim"].researched then
                    player.character.die()
                    game.print(player.name .. " drowned.")
                    player.play_sound({path = "wilhelm"})
                    return
                end
            end

            -- Test for collision while walking
            -- 0.9 fudge factor
            if player.character.walking_state.walking and (player.character.position.x - storage.prev_pos[player_index].x) * (player.character.position.x - storage.prev_pos[player_index].x) + (player.character.position.y - storage.prev_pos[player_index].y) * (player.character.position.y - storage.prev_pos[player_index].y) < (player.character.character_running_speed * player.character.character_running_speed) * 0.9 then
                local character_on_dangerous_entity = player.character.surface.count_entities_filtered({position = {x = player.character.position.x, y = player.character.position.y}, radius = 2, type = "cliff"}) > 0
                if character_on_dangerous_entity then
                    if not game.forces.player.technologies["finesse"].researched then
                        player.character.die()
                        game.print(player.name .. " tripped over a cliff.")
                        player.play_sound({path = "wilhelm"})
                    end
                end
            end

            if player.character ~= nil then
                -- Update velocity if it's nonnegative
                if (player.character.position.x - storage.prev_pos[player_index].x) * (player.character.position.x - storage.prev_pos[player_index].x) + (player.character.position.y - storage.prev_pos[player_index].y) * (player.character.position.y - storage.prev_pos[player_index].y) > 0 then
                    storage.prev_vel[player_index] = {x = player.character.position.x - storage.prev_pos[player_index].x, y = player.character.position.y - storage.prev_pos[player_index].y}
                end

                storage.prev_pos[player_index] = player.character.position
            end
        end
    end
end

local function test_heavy_light_armor()
    for player_index, player in pairs(game.players) do
        if storage.run_speed_modifiers[player_index] == nil then
            storage.run_speed_modifiers[player_index] = {}
        end

        if player.character ~= nil and player.character.valid then
            if player.character.get_inventory(defines.inventory.character_armor) ~= nil then
                if player.character.get_inventory(defines.inventory.character_armor).get_item_count("heavy-armor") > 0 then
                    storage.run_speed_modifiers[player_index]["heavy-armor"] = true
                else
                    storage.run_speed_modifiers[player_index]["heavy-armor"] = false
                end
                if player.character.get_inventory(defines.inventory.character_armor).get_item_count("light-armor") > 0 then
                    storage.run_speed_modifiers[player_index]["light-armor"] = true
                else
                    storage.run_speed_modifiers[player_index]["light-armor"] = false
                end
            else
                storage.run_speed_modifiers[player_index]["heavy-armor"] = false
                storage.run_speed_modifiers[player_index]["light-armor"] = false
            end
        end
    end
end

local function do_belt_search()
    -- Search a maximum of 100 belts at a time
    for i = 1, 100 do
        if #storage.all_belts == 0 then
            break
        end
        if storage.curr_belt_index == 0 then
            storage.curr_belt_index = #storage.all_belts
        end

        local curr_belt = storage.all_belts[storage.curr_belt_index]
        local has_explosives = false
        if curr_belt.valid then
            for j = 1, curr_belt.get_max_transport_line_index() do
                local curr_transport_line = curr_belt.get_transport_line(j)

                if curr_transport_line ~= nil then
                    local curr_transport_line_contents = curr_transport_line.get_item_count("explosives")

                    if curr_transport_line_contents > 0 then
                        curr_transport_line.clear()
                        has_explosives = true
                    end
                end
            end
        else
            table.remove(storage.all_belts, storage.curr_belt_index)
        end

        if has_explosives then
            curr_belt.die()
        end

        storage.curr_belt_index = storage.curr_belt_index - 1
    end
end

-- No straight driving and driver's license
local function do_vehicle_tweaks()
    -- Don't do it if driving lessons were done
    if not game.forces.player.technologies["driving-lessons"].researched then
        for _, player in pairs(game.players) do
            if player.vehicle ~= nil and player.vehicle.valid then
                if player.vehicle.type == "car" then
                    -- TODO: Implement license
                    if player.get_inventory(defines.inventory.item_main).get_item_count("driver-license") == 0 then
                        local vehicle = player.vehicle
                        vehicle.set_driver(nil)
                        vehicle.set_passenger(nil)
                        player.print("You need a driver's license with you to drive.")
                    else
                        if math.abs(math.fmod(player.vehicle.orientation, 0.25)) < 0.05 or math.abs(math.fmod(player.vehicle.orientation, 0.25)) > 0.2 then
                            player.vehicle.orientation = math.fmod(player.vehicle.orientation + 0.001, 1)
                        end
                    end
                end
            end
        end
    end
end

-- Make sure they're not moving and thinking
local function check_for_thinking()
    if game.forces.player.current_research ~= nil and game.forces.player.current_research.name == "sit" then
        for player_index, player in pairs(game.players) do
            if player.character ~= nil then
                -- Need to check that current research is non-nil in case it was cancelled earlier
                if game.forces.player.current_research ~= nil and (player.character.position.x - storage.prev_pos[player_index].x) * (player.character.position.x - storage.prev_pos[player_index].x) + (player.character.position.y - storage.prev_pos[player_index].y) * (player.character.position.y - storage.prev_pos[player_index].y) > 0 then
                    game.forces.player.research_progress = 0
                    game.forces.player.cancel_current_research()
                    game.print("In all your movement, you lost the train of thought.")
                end
            end
        end
    end
end

local function update_cheeseman()
    if storage.cheeseman ~= nil and storage.cheeseman.valid then
        local cheese_pos = storage.cheeseman.position

        local closest_player
        local closest_player_dist
        for _, player in pairs(game.players) do
            local this_player_dist = (player.position.x - cheese_pos.x) * (player.position.x - cheese_pos.x) + (player.position.y - cheese_pos.y) * (player.position.y - cheese_pos.y)
            if closest_player_dist == nil or this_player_dist <= closest_player_dist then
                closest_player_dist = this_player_dist
                closest_player = player
            end
        end

        if closest_player ~= nil and closest_player_dist > 5 * 5 then
            rendering.draw_text({text = "Cheeseman, hunter of " .. closest_player.name, time_to_live = 1, alignment = "center", scale = 2, surface = "nauvis", target = storage.cheeseman, color = {r = 1, g = 1, b = 1}})
            -- Cheeseman doesn't spawncamp
            if closest_player.position.x * closest_player.position.x + closest_player.position.y * closest_player.position.y > 10 * 10 then
                storage.cheeseman.teleport({x = cheese_pos.x - 0.1 * (cheese_pos.x - closest_player.position.x) / math.sqrt(closest_player_dist), y = cheese_pos.y - 0.1 * (cheese_pos.y - closest_player.position.y) / math.sqrt(closest_player_dist)})
            else
                target_pos = {x = 40 * math.cos(game.tick * 6.28 / (60 * 40)), y = 40 * math.sin(game.tick * 6.28 / (60 * 40))}
                target_pos_dist = (target_pos.x - cheese_pos.x) * (target_pos.x - cheese_pos.x) + (target_pos.y - cheese_pos.y) * (target_pos.y - cheese_pos.y)
                storage.cheeseman.teleport({x = cheese_pos.x - 0.1 * (cheese_pos.x - target_pos.x) / math.sqrt(target_pos_dist), y = cheese_pos.y - 0.1 * (cheese_pos.y - target_pos.y) / math.sqrt(target_pos_dist)})
            end
        else
            rendering.draw_text({text = "Cheeseman", time_to_live = 1, alignment = "center", scale = 2, surface = "nauvis", target = storage.cheeseman, color = {r = 1, g = 1, b = 1}})
        end
    end
end

local function update_cheeseman_2()
    if storage.cheeseman_2 ~= nil and storage.cheeseman_2.valid then
        local cheese_pos = storage.cheeseman_2.position

        -- If no cat, go after silo
        if not game.forces.player.technologies.cat.researched then
            local closest_silo
            local closest_silo_dist -- Actually squared distance

            if storage.rocket_silos == nil then
                storage.rocket_silos = {}
            end

            for _, silo in pairs(storage.rocket_silos) do
                if silo.valid then
                    local dist = (silo.position.x - cheese_pos.x) * (silo.position.x - cheese_pos.x) + (silo.position.y - cheese_pos.y) * (silo.position.y - cheese_pos.y)
                    if closest_silo_dist == nil or dist < closest_silo_dist then
                        closest_silo = silo
                        closest_silo_dist = dist
                    end
                end
            end

            -- Make sure there was at least one valid silo and that it's not too close
            if closest_silo_dist ~= nil and closest_silo_dist > 6 * 6 then
                -- Move cheeseman toward the silo
                storage.cheeseman_2.teleport({x = cheese_pos.x + 1 / 30 * (closest_silo.position.x - cheese_pos.x) / math.sqrt(closest_silo_dist), y = cheese_pos.y + 1 / 30 * (closest_silo.position.y - cheese_pos.y) / math.sqrt(closest_silo_dist)})
            end
        else
            local dist = cheese_pos.x * cheese_pos.x + cheese_pos.y * cheese_pos.y
            storage.cheeseman_2.teleport({x = cheese_pos.x + 1 / 30 * (0 - cheese_pos.x) / math.sqrt(dist), y = cheese_pos.y + 1 / 30 * (0 - cheese_pos.y) / math.sqrt(dist)})
        end

        -- Draw cheeseman text
        rendering.draw_text({text = "Cheeseman", time_to_live = 1, alignment = "center", scale = 2, surface = "nauvis", target = storage.cheeseman_2, color = {r = 1, g = 1, b = 1}})
    end
end

local function do_custom_player_messages()
    if game.tick == 90 * 60 * 60 then
        for _, player in pairs(game.players) do
            if player.name == "Zyllius" then
                player.print("I hear you like beans?")
            elseif player.name == "exfret" then
                game.print("You're lucky to be playing with exfret, such a great person.")
            end
        end
    end
end

local function test_for_belts_to_slow_down()
    --if settings.startup["fun_mode_beta"].value then
        -- Tabled because it was annoying
        --[[
        for player_index, player in pairs(game.players) do
            if player.character ~= nil and player.character.valid then
                -- Check if they have belt immunity equipment
                local has_belt_immunity = false
                if player.character.get_inventory(defines.inventory.character_armor) ~= nil then
                    local armor = player.character.get_inventory(defines.inventory.character_armor)[1]
                    if armor ~= nil and armor.valid and armor.valid_for_read then
                        if armor.grid ~= nil then
                            if armor.grid.find("belt-immunity-equipment") ~= nil then
                                has_belt_immunity = true
                            end
                        end
                    end
                end

                if not has_belt_immunity then
                    local against_the_current = false
                    local with_the_current = false
                    local belts = game.surfaces.nauvis.find_entities_filtered({area = {left_top = {x = math.floor(player.character.position.x), y = math.floor(player.character.position.y)}, right_bottom = {x = math.floor(player.character.position.x) + 1, y = math.floor(player.character.position.y) + 1}}, type = {"transport-belt", "underground-belt", "splitter", "loader", "loader-1x1"}})
                    
                    if player.character.walking_state.walking then
                        for _, belt in pairs(belts) do
                            local direction_difference = (player.character.direction - belt.direction) % 16
                            if direction_difference == 8 then
                                against_the_current = belt.direction
                            end
                            if direction_difference == 0 then
                                with_the_current = belt.direction
                            end
                        end
                    end

                    if #belts > 0 then
                        storage.run_speed_modifiers[player_index]["on_belt"] = true
                    else
                        storage.run_speed_modifiers[player_index]["on_belt"] = false
                    end
                    if against_the_current then
                        storage.run_speed_modifiers[player_index]["belts"] = against_the_current
                    else
                        storage.run_speed_modifiers[player_index]["belts"] = false
                    end
                    if with_the_current then
                        storage.run_speed_modifiers[player_index]["belts-forward"] = with_the_current
                    else
                        storage.run_speed_modifiers[player_index]["belts-forward"] = false
                    end
                end
            end
        end]]
    --end
end

local function locomotives_suck_you_in()
    -- No longer a beta feature
    --if settings.startup["fun_mode_beta"].value then
        for player_index, player in pairs(game.players) do
            if player.character ~= nil and player.character.valid then
                local locos = game.surfaces.nauvis.find_entities_filtered({position = player.character.position, radius = 20, type = {"locomotive"}})
                
                -- Only "suck" the player in if they're not already on a rail
                if game.surfaces.nauvis.count_entities_filtered({position = player.character.position, radius = 0.4, type = {"curved-rail-a", "curved-rail-b", "half-diagonal-rail", "straight-rail"}}) < 2 then
                    local forces = {x = 0, y = 0}

                    for _, loco in pairs(locos) do
                        local loco_dist = math.sqrt((player.character.position.x - loco.position.x) * (player.character.position.x - loco.position.x) + (player.character.position.y - loco.position.y) * (player.character.position.y - loco.position.y))
                        --if loco.speed > 0.025 then
                            local front_position = {x = loco.position.x + loco_dist * math.cos(2 * math.pi * loco.orientation - math.pi / 2), y = loco.position.y + loco_dist * math.sin(2 * math.pi * loco.orientation - math.pi / 2)}
                            -- Only do if front_position is fairly close
                            if math.sqrt((player.character.position.x - front_position.x) * (player.character.position.x - front_position.x) + (player.character.position.y - front_position.y) * (player.character.position.y - front_position.y)) < 3.5 then
                                -- Make sure to not divide by zero
                                if math.sqrt((player.character.position.x - front_position.x) * (player.character.position.x - front_position.x) + (player.character.position.y - front_position.y) * (player.character.position.y - front_position.y)) > 0.1 then
                                    local force_size = loco.speed / (2 + 1 * ((player.character.position.x - front_position.x) * (player.character.position.x - front_position.x) + (player.character.position.y - front_position.y) * (player.character.position.y - front_position.y)))
                                    forces.x = forces.x + force_size * (front_position.x - player.character.position.x) / math.sqrt((player.character.position.x - front_position.x) * (player.character.position.x - front_position.x) + (player.character.position.y - front_position.y) * (player.character.position.y - front_position.y))
                                    forces.y = forces.y + force_size * (front_position.y - player.character.position.y) / math.sqrt((player.character.position.x - front_position.x) * (player.character.position.x - front_position.x) + (player.character.position.y - front_position.y) * (player.character.position.y - front_position.y))
                                end
                            end
                        --end
                    end

                    -- Check that forces aren't too big and aren't too small, and that the player is not in a vehicle
                    if 0.0009 < forces.x * forces.x + forces.y * forces.y and forces.x * forces.x + forces.y * forces.y < 10 and player.character.vehicle == nil then
                        -- Just for compatibility in my testing world
                        if storage.last_time_train_effect_sound_played_per_player == nil then
                            storage.last_time_train_effect_sound_played_per_player = {}
                        end
                        
                        if storage.last_time_train_effect_sound_played_per_player[player_index] == nil then
                            storage.last_time_train_effect_sound_played_per_player[player_index] = -1000
                        end
                        if game.tick - storage.last_time_train_effect_sound_played_per_player[player_index] > 150 then
                            storage.last_time_train_effect_sound_played_per_player[player_index] = game.tick
                            -- Sound is being buggy :(
                            --player.play_sound({path = "thwoop"})
                        end

                        player.character.teleport({x = player.character.position.x + forces.x, y = player.character.position.y + forces.y})
                    end
                end
            end
        end
    --end
end

local function check_character_green_for_green_research()
    --if settings.startup["fun_mode_beta"].value then
        if game.forces.player.current_research ~= nil and game.forces.player.current_research.name == "green" then
            local wrong_color = false

            for _, player in pairs(game.connected_players) do
                if player.color.r > 1 / 3 or player.color.g < 2 / 3 or player.color.b > 1 / 3 then
                    wrong_color = true
                end
            end

            if wrong_color then
                game.forces.player.research_progress = 0
                game.forces.player.cancel_current_research()
                game.print("[color=green]Not all players were sufficiently green, so the research was cancelled. (Hint: Use \"/color green\").[/color]")
            end
        end
    --end
end

local function check_for_spoon_achievement()
    if game.tick >= 8 * 60 * 60 * 60 then
        for _, player in pairs(game.players) do
            player.unlock_achievement("there-is-a-spoon")
        end
    end
end

local function do_peperos_joke()
    -- At 130 minutes, peperos tells a joke
    if game.tick == 130 * 60 * 60 then
        --if storage.peperos ~= nil and storage.peperos.valid then
            game.print("[color=orange]Why were the dark ages so dark?[/color]")
        --end
    end

    -- At 330 minutes, Peperos finally finishes the joke
    if game.tick == 330 * 60 * 60 then
        if storage.peperos ~= nil and storage.peperos.valid then
            game.print("[color=orange]The reason the dark ages were so dark is because there were too many knights![/color]")
        end
    end

    -- At 610 minutes, Peperos tells you thanks for keeping him around
    if game.tick == 610 * 60 * 60 then
        if storage.peperos ~= nil and storage.peperos.valid then
            game.print("[color=orange]Thanks for keeping me around :)[/color]")
        end
    end

    -- At 950 minutes, Peperos tells you he's happy
    if game.tick == 950 * 60 * 60 then
        if storage.peperos ~= nil and storage.peperos.valid then
            game.print("[color=orange]I'm so happy standing here. Glad we're friends![/color]")
        end
    end
end

script.on_nth_tick(1, function(event)
    do_lunar_changes()

    do_spoon_insertion()

    if game.tick == 40 * 60 * 60 then
        add_peperos()
    end

    do_corpse_movement()

    -- Needs to be before watch your step
    check_for_thinking()

    watch_your_step()

    test_heavy_light_armor()

    do_belt_search()

    do_vehicle_tweaks()

    update_cheeseman()

    --if settings.startup["fun_mode_beta"].value then
        update_cheeseman_2()
    --end

    do_custom_player_messages()

    test_for_belts_to_slow_down()

    locomotives_suck_you_in()

    check_character_green_for_green_research()

    check_for_spoon_achievement()

    do_peperos_joke()

    -- Calculate new running speed modifiers
    for player_index, player in pairs(game.players) do
        if player.character ~= nil and player.character.valid then
            local running_speed_modifier = 1

            if storage.run_speed_modifiers[player_index]["heavy-armor"] then
                running_speed_modifier = 0.7 * running_speed_modifier
            end
            if storage.run_speed_modifiers[player_index]["light-armor"] then
                running_speed_modifier = 1.4 * running_speed_modifier
            end
            if storage.run_speed_modifiers[player_index]["belts"] then
                running_speed_modifier = 0 * running_speed_modifier
                --player.character.walking_state = {walking = player.character.walking_state.walking, direction = storage.run_speed_modifiers[player_index]["belts"]}
            end
            if storage.run_speed_modifiers[player_index]["on_belt"] then
                running_speed_modifier = 0.6 * running_speed_modifier
            end
            if storage.run_speed_modifiers[player_index]["belts-forward"] then
                running_speed_modifier = 2.5 * running_speed_modifier
                --player.character.walking_state = {walking = player.character.walking_state.walking, direction = storage.run_speed_modifiers[player_index]["belts-forward"]}
            end

            player.character_running_speed_modifier = running_speed_modifier - 1
        end
    end
end)