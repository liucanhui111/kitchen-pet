extends Node2D

@onready var notification: Label = $Notification

func _ready():
	notification.text = "点击家具互动！"

func _process(delta):
	pass
