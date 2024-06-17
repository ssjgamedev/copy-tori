extends StaticBody2D


var aboveLadder := false
@onready var collision_shape_2d = $CollisionShape2D

func _physics_process(delta):
	if Input.is_action_pressed("down") && aboveLadder:
		collision_shape_2d.rotation_degrees = 180
	else:
		collision_shape_2d.rotation_degrees = 0

func _on_above_checker_body_entered(body):
	print("I touched the top of ladder")
	aboveLadder = true


func _on_above_checker_body_exited(body):
	print("I am not touching the top of ladder anymore")
	aboveLadder = false
