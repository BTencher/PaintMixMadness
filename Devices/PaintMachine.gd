extends Node2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator
onready var paintCanPosition : Position2D = $PaintCanPosition
onready var menuPosition : Position2D = $MenuPosition
onready var paintSpittle : Particles2D = $PaintSpittle
onready var goodProgress : TextureProgress = $GoodProgress
onready var badProgress : TextureProgress = $BadProgress
onready var goodTimer : Timer = $GoodTimer
onready var badTimer : Timer = $BadTimer
onready var interactArea : Area2D = $InteractArea


#signal playerNearEmptyMachine(body,this_node)
signal playerNearLoadedMachine(body,this_node)
signal playerFarFromPaintMachine(body,this_node)

var playersThatCanPress : Array = []

var currentPaintBucket : Node2D

var paintMachineColor : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	keyPressSprite.visible = false

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
	move_child(currentPaintBucket,3)

func get_menu_location() -> Vector2:
	return menuPosition.global_position

func run_paint_machine(color : Color) -> void:
	paintMachineColor = color
	interactArea.monitoring = false
	start_spewing_paint(paintMachineColor)
	start_texture_progress()
	currentPaintBucket.set_end_paint_color(paintMachineColor)

func start_spewing_paint(color : Color) -> void:
	paintSpittle.modulate = color
	move_child(currentPaintBucket,1)
	paintSpittle.emitting = true

func start_texture_progress() -> void:
	goodProgress.value = 0
	badProgress.value = 0
	goodProgress.visible = true
	goodTimer.start()

func turn_off_machine() -> void:
	goodProgress.value = 0
	badProgress.value = 0
	goodProgress.visible = false
	badProgress.visible = false
	paintSpittle.emitting = false
	goodTimer.stop()
	badTimer.stop()
	currentPaintBucket = null

func _on_InteractArea_body_entered(body):
	print(body._state)
	if currentPaintBucket:
		if body._state == body.States.EMPTY_HANDS:
			body.nearbyPaintMachine.append(self)
			if body.currentMachineNode:
				if body.currentMachineNode != self:
					body.currentMachineNode.playersThatCanPress.erase(body)
					body.currentMachineNode.update_key_press_sprite()
			body.currentMachineNode = self
			body._state = body.States.CAN_USE_MACHINE
			playersThatCanPress.append(body)
			update_key_press_sprite()
	else:
		if body._state == body.States.EMPTY_PAINT or body._state == body.States.CAN_USE_MACHINE:
			body.nearbyPaintMachine.append(self)
			body.currentMachineNode = self
			body._state = body.States.CAN_USE_MACHINE
			playersThatCanPress.append(body)
			update_key_press_sprite()
		#emit_signal("playerNearEmptyMachine",body,self)

func _on_InteractArea_body_exited(body):
	playersThatCanPress.erase(body)
	update_key_press_sprite()
	emit_signal("playerFarFromPaintMachine",body,self)


func _on_GoodTimer_timeout():
	if goodProgress.value < 100:
		goodProgress.value += 1
		currentPaintBucket.update_current_color(goodProgress.value)
	elif badProgress.visible == false:
		badProgress.visible = true
		currentPaintBucket.isFilled = true
		interactArea.monitoring = true #Workers can now grab paint.
		badTimer.start()


func _on_BadTimer_timeout():
	if badProgress.value < 100:
		badProgress.value += 1
	else:
		currentPaintBucket.paint_can_full()
