return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 10,
  height = 10,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../tools/tiled/dont_starve/tiles.png",
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
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 6, 6, 6, 6, 6, 6, 0, 0,
        0, 6, 6, 7, 7, 7, 7, 0, 6, 0,
        0, 6, 7, 7, 7, 7, 7, 7, 6, 0,
        0, 6, 7, 7, 7, 7, 7, 7, 6, 0,
        0, 6, 7, 7, 7, 7, 7, 7, 6, 0,
        0, 6, 7, 7, 7, 7, 7, 7, 6, 0,
        0, 6, 0, 7, 7, 7, 7, 0, 6, 0,
        0, 0, 6, 6, 6, 6, 6, 6, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
          name = "月台",
          type = "moonbase",
          shape = "rectangle",
          x = 320,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "盒中泰拉",
          type = "terrarium",
          shape = "rectangle",
          x = 220,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "复活石",
          type = "resurrectionstone",
          shape = "rectangle",
          x = 160,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
      }
    }
  }
}
