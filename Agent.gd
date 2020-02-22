extends Node2D


func _ready():
	$AnimationPlayer.play("default")

func move():
	$AnimationPlayer.play("move")

func stop():
	$AnimationPlayer.play("default")
