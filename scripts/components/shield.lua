local Shield = Class(function(self, inst)
	self.inst = inst
	self.max = 200
	self.condition = 200
end)

--------------------------------------------------------------------------
--[[ Public member functions ]] --公共函数
--------------------------------------------------------------------------

function Shield:IsBroken()
	return self.condition > 0
end

function Shield:SetMax(amount)
	if type(amount) ~= "number" then return end
	self.max = amount
end
function Shield:SetCondition(amount)
	if type(amount) ~= "number" then return end
	self.condition = math.max(self.max, amount) 
end

function Shield:DoDelta(combat, attacker, damage, weapon, stimuli, spdamage)

	local old_health = self.condition
	self.condition = self.condition - damage

	if old_health < self.condition then --是增加生命值的攻击, 护盾值不变
		self.condition = old_health
		--执行原方法
		return combat:old_GetAttacked_haidiao(attacker, damage, weapon, stimuli, spdamage)
	end
	--生成fx
	local fx = SpawnPrefab("shield_fx")
 	fx.entity:SetParent(combat.inst.entity) 
 	fx.Transform:SetScale(combat.inst.Transform:GetScale()) --放大倍数
	fx.Transform:SetPosition(0, 2, 0)

	if self.condition <= 0 then --造成超额伤害
		fx.AnimState:PlayAnimation("shield")
		self.condition = 0

		return combat:old_GetAttacked_haidiao(attacker, damage - old_health, weapon, stimuli, spdamage)
	end
	--刚好造成0伤害
	return false
end

--------------------------------------------------------------------------
--[[ Save/Load ]] --保存与加载
--------------------------------------------------------------------------

function Shield:OnSave()
    return {
    	condition = self.condition
    }
end

function Shield:OnLoad(data)
    --先保存下来 初始化时进行赋值
    for k,v in pairs(data) do
    	self[k] = v
    end
end

-- 变猴子也继承
function Shield:TransferComponent(newinst)
    local data = self:OnSave()
    if data then
        local newcomponent = newinst.components.shield
        if not newcomponent then
            newinst:AddComponent("shield")
            newcomponent = newinst.components.shield
        end
        newcomponent:OnLoad(data)
    end
end

return Shield