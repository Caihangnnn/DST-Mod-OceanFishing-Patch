require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/doaction"
-- require "behaviours/follow"
-- require "behaviours/chattynode"
-- local BrainCommon = require("brains/braincommon")


local function AttackAction(inst)
    local target = FindEntity(inst, 12, function(guy)
            return inst.components.combat:CanTarget(guy) and guy:IsOnValidGround()
        end,
        nil,
        {"player","INLIMBO","DECOR", "boat","FX","NOBLOCK","NOCLICK","playerghost","CLASSIFIED","rotatableobject","companion"},
        {"animal", "character", "monster", "shadowminion", "smallcreature"})
    return target ~= nil and BufferedAction(inst, target, ACTIONS.ATTACK) or nil
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local PlayerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function PlayerBrain:OnStart()
    local jiedian = {
        --找附近攻击者
        DoAction(self.inst, AttackAction, "Attack", nil, 4), --做出行为
        --条件修饰节点 当条件满足时 访问第二节点（这里的徘徊行为节点）    
        WhileNode(function() return not self.inst.components.health:IsDead() end, "Piahui",
            Wander(self.inst, function(inst) return GetLeader(inst) and GetLeader(inst):GetPosition() or nil end, 4))
    }

    self.bt = BT(self.inst, PriorityNode(jiedian, .5))
end

return PlayerBrain
