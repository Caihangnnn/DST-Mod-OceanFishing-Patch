local function onowner(self, v, old)
    if v then
        self.inst.components.inventoryitem.canonlygoinpocket = true --只能放口袋，不可以放到容器中
        self.inst:AddTag("nosteal") --不能被偷
        v:PushEvent("binding_oceanfishingrod", self.inst)
    else
        self.inst.components.inventoryitem.canonlygoinpocket = false --可以放到容器中
        self.inst:RemoveTag("nosteal")
    end
    if old and v ~= old then
        old:PushEvent("unbound_oceanfishingrod", self.inst)
    end
end

local Binding = Class(function(self, inst) 
	self.inst = inst
    self.owner = nil
    --监听放入库存
    self.inst:ListenForEvent("onputininventory",function(inst, owner)
        if owner ~= nil and owner:HasTag("Player") and owner.components.bindingoceanfishingrod and owner.components.bindingoceanfishingrod.child == nil then
            self:SetOwner(owner)
        end
    end)
    --被移除了
    self.inst:ListenForEvent("onremove", function(inst)
        if self.owner then
            self.owner:PushEvent("unbound_oceanfishingrod", self.inst)
        end
    end)
end,nil,{
    owner = onowner,
})

function Binding:SetOwner(owner)
    self.owner = owner ~= nil and owner:HasTag("Player") and owner or nil
end

function Binding:GetOwner()
	return self.owner
end

return Binding