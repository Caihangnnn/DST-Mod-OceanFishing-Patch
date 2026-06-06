return {
	rockcircle = {
		"rock_flintless",
		"stalagmite_tall",
		"stalagmite",
		"rock_flintless",
		"rock2",
		"moonglass_rock",
		"rock_moon",
		"penguin_ice",
	},
	monstercircle = {
		"spider", 
		"squid",
		"hound", 
		"firehound", 
		"icehound", 
		"tallbird", 
		"frog", 
		"merm", 
		"bat", 
		"bee",
		"clayhound",
		"bunnyman",
		"spider_healer",
	},
	chest = {
		treasurechest = {
			"log",
			"cutgrass",
			"twigs",
			"goldnugget",
		},
		pandoraschest = {
            "lightbulb",
            "poop",
            "rocks",
            "ice",
            "nightmarefuel",
            "boneshard",
            "charcoal",
		},
		dragonflychest = {
            "armorwood",
            "meatballs",
            "ratatouille",
            "healingsalve",
            "spear",
            "tentaclespike",
            "gunpowder",
            "batbat",
            "nightsword",
		},
		minotaurchest = {
	        "ruins_bat",
	        "thulecite",
	        "ruinshat",
	        "armorruins",
	        "thulecite_pieces",
	        "thulecite_pieces",
	        "thulecite_pieces",
	        "opalstaff",
		},
		other = {
			"log",
			"cutgrass",
            "armorwood",
            "ratatouille",
            "healingsalve",
            "spear",
            "tentaclespike",	
            "heatrock",	
		},
	},
	getplayer = {
		"beefalohat",
		"amulet",
		"armorwood",
		"footballhat",
		"torch",
		"axe",
		"pickaxe",
		"lightbulb",
		"meat",
		"cave_banana",
		"rocks",
		"boards",
		"seeds",
		"goldnugget",
		"shovel",
		"umbrella",
		"heatrock",
		"gunpowder",
	},
	sewing_mannequin = {
		{
			"axe","pickaxe","shovel","farm_hoe","goldenaxe","goldenpickaxe","goldenshovel","golden_farm_hoe",
			"moonglassaxe","torch","golden_farm_hoe","pitchfork","bugnet","umbrella","grass_umbrella",
			"multitool_axe_pickaxe","hambat","nightstick","tentaclespike","glasscutter","malbatross_beak",
			"whip","boomerang","blowdart_sleep","blowdart_fire","blowdart_pipe","blowdart_yellow",
			"waterplant_bomb","shieldofterror","spear_wathgrithr","nightsword","batbat",
		},
		{
			"armorgrass","raincoat","sweatervest","trunkvest_summer","reflectivevest","hawaiianshirt","armorwood",
			"armormarble","armorslurper","amulet","trunkvest_winter","armorsnurtleshell","armor_bramble",
		},
		{
			"red_mushroomhat","green_mushroomhat","blue_mushroomhat","flowerhat","strawhat","earmuffshat",
			"beefalohat","winterhat","icehat","beehat","minerhat","molehat","footballhat","wathgrithrhat",
			"cookiecutterhat","goggleshat","deserthat","slurtlehat","rainhat","tophat","featherhat",
		}
	},
	-- chance 不仅是生成概率 还是不会破碎概率 1为百分百不会破碎
	debrisitems = {
		{chance = 0.3, item = "ice"},--冰
	    {chance = 0.25, item = "nitre"},--硝石
	    {chance = 0.4, item = "rocks"},--石头
    	{chance = 0.3, item = "flint"},--燧石
    	{chance = 0.2, item = "marble"},--大理石
    	{chance = 0.2, item = "goldnugget"},--黄金
    	{chance = 0.1, item = "moonrocknugget"},--月石
    	{chance = 0.1, item = "moonglass"},--月亮碎片
    	{chance = 0.001, item = "opalpreciousgem"},--彩虹宝石
	    {chance = 0.002, item = "armordreadstone"},--绝望石盔甲
	    {chance = 0.009, item = "dreadstonehat"},--绝望石头盔
	    {chance = 0.009, item = "lunarplanthat"}, --亮茄头盔
	    {chance = 0.002, item = "armor_lunarplant"}, --亮茄盔甲
	    {chance = 0.002, item = "voidclothhat"}, --虚空风帽
	    {chance = 0.002, item = "armor_voidcloth"}, --虚空长袍
    	{chance = 0.001, item = "lunarrift_crystal_big"}, --裂隙晶体 大
	    {chance = 0.1, item = "pigguard"},--猪人守卫
		{chance = 0.02, item = "merm"},--鱼人
	    {chance = 0.05, item = "rocky"},--石虾
	    {chance = 0.12, item = "catcoon"},--猫
	    {chance = 0.25, item = "frog"},--青蛙
	    {chance = 0.3, item = "rabbit"},--兔子
	    {chance = 0.15, item = "mole"},--鼹鼠
	    {chance = 0.15, item = "carrat"},--胡萝卜鼠
	    {chance = 0.01, item = "gunpowder"},--炸药
	},
	weapon = {
		"torch", --火把
		"axe","pickaxe","shovel","farm_hoe", --斧头-鹤嘴锄-铲子-园艺锄
		"goldenaxe","goldenpickaxe","goldenshovel","golden_farm_hoe",--黄金斧头-黄金鹤嘴锄-黄金铲子-黄金园艺锄
		"moonglassaxe", --月光玻璃斧头
		"pitchfork", --草叉
		"multitool_axe_pickaxe", --多功能工具

		"hambat",--火腿棍
		"nightstick",--晨星
		"tentaclespike",--狼牙棒
		"glasscutter",--玻璃刀
		"gnarwail_horn",--独角鲸的角
		"malbatross_beak",--邪天翁的喙
		"whip",--三尾猫鞭		
		"shieldofterror",--恐怖盾牌
		"spear_wathgrithr","spear",--战斗长矛
		"nightsword",--暗夜剑
		"batbat",--蝙蝠棒
		"ruins_bat",--远古棒
		"sword_lunarplant", --亮茄剑
		"voidcloth_scythe", --暗影收割者
		-- "blowdart_sleep","blowdart_fire","blowdart_pipe","blowdart_yellow",--吹箭不好
	},
	head = {
		"wathgrithrhat",--战斗头盔
		"eyemaskhat",--眼面具
		"cookiecutterhat",--饼干切割机帽子
		"ruinshat",--远古皇冠
		"dreadstonehat",--绝望石头盔
		"lunarplanthat", --亮茄头盔
		"voidclothhat",--虚空风帽
		"woodcarvedhat", --硬木帽
		"footballhat",--橄榄球头盔
		"wagpunkhat",--W.A.R.B.I.S.头戴齿轮 
		"alterguardianhat",--启迪之冠

		-- "goggleshat","deserthat",--时髦目镜-沙漠目镜
		"minerhat",--矿工帽
		"molehat",--鼹鼠帽
		"icehat",--冰块帽
		-- "beehat",--养蜂帽
		-- "flowerhat",--花环
		-- "strawhat",--草帽
		-- "watermelonhat",--西瓜帽
		-- "featherhat",--羽毛帽
		-- "bushhat",--灌木帽
		"tophat",--绅士高帽
		"rainhat",--防雨帽
		"earmuffshat",--小兔耳罩
		"beefalohat",--牛角帽
		"winterhat",--冬帽
	},
}