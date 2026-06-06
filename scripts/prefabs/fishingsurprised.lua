local shield_assets = {
    Asset("ANIM", "anim/shield.zip"),
}
local warrior_assets = {
    Asset("ANIM", "anim/Animations.zip"),
}

local function fn()
	local inst = CreateEntity() --创建实体
    inst.entity:AddTransform() --添加一个位置组件
    inst.entity:AddAnimState() --添加一个动画组件
    inst.entity:AddNetwork() --添加一个网络组件

    inst.AnimState:SetBank("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("unwrap")
    inst:AddTag("FX") --添加一个标签

    if not TheWorld.ismastersim then -- 判断是否是主服务器
        return inst
    end
	
	inst.persists = false   

	inst:DoTaskInTime(3,function(inst) inst:Remove() end)	
	return inst
end

local function ofn()
    local inst = CreateEntity() --创建实体
    inst.entity:AddTransform() --添加一个位置组件
    inst.entity:AddAnimState() --添加一个动画组件
    inst.entity:AddNetwork() --添加一个网络组件

    inst.AnimState:SetBank("reticule")
    inst.AnimState:SetBuild("reticule")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst:AddTag("FX") --添加一个标签
    inst:AddTag("NOCLICK")
    
    inst.persists = false   
    return inst
end

local function shieldfn()
    local inst = CreateEntity() --创建实体
    inst.entity:AddTransform() --添加一个位置组件
    inst.entity:AddAnimState() --添加一个动画组件
    inst.entity:AddNetwork() --添加一个网络组件

    inst:AddTag("FX") --添加一个标签

    inst.AnimState:SetBuild("shield")
    inst.AnimState:SetBank("shield")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    -- 动画结束就删除
    inst:ListenForEvent("animover",inst.Remove)
    
    inst.persists=false 

    return inst
end

local function recoveryfn()
    local inst = CreateEntity() --创建实体
    inst.entity:AddTransform() --添加一个位置组件
    inst.entity:AddAnimState() --添加一个动画组件
    inst.entity:AddNetwork() --添加一个网络组件

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")

    inst.AnimState:SetBank("sporecloud")
    inst.AnimState:SetBuild("sporecloud")
    inst.AnimState:PlayAnimation("sporecloud_pre")
    inst.AnimState:PushAnimation("sporecloud_loop", true)
    
    inst.persists=false 

    return inst
end

return Prefab("fishingsurprised",fn), -- 一个散花效果, 钓到事件就是它
    Prefab("of_reticule",ofn), --脚底有环 原来的没有网络变量导致无法显示
    Prefab("of_recovery",recoveryfn), --范围治疗fx
    Prefab("shield_fx",shieldfn, shield_assets) --护盾fx
