extends Node2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator
onready var paintCanPosition : Position2D = $PaintCanPosition
onready var menuPosition : Position2D = $MenuPosition
onready var paintSpittle : Particles2D = $PaintSpittle
onready var goodProgress : TextureProgress = $GoodProgress
onready var badProgress : TextureProgress = $BadProgress
onready var textureTimer : Timer = $TextureTimer


signal playerNearEmptyMachine(body,this_node)
signal playerNearLoadedMachine(body,this_node)
signal playerFarFromPaintMachine(body,this_node)

var playersThatCanPress : Array = []

var currentPaintBucket : Node2D

enum States {READY,RUNNING}
var _state : int = States.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	keyPressSprite.visible = false

func add_worker_to_nearby(worker_node : KinematicBody2D) -> void:
	playersThatCanPress.append(worker_node)
	update_key_press_sprite()

func update_key_press_sprite() -> void:
	if playersThatCanPress.size() > 0 and keyPressSprite.visible == false:
		keyPressSprite.visible = true
		keyPressAnimator.play("KeyPress")
	elif playersThatCanPress.size() == 0 and keyPressSprite.visible == true:
		keyPressSprite.visible = false
		keyPressAnimator.stop()

func remove_from_machine_can_press(player_node : KinematicBody2D) -> void:
	if playersThatCanPress.find(player_node) > -1:
		playersThatCanPress.erase(player_node)
		update_key_press_sprite()

func move_paint_can_to_machine(paintCanNode : Node2D) -> void:
	var paintCan : Node2D = paintCanNode
	paintCan.position = paintCanPosition.position
	add_child(paintCan)
	currentPaintBucket = paintCan

func get_menu_location() -> Vector2:
	return menuPosition.global_position

func run_paint_machine(color : Color) -> void:
	start_spewing_paint(color)
	start_texture_progress()

func start_spewing_paint(color : Color) -> void:
	paintSpittle.modulate = color
	paintSpittle.emitting = true

func start_texture_progress() -> void:
	goodProgress.value = 0
	badProgress.value = 0
	goodProgress.visible = true
	textureTimer.start()
	

func _on_InteractArea_body_entered(body):
	if currentPaintBucket:
		emit_signal("playerNearLoadedMachine",body,self)
	else:
		emit_signal("playerNearEmptyMachine",body,self)

func _on_InteractArea_body_exited(body):
	playersThatCanPress.erase(body)
	update_key_press_sprite()
	emit_signal("playerFarFromPaintMachine",body,self)


func _on_TextureTimer_timeout():
	if goodProgress.value < 100:
		goodProgress.value += 1
	elif badProgress.visible == false:
		badProgress.visible == true
	elif badProgress.value < 100:
		goodProgress.value += 1
	else:
		pass #make bad stuff happen.
