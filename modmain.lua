GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
PrefabFiles = {
    "fishingsurprised", -- 钓起事件时的特效物品
    -- "artificial_atrium_gate", -- 钓起织影者的伪·大门
    "bag", --包裹
    "of_eyeturret", -- 眼球
    "timebomb", --定时炸弹
    "zdy_mist_of", --雾
    "black_hole_of", -- 黑洞？
    "buff_of", -- 各种buff
    "clearing_staff_of", --清理杖
    "gambling_of", --资源 赌博机

    -- "springlamp", -- 泉灯
}
Assets = {
    Asset("ANIM", "anim/shield.zip"),
    Asset("SHADER", "shaders/win_round_cs6.ksh"),
    Asset("SHADER", "shaders/ripple.ksh"),
    Asset("SHADER", "shaders/raodoyuan.ksh"),
}

modimport("scripts/of_modify/all/tuning.lua") --常量
modimport("scripts/of_modify/all/strings.lua") --字符串
modimport("scripts/of_modify/all/utility.lua")
modimport("scripts/of_modify/all/loadingtips.lua") --加载页面的情况
if GetModConfigData("pullup") then
    --加载注册【钓东西】动作
    modimport("scripts/of_modify/all/pullup.lua")
end
-- 加载操控相关
modimport("scripts/of_modify/all/control_puppet.lua")
-- 森林网络的调整
modimport("scripts/of_modify/all/forest_network.lua")
-- rpc的注册
modimport("scripts/of_modify/all/of_rpc.lua")
-- 双端玩家角色调整
modimport("scripts/of_modify/all/playerpostinit.lua")
-- 注册用户命令
modimport("scripts/of_modify/all/usercommand.lua")

---------------------------------------- [[ 仅服务器的内容 ]] ------------------------ 
if TheNet:GetIsServer() or TheNet:IsDedicated() then
    --------------------------模组设置-------------------------------
    GLOBAL.gambling_dog = GetModConfigData("no_crafting") or false --赌狗模式
    GLOBAL.setsleeper = GetModConfigData("sleeper") or false
    -- GLOBAL.suffering = GetModConfigData("suffering") or false --受难模式
    GLOBAL.build = GetModConfigData("build") or false --钓起建筑
    GLOBAL.Bobbers = GetModConfigData("bobbers") or false --浮标影响概率
    GLOBAL.Gift_OF = GetModConfigData("gift") or false --开局礼物
    GLOBAL.Lightning = GetModConfigData("lightning") or false --闪电
    GLOBAL.Boss_modify = GetModConfigData("boss_modify") or false --boss修改
    GLOBAL.RegularCleaning = GetModConfigData("regularcleaning") or -1 --定期清理
    TUNING.ATRIUM_GATE_COOLDOWN = (GetModConfigData("atriumgate") or 20) * TUNING.TOTAL_DAY_TIME --中庭刷新时间
    
    TUNING.OFDATA.AVERAGE = GetModConfigData("average") or false  --随机模式
    TUNING.OFDATA.DURABLE = GetModConfigData("durable") or 0  --随机耐久
    TUNING.OFDATA.PROTECT = GetModConfigData("protect") or 3  --保护期

    -- 默认初始岛
    GLOBAL.start_of = GetModConfigData("start") or "default_start"

    if gambling_dog then
        modimport("scripts/gambling.lua")
    end
    ----------------------------------
    -- 加载受难模式
    -- if suffering then
    --     modimport("scripts/suffering.lua") D:\Steam\steamapps\common\Don't Starve Together\mods\11cs\scripts\of_modify\server\setoceanfishingrod.lua
    -- end
    ---------------【公共方法】-----------------------------
    -- 大部分的其他设置
    modimport("scripts/of_modify/server/overall.lua")
    -- 加载自动清理    
    modimport("scripts/clean.lua")
    --------------------------------------------------------
    -- 本mod, 钓起执行的方法
    TUNING.OCEANFISHINGROD_E = TUNING.OCEANFISHINGROD_E or {}
    TUNING.OCEANFISHINGROD_E.oceanfishingrod = require("event_table")
    TUNING.OCEANFISHINGROD_E.prefab_events = require("prefab_event_table")

    ---------------【修改其他物品或组件】-----------------------------
    -- 大部分的其他设置
    modimport("scripts/of_modify/server/all_modify.lua")
    -- 兼容其他mod
    modimport("scripts/of_modify/server/compatible_mod.lua")

    -- 相对多内容或者代码量大的会单独放一个文件里。
    -- 设置世界
    modimport("scripts/of_modify/server/world_modify.lua")

    -- 设置月兽相关内容
    modimport("scripts/of_modify/server/moonbeastspawner_modify.lua")

    -- 设置海钓竿
    modimport("scripts/of_modify/server/setoceanfishingrod.lua")

    --[[ 
    --钓起后执行方法, 也可以不用, 直接写在下面 的 event 里
    TUNING.OCEANFISHINGROD_E = TUNING.OCEANFISHINGROD_E or {}
    TUNING.OCEANFISHINGROD_E.xxxx = { -- xxxx是自己命名，确保其他mod不同, 与下面的应该要保持一致
        funxxx = function(inst, player) --参数是: 物品 钓起玩家
        end
    }
    --设置额外钓起的内容
    TUNING.OCEANFISHINGROD_R = TUNING.OCEANFISHINGROD_R or {}
    TUNING.OCEANFISHINGROD_R.xxxx = { -- xxxx是自己命名，确保唯一性
        {
            chance = 1, -- 权重, 必填
            item = "log" or {"log"}, -- 名称,如果是物品,则为预制体名称, 必填, 通常名称不应该重复。
            name = "", -- 命名, 用于宣告, announce无需添加此项也会宣告。
            eventF = function(inst, player) end, -- 钓起时执行事件。
            eventA = function(inst, player) end, -- 钓起后执行事件。
            build = true, -- 钓起时是建筑, true 是建筑, 默认是物品。
            sleeper = true, -- 钓起时睡眠, true 是不睡觉, 默认睡眠。
            hatred = true, -- 钓起时仇恨玩家, true 是不仇恨, 默认仇恨。
            announce = true, -- 钓起时进行宣告, true 是宣告, 默认不宣告。
        },
        default = { -- 项参数默认值。 可有可无, 其他项对应参数为空时, 为其他项添加对应参数的默认值。
            build = ,
            sleeper = ,
            hatred = ,
            announce = ,
        }
    } 
    -- 说明:
    -- build, 即使是建筑, 不添加, 将视为物品一样被钓起, 生物也视为物品。
    -- sleeper hatred, 钓起物是生物才要添加。
    -- 事件也归为物品, 利用了 fishingsurprised 特效物品, 要执行的方法放到 eventF 或 eventA 里。
    --]]

    -- 扩展原表接口
    -- 那么扩展mod要用到这个函数 有两个方法
    -- 1、 扩展mod modinfo.lua 这个文件的 priority 要大于海钓mod。然后直接调用SetOF_loot函数添加。
    -- 2、 扩展mod 添加代码
    --[[AddPrefabPostInit("world", function(inst) 
        inst:DoTaskInTime(0,function() 
            if rawget(GLOBAL, "Set_OF_loot") then
                Set_OF_loot(function(t1,t2)
                    -- 向海钓原版 掉落物表添加新内容。
                    -- 事件表 添加自定义事件
                    table.insert(t1.events, {chance = 0.01, item = "fishingsurprised", name = "自定义事件名称", eventF = function() end})
                end)
            end 
        end) 
    end)]]
    GLOBAL.Set_OF_loot = function(fn, ...)
        local t1 = require("loots")--正常掉落表
        local t2 = require("especiallys")--月圆月黑掉落表
        if fn and type(fn) == "function" then
            fn(t1, t2, ...)
        end
    end
end
---------------------------------------- [[ 仅客机的内容 ]] ------------------------ 
-- print("鼠标坐标", TheSim:GetPosition())
if TheNet:GetIsClient() or not TheNet:IsDedicated() then
    --改变海洋颜色
    modimport("scripts/of_modify/clien/ocean_colour.lua")
    --移动ui
    modimport("scripts/of_modify/clien/moveui_of.lua")
    --钓鱼信息按钮
    modimport("scripts/of_modify/clien/playerhud.lua")
    --客户端角色实体调整
    modimport("scripts/of_modify/clien/playerpostinit.lua")
    --shader：注册后处理
    modimport("scripts/of_modify/clien/shader.lua")

    --地图传送:传送到鼠标所在地图位置
    GLOBAL.mapgoto_of = function()
        if ThePlayer == nil then return end --ThePlayer:AddDebuff("buff_deathrattle_of", "buff_deathrattle_of") c_teleport(0,0,0, ThePlayer)
        local x, y = TheSim:GetPosition()
        local w, h = TheSim:GetScreenSize()
        x = 2 * x / w - 1
        y = 2 * y / h - 1
        local minimap = TheWorld.minimap.MiniMap
        x, y = minimap:MapPosToWorldPos(x, y, 0)
        c_teleport(x,0,y, ThePlayer)
        local screen = TheFrontEnd:GetOpenScreenOfType("MapScreen")
        if screen and screen.minimap then --显示到目标位置
            ThePlayer.HUD.controls:FocusMapOnWorldPosition(screen.minimap, x,y)
        end
    end
end

-- function extendTaskTick(task, time)
--     if not Periodic.is_instance(task) then print("【延迟定时器】:不是定时器的实例", task) return end 
--     if type(time) ~= "number" then print("【延迟定时器】:不是数字", time) return end
--     local nexttime = task:NextTime() --获取到下次执行的目标时间
--     nexttime = nexttime + time - GetTime() --GetListForTimeFromNow里多算了一个当前时间

--     -- 找到定时器所属的 调度程序所在的tick
--     if scheduler.attime[task.nexttick] and scheduler.attime[task.nexttick][task] then
--         -- 从旧的tick点移除掉 要执行的task
--         scheduler.attime[task.nexttick][task] = nil

--         -- 重新的tick点里添加进去
--         local list, nexttick = scheduler:GetListForTimeFromNow(nexttime)
--         list[task] = true
--         task.list = list
--     elseif staticScheduler.attime[task.nexttick] and staticScheduler.attime[task.nexttick][task] then
--         staticScheduler.attime[task.nexttick][task] = nil
--         local list, nexttick = staticScheduler:GetListForTimeFromNow(nexttime)
--         list[task] = true
--         task.list = list
--     end
-- end

-- function ProcessEntity(isnt, time)
--     local periodics = inst.pendingtasks 
--     for periodic, _ in pairs(periodics or {}) do
--         extendTaskTick(periodic, time)
--     end
-- end

-- GLOBAL.css = function()
--     local t1 = GetTime()
--     print("当前时间", t1)
--     local x = ThePlayer:DoTaskInTime(5,function()
--         local t2 = GetTime()
--         print("五秒后了啊", t2, t2 - t1)
--     end)
--     ThePlayer:DoTaskInTime(2, function()
--         print("延迟了", 2, GetTime())
--         extendTaskTick(x, -2)
--     end)
-- end

-- GLOBAL.printtimefn = function()
--     print("打印时间函数的返回值")
--     local xx = {
--         "GetTickTime",
--         "GetTime",
--         "GetStaticTime",
--         "GetTick",
--         "GetStaticTick",
--         "GetTimeReal",
--         "GetTimeRealSeconds",
--     }
--     for key, value in ipairs(xx or {}) do
--         print(value, GLOBAL[value] and GLOBAL[value]() or "无")
--     end
-- end

-- printtimefn()
-- 打印 系统组件
-- GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
-- local xx = {
--     "UITransform",
--     -- "Transform",
--     -- "Network",
--     -- "AnimState",
--     -- "Light",
--     -- "SoundEmitter",
--     -- "MiniMapEntity",
--     -- "VFXEffect",
--     -- "DynamicShadow",
--     -- "Follower",
--     -- "Physics",
--     -- "Map",
--     -- "Pathfinder",
--     -- "GroundCreep",
--     -- "ShardClient",
-- }

-- for _, name in pairs(xx) do
--     local t = rawget(GLOBAL, name)
--     if t then
--         print("组件", name, t)
--         for k,v in pairs(type(t) == "table" and t or {}) do
--             print("---方法", k, v)
--         end
--     end
-- end
-- GLOBAL.xx = function()
--     local self = TheFrontEnd
--     local screen = self.screenstack[#self.screenstack-1]
--     print("屏幕", screen, screen.minimap)
--     if screen.minimap then
--     end
-- end

-- 控制台执行的

-- 世界坐标转屏幕坐标
--[[
local w, h = TheSim:GetScreenSize() 
local wx, wz = 1, 0 
local minimap = TheWorld.minimap.MiniMap 
local x, y = minimap:WorldPosToMapPos(wx, wz, 0) 
print("(1)",x, y) 
x= x*w/2 
y= y*h/2 
print("(2)",x, y) 
]]
--[[
local w, h = TheSim:GetScreenSize() 
local wx, wz = 20, 0 
local minimap = TheWorld.minimap.MiniMap 
local x, y = minimap:WorldPosToMapPos(wx, wz, 0) 
print("(1)",x, y) 
 x, y = (x)*w/2, (y)*h/2 
print("(2)",x, y) 
dx,dy = 0-x, 0-y 
local r = math.sqrt(dx*dx+dy*dy) 
print("半径",r)
]]

-- -- 屏幕坐标转世界坐标
-- local w, h = TheSim:GetScreenSize() 
-- local x, y = 0,-8.4852809216827 
-- print("(I)",x, y) 
-- x = 2*x/w 
-- y = 2*y/h 
-- print("(II)",x, y) 
-- local minimap = TheWorld.minimap.MiniMap 
-- x, y = minimap:MapPosToWorldPos(x, y, 0) 
-- print("(II)",x, y) 

-- 鼠标在小地图上屏幕坐标到实际世界坐标转换
-- local x, y = TheSim:GetPosition() 
-- local w, h = TheSim:GetScreenSize() 
-- x = x / w * RESOLUTION_X - RESOLUTION_X/2 
-- y = y / h * RESOLUTION_Y - RESOLUTION_Y/2 
-- print("a", x,y) 
-- x = x / (RESOLUTION_X/2) 
-- y = y / (RESOLUTION_Y/2) 
-- print("b", x,y) 
-- local minimap = TheWorld.minimap.MiniMap 
-- x, y = minimap:MapPosToWorldPos(x, y, 0) 
-- print("c", x,y) 
-- c_teleport(10,0,0, ThePlayer)


-- AddPrefabPostInit("multiplayer_portal_moonrock", function(inst)
--     inst:ListenForEvent("entitysleep", function() 
--         local x,y,z = inst.Transform:GetWorldPosition()
--         local ents = TheSim:FindEntities(x, 0, z, 10)
--         print("睡眠")
--         for k,v in pairs(ents or {}) do
--             print(k,v)
--         end
--     end)
-- end)

-- return
-- PlayAnimation("emote_jumpcheer") 玩家 兴奋的跳起来


--c_teleport(206,0,188, ThePlayer)
--chatinputscreen 聊天输入屏幕

-- 获取鼠标的 TheInput:GetWorldPosition()
-- GLOBAL.xxx = function()
--     local x,y,z = TheInput:GetWorldPosition():Get()
--     local pigman = SpawnPrefab("pigman")
--     pigman.Transform:SetPosition(x, y, z)

--     local item = SpawnPrefab("armor_bramble")
--     pigman.components.inventory:Equip(item)
-- end 
-- if TheNet:GetIsServer() then
-- --这里写需要放在服务端的代码
-- end

-- if not TheNet:IsDedicated() then
-- --这里写需要放在客户端的代码
-- --如果使用 not TheNet:GetIsServer() ，那么就把不开洞的房主漏掉了，它也需要客户端代码
-- end

-- TheWorld.net.components.climatechange.current:set(1)

-- 显示各节点范围
-- AddPrefabPostInit("world",function(inst)
--     inst:DoTaskInTime(0, function(inst)
--         for k,v in pairs(inst.topology.nodes) do
--             local moom = SpawnPrefab("moonbase")
--             moom.Transform:SetPosition(v.x,0,v.y)
--             moom.persists=false
--             -- moom.components.writeable:SetText("节点id"..k) --生成木牌时
--             for k1,v1 in pairs(v.poly) do
--                 local moom2 = SpawnPrefab("homesign")
--                 moom2.Transform:SetPosition(v1[1],0,v1[2])
--                 moom2.persists=false
--             end
--             if v.tags then
--             end
--         end
        
--     end)
-- end)    
-----------------------------------------------------------------------------------------------------------------
-- 移动 DoDirectWalking 旋转 DoCameraControl

-- -- 获取鼠标下实体
-- --TheInput:GetWorldEntityUnderMouse()
-- local old_ThePlayer = nil
-- GLOBAL.xx1 = function()
--     local p = TheInput:GetWorldEntityUnderMouse()
--     if p and p:HasTag("player") then
--         -- old_ThePlayer = ThePlayer
--         -- ThePlayer = p
--         SwapAllCharacteristics(ThePlayer, p)
--         -- ThePlayer:PushEvent("setowner")
--     end
-- end

-- GLOBAL.xx2 = function()
--     if old_ThePlayer then
--         ThePlayer = old_ThePlayer
--         old_ThePlayer = nil
--         ThePlayer:PushEvent("setowner")
--     end
-- end

-- if rawget(GLOBAL, "TheNet") then
--     local idx = getmetatable(TheNet).__index
--     local old_GetClientTableForUser = idx.GetClientTableForUser
--     idx.GetClientTableForUser = function(self, id)
--         if id == nil or ThePlayer then
--             id = ThePlayer.userid
--         end
--         return old_GetClientTableForUser(self, id)
--     end
-- end

-- GLOBAL.IsConsole = function() return true end


-- -- 本地测试使用 xx2(ThePlayer)
-- GLOBAL.xx2 = function(player)
--     if player == nil or not player:HasTag("player") or player.puppet_of then return end --非玩家
--     local inst = TheInput:GetWorldEntityUnderMouse()
--     if inst == nil or inst.components.locomotor == nil then return end
--     if inst.brainfn then 
--         inst:StopBrain()
--         inst.old_brainfn = inst.brainfn
--         inst.brainfn = nil
--     end
--     -- 结束时 还需要添加一个定时器自杀.
--     inst:DoTaskInTime(20, inst.Remove)
--     if inst.components.knownlocations then 
--         inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition(), false) -- 重新记住
--     end
--     player.components.controlpuppet:StartControl(inst)
--     inst.persists = false --退出时不会保存
--     local function onxx(inst)
--         if inst.old_brainfn then
--             inst:SetBrain(inst.old_brainfn)
--             inst:RestartBrain() 
--         end
--         inst:RemoveEventCallback("of_stopcontrolling", onxx)
--     end
--     inst:ListenForEvent("of_leavecontrol", onxx)
-- end


--[[ Follower组件讲解 Tip:
    ▷ inst.entity:AddFollower() 使用这个添加该组件
    ▷ inst.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 0, 3)
        1、参数分别为 实体ID，跟随通道名，偏移量x，偏移量y，偏移量z，是否替换贴图位置，未知，默认贴图下标，连续替换的贴图下标
        2、例子中的意思就是 inst 这个实体跟随 owner 的 swap_object 通道，并替换位置 0到3 的通道内贴图
    ▷ inst.Follower:FollowSymbol(owner.GUID, "swap_body", nil, nil, nil, true, nil, 5)
        1、例子中的意思就是 inst 这个实体跟随 owner 的 swap_body 通道，并替换位置为 5 的通道内贴图
        2、如果最后两个参数都不填写，就代表把所有位置的贴图都替换掉
    ▷ inst.Follower:StopFollowing() 让 inst 停止跟随通道
]]--

-- 加载debug文件 执行对应指令
--require("debugcommands") d_ground(23) --改变鼠标位置地皮类型

--[[
测试冰上脚印
--鼠标位置 创建冰
local x,y,z = TheInput:GetWorldPosition():Get()
TheWorld.components.oceanicemanager:CreateIceAtPoint(x, y, z)
--删除冰
local x,y,z = TheInput:GetWorldPosition():Get()
TheWorld.components.oceanicemanager:DestroyIceAtPoint(x,y,z)
--强制生成冰
TheWorld.components.hunter:DebugForceHunt()
]]
--[[
-- 手动生成裂缝 测试避免选择建筑
require("debugcommands") d_togglelunarhail()
]]

-- 设置全局环境光
-- local index = getmetatable(TheSim).__index
-- if index then
--     local old_SetVisualAmbientColour = index.SetVisualAmbientColour
--     index.SetVisualAmbientColour = function(self, r, g, b)
--         old_SetVisualAmbientColour(self, r, 0, 0)
--     end
-- end

--entity:WorldToLocalSpace -- 世界坐标系转局部坐标系
--entity:LocalToWorldSpace -- 局部坐标系转世界坐标系

-- 以时间设置随机种子 math.randomseed(tostring(os.time()):reverse():sub(1, 7))

