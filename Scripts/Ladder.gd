extends Area2D

@onready var playerReference = $"../../Player"


func _on_body_entered(body):
	
	playerReference.updateisTouchingLadder(true)



func _on_body_exited(body):
	
	playerReference.updateisTouchingLadder(false)
	playerReference.updateLadderPhysics()
