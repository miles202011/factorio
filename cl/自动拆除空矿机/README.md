Factorio 2.0 中矿机采矿半径属性名从 resource_searching_radius 改为 mining_drill_radius

on_resource_depleted 只在资源耗尽那一刻触发，脚本加载前已采空的矿机不会补发事件
用 on_nth_tick(18000) 每 5 分钟全图扫描兜底
