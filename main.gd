extends Node2D


export(int) var steps_to_win = 2


func _ready():
	play_turn()
	
	
func play_turn():
	for agent in $agents.get_children():
		agent.move()
		yield(get_tree().create_timer(randf()), "timeout")

	$AnimationTimer.start()

	yield(get_tree().create_timer(3), "timeout")
	
	for agent in $agents.get_children():
		agent.stop()


func _on_NextButton_pressed():
	steps_to_win -= 1
	
	if steps_to_win == 0:
		get_tree().change_scene("res://End.tscn")
		return
	
	play_turn()
