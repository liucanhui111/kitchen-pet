extends Node2D
## 厨房场景 - 使用参考图素材，可交互家具

@onready var bg: Sprite2D = $Background
@onready var fridge: Area2D = $Furniture/Fridge
@onready var stove: Area2D = $Furniture/Stove
@onready var cabinet: Area2D = $Furniture/Cabinet

# 状态
var hunger := 80.0
var happy := 75.0

func _ready():
	print("Kitchen loaded - click furniture to interact!")

func _process(delta):
	hunger = max(0.0, hunger - 0.1 * delta)
	happy = max(0.0, happy - 0.05 * delta)
