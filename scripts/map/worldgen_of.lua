-- GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
-- 支持世界设置扩展
-- if #OPTIONS > 0 then
-- 	print("创建海钓世界设置扩展内容")
-- 	rawset(GLOBAL, "OCEANFISHEDMOD_OPTIONS", OPTIONS)
-- else
-- 	local custom_1 = {
-- 		name = "测试扩展名称",
-- 		task_set = {
-- 			ocean_prefill_setpieces = {["Nightmare_Home"] = {count =1},},
-- 		}
-- 	}

-- 	table.insert(OPTIONS, custom_1)

-- 	rawset(GLOBAL, "OCEANFISHEDMOD_OPTIONS", OPTIONS)	
-- end



local StaticLayout = require("map/static_layout")
-- local obj_layout = require("map/object_layout")

local Layouts = {}
-- skull grail
Layouts["DefaultStart1"] = StaticLayout.Get("map/static_layouts/"..start_of, {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})

Layouts["OceanBoss"] = StaticLayout.Get("map/static_layouts/boss", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:OceanBoss", tags = {"sandstorm"}, node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})


-- 中庭布局
Layouts["AtriumEnd"] = StaticLayout.Get("map/static_layouts/rooms/atrium_end/atrium_end", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:AtriumEnd", tags = {"Atrium"}, node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
Layouts["AtriumEnd"].ground_types[1] = 201 --替换虚空为海洋地皮 还是让添加码头

-- 小月岛布局
Layouts["OceanMoon"] = StaticLayout.Get("map/static_layouts/ocean_moon", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:OceanMoon", tags = {"lunacyarea"}, node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
-- 天体祭坛 部件1
Layouts["OceanMoon"].layout["moon_altar_astral_marker_1"] = {
	{
		x = 1.5-4/2, --地皮中间 - 布局宽度一半 (将坐标轴原点从左上角移到中心)
		y = 1.5-4/2,
		width = 0,
		height = 0,
		properties = {}
	}
}
-- 小月岛布局
Layouts["OceanMoon2"] = StaticLayout.Get("map/static_layouts/ocean_moon", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:OceanMoon2", tags = {"lunacyarea"}, node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
-- 天体祭坛 部件2
Layouts["OceanMoon2"].layout["moon_altar_astral_marker_2"] = {
	{
		x = 1.5-4/2,
		y = 1.5-4/2,
		width = 0,
		height = 0,
		properties = {}
	}
}
-- 月台岛布局 of_spawnlayout("OceanMoonbase", true)
Layouts["OceanMoonbase"] = StaticLayout.Get("map/static_layouts/ocean_moonbase", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:OceanMoonbase", node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
-- of_spawnlayout("NightmareHome")
-- 噩梦家园布局
Layouts["NightmareHome"] = StaticLayout.Get("map/static_layouts/nightmare_home", {
	areas = {
		item_area = function(area, data) --给定了坐标 要形成相对有一定间隔效果。 也可以直接返回 {"fissure","fissure"} 那么会在这个范围内随机位置生成两个
			local vert = data.height > data.width
			local x = data.x - data.width/2.0
			local y = data.y - data.height/2.0
			local spacing = math.random(3,8)
			local num = math.ceil((vert and data.height or data.width) / spacing)
			local prefabs = {}
			for i = 1, num do
				table.insert(prefabs,
				{
					prefab = "fissure", --噩梦裂缝
					x = x,
					y = y,
				})
				if vert then
					y = y + spacing
				else
					x = x + spacing
				end
			end
			return prefabs
		end
	},
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:NightmareHome", node_type = 7},
	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
-- 风滚草岛布局
Layouts["TumbleweedLand"] = StaticLayout.Get("map/static_layouts/tumbleweed_land", {
	areas = {
		item_area = function(area, data)
			local vert = data.height > data.width
			local x = data.x - data.width/2.0
			local y = data.y - data.height/2.0
			local spacing = math.random(80,160)/10.0
			local num = math.ceil((vert and data.height or data.width) / spacing)
			local prefabs = {}
			for i = 1, num do
				table.insert(prefabs,
				{
					prefab = "tumbleweedspawner",
					x = x,
					y = y,
				})
				if vert then
					y = y + spacing
				else
					x = x + spacing
				end
			end
			return prefabs
		end
	},
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:TumbleweedLand", node_type = 7},
	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})

----------------------------------------------------------------------------------------------------------------
local PoissonDiskSampling = require("map/poissondisksampling")
-- 测试自定义生成岛屿
local function GetLand()
	local layout = {}

	layout.type = 0 --0~5
	layout.scale = 1
	layout.layout_file = {} -- 布局文件的内容
	layout.ground_types = {
		-- 201,202,15,23,24
		201, 24
	}
	local is_land = nil
	local size = 20
	layout.ground = require("map/cellularautomata").GetLand(size) --{}
	-- local w = #layout.ground --math.random(16,22)
	-- local h = w

	local pds = PoissonDiskSampling(size, size, 1, 20)
	local points = pds:Generate()
	local prefab = "ancient_altar_broken_spawner" --损坏的远古伪科技站刷新点 查看文件..\scripts\prefabs\ruinsrespawner.lua
	layout.layout = {}
	if layout.layout[prefab] == nil then
		layout.layout[prefab] = {}
	end

	if #points > 1 then
		local pos = points[1]
		table.insert(layout.layout[prefab], {x=pos.x-size/2, y=pos.y-size/2, properties={}, width=0, height=0})
	else
		table.insert(layout.layout[prefab], {x=0, y=0, properties={}, width=0, height=0})
	end

	-- 随机陆地为刷新点
	-- if is_land and #is_land > 0 then
	-- 	local pos = is_land[math.random(1,#is_land)]
	-- 	local x = pos[2]-w/2-.5
	-- 	local y = pos[1]-h/2-.5
	-- 	-- print("远古塔",w, x,y, pos[1],pos[2], layout.ground[pos[1]][pos[2]])
	-- 	table.insert(layout.layout[prefab], {x=x, y=y, properties={}, width=0, height=0})
	-- else
	-- 	-- table.insert(layout.layout[prefab], {x=0, y=0, properties={}, width=0, height=0})
	-- 	table.insert(layout.layout[prefab], {x=-w/2, y=-h/2, properties={}, width=0, height=0})
	-- end
    
    layout.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
    layout.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
    layout.layout_position = LAYOUT_POSITION.CENTER

	layout.add_topology = {room_id = "StaticLayoutIsland:Confusion", node_type = 7}
	layout.defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	}
	layout.disable_transform = true --禁止旋转
	return layout
end

Layouts["Confusion"] = GetLand()
-- 隐藏岛
Layouts["NineGrid"] = StaticLayout.Get("map/static_layouts/ninegrid", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,

    add_topology = {room_id = "StaticLayoutIsland:NineGrid", node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
-- 王八岛
Layouts["Turtle"] = StaticLayout.Get("map/static_layouts/turtle", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    disable_transform = true, --禁止变化 宽高（内容不一致）反转一下布局物品就会偏移

    add_topology = {room_id = "StaticLayoutIsland:Turtle", node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
-- 垃圾岛布局
Layouts["JunkYard"] = StaticLayout.Get("map/static_layouts/junk_yard1", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    add_topology = {room_id = "StaticLayoutIsland:JunkYard", node_type = 7},
    disable_transform = true, --禁止翻转
	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
	areas =
	{
		wobot_area = { "storage_robot" },
		grass_area = {"grass","evergreen_stump","evergreen_stump"},
	},
})
local JunkYard_size = #Layouts["JunkYard"].ground
local JunkYard_ground = {}
for x=1, JunkYard_size + 4 do
	if JunkYard_ground[x] == nil then
		JunkYard_ground[x] = {}
	end
	for y=1, JunkYard_size + 4 do
		local tile = Layouts["JunkYard"].ground[x-2] and Layouts["JunkYard"].ground[x-2][y-2] or nil
		if not tile or tile == 0 then
			JunkYard_ground[x][y] = 6
		else
			JunkYard_ground[x][y] = tile
		end
		-- 四角为海
		if x == 1 and (y == 1 or y == JunkYard_size + 4) or 
			x == JunkYard_size + 4 and (y == 1 or y == JunkYard_size + 4) then
			JunkYard_ground[x][y] = 0
		end
	end
end
Layouts["JunkYard"].ground = JunkYard_ground
-- 可以用月台岛地皮布局
-- Layouts["JunkYard"].ground = Layouts["OceanMoonbase"].ground
local function AdditionalItem()
	local core= 0
	local edge= JunkYard_size+4-(JunkYard_size+4)/2
	Layouts["JunkYard"].layout["monkeyisland_center"] = {{x=core,y=core,properties={},width=0, height=0}}
	Layouts["JunkYard"].layout["monkeyisland_direction"] = {{x=core,y=core-1,properties={},width=0, height=0}}
	Layouts["JunkYard"].layout["monkeyisland_dockgen_safeareacenter"] = {{x=edge,y=edge,width=0, height=0,properties={data={width=30, height=30}}}}
end
AdditionalItem()

local function GetMigong()
	require("map/dungeonarea")
	local max = 25
	local rooms,core,connects,maze,corner,area = Generate({width=max,height=max,roomnum = 50})
	local layout = {}
	layout.type = 0 --0~5
	layout.scale = 1
	layout.layout_file = {} -- 布局文件的内容
	layout.ground_types = {
		WORLD_TILES.OCEAN_COASTAL, 22, 3, 19
	}
	layout.ground = {}
	for idx = 1, #area do
	    local i = math.ceil(idx/max)
	    local j = (idx - 1) % max + 1
	    if layout.ground[j] == nil then
	    	layout.ground[j] = {}
	    end
	    layout.ground[j][i] = area[idx] + 1
	end
	local function isBoundary(a, b)
		if a > 0 and a <= max and b > 0 and b <= max then
			return true
		end
	end
	local function GetAisleNum(x, y)
		local num = 0
		if isBoundary(x-1, y) and layout.ground[x-1][y] == 4 then
			num = num + 1
		end
		if isBoundary(x+1, y) and layout.ground[x+1][y] == 4 then
			num = num + 1
		end
		if isBoundary(x, y-1) and layout.ground[x][y-1] == 4 then
			num = num + 1
		end
		if isBoundary(x, y+1) and layout.ground[x][y+1] == 4 then
			num = num + 1
		end
		return num
	end
	local prefab = "pandoraschest"
	layout.layout = {}
	if layout.layout[prefab] == nil then
		layout.layout[prefab] = {}
	end
	for i = 1, max do
		for j = 1, max do
			if layout.ground[i][j] == 4 and GetAisleNum(i,j) == 1 then --四向只相邻一个过道
				local y = i-max/2-.5
				local x = j-max/2-.5
				table.insert(layout.layout[prefab], {x=x, y=y, properties={scenario = "chest_labyrinth"}, width=0, height=0})
			end
		end
	end
    
    layout.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
    layout.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
    layout.layout_position = LAYOUT_POSITION.CENTER

	layout.add_topology = {room_id = "StaticLayoutIsland:Migong", tags = {"zdy_tag_of", "Nightmare"}, node_type = 7}

	layout.defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	}
	layout.disable_transform = true --禁止旋转
	return layout
end
Layouts["Migong"] = GetMigong()


-- 小丑岛
Layouts["Joker_of"] = StaticLayout.Get("map/static_layouts/joker_of", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    disable_transform = true, --禁止变化 宽高（内容不一致）反转一下布局物品就会偏移

    add_topology = {room_id = "StaticLayoutIsland:Joker_of", node_type = 7},

	defs={
		--有特别活动吗
		welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
	},
})
----------------------------------------------------------------------------------------------------------------
-- local ysz = Layouts["OceanBoss"].layout["antlion_spawner"][1]
-- print("蚁狮子坐标", ysz.x, ysz.y)

-- 是生成世界时 将布局添加到对应表里
if rawget(_G,"WorldSim") then -- 此时环境改为本体的 
	local L = require("map/layouts").Layouts
	for k,v in pairs(Layouts) do
		L[k] = v
	end

	-- 移除蟹岛上面的物品
	L["HermitcrabIsland"].layout["sapling_moon"] = nil
	L["HermitcrabIsland"].layout["bullkelp_beachedroot"] = nil
	L["HermitcrabIsland"].layout["moon_tree"] = nil
	L["HermitcrabIsland"].layout["moonglass_rock"] = nil
	return
end

-- 加载蟹岛 (此时，不走官方的 就没有此岛。)
Layouts["HermitcrabIsland"] = StaticLayout.Get("map/static_layouts/hermitcrab_01",
{
	add_topology = {room_id = "StaticLayoutIsland:HermitcrabIsland", tags = {"RoadPoison", "nohunt", "nohasslers", "not_mainland"}},
	min_dist_from_land = 0,
})
Layouts["HermitcrabIsland"].layout["sapling_moon"] = nil
Layouts["HermitcrabIsland"].layout["bullkelp_beachedroot"] = nil
Layouts["HermitcrabIsland"].layout["moon_tree"] = nil
Layouts["HermitcrabIsland"].layout["moonglass_rock"] = nil

-- 非生成世界阶段 存储数据下来 方便后续指令调用
return {
	Layouts = Layouts,
}