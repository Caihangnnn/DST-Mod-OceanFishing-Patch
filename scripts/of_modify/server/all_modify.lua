---------------------------------------------------
--[[ 需要直接修改 Prefabs 表中预加载的预制体文件数据 ]]--
---------------------------------------------------

local old_DoRetrofitting = require("map/retrofit_savedata").DoRetrofitting
require("map/retrofit_savedata").DoRetrofitting = function(savedata, map)
    if Boss_modify and GLOBAL.Prefabs["moose"] then --更改鹿鸭 使其非春天生成出来后脱离仇恨就飞走机制失效
        setval(GLOBAL.Prefabs["moose"].fn, "OnSpringChange", function() end)
    end
    if GLOBAL.Prefabs["grotto_pool_small"] then --更改绿洲玻璃池 使其不能生成雾气
        setval(GLOBAL.Prefabs["grotto_pool_small"].fn, "makesmallmist", function() end)
    end
    -- 方正也就执行一次问题不大
    print("检查buff实体")
    for name, data in pairs(GLOBAL.Prefabs) do
        local str = string.split(name,"_") 
        if str[1] == "buff" then
            table.insert(TUNING.OFDATA.BUFFNAMES, name)
        end
    end
    print("buff数量", #TUNING.OFDATA.BUFFNAMES)

    old_DoRetrofitting(savedata, map)
end


---------------------------------------------
-- messagebottlemanager -- 使得瓶子可以查看其他岛屿
AddComponentPostInit("messagebottlemanager",function(self)
    self.lands = nil
    -- 希望有兼容效果
    if self.player_lands == nil then
        self.player_lands = {} -- 记录玩家查看过的岛屿
        local old_UseMessageBottle = self.UseMessageBottle
        self.UseMessageBottle = function(self, bottle, doer, is_not_from_hermit)
            if self.player_lands[doer.userid] == nil then
                self.player_lands[doer.userid] = {}
            end
            --每使用瓶中信都会随机打乱
            for k,i in pairs(self.lands and shuffleArray(self.lands) or {}) do 
                if table.reverselookup(self.player_lands[doer.userid],i) == nil then
                    table.insert(self.player_lands[doer.userid],i)
                    local node = TheWorld.topology.nodes[i]
                    -- local x,z = TheWorld.Map:GetRandomPointsForSite(node.x, node.y, node.poly, 1) --本来想随机一点的 出bug 就不要啦
                    -- return Vector3(x,0,z), "REVEAL_OTHER_ISLANDS"
                    return Vector3(node.x, 0, node.y), "REVEAL_OTHER_ISLANDS"
                end
            end
            return old_UseMessageBottle(self, bottle, doer, is_not_from_hermit)
        end

        local old_Save = self.OnSave
        local old_Load = self.OnLoad

        self.OnSave = function(self)
            local data = old_Save(self) or {}

            if next(self.player_lands) ~= nil then
                data.player_lands = self.player_lands
            end

            return data        
        end

        self.OnLoad = function(self,data)
            old_Load(self,data)
            if data ~= nil then
                if data.player_lands ~= nil and next(data.player_lands) ~= nil then
                    for k, v in pairs(data.player_lands) do
                        self.player_lands[k] = v
                    end
                end            
            end 
        end
    end
end)

---------------------------------------------
-- alterguardian_phase3dead 被击败的天体英雄
-- 清理当前世界上召唤天体英雄的组件，防止数量太多
AddPrefabPostInit("alterguardian_phase3dead", function(inst)
    inst:DoTaskInTime(0,function(inst)
        TheWorld:PushEvent("onremove_alterguardian")
    end)
end)
local phase3dead = {
    "moon_altar_ward",
    "moon_altar_seed",
    "moon_altar_idol",
    "moon_altar_icon",
    "moon_altar_glass",
    "moon_altar_crown",
    "moonrockseed",
}
for k,i in pairs(phase3dead) do
    AddPrefabPostInit(i,function(inst)
        inst:ListenForEvent("onremove_alterguardian",function(word)
            inst:Remove()
        end,TheWorld)
    end)
end

-- 启迪陷阱 不要月亮碎片
AddPrefabPostInit("alterguardian_phase3trap",function(inst)
    if inst.components.lootdropper then
        inst.components.lootdropper:SetLoot({})
        -- inst.components.lootdropper.ifnotchanceloot = nil
        inst.components.lootdropper.chanceloottable = nil
    end
end)

---------------------------------------------
-- 修改麦斯威尔的犬牙陷阱
AddPrefabPostInit("trap_teeth_maxwell", function(inst)
    if TheWorld.ismastersim then --判断是不是主机
        if inst.components.mine then
            inst.components.mine:SetRadius(1.5)
            inst.components.mine:SetTestTimeFn(function()return 0.75 end)
        end
    end
end)

AddComponentPostInit("mine",function(self) 
    local mine_test_fn = function(dude, inst)
        return not (dude.components.health ~= nil and
                    dude.components.health:IsDead())
            and dude.components.combat:CanBeAttacked(inst)
    end
    local mine_test_tags = { "monster", "character", "animal" }
    -- See entityreplica.lua
    local mine_must_tags = { "_combat" }
    local function MineTest(inst, self)
        if self.radius ~= nil then
            local notags = { "notraptrigger", "flying", "ghost", "playerghost", "spawnprotection"}
            table.insert(notags, self.alignment) -- 移除它,默认alignment 忽略玩家

            local target = FindEntity(inst, self.radius, mine_test_fn, mine_must_tags, notags, mine_test_tags)
            if target ~= nil then
                self:Explode(target)
            end
        end
    end
    self.StartTesting = function(self)
        if self.testtask ~= nil then
            self.testtask:Cancel()
        end
        local next_test_time = self.testtimefn ~= nil and self.testtimefn(self.inst) or (1 + math.random())
        self.testtask = self.inst:DoPeriodicTask(next_test_time, MineTest, 0, self)  --只要重置了就直接开始搜索     
    end
end)

---------------------------------------------
-- 修改骨架
local ATRIUM_RANGE = 8.5
local function ActiveStargate(gate)
    return gate:IsWaitingForStalker()
end
local STARGET_TAGS = { "stargate" }
local function OnAccept(inst, giver, item)
    if item.prefab == "shadowheart" then
        local stalker
        
        local stargate = FindEntity(inst, ATRIUM_RANGE, ActiveStargate, STARGET_TAGS) -- 查找大门
        if stargate ~= nil then
            stalker = SpawnPrefab("stalker_atrium")
            stalker.components.entitytracker:TrackEntity("stargate", stargate)
            stargate:TrackStalker(stalker) -- 跟踪者
        elseif TheWorld.state.isnight then
            stalker = SpawnPrefab("stalker_forest")
        else
            stalker = SpawnPrefab("stalker")
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        local rot = inst.Transform:GetRotation()
        inst:Remove()

        stalker.Transform:SetPosition(x, y, z)
        stalker.Transform:SetRotation(rot)
        stalker.sg:GoToState("resurrect")

        giver.components.sanity:DoDelta(TUNING.REVIVE_SHADOW_SANITY_PENALTY)
    end
end

AddPrefabPostInit("fossil_stalker", function(inst)
    if TheWorld.ismastersim and not TheWorld:HasTag("cave") then --是服务器且不是洞穴
        if inst.components.trader then
            inst.components.trader:SetAbleToAcceptTest(function(...) return true end)
            inst.components.trader.onaccept = OnAccept
        end
    end
end)

------------------------------
-- 船身组件
AddComponentPostInit("hull", function(self, inst)
    local AttachEntityToBoat_ = self.AttachEntityToBoat 
    self.AttachEntityToBoat = function(self, obj, offset_x, offset_z, parent_to_boat)
        -- 仅删除着火点
        if obj.prefab == "burnable_locator_medium" then
            obj:Remove()
        else
            AttachEntityToBoat_(self, obj, offset_x, offset_z, parent_to_boat)
        end
    end
end)

------------------------------
--世界组件
--防止钓其 蘑菇精 在水面上时，生成月亮孢子 导致调用的方法没有检查组件
AddComponentPostInit("flotsamgenerator",function(self)
    local old_SpawnFlotsam = self.SpawnFlotsam
    self.SpawnFlotsam = function(self,spawnpoint,prefab,notrealflotsam)
        if not prefab then --不想复制私有方法到这里，那么记录原方法，遇到让它去调用
            return old_SpawnFlotsam(self,spawnpoint,prefab,notrealflotsam)
        end

        if prefab == nil then
            return
        end

        local flotsam = SpawnPrefab(prefab)
        if math.random() < .5 then
            flotsam.Transform:SetRotation(180)
        end
        if flotsam.Physics then --判断一下是否存在物理
            flotsam.Physics:Teleport(spawnpoint:Get())
        end

        self:setinsttoflotsam(flotsam, nil, notrealflotsam)

        return flotsam
    end 

end)

--藏宝 
--更改宝藏点生成机制 防止地少卡循环而崩溃
AddComponentPostInit("piratespawner",function(self)
    self.FindStashLocation = function(self)
        local locationOK = false
        local pt = Vector3(0,0,0)
        local offset = Vector3(0,0,0)
        local i = 1
        while locationOK == false or i < 10 do
            local ids = {}
            for node, i in pairs(TheWorld.topology.nodes)do
                local ct = TheWorld.topology.nodes[node].cent
                if TheWorld.Map:IsVisualGroundAtPoint(ct[1], 0, ct[2]) then --在陆地上
                    table.insert(ids,node)
                end
            end
            if #ids == 0 then
                break
            end
            local randnode =  TheWorld.topology.nodes[ids[math.random(1,#ids)]]
            pt = Vector3(randnode.cent[1],0,randnode.cent[2])
            local theta = math.random()* 2 * PI
            local radius = 4 
            offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

            while  TheWorld.Map:IsVisualGroundAtPoint(pt.x, 0, pt.z) == true do
                pt = pt + offset
            end
            --原本检查 这个点10地皮范围内玩家是否存在
            local players = FindPlayersInRange( pt.x, pt.y, pt.z, 3*4, true ) 
            if #players == 0  then
                locationOK = true
            end
            i = i+1
        end
        if not locationOK then --附近岸边找一个点
            local dest_x, dest_y, dest_z = FindRandomPointOnShoreFromOcean(pt.x, pt.y, pt.z)
            if dest_x then
                offset.x,offset.y,offset.z = dest_x, dest_y, dest_z
            end
        end
        return pt - (offset *2)
    end 

end)

----------------------------------------
-- 致命亮茄 钓起了或T出来被冰冻会因为没有 back 而报错
local function spawnback(inst)
    local back = SpawnPrefab("lunarthrall_plant_back")
    --back.Transform:SetPosition(inst.Transform:GetWorldPosition())
    back.AnimState:SetFinalOffset(-1)
    inst.back = back
    table.insert(inst.highlightchildren, back)
    back:ListenForEvent("onremove", function() back:Remove() end, inst)

    back:ListenForEvent("death", function()
        local self = inst.components.burnable
        if self ~= nil and self:IsBurning() and not self.nocharring then
            back.AnimState:SetMultColour(.2, .2, .2, 1)
        end
    end, inst)

    if math.random() < 0.5 then
        inst.AnimState:SetScale(-1,1)
        back.AnimState:SetScale(-1,1)
    end
    local color = .6 + math.random() * .4
    inst.tintcolor = color
    inst.AnimState:SetMultColour(color, color, color, 1)
    back.AnimState:SetMultColour(color, color, color, 1)
    inst:AddChild(back)

    inst.components.colouradder:AttachChild(back)
end
AddPrefabPostInit("lunarthrall_plant", function(inst)
    --加载时执行
    inst.OnLoadPostPass = function(inst)
        if inst.components.entitytracker:GetEntity("targetplant") then
            inst:infest(inst.components.entitytracker:GetEntity("targetplant"),true)
        else
            spawnback(inst)
        end      
    end
    inst:DoTaskInTime(0,function(inst)
        if not inst.components.entitytracker:GetEntity("targetplant") and inst.back == nil then
            spawnback(inst)
        end
    end)
end)

-----------------------------------------------------
if Bobbers then
    -----------------------------------------------------
    -- 更改浮标描述。
    local bobbers ={
        twigs = "可以作为浮标, 可禁止钓起道具物品",
        oceanfishingbobber_ball = "可以作为浮标, 可禁止钓起特殊事件",
        oceanfishingbobber_oval = "可以作为浮标, 可禁止钓起穿戴类",
        trinket_8 = "可以作为浮标, 可双倍钓起",
        oceanfishingbobber_robin = "可以作为浮标, 可禁止钓起食材类",
        oceanfishingbobber_canary = "可以作为浮标, 可禁止钓起移植类",
        oceanfishingbobber_crow = "可以作为浮标, 可禁止钓起生物类",
        oceanfishingbobber_robin_winter = "可以作为浮标, 可禁止钓起建筑类",
        oceanfishingbobber_goose = "可以作为浮标, 可禁止钓起基础材料",
        oceanfishingbobber_malbatross = "可以作为浮标,可禁止钓起巨型生物类",
    }
    for name, desc in pairs(bobbers) do
        AddPrefabPostInit(name, function(inst)
            if inst.components.inspectable then
                inst.components.inspectable.description = desc
            end 
        end)
    end
    -----------------------------------------------------
    -- 容器 按索引消耗物品 钓竿渔具可堆叠时 仅消耗一个
    AddComponentPostInit("container",function(self)
        self.ConsumeByKey = function(self, index, amount)
            local item = self.slots[index]
            if item == nil or (amount and amount < 0) then return 0 end --不存在物品

            if item.components.stackable == nil then
                self:RemoveItem(item):Remove()
                return 1
            elseif item.components.stackable.stacksize > amount then
                item.components.stackable:SetStackSize(item.components.stackable.stacksize - amount)
                return amount
            else
                amount = item.components.stackable.stacksize
                self:RemoveItem(item, true):Remove()
                return amount
            end

            return 0   
        end
    end)
end

----
--[[
"crabking_spawner", --帝王蟹刷新点
"dragonfly_spawner", --龙蝇刷新点
"antlion_spawner", --蚁狮刷新点
"beequeenhive", --蜂后
]]


AddPrefabPostInit("crabking",function(inst)
    -- 注册死亡时事件 是帝王蟹刷新点的 触发生成地形
    inst:ListenForEvent("death",function(inst)
        if inst.components.homeseeker then
            local home = inst.components.homeseeker.home
            if home ~= nil and home:IsValid() and home.prefab == "crabking_spawner" then
                of_spawnlayout("NineGrid")
            end
        end
    end)
end)

-------------------------------------
-- 小妾和星空 可以跨海岸线
AddPrefabPostInit("chester",function(inst)
    inst:DoTaskInTime(0,function(inst)
        inst.Physics:ClearCollisionMask()                           --Physics物理 清除碰撞遮罩
        --与 地面、障碍物、小型障碍物、人物、boss碰撞，但不与海洋陆地界限碰撞
        inst.Physics:SetCollisionMask(COLLISION.GROUND,COLLISION.OBSTACLES, COLLISION.SMALLOBSTACLES, COLLISION.CHARACTERS,COLLISION.GIANTS)
    end)
    -- 防溺水
    if inst.components and inst.components.drownable then
        inst.components.drownable.enabled = false
    end 
end)
AddPrefabPostInit("hutch",function(inst)
    inst:DoTaskInTime(0,function(inst)
        inst.Physics:ClearCollisionMask()                           --Physics物理 清除碰撞遮罩
        --与 地面、障碍物、小型障碍物、人物、boss碰撞，但不与海洋陆地界限碰撞
        inst.Physics:SetCollisionMask(COLLISION.GROUND,COLLISION.OBSTACLES, COLLISION.SMALLOBSTACLES, COLLISION.CHARACTERS,COLLISION.GIANTS)
    end)
    -- 防溺水
    if inst.components and inst.components.drownable then
        inst.components.drownable.enabled = false
    end 
end)

---------------------------------------
-- 守护者暗影触手 防止其攻击暗影生物(攻击了织影者，看不见的手设置攻击目标为它。它然后检查攻击目标时没有sg 会崩)
-- 选择攻击目标时，忽略暗影生物
AddPrefabPostInit("bigshadowtentacle",function(inst)
    if inst.components and inst.components.combat then
        inst.components.combat:SetRetargetFunction(0.5, function(inst)
            return FindEntity(
                inst,
                TUNING.TENTACLE_ATTACK_DIST,
                function(guy)
                    return guy.prefab ~= inst.prefab
                        and guy.entity:IsVisible()
                        and not guy.components.health:IsDead()
                        and (guy.components.combat.target == inst or
                            guy:HasTag("character") or
                            guy:HasTag("monster") or
                            guy:HasTag("animal"))
                        and (guy:HasTag("player") or (guy.sg and not guy.sg:HasStateTag("hiding")) )
                end,
                { "_combat", "_health" },
                { "minotaur", "shadowcreature"})--忽略暗影生物
        end)
    end 
end)


---------------------------------
-- 修改boss
if Boss_modify then
    -- hook 修改蚁狮 OnInit方法不使用Despawn方法
    AddPrefabPostInit("antlion",function(inst)
        local function OnInit(inst)
            inst.inittask = nil
            inst.onsandstormchanged = function(src, data)
            end
            inst:ListenForEvent("ms_stormchanged", inst.onsandstormchanged, TheWorld) --监听风暴变化 改为就是变了也没有

        end
        if inst.StopCombat then
            setval(inst.StopCombat,"OnInit",OnInit)
        end
        if inst.inittask then
            inst.inittask:Cancel()
            inst.inittask = inst:DoTaskInTime(0, OnInit)
        end
    end)
    -- 更改鹿鸭 使其非春天生成出来后脱离仇恨就飞走机制失效
    -- 在地图生成的时候，进行修改。
    -- local old_DoRetrofitting = require("map/retrofit_savedata").DoRetrofitting
    -- require("map/retrofit_savedata").DoRetrofitting = function(savedata, map)
    --     if GLOBAL.Prefabs["moose"] then
    --         setval(GLOBAL.Prefabs["moose"].fn, "OnSpringChange", function() end)
    --     end
    --     old_DoRetrofitting(savedata, map)
    -- end
    --更改邪天翁 使其能够在陆地上不飞走
    local brain = require("brains/malbatrossbrain")
    setval(brain.OnStart, "ShouldLeaveLand", function() end)

    -- 织影者保留
    AddPrefabPostInit("stalker_atrium", function(inst)
        inst.IsNearAtrium = function () return true end
        inst.OnEntitySleep = function () return true end
    end)
end

---------------------------------
-- 修改坟墓
AddPrefabPostInit("mound",function(inst)
    if inst.components.workable and inst.components.workable.onfinish then
        local old_onfinish = inst.components.workable.onfinish
        inst.components.workable.onfinish = function(inst, worker) 
            old_onfinish(inst, worker)
            if math.random() > 0.5 then
                inst:Remove()
            end
        end
    end
end)

---------------------------------
-- 使其不被清理物品事件删除
local strong = {
    "critterlab", --岩石巢穴
    "spawnpoint_master", --玩家出生点
    "multiplayer_portal", --大门
    "multiplayer_portal_moonrock_constr", --大门2
    "multiplayer_portal_moonrock", --大门3
    "stagehand", --舞台
    "junk_pile_big", --大垃圾堆
    "daywalkerspawningground", --梦魇疯猪刷新点
    "icefishing_hole", --大鲨鱼的洞
    "monkeyqueen", --月亮码头女王
    "atrium_gate", --中庭
    "daywalker_pillar", --裂开的柱子 梦魇疯猪
    "archive_lockbox_dispencer", --知识饮水机
    "archive_switch", --华丽基座开关
    "archive_switch_base", --华丽基座底座
    "archive_portal", --封印的传送门
    -- 刷新点好像自带 一个标签 不会被清理掉来着 算了留着
    "antlion_spawner", --蚁狮刷新点
    "dragonfly_spawner", --龙蝇刷新点
    "meteorspawner", --陨石刷新点
    "beequeenhive", --蜂后刷新点
    "crabking_spawner", --帝王蟹刷新点
    "ancient_altar_broken_spawner", --损坏的远古伪科技站刷新点
    -- 可能不需要的
    "archive_cookpot", --远古锅
}
for _,name in ipairs(strong) do
    AddPrefabPostInit(name, function(inst)
        inst:AddTag("strong_of")
    end)
end

---------------------------------
-- 月球风暴管理器  
AddComponentPostInit("moonstormmanager",function(self)
    local function NodeCanHaveMoonstorm2(node)
        return (not self.lastnodes or not table.contains(self.lastnodes, node.area))
            and not table.contains(node.tags, "lunacyarea")
            and not table.contains(node.tags, "sandstorm")
            and not TheWorld.Map:IsOceanAtPoint(node.cent[1], 0, node.cent[2])
    end
    -- 每次靠近npc时 地小就给原地位置
    self.GetNewWagstaffLocation = function(self, wagstaff)
        return wagstaff:GetPosition()
    end
    --可以正常生成 颗粒状传输 npc来完成实验
    setval(self.beginWagstaffHunt,"findnewcluelocation",function(v) return v end)
    --节点小一样可以添加
    self.CalcNewMoonstormBaseNodeIndex = function(self)
        local num_nodes = #TheWorld.topology.nodes
        local index_offset = math.random(1, num_nodes)
        local mindistsq = 12*12

        for i = 1, num_nodes do
            local ind = math.fmod(i + index_offset, num_nodes) + 1
            local new_node = TheWorld.topology.nodes[ind]

            if ind ~= self.currentbasenodeindextemp then
                local current_node = TheWorld.topology.nodes[self.currentbasenodeindextemp]

                if self.currentbasenodeindextemp ~= nil then
                    local new_x, new_z = new_node.cent[1], new_node.cent[2]
                    local current_x, current_z = current_node.cent[1], current_node.cent[2]

                    if NodeCanHaveMoonstorm2(new_node) and VecUtil_LengthSq(new_x - current_x, new_z - current_z) > mindistsq then
                        return ind
                    end
                else
                    if NodeCanHaveMoonstorm2(new_node) then
                        return ind
                    end
                end
            end
        end
        print("月球风暴组件：找不到有效节点")
    end
    -- 停止风暴 最好通过事件执行 TheWorld:PushEvent("ms_stopthemoonstorms")
    local old_StopCurrentMoonstorm = self.StopCurrentMoonstorm
    self.StopCurrentMoonstorm = function(self)
        old_StopCurrentMoonstorm(self)
        self._currentnodes = nil
        -- 是天体任务 且 非钓鱼事件 情况下，说明完成了天体任务
        if self.is_moonboss and not self.of_moonstorm then
            self.is_moonboss = nil
        end
    end
    -- 钓鱼事件结束后 重新再生成一个月亮风暴
    self.RestartMoonstorm_OF = function(self)
        if self.is_moonboss then
            if self.startstormtask then
                self.startstormtask:Cancel()
                self.startstormtask = nil
            end
            self.startstormtask = self.inst:DoTaskInTime(5, function() self:StartMoonstorm() end)
        end
    end
    -- 生成风暴 最好通过事件执行 TheWorld:PushEvent("ms_startthemoonstorms")
    self.StartMoonstorm = function(self, set_first_node_index,nodes)
        self:StopCurrentMoonstorm() --停止当前月亮风暴
        if self.startstormtask then
            self.startstormtask:Cancel()
            self.startstormtask = nil
        end

        if not TheWorld.net or not TheWorld.net.components.moonstorms == nil then
            print("世界网络，无月球风暴组件 moonstorms")
            return
        end

        if self.of_moonstorm then --是作为事件
            self.of_num = self.of_num and self.of_num + 1 or 1 --记录次数
        else
            self.is_moonboss = true
        end

        local checked_nodes = {}
        local new_storm_nodes = {} --nodes or {} --不需要传入的节点，自己找
        local first_node_index = set_first_node_index or nil


        local function propagatestorm(node, nodelist)
            if not checked_nodes[node] and NodeCanHaveMoonstorm2(TheWorld.topology.nodes[node]) then --节点可以有月亮风暴
                checked_nodes[node] = true

                table.insert(nodelist, node)
                -- print("     添加节点:", node)
            else
                print("没有合适节点")
            end
        end
        local trial = 0
        if not new_storm_nodes or #new_storm_nodes < 3 then
            while #new_storm_nodes < 1 do
                
                if set_first_node_index and trial < 1 then --设置第一个节点索引
                    trial = trial + 1
                else
                    if trial > 0 then
                        print("SET_FIRST_NODE_INDEX failed to generate enough nodes, using random") 
                    end
                    first_node_index = self:CalcNewMoonstormBaseNodeIndex() --计算新月风暴基本节点索引
                end
                if first_node_index == nil then
                    print("月亮风暴管理器无法启动月亮风暴")
                    return
                end
                propagatestorm(first_node_index, new_storm_nodes)
            end
        end

        self.currentbasenodeindextemp = first_node_index --临时的当前基本节点索引
        self._currentnodes = new_storm_nodes

        --清除 月亮风暴
        TheWorld.net.components.moonstorms:ClearMoonstormNodes()
        --添加 月亮风暴
        TheWorld.net.components.moonstorms:AddMoonstormNodes(new_storm_nodes, self.currentbasenodeindextemp)

        self.spawn_wagstaff_test_task = self.inst:DoPeriodicTask(10,function() self:DoTestForWagstaff() end)
        self.moonstorm_spark_task = self.inst:DoPeriodicTask(30,function() self:DoTestForSparks() end)
        self.moonstorm_lightning_task = self.inst:DoTaskInTime(math.random()*30+10,function() self:DoTestForLightning() end)

        self.stormdays = 0
    end
    -- 保存
    local old_Save = self.OnSave
    self.OnSave = function(self)
        local data = old_Save(self)
        if self.is_moonboss then
            data.currentnodes = self._currentnodes
        else
            data.currentnodes = nil
            data.currentbasenodeindex = nil
            data.startstormtask = nil
            -- 月相
            data.moonstyle_altar = nil --月亮式祭坛未启用
        end
        -- 击败次数？ 
        data._alterguardian_defeated_count = data._alterguardian_defeated_count - (self.of_num or 0)

        -- print("月亮风暴保存", self.of_moonstorm, self.is_moonboss, data.currentnodes, data.currentbasenodeindex)
        return data
    end
end)


--------------------------------------------------
-- 注册唯一（非唯一？ 可变数量）
local only = { --设置最大数量
    -- 眼骨、星空、舞台、格鲁姆雕像
    chester_eyebone = 1, --眼骨
    hutch_fishbowl = 1, --星空
    stagehand = 1, --舞台
    statueglommer = 1, --格罗姆雕像
}
TUNING.of_only = {}
for k,v in pairs(only) do
    AddPrefabPostInit(k,function(inst)
        inst:DoTaskInTime(0, function()
            -- 不存在
            if TUNING.of_only[k] == nil then TUNING.of_only[k] = {0, v} end
            TUNING.of_only[k][1] = TUNING.of_only[k][1] + 1
        end)
        inst:ListenForEvent("onremove", function(inst)
            TUNING.of_only[k][1] = TUNING.of_only[k][1] - 1
            if TUNING.of_only[k][1] < 0 then TUNING.of_only[k] = 0 end --不要少于0
        end)
    end)
end
--------------------------------------------------
-- 绿洲玻璃池再生
local grottos = {
    "grotto_waterfall_small1",
    "grotto_waterfall_small2",
}
local function OnFullMoon(inst, fullmoon)
    inst:SetPhysicsRadiusOverride(2.5)
    inst:RemoveTag("NOCLICK")

    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)

    local reset_fx = SpawnPrefab("halloween_moonpuff")
    reset_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

    if inst._type ~= nil then
        inst.AnimState:PlayAnimation("water_small"..inst._type, true)
    end

    inst:StopWatchingWorldState("isfullmoon", OnFullMoon)
end
for _,v in pairs(grottos) do
    AddPrefabPostInit(v,function(inst)
        if inst.components.workable then
            if inst.components.workable.onloadfn then --加载时执行的代码
                local old_fn = inst.components.workable.onloadfn
                inst.components.workable.onloadfn = function(inst, data)
                    if old_fn then old_fn(inst, data) end
                    if data.workleft <= 0 then --不存在玻璃矿时 监测月圆
                        inst:WatchWorldState("isfullmoon", OnFullMoon)
                    end
                end
            end
            if inst.components.workable.onwork then --挖矿时执行
                local old_fn = inst.components.workable.onwork
                inst.components.workable.onwork = function(inst, worker, workleft)
                    if old_fn then old_fn(inst, worker, workleft) end
                    if workleft <= 0 then --不存在玻璃矿时 监测月圆
                        inst:WatchWorldState("isfullmoon", OnFullMoon)
                    end
                end
            end
        end
    end)
end

-------------------------------------------------------
-- 蘑菇 变 蘑菇树
local mushroom = {
    blue_mushroom = "mushtree_tall", -- 蓝蘑菇
    green_mushroom = "mushtree_small", -- 绿蘑菇
    red_mushroom = "mushtree_medium", -- 红蘑菇
}
for k,v in pairs(mushroom) do
    AddPrefabPostInit(k,function(inst)
        --变成蘑菇树事件
        inst:ListenForEvent("become_mushtree",function(word)
            if math.random() < 0.25 then
                local mushtree = SpawnPrefab(v) --蘑菇树
                mushtree.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst:Remove()
            end
        end, TheWorld)
    end)
end

-------------------------------------------------------
-- 鹿鸭的旋风攻击
local function toofar(inst)
    local target = inst.components.combat.target
    local range = inst.components.combat:GetHitRange()
    if target ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = target.Transform:GetWorldPosition()
        local dx, dz = x1 - x, z1 - z
        local dist = dx * dx + dz * dz
        if dist > 0 then
            dist = math.sqrt(dist)
        end
        if range < dist then
            return true
        end
    end
    return false
end
local function onattackfn(inst)
    if inst.components.health and not inst.components.health:IsDead()
       and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
        if inst.CanDisarm then
            inst.sg:GoToState("disarm")
        else
            if inst:HasTag("small_boss") and toofar(inst) and math.random() < 0.45 then
                inst.sg:GoToState("spin_loop")
            else
                inst.sg:GoToState("attack")
            end
        end
    end
end

AddStategraphEvent("moose", EventHandler("doattack", onattackfn))

local function ShouldStopSpin(inst)
    local pos = inst:GetPosition()

    local nearby_player = FindClosestPlayerInRange(pos.x, pos.y, pos.z, 7.5, true)
    local time_out = inst.numSpins >= 2

    return not nearby_player or time_out
end
local function LightningStrike(inst)
    local rad = math.random(0,3)
    local angle = math.random() * 2 * PI
    local offset = Vector3(rad * math.cos(angle), 0, -rad * math.sin(angle))

    local pos = inst:GetPosition() + offset

    TheWorld:PushEvent("ms_sendlightningstrike", pos)
    TheWorld:PushEvent("ms_forceprecipitation", true)
end
local moose_spin = State{
    name = "spin_loop",
    tags = {"busy", "spinning", "attack"},

    onenter = function(inst)
        inst.DynamicShadow:SetSize(2.5,1.25)
        inst.AnimState:SetBank("mossling")
        inst.AnimState:SetBuild("mossling_angry_build")
        inst.Transform:SetScale(3,3,3)

        inst.AnimState:PlayAnimation("spin_loop")
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin", "spinLoop")

        local fx = SpawnPrefab("mossling_spin_fx")
        fx.entity:SetParent(inst.entity)
        fx.Transform:SetPosition(0,0.1,0)
        inst.components.burnable:Extinguish()
    end,

    onupdate = function(inst)
        if inst.sg.statemem.move then
            inst.components.locomotor:WalkForward()
        else
            inst.components.locomotor:StopMoving()
        end
    end,

    onexit = function(inst)
        inst.AnimState:SetBank("goosemoose")
        inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "goosemoose_yule_build" or "goosemoose_build")
        inst.AnimState:PlayAnimation("idle", true)
        inst.Transform:SetScale(.5,.5,.5)
        inst.SoundEmitter:KillSound("spinLoop")
        inst.components.locomotor:StopMoving()
    end,

    timeline=
    {
        TimeEvent(5*FRAMES, function(inst)
            if math.random() < 0.1 then
                LightningStrike(inst)
            end
        end),
        TimeEvent(0*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        TimeEvent(35*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        TimeEvent(70*FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },

    events=
    {
        EventHandler("animover",
        function(inst)
            if inst.numSpins == nil then
                inst.numSpins = 0
            end
            inst.numSpins = inst.numSpins + 1
            if ShouldStopSpin(inst) then
                inst.sg:GoToState("attack")
                inst.numSpins = 0
            else
                inst.sg:GoToState("spin_loop")
            end
        end),
    },
}
AddStategraphState("moose", moose_spin)

-------------------------------------------------------
-- 已有未添加的裂缝 添加到 总裂缝控制器中
AddPrefabPostInit("lunarrift_portal", function(inst)
    inst:DoTaskInTime(0,function(inst)
        local is_add = true
        for k,v in pairs(TheWorld.components.riftspawner:GetRifts()) do
            if k == inst then
                is_add = false
                break
            end
        end
        if is_add then
            TheWorld.components.riftspawner:AddRiftToPool(inst, inst.prefab)
        end
    end)
end)

-------------------------------------------------------
-- 为鱼人添加金灿灿的状态
local merm_gold = State{
    name = "gold",
    tags = {"busy", "gold"},

    onenter = function(inst)
        if inst.components.locomotor ~= nil then --停止移动
            inst.components.locomotor:StopMoving()
        end
        -- 更改动画为冰冻状态动画
        inst.AnimState:PlayAnimation("frozen", true)
        inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen") --替换身上的冰块
        inst.AnimState:OverrideMultColour(1, 215/255, 0, 1)
    end,

    onexit = function(inst)
        inst.AnimState:ClearOverrideSymbol("swap_frozen") --清除身上的冰块
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        if inst.components.workable then --挖矿次数减少生命值
            local self = inst.components.health
            if self then
                self:SetVal(self.maxhealth*inst.components.workable.workleft/3)
            end
            inst:RemoveComponent("workable")
        end
        if inst.components.lootdropper then --战利品替换回去
            inst.components.lootdropper:SetLoot({"pondfish","froglegs",})
        end
    end,

    events=
    {
        EventHandler("onthawgold", function(inst)
            inst.sg:GoToState("thaw")
        end),
    },
}
AddStategraphState("merm", merm_gold)

------------------------------------------------------
-- 护盾系统 受到攻击先扣除护盾值 再执行原方法
AddComponentPostInit("inventory",function(self)
    self.EquipHasShield = function(self)
        for k, v in pairs(self.equipslots) do
            if v.components.shield and v.components.shield:IsBroken() then
                return v.components.shield
            end
        end
    end
end)

AddComponentPostInit("combat",function(self)
    self.old_GetAttacked_haidiao = self.GetAttacked
    -- 受到攻击前 判断是否存在护盾值
    self.GetAttacked = function(self, ...)
        -- 对护盾造成伤害
        if self.inst.components.shield and self.inst.components.shield:IsBroken() then
            return self.inst.components.shield:DoDelta(self, ...)
        end
        if self.inst.components.inventory then
            local shield = self.inst.components.inventory:EquipHasShield()
            if shield then
                return shield:DoDelta(self, ...)
            end
        end
        return self:old_GetAttacked_haidiao(...)
    end
end)
------------------------------------------------------
-- 修改容器 部分物品只能放到库存中 容器内不行
AddComponentPostInit("container",function(self)
    self.old_CanTakeItemInSlot = self.CanTakeItemInSlot
    self.CanTakeItemInSlot = function(self, item, slot) --判断是否可放容器中
        return item ~= nil 
                and item.components.inventoryitem ~= nil
                and not item.components.inventoryitem.nocontainer 
                and self:old_CanTakeItemInSlot(item, slot)
    end
end)

-----------------------------------------------------
-- 假人 禁止换海钓竿
AddPrefabPostInit("sewing_mannequin", function(inst)
    if inst.components.inventory then
        local old_SwapEquipment = inst.components.inventory.SwapEquipment
        inst.components.inventory.SwapEquipment = function(self, other, equipslot_to_swap)
            if equipslot_to_swap == EQUIPSLOTS.HANDS then
                if other == nil then
                    return false
                end
                local other_inventory = other.components.inventory
                if other_inventory == nil or other_inventory.equipslots == nil then
                    return false
                end
                local ot_equipitem = other_inventory.equipslots["hands"]
                if ot_equipitem and ot_equipitem.prefab == "oceanfishingrod" then
                    return false
                end
            end
            old_SwapEquipment(self, other, equipslot_to_swap)
        end
    end
end)

-----------------------------------------------------
-- 蚁狮坑 自动消失
AddPrefabPostInit("antlion_sinkhole", function(inst)
    inst:DoTaskInTime(10, inst.Remove)
end)

-----------------------------------------------------
-- 世界状态组件
AddComponentPostInit("worldstate",function(self)
    self.data.iffog_of = false      -- 控制雾天增加潮湿值
    self.data.ifacidrain_of = false -- 控制酸雨掉血 需要水分组件
    self.inst:ListenForEvent("setclimate_of", function(inst, type)
        if type == "fog" then
            TheWorld:PushEvent("precipitationchanged", "none")
            self.data.iffog_of = true
            self.data.ifacidrain_of = false
        elseif type == "none" then
            TheWorld:PushEvent("ms_forceprecipitation", false) --是下雨天就关闭掉雨天fx
            TheWorld:PushEvent("precipitationchanged", "none")
            self.data.iffog_of = false
            self.data.ifacidrain_of = false
        elseif type == "acidrain" then
            TheWorld:PushEvent("precipitationchanged", type)
            self.data.iffog_of = false
            self.data.ifacidrain_of = true
        else
            TheWorld:PushEvent("precipitationchanged", type)
            self.data.iffog_of = false
            self.data.ifacidrain_of = false
        end
    end)
end)
-- 水分组件
AddComponentPostInit("moisture",function(self)
    local old_GetMoistureRate = self.GetMoistureRate
    self.GetMoistureRate = function(self)
        if TheWorld.state.iffog_of then
            return 0.1
        end
        return old_GetMoistureRate(self)
    end
    local old_GetMoistureRateAssumingRain = self._GetMoistureRateAssumingRain
    self._GetMoistureRateAssumingRain = function(self) 
        if TheWorld.state.ifacidrain_of then
            return 0.1
        end
        return old_GetMoistureRateAssumingRain(self)
    end
end)
-----------------------------------------------------
-- 梦魇疯猪 和 垃圾疯猪刷新
if rawget(GLOBAL, "Shard_SyncBossDefeated") then
    local old_Shard_SyncBossDefeated = GLOBAL.Shard_SyncBossDefeated
    GLOBAL.Shard_SyncBossDefeated = function(bossprefab, shardid)
        -- 有指定的世界id 且非本世界id 那么走原来的 
        if shardid and shardid ~= TheShard:GetShardId() then
            old_Shard_SyncBossDefeated(bossprefab, shardid)
            return
        end
        --默认认为 没有其他世界都是一个世界的事情
        if TheWorld then
            --触发刷事件
            TheWorld:PushEvent("master_shardbossdefeated", {bossprefab = bossprefab, shardid = shardid or TheShard:GetShardId()})
        end
    end
end
-- 快速过掉疯猪击败动画
AddPrefabPostInit("daywalker", function(inst)
    inst:ListenForEvent("newstate", function(inst, data)
        if data and data.statename == "defeat" then
            inst.components.timer:PauseTimer("despawn")
            inst.components.timer:SetTimeLeft("despawn", 10)
        end
    end)
end)
AddPrefabPostInit("daywalker2", function(inst)
    inst:ListenForEvent("newstate", function(inst, data)
        if data and data.statename == "defeat" then
            inst.components.timer:PauseTimer("despawn")
            inst.components.timer:SetTimeLeft("despawn", 10)
        end
    end)
end)

-----------------------------------------------------------------------
-- 老瓦刷出 被丢弃的垃圾  (月后垃圾岛加载范围外)测试代码: TheWorld.components.wagpunk_manager:DebugForceSpawnMachine()
AddComponentPostInit("wagpunk_manager",function(self)
    self.FindSpotForMachines = function(self)
        if self.machinemarker and not self:IsWerepigInCharge(Vector3(self.machinemarker.Transform:GetWorldPosition())) then
            local pos = Vector3(self.machinemarker.Transform:GetWorldPosition())

            if not IsAnyPlayerInRange(pos.x, 0, pos.z, PLAYER_CAMERA_SEE_DISTANCE) then
                return pos, true
            else
                if not TheWorld.components.timer:TimerExists("junkwagpunk") then
                    TheWorld.components.timer:StartTimer("junkwagpunk", math.random(240 + math.random()*240))

                    local offset = FindWalkableOffset(pos, math.random()*TWOPI, 30, 16, true)
                    if offset == nil then return nil end --防止崩
                    local finalpos = pos + offset

                    local radius = 16
                    local theta = self.machinemarker:GetAngleToPoint(finalpos.x, 0, finalpos.z)*DEGREES
                    local offsetclose = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))

                    self:SpawnJunkWagstaff(pos+offset, pos+offsetclose)
                end
            end
        else
            local nodes = {}

            for index, node in ipairs(TheWorld.topology.nodes) do
                if index ~= self._currentnodeindex and TheWorld.Map:IsLandTileAtPoint(node.cent[1], 0, node.cent[2]) then
                    table.insert(nodes, index)
                end
            end

            local current_node = TheWorld.topology.nodes[self._currentnodeindex]
            local current_x, current_z = current_node and current_node.cent[1], current_node and current_node.cent[2]

            while #nodes > 0 do
                local rand = math.random(#nodes)
                local index = nodes[rand]

                table.remove(nodes, rand)

                local new_node = TheWorld.topology.nodes[index]
                local new_x, new_z = new_node.cent[1], new_node.cent[2]
                local new_pos = Vector3(new_x, 0, new_z)

                if not IsAnyPlayerInRange(new_x, 0, new_z, PLAYER_CAMERA_SEE_DISTANCE) and
                    (current_node == nil or VecUtil_LengthSq(new_x - current_x, new_z - current_z) > 300 * 300)
                then
                    -- 复制代码过来
                    local offset = FindWalkableOffset(new_pos, math.random()*TWOPI, math.random()*10, 16, nil, nil, 
                                    function(pos)
                                        local valid = TheSim:CountEntities(pos.x, 0, pos.z, 10, nil, { "INLIMBO", "NOBLOCK", "FX" }) <= 0
                                        return valid and not IsAnyPlayerInRange(pos.x, 0, pos.z, PLAYER_CAMERA_SEE_DISTANCE)
                                    end)
                    if offset ~= nil then
                        self._currentnodeindex = index
                        return new_pos + offset, false
                    end
                end
            end
        end
    end 
end)
-----------------------------------------------------------------------
-- 刷出来的大鲨鱼不能传送 会炸档。进行修复
AddComponentPostInit("sharkboimanager",function(self)
    self.FindWalkableOffsetInArena = function(self, sharkboi)
        if self.arena == nil then
            return nil
        end

        if sharkboi and self.arena.sharkbois and self.arena.sharkbois[sharkboi] == nil then
            return nil
        end

        local offset
        for i = math.floor(self.arena.radius), 1, -TILE_SCALE do
            offset = FindWalkableOffset(self.arena.origin, math.random() * 2 * PI, i, 16, false, false)
            if offset then
                break
            end
        end
        
        return offset ~= nil and (self.arena.origin + offset) or self.arena.origin
    end
end)


---------------------------------------------------------------------------
-- 爆炸组件添加 炸冰能力
AddComponentPostInit("explosive",function(self)
    local old_OnBurnt = self.OnBurnt
    self.OnBurnt = function(self)
        -- 炸冰
        local stacksize = self.inst.components.stackable ~= nil and self.inst.components.stackable:StackSize() or 1
        local totaldamage = self.explosivedamage * stacksize

        local x, y, z = self.inst.Transform:GetWorldPosition()

        local world = TheWorld
        if world.components.oceanicemanager ~= nil then
            world.components.oceanicemanager:DamageIceAtPoint(x, y, z, totaldamage)
        end

        old_OnBurnt(self)
    end
end)

---------------------------------------------------------------------------
-- 使得伪玩家随从不能变芜猴
AddComponentPostInit("curseditem",function(self)
    local old_fn = self.checkplayersinventoryforspace
    self.checkplayersinventoryforspace = function(self, player)
        if player.refusing_monkey then
            return false
        end
        return old_fn(self, player)
    end
end)

---------------------------------------------------------------------------
-- 巨石枝 产物增加
local TREE_ROCK_DATA = require("prefabs/tree_rock_data")
-- 新的 那么就随便设置一个贴图
local DEFAULT_VINE_LOOT_DATA = {build = "gems", symbols = {"swap_zdy"}}
setmetatable(TREE_ROCK_DATA.VINE_LOOT_DATA, {__index=function(t,k) return DEFAULT_VINE_LOOT_DATA end})
local land_loots = {
    gears = .2, --齿轮
    dreadstone = .1, --绝望石
    horrorfuel = .1, --纯粹恐惧
    purebrilliance = .1, --纯粹辉煌
    lunarplant_husk = .1, --亮茄外壳
    ice = .01, --冰
    fig = .01, --无花果
}
for key, value in pairs(land_loots or {}) do
    TREE_ROCK_DATA.WEIGHTED_VINE_LOOT.DEFAULT[key] = value
end
TREE_ROCK_DATA.WEIGHTED_VINE_LOOT.DEFAULT.rocks = 2