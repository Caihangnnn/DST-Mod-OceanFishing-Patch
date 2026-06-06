local playerdata =  {
    wilson = { --威尔逊
        {chance = 0.15, item = "beardhair"},--胡须
        {chance = 0.15, item = "razor"},--剃刀
    }, 
    wortox = { --沃括克斯 恶魔人
        {chance = 0.25, item = "wortox_soul"},--灵魂
    }, 
    wendy = { --温蒂
        {chance = 0.4, item = "ghostflower"},--哀悼荣耀
    	{chance = 0.1, item = "ghostlyelixir_attack"},--精油
    	{chance = 0.05, item = "ghostlyelixir_speed"},--精油
    	{chance = 0.1, item = "ghostlyelixir_slowregen"},--精油
    	{chance = 0.05, item = "ghostlyelixir_fastregen"},--精油
    	{chance = 0.1, item = "ghostlyelixir_shield"},--精油
    	{chance = 0.05, item = "ghostlyelixir_retaliation"},--精油
    },
    willow = { --薇洛 
        {chance = 0.01, item = "bernie_inactive"},--伯尼
        {chance = 0.5, item = "willow_ember"},--以太余烬
    },
    wickerbottom = { --维克巴顿 老奶奶
		{chance = 0.2, item = "book_birds"},--鸟书
		{chance = 0.2, item = "book_brimstone"},--雷书
		{chance = 0.01, item = "book_gardening"},--应用圆艺
		{chance = 0.1, item = "book_horticulture"},--应用圆艺·简
		{chance = 0.2, item = "book_silviculture"},--造林
		{chance = 0.2, item = "book_sleep"},--睡前故事
		{chance = 0.1, item = "book_tentacles"},--触手
    },
    waxwell = { --麦斯威尔
        {chance = 0.1, item = "nightmarefuel"},--恶魔燃料
    },
    webber = { --韦伯 蜘蛛人
		{chance = 0.3, item = "spider_healer_item"},--治疗黏团
		{chance = 0.2, item = "spider_repellent"},--驱赶盒子
		{chance = 0.1, item = "spider_whistle"},--韦伯口哨
		{chance = 0.1, item = "spiderden_bedazzler"},--蜘蛛巢专饰套装
		{chance = 0.2, item = {"mutator_dropper","mutator_healer","mutator_hider","mutator_moon","mutator_spitter","mutator_warrior","mutator_water"}},--涂鸦
    },
    wes = { --韦斯 气球小子
    	{chance = 0.1, item = "balloon"},--气球
    	{chance = 0.2, item = "balloonhat"},--气球帽
    	{chance = 0.1, item = "balloonparty"},--派对气球
    	{chance = 0.1, item = "balloonspeed"},--迅捷气球
    	{chance = 0.1, item = "balloonvest"},--充气背心
    },
    winona = { --薇诺娜 女工
    	{chance = 0.22, item = "sewing_tape"},--可靠的胶布
    },
    woodie = { --伍迪
        {chance = 0.1, item = "monstermeat"},--怪物肉
    },
    wormwood = { --树人
    	{chance = 0.2, item = "compostwrap"},--肥料包
    },
    wurt = { --鱼妹
        {chance = 0.2, item = "mosquitobomb"},--蚊子炸弹
    },
    warly = { --沃利 厨子
        {chance = 0.1, item = {"portablecookpot_item","portableblender_item","portablespicer_item"}},--3便携厨具
        {chance = 0.2, item = {"spice_sugar","spice_salt","spice_chili","spice_garlic"}},--香料
    },
    wathgrithr = { --维格弗德 女武神
    	{chance = 0.1, item = "wathgrithrhat"},--战斗头盔
    	{chance = 0.2, item = "spear_wathgrithr"},--战斗长矛
        {chance = 0.05, item = "battlesong_durability"}, --武器化的颤音
        {chance = 0.05, item = "battlesong_healthgain"}, --心碎歌谣
        {chance = 0.05, item = "battlesong_sanitygain"}, --醍醐灌顶华彩
        {chance = 0.05, item = "battlesong_fireresistance"}, --防火假声
        {chance = 0.05, item = "battlesong_shadowaligned"}, --黑暗悲歌
        {chance = 0.05, item = "battlesong_lunaraligned"}, --启迪摇篮曲
        {chance = 0.05, item = "battlesong_instant_revive"}, --战士重奏
        {chance = 0.05, item = "battlesong_sanityaura"}, --英勇美声颂
        {chance = 0.05, item = "battlesong_instant_taunt"}, --粗鲁插曲
        {chance = 0.05, item = "battlesong_instant_panic"}, --惊心独白  
    	-- {chance = 0.1, item = {"battlesong_durability","battlesong_healthgain","battlesong_sanitygain","battlesong_sanityaura","battlesong_fireresistance","battlesong_instant_taunt","battlesong_instant_panic"}},--歌谣
    },
    wolfgang = { --大力士
    	{chance = 0.3, item = "dumbbell"},--哑铃
    	{chance = 0.1, item = "dumbbell_gem"},--黄金哑铃
        {chance = 0.05, item = "dumbbell_golden"},--宝石哑铃
        {chance = 0.05, item = "dumbbell_heat"},--热铃
        {chance = 0.05, item = "dumbbell_redgem"},--火铃
    	{chance = 0.05, item = "dumbbell_bluegem"},--冰铃
    },
    wx78 = { --机器人
        {chance = 0.05, item = "wx78module_bee"}, --豆增压电路
        {chance = 0.05, item = "wx78module_cold"}, --制冷电路
        {chance = 0.05, item = "wx78module_heat"}, --热能电路
        {chance = 0.05, item = "wx78module_light"}, --照明电路
        {chance = 0.05, item = "wx78module_maxhealth"}, --强化电路
        {chance = 0.05, item = "wx78module_maxhealth2"}, --超级强化电路
        {chance = 0.05, item = "wx78module_maxhunger"}, --超级胃增益电路
        {chance = 0.05, item = "wx78module_maxsanity"}, --超级处理器电路
        {chance = 0.05, item = "wx78module_movespeed"}, --加速电路
        {chance = 0.05, item = "wx78module_movespeed2"}, --超级加速电路
        {chance = 0.05, item = "wx78module_music"}, --合唱盒电路
        {chance = 0.05, item = "wx78module_nightvision"}, --光电电路
        {chance = 0.05, item = "wx78module_taser"}, --电气化电路        
    },
    walter = { --沃尔特
    	-- {chance = 0.5, item = {"slingshotammo_rock","slingshotammo_gold","slingshotammo_marble","slingshotammo_poop","slingshotammo_freeze","slingshotammo_slow","slingshotammo_thulecite"}},--子弹
        {chance = 0.05, item = "slingshotammo_rock"},  --石头弹药
        {chance = 0.05, item = "slingshotammo_gold"}, --黄金弹药
        {chance = 0.05, item = "slingshotammo_marble"}, --大理石弹药
        {chance = 0.05, item = "slingshotammo_poop"}, --便便弹药
        {chance = 0.05, item = "slingshotammo_freeze"}, --冰冻弹药
        {chance = 0.05, item = "slingshotammo_slow"}, --减速弹药    
        {chance = 0.05, item = "slingshotammo_thulecite"}, --诅咒弹药   
        {chance = 0.05, item = "slingshotammo_thulecite"}, --蜂刺弹药   
        {chance = 0.05, item = "slingshotammo_moonglass"}, --月亮弹药   
        {chance = 0.05, item = "slingshotammo_honey"}, --蜂蜜弹药
        {chance = 0.05, item = "slingshotammo_scrapfeather"}, --电击弹药
        {chance = 0.05, item = "slingshotammo_gunpowder"}, --轰轰弹    
        {chance = 0.05, item = "slingshotammo_dreadstone"}, --绝望小石  
        {chance = 0.05, item = "slingshotammo_horrorfuel"}, --纯粹恐惧弹药    
        {chance = 0.05, item = "slingshotammo_lunarplanthusk"}, --亮茄外壳弹药
        {chance = 0.05, item = "slingshotammo_purebrilliance"}, --纯粹辉煌弹药
    },
    wanda = { --旺达
    	{chance = 0.03, item = "pocketwatch_heal"},--不老表
    	{chance = 0.01, item = "pocketwatch_portal"},--裂缝表
    	{chance = 0.03, item = "pocketwatch_recall"},--溯源表
    	{chance = 0.04, item = "pocketwatch_revive"},--第二次机会表
    	{chance = 0.05, item = "pocketwatch_warp"},--倒走表
    	{chance = 0.04, item = "pocketwatch_weapon"},--警告表
    },
}


return playerdata