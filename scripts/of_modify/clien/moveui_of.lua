-- 存储UI坐标
local OCEANFISHIN_UI_DATA = {}

local is_save = false
local function loadingUIpos()
    TheSim:GetPersistentString("oceanfishin_ui_data", function(load_success, data)
        if load_success and data ~= nil then
            local success, allpos = RunInSandbox(data)
            if success and allpos then
                for k, v in pairs(allpos) do
                    if OCEANFISHIN_UI_DATA[k] == nil then
                        OCEANFISHIN_UI_DATA[k] = {x = v.x or 0, y = v.y or 0}
                    end
                end
            end
        end
    end)
end

-- 停止移动时
local function CeaseMove(self)
    if self.move_task then --移除任务
        self.move_task:Remove()
        self.move_task = nil
    end

    local pos = self.moveui_name and self:GetPosition() or nil
    if pos then
        OCEANFISHIN_UI_DATA[self.moveui_name] = {x = pos.x, y = pos.y}
    end
    -- 需要保存数据
    is_save = true

end

-- 鼠标右键移动时
local function OnMove(self, control, down)
    if down then --按住
        -- 开始拖动
        if not self.move_task then --存在移动任务处理器吗
            -- 记录初始时鼠标位置 和 ui位置 还有父级的缩放
            local ui_pos = self:GetPosition()
            local mouse_pos = TheInput:GetScreenPosition()
            local scale = self.parent:GetScale()

            self.move_task = TheInput:AddMoveHandler(function(x,y)
                -- 设置坐标
                local mouse_delta = Vector3(x, y, 0)-mouse_pos
                self:SetPosition(ui_pos.x+mouse_delta.x/scale.x, ui_pos.y+mouse_delta.y/scale.y, 0)
                if control ~= CONTROL_SECONDARY then --TheSim:IsKeyDown(CONTROL_SECONDARY)
                    -- 停止
                    CeaseMove(self)
                end
            end)
        end
    else
        -- 停止拖动
        CeaseMove(self)
    end
end
local function OnControl(self, control, down)
    if control == CONTROL_SECONDARY then --聚焦 且 右键时
        OnMove(self, control, down)
    end
    return self.oldOnControl and self:oldOnControl(control, down)
end

-- 注册 移动ui 需要像按钮一样可以被聚焦的Widget
GLOBAL.MoveUI_of = function(self)
    -- 初始化坐标
    local pos = self.moveui_name and OCEANFISHIN_UI_DATA[self.moveui_name] or nil
    if pos then --说明已经改动好了的值 那么直接赋值就行
        self:SetPosition(pos.x, pos.y)
    end
    if self.oldOnControl then return end
    self.oldOnControl = self.OnControl
    self.OnControl = OnControl
end

-- 加载数据
loadingUIpos()
-- 保存游戏时保存
AddPrefabPostInit("forest_network",function(inst)
    inst:ListenForEvent("issavingdirty", function()
        if is_save then
            TheSim:SetPersistentString("oceanfishin_ui_data", DataDumper(OCEANFISHIN_UI_DATA, nil, true), false)
            is_save = false
        end
    end)
end)

-- local Widget = require "widgets/widget"
-- -- 自定义等待面板
-- local WaPanel = Class(Widget, function(self, owner) --owner 大厅界面
--     Widget._ctor(self, "WaPanel")
--     self.title = "选择队伍"
--     self.next_button_title = STRINGS.UI.LOBBYSCREEN.NEXT
-- end)

-- AddClassPostConstruct("screens/redux/lobbyscreen", function(self)
--     table.insert(self.panels, 1, {panelfn = WaPanel}) --等待界面

--     self.current_panel_index = 0
--     -- 加载第一个界面
--     self:ToNextPanel(1)
-- end)



-- local function PickSome_of(num, choices)
--     local l_choices = choices
--     local ret = {}
--     -- for i=1,num do
--     --     local choice = 1--math.random(#l_choices)
--     --     table.insert(ret, l_choices[choice])
--     --     table.remove(l_choices, choice)
--     -- end
--     local function xx(i)
--         local choice = i
--         table.insert(ret, l_choices[choice])
--         table.remove(l_choices, choice)
--     end
--     -- xx(52)
--     -- xx(39)
--     -- xx(26)
--     -- xx(13)
--     -- xx(12)
--     xx(52)
--     xx(51)
--     xx(50)
--     xx(49)
--     xx(48)
--     return ret
-- end

-- local BALATRO_UTIL = require("prefabs/balatro_util")
-- AddPrefabPostInit("balatro_machine", function(inst)
--     if inst.components.activatable then
--         inst.components.activatable.OnActivate = function(inst, doer)
--             inst.components.talker:ShutUp()

--             inst.rewarding = true
            
--             inst._currentgame.user = doer --玩家
--             inst._currentgame.round = 1 -- 第n个丢牌选牌阶段 为3
--             inst._currentgame.joker = nil -- 玩家选择的小丑牌
--             inst._currentgame.jokerchoices = PickSome(BALATRO_UTIL.NUM_JOKER_CHOICES, shallowcopy(BALATRO_UTIL.AVAILABLE_JOKERS)) -- These are strings. --随机挑选3张小丑牌
--             inst._currentgame.carddeck = shallowcopy(BALATRO_UTIL.AVAILABLE_CARDS) -- These are card IDs, not IDs. --复制全部牌 key是排序 value是卡值对应的

--             inst._currentgame.selectedcards = PickSome_of(BALATRO_UTIL.NUM_SELECTED_CARDS, inst._currentgame.carddeck) -- These are card IDs, not IDs. --随机挑选5张初始牌
--             inst._currentgame._lastselectedcards = shallowcopy(inst._currentgame.selectedcards) --复制一份 初始牌作为上次牌

--             inst:ListenForEvent("onremove", inst.ondoerremoved, doer)
--             inst:ListenForEvent("ms_closepopup", inst.onclosepopup, doer)
--             inst:ListenForEvent("ms_popupmessage", inst.onpopupmessage, doer)

--             doer.sg:GoToState("playingbalatro", { target = inst })
--         end
--     end
-- end)