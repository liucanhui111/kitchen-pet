extends CharacterBody2D
## 宠物角色 - 处理移动、动画、自主AI行为

# 移动参数
@export var move_speed: float = 150.0
@export var arrive_threshold: float = 10.0

# 状态
enum PetState { IDLE, WALKING, EATING, SLEEPING, PLAYING, WASHING, COOKING }
var current_state: PetState = PetState.IDLE
var state_timer: float = 0.0

# 动画
var current_animation: String = "idle"
var anim_frame: int = 0
var anim_timer: float = 0.0
var anim_speed: float = 0.15

# 目标位置
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false

# 自主行为
var auto_timer: float = 3.0
var bob_offset: float = 0.0

# 表情
var emotion: String = ""
var emotion_timer: float = 0.0

# 纹理引用
var sprite: Sprite2D
var game_manager: Node

func _ready():
	sprite = $Sprite
	game_manager = get_parent()
	target_position = position
	
	# 设置碰撞形状
	var collision = $CollisionShape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 80)
	collision.shape = shape
	
	# 设置初始纹理
	_update_sprite("idle")

func _physics_process(delta):
	bob_offset += delta * 3.0
	
	match current_state:
		PetState.IDLE:
			_process_idle(delta)
		PetState.WALKING:
			_process_walking(delta)
		PetState.EATING, PetState.SLEEPING, PetState.PLAYING, PetState.WASHING, PetState.COOKING:
			_process_action(delta)
	
	# 更新动画帧
	anim_timer += delta
	if anim_timer >= anim_speed:
		anim_timer = 0.0
		anim_frame += 1
	
	# 表情计时
	if emotion_timer > 0:
		emotion_timer -= delta
	
	# 自主行为
	auto_timer -= delta
	if auto_timer <= 0 and current_state == PetState.IDLE:
		_do_auto_behavior()
		auto_timer = randf_range(3.0, 8.0)

func _process_idle(delta):
	# 弹跳效果
	var bob = sin(bob_offset) * 3.0
	sprite.position.y = -80 + bob

func _process_walking(delta):
	var direction = (target_position - position).normalized()
	var distance = position.distance_to(target_position)
	
	if distance > arrive_threshold:
		velocity = direction * move_speed
		move_and_slide()
		
		# 翻转朝向
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
		
		# 走路动画
		_update_sprite("walk" if anim_frame % 2 == 0 else "run")
		
		# 弹跳
		var bob = sin(bob_offset * 2) * 5.0
		sprite.position.y = -80 + bob
	else:
		velocity = Vector2.ZERO
		current_state = PetState.IDLE
		_update_sprite("idle")

func _process_action(delta):
	state_timer -= delta
	if state_timer <= 0:
		current_state = PetState.IDLE
		_update_sprite("idle")

func move_to_target(target: Vector2):
	target_position = target
	current_state = PetState.WALKING
	is_moving = true

func play_animation(anim_name: String):
	match anim_name:
		"eat":
			current_state = PetState.EATING
			state_timer = 2.0
			_animate_frames(["eat1", "eat2", "eat3"], 0.3)
		"sleep":
			current_state = PetState.SLEEPING
			state_timer = 4.0
			_update_sprite("stand")
		"play":
			current_state = PetState.PLAYING
			state_timer = 3.0
			_animate_frames(["run", "walk"], 0.2)
		"wash":
			current_state = PetState.WASHING
			state_timer = 2.0
			_update_sprite("wash")
		"cook":
			current_state = PetState.COOKING
			state_timer = 2.0
			_update_sprite("cook")
		"run":
			current_state = PetState.PLAYING
			state_timer = 2.0
			_animate_frames(["run", "walk"], 0.15)
		"stand":
			current_state = PetState.SLEEPING
			state_timer = 3.0
			_update_sprite("stand")
		_:
			current_state = PetState.IDLE
			_update_sprite("idle")

func _animate_frames(frames: Array, interval: float):
	# 使用计时器切换帧
	var tween = create_tween()
	for i in range(frames.size() * 3):
		var frame_name = frames[i % frames.size()]
		tween.tween_callback(_update_sprite.bind(frame_name))
		tween.tween_interval(interval)
	tween.tween_callback(_update_sprite.bind("idle"))

func _update_sprite(texture_name: String):
	if game_manager and game_manager.pet_textures.has(texture_name):
		sprite.texture = game_manager.pet_textures[texture_name]
	current_animation = texture_name

func _do_auto_behavior():
	if not game_manager:
		return
	
	# 根据状态决定行为
	if game_manager.hunger < 30:
		# 去冰箱
		move_to_target(Vector2(185, 495))
		_show_thought("🍖")
	elif game_manager.energy < 25:
		# 休息
		play_animation("stand")
		_show_thought("💤")
	elif game_manager.happy < 30:
		# 去窗户
		move_to_target(Vector2(657, 255))
		_show_thought("☀️")
	else:
		# 随机探索
		var targets = [
			Vector2(200, 620), Vector2(400, 660), Vector2(550, 520),
			Vector2(300, 560), Vector2(650, 460), Vector2(150, 500)
		]
		move_to_target(targets[randi() % targets.size()])
		
		# 随机表情
		var emojis = ["😊", "🎵", "🌟", "💭", "🐾", "✨"]
		emotion = emojis[randi() % emojis.size()]
		emotion_timer = 2.0

func _show_thought(thought: String):
	emotion = thought
	emotion_timer = 3.0

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 摸头互动
		current_state = PetState.PLAYING
		state_timer = 1.0
		emotion = "💕"
		emotion_timer = 2.0
		if game_manager:
			game_manager.happy = min(100, game_manager.happy + 5)
			game_manager._spawn_effects(position, "star", 4)
