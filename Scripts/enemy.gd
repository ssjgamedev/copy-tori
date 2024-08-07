extends Node2D
@onready var animated_sprite_2d = $AnimatedSprite2D

const speed = 40
# Called when the node enters the scene tree for the first time.
@onready var raycastDownLeft = $RayCast2DDownLeft
@onready var raycastDownRight = $RayCast2DDownRight
@onready var raycastLeft = $RayCast2DLeft
@onready var raycastRight = $RayCast2DRight
@onready var collisionShape = $Area2D/CollisionShape2D
@onready var raycastDownCenter = $RayCast2DDownCenter
@onready var frozenCollisionShape = $StaticBody2D/CollisionShape2D


var direction = 1
var isInAir = true
var isFrozen = false

func _ready():
	frozenCollisionShape.set_deferred("disabled", true)

func _process(delta):
	raycastDownLeft.force_raycast_update()
	raycastDownRight.force_raycast_update()
	raycastLeft.force_raycast_update()
	raycastRight.force_raycast_update()
	raycastDownCenter.force_raycast_update()
	
	isInAir = !raycastDownCenter.is_colliding()
	if isInAir:
		position.y += speed * delta
	elif isFrozen:
		position.x = position.x	
	else:
		if not isFrozen:
			if (!raycastDownLeft.is_colliding() || !raycastDownRight.is_colliding()):
				direction *= -1
			if (raycastLeft.is_colliding() || raycastRight.is_colliding()):
				direction *= -1
			if direction < 0:
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false

		position.x += direction * speed * delta

	
		
	
	
func hit():
	print("I am hit")


func _on_area_2d_body_entered(body):
	if body is Bullet:
		print ("I hit a bullet")
		isFrozen = true
		collisionShape.set_deferred("disabled",true)
		frozenCollisionShape.set_deferred("disabled", false)
		animated_sprite_2d.stop()
		body.queue_free()# release the bullet
	if body is Player:
		print("I hit Player")
		var gameManager = get_node("/root/Game/GameManager")
		gameManager.isDead = true
	if body is Block:
		direction *= -1
