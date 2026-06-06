local ATRIUM_ARENA_SIZE = 14.55

local function IsObjectInAtriumArena(inst, obj) -- 织影者是否在中庭
    if obj == nil then
        return false
    end
    local obj_x, _, obj_z = obj.Transform:GetWorldPosition()
    local inst_x, _, inst_z = inst.Transform:GetWorldPosition()
    -- print(obj_x,obj_z ,inst_x,inst_z )
    return math.abs(obj_x - inst_x) < ATRIUM_ARENA_SIZE
        and math.abs(obj_z - inst_z) < ATRIUM_ARENA_SIZE
end
--在接受心脏时
local function TrackStalker(inst, stalker) -- 设置追踪对象
    local old = inst.components.entitytracker:GetEntity("stalker")
    if old ~= stalker then
        if old ~= nil then
            inst.components.entitytracker:ForgetEntity("stalker") -- 移除原来的
            inst:RemoveEventCallback("onremove", inst._onstalkerdeath, old)
            inst:RemoveEventCallback("death", inst._onstalkerdeath, old)
        end
        inst.components.entitytracker:TrackEntity("stalker", stalker)
        if stalker.components.health ~= nil and not stalker.components.health:IsDead() then
            inst:ListenForEvent("onremove", inst._onstalkerdeath, stalker)
            inst:ListenForEvent("death", inst._onstalkerdeath, stalker) 
            -- inst:AddTag("intense") 
        else
            inst:Remove()
        end
    end
end
-- ListenForEvent("resetruins") -- 重置废墟 远古遗迹用
local function IsWaitingForStalker(inst) --钓起后，还再复活骨架时,检查用滴
    return false
end

local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()

    inst:AddTag("FX")
    inst:AddTag("stargate")
    inst:AddTag("intense") --用于判断是否在中庭附近

    if not TheWorld.ismastersim then
        return inst
    end    

    inst:AddComponent("entitytracker") --实体跟踪器

    inst.IsObjectInAtriumArena = IsObjectInAtriumArena --用于判断是否在中庭附近
    inst.TrackStalker = TrackStalker
    inst.IsWaitingForStalker = IsWaitingForStalker

    inst._onstalkerdeath = function(stalker) -- 跟踪者死亡或移除
        stalker.persists = true --织影者判断掉落物时要用
        inst:Remove()
    end

    inst.persists = false

	return inst
end


return Prefab("artificial_atrium_gate",fn)