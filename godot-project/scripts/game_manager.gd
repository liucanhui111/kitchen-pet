extends Node2D

var hunger: float = 80.0
var happy: float = 75.0
var energy: float = 70.0
var clean: float = 90.0
var coins: int = 50
var level: int = 1
var exp: int = 0
var game_time: float = 0.0

var stove_on: bool = false
var cook_progress: float = 0.0
var has_food_on_table: bool = false

var pet: CharacterBody2D
var pet_textures: Dictionary = {}

func _ready():
	pet = $Pet
	_load_textures()
	_setup_zones()
	print("Kitchen Cat started!")

func _load_textures():
	var frames = ["idle", "walk", "run", "eat1", "eat2", "eat3", "stand", "wash", "cook"]
	for f in frames:
		var path = "res://assets/pet_frames/" + f + ".png"
		if ResourceLoader.exists(path):
			pet_textures[f] = load(path)

func _process(delta):
	game_time += delta
	hunger = max(0.0, hunger - 0.3 * delta)
	happy = max(0.0, happy - 0.2 * delta)
	energy = max(0.0, energy - 0.15 * delta)
	clean = max(0.0, clean - 0.1 * delta)
	
	if stove_on:
		cook_progress += 12.0 * delta
		if cook_progress >= 100.0:
			stove_on = false
			cook_progress = 0.0
			has_food_on_table = true
			hunger = min(100.0, hunger + 25.0)
			coins += 5
			exp += 15
	
	if exp >= level * 100:
		level += 1
		exp = 0
		coins += 20

func _setup_zones():
	for zone in $InteractionZones.get_children():
		if zone is Area2D:
			zone.input_event.connect(_on_zone_input.bind(zone.name))

func _on_zone_input(_viewport, event, _shape_idx, zone_name):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var name = zone_name.replace("Zone", "").to_lower()
		interact_with(name)

func interact_with(zone_name: String):
	match zone_name:
		"fridge":
			hunger = min(100.0, hunger + 20.0)
			exp += 10
			pet.play_animation("eat")
		"stove":
			if not stove_on:
				stove_on = true
				cook_progress = 0.0
				pet.play_animation("cook")
		"sink":
			clean = min(100.0, clean + 25.0)
			energy = max(0.0, energy - 5.0)
			pet.play_animation("wash")
		"window":
			happy = min(100.0, happy + 15.0)
		"table":
			if has_food_on_table:
				hunger = min(100.0, hunger + 15.0)
				happy = min(100.0, happy + 10.0)
				has_food_on_table = false
				pet.play_animation("eat")
			else:
				happy = min(100.0, happy + 5.0)
		"plant":
			happy = min(100.0, happy + 12.0)

func do_action(action: String):
	match action:
		"feed":
			hunger = min(100.0, hunger + 15.0)
			exp += 8
			pet.play_animation("eat")
		"play":
			if energy < 10.0:
				return
			happy = min(100.0, happy + 20.0)
			energy = max(0.0, energy - 10.0)
			exp += 12
			pet.play_animation("run")
		"sleep":
			energy = min(100.0, energy + 30.0)
			hunger = max(0.0, hunger - 5.0)
			pet.play_animation("stand")
		"clean":
			clean = min(100.0, clean + 30.0)
			happy = min(100.0, happy + 5.0)
			exp += 6
