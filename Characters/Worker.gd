extends KinematicBody2D


const ACCELERATION : int = 500
const MAX_SPEED : int = 80
const FRICTION : int = 500

var velocity : Vector2 = Vector2.ZERO

onready var bucketPosition : Position2D = $BucketPosition
onready var animationPlayer : AnimationPlayer = $AnimationPlayer
onready var animationTree : AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var textalogPosition : Position2D = $TexalogPosition
onready var responseTimer : Timer = $ResponseTimer

# An enum allows us to keep track of valid states.
enum States {EMPTY_HANDS, CAN_PICK_UP, PICKING_UP_CAN, EMPTY_PAINT, CAN_USE_MACHINE, USING_MACHINE, OPEN_PAINT, CAN_USE_HAMMER, USING_HAMMER, CLOSE_PAINT, CAN_USE_SHAKER,USING_SHAKER,DONE_PAINT,READY_GIVE}
var _state : int = States.EMPTY_HANDS

enum HammerStates {ARRIVE, LIFT, READY_SLAM, SLAM, CHECK, DONE}
var _hammer_state : int = HammerStates.ARRIVE
var more_swings : bool = true

var nearbyCubbies : Array = []
var nearbyPaintMachine : Array = []
var nearbyHammerStation : Array = []
var nearbyShaker : Array = []

var currentBucketNode : Node2D = null
var currentMachineNode : Node2D = null
var currentHammerStationNode : Node2D = null
var currentShakerNode : Node2D = null
var currentCustomer : KinematicBody2D = null

var canAskQuestion : bool = false
var canDeletePaint : bool = false

var textalogNode : Position2D = null

var trashcanNode : StaticBody2D = null

signal canInteractCubby(this_node, cubby_node)
signal disconnectFromCubbies(this_node, arrayNearbyCubbies)

#signal canInteractPaintMachine(this_node, machine_node)
signal interactWithPaintMachine(this_node, machine_node)

signal canInteractHammerStation(this_node, hammer_station_node)
signal interactWithHammerStation(this_node, hammer_station_node)
signal checkSwingCount(this_node, hammer_station_node) 
#signal completeHammerStation(this_node, arrayNearbyCubbies) #Not used yet

signal canInteractShaker(this_node, shaker_node)
signal interactWithShaker(this_node, machine_node)

signal sendTextalogPosition(position_node, position)
signal createTextalog(self_node, position_node, text, font_size, time_length, fade_length)

func _ready() -> void:
	pass
	
func _physics_process(delta) -> void:
	#print(_state)
	var input_vector : Vector2 = Vector2.ZERO
	emit_signal("sendTextalogPosition",textalogNode,textalogPosition.global_position)
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if Input.is_action_just_pressed("interact"):
		match _state:
			States.CAN_PICK_UP:
				_state = States.PICKING_UP_CAN
				pick_up_from_paint_cubby()
			States.CAN_USE_MACHINE:
				_state = States.USING_MACHINE
				interact_with_paint_machine()
			States.CAN_USE_HAMMER:
				_state = States.USING_HAMMER
				interact_with_hammer_station()
			States.CAN_USE_SHAKER:
				_state = States.USING_SHAKER
				interact_with_shaker()
			States.READY_GIVE:
				give_paint_to_customer()
		if canAskQuestion:
			ask_color_again()
	if Input.is_action_just_pressed("delete_paint") and canDeletePaint != null and currentBucketNode != null:
		_state = States.EMPTY_HANDS
		currentBucketNode.queue_free()
		currentBucketNode = null
		canDeletePaint = false
		if trashcanNode:
			trashcanNode.animationPlayer.stop()
			trashcanNode = null
	match _state:
		States.EMPTY_HANDS,States.OPEN_PAINT,States.CAN_PICK_UP,States.EMPTY_PAINT,States.CAN_USE_MACHINE,States.OPEN_PAINT,States.CAN_USE_HAMMER,States.CLOSE_PAINT,States.CAN_USE_SHAKER,States.DONE_PAINT,States.READY_GIVE:
			if !animationTree.active == true:
				animationTree.active = true
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
		States.USING_MACHINE:
			animationState.travel("Idle")
			animationTree.set("parameters/Idle/blend_position", Vector2(0.7,-0.7))
		States.USING_HAMMER:
			#animationTree.set("parameters/Idle/blend_position", Vector2(0.7,0.7))
			if _hammer_state == HammerStates.ARRIVE and more_swings:
				_hammer_state = HammerStates.LIFT
				animationState.travel("HammerLiftDownRight")
			#if _hammer_state == HammerStates.ARRIVE and !more_swings:
			#	end_hammer_station()
			elif _hammer_state == HammerStates.READY_SLAM and Input.is_action_just_pressed("interact"):
				animationState.travel("HammerSlamDownRight")
			else:
				pass
		States.USING_SHAKER:
			pass #Nothing for now

func pick_up_from_paint_cubby() -> void:
	animationTree.active = false
	animationPlayer.play("PickUpBucket") #Calls create_paint_can_child()

func create_paint_can_child() -> void:
	var paintBucketScene = preload("res://Devices/PaintCan.tscn").instance()
	currentBucketNode = paintBucketScene
	add_child(paintBucketScene)
	call_deferred("emit_signal", "disconnectFromCubbies", self, nearbyCubbies)
	bring_paint_can_to_back()

func move_paint_can() -> void:
	if currentBucketNode:
		currentBucketNode.position = bucketPosition.position

func bring_paint_can_to_front() -> void:
	if currentBucketNode in self.get_children():
		move_child(currentBucketNode,get_child_count()-1)
	else:
		print("bring_paint_can_to_front can for some reason without a bucket.")

func bring_paint_can_to_back() -> void:
	if currentBucketNode in self.get_children():
		move_child(currentBucketNode,0)
	else:
		print("bring_paint_can_to_back can for some reason without a bucket.")

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


func mark_machine_far(machine_id : Node2D) -> void:
	nearbyPaintMachine.erase(machine_id)
	if nearbyPaintMachine.size() == 0 and _state == States.CAN_USE_MACHINE:
		if currentBucketNode:
			if currentBucketNode.hasLid:
				_state = States.CLOSE_PAINT
			elif currentBucketNode.isFilled:
				_state = States.OPEN_PAINT
			else:
				_state = States.EMPTY_PAINT
		else:
			_state = States.EMPTY_HANDS

func interact_with_paint_machine() -> void:
	currentMachineNode = nearbyPaintMachine[0] #Mark machine we are using
	emit_signal("interactWithPaintMachine",self,currentMachineNode)

#This looks real wrong
func move_paint_can_to_machine(paintCanNode : Node2D) -> void:
	var paintCan : Node2D = paintCanNode
	paintCan.position = bucketPosition.position
	add_child(paintCan)
	currentBucketNode = paintCan
	_state = States.OPEN_PAINT

func release_worker_from_machine() -> void:
	#Called from Paint Machine Control UI button press.
	_state = States.EMPTY_HANDS
	currentBucketNode = null
	animationPlayer.stop()
	animationTree.active = true

func move_paint_can_from_machine_to_worker(paintCanNode : Node2D) -> void:
	currentBucketNode = paintCanNode
	add_child(paintCanNode)
	bring_paint_can_to_back()
	_state = States.OPEN_PAINT
	animationTree.active = true

func move_paint_can_from_hammer_station_to_worker(paintCanNode : Node2D) -> void:
	currentBucketNode = paintCanNode
	add_child(paintCanNode)
	bring_paint_can_to_back()
	#_state = States.OPEN_PAINT
	#animationTree.active = true

func mark_hammer_station_nearby(hammerStationID : Node2D) -> void:
	nearbyHammerStation.append(hammerStationID)
	if nearbyHammerStation.size() > 0 and _state == States.OPEN_PAINT:
		_state = States.CAN_USE_HAMMER
		emit_signal("canInteractHammerStation",self,hammerStationID)

func mark_hammer_station_far(hammerStationID : Node2D) -> void:
	nearbyHammerStation.erase(hammerStationID)
	if nearbyHammerStation.size() == 0 and _state == States.CAN_USE_HAMMER:
		_state = States.OPEN_PAINT

func interact_with_hammer_station() -> void:
	currentHammerStationNode = nearbyHammerStation[0] #Mark machine we are using
	more_swings = true
	_hammer_state = HammerStates.ARRIVE #READY_SLAM
	emit_signal("interactWithHammerStation",self,currentHammerStationNode)

func ready_for_hammer_swing() -> void:
	_hammer_state = HammerStates.READY_SLAM

func end_hammer_swing() -> void:
	_hammer_state = HammerStates.CHECK
	emit_signal("checkSwingCount",self,currentHammerStationNode)

func start_next_swing() -> void:
	_hammer_state = HammerStates.ARRIVE

func update_worker_state_to_filled_paint():
	_state = States.CLOSE_PAINT
	_hammer_state = HammerStates.DONE
	currentHammerStationNode = null
	nearbyHammerStation.clear()

#func mark_empty_shaker_nearby(shaker_id : Node2D) -> void:
#	nearbyShaker.append(shaker_id)
#	currentShakerNode = shaker_id
#	if _state == States.CLOSE_PAINT:
#		_state = States.CAN_USE_SHAKER
#		emit_signal("canInteractShaker",self,shaker_id)

#func mark_loaded_shaker_nearby(shaker_id : Node2D) -> void:
#	nearbyShaker.append(shaker_id)
#	currentShakerNode = shaker_id
#	if _state == States.EMPTY_HANDS:
#		_state = States.CAN_USE_SHAKER
#	if _state == States.CAN_USE_SHAKER and nearbyShaker.has(shaker_id):
#		emit_signal("canInteractShaker",self,shaker_id)

func interact_with_shaker() -> void:
	#currentShakerNode = nearbyShaker[0] #Mark machine we are using
	emit_signal("interactWithShaker",self,currentShakerNode)
	#_state = States.EMPTY_HANDS

func mark_shaker_far(shaker_id : Node2D) -> void:
	currentShakerNode = null
	nearbyPaintMachine.erase(shaker_id)
	if nearbyPaintMachine.size() == 0 and _state == States.CAN_USE_SHAKER:
		if currentBucketNode:
			if currentBucketNode.shaken:
				_state = States.DONE_PAINT
			elif currentBucketNode.hasLid:
				_state = States.CLOSE_PAINT
			elif currentBucketNode.isFilled:
				_state = States.OPEN_PAINT
			else:
				_state = States.EMPTY_PAINT
		else:
			_state = States.EMPTY_HANDS

func move_paint_can_from_shaker_to_worker(paintCanNode : Node2D) -> void:
	currentBucketNode = paintCanNode
	add_child(paintCanNode)
	bring_paint_can_to_front()
	_state = States.DONE_PAINT
	#animationTree.active = true

func release_worker_from_paint_bucket_to_shaker():
	_state = States.EMPTY_HANDS
	currentBucketNode = null

func ask_about_color(finished_color : Color):
	var color_hex : String =  "#"+finished_color.to_html(false).to_upper()
	emit_text_signal("Does this [color=" + color_hex + "] paint [/color] look right?", 3, 0.3, 0.04)

func ask_color_again() -> void:
	emit_text_signal("What color?", 1.5, 0.2, 0.02)
	responseTimer.start()
	

func emit_text_signal(text:String, time_length:float, fade_length:float, speed:float):
	emit_signal("createTextalog", self, textalogNode, text, time_length, fade_length, speed)

func _on_PaintGiveArea_body_entered(body):
	match _state:
		States.DONE_PAINT, States.READY_GIVE:
			match body._state:
				body.States.MEANDER, body.States.SUMMONED, body.States.SUMMONED_WAITING:
					if currentCustomer != null:
						if currentCustomer != body:
							currentCustomer.keyPressAnimator.play("SellHide")
					currentCustomer = body
					_state = States.READY_GIVE
					body.keyPressAnimator.play("SellLoad")
				
		_:
			match body._state:
				body.States.MEANDER, body.States.SUMMONED, body.States.SUMMONED_WAITING:
					if currentCustomer != null:
						if currentCustomer != body:
							currentCustomer.keyPressAnimator.play("QuestionHide")
					currentCustomer = body
					canAskQuestion = true
					body.keyPressAnimator.play("QuestionLoad")
				

func _on_PaintGiveArea_body_exited(body):
	if _state == States.READY_GIVE or _state == States.DONE_PAINT:
		if currentCustomer == body:
			currentCustomer = null
			_state = States.DONE_PAINT
			body.keyPressAnimator.play("SellHide")
		else: 
			body.keyPressAnimator.play("SellHide")
	else:
		if currentCustomer == body:
			currentCustomer = null
			canAskQuestion = false
			body.keyPressAnimator.play("QuestionHide")
		else:
			body.keyPressAnimator.play("QuestionHide")

func give_paint_to_customer() -> void:
	if currentCustomer != null:
		match currentCustomer._state:
			currentCustomer.States.MEANDER, currentCustomer.States.SUMMONED, currentCustomer.States.SUMMONED_WAITING:
				currentBucketNode.visible = false
				var paintCanNode : Node2D = currentBucketNode
				currentBucketNode = null
				remove_child(paintCanNode)
				currentCustomer.add_child(paintCanNode)
				_state = States.EMPTY_HANDS
				currentCustomer.paintCan = paintCanNode
				currentCustomer.judge_experience_and_leave()

func _on_ResponseTimer_timeout():
	if currentCustomer != null:
		currentCustomer.remind_color()
