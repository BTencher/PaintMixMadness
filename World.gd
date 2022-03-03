extends Node

onready var room : Node2D = $GameWorld/GameWorldPort/Room
onready var gameWorld : ViewportContainer = $GameWorld
onready var testPos : Position2D = $Test

func _ready():
	connect_room_signals()

func connect_room_signals():
	room.connect("createPaintMachineUI", self, "_create_paint_machine_ui")

func _create_paint_machine_ui(worker_node, machine_node) -> void:
	var createPaintMachineUI = preload("res://Devices/PaintMachineControl.tscn").instance()
	var popupPosition : Vector2 = machine_node.get_menu_location()*5 #testPos.position
	var popupRectPosition : Vector2 = Vector2(210, 150)
	createPaintMachineUI.workerNode = worker_node
	createPaintMachineUI.machineNode = machine_node
	gameWorld.add_child(createPaintMachineUI)
	createPaintMachineUI.popup(Rect2(popupPosition.x, popupPosition.y, popupRectPosition.x, popupRectPosition.y))
	#Above is kind of ghetto. Fix later. Probably bad for resizing.
