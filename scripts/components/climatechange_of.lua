local _hasfx = not TheNet:IsDedicated() --是客户端的
local _lunarhailfx = _hasfx and SpawnPrefab("lunarhail") or nil
local _acidrainfx = _hasfx and SpawnPrefab("caveacidrain") or nil
local _fogfx = _hasfx and SpawnPrefab("zdy_mist_of") or nil

local preciprate = .2
local _activatedplayer = nil

local function OnPlayerActivated(src, player)
    _activatedplayer = player
    if _hasfx then
    	-- print("添加fx")
        _acidrainfx.entity:SetParent(player.entity)
        _acidrainfx:PostInit()
        _lunarhailfx.entity:SetParent(player.entity)
        _lunarhailfx:PostInit()
        _fogfx.entity:SetParent(player.entity)
    end
end

local function OnPlayerDeactivated(src, player)
    if _activatedplayer == player then
        _activatedplayer = nil
    end
    if _hasfx then
        _acidrainfx.entity:SetParent(nil)
        _lunarhailfx.entity:SetParent(nil)
        _fogfx.entity:SetParent(nil)
    end
end

-- 气候变化
local ClimateChange = Class(function(self, inst)
	self.inst = inst

    self.teyp = {
        "none",
        "acidrain",
        "lunarhail",
        "fog",
    }
    if _hasfx then
        self.teypdata = {
            {0, 0, 0},
            {.5, 0, 0},
            {0, .5, 0},
            {0, 0, .5},
        }
    end
    -- 0~7
    self.current = net_tinybyte(inst.GUID, "climatechange.current", "climatechange_current")

    -- 注册玩家加入和离开世界事件
	self.inst:ListenForEvent("playeractivated", OnPlayerActivated, TheWorld)
	self.inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, TheWorld)

    self.inst:ListenForEvent("climatechange_current", function(inst)
        -- 客户端执行
        if _hasfx then
            local data = self.teypdata and self.teypdata[self.current:value()] or nil
            local p1 = data and data[1] or 0
            local p2 = data and data[2] or 0
            local p3 = data and data[3] or 0

            _acidrainfx.particles_per_tick = 2 * p1
            _acidrainfx.splashes_per_tick = 1 * p1
            _lunarhailfx.particles_per_tick = 2 * p2
            _lunarhailfx.splashes_per_tick = 1 * p2
            _fogfx.particles_per_tick = 1 * p3 
        end
        -- 服务器执行
        if TheWorld.ismastersim then
            local type = self.teyp[self.current:value()]
            if type then
                TheWorld:PushEvent("setclimate_of", type)
            end
        end
    end)
end)

--------------------------------------------------------------------------
--[[ Public member functions ]] --公共函数
--------------------------------------------------------------------------
local function OnTimerDone(inst, self)
    self:SetCurrent(1)
end
-- 清理任务
function ClimateChange:Cancel()
    if self.climatechange_task then
        self.climatechange_task:Cancel()
        self.climatechange_task = nil
    end
end
-- 更改状态
function ClimateChange:SetCurrent(value)
    if type(value) == "number" and value > 0 and value < 8 then
        self.current:set(value)
        if value ~= 1 then
            self:Cancel()
            self.climatechange_task = self.inst:DoTaskInTime(60, OnTimerDone, self)
        end
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]] --保存与加载
--------------------------------------------------------------------------

function ClimateChange:OnSave()
    if not _hasfx then
        return {
        	current = self.current:value()
        }
    end
end

function ClimateChange:OnLoad(data)
    if not _hasfx and data and data.current then
        self:SetCurrent(data.current)
    end
end

return ClimateChange