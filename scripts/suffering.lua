-- 受难模式
-- 对战利品组件进行修改

local LOOT_GL = 0.5
local SOUL_GL = 0.33

AddComponentPostInit("lootdropper", function(self, inst)
    self.DropLoot = function(self, pt) -- 只好覆盖原方法
        local prefabs = self:GenerateLoot()
        if self.inst:HasTag("burnt")
            or (self.inst.components.burnable ~= nil and
                self.inst.components.burnable:IsBurning() and
                (self.inst.components.fueled == nil or self.inst.components.burnable.ignorefuel)) then

            local isstructure = self.inst:HasTag("structure")
            for k, v in pairs(prefabs) do
                if TUNING.BURNED_LOOT_OVERRIDES[v] ~= nil then
                    prefabs[k] = TUNING.BURNED_LOOT_OVERRIDES[v]
                elseif PrefabExists(v.."_cooked") then
                    prefabs[k] = v.."_cooked"
                elseif PrefabExists("cooked"..v) then
                    prefabs[k] = "cooked"..v
                elseif (not isstructure and not self.inst:HasTag("tree")) or self.inst:HasTag("hive") then 
                    prefabs[k] = "ash"
                end
            end
        end
        for k, v in pairs(prefabs) do
            if math.random() > LOOT_GL then -- 就这里添加一下概率 每次掉落时判断一下
                self:SpawnLootPrefab(v, pt)
            end
        end
        if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
            local prefabname = string.upper(self.inst.prefab)
            local num_decor_loot = self.GetWintersFeastOrnaments ~= nil and self.GetWintersFeastOrnaments(self.inst) or TUNING.WINTERS_FEAST_TREE_DECOR_LOOT[prefabname] or nil
            if num_decor_loot ~= nil then
                for i = 1, num_decor_loot.basic do
                    self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
                end
                if num_decor_loot.special ~= nil then
                    self:SpawnLootPrefab(num_decor_loot.special, pt)
                end
            elseif not TUNING.WINTERS_FEAST_LOOT_EXCLUSION[prefabname] and (self.inst:HasTag("monster") or self.inst:HasTag("animal")) then
                local loot = math.random()
                if loot < 0.005 then
                    self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
                elseif loot < 0.20 then
                    self:SpawnLootPrefab("winter_food"..math.random(NUM_WINTERFOOD), pt)
                end
            end
        end

        TheWorld:PushEvent("entity_droploot", { inst = self.inst })
    end
end)


AddPrefabPostInit("wortox_soul_spawn", function(inst)
    -- 击杀生物时有33%概率掉落灵魂
    inst:DoTaskInTime(0,function(inst)
        if math.random() > SOUL_GL then
            inst:Remove()
        end
    end)
end)


AddPrefabPostInit("world", function(inst)
    if TheWorld.ismastersim then --判断是不是主机
        -- 给大门免费升级
        inst:DoTaskInTime(0,function(inst) 
            local items = {
                multiplayer_portal = true,
                multiplayer_portal_moonrock_constr = true,
            }
            local removed = {}
            for k,v in pairs(Ents) do
                if v.prefab ~= nil and items[v.prefab] then
                    table.insert(removed, v)
                end
            end
            for k,v in pairs(removed) do
                local dm = SpawnPrefab("multiplayer_portal_moonrock")
                local sp = SpawnPrefab("springlamp") -- 添加泉灯
                local x,y,z = v.Transform:GetWorldPosition()
                dm.Transform:SetPosition(x,y,z)
                sp.Transform:SetPosition(x + 4,y,z)
                v:Remove()
            end                
        end)
    end
end)