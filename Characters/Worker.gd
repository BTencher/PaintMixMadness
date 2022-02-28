extends "res://Characters/PersonTemplate.gd"

# An enum allows us to keep track of valid states.
enum States {EMPTY_HANDS, PICKING_UP_CAN, EMPTY_PAINT, USING_MACHINE, OPEN_PAINT, USING_HAMMER, CLOSE_PAINT}

# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.EMPTY_HANDS

var canPickUpCan : bool = false
var canUseMachine : bool = false
var canHammer : bool = false

func _physics_process(delta) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if _state == States.EMPTY_HANDS and canPickUpCan and Input.is_action_just_pressed("move_up"):
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
