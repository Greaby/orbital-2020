extends Node2D

export(int) var steps_to_win = 20
var current_step = 1
# Current time as hour of the day
var current_time = 10.0
var night_alpha = 0

# Fatigue to add on each round
var regular_strain = 9
# Fatigue to heal on each regular break
var rest_value_regular = 6
# Fatigue to heal on each break with furnace
var rest_value_plus = 8

var delay_time = 1.5
var delay_time_long = 2
var shortcut_time = 0.5

var mem_curr_event = null
var mem_next_event = null
var mem_chosen = null
var dialogue_agent = null
var dialogue_queue = []

var progress = {
	"night" : false,
	"distance" : 0,
	"death" : 4,
	"health" : [0, 0, 0, 0],
}

var pentes = [
	"res://terrain/pente-01.png",
	"res://terrain/pente-02.png",
	"res://terrain/pente-03.png"
]

# Nodes
onready var scene_node = $SceneContainer;
onready var agents_node = scene_node.get_node("agents");
onready var background_node = scene_node.get_node("Background");
onready var terrain_node = scene_node.get_node("terrain");

func _ready():
	randomize()
	init_items()
	set_night_level(false)
	play_turn()


func animation_mountain():
	$BackgroundTween.interpolate_property(background_node, "position", background_node.position, background_node.position + Vector2(0, 40), 10, Tween.TRANS_LINEAR)
	$BackgroundTween.start()

func hide_items():
	for agent in get_agents():
		agent.hide_items_ui()

func show_items():
	for agent in get_agents():
		agent.display_items_ui()

func change_terrain():
	terrain_node.texture = load(pentes[randi() % pentes.size()])
	
func display_dialogue(type):
	var agents = get_agents()
	dialogue_agent = agents[randi() % len(agents)]
	var temp = null
	
	if type == 0:
		if mem_curr_event != null:
			temp = States.sols_dialogue.get(mem_curr_event)
		
		if temp != null:
			temp = States.sols_dialogue[mem_curr_event].get(mem_chosen)
			
		if temp != null:
			temp = States.sols_dialogue[mem_curr_event][mem_chosen].get(mem_next_event)
		
	elif type == 1:
		print(progress)
		if current_step / steps_to_win > progress["distance"]: # DISTANCE
			enqueue_line(States.progress_dialogue["distance"][progress["distance"]])
			progress["distance"] = progress["distance"] + 1
		if !progress["night"] and night_alpha >= 0.4: # NIGHT
			enqueue_line(States.progress_dialogue["night"])
			progress["night"] = true
		elif len(get_agents()) < progress["death"]: # DEATH
			progress["death"] = len(get_agents())
			enqueue_line(States.progress_dialogue['death'][4 - len(get_agents())])
		else:
			for i in range(len(get_agents())):
				if get_agents()[i].fatigue > progress["health"][i] * 25:
					enqueue_line(States.progress_dialogue["health"][int(get_agents()[i].fatigue / 25)])
					progress["health"][i] = progress["health"][i] + 1
					
		if len(dialogue_queue):
			temp = dialogue_queue.pop_front()

	if temp != null:
		dialogue_agent.add_dialogue(temp)
		
func enqueue_line(lines):
	var idx = randi() % len(lines)
	dialogue_queue.append(lines[idx])
		
func hide_dialogue():
	if dialogue_agent:
		dialogue_agent.remove_dialogue()

# Return the night level as a percentage
func get_night_level():
	var level = 0
	
	if current_time >= 17:
		level = 100 / float(max(1, 25 - current_time))
	elif current_time <= 5:
		level = 100 - 100 / float(max(1, 6 - current_time))
	
	return level
	
func get_night_alpha():
	# Make sure alpha doesn't exceed 0.6 or the player won't see anything
	return min(0.6, get_night_level() / 100)
		
func set_night_level(animate=true):
	var alpha = 1 - get_night_alpha()
	var new_color = Color(alpha, alpha, alpha)

	if animate:
		var tween = $Night/Tween
		tween.interpolate_property(
			scene_node, "modulate", scene_node.modulate, new_color, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		if not tween.is_active():
			tween.start()
	else:
		scene_node.modulate = new_color
			
func pass_time(delay):
	current_time = current_time + delay
	if current_time >= 24:
		current_time -= 24
		
	$Time.text = str(current_time)
	
	set_night_level(true)
	
func play_turn():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("move")
	
	$Event.discard()
	
	for agent in get_agents():
		agent.move()

	yield($AnimationPlayer, "animation_finished")

	for agent in get_agents():
		agent.stop()
	
	add_fatigue_to_agents(regular_strain)
	
	var all_dead = true
	for agent in get_agents():
		if agent.fatigue < agent.max_fatigue:
			all_dead = false
			break

	var event = (
		get_random_event() if (get_agents() and not all_dead) else States.EVENTS.ALL_DEAD
	)

	show_event(event)
	
func show_event(event):
	var options = States.sol_outcomes[event]
	var available_options = {}
	var event_description = States.event_descr.get(event)
	assert(event_description)
	var event_title = event_description[0]
	var event_text = event_description[1]
	
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
		var description = States.sol_descr[option] + (" (nécessite " + needed_objects + ")." if not enabled else ".")
		
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
	return agents_node.get_children()
	
func get_random_event():
	var event_list = []
	for event_key in States.events_probas:
		var chance = States.events_probas[event_key]
		
		for i in chance:
			event_list.append(event_key)

	return event_list[randi() % event_list.size()]

func _on_NextButton_pressed():
	steps_to_win -= 1
	
	play_turn()

func init_items():
	var child_count = agents_node.get_child_count()
	var i = 0
	for value in States.ITEMS.values():
		agents_node.get_child(i % child_count).add_item(value)
		i+=1

func _on_Event_selected_option(event, option):
	print("Player selected option ", option)
	var success_chance = States.sol_probas[event].get(option, null)
	
	if get_night_level() >= 50:
		success_chance /= 2
		
	var roll = randi() % 100
	var success = roll <= success_chance
	var next_event = States.sol_outcomes[event][option][success]
	var outcome_description = States.outcomes_descr.get(option, null)
	
	if success:
		print("Roll successful (difficulty ", success_chance, ", rolled ", roll, ")")
	else:
		print("Roll failed (difficulty ", success_chance, ", rolled ", roll, ")")
	
	mem_curr_event = event
	mem_next_event = success
	mem_chosen = option
	
	if outcome_description:
		$Event.show_outcome(
			option,
			outcome_description[0 if success or outcome_description.size() == 1 else 1],
			next_event
		)
	else:
		_on_Event_outcome_continue(next_event)
	
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
		
func tire_agent(agent, tire_value):
	var new_fatigue = min(100, agent.fatigue + tire_value)
	agent.set_fatigue(new_fatigue)
	
func get_random_agent():
	return self.get_agents()[randi() % (self.get_agents().size())]
		
func add_fatigue_to_agents(strain):
	print("Adding strain to agents ", strain)
	for agent in get_agents():
		var new_fatigue = min(100, agent.fatigue + strain)
		print("new fatigue ", new_fatigue)
		agent.set_fatigue(new_fatigue)
	
func kill_random_agent():
	var agents = get_agents()
	
	if agents and agents.size() > 1:
		var agent_id = randi() % (agents.size())
		print("Killing agent ", agent_id)
		agents_node.remove_child(agents_node.get_child(agent_id))
		progress["health"].remove(agent_id)
	
	if agents.size() == 1:
		game_over()
	
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
		States.EVENTS.HARM:
			tire_agent(get_random_agent(), 10)
		States.EVENTS.GAME_OVER:
			game_over()
			
	return time

func _on_Event_outcome_continue(next_event):
	var round_duration = run_event(next_event)
	pass_time(round_duration)
	current_step += 1
	
	if current_step == steps_to_win:
		get_tree().change_scene("res://End.tscn")
	
	play_turn()
	
func game_over():
	get_tree().change_scene("res://GameOver.tscn")
