local state = "control_puppet" -- 设定要绑定的state
local puppet= State{
    name = state,--状态名称
    tags = {"busy", "doing", "canrotate", "oncontrolpuppet"}, --oncontrolpuppet标签用来判断

    onenter = function(inst)
        local ba = inst:GetBufferedAction()
        if ba and ba.pos then
            inst:ForceFacePoint(ba.pos)
        end

        inst.sg:SetTimeout(TUNING.CONTROLPUPPETTIME) --设置退出时间
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("channel_pre")
        inst.AnimState:PushAnimation("channel_loop", true)
    end,

    events =
    {
        EventHandler("of_stopcontrolling", function(inst) inst.sg:GoToState("idle") end),
    },
    --退出时间到了执行
    ontimeout = function(inst)
        inst.sg:GoToState("idle") --转到空闲状态
    end,
    --退出状态时执行
    onexit = function(inst)
        inst.components.locomotor:Stop()
        inst.components.locomotor:SetBufferedAction(nil)

        if inst.components.controlpuppet then
            inst.components.controlpuppet:StopControl()
        end
    end,
} 

--注册状态
AddStategraphState("wilson",puppet) 
AddStategraphState("wilson_client",puppet)


AddAction("RELINQUISHCONTROL", STRINGS.ACTIONS.RELINQUISHCONTROL, function(act)
    -- print("执行取消动作了吗")
    local puppet = act.doer
    local inst = act.target
    if inst and inst.components.controlpuppet then
        inst.components.controlpuppet:StopControl()
        return true
    end
    return false
end)

local function GetPuppet(inst)
    return inst.components and (
            (inst.components.controlpuppet and inst.components.controlpuppet.puppet) 
            or (inst.components.clientcontrolpuppet and inst.components.clientcontrolpuppet.puppet)
        ) or nil
end

function GLOBAL.GetAction_of(inst, target, puppet, inventory, pos) -- pos 位移完全可以左键点击前往。 这个来刨耕地的土坑有点用。
    local lmb, rmb = BufferedAction(puppet, target, ACTIONS.LOOKAT)
    -- 检查目标是自己 创建缓冲动作
    if target == puppet then --是目标傀儡自己
        -- 左键取消控制
        -- 右键丢下物品
        rmb = BufferedAction(puppet, inst, ACTIONS.RELINQUISHCONTROL) -- 玩家在操控期间是busy的 忙碌的就不会执行动作.让傀儡取消
        return lmb, rmb
    end
    -- 可以攻击吗
    if target ~= inst and puppet.replica.combat and puppet.replica.combat:CanTarget(target) then
        rmb = BufferedAction(puppet, target, ACTIONS.ATTACK)
        return lmb, rmb
    end

    -- -- 收入库存的动作
    -- if inventory then
    --     -- 是否为物品 可以被捡起吗
    --     local inventoryitem = target.replica.inventoryitem
    --     if target and inventoryitem and not inventoryitem:IsHeld() then -- 无主之物 或者 直接判断标签
    --         rmb = BufferedAction(puppet, target, ACTIONS.PICKUP_PUPPE)
    --         return lmb, rmb
    --     end

    --     -- 是否为可以采集的
    --     if target:HasTag("pickable") and not (target:HasTag("fire") or target:HasTag("intense")) then
    --         rmb = BufferedAction(puppet, target, ACTIONS.PICK)
    --         return lmb, rmb
    --     end
    -- end
    -- TOOLACTIONS = {CHOP = "砍", DIG = "挖", HAMMER = "敲", MINE = "开采", NET = "捕捉", PLAY = "这个可不行", UNSADDLE = "卸下", SCYTHE = "收割" }
    -- 砍树 挖矿  ACTIONS.MINE 开采 ACTIONS.DIG 挖 ACTIONS.NET 捕捉 ACTIONS.CHOP 砍
    for k, v in pairs(TOOLACTIONS) do -- 直接使用这个感觉会出问题啊
        if target:HasTag(k.."_workable") then
            rmb = BufferedAction(puppet, target, ACTIONS[k])
            return lmb, rmb
        end
    end

    return lmb, rmb
end

AddComponentPostInit("playeractionpicker",function(self)
    local old_DoGetMouseActions = self.DoGetMouseActions
    self.DoGetMouseActions = function(self, position, target, spellbook)
        local lmb, rmb
        if self.inst.onpuppet:value() then
            -- local pos = position or TheInput:GetWorldPosition() --前者表示是服务器执行的 后者是客户端执行的
            target = target or TheInput:GetWorldEntityUnderMouse()
            local puppet = GetPuppet(self.inst)
            -- 没有对象 无需交互。
            if puppet and target then 
                -- lmb = BufferedAction(puppet, self.inst, ACTIONS.RELINQUISHCONTROL) -- 玩家在操控期间是busy的 忙碌的就不会执行动作.让傀儡取消
                lmb, rmb = GetAction_of(self.inst, target, puppet, inventory)
                -- return lmb, rmb
            end
        else
            lmb, rmb = old_DoGetMouseActions(self, position, target, spellbook)
        end
        return lmb, rmb
    end
end)


if TheNet:GetIsServer() or TheNet:IsDedicated() then
    require "stategraph"
    if StateGraphInstance then
        local old_PushBufferedAction = StateGraphInstance.StartAction
        StateGraphInstance.StartAction = function(self, bufferedaction)
            if self.inst:HasTag("is_puppet") and not self.inst:HasTag("busy") and bufferedaction and bufferedaction.action ~= ACTIONS.ATTACK then
                bufferedaction:Do()
                return 
            end
            return old_PushBufferedAction(self, bufferedaction)
        end
    end
    -- 这部分完全可以服务器上执行就好了
    AddComponentPostInit("playercontroller",function(self)
        if TheWorld.ismastersim then
            local old_DoAction = self.DoAction
            self.DoAction = function(self, act, spellbook) 
                if self.inst.onpuppet:value() and act --[[and act.action == ACTIONS.RELINQUISHCONTROL]] then --玩家在操控期间是busy的 忙碌的就不会执行动作
                    -- 得推送动作到 组件里执行
                    -- act.instant = true --立刻执行 不进sg动画就算了 而且没有监测该动作啊 难以统一
                    if act.action == ACTIONS.ATTACK then
                        self.inst.components.controlpuppet:PuppetAttack(act.target)
                    else
                        self.inst.components.controlpuppet:PushAction(act, true)
                    end

                    return
                end
                old_DoAction(self, act, spellbook)
            end
        end
    end)
end