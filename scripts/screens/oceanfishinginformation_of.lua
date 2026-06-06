local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates" --UI控件库

local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

--------------------------------------------------------------------------
--[[ Member variables ]] --成员变量
--------------------------------------------------------------------------
local widget_width = 600
local widget_height = 90
local NUM_ROWS = 4

local padded_width = widget_width/2 + 5
local padded_height = widget_height - 10
--------------------------------------------------------------------------
--[[ EventLieBiao ]]
--------------------------------------------------------------------------

local EventLieBiao = Class(Widget, function(self, context, fubenshuju, index)
    Widget._ctor(self, "EventLieBiao")
    --初始化
    self:DoInit(context, fubenshuju, index)
end)

function EventLieBiao:DoInit(context, fubenshuju, index)
    self.bg = self:AddChild(TEMPLATES.ListItemBackground_Static(padded_width - 40, padded_height))
    --事件名称
    self.event_name = self.bg:AddChild(Text(NEWFONT_OUTLINE, 30, "", {unpack(GOLD)}))
    self.event_name:SetHAlign(ANCHOR_LEFT)
    self.event_name:SetVAlign(ANCHOR_MIDDLE)
    self.event_name:SetRegionSize(padded_width - 40, 30)
    self.event_name:SetPosition(20, padded_height/2 - (20))

    --事件次数
    self.event_num = self.bg:AddChild(Text(NEWFONT_OUTLINE, 30, "", {unpack(GOLD)}))
    self.event_num:SetHAlign(ANCHOR_RIGHT)
    self.event_num:SetVAlign(ANCHOR_MIDDLE)
    self.event_num:SetRegionSize(padded_width - 40, 30)
    self.event_num:SetPosition(-20, padded_height/2 -(20 + 26 + 10))

end

local function UpdateLieBiao(context, self, item, index) 
    if not item then
        self:Hide()
        self.item = nil
        return
    end

    if self.item ~= item then
        self.item = item
        self.event_name:SetTruncatedString(item[1], nil, 11, "..")
        self.event_num:SetString(item[2])
        self:Show()
    end
end

--------------------------------------------------------------------------
--[[ OceanFishingInformation_of ]]
--------------------------------------------------------------------------


local OceanFishingInformation_of = Class(Screen, function(self, owner)
    Screen._ctor(self, "OceanFishingInformation_of")
    self.owner = owner --玩家 就是 ThePlayer
    self.admin = TheNet:GetClientTableForUser(TheNet:GetUserID()).admin
    self.time = 0
    --根节点
    self.root = self:AddChild(Widget("root"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--在使用一个模板作为背景
    self.bg = self.root:AddChild(TEMPLATES.RectangleWindow(widget_width+300, 550))
    --标题
	self.title = self.root:AddChild(Text(NEWFONT_OUTLINE, 50, "钓鱼详情面板"))
	self.title:SetPosition(0, 250)

    --退出按钮
    self.close_button = self.root:AddChild(TEMPLATES.StandardButton(function() self:OnClose() end, "关闭", {100, 74}))
    self.close_button:SetPosition(0, -300)
    
    --创建 钓鱼数
    self.xianshicishu = self.root:AddChild(Text(NEWFONT_OUTLINE, 30, "次数"))
    self.xianshicishu:SetPosition(-400, 250)
    --创建 上次事件
    self.last = self.root:AddChild(Text(NEWFONT_OUTLINE, 30, "上次：一二三四五六七八九十"))
    self.last:SetPosition(-400, -300)

    --创建 列表
    self:MakeList({})

    -- 管理员
    self.create_button = self.root:AddChild(TEMPLATES.StandardButton(function() if not self.owner.create_button_Cooling then self:createQLZ() end end, "获取清理杖", {130, 74}))
    self.create_button:SetPosition(150, -300)
    self.create_button:Hide()

    self.create_button.moveui_name = "清理杖按钮"
    MoveUI_of(self.create_button, ANCHOR_MIDDLE, ANCHOR_MIDDLE)

    if self.admin then
        self.create_button:Show()
    end
end)
-----------------------------------------------------------------------
-- 屏幕类常用代码
--关闭屏幕时
function OceanFishingInformation_of:OnClose()
    --取消一切任务
    for k,v in pairs(self.tasks or {}) do
        if v then
            v:Cancel()
        end
    end
    local screen = TheFrontEnd:GetActiveScreen()
    --不要弹出HUD
    if screen and screen.name:find("HUD") == nil then
        --删除我们的屏幕
        TheFrontEnd:PopScreen()
    end
    -- SetAutopaused(false)--关闭自动暂停
end

--激活时
function OceanFishingInformation_of:OnBecomeActive()
    self._base.OnBecomeActive(self)
    self:GetData()  -- 获取数据
    self:SetData()  -- 设置数据
    -- SetAutopaused(true)--开启自动暂停
end
-- --注销时
-- function OceanFishingInformation_of:OnDestroy()
--     self._base.OnDestroy(self)
--     SetAutopaused(false)--关闭自动暂停
-- end
--控制屏幕时
function OceanFishingInformation_of:OnControl(control, down)
    if not self.enabled then 
        return false
    end
    --将点击发送到屏幕
    if self._base.OnControl(self, control, down) then 
        return true 
    end
    --esc 关闭界面
    if not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then
        self:OnClose()
        return true
    end

    return false
end
-----------------------------------------------------------------------
function OceanFishingInformation_of:createQLZ()
    -- 添加一个冷却时间
    self.owner:DoTaskInTime(10, function()
        self.owner.create_button_Cooling = nil
    end)
    self.owner.create_button_Cooling = true
    SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"getclearing_staff_of"}, nil, true))
end

function OceanFishingInformation_of:GetData()
    -- 当有数据更新了 才能发送rpc来更新数据
    if self.owner.update_oceanfishin_data and self.owner.update_oceanfishin_data:value() then
        SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"getofdata"}, nil, true))
    end
end
function OceanFishingInformation_of:SetData()
    self.data = TUNING.OFDATA.OCEANFISHIN_DATA.e
    self.cishu = TUNING.OFDATA.OCEANFISHIN_DATA.n
    self.lastname = TUNING.OFDATA.OCEANFISHIN_DATA.l
    self:Refresh()
end

function OceanFishingInformation_of:Refresh()
    self:MakeList(self.data)
    self.last:SetString("上次:"..(self.lastname or "无"))
    self.xianshicishu:SetTruncatedString("钓鱼数:"..tostring(self.cishu or 0), nil, 20, "..")
end

function OceanFishingInformation_of:MakeList(data)
    if data == nil then return end
    if self.e_list then
        self.e_list:SetItemsData(data)
        self.e_list:RefreshView()
    else
        --滚动列表
        local function ScrollWidgetsCtor(context, index) --滚动小部件Ctor
            local w = EventLieBiao(context, data[index] or {}, index)
            w.ongainfocusfn = function()
                self.e_list:OnWidgetFocus(w) --聚焦时
            end
            return w
        end
        self.e_list = self.root:AddChild(TEMPLATES.ScrollingGrid(
                data,
                {
                    scroll_context = self,--{ grouplist = self},
                    widget_width  = padded_width, --显示区域
                    widget_height = padded_height, --显示区域
                    num_visible_rows = NUM_ROWS, -- 滚动条内最多显示多少行
                    num_columns      = 3, --多少列
                    item_ctor_fn = ScrollWidgetsCtor, --生成列表
                    apply_fn = UpdateLieBiao, --更新列表
                    scrollbar_offset = 10, --滚动条 右偏一点
                    scrollbar_height_offset = 0, --滚动条 垂直不偏移
                    peek_percent = 0.5, --多显示0.5行 保证底部能完整
                }
            ))
        self.e_list:SetPosition(0,0)
    end
end


function OceanFishingInformation_of:OnUpdate(dt)
    self:Refresh()
end

return OceanFishingInformation_of
