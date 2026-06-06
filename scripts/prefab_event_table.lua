local messagebottletreasures = require("messagebottletreasures")
local data = require("event_data")

local function bird(inst, player) -- 钓到鸟类
    inst:DoTaskInTime(1,function(inst) --等鸟飞起睡眠它, 超2s就被删了
        inst.components.sleeper:GoToSleep(0)
    end)
end

local function grotto_pool_small(inst, player) -- 钓到了岩石水池
    if inst._waterfall then
        inst._waterfall.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    inst.children = nil
end

local function klaus(inst, player)  -- 钓到克劳斯
	-- inst:SpawnDeer() -- 产鹿 钓起后,产鹿也暴怒。 钓起前,原克劳斯位置在海上,无法用海上坐标,所以产鹿坐标设置当前玩家坐标。
    local pos = player:GetPosition()
    local rot = player.Transform:GetRotation()
    local theta = (rot - 90) * DEGREES
    local offset =
        FindWalkableOffset(pos, theta, inst.deer_dist, 5, true, false) or
        FindWalkableOffset(pos, theta, inst.deer_dist * .5, 5, true, false) or
        Vector3(0, 0, 0)

    local deer_red = SpawnPrefab("deer_red")
    deer_red.Transform:SetRotation(rot)
    deer_red.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
    local redP = deer_red.Physics:GetCollisionMask()
    deer_red.Physics:SetCollisionMask(COLLISION.GROUND)  
    deer_red:DoTaskInTime(1,function(inst)
    	inst.Physics:SetCollisionMask(redP)  
	end)
    deer_red.components.spawnfader:FadeIn()
    inst.components.commander:AddSoldier(deer_red)


    theta = (rot + 90) * DEGREES
    offset =
        FindWalkableOffset(pos, theta, inst.deer_dist, 5, true, false) or
        FindWalkableOffset(pos, theta, inst.deer_dist * .5, 5, true, false) or
        Vector3(0, 0, 0)

    local deer_blue = SpawnPrefab("deer_blue")
    deer_blue.Transform:SetRotation(rot)
    deer_blue.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
    deer_blue.Physics:SetCollisionMask(COLLISION.GROUND)  
    deer_blue:DoTaskInTime(1,function(inst)
    	inst.Physics:SetCollisionMask(redP)  
	end)
    deer_blue.components.spawnfader:FadeIn()
    inst.components.commander:AddSoldier(deer_blue)	

	inst.components.knownlocations:RememberLocation("spawnpoint", player:GetPosition(), false) -- 重新记住玩家位置
	inst.components.spawnfader:FadeIn() -- 渐入效果

    --死亡位置生成一个赃物袋
    inst:ListenForEvent("death", function(inst)
        if not inst:IsUnchained() then
            SpawnPrefab("klaus_sack").Transform:SetPosition(inst:GetPosition():Get())
        end
    end)
end

local function oasislake(inst, player)--钓湖泊时
    inst.Physics:SetMass(0) -- 抛物结束，修改质量为0
    inst:DoTaskInTime(1.5,function(inst)
        if inst.driedup then -- 不可以钓鱼时
            inst.Physics:ClearCollisionMask() -- 清碰撞组
            inst.Physics:CollidesWith(COLLISION.ITEMS)
        else -- 可以钓鱼时
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.GIANTS)
        end
    end)
end
local function seedpacket(inst, player)
    if inst.components.unwrappable then
        --更改打开的方法 随机不重复的种子
        inst.components.unwrappable:SetOnUnwrappedFn(function(inst, pos, doer)
            if inst.burnt then
                SpawnPrefab("ash").Transform:SetPosition(pos:Get())
            else  
                local seeds = {"seeds","asparagus_seeds","carrot_seeds","corn_seeds","dragonfruit_seeds","durian_seeds","eggplant_seeds","garlic_seeds","onion_seeds","pepper_seeds","pomegranate_seeds","potato_seeds","pumpkin_seeds","tomato_seeds","watermelon_seeds"}
                local loot = table.randomnorepeat(seeds, 4)
                if loot ~= nil then
                    local moisture = inst.components.inventoryitem:GetMoisture()
                    local iswet = inst.components.inventoryitem:IsWet()
                    for i, v in ipairs(loot) do
                        local item = SpawnPrefab(v)
                        if item ~= nil then
                            if item.Physics ~= nil then
                                item.Physics:Teleport(pos:Get())
                            else
                                item.Transform:SetPosition(pos:Get())
                            end
                            if item.components.inventoryitem ~= nil then
                                item.components.inventoryitem:InheritMoisture(moisture, iswet)
                                item.components.inventoryitem:OnDropped(true, .5)
                            end
                        end
                    end
                end
                SpawnPrefab("carnival_seedpacket_unwrap").Transform:SetPosition(pos:Get())
            end      
            if doer ~= nil and doer.SoundEmitter ~= nil then
                doer.SoundEmitter:PlaySound(inst.skin_wrap_sound or "dontstarve/common/together/packaged")
            end
            inst:Remove()    
        end)
    end
end

local function sunkenchest(inst, player)
    local ls = messagebottletreasures.GenerateTreasure(inst:GetPosition(), "sunkenchest") --生成宝藏
    if ls == nil then return end
    if inst.components.container and ls.components.container then --箱子容器组件存在，添加到箱子里
        for _,item in pairs(ls.components.container:GetAllItems()) do
            inst.components.container:GiveItem(item)
        end
    end  
    ls:Remove()
end
local function alterguardian_laser(inst, player)
    inst:Trigger(0.5)
end

local function antlion(inst, player)
    inst:StartCombat(player,"burn")
end

local function gift(inst, player, target, parameter) --parameter可以是方法，表，字符串
    local items = {}
    local loot = nil
    local wp = {
        combat1 = {"armorwood","wathgrithrhat","spear_wathgrithr"}, --战斗套装
        combat2 = {"armorruins","ruinshat","ruins_bat"}, --铥矿套装
        combat3 = {"armor_sanity","nightsword"}, --暗影套装
    }
    if type(parameter) == "function" then
        loot = parameter(player)
    elseif type(parameter) == "string" then
        loot = wp[parameter] or {"goldnugget","goldnugget","goldnugget","goldnugget"}
    else
        loot = parameter
    end
    for _,name in pairs(table.randomnorepeat(loot,4)) do --4个不可重复项
        local item = SpawnPrefab(name)
        if item then 
            SetSpellCB(item, player) --给随机皮肤
            table.insert(items, item)
        end
    end
    inst.components.unwrappable:WrapItems(items) --打包物品
    for i, v in ipairs(items) do --删除生成出来的
        v:Remove()
    end
end
local function gift_plant(inst, player, target, parameter) --parameter可以是方法，表，字符串
    local items = {}
    local loot = nil
    local wp = {
        tree = {
            pinecone = function() return math.random(1,20) end,
            acorn = function() return math.random(1,15) end,
            livingtree_root = function() return math.random(1,5) end,
        },
        sapling = {
            twiggy_nut = function() return math.random(2,5) end,
            dug_sapling = function() return math.random(1,5) end,
            dug_sapling_moon = function() return math.random(1,5) end,
            dug_marsh_bush = function() return math.random(1,5) end,
        },
        miscellaneous = {
            dug_grass = function() return math.random(2,5) end, 
            bullkelp_root = function() return math.random(1,5) end,
            marblebean = function() return math.random(1,5) end, 
        },
        berrybush = {
            dug_berrybush = function() return math.random(1,5) end, 
            dug_berrybush2 = function() return math.random(1,5) end, 
            dug_berrybush_juicy = function() return math.random(1,5) end, 
        },
    }
    if type(parameter) == "function" then
        loot = parameter(player)
    elseif type(parameter) == "string" then
        loot = wp[parameter] or {poop = 5, log = 10}
    else
        loot = parameter
    end
    for name,v in pairs(loot) do --4个不可重复项
        local item = SpawnPrefab(name)
        if item then 
            SetSpellCB(item, player) --给随机皮肤
            if item.components.stackable then --设置堆叠数量
                item.components.stackable:SetStackSize(type(v) == "function" and v() or v)
            end
            table.insert(items, item)
        end
    end
    inst.components.unwrappable:WrapItems(items) --打包物品
    for i, v in ipairs(items) do --删除生成出来的
        v:Remove()
    end
end

local function getplayer(inst, player)
    local items = data.getplayer
    -- inst:DoTaskInTime(180,function(inst) inst:Remove() end) --会主动打怪。所以不需要了，并且死亡删除。
    if inst.components.health then --设置生命上限, 容易弄死, 好掉落东西
        inst.components.health:SetMaxHealth(60)
    end
    if inst.components.inventory then --放一些东西
        local max = math.random(1,5)
        for k = 1, max do
            inst.components.inventory:GiveItem(SpawnPrefab(items[math.random(#items)]))
        end
    end
    spawnprefabplayer(inst, player)
end
local function chest(inst, player)
    local prefab = inst.prefab
    local items = nil
    if prefab == "treasurechest" then
        items = data.chest.treasurechest
    elseif prefab == "pandoraschest" then 
        items = data.chest.pandoraschest
    elseif prefab == "dragonflychest" then
        items = data.chest.dragonflychest
    elseif prefab == "minotaurchest" then
        items = data.chest.minotaurchest
    else --其他箱子
        items = data.chest.other
    end
    if inst.components.workable then inst:RemoveComponent("workable") end --不能被敲
    if inst.components.burnable then inst:RemoveComponent("burnable") end --移除燃烧属性   
    inst.persists = false --退出时不会保存
    inst:DoTaskInTime(60, inst.Remove) --到60s清理掉
    -- announce(player, inst:GetDisplayName())
    if items == nil and type(items) ~= "table" and #items <= 0 then return end
    for _,name in pairs(table.randomrepea(items, math.random(3,9))) do
        local giveItem = SpawnPrefab(name)
        if inst.components.container then --箱子容器组件存在，添加到箱子里
            inst.components.container:GiveItem(giveItem)
        end  
    end
    inst.AnimState:OverrideMultColour(1, 0, 0, 1)
end
local taozuan = {
    {"minerhat","sweatervest"}, -- 矿工套
    {"flowerhat","hawaiianshirt","grass_umbrella"}, -- 休闲套
    {"wathgrithrhat","spear_wathgrithr"}, -- 战斗套
    {"kelphat","trident"}, -- 海王套
    {"armor_sanity","nightsword"}, --暗夜套
    {"lunarplanthat","armor_lunarplant"}, --亮茄套
    {"voidclothhat","armor_voidcloth"}, --虚空套
    {"armordreadstone","dreadstonehat"}, --绝望石套
    {"shieldofterror","eyemaskhat"}, --恐怖套
    {"featherhat","hawaiianshirt"}, --夏威夷套
}
local function sewing_mannequin(inst, player) --假人装备
    local gl = math.random()
    if gl < 0.001 then return end --没有装备
    if gl < 0.45 then -- 随机数量随机着装
        local wp = data.sewing_mannequin
        
        local function sj(t)
            local item = spawnAtGround_of(t[math.random(#t)],0,0,0)
            if item then 
                inst.components.inventory:Equip(item)
            end
        end
        -- 保底一件
        if math.random() > 0.33 then
            sj(wp[2])
        end
        if math.random() > 0.33 then
            sj(wp[3])
        end
        sj(wp[1])

        return 
    end

    for k,v in pairs( taozuan[math.random(#taozuan)] ) do
        local item = spawnAtGround_of(v,0,0,0)
        if item then 
            inst.components.inventory:Equip(item)
        end
    end
end

-- 限时限数 猪王
local function pigking(inst, player)
    local function launchitem(item, angle)
        local speed = math.random() * 4 + 2
        angle = (angle + math.random() * 60 - 30) * DEGREES
        item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
    end
    inst.AnimState:SetMultColour(0, 0, 0, .5) --暗影猪王一样
    -- 限数
    local num = 5
    inst:ListenForEvent("trade", function(inst, data) 
        num = num - 1
        if num <= 0 then
            -- 提前把产物生成出来得了 防止重复交易带来的损失 (但是第4次交易结果还没有完成，在第5次交易结束了, 咋办。还是4次)
            if data.item then
                local x, y, z = inst.Transform:GetWorldPosition()
                y = 4.5
                local angle
                if data.giver ~= nil and data.giver:IsValid() then
                    angle = 180 - data.giver:GetAngleToPoint(x, 0, z)
                else
                    local down = TheCamera:GetDownVec()
                    angle = math.atan2(down.z, down.x) / DEGREES
                end
                
                for k = 1, data.item.components.tradable.goldvalue do
                    local nug = SpawnPrefab("goldnugget")
                    nug.Transform:SetPosition(x, y, z)
                    launchitem(nug, angle)
                end
                for _, v in pairs(data.item.components.tradable.tradefor or {}) do
                    local item = SpawnPrefab(v)
                    if item ~= nil then
                        item.Transform:SetPosition(x, y, z)
                        launchitem(item, angle)
                    end
                end
            end
            inst:DoTaskInTime(0, inst.Remove) --直接删除了
            return
        end
        if data and data.giver and data.giver.components.talker then
            data.giver.components.talker:Say("还有交易次数"..num, 5)
        end
    end)
    -- 限时
    inst:DoTaskInTime(60*4, inst.Remove)
    --退出时不会保存
    inst.persists = false 
end

local function player_hosted(inst, player)
    local zbs = {
        {"voidcloth_scythe", "voidclothhat", "armor_voidcloth"},
        {"sword_lunarplant", "lunarplanthat", "armor_lunarplant"},
        {"ruins_bat", "ruinshat", "armorruins"},
        {"spear_wathgrithr_lightning", "wagpunkhat", "armorwagpunk"},
    }
    zbs = zbs[math.random(#zbs)]
    for _, prefab in ipairs(zbs) do
        local zb = SpawnPrefab(prefab)
        if zb then
            inst.components.inventory:Equip(zb)
        end
        inst.components.combat:SuggestTarget(player) --仇恨
    end
end
-------------------------------------------------------------------
-------------------------------------------------------------------

return {
	bird = bird, -- 钓到鸟类
    grotto_pool_small = grotto_pool_small, -- 钓到了岩石水池
	klaus = klaus, -- 钓到克劳斯
    oasislake = oasislake, --钓湖泊时
    seedpacket = seedpacket, --钓到种子包
    sunkenchest = sunkenchest, --钓到沉底宝箱
    antlion = antlion, --钓到蚁狮
    gift = gift, --钓到礼物
    gift_plant = gift_plant, --钓到礼物·可堆叠
    getplayer = getplayer, --钓到玩家
    chest = chest, -- 钓到箱子了
    sewing_mannequin = sewing_mannequin, --假人装备
    pigking = pigking, --钓到限时限数猪王
    player_hosted = player_hosted, -- 被附身的尸体
}