extends Node2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator

signal playerNearEmptyMachine(body,this_node)
signal playerNearLoadedMachine(body,this_node)
signal playerFarFromPaintMachine(body,this_node)

var playersThatCanPress : Array = []

var currentPaintBucket : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	keyPressSprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InteractArea_body_entered(body):
	if currentPaintBucket:
		emit_signal("playerNearLoadedMachine",body,self)
	else:
		emit_signal("playerNearEmptyMachine",body,self)

func _on_InteractArea_body_exited(body):
	emit_signal("playerFarFromPaintMachine",body,self)
	keyPressSprite.visible = false
	keyPressAnimator.stop()
