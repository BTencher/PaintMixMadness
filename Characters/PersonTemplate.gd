extends KinematicBody2D


const ACCELERATION : int = 500
const MAX_SPEED : int = 80
const FRICTION : int = 500

var velocity : Vector2 = Vector2.ZERO

onready var animationPlayer : AnimationPlayer = $AnimationPlayer
onready var animationTree : AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
