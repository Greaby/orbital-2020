extends Node2D

signal selected_option

var current_opacity = 0
var option_nodes = []
onready var container = $ColorRect/MarginContainer/VBoxContainer

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
		option_node.margin_left = text_element.margin_left
		option_node.margin_top = y_pos
		
		if option_enabled:
			option_node.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
			option_node.connect("pressed", self, "_on_selected_option", [event, option_value])
		else:
			option_node.underline = LinkButton.UNDERLINE_MODE_NEVER
			option_node.add_color_override("font_color", Color(0.4, 0.4, 0.6, 1))
			option_node.add_color_override("font_color_hover", Color(0.4, 0.4, 0.6, 1))
		
		option_nodes.append(option_node)

		container.add_child(option_node)
		
		y_pos += option_node.rect_size.y + 10

	show()
	
func discard():
	for option_node in option_nodes:
		container.remove_child(option_node)
	
	hide()

func _on_selected_option(event, option):
	emit_signal("selected_option", event, option)
