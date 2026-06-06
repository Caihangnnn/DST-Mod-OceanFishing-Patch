return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 15,
  height = 15,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/ground.tsx",
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
      width = 15,
      height = 15,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0,
        0, 0, 0, 9, 9, 9, 0, 0, 0, 9, 9, 9, 0, 0, 0,
        0, 0, 9, 9, 9, 9, 9, 0, 9, 9, 9, 9, 9, 0, 0,
        0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0,
        0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0,
        0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0,
        0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0,
        0, 0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 9, 9, 9, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
          name = "复活石",
          type = "resurrectionstone",
          shape = "rectangle",
          x = 256,
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
          x = 704,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        -- {
        --   name = "哈奇",
        --   type = "hutch",
        --   shape = "ellipse",
        --   x = 320,
        --   y = 512,
        --   width = 0,
        --   height = 0,
        --   visible = true,
        --   properties = {}
        -- },
        {
          name = "星空 鱼缸",
          type = "hutch_fishbowl",
          shape = "ellipse",
          x = 320,
          y = 512,
          width = 0,
          height = 0,
          visible = true,
          properties = {data= {respawntimeremaining = 0}}
        },
        -- {
        --   name = "小妾",
        --   type = "chester",
        --   shape = "ellipse",
        --   x = 640,
        --   y = 512,
        --   width = 0,
        --   height = 0,
        --   visible = true,
        --   properties = {}
        -- },
        {
          name = "眼骨",
          type = "chester_eyebone",
          shape = "ellipse",
          x = 640,
          y = 512,
          width = 0,
          height = 0,
          visible = true,
          properties = {data= {respawntimeremaining = 0}}
        },
        {
          name = "大门",
          type = "multiplayer_portal",
          shape = "ellipse",
          x = 480,
          y = 512,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "出生点",
          type = "spawnpoint_master",
          shape = "ellipse",
          x = 480,
          y = 512,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
