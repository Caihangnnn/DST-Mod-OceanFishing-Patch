GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local event_times = GetModConfigData("event_times") or 3
local enable_medal = GetModConfigData("enable_medal") ~= false
local enable_legion = GetModConfigData("enable_legion") ~= false
-- Add new mod loot switch here, matching modinfo.lua.
-- Example: local enable_xxx = GetModConfigData("enable_xxx") ~= false
local enable_error_prone_events = GetModConfigData("enable_error_prone_events") == true

event_times = math.floor(tonumber(event_times) or 3)
event_times = math.max(1, math.min(event_times, 5))

local patch_logic = require("patch_logic")
local patch_events = require("patch_events")

local function CopyTable(t)
    local deepcopy_fn = rawget(GLOBAL, "deepcopy")
    return deepcopy_fn ~= nil and deepcopy_fn(t) or t
end

-- Add new mod loot table here.
-- Categories should match original loots.lua: materials, goods, equipments,
-- plant, ingredients, organisms, builds, giants, events.
-- Template:
-- xxx = {
--     materials = {
--         {chance = 0.05, item = "xxx_material"},
--         {chance = 0.01, item = "xxx_rare_item", announce = true},
--     },
--     goods = {
--         {chance = 0.05, item = {"xxx_item_a", "xxx_item_b"}},
--     },
--     builds = {
--         {chance = 0.005, item = "xxx_building", announce = true, pack = true},
--     },
-- },
-- Missing prefabs are filtered by scripts/patch_logic.lua before drawing.
-- 按分类整理模组物品
local mod_loots = {
    medal = {
        materials = {
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
        },
        goods = {
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
        },
        equipments = {
            {chance = 0.01, item = "down_filled_coat", announce = true}, --羽绒服
            {chance = 0.01, item = "hat_blue_crystal", announce = true}, --蓝晶帽
            {chance = 0.01, item = "armor_medal_obsidian", announce = true}, --红晶甲
            {chance = 0.01, item = "armor_blue_crystal", announce = true}, --蓝晶甲
            {chance = 0.005, item = "armor_medal_space_time", announce = true}, --时空晶甲
        },
        plant = {
            {chance = 0.05, item = "immortal_fruit_seed", announce = true},--不朽种子
            {chance = 0.05, item = "medal_gift_fruit_seed", announce = true},--包果种子
        },
        builds = {
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
        }
    },
    legion = {
        ingredients = {
            {chance = 0.3, item = {
                "dish_braisedmeatwithfoliages", "dish_fleshnapoleon", "dish_seedscongee", "dish_beancongee",
                "dish_mushedkoi", "dish_mushedmilk", "dish_mushedeggs", "dish_l_mooncake",
                "dish_l_flowerbun", "dish_lovingrosecake", "dish_medicinalliquor", "dish_bananamousse",
                "dish_tomahawksteak", "dish_friedfishwithpuree", "dish_sosweetjarkfruit", "dish_murmurananas",
                "dish_wrappedshrimppaste", "dish_farewellcupcake", "dish_sugarlesstrickmakercupcakes", "dish_merrychristmassalad",
                "dish_shyerryjam", "dish_duriantartare", "dish_ricedumpling", "dish_pomegranatejelly",
                "dish_roastedmarshmallows", "dish_fishjoyramen", "dish_neworleanswings", "dish_frenchsnailsbaked",
                "dish_beggingmeat", "dish_orchidcake", "dish_twistedrolllily", "dish_chilledrosejuice",
            }},--棱镜料理
            {chance = 0.3, item = {
                "bean_l_ice", "squamousfruit", "monstrain_leaf", "albicans_cap", "shyerry",
                "mint_l", "pineananas", "pineananas_cooked", "petals_orchid", "petals_lily", "petals_rose",
            }},--棱镜食材
        },
        materials = {
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
        },
        goods = {
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
            {chance = 0.05, item = "refractedmoonlight", announce = true}, --月折宝剑
            {chance = 0.005, item = "agronssword", announce = true}, --艾力冈的剑
            {chance = 0.05, item = "foliageath", announce = true}, --青枝绿叶
            {chance = 0.05, item = "lance_carrot_l", announce = true}, --胡萝卜长枪
            {chance = 0.05, item = "siving_feather_fake"}, --子圭玄鸟绒羽
            {chance = 0.05, item = "orchitwigs", announce = true}, --兰草花穗
            {chance = 0.05, item = "lileaves", announce = true}, --蹄莲翠叶
            {chance = 0.05, item = "rosorns", announce = true}, --带刺蔷薇
        },
        equipments = {
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
        },
        plant = {
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
        },
        organisms = {
            {chance = 0.01, item = "raindonate", announce = true},--雨蝇
            {chance = 0.01, item = "cropgnat"},--植害虫群
            {chance = 0.01, item = "cropgnat_infester"},--叮咬虫群
        },
        builds = {
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
        }
    }
}

local bobbers = {
    twigs = {"goods",.65}, --树枝 --禁止物品表
    oceanfishingbobber_ball = {"events",.75}, --木球浮标 --禁止事件
    oceanfishingbobber_oval = {"equipments",.75}, --硬物浮标 --禁止穿戴表
    trinket_8 = {"double",.95}, --硬化橡胶塞 --双倍钓
    oceanfishingbobber_robin = {"ingredients",.85}, --红羽浮标 --禁止食材
    oceanfishingbobber_canary = {"plant",.85}, --黄羽浮标 --禁止种植表
    oceanfishingbobber_crow = {"organisms",.85}, --黑羽浮标 --禁止生物表
    oceanfishingbobber_robin_winter = {"builds",.85}, --蔚蓝羽浮标 --禁止建筑表
    oceanfishingbobber_goose = {"materials",.9}, --鹅羽浮标 --禁止基础材料
    oceanfishingbobber_malbatross = {"giants",.9}, --邪天翁羽浮标 --禁止巨大生物表
}

-- 注入物品到 loot 表
local function PatchLoots(base_loots)
    local loots_origin = base_loots
    if loots_origin == nil then
        local success
        success, loots_origin = pcall(require, "loots")
        if not success then
            return false
        end
    end
    if type(loots_origin) ~= "table" then
        return false
    end

    -- 复制一份原有的 loot 表，防止直接修改导致不可预期的后果
    local loots = CopyTable(loots_origin)

    local patched_events = patch_events.BuildPatchedEvents(enable_error_prone_events)
    if patched_events ~= nil and #patched_events > 0 then
        loots.events = patched_events
    end

    local function inject_items(mod_name, enable_flag)
        if not enable_flag then return end
        local mod_data = mod_loots[mod_name]
        if not mod_data then return end

        for category, items in pairs(mod_data) do
            if loots[category] == nil then
                loots[category] = {}
            end
            if loots[category] then
                for _, item in ipairs(items) do
                    table.insert(loots[category], CopyTable(item))
                end
            end
        end
    end

    -- Register new mod loot injection here.
    -- Example: inject_items("xxx", enable_xxx)
    inject_items("medal", enable_medal)
    inject_items("legion", enable_legion)

    -- 设置全局变量，供 Reward 函数优先使用
    rawset(GLOBAL, "OF_HARVEST", loots)
    if patch_logic.SetLoots then
        patch_logic.SetLoots(loots)
    end
    return true
end

local function InstallLootPatch()
    PatchLoots()

    local old_Set_OF_loot = rawget(GLOBAL, "Set_OF_loot")
    if type(old_Set_OF_loot) == "function" and not rawget(GLOBAL, "OFP_Set_OF_loot_WRAPPED") then
        rawset(GLOBAL, "Set_OF_loot", function(fn, ...)
            local args = {...}
            return old_Set_OF_loot(function(t1, t2)
                if type(fn) == "function" then
                    fn(t1, t2, unpack(args))
                end
                PatchLoots(t1)
            end)
        end)
        rawset(GLOBAL, "OFP_Set_OF_loot_WRAPPED", true)
    end
end

if TheNet:GetIsServer() or TheNet:IsDedicated() then
    -- 在加载时执行一次 loot 注入
    InstallLootPatch()

    -- 钩子：修改海钓竿行为
    AddPrefabPostInit("oceanfishingrod", function(inst)
        if not TheWorld.ismastersim then return end
        
        inst:DoTaskInTime(0, function(inst)
            local rod = inst.components.oceanfishingrod
            if rod and rod.ondonefishing and not rod._OFP_ondonefishing_patched then
                rod._OFP_ondonefishing_patched = true
                local old_ondonefishing = rod.ondonefishing
                rod.ondonefishing = function(inst, reason, lose_tackle, fisher, target)
                    if reason == "reeledin" and fisher ~= nil and fisher:HasTag("player") and not fisher:HasTag("refusefish") then
                        if inst.components.container ~= nil and lose_tackle then
                            if rawget(GLOBAL, "Bobbers") then
                                inst.components.container:ConsumeByKey(1, 1)
                                inst.components.container:ConsumeByKey(2, 1)
                            else
                                inst.components.container:DestroyContents()
                            end
                        end

                        if inst.components.container ~= nil and inst.components.equippable ~= nil and inst.components.equippable.isequipped then
                            inst.components.container:Open(fisher)
                        end

                        -- 获取当前浮标数据
                        local tackle = rod.gettackledatafn and rod.gettackledatafn(inst) or {}
                        local bobber = tackle.bobber and tackle.bobber.prefab or "Not"
                        local bobber_data = rawget(GLOBAL, "Bobbers") and bobbers[bobber] or nil
                        local ban = bobber_data and bobber_data[1] or nil

                        -- 原模组和依赖模组的加载顺序可能让首次注入失败，实际奖励前再确认一次。
                        PatchLoots()

                        if inst.Reward then
                            for i = 1, event_times do
                                inst.Reward(inst, fisher, target, bobber)
                            end
                        else
                            -- 使用补丁逻辑中的 Reward 函数
                            local RewardFn = patch_logic.Reward

                            -- 执行指定次数的奖励
                            for i = 1, event_times do
                                RewardFn(inst, fisher, target, ban)
                            end

                            -- 处理双倍钓的情况
                            if ban == "double" then
                                for i = 1, event_times do
                                    RewardFn(inst, fisher, target)
                                end
                            end
                        end

                        -- 记录玩家钓鱼次数
                        if inst.AddSum then
                            inst:AddSum(fisher, target)
                        elseif fisher.components.record_of then
                            fisher.components.record_of:Add()
                        end

                        -- 浮标消耗逻辑
                        if bobber_data and bobber_data[2] < math.random() then
                            if inst.components.container then
                                inst.components.container:ConsumeByKey(1, 1)
                            end
                        end
                    else
                        -- 非空军情况，调用原逻辑
                        old_ondonefishing(inst, reason, lose_tackle, fisher, target)
                    end
                end
            end
        end)
    end)
end
