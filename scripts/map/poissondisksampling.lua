local PoissonDiskSampling = Class(function(self, width, height, minDist, maxTries, rng)
    self.width = width or 100
    self.height = height or 100
    self.minDist = minDist or 10
    self.maxTries = maxTries or 30
    self.rng = rng or math.random
    self.cellSize = self.minDist / math.sqrt(2)
    self.gridWidth = math.ceil(self.width / self.cellSize)
    self.gridHeight = math.ceil(self.height / self.cellSize)
    self.grid = {}
    self.points = {}
    self.activeList = {}
end)

function PoissonDiskSampling:Generate()
    -- 初始化网格
    for i = 1, self.gridWidth do
        self.grid[i] = {}
        for j = 1, self.gridHeight do
            self.grid[i][j] = nil
        end
    end
    
    -- 添加第一个点
    local firstPoint = {
        -- x = self.rng() * self.width,
        -- y = self.rng() * self.height
        x = .5 * self.width,
        y = .5 * self.height
    }
    table.insert(self.points, firstPoint)
    table.insert(self.activeList, firstPoint)
    
    local gridX = math.floor(firstPoint.x / self.cellSize) + 1
    local gridY = math.floor(firstPoint.y / self.cellSize) + 1
    self.grid[gridX][gridY] = firstPoint
    
    -- 生成过程
    while #self.activeList > 0 do
        local activeIndex = math.random(#self.activeList)
        local point = self.activeList[activeIndex]
        local found = false
        
        for i = 1, self.maxTries do
            local angle = self.rng() * 2 * math.pi
            local distance = self.minDist + self.rng() * self.minDist
            local newPoint = {
                x = point.x + math.cos(angle) * distance,
                y = point.y + math.sin(angle) * distance
            }
            
            -- 检查是否在范围内
            if newPoint.x >= 0 and newPoint.x < self.width and
               newPoint.y >= 0 and newPoint.y < self.height then
                
                local gridX = math.floor(newPoint.x / self.cellSize) + 1
                local gridY = math.floor(newPoint.y / self.cellSize) + 1
                
                -- 检查邻近单元格
                local valid = true
                for x = math.max(1, gridX - 2), math.min(self.gridWidth, gridX + 2) do
                    for y = math.max(1, gridY - 2), math.min(self.gridHeight, gridY + 2) do
                        if self.grid[x][y] then
                            local existingPoint = self.grid[x][y]
                            local dx = newPoint.x - existingPoint.x
                            local dy = newPoint.y - existingPoint.y
                            if dx * dx + dy * dy < self.minDist * self.minDist then
                                valid = false
                                break
                            end
                        end
                    end
                    if not valid then break end
                end
                
                -- 如果有效，添加到列表
                if valid then
                    table.insert(self.points, newPoint)
                    table.insert(self.activeList, newPoint)
                    self.grid[gridX][gridY] = newPoint
                    found = true
                    break
                end
            end
        end
        
        -- 如果未找到新点，从激活列表中移除
        if not found then
            table.remove(self.activeList, activeIndex)
        end
    end
    
    return self.points
end

return PoissonDiskSampling