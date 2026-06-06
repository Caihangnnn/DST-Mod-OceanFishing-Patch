local NO_REMOVE = {"FX", "NOCLICK", "DECOR", "INLIMBO", "STUMP", "BIRD", "NOVACUUM", "irreplaceable", "boat", "NOBLOCK", "multiplayer_portal", "farm_plant"}
-- 设置速度
local function setspeed(v, multiple, angle)
    if v.components.inventoryitem then
        -- v.Physics:SetVel(multiple * math.sin(angle), 0, multiple * math.cos(angle))
        v.Physics:SetMotorVel(multiple * math.sin(angle), 0, multiple * math.cos(angle))
    else
        v.Physics:SetMotorVelOverride(multiple * math.sin(angle), 0, multiple * math.cos(angle))
    end
end
-- 获取传送的随机点
local function getpoint()
    local p_x,p_z
    local t = TheWorld.topology.lands
    local idx = t[math.random(#t)]
    if idx then
        -- 优先节点中心 如果是海洋 那么再随机一部分
        local node = TheWorld.topology.nodes[idx]
        if TheWorld.Map:IsLandTileAtPoint(node.x, 0, node.y) then
            p_x,p_z = node.x, node.y
        end
        while p_x == nil do
            local points = GetRandomPointsForSite_OF(node.poly, 5)
            for k, v in pairs(points) do
                if TheWorld.Map:IsLandTileAtPoint(v[1], 0, v[2]) then
                    p_x,p_z = v[1], v[2]
                    break 
                end
            end
        end
    end
    return p_x, p_z
end
-- 开始吸引
local function onattract(inst)
    local p_x, p_z = getpoint()
    local x, y, z = inst.Transform:GetWorldPosition()
    local r = 4
    local time = 0
    --刷帧
    inst:DoPeriodicTask(2*FRAMES, function()
        -- 计算半径
        if time > 1 then
            r = r + 1
            time = time - 1
        else
            time = time + FRAMES
        end
        -- 对附近实体进行吸引
        local ents = TheSim:FindEntities(x, y, z, r, nil, NO_REMOVE)
        for i, v in ipairs(ents or {}) do
            if v ~= inst and v.entity:IsVisible() then
                if v.Physics then
                    local distance = math.sqrt(v:GetDistanceSqToPoint(x,y,z))
                    local angle = v:GetAngleToPoint(x, y, z)
                    if distance > 12 then
                        setspeed(v, 12, angle)
                    elseif distance > 8 then
                        setspeed(v, 9, angle)
                    elseif distance > 5 then
                        setspeed(v, 6, angle)
                    elseif distance > 2 then
                        setspeed(v, 4, angle)
                    elseif distance > 0.75 then
                        setspeed(v, 1, angle)
                    elseif p_x and p_z then
                        setspeed(v, 0, angle)
                        v.Transform:SetPosition(p_x, 0, p_z) --进行传送 更改坐标
                    end
                end
            end
        end
    end)
end

local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("whirlportal")
    inst.AnimState:SetBank("whirlportal")
    inst.AnimState:PushAnimation("open_loop", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND) --设置图层 4


    inst:AddTag("CLASSIFIED")

    if not TheWorld.ismastersim then
        return inst
    end   

    inst:DoTaskInTime(0, onattract)
    inst:DoTaskInTime(15, inst.Remove)

    inst.persists = false --退出时不会保存

	return inst
end

return Prefab("black_hole_of",fn)