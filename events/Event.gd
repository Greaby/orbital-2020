extends Node2D

signal selected_option
signal outcome_continue

var current_opacity = 0
var option_nodes = {}
var outcome_node = null
onready var container = $ColorRect/MarginContainer/VBoxContainer

func _disable_link(link_button):
	link_button.underline = LinkButton.UNDERLINE_MODE_NEVER
	link_button.add_color_override("font_color", Color(0.4, 0.4, 0.6, 1))
	link_button.add_color_override("font_color_hover", Color(0.4, 0.4, 0.6, 1))
	
func spawn(event, title, text, options):
	var title_element = container.find_node("Title")
	var text_element = container.find_node("Text")

	title_element.text = title
	text_element.text = text
	
	var y_pos = text_element.margin_bottom
	
	for option in options:
		var option_node = load("res://events/Option.tscn").instance()
		var option_value = option
		var option_enabled = options[option]["enabled"]
		var option_descr = options[option]["description"]

		option_node.text = "> " + option_descr
		
		if option_enabled:
			option_node.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
			option_node.connect("pressed", self, "_on_selected_option", [event, option_value])
		else:
			_disable_link(option_node)
		
		option_nodes[option] = option_node

		container.add_child(option_node)

	show()
	
func show_outcome(option, outcome, next_event):
	var selected_option_text = option_nodes[option].text
	outcome_node = load("res://events/Outcome.tscn").instance()
	var option_node = outcome_node.find_node("Option")
	
	for option in option_nodes:
		container.remove_child(option_nodes[option])
	option_nodes = {}
	
	option_node.text = selected_option_text
	_disable_link(option_node)
	outcome_node.find_node("Description").text = outcome
	outcome_node.find_node("Continue").connect("pressed", self, "_on_continue_pressed", [next_event])
	
	container.add_child(outcome_node)

	
func discard():
	for option in option_nodes:
		container.remove_child(option_nodes[option])
		
	if outcome_node:
		container.remove_child(outcome_node)
	
	hide()

func _on_selected_option(event, option):
	emit_signal("selected_option", event, option)
	
func _on_continue_pressed(next_event):
	emit_signal("outcome_continue", next_event)
