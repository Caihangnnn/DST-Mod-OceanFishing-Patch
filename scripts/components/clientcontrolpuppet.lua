-- 键盘移动输入信息
local function GetWorldControllerVector()
    local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
    local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
    if math.abs(xdir) >= deadzone or math.abs(ydir) >= deadzone then --超过误差. 才说明移动了
        local dir = TheCamera:GetRightVec() * xdir - TheCamera:GetDownVec() * ydir
        return dir:GetNormalized()
    end
end
-- 是否发起了攻击或强制攻击
local function GetPressAttack()
    local force_attack = TheInput:IsControlPressed(CONTROL_FORCE_ATTACK) or TheInput:IsControlPressed(CONTROL_ATTACK)
    return force_attack
end
-- 空格键
local function GetControlAction()
    return TheInput:IsControlPressed(CONTROL_ACTION)
end

local ClientControlPuppet = Class(function(self, inst) 
	self.inst = inst
    self.client = TheNet:GetIsClient() or not TheNet:IsDedicated()
    self.puppet = nil --傀儡

    -- 不是客户端 不需要这个组件
    if not self.client then
        self.inst:DoTaskInTime(0, function()
            self.inst:RemoveComponent("clientcontrolpuppet")
        end)
    end 
end)

function ClientControlPuppet:StartControl(puppet)
    if puppet == nil then return end
    self.puppet = puppet
    self.inst:StartUpdatingComponent(self)
end
function ClientControlPuppet:StopControl()
    self.puppet = nil
    self.inst:StopUpdatingComponent(self)
end

function ClientControlPuppet:OnUpdate()
    if self.puppet == nil then
        self:StopControl()
        SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"npc_fail"}, nil, true))
        return
    end
    -- 不忙的时候 才获取键盘输入
    local isbusy = self.inst.puppet_isbusy:value()
    if not isbusy then
        local dir = GetWorldControllerVector()
        local attack = GetPressAttack()
        -- 方向为改变时 不需要发送rpc
        if (dir == nil and self.puppet_dir == nil) or
            (self.puppet_dir and dir and self.puppet_dir.x == dir.x and self.puppet_dir.z == dir.z) then
        else
            self.puppet_dir = dir --可能为nil 说明是要停止移动
            SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"npc_move_of", dir and -math.atan2(dir.z, dir.x) / DEGREES or false}, nil, true))
        end
        if attack then
            SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"npc_attack"}, nil, true))
        end
        local space = GetControlAction()
        if space then
            SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"npc_vicinity"}, nil, true))
            return
        end
    end
end

return ClientControlPuppet