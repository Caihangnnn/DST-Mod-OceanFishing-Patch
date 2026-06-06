local function Detonate(inst) --引爆
    inst.components.inventoryitem:RemoveFromOwner(true) --从所有者中删除
    if inst.holder then
        if inst.holder.components.health and not inst.holder.components.health:IsDead() then
            inst.holder.components.health:DoDelta(-70) --炸70hp 无视护甲的
        end
        inst.holder = nil
    end
    inst.SoundEmitter:PlaySound("rifts/lunarthrall_bomb/explode")
    inst:Remove()
end

local function OnPutInInventory(inst, owner) --放入库存时
    if inst.holder ~= owner then
        inst.holder = owner
        inst.components.rechargeable:Discharge(30)
    end
end
local function OnDropped(inst) --被丢下时
    if inst.holder then
        local inventory = inst.holder.components.inventory --原持有者 捡回去
        if #inventory.itemslots < inventory.maxslots then
            inventory:GiveItem(inst)
        else
            for k, v in pairs(inventory.itemslots) do
                if v and not v:HasTag("黏人炸弹") and not v.components.inventoryitem.canonlygoinpocket then
                    --丢下第k个物品
                    inventory:DropItem(inventory.itemslots[k], true, true)
                    inventory:GiveItem(inst)
                    break
                end
            end
        end
        --超库存上限，就丢地上吧。只有不是其他人捡到，还是会炸到持有者
        return
    end
    -- 理论上不应该执行到这里。
    -- 但是还要引爆吧
    inst:Detonate()
end

local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bomb_lunarplant")
    inst.AnimState:SetBuild("bomb_lunarplant")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideMultColour(1, 0, 0, 1) --变为红色吧

    inst:AddTag("nosteal") --不能被偷
    inst:AddTag("黏人炸弹") --不能被偷

    MakeInventoryPhysics(inst)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end    
    inst:AddComponent("inspectable")

    inst:AddComponent("rechargeable") --冷却组件
    inst.components.rechargeable:SetOnChargedFn(function(inst) inst:Detonate() end)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nocontainer = true --只能放口袋，不可以放到容器中
    inst.components.inventoryitem:ChangeImageName("bomb_lunarplant") --库存显示图像

    inst:ListenForEvent("onputininventory", OnPutInInventory) --放入背包时
    inst:ListenForEvent("ondropped", OnDropped) --被丢弃时

    inst.Detonate = Detonate

    inst.persists = false --退出时不会保存

	return inst
end


return Prefab("timebomb",fn)