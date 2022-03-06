tool
extends DialogNode
class_name DialogBubble


onready var closeTimer : Timer = $CloseTimer
onready var alphaTimer : Timer = $AlphaTimer
onready var funkyTimer : Timer = $FunkyTimer
onready var tween : Tween = $Tween
onready var dialogManager : DialogManager = $DialogBox/DialogManager

var positionNode : Position2D = null
var offset : Vector2 = Vector2(-37,-135)
#var fontSize : int
var timeLength : float
var text : String
var fade_length : float
var speed : float
var characterNode : KinematicBody2D

func _ready():
	#if fontSize:
	#	self.get_font('font').size = fontSize
	alphaTimer.wait_time = timeLength
	dialogManager.rect_size = Vector2(300, 150)
	dialogManager.text_speed = speed
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), fade_length, Tween.TRANS_LINEAR, Tween.EASE_IN)

func quick_adjust_location_and_play() -> void:
	rect_position = lerp(rect_position, 5*positionNode.position, 0.2) + offset
	funkyTimer.start()


func _init() -> void:
	._init()
	_used_scene = "res://addons/textalog/nodes/dialogue_bubble_node/dialog_bubble.tscn"

func _physics_process(delta):
	if positionNode:
		rect_position = lerp(rect_position, 5*positionNode.position, 0.2) + offset

static func instance() -> Node:
	var _default_scene := load("res://addons/textalog/nodes/dialogue_bubble_node/dialog_bubble.tscn") as PackedScene
	return _default_scene.instance()



func _on_DialogBubble_text_displayed():
	alphaTimer.start()

func _on_AlphaTimer_timeout():
	tween.start()
	closeTimer.start()

func _on_CloseTimer_timeout():
	queue_free()


func _on_FunkyTimer_timeout():
	show()
	show_text(text)
