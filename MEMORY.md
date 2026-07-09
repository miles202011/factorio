https://github.com/miles202011/factorio
所有改动都要同步到github

## 规则

- `D:\桌面\factorio\cl` 下面的所有 `cl` 文件均为场景替换文件，不是 mod。
- 每个 `control.lua` 放在独立子文件夹中，文件夹名描述该脚本的用途。
  - 示例：`欢迎欢迎健康提醒\control.lua`、`自动拆除空矿机\control.lua`
- 按照功能拆分 `control.lua`，参考 `D:\桌面\factorio\cl\斗地主`，`control.lua` 里只放核心内容。

## 环境

- 所有 `cl` 都在 Factorio 2.x（含 Space Age DLC）中运行。

## 缩写

- `cl` = `control.lua`

## 路径

- 场景文件目录：`C:\Users\王\AppData\Roaming\Factorio\scenarios`
- 存档文件目录：`C:\Users\王\AppData\Roaming\Factorio\saves`
- 游戏默认输出目录：`C:\Users\王\AppData\Roaming\Factorio\script-output`

## 参考资源

- 游戏安装目录：`D:\LenovoSoftstore\Install\Steam\steamapps\common\Factorio`
- 子文件夹 `data`：游戏自带数据，通常包括基础包、Space Age DLC 数据、内置资源、原型定义等
- 子文件夹 `bin\x64\factorio.exe`：游戏可执行文件
- 子文件夹 `doc-html`：本地 HTML 文档
- 子文件夹 `config-path.cfg`：配置路径说明文件，告诉游戏用户数据、配置、存档等放在哪里
- Factorio 官方 Lua API：<https://lua-api.factorio.com/latest/>

## cl 目录新建规范

- 在 `D:\桌面\factorio\cl\` 下新建 `cl` 文件夹时：
  - 同步创建 `README.md`
  - 每次修改 `cl` 文件夹里的文件后，也必须同步更新 `README.md`
  - `README.md` 内容：文件性质、事件注册方式、核心逻辑说明、关键数据表、注意事项

  - 如果该 `cl` 是小游戏类型，还要同步创建 `index.html`
  - 每次修改 `cl` 文件夹里的文件后，也必须同步更新 `index.html`
  - `index.html` 内容：和异星工厂中该小游戏的功能面板完全一样

  - 同步在 `C:\Users\王\AppData\Roaming\Factorio\scenarios` 创建同名文件夹，并只同步 cl 子项目运行所需内容
  - 每次修改 cl 子项目后，也必须同步更新 `scenarios` 下对应子文件夹的运行所需内容
  - 不要把参考资料、网页缓存、下载页面、临时文件、测试截图、无关导出文件同步进 `scenarios`
    - `control.lua`
    - 被 `control.lua` `require` 的 `*.lua`
    - `locale/`
    - 运行时必须读取的资源文件

- 若有输出内容，则输出到 `C:\Users\王\AppData\Roaming\Factorio\script-output` 的同名文件夹里。

- 若有保存反馈功能，则同步创建 `feedback.md`
- 由于每次在游戏中保存反馈都会覆盖 `script-output` 对应的反馈文件，所以工作前要先检查反馈文件并更新到 `feedback.md`，这个文件只保存从 `script-output` 导出的文件。
- 处理反馈时，bug 要找到原因和列出解决办法。
- 已解决的反馈要标注“已解决”。

- 若引入 AI，则同步创建 `AI.md`，里面保存 AI 的逻辑和策略
- 每次修改 AI 相关功能也必须同步更新 `AI.md`

## 操作

- 允许在 `D:\桌面\factorio` 及其子文件夹操作。
- 允许在 `C:\Users\王\AppData\Roaming\Factorio\scenarios` 及其子文件夹操作。
- 允许在 `C:\Users\王\AppData\Roaming\Factorio\script-output` 及其子文件夹操作。

## locale 确定规则

- 客户端语言是 `zh-CN`，就加载 `locale/zh-CN/locale.cfg`
- 客户端语言是 `en`，就加载 `locale/en/locale.cfg`
- 客户端语言是 `zh-TW`，且没有 `locale/zh-TW/locale.cfg` 时，回退到 `en`
