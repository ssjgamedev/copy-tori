extends Node

var coinsArray = []
var levelGoalAchieved = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var coinsParent = get_node("/root/Game/Coins")
	for child in coinsParent.get_children():
		if child is Area2D:
			coinsArray.append(child)
	for coin in coinsArray:
		print(coin.name)
	print("I have " + str(coinsArray.size()) + " coins")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var coinsParent = get_node("/root/Game/Coins")
	
	if coinsParent.get_children().size() <= 0 && !levelGoalAchieved:
		print("I collected all the coins")
		levelGoalAchieved = true
	elif coinsParent.get_children().size() > 0:
		print("I have " + str(coinsParent.get_children().size()) + " coins left")
