class_name Player

extends CharacterBody2D


@onready var backTileBridgeMarker = $BackTileBridgeMarker
@onready var frontTileBridgeMarker = $FrontTileBridgeMarker2



var playerstate = PlayerState.FLYING
@onready var bridgeRaycast = $RayCast2DBridgeChecker
@onready var outlineSprite = $OutlineSprite
@export var teleport_cooldown : float = 2.0
var teleport_timer : float = 0.0
@onready var collision_shape = $CollisionShape2D
@onready var OutlineArea2D = $OutlineSprite/TeleportCheckerArea2D
@onready var ray_cast_down = $RayCastDown
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_right_2 = $RayCastRight2
@onready var ray_cast_left_2 = $RayCastLeft2
@onready var ray_cast_up_2 = $RayCastUp2
@onready var ray_cast_down_2 = $RayCastDown2
@onready var ray_cast_up_3 = $RayCastUp3
@onready var ray_cast_up_4 = $RayCastUp4

@onready var bridge = preload("res://Scenes/platform_bridge.tscn")



const HALF_BLOCK_SIZE = 8
const SPEED = 50
const LadderSpeed = -50
const JUMP_VELOCITY = -300
const gravityCONSTANT = 50
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
var isFlyingUpClear = true
var isCleartoShoot = true
var bridgeTrackingArray: Array [StaticBody2D] = []
var isClearToSpawnBridge = true
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
			#print("I am in the AIR state")
			
			velocity.y += gravityCONSTANT * delta
			velocity.x = 0
			move_and_slide()
			
		PlayerState.TELEPORTING:
			handleTeleportState(delta)
					
		PlayerState.LIFTING:
			print("I am in the LIFTING state")	
		PlayerState.FLYING:
			handleFlyingState(delta)
		PlayerState.CLIMBING:
			print("I am in the CLIMBING state")
	
	
func toggle_teleportState():
	if playerstate == PlayerState.WALKING :
		OutlineArea2D.monitoring = true
		playerstate = PlayerState.TELEPORTING
	else:
		OutlineArea2D.monitoring = false
		playerstate = PlayerState.WALKING
		
		
func handleInput():
	if Input.is_action_just_pressed("teleport"):
		isTeleporting = true
		toggle_teleportState()
		print("input")
	if !isTouchingLadder && !is_on_floor():
		playerstate = PlayerState.AIR
	elif(!isTeleporting):
		playerstate = PlayerState.FLYING
	
	
		
	if(Input.is_action_just_pressed("buildBridge") && playerstate == PlayerState.WALKING):
		spawnBridge()
		
	updateLastInputDirection()
		
func handleWalkingState():
	#print("I am in the WALKING state")
	outlineSprite.hide()
	var walkingdirection = Vector2.ZERO
	
	if isTouchingLadder && Input.is_action_pressed("up"):
				
		velocity.y = LadderSpeed

	elif isTouchingLadder && Input.is_action_pressed("down"):

		velocity.y = -LadderSpeed

	elif isTouchingLadder && (Input.is_action_just_released("up") || Input.is_action_just_released("down") ):
		velocity.y = 0
		
	elif Input.is_action_just_released("up") || !isTouchingLadder:
		gravity = gravityCONSTANT
		velocity.y = gravityCONSTANT
				
	elif isTouchingLadder && Input.is_action_just_pressed("down"):

		velocity.y = gravityCONSTANT
		
	direction = Input.get_axis("ui_left", "ui_right")
	if Input.is_action_just_pressed("ui_left") && !facingLeft && !Input.is_action_pressed("ui_right"):
				#animatedSprite.flip_h = true
		facingLeft = true
		scale.x = -1
		walkingdirection.x = walkingdirection.x - 1
	elif Input.is_action_just_pressed("ui_right") && facingLeft && !Input.is_action_pressed("ui_left") :
				#animatedSprite.flip_h = false
		facingLeft = false
		scale.x *= -1
		walkingdirection.x = walkingdirection.x + 1
	if direction && is_on_floor() || (direction && isTouchingLadder) && !isTeleporting:
			#velocity.x = direction * SPEED
			walkingdirection = walkingdirection.normalized() * HALF_BLOCK_SIZE
			position.x = position.x  + walkingdirection.x
				
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#position.x = position.x
				
	if Input.is_action_just_pressed("shoot"):
		shoot()
				
	#move_and_slide()
	walkingdirection = walkingdirection.normalized() * HALF_BLOCK_SIZE
	position.x = position.x  + walkingdirection.x
		
		
	
func handleTeleportState(delta):
	#print("I am in the TELEPORTING state")
	outlineSprite.show()
	#if teleport_timer > 0 :
		###retur
		
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
func handleFlyingState(delta):
	print("I am in the flying State")
	var flydirection = Vector2.ZERO
	
	
	
	if Input.is_action_just_pressed("up") && isFlyingUpClear:
		flydirection.y -= 5
		print("UP")
	elif Input.is_action_just_pressed("ui_down") && !ray_cast_down.is_colliding() && !ray_cast_down_2.is_colliding():
		flydirection.y += 1
	elif Input.is_action_just_pressed("ui_left") && (!ray_cast_left.is_colliding() && !ray_cast_left_2.is_colliding()):
		flydirection.x -= 1
	elif Input.is_action_just_pressed("ui_right") && (!ray_cast_right.is_colliding() && !ray_cast_right_2.is_colliding()):
		flydirection.x += 1
	
	if flydirection != Vector2.ZERO:
		flydirection = flydirection.normalized() * HALF_BLOCK_SIZE
		position = position + flydirection
	
func isCleartoFly():
	pass
	
func shoot():
	if !isCleartoShoot:
		return
	var bulletProjectile = Bullet.instantiate()
	if facingLeft:

		bulletProjectile.get_child(0).flip_v = true
	#	bulletProjectile.start($Marker2.global_position, deg_to_rad(180))#added a second marker for the left side
	#else:
	bulletProjectile.start($Marker.global_position, rotation)
	get_tree().root.add_child(bulletProjectile)

func spawnBridge():
	bridgeRaycast.force_raycast_update()
	ray_cast_down_2.force_raycast_update()
	var tileOffset = Vector2(5,0)
	var offSet = Vector2(0,2)
	
	#if bridgeRaycast.is_colliding():
	#	print("didn't spawn")
	#	return
	var newBridge = bridge.instantiate()
	var tileMap = get_node("/root/Game/TileMap")
	var tileBelowPosition
	print("player position is " + str(tileMap.local_to_map(global_position)))
	if ray_cast_down_2.is_colliding():
		var collider = ray_cast_down_2.get_collider()
		if collider && collider.name == "TileMap":
			print("hey i collided with " + collider.name)
			var collisionPoint = ray_cast_down_2.get_collision_point()
		if facingLeft:
			tileBelowPosition = tileMap.local_to_map(global_position + Vector2(-16,16))
		else:
			tileBelowPosition = tileMap.local_to_map(global_position + Vector2(16,16))
	elif !ray_cast_down_2.is_colliding():
		var collider = ray_cast_down_2.get_collider()
		if collider && collider.name == "TileMap":
			print("hey i collided with  2 " + collider.name)
			var collisionPoint = ray_cast_down_2.get_collision_point()
			tileBelowPosition = tileMap.local_to_map(global_position + Vector2(-48,32))
	elif facingLeft:
		tileBelowPosition = tileMap.local_to_map(global_position + Vector2(-48,32)) 
	else:
		tileBelowPosition = tileMap.local_to_map(global_position + Vector2(-16,32)) 
	if tileBelowPosition == null :
		print("no spawn for you")
		return
	var localPosition = (tileMap.map_to_local(tileBelowPosition))
	
	newBridge.position = localPosition
	
	tileMap.add_child(newBridge)
	

	bridgeTrackingArray.append(newBridge)
	
func clearBridges():
	for bridges in bridgeTrackingArray:
		bridges.queue_free()
	bridgeTrackingArray.clear()
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

func _on_scene_reload():
	clearBridges()

func _on_area_2d_body_entered(body):
	isTeleportPositionClear = false


func _on_area_2d_body_exited(body):
	isTeleportPositionClear = true


func _on_flying_checker_body_entered(body):
	isFlyingUpClear = false


func _on_flying_checker_body_exited(body):
	isFlyingUpClear = true


func _on_shooting_space_body_entered(body):
	isCleartoShoot = false #for weird bug that pushes block

func _on_shooting_space_body_exited(body):
	isCleartoShoot = true 


func _on_platform_spawn_area_body_entered(body):
	isClearToSpawnBridge = false


func _on_platform_spawn_area_body_exited(body):
	isClearToSpawnBridge = true
