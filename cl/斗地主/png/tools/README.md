# 斗地主牌面转换工具

本目录保存斗地主牌面资源的转换脚本和 Node.js 依赖声明。这里的文件只用于生成或刷新牌面图片资源，游戏运行时不直接读取本目录。

## Node.js 和 npm 是什么

Node.js 是本地运行 JavaScript 脚本的环境。本目录里的 `.mjs` 文件不是给浏览器或 Factorio 直接运行的，而是给 Node.js 在命令行里运行的。

npm 是 Node.js 配套的依赖和命令工具。本目录使用 npm 做两件事：

- 运行 `npm install` 安装图片处理依赖。
- 运行 `npm run convert` / `npm run convert:played` 执行 `package.json` 里定义的转换命令。

游戏本身不需要 Node.js 或 npm；只有重新生成牌面 PNG 资源时才需要。

## sharp 是什么

`sharp` 是一个 Node.js 图片处理库，是本目录转换脚本使用的图片处理引擎。

本项目用 `sharp` 做这些事：

- 读取 SVG 扑克牌文件。
- 输出 PNG 图片。
- 把牌面固定转换为 225x315 等指定尺寸。
- 读取已有 PNG，并按像素生成淡化的“已出牌”版本。

`sharp` 只在运行转换工具时需要。Factorio 场景运行时读取的是已经生成好的 PNG 文件，不会加载 `sharp`。

## 文件作用

- `svg_to_png.mjs`：把上一级 `../svg_original` 中的 SVG 扑克牌转换成 PNG，默认输出到 `../png_converted`。
- `convert_played_cards.mjs`：把 `../png_converted` 中的正面牌生成淡化的“已出牌”版本，默认输出到 `../png_converted_played`。
- `package.json`：定义 npm 命令和 `sharp` 依赖。
- `package-lock.json`：锁定依赖版本，保证下次安装依赖时结果一致。

## 首次使用

在本目录打开终端：

```powershell
npm install
```

安装后会生成 `node_modules/`。该目录只用于本机运行工具，不需要提交到 Git。

## 转换 SVG 牌面

默认输入目录为 `../svg_original`，默认输出目录为 `../png_converted`。

```powershell
npm run convert -- --clean --width 225 --height 315
```

常用参数：

- `--clean`：转换前清空输出目录里的旧 PNG。
- `--width 225 --height 315`：输出固定为 225x315，匹配当前斗地主牌面资源尺寸。
- `--input <dir>`：指定其它 SVG 输入目录。
- `--output <dir>`：指定其它 PNG 输出目录。

## 生成已出牌版本

默认输入目录为 `../png_converted`，默认输出目录为 `../png_converted_played`。

```powershell
npm run convert:played -- --clean
```

常用参数：

- `--clean`：转换前清空输出目录里的旧 PNG。
- `--fade <0-1>`：控制变淡强度，默认 `0.58`。
- `--white-threshold <0-255>`：接近白色的像素保持不变，默认 `242`。
- `--include-backs`：连 `1B.png`、`2B.png`、`1B_Goodall.png`、`2B_Goodall.png` 四张牌背也一起转换；默认不转换牌背。

## 目录关系

```text
png/
  svg_original/           原始正面牌 SVG
  poker-qr/               旧牌背/牌面 SVG 来源
  poker-qr-BackGoodall/   Goodall 牌背/牌面 SVG 来源
  png_converted/          游戏和 html/index.html 使用的 PNG 牌面
  png_converted_played/   已出牌淡化 PNG
  tools/                  本目录，转换工具
```

## 注意事项

- 不要把 `node_modules/` 提交到 Git。
- 不要把临时输出放到 `tools/` 目录；工具输出应放在上一级资源目录。
- 转换后要确认 `ddz_gui.lua` 和 `html/index.html` 引用的文件名仍存在。
- 如果改了牌面尺寸、目录名或默认输出位置，同步更新上一级 `README.md`。
