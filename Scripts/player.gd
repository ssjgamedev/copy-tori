class_name Player

extends CharacterBody2D

enum PlayerState {WALKING, AIR, TELEPORTING, LIFTING, FLYING, CLIMBING}

var playerstate = PlayerState.WALKING

@onready var outlineSprite = $OutlineSprite
@export var teleport_cooldown : float = 2.0
var teleport_timer : float = 0.0
@onready var collision_shape = $CollisionShape2D



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
var isInAir = false
var isTeleporting = false
var lastInputDirection = Vector2.ZERO
var isTeleportPositionClear = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = gravityCONSTANT #ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	outlineSprite.hide()

func _physics_process(delta):
	handleInput()
	
	match playerstate:
		
		PlayerState.WALKING:
			handleWalkingState()
		PlayerState.AIR:
			print("I am in the AIR state")
			
			velocity.y += 40 * delta
			velocity.x = 0
			move_and_slide()
			print(gravity)
			
		PlayerState.TELEPORTING:
			handleTeleportState(delta)
					
		PlayerState.LIFTING:
			print("I am in the LIFTING state")	
		PlayerState.FLYING:
			print("I am in the FLYING state")
		PlayerState.CLIMBING:
			print("I am in the CLIMBING state")
	
	
func toggle_teleportState():
	if playerstate == PlayerState.WALKING :
		playerstate = PlayerState.TELEPORTING
	else:
		playerstate = PlayerState.WALKING
		
		
func handleInput():
	if !isTouchingLadder && !is_on_floor():
		playerstate = PlayerState.AIR
	elif(!isTeleporting):
		playerstate = PlayerState.WALKING
	if Input.is_action_just_pressed("teleport"):
		isTeleporting = true
		toggle_teleportState()
		print("input")
		
	updateLastInputDirection()
		
func handleWalkingState():
	print("I am in the WALKING state")
	outlineSprite.hide()
			
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
			# As good practice, you should replace UI actions with custom gameplay actions.q
	direction = Input.get_axis("ui_left", "ui_right")
	if Input.is_action_pressed("ui_left") && !facingLeft && !Input.is_action_pressed("ui_right"):
				#animatedSprite.flip_h = true
		facingLeft = true
		scale.x *= -1
	elif Input.is_action_pressed("ui_right") && facingLeft && !Input.is_action_pressed("ui_left") :
				#animatedSprite.flip_h = false
		facingLeft = false
		scale.x *= -1
	if direction && is_on_floor() || (direction && isTouchingLadder) && !isTeleporting:
			velocity.x = direction * SPEED
				
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
				
	if Input.is_action_just_pressed("shoot"):
		shoot()
				
	move_and_slide()
		
		
	
func handleTeleportState(delta):
	print("I am in the TELEPORTING state")
	outlineSprite.show()
	#if teleport_timer > 0 :
		###return
		
	if Input.is_action_just_pressed("confirm_teleport"):
		try_teleport()
		isTeleporting = false
	else:
		show_outline(lastInputDirection)

func updateisTouchingLadder(value):
	print("I am touch ladder")
	isTouchingLadder = value
	
func updateLadderPhysics():
	velocity.y = 0
	gravity = 0
	
	
func shoot():
	var bulletProjectile = Bullet.instantiate()
	if facingLeft:

		bulletProjectile.get_child(0).flip_v = true
	#	bulletProjectile.start($Marker2.global_position, deg_to_rad(180))#added a second marker for the left side
	#else:
	bulletProjectile.start($Marker.global_position, rotation)
	get_tree().root.add_child(bulletProjectile)
	
func try_teleport():
	
	
	var player_size = get_player_size()
	var teleport_distance = player_size * 2
	var direction = teleportDirection()
	var new_position = global_position + lastInputDirection * teleport_distance
	print(new_position)
	print(position)
	if is_position_clear(new_position, player_size):
		teleport(new_position)
		print("I should have teleported")
		playerstate = PlayerState.WALKING
	else:
		
		print("I am not clear")
		playerstate = PlayerState.WALKING

func get_player_size() -> float:
	if collision_shape.shape is RectangleShape2D:
		var shape = collision_shape.shape as RectangleShape2D
		return max(shape.extents.x, shape.extents.y)
	elif collision_shape.shape is CircleShape2D:
		var shape = collision_shape.shape as CircleShape2D
		return 8 * 2
	return 8 * 2		#tiles are 8 pixels long for now

func is_position_clear(position: Vector2, size: float) -> bool:
	return isTeleportPositionClear
	


func show_outline(direction : Vector2):
	if(direction == Vector2.ZERO):
		return
	var player_size = get_player_size()
	var teleport_distance = player_size * 2
	var new_position = global_position + direction * teleport_distance
	
	outlineSprite.global_position = new_position
	outlineSprite.show()

func teleport(position: Vector2):
	outlineSprite.hide()
	global_position = position
	teleport_timer = teleport_cooldown
	playerstate = PlayerState.WALKING
	
func teleportDirection() -> Vector2 :
	return lastInputDirection


func updateLastInputDirection():
	
	if Input.is_action_pressed("ui_right"):
		lastInputDirection = Vector2.ZERO
		lastInputDirection.x += 1
	elif Input.is_action_pressed("ui_left"):
		lastInputDirection = Vector2.ZERO
		lastInputDirection.x -= 1
	if Input.is_action_pressed("ui_down"):
		lastInputDirection = Vector2.ZERO
		lastInputDirection.y += 1
	elif Input.is_action_pressed("ui_up"):
		lastInputDirection = Vector2.ZERO
		lastInputDirection.y -= 1

	lastInputDirection = lastInputDirection.normalized()


func _on_area_2d_body_entered(body):
	isTeleportPositionClear = false


func _on_area_2d_body_exited(body):
	isTeleportPositionClear = true
