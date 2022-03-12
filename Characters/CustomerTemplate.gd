extends KinematicBody2D

const FRICTION : int = 500

var ACCELERATION : int = 300
var MAX_SPEED : int = 40
var velocity : Vector2 = Vector2.ZERO

var rng = RandomNumberGenerator.new()

var path := PoolVector2Array() setget set_path
var nextSpot := Vector2.ZERO
var meanderReady : bool = true

onready var animationPlayer : AnimationPlayer = $AnimationPlayer
onready var animationTree : AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var textalogPosition : Position2D = $TexalogPosition
onready var waitingTimer : Timer = $WaitingTimer
onready var textTimer : Timer = $TextTimer
onready var responseTimer : Timer = $ResponseTimer
onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator
onready var sprite : Sprite = $Sprite
onready var moneySprite : Sprite = $MoneySprite
onready var questionSprite : Sprite = $QuestionSprite

var ready_to_give_order : bool = false

var workersNearby : Array = []
var currentWorker : KinematicBody2D

var distanceForgiveness :float = 1
var slideForgiveness : float = 1
var distance : float =0

var textalogNode : Position2D = null

var desiredColor : Color = Color8(255,0,0,255)
var hexColor : String = "#" + desiredColor.to_html(false).to_upper()
var colorName : String = "Red"
var colorStringOpen : String = "[color=" + hexColor + "]"
var colorStringClose : String = "[/color]"
var colorString : String =  colorStringOpen + colorName + colorStringClose

var paintCan : Node2D

var characterOptions = {
	1:load("res://Art Assets/Customers1.png"), 
	2:load("res://Art Assets/Customers2.png"),
	3:load("res://Art Assets/Customers3.png"),
	4:load("res://Art Assets/Customers4.png"),
	5:load("res://Art Assets/Customers5.png"),
	6:load("res://Art Assets/Customers6.png"),
	7:load("res://Art Assets/Customers7.png")
	}

var colorOptions = {
	"Red":Color8(255,0,0),
	"Salmon":Color8(250,128,114),
	"Dark Orange":Color8(255,140,0),
	"Gold":Color8(255,215,0),
	"Olive":Color8(128,128,0),
	"Yellow":Color8(255,255,0),
	"Dark Green":Color8(0,100,0),
	"Green":Color8(0,128,0),
	"Lime":Color8(0,255,0),
	"Cyan":Color8(0,255,255),
	"Turquoise":Color8(64,224,208),
	"Navy":Color8(0,0,128),
	"Blue":Color8(0,0,255),
	"Indigo":Color8(75,0,130),
	"Purple":Color8(128,0,128),
	"Pink":Color8(255,192,203),
	"Black":Color8(0,0,0),
	"Silver":Color8(192,192,192),
	"Tan":Color8(210,180,140),
	"Orange":Color8(255,165,0)
	}



# An enum allows us to keep track of valid states.
enum States {SPAWN, WAITING, START_ORDER, MEANDER, SUMMONED, SUMMONED_WAITING, LEAVE}
var _state : int = States.SPAWN

# Called when the node enters the scene tree for the first time.

#signal headToDesk(this_node) MIGHT_NEED_LATER
signal sendTextalogPosition(position_node, position)
signal createTextalog(self_node, position_node, text, font_size, time_length, fade_length)

signal getMeanderDestination(this_node)
signal collectPayment(total_amount, color_amt, mix_penaly, shake_penalty)
signal customerLeave(this_node)

func _ready():
	rng.randomize()
	keyPressSprite.visible = false
	moneySprite.visible = false
	questionSprite.visible = false
	set_process(false)
	set_physics_process(false)
	sprite.texture = characterOptions.get(rng.randi_range(1,7))
	set_color()

func _physics_process(delta):
	emit_signal("sendTextalogPosition",textalogNode,textalogPosition.global_position)
	var input_vector : Vector2 = Vector2.ZERO
	match _state:
		States.SPAWN:
			if path.size() == 0:
				_state = States.WAITING
				start_waiting()
				if ready_to_give_order and Input.is_action_just_pressed("interact"):
					currentWorker.emit_text_signal("Welcome! What paint do ye seek?", 2, 0.2, 0.01)
					keyPressSprite.visible = false
					keyPressAnimator.stop()
					responseTimer.start()
		States.WAITING:
			if ready_to_give_order and Input.is_action_just_pressed("interact"):
				currentWorker.emit_text_signal("Welcome! What paint do ye seek?", 2, 0.2, 0.01)
				keyPressSprite.visible = false
				keyPressAnimator.stop()
				responseTimer.start()
		States.START_ORDER:
			keyPressSprite.visible = false
			keyPressAnimator.stop()
		States.MEANDER:
			MAX_SPEED = 30
			ACCELERATION = 250
			if path.size() == 0:
				if meanderReady:
					emit_signal("getMeanderDestination",self)
					waitingTimer.wait_time = rng.randf_range(7.0, 12.0)
					meanderReady = false
					waitingTimer.start()
		States.SUMMONED:
			if path.size() == 0:
				_state = States.SUMMONED_WAITING
				start_summoned_waiting()
		States.LEAVE:
			if path.size() == 0:
				queue_free()
	match _state:
		States.SPAWN, States.MEANDER, States.SUMMONED, States.LEAVE:
			input_vector = nextSpot - position
			distance = input_vector.length()
			if distance <= slideForgiveness:
				move_to_next_spot()
			input_vector = input_vector.normalized()
			if distance > distanceForgiveness:#input_vector != Vector2.ZERO:
				animationTree.set("parameters/Idle/blend_position", input_vector)
				animationTree.set("parameters/Walking/blend_position", input_vector)
				animationState.travel("Walking")
				velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
				velocity = move_and_slide(velocity)
			else:
				animationState.travel("Idle")
		States.WAITING, States.START_ORDER, States.SUMMONED_WAITING:
			animationTree.set("parameters/Idle/blend_position", Vector2(1,-1))
			animationTree.set("parameters/Walking/blend_position", Vector2(1,-1))
			animationState.travel("Idle")


func move_along_path(distance : float) -> void:
	pass

func set_path(value : PoolVector2Array) -> void:
	path = value
	if value.size() == 0:
		return
	set_process(true)
	set_physics_process(true)
	move_to_next_spot()

func move_to_next_spot() -> void:
	if path.size() <= 1:
		nextSpot = position
		if path.size() == 1:
			path.remove(0)
	else:
		path.remove(0)
		nextSpot = path[0]

func start_waiting():
	waitingTimer.start()

func set_color()->void:
	var a = colorOptions.keys()
	a = a[rng.randi() % a.size()]
	desiredColor = colorOptions.get(a)
	colorName  = a
	hexColor  = "#" + desiredColor.to_html(false).to_upper()
	colorStringOpen = "[color=" + hexColor + "]"
	colorStringClose  = "[/color]"
	colorString =  colorStringOpen + colorName + colorStringClose

func start_order():
	var text : String = "Hello! I want " + colorString + " paint. " + colorString + " paint."
	textTimer.wait_time = 4
	emit_text_signal(text, textTimer.wait_time-1, 0.1, 0.03)
	textTimer.start()

func emit_text_signal(text:String, time_length:float, fade_length:float, speed:float):
	emit_signal("createTextalog", self, textalogNode, text, time_length, fade_length, speed)

func update_to_summoned_state() -> void:
	update_state_to_summoned()
	reset_meander_values()

func update_state_to_summoned() -> void:
	_state = States.SUMMONED

func reset_meander_values() -> void:
	ACCELERATION = 300
	MAX_SPEED = 40
	waitingTimer.stop()
	meanderReady = true

func reset_to_meander() -> void:
	_state = States.MEANDER

func start_summoned_waiting()-> void:
	pass

func respond_to_color(judge_color : Color) -> void:
	var colorScore = color_score(judge_color, desiredColor)
	if colorScore == 0:
		emit_text_signal("[center]Yes! Looks great![/center]", 3, 0.1, 0.02)
	elif colorScore < 50:
		emit_text_signal("[center]Looks pretty good![/center]", 3, 0.1, 0.02)
	elif colorScore < 100:
		emit_text_signal("[center]Pretty close to " + colorString + "![/center]", 3, 0.1, 0.02)
	elif colorScore < 130:
		emit_text_signal("[center]I guess this will do![/center]", 3, 0.1, 0.02)
	elif colorScore < 150:
		emit_text_signal("[center]Maybe that is mine?[/center]", 3, 0.1, 0.02)
	elif colorScore < 180:
		emit_text_signal("[center]I hope that isn't mine. Is that " + colorString + "?[/center]", 3, 0.1, 0.02)
	elif colorScore < 200:
		emit_text_signal("[center]That is NOT " + colorString + ".[/center]", 3, 0.1, 0.02)

func color_score(paintCanColor : Color, desiredColor : Color) -> float:
	if paintCanColor.is_equal_approx(desiredColor):
		return 0.0
	else:
		var r_hat = (paintCanColor.r8+desiredColor.r8)/2
		var delta_red_squared : float = pow((paintCanColor.r8-desiredColor.r8),2.0)
		var delta_green_squared : float = pow((paintCanColor.g8-desiredColor.g8),2.0)
		var delta_blue_squared : float = pow((paintCanColor.b8-desiredColor.b8),2.0)
		var _red_math : float = 2.0+(r_hat/256.0)*delta_red_squared
		var _green_math : float = 4.0*(delta_green_squared)
		var _blue_math_with_red : float = (2.0+((256.0-r_hat)/256))*delta_blue_squared
		var delta_color : float = sqrt(_red_math + _green_math +  _blue_math_with_red)
		return delta_color

func judge_experience_and_leave() -> void:
	get_score_send_to_UI()
	set_state_to_leave_and_go()


func get_score_send_to_UI() -> void:
	var payment_amount : float = 0
	var colorScore = color_score(paintCan.paintEndColor, desiredColor)
	var colorDollars : float = 0
	var sprayDeduction : float = 0
	var shakeDeduction : float = 0
	if colorScore == 0:
		colorDollars = 10
	elif colorScore < 50:
		colorDollars = 8
	elif colorScore < 100:
		colorDollars = 7
	elif colorScore < 130:
		colorDollars = 5
	elif colorScore < 150:
		colorDollars = 4
	elif colorScore < 180:
		colorDollars = 0
	elif colorScore < 200:
		colorDollars = 2
	elif colorScore < 250:
		colorDollars = 1
	else:
		0
	if paintCan.tooMuchPaint:
		sprayDeduction = -2.00
	if paintCan.tooShaken:
		shakeDeduction = -2.00
	payment_amount = colorDollars + sprayDeduction + shakeDeduction
	emit_signal("collectPayment", payment_amount, colorDollars, sprayDeduction, shakeDeduction)

func set_state_to_leave_and_go() -> void:
	_state = States.LEAVE
	emit_signal("customerLeave",self)

func remind_color():
	emit_text_signal("[center]" + colorString + ".[/center]", 2, 0.1, 0.02)

func _on_WaitingTimer_timeout():
	match _state:
		States.WAITING:
			if !currentWorker:
				waitingTimer.wait_time = 6
				emit_text_signal("[center]...[/center]", 2, 0.1, 0.5)
				waitingTimer.wait_time = 6
				waitingTimer.one_shot = false
				waitingTimer.start()
		States.MEANDER:
			meanderReady = true

func _on_Area2D_body_entered(body):
	workersNearby.append(body)

func _on_Area2D_body_exited(body):
	workersNearby.erase(body)


func _on_TextTimer_timeout():
	if _state == States.START_ORDER:
		_state = States.MEANDER

func _on_TalkingZone_body_entered(body):
	match _state:
		States.WAITING, States.SPAWN:
			currentWorker = body
			ready_to_give_order = true
			keyPressSprite.visible = true
			keyPressAnimator.play("KeyPress")
	#Check if player has full paint can if not, make animated question mark that will make say the color again
	#If has full, show symbol based on color proximity

func _on_TalkingZone_body_exited(body):
	match _state:
		States.WAITING:
			currentWorker = null
			keyPressSprite.visible = false
			keyPressAnimator.stop()
			ready_to_give_order = false

func play_money_continue () -> void:
	keyPressAnimator.play("SellIdle")

func play_question_continue () -> void:
	keyPressAnimator.play("QuestionIdle")

func _on_ResponseTimer_timeout():
	_state = States.START_ORDER
	start_order()
