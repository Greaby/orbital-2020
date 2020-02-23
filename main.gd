extends Node2D

export(int) var steps_to_win = 20

# Fatigue to add on each round
var regular_strain = 10
# Fatigue to heal on each regular break
var rest_value_regular = 5
# Fatigue to heal on each break with furnace
var rest_value_plus = 8

func _ready():
	randomize()
	init_items()
	play_turn()
	
func play_turn():
	$Event.discard()
	
	for agent in get_agents():
		agent.remove_dialogue()
		agent.move()

	$AnimationTimer.start()

	yield(get_tree().create_timer(2.5), "timeout")

	for agent in get_agents():
		agent.stop()
		#agent.add_dialogue("ceci est un text")
	
	add_fatigue_to_agents(regular_strain)
	
	var event = get_random_event()
	print("outcomes ", States.sol_outcomes[event])
	var options = States.sol_outcomes[event]
	var available_options = []
	
	for option in options:
		# If this action has no way of happening, skip it
		if not States.sol_probas[event].get(option, null):
			continue
		
		# Check if any of the agents has the right tools to execute the action
		var items = States.reqs.get(option, [])
		if items and not has_any_item(items):
			continue
			
		available_options.append(option)
	
	$Event.spawn(event, "Titre", "Texte", available_options)

func has_any_item(items):
	for agent in get_agents():
		for item in items:
			if item in agent.items:
				return true
				
	return false
	
func get_agents():
	return $agents.get_children()
	
func get_random_event():
	var event_list = []
	for event_key in States.events_probas:
		var chance = States.events_probas[event_key]
		
		for i in chance:
			event_list.append(event_key)

	return event_list[randi() % event_list.size()]

func _on_NextButton_pressed():
	steps_to_win -= 1
	
	if steps_to_win == 0:
		get_tree().change_scene("res://End.tscn")
		return
	
	play_turn()

func init_items():
	var child_count = $agents.get_child_count()
	var i = 0
	for value in States.ITEMS.values():
		$agents.get_child(i % child_count).add_item(value)
		i+=1

func _on_Event_selected_option(event, option):
	print("Player selected option ", option)
	var success_chance = States.sol_probas[event].get(option, null)
	var success = randi() % 100 <= success_chance
	var next_event = States.sol_outcomes[event][option][success]
	
	run_event(next_event)
		
	play_turn()
	
func rest_agents(rest_value):
	print("Resting agents with rest value ", rest_value)
	
	for agent in get_agents():
		var new_fatigue = max(0, agent.fatigue - rest_value)
		agent.set_fatigue(new_fatigue)
		
func add_fatigue_to_agents(strain):
	print("Adding strain to agents ", strain)
	for agent in get_agents():
		var new_fatigue = min(100, agent.fatigue + strain)
		print("new fatigue ", new_fatigue)
		agent.set_fatigue(new_fatigue)
	
func kill_random_agent():
	var agent_id = randi() % get_agents().size() - 1
	$agents.remove_child($agents.get_child(agent_id))
	
func run_event(event):
	print("Running event ", event)
	match event:
		States.EVENTS.REST:
			rest_agents(rest_value_regular)
		States.EVENTS.REST_PLUS:
			rest_agents(rest_value_plus)
		States.EVENTS.KILL:
			kill_random_agent()
