require "behaviours/wander"
require "behaviours/chaseandattack"
-- require "behaviours/doaction"
-- require "behaviours/follow"
require "behaviours/chattynode"
-- local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9

local function GetLeader(inst)
    return inst.components.follower.leader
end
local function IsAround(inst)
    if inst.components.follower and inst.components.follower.leader and inst:IsNear(inst.components.follower.leader, inst.distance_around or 8) then --离追随者距离少于4地皮
        return true
    end
end

local GlasscutterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function GlasscutterBrain:OnStart()
    local root = PriorityNode(
    {
        --追逐和攻击 
        WhileNode(
            function() return IsAround(self.inst) end, "AttackMomentarily",
            ChaseAndAttack(self.inst, 7, 20)--攻击和追踪
            --ChaseAndAttackAndAvoid 攻击、追踪、躲避
        ),
        --徘徊 
        WhileNode(
            function() return not self.inst.components.health:IsDead() end, "Piahui",
            Wander(self.inst, function(inst) return GetLeader(inst) and GetLeader(inst):GetPosition() or nil end, 4)
        ),
    },.5)

    self.bt = BT(self.inst, root)
end

return GlasscutterBrain