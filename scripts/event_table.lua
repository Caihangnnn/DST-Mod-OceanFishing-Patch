
-- 这个文件里 第1层的local 应该差不多有100个了 199个时就gg(要么拆分文件,要么分成多个块)
local data = require("event_data")

local function Passable(player)
    local x,y,z = player.Transform:GetWorldPosition()
    if TheWorld.Map:IsPassableAtPoint(x,y,z,false,true) then
        return true
    end
end

-----------------------------------------------------------------------------------------------------
local function weatherchanged(inst, player)
    if TheWorld.state.israining or TheWorld.state.issnowing then --如果在下雨或者下雪
        TheWorld:PushEvent("ms_forceprecipitation", false)
    else
        TheWorld:PushEvent("ms_forceprecipitation", true)
    end

    -- 宣告
    -- announce(player,"阴晴不定")
    player:PushEvent("accident_of", "weatherchanged")
end

local function rockcircle(inst, player)
	local items = data.rockcircle
    if TheWorld.state.iswinter then --冬天才能出冰川
        items = {"rock_ice"}
    end
	circular_of(player,6,10,items)
	-- announce(player, "岩石怪圈")
    player:PushEvent("accident_of", "rockcircle")
end

local function campfirecircle(inst, player)
	local items = {"campfire","coldfire"}
    if TheWorld.state.iswinter then
        items = {"coldfire"}
    end
	circular_of(player,2,10,items)
	-- announce(player, "营火晚会")
    player:PushEvent("accident_of", "campfirecircle")
end

local function monstercircle(inst, player)
    local items = data.monstercircle
    circular_of(player,4,math.random(4,9),items,function(inst, target)
    	if target ~= nil and inst.components.combat then
    		inst.components.combat:SuggestTarget(target) --仇恨
    	end
	end)
	-- announce(player, "生物怪圈")
    player:PushEvent("accident_of", "monstercircle")
end
local function maxwellcircle(inst, player)
    circular_of(player,2,10,{"trap_teeth_maxwell"})
    circular_of(player,2.5,14,{"trap_teeth_maxwell"})
    player:PushEvent("accident_of", "maxwellcircle")
end

local function lightningTarget(inst, player)  --天雷陷阱方法，10道雷，分布在玩家1-5单位距离范围内(1块地皮大小4*4)
    
    if not Lightning then return end 

    local pt = player:GetPosition() --不要带到其他地方
    player:StartThread(function()  --开启线程
        -- local x,y,z = player.Transform:GetWorldPosition() 
        local num = 10
        for k = 1, num do
            local r = math.random(1, 5)
            local angle = k * 2 * PI / num
            -- local pos = Point(r*math.cos(angle)+x, y, r*math.sin(angle)+z)
            local pos = pt + Vector3(r * math.cos(angle), 0, r * math.sin(angle))
            TheWorld:PushEvent("ms_sendlightningstrike", pos) --触发天雷事件(饥荒自带的降雷),提供坐标
            Sleep(.2 + math.random())
        end
    end)
    player:PushEvent("accident_of", "lightningTarget")
end

local function celestialfury(inst, player)
    player:StartThread(function()  --开启线程
        local num = 5
        for k = 1, num do 
            for j = 1, 3 do
                local x,y,z = player.Transform:GetWorldPosition()
                local r = math.random(1, 4)
                local angle = j * 2 * PI / 3
                spawnAtGround_of("alterguardian_phase2spike", r*math.cos(angle)+x,y,r*math.sin(angle)+z)
                Sleep(0.25)
            end
            local x,y,z = player.Transform:GetWorldPosition()
            local r = math.random(1, 4)
            local angle = k * 2 * PI / num
            local tt = spawnAtGround_of("alterguardian_phase3trapprojectile",r*math.cos(angle)+x,y,r*math.sin(angle)+z,function(item) item.nameoverride = "OF_CELESTIALFURY" end)
            Sleep(math.random())
        end
    end)
    player:PushEvent("accident_of", "celestialfury")
end

local function gunpowdercircle(inst, player)
    local arm = SpawnPrefab("armormarble") --替换为大理石甲
    player.components.inventory:Equip(arm)
    local x,y,z = player.Transform:GetWorldPosition()
    local num=4
    for k=1,num do
        local item = spawnAtGround_of("gunpowder", x,y,z)
        if item then
            item.nameoverride = "OF_GUNPOWDERCIRCLE"
            item.components.explosive:OnBurnt()
        end
    end
    player:PushEvent("accident_of", "gunpowdercircle")
end

local function onAddHun(inst, player) --啜食
    -- if player.components.modnewbuff then 
    --     player.components.modnewbuff:StartTimer("OnAddHun",10,0,1,0) -- 持续10秒
    -- end    
    player:AddDebuff("buff_sipping_of", "buff_sipping_of")
    player:PushEvent("accident_of", "onAddHun")
end

local function onAddSan(inst, player) --降智
    -- if player.components.modnewbuff then
    --     player.components.modnewbuff:StartTimer("OnAddSan",10,0,1,0) -- 持续10秒
    -- end    
    player:AddDebuff("buff_reducesan_of", "buff_reducesan_of")
    player:PushEvent("accident_of", "onAddSan")
end

local function onAddHp(inst, player) --流血
    -- if player.components.modnewbuff then
    --     player.components.modnewbuff:StartTimer("OnAddHp",10,0,1,0) -- 持续10秒
    -- end    
    player:AddDebuff("buff_bleed_of", "buff_bleed_of")
    player:PushEvent("accident_of", "onAddHp")
end

local shadow_boss = {"shadow_rook","shadow_knight","shadow_bishop"}
local function shadow_level(inst, player) --暗影陷阱 暗影基佬随机等级 
    if not inspectProtect(player) then return end
    local shadow = SpawnPrefab(shadow_boss[math.random(#shadow_boss)])
    shadow.Transform:SetPosition(player.Transform:GetWorldPosition())
    shadow:DoTaskInTime(0,function(inst)
        shadow:LevelUp(math.random(3))
    end)
    player:PushEvent("accident_of", "shadow_level")
end

local function healthlink(inst, player)
    -- print("触发事件的玩家",player)
    if player.components.healthlink == nil then
        player:AddComponent("healthlink")
    end
    player.components.healthlink:Start()
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "healthlink")
end

local function caveinobstacle(inst, player) -- 柱！柱！柱！
    -- player:StartThread(function()  --开启线程
    --     for i=1, math.random(4,6) do
    --         player:DoTaskInTime(0.75+math.random()*.5, function(inst)
    --             local x,y,z = inst.Transform:GetWorldPosition()
    --             local item = spawnAtGround_of("ruins_cavein_obstacle",x+math.random()*2,0,y+math.random()*2, true)
    --             if not item then return end 
    --             item.fall(item,Vector3(inst.Transform:GetWorldPosition()))
    --         end)
    --     end
    -- end)   
    SpawnGrowTheGround(player, 0.45,
        {{chance = 0.5, item = "ruins_cavein_obstacle", fn = function(i,x,y,z) i:fall(Vector3(x,y,z)) end}}, 
        math.random(4,6), 2.25)
    player:PushEvent("accident_of", "caveinobstacle")
end

local function sporecloud(inst, player) -- 多重孢子云
    player:StartThread(function()  --开启线程
        for i=1, math.random(1,3) do
            player:DoTaskInTime(1+(math.random()*2), function(inst)
                local sporecloud = SpawnPrefab("sporecloud")
                sporecloud.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end)
        end
    end)
    player:PushEvent("accident_of","sporecloud")
end

local NO_REMOVE = {"player","INLIMBO","irreplaceable","shadowcreature","farm_plant","_combat", "donotautopick",
                 "locomotor","boat","FX","NOBLOCK","NOCLICK","multiplayer_portal","strong_of","DECOR" }
local function removeitems(inst, player) --清理物品
    local x,y,z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z,10,nil,NO_REMOVE)
    if ents ~= nil then
        for k,v in pairs(ents) do
            v:Remove()
        end
    end
    player:PushEvent("accident_of", "removeitems")
end

local function hedgehounds(inst, player) --蔷薇陷阱
    circular_of(player,4,math.random(4,5),{"hedgehound_bush"},function(inst, target)
        if target ~= nil and inst.components.combat then
            inst.components.combat:SuggestTarget(target) --仇恨
        end
    end)
    circular_of(player,6,math.random(4,6),{"hedgehound"},function(inst, target)
        if target ~= nil and inst.components.combat then
            inst.components.combat:SuggestTarget(target) --仇恨
        end
    end)

    player:PushEvent("accident_of", "hedgehounds")
end

local function ghost_circle(inst, player) --鬼魂陷阱
    local x, y, z = player.Transform:GetWorldPosition()
    local num = 5
    for k=1,num do
        local angle = k * 2 * PI / num
        local item = spawnAtGround_of("ghost", 2*math.cos(angle)+x, y, 2*math.sin(angle)+z, true)
        if player ~= nil and item ~= nil then
            item.components.combat:SuggestTarget(player)
        end
    end

    player:PushEvent("accident_of", "ghost_circle")
end

local function lethargy(inst, player) --昏睡陷阱
    local x, y, z = player.Transform:GetWorldPosition()
    spawnAtGround_of("spore_small",x,y,z)
    player:StartThread(function()
        local num = 15
        for k=1,num do
            local x,y,z = player.Transform:GetWorldPosition()
            local r = math.random(2, 2)
            local angle = math.random(0,360)--k * 2 * PI / num
            spawnAtGround_of("gestalt_alterguardian_projectile", r*math.cos(angle)+x, y, r*math.sin(angle)+z)
            Sleep(math.random(20, 100)*0.01)
        end
    end)

    player:PushEvent("accident_of", "lethargy")
end

local function sanityempty(inst, player) --理智全无
    local arm = SpawnPrefab("purpleamulet") --替换为噩梦护符
    player.components.inventory:Equip(arm)
    player.components.sanity:DoDelta(-50)

    player:PushEvent("accident_of", "sanityempty")
end
-- 饥饿为0 给个毒火鸡正餐 加血变为扣血
local function turkey(inst, player) --毒计？鸡
    local x, y, z = player.Transform:GetWorldPosition()
    local item = spawnAtGround_of("turkeydinner",x,y,z)
    if item then item.components.edible.healthvalue = -20 end
    player.components.hunger:DoDelta(-9999)

    player:PushEvent("accident_of", "turkey")
end

local function dropequip(inst, player) --卸甲归田
    for k,v in pairs(player.components.inventory.equipslots) do
        player.components.inventory:DropItem(v)
    end

    player:PushEvent("accident_of", "dropequip")
end

-- 随机一样库存中的物品 藏到 宝藏里
local function stashloot(inst, player) --遗失宝藏
    local items = {}
    for k = 1, player.components.inventory.maxslots do --全部遍历一遍，获取存在的物品槽位
        local v = player.components.inventory.itemslots[k] 
        if v ~= nil then
            table.insert(items, v)
        end
    end
    if #items > 0 then --随机一项
        local item = items[math.random(#items)]
        if TheWorld.components.piratespawner then
            TheWorld.components.piratespawner:StashLoot(item)
            TheNet:Announce(player:GetDisplayName().."遗失了 "..(item:GetDisplayName() or item))
        end        
    end
    local x, y, z = player.Transform:GetWorldPosition()
    spawnAtGround_of("stash_map",x,y,z)

    player:PushEvent("accident_of", "stashloot")
end

local function seasonchange(inst, player)
    if TheWorld.net.SetSeasons_of then
        -- 记录下当天季节情况 第2天恢复回去
        TheWorld.net.SetSeasons_of()
    end
    local names = {"spring","summer","autumn","winter"}
    local currentseason = TheWorld.state.season
    if table.contains(names, currentseason) then
        RemoveByValue(names, currentseason)
    end
    local index = math.random(#names)
    TheWorld:PushEvent("ms_setseason", names[index])

    player:PushEvent("accident_of", "seasonchange")
end

local function shadowthrall(inst, player)
    if not inspectProtect(player) then return end
    local x, y, z = player.Transform:GetWorldPosition()
    local hands = spawnAtGround_of("shadowthrall_hands", x+6,y,z+6, true)
    local horns =spawnAtGround_of("shadowthrall_horns", x-3,y,z+5.2, true)
    local wings =spawnAtGround_of("shadowthrall_wings", x-3,y,z-5.2, true)
    if hands.components.entitytracker ~= nil then
        hands.components.entitytracker:TrackEntity("horns", horns)
        hands.components.entitytracker:TrackEntity("wings", wings)
    end
    if horns.components.entitytracker ~= nil then
        horns.components.entitytracker:TrackEntity("hands", hands)
        horns.components.entitytracker:TrackEntity("wings", wings)
    end
    if wings.components.entitytracker ~= nil then
        wings.components.entitytracker:TrackEntity("hands", hands)
        wings.components.entitytracker:TrackEntity("horns", horns)
    end
    player:PushEvent("accident_of", "shadowthrall")
end


local function spawnwaves(inst, player, target)
    SpawnAttackWaves(
        target:GetPosition(),
        nil,
        nil,
        6,
        360,
        4,
        nil,
        2,
        nil
    )

    player:PushEvent("accident_of", "spawnwaves")
end
local function deciduous(inst, player)
    player:StartThread(function()  --开启线程
        circular_of(player,4,10,{"deciduous_root"},function(item) item.nameoverride = "OF_DECIDUOUS" end,true)
        Sleep(.5 + math.random())
        circular_of(player,8,18,{"deciduous_root"},function(item) item.nameoverride = "OF_DECIDUOUS" end,true)
        Sleep(.5 + math.random())
        circular_of(player,4,10,{"deciduous_root"},function(item) item.nameoverride = "OF_DECIDUOUS" end,true)
    end)

    player:PushEvent("accident_of", "deciduous")
end

local function refusefish(inst, player)
    -- player:AddTag("refusefish")
    -- player:DoTaskInTime(30*2, function(player)
    --     player:RemoveTag("refusefish")
    -- end)
    player:AddDebuff("buff_refusefish_of", "buff_refusefish_of")
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "refusefish")
end

-- 移形换影 互相交换位置 
local function transformation(inst, player)
    local closestPlayer = {}
    for i, v in ipairs(AllPlayers) do
        if v and v.entity:IsVisible() and v.userid ~= player.userid and Passable(v) then --目标不是自己 且目标没有链接自己
            table.insert(closestPlayer,v)
        end
    end
    if #closestPlayer > 0 then
        local target = closestPlayer[math.random(#closestPlayer)]
        local target_x, target_y, target_z = target.Transform:GetWorldPosition()
        local x, y, z = player.Transform:GetWorldPosition()
        player.Transform:SetPosition(target_x, target_y, target_z)
        target.Transform:SetPosition(x, y, z)
    else
        --还是算了 【没有直接传送到大门】
    end
    player:PushEvent("accident_of", "transformation")
end

-- 兔吃曼草 背包里兔子吃曼德拉草
local function rabbiteater(inst, player)
    local tz = SpawnPrefab("rabbit")
    tz.Transform:SetPosition(player.Transform:GetWorldPosition())
    local md = SpawnPrefab("mandrake")
    tz.components.eater:Eat(md, player)
    player.components.inventory:GiveItem(tz)
    player:PushEvent("accident_of", "rabbiteater")
end

--奇怪的雨
local function debrisitems(inst, player)
    SpawnDebrisLoots(player, 0.1, data.debrisitems, math.random(20,35), 20) --5格地皮范围内
    player:PushEvent("accident_of", "debrisitems")
end

--升天
local function ascension(inst, player)
    local x, y, z = player.Transform:GetWorldPosition()
    player.Transform:SetPosition(x, 35, z)
    if player.components.drownable ~= nil then
        player.components.drownable.enabled = false --关闭溺水
    end
    player.Physics:SetDamping(.99)
    player:AddTag("refusefish") --禁止钓鱼 防止发生奇怪的事情
    player.ascensiontask = player:DoPeriodicTask(FRAMES, function(player) 
        local x, y, z = player.Transform:GetWorldPosition()
        if y <= 0.35 then
            if player.components.drownable ~= nil then --开启溺水
                player.components.drownable.enabled = true
            end
            player.Physics:SetDamping(5)
            player:RemoveTag("refusefish")
            player.ascensiontask:Cancel()
            player.ascensiontask = nil
        else
            if y <= 2 then
                player.Physics:SetMotorVel(0, 0, 0)
            end
        end
    end)
    player:PushEvent("accident_of", "ascension")
end
-- 大范围冰冻
local function allfreezable(inst, player, target)
    local x, y, z = target.Transform:GetWorldPosition()
    local function onfreeze(inst, v)
        if not v:IsValid() then
            return
        end

        if v.components.burnable ~= nil then
            if v.components.burnable:IsBurning() then--灭火
                v.components.burnable:Extinguish()
            elseif v.components.burnable:IsSmoldering() then
                v.components.burnable:SmotherSmolder()
            end
        end

        if v.components.freezable ~= nil then
            v.components.freezable:AddColdness(10,10) --冻结层数10 冻结时间10s
            v.components.freezable:SpawnShatterFX()
        end
    end
    local ents = TheSim:FindEntities(x, y, z, 4*6, nil, {"crabking_claw","crabking", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO"})
    for i,v in pairs(ents)do
        onfreeze(inst, v)
    end
    local fx = SpawnPrefab("crabking_ring_fx")
    fx.Transform:SetPosition(x, y, z)
    fx.Transform:SetScale(1.5,1.5,1.5)
    player:PushEvent("accident_of", "allfreezable")
end
-- 蚁狮陷阱
local function sand(inst, player, target)
    circular_of(player,6,14,{"sandblock"})
    SpawnGrowTheGround(player, 0.2,
        {{chance = 0.5, item = "sandspike", function(item) item.nameoverride = "OF_SAND" end},
        {chance = 0.001, item = "sandblock"}}, 
        math.random(20,35), 6)
    player:PushEvent("accident_of", "sand")
end
-- 超多的陷阱 最好办法在船上等待一下
local function supermany(inst, player, target)
    SpawnGrowTheGround(player, 0.3,
        {
            {chance = 0.6, item = "sandspike"},--沙刺
            {chance = 0.5, item = "houndfire"},--火
            {chance = 0.3, item = "sandblock"},--沙堡
            {chance = 0.5, item = "sporecloud"},--孢子云
            {chance = 0.5, item = "tornado"},--龙卷风
            {chance = 0.5, item = "deciduous_root"},--桦栗树 鞭子
            {chance = 0.3, item = "fused_shadeling_quickfuse_bomb"},--绝望螨 不分裂
            {chance = 0.5, item = "mushroombomb"}, --炸弹蘑菇
            {chance = 0.6, item = "mushroombomb_dark"}, --悲惨的炸弹蘑菇
            {chance = 0.5, item = "moonspider_spike"}, --月亮蜘蛛钉
            {chance = 0.5, item = "trap_teeth_maxwell"}, --麦斯威尔的犬牙陷阱
            {chance = 0.4, item = "beemine_maxwell"}, --麦斯威尔的蚊子陷阱
            {chance = 0.5, item = "wave_med"}, --海浪
            {chance = 0.3, item = "ruins_cavein_obstacle", fn = function(i,x,y,z) i.fall(i,Vector3(x,y,z)) end}, --块状废墟
            {chance = 0.4, item = "bigshadowtentacle"}, --守护者暗影触手
            {chance = 0.2, item = "shadowmeteor"}, --流星
            {chance = 0.4, item = "fossilspike2"}, --化石骨刺
            {chance = 0.3, item = "fossilspike"}, --化石笼子
            {chance = 0.1, item = "moonstorm_spark"}, --月熠 alterguardian_phase3trapprojectile
            {chance = 0.1, item = "spore_moon"}, --月亮孢子
            {chance = 0.3, item = "alterguardian_phase3trapprojectile"}, --落下的启迪陷阱
            {chance = 0.3, item = "alterguardian_laser", fn = function(i,x,y,z) i:Trigger(0.5) end}, --激光
            {chance = 0.01, item = "miasma_cloud"},--瘴气
            {chance = 0.1, item = "antlion_sinkhole"},--坑
        }, 
        math.random(30,45), 8)
    player:PushEvent("accident_of", "supermany")
end

-- 青蛙雨 有概率掉鱼人
local function frograin(inst, player, target)
    SpawnDebrisLoots(player, 0.75, {
        {chance = 5, item = "frog"},--青蛙
        {chance = 0.5, item = "merm"},--鱼人
        {chance = 0.25, item = "lunarfrog"},--明眼青蛙
    }, math.random(20,35), 25) --6格地皮范围内
    player:PushEvent("accident_of", "frograin")
end
-- 相控阵激光 调整为相对好躲避 向后移动 小心船体
local function alterguardian_laser(inst, player, target)
    local al = SpawnPrefab("alterguardian_laser")
    al.Transform:SetPosition(player.Transform:GetWorldPosition())
    al.nameoverride = "OF_ALTERGUARDIAN_LASER"
    al:Trigger(1.25)
    circular_of(player,4,15,{"alterguardian_laser"},function(inst2,p,i) inst2:Trigger(i*FRAMES) inst2.nameoverride = "OF_ALTERGUARDIAN_LASER" end, true, false, 0.7)
    circular_of(player,2,10,{"alterguardian_laser"},function(inst2,p,i) inst2:Trigger(i*FRAMES) inst2.nameoverride = "OF_ALTERGUARDIAN_LASER" end, true, true, 0.7, math.random()*360)
    player:PushEvent("accident_of", "alterguardian_laser")
end
local function mushroombomb(inst, player)
    circular_of(player,4,math.random(7,11),{"mushroombomb","mushroombomb_dark"},function(inst2) inst2.nameoverride = "OF_MUSHROOMBOMB" end,true)

    player:PushEvent("accident_of", "mushroombomb")
end

local function mushroom(inst, player)
    circular_of(player,10,math.random(7,11),{"blue_mushroom","green_mushroom","red_mushroom"},nil)

    player:PushEvent("accident_of", "mushroombomb")
end

-- 骨牢骨刺
local function fossilspike(inst, player, target)
    circular_of(player,4,8,{"fossilspike"},nil, true)
    circular_of(player,3.5,15,{"fossilspike2"},function(inst2,p,i) inst2:RestartSpike(i*FRAMES) inst2.nameoverride = "OF_FOSSILSPIKE" end, true, false, math.random(45,75)*.01,math.random()*360,math.random(-20,20)*.1,math.random(-20,20)*.1)
    circular_of(player,1.75,10,{"fossilspike2"},function(inst2,p,i) inst2:RestartSpike(i*FRAMES) inst2.nameoverride = "OF_FOSSILSPIKE" end, true, true, math.random(45,75)*.01,math.random()*360,math.random(-10,10)*.1,math.random(-10,10)*.1)
    player:PushEvent("accident_of", "alterguardian_laser")
end
-- 区域异常
local function areaaware_abnormal(inst, player, target)
    local x, y, z = player.Transform:GetWorldPosition()
    local node, node_index = TheWorld.Map:FindVisualNodeAtPoint(x, y, z)
    if node == nil or node_index <= 0 then return end
    if node.tags == nil then node.tags = {} end

    local tag = "lunacyarea"
    if TheWorld.state.issummer then --是不是夏天
        tag = "sandstorm"
    end

    if table.contains(node.tags,tag) then
        return 
    end
    local id = TheWorld.topology.ids[node_index]
    --钓起者移动一下下 就可以更新了。至于其他玩家 只能是离开该区域再返回才能起效果
    table.insert(node.tags, tag)
    TheWorld.components.maptagchange:StartTimer(id, 60*4, tag) --对改节点的地图标签进行管理
    --全员更新一下
    -- for k,v in ipairs(AllPlayers) do
    --     v.components.areaaware.current_area = -1
    -- end

    player:PushEvent("accident_of", "areaaware_abnormal")
end
-- 变大
local function super_big(inst, player, target)
    -- if player.super_big_task ~= nil then player.super_big_task:Cancel() end
    -- player.super_big_task = player:DoTaskInTime(60,function(word)
    --     player.super_big_task:Cancel()
    --     player.super_big_task = nil
    --     player.Transform:SetScale(1,1,1)
    -- end)
    -- player.Transform:SetScale(2.5,2.5,2.5)
    -- SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:AddDebuff("buff_big_of", "buff_big_of")
    player:PushEvent("accident_of", "super_big")
end

-- local must_have_tags = {"player","INLIMBO","DECOR", "boat","FX","NOBLOCK","NOCLICK","playerghost"}
local cant_have_tags = {"player","INLIMBO","DECOR", "boat","FX","NOBLOCK","NOCLICK","playerghost","CLASSIFIED","rotatableobject"}
local TARGET_ONEOF_TAGS = { "animal", "character", "monster", "shadowminion", "smallcreature" }
local function p_combat(inst, player)
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4*10, nil, cant_have_tags,TARGET_ONEOF_TAGS) --10地皮范围内
    local h = 0
    local target = nil
    for i, v in ipairs(ents) do
        if v and v.components.health and (v.components.health.currenthealth > h) then --找一下血厚的
            h = v.components.health.currenthealth
            target = v
        end
    end
    if target then
        local pos = target:GetPosition()
        local offset = FindWalkableOffset(pos, 2*PI*math.random(), 2, 8, true, true, nil, false, true)
        if offset ~= nil then --周围能够有位置传送存在
            player.Transform:SetPosition(offset.x + pos.x,0,offset.z + pos.z)
        end
        -- 能战斗就瞄准
        if target.components.combat then
            target.components.combat:SuggestTarget(player)
        end
    end
    player:PushEvent("accident_of", "p_combat")
end

-- 触手陷阱
local function tentacle_kl(inst, player)
    local items = {"tentacle","bigshadowtentacle"}
    circular_of(player,4,9,items)

    player:PushEvent("accident_of", "tentacle_kl")
end

-- 蝙蝠军团 增强的蝙蝠
local function bat_eye(inst, player)
    local items = {"bat"}
    circular_of(player,4,6,items,function(b,target)
        if b.components.acidinfusible then
            b.components.acidinfusible:OnInfuse() --改为被酸化后的状态
        end
        if target ~= nil and b.components.combat then
            b.components.combat:SuggestTarget(target) --仇恨
        end
    end,true)

    player:PushEvent("accident_of", "bat_eye")
end

-- 变小
local function super_small(inst, player, target)
    -- if player.super_big_task ~= nil then player.super_big_task:Cancel() end
    -- player.super_big_task = player:DoTaskInTime(60,function(word)
    --     player.super_big_task:Cancel()
    --     player.super_big_task = nil
    --     player.Transform:SetScale(1,1,1)
    -- end)
    -- player.Transform:SetScale(0.25,0.25,0.25)
    -- SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:AddDebuff("buff_small_of", "buff_small_of")
    player:PushEvent("accident_of", "super_small")
end
-- 杂草禁锢
local function weed_imprison(inst, player)
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, nil, {"playerghost","plantkin"},{"player","animal", "character", "monster"}) --5地皮范围内
    if ents~=nil then
        for i, target in ipairs(ents) do
            local islarge = target:HasTag("largecreature")
            local r = target:GetPhysicsRadius(0) + (islarge and 1.4 or .4)
            local num = islarge and 12 or 6
            circular_of(target,r,num,{"ivy_snare"},function(snare,target)
                snare.target = target
                snare.target_max_dist = r + 1.0
                snare:RestartSnare(.2 + math.random(-1,1) * .2)
                snare:DoTaskInTime(5,function() snare.components.health:Kill() end)
            end)
        end
    end

    player:PushEvent("accident_of", "weed_imprison")
end
--一拳小超人
local function onefistsuperman(inst, player)
    local function onattackJ(inst, data)
        -- if data.weapon ~= nil then return end --必须赤手空拳打
        data.target.components.health:DoDelta(-999, nil, "OF_ONEFISTSUPERMAN", nil, inst)
        player:RemoveEventCallback("onattackother", onattackJ)
    end
    player:ListenForEvent("onattackother", onattackJ)
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "onefistsuperman")
end
--天使赐福
local function angel_blessing(inst, player)
    player.components.health:DoDelta(999)
    player.components.sanity:DoDelta(999)
    player.components.hunger:DoDelta(999)
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "angel_blessing")
end
--还你飘飘拳
local function returnonattack(inst, player)
    local function onattackA(inst, data)
        -- if data.weapon ~= nil then return end --必须赤手空拳打
        data.target.components.health:DoDelta(999)
        player:RemoveEventCallback("onattackother", onattackA)
    end
    player:ListenForEvent("onattackother", onattackA)
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "returnonattack")
end

local function deltapenalty(inst, player)
    -- 获取默认扣除血上限的数据 溺水的时候也是这样
    local tunings = TUNING.DROWNING_DAMAGE[string.upper(player.prefab)] or TUNING.DROWNING_DAMAGE[player:HasTag("player") and "DEFAULT" or "CREATURE"]
    if tunings.HEALTH_PENALTY ~= nil then
        player.components.health:DeltaPenalty(tunings.HEALTH_PENALTY)
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "deltapenalty")
end

local function onlifeinjector(inst, player)
    -- 强心针的效果
    if player.components.health ~= nil then
        player.components.health:DeltaPenalty(TUNING.MAX_HEALING_NORMAL)
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "onlifeinjector")
end  
local function sanityaura(inst, player)
    if player.components.sanityaura then return end --存在理智光环 可能是mod角色自动特性 或者 已经钓到过 故不用管
    
    player.sanityaura_task = player:DoTaskInTime(60,function(word)
        player.sanityaura_task:Cancel()
        player.sanityaura_task = nil
        player:RemoveComponent("sanityaura")
        player.AnimState:OverrideMultColour(1, 1, 1, 1)
    end)
    player.AnimState:OverrideMultColour(0.15, 0.15, 0.15, 1)
    player:AddComponent("sanityaura")
    player.components.sanityaura.aurafn = function() return -100/15 end
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    player:PushEvent("accident_of", "sanityaura")
end  
local function research(inst, player)

    if player and player.components.builder then
        player.components.builder:GiveTempTechBonus({SCIENCE = 2, MAGIC = 2, SEAFARING = 2})
    end
    local fx = SpawnPrefab(player.components.rider ~= nil and player.components.rider:IsRiding() and "fx_book_research_station_mount" or "fx_book_research_station")
    fx.Transform:SetPosition(player.Transform:GetWorldPosition())
    fx.Transform:SetRotation(player.Transform:GetRotation())

    player:PushEvent("accident_of", "research")
end
local function temperature(inst, player)

    if player and player.components.temperature then
        player.components.temperature:SetTemperature(TheWorld.state.temperature)
    end

    player:PushEvent("accident_of", "temperature")
end


local function mindcontrol(inst, player)
    if player.mindcontrol_task then return end --不希望短时间钓起两次同时影响
    if player.components.debuffable == nil then
        player:AddComponent("debuffable")
    end    
    local tiem = 6
    local function IsCrazyGuy(guy)
        local sanity = guy ~= nil and guy.replica.sanity or nil
        return sanity ~= nil and sanity:GetPercentNetworked() <= (guy:HasTag("dappereffects") and TUNING.DAPPER_BEARDLING_SANITY or TUNING.BEARDLING_SANITY)
    end
    local function control(p) 
        if tiem <= 0 or p.components.health:IsDead() or p:HasTag("playerghost") or not p.entity:IsVisible() then
            p.mindcontrol_task:Cancel()
            p.mindcontrol_task = nil
            p:RemoveDebuff("mindcontroller") 
            return
        end
        p:AddDebuff("mindcontroller", "mindcontroller")
        -- 根据精神大小来调整控制时长 精神值高就减少的快一点
        tiem = tiem - FRAMES*(IsCrazyGuy(p) and 1 or 2) 
    end
    --刷帧控制
    player.mindcontrol_task = player:DoPeriodicTask(FRAMES, control)

    player:PushEvent("accident_of", "mindcontrol")
end

local function twinmanager(inst, player)
    if not inspectProtect(player) then return end
    local twinmanager = SpawnPrefab("twinmanager") --当双眼都死了、删除了，就会删除自己
    twinmanager.Transform:SetPosition(player.Transform:GetWorldPosition())
    twinmanager:PushEvent("arrive", player)
    -- twinmanager:ListenForEvent("onremove",function()print("双子魔眼控制器删除了")end)
    player:PushEvent("accident_of", "twinmanager")
end

local function small_forest(inst, player)
    circular_of(player,5,10,{"evergreen","deciduoustree_normal","moon_tree_tall","cave_banana_tree","mushtree_medium","mushtree_small","mushtree_tall","mushtree_moon","mushroomsprout","mushroomsprout_dark","oceantree"})
    player:PushEvent("accident_of", "twinmanager")
end

local function automatic_weapon(inst, player, target, parameter)
    local t = parameter or {"glasscutter", "nightsword","spear_wathgrithr","spear","tentaclespike","ruins_bat"}
    local item = SpawnPrefab(t[math.random(#t)]) --默认玻璃刀
    GiveLife(item, player)

    player:PushEvent("accident_of", {"automatic_weapon", parameter})
end

local function equip_recovery(inst, player) --物品恢复
    for k,v in pairs(player.components.inventory.equipslots) do --装备栏
        if v.components.finiteuses and v.components.finiteuses:GetPercent() < 1 then --耐久补满
            v.components.finiteuses:SetPercent(1)
        end
        if v.components.fueled and v.components.fueled:GetPercent() < 1 then --燃料补满
            v.components.fueled:SetPercent(1)
        end
        if v.components.perishable and v.components.perishable:GetPercent() < 1 then --新鲜补满
            v.components.perishable:SetPercent(1)
        end
        if v.components.armor and v.components.armor:GetPercent() < 1 then --护甲耐久补满
            v.components.armor:SetPercent(1)
        end
    end
    for k,v in pairs(player.components.inventory.itemslots) do --库存栏
        if v.components.finiteuses and v.components.finiteuses:GetPercent() < 1 then --耐久补满
            v.components.finiteuses:SetPercent(1)
        end
        if v.components.fueled and v.components.fueled:GetPercent() < 1 then --燃料补满
            v.components.fueled:SetPercent(1)
        end
        if v.components.perishable and v.components.perishable:GetPercent() < 1 then --新鲜补满
            v.components.perishable:SetPercent(1)
        end
        if v.components.armor and v.components.armor:GetPercent() < 1 then --护甲耐久补满
            v.components.armor:SetPercent(1)
        end
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())

    player:PushEvent("accident_of", "equip_recovery")
end

local function small_boss(inst, player)
    if not inspectProtect(player) then return end
    local pos = FindNearbyLand(player:GetPosition(),8) --两地皮范围内陆地位置
    if pos ~= nil then --没有可生成位置就不要生成出来
        local t = {"moose", "dragonfly", "bearger", "deerclops"}
        local boss = SpawnPrefab(t[math.random(#t)])
        boss:AddTag("small_boss")
        boss.Transform:SetPosition(pos:Get())
        boss.components.health:SetMaxHealth(boss.components.health.maxhealth/2) --生命值上限减少一半
        boss.components.combat:SetRange(boss.components.combat.attackrange*.5)--尝试减少攻击距离
        boss.Transform:SetScale(.5,.5,.5) --体型减少一半
        SpawnPrefab("collapse_small").Transform:SetPosition(pos:Get())
        if boss.components.groundpounder then --熊大、龙蝇拍地板 增加地陷
            local old_groundpoundFn = boss.components.groundpounder.groundpoundFn
            boss.components.groundpounder.groundpoundFn = function(inst)
                if old_groundpoundFn then old_groundpoundFn(boss) end
                local hole = SpawnPrefab("antlion_sinkhole")
                hole.components.unevenground.radius = 6
                hole.Transform:SetPosition(boss.Transform:GetWorldPosition())
                local scale = hole.components.unevenground.radius*.5/2.2
                hole.Transform:SetScale(scale, scale, scale)
                -- hole:DoTaskInTime(10, hole.Remove)
            end
        end
        boss.freezepower = 3 -- 巨鹿冰冻层数增加1
        boss.TransformFire = function(inst) boss.enraged = true boss.can_ground_pound = true end --龙蝇激怒
        boss.TransformNormal = function(inst) boss.enraged = false boss.can_ground_pound = false end --龙蝇冷静
    end
    player:PushEvent("accident_of", "small_boss")
end

local function groundpounder(inst, player)
    MakeGroundPounder(player:GetPosition(), {
        numRings = 2,               --波数
        ringDelay = 1,              --每波间隔 1s时间是可以逃离第2波伤害
        destroyer = true,           --是否破坏周围
        burner = true,              --是否点燃周围
        ejection = true,            --伤害时是否击飞武器
        damage = 10,                --每波造成的伤害值
        radiusStepDistance = 2,     --半径步长 半格地皮
        damageRings = 2,            --伤害半径
        destructionRings = 1,       --破坏半径
        platformPushingRings = 1,   --推船半径
        inventoryPushingRings = 2,  --地面物品震飞半径
        name = "【地震波】",
    })
    player:PushEvent("accident_of", "groundpounder")
end

local function glacier(inst, player, target)
    SpawnIceFx(target:GetPosition(), player)
    player:PushEvent("accident_of", "glacier")
end


local function moonstorms(inst, player, target)
    -- 此事件不存在 且 原版的也不存在时执行
    if TheWorld.of_moonstorms_task == nil and TheWorld.components.messagebottlemanager.startstormtask == nil then
        TheWorld.of_moonstorms_task = TheWorld:DoTaskInTime(6*4,function(word)
            TheWorld.of_moonstorms_task:Cancel()
            TheWorld.of_moonstorms_task = nil
            TheWorld:PushEvent("ms_stopthemoonstorms")
            TheWorld.components.moonstormmanager.of_moonstorm = nil
            TheWorld.components.moonstormmanager:RestartMoonstorm_OF()
        end)    
        --防止保存成永久的 需要钓到天体并击杀才结束。
        --先设置 再触发。那么 of_moonstorm 属性就可以确定是事件
        TheWorld.components.moonstormmanager.of_moonstorm = true 
        TheWorld:PushEvent("ms_startthemoonstorms")
        player:PushEvent("accident_of", "moonstorms")
    end
end

--
local function deer_fire_circle(inst, player) -- 无眼鹿火
    player:StartThread(function()  --开启线程
        for i=1, 1 do
            local deer_fire_charge = SpawnPrefab("deer_fire_charge")
            deer_fire_charge.Transform:SetPosition(inst.Transform:GetWorldPosition())
            player:DoTaskInTime(1, function(inst)
                deer_fire_charge:Remove()
                local deer_fire_circle = SpawnPrefab("deer_fire_circle")
                deer_fire_circle.Transform:SetPosition(inst.Transform:GetWorldPosition())
                deer_fire_circle:DoTaskInTime(5, function(deer_fire_circle) --特效存在时间
                    deer_fire_circle:Remove()
                end)
            end)
        end
    end)
    player:PushEvent("accident_of","deer_fire_circle")
end
local function deer_ice_circle(inst, player) -- 无眼鹿冰
    player:StartThread(function()  --开启线程
        for i=1, 1 do
            local deer_ice_charge = SpawnPrefab("deer_ice_charge")
            deer_ice_charge.Transform:SetPosition(inst.Transform:GetWorldPosition())
            player:DoTaskInTime(1, function(inst)
                deer_ice_charge:Remove()
                local deer_ice_circle = SpawnPrefab("deer_ice_circle")
                deer_ice_circle.Transform:SetPosition(inst.Transform:GetWorldPosition())
                deer_ice_circle:DoTaskInTime(5, function(deer_ice_circle) --特效存在时间
                    deer_ice_circle:Remove()
                end)
            end)
        end
    end)
    player:PushEvent("accident_of","deer_ice_circle")
end
local function fire_ice_charge(inst, player) --一圈无眼鹿冰火
    local x0, y0, z0 = player.Transform:GetWorldPosition()
    local radius = 7.5 + math.random(0, 4)
    for i = 1, 8 do 
        local x = x0 + radius * (math.sin(math.rad((359 / 8 * i) - 180)))
        local z = z0 + radius * (math.cos(math.rad((359 / 8 * i) - 180)))
        local y = y0
        local flag = 1 % 2
    if i % 2 == flag then
        local fire_charge = SpawnPrefab("deer_fire_charge")
        fire_charge.Transform:SetPosition(x, y, z)
        fire_charge:DoTaskInTime(1, function(fire_charge) --释放时间
            fire_charge:Remove()
            local fire_circle = SpawnPrefab("deer_fire_circle")
            fire_circle.Transform:SetPosition(x, 0, z)
            fire_circle:DoTaskInTime(7, function(fire_circle) --特效存在时间
                fire_circle:Remove()
            end)
        end)
    else
    local ice_charge = SpawnPrefab("deer_ice_charge")
                ice_charge.Transform:SetPosition(x, y, z)
                ice_charge:DoTaskInTime(0.1, function(ice_charge) --释放时间
                    ice_charge:Remove()
                local ice_circle = SpawnPrefab("deer_ice_circle")
                ice_circle.Transform:SetPosition(x, 0, z)
                ice_circle:DoTaskInTime(7.8, function(ice_circle) --特效存在时间
                    ice_circle:Remove()
                end)
            end)
        end
    end
    player:PushEvent("accident_of", "fire_ice_charge")
end
local function shadowmeteor(inst, player) --流星雨
    SpawnGrowTheGround(player, 0.35,
        {
            {chance = 0.6, item = "shadowmeteor"},
            {chance = 0.5, item = "shadowmeteor"},
            {chance = 0.3, item = "shadowmeteor"},
        }, 
        math.random(5,16), 8)
    player:PushEvent("accident_of", "shadowmeteor")
end
local function spawnendhounds(inst, player) -- 猎犬来袭
    local num_p = 3
    for n = 1, math.random(3) do
        for i, v in ipairs(AllPlayers) do
            if v ~= player and num_p > 0 then
                num_p = num_p - 1
                TheWorld.components.hounded:ForceReleaseSpawn(v)
            end
        end
    end
    TheWorld.components.hounded:ForceReleaseSpawn(player)
    -- if TheWorld.components.hounded ~= nil then
    --     TheWorld.components.hounded:ForceNextWave()
    -- end
end
local function goldnuggets(inst, player)
    SpawnDebrisLoots(player, 0.1, {
        {chance = 0.1, item = "goldnugget"},--黄金
        {chance = 0.2, item = "goldnugget"},--黄金
        {chance = 0.3, item = "goldnugget"},--黄金
        {chance = 0.4, item = "goldnugget"},--黄金
    }, math.random(20,35), 28) --7格地皮范围内
    player:PushEvent("accident_of", "debrisitems")
end

local function monkeyprojectile(inst, player)
    SpawnGrowTheGround(player, 0.75, {{chance = 0.6, item = "monkeyprojectile", fn = function(item)
        item.components.projectile:Throw(item, player)
    end}}, math.random(4,10), 8, 4)
    player:PushEvent("accident_of", "monkeyprojectile")
end

local function san_restore(inst, player)
    player.components.sanity:DoDelta(50)
    player:PushEvent("accident_of", "san_restore")
end

local function spat_bomb(inst, player)
    -- local proj = SpawnPrefab("spat_bomb")
    -- proj.Transform:SetPosition(target.Transform:GetWorldPosition())
    -- proj.components.complexprojectile:Launch(player:GetPosition())
    local x,y,z = player.Transform:GetWorldPosition()
    -- 直接触发被黏住的效果 
    local ents = TheSim:FindEntities(x, y, z, 4*2, {"player"}) --2地皮范围内玩家
    for _,v in pairs(ents or {}) do
        if v.components.pinnable ~= nil then
            v.components.pinnable:Stick()
        end        
    end

    player:PushEvent("accident_of", "spat_bomb")
end
local function pocketwatch(inst, player)
    local x,y,z
    for _, v in pairs(_G.Ents) do 
        if v.prefab and v.prefab == "spawnpoint_master" then
            x,y,z = v.Transform:GetWorldPosition()
            break
        end
    end
    if x then --目标位置存在 那么就生成裂缝
        local portal = SpawnPrefab("pocketwatch_portal_entrance")
        portal.Transform:SetPosition(player.Transform:GetWorldPosition())
        portal:SpawnExit(TheShard:GetShardId(), x, y, z)
    end
    player:PushEvent("accident_of", "pocketwatch")
end
local function abigail(inst, player)
    GiveAbigail(player)
    player:PushEvent("accident_of", "abigail")
end

local function army(inst, player)
    local function SpawnWeapon(holder)
        local weapon = SpawnPrefab(data.weapon[math.random(#data.weapon)])
        holder.components.inventory:Equip(weapon)
    end
    local function SpawnHead(holder)
        local head = SpawnPrefab(data.head[math.random(#data.head)])
        holder.components.inventory:Equip(head)
    end

    local armys = {
        {chance=0.9, item = {"spider","spider_warrior","spider_hider","spider_spitter","spider_dropper","spider_moon","spider_healer","spider_water"}}, --蜘蛛军团
        {chance=0.3, item = {"pigguard","pigman"}}, --猪人军团
        {chance=0.3, item = {"bunnyman"}}, --兔人军团
        {chance=0.3, item = {"merm", "mermguard"}}, --鱼人军团
        {chance=0.1, item = {"prime_mate"}, weapon = true}, --海盗大副军团
    }
    local items =  WeightRandom(armys)
    --选择最多4种生物
    items.item = table.randomnorepeat(items.item, math.random(4))

    circular_of(player,4,math.random(3,6),items.item,function(item, target)
        if target ~= nil and item.components.combat then
            item.components.combat:SuggestTarget(target) --仇恨
        end
        if items.weapon or math.random()<0.01 then --有1%概率整一个带武器的
            SpawnWeapon(item)
        end
        SpawnHead(item)
    end)
end

local function moisture(inst, player)
    local num = 10
    for k,v in pairs(player.components.inventory.equipslots) do
        if v.components.waterproofer then --防水组件
            num = num + v.components.waterproofer.effectiveness*100
        end
    end
    player.components.moisture:SetMoistureLevel(num)

    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())

    player:PushEvent("accident_of", "moisture")
end
--不可否认到勋章mod里稍微借鉴了一下下。忘记了柱子叫啥名字。
local function insanityrock(inst, player) --巨石阵1
    player.components.sanity:SetPercent(0)
    circular_of(player,2,6,{"insanityrock"}, function(item) item.persists = false item:DoTaskInTime(60, item.Remove) end)

    player:PushEvent("accident_of", "insanityrock")
end
local function sanityrock(inst, player) --巨石阵2
    player.components.sanity:SetPercent(1)
    circular_of(player,2,6,{"sanityrock"}, function(item) item.persists = false item:DoTaskInTime(60, item.Remove) end)

    player:PushEvent("accident_of", "sanityrock")
end

local function rapid(inst, player) --疾如风
    -- if player.rapid_task == nil then
    --     local time = 30
    --     local old_walkspeed = player.components.locomotor.runspeed
    --     player.components.locomotor.runspeed = old_walkspeed * 5.5
    --     player.rapid_task = player:DoTaskInTime(time, function(inst)
    --         player.components.locomotor.runspeed = old_walkspeed
    --         player.rapid_task:Cancel()
    --         player.rapid_task = nil
    --     end)
    -- end
    player:AddDebuff("buff_rapid_of", "buff_rapid_of")
    player:PushEvent("accident_of", "rapid")
end
local function resurrection(inst, player) --复活吧！我的爱人们
    for k,v in ipairs(AllPlayers) do
        if v:HasTag("playerghost") then
            v:PushEvent("respawnfromghost",{user=player}) --是由xx玩家复活滴
        end
    end

    player:PushEvent("accident_of", "resurrection")
end
 
local function xixindafa(inst, player) --吸物大法
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, nil, NO_REMOVE) 
    for i, v in ipairs(ents) do
        if v ~= inst and v.entity:IsVisible() and v.components.inventoryitem then
            v.Transform:SetPosition(x,y,z)
        end
    end
    player:PushEvent("accident_of", "xixindafa")
end

-- 小淘气
local function makeakrampusforplayer(inst, player)
    local pt = player:GetPosition()
    local spawn_pt = GetSpawnPoint_of(pt)
    if spawn_pt ~= nil then
        local kramp = SpawnPrefab("krampus")
        kramp.Physics:Teleport(spawn_pt:Get())
        kramp:FacePoint(pt)
        kramp.spawnedforplayer = player
        kramp:ListenForEvent("onremove", function() kramp.spawnedforplayer = nil end, player)
    end
    player:PushEvent("accident_of", "makeakrampusforplayer")
end
local function quantixianwokanqi(inst, player) --全体目光向我看齐
    local x, y, z = player.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, 4*5) 
    for i, v in ipairs(ents) do
        if v ~= player and v.entity:IsVisible() then
            v:ForceFacePoint(x, y, z)
            if v.components.combat then
                v.components.combat:SuggestTarget(player)
            end
        end
    end

    local poop = SpawnPrefab("poop")
    poop.Transform:SetPosition(x, y, z)
    player.components.inventory:GiveItem(poop)

    player:PushEvent("accident_of", "quantixianwokanqi")
end
--给生物冰冻住，然后更改颜色金灿灿，加上挖矿组件 
--解冻后，移除挖矿组件
local function goldenstatue(inst2, player)
    local merm = SpawnPrefab("merm")
    merm.Transform:SetPosition(player:GetPosition():Get()) --设置位置
    SpawnPrefab("collapse_small").Transform:SetPosition(player:GetPosition():Get())
    if merm.components.workable == nil then --添加可行动组件
        merm:AddComponent("workable")
    end
    local workable = merm.components.workable
    workable:SetWorkAction(ACTIONS.MINE) --挖矿
    workable:SetWorkLeft(3) --次数
    workable:SetOnWorkCallback(function(inst, worker, workleft) --挖矿完成删除
        if workleft <= 0 then
            local pt = inst:GetPosition()
            SpawnPrefab("rock_break_fx").Transform:SetPosition(pt.x, pt.y, pt.z)
            inst.components.lootdropper:SetLoot({"goldnugget","goldnugget"})
            inst.components.lootdropper:DropLoot(pt)
            inst:Remove()
        end
    end)
    merm.sg:GoToState("gold") --进入金铲铲状态
    merm:DoTaskInTime(5, function(inst)
        inst:PushEvent("onthawgold")
    end)
    player:PushEvent("accident_of", "goldenstatue")
end

-- 眼球草陷阱
local function eyeplant(inst, player)
    circular_of(player,5,9,{"eyeplant"})

    player:PushEvent("accident_of", "eyeplant")
end

-- 护盾充能
local function shield(inst, player)
    if player.components.shield then
        player.components.shield:SetCondition(200)
    end

    player:PushEvent("accident_of", "shield")
end
-- 我就是二郎神
local function i_am_els(inst, player)
    GiveEyeturret(player)
    player:PushEvent("accident_of", "i_am_els")
end

local function range_life_recovery(inst, player)
    local x, y, z = player.Transform:GetWorldPosition()
    local of_recovery = SpawnPrefab("of_recovery")
    of_recovery.Transform:SetPosition(x, y, z)
    
    local number = 10
    local function recovery(i)
        if number <= 0 then i.task:Cancel() i.task = nil i:Remove() return end --次数达到了就移除
        local ents = TheSim:FindEntities(x, y, z, 4, {"player"})
        for k,v in ipairs(ents or {}) do
            if v and v:IsValid() and not v:HasTag("playerghost") and v.components.health then
                v.components.health:DoDelta(10)
            end
        end
        number = number - 1
    end

    of_recovery.task = of_recovery:DoPeriodicTask(1, recovery)
    player:PushEvent("accident_of", "range_life_recovery")
end
local function leif_anger(inst, player)
    if not inspectProtect(player) then return end
    circular_of(player,5,1,{"leif", "leif_sparse"}, function(item, target)
        if item.components.locomotor then
            item.components.locomotor.runspeed = 14
            item.components.locomotor.walkspeed = 14
        end
        if target ~= nil and item.components.combat then
            item.components.combat:SuggestTarget(target) --仇恨
        end
    end)
    player:PushEvent("accident_of", "leif_anger")
end
local function bosscompanion(inst, player)
    if not inspectProtect(player) then return end
    GiveBossCompanion(player)
    player:PushEvent("accident_of", "bosscompanion")
end
local function timebomb(inst, player)
    local timebomb = SpawnPrefab("timebomb")
    player.components.inventory:GiveItem(timebomb)
    player:PushEvent("accident_of", "timebomb")
end

local function knockback(inst, player)
    local strengthmult = (player.components.inventory and player.components.inventory:ArmorHasTag("heavyarmor") or player:HasTag("heavybody")) and 1 or 4
    player:PushEvent("knockback", { knocker = inst, radius = 8, strengthmult = strengthmult, forcelanded = nil })
    player:PushEvent("accident_of", "knockback")
end

local function feetslipped(inst, player)
    -- if player.feetslipped_tsak == nil then
    --     player.feetslipped_tsak = player:DoPeriodicTask(1.5, function(p)
    --         if p.Physics:GetMotorSpeed() > 0 then
    --             p:PushEvent("feetslipped") --跳转到脚滑状态Sg
    --         end
    --     end)
    -- end
    -- -- 停止打滑 可以重新计时
    -- if player.feetslipped_end_tsak ~= nil then
    --     player.feetslipped_end_tsak:Cancel()
    --     player.feetslipped_end_tsak = nil
    -- end
    -- player.feetslipped_end_tsak = player:DoTaskInTime(30, function(p)
    --     p.feetslipped_end_tsak:Cancel()
    --     p.feetslipped_end_tsak = nil
    --     p.feetslipped_tsak:Cancel()
    --     p.feetslipped_tsak = nil
    -- end)
    player:AddDebuff("buff_feetslipped_of", "buff_feetslipped_of")
    player:PushEvent("accident_of", "feetslipped")
end
-- 变身术
local function alterself(inst, player)
    -- 把玩家不显示 hud隐藏
    -- local build = {"wilson","wortox","wendy","willow","wickerbottom","waxwell","webber","wes","winona","woodie","wormwood","wurt","warly","wathgrithr","wolfgang","wx78","walter","wanda"}
    -- player.AnimState:SetBuild(build[math.random(#build)])

    -- if player.alterself_end_tsak ~= nil then
    --     player.alterself_end_tsak:Cancel()
    --     player.alterself_end_tsak = nil
    -- end
    -- player.alterself_end_tsak = player:DoTaskInTime(30, function(p)
    --     p.AnimState:SetBuild(p.prefab)
    -- end)
    player:AddDebuff("buff_alterself_of", "buff_alterself_of")
    player:PushEvent("accident_of", "alterself")

end

local function acidrain(inst, player)
    TheWorld.net.components.climatechange_of:SetCurrent(2)
    player:PushEvent("accident_of", "acidrain")
end

local function lunarhail(inst, player)
    TheWorld.net.components.climatechange_of:SetCurrent(3)
    player:PushEvent("accident_of", "lunarhail")
end

local function fog(inst, player)
    TheWorld.net.components.climatechange_of:SetCurrent(4)
    player:PushEvent("accident_of", "fog")
end
local function buff_playerabsorption_of(inst, player)
    player:AddDebuff("buff_playerabsorption_of", "buff_playerabsorption_of")

    player:PushEvent("accident_of", "buff_playerabsorption_of")
end
local function buff_attack_of(inst, player)
    player:AddDebuff("buff_attack_of", "buff_attack_of")
    
    player:PushEvent("accident_of", "buff_attack_of")
end

local function black_hole(inst, player)
    local pos = FindNearbyLand(player:GetPosition(),8) --两地皮范围内陆地位置
    if pos ~= nil then --没有可生成位置就不要生成出来
        local hole = SpawnPrefab("black_hole_of")
        hole.Transform:SetPosition(pos:Get())
    end
    player:PushEvent("accident_of", "black_hole")
end

local function random_buff(inst, player)
    if TUNING.OFDATA.BUFFNAMES then
        local buffs = deepcopy(TUNING.OFDATA.BUFFNAMES)
        shuffleArray(buffs)
        local max = #buffs
        max = math.min(max, 3)
        for i = 1, max do
            player:AddDebuff(buffs[i], buffs[i])
        end
    end
    player:PushEvent("accident_of", "random_buff")
end

local function previousF(inst, player, target)
    if player.components.record_of == nil then return end
    local self = player.components.record_of
    if self.last_F_fn then
        self.last_F_fn(inst, player, target, self.last_parameter)
    end
    if self.last_A_fn == nil then
        TheNet:Announce("上次事件:"..(self.last or "???"))
    end
end
local function previousA(inst, player, target)
    if player.components.record_of == nil then return end
    local self = player.components.record_of
    if self.last_A_fn then
        self.last_A_fn(inst, player, target, self.last_parameter)
    end
    if self.last_F_fn == nil then
        TheNet:Announce("上次事件:"..(self.last or "???"))
    end
end

local function oceancolour(inst, player, target)
    if TheWorld.oceancolour_task == nil then
        TheWorld.oceancolour_task = TheWorld:DoTaskInTime(60*4,function(word)
            TheWorld.oceancolour_task:Cancel()
            TheWorld.oceancolour_task = nil
            SendModRPCToClient(GetClientModRPC("of_RPC", "kehuduan"), nil, DataDumper({"oceancolour", false}, nil, true))
        end)
        -- nil 时, 对当前世界的全部玩家有效 (如果在持续时间里有玩家重新进入世界 会变回去)
        SendModRPCToClient(GetClientModRPC("of_RPC", "kehuduan"), nil, DataDumper({"oceancolour", true}, nil, true))
    end
    player:PushEvent("accident_of", "oceancolour")
end

local function junkball(inst, player, target)
    SpawnGrowTheGround(player, 0.5,
        {
            {chance = 0.6, item = "junkball_fx", fn = function(i, x, y, z) 
                i:SetupJunkTossFromPile(x, z, x, z)
            end},
        }, 
    math.random(5,10), 8, 4)
    player:PushEvent("accident_of", "junkball")
end

local function puppet(inst, player)
    GeneratePuppet(player)
    player:PushEvent("accident_of", "puppet")
end

-- local list_index = 1
local function puppet_boss(i, player)
    if player == nil or not player:HasTag("player") then return end --非玩家
    local sw_list = {
        -- "shadowprotector", --暗夜兵
        -- "terrorbeak", --尖嘴暗影怪
        -- "crawlinghorror", --暗影爬行怪
        "killerbee", --杀人蜂
        "koalefant_summer", --冬象
        -- "gnarwail", --一角鲸
        "tallbird", --高鸟
        "mushgnome", --蘑菇地精
        "hound", --猎狗
        -- "monkey",
        "rook", --发条战车
        "worm", --洞穴蠕虫
        -- "eyeofterror", --恐怖之眼
        "mutateddeerclops", --晶体独眼巨鹿
        "shadowthrall_horns", --墨荒·吞
        "sharkboi",  --大霜鲨
        "bearger", --熊大

        "krampus", --小偷
        "fruitdragon", --沙拉蝾螈
        "lunarfrog", --明眼青蛙
        "crabking_mob", --蟹卫
        "crabking_mob_knight", --蟹骑士

        "malbatross", --邪天翁
        "moose", --鹿鸭
        -- "spiderqueen", --蜘蛛女王
    }
    local inst = SpawnPrefab(sw_list[math.random(#sw_list)])
    -- if #sw_list < list_index + 1 then
    --     list_index = 1
    -- else
    --     list_index = list_index + 1
    -- end

    if inst.brainfn then 
        inst:StopBrain("control_puppet")
    end
    if inst.components.knownlocations then 
        inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition(), false) -- 重新记住
    end

    local function onxx(inst)
        if inst.old_brainfn then
            inst:RestartBrain("control_puppet") 
        end
        inst:RemoveEventCallback("of_stopcontrolling", onxx)
    end

    inst.Transform:SetPosition(player:GetPosition():Get()) --设置坐标
    inst.AnimState:SetMultColour(0, 0, 0, .5) --暗影兵一样

    -- 结束时 还需要添加一个定时器自杀.
    inst:DoTaskInTime(TUNING.CONTROLPUPPETTIME, inst.Remove)

    -- 开始控制傀儡 
    player.components.controlpuppet:StartControl(inst)

    -- 重新记住
    if inst.components.knownlocations then 
        inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition(), false)
    end

    --控制结束则移除
    inst:ListenForEvent("of_leavecontrol", function(inst) inst:DoTaskInTime(0, inst.Remove) end) 

    inst:ListenForEvent("entitysleep", function() --脱离加载范围
        if player then
            inst.Transform:SetPosition(player.Transform:GetWorldPosition())
        end
    end)
    inst:AddTag("is_puppet")
    inst.persists = false --退出时不会保存

    player:PushEvent("accident_of", "puppet_boss")
end

local function oceanice(inst, player)
    local x,y,z = player.Transform:GetWorldPosition()
    local tile_x, tile_y = TheWorld.Map:GetTileCoordsAtPoint(x, y, z)

    if TheWorld.Map:GetTile(tile_x, tile_y) == WORLD_TILES.OCEAN_ICE then return end --防止变为永久地皮

    TheWorld.components.oceanicemanager:CreateIceAtPoint(x, y, z)

    -- 破坏冰 如果中退了那么只能靠炸药类物品炸开
    TheWorld:DoTaskInTime(60, function(word)
        TheWorld.components.oceanicemanager:QueueDestroyForIceAtPoint(x,y,z)
    end)
end

local function deathrattle_of(inst, player)
    player:AddDebuff("buff_deathrattle_of", "buff_deathrattle_of")
    
    player:PushEvent("accident_of", "deathrattle_of")
end

local function worm_attack(inst, player)
    player:PushEvent("accident_of", "worm_attack")
    local pos = FindNearbyLand(player:GetPosition(), 4*5)
    if pos == nil then return end
    if TUNING.WORM_ATTACK_OF > math.random() then
        TUNING.WORM_ATTACK_OF = 0
        local worm_boss = SpawnPrefab("worm_boss")
        worm_boss.Transform:SetPosition(pos:Get())
        worm_boss.components.combat:SuggestTarget(player)
        return
    end
    TUNING.WORM_ATTACK_OF = TUNING.WORM_ATTACK_OF + .2
    for i = 1, math.random(2, 5) do
        local worm = SpawnPrefab("worm")
        worm.Transform:SetPosition(pos:Get())
        worm.components.combat:SuggestTarget(player)
    end
end

local function gelblobs(inst, player)
    SpawnGrowTheGround(player, 0.5,
        {
            {chance = 0.6, item = "gelblob", fn = function(gelblob, x, y, z) 
                gelblob.sg:GoToState("spawndelay", .15 + math.random() * 1)
            end},
        }, 
    math.random(5,10), 6, 3)
    player:PushEvent("accident_of", "gelblobs")
end
local function icewall(inst, player)
    circular_of(player,2,6, {"crabking_icewall","sharkboi_icespike"})
    -- announce(player, "营火晚会")
    player:PushEvent("accident_of", "icewall")
end
local function fruits(inst, player, target, parameter)
    circular_of(player,3,6, parameter, function(inst, target)
        inst.force_oversized=true
        if inst.components.growable then
            for i = 1, 4 do
                inst:DoTaskInTime((i-1) * 1 + math.random() * 0.5, function()
                    inst.components.growable:DoGrowth()
                end)
            end
        end
    end)
    player:PushEvent("accident_of", "fruits")
end

local function playerdata(inst, player, target, parameter)
    local loots = require("gambling_loot")
    -- 玩家角色类型物品 mod角色给肉干好了
    local loot = loots[player.prefab] or {
        {chance = 0.1, item = "meat_dried"},--肉干
    }
    if loot then
        loot = WeightRandom2(loot, 3)
        for key, value in ipairs(loot or {}) do
            local prefab = type(value.item) == "table" and value.item[math.random(#value.item)] or value.item
            local item = SpawnPrefab(prefab)
            if item then
                player.components.inventory:GiveItem(item)
            end
        end
    end
    player:PushEvent("accident_of", "playerdata")
end

-------------------------------------------------------------------
return {
	weatherchanged = weatherchanged, -- 阴晴不定
	rockcircle = rockcircle, -- 岩石怪圈
	campfirecircle = campfirecircle, -- 营火晚会
	monstercircle = monstercircle, -- 生物怪圈
    maxwellcircle = maxwellcircle, -- 犬牙陷阱圈
    lightningTarget = lightningTarget, -- 天雷陷阱
    celestialfury = celestialfury, -- 天体陷阱
    gunpowdercircle = gunpowdercircle, -- 火药陷阱
    onAddHun = onAddHun, -- 啜食
    onAddSan = onAddSan, -- 降智
    onAddHp = onAddHp, -- 流血
    shadow_level = shadow_level, -- 暗影陷阱
    healthlink = healthlink, -- 单向生命链接
    caveinobstacle = caveinobstacle, -- 柱！柱！柱！
    sporecloud = sporecloud, -- 多重孢子云
    removeitems = removeitems, --清理物品
    hedgehounds = hedgehounds, --蔷薇陷阱
    ghost_circle = ghost_circle, --鬼魂陷阱
    lethargy = lethargy, --昏睡陷阱
    sanityempty = sanityempty, --理智全无
    turkey = turkey, --毒计？鸡
    dropequip = dropequip, --卸甲归田
    stashloot = stashloot, --遗失宝藏
    seasonchange = seasonchange, --季节变化
    shadowthrall = shadowthrall, --甘·文·崔
    spawnwaves = spawnwaves, --惊涛波浪
    deciduous = deciduous, --桦树精的愤愤
    refusefish = refusefish, --强制禁鱼期
    rabbiteater = rabbiteater, --兔吃曼草
    transformation = transformation, --移形换影
    debrisitems = debrisitems, --奇怪的雨
    ascension = ascension, --升天
    allfreezable = allfreezable, --大范围冰冻
    sand = sand, --蚁狮陷阱
    supermany = supermany, --超多的陷阱
    frograin = frograin, --青蛙雨
    alterguardian_laser = alterguardian_laser, --相控阵激光
    mushroombomb = mushroombomb, --奇妙蘑菇林
    mushroom = mushroom, --蘑菇丛
    fossilspike = fossilspike, --骨牢骨刺
    areaaware_abnormal = areaaware_abnormal, --区域异常，半天!
    super_big = super_big, --快快变大
    p_combat = p_combat, --别钓了，快战斗
    tentacle_kl = tentacle_kl, --触手陷阱
    bat_eye = bat_eye, --蝙蝠军团
    super_small = super_small, --快快变小
    weed_imprison = weed_imprison, --杂草禁锢
    onefistsuperman = onefistsuperman, --一拳小超人
    angel_blessing = angel_blessing, --天使赐福
    returnonattack = returnonattack, --还你飘飘拳
    deltapenalty = deltapenalty, --加点黑血
    onlifeinjector = onlifeinjector, --注射强心针
    sanityaura = sanityaura, --你不要过来
    research = research, --知识灌入
    temperature = temperature, --体温变气温
    mindcontrol = mindcontrol, --精神控制
    twinmanager = twinmanager, --双子魔眼
    small_forest = small_forest, --小森林
    automatic_weapon = automatic_weapon, --器灵
    equip_recovery = equip_recovery, --装备恢复
    small_boss = small_boss, --季节小boss
    groundpounder = groundpounder, --地震波
    glacier = glacier, --冰川
    moonstorms = moonstorms, --月亮风暴
    shadowmeteor = shadowmeteor, --流星雨
    fire_ice_charge = fire_ice_charge, --一圈无眼鹿冰火
    deer_ice_circle = deer_ice_circle, --无眼鹿冰
    deer_fire_circle = deer_fire_circle, --无眼鹿火
    spawnendhounds = spawnendhounds, --猎犬来袭
    goldnuggets = goldnuggets, --黄金雨
    monkeyprojectile = monkeyprojectile, --虚空便便弹
    san_restore = san_restore, --精神恢复
    spat_bomb = spat_bomb, --被黏住了
    pocketwatch = pocketwatch, --前往出生点
    abigail = abigail, --阿比盖尔
    army = army, --怪物军团
    moisture = moisture, --潮腻加身
    insanityrock = insanityrock, --巨石阵1
    sanityrock = sanityrock, --巨石阵2
    rapid = rapid, --疾如风
    resurrection = resurrection, --复活吧！我的爱人们
    xixindafa = xixindafa, --吸物大法
    makeakrampusforplayer = makeakrampusforplayer, --小淘气
    quantixianwokanqi = quantixianwokanqi, --全体目光向我看齐
    goldenstatue = goldenstatue, --黄金雕像
    eyeplant = eyeplant, --眼球草陷阱
    shield = shield, --护盾充能
    i_am_els = i_am_els, --我就是二郎神
    range_life_recovery = range_life_recovery, --范围生命恢复
    leif_anger = leif_anger, --森林怒火
    bosscompanion = bosscompanion, --巨兽伙伴
    timebomb = timebomb, --黏人炸弹
    knockback = knockback, --击飞
    feetslipped = feetslipped, --脚踩西瓜皮
    alterself = alterself, --变身术
    acidrain = acidrain, --酸雨天
    lunarhail = lunarhail, --玻璃雨
    fog = fog, --雾天
    buff_playerabsorption_of = buff_playerabsorption_of, --固若金汤
    buff_attack_of = buff_attack_of, --侵掠如火
    black_hole = black_hole, --黑洞？
    random_buff = random_buff, --随机buff
    previousF = previousF, --上次事件 钓起时
    previousA = previousA, --上次事件 落地时
    oceancolour = oceancolour, --不一样的海洋
    junkball = junkball, --垃圾雨
    puppet = puppet, --提线木偶
    puppet_boss = puppet_boss, --控制傀儡
    oceanice = oceanice, --卧槽，冰！
    deathrattle_of = deathrattle_of, --亡语
    worm_attack = worm_attack, --蠕虫来袭
    gelblobs = gelblobs, --恶液雨
    icewall = icewall, --寒冰屏障
    fruits = fruits, --硕果累累
    playerdata = playerdata, --角色物品
}