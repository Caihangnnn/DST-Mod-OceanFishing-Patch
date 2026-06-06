GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local no_oceanfished = rawget(GLOBAL,"NO_OCEANFISHED")
local OPTIONS = rawget(_G,"OCEANFISHEDMOD_OPTIONS") or {}
--不要执行其他内容
if no_oceanfished then return end --lua文件本身可以看作一个函数，那么有个返回值很正常吧

--[[
客户端ui界面大部分是借鉴熔炉mod https://steamcommunity.com/sharedfiles/filedetails/?id=1938752683 
但直接抄也会有问题，就是预设加载问题，这部分是本人从报错的一步步看源码，一点点测试得到的。
]]

-- 仅创建世界时执行的内容
if rawget(GLOBAL,"WorldSim") then
	-- print("创建世界时")
	-- GLOBAL.SEED = 233

	function GLOBAL.getval(fn, path)
	    local val = fn
	    for entry in path:gmatch("[^%.]+") do -- 正则: 取一个或多个任意字符的补集
	        local i=1
	        while true do
	            local name, value = GLOBAL.debug.getupvalue(val, i) -- 此函数返回函数 val 的第 i 个上值的名字和值。 如果该函数没有那个上值，返回 nil 。 值为任意类型
	            print("调用的参数", name, value, type(value))
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

	local map_max = GetModConfigData("minmap") or 0
	GLOBAL.start_of = GetModConfigData("start") or "default_start"

	-- 加载岛屿数据
	require("map/worldgen_of")
	--全局表中是否存在WorldSim表
	if map_max > 0 then
	    local idx = getmetatable(WorldSim).__index
	 --    print("查看WorldSim的lua层函数")
		-- for k,v in pairs(idx) do
	 --    	print("函数",k)
	 --    end
	    local SetWorldSize_ = idx.SetWorldSize
	    local ConvertToTileMap_ = idx.ConvertToTileMap
	    idx.SetWorldSize = function(self,a,b) SetWorldSize_(self,map_max,map_max) end --没有啥用的
	    idx.ConvertToTileMap = function(self,x) ConvertToTileMap_(self,map_max) end --设置地图大小,单位一地皮
	end

	-- -- 添加 自定义标签
	-- require("map/storygen")
	-- local old_ctor = Story._ctor
	-- Story._ctor = function(self, ...)
	-- 	old_ctor(self, ...)
	-- 	self.map_tags.Tag["zdy_Tag_of"] = function(tagdata)
	-- 		if tagdata["zdy_Tag_of"] == false then
	-- 			return
	-- 		end
	-- 		tagdata["zdy_Tag_of"] = true

	-- 		-- return "ITEM", "物品代码名"
	-- 		return "TAG", "自定义标签"
	-- 		-- return "STATIC", "静态布局名称"
	-- 		-- return "GLOBALTAG", "全局标签 官方是用在迷宫生成方面了"
	-- 	end
	-- end
end

--------------------------------------------------------------
-- 在前端和创建世界时，都要执行的内容。 前端是预设选择, 生成世界预设内容(原因是，新环境，重新加载了预设，没有的要添加进去)。
-- 定义海洋房间
AddRoom("OceanSwell_cs", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_SWELL,
					-- tags = {"zdy_tag"},
					contents =  {
						distributepercent = 0.001,
						distributeprefabs =
						{
							oceanfish_shoalspawner = 0.01, --鱼场
							boat_otterden = 0.01 --水獭掠夺者 平台
                        },
						countstaticlayouts =
						{
					        ["AtriumEnd"] = {count = 1},
						},
					}})


--自定义起始位置
AddStartLocation("cs_sl", {
    name = "测试起始地",
    location = "forest",
    --起始布局
    start_setpeice = "DefaultStart1",
    --布局在的房间名称
    start_node = "Blank",
})

AddTask("Isolated Island", {
		locks={},
		keys_given={},
		room_choices={
			["Blank"] = 1, -- 添加空白房间
		},
		room_bg=GROUND.GRASS,
		background_room="Blank", --也为空白房间
		colour={r=0,g=1,b=0,a=1}
	})
local task_set = {
    name = "海岛",
    location = "forest",
    tasks = {
		"Isolated Island",
    },
    --保留原因是用于覆盖
    numoptionaltasks = 0,
    optionaltasks = {},
    valid_start_tasks = nil,
    required_prefabs = {},
    set_pieces = {},
    -- 海洋布局
 	ocean_prefill_setpieces = {},
    -- 海洋房间
	ocean_population = {
		"OceanSwell_cs",
	},
}
local ocean_prefill_setpieces = {
	["BrinePool1"] = {count = 1},	--盐堆
	["Waterlogged1"] = {count = 1}, --水中木
	["CrabKing"] = {count =1},		--帝王蟹
	["HermitcrabIsland"] = {count =1},--蟹岛
	["MonkeyIsland"] = {count =1},	--猴岛
	["OceanMoon"] = {count =1},		--小月亮岛
	["OceanMoon2"] = {count =1},	--小月亮岛2
	["OceanMoonbase"] = {count =1},	--月台岛
	["OceanBoss"] = {count =1},		--boss岛
	["Confusion"] = {count =1},		--混乱岛
	["NightmareHome"] = {count =1}, --噩梦家园岛
	["TumbleweedLand"] = {count =1},--风滚草岛
	["Turtle"] = {count =1},		--档案馆岛
	["JunkYard"] = {count =1},		--垃圾场岛
	["Migong"] = {count =1},		--迷宫岛
	["Joker_of"] = {count =1},		--小丑岛
}
--生物群落设置
AddTaskSet("cs_sz2", task_set)
local overrides = {
    start_location = "cs_sl",
    season_start = "default",
    world_size = "default",
    task_set = "cs_sz2",
    layout_mode = "LinkNodesByKeys",
    wormhole_prefab = "wormhole",
    roads = "never", --道路
    -- birds = "never", --鸟
	keep_disconnected_tiles = true,
	no_wormholes_to_disconnected_tiles = true,
	no_joining_islands = true,
	has_ocean = true, --有海洋
	is_oceanfishing = true, --标记用的, 专服要么拷贝客户端的leveldataoverride.lua 要么自己在它中的overrides添加这一条
}

--预设
AddLevel("oceanfishing", {
    id = "CS_ZDY_YS1",
    name = "默认预设",
    desc = "默认【海岛】，默认修改出生点",
    location = "forest",
    version = 4,
    overrides=overrides,
    background_node_range = {0,1},
})

-- 添加风格
local Levels = require("map/levels")
if Levels.GetPlaystyleDef("oceanfishing") == nil then
	AddPlaystyleDef({
	    id = "oceanfishing",
	    default_preset = "SURVIVAL_TOGETHER",
	    location = "forest",
	    name = "海钓风格",
	    desc = "选择海钓模式",
	    image = {atlas = "images/serverplaystyles.xml", icon = "survival.tex"},
	    smallimage = {atlas = "images/serverplaystyles.xml", icon = "survival_small.tex"},
	    is_default = false,
	    priority = 99,
	    overrides = {
	        is_oceanfishing = true,
	    },
	})
end

-- 省一下进行服务器世界设置
AddLevelPreInitAny(function(self)
	-- print("执行了",self.location,self.id)
	if self.location == "forest" then --加载世界设置时
		if self.id ~= "CS_ZDY_YS1" then
			print("世界设置不一样")
			self:SetID("CS_ZDY_YS1")
			self:SetBaseID("CS_ZDY_YS1")

			for key, vel in pairs(overrides) do
				self.overrides[key] = vel
			end
			for k, v in pairs(task_set) do
				self[k] = v
			end
		end
		-- 做兼容其他 岛屿内容 都是对 self.ocean_prefill_setpieces 进行修改的话 应该是可以生成的
		if self.ocean_prefill_setpieces then
			for k,v in pairs(ocean_prefill_setpieces) do
				self.ocean_prefill_setpieces[k] = v
			end
		end

		--执行扩展mod内容
		for _,mod in pairs(OPTIONS or {}) do
			print("【海钓随机物品】添加世界设置扩展mod:"..(mod.name or "？？？"))

			for key, vel in pairs(mod.overrides or {}) do
				self.overrides[key] = vel
			end		
			for k,v in pairs(mod.task_set or {}) do
				if type(v)=="table" and type(self[k])=="table" and not mod.iscover then
					for i,j in pairs(v) do
						if type(i) == "string" then
							self[k][i] = j
						else
							table.insert(self[k], j)
						end
					end
				else
					self[k] = v
				end
			end
		end
	end
end)

--------------------------------------------------------------
-- 客户端 前端ui
-- 向全局表中设置MODENV属性(值为表)设置为本文件的env 这里是抄的 
-- _G.rawset(_G, "MODENV", env) --有啥意义吗？

local IsTheFrontEnd = rawget(_G, "TheFrontEnd")
if IsTheFrontEnd == nil then return end 
-- 仅前端执行的内容

local Profile = require("playerprofile") --设置
local ModsTab = require("widgets/redux/modstab")
local WorldSettingsTab = require("widgets/redux/worldsettings/worldsettingstab")
local _OnConfirmEnable = ModsTab.OnConfirmEnable
local _Cancel = ModsTab.Cancel
local _Refresh = WorldSettingsTab.Refresh

local function Reset(modname)
	local screen = TheFrontEnd:GetActiveScreen()
	if screen and screen.server_settings_tab then
		local fancy_name = modname and KnownModIndex:GetModFancyName(modname) or nil		
		--如果有人禁用了我们的mod或卸载了所有mod（无）。
		if modname == nil or fancy_name == modinfo.name then
			-- 更改回默认的模式 即生存
			screen.server_settings_tab.game_mode.spinner:Enable()
			screen.server_settings_tab.game_mode.spinner:SetOptions(GetGameModesSpinnerData(ModManager:GetEnabledServerModNames()))
			screen.server_settings_tab.game_mode.spinner:SetSelectedIndex(1)
			screen.server_settings_tab.game_mode.spinner:Changed()

	        for i, v in pairs(screen.world_tabs[1].worldsettings_widgets) do
            	v:LoadPreset() --重新载入预设
	        end
			-- 重新打开洞穴选项
			screen.world_tabs[2].isnewshard = true
		end
	end	
end

--卸下mod时会执行
ModsTab.OnConfirmEnable = function(self, restart, modname)
	Reset(modname)
	_OnConfirmEnable(self, restart, modname)
end	

-- 返回退出创建世界时执行
ModsTab.Cancel = function(self)
	Reset()
	_Cancel(self)
end

-- 刷新时，有问题，会解锁存档的世界生存选项。我也没办法，暂时不能找到客户端读取有这个mod的存档时，洞穴依旧可以添加，而导致崩
WorldSettingsTab.Refresh = function(self)
	-- 不让客户端显示添加洞穴
	-- self.isnewshard = self.location_index == 1 and true or false
	if self.location_index == 2 then --是洞穴
		self.isnewshard = false
	end
	return _Refresh(self)
end

--设置mod关闭时执行
local old_FrontendUnloadMod = ModManager.FrontendUnloadMod   
ModManager.FrontendUnloadMod = function(self, modname)
	old_FrontendUnloadMod(self, modname)
	local CurrentScreen = TheFrontEnd:GetActiveScreen()    
	if CurrentScreen and CurrentScreen.server_settings_tab then
		local fancy_name = modname and KnownModIndex:GetModFancyName(modname) or nil
		--如果有人禁用了我们的mod或卸载了所有mod（无）。
		if modname == nil or fancy_name == modinfo.name then

			-- 更改回默认的模式 即生存
			-- CurrentScreen.server_settings_tab.game_mode.spinner:Enable()
			-- CurrentScreen.server_settings_tab.game_mode.spinner:SetOptions(GetGameModesSpinnerData(ModManager:GetEnabledServerModNames()))
			-- CurrentScreen.server_settings_tab.game_mode.spinner:SetSelectedIndex(1)
			-- CurrentScreen.server_settings_tab.game_mode.spinner:Changed()

	        for i, v in pairs(CurrentScreen.world_tabs[1].worldsettings_widgets) do
            	v:LoadPreset() --重新载入预设
	        end
			-- 重新打开洞穴选项
			CurrentScreen.world_tabs[2].isnewshard = true	
			
			--恢复原来的
			ModsTab.OnConfirmEnable = _OnConfirmEnable
			ModsTab.Cancel = _Cancel
			ModManager.FrontendUnloadMod = old_FrontendUnloadMod 
			WorldSettingsTab.Refresh = _Refresh
		end
	end
end


local CurrentScreen = TheFrontEnd:GetActiveScreen() --获取活动屏幕 ServerSlotScreen存档界面 ServerCreationScreen具体档/新档
--server_settings_tab 服务器设置选项卡 game_mode游戏模式  enabled启用
if CurrentScreen and CurrentScreen.server_settings_tab and CurrentScreen.server_settings_tab.game_mode.spinner.enabled then
	-- print("界面名称 ServerCreationScreen",CurrentScreen.name)
                                                        --从mod中添加模式，并设置ui设置选项数据
	CurrentScreen.server_settings_tab.game_mode.spinner:SetOptions(GetGameModesSpinnerData(ModManager:GetEnabledServerModNames()))
                                                        --选定，有就会选定
	CurrentScreen.server_settings_tab.game_mode.spinner:SetSelected("OceanFishing")
                                                        --改变
    CurrentScreen.server_settings_tab.game_mode.spinner:Changed()
    													--锁定值	
    CurrentScreen.server_settings_tab.game_mode.spinner:Disable()
    -- 主是显示
    --world_tabs第几个世界的设置(最多支持2个) worldsettings_widgets世界设置(1世界选项、2世界生成) settingslist设置列表 scroll_list滚动列表 widgets_to_update网格表 opt_spinner选择器
	local scroll_list = CurrentScreen.world_tabs[1].worldsettings_widgets[2].settingslist.scroll_list
	-- 设置生物群落
	scroll_list.widgets_to_update[10].opt_spinner.spinner:SetSelected("cs_sz2")
	scroll_list.widgets_to_update[10].opt_spinner.spinner:Changed()
    													--锁定值	
    scroll_list.widgets_to_update[10].opt_spinner.spinner:Disable()		
	-- 设置出生点
	scroll_list.widgets_to_update[11].opt_spinner.spinner:SetSelected("cs_sl")
	scroll_list.widgets_to_update[11].opt_spinner.spinner:Changed()
    													--锁定值	
    scroll_list.widgets_to_update[11].opt_spinner.spinner:Disable()

    -- 重新加载一次预设
    for i, v in pairs(CurrentScreen.world_tabs[1].worldsettings_widgets) do
    	v:LoadPreset() -- 重新载入预设
    end

    --洞穴设置
    CurrentScreen.world_tabs[2]:RemoveMultiLevel()--删除预设面板
    CurrentScreen.world_tabs[2].isnewshard = false --关闭显示洞穴设置
    CurrentScreen.world_tabs[2].autoaddcaves.checked = false --关闭 自动添加洞穴的默认按钮 希望有用
    -- CurrentScreen.world_tabs[2].autoaddcaves:Refresh() --标签按钮的刷新，显然没有必要
    Profile:SetAutoCavesEnabled(false) --执行的指令 不需要洞穴。
    CurrentScreen.world_tabs[2]:Refresh()--刷新
end

-- 添加自定义选项的名称. 虽然原版有 仅洞穴显示 改成双世界都显示还是比较麻烦，不如添加。
-- STRINGS.UI.CUSTOMIZATIONSCREEN.RIFTS_ENABLED_CAVE2 = "荒野裂隙【暗影】开启"

-- local WorldSettings_Overrides = require("worldsettings_overrides")
-- WorldSettings_Overrides.Post["rifts_enabled_cave2"] = function(difficulty) TheWorld:PushEvent("rifts_settingsenabled_cave", difficulty) end

-- local riftsenabled_descriptions = {
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
--     { text = STRINGS.UI.SANDBOXMENU.ALWAYS, data = "always" },
-- }
-- local xx2 = { value = "default", image = "shadowrift_portal.tex", desc = riftsenabled_descriptions, world={"forest"}, order = 0 }

-- AddCustomizeItem(LEVELCATEGORY.SETTINGS, "misc", "rifts_enabled_cave2", xx2)

