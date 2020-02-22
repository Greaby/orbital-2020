extends Node2D

var items = []

func _ready():
	$AnimatedSprite.play("default")


func move():
	$AnimatedSprite.play("move")
	$AnimatedSprite.frame = randi() % 20

func stop():
	$AnimatedSprite.play("default")
	display_items_ui()


func add_dialogue(text):
	var dialogue = load("res://agent/Dialogue.tscn").instance()
	dialogue.set_text(text)
	$dialogue.add_child(dialogue)
	
func remove_dialogue():
	for child in $dialogue.get_children():
		child.queue_free()


func display_items_ui():
	$items.show()
	for i in $items.get_child_count():
		var spawn = $items.get_child(i)
		if i >= items.size():
			var drop = load("res://items/DropZone.tscn").instance()

			drop.connect("drop", self, "_on_zone_drop")
			spawn.add_child(drop)
		else:
			var item = load("res://items/Item.tscn").instance()
			item.connect("drop", self, "_on_item_drop")
			spawn.add_child(item)

func hide_items_ui():
	$items.hide()
	for item in $items.get_children():
		var child = item.get_child(0)
		if child:
			child.queue_free()


func _on_zone_drop(item):
	item.queue_free()
	items.append(item.id)
	hide_items_ui()
	display_items_ui()
	
func _on_item_drop(item):
	var key = items.find(item.id)
	items.remove(key)
	hide_items_ui()
	display_items_ui()
