AddPrefabPostInit("forest_network", function(inst)
    --夜晚变月圆月黑让客户端也发生变化
    inst.of_moon = net_string(inst.GUID, "worldstate.of_isfullmoon","of_isfullmoon")
    inst:ListenForEvent("of_isfullmoon",function(inst)
        if inst.of_moon:value() == "full" then
            TheWorld:PushEvent("moonphasechanged2", {moonphase = "full", waxing = true})
        elseif inst.of_moon:value() == "new" then
            TheWorld:PushEvent("moonphasechanged2", {moonphase = "new", waxing = true})
        end
    end)

    inst:AddComponent("nightmareclock") --添加梦魇时钟
    inst:AddComponent("climatechange_of") --添加天气变化组件

    -- 季节变化 仅 持续1天 第二天恢复原来的
    local seasonsdata = nil
    local function restoreseasonsdata(inst)
        if seasonsdata then
            TheWorld.net.components.seasons:OnLoad(seasonsdata)
            seasonsdata = nil
        end
        TheWorld:StopWatchingWorldState("startday", restoreseasonsdata)
    end
    inst.SetSeasons_of = function()
        if seasonsdata == nil then
            seasonsdata = inst.components.seasons:OnSave()
            TheWorld:WatchWorldState("startday", restoreseasonsdata)
        end
    end

    inst.OnSave = createHookedFunction(inst.OnSave, function(inst, data)
        if data then
            data.seasonsdata_of = seasonsdata
        end
        return true
    end)
    inst.OnLoad = createHookedFunction(inst.OnLoad, function(inst, data)
        if data and data.seasonsdata_of then
            seasonsdata = data.seasonsdata_of
            TheWorld:WatchWorldState("startday", restoreseasonsdata)
        end
        return true
    end)
end)
