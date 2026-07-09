【斗地主 多牌桌版】

文件性质：
  这是 Factorio 场景脚本目录，入口是 control.lua。
  control.lua 只负责加载模块，不直接写业务逻辑：
    ddz_constants.lua  -- 常量
    ddz_cards.lua      -- 牌、牌型判断、出牌展示排序
    ddz_state.lua      -- storage 初始化、桌子/玩家状态、刷新辅助
    ddz_sound.lua      -- Factorio utility 音效表、玩家音效开关、播放封装
    ddz_gui.lua        -- 主界面、等待/叫分/出牌/结束/规则/测试工具等 GUI
    ddz_replay.lua     -- 回放记录、最近3局回放归档、回放窗口
    ddz_game.lua       -- 发牌、叫分、地主分配、出牌/跳过、胜负
    ddz_ai.lua         -- AI 出牌和超时自动行动
    DouZero.lua        -- 参考 DouZero 思路的新 AI 决策层，加载后覆盖公开 AI 决策函数
    ddz_events.lua     -- Factorio 事件注册和按钮分发
    locale/zh-CN/locale.cfg -- 中文本地化
    locale/en/locale.cfg    -- 英文本地化
    AI.md             -- AI v2 与托管逻辑、策略说明
    DouZero.md        -- DouZero Lua AI 的参考来源、策略和回退说明
    ai_sources/README.md -- DouZero / RLCard 源码归档目录说明
    sound.md          -- 斗地主音效映射建议与当前实现说明
    registered_sounds.md -- scenario 可直接尝试的已注册声音路径说明
    html/README.md     -- 浏览器预览目录说明
    html/index.html    -- 浏览器预览/测试版，需尽量与游戏内行为同步
  本场景不加载 __base__/script/freeplay/control.lua，避免原版自由模式在玩家创建时生成坠毁飞船/初始物品并干扰斗地主场景。

事件注册方式：
  所有 script.on_* 注册集中在 ddz_events.lua，control.lua 不直接注册事件。
  不使用 base freeplay 的 on_player_created 事件；玩家进入只由本场景的 on_player_joined_game 刷新大厅。
  - script.on_init：初始化 storage.ddz
  - script.on_configuration_changed：补齐旧存档缺失字段
  - script.on_nth_tick(30)：轮询 AI 待行动
  - script.on_nth_tick(60)：叫分/出牌倒计时、超时处理、等待室未准备踢出
  - on_player_joined_game：进入游戏时刷新大厅
  - on_player_left_game：游戏中断线/离开时按规则记录逃跑并清理座位
  - on_gui_click：统一处理大厅、等待室、叫分、出牌、回放、测试工具、退出确认等按钮

核心逻辑说明：
  - 发牌/叫分/出牌主流程在 ddz_game.lua。
  - 牌型判断和牌面展示顺序在 ddz_cards.lua。
  - 出牌成功后会调用 order_play_cards(cards, pt) 重新整理展示顺序：
      三带一/三带二：三张在前，带牌在后
      四带两单/四带两对：四张在前，带牌在后
      飞机/飞机带单/飞机带对：飞机主体在前，带牌在后
      其他牌型按手牌降序展示
    该排序只影响桌面展示和回放，不改变合法性判断。
  - 回放由 ddz_replay.lua 记录每步 bid/landlord/play/pass/over。
    回放从第0步开始，可在桌子销毁后继续查看最近3局归档；正在查看的旧回放会临时保留到关闭回放界面。
  - 游戏内 UI 与 html/index.html 预览版应同步维护，尤其是牌面颜色、压牌距离、出牌展示顺序。
  - 游戏内主交互文案使用 Factorio 标准 locale 文件，已覆盖标题、按钮、短提示、系统消息、规则正文、注意事项、牌型名、AI显示名、大小王显示名和回放步骤描述；反馈导出纯文本会按导出玩家语言生成中文或英文表头。

需求：多玩家联机，支持动态开桌、准备机制、AI补位

游戏流程：
  1. 进入场景 → 看到大厅（列出所有桌子）
  2. 点「开新桌」创建桌子，或「加入」已有等待中的桌子
  3. 入座后点「准备」，30秒内未准备自动踢出
  4. 三人全部准备后自动开始叫地主
  5. 叫分最高者为地主，底牌3张并入地主手牌（共20张）
  6. 地主先出牌，顺序按座位编号循环
  7. 某人打完手牌即结束，判断地主/农民胜负
  8. 游戏结束后可「再来一局」（同桌重新准备）或「离桌」

支持的牌型：
  单张、对子、三张、三带一、三带二
  顺子（5张+，3-A）、连对（3对+，3-A）
  飞机（2组+连续三张，不含2）、飞机带单翅、飞机带对翅
  四带两单（4张同点+2单）、四带两对（4张同点+2对）
  炸弹（四张相同）、火箭（大小王）

存储结构（storage.ddz）：
  tables          -- [tid] = 桌状态（见下）
  seat            -- [player_index] = tid，nil 表示在大厅
  next_tid        -- 已废弃（桌号现用 alloc_tid 找最小空位复用）
  next_ai_id      -- 下一个AI ID（从-1开始递减）
  ai_names        -- [ai_id] = "AI甲/乙/丙"（动态分配，每桌最多3个slot）
  ai_tid          -- [ai_id] = tid（AI属于哪张桌）
  join_tick       -- [player_index] = 入座时的tick（30秒未准备踢出计时）
  stats           -- [player_name] = {w=胜场, l=负场, e=逃跑次数}
  feedback        -- [{player=名, text=内容, tick=游戏tick}, ...] 玩家反馈，存档内持久
  fb_editing      -- [player_index] = feedback_index，记录玩家正在编辑的反馈条目
  trustees        -- [player_index] = true，表示该真实玩家本局托管中
  spectating      -- [player_index] = tid，表示该玩家正在观战某桌
  win_pos         -- [player_index] = {x,y} 主面板位置记忆
  replay_pos      -- [player_index] = {x,y} 回放面板位置记忆
  replay_archive  -- [id] = 最近回放归档；桌子销毁后仍可查看
  replay_archive_order -- 最近回放顺序；保留最近3局，并额外保留正在查看的回放
  replay_view     -- [player_index] = replay_archive_id，正在查看的回放临时保护
  next_replay_id  -- 下一个回放归档ID
  test_tool       -- [player_index] = 牌面测试工具状态（选择、出牌、压值、红牌颜色）
  sound_enabled   -- [player_index] = false 表示该玩家关闭斗地主音效；nil/true 表示开启

每桌状态（tables[tid]）：
  tid, phase      -- 桌号，阶段：waiting/bidding/playing/over
  order           -- [1..3] = player_index（AI用负数）
  ready           -- [player_index] = true/false（准备状态）
  next_ready      -- over阶段下一局确认状态，[player_index] = true 表示已确认下一局
  hands           -- [player_index] = 手牌数组
  bottom          -- 底牌3张
  landlord        -- 地主 player_index
  bid_turn/val/who/bids_done/bid_status
  redeal_pending/redeal_pending_tick -- 三人都不叫后的重发提示倒计时
  play_turn, last, passes, sel, msg, over_msg
  final_play       -- 游戏结束时展示的最后一手出牌
  turn_tick       -- 当前回合开始的tick（叫分/出牌/跳过后重置，用于30秒超时）
  ai_pending      -- 是否有AI待行动
  last_play_by    -- [player_index] = 上次出的牌数组
  pass_by         -- [player_index] = true 表示上次跳过
  played_cards    -- {val: count} 累计已打出的牌（记牌器数据源）
  replay          -- 当前局回放数据：start + steps + pos
  replay_archive_id -- 当前局归档ID；同一局重复归档时复用，新局 replay_init 会清空

GUI说明：

  大厅界面（gui_lobby）：
  - 列出所有桌子：桌号、状态（等待中/游戏中/结束）、玩家名+准备标记（✓/○）
  - 等待中且有空位时显示「加入」按钮
  - 游戏中/叫分中/结束的桌子可显示「观战」按钮
  - 底部「开新桌」「查看战绩」「游戏规则」「注意事项」「收起」「关于」

  等待界面（gui_waiting）：
  - 显示座位、玩家名、准备状态
  - 已入座玩家：「准备」按钮在未准备时为准备，已准备时再次点击可取消准备
  - 「加入AI」「离桌」「游戏规则」「注意事项」

  叫地主界面（gui_bidding）：
  - 三人叫分状态使用与出牌阶段一致的竖向玩家区，底牌[?][?][?]，手牌展示
  - 轮到自己时显示不叫/叫1-3分按钮
  - 三人都不叫时先显示重新发牌倒计时，再重发新牌
  - 倒计时最后5秒变红
  - 「游戏规则」「退出（结束本局）」

  出牌界面（gui_playing）：
  - 三人信息竖向排列（出牌者带▶，地主金色，显示手牌数和上次出牌）
  - 玩家出牌放在玩家信息下方，固定15px压牌
  - 顶部只显示底牌；记牌器改为通过「记牌器」按钮打开独立弹窗，剩余数量会扣除自己的手牌
  - 手牌按钮固定15px压牌；选中牌会上提，实时牌型提示
  - 出牌倒计时最后5秒变红
  - 第一行按钮为「提示」「出牌」「跳过」「记牌器」；提示/出牌/跳过常驻，当前不可执行时点击无反应
  - 第二行按钮为「托管」「游戏规则」「声音开/关」「退出（结束本局）」
  - over 阶段继续使用同一牌桌界面，三名玩家信息区改为展示各自当前剩余手牌；底部只嵌入胜负信息、下一局确认和回放/导出/离桌按钮

  游戏结束阶段：
  - 不再切换到独立结束窗口；`gui_over` 仅作为兼容入口，实际复用 `gui_playing`
  - 胜负信息、下一局确认状态、「查看回放」「导出回放」「再来一局/取消下一局」「离桌」直接显示在牌桌底部
  - 点击「再来一局」只确认当前玩家，不立即重置其他玩家牌桌界面；所有真实玩家确认后才进入下一局准备

  观战界面（gui_spectator）：
  - 观战者不入座，不参与准备、叫分、出牌、战绩、逃跑
  - 可查看三家手牌数量、当前出牌、跳过状态、底牌占位/已揭示底牌
  - 仅提供「退出观战」「游戏规则」

  回放界面（gui_replay）：
  - 标题为“斗地主 · 桌 N · 回放”，宽度与叫分/出牌主面板一致（940）
  - 从第0步开始展示，含叫分阶段、地主身份、底牌、三人全部手牌
  - 回放内容不使用内层横向滚动框，避免右侧空框和底部滑块
  - 牌面展示固定15px压牌
  - 当前动作玩家行前显示黄色 ▶，与叫分/出牌阶段保持一致
  - 支持“上一步 / 下一步 / 最后一步 / 输入步数跳转 / 滑块拖动翻步 / 导出回放 / 关闭”

  退出确认（gui_quit_confirm）：
  - 点击「退出（结束本局）」先弹出二次确认
  - 使用原生 back_button 与 red_confirm_button
  - 独立弹窗，但位置绑定主面板：主面板刷新后会重新对齐到主面板中间偏上，并尝试 bring_to_front 防止被主面板遮挡
  - 三位真实玩家时提示退出会记录为逃跑并影响战绩

  牌面测试工具（gui_test_tool）：
  - 可测试固定压值：0/5/10/15/20/25，也可手动输入压值
  - 可测试红牌字体颜色：默认红、亮红、玫瑰红、橙红、深红
  - 主界面保留斗地主当前使用/推荐的常用音效按钮；另有「全部音效测试」窗口，列出 66 个 Factorio `utility/...` 内置音效和 1 个已确认地砖声音 `tile-build-small/concrete`
  - “预览牌区”显示当前选中的牌，并固定保留一排牌高度；可快速选择10/15/20张验证多牌出牌区效果
  - 预览牌区复用正式出牌牌型判断和展示排序；例如 22333344 会提示“四带两对”，并按 33332244 展示，点击预览牌仍可取消对应选择

  战绩界面（gui_stats）：
  - 列：玩家 / 胜 / 负 / 逃跑 / 总场次 / 胜率
  - 仅统计3位真实玩家的完整对局；逃跑含退出对局及退出游戏

  关于界面（gui_about）：
  - 显示"由QQ群 1101554578 的伙伴制作"
  - 第一行按钮：「扫码加QQ群」「扫码加Discord」，分别打开 gui_qr / gui_discord_qr 扫码窗口
  - 第二行按钮：「导出QQ群二维码」「导出Discord二维码」，放在扫码按钮下方，分别保存到 script-output/斗地主/ddz_qq_qr.svg 与 script-output/斗地主/ddz_discord_qr.svg
  - 玩家反馈文本框 + 「保存反馈」按钮（写入 storage.ddz.feedback，存档持久）
  - 窗口宽度 520，文本框 500，scroll-pane 508

关键行为：
  - 30秒未准备：`on_nth_tick(60)` 检测 join_tick，超时踢出，发提示消息
  - 30秒出牌/叫分超时：`on_nth_tick(60)` 检测 turn_tick，调 do_auto_timeout(g)
      - 叫分阶段：将该真实玩家设为托管，并调用 do_ai_turn_for(g) 由AI接管叫分
      - 出牌阶段：将该真实玩家设为托管，并调用 do_ai_turn_for(g) 由AI接管出牌
  - 倒计时显示：gui_bidding/gui_playing 每秒从 turn_tick 计算剩余秒数显示；≤5秒变红
  - 桌号复用：alloc_tid() 每次找最小空闲编号，离桌/销毁后编号回收
  - 输出目录：游戏内导出的二维码、反馈和回放文件统一写入 `%AppData%\Factorio\script-output\斗地主\`
  - 空桌自动销毁：waiting阶段无真实玩家时删除（try_destroy_table）
  - 再来一局：over 阶段只标记当前玩家 next_ready；所有真实玩家确认后才 phase 回 waiting，AI 自动准备，玩家重新倒计时
  - 加入下局：over 阶段桌子有空位时，大厅可点「加入下局」，新玩家加入 next_ready，不立即关闭其他玩家结束面板
  - 离桌：bidding/playing 中离桌先结束本局再离开；over 阶段直接离桌
  - 战绩：record_stats 记 w/l（仅3真人完整局）；record_escape 记 e（ddz_quit/断线）
  - 退出确认：ddz_quit 只打开确认框；ddz_quit_confirm_ok 才真正结束本局并记录逃跑
  - 回放归档：replay_record_over 时归档，replay_archive_order 保留最近3局；新局 replay_init 会清空旧 replay_archive_id，避免同桌下一局覆盖上一局回放
  - 回放保护：replay_cleanup_archive 清理旧归档时跳过 replay_view 中正在查看的 ID；关闭回放或玩家离开后释放保护并再次清理
  - 回放导出：结束界面和回放窗口可导出当前回放为 `ddz_replay_<桌号>_<回放ID>.txt`，内容包含初始手牌、底牌和全部步骤
  - 出牌展示排序：do_play 成功后用 order_play_cards 整理 cards，再写入 g.last/g.last_play_by/replay
  - 三人都不叫：进入 redeal_pending，保留当前叫分状态和手牌显示约3秒，再重新发牌并开始新一轮叫分
  - 出牌提示：轮到玩家出牌时，「提示」复用当前 AI/DouZero 选牌逻辑，只选中建议手牌，不自动出牌
  - 结束阶段手牌展示：do_play 成功后更新手牌和 final_play；若该手打完，over 阶段上方三名玩家区中，最后出牌者显示 final_play，其他玩家显示当前剩余手牌，结束区不重复展示最后一手
  - 托管：叫分/出牌阶段可点「托管」，轮到该玩家时复用AI逻辑自动操作；离桌、断线、退出、再来一局、正常结束都会清理托管状态
  - 底牌区：底牌保留独立展示副本，地主手牌拿底牌副本；对应底牌被打出后，仅底牌区和回放底牌的牌面文字变为黄色，牌背景和边框不变
  - 英文牌面：大小王牌面按钮使用 BJ/SJ 短标签，避免 60px 牌面中 Big Joker/Small Joker 被截断；规则说明仍使用完整英文说明
  - 音效：新增 `ddz_sound.lua` 统一封装 `player.play_sound{path="utility/..."}`；每个玩家可单独通过「声音开/关」切换

AI管理：
  - alloc_ai(tid)：从全局 next_ai_id 分配唯一负数ID，记录 ai_names/ai_tid
  - 踢出AI：从 order 移除，清理 ai_names/ai_tid
  - AI立即准备：入座时 ready[ai_id]=true
  - do_ai_turn_for(g)：对单张桌处理AI行动
  - on_nth_tick(30) 遍历所有桌的 ai_pending
  - 托管玩家也通过同一 ai_pending 通道行动，但不会作为AI计入战绩/逃跑判断

二维码说明：
  - QR_DATA：71×71 二进制字符串数组，硬编码在 cl 顶部（QQ群链接）
  - DISCORD_QR_DATA：37×37 二进制字符串数组，硬编码在 cl 顶部（Discord邀请链接）
  - QR_ROWS_RENDERED：启动时预计算，71行，每行71个彩色 █ 字符（白=黑模块，深色=白模块）
  - gui_qr / gui_discord_qr：专用二维码窗口，显示时裁掉2格外圈空白以减少深色边框，单次渲染每行，font_size=8；导出按钮不在扫码窗口内，而是在关于面板扫码按钮下方
  - save_qr_svg：生成 QQ 群 SVG 文件 script-output/斗地主/ddz_qq_qr.svg，黑白标准二维码，用浏览器打开可扫
  - save_discord_qr_svg：生成 Discord SVG 文件 script-output/斗地主/ddz_discord_qr.svg，黑白标准二维码，用浏览器打开可扫
  - 注意：empty-widget.style.background_color 在 Factorio 2.0 运行时不支持

Factorio 2.0 LuaStyle 已知限制（运行时不可设）：
  - stretch_image_to_widget_size：仅 image_style，button_style 报 "Expected Image style type but was Button"
  - single_line=false：仅 label_style，button_style 报 "Expected Label style type but was Button"
  - horizontal_scroll_policy：scroll_pane_style 不支持运行时设置，报 "doesn't contain key"
  - button caption 不支持 \n 换行（单行显示），多行布局只能用 label
  - frame/button 等 style 类型必须匹配；例如 ProgressBar 样式不能给 Button 用
  - vertical_align 不支持 "middle"，只能使用 top/center/bottom

注意事项：
  - 新建 cl 下的子项目目录时必须同步创建 README.md。
  - 修改 control.lua 后必须同步更新 README.md。
  - 本项目虽然 control.lua 很薄，但新增 require 或调整模块加载顺序时也要记录到 README.md。
  - 修改 Lua 后应同步复制到实际测试场景目录：
      C:\Users\王\AppData\Roaming\Factorio\scenarios\斗地主
  - 修改 Lua 后用 luac -p 检查；修改 html/index.html 后至少做脚本语法检查。
  - 不要只改 html/index.html 或只改 Factorio Lua；涉及规则/牌面/出牌展示时两边都要同步。

已知修复历史：
  - v1~v4：global→storage，GUI优化，AI修复，持久按钮，规则面板
  - v5：欢乐斗地主风格，三人信息横排，记牌器，叫分状态，四带二，飞机限制
  - v6：AI自由出牌改==2/==3避免拆牌，AI新增飞机应对逻辑
  - v7：完整重构为多牌桌架构，动态开桌，准备机制，大厅界面
  - v8：战绩改为 {w,l,e}（不分角色），加逃跑统计（ddz_quit+断线均计入）
  - v9：桌号复用、关于窗口（含游戏内二维码+SVG导出+玩家反馈）
  - v10：30秒出牌/叫分超时自动跳过，GUI倒计时显示
  - v11：「查看规则」改为「游戏规则」，新增「注意事项」按钮（大厅+等待室，gui_notice）
  - v12：反馈支持编辑/删除/时间戳；管理员可删除所有人反馈
  - v13：与两个AI对局退出不计逃跑（record_escape 逻辑 + 注意事项文本同步更新）
  - v14：扑克牌重制为竖版（5:7比例）左上角索引样式
      - card_btn_cap(c,sel) 新函数：值+花色单行，黑色字/红色字/橙色选中
      - button caption 不支持 \n 换行，v16 已改为 v..s 单行格式
  - v15：叫地主结束后等待3秒再进入出牌阶段
      - set_bid_pending(g, winner)：bid_pending=true / bid_pending_who / bid_pending_tick=tick+180
      - on_nth_tick(60)：到期调 assign_landlord；期间倒计时"X成为地主，N秒后开始"
      - refresh_table / do_ai_turn_for：bid_pending 期间不触发 AI 行动，防止重复叫分
      - gui_bidding：bid_pending 时隐藏叫分按钮，只显示倒计时
      - assign_landlord：清除 bid_status / bid_pending，删除旧 play_start_tick 字段
  - v16：扑克牌按钮大幅重制 + 关于窗口加宽
      - 手牌按钮：60×84，font="default-large"，左上角对齐，padding=5，选中 top_margin=-20
      - 出牌区按钮（已出牌/底牌）：48×67；需压过：52×73；全部改为 type="button" 同风格
      - card_btn_cap：去掉 \n，改为 v..s 单行（button 不支持换行）
      - gui_playing frame：min-width 1240；玩家面板 min-width 400
      - 关于窗口：min-width 520，scroll-pane 508，按钮文字改为"扫码加QQ群"/"导出QQ群二维码"
      - gui_qr：每行双次渲染（for _=1,2 do），maximal_height=6，字符宽≈12px/高≈6px → 模块约12×12px正方形；约 852×852px
  - v17：UI 与回放同步整理
      - gui_playing/gui_bidding 主面板宽度统一为 940
      - 玩家区改为竖向排列，出牌放在玩家信息下方，除底牌外固定15px压牌
      - 记牌器移到底牌后方，并扣除自己的手牌
      - 红色牌统一为深红
      - 退出按钮增加原生风格二次确认，真实三人局提示逃跑/战绩影响
      - 回放支持叫分阶段、地主/农民身份、全部手牌、最近3局归档，第0步开始；正在查看的旧回放临时保留到关闭
      - 回放当前动作玩家行前显示黄色 ▶
      - 回放面板与主面板同宽，去掉内层横向滚动框
      - 牌面测试工具合并为单个固定高度预览牌区，支持固定压值输入、压值按钮、红牌颜色测试
      - 出牌成功后统一整理展示顺序：三带/四带/飞机主体在前，带牌在后
      - index.html 同步上述牌面、回放、测试工具、出牌排序行为
  - v18：根据游戏内反馈整理
      - 结束桌有空位时大厅显示「加入下局」，加入后标记下一局确认
      - 等待室满员后保留「加入AI（已满）」不可用按钮
      - 叫3分进入地主确认时继续显示「叫3分」
      - 叫分/回放未揭示底牌的问号改为黑色大号
      - 牌面测试工具预览牌支持点击取消选择，并提示压值范围0-45
      - 统一注意事项/战绩中的AI、逃跑、胜负统计文案
      - 新增真实玩家托管按钮，托管后复用AI逻辑自动叫分/出牌
      - 底牌与地主手牌断开对象引用；出掉底牌后，底牌区/回放底牌对应牌文字变黄
      - 叫分/出牌倒计时结束后自动进入托管，并由AI接管，不再使用自动不叫、自动跳过或首发最小牌逻辑
      - 关于窗口新增「扫码加Discord」按钮，游戏内硬编码二维码，HTML 预览使用 ddz_discord_qr.png
      - 二维码导出按钮区分「导出QQ群二维码」和「导出Discord二维码」，文件名分别为 ddz_qq_qr.svg / ddz_discord_qr.svg
      - over阶段「再来一局/加入下局」改为下一局确认机制，避免关闭其他玩家结束面板
      - 新增观战功能，观战者可从大厅进入游戏中/结束桌，不参与牌局和统计
  - v19：二维码窗口调整
      - 关于窗口按钮分两行：第一行扫码，第二行导出对应二维码
      - QQ/Discord 扫码窗口只显示二维码和关闭按钮，不放导出按钮
      - 游戏内二维码显示裁掉2格外圈空白，HTML 预览二维码 padding 从10px缩小到4px，减少深色边框
  - v20：输出目录和反馈归档整理
      - 游戏内二维码导出改为 script-output/斗地主/ddz_qq_qr.svg 与 script-output/斗地主/ddz_discord_qr.svg
      - 游戏内反馈导出改为 script-output/斗地主/ddz_feedback.txt
      - 工作前检查 script-output 根目录旧反馈导出，并合并记录到 feedback.md，已解决反馈标注原因和处理方式
  - v21：底牌已出提示修正
      - HTML 预览中底牌已出提示不再复用 selected 选中牌样式，避免底牌上移、黄边或整张牌像被选中
      - 出牌阶段、观战和回放底牌已出提示统一为仅牌面文字变黄
      - Lua 静态牌参数命名改为 yellow_text，明确该标记只影响 caption 文字颜色
  - v22：关于窗口和牌面测试提示修正
      - 纠正二维码导出按钮位置：导出按钮放在关于面板内的扫码按钮下方，不放在扫码弹窗内部
      - 牌面测试工具「范围 0-45」提示字体加深，避免灰底上看不清
  - v23：第一阶段国际化
      - 新增 locale/zh-CN/locale.cfg 与 locale/en/locale.cfg，采用 Factorio 标准 LocalisedString
      - 主界面标题、按钮、短状态提示、二维码/反馈/系统提示改为 ddz.* 本地化键
      - 顶部按钮会在玩家进入时刷新 caption/tooltip，已有旧按钮也会更新
  - v24：第二阶段国际化
      - 规则正文、注意事项长文、牌型名、回放步骤描述、当前牌牌型、胜负/退出/断线/离桌结束原因改为 ddz.* 本地化键
      - 大小王牌面显示、记牌器、牌面测试工具和回放中的 AI 名显示改为按玩家语言本地化
      - 游戏内部牌值、AI slot 名和战绩键仍保留原始值，避免影响牌型判断、排序、统计和旧存档兼容
      - 反馈导出文件内容和浏览器预览 index.html 的完整多语言当时仍留到后续阶段
  - v25：英文界面细节修复
      - 英文大小王牌面标签由 Big Joker/Small Joker 改为 BJ/SJ，避免手牌按钮中文字被截断
      - 倒计时提示拆分为 timeout-trust-normal / timeout-trust-danger 两个本地化键，不再把富文本颜色标签作为参数传入，避免英文界面出现中文倒计时
      - 修复 on_nth_tick 每秒刷新 ddz_countdown 时仍写入中文硬编码的问题；地主确认倒计时也改用 landlord-start 本地化键
  - v26：第三阶段国际化（Lua 侧）
      - 反馈导出文件为纯文本，不能直接写 LocalisedString；新增导出文本翻译表，按导出玩家语言生成中文或英文表头
      - 反馈导出中的标题、导出玩家、反馈数量、未知玩家兜底文本已支持中英文
      - 审计 Lua 中文硬编码：保留注释、内部牌值（大王/小王）和 AI slot 名等兼容数据；运行时可见中文继续走 locale 或导出翻译表
      - index.html 浏览器预览页多语言本阶段暂不处理
  - v27：牌面测试工具增强
      - 预览牌区新增当前选牌牌型提示，合法牌型显示正式牌型名，非法组合显示无效牌型
      - 预览牌区复用正式出牌展示排序，三带/四带/飞机主体会排在前方；22333344 会展示为 33332244
      - index.html 同步测试工具牌型提示与排序预览行为，但不做浏览器预览页多语言
  - v28：牌型判断修正
      - 修正“飞机带单”和“四带两单”的带牌判断：带单按实际张数计算，不再要求带牌点数必须不同
      - AAAKKK66 现在识别为飞机带单，AAAA66 现在识别为四带两单
      - Lua 与 index.html 同步修正，避免测试工具和正式出牌判断不一致
  - v29：AI/托管带单应对同步
      - AI 应对“四带两单”时允许两张带牌来自同一点数，例如用 AAAA66 压更小的四带两单
      - AI 应对“飞机带单”时允许同点数多张牌作为带牌，例如用 AAAKKK66 压更小的飞机带单
      - index.html 同步补齐飞机类 AI 应对逻辑，并同步四带两单带牌选择规则
  - v30：AI 不拆炸弹策略
      - 新增 AI.md，记录 AI/托管触发方式、叫分策略、出牌策略和不拆炸弹边界
      - AI 应对单张、对子、三张、三带、顺子、连对、飞机等普通牌型时，不再拆四张炸弹
      - AI 仍可整组出炸弹；四带两单/四带两对允许完整四张作为主体
      - index.html 同步 AI 不拆炸弹策略
  - v31：AI v1 叫分评分
      - AI/托管叫分改为按手牌评分返回 0/1/2/3，0 表示不叫
      - 评分考虑火箭、大小王、2/A/K、炸弹、对子、三张、顺子/连对/飞机潜力和散单数量
      - AI 只会在目标叫分高于当前最高叫分时继续叫分
      - AI.md 更新为 AI v1 策略文档；index.html 同步叫分评分逻辑
  - v32：AI v2 候选评分出牌
      - 出牌逻辑从“找到第一手能出的牌”升级为“生成候选牌并评分选择”
      - 支持一手出完优先、低牌优先、普通牌优先、地主低手牌拦截、农民不压队友
      - 农民只有在自己能一手出完时才允许压队友
      - AI.md 更新为 AI v2 策略文档；index.html 同步候选评分出牌逻辑
  - v33：AI v2 保留与后续强 AI 方向
      - 当前运行逻辑继续使用 AI v2，作为可回退的保留版本
      - 后续“超强 AI”从 AI v3 另起，不直接覆盖 AI v2 记录
      - 记录网上强 AI 多依赖 Python/PyTorch/模型权重，正式场景不直接接入外部模型
      - 后续 AI v3 优先参考强 AI 思路，在 Lua 内实现确定性策略
  - v34：DouZero Lua AI 接入
      - 新增 DouZero.lua，不修改 ddz_ai.lua，旧 AI v2 继续作为回退版本保留
      - 新增 DouZero.md，记录本地 DouZero 源码参考范围、不能直接移植的模型部分和 Lua 版策略
      - control.lua 在 ddz_ai 后加载 DouZero，由 DouZero.lua 覆盖 ai_choose_bid / ai_choose_cards_for / ai_choose_cards
      - 参考 DouZero 的“生成合法动作 -> 过滤可出动作 -> 评估动作”流程，在 Lua 内用规则评分替代 PyTorch 模型推理
      - 运行同步时只复制 DouZero.lua，不复制 DouZero.md、README.md 或 DouZero 源码目录
  - v35：DouZero Lua v2 候选剪枝
      - DouZero.lua 带牌组合新增拆牌代价，三带、飞机、四带会优先枚举更合理的带牌
      - 候选组合按总代价排序后剪枝，避免候选数量过大导致运行卡顿
      - 低点数孤张优先作为带牌；拆对子、拆三张和使用2/大小王作为带牌会增加代价
      - 继续保持不拆炸弹规则，四张同点牌不会作为普通带牌来源
      - DouZero.md 更新为 DouZero Lua v2 说明
  - v36：DouZero Lua v3 剩牌拆分评估
      - DouZero.lua 新增 analyze_remaining_hand，对候选出牌后的剩牌进行拆分评分
      - 剩牌拆分会尝试飞机/连对/顺子的不同优先顺序，并取分数最高的方案
      - 评分更重视一手出完、两手收尾、保留完整顺子/连对/飞机/对子/三张/炸弹
      - 低价值孤张增加惩罚；农民保留2、大小王和炸弹等拦截牌会加分
      - DouZero.md 更新为 DouZero Lua v3 说明
  - v37：DouZero Lua v4 残局搜索与安全牌
      - DouZero.lua 新增安全牌判断，根据已出牌和自己手牌估算单张/对子/三张是否已无更大同类牌
      - 手牌较少时检查候选出牌后是否能在两手内收尾，残局收束能力加分
      - 地主剩1张时农民更重视普通单张拦截；地主剩2张时更重视对子拦截和保留控制牌
      - 普通牌能拦截地主时降低炸弹/火箭优先级；只有炸弹能拦时降低炸弹惩罚
      - 队友快走时主动出牌更偏向匹配队友剩牌数量
      - DouZero.md 更新为 DouZero Lua v4 说明
  - v38：DouZero Lua v5 对手剩牌范围推断
      - DouZero.lua 新增 opponent_range_profile，根据已出牌和自己手牌估算外面可能剩余的高单、高对、高三张、炸弹和火箭
      - 安全牌判断改为基于剩牌范围画像，单张/对子/三张的风险判断更可靠
      - 外面可能还有较多高牌时，普通单张/对子/三张评分降低
      - 外面可能还有炸弹或火箭时，非关键局面主动用炸弹会额外扣分
      - 外面已不可能有炸弹/火箭时，农民保留自己的炸弹会获得更高价值
      - DouZero.md 更新为 DouZero Lua v5 说明和强度评分
  - v39：DouZero Lua v6 轻量多轮残局搜索
      - DouZero.lua 新增轻量残局搜索，只在 AI 手牌 9 张以内时触发
      - 搜索深度最多 3 手，每层只取评分靠前的 8 个候选，避免 Factorio 运行卡顿
      - 当前候选出完后会检查剩牌是否能在后续 1-2 手内走完
      - 能形成 2-3 手收尾路线的候选会额外加分，安全控制牌收尾加分更高
      - 外面仍可能有较多高牌、炸弹或火箭时，非安全收尾会降低奖励
      - DouZero.md 更新为 DouZero Lua v6 说明和强度评分
  - v40：DouZero Lua v7 叫分增强
      - DouZero.lua 新增地主潜力评分 landlord_potential_score，替换旧的粗略叫分评分
      - 叫分综合火箭/王/2/A/K控制力、炸弹、三张、对子、顺子/连对/飞机潜力和预计手数
      - 低价值孤张过多、没有控制牌且没有炸弹时会额外降分，避免靠底牌救命的激进叫分
      - 当前最高叫分越高，AI 越谨慎，不再硬追低胜率叫分
      - DouZero.md 更新为 DouZero Lua v7 说明和强度评分
  - v41：DouZero Lua v8 样例库、权重集中和队友配合
      - DouZero.lua 新增 DZ_WEIGHTS，把队友配合、地主危险拦截和炸弹使用等关键权重集中到文件顶部
      - 队友剩1张时，农民主动作牌更倾向出低单张；队友剩2张时更倾向出低对子
      - 地主也处于危险状态时，降低盲目配合队友倾向，避免放跑地主
      - DouZero.md 新增固定样例库，记录后续调权必须保持的关键行为
      - DouZero.md 更新为 DouZero Lua v8 说明和强度评分
  - v42：叫分/结束/观战/提示交互修正
      - 三人都不叫时不再无提示直接重发牌，改为显示重新发牌倒计时后再发牌
      - 游戏结束界面展示最后一手出牌，避免打完最后一张后直接跳到结算看不到牌
      - 观战退出按钮和标题栏关闭按钮统一清理 spectating 状态并返回大厅
      - 出牌阶段新增「提示」按钮，复用当前 AI/DouZero 逻辑选中建议手牌
      - index.html 同步上述预览行为
  - v43：回放导出
      - 游戏结束界面新增「导出回放」按钮
      - 回放窗口底部新增「导出回放」按钮
      - 导出文件写入 script-output/斗地主/ddz_replay_<桌号>_<回放ID>.txt
      - 导出内容包含玩家、初始手牌、底牌、叫分、地主、出牌、跳过和结束结果
      - index.html 同步浏览器下载回放文本文件
  - v44：音效接入
      - 新增 ddz_sound.lua，集中维护斗地主 utility 音效和播放封装
      - 大厅、等待、叫分、出牌、结束、观战界面新增「声音开/关」个人开关
      - 准备、叫分、轮到自己、选牌、提示、出牌、跳过、炸弹、火箭、托管、胜负和导出等节点播放音效
      - 牌面测试工具扩展为牌面/音效测试，可点击试听常用音效
      - index.html 同步声音开关和浏览器模拟试听区
      - 「全部音效测试」窗口补全为 66 个 utility 声音和 1 个已确认地砖声音路径；牌面测试工具主界面只保留斗地主常用音效入口
  - v45：结束阶段嵌入出牌界面
      - over 阶段不再切换到独立结束窗口，改为继续显示出牌牌桌界面
      - 胜负信息、下一局确认、查看/导出回放、再来一局和离桌按钮直接显示在牌桌底部；上方玩家区展示所有玩家当前剩余手牌
      - gui_over 保留为兼容入口，内部复用 gui_playing
  - v46：回放跳转增强
      - 回放窗口新增「最后一步」按钮
      - 回放窗口新增数字输入跳转，可输入指定步数后点击「跳转」或按 Enter
      - 回放窗口新增滑块，可拖动滑块上翻/下翻到指定步骤
      - 滑块拖动时只局部刷新回放内容，不重建整个回放窗口，避免拖动过程中滑块失焦
      - index.html 同步上述回放预览交互
  - v47：结束阶段最后出牌展示调整
      - 游戏结束后，上方玩家区中最后出完牌的玩家显示最后出的牌
      - 其他玩家继续显示当前剩余手牌
      - index.html 同步上述结束阶段展示逻辑
  - v48：牌面改为 PNG 图片资源
      - 游戏内牌面由文字按钮改为 `sprite-button`，图片路径为 `file/png/png_converted/<牌名>.png`
      - 手牌、出牌区、底牌、回放和牌面测试工具继续保持按钮尺寸 60×84、压值 15px 和选中上移 20px
      - 54 张牌面 PNG 由 `png/svg_original` 的 Wikimedia 原始 SVG 转换，当前统一为 225×315，运行时按 60×84 按钮显示
      - 背面问号仍保留文字按钮；底牌已出标记在图片模式下改为黄色槽位/边框提示
      - index.html 同步使用 `png/png_converted` 图片牌面
  - v49：牌背图片接入
      - 从 `png/poker-qr/1B.svg` 和 `png/poker-qr/2B.svg` 转换输出 `png/png_converted/1B.png`、`2B.png`，尺寸统一为 225×315
      - 未揭示的底牌改为显示牌背，不再显示问号；红桃/方块/大王使用红牌背 `2B.png`，黑桃/梅花/小王使用黑牌背 `1B.png`
      - 牌面测试工具新增两张牌背展示；index.html 同步隐藏底牌和测试工具牌背预览
  - v50：回放牌面修正
      - 回放第 0 步和叫分阶段不再因整局已结束而强制显示底牌，未揭示底牌继续按红黑显示牌背
      - 回放中的玩家手牌、当前牌和底牌明牌改为静态 PNG 图片控件，不再显示旧文字按钮或可点击牌按钮
      - index.html 同步回放底牌可见性逻辑
  - v51：牌面尺寸和压值调整
      - 游戏内牌面统一改为 120x168，常规手牌、出牌区、回放和观战固定压值改为 100
      - 手牌选中上移距离改为 40，保持相对旧 20 的双倍抬起效果
      - 牌面测试工具压值按钮改为 20/40/60/80/100，手动输入范围改为 0-120
      - index.html 同步上述牌面尺寸、压值和选中抬起距离
  - v52：牌库改为九列
      - 牌面测试工具下方牌库改为 9 列网格、7 行内容布局，减少横向展开
      - 两张牌背并入同一个牌库网格，不再单独占一行
      - index.html 同步牌库网格和牌背归位
  - v53：记牌器拆花色
      - 记牌器保留每张牌的总剩余数，并在普通牌下方补充四花色剩余拆分
      - 牌局出牌时同步累计花色已出牌，保证记牌器能按花色正确递减
      - index.html 同步记牌器总数与花色拆分显示
  - v54：已出牌面置灰转换
      - 新增 `png/tools/convert_played_cards.mjs`，专门把 `png_converted` 里的 54 张正面牌转换成“已出”版本，输出到 `png_converted_played`
      - 转换方式不是单纯灰度化，而是逐像素向白色混合：白底和近白区域保持不变，其余彩色区域按 `--fade` 变淡，默认值 0.58
      - 默认跳过 `1B.png` 和 `2B.png` 两张牌背，只处理真正的 54 张正面牌；需要连牌背一起转时可加 `--include-backs`
      - 在 `png/tools` 目录执行 `npm run convert:played -- --clean` 会先清空输出目录再重建；`--white-threshold` 可调近白保留范围，方便把牌面边框和底色保住
      - `ddz_gui.lua` 和 `index.html` 在底牌已出时改用 `png_converted_played`，这样游戏内和预览里的“已出牌”都会直接显示置灰牌面
  - v55：出牌页布局重排
      - 底牌和记牌器移到最上方，记牌器的黑桃/梅花改为灰色显示
      - 其他玩家区域改成左侧牌背、右侧出牌的两栏结构
      - 玩家自己的区域移到底部，左侧保留手牌，右侧集中放出牌操作和状态
      - index.html 和 Lua 侧一起同步，保证游戏内和网页预览一致
  - v56：Goodall 牌背接入
      - 新增 `png/png_converted/1B_Goodall.png` 和 `png/png_converted/2B_Goodall.png` 两张牌背资源，尺寸保持 225×315
      - 游戏内所有未揭示牌背统一改为 `1B_Goodall.png`，不再按红黑牌切换 `1B.png` / `2B.png`
      - 牌面测试工具的牌库新增四张牌背展示：`1B.png`、`2B.png`、`1B_Goodall.png`、`2B_Goodall.png`
      - index.html 同步牌背默认图和测试工具展示
  - v57：出牌界面其他玩家半截牌区
      - 出牌界面中其他两个玩家的左侧手牌/牌背区域改为半高视口，只显示牌图上半截
      - 其他玩家右侧出牌区同样改为半高视口；牌局结束阶段也保持半截显示
      - 仅调整出牌界面，观战、回放、测试工具、底牌区和玩家自己的手牌区保持原样
      - index.html 同步出牌界面的半截显示效果，观战预览不改
  - v58：牌背按钮化
      - 牌背从静态 `sprite` 改为 `sprite-button`，显示为可点击状态
      - 移除牌背 tooltip，不再悬停显示“底牌:”
      - 牌背按钮不设置 GUI 名称，避免同一父容器内多张牌背重名，并且不会命中任何游戏动作
  - v59：叫地主界面收窄
      - 叫地主界面窗口最小宽度从 940 调整为 680，减少右侧空白
      - 叫地主阶段三名玩家状态框宽度从 910 调整为 650
      - 出牌界面、观战界面和回放界面宽度保持不变
      - index.html 同步叫地主预览窗口宽度
  - v60：出牌界面按钮和记牌器弹窗
      - 出牌界面窗口最小宽度调整为 680，不再设置最大宽度
      - 记牌器从顶部内嵌区域移出，改为点击「记牌器」按钮打开独立弹窗
      - 第一行按钮固定为「提示」「出牌」「跳过」「记牌器」
      - 「提示」「出牌」「跳过」在不可执行时静默无反应，不再隐藏或提示错误
      - 第二行按钮固定为「托管」「游戏规则」「声音开/关」「退出（结束本局）」
      - index.html 同步上述预览行为
  - v61：牌面转换工具归档
      - 将 `png` 根目录下的转换工具文件集中移动到 `png/tools`
      - `svg_to_png.mjs` 默认读取 `../svg_original` 并输出到 `../png_converted`
      - `convert_played_cards.mjs` 默认读取 `../png_converted` 并输出到 `../png_converted_played`
      - `package.json` 和 `package-lock.json` 随工具脚本一起放入 `png/tools`
