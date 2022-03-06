extends Node

onready var room : Node2D = $GameWorld/GameWorldPort/Room
onready var gameWorld : ViewportContainer = $GameWorld
onready var timeDispaly : RichTextLabel = $CanvasLayer/Control/HBoxContainer/Panel/TimeDisplay
onready var cashDispaly : RichTextLabel = $CanvasLayer/Control/HBoxContainer/CashDisplay
onready var moneyParticles : Particles2D = $MoneyParticles

signal readySendBuble(character_node, sent_position_node, sent_text, length, fade_time, speed)

var minutes : int = 0
var hours : int = 8

var earned_income : float = 0.0


func _ready():
	connect_room_signals()
	connect_worker_signals()
	set_clock()

func connect_room_signals():
	room.connect("createPaintMachineUI", self, "_create_paint_machine_ui")
	room.connect("createCustomerTextSignals", self, "_connect_customer_text_signals")


func connect_worker_signals() -> void:
	var workerCount : int = 0
	var workerNodes : Array
	workerNodes = get_tree().get_nodes_in_group("Worker")
	while workerCount < workerNodes.size():
		var scene := preload("res://TextalogNodes/CharacterPosition.tscn").instance()
		scene.set_name(str(workerNodes[workerCount]))
		self.add_child(scene)
		workerNodes[workerCount].textalogNode = scene
		var workerNode : KinematicBody2D = workerNodes[workerCount]
		workerNode.connect("createTextalog", self, "_create_textalog_box")
		workerNode.connect("sendTextalogPosition", self, "_update_textalog_position")
		workerCount += 1

func _connect_customer_text_signals(customer_node):
	var scene := preload("res://TextalogNodes/CharacterPosition.tscn").instance()
	scene.set_name(str(customer_node))
	self.add_child(scene)
	customer_node.textalogNode = scene
	customer_node.connect("createTextalog", self, "_create_textalog_box")
	customer_node.connect("sendTextalogPosition", self, "_update_textalog_position")
	customer_node.connect("collectPayment", self, "_upate_earned_amout")


func _create_paint_machine_ui(worker_node, machine_node) -> void:
	var createPaintMachineUI = preload("res://Devices/PaintMachineControl.tscn").instance()
	var popupPosition : Vector2 = machine_node.get_menu_location()*5 #testPos.position
	var popupRectPosition : Vector2 = Vector2(210, 150)
	createPaintMachineUI.workerNode = worker_node
	createPaintMachineUI.machineNode = machine_node
	gameWorld.add_child(createPaintMachineUI)
	createPaintMachineUI.popup(Rect2(popupPosition.x, popupPosition.y, popupRectPosition.x, popupRectPosition.y))
	#Above is kind of ghetto. Fix later. Probably bad for resizing.

func _update_textalog_position(character_node, new_position : Vector2):
	if character_node: 
		character_node.position = new_position

func _create_textalog_box(character_node, sent_position_node : Position2D, sent_text : String, length : float, fade_time : float, speed: float) -> void:
	var dialog_node = preload("res://addons/textalog/nodes/dialogue_bubble_node/dialog_bubble.tscn").instance()
	#dialog_node.rect_position = 5*(sent_position_node.position + Vector2(-35,-167))
	#dialog_node.fontSize = font_size
	dialog_node.timeLength = length
	dialog_node.text = sent_text
	dialog_node.fade_length = fade_time
	dialog_node.speed = speed
	add_child(dialog_node)
	dialog_node.positionNode = sent_position_node
	dialog_node.quick_adjust_location_and_play()
	dialog_node.characterNode = character_node
	#dialog_node.show_text(sent_text)


func set_clock() -> void:
	var min_string : String
	if minutes >= 10:
		min_string = str(minutes)
	else:
		min_string = "0" + str(minutes)
	var hour_string : String
	if hours > 12:
		hour_string = str(hours-12)
	else: 
		hour_string = str(hours)
	var AM_PM : String
	if hours >= 12:
		AM_PM = 'PM'
	else: 
		AM_PM = 'AM'
	var timeDisplay : String = hour_string + ":" + min_string + " " + AM_PM
	timeDispaly.bbcode_text = "[center]" + timeDisplay + "[/center]"
var AM_PM : String = 'AM'

func _upate_earned_amout(total_amount : float, color_amt: float, mix_penaly: float, shake_penalty: float):
	earned_income = earned_income + total_amount
	shoot_colors(total_amount)
	update_displayed_money()

func shoot_colors(total_amount:float)->void:
	if total_amount > 0.0:
		moneyParticles.modulate = Color8(18,212,25,255)
	else:
		moneyParticles.modulate = Color8(255,10,10,255)
	if total_amount > 8.0:
		moneyParticles.amount = 200
	elif total_amount > 4.0:
		moneyParticles.amount = 100
	else:
		moneyParticles.amount = 50
	moneyParticles.emitting = true

func update_displayed_money() -> void:
	cashDispaly.bbcode_text = "[center]$" + str(earned_income) + "[/center]"

func _on_ClockTimer_timeout():
	print(minutes)
	if minutes < 50:
		minutes = minutes + 10
		print("Here?")
	else:
		minutes = 0
		hours = hours + 1
		print("There?")
	set_clock()
