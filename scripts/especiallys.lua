local function tofullmoon(inst, player)
	TheWorld.net.of_moon:set("full")
end
local function tonewmoon(inst, player)
	TheWorld.net.of_moon:set("new")
end

local function shadow(inst, player)
    if not inspectProtect(player) then return end
	for k,v in pairs({"shadow_rook","shadow_bishop","shadow_knight"}) do
		local item = SpawnPrefab(v)
		item.Transform:SetPosition(player.Transform:GetWorldPosition())
		item.components.combat:SuggestTarget(player)
	end
end

local function pigman(inst, player)
	inst.components.werebeast:TriggerDelta(4) --变疯猪
end

local function shadowcreature(inst, player) --月黑的暗影生物 使其到时间消失
    inst:DoTaskInTime(120, function(inst) inst:Remove() end)
end

local function become_mushtree(inst, player) --变蘑菇树 类似单机的月圆事件
	TheWorld:PushEvent("become_mushtree")
end

local function gemstones(inst, player)
    SpawnDebrisLoots(player, 0.1, {
        {chance = 0.2, item = "redgem"},--红宝石
        {chance = 0.2, item = "bluegem"},--蓝宝石
        {chance = 0.2, item = "purplegem"},--紫宝石
        {chance = 0.1, item = "orangegem"},--橙宝石
        {chance = 0.1, item = "yellowgem"},--黄宝石
        {chance = 0.03, item = "greengem"},--绿宝石
        {chance = 0.01, item = "opalpreciousgem"},--彩虹宝石
    }, math.random(20,35), 28) --7格地皮范围内
    player:PushEvent("accident", "debrisitems")
end

local function stalker_effect(inst, player) --是森林守护者身边生成的几种洞穴植物
    SpawnGrowTheGround(player, 0.75, {
        {chance = 0.5, item = "stalker_bulb"},
        {chance = 0.5, item = "stalker_bulb_double"},
        {chance = 1, item = "stalker_berry"},
        {chance = 8, item = "stalker_fern"},
    }, math.random(10,30), 1)
    player:PushEvent("accident", "abigail")
end

local especiallys = {}
-- 月圆
especiallys.fullmoon = {
    {chance = 0.05, item = "pigman", sleeper = true, eventF = pigman},--猪人疯猪
    {chance = 0.1, item = "ghost"},--鬼魂
    {chance = 0.001, item = "moonbase", announce = true, build = build},--月亮石
    {chance = 0.015, item = "statueglommer", announce = true, build = build},--格罗姆雕像
    {chance = 0.2, item = "glommerfuel"},--格罗姆黏液
	{chance = 0.01, item = "yellowstaff", announce = true},--唤星者法杖
	{chance = 0.1, item = "krampus", sleeper = true},--小偷
    {chance = 0.02, item = "staffcoldlight", build = build},--极光
    {chance = 0.01, item = "mound", build = build},--坟墓
	
	-- {chance = 0.009, item = "fishingsurprised", name = "蘑菇疯狂生长", eventF = become_mushtree},
	{chance = 0.01, item = "fishingsurprised", name = "宝石雨", eventF = gemstones}, 
	-- 变月黑
	{chance = 0.005, item = "fishingsurprised", name = "变月黑", eventF = tonewmoon},
}
-- 新月
especiallys.newmoon = {
    {chance = 0.1, item = "crawlinghorror", eventF = shadowcreature},--暗影爬行怪
    {chance = 0.05, item = "terrorbeak", eventF = shadowcreature},--尖嘴暗影怪
	{chance = 0.2, item = "nightmarefuel"},-- 噩梦燃料
    {chance = 0.01, item = "stafflight", build = build},--矮星
    {chance = 0.03, item = "shadowprotector", eventF = shadowcreature},--暗夜兵
    {chance = 0.03, item = "lightbulb"},--荧光果

	{chance = 0.01, item = "fishingsurprised", name = "暗影三兄贵", eventA = shadow},-- 暗影三基佬
	{chance = 0.01, item = "fishingsurprised", name = "步步生花", eventF = stalker_effect}, 
	{chance = 0.005, item = "fishingsurprised", name = "宝石雨", eventF = gemstones}, 
	-- 变月圆
	{chance = 0.003, item = "fishingsurprised", name = "变月圆", eventF = tofullmoon}, 
}


return especiallys