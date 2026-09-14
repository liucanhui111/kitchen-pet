extends Area2D
## 交互区域 - 处理鼠标悬停和点击交互

@export var zone_name: String = ""
@export var zone_label: String = ""
@export var zone_icon: String = ""

var is_hovered: bool = false
var highlight_alpha: float = 0.0
var label_node: Label

func _ready():
	# 创建碰撞形状
	var collision = $Collision
	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 100)  # 默认大小，可以在场景中调整
	collision.shape = shape
	
	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect._on_mouse_exited)
	input_event.connect._on_input_event)
	
	# 创建标签
	_create_label()

func _create_label():
	label_node = Label.new()
	label_node.text = zone_icon + " " + zone_label
	label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_node.visible = false
	label_node.position = Vector2(-50, -30)
	add_child(label_node)

func _process(delta):
	# 更新高亮效果
	if is_hovered:
		highlight_alpha = min(1.0, highlight_alpha + delta * 5.0)
	else:
		highlight_alpha = max(0.0, highlight_alpha - delta * 5.0)
	
	# 更新标签显示
	if label_node:
		label_node.visible = highlight_alpha > 0.1
		label_node.modulate.a = highlight_alpha
	
	# 重绘高亮
	queue_redraw()

func _draw():
	if highlight_alpha > 0.05:
		# 绘制高亮矩形
		var rect = Rect2(-50, -50, 100, 100)
		var color = Color(0.66, 0.85, 0.78, highlight_alpha * 0.15)
		draw_rect(rect, color)
		
		# 绘制边框
		var border_color = Color(0.66, 0.85, 0.78, highlight_alpha * 0.5)
		draw_rect(rect, border_color, false, 2.0)

func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 获取游戏管理器并调用交互
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.interact_with(zone_name)
