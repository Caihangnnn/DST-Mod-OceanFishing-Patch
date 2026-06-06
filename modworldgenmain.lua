GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

-- Worldgen-only patch entry.
-- This file is used when a new world is generated. It does not affect existing saves.
-- Keep terrain/task/room generation in the original mod; only append objects to existing island layouts.
if rawget(GLOBAL, "WorldSim") then
    require("map/oceanfishing_patch_worldgen")
end
