local Layouts = require("map/layouts").Layouts

local TILE_SIZE = 64

local function GetGlobal(name)
    local global = rawget(_G, "GLOBAL")
    if global ~= nil then
        local value = rawget(global, name)
        if value ~= nil then
            return value
        end
    end

    return rawget(_G, name)
end

local function GetConfig(name, default)
    local get_mod_config_data = GetGlobal("GetModConfigData")
    if get_mod_config_data == nil then
        return default
    end

    local ok, value = pcall(get_mod_config_data, name)
    if ok and value ~= nil then
        return value
    end

    return default
end

local enable_yyxk_build = GetConfig("enable_yyxk_build", true) ~= false
local enable_star_monv = GetConfig("enable_star_monv", true) ~= false

local function HasPrefab(prefab)
    local prefab_exists = GetGlobal("PrefabExists")

    return type(prefab) == "string"
        and prefab ~= ""
        and (prefab_exists == nil or prefab_exists(prefab))
end

local function AddIslandPrefab(layout_name, prefab, x, y, data)
    if not HasPrefab(prefab) then
        print("[OceanFishing-Patch] skipped island prefab because prefab is missing:", layout_name, prefab)
        return false
    end

    -- x/y are DST layout coordinates, not Tiled pixel coordinates.
    -- Keep them inside a normal static-layout range, otherwise worldgen may reserve
    -- a huge area and the object will be far outside the island.
    if type(x) ~= "number" or type(y) ~= "number" or math.abs(x) > 32 or math.abs(y) > 32 then
        print("[OceanFishing-Patch] skipped island prefab with invalid layout coords:", layout_name, prefab, x, y)
        return false
    end

    local layout = Layouts[layout_name]
    if layout == nil or layout.layout == nil then
        print("[OceanFishing-Patch] skipped island prefab because layout is missing:", layout_name, prefab)
        return false
    end

    layout.layout[prefab] = layout.layout[prefab] or {}
    table.insert(layout.layout[prefab], {
        x = x,
        y = y,
        width = 0,
        height = 0,
        visible = true,
        properties = data ~= nil and {data = data} or {},
    })
    return true
end

local function AddIslandPrefabAtTiledPixel(layout_name, prefab, tiled_x, tiled_y, data)
    local layout = Layouts[layout_name]
    if layout == nil or layout.ground == nil then
        print("[OceanFishing-Patch] skipped tiled-pixel prefab because layout is missing:", layout_name, prefab)
        return false
    end

    -- Tiled object coordinates are pixels from the layout's top-left corner.
    -- StaticLayout.Get converts them to layout coordinates with this formula.
    local width = #(layout.ground[1] or {})
    local height = #layout.ground
    local x = tiled_x / TILE_SIZE - width / 2
    local y = tiled_y / TILE_SIZE - height / 2
    return AddIslandPrefab(layout_name, prefab, x, y, data)
end

local function GetGroundAreaCenter(layout, tile_id, flip_y)
    if layout == nil or layout.ground == nil then
        return nil
    end

    local min_col, max_col, min_row, max_row

    for row, tiles in ipairs(layout.ground) do
        for col, tile in ipairs(tiles) do
            if tile == tile_id then
                min_col = min_col == nil and col or math.min(min_col, col)
                max_col = max_col == nil and col or math.max(max_col, col)
                min_row = min_row == nil and row or math.min(min_row, row)
                max_row = max_row == nil and row or math.max(max_row, row)
            end
        end
    end

    if min_col == nil then
        return nil
    end

    local width = #(layout.ground[1] or {})
    local height = #layout.ground
    local x = ((min_col - 1 + max_col) / 2) - width / 2
    local y = ((min_row - 1 + max_row) / 2) - height / 2

    -- Use flip_y=true when you are choosing the area by looking at the Tiled map
    -- visually from top to bottom and want it to match in-game island placement.
    if flip_y then
        y = -y
    end

    return x, y
end

local function AddIslandPrefabAtGroundTileCenter(layout_name, prefab, tile_id, data, flip_y)
    local layout = Layouts[layout_name]
    local x, y = GetGroundAreaCenter(layout, tile_id, flip_y)
    if x == nil then
        print("[OceanFishing-Patch] skipped ground-tile prefab because tile is missing:", layout_name, prefab, tile_id)
        return false
    end

    return AddIslandPrefab(layout_name, prefab, x, y, data)
end

-- Common layout names from the original mod:
-- DefaultStart1     spawn island
-- OceanMoon         small lunar island
-- OceanMoon2        small lunar island 2
-- OceanMoonbase     moonbase island
-- OceanBoss         boss island
-- HermitcrabIsland  hermit island
-- TumbleweedLand    tumbleweed island
-- Turtle            archive/turtle island
-- JunkYard          junkyard island
-- NightmareHome     nightmare island
-- Joker_of          joker island

-- Example A: add one gold nugget by direct DST layout coordinates.
-- The numbers are small offsets from the island center, measured in tiles.
-- AddIslandPrefab("NightmareHome", "goldnugget", -4.5, 4.5)

-- Example B: add one gold nugget by Tiled pixel coordinates.
-- If your chosen point is x=224, y=800 in the static layout .lua/.tmx, use this.

-- Example C: add one gold nugget to the center of a ground-tile region.
-- AddIslandPrefabAtGroundTileCenter("NightmareHome", "goldnugget", 22, nil, true)

-- Example with saved data:
-- AddIslandPrefab("DefaultStart1", "chester_eyebone", 0, 0, {respawntimeremaining = 0})

local yyxk_builds = {
    -- Add yyxk worldgen prefabs here. Each prefab is checked by AddIslandPrefab.
    -- Format: {layout_name, prefab, tiled_x, tiled_y, optional_saved_data}
    {"NightmareHome", "yyxk_san_layout", 224, 800},
    {"NightmareHome", "nilxin_lifeplant", 160, 736},
    {"NightmareHome", "nilxin_lifeplant", 160, 800},
    {"NightmareHome", "nilxin_lifeplant", 160, 864},
    {"NightmareHome", "nilxin_lifeplant", 224, 736},
    {"NightmareHome", "nilxin_lifeplant", 224, 864},
    {"NightmareHome", "nilxin_lifeplant", 288, 864},
    {"NightmareHome", "nilxin_lifeplant", 288, 736},
    {"NightmareHome", "nilxin_lifeplant", 288, 800},
}

local function AddYyxkBuilds()
    for _, item in ipairs(yyxk_builds) do
        AddIslandPrefabAtTiledPixel(item[1], item[2], item[3], item[4], item[5])
    end
end

local function RemoveMonvLandFromWorldgen()
    local add_level_pre_init_any = GetGlobal("AddLevelPreInitAny")
    if add_level_pre_init_any == nil then
        print("[OceanFishing-Patch] skipped MONVLand removal because AddLevelPreInitAny is missing")
        return
    end

    add_level_pre_init_any(function(level)
        if level ~= nil and level.location == "forest" and level.ocean_prefill_setpieces ~= nil then
            level.ocean_prefill_setpieces["MONVLand"] = nil
            print("[OceanFishing-Patch] removed MONVLand from ocean_prefill_setpieces")
        end
    end)
end

if enable_yyxk_build then
    AddYyxkBuilds()
end

if enable_star_monv then
    RemoveMonvLandFromWorldgen()
    AddIslandPrefabAtTiledPixel("Turtle", "star_monv", 864, 1056)
end

return {
    AddIslandPrefab = AddIslandPrefab,
    AddIslandPrefabAtTiledPixel = AddIslandPrefabAtTiledPixel,
    AddIslandPrefabAtGroundTileCenter = AddIslandPrefabAtGroundTileCenter,
    yyxk_builds = yyxk_builds,
    AddYyxkBuilds = AddYyxkBuilds,
    RemoveMonvLandFromWorldgen = RemoveMonvLandFromWorldgen,
}
