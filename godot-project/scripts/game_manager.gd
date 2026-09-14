extends Node2D
## 游戏主管理器 - 管理全局状态、UI、交互

# ===== 游戏状态 =====
var hunger: float = 80.0
var happy: float = 75.0
var energy: float = 70.0
var clean: float = 90.0
var coins: int = 50
var level: int = 1
var exp: int = 0
var day: int = 1
var game_time: float = 0.0

# 灶台状态
var stove_on: bool = false
var cook_progress: float = 0.0
var has_food_on_table: bool = false

# 节点引用
@onready var pet = $Pet
@onready var ui = $UILayer/HUD

# 纹理资源
var pet_textures: Dictionary = {}
var item_textures: Dictionary = {}
var effect_textures: Dictionary = {}

func _ready():
	_load_textures()
	_setup_ui()
	_setup_interaction_zones()
	print("Kitchen Cat 游戏启动！")

func _load_textures():
	# 加载宠物纹理
	var pet_frames = ["idle", "walk", "run", "eat1", "eat2", "eat3", "stand", "wash", "cook"]
	for frame_name in pet_frames:
		var path = "res://assets/pet_frames/" + frame_name + ".png"
		if ResourceLoader.exists(path):
			pet_textures[frame_name] = load(path)
	
	# 加载道具纹理
	var item_names = ["fish_orange", "cake", "milk", "yarn_ball", "flower_pot", "pill", "teddy_bear", "food_blocks"]
	for item_name in item_names:
		var path = "res://assets/items/" + item_name + ".png"
		if ResourceLoader.exists(path):
			item_textures[item_name] = load(path)
	
	# 加载特效纹理
	var effect_names = ["star1", "star2", "star3", "steam", "water_drop", "flower_glow"]
	for eff_name in effect_names:
		var path = "res://assets/effects/" + eff_name + ".png"
		if ResourceLoader.exists(path):
			effect_textures[eff_name] = load(path)

func _process(delta):
	game_time += delta
	
	# 状态衰减（每秒）
	hunger = max(0, hunger - 0.3 * delta)
	happy = max(0, happy - 0.2 * delta)
	energy = max(0, energy - 0.15 * delta)
	clean = max(0, clean - 0.1 * delta)
	
	# 灶台烹饪
	if stove_on:
		cook_progress += 12.0 * delta
		if cook_progress >= 100.0:
			_cooking_done()
	
	# 检查升级
	if exp >= level * 100:
		_level_up()
	
	# 更新UI
	_update_ui()

func _cooking_done():
	stove_on = false
	cook_progress = 0.0
	has_food_on_table = true
	hunger = min(100, hunger + 25)
	coins += 5
	exp += 15
	_show_notification("🍳 做好了！+25饱食 +5金币")

func _level_up():
	level += 1
	exp = 0
	coins += 20
	_show_notification("🎉 升级到 Lv.%d！+20金币" % level)
	_spawn_effects(pet.position, "star", 10)

# ===== 交互系统 =====
func interact_with(zone_name: String):
	match zone_name:
		"fridge":
			hunger = min(100, hunger + 20)
			exp += 10
			pet.play_animation("eat")
			_spawn_effects(pet.position, "food", 3)
			_show_notification("从冰箱拿了好吃的！🍖")
		"stove":
			if not stove_on:
				stove_on = true
				cook_progress = 0.0
				pet.play_animation("cook")
				_show_notification("开始做饭了！🍳")
				exp += 5
			else:
				_show_notification("还在做呢~ ⏳")
		"sink":
			clean = min(100, clean + 25)
			energy = max(0, energy - 5)
			pet.play_animation("wash")
			_spawn_effects(pet.position, "water", 4)
			_show_notification("洗得干干净净！✨")
			exp += 8
		"window":
			happy = min(100, happy + 15)
			_show_notification("窗外风景真好~ 🌤️")
			exp += 5
		"table":
			if has_food_on_table:
				hunger = min(100, hunger + 15)
				happy = min(100, happy + 10)
				has_food_on_table = false
				pet.play_animation("eat")
				_spawn_effects(pet.position, "food", 3)
				_show_notification("享用了一顿美餐！🍽️")
				exp += 12
			else:
				happy = min(100, happy + 5)
				_show_notification("在餐桌旁休息~")
		"plant":
			happy = min(100, happy + 12)
			_spawn_effects(pet.position, "glow", 3)
			_show_notification("给绿植浇了浇水~ 🌱")
			exp += 5

func do_action(action: String):
	match action:
		"feed":
			hunger = min(100, hunger + 15)
			exp += 8
			pet.play_animation("eat")
			_spawn_effects(pet.position, "food", 3)
			_show_notification("喂了好吃的！🍖")
		"play":
			if energy < 10:
				_show_notification("太累了先休息~")
				return
			happy = min(100, happy + 20)
			energy = max(0, energy - 10)
			exp += 12
			pet.play_animation("run")
			_spawn_effects(pet.position, "star", 6)
			_show_notification("玩得好开心！🎾")
		"sleep":
			energy = min(100, energy + 30)
			hunger = max(0, hunger - 5)
			pet.play_animation("stand")
			_show_notification("睡着了~ 💤")
		"clean":
			clean = min(100, clean + 30)
			happy = min(100, happy + 5)
			exp += 6
			_spawn_effects(pet.position, "glow", 6)
			_show_notification("打扫干净！🧹")

# ===== 特效系统 =====
func _spawn_effects(pos: Vector2, type: String, count: int):
	for i in range(count):
		var effect = Sprite2D.new()
		effect.texture = effect_textures.get(type, effect_textures.get("star1"))
		effect.position = pos + Vector2(randf_range(-30, 30), randf_range(-50, -20))
		effect.scale = Vector2(0.3, 0.3)
		add_child(effect)
		# 动画
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(effect, "position:y", effect.position.y - 60, 1.0)
		tween.tween_property(effect, "modulate:a", 0.0, 1.0)
		tween.tween_property(effect, "scale", Vector2(0.5, 0.5), 1.0)
		tween.chain().tween_callback(effect.queue_free)

# ===== UI系统 =====
func _setup_ui():
	# 这里可以动态创建UI元素
	pass

func _update_ui():
	# 更新状态条显示
	var status_panel = ui.get_node_or_null("StatusPanel")
	if status_panel:
		var label = status_panel.get_node_or_null("Label")
		if label:
			label.text = "🍎%.0f 💛%.0f ⚡%.0f 🫧%.0f 🪙%d ⭐Lv.%d" % [hunger, happy, energy, clean, coins, level]

func _show_notification(text: String):
	var notif_label = ui.get_node_or_null("NotificationLabel")
	if notif_label:
		notif_label.text = text
		notif_label.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(2.0)
		tween.tween_property(notif_label, "modulate:a", 0.0, 1.0)

func _setup_interaction_zones():
	# 连接交互区域信号
	for zone in $InteractionZones.get_children():
		if zone is Area2D:
			zone.input_event.connect(_on_zone_input.bind(zone.name))

func _on_zone_input(_viewport, event, _shape_idx, zone_name):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clean_name = zone_name.replace("Zone", "").to_lower()
		interact_with(clean_name)
