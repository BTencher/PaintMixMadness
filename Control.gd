extends Control


var dialog_node = preload("res://addons/textalog/nodes/dialogue_bubble_node/dialog_bubble.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(dialog_node)
# Shows the dialog node
	dialog_node.show()
# Show an string. BBCode works too!
	dialog_node.show_text("A whole new [color=#FF0000]W[/color][color=#D4002A]O[/color][color=#AA0055]O[/color][color=#7F007F]O[/color][color=#5500AA]O[/color][color=#2A00D4]R[/color][color=#0000FF]L[/color][color=#002AD4]L[/color][color=#0055AA]L[/color][color=#007F7F]L[/color][color=#00AA55]L[/color][color=#00D42A]L[/color][color=#00FF00]D[/color]!")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	Input.is_action_just_pressed("interact")

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
		print(dialog_node.position)
