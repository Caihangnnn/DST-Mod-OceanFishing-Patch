local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "swap_purplestaff")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function usable(inst) -- 冷却结束
    if not inst:HasTag("clearing_staff_of_cooling") then
        inst:AddTag("clearing_staff_of_cooling")
    end
end
local function unavailable(inst) -- 冷却开始
    if inst:HasTag("clearing_staff_of_cooling") then
        inst:RemoveTag("clearing_staff_of_cooling")
    end
end
local NO_REMOVE = {"player","INLIMBO","irreplaceable","shadowcreature","farm_plant","_combat", "donotautopick",
                 "locomotor","boat","FX","NOBLOCK","NOCLICK","multiplayer_portal","strong_of","DECOR" }
local function FireThrowSpellFn(inst, doer, pos)
    if not inst:HasTag("clearing_staff_of_cooling") then doer.components.talker:Say("正在冷却中", 2) return end
    local x, y, z = pos:Get()
    local ents = TheSim:FindEntities(x,y,z,4,nil,NO_REMOVE)
    if ents ~= nil then
        for k,v in pairs(ents) do
            v:Remove()
        end
    end
    --开始冷却
    inst.components.rechargeable:SetCharge(0)
    return true
end

local function fn()
    local inst = CreateEntity()--生成实体

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    --添加[物品]类型的物理学
    MakeInventoryPhysics(inst)

    --放在地上的动画集
    inst.AnimState:SetBuild("staffs")
    inst.AnimState:SetBank("staffs")
    inst.AnimState:PlayAnimation("purplestaff")

    inst:AddTag("clearing_staff_of_cooling")
    inst:AddTag("strong_of") -- 珍贵物品

    -- 主客都有的组件  aoe选择器  客户端显示出的标记物
    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = function() return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0.001, 0)) end
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true

    --漂浮
    local floater_swap_data =
    {
        sym_build = "swap_staffs",
        sym_name = "swap_purplestaff",
        bank = "staffs",
        anim = "purplestaff"
    }
    MakeInventoryFloatable(inst, "med", 0.1, {0.9, 0.4, 0.9}, true, -13, floater_swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --可检查组件
    inst:AddComponent("inspectable")
    
    inst:AddComponent("named")
    inst:AddComponent("lootdropper")

    --物品栏组件，可以放到物品栏里
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "telestaff" --图像,像素大小64*64

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    -- 添加冷却组件
    inst:AddComponent("rechargeable") 
    inst.components.rechargeable:SetOnDischargedFn(unavailable) 
    inst.components.rechargeable:SetOnChargedFn(usable)
    inst.components.rechargeable:SetChargeTime(5)

    inst:AddComponent("aoespell") --aoe咒语 组件
    inst.components.aoespell:SetSpellFn(FireThrowSpellFn)

    MakeHauntableLaunch(inst)


    return inst
end

return Prefab("clearing_staff_of", fn)