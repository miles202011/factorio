# 斗地主牌面资源目录

本目录保存斗地主场景使用的扑克牌图像资源、原始 SVG 资源和转换工具。游戏运行时主要读取已经生成好的 PNG 文件，不会运行本目录里的转换脚本。

## 目录作用

- `png_converted/`：正式使用的 PNG 牌面资源。`ddz_gui.lua` 和 `html/index.html` 会读取这里的牌面、牌背图片。
- `png_converted_played/`：已出牌淡化版本。底牌已经打出后，界面会使用这里的淡化牌面提示该底牌已经出现过。
- `svg_original/`：正面牌的原始 SVG 来源。每张牌的具体来源页逐条列在 [source.md](./source.md)。
- `poker-qr/`：旧牌背和一套 SVG 牌面来源，具体来源说明见 [source.md](./source.md)。
- `poker-qr-BackGoodall/`：Goodall 牌背和一套 SVG 牌面来源，具体来源说明见 [source.md](./source.md)。
- `tools/`：转换工具目录。里面保存 Node.js 脚本、npm 配置文件和工具说明，详见 `tools/README.md`。
- 来源索引见 [source.md](./source.md)。

## 游戏实际读取

游戏内 Lua 和浏览器预览主要读取：

```text
png/png_converted/
png/png_converted_played/
```

当前常用牌背在 `png_converted/` 中：

```text
1B.png
2B.png
1B_Goodall.png
2B_Goodall.png
```

其中游戏内未揭示牌背当前统一使用 `1B_Goodall.png`。

## 转换流程

需要重新生成牌面时，进入 `tools/` 目录运行转换工具：

```powershell
cd D:\桌面\factorio\cl\斗地主\png\tools
npm install
npm run convert -- --clean --width 225 --height 315
npm run convert:played -- --clean
```

转换工具默认路径：

- `svg_to_png.mjs`：读取 `../svg_original/`，输出到 `../png_converted/`
- `convert_played_cards.mjs`：读取 `../png_converted/`，输出到 `../png_converted_played/`

## 不应放回根目录的内容

`png` 根目录只保留资源文件夹和 `tools/`。不要把下面内容放回根目录：

- `node_modules/`
- `.zip` 下载包
- `.pdf` 打印稿
- `.jpg` 临时来源图
- `tmp_*.png`
- `upload_test*`
- `card_back_*`

这些内容要么可以重新生成，要么只是下载、上传或测试过程中的临时文件，不属于游戏运行资源。
