local function Attack(inst)
    local combat = inst.components.combat
    local attackrange = combat:GetAttackRange() + 4
    -- 存在攻击目标 或者 攻击距离+4范围内找一个目标
    local target = combat.target or
             FindEntity(inst, attackrange, function(guy)
                            return inst ~= guy and inst.components.combat:CanTarget(guy)
                        end,
                        nil,
                        {"player","INLIMBO","DECOR", "boat","FX","NOBLOCK","NOCLICK","playerghost","CLASSIFIED","rotatableobject","companion"},
                        {"animal", "character", "monster", "shadowminion", "smallcreature"}
                    )
    -- 存在目标 返回攻击动作缓存
    return target
    -- return target ~= nil and BufferedAction(inst, target, ACTIONS.ATTACK) or nil
end

local function onremove(inst)
    local player = inst.puppet_owner
    if player and player.components.controlpuppet then
        player.components.controlpuppet:StopControl()
    end
end
local function onpuppet(self, v, old_v)
    if old_v then
        old_v:DoTaskInTime(0, function(inst) inst:RemoveEventCallback("onremove", onremove) end)
        old_v.puppet_owner = nil
    end
    if v then
        v.puppet_owner = self.inst
        v:ListenForEvent("onremove", onremove)
        -- v:ListenForEvent("of_leavecontrol", v.Remove)
    end
end

local ControlPuppet = Class(function(self, inst) 
	self.inst = inst
    self.ismastersim = TheWorld.ismastersim
    self.puppet = nil --傀儡 
    self.last_time = nil
end,
nil,
{
    puppet = onpuppet,
})

-- 检查一下传入的傀儡 是否符合要求
function ControlPuppet:CheckLegality(puppet)
    if puppet == nil or puppet.puppet_owner or puppet.components == nil or puppet.components.combat == nil then
        return false
    end
    return true
end

-- 开始控制
function ControlPuppet:StartControl(puppet)
    -- 目标不合法 或者 自身死亡了 或者 在控制中了
    if not self:CheckLegality(puppet) or self.inst.components.health:IsDead() or (self.inst.sg ~= nil and self.inst.sg:HasStateTag("oncontrolpuppet")) then return end
    self:StopControl()
    self.puppet = puppet
    -- 暂停移动
    self.puppet.components.locomotor:Stop()
    -- 清空目标
    self.puppet.components.combat:SetTarget()
    self.puppet:PushEvent("of_controlled")
    self.inst.sg:GoToState("control_puppet")
    self.inst:StartUpdatingComponent(self)
    if self.puppet then
        SendModRPCToClient(GetClientModRPC("of_RPC", "kehuduan"), self.inst.userid, DataDumper({"start_npc_move", {self.puppet.Network:GetNetworkID()}}, nil, true))
    end
    self.last_time = GetTime()
    self.inst.onpuppet:set(true)
end
-- 结束控制
function ControlPuppet:StopControl()
    if self.puppet == nil then return end
    self.puppet.components.locomotor:Stop()
    self.puppet:PushEvent("of_leavecontrol")
    self.puppet = nil
    self.inst:PushEvent("of_stopcontrolling", self.puppet) --sg 处于控制时 结束控制
    self.inst:StopUpdatingComponent(self)
    SendModRPCToClient(GetClientModRPC("of_RPC", "kehuduan"), self.inst.userid, DataDumper({"end_npc_move"}, nil, true))
    self.inst.onpuppet:set(false)
end
-- sg状态
function ControlPuppet:IsBusy()
    -- 非玩家的生物 服务器才有sg
    if self.puppet == nil then
        return true
    end
    local isbusy = self.puppet:HasTag("busy") or (self.puppet.sg ~= nil and self.puppet.sg:HasStateTag("busy")) or false
    isbusy = isbusy or (self.puppet.sg ~= nil and self.puppet.sg:HasStateTag("attack")) or self.puppet:HasTag("attack") 
    if isbusy and (self.puppet:HasTag("boathopping") or (self.puppet.sg ~= nil and not self.puppet.sg:HasStateTag("boathopping"))) then
        isbusy = false
    end
    return isbusy
end

-- 执行移动指令
function ControlPuppet:PuppetMove(dir)
    if self.ismastersim then
        -- 允许控制 且 目标存在
        if self.puppet == nil then
            return
        end
        if dir then
            self.puppet.components.locomotor:SetBufferedAction(nil)
            self.puppet.components.locomotor:RunInDirection(dir)
        else
            self.puppet.components.locomotor:Stop()
        end
    end
end
-- 执行攻击指令
function ControlPuppet:PuppetAttack(target) 
    if self.ismastersim then
        if self.puppet == nil then
            return
        end
        -- 检查攻击距离
        local combat = self.puppet.components.combat
        if combat == nil then return end
        -- 检查是否在攻击状态中 那么不要打断正在攻击。
        if (self.puppet.sg ~= nil and (self.puppet.sg:HasStateTag("attack") or self.puppet.sg:HasStateTag("longattack"))) or self.puppet:HasTag("attack") then
            return
        end
        -- 无视仇恨距离限制
        local ignoring_distance = false
        if target then
            combat:SetTarget(target)
            ignoring_distance = true
        end
        -- 不存在目标 产生找一次
        if combat.target == nil or not combat.target:IsValid() or combat.target.components.health:IsDead() then
            target = Attack(self.puppet)
            if target then
                combat:SetTarget(target)
            else
                return
            end
            if combat.target == nil or not combat.target:IsValid() or combat.target.components.health:IsDead() then
                return
            end
        end
        -- self.puppet.components.locomotor:PushAction(BufferedAction(self.puppet, combat.target, ACTIONS.ATTACK), true)
        -- 坐标
        local target_position = Point(combat.target.Transform:GetWorldPosition())
        local me = Point(self.puppet.Transform:GetWorldPosition())
        -- 距离
        local dsq = distsq(target_position, me)
        -- 速度
        local running = self.puppet.components.locomotor:WantsToRun()

        if not ignoring_distance and dsq >= 8*8 then --3 地皮外的就放弃仇恨
            self.puppet.components.combat:GiveUp()
            self.puppet.components.locomotor:Stop()
            return
        end
        -- 尝试移动到目标位置 (最近的可攻击位置)
        local r = self.puppet:GetPhysicsRadius(0) + combat.target:GetPhysicsRadius(-.1) + .1
        if (running and dsq > r * r) or (not running and dsq > combat:CalcAttackRangeSq()) then
            local vel_x, vel_z = VecUtil_NormalizeNoNaN(VecUtil_Sub(me.x, me.z, target_position.x, target_position.z))
            local combat_r = combat:GetAttackRange() - .1 --稍微小一点的
            target_position = Point( target_position.x + (combat_r * vel_x), target_position.y, target_position.z + (combat_r * vel_z))

            self.puppet.components.locomotor:GoToPoint(target_position, nil, true)
            -- 到达目的地后 应该要主动攻击一次。 (算了还是等待客户端的指令吧) -- 监听 onreachdestination 事件就好了
            return
        elseif not (self.puppet.sg ~= nil and self.puppet.sg:HasStateTag("jumping")) then
            self.puppet.components.locomotor:Stop()
            if self.puppet.sg:HasStateTag("canrotate") then
                self.puppet:FacePoint(target_position)
            end
        end
        -- 尝试发起攻击
        if self.puppet:HasTag("player") then
            self.puppet.components.locomotor:PushAction(BufferedAction(self.puppet, combat.target, ACTIONS.ATTACK), true)
        elseif combat:TryAttack() then
        else
            combat:BattleCry()
        end
    end
end
--开始更新检查状态
function ControlPuppet:OnUpdate()
    local isbusy = self:IsBusy()
    if self.inst.puppet_isbusy:value() ~= isbusy then
        self.inst.puppet_isbusy:set(isbusy)
    end
end

function ControlPuppet:PushAction(bufferedaction, isinterrupt) --isinterrupt 会打断当前缓冲或者行为。
    if self.puppet == nil then return end
    local locomotor = self.puppet.components.locomotor
    if locomotor == nil then return end
    --判断是否已经存在该缓冲动作 或者 不是空闲中(不允许进行行为时)
    if not isinterrupt and bufferedaction ~= nil and
        locomotor.bufferedaction ~= nil and
        bufferedaction.target == locomotor.bufferedaction.target and
        bufferedaction.action == locomotor.bufferedaction.action and
        bufferedaction.invobject == locomotor.bufferedaction.invobject and
        not (self.puppet.sg ~= nil and self.puppet.sg:HasStateTag("idle") and self.puppet:HasTag("busy")) then
        -- print("啊 有其他动作哟", bufferedaction) 
        return
    end
    -- print("推送动作", bufferedaction, bufferedaction.doer)
    self.puppet.components.locomotor:PushAction(bufferedaction, true)
end

-- 变猴子

return ControlPuppet

--ClientControlPuppet