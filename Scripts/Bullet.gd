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
			velocity = velocity.bounce(collision.get_normal())
			if collision.get_collider().has_method("hit"):
				print("I am Hit")
				collision.get_collider().hit()




