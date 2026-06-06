-- -- 测试用代码,目的是使角色无视海岸限制,可以水上行走
AddPlayerPostInit_of(function(inst)
    if inst.components.drownable ~= nil then
        inst.components.drownable.enabled = false                   --关闭溺水
        inst.Physics:ClearCollisionMask()                           --Physics物理 清除碰撞遮罩
        inst.Physics:CollidesWith(COLLISION.GROUND)                 --与地面碰撞
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)              --与障碍物碰撞
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)         --与小型障碍物碰撞
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)             --与人物碰撞
        inst.Physics:CollidesWith(COLLISION.GIANTS)                 --与巨兽boss碰撞
    end
end)


--[[
--计算物品摆放位置的
local function circular()
    local x,z = 864, 192
    local num = 3
    local r = 55
    for k=1,num do
        local angle = (k * 2 * PI / num) --用弧度求角度, 例 弧度2*PI = 角度360
        print(k, r*math.cos(angle)+x, 0, r*math.sin(angle)+z)
    end
end
]]

--注册按钮触发
AddSimPostInit(function()
    TheInput:AddKeyHandler(function(key, down)
        if not down then return end --仅在按键时触发
        --推送我们的屏幕
        if key == KEY_T then
            -- circular()
        end
        --任何调试键绑定都需要CTRL
        if TheInput:IsKeyDown(KEY_CTRL) then --CTRL+R 回档
            --加载最新保存并运行最新脚本
            if key == KEY_R then
                if TheWorld.ismastersim then
                    c_reset()
                else
                    TheNet:SendRemoteExecute("c_reset()") --发送远程执行命令
                end
            end
        end
    end)
end)

-- Assets = {
--     Asset("IMAGE", "images/lavaarena_wave.tex"),
--     Asset("IMAGE", "images/wave.tex"),
--     Asset("IMAGE", "images/wave_shadow.tex"),
-- }
-- 世界设置为无海洋后，显示熔炉的海波浪
-- AddPrefabPostInit("world", function(inst)
--     inst.Map:SetUndergroundFadeHeight(0)--设置地皮高度
--     inst.Map:AlwaysDrawWaves(true) --制作波浪
--     if not TheNet:IsDedicated() then
--         local scale = 1.3
--         inst.WaveComponent:SetWaveParams(13.5 * scale, 2.8 * (scale - .15), -5) -- wave texture u repeat, forward distance between waves, world y-axis position
--         inst.WaveComponent:SetWaveSize(80 * scale, 3.5 * scale)                 -- wave mesh width and height
--         inst.WaveComponent:SetWaveMotion(.3, .5, .35)                           -- speed, horizontal travel, vertical travel

--         inst.WaveComponent:SetWaveTexture(resolvefilepath("images/lavaarena_wave.tex"))
--         inst.WaveComponent:SetWaveEffect("shaders/waves.ksh")

--         if inst.components.wavemanager then
--             inst:RemoveComponent("wavemanager") --波浪管理器
--         end

--         inst.components.ambientsound:SetReverbPreset("lava_arena")
--         inst.components.ambientsound:SetWavesEnabled(false)
--         inst:PushEvent("overrideambientsound", { tile = GROUND.IMPASSABLE, override = GROUND.LAVAARENA_FLOOR })
--         inst:PushEvent("overridecolourcube", "images/colour_cubes/night04_cc.tex")

--         inst:ListenForEvent("playeractivated", function(inst, player)
--             if ThePlayer == player then
--                 TheNet:UpdatePlayingWithFriends()
--             end
--         end)
--     end
-- end)