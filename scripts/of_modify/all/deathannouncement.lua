--------------------------------------------------------------------------------------
-- 死亡宣告调整
--主、客端必须都要有不然咋显示
local death_cause = {
   OF_BLEED = "流血",
   OF_HEALTHLINK = "单向生命链接",
   OF_ONEFISTSUPERMAN = "一拳小超人",
   OF_DECIDUOUS = "桦树精的愤愤",
   OF_FOSSILSPIKE = "骨牢骨刺",
   OF_CELESTIALFURY = "天体陷阱",
   OF_GUNPOWDERCIRCLE = "火药陷阱",
   OF_ALTERGUARDIAN_LASER = "相控阵激光",
   OF_MUSHROOMBOMB = "奇妙蘑菇林",
}
for k,v in pairs(death_cause) do
    STRINGS.NAMES[k] = "【"..v.."】" --希望不会有预制体名称重复的
end

if rawget(GLOBAL, "GetNewDeathAnnouncementString") == nil then
    require "widgets/eventannouncer" --没有,再提前执行一下。
end
if rawget(GLOBAL, "GetNewDeathAnnouncementString") then
    -- 覆盖死亡宣告字符串生成方法
    local old_GetNewDeathAnnouncementString = GLOBAL.GetNewDeathAnnouncementString
    GLOBAL.GetNewDeathAnnouncementString = function(theDead, source, pkname, sourceispet)
        if source and source == "OF_HEALTHLINK" then
            local message = theDead:GetDisplayName().." "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." "..pkname.."的"..STRINGS.NAMES[source]
            local gender = GetGenderStrings(theDead.prefab)
            if STRINGS.UI.HUD["DEATH_ANNOUNCEMENT_2_"..gender] then
                message = message..STRINGS.UI.HUD["DEATH_ANNOUNCEMENT_2_"..gender] --他\她变成了可怕的鬼魂
            else
                message = message..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT --。它变成了可怕的鬼魂
            end
            return message
        end
        return old_GetNewDeathAnnouncementString(theDead, source, pkname, sourceispet)
    end
end