# 海钓随机物品 - 模组物品补丁

这是 `海钓随机物品` 的依赖补丁模组。补丁本身不复制原模组的完整代码，而是在与原模组同时启用时，对原模组的海钓掉落、空军事件和部分世界生成内容进行追加或覆盖。

Steam 创意工坊订阅链接：[OceanFishing-Patch](https://steamcommunity.com/sharedfiles/filedetails/?id=3739717643)

## 依赖

必须同时启用原模组：

[海钓随机物品](https://steamcommunity.com/sharedfiles/filedetails/?id=2710978964)

建议在服务器模组列表中同时勾选原模组和本补丁。本补丁已在 `modinfo.lua` 中声明依赖，并使用更低的 `priority`，以便在原模组及部分可选模组完成世界生成注册后再进行修改。

## 主要功能

- 修改一次空军时触发奖励/事件的次数，可配置为 1 到 5 次，默认 3 次。
- 追加能力勋章物品到原模组的海钓掉落表。
- 追加棱镜/相关模组物品到原模组的海钓掉落表。
- 可选启用原补丁中注释掉、但原模组未注释的易报错事件。
- 可选在世界生成中向指定岛屿追加夜雨心空物品。
- 可选在世界生成中向指定位置生成 "星辰魔女"。

## 配置项

### 空军触发事件次数

配置名：`event_times`

设置一次空军时触发奖励/事件的次数。可选值为 1 到 5，默认 3。

### 增加勋章物品

配置名：`enable_medal`

开启后，将能力勋章相关物品追加进海钓随机掉落表。补丁会在抽取前过滤不存在的 prefab，未启用对应模组时会尽量跳过无效物品。

### 增加棱镜物品

配置名：`enable_prismatic`

开启后，将棱镜相关物品追加进海钓随机掉落表。补丁会在抽取前过滤不存在的 prefab，避免抽到不存在物品导致报错。

### 增加夜雨心空非制作物品

配置名：`enable_yyxk_build`

开启后，在世界生成阶段向原模组的 `NightmareHome` 岛追加夜雨心空相关物品，例如 `yyxk_san_layout` 和 `nilxin_lifeplant`。

注意：世界生成修改只对新生成的世界生效，旧存档不会自动补生成。

### 增加魔女老师

配置名：`enable_star_monv`

开启后，在世界生成阶段向 `Turtle` 岛追加 `star_monv`。同时会移除魔女模组注册的 `MONVLand` 岛生成项，避免额外生成魔女花花岛。

注意：该功能依赖目标 prefab 存在。如果对应模组未启用，补丁会跳过不存在的 prefab，并在日志中打印跳过原因。

### 启用易报错事件

配置名：`enable_error_prone_events`

默认关闭。开启后会加入一组原补丁中注释掉、但原模组中存在的事件，例如：

- `healthlink`
- `removeitems`
- `transformation`
- `black_hole`
- `puppet_boss`
- `playerdata`

这些事件被单独放在开关后面，是因为它们更容易与其他模组、玩家状态或世界状态产生冲突。服务器稳定性优先时建议保持关闭。

## 世界生成说明

本补丁的世界生成入口是：

```text
modworldgenmain.lua
scripts/map/oceanfishing_patch_worldgen.lua
```

追加岛屿物品时，建议使用：

```lua
AddIslandPrefabAtTiledPixel("NightmareHome", "goldnugget", 224, 800)
```

这里的 `224, 800` 是 Tiled/static layout 文件中的像素坐标。不要直接传给 `AddIslandPrefab`，因为 `AddIslandPrefab` 使用的是 DST layout 相对坐标，不是像素坐标。

所有通过这些辅助函数添加的物品，最终都会经过 prefab 存在性检查。不存在的物品会跳过，不会强行写入 layout。

## 后续添加其他模组物品

海钓掉落表的扩展主要在 `modmain.lua`：

1. 在 `modinfo.lua` 增加一个配置项，例如 `enable_xxx`。
2. 在 `modmain.lua` 顶部读取配置。
3. 在 `mod_loots` 中增加对应模组的掉落表。
4. 在 `PatchLoots()` 中调用 `inject_items("xxx", enable_xxx)`。

世界生成物品的扩展主要在 `scripts/map/oceanfishing_patch_worldgen.lua`：

```lua
local xxx_worldgen_items = {
    {"NightmareHome", "xxx_prefab", 224, 800},
}

for _, item in ipairs(xxx_worldgen_items) do
    AddIslandPrefabAtTiledPixel(item[1], item[2], item[3], item[4], item[5])
end
```

## 兼容性说明

本补丁会尽量通过 `PrefabExists` 和保护性逻辑跳过不存在的物品，降低未启用可选模组时的报错风险。但如果其他模组在更晚阶段修改同一份世界生成 layout 或覆盖原模组的海钓逻辑，仍可能出现冲突。

如果修改了世界生成相关配置，请重新创建世界测试。旧存档不会重新执行 `modworldgenmain.lua` 中的岛屿生成逻辑。
