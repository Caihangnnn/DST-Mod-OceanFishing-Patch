local assets =
{
    Asset("ANIM", "anim/moondial.zip"),
    Asset("ANIM", "anim/moondial_build.zip"),
    Asset("ANIM", "anim/moondial_waning_build.zip"),
}

-- 原计划A是此建造 设定为 给任意可交易物品一定数量后，从通用+角色特有的集合中随机一份奖励，有些喧宾夺主的意味了。
-- 原计划B是此建造 设定为 特殊科技，会记录已经交易过的物品(有些物品得添加可交易组件)，可提过ui界面选择，已经达到配方的奖励，且消耗对应的物品，复杂了懒得搞。
-- 原计划C是此建造 设置为 光源。

-- local function SpawnPrefabItem(inst,num,giver)
--     -- 获取表
--     local playerdata = TUNING.GAMBLING_DOG and TUNING.GAMBLING_DOG.playerdata or deepcopy(require("wishspring_loot").playerdata)
--     local currency = TUNING.GAMBLING_DOG and TUNING.GAMBLING_DOG.currency or deepcopy(require("wishspring_loot").currency)
--     -- 通用表
--     if currency == nil or type(currency) ~= "table" then
--         currency = {}
--     end
--     -- 获取对应角色类型的奖励表
--     local data = playerdata and playerdata[giver.prefab] or {}

--     for k,v in ipairs(data and type(data)== "table" and data or {}) do
--         table.insert(currency, v)
--     end

--     for i = 1, num do
--         local loot = WeightRandom(currency) -- 权重随机一项
--         if loot == nil then return end
--         if loot.event then loot.event(giver) return end

--         local item = SpawnPrefab(type(loot.item) == "table" and loot.item[math.random(#loot.item)] or loot.item)
--         if item then
--             local x,y,z = inst.Transform:GetWorldPosition()
--             item.Transform:SetPosition(x,2,z)
--              --这里应该改为钓鱼的那种方法，将一切视为物品 抛出去
--             if item.Physics then
--                 local angle = math.random() * 2 * PI
--                 local speed = math.random() * 3 + 1
--                 item.Physics:SetVel(speed * math.cos(angle), 1, speed * math.sin(angle))
--             end
--         end
--     end
-- end


-- 底下代码，写太久了，思路混乱了，可能优化并不好，未来可能重写

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    end

    return true
end
local levels = {
    .5, 1.25, 2.5, 3.75
}
-- 懒得做映射
local function state(inst)
    if inst.threshold <= 0 then
        inst.Light:Enable(false)
        return
    end
    inst.Light:Enable(true)
    if inst.threshold == 1 then
        inst.AnimState:PlayAnimation("wax_to_quarter",false)
        inst.AnimState:PushAnimation("idle_quarter",true)
    end
    if inst.threshold == 2 then
        inst.AnimState:PlayAnimation("wax_to_half",false)
        inst.AnimState:PushAnimation("idle_half",true)
    end
    if inst.threshold == 3 then
        inst.AnimState:PlayAnimation("wax_to_threequarter",false)
        inst.AnimState:PushAnimation("idle_threequarter",true)
    end
    if inst.threshold == 4 then
        inst.AnimState:PlayAnimation("wax_to_full",false)
        inst.AnimState:PushAnimation("idle_full",true)
    end
end

local function state2(inst)
    if inst.threshold <= 0 then
        inst.AnimState:PlayAnimation("wane_to_new",false)
        inst.AnimState:PushAnimation("idle_new",true)
        inst.Light:Enable(false)
        return
    end
    if inst.threshold == 1 then
        inst.AnimState:PlayAnimation("wane_to_quarter",false)
        inst.AnimState:PushAnimation("idle_quarter",true)
    end
    if inst.threshold == 2 then
        inst.AnimState:PlayAnimation("wane_to_half",false)
        inst.AnimState:PushAnimation("idle_half",true)
    end
    if inst.threshold == 3 then
        inst.AnimState:PlayAnimation("wane_to_threequarter",false)
        inst.AnimState:PushAnimation("idle_threequarter",true)
    end
    inst.Light:SetRadius(levels[inst.threshold])
end
local function OnUpdateLight(inst, distance)
    inst.radius = inst.radius - distance
    local jl = inst.threshold <= 1 and distance or levels[inst.threshold - 1]
    if inst.radius < jl then
        inst.threshold = inst.threshold - 1
        if inst.threshold <= 0 then
            inst.lighttask:Cancel() -- 取消执行任务
            inst.threshold = 0
            inst.radius = 0
            inst.lighttask = nil            
        end
        state2(inst)
    end
    inst.Light:SetRadius(inst.radius)
end

local function OnStaffGiven(inst, giver, item)
    if inst.lighttask ~= nil then
        -- inst.pendingtasks[inst.lighttask] = nil
        inst.lighttask:Cancel() -- 取消执行任务
        inst.lighttask = nil
    end

    if inst.threshold == 4 then
        inst.AnimState:PlayAnimation("hit_new",false)
        inst.AnimState:PushAnimation("idle_new",true)
        inst.Light:Enable(false)
        inst.radius = 0
        inst.threshold = 0
        inst.Light:SetRadius(inst.radius)
        return
    end

    inst.threshold = inst.threshold + 1
    inst.radius = levels[inst.threshold]
    inst.lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, 0, .05 * 1/30)
    state(inst)
end

local function OnSave(inst, data)
    data.threshold = inst.threshold
    data.radius = inst.radius
end

local function OnLoad(inst, data)
    inst.threshold = data and data.threshold ~= nil and data.threshold or 0
    inst.radius = data and data.radius ~= nil and data.radius or 0
    inst.lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, 1, .05 * 1/30)
    state(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    MakeObstaclePhysics(inst, .45)

    inst:AddTag("structure")

    inst.AnimState:SetBank("moondial")
    inst.AnimState:SetBuild("moondial_build")
    inst.AnimState:PlayAnimation("idle_new", true)
    inst.AnimState:SetMultColour(255/255, 200/255, 255/255, 1)

    inst.Light:Enable(false)
    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(15 / 255, 160 / 255, 180 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeHauntableWork(inst)

    inst:AddComponent("inspectable") --可检测

    inst:AddComponent("trader") 
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)  
    inst.components.trader.deleteitemonaccept = true  
    inst.components.trader.onaccept = OnStaffGiven 
    inst.components.trader:Enable()

    inst.radius = 0
    inst.threshold = 0

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("springlamp", fn, assets)
