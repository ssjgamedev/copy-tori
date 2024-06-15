extends Area2D





func _on_body_entered(body):
	queue_free()
	print("I am free")
	print("i am setup")
	
