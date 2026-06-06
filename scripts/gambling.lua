local loots = {
    {chance = 0.02, item = {"slow_farmplot","fast_farmplot"}},--旧版农场
    {chance = 0.02, item = "mushroom_farm"},--蘑菇农场
    {chance = 0.08, item = "cookpot"},--烹饪锅
    {chance = 0.05, item = "icebox"},--冰箱
    {chance = 0.05, item = "treasurechest"},--木箱
    {chance = 0.02, item = "saltbox"},--盐盒
    {chance = 0.02, item = "firesuppressor"},--雪球发射器
    {chance = 0.02, item = "lightning_rod"},--避雷针
    {chance = 0.02, item = "birdcage"},--鸟笼
    {chance = 0.01, item = "dragonflyfurnace"},--龙鳞火炉
    {chance = 0.02, item = "sisturn"},--姐妹骨灰盒
    {chance = 0.02, item = "mighty_gym"},--强大的健身房
    {chance = 0.02, item = "sculptingtable"},--陶轮
    {chance = 0.02, item = "wardrobe"},--衣柜
    {chance = 0.02, item = "resurrectionstatue"},--肉块雕像
    {chance = 0.02, item = "beebox"},--蜂箱
    {chance = 0.02, item = {"meatrack","meatrack_hermit"}},--晾肉架
    {chance = 0.02, item = {"siestahut","portabletent","tent"}},--帐篷等
    {chance = 0.04, item = {"firepit","coldfirepit"}},--火坑
    {chance = 0.02, item = {"mushroom_light","mushroom_light2"}},--蘑菇灯
}

local playerdata = require("gambling_loot")

for player,data in pairs(playerdata) do
	for k,v in ipairs(data) do
		v.announce = false
		table.insert(loots, v)
	end
end

loots.default = {announce = true, build = build} -- 其他选项设置, 默认设置

-- 为赌狗模式添加
TUNING.OCEANFISHINGROD_R = TUNING.OCEANFISHINGROD_R or {}
TUNING.OCEANFISHINGROD_R.gambling_dog = loots