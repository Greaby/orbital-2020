extends Node2D


func _ready():
	$AnimatedSprite.play("default")
	

func move():
	$AnimatedSprite.play("move")
	$AnimatedSprite.frame = randi() % 20

func stop():
	$AnimatedSprite.play("default")


func add_dialogue(text):
	var dialogue = load("res://agent/Dialogue.tscn").instance()
	dialogue.set_text(text)
	$dialogue.add_child(dialogue)
	
func remove_dialogue():
	for child in $dialogue.get_children():
		child.queue_free()
