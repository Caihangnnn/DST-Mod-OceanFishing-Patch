-- 自定义 全局函数

-- hook函数
-- 对原函数执行一次就好，谨防多次执行导致嵌套多层。
-- 缺点:不能再次覆盖为原函数，记得提前存好原函数的引用，需要时再通过这个覆盖回原函数
function GLOBAL.createHookedFunction(originalFunc, preHook, postHook)
    return function(...)
        -- 调用操作函数，传入原始函数和原始参数
        local result = preHook and {preHook(...)} or {true}
        
        -- 如果操作函数返回 true，则继续执行原始函数
        if result[1] then
            result = originalFunc and {originalFunc(...)} or nil
            if postHook then
                postHook(result, ...)
            end
            return result ~= nil and unpack(result) or nil
        else
            table.remove(result, 1)
            -- 如果操作函数返回 false，则直接返回操作函数的结果
            return unpack(result)
        end
    end
end


-- 重新加载这两个文件 常用测试
GLOBAL.resetting_loot = function()
    if package.loaded["event_table"] then
        package.loaded["event_table"] = nil
        TUNING.OCEANFISHINGROD_E.oceanfishingrod = require("event_table")
    end
    if package.loaded["loots"] then
        package.loaded["loots"] = nil
        require("loots")
    end
    -- if package.loaded["of_debug"] then
        package.loaded["of_debug"] = nil
        require("of_debug")
    -- end
end


-- 替代 AddPlayerPostInit
local allplayerfns = {}

function GLOBAL.AddPlayerPostInit_of(fn)
    table.insert(allplayerfns, fn)
end

local MakePlayerCharacter = require("prefabs/player_common")
package.loaded["prefabs/player_common"] = createHookedFunction(MakePlayerCharacter, function(name, ...)
    AddPrefabPostInit(name, function(inst)
        for _, fn in ipairs(allplayerfns or {}) do
            fn(inst)
        end
    end)
    return true
end)

GLOBAL.MOUSEENTITY = nil
function GLOBAL.getmouse()
    local mouseentity = TheInput:GetWorldEntityUnderMouse()
    if TheWorld == nil or mouseentity == nil then
        return
    end
    if GLOBAL.MOUSEENTITY ~= mouseentity then
        GLOBAL.MOUSEENTITY = mouseentity
    end
end