-- 换皮肤
GLOBAL.SetSpellCB = function (target,player)
    if target and not target:IsValid() then return false end
    player = player or target.components.inventorytarget.owner
    local target_types = {}
    if PREFAB_SKINS[target.prefab] ~= nil then
        for _,target_type in pairs(PREFAB_SKINS[target.prefab]) do
            if TheInventory:CheckClientOwnership(player.userid, target_type) then
                table.insert(target_types,target_type)
            end
        end
    end
    if #target_types<=0 then
        return false
    end
    TheSim:ReskinEntity( target.GUID, target.skinname, target_types[math.random(#target_types)], nil, player.userid ) --玩家有的随机物品皮肤
end

------------------------------
-- 随机函数
local function RandomWeight(weight_table)
    local totalchance = 0
    local number = 1
    local next = nil
    -- 计算权重表所有项的权重和
    for m, n in ipairs(weight_table) do
        totalchance = totalchance + n.chance
    end

    while number > 0 do
        local next_chance = math.random()*totalchance 
        for m, n in ipairs(weight_table) do
            next_chance = next_chance - n.chance
            if next_chance <= 0 then
                next = n
                break
            end
        end
        if next ~= nil then
            number = number - 1
        end
    end
    return next
end
local function RandomWeight2(weight_table, number)
    local totalchance = 0
    number = number or 1
    local next = nil
    local loot = {}
    -- 计算权重表所有项的权重和
    for m, n in ipairs(weight_table) do
        totalchance = totalchance + n.chance
    end

    while number > 0 do
        local next_chance = math.random()*totalchance 
        for m, n in ipairs(weight_table) do
            next_chance = next_chance - n.chance
            if next_chance <= 0 then
                next = true
                table.insert(loot, n)
                break
            end
        end
        if next then
            number = number - 1
            next = nil
        end
    end
    return loot
end

GLOBAL.WeightRandom = RandomWeight
GLOBAL.WeightRandom2 = RandomWeight2


-- 返回指定数量 不可重复的随机项集
function table.randomnorepeat(t, need)
    local value = {}
    if #t <= need then
        return t
    end
    shuffleArray(t)
    for i = 1, need do
        table.insert(value, t[i])
    end
    return value
end
-- 返回指定数量 可重复的随机项集
function table.randomrepea(t, need)
    local value = {}
    for i = 1, need do
        table.insert(value, t[math.random(#t)])
    end
    return value
end

function table.length(t)
    local r = 0
    for _,v in pairs(t) do
        r = r + 1
    end
    return r
end


-------------------------------------
-- 控制台指令
-- GLOBAL.o_dug = function ()
--     GLOBAL.O_DUG = true
-- end

------------------------------------------------
-- 落石所需

local SMASHABLE_TAGS = { "smashable", "quakedebris", "_combat" }
local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost", "irreplaceable", "outofreach" }
local HEAVY_SMASHABLE_TAGS = { "smashable", "quakedebris", "_combat", "_inventoryitem", "NPC_workable" }
local HEAVY_NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost", "irreplaceable", "caveindebris", "outofreach" }

local function UpdateShadowSize(shadow, height)
    local scaleFactor = Lerp(.5, 1.5, height / 35)
    shadow.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
end

local function BreakDebris(debris)
    local x, y, z = debris.Transform:GetWorldPosition()
    SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(x, 0, z)
    debris:Remove()
end 

local function GetSpawnPoint(pt, rad, minrad)
    local theta = math.random() * 2 * PI
    local radius = math.random() * (rad or TUNING.FROG_RAIN_SPAWN_RADIUS)

    minrad = minrad ~= nil and minrad > 0 and minrad * minrad or nil

    local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
        local x = pt.x + offset.x
        local z = pt.z + offset.z
        return TheWorld.Map:IsAboveGroundAtPoint(x, 0, z)
            and (minrad == nil or offset.x * offset.x + offset.z * offset.z >= minrad)
            and not TheWorld.Map:IsPointNearHole(Vector3(x, 0, z))
    end)

    return result_offset ~= nil and pt + result_offset or nil
end

local function GroundDetectionUpdate(debris, override_density, mass)
    local x, y, z = debris.Transform:GetWorldPosition()
    if y <= .2 then
        if not debris:IsOnPassablePoint(false,true) then --不是陆地或船只
            debris:PushEvent("detachchild")
            debris:Remove()
        else
            local softbounce = false
            if debris:HasTag("heavy") then --是重的
                local ents = TheSim:FindEntities(x, 0, z, 2, nil, HEAVY_NON_SMASHABLE_TAGS, HEAVY_SMASHABLE_TAGS)
                for i, v in ipairs(ents) do
                    if v ~= debris and v:IsValid() and not v:IsInLimbo() then
                        softbounce = true --软反弹
                        if v:HasTag("quakedebris") then --是地震残骸
                            local vx, vy, vz = v.Transform:GetWorldPosition()
                            SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(vx, 0, vz)
                            v:Remove()
                        elseif v.components.workable ~= nil then
                            if v.sg == nil or not v.sg:HasStateTag("busy") then
                                local work_action = v.components.workable:GetWorkAction()
                                if (    (work_action == nil and v:HasTag("NPC_workable")) or
                                        (work_action ~= nil and HEAVY_WORK_ACTIONS[work_action.id]) ) and
                                    (work_action ~= ACTIONS.DIG
                                    or (v.components.spawner == nil and
                                        v.components.childspawner == nil)) then
                                    v.components.workable:Destroy(debris)
                                end
                            end
                        elseif v.components.combat ~= nil then
                            v.components.combat:GetAttacked(debris, 30, nil) --受到攻击 30点hp
                        elseif v.components.inventoryitem ~= nil then
                            if v.components.mine ~= nil then --矿
                                v.components.mine:Deactivate()
                            end
                            Launch(v, debris, TUNING.LAUNCH_SPEED_SMALL)
                        end
                    end
                end
            else 
                local ents = TheSim:FindEntities(x, 0, z, 2, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)
                for i, v in ipairs(ents) do
                    if v ~= debris and v:IsValid() and not v:IsInLimbo() then
                        softbounce = true
                        if v:HasTag("quakedebris") then
                            local vx, vy, vz = v.Transform:GetWorldPosition()
                            SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(vx, 0, vz)
                            v:Remove()
                        elseif v.components.combat ~= nil and not (v:HasTag("epic") or v:HasTag("wall")) then
                            v.components.combat:GetAttacked(debris, 20, nil)
                        end
                    end
                end
            end

            debris.Physics:SetDamping(.9)

            if softbounce then
                local speed = 3.2 + math.random()
                local angle = math.random() * 2 * PI
                debris.Physics:SetMotorVel(0, 0, 0)
                debris.Physics:SetVel(
                    speed * math.cos(angle),
                    speed * 2.3,
                    speed * math.sin(angle)
                )
            end

            debris.shadow:Remove()
            debris.shadow = nil

            debris.updatetask:Cancel()
            debris.updatetask = nil

            local density = math.random()
            if density <= override_density then
                debris.persists = true
                debris.entity:SetCanSleep(true)
                debris:RestartBrain()

                debris.Physics:SetMass(mass)
                -- debris.Physics:SetDamping(5)
                -- 清醒
                if debris.components.sleeper then
                    debris.components.sleeper:WakeUp()
                end
                if debris._restorepickup then
                    debris._restorepickup = nil
                    if debris.components.inventoryitem ~= nil then
                        debris.components.inventoryitem.canbepickedup = true
                    end
                end
                debris:PushEvent("stopfalling")
            elseif debris:GetTimeAlive() < 1.5 then
                --第一次反弹
                debris:DoTaskInTime(softbounce and .4 or .6, BreakDebris)
            else
                --我们错过了第一次反弹的机会，所以这次立即破发
                BreakDebris(debris)
            end
        end
    elseif debris:GetTimeAlive() < 3 then
        if y < 2 then
            debris.Physics:SetMotorVel(0, 0, 0)
        end
        UpdateShadowSize(debris.shadow, y)
    elseif debris:IsInLimbo() then --从场景这移除了 但保持它 恢复原状态
        debris.persists = true
        debris.entity:SetCanSleep(true)
        debris.shadow:Remove()
        debris.shadow = nil
        debris.updatetask:Cancel()
        debris.updatetask = nil
        if debris._restorepickup then
            debris._restorepickup = nil
            if debris.components.inventoryitem ~= nil then
                debris.components.inventoryitem.canbepickedup = true
            end
        end
        debris:PushEvent("stopfalling")
    elseif debris.prefab == "mole" or debris.prefab == "rabbit" or debris.prefab == "carrat" then
        debris:PushEvent("detachchild")
        debris:Remove()
    else
        BreakDebris(debris)
    end
end

local function SpawnDebris(spawn_point, loot)
    local prefab = loot.item
    local Mass = 0
    if prefab ~= nil then
        local debris = SpawnPrefab(prefab)
        if debris ~= nil then
            debris.entity:SetCanSleep(false)
            debris.persists = false

            debris:StopBrain()

            if (prefab == "rabbit" or prefab == "mole" or prefab == "carrat") and debris.sg ~= nil then
                debris.sg:GoToState("fall")
            end
            if debris.components.inventoryitem ~= nil and debris.components.inventoryitem.canbepickedup then
                debris.components.inventoryitem.canbepickedup = false
                debris._restorepickup = true
            end
            if math.random() < .5 then
                debris.Transform:SetRotation(180)
            end
            if debris.Physics then
                -- 设置质量，建筑为0，默认 1 物品
                Mass = debris.Physics:GetMass() 
                debris.Physics:SetMass(1)
                debris.Physics:Teleport(spawn_point.x, 35, spawn_point.z)
                debris.Physics:SetDamping(0)
                debris.Physics:SetMotorVel(0,-30+math.random()*10,0)
            end
            -- 设置睡眠
            if debris.components.sleeper then
                debris.components.sleeper:GoToSleep(3)
            end
            debris.shadow = SpawnPrefab("warningshadow")
            debris.shadow:ListenForEvent("onremove", function(debris) debris.shadow:Remove() end, debris)
            debris.shadow.Transform:SetPosition(spawn_point.x, 0, spawn_point.z)
            UpdateShadowSize(debris.shadow, 35)

            debris.updatetask = debris:DoPeriodicTask(FRAMES, GroundDetectionUpdate, nil, loot.chance, Mass)
            debris:PushEvent("startfalling")
        end
        return debris
    end
end
local function DoDropForPlayer(player, reschedulefn, dt, loots, need, rad, minrad)
    local px, py, pz = player.Transform:GetWorldPosition()
    local char_pos = Vector3(px, py, pz)
    local spawn_point = GetSpawnPoint(char_pos, rad, minrad)
    local loot = WeightRandom(loots)
    if spawn_point ~= nil then
        SpawnDebris(spawn_point, loot)
    end
    reschedulefn(player, dt, loots, need-1, rad, minrad)
end

GLOBAL.SpawnDebrisLoots = function(player, dt, loots, need, rad, minrad)
    if need <= 0 then return end
    if player.droptask ~= nil then
        player.droptask:Cancel()
    end
    player.droptask = player:DoTaskInTime(dt+math.random()*0.1, DoDropForPlayer, SpawnDebrisLoots, dt, loots, need, rad, minrad)
end

--------------------------------
-- 定期在玩家附近陆地生成物品
local function SpawnGrow(spawn_point, loot)
    local prefab = loot.item
    local Mass = 0
    if prefab ~= nil then
        local debris = SpawnPrefab(prefab)
        if debris ~= nil then
            if math.random() < .5 then
                debris.Transform:SetRotation(180)
            end
            -- 设置睡眠
            if debris.components.sleeper and not loot.sleeper then
                debris.components.sleeper:GoToSleep(3)
            end

            debris.Transform:SetPosition(spawn_point.x, 0, spawn_point.z)

            if loot.fn ~= nil and type(loot.fn) == "function" then
                loot.fn(debris, spawn_point.x, 0, spawn_point.z)
            end
        end
        return debris
    end
end
local function DoGrowForPlayer(player, reschedulefn, dt, loots, need, rad, minrad)
    local px, py, pz = player.Transform:GetWorldPosition()
    local char_pos = Vector3(px, py, pz)
    local spawn_point = GetSpawnPoint(char_pos, rad, minrad)
    local loot = WeightRandom(loots)
    if spawn_point ~= nil then
        SpawnGrow(spawn_point, loot)
    end
    reschedulefn(player, dt, loots, need-1, rad, minrad)
end

GLOBAL.SpawnGrowTheGround = function(player, dt, loots, need, rad, minrad)
    if player == nil or need <= 0 then return end
    if player.growtask ~= nil then
        player.growtask:Cancel()
    end
    player.growtask = player:DoTaskInTime(dt+math.random()*0.1, DoGrowForPlayer, SpawnGrowTheGround, dt, loots, need, rad, minrad)
end


--------------------------------
-- 天体英雄的环型激光
local BASE_NUM_ANGULAR_STEPS = 10
local SWEEP_ANGULAR_LENGTH = 30
local BASE_SWEEP_DISTANCE = 8
local MIN_SWEEP_DISTANCE = 3
local SECOND_BLAST_TIME = 22*FRAMES
GLOBAL.SpawnSweep = function(inst, target_pos)
    local gx, gy, gz = inst.Transform:GetWorldPosition()

    local angle = nil
    local dist = nil
    local angle_step_dir = 1
    local x_dir = 1

    if target_pos == nil then
        angle = DEGREES * (inst.Transform:GetRotation() + (SWEEP_ANGULAR_LENGTH/2))
        dist = BASE_SWEEP_DISTANCE
        x_dir = -1
        angle_step_dir = -1
    else
        angle = math.atan2(gz - target_pos.z, gx - target_pos.x) - (SWEEP_ANGULAR_LENGTH * DEGREES/2)
        dist = math.max(math.sqrt(inst:GetDistanceSqToPoint(target_pos:Get())), MIN_SWEEP_DISTANCE)
    end

    local num_angle_steps = BASE_NUM_ANGULAR_STEPS + RoundBiasedDown((math.abs(dist) - BASE_SWEEP_DISTANCE) / 2)
    local angle_step = (SWEEP_ANGULAR_LENGTH / num_angle_steps) * DEGREES

    local targets, skiptoss = {}, {}
    local sbtargets, sbskiptoss = {}, {}
    local x, z = nil, nil
    local delay = nil

    local i = -1
    while i < num_angle_steps do
        i = i + 1
        delay = math.max(0, i - 1)*FRAMES

        x = gx - (x_dir * dist * math.cos(angle))
        z = gz - dist * math.sin(angle)
        angle = angle + (angle_step_dir * angle_step)

        local first = (i == 0)
        local x1, z1 = x, z
        inst:DoTaskInTime(delay, function(inst2)
            local fx = SpawnPrefab("alterguardian_laser")
            fx.Transform:SetPosition(x1, 0, z1)
            fx:Trigger(0, targets, skiptoss)
        end)

        inst:DoTaskInTime(delay + SECOND_BLAST_TIME, function(inst2)
            local fx = SpawnPrefab("alterguardian_laser")
            fx.Transform:SetPosition(x1, 0, z1)
            fx:Trigger(0, sbtargets, sbskiptoss, true)
        end)
    end

    inst:DoTaskInTime(i*FRAMES, function(inst2)
        local fx = SpawnPrefab("alterguardian_laser")
        fx.Transform:SetPosition(x, 0, z)
        fx:Trigger(0, targets, skiptoss)
    end)

    inst:DoTaskInTime((i+1)*FRAMES, function(inst2)
        local fx = SpawnPrefab("alterguardian_laser")
        fx.Transform:SetPosition(x, 0, z)
        fx:Trigger(0, targets, skiptoss)
    end)
end


-- 添加岛屿 参数 布局名称、是否忽略已有同名岛
GLOBAL.of_spawnlayout = function(name, ignore)
    local obj_layout = require("map/object_layout_of")
    local entities = {}
    local map_width, map_height = TheWorld.Map:GetSize()
    local add_fn = {
        fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
            print("adding, ", prefab, points_x[current_pos_idx], points_y[current_pos_idx])
            local x = (points_x[current_pos_idx] - width/2.0)*TILE_SCALE
            local y = (points_y[current_pos_idx] - height/2.0)*TILE_SCALE
            x = math.floor(x*100)/100.0
            y = math.floor(y*100)/100.0
            SpawnPrefab(prefab).Transform:SetPosition(x, 0, y)
        end,
        args={entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
    }
    local function AddSquareTopology(topology, left, top, size, room_id, tags)
        print("  添加节点",room_id)
        local index = #topology.ids + 1
        topology.ids[index] = room_id
        topology.story_depths[index] = 0

        local node = {}
        node.area = size * size
        node.c = 1 -- colour index
        node.cent = {left + (size / 2), top + (size / 2)}
        node.neighbours = {}
        node.poly = { {left, top},
                      {left + size, top},
                      {left + size, top + size},
                      {left, top + size}
                    }
        node.tags  = tags
        node.type = NODE_TYPE.Default
        node.x = node.cent[1]
        node.y = node.cent[2]

        node.validedges = {}

        topology.nodes[index] = node
    end
    -- 判断节点名称是否已经有了
    local function topology_room(name)
        local roomid = "StaticLayoutIsland:"..name
        for k, v in pairs(TheWorld.topology.ids) do -- 可以直接换成 table.contains
            if v == roomid then
                return k
            end
        end
        return
    end
    local function is_ocean(_left, _top, tile_size)
        for x = 0, tile_size do
            for y = 0, tile_size do
                local tile = TheWorld.Map:GetTile(_left + x, _top + y)
                if tile < GROUND.OCEAN_COASTAL or tile > GROUND.OCEAN_WATERLOG then
                    return false
                end
            end
        end
        return true
    end
    local function getdt()
        local layout = obj_layout.LayoutForDefinition(name)
        if not ignore and topology_room(name) then print("存在该房间") return end
        if layout == nil then print("找不到目标地形："..name) return end
        local tile_size = #layout.ground
        local candidtates = {}
        local topology_delta = 1
        local num_steps = math.floor((map_width - tile_size) / tile_size) --向下取整,比如世界宽100地皮,布局10*10地皮, 90/10 = 9
        for x = 0, num_steps do
            for y = 0, num_steps do
                local left = 8 + (x > 0 and ((x * math.floor(map_width / num_steps)) - tile_size - 16) or 0) -- 大概是限制距离地图边界
                local top  = 8 + (y > 0 and ((y * math.floor(map_height / num_steps)) - tile_size - 16) or 0)
                if is_ocean(left, top, tile_size) then -- 目标区域全部地皮是否满足条件
                    table.insert(candidtates, {top = top, left = left})
                end
            end
        end
        print("  有" ..tostring(#candidtates) .. "区域，符合条件")
        if #candidtates > 0 then
            local world_size = (tile_size + (topology_delta*2))*4

            shuffleArray(candidtates) -- 洗牌打乱
            for _, candidtate in ipairs(candidtates) do
                local top, left = candidtates[1].top, candidtates[1].left
                local world_top, world_left = (left-topology_delta)*4 - (map_width * 0.5 * 4), (top-topology_delta)*4 - (map_height * 0.5 * 4)

                print("地图大小",map_width,map_height, world_top, world_left)
                -- 替换地皮,物品
                obj_layout.Place({left, top}, name, add_fn, nil, TheWorld.Map)

                -- 添加节点
                if layout.add_topology ~= nil then
                    local room_id = layout.add_topology.room_id or "StaticLayoutIsland:"..name
                    AddSquareTopology(TheWorld.topology, world_top, world_left, world_size,not ignore and room_id or (room_id..#TheWorld.topology.ids), layout.add_topology.tags)
                end

                return true

            end
        end
    end

    if getdt() then
        TheNet:Announce("生成了全新岛屿")
        return
    end
    TheNet:Announce("已存在或未找到合适位置生成新岛屿")
end

--------------------------------
-- debug
GLOBAL.getval = function(fn, path)
    local val = fn
    for entry in path:gmatch("[^%.]+") do -- 正则: 取一个或多个任意字符的补集
        local i=1
        while true do
            local name, value = GLOBAL.debug.getupvalue(val, i) -- 此函数返回函数 val 的第 i 个上值的名字和值。 如果该函数没有那个上值，返回 nil 。 值为任意类型
            if name == entry then 
                val = value
                break
            elseif name == nil then -- 到最后，也没有找到
                return
            end
            i=i+1
        end
    end
    return val
end
GLOBAL.setval = function(fn, path, new) --初始fn "xx.xxx.xxx" 新函数
    local val = fn
    local prev = nil
    local i
    for entry in path:gmatch("[^%.]+") do
        i = 1
        prev = val
        while true do
            local name, value = GLOBAL.debug.getupvalue(val, i)
            -- print("参数", name or "nil")
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i=i+1
        end
    end

    GLOBAL.debug.setupvalue(prev, i, new) -- 这个函数将 new 设为函数 prev 的第 i 个上值。 如果函数没有那个上值，返回 nil 否则，返回该上值的名字。 
    return val --返回旧函数 方便改回去
end

-- local self = require("components/stackable_replica") 
-- local NEW_STACK_SIZES = {    
--     TUNING.STACK_SIZE_MEDITEM,
--     TUNING.STACK_SIZE_SMALLITEM,
--     TUNING.STACK_SIZE_LARGEITEM,
--     TUNING.STACK_SIZE_TINYITEM,
--     100,
--     500,
--     999,
-- }
-- local NEW_STACK_SIZE_CODES = table.invert(NEW_STACK_SIZES)
-- setval(self.OriginalMaxSize, "STACK_SIZES", NEW_STACK_SIZES)
-- setval(self.MaxSize, "STACK_SIZES", NEW_STACK_SIZES)
-- setval(self.SetMaxSize, "STACK_SIZE_CODES", NEW_STACK_SIZE_CODES)
-- 举例
-- local function a() print("a") end
-- local function b() a() end
-- function c() b() end
-- setval(c, "b.a", function() print("新a") end)


-------------------------------------------------
-- 器灵
local glasscutterbrain = require("brains/glasscutterbrain")
local function OnPutInInventory(inst, owner) --装入库存时
    inst.components.follower:SetLeader(owner)
end
local function OnDropped(inst) --丢下时 将耐久转化为生命
    inst:RestartBrain()
    inst.components.health:SetVal(inst.components.finiteuses and inst.components.finiteuses.current or 200)
end
local function OnPickup(inst) --捡起时 将生命转换为耐久
    inst:StopBrain()
    if inst.components.finiteuses then
        inst.components.finiteuses:SetUses(inst.components.health.currenthealth)
    end
end

local function RetargetFn(inst, target)
    return FindEntity(
        inst,
        20,
        function(guy)
            return not guy:HasTag("player") and inst.components.combat:CanTarget(guy)
        end,
        { "_combat","_health" },
        { "player", "playerghost", "INLIMBO" , "abigail", "NOCLICK", "companion", "flying"}, --不能攻击 companion同伴
        {"monster", "prey", "insect", "hostile", "character", "animal", "wonkey","pirate"}
    )
end
local function KeepTargetFn(inst, target)
    -- if inst.components.follower and inst.components.follower.leader and not inst:IsNear(inst.components.follower.leader, inst.distance_around or 4) then --离追随者距离少于4地皮
    --     return false
    -- end
    return inst.components.combat.target == target or inst.components.combat:CanTarget(target)
end
local function MakeWeaponPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:SetCapsule(rad, 1)
end

GLOBAL.GiveLife = function(inst, player)
    if inst == nil or player == nil or player == inst then return end
    if not inst:HasTag("weapon") or inst:HasTag("flying") then return end --还是限制一下为武器
    
    SetSpellCB(inst, player) --设置皮肤
    RemovePhysicsColliders(inst) --移除物理
    -- inst.Transform:SetPosition(player.Transform:GetWorldPosition())
    inst:AddTag("flying")
    inst:AddTag("companion")
    inst:AddTag("crazy") --可以攻击影怪？
    --声音
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst) --添加库存物理
    -- 可以移动的
    if inst.components.locomotor == nil then
        inst:AddComponent("locomotor")
    end
    inst.components.locomotor:EnableGroundSpeedMultiplier(false) --不需要地面倍增
    inst.components.locomotor:SetTriggersCreep(false) --不需要慢速
    inst.components.locomotor.runspeed = 10
    inst.components.locomotor.walkspeed = 12
    -- 可以战斗的
    if inst.components.combat == nil then
        inst:AddComponent("combat")
    end
    inst.components.combat:SetRange(1.5) --攻击范围
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetDefaultDamage(inst.components.weapon and inst.components.weapon.damage or 10) --攻击伤害
    inst.components.combat:SetAttackPeriod(1) --攻击周期
    inst.components.combat:SetRetargetFunction(5, RetargetFn) --重置攻击目标
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn) --保持目标
    -- 拥有生命
    if inst.components.health == nil then
        inst:AddComponent("health")
    end
    inst.components.health:SetMaxHealth(inst.components.finiteuses and inst.components.finiteuses.current or 200) --设置耐久的
    inst.components.health:SetAbsorptionAmount(0.8)  --减少80%受到的伤害
    -- 追随组件
    if inst.components.follower == nil then
        inst:AddComponent("follower")
    end
    inst.components.follower:SetLeader(player)
    inst.components.follower:StopLeashing()

    if inst.components.inventoryitem then 
        inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
        inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
        inst.components.inventoryitem:SetOnPickupFn(OnPickup)
    end

    -- 删除漂浮组件
    inst:RemoveComponent("floater")

    inst:SetStateGraph("SGglasscutter")
    inst:SetBrain(glasscutterbrain) --设置脑子 
    inst:RestartBrain() --重启脑子       
end
-- 管理员可以通过
-- GiveLife(TheInput:GetWorldEntityUnderMouse(),ThePlayer)
----------------------------------------------------------------------------
-- 抛飞装备的武器
local function LaunchItem(inst, target, item)
    if item.Physics ~= nil and item.Physics:IsActive() then
        local x, y, z = item.Transform:GetWorldPosition()
        item.Physics:Teleport(x, .1, z)

        x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = target.Transform:GetWorldPosition()
        local angle = math.atan2(z1 - z, x1 - x) + (math.random() * 20 - 10) * DEGREES
        local speed = 5 + math.random() * 2
        item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
    end
end
local function OnHitOther(inst, data)
    if data.target ~= nil and data.target.components.inventory ~= nil and not data.target:HasTag("stronggrip") then
        local item = data.target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item ~= nil then
            data.target.components.inventory:DropItem(item)
            LaunchItem(inst, data.target, item)
        end
    end
end
--MakeGroundPounder(ThePlayer:GetPosition()) --在自身位置释放一个波
GLOBAL.MakeGroundPounder = function(pos, t)
    local data = t or {} 
    SpawnPrefab("collapse_small").Transform:SetPosition(pos:Get())
    local fx = CreateEntity()
    fx.entity:AddTransform()
    fx.Transform:SetPosition(pos:Get()) --设置坐标
    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    fx:AddComponent("combat") --战斗组件
    fx.components.combat:SetDefaultDamage(data.damage or 0) --造成的伤害

    fx.overridepkname = data.name or "【未知】" --杀死玩家时 宣告的内容

    fx:AddComponent("groundpounder") --地震波组件
    fx.components.groundpounder.numRings = data.numRings or 1 -- 波数
    fx.components.groundpounder.destroyer = data.destroyer ~= nil and data.destroyer or false --是否破坏周围
    fx.components.groundpounder.burner = data.burner ~= nil and data.burner or false --是否点燃周围
    fx.components.groundpounder.radiusStepDistance = data.radiusStepDistance or 4 --半径步长
    fx.components.groundpounder.damageRings = data.damageRings or 0 --伤害半径
    fx.components.groundpounder.destructionRings = data.destructionRings or 0 --破坏半径
    fx.components.groundpounder.platformPushingRings = data.platformPushingRings or 0 -- 推船环半径地皮
    fx.components.groundpounder.inventoryPushingRings = data.inventoryPushingRings or 0 --地面物品推离环半径
    fx.components.groundpounder.ringDelay = data.ringDelay or 0.2 --每波间隔
    fx.components.groundpounder.initialRadius = data.initialRadius or 1 --初始半径
    fx.components.groundpounder.pointDensity = data.pointDensity or 0.25 --点特效密度
    fx.components.groundpounder.noTags = data.noTags or { "FX", "NOCLICK", "DECOR", "INLIMBO" } --不进行操作的实体标签
    fx.components.groundpounder.workefficiency = data.workefficiency or nil --工作效率 砍树挖矿。有它，必定破坏周围
    fx.components.groundpounder.groundpounddamagemult = data.groundpounddamagemult or 1 --伤害系数
    fx.components.groundpounder.groundpoundFn = data.groundpoundFn or nil --触发地震波时执行方法 参数是fx自己

    fx.persists = false --不要保存
    fx:DoTaskInTime(3, fx.Remove) --持续3s后就删除

    if data.ejection then
        fx:ListenForEvent("onhitother", OnHitOther) --监听攻击反馈事件 执行武器飞走
    end

    fx.components.groundpounder:GroundPound() --触发地震波
end

---------------------------------------------------------

local AREAATTACK_MUST_TAGS = { "_combat" }
local AREA_EXCLUDE_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }
local ICESPAWNTIME =  0.25
    
local function DoSpawnIceSpike(inst, x, z, s)
    local fx = SpawnPrefab("icespike_fx_"..tostring(math.random(1, 4)))
    fx.Transform:SetPosition(x, 0, z)
    fx.Transform:SetScale(s, s, s)

    local ents = TheSim:FindEntities(x,0,z,1.5,AREAATTACK_MUST_TAGS,AREA_EXCLUDE_TAGS)
    if #ents > 0 then
        for i,ent in ipairs(ents)do
            if ent ~= inst then
                if not inst._icespikeshit_targets[ent.GUID] and inst.components.combat:CanTarget(ent) and not ent.deerclopsattacked then
                    inst.components.combat:DoAttack(ent)
                    inst._icespikeshit = true
                    inst._icespikeshit_targets[ent.GUID] = true
                end
                ent.deerclopsattacked = true
                ent:DoTaskInTime(ICESPAWNTIME +0.03,function() ent.deerclopsattacked = nil end)
            end
        end
    end
end

local function CheckForIceSpikesMiss(inst)
    if inst._icespikeshit_task ~= nil then
        inst._icespikeshit_task:Cancel()
        inst._icespikeshit_task = nil
    end

    if not inst._icespikeshit then
        inst:PushEvent("onmissother") -- for ChaseAndAttack
    end
end

GLOBAL.SpawnIceFx = function(pos, player)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    local x1,y1,z1 = player.Transform:GetWorldPosition()
    inst.Transform:SetPosition(pos:Get()) --设置坐标 根据浮标位置，来计算朝向
    inst:ForceFacePoint(x1,y1,z1) --朝向
    inst.Transform:SetPosition(x1,y1,z1) --设置坐标

    inst.overridepkname = "【冰川】"

    inst:AddComponent("combat") --战斗组件
    inst.components.combat:SetDefaultDamage(20) --造成的伤害

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.persists = false --不要保存
    inst:DoTaskInTime(3, inst.Remove) --持续3s后就删除

    inst._icespikeshit_targets = {}

    local AOEarc = 35

    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = inst.Transform:GetRotation()

    local num = 3
    for i=1,num do
        local newarc = 180 - AOEarc
        local theta =  inst.Transform:GetRotation()*DEGREES
        local radius = TUNING.DEERCLOPS_ATTACK_RANGE - ( (TUNING.DEERCLOPS_ATTACK_RANGE/num)*i )
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        inst:DoTaskInTime(math.random() * .25, DoSpawnIceSpike, x+offset.x, z+offset.z, 1.25)
    end

    for i=math.random(12,17),1,-1 do
        local theta =  ( angle + math.random(AOEarc *2) - AOEarc ) * DEGREES
        local radius = TUNING.DEERCLOPS_ATTACK_RANGE * math.sqrt(math.random())
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        inst:DoTaskInTime(math.random() * ICESPAWNTIME, DoSpawnIceSpike, x+offset.x, z+offset.z, 2)
    end

    for i=math.random(5,8),1,-1 do
        local newarc = 180 - AOEarc
        local theta =  ( angle -180 + math.random(newarc *2) - newarc ) * DEGREES
        local radius = 2 * math.random() +1
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        inst:DoTaskInTime(math.random() * ICESPAWNTIME, DoSpawnIceSpike, x+offset.x, z+offset.z, 0.85)
    end 

    inst._icespikeshit = false
    if inst._icespikeshit_task ~= nil then
        inst._icespikeshit_task:Cancel()
    end
    inst._icespikeshit_task = inst:DoTaskInTime(ICESPAWNTIME + FRAMES, CheckForIceSpikesMiss)
    --监听攻击事件 来冰冻
    local function OnHitOther(inst, data)
        local other = data.target
        if other ~= nil then
            if not (other.components.health ~= nil and other.components.health:IsDead()) then
                if other.components.freezable ~= nil then
                    other.components.freezable:AddColdness(2)
                end
                if other.components.temperature ~= nil then
                    local mintemp = math.max(other.components.temperature.mintemp, 0)
                    local curtemp = other.components.temperature:GetCurrent()
                    if mintemp < curtemp then
                        other.components.temperature:DoDelta(math.max(-5, mintemp - curtemp))
                    end
                end
            end
            if other.components.freezable ~= nil then
                other.components.freezable:SpawnShatterFX()
            end
        end
    end
    inst:ListenForEvent("onhitother", OnHitOther)
end

---------------------------------------------------------
-- 阿比盖尔重新设置脑子及其它
GLOBAL.GiveAbigail = function(player)
    local inst = SpawnPrefab("abigail")
    inst.Transform:SetPosition(player.Transform:GetWorldPosition())
    inst.components.locomotor.walkspeed = 5
    inst.components.follower:SetLeader(player) --跟随玩家

    --随机等级的生命值
    local level = math.random(1,3)
    inst.components.health:SetMaxHealth(TUNING["ABIGAIL_HEALTH_LEVEL"..level])

    local light_vals = TUNING.ABIGAIL_LIGHTING[level] or TUNING.ABIGAIL_LIGHTING[1]
    if light_vals.r ~= 0 then
        inst.Light:Enable(not inst.inlimbo)
        inst.Light:SetRadius(light_vals.r)
        inst.Light:SetIntensity(light_vals.i)
        inst.Light:SetFalloff(light_vals.f)
    else
        inst.Light:Enable(false)
    end
    inst.AnimState:SetLightOverride(light_vals.l)

    inst.components.combat:SetRetargetFunction(5, RetargetFn) --重置攻击目标
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn) --保持目标
    inst:ListenForEvent("death",function(inst) --死亡时消失
        inst.AnimState:PlayAnimation("dissipate")
        inst:ListenForEvent("animover", inst.Remove)
    end)

    inst.is_defensive = false --改为进攻状态
    inst.persists = false --退出时不会保存
    inst:SetBrain(glasscutterbrain) --设置脑子  
end

---------------------------------------------------------
-- 玩家脑子
local playerbrain = require("brains/playerbrain")
-- 在鼠标所指位置，生成一个拿玻璃刀的威尔逊
GLOBAL.spawnprefabplayer = function(inst, player)
    local inst = inst or SpawnPrefab("wilson")
    local v = SpawnPrefab("glasscutter")
    inst.refusing_monkey = true --添加不能变猴子属性
    inst.name = "【伪玩家】"
    inst.components.inventory:Equip(v) --装备武器

    inst:AddComponent("follower")
    inst.components.follower:SetLeader(player or ThePlayer) --跟随玩家
    inst.components.combat:SetRetargetFunction(5, RetargetFn) --重置攻击目标
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn) --保持目标

    inst:ListenForEvent("death",function(inst) --死亡时消失
        -- 防止因为开了 灵魂携带物品 导致物品没法正常掉落。
        if inst.components.inventory.oldDropEverythingFn then
            inst.components.inventory:oldDropEverythingFn()
        end

        inst.AnimState:PlayAnimation("dissipate")
        inst:ListenForEvent("animover", inst.Remove)
    end)

    inst.persists = false --退出时不会保存
    inst:SetBrain(playerbrain) --设置脑子 
end

---------------------------------------------------------
-- boss小弟
local function RemoveListener(t, event, inst)
    if t then
        local listeners = t[event]
        if listeners then
            listeners[inst] = nil
            if next(listeners) == nil then
                t[event] = nil
            end
        end
    end
end
GLOBAL.GiveBossCompanion = function(player)
    if not player or player and not player:HasTag("player") then print("目标非玩家", player) return end
    if player.boss_companion then
        local inst = player.boss_companion
        if inst:IsValid() and inst.components.health then
            inst.components.health:DoDelta(9999) --恢复生命值
        end
        return
    end
    local boss_list = {
        "shadow_rook",
        "shadow_knight",
        "shadow_bishop",
        "spiderqueen",
        "leif",
        "leif_sparse",
        "deerclops",
        "moose",
        "warg",
        "bearger",
        "klaus",
        "shadowthrall_hands",
        "shadowthrall_horns",
        "shadowthrall_wings",
    }
    local inst = SpawnPrefab(boss_list[math.random(#boss_list)]) 
    player.boss_companion = inst
    inst.Transform:SetPosition(player.Transform:GetWorldPosition())
    inst.Physics:SetCapsule(0.1, 1) --设置碰撞体胶囊的大小 小一点，直接改为不和玩家碰撞也成。
    inst:AddTag("companion") --伙伴
    inst.distance_around = 16 --范围
    if inst.components.locomotor == nil then
        inst:AddComponent("locomotor")
        --设置速度
        inst.components.locomotor.runspeed = 10
        inst.components.locomotor.walkspeed = 5
    end

    if inst.components.follower == nil then
        inst:AddComponent("follower") --这个组件有监听被攻击事件 会移除追随者
    end
    inst.components.follower:SetLeader(player) --跟随玩家
    --移除全部的 attacked 受到攻击的监听器
    RemoveListener(inst.event_listeners, "attacked",inst)
    RemoveListener(inst.event_listening, "attacked",inst)

    if inst.components.combat == nil then
        inst:AddComponent("combat")
    end
    inst.components.combat:SetRetargetFunction(5, RetargetFn) --重置攻击目标
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn) --保持目标
    -- 重新监听自身被攻击事件
    inst:ListenForEvent("attacked", function(inst, data)
        if not data.attacker:HasTag("player") then
            inst.components.combat:SetTarget(data.attacker)
        end
    end)
    inst:ListenForEvent("death",function(inst) --死亡时消失
        inst.AnimState:PlayAnimation("dissipate")
        inst:ListenForEvent("animover", inst.Remove)
    end)
    inst.persists = false --退出时不会保存
    inst:SetBrain(glasscutterbrain) --设置脑子
end

---------------------------------------------------------
-- 玩家头部添加眼睛 GiveEyeturret(TheInput:GetWorldEntityUnderMouse())

GLOBAL.GiveEyeturret = function(player)
    if player == nil or (player and player:HasTag("player") and player.head_eyeturret) then return end
    -- 大部分是复制眼睛炮塔的代码 稍微删改不需要的部分
    local inst = SpawnPrefab("of_eyeturret")
    --设置跟随玩家
    inst.entity:SetParent(player.entity)
    player.head_eyeturret = inst

    -- inst.Transform:SetPosition(0,0,0) --设置相对坐标 太高容易无法攻击目标
    --监听父亲状态
    inst:ListenForEvent("death", function(p,data) inst:Remove() end, player)
    inst:ListenForEvent("onremove", function(p,data) inst:Remove() end, player)
    inst:ListenForEvent("onremove", function(inst,data) player.head_eyeturret = nil end) --解除引用
end

----------------------------------------------------------
-- 手动调整裂缝和亮茄选择野外地址
local function SelectPoint(i)
    local names = {
        ["StaticLayoutIsland:HermitcrabIsland"] = "蟹岛",
        ["StaticLayoutIsland:MonkeyIsland"] = "猴岛",
        ["StaticLayoutIsland:OceanMoon"] = "小月亮岛",
        ["StaticLayoutIsland:OceanMoon2"] = "小月亮岛2",
        ["StaticLayoutIsland:OceanMoonbase"] = "月台岛",
        ["StaticLayoutIsland:OceanBoss"] = "boss岛",
        ["StaticLayoutIsland:Confusion"] = "混乱岛",
        ["StaticLayoutIsland:NightmareHome"] = "噩梦家园岛",
        ["StaticLayoutIsland:TumbleweedLand"] = "风滚草岛",
        ["StaticLayoutIsland:Turtle"] = "档案馆岛",
        ["StaticLayoutIsland:AtriumEnd"] = "中庭岛",
        ["StaticLayoutIsland:JunkYard"] = "垃圾场岛",
        ["StaticLayoutIsland:Joker_of"] = "小丑岛",
    }
    local node = TheWorld.topology.nodes[i]
    local t = {}
    for a = 1, 5 do
        local points = GetRandomPointsForSite_OF(node.poly, 10)
        for k, v in pairs(points) do
            if TheWorld.Map:IsLandTileAtPoint(v[1], 0, v[2]) then
                table.insert(t, {v[1], v[2]}) 
            end
        end
    end
    print("岛屿可用点", names[TheWorld.topology.ids[i]] or TheWorld.topology.ids[i],#t)
    return t
end
--为裂缝选择区域
local function SelectArea(t)
    local points = {}
    for _, i in pairs(t) do
        local a_point = SelectPoint(i)
        for i, v in pairs(a_point or {}) do
            table.insert(points, v)
        end
    end
    return points
end
GLOBAL.GivePortalPoints = function()
    print("为裂缝生成和亮茄虚影寻找野外植物提供岛屿坐标")
    -- 记录可选裂缝坐标（不会包含初始岛）
    TheWorld.lunarrift_portal_points = SelectArea(TheWorld.topology.lands)
end

------------------------------------------------------------------------------
-- 事件常用函数
GLOBAL.GetSpawnPoint_of = function(pt)
    if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
        pt = FindNearbyLand(pt, 1) or pt
    end
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 30, 12, true, true, function(pt) return not TheWorld.Map:IsPointNearHole(pt) end)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end
GLOBAL.spawnAtGround_of = function(name, x,y,z, ignore_ocean, fn)
    if ignore_ocean or TheWorld.Map:IsPassableAtPoint(x, y, z,false,true) then
        local item = SpawnPrefab(name)
        if item then
            item.Transform:SetPosition(x, y, z)
            if fn then
                fn(item)
            end
            return item
        end
    end
end

-- 物品位置, 半径, 几等分, 对象表, 将要执行的方法 是否忽略海洋 是否逆时针 最多绘制百分之几的圆 偏转几度 圆心偏离x 圆心偏离z
GLOBAL.circular_of = function(target, r, num, lsit, fn, ignore_ocean, isreverse, angleE, def, _x, _z)
    if target == nil or lsit == nil or #lsit <= 0 then return end 
    local x,y,z = target.Transform:GetWorldPosition()
    local d_x = _x or 0
    local d_z = _z or 0
    def = def or math.random(360)
    for k=1,num do
        local angle = angleE and (k * angleE * 2 * PI / num) or (k * 2 * PI / num) --用弧度求角度, 例 弧度2*PI = 角度360
        angle = angle + def -- if def then angle = angle + def end
        local item = isreverse and 
            spawnAtGround_of(lsit[math.random(#lsit)], r*math.cos(angle)+x+d_x, 0, r*math.sin(angle)+z+d_z, ignore_ocean) or
            spawnAtGround_of(lsit[math.random(#lsit)], r*math.sin(angle)+x+d_x, 0, r*math.cos(angle)+z+d_z, ignore_ocean) --利用极坐标画圆
        if item ~= nil and fn ~= nil and type(fn) == "function" then 
            fn(item, target, k)
        end
    end
end

-----------------------------------------
-- 岛屿随机陆地点
GLOBAL.GetRandomPointsForSite_OF = function(poly, num)
    num = num or 1 --需要随机的次数
    local points= {} --存放点集
    -- 找到多边形的包围盒
    local min_x, max_x = math.huge, -math.huge
    local min_y, max_y = math.huge, -math.huge
    for k, v in ipairs(poly) do
        min_x = math.min(min_x, v[1]) 
        max_x = math.max(max_x, v[1])
        min_y = math.min(min_y, v[2]) 
        max_y = math.max(max_y, v[2]) 
    end
    -- 检查点是否在多边形内
    local function isPointInPolygon(point)
        local internal = false
        local j = #poly

        for i = 1, #poly do
            if (poly[i][2] < point[2] and poly[j][2] >= point[2] or poly[j][2] < point[2] and poly[i][2] >= point[2]) then
                if (poly[i][1] + (point[2] - poly[i][2]) / (poly[j][2] - poly[i][2]) * (poly[j][1] - poly[i][1]) < point[1]) then
                    internal = not internal
                end
            end
            j = i
        end

        return internal
    end
    -- 随机点
    local function getRandomPoint()
        return { math.random(min_x, max_x), math.random(min_y, max_y) }
    end

    for i = 1, num do
        local randomPoint = getRandomPoint()
        while not isPointInPolygon(randomPoint, vertices) do
            randomPoint = getRandomPoint()
        end
        table.insert(points, randomPoint)
    end

    return points
end
-----------------------------------------------------------------
-- 生成一个傀儡
GLOBAL.GeneratePuppet = function(player)
    if player == nil or not player:HasTag("player") then return end --非玩家
    local inst = inst or SpawnPrefab("wilson")
    local v = SpawnPrefab("glasscutter") --它的默认攻击距离是3
    inst.name = "【人偶】"
    inst.components.inventory:Equip(v) --装备武器
    inst.Transform:SetPosition(player:GetPosition():Get()) --设置坐标
    inst.AnimState:SetMultColour(0, 0, 0, .5) --设置颜色

    -- 结束时 还需要添加一个定时器自杀.
    inst:DoTaskInTime(TUNING.CONTROLPUPPETTIME, function() inst:PushEvent("death") end)
    --死亡时消失
    inst:ListenForEvent("death", function(inst) 
        -- 防止因为开了 灵魂携带物品 导致物品没法正常掉落。
        if inst.components.inventory.oldDropEverythingFn then
            inst.components.inventory:oldDropEverythingFn()
        end
        --死亡动画结束后就gg
        inst.AnimState:PlayAnimation("dissipate")
        inst:ListenForEvent("animover", inst.Remove)
        -- inst:Remove()
    end) 
    --控制结束则移除
    inst:ListenForEvent("of_leavecontrol", function(inst) inst:DoTaskInTime(0, inst.Remove) end) 

    inst:ListenForEvent("entitysleep", function() --脱离加载范围
        if player then
            inst.Transform:SetPosition(player.Transform:GetWorldPosition())
        end
    end)
    -- 开始控制傀儡 
    player.components.controlpuppet:StartControl(inst)
    
    inst:AddTag("is_puppet")
    inst.persists = false --退出时不会保存
end


-----------------------------------------------------------------
-- 保护期
GLOBAL.inspectProtect = function(inst)
    if inst and inst.components.age then
        local time = inst.components.age:GetAge()
        if time > TUNING.OFDATA.PROTECT then
            return true
        end
    end
end


-- AddPlayerPostInit(function(inst)
--     inst:ListenForEvent("onremove", function(inst, data) 
--         print("玩家删除了", inst)
--     end,inst)
--     inst:ListenForEvent("ms_playerreroll", function(inst, data)
--         print("变身旧身体", inst)
--     end,inst)
--     inst:ListenForEvent("ms_playerseamlessswaped", function(inst, data)
--         print("变身新身体", inst)
--     end,inst)
-- end)