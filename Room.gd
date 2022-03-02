extends Node2D


onready var bucketCubby : StaticBody2D = $YSort/BucketCubby
onready var worker : KinematicBody2D = $YSort/Worker

func _ready():
	connect_paint_cubbies()
	connect_workers()

func connect_paint_cubbies() -> void:
	var cubbyCount : int = 0
	var paintCubbyNodes : Array
	paintCubbyNodes = get_tree().get_nodes_in_group("PaintCubby")
	while cubbyCount < paintCubbyNodes.size():
		var cubbyNode : StaticBody2D = paintCubbyNodes[cubbyCount]
		cubbyNode.connect("playerNearPaintCubby", self, "_mark_player_near_to_cubby")
		cubbyNode.connect("playerFarPaintCubby", self, "_mark_player_far_from_cubby")
		cubbyCount += 1

func connect_paint_machines() -> void:
	var machineCount : int = 0
	var paintMachineNodes : Array
	paintMachineNodes = get_tree().get_nodes_in_group("PaintMachine")
	while machineCount < paintMachineNodes.size():
		var machineNode : Node2D = paintMachineNodes[machineCount]
		machineNode.connect("playerNearEmptyMachine", self, "_mark_player_near_empty_machine")
		machineNode.connect("playerNearLoadedMachine", self, "_mark_player_near_loaded_machine")
		machineNode.connect("playerFarFromPaintMachine", self, "_mark_player_far_from_machine")
		machineCount += 1

func connect_workers() -> void:
	var workerCount : int = 0
	var workerNodes : Array
	workerNodes = get_tree().get_nodes_in_group("Worker")
	while workerCount < workerNodes.size():
		var workerNode : KinematicBody2D = workerNodes[workerCount]
		workerNode.connect("canInteractCubby", self, "_mark_cubby_interactable")
		workerNode.connect("disconnectFromCubbies", self, "_disconnect_from_cubbies")
		workerNode.connect("canInteractPaintMachine", self, "_mark_cubby_interactable") #Make this function
		#workerNode.connect("disconnectFromCubbies", self, "_disconnect_from_cubbies")
		workerCount += 1

func _mark_player_near_to_cubby(player_node : KinematicBody2D, cubby_node):
	player_node.mark_cubby_nearby(cubby_node)

func _mark_player_far_from_cubby(player_node :KinematicBody2D, cubby_node):
	player_node.mark_cubby_far(cubby_node)

func _mark_cubby_interactable(player_node :KinematicBody2D, cubby_node):
	cubby_node.add_worker_to_nearby(player_node)

func _mark_player_near_empty_machine(player_node : KinematicBody2D, machine_node):
	player_node.mark_empty_machine_nearby(machine_node)
	
func _mark_player_near_loaded_machine(player_node : KinematicBody2D, machine_node):
	player_node.mark_cubby_nearby(machine_node)

func _mark_player_far_from_machine(player_node :KinematicBody2D, machine_node):
	player_node.mark_cubby_far(machine_node)

func _mark_machine_interactable(player_node :KinematicBody2D, machine_node):
	machine_node.add_worker_to_nearby(player_node)

func _disconnect_from_cubbies(player_node : KinematicBody2D, cubby_array : Array):
	if cubby_array.size() > 0:
		var cubbyCount : int = 0
		while cubbyCount < cubby_array.size():
			var cubbyNode : StaticBody2D = cubby_array[cubbyCount]
			cubbyNode.remove_from_cubby_can_press(player_node)
			cubbyCount += 1
