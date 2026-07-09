-- All GUI construction and stats/feedback views.


function clear_gui(p)
    local f=p.gui.screen.ddz
    if f and f.valid then
        local loc=f.location
        if loc then
            local d=storage.ddz
            if d then
                if not d.win_pos then d.win_pos={} end
                d.win_pos[p.index]={x=loc.x,y=loc.y}
            end
        end
        f.destroy()
    end
end

function apply_win_pos(p,f)
    local d=storage.ddz
    local pos=d.win_pos and d.win_pos[p.index]
    if pos then f.auto_center=false; f.location={x=pos.x,y=pos.y} end
end

function align_quit_confirm(p)
    local q=p.gui.screen.ddz_quit_confirm
    if not (q and q.valid) then return end
    q.style.minimal_width=276
    q.style.maximal_width=276
    local main=p.gui.screen.ddz
    if main and main.valid and main.location then
        q.auto_center=false
        q.location={x=main.location.x+332,y=main.location.y+70}
    else
        q.auto_center=true
    end
    if q.bring_to_front then pcall(function() q.bring_to_front() end) end
end

function add_titlebar(f, title, close_name)
    local bar=f.add{type="flow",direction="horizontal"}
    bar.drag_target=f
    local title_label=bar.add{type="label",style="frame_title",caption=title}
    title_label.drag_target=f
    local drag=bar.add{type="empty-widget",style="draggable_space_header"}
    drag.style.horizontally_stretchable=true
    drag.style.height=24
    drag.drag_target=f
    bar.add{type="sprite-button",name=close_name,style="frame_action_button",
        sprite="utility/close",hovered_sprite="utility/close_black",
        clicked_sprite="utility/close_black",tooltip=DDZ_L("close")}
end

local function apply_player_panel_style(panel, highlighted)
    panel.style=highlighted and "positive_message_frame" or "inside_shallow_frame"
    panel.style.minimal_width=910
    panel.style.maximal_width=910
    panel.style.padding=6
    if highlighted then
        panel.style.font_color={r=0.8,g=1,b=0.8}
    end
end

local function style_good_button(btn)
    btn.style="green_button"
end

local function style_danger_button(btn)
    btn.style="red_button"
end

local function style_inactive_button(btn)
    btn.style.font_color={r=0.35,g=0.35,b=0.35}
end

local function add_sound_toggle_button(parent,p)
    local caption=ddz_sound_enabled(p) and DDZ_L("sound-on") or DDZ_L("sound-off")
    parent.add{type="button",name="ddz_sound_toggle",caption=caption,tooltip=DDZ_L("sound-toggle-tip")}
end

local TEST_RED_COLORS={
    default={label_key="red-default",tag="1,0.08,0.08"},
    bright={label_key="red-bright",tag="1,0,0"},
    rose={label_key="red-rose",tag="1,0.2,0.45"},
    orange={label_key="red-orange",tag="1,0.28,0"},
    deep={label_key="red-deep",tag="0.75,0,0"},
}
local TEST_RED_ORDER={"default","bright","rose","orange","deep"}

local CARD_SPRITE_DIR="file/png/png_converted/"
local CARD_PLAYED_SPRITE_DIR="file/png/png_converted_played/"
local DEFAULT_CARD_BACK_FILE="1B_Goodall.png"
local TEST_CARD_BACK_FILES={"1B.png","2B.png","1B_Goodall.png","2B_Goodall.png"}
local CARD_SUIT_FILE={[SUITS[1]]="S",[SUITS[2]]="H",[SUITS[3]]="D",[SUITS[4]]="C"}
local CARD_SPRITE_VALID={}

local function card_sprite_name(c)
    if not c then return nil end
    if c.suit=="" then
        if c.rank==17 then return "JK-Red.png" end
        if c.rank==16 then return "JK-Black.png" end
        return nil
    end
    local suit=CARD_SUIT_FILE[c.suit]
    if not suit then return nil end
    return tostring(c.val)..suit..".png"
end

local function card_sprite_path(c,played)
    local name=card_sprite_name(c)
    if not name then return nil end
    return (played and CARD_PLAYED_SPRITE_DIR or CARD_SPRITE_DIR)..name
end

local function is_valid_card_sprite(sprite)
    if not sprite then return false end
    if CARD_SPRITE_VALID[sprite]~=nil then return CARD_SPRITE_VALID[sprite] end
    local valid=true
    if helpers and helpers.is_valid_sprite_path then
        local ok,res=pcall(function() return helpers.is_valid_sprite_path(sprite) end)
        valid=ok and res
    end
    CARD_SPRITE_VALID[sprite]=valid
    return valid
end

local function set_card_image_size(el,w,h)
    el.style.width=w or DDZ_CARD_W
    el.style.height=h or DDZ_CARD_H
    pcall(function() el.style.padding=0 end)
    pcall(function() el.style.stretch_image_to_widget_size=true end)
end

local function card_back_variant(c)
    if c and ((c.suit==SUITS[2] or c.suit==SUITS[3]) or c.rank==17) then return 2 end
    return 1
end

local function add_card_back_file_sprite(parent,w,h,file_name)
    local sprite=CARD_SPRITE_DIR..file_name
    if is_valid_card_sprite(sprite) then
        local img=parent.add{type="sprite-button",sprite=sprite,resize_to_sprite=false}
        set_card_image_size(img,w,h)
        return img
    end
    return nil
end

local function add_card_back_sprite(parent,w,h,variant_or_card)
    return add_card_back_file_sprite(parent,w,h,DEFAULT_CARD_BACK_FILE)
end

local function add_card_button(parent,c,w,h,name,yellow_text)
    local sprite=card_sprite_path(c)
    local spec
    if is_valid_card_sprite(sprite) then
        spec={type="sprite-button",sprite=sprite,resize_to_sprite=false,tooltip=card_str(c)}
    else
        spec={type="button",caption=card_btn_cap(c,yellow_text)}
    end
    if name then spec.name=name end
    local btn=parent.add(spec)
    if yellow_text and spec.type=="sprite-button" then btn.style="yellow_slot" end
    btn.style.width=w or DDZ_CARD_W
    btn.style.height=h or DDZ_CARD_H
    btn.style.padding=0
    if spec.type=="button" then
        btn.style.horizontal_align="left"
        btn.style.vertical_align="top"
        btn.style.left_padding=5
        btn.style.top_padding=5
        btn.style.font="default-large"
    end
    return btn
end

local function add_card_face(parent,c,w,h,name,selected)
    return add_card_button(parent,c,w,h,name,selected)
end

function add_static_card_face(parent,c,w,h,yellow_text)
    local sprite=card_sprite_path(c,yellow_text)
    if is_valid_card_sprite(sprite) then
        local spec={type="sprite-button",sprite=sprite,resize_to_sprite=false,tooltip=card_str(c)}
        local img=parent.add(spec)
        set_card_image_size(img,w,h)
        return img
    end
    return add_card_button(parent,c,w,h,nil,yellow_text)
end

function add_back_card(parent,w,h,card)
    local back=add_card_back_sprite(parent,w,h,card)
    if back then return back end
    local btn=parent.add{type="button",caption="鐗岃儗"}
    btn.style.width=w or DDZ_CARD_W
    btn.style.height=h or DDZ_CARD_H
    btn.style.horizontal_align="center"
    btn.style.vertical_align="center"
    btn.style.font="default-large"
    return btn
end

local function fixed_card_overlap(overlap)
    overlap=overlap or 0
    if overlap<0 then overlap=0 end
    if overlap>DDZ_CARD_OVERLAP_MAX then overlap=DDZ_CARD_OVERLAP_MAX end
    return overlap
end

local function add_card_group(parent,cards,overlap_px)
    local flow=parent.add{type="flow",direction="horizontal"}
    flow.style.horizontal_spacing=2
    local overlap=fixed_card_overlap(overlap_px)
    for i,c in ipairs(cards or {}) do
        local face=add_card_face(flow,c,DDZ_CARD_W,DDZ_CARD_H)
        if i>1 and overlap>0 then face.style.left_margin=-overlap end
    end
end

local function add_card_back_group(parent,count,overlap_px,variant_or_card)
    local flow=parent.add{type="flow",direction="horizontal"}
    flow.style.horizontal_spacing=2
    local overlap=fixed_card_overlap(overlap_px)
    for i=1,math.max(0,count or 0) do
        local back=add_card_back_sprite(flow,DDZ_CARD_W,DDZ_CARD_H,variant_or_card or 1)
        if back and i>1 and overlap>0 then back.style.left_margin=-overlap end
    end
end

local function add_half_card_view(parent)
    local clip=parent.add{type="scroll-pane",direction="vertical"}
    local half_h=math.floor(DDZ_CARD_H/2)
    clip.style.height=half_h
    clip.style.minimal_height=half_h
    clip.style.maximal_height=half_h
    clip.style.vertical_align="top"
    pcall(function() clip.style.padding=0 end)
    pcall(function() clip.horizontal_scroll_policy="never" end)
    pcall(function() clip.vertical_scroll_policy="never" end)
    local flow=clip.add{type="flow",direction="horizontal"}
    flow.style.vertical_align="top"
    return flow
end

local function add_played_cards_panel(parent,cards)
    add_card_group(parent,cards,DDZ_CARD_OVERLAP)
end

local function add_hand_cards_panel(parent,hand,sel)
    local flow=parent.add{type="flow",direction="horizontal"}
    flow.style.vertical_align="bottom"
    flow.style.horizontal_spacing=1
    local overlap=fixed_card_overlap(DDZ_CARD_OVERLAP)
    for i,c in ipairs(hand or {}) do
        local selected=sel and sel[i]
        local slot=flow.add{type="flow",direction="vertical"}
        slot.style.width=DDZ_CARD_W
        slot.style.height=DDZ_CARD_H+DDZ_CARD_SELECT_OFFSET
        if i>1 and overlap>0 then slot.style.left_margin=-overlap end
        if not selected then
            local top_spacer=slot.add{type="empty-widget"}
            top_spacer.style.height=DDZ_CARD_SELECT_OFFSET
        end
        add_card_face(slot,c,DDZ_CARD_W,DDZ_CARD_H,"ddz_c_"..i,selected)
        if selected then
            local bottom_spacer=slot.add{type="empty-widget"}
            bottom_spacer.style.height=DDZ_CARD_SELECT_OFFSET
        end
    end
end

local function get_test_state(pid)
    local d=storage.ddz
    if not d.test_tool then d.test_tool={} end
    if not d.test_tool[pid] then d.test_tool[pid]={sel={},played={}} end
    if not d.test_tool[pid].overlap then d.test_tool[pid].overlap=DDZ_CARD_OVERLAP end
    if not d.test_tool[pid].red_color then d.test_tool[pid].red_color="deep" end
    return d.test_tool[pid]
end

local function test_card_caption(c, selected, red_color)
    local txt=(c.suit~="" and (c.val..c.suit) or card_value_loc(c.val))
    if selected then return DDZ_S("[color=1,1,0]",txt,"[/color]") end
    local is_red=(c.rank==17 or c.suit==SUITS[2] or c.suit==SUITS[3])
    if is_red then
        local cfg=TEST_RED_COLORS[red_color or "default"] or TEST_RED_COLORS.default
        return DDZ_S("[color="..cfg.tag.."]",txt,"[/color]")
    end
    return txt
end

local function add_test_card_face(parent,c,w,h,name,selected,red_color)
    local sprite=card_sprite_path(c)
    local spec
    if is_valid_card_sprite(sprite) then
        spec={type="sprite-button",sprite=sprite,resize_to_sprite=false,tooltip=card_str(c)}
    else
        spec={type="button",caption=test_card_caption(c,selected,red_color)}
    end
    if name then spec.name=name end
    local btn=parent.add(spec)
    if selected and spec.type=="sprite-button" then btn.style="yellow_slot" end
    btn.style.width=w or DDZ_CARD_W
    btn.style.height=h or DDZ_CARD_H
    btn.style.padding=0
    if spec.type=="button" then
        btn.style.horizontal_align="left"
        btn.style.vertical_align="top"
        btn.style.left_padding=5
        btn.style.top_padding=5
        btn.style.font="default-large"
    end
    return btn
end

local function add_test_card_group(parent,cards,overlap_px,red_color)
    local flow=parent.add{type="flow",direction="horizontal"}
    flow.style.horizontal_spacing=2
    local overlap=fixed_card_overlap(overlap_px)
    for i,c in ipairs(cards or {}) do
        local face=add_test_card_face(flow,c,DDZ_CARD_W,DDZ_CARD_H,nil,false,red_color)
        if i>1 and overlap>0 then face.style.left_margin=-overlap end
    end
end


local function tracker_suit_color(suit)
    if suit==SUITS[2] or suit==SUITS[3] then
        return {r=1,g=0.22,b=0.22}
    end
    return {r=0.58,g=0.58,b=0.58}
end

local TRACKER_LABEL_W=54
local TRACKER_COL_W=28

local function add_tracker_cell(parent, text, w, color, bold)
    local lbl=parent.add{type="label",caption=text or ""}
    lbl.style.minimal_width=w
    lbl.style.maximal_width=w
    lbl.style.horizontal_align="center"
    lbl.style.font=bold and "default-bold" or "default-small"
    if color then lbl.style.font_color=color end
    return lbl
end

local function add_tracker_row(parent, label, cells, label_color, bold_label)
    local row=parent.add{type="flow",direction="horizontal"}
    row.style.horizontal_spacing=0
    add_tracker_cell(row,label,TRACKER_LABEL_W,label_color,bold_label)
    for _,cell in ipairs(cells or {}) do
        add_tracker_cell(row,cell.text or "",TRACKER_COL_W,cell.color,cell.bold)
    end
end

local function ordered_test_entries(entries, pt)
    if not pt then return entries end
    local cards={}
    for i,item in ipairs(entries or {}) do cards[i]=item.card end
    local ordered=order_play_cards(cards, pt)
    local remaining={}
    for _,item in ipairs(entries or {}) do remaining[#remaining+1]=item end
    local out={}
    for _,card in ipairs(ordered) do
        for i,item in ipairs(remaining) do
            if item.card==card then
                out[#out+1]=item
                table.remove(remaining,i)
                break
            end
        end
    end
    for _,item in ipairs(remaining) do out[#out+1]=item end
    return out
end

function gui_test_tool(p)
    if p.gui.screen.ddz_test then p.gui.screen.ddz_test.destroy() end
    local pid=p.index
    local st=get_test_state(pid)
    if not st.deck then
        st.deck=create_deck()
        sort_hand(st.deck)
    end
    local f=p.gui.screen.add{type="frame",name="ddz_test",direction="vertical"}
    f.auto_center=true
    f.style.minimal_width=940
    add_titlebar(f,DDZ_L("title-test"),"ddz_test_close")

    local test_overlap=st.overlap or DDZ_CARD_OVERLAP
    local wf=f.add{type="flow",direction="horizontal"}
    wf.style.vertical_align="center"
    wf.add{type="label",caption=DDZ_L("fixed-overlap")}
    for _,ov in ipairs({20,40,60,80,100}) do
        local btn=wf.add{type="button",name="ddz_test_overlap_"..ov,caption=tostring(ov)}
        if ov==test_overlap then style_good_button(btn) end
    end
    local input=wf.add{type="textfield",name="ddz_test_overlap_input",text=tostring(test_overlap)}
    input.style.width=54
    wf.add{type="button",name="ddz_test_overlap_apply",caption=DDZ_L("apply")}
    local hint=wf.add{type="button",caption=DDZ_L("range-0-120")}
    hint.style.height=30
    hint.style.font_color={r=0.08,g=0.08,b=0.08}

    local cf=f.add{type="flow",direction="horizontal"}
    cf.add{type="label",caption=DDZ_L("red-card-color")}
    local red_color=st.red_color or "default"
    for _,key in ipairs(TEST_RED_ORDER) do
        local cfg=TEST_RED_COLORS[key]
        local btn=cf.add{type="button",name="ddz_test_red_"..key,
            caption=DDZ_S("[color="..cfg.tag.."]",DDZ_L(cfg.label_key),"[/color]")}
        if key==red_color then style_good_button(btn) end
    end

    local sf=f.add{type="frame",style="inside_shallow_frame",direction="vertical"}
    sf.style.padding=6
    sf.add{type="label",caption=DDZ_L("sound-test-title")}
    local sg=sf.add{type="table",column_count=9}
    for _,item in ipairs(DDZ_RECOMMENDED_SOUND_TESTS) do
        local btn=sg.add{type="button",name="ddz_test_sound_"..item.id,
            caption=ddz_sound_test_caption(item),
            tooltip=ddz_sound_test_path(item)}
        btn.style.width=118
    end
    local all_sound_btn=sg.add{type="button",name="ddz_all_sound_test_open",caption=DDZ_L("all-sound-test"),tooltip=DDZ_L("all-sound-test-tip")}
    style_good_button(all_sound_btn)
    all_sound_btn.style.width=118
    local note=sf.add{type="label",caption=DDZ_L("sound-test-note")}
    note.style.single_line=false
    note.style.maximal_width=860

    local selected={}
    for i,c in ipairs(st.deck or {}) do
        if st.sel[i] then selected[#selected+1]={idx=i,card=c} end
    end
    local selected_cards={}
    for i,item in ipairs(selected) do selected_cards[i]=item.card end
    local selected_type=#selected_cards>0 and get_type(selected_cards) or nil
    local preview_entries=ordered_test_entries(selected, selected_type)
    f.add{type="label",caption=DDZ_L("preview-cards",#selected,test_overlap)}
    if #selected>0 then
        local type_caption=selected_type and DDZ_S("[color=0.4,1,0.4]",type_name_loc(selected_type.tp),"[/color]") or DDZ_L("test-invalid-type")
        f.add{type="label",caption=DDZ_L("test-card-type",type_caption)}
    end
    local preview=f.add{type="flow",direction="vertical"}
    preview.style.height=DDZ_CARD_H+6
    if #preview_entries>0 then
        local pf=preview.add{type="flow",direction="horizontal"}
        pf.style.horizontal_spacing=2
        local overlap=fixed_card_overlap(test_overlap)
        for i,item in ipairs(preview_entries) do
            local face=add_test_card_face(pf,item.card,DDZ_CARD_W,DDZ_CARD_H,"ddz_test_card_"..item.idx,false,red_color)
            if i>1 and overlap>0 then face.style.left_margin=-overlap end
        end
    else
        local spacer=preview.add{type="empty-widget"}
        spacer.style.height=DDZ_CARD_H
    end

    local bf=f.add{type="flow",direction="horizontal"}
    bf.add{type="button",name="ddz_test_clear",caption=DDZ_L("clear")}
    bf.add{type="button",name="ddz_test_10",caption=DDZ_L("select-10")}
    bf.add{type="button",name="ddz_test_15",caption=DDZ_L("select-15")}
    bf.add{type="button",name="ddz_test_20",caption=DDZ_L("select-20")}
    f.add{type="line"}

    f.add{type="label",caption=DDZ_L("deck-hint")}
    local sc=f.add{type="scroll-pane",direction="vertical"}
    sc.style.maximal_height=260
    local grid=sc.add{type="table",column_count=9}
    for i,c in ipairs(st.deck or {}) do
        add_test_card_face(grid,c,DDZ_CARD_W,DDZ_CARD_H,"ddz_test_card_"..i,st.sel[i],red_color)
    end
    for _,file_name in ipairs(TEST_CARD_BACK_FILES) do
        add_card_back_file_sprite(grid,DDZ_CARD_W,DDZ_CARD_H,file_name)
    end
end

function gui_all_sound_test(p)
    if p.gui.screen.ddz_all_sound_test then p.gui.screen.ddz_all_sound_test.destroy() end
    local f=p.gui.screen.add{type="frame",name="ddz_all_sound_test",direction="vertical"}
    f.auto_center=true
    f.style.minimal_width=940
    add_titlebar(f,DDZ_L("title-all-sound-test"),"ddz_all_sound_test_close")

    local note=f.add{type="label",caption=DDZ_L("all-sound-test-note")}
    note.style.single_line=false
    note.style.maximal_width=880

    local sound_scroll=f.add{type="scroll-pane",direction="vertical"}
    sound_scroll.style.maximal_height=620
    sound_scroll.style.minimal_width=900
    local current_group=nil
    local sg=nil
    for _,item in ipairs(DDZ_SOUND_TESTS) do
        local group=item.group or "misc"
        if group~=current_group then
            current_group=group
            local group_label=sound_scroll.add{type="label",caption=ddz_sound_test_group_caption(group)}
            group_label.style.font_color={r=0.95,g=0.82,b=0.45}
            sg=sound_scroll.add{type="table",column_count=5}
        end
        local btn=sg.add{type="button",name="ddz_test_sound_"..item.id,
            caption=ddz_sound_test_caption(item),
            tooltip=ddz_sound_test_path(item)}
        btn.style.minimal_width=152
    end
end

function gui_rules(p)
    if p.gui.screen.ddz_rules then p.gui.screen.ddz_rules.destroy(); return end
    local f=p.gui.screen.add{type="frame",name="ddz_rules",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=460
    add_titlebar(f,DDZ_L("title-rules"),"ddz_rules_close")
    local sc=f.add{type="scroll-pane",direction="vertical"}
    sc.style.maximal_height=480
    local function row(title,body)
        local rf=sc.add{type="flow",direction="horizontal"}
        local lbl=rf.add{type="label",caption=title}
        lbl.style.font="default-bold"; lbl.style.minimal_width=110
        if body and body~="" then
            local bl=rf.add{type="label",caption=body}
            bl.style.single_line=false; bl.style.maximal_width=330
        end
    end
    row(DDZ_L("rules-target-title"),DDZ_L("rules-target-body"))
    row(DDZ_L("rules-deal-title"),DDZ_L("rules-deal-body"))
    row(DDZ_L("rules-bid-title"),DDZ_L("rules-bid-body"))
    row(DDZ_L("rules-order-title"),DDZ_L("rules-order-body"))
    sc.add{type="line"}
    row(DDZ_L("rules-types-title"),"")
    row(DDZ_L("rules-type-single"),DDZ_L("rules-type-single-body"))
    row(DDZ_L("rules-type-pair"),DDZ_L("rules-type-pair-body"))
    row(DDZ_L("rules-type-triple"),DDZ_L("rules-type-triple-body"))
    row(DDZ_L("rules-type-t1"),DDZ_L("rules-type-t1-body"))
    row(DDZ_L("rules-type-t2"),DDZ_L("rules-type-t2-body"))
    row(DDZ_L("rules-type-seq"),DDZ_L("rules-type-seq-body"))
    row(DDZ_L("rules-type-pseq"),DDZ_L("rules-type-pseq-body"))
    row(DDZ_L("rules-type-plane"),DDZ_L("rules-type-plane-body"))
    row(DDZ_L("rules-type-plane1"),DDZ_L("rules-type-plane1-body"))
    row(DDZ_L("rules-type-plane2"),DDZ_L("rules-type-plane2-body"))
    row(DDZ_L("rules-type-s41"),DDZ_L("rules-type-s41-body"))
    row(DDZ_L("rules-type-s42"),DDZ_L("rules-type-s42-body"))
    row(DDZ_L("rules-type-bomb"),DDZ_L("rules-type-bomb-body"))
    row(DDZ_L("rules-type-rocket"),DDZ_L("rules-type-rocket-body"))
    sc.add{type="line"}
    row(DDZ_L("rules-rank-title"),DDZ_L("rules-rank-body"))
    row(DDZ_L("rules-compare-title"),DDZ_L("rules-compare-body"))
end

function gui_notice(p)
    if p.gui.screen.ddz_notice then p.gui.screen.ddz_notice.destroy(); return end
    local f=p.gui.screen.add{type="frame",name="ddz_notice",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=430
    add_titlebar(f,DDZ_L("title-notice"),"ddz_notice_close")
    local sc=f.add{type="scroll-pane",direction="vertical"}
    sc.style.maximal_height=420
    local function row(title,body)
        local rf=sc.add{type="flow",direction="horizontal"}
        local lbl=rf.add{type="label",caption=title}
        lbl.style.font="default-bold"; lbl.style.minimal_width=90
        if body and body~="" then
            local bl=rf.add{type="label",caption=body}
            bl.style.single_line=false; bl.style.maximal_width=320
        end
    end
    row(DDZ_L("notice-ready-timeout-title"),DDZ_L("notice-ready-timeout-body"))
    sc.add{type="line"}
    row(DDZ_L("notice-bid-timeout-title"),DDZ_L("notice-bid-timeout-body"))
    sc.add{type="line"}
    row(DDZ_L("notice-play-timeout-title"),DDZ_L("notice-play-timeout-body"))
    sc.add{type="line"}
    row(DDZ_L("notice-escape-title"),DDZ_L("notice-escape-body"))
    sc.add{type="line"}
    row(DDZ_L("notice-stats-title"),DDZ_L("notice-stats-body"))
end


local add_lobby_footer

function gui_lobby(p)
    clear_gui(p)
    local d=storage.ddz; local pid=p.index
    local f=p.gui.screen.add{type="frame",name="ddz",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=520; apply_win_pos(p,f)
    add_titlebar(f,DDZ_L("title-lobby"),"ddz_close")
    add_lobby_footer(f,p)

    local tids=sorted_keys(d.tables)
    if #tids==0 then
        local nl=f.add{type="label",caption=DDZ_L("no-tables")}
        nl.style.font_color={r=0.55,g=0.55,b=0.55}
    else
        local sc=f.add{type="scroll-pane",direction="vertical"}
        sc.style.maximal_height=280
        for _,tid in ipairs(tids) do
            local g=d.tables[tid] or {phase="waiting",order={},ready={},seat={},spectating={}}
            local tf=sc.add{type="frame",direction="horizontal"}
            tf.style.minimal_width=500; tf.style.padding=6
            local phase_txt
            if     g.phase=="waiting" then phase_txt=DDZ_L("phase-waiting")
            elseif g.phase=="over"    then phase_txt=DDZ_L("phase-over")
            else                           phase_txt=DDZ_L("phase-playing") end
            local tl=tf.add{type="label",caption=DDZ_L("table-row",tid,phase_txt)}
            tl.style.minimal_width=120
            local pf2=tf.add{type="flow",direction="horizontal"}
            pf2.style.horizontal_spacing=8; pf2.style.minimal_width=280
            for _,qid in ipairs(g.order) do
                local mark=""
                if g.phase=="waiting" then
                    mark=g.ready[qid] and "[color=0.4,1,0.4]✔[/color]" or "[color=1,0.6,0.2]•[/color]"
                end
                pf2.add{type="label",caption=DDZ_S(pname_loc(qid),mark)}
            end
            for _=#g.order+1,3 do
                pf2.add{type="label",caption=DDZ_L("empty-seat")}
            end
            if not d.seat[pid] and not d.spectating[pid] then
                tf.add{type="button",name="ddz_join_"..tid,caption=g.phase=="over" and DDZ_L("join-next") or DDZ_L("join")}
            end
            if (g.phase=="bidding" or g.phase=="playing" or g.phase=="over") and not d.seat[pid] and not d.spectating[pid] then
                tf.add{type="button",name="ddz_watch_"..tid,caption=DDZ_L("watch")}
            end
        end
    end
end

add_lobby_footer = function(f,p)
    f.add{type="line"}
    local bf=f.add{type="flow",direction="horizontal"}
    bf.add{type="button",name="ddz_new_table",caption=DDZ_L("new-table")}
    bf.add{type="button",name="ddz_stats_open",caption=DDZ_L("stats")}
    bf.add{type="button",name="ddz_test_open",caption=DDZ_L("test-tool")}
    bf.add{type="button",name="ddz_rules_open",caption=DDZ_L("rules")}
    bf.add{type="button",name="ddz_notice_open",caption=DDZ_L("notice")}
    add_sound_toggle_button(bf,p)
    local sp=bf.add{type="label",caption=""}
    sp.style.horizontally_stretchable=true
    bf.add{type="button",name="ddz_about_open",caption=DDZ_L("about")}
end

function gui_waiting(p,g)
    clear_gui(p)
    local pid=p.index
    local f=p.gui.screen.add{type="frame",name="ddz",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=400; apply_win_pos(p,f)
    add_titlebar(f,DDZ_L("title-waiting",g.tid),"ddz_leave_close")

    f.add{type="label",caption=DDZ_L("players-ready",#g.order)}
    for i,qid in ipairs(g.order) do
        local rf=f.add{type="flow",direction="horizontal"}
        local rmark=g.ready[qid] and DDZ_L("ready-mark") or DDZ_L("not-ready-mark")
        rf.add{type="label",caption=DDZ_L("seat-ready",i,pname_loc(qid),rmark)}
        if is_ai(qid) then
            rf.add{type="button",name="ddz_kick_"..i,caption=DDZ_L("kick")}
        end
    end
    for i=#g.order+1,3 do
        f.add{type="label",caption=DDZ_L("seat-empty",i)}
    end
    f.add{type="line"}
    local bf=f.add{type="flow",direction="horizontal"}
    local seated=player_in_table(g,pid)
    if seated then
        local cap=g.ready[pid] and DDZ_L("cancel-ready") or DDZ_L("ready")
        style_good_button(bf.add{type="button",name="ddz_ready",caption=cap})
    end
    if #g.order<3 then
        bf.add{type="button",name="ddz_add_ai",caption=DDZ_L("add-ai")}
    else
        style_inactive_button(bf.add{type="button",name="ddz_add_ai_full",caption=DDZ_L("add-ai-full")})
    end
    bf.add{type="button",name="ddz_leave_table",caption=DDZ_L("leave-table")}
    bf.add{type="button",name="ddz_rules_open",caption=DDZ_L("rules")}
    bf.add{type="button",name="ddz_notice_open",caption=DDZ_L("notice")}
    add_sound_toggle_button(bf,p)
end

function gui_bidding(p,g)
    clear_gui(p)
    local pid=p.index
    local f=p.gui.screen.add{type="frame",name="ddz",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=680; apply_win_pos(p,f)
    add_titlebar(f,DDZ_L("title-bidding",g.tid),"ddz_close")

    local hdr=f.add{type="flow",direction="vertical"}
    hdr.style.vertical_spacing=4
    for i,qid in ipairs(g.order) do
        local pf2=hdr.add{type="frame",direction="vertical"}
        local is_cur=(not g.bid_pending and not g.redeal_pending and g.bid_turn==i)
        local is_pending=(g.bid_pending and g.bid_pending_who==qid)
        if is_cur or is_pending then pf2.style="positive_message_frame" end
        pf2.style.minimal_width=650
        pf2.style.maximal_width=650
        pf2.style.height=82
        pf2.style.padding=6
            local arrow=(is_cur or is_pending) and "[color=1,0.9,0.1]▶ [/color]" or "   "
        local hand_n=#(g.hands[qid] or {})
        local nl=pf2.add{type="label",
            caption=DDZ_S(arrow,pname_loc(qid),"  ",DDZ_L("cards-blue",hand_n))}
        local bs=g.bid_status[qid]
        if is_pending and bs and bs>0 then
            pf2.add{type="label",caption=DDZ_L("bid-pending-score",bs)}
        elseif is_pending then
            pf2.add{type="label",caption=DDZ_L("bid-pending")}
        elseif bs==nil and is_cur then
            pf2.add{type="label",caption=DDZ_L("bidding")}
        elseif bs==nil then
            pf2.add{type="label",caption=DDZ_L("waiting")}
        elseif bs==0 then
            pf2.add{type="label",caption=DDZ_L("no-bid")}
        else
            pf2.add{type="label",caption=DDZ_L("bid-score",bs)}
        end
    end

    local botf=f.add{type="flow",direction="horizontal"}
    botf.style.vertical_align="center"
    botf.add{type="label",caption=DDZ_L("bottom-cards")}
    for i=1,3 do
        add_back_card(botf,DDZ_CARD_W,DDZ_CARD_H,g.bottom and g.bottom[i])
    end
    f.add{type="line"}

    f.add{type="label",caption=DDZ_L("your-hand-count",#(g.hands[pid] or {}))}
    add_card_group(f,g.hands[pid] or {},DDZ_CARD_OVERLAP)
    f.add{type="line"}

    local trusting=storage.ddz.trustees and storage.ddz.trustees[pid]
    local af=f.add{type="flow",direction="horizontal"}
    if g.redeal_pending then
        local rem=math.max(0, g.redeal_pending_tick - game.tick)
        local secs=math.ceil(rem/60)
        af.add{type="label",name="ddz_countdown",
            caption=DDZ_L("redeal-start",secs)}
    elseif g.bid_pending then
        local rem=math.max(0, g.bid_pending_tick - game.tick)
        local secs=math.ceil(rem/60)
        local lname=pname_loc(g.bid_pending_who)
        af.add{type="label",name="ddz_countdown",
            caption=DDZ_L("landlord-start",lname,secs)}
    else
        if g.order[g.bid_turn]==pid and trusting then
            af.add{type="label",caption=DDZ_L("trustee-bid")}
        elseif g.order[g.bid_turn]==pid then
            af.add{type="button",name="ddz_bid_0",caption=DDZ_L("bid-0")}
            if g.bid_val<1 then af.add{type="button",name="ddz_bid_1",caption=DDZ_L("bid-1")} end
            if g.bid_val<2 then af.add{type="button",name="ddz_bid_2",caption=DDZ_L("bid-2")} end
            if g.bid_val<3 then af.add{type="button",name="ddz_bid_3",caption=DDZ_L("bid-3")} end
        else
            af.add{type="label",caption=DDZ_L("wait-bid",pname_loc(g.order[g.bid_turn]))}
        end
        if g.turn_tick then
            local rem=math.max(0,TURN_TIMEOUT-(game.tick-g.turn_tick))
            local secs=math.ceil(rem/60)
            local key=secs<=5 and "timeout-trust-danger" or "timeout-trust-normal"
            f.add{type="label",name="ddz_countdown",
                caption=DDZ_L(key,secs)}
        end
    end
    f.add{type="line"}
    local qf=f.add{type="flow",direction="horizontal"}
    qf.add{type="button",name="ddz_trust_toggle",caption=trusting and DDZ_L("cancel-trustee") or DDZ_L("trustee")}
    qf.add{type="button",name="ddz_rules_open",caption=DDZ_L("rules")}
    add_sound_toggle_button(qf,p)
    style_danger_button(qf.add{type="button",name="ddz_quit",caption=DDZ_L("quit-round")})
    if g.msg[pid] then f.add{type="label",caption=ddz_message_caption(g.msg[pid])} end
end

local function add_game_over_panel(parent,p,g)
    local panel=parent.add{type="frame",style="inside_shallow_frame",direction="vertical"}
    panel.style.padding=6
    panel.style.minimal_width=910

    local lbl=panel.add{type="label",caption=ddz_message_caption(g.over_msg)}
    lbl.style.font="default-bold"

    local nr=panel.add{type="frame",style="inside_shallow_frame",direction="vertical"}
    nr.style.padding=6
    nr.add{type="label",caption=DDZ_L("next-ready")}
    for _,qid in ipairs(g.order) do
        local status=is_ai(qid) and DDZ_L("ai-ready")
            or ((g.next_ready and g.next_ready[qid]) and DDZ_L("confirmed") or DDZ_L("waiting-confirm"))
        nr.add{type="label",caption=DDZ_S(pname_loc(qid),"  ",status)}
    end

    local bf=panel.add{type="flow",direction="horizontal"}
    if g.replay then bf.add{type="button",name="ddz_replay_open",caption=DDZ_L("view-replay")} end
    if g.replay then bf.add{type="button",name="ddz_replay_export",caption=DDZ_L("export-replay")} end
    local ready=g.next_ready and g.next_ready[p.index]
    bf.add{type="button",name="ddz_restart",caption=ready and DDZ_L("cancel-next") or DDZ_L("restart")}
    add_sound_toggle_button(bf,p)
    bf.add{type="button",name="ddz_leave_table",caption=DDZ_L("leave-table")}
end

local function add_card_tracker(parent,g,pid)
    local stat_vals={"大王","小王","2","A","K","Q","J","10","9","8","7","6","5","4","3"}
    local pc=g.played_cards or {}
    local pc_suits=g.played_suits or {}
    local my_counts={}
    local my_suits={}
    for _,c in ipairs(g.hands[pid] or {}) do
        my_counts[c.val]=(my_counts[c.val] or 0)+1
        if c.suit and c.suit~="" then
            my_suits[c.val]=my_suits[c.val] or {}
            my_suits[c.val][c.suit]=(my_suits[c.val][c.suit] or 0)+1
        end
    end
    local tracker=parent.add{type="flow",direction="vertical"}
    tracker.style.minimal_width=TRACKER_LABEL_W+TRACKER_COL_W*#stat_vals
    tracker.style.maximal_width=TRACKER_LABEL_W+TRACKER_COL_W*#stat_vals
    local header_cells={}
    local total_cells={}
    for _,v in ipairs(stat_vals) do
        local played=pc[v] or 0
        local mine=my_counts[v] or 0
        local maxn=VAL_MAX[v] or 0
        local remaining=math.max(0,maxn-played-mine)
        header_cells[#header_cells+1]={text=card_value_loc(v)}
        total_cells[#total_cells+1]={
            text=tostring(remaining),
            color=(remaining==0 and {r=0.28,g=0.28,b=0.28})
                or (v==stat_vals[1] and remaining>0 and {r=0.75,g=0,b=0})
                or (remaining==1 and {r=1,g=0.88,b=0.2})
                or {r=0.85,g=0.85,b=0.85},
            bold=remaining==1
        }
    end
    add_tracker_row(tracker, DDZ_L("card-tracker"), header_cells, nil, true)
    add_tracker_row(tracker, DDZ_L("remaining"), total_cells)
    for _,suit in ipairs(SUITS) do
        local row={}
        for _,v in ipairs(stat_vals) do
            if v=="大王" or v=="小王" then
                row[#row+1]={text=""}
            else
                local played_suit=(pc_suits[v] and pc_suits[v][suit]) or 0
                local mine_suit=(my_suits[v] and my_suits[v][suit]) or 0
                local rem=math.max(0,1-played_suit-mine_suit)
                row[#row+1]={
                    text=rem>0 and "1" or "",
                    color=rem==0 and {r=0.28,g=0.28,b=0.28} or tracker_suit_color(suit),
                    bold=rem>0
                }
            end
        end
        add_tracker_row(tracker, suit, row, tracker_suit_color(suit), true)
    end
    return tracker
end

local function add_top_card_tracker_section(parent,g,pid,show_tracker)
    local mid=parent.add{type="flow",direction="horizontal"}
    mid.style.horizontal_spacing=20
    local botf=mid.add{type="flow",direction="horizontal"}
    botf.style.vertical_align="top"
    local bot_label=botf.add{type="label",caption=DDZ_L("bottom-cards")}
    bot_label.style.top_padding=24
    for i,c in ipairs(g.bottom or {}) do
        add_static_card_face(botf,c,DDZ_CARD_W,DDZ_CARD_H,g.played_bottom and g.played_bottom[i])
    end
    if show_tracker then
        local tracker=add_card_tracker(mid,g,pid)
        tracker.style.top_padding=20
    end
    return mid
end

function gui_card_tracker(p,g)
    if p.gui.screen.ddz_tracker then p.gui.screen.ddz_tracker.destroy() end
    local f=p.gui.screen.add{type="frame",name="ddz_tracker",direction="vertical"}
    f.auto_center=true
    f.style.minimal_width=680
    add_titlebar(f,DDZ_L("card-tracker"),"ddz_tracker_close")
    local inner=f.add{type="frame",style="inside_shallow_frame",direction="vertical"}
    inner.style.padding=8
    add_card_tracker(inner,g,p.index)
end

local function add_opponent_play_row(parent,g,qid,is_over)
    local pf2=parent.add{type="frame",direction="vertical"}
    local role_txt=(g.landlord and qid==g.landlord) and DDZ_L("landlord-role") or DDZ_L("farmer-role")
    local is_cur=(g.phase=="playing" and g.order[g.play_turn]==qid) or (g.phase=="bidding" and g.order[g.bid_turn]==qid and not g.bid_pending and not g.redeal_pending)
    apply_player_panel_style(pf2,is_cur)
    local arrow=is_cur and "[color=1,0.9,0.1]▶ [/color]" or "   "
    local hand_n=#(g.hands[qid] or {})
    local head=pf2.add{type="flow",direction="horizontal"}
    head.style.horizontal_spacing=8
    local nl=head.add{type="label",caption=DDZ_S(arrow,pname_loc(qid),"  [",role_txt,"]  ",DDZ_L("cards-blue",hand_n))}
    if is_cur then nl.style.font="default-bold" end
    local row=pf2.add{type="flow",direction="horizontal"}
    row.style.horizontal_spacing=10
    row.style.top_padding=4
    local left=add_half_card_view(row)
    left.style.vertical_align="top"
    local qhand=g.hands[qid] or {}
    if is_over then
        add_card_group(left,qhand,DDZ_CARD_OVERLAP)
    else
        add_card_back_group(left,hand_n,DDZ_CARD_OVERLAP,1)
    end
    local right=add_half_card_view(row)
    right.style.vertical_align="top"
    local lp=g.last_play_by[qid]; local pb=g.pass_by[qid]
    if is_over then
        local fp=g.final_play
        if fp and fp.by==qid and fp.cards and #fp.cards>0 then
            add_card_group(right,fp.cards,DDZ_CARD_OVERLAP)
        else
            right.add{type="label",caption=DDZ_L("none")}
        end
    elseif pb then
        right.add{type="label",caption=DDZ_L("passed")}
    elseif lp and #lp>0 then
        add_card_group(right,lp,DDZ_CARD_OVERLAP)
    else
        right.add{type="label",caption=DDZ_L("none")}
    end
end

function gui_playing(p,g)
    clear_gui(p)
    local pid=p.index
    local is_over=(g.phase=="over")
    local turn_pid=g.order[g.play_turn]
    local hand=g.hands[pid] or {}
    local sel=g.sel[pid] or {}
    local selected={}
    for i,v in pairs(sel) do if v and hand[i] then selected[#selected+1]=hand[i] end end
    local self_play
    if is_over then
        if g.final_play and g.final_play.by==pid and g.final_play.cards and #g.final_play.cards>0 then
            self_play=g.final_play.cards
        end
    elseif g.last_play_by[pid] and #g.last_play_by[pid]>0 then
        self_play=g.last_play_by[pid]
    end

    local f=p.gui.screen.add{type="frame",name="ddz",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=680; apply_win_pos(p,f)
    add_titlebar(f,DDZ_L("title-table",g.tid),"ddz_close")

    add_top_card_tracker_section(f,g,pid,false)
    f.add{type="line"}

    local hdr=f.add{type="flow",direction="vertical"}
    hdr.style.vertical_spacing=6
    for _,qid in ipairs(g.order) do
        if qid~=pid then
            add_opponent_play_row(hdr,g,qid,is_over)
        end
    end

    local self_panel=f.add{type="frame",direction="vertical"}
    apply_player_panel_style(self_panel, not is_over and turn_pid==pid)

    local status_row=self_panel.add{type="flow",direction="horizontal"}
    status_row.style.horizontal_spacing=8
    local self_role_txt=(g.landlord and pid==g.landlord) and DDZ_L("landlord-role") or DDZ_L("farmer-role")
    local self_arrow=(not is_over and turn_pid==pid) and "[color=1,0.9,0.1]▶[/color]" or "   "
    local self_name=status_row.add{type="label",caption=DDZ_S(self_arrow,pname_loc(pid),"  [",self_role_txt,"]  ",DDZ_L("cards-blue",#hand))}
    if not is_over and turn_pid==pid then self_name.style.font="default-bold" end

    local trusting=storage.ddz.trustees and storage.ddz.trustees[pid]
    if is_over then
        status_row.add{type="label",caption=DDZ_L("phase-over")}
    elseif turn_pid==pid and trusting then
        status_row.add{type="label",caption=DDZ_L("trustee-play")}
    elseif turn_pid==pid then
        if #selected>0 then
            local st=get_type(selected)
            if st then
                status_row.add{type="label",caption=DDZ_S("[color=0.4,1,0.4][",type_name_loc(st.tp),"][/color]")}
            else
                status_row.add{type="label",caption=DDZ_L("invalid-type")}
            end
        else
            status_row.add{type="label",caption="请选择要出的牌"}
        end
    else
        status_row.add{type="label",caption=DDZ_L("wait-play",pname_loc(turn_pid))}
    end

    if g.msg[pid] then
        local ml=status_row.add{type="label",caption=ddz_message_caption(g.msg[pid])}
        ml.style.font_color={r=1,g=0.2,b=0.2}
    end
    if (not is_over) and g.turn_tick then
        local rem=math.max(0,TURN_TIMEOUT-(game.tick-g.turn_tick))
        local secs=math.ceil(rem/60)
        local key=secs<=5 and "timeout-trust-danger" or "timeout-trust-normal"
        local cd=status_row.add{type="label",name="ddz_countdown",caption=DDZ_L(key,secs)}
        cd.style.font="default-bold"
    end

    local self_row=self_panel.add{type="flow",direction="horizontal"}
    self_row.style.horizontal_spacing=16
    self_row.style.vertical_align="top"

    if #hand>0 then
        local hand_box=self_row.add{type="flow",direction="vertical"}
        hand_box.style.maximal_width=540
        if is_over then
            add_card_group(hand_box,hand,DDZ_CARD_OVERLAP)
        else
            if not g.sel[pid] then g.sel[pid]={} end
            add_hand_cards_panel(hand_box,hand,g.sel[pid])
        end
    end

    local play_box=self_row.add{type="flow",direction="horizontal"}
    play_box.style.vertical_align="top"
    if self_play and #self_play>0 then
        add_card_group(play_box,self_play,DDZ_CARD_OVERLAP)
    else
        play_box.add{type="label",caption=DDZ_L("none")}
    end

    if is_over then
        local over_box=f.add{type="frame",direction="vertical"}
        over_box.style="inside_shallow_frame"
        over_box.style.padding=6
        add_game_over_panel(over_box,p,g)
        return
    end

    local primary_row=self_panel.add{type="flow",direction="horizontal"}
    primary_row.style.horizontal_spacing=4
    primary_row.add{type="button",name="ddz_hint",caption=DDZ_L("hint")}
    primary_row.add{type="button",name="ddz_play",caption=DDZ_L("play")}
    primary_row.add{type="button",name="ddz_pass",caption=DDZ_L("pass")}
    primary_row.add{type="button",name="ddz_tracker_open",caption=DDZ_L("card-tracker")}

    local action_row=self_panel.add{type="flow",direction="horizontal"}
    action_row.style.horizontal_spacing=4
    action_row.add{type="button",name="ddz_trust_toggle",caption=trusting and DDZ_L("cancel-trustee") or DDZ_L("trustee")}
    action_row.add{type="button",name="ddz_rules_open",caption=DDZ_L("rules")}
    add_sound_toggle_button(action_row,p)
    style_danger_button(action_row.add{type="button",name="ddz_quit",caption=DDZ_L("quit-round")})
end

function gui_over(p,g)
    gui_playing(p,g)
end

function gui_spectator(p,g)
    clear_gui(p)
    local f=p.gui.screen.add{type="frame",name="ddz",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=940; apply_win_pos(p,f)
    add_titlebar(f,DDZ_L("title-spectator",g.tid),"ddz_watch_close")
    add_top_card_tracker_section(f,g,p.index,false)
    f.add{type="line"}
    local hdr=f.add{type="flow",direction="vertical"}
    hdr.style.vertical_spacing=6
    for _,qid in ipairs(g.order) do
        local pf2=hdr.add{type="frame",direction="vertical"}
        local is_cur=(g.phase=="playing" and g.order[g.play_turn]==qid) or (g.phase=="bidding" and g.order[g.bid_turn]==qid and not g.bid_pending and not g.redeal_pending)
        apply_player_panel_style(pf2,is_cur)
        local role_txt=(g.landlord and qid==g.landlord) and DDZ_L("landlord-role") or DDZ_L("farmer-role")
        local arrow=is_cur and "[color=1,0.9,0.1]▶[/color]" or "   "
        local hand_n=#(g.hands[qid] or {})
        local head=pf2.add{type="flow",direction="horizontal"}
        head.style.horizontal_spacing=8
        local nl=head.add{type="label",caption=DDZ_S(arrow,pname_loc(qid),"  [",role_txt,"]  ",DDZ_L("cards-blue",hand_n))}
        if is_cur then nl.style.font="default-bold" end
        local row=pf2.add{type="flow",direction="horizontal"}
        row.style.horizontal_spacing=10
        row.style.top_padding=4
        local left=row.add{type="flow",direction="horizontal"}
        left.style.vertical_align="top"
        local qhand=g.hands[qid] or {}
        if g.phase=="over" then
            add_card_group(left,qhand,DDZ_CARD_OVERLAP)
        else
            add_card_back_group(left,hand_n,DDZ_CARD_OVERLAP,1)
        end
        local right=row.add{type="flow",direction="horizontal"}
        right.style.vertical_align="top"
        local lp=g.last_play_by[qid]; local pb=g.pass_by[qid]
        if g.phase=="over" then
            local fp=g.final_play
            if fp and fp.by==qid and fp.cards and #fp.cards>0 then
                add_card_group(right,fp.cards,DDZ_CARD_OVERLAP)
            else
                right.add{type="label",caption=DDZ_L("none")}
            end
        elseif pb then
            right.add{type="label",caption=DDZ_L("passed")}
        elseif lp and #lp>0 then
            add_card_group(right,lp,DDZ_CARD_OVERLAP)
        else
            right.add{type="label",caption=DDZ_L("none")}
        end
    end
    f.add{type="line"}
    local bf=f.add{type="flow",direction="horizontal"}
    bf.add{type="button",name="ddz_watch_close",caption=DDZ_L("exit-spectator")}
    bf.add{type="button",name="ddz_rules_open",caption=DDZ_L("rules")}
    add_sound_toggle_button(bf,p)
end

function ensure_stat(name)
    local d=storage.ddz
    if not d.stats then d.stats={} end
    if not d.stats[name] then d.stats[name]={w=0,l=0,e=0} end
    return d.stats[name]
end

function gui_stats(p)
    if p.gui.screen.ddz_stats then p.gui.screen.ddz_stats.destroy(); return end
    local d=storage.ddz
    local f=p.gui.screen.add{type="frame",name="ddz_stats",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=460
    add_titlebar(f,DDZ_L("title-stats"),"ddz_stats_close")

    if not d.stats or not next(d.stats) then
        f.add{type="label",caption=DDZ_L("no-stats")}
        return
    end

    local hf=f.add{type="flow",direction="horizontal"}
    local function hcol(txt,w)
        local l=hf.add{type="label",caption=txt}
        l.style.font="default-bold"; l.style.minimal_width=w
    end
    hcol(DDZ_L("stats-player"),130); hcol(DDZ_L("stats-win"),60); hcol(DDZ_L("stats-loss"),60); hcol(DDZ_L("stats-escape"),60)
    hcol(DDZ_L("stats-total"),65); hcol(DDZ_L("stats-rate"),65)
    f.add{type="line"}

    local rows={}
    for name,s in pairs(d.stats) do
        local total=s.w+s.l
        rows[#rows+1]={name=name,s=s,total=total,rate=total>0 and s.w/total or 0}
    end
    table.sort(rows,function(a,b) return a.rate>b.rate end)

    local sc=f.add{type="scroll-pane",direction="vertical"}
    sc.style.maximal_height=320
    for _,row in ipairs(rows) do
        local s=row.s
        local rf=sc.add{type="flow",direction="horizontal"}
        local function col(txt,w)
            local l=rf.add{type="label",caption=txt}; l.style.minimal_width=w
        end
        col(row.name,130)
        col(tostring(s.w),60)
        col(tostring(s.l),60)
        local ec=s.e or 0
        local et=ec>0 and ("[color=1,0.35,0.35]"..ec.."[/color]") or "0"
        col(et,60)
        col(tostring(row.total),65)
        local rate_txt=row.total>0
            and (math.floor(row.rate*1000+0.5)/10 .."%") or ""
        col(rate_txt,65)
    end

    f.add{type="line"}
    local nl=f.add{type="label",caption=DDZ_L("stats-note")}
    nl.style.font_color={r=0.5,g=0.5,b=0.5}; nl.style.single_line=false
end

QR_DATA={
"00000000000000000000000000000000000000000000000000000000000000000000000",
"01111111001000110001000111110001100010100011000000100011000111011111110",
"01000001011110110101111001000001101001011100101011111001111000010000010",
"01011101001101011000110111010110010011010010101111110100011100010111010",
"01011101010101100011010001100111101011010011100111011001100001010111010",
"01011101000111011111100011001010111111101111101000101111111101010111010",
"01000001011000101010111010101100010001010111100111011101111100010000010",
"01111111010101010101010101010101010101010101010101010101010101011111110",
"00000000001011001111111110011111110001111001100110011111010111000000000",
"01111101111110011011010010000011111111100000100101000011101100101010100",
"01011110100011010011101111110010001110101111010011101111010011101001000",
"01110101010000011101111010010001110001000101101111000110101000110110100",
"01011100100111001110001111100011100001100010001100101111011010111011010",
"00011011101011001111000001001011001011000010101111000001101011110001100",
"00110010011101110010101111010000101000101111000011001111011011101011110",
"00011101100110001110111111001110010111010000011001111100110111011101100",
"01111100001101001000001111001010100010101100111101001100011000000111010",
"01101001110110011110010011101111000010000001101011010000100100100010110",
"00000110111000111001101111010000101000100111100001101011110011100101110",
"00110011101110101000011001000011011111100001100000011100001111110111100",
"00101110001000011000100111100010100011011011011010001011101111011111000",
"00110011101110000111100000101011001000000001100111110000101110110010010",
"01100010110101101110101111010001100000101011010000101001100001000110100",
"01111111001010110111010100000101010101101001001010010010011000111010100",
"00000100000010111000100111001001101001011010101000011101110101011111000",
"01011011010111111011010000100111010100000011100011110000101100000011100",
"01101100110000100100100111101000100110101101000000101011100001101111110",
"01110001111101101100000010101100110001000010011101100010010111100111100",
"00000010011100000100001110010001100011000000110000011001010001000011110",
"00100011010010011111110010100101111100110010100111100011101110010010100",
"01111000110010000001001011011010001000001011100000100011110001000011010",
"00000011110111010001000111010000100011111111010000011110111101110001100",
"01101000110000011111011010100011101000100100111111101100100111101111100",
"01001111111100000001010001101111011111110010101111100001100101111110000",
"01110100011001100011101011010001110001100011100000000111100011000101010",
"00101101011000111111010100001010110101011100001101011011001111010110100",
"01011100011001011010110001010011110001000101110101110001010001000111010",
"01110111110000001111110010101011111111001011101111100000100101111110000",
"01010100111001010000000001010000101100000011010011000111111011101011000",
"01010011100100001100000000100111011000110010100011110111001101100101100",
"00101100111101011001010001010111111111101001001010100001011010010111100",
"00110001111011100011110011101001010010010011100111100010100001100011010",
"01101010011110001011000111110010101011100011011011101011010000110000010",
"00010101110110010010000111101111001110010000100101100000111000101111100",
"01000010100111111001100111000111110001100111000000110111011010000011110",
"01110011111010001001010010101111000000001001100011010001100100011111100",
"00100010010111110010100101011001110101100011100011100011111001010001010",
"00011101010111110110000011100100001110001110011100000000000101101101100",
"01001010101110101000010001000000111101111111010111110111010110101111100",
"01110001101011011010010011000111000010000011101111110001100000000110010",
"01111000110101000001101111110001010001100011010000100011011011000000010",
"00001101110000001111101101111100000000111110101101110111101110100001010",
"00010110101101000001010001000000011111100000111101011011110010000111100",
"01010111111101010011110001001011010011110001000011100010101101111101000",
"00110000100101100001001011010011010100101011011010001111100011011011010",
"01101011110101010011111000000110001110000001000101110000101111001100100",
"00110100111011101111101001101011100111000100100100011001010100011111000",
"01111001001100101011110010101101110011010010100011000011100001010111110",
"01111110100101100111100001100010111000100011111001101011100001011001100",
"01010111000100111101011101001111011011110110100100010100100010000000100",
"01000000100110110110001100101001111111010001011110111101011110110011000",
"01001101111111001111011000101011111111100000100011000011100001111111100",
"00000000011100000011100111110000110001101111110001000001010001000101110",
"01111111011100011101000001110010110101011000111000110110101111010110000",
"01000001001010101111101011100110110001101000010101001111000111000101110",
"01011101010001111001011010101111011111100011001011111011100111111110100",
"01011101011000000011100101011011110000101001100001101011110000100000000",
"01011101010100001000111100101011000000001110000111010100100111010001000",
"01000001010100001100111011100011111000110010111000000101111011100011000",
"01111111010110110011010010000101000011100000000111101010101111101000100",
"00000000000000000000000000000000000000000000000000000000000000000000000",
}

DISCORD_QR_DATA={
"0000000000000000000000000000000000000",
"0000000000000000000000000000000000000",
"0000000000000000000000000000000000000",
"0000000000000000000000000000000000000",
"0000111111100100010010000011111110000",
"0000100000101111001111111010000010000",
"0000101110100101011010110010111010000",
"0000101110100010011101111010111010000",
"0000101110101100001000010010111010000",
"0000100000100100110000110010000010000",
"0000111111101010101010101011111110000",
"0000000000000000011011011000000000000",
"0000101010100100001101001000100100000",
"0000111100011001101100011110010010000",
"0000000010110011010001101101001110000",
"0000011011010101100101011011000100000",
"0000001000100101000010000110010110000",
"0000011101001011110111000010010010000",
"0000100000110110001110000011010110000",
"0000111011010000111011001111010100000",
"0000111111100011101100011111010110000",
"0000010111011101001101000110011010000",
"0000100101111100010001100111100110000",
"0000010010011111100101101101110100000",
"0000101100101010100010001111100000000",
"0000000000001100110110011000101110000",
"0000111111100000101111111010110110000",
"0000100000100111011011001000110100000",
"0000101110101100101100101111100100000",
"0000101110100011011100001101101000000",
"0000101110101000000001011001110010000",
"0000100000100011000100011011000100000",
"0000111111101010110010011001100110000",
"0000000000000000000000000000000000000",
"0000000000000000000000000000000000000",
"0000000000000000000000000000000000000",
"0000000000000000000000000000000000000",
}

local function render_qr_rows(data)
    local rows={}
    local B="[color=1,1,1]\226\150\136[/color]"
    local W="[color=0.13,0.10,0.07]\226\150\136[/color]"
    for _,row in ipairs(data) do
        local buf={}
        for j=1,#row do
            buf[j]=row:sub(j,j)=="1" and B or W
        end
        rows[#rows+1]=table.concat(buf)
    end
    return rows
end
local function crop_qr_quiet_zone(data, trim)
    if trim<=0 or #data<=trim*2 or #data[1]<=trim*2 then return data end
    for i=1,trim do
        if data[i]:find("1",1,true) then return data end
        if data[#data-i+1]:find("1",1,true) then return data end
    end
    for _,row in ipairs(data) do
        if row:sub(1,trim):find("1",1,true) then return data end
        if row:sub(#row-trim+1):find("1",1,true) then return data end
    end
    local out={}
    for i=trim+1,#data-trim do
        out[#out+1]=data[i]:sub(trim+1,#data[i]-trim)
    end
    return out
end

QR_ROWS_RENDERED=render_qr_rows(crop_qr_quiet_zone(QR_DATA,2))
DISCORD_QR_ROWS_RENDERED=render_qr_rows(crop_qr_quiet_zone(DISCORD_QR_DATA,2))

local function gui_qr_rows(p,name,title,close_name,rows)
    local old=p.gui.screen[name]
    if old then old.destroy(); return end
    local f=p.gui.screen.add{type="frame",name=name,direction="vertical"}
    f.auto_center=true
    add_titlebar(f,title,close_name)
    local qf=f.add{type="flow",direction="vertical"}
    qf.style.vertical_spacing=0
    qf.style.top_margin=2
    qf.style.bottom_margin=4
    for _,line in ipairs(rows) do
        for _=1,2 do
            local lbl=qf.add{type="label",caption=line}
            lbl.style.font="default-small"
            lbl.style.top_padding=0; lbl.style.bottom_padding=0
            lbl.style.maximal_height=6
        end
    end
end

function gui_qr(p)
    gui_qr_rows(p,"ddz_qr",DDZ_L("qq-title"),"ddz_qr_close",QR_ROWS_RENDERED)
end

function gui_discord_qr(p)
    gui_qr_rows(p,"ddz_discord_qr",DDZ_L("discord-title"),"ddz_discord_qr_close",DISCORD_QR_ROWS_RENDERED)
end

local function is_all_real_three(g)
    if not g or #g.order~=3 then return false end
    for _,pid in ipairs(g.order) do
        if is_ai(pid) then return false end
    end
    return true
end

function gui_quit_confirm(p,g)
    if p.gui.screen.ddz_quit_confirm then p.gui.screen.ddz_quit_confirm.destroy() end
    local f=p.gui.screen.add{type="frame",name="ddz_quit_confirm",direction="vertical"}
    f.style.minimal_width=276
    f.style.maximal_width=276
    local bar=f.add{type="flow",direction="horizontal"}
    bar.drag_target=f
    local title=bar.add{type="label",style="frame_title",caption=DDZ_L("title-confirm")}
    title.drag_target=f
    local drag=bar.add{type="empty-widget",style="draggable_space_header"}
    drag.style.horizontally_stretchable=true
    drag.style.height=24
    drag.drag_target=f
    local msg=DDZ_L("confirm-quit")
    if is_all_real_three(g) then
        msg=DDZ_S(msg,"\n",DDZ_L("confirm-quit-stat"))
    end
    local box=f.add{type="frame",style="inside_shallow_frame",direction="vertical"}
    box.style.minimal_width=256
    box.style.maximal_width=256
    box.style.padding=10
    local lbl=box.add{type="label",caption=msg}
    lbl.style.single_line=false
    lbl.style.maximal_width=236
    local bf=f.add{type="flow",direction="horizontal"}
    bf.style.horizontal_spacing=8
    local back=bf.add{type="button",style="back_button",name="ddz_quit_confirm_return",caption=DDZ_L("back")}
    back.style.width=124
    back.style.maximal_width=124
    local quit=bf.add{type="button",style="red_confirm_button",name="ddz_quit_confirm_ok",caption=DDZ_L("quit")}
    quit.style.width=124
    quit.style.maximal_width=124
    align_quit_confirm(p)
end

local function save_qr_svg_data(player,data,filename,label)
    local sc=6
    local sz=(#data[1])*sc
    local parts={
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<svg xmlns="http://www.w3.org/2000/svg" width="'..sz..'" height="'..sz..'">',
        '<rect width="'..sz..'" height="'..sz..'" fill="white"/>',
    }
    for i,row in ipairs(data) do
        local y=(i-1)*sc
        for j=1,#row do
            if row:sub(j,j)=="1" then
                local x=(j-1)*sc
                parts[#parts+1]='<rect x="'..x..'" y="'..y..'" width="'..sc..'" height="'..sc..'" fill="black"/>'
            end
        end
    end
    parts[#parts+1]='</svg>'
    helpers.write_file(filename,table.concat(parts,"\n"),false,player.index)
    local display_filename=filename:gsub("/","\\")
    player.print(DDZ_L("qr-saved",label,display_filename))
end

function save_qr_svg(player)
    save_qr_svg_data(player,QR_DATA,"ddz_qq_qr.svg",DDZ_L("qq-qr"))
end

function save_discord_qr_svg(player)
    save_qr_svg_data(player,DISCORD_QR_DATA,"ddz_discord_qr.svg",DDZ_L("discord-qr"))
end

function tick_to_str(t)
    local s=math.floor(t/60)
    return string.format("%d:%02d:%02d",math.floor(s/3600),math.floor(s/60)%60,s%60)
end

function gui_about(p)
    if p.gui.screen.ddz_about then p.gui.screen.ddz_about.destroy() end
    local d=storage.ddz
    if not d.feedback   then d.feedback={} end
    if not d.fb_editing then d.fb_editing={} end
    local pid=p.index
    local edit_idx=d.fb_editing[pid]
    local editing=(edit_idx~=nil and d.feedback[edit_idx]~=nil
                   and d.feedback[edit_idx].player==p.name)

    local f=p.gui.screen.add{type="frame",name="ddz_about",direction="vertical"}
    f.auto_center=true; f.style.minimal_width=520
    add_titlebar(f,DDZ_L("title-about"),"ddz_about_close")

    local tl=f.add{type="label",caption=DDZ_L("made-by")}
    tl.style.font="default-bold"; tl.style.top_margin=4; tl.style.bottom_margin=6

    local bf0=f.add{type="flow",direction="horizontal"}
    bf0.add{type="button",name="ddz_about_qr_show",caption=DDZ_L("scan-qq")}
    bf0.add{type="button",name="ddz_about_discord_qr_show",caption=DDZ_L("scan-discord")}
    local bf1=f.add{type="flow",direction="horizontal"}
    bf1.style.top_margin=4
    bf1.add{type="button",name="ddz_about_qr_save",caption=DDZ_L("export-qq")}
    bf1.add{type="button",name="ddz_about_discord_qr_save",caption=DDZ_L("export-discord")}

    f.add{type="line"}
    local hint=editing and DDZ_L("feedback-edit-hint")
                        or DDZ_L("feedback-new-hint")
    f.add{type="label",caption=hint}
    local tb=f.add{type="text-box",name="ddz_about_feedback"}
    tb.style.width=500; tb.style.height=64
    if editing then tb.text=d.feedback[edit_idx].text end

    local bf2=f.add{type="flow",direction="horizontal"}
    bf2.add{type="button",name="ddz_about_save",caption=editing and DDZ_L("save-edit") or DDZ_L("save-feedback")}
    bf2.add{type="button",name="ddz_feedback_export",caption=DDZ_L("export-feedback")}
    if editing then bf2.add{type="button",name="ddz_fb_cancel",caption=DDZ_L("cancel")} end

    if #d.feedback>0 then
        f.add{type="line"}
        local hl=f.add{type="label",caption=DDZ_L("saved-feedback")}
        hl.style.font="default-bold"
        local sc2=f.add{type="scroll-pane",direction="vertical"}
        sc2.style.maximal_height=200; sc2.style.width=508
        for i,fb in ipairs(d.feedback) do
            if i>1 then sc2.add{type="line"} end
            local hf=sc2.add{type="flow",direction="horizontal"}
            hf.add{type="label",
                caption="[color=0.9,0.75,0]"..fb.player.."[/color]"
            }.style.minimal_width=110
            if fb.tick then
                hf.add{type="label",
                    caption="[color=0.45,0.45,0.45]"..tick_to_str(fb.tick).."[/color]"
                }.style.minimal_width=68
            end
            local sp=hf.add{type="label",caption=""}
            sp.style.horizontally_stretchable=true
            if fb.player==p.name then
                hf.add{type="button",name="ddz_fb_edit_"..i,caption=DDZ_L("edit")}
            end
            if fb.player==p.name or p.admin then
                hf.add{type="button",name="ddz_fb_del_"..i,caption=DDZ_L("delete")}
            end
            local tr=sc2.add{type="flow",direction="horizontal"}
            local mtl=tr.add{type="label",caption=fb.text}
            mtl.style.single_line=false; mtl.style.maximal_width=496
        end
    end
end

function record_stats(g, winner_pid)
    if #g.order~=3 then return end
    for _,pid in ipairs(g.order) do if is_ai(pid) then return end end
    local landlord_won=(winner_pid==g.landlord)
    for _,pid in ipairs(g.order) do
        local s=ensure_stat(pname(pid))
        local won=(pid==g.landlord)==landlord_won
        if won then s.w=s.w+1 else s.l=s.l+1 end
    end
end

function record_escape(pid, g)
    if is_ai(pid) then return end
    if g then
        for _,qid in ipairs(g.order) do
            if is_ai(qid) then return end
        end
    end
    local s=ensure_stat(pname(pid))
    s.e=(s.e or 0)+1
end

rebuild_one=function(p)
    local d=storage.ddz; local pid=p.index
    if d.panel_hidden and d.panel_hidden[pid] then
        clear_gui(p)
        align_quit_confirm(p)
        return
    end
    local tid=d.seat[pid]
    if not tid then
        local watch_tid=d.spectating and d.spectating[pid]
        local wg=watch_tid and d.tables[watch_tid]
        if wg then gui_spectator(p,wg)
        else if d.spectating then d.spectating[pid]=nil end; gui_lobby(p) end
        align_quit_confirm(p); return
    end
    local g=d.tables[tid]
    if not g then d.seat[pid]=nil; gui_lobby(p); align_quit_confirm(p); return end
    if     g.phase=="waiting" then gui_waiting(p,g)
    elseif g.phase=="over"    then gui_over(p,g)
    elseif player_in_table(g,pid) then
        if     g.phase=="bidding" then gui_bidding(p,g)
        elseif g.phase=="playing" then gui_playing(p,g) end
    else
        gui_lobby(p)
    end
    align_quit_confirm(p)
end
