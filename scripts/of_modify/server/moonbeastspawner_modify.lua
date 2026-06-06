--[[
月台bug
我设想的是把月兽调整为不可溺水和无视海岸，然后更改生成方法，允许生成的坐标在海上，也不至于一个坐标点都没有，而崩溃
组件 MoonBeastSpawner:Start() 
月兽
    "moonhound",
    "moonpig",
]]
--月狗
AddPrefabPostInit("moonhound", function(inst)
    if inst.Physics then
        inst.Physics:ClearCollisionMask()                           --Physics物理 清除碰撞遮罩
        --与 地面、船、障碍物、小型障碍物、人物、boss碰撞，但不与海洋陆地界限碰撞
        inst.Physics:SetCollisionMask(COLLISION.GROUND, COLLISION.BOAT_LIMITS,COLLISION.OBSTACLES, COLLISION.SMALLOBSTACLES, COLLISION.CHARACTERS,COLLISION.GIANTS)
    end
    -- 防溺水
    if inst.components and inst.components.drownable then
        inst.components.drownable.enabled = false
    end 
end)
--月疯猪
AddPrefabPostInit("moonpig", function(inst)
    if inst.Physics then
        inst.Physics:ClearCollisionMask()                           --Physics物理 清除碰撞遮罩
        --与 地面、船、障碍物、小型障碍物、人物、boss碰撞，但不与海洋陆地界限碰撞
        inst.Physics:SetCollisionMask(COLLISION.GROUND, COLLISION.BOAT_LIMITS, COLLISION.OBSTACLES, COLLISION.SMALLOBSTACLES, COLLISION.CHARACTERS,COLLISION.GIANTS)
    end
    -- 防溺水
    if inst.components and inst.components.drownable then
        inst.components.drownable.enabled = false
    end 
end)

-- 检查是否符合的位置，并返回。 瞎改的
local function FindWalkable(position, start_angle, radius, attempts, check_los, ignore_walls)
    return FindValidPositionByFan(start_angle, radius, attempts,
            function(offset)
                local x = position.x + offset.x
                local y = position.y + offset.y
                local z = position.z + offset.z
                return (not check_los or 
                        TheWorld.Pathfinder:IsClear(
                            position.x, position.y, position.z,
                            x, y, z,
                            { ignorewalls = ignore_walls ~= false, ignorecreep = true, allowocean = allow_water }))
            end)
end



local MOONBEASTS = {
    "moonhound",
    "moonpig",
}

local function MorphMoonBeast(old, moonbase)
    if not (old.components.health ~= nil and old.components.health:IsDead()) then
        local x, y, z = old.Transform:GetWorldPosition()
        local rot = old.Transform:GetRotation()
        local oldprefab = old.prefab
        local newprefab = old:HasTag("werepig") and "moonpig" or "moonhound"
        local new = SpawnPrefab(newprefab)
        new.components.entitytracker:TrackEntity("moonbase", moonbase)
        new.Transform:SetPosition(x, y, z)
        new.Transform:SetRotation(rot)
        old:PushEvent("detachchild")
        new:PushEvent("moontransformed", { old = old })
        old.persists = false
        old.entity:Hide()
        old:DoTaskInTime(0, old.Remove)
    end
end

local function CheckCCToFree(oldcc, newcc, tofree, target)
    --On top of breaking petrification, moon charge
    --also overpowers some lesser disabling effects
    if target.components.health ~= nil and target.components.health:IsDead() then
        return
    elseif target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        newcc[target] = "sleeping"
    elseif target.components.freezable ~= nil and target.components.freezable:IsFrozen() and not target.components.freezable:IsThawing() then
        newcc[target] = "frozen"
    else
        return
    end

    if newcc[target] == oldcc[target] then
        table.insert(tofree, target)
    end
end

local SPAWN_CANT_TAGS = { "INLIMBO" }
local SPAWN_ONEOF_TAGS = { --[["moonbeast",]] "gargoyle", "werepig", "hound" }
local SPAWN_WALLS_ONEOF_TAGS = { "wall", "playerskeleton" }
local function DoSpawn(inst, self)
    local pos = inst:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.range, nil, SPAWN_CANT_TAGS, SPAWN_ONEOF_TAGS)
    local offscreenworkers, newcc, tofree
    if inst:IsAsleep() then
        offscreenworkers = {}
        if next(self.cc) ~= nil then
            self.cc = {}
        end
    else
        newcc = {}
        tofree = {}
    end

    for i, v in ipairs(ents) do
        if not (v:HasTag("moonbeast") or v:HasTag("gargoyle") or v:HasTag("clay")) then
            --claim regular werepigs and hounds
            if not v.sg:HasStateTag("busy") then
                MorphMoonBeast(v, inst)
            else
                if not v._morphmoonbeast then
                    v._morphmoonbeast = true
                    v:ListenForEvent("newstate", function()
                        if not v.sg:HasStateTag("busy") and v._morphmoonbeast == true then
                            v._morphmoonbeast = v:DoTaskInTime(0, MorphMoonBeast, inst)
                        end
                    end)
                end
                if offscreenworkers == nil then
                    CheckCCToFree(self.cc, newcc, tofree, v)
                end
            end
        elseif offscreenworkers == nil then
            CheckCCToFree(self.cc, newcc, tofree, v)
        elseif v.components.combat ~= nil and math.random() < .25 then
            --do random work when off-screen
            table.insert(offscreenworkers, v)
        end
    end

    if offscreenworkers == nil then
        for i = 1, math.min(#tofree, math.random(2)) do
            local ent = table.remove(tofree, math.random(#tofree))
            if ent.components.sleeper ~= nil and ent.components.sleeper:IsAsleep() then
                ent.components.sleeper:WakeUp()
            elseif ent.components.freezable ~= nil and ent.components.freezable:IsFrozen() and not ent.components.freezable:IsThawing() then
                ent.components.freezable:Thaw()
            end
            newcc[ent] = nil
        end
        self.cc = newcc
    elseif #offscreenworkers > 0 then
        local walls = TheSim:FindEntities(pos.x, pos.y, pos.z, 10, nil, nil, SPAWN_WALLS_ONEOF_TAGS)
        for i, v in ipairs(walls) do
            if math.random(self.maxspawns * 2 + 1) <= #offscreenworkers then
                if v.components.health ~= nil and not v.components.health:IsDead() then
                    --walls
                    v.components.health:Kill()
                elseif v.components.workable ~= nil and v.components.workable:CanBeWorked() then
                    --skellies
                    v.components.workable:Destroy(inst)
                end
            end
        end
        for i, v in ipairs(offscreenworkers) do
            inst.components.workable:WorkedBy(v, 1)
            if not self.started then
                return
            end
        end
    end

    local maxwavespawn = math.random(2)
    for i = #ents + 1, self.maxspawns do
        local offset
        if inst:IsAsleep() then
            local numattempts = 3
            local minrange = 3
            for attempt = 1, numattempts do
                offset = FindWalkable(pos, math.random() * 2 * PI, GetRandomMinMax(minrange, math.max(minrange, minrange + .9 * (self.range - minrange) * attempt / numattempts)), 16, false, true)
                local x1 = pos.x + offset.x
                local z1 = pos.z + offset.z
                local collisions = TheSim:FindEntities(x1, 0, z1, 4, nil, SPAWN_CANT_TAGS)
                for i, v in ipairs(collisions) do
                    local r = v:GetPhysicsRadius(0) + 1
                    if v:GetDistanceSqToPoint(x1, 0, z1) < r * r then
                        offset = nil
                        break
                    end
                end
                if offset ~= nil then
                    break
                end
            end
        else
            offset = FindWalkable(pos, math.random() * 2 * PI, self.range, 16, false, true)
        end
        if offset ~= nil then
            local creature = SpawnPrefab(MOONBEASTS[math.random(#MOONBEASTS)])
            creature.components.entitytracker:TrackEntity("moonbase", inst)
            creature.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
            creature:ForceFacePoint(pos)
            creature.components.spawnfader:FadeIn()
            if maxwavespawn > 1 then
                maxwavespawn = maxwavespawn - 1
            else
                return
            end
        end
    end
end

local GARGOYLE_TAGS = { "gargoyle" }


AddComponentPostInit("moonbeastspawner",function(self)
    self.Start = function(self)
        if not self.started then
            self.started = true

            local x, y, z = self.inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, self.range, GARGOYLE_TAGS)
            for i, v in ipairs(ents) do
                v:Reanimate(self.inst)
            end

            self.task = self.inst:DoPeriodicTask(self.period, DoSpawn, nil, self)
            self.cc = {}
        end
    end
end)