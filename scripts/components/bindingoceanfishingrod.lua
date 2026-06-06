local function OnDropped(inst, data)
    if data.item.components.binding and data.item.components.binding.owner == inst then
        local inventory = inst.components.inventory
        if #inventory.itemslots < inventory.maxslots then
            inventory:GiveItem(data.item)
        else
            -- 丢下第一个物品
            inventory:DropItem(inventory.itemslots[1], true, true)
            inventory:GiveItem(data.item)
        end
    end
end

local BindingOceanFishingRod = Class(function(self, inst) 
	self.inst = inst
    --监听绑定请求
    self.inst:ListenForEvent("binding_oceanfishingrod",function(inst,child)
        if self.child == child then return end
        if self.child ~= nil then
            self.child.components.binding:SetOwner(nil)
        end
        self.child = child
        -- print("玩家绑定海钓竿")
    end)
    --监听断开绑定请求
    self.inst:ListenForEvent("unbound_oceanfishingrod",function(inst, child)
        if self.child ~= child then return end
        self.child = nil
    end)
    -- 玩家移除时，解除绑定 变猴子时 或者 换人时掉落物品 就会执行这个
    self.inst:ListenForEvent("onremove",function(inst)
        if self.child ~= nil then
            self.child.components.binding:SetOwner(nil)
        end
        self.child = nil        
    end)
    -- -- 玩家变猴子时
    -- self.inst:ListenForEvent("ms_playerseamlessswaped", function(inst)
    --     -- print("变身的旧身体", inst)
    -- end)
    -- self.inst:ListenForEvent("ms_playerreroll", function(inst)
    --     -- print("变身的新身体", inst)
    -- end)
    self.inst:ListenForEvent("dropitem", OnDropped) -- 丢下时
end)

function BindingOceanFishingRod:GetChild()
	return self.child
end

return BindingOceanFishingRod
