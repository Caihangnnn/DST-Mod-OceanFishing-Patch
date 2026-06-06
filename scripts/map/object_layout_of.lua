-- 核心代码还是使用官方的 但是选择布局还得是自己建的表 直接使用原版的 会多很多其他不必要的内容
-- 而且 加载部分还是用的再有吧。 要不要考虑卸掉加载的文件呢。 毕竟用的次数不多。

local obj_layout = require("map/object_layout")

local function LayoutForDefinition(name, choices)
	assert(name~=nil)

	local objs = require("map/worldgen_of")

	local layout = {}

	if objs.Layouts[name] == nil then
		print("没有对应的岛屿", name)
		return
	else
		if objs.Layouts[name] ~= nil then
			layout = deepcopy(objs.Layouts[name])
		end

		layout.name = name
	end

	package.loaded["map/worldgen_of"] = nil --这样就断开了记录的表 GC时应该会被回收吧 我不知道啊 （而且这样做的话 每次随机岛的内容都不一样）

	return layout
end

local function Place(position, item, addEntity, choices, world)
	assert(item and item ~= "", "Must provide a valid layout name, got nothing.")
	local layout = LayoutForDefinition(item, choices)
	local prefabs = obj_layout.ConvertLayoutToEntitylist(layout)
	obj_layout.ReserveAndPlaceLayout("POSITIONED", layout, prefabs, addEntity, position, world)
end

return {
		LayoutForDefinition = LayoutForDefinition,
		Place = Place,
	}
