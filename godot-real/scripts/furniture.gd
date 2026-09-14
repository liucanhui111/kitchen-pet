extends Area2D
## 家具交互 - 点击高亮、弹跳、悬停效果

@export var furniture_name: String = ""
@export var hover_scale: float = 1.05

var is_hovered := false
var original_scale := Vector2.ONE
var tw: Tween

@onready var sprite: Sprite2D = $Sprite
@onready var label: Label = $Label

func _ready():
	original_scale = sprite.scale
	input_event.connect(_on_input)
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	if label:
		label.text = furniture_name
		label.visible = false

func _on_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_click_effect()

func _click_effect():
	if tw:
		tw.kill()
	tw = create_tween()
	tw.tween_property(sprite, "scale", original_scale * 1.15, 0.1)
	tw.tween_property(sprite, "scale", original_scale * 0.95, 0.1)
	tw.tween_property(sprite, "scale", original_scale, 0.1)

func _on_hover_enter():
	is_hovered = true
	if tw:
		tw.kill()
	tw = create_tween()
	tw.tween_property(sprite, "scale", original_scale * hover_scale, 0.15)
	tw.tween_property(sprite, "modulate", Color(1.1, 1.1, 1.05), 0.15)
	if label:
		label.visible = true

func _on_hover_exit():
	is_hovered = false
	if tw:
		tw.kill()
	tw = create_tween()
	tw.tween_property(sprite, "scale", original_scale, 0.15)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	if label:
		label.visible = false
