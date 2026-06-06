local function setdata(inst, data)
    inst.saved = data.item
    inst.components.named:SetName(data.name)
end

local function arrange(inst, pt, deployer)
    if inst and inst.saved then
        local item = SpawnPrefab(inst.saved)
        if item then
            item.Transform:SetPosition(pt:Get())
        end
    end
    inst:Remove()
end

local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gift")
    inst.AnimState:SetBuild("gift")
    inst.AnimState:PlayAnimation("idle_large1")

    MakeInventoryPhysics(inst)
    inst.entity:SetPristine()

    inst.saved = "" --要生成对象的数据

    if not TheWorld.ismastersim then
        return inst
    end    
    inst:AddComponent("inspectable")

    inst:AddComponent("deployable") --可栽种的
    inst.components.deployable.ondeploy = arrange
    -- inst.components.deployable:SetUseGridPlacer(true)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem:ChangeImageName("gift_large1") --库存显示图像

    inst:AddComponent("named")

    inst.SetData = setdata

    inst.OnLoad = function(inst, data) if data ~= nil and data.saved then inst.saved = data.saved end end
    inst.OnSave = function(inst, data) data.saved = inst.saved end
	return inst
end

return Prefab("bag",fn),
    MakePlacer("bag_placer", "gift", "gift", "idle_large1")