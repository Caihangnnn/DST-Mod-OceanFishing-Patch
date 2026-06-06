--[[

非被包裹的物品
1\存在物品的背包容器类物品,不能清理,不必计数
2\物品使用耐久低于5%,直接清理
3\物品可堆叠,堆叠数量一并计数,当计数超最大值,物品一堆一堆的清理

max 保留物品
]]

--参考了 河蟹防熊锁(修复) mod
--https://steamcommunity.com/sharedfiles/filedetails/?id=1714227968

local cleaned = require("clean_list")

local function Clean()
    local countList = {} --待清理列表
    local size = 1
    for _, v in pairs(_G.Ents) do 
        if v.prefab ~= nil then
            local prefab = v.prefab
            repeat
                size = 1
                if cleaned[prefab] and not v:HasTag("INLIMBO") then --INLIMBO 在身上或者箱子里的物品都有这个标签
                    if v.components and v.components.stackable and v.components.stackable:StackSize() > 1 then --堆叠数量
                        size = v.components.stackable:StackSize()
                    end
                    if v.components and v.components.container and #v.components.container:GetAllItems() > 0 then --判断容器 如果存在物品 说明要用的 不能清理
                        break
                    end
                else
                    break --不在列表里的 不考虑处理
                end

                if countList[prefab] == nil then
                    countList[prefab] = {name = v.name, count = size, delete = 0}
                else
                    countList[prefab].count = countList[prefab].count + size
                end

                --耐久小于5%
                if v.components and v.components.finiteuses and v.components.finiteuses:GetPercent()<0.05 then
                    countList[prefab].count = countList[prefab].count - size
                    countList[prefab].delete = countList[prefab].delete + size
                    v:Remove()                    
                end

                if cleaned[prefab].max >= countList[prefab].count then
                    break
                end
                countList[prefab].count = countList[prefab].count - size
                countList[prefab].delete = countList[prefab].delete + size
                v:Remove()
            until true
        end
    end
    TheNet:Announce("清理完成")
    print("清理物品如下:预制体(名称)   极限   剩余   删除")
    for k,v in pairs(countList) do
        if v.delete > 0 then
            print(string.format("   %s(%s)   %d   %d   %d",k,v.name,cleaned[k].max,v.count,v.delete))
        end
    end
end

--可手动清理
GLOBAL.of_clean = function()
    Clean()
end