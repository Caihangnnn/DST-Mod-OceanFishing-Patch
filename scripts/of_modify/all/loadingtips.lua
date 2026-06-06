-------------修改提示内容-------------------------------------------------------------------------------
local MOD_TIPS = {
    CS_TIPS1 = "不仅仅有初始岛屿，出海探险吧。岛屿很多，使用瓶子信可以查看。",
    CS_TIPS2 = "玩家绑定的海钓竿没了，可以捡起另一个，会自动绑定到新海钓竿。",
    CS_TIPS3 = "正常钓鱼，不会钓起随机物品，食物缺乏钓海鱼吧。",
    CS_TIPS4 = "别在家附近钓，可能会拆家的。",
    CS_TIPS5 = "随生存时间增加，钓到boss和建筑概率会提高。前3天不会钓到boss，放心。",
    CS_TIPS6 = "化石碎片机制更改了，白天是洞穴里的【复活的骨架】",
    CS_TIPS7 = "敲掉被击败的天体英雄，会自动清理掉之前存在的召唤天体英雄的组件。",
    CS_TIPS8 = "注意月圆月黑，是独立的掉落列表。",
    CS_TIPS9 = "阅读mod代码，可以自定义地图和扩展掉落物。",
    CS_TIPS10 = "船不会着火，但会被其他方法摧毁。有些钓起事件，躲船上比较安全。",
    CS_TIPS11 = "钓到一定数量，是会奖励黄金的。",
    CS_TIPS12 = "钓起了事件，沉着冷静面对。有的时候需要静如处子，有时候需要动如脱兔。",
    CS_TIPS13 = "开启了mod设置中【浮标可影响钓起内容】，海钓竿可以接受堆叠的物品，浮标们有特殊效果，检查它。\n【树枝】也是浮标。",
    CS_TIPS14 = "注意看mod设置的描述。",
    CS_TIPS15 = "发现了具有龙蝇的岛吗?小心流星。\n夏天在这里记得带上你的帽子。",
    CS_TIPS16 = "开启了清理了，前期可以利用背包来存放物品。地面上尽量别留物品。物品是一堆一堆清理。",
    CS_TIPS17 = "这个海钓世界里，存在着一个隐藏岛屿。开启方法藏在月儿弯主人所爱之人身上。",
    CS_TIPS18 = "猪哥：在天上的时候，走着到另一个岛了。",
    CS_TIPS19 = "遇到了饥饿值无了，脚下的食物别乱吃，可得留给队友^_^。",
    CS_TIPS20 = "裂缝生成亮茄虚影，需要有【非种子阶段的作物】或者在【非初始岛的其他岛屿种植了植物】。\n即，寻找农作物或野外植物。",
}
STRINGS.UI.LOADING_SCREEN_OTHER_TIPS = STRINGS.UI.LOADING_SCREEN_OTHER_TIPS or {}
for k,v in pairs(MOD_TIPS) do
    STRINGS.UI.LOADING_SCREEN_OTHER_TIPS[k] = v
end

local tipcategorystartweights =
{
    CONTROLS = 0,
    SURVIVAL = 0,
    LORE = 0,
    LOADING_SCREEN = 0,
    OTHER = 0.2,
}

SetLoadingTipCategoryWeights(LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START, tipcategorystartweights)

local tipcategoryendweights =
{
    CONTROLS = 0,
    SURVIVAL = 0,
    LORE = 0,
    LOADING_SCREEN = 0,
    OTHER = 0.5,
}
SetLoadingTipCategoryWeights(LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_END, tipcategoryendweights)

GLOBAL.TheLoadingTips = require("loadingtipsdata")()
GLOBAL.TheLoadingTips.loadingtipweights = GLOBAL.TheLoadingTips:CalculateLoadingTipWeights()
GLOBAL.TheLoadingTips.categoryweights = GLOBAL.TheLoadingTips:CalculateCategoryWeights()
GLOBAL.TheLoadingTips:Load()
