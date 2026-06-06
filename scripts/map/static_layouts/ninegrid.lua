return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 17,
  height = 17,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "静态布局使用地皮",
      firstgid = 1,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "C:/Users/ZCJ123/Desktop/静态布局使用地皮.png",
      imagewidth = 512,
      imageheight = 448,
      transparentcolor = "#ff00ff",
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
      width = 17,
      height = 17,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        18, 18, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 18, 18,
        18, 18, 10, 10, 10, 10, 10, 2, 2, 2, 10, 10, 10, 10, 10, 18, 18,
        4, 10, 10, 5, 5, 5, 10, 10, 2, 10, 10, 11, 11, 11, 10, 10, 4,
        4, 10, 5, 5, 5, 5, 5, 10, 2, 10, 11, 11, 11, 11, 11, 10, 4,
        4, 10, 5, 5, 5, 5, 5, 10, 2, 10, 11, 11, 11, 11, 11, 10, 4,
        4, 10, 5, 5, 5, 5, 5, 10, 2, 10, 11, 11, 11, 11, 11, 10, 4,
        4, 10, 10, 5, 5, 5, 10, 10, 2, 10, 10, 11, 11, 11, 10, 10, 4,
        2, 2, 10, 10, 10, 10, 10, 2, 2, 2, 10, 10, 10, 10, 10, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 10, 10, 10, 10, 10, 2, 2, 2, 10, 10, 10, 10, 10, 2, 2,
        4, 10, 10, 9, 9, 9, 10, 10, 2, 10, 10, 6, 6, 6, 10, 10, 4,
        4, 10, 9, 9, 9, 9, 9, 10, 2, 10, 6, 6, 6, 6, 6, 10, 4,
        4, 10, 9, 9, 9, 9, 9, 10, 2, 10, 6, 6, 6, 6, 6, 10, 4,
        4, 10, 9, 9, 9, 9, 9, 10, 2, 10, 6, 6, 6, 6, 6, 10, 4,
        4, 10, 10, 9, 9, 9, 10, 10, 2, 10, 10, 6, 6, 6, 10, 10, 4,
        18, 18, 10, 10, 10, 10, 10, 2, 2, 2, 10, 10, 10, 10, 10, 18, 18,
        18, 18, 4, 4, 4, 4, 4, 2, 2, 2, 4, 4, 4, 4, 4, 18, 18
      },
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "弹性空间制造器",
          type = "chestupgrade_stacksize",
          shape = "rectangle",
          x = 543,
          y = 544,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },{
          name = "天体裂缝 moon_altar_icon 天体圣殿", --可以被挖掘出啊 给裂缝
          type = "moon_fissure",
          shape = "rectangle",
          x = 215,
          y = 218,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },{
          name = "天体裂缝 moon_altar_cosmic 天体贡品", --击杀帝王蟹出 给裂缝
          type = "moon_fissure",
          shape = "rectangle",
          x = 333,
          y = 218,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },{
          name = "天体裂缝 moon_altar 天体祭坛", --自带的
          type = "moon_fissure",
          shape = "rectangle",
          x = 800,
          y = 285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "天体祭坛 吸引人的结构", --自带的
          type = "moon_altar_rock_glass",
          shape = "rectangle",
          x = 285,
          y = 800,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "天体祭坛 吸引人的结构", --自带的
          type = "moon_altar_rock_idol",
          shape = "rectangle",
          x = 800,
          y = 800,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "天体祭坛 吸引人的结构", --自带的
          type = "moon_altar_rock_seed",
          shape = "rectangle",
          x = 300,
          y = 450,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
