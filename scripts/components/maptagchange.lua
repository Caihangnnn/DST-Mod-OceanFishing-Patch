--只能对一个节点进行一次添加一个地图标签

local MapTagChange = Class(function(self, inst) 
	self.inst = inst
    self.task_maptags = {} --记录更改了地图标签的节点
end)

local function ResetPosition()
    for k,v in ipairs(AllPlayers) do
        local x, y, z = v.Transform:GetWorldPosition()
        local node, node_index = TheWorld.Map:FindVisualNodeAtPoint(x, y, z)

        local current_area_data = node and {
            id = TheWorld.topology.ids[node_index],
            type = node.type,
            center = node.cent,
            poly = node.poly,
            tags = node.tags,
        }
        or nil

        v:PushEvent("changearea", current_area_data)
    end
end

function MapTagChange:TimerExists(name)
    return self.task_maptags[name] ~= nil
end

local function OnTimerDone(inst, self, name, tag)
    -- 找到对应节点
    local node_index = -1
    for k, value in pairs(TheWorld.topology.ids) do
        if value == name then
            node_index = k
            break
        end
    end
    if node_index > 0 then
        -- 删除对应标签
        local node = TheWorld.topology.nodes[node_index]

        table.removetablevalue(node.tags,tag)
        --全员更新一下
        -- for k,v in ipairs(AllPlayers) do
        --     v.components.areaaware.current_area = -1
        -- end
        ResetPosition()
    end
    self:StopTimer(name)
end

function MapTagChange:StartTimer(name,time,tag)
    if self:TimerExists(name) then
        return
    end
    self.task_maptags[name] = {
        timer = self.inst:DoTaskInTime(time, OnTimerDone, self, name, tag),
        additional_tag = tag, --额外的标签
        end_time = GetTime() + time, --结束时间
    }
    --全员更新一下
    ResetPosition()
end

function MapTagChange:StopTimer(name)
    if not self:TimerExists(name) then
        return
    end

    if self.task_maptags[name].timer ~= nil then
        self.task_maptags[name].timer:Cancel()
        self.task_maptags[name].timer = nil
    end
    self.task_maptags[name] = nil
end
--------------------------------------------------------------------------
--[[ Save/Load ]] --保存与加载
--------------------------------------------------------------------------

function MapTagChange:OnSave()
    local data = {}
    for k, v in pairs(self.task_maptags) do
        data[k] =
        {
            timeleft = v.end_time - GetTime(),
            additional_tag = v.additional_tag,
        }
    end
    return next(data) ~= nil and { task_maptags = data } or nil
end

function MapTagChange:OnLoad(data)
    if data.task_maptags ~= nil then
        for k, v in pairs(data.task_maptags) do
            self:StartTimer(k, v.timeleft, v.additional_tag)
        end
    end
end

return MapTagChange