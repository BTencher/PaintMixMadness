extends Node2D


onready var bucketCubby : StaticBody2D = $YSort/BucketCubby
onready var worker : KinematicBody2D = $YSort/Worker

signal createPaintMachineUI(worker_node,machine_node)

func _ready():
	connect_paint_cubbies()
	connect_paint_machines()
	connect_hammer_stations()
	connect_paint_shakers()
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

func connect_hammer_stations() -> void:
	var hammerStationCount : int = 0
	var hammerStationNodes : Array
	hammerStationNodes = get_tree().get_nodes_in_group("HammerStation")
	while hammerStationCount < hammerStationNodes.size():
		var hammerStationNode : Node2D = hammerStationNodes[hammerStationCount]
		hammerStationNode.connect("playerNearHammerStation", self, "_mark_player_near_to_hammer_station")
		hammerStationNode.connect("playerFarFromHammerStation", self, "_mark_player_far_from_hammmer_station")
		hammerStationCount += 1

func connect_paint_shakers() -> void:
	var paintShakerCount : int = 0
	var paintShakerNodes : Array
	paintShakerNodes = get_tree().get_nodes_in_group("PaintShaker")
	while paintShakerCount < paintShakerNodes.size():
		var paintShakerNode : Node2D = paintShakerNodes[paintShakerCount]
		paintShakerNode.connect("playerNearEmptyShaker", self, "_mark_player_near_empty_shaker")
		paintShakerNode.connect("playerNearLoadedShaker", self, "_mark_player_near_loaded_shaker")
		paintShakerNode.connect("playerFarFromShaker", self, "_mark_player_far_from_shaker")
		paintShakerCount += 1

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
		workerNode.connect("interactWithHammerStation", self, "_start_interact_with_hammer_station")
		workerNode.connect("canInteractHammerStation", self, "_mark_hammer_station_interactable")
		workerNode.connect("checkSwingCount", self, "_check_swing_count_and_see_if_done")
		workerNode.connect("canInteractShaker", self, "_mark_shaker_interactable")
		workerNode.connect("interactWithShaker", self, "_interact_with_shaker")
		workerCount += 1

func remove_worker_from_machine_arrays(player_node : KinematicBody2D) -> void:
	if player_node.nearbyPaintMachine.size() > 0: #Emit signal to remove work from all machines, always
		var machineCount : int = 0
		while machineCount < player_node.nearbyPaintMachine.size():
			var machineNode : Node2D = player_node.nearbyPaintMachine[machineCount]
			machineNode.remove_from_machine_can_press(player_node)
			machineCount += 1
		player_node.nearbyPaintMachine.clear()

func remove_worker_from_hammer_station_arrays(player_node : KinematicBody2D) -> void:
	if player_node.nearbyHammerStation.size() > 0: #Emit signal to remove work from all machines, always
		var hammerStationCount : int = 0
		while hammerStationCount < player_node.nearbyHammerStation.size():
			var hammerStationNode : Node2D = player_node.nearbyHammerStation[hammerStationCount]
			hammerStationNode.remove_from_hammer_station_can_use(player_node)
			hammerStationCount += 1
		player_node.nearbyHammerStation.clear()

func move_filled_paint_can_from_machine_to_worker(worker_node : KinematicBody2D, machine_node : Node2D) -> void:
	#Start by getting paint can from worker
	var paintCanNode : Node2D
	for child in machine_node.get_children():
		if child.is_in_group("PaintCan"):
			paintCanNode = child
	machine_node.remove_child(paintCanNode)
	worker_node.move_paint_can_from_machine_to_worker(paintCanNode)
	machine_node.turn_off_machine()


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
	
func move_paint_can_from_worker_to_hammer_station(worker_node : KinematicBody2D, hammer_station : Node2D) -> void:
	#Start by getting paint can from worker
	var paintCanNode : Node2D
	for child in worker_node.get_children():
		if child.is_in_group("PaintCan"):
			paintCanNode = child
	worker_node.remove_child(paintCanNode)
	hammer_station.move_paint_can_to_hammer_station(paintCanNode)

func NOT_GETTING_CALLED(player_node : KinematicBody2D, hammer_station_node : Node2D):
	player_node.mark_hammer_station_nearby(hammer_station_node)
	
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

func _mark_player_near_to_hammer_station(player_node : KinematicBody2D, hammer_station_node : Node2D):
	player_node.mark_hammer_station_nearby(hammer_station_node)

func _mark_player_far_from_hammmer_station(player_node :KinematicBody2D, hammer_station_node):
	player_node.mark_hammer_station_far(hammer_station_node)

func _disconnect_from_cubbies(player_node : KinematicBody2D, cubby_array : Array):
	if cubby_array.size() > 0:
		var cubbyCount : int = 0
		while cubbyCount < cubby_array.size():
			var cubbyNode : StaticBody2D = cubby_array[cubbyCount]
			cubbyNode.remove_from_cubby_can_press(player_node)
			cubbyCount += 1

func _interact_with_paint_machine(player_node : KinematicBody2D, machine_node : Node2D) -> void:
	remove_worker_from_machine_arrays(player_node)
	if machine_node.currentPaintBucket: #If Machine already has a bucket
		move_filled_paint_can_from_machine_to_worker(player_node, machine_node)
	else:
		move_empty_paint_can_from_worker_to_machine(player_node, machine_node)

func _mark_hammer_station_interactable(player_node : KinematicBody2D, hammer_station : Node2D) -> void:
	hammer_station.add_worker_to_nearby(player_node)

func _start_interact_with_hammer_station(player_node : KinematicBody2D, hammer_station : Node2D) -> void:
	remove_worker_from_machine_arrays(player_node)
	move_paint_can_from_worker_to_hammer_station(player_node, hammer_station)

func _check_swing_count_and_see_if_done(player_node : KinematicBody2D, hammer_station : Node2D):
	hammer_station.numberOfHits += 1
	if hammer_station.numberOfHits >= hammer_station.numberOfHitsNeeded:
		player_node.more_swings = false
		_complete_hammer_station(player_node,hammer_station)
	else:
		player_node.start_next_swing()

func _complete_hammer_station(player_node : KinematicBody2D, hammer_station : Node2D):
	move_paint_can_from_hammer_station_to_worker(player_node, hammer_station)
	player_node.update_worker_state_to_filled_paint()
	

func move_paint_can_from_hammer_station_to_worker(player_node : KinematicBody2D, hammer_station : Node2D):
	#Start by getting paint can from worker
	var paintCanNode : Node2D
	for child in hammer_station.get_children():
		if child.is_in_group("PaintCan"):
			paintCanNode = child
	hammer_station.remove_child(paintCanNode)
	player_node.move_paint_can_from_hammer_station_to_worker(paintCanNode)

func _mark_player_near_empty_shaker(player_node : KinematicBody2D, shaker_node):
	player_node.mark_empty_shaker_nearby(shaker_node)
	
func _mark_player_near_loaded_shaker(player_node : KinematicBody2D, shaker_node):
	player_node.mark_loaded_shaker_nearby(shaker_node)

func _mark_player_far_from_shaker(player_node :KinematicBody2D, shaker_node):
	player_node.mark_shaker_far(shaker_node)

func _mark_shaker_interactable(player_node :KinematicBody2D, shaker_node):
	shaker_node.add_worker_to_nearby(player_node)

func _interact_with_shaker(player_node : KinematicBody2D, shaker_node : Node2D) -> void:
	remove_worker_from_shaker_arrays(player_node)
	if shaker_node.currentPaintBucket: #If Machine already has a bucket
		move_filled_paint_can_from_shaker_to_worker(player_node, shaker_node)
	else:
		move_paint_can_from_worker_to_shaker(player_node, shaker_node)
		player_node.release_worker_from_paint_bucket_to_shaker()

func remove_worker_from_shaker_arrays(player_node : KinematicBody2D) -> void:
	if player_node.nearbyShaker.size() > 0: #Emit signal to remove work from all machines, always
		var shakerCount : int = 0
		while shakerCount < player_node.nearbyShaker.size():
			var shakerNode : Node2D = player_node.nearbyShaker[shakerCount]
			shakerNode.remove_from_shaker_can_press(player_node) 
			shakerCount += 1
		player_node.nearbyShaker.clear()

func move_filled_paint_can_from_shaker_to_worker(worker_node : KinematicBody2D, shaker_node : Node2D) -> void:
	#Start by getting paint can from worker
	var paintCanNode : Node2D
	for child in shaker_node.get_children():
		if child.is_in_group("PaintCan"):
			paintCanNode = child
	shaker_node.remove_child(paintCanNode)
	worker_node.move_paint_can_from_shaker_to_worker(paintCanNode) ###
	shaker_node.turn_off_shaker()

func move_paint_can_from_worker_to_shaker(worker_node : KinematicBody2D, shaker_node : Node2D) -> void:
	#Start by getting paint can from worker
	var paintCanNode : Node2D
	for child in worker_node.get_children():
		if child.is_in_group("PaintCan"):
			paintCanNode = child
	worker_node.remove_child(paintCanNode)
	print("is this called multiple times? " + str(worker_node._state))
	worker_node.currentShakerNode = null
	shaker_node.move_and_start_shaker(paintCanNode)
