extends Node2D


func _ready():
	$AnimationPlayer.play("default")

func move():
	$AnimationPlayer.play("move")

func stop():
	$AnimationPlayer.play("default")


func add_dialogue(text):
	var dialogue = load("res://agent/Dialogue.tscn").instance()
	dialogue.set_text(text)
	$dialogue.add_child(dialogue)
	
func remove_dialogue():
	for child in $dialogue.get_children():
		child.queue_free()
