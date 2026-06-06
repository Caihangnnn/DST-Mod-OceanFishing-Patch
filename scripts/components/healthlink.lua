-----------------------------
-- 【单向生命链接状态】
-- 在持续时间内 会持续找合适目标
-- 目标会在限时里随来源【生命值变化】
-----------------------------
local LINKTIME = 60 -- 持续时间

--检查表中是否存在
local function Inspect(inst)
    local self = inst.components.healthlink
    return self and self.source == nil or false
end

local function FindPlayer(inst)
    local p = {}
    for i, v in ipairs(AllPlayers) do
        if v and v.entity:IsVisible() and v ~= inst and Inspect(v) 
        and not v:HasTag("playerghost") and v.components.health ~= nil and
        not v.components.health:IsDead()  then --目标不是自己 且目标没有链接目标 且 目标未死亡
            table.insert(p,v)
        end
    end
    return #p > 0 and p[math.random(#p)] or nil
end

local HealthLink = Class(function(self,inst)
	self.inst = inst
    -- 目标角色
    self.target = nil
    -- 来源角色
    self.source = nil

    self:AllEvent()
end)

function HealthLink:AllEvent()
    --如果是来自链接的 生命变化
    self.inst:ListenForEvent("healthdelta",function(inst,data)
        -- if data.cause ~= "OF_HEALTHLINK" then
            if self.target ~= nil and self.target:IsValid() and
            not self.target:HasTag("playerghost") and
            self.target.components.health ~= nil and
            not self.target.components.health:IsDead() then -- 存在且存活
                self.target.components.health:DoDelta(data.amount,nil,"OF_HEALTHLINK",nil, inst)
            end
        -- end
    end)
    -- 如果自己死亡 断开链接 结束任务
    self.inst:ListenForEvent("death", function(inst,data)
        self:Disconnect()
        self:Finish()
    end)
    self.inst:ListenForEvent("onremove", function(inst)
        self:Disconnect()
        self:Finish()
    end)
    -- 连接使用事件
    self.inst:ListenForEvent("link_of", function(inst, data) 
        self.source = data
        self.colour = self.source.components.healthlink:GetColour()
        self:SpawnFX()

        local str = self.source:GetDisplayName() or "???"
        self.inst.components.talker:Say("与来源 "..str.." 链接", 5)
    end)
    self.inst:ListenForEvent("broken_link_of", function(inst, data)
        if self.of_fx then
            self.of_fx:Remove()
            self.of_fx = nil
        end
        local str = ""
        -- 取消关联
        if data and data.type then
            str = self[data.type]:GetDisplayName()
            self[data.type] = nil
        end
        self.inst.components.talker:Say("断开了与 "..str.." 链接", 5)
    end)
end

-- 断开与被连接目标的关系
function HealthLink:Disconnect()
    local str = ""
    if self.target then
        str = self.target:GetDisplayName()
        self.target:PushEvent("broken_link_of", {type = "source"})
        self.target = nil
    end
    if self.source then
        str = self.source:GetDisplayName()
        self.source:PushEvent("broken_link_of", {type = "target"})
        self.source = nil
    end

    if self.of_fx then
        self.of_fx:Remove()
        self.of_fx = nil
    end
    self.inst.components.talker:Say("断开了与 "..str.." 链接", 5)
end

function HealthLink:SpawnFX()
    if self.of_fx == nil then
        self.of_fx = SpawnPrefab("of_reticule")
        self.of_fx.AnimState:SetMultColour(self.colour.r, self.colour.p, self.colour.c, 1)
        self.of_fx.entity:SetParent(self.inst.entity) 
    end
end
function HealthLink:GetColour()
    if self.colour == nil then
        self.colour = {
            r = math.random(1,255)/255,
            p = math.random(1,255)/255,
            c = math.random(1,255)/255,
        }   
    end
    return self.colour
end


function HealthLink:LockPlayer()
    local target = FindPlayer(self.inst)
    if target then
        self.target = target
        self.target:PushEvent("link_of", self.inst) --被连接

        self:SpawnFX()
        -- 重置时间
        self.last_time = nil

        local str = self.target:GetDisplayName() or "???"
        self.inst.components.talker:Say("与目标 "..str.." 链接", 5)
    end
end

function HealthLink:Finish()
    self.inst:StopUpdatingComponent(self)
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function HealthLink:Start(time)
    self:Finish()
    self.inst:StartUpdatingComponent(self)
    self.task = self.inst:DoTaskInTime(time or LINKTIME, function()
        self:Disconnect()
        self:Finish()
    end)
end

function HealthLink:OnUpdate(dt)
    if self.source or self.target then --被连接中 或者 已存在目标, 则无需找目标
        return
    end
    --每隔一会 就寻找目标一次
    self.last_time = (self.last_time or 1.5) + dt
    if self.last_time > 2 then
        self.last_time = 0
        self:LockPlayer()
    end
end

return HealthLink