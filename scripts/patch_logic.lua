local patched_loots = nil

local function getglobal(name)
    local global = rawget(_G, "GLOBAL")
    if global ~= nil then
        local value = rawget(global, name)
        if value ~= nil then
            return value
        end
    end
    return rawget(_G, name)
end

local function SetLoots(loots)
    patched_loots = loots
end

local function get_tuning()
    return getglobal("TUNING") or {}
end

local function copy_table(t)
    local deepcopy_fn = getglobal("deepcopy")
    return deepcopy_fn and deepcopy_fn(t) or t
end

local function setoption(default, item)
    local i = item
    if default then
        for k, v in pairs(default) do
            i[k] = i[k] == nil and v or i[k]
        end
    end

    local tuning = get_tuning()
    if tuning.OFDATA and tuning.OFDATA.AVERAGE then
        i.chance = 1
    end
    return i
end

local function can_spawn_giant(fisher)
    local inspectProtect = getglobal("inspectProtect")
    if inspectProtect == nil then
        return true
    end

    local ok, result = pcall(inspectProtect, fisher)
    return ok and result
end

local function get_player_age(fisher)
    if fisher ~= nil and fisher.components ~= nil and fisher.components.age ~= nil then
        return fisher.components.age:GetAgeInDays() or 0
    end
    return 0
end

local function get_world_cycles()
    local TheWorld = getglobal("TheWorld")
    return TheWorld ~= nil and TheWorld.state ~= nil and TheWorld.state.cycles or 0
end

local function prefab_exists(prefab)
    if type(prefab) ~= "string" or prefab == "" then
        return false
    end

    local PrefabExists = getglobal("PrefabExists")
    if type(PrefabExists) == "function" then
        local ok, exists = pcall(PrefabExists, prefab)
        if ok then
            return exists == true
        end
    end

    local Prefabs = getglobal("Prefabs")
    if type(Prefabs) == "table" then
        return Prefabs[prefab] ~= nil
    end

    -- Fail open if the prefab registry is not available yet.
    return true
end

local function resolve_prefab_options(item)
    if type(item) == "string" then
        return prefab_exists(item) and item or nil
    end

    if type(item) ~= "table" then
        return nil
    end

    local valid_items = {}
    for _, prefab in ipairs(item) do
        if prefab_exists(prefab) then
            table.insert(valid_items, prefab)
        end
    end

    if #valid_items == 0 then
        return nil
    end
    return valid_items
end

local function sanitize_loot(loot)
    if type(loot) ~= "table" or loot.item == nil then
        return nil
    end

    local item = resolve_prefab_options(loot.item)
    if item == nil then
        return nil
    end

    local sanitized = copy_table(loot)
    sanitized.item = item
    return sanitized
end

local function recombination(loots, t, only, fisher, ban)
    local probably_loot = {}
    local loots_ = only and {} or copy_table(loots)
    local tuning = get_tuning()
    local extras = only and {} or copy_table(tuning.OCEANFISHINGROD_R)
    local specials = t and copy_table(t) or {}

    for name, child in pairs(loots_ and type(loots_) == "table" and loots_ or {}) do
        if not (ban and name == ban) then
            for _, v in ipairs(child and type(child) == "table" and child or {}) do
                if name == "giants" then
                    if not can_spawn_giant(fisher) then
                        break
                    end
                    v.chance = v.chance * math.min(get_player_age(fisher) / 22 + 1, 5)
                elseif name == "builds" then
                    v.chance = v.chance * math.min(get_world_cycles() / 40 + 1, 5)
                end
                local loot = sanitize_loot(v)
                if loot ~= nil then
                    table.insert(probably_loot, setoption(child.default, loot))
                end
            end
        end
    end

    for _, extra in pairs(extras and type(extras) == "table" and extras or {}) do
        for _, v in ipairs(extra and type(extra) == "table" and extra or {}) do
            local loot = sanitize_loot(v)
            if loot ~= nil then
                table.insert(probably_loot, setoption(extra.default, loot))
            end
        end
    end

    for _, special in pairs(specials and type(specials) == "table" and specials or {}) do
        for _, v in ipairs(special and type(special) == "table" and special or {}) do
            local loot = sanitize_loot(v)
            if loot ~= nil then
                table.insert(probably_loot, setoption(special.default, loot))
            end
        end
    end
    return probably_loot
end

local function SpawnLoot(loot, fisher, target, inst)
    local SpawnPrefab = getglobal("SpawnPrefab")
    if SpawnPrefab == nil or loot == nil or loot.item == nil then
        return
    end

    local prefab = type(loot.item) == "table" and loot.item[math.random(#loot.item)] or loot.item
    local tuning = get_tuning()
    if tuning.of_only and tuning.of_only[prefab] and tuning.of_only[prefab][1] >= tuning.of_only[prefab][2] then
        prefab = "goldnugget"
        loot = {}
    end

    if loot.pack and math.random() < (loot.pack_chance or .65) then
        local STRINGS = getglobal("STRINGS") or { NAMES = {} }
        local bagname = ((STRINGS.NAMES[string.upper(prefab)] or "未知") .. (STRINGS.NAMES.BAG or "包裹"))
        local name = loot.announce and bagname or loot.name
        loot = {
            name = name,
            eventF = function(i, f, t, p) i:SetData(p) end,
            parameter = {item = prefab, name = bagname},
        }
        prefab = "bag"
    end

    local item = SpawnPrefab(prefab)
    if item == nil then
        return
    end

    local SetSpellCB = getglobal("SetSpellCB")
    if SetSpellCB then
        SetSpellCB(item, fisher)
    end

    local Brain = false
    if item.brainfn then
        item.sleepstatepending = true
        Brain = true
        item:StopBrain("钓起中")
    end

    if loot.announce or loot.name then
        local TheNet = getglobal("TheNet")
        if TheNet ~= nil then
            local fisher_name = fisher and fisher:GetDisplayName() or "???"
            local item_name = loot.name or item:GetDisplayName() or item.prefab or prefab
            TheNet:Announce(fisher_name .. " 钓到了 " .. item_name)
        end
    end

    local COLLISION = getglobal("COLLISION")
    local PROJECTILE_COLLISION_MASK = COLLISION.GROUND
    local SWIMMING_COLLISION_MASK = COLLISION.GROUND + COLLISION.LAND_OCEAN_LIMITS + COLLISION.OBSTACLES + COLLISION.SMALLOBSTACLES

    local CUSTOMARY = nil
    local Mass = nil
    local NoPhysics = false
    local IsActive = true
    local Fn_hit = nil
    local Fn_launch = nil
    local hatred = false

    if item.Physics then
        IsActive = item.Physics:IsActive()
        Mass = item.Physics:GetMass()
        item.Physics:SetMass(loot.build and 0 or 1)
        CUSTOMARY = item.Physics:GetCollisionMask()
        item.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)
        if IsActive == false then
            item.Physics:SetActive(true)
        end
    else
        NoPhysics = true
        local MakeInventoryPhysics = getglobal("MakeInventoryPhysics")
        if MakeInventoryPhysics then
            MakeInventoryPhysics(item)
        end
        item.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)
    end

    local function OnProjectileLand(item_)
        if Brain then
            item_:RestartBrain("钓起中")
        end
        item_:DoTaskInTime(Brain and 0 or 2, function(landed_item)
            if landed_item == nil or not landed_item:IsValid() then return end
            landed_item.Physics:SetCollisionMask(CUSTOMARY or SWIMMING_COLLISION_MASK)
            landed_item.Physics:SetMass(Mass or 0)
            if IsActive == false then
                landed_item.Physics:SetActive(false)
            end
        end)
        if Fn_hit == nil then
            item_:RemoveComponent("complexprojectile")
        else
            item_.components.complexprojectile:SetOnHit(Fn_hit)
            item_.components.complexprojectile:SetOnLaunch(Fn_launch or nil)
        end
        if NoPhysics then
            local RemovePhysicsColliders = getglobal("RemovePhysicsColliders")
            if RemovePhysicsColliders then
                RemovePhysicsColliders(item_)
            end
        end
        if item_.components.drownable then
            item_.components.drownable.enabled = true
        end
        if item_.components.knownlocations then
            item_.components.knownlocations:RememberLocation("spawnpoint", item_:GetPosition(), false)
        end
        if item_.components.sleeper then
            item_.components.sleeper:WakeUp()
        end
        if item_.components.combat and hatred then
            item_.components.combat:SuggestTarget(fisher)
            item_:StartUpdatingComponent(item_.components.combat)
        end
        if loot.eventA ~= nil and type(loot.eventA) == "function" then
            loot.eventA(item_, fisher, target, loot.parameter)
        end
    end

    if item.components.complexprojectile == nil then
        item:AddComponent("complexprojectile")
    else
        Fn_hit = item.components.complexprojectile.onhitfn
        Fn_launch = item.components.complexprojectile.onlaunchfn
    end
    item.components.complexprojectile:SetOnHit(OnProjectileLand)
    item.components.complexprojectile:SetOnLaunch(nil)

    if item.components.drownable then
        item.components.drownable.enabled = false
    end
    if item.components.sleeper and not loot.sleeper then
        item.components.sleeper:GoToSleep(0)
    end
    if item.components.knownlocations and fisher ~= nil then
        item.components.knownlocations:RememberLocation("spawnpoint", fisher:GetPosition(), false)
    end
    if item.components.combat and not loot.hatred then
        hatred = true
        item:StopUpdatingComponent(item.components.combat)
    end

    if tuning.OFDATA and tuning.OFDATA.DURABLE and tuning.OFDATA.DURABLE > 0 and math.random() > tuning.OFDATA.DURABLE then
        if item.components.fueled then item.components.fueled:SetPercent(math.random()) end
        if item.components.finiteuses then item.components.finiteuses:SetPercent(math.random()) end
        if item.components.perishable then item.components.perishable:SetPercent(math.random()) end
    end

    if loot.eventF ~= nil and type(loot.eventF) == "function" then
        loot.eventF(item, fisher, target, loot.parameter)
    end

    if prefab == "fishingsurprised" and (loot.eventF or loot.eventA) and fisher ~= nil and fisher.RecordEvents_of then
        fisher:RecordEvents_of(loot)
    end

    if inst.components.oceanfishingrod == nil or target == nil or fisher == nil then
        return
    end
    local targetpos = inst.components.oceanfishingrod:CalcCatchDest(target:GetPosition(), fisher:GetPosition(), 4)
    local startpos = target:GetPosition()
    inst.components.oceanfishingrod:_LaunchFishProjectile(item, startpos, targetpos)
end

local function Reward(inst, fisher, target, ban)
    local loots = patched_loots or getglobal("OF_HARVEST") or require("loots")
    local success, especiallys = pcall(require, "especiallys")
    if not success then especiallys = {} end

    local TheWorld = getglobal("TheWorld")
    local isfullmoon = TheWorld ~= nil and TheWorld.state ~= nil and TheWorld.state.isfullmoon
    local isnewmoon = TheWorld ~= nil and TheWorld.state ~= nil and TheWorld.state.isnewmoon
    local WeightRandom = getglobal("WeightRandom")
    if WeightRandom == nil then
        return
    end

    local function pick_weighted(loot_list)
        if type(loot_list) ~= "table" or #loot_list <= 0 then
            return nil
        end
        return WeightRandom(loot_list)
    end

    local function get_loot(t, only)
        return recombination(loots, t, only, fisher, ban)
    end

    local loot = nil
    if isfullmoon then
        loot = pick_weighted(get_loot({especiallys.fullmoon}, true))
    elseif isnewmoon then
        loot = pick_weighted(get_loot({especiallys.newmoon}, true))
    end

    if not loot then
        loot = pick_weighted(get_loot())
    end

    if loot and loot.item then
        SpawnLoot(loot, fisher, target, inst)
    end
end

return {
    Reward = Reward,
    SetLoots = SetLoots,
}
