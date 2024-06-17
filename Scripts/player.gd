extends CharacterBody2D



const SPEED = 50
const LadderSpeed = -100
const JUMP_VELOCITY = -300
const gravityCONSTANT = 40
@onready var animatedSprite = $AnimatedSprite2D
var isTouchingLadder = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = gravityCONSTANT #ProjectSettings.get_setting("physics/2d/default_gravity")

#going to set gravity to zero when pressing up or down on ladder area
func _physics_process(delta):
	# Add the gravity.
	
	if !is_on_floor():
		velocity.y += gravity * delta
		#velocity.x = 0
	if isTouchingLadder && Input.is_action_pressed("up"):
		print("pressing up")
		velocity.y = LadderSpeed
		print(str(velocity.y))
	elif isTouchingLadder && Input.is_action_pressed("down"):
		print("pressing down")
		velocity.y = -LadderSpeed
		print(str(velocity.y))
	elif isTouchingLadder && (Input.is_action_just_released("up") || Input.is_action_just_released("down") ):
		velocity.y = 0
		gravity = 0
	elif Input.is_action_just_released("up") || !isTouchingLadder:
		gravity = gravityCONSTANT
		velocity.y = gravity
		
	elif isTouchingLadder && Input.is_action_just_pressed("down"):
		print("pressing down")
		velocity.y = gravity
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction < 0:
		animatedSprite.flip_h = true
	elif direction > 0:
		animatedSprite.flip_h = false
	if direction && is_on_floor() || direction && isTouchingLadder:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func updateisTouchingLadder(value):
	isTouchingLadder = value
	
func updateLadderPhysics():
	velocity.y = 0
	gravity = 0
	
