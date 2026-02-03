local challenges = {}

table.insert(challenges, function()
    if storage.dosh_mode then
        game.print("You don't seem to think as quickly as you used to. (Research multiplier increased by 1).")

        game.difficulty_settings.technology_price_multiplier = game.difficulty_settings.technology_price_multiplier + 1
    else
        game.print("You don't seem to think as quickly as you used to. (Research multiplier increased by 0.1).")

        game.difficulty_settings.technology_price_multiplier = game.difficulty_settings.technology_price_multiplier + 0.1
    end
end)

table.insert(challenges, function()
    game.print("You're so forgetful... what were you doing again? (Lost all research progress on current research).")

    if game.forces.player.current_research ~= nil then
        -- Take at most 500 science packs at once
        if game.forces.player.current_research.research_unit_count * game.forces.player.research_progress <= 500 then
            game.forces.player.research_progress = 0
        else
            game.print("Oh... that would be a lot of research. I'll be nice and just take away 500 science cylces.")
            game.forces.player.research_progress = game.forces.player.research_progress - 500 / game.forces.player.current_research.research_unit_count
        end
    else
        game.print("Yo, you weren't researching anything? Uncool.")
    end
end)

table.insert(challenges, function()
    -- This challenge is too easy for Dosh
    if storage.dosh_mode then
        return false
    end

    game.print("The rotation of nauvis is getting slower. (Day-night cycle lengthened by 5 minutes, also set time to day because day is the best!)")

    game.surfaces.nauvis.ticks_per_day = game.surfaces.nauvis.ticks_per_day + 5 * 60 * 60
    game.surfaces.nauvis.daytime = game.surfaces.nauvis.dawn
    storage.day_offset = game.tick
end)

table.insert(challenges, function()
    game.print("Wait, where was everything? (Un-map all chunks; they stay generated even if you can't see them).")

    local chunks = game.surfaces.nauvis.get_chunks()
    for chunk in chunks do
        game.forces.player.unchart_chunk({chunk.x, chunk.y}, game.surfaces.nauvis)
    end
end)

table.insert(challenges, function()
    if not settings.startup["fun_mode_permanence"].value then
        return false
    end

    game.print("You've opted for a little more stability in your life. (10% of the things you've placed down are now permanent).")

    for _, entity in pairs(game.surfaces.nauvis.find_entities_filtered({force = game.forces.player})) do
        -- Have to make sure it's not a character
        if (math.random(1, 10) == 1) and entity.type ~= "character" then
            table.insert(storage.buildings_currently_permanent, entity)
            entity.minable = false
            entity.destructible = false
        end
    end
end)

table.insert(challenges, function()
    game.print("The biters seem to be gathering in larger waves than before. (Attack cost modifier reduced).")

    if storage.dosh_mode then
        game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.7 * game.map_settings.pollution.enemy_attack_pollution_consumption_modifier
    else
        game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.9 * game.map_settings.pollution.enemy_attack_pollution_consumption_modifier
    end
end)

table.insert(challenges, function()
    game.print("A transport belt conducts a small act of protest in search of a living wage. (A random transport belt in your factory was rotated).")

    if #storage.all_belts == 0 then
        game.print("You... didn't have any transport belts? How?!")
    else
        local belt_ind_to_rotate = math.random(1, #storage.all_belts)
        if storage.all_belts[belt_ind_to_rotate].valid then
            --if settings.startup["fun_mode_beta"].value then
                if game.forces.player.technologies["belt-ping"].researched then
                    game.print("[gps=" .. storage.all_belts[belt_ind_to_rotate].position.x .. "," .. storage.all_belts[belt_ind_to_rotate].position.y .. "]")
                end
            --end

            storage.all_belts[belt_ind_to_rotate].rotate()
        end
    end
end)

-- Increased time from original wheel of challenges to account for other pains
script.on_nth_tick(13 * 60 * 60, function ()
    if math.random(1, 100) <= storage.chance_to_do_challenge then
        while true do
            storage.chance_to_do_challenge = 0

            for _, player in pairs(game.players) do
                -- Make sure they aren't in editor mode or otherwise something wonky's going on
                if player.character ~= nil and player.character.valid then
                    player.create_local_flying_text({text = "Challenge time!", position = {player.character.position.x, player.character.position.y}})
                end
            end

            -- If false returned, then the challenge failed and try another one
            if challenges[math.random(#challenges)]() then
                break
            end
        end
    else
        storage.chance_to_do_challenge = storage.chance_to_do_challenge + 20
    end
end)

return challenges