--[[
世界：
1、记录岛屿 必须是有名称的 StaticLayoutIsland:xxx岛。初始岛没有设置名字
2、修改月亮裂缝的生成位置 每个有记录的岛都有一些点
3、瓶中信管理器添加可查找记录过的岛，
4、玩家进入游戏时给予额外物品。（取消了第一次进入才给的限制）会给个钓鱼竿。（已经更改为每个钓鱼竿都添加绑定组件，但仅包里的一根会绑定，其他未绑定）
]]

---------------------------------------------
--开局赠送 海钓杆\船套装\桨

-- local function IsStart(name)
--     if TheWorld.components.worldstate.data.new_fishing[name] == nil then
--         TheWorld.components.worldstate.data.new_fishing[name] = 0
--         return true
--     end
--     return false
-- end

local function existlunarrift(x,y)  -- 在20范围内不存在裂缝 建筑 墙"wall"
    for i, v in ipairs(TheSim:FindEntities(x, 0, y, 16, nil, {"lunarrift_portal", "structure", "blocker"})) do
        return false
    end
    return true
end

local rift_portal_defs = require("prefabs/rift_portal_defs")
local RIFTPORTAL_FNS = rift_portal_defs.RIFTPORTAL_FNS
local RIFTPORTAL_CONST = rift_portal_defs.RIFTPORTAL_CONST

-- require("maputil")
-- StaticLayoutPlacer.TileFilter_Impassable = function(tileid)
--     return TileGroupManager:IsOceanTile(tileid)
-- end

AddPrefabPostInit("world", function(inst)
    if inst.ismastersim then --判断是不是主机
        if inst.components.daywalkerspawner == nil then
            inst:AddComponent("daywalkerspawner") -- 添加噩梦猪人boss刷新组件
        end
        if inst.components.archivemanager == nil then
            inst:AddComponent("archivemanager") --档案馆管理器
        end
        if inst.components.riftspawner == nil then
            inst:AddComponent("riftspawner") --裂缝生成器
        end
        if inst.components.miasmamanager == nil then
            inst:AddComponent("miasmamanager") --瘴气管理器
        end
        if inst.components.shadowthrallmanager == nil then
            inst:AddComponent("shadowthrallmanager") --墨荒管理器
        end
        if inst.components.ruinsshadelingspawner == nil then
            inst:AddComponent("ruinsshadelingspawner") --废墟着色管理器
        end
        if inst.components.maptagchange == nil then
            inst:AddComponent("maptagchange") --更改地图标签管理器
        end
        -- if inst.components.vaultroommanager == nil then --洞穴解密组件
        --     inst:AddComponent("vaultroommanager")
        -- end
        
        -- if inst.components.worldstate and inst.components.worldstate.data and inst.components.worldstate.data.new_fishing == nil then --利用组件保存
        --     inst.components.worldstate.data.new_fishing = {} -- 仅第一次进入游戏
        -- end

        inst:ListenForEvent("ms_playerspawn", function(inst, player)
            local CurrentOnNewSpawn = player.OnNewSpawn or function() return true end -- 记录角色本身开局物品
            player.OnNewSpawn = function(...)
                -- if IsStart(player.userid) then
                player.components.inventory.ignoresound = true
                if Gift_OF then --开局礼物
                    local items = {}
                    local wp = Bobbers and {"boat_item","oar","messagebottle","spear","trinket_8"}
                        or {"boat_item","oar","messagebottle","spear"}
                    for _,name in ipairs(wp) do  --船套装 桨 瓶中信 长矛 硬化橡胶塞
                        local item = SpawnPrefab(name)
                        SetSpellCB(item, player)
                        table.insert(items, item)
                    end
                    local gift = SpawnPrefab("gift")
                    gift.components.unwrappable:WrapItems(items) --打包物品
                    for i, v in ipairs(items) do --删除生成出来的
                        v:Remove()
                    end
                    player.components.inventory:GiveItem(gift)
                end

                -- end
                -- 赌狗模式 额外赠送火把
                if gambling_dog then
                    player.components.inventory:GiveItem(SpawnPrefab("torch")) --火把
                end
                -- 海钓竿
                local of = SpawnPrefab("oceanfishingrod")
                SetSpellCB(of, player)
                player.components.inventory:GiveItem(of) --海钓杆  

                return CurrentOnNewSpawn(...)
            end
        end)
        inst:DoTaskInTime(0,function()
            -- 记录岛id
            local lands = {}

            for i, id in ipairs(TheWorld.topology.ids) do -- 旧档新添加岛屿, 不会改变顺序
                local str = string.split(id,":")
                if str[1] == "StaticLayoutIsland" then --初始岛不需要节点，也不会记录
                    table.insert(lands,i)
                end
            end
            
            TheWorld.topology.lands = lands
            if TheWorld.components.messagebottlemanager then --瓶中信使用
                TheWorld.components.messagebottlemanager.lands = lands or nil
            end
            -- 记录可选裂缝坐标（不会包含初始岛）
            GivePortalPoints()
            
            RIFTPORTAL_FNS.CreateRiftPortalDefinition("lunarrift_portal", {
                GetNextRiftSpawnLocation = function(_map, rift_def)
                    local points = TheWorld.lunarrift_portal_points or {}
                    shuffleArray(points) --洗牌打乱

                    for i, v in ipairs(points) do --可能存在非常差劲的情况, 毕竟岛小
                        if existlunarrift(v[1], v[2]) then
                            return v[1], v[2]
                        end
                    end
                    -- 可能一个也没有
                end,
                Affinity = RIFTPORTAL_CONST.AFFINITY.LUNAR,
            })
            RIFTPORTAL_FNS.CreateRiftPortalDefinition("shadowrift_portal", {
                GetNextRiftSpawnLocation = function(_map, rift_def)
                    local points = TheWorld.lunarrift_portal_points or {}
                    shuffleArray(points) --洗牌打乱

                    for i, v in ipairs(points) do --可能存在非常差劲的情况, 毕竟岛小
                        if existlunarrift(v[1], v[2]) then
                            return v[1], v[2]
                        end
                    end

                    -- 可能一个也没有
                end,
                Affinity = RIFTPORTAL_CONST.AFFINITY.SHADOW,
            })
            --解锁三基佬草图事件
            inst:PushEvent("ms_unlockchesspiece", "bishop")
            inst:PushEvent("ms_unlockchesspiece", "rook")
            inst:PushEvent("ms_unlockchesspiece", "knight")

            -- 为亮茄虚影寻找野外植物时 提供坐标。
            local idx = getmetatable(TheWorld.Map).__index
            if idx then
                -- 除了初始岛之外的 每次重新进入游戏会自动添加点
                idx.FindRandomPointOnLand = function(self, max_tries)
                    local points = TheWorld.lunarrift_portal_points or {}
                    shuffleArray(points) --洗牌打乱
                    local pos = points[1]
                    -- print("查找野生植物坐标", pos[1],pos[2])
                    return pos and Vector3(pos[1], 0, pos[2]) or nil
                end
                idx.CanPointHaveAcidRain = function() return true end
            end
        end)    

        -- 添加自动清理
        if RegularCleaning > 0 then
            --注册清理事件
            inst:ListenForEvent("of_clean", function(inst)
                of_clean()
            end)
            --第3天开始清理
            inst:DoPeriodicTask(RegularCleaning*480, function(inst) if TheWorld.state.cycles>3 then inst:PushEvent("of_clean") end end, 15)
            inst:DoPeriodicTask(RegularCleaning*480, function(inst) if TheWorld.state.cycles>3 then TheNet:Announce("15秒后开始清理") end end, 0)
        end 

        -- inst:ListenForEvent("ms_playerjoined", function(inst, player)
            
        --     local names = {
        --         ["StaticLayoutIsland:HermitcrabIsland"] = false, --"蟹岛",
        --         ["StaticLayoutIsland:MonkeyIsland"] = false, --"猴岛",
        --         ["StaticLayoutIsland:OceanMoonbase"] = false, --"月台岛",
        --         ["StaticLayoutIsland:OceanBoss"] = false, --"boss岛",
        --         ["StaticLayoutIsland:Confusion"] = false, --"混乱岛",
        --         ["StaticLayoutIsland:NightmareHome"] = false, --"噩梦家园岛",
        --         ["StaticLayoutIsland:TumbleweedLand"] = false, --"风滚草岛",
        --         ["StaticLayoutIsland:Turtle"] = false, --"档案馆岛",
        --         ["StaticLayoutIsland:JunkYard"] = false, --"垃圾场岛",
        --     }

        --     for _, i in ipairs(TheWorld.topology.lands or {}) do
        --         local node = TheWorld.topology.nodes[i]
        --         local t = {}
        --         for a = 1, 5 do
        --             local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(node.x, node.y, node.poly, 10)
        --             for k in ipairs(points_x) do
        --                 if TheWorld.Map:IsLandTileAtPoint(points_x[k], 0, points_y[k], false) then
        --                     ZSHH_PlayerTransform(player, points_x[k], 0, points_y[k])
        --                 end
        --             end
        --         end
        --     end
        -- end)
    end
end)


-- function GLOBAL.ZSHH_PlayerTransform(player, x, y, z)
--     if player == nil or x == nil or y == nil or z == nil then return end
--     player.Transform:SetPosition(x,y,z)
--     if player.components.leader then
--         for key in pairs(player.components.leader.followers or {}) do
--             if key and key:IsValid() then
--                 key.Transform:SetPosition(x,y,z)
--             end
--         end
--     end
--     if player.components.controlpuppet then
--         local puppet = player.components.controlpuppet.puppet
--         if puppet then
--             puppet.Transform:SetPosition(x,y,z)
--         end
--     end

-- end