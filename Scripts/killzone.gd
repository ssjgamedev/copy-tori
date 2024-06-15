extends Area2D


# Called when the node enters the scene tree for the first time.
@onready var timer = $Timer



func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
