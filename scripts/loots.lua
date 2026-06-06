


-- 材料表 materials        基础原材料
-- 物品表 goods            道具、工具、武器
-- 穿戴表 equipments       服装、穿戴物品
-- 种植表 plant            种子、可移植植物
-- 食材表 ingredients      可食用非成品食物
-- 料理表 foods            成品食物
-- 生物表 organisms        大部分生物
-- 巨兽表 giants           巨大怪兽
-- 建筑表 builds           建筑、基建物品、不可移植
-- 事件表 events
-- 科技表 technology       草图、渔具广告、食谱卡

local loots = {}
local events = TUNING.OCEANFISHINGROD_E.oceanfishingrod
local p_events = TUNING.OCEANFISHINGROD_E.prefab_events

local huge_fruits_loot = {}
for k, v in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do
    if v.product_oversized ~= nil then
        table.insert(huge_fruits_loot, v.prefab)
    end
end

-- 食材表: 可食用非成品食物
loots.ingredients = {
    {chance = 0.1, item = "petals"},--花瓣
    {chance = 0.07, item = "foliage"},--蕨叶
    {chance = 0.1, item = "ice"},--冰
    {chance = 0.4, item = {"berries","berries_juicy"}},--浆果
    {chance = 0.1, item = {"red_cap","green_cap","blue_cap","moon_cap"}},--蘑菇
    {chance = 0.05, item = {"trunk_summer","trunk_winter"}},--象鼻
    {chance = 0.1, item = {"asparagus","carrot","corn","dragonfruit","durian","eggplant","garlic","onion","pepper","pomegranate","potato","pumpkin","tomato","watermelon"}},--蔬菜
    {chance = 0.05, item = "wormlight"},--发光浆果
    {chance = 0.1, item = "wormlight_lesser"},--小发光浆果
    {chance = 0.01, item = "royal_jelly"},--蜂王浆
    {chance = 0.2, item = "cave_banana"},--洞穴香蕉
    {chance = 0.1, item = "cactus_meat"},--仙人掌肉
    {chance = 0.1, item = "cactus_flower"},--仙人掌花
    {chance = 0.1, item = {"smallmeat", "smallmeat_dried"}},--小肉 小肉干
    {chance = 0.2, item = {"meat", "meat_dried"}},--大肉 肉干
    {chance = 0.4, item = "barnacle"},--藤壶
    {chance = 0.1, item = "drumstick"},--鸡腿
    {chance = 0.3, item = {"monstermeat", "monstermeat_dried"}},--怪物肉 怪物肉干
    -- {chance = 0.3, item = "humanmeat_dried"},--长猪肉干
    -- {chance = 0.3, item = "humanmeat"},--长猪肉
    {chance = 0.1, item = "batnose"},--裸露鼻孔
    {chance = 0.1, item = "plantmeat"},--食人花肉
    {chance = 0.2, item = "bird_egg"},--鸡蛋
    {chance = 0.1, item = "tallbirdegg"},--高鸟蛋
    {chance = 0.2, item = {"pondfish","fish"}},--死活淡水鱼
    {chance = 0.2, item = {"pondeel","eel"}},--死活鳗鱼
    {chance = 0.1, item = "froglegs"},--蛙腿
    {chance = 0.3, item = "batwing"},--蝙蝠翅膀
    {chance = 0.1, item = "honey"},--蜂蜜
    {chance = 0.02, item = "butter"},--黄油
    {chance = 0.15, item = "milkywhites"},--乳白物
    {chance = 0.5, item = "goatmilk"},--羊奶
    {chance = 0.04, item = "fig"},--无花果
    {chance = 0.1, item = {"oceanfish_small_1_inv","oceanfish_small_2_inv","oceanfish_small_3_inv","oceanfish_small_4_inv","oceanfish_small_5_inv",
        "oceanfish_medium_1_inv","oceanfish_medium_2_inv","oceanfish_medium_3_inv","oceanfish_medium_4_inv","oceanfish_medium_5_inv"}},--海鱼
    {chance = 0.001, item = {"oceanfish_small_6_inv","oceanfish_small_7_inv","oceanfish_small_8_inv","oceanfish_medium_8_inv"}, announce = true}, --四季鱼
    {chance = 0.1, item = {
        "acorn_cooked", --烤桦栗果
        "asparagus_cooked", --烤芦笋
        "barnacle_cooked", --熟藤壶
        "batnose_cooked", --炭烤鼻孔
        "batwing_cooked", --熟蝙蝠翅膀
        "berries_cooked", --烤浆果
        "berries_juicy_cooked", --烤多汁浆果
        "bird_egg_cooked", --熟鸟蛋
        "blue_cap_cooked", --熟蓝蘑菇
        "cactus_meat_cooked", --熟仙人掌肉
        "carrot_cooked", --烤胡萝卜
        "cave_banana_cooked", --熟香蕉
        "corn_cooked", --爆米花
        "dragonfruit_cooked", --熟火龙果
        "drumstick_cooked", --炸鸟腿
        "durian_cooked", --超臭榴莲
        "eel_cooked", --熟鳗鱼
        "eggplant_cooked", --烤茄子
        "fig_cooked", --做熟的无花果
        "fishmeat_cooked", --鱼排
        "fishmeat_small_cooked", --熟小鱼块
        "fish_cooked", --熟鱼
        "froglegs_cooked", --熟蛙腿
        "garlic_cooked", --烤大蒜
        "green_cap_cooked", --熟绿蘑菇
        "kelp_cooked", --熟海带叶
        "kelp_dried", --海带干
        "moon_cap_cooked", --熟月亮蘑菇
        "onion_cooked", --烤洋葱
        "pepper_cooked", --烤辣椒
        "plantmeat_cooked", --熟叶肉
        "pomegranate_cooked", --切片熟石榴
        "potato_cooked", --烤土豆
        "pumpkin_cooked", --烤南瓜
        "red_cap_cooked", --熟红蘑菇
        "rock_avocado_fruit_ripe_cooked", --熟石果
        "seeds_cooked", --烤种子
        "tallbirdegg_cooked", --煎高脚鸟蛋
        "tomato_cooked", --烤番茄
        "trunk_cooked", --象鼻排
        "watermelon_cooked", --烤西瓜
        "wobster_sheller_dead_cooked", --美味的龙虾
        "cookedmeat", --熟肉
        "cookedsmallmeat", --熟小肉
        "cookedmonstermeat", --熟怪物肉
        "ancientfruit_nightvision_cooked", --熟夜莓
    }}, --烤熟的食材
    {chance = 0.01, item = "ancientfruit_nightvision"},--夜莓
    {chance = 0.2, item = "kelp"},--海带叶
    {chance = 0.3, item = {
        "dish_braisedmeatwithfoliages",
        "dish_fleshnapoleon",
        "dish_seedscongee",
        "dish_beancongee",
        "dish_mushedkoi",
        "dish_mushedmilk",
        "dish_mushedeggs",
        "dish_l_mooncake",
        "dish_l_flowerbun",
        "dish_lovingrosecake",
        "dish_medicinalliquor",
        "dish_bananamousse",
        "dish_tomahawksteak",
        "dish_friedfishwithpuree",
        "dish_sosweetjarkfruit",
        "dish_murmurananas",
        "dish_wrappedshrimppaste",
        "dish_farewellcupcake",
        "dish_sugarlesstrickmakercupcakes",
        "dish_merrychristmassalad",
        "dish_shyerryjam",
        "dish_duriantartare",
        "dish_ricedumpling",
        "dish_pomegranatejelly",
        "dish_roastedmarshmallows",
        "dish_fishjoyramen",
        "dish_neworleanswings",
        "dish_frenchsnailsbaked",
        "dish_beggingmeat",
        "dish_orchidcake",
        "dish_twistedrolllily",
        "dish_chilledrosejuice",
    }},--棱镜料理
    {chance = 0.3, item = {
        "bean_l_ice",
        "squamousfruit",
        "monstrain_leaf",
        "albicans_cap",
        "shyerry",
        "mint_l",
        "pineananas",
        "pineananas_cooked",
        "petals_orchid",
        "petals_lily",
        "petals_rose",
    }},--棱镜食材
}
-- 事件表
loots.events = {
    {chance = 0.01, item = "fishingsurprised", name = "阴晴不定", eventF = events.weatherchanged},--阴晴不定
    {chance = 0.01, item = "fishingsurprised", name = "岩石怪圈", eventF = events.rockcircle},--岩石怪圈
    {chance = 0.03, item = "fishingsurprised", name = "营火晚会", eventF = events.campfirecircle},--营火晚会
    {chance = 0.09, item = "fishingsurprised", name = "生物怪圈", eventA = events.monstercircle},--生物怪圈
    {chance = 0.04, item = "fishingsurprised", name = "犬牙陷阱圈", eventF = events.maxwellcircle},--犬牙陷阱圈
    {chance = 0.09, item = "fishingsurprised", name = "天雷陷阱", eventA = events.lightningTarget},--天雷陷阱
    {chance = 0.05, item = "fishingsurprised", name = "天体陷阱", eventF = events.celestialfury},--天体陷阱
    {chance = 0.04, item = "fishingsurprised", name = "火药陷阱", eventF = events.gunpowdercircle},--火药陷阱
    {chance = 0.1, item = "fishingsurprised", name = "啜食", eventF = events.onAddHun},--状态陷阱
    {chance = 0.1, item = "fishingsurprised", name = "降智", eventF = events.onAddSan},--状态陷阱
    {chance = 0.1, item = "fishingsurprised", name = "流血", eventF = events.onAddHp},--状态陷阱
    {chance = 0.012, item = "fishingsurprised", name = "暗影陷阱", eventF = events.shadow_level},--暗影陷阱
    -- {chance = 0.01, item = "fishingsurprised", name= "单向生命链接", eventF = events.healthlink},--单向生命链接
    {chance = 0.09, item = "fishingsurprised", name="柱！柱！柱！", eventF = events.caveinobstacle},--柱！柱！柱！
    {chance = 0.09, item = "fishingsurprised", name="多重孢子云", eventF = events.sporecloud},--多重孢子云 
    -- {chance = 0.09, item = "fishingsurprised", name="清理物品", eventF = events.removeitems},--清理物品
    {chance = 0.11, item = "fishingsurprised", name= "蔷薇陷阱", eventF = events.hedgehounds},--蔷薇陷阱
    {chance = 0.08, item = "fishingsurprised", name= "鬼魂陷阱", eventF = events.ghost_circle},--鬼魂陷阱
    {chance = 0.1, item = "fishingsurprised", name= "昏睡陷阱", eventF = events.lethargy},--昏睡陷阱
    {chance = 0.04, item = "fishingsurprised", name= "理智全无", eventF = events.sanityempty},--理智全无
    {chance = 0.01, item = "fishingsurprised", name= "毒计？鸡", eventF = events.turkey},--毒计？鸡
    {chance = 0.05, item = "fishingsurprised", name= "卸甲归田", eventF = events.dropequip},--卸甲归田
    {chance = 0.04, item = "fishingsurprised", name= "遗失宝藏", eventF = events.stashloot},--遗失宝藏
    {chance = 0.02, item = "fishingsurprised", name= "季节变化", eventF = events.seasonchange},--季节变化
    {chance = 0.03, item = "fishingsurprised", name= "甘·文·崔", eventA = events.shadowthrall},--甘·文·崔
    {chance = 0.07, item = "fishingsurprised", name= "惊涛波浪", eventF = events.spawnwaves},--惊涛波浪
    {chance = 0.09, item = "fishingsurprised", name= "桦树精的愤愤", eventF = events.deciduous},--桦树精的愤愤
    {chance = 0.05, item = "fishingsurprised", name= "强制禁鱼,一分钟", eventF = events.refusefish},--强制禁鱼
    {chance = 0.08, item = "fishingsurprised", name= "兔吃曼草", eventF = events.rabbiteater},--兔吃曼草
    -- {chance = 0.03, item = "fishingsurprised", name= "移形换影", eventA = events.transformation},--移形换影
    {chance = 0.04, item = "fishingsurprised", name= "奇怪的雨", eventF = events.debrisitems},--奇怪的雨
    {chance = 0.01, item = "fishingsurprised", name= "升天", eventF = events.ascension},--升天
    {chance = 0.05, item = "fishingsurprised", name= "大范围冰冻", eventF = events.allfreezable},--大范围冰冻
    {chance = 0.05, item = "fishingsurprised", name= "蚁狮陷阱", eventF = events.sand},--蚁狮陷阱
    {chance = 0.01, item = "fishingsurprised", name= "超多的陷阱", eventF = events.supermany},--超多的陷阱
    {chance = 0.02, item = "fishingsurprised", name= "青蛙雨", eventF = events.frograin},--青蛙雨
    {chance = 0.05, item = "fishingsurprised", name= "相控阵激光", eventF = events.alterguardian_laser},--相控阵激光
    {chance = 0.07, item = "fishingsurprised", name= "奇妙蘑菇林", eventA = events.mushroombomb},--奇妙蘑菇林
    {chance = 0.03, item = "fishingsurprised", name= "蘑菇丛", eventF = events.mushroom},--蘑菇丛
    {chance = 0.04, item = "fishingsurprised", name= "骨牢骨刺", eventF = events.fossilspike},--骨牢骨刺
    {chance = 0.01, item = "fishingsurprised", name= "区域异常，半天！", eventF = events.areaaware_abnormal},--区域异常，半天！
    {chance = 0.075, item = "fishingsurprised", name= "快快变大", eventF = events.super_big},--快快变大
    {chance = 0.09, item = "fishingsurprised", name= "别钓了，快战斗", eventF = events.p_combat},--别钓了，快战斗
    {chance = 0.03, item = "fishingsurprised", name= "触手陷阱", eventF = events.tentacle_kl},--触手陷阱
    {chance = 0.13, item = "fishingsurprised", name= "蝙蝠军团", eventF = events.bat_eye},--蝙蝠军团
    {chance = 0.075, item = "fishingsurprised", name= "快快变小", eventF = events.super_small},--快快变小
    {chance = 0.09, item = "fishingsurprised", name= "杂草禁锢", eventF = events.weed_imprison},--杂草禁锢
    {chance = 0.035, item = "fishingsurprised", name= "一拳小超人", eventF = events.onefistsuperman},--一拳小超人
    {chance = 0.095, item = "fishingsurprised", name= "天使赐福", eventF = events.angel_blessing},--天使赐福
    {chance = 0.035, item = "fishingsurprised", name= "还你飘飘拳", eventF = events.returnonattack},--还你飘飘拳
    {chance = 0.015, item = "fishingsurprised", name= "加点黑血", eventF = events.deltapenalty},--加点黑血
    {chance = 0.025, item = "fishingsurprised", name= "注射强心针", eventF = events.onlifeinjector},--注射强心针
    {chance = 0.045, item = "fishingsurprised", name= "你不要过来", eventF = events.sanityaura},--你不要过来
    {chance = 0.025, item = "fishingsurprised", name= "知识灌入", eventF = events.research},--知识灌入
    {chance = 0.05, item = "fishingsurprised", name= "体温变气温", eventF = events.temperature},--体温变气温
    {chance = 0.075, item = "fishingsurprised", name= "精神控制", eventF = events.mindcontrol},--精神控制
    {chance = 0.009, item = "fishingsurprised", name= "双子魔眼", eventF = events.twinmanager},--双子魔眼
    {chance = 0.01, item = "fishingsurprised", name= "小森林", eventF = events.small_forest},--小森林
    {chance = 0.008, item = "fishingsurprised", name= "器灵", eventF = events.automatic_weapon},--器灵
    {chance = 0.011, item = "fishingsurprised", name= "物品恢复", eventF = events.equip_recovery},--物品恢复
    {chance = 0.005, item = "fishingsurprised", name= "季节小boss", eventF = events.small_boss},--季节小boss
    {chance = 0.045, item = "fishingsurprised", name= "地震波", eventF = events.groundpounder},--地震波
    {chance = 0.055, item = "fishingsurprised", name= "冰川", eventF = events.glacier},--冰川
    {chance = 0.045, item = "fishingsurprised", name= "流星雨", eventF = events.shadowmeteor},--流星雨
    {chance = 0.037, item = "fishingsurprised", name= "冰与火", eventF = events.fire_ice_charge},--冰与火
    {chance = 0.085, item = "fishingsurprised", name= "无眼鹿冰", eventF = events.deer_ice_circle},--无眼鹿冰
    {chance = 0.085, item = "fishingsurprised", name= "无眼鹿火", eventF = events.deer_fire_circle},--无眼鹿火
    {chance = 0.009, item = "fishingsurprised", name= "猎犬来袭", eventF = events.spawnendhounds},--猎犬来袭
    {chance = 0.013, item = "fishingsurprised", name= "黄金雨", eventF = events.goldnuggets},--黄金雨
    {chance = 0.033, item = "fishingsurprised", name= "虚空便便弹", eventF = events.monkeyprojectile},--虚空便便弹
    {chance = 0.07, item = "fishingsurprised", name= "精神恢复", eventF = events.san_restore},--精神恢复
    {chance = 0.06, item = "fishingsurprised", name= "被黏住了", eventF = events.spat_bomb},--被黏住了
    {chance = 0.06, item = "fishingsurprised", name= "前往出生点", eventF = events.pocketwatch},--前往出生点
    {chance = 0.07, item = "fishingsurprised", name= "阿比盖尔", eventF = events.abigail},--阿比盖尔
    {chance = 0.09, item = "fishingsurprised", name= "怪物军团", eventF = events.army},--怪物军团
    {chance = 0.05, item = "fishingsurprised", name= "潮腻加身", eventF = events.moisture},--潮腻加身
    {chance = 0.03, item = "fishingsurprised", name= "巨石阵1", eventF = events.insanityrock},--巨石阵1
    {chance = 0.04, item = "fishingsurprised", name= "巨石阵2", eventF = events.sanityrock},--巨石阵2
    {chance = 0.055, item = "fishingsurprised", name= "疾如风", eventF = events.rapid},--疾如风
    {chance = 0.06, item = "fishingsurprised", name= "复活吧！我的爱人们", eventF = events.resurrection},--复活吧！我的爱人们
    {chance = 0.03, item = "fishingsurprised", name= "吸物大法", eventF = events.xixindafa},--吸物大法
    {chance = 0.04, item = "fishingsurprised", name= "小淘气", eventF = events.makeakrampusforplayer},--小淘气
    {chance = 0.07, item = "fishingsurprised", name= "全体目光向我看齐", eventF = events.quantixianwokanqi},--全体目光向我看齐
    {chance = 0.08, item = "fishingsurprised", name= "黄金雕像", eventF = events.goldenstatue},--黄金雕像
    {chance = 0.03, item = "fishingsurprised", name= "眼球草陷阱", eventF = events.eyeplant},--眼球草陷阱
    {chance = 0.04, item = "fishingsurprised", name= "护盾充能", eventF = events.shield},--护盾充能
    {chance = 0.01, item = "fishingsurprised", name= "我就是二郎神", eventF = events.i_am_els},--我就是二郎神
    {chance = 0.037, item = "fishingsurprised", name= "范围生命恢复", eventF = events.range_life_recovery},--范围生命恢复
    {chance = 0.007, item = "fishingsurprised", name= "月亮风暴", eventF = events.moonstorms},--月亮风暴
    {chance = 0.007, item = "fishingsurprised", name= "森林怒火", eventF = events.leif_anger},--森林怒火
    {chance = 0.003, item = "fishingsurprised", name= "巨兽伙伴", eventF = events.bosscompanion},--巨兽伙伴
    {chance = 0.01, item = "fishingsurprised", name= "黏人炸弹", eventF = events.timebomb},--黏人炸弹
    {chance = 0.035, item = "fishingsurprised", name= "击飞", eventF = events.knockback},--击飞
    {chance = 0.02, item = "fishingsurprised", name= "脚踩西瓜皮", eventF = events.feetslipped},--脚踩西瓜皮
    {chance = 0.028, item = "fishingsurprised", name= "变身术", eventF = events.alterself},--变身术
    {chance = 0.014, item = "fishingsurprised", name= "酸雨天", eventF = events.acidrain},--酸雨天
    {chance = 0.023, item = "fishingsurprised", name= "玻璃雨", eventF = events.lunarhail},--玻璃雨
    {chance = 0.02, item = "fishingsurprised", name= "雾天", eventF = events.fog},--雾天
    {chance = 0.042, item = "fishingsurprised", name= "固若金汤", eventF = events.buff_playerabsorption_of},--固若金汤
    {chance = 0.042, item = "fishingsurprised", name= "侵掠如火", eventF = events.buff_attack_of},--侵掠如火
    -- {chance = 0.005, item = "fishingsurprised", name= "黑洞？", eventF = events.black_hole},--黑洞？
    {chance = 0.02, item = "fishingsurprised", name= "随机buff", eventF = events.random_buff},--随机buff
    {chance = 0.001, item = "fishingsurprised", name= "上次事件", eventF = events.previousF, eventA = events.previousA},--上次事件
    {chance = 0.005, item = "fishingsurprised", name= "不一样的海洋", eventF = events.oceancolour},--不一样的海洋
    {chance = 0.025, item = "fishingsurprised", name= "垃圾雨", eventF = events.junkball},--垃圾雨
    {chance = 0.02, item = "fishingsurprised", name= "提线木偶", eventF = events.puppet},--提线木偶
    -- {chance = 0.015, item = "fishingsurprised", name= "控制傀儡", eventF = events.puppet_boss},--控制傀儡
    {chance = 0.09, item = "fishingsurprised", name= "卧槽！冰", eventF = events.oceanice},--卧槽！冰
    {chance = 0.01, item = "fishingsurprised", name= "亡语时间", eventF = events.deathrattle_of},--亡语时间
    {chance = 0.01, item = "fishingsurprised", name= "蠕虫来袭", eventF = events.worm_attack},--蠕虫来袭
    {chance = 0.01, item = "fishingsurprised", name= "恶液雨", eventF = events.gelblobs},--恶液雨
    {chance = 0.01, item = "fishingsurprised", name= "寒冰屏障", eventF = events.icewall},--寒冰屏障
    {chance = 0.01, item = "fishingsurprised", name= "硕果累累", eventF = events.fruits, parameter = huge_fruits_loot},--硕果累累
    -- {chance = 0.005, item = "fishingsurprised", name= "专属物品", eventF = events.playerdata},--专属物品

}
-- 材料表: 基础原材料
loots.materials = {
    {chance = 3.1, item = "log"},--木头
    {chance = 0.3, item = "charcoal"},--木炭
    {chance = 0.5, item = "flint"},--燧石
    {chance = 0.4, item = "nitre"},--硝石
    {chance = 2.1, item = "rocks"},--石头
    {chance = 4, item = "cutgrass"},--草
    {chance = 4, item = "twigs"},--树枝
    {chance = 0.1, item = "marble"},--大理石
    {chance = 1.2, item = "goldnugget"},--黄金
    {chance = 0.05, item = "petals_evil"},--恶魔花瓣
    {chance = 0.5, item = "cutreeds"},--芦苇
    {chance = 0.5, item = "boards"},--木板
    {chance = 0.5, item = "cutstone"},--石砖
    {chance = 0.2, item = "papyrus"},--纸
    {chance = 0.8, item = "pigskin"},--猪皮
    {chance = 0.2, item = "manrabbit_tail"},--兔毛
    {chance = 0.4, item = "spidergland"},--蜘蛛腺体
    {chance = 0.02, item = "honeycomb"},--蜂巢
    {chance = 0.01, item = "tentaclespots"},--触手皮
    {chance = 0.01, item = "coontail"},--猫鞭
    {chance = 0.5, item = "mosquitosack"},--蚊子血囊
    {chance = 0.2, item = "lightninggoathorn"},--闪电羊角
    {chance = 0.2, item = "glommerfuel"},--格罗姆黏液
    {chance = 1.2, item = "nightmarefuel"},--噩梦燃料
    {chance = 0.2, item = "transistor"},--电子元件
    {chance = 0.5, item = "poop"},--便便
    {chance = 0.02, item = "waxpaper"},--蜡纸
    {chance = 0.21, item = "moonrocknugget"},--月石
    {chance = 0.01, item = "houndstooth"},--狗牙
    {chance = 0.01, item = "stinger"},--蜂刺
    {chance = 0.2, item = "gears"},--齿轮
    {chance = 0.1, item = "boneshard"},--骨头碎片
    {chance = 0.3, item = {"feather_crow","feather_robin","feather_robin_winter","feather_canary"}},--羽毛
    {chance = 0.3, item = "beefalowool"},--牛毛
    {chance = 0.5, item = "beardhair"},--胡子
    {chance = 0.01, item = "townportaltalisman"},--砂石
    {chance = 0.3, item = "lightbulb"},--荧光果
    {chance = 0.1, item = "lureplantbulb"},--食人花
    {chance = 0.01, item = "slurtleslime"},--蜗牛黏液
    {chance = 0.01, item = "slurtle_shellpieces"},--蜗牛壳碎片
    {chance = 0.01, item = "slurper_pelt"},--啜食者皮
    {chance = 0.2, item = "saltrock"},--盐晶
    {chance = 0.1, item = "seeds"},--种子
    {chance = 0.01, item = "walrus_tusk", announce = true},--象牙
    {chance = 0.06, item = "purplegem"},--紫宝石
    {chance = 0.1, item = "bluegem"},--蓝宝石
    {chance = 0.1, item = "moonrockcrater"},--带孔月岩
    {chance = 0.1, item = "moonglass"},--月亮碎片
    {chance = 0.08, item = "redgem"},--红宝石
    {chance = 0.06, item = "steelwool"},--钢绒
    {chance = 0.05, item = "goose_feather"},--鹿鸭羽毛
    {chance = 0.01, item = "bearger_fur", announce = true},--熊皮
    {chance = 0.002, item = "minotaurhorn", announce = true},--远古守护者角
    {chance = 0.003, item = "deerclops_eyeball", announce = true},--巨鹿眼球
    {chance = 0.08, item = "livinglog"},--活木
    {chance = 0.005, item = "dragon_scales", announce = true},--蜻蜓鳞片
    {chance = 0.003, item = "shroom_skin", announce = true},--蛤蟆皮
    {chance = 0.002, item = "shadowheart", announce = true},--暗影之心
    {chance = 0.02, item = "orangegem", announce = true},--橙宝石
    {chance = 0.01, item = "yellowgem", announce = true},--黄宝石
    {chance = 0.01, item = "greengem", announce = true},--绿宝石
    {chance = 0.01, item = "opalpreciousgem", announce = true},--彩虹宝石
    {chance = 0.08, item = "thulecite"},--铥矿
    {chance = 0.05, item = "dreadstone"},-- 绝望石
    {chance = 0.05, item = "horrorfuel"},-- 纯粹恐惧
    {chance = 0.05, item = "purebrilliance"}, --纯粹辉煌
    {chance = 0.05, item = "lunarplant_husk"}, --亮茄外壳
    {chance = 0.02, item = "phlegm"},--脓鼻涕        
    {chance = 0.2, item = "thulecite_pieces"},--铥矿碎片
    {chance = 0.02, item = "voidcloth"},--暗影碎布
    {chance = 0.01, item = "ghostflower"},--哀悼荣耀
    {chance = 0.01, item = "fossil_piece"},--化石碎片
    {chance = 0.01, item = "mandrake", announce = true},--曼德拉草
    {chance = 0.005, item = "malbatross_feather_fall"}, --飘落的邪天翁羽毛
    {chance = 0.05, item = "moonglass_charged"}, --注能月亮碎片
    {chance = 0.05, item = "ancientfruit_gem"}, --晶洞果
    {chance = 0.00001, item = "shadowheart_infused", announce = true},--附身暗影心房
    {chance = 0.003, item = "gelblob_bottle"},--Icker Jar
    {chance = 0.05, item = "spice_jelly"},--果冻粉
    {chance = 0.05, item = "spice_voltjelly"},--带电果冻粉
    {chance = 0.05, item = "spice_phosphor"},--荧光粉
    {chance = 0.05, item = "spice_moontree_blossom"},--月树花粉
    {chance = 0.05, item = "spice_cactus_flower"},--仙人掌花粉
    {chance = 0.05, item = "spice_blood_sugar"},--血糖
    {chance = 0.05, item = "spice_rage_blood_sugar"},--黑暗血糖
    {chance = 0.05, item = "spice_soul"},--灵魂佐料
    {chance = 0.05, item = "spice_potato_starch"},--土豆淀粉
    {chance = 0.05, item = "spice_poop"},--秘制酱料
    {chance = 0.05, item = "spice_plantmeat"},--叶肉酱
    {chance = 0.05, item = "spice_mandrake_jam"},--曼德拉果酱
    {chance = 0.05, item = "spice_pomegranate"},--山力叶酱
    {chance = 0.05, item = "medal_rain_bomb"},--催雨弹
    {chance = 0.05, item = "medal_clear_up_bomb"},--放晴弹
    {chance = 0.05, item = "toil_money"},--血汗钱
    {chance = 0.05, item = "medal_ivy"},--旋花藤
    {chance = 0.05, item = "mandrake_seeds"},--曼德拉种子
    {chance = 0.05, item = "medal_weed_seeds"},--杂草种子
    {chance = 0.05, item = "medal_moonglass_potion"},--月光药水
    {chance = 0.05, item = "bottled_moonlight", announce = true},--瓶装月光
    {chance = 0.05, item = "medaldug_fruit_tree_stump"},--砧木桩
    {chance = 0.05, item = "medaldug_livingtree_root"},--活木树苗
    {chance = 0.05, item = "immortal_book"},--不朽之谜
    {chance = 0.05, item = "immortal_essence"},--不朽精华
    {chance = 0.05, item = "immortal_fruit"},--不朽果实
    {chance = 0.05, item = "medal_glommer_essence"},--格罗姆精华
    {chance = 0.05, item = "medal_inherit_page", announce = true},--传承书页
    {chance = 0.05, item = "sanityrock_fragment"},--方尖碑碎片
    {chance = 0.05, item = "medal_obsidian"},--红晶
    {chance = 0.05, item = "medal_blue_obsidian"},--蓝晶
    {chance = 0.05, item = "bottled_soul", announce = true},--瓶装灵魂
    {chance = 0.05, item = "medal_withered_heart", announce = true},--凋零之心
    {chance = 0.05, item = "medal_bee_larva"},--育王蜂种
    {chance = 0.05, item = "medal_withered_royaljelly"},--凋零蜂王浆
    {chance = 0.05, item = "medal_losswetpouch1"},--遗失塑料袋
    {chance = 0.05, item = "medal_losswetpouch2"},
    {chance = 0.05, item = "medal_losswetpouch3"},
    {chance = 0.05, item = "medal_losswetpouch4"},
    {chance = 0.05, item = "medal_losswetpouch5"},
    {chance = 0.05, item = "medal_losswetpouch6"},
    {chance = 0.05, item = "medal_losswetpouch7"},
    {chance = 0.05, item = "medal_treasure_map"},--藏宝图
    {chance = 0.05, item = "medal_chum"},--特制鱼食
    {chance = 0.05, item = "medal_spacetime_lingshi"},--时空灵石
    {chance = 0.05, item = "medal_spacetime_snacks_packet"},--零食包装袋
    {chance = 0.05, item = "medal_spacetime_snacks", announce = true},--时空零食
    {chance = 0.05, item = "medal_spacetime_potion"},--改命药水
    {chance = 0.05, item = "medal_spacetime_runes"},--时空符文
    {chance = 0.05, item = "medal_time_slider"},--时空碎片
    {chance = 0.05, item = "medal_dustmothden_base", announce = true},--尘蛾巢台
    {chance = 0.05, item = "medal_dustmeringue"},--琥珀灵石
    {chance = 0.05, item = "medal_desert_nucleus"},--沙之晶核
    {chance = 0.05, item = "medal_diligence_token"},--酬勤令
    {chance = 0.05, item = "medal_gift_fruit"},--包果
    {chance = 0.05, item = "medal_origin_essence"},--本源精华
    {chance = 0.05, item = "fishhomingtool_normal"},--简易打窝饵制作器
    {chance = 0.05, item = "ointment_l_fireproof"}, --防火漆
    {chance = 0.05, item = "cattenball"}, --猫线球
    {chance = 0.05, item = "tourmalineshard"},--带电的晶石
    {chance = 0.05, item = "insectshell_l"},--虫甲碎片
    {chance = 0.05, item = "ahandfulofwings"},--虫翅碎片
    {chance = 0.05, item = "tissue_l_lightbulb"},--荧光花活性组织
    {chance = 0.05, item = "tissue_l_berries"},--浆果丛活性组织
    {chance = 0.05, item = "tissue_l_lureplant"},--食人花活性组织
    {chance = 0.05, item = "tissue_l_cactus"},--仙人掌活性组织
    {chance = 0.05, item = "siving_derivant_item", announce = true},--子圭奇型岩(物品)
    {chance = 0.05, item = "shyerrylog"},--宽大的木墩
    {chance = 0.05, item = "siving_rocks"},--子圭石
    {chance = 0.05, item = "merm_scales"},--鱼鳞

}
-- 物品表: 道具、工具、武器
loots.goods = {
    {chance = 0.005, item = "moonrockidol"},--月岩雕像
    {chance = 0.07, item = "messagebottle"},--瓶中信
    {chance = 0.001, item = "cursed_monkey_token"},--诅咒饰品
    {chance = 0.05, item = {"brush","razor","compost","hammer"}},--洗刷\剃刀\耕作先驱帽\锤子
    {chance = 0.05, item = {"farm_plow_item","wateringcan"}},--耕地机\空浇水壶\
    {chance = 0.01, item = "premiumwateringcan", announce = true},--鸟嘴喷壶
    {chance = 0.1, item = {"soil_amender","plantregistryhat","fertilizer", "mosquitofertilizer"}},--堆肥\催长剂起子\堆肥桶\嗡嗡肥料
    {chance = 0.5, item = {"axe","pickaxe","shovel","farm_hoe"}},--斧头-鹤嘴锄-铲子-园艺锄
    {chance = 0.25, item = {"goldenaxe","goldenpickaxe","goldenshovel","golden_farm_hoe"}},--黄金斧头-黄金鹤嘴锄-黄金铲子-黄金园艺锄
    {chance = 0.15, item = "moonglassaxe"},--月光玻璃斧头
    {chance = 0.001, item = {"pickaxe_lunarplant", "shovel_lunarplant"}, announce = true}, --亮茄粉碎者\亮茄铲子
    {chance = 0.4, item = "torch"},--火把

    {chance = 0.03, item = {"oar","oar_driftwood","oar_monkey"}},--三种浆
    --{chance = 0.05, item = "mast_item"},--海钓竿
    {chance = 0.01, item = "mast_malbatross_item", announce = true},--飞翼风帆
    {chance = 0.05, item = {"oceanfishingbobber_ball","oceanfishingbobber_oval","trinket_8","oceanfishingbobber_robin","oceanfishingbobber_canary","oceanfishingbobber_crow","oceanfishingbobber_robin_winter","oceanfishingbobber_goose","oceanfishingbobber_malbatross"}},--木球浮标-木球浮标-硬物浮标
    {chance = 0.1, item = "featherpencil"},--羽毛笔
    {chance = 0.01, item = "pitchfork"},--草叉
    {chance = 0.04, item = "trap"},--陷阱
    {chance = 0.02, item = "lifeinjector"},--强心针
    {chance = 0.25, item = "birdtrap"},--捕鸟陷阱
    {chance = 0.25, item = {"bugnet","umbrella","grass_umbrella"}},--捕虫网
    {chance = 0.01, item = {"saddle_war","saddle_race","saddle_basic","saddle_wathgrithr"}},--鞍具
    {chance = 0.001, item = "fishingrod"},--钓竿
    {chance = 0.07, item = "waterballoon"},--水球
    {chance = 0.05, item = "heatrock"},--热能石
    {chance = 0.04, item = {"bedroll_furry","bedroll_straw"}},--凉席\毛皮铺盖
    {chance = 0.04, item = "sewing_kit"},--针线包
    {chance = 0.04, item = "lantern"},--提灯
    {chance = 0.1, item = "deer_antler"},--鹿角
    {chance = 0.3, item = "healingsalve"},--治疗药膏
    {chance = 0.3, item = "tillweedsalve"},--犁地草膏
    {chance = 0.2, item = "bandage"},--蜂蜜药膏
    {chance = 0.02, item = {"bundlewrap","giftwrap"}},--捆绑包装纸
    {chance = 0.001, item = "firecrackers"},--鞭炮 算是彩蛋吧
    {chance = 0.1, item = {"redlantern","pumpkin_lantern","miniboatlantern"}},--红灯笼--漂浮灯笼--南瓜灯
    {chance = 0.01, item = {"halloweenpotion_bravery_small","halloweenpotion_bravery_large","halloweenpotion_health_small","halloweenpotion_health_large","halloweenpotion_sanity_small","halloweenpotion_sanity_large"}},--药水
    {chance = 0.01, item = "atrium_key", announce = true},--远古钥匙
    {chance = 0.01, item = "alterguardianhatshard", announce = true},--启迪之冠碎片
    {chance = 0.05, item = "featherfan", announce = true},--羽毛扇
    {chance = 0.08, item = "multitool_axe_pickaxe"},--多功能工具
    {chance = 0.01, item = "klaussackkey", announce = true},--克劳斯钥匙
    {chance = 0.1, item = "gunpowder"},--炸药
    {chance = 0.15, item = "hambat"},--火腿棍
    {chance = 0.1, item = "nightstick"},--晨星
    {chance = 0.15, item = "tentaclespike"},--狼牙棒
    {chance = 0.15, item = "glasscutter"},--玻璃刀
    {chance = 0.05, item = "gnarwail_horn"},--独角鲸的角
    {chance = 0.01, item = "malbatross_beak", announce = true},--邪天翁的喙
    {chance = 0.1, item = "whip"},--三尾猫鞭
    {chance = 0.3, item = {"blowdart_sleep","blowdart_fire","blowdart_pipe","blowdart_yellow"}},--催眠吹箭火焰吹箭吹箭电箭
    {chance = 0.2, item = "boomerang"},--回旋镖
    {chance = 0.02, item = "waterplant_bomb"},--种壳
    {chance = 0.05, item = "shieldofterror"},--恐怖盾牌
    {chance = 0.15, item = {"spear_wathgrithr","spear"}},--战斗长矛
    {chance = 0.05, item = "nightsword"},--暗夜剑
    {chance = 0.05, item = "batbat"},--蝙蝠棒
    {chance = 0.05, item = "firestaff"},--火焰法杖
    {chance = 0.05, item = "icestaff"},--冰魔杖
    {chance = 0.001, item = "cannonball_rock_item"}, --炮弹
    {chance = 0.001, item = "perdfan", announce = true}, --幸运扇
    {chance = 0.02, item = "telestaff", announce = true},--传送魔杖
    {chance = 0.01, item = "staff_tornado", announce = true},--天气棒
    {chance = 0.005, item = "cane", announce = true},--步行手杖
    {chance = 0.01, item = "panflute", announce = true},--排箫
    {chance = 0.006, item = "orangestaff", announce = true},--瞬移魔杖
    {chance = 0.01, item = "yellowstaff", announce = true},--唤星者法杖
    {chance = 0.006, item = "greenstaff", announce = true},--解构魔杖
    {chance = 0.02, item = "ruins_bat", announce = true},--远古棒
    {chance = 0.002, item = "opalstaff", announce = true},--唤月法杖
    {chance = 0.0003, item = "staff_lunarplant", announce = true}, --亮茄魔杖
    {chance = 0.0004, item = "sword_lunarplant", announce = true}, --亮茄剑
    {chance = 0.03, item = "bomb_lunarplant"}, --亮茄炸弹
    {chance = 0.02, item = "trident"},--三叉戟
    {chance = 0.001, item="book_tentacles"}, --触手书
    {chance = 0.001, item="book_birds"}, --鸟书
    {chance = 0.001, item="book_brimstone"}, --末日书
    {chance = 0.001, item="book_sleep"}, --催眠书
    {chance = 0.01, item = "stash_map"}, --海盗地图
    {chance = 0.0002, item = "voidcloth_scythe", announce = true}, --暗影收割者
    {chance = 0.0001, item = "voidcloth_umbrella", announce = true}, --暗影伞
    {chance = 0.03, item = "voidcloth_kit"}, --虚空修复包
    {chance = 0.03, item = "lunarplant_kit"}, --亮茄修复包
    {chance = 0.013, item = "treegrowthsolution"}, --树果酱
    {chance = 0.03, item = "walking_stick", announce = true}, --木手杖
    {chance = 0.001, item = "thurible"}, --暗影香炉
    {chance = 0.008, item = "carnival_seedpacket", eventA = p_events.seedpacket}, --种子包
    {chance = 0.007, item = {"yotc_seedpacket_rare","yotc_seedpacket"}},--高级种子包
    {chance = 0.03, item = "gift", name = "战斗套装", eventF = p_events.gift, parameter = "combat1"},
    {chance = 0.005, item = "gift", name = "铥矿套装", eventF = p_events.gift, parameter = "combat2"},
    {chance = 0.01, item = "gift", name = "暗影套装", eventF = p_events.gift, parameter = "combat3"},
    {chance = 0.05, item = "gift", eventF = p_events.gift, parameter = "combat4"},
    {chance = 0.001, item = "hutch_fishbowl", announce = true}, --星空
    {chance = 0.001, item = "chester_eyebone", announce = true}, --眼骨
    {chance = 0.001, item = "moonrockseed", announce = true}, --天体宝球
    {chance = 0.001, item = "bootleg", announce = true}, --出逃腿靴
    {chance = 0.01, item = "spear_wathgrithr_lightning"}, --奔雷矛
    {chance = 0.016, item = "portabletent_item"}, --帐篷卷
    {chance = 0.0001, item = "fishingnet"}, --渔网 打捞海面上物品到包里
    {chance = 0.05, item = "mosquitomusk"}, --小痒痒 蚊子不会主动攻击该玩家
    {chance = 0.01, item = "mosquitobomb"}, --蚊子炸弹
    {chance = 0.005, item = "healingsalve_acid"}, --黏糊糊的药膏
    {chance = 0.0003, item = "voidcloth_boomerang", announce = true}, --阴郁回旋镖
    {chance = 0.0003, item = "shadow_battleaxe", announce = true}, --暗影槌
    {chance = 0.0005, item = "rabbitkingspear", announce = true}, --兔王棍
    {chance = 0.0001, item = "shadow_beef_bell", announce = true}, --阴郁皮弗娄牛铃铛
    {chance = 0.0001, item = "saddle_shadow", announce = true}, --梦魇鞍具
    {chance = 0.0001, item = "rabbitkinghorn", announce = true}, --挖洞兔号角
    {chance = 0.06, item = "yots_lantern_post"},--喜庆灯笼柱
    {chance = 0.05, item = "yots_lantern_post_item"},--喜庆灯笼柱套装
    {chance = 0.05, item = "marbleaxe"},--大理石斧头
    {chance = 0.05, item = "marblepickaxe"},--大理石镐
    {chance = 0.05, item = "medal_moonglass_shovel"},--月光玻璃铲
    {chance = 0.05, item = "medal_moonglass_hammer"},--月光玻璃锤
    {chance = 0.05, item = "medal_moonglass_bugnet"},--月光玻璃网
    {chance = 0.05, item = "medal_moonlight_staff", announce = true},--月光法杖
    {chance = 0.05, item = "immortal_staff"},--不朽法杖
    {chance = 0.005, item = "headchef_certificate", announce = true},--主厨勋章
    {chance = 0.05, item = "spices_box"},--调料盒
    {chance = 0.05, item = "medal_box"},--勋章盒
    {chance = 0.005, item = "largechop_certificate", announce = true},--高级伐木勋章
    {chance = 0.005, item = "largeminer_certificate", announce = true},--高级矿工勋章
    {chance = 0.005, item = "handy_certificate", announce = true},--巧手勋章
    {chance = 0.05, item = "medal_farm_plow_item"},--高效耕地机
    {chance = 0.05, item = "medal_waterpump_item"},--深井泵套件    
    {chance = 0.005, item = "wisdom_certificate", announce = true},--智慧勋章
    {chance = 0.005, item = "plant_certificate", announce = true},--虫木勋章
    {chance = 0.005, item = "transplant_certificate", announce = true},--植物勋章
    {chance = 0.005, item = "harvest_certificate", announce = true},--丰收勋章
    {chance = 0.005, item = "bosom_friend_certificate", announce = true},--挚友勋章
    {chance = 0.005, item = "justice_certificate", announce = true},--正义勋章
    {chance = 0.05, item = "medal_goathat", announce = true},--羊角帽
    {chance = 0.005, item = "merm_certificate", announce = true},--鱼人勋章
    {chance = 0.005, item = "valkyrie_certificate", announce = true},--女武神勋章
    {chance = 0.005, item = "naughty_certificate", announce = true},--淘气勋章
    {chance = 0.05, item = "medal_naughtybell", announce = true},--淘气铃铛
    {chance = 0.05, item = "blank_certificate", announce = true},--空白勋章
    {chance = 0.005, item = "inherit_certificate", announce = true},--传承勋章
    {chance = 0.005, item = "down_filled_coat_certificate", announce = true},--羽绒勋章
    {chance = 0.005, item = "blue_crystal_certificate", announce = true},--蓝晶勋章
    {chance = 0.005, item = "ommateum_certificate", announce = true},--复眼勋章
    {chance = 0.005, item = "treadwater_certificate", announce = true},--踏水勋章
    {chance = 0.005, item = "tentacle_certificate", announce = true},--触手勋章
    {chance = 0.05, item = "monster_book", announce = true},--怪物图鉴
    {chance = 0.05, item = "unsolved_book", announce = true},--未解之谜
    {chance = 0.05, item = "medal_plant_book", announce = true},--植物图鉴
    {chance = 0.005, item = "immortal_gem", announce = true},--不朽宝石
    {chance = 0.05, item = "sanityrock_mace", announce = true},--方尖锏
    {chance = 0.05, item = "meteor_staff", announce = true},--流星法杖
    {chance = 0.005, item = "spider_certificate", announce = true},--蜘蛛勋章
    {chance = 0.005, item = "silence_certificate", announce = true},--沉默勋章
    {chance = 0.005, item = "bathingfire_certificate", announce = true},--浴火勋章
    {chance = 0.005, item = "devour_soul_certificate", announce = true},--噬灵勋章
    {chance = 0.005, item = "medium_devour_soul_certificate", announce = true},--噬魂勋章
    {chance = 0.005, item = "large_devour_soul_certificate", announce = true},--噬空勋章
    {chance = 0.005, item = "bee_king_certificate", announce = true},--蜂王勋章
    {chance = 0.005, item = "largefishing_certificate", announce = true},--渔翁勋章
    {chance = 0.05, item = "medal_fishingrod"},--玻璃钓竿
    {chance = 0.05, item = "medal_resonator_item"},--宝藏探测仪
    {chance = 0.005, item = "childlike_certificate", announce = true},--童真勋章
    {chance = 0.005, item = "medal_spacetime_crystalball", announce = true},--预言水晶球
    {chance = 0.005, item = "medal_space_gem", announce = true},--时空宝石
    {chance = 0.005, item = "speed_certificate", announce = true},--速度勋章
    {chance = 0.005, item = "space_certificate", announce = true},--空间勋章
    {chance = 0.005, item = "space_time_certificate", announce = true},--时空勋章
    {chance = 0.005, item = "medal_krampus_chest_item", announce = true}, --坎普斯宝匣
    {chance = 0.005, item = "devour_staff", announce = true}, --吞噬法杖
    {chance = 0.005, item = "medal_space_staff", announce = true}, --时空法杖
    {chance = 0.005, item = "medal_shadow_magic_stone", announce = true}, --暗影魔法石
    {chance = 0.005, item = "shadowmagic_certificate", announce = true}, --暗影魔法勋章
    {chance = 0.05, item = "medal_shadow_tool", announce = true}, --暗影魔法工具
    {chance = 0.005, item = "soul_contracts", announce = true}, --灵魂契约
    {chance = 0.005, item = "tourmalinecore", announce = true}, --电气石
    {chance = 0.005, item = "siving_ctlall_item", announce = true}, --子圭·崇溟
    {chance = 0.05, item = "triplegoldenshovelaxe", announce = true}, --斧铲-黄金三用型
    {chance = 0.05, item = "guitar_miguel", announce = true}, --米格尔的吉他
    {chance = 0.005, item = "fishhomingtool_awesome", announce = true}, --专业打窝饵制作器
    {chance = 0.05, item = "explodingfruitcake", announce = true}, --爆炸水果蛋糕
    {chance = 0.05, item = "icire_rock", announce = true}, --鸳鸯石
    {chance = 0.05, item = "dualwrench"}, --扳手-双用型
    {chance = 0.05, item = "tripleshovelaxe"}, --斧铲-三用型
    {chance = 0.005, item = "siving_boxopener", announce = true}, --子圭·系
    {chance = 0.01, item = "boxopener_l", announce = true}, --云松子
    {chance = 0.05, item = "ointment_l_sivbloodreduce", announce = true}, --弱肤药膏
    {chance = 0.005, item = "siving_feather_real", announce = true}, --子圭·翰
    {chance = 0.05, item = "siving_soil_item", announce = true}, --子圭·垄
    {chance = 0.01, item = "siving_ctldirt_item", announce = true}, --子圭·益矩
    {chance = 0.01, item = "siving_ctlwater_item", announce = true}, --子圭·利川
    {chance = 0.05, item = "guitar_whitewood"}, --白木吉他
    {chance = 0.01, item = "revolvedmoonlight_item", announce = true}, --月轮宝盘套件
    {chance = 0.005, item = "revolvedmoonlight", announce = true}, --月轮宝盘
    {chance = 0.005, item = "revolvedmoonlight_pro", announce = true}, --月轮宝盘pro
    {chance = 0.05, item = "shield_l_sand", announce = true}, --砂之抵御
    {chance = 0.05, item = "book_weather", announce = true}, --多变的云
    {chance = 0.05, item = "neverfade", announce = true}, --永不凋零
    {chance = 0.01, item = "simmeredmoonlight_item", announce = true}, --月炆宝炊套件
    {chance = 0.005, item = "simmeredmoonlight_pro_item", announce = true}, --月炆宝炊
    {chance = 0.005, item = "simmeredmoonlight_pro_inf_item", announce = true}, --月炆宝炊pro
    {chance = 0.01, item = "hiddenmoonlight_item", announce = true}, --月藏宝匣套件
    {chance = 0.05, item = "chestupgrader_l", announce = true}, --月石角撑
    {chance = 0.05, item = "pinkstaff", announce = true}, --幻象法杖
    {chance = 0.05, item = "shadowbrush_l", announce = true}, --细微之触
    {chance = 0.05, item = "fimbul_axe", announce = true}, --芬布尔斧
    {chance = 0.05, item = "acc_l_shadowmirror", announce = true}, --捉影之镜
    {chance = 0.005, item = "refractedmoonlight", announce = true}, --月折宝剑
    {chance = 0.005, item = "agronssword", announce = true}, --艾力冈的剑
    {chance = 0.05, item = "foliageath", announce = true}, --青枝绿叶
    {chance = 0.05, item = "lance_carrot_l", announce = true}, --胡萝卜长枪
    {chance = 0.05, item = "siving_feather_fake"}, --子圭玄鸟绒羽
    {chance = 0.05, item = "orchitwigs", announce = true}, --兰草花穗
    {chance = 0.05, item = "lileaves", announce = true}, --蹄莲翠叶
    {chance = 0.05, item = "rosorns", announce = true}, --带刺蔷薇
}
-- 穿戴表: 服装、穿戴物品
loots.equipments = { 
    {chance = 0.1, item = "spicepack"},--厨师包
    {chance = 0.08, item = "piggyback"},--猪皮背包
    {chance = 0.001, item = "krampus_sack", announce = true},--坎普斯背包
    {chance = 0.3, item = "armorgrass"},--草甲
    {chance = 0.05, item = "flowerhat"},--花环
    {chance = 0.05, item = "strawhat"},--草帽
    {chance = 0.01, item = "watermelonhat"},--西瓜帽
    -- {chance = 0.05, item = "featherhat"},--羽毛帽
    -- {chance = 0.02, item = "bushhat"},--灌木帽
    {chance = 0.01, item = "tophat"},--绅士高帽
    {chance = 0.15, item = "rainhat"},--防雨帽
    {chance = 0.15, item = "earmuffshat"},--小兔耳罩
    {chance = 0.01, item = "beefalohat"},--牛角帽
    {chance = 0.15, item = "winterhat"},--冬帽
    {chance = 0.01, item = "catcoonhat"},--浣熊猫帽子
    {chance = 0.02, item = "icehat"},--冰块帽
    {chance = 0.05, item = "beehat"},--养蜂帽
    {chance = 0.1, item = "raincoat"},--雨衣
    {chance = 0.03, item = "sweatervest"},--格子背心
    {chance = 0.05, item = "trunkvest_summer"},--保暖小背心
    {chance = 0.03, item = "reflectivevest"},--清凉夏装
    {chance = 0.03, item = "hawaiianshirt"},--花衬衫
    {chance = 0.04, item = "minerhat"},--矿工帽
    {chance = 0.05, item = "molehat"},--鼹鼠帽
    {chance = 0.02, item = "icepack", announce = true},--保鲜背包
    {chance = 0.2, item = "armorwood"},--木甲
    {chance = 0.15, item = "footballhat"},--橄榄球头盔
    {chance = 0.1, item = "armormarble"},--大理石甲
    {chance = 0.09, item = "armor_sanity"},--魂甲
    {chance = 0.1, item = "eyemaskhat"},--眼面具
    {chance = 0.15, item = "armorslurper"},--饥饿腰带
    {chance = 0.25, item = "wathgrithrhat"},--战斗头盔
    {chance = 0.1, item = "cookiecutterhat"},--饼干切割机帽子
    {chance = 0.1, item = "amulet"},--重生护符
    {chance = 0.08, item = "blueamulet"},--寒冰护符
    {chance = 0.03, item = "purpleamulet"},--噩梦护符
    {chance = 0.05, item = "armordragonfly", announce = true},--鳞甲
    {chance = 0.01, item = {"goggleshat","deserthat"}},--时髦目镜-沙漠目镜
    {chance = 0.05, item = "trunkvest_winter"},--寒冬背心
    {chance = 0.02, item = "beargervest", announce = true},--熊皮背心
    {chance = 0.05, item = {"red_mushroomhat","green_mushroomhat","blue_mushroomhat"}},--红蘑菇帽、绿蘑菇帽、蓝蘑菇帽
    {chance = 0.1, item = "armor_bramble"},--荆棘甲
    {chance = 0.01, item = "eyebrellahat", announce = true},--眼球伞
    {chance = 0.01, item = "ruinshat", announce = true},--远古皇冠
    {chance = 0.02, item = "orangeamulet", announce = true},--懒人强盗
    {chance = 0.01, item = "yellowamulet", announce = true},--魔光护符
    {chance = 0.01, item = "greenamulet", announce = true},--建造护符
    {chance = 0.03, item = "slurtlehat"},--蜗牛帽
    {chance = 0.03, item = "armorsnurtleshell"},--蜗牛盔甲
    {chance = 0.01, item = "hivehat", announce = true},--蜂后头冠
    {chance = 0.005, item = "armorskeleton", announce = true},--远古骨甲
    {chance = 0.03, item = "armorruins", announce = true},--远古护甲
    {chance = 0.02, item = "antlionhat", announce = true},--刮地皮头盔
    {chance = 0.02, item = "armordreadstone", announce = true},--绝望石盔甲
    {chance = 0.01, item = "dreadstonehat", announce = true},--绝望石头盔
    {chance = 0.0005, item = "lunarplanthat", announce = true}, --亮茄头盔
    {chance = 0.0005, item = "armor_lunarplant", announce = true}, --亮茄盔甲
    {chance = 0.0005, item = "voidclothhat", announce = true}, --虚空风帽
    {chance = 0.0005, item = "armor_voidcloth", announce = true}, --虚空长袍
    {chance = 0.02, item = "woodcarvedhat"}, --硬木帽
    {chance = 0.02, item = "wathgrithr_improvedhat"}, --统帅头盔
    {chance = 0.0005, item = "wagpunkhat", announce = true}, --W.A.R.B.I.S.头戴齿轮
    {chance = 0.0005, item = "armorwagpunk", announce = true}, --W.A.R.B.I.S.盔甲
    {chance = 0.0025, item = "scraphat", announce = true}, --拾荒尖帽
    {chance = 0.0005, item = "scrap_monoclehat", announce = true}, --视界扩展器
    {chance = 0.05, item = "rabbithat"}, --洞穴花环
    {chance = 0.025, item = "armor_carrotlure"}, --胡萝卜外套
    {chance = 0.01, item = "down_filled_coat", announce = true}, --羽绒服
    {chance = 0.01, item = "hat_blue_crystal", announce = true}, --蓝晶帽
    {chance = 0.01, item = "armor_medal_obsidian", announce = true}, --红晶甲
    {chance = 0.01, item = "armor_blue_crystal", announce = true}, --蓝晶甲
    {chance = 0.005, item = "armor_medal_space_time", announce = true}, --时空晶甲
    {chance = 0.005, item = "hat_elepheetle", announce = true}, --犀金胄甲
    {chance = 0.005, item = "armor_elepheetle", announce = true}, --犀金护甲
    {chance = 0.005, item = "siving_suit_gold", announce = true}, --子圭·釜
    {chance = 0.005, item = "siving_mask_gold", announce = true}, --子圭·歃
    {chance = 0.05, item = "hat_cowboy"}, --牛仔帽
    {chance = 0.05, item = "hat_albicans_mushroom"}, --素白蘑菇帽
    {chance = 0.05, item = "siving_suit"}, --子圭·庇
    {chance = 0.05, item = "siving_mask"}, --子圭·汲
    {chance = 0.05, item = "hat_lichen"}, --苔衣发卡
    {chance = 0.005, item = "boltwingout", announce = true},--脱壳之翅
    {chance = 0.01, item = "giantsfoot", announce = true}, --巨人之脚
    {chance = 0.05, item = "theemperorspendant", announce = true},--皇帝的吊坠
    {chance = 0.05, item = "theemperorsscepter", announce = true},--皇帝的权杖
    {chance = 0.05, item = "theemperorsmantle", announce = true},--皇帝的披风
    {chance = 0.05, item = "theemperorscrown", announce = true},--皇帝的王冠
    {chance = 0.05, item = "backcub", announce = true},--靠背熊
}

-- 可种植表: 种子、可移植植物
loots.plant = {
    {chance = 0.06, item = "pinecone"},--松果
    {chance = 0.06, item = "acorn"},--桦木果
    {chance = 0.05, item = "twiggy_nut"},--多枝种子
    {chance = 0.01, item = "livingtree_root"},--完全正常的树根
    {chance = 0.05, item = "marblebean"},--大理石豆
    {chance = 0.08, item = "rock_avocado_fruit_sprout"},--发芽石果
    {chance = 0.14, item = {"seeds","asparagus_seeds","carrot_seeds","corn_seeds","dragonfruit_seeds","durian_seeds","eggplant_seeds","garlic_seeds","onion_seeds","pepper_seeds","pomegranate_seeds","potato_seeds","pumpkin_seeds","tomato_seeds","watermelon_seeds"}},--种子
    {chance = 0.15, item = "dug_grass"},--草丛
    {chance = 0.15, item = "dug_sapling"},--树苗
    {chance = 0.15, item = "dug_marsh_bush"},--荆棘丛
    {chance = 0.15, item = "dug_sapling_moon"},--月岛树苗
    {chance = 0.08, item = "dug_berrybush"},--普通浆果丛
    {chance = 0.08, item = "dug_berrybush2"},--三叶浆果丛
    {chance = 0.08, item = "dug_bananabush"},--香蕉丛
    {chance = 0.08, item = "dug_monkeytail"},--猴尾草
    {chance = 0.08, item = "dug_berrybush_juicy"},--多汁浆果丛
    {chance = 0.01, item = "dug_rock_avocado_bush"},--石果灌木
    {chance = 0.05, item = "bullkelp_root"},--海带茎
    {chance = 0.01, item = "waterplant_planter"},--海芽插穗

    {chance = 0.001, item = "lunar_forge_kit", announce = true}, --辉煌铁匠铺套装
    {chance = 0.001, item = "shadow_forge_kit", announce = true}, --暗影术基座套装
    {chance = 0.001, item = "gelblob_storage_kit", announce = true}, --恶液储存箱套件
    {chance = 0.005, item = "boat_cannon_kit"}, --大炮套装
    {chance = 0.001, item = {"boat_bumper_kelp_kit", "boat_bumper_shell_kit", "boat_bumper_crabking_kit"}}, --贝壳保险杠套装\海带保险杠套装\帝王蟹保险杠套装

    {chance = 0.075, item = {"boat_item", "boat_grass_item", "boat_ancient_item"}},--船套装 草筏套装 古董船套装
    {chance = 0.06, item = {"oar","anchor_item","steeringwheel_item","boatpatch"}},--锚套装-方向舵套装-船补丁-桅杆套装
    {chance = 0.002, item = "eyeturret_item", announce = true},--眼球塔
    {chance = 0.01, item = {"yotr_decor_1_item","yotr_decor_2_item"}}, --矮高兔灯
    {chance = 0.1, item = {"beemine","trap_teeth","dug_trap_starfish"}},--蜜蜂地雷\犬牙陷阱\海星陷阱
    {chance = 0.08, item = "spidereggsack"},--蜘蛛卵
    {chance = 0.004, item = "oceantreenut"},--疙瘩树种
    {chance = 0.01, item = "gift", name = "树种礼包", eventF = p_events.gift_plant, parameter = "tree"},
    {chance = 0.02, item = "gift", name = "树枝礼包", eventF = p_events.gift_plant, parameter = "sapling"},
    {chance = 0.009, item = "gift", name = "杂植礼包", eventF = p_events.gift_plant, parameter = "miscellaneous"},
    {chance = 0.01, item = "gift", name = "鸡窝礼包", eventF = p_events.gift_plant, parameter = "berrybush"},
    {chance = 0.05, item = "immortal_fruit_seed", announce = true},--不朽种子
    {chance = 0.05, item = "medal_gift_fruit_seed", announce = true},--包果种子
    {chance = 0.05, item = "shyerrycore_item", announce = true},--颤栗树心芽
    {chance = 0.05, item = "cutted_lumpyevergreen", announce = true},--臃肿常青树嫩枝
    {chance = 0.05, item = "cutted_rosebush", announce = true},--蔷薇折枝
    {chance = 0.05, item = "cutted_lilybush", announce = true},--蹄莲芽束
    {chance = 0.05, item = "cutted_orchidbush", announce = true},--兰草种籽
    {chance = 0.05, item = "dug_monstrain", announce = true},--雨竹块茎
    {chance = 0.05, item = "seeds_lightbulb_l", announce = true},--[异种]夜盏花
    {chance = 0.05, item = "seeds_log_l", announce = true},--[异种]云青松
    {chance = 0.05, item = "seeds_carrot_l", announce = true},--[异种]芾萝卜
    {chance = 0.05, item = "seeds_berries_l", announce = true},--[异种]果攀树
    {chance = 0.05, item = "seeds_cactus_meat_l", announce = true},--[异种]仙人柱
    {chance = 0.05, item = "seeds_corn_l", announce = true},--[异种]玉米杆
    {chance = 0.05, item = "seeds_pumpkin_l", announce = true},--[异种]南瓜架
    {chance = 0.05, item = "seeds_eggplant_l", announce = true},--[异种]茄巢
    {chance = 0.05, item = "seeds_durian_l", announce = true},--[异种]榴莲柳
    {chance = 0.05, item = "seeds_pomegranate_l", announce = true},--[异种]石榴树
    {chance = 0.05, item = "seeds_dragonfruit_l", announce = true},--[异种]火龙果树
    {chance = 0.05, item = "seeds_watermelon_l", announce = true},--[异种]西瓜草
    {chance = 0.05, item = "seeds_pineananas_l", announce = true},--[异种]松萝树
    {chance = 0.05, item = "seeds_onion_l", announce = true},--[异种]洋葱圈
    {chance = 0.05, item = "seeds_pepper_l", announce = true},--[异种]薄荷椒
    {chance = 0.05, item = "seeds_potato_l", announce = true},--[异种]三地薯
    {chance = 0.05, item = "seeds_garlic_l", announce = true},--[异种]鸡毛蒜
    {chance = 0.05, item = "seeds_tomato_l", announce = true},--[异种]刺茄
    {chance = 0.05, item = "seeds_asparagus_l", announce = true},--[异种]芦笋丛
    {chance = 0.05, item = "seeds_mandrake_l", announce = true},--[异种]培植曼草

    {chance = 0.002, item = "ancienttree_seed"},--惊喜种子
    {chance = 0.01, item = huge_fruits_loot, eventF = function(inst) 
        if math.random() > .25 then return end
        inst.force_oversized=true
        if inst.components.growable then
            for i = 1, 4 do
                inst:DoTaskInTime((i-1) * 1 + math.random() * 0.5, function()
                    inst.components.growable:DoGrowth()
                end)
            end
        end
    end}, --种植的作物
    
    {chance = 0.01, item = "tree_rock_seed"},--巨石枝种子
}

-- 料理表: 成品食物
loots.foods = {}
-- 生物表: 大部分生物
loots.organisms = {
    {chance = 0.058, item = {"wilson","wortox","wendy","willow","wickerbottom","waxwell","webber","wes","winona","woodie","wormwood","wurt","warly","wathgrithr","wolfgang","wx78","walter","wanda"},announce = true, eventF = p_events.getplayer},--人物 算为事件
    {chance = 0.1, item = {"butterfly","moonbutterfly"}},--蝴蝶、月蛾
    {chance = 0.1, item = "fireflies"},--萤火虫
    {chance = 0.1, item = "lightflier"},--球状光虫
    {chance = 0.01, item = "moonstorm_spark"}, --月熠
    {chance = 0.01, item = "spore_moon"}, --月亮孢子
    {chance = 0.2, item = "perd", pack = true},--火鸡
    {chance = 0.5, item = {"bee","killerbee"}},--蜜蜂、杀人蜂
    {chance = 0.1, item = "beefalo"},--牛
    {chance = 0.1, item = "lightninggoat"},--闪电羊
    {chance = 0.1, item = "pigman", eventF = function(inst) if TheWorld.state.isnight then inst.components.werebeast:TriggerDelta(4) end end},--猪人
    {chance = 0.05, item = "rocky"},--石虾
    {chance = 0.05, item = "lavae"},--岩浆虫
    {chance = 0.12, item = "catcoon"},--猫
    {chance = 0.05,item = {"wobster_sheller_land", "wobster_moonglass_land"}},--龙虾
    {chance = 0.02, item = "little_walrus"},--小海象
    {chance = 0.2, item = {"koalefant_summer","koalefant_winter"}},--冬夏象
    {chance = 0.1, item = {"spider_healer","spider_water", "spider_moon"} },--护士蜘蛛、海黾、破碎蜘蛛
    {chance = 0.1, item = "grassgator"},--草鳄鱼 
    {chance = 0.1, item = "shark", sleeper = true, eventF = function(inst) inst.components.timer:StartTimer("getdistance", 3) end},--岩石大白鲨 
    {chance = 0.1, item = "gnarwail", sleeper = true},--一角鲸 
    {chance = 0.1, item = "tallbird"},--高鸟
    {chance = 0.1, item = "crawlinghorror"},--暗影爬行怪
    {chance = 0.1, item = "terrorbeak"},--尖嘴暗影怪
    {chance = 0.1, item = "pigguard"},--猪人守卫
    {chance = 0.1, item = "bunnyman"},--兔人
    {chance = 0.4, item = "merm"},--鱼人
    {chance = 0.05, item = "mandrake_active", announce = true},--活曼德拉草
    {chance = 0.1, item = "squid"},--鱿鱼
    {chance = 0.4, item = "mushgnome"},--蘑菇地精
    {chance = 0.3, item = "spider_warrior"},--蜘蛛战士
    {chance = 0.25, item = "spider_hider"},--蜘蛛2
    {chance = 0.25, item = "spider_spitter"},--蜘蛛3
    {chance = 0.3, item = "spider_dropper"},--白蜘蛛
    {chance = 0.5, item = {"hound","firehound","icehound","hedgehound_bush","hedgehound","clayhound"} },--猎狗
    {chance = 0.08, item = "walrus", pack = true},--海象
    {chance = 0.08, item = "slurtle", pack = true},--蜗牛1
    {chance = 0.08, item = "snurtle", pack = true},--蜗牛2
    {chance = 0.1, item = "slurper"},--缀食者
    {chance = 0.14, item = "monkey"},--猴子
    {chance = 0.6, item = "bat"},--蝙蝠
    {chance = 1, item = "mosquito"},--蚊子
    {chance = 1.1, item = "spider"},--蜘蛛
    {chance = 0.6, item = "frog"},--青蛙
    {chance = 0.05, item = "rabbit"},--兔子
    {chance = 0.1, item = "penguin"},--企鹅
    {chance = 0.1, item = {"knight","knight_nightmare"}},--发条骑士\损坏的发条骑士
    {chance = 0.1, item = {"bishop","bishop_nightmare"}},--发条主教\损坏的发条主教
    {chance = 0.1, item = {"rook","rook_nightmare"}},--发条战车\损坏的发条战车
    {chance = 0.1, item = "worm"},--洞穴蠕虫
    {chance = 0.1, item = "krampus"},--小偷
    {chance = 0.05, item = "mossling"},--小鸭
    {chance = 0.2, item = "tentacle"},--触手
    {chance = 0.09, item = "bigshadowtentacle"},--守护者暗影触手
    {chance = 0.1, item = "molebat"},--裸鼹鼠蝙蝠
    {chance = 0.01, item = {"crow","robin","canary","puffin","robin_winter"}, eventA = p_events.bird},--鸟类
    {chance = 0.03, item = "lunarthrall_plant", announce = true},--致命亮茄
    {chance = 0.01, item = "fused_shadeling"}, --熔合暗影
    {chance = 0.03, item = "fused_shadeling_bomb"}, --绝望螨 可分裂
    {chance = 0.04, item = "shadowprotector", eventF = function(inst, player) if math.random() > .5 then inst.components.follower:SetLeader(player) end end}, --暗夜兵
    {chance = 0.1, item = "crabking_claw"}, --帝王蟹的爪子
    {chance = 0.1, item = "fruitdragon"},--沙拉蝾螈
    {chance = 0.04, item = "buzzard"},--秃鹫
    {chance = 0.05, item = "dustmoth", pack = true},--尘蛾
    {chance = 0.1, item = "teenbird"},--小高脚鸟 
    {chance = 0.03, item = {"bird_mutant","bird_mutant_spitter"}},--月盲乌鸦、奇形鸟
    {chance = 0.045, item = "grassgekko"},--草壁虎 
    {chance = 0.001, item = "carrat"},--胡萝卜鼠
    {chance = 0.03,item={"shadowminer","shadowlumber","shadowdigger"}, eventF = function(inst, player) inst.components.follower:SetLeader(player) end},--暗影工具人
    {chance = 0.05, item = "cookiecutter", pack = true},--饼干切割机
    {chance = 0.001, item = "ruins_shadeling"},--休憩恐惧
    {chance = 0.05, item = "lunarfrog"},--明眼青蛙
    {chance = 0.08, item = "eyeplant"},--眼球草
    {chance = 0.12, item = "crabking_mob"},--蟹卫
    {chance = 0.01, item = "crabking_mob_knight"},--蟹骑士
    {chance = 0.015, item = "rabbitkingminion_bunnyman"},--皇家兔子警卫
    {chance = 0.001, item = "itemmimic_revealed"},--拟态蠕虫
    {chance = 0.03, item = "gelblob"},--恶液
    {chance = 0.001, item = "chest_mimic_revealed"},--暴躁箱子
    -- {chance = 0.007, item = "player_hosted", eventF = p_events.player_hosted},--被附身的尸体
    {chance = 0.01, item = "raindonate", anounce = true},--雨蝇
    {chance = 0.01, item = "cropgnat"},--植害虫群
    {chance = 0.01, item = "cropgnat_infester"},--叮咬虫群

    default = {
        sleeper = setsleeper,
    }
}

-- 巨兽表: 巨大怪兽
loots.giants = {
    {chance = 0.02, item = "shadow_rook"},--暗影战车
    {chance = 0.02, item = "shadow_knight"},--暗影骑士
    {chance = 0.02, item = "shadow_bishop"},--暗影主教 
    {chance = 0.05, item = "spiderqueen"},--蜘蛛女王
    {chance = 0.05, item = "leif"},--树精
    {chance = 0.05, item = "leif_sparse"},--稀有树精
    {chance = 0.004, item = "stalker_forest", sleeper = false},--森林守护者
    {chance = 0.03, item = "deerclops"},--巨鹿
    {chance = 0.05, item = "moose", sleeper = false},--鹿鸭\麋鹿鹅
    {chance = 0.02, item = {"warg","gingerbreadwarg","claywarg"}},--座狼、姜饼座狼、粘土座狼
    {chance = 0.02, item = "spat"},--钢羊
    {chance = 0.09, item = "warglet"},--年轻座狼
    {chance = 0.03, item = "bearger"},--熊大
    {chance = 0.01, item = "klaus", eventF = p_events.klaus},--克劳斯
    {chance = 0.01, item = "dragonfly"},--龙蝇
    {chance = 0.01, item = "antlion", eventF = p_events.antlion},--蚁狮
    {chance = 0.01, item = "beequeen"},--蜂后
    {chance = 0.012, item = "minotaur"},--远古守护者
    {chance = 0.01, item = "toadstool"},--蘑菇蛤
    {chance = 0.003, item = "toadstool_dark"},--毒蘑菇蛤
    {chance = 0.001, item = "stalker_atrium"},--远古影织者
    {chance = 0.01, item = "stalker"},--复活的骨架
    {chance = 0.0055, item = {"alterguardian_phase1","alterguardian_phase2","alterguardian_phase3"}},--天体英雄3
    {chance = 0.03, item = "malbatross"},--邪天翁
    {chance = 0.01, item = "crabking"},--帝王蟹
    {chance = 0.03, item = "eyeofterror"},--恐怖之眼
    {chance = 0.01, item = {"twinofterror1","twinofterror2"}},--机械之眼1 激光眼 机械之眼2 魔焰眼
    {chance = 0.007, item = "shadowthrall_hands", name= "墨荒·文"}, --墨荒·滚 文
    {chance = 0.007, item = "shadowthrall_horns", name= "墨荒·甘"}, --墨荒·吞 甘
    {chance = 0.007, item = "shadowthrall_wings", name= "墨荒·崔"}, --墨荒·飞 崔
    {chance = 0.007, item = "shadowthrall_mouth", name= "墨荒·山"}, --墨荒·蛇 山
    {chance = 0.045, item = "lordfruitfly"}, --果蝇王
    {chance = 0.005, item = {"twinofterror1","twinofterror2","spiderqueen","leif","leif_sparse","deerclops","moose","spat","warglet","bearger","klaus","dragonfly","beequeen","minotaur","toadstool","toadstool_dark","stalker","malbatross",
    "crabking","eyeofterror","shadowthrall_hands","shadowthrall_horns","shadowthrall_wings","shadow_rook","warg","gingerbreadwarg","claywarg","shadow_knight","shadow_bishop","alterguardian_phase1","alterguardian_phase2","alterguardian_phase3", "mutateddeerclops", "mutatedbearger", "mutatedwarg", "sharkboi", "worm_boss"}, pack = true, pack_chance = 1}, --boss包裹
    {chance = 0.008, item = "deciduoustree", eventF = function(inst) if inst.StartMonster then inst:StartMonster(true) end end},--桦树精
    {chance = 0.003, item = "deerclopscorpse"}, --晶体独眼巨鹿尸体
    {chance = 0.003, item = "beargercorpse"}, --装甲熊獾尸体
    {chance = 0.004, item = "wargcorpse"}, --附身座狼尸体
    {chance = 0.009, item = "sharkboi"}, --大霜鲨
    -- {chance = 0.009, item = "worm_boss"}, --巨大洞穴蠕虫
    {chance = 0.005, item = "ruinsnightmare"}, --潜伏梦魇
    {chance = 0.008, item = "rabbitking_aggressive"}, --暴戾兔王
    
    default = {announce = true, sleeper = true}, -- 其他选项设置, 默认设置
}
-- 建筑表: 建筑、基建物品、不可移植植物
loots.builds = {
    {chance = 0.1, item = {"mushroombomb","mushroombomb_dark"}},--炸弹蘑菇\悲惨的炸弹蘑菇 
    {chance = 0.05, item = "houndfire"}, --火
    {chance = 0.15, item = "tornado"},--龙卷风
    {chance = 0.04, item = "sporecloud"}, --孢子云
    {chance = 0.09, item = "sandspike"}, --沙刺
    {chance = 0.09, item = "sandblock"}, --沙堡
    {chance = 0.05, item = "alterguardian_laser", eventF = p_events.alterguardian_laser}, --天体激光
    {chance = 0.03, item = {"alterguardian_phase3trapprojectile","alterguardian_phase3trap"}}, --启迪陷阱
    {chance = 0.03, item = "deciduous_root"}, --桦栗树 鞭子
    {chance = 0.01, item = "fused_shadeling_quickfuse_bomb"}, --绝望螨 不分裂
    {chance = 0.04, item = "ruins_cavein_obstacle"}, --块状废墟
    {chance = 0.02, item = "shadowmeteor"}, --流星
    {chance = 0.09, item = "fossilspike"},--化石笼子
    {chance = 0.1, item = "fossilspike2"},--化石骨刺
    {chance = 0.006, item = {"rabbithole","molehill","tallbirdnest"}, announce = true},--兔子鼹鼠洞高脚鸟巢
    {chance = 0.1, item = "carrat_planted"},--胡萝卜鼠
    {chance = 0.03, item = {"skeleton","houndbone","dead_sea_bones"}},--骷髅、犬骨、海鱼骨
    {chance = 0.05, item = {"pighead","mermhead"}},--猪头、鱼人头
    {chance = 0.01, item = {"driftwood_tall","driftwood_tall1","driftwood_tall2"}},--浮木桩
    {chance = 0.02, item = {"chessjunk","chessjunk1","chessjunk2","chessjunk3"}},--损坏的发条装置
    {chance = 0.042, item = {"stalagmite_tall","stalagmite","rock_flintless","rock2","moonglass_rock","rock_moon","penguin_ice"}},--矿
    {chance = 0.01, item = {"statuemaxwell","marblepillar","statueharp","statue_marble_pawn","statue_marble","statue_marble_muse","marbletree"}},--大理石雕像
    {chance = 0.04, item = {"asparagus_oversized","carrot_oversized","corn_oversized","dragonfruit_oversized","durian_oversized","eggplant_oversized","garlic_oversized","onion_oversized","pepper_oversized","pomegranate_oversized","potato_oversized","pumpkin_oversized","tomato_oversized","watermelon_oversized"}},--巨型蔬菜
    {chance = 0.004, item = "saltstack", announce = true, pack = true},--盐堆
    {chance = 0.004, item = "seastack", announce = true, pack = true},--浮堆
    {chance = 0.02, item = "shell_cluster"},--贝壳堆
    {chance = 0.02, item = "sunkenchest", announce = true, eventF = p_events.sunkenchest},--沉底宝箱
    {chance = 0.009, item = "klaus_sack", announce = true, pack = true},--克劳斯袋
    {chance = 0.008, item = "ruins_statue_mage", announce = true, pack = true}, --远古雕像
    {chance = 0.009, item = "archive_moon_statue", announce = true, pack = true}, --远古月亮雕像
    {chance = 0.001, item = "moonbase", announce = true, pack = true, pack_chance = .9}, --月亮石
    {chance = 0.004, item = "resurrectionstone", announce = true, pack = true}, --复活石
    {chance = 0.004, item = "pigking", announce = true, pack = true, pack_chance = .9}, --猪王
    {chance = 0.004, item = {"ancient_altar","ancient_altar_broken"}, announce = true, pack = true, pack_chance = .85}, --远古伪科学站
    {chance = 0.001, item = "archive_cookpot", announce = true, pack = true}, --远古锅
    {chance = 0.001, item = "nightmaregrowth", announce = true, pack = true, pack_chance = 1}, --梦魇城墙
    {chance = 0.001, item = "atrium_idol", announce = true, pack = true}, --远古方尖碑1
    {chance = 0.001, item = "atrium_overgrowth", announce = true, pack = true}, --远古方尖碑2
    {chance = 0.002, item = "monkeybarrel", announce = true}, -- 猴子桶
    {chance = 0.002, item = "catcoonden", announce = true}, --中空树桩
    {chance = 0.002, item = "walrus_camp", announce = true}, --海象营地
    {chance = 0.002, item = "pigtorch", announce = true}, -- 猪人火炬
    {chance = 0.002, item = "houndmound", announce = true}, -- 猎犬丘
    {chance = 0.003, item = "oceanvine_cocoon", announce = true}, -- 海蜘蛛巢穴
    {chance = 0.002, item = "wasphive", announce = true}, -- 杀人蜂巢
    {chance = 0.004, item = "beehive", announce = true}, -- 蜂窝
    {chance = 0.0065, item = "pond", announce = true, pack = true},-- 青蛙池塘
    {chance = 0.0025, item = "pond_cave", announce = true, pack = true},-- 鳗鱼池塘
    {chance = 0.005, item = "grotto_pool_small", announce = true, pack = true,  eventA = p_events.grotto_pool_small},--小月亮玻璃池
    {chance = 0.0075, item = "pond_mos", announce = true, pack = true},--蚊子池塘
    {chance = 0.0035, item = "lava_pond", announce = true, pack = true},--熔岩池
    {chance = 0.005, item = "moon_fissure", announce = true, pack = true},--天体裂缝
    {chance = 0.0015, item = "hotspring", announce = true, pack = true},--温泉
    -- {chance = 0.003, item = "oasislake", announce = true, eventA = p_events.oasislake},--湖泊
    {chance = 0.003, item = "oasislake", announce = true, pack = true, pack_chance = 1},--湖泊
    {chance = 0.008, item = {"cactus","oasis_cactus"}, pack = true},--仙人掌植株
    {chance = 0.008, item = {"blue_mushroom","green_mushroom","red_mushroom"}, pack = true},--蘑菇植株
    {chance = 0.008, item = "wormlight_plant"},--神秘植物    
    {chance = 0.007, item = "lichen"},--洞穴苔藓    
    {chance = 0.008, item = "reeds"},--芦苇植株
    {chance = 0.008, item = "bananabush"},--香蕉丛植株
    {chance = 0.008, item = "monkeytail"},--猴尾草植株
    {chance = 0.008, item = "oceanvine", pack = true},--苔藓藤条植株
    {chance = 0.008, item = {"palmconetree_short","palmconetree_normal","palmconetree_tall"}},--棕榈树
    {chance = 0.008, item = {"flower_cave_triple","flower_cave_double","flower_cave","lightflier_flower"}, pack = true}, -- 荧光花
    {chance = 0.008, item = {"evergreen","deciduoustree_normal","moon_tree_tall","cave_banana_tree","mushtree_medium","mushtree_small","mushtree_tall","mushtree_moon","mushroomsprout","mushroomsprout_dark","oceantree"}},--树  
    {chance = 0.004, item = "wobster_den", pack = true}, -- 龙虾窝
    {chance = 0.004, item = "moonglass_wobster_den", pack = true}, -- 月光玻璃窝
    {chance = 0.002, item = "gingerbreadhouse", pack = true}, -- 姜饼猪屋
    {chance = 0.002, item = "cavelight", name = "洞穴光", pack = true}, -- 洞穴光
    {chance = 0.1, item = "moonspider_spike"},--月亮蜘蛛钉
    {chance = 0.1, item = "trap_teeth_maxwell"},--麦斯威尔的犬牙陷阱
    {chance = 0.075, item = "beemine_maxwell"},--麦斯威尔的蚊子陷阱
    {chance = 0.04, item = "sewing_mannequin",eventF = p_events.sewing_mannequin},--假人
    -- 概率不一样就不放一起了
    {chance = 0.01, item = "treasurechest", eventF = p_events.chest},--木箱
    {chance = 0.003, item = "pandoraschest", eventF = p_events.chest},--华丽宝箱
    {chance = 0.003, item = "dragonflychest", eventF = p_events.chest},--龙鳞宝箱
    {chance = 0.001, item = "minotaurchest", eventF = p_events.chest},--大号华丽箱子

    {chance = 0.001, item = "lunarrift_crystal_big", pack = true}, --裂隙晶体 大
    {chance = 0.005, item = "lunarrift_crystal_small", pack = true}, --裂隙晶体 小
    {chance = 0.001, name = "家具", item = {"mushroom_farm","cookpot","icebox","lightning_rod","meatrack_hermit","firepit", "saltbox", "siestahut", "dragonflyfurnace"}, pack = true}, --蘑菇农场、烹饪锅、冰箱、避雷针、晾肉架、火坑
    {chance = 0.006, item = "nightmarelight", announce = true, pack = true},--梦魇灯座
    {chance = 0.005, item = {"fissure","fissure_lower","fissure_grottowar"}, pack = true},--梦魇裂缝
    {chance = 0.001, item = "dropperweb", pack = true},--悬蛛网
    {chance = 0.013, item = "staffcoldlight"},--极光
    {chance = 0.01, item = {"stafflight","emberlight"}},--矮星、火球术
    {chance = 0.014, item = "waterplant_baby", pack = true},--海芽 (会长大)
    {chance = 0.03, item = "cave_fern"},--蕨类植物 
    {chance = 0.001, item = "mound"},--坟墓
    {chance = 0.008, item = {"ruinsrelic_bowl", "ruinsrelic_chair", "ruinsrelic_chipbowl", "ruinsrelic_plate", "ruinsrelic_table", "ruinsrelic_vase"}},--遗物复制品
    {chance = 0.008, item = {"ruins_plate", "ruins_bowl", "ruins_chair", "ruins_chipbowl", "ruins_vase", "ruins_table"}},--遗物
    {chance = 0.001, item = "stagehand", announce = true},--舞台
    {chance = 0.001, item = "statueglommer", announce = true, pack = true},--格罗姆雕像
    {chance = 0.008, item = {"gargoyle_werepigatk", "gargoyle_werepigdeath", "gargoyle_werepighowl", "gargoyle_hound", "gargoyle_hounddeath"}},--可疑的月岩
    {chance = 0.008, item = {"boatfragment03", "boatfragment04", "boatfragment05"}},--船碎片
    {chance = 0.008, item = "oceanfishableflotsam"},--海洋残骸
    {chance = 0.05, item = "miasma_cloud", name = "瘴气"}, --瘴气
    {chance = 0.05, item = "daywalker_sinkhole", eventF = function(inst) inst:DoTaskInTime(60*4, inst.Remove) end}, --坑
    {chance = 0.0005, item = "oceantree_pillar", announce = true, pack = true, pack_chance = 1}, --大型疙瘩树 
    {chance = 0.006, item = "slurtlehole", pack = true}, --蛞蝓龟窝 
    {chance = 0.003, item = "moonspiderden", pack = true}, --破碎蜘蛛洞 
    {chance = 0.001, item = {"pighouse", "rabbithouse", "mermhouse"}, pack = true}, --猪屋 兔屋 漏雨的小屋
    {chance = 0.045, item = "junk_pile"}, --垃圾堆 
    {chance = 0.0005, item = "lunarthrall_plant", pack = true, pack_chance = 1}, --致命亮茄 包裹 
    {chance = 0.01, item = "pigking", announce = true, eventF = p_events.pigking}, --暗影猪王
    {chance = 0.01, item = "gambling_of", announce = true}, --赌博机
    {chance = 0.0005, item = "ancienttree_gem", pack = true, pack_chance = 1}, --萌芽石 包裹 
    {chance = 0.0005, item = "ancienttree_nightvision", pack = true, pack_chance = 1}, --阴郁之棘 包裹 
    {chance = 0.07, item = "rabbitkinghorn_chest"}, --便携式巢穴 
    {chance = 0.01, item = {"punchingbag_lunar", "punchingbag_shadow"}},--拳击袋
    {chance = 0.01, item = "medal_cookpot", announce = true, pack = true},--红晶锅
    {chance = 0.01, item = "medal_waterpump", announce = true, pack = true}, --手摇深井泵
    {chance = 0.005, item = "bearger_chest", announce = true, pack = true},--熊皮宝箱
    {chance = 0.05, item = "immortal_fruit_oversized", announce = true},--巨型不朽果实
    {chance = 0.005, item = "medal_shroom_chest", announce = true, pack = true},--蛤皮宝箱
    {chance = 0.01, item = "medal_firepit_obsidian", announce = true, pack = true},--红晶火坑
    {chance = 0.01, item = "medal_coldfirepit_obsidian", announce = true, pack = true},--蓝晶火坑
    {chance = 0.01, item = "medal_ice_machine", announce = true, pack = true},--蓝晶制冰机
    {chance = 0.01, item = "medal_rose_terrace", announce = true, pack = true},--蔷薇花台
    {chance = 0.01, item = "medal_beequeenhivegrown", announce = true, pack = true},--凋零蜂巢
    {chance = 0.01, item = "medal_beebox", announce = true, pack = true},--育王蜂箱
    {chance = 0.01, item = "medal_seapond", announce = true, pack = true},--船上钓鱼池
    {chance = 0.01, item = "medal_treasure", announce = true},--神秘土堆
    {chance = 0.001, item = "medal_spacetime_treasure", announce = true},--时空宝藏
    {chance = 0.001, item = "medal_dustmothden", announce = true, pack = true},--时空尘蛾窝
    {chance = 0.01, item = "medal_gift_fruit_oversized", announce = true},--巨型包果
    {chance = 0.001, item = "medal_origin_tree", announce = true, pack = true},--本源之树
    {chance = 0.005, item = "siving_turn", announce = true, pack = true},--子圭·育
    {chance = 0.01, item = "pot_whitewood", announce = true, pack = true}, --稀有基质培植盆
    {chance = 0.01, item = "chest_whitewood_big", announce = true, pack = true}, --白木展示柜
    {chance = 0.01, item = "chest_whitewood", announce = true, pack = true}, --白木展示台
    {chance = 0.005, item = "pond_l_mud", announce = true, pack = true}, --澄澈泥泉
    {chance = 0.01, item = "pond_l_mud_s", announce = true, pack = true}, --泥泉
    {chance = 0.01, item = "pondbldg_soak", announce = true, pack = true}, --澡花壳
    {chance = 0.01, item = "pondbldg_fish", announce = true, pack = true}, --鱼栖壳
    {chance = 0.005, item = "shyerrycore", announce = true, pack = true}, --颤栗树之心
    {chance = 0.01, item = "shyerrycore_planted", announce = true, pack = true}, --不正常的颤栗树之心
    {chance = 0.001, item = "pond_l_smoke", announce = true, pack = true}, --气熏温泉
    {chance = 0.01, item = "pond_l_smoke_s", announce = true, pack = true}, --气熏温泉
    {chance = 0.001, item = "moondungeon", announce = true, pack = true}, --月的地下城
    {chance = 0.001, item = "siving_thetree", announce = true, pack = true}, --子圭神木岩
    {chance = 0.001, item = "elecourmaline", announce = true, pack = true}, --电气重铸台

    -- tree_rock 巨石枝
    default = {
        build = build,
    }
}

-- 科技类: 草图、蓝图等图纸
loots.technology = {
    {chance = 0.005, item = "cookingrecipecard"}, --食谱卡
    {chance = 0.01, item = "scrapbook_page"}, --丢失的图鉴页面 
    {chance = 0.17, item = "blueprint"}, --蓝图
}
-----------------------------------------------------------------------------------------
-- 添加两种加调料的食物集
local preparedfoods = {}
local preparedfoods_spice = {}
local preparedfoods_warly = {}
local preparedfoods_warly_spice = {}
-- 添加普通料理
for k, v in pairs(require("preparedfoods")) do
    -- table.insert(loots.foods,{chance = 0.04, item = v.name})
    table.insert(preparedfoods, v.name)
    -- -- 添加调料
    table.insert(preparedfoods_spice, v.name.."_spice_garlic") --蒜
    table.insert(preparedfoods_spice, v.name.."_spice_sugar") --糖
    table.insert(preparedfoods_spice, v.name.."_spice_chili") --辣椒
    table.insert(preparedfoods_spice, v.name.."_spice_salt") --盐
end
-- 添加大厨料理
for k, v in pairs(require("preparedfoods_warly")) do
    -- table.insert(loots.foods,{chance = 0.01, item = v.name})
    table.insert(preparedfoods_warly, v.name)
    -- -- 添加调料
    table.insert(preparedfoods_warly_spice, v.name.."_spice_garlic") --蒜
    table.insert(preparedfoods_warly_spice, v.name.."_spice_sugar") --糖
    table.insert(preparedfoods_warly_spice, v.name.."_spice_chili") --辣椒
    table.insert(preparedfoods_warly_spice, v.name.."_spice_salt") --盐
end
table.insert(loots.foods,{chance = 0.12, item = preparedfoods})
table.insert(loots.foods,{chance = 0.05, item = preparedfoods_spice})
table.insert(loots.foods,{chance = 0.08, item = preparedfoods_warly})
table.insert(loots.foods,{chance = 0.01, item = preparedfoods_warly_spice})
table.insert(loots.foods,{chance = 0.01, item = {"yotr_food1","yotr_food2","yotr_food3","yotr_food4"}})--兔年食物
table.insert(loots.foods,{chance = 0.01, item = "carnivalfood_corntea"})--玉米泥
table.insert(loots.foods,{chance = 0.01, item = "ipecacsyrup"})--土根糖浆
table.insert(loots.foods,{chance = 0.035, item = "gift", name = "料理礼包", eventF = p_events.gift, 
            parameter = function()
                local loot1 = deepcopy(preparedfoods)
                local loot2 = deepcopy(preparedfoods_warly)
                for k,v in pairs(loot2) do
                    table.insert(loot1, v)
                end
                return loot1
            end
        })
table.insert(loots.foods,{chance = 0.015, item = "gift", name = "调味料理礼包", eventF = p_events.gift, 
            parameter = function()
                local loot1 = deepcopy(preparedfoods_spice)
                local loot2 = deepcopy(preparedfoods_warly_spice)
                for k,v in pairs(loot2) do
                    table.insert(loot1, v)
                end
                return loot1
            end
        })
table.insert(loots.foods,{chance = 0.35, item = "gift", name = "食材礼包", eventF = p_events.gift, 
            parameter = function()
                local loot1 = {}
                for k,v in pairs(loots.ingredients) do
                    if type(v.item) == "table" then
                        for _,prefab in pairs(v.item) do
                            table.insert(loot1, prefab)
                        end
                    else
                        table.insert(loot1, v.item)
                    end
                end
                return loot1
            end
        })

--carnivalfood_corntea

--雕像草图
local sketch = {
    "chesspiece_pawn_sketch",
    "chesspiece_rook_sketch",
    "chesspiece_knight_sketch",
    "chesspiece_bishop_sketch",
    "chesspiece_muse_sketch",
    "chesspiece_formal_sketch",
    "chesspiece_deerclops_sketch",
    "chesspiece_bearger_sketch",
    "chesspiece_moosegoose_sketch",
    "chesspiece_dragonfly_sketch",
    "chesspiece_clayhound_sketch",
    "chesspiece_claywarg_sketch",
    "chesspiece_butterfly_sketch",
    "chesspiece_anchor_sketch",
    "chesspiece_moon_sketch",
    "chesspiece_carrat_sketch",
    "chesspiece_malbatross_sketch",
    "chesspiece_crabking_sketch",
    "chesspiece_toadstool_sketch",
    "chesspiece_stalker_sketch",
    "chesspiece_klaus_sketch",
    "chesspiece_beequeen_sketch",
    "chesspiece_antlion_sketch",
    "chesspiece_minotaur_sketch", 
    "chesspiece_beefalo_sketch",
    "chesspiece_guardianphase3_sketch",
    "chesspiece_eyeofterror_sketch",
    "chesspiece_twinsofterror_sketch",
    "chesspiece_kitcoon_sketch",
    "chesspiece_catcoon_sketch",
    "chesspiece_manrabbit_sketch",
}
--渔具广告
local tacklesketch = {
    "oceanfishingbobber_ball_tacklesketch",
    "oceanfishingbobber_oval_tacklesketch",
    "oceanfishingbobber_crow_tacklesketch",
    "oceanfishingbobber_robin_tacklesketch",
    "oceanfishingbobber_robin_winter_tacklesketch",
    "oceanfishingbobber_canary_tacklesketch",
    "oceanfishingbobber_goose_tacklesketch",
    "oceanfishingbobber_malbatross_tacklesketch",
    "oceanfishinglure_hermit_drowsy_tacklesketch",
    "oceanfishinglure_hermit_rain_tacklesketch",
    "oceanfishinglure_hermit_heavy_tacklesketch",
    "oceanfishinglure_hermit_snow_tacklesketch",
}
table.insert(loots.technology,{chance = 0.002, item = sketch})
table.insert(loots.technology,{chance = 0.003, item = tacklesketch})

-- 各种材质的雕像
local chesspieces = {}
local PIECES = {"pawn", "rook", "knight", "bishop", "muse", "formal", "hornucopia", "pipe", "deerclops", "bearger", "moosegoose", "dragonfly", "clayhound", "claywarg", "butterfly", "anchor", "moon", "carrat", "beefalo", "crabking", "malbatross", "toadstool", "stalker", "klaus", "beequeen", "antlion", "minotaur", 
"guardianphase3", "eyeofterror", "twinsofterror", "kitcoon", "catcoon", "manrabbit", "daywalker", "deerclops_mutated", "bearger_mutated", "warg_mutated"}
local MATERIALS ={"marble", "stone", "moonglass"}
local function makepiece(pieceid, materialid)
    return materialid and ("chesspiece_"..PIECES[pieceid].."_"..MATERIALS[materialid]) or ("chesspiece_"..PIECES[pieceid])
end
for p = 1,#PIECES do
    table.insert(chesspieces, makepiece(p))
    for m = 1,#MATERIALS do
        table.insert(chesspieces, makepiece(p, m))
    end
end
table.insert(loots.equipments,{chance = 0.009, item = chesspieces})
----------------------------------------------------------------------------------------------------
--[[测试用--]]
-- loots = {
--     xxxx = {
--     {chance = 0.007, item = "player_hosted", eventF = p_events.player_hosted},--被附身的尸体
--     -- {chance = 0.01, item = huge_fruits_loot}, --种植的作物
--     -- {chance = 0.01, item = "fishingsurprised", name= "硕果累累", eventF = events.fruits, parameter = huge_fruits_loot},--硕果累累
--     -- {chance = 0.001, item = "statueglommer", announce = true, pack = true},--格罗姆雕像
--     -- {chance = 0.02, item = "fishingsurprised", name= "提线木偶", eventF = events.puppet},--提线木偶
--     -- {chance = 0.015, item = "fishingsurprised", name= "控制傀儡", eventF = events.puppet_boss},--控制傀儡
--     -- {chance = 0.001, item = "fishingsurprised", name= "季节变化", eventF = events.seasonchange},--季节变化
--     -- {chance = 0.01, item = "fishingsurprised", name= "蠕虫来袭", eventF = events.worm_attack},--蠕虫来袭
--     -- {chance = 0.01, item = "fishingsurprised", name= "恶液雨", eventF = events.playerdata},--蠕虫来袭
--         -- {chance = 0.05, item = "dreadstone"},-- 绝望石
--     -- {chance = 0.003, item = "shadowheart_infused", announce = true},--附身暗影心房
--     -- {chance = 0.015, item = "rabbitkingminion_bunnyman"},--皇家兔子警卫
--     -- {chance = 0.001, item = "itemmimic_revealed"},--拟态蠕虫
--     -- {chance = 0.001, item = "gelblob"},--恶液
--     -- {chance = 0.001, item = "chest_mimic_revealed"},--暴躁箱子
--     -- {chance = 0.07, item = "rabbitkinghorn_chest"}, --便携式巢穴 
--         --junk_pile 垃圾堆 scraphat 拾荒尖帽 fishingnet 渔网 portabletent_item 帐篷卷
--         -- {chance = 0.007, item = "fishingsurprised", name= "上次事件", eventF = events.previousF, eventA = events.previousA},--森林怒火\
--         -- {chance = 0.005, item = "fishingsurprised", name= "单向生命链接", eventF = events.deathrattle_of},
--     -- {chance = 0.009, item = "worm_boss", eventF = function(item, fisher, target, parameter) 
--     --     item.Transform:SetPosition(fisher.Transform:GetWorldPosition())
--     -- end}, --巨大洞穴蠕虫
--     -- {chance = 0.009, item = "ruinsnightmare"}, --潜伏梦魇
--     -- {chance = 0.009, item = "rabbitking_aggressive"}, --暴戾兔王
--     -- {chance = 0.007, item = "shadowthrall_mouth", name= "墨荒·山"}, --墨荒·蛇 山
--         -- {chance = 0.01, item = "fishingsurprised", name= "提线木偶", eventF = events.puppet_boss},--
--         -- {chance = 0.09, item = "fishingsurprised", name= "卧槽！冰", eventF = events.oceanice},--卧槽！冰
--         -- {chance = 0.001, item = {"pighouse", "rabbithouse", "mermhouse"}, pack = true}, --猪屋 兔屋 漏雨的小屋
--         -- {chance = 0.01, item = "pigking", announce = true, eventF = p_events.pigking}, --猪王
--         -- {chance = 0.058, item = {"wilson","wortox","wendy","willow","wickerbottom","waxwell","webber","wes","winona","woodie","wormwood","wurt","warly","wathgrithr","wolfgang","wx78","walter","wanda"},announce = true, eventF = p_events.getplayer},--人物 算为事件
--         default = {
--             announce = true,
--             -- sleeper = false,
--         }
--     },
-- }
-- sharkboi_icespike 冰 crabking_icewall 冰障
-- --chestupgrade_stacksize 弹性空间制造器

return loots