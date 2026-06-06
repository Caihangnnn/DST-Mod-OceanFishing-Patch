local function optentity(v) return v ~= nil and type(v) == "table" end
local function checknumber(v) return v ~= nil and type(v) == "number" end
local function checkstring(v) return v ~= nil and type(v) == "string" end

-----------------------------------------------------------------------
local oceancolour_time = 0
local function oceancolour_gradient(fn) --渐变色
    if TheWorld.gradient_of_task then
        TheWorld.gradient_of_task:Cancel()
        TheWorld.gradient_of_task = nil
    end
    TheWorld.gradient_of_task = TheWorld:DoPeriodicTask(FRAMES, function()
        local num = fn()
        if num>1 or num<0 then --控制时间在 1s内
            TheWorld.gradient_of_task:Cancel()
            TheWorld.gradient_of_task = nil
            oceancolour_time = 0
            TheWorld.Map:SetOceanTextureBlendAmount(num > 1 and 1 or 0)
            if num < 0 then
                TheWorld.ocean_colour_kg = false --结束渐变后 变回去
            end
        else
            TheWorld.Map:SetOceanTextureBlendAmount(num)
            oceancolour_time = oceancolour_time + 1
        end
    end)
end
-- 查找对应实体
local function getEntities(networkid, x, y, z, r, must_have_tags, cant_have_tags, must_have_one_of_tags)
    local ents = TheSim:FindEntities(x,y,z, r or 20, must_have_tags, cant_have_tags, must_have_one_of_tags)
    for i, ent in ipairs(ents) do
        if ent and ent.Network and ent.Network:GetNetworkID() == networkid then
            return ent
        end
    end
end
-- 设置摄像机给谁
local function SetTheCamera(target) if TheCamera then TheCamera:SetTarget(target or TheFocalPoint) end end

-----------------------------------------------------------------------
local khd = {
    -- 接收玩家钓鱼数据
    fishingdata = function(data)
        -- print(dumptable(data, 1, 5))
        if not optentity(data) then return end
        local e = data.e or {}
        local n = data.n or 0
        local l = data.l or "无"
        TUNING.OFDATA.OCEANFISHIN_DATA = data
        -- 将数据填充到客户端ui上
        if ThePlayer and ThePlayer.HUD and ThePlayer.HUD.oceanfishinginformation_of then
            -- 更新数据
            ThePlayer.HUD.oceanfishinginformation_of:SetData()
        end
    end,
    -- 改变海洋颜色
    oceancolour = function(data)
        if data then
            TheWorld.ocean_colour_kg = true
            oceancolour_gradient(function() return oceancolour_time*FRAMES end)
        else
            oceancolour_gradient(function() return 1-oceancolour_time*FRAMES end)
        end
    end,
    -- 开始操控pnc了
    start_npc_move = function(data)
        if data == nil or not checknumber(data[1]) then return end
        TheWorld:DoTaskInTime(0.5, function()
            local x,y,z = ThePlayer.Transform:GetWorldPosition()
            local ent = getEntities(data[1], x,y,z, data[2], {"locomotor"})
            if ent then
                --设置摄像机
                SetTheCamera(ent)
                if ThePlayer.components.clientcontrolpuppet then
                    ThePlayer.components.clientcontrolpuppet:StartControl(ent)
                end
                ent:ListenForEvent("onremove", function() SetTheCamera() end)
            else
                print("失败，未从客户端找到目标")
                SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"npc_fail"}, nil, true))
            end
        end)
    end,
    -- 结束控制npc了
    end_npc_move = function(data)
        local tiem = .75
        ThePlayer.controlend_task = ThePlayer:DoTaskInTime(tiem, function()
            SetTheCamera()
        end)
        if ThePlayer.components.clientcontrolpuppet then
            ThePlayer.components.clientcontrolpuppet:StopControl()
        end
    end,
}
-- ThePlayer.components.cursable:RemoveCurse("MONKEY",10)

local function khd_handler(str)
    if str == nil then return end
    local success, savedata = RunInSandboxSafe(str)
    if success and type(savedata) == "table" and next(savedata) ~= nil then --字符串转为数组成功
        local index = savedata[1]
        local parameter = savedata[2]

        if index and khd[index] then
            khd[index](parameter)
        end
        -- print("【海钓mod】客户端：处理从服务器发送来的信息成功", index)
    else
        print("【海钓mod】客户端：处理从服务器发送来的信息失败")
    end
end
--客户端上 处理 服务器发来的信息
--当 海钓存档专服时, 服务器端的 AddClientModRPCHandler khd_handler内容不会触发, 但rpc要有注册。
AddClientModRPCHandler("of_RPC", "kehuduan", khd_handler)
--------------------------------------------------------------------------------------------------------------------------------------------------
local fwq = {
    -- 请求返回玩家数据
    getofdata = function(player, data)
        local all = player.components.record_of:Get()
        SendModRPCToClient(GetClientModRPC("of_RPC", "kehuduan"), player.userid, DataDumper({"fishingdata", all}, nil, true))

        -- 重置允许访问请求
        if player.update_oceanfishin_data:value() then
            player.update_oceanfishin_data:set(false)
        end
    end,
    -- 给玩家生成一个清理杖
    getclearing_staff_of = function(player, data)
        -- if player == nil then print("发送者非玩家？？？") return end
        local p = TheNet:GetClientTableForUser(player.userid)
        if p and p.admin then
            print((player:GetDisplayName() or player.userid).."玩家, 需要清理杖")
            local item = SpawnPrefab("clearing_staff_of")
            player.components.inventory:GiveItem(item)
        end
    end,
    -- 移动 npc 坐标
    npc_move_of = function(player, direction)
        local dir = checknumber(direction) and direction or nil
        local controlpuppet = player.components.controlpuppet
        if controlpuppet ~= nil and controlpuppet.PuppetMove then
            --移动
            controlpuppet:PuppetMove(dir)
        end
    end,
    -- npc 攻击 
    npc_attack = function(player)
        local controlpuppet = player.components.controlpuppet
        if controlpuppet ~= nil and controlpuppet.PuppetAttack then
            --攻击
            controlpuppet:PuppetAttack()
        end
    end,
    npc_fail = function(player)
        local controlpuppet = player.components.controlpuppet
        if controlpuppet ~= nil and controlpuppet.StopControl then
            --攻击
            controlpuppet:StopControl()
        end
    end,
    npc_vicinity = function(player)
        local self = player.components.controlpuppet
        if self and self.puppet then
            local x, y, z = self.puppet.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, 0, z, 4)
            for _, v in ipairs(ents) do
                if v ~= self.puppet then
                    local lmb, rmb = GetAction_of(player, v, self.puppet, self.puppet.replica.inventory)
                    if rmb then
                        if rmb.action == ACTIONS.ATTACK then
                            self:PuppetAttack(v)
                            return
                        end
                        -- 推送动作
                        self:PushAction(rmb, true)
                        return
                    end
                end
            end
        end
    end,
    betting = function(player, id)
        if id == nil then return end
        local x,y,z = player.Transform:GetWorldPosition()
        local ent = getEntities(id, x, y, z, nil, {"gambling_of"})
        if ent then
            ent:Betting()
        end
    end,
}

local function fwq_handler(player, str)
    if player == nil or str == nil then return end
    local success, savedata = RunInSandboxSafe(str)
    if success and type(savedata) == "table" and next(savedata) ~= nil then --字符串转为数组成功
        local index = savedata[1]
        local parameter = savedata[2]

        if index and fwq[index] then
            fwq[index](player, parameter)
        end
        -- print("【海钓mod】服务器：处理从客户端发送来的信息成功", index)
    else
        print("【海钓mod】服务器：处理从客户端发送来的信息失败")
    end
end
--服务器上 处理 客户端发来的信息
--当 海钓存档专服时, 玩家本地客户端的 AddModRPCHandler fwq_handler内容不会触发, 但prc要有注册(那么 客户端可以注册空函数 服务器里相同rpc可以为指定函数 隐藏了客户端上显示的rpc)。
AddModRPCHandler("of_RPC", "fuwuqi", fwq_handler)