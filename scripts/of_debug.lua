local cor = {
    -- {1, 0, 0},
    -- {0, 1, 0},
    -- {0, 0, 1},
    {1.000, 0.000, 0.000},   -- 红
    {1.000, 0.647, 0.000},   -- 橙
    {1.000, 1.000, 0.000},   -- 黄
    {0.000, 0.502, 0.000},   -- 绿
    {0.000, 0.000, 1.000},   -- 蓝
    {0.294, 0.000, 0.510},   -- 靛
    {0.502, 0.000, 0.502}    -- 紫
}

local function SpawnPrefabL(i)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.Light:SetIntensity(.9)
    -- inst.Light:SetRadius(.3*i)
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(.8)
    inst.Light:Enable(true)
    -- inst.Light:SetColour(i*10 / 255, i*10 / 255, i*10 / 255)
    inst.Light:SetColour(cor[i][1], cor[i][2], cor[i][3])
    return inst
end

setmouse = function()
    if MOUSEENTITY == nil then
        return
    end
    local ent = MOUSEENTITY
    local n = #cor
    local r = 3
    if ent.light == nil then
        ent.light = {}
        for i=1, n do
            -- 生成光源
            local inst = SpawnPrefabL(i)
            inst.entity:SetParent(ent.entity)
            local angle = i * 2 * PI / n
            local x = r*math.cos(angle) + 2
            local z = r*math.sin(angle) + 2

            inst.Transform:SetPosition(x, 0, z)
            ent.light[i] = inst
        end
    else
        for key, value in pairs(ent.light or {}) do
            value:Remove()
        end
        ent.light = nil
    end
end

-- print("执行了吗")