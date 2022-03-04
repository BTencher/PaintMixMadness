extends Node2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator
onready var paintCanPosition : Position2D = $PaintCanPosition
onready var goodProgress : TextureProgress = $GoodProgress
onready var badProgress : TextureProgress = $BadProgress
onready var textureTimer : Timer = $TextureTimer
onready var interactArea : Area2D = $InteractArea
onready var shakingAnimation : AnimationPlayer = $ShakingAnimation

signal playerNearEmptyShaker(body,this_node)
signal playerNearLoadedShaker(body,this_node)
signal playerFarFromShaker(body,this_node)

var playersThatCanPress : Array = []
var currentPaintBucket : Node2D

enum States {EMPTY,RUNNING,COMPLETED}
var _state : int = States.EMPTY

# Called when the node enters the scene tree for the first time.
func _ready():
	keyPressSprite.visible = false

func add_worker_to_nearby(worker_node : KinematicBody2D) -> void:
	playersThatCanPress.append(worker_node)
	update_key_press_sprite()

func update_key_press_sprite() -> void:
	print(playersThatCanPress.size())
	if playersThatCanPress.size() > 0 and keyPressSprite.visible == false:
		keyPressSprite.visible = true
		keyPressAnimator.play("KeyPress")
	elif playersThatCanPress.size() == 0 and keyPressSprite.visible == true:
		keyPressSprite.visible = false
		keyPressAnimator.stop()

func remove_from_shaker_can_press(player_node : KinematicBody2D) -> void:
	if playersThatCanPress.find(player_node) > -1:
		playersThatCanPress.erase(player_node)
		update_key_press_sprite()

func move_and_start_shaker(paintCanNode : Node2D):
	move_paint_can_to_shaker(paintCanNode)
	move_paint_can_to_correct_position(paintCanNode)
	set_state_to_running()
	start_texture_progress()
	start_shaking_animation()

func move_paint_can_to_shaker(paintCanNode : Node2D) -> void:
	var paintCan : Node2D = paintCanNode
	paintCan.position = paintCanPosition.position
	add_child(paintCan)
	currentPaintBucket = paintCan

func move_paint_can_to_correct_position(paintCanNode : Node2D) -> void:
	move_child(currentPaintBucket,1)

func set_state_to_running() -> void:
	_state = States.RUNNING
	interactArea.monitoring = false

func start_texture_progress() -> void:
	print("start the things!")
	goodProgress.value = 0
	badProgress.value = 0
	goodProgress.visible = true
	textureTimer.start()

func start_shaking_animation() -> void:
	shakingAnimation.play("Shaking")

func update_paint_can_during_shaking() -> void:
	currentPaintBucket.position = paintCanPosition.position

func turn_off_shaker() -> void:
	shakingAnimation.play("Idle")
	goodProgress.value = 0
	badProgress.value = 0
	goodProgress.visible = false
	badProgress.visible = false
	textureTimer.stop()

func _on_InteractArea_body_entered(body):
	if currentPaintBucket:
		emit_signal("playerNearLoadedShaker",body,self)
	else:
		emit_signal("playerNearEmptyShaker",body,self)

func _on_InteractArea_body_exited(body):
	pass # Replace with function body.

func _on_TextureTimer_timeout():
	if goodProgress.value < 100:
		goodProgress.value += 1
	elif badProgress.visible == false:
		badProgress.visible = true
		_state = States.COMPLETED #Paint Filled
		currentPaintBucket.shaken = true
		interactArea.monitoring = true #Workers can now grab paint.
	elif badProgress.value < 100:
		badProgress.value += 1
	else:
		pass #make bad stuff happen.
