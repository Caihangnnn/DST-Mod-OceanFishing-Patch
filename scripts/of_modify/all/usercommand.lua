AddUserCommand("growgiant",{
    prettyname = "查看钓鱼数",
    desc = "会消息的形式发送",
    permission = COMMAND_PERMISSION.USER, --全部玩家
    slash = true, --碎片世界
    usermenu = false, --客户端的
    servermenu = true, --服务器上的
    menusort = 4, --排序位置
    params = {}, --参数
    -- paramsoptional = {},--对应参数列表params
    vote = false, --投票
    serverfn = function(params, caller)
        local data = TheWorld.components.worldstate.data
        local num = caller.components.record_of.number -- data.new_fishing and data.new_fishing[caller.userid] or 0
        local str = "["..caller:GetDisplayName().."] 已经钓了 "..tostring(num).."次, 距离下次奖励差"..tostring(200-num%200).."次"
        caller.components.talker:Say(str, 5) --停留5秒
    end,
})