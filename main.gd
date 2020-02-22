extends Node2D

export(int) var steps_to_win = 20

enum EVENTS {NO = -1, AVALANCHE, CREVASSE}

var events_chances = {
	EVENTS.NO: 30,
	EVENTS.AVALANCHE: 2,
	EVENTS.CREVASSE:2
}

func _ready():
	randomize()
	play_turn()
	
func play_turn():
	for agent in $agents.get_children():
		agent.remove_dialogue()
		agent.move()
		yield(get_tree().create_timer(randf()), "timeout")

	$AnimationTimer.start()

	yield(get_tree().create_timer(1), "timeout")
	
	for agent in $agents.get_children():
		agent.stop()
		agent.add_dialogue("ceci est un text")
	
	var event = get_random_event()
	print(event)

func get_random_event():
	var event_list = []
	for event_key in events_chances:
		var number = events_chances[event_key]
		
		for i in number:
			event_list.append(event_key)

	return event_list[randi() % event_list.size()]

func _on_NextButton_pressed():
	steps_to_win -= 1
	
	if steps_to_win == 0:
		get_tree().change_scene("res://End.tscn")
		return
	
	play_turn()
