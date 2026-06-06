local DIRECTION = {
    {0,1},
    {0,-1},
    {1,0},
    {-1,0},
}

-- 返回地图布局，返回迷宫，返回死胡同末端，返回房间，房间中心，返回门

local DungeonArea = Class(function(self, id, data) --拓扑结构
    self.id = id 

    self.height = data and data.height or 49
    self.width = data and data.width or 49  

    self.space = 1 -- 间隔

    self.size = {3,7,11,15} --房间大小 

    self.roomnum = data.roomnum or 16  --房间数量

    self.windingPercent = data.windingPercent or 0.5 -- 迷宫复杂

    self.attempt_num = 50 --尝试生成房间次数

    self.deleteCorner = 0--self.height * self.width * 0.5 --将会删除掉的死胡同数量

    self.area = {} -- 记录地区地图块的类型 0未被使用 1被房间占用 2被连接点占用 3被迷宫通道占用 --4空虚
end)

function DungeonArea:GenerateArea()
    --初始化区域
    for i=1,self.height*self.width do
        self.area[i] = 0 
    end

    local rooms,core,connects = nil --self:GenerateRooms()
    self:GenerateMaze()


    local connects_ = {}

    local radius = 1
    local function xd(t,i)
        for _,v in pairs(t) do
            if (v[1] - radius <= i[1] and v[1] + radius >= i[1]) or (v[2] - radius <= i[2] and v[2] + radius >= i[2]) then 
                return false
            end
        end
        return true
    end

    --这个方法并不好，选择其他方式进行门与迷宫的连接，现在会出现一个房间的门与它的门连接，自己形成环
    --将遍历全部连接点，删除不能连接通道的点
    for _,connect in pairs(connects or {}) do
        for k,v in pairs(connect) do
            local cz = false
            for dirid,dir in pairs(DIRECTION) do
                local t = self:GetArea(v[1]+dir[1],v[2]+dir[2])
                if t and (t == 3 or t == 1) then --房间之间也可以连接
                    cz = true
                end
            end
            if not cz then
                --去掉不能连接迷宫通道的
                table.removetablevalue(connect,v)
            end
        end

        local i = math.random(1,4) --有几个门
        local num = #connect*2 + 200
        local connect_ = {}
        while #connect>0 and i > 0 and num > 0 do 
            local con = connect[math.random(#connect)]
            if con and xd(connect_,con) then
                table.insert(connect_,con)
                self.area[con[1]+con[2]*self.width] = 2
                i = i - 1
            end
            num = num - 1
        end
        table.insert(connects_,connect_)
        
        print("连接点数后:"..GetTableSize(connect_),i)
    end

    --删除掉一些死胡同
    local maze_,corner = self:FloodFillMaze()

    return rooms,core,connects_,maze_,corner,self.area
end

function DungeonArea:IsRange(x,y)
    return x > self.space and x <= self.width - self.space
        and y > self.space and y <= self.height - self.space
end

function DungeonArea:IsUse(x,y)
    return self:IsRange(x,y) and self.area[x+y*self.width] == 0
end

function DungeonArea:GetArea(x,y)
    return x+y*self.width > 1 and self.area[x+y*self.width] or nil
end

function DungeonArea:SetArea(x,y,t)
    if self:IsUse(x,y) then
        self.area[x+y*self.width] = t
        return true
    end
    return false
end

local function Contains(t,i)
    if t == nil then return false end

    for _, v in pairs(t) do
        if v[1] == i[1] and v[2] == i[2] then
          return true
        end
    end
    return false
end

--查看邻块类型(算边界)数量
function DungeonArea:QueryNeighbors(v,h,i)
    local lj = {}
    for _,dir in pairs(DIRECTION) do
        local t = self:GetArea(v[1]+dir[1],v[2]+dir[2])
        if h then 
            if t and (t == i or t==2) then
                table.insert(lj,{v[1]+dir[1],v[2]+dir[2]})
            end
        else
            if not t or t == i then
                table.insert(lj,{v[1]+dir[1],v[2]+dir[2]})
            end
        end
    end
    return lj
end


function DungeonArea:FloodFillMaze()
    --要反向遍历迷宫通道的每个方块，保证它
    local maze_ = {}
    local corner = {}
    local qy = false
    local num_m = self.deleteCorner --调整删除数量

    -- while not qy and num_m>0 do
    --     qy = true
    --     for x = 1, self.width do
    --         for y = 1, self.height do
    --             local t = self:GetArea(x,y) 
    --             if t and t == 3 then
    --                 local lj = self:QueryNeighbors({x,y},nil,0)
    --                 if #lj >= 3 then 
    --                     qy = false
    --                     self.area[x+y*self.width] = 0
    --                     num_m = num_m - 1
    --                 end
    --             end
    --         end
    --     end 
    -- end
    -- -- print("删除了死胡同的块数",self.deleteCorner-num_m)
    -- for x = 1, self.width do
    --     local str = ""
    --     for y = 1, self.height do
    --         local t = self:GetArea(x,y) 
    --         str = str..(t or "")
    --         if t and t == 3 then
    --             table.insert(maze_,{x,y})
    --             local lj = self:QueryNeighbors({x,y},nil,0)
    --             if #lj == 3 then 
    --                 table.insert(corner,{x,y})
    --             end
    --         end
    --     end
    --     print(str)
    -- end   
    -- print("死胡同方块",#corner)
    return maze_,corner
end

--local num = 3000
function DungeonArea:FloodFill(x,y,maze)
    local part = {}

    local num = 4000
    local con = 1
    local lastdir = {0,0}
    local cells = {}

    cells[1] = {x,y}

    table.insert(part,{x,y})
    self:SetArea(x,y,3)

    local threshold = 5
    while #cells > 0 and num > 0 do
        local current = cells[#cells]

        local unmadeCells = {}
        for _,dir in pairs(DIRECTION) do
            if self:IsUse(current[1]+dir[1],current[2]+dir[2]) and self:IsUse(current[1]+dir[1]*2,current[2]+dir[2]*2) then
                table.insert(unmadeCells,dir)
            end
        end

        if #unmadeCells ~= 0 then
            local dir = nil
            if Contains(unmadeCells,lastdir) and self.windingPercent < math.random() --[[and threshold ~= 0 --]]then
                dir = lastdir
                threshold = threshold - 1
            else
                dir = unmadeCells[math.random(#unmadeCells)]
                threshold = 5
            end

            if self:SetArea(current[1]+dir[1],current[2]+dir[2],3) and self:SetArea(current[1]+dir[1]*2,current[2]+dir[2]*2,3) then
                table.insert(part,{current[1]+dir[1],current[2]+dir[2]}) 
                table.insert(part,{current[1]+dir[1]*2,current[2]+dir[2]*2})
                table.insert(cells,{current[1]+dir[1]*2,current[2]+dir[2]*2})
            end

            con = con + 1
            lastdir = dir
        else
            table.remove(cells)
            lastdir = {0,0}
        end

        num = num - 1
    end

    if #part>300 then
        table.insert(maze,part)
    end
end

function DungeonArea:GenerateMaze()
    local maze = {}
    print("开始填充迷宫")
    for x = 2, self.width, 2 do
        for y = 2, self.height, 2 do
            if self:IsUse(x,y) then
                self:FloodFill(x,y,maze)
            end
        end
    end
    print("结束填充迷宫")
    return maze
end

function DungeonArea:GenerateRoom(x,y,xsize,ysize)
    local room = {}
    local connect = {}

    local xmin = x - (xsize-1)/2
    local xmax = x + (xsize-1)/2
    local ymin = y - (ysize-1)/2
    local ymax = y + (ysize-1)/2

    for i = xmin-1, xmax+1 do
        for j = ymin-1, ymax+1 do
            if not self:IsUse(i,j) then return end
            if i ~= xmin - 1 and i ~= xmax + 1 and j ~= ymin - 1 and j ~= ymax + 1 then --房间里
                table.insert(room,{i,j})
            elseif (i == xmin - 1 or i == xmax + 1) and (j == ymin - 1 or j == ymax + 1) then --四个角

            else
                table.insert(connect,{i,j})
            end
        end
    end
    for k,v in pairs(room) do
        self:SetArea(v[1],v[2],1)
    end

    return room,connect
end

function DungeonArea:GenerateRooms()
    local roomsnum = self.roomnum
    local num = self.roomnum + self.attempt_num
    local rooms = {}
    local core = {}
    local connects = {}

    while roomsnum>0 and num>0 do

        local w = self.size[math.random(#self.size)]
        local h = self.size[math.random(#self.size)]

        --房间坐标要为奇数
        local x = math.random(1, (self.width - w) / 2) * 2 + 1 
        local y = math.random(1, (self.height - h) / 2) * 2 + 1 

        local room,connect = self:GenerateRoom(x,y,w,h)
        if room then
            print("房间坐标",x,y)
            table.insert(rooms,room)
            table.insert(connects,connect)
            table.insert(core,{x=x,y=y})
            roomsnum = roomsnum - 1
            num = num + 1
        end
        num = num - 1
    end
    print("生成房间数量",self.roomnum-roomsnum)
    return rooms,core,connects
end

function Generate(data)
    local dungeonarea = DungeonArea("GAME", data) 
    print("生成区域")
    return dungeonarea:GenerateArea()
end
