AddPlayerPostInit_of(function(inst)
    print("执行了吗")
    -- inst.fishnumber = net_ushortint(inst.GUID, "fishnumber") --钓鱼次数 后续可能有用
    if TheWorld.ismastersim then --仅服务器添加
        inst:AddComponent("healthlink") --单向生命链接
        inst:AddComponent("bindingoceanfishingrod") --绑定海钓竿
        inst:AddComponent("shield") --护盾组件
        inst:AddComponent("record_of") --记录事件
        inst:AddComponent("controlpuppet") --控制傀儡组件
        inst.RecordEvents_of = function(inst, data)
            if inst.components.record_of then
                inst.components.record_of:AddEvent(data.name, data.eventF, data.eventA, data.parameter)
            end
        end
    end
    if inst.components.oldager then --单向生命链接可以作用到旺达身上了
        inst.components.oldager:AddValidHealingCause("healthlink") -- 可以作用到旺达身上
    end
    --添加网络变量 用于判断是否允许更新数据
    inst.update_oceanfishin_data = net_bool(inst.GUID, "record.data", "xxof")
    --傀儡状态
    inst.puppet_isbusy = net_bool(inst.GUID, "ControlPuppet.puppet_isbusy")
    -- 进入操控状态了
    inst.onpuppet = net_bool(inst.GUID, "ControlPuppet.onpuppet")
    -- inst:ListenForEvent("xxof", function(inst, data) print("数据变化了", data) end)
    inst.update_oceanfishin_data:set(true)
    -- inst:ListenForEvent("trade", function(inst, data) 
    --     print("交易了", data.giver, data.item)
    -- end)
end)

