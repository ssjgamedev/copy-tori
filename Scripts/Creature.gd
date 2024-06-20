extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const speed = 40
# Called when the node enters the scene tree for the first time.
@onready var raycastDownLeft = $RayCast2DDownLeft
@onready var raycastDownRight = $RayCast2DDownRight
@onready var raycastLeft = $RayCast2DLeft
@onready var raycastRight = $RayCast2DRight
@onready var collisionShape = $CollisionShape2D
@onready var player = $"../Player"
@onready var creature = $"."

var isInAir = true


var direction = 1
var gravity = 40

func _ready():
	velocity.y = gravity
	velocity.x = 0

func _process(delta):
	raycastDownLeft.force_raycast_update()
	raycastDownRight.force_raycast_update()
	raycastLeft.force_raycast_update()
	raycastRight.force_raycast_update()
	
	if (!raycastDownLeft.is_colliding() && !raycastDownRight.is_colliding() && !raycastLeft.is_colliding() && !raycastRight.is_colliding() ):
		isInAir = true
		
	if !isInAir:
		if (!raycastDownLeft.is_colliding() || !raycastDownRight.is_colliding() || raycastLeft.is_colliding() || raycastRight.is_colliding()):
			direction *= -1
		if direction < 0:
			animated_sprite_2d.flip_h = true
			velocity.y = 0
		else:
			animated_sprite_2d.flip_h = false
			velocity.y = 0
			
		position.x += direction * speed * delta
		
		
	
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().name == "TileMap" :
			isInAir = false
		if collision.get_collider().name =="player" :
			get_tree().reload_current_scene()
			
	#checkCollisions()
	#if is_colliding(creature,player):
	#	print("I am colliding  with player")
		
	collision = move_and_collide(velocity * delta)
	if collision:
		print("I collided with ", collision.get_collider().name)
	
func hit():
	print("I am hit")





func _on_timer_timeout(): # figure out what to do later for dying in game
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func checkCollisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider():
			print(collision.get_collider().name)
			if collision.get_collider().name=="Creature":
				print("I am hit")
				
				
func is_colliding(body1: CharacterBody2D, body2: CharacterBody2D) -> bool:
	var collision_shape1 = body1.get_node("CollisionShape2D").shape
	var collision_shape2 = body2.get_node("CollisionShape2D").shape
	
	var transform1 = body1.get_global_transform()
	var transform2 = body2.get_global_transform()
	
	return collision_shape1.collide(transform2, collision_shape2, transform2)
