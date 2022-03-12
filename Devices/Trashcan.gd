extends StaticBody2D


onready var del : Sprite = $Del
onready var animationPlayer : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	del.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DetectPlayer_body_entered(body):
	if body.currentBucketNode != null:
		animationPlayer.play("flash del")
		body.canDeletePaint = true
		body.trashcanNode = self


func _on_DetectPlayer_body_exited(body):
	animationPlayer.stop()
	del.visible = false
	body.canDeletePaint = false
	body.trashcanNode = null
