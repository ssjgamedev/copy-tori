extends Node

var coinsArray = []
var levelGoalAchieved = false
var isDead = false
@onready var timer = $Timer
var player 

# Called when the node enters the scene tree for the first time.
func _ready():
	#var coinsParent = get_node("/root/Game/Coins")
	#for child in coinsParent.get_children():
	#	if child is Area2D:
	#		coinsArray.append(child)
	#for coin in coinsArray:
	#	print(coin.name)
	player = get_node("/root/Game/Player")
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var coinsParent = get_node("/root/Game/Coins")
	
	if coinsParent.get_children().size() <= 0 && !levelGoalAchieved || isDead:
		
		levelGoalAchieved = true
		Engine.time_scale = 0.6
		isDead = false
		timer.start()
	
	


func _on_timer_timeout():
	Engine.time_scale = 1.0

	player._on_scene_reload()
	get_tree().reload_current_scene()
	
