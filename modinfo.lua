name = "海钓随机物品-模组物品补丁"
description = "海钓补丁：增加空军事件次数，可选增加勋章和棱镜物品。"
author = "StellarVoyage"
version = "1.0.1"
api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false
-- Must be lower than the original OceanFishing mod (-9998), so its island
-- layouts are registered before this dependency patch appends extra prefabs.
-- Also keep it lower than optional island mods such as Witch Journey, so this
-- patch can remove or override their ocean_prefill_setpieces after they add them.
priority = -100000

icon_atlas = "fishingrod-ModPatch.xml"
icon = "fishingrod-ModPatch.tex"

mod_dependencies = {
    { workshop = "workshop-2710978964" },
}

configuration_options = {
    -- Add new mod loot switch here.
    -- Template:
    -- {
    --     name = "enable_xxx",
    --     label = "增加XXX物品",
    --     hover = "是否在海钓中加入XXX模组的物品",
    --     options = {
    --         {description = "开启", data = true},
    --         {description = "关闭", data = false},
    --     },
    --     default = true,
    -- },
    {
        name = "event_times",
        label = "空军触发事件次数",
        hover = "设置一次空军触发的事件数量",
        options = {
            {description = "1次", data = 1},
            {description = "2次", data = 2},
            {description = "3次", data = 3},
            {description = "4次", data = 4},
            {description = "5次", data = 5},
        },
        default = 3,
    },
    {
        name = "enable_medal",
        label = "增加勋章物品",
        hover = "是否在海钓中加入勋章模组的物品",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false},
        },
        default = true,
    },
    {
        name = "enable_prismatic",
        label = "增加棱镜物品",
        hover = "是否在海钓中加入棱镜模组的物品",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false},
        },
        default = true,
    },
    {
        name = "enable_yyxk_build",
        label = "增加夜雨心空非制作物品（星光之晶和魔力花）",
        hover = "是否在世界生成中加入夜雨心空非制作物品（星光之晶和魔力花）的物品",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false},
        },
        default = true,
    },
    {
        name = "enable_star_monv",
        label = "增加魔女老师",
        hover = "是否在世界生成中魔女老师",
        options = {
            {description = "开启", data = true, hover = "在档案馆生成老师"},
            {description = "关闭", data = false, hover = "不在档案馆生成老师"},
        },
        default = true,
    },
    {
        name = "enable_error_prone_events",
        label = "启用易报错事件",
        hover = "是否加入旧补丁注释掉的原模组事件：healthlink、removeitems、transformation、black_hole、puppet_boss、playerdata",
        options = {
            {description = "关闭", data = false},
            {description = "开启", data = true},
        },
        default = false,
    },
}
