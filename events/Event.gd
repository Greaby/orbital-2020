extends Control

signal selected_option

var current_opacity = 0
var option_nodes = []

func _ready():
	pass

func spawn(event, title, text, options):
	var title_element = $Title
	var text_element = $Text

	title_element.text = title
	text_element.text = text
	
	var y_pos = text_element.margin_bottom
	
	for option in options:
		var option_node = load("res://events/Option.tscn").instance()

		option_node.underline = LinkButton.UNDERLINE_MODE_ON_HOVER
		option_node.text = "> " + States.sol_descr[option]
		option_node.margin_left = text_element.margin_left
		option_node.margin_top = y_pos
		option_node.connect("pressed", self, "_on_selected_option", [event, option])
		option_nodes.append(option_node)

		add_child(option_node)
		
		y_pos += option_node.rect_size.y + 10

	show()
	
func discard():
	for option_node in option_nodes:
		remove_child(option_node)
	
	hide()

func _on_selected_option(event, option):
	emit_signal("selected_option", event, option)
