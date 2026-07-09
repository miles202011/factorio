# HTML 预览资源目录

本目录保存浏览器预览页和它依赖的本地资源。这里的文件主要给人查看和测试用，不是 Factorio 场景运行时直接读取的内容。

## 文件作用

- `index.html`：浏览器预览/测试页，负责展示与游戏内尽量一致的界面和交互。
- `ddz_qr.png`：QQ群二维码预览图，供 `index.html` 弹窗直接显示。
- `ddz_discord_qr.png`：Discord 二维码预览图，供 `index.html` 弹窗直接显示。
- `ddz_qr.svg`：QQ群二维码导出文件，供 `index.html` 的“导出QQ群二维码”按钮下载。
- `README.md`：本目录说明文件。

## 依赖资源

`index.html` 还会读取上一级 `png/` 目录里的图片资源：

- `../png/png_converted/`：正式牌面和牌背图片。
- `../png/png_converted_played/`：已出牌淡化图片。

## 说明

`index.html` 对本目录里的二维码文件使用相对路径；牌面图片则从上一级 `../png/` 目录读取。
