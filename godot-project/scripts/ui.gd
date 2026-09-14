extends Control
## UI管理器 - 处理状态条、按钮、商店、通知

@onready var game_manager = get_tree().get_first_node_in_group("game_manager")

# UI元素
var hunger_bar: ProgressBar
var happy_bar: ProgressBar
var energy_bar: ProgressBar
var clean_bar: ProgressBar
var coins_label: Label
var level_label: Label
var notification_label: Label

# 商店
var shop_panel: Panel
var shop_open: bool = false

func _ready():
	_create_ui()
	# 添加到组
	add_to_group("ui")

func _create_ui():
	# 状态面板
	var status_panel = $StatusPanel
	status_panel.custom_minimum_size = Vector2(340, 55)
	
	var status_vbox = VBoxContainer.new()
	status_vbox.position = Vector2(10, 5)
	status_panel.add_child(status_vbox)
	
	# 状态条
	var bars_hbox1 = HBoxContainer.new()
	bars_hbox1.add_theme_constant_override("separation", 10)
	status_vbox.add_child(bars_hbox1)
	
	hunger_bar = _create_status_bar("🍎 饱食", Color.RED)
	happy_bar = _create_status_bar("💛 心情", Color.YELLOW)
	bars_hbox1.add_child(hunger_bar)
	bars_hbox1.add_child(happy_bar)
	
	var bars_hbox2 = HBoxContainer.new()
	bars_hbox2.add_theme_constant_override("separation", 10)
	status_vbox.add_child(bars_hbox2)
	
	energy_bar = _create_status_bar("⚡ 体力", Color.GREEN)
	clean_bar = _create_status_bar("🫧 清洁", Color.CYAN)
	bars_hbox2.add_child(energy_bar)
	bars_hbox2.add_child(clean_bar)
	
	# 金币和等级
	var info_hbox = HBoxContainer.new()
	info_hbox.position = Vector2(555, 10)
	info_hbox.add_theme_constant_override("separation", 15)
	add_child(info_hbox)
	
	coins_label = Label.new()
	coins_label.text = "🪙 50"
	info_hbox.add_child(coins_label)
	
	level_label = Label.new()
	level_label.text = "⭐ Lv.1"
	info_hbox.add_child(level_label)
	
	# 底部操作栏
	var action_bar = $ActionBar
	action_bar.add_theme_constant_override("separation", 8)
	
	var actions = [
		{"icon": "🍖", "label": "喂食", "action": "feed"},
		{"icon": "🎾", "label": "玩耍", "action": "play"},
		{"icon": "😴", "label": "睡觉", "action": "sleep"},
		{"icon": "🧹", "label": "打扫", "action": "clean"},
		{"icon": "🛒", "label": "商店", "action": "shop"},
	]
	
	for action_data in actions:
		var btn = Button.new()
		btn.text = action_data["icon"] + "\n" + action_data["label"]
		btn.custom_minimum_size = Vector2(60, 50)
		btn.pressed.connect(_on_action_pressed.bind(action_data["action"]))
		action_bar.add_child(btn)
	
	# 通知标签
	notification_label = $NotificationLabel
	notification_label.text = ""
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _create_status_bar(label_text: String, color: Color) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(label)
	
	var bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(120, 10)
	bar.max_value = 100
	bar.value = 75
	bar.show_percentage = false
	
	# 设置样式
	var style = StyleBoxFlat.new()
	style.bg_color = color.darkened(0.5)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", style)
	
	vbox.add_child(bar)
	return vbox

func _process(_delta):
	_update_bars()

func _update_bars():
	if not game_manager:
		return
	
	hunger_bar.get_child(1).value = game_manager.hunger
	happy_bar.get_child(1).value = game_manager.happy
	energy_bar.get_child(1).value = game_manager.energy
	clean_bar.get_child(1).value = game_manager.clean
	coins_label.text = "🪙 %d" % game_manager.coins
	level_label.text = "⭐ Lv.%d" % game_manager.level

func _on_action_pressed(action: String):
	if not game_manager:
		return
	
	if action == "shop":
		_toggle_shop()
		return
	
	game_manager.do_action(action)

func _toggle_shop():
	shop_open = !shop_open
	if shop_open:
		_show_shop()
	else:
		_hide_shop()

func _show_shop():
	# 创建商店面板
	shop_panel = Panel.new()
	shop_panel.custom_minimum_size = Vector2(400, 350)
	shop_panel.position = Vector2(250, 400)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	shop_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "🛒 宠物商店"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var items = [
		{"name": "高级猫粮", "icon": "🥩", "price": 20},
		{"name": "毛线球", "icon": "🧶", "price": 15},
		{"name": "能量饮料", "icon": "🧴", "price": 25},
		{"name": "泡泡浴", "icon": "🛁", "price": 30},
		{"name": "小鱼干", "icon": "🐟", "price": 10},
	]
	
	for item in items:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		vbox.add_child(hbox)
		
		var name_label = Label.new()
		name_label.text = item["icon"] + " " + item["name"]
		hbox.add_child(name_label)
		
		var buy_btn = Button.new()
		buy_btn.text = "🪙 %d" % item["price"]
		buy_btn.pressed.connect(_on_buy_item.bind(item))
		hbox.add_child(buy_btn)
	
	var close_btn = Button.new()
	close_btn.text = "关闭"
	close_btn.pressed.connect(_hide_shop)
	vbox.add_child(close_btn)
	
	add_child(shop_panel)

func _hide_shop():
	if shop_panel:
		shop_panel.queue_free()
		shop_panel = null
	shop_open = false

func _on_buy_item(item: Dictionary):
	if not game_manager:
		return
	
	if game_manager.coins >= item["price"]:
		game_manager.coins -= item["price"]
		# 应用效果
		match item["name"]:
			"高级猫粮":
				game_manager.hunger = min(100, game_manager.hunger + 40)
			"毛线球":
				game_manager.happy = min(100, game_manager.happy + 30)
			"能量饮料":
				game_manager.energy = min(100, game_manager.energy + 50)
			"泡泡浴":
				game_manager.clean = 100
				game_manager.happy = min(100, game_manager.happy + 15)
			"小鱼干":
				game_manager.hunger = min(100, game_manager.hunger + 15)
				game_manager.happy = min(100, game_manager.happy + 10)
		
		game_manager._spawn_effects(game_manager.pet.position, "glow", 5)
		notification_label.text = "购买了 %s %s！" % [item["icon"], item["name"]]
	else:
		notification_label.text = "金币不够~ 💸"
