require("stategraphs/commonstates")

local function onattack(inst)
    inst.sg:GoToState("attack")
    -- print("攻击事件 2", GetTime())
end

local events=
{
    CommonHandlers.OnLocomote(false, true), --移动
    -- CommonHandlers.OnFreeze(),--冻结时 不需要
    EventHandler("doattack", onattack) --进攻时
    -- CommonHandlers.OnAttacked(), --论被攻击 没有
    -- CommonHandlers.OnDeath(), --论死亡
    -- CommonHandlers.OnSleepEx(), --被睡眠
    -- CommonHandlers.OnWakeEx(), --唤醒时
}

local states =
{
    State{

        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                if not inst.components.health:IsDead() then --防止死亡还能造成伤害
                    inst.components.combat:DoAttack()
                    inst.components.health:DoDelta(-5) --每次攻击减少1点耐久 生命值-1.自带80%减伤
                    inst.sg:RemoveStateTag("attack")
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

}

local walkanims =
{
    startwalk = "idle", --开始步行
    walk = "idle", --步行中
    stopwalk = "idle", --停止步行
}

CommonStates.AddWalkStates(states, nil, walkanims, true)

return StateGraph("glasscutter", states, events, "idle")
