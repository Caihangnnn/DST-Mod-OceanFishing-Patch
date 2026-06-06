-- 初始化 随机地皮类型 (海洋或者陆地)
local function initialization()
	local ground = {}
	local w = 24--math.random(22,25)
	local h = w

	for i=1,w do
		local t = {}
		for j=1,h do
			if i == 1 or j == 1 or i == w or j == h then
				table.insert(t, 1) -- 边缘默认为1
			elseif math.random() <= .4 then --海洋占比小一些 后续陆地面积会大一些（大概）
				table.insert(t, 1)
			else
				table.insert(t, 3)
			end
		end
		table.insert(ground,t)
	end
	return ground
end
-- 判断邻格海洋数量
local function checkNeighborOceans(x, y, t)
	local num = 0
	for i = -1, 1 do
		for j = -1, 1 do
			local n_x, n_y = x + i, y + j
			local tile = t[n_x] and t[n_x][n_y] or nil
			if not tile or tile <= 2 then
				num = num + 1
			end
		end
	end
	return num
end
-- 细胞自动机
local function circulate(ground)
	local size = #ground
	for i=1,size do
		for j=1,size do
			local n = checkNeighborOceans(i, j, ground)
			if ground[i][j] >= 3 then 	-- 陆地
				if n >= 5 then
					ground[i][j] = math.random(1, 2) --前两个是海洋地皮 后三是陆地地皮
				else
					ground[i][j] = 3--math.random(3, 5)
				end
			else						-- 海洋
				if n >= 4 then
					ground[i][j] = math.random(1, 2)
				else
					ground[i][j] = 3--math.random(3, 5)
				end
			end
		end
	end
	return ground
end



local function createChaosIsland()
	local function getArea() -- 执行几次细胞自动机
		-- return initialization()
		-- return circulate(initialization())
		return circulate(circulate(initialization()))
		-- return circulate(circulate(circulate(initialization())))
		-- return circulate(circulate(circulate(circulate(initialization()))))
		-- return circulate(circulate(circulate(circulate(circulate(initialization())))))
	end
	local idx = 2
	local t = getArea()
	local t2 = {}
	local is_land = {} --陆地

	local index = 0 --小岛屿id
	-- 洪水填充法 找到相邻的非海洋地皮 说明是一体的
	local function FloodStain(x, y)
		for _x = -1, 1 do
			for _y = -1, 1 do
				local i, j = x + _x, y + _y
				local tile = t[i] and t[i][j] or nil
				local is_stain = t2[i] and t2[i][j] or nil
				if is_stain or not tile or tile <= 2 then
					-- 已经更改了 或者 超范围了 或者 是海洋
				else
					-- 统一地皮类型
					t[i][j] = idx
					-- 标记已经更改
					if t2[i] == nil then t2[i] = {} end
					t2[i][j] = true

					-- 记录陆地位置
					if is_land[index] == nil then is_land[index] = {} end
					table.insert(is_land[index], {i,j})
					-- 迭代
					FloodStain(i, j)
				end
			end
		end
	end

	for i=1,#t do
		for j=1,#t do
			if t[i][j] > 2 and not (t2[i] and t2[i][j]) then --每次执行判断体内代码，说明是新的一块区域
				idx = idx + 1
				if idx > 5 then
					idx = 3
				end
				index = index + 1
				FloodStain(i, j)
			end
		end
	end

	-- print("小岛数量", #is_land)

	local land = {}

	for _, data in ipairs(is_land) do
		if #data < 2 then
			-- print("岛屿".._, #data) --排除地皮太小的区块
		else
			for k,v in ipairs(data) do
				table.insert(land, v)
			end
		end
	end
	--[[ --输出为可被查看文件
	local function handle(map_width, map_height)
		local data = {}
		local tiledata = {}
		for i=1, map_width do
			for j=1, map_height do
				if t[i] and t[i][j] and t[i][j] > 2 then
					table.insert(tiledata, t[i][j])
				else
					table.insert(tiledata, 203)
				end
			end
		end
		data.tiledata = tiledata
		data.width = map_width
		data.height = map_height
		return data
	end

    local file, msg = io.open("map_data.json", "w")--保存到data文件夹下的map_data.json
    local json = require "json"
    local data = handle(#t, #t)
    local str = json.encode(data)

    file:write(str)
    file:close()
    ]]

	return t, land
end

return {
	GetLand = createChaosIsland,
}