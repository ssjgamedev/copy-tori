extends Area2D

@onready var playerReference = $"../../Player"


func _on_body_entered(body):
	
	playerReference.updateisTouchingLadder(true)
	print("I am touching A Ladder")


func _on_body_exited(body):
	print("I am not touching A Ladder") # Replace with function body.
	playerReference.updateisTouchingLadder(false)
	playerReference.updateLadderPhysics()
