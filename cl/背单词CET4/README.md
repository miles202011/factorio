## 背单词CET4

功能：在游戏中每隔 3 分钟弹出单词卡片，支持 7 本词书切换，多词性分行显示。

### 词书（来源：KyleBing/english-vocabulary）

| 文件 | 书名 | 词数 |
|------|------|------|
| word_list_junior.lua  | 初中 | 1987 |
| word_list_senior.lua  | 高中 | 3743 |
| word_list_cet4.lua    | 四级 | 4543 |
| word_list_cet6.lua    | 六级 | 3991 |
| word_list_kaoyan.lua  | 考研 | 5047 |
| word_list_toefl.lua   | 托福 | 10367 |
| word_list_sat.lua     | SAT  | 4464 |

### 单词格式
```lua
{w="access", m="v. 获取\nn. 接近，入口"}
```
- 无独立 p 字段，词性内嵌在 m 中
- `\n` 分隔不同词性，卡片上分行显示（label.style.single_line = false）

### GUI 行为
- 卡片默认左上角 (10, 80)，可拖拽
- 标题行：[书名] [书按钮] ===拖拽=== [当前/总数]
- 内容：单词大粗体 + 多行释义
- 按钮：[< 上一个] [总览] [下一个 >] [关]
- 点"关"→ 折叠成"词汇"小按钮，再点恢复
- 点"书"→ 弹出7本书的选择面板
- 点"总览"→ 滚动列表，当前词高亮（两列：单词 | 释义）
- 每 3 分钟（10800 ticks）自动翻到下一词

### storage 结构
```
storage.vocab[player_index] = {
  active   = "cet4",
  card_loc = {x, y},
  [bid]    = {order, pos, next_tick},  -- 每本书独立进度
}
```

### 技术细节
- 第一行 require freeplay，用 script.get_event_handler 链式保存原处理器
- flow 不可拖拽：用 empty-widget + draggable_space_header + drag_target=frame
- small_button 在 Factorio 2.0 不存在，手动覆盖 button 的 height/padding/font
- book 切换按钮统一用 name:match("^vocab_book_(.+)$") 提取 bid，不需要逐一列举
