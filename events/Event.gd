extends Control

func _ready():
	pass

func spawn(title, text, options):
	var title_element = $Title
	var text_element = $Text
	
	title_element.text = title
	text_element.text = text
	
	var y_pos = text_element.margin_bottom
	
	for option in options:
		var option_node = load("res://events/Option.tscn").instance()
		option_node.text = "> " + option
		option_node.margin_left = text_element.margin_left
		option_node.margin_top = y_pos

		add_child(option_node)
		
		y_pos += option_node.rect_size.y + 10

	show()
