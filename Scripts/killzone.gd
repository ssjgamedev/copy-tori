extends Area2D


# Called when the node enters the scene tree for the first time.

@onready var timer = $Timer



func _on_timer_timeout():
	
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _on_body_entered(body):
	
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	timer.start()
