extends "res://Characters/PersonTemplate.gd"

# An enum allows us to keep track of valid states.
enum States {EMPTY_HANDS, CAN_PICK_UP, PICKING_UP_CAN, EMPTY_PAINT, CAN_USE_MACHINE, USING_MACHINE, OPEN_PAINT, CAN_USE_HAMMER, USING_HAMMER, CLOSE_PAINT}
var _state : int = States.EMPTY_HANDS setget updateState

var nearbyCubbies : Array = []

signal canInteractCubby(this_node, cubby_node)

func _physics_process(delta) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if _state == States.CAN_PICK_UP and Input.is_action_just_pressed("interact"):
		_state = States.PICKING_UP_CAN
		
	if _state == States.EMPTY_HANDS or _state == States.OPEN_PAINT:
		if input_vector != Vector2.ZERO:
			animationTree.set("parameters/Idle/blend_position", input_vector)
			animationTree.set("parameters/Walking/blend_position", input_vector)
			animationState.travel("Walking")
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		else:
			animationState.travel("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		velocity = move_and_slide(velocity)

func updateState(new_state : int) -> void:
	_state = new_state
	if _state == States.CAN_PICK_UP:
		pass

func markCubbyNearby(cubbyID : StaticBody2D) -> void:
	nearbyCubbies.append(cubbyID)
	if nearbyCubbies.size() > 0 and _state == States.EMPTY_HANDS:
		_state = States.CAN_PICK_UP
		emit_signal("canInteractCubby",self,cubbyID)
	elif not nearbyCubbies.size() == 0 and _state == States.CAN_PICK_UP:
		_state = States.EMPTY_HANDS
