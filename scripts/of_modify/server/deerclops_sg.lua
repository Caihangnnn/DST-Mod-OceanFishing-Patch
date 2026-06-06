--------------------------------------------------------
-- 更改巨鹿攻击方法
-------------------------------------------------------
local AOE_RANGE_PADDING = 3
local AREAATTACK_MUST_TAGS = { "_combat" }
local AREA_EXCLUDE_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "deerclops" }
local ICESPAWNTIME = 0.25
local ICESPIKE_RADIUS = 1 --2/3 is more accurate, but 1 matches legacy

local function DoIceSpikeAOE(inst, target, x, z, data)
    inst.components.combat.ignorehitrange = true
    if inst:HasTag("companion") then AREA_EXCLUDE_TAGS = { "player", "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "deerclops", "abigail", "NOCLICK", "companion"} end
    local ents = TheSim:FindEntities(x, 0, z, ICESPIKE_RADIUS + AOE_RANGE_PADDING, AREAATTACK_MUST_TAGS, AREA_EXCLUDE_TAGS)
    for i, v in ipairs(ents) do
        if not data.targets[v] and v:IsValid() and not v:IsInLimbo() and
            not (v.components.health ~= nil and v.components.health:IsDead())
        then
            local range = ICESPIKE_RADIUS + v:GetPhysicsRadius(0)
            if v:GetDistanceSqToPoint(x, 0, z) < range * range and inst.components.combat:CanTarget(v) then
                local shouldknockback = inst.hasknockback and v.components.freezable ~= nil and v.components.freezable:IsFrozen()
                inst.components.combat:DoAttack(v)
                if shouldknockback then
                    v:PushEvent("knockback", { knocker = inst, radius = TUNING.DEERCLOPS_ATTACK_RANGE })
                end
                data.targets[v] = true
            end
        end
    end
    inst.components.combat.ignorehitrange = false

    --After the final spike, check if we hit anything at all
    if data.count > 1 then
        data.count = data.count - 1
    elseif next(data.targets) == nil then
        inst:PushEvent("onmissother", { target = target }) -- for ChaseAndAttack
    end
end

local function DoSpawnIceSpike(inst, target, rot, info, data, hitdelay, shouldsfx)
    local fx = table.remove(inst.icespike_pool)
    if fx == nil then
        fx = SpawnPrefab("deerclops_icespike_fx")
        fx:SetFXOwner(inst)
    end
    fx.Transform:SetPosition(info.x, 0, info.z)
    fx.Transform:SetRotation(rot)
    fx:RestartFX(info.big, info.variation)
    if shouldsfx then
        fx.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/ice_small")
    end
    if hitdelay < FRAMES then
        DoIceSpikeAOE(inst, target, info.x, info.z, data)
    else
        inst:DoTaskInTime(hitdelay, DoIceSpikeAOE, target, info.x, info.z, data)
    end
end
local function SpikeInfoNearToFar(a, b)
    return a.radius < b.radius
end
local MAX_ICESPIKE_SFX = 6
local function SpawnIceFx(inst, target)
    local data = { targets = {}, count = 0 }

    local AOEarc = 35

    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = inst.Transform:GetRotation()
    local spikeinfo = {}

    local theta = angle * DEGREES
    local cos_theta = math.cos(theta)
    local sin_theta = math.sin(theta)
    local num = 3
    data.count = data.count + num
    for i = 1, num do
        local radius = TUNING.DEERCLOPS_ATTACK_RANGE / num * i
        table.insert(spikeinfo,
        {
            x = x + radius * cos_theta,
            z = z - radius * sin_theta,
            radius = radius,
        })
    end

    num = math.random(12, 17)
    data.count = data.count + num
    for i = 1, num do
        local theta =  ( angle + math.random(AOEarc *2) - AOEarc ) * DEGREES
        local radius = TUNING.DEERCLOPS_ATTACK_RANGE * math.sqrt(math.random())
        table.insert(spikeinfo,
        {
            x = x + radius * math.cos(theta),
            z = z - radius * math.sin(theta),
            radius = radius,
        })
    end

    num = math.random(5, 8)
    data.count = data.count + num
    local newarc = 180 - AOEarc
    for i = 1, num do
        local theta =  ( angle -180 + math.random(newarc *2) - newarc ) * DEGREES
        local radius = 2 * math.random() +1
        table.insert(spikeinfo,
        {
            x = x + radius * math.cos(theta),
            z = z - radius * math.sin(theta),
            radius = radius,
        })
    end

    table.sort(spikeinfo, SpikeInfoNearToFar)

    num = data.count
    local nextbig = 1
    local delayvar = ICESPAWNTIME / (num - 1) * 0.3
    local cursfxinstance = 0
    for i = 1, num do
        local rnd = math.random()
        rnd = math.floor(rnd * rnd * #spikeinfo * 0.6) + 1
        local info = table.remove(spikeinfo, rnd)
        local delay =
            (i == 1 and 0) or
            (i == num and ICESPAWNTIME) or
            (i - 1) / (num - 1) * ICESPAWNTIME + delayvar * (math.random() - 0.5)
        local hitdelay = math.max(0, 3 * FRAMES - delay)
        local soundidx = math.floor((i - 1) / (num - 1) * (MAX_ICESPIKE_SFX - 1))
        local shouldsfx = soundidx >= cursfxinstance
        if shouldsfx then
            cursfxinstance = soundidx + 1
        end
        if math.floor(i * 4 / num) == nextbig then
            info.big = true
            info.variation = nextbig
            nextbig = nextbig + 1
        end
        inst:DoTaskInTime(delay, DoSpawnIceSpike, target, angle, info, data, hitdelay, shouldsfx)
    end
end



local function TryStagger(inst)
    if inst.sg.mem.noice == 1 and not inst.sg.mem.noeyeice and inst.components.burnable:IsBurning() then
        inst.sg:GoToState("struggle_pre")
        return true
    end
    inst.sg.mem.dostagger = nil
    return false
end
local deerclops_attack = State{
    name = "attack",
    tags = { "attack", "busy" },

    onenter = function(inst, target)
        inst.components.locomotor:StopMoving()
        inst.AnimState:PlayAnimation("atk")
        inst.SoundEmitter:PlaySound(inst.sounds.attack)
        -- StartAttackCooldown(inst) --开始攻击冷却
        if inst.sg.mem.combo ~= nil then
            inst.sg.mem.combo = inst.sg.mem.combo + 1
            if inst.sg.mem.combo == 1 then
                inst.components.combat:SetAttackPeriod(1)
            elseif inst.sg.mem.combo == 3 or math.random() < 0.5 then
                inst.sg.mem.combo = 0
                inst.components.combat:SetAttackPeriod(TUNING.MUTATED_DEERCLOPS_COMBO_ATTACK_PERIOD)
            end
        end
        inst.components.combat:StartAttack()

        if target ~= nil and target:IsValid() then
            inst:ForceFacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.target = target
        end
        inst.sg.statemem.original_target = target --remember for onmissother event
    end,

    onupdate = function(inst)
        if inst.sg.statemem.target ~= nil then
            if inst.sg.statemem.target:IsValid() then
                local rot = inst.Transform:GetRotation()
                local rot1 = inst:GetAngleToPoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                if DiffAngle(rot, rot1) < 45 then
                    inst.Transform:SetRotation(rot1)
                    return
                end
            end
            inst.sg.statemem.target = nil
        end
    end,

    timeline =
    {
        FrameEvent(16, function(inst)
            inst.sg.statemem.target = nil
        end),
        FrameEvent(31, function(inst)
            SpawnIceFx(inst, inst.sg.statemem.original_target) --生成冰川并造成伤害
        end),
        FrameEvent(34, function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.swipe)
            -- THE ATTACK DAMAGE COMES FROM THE DEERCLOPS SMALL ICE SPICE FX NOW.
            --inst.components.combat:DoAttack(inst.sg.statemem.target)
            if inst.bufferedaction ~= nil and inst.bufferedaction.action == ACTIONS.HAMMER then
                local target = inst.bufferedaction.target
                inst:ClearBufferedAction()
                if target ~= nil and
                    target:IsValid() and
                    target.components.workable ~= nil and
                    target.components.workable:CanBeWorked() and
                    target.components.workable:GetWorkAction() == ACTIONS.HAMMER
                then
                    target.components.workable:Destroy(inst)
                end
            end
            --摇晃所有相机
            ShakeAllCameras(CAMERASHAKE.FULL, .5, .025, 1.25, inst, SHAKE_DIST)
        end),
        FrameEvent(35, function(inst) inst.sg:RemoveStateTag("attack") end),
        FrameEvent(51, function(inst)
            if inst.sg.mem.dostagger and TryStagger(inst) then
                return
            end
            inst.sg:AddStateTag("caninterrupt")
        end),
        FrameEvent(56, function(inst) inst.sg:RemoveStateTag("busy") end),
    },

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
}
AddStategraphState("deerclops", deerclops_attack)