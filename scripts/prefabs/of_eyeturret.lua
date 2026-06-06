local eyeturretbrain = require "brains/eyeturretbrain"

local function RetargetFn(inst, target)
    return FindEntity(
        inst,
        20,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        { "_combat","_health" },
        { "player", "playerghost", "INLIMBO" , "abigail", "NOCLICK", "companion", "flying"}, --不能攻击 companion同伴
        {"monster", "prey", "insect", "hostile", "character", "animal", "wonkey","pirate"}
    )
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced() --四面类型

    inst.prefab = "eyeturret" --给定预制物

    inst:AddTag("eyeturret")
    inst:AddTag("companion")

    inst.AnimState:SetBank("eyeball_turret")
    inst.AnimState:SetBuild("eyeball_turret")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(10) --可以一拳打爆你的眼睛

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.EYETURRET_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.EYETURRET_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.EYETURRET_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(function(inst, target)
        return target ~= nil
            and target:IsValid()
            and target.components.health ~= nil
            and not target.components.health:IsDead()
            and inst:IsNear(target, TUNING.EYETURRET_RANGE + 3)
    end)
    inst.components.combat:SetShouldAggroFn(function(combat, target)
        if target:HasTag("player") then
            return TheNet:GetPVPEnabled()
        end
        return true
    end)

    -- 添加库存来装备武器 电光球效果
    inst:AddComponent("inventory")
    inst:DoTaskInTime(1,function(inst)
        if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
            local weapon = CreateEntity()
            --[[Non-networked entity]]
            weapon.entity:AddTransform()
            weapon:AddComponent("weapon")
            weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
            weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
            weapon.components.weapon:SetProjectile("eye_charge")
            weapon:AddComponent("inventoryitem")
            weapon.persists = false
            weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
            weapon:AddComponent("equippable")

            inst.components.inventory:Equip(weapon)
        end
    end)

    inst:ListenForEvent("attacked", function(inst, data)
        local attacker = data ~= nil and data.attacker or nil
        if attacker ~= nil and not PreventTargetingOnAttacked(inst, attacker, "player") then
            inst.components.combat:SetTarget(attacker)
            inst.components.combat:ShareTarget(attacker, 15, function(dude) return dude:HasTag("eyeturret") end, 10)
        end
    end)

    inst.persists = false --退出时不会保存

    inst:SetStateGraph("SGeyeturret_2")
    inst:SetBrain(eyeturretbrain)

	return inst
end


return Prefab("of_eyeturret",fn)