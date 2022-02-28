extends Node2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	keyPressSprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InteractArea_body_entered(body):
	keyPressAnimator.play("KeyPress")


func _on_InteractArea_body_exited(body):
	keyPressSprite.visible = false
	keyPressAnimator.stop()
