extends Node2D

signal drop


var drag_mouse = false
var last_position = Vector2()

export(States.ITEMS) var id = 0 setget set_id

var textures = {
	States.ITEMS.GUN: "res://items/assets/outils-03.png",
	States.ITEMS.FURNACE: "res://items/assets/outils-04.png",
	States.ITEMS.KNIFE: "res://items/assets/outils-02.png",
	States.ITEMS.PICK: "res://items/assets/outils-05.png",
	States.ITEMS.SHOVEL: "res://items/assets/outils-01.png"
}

func set_id(_id):
	id = _id
	var texture = textures[id]
	if(texture):
		$Sprite.texture = load(texture)

func _process(delta):
	if drag_mouse and not is_queued_for_deletion():
		global_position = get_viewport().get_mouse_position()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if not drag_mouse:
				last_position = position
			drag_mouse = true
		else:
			drag_mouse = false
			for area in $Area2D.get_overlapping_areas():
				if area.is_in_group("droppable"):
					emit_signal("drop", self)
					return area.drop(self)
			position = last_position


