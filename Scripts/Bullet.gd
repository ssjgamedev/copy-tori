class_name Bullet
extends CharacterBody2D

const SPEED = 100


func start(_position, _direction):
	rotation = _direction
	position = _position
	velocity = Vector2(SPEED, 0).rotated(rotation)
	


func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
			print("I collided with " + str(collision))
			queue_free()




