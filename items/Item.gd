extends Node2D

signal drop

var drag_mouse = false
var last_position = Vector2()

export var id = -1

func _process(delta):
	if drag_mouse:
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


