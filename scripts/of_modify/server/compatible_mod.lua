---------------------------------------------------
--[[ 兼容其他mod ]]--
---------------------------------------------------
-- https://steamcommunity.com/sharedfiles/filedetails/?id=786556008 
-- 45 Inventory Slots
-- 这个mod上次更新2016年11月的事情。 太多人订阅了。 触发了天雷陷阱崩。
AddComponentPostInit("inventory",function(self)
    if self.isexternallyinsulated == nil then
        self.isexternallyinsulated = SourceModifierList(self.inst, false, SourceModifierList.boolean)
    end
end)
