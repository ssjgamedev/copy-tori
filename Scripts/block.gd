class_name Block
extends CharacterBody2D

# Reference to the Player node and the CharacterBody2D child
@onready var playerMarker = $"../Player"
@onready var character_body = $CharacterBody2D
var isPickedUp = false
@onready var block = $"."
var gravity = 100
@onready var raycastRight = $RayCastRight
@onready var raycastLeft = $RayCastLeft
@onready var player = $"../Player"
var tween


func _ready():
	
	tween = get_tree().create_tween()

func _process(delta):
	
	if player.isInAir :
		isPickedUp = false
	if Input.is_action_just_pressed("pickupBlock") && (raycastLeft.is_colliding() || raycastRight.is_colliding()):
		isPickedUp = !isPickedUp
	if isPickedUp:
		move_behind_player()
	elif !isPickedUp:
		velocity.y = gravity
	if player.playerstate == PlayerState.AIR :
		isPickedUp = false

	move_and_slide()
# Function to move the block's CharacterBody2D directly behind the player over time
func move_behind_player():
	if player.playerstate != PlayerState.WALKING :
		return #maybe player error animation
	player.scale.x *= -1
	position = playerMarker.get_child(3).global_position #marker is 3 child of player
	isPickedUp = false
	player.scale.x *= -1
	
func animate_scale_x(target_scale_x: float, duration: float) -> void:
	tween.tween_property(player, "scale:x", target_scale_x, duration)
	await tween.finished
	print("Scale animation completed!")
