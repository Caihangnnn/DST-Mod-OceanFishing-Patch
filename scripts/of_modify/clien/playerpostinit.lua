

AddPlayerPostInit_of(function(inst)
    inst:AddComponent("clientcontrolpuppet") --客户端控制傀儡
    inst:ListenForEvent("changearea", function(inst, data) --客户端判断所在节点是否有该自定义标签 
        if data and table.contains(data.tags, "zdy_tag_of") then
            PostProcessor:EnablePostProcessEffect(PostProcessorEffects.LEFTHALFMIRROR, true)
        else
            PostProcessor:EnablePostProcessEffect(PostProcessorEffects.LEFTHALFMIRROR, false)
        end
    end)
end)
