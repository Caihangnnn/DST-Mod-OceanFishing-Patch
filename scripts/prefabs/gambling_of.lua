local assets = {
    Asset("ANIM", "anim/treasure_chest.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
    Asset("ANIM", "anim/ui_chest_upgraded_3x3.zip"),
}

-- 希望被修改吗 
local function Betting(inst)
    local self = inst.components.container
    if self == nil then
        return
    end
    local max = 0
    local x,y,z = inst.Transform:GetWorldPosition()
    for k,v in pairs(self.slots) do
        max = max + 1
        local item = self:DropItemBySlot(k) --丢下物品

        if math.random() > .65 then
            local data, references = item:GetPersistData() --获取保存的数据
            for i = 1, math.random(1,3) do
                local newents = {}
                local new = SpawnPrefab(item.prefab)
                newents[new] = {entity=new, data=data}

                new:SetPersistData(data, newents)
                new:LoadPostPass(newents, data)

                -- 设置 抛飞
                new.Transform:SetPosition(x,2,z)
                if new.Physics then
                    local angle = math.random() * 2 * PI
                    local speed = math.random() * 3 + 1
                    new.Physics:SetVel(speed * math.cos(angle), 1, speed * math.sin(angle))
                end
            end
        elseif item then
            item:Remove()
        end
    end
    if max > 0 then
        inst:Remove()
    end
end

local containers = require("containers")
local xxx = {
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(0, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = "开赌",
            position = Vector3(0, 200, 0),
            fn = function(inst, doer)
                if inst.components.container ~= nil and inst.Betting then --是服务器端
                    -- 本地情况下
                    inst:Betting()
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then --客户端端
                    -- 发送rpc
                    SendModRPCToServer(GetModRPC("of_RPC", "fuwuqi"), DataDumper({"betting", inst.Network:GetNetworkID()}, nil, true))
                end
            end,
        },
    },
    type = "cooker",
    itemtestfn = function(container, item, slot)
        return not item:HasTag("irreplaceable") --拒绝 不可替代 物品
    end,
}

containers.params.gambling_of = xxx

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("chest")
    inst.AnimState:SetBuild("treasure_chest")
    inst.AnimState:PlayAnimation("closed")

    inst.AnimState:SetMultColour(0, 0, 0, .75)

    inst:AddTag("nosteal") --不能被偷
    inst:AddTag("gambling_of") --海钓赌博机

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end    

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("gambling_of")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    -- inst.persists = false --退出时不会保存

    inst.Betting = Betting

    -- inst:DoTaskInTime(120, inst.Remove) --到120s清理掉

	return inst
end


return Prefab("gambling_of",fn, assets)