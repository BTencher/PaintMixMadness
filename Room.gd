extends Node2D


onready var bucketCubby : StaticBody2D = $YSort/BucketCubby
onready var worker : KinematicBody2D = $YSort/Worker
onready var nav2d : Navigation2D = $YSort/Navigation2D
onready var spawnlocation : PathFollow2D = $SpawnPath/SpawnPathLocation
onready var meanderLocation : PathFollow2D = $MeanderPath/MeanderPathLocation
onready var ysort : YSort = $YSort
onready var deskspots : Node = $DeskSpots
onready var spawnTimer : Timer = $SpawnTimer

#Temporary Customer Template
onready var line : Line2D = $YSort/Line2D

signal createPaintMachineUI(worker_node,machine_node)
signal createCustomerTextSignals(customer_node)

export (PackedScene) var customerScene

var activeCustomers : Array = []
var rng = RandomNumberGenerator.new()


func _ready():
	connect_paint_cubbies()
	connect_paint_machines()
	connect_hammer_stations()
	connect_paint_shakers()
	connect_workers()
	spawn_customer()
	spawnTimer.start()
	rng.randomize()

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
		#paintShakerNode.connect("playerNearEmptyShaker", self, "_mark_player_near_empty_shaker")
		#paintShakerNode.connect("playerNearLoadedShaker", self, "_mark_player_near_loaded_shaker")
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
		workerNode.connect("interactWithPaintMachine", self, "_interact_with_paint_machine")
		workerNode.connect("interactWithHammerStation", self, "_start_interact_with_hammer_station")
		workerNode.connect("canInteractHammerStation", self, "_mark_hammer_station_interactable")
		workerNode.connect("checkSwingCount", self, "_check_swing_count_and_see_if_done")
		#workerNode.connect("canInteractShaker", self, "_mark_shaker_interactable")
		workerNode.connect("interactWithShaker", self, "_interact_with_shaker")
		workerCount += 1



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


func _mark_player_far_from_machine(player_node :KinematicBody2D, machine_node):
	player_node.mark_machine_far(machine_node)

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
	#remove_worker_from_machine_arrays(player_node)
	if machine_node.currentPaintBucket and machine_node.currentPaintBucket.isFilled: #If Machine already has a bucket
		move_filled_paint_can_from_machine_to_worker(player_node, machine_node)
	elif machine_node.currentPaintBucket:
		emit_signal("createPaintMachineUI",player_node, machine_node) 
	else:
		move_empty_paint_can_from_worker_to_machine(player_node, machine_node)

func _mark_hammer_station_interactable(player_node : KinematicBody2D, hammer_station : Node2D) -> void:
	hammer_station.add_worker_to_nearby(player_node)

func _start_interact_with_hammer_station(player_node : KinematicBody2D, hammer_station : Node2D) -> void:
	#remove_worker_from_machine_arrays(player_node)
	move_paint_can_from_worker_to_hammer_station(player_node, hammer_station)

func _check_swing_count_and_see_if_done(player_node : KinematicBody2D, hammer_station : Node2D):
	hammer_station.numberOfHits += 1
	if hammer_station.numberOfHits >= hammer_station.numberOfHitsNeeded:
		player_node.more_swings = false
		_complete_hammer_station(player_node,hammer_station)
	else:
		match hammer_station.numberOfHitsNeeded-hammer_station.numberOfHits:
			1: 
				player_node.emit_text_signal("[center]One to go!![/center]", 0.04, 0.1, 0.03)
			2: 
				player_node.emit_text_signal("[center]Only two left...[/center]", 0.04, 0.1, 0.03)
			3: 
				player_node.emit_text_signal("[center]Three...[/center]", 0.04, 0.1, 0.03)
			4: 
				player_node.emit_text_signal("[center]Four....[/center]", 0.04, 0.1, 0.03)
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

#func _mark_player_near_empty_shaker(player_node : KinematicBody2D, shaker_node):
#	player_node.mark_empty_shaker_nearby(shaker_node)
	
#func _mark_player_near_loaded_shaker(player_node : KinematicBody2D, shaker_node):
#	player_node.mark_loaded_shaker_nearby(shaker_node)

func _mark_player_far_from_shaker(player_node :KinematicBody2D, shaker_node):
	player_node.mark_shaker_far(shaker_node)

#func _mark_shaker_interactable(player_node :KinematicBody2D, shaker_node):
#	shaker_node.add_worker_to_nearby(player_node)

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
	worker_node.currentShakerNode = null
	shaker_node.move_and_start_shaker(paintCanNode)

func navigate_customer_to_open_desk_stop(customer_id) -> void:
	var deskPosition : Vector2
	for child in deskspots.get_children():
		if !child.assignedCustomer and !deskPosition:
			child.assignedCustomer = customer_id
			deskPosition = child.position
	if deskPosition:
		navigateCustomer(customer_id,deskPosition)


func navigateCustomer(customer_id : KinematicBody2D, new_position : Vector2) -> void:
	var new_path := nav2d.get_simple_path(customer_id.position, new_position)
	customer_id.path = new_path


func spawn_customer() -> void:
	spawnlocation.unit_offset = randf()
	var customer = customerScene.instance()
	customer.position = spawnlocation.position
	ysort.add_child(customer)
	navigate_customer_to_open_desk_stop(customer)
	activeCustomers.append(customer)
	#Connect to singals
	call_deferred("emit_signal", "createCustomerTextSignals", customer)
	customer.connect("getMeanderDestination", self, "_set_new_meander_destination")
	customer.connect("customerLeave", self, "_set_leave_destination")
	#emit_signal("createCustomerTextSignals",customer)

func _set_new_meander_destination(customer_id : KinematicBody2D) -> void:
	meanderLocation.unit_offset = randf()
	var new_destination : Vector2 = meanderLocation.position
	navigateCustomer(customer_id, new_destination) 

func _set_leave_destination(customer_id : KinematicBody2D) -> void:
	spawnlocation.unit_offset = randf()
	var new_destination : Vector2 = spawnlocation.position
	navigateCustomer(customer_id, new_destination)
	activeCustomers.erase(customer_id)
	for child in deskspots.get_children():
		if child.assignedCustomer == customer_id:
			child.assignedCustomer = null

func _on_SpawnTimer_timeout():
	if activeCustomers.size() < 5:
		spawnTimer.wait_time = rng.randi_range(14,25)
		spawn_customer()
	else:
		spawnTimer.wait_time = 8

func _on_CustomerSummonZone_body_entered(body):
	var deskPosition : Vector2
	if body.currentBucketNode:
		if body.currentBucketNode.shaken:
			body.ask_about_color(body.currentBucketNode.paintEndColor)
	for child in deskspots.get_children():
		if child.assignedCustomer != null:
			var customer_node : KinematicBody2D = child.assignedCustomer
			if customer_node._state == customer_node.States.MEANDER:
				navigateCustomer(customer_node,child.position)
				customer_node.update_to_summoned_state()
				deskPosition = child.position
				if body.currentBucketNode:
					if body.currentBucketNode.shaken:
						customer_node.respond_to_color(body.currentBucketNode.paintEndColor)

func _on_CustomerSummonZone_body_exited(_body):
	var deskPosition : Vector2
	for child in deskspots.get_children():
		if child.assignedCustomer != null:
			var customer_node : KinematicBody2D = child.assignedCustomer
			if customer_node._state == customer_node.States.SUMMONED_WAITING or customer_node._state == customer_node.States.SUMMONED:
				customer_node.reset_to_meander()
			deskPosition = child.position
