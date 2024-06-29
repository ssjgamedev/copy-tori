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
var last_positionTeleport = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = gravityCONSTANT #ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	pass#outlineSprite.hide()

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
	
	
	
		
func handleInput():
	if Input.is_action_just_pressed("teleport"):
		if isTeleporting:
			isTeleporting = false
			playerstate = PlayerState.WALKING
		elif !isTeleporting:
			isTeleporting = true
			playerstate = PlayerState.TELEPORTING
		elif !is_on_floor() && !isTouchingLadder:
			isInAir = true
			playerstate = PlayerState.AIR
			isTeleporting = false
		else:
			playerstate = PlayerState.WALKING
			#isInAir = false
			isTeleporting = false
		
func handleWalkingState():
	print("I am in the WALKING state")
			
			
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
	if(!isTeleporting):
		playerstate = PlayerState.WALKING
		return
			
	if teleport_timer > 0 :
		teleport_timer -= delta
		
	if Input.is_action_just_pressed("teleport"):#  && teleport_timer <= 0 :
		isTeleporting = false
		try_teleport(teleportDirection(Vector2.ZERO))
		playerstate = PlayerState.WALKING
		print("Finsh teleporting")
		return
			
	if isTeleporting:
		show_outline(teleportDirection(Vector2.ZERO))

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
	
func try_teleport(direction : Vector2):
	
	
	
	var player_size = get_player_size()
	var teleport_distance = player_size * 2
	var new_position = global_position + last_positionTeleport * teleport_distance
	
	#if is_position_clear(new_position, player_size):
		
		#await(get_tree().create_timer(5000))
		#isTeleporting = false
		
	teleport(new_position)
	print("I should have teleported")

func get_player_size() -> float:
	if collision_shape.shape is RectangleShape2D:
		var shape = collision_shape.shape as RectangleShape2D
		return max(shape.extents.x, shape.extents.y)
	elif collision_shape.shape is CircleShape2D:
		var shape = collision_shape.shape as CircleShape2D
		return shape.radius * 2
	return 0.0

func is_position_clear(position: Vector2, size: float) -> bool:
	
	var area = Area2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(size, size) / 2

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	area.add_child(collision_shape)

	add_child(area)
	area.global_position = position

	#area.update()

	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_shape(shape,32)

	remove_child(area)

	return result.size() == 0

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
	last_positionTeleport = Vector2.ZERO
	teleport_timer = teleport_cooldown
	
func teleportDirection(direction : Vector2) -> Vector2 :
	if Input.is_action_pressed("ui_right"):
			direction.x += 1
			last_positionTeleport = direction
			direction = Vector2.ZERO
			
	elif Input.is_action_pressed("ui_left"):
		direction.x -= 1
		last_positionTeleport = direction
		direction = Vector2.ZERO
		
	elif Input.is_action_pressed("ui_down"):
		direction.y += 1
		last_positionTeleport = direction
		direction = Vector2.ZERO
		
	elif Input.is_action_pressed("ui_up"):
		direction.y -= 1
		last_positionTeleport = direction
		direction = Vector2.ZERO
	
	else:
		direction = last_positionTeleport
		

	if direction != Vector2.ZERO && last_positionTeleport != Vector2.ZERO:
		direction = direction.normalized()
		last_positionTeleport = last_positionTeleport.normalized()
		
	return direction
