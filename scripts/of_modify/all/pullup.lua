-- 部分借鉴了"Retrieve Items From The Ocean"mod 下面是mod的链接
-- https://steamcommunity.com/sharedfiles/filedetails/?id=1819208941
local id = "PULLUP_OF" --必须大写，动作会被加入到ACTIONS表中，key就是id。
local name = "钓东西" --随意，会在游戏中能执行动作时，显示出动作的名字
--等待动作设置状态动画队列的播放完毕时 才会执行到这里。
local fn = function(act) -- 动作触发的函数。传入的是一个BufferedAction对象。可以通过它直接调用动作的执行者，目标，具体的动作内容等等，详情请查看bufferedaction.lua文件，也可以参考actions.lua里各个action的fn。
    if act.target and act.target.components.inventoryitem
    and act.target.components.inventoryitem.canbepickedup and not act.target.components.inventoryitem:IsHeld() then --目标可以钓起来
        -- 获取目标物品的位置
        local pt = act.target:GetPosition()

        -- 获取海钓竿最大距离 浮标影响
        local rod = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local maxcastdist = rod.replica.oceanfishingrod:GetMaxCastDist()

        -- 超过范围了
        if act.doer:GetDistanceSqToPoint(pt.x,pt.y,pt.z) > maxcastdist*maxcastdist then return false end

        -- 在海上
        if TheWorld.Map:InternalIsPointOnWater(pt.x, pt.z) or act.target.IsOnWater and act.target:IsOnWater() then
            if act.doer or act.invobject then
                --将物品朝玩家抛起
                LaunchAt(act.target, act.target, act.doer or act.invobject, 4)
                act.target.components.inventoryitem:SetLanded(false, true)
            end
            return true
        end
    end
end
--注册动作
AddAction(id,name,fn) -- 将上面编写的内容传入MOD API,添加动作

-------------------------------------------------------------------
-- 设置动作的其他数据
-- ACTIONS.PULLUP_OF.distance = 10 --最大使用距离
-- ACTIONS.PULLUP_OF.mindistance = 3 --最小使用距离
ACTIONS.PULLUP_OF.customarrivecheck = function(doer, dest) --直接复制官方抛竿动作内容
    local doer_pos = doer:GetPosition()
    local target_pos = Vector3(dest:GetPoint())
    local dir = target_pos - doer_pos

    local test_pt = doer_pos + dir:GetNormalized() * (doer:GetPhysicsRadius(0) + 0.25)
    if TheWorld.Map:IsVisualGroundAtPoint(test_pt.x, 0, test_pt.z) or TheWorld.Map:GetPlatformAtPoint(test_pt.x, test_pt.z) ~= nil then
        return false
    else
        return true
    end
end

-------------------------------------------------------------------
local type = "EQUIPPED" -- 设置动作绑定的类型
local component = "oceanfishingrod" -- 设置动作绑定的组件
local testfn = function(inst, doer, target, actions, right) -- 设置动作的检测函数，如果满足条件，就向人物的动作可执行表中加入某个动作。right表示是否是右键动作。
    if right and doer and not doer:HasTag("fishing_idle") and not doer:HasTag("oceanfishing_pullup") then --不能在海钓时执行
        --判断物品是否可呗放到包里
        if target and target.replica.inventoryitem and target.replica.inventoryitem:CanBePickedUp() and not target.replica.inventoryitem:IsHeld() then
            local pt = target:GetPosition()
            --判断是否在水上
            if TheWorld.Map:InternalIsPointOnWater(pt.x, pt.z) or (target.IsOnWater and target:IsOnWater()) then 
                table.insert(actions, ACTIONS.PULLUP_OF)
            end
        end        
    end

end
--注册动作所绑定的组件
AddComponentAction(type, component, testfn)

-------------------------------------------------------------------
local state = "oceanfishing_pullup" -- 设定要绑定的state
local wilson= State{
    name = state,--状态名称
    tags = { "prefish", "fishing" }, --状态标签
    --进入状态时
    onenter = function(inst)
        inst:AddTag("oceanfishing_pullup") --标记一下
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("fishing_ocean_pre") --播放玩家行为动画
        inst.AnimState:PushAnimation("fishing_ocean_cast", false)
        inst.AnimState:PushAnimation("fishing_ocean_bite_heavy_loop", false)
        inst.AnimState:PushAnimation("fishing_ocean_catch", false)
    end,
    --时间线
    timeline =
    {
        TimeEvent(15*FRAMES, function(inst)
            --抛竿的声音
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast")
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast_ocean")
        end),
        --30帧 刚好播完上面的动画
        TimeEvent(30*FRAMES, function(inst)
            inst.sg:RemoveStateTag("fishing") --删除状态标记
            -- 推送动作 执行动作的方法
            inst:PerformBufferedAction()
        end),
    },
    --状态事件
    events =
    {
        --动画队列结束
        EventHandler("animqueueover", function(inst)
            inst.sg:GoToState("idle") --转到空闲状态
        end),
    },
    --退出时
    onexit = function(inst)
        inst:RemoveTag("oceanfishing_pullup")
    end
} 

local wilson_client = State{
    name = state,
    tags = { "prefish", "fishing" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("fishing_ocean_pre")
        inst.AnimState:PushAnimation("fishing_ocean_cast", false)
        inst.AnimState:PushAnimation("fishing_ocean_bite_heavy_loop", false)
        inst.AnimState:PushAnimation("fishing_ocean_catch", false)

        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(TIMEOUT)
    end,

    onupdate = function(inst)
        if inst:HasTag("fishing") then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle")
        end
    end,

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end,
}
--注册状态
AddStategraphState("wilson",wilson) 
AddStategraphState("wilson_client",wilson_client)
-------------------------------------------------------------------
--注册动作的状态
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.PULLUP_OF, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.PULLUP_OF,state))