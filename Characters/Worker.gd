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

func _physics_process(delta) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if _state == States.CAN_PICK_UP and Input.is_action_just_pressed("interact"):
		_state = States.PICKING_UP_CAN
		pick_up_from_paint_cubby()
		
	if _state == States.EMPTY_HANDS or _state == States.OPEN_PAINT or _state == States.CAN_PICK_UP or _state == States.EMPTY_PAINT:
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
	emit_signal("disconnectFromCubbies",self,nearbyCubbies)
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
		self._state = States.CAN_PICK_UP
		emit_signal("canInteractCubby",self,cubbyID)
		
func mark_cubby_far(cubbyID : StaticBody2D) -> void:
	nearbyCubbies.erase(cubbyID)
	if nearbyCubbies.size() == 0 and _state == States.CAN_PICK_UP:
		self._state = States.EMPTY_HANDS
