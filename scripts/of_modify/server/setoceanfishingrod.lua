
local bobbers = {
    twigs = {"goods",.65}, --树枝 --禁止物品表
    oceanfishingbobber_ball = {"events",.75}, --木球浮标 --禁止事件
    oceanfishingbobber_oval = {"equipments",.75}, --硬物浮标 --禁止穿戴表
    trinket_8 = {"double",.95}, --硬化橡胶塞 --双倍钓
    oceanfishingbobber_robin = {"ingredients",.85}, --红羽浮标 --禁止食材
    oceanfishingbobber_canary = {"plant",.85}, --黄羽浮标 --禁止种植表
    oceanfishingbobber_crow = {"organisms",.85}, --黑羽浮标 --禁止生物表
    oceanfishingbobber_robin_winter = {"builds",.85}, --蔚蓝羽浮标 --禁止建筑表
    oceanfishingbobber_goose = {"materials",.9}, --鹅羽浮标 --禁止基础材料
    oceanfishingbobber_malbatross = {"giants",.9}, --邪天翁羽浮标 --禁止巨大生物表
}
local function Reward(inst, fisher, target, ban)  --用于自定义 空军时的奖励执行逻辑
    -- 一般 --OF_HARVEST表 覆盖本mod已设置的钓起物表
    local loots = rawget(GLOBAL,"OF_HARVEST") and OF_HARVEST or require("loots") --放到这个函数里 那么每次钓鱼访问都是最新的 方便重载loots文件
    -- 特殊情况
    local especiallys = require("especiallys")

    -- 这是直接抄鱼的碰撞
    local SWIMMING_COLLISION_MASK   = COLLISION.GROUND
                                    + COLLISION.LAND_OCEAN_LIMITS
                                    + COLLISION.OBSTACLES
                                    + COLLISION.SMALLOBSTACLES
    local PROJECTILE_COLLISION_MASK = COLLISION.GROUND

    local today = TheWorld.state.cycles  --世界天数
    local playerage = fisher.components.age:GetAgeInDays() or 0 --玩家天数

    local isfullmoon = TheWorld.state.isfullmoon -- 满月
    local isnewmoon = TheWorld.state.isnewmoon -- 新月

    local CUSTOMARY = nil   -- 记录原碰撞组
    local Mass = nil        -- 记录原自由落体
    local NoPhysics = nil   -- 不存在物理
    local Fn_hit = nil      -- 记录原投掷结束方法
    local Fn_launch = nil   -- 记录原投掷开始方法
    local Fn = nil          -- 记录投掷结束要执行方法
    local Brain = nil       -- 记录脑子
    local Fn_p = nil        -- 记录额外参数
    local hatred = nil      -- 仇恨
    local IsActive = nil    -- 物理状态

    local function setoption(default,item)
        local i = item
        if default then
            for k,v in pairs(default) do
                i[k] = i[k] == nil and v or i[k]
            end
        end
        if TUNING.OFDATA.AVERAGE then
            i.chance = 1
        end     
        return i
    end

    -- 重组钓起物表
    local function recombination(t, only)
        local probably_loot = {}
        local loots_ = only and {} or deepcopy(loots)
        local extras = only and {} or deepcopy(TUNING.OCEANFISHINGROD_R)
        local specials = t and deepcopy(t) or {}
        -- 默认列表
        for name, child in pairs(loots_ and type(loots_) == "table" and loots_ or {}) do
            for k, v in ipairs(child and type(child) == "table" and child or {}) do
                if ban and name == ban then --禁止的表
                    break
                end
                if name == "giants" then
                    if not inspectProtect(fisher) then -- 前几天,不让玩家钓到boss
                        break
                    end
                    v.chance = v.chance * math.min(playerage/22 + 1, 5) -- 1~5 随天数增加
                end
                if name == "builds" then
                    v.chance = v.chance * math.min(today/40 + 1,5) --建筑概率慢慢增加
                end
                table.insert(probably_loot, setoption(child.default, v))
            end
        end     
        -- 扩展列表 
        for name, extra in pairs(extras and type(extras) == "table" and extras or {}) do
            for k, v in ipairs(extra and type(extra) == "table" and extra or {}) do
                table.insert(probably_loot, setoption(extra.default, v))
            end
        end
        -- 特殊列表
        for name, special in pairs(specials and type(specials) == "table" and specials or {}) do
            for k, v in ipairs(special and type(special) == "table" and special or {}) do
                table.insert(probably_loot, setoption(special.default, v))
            end
        end
        return probably_loot
    end
    local function OnProjectileLand(inst)
        if Brain then
            -- inst:SetBrain(Brain)
            inst:RestartBrain("钓起中") 
        end
        -- 延迟执行，给玩家时间，避免被卡海（建筑晚些 生物1s）
        inst:DoTaskInTime(Brain and 0 or 2,function(inst)
            if inst == nil or not inst:IsValid() then return end
            inst.Physics:SetCollisionMask(CUSTOMARY or SWIMMING_COLLISION_MASK) --WORLD
            inst.Physics:SetMass(Mass or 0)
            if IsActive == false then
                inst.Physics:SetActive(false)
            end
        end)
        -- 投掷
        if Fn_hit == nil then
            inst:RemoveComponent("complexprojectile")
        else
            inst.components.complexprojectile:SetOnHit(Fn_hit)
            inst.components.complexprojectile:SetOnLaunch(Fn_launch or nil)
        end
        -- 物理学
        if NoPhysics then
            RemovePhysicsColliders(inst) -- 移除物理
        end
        -- 溺水
        if inst.components.drownable then
            inst.components.drownable.enabled = true
        end
        -- 记住家
        if inst.components.knownlocations then 
            inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition(), false) -- 重新记住
        end
        -- 清醒
        if inst.components.sleeper then
            inst.components.sleeper:WakeUp()
        end
        -- 设置仇恨
        if inst.components.combat and hatred then
            inst.components.combat:SuggestTarget(fisher)
            inst:StartUpdatingComponent(inst.components.combat) --开始刷新组件
        end
        if Fn ~= nil then
            Fn(inst, fisher, target, Fn_p)
        end
        --触发监听器 方便堆叠
    end
    local function SpawnLoot(loot)
        local prefab = type(loot.item) == "table" and loot.item[math.random(#loot.item)] or loot.item
        -- local prefab = string.sxx
        if TUNING.of_only[prefab] and TUNING.of_only[prefab][1] >= TUNING.of_only[prefab][2] then --检查一下是否满足生成数量了
            prefab = "goldnugget"
            loot = {}
        end
        -- 是包裹
        if loot.pack and math.random() < (loot.pack_chance or .65) then
            local bagname = ((STRINGS.NAMES[string.upper(prefab)] or "未知")..STRINGS.NAMES["BAG"])
            local name = loot.announce and bagname or loot.name
            loot = { name = name, eventF = function(i,f,t,p) i:SetData(p) end, parameter = {item=prefab, name=bagname} }
            prefab = "bag"
        end

        local item = SpawnPrefab(prefab)
        
        if item == nil then return end -- 保险
        SetSpellCB(item,fisher) --随机皮肤
        --通常生物生成后，不会设置添加脑子 实体唤醒后才会添加脑子
        --故原先版本是后一帧判断是否有脑子，现改为落地后在添加脑子
        --有部分生物是给脑子后直接开始脑子，故先暂停脑子，后移除脑子
        if item.brainfn then 
            -- item:StopBrain() 
            item.sleepstatepending = true
            Brain = true--记录使用的脑子
            -- item.brainfn = nil
            item:StopBrain("钓起中")
        end
        -- 是否宣告
        if loot.announce or loot.name then
            local fisher_name = fisher and fisher:GetDisplayName() or "???"
            local item_name = loot.name or item:GetDisplayName() or item
            TheNet:Announce(fisher_name .. " 钓到了 " .. item_name)
            --local item_describe = (loot.describe and type(loot.describe) == "table" and loot.describe[math.random(#loot.describe)] or loot.describe) or ""
            --TheNet:Announce(fisher_name .. " 钓到了 " .. item_name..item_describe)
        end

        if item.Physics then
            IsActive = item.Physics:IsActive()

            -- 设置质量，建筑为0，默认 1 物品
            Mass = item.Physics:GetMass() 
            item.Physics:SetMass(loot.build and 0 or 1)

            -- 设置碰撞组，不会碰海岸、船、玩家等
            CUSTOMARY = item.Physics:GetCollisionMask()
            item.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)  -- WORLD   

            if IsActive == false then
                item.Physics:SetActive(true)
            end
        else
            NoPhysics = true
            MakeInventoryPhysics(item) -- 添加物理
            item.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)
            --print("状态2",NoPhysics)
        end

        -- 要有 Physics，才能添加 complexprojectile
        if item.components.complexprojectile == nil then
            item:AddComponent("complexprojectile")
        else -- 投掷类物品
            Fn_hit = item.components.complexprojectile.onhitfn
            Fn_launch = item.components.complexprojectile.onlaunchfn
        end
        -- 设置投掷结束和开始时执行方法
        item.components.complexprojectile:SetOnHit(OnProjectileLand)
        item.components.complexprojectile:SetOnLaunch(nil)

        -- 防溺水，蜘蛛猪人等
        if item.components.drownable then
            item.components.drownable.enabled = false
        end 

        -- 设置睡眠
        if item.components.sleeper and not loot.sleeper then
            item.components.sleeper:GoToSleep(0)
        end

        -- 先给一个玩家位置为家 等待落地后重新设置家位置
        if item.components.knownlocations then 
            item.components.knownlocations:RememberLocation("spawnpoint", fisher:GetPosition(), false) -- 重新记住
        end

        -- 设置仇恨
        if item.components.combat and not loot.hatred then
            hatred = true
            --基本没有用啊--执行完后会在唤醒实体时添加更新战斗组件
            item:StopUpdatingComponent(item.components.combat) --停止刷新组件
        end

        --受难 有67%概率随机耐久随机新鲜值
        if TUNING.OFDATA.DURABLE > 0 and math.random() > TUNING.OFDATA.DURABLE then 
            if item.components.fueled then
                item.components.fueled:SetPercent(math.random()) --随机燃料值
            end
            if item.components.finiteuses then
                item.components.finiteuses:SetPercent(math.random()) --随机耐久
            end
            if item.components.perishable then
                item.components.perishable:SetPercent(math.random()) --随机新鲜值
            end
        end

        -- 在钓起时执行
        if loot.eventF ~= nil and type(loot.eventF) == "function" then
            loot.eventF(item, fisher, target, loot.parameter)
        end

        -- 在投掷到地面时执行
        if loot.eventA ~= nil and type(loot.eventA) == "function" then
            Fn = loot.eventA
            Fn_p = loot.parameter
        end

        -- 记录事件
        if prefab == "fishingsurprised" and (loot.eventF or loot.eventA) then
            fisher:RecordEvents_of(loot)
        end

        -- 弹道
        local targetpos = inst.components.oceanfishingrod:CalcCatchDest(target:GetPosition(), fisher:GetPosition(), 4) --鱼钩 玩家的位置
        local startpos = target:GetPosition()
        inst.components.oceanfishingrod:_LaunchFishProjectile(item, startpos, targetpos) --发射 物品、起始坐标、预定坐标 
    end

    -- 根据世界情况来选择
    local loot = nil

    loot = isfullmoon and WeightRandom(recombination({especiallys.fullmoon}, true)) or nil 
    loot = loot or (isnewmoon and WeightRandom(recombination({especiallys.newmoon}, true)) or nil)
    loot = loot or WeightRandom(recombination())
    
    if loot == nil or loot.item == nil then return end -- 保险
    -- 生成
    SpawnLoot(loot)
end

local function OnDoneFishing(inst, reason, lose_tackle, fisher, target) --自己、原因、  、钓鱼的人、 目标
    if inst.components.container ~= nil and lose_tackle then
        if Bobbers then
            inst.components.container:ConsumeByKey(1,1)
            inst.components.container:ConsumeByKey(2,1)
        else
            inst.components.container:DestroyContents()
        end
    end

    if inst.components.container ~= nil and fisher ~= nil and inst.components.equippable ~= nil and inst.components.equippable.isequipped then
        inst.components.container:Open(fisher)
    end

    local tackle = inst.components.oceanfishingrod.gettackledatafn(inst)
    local bobber = tackle.bobber and tackle.bobber.prefab or "Not"

    local function AddSum()
        -- 记录玩家 钓鱼次数
        if fisher.components.record_of then
            fisher.components.record_of:Add()
        end

        -- 浮漂可能消耗
        if Bobbers and bobbers[bobber] and bobbers[bobber][2] < math.random() then
            inst.components.container:ConsumeByKey(1,1)
        end
    end

    -- 空军情况 
    if reason == "reeledin" and fisher ~= nil and fisher:HasTag("player") and not fisher:HasTag("refusefish") then
        local ban = Bobbers and bobbers[bobber] and bobbers[bobber][1] or nil
        local times = 3
        if inst.Reward then
            for i = 1, times do
                inst.Reward(inst, fisher, target, bobber)
            end
        else
            for i = 1, times do
                Reward(inst, fisher, target, ban) -- 海竿，钓鱼人，目标, 浮标
            end
            if ban == "double" then
                for i = 1, times do
                    Reward(inst, fisher, target)
                end
            end
        end
        -- if inst.Reward then -- 可以执行你的方法
        --     inst.Reward(inst, fisher, target, bobber) 
        -- else
        --     Reward(inst, fisher, target, ban) -- 海竿，钓鱼人，目标, 浮标
        --     if ban == "double" then
        --         Reward(inst, fisher, target)
        --     end
        -- end
        if inst.AddSum then
            inst:AddSum(fisher,target)
        else
            AddSum()
        end
    end
    -- -- 钓起鱼
    -- if reason == "success" and fisher ~= nil and fisher:HasTag("player") then
    --     AddSum()
    -- end
end
local container_params = {
    widget = {
        slotpos = {
            Vector3(0,   32 + 4,  0),
            Vector3(0, -(32 + 4), 0),
        },
        slotbg = {
            { image = "fishing_slot_bobber.tex" },
            { image = "fishing_slot_lure.tex" },
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 60, 0),
    },
    acceptsstacks = true,
    usespecificslotsforitems = true,
    type = "hand_inv",
    itemtestfn = function(container, item, slot)
        -- return (slot == nil and not item:HasTag("cookable") and (item:HasTag("oceanfishing_bobber") or item:HasTag("oceanfishing_lure")))-- 禁止添加食用物品
        return (slot == nil and (item:HasTag("oceanfishing_bobber") or item:HasTag("oceanfishing_lure")))
            or (slot == 1 and item:HasTag("oceanfishing_bobber"))
            or (slot == 2 and item:HasTag("oceanfishing_lure"))
    end
}
AddPrefabPostInit("oceanfishingrod",function(inst)
    if TheWorld.ismastersim then
        if inst.components.oceanfishingrod then
            inst.components.oceanfishingrod.ondonefishing = OnDoneFishing  -- 钓鱼完毕 
        end
        if Bobbers and inst.components.container then
            inst.components.container:WidgetSetup("oceanfishingrod", container_params) --更改渔竿容器数据 使其可以堆叠
        end
        if inst.components.binding == nil then
            inst:AddComponent("binding")
        end
    end
end)

-- reason: 有这种情况
-- 1 reeledin ...\scripts\actions.lua 的 ACTIONS.OCEAN_FISHING_STOP 表示 空军
-- 2 success ...\scripts\components\oceanfishingrod.lua 的 CatchFish 表示 捕鱼成功
-- 3 linesnapped ...\scripts\components\oceanfishingrod.lua 的 Reel 表示 线断了
-- 4 interupted ...\scripts\components\oceanfishingrod.lua 的 OnUpdate 表示 钓鱼行为 被打断
-- 5 linetooloose ...\scripts\components\oceanfishingrod.lua 的 OnUpdate 表示 线太松
-- 6 nil ...\scripts\components\oceanfishingrod.lua 的 OnUpdate 表示 钓鱼人没了

--[[

fishing_stats = {
    bobber = "",
    lure = "",
}

hook --空钩
spoiled_food --腐烂物
seed --种子
berry --浆果
fig --无花果
oceanfishinglure_spoon_red --日出匙型假饵
oceanfishinglure_spoon_green --黄昏匙型假饵
oceanfishinglure_spoon_blue --夜间匙型假饵

oceanfishinglure_spinner_red --日出旋转亮片
oceanfishinglure_spinner_green --黄昏旋转亮片
oceanfishinglure_spinner_blue --夜间旋转亮片

oceanfishinglure_hermit_rain --雨天鱼饵
oceanfishinglure_hermit_snow --雪天鱼饵
oceanfishinglure_hermit_drowsy --麻醉鱼饵 
oceanfishinglure_hermit_heavy --重量级鱼饵
trinket_17 --弯曲的勺子

---

]]
