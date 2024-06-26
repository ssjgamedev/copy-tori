extends Node2D

# Reference to the Player node and the CharacterBody2D child
@onready var playerMarker = $"../Player"
@onready var character_body = $CharacterBody2D
var isPickedUp = false
@onready var block = $"."


func _ready():
	# Optionally, you can connect a signal or use an input action to trigger the move
	pass

func _process(delta):
	# Example of triggering the move with an input action
	if Input.is_action_just_pressed("pickupBlock"):
		isPickedUp = !isPickedUp
	if isPickedUp:
		move_behind_player()

# Function to move the block's CharacterBody2D directly behind the player over time
func move_behind_player():
	position = playerMarker.get_child(2).global_position
	
	# Get the position of the attached Node2D relative to the player
	#var attached_node_position = playerMarker.global_position

	# Calculate the offset from the player to the attached node
	#var offset_from_player = attached_node_position - playerMarker.global_position

	# Set the position of the entire BlockNode2D to match the attached Node2D's position
	#block.global_position = playerMarker.global_position + offset_from_player
