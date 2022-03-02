extends Node2D


onready var bucketCubby : StaticBody2D = $YSort/BucketCubby
onready var worker : KinematicBody2D = $YSort/Worker

signal createPaintMachineUI(worker_node,machine_node)

func _ready():
	connect_paint_cubbies()
	connect_paint_machines()
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
		workerNode.connect("canInteractPaintMachine", self, "_mark_machine_interactable")
		workerNode.connect("interactWithPaintMachine", self, "_interact_with_paint_machine")
		#workerNode.connect("disconnectFromCubbies", self, "_disconnect_from_cubbies")
		workerCount += 1

func remove_worker_from_machine_arrays(player_node : KinematicBody2D, machine_node : Node2D) -> void:
	if player_node.nearbyPaintMachine.size() > 0: #Emit signal to remove work from all machines, always
		var machineCount : int = 0
		while machineCount < player_node.nearbyPaintMachine.size():
			var machineNode : Node2D = player_node.nearbyPaintMachine[machineCount]
			machineNode.remove_from_machine_can_press(player_node)
			machineCount += 1
		player_node.nearbyPaintMachine.clear()

func move_filled_paint_can_from_machine_to_worker(worker_node : KinematicBody2D, machine_node : Node2D) -> void:
	#Start by getting paint can from worker
	var paintCanNode : Node2D
	for child in machine_node.get_children():
		if child.is_in_group("PaintCan"):
			paintCanNode = child
	machine_node.remove_child(paintCanNode)
	worker_node.move_paint_can_from_machine_to_worker(paintCanNode)


func move_empty_paint_can_from_worker_to_machine(worker_node : KinematicBody2D, machine_node : Node2D) -> void:
	#Start by getting paint can from worker
	var paintCanNode : Node2D
	for child in worker_node.get_children():
		if child.is_in_group("PaintCan"):
			paintCanNode = child
	worker_node.remove_child(paintCanNode)
	machine_node.move_paint_can_to_machine(paintCanNode)
	# Make paint machine popup
	emit_signal("createPaintMachineUI",worker_node, machine_node) 
	
	

func _mark_player_near_to_cubby(player_node : KinematicBody2D, cubby_node):
	player_node.mark_cubby_nearby(cubby_node)

func _mark_player_far_from_cubby(player_node :KinematicBody2D, cubby_node):
	player_node.mark_cubby_far(cubby_node)

func _mark_cubby_interactable(player_node :KinematicBody2D, cubby_node):
	cubby_node.add_worker_to_nearby(player_node)

func _mark_player_near_empty_machine(player_node : KinematicBody2D, machine_node):
	player_node.mark_empty_machine_nearby(machine_node)
	
func _mark_player_near_loaded_machine(player_node : KinematicBody2D, machine_node):
	player_node.mark_loaded_machine_nearby(machine_node)

func _mark_player_far_from_machine(player_node :KinematicBody2D, machine_node):
	player_node.mark_machine_far(machine_node)

func _mark_machine_interactable(player_node :KinematicBody2D, machine_node):
	machine_node.add_worker_to_nearby(player_node)

func _disconnect_from_cubbies(player_node : KinematicBody2D, cubby_array : Array):
	if cubby_array.size() > 0:
		var cubbyCount : int = 0
		while cubbyCount < cubby_array.size():
			var cubbyNode : StaticBody2D = cubby_array[cubbyCount]
			cubbyNode.remove_from_cubby_can_press(player_node)
			cubbyCount += 1

func _interact_with_paint_machine(player_node : KinematicBody2D, machine_node : Node2D) -> void:
	remove_worker_from_machine_arrays(player_node, machine_node)
	if machine_node.currentPaintBucket: #If Machine already has a bucket
		move_filled_paint_can_from_machine_to_worker(player_node, machine_node)
	else:
		move_empty_paint_can_from_worker_to_machine(player_node, machine_node)

