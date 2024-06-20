class_name Player

extends CharacterBody2D



const SPEED = 50
const LadderSpeed = -50
const JUMP_VELOCITY = -300
const gravityCONSTANT = 40
@onready var animatedSprite = $AnimatedSprite2D
var isTouchingLadder = false
var Bullet = preload("res://Scenes/Bullet.tscn")
var BulletSpeed = 200
var direction = 0
var facingLeft = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = gravityCONSTANT #ProjectSettings.get_setting("physics/2d/default_gravity")

#going to set gravity to zero when pressing up or down on ladder area
func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y += gravity * delta
		#velocity.x = 0
	if isTouchingLadder && Input.is_action_pressed("up"):
		
		velocity.y = LadderSpeed

	elif isTouchingLadder && Input.is_action_pressed("down"):

		velocity.y = -LadderSpeed

	elif isTouchingLadder && (Input.is_action_just_released("up") || Input.is_action_just_released("down") ):
		velocity.y = 0
		gravity = 0
	elif Input.is_action_just_released("up") || !isTouchingLadder:
		gravity = gravityCONSTANT
		velocity.y = gravity
		
	elif isTouchingLadder && Input.is_action_just_pressed("down"):

		velocity.y = gravity
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction < 0:
		animatedSprite.flip_h = true
		facingLeft = true
	elif direction > 0:
		animatedSprite.flip_h = false
		facingLeft = false
	if direction && is_on_floor() || direction && isTouchingLadder:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if Input.is_action_just_pressed("shoot"):
			shoot()

	move_and_slide()

func updateisTouchingLadder(value):
	isTouchingLadder = value
	
func updateLadderPhysics():
	velocity.y = 0
	gravity = 0
	
	
func shoot():
	var bulletProjectile = Bullet.instantiate()
	if facingLeft:

		bulletProjectile.get_child(0).flip_v = true
		bulletProjectile.start($Marker2.global_position, deg_to_rad(180))#added a second marker for the left side
	else:
		bulletProjectile.start($Marker.global_position, rotation)
	get_tree().root.add_child(bulletProjectile)
