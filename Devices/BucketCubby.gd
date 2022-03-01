extends StaticBody2D

onready var keyPressSprite : Sprite = $KeyPressSprite
onready var keyPressAnimator : AnimationPlayer = $KeyPressAnimator

signal playerNearPaintCubby(body,this_node)

var playersThatCanPress : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	keyPressSprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InteractArea_body_entered(body):
	emit_signal("playerNearPaintCubby",body,self)

	#Above signal is connected in Room Code, checks if body has a state of "Empty"
	
	#Commenting out as this will be done elsewhere after checking if user can grab
	#keyPressAnimator.play("KeyPress")


#This won't work for multiplayer. Make it remove players from array and check if aray is empty?
func _on_InteractArea_body_exited(body):
	keyPressSprite.visible = false
	keyPressAnimator.stop()
