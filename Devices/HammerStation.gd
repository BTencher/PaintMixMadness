extends Node2D


signal playerNearHammerStation(body,this_node)
signal playerFarFromHammerStation(body,this_node)
onready var paintCanPosition : Position2D = $PaintCanPosition

var numberOfHits : int = 0
var numberOfHitsNeeded : int = 2

var playersThatCanUse : Array = []

var currentPaintBucket : Node2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator

func _ready():
	keyPressSprite.visible = false

func remove_from_hammer_station_can_use(player_node : KinematicBody2D) -> void:
	if playersThatCanUse.find(player_node) > -1:
		playersThatCanUse.erase(player_node)
		update_key_press_sprite()

func add_worker_to_nearby(worker_node : KinematicBody2D) -> void:
	playersThatCanUse.append(worker_node)
	update_key_press_sprite()

func move_paint_can_to_hammer_station(paintCanNode : Node2D) -> void:
	var paintCan : Node2D = paintCanNode
	paintCan.position = paintCanPosition.position
	add_child(paintCan)
	currentPaintBucket = paintCan
	currentPaintBucket.closeLid(true)
	numberOfHits = 0

func update_key_press_sprite() -> void:
	if playersThatCanUse.size() > 0 and keyPressSprite.visible == false:
		keyPressSprite.visible = true
		keyPressAnimator.play("KeyPress")
	elif playersThatCanUse.size() == 0 and keyPressSprite.visible == true:
		keyPressSprite.visible = false
		keyPressAnimator.stop()

func _on_Area2D_body_entered(body):
	emit_signal("playerNearHammerStation",body,self)

func _on_Area2D_body_exited(body):
	playersThatCanUse.erase(body)
	update_key_press_sprite()
	emit_signal("playerFarFromHammerStation",body,self)
