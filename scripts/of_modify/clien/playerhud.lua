local TEMPLATES = require "widgets/redux/templates" --UI控件库
local Information = require "screens/oceanfishinginformation_of" --钓鱼信息界面
local Widget = require "widgets/widget"
local Image = require "widgets/image"
AddClassPostConstruct("screens/playerhud", function(self)
    -- 需要通过按钮显示出来
    self.oceanfishin_button = self.root:AddChild(TEMPLATES.StandardButton(function() self:ShowTarnsferPanel() end, "鱼", {50, 50}))
    self.oceanfishin_button:SetPosition(1567,947)
    -- self.oceanfishin_button:SetVAnchor(1)
    -- self.oceanfishin_button:SetHAnchor(1)
    self.oceanfishin_button:Show()
    self.oceanfishin_button:SetHoverText("右键按住拖动")
    -- 注册移动UI
    self.oceanfishin_button.moveui_name = "界面开关按钮"
    MoveUI_of(self.oceanfishin_button)

    -- 显示面板
    self.ShowTarnsferPanel = function(self, attach)
        self:CloseTarnsferPanel()
        self.oceanfishinginformation_of = Information(self.owner)
        self:OpenScreenUnderPause(self.oceanfishinginformation_of) --使用HUD自带的推送屏幕方法 兼容暂停服务器屏幕
        return true
    end
    -- 关闭面板
    self.CloseTarnsferPanel = function(self)
        if self.oceanfishinginformation_of ~= nil then
            if self.oceanfishinginformation_of.inst:IsValid() then
                TheFrontEnd:PopScreen(self.oceanfishinginformation_of) --弹出屏幕
            end
            self.oceanfishinginformation_of = nil
        end
    end

    -- self.inst:DoTaskInTime(1,function()
    --     self.mousefollow = self.controls:AddChild(Widget("follower"))
    --     self.mousefollow:FollowMouse(true)
    --     self.mousefollow:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --     self.of_xxx = self.mousefollow:AddChild(Image("images/hud.xml", "slot_select.tex"))
    --     self.of_xxx.OnGainFocus = function()
    --         self.of_xxx:SetTooltip("\n这是提示词哟") 
    --     end

    --     self.inst:DoTaskInTime(5,function()
    --         self.of_xxx:SetClickable(false) --设置为不能点击的 那么 TheInput:GetAllEntitiesUnderMouse() 就不会获取到
    --     end)
    -- end)
end)

-- AddClassPostConstruct("widgets/inventorybar", function(self) 
--     self.OnNewActiveItem = createHookedFunction(self.OnNewActiveItem, function(self, item)
--         print(string.format("手拿：新物品[%s], 旧物品[%s]", tostring(item), tostring(self.hovertile and self.hovertile:GetDescriptionString())))
--         return true
--     end)

--     self.OnItemGet = createHookedFunction(self.OnItemGet, function(self, item, slot, source_pos, ignore_stacksize_anim) 
--         if slot then
--             print("设置UI格子内容(物品-格子-坐标)", item, slot.num, source_pos and source_pos:Get())
--         end
--         return true
--     end)
--     self.OnControl = createHookedFunction(self.OnControl, function(self, control, down)
--         if control ~= 42 then
--             print("点击事件", control, down, self.active_slot and self.active_slot.num)
--         end
--         return true
--     end)
-- end)
-- AddClassPostConstruct("widgets/itemtile", function(self) 
--     self.OnGainFocus = createHookedFunction(self.OnGainFocus, function(self)
--         if GetTick()%10 == 0 then
--             print(GetTick(), self, self.item)
--         end
--         return true
--     end)
-- end)

-- AddClassPostConstruct("widgets/controls", function(self) 
--     self.OnUpdate = createHookedFunction(self.OnUpdate, function()
--         if GetTick()%30 == 0 then
--             print("提示词", self.hover.text.string)
--         end
--         return true
--     end)
-- end)

