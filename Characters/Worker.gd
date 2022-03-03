extends KinematicBody2D


const ACCELERATION : int = 500
const MAX_SPEED : int = 80
const FRICTION : int = 500

var velocity : Vector2 = Vector2.ZERO

onready var bucketPosition : Position2D = $BucketPosition
onready var animationPlayer : AnimationPlayer = $AnimationPlayer
onready var animationTree : AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


# An enum allows us to keep track of valid states.
enum States {EMPTY_HANDS, CAN_PICK_UP, PICKING_UP_CAN, EMPTY_PAINT, CAN_USE_MACHINE, USING_MACHINE, OPEN_PAINT, CAN_USE_HAMMER, USING_HAMMER, CLOSE_PAINT}
var _state : int = States.EMPTY_HANDS

var nearbyCubbies : Array = []

var currentBucketNode : Node2D = null

signal canInteractCubby(this_node, cubby_node)
signal disconnectFromCubbies(this_node, arrayNearbyCubbies)

var nearbyPaintMachine : Array = []
var currentMachineNode : Node2D
signal canInteractPaintMachine(this_node, machine_node)
#signal disconnectFromPaintMachines(this_node, arrayNearbyMachines) Not needed?
signal interactWithPaintMachine(this_node, machine_node)


func _physics_process(delta) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if _state == States.CAN_PICK_UP and Input.is_action_just_pressed("interact"):
		_state = States.PICKING_UP_CAN
		pick_up_from_paint_cubby()
	elif _state == States.CAN_USE_MACHINE and Input.is_action_just_pressed("interact"):
		_state = States.USING_MACHINE
		interact_with_paint_machine()
		
	#if _state == States.EMPTY_HANDS or _state == States.OPEN_PAINT or _state == States.CAN_PICK_UP or _state == States.EMPTY_PAINT or _state == States.CAN_USE_MACHINE or _state == States.OPEN_PAINT:
	match _state:
		States.EMPTY_HANDS,States.OPEN_PAINT,States.CAN_PICK_UP,States.EMPTY_PAINT,States.CAN_USE_MACHINE,States.OPEN_PAINT:
			if input_vector != Vector2.ZERO:
				animationTree.set("parameters/Idle/blend_position", input_vector)
				animationTree.set("parameters/Walking/blend_position", input_vector)
				animationTree.set("parameters/IdleBucket/blend_position", input_vector)
				animationTree.set("parameters/WalkingBucket/blend_position", input_vector)
				if currentBucketNode:
					animationState.travel("WalkingBucket")
				else:
					animationState.travel("Walking")
				velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
			else:
				if currentBucketNode:
					animationState.travel("IdleBucket")
				else:
					animationState.travel("Idle")
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			velocity = move_and_slide(velocity)

func pick_up_from_paint_cubby() -> void:
	animationTree.active = false
	animationPlayer.play("PickUpBucket")

func create_paint_can_child() -> void:
	var paintBucketScene = preload("res://Devices/PaintCan.tscn").instance()
	currentBucketNode = paintBucketScene
	move_paint_can()
	add_child(paintBucketScene)
	call_deferred("emit_signal", "disconnectFromCubbies", self, nearbyCubbies )
	bring_paint_can_to_back()

func move_paint_can() -> void:
	currentBucketNode.position = bucketPosition.position

func bring_paint_can_to_front() -> void:
	move_child(currentBucketNode,get_child_count()-1)

func bring_paint_can_to_back() -> void:
	move_child(currentBucketNode,0)

func finish_picking_up_paint() -> void:
	animationTree.active = true
	if _state == States.PICKING_UP_CAN:
		_state = States.EMPTY_PAINT
	elif _state == States.USING_MACHINE:
		_state = States.OPEN_PAINT

func mark_cubby_nearby(cubbyID : StaticBody2D) -> void:
	nearbyCubbies.append(cubbyID)
	if nearbyCubbies.size() > 0 and _state == States.EMPTY_HANDS:
		_state = States.CAN_PICK_UP
		emit_signal("canInteractCubby",self,cubbyID)
		
func mark_cubby_far(cubbyID : StaticBody2D) -> void:
	nearbyCubbies.erase(cubbyID)
	if nearbyCubbies.size() == 0 and _state == States.CAN_PICK_UP:
		_state = States.EMPTY_HANDS

func mark_empty_machine_nearby(machine_id : Node2D) -> void:
	nearbyPaintMachine.append(machine_id)
	if nearbyPaintMachine.size() > 0 and _state == States.EMPTY_PAINT:
		_state = States.CAN_USE_MACHINE
		emit_signal("canInteractPaintMachine",self,machine_id)

func mark_loaded_machine_nearby(machine_id : Node2D) -> void:
	nearbyPaintMachine.append(machine_id)
	if nearbyPaintMachine.size() > 0 and _state == States.EMPTY_HANDS:
		_state = States.CAN_USE_MACHINE
		emit_signal("canInteractPaintMachine",self,machine_id)
		
func mark_machine_far(machine_id : Node2D) -> void:
	nearbyPaintMachine.erase(machine_id)
	if nearbyPaintMachine.size() == 0 and _state == States.CAN_USE_MACHINE:
		_state = States.EMPTY_PAINT

func interact_with_paint_machine() -> void:
	_state = States.USING_MACHINE
	currentMachineNode = nearbyPaintMachine[0] #Mark machine we are using
	emit_signal("interactWithPaintMachine",self,currentMachineNode)
	animationTree.active = false #make idle_up_right
	animationPlayer.play("IdleUpRight") #maybe make a new animation. Do later
	print("Stuck?")

#This looks real wrong
func move_paint_can_to_machine(paintCanNode : Node2D) -> void:
	var paintCan : Node2D = paintCanNode
	paintCan.position = bucketPosition.position
	add_child(paintCan)
	currentBucketNode = paintCan
	_state = States.OPEN_PAINT

func release_worker_from_machine() -> void:
	_state = States.EMPTY_HANDS
	currentBucketNode = null
	animationPlayer.stop()
	animationTree.active = true

func move_paint_can_from_machine_to_worker(paintCanNode : Node2D) -> void:
	currentBucketNode = paintCanNode
	add_child(paintCanNode)
	call_deferred("emit_signal", "disconnectFromCubbies", self, nearbyCubbies )
	bring_paint_can_to_back()
	_state = States.OPEN_PAINT
	animationPlayer.stop()
	animationTree.active = true
	print("HEre?")
