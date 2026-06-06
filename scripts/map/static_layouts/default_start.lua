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
      -- filename = "D:/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/ground.tsx",
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
      width = 15,
      height = 15,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 9, 9, 0,
        0, 6, 6, 6, 0, 6, 6, 6, 6, 6, 2, 2, 9, 9, 0,
        6, 6, 6, 0, 0, 0, 0, 6, 6, 2, 6, 6, 6, 6, 0,
        0, 6, 0, 0, 0, 0, 0, 0, 6, 2, 6, 6, 6, 0, 0,
        0, 0, 0, 7, 7, 7, 7, 0, 6, 2, 6, 6, 0, 0, 0,
        0, 0, 0, 7, 7, 7, 7, 0, 6, 2, 6, 0, 0, 0, 0,
        0, 0, 0, 7, 7, 7, 7, 0, 6, 6, 6, 6, 6, 0, 0,
        0, 0, 0, 7, 7, 7, 7, 0, 6, 6, 6, 6, 6, 6, 0,
        6, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 0, 0, 0, 0,
        6, 6, 0, 0, 0, 0, 6, 6, 6, 6, 6, 0, 9, 9, 0,
        0, 0, 0, 0, 6, 6, 6, 6, 0, 0, 0, 0, 9, 9, 0,
        0, 0, 0, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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
          name = "大门",
          type = "multiplayer_portal",
          shape = "rectangle",
          x = 590,
          y = 530,
          width = 34,
          height = 32,
          visible = true,
          properties = {}
        },
        {
          name = "大门",
          type = "spawnpoint_master",
          shape = "rectangle",
          x = 590,
          y = 530,
          width = 34,
          height = 32,
          visible = true,
          properties = {}
        },
        {
          name = "复活石",
          type = "resurrectionstone",
          shape = "rectangle",
          x = 818,
          y = 176,
          width = 31,
          height = 31,
          visible = true,
          properties = {}
        },
        {
          name = "复活石",
          type = "resurrectionstone",
          shape = "rectangle",
          x = 815,
          y = 749,
          width = 34,
          height = 33,
          visible = true,
          properties = {}
        },
        {
          name = "眼骨",
          type = "chester_eyebone",
          shape = "rectangle",
          x = 311,
          y = 790,
          width = 14,
          height = 12,
          visible = true,
          properties = {data= {respawntimeremaining = 0}}
        },
        -- {
        --   name = "眼骨",
        --   type = "chester",
        --   shape = "rectangle",
        --   x = 311,
        --   y = 790,
        --   width = 14,
        --   height = 12,
        --   visible = true,
        --   properties = {}
        -- },
        {
          name = "鱼缸",
          type = "hutch_fishbowl",
          shape = "rectangle",
          x = 311,
          y = 504,
          width = 16,
          height = 14,
          visible = true,
          properties = {data= {respawntimeremaining = 0}}
        },
        -- {
        --   name = "鱼缸",
        --   type = "hutch",
        --   shape = "rectangle",
        --   x = 311,
        --   y = 504,
        --   width = 16,
        --   height = 14,
        --   visible = true,
        --   properties = {}
        -- },
        {
          name = "舞台",
          type = "stagehand",
          shape = "rectangle",
          x = 80,
          y = 278,
          width = 20,
          height = 18,
          visible = true,
          properties = {}
        },
        {
          name = "齿轮骑士",
          type = "knight",
          shape = "rectangle",
          x = 336,
          y = 114,
          width = 3,
          height = 2,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
