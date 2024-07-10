extends Area2D


# Called when the node enters the scene tree for the first time.

@onready var timer = $Timer



func _on_timer_timeout():
	
	Engine.time_scale = 1.0


func _on_body_entered(body):
	
	
	
	var gameManager = get_node("/root/Game/GameManager")
	gameManager.isDead = true
	
