return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 10,
  height = 12,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 10,
      height = 12,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 27, 27, 27, 0, 0, 0,
        0, 0, 0, 27, 27, 27, 0, 0, 0, 0,
        0, 0, 11, 11, 11, 11, 11, 11, 0, 0,
        0, 11, 10, 11, 11, 11, 11, 10, 11, 0,
        11, 10, 10, 10, 11, 11, 10, 10, 10, 11,
        11, 11, 10, 11, 11, 11, 11, 10, 11, 11,
        11, 11, 11, 11, 29, 29, 11, 11, 11, 11,
        11, 11, 11, 11, 29, 29, 11, 11, 11, 11,
        11, 27, 11, 11, 11, 11, 11, 11, 27, 11,
        11, 11, 27, 11, 11, 11, 11, 27, 11, 11,
        0, 11, 11, 27, 27, 27, 27, 11, 11, 0,
        0, 0, 11, 11, 11, 11, 11, 11, 0, 0
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
          name = "小丑",
          type = "balatro_machine",
          shape = "rectangle",
          x = 256,
          y = 448,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
