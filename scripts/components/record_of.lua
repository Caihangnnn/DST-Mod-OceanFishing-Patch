local list = {
	"goldnugget", --黄金
	"thulecite", --铥矿
	"purplegem",
	"bluegem",
	"redgem",
	"orangegem",
	"yellowgem",
	"greengem",
	"dreadstone",
	"goldnugget", --黄金
	"goldnugget", --黄金
	"deerclops_eyeball",
	"minotaurhorn",
	"healingsalve",
	"bandage",
	"gears",
}

local bobbers = {
    "twigs", --树枝 --禁止物品表
    "oceanfishingbobber_ball", --木球浮标 --禁止事件
    "oceanfishingbobber_oval", --硬物浮标 --禁止穿戴表
    -- "trinket_8", --硬化橡胶塞 --双倍钓
    "oceanfishingbobber_robin", --红羽浮标 --禁止食材
    "oceanfishingbobber_canary", --黄羽浮标 --禁止种植表
    "oceanfishingbobber_crow", --黑羽浮标 --禁止生物表
    "oceanfishingbobber_robin_winter", --蔚蓝羽浮标 --禁止建筑表
    "oceanfishingbobber_goose", --鹅羽浮标 --禁止基础材料
    "oceanfishingbobber_malbatross", --邪天翁羽浮标 --禁止巨大生物表
}

local num_data = {
	[69] = function(item)
		table.insert(item, "lifeinjector")
		table.insert(item, "lifeinjector")
		table.insert(item, "batbat")
		table.insert(item, "rabbithat")
	end,
	[233] = function(item)
		table.insert(item, "lifeinjector")
		table.insert(item, "amulet")
		table.insert(item, "slurtlehat")
		table.insert(item, "armorsnurtleshell")
	end,
	[666] = function(item)
		table.insert(item, "greenamulet")
		table.insert(item, "greenstaff")
	end,
	[999] = function(item)
		local bag = SpawnPrefab("bag")
		bag:SetData({item="pigking", name=STRINGS.NAMES.PIGKING..STRINGS.NAMES.BAG})
		table.insert(item, bag)
	end,
}

local Record = Class(function(self, inst)
	self.inst = inst

	-- 记录钓鱼事件总信息
	self.event = {}
	-- 钓鱼数量
	self.number = 0 --ThePlayer.components.record_of.number = 199
	-- 上次钓鱼事件执行函数 (这部分数据无法保存,没办法咯,每次重进游戏都为无)
	self.last = nil
	self.last_F_fn = nil
	self.last_A_fn = nil
	self.last_parameter = nil
	self.gift_item = {}
end)

--------------------------------------------------------------------------
--[[ Public member functions ]] --公共函数
--------------------------------------------------------------------------

function Record:AddEvent(name, fn1, fn2, parameter)
	self.inst.update_oceanfishin_data:set(true) --数据发生变化了 允许发送rpc请求数据

	self.event[name] = self.event[name] and self.event[name] + 1 or 1
	-- 记录上次钓到的事件
	if name == "上次事件" then return end --防止堆栈溢出
	self.last = name
	self.last_F_fn = fn1
	self.last_A_fn = fn2
	self.last_parameter = parameter
end

function Record:Pack()
	if self.gift_item == nil or #self.gift_item == 0 then return end
	local gift = SpawnPrefab("gift")
	local items = {}
	for _,name in ipairs(self.gift_item) do  --船套装 桨 瓶中信 长矛 硬化橡胶塞
        local item = type(name) == "table" and name or SpawnPrefab(name)
        SetSpellCB(item, self.inst)
        table.insert(items, item)
    end
    gift.components.unwrappable:WrapItems(items) --打包物品
    for i, v in ipairs(items) do --删除生成出来的
        v:Remove()
    end
    self.inst.components.inventory:GiveItem(gift)
    TheNet:Announce(self.inst:GetDisplayName() .. " 钓了 " .. self.number .. "次, 奖励一次礼物包裹")
    self.gift_item = {}
end

-- 钓鱼数量增加
function Record:Add()
	self.inst.update_oceanfishin_data:set(true) --数据发生变化了 允许发送rpc请求数据 本身是true值再赋值true不会触发事件

	self.number = self.number + 1
	if self.number%200 == 0 then
		local num = self.number/200
		local item = nil
		if num < 2 then
			item = "origin_certificate"
		else
			item = list[math.random(#list)]
		end
		table.insert(self.gift_item, item)

		-- 额外给浮标
		for i = 1, math.random(3, 6) do
			table.insert(self.gift_item, bobbers[math.random(#bobbers)])
		end
		if math.random() > .15 then
			table.insert(self.gift_item, "trinket_8")
		else
			table.insert(self.gift_item, "trinket_8")
		end
		--再额外奖励 码头套装吧
		local item = SpawnPrefab("dock_kit")
		item.components.stackable:SetStackSize(4)
		table.insert(self.gift_item, item)
	end
	-- 奖励特殊的
	if num_data[self.number] then
		num_data[self.number](self.gift_item)
	end
	self:Pack()
end
-- 访问
function Record:Get()
	local all = {
		e = {},
		n = self.number,
		l = self.last,
	}
	for k,v in pairs(self.event) do
		table.insert(all.e, {k,v})
	end
	return all
end
--------------------------------------------------------------------------
--[[ Save/Load ]] --保存与加载
--------------------------------------------------------------------------

function Record:OnSave()
    return {
    	event = self.event,
    	number = self.number,
    }
end

function Record:OnLoad(data)
	-- print("加载玩家钓鱼数据")
	-- print(dumptable(data, 1, 5))
	if data == nil then return end
    --先保存下来 初始化时进行赋值
    for k,v in pairs(data.event or {}) do
    	self.event[k] = v
    end
    self.number = data.number or 0
end

-- 变猴子也继承
function Record:TransferComponent(newinst)
    local data = self:OnSave()
    if data then
        local newcomponent = newinst.components.record_of
        if not newcomponent then
            newinst:AddComponent("record_of")
            newcomponent = newinst.components.record_of
        end
        newcomponent:OnLoad(data)
    end
end

return Record