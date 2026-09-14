extends CharacterBody2D

var move_speed: float = 150.0
var target_position: Vector2 = Vector2.ZERO
var current_state: String = "idle"
var state_timer: float = 0.0
var anim_frame: int = 0
var anim_timer: float = 0.0
var auto_timer: float = 3.0
var bob_offset: float = 0.0

var sprite: Sprite2D
var game_manager: Node

func _ready():
	sprite = $Sprite
	game_manager = get_parent()
	target_position = position
	
	var collision = $CollisionShape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 80)
	collision.shape = shape
	
	_update_sprite("idle")

func _physics_process(delta):
	bob_offset += delta * 3.0
	
	if current_state == "idle":
		var bob = sin(bob_offset) * 3.0
		sprite.position.y = -80 + bob
	elif current_state == "walking":
		var direction = (target_position - position).normalized()
		var distance = position.distance_to(target_position)
		
		if distance > 10.0:
			velocity = direction * move_speed
			move_and_slide()
			if direction.x != 0:
				sprite.flip_h = direction.x < 0
			_update_sprite("walk" if anim_frame % 2 == 0 else "run")
			var bob = sin(bob_offset * 2) * 5.0
			sprite.position.y = -80 + bob
		else:
			velocity = Vector2.ZERO
			current_state = "idle"
			_update_sprite("idle")
	
	anim_timer += delta
	if anim_timer >= 0.15:
		anim_timer = 0.0
		anim_frame += 1
	
	if state_timer > 0:
		state_timer -= delta
		if state_timer <= 0:
			current_state = "idle"
			_update_sprite("idle")
	
	auto_timer -= delta
	if auto_timer <= 0 and current_state == "idle":
		_do_auto_behavior()
		auto_timer = randf_range(3.0, 8.0)

func move_to_target(target: Vector2):
	target_position = target
	current_state = "walking"

func play_animation(anim_name: String):
	match anim_name:
		"eat":
			current_state = "eating"
			state_timer = 2.0
			_update_sprite("eat1")
		"sleep", "stand":
			current_state = "sleeping"
			state_timer = 3.0
			_update_sprite("stand")
		"play", "run":
			current_state = "playing"
			state_timer = 2.0
			_update_sprite("run")
		"wash":
			current_state = "washing"
			state_timer = 2.0
			_update_sprite("wash")
		"cook":
			current_state = "cooking"
			state_timer = 2.0
			_update_sprite("cook")
		_:
			current_state = "idle"
			_update_sprite("idle")

func _update_sprite(texture_name: String):
	if game_manager and game_manager.pet_textures.has(texture_name):
		sprite.texture = game_manager.pet_textures[texture_name]

func _do_auto_behavior():
	if not game_manager:
		return
	
	if game_manager.hunger < 30:
		move_to_target(Vector2(185, 495))
	elif game_manager.energy < 25:
		play_animation("stand")
	elif game_manager.happy < 30:
		move_to_target(Vector2(657, 255))
	else:
		var targets = [
			Vector2(200, 620), Vector2(400, 660), Vector2(550, 520),
			Vector2(300, 560), Vector2(650, 460)
		]
		move_to_target(targets[randi() % targets.size()])

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_state = "playing"
		state_timer = 1.0
		if game_manager:
			game_manager.happy = min(100.0, game_manager.happy + 5.0)
