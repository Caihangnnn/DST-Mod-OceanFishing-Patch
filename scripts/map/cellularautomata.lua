-- 凸多边形岛屿生成器
local function generateConvexIsland(size, irregularity)
    -- 确定岛屿中心
    local center = {x = size/2, y = size/2}
    
    -- 确定岛屿半径 (占地图大小的40%-60%)
    local radius = size * (0.4 + 0.2 * math.random())
    
    -- 确定多边形的边数 (6-12边)
    local numSides = 6 + math.random(6)
    
    -- 生成凸多边形的顶点
    local points = {}
    local angleStep = 2 * math.pi / numSides
    
    for i = 1, numSides do
        -- 基础角度
        local angle = (i-1) * angleStep
        
        -- 添加一些不规则性
        local irregularAngle = angle + (math.random() - 0.5) * irregularity * angleStep
        local irregularRadius = radius * (0.8 + 0.4 * math.random())
        
        -- 计算点坐标
        local x = center.x + irregularRadius * math.cos(irregularAngle)
        local y = center.y + irregularRadius * math.sin(irregularAngle)
        
        -- 确保点在有效范围内
        x = math.max(1, math.min(size, x))
        y = math.max(1, math.min(size, y))
        
        table.insert(points, {x = x, y = y})
    end
    
    -- 按角度排序点，确保凸多边形正确绘制
    table.sort(points, function(a, b)
        local angleA = math.atan2(a.y - center.y, a.x - center.x)
        local angleB = math.atan2(b.y - center.y, b.x - center.x)
        return angleA < angleB
    end)
    
    return points, numSides
end

-- 判断点是否在多边形内 (射线法)
local function pointInPolygon(point, polygon)
    local inside = false
    local j = #polygon
    
    for i = 1, #polygon do
        if ((polygon[i].y > point.y) ~= (polygon[j].y > point.y)) and
           (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / 
            (polygon[j].y - polygon[i].y) + polygon[i].x) then
            inside = not inside
        end
        j = i
    end
    
    return inside
end

-- 创建岛屿地图
local function createIslandMap(polygon, size)
    local map = {}
    for y = 1, size do
        map[y] = {}
        for x = 1, size do
            -- 默认是海洋 (1)
            map[y][x] = 1
            
            -- 检查点是否在多边形内
            if pointInPolygon({x = x, y = y}, polygon) then
                map[y][x] = 2  -- 陆地 (2)
            end
        end
    end
    
    return map
end

-- 平滑函数 - 使岛屿边缘更自然
local function smoothIsland(map, iterations)
    local size = #map
    local tempMap = {}
    
    for iter = 1, iterations do
        -- 创建临时地图副本
        for y = 1, size do
            tempMap[y] = {}
            for x = 1, size do
                tempMap[y][x] = map[y][x]
            end
        end
        
        -- 应用平滑规则
        for y = 2, size - 1 do
            for x = 2, size - 1 do
                -- 计算周围陆地块数
                local landCount = 0
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        if not (dx == 0 and dy == 0) then
                            landCount = landCount + (tempMap[y + dy][x + dx] == 2 and 1 or 0)
                        end
                    end
                end
                
                -- 根据周围陆地情况调整当前点
                if landCount >= 5 then
                    map[y][x] = 2  -- 如果周围大多是陆地，设为陆地
                elseif landCount <= 3 then
                    map[y][x] = 1  -- 如果周围大多是水，设为水
                end
                -- 中间情况保持不变
            end
        end
    end
    
    return map
end

-- 打印岛屿地图
local function printIslandMap(map)
    for y = 1, #map do
        local line = ""
        for x = 1, #map[y] do
            line = line .. (map[y][x] == 2 and "■" or "□")  -- 陆地用█，海洋用░
        end
        print(line)
    end
end

local function createChaosIsland(size, irregularity)
    -- math.randomseed(seed or os.time())
    
    print("生成凸多边形岛屿...")
    local polygon, numSides = generateConvexIsland(size, irregularity or 0.3)
    local islandMap = createIslandMap(polygon, size)
    islandMap = smoothIsland(islandMap, 2)  -- 应用两次平滑

    return islandMap
end


return {
	GetLand = createChaosIsland,
}