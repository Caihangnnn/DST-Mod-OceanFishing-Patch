----------------------------------------------------------------------------------
-- 制作buff实体 
-------------------------------------------------
-- 固若金汤
local function playerabsorption_attach(inst, target)
    if target.components.health ~= nil then
        target.components.health.externalabsorbmodifiers:SetModifier(inst, TUNING.BUFF_PLAYERABSORPTION_MODIFIER)
    end
end

local function playerabsorption_detach(inst, target)
    if target.components.health ~= nil then
        target.components.health.externalabsorbmodifiers:RemoveModifier(inst)
    end
end
-------------------------------------------------
-- 侵掠如火
local function attack_attach(inst, target)
    if target.components.combat ~= nil then
        target.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.BUFF_ATTACK_MULTIPLIER)
    end
end

local function attack_detach(inst, target)
    if target.components.combat ~= nil then
        target.components.combat.externaldamagemultipliers:RemoveModifier(inst)
    end
end
-------------------------------------------------
-- 流血
local function hp_OnTick(inst, target)
    if target.components.health ~= nil and
        not target.components.health:IsDead() and
        not target:HasTag("playerghost") then
        target.components.health:DoDelta(-5, nil, "OF_BLEED")
    else
        inst.components.debuff:Stop()
    end
end

local function hp_attach(inst, target)
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, hp_OnTick, nil, target)
end
local function hp_extended(inst, target)
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, hp_OnTick, nil, target)
end
-------------------------------------------------
-- 降智
local function san_OnTick(inst, target)
    if target.components.sanity ~= nil and
        not target:HasTag("playerghost") then
        target.components.sanity:DoDelta(-5)
    else
        inst.components.debuff:Stop()
    end
end

local function san_attach(inst, target)
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, san_OnTick, nil, target)
end
local function san_extended(inst, target)
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, san_OnTick, nil, target)
end
-------------------------------------------------
-- 啜食
local function hun_OnTick(inst, target)
    if target.components.hunger ~= nil and
        not target:HasTag("playerghost") then
        target.components.hunger:DoDelta(-5)
    else
        inst.components.debuff:Stop()
    end
end

local function hun_attach(inst, target)
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, hun_OnTick, nil, target)
end
local function hun_extended(inst, target)
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, hun_OnTick, nil, target)
end
-------------------------------------------------
-- 禁渔期
local function refusefish_attach(inst, target)
    target:AddTag("refusefish")
end

local function refusefish_detach(inst, target)
    target:RemoveTag("refusefish")
end
-------------------------------------------------
-- 脚滑
local function feetslipped_attach(inst, target)
    if target.feetslipped_tsak == nil then
        target.feetslipped_tsak = target:DoPeriodicTask(1.5, function(p)
            if p.Physics:GetMotorSpeed() > 0 then
                p:PushEvent("feetslipped") --跳转到脚滑状态Sg
            end
        end)
    end
end

local function feetslipped_detach(inst, target)
    if target.feetslipped_tsak then
        target.feetslipped_tsak:Cancel()
        target.feetslipped_tsak = nil
    end
end
-------------------------------------------------
-- 变身术
local function alterself_attach(inst, target)
    inst.of_clothing = target.components.skinner:GetClothing()
    local build = {"wilson","wortox","wendy","willow","wickerbottom","waxwell","webber","wes","winona","woodie","wormwood","wurt","warly","wathgrithr","wolfgang","wx78","walter","wanda"}
    local b = target.prefab
    while b == target.prefab do
        b = build[math.random(#build)]
    end
    target.AnimState:SetBuild(b)
end

local function alterself_detach(inst, target)
    target.AnimState:SetBuild(target.prefab)
    if inst.of_clothing then
        local skinner = target.components.skinner
        skinner:SetClothing(inst.of_clothing.body)
        skinner:SetClothing(inst.of_clothing.hand)
        skinner:SetClothing(inst.of_clothing.legs)
        skinner:SetClothing(inst.of_clothing.feet)
    end
end
-------------------------------------------------
-- 变大
local function big_attach(inst, target)
    target.Transform:SetScale(2.5,2.5,2.5)
    SpawnPrefab("collapse_small").Transform:SetPosition(target:GetPosition():Get())
end

local function big_detach(inst, target)
    target.Transform:SetScale(1,1,1)
end
-------------------------------------------------
-- 变小
local function small_attach(inst, target)
    target.Transform:SetScale(0.25,0.25,0.25)
    SpawnPrefab("collapse_small").Transform:SetPosition(target:GetPosition():Get())
end

local function small_detach(inst, target)
    target.Transform:SetScale(1,1,1)
end
-------------------------------------------------
-- 疾如风
local function rapid_attach(inst, target)
    target.components.locomotor.old_walkspeed_of = target.components.locomotor.old_walkspeed_of or target.components.locomotor.runspeed
    target.components.locomotor.runspeed = target.components.locomotor.old_walkspeed_of * 5.5
end

local function rapid_detach(inst, target)
    target.components.locomotor.runspeed = target.components.locomotor.old_walkspeed_of
    target.components.locomotor.old_walkspeed_of = nil
end
-------------------------------------------------
-- 亡语 效果 击杀生物掉落其他生物
local function onDeathrattle(inst, data)
    local loots = require("loots")
    if loots and loots.organisms then
        local loot = WeightRandom(loots.organisms)
        local prefab = type(loot.item) == "table" and loot.item[math.random(#loot.item)] or loot.item
        local item = prefab and SpawnPrefab(prefab) or nil
        if item and item.components.combat then
            item.components.combat:SuggestTarget(inst)
            item.Transform:SetPosition(data.victim:GetPosition():Get()) 
        end
    end
end

local function deathrattle_attach(inst, target)
    target:ListenForEvent("killed", onDeathrattle)
end
local function deathrattle_detach(inst, target)
    target:RemoveEventCallback("killed", onDeathrattle)
end
-------------------------------------------------
local function OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end
local function MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration, priority, prefabs)
    local function OnAttached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0) --in case of loading
        inst:ListenForEvent("death", function()
            inst.components.debuff:Stop()
        end, target)

        target:PushEvent("foodbuffattached", { buff = "ANNOUNCE_ATTACH_BUFF_"..string.upper(name), priority = priority })
        if onattachedfn ~= nil then
            onattachedfn(inst, target)
        end
    end
    local function OnExtended(inst, target)
        inst.components.timer:StopTimer("buffover")
        inst.components.timer:StartTimer("buffover", duration)

        target:PushEvent("foodbuffattached", { buff = "ANNOUNCE_ATTACH_BUFF_"..string.upper(name), priority = priority })
        if onextendedfn ~= nil then
            onextendedfn(inst, target)
        end
    end

    local function OnDetached(inst, target)
        if ondetachedfn ~= nil then
            ondetachedfn(inst, target)
        end

        target:PushEvent("foodbuffdetached", { buff = "ANNOUNCE_DETACH_BUFF_"..string.upper(name), priority = priority })
        inst:Remove()
    end
    local function absorb_fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()

        --[[Non-networked entity]]
        --inst.entity:SetCanSleep(false)
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff.keepondespawn = true

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("buffover", duration)
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end
    return Prefab("buff_"..name, absorb_fn, nil, prefabs)
end

return MakeBuff("attack_of", attack_attach, nil, attack_detach, TUNING.BUFF_ATTACK_DURATION, 1),
    MakeBuff("playerabsorption_of", playerabsorption_attach, nil, playerabsorption_detach, TUNING.BUFF_PLAYERABSORPTION_DURATION, 1),
    MakeBuff("bleed_of", hp_attach, hp_extended, nil, 10, 1),
    MakeBuff("reducesan_of", san_attach, san_extended, nil, 10, 1),
    MakeBuff("sipping_of", hun_attach, hun_extended, nil, 10, 1),
    MakeBuff("refusefish_of", refusefish_attach, nil, refusefish_detach, 60, 1),
    MakeBuff("feetslipped_of", feetslipped_attach, nil, feetslipped_detach, 30, 1),
    MakeBuff("alterself_of", alterself_attach, nil, alterself_detach, 30, 1),
    MakeBuff("rapid_of", rapid_attach, nil, rapid_detach, 30, 1),
    MakeBuff("big_of", big_attach, nil, big_detach, 60, 1),
    MakeBuff("small_of", small_attach, nil, small_detach, 60, 1),
    MakeBuff("deathrattle_of", deathrattle_attach, nil, deathrattle_detach, 60, 1)
