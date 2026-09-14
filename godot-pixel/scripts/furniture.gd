extends Area2D
## 通用家具组件 - 点击切换开/关动画

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var stay_open_time: float = 3.0  # 打开后自动关闭时间，0=不自动关

var is_open := false
var auto_close_timer := 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $Anim

func _ready():
	# 设置纹理
	if closed_texture:
		sprite.texture = closed_texture
	
	# 创建开关动画
	_create_animations()
	
	# 连接输入
	input_event.connect(_on_input)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)

func _process(delta):
	# 自动关门
	if is_open and stay_open_time > 0:
		auto_close_timer -= delta
		if auto_close_timer <= 0:
			close()

func open():
	if is_open:
		return
	is_open = true
	auto_close_timer = stay_open_time
	if open_texture:
		sprite.texture = open_texture
	# 弹跳动画
	anim.play("open_bounce")

func close():
	if not is_open:
		return
	is_open = false
	if closed_texture:
		sprite.texture = closed_texture
	anim.play("close_bounce")

func toggle():
	if is_open:
		close()
	else:
		open()

func _on_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle()

func _on_hover():
	# 悬停高亮
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color(1.2, 1.2, 1.1), 0.15)

func _on_unhover():
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func _create_animations():
	# 创建 AnimationLibrary
	var lib = AnimationLibrary.new()
	
	# 打开弹跳动画
	var open_anim = Animation.new()
	open_anim.length = 0.3
	open_anim.add_track(Animation.TYPE_VALUE)
	open_anim.track_set_path(0, "Sprite:scale")
	open_anim.track_insert_key(0, 0.0, Vector2(1, 1))
	open_anim.track_insert_key(0, 0.1, Vector2(1.15, 0.9))
	open_anim.track_insert_key(0, 0.2, Vector2(0.95, 1.05))
	open_anim.track_insert_key(0, 0.3, Vector2(1, 1))
	lib.add_animation("open_bounce", open_anim)
	
	# 关闭弹跳动画
	var close_anim = Animation.new()
	close_anim.length = 0.25
	close_anim.add_track(Animation.TYPE_VALUE)
	close_anim.track_set_path(0, "Sprite:scale")
	close_anim.track_insert_key(0, 0.0, Vector2(1, 1))
	close_anim.track_insert_key(0, 0.08, Vector2(1.1, 0.92))
	close_anim.track_insert_key(0, 0.16, Vector2(0.97, 1.03))
	close_anim.track_insert_key(0, 0.25, Vector2(1, 1))
	lib.add_animation("close_bounce", close_anim)
	
	anim.add_animation_library("", lib)
