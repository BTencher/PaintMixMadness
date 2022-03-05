extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Creates a new DialogNode instance
	var dialog_node = DialogBubble.instance()
	dialog_node._init()
# Add the node as child
	add_child(dialog_node)
# Shows the dialog node
	dialog_node.show()
# Show an string. BBCode works too!
	dialog_node.show_text("[color=#FF0000]H[/color][color=#D4002A]e[/color][color=#AA0055]l[/color][color=#7F007F]l[/color][color=#5500AA]o[/color] [color=#0000FF]w[/color][color=#002AD4]o[/color][color=#0055AA]r[/color][color=#007F7F]l[/color][color=#00AA55]d[/color][color=#00D42A]![/color]")
