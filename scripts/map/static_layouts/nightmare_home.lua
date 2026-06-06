return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 16,
  height = 16,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 0,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 16,
      height = 16,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 6, 6, 6, 0, 0, 0, 0, 6, 6, 6, 0, 0, 0,
        0, 0, 2, 2, 2, 2, 2, 0, 0, 6, 6, 6, 6, 6, 0, 0,
        0, 6, 2, 22, 22, 22, 2, 0, 6, 6, 6, 7, 7, 7, 6, 0,
        0, 6, 2, 22, 22, 22, 2, 2, 2, 2, 2, 2, 2, 7, 6, 0,
        0, 6, 2, 22, 22, 22, 2, 0, 6, 6, 6, 7, 2, 7, 6, 0,
        0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 6, 7, 2, 7, 6, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 2, 7, 6, 0,
        6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 6, 7, 2, 7, 6, 0,
        6, 2, 2, 2, 2, 2, 2, 6, 0, 0, 6, 7, 2, 7, 6, 0,
        6, 10, 10, 10, 10, 10, 2, 6, 0, 0, 6, 7, 2, 7, 6, 0,
        6, 10, 9, 9, 9, 10, 2, 6, 6, 6, 6, 7, 2, 7, 6, 0,
        6, 10, 9, 9, 9, 10, 2, 2, 2, 2, 2, 2, 2, 7, 6, 0,
        6, 10, 9, 9, 9, 10, 2, 6, 6, 6, 6, 7, 7, 7, 6, 0,
        6, 10, 10, 10, 10, 10, 2, 6, 0, 0, 6, 6, 6, 6, 6, 0,
        6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "噩梦疯猪",
          type = "daywalkerspawningground",
          shape = "rectangle",
          x = 287,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "噩梦城",
          type = "nightmaregrowth",
          shape = "rectangle",
          x = 94,
          y = 225,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "噩梦城",
          type = "nightmaregrowth",
          shape = "rectangle",
          x = 94,
          y = 289,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "噩梦城",
          type = "nightmaregrowth",
          shape = "rectangle",
          x = 94,
          y = 354,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "白色蜘蛛巢",
          type = "item_area",
          shape = "rectangle",
          x = 834,
          y = 196,
          width = 60,
          height = 697,
          visible = true,
          properties = {}
        },
        {
          name = "白色蜘蛛巢2",
          type = "item_area",
          shape = "rectangle",
          x = 707,
          y = 325,
          width = 58,
          height = 438,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
