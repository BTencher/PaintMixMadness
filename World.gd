extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func create_paint_machine_ui() -> void:
	var createPaintMachineUI = preload("res://Devices/PaintMachineControl.tscn").instance()
	add_child(createPaintMachineUI)
