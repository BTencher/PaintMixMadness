extends StaticBody2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator

signal playerNearPaintCubby(body,this_node)
signal playerFarPaintCubby(body,this_node)

var playersThatCanPress : Array = []

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

func remove_from_cubby_can_press(player_node : KinematicBody2D) -> void:
	if playersThatCanPress.find(player_node) > -1:
		playersThatCanPress.erase(player_node)
		update_key_press_sprite()

func _on_InteractArea_body_entered(body):
	emit_signal("playerNearPaintCubby",body,self)

func _on_InteractArea_body_exited(body):
	playersThatCanPress.erase(body)
	update_key_press_sprite()
	emit_signal("playerFarPaintCubby",body,self)
