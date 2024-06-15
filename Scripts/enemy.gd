extends Node2D
@onready var animated_sprite_2d = $AnimatedSprite2D

const speed = 40
# Called when the node enters the scene tree for the first time.
@onready var raycastDownLeft = $RayCast2DDownLeft
@onready var raycastDownRight = $RayCast2DDownRight
@onready var raycastLeft = $RayCast2DLeft
@onready var raycastRight = $RayCast2DRight
@onready var collisionShape = $Killzone/CollisionShape2D

var direction = 1

func _process(delta):
	raycastDownLeft.force_raycast_update()
	raycastDownRight.force_raycast_update()
	raycastLeft.force_raycast_update()
	raycastRight.force_raycast_update()
	if (!raycastDownLeft.is_colliding() || !raycastDownRight.is_colliding() || raycastLeft.is_colliding() || raycastRight.is_colliding()):
		direction *= -1
	if direction < 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
		
		
	position.x += direction * speed * delta
