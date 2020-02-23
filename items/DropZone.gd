extends Area2D

signal drop

func drop(item):
	emit_signal("drop", item)
	print("drop", item)
