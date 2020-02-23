extends Node2D

export(int) var steps_to_win = 20
# Current time as hour of the day
var current_time = 5.0

# Fatigue to add on each round
var regular_strain = 10
# Fatigue to heal on each regular break
var rest_value_regular = 5
# Fatigue to heal on each break with furnace
var rest_value_plus = 8

var pentes = [
	"res://terrain/pente-01.png",
	"res://terrain/pente-02.png",
	"res://terrain/pente-03.png"
]

var delay_time = 1.5
var delay_time_long = 2
var shortcut_time = 0.5

func _ready():
	randomize()
	init_items()
	play_turn()


func change_terrain():
	$terrain.texture = load(pentes[randi() % pentes.size()])
	
func play_turn():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("move")
	
	$Event.discard()
	
	for agent in get_agents():
		agent.remove_dialogue()
		agent.move()

	yield($AnimationPlayer, "animation_finished")

	for agent in get_agents():
		agent.stop()
		#agent.add_dialogue("ceci est un text")
	
	add_fatigue_to_agents(regular_strain)
	
	show_event(get_random_event())
	
func show_event(event):
	var options = States.sol_outcomes[event]
	var available_options = {}
	var event_description = States.event_descr.get(event)
	var event_title = event_description[0] if event_description else "Titre"
	var event_text = event_description[1] if event_description else "Texte"
	
	for option in options:		
		# If this action has no way of happening, skip it
		if not States.sol_probas[event].get(option, null):
			continue
		
		# Check if any of the agents has the right tools to execute the action
		var items = States.reqs.get(option, [])
		var items_descriptions = PoolStringArray()
		for item in items:
			items_descriptions.append(States.items_descr[item])
			
		var enabled = not items or has_any_item(items)
		var needed_objects = items_descriptions.join(", ")
		var description = States.sol_descr[option] + (" (nécessite " + needed_objects + " )" if not enabled else "")
		
		var option_dict = {
			"enabled": enabled,
			"description": description
		}
		
		available_options[option] = option_dict
	
	$Event.spawn(event, event_title, event_text, available_options)

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
	
	if success:
		print("Roll successful")
	else:
		print("Roll failed")
	
	run_event(next_event)
		
	play_turn()
	
func rest_agents(rest_value):
	print("Resting agents with rest value ", rest_value)
	
	for agent in get_agents():
		var new_fatigue = max(0, agent.fatigue - rest_value)
		agent.set_fatigue(new_fatigue)
		
func tire_agents(tire_value):
	print("Tiring agents with rest value ", tire_value)
	
	for agent in get_agents():
		var new_fatigue = min(100, agent.fatigue + tire_value)
		agent.set_fatigue(new_fatigue)
		
func add_fatigue_to_agents(strain):
	print("Adding strain to agents ", strain)
	for agent in get_agents():
		var new_fatigue = min(100, agent.fatigue + strain)
		print("new fatigue ", new_fatigue)
		agent.set_fatigue(new_fatigue)
	
func kill_random_agent():
	var agents = get_agents()
	
	if agents:
		var agent_id = randi() % (agents.size() - 1)
		print("Killing agent ", agent_id)
		$agents.remove_child($agents.get_child(agent_id))
		
func delay(time):
	current_time += time
	
func run_event(event):
	print("Running event ", event)
	var time = 1
	
	match event:
		States.EVENTS.REST:
			rest_agents(rest_value_regular)
		States.EVENTS.REST_PLUS:
			rest_agents(rest_value_plus)
		States.EVENTS.KILL:
			kill_random_agent()
		States.EVENTS.DELAY:
			time = delay_time
		States.EVENTS.DELAY_LONG:
			time = delay_time_long
		States.EVENTS.ADD_FATIGUE:
			tire_agents(5)
		States.EVENTS.GAIN_TIME:
			time = shortcut_time
			
	return time
