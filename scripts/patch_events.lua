local event_defs = {
    {chance = 0.01, name = "weatherchanged", eventF = "weatherchanged"},
    {chance = 0.01, name = "rockcircle", eventF = "rockcircle"},
    {chance = 0.03, name = "campfirecircle", eventF = "campfirecircle"},
    {chance = 0.09, name = "monstercircle", eventA = "monstercircle"},
    {chance = 0.04, name = "maxwellcircle", eventF = "maxwellcircle"},
    {chance = 0.09, name = "lightningTarget", eventA = "lightningTarget"},
    {chance = 0.05, name = "celestialfury", eventF = "celestialfury"},
    {chance = 0.04, name = "gunpowdercircle", eventF = "gunpowdercircle"},
    {chance = 0.1, name = "onAddHun", eventF = "onAddHun"},
    {chance = 0.1, name = "onAddSan", eventF = "onAddSan"},
    {chance = 0.1, name = "onAddHp", eventF = "onAddHp"},
    {chance = 0.012, name = "shadow_level", eventF = "shadow_level"},
    {chance = 0.09, name = "caveinobstacle", eventF = "caveinobstacle"},
    {chance = 0.09, name = "sporecloud", eventF = "sporecloud"},
    {chance = 0.11, name = "hedgehounds", eventF = "hedgehounds"},
    {chance = 0.08, name = "ghost_circle", eventF = "ghost_circle"},
    {chance = 0.1, name = "lethargy", eventF = "lethargy"},
    {chance = 0.04, name = "sanityempty", eventF = "sanityempty"},
    {chance = 0.01, name = "turkey", eventF = "turkey"},
    {chance = 0.05, name = "dropequip", eventF = "dropequip"},
    {chance = 0.04, name = "stashloot", eventF = "stashloot"},
    {chance = 0.02, name = "seasonchange", eventF = "seasonchange"},
    {chance = 0.03, name = "shadowthrall", eventA = "shadowthrall"},
    {chance = 0.07, name = "spawnwaves", eventF = "spawnwaves"},
    {chance = 0.09, name = "deciduous", eventF = "deciduous"},
    {chance = 0.05, name = "refusefish", eventF = "refusefish"},
    {chance = 0.08, name = "rabbiteater", eventF = "rabbiteater"},
    {chance = 0.04, name = "debrisitems", eventF = "debrisitems"},
    {chance = 0.01, name = "ascension", eventF = "ascension"},
    {chance = 0.05, name = "allfreezable", eventF = "allfreezable"},
    {chance = 0.05, name = "sand", eventF = "sand"},
    {chance = 0.01, name = "supermany", eventF = "supermany"},
    {chance = 0.02, name = "frograin", eventF = "frograin"},
    {chance = 0.05, name = "alterguardian_laser", eventF = "alterguardian_laser"},
    {chance = 0.07, name = "mushroombomb", eventA = "mushroombomb"},
    {chance = 0.03, name = "mushroom", eventF = "mushroom"},
    {chance = 0.04, name = "fossilspike", eventF = "fossilspike"},
    {chance = 0.01, name = "areaaware_abnormal", eventF = "areaaware_abnormal"},
    {chance = 0.075, name = "super_big", eventF = "super_big"},
    {chance = 0.09, name = "p_combat", eventF = "p_combat"},
    {chance = 0.03, name = "tentacle_kl", eventF = "tentacle_kl"},
    {chance = 0.13, name = "bat_eye", eventF = "bat_eye"},
    {chance = 0.075, name = "super_small", eventF = "super_small"},
    {chance = 0.09, name = "weed_imprison", eventF = "weed_imprison"},
    {chance = 0.035, name = "onefistsuperman", eventF = "onefistsuperman"},
    {chance = 0.095, name = "angel_blessing", eventF = "angel_blessing"},
    {chance = 0.035, name = "returnonattack", eventF = "returnonattack"},
    {chance = 0.015, name = "deltapenalty", eventF = "deltapenalty"},
    {chance = 0.025, name = "onlifeinjector", eventF = "onlifeinjector"},
    {chance = 0.045, name = "sanityaura", eventF = "sanityaura"},
    {chance = 0.025, name = "research", eventF = "research"},
    {chance = 0.05, name = "temperature", eventF = "temperature"},
    {chance = 0.075, name = "mindcontrol", eventF = "mindcontrol"},
    {chance = 0.009, name = "twinmanager", eventF = "twinmanager"},
    {chance = 0.01, name = "small_forest", eventF = "small_forest"},
    {chance = 0.008, name = "automatic_weapon", eventF = "automatic_weapon"},
    {chance = 0.011, name = "equip_recovery", eventF = "equip_recovery"},
    {chance = 0.005, name = "small_boss", eventF = "small_boss"},
    {chance = 0.045, name = "groundpounder", eventF = "groundpounder"},
    {chance = 0.055, name = "glacier", eventF = "glacier"},
    {chance = 0.045, name = "shadowmeteor", eventF = "shadowmeteor"},
    {chance = 0.037, name = "fire_ice_charge", eventF = "fire_ice_charge"},
    {chance = 0.085, name = "deer_ice_circle", eventF = "deer_ice_circle"},
    {chance = 0.085, name = "deer_fire_circle", eventF = "deer_fire_circle"},
    {chance = 0.009, name = "spawnendhounds", eventF = "spawnendhounds"},
    {chance = 0.013, name = "goldnuggets", eventF = "goldnuggets"},
    {chance = 0.033, name = "monkeyprojectile", eventF = "monkeyprojectile"},
    {chance = 0.07, name = "san_restore", eventF = "san_restore"},
    {chance = 0.06, name = "spat_bomb", eventF = "spat_bomb"},
    {chance = 0.06, name = "pocketwatch", eventF = "pocketwatch"},
    {chance = 0.07, name = "abigail", eventF = "abigail"},
    {chance = 0.09, name = "army", eventF = "army"},
    {chance = 0.05, name = "moisture", eventF = "moisture"},
    {chance = 0.03, name = "insanityrock", eventF = "insanityrock"},
    {chance = 0.04, name = "sanityrock", eventF = "sanityrock"},
    {chance = 0.055, name = "rapid", eventF = "rapid"},
    {chance = 0.06, name = "resurrection", eventF = "resurrection"},
    {chance = 0.03, name = "xixindafa", eventF = "xixindafa"},
    {chance = 0.04, name = "makeakrampusforplayer", eventF = "makeakrampusforplayer"},
    {chance = 0.07, name = "quantixianwokanqi", eventF = "quantixianwokanqi"},
    {chance = 0.08, name = "goldenstatue", eventF = "goldenstatue"},
    {chance = 0.03, name = "eyeplant", eventF = "eyeplant"},
    {chance = 0.04, name = "shield", eventF = "shield"},
    {chance = 0.01, name = "i_am_els", eventF = "i_am_els"},
    {chance = 0.037, name = "range_life_recovery", eventF = "range_life_recovery"},
    {chance = 0.007, name = "moonstorms", eventF = "moonstorms"},
    {chance = 0.007, name = "leif_anger", eventF = "leif_anger"},
    {chance = 0.003, name = "bosscompanion", eventF = "bosscompanion"},
    {chance = 0.01, name = "timebomb", eventF = "timebomb"},
    {chance = 0.035, name = "knockback", eventF = "knockback"},
    {chance = 0.02, name = "feetslipped", eventF = "feetslipped"},
    {chance = 0.028, name = "alterself", eventF = "alterself"},
    {chance = 0.014, name = "acidrain", eventF = "acidrain"},
    {chance = 0.023, name = "lunarhail", eventF = "lunarhail"},
    {chance = 0.02, name = "fog", eventF = "fog"},
    {chance = 0.042, name = "buff_playerabsorption_of", eventF = "buff_playerabsorption_of"},
    {chance = 0.042, name = "buff_attack_of", eventF = "buff_attack_of"},
    {chance = 0.02, name = "random_buff", eventF = "random_buff"},
    {chance = 0.001, name = "previous", eventF = "previousF", eventA = "previousA"},
    {chance = 0.005, name = "oceancolour", eventF = "oceancolour"},
    {chance = 0.025, name = "junkball", eventF = "junkball"},
    {chance = 0.02, name = "puppet", eventF = "puppet"},
    {chance = 0.09, name = "oceanice", eventF = "oceanice"},
    {chance = 0.01, name = "deathrattle_of", eventF = "deathrattle_of"},
    {chance = 0.01, name = "worm_attack", eventF = "worm_attack"},
    {chance = 0.01, name = "gelblobs", eventF = "gelblobs"},
    {chance = 0.01, name = "icewall", eventF = "icewall"},
    {chance = 0.01, name = "fruits", eventF = "fruits", parameter = "huge_fruits_loot"},
}

local error_prone_event_defs = {
    {chance = 0.01, name = "healthlink", eventF = "healthlink"},
    {chance = 0.09, name = "removeitems", eventF = "removeitems"},
    {chance = 0.03, name = "transformation", eventA = "transformation"},
    {chance = 0.005, name = "black_hole", eventF = "black_hole"},
    {chance = 0.015, name = "puppet_boss", eventF = "puppet_boss"},
    {chance = 0.005, name = "playerdata", eventF = "playerdata"},
}

local function get_huge_fruits()
    local ok, farm_plant_defs = pcall(require, "prefabs/farm_plant_defs")
    local huge_fruits_loot = {}
    if ok and farm_plant_defs and farm_plant_defs.PLANT_DEFS then
        for _, v in pairs(farm_plant_defs.PLANT_DEFS) do
            if v.product_oversized ~= nil then
                table.insert(huge_fruits_loot, v.prefab)
            end
        end
    end
    return huge_fruits_loot
end

local function make_event_key(eventF_name, eventA_name)
    return (eventF_name or "") .. "|" .. (eventA_name or "")
end

local function build_original_event_names(events)
    local ok, loots = pcall(require, "loots")
    if not ok or type(loots) ~= "table" or type(loots.events) ~= "table" then
        return {}
    end

    local function_names = {}
    for name, fn in pairs(events) do
        if type(fn) == "function" then
            function_names[fn] = name
        end
    end

    local names = {}
    for _, loot in ipairs(loots.events) do
        if type(loot) == "table" and loot.name ~= nil then
            local eventF_name = type(loot.eventF) == "function" and function_names[loot.eventF] or nil
            local eventA_name = type(loot.eventA) == "function" and function_names[loot.eventA] or nil
            if eventF_name ~= nil or eventA_name ~= nil then
                names[make_event_key(eventF_name, eventA_name)] = loot.name
            end
        end
    end

    return names
end

local function append_event_defs(patched_events, events, defs, original_names, huge_fruits_loot)
    for _, def in ipairs(defs) do
        local eventF = def.eventF and events[def.eventF] or nil
        local eventA = def.eventA and events[def.eventA] or nil
        if eventF ~= nil or eventA ~= nil then
            local event_name = original_names[make_event_key(def.eventF, def.eventA)] or def.name
            local event = {
                chance = def.chance,
                item = "fishingsurprised",
                name = event_name,
                eventF = eventF,
                eventA = eventA,
            }
            if def.parameter == "huge_fruits_loot" then
                huge_fruits_loot = huge_fruits_loot or get_huge_fruits()
                event.parameter = huge_fruits_loot
            end
            table.insert(patched_events, event)
        end
    end
    return huge_fruits_loot
end

local function BuildPatchedEvents(include_error_prone_events)
    local ok, events = pcall(require, "event_table")
    if not ok or type(events) ~= "table" then
        return nil
    end

    local patched_events = {}
    local original_names = build_original_event_names(events)
    local huge_fruits_loot = append_event_defs(patched_events, events, event_defs, original_names)
    if include_error_prone_events then
        append_event_defs(patched_events, events, error_prone_event_defs, original_names, huge_fruits_loot)
    end

    return patched_events
end

return {
    BuildPatchedEvents = BuildPatchedEvents,
    error_prone_event_defs = error_prone_event_defs,
}
